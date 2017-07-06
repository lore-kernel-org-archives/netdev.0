From: Alvaro Gamez Machado <alvaro.gamez@hazent.com>
Subject: [PATCH] net: axienet: add support for standard phy-mode binding
Date: Thu,  6 Jul 2017 10:50:11 +0200
Message-ID: <20170706085011.2828-1-alvaro.gamez@hazent.com>
Cc: Alvaro Gamez Machado <alvaro.gamez@hazent.com>
To: Anirudha Sarangi <anirudh@xilinx.com>,
        John Linn <John.Linn@xilinx.com>,
        Michal Simek <michal.simek@xilinx.com>,
        =?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Keep supporting proprietary "xlnx,phy-type" attribute and add support for
MII connectivity to the PHY.

Signed-off-by: Alvaro Gamez Machado <alvaro.gamez@hazent.com>
---
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 48 +++++++++++++++++------
 1 file changed, 36 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 33c595f4691d..f669b8e69e8b 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -531,11 +531,11 @@ static void axienet_adjust_link(struct net_device *ndev)
 	link_state = phy->speed | (phy->duplex << 1) | phy->link;
 	if (lp->last_link != link_state) {
 		if ((phy->speed == SPEED_10) || (phy->speed == SPEED_100)) {
-			if (lp->phy_type == XAE_PHY_TYPE_1000BASE_X)
+			if (lp->phy_type == PHY_INTERFACE_MODE_1000BASEX)
 				setspeed = 0;
 		} else {
 			if ((phy->speed == SPEED_1000) &&
-			    (lp->phy_type == XAE_PHY_TYPE_MII))
+			    (lp->phy_type == PHY_INTERFACE_MODE_MII))
 				setspeed = 0;
 		}
 
@@ -935,15 +935,8 @@ static int axienet_open(struct net_device *ndev)
 		return ret;
 
 	if (lp->phy_node) {
-		if (lp->phy_type == XAE_PHY_TYPE_GMII) {
-			phydev = of_phy_connect(lp->ndev, lp->phy_node,
-						axienet_adjust_link, 0,
-						PHY_INTERFACE_MODE_GMII);
-		} else if (lp->phy_type == XAE_PHY_TYPE_RGMII_2_0) {
-			phydev = of_phy_connect(lp->ndev, lp->phy_node,
-						axienet_adjust_link, 0,
-						PHY_INTERFACE_MODE_RGMII_ID);
-		}
+		phydev = of_phy_connect(lp->ndev, lp->phy_node,
+					axienet_adjust_link, 0, lp->phy_type);
 
 		if (!phydev)
 			dev_err(lp->dev, "of_phy_connect() failed\n");
@@ -1539,7 +1532,38 @@ static int axienet_probe(struct platform_device *pdev)
 	 * the device-tree and accordingly set flags.
 	 */
 	of_property_read_u32(pdev->dev.of_node, "xlnx,rxmem", &lp->rxmem);
-	of_property_read_u32(pdev->dev.of_node, "xlnx,phy-type", &lp->phy_type);
+
+	/* Start with the proprietary, and broken phy_type */
+	ret = of_property_read_u32(pdev->dev.of_node, "xlnx,phy-type", &value);
+	if (!ret) {
+		netdev_warn(ndev, "Please upgrade your device tree binary blob to use phy-mode");
+		switch (phy_type) {
+		case XAE_PHY_TYPE_MII:
+			lp->phy_type = PHY_INTERFACE_MODE_MII;
+			break;
+		case XAE_PHY_TYPE_GMII:
+			lp->phy_type = PHY_INTERFACE_MODE_GMII;
+			break;
+		case XAE_PHY_TYPE_RGMII_2_0:
+			lp->phy_type = PHY_INTERFACE_MODE_RGMII;
+			break;
+		case XAE_PHY_TYPE_SGMII:
+			lp->phy_type = PHY_INTERFACE_MODE_SGMII;
+			break;
+		case XAE_PHY_TYPE_1000BASE_X:
+			lp->phy_type = PHY_INTERFACE_MODE_1000BASEX;
+			break;
+		default:
+			ret = -EINVAL;
+			goto free_netdev;
+		}
+	} else {
+		lp->phy_type = of_get_phy_mode(pdev->dev.of_node);
+		if (lp->phy_mode < 0) {
+			ret = -EINVAL;
+			goto free_netdev;
+		}
+	}
 
 	/* Find the DMA node, map the DMA registers, and decode the DMA IRQs */
 	np = of_parse_phandle(pdev->dev.of_node, "axistream-connected", 0);
-- 
2.11.0
