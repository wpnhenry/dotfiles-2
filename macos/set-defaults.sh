#!/usr/bin/env bash
#
# Sets reasonable macOS defaults.
#
# Original from https://mths.be/macos

printf "› Setting macOS defaults.\\n"

# Close any open System Preferences panes, to prevent them from overriding
# settings we're about to change.
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront.
sudo -v

# Keep-alive: update existing `sudo` time stamp until script has finished.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

###############################################################################
# General security & privacy                                                  #
###############################################################################

# Disable storing information about downloaded files by Quarantine.
# Clear the file: `:> file` is equivalent to `true > file`
(:> ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2) &> /dev/null
# Make the file immutable.
sudo chflags schg ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2 &> /dev/null

# Disable Bonjour multicast advertisements.
sudo defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool true

# Disable automatic login.
sudo defaults delete /Library/Preferences/com.apple.loginwindow autoLoginUser &> /dev/null
sudo rm /etc/kcpassword &> /dev/null

# Disable remote control infrared receiver.
sudo defaults write /Library/Preferences/com.apple.driver.AppleIRController DeviceEnabled -bool false

# Allow apps downloaded from "Anywhere".
sudo spctl --master-disable

# Do not send diagnostic & usage data to Apple.
defaults -currentHost write com.apple.SubmitDiagInfo AutoSubmit -bool false

# Save to disk (not to iCloud) by default.
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Disable crash reporter.
defaults write com.apple.CrashReporter DialogType none

# Disable location services.
defaults write com.apple.MCX DisableLocationServices -bool true

# Require password immediately after sleep or screen saver begins.
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

###############################################################################
# General UI/UX                                                               #
###############################################################################

# Disable the sound effects on boot.
sudo nvram SystemAudioVolume=" "

# Disable transparency in the menu bar and elsewhere on Yosemite.
defaults write com.apple.universalaccess reduceTransparency -bool true

# Set highlight color to green.
defaults write NSGlobalDomain AppleHighlightColor -string "0.764700 0.976500 0.568600"

# Set sidebar icon size to medium.
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

# Always show scrollbars.
# Possible values:
#   WhenScrolling
#   Automatic
#   Always
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

# Disable the over-the-top focus ring animation.
defaults write NSGlobalDomain NSUseAnimatedFocusRing -bool false

# Increase window resize speed for Cocoa applications.
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# Expand save panel by default.
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default.
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Automatically quit printer app once the print jobs complete.
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Disable the "Are you sure you want to open this application?" dialog.
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Remove duplicates in the "Open With" menu.
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

# Display ASCII control characters using caret notation in standard text views.
# Try e.g. `cd /tmp; unidecode "\x{0000}" > cc.txt; open -e cc.txt`
defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true

# Disable "Resume" system-wide.
defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

# Disable automatic termination of inactive apps.
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

# Set Help Viewer windows to non-floating mode.
defaults write com.apple.helpviewer DevMode -bool true

# Restart automatically if the computer freezes.
sudo systemsetup -setrestartfreeze on

# Disable "Notification Center" and remove the menu bar icon.
launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2> /dev/null

# Disable automatic capitalization as it's annoying when typing code.
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable smart dashes as they're annoying when typing code.
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable automatic period substitution as it's annoying when typing code.
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable smart quotes as they're annoying when typing code.
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable auto-correct.
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Hide battery percentage
defaults write com.apple.menuextra.battery ShowPercent -string "NO"

# Show certain preferences in menu bar.
#   1. Wi-Fi
#   2. Volume
#   3. Displays
#   4. Battery
#   5. Date & Time
#   6. Keyboard
defaults write com.apple.systemuiserver menuExtras -array \
	"/System/Library/CoreServices/Menu Extras/AirPort.menu" \
	"/System/Library/CoreServices/Menu Extras/Volume.menu" \
	"/System/Library/CoreServices/Menu Extras/Displays.menu" \
	"/System/Library/CoreServices/Menu Extras/Battery.menu" \
	"/System/Library/CoreServices/Menu Extras/Clock.menu" \
	"/System/Library/CoreServices/Menu Extras/TextInput.menu"

# Set local reference to the `airport` command-line utility for later use.
AIRPORT="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"

# Join Preferred Wi-Fi networks.
# Possible values:
#   * Automatic
#   * Preferred
#   * Ranked
#   * Recent
#   * Strongest
sudo "$AIRPORT" prefs JoinMode=Preferred

# Do not ask to join new networks.
# Possible values:
#   * Prompt
#   * JoinOpen
#   * KeepLooking
#   * DoNothing
sudo "$AIRPORT" prefs JoinModeFallback=DoNothing

# Remember networks this computer has joined.
sudo "$AIRPORT" prefs RememberRecentNetworks=YES

# Require administrator authorization to create computer-to-computer networks.
sudo "$AIRPORT" prefs RequireAdminIBSS=YES

