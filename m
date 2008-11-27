From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH] phy: add natsemi PHY driver
Date: Thu, 27 Nov 2008 14:56:33 +0100
Message-ID: <1227794193-19846-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:43797 "EHLO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755424AbYK0N5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 08:57:09 -0500
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id D2F3FDB1B
	for <netdev@vger.kernel.org>; Thu, 27 Nov 2008 13:56:56 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id AECE74C275
	for <netdev@vger.kernel.org>; Thu, 27 Nov 2008 13:56:51 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the PHY device driver for the National Semiconductor
DP83865 Gig PHYTER.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/phy/Kconfig    |    5 ++
 drivers/net/phy/Makefile   |    1 +
 drivers/net/phy/national.c |  155 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 161 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/phy/national.c

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index d55932a..0923c8f 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -66,6 +66,11 @@ config REALTEK_PHY
 	---help---
 	  Supports the Realtek 821x PHY.
 
+config NATIONAL_PHY
+	tristate "Drivers for National Semiconductor PHYs"
+	---help---
+	  Currently supports the DP83865 PHY.
+
 config FIXED_PHY
 	bool "Driver for MDIO Bus/PHY emulation with fixed speed/link PHYs"
 	depends on PHYLIB=y
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index eee329f..5c53ca5 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -16,3 +16,4 @@ obj-$(CONFIG_REALTEK_PHY)	+= realtek.o
 obj-$(CONFIG_FIXED_PHY)		+= fixed.o
 obj-$(CONFIG_MDIO_BITBANG)	+= mdio-bitbang.o
 obj-$(CONFIG_MDIO_OF_GPIO)	+= mdio-ofgpio.o
+obj-$(CONFIG_NATIONAL_PHY)	+= national.o
diff --git a/drivers/net/phy/national.c b/drivers/net/phy/national.c
new file mode 100644
index 0000000..6c636eb
--- /dev/null
+++ b/drivers/net/phy/national.c
@@ -0,0 +1,155 @@
+/*
+ * drivers/net/phy/national.c
+ *
+ * Driver for National Semiconductor PHYs
+ *
+ * Author: Stuart Menefy <stuart.menefy@st.com>
+ * Maintainer: Giuseppe Cavallaro <peppe.cavallaro@st.com>
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
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/phy.h>
+#include <linux/netdevice.h>
+
+/* DP83865 phy identifier values */
+#define DP83865_PHY_ID	0x20005c7a
+
+#define DP83865_INT_MASK_REG 0x15
+#define DP83865_INT_MASK_STATUS 0x14
+
+#define DP83865_INT_REMOTE_FAULT 0x0008
+#define DP83865_INT_ANE_COMPLETED 0x0010
+#define DP83865_INT_LINK_CHANGE	0xe000
+#define DP83865_INT_MASK_DEFAULT (DP83865_INT_REMOTE_FAULT | \
+				DP83865_INT_ANE_COMPLETED | \
+				DP83865_INT_LINK_CHANGE)
+
+/* Advanced proprietary configuration */
+#define NS_EXP_MEM_CTL	0x16
+#define NS_EXP_MEM_DATA	0x1d
+#define NS_EXP_MEM_ADD	0x1e
+
+#define LED_CTRL_REG 0x13
+#define AN_FALLBACK_AN 0x0001
+#define AN_FALLBACK_CRC 0x0002
+#define AN_FALLBACK_IE 0x0004
+#define ALL_FALLBACK_ON (AN_FALLBACK_AN |  AN_FALLBACK_CRC | AN_FALLBACK_IE)
+
+enum hdx_loopback {
+	hdx_loopback_on = 0,
+	hdx_loopback_off = 1,
+};
+
+static u8 ns_exp_read(struct phy_device *phydev, u16 reg)
+{
+	phy_write(phydev, NS_EXP_MEM_ADD, reg);
+	return phy_read(phydev, NS_EXP_MEM_DATA);
+}
+
+static void ns_exp_write(struct phy_device *phydev, u16 reg, u8 data)
+{
+	phy_write(phydev, NS_EXP_MEM_ADD, reg);
+	phy_write(phydev, NS_EXP_MEM_DATA, data);
+}
+
+static int ns_config_intr(struct phy_device *phydev)
+{
+	int err;
+
+	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
+		err = phy_write(phydev, DP83865_INT_MASK_REG,
+				DP83865_INT_MASK_DEFAULT);
+	else
+		err = phy_write(phydev, DP83865_INT_MASK_REG, 0);
+
+	return err;
+}
+
+static int ns_ack_interrupt(struct phy_device *phydev)
+{
+	int ret = phy_read(phydev, DP83865_INT_MASK_STATUS);
+	if (ret < 0)
+		return ret;
+
+	return 0;
+}
+
+static void ns_giga_speed_fallback(struct phy_device *phydev, int mode)
+{
+	int bmcr = phy_read(phydev, MII_BMCR);
+
+	phy_write(phydev, MII_BMCR, (bmcr | BMCR_PDOWN));
+
+	/* Enable 8 bit expended memory read/write (no auto increment) */
+	phy_write(phydev, NS_EXP_MEM_CTL, 0);
+	phy_write(phydev, NS_EXP_MEM_ADD, 0x1C0);
+	phy_write(phydev, NS_EXP_MEM_DATA, 0x0008);
+	phy_write(phydev, MII_BMCR, (bmcr & ~BMCR_PDOWN));
+	phy_write(phydev, LED_CTRL_REG, mode);
+	return;
+}
+
+static void ns_10_base_t_hdx_loopack(struct phy_device *phydev, int disable)
+{
+	if (disable)
+		ns_exp_write(phydev, 0x1c0, ns_exp_read(phydev, 0x1c0) | 1);
+	else
+		ns_exp_write(phydev, 0x1c0,
+			     ns_exp_read(phydev, 0x1c0) & 0xfffe);
+
+	printk(KERN_DEBUG "DP83865 PHY: 10BASE-T HDX loopback %s\n",
+	       (ns_exp_read(phydev, 0x1c0) & 0x0001) ? "off" : "on");
+
+	return;
+}
+
+static int ns_config_init(struct phy_device *phydev)
+{
+	ns_giga_speed_fallback(phydev, ALL_FALLBACK_ON);
+	/* In the latest MAC or switches design, the 10 Mbps loopback
+	   is desired to be turned off. */
+	ns_10_base_t_hdx_loopack(phydev, hdx_loopback_off);
+	return ns_ack_interrupt(phydev);
+}
+
+static struct phy_driver dp83865_driver = {
+	.phy_id = DP83865_PHY_ID,
+	.phy_id_mask = 0xfffffff0,
+	.name = "NatSemi DP83865",
+	.features = PHY_GBIT_FEATURES | SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.flags = PHY_HAS_INTERRUPT,
+	.config_init = ns_config_init,
+	.config_aneg = genphy_config_aneg,
+	.read_status = genphy_read_status,
+	.ack_interrupt = ns_ack_interrupt,
+	.config_intr = ns_config_intr,
+	.driver = {.owner = THIS_MODULE,}
+};
+
+static int __init ns_init(void)
+{
+	return phy_driver_register(&dp83865_driver);
+}
+
+static void __exit ns_exit(void)
+{
+	phy_driver_unregister(&dp83865_driver);
+}
+
+MODULE_DESCRIPTION("NatSemi PHY driver");
+MODULE_AUTHOR("Stuart Menefy");
+MODULE_LICENSE("GPL");
+
+module_init(ns_init);
+module_exit(ns_exit);
-- 
1.5.6.5

