From: <shh.xie@gmail.com>
Subject: [PATCH] phylib: add driver for aquantia phy
Date: Fri, 24 Jul 2015 11:46:45 +0800
Message-ID: <1437709605-42980-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shaohui Xie <Shaohui.Xie@freescale.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0095.outbound.protection.outlook.com ([207.46.100.95]:9280
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754135AbbGXDvn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2015 23:51:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohui Xie <Shaohui.Xie@freescale.com>

This patch added driver to support Aquantia PHYs AQ1202, AQ2104, AQR105,
AQR405, which accessed through clause 45.

Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
---
 drivers/net/phy/Kconfig    |   5 ++
 drivers/net/phy/Makefile   |   1 +
 drivers/net/phy/aquantia.c | 157 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 163 insertions(+)
 create mode 100644 drivers/net/phy/aquantia.c

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index d6aff87..839b84c 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -14,6 +14,11 @@ if PHYLIB
 
 comment "MII PHY device drivers"
 
+config AQUANTIA_PHY
+        tristate "Drivers for the Aquantia PHYs"
+        ---help---
+          Currently supports the Aquantia AQ1202, AQ2104, AQR105, AQR405
+
 config AT803X_PHY
 	tristate "Drivers for Atheros AT803X PHYs"
 	---help---
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 16aac1c..9bb1033 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -3,6 +3,7 @@
 libphy-objs			:= phy.o phy_device.o mdio_bus.o
 
 obj-$(CONFIG_PHYLIB)		+= libphy.o
+obj-$(CONFIG_AQUANTIA_PHY)	+= aquantia.o
 obj-$(CONFIG_MARVELL_PHY)	+= marvell.o
 obj-$(CONFIG_DAVICOM_PHY)	+= davicom.o
 obj-$(CONFIG_CICADA_PHY)	+= cicada.o
diff --git a/drivers/net/phy/aquantia.c b/drivers/net/phy/aquantia.c
new file mode 100644
index 0000000..cb848f95
--- /dev/null
+++ b/drivers/net/phy/aquantia.c
@@ -0,0 +1,157 @@
+/*
+ * Driver for Aquantia PHY
+ *
+ * Author: Shaohui Xie <Shaohui.Xie@freescale.com>
+ *
+ * Copyright 2015 Freescale Semiconductor, Inc.
+ *
+ * This file is licensed under the terms of the GNU General Public License
+ * version 2.  This program is licensed "as is" without any warranty of any
+ * kind, whether express or implied.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/delay.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/phy.h>
+#include <linux/mdio.h>
+
+#define PHY_ID_AQ1202	0x03a1b445
+#define PHY_ID_AQ2104	0x03a1b460
+#define PHY_ID_AQR105	0x03a1b4a2
+#define PHY_ID_AQR405	0x03a1b4b0
+
+static int aquantia_soft_reset(struct phy_device *phydev)
+{
+	return 0;
+}
+
+static int aquantia_config_init(struct phy_device *phydev)
+{
+	return 0;
+}
+
+static int aquantia_config_aneg(struct phy_device *phydev)
+{
+	phydev->supported = SUPPORTED_10000baseT_Full | PHY_GBIT_FEATURES;
+	phydev->advertising = phydev->supported;
+
+	return 0;
+}
+
+static int aquantia_aneg_done(struct phy_device *phydev)
+{
+	int reg;
+
+	reg = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_STAT1);
+	return (reg < 0) ? reg : (reg & BMSR_ANEGCOMPLETE);
+}
+
+static int aquantia_read_status(struct phy_device *phydev)
+{
+	int reg;
+
+	phydev->speed = SPEED_10000;
+	phydev->duplex = DUPLEX_FULL;
+
+	reg = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_STAT1);
+	reg = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_STAT1);
+	if (reg & MDIO_STAT1_LSTATUS)
+		phydev->link = 1;
+	else
+		phydev->link = 0;
+
+	reg = phy_read_mmd(phydev, MDIO_MMD_AN, 0xc800);
+	mdelay(10);
+	reg = phy_read_mmd(phydev, MDIO_MMD_AN, 0xc800);
+	if (reg == 0x9)
+		phydev->speed = SPEED_2500;
+	else if (reg == 0x5)
+		phydev->speed = SPEED_1000;
+	else if (reg == 0x3)
+		phydev->speed = SPEED_100;
+
+	return 0;
+}
+
+static struct phy_driver aquantia_driver[] = {
+{
+	.phy_id		= PHY_ID_AQ1202,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "Aquantia AQ1202",
+	.features	= PHY_GBIT_FEATURES,
+	.soft_reset	= aquantia_soft_reset,
+	.aneg_done	= aquantia_aneg_done,
+	.config_init    = aquantia_config_init,
+	.config_aneg    = aquantia_config_aneg,
+	.read_status	= aquantia_read_status,
+	.driver		= { .owner = THIS_MODULE,},
+},
+{
+	.phy_id		= PHY_ID_AQ2104,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "Aquantia AQ2104",
+	.features	= PHY_GBIT_FEATURES,
+	.soft_reset	= aquantia_soft_reset,
+	.aneg_done	= aquantia_aneg_done,
+	.config_init    = aquantia_config_init,
+	.config_aneg    = aquantia_config_aneg,
+	.read_status	= aquantia_read_status,
+	.driver		= { .owner = THIS_MODULE,},
+},
+{
+	.phy_id		= PHY_ID_AQR105,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "Aquantia AQR105",
+	.features	= PHY_GBIT_FEATURES,
+	.soft_reset	= aquantia_soft_reset,
+	.aneg_done	= aquantia_aneg_done,
+	.config_init    = aquantia_config_init,
+	.config_aneg    = aquantia_config_aneg,
+	.read_status	= aquantia_read_status,
+	.driver		= { .owner = THIS_MODULE,},
+},
+{
+	.phy_id		= PHY_ID_AQR405,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "Aquantia AQR405",
+	.features	= PHY_GBIT_FEATURES,
+	.soft_reset	= aquantia_soft_reset,
+	.aneg_done	= aquantia_aneg_done,
+	.config_init    = aquantia_config_init,
+	.config_aneg    = aquantia_config_aneg,
+	.read_status	= aquantia_read_status,
+	.driver		= { .owner = THIS_MODULE,},
+},
+};
+
+static int __init aquantia_init(void)
+{
+	return phy_drivers_register(aquantia_driver,
+				    ARRAY_SIZE(aquantia_driver));
+}
+
+static void __exit aquantia_exit(void)
+{
+	return phy_drivers_unregister(aquantia_driver,
+				      ARRAY_SIZE(aquantia_driver));
+}
+
+module_init(aquantia_init);
+module_exit(aquantia_exit);
+
+static struct mdio_device_id __maybe_unused aquantia_tbl[] = {
+	{ PHY_ID_AQ1202, 0xfffffff0 },
+	{ PHY_ID_AQ2104, 0xfffffff0 },
+	{ PHY_ID_AQR105, 0xfffffff0 },
+	{ PHY_ID_AQR405, 0xfffffff0 },
+	{ }
+};
+
+MODULE_DEVICE_TABLE(mdio, aquantia_tbl);
+
+MODULE_DESCRIPTION("Aquantia PHY driver");
+MODULE_AUTHOR("Shaohui Xie <Shaohui.Xie@freescale.com>");
+MODULE_LICENSE("GPL v2");
-- 
2.1.0.27.g96db324
