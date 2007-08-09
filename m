From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] Fix the SSB dependency hell
Date: Thu, 9 Aug 2007 15:04:37 +0200
Message-ID: <200708091504.38029.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: John Linville <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:42658
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932067AbXHINFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 09:05:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes the SSB dependency hell and introduces some
fake-options that only give some advice on what to select.

We live with these fake options only until menuconfig is able
to tell more about needed dependencies and how to resolve them.

Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: wireless-dev/drivers/net/Kconfig
===================================================================
--- wireless-dev.orig/drivers/net/Kconfig	2007-08-09 14:47:01.000000000 +0200
+++ wireless-dev/drivers/net/Kconfig	2007-08-09 14:47:40.000000000 +0200
@@ -1452,10 +1452,31 @@ config APRICOT
 	  <file:Documentation/networking/net-modules.txt>.  The module will be
 	  called apricot.
 
+config B44_DEP_HACK
+	bool
+	depends on SSB && SSB_PCIHOST && SSB_DRIVER_PCICORE
+	default y
+
+config B44_ADVICE_HACK
+	bool "B44 for PCI not available. Read the help text of this option!"
+	depends on !B44_DEP_HACK
+	---help---
+	  The Broadcom 440x/47xx driver for PCI devices can not be enabled,
+	  because the required dependencies are not selected.
+
+	  In order to be able to select the Broadcom 440x/47xx PCI driver, you
+	  need to enable the following options first:
+
+	  CONFIG_SSB found in menu:
+	  Device Drivers/Sonics Silicon Backplane/Sonics Silicon Backplane support
+	  CONFIG_SSB_PCIHOST found in menu:
+	  Device Drivers/Sonics Silicon Backplane/Support for SSB on PCI-bus host
+	  CONFIG_SSB_DRIVER_PCICORE found in menu:
+	  Device Drivers/Sonics Silicon Backplane/SSB PCI core driver
+
 config B44
 	tristate "Broadcom 440x/47xx ethernet support"
-	depends on HAS_IOMEM
-	select SSB
+	depends on SSB
 	select MII
 	help
 	  If you have a network (Ethernet) controller of this type, say Y
@@ -1473,9 +1494,7 @@ config B44
 
 config B44_PCI
 	bool "Broadcom 440x PCI device support"
-	depends on B44 && NET_PCI
-	select SSB_PCIHOST
-	select SSB_DRIVER_PCICORE
+	depends on B44 && SSB_PCIHOST && SSB_DRIVER_PCICORE && NET_PCI
 	default y
 	help
 	  Support for Broadcom 440x PCI devices.
Index: wireless-dev/drivers/net/wireless/bcm43xx-mac80211/Kconfig
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx-mac80211/Kconfig	2007-08-09 14:47:01.000000000 +0200
+++ wireless-dev/drivers/net/wireless/bcm43xx-mac80211/Kconfig	2007-08-09 14:59:39.000000000 +0200
@@ -1,8 +1,29 @@
+config BCM43XX_DEP_HACK
+	bool
+	depends on SSB && SSB_PCIHOST && SSB_DRIVER_PCICORE
+	default y
+
+config BCM43XX_ADVICE_HACK
+	bool "BCM43xx PCI (mac80211) not available. Read the help text of this option!"
+	depends on !BCM43XX_DEP_HACK
+	---help---
+	  The BCM43xx driver for BCM43xx PCI devices can not be enabled,
+	  because the required dependencies are not selected.
+
+	  In order to be able to select the BCM43xx-mac80211 driver, you
+	  need to enable the following options first:
+
+	  CONFIG_SSB found in menu:
+	  Device Drivers/Sonics Silicon Backplane/Sonics Silicon Backplane support
+	  CONFIG_SSB_PCIHOST found in menu:
+	  Device Drivers/Sonics Silicon Backplane/Support for SSB on PCI-bus host
+	  CONFIG_SSB_DRIVER_PCICORE found in menu:
+	  Device Drivers/Sonics Silicon Backplane/SSB PCI core driver
+
 config BCM43XX_MAC80211
 	tristate "Broadcom BCM43xx wireless support (mac80211 stack)"
-	depends on MAC80211 && WLAN_80211 && EXPERIMENTAL
+	depends on SSB && MAC80211 && WLAN_80211 && EXPERIMENTAL
 	select FW_LOADER
-	select SSB
 	select HW_RANDOM
 	---help---
 	  This is an experimental driver for the Broadcom 43xx wireless chip,
