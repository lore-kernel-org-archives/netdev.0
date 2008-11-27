From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH] phy: add the ST ste10Xp PHYs
Date: Thu, 27 Nov 2008 14:57:35 +0100
Message-ID: <1227794255-19924-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:48711 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753417AbYK0N6B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 08:58:01 -0500
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 58687DB3B
	for <netdev@vger.kernel.org>; Thu, 27 Nov 2008 13:57:52 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 7745D4C283
	for <netdev@vger.kernel.org>; Thu, 27 Nov 2008 13:57:52 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the STMicroelectronics ste10xp PHY device driver.
It supports both the ste100p and the ste101p devices.

Suspend/resume alredy added.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/phy/Kconfig   |    6 ++
 drivers/net/phy/Makefile  |    1 +
 drivers/net/phy/ste10Xp.c |  137 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 144 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/phy/ste10Xp.c

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 0923c8f..6ccf9e6 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -71,6 +71,12 @@ config NATIONAL_PHY
 	---help---
 	  Currently supports the DP83865 PHY.
 
+config STE10XP
+	depends on PHYLIB
+	tristate "Driver for STMicroelectronics STe10Xp PHYs"
+	---help---
+	  This is the driver for the STe100p and STe101p PHYs.
+
 config FIXED_PHY
 	bool "Driver for MDIO Bus/PHY emulation with fixed speed/link PHYs"
 	depends on PHYLIB=y
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 5c53ca5..babe76e 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -17,3 +17,4 @@ obj-$(CONFIG_FIXED_PHY)		+= fixed.o
 obj-$(CONFIG_MDIO_BITBANG)	+= mdio-bitbang.o
 obj-$(CONFIG_MDIO_OF_GPIO)	+= mdio-ofgpio.o
 obj-$(CONFIG_NATIONAL_PHY)	+= national.o
+obj-$(CONFIG_STE10XP)		+= ste10Xp.o
diff --git a/drivers/net/phy/ste10Xp.c b/drivers/net/phy/ste10Xp.c
new file mode 100644
index 0000000..0733151
--- /dev/null
+++ b/drivers/net/phy/ste10Xp.c
@@ -0,0 +1,137 @@
+/*
+ * drivers/net/phy/ste10Xp.c
+ *
+ * Driver for STMicroelectronics STe10Xp PHYs
+ *
+ * Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
+ *
+ * Copyright (c) 2008 STMicroelectronics Limited
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/sched.h>
+#include <linux/kernel.h>
+#include <linux/moduleparam.h>
+#include <linux/interrupt.h>
+#include <linux/netdevice.h>
+#include <linux/ethtool.h>
+#include <linux/mii.h>
+#include <linux/phy.h>
+
+#define MII_XCIIS   	0x11	/* Configuration Info IRQ & Status Reg */
+#define MII_XIE     	0x12	/* Interrupt Enable Register */
+#define MII_XIE_DEFAULT_MASK 0x0070 /* ANE complete, Remote Fault, Link Down */
+
+#define STE101P_PHY_ID		0x00061c50
+#define STE100P_PHY_ID       	0x1c040011
+
+static int ste10Xp_config_init(struct phy_device *phydev)
+{
+	int value, err;
+
+	/* Software Reset PHY */
+	value = phy_read(phydev, MII_BMCR);
+	if (value < 0)
+		return value;
+
+	value |= BMCR_RESET;
+	err = phy_write(phydev, MII_BMCR, value);
+	if (err < 0)
+		return err;
+
+	do {
+		value = phy_read(phydev, MII_BMCR);
+	} while (value & BMCR_RESET);
+
+	return 0;
+}
+
+static int ste10Xp_config_intr(struct phy_device *phydev)
+{
+	int err, value;
+
+	if (phydev->interrupts == PHY_INTERRUPT_ENABLED) {
+		/* Enable all STe101P interrupts (PR12) */
+		err = phy_write(phydev, MII_XIE, MII_XIE_DEFAULT_MASK);
+		/* clear any pending interrupts */
+		if (err == 0) {
+			value = phy_read(phydev, MII_XCIIS);
+			if (value < 0)
+				err = value;
+		}
+	} else
+		err = phy_write(phydev, MII_XIE, 0);
+
+	return err;
+}
+
+static int ste10Xp_ack_interrupt(struct phy_device *phydev)
+{
+	int err = phy_read(phydev, MII_XCIIS);
+	if (err < 0)
+		return err;
+
+	return 0;
+}
+
+static struct phy_driver ste101p_pdriver = {
+	.phy_id = STE101P_PHY_ID,
+	.phy_id_mask = 0xfffffff0,
+	.name = "STe101p",
+	.features = PHY_BASIC_FEATURES | SUPPORTED_Pause,
+	.flags = PHY_HAS_INTERRUPT,
+	.config_init = ste10Xp_config_init,
+	.config_aneg = genphy_config_aneg,
+	.read_status = genphy_read_status,
+	.ack_interrupt = ste10Xp_ack_interrupt,
+	.config_intr = ste10Xp_config_intr,
+	.suspend = genphy_suspend,
+	.resume = genphy_resume,
+	.driver = {.owner = THIS_MODULE,}
+};
+
+static struct phy_driver ste100p_pdriver = {
+	.phy_id = STE100P_PHY_ID,
+	.phy_id_mask = 0xffffffff,
+	.name = "STe100p",
+	.features = PHY_BASIC_FEATURES | SUPPORTED_Pause,
+	.flags = PHY_HAS_INTERRUPT,
+	.config_init = ste10Xp_config_init,
+	.config_aneg = genphy_config_aneg,
+	.read_status = genphy_read_status,
+	.ack_interrupt = ste10Xp_ack_interrupt,
+	.config_intr = ste10Xp_config_intr,
+	.suspend = genphy_suspend,
+	.resume = genphy_resume,
+	.driver = {.owner = THIS_MODULE,}
+};
+
+static int __init ste10Xp_init(void)
+{
+	int retval;
+
+	retval = phy_driver_register(&ste100p_pdriver);
+	if (retval < 0)
+		return retval;
+	return phy_driver_register(&ste101p_pdriver);
+}
+
+static void __exit ste10Xp_exit(void)
+{
+	phy_driver_unregister(&ste100p_pdriver);
+	phy_driver_unregister(&ste101p_pdriver);
+}
+
+module_init(ste10Xp_init);
+module_exit(ste10Xp_exit);
+
+MODULE_DESCRIPTION("STMicroelectronics STe10Xp PHY driver");
+MODULE_AUTHOR("Giuseppe Cavallaro <peppe.cavallaro@st.com>");
+MODULE_LICENSE("GPL");
-- 
1.5.6.5

