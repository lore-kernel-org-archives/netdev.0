From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: stmmac: use phydev from struct net_device
Date: Sun,  2 Oct 2016 22:07:50 +0200
Message-ID: <1475438871-26735-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com,
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
 .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    |    4 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    1 -
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |   18 +++++-----
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   39 ++++++++++----------
 4 files changed, 30 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
index bec6963..5ad1dfb 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
@@ -367,8 +367,8 @@ static int socfpga_dwmac_resume(struct device *dev)
 	 * control register 0, and can be modified by the phy driver
 	 * framework.
 	 */
-	if (priv->phydev)
-		phy_resume(priv->phydev);
+	if (ndev->phydev)
+		phy_resume(ndev->phydev);
 
 	return stmmac_resume(dev);
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 8dc9056..f94e028 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -90,7 +90,6 @@ struct stmmac_priv {
 	struct mac_device_info *hw;
 	spinlock_t lock;
 
-	struct phy_device *phydev ____cacheline_aligned_in_smp;
 	int oldlink;
 	int speed;
 	int oldduplex;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index 1e06173..ac823bf 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -273,7 +273,7 @@ static int stmmac_ethtool_getsettings(struct net_device *dev,
 				      struct ethtool_cmd *cmd)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
-	struct phy_device *phy = priv->phydev;
+	struct phy_device *phy = dev->phydev;
 	int rc;
 
 	if (priv->hw->pcs & STMMAC_PCS_RGMII ||
@@ -359,7 +359,7 @@ static int stmmac_ethtool_setsettings(struct net_device *dev,
 				      struct ethtool_cmd *cmd)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
-	struct phy_device *phy = priv->phydev;
+	struct phy_device *phy = dev->phydev;
 	int rc;
 
 	if (priv->hw->pcs & STMMAC_PCS_RGMII ||
@@ -468,12 +468,12 @@ stmmac_get_pauseparam(struct net_device *netdev,
 		if (!adv_lp.pause)
 			return;
 	} else {
-		if (!(priv->phydev->supported & SUPPORTED_Pause) ||
-		    !(priv->phydev->supported & SUPPORTED_Asym_Pause))
+		if (!(netdev->phydev->supported & SUPPORTED_Pause) ||
+		    !(netdev->phydev->supported & SUPPORTED_Asym_Pause))
 			return;
 	}
 
-	pause->autoneg = priv->phydev->autoneg;
+	pause->autoneg = netdev->phydev->autoneg;
 
 	if (priv->flow_ctrl & FLOW_RX)
 		pause->rx_pause = 1;
@@ -487,7 +487,7 @@ stmmac_set_pauseparam(struct net_device *netdev,
 		      struct ethtool_pauseparam *pause)
 {
 	struct stmmac_priv *priv = netdev_priv(netdev);
-	struct phy_device *phy = priv->phydev;
+	struct phy_device *phy = netdev->phydev;
 	int new_pause = FLOW_OFF;
 
 	if (priv->hw->pcs && priv->hw->mac->pcs_get_adv_lp) {
@@ -547,7 +547,7 @@ static void stmmac_get_ethtool_stats(struct net_device *dev,
 			}
 		}
 		if (priv->eee_enabled) {
-			int val = phy_get_eee_err(priv->phydev);
+			int val = phy_get_eee_err(dev->phydev);
 			if (val)
 				priv->xstats.phy_eee_wakeup_error_n = val;
 		}
@@ -666,7 +666,7 @@ static int stmmac_ethtool_op_get_eee(struct net_device *dev,
 	edata->eee_active = priv->eee_active;
 	edata->tx_lpi_timer = priv->tx_lpi_timer;
 
-	return phy_ethtool_get_eee(priv->phydev, edata);
+	return phy_ethtool_get_eee(dev->phydev, edata);
 }
 
 static int stmmac_ethtool_op_set_eee(struct net_device *dev,
@@ -691,7 +691,7 @@ static int stmmac_ethtool_op_set_eee(struct net_device *dev,
 		priv->tx_lpi_timer = edata->tx_lpi_timer;
 	}
 
-	return phy_ethtool_set_eee(priv->phydev, edata);
+	return phy_ethtool_set_eee(dev->phydev, edata);
 }
 
 static u32 stmmac_usec2riwt(u32 usec, struct stmmac_priv *priv)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 4c8c60a..d815c82 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -221,7 +221,8 @@ static inline u32 stmmac_rx_dirty(struct stmmac_priv *priv)
  */
 static inline void stmmac_hw_fix_mac_speed(struct stmmac_priv *priv)
 {
-	struct phy_device *phydev = priv->phydev;
+	struct net_device *ndev = priv->dev;
+	struct phy_device *phydev = ndev->phydev;
 
 	if (likely(priv->plat->fix_mac_speed))
 		priv->plat->fix_mac_speed(priv->plat->bsp_priv, phydev->speed);
@@ -279,6 +280,7 @@ static void stmmac_eee_ctrl_timer(unsigned long arg)
  */
 bool stmmac_eee_init(struct stmmac_priv *priv)
 {
+	struct net_device *ndev = priv->dev;
 	unsigned long flags;
 	bool ret = false;
 
@@ -295,7 +297,7 @@ bool stmmac_eee_init(struct stmmac_priv *priv)
 		int tx_lpi_timer = priv->tx_lpi_timer;
 
 		/* Check if the PHY supports EEE */
-		if (phy_init_eee(priv->phydev, 1)) {
+		if (phy_init_eee(ndev->phydev, 1)) {
 			/* To manage at run-time if the EEE cannot be supported
 			 * anymore (for example because the lp caps have been
 			 * changed).
@@ -327,7 +329,7 @@ bool stmmac_eee_init(struct stmmac_priv *priv)
 						     tx_lpi_timer);
 		}
 		/* Set HW EEE according to the speed */
-		priv->hw->mac->set_eee_pls(priv->hw, priv->phydev->link);
+		priv->hw->mac->set_eee_pls(priv->hw, ndev->phydev->link);
 
 		ret = true;
 		spin_unlock_irqrestore(&priv->lock, flags);
@@ -691,7 +693,7 @@ static void stmmac_release_ptp(struct stmmac_priv *priv)
 static void stmmac_adjust_link(struct net_device *dev)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
-	struct phy_device *phydev = priv->phydev;
+	struct phy_device *phydev = dev->phydev;
 	unsigned long flags;
 	int new_state = 0;
 	unsigned int fc = priv->flow_ctrl, pause_time = priv->pause;
@@ -874,8 +876,6 @@ static int stmmac_init_phy(struct net_device *dev)
 	pr_debug("stmmac_init_phy:  %s: attached to PHY (UID 0x%x)"
 		 " Link = %d\n", dev->name, phydev->phy_id, phydev->link);
 
-	priv->phydev = phydev;
-
 	return 0;
 }
 
@@ -1800,8 +1800,8 @@ static int stmmac_open(struct net_device *dev)
 
 	stmmac_init_tx_coalesce(priv);
 
-	if (priv->phydev)
-		phy_start(priv->phydev);
+	if (dev->phydev)
+		phy_start(dev->phydev);
 
 	/* Request the IRQ lines */
 	ret = request_irq(dev->irq, stmmac_interrupt,
@@ -1848,8 +1848,8 @@ wolirq_error:
 init_error:
 	free_dma_desc_resources(priv);
 dma_desc_error:
-	if (priv->phydev)
-		phy_disconnect(priv->phydev);
+	if (dev->phydev)
+		phy_disconnect(dev->phydev);
 
 	return ret;
 }
@@ -1868,10 +1868,9 @@ static int stmmac_release(struct net_device *dev)
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
 
 	netif_stop_queue(dev);
@@ -2873,9 +2872,9 @@ static int stmmac_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	case SIOCGMIIPHY:
 	case SIOCGMIIREG:
 	case SIOCSMIIREG:
-		if (!priv->phydev)
+		if (!dev->phydev)
 			return -EINVAL;
-		ret = phy_mii_ioctl(priv->phydev, rq, cmd);
+		ret = phy_mii_ioctl(dev->phydev, rq, cmd);
 		break;
 	case SIOCSHWTSTAMP:
 		ret = stmmac_hwtstamp_ioctl(dev, rq);
@@ -3428,8 +3427,8 @@ int stmmac_suspend(struct device *dev)
 	if (!ndev || !netif_running(ndev))
 		return 0;
 
-	if (priv->phydev)
-		phy_stop(priv->phydev);
+	if (ndev->phydev)
+		phy_stop(ndev->phydev);
 
 	spin_lock_irqsave(&priv->lock, flags);
 
@@ -3523,8 +3522,8 @@ int stmmac_resume(struct device *dev)
 
 	spin_unlock_irqrestore(&priv->lock, flags);
 
-	if (priv->phydev)
-		phy_start(priv->phydev);
+	if (ndev->phydev)
+		phy_start(ndev->phydev);
 
 	return 0;
 }
-- 
1.7.4.4