@@ -10,9 +31,7 @@ config BCM43XX_MAC80211
 
 config BCM43XX_MAC80211_PCI
 	bool "BCM43xx PCI device support"
-	depends on BCM43XX_MAC80211 && PCI
-	select SSB_PCIHOST
-	select SSB_DRIVER_PCICORE
+	depends on BCM43XX_MAC80211 && SSB_PCIHOST && SSB_DRIVER_PCICORE
 	default y
 	---help---
 	  Broadcom 43xx PCI device support.
@@ -24,8 +43,7 @@ config BCM43XX_MAC80211_PCI
 
 config BCM43XX_MAC80211_PCMCIA
 	bool "BCM43xx PCMCIA device support"
-	depends on BCM43XX_MAC80211 && PCMCIA
-	select SSB_PCMCIAHOST
+	depends on BCM43XX_MAC80211 && SSB_PCMCIAHOST
 	---help---
 	  Broadcom 43xx PCMCIA device support.
 
@@ -43,14 +61,13 @@ config BCM43XX_MAC80211_PCMCIA
 	  If unsure, say N.
 
 config BCM43XX_MAC80211_DEBUG
-	bool "Broadcom BCM43xx debugging (RECOMMENDED)"
+	bool "Broadcom BCM43xx debugging"
 	depends on BCM43XX_MAC80211
-	select SSB_DEBUG if !SSB_SILENT
-	default y
 	---help---
 	  Broadcom 43xx debugging messages.
-	  Say Y, because the driver is still very experimental and
-	  this will help you get it running.
+
+	  Say Y, if you want to find out why the driver does not
+	  work for you.
 
 config BCM43XX_MAC80211_DMA
 	bool
Index: wireless-dev/drivers/ssb/Kconfig
===================================================================
--- wireless-dev.orig/drivers/ssb/Kconfig	2007-08-09 14:47:01.000000000 +0200
+++ wireless-dev/drivers/ssb/Kconfig	2007-08-09 14:51:09.000000000 +0200
@@ -2,7 +2,7 @@ menu "Sonics Silicon Backplane"
 
 config SSB
 	tristate "Sonics Silicon Backplane support"
-	depends on EXPERIMENTAL && HAS_IOMEM
+	depends on HAS_IOMEM
 	help
 	  Support for the Sonics Silicon Backplane bus
 
@@ -21,8 +21,8 @@ config SSB_PCIHOST
 	  If unsure, say Y
 
 config SSB_PCMCIAHOST
-	bool "Support for SSB on PCMCIA-bus host"
-	depends on SSB && PCMCIA
+	bool "Support for SSB on PCMCIA-bus host (EXPERIMENTAL)"
+	depends on SSB && PCMCIA && EXPERIMENTAL
 	help
 	  Support for a Sonics Silicon Backplane on top
 	  of a PCMCIA device.
@@ -65,14 +65,14 @@ config SSB_DRIVER_PCICORE
 	  If unsure, say Y
 
 config SSB_PCICORE_HOSTMODE
-	bool "Hostmode support for SSB PCI core"
-	depends on SSB_DRIVER_PCICORE && SSB_DRIVER_MIPS
+	bool "Hostmode support for SSB PCI core (EXPERIMENTAL)"
+	depends on SSB_DRIVER_PCICORE && SSB_DRIVER_MIPS && EXPERIMENTAL
 	help
 	  PCIcore hostmode operation (external PCI bus).
 
 config SSB_DRIVER_MIPS
-	bool "SSB Broadcom MIPS core driver"
-	depends on SSB && MIPS
+	bool "SSB Broadcom MIPS core driver (EXPERIMENTAL)"
+	depends on SSB && MIPS && EXPERIMENTAL
 	select SSB_SERIAL
 	help
 	  Driver for the Sonics Silicon Backplane attached
@@ -81,8 +81,8 @@ config SSB_DRIVER_MIPS
 	  If unsure, say N
 
 config SSB_DRIVER_EXTIF
-	bool "SSB Broadcom EXTIF core driver"
-	depends on SSB_DRIVER_MIPS
+	bool "SSB Broadcom EXTIF core driver (EXPERIMENTAL)"
+	depends on SSB_DRIVER_MIPS && EXPERIMENTAL
 	help
 	  Driver for the Sonics Silicon Backplane attached
 	  Broadcom EXTIF core.
