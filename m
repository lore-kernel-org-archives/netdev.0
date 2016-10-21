From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [RFC PATCH 09/13] net: phy: Add Meson GXL Internal PHY driver
Date: Fri, 21 Oct 2016 16:40:34 +0200
Message-ID: <1477060838-14164-10-git-send-email-narmstrong@baylibre.com>
References: <1477060838-14164-1-git-send-email-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong@baylibre.com>,
        linux-gpio@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-amlogic@lists.infradead.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: khilman@baylibre.com, carlo@caione.org, linus.walleij@linaro.org
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <1477060838-14164-1-git-send-email-narmstrong@baylibre.com>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add driver for the Internal RMII PHY found in the Amlogic Meson GXL SoCs.

This PHY seems to only implement some standard registers and need some
workarounds to provide autoneg values from vendor registers.

Some magic values are currently used to configure the PHY, and this a
temporary setup until clarification about these registers names and
registers fields are provided by Amlogic.

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 drivers/net/phy/Kconfig     |   5 ++
 drivers/net/phy/Makefile    |   1 +
 drivers/net/phy/meson-gxl.c | 175 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 181 insertions(+)
 create mode 100644 drivers/net/phy/meson-gxl.c

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 2651c8d..09342b6 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -226,6 +226,11 @@ config DP83867_PHY
 	---help---
 	  Currently supports the DP83867 PHY.
 
+config MESON_GXL_PHY
+	tristate "Amlogic Meson GXL Internal PHY"
+	---help---
+	  Currently has a driver for the Amlogic Meson GXL Internal PHY
+
 config FIXED_PHY
 	tristate "MDIO Bus/PHY emulation with fixed speed/link PHYs"
 	depends on PHYLIB
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index e58667d..1511b3e 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -44,6 +44,7 @@ obj-$(CONFIG_MARVELL_PHY)	+= marvell.o
 obj-$(CONFIG_MICREL_KS8995MA)	+= spi_ks8995.o
 obj-$(CONFIG_MICREL_PHY)	+= micrel.o
 obj-$(CONFIG_MICROCHIP_PHY)	+= microchip.o
+obj-$(CONFIG_MESON_GXL_PHY)	+= meson-gxl.o
 obj-$(CONFIG_MICROSEMI_PHY)	+= mscc.o
 obj-$(CONFIG_NATIONAL_PHY)	+= national.o
 obj-$(CONFIG_QSEMI_PHY)		+= qsemi.o
