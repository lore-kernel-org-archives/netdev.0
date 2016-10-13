From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH net-next v11 1/1] net: phy: Cleanup the Edge-Rate feature in Microsemi PHYs.
Date: Thu, 13 Oct 2016 20:21:30 +0200
Message-ID: <1476382890-7275-2-git-send-email-allan.nielsen@microsemi.com>
References: <20161013.100141.1588302672560551253.davem@davemloft.net>
 <1476382890-7275-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>, <allan.nielsen@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0067.outbound.protection.outlook.com ([104.47.37.67]:11776
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933500AbcJMSWW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Oct 2016 14:22:22 -0400
In-Reply-To: <1476382890-7275-1-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Edge-Rate cleanup include the following:
- Updated device tree bindings documentation for edge-rate
- The edge-rate is now specified as a "slowdown", meaning that it is now
  being specified as positive values instead of negative (both
  documentation and implementation wise).
- Only explicitly documented values for "vsc8531,vddmac" and
  "vsc8531,edge-slowdown" are accepted by the device driver.
- Deleted include/dt-bindings/net/mscc-phy-vsc8531.h as it was not needed.
- Read/validate devicetree settings in probe instead of init

Signed-off-by: Allan W. Nielsen <allan.nielsen@microsemi.com>
Signed-off-by: Raju Lakkaraju <raju.lakkaraju@microsemi.com>
---
 .../devicetree/bindings/net/mscc-phy-vsc8531.txt   |  51 ++++----
 drivers/net/phy/mscc.c                             | 135 ++++++++++-----------
 include/dt-bindings/net/mscc-phy-vsc8531.h         |  21 ----
 3 files changed, 90 insertions(+), 117 deletions(-)
 delete mode 100644 include/dt-bindings/net/mscc-phy-vsc8531.h

diff --git a/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt b/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
index 99c7eb0..bdefefc6 100644
--- a/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
+++ b/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
@@ -6,22 +6,27 @@ Required properties:
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
-
-Note: see dt-bindings/net/mscc-phy-vsc8531.h for applicable values
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
 
 Table: 1 - Edge rate change
 ----------------------------------------------------------------|
@@ -29,23 +34,23 @@ Table: 1 - Edge rate change
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
 
@@ -54,5 +59,5 @@ Example:
         vsc8531_0: ethernet-phy@0 {
                 compatible = "ethernet-phy-id0007.0570";
                 vsc8531,vddmac		= <3300>;
-                vsc8531,edge-slowdown	= <21>;
+                vsc8531,edge-slowdown	= <7>;
         };
diff --git a/drivers/net/phy/mscc.c b/drivers/net/phy/mscc.c
index 77a6671..113616b 100644
--- a/drivers/net/phy/mscc.c
+++ b/drivers/net/phy/mscc.c
@@ -12,7 +12,6 @@
 #include <linux/mii.h>
 #include <linux/phy.h>
 #include <linux/of.h>
-#include <dt-bindings/net/mscc-phy-vsc8531.h>
 #include <linux/netdevice.h>
 
 enum rgmii_rx_clock_delay {
@@ -69,23 +68,29 @@ enum rgmii_rx_clock_delay {
 #define PHY_ID_VSC8531			  0x00070570
 #define PHY_ID_VSC8541			  0x00070770
 
-struct edge_rate_table {
-	u16 vddmac;
-	int slowdown[MSCC_SLOWDOWN_MAX];
-};
+#define MSCC_VDDMAC_1500		  1500
+#define MSCC_VDDMAC_1800		  1800
+#define MSCC_VDDMAC_2500		  2500
+#define MSCC_VDDMAC_3300		  3300
 
-struct edge_rate_table edge_table[MSCC_VDDMAC_MAX] = {
-	{3300, { 0, -2, -4,  -7,  -10, -17, -29, -53} },
-	{2500, { 0, -3, -6,  -10, -14, -23, -37, -63} },
-	{1800, { 0, -5, -9,  -16, -23, -35, -52, -76} },
-	{1500, { 0, -6, -14, -21, -29, -42, -58, -77} },
+struct vsc8531_private {
+	int rate_magic;
 };
 
-struct vsc8531_private {
-	u8 edge_slowdown;
+#ifdef CONFIG_OF_MDIO
+struct vsc8531_edge_rate_table {
 	u16 vddmac;
+	u8 slowdown[8];
 };
 
+static const struct vsc8531_edge_rate_table edge_table[] = {
+	{MSCC_VDDMAC_3300, { 0, 2,  4,  7, 10, 17, 29, 53} },
+	{MSCC_VDDMAC_2500, { 0, 3,  6, 10, 14, 23, 37, 63} },
+	{MSCC_VDDMAC_1800, { 0, 5,  9, 16, 23, 35, 52, 76} },
+	{MSCC_VDDMAC_1500, { 0, 6, 14, 21, 29, 42, 58, 77} },
+};
+#endif /* CONFIG_OF_MDIO */
+
 static int vsc85xx_phy_page_set(struct phy_device *phydev, u8 page)
 {
 	int rc;
@@ -205,29 +210,43 @@ static void vsc85xx_wol_get(struct phy_device *phydev,
 	mutex_unlock(&phydev->lock);
 }
 
-static u8 edge_rate_magic_get(u16 vddmac,
-			      int slowdown)
+#ifdef CONFIG_OF_MDIO
+static int vsc85xx_edge_rate_magic_get(struct phy_device *phydev)
 {
-	int rc = (MSCC_SLOWDOWN_MAX - 1);
-	u8 vdd;
 	u8 sd;
+	u16 vdd;
+	int rc, i, j;
+	struct device *dev = &phydev->mdio.dev;
+	struct device_node *of_node = dev->of_node;
+	u8 sd_array_size = ARRAY_SIZE(edge_table[0].slowdown);
 
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
+	if (!of_node)
+		return -ENODEV;
 
-	return rc;
+	rc = of_property_read_u16(of_node, "vsc8531,vddmac", &vdd);
+	if (rc != 0)
+		vdd = MSCC_VDDMAC_3300;
+
+	rc = of_property_read_u8(of_node, "vsc8531,edge-slowdown", &sd);
+	if (rc != 0)
+		sd = 0;
+
+	for (i = 0; i < ARRAY_SIZE(edge_table); i++)
+		if (edge_table[i].vddmac == vdd)
+			for (j = 0; j < sd_array_size; j++)
+				if (edge_table[i].slowdown[j] == sd)
+					return (sd_array_size - j - 1);
+
+	return -EINVAL;
+}
+#else
+static int vsc85xx_edge_rate_magic_get(struct phy_device *phydev)
+{
+	return 0;
 }
+#endif /* CONFIG_OF_MDIO */
 
-static int vsc85xx_edge_rate_cntl_set(struct phy_device *phydev,
-				      u8 edge_rate)
+static int vsc85xx_edge_rate_cntl_set(struct phy_device *phydev, u8 edge_rate)
 {
 	int rc;
 	u16 reg_val;
@@ -308,45 +327,10 @@ static int vsc85xx_default_config(struct phy_device *phydev)
 	return rc;
 }
 
-#ifdef CONFIG_OF_MDIO
-static int vsc8531_of_init(struct phy_device *phydev)
-{
-	int rc;
-	struct vsc8531_private *vsc8531 = phydev->priv;
-	struct device *dev = &phydev->mdio.dev;
-	struct device_node *of_node = dev->of_node;
-
-	if (!of_node)
-		return -ENODEV;
-
-	rc = of_property_read_u16(of_node, "vsc8531,vddmac",
-				  &vsc8531->vddmac);
-	if (rc == -EINVAL)
-		vsc8531->vddmac = MSCC_VDDMAC_3300;
-	rc = of_property_read_u8(of_node, "vsc8531,edge-slowdown",
-				 &vsc8531->edge_slowdown);
-	if (rc == -EINVAL)
-		vsc8531->edge_slowdown = 0;
-
-	rc = 0;
-	return rc;
-}
-#else
-static int vsc8531_of_init(struct phy_device *phydev)
-{
-	return 0;
-}
-#endif /* CONFIG_OF_MDIO */
-
 static int vsc85xx_config_init(struct phy_device *phydev)
 {
 	int rc;
 	struct vsc8531_private *vsc8531 = phydev->priv;
-	u8 edge_rate;
-
-	rc = vsc8531_of_init(phydev);
-	if (rc)
-		return rc;
 
 	rc = vsc85xx_default_config(phydev);
 	if (rc)
@@ -356,9 +340,7 @@ static int vsc85xx_config_init(struct phy_device *phydev)
 	if (rc)
 		return rc;
 
-	edge_rate = edge_rate_magic_get(vsc8531->vddmac,
-					-(int)vsc8531->edge_slowdown);
-	rc = vsc85xx_edge_rate_cntl_set(phydev, edge_rate);
+	rc = vsc85xx_edge_rate_cntl_set(phydev, vsc8531->rate_magic);
 	if (rc)
 		return rc;
 
@@ -396,14 +378,21 @@ static int vsc85xx_config_intr(struct phy_device *phydev)
 
 static int vsc85xx_probe(struct phy_device *phydev)
 {
+	int rate_magic;
 	struct vsc8531_private *vsc8531;
 
+	rate_magic = vsc85xx_edge_rate_magic_get(phydev);
+	if (rate_magic < 0)
+		return rate_magic;
+
 	vsc8531 = devm_kzalloc(&phydev->mdio.dev, sizeof(*vsc8531), GFP_KERNEL);
 	if (!vsc8531)
 		return -ENOMEM;
 
 	phydev->priv = vsc8531;
 
+	vsc8531->rate_magic = rate_magic;
+
 	return 0;
 }
 
@@ -424,9 +413,9 @@ static struct phy_driver vsc85xx_driver[] = {
 	.config_intr    = &vsc85xx_config_intr,
 	.suspend	= &genphy_suspend,
 	.resume		= &genphy_resume,
-	.probe          = &vsc85xx_probe,
-	.set_wol        = &vsc85xx_wol_set,
-	.get_wol        = &vsc85xx_wol_get,
+	.probe		= &vsc85xx_probe,
+	.set_wol	= &vsc85xx_wol_set,
+	.get_wol	= &vsc85xx_wol_get,
 },
 {
 	.phy_id		= PHY_ID_VSC8541,
@@ -443,9 +432,9 @@ static struct phy_driver vsc85xx_driver[] = {
 	.config_intr    = &vsc85xx_config_intr,
 	.suspend	= &genphy_suspend,
 	.resume		= &genphy_resume,
-	.probe          = &vsc85xx_probe,
-	.set_wol        = &vsc85xx_wol_set,
-	.get_wol        = &vsc85xx_wol_get,
+	.probe		= &vsc85xx_probe,
+	.set_wol	= &vsc85xx_wol_set,
+	.get_wol	= &vsc85xx_wol_get,
 }
 
 };
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
