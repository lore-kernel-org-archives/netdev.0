From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: [PATCH] refactor wireless Kconfig
Date: Mon, 23 Apr 2007 14:34:43 -0400
Message-ID: <20070423183443.GD5883@tuxdriver.com>
References: <20070423183334.GC5883@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070423183334.GC5883-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>

This patch refactors the wireless Kconfig all over and already
introduces net/wireless/Kconfig with just the WEXT bit for now,
the cfg80211 patch will add to that as well.

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
---
 drivers/net/Makefile                  |    2 +-
 drivers/net/wireless/Kconfig          |  120 ++++++++++++++-------------------
 drivers/net/wireless/bcm43xx/Kconfig  |    3 +-
 drivers/net/wireless/hostap/Kconfig   |    3 +-
 drivers/net/wireless/zd1211rw/Kconfig |    3 +-
 net/Kconfig                           |   11 ++-
 net/Makefile                          |    2 +
 net/ieee80211/Kconfig                 |    3 +-
 net/wireless/Kconfig                  |   23 ++++++
 net/wireless/Makefile                 |    1 +
 10 files changed, 92 insertions(+), 79 deletions(-)
 create mode 100644 net/wireless/Kconfig
 create mode 100644 net/wireless/Makefile

diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 33af833..5852732 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -206,7 +206,7 @@ obj-$(CONFIG_TR) += tokenring/
 obj-$(CONFIG_WAN) += wan/
 obj-$(CONFIG_ARCNET) += arcnet/
 obj-$(CONFIG_NET_PCMCIA) += pcmcia/
-obj-$(CONFIG_NET_RADIO) += wireless/
+obj-y += wireless/
 obj-$(CONFIG_NET_TULIP) += tulip/
 obj-$(CONFIG_HAMRADIO) += hamradio/
 obj-$(CONFIG_IRDA) += irda/
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index ece3d9c..880c628 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -2,47 +2,21 @@
 # Wireless LAN device configuration
 #
 
-menu "Wireless LAN (non-hamradio)"
-	depends on NETDEVICES
-
-config NET_RADIO
-	bool "Wireless LAN drivers (non-hamradio) & Wireless Extensions"
-	select WIRELESS_EXT
-	---help---
-	  Support for wireless LANs and everything having to do with radio,
-	  but not with amateur radio or FM broadcasting.
-
-	  Saying Y here also enables the Wireless Extensions (creates
-	  /proc/net/wireless and enables iwconfig access). The Wireless
-	  Extension is a generic API allowing a driver to expose to the user
-	  space configuration and statistics specific to common Wireless LANs.
-	  The beauty of it is that a single set of tool can support all the
-	  variations of Wireless LANs, regardless of their type (as long as
-	  the driver supports Wireless Extension). Another advantage is that
-	  these parameters may be changed on the fly without restarting the
-	  driver (or Linux). If you wish to use Wireless Extensions with
-	  wireless PCMCIA (PC-) cards, you need to say Y here; you can fetch
-	  the tools from
-	  <http://www.hpl.hp.com/personal/Jean_Tourrilhes/Linux/Tools.html>.
+menu "Wireless LAN"
 
-config NET_WIRELESS_RTNETLINK
-	bool "Wireless Extension API over RtNetlink"
-	depends on NET_RADIO
+config WLAN_PRE80211
+	bool "Wireless LAN (pre-802.11)"
+	depends on NETDEVICES
 	---help---
-	  Support the Wireless Extension API over the RtNetlink socket
-	  in addition to the traditional ioctl interface (selected above).
+	  Say Y if you have any pre-802.11 wireless LAN hardware.
 
-	  For now, few tools use this facility, but it might grow in the
-	  future. The only downside is that it adds 4.5 kB to your kernel.
-
-# Note : the cards are obsolete (can't buy them anymore), but the drivers
-# are not, as people are still using them...
-comment "Obsolete Wireless cards support (pre-802.11)"
-	depends on NET_RADIO && (INET || ISA || PCMCIA)
+	  This option does not affect the kernel build, it only
+	  let's you choose drivers.
 
 config STRIP
 	tristate "STRIP (Metricom starmode radio IP)"
-	depends on NET_RADIO && INET
+	depends on INET && WLAN_PRE80211
+	select WIRELESS_EXT
 	---help---
 	  Say Y if you have a Metricom radio and intend to use Starmode Radio
 	  IP. STRIP is a radio protocol developed for the MosquitoNet project
@@ -65,7 +39,8 @@ config STRIP
 
 config ARLAN
 	tristate "Aironet Arlan 655 & IC2200 DS support"
-	depends on NET_RADIO && ISA && !64BIT
+	depends on ISA && !64BIT && WLAN_PRE80211
+	select WIRELESS_EXT
 	---help---
 	  Aironet makes Arlan, a class of wireless LAN adapters. These use the
 	  www.Telxon.com chip, which is also used on several similar cards.