diff --git a/drivers/net/phy/meson-gxl.c b/drivers/net/phy/meson-gxl.c
new file mode 100644
index 0000000..4de3404
--- /dev/null
+++ b/drivers/net/phy/meson-gxl.c
@@ -0,0 +1,175 @@
+/*
+ * Amlogic Meson GXL Internal PHY Driver
+ *
+ * Copyright (C) 2015 Amlogic, Inc. All rights reserved.
+ * Copyright (C) 2016 BayLibre, SAS. All rights reserved.
+ * Author: Neil Armstrong <narmstrong@baylibre.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ */
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/phy.h>
+#include <linux/netdevice.h>
+
+#define GXL_REG_ANEG	0x1f
+
+#define REG_ANEG_FDUPLEX	0x10
+#define REG_ANEG_SPEED10	0x4
+#define REG_ANEG_SPEED100	0x8
+#define REG_ANEG_SPEED_MASK	0xc
+
+static void meson_gxl_phy_config(struct phy_device *phydev)
+{
+	/* Enable Analog and DSP register Bank access by */
+	phy_write(phydev, 0x14, 0x0000);
+	phy_write(phydev, 0x14, 0x0400);
+	phy_write(phydev, 0x14, 0x0000);
+	phy_write(phydev, 0x14, 0x0400);
+
+	/* Write Analog register 23 */
+	phy_write(phydev, 0x17, 0x8E0D);
+	phy_write(phydev, 0x14, 0x4417);
+
+	/* Enable fractional PLL */
+	phy_write(phydev, 0x17, 0x0005);
+	phy_write(phydev, 0x14, 0x5C1B);
+
+	/* Program fraction FR_PLL_DIV1 */
+	phy_write(phydev, 0x17, 0x029A);
+	phy_write(phydev, 0x14, 0x5C1D);
+
+	/* Program fraction FR_PLL_DIV1 */
+	phy_write(phydev, 0x17, 0xAAAA);
+	phy_write(phydev, 0x14, 0x5C1C);
+}
+
+static int meson_gxl_config_init(struct phy_device *phydev)
+{
+	int val;
+	u32 features;
+
+	meson_gxl_phy_config(phydev);
+
+	features = SUPPORTED_MII;
+
+	/* Do we support autonegotiation? */
+	val = phy_read(phydev, MII_BMSR);
+	if (val < 0)
+		return val;
+
+	if (val & BMSR_ANEGCAPABLE)
+		features |= SUPPORTED_Autoneg;
+	if (val & BMSR_100FULL)
+		features |= SUPPORTED_100baseT_Full;
+	if (val & BMSR_100HALF)
+		features |= SUPPORTED_100baseT_Half;
+	if (val & BMSR_10FULL)
+		features |= SUPPORTED_10baseT_Full;
+	if (val & BMSR_10HALF)
+		features |= SUPPORTED_10baseT_Half;
+
+	phydev->supported = features;
+	phydev->advertising = features;
+
+	return 0;
+}
+
+static int meson_gxl_phy_read_status(struct phy_device *phydev)
+{
+	int err;
+
+	/* Update the link, but return if there was an error */
+	err = genphy_update_link(phydev);
+	if (err)
+		return err;
+
+	phydev->lp_advertising = 0;
+	phydev->pause = 0;
+	phydev->asym_pause = 0;
+
+	if (phydev->autoneg == AUTONEG_ENABLE) {
+		unsigned int speed;
+		int reg = phy_read(phydev, GXL_REG_ANEG);
+
+		if (reg < 0)
+			return reg;
+
+		speed = reg & REG_ANEG_SPEED_MASK;
+
+		if (reg & REG_ANEG_FDUPLEX)
+			phydev->duplex = DUPLEX_FULL;
+		else
+			phydev->duplex = DUPLEX_HALF;
+
+		if ((reg & REG_ANEG_SPEED_MASK) == REG_ANEG_SPEED10)
+			phydev->speed = SPEED_10;
+		else if ((reg & REG_ANEG_SPEED_MASK) == REG_ANEG_SPEED100)
+			phydev->speed = SPEED_100;
+	} else {
+		int bmcr = phy_read(phydev, MII_BMCR);
+
+		if (bmcr < 0)
+			return bmcr;
+
+		if (bmcr & BMCR_FULLDPLX)
+			phydev->duplex = DUPLEX_FULL;
+		else
+			phydev->duplex = DUPLEX_HALF;
+
+		if (bmcr & BMCR_SPEED1000)
+			phydev->speed = SPEED_1000;
+		else if (bmcr & BMCR_SPEED100)
+			phydev->speed = SPEED_100;
+		else
+			phydev->speed = SPEED_10;
+	}
+
+	return 0;
+}
+
+static struct phy_driver meson_gxl_phy = {
+	.phy_id		= 0x01814400,
+	.name		= "Meson GXL Internal PHY",
+	.phy_id_mask	= 0x0fffffff,
+	.features	= 0,
+	.config_init	= meson_gxl_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= meson_gxl_phy_read_status,
+};
+
+static int __init meson_gxl_init(void)
+{
+	return phy_driver_register(&meson_gxl_phy, THIS_MODULE);
+}
+
+static void __exit meson_gxl_exit(void)
+{
+	phy_driver_unregister(&meson_gxl_phy);
+}
+
+static struct mdio_device_id __maybe_unused meson_gxl_tbl[] = {
+	{ 0x01814400, 0x0fffffff },
+	{ }
+};
+
+MODULE_DEVICE_TABLE(mdio, meson_gxl_tbl);
+
+module_init(meson_gxl_init);
+module_exit(meson_gxl_exit);
+
+MODULE_DESCRIPTION("Amlogic Meson GXL Internal PHY driver");
+MODULE_AUTHOR("Baoqi wang");
+MODULE_AUTHOR("Neil Armstrong <narmstrong@baylibre.com>");
+MODULE_LICENSE("GPL");
-- 
1.9.1

