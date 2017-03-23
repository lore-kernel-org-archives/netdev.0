From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 3/3] net: phy: Allow splitting MDIO bus/device support from PHYs
Date: Thu, 23 Mar 2017 10:01:19 -0700
Message-ID: <20170323170119.4004-4-f.fainelli@gmail.com>
References: <20170323170119.4004-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, rmk+kernel@armlinux.org.uk,
        arnd@arndb.de, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:36237 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755874AbdCWRBa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 13:01:30 -0400
Received: by mail-oi0-f67.google.com with SMTP id l203so4572101oia.3
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 10:01:29 -0700 (PDT)
In-Reply-To: <20170323170119.4004-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce a new configuration symbol: MDIO_DEVICE which allows building
the MDIO devices and bus code, without pulling in the entire Ethernet
PHY library and devices code.

PHYLIB nows select MDIO_DEVICE and the relevant Makefile files are
updated to reflect that.

When MDIO_DEVICE (MDIO bus/device only) is selected, but not PHYLIB, we
have mdio-bus.ko as a loadable module, and it does not have a
module_exit() function because the safety of removing a bus class is
unclear.

When both MDIO_DEVICE and PHYLIB are enabled, we need to assemble
everything into a common loadable module: libphy.ko because of nasty
circular dependencies between phy.c, phy_device.c and mdio_bus.c which
are really tough to untangle.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/Makefile             |  2 +-
 drivers/net/phy/Kconfig          | 60 +++++++++++++++++++++++-----------------
 drivers/net/phy/Makefile         | 13 +++++++--
 drivers/net/phy/mdio-boardinfo.c |  1 +
 drivers/net/phy/mdio_bus.c       |  9 ++++++
 include/linux/phy.h              | 21 ++++++++++++--
 6 files changed, 76 insertions(+), 30 deletions(-)

diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 98ed4d96987c..55f75aea283c 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -18,7 +18,7 @@ obj-$(CONFIG_MII) += mii.o
 obj-$(CONFIG_MDIO) += mdio.o
 obj-$(CONFIG_NET) += Space.o loopback.o
 obj-$(CONFIG_NETCONSOLE) += netconsole.o
-obj-$(CONFIG_PHYLIB) += phy/
+obj-$(CONFIG_MDIO_DEVICE) += phy/
 obj-$(CONFIG_RIONET) += rionet.o
 obj-$(CONFIG_NET_TEAM) += team/
 obj-$(CONFIG_TUN) += tun.o
diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 7ab4b14a43b7..60ffc9da6a28 100644
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
@@ -49,6 +28,7 @@ config MDIO_BCM_UNIMAC
 
 config MDIO_BITBANG
 	tristate "Bitbanged MDIO buses"
+	depends on !(MDIO_DEVICE=y && PHYLIB=m)
 	help
 	  This module implements the MDIO bus protocol in software,
 	  for use by low level drivers that export the ability to
@@ -160,6 +140,36 @@ config MDIO_XGENE
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
index 82d915614646..0e1ec0438c23 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -1,7 +1,16 @@
 # Makefile for Linux PHY drivers and MDIO bus drivers
 
-libphy-y			:= phy.o phy_device.o mdio_bus.o mdio_device.o \
-				   mdio-boardinfo.o phy-core.o
+libphy-y			:= phy.o phy-core.o phy_device.o
+mdio-bus-y			+= mdio_bus.o mdio_device.o mdio-boardinfo.o
+
+# PHYLIB implies MDIO_DEVICE, in that case, we have a bunch of circular
+# dependencies that does not make it possible to split mdio-bus objects into a
+# dedicated loadable module, so we bundle them all together into libphy.ko
+ifdef CONFIG_PHYLIB
+libphy-y			+= $(mdio-bus-y)
+else
+obj-$(CONFIG_MDIO_DEVICE)	+= mdio-bus.o
+endif
 libphy-$(CONFIG_SWPHY)		+= swphy.o
 libphy-$(CONFIG_LED_TRIGGER_PHY)	+= phy_led_triggers.o
 
diff --git a/drivers/net/phy/mdio-boardinfo.c b/drivers/net/phy/mdio-boardinfo.c
index 6b988f77da08..61941e29daae 100644
--- a/drivers/net/phy/mdio-boardinfo.c
+++ b/drivers/net/phy/mdio-boardinfo.c
@@ -84,3 +84,4 @@ int mdiobus_register_board_info(const struct mdio_board_info *info,
 
 	return 0;
 }
+EXPORT_SYMBOL(mdiobus_register_board_info);
diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index fa7d51f14869..46b468eb6e12 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -648,9 +648,18 @@ int __init mdio_bus_init(void)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mdio_bus_init);
 
+#if IS_ENABLED(CONFIG_PHYLIB)
 void mdio_bus_exit(void)
 {
 	class_unregister(&mdio_bus_class);
 	bus_unregister(&mdio_bus_type);
 }
+EXPORT_SYMBOL_GPL(mdio_bus_exit);
+#else
+module_init(mdio_bus_init);
+/* no module_exit, intentional */
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("MDIO bus/device layer");
+#endif
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 2efca6b39fba..624cecf69c28 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -745,8 +745,24 @@ int phy_write_mmd(struct phy_device *phydev, int devad, u32 regnum, u16 val);
 struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
 				     bool is_c45,
 				     struct phy_c45_device_ids *c45_ids);
+#if IS_ENABLED(CONFIG_PHYLIB)
 struct phy_device *get_phy_device(struct mii_bus *bus, int addr, bool is_c45);
 int phy_device_register(struct phy_device *phy);
+void phy_device_free(struct phy_device *phydev);
+#else
+static inline
+struct phy_device *get_phy_device(struct mii_bus *bus, int addr, bool is_c45)
+{
+	return NULL;
+}
+
+static inline int phy_device_register(struct phy_device *phy)
+{
+	return 0;
+}
+
+static inline void phy_device_free(struct phy_device *phydev) { }
+#endif /* CONFIG_PHYLIB */
 void phy_device_remove(struct phy_device *phydev);
 int phy_init_hw(struct phy_device *phydev);
 int phy_suspend(struct phy_device *phydev);
@@ -827,7 +843,6 @@ int phy_ethtool_ksettings_set(struct phy_device *phydev,
 int phy_mii_ioctl(struct phy_device *phydev, struct ifreq *ifr, int cmd);
 int phy_start_interrupts(struct phy_device *phydev);
 void phy_print_status(struct phy_device *phydev);
-void phy_device_free(struct phy_device *phydev);
 int phy_set_max_speed(struct phy_device *phydev, u32 max_speed);
 
 int phy_register_fixup(const char *bus_id, u32 phy_uid, u32 phy_uid_mask,
@@ -854,8 +869,10 @@ int phy_ethtool_set_link_ksettings(struct net_device *ndev,
 				   const struct ethtool_link_ksettings *cmd);
 int phy_ethtool_nway_reset(struct net_device *ndev);
 
+#if IS_ENABLED(CONFIG_PHYLIB)
 int __init mdio_bus_init(void);
 void mdio_bus_exit(void);
+#endif
 
 extern struct bus_type mdio_bus_type;
 
@@ -866,7 +883,7 @@ struct mdio_board_info {
 	const void	*platform_data;
 };
 
-#if IS_ENABLED(CONFIG_PHYLIB)
+#if IS_ENABLED(CONFIG_MDIO_DEVICE)
 int mdiobus_register_board_info(const struct mdio_board_info *info,
 				unsigned int n);
 #else
-- 
2.9.3