# Require administrator authorization to change networks.
sudo "$AIRPORT" prefs RequireAdminNetworkChange=YES

# Require administrator authorization to turn Wi-Fi on or off.
sudo "$AIRPORT" prefs RequireAdminPowerToggle=YES

# Define list of DNS servers to set up.
#   1. Google
#   2. CloudFlare
#   3. Quad9
#   4. OpenDNS
DNS_SERVERS=(
	"8.8.8.8"
	"8.8.4.4"

	"1.1.1.1"

	"9.9.9.9"

	"208.67.222.222"
	"208.67.220.220"
)

# Clear all DNS entries.
sudo networksetup -setdnsservers "Wi-Fi" "Empty"
sudo networksetup -setdnsservers "Thunderbolt Ethernet" "Empty"

# Set DNS entries.
sudo networksetup -setdnsservers "Wi-Fi" ${DNS_SERVERS[*]}
sudo networksetup -setdnsservers "Thunderbolt Ethernet" ${DNS_SERVERS[*]}

# Flush DNS cache.
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder

# Set the timezone; see `sudo systemsetup -listtimezones` for other values.
sudo systemsetup -settimezone "America/Hermosillo" > /dev/null

# Set date and time automatically.
sudo systemsetup -setusingnetworktime on > /dev/null

# Set the clock to show the date and use a 12-hour clock with AM/PM.
defaults write com.apple.menuextra.clock DateFormat -string "MMM d  h:mm a"

# Disable the flashing time separators.
defaults write com.apple.menuextra.clock FlashDateSeparators -bool false

# Set the clock to be digital.
defaults write com.apple.menuextra.clock IsAnalog -bool false

###############################################################################
# SSD-specific tweaks                                                         #
###############################################################################

# Disable hibernation (speeds up entering sleep mode).
sudo pmset -a hibernatemode 0

###############################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
###############################################################################

# Disable "natural" (Lion-style) scrolling.
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Increase sound quality for Bluetooth headphones/headsets.
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

# Enable full keyboard access for all controls.
# (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Use scroll gesture with the Ctrl (^) modifier key to zoom.
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
# Follow the keyboard focus while zoomed in.
defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

# Disable press-and-hold for keys in favor of key repeat.
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Set a blazingly fast keyboard repeat rate.
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 20

# Set language and text formats.
defaults write NSGlobalDomain AppleLanguages -array "en" "es"
defaults write NSGlobalDomain AppleLocale -string "en_US@currency=USD"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricUnits -bool true

# Use all F1, F2, etc. keys as standard function keys.
defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true

# Set tracking speed.
defaults write NSGlobalDomain com.apple.mouse.scaling -float 0.875

# Show language menu in the top right corner of the boot screen.
sudo defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool true

# Stop iTunes from responding to the keyboard media keys.
launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2> /dev/null

# Turn off keyboard brightness.
sudo defaults write /Library/Preferences/com.apple.iokit.AmbientLightSensor "Keyboard Manual Brightness" -int 0
sudo defaults write /Library/Preferences/com.apple.iokit.AmbientLightSensor "Keyboard Muted" -bool true

###############################################################################
# Screen                                                                      #
###############################################################################

# Save screenshots to ~/Pictures.
defaults write com.apple.screencapture location -string "${HOME}/Pictures"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF).
defaults write com.apple.screencapture type -string "png"

# Disable shadow in screenshots.
defaults write com.apple.screencapture disable-shadow -bool true

# Enable subpixel font rendering on non-Apple LCDs.
# Reference: https://github.com/kevinSuttle/macOS-Defaults/issues/17#issuecomment-266633501
defaults write NSGlobalDomain AppleFontSmoothing -int 1

# Enable HiDPI display modes (requires restart).
sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

# Show mirroring options in the menu bar when available.
defaults write com.apple.airplay showInMenuBarIfPresent -bool true

###############################################################################
# Finder                                                                      #
###############################################################################

# Open folders in tabs instead of new windows.
defaults write com.apple.finder FinderSpawnTab -bool true

# Allow quitting via ⌘ + Q; doing so will also hide desktop icons.
defaults write com.apple.finder QuitMenuItem -bool true

# Disable window animations and Get Info animations.
defaults write com.apple.finder DisableAllAnimations -bool true

# Set Downloads folder as the default location for new Finder windows.
# Possible values:
#   PfCm: Computer
#   PfVo: Volume
#   PfHm: $HOME
#   PfDe: Desktop
#   PfDo: Documents
#   PfAF: All My Files
#   PfLo: Other
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Downloads/"

# Show icons for hard drives, servers, and removable media on the desktop.
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Show hidden files by default.
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show all filename extensions.
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show status bar.
defaults write com.apple.finder ShowStatusBar -bool true

# Show path bar.
defaults write com.apple.finder ShowPathbar -bool true

