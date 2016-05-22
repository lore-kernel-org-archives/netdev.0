From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [RFC] NET: PHY: adds driver for Lantiq PHY11G
Date: Sun, 22 May 2016 21:33:51 +0200
Message-ID: <1463945631-29273-1-git-send-email-hauke@hauke-m.de>
Cc: alexander.stein@systec-electronic.com, netdev@vger.kernel.org,
	andrew@lunn.ch, john@phrozen.org, openwrt@kresin.me,
	hauke.mehrtens@intel.com, Hauke Mehrtens <hauke@hauke-m.de>
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from hauke-m.de ([5.39.93.123]:51564 "EHLO hauke-m.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752449AbcEVTeH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 May 2016 15:34:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Supports the Lantiq / Intel CHD 11G and 22E PHYs.
These PHYs are also named PEF 7061, PEF 7071, PEF 7072

Signed-off-by: John Crispin <john@phrozen.org>
Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---

This is based on a driver from OpenWrt / LEDE. This is send as a RFC
because the merge window is open now and it adds a new driver. This
patch was cleaned up on request of Alexander.


 .../devicetree/bindings/phy/phy-lanitq.txt         | 216 +++++++++++++++++
 drivers/net/phy/Kconfig                            |   6 +
 drivers/net/phy/Makefile                           |   1 +
 drivers/net/phy/lantiq.c                           | 269 +++++++++++++++++++++
 4 files changed, 492 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/phy/phy-lanitq.txt
 create mode 100644 drivers/net/phy/lantiq.c

diff --git a/Documentation/devicetree/bindings/phy/phy-lanitq.txt b/Documentation/devicetree/bindings/phy/phy-lanitq.txt
new file mode 100644
index 0000000..d9746e8
--- /dev/null
+++ b/Documentation/devicetree/bindings/phy/phy-lanitq.txt
@@ -0,0 +1,216 @@
+Lanitq PHY binding
+============================================
+
+This devicetree binding controls the lantiq ethernet phys led functionality.
+
+Example:
+	mdio@0 {
+		#address-cells = <1>;
+		#size-cells = <0>;
+		compatible = "lantiq,xrx200-mdio";
+			phy5: ethernet-phy@5 {
+			reg = <0x1>;
+			compatible = "lantiq,phy11g", "ethernet-phy-ieee802.3-c22";
+		};
+		phy11: ethernet-phy@11 {
+			reg = <0x11>;
+			compatible = "lantiq,phy22f", "ethernet-phy-ieee802.3-c22";
+			lantiq,led2h = <0x00>;
+			lantiq,led2l = <0x03>;
+		};
+		phy12: ethernet-phy@12 {
+			reg = <0x12>;
+			compatible = "lantiq,phy22f", "ethernet-phy-ieee802.3-c22";
+			lantiq,led1h = <0x00>;
+			lantiq,led1l = <0x03>;
+		};
+		phy13: ethernet-phy@13 {
+			reg = <0x13>;
+			compatible = "lantiq,phy22f", "ethernet-phy-ieee802.3-c22";
+			lantiq,led2h = <0x00>;
+			lantiq,led2l = <0x03>;
+		};
+		phy14: ethernet-phy@14 {
+			reg = <0x14>;
+			compatible = "lantiq,phy22f", "ethernet-phy-ieee802.3-c22";
+			lantiq,led1h = <0x00>;
+			lantiq,led1l = <0x03>;
+		};
+	};
+
+Register Description
+============================================
+
+LEDCH:
+
+Name	Hardware Reset Value
+LEDCH	0x00C5
+
+| 15 |    |    |    |    |    |    |  8 |
+=========================================
+|		RES			|
+=========================================
+
+|  7 |    |    |    |    |    |    |  0 |
+=========================================
+|   FBF   |   SBF   |RES |     NACS     |
+=========================================
+
+Field	Bits	Type	Description
+FBC	7:6	RW	Fast Blink Frequency
+			---
+			0x0 (00b) F02HZ 2 Hz blinking frequency
+			0x1 (01b) F04HZ 4 Hz blinking frequency
+			0x2 (10b) F08HZ 8 Hz blinking frequency
+			0x3 (11b) F16HZ 16 Hz blinking frequency
+
+SBF	5:4	RW	Slow Blink Frequency
+			---
+			0x0 (00b) F02HZ 2 Hz blinking frequency
+			0x1 (01b) F04HZ 4 Hz blinking frequency
+			0x2 (10b) F08HZ 8 Hz blinking frequency
+			0x3 (11b) F16HZ 16 Hz blinking frequency
+
+NACS	2:0	RW	Inverse of Scan Function
+			---
+			0x0 (000b) NONE No Function
+			0x1 (001b) LINK Complex function enabled when link is up
+			0x2 (010b) PDOWN Complex function enabled when device is powered-down
+			0x3 (011b) EEE Complex function enabled when device is in EEE mode
+			0x4 (100b) ANEG Complex function enabled when auto-negotiation is running
+			0x5 (101b) ABIST Complex function enabled when analog self-test is running
+			0x6 (110b) CDIAG Complex function enabled when cable diagnostics are running
+			0x7 (111b) TEST Complex function enabled when test mode is running
+
+LEDCL:
+
+Name	Hardware Reset Value
+LEDCL	0x0067
+
+| 15 |    |    |    |    |    |    |  8 |
+=========================================
+|		RES			|
+=========================================
+
+|  7 |    |    |    |    |    |    |  0 |
+=========================================
+|RES |     SCAN     |RES |    CBLINK    |
+=========================================
+
+Field	Bits	Type	Description
+SCAN	6:4	RW	Complex Scan Configuration
+			---
+			000 B NONE No Function
+			001 B LINK Complex function enabled when link is up
+			010 B PDOWN Complex function enabled when device is powered-down
+			011 B EEE Complex function enabled when device is in EEE mode
+			100 B ANEG Complex function enabled when auto-negotiation is running
+			101 B ABIST Complex function enabled when analog self-test is running
+			110 B CDIAG Complex function enabled when cable diagnostics are running
+			111 B TEST Complex function enabled when test mode is running
+
+CBLINK	2:0	RW	Complex Blinking Configuration
+			---
+			000 B NONE No Function
+			001 B LINK Complex function enabled when link is up
+			010 B PDOWN Complex function enabled when device is powered-down
+			011 B EEE Complex function enabled when device is in EEE mode
+			100 B ANEG Complex function enabled when auto-negotiation is running
+			101 B ABIST Complex function enabled when analog self-test is running
+			110 B CDIAG Complex function enabled when cable diagnostics are running
+			111 B TEST Complex function enabled when test mode is running
+
+LEDxH:
+
+Name	Hardware Reset Value
+LED0H	0x0070
+LED1H	0x0020
+LED2H	0x0040
+LED3H	0x0040
+
+| 15 |    |    |    |    |    |    |  8 |
+=========================================
+|		RES			|
+=========================================
+
+|  7 |    |    |    |    |    |    |  0 |
+=========================================
+|        CON        |       BLINKF      |
+=========================================
+
+Field	Bits	Type	Description
+CON	7:4	RW	Constant On Configuration
+			---
+			0x0 (0000b) NONE LED does not light up constantly
+			0x1 (0001b) LINK10 LED is on when link is 10 Mbit/s
+			0x2 (0010b) LINK100 LED is on when link is 100 Mbit/s
+			0x3 (0011b) LINK10X LED is on when link is 10/100 Mbit/s
+			0x4 (0100b) LINK1000 LED is on when link is 1000 Mbit/s
+			0x5 (0101b) LINK10_0 LED is on when link is 10/1000 Mbit/s
+			0x6 (0110b) LINK100X LED is on when link is 100/1000 Mbit/s
+			0x7 (0111b) LINK10XX LED is on when link is 10/100/1000 Mbit/s
+			0x8 (1000b) PDOWN LED is on when device is powered-down
+			0x9 (1001b) EEE LED is on when device is in EEE mode
+			0xA (1010b) ANEG LED is on when auto-negotiation is running
+			0xB (1011b) ABIST LED is on when analog self-test is running
+			0xC (1100b) CDIAG LED is on when cable diagnostics are running
+
+BLINKF	3:0	RW	Fast Blinking Configuration
+			---
+			0x0 (0000b) NONE No Blinking
+			0x1 (0001b) LINK10 Blink when link is 10 Mbit/s
+			0x2 (0010b) LINK100 Blink when link is 100 Mbit/s
+			0x3 (0011b) LINK10X Blink when link is 10/100 Mbit/s
+			0x4 (0100b) LINK1000 Blink when link is 1000 Mbit/s
+			0x5 (0101b) LINK10_0 Blink when link is 10/1000 Mbit/s
+			0x6 (0110b) LINK100X Blink when link is 100/1000 Mbit/s
+			0x7 (0111b) LINK10XX Blink when link is 10/100/1000 Mbit/s
+			0x8 (1000b) PDOWN Blink when device is powered-down
+			0x9 (1001b) EEE Blink when device is in EEE mode
+			0xA (1010b) ANEG Blink when auto-negotiation is running
+			0xB (1011b) ABIST Blink when analog self-test is running
+			0xC (1100b) CDIAG Blink when cable diagnostics are running
+
+LEDxL:
+
+Name	Hardware Reset Value
+LED0L	0x0003
+LED1L	0x0000
+LED2L	0x0000
+LED3L	0x0020
+
+| 15 |    |    |    |    |    |    |  8 |
+=========================================
+|		RES			|
+=========================================
+
+|  7 |    |    |    |    |    |    |  0 |
+=========================================
+|      BLINKS       |       PULSE       |
+=========================================
+
+Field	Bits	Type	Description
+BLINKS	7:4	RW	Slow Blinkin Configuration
+			---
+			0x0 (0000b) NONE No Blinking
+			0x1 (0001b) LINK10 Blink when link is 10 Mbit/s
+			0x2 (0010b) LINK100 Blink when link is 100 Mbit/s
+			0x3 (0011b) LINK10X Blink when link is 10/100 Mbit/s
+			0x4 (0100b) LINK1000 Blink when link is 1000 Mbit/s
+			0x5 (0101b) LINK10_0 Blink when link is 10/1000 Mbit/s
+			0x6 (0110b) LINK100X Blink when link is 100/1000 Mbit/s
+			0x7 (0111b) LINK10XX Blink when link is 10/100/1000 Mbit/s
+			0x8 (1000b) PDOWN Blink when device is powered-down
+			0x9 (1001b) EEE Blink when device is in EEE mode
+			0xA (1010b) ANEG Blink when auto-negotiation is running
+			0xB (1011b) ABIST Blink when analog self-test is running
+			0xC (1100b) CDIAG Blink when cable diagnostics are runningning
+
+PULSE	3:0	RW	Pulsing Configuration
+			The pulse field is a mask field by which certain events can be combined
+			---
+			0x0 (0000b) NONE No pulsing
+			0x1 (0001b) TXACT Transmit activity
+			0x2 (0010b) RXACT Receive activity
+			0x4 (0100b) COL Collision
+			0x8 (1000b) RES Reserved
diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index f0a7702..f3685ef 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -257,6 +257,12 @@ config MDIO_BCM_IPROC
 	  This module provides a driver for the MDIO busses found in the
 	  Broadcom iProc SoC's.
 
+config LANTIQ_PHY
+	tristate "Driver for Lantiq PHYs"
+	---help---
+	  Supports the Lantiq / Intel CHD 11G and 22E PHYs.
+	  These PHYs are also named PEF 7061, PEF 7071 and PEF 7072
+
 endif # PHYLIB
 
 config MICREL_KS8995MA
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 680e88f9..042b0ef6 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -42,3 +42,4 @@ obj-$(CONFIG_MDIO_MOXART)	+= mdio-moxart.o
 obj-$(CONFIG_MDIO_BCM_UNIMAC)	+= mdio-bcm-unimac.o
 obj-$(CONFIG_MICROCHIP_PHY)	+= microchip.o
 obj-$(CONFIG_MDIO_BCM_IPROC)	+= mdio-bcm-iproc.o
+obj-$(CONFIG_LANTIQ_PHY)	+= lantiq.o
diff --git a/drivers/net/phy/lantiq.c b/drivers/net/phy/lantiq.c
new file mode 100644
index 0000000..65a8086
--- /dev/null
+++ b/drivers/net/phy/lantiq.c
@@ -0,0 +1,269 @@
+/*
+ * Copyright (C) 2012 Daniel Schwierzeck <daniel.schwierzeck@googlemail.com>
+ * Copyright (C) 2016 Hauke Mehrtens <hauke@hauke-m.de>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/mdio.h>
+#include <linux/module.h>
+#include <linux/phy.h>
+#include <linux/of.h>
+
+#define MII_VR9_11G_IMASK	0x19	/* interrupt mask */
+#define MII_VR9_11G_ISTAT	0x1a	/* interrupt status */
+
+#define INT_VR9_11G_WOL		BIT(15)	/* Wake-On-LAN */
+#define INT_VR9_11G_ANE		BIT(11)	/* Auto-Neg error */
+#define INT_VR9_11G_ANC		BIT(10)	/* Auto-Neg complete */
+#define INT_VR9_11G_ADSC	BIT(5)	/* Link auto-downspeed detect */
+#define INT_VR9_11G_DXMC	BIT(2)	/* Duplex mode change */
+#define INT_VR9_11G_LSPC	BIT(1)	/* Link speed change */
+#define INT_VR9_11G_LSTC	BIT(0)	/* Link state change */
+#define INT_VR9_11G_MASK	(INT_VR9_11G_LSTC | INT_VR9_11G_ADSC)
+
+#define ADVERTISED_MPD		BIT(10)	/* Multi-port device */
+
+#define PHY_ID_PHY11G_1_3	0x030260D1
+#define PHY_ID_PHY22F_1_3	0x030260E1
+#define PHY_ID_PHY11G_1_4	0xD565A400
+#define PHY_ID_PHY22F_1_4	0xD565A410
+#define PHY_ID_PHY11G_1_5	0xD565A401
+#define PHY_ID_PHY22F_1_5	0xD565A411
+
+static void lantiq_gphy_of_reg_init(struct phy_device *phydev)
+{
+	struct device_node *node = phydev->mdio.dev.of_node;
+	u32 tmp;
+
+	if (!IS_ENABLED(CONFIG_OF_MDIO))
+		return;
+
+	/* store the led values if one was passed by the device tree */
+	if (!of_property_read_u32(node, "lantiq,ledch", &tmp))
+		phy_write_mmd_indirect(phydev, 0x1e0, MDIO_MMD_VEND2, tmp);
+
+	if (!of_property_read_u32(node, "lantiq,ledcl", &tmp))
+		phy_write_mmd_indirect(phydev, 0x1e1, MDIO_MMD_VEND2, tmp);
+
+	if (!of_property_read_u32(node, "lantiq,led0h", &tmp))
+		phy_write_mmd_indirect(phydev, 0x1e2, MDIO_MMD_VEND2, tmp);
+
+	if (!of_property_read_u32(node, "lantiq,led0l", &tmp))
+		phy_write_mmd_indirect(phydev, 0x1e3, MDIO_MMD_VEND2, tmp);
+
+	if (!of_property_read_u32(node, "lantiq,led1h", &tmp))
+		phy_write_mmd_indirect(phydev, 0x1e4, MDIO_MMD_VEND2, tmp);
+
+	if (!of_property_read_u32(node, "lantiq,led1l", &tmp))
+		phy_write_mmd_indirect(phydev, 0x1e5, MDIO_MMD_VEND2, tmp);
+
+	if (!of_property_read_u32(node, "lantiq,led2h", &tmp))
+		phy_write_mmd_indirect(phydev, 0x1e6, MDIO_MMD_VEND2, tmp);
+
+	if (!of_property_read_u32(node, "lantiq,led2l", &tmp))
+		phy_write_mmd_indirect(phydev, 0x1e7, MDIO_MMD_VEND2, tmp);
+
+	/* The LED3 is only available in PEF 7072 package. */
+	if (!of_property_read_u32(node, "lantiq,led3h", &tmp))
+		phy_write_mmd_indirect(phydev, 0x1e8, MDIO_MMD_VEND2, tmp);
+
+	if (!of_property_read_u32(node, "lantiq,led3l", &tmp))
+		phy_write_mmd_indirect(phydev, 0x1e9, MDIO_MMD_VEND2, tmp);
+}
+
+static int lantiq_gphy_config_init(struct phy_device *phydev)
+{
+	int err;
+
+	/* Mask all interrupts */
+	err = phy_write(phydev, MII_VR9_11G_IMASK, 0);
+	if (err)
+		return err;
+
+	/* Clear all pending interrupts */
+	phy_read(phydev, MII_VR9_11G_ISTAT);
+
+	phy_write_mmd_indirect(phydev, 0x1e0, MDIO_MMD_VEND2, 0xc5);
+	phy_write_mmd_indirect(phydev, 0x1e1, MDIO_MMD_VEND2, 0x67);
+	phy_write_mmd_indirect(phydev, 0x1e2, MDIO_MMD_VEND2, 0x42);
+	phy_write_mmd_indirect(phydev, 0x1e3, MDIO_MMD_VEND2, 0x10);
+	phy_write_mmd_indirect(phydev, 0x1e4, MDIO_MMD_VEND2, 0x70);
+	phy_write_mmd_indirect(phydev, 0x1e5, MDIO_MMD_VEND2, 0x03);
+	phy_write_mmd_indirect(phydev, 0x1e6, MDIO_MMD_VEND2, 0x20);
+	phy_write_mmd_indirect(phydev, 0x1e7, MDIO_MMD_VEND2, 0x00);
+	phy_write_mmd_indirect(phydev, 0x1e8, MDIO_MMD_VEND2, 0x40);
+	phy_write_mmd_indirect(phydev, 0x1e9, MDIO_MMD_VEND2, 0x20);
+
+	lantiq_gphy_of_reg_init(phydev);
+
+	return 0;
+}
+
+static int lantiq_gphy14_config_aneg(struct phy_device *phydev)
+{
+	int reg, err;
+
+	/* Advertise as multi-port device, see IEEE802.3-2002 40.5.1.1 */
+	/* This is a workaround for an errata in rev < 1.5 devices */
+	reg = phy_read(phydev, MII_CTRL1000);
+	reg |= ADVERTISED_MPD;
+	err = phy_write(phydev, MII_CTRL1000, reg);
+	if (err)
+		return err;
+
+	return genphy_config_aneg(phydev);
+}
+
+static int lantiq_gphy_ack_interrupt(struct phy_device *phydev)
+{
+	int reg;
+
+	/**
+	 * Possible IRQ numbers:
+	 * - IM3_IRL18 for GPHY0
+	 * - IM3_IRL17 for GPHY1
+	 *
+	 * Due to a silicon bug IRQ lines are not really independent from
+	 * each other. Sometimes the two lines are driven at the same time
+	 * if only one GPHY core raises the interrupt.
+	 */
+	reg = phy_read(phydev, MII_VR9_11G_ISTAT);
+
+	return (reg < 0) ? reg : 0;
+}
+
+static int lantiq_gphy_did_interrupt(struct phy_device *phydev)
+{
+	int reg;
+
+	reg = phy_read(phydev, MII_VR9_11G_ISTAT);
+
+	return reg > 0;
+}
+
+static int lantiq_gphy_config_intr(struct phy_device *phydev)
+{
+	int err;
+
+	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
+		err = phy_write(phydev, MII_VR9_11G_IMASK, INT_VR9_11G_MASK);
+	else
+		err = phy_write(phydev, MII_VR9_11G_IMASK, 0);
+
+	return err;
+}
+
+static struct phy_driver lantiq_gphy[] = {
+	{
+		.phy_id		= PHY_ID_PHY11G_1_3,
+		.phy_id_mask	= 0xffffffff,
+		.name		= "Lantiq XWAY PHY11G (PEF 7071/PEF 7072) v1.3",
+		.features	= (PHY_GBIT_FEATURES | SUPPORTED_Pause),
+		 /* there is an errata regarding irqs in this rev */
+		.flags		= 0,
+		.config_init	= lantiq_gphy_config_init,
+		.config_aneg	= lantiq_gphy14_config_aneg,
+		.read_status	= genphy_read_status,
+		.ack_interrupt	= lantiq_gphy_ack_interrupt,
+		.did_interrupt	= lantiq_gphy_did_interrupt,
+		.config_intr	= lantiq_gphy_config_intr,
+		.suspend	= genphy_suspend,
+		.resume		= genphy_resume,
+	}, {
+		.phy_id		= PHY_ID_PHY22F_1_3,
+		.phy_id_mask	= 0xffffffff,
+		.name		= "Lantiq XWAY PHY22F (PEF 7061) v1.3",
+		.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
+		 /* there is an errata regarding irqs in this rev */
+		.flags		= 0,
+		.config_init	= lantiq_gphy_config_init,
+		.config_aneg	= lantiq_gphy14_config_aneg,
+		.read_status	= genphy_read_status,
+		.ack_interrupt	= lantiq_gphy_ack_interrupt,
+		.did_interrupt	= lantiq_gphy_did_interrupt,
+		.config_intr	= lantiq_gphy_config_intr,
+		.suspend	= genphy_suspend,
+		.resume		= genphy_resume,
+	}, {
+		.phy_id		= PHY_ID_PHY11G_1_4,
+		.phy_id_mask	= 0xffffffff,
+		.name		= "Lantiq XWAY PHY11G (PEF 7071/PEF 7072) v1.4",
+		.features	= (PHY_GBIT_FEATURES | SUPPORTED_Pause),
+		.flags		= PHY_HAS_INTERRUPT,
+		.config_init	= lantiq_gphy_config_init,
+		.config_aneg	= lantiq_gphy14_config_aneg,
+		.read_status	= genphy_read_status,
+		.ack_interrupt	= lantiq_gphy_ack_interrupt,
+		.did_interrupt	= lantiq_gphy_did_interrupt,
+		.config_intr	= lantiq_gphy_config_intr,
+		.suspend	= genphy_suspend,
+		.resume		= genphy_resume,
+	}, {
+		.phy_id		= PHY_ID_PHY22F_1_4,
+		.phy_id_mask	= 0xffffffff,
+		.name		= "Lantiq XWAY PHY22F (PEF 7061) v1.4",
+		.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
+		.flags		= PHY_HAS_INTERRUPT,
+		.config_init	= lantiq_gphy_config_init,
+		.config_aneg	= lantiq_gphy14_config_aneg,
+		.read_status	= genphy_read_status,
+		.ack_interrupt	= lantiq_gphy_ack_interrupt,
+		.did_interrupt	= lantiq_gphy_did_interrupt,
+		.config_intr	= lantiq_gphy_config_intr,
+		.suspend	= genphy_suspend,
+		.resume		= genphy_resume,
+	}, {
+		.phy_id		= PHY_ID_PHY11G_1_5,
+		.phy_id_mask	= 0xffffffff,
+		.name		= "Lantiq XWAY PHY11G (PEF 7071/PEF 7072) v1.5 / v1.6",
+		.features	= (PHY_GBIT_FEATURES | SUPPORTED_Pause),
+		.flags		= PHY_HAS_INTERRUPT,
+		.config_init	= lantiq_gphy_config_init,
+		.config_aneg	= genphy_config_aneg,
+		.read_status	= genphy_read_status,
+		.ack_interrupt	= lantiq_gphy_ack_interrupt,
+		.did_interrupt	= lantiq_gphy_did_interrupt,
+		.config_intr	= lantiq_gphy_config_intr,
+		.suspend	= genphy_suspend,
+		.resume		= genphy_resume,
+	}, {
+		.phy_id		= PHY_ID_PHY22F_1_5,
+		.phy_id_mask	= 0xffffffff,
+		.name		= "Lantiq XWAY PHY22F (PEF 7061) v1.5 / v1.6",
+		.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
+		.flags		= PHY_HAS_INTERRUPT,
+		.config_init	= lantiq_gphy_config_init,
+		.config_aneg	= genphy_config_aneg,
+		.read_status	= genphy_read_status,
+		.ack_interrupt	= lantiq_gphy_ack_interrupt,
+		.did_interrupt	= lantiq_gphy_did_interrupt,
+		.config_intr	= lantiq_gphy_config_intr,
+		.suspend	= genphy_suspend,
+		.resume		= genphy_resume,
+	},
+};
+module_phy_driver(lantiq_gphy);
+
+static struct mdio_device_id __maybe_unused lantiq_gphy_tbl[] = {
+	{ PHY_ID_PHY11G_1_3, 0xffffffff },
+	{ PHY_ID_PHY22F_1_3, 0xffffffff },
+	{ PHY_ID_PHY11G_1_4, 0xffffffff },
+	{ PHY_ID_PHY22F_1_4, 0xffffffff },
+	{ PHY_ID_PHY11G_1_5, 0xffffffff },
+	{ PHY_ID_PHY22F_1_5, 0xffffffff },
+	{ }
+};
+MODULE_DEVICE_TABLE(mdio, lantiq_gphy_tbl);
+
+MODULE_DESCRIPTION("Lantiq PHY driver");
+MODULE_AUTHOR("Daniel Schwierzeck <daniel.schwierzeck@googlemail.com>");
+MODULE_LICENSE("GPL");
-- 
2.8.1
