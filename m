From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: [PATCH net-next] net: phy: Add LED mode driver for Microsemi PHYs.
Date: Tue, 31 Jan 2017 11:16:01 +0530
Message-ID: <1485841561-32056-2-git-send-email-Raju.Lakkaraju@microsemi.com>
References: <1485841561-32056-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <Allan.Nielsen@microsemi.com>,
        <andrew@lunn.ch>, Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>, <devicetree@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0079.outbound.protection.outlook.com ([104.47.40.79]:49856
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751190AbdAaFq2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Jan 2017 00:46:28 -0500
In-Reply-To: <1485841561-32056-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

LED Mode:
Microsemi PHY support 2 LEDs (LED[0] and LED[1]) to display different
status information that can be selected by setting LED mode.

LED Mode parameter (vddmac, led-0-mode) and (vddmac, led-1-mode) get
from Device Tree.

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
---
 .../devicetree/bindings/net/mscc-phy-vsc8531.txt   | 39 ++++++++++++
 drivers/net/phy/mscc.c                             | 72 ++++++++++++++++++++++
 2 files changed, 111 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt b/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
index bdefefc6..1abf4b6 100644
--- a/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
+++ b/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
@@ -27,6 +27,12 @@ Optional properties:
 			  'vddmac'.
 			  Default value is 0%.
 			  Ref: Table:1 - Edge rate change (below).
+- vsc8531,led-0-mode	: LED mode. Specify how the LED[0] should behave.
+			  Allowed values is listed in the 'PHY LED Mode' -
+			  Table 2 (below).  Default value is 1.
+- vsc8531,led-1-mode	: LED mode. Specify how the LED[1] should behave.
+			  Allowed values is listed in the 'PHY LED Mode' -
+			  Table 2 (below).  Default value is 2.
 
 Table: 1 - Edge rate change
 ----------------------------------------------------------------|
@@ -54,10 +60,43 @@ Table: 1 - Edge rate change
 | (slowest)							|
 |---------------------------------------------------------------|
 
+Table: 2 - PHY LED Mode
+|-----------------------------------------------|
+| LINK_ACTIVITY			| 0		|
+|-----------------------------------------------|
+| LINK_1000_ACTIVITY		| 1		|
+|-----------------------------------------------|
+| LINK_100_ACTIVITY		| 2		|
+|-----------------------------------------------|
+| LINK_10_ACTIVITY		| 3		|
+|-----------------------------------------------|
+| LINK_100_1000_ACTIVITY	| 4		|
+|-----------------------------------------------|
+| LINK_10_1000_ACTIVITY		| 5		|
+|-----------------------------------------------|
+| LINK_10_100_ACTIVITY		| 6		|
+|-----------------------------------------------|
+| DUPLEX_COLLISION		| 8		|
+|-----------------------------------------------|
+| COLLISION			| 9		|
+|-----------------------------------------------|
+| ACTIVITY			| 10		|
+|-----------------------------------------------|
+| AUTONEG_FAULT			| 12		|
+|-----------------------------------------------|
+| SERIAL_MODE			| 13		|
+|-----------------------------------------------|
+| FORCE_LED_OFF			| 14		|
+|-----------------------------------------------|
+| FORCE_LED_ON			| 15		|
+|-----------------------------------------------|
+
 Example:
 
         vsc8531_0: ethernet-phy@0 {
                 compatible = "ethernet-phy-id0007.0570";
                 vsc8531,vddmac		= <3300>;
                 vsc8531,edge-slowdown	= <7>;
+                vsc8531,led-0-mode	= <1>;
+                vsc8531,led-1-mode	= <2>;
         };
diff --git a/drivers/net/phy/mscc.c b/drivers/net/phy/mscc.c
index e03ead8..ec808bf 100644
--- a/drivers/net/phy/mscc.c
+++ b/drivers/net/phy/mscc.c
@@ -25,6 +25,25 @@ enum rgmii_rx_clock_delay {
 	RGMII_RX_CLK_DELAY_3_4_NS = 7
 };
 
+enum phy_led_mode {
+	LINK_ACTIVITY		= 0,
+	LINK_1000_ACTIVITY	= 1,
+	LINK_100_ACTIVITY	= 2,
+	LINK_10_ACTIVITY	= 3,
+	LINK_100_1000_ACTIVITY	= 4,
+	LINK_10_1000_ACTIVITY	= 5,
+	LINK_10_100_ACTIVITY	= 6,
+	LINK_RESERVED		= 7,
+	DUPLEX_COLLISION	= 8,
+	COLLISION		= 9,
+	ACTIVITY		= 10,
+	LINK_RESERVED_1		= 11,
+	AUTONEG_FAULT		= 12,
+	SERIAL_MODE		= 13,
+	FORCE_LED_OFF		= 14,
+	FORCE_LED_ON		= 15,
+};
+
 /* Microsemi VSC85xx PHY registers */
 /* IEEE 802. Std Registers */
 #define MSCC_PHY_BYPASS_CONTROL		  18
@@ -52,6 +71,11 @@ enum rgmii_rx_clock_delay {
 #define MSCC_PHY_DEV_AUX_CNTL		  28
 #define HP_AUTO_MDIX_X_OVER_IND_MASK	  0x2000
 
+#define MSCC_PHY_LED_MODE_SEL		  29
+#define LED_1_MODE_SEL_MASK		  0x00F0
+#define LED_0_MODE_SEL_MASK		  0x000F
+#define LED_1_MODE_SEL_POS		  4
+
 #define MSCC_EXT_PAGE_ACCESS		  31
 #define MSCC_PHY_PAGE_STANDARD		  0x0000 /* Standard registers */
 #define MSCC_PHY_PAGE_EXTENDED		  0x0001 /* Extended registers */
@@ -99,6 +123,8 @@ enum rgmii_rx_clock_delay {
 
 struct vsc8531_private {
 	int rate_magic;
+	u8 led_0_mode;
+	u8 led_1_mode;
 };
 
 #ifdef CONFIG_OF_MDIO
@@ -123,6 +149,28 @@ static int vsc85xx_phy_page_set(struct phy_device *phydev, u8 page)
 	return rc;
 }
 
+static int vsc85xx_led_cntl_set(struct phy_device *phydev,
+				u8 led_num,
+				u8 mode)
+{
+	int rc;
+	u16 reg_val;
+
+	mutex_lock(&phydev->lock);
+	reg_val = phy_read(phydev, MSCC_PHY_LED_MODE_SEL);
+	if (led_num) {
+		reg_val &= ~LED_1_MODE_SEL_MASK;
+		reg_val |= (((u16)mode << LED_1_MODE_SEL_POS) &
+			    LED_1_MODE_SEL_MASK);
+	} else {
+		reg_val |= ((u16)mode & LED_0_MODE_SEL_MASK);
+	}
+	rc = phy_write(phydev, MSCC_PHY_LED_MODE_SEL, reg_val);
+	mutex_unlock(&phydev->lock);
+
+	return rc;
+}
+
 static int vsc85xx_mdix_get(struct phy_device *phydev, u8 *mdix)
 {
 	u16 reg_val;
@@ -499,6 +547,13 @@ static int vsc85xx_config_init(struct phy_device *phydev)
 	if (rc)
 		return rc;
 
+	rc = vsc85xx_led_cntl_set(phydev, 1, vsc8531->led_1_mode);
+	if (rc)
+		return rc;
+	rc = vsc85xx_led_cntl_set(phydev, 0, vsc8531->led_0_mode);
+	if (rc)
+		return rc;
+
 	rc = genphy_config_init(phydev);
 
 	return rc;
@@ -555,8 +610,13 @@ static int vsc85xx_read_status(struct phy_device *phydev)
 
 static int vsc85xx_probe(struct phy_device *phydev)
 {
+	int rc;
 	int rate_magic;
+	u8 led_0_mode;
+	u8 led_1_mode;
 	struct vsc8531_private *vsc8531;
+	struct device *dev = &phydev->mdio.dev;
+	struct device_node *of_node = dev->of_node;
 
 	rate_magic = vsc85xx_edge_rate_magic_get(phydev);
 	if (rate_magic < 0)
@@ -570,6 +630,18 @@ static int vsc85xx_probe(struct phy_device *phydev)
 
 	vsc8531->rate_magic = rate_magic;
 
+	/* LED[0] and LED[1] mode */
+	rc = of_property_read_u8(of_node, "vsc8531,led-0-mode", &led_0_mode);
+	if (rc != 0)
+		vsc8531->led_0_mode = LINK_1000_ACTIVITY;
+	else
+		vsc8531->led_0_mode = led_0_mode;
+	rc = of_property_read_u8(of_node, "vsc8531,led-1-mode", &led_1_mode);
+	if (rc != 0)
+		vsc8531->led_1_mode = LINK_100_ACTIVITY;
+	else
+		vsc8531->led_1_mode = led_1_mode;
+
 	return 0;
 }
 
-- 
2.7.4
