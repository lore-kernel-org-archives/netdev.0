From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: dwc_eth_qos: use phydev from struct net_device
Date: Sat, 25 Jun 2016 23:05:15 +0200
Message-ID: <1466888716-31222-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: lars.persson@axis.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36078 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751687AbcFYVFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2016 17:05:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phydev in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/synopsys/dwc_eth_qos.c |   47 +++++++++++++--------------
 1 files changed, 23 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/synopsys/dwc_eth_qos.c b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
index 158213c..094234f 100644
--- a/drivers/net/ethernet/synopsys/dwc_eth_qos.c
+++ b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
@@ -598,7 +598,6 @@ struct net_local {
 	struct work_struct txtimeout_reinit;
 
 	phy_interface_t phy_interface;
-	struct phy_device *phy_dev;
 	struct mii_bus *mii_bus;
 
 	unsigned int link;
@@ -816,7 +815,7 @@ static int dwceqos_mdio_write(struct mii_bus *bus, int mii_id, int phyreg,
 static int dwceqos_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
 {
 	struct net_local *lp = netdev_priv(ndev);
-	struct phy_device *phydev = lp->phy_dev;
+	struct phy_device *phydev = ndev->phydev;
 
 	if (!netif_running(ndev))
 		return -EINVAL;
@@ -850,6 +849,7 @@ static void dwceqos_link_down(struct net_local *lp)
 
 static void dwceqos_link_up(struct net_local *lp)
 {
+	struct net_device *ndev = lp->ndev;
 	u32 regval;
 	unsigned long flags;
 
@@ -860,7 +860,7 @@ static void dwceqos_link_up(struct net_local *lp)
 	dwceqos_write(lp, REG_DWCEQOS_MAC_LPI_CTRL_STATUS, regval);
 	spin_unlock_irqrestore(&lp->hw_lock, flags);
 
-	lp->eee_active = !phy_init_eee(lp->phy_dev, 0);
+	lp->eee_active = !phy_init_eee(ndev->phydev, 0);
 
 	/* Check for changed EEE capability */
 	if (!lp->eee_active && lp->eee_enabled) {
@@ -876,7 +876,8 @@ static void dwceqos_link_up(struct net_local *lp)
 
 static void dwceqos_set_speed(struct net_local *lp)
 {
-	struct phy_device *phydev = lp->phy_dev;
+	struct net_device *ndev = lp->ndev;
+	struct phy_device *phydev = ndev->phydev;
 	u32 regval;
 
 	regval = dwceqos_read(lp, REG_DWCEQOS_MAC_CFG);
@@ -903,7 +904,7 @@ static void dwceqos_set_speed(struct net_local *lp)
 static void dwceqos_adjust_link(struct net_device *ndev)
 {
 	struct net_local *lp = netdev_priv(ndev);
-	struct phy_device *phydev = lp->phy_dev;
+	struct phy_device *phydev = ndev->phydev;
 	int status_change = 0;
 
 	if (lp->phy_defer)
@@ -987,7 +988,6 @@ static int dwceqos_mii_probe(struct net_device *ndev)
 	lp->link    = 0;
 	lp->speed   = 0;
 	lp->duplex  = DUPLEX_UNKNOWN;
-	lp->phy_dev = phydev;
 
 	return 0;
 }
@@ -1531,6 +1531,7 @@ static void dwceqos_configure_bus(struct net_local *lp)
 
 static void dwceqos_init_hw(struct net_local *lp)
 {
+	struct net_device *ndev = lp->ndev;
 	u32 regval;
 	u32 buswidth;
 	u32 dma_skip;
@@ -1645,10 +1646,10 @@ static void dwceqos_init_hw(struct net_local *lp)
 		      regval | DWCEQOS_MAC_CFG_TE | DWCEQOS_MAC_CFG_RE);
 
 	lp->phy_defer = false;
-	mutex_lock(&lp->phy_dev->lock);
-	phy_read_status(lp->phy_dev);
+	mutex_lock(&ndev->phydev->lock);
+	phy_read_status(ndev->phydev);
 	dwceqos_adjust_link(lp->ndev);
-	mutex_unlock(&lp->phy_dev->lock);
+	mutex_unlock(&ndev->phydev->lock);
 }
 
 static void dwceqos_tx_reclaim(unsigned long data)
@@ -1898,7 +1899,7 @@ static int dwceqos_open(struct net_device *ndev)
 	 * hence the unusual init order with phy_start first.
 	 */
 	lp->phy_defer = true;
-	phy_start(lp->phy_dev);
+	phy_start(ndev->phydev);
 	dwceqos_init_hw(lp);
 	napi_enable(&lp->napi);
 
@@ -1943,7 +1944,7 @@ static int dwceqos_stop(struct net_device *ndev)
 
 	dwceqos_drain_dma(lp);
 	dwceqos_reset_hw(lp);
-	phy_stop(lp->phy_dev);
+	phy_stop(ndev->phydev);
 
 	dwceqos_descriptor_free(lp);
 
@@ -2526,8 +2527,7 @@ dwceqos_get_stats64(struct net_device *ndev, struct rtnl_link_stats64 *s)
 static int
 dwceqos_get_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
 {
-	struct net_local *lp = netdev_priv(ndev);
-	struct phy_device *phydev = lp->phy_dev;
+	struct phy_device *phydev = ndev->phydev;
 
 	if (!phydev)
 		return -ENODEV;
@@ -2538,8 +2538,7 @@ dwceqos_get_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
 static int
 dwceqos_set_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
 {
-	struct net_local *lp = netdev_priv(ndev);
-	struct phy_device *phydev = lp->phy_dev;
+	struct phy_device *phydev = ndev->phydev;
 
 	if (!phydev)
 		return -ENODEV;
@@ -2574,17 +2573,17 @@ static int dwceqos_set_pauseparam(struct net_device *ndev,
 
 	lp->flowcontrol.autoneg = pp->autoneg;
 	if (pp->autoneg) {
-		lp->phy_dev->advertising |= ADVERTISED_Pause;
-		lp->phy_dev->advertising |= ADVERTISED_Asym_Pause;
+		ndev->phydev->advertising |= ADVERTISED_Pause;
+		ndev->phydev->advertising |= ADVERTISED_Asym_Pause;
 	} else {
-		lp->phy_dev->advertising &= ~ADVERTISED_Pause;
-		lp->phy_dev->advertising &= ~ADVERTISED_Asym_Pause;
+		ndev->phydev->advertising &= ~ADVERTISED_Pause;
+		ndev->phydev->advertising &= ~ADVERTISED_Asym_Pause;
 		lp->flowcontrol.rx = pp->rx_pause;
 		lp->flowcontrol.tx = pp->tx_pause;
 	}
 
 	if (netif_running(ndev))
-		ret = phy_start_aneg(lp->phy_dev);
+		ret = phy_start_aneg(ndev->phydev);
 
 	return ret;
 }
@@ -2705,7 +2704,7 @@ static int dwceqos_get_eee(struct net_device *ndev, struct ethtool_eee *edata)
 			    dwceqos_get_tx_lpi_state(regval));
 	}
 
-	return phy_ethtool_get_eee(lp->phy_dev, edata);
+	return phy_ethtool_get_eee(ndev->phydev, edata);
 }
 
 static int dwceqos_set_eee(struct net_device *ndev, struct ethtool_eee *edata)
@@ -2747,7 +2746,7 @@ static int dwceqos_set_eee(struct net_device *ndev, struct ethtool_eee *edata)
 		spin_unlock_irqrestore(&lp->hw_lock, flags);
 	}
 
-	return phy_ethtool_set_eee(lp->phy_dev, edata);
+	return phy_ethtool_set_eee(ndev->phydev, edata);
 }
 
 static u32 dwceqos_get_msglevel(struct net_device *ndev)
@@ -2981,8 +2980,8 @@ static int dwceqos_remove(struct platform_device *pdev)
 	if (ndev) {
 		lp = netdev_priv(ndev);
 
-		if (lp->phy_dev)
-			phy_disconnect(lp->phy_dev);
+		if (ndev->phydev)
+			phy_disconnect(ndev->phydev);
 		mdiobus_unregister(lp->mii_bus);
 		mdiobus_free(lp->mii_bus);
 
-- 
1.7.4.4
