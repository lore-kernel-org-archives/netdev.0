From: chaithrika@ti.com
Subject: [PATCH] phy: Add LSI ET1011C PHY driver
Date: Tue,  9 Dec 2008 15:29:39 +0530
Message-ID: <1228816779-3683-1-git-send-email-chaithrika@ti.com>
Cc: davinci-linux-open-source@linux.davincidsp.com,
	Chaithrika U S <chaithrika@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:59442 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752099AbYLILHj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2008 06:07:39 -0500
Received: from dbdp31.itg.ti.com ([172.24.170.98])
	by bear.ext.ti.com (8.13.7/8.13.7) with ESMTP id mB9B7WcW019164
	for <netdev@vger.kernel.org>; Tue, 9 Dec 2008 05:07:38 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chaithrika U S <chaithrika@ti.com>

Adds LSI ET1011C PHY driver. 
This driver is used by TI DM646x EVM.

Signed-off-by: Chaithrika U S <chaithrika@ti.com>
---
 drivers/net/phy/Kconfig   |    5 ++
 drivers/net/phy/Makefile  |    1 +
 drivers/net/phy/et1011c.c |  113 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 119 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/phy/et1011c.c

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index d55932a..65dc771 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -66,6 +66,11 @@ config REALTEK_PHY
 	---help---
 	  Supports the Realtek 821x PHY.
 
+config LSI_ET1011C_PHY
+	tristate "Driver for LSI ET1011C PHY"
+	---help---
+	  Supports the LSI ET1011C PHY.
+
 config FIXED_PHY
 	bool "Driver for MDIO Bus/PHY emulation with fixed speed/link PHYs"
 	depends on PHYLIB=y
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index eee329f..ebafcfb 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -13,6 +13,7 @@ obj-$(CONFIG_VITESSE_PHY)	+= vitesse.o
 obj-$(CONFIG_BROADCOM_PHY)	+= broadcom.o
 obj-$(CONFIG_ICPLUS_PHY)	+= icplus.o
 obj-$(CONFIG_REALTEK_PHY)	+= realtek.o
+obj-$(CONFIG_LSI_ET1011C_PHY)	+= et1011c.o
 obj-$(CONFIG_FIXED_PHY)		+= fixed.o
 obj-$(CONFIG_MDIO_BITBANG)	+= mdio-bitbang.o
 obj-$(CONFIG_MDIO_OF_GPIO)	+= mdio-ofgpio.o
diff --git a/drivers/net/phy/et1011c.c b/drivers/net/phy/et1011c.c
new file mode 100644
index 0000000..b031fa2
--- /dev/null
+++ b/drivers/net/phy/et1011c.c
@@ -0,0 +1,113 @@
+/*
+ * drivers/net/phy/et1011c.c
+ *
+ * Driver for LSI ET1011C PHYs
+ *
+ * Author: Chaithrika U S
+ *
+ * Copyright (c) 2008 Texas Instruments
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+#include <linux/kernel.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/unistd.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/phy.h>
+#include <linux/io.h>
+#include <linux/uaccess.h>
+#include <asm/irq.h>
+
+#define ET1011C_STATUS_REG	(0x1A)
+#define ET1011C_CONFIG_REG	(0x16)
+#define ET1011C_SPEED_MASK		(0x0300)
+#define ET1011C_GIGABIT_SPEED		(0x0200)
+#define ET1011C_TX_FIFO_MASK		(0x3000)
+#define ET1011C_TX_FIFO_DEPTH_8		(0x0000)
+#define ET1011C_TX_FIFO_DEPTH_16	(0x1000)
+#define ET1011C_INTERFACE_MASK		(0x0007)
+#define ET1011C_GMII_INTERFACE		(0x0002)
+#define ET1011C_SYS_CLK_EN		(0x01 << 4)
+
+
+MODULE_DESCRIPTION("LSI ET1011C PHY driver");
+MODULE_AUTHOR("Chaithrika U S");
+MODULE_LICENSE("GPL");
+
+static int et1011c_config_aneg(struct phy_device *phydev)
+{
+	int ctl = 0;
+	ctl = phy_read(phydev, MII_BMCR);
+	if (ctl < 0)
+		return ctl;
+	ctl &= ~(BMCR_FULLDPLX | BMCR_SPEED100 | BMCR_SPEED1000 |
+		 BMCR_ANENABLE);
+	/* First clear the PHY */
+	phy_write(phydev, MII_BMCR, ctl | BMCR_RESET);
+
+	return genphy_config_aneg(phydev);
+}
+
+static int et1011c_read_status(struct phy_device *phydev)
+{
+	int ret;
+	u32 val;
+	static int speed;
+	ret = genphy_read_status(phydev);
+
+	if (speed != phydev->speed) {
+		speed = phydev->speed;
+		val = phy_read(phydev, ET1011C_STATUS_REG);
+		if ((val & ET1011C_SPEED_MASK) ==
+					ET1011C_GIGABIT_SPEED) {
+			val = phy_read(phydev, ET1011C_CONFIG_REG);
+			val &= ~ET1011C_TX_FIFO_MASK;
+			phy_write(phydev, ET1011C_CONFIG_REG, val\
+					| ET1011C_GMII_INTERFACE\
+					| ET1011C_SYS_CLK_EN\
+					| ET1011C_TX_FIFO_DEPTH_16);
+
+		}
+	}
+	return ret;
+}
+
+static struct phy_driver et1011c_driver = {
+	.phy_id		= 0x0282f014,
+	.name		= "ET1011C",
+	.phy_id_mask	= 0xfffffff0,
+	.features	= (PHY_BASIC_FEATURES | SUPPORTED_1000baseT_Full),
+	.flags		= PHY_POLL,
+	.config_aneg	= et1011c_config_aneg,
+	.read_status	= et1011c_read_status,
+	.driver 	= { .owner = THIS_MODULE,},
+};
+
+static int __init et1011c_init(void)
+{
+	return phy_driver_register(&et1011c_driver);
+}
+
+static void __exit et1011c_exit(void)
+{
+	phy_driver_unregister(&et1011c_driver);
+}
+
+module_init(et1011c_init);
+module_exit(et1011c_exit);
-- 
1.5.4.1

