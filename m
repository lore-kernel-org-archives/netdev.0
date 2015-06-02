From: Dan Murphy <dmurphy@ti.com>
Subject: [PATCH v2] net: phy: dp83867: Add TI dp83867 phy
Date: Tue, 2 Jun 2015 09:34:37 -0500
Message-ID: <1433255677-20293-1-git-send-email-dmurphy@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, Dan Murphy <dmurphy@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:37329 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752607AbbFBOek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 10:34:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the TI dp83867 Gigabit ethernet phy
device.

The DP83867 is a robust, low power, fully featured
Physical Layer transceiver with integrated PMD
sublayers to support 10BASE-T, 100BASE-TX and
1000BASE-T Ethernet protocols.

Signed-off-by: Dan Murphy <dmurphy@ti.com>
---

v2 - Add device tree support and other minor changes.  Added change for rgmii helper
http://patchwork.ozlabs.org/patch/476446/

 .../devicetree/bindings/net/ti,dp83867.txt         |  19 ++
 drivers/net/phy/Kconfig                            |   6 +-
 drivers/net/phy/Makefile                           |   1 +
 drivers/net/phy/dp83867.c                          | 239 +++++++++++++++++++++
 include/dt-bindings/net/ti-dp83867.h               |  45 ++++
 5 files changed, 309 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/devicetree/bindings/net/ti,dp83867.txt
 create mode 100644 drivers/net/phy/dp83867.c
 create mode 100644 include/dt-bindings/net/ti-dp83867.h

diff --git a/Documentation/devicetree/bindings/net/ti,dp83867.txt b/Documentation/devicetree/bindings/net/ti,dp83867.txt
new file mode 100644
index 0000000..46bb67a
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/ti,dp83867.txt
@@ -0,0 +1,19 @@
+* Texas Instruments - dp83867 Giga bit ethernet phy
+
+Required properties:
+	- reg - The ID number for the phy, usually a small integer
+	- ti,rx_int_delay - RGMII Recieve Clock Delay - see dt-bindings/net/ti-dp83867.h
+		for applicable values
+	- ti,tx_int_delay - RGMII Transmit Clock Delay - see dt-bindings/net/ti-dp83867.h
+		for applicable values
+	- ti,fifo_depth - Transmitt FIFO depth- see dt-bindings/net/ti-dp83867.h
+		for applicable values
+
+Example:
+
+	ethernet-phy@0 {
+		reg = <0>;
+		ti,rx_int_delay = <DP83867_RGMIIDCTL_2_25_NS>;
+		ti,tx_int_delay = <DP83867_RGMIIDCTL_2_75_NS>;
+		ti,fifo_depth = <DP83867_PHYCR_FIFO_DEPTH_4_B_NIB>;
+	};
diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 70641d2..939f06e 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -119,6 +119,11 @@ config MICREL_PHY
 	---help---
 	  Supports the KSZ9021, VSC8201, KS8001 PHYs.
 
+config DP83867_PHY
+	tristate "Drivers for Texas Instruments DP83867 Gigabit PHY"
+	---help---
+	  Currently supports the DP83867 PHY.
+
 config FIXED_PHY
 	tristate "Driver for MDIO Bus/PHY emulation with fixed speed/link PHYs"
 	depends on PHYLIB
@@ -212,7 +217,6 @@ config MDIO_BCM_UNIMAC
 	  This hardware can be found in the Broadcom GENET Ethernet MAC
 	  controllers as well as some Broadcom Ethernet switches such as the
 	  Starfighter 2 switches.
-
 endif # PHYLIB
 
 config MICREL_KS8995MA
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 501ea76..58e6131 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -22,6 +22,7 @@ obj-$(CONFIG_MDIO_BITBANG)	+= mdio-bitbang.o
 obj-$(CONFIG_MDIO_GPIO)		+= mdio-gpio.o
 obj-$(CONFIG_NATIONAL_PHY)	+= national.o
 obj-$(CONFIG_DP83640_PHY)	+= dp83640.o
