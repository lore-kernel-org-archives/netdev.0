From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: [PATCH v7 net-next] net: phy: Add Edge-rate driver for Microsemi PHYs.
Date: Tue, 4 Oct 2016 19:34:05 +0530
Message-ID: <1475589845-29182-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <Allan.Nielsen@microsemi.com>,
        <andrew@lunn.ch>, Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>, <devicetree@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0047.outbound.protection.outlook.com ([104.47.37.47]:54066
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753724AbcJDOEh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Oct 2016 10:04:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

Edge-rate:
As system and networking speeds increase, a signal's output transition,
also know as the edge rate or slew rate (V/ns), takes on greater importance
because high-speed signals come with a price. That price is an assortment of
interference problems like ringing on the line, signal overshoot and
undershoot, extended signal settling times, crosstalk noise, transmission
line reflections, false signal detection by the receiving device and
electromagnetic interference (EMI) -- all of which can negate the potential
gains designers are seeking when they try to increase system speeds through
the use of higher performance logic devices. The fact is, faster signaling
edge rates can cause a higher level of electrical noise or other type of
interference that can actually lead to slower line speeds and lower maximum
system frequencies. This parameter allow the board designers to change the
driving strange, and thereby change the EMI behavioral.

Edge-rate parameters (vddmac, edge-slowdown) get from Device Tree.

Tested on Beaglebone Black with VSC 8531 PHY.

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

---
All the review comments updated and resending for review.

Change set:
v1:
- Initial version of Edge-rate driver add by using IOCTL.
v2:
- Changed edge-rate parameter to Device Tree with magic number.
v3:
- Added Device Tree documentati0n and edge-rate parameter table.
  Added probe function initialize the vsc8531 private data structure.
v4:
- As per review comment, Device Tree parameters (vddmac, edge-slowdown)
  added.
v5:
- As per review comment, Device Tree Document parameters (vddmac, 
  edge-slowdown) real numbers added. Table number changed from 5 to 1.
v6:
- As per review comment, Removed Device Tree header file. Removed MACROs
  and add ARRAYSIZE
v7:
- As per review comment, Removed '-'s (minus) sign in Edge rate table. 

---

 .../devicetree/bindings/net/mscc-phy-vsc8531.txt   |  3 +-
 drivers/net/phy/mscc.c                             | 43 ++++++++++++----------
 include/dt-bindings/net/mscc-phy-vsc8531.h         | 21 -----------
 3 files changed, 26 insertions(+), 41 deletions(-)
 delete mode 100644 include/dt-bindings/net/mscc-phy-vsc8531.h

diff --git a/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt b/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
index 99c7eb0..241841c 100644
--- a/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
+++ b/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
@@ -18,7 +18,8 @@ Optional properties:
 			  to reprogram drive strength and in effect slow
 			  down the edge rate if desired.  Table 1 shows the
 			  impact to the edge rate per VDDMAC supply for each
-			  drive strength setting.
+			  drive strength setting. VDDMAC supply voltage
+			  should be one of the value in Table-1 first row.
 			  Ref: Table:1 - Edge rate change below.
 
 Note: see dt-bindings/net/mscc-phy-vsc8531.h for applicable values
diff --git a/drivers/net/phy/mscc.c b/drivers/net/phy/mscc.c
index a17573e..b40cf18c 100644
--- a/drivers/net/phy/mscc.c
+++ b/drivers/net/phy/mscc.c
@@ -12,7 +12,6 @@
 #include <linux/mii.h>
 #include <linux/phy.h>
 #include <linux/of.h>
-#include <dt-bindings/net/mscc-phy-vsc8531.h>
 
 enum rgmii_rx_clock_delay {
 	RGMII_RX_CLK_DELAY_0_2_NS = 0,
@@ -56,16 +55,18 @@ enum rgmii_rx_clock_delay {
 #define PHY_ID_VSC8531			  0x00070570
 #define PHY_ID_VSC8541			  0x00070770
 
+#define MSCC_SLOWDOWN_MAX		  8
+
 struct edge_rate_table {
 	u16 vddmac;
-	int slowdown[MSCC_SLOWDOWN_MAX];
+	u8 slowdown[MSCC_SLOWDOWN_MAX];
 };
 
-struct edge_rate_table edge_table[MSCC_VDDMAC_MAX] = {
-	{3300, { 0, -2, -4,  -7,  -10, -17, -29, -53} },
-	{2500, { 0, -3, -6,  -10, -14, -23, -37, -63} },
-	{1800, { 0, -5, -9,  -16, -23, -35, -52, -76} },
-	{1500, { 0, -6, -14, -21, -29, -42, -58, -77} },
+static const struct edge_rate_table edge_table[] = {
+	{3300, { 0, 2, 4,  7,  10, 17, 29, 53} },
+	{2500, { 0, 3, 6,  10, 14, 23, 37, 63} },
+	{1800, { 0, 5, 9,  16, 23, 35, 52, 76} },
+	{1500, { 0, 6, 14, 21, 29, 42, 58, 77} },
 };
 
 struct vsc8531_private {
@@ -81,21 +82,26 @@ static int vsc85xx_phy_page_set(struct phy_device *phydev, u8 page)
 	return rc;
 }
 
-static u8 edge_rate_magic_get(u16 vddmac,
-			      int slowdown)
+static u8 vsc85xx_edge_rate_magic_get(u16 vddmac,
+				      u8 slowdown)
 {
-	int rc = (MSCC_SLOWDOWN_MAX - 1);
+	int rc = (ARRAY_SIZE(edge_table[0].slowdown) - 1);
 	u8 vdd;
 	u8 sd;
 
-	for (vdd = 0; vdd < MSCC_VDDMAC_MAX; vdd++) {
+	for (vdd = 0; vdd < ARRAY_SIZE(edge_table); vdd++) {
 		if (edge_table[vdd].vddmac == vddmac) {
-			for (sd = 0; sd < MSCC_SLOWDOWN_MAX; sd++) {
-				if (edge_table[vdd].slowdown[sd] <= slowdown) {
-					rc = (MSCC_SLOWDOWN_MAX - sd - 1);
+			for (sd = 0;
+			     sd < ARRAY_SIZE(edge_table[0].slowdown);
+			     sd++) {
+				if (edge_table[vdd].slowdown[sd] >= slowdown) {
+					rc = (ARRAY_SIZE(edge_table[0].slowdown)
+					      - sd - 1);
 					break;
 				}
 			}
+			/* Max Slowdown Magic number should be zero */
+			rc = 0;
 		}
 	}
 
@@ -198,14 +204,13 @@ static int vsc8531_of_init(struct phy_device *phydev)
 	rc = of_property_read_u16(of_node, "vsc8531,vddmac",
 				  &vsc8531->vddmac);
 	if (rc == -EINVAL)
-		vsc8531->vddmac = MSCC_VDDMAC_3300;
+		vsc8531->vddmac = 3300;
 	rc = of_property_read_u8(of_node, "vsc8531,edge-slowdown",
 				 &vsc8531->edge_slowdown);
 	if (rc == -EINVAL)
 		vsc8531->edge_slowdown = 0;
 
-	rc = 0;
-	return rc;
+	return 0;
 }
 #else
 static int vsc8531_of_init(struct phy_device *phydev)
@@ -232,8 +237,8 @@ static int vsc85xx_config_init(struct phy_device *phydev)
 	if (rc)
 		return rc;
 
-	edge_rate = edge_rate_magic_get(vsc8531->vddmac,
-					-(int)vsc8531->edge_slowdown);
+	edge_rate = vsc85xx_edge_rate_magic_get(vsc8531->vddmac,
+						vsc8531->edge_slowdown);
 	rc = vsc85xx_edge_rate_cntl_set(phydev, edge_rate);
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
2.7.4