# Hide preview pane.
defaults write com.apple.finder ShowPreviewPane -bool false

# Display full POSIX path as Finder window title.
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Keep folders on top when sorting by name.
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# When performing a search, search the current folder by default.
# Possible values:
#   SCev: This Mac
#   SCcf: Current Folder
#   SCsp: Previous Scope
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension.
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Enable spring loading for directories.
defaults write NSGlobalDomain com.apple.springing.enabled -bool true

# Remove the spring loading delay for directories.
defaults write NSGlobalDomain com.apple.springing.delay -float 0

# Avoid creating .DS_Store files on network or USB volumes.
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Disable disk image verification.
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

# Automatically open a new Finder window when a volume is mounted.
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Show item info near icons on the desktop and in other icon views.
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist

# Show item info to the right of the icons on the desktop.
/usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:labelOnBottom false" ~/Library/Preferences/com.apple.finder.plist

# Enable snap-to-grid for icons on the desktop and in other icon views.
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

# Increase grid spacing for icons on the desktop and in other icon views.
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist

# Increase the size of icons on the desktop and in other icon views.
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist

# Use list view in all Finder windows by default.
# Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Disable the warning before emptying the Trash.
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Enable AirDrop over Ethernet and on unsupported Macs running Lion.
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

# Show the `~/Library` folder.
chflags nohidden ~/Library

# Show the `/Volumes` folder.
sudo chflags nohidden /Volumes

# Expand the following File Info panes:
# "General", "Open with", and "Sharing & Permissions"
defaults write com.apple.finder FXInfoPanesExpanded -dict \
	General -bool true \
	OpenWith -bool true \
	Privileges -bool true

###############################################################################
# Dock, Dashboard, and hot corners                                            #
###############################################################################

# Enable highlight hover effect for the grid view of a stack (Dock).
defaults write com.apple.dock mouse-over-hilite-stack -bool true

# Set the icon size of Dock items to 48 pixels.
defaults write com.apple.dock tilesize -int 48

# Lock the Dock size.
defaults write com.apple.Dock size-immutable -bool true

# Change minimize/maximize window effect.
defaults write com.apple.dock mineffect -string "scale"

# Minimize windows into their application's icon.
defaults write com.apple.dock minimize-to-application -bool true

# Enable spring loading for all Dock items.
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

# Show indicator lights for open applications in the Dock.
defaults write com.apple.dock show-process-indicators -bool true

# Don't animate opening applications from the Dock.
defaults write com.apple.dock launchanim -bool false

# Disable bounce animation on notification.
defaults write com.apple.dock no-bouncing -bool true

# Speed up "Mission Control" animations.
defaults write com.apple.dock expose-animation-duration -float 0.1

# Don't group windows by application in "Mission Control".
# (i.e. use the old Exposé behavior instead)
defaults write com.apple.dock expose-group-by-app -bool false

# Disable Dashboard.
defaults write com.apple.dashboard mcx-disabled -bool true

# Don't show Dashboard as a Space.
defaults write com.apple.dock dashboard-in-overlay -bool true

# Don't automatically rearrange Spaces based on most recent use.
defaults write com.apple.dock mru-spaces -bool false

# Remove the auto-hiding Dock delay.
defaults write com.apple.dock autohide-delay -float 0

# Remove the animation when hiding/showing the Dock.
defaults write com.apple.dock autohide-time-modifier -float 0

# Disable automatically hiding and showing the Dock.
defaults write com.apple.dock autohide -bool false

# Make Dock icons of hidden applications translucent.
defaults write com.apple.dock showhidden -bool true

# Don't show recent applications in Dock.
defaults write com.apple.dock show-recents -bool false

# Reset Launchpad, but keep the desktop wallpaper intact.
find "${HOME}/Library/Application Support/Dock" -maxdepth 1 -name "*-*.db" -delete

# Add iOS & Watch Simulator to Launchpad.
sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app" "/Applications/Simulator.app"
sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator (Watch).app" "/Applications/Simulator (Watch).app"

# Hot corners
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center

# Top left screen corner → no-op.
defaults write com.apple.dock wvous-tl-corner -int 0
defaults write com.apple.dock wvous-tl-modifier -int 0

# Top right screen corner → no-op.
defaults write com.apple.dock wvous-tr-corner -int 0
defaults write com.apple.dock wvous-tr-modifier -int 0

# Bottom left screen corner → no-op.
defaults write com.apple.dock wvous-bl-corner -int 0
defaults write com.apple.dock wvous-bl-modifier -int 0

# Bottom left screen corner → no-op.
defaults write com.apple.dock wvous-br-corner -int 0
defaults write com.apple.dock wvous-br-modifier -int 0

# Clear out icons in Dock.
defaults write com.apple.dock persistent-apps -array

