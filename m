From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH net-next 2/2] net: phy: Add Meson GXL Internal PHY driver
Date: Fri,  4 Nov 2016 16:51:23 +0100
Message-ID: <1478274683-1503-3-git-send-email-narmstrong@baylibre.com>
References: <1478274683-1503-1-git-send-email-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong@baylibre.com>, netdev@vger.kernel.org,
        linux-amlogic@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com, carlo@caione.org, khilman@baylibre.com,
        andrew@lunn.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478274683-1503-1-git-send-email-narmstrong@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add driver for the Internal RMII PHY found in the Amlogic Meson GXL SoCs.

This PHY seems to only implement some standard registers and need some
workarounds to provide autoneg values from vendor registers.

Some magic values are currently used to configure the PHY, and this a
temporary setup until clarification about these registers names and
registers fields are provided by Amlogic.

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 drivers/net/phy/Kconfig     |  5 +++
 drivers/net/phy/Makefile    |  1 +
 drivers/net/phy/meson-gxl.c | 81 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 87 insertions(+)
 create mode 100644 drivers/net/phy/meson-gxl.c

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 2651c8d..b48943a 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -264,6 +264,11 @@ config MARVELL_PHY
 	---help---
 	  Currently has a driver for the 88E1011S
 
+config MESON_GXL_PHY
+	tristate "Amlogic Meson GXL Internal PHY"
+	---help---
+	  Currently has a driver for the Amlogic Meson GXL Internal PHY
+
 config MICREL_PHY
 	tristate "Micrel PHYs"
 	---help---
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index e58667d..3cd5af7 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -41,6 +41,7 @@ obj-$(CONFIG_INTEL_XWAY_PHY)	+= intel-xway.o
 obj-$(CONFIG_LSI_ET1011C_PHY)	+= et1011c.o
 obj-$(CONFIG_LXT_PHY)		+= lxt.o
 obj-$(CONFIG_MARVELL_PHY)	+= marvell.o
+obj-$(CONFIG_MESON_GXL_PHY)	+= meson-gxl.o
 obj-$(CONFIG_MICREL_KS8995MA)	+= spi_ks8995.o
 obj-$(CONFIG_MICREL_PHY)	+= micrel.o
 obj-$(CONFIG_MICROCHIP_PHY)	+= microchip.o
diff --git a/drivers/net/phy/meson-gxl.c b/drivers/net/phy/meson-gxl.c
new file mode 100644
index 0000000..1ea69b7
--- /dev/null
+++ b/drivers/net/phy/meson-gxl.c
@@ -0,0 +1,81 @@
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
+static int meson_gxl_config_init(struct phy_device *phydev)
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
+
+	return 0;
+}
+
+static struct phy_driver meson_gxl_phy[] = {
+	{
+		.phy_id		= 0x01814400,
+		.phy_id_mask	= 0xfffffff0,
+		.name		= "Meson GXL Internal PHY",
+		.features	= PHY_BASIC_FEATURES,
+		.flags		= PHY_IS_INTERNAL,
+		.config_init	= meson_gxl_config_init,
+		.config_aneg	= genphy_config_aneg,
+		.aneg_done      = genphy_aneg_done,
+		.read_status	= genphy_read_status,
+		.suspend        = genphy_suspend,
+		.resume         = genphy_resume,
+	},
+};
+
+static struct mdio_device_id __maybe_unused meson_gxl_tbl[] = {
+	{ 0x01814400, 0xfffffff0 },
+	{ }
+};
+
+module_phy_driver(meson_gxl_phy);
+
+MODULE_DEVICE_TABLE(mdio, meson_gxl_tbl);
+
+MODULE_DESCRIPTION("Amlogic Meson GXL Internal PHY driver");
+MODULE_AUTHOR("Baoqi wang");
+MODULE_AUTHOR("Neil Armstrong <narmstrong@baylibre.com>");
+MODULE_LICENSE("GPL");
-- 
1.9.1
