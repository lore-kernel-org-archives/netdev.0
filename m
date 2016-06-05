From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH 2/2] NET: PHY: Intel XWAY: add LED configuration support
Date: Sun,  5 Jun 2016 23:45:50 +0200
Message-ID: <1465163150-21429-3-git-send-email-hauke@hauke-m.de>
References: <1465163150-21429-1-git-send-email-hauke@hauke-m.de>
Cc: alexander.stein@systec-electronic.com, netdev@vger.kernel.org,
	andrew@lunn.ch, john@phrozen.org, openwrt@kresin.me,
	hauke.mehrtens@intel.com, daniel.schwierzeck@gmail.com,
	eckert.florian@googlemail.com, devicetree@vger.kernel.org,
	thomas.langer@intel.com, Hauke Mehrtens <hauke@hauke-m.de>
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from hauke-m.de ([5.39.93.123]:50858 "EHLO hauke-m.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752760AbcFEVqI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jun 2016 17:46:08 -0400
In-Reply-To: <1465163150-21429-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes it possible to configure the behavior of the LEDs connected
to a PHY. The LEDs are controlled by the chip, this makes it possible
to configure the behavior when the hardware should activate and
deactivate the LEDs.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 .../devicetree/bindings/phy/intel-xway.txt         |  77 +++++++++++
 drivers/net/phy/intel-xway.c                       | 152 +++++++++++++++++++++
 2 files changed, 229 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/phy/intel-xway.txt

diff --git a/Documentation/devicetree/bindings/phy/intel-xway.txt b/Documentation/devicetree/bindings/phy/intel-xway.txt
new file mode 100644
index 0000000..02891c4
--- /dev/null
+++ b/Documentation/devicetree/bindings/phy/intel-xway.txt
@@ -0,0 +1,77 @@
+Intel XWAY Ethernet PHY binding
+------------------------------
+
+This supports the Intel XWAY (former Lantiq) 11G and 22E PHYs. These
+PHYs are also named PEF 7061, PEF 7071 and PEF 7072.
+
+Required properties:
+ - compatible:	should be "ethernet-phy-ieee802.3-c22"
+ - reg:		MDIO address of this PHY
+
+
+LEDs:
+The PEF 7071 PHY supports 3 LEDs, the PEF 7072 PHY supports 4 LEDs. Use
+one subnode for each LED. By default the LEDs 0, 1 and 2 are switched
+to be constant on when a 10MBit/s, 100MBit/s or 1000MBit/s link is
+detected and they blink when TX or RX traffic is detected. All 3 LEDs
+are doing the same as most known devices only have one LED.
+
+To change the behavior create a subnode with the following attributes:
+
+Required properties:
+ - compatible: 	should be: "phy,led"
+ - reg:		led number
+
+optional properties:
+ - led-const-on:	Conditions when being constant on
+			Possible options are one of these:
+			LED_LINK10, LED_LINK100 and LED_LINK1000, or
+			some of these 3 values connected with OR.
+			PHY_LED_PDOWN, PHY_LED_EEE, PHY_LED_ANEG,
+			PHY_LED_ABIST, PHY_LED_CDIAG, PHY_LED_COPPER,
+			PHY_LED_FIBER.
+ - led-pulse:		Conditions when led is pulsed
+			The following values can be connected with OR:
+			PHY_LED_TXACT, PHY_LED_RXACT, PHY_LED_COL
+ - led-blink-slow:	Conditions when led should blink with 2Hz:
+			Possible options are one of these:
+			LED_LINK10, LED_LINK100 and LED_LINK1000, or
+			some of these 3 values connected with OR.
+			PHY_LED_PDOWN, PHY_LED_EEE, PHY_LED_ANEG,
+			PHY_LED_ABIST, PHY_LED_CDIAG.
+ - led-blink-fast:	Conditions when led should blink with 16Hz:
+			Possible options are one of these:
+			LED_LINK10, LED_LINK100 and LED_LINK1000, or
+			some of these 3 values connected with OR.
+			PHY_LED_PDOWN, PHY_LED_EEE, PHY_LED_ANEG,
+			PHY_LED_ABIST, PHY_LED_CDIAG.
+
+When multiple properties are set they are applied with the following priority:
+ 1. led-pulse
+ 2. led-blink-fast
+ 3. led-blink-slow
+ 4. led-const-on
+ 5. off
+
+
+Example:
+
+#include <dt-bindings/phy/phy-leds.h>
+phy@0 {
+	compatible = "intel,phy11g", "ethernet-phy-ieee802.3-c22";
+	reg = <0x0>;
+	#address-cells = <1>;
+	#size-cells = <0>;
+	led@0 {
+		compatible = "phy,led";
+		reg = <0>;
+		led-const-on = <(PHY_LED_LINK10 | PHY_LED_LINK100 | PHY_LED_LINK1000)>;
+		led-pulse = <(PHY_LED_TXACT | PHY_LED_RXACT)>;
+	};
+	led@2 {
+		compatible = "phy,led";
+		reg = <2>;
+		led-blink-slow = <PHY_LED_EEE>;
+		led-blink-fast = <PHY_LED_PDOWN>;
+	};
+};
diff --git a/drivers/net/phy/intel-xway.c b/drivers/net/phy/intel-xway.c
index c300ab5..6469ded 100644
--- a/drivers/net/phy/intel-xway.c
+++ b/drivers/net/phy/intel-xway.c
@@ -17,6 +17,7 @@
 #include <linux/module.h>
 #include <linux/phy.h>
 #include <linux/of.h>
+#include <dt-bindings/phy/phy-leds.h>
 
 #define XWAY_MDIO_IMASK			0x19	/* interrupt mask */
 #define XWAY_MDIO_ISTAT			0x1A	/* interrupt status */
@@ -152,11 +153,158 @@
 #define PHY_ID_PHY11G_VR9		0xD565A409
 #define PHY_ID_PHY22F_VR9		0xD565A419
 
+static void xway_gphy_config_led(struct phy_device *phydev,
+				 struct device_node *led_np)
+{
+	const __be32 *addr, *blink_fast_p, *const_on_p, *pulse_p, *blink_slow_p;
+	u32 num, blink_fast, const_on, pulse, blink_slow;
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
+	ledxh = XWAY_MMD_LEDxH_BLINKF_NONE | XWAY_MMD_LEDxH_CON_LINK10XX;
+	blink_fast_p = of_get_property(led_np, "led-blink-fast", NULL);
+	if (blink_fast_p) {
+		ledxh &= ~XWAY_MMD_LEDxH_BLINKF_MASK;
+		blink_fast = be32_to_cpu(*blink_fast_p);
+		if ((blink_fast & PHY_LED_LINK10) &&
+		    (blink_fast & PHY_LED_LINK100) &&
+		    (blink_fast & PHY_LED_LINK1000)) {
+			ledxh |= XWAY_MMD_LEDxH_BLINKF_LINK10XX;
+		} else if ((blink_fast & PHY_LED_LINK10) &&
+			   (blink_fast & PHY_LED_LINK1000)) {
+			ledxh |= XWAY_MMD_LEDxH_BLINKF_LINK10_0;
+		} else if ((blink_fast & PHY_LED_LINK10) &&
+			   (blink_fast & PHY_LED_LINK100)) {
+			ledxh |= XWAY_MMD_LEDxH_BLINKF_LINK10X;
+		} else if ((blink_fast & PHY_LED_LINK100) &&
+			   (blink_fast & PHY_LED_LINK1000)) {
+			ledxh |= XWAY_MMD_LEDxH_BLINKF_LINK100X;
+		} else if (blink_fast & PHY_LED_LINK10) {
+			ledxh |= XWAY_MMD_LEDxH_BLINKF_LINK10;
+		} else if (blink_fast & PHY_LED_LINK100) {
+			ledxh |= XWAY_MMD_LEDxH_BLINKF_LINK100;
+		} else if (blink_fast & PHY_LED_LINK1000) {
+			ledxh |= XWAY_MMD_LEDxH_BLINKF_LINK1000;
+		} else if (blink_fast & PHY_LED_PDOWN) {
+			ledxh |= XWAY_MMD_LEDxH_BLINKF_PDOWN;
+		} else if (blink_fast & PHY_LED_EEE) {
+			ledxh |= XWAY_MMD_LEDxH_BLINKF_EEE;
+		} else if (blink_fast & PHY_LED_ANEG) {
+			ledxh |= XWAY_MMD_LEDxH_BLINKF_ANEG;
+		} else if (blink_fast & PHY_LED_ABIST) {
+			ledxh |= XWAY_MMD_LEDxH_BLINKF_ABIST;
+		} else if (blink_fast & PHY_LED_CDIAG) {
+			ledxh |= XWAY_MMD_LEDxH_BLINKF_CDIAG;
+		}
+	}
+	const_on_p = of_get_property(led_np, "led-const-on", NULL);
+	if (const_on_p) {
+		ledxh &= ~XWAY_MMD_LEDxH_CON_MASK;
+		const_on = be32_to_cpu(*const_on_p);
+		if ((const_on & PHY_LED_LINK10) &&
+		    (const_on & PHY_LED_LINK100) &&
+		    (const_on & PHY_LED_LINK1000)) {
+			ledxh |= XWAY_MMD_LEDxH_CON_LINK10XX;
+		} else if ((const_on & PHY_LED_LINK10) &&
+			   (const_on & PHY_LED_LINK1000)) {
+			ledxh |= XWAY_MMD_LEDxH_CON_LINK10_0;
+		} else if ((const_on & PHY_LED_LINK10) &&
+			   (const_on & PHY_LED_LINK100)) {
+			ledxh |= XWAY_MMD_LEDxH_CON_LINK10X;
+		} else if ((const_on & PHY_LED_LINK100) &&
+			   (const_on & PHY_LED_LINK1000)) {
+			ledxh |= XWAY_MMD_LEDxH_CON_LINK100X;
+		} else if (const_on & PHY_LED_LINK10) {
+			ledxh |= XWAY_MMD_LEDxH_CON_LINK10;
+		} else if (const_on & PHY_LED_LINK100) {
+			ledxh |= XWAY_MMD_LEDxH_CON_LINK100;
+		} else if (const_on & PHY_LED_LINK1000) {
+			ledxh |= XWAY_MMD_LEDxH_CON_LINK1000;
+		} else if (const_on & PHY_LED_PDOWN) {
+			ledxh |= XWAY_MMD_LEDxH_CON_PDOWN;
+		} else if (const_on & PHY_LED_EEE) {
+			ledxh |= XWAY_MMD_LEDxH_CON_EEE;
+		} else if (const_on & PHY_LED_ANEG) {
+			ledxh |= XWAY_MMD_LEDxH_CON_ANEG;
+		} else if (const_on & PHY_LED_ABIST) {
+			ledxh |= XWAY_MMD_LEDxH_CON_ABIST;
+		} else if (const_on & PHY_LED_CDIAG) {
+			ledxh |= XWAY_MMD_LEDxH_CON_CDIAG;
+		} else if (const_on & PHY_LED_COPPER) {
+			ledxh |= XWAY_MMD_LEDxH_CON_COPPER;
+		} else if (const_on & PHY_LED_FIBER) {
+			ledxh |= XWAY_MMD_LEDxH_CON_FIBER;
+		}
+	}
+	phy_write_mmd_indirect(phydev, XWAY_MMD_LED0H + (num * 2),
+			       MDIO_MMD_VEND2, ledxh);
+
+	ledxl = XWAY_MMD_LEDxL_PULSE_TXACT | XWAY_MMD_LEDxL_PULSE_RXACT |
+		XWAY_MMD_LEDxL_BLINKS_NONE;
+	pulse_p = of_get_property(led_np, "led-pulse", NULL);
+	if (pulse_p) {
+		ledxl &= ~XWAY_MMD_LEDxL_PULSE_MASK;
+		pulse = be32_to_cpu(*pulse_p);
+		if (pulse & PHY_LED_TXACT)
+			ledxl |= XWAY_MMD_LEDxL_PULSE_TXACT;
+		if (pulse & PHY_LED_RXACT)
+			ledxl |= XWAY_MMD_LEDxL_PULSE_RXACT;
+		if (pulse & PHY_LED_COL)
+			ledxl |= XWAY_MMD_LEDxL_PULSE_COL;
+	}
+	blink_slow_p = of_get_property(led_np, "led-blink-slow", NULL);
+	if (blink_slow_p) {
+		ledxl &= ~XWAY_MMD_LEDxL_BLINKS_MASK;
+		blink_slow = be32_to_cpu(*blink_slow_p);
+		if ((blink_slow & PHY_LED_LINK10) &&
+		    (blink_slow & PHY_LED_LINK100) &&
+		    (blink_slow & PHY_LED_LINK1000)) {
+			ledxl |= XWAY_MMD_LEDxL_BLINKS_LINK10XX;
+		} else if ((blink_slow & PHY_LED_LINK10) &&
+			   (blink_slow & PHY_LED_LINK1000)) {
+			ledxl |= XWAY_MMD_LEDxL_BLINKS_LINK10_0;
+		} else if ((blink_slow & PHY_LED_LINK10) &&
+			   (blink_slow & PHY_LED_LINK100)) {
+			ledxl |= XWAY_MMD_LEDxL_BLINKS_LINK10X;
+		} else if ((blink_slow & PHY_LED_LINK100) &&
+			   (blink_slow & PHY_LED_LINK1000)) {
+			ledxl |= XWAY_MMD_LEDxL_BLINKS_LINK100X;
+		} else if (blink_slow & PHY_LED_LINK10) {
+			ledxl |= XWAY_MMD_LEDxL_BLINKS_LINK10;
+		} else if (blink_slow & PHY_LED_LINK100) {
+			ledxl |= XWAY_MMD_LEDxL_BLINKS_LINK100;
+		} else if (blink_slow & PHY_LED_LINK1000) {
+			ledxl |= XWAY_MMD_LEDxL_BLINKS_LINK1000;
+		} else if (blink_slow & PHY_LED_PDOWN) {
+			ledxl |= XWAY_MMD_LEDxL_BLINKS_PDOWN;
+		} else if (blink_slow & PHY_LED_EEE) {
+			ledxl |= XWAY_MMD_LEDxL_BLINKS_EEE;
+		} else if (blink_slow & PHY_LED_ANEG) {
+			ledxl |= XWAY_MMD_LEDxL_BLINKS_ANEG;
+		} else if (blink_slow & PHY_LED_ABIST) {
+			ledxl |= XWAY_MMD_LEDxL_BLINKS_ABIST;
+		} else if (blink_slow & PHY_LED_CDIAG) {
+			ledxl |= XWAY_MMD_LEDxL_BLINKS_CDIAG;
+		}
+	}
+	phy_write_mmd_indirect(phydev, XWAY_MMD_LED0L + (num * 2),
+			       MDIO_MMD_VEND2, ledxl);
+}
+
 static int xway_gphy_config_init(struct phy_device *phydev)
 {
 	int err;
 	u32 ledxh;
 	u32 ledxl;
+	struct device_node *led_np;
 
 	/* Mask all interrupts */
 	err = phy_write(phydev, XWAY_MDIO_IMASK, 0);
@@ -190,6 +338,10 @@ static int xway_gphy_config_init(struct phy_device *phydev)
 	phy_write_mmd_indirect(phydev, XWAY_MMD_LED2H, MDIO_MMD_VEND2, ledxh);
 	phy_write_mmd_indirect(phydev, XWAY_MMD_LED2L, MDIO_MMD_VEND2, ledxl);
 
+	for_each_child_of_node(phydev->mdio.dev.of_node, led_np)
+		if (of_device_is_compatible(led_np, "phy,led"))
+			xway_gphy_config_led(phydev, led_np);
+
 	return 0;
 }
 
-- 
2.8.1