# Add icons to Dock:
#  * Google Chrome
#  * Brave
#  * (small spacer tile)
#  * Sublime Text 2
#  * Hyper
#  * (small spacer tile)
#  * Signal
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Google Chrome.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Brave Browser.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="small-spacer-tile";}'
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Sublime Text 2.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Hyper.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="small-spacer-tile";}'
defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Signal.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'

###############################################################################
# Safari & WebKit                                                             #
###############################################################################

# Don't send search queries to Apple.
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true
defaults write com.apple.Safari WebsiteSpecificSearchEnabled -bool false

# Show the full URL in the address bar (note: this still hides the scheme).
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

# Set Safari's home page to `about:blank` for faster loading.
defaults write com.apple.Safari HomePage -string "about:blank"

# Prevent Safari from opening 'safe' files automatically after downloading.
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# Allow hitting the Backspace key to go to the previous page in history.
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true

# Hide Safari's bookmarks bar by default.
defaults write com.apple.Safari ShowFavoritesBar -bool false

# Hide Safari's sidebar in Top Sites.
defaults write com.apple.Safari ShowSidebarInTopSites -bool false

# Disable Safari's thumbnail cache for History and Top Sites.
defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2

# Enable Safari's debug menu.
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

# Make Safari's search banners default to Contains instead of Starts With.
defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

# Remove useless icons from Safari's bookmarks bar.
defaults write com.apple.Safari ProxiesInBookmarksBar "()"

# Enable the Develop menu and the Web Inspector in Safari.
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

# Add a context menu item for showing the Web Inspector in web views.
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# Enable continuous spellchecking.
defaults write com.apple.Safari WebContinuousSpellCheckingEnabled -bool true

# Disable auto-correct.
defaults write com.apple.Safari WebAutomaticSpellingCorrectionEnabled -bool false

# Disable AutoFill.
defaults write com.apple.Safari AutoFillFromAddressBook -bool false
defaults write com.apple.Safari AutoFillPasswords -bool false
defaults write com.apple.Safari AutoFillCreditCardData -bool false
defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false

# Warn about fraudulent websites.
defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true

# Disable plug-ins.
defaults write com.apple.Safari WebKitPluginsEnabled -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2PluginsEnabled -bool false

# Disable Java.
defaults write com.apple.Safari WebKitJavaEnabled -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled -bool false

# Block pop-up windows.
defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false

# Enable "Do Not Track".
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

# Update extensions automatically.
defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true

###############################################################################
# Spotlight                                                                   #
###############################################################################

# Disable Spotlight indexing for any volume that gets mounted and has not yet
# been indexed before.
# Use `sudo mdutil -i off "/Volumes/foo"` to stop indexing any volume.
sudo defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array "/Volumes"

# Change indexing order and disable some search results
defaults write com.apple.spotlight orderedItems -array \
	'{"enabled" = 1;"name" = "APPLICATIONS";}' \
	'{"enabled" = 1;"name" = "SYSTEM_PREFS";}' \
	'{"enabled" = 1;"name" = "DIRECTORIES";}' \
	'{"enabled" = 1;"name" = "DOCUMENTS";}' \
	'{"enabled" = 1;"name" = "IMAGES";}' \
	'{"enabled" = 1;"name" = "PDF";}' \
	'{"enabled" = 1;"name" = "FONTS";}' \
	'{"enabled" = 0;"name" = "BOOKMARKS";}' \
	'{"enabled" = 0;"name" = "CONTACT";}' \
	'{"enabled" = 0;"name" = "EVENT_TODO";}' \
	'{"enabled" = 0;"name" = "MENU_CONVERSION";}' \
	'{"enabled" = 0;"name" = "MENU_DEFINITION";}' \
	'{"enabled" = 0;"name" = "MENU_EXPRESSION";}' \
	'{"enabled" = 0;"name" = "MENU_OTHER";}' \
	'{"enabled" = 0;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}' \
	'{"enabled" = 0;"name" = "MENU_WEBSEARCH";}' \
	'{"enabled" = 0;"name" = "MESSAGES";}' \
	'{"enabled" = 0;"name" = "MOVIES";}' \
	'{"enabled" = 0;"name" = "MUSIC";}' \
	'{"enabled" = 0;"name" = "PRESENTATIONS";}' \
	'{"enabled" = 0;"name" = "SOURCE";}' \
	'{"enabled" = 0;"name" = "SPREADSHEETS";}'

# Load new settings before rebuilding the index.
killall mds > /dev/null 2>&1

# Make sure indexing is enabled for the main volume.
sudo mdutil -i on / > /dev/null

# Rebuild the index from scratch.
sudo mdutil -E / > /dev/null

###############################################################################
# Terminal                                                                    #
###############################################################################

# Only use UTF-8 in Terminal.app.
defaults write com.apple.terminal StringEncodings -array 4

# Enable Secure Keyboard Entry in Terminal.app.
# See: https://security.stackexchange.com/a/47786/8918
defaults write com.apple.terminal SecureKeyboardEntry -bool true