+obj-$(CONFIG_DP83867_PHY)	+= dp83867.o
 obj-$(CONFIG_STE10XP)		+= ste10Xp.o
 obj-$(CONFIG_MICREL_PHY)	+= micrel.o
 obj-$(CONFIG_MDIO_OCTEON)	+= mdio-octeon.o
diff --git a/drivers/net/phy/dp83867.c b/drivers/net/phy/dp83867.c
new file mode 100644
index 0000000..ef0b4eb
--- /dev/null
+++ b/drivers/net/phy/dp83867.c
@@ -0,0 +1,239 @@
+/*
+ * Driver for the Texas Instruments DP83867 PHY
+ *
+ * Copyright (C) 2015 Texas Instruments Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/ethtool.h>
+#include <linux/kernel.h>
+#include <linux/mii.h>
+#include <linux/module.h>
+#include <linux/of.h>
+#include <linux/phy.h>
+
+#include <dt-bindings/net/ti-dp83867.h>
+
+#define DP83867_PHY_ID		0x2000a231
+#define DP83867_DEVADDR		0x1f
+
+#define MII_DP83867_PHYCTRL	0x10
+#define MII_DP83867_MICR	0x12
+#define MII_DP83867_ISR		0x13
+#define DP83867_CTRL		0x1f
+
+/* Extended Registers */
+#define DP83867_RGMIICTL	0x0032
+#define DP83867_RGMIIDCTL	0x0086
+
+#define DP83867_SW_RESET	BIT(15)
+#define DP83867_SW_RESTART	BIT(14)
+
+/* MICR Interrupt bits */
+#define MII_DP83867_MICR_AN_ERR_INT_EN		BIT(15)
+#define MII_DP83867_MICR_SPEED_CHNG_INT_EN	BIT(14)
+#define MII_DP83867_MICR_DUP_MODE_CHNG_INT_EN	BIT(13)
+#define MII_DP83867_MICR_PAGE_RXD_INT_EN	BIT(12)
+#define MII_DP83867_MICR_AUTONEG_COMP_INT_EN	BIT(11)
+#define MII_DP83867_MICR_LINK_STS_CHNG_INT_EN	BIT(10)
+#define MII_DP83867_MICR_FALSE_CARRIER_INT_EN	BIT(8)
+#define MII_DP83867_MICR_SLEEP_MODE_CHNG_INT_EN	BIT(4)
+#define MII_DP83867_MICR_WOL_INT_EN		BIT(3)
+#define MII_DP83867_MICR_XGMII_ERR_INT_EN	BIT(2)
+#define MII_DP83867_MICR_POL_CHNG_INT_EN	BIT(1)
+#define MII_DP83867_MICR_JABBER_INT_EN		BIT(0)
+
+/* RGMIICTL bits */
+#define DP83867_RGMII_TX_CLK_DELAY_EN		BIT(1)
+#define DP83867_RGMII_RX_CLK_DELAY_EN		BIT(0)
+
+/* PHY CTRL bits */
+#define DP83867_PHYCR_FIFO_DEPTH_SHIFT		14
+
+/* RGMIIDCTL bits */
+#define DP83867_RGMII_TX_CLK_DELAY_SHIFT	4
+
+struct dp83867_private {
+	int rx_id_delay;
+	int tx_id_delay;
+	int fifo_depth;
+};
+
+static int dp83867_ack_interrupt(struct phy_device *phydev)
+{
+	int err = phy_read(phydev, MII_DP83867_ISR);
+
+	if (err < 0)
+		return err;
+
+	return 0;
+}
+
+static int dp83867_config_intr(struct phy_device *phydev)
+{
+	int micr_status;
+
+	if (phydev->interrupts == PHY_INTERRUPT_ENABLED) {
+		micr_status = phy_read(phydev, MII_DP83867_MICR);
+		if (micr_status < 0)
+			return micr_status;
+
+		micr_status |=
+			(MII_DP83867_MICR_AN_ERR_INT_EN |
+			MII_DP83867_MICR_SPEED_CHNG_INT_EN |
+			MII_DP83867_MICR_DUP_MODE_CHNG_INT_EN |
+			MII_DP83867_MICR_SLEEP_MODE_CHNG_INT_EN);
+
+		return phy_write(phydev, MII_DP83867_MICR, micr_status);
+	}
+
+	micr_status = 0x0;
+	return phy_write(phydev, MII_DP83867_MICR, micr_status);
+}
+
+#ifdef CONFIG_OF_MDIO
+static int dp83867_of_init(struct phy_device *phydev)
+{
+	struct dp83867_private *dp83867 = phydev->priv;
+	struct device *dev = &phydev->dev;
+	struct device_node *of_node = dev->of_node;
+	int ret;
+
+	if (!of_node && dev->parent->of_node)
+		of_node = dev->parent->of_node;
+
+	if (!phydev->dev.of_node)
+		return -ENODEV;
+
+	ret = of_property_read_u32(of_node, "ti,rx_int_delay",
+				   &dp83867->rx_id_delay);
+	if (ret)
+		return ret;
+
+	ret = of_property_read_u32(of_node, "ti,tx_int_delay",
+				   &dp83867->tx_id_delay);
+	if (ret)
+		return ret;
+
+	ret = of_property_read_u32(of_node, "ti,fifo_depth",
+				   &dp83867->fifo_depth);
+	if (ret)
+		return ret;
+
+	return 0;
+}
+#else
+static int dp83867_of_init(struct phy_device *phydev)
+{
+	return 0;
+}
+#endif /* CONFIG_OF_MDIO */
+
+static int dp83867_config_init(struct phy_device *phydev)
+{
+	struct dp83867_private *dp83867;
+	int ret;
+	u16 val, delay;
+
+	if (!phydev->priv) {
+		dp83867 = devm_kzalloc(&phydev->dev, sizeof(*dp83867),
+				       GFP_KERNEL);
+		if (!dp83867)
+			return -ENOMEM;
+
+		phydev->priv = dp83867;
+		ret = dp83867_of_init(phydev);
+		if (ret)
+			return ret;
+	} else {
+		dp83867 = (struct dp83867_private *)phydev->priv;
+	}
+
+	if (phy_interface_is_rgmii(phydev)) {
+		ret = phy_write(phydev, MII_DP83867_PHYCTRL,
+			(dp83867->fifo_depth << DP83867_PHYCR_FIFO_DEPTH_SHIFT));
+		if (ret)
+			return ret;
+	}
+
+	if ((phydev->interface >= PHY_INTERFACE_MODE_RGMII_ID) ||
+	    (phydev->interface <= PHY_INTERFACE_MODE_RGMII_RXID)) {
+		val = phy_read_mmd_indirect(phydev, DP83867_RGMIICTL,
+					    DP83867_DEVADDR, phydev->addr);
+
+		if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID)
+			val |= (DP83867_RGMII_TX_CLK_DELAY_EN | DP83867_RGMII_RX_CLK_DELAY_EN);
+
+		if (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID)
+			val |= DP83867_RGMII_TX_CLK_DELAY_EN;
+
+		if (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID)
+			val |= DP83867_RGMII_RX_CLK_DELAY_EN;
+
+		phy_write_mmd_indirect(phydev, DP83867_RGMIICTL,
+				       DP83867_DEVADDR, phydev->addr, val);
+
+		delay = (dp83867->rx_id_delay |
+			(dp83867->tx_id_delay << DP83867_RGMII_TX_CLK_DELAY_SHIFT));
+
+		phy_write_mmd_indirect(phydev, DP83867_RGMIIDCTL,
+				       DP83867_DEVADDR, phydev->addr, delay);
+	}
+
+	return 0;
+}
+
+static int dp83867_phy_reset(struct phy_device *phydev)
+{
+	int err;
+
+	err = phy_write(phydev, DP83867_CTRL, DP83867_SW_RESET);
+	if (err < 0)
+		return err;
+
+	return dp83867_config_init(phydev);
+}
+
+static struct phy_driver dp83867_driver[] = {
+	{
+		.phy_id		= DP83867_PHY_ID,
+		.phy_id_mask	= 0xfffffff0,
+		.name		= "TI DP83867",
+		.features	= PHY_GBIT_FEATURES,
+		.flags		= PHY_HAS_INTERRUPT,
+
+		.config_init	= dp83867_config_init,
+		.soft_reset	= dp83867_phy_reset,
+
+		/* IRQ related */
+		.ack_interrupt	= dp83867_ack_interrupt,
+		.config_intr	= dp83867_config_intr,
+
+		.config_aneg	= genphy_config_aneg,
+		.read_status	= genphy_read_status,
+		.suspend	= genphy_suspend,
+		.resume		= genphy_resume,
+
+		.driver		= {.owner = THIS_MODULE,}
+	},
+};
+module_phy_driver(dp83867_driver);
+
+static struct mdio_device_id __maybe_unused dp83867_tbl[] = {
+	{ DP83867_PHY_ID, 0xfffffff0 },
+	{ }
+};
+
+MODULE_DEVICE_TABLE(mdio, dp83867_tbl);
+
+MODULE_DESCRIPTION("Texas Instruments DP83867 PHY driver");
+MODULE_AUTHOR("Dan Murphy <dmurphy@ti.com");
+MODULE_LICENSE("GPL");
diff --git a/include/dt-bindings/net/ti-dp83867.h b/include/dt-bindings/net/ti-dp83867.h
new file mode 100644
index 0000000..172744a
--- /dev/null
+++ b/include/dt-bindings/net/ti-dp83867.h
@@ -0,0 +1,45 @@
+/*
+ * Device Tree constants for the Texas Instruments DP83867 PHY
+ *
+ * Author: Dan Murphy <dmurphy@ti.com>
+ *
+ * Copyright:   (C) 2015 Texas Instruments, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+
+#ifndef _DT_BINDINGS_TI_DP83867_H
+#define _DT_BINDINGS_TI_DP83867_H
+
+/* PHY CTRL bits */
+#define DP83867_PHYCR_FIFO_DEPTH_3_B_NIB	0x00
+#define DP83867_PHYCR_FIFO_DEPTH_4_B_NIB	0x01
+#define DP83867_PHYCR_FIFO_DEPTH_6_B_NIB	0x02
+#define DP83867_PHYCR_FIFO_DEPTH_8_B_NIB	0x03
+
+/* RGMIIDCTL internal delay for rx and tx */
+#define	DP83867_RGMIIDCTL_250_PS	0x0
+#define	DP83867_RGMIIDCTL_500_PS	0x1
+#define	DP83867_RGMIIDCTL_750_PS	0x2
+#define	DP83867_RGMIIDCTL_1_NS		0x3
+#define	DP83867_RGMIIDCTL_1_25_NS	0x4
+#define	DP83867_RGMIIDCTL_1_50_NS	0x5
+#define	DP83867_RGMIIDCTL_1_75_NS	0x6
+#define	DP83867_RGMIIDCTL_2_00_NS	0x7
+#define	DP83867_RGMIIDCTL_2_25_NS	0x8
+#define	DP83867_RGMIIDCTL_2_50_NS	0x9
+#define	DP83867_RGMIIDCTL_2_75_NS	0xa
+#define	DP83867_RGMIIDCTL_3_00_NS	0xb
+#define	DP83867_RGMIIDCTL_3_25_NS	0xc
+#define	DP83867_RGMIIDCTL_3_50_NS	0xd
+#define	DP83867_RGMIIDCTL_3_75_NS	0xe
+#define	DP83867_RGMIIDCTL_4_00_NS	0xf
+
+#endif
-- 
1.9.1
