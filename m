From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: [PATCH net-next 2/2] net: phy: Add Fast Link Failure - 2 set driver for Microsemi PHYs.
Date: Fri, 14 Oct 2016 17:10:33 +0530
Message-ID: <1476445233-26524-3-git-send-email-Raju.Lakkaraju@microsemi.com>
References: <1476445233-26524-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <Allan.Nielsen@microsemi.com>,
        <andrew@lunn.ch>, Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>,
        "Allan W . Nielsen" <allan.nielsen@microsemi.com>
To: <netdev@vger.kernel.org>, <devicetree@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0066.outbound.protection.outlook.com ([104.47.38.66]:58511
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754574AbcJNLlO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 14 Oct 2016 07:41:14 -0400
In-Reply-To: <1476445233-26524-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

VSC8531 Fast Link Failure 2 feature enables the PHY to indicate the
onset of a potential link failure in < 100 usec for 100BASE-TX
operation. FLF2 is supported through the MDINT (active low) pin.

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Signed-off-by: Allan W. Nielsen <allan.nielsen@microsemi.com>
---
 .../devicetree/bindings/net/mscc-phy-vsc8531.txt   |  6 +++
 drivers/net/phy/mscc.c                             | 45 ++++++++++++++++++++++
 2 files changed, 51 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt b/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
index 062d115..472fc68 100644
--- a/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
+++ b/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
@@ -32,6 +32,11 @@ Optional properties:
 			  after a 'downshift-cnt' of failed attempts at
 			  1000BAST-T. Allowed values: 0, 2, 3, 4, 5.
 			  0 is default and will disable downshifting.
+- flf2			: Fast Link Failure 2 (FLF2) feature enables the PHY
+			  to indicate the onset of a potential link failure in
+			  < 100 usec for 100BASE-TX operation. FLF2 is
+			  supported through the MDINT (active low) pin.
+			  Default will be disable flf2.
 
 Table: 1 - Edge rate change
 ----------------------------------------------------------------|
@@ -66,4 +71,5 @@ Example:
                 vsc8531,vddmac		= <3300>;
                 vsc8531,edge-slowdown	= <7>;
                 vsc8531,downshift-cnt   = <3>;
+		vsc8531,flf2;
         };
diff --git a/drivers/net/phy/mscc.c b/drivers/net/phy/mscc.c
index e87d9f0..57bd628 100644
--- a/drivers/net/phy/mscc.c
+++ b/drivers/net/phy/mscc.c
@@ -57,6 +57,7 @@ enum rgmii_rx_clock_delay {
 
 /* Extended Page 2 Registers */
 #define MSCC_PHY_RGMII_CNTL		  20
+#define FLF2_ENABLE			  0x8000
 #define RGMII_RX_CLK_DELAY_MASK		  0x0070
 #define RGMII_RX_CLK_DELAY_POS		  4
 
@@ -83,6 +84,7 @@ enum rgmii_rx_clock_delay {
 struct vsc8531_private {
 	int rate_magic;
 	u8  downshift_magic;
+	bool flf2;		/* Fast Link Failure-2 Enable/Disable */
 };
 
 #ifdef CONFIG_OF_MDIO
@@ -107,6 +109,33 @@ static int vsc85xx_phy_page_set(struct phy_device *phydev, u8 page)
 	return rc;
 }
 
+static int vsc85xx_flf2_set(struct phy_device *phydev, bool op)
+{
+	int rc;
+	u16 reg_val;
+
+	mutex_lock(&phydev->lock);
+	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_EXTENDED_2);
+	if (rc != 0)
+		goto out_unlock;
+
+	reg_val = phy_read(phydev, MSCC_PHY_RGMII_CNTL);
+	if (op)
+		reg_val |= FLF2_ENABLE;
+	else
+		reg_val &= ~FLF2_ENABLE;
+	rc = phy_write(phydev, MSCC_PHY_RGMII_CNTL, reg_val);
+	if (rc != 0)
+		goto out_unlock;
+
+	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_STANDARD);
+
+out_unlock:
+	mutex_unlock(&phydev->lock);
+
+	return rc;
+}
+
 static int vsc85xx_downshift_set(struct phy_device *phydev, u8 magic)
 {
 	int rc;
@@ -412,6 +441,10 @@ static int vsc85xx_config_init(struct phy_device *phydev)
 	if (rc)
 		return rc;
 
+	rc = vsc85xx_flf2_set(phydev, vsc8531->flf2);
+	if (rc)
+		return rc;
+
 	rc = genphy_config_init(phydev);
 
 	return rc;
@@ -449,6 +482,11 @@ static int vsc85xx_probe(struct phy_device *phydev)
 	int rate_magic;
 	int downshift_magic;
 	struct vsc8531_private *vsc8531;
+	struct device *dev = &phydev->mdio.dev;
+	struct device_node *of_node = dev->of_node;
+
+	if (!of_node)
+		return -ENODEV;
 
 	rate_magic = vsc85xx_edge_rate_magic_get(phydev);
 	if (rate_magic < 0)
@@ -466,6 +504,13 @@ static int vsc85xx_probe(struct phy_device *phydev)
 	vsc8531->rate_magic = rate_magic;
 	vsc8531->downshift_magic = downshift_magic;
 
+#ifdef CONFIG_OF_MDIO
+	/* Fast Link Failure 2 */
+	vsc8531->flf2 = of_property_read_bool(of_node, "vsc8531,flf2");
+#else
+	vsc8531->flf2 = 0;
+#endif
+
 	return 0;
 }
 
-- 
2.7.4