# Disable the annoying line marks.
defaults write com.apple.Terminal ShowLineMarks -int 0

###############################################################################
# Time Machine                                                                #
###############################################################################

# Prevent Time Machine from prompting to use new hard drives as backup volume.
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Disable local Time Machine backups.
hash tmutil &> /dev/null && sudo tmutil disablelocal

###############################################################################
# Activity Monitor                                                            #
###############################################################################

# Show the main window when launching Activity Monitor.
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# Visualize CPU usage in the Activity Monitor Dock icon.
defaults write com.apple.ActivityMonitor IconType -int 5

# Show all processes in Activity Monitor.
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Sort Activity Monitor results by CPU usage.
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

###############################################################################
# TextEdit, QuickTime and Disk Utility                                        #
###############################################################################

# Use plain text mode for new TextEdit documents.
defaults write com.apple.TextEdit RichText -int 0

# Open and save files as UTF-8 in TextEdit.
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

# Enable the debug menu in Disk Utility.
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
defaults write com.apple.DiskUtility advanced-image-options -bool true

# Auto-play videos when opened with QuickTime Player.
defaults write com.apple.QuickTimePlayerX MGPlayMovieOnOpen -bool true

###############################################################################
# Mac App Store                                                               #
###############################################################################

# Enable Debug Menu in the Mac App Store.
defaults write com.apple.appstore ShowDebugMenu -bool true

# Enable the automatic update check.
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# Check for software updates daily, not just once per week.
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# Download newly available updates in background.
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

# Install System data files & security updates.
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

# Automatically download apps purchased on other Macs.
defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 1

# Turn on app auto-update.
defaults write com.apple.commerce AutoUpdate -bool true

###############################################################################
# Photos                                                                      #
###############################################################################

# Prevent Photos from opening automatically when devices are plugged in.
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

###############################################################################
# Calculator                                                                  #
###############################################################################

# Enable scientific calculator
defaults write com.apple.calculator ViewDefaultsKey -string "Scientific"

# Show thousands separator
defaults write com.apple.calculator SeparatorsDefaultsKey -int 1

# Set decimal places
defaults write com.apple.calculator PrecisionDefaultsKey_2 -int 8

###############################################################################
# 1Password                                                                   #
###############################################################################

# Always keep 1Password mini running.
defaults write com.agilebits.onepassword-osx KeepHelperRunning -bool true

# Show mini app icon in the menu bar.
defaults write com.agilebits.onepassword-osx ShowStatusItem -bool true

# Use rich icons.
defaults write com.agilebits.onepassword-osx ShowRichIcons -bool true

# Don't show item count in sidebar.
defaults write com.agilebits.onepassword-osx ShowItemCounts -bool false

# Conceal passwords.
defaults write com.agilebits.onepassword-osx ConcealPasswords -bool true

# Automatically check for updates.
defaults write com.agilebits.onepassword-osx CheckForSoftwareUpdatesEnabled -bool true

###############################################################################
# BitBar                                                                      #
###############################################################################

# Create plugin folder if it doesn't exist.
mkdir -p "${HOME}/bitbar-plugins"

# Set plugin folder.
defaults write com.matryer.BitBar pluginsDirectory -string "${HOME}/bitbar-plugins"

###############################################################################
# Caffeine                                                                    #
###############################################################################

# Activate at launch.
defaults write com.lightheadsw.Caffeine ActivateOnLaunch -bool true

# Default duration.
# Possible values:
#   0 (Indefinitely)
#   5 (5 minutes)
#   10 (10 minutes)
#   15 (15 minutes)
#   30 (30 minutes)
#   60 (1 hour)
#   120 (2 hours)
#   300 (5 hours)
defaults write com.lightheadsw.Caffeine DefaultDuration -int 0

# Suppress welcome message when starting.
defaults write com.lightheadsw.Caffeine SuppressLaunchMessage -bool true

###############################################################################
# Calibre                                                                     #
###############################################################################

# Add E-book Viewer to Launchpad.
sudo ln -sf "/Applications/calibre.app/Contents/ebook-viewer.app" "/Applications/E-book Viewer.app"

###############################################################################
# Fitbit Connect                                                              #
###############################################################################

# Don't show menu bar icon.
defaults write com.fitbit.GalileoClient menubarHelperNotKeepRunning -int 0

###############################################################################
# Flux                                                                        #
###############################################################################

# Start Flux at login.
defaults write org.herf.Flux startAtLogin -bool true

# Set recommended colors.
defaults write org.herf.Flux lateColorTemp -int 1900

# Set location
defaults write org.herf.Flux location -string "29.0975,-111.022"
defaults write org.herf.Flux locationTextField -string "29.0975, -111.022"

###############################################################################
# Google Chrome                                                               #
###############################################################################

# Full list of supported policies: https://www.chromium.org/administrators/policy-list-3

