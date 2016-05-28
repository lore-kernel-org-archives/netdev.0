From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [RFC v2 2/2] NET: PHY: lantiq: add LED configuration support
Date: Sat, 28 May 2016 18:59:01 +0200
Message-ID: <1464454741-18557-2-git-send-email-hauke@hauke-m.de>
References: <1464454741-18557-1-git-send-email-hauke@hauke-m.de>
Cc: alexander.stein@systec-electronic.com, netdev@vger.kernel.org,
	andrew@lunn.ch, john@phrozen.org, openwrt@kresin.me,
	hauke.mehrtens@intel.com, daniel.schwierzeck@gmail.com,
	eckert.florian@googlemail.com, Hauke Mehrtens <hauke@hauke-m.de>
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from hauke-m.de ([5.39.93.123]:38499 "EHLO hauke-m.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752870AbcE1Q7M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 May 2016 12:59:12 -0400
In-Reply-To: <1464454741-18557-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes it possible to configure the behavior of the LEDs connected
to a PHY. The LEDs are controlled by the chip, this makes it possible
to configure the behavior when the hardware should activate and
deactivate the LEDs.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 Documentation/devicetree/bindings/phy/phy-leds.txt |  45 ++++++
 drivers/net/phy/lantiq.c                           | 152 +++++++++++++++++++++
 include/dt-bindings/phy/phy-leds.h                 |  27 ++++
 3 files changed, 224 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/phy/phy-leds.txt
 create mode 100644 include/dt-bindings/phy/phy-leds.h

diff --git a/Documentation/devicetree/bindings/phy/phy-leds.txt b/Documentation/devicetree/bindings/phy/phy-leds.txt
new file mode 100644
index 0000000..6d9f5f3
--- /dev/null
+++ b/Documentation/devicetree/bindings/phy/phy-leds.txt
@@ -0,0 +1,45 @@
+LED configuration for Ethernet phys
+
+Property names:
+	led-const-on: conditions the LED should be constant on
+	led-pules: condition the LED should be pulsed on
+	led-blink-slow: condition the LED should slowly blink
+	led-blink-fast: condition the LED should fast blink
+
+property values:
+	PHY_LED_OFF:		LED is off
+	PHY_LED_LINK10:		link is 10MBit/s
+	PHY_LED_LINK100:	link is 100MBit/s
+	PHY_LED_LINK1000:	link is 1000MBit/s
+	PHY_LED_PDOWN:		link is powered down
+	PHY_LED_EEE:		link is in EEE mode
+	PHY_LED_ANEG:		auto negotiation is running
+	PHY_LED_ABIST:		analog self testing is running
+	PHY_LED_CDIAG:		cable diagnostics is running
+	PHY_LED_COPPER:		copper interface detected
+	PHY_LED_FIBER:		fiber interface detected
+	PHY_LED_TXACT:		Transmit activity
+	PHY_LED_RXACT:		Receive activity
+	PHY_LED_COL:		Collision
+
+Example:
+
+#include <dt-bindings/phy/phy-leds.h>
+phy@0 {
+	compatible = "ethernet-phy-ieee802.3-c22";
+	reg = <0x0>;
+	#address-cells = <1>;
+	#size-cells = <0>;
+	led@0 {
+		compatible = "phy,led";
+		reg = <0>;
+		led-const-on = <(PHY_LED_LINK10 | PHY_LED_LINK100 | PHY_LED_LINK1000)>;
+		led-pules = <(PHY_LED_TXACT | PHY_LED_RXACT)>;
+	};
+	led@2 {
+		compatible = "phy,led";
+		reg = <2>;
+		led-blink-slow = <PHY_LED_EEE>;
+		led-blink-fast = <PHY_LED_PDOWN>;
+	};
+};
diff --git a/drivers/net/phy/lantiq.c b/drivers/net/phy/lantiq.c
index a2adc4b..2d00b31 100644
--- a/drivers/net/phy/lantiq.c
+++ b/drivers/net/phy/lantiq.c
@@ -17,6 +17,7 @@
 #include <linux/module.h>
 #include <linux/phy.h>
 #include <linux/of.h>
+#include <dt-bindings/phy/phy-leds.h>
 
 #define LANTIQ_MDIO_IMASK		0x19	/* interrupt mask */
 #define LANTIQ_MDIO_ISTAT		0x1A	/* interrupt status */
@@ -152,11 +153,158 @@
 #define PHY_ID_PHY11G_VR9			0xD565A409
 #define PHY_ID_PHY22F_VR9			0xD565A419
 
+static void lantiq_gphy_config_led(struct phy_device *phydev,
+				   struct device_node *led_np)
+{
+	const __be32 *addr, *blink_fast_p, *const_on_p, *pules_p, *blink_slow_p;
+	u32 num, blink_fast, const_on, pules, blink_slow;
+	u32 ledxl;
+	u32 ledxh;
+
+	addr = of_get_property(led_np, "reg", NULL);
+	if (!addr)
+		return;
+	num = be32_to_cpu(*addr);
+
+	if (num < 0 || num > 3)
+		return;
+
+	ledxh = LANTIQ_MMD_LEDxH_BLINKF_NONE | LANTIQ_MMD_LEDxH_CON_LINK10XX;
+	blink_fast_p = of_get_property(led_np, "led-blink-fast", NULL);
+	if (blink_fast_p) {
+		ledxh &= ~LANTIQ_MMD_LEDxH_BLINKF_MASK;
+		blink_fast = be32_to_cpu(*blink_fast_p);
+		if ((blink_fast & PHY_LED_LINK10) &&
+		    (blink_fast & PHY_LED_LINK100) &&
+		    (blink_fast & PHY_LED_LINK1000)) {
+			ledxh |= LANTIQ_MMD_LEDxH_BLINKF_LINK10XX;
+		} else if ((blink_fast & PHY_LED_LINK10) &&
+			   (blink_fast & PHY_LED_LINK1000)) {
+			ledxh |= LANTIQ_MMD_LEDxH_BLINKF_LINK10_0;
+		} else if ((blink_fast & PHY_LED_LINK10) &&
+			   (blink_fast & PHY_LED_LINK100)) {
+			ledxh |= LANTIQ_MMD_LEDxH_BLINKF_LINK10X;
+		} else if ((blink_fast & PHY_LED_LINK100) &&
+			   (blink_fast & PHY_LED_LINK1000)) {
+			ledxh |= LANTIQ_MMD_LEDxH_BLINKF_LINK100X;
+		} else if (blink_fast & PHY_LED_LINK10) {
+			ledxh |= LANTIQ_MMD_LEDxH_BLINKF_LINK10;
+		} else if (blink_fast & PHY_LED_LINK100) {
+			ledxh |= LANTIQ_MMD_LEDxH_BLINKF_LINK100;
+		} else if (blink_fast & PHY_LED_LINK1000) {
+			ledxh |= LANTIQ_MMD_LEDxH_BLINKF_LINK1000;
+		} else if (blink_fast & PHY_LED_PDOWN) {
+			ledxh |= LANTIQ_MMD_LEDxH_BLINKF_PDOWN;
+		} else if (blink_fast & PHY_LED_EEE) {
+			ledxh |= LANTIQ_MMD_LEDxH_BLINKF_EEE;
+		} else if (blink_fast & PHY_LED_ANEG) {
+			ledxh |= LANTIQ_MMD_LEDxH_BLINKF_ANEG;
+		} else if (blink_fast & PHY_LED_ABIST) {
+			ledxh |= LANTIQ_MMD_LEDxH_BLINKF_ABIST;
+		} else if (blink_fast & PHY_LED_CDIAG) {
+			ledxh |= LANTIQ_MMD_LEDxH_BLINKF_CDIAG;
+		}
+	}
+	const_on_p = of_get_property(led_np, "led-const-on", NULL);
+	if (const_on_p) {
+		ledxh &= ~LANTIQ_MMD_LEDxH_CON_MASK;
+		const_on = be32_to_cpu(*const_on_p);
+		if ((const_on & PHY_LED_LINK10) &&
+		    (const_on & PHY_LED_LINK100) &&
+		    (const_on & PHY_LED_LINK1000)) {
+			ledxh |= LANTIQ_MMD_LEDxH_CON_LINK10XX;
+		} else if ((const_on & PHY_LED_LINK10) &&
+			   (const_on & PHY_LED_LINK1000)) {
+			ledxh |= LANTIQ_MMD_LEDxH_CON_LINK10_0;
+		} else if ((const_on & PHY_LED_LINK10) &&
+			   (const_on & PHY_LED_LINK100)) {
+			ledxh |= LANTIQ_MMD_LEDxH_CON_LINK10X;
+		} else if ((const_on & PHY_LED_LINK100) &&
+			   (const_on & PHY_LED_LINK1000)) {
+			ledxh |= LANTIQ_MMD_LEDxH_CON_LINK100X;
+		} else if (const_on & PHY_LED_LINK10) {
+			ledxh |= LANTIQ_MMD_LEDxH_CON_LINK10;
+		} else if (const_on & PHY_LED_LINK100) {
+			ledxh |= LANTIQ_MMD_LEDxH_CON_LINK100;
+		} else if (const_on & PHY_LED_LINK1000) {
+			ledxh |= LANTIQ_MMD_LEDxH_CON_LINK1000;
+		} else if (const_on & PHY_LED_PDOWN) {
+			ledxh |= LANTIQ_MMD_LEDxH_CON_PDOWN;
+		} else if (const_on & PHY_LED_EEE) {
+			ledxh |= LANTIQ_MMD_LEDxH_CON_EEE;
+		} else if (const_on & PHY_LED_ANEG) {
+			ledxh |= LANTIQ_MMD_LEDxH_CON_ANEG;
+		} else if (const_on & PHY_LED_ABIST) {
+			ledxh |= LANTIQ_MMD_LEDxH_CON_ABIST;
+		} else if (const_on & PHY_LED_CDIAG) {
+			ledxh |= LANTIQ_MMD_LEDxH_CON_CDIAG;
+		} else if (const_on & PHY_LED_COPPER) {
+			ledxh |= LANTIQ_MMD_LEDxH_CON_COPPER;
+		} else if (const_on & PHY_LED_FIBER) {
+			ledxh |= LANTIQ_MMD_LEDxH_CON_FIBER;
+		}
+	}
+	phy_write_mmd_indirect(phydev, LANTIQ_MMD_LED0H + (num * 2),
+			       MDIO_MMD_VEND2, ledxh);
+
+	ledxl = LANTIQ_MMD_LEDxL_PULSE_TXACT | LANTIQ_MMD_LEDxL_PULSE_RXACT |
+		LANTIQ_MMD_LEDxL_BLINKS_NONE;
+	pules_p = of_get_property(led_np, "led-pules", NULL);
+	if (pules_p) {
+		ledxl &= ~LANTIQ_MMD_LEDxL_PULSE_MASK;
+		pules = be32_to_cpu(*pules_p);
+		if (pules & PHY_LED_TXACT)
+			ledxl |= LANTIQ_MMD_LEDxL_PULSE_TXACT;
+		if (pules & PHY_LED_RXACT)
+			ledxl |= LANTIQ_MMD_LEDxL_PULSE_RXACT;
+		if (pules & PHY_LED_COL)
+			ledxl |= LANTIQ_MMD_LEDxL_PULSE_COL;
+	}
+	blink_slow_p = of_get_property(led_np, "led-blink-slow", NULL);
+	if (blink_slow_p) {
+		ledxl &= ~LANTIQ_MMD_LEDxL_BLINKS_MASK;
+		blink_slow = be32_to_cpu(*blink_slow_p);
+		if ((blink_slow & PHY_LED_LINK10) &&
+		    (blink_slow & PHY_LED_LINK100) &&
+		    (blink_slow & PHY_LED_LINK1000)) {
+			ledxl |= LANTIQ_MMD_LEDxL_BLINKS_LINK10XX;
+		} else if ((blink_slow & PHY_LED_LINK10) &&
+			   (blink_slow & PHY_LED_LINK1000)) {
+			ledxl |= LANTIQ_MMD_LEDxL_BLINKS_LINK10_0;
+		} else if ((blink_slow & PHY_LED_LINK10) &&
+			   (blink_slow & PHY_LED_LINK100)) {
+			ledxl |= LANTIQ_MMD_LEDxL_BLINKS_LINK10X;
+		} else if ((blink_slow & PHY_LED_LINK100) &&
+			   (blink_slow & PHY_LED_LINK1000)) {
+			ledxl |= LANTIQ_MMD_LEDxL_BLINKS_LINK100X;
+		} else if (blink_slow & PHY_LED_LINK10) {
+			ledxl |= LANTIQ_MMD_LEDxL_BLINKS_LINK10;
+		} else if (blink_slow & PHY_LED_LINK100) {
+			ledxl |= LANTIQ_MMD_LEDxL_BLINKS_LINK100;
+		} else if (blink_slow & PHY_LED_LINK1000) {
+			ledxl |= LANTIQ_MMD_LEDxL_BLINKS_LINK1000;
+		} else if (blink_slow & PHY_LED_PDOWN) {
+			ledxl |= LANTIQ_MMD_LEDxL_BLINKS_PDOWN;
+		} else if (blink_slow & PHY_LED_EEE) {
+			ledxl |= LANTIQ_MMD_LEDxL_BLINKS_EEE;
+		} else if (blink_slow & PHY_LED_ANEG) {
+			ledxl |= LANTIQ_MMD_LEDxL_BLINKS_ANEG;
+		} else if (blink_slow & PHY_LED_ABIST) {
+			ledxl |= LANTIQ_MMD_LEDxL_BLINKS_ABIST;
+		} else if (blink_slow & PHY_LED_CDIAG) {
+			ledxl |= LANTIQ_MMD_LEDxL_BLINKS_CDIAG;
+		}
+	}
+	phy_write_mmd_indirect(phydev, LANTIQ_MMD_LED0L + (num * 2),
+			       MDIO_MMD_VEND2, ledxl);
+}
+
 static int lantiq_gphy_config_init(struct phy_device *phydev)
 {
 	int err;
 	u32 ledxh;
 	u32 ledxl;
+	struct device_node *led_np;
 
 	/* Mask all interrupts */
 	err = phy_write(phydev, LANTIQ_MDIO_IMASK, 0);
@@ -190,6 +338,10 @@ static int lantiq_gphy_config_init(struct phy_device *phydev)
 	phy_write_mmd_indirect(phydev, LANTIQ_MMD_LED2H, MDIO_MMD_VEND2, ledxh);
 	phy_write_mmd_indirect(phydev, LANTIQ_MMD_LED2L, MDIO_MMD_VEND2, ledxl);
 
+	for_each_child_of_node(phydev->mdio.dev.of_node, led_np)
+		if (of_device_is_compatible(led_np, "phy,led"))
+			lantiq_gphy_config_led(phydev, led_np);
+
 	return 0;
 }
 
diff --git a/include/dt-bindings/phy/phy-leds.h b/include/dt-bindings/phy/phy-leds.h
new file mode 100644
index 0000000..6e43245
--- /dev/null
+++ b/include/dt-bindings/phy/phy-leds.h
@@ -0,0 +1,27 @@
+/*
+ * Copyright (C) 2016 Hauke Mehrtens <hauke@hauke-m.de>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
+
+#ifndef _DT_BINDINGS_PHY_LEDS
+#define _DT_BINDINGS_PHY_LEDS
+
+#define PHY_LED_OFF		(1 << 0)	/* is off */
+#define PHY_LED_LINK10		(1 << 1)	/* link is 10MBit/s */
+#define PHY_LED_LINK100		(1 << 2)	/* link is 100MBit/s */
+#define PHY_LED_LINK1000	(1 << 3)	/* link is 1000MBit/s */
+#define PHY_LED_PDOWN		(1 << 4)	/* link is powered down */
+#define PHY_LED_EEE		(1 << 5)	/* link is in EEE mode */
+#define PHY_LED_ANEG		(1 << 6)	/* auto negotiation is running */
+#define PHY_LED_ABIST		(1 << 7)	/* analog self testing is running */
+#define PHY_LED_CDIAG		(1 << 8)	/* cable diagnostics is running */
+#define PHY_LED_COPPER		(1 << 9)	/* copper interface detected */
+#define PHY_LED_FIBER		(1 << 10)	/* fiber interface detected */
+#define PHY_LED_TXACT		(1 << 11)	/* Transmit activity */
+#define PHY_LED_RXACT		(1 << 12)	/* Receive activity */
+#define PHY_LED_COL		(1 << 13)	/* Collision */
+
+#endif /* _DT_BINDINGS_PHY_LEDS */
-- 
2.8.1
