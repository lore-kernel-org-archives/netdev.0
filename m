From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: bcmgenet: use phydev from struct net_device
Date: Sun,  3 Jul 2016 17:33:56 +0200
Message-ID: <1467560037-21784-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: f.fainelli@gmail.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phy in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c |   45 ++++++++++-------------
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |    1 -
 drivers/net/ethernet/broadcom/genet/bcmmii.c   |   24 ++++++-------
 3 files changed, 31 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 5414563..8d4f849 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -453,29 +453,25 @@ static inline void bcmgenet_rdma_ring_writel(struct bcmgenet_priv *priv,
 static int bcmgenet_get_settings(struct net_device *dev,
 				 struct ethtool_cmd *cmd)
 {
-	struct bcmgenet_priv *priv = netdev_priv(dev);
-
 	if (!netif_running(dev))
 		return -EINVAL;
 
-	if (!priv->phydev)
+	if (!dev->phydev)
 		return -ENODEV;
 
-	return phy_ethtool_gset(priv->phydev, cmd);
+	return phy_ethtool_gset(dev->phydev, cmd);
 }
 
 static int bcmgenet_set_settings(struct net_device *dev,
 				 struct ethtool_cmd *cmd)
 {
-	struct bcmgenet_priv *priv = netdev_priv(dev);
-
 	if (!netif_running(dev))
 		return -EINVAL;
 
-	if (!priv->phydev)
+	if (!dev->phydev)
 		return -ENODEV;
 
-	return phy_ethtool_sset(priv->phydev, cmd);
+	return phy_ethtool_sset(dev->phydev, cmd);
 }
 
 static int bcmgenet_set_rx_csum(struct net_device *dev,
@@ -941,7 +937,7 @@ static int bcmgenet_get_eee(struct net_device *dev, struct ethtool_eee *e)
 	e->eee_active = p->eee_active;
 	e->tx_lpi_timer = bcmgenet_umac_readl(priv, UMAC_EEE_LPI_TIMER);
 
-	return phy_ethtool_get_eee(priv->phydev, e);
+	return phy_ethtool_get_eee(dev->phydev, e);
 }
 
 static int bcmgenet_set_eee(struct net_device *dev, struct ethtool_eee *e)
@@ -958,7 +954,7 @@ static int bcmgenet_set_eee(struct net_device *dev, struct ethtool_eee *e)
 	if (!p->eee_enabled) {
 		bcmgenet_eee_enable_set(dev, false);
 	} else {
-		ret = phy_init_eee(priv->phydev, 0);
+		ret = phy_init_eee(dev->phydev, 0);
 		if (ret) {
 			netif_err(priv, hw, dev, "EEE initialization failed\n");
 			return ret;
@@ -968,14 +964,12 @@ static int bcmgenet_set_eee(struct net_device *dev, struct ethtool_eee *e)
 		bcmgenet_eee_enable_set(dev, true);
 	}
 
-	return phy_ethtool_set_eee(priv->phydev, e);
+	return phy_ethtool_set_eee(dev->phydev, e);
 }
 
 static int bcmgenet_nway_reset(struct net_device *dev)
 {
-	struct bcmgenet_priv *priv = netdev_priv(dev);
-
-	return genphy_restart_aneg(priv->phydev);
+	return genphy_restart_aneg(dev->phydev);
 }
 
 /* standard ethtool support functions. */
@@ -1002,12 +996,13 @@ static struct ethtool_ops bcmgenet_ethtool_ops = {
 static int bcmgenet_power_down(struct bcmgenet_priv *priv,
 				enum bcmgenet_power_mode mode)
 {
+	struct net_device *ndev = priv->dev;
 	int ret = 0;
 	u32 reg;
 
 	switch (mode) {
 	case GENET_POWER_CABLE_SENSE:
-		phy_detach(priv->phydev);
+		phy_detach(ndev->phydev);
 		break;
 
 	case GENET_POWER_WOL_MAGIC:
@@ -1068,7 +1063,6 @@ static void bcmgenet_power_up(struct bcmgenet_priv *priv,
 /* ioctl handle special commands that are not present in ethtool. */
 static int bcmgenet_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct bcmgenet_priv *priv = netdev_priv(dev);
 	int val = 0;
 
 	if (!netif_running(dev))
@@ -1078,10 +1072,10 @@ static int bcmgenet_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	case SIOCGMIIPHY:
 	case SIOCGMIIREG:
 	case SIOCSMIIREG:
-		if (!priv->phydev)
+		if (!dev->phydev)
 			val = -ENODEV;
 		else
-			val = phy_mii_ioctl(priv->phydev, rq, cmd);
+			val = phy_mii_ioctl(dev->phydev, rq, cmd);
 		break;
 
 	default:
@@ -2464,6 +2458,7 @@ static void bcmgenet_irq_task(struct work_struct *work)
 {
 	struct bcmgenet_priv *priv = container_of(
 			work, struct bcmgenet_priv, bcmgenet_irq_work);
+	struct net_device *ndev = priv->dev;
 
 	netif_dbg(priv, intr, priv->dev, "%s\n", __func__);
 
@@ -2476,7 +2471,7 @@ static void bcmgenet_irq_task(struct work_struct *work)
 
 	/* Link UP/DOWN event */
 	if (priv->irq0_stat & UMAC_IRQ_LINK_EVENT) {
-		phy_mac_interrupt(priv->phydev,
+		phy_mac_interrupt(ndev->phydev,
 				  !!(priv->irq0_stat & UMAC_IRQ_LINK_UP));
 		priv->irq0_stat &= ~UMAC_IRQ_LINK_EVENT;
 	}
@@ -2838,7 +2833,7 @@ static void bcmgenet_netif_start(struct net_device *dev)
 	/* Monitor link interrupts now */
 	bcmgenet_link_intr_enable(priv);
 
-	phy_start(priv->phydev);
+	phy_start(dev->phydev);
 }
 
 static int bcmgenet_open(struct net_device *dev)
@@ -2937,7 +2932,7 @@ static void bcmgenet_netif_stop(struct net_device *dev)
 	struct bcmgenet_priv *priv = netdev_priv(dev);
 
 	netif_tx_stop_all_queues(dev);
-	phy_stop(priv->phydev);
+	phy_stop(dev->phydev);
 	bcmgenet_intr_disable(priv);
 	bcmgenet_disable_rx_napi(priv);
 	bcmgenet_disable_tx_napi(priv);
@@ -2963,7 +2958,7 @@ static int bcmgenet_close(struct net_device *dev)
 	bcmgenet_netif_stop(dev);
 
 	/* Really kill the PHY state machine and disconnect from it */
-	phy_disconnect(priv->phydev);
+	phy_disconnect(dev->phydev);
 
 	/* Disable MAC receive */
 	umac_enable_set(priv, CMD_RX_EN, false);
@@ -3522,7 +3517,7 @@ static int bcmgenet_suspend(struct device *d)
 
 	bcmgenet_netif_stop(dev);
 
-	phy_suspend(priv->phydev);
+	phy_suspend(dev->phydev);
 
 	netif_device_detach(dev);
 
@@ -3586,7 +3581,7 @@ static int bcmgenet_resume(struct device *d)
 	if (priv->wolopts)
 		clk_disable_unprepare(priv->clk_wol);
 
-	phy_init_hw(priv->phydev);
+	phy_init_hw(dev->phydev);
 	/* Speed settings must be restored */
 	bcmgenet_mii_config(priv->dev);
 
@@ -3619,7 +3614,7 @@ static int bcmgenet_resume(struct device *d)
 
 	netif_device_attach(dev);
 
-	phy_resume(priv->phydev);
+	phy_resume(dev->phydev);
 
 	if (priv->eee.eee_enabled)
 		bcmgenet_eee_enable_set(dev, true);
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 1e2dc34..0f0868c 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -597,7 +597,6 @@ struct bcmgenet_priv {
 
 	/* MDIO bus variables */
 	wait_queue_head_t wq;
-	struct phy_device *phydev;
 	bool internal_phy;
 	struct device_node *phy_dn;
 	struct device_node *mdio_dn;
diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index 457c3bc..e907acd 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -86,7 +86,7 @@ static int bcmgenet_mii_write(struct mii_bus *bus, int phy_id,
 void bcmgenet_mii_setup(struct net_device *dev)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
-	struct phy_device *phydev = priv->phydev;
+	struct phy_device *phydev = dev->phydev;
 	u32 reg, cmd_bits = 0;
 	bool status_changed = false;
 
@@ -183,9 +183,9 @@ void bcmgenet_mii_reset(struct net_device *dev)
 	if (GENET_IS_V4(priv))
 		return;
 
-	if (priv->phydev) {
-		phy_init_hw(priv->phydev);
-		phy_start_aneg(priv->phydev);
+	if (dev->phydev) {
+		phy_init_hw(dev->phydev);
+		phy_start_aneg(dev->phydev);
 	}
 }
 
@@ -236,6 +236,7 @@ static void bcmgenet_internal_phy_setup(struct net_device *dev)
 
 static void bcmgenet_moca_phy_setup(struct bcmgenet_priv *priv)
 {
+	struct net_device *ndev = priv->dev;
 	u32 reg;
 
 	/* Speed settings are set in bcmgenet_mii_setup() */
@@ -244,14 +245,14 @@ static void bcmgenet_moca_phy_setup(struct bcmgenet_priv *priv)
 	bcmgenet_sys_writel(priv, reg, SYS_PORT_CTRL);
 
 	if (priv->hw_params->flags & GENET_HAS_MOCA_LINK_DET)
-		fixed_phy_set_link_update(priv->phydev,
+		fixed_phy_set_link_update(ndev->phydev,
 					  bcmgenet_fixed_phy_link_update);
 }
 
 int bcmgenet_mii_config(struct net_device *dev)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
-	struct phy_device *phydev = priv->phydev;
+	struct phy_device *phydev = dev->phydev;
 	struct device *kdev = &priv->pdev->dev;
 	const char *phy_name = NULL;
 	u32 id_mode_dis = 0;
@@ -302,7 +303,7 @@ int bcmgenet_mii_config(struct net_device *dev)
 		 * capabilities, use that knowledge to also configure the
 		 * Reverse MII interface correctly.
 		 */
-		if ((priv->phydev->supported & PHY_BASIC_FEATURES) ==
+		if ((phydev->supported & PHY_BASIC_FEATURES) ==
 				PHY_BASIC_FEATURES)
 			port_ctrl = PORT_MODE_EXT_RVMII_25;
 		else
@@ -371,7 +372,7 @@ int bcmgenet_mii_probe(struct net_device *dev)
 			return -ENODEV;
 		}
 	} else {
-		phydev = priv->phydev;
+		phydev = dev->phydev;
 		phydev->dev_flags = phy_flags;
 
 		ret = phy_connect_direct(dev, phydev, bcmgenet_mii_setup,
@@ -382,8 +383,6 @@ int bcmgenet_mii_probe(struct net_device *dev)
 		}
 	}
 
-	priv->phydev = phydev;
-
 	/* Configure port multiplexer based on what the probed PHY device since
 	 * reading the 'max-speed' property determines the maximum supported
 	 * PHY speed which is needed for bcmgenet_mii_config() to configure
@@ -391,7 +390,7 @@ int bcmgenet_mii_probe(struct net_device *dev)
 	 */
 	ret = bcmgenet_mii_config(dev);
 	if (ret) {
-		phy_disconnect(priv->phydev);
+		phy_disconnect(phydev);
 		return ret;
 	}
 
@@ -401,7 +400,7 @@ int bcmgenet_mii_probe(struct net_device *dev)
 	 * Ethernet MAC ISRs
 	 */
 	if (priv->internal_phy)
-		priv->phydev->irq = PHY_IGNORE_INTERRUPT;
+		phydev->irq = PHY_IGNORE_INTERRUPT;
 
 	return 0;
 }
@@ -606,7 +605,6 @@ static int bcmgenet_mii_pd_init(struct bcmgenet_priv *priv)
 
 	}
 
-	priv->phydev = phydev;
 	priv->phy_interface = pd->phy_interface;
 
 	return 0;
-- 
1.7.4.4