# -- Default search provider

# Enable the use of a default search provider.
defaults write com.google.Chrome DefaultSearchProviderEnabled -bool true

# Set the name of the default search provider.
defaults write com.google.Chrome DefaultSearchProviderName -string "Encrypted Google"

# Set the keyword of the default search provider provider, as trigger, for the omnibox.
defaults write com.google.Chrome DefaultSearchProviderKeyword -string "google.com"

# Set the search URL of the default search provider.
defaults write com.google.Chrome DefaultSearchProviderSearchURL -string "https://encrypted.google.com/search?hl=en&q={searchTerms}"

# -- Google Cast

# Enable Google Cast.
defaults write com.google.Chrome EnableMediaRouter -bool true

# Hide the Google Cast toolbar icon.
defaults write com.google.Chrome ShowCastIconInToolbar -bool false

# -- Home page

# Use New Tab Page as homepage.
defaults write com.google.Chrome HomepageIsNewTabPage -bool true

# -- Password manager

# Disable saving passwords to the password manager.
defaults write com.google.Chrome PasswordManagerEnabled -bool false

# -- Safe Browsing settings

# Protect you and your device from dangerous sites.
defaults write com.google.Chrome SafeBrowsingEnabled -bool true

# Disable sending system information and page content to Google servers to help detect dangerous apps and sites.
defaults write com.google.Chrome SafeBrowsingExtendedReportingEnabled -bool false

# -- Startup pages

# Continue where you left off on startup.
defaults write com.google.Chrome RestoreOnStartup -int 1

# --

# Prevent sites with abusive experiences from opening new windows or tabs.
defaults write com.google.Chrome AbusiveExperienceInterventionEnforce -bool true

# Disallow ads on sites with intrusive ads.
defaults write com.google.Chrome AdsSettingForIntrusiveAdsSites -int 2

# Disable web service to help resolve navigation errors.
defaults write com.google.Chrome AlternateErrorPagesEnabled -bool false

# Always open PDF files in browser instead of downloading them.
defaults write com.google.Chrome AlwaysOpenPdfExternally -bool false

# Set the application locale.
defaults write com.google.Chrome ApplicationLocaleValue -string "en-US"

# Disable autoFill for addresses.
defaults write com.google.Chrome AutofillAddressEnabled -bool false

# Disable autofill for credit cards.
defaults write com.google.Chrome AutofillCreditCardEnabled -bool false

# Disable playing videos automatically (without user consent) with audio content.
defaults write com.google.Chrome AutoplayAllowed -bool false

# Stop running background apps when browser is closed.
defaults write com.google.Chrome BackgroundModeEnabled -bool true

# Enable bookmark bar.
defaults write com.google.Chrome BookmarkBarEnabled -bool true

# Disallow Add Person from the user manager.
defaults write com.google.Chrome BrowserAddPersonEnabled -bool false

# Disable guest logins.
defaults write com.google.Chrome BrowserGuestModeEnabled -bool false

# Disallow queries to a Google time service.
defaults write com.google.Chrome BrowserNetworkTimeQueriesEnabled -bool false

# Disable browser sign-in.
defaults write com.google.Chrome BrowserSignin -int 0

# Don't use built-in DNS client.
defaults write com.google.Chrome BuiltInDnsClientEnabled -bool false

# Disable mandatory cloud management enrollment.
defaults write com.google.Chrome CloudManagementEnrollmentMandatory -bool false

# Set as default browser.
defaults write com.google.Chrome DefaultBrowserSettingEnabled -bool true

# Set default download directory.
defaults write com.google.Chrome DefaultDownloadDirectory -string "$HOME/Downloads"

# Allow usage of the developer tools.
defaults write com.google.Chrome DeveloperToolsAvailability -int 1

# Use the system-native print preview dialog instead of the print preview.
defaults write com.google.Chrome DisablePrintPreview -bool true

# Disable taking screenshots.
defaults write com.google.Chrome DisableScreenshots -bool true

# Set download directory.
defaults write com.google.Chrome DownloadDirectory -string "$HOME/Downloads"

# Don't enforce Google SafeSearch.
defaults write com.google.Chrome ForceGoogleSafeSearch -bool false

# Don't enforce restricted mode on YouTube.
defaults write com.google.Chrome ForceYouTubeRestrict -int 0

# Use hardware acceleration when available.
defaults write com.google.Chrome HardwareAccelerationModeEnabled -bool true

# Don't import autofill form data from default browser on first run.
defaults write com.google.Chrome ImportAutofillFormData -bool false

# Don't import bookmarks from default browser on first run.
defaults write com.google.Chrome ImportBookmarks -bool false

# Don't import browsing history from default browser on first run.
defaults write com.google.Chrome ImportHistory -bool false

# Don't import homepage from default browser on first run.
defaults write com.google.Chrome ImportHomepage -bool false

