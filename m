From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: sxgbe: use phydev from struct net_device
Date: Sat, 25 Jun 2016 22:05:26 +0200
Message-ID: <1466885127-27794-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: bh74.an@samsung.com, ks.giri@samsung.com, vipul.pandya@samsung.com,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phydev in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h  |    1 -
 drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c |   18 ++++-------
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c    |   32 +++++++++----------
 3 files changed, 22 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h b/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h
index 4501964..5cb51b6 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h
@@ -475,7 +475,6 @@ struct sxgbe_priv_data {
 	int rxcsum_insertion;
 	spinlock_t stats_lock;	/* lock for tx/rx statatics */
 
-	struct phy_device *phydev;
 	int oldlink;
 	int speed;
 	int oldduplex;
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c
index c0981ae..72c9108 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c
@@ -147,7 +147,7 @@ static int sxgbe_get_eee(struct net_device *dev,
 	edata->eee_active = priv->eee_active;
 	edata->tx_lpi_timer = priv->tx_lpi_timer;
 
-	return phy_ethtool_get_eee(priv->phydev, edata);
+	return phy_ethtool_get_eee(dev->phydev, edata);
 }
 
 static int sxgbe_set_eee(struct net_device *dev,
@@ -172,7 +172,7 @@ static int sxgbe_set_eee(struct net_device *dev,
 		priv->tx_lpi_timer = edata->tx_lpi_timer;
 	}
 
-	return phy_ethtool_set_eee(priv->phydev, edata);
+	return phy_ethtool_set_eee(dev->phydev, edata);
 }
 
 static void sxgbe_getdrvinfo(struct net_device *dev,
@@ -185,20 +185,16 @@ static void sxgbe_getdrvinfo(struct net_device *dev,
 static int sxgbe_getsettings(struct net_device *dev,
 			     struct ethtool_cmd *cmd)
 {
-	struct sxgbe_priv_data *priv = netdev_priv(dev);
-
-	if (priv->phydev)
-		return phy_ethtool_gset(priv->phydev, cmd);
+	if (dev->phydev)
+		return phy_ethtool_gset(dev->phydev, cmd);
 
 	return -EOPNOTSUPP;
 }
 
 static int sxgbe_setsettings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct sxgbe_priv_data *priv = netdev_priv(dev);
-
-	if (priv->phydev)
-		return phy_ethtool_sset(priv->phydev, cmd);
+	if (dev->phydev)
+		return phy_ethtool_sset(dev->phydev, cmd);
 
 	return -EOPNOTSUPP;
 }
@@ -255,7 +251,7 @@ static void sxgbe_get_ethtool_stats(struct net_device *dev,
 	char *p;
 
 	if (priv->eee_enabled) {
-		int val = phy_get_eee_err(priv->phydev);
+		int val = phy_get_eee_err(dev->phydev);
 
 		if (val)
 			priv->xstats.eee_wakeup_error_n = val;
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
index 413ea14a..ea44a24 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
@@ -124,12 +124,13 @@ static void sxgbe_eee_ctrl_timer(unsigned long arg)
  */
 bool sxgbe_eee_init(struct sxgbe_priv_data * const priv)
 {
+	struct net_device *ndev = priv->dev;
 	bool ret = false;
 
 	/* MAC core supports the EEE feature. */
 	if (priv->hw_cap.eee) {
 		/* Check if the PHY supports EEE */
-		if (phy_init_eee(priv->phydev, 1))
+		if (phy_init_eee(ndev->phydev, 1))
 			return false;
 
 		priv->eee_active = 1;
@@ -152,12 +153,14 @@ bool sxgbe_eee_init(struct sxgbe_priv_data * const priv)
 
 static void sxgbe_eee_adjust(const struct sxgbe_priv_data *priv)
 {
+	struct net_device *ndev = priv->dev;
+
 	/* When the EEE has been already initialised we have to
 	 * modify the PLS bit in the LPI ctrl & status reg according
 	 * to the PHY link status. For this reason.
 	 */
 	if (priv->eee_enabled)
-		priv->hw->mac->set_eee_pls(priv->ioaddr, priv->phydev->link);
+		priv->hw->mac->set_eee_pls(priv->ioaddr, ndev->phydev->link);
 }
 
 /**
@@ -203,7 +206,7 @@ static inline u32 sxgbe_tx_avail(struct sxgbe_tx_queue *queue, int tx_qsize)
 static void sxgbe_adjust_link(struct net_device *dev)
 {
 	struct sxgbe_priv_data *priv = netdev_priv(dev);
-	struct phy_device *phydev = priv->phydev;
+	struct phy_device *phydev = dev->phydev;
 	u8 new_state = 0;
 	u8 speed = 0xff;
 
@@ -306,9 +309,6 @@ static int sxgbe_init_phy(struct net_device *ndev)
 	netdev_dbg(ndev, "%s: attached to PHY (UID 0x%x) Link = %d\n",
 		   __func__, phydev->phy_id, phydev->link);
 
-	/* save phy device in private structure */
-	priv->phydev = phydev;
-
 	return 0;
 }
 
@@ -1173,8 +1173,8 @@ static int sxgbe_open(struct net_device *dev)
 	priv->hw->dma->start_tx(priv->ioaddr, SXGBE_TX_QUEUES);
 	priv->hw->dma->start_rx(priv->ioaddr, SXGBE_RX_QUEUES);
 
-	if (priv->phydev)
-		phy_start(priv->phydev);
+	if (dev->phydev)
+		phy_start(dev->phydev);
 
 	/* initialise TX coalesce parameters */
 	sxgbe_tx_init_coalesce(priv);
@@ -1194,8 +1194,8 @@ static int sxgbe_open(struct net_device *dev)
 
 init_error:
 	free_dma_desc_resources(priv);
-	if (priv->phydev)
-		phy_disconnect(priv->phydev);
+	if (dev->phydev)
+		phy_disconnect(dev->phydev);
 phy_error:
 	clk_disable_unprepare(priv->sxgbe_clk);
 
@@ -1216,10 +1216,9 @@ static int sxgbe_release(struct net_device *dev)
 		del_timer_sync(&priv->eee_ctrl_timer);
 
 	/* Stop and disconnect the PHY */
-	if (priv->phydev) {
-		phy_stop(priv->phydev);
-		phy_disconnect(priv->phydev);
-		priv->phydev = NULL;
+	if (dev->phydev) {
+		phy_stop(dev->phydev);
+		phy_disconnect(dev->phydev);
 	}
 
 	netif_tx_stop_all_queues(dev);
@@ -1969,7 +1968,6 @@ static void sxgbe_poll_controller(struct net_device *dev)
  */
 static int sxgbe_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct sxgbe_priv_data *priv = netdev_priv(dev);
 	int ret = -EOPNOTSUPP;
 
 	if (!netif_running(dev))
@@ -1979,9 +1977,9 @@ static int sxgbe_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	case SIOCGMIIPHY:
 	case SIOCGMIIREG:
 	case SIOCSMIIREG:
-		if (!priv->phydev)
+		if (!dev->phydev)
 			return -EINVAL;
-		ret = phy_mii_ioctl(priv->phydev, rq, cmd);
+		ret = phy_mii_ioctl(dev->phydev, rq, cmd);
 		break;
 	default:
 		break;
-- 
1.7.4.4
