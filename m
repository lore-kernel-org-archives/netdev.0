From: Anatolij Gustschin <agust@denx.de>
Subject: [PATCH v2 net-next] phy: add am79c874 PHY support
Date: Sun, 18 Mar 2012 22:03:05 +0100
Message-ID: <1332104585-23033-1-git-send-email-agust@denx.de>
Cc: Heiko Schocher <hs@denx.de>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:41529 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752471Ab2CRVDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2012 17:03:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiko Schocher <hs@denx.de>

Signed-off-by: Heiko Schocher <hs@denx.de>
Signed-off-by: Anatolij Gustschin <agust@denx.de>
---
Changes since initial patch version (was only on linuxppc-dev list):
 - slightly rework function names and rename driver file to amd.c
 - remove not needed includes
 - fix interrupt initialization
 - add module device ID table

 drivers/net/phy/Kconfig  |    5 ++
 drivers/net/phy/Makefile |    1 +
 drivers/net/phy/amd.c    |  102 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 108 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/phy/amd.c

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index fbdcdf8..0e01f4e 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -15,6 +15,11 @@ if PHYLIB
 
 comment "MII PHY device drivers"
 
+config AMD_PHY
+	tristate "Drivers for the AMD PHYs"
+	---help---
+	  Currently supports the am79c874
+
 config MARVELL_PHY
 	tristate "Drivers for Marvell PHYs"
 	---help---
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index e15c83f..b7438b1 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -24,3 +24,4 @@ obj-$(CONFIG_STE10XP)		+= ste10Xp.o
 obj-$(CONFIG_MICREL_PHY)	+= micrel.o
 obj-$(CONFIG_MDIO_OCTEON)	+= mdio-octeon.o
 obj-$(CONFIG_MICREL_KS8995MA)	+= spi_ks8995.o
+obj-$(CONFIG_AMD_PHY)		+= amd.o
diff --git a/drivers/net/phy/amd.c b/drivers/net/phy/amd.c
new file mode 100644
index 0000000..cfabd5f
--- /dev/null
+++ b/drivers/net/phy/amd.c
@@ -0,0 +1,102 @@
+/*
+ * Driver for AMD am79c PHYs
+ *
+ * Author: Heiko Schocher <hs@denx.de>
+ *
+ * Copyright (c) 2011 DENX Software Engineering GmbH
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/mii.h>
+#include <linux/phy.h>
+
+#define PHY_ID_AM79C874		0x0022561b
+
+#define MII_AM79C_IR		17	/* Interrupt Status/Control Register */
+#define MII_AM79C_IR_EN_LINK	0x0400	/* IR enable Linkstate */
+#define MII_AM79C_IR_EN_ANEG	0x0100	/* IR enable Aneg Complete */
+#define MII_AM79C_IR_IMASK_INIT	(MII_AM79C_IR_EN_LINK | MII_AM79C_IR_EN_ANEG)
+
+MODULE_DESCRIPTION("AMD PHY driver");
+MODULE_AUTHOR("Heiko Schocher <hs@denx.de>");
+MODULE_LICENSE("GPL");
+
+static int am79c_ack_interrupt(struct phy_device *phydev)
+{
+	int err;
+
+	err = phy_read(phydev, MII_BMSR);
+	if (err < 0)
+		return err;
+
+	err = phy_read(phydev, MII_AM79C_IR);
+	if (err < 0)
+		return err;
+
+	return 0;
+}
+
+static int am79c_config_init(struct phy_device *phydev)
+{
+	return 0;
+}
+
+static int am79c_config_intr(struct phy_device *phydev)
+{
+	int err;
+
+	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
+		err = phy_write(phydev, MII_AM79C_IR, MII_AM79C_IR_IMASK_INIT);
+	else
+		err = phy_write(phydev, MII_AM79C_IR, 0);
+
+	return err;
+}
+
+static struct phy_driver am79c_driver = {
+	.phy_id		= PHY_ID_AM79C874,
+	.name		= "AM79C874",
+	.phy_id_mask	= 0xfffffff0,
+	.features	= PHY_BASIC_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.config_init	= am79c_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.ack_interrupt	= am79c_ack_interrupt,
+	.config_intr	= am79c_config_intr,
+	.driver		= { .owner = THIS_MODULE,},
+};
+
+static int __init am79c_init(void)
+{
+	int ret;
+
+	ret = phy_driver_register(&am79c_driver);
+	if (ret)
+		return ret;
+
+	return 0;
+}
+
+static void __exit am79c_exit(void)
+{
+	phy_driver_unregister(&am79c_driver);
+}
+
+module_init(am79c_init);
+module_exit(am79c_exit);
+
+static struct mdio_device_id __maybe_unused amd_tbl[] = {
+	{ PHY_ID_AM79C874, 0xfffffff0 },
+	{ }
+};
+
+MODULE_DEVICE_TABLE(mdio, amd_tbl);
-- 
1.7.7.6