# Don't import saved passwords from default browser on first run.
defaults write com.google.Chrome ImportSavedPasswords -bool false

# Don't import search engines from default browser on first run.
defaults write com.google.Chrome ImportSearchEngine -bool false

# Allow Google Cast to connect to Cast devices on private IP addresses only.
defaults write com.google.Chrome MediaRouterCastAllowAllIPs -bool false

# Disable reporting of usage and crash-related data.
defaults write com.google.Chrome MetricsReportingEnabled -bool false

# Disable prediction service to load pages more quickly (on any network connection).
defaults write com.google.Chrome NetworkPredictionOptions -int 2

# Disable showing full-tab promotional content.
defaults write com.google.Chrome PromotionalTabsEnabled -bool false

# Don't ask where to save each file before downloading.
defaults write com.google.Chrome PromptForDownloadLocation -bool false

# Allow proceeding from the SSL warning page.
defaults write com.google.Chrome SSLErrorOverrideAllowed -bool true

# Disable SafeSites adult content filtering.
defaults write com.google.Chrome SafeSitesFilterBehavior -int 0

# Disable prediction service to help complete searches and URLs typed in the address bar.
defaults write com.google.Chrome SearchSuggestEnabled -bool false

# Hide the apps shortcut in the bookmark bar.
defaults write com.google.Chrome ShowAppsShortcutInBookmarkBar -bool false

# Hide the Home button on the toolbar.
defaults write com.google.Chrome ShowHomeButton -bool false

# Enable site isolation for every site.
defaults write com.google.Chrome SitePerProcess -bool true

# Disable spell checking web service.
defaults write com.google.Chrome SpellCheckServiceEnabled -bool false

# Disable synchronization of data with Google.
defaults write com.google.Chrome SyncDisabled -bool true

# Disable tab lifecycles.
defaults write com.google.Chrome TabLifecyclesEnabled -bool false

# Disable the integrated Google Translate service.
defaults write com.google.Chrome TranslateEnabled -bool false

# Disable URL-keyed anonymized data collection.
defaults write com.google.Chrome UrlKeyedAnonymizedDataCollectionEnabled -bool false

# Disable Web Proxy Auto-Discovery optimization.
defaults write com.google.Chrome WPADQuickCheckEnabled -bool false

# Disable collection of WebRTC event logs from Google services.
defaults write com.google.Chrome WebRtcEventLogCollectionAllowed -bool false

###############################################################################
# ImageOptim                                                                  #
###############################################################################

# Strip PNG metadata.
defaults write net.pornel.ImageOptim PngOutRemoveChunks -bool true

# Strip JPEG metadata.
defaults write net.pornel.ImageOptim JpegTranStripAll -bool true

# Preserve file permissions, attributes and hardlinks
defaults write net.pornel.ImageOptim PreservePermissions -bool true

###############################################################################
# Lightshot Screenshot                                                        #
###############################################################################

# Capture screenshot via ⌘ + ⇧ + 1.
defaults write com.skillbrains.lightshot GlobalShortcut -data 62706c6973743030d40102030405061617582476657273696f6e58246f626a65637473592461726368697665725424746f7012000186a0a307080f55246e756c6cd3090a0b0c0d0e574b6579436f64655624636c6173735d4d6f646966696572466c616773101280021200120000d2101112135a24636c6173736e616d655824636c61737365735b4d415353686f7274637574a214155b4d415353686f7274637574584e534f626a6563745f100f4e534b657965644172636869766572d1181954726f6f74800108111a232d32373b414850576567696e737e879396a2abbdc0c50000000000000101000000000000001a000000000000000000000000000000c7

# Don't downscale retina screens.
defaults write com.skillbrains.lightshot downscaleRetinaScreens -bool false

###############################################################################
# LimeChat                                                                    #
###############################################################################

# Highlight your nickname.
defaults write net.limechat.LimeChat-AppStore Preferences.Keyword.current_nick -int 1

# Confirm to quit the application.
defaults write net.limechat.LimeChat-AppStore Preferences.General.confirm_quit -int 1

# Connect to server on double click.
defaults write net.limechat.LimeChat-AppStore Preferences.General.connect_on_doubleclick -int 1

# Disconnect from server on double click.
defaults write net.limechat.LimeChat-AppStore Preferences.General.disconnect_on_doubleclick -int 1

# Join channel on double click.
defaults write net.limechat.LimeChat-AppStore Preferences.General.join_on_doubleclick -int 1

# Leave channel on double click.
defaults write net.limechat.LimeChat-AppStore Preferences.General.leave_on_doubleclick -int 1

# Hide join/leave events.
defaults write net.limechat.LimeChat-AppStore Preferences.General.show_join_leave -int 0

