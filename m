From: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Subject: [PATCH net-next 1/2] net: phy: Add Speed downshift set driver for Microsemi PHYs.
Date: Fri, 14 Oct 2016 17:10:32 +0530
Message-ID: <1476445233-26524-2-git-send-email-Raju.Lakkaraju@microsemi.com>
References: <1476445233-26524-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <Allan.Nielsen-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>,
        <andrew-g2DYL2Zd6BY@public.gmane.org>, Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>,
        "Allan W . Nielsen" <allan.nielsen-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1476445233-26524-1-git-send-email-Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>

For operation in cabling environments that are incompatible with
1000BAST-T, VSC8531 device provides an automatic link speed
downshift operation. When enabled, the device automatically changes
its 1000BAST-T auto-negotiation to the next slower speed after
a configured number of failed attempts at 1000BAST-T.
This feature is useful in setting up in networks using older cable
installations that include only pairs A and B, and not pairs C and D.

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Signed-off-by: Allan W. Nielsen <allan.nielsen-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
---
 .../devicetree/bindings/net/mscc-phy-vsc8531.txt   |  6 ++
 drivers/net/phy/mscc.c                             | 75 +++++++++++++++++++++-
 2 files changed, 80 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt b/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
index bdefefc6..062d115 100644
--- a/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
+++ b/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
@@ -27,6 +27,11 @@ Optional properties:
 			  'vddmac'.
 			  Default value is 0%.
 			  Ref: Table:1 - Edge rate change (below).
+- downshift-cnt		: When enabled, the device automatically changes its
+			  1000BAST-T auto-negotiation to the next slower speed
+			  after a 'downshift-cnt' of failed attempts at
+			  1000BAST-T. Allowed values: 0, 2, 3, 4, 5.
+			  0 is default and will disable downshifting.
 
 Table: 1 - Edge rate change
 ----------------------------------------------------------------|
@@ -60,4 +65,5 @@ Example:
                 compatible = "ethernet-phy-id0007.0570";
                 vsc8531,vddmac		= <3300>;
                 vsc8531,edge-slowdown	= <7>;
+                vsc8531,downshift-cnt   = <3>;
         };
diff --git a/drivers/net/phy/mscc.c b/drivers/net/phy/mscc.c
index 43a7545..e87d9f0 100644
--- a/drivers/net/phy/mscc.c
+++ b/drivers/net/phy/mscc.c
@@ -46,8 +46,15 @@ enum rgmii_rx_clock_delay {
 
 #define MSCC_EXT_PAGE_ACCESS		  31
 #define MSCC_PHY_PAGE_STANDARD		  0x0000 /* Standard registers */
+#define MSCC_PHY_PAGE_EXTENDED		  0x0001 /* Extended registers */
 #define MSCC_PHY_PAGE_EXTENDED_2	  0x0002 /* Extended reg - page 2 */
 
+/* Extended Page 1 Registers */
+#define MSCC_PHY_ACTIPHY_CNTL		  20
+#define DOWNSHIFT_CNTL_MASK		  0x000C
+#define DOWNSHIFT_EN			  0x0010
+#define DOWNSHIFT_CNTL_POS		  2
+
 /* Extended Page 2 Registers */
 #define MSCC_PHY_RGMII_CNTL		  20
 #define RGMII_RX_CLK_DELAY_MASK		  0x0070
@@ -75,6 +82,7 @@ enum rgmii_rx_clock_delay {
 
 struct vsc8531_private {
 	int rate_magic;
+	u8  downshift_magic;
 };
 
 #ifdef CONFIG_OF_MDIO
@@ -99,6 +107,31 @@ static int vsc85xx_phy_page_set(struct phy_device *phydev, u8 page)
 	return rc;
 }
 
+static int vsc85xx_downshift_set(struct phy_device *phydev, u8 magic)
+{
+	int rc;
+	u16 reg_val;
+
+	mutex_lock(&phydev->lock);
+	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_EXTENDED);
+	if (rc != 0)
+		goto out_unlock;
+
+	reg_val = phy_read(phydev, MSCC_PHY_ACTIPHY_CNTL);
+	reg_val &= ~(DOWNSHIFT_CNTL_MASK);
+	reg_val |= magic;
+	rc = phy_write(phydev, MSCC_PHY_ACTIPHY_CNTL, reg_val);
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
 static int vsc85xx_wol_set(struct phy_device *phydev,
 			   struct ethtool_wolinfo *wol)
 {
@@ -239,11 +272,42 @@ static int vsc85xx_edge_rate_magic_get(struct phy_device *phydev)
 
 	return -EINVAL;
 }
+
+static int vsc85xx_downshift_magic_get(struct phy_device *phydev)
+{
+	int rc;
+	u8 ds;
+	struct device *dev = &phydev->mdio.dev;
+	struct device_node *of_node = dev->of_node;
+
+	if (!of_node)
+		return -ENODEV;
+
+	rc = of_property_read_u8(of_node, "vsc8531,downshift-cnt", &ds);
+	if ((rc == -EINVAL) || (ds == 0))
+		return 0;
+	if (ds == 1 || ds > 5) {
+		phydev_err(phydev, "Invalid downshift count\n");
+		return -EINVAL;
+	}
+
+	/* ds is either 2,3,4 or 5 */
+	ds -= 2;
+	ds <<= DOWNSHIFT_CNTL_POS;
+	ds |= DOWNSHIFT_EN;
+
+	return ds;
+}
 #else
 static int vsc85xx_edge_rate_magic_get(struct phy_device *phydev)
 {
 	return 0;
 }
+
+static int vsc85xx_downshift_magic_get(struct phy_device *phydev)
+{
+	return 0;
+}
 #endif /* CONFIG_OF_MDIO */
 
 static int vsc85xx_edge_rate_cntl_set(struct phy_device *phydev, u8 edge_rate)
@@ -344,6 +408,10 @@ static int vsc85xx_config_init(struct phy_device *phydev)
 	if (rc)
 		return rc;
 
+	rc = vsc85xx_downshift_set(phydev, vsc8531->downshift_magic);
+	if (rc)
+		return rc;
+
 	rc = genphy_config_init(phydev);
 
 	return rc;
@@ -379,19 +447,24 @@ static int vsc85xx_config_intr(struct phy_device *phydev)
 static int vsc85xx_probe(struct phy_device *phydev)
 {
 	int rate_magic;
+	int downshift_magic;
 	struct vsc8531_private *vsc8531;
 
 	rate_magic = vsc85xx_edge_rate_magic_get(phydev);
 	if (rate_magic < 0)
 		return rate_magic;
 
+	downshift_magic = vsc85xx_downshift_magic_get(phydev);
+	if (downshift_magic < 0)
+		return downshift_magic;
+
 	vsc8531 = devm_kzalloc(&phydev->mdio.dev, sizeof(*vsc8531), GFP_KERNEL);
 	if (!vsc8531)
 		return -ENOMEM;
 
 	phydev->priv = vsc8531;
-
 	vsc8531->rate_magic = rate_magic;
+	vsc8531->downshift_magic = downshift_magic;
 
 	return 0;
 }
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
