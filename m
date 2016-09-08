From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: [PATCH v2 net-next 1/2] net: phy: Add Edge-rate driver for Microsemi PHYs.
Date: Thu, 8 Sep 2016 14:47:21 +0530
Message-ID: <1473326242-4198-2-git-send-email-Raju.Lakkaraju@microsemi.com>
References: <20160824125934.GC13406@lunn.ch>
 <1473326242-4198-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <Allan.Nielsen@microsemi.com>,
        <andrew@lunn.ch>, Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0046.outbound.protection.outlook.com ([104.47.42.46]:35076
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S938703AbcIHJR5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 05:17:57 -0400
In-Reply-To: <1473326242-4198-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

Used Device Tree to configure the Edge-rate as per review comments and
re-sending code for review

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
---
 drivers/net/phy/mscc.c | 76 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 76 insertions(+)

diff --git a/drivers/net/phy/mscc.c b/drivers/net/phy/mscc.c
index c09cc4a..f0a0e8d 100644
--- a/drivers/net/phy/mscc.c
+++ b/drivers/net/phy/mscc.c
@@ -11,6 +11,7 @@
 #include <linux/mdio.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
+#include <linux/of.h>
 
 enum rgmii_rx_clock_delay {
 	RGMII_RX_CLK_DELAY_0_2_NS = 0,
@@ -36,10 +37,20 @@ enum rgmii_rx_clock_delay {
 #define RGMII_RX_CLK_DELAY_MASK		  0x0070
 #define RGMII_RX_CLK_DELAY_POS		  4
 
+#define MSCC_PHY_WOL_MAC_CONTROL	  27
+#define EDGE_RATE_CNTL_POS		  5
+#define EDGE_RATE_CNTL_MASK		  0x00E0
+#define SECURE_ON_ENABLE		  0x8000
+#define SECURE_ON_PASSWD_LEN_4		  0x4000
+
 /* Microsemi PHY ID's */
 #define PHY_ID_VSC8531			  0x00070570
 #define PHY_ID_VSC8541			  0x00070770
 
+struct vsc8531_private {
+	u8 edge_rate;
+};
+
 static int vsc85xx_phy_page_set(struct phy_device *phydev, u8 page)
 {
 	int rc;
@@ -48,6 +59,28 @@ static int vsc85xx_phy_page_set(struct phy_device *phydev, u8 page)
 	return rc;
 }
 
+static int vsc85xx_edge_rate_cntl_set(struct phy_device *phydev,
+				      u8     edge_rate)
+{
+	int rc;
+	u16 reg_val;
+
+	mutex_lock(&phydev->lock);
+	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_EXTENDED_2);
+	if (rc != 0)
+		goto out_unlock;
+	reg_val = phy_read(phydev, MSCC_PHY_WOL_MAC_CONTROL);
+	reg_val &= ~(EDGE_RATE_CNTL_MASK);
+	reg_val |= (edge_rate << EDGE_RATE_CNTL_POS);
+	phy_write(phydev, MSCC_PHY_WOL_MAC_CONTROL, reg_val);
+	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_STANDARD);
+
+out_unlock:
+	mutex_unlock(&phydev->lock);
+
+	return rc;
+}
+
 static int vsc85xx_default_config(struct phy_device *phydev)
 {
 	int rc;
@@ -70,13 +103,56 @@ out_unlock:
 	return rc;
 }
 
+#ifdef CONFIG_OF_MDIO
+static int vsc8531_of_init(struct phy_device *phydev)
+{
+	int rc;
+	struct vsc8531_private *vsc8531 = phydev->priv;
+	struct device *dev = &phydev->mdio.dev;
+	struct device_node *of_node = dev->of_node;
+
+	if (!of_node)
+		return -ENODEV;
+
+	rc = of_property_read_u8(of_node, "vsc8531,edge-rate",
+				 &vsc8531->edge_rate);
+
+	return rc;
+}
+#else
+static int vsc8531_of_init(struct phy_device *phydev)
+{
+	return 0;
+}
+#endif /* CONFIG_OF_MDIO */
+
 static int vsc85xx_config_init(struct phy_device *phydev)
 {
 	int rc;
+	struct vsc8531_private *vsc8531;
+
+	if (!phydev->priv) {
+		vsc8531 = devm_kzalloc(&phydev->mdio.dev, sizeof(*vsc8531),
+				       GFP_KERNEL);
+		if (!vsc8531)
+			return -ENOMEM;
+
+		phydev->priv = vsc8531;
+		rc = vsc8531_of_init(phydev);
+		if (rc)
+			return rc;
+	} else {
+		vsc8531 = (struct vsc8531_private *)phydev->priv;
+	}
 
 	rc = vsc85xx_default_config(phydev);
 	if (rc)
 		return rc;
+
+	rc = vsc85xx_edge_rate_cntl_set(phydev, vsc8531->edge_rate);
+	if (rc)
+		return rc;
+
 	rc = genphy_config_init(phydev);
 
 	return rc;
-- 
2.7.4