# Override log font.
defaults write net.limechat.LimeChat-AppStore Preferences.Theme.override_log_font -int 1
defaults write net.limechat.LimeChat-AppStore Preferences.Theme.log_font_name -string "FiraMono-Regular"
defaults write net.limechat.LimeChat-AppStore Preferences.Theme.log_font_size -int 13

# Override input font.
defaults write net.limechat.LimeChat-AppStore Preferences.Theme.override_input_font -int 1
defaults write net.limechat.LimeChat-AppStore Preferences.Theme.input_font_name -string "FiraMono-Regular"
defaults write net.limechat.LimeChat-AppStore Preferences.Theme.input_font_size -int 13

# Show dialog when received a file transfer.
defaults write net.limechat.LimeChat-AppStore Preferences.Dcc.action -int 1

###############################################################################
# Noisy                                                                       #
###############################################################################

# Set initial noise type to "Off".
defaults write com.rathertremendous.noisy NoiseType -int 0

# Set previous noisy type to "Brown".
defaults write com.rathertremendous.noisy PreviousNoiseType -int 3

# Set volume to 100%.
defaults write com.rathertremendous.noisy NoiseVolume -int 1

###############################################################################
# QuickTime Player                                                            #
###############################################################################

# Don't show mouse clicks in recording.
defaults write com.apple.QuickTimePlayerX MGScreenRecordingDocumentShowMouseClicksUserDefaultsKey -int 0

# Set Microphone input to "None" for recording.
defaults delete com.apple.QuickTimePlayerX "MGCaptureDeviceSelection MGScreenRecordingDocument"

# Clear recent items.
defaults delete com.apple.QuickTimePlayerX MGRecentURLPropertyLists

###############################################################################
# Spectacle                                                                   #
###############################################################################

# Turn on automatic updates.
defaults write com.divisiblebyzero.Spectacle SUEnableAutomaticChecks -bool true

# Run as a background application (false). Run in the status menu (true).
defaults write com.divisiblebyzero.Spectacle StatusItemEnabled -bool false

###############################################################################
# Transmission                                                                #
###############################################################################

# Use `~/Documents/Torrents` to store incomplete downloads.
defaults write org.m0k.transmission UseIncompleteDownloadFolder -bool true
defaults write org.m0k.transmission IncompleteDownloadFolder -string "${HOME}/Documents/Torrents"

# Use `~/Downloads` to store completed downloads.
defaults write org.m0k.transmission DownloadLocationConstant -bool true

# Don't prompt for confirmation before downloading.
defaults write org.m0k.transmission DownloadAsk -bool false
defaults write org.m0k.transmission MagnetOpenAsk -bool false

# Don't prompt for confirmation before removing non-downloading active transfers.
defaults write org.m0k.transmission CheckRemoveDownloading -bool true

# Trash original torrent files.
defaults write org.m0k.transmission DeleteOriginalTorrent -bool true

# Hide the donate message.
defaults write org.m0k.transmission WarningDonate -bool false

# Hide the legal disclaimer.
defaults write org.m0k.transmission WarningLegal -bool false

# IP block list.
# Source: https://giuliomac.wordpress.com/2014/02/19/best-blocklist-for-transmission/
defaults write org.m0k.transmission BlocklistNew -bool true
defaults write org.m0k.transmission BlocklistURL -string "http://john.bitsurge.net/public/biglist.p2p.gz"
defaults write org.m0k.transmission BlocklistAutoUpdate -bool true

# Randomize port on launch.
defaults write org.m0k.transmission RandomPort -bool true

# Turn on "Stop seeding at ratio" of 2.00.
defaults write org.m0k.transmission RatioCheck -bool true
defaults write org.m0k.transmission RatioLimit -string "2.00"

# Turn on "Download with maximum of" 1 active transfer.
defaults write org.m0k.transmission Queue -bool true
defaults write org.m0k.transmission QueueDownloadNumber -int 1

###############################################################################
# VLC media player                                                            #
###############################################################################

# Enable checking for updates automatically.
defaults write org.videolan.vlc SUEnableAutomaticChecks -bool true

# Disable checking online for album art and metadata.
defaults write org.videolan.vlc SUSendProfileInfo -bool true

# Set language to "American English".
defaults write org.videolan.vlc language -string "en"

###############################################################################
# Kill affected applications                                                  #
###############################################################################

AFFECTED_APPS=(
	"Activity Monitor"
	"BitBar"
	"Caffeine"
	"Calculator"
	"cfprefsd"
	"Dock"
	"Finder"
	"Fitbit Connect"
	"Flux"
	"Google Chrome"
	"ImageOptim"
	"Lightshot Screenshot"
	"LimeChat"
	"Noisy"
	"Photos"
	"Safari"
	"Spectacle"
	"SystemUIServer"
	"Terminal"
	"Transmission"
	"VLC"
)

for app in "${AFFECTED_APPS[@]}"
do
	killall "${app}" &> /dev/null
done

echo 'Done. Note that some of these changes require a logout/restart to take effect.'
