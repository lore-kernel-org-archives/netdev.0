From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH net-next v9 1/1] net: phy: Cleanup the Edge-Rate feature in Microsemi PHYs.
Date: Fri, 7 Oct 2016 10:28:24 +0200
Message-ID: <1475828904-13839-2-git-send-email-allan.nielsen@microsemi.com>
References: <1475828904-13839-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>, <allan.nielsen@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0042.outbound.protection.outlook.com ([104.47.40.42]:56672
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1756493AbcJGI3P (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Oct 2016 04:29:15 -0400
In-Reply-To: <1475828904-13839-1-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Edge-Rate cleanup include the following:
- Updated device tree bindings documentation for edge-rate
- The edge-rate is now specified as a "slowdown", meaning that it is now
  being specified as positive values instead of negative (both
  documentation and implementation wise).
- Only explicitly documented values for "vsc8531,vddmac" and
  "vsc8531,edge-slowdown" are accepted by the device driver.
- Deleting include/dt-bindings/net/mscc-phy-vsc8531.h as it was not needed.

Signed-off-by: Allan W. Nielsen <allan.nielsen@microsemi.com>
Signed-off-by: Raju Lakkaraju <raju.lakkaraju@microsemi.com>
---
 .../devicetree/bindings/net/mscc-phy-vsc8531.txt   | 49 ++++++++------
 drivers/net/phy/mscc.c                             | 79 +++++++++++++---------
 include/dt-bindings/net/mscc-phy-vsc8531.h         | 21 ------
 3 files changed, 75 insertions(+), 74 deletions(-)
 delete mode 100644 include/dt-bindings/net/mscc-phy-vsc8531.h

diff --git a/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt b/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
index 99c7eb0..f552033 100644
--- a/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
+++ b/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
@@ -6,20 +6,27 @@ Required properties:
 		  Documentation/devicetree/bindings/net/phy.txt
 
 Optional properties:
-- vsc8531,vddmac	: The vddmac in mV.
+- vsc8531,vddmac	: The vddmac in mV. Allowed values is listed
+			  in the first row of Table 1 (below).
+			  This property is only used in combination
+			  with the 'edge-slowdown' property.
+			  Default value is 3300.
 - vsc8531,edge-slowdown	: % the edge should be slowed down relative to
-			  the fastest possible edge time. Native sign
-			  need not enter.
+			  the fastest possible edge time.
 			  Edge rate sets the drive strength of the MAC
-			  interface output signals.  Changing the drive
-			  strength will affect the edge rate of the output
-			  signal.  The goal of this setting is to help
-			  reduce electrical emission (EMI) by being able
-			  to reprogram drive strength and in effect slow
-			  down the edge rate if desired.  Table 1 shows the
-			  impact to the edge rate per VDDMAC supply for each
-			  drive strength setting.
-			  Ref: Table:1 - Edge rate change below.
+			  interface output signals.  Changing the
+			  drive strength will affect the edge rate of
+			  the output signal.  The goal of this setting
+			  is to help reduce electrical emission (EMI)
+			  by being able to reprogram drive strength
+			  and in effect slow down the edge rate if
+			  desired.
+			  To adjust the edge-slowdown, the 'vddmac'
+			  must be specified. Table 1 lists the
+			  supported edge-slowdown values for a given
+			  'vddmac'.
+			  Default value is 0%.
+			  Ref: Table:1 - Edge rate change (below).
 
 Note: see dt-bindings/net/mscc-phy-vsc8531.h for applicable values
 
@@ -29,23 +36,23 @@ Table: 1 - Edge rate change
 |								|
 | 3300 mV	2500 mV		1800 mV		1500 mV		|
 |---------------------------------------------------------------|
-| Default	Deafult		Default		Default		|
+| 0%		0%		0%		0%		|
 | (Fastest)			(recommended)	(recommended)	|
 |---------------------------------------------------------------|
-| -2%		-3%		-5%		-6%		|
+| 2%		3%		5%		6%		|
 |---------------------------------------------------------------|
-| -4%		-6%		-9%		-14%		|
+| 4%		6%		9%		14%		|
 |---------------------------------------------------------------|
-| -7%		-10%		-16%		-21%		|
+| 7%		10%		16%		21%		|
 |(recommended)	(recommended)					|
 |---------------------------------------------------------------|
-| -10%		-14%		-23%		-29%		|
+| 10%		14%		23%		29%		|
 |---------------------------------------------------------------|
-| -17%		-23%		-35%		-42%		|
+| 17%		23%		35%		42%		|
 |---------------------------------------------------------------|
-| -29%		-37%		-52%		-58%		|
+| 29%		37%		52%		58%		|
 |---------------------------------------------------------------|
-| -53%		-63%		-76%		-77%		|
+| 53%		63%		76%		77%		|
 | (slowest)							|
 |---------------------------------------------------------------|
 
@@ -54,5 +61,5 @@ Example:
         vsc8531_0: ethernet-phy@0 {
                 compatible = "ethernet-phy-id0007.0570";
                 vsc8531,vddmac		= <3300>;
-                vsc8531,edge-slowdown	= <21>;
+                vsc8531,edge-slowdown	= <7>;
         };
diff --git a/drivers/net/phy/mscc.c b/drivers/net/phy/mscc.c
index a17573e..2bd00b6 100644
--- a/drivers/net/phy/mscc.c
+++ b/drivers/net/phy/mscc.c
@@ -12,7 +12,6 @@
 #include <linux/mii.h>
 #include <linux/phy.h>
 #include <linux/of.h>
-#include <dt-bindings/net/mscc-phy-vsc8531.h>
 
 enum rgmii_rx_clock_delay {
 	RGMII_RX_CLK_DELAY_0_2_NS = 0,
@@ -56,21 +55,27 @@ enum rgmii_rx_clock_delay {
 #define PHY_ID_VSC8531			  0x00070570
 #define PHY_ID_VSC8541			  0x00070770
 
-struct edge_rate_table {
+#define MSCC_VDDMAC_1500		  1500
+#define MSCC_VDDMAC_1800		  1800
+#define MSCC_VDDMAC_2500		  2500
+#define MSCC_VDDMAC_3300		  3300
+
+struct vsc8531_edge_rate_table {
 	u16 vddmac;
-	int slowdown[MSCC_SLOWDOWN_MAX];
+	u8 slowdown[8];
 };
 
-struct edge_rate_table edge_table[MSCC_VDDMAC_MAX] = {
-	{3300, { 0, -2, -4,  -7,  -10, -17, -29, -53} },
-	{2500, { 0, -3, -6,  -10, -14, -23, -37, -63} },
-	{1800, { 0, -5, -9,  -16, -23, -35, -52, -76} },
-	{1500, { 0, -6, -14, -21, -29, -42, -58, -77} },
+static const struct vsc8531_edge_rate_table edge_table[] = {
+	{MSCC_VDDMAC_3300, { 0, 2,  4,  7, 10, 17, 29, 53} },
+	{MSCC_VDDMAC_2500, { 0, 3,  6, 10, 14, 23, 37, 63} },
+	{MSCC_VDDMAC_1800, { 0, 5,  9, 16, 23, 35, 52, 76} },
+	{MSCC_VDDMAC_1500, { 0, 6, 14, 21, 29, 42, 58, 77} },
 };
 
 struct vsc8531_private {
 	u8 edge_slowdown;
 	u16 vddmac;
+	int rate_magic;
 };
 
 static int vsc85xx_phy_page_set(struct phy_device *phydev, u8 page)
@@ -81,29 +86,21 @@ static int vsc85xx_phy_page_set(struct phy_device *phydev, u8 page)
 	return rc;
 }
 
-static u8 edge_rate_magic_get(u16 vddmac,
-			      int slowdown)
+static int vsc85xx_edge_rate_magic_get(u16 vddmac, u8 slowdown)
 {
-	int rc = (MSCC_SLOWDOWN_MAX - 1);
 	u8 vdd;
 	u8 sd;
-
-	for (vdd = 0; vdd < MSCC_VDDMAC_MAX; vdd++) {
-		if (edge_table[vdd].vddmac == vddmac) {
-			for (sd = 0; sd < MSCC_SLOWDOWN_MAX; sd++) {
-				if (edge_table[vdd].slowdown[sd] <= slowdown) {
-					rc = (MSCC_SLOWDOWN_MAX - sd - 1);
-					break;
-				}
-			}
-		}
-	}
-
-	return rc;
+	u8 sd_array_size = ARRAY_SIZE(edge_table[0].slowdown);
+
+	for (vdd = 0; vdd < ARRAY_SIZE(edge_table); vdd++)
+		if (edge_table[vdd].vddmac == vddmac)
+			for (sd = 0; sd < sd_array_size; sd++)
+				if (edge_table[vdd].slowdown[sd] == slowdown)
+					return (sd_array_size - sd - 1);
+	return -EINVAL;
 }
 
-static int vsc85xx_edge_rate_cntl_set(struct phy_device *phydev,
-				      u8 edge_rate)
+static int vsc85xx_edge_rate_cntl_set(struct phy_device *phydev, u8 edge_rate)
 {
 	int rc;
 	u16 reg_val;
@@ -199,17 +196,38 @@ static int vsc8531_of_init(struct phy_device *phydev)
 				  &vsc8531->vddmac);
 	if (rc == -EINVAL)
 		vsc8531->vddmac = MSCC_VDDMAC_3300;
+
 	rc = of_property_read_u8(of_node, "vsc8531,edge-slowdown",
 				 &vsc8531->edge_slowdown);
 	if (rc == -EINVAL)
 		vsc8531->edge_slowdown = 0;
 
-	rc = 0;
-	return rc;
+	vsc8531->rate_magic = vsc85xx_edge_rate_magic_get(
+		vsc8531->vddmac, vsc8531->edge_slowdown);
+	if (vsc8531->rate_magic < 0) {
+		phydev_err(phydev,
+			   "Invalid vsc8531,vddmac or vsc8531,edge-slowdown");
+		return vsc8531->rate_magic;
+	}
+
+	return 0;
 }
 #else
 static int vsc8531_of_init(struct phy_device *phydev)
 {
+	struct vsc8531_private *vsc8531 = phydev->priv;
+
+	vsc8531->vddmac = MSCC_VDDMAC_3300;
+	vsc8531->edge_slowdown = 0;
+
+	vsc8531->rate_magic = vsc85xx_edge_rate_magic_get(
+		vsc8531->vddmac, vsc8531->edge_slowdown);
+	if (vsc8531->rate_magic < 0) {
+		phydev_err(phydev,
+			   "Invalid vsc8531,vddmac or vsc8531,edge-slowdown");
+		return vsc8531->rate_magic;
+	}
+
 	return 0;
 }
 #endif /* CONFIG_OF_MDIO */
@@ -218,7 +236,6 @@ static int vsc85xx_config_init(struct phy_device *phydev)
 {
 	int rc;
 	struct vsc8531_private *vsc8531 = phydev->priv;
-	u8 edge_rate;
 
 	rc = vsc8531_of_init(phydev);
 	if (rc)
@@ -232,9 +249,7 @@ static int vsc85xx_config_init(struct phy_device *phydev)
 	if (rc)
 		return rc;
 
-	edge_rate = edge_rate_magic_get(vsc8531->vddmac,
-					-(int)vsc8531->edge_slowdown);
-	rc = vsc85xx_edge_rate_cntl_set(phydev, edge_rate);
+	rc = vsc85xx_edge_rate_cntl_set(phydev, vsc8531->rate_magic);
 	if (rc)
 		return rc;
 
diff --git a/include/dt-bindings/net/mscc-phy-vsc8531.h b/include/dt-bindings/net/mscc-phy-vsc8531.h
deleted file mode 100644
index 2383dd2..0000000
--- a/include/dt-bindings/net/mscc-phy-vsc8531.h
+++ /dev/null
@@ -1,21 +0,0 @@
-/*
- * Device Tree constants for Microsemi VSC8531 PHY
- *
- * Author: Nagaraju Lakkaraju
- *
- * License: Dual MIT/GPL
- * Copyright (c) 2016 Microsemi Corporation
- */
-
-#ifndef _DT_BINDINGS_MSCC_VSC8531_H
-#define _DT_BINDINGS_MSCC_VSC8531_H
-
-/* MAC interface Edge rate control VDDMAC in milli Volts */
-#define MSCC_VDDMAC_3300		 3300
-#define MSCC_VDDMAC_2500		 2500
-#define MSCC_VDDMAC_1800		 1800
-#define MSCC_VDDMAC_1500		 1500
-#define MSCC_VDDMAC_MAX			 4
-#define MSCC_SLOWDOWN_MAX		 8
-
-#endif
-- 
2.7.3
