From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: xilinx: axienet: use phydev from struct net_device
Date: Thu, 14 Jul 2016 19:45:57 +0200
Message-ID: <1468518358-28735-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: anirudh@xilinx.com, John.Linn@xilinx.com, michal.simek@xilinx.com,
	soren.brinkmann@xilinx.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phy in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/xilinx/xilinx_axienet.h      |    2 -
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c |   35 +++++++++-----------
 2 files changed, 16 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet.h b/drivers/net/ethernet/xilinx/xilinx_axienet.h
index 9ead4e2..af27f7d 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet.h
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet.h
@@ -382,7 +382,6 @@ struct axidma_bd {
  * struct axienet_local - axienet private per device data
  * @ndev:	Pointer for net_device to which it will be attached.
  * @dev:	Pointer to device structure
- * @phy_dev:	Pointer to PHY device structure attached to the axienet_local
  * @phy_node:	Pointer to device node structure
  * @mii_bus:	Pointer to MII bus structure
  * @regs:	Base address for the axienet_local device address space
@@ -420,7 +419,6 @@ struct axienet_local {
 	struct device *dev;
 
 	/* Connection to PHY device */
-	struct phy_device *phy_dev;	/* Pointer to PHY device */
 	struct device_node *phy_node;
 
 	/* MDIO bus data */
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 8c7f5be..71abd00 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -525,7 +525,7 @@ static void axienet_adjust_link(struct net_device *ndev)
 	u32 link_state;
 	u32 setspeed = 1;
 	struct axienet_local *lp = netdev_priv(ndev);
-	struct phy_device *phy = lp->phy_dev;
+	struct phy_device *phy = ndev->phydev;
 
 	link_state = phy->speed | (phy->duplex << 1) | phy->link;
 	if (lp->last_link != link_state) {
@@ -911,6 +911,7 @@ static int axienet_open(struct net_device *ndev)
 {
 	int ret, mdio_mcreg;
 	struct axienet_local *lp = netdev_priv(ndev);
+	struct phy_device *phydev = NULL;
 
 	dev_dbg(&ndev->dev, "axienet_open()\n");
 
@@ -934,19 +935,19 @@ static int axienet_open(struct net_device *ndev)
 
 	if (lp->phy_node) {
 		if (lp->phy_type == XAE_PHY_TYPE_GMII) {
-			lp->phy_dev = of_phy_connect(lp->ndev, lp->phy_node,
-					     axienet_adjust_link, 0,
-					     PHY_INTERFACE_MODE_GMII);
+			phydev = of_phy_connect(lp->ndev, lp->phy_node,
+						axienet_adjust_link, 0,
+						PHY_INTERFACE_MODE_GMII);
 		} else if (lp->phy_type == XAE_PHY_TYPE_RGMII_2_0) {
-			lp->phy_dev = of_phy_connect(lp->ndev, lp->phy_node,
-					     axienet_adjust_link, 0,
-					     PHY_INTERFACE_MODE_RGMII_ID);
+			phydev = of_phy_connect(lp->ndev, lp->phy_node,
+						axienet_adjust_link, 0,
+						PHY_INTERFACE_MODE_RGMII_ID);
 		}
 
-		if (!lp->phy_dev)
+		if (!phydev)
 			dev_err(lp->dev, "of_phy_connect() failed\n");
 		else
-			phy_start(lp->phy_dev);
+			phy_start(phydev);
 	}
 
 	/* Enable tasklets for Axi DMA error handling */
@@ -967,9 +968,8 @@ static int axienet_open(struct net_device *ndev)
 err_rx_irq:
 	free_irq(lp->tx_irq, ndev);
 err_tx_irq:
-	if (lp->phy_dev)
-		phy_disconnect(lp->phy_dev);
-	lp->phy_dev = NULL;
+	if (phydev)
+		phy_disconnect(phydev);
 	tasklet_kill(&lp->dma_err_tasklet);
 	dev_err(lp->dev, "request_irq() failed\n");
 	return ret;
@@ -1006,9 +1006,8 @@ static int axienet_stop(struct net_device *ndev)
 	free_irq(lp->tx_irq, ndev);
 	free_irq(lp->rx_irq, ndev);
 
-	if (lp->phy_dev)
-		phy_disconnect(lp->phy_dev);
-	lp->phy_dev = NULL;
+	if (ndev->phydev)
+		phy_disconnect(ndev->phydev);
 
 	axienet_dma_bd_release(ndev);
 	return 0;
@@ -1092,8 +1091,7 @@ static const struct net_device_ops axienet_netdev_ops = {
 static int axienet_ethtools_get_settings(struct net_device *ndev,
 					 struct ethtool_cmd *ecmd)
 {
-	struct axienet_local *lp = netdev_priv(ndev);
-	struct phy_device *phydev = lp->phy_dev;
+	struct phy_device *phydev = ndev->phydev;
 	if (!phydev)
 		return -ENODEV;
 	return phy_ethtool_gset(phydev, ecmd);
@@ -1115,8 +1113,7 @@ static int axienet_ethtools_get_settings(struct net_device *ndev,
 static int axienet_ethtools_set_settings(struct net_device *ndev,
 					 struct ethtool_cmd *ecmd)
 {
-	struct axienet_local *lp = netdev_priv(ndev);
-	struct phy_device *phydev = lp->phy_dev;
+	struct phy_device *phydev = ndev->phydev;
 	if (!phydev)
 		return -ENODEV;
 	return phy_ethtool_sset(phydev, ecmd);
-- 
1.7.4.4
