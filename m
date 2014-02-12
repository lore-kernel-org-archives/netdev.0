From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 04/10] net: phy: add Broadcom BCM7xxx internal PHY driver
Date: Tue, 11 Feb 2014 20:07:27 -0800
Message-ID: <1392178053-3143-5-git-send-email-f.fainelli@gmail.com>
References: <1392178053-3143-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <cernekee@gmail.com>,
	<devicetree@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:32426 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751645AbaBLEIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 23:08:14 -0500
In-Reply-To: <1392178053-3143-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the Broadcom BCM7xxx Set Top Box SoCs
internal PHYs. This driver supports the following generation of SoCs:

- BCM7366, BCM7439, BCM7445 (28nm process)
- all 40nm and 65nm (older MIPS-based SoCs)

The PHYs on these SoCs require a bunch of workarounds to operate
correctly, both during configuration time and at suspend/resume time,
the driver handles that for us.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/Kconfig   |   6 +
 drivers/net/phy/Makefile  |   1 +
 drivers/net/phy/bcm7xxx.c | 322 ++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/brcmphy.h   |   9 ++
 4 files changed, 338 insertions(+)
 create mode 100644 drivers/net/phy/bcm7xxx.c

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 9b5d46c..6a17f92 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -71,6 +71,12 @@ config BCM63XX_PHY
 	---help---
 	  Currently supports the 6348 and 6358 PHYs.
 
+config BCM7XXX_PHY
+	tristate "Drivers for Broadcom 7xxx SOCs internal PHYs"
+	---help---
+	  Currently supports the BCM7366, BCM7439, BCM7445, and
+	  40nm and 65nm generation of BCM7xxx Set Top Box SoCs.
+
 config BCM87XX_PHY
 	tristate "Driver for Broadcom BCM8706 and BCM8727 PHYs"
 	help
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 9013dfa..07d2402 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -12,6 +12,7 @@ obj-$(CONFIG_SMSC_PHY)		+= smsc.o
 obj-$(CONFIG_VITESSE_PHY)	+= vitesse.o
 obj-$(CONFIG_BROADCOM_PHY)	+= broadcom.o
 obj-$(CONFIG_BCM63XX_PHY)	+= bcm63xx.o
+obj-$(CONFIG_BCM7XXX_PHY)	+= bcm7xxx.o
 obj-$(CONFIG_BCM87XX_PHY)	+= bcm87xx.o
 obj-$(CONFIG_ICPLUS_PHY)	+= icplus.o
 obj-$(CONFIG_REALTEK_PHY)	+= realtek.o
diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
new file mode 100644
index 0000000..f9ac282
--- /dev/null
+++ b/drivers/net/phy/bcm7xxx.c
@@ -0,0 +1,322 @@
+/*
+ * Broadcom BCM7xxx internal transceivers support.
+ *
+ * Copyright (C) 2014, Broadcom Corporation
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/phy.h>
+#include <linux/delay.h>
+#include <linux/brcmphy.h>
+
+static int bcm7445_config_init(struct phy_device *phydev)
+{
+	int ret;
+	const struct bcm7445_regs {
+		int reg;
+		u16 value;
+	} bcm7445_regs_cfg[] = {
+		/* increases ADC latency by 24ns */
+		{ 0x17, 0x0038 },
+		{ 0x15, 0xAB95 },
+		/* increases internal 1V LDO voltage by 5% */
+		{ 0x17, 0x2038 },
+		{ 0x15, 0xBB22 },
+		/* reduce RX low pass filter corner frequency */
+		{ 0x17, 0x6038 },
+		{ 0x15, 0xFFC5 },
+		/* reduce RX high pass filter corner frequency */
+		{ 0x17, 0x003a },
+		{ 0x15, 0x2002 },
+	};
+	unsigned int i;
+
+	for (i = 0; i < ARRAY_SIZE(bcm7445_regs_cfg); i++) {
+		ret = phy_write(phydev,
+				bcm7445_regs_cfg[i].reg,
+				bcm7445_regs_cfg[i].value);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+
+static void phy_write_exp(struct phy_device *phydev,
+					u16 reg, u16 value)
+{
+	phy_write(phydev, 0x17, 0xf00 | reg);
+	phy_write(phydev, 0x15, value);
+}
+
+static void phy_write_misc(struct phy_device *phydev,
+					u16 reg, u16 chl, u16 value)
+{
+	int tmp;
+
+	phy_write(phydev, 0x18, 0x7);
+
+	tmp = phy_read(phydev, 0x18);
+	tmp |= 0x800;
+	phy_write(phydev, 0x18, tmp);
+
+	tmp = (chl * 0x2000) | reg;
+	phy_write(phydev, 0x17, tmp);
+
+	phy_write(phydev, 0x15, value);
+}
+
+static int bcm7xxx_28nm_afe_config_init(struct phy_device *phydev)
+{
+	/* write AFE_RXCONFIG_0 */
+	phy_write_misc(phydev, 0x38, 0x0000, 0xeb17);
+
+	/* write AFE_RXCONFIG_1 */
+	phy_write_misc(phydev, 0x38, 0x0001, 0x9a3f);
+
+	/* write AFE_RX_LP_COUNTER */
+	phy_write_misc(phydev, 0x38, 0x0003, 0x7fc7);
+
+	/* write AFE_HPF_TRIM_OTHERS */
+	phy_write_misc(phydev, 0x3A, 0x0000, 0x000b);
+
+	/* write AFTE_TX_CONFIG */
+	phy_write_misc(phydev, 0x39, 0x0000, 0x0800);
+
+	/* Increase VCO range to prevent unlocking problem of PLL at low
+	 * temp
+	 */
+	phy_write_misc(phydev, 0x0032, 0x0001, 0x0048);
+
+	/* Change Ki to 011 */
+	phy_write_misc(phydev, 0x0032, 0x0002, 0x021b);
+
+	/* Disable loading of TVCO buffer to bandgap, set bandgap trim
+	 * to 111
+	 */
+	phy_write_misc(phydev, 0x0033, 0x0000, 0x0e20);
+
+	/* Adjust bias current trim by -3 */
+	phy_write_misc(phydev, 0x000a, 0x0000, 0x690b);
+
+	/* Switch to CORE_BASE1E */
+	phy_write(phydev, 0x1e, 0xd);
+
+	/* Reset R_CAL/RC_CAL Engine */
+	phy_write_exp(phydev, 0x00b0, 0x0010);
+
+	/* Disable Reset R_CAL/RC_CAL Engine */
+	phy_write_exp(phydev, 0x00b0, 0x0000);
+
+	return 0;
+}
+
+static int bcm7xxx_28nm_config_init(struct phy_device *phydev)
+{
+	int ret;
+
+	ret = bcm7445_config_init(phydev);
+	if (ret)
+		return ret;
+
+	return bcm7xxx_28nm_afe_config_init(phydev);
+}
+
+static int phy_set_clr_bits(struct phy_device *dev, int location,
+					int set_mask, int clr_mask)
+{
+	int v, ret;
+
+	v = phy_read(dev, location);
+	if (v < 0)
+		return v;
+
+	v &= ~clr_mask;
+	v |= set_mask;
+
+	ret = phy_write(dev, location, v);
+	if (ret < 0)
+		return ret;
+
+	return v;
+}
+
+static int bcm7xxx_config_init(struct phy_device *phydev)
+{
+	/* Enable 64 clock MDIO */
+	phy_write(phydev, 0x1d, 0x1000);
+	phy_read(phydev, 0x1d);
+
+	/* Workaround only required for 100Mbits/sec */
+	if (!(phydev->dev_flags & PHY_BRCM_100MBPS_WAR))
+		return 0;
+
+	/* set shadow mode 2 */
+	phy_set_clr_bits(phydev, 0x1f, 0x0004, 0x0004);
+
+	/* set iddq_clkbias */
+	phy_write(phydev, 0x14, 0x0F00);
+	udelay(10);
+
+	/* reset iddq_clkbias */
+	phy_write(phydev, 0x14, 0x0C00);
+
+	phy_write(phydev, 0x13, 0x7555);
+
+	/* reset shadow mode 2 */
+	phy_set_clr_bits(phydev, 0x1f, 0x0004, 0);
+
+	return 0;
+}
+
+/* Workaround for putting the PHY in IDDQ mode, required
+ * for all BCM7XXX PHYs
+ */
+static int bcm7xxx_suspend(struct phy_device *phydev)
+{
+	int ret;
+	const struct bcm7xxx_regs {
+		int reg;
+		u16 value;
+	} bcm7xxx_suspend_cfg[] = {
+		{ 0x1f, 0x008b },
+		{ 0x10, 0x01c0 },
+		{ 0x14, 0x7000 },
+		{ 0x1f, 0x000f },
+		{ 0x10, 0x20d0 },
+		{ 0x1f, 0x000b },
+	};
+	unsigned int i;
+
+	for (i = 0; i < ARRAY_SIZE(bcm7xxx_suspend_cfg); i++) {
+		ret = phy_write(phydev,
+				bcm7xxx_suspend_cfg[i].reg,
+				bcm7xxx_suspend_cfg[i].value);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+
+static int bcm7xxx_dummy_config_init(struct phy_device *phydev)
+{
+	return 0;
+}
+
+static struct phy_driver bcm7xxx_driver[] = {
+{
+	.phy_id		= PHY_ID_BCM7366,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "Broadcom BCM7366",
+	.features	= PHY_GBIT_FEATURES |
+			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.flags		= PHY_IS_INTERNAL,
+	.config_init	= bcm7xxx_28nm_afe_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.suspend	= bcm7xxx_suspend,
+	.resume		= bcm7xxx_28nm_afe_config_init,
+	.driver		= { .owner = THIS_MODULE },
+}, {
+	.phy_id		= PHY_ID_BCM7439,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "Broadcom BCM7439",
+	.features	= PHY_GBIT_FEATURES |
+			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.flags		= PHY_IS_INTERNAL,
+	.config_init	= bcm7xxx_28nm_afe_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.suspend	= bcm7xxx_suspend,
+	.resume		= bcm7xxx_28nm_afe_config_init,
+	.driver		= { .owner = THIS_MODULE },
+}, {
+	.phy_id		= PHY_ID_BCM7445,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "Broadcom BCM7445",
+	.features	= PHY_GBIT_FEATURES |
+			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.flags		= PHY_IS_INTERNAL,
+	.config_init	= bcm7xxx_28nm_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.suspend	= bcm7xxx_suspend,
+	.resume		= bcm7xxx_28nm_config_init,
+	.driver		= { .owner = THIS_MODULE },
+}, {
+	.name		= "Broadcom BCM7XXX 28nm",
+	.phy_id		= PHY_ID_BCM7XXX_28,
+	.phy_id_mask	= PHY_BCM_OUI_MASK,
+	.features	= PHY_GBIT_FEATURES |
+			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.flags		= PHY_IS_INTERNAL,
+	.config_init	= bcm7xxx_28nm_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.suspend	= bcm7xxx_suspend,
+	.resume		= bcm7xxx_28nm_config_init,
+	.driver		= { .owner = THIS_MODULE },
+}, {
+	.phy_id		= PHY_BCM_OUI_4,
+	.phy_id_mask	= 0xffff0000,
+	.name		= "Broadcom BCM7XXX 40nm",
+	.features	= PHY_GBIT_FEATURES |
+			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.flags		= PHY_IS_INTERNAL,
+	.config_init	= bcm7xxx_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.suspend	= bcm7xxx_suspend,
+	.resume		= bcm7xxx_config_init,
+	.driver		= { .owner = THIS_MODULE },
+}, {
+	.phy_id		= PHY_BCM_OUI_5,
+	.phy_id_mask	= 0xffffff00,
+	.name		= "Broadcom BCM7XXX 65nm",
+	.features	= PHY_BASIC_FEATURES |
+			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.flags		= PHY_IS_INTERNAL,
+	.config_init	= bcm7xxx_dummy_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.suspend	= bcm7xxx_suspend,
+	.resume		= bcm7xxx_config_init,
+	.driver		= { .owner = THIS_MODULE },
+} };
+
+static struct mdio_device_id __maybe_unused bcm7xxx_tbl[] = {
+	{ PHY_ID_BCM7366, 0xfffffff0, },
+	{ PHY_ID_BCM7439, 0xfffffff0, },
+	{ PHY_ID_BCM7445, 0xfffffff0, },
+	{ PHY_ID_BCM7XXX_28, 0xfffffc00 },
+	{ PHY_BCM_OUI_4, 0xffff0000 },
+	{ PHY_BCM_OUI_5, 0xffffff00 },
+	{ }
+};
+
+static int __init bcm7xxx_phy_init(void)
+{
+	return phy_drivers_register(bcm7xxx_driver,
+			ARRAY_SIZE(bcm7xxx_driver));
+}
+
+static void __exit bcm7xxx_phy_exit(void)
+{
+	phy_drivers_unregister(bcm7xxx_driver,
+			ARRAY_SIZE(bcm7xxx_driver));
+}
+
+module_init(bcm7xxx_phy_init);
+module_exit(bcm7xxx_phy_exit);
+
+MODULE_DEVICE_TABLE(mdio, bcm7xxx_tbl);
+
+MODULE_DESCRIPTION("Broadcom BCM7xxx internal PHY driver");
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Broadcom Corporation");
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index 677b4f0..e9fc98d 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -13,10 +13,17 @@
 #define PHY_ID_BCM5461			0x002060c0
 #define PHY_ID_BCM57780			0x03625d90
 
+#define PHY_ID_BCM7366			0x600d8490
+#define PHY_ID_BCM7439			0x600d8480
+#define PHY_ID_BCM7445			0x600d8510
+#define PHY_ID_BCM7XXX_28		0x600d8400
+
 #define PHY_BCM_OUI_MASK		0xfffffc00
 #define PHY_BCM_OUI_1			0x00206000
 #define PHY_BCM_OUI_2			0x0143bc00
 #define PHY_BCM_OUI_3			0x03625c00
+#define PHY_BCM_OUI_4			0x600d0000
+#define PHY_BCM_OUI_5			0x03625e00
 
 
 #define PHY_BCM_FLAGS_MODE_COPPER	0x00000001
@@ -31,6 +38,8 @@
 #define PHY_BRCM_EXT_IBND_TX_ENABLE	0x00002000
 #define PHY_BRCM_CLEAR_RGMII_MODE	0x00004000
 #define PHY_BRCM_DIS_TXCRXC_NOENRGY	0x00008000
+/* Broadcom BCM7xxx specific workarounds */
+#define PHY_BRCM_100MBPS_WAR		0x00010000
 #define PHY_BCM_FLAGS_VALID		0x80000000
 
 #endif /* _LINUX_BRCMPHY_H */
-- 
1.8.3.2
