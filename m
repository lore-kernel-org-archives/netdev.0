From: Doug Berger <opendmb@gmail.com>
Subject: [PATCH net-next 9/9] net: bcmgenet: use dev->phydev instead of priv->phydev
Date: Wed, 25 Oct 2017 15:04:19 -0700
Message-ID: <20171025220419.24951-10-opendmb@gmail.com>
References: <20171025220419.24951-1-opendmb@gmail.com>
Cc: Doug Berger <opendmb@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171025220419.24951-1-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that the software reset of the PHY has been removed it is no
longer necessary to retain a private pointer to the phydev for
use when the PHY is detached (which isn't generally safe anyway).

The driver now uses the phydev member attached to the net_device.

For ethtool commands that have a PHY component, an explicit check
is made to prevent accessing an invalid phydev pointer when one
is not attached (e.g. interface is down).

Signed-off-by: Doug Berger <opendmb@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 47 +++++++++++++-------------
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  1 -
 drivers/net/ethernet/broadcom/genet/bcmmii.c   | 17 ++++------
 3 files changed, 31 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 54b09a01cb2c..9713374ebf14 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -488,15 +488,13 @@ static void bcmgenet_complete(struct net_device *dev)
 static int bcmgenet_get_link_ksettings(struct net_device *dev,
 				       struct ethtool_link_ksettings *cmd)
 {
-	struct bcmgenet_priv *priv = netdev_priv(dev);
-
 	if (!netif_running(dev))
 		return -EINVAL;
 
-	if (!priv->phydev)
+	if (!dev->phydev)
 		return -ENODEV;
 
-	phy_ethtool_ksettings_get(priv->phydev, cmd);
+	phy_ethtool_ksettings_get(dev->phydev, cmd);
 
 	return 0;
 }
@@ -504,15 +502,13 @@ static int bcmgenet_get_link_ksettings(struct net_device *dev,
 static int bcmgenet_set_link_ksettings(struct net_device *dev,
 				       const struct ethtool_link_ksettings *cmd)
 {
-	struct bcmgenet_priv *priv = netdev_priv(dev);
-
 	if (!netif_running(dev))
 		return -EINVAL;
 
-	if (!priv->phydev)
+	if (!dev->phydev)
 		return -ENODEV;
 
-	return phy_ethtool_ksettings_set(priv->phydev, cmd);
+	return phy_ethtool_ksettings_set(dev->phydev, cmd);
 }
 
 static int bcmgenet_set_rx_csum(struct net_device *dev,
@@ -1042,11 +1038,14 @@ static int bcmgenet_get_eee(struct net_device *dev, struct ethtool_eee *e)
 	if (GENET_IS_V1(priv))
 		return -EOPNOTSUPP;
 
+	if (!dev->phydev)
+		return -ENODEV;
+
 	e->eee_enabled = p->eee_enabled;
 	e->eee_active = p->eee_active;
 	e->tx_lpi_timer = bcmgenet_umac_readl(priv, UMAC_EEE_LPI_TIMER);
 
-	return phy_ethtool_get_eee(priv->phydev, e);
+	return phy_ethtool_get_eee(dev->phydev, e);
 }
 
 static int bcmgenet_set_eee(struct net_device *dev, struct ethtool_eee *e)
@@ -1058,12 +1057,15 @@ static int bcmgenet_set_eee(struct net_device *dev, struct ethtool_eee *e)
 	if (GENET_IS_V1(priv))
 		return -EOPNOTSUPP;
 
+	if (!dev->phydev)
+		return -ENODEV;
+
 	p->eee_enabled = e->eee_enabled;
 
 	if (!p->eee_enabled) {
 		bcmgenet_eee_enable_set(dev, false);
 	} else {
-		ret = phy_init_eee(priv->phydev, 0);
+		ret = phy_init_eee(dev->phydev, 0);
 		if (ret) {
 			netif_err(priv, hw, dev, "EEE initialization failed\n");
 			return ret;
@@ -1073,7 +1075,7 @@ static int bcmgenet_set_eee(struct net_device *dev, struct ethtool_eee *e)
 		bcmgenet_eee_enable_set(dev, true);
 	}
 
-	return phy_ethtool_set_eee(priv->phydev, e);
+	return phy_ethtool_set_eee(dev->phydev, e);
 }
 
 /* standard ethtool support functions. */
@@ -1107,7 +1109,7 @@ static int bcmgenet_power_down(struct bcmgenet_priv *priv,
 
 	switch (mode) {
 	case GENET_POWER_CABLE_SENSE:
-		phy_detach(priv->phydev);
+		phy_detach(priv->dev->phydev);
 		break;
 
 	case GENET_POWER_WOL_MAGIC:
@@ -1192,15 +1194,13 @@ static void bcmgenet_power_up(struct bcmgenet_priv *priv,
 /* ioctl handle special commands that are not present in ethtool. */
 static int bcmgenet_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct bcmgenet_priv *priv = netdev_priv(dev);
-
 	if (!netif_running(dev))
 		return -EINVAL;
 
-	if (!priv->phydev)
+	if (!dev->phydev)
 		return -ENODEV;
 
-	return phy_mii_ioctl(priv->phydev, rq, cmd);
+	return phy_mii_ioctl(dev->phydev, rq, cmd);
 }
 
 static struct enet_cb *bcmgenet_get_txcb(struct bcmgenet_priv *priv,
@@ -2529,7 +2529,7 @@ static void bcmgenet_irq_task(struct work_struct *work)
 
 	/* Link UP/DOWN event */
 	if (status & UMAC_IRQ_LINK_EVENT)
-		phy_mac_interrupt(priv->phydev,
+		phy_mac_interrupt(priv->dev->phydev,
 				  !!(status & UMAC_IRQ_LINK_UP));
 }
 
@@ -2767,7 +2767,7 @@ static void bcmgenet_netif_start(struct net_device *dev)
 	/* Monitor link interrupts now */
 	bcmgenet_link_intr_enable(priv);
 
-	phy_start(priv->phydev);
+	phy_start(dev->phydev);
 }
 
 static int bcmgenet_open(struct net_device *dev)
@@ -2874,7 +2874,7 @@ static void bcmgenet_netif_stop(struct net_device *dev)
 	/* Disable MAC transmit. TX DMA disabled must be done before this */
 	umac_enable_set(priv, CMD_TX_EN, false);
 
-	phy_stop(priv->phydev);
+	phy_stop(dev->phydev);
 	bcmgenet_disable_rx_napi(priv);
 	bcmgenet_intr_disable(priv);
 
@@ -2903,7 +2903,7 @@ static int bcmgenet_close(struct net_device *dev)
 	bcmgenet_netif_stop(dev);
 
 	/* Really kill the PHY state machine and disconnect from it */
-	phy_disconnect(priv->phydev);
+	phy_disconnect(dev->phydev);
 
 	free_irq(priv->irq0, priv);
 	free_irq(priv->irq1, priv);
@@ -3523,7 +3523,7 @@ static int bcmgenet_suspend(struct device *d)
 	bcmgenet_netif_stop(dev);
 
 	if (!device_may_wakeup(d))
-		phy_suspend(priv->phydev);
+		phy_suspend(dev->phydev);
 
 	netif_device_detach(dev);
 
@@ -3571,7 +3571,8 @@ static int bcmgenet_resume(struct device *d)
 	if (priv->wolopts)
 		clk_disable_unprepare(priv->clk_wol);
 
-	phy_init_hw(priv->phydev);
+	phy_init_hw(dev->phydev);
+
 	/* Speed settings must be restored */
 	bcmgenet_mii_config(priv->dev, false);
 
@@ -3602,7 +3603,7 @@ static int bcmgenet_resume(struct device *d)
 	netif_device_attach(dev);
 
 	if (!device_may_wakeup(d))
-		phy_resume(priv->phydev);
+		phy_resume(dev->phydev);
 
 	if (priv->eee.eee_enabled)
 		bcmgenet_eee_enable_set(dev, true);
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 35f18a8d1ce6..3c50431ccd2a 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -617,7 +617,6 @@ struct bcmgenet_priv {
 
 	/* MDIO bus variables */
 	wait_queue_head_t wq;
-	struct phy_device *phydev;
 	bool internal_phy;
 	struct device_node *phy_dn;
 	struct device_node *mdio_dn;
diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index a5ae9b78389c..ba3fcfdaa0bc 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -34,7 +34,7 @@
 void bcmgenet_mii_setup(struct net_device *dev)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
-	struct phy_device *phydev = priv->phydev;
+	struct phy_device *phydev = dev->phydev;
 	u32 reg, cmd_bits = 0;
 	bool status_changed = false;
 
@@ -166,14 +166,14 @@ static void bcmgenet_moca_phy_setup(struct bcmgenet_priv *priv)
 	}
 
 	if (priv->hw_params->flags & GENET_HAS_MOCA_LINK_DET)
-		fixed_phy_set_link_update(priv->phydev,
+		fixed_phy_set_link_update(priv->dev->phydev,
 					  bcmgenet_fixed_phy_link_update);
 }
 
 int bcmgenet_mii_config(struct net_device *dev, bool init)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
-	struct phy_device *phydev = priv->phydev;
+	struct phy_device *phydev = dev->phydev;
 	struct device *kdev = &priv->pdev->dev;
 	const char *phy_name = NULL;
 	u32 id_mode_dis = 0;
@@ -220,7 +220,7 @@ int bcmgenet_mii_config(struct net_device *dev, bool init)
 		 * capabilities, use that knowledge to also configure the
 		 * Reverse MII interface correctly.
 		 */
-		if ((priv->phydev->supported & PHY_BASIC_FEATURES) ==
+		if ((dev->phydev->supported & PHY_BASIC_FEATURES) ==
 				PHY_BASIC_FEATURES)
 			port_ctrl = PORT_MODE_EXT_RVMII_25;
 		else
@@ -290,7 +290,7 @@ int bcmgenet_mii_probe(struct net_device *dev)
 			return -ENODEV;
 		}
 	} else {
-		phydev = priv->phydev;
+		phydev = dev->phydev;
 		phydev->dev_flags = phy_flags;
 
 		ret = phy_connect_direct(dev, phydev, bcmgenet_mii_setup,
@@ -301,8 +301,6 @@ int bcmgenet_mii_probe(struct net_device *dev)
 		}
 	}
 
-	priv->phydev = phydev;
-
 	/* Configure port multiplexer based on what the probed PHY device since
 	 * reading the 'max-speed' property determines the maximum supported
 	 * PHY speed which is needed for bcmgenet_mii_config() to configure
@@ -310,7 +308,7 @@ int bcmgenet_mii_probe(struct net_device *dev)
 	 */
 	ret = bcmgenet_mii_config(dev, true);
 	if (ret) {
-		phy_disconnect(priv->phydev);
+		phy_disconnect(dev->phydev);
 		return ret;
 	}
 
@@ -320,7 +318,7 @@ int bcmgenet_mii_probe(struct net_device *dev)
 	 * Ethernet MAC ISRs
 	 */
 	if (priv->internal_phy)
-		priv->phydev->irq = PHY_IGNORE_INTERRUPT;
+		dev->phydev->irq = PHY_IGNORE_INTERRUPT;
 
 	return 0;
 }
@@ -529,7 +527,6 @@ static int bcmgenet_mii_pd_init(struct bcmgenet_priv *priv)
 
 	}
 
-	priv->phydev = phydev;
 	priv->phy_interface = pd->phy_interface;
 
 	return 0;
-- 
2.14.1
