From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH v2 2/3] net: ethernet: fec: use phydev from struct net_device
Date: Sun,  8 May 2016 23:44:36 +0200
Message-ID: <1462743877-31738-3-git-send-email-tremyfr@gmail.com>
References: <1462743877-31738-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: fugang.duan@nxp.com, davem@davemloft.net, ben@decadent.org.uk,
	kan.liang@intel.com, decot@googlers.com, aduyck@mirantis.com,
	jiri@mellanox.com, jacob.e.keller@intel.com, tom@herbertland.com,
	andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33124 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751021AbcEHVoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 17:44:55 -0400
In-Reply-To: <1462743877-31738-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phydev in the private structure, and update the driver to use the one
contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/freescale/fec.h      |    1 -
 drivers/net/ethernet/freescale/fec_main.c |   49 ++++++++++++----------------
 2 files changed, 21 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 195122e..f58f9ea 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -517,7 +517,6 @@ struct fec_enet_private {
 
 	/* Phylib and MDIO interface */
 	struct	mii_bus *mii_bus;
-	struct	phy_device *phy_dev;
 	int	mii_timeout;
 	uint	phy_speed;
 	phy_interface_t	phy_interface;
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index bfa10c3..e1d24ff 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -967,10 +967,10 @@ fec_restart(struct net_device *ndev)
 			rcntl &= ~(1 << 8);
 
 		/* 1G, 100M or 10M */
-		if (fep->phy_dev) {
-			if (fep->phy_dev->speed == SPEED_1000)
+		if (ndev->phydev) {
+			if (ndev->phydev->speed == SPEED_1000)
 				ecntl |= (1 << 5);
-			else if (fep->phy_dev->speed == SPEED_100)
+			else if (ndev->phydev->speed == SPEED_100)
 				rcntl &= ~(1 << 9);
 			else
 				rcntl |= (1 << 9);
@@ -991,7 +991,7 @@ fec_restart(struct net_device *ndev)
 			 */
 			cfgr = (fep->phy_interface == PHY_INTERFACE_MODE_RMII)
 				? BM_MIIGSK_CFGR_RMII : BM_MIIGSK_CFGR_MII;
-			if (fep->phy_dev && fep->phy_dev->speed == SPEED_10)
+			if (ndev->phydev && ndev->phydev->speed == SPEED_10)
 				cfgr |= BM_MIIGSK_CFGR_FRCONT_10M;
 			writel(cfgr, fep->hwp + FEC_MIIGSK_CFGR);
 
@@ -1005,7 +1005,7 @@ fec_restart(struct net_device *ndev)
 	/* enable pause frame*/
 	if ((fep->pause_flag & FEC_PAUSE_FLAG_ENABLE) ||
 	    ((fep->pause_flag & FEC_PAUSE_FLAG_AUTONEG) &&
-	     fep->phy_dev && fep->phy_dev->pause)) {
+	     ndev->phydev && ndev->phydev->pause)) {
 		rcntl |= FEC_ENET_FCE;
 
 		/* set FIFO threshold parameter to reduce overrun */
@@ -1679,7 +1679,7 @@ static void fec_get_mac(struct net_device *ndev)
 static void fec_enet_adjust_link(struct net_device *ndev)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
-	struct phy_device *phy_dev = fep->phy_dev;
+	struct phy_device *phy_dev = ndev->phydev;
 	int status_change = 0;
 
 	/* Prevent a state halted on mii error */
@@ -1879,8 +1879,6 @@ static int fec_enet_mii_probe(struct net_device *ndev)
 	int phy_id;
 	int dev_id = fep->dev_id;
 
-	fep->phy_dev = NULL;
-
 	if (fep->phy_node) {
 		phy_dev = of_phy_connect(ndev, fep->phy_node,
 					 &fec_enet_adjust_link, 0,
@@ -1928,7 +1926,6 @@ static int fec_enet_mii_probe(struct net_device *ndev)
 
 	phy_dev->advertising = phy_dev->supported;
 
-	fep->phy_dev = phy_dev;
 	fep->link = 0;
 	fep->full_duplex = 0;
 
@@ -2061,8 +2058,7 @@ static void fec_enet_mii_remove(struct fec_enet_private *fep)
 static int fec_enet_get_link_ksettings(struct net_device *ndev,
 				       struct ethtool_link_ksettings *cmd)
 {
-	struct fec_enet_private *fep = netdev_priv(ndev);
-	struct phy_device *phydev = fep->phy_dev;
+	struct phy_device *phydev = ndev->phydev;
 
 	if (!phydev)
 		return -ENODEV;
@@ -2073,8 +2069,7 @@ static int fec_enet_get_link_ksettings(struct net_device *ndev,
 static int fec_enet_set_link_ksettings(struct net_device *ndev,
 				       const struct ethtool_link_ksettings *cmd)
 {
-	struct fec_enet_private *fep = netdev_priv(ndev);
-	struct phy_device *phydev = fep->phy_dev;
+	struct phy_device *phydev = ndev->phydev;
 
 	if (!phydev)
 		return -ENODEV;
@@ -2214,7 +2209,7 @@ static int fec_enet_set_pauseparam(struct net_device *ndev,
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
 
-	if (!fep->phy_dev)
+	if (!ndev->phydev)
 		return -ENODEV;
 
 	if (pause->tx_pause != pause->rx_pause) {
@@ -2230,17 +2225,17 @@ static int fec_enet_set_pauseparam(struct net_device *ndev,
 	fep->pause_flag |= pause->autoneg ? FEC_PAUSE_FLAG_AUTONEG : 0;
 
 	if (pause->rx_pause || pause->autoneg) {
-		fep->phy_dev->supported |= ADVERTISED_Pause;
-		fep->phy_dev->advertising |= ADVERTISED_Pause;
+		ndev->phydev->supported |= ADVERTISED_Pause;
+		ndev->phydev->advertising |= ADVERTISED_Pause;
 	} else {
-		fep->phy_dev->supported &= ~ADVERTISED_Pause;
-		fep->phy_dev->advertising &= ~ADVERTISED_Pause;
+		ndev->phydev->supported &= ~ADVERTISED_Pause;
+		ndev->phydev->advertising &= ~ADVERTISED_Pause;
 	}
 
 	if (pause->autoneg) {
 		if (netif_running(ndev))
 			fec_stop(ndev);
-		phy_start_aneg(fep->phy_dev);
+		phy_start_aneg(ndev->phydev);
 	}
 	if (netif_running(ndev)) {
 		napi_disable(&fep->napi);
@@ -2356,8 +2351,7 @@ static int fec_enet_get_sset_count(struct net_device *dev, int sset)
 
 static int fec_enet_nway_reset(struct net_device *dev)
 {
-	struct fec_enet_private *fep = netdev_priv(dev);
-	struct phy_device *phydev = fep->phy_dev;
+	struct phy_device *phydev = dev->phydev;
 
 	if (!phydev)
 		return -ENODEV;
@@ -2588,7 +2582,7 @@ static const struct ethtool_ops fec_enet_ethtool_ops = {
 static int fec_enet_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
-	struct phy_device *phydev = fep->phy_dev;
+	struct phy_device *phydev = ndev->phydev;
 
 	if (!netif_running(ndev))
 		return -EINVAL;
@@ -2843,7 +2837,7 @@ fec_enet_open(struct net_device *ndev)
 		goto err_enet_mii_probe;
 
 	napi_enable(&fep->napi);
-	phy_start(fep->phy_dev);
+	phy_start(ndev->phydev);
 	netif_tx_start_all_queues(ndev);
 
 	device_set_wakeup_enable(&ndev->dev, fep->wol_flag &
@@ -2867,7 +2861,7 @@ fec_enet_close(struct net_device *ndev)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
 
-	phy_stop(fep->phy_dev);
+	phy_stop(ndev->phydev);
 
 	if (netif_device_present(ndev)) {
 		napi_disable(&fep->napi);
@@ -2875,8 +2869,7 @@ fec_enet_close(struct net_device *ndev)
 		fec_stop(ndev);
 	}
 
-	phy_disconnect(fep->phy_dev);
-	fep->phy_dev = NULL;
+	phy_disconnect(ndev->phydev);
 
 	fec_enet_clk_enable(ndev, false);
 	pinctrl_pm_select_sleep_state(&fep->pdev->dev);
@@ -3504,7 +3497,7 @@ static int __maybe_unused fec_suspend(struct device *dev)
 	if (netif_running(ndev)) {
 		if (fep->wol_flag & FEC_WOL_FLAG_ENABLE)
 			fep->wol_flag |= FEC_WOL_FLAG_SLEEP_ON;
-		phy_stop(fep->phy_dev);
+		phy_stop(ndev->phydev);
 		napi_disable(&fep->napi);
 		netif_tx_lock_bh(ndev);
 		netif_device_detach(ndev);
@@ -3564,7 +3557,7 @@ static int __maybe_unused fec_resume(struct device *dev)
 		netif_device_attach(ndev);
 		netif_tx_unlock_bh(ndev);
 		napi_enable(&fep->napi);
-		phy_start(fep->phy_dev);
+		phy_start(ndev->phydev);
 	}
 	rtnl_unlock();
 
-- 
1.7.4.4