@@ -80,7 +55,8 @@ config ARLAN
 
 config WAVELAN
 	tristate "AT&T/Lucent old WaveLAN & DEC RoamAbout DS ISA support"
-	depends on NET_RADIO && ISA
+	depends on ISA && WLAN_PRE80211
+	select WIRELESS_EXT
 	---help---
 	  The Lucent WaveLAN (formerly NCR and AT&T; or DEC RoamAbout DS) is
 	  a Radio LAN (wireless Ethernet-like Local Area Network) using the
@@ -107,7 +83,8 @@ config WAVELAN
 
 config PCMCIA_WAVELAN
 	tristate "AT&T/Lucent old WaveLAN Pcmcia wireless support"
-	depends on NET_RADIO && PCMCIA
+	depends on PCMCIA && WLAN_PRE80211
+	select WIRELESS_EXT
 	help
 	  Say Y here if you intend to attach an AT&T/Lucent Wavelan PCMCIA
 	  (PC-card) wireless Ethernet networking card to your computer.  This
@@ -118,7 +95,8 @@ config PCMCIA_WAVELAN
 
 config PCMCIA_NETWAVE
 	tristate "Xircom Netwave AirSurfer Pcmcia wireless support"
-	depends on NET_RADIO && PCMCIA
+	depends on PCMCIA && WLAN_PRE80211
+	select WIRELESS_EXT
 	help
 	  Say Y here if you intend to attach this type of PCMCIA (PC-card)
 	  wireless Ethernet networking card to your computer.
@@ -126,12 +104,20 @@ config PCMCIA_NETWAVE
 	  To compile this driver as a module, choose M here: the module will be
 	  called netwave_cs.  If unsure, say N.
 
-comment "Wireless 802.11 Frequency Hopping cards support"
-	depends on NET_RADIO && PCMCIA
+
+config WLAN_80211
+	bool "Wireless LAN (IEEE 802.11)"
+	depends on NETDEVICES
+	---help---
+	  Say Y if you have any 802.11 wireless LAN hardware.
+
+	  This option does not affect the kernel build, it only
+	  let's you choose drivers.
 
 config PCMCIA_RAYCS
 	tristate "Aviator/Raytheon 2.4MHz wireless support"
-	depends on NET_RADIO && PCMCIA
+	depends on PCMCIA && WLAN_80211
+	select WIRELESS_EXT
 	---help---
 	  Say Y here if you intend to attach an Aviator/Raytheon PCMCIA
 	  (PC-card) wireless Ethernet networking card to your computer.
@@ -141,12 +127,10 @@ config PCMCIA_RAYCS
 	  To compile this driver as a module, choose M here: the module will be
 	  called ray_cs.  If unsure, say N.
 
-comment "Wireless 802.11b ISA/PCI cards support"
-	depends on NET_RADIO && (ISA || PCI || PPC_PMAC || PCMCIA)
-
 config IPW2100
 	tristate "Intel PRO/Wireless 2100 Network Connection"
-	depends on NET_RADIO && PCI
+	depends on PCI && WLAN_80211
+	select WIRELESS_EXT
 	select FW_LOADER
 	select IEEE80211
 	---help---
@@ -200,7 +184,8 @@ config IPW2100_DEBUG
 
 config IPW2200
 	tristate "Intel PRO/Wireless 2200BG and 2915ABG Network Connection"
-	depends on NET_RADIO && PCI
+	depends on PCI && WLAN_80211
+	select WIRELESS_EXT
 	select FW_LOADER
 	select IEEE80211
 	---help---
@@ -282,7 +267,8 @@ config IPW2200_DEBUG
 
 config AIRO
 	tristate "Cisco/Aironet 34X/35X/4500/4800 ISA and PCI cards"
- 	depends on NET_RADIO && ISA_DMA_API && (PCI || BROKEN)
+	depends on ISA_DMA_API && WLAN_80211 && (PCI || BROKEN)
+	select WIRELESS_EXT
 	select CRYPTO
 	---help---
 	  This is the standard Linux driver to support Cisco/Aironet ISA and
@@ -299,7 +285,8 @@ config AIRO
 
 config HERMES
 	tristate "Hermes chipset 802.11b support (Orinoco/Prism2/Symbol)"
-	depends on NET_RADIO && (PPC_PMAC || PCI || PCMCIA)
+	depends on (PPC_PMAC || PCI || PCMCIA) && WLAN_80211
+	select WIRELESS_EXT
 	---help---
 	  A driver for 802.11b wireless cards based on the "Hermes" or
 	  Intersil HFA384x (Prism 2) MAC controller.  This includes the vast
