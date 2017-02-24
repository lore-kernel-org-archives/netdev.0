From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: [PATCH v2 net] net: phy: Fix LED mode in DT single property.
Date: Fri, 24 Feb 2017 14:27:26 +0530
Message-ID: <1487926646-3605-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <Allan.Nielsen@microsemi.com>,
        <andrew@lunn.ch>, <robh@kernel.org>,
        Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>, <devicetree@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0043.outbound.protection.outlook.com ([104.47.37.43]:48960
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751005AbdBXI5p (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Feb 2017 03:57:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

Fix the LED mode DT parameters combine to a single property
and change the vendor prefix i.e. mscc.

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
---
Change set:
v0: Fix the LED mode DT parameters combine to a single property
v1: Fix the build test ERROR
v2: Add default LED mode "vsc85xx_dt_led_mode_get" function.

 .../devicetree/bindings/net/mscc-phy-vsc8531.txt   | 20 +++----
 drivers/net/phy/mscc.c                             | 65 ++++++++++++----------
 2 files changed, 45 insertions(+), 40 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt b/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
index 0eedabe..2253de5 100644
--- a/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
+++ b/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
@@ -6,12 +6,12 @@ Required properties:
 		  Documentation/devicetree/bindings/net/phy.txt
 
 Optional properties:
-- vsc8531,vddmac	: The vddmac in mV. Allowed values is listed
+- mscc,vddmac		: The vddmac in mV. Allowed values is listed
 			  in the first row of Table 1 (below).
 			  This property is only used in combination
 			  with the 'edge-slowdown' property.
 			  Default value is 3300.
-- vsc8531,edge-slowdown	: % the edge should be slowed down relative to
+- mscc,edge-slowdown	: % the edge should be slowed down relative to
 			  the fastest possible edge time.
 			  Edge rate sets the drive strength of the MAC
 			  interface output signals.  Changing the
@@ -27,14 +27,11 @@ Optional properties:
 			  'vddmac'.
 			  Default value is 0%.
 			  Ref: Table:1 - Edge rate change (below).
-- vsc8531,led-0-mode	: LED mode. Specify how the LED[0] should behave.
+- mscc,led-mode		: LED mode. Specify how the LED[0] and LED[1] should behave.
 			  Allowed values are define in
 			  "include/dt-bindings/net/mscc-phy-vsc8531.h".
-			  Default value is VSC8531_LINK_1000_ACTIVITY (1).
-- vsc8531,led-1-mode	: LED mode. Specify how the LED[1] should behave.
-			  Allowed values are define in
-			  "include/dt-bindings/net/mscc-phy-vsc8531.h".
-			  Default value is VSC8531_LINK_100_ACTIVITY (2).
+			  Default LED[0] value is VSC8531_LINK_1000_ACTIVITY (1).
+			  Default LED[1] value is VSC8531_LINK_100_ACTIVITY (2).
 
 Table: 1 - Edge rate change
 ----------------------------------------------------------------|
@@ -66,8 +63,7 @@ Example:
 
         vsc8531_0: ethernet-phy@0 {
                 compatible = "ethernet-phy-id0007.0570";
-                vsc8531,vddmac		= <3300>;
-                vsc8531,edge-slowdown	= <7>;
-                vsc8531,led-0-mode	= <LINK_1000_ACTIVITY>;
-                vsc8531,led-1-mode	= <LINK_100_ACTIVITY>;
+                mscc,vddmac		= /bits/ 16 <3300>;
+                mscc,edge-slowdown	= /bits/ 8  <7>;
+                mscc,led-mode	= <LINK_1000_ACTIVITY LINK_100_ACTIVITY>;
         };
diff --git a/drivers/net/phy/mscc.c b/drivers/net/phy/mscc.c
index 650c266..30bc9ec 100644
--- a/drivers/net/phy/mscc.c
+++ b/drivers/net/phy/mscc.c
@@ -385,11 +385,11 @@ static int vsc85xx_edge_rate_magic_get(struct phy_device *phydev)
 	if (!of_node)
 		return -ENODEV;
 
-	rc = of_property_read_u16(of_node, "vsc8531,vddmac", &vdd);
+	rc = of_property_read_u16(of_node, "mscc,vddmac", &vdd);
 	if (rc != 0)
 		vdd = MSCC_VDDMAC_3300;
 
-	rc = of_property_read_u8(of_node, "vsc8531,edge-slowdown", &sd);
+	rc = of_property_read_u8(of_node, "mscc,edge-slowdown", &sd);
 	if (rc != 0)
 		sd = 0;
 
@@ -402,26 +402,43 @@ static int vsc85xx_edge_rate_magic_get(struct phy_device *phydev)
 	return -EINVAL;
 }
 
-static int vsc85xx_dt_led_mode_get(struct phy_device *phydev,
-				   char *led,
-				   u8 default_mode)
+static int vsc85xx_dt_led_mode_get(struct phy_device *phydev, char *led)
 {
 	struct device *dev = &phydev->mdio.dev;
 	struct device_node *of_node = dev->of_node;
-	u8 led_mode;
-	int err;
+	struct vsc8531_private *vsc8531 = phydev->priv;
+	u8 led_0_mode = VSC8531_LINK_1000_ACTIVITY;
+	u8 led_1_mode = VSC8531_LINK_100_ACTIVITY;
+	const __be32 *paddr_end;
+	const __be32 *paddr;
+	int len;
 
 	if (!of_node)
 		return -ENODEV;
 
-	led_mode = default_mode;
-	err = of_property_read_u8(of_node, led, &led_mode);
-	if (!err && (led_mode > 15 || led_mode == 7 || led_mode == 11)) {
-		phydev_err(phydev, "DT %s invalid\n", led);
+	paddr = of_get_property(of_node, "mscc,led-mode", &len);
+	if (!paddr)
+		return -EINVAL;
+
+	paddr_end = paddr + (len /= sizeof(*paddr));
+	while (paddr + 1 < paddr_end) {
+		led_0_mode = be32_to_cpup(paddr++);
+		led_1_mode = be32_to_cpup(paddr++);
+	}
+
+	if (!len && (led_0_mode > 15 || led_0_mode == 7 || led_0_mode == 11)) {
+		phydev_err(phydev, "DT %s-0 invalid\n", led);
 		return -EINVAL;
 	}
+	vsc8531->led_0_mode = led_0_mode;
 
-	return led_mode;
+	if (!len && (led_1_mode > 15 || led_1_mode == 7 || led_1_mode == 11)) {
+		phydev_err(phydev, "DT %s-1 invalid\n", led);
+		return -EINVAL;
+	}
+	vsc8531->led_1_mode = led_1_mode;
+
+	return 0;
 }
 
 #else
@@ -430,11 +447,11 @@ static int vsc85xx_edge_rate_magic_get(struct phy_device *phydev)
 	return 0;
 }
 
-static int vsc85xx_dt_led_mode_get(struct phy_device *phydev,
-				   char *led,
-				   u8 default_mode)
+static int vsc85xx_dt_led_mode_get(struct phy_device *phydev, char *led)
 {
-	return default_mode;
+	vsc8531->led_0_mode = VSC8531_LINK_1000_ACTIVITY;
+	vsc8531->led_1_mode = VSC8531_LINK_100_ACTIVITY;
+	return 0;
 }
 #endif /* CONFIG_OF_MDIO */
 
@@ -626,7 +643,7 @@ static int vsc85xx_probe(struct phy_device *phydev)
 {
 	struct vsc8531_private *vsc8531;
 	int rate_magic;
-	int led_mode;
+	int err;
 
 	rate_magic = vsc85xx_edge_rate_magic_get(phydev);
 	if (rate_magic < 0)
@@ -641,17 +658,9 @@ static int vsc85xx_probe(struct phy_device *phydev)
 	vsc8531->rate_magic = rate_magic;
 
 	/* LED[0] and LED[1] mode */
-	led_mode = vsc85xx_dt_led_mode_get(phydev, "vsc8531,led-0-mode",
-					   VSC8531_LINK_1000_ACTIVITY);
-	if (led_mode < 0)
-		return led_mode;
-	vsc8531->led_0_mode = led_mode;
-
-	led_mode = vsc85xx_dt_led_mode_get(phydev, "vsc8531,led-1-mode",
-					   VSC8531_LINK_100_ACTIVITY);
-	if (led_mode < 0)
-		return led_mode;
-	vsc8531->led_1_mode = led_mode;
+	err = vsc85xx_dt_led_mode_get(phydev, "mscc,led-mode");
+	if (err < 0)
+		return err;
 
 	return 0;
 }
-- 
2.7.4
