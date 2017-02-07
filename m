From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: phy: Allow splitting MDIO bus/device support from PHYs
Date: Mon,  6 Feb 2017 16:11:12 -0800
Message-ID: <20170207001112.1282-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, rmk+kernel@armlinux.org.uk,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33212 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751414AbdBGALR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 19:11:17 -0500
Received: by mail-pg0-f67.google.com with SMTP id 194so10352658pgd.0
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 16:11:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce a new configuration symbol: MDIO_DEVICE which allows building
the MDIO devices and bus code, without pulling in the entire Ethernet
PHY library and devices code.

PHYLIB nows select MDIO_DEVICE and the relevant Makefile files are
updated to reflect that.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/Makefile       |  2 +-
 drivers/net/phy/Kconfig    | 59 ++++++++++++++++++++++++++--------------------
 drivers/net/phy/Makefile   |  3 ++-
 drivers/net/phy/mdio_bus.c |  2 ++
 4 files changed, 39 insertions(+), 27 deletions(-)

diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 7336cbd3ef5d..a701e390d48f 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -17,7 +17,7 @@ obj-$(CONFIG_MII) += mii.o
 obj-$(CONFIG_MDIO) += mdio.o
 obj-$(CONFIG_NET) += Space.o loopback.o
 obj-$(CONFIG_NETCONSOLE) += netconsole.o
-obj-$(CONFIG_PHYLIB) += phy/
+obj-$(CONFIG_MDIO_DEVICE) += phy/
 obj-$(CONFIG_RIONET) += rionet.o
 obj-$(CONFIG_NET_TEAM) += team/
 obj-$(CONFIG_TUN) += tun.o
diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 8dbd59baa34d..01152fb9cb76 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -2,33 +2,12 @@
 # PHY Layer Configuration
 #
 
-menuconfig PHYLIB
-	tristate "PHY Device support and infrastructure"
-	depends on NETDEVICES
+menuconfig MDIO_DEVICE
+	tristate "MDIO bus device drivers"
 	help
-	  Ethernet controllers are usually attached to PHY
-	  devices.  This option provides infrastructure for
-	  managing PHY devices.
-
-if PHYLIB
-
-config SWPHY
-	bool
-
-config LED_TRIGGER_PHY
-	bool "Support LED triggers for tracking link state"
-	depends on LEDS_TRIGGERS
-	---help---
-	  Adds support for a set of LED trigger events per-PHY.  Link
-	  state change will trigger the events, for consumption by an
-	  LED class driver.  There are triggers for each link speed currently
-	  supported by the phy, and are of the form:
-	       <mii bus id>:<phy>:<speed>
-
-	  Where speed is in the form:
-		<Speed in megabits>Mbps or <Speed in gigabits>Gbps
+	   MDIO devices and driver infrastructure code.
 
-comment "MDIO bus device drivers"
+if MDIO_DEVICE
 
 config MDIO_BCM_IPROC
 	tristate "Broadcom iProc MDIO bus controller"
@@ -160,6 +139,36 @@ config MDIO_XGENE
 	  This module provides a driver for the MDIO busses found in the
 	  APM X-Gene SoC's.
 
+endif
+
+menuconfig PHYLIB
+	tristate "PHY Device support and infrastructure"
+	depends on NETDEVICES
+	select MDIO_DEVICE
+	help
+	  Ethernet controllers are usually attached to PHY
+	  devices.  This option provides infrastructure for
+	  managing PHY devices.
+
+if PHYLIB
+
+config SWPHY
+	bool
+
+config LED_TRIGGER_PHY
+	bool "Support LED triggers for tracking link state"
+	depends on LEDS_TRIGGERS
+	---help---
+	  Adds support for a set of LED trigger events per-PHY.  Link
+	  state change will trigger the events, for consumption by an
+	  LED class driver.  There are triggers for each link speed currently
+	  supported by the phy, and are of the form:
+	       <mii bus id>:<phy>:<speed>
+
+	  Where speed is in the form:
+		<Speed in megabits>Mbps or <Speed in gigabits>Gbps
+
+
 comment "MII PHY device drivers"
 
 config AMD_PHY
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 356859ac7c18..441d228f53ed 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -1,6 +1,7 @@
 # Makefile for Linux PHY drivers and MDIO bus drivers
 
-libphy-y			:= phy.o phy_device.o mdio_bus.o mdio_device.o
+libphy-y			:= phy.o phy_device.o
+obj-$(CONFIG_MDIO_DEVICE)	+= mdio_device.o mdio_bus.o
 libphy-$(CONFIG_SWPHY)		+= swphy.o
 libphy-$(CONFIG_LED_TRIGGER_PHY)	+= phy_led_triggers.o
 
diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 653d076eafe5..fa6bd2a2ce3e 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -644,9 +644,11 @@ int __init mdio_bus_init(void)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mdio_bus_init);
 
 void mdio_bus_exit(void)
 {
 	class_unregister(&mdio_bus_class);
 	bus_unregister(&mdio_bus_type);
 }
+EXPORT_SYMBOL_GPL(mdio_bus_exit);
-- 
2.9.3