@@ -373,7 +360,8 @@ config PCI_HERMES
 
 config ATMEL
       tristate "Atmel at76c50x chipset  802.11b support"
-      depends on NET_RADIO && (PCI || PCMCIA)
+      depends on (PCI || PCMCIA) && WLAN_80211
+      select WIRELESS_EXT
       select FW_LOADER
       select CRC32
        ---help---
@@ -394,13 +382,9 @@ config PCI_ATMEL
         Enable support for PCI and mini-PCI cards containing the
         Atmel at76c506 chip.
 
-# If Pcmcia is compiled in, offer Pcmcia cards...
-comment "Wireless 802.11b Pcmcia/Cardbus cards support"
-	depends on NET_RADIO && PCMCIA
-
 config PCMCIA_HERMES
 	tristate "Hermes PCMCIA card support"
-	depends on NET_RADIO && PCMCIA && HERMES
+	depends on PCMCIA && HERMES
 	---help---
 	  A driver for "Hermes" chipset based PCMCIA wireless adaptors, such
 	  as the Lucent WavelanIEEE/Orinoco cards and their OEM (Cabletron/
@@ -420,7 +404,7 @@ config PCMCIA_HERMES
 
 config PCMCIA_SPECTRUM
 	tristate "Symbol Spectrum24 Trilogy PCMCIA card support"
-	depends on NET_RADIO && PCMCIA && HERMES
+	depends on PCMCIA && HERMES
 	select FW_LOADER
 	---help---
 
@@ -434,7 +418,8 @@ config PCMCIA_SPECTRUM
 
 config AIRO_CS
 	tristate "Cisco/Aironet 34X/35X/4500/4800 PCMCIA cards"
-	depends on NET_RADIO && PCMCIA && (BROKEN || !M32R)
+	depends on PCMCIA && (BROKEN || !M32R) && WLAN_80211
+	select WIRELESS_EXT
 	select CRYPTO
 	select CRYPTO_AES
 	---help---
@@ -458,7 +443,8 @@ config AIRO_CS
 
 config PCMCIA_ATMEL
 	tristate "Atmel at76c502/at76c504 PCMCIA cards"
-	depends on NET_RADIO && ATMEL && PCMCIA
+	depends on ATMEL && PCMCIA
+	select WIRELESS_EXT
 	select FW_LOADER
 	select CRC32
 	---help---
@@ -467,17 +453,17 @@ config PCMCIA_ATMEL
 
 config PCMCIA_WL3501
       tristate "Planet WL3501 PCMCIA cards"
-      depends on NET_RADIO && EXPERIMENTAL && PCMCIA
+      depends on EXPERIMENTAL && PCMCIA && WLAN_80211
+      select WIRELESS_EXT
        ---help---
          A driver for WL3501 PCMCIA 802.11 wireless cards made by Planet.
 	 It has basic support for Linux wireless extensions and initial
 	 micro support for ethtool.
 
-comment "Prism GT/Duette 802.11(a/b/g) PCI/Cardbus support"
-	depends on NET_RADIO && PCI
 config PRISM54
 	tristate 'Intersil Prism GT/Duette/Indigo PCI/Cardbus' 
-	depends on PCI && NET_RADIO && EXPERIMENTAL
+	depends on PCI && EXPERIMENTAL && WLAN_80211
+	select WIRELESS_EXT
 	select FW_LOADER
 	---help---
 	  Enable PCI and Cardbus support for the following chipset based cards:
@@ -523,7 +509,8 @@ config PRISM54
 
 config USB_ZD1201
 	tristate "USB ZD1201 based Wireless device support"
-	depends on USB && NET_RADIO
+	depends on USB && WLAN_80211
+	select WIRELESS_EXT
 	select FW_LOADER
 	---help---
 	  Say Y if you want to use wireless LAN adapters based on the ZyDAS
@@ -542,11 +529,4 @@ source "drivers/net/wireless/hostap/Kconfig"
 source "drivers/net/wireless/bcm43xx/Kconfig"
 source "drivers/net/wireless/zd1211rw/Kconfig"
 
-# yes, this works even when no drivers are selected
-config NET_WIRELESS
-	bool
-	depends on NET_RADIO && (ISA || PCI || PPC_PMAC || PCMCIA)
-	default y
-
 endmenu
-
diff --git a/drivers/net/wireless/bcm43xx/Kconfig b/drivers/net/wireless/bcm43xx/Kconfig
index 533993f..ce397e4 100644
--- a/drivers/net/wireless/bcm43xx/Kconfig
+++ b/drivers/net/wireless/bcm43xx/Kconfig
@@ -1,6 +1,7 @@
 config BCM43XX
 	tristate "Broadcom BCM43xx wireless support"
-	depends on PCI && IEEE80211 && IEEE80211_SOFTMAC && NET_RADIO && EXPERIMENTAL
+	depends on PCI && IEEE80211 && IEEE80211_SOFTMAC && WLAN_80211 && EXPERIMENTAL
+	select WIRELESS_EXT
 	select FW_LOADER
 	select HW_RANDOM
 	---help---
diff --git a/drivers/net/wireless/hostap/Kconfig b/drivers/net/wireless/hostap/Kconfig
index 308f773..1fef331 100644
--- a/drivers/net/wireless/hostap/Kconfig
+++ b/drivers/net/wireless/hostap/Kconfig
@@ -1,6 +1,7 @@
 config HOSTAP
 	tristate "IEEE 802.11 for Host AP (Prism2/2.5/3 and WEP/TKIP/CCMP)"
-	depends on NET_RADIO
+	depends on WLAN_80211
+	select WIRELESS_EXT
 	select IEEE80211
 	select IEEE80211_CRYPT_WEP
 	---help---
diff --git a/drivers/net/wireless/zd1211rw/Kconfig b/drivers/net/wireless/zd1211rw/Kconfig
index 66ed55b..d1ab24a 100644
--- a/drivers/net/wireless/zd1211rw/Kconfig
+++ b/drivers/net/wireless/zd1211rw/Kconfig
@@ -1,6 +1,7 @@
 config ZD1211RW
 	tristate "ZyDAS ZD1211/ZD1211B USB-wireless support"
-	depends on USB && IEEE80211 && IEEE80211_SOFTMAC && NET_RADIO && EXPERIMENTAL
+	depends on USB && IEEE80211_SOFTMAC && WLAN_80211 && EXPERIMENTAL
+	select WIRELESS_EXT
 	select FW_LOADER
 	---help---
 	  This is an experimental driver for the ZyDAS ZD1211/ZD1211B wireless
diff --git a/net/Kconfig b/net/Kconfig
index e2d9b3b..ae1817d 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -212,14 +212,17 @@ endmenu
 source "net/ax25/Kconfig"
 source "net/irda/Kconfig"
 source "net/bluetooth/Kconfig"
-source "net/ieee80211/Kconfig"
-
-config WIRELESS_EXT
-	bool
 
 config FIB_RULES
 	bool
 
+menu "Wireless"
+
+source "net/wireless/Kconfig"
+source "net/ieee80211/Kconfig"
+
+endmenu
+
 endif   # if NET
 endmenu # Networking
 
diff --git a/net/Makefile b/net/Makefile
index 4854ac5..29bbe19 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -52,3 +52,5 @@ obj-$(CONFIG_IUCV)		+= iucv/
 ifeq ($(CONFIG_NET),y)
 obj-$(CONFIG_SYSCTL)		+= sysctl_net.o
 endif
+
+obj-y				+= wireless/
diff --git a/net/ieee80211/Kconfig b/net/ieee80211/Kconfig
index 6ef766e..1438ade 100644
--- a/net/ieee80211/Kconfig
+++ b/net/ieee80211/Kconfig
@@ -56,7 +56,8 @@ config IEEE80211_CRYPT_CCMP
 
 config IEEE80211_CRYPT_TKIP
 	tristate "IEEE 802.11i TKIP encryption"
-	depends on IEEE80211 && NET_RADIO
+	depends on IEEE80211
+	select WIRELESS_EXT
 	select CRYPTO
 	select CRYPTO_MICHAEL_MIC
 	select CRYPTO_ECB
diff --git a/net/wireless/Kconfig b/net/wireless/Kconfig
new file mode 100644
index 0000000..ca2f05c
--- /dev/null
+++ b/net/wireless/Kconfig
@@ -0,0 +1,23 @@
+config WIRELESS_EXT
+	bool "Wireless extensions"
+	default n
+	---help---
+	  This option enables the legacy wireless extensions
+	  (wireless network interface configuration via ioctls.)
+
+	  Wireless extensions will be replaced by cfg80211 and
+	  will be required only by legacy drivers that implement
+	  wireless extension handlers.
+
+	  Say N (if you can) unless you know you need wireless
+	  extensions for external modules.
+
+config NET_WIRELESS_RTNETLINK
+	bool "Wireless Extension API over RtNetlink"
+	depends on WIRELESS_EXT
+	---help---
+	  Support the Wireless Extension API over the RtNetlink socket
+	  in addition to the traditional ioctl interface (selected above).
+
+	  For now, few tools use this facility, but it might grow in the
+	  future. The only downside is that it adds 4.5 kB to your kernel.
diff --git a/net/wireless/Makefile b/net/wireless/Makefile
new file mode 100644
index 0000000..cf4e3d9
--- /dev/null
+++ b/net/wireless/Makefile
@@ -0,0 +1 @@
+# dummy file for now
-- 
1.5.0.6

-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
