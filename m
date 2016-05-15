From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: gianfar: use phydev from struct net_device
Date: Mon, 16 May 2016 01:30:08 +0200
Message-ID: <1463355009-19803-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: claudiu.manoil@freescale.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phydev in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/freescale/gianfar.c         |   42 +++++++++++----------
 drivers/net/ethernet/freescale/gianfar.h         |    1 -
 drivers/net/ethernet/freescale/gianfar_ethtool.c |   24 +++++++------
 3 files changed, 35 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index a580041..7615e06 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -999,7 +999,7 @@ static int gfar_hwtstamp_get(struct net_device *netdev, struct ifreq *ifr)
 
 static int gfar_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct gfar_private *priv = netdev_priv(dev);
+	struct phy_device *phydev = dev->phydev;
 
 	if (!netif_running(dev))
 		return -EINVAL;
@@ -1009,10 +1009,10 @@ static int gfar_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	if (cmd == SIOCGHWTSTAMP)
 		return gfar_hwtstamp_get(dev, rq);
 
-	if (!priv->phydev)
+	if (!phydev)
 		return -ENODEV;
 
-	return phy_mii_ioctl(priv->phydev, rq, cmd);
+	return phy_mii_ioctl(phydev, rq, cmd);
 }
 
 static u32 cluster_entry_per_class(struct gfar_private *priv, u32 rqfar,
@@ -1635,7 +1635,7 @@ static int gfar_suspend(struct device *dev)
 		gfar_start_wol_filer(priv);
 
 	} else {
-		phy_stop(priv->phydev);
+		phy_stop(ndev->phydev);
 	}
 
 	return 0;
@@ -1664,7 +1664,7 @@ static int gfar_resume(struct device *dev)
 		gfar_filer_restore_table(priv);
 
 	} else {
-		phy_start(priv->phydev);
+		phy_start(ndev->phydev);
 	}
 
 	gfar_start(priv);
@@ -1698,8 +1698,8 @@ static int gfar_restore(struct device *dev)
 	priv->oldspeed = 0;
 	priv->oldduplex = -1;
 
-	if (priv->phydev)
-		phy_start(priv->phydev);
+	if (ndev->phydev)
+		phy_start(ndev->phydev);
 
 	netif_device_attach(ndev);
 	enable_napi(priv);
@@ -1778,6 +1778,7 @@ static int init_phy(struct net_device *dev)
 		priv->device_flags & FSL_GIANFAR_DEV_HAS_GIGABIT ?
 		GFAR_SUPPORTED_GBIT : 0;
 	phy_interface_t interface;
+	struct phy_device *phydev;
 
 	priv->oldlink = 0;
 	priv->oldspeed = 0;
@@ -1785,9 +1786,9 @@ static int init_phy(struct net_device *dev)
 
 	interface = gfar_get_interface(dev);
 
-	priv->phydev = of_phy_connect(dev, priv->phy_node, &adjust_link, 0,
-				      interface);
-	if (!priv->phydev) {
+	phydev = of_phy_connect(dev, priv->phy_node, &adjust_link, 0,
+				interface);
+	if (!phydev) {
 		dev_err(&dev->dev, "could not attach to PHY\n");
 		return -ENODEV;
 	}
@@ -1796,11 +1797,11 @@ static int init_phy(struct net_device *dev)
 		gfar_configure_serdes(dev);
 
 	/* Remove any features not supported by the controller */
-	priv->phydev->supported &= (GFAR_SUPPORTED | gigabit_support);
-	priv->phydev->advertising = priv->phydev->supported;
+	phydev->supported &= (GFAR_SUPPORTED | gigabit_support);
+	phydev->advertising = phydev->supported;
 
 	/* Add support for flow control, but don't advertise it by default */
-	priv->phydev->supported |= (SUPPORTED_Pause | SUPPORTED_Asym_Pause);
+	phydev->supported |= (SUPPORTED_Pause | SUPPORTED_Asym_Pause);
 
 	return 0;
 }
@@ -1944,7 +1945,7 @@ void stop_gfar(struct net_device *dev)
 	/* disable ints and gracefully shut down Rx/Tx DMA */
 	gfar_halt(priv);
 
-	phy_stop(priv->phydev);
+	phy_stop(dev->phydev);
 
 	free_skb_resources(priv);
 }
@@ -2204,7 +2205,7 @@ int startup_gfar(struct net_device *ndev)
 	priv->oldspeed = 0;
 	priv->oldduplex = -1;
 
-	phy_start(priv->phydev);
+	phy_start(ndev->phydev);
 
 	enable_napi(priv);
 
@@ -2572,8 +2573,7 @@ static int gfar_close(struct net_device *dev)
 	stop_gfar(dev);
 
 	/* Disconnect from the PHY */
-	phy_disconnect(priv->phydev);
-	priv->phydev = NULL;
+	phy_disconnect(dev->phydev);
 
 	gfar_free_irq(priv);
 
@@ -3379,7 +3379,7 @@ static irqreturn_t gfar_interrupt(int irq, void *grp_id)
 static void adjust_link(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
-	struct phy_device *phydev = priv->phydev;
+	struct phy_device *phydev = dev->phydev;
 
 	if (unlikely(phydev->link != priv->oldlink ||
 		     (phydev->link && (phydev->duplex != priv->oldduplex ||
@@ -3620,7 +3620,8 @@ static irqreturn_t gfar_error(int irq, void *grp_id)
 
 static u32 gfar_get_flowctrl_cfg(struct gfar_private *priv)
 {
-	struct phy_device *phydev = priv->phydev;
+	struct net_device *ndev = priv->ndev;
+	struct phy_device *phydev = ndev->phydev;
 	u32 val = 0;
 
 	if (!phydev->duplex)
@@ -3660,7 +3661,8 @@ static u32 gfar_get_flowctrl_cfg(struct gfar_private *priv)
 static noinline void gfar_update_link_state(struct gfar_private *priv)
 {
 	struct gfar __iomem *regs = priv->gfargrp[0].regs;
-	struct phy_device *phydev = priv->phydev;
+	struct net_device *ndev = priv->ndev;
+	struct phy_device *phydev = ndev->phydev;
 	struct gfar_priv_rx_q *rx_queue = NULL;
 	int i;
 
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index cb77667..373fd09 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -1153,7 +1153,6 @@ struct gfar_private {
 	phy_interface_t interface;
 	struct device_node *phy_node;
 	struct device_node *tbi_node;
-	struct phy_device *phydev;
 	struct mii_bus *mii_bus;
 	int oldspeed;
 	int oldduplex;
diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index 2c45c80..94a8dc5 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -188,10 +188,9 @@ static void gfar_gdrvinfo(struct net_device *dev,
 static int gfar_set_ksettings(struct net_device *dev,
 			      const struct ethtool_link_ksettings *cmd)
 {
-	struct gfar_private *priv = netdev_priv(dev);
-	struct phy_device *phydev = priv->phydev;
+	struct phy_device *phydev = dev->phydev;
 
-	if (NULL == phydev)
+	if (!phydev)
 		return -ENODEV;
 
 	return phy_ethtool_ksettings_set(phydev, cmd);
@@ -200,10 +199,9 @@ static int gfar_set_ksettings(struct net_device *dev,
 static int gfar_get_ksettings(struct net_device *dev,
 			      struct ethtool_link_ksettings *cmd)
 {
-	struct gfar_private *priv = netdev_priv(dev);
-	struct phy_device *phydev = priv->phydev;
+	struct phy_device *phydev = dev->phydev;
 
-	if (NULL == phydev)
+	if (!phydev)
 		return -ENODEV;
 
 	return phy_ethtool_ksettings_get(phydev, cmd);
@@ -233,10 +231,12 @@ static void gfar_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 static unsigned int gfar_usecs2ticks(struct gfar_private *priv,
 				     unsigned int usecs)
 {
+	struct net_device *ndev = priv->ndev;
+	struct phy_device *phydev = ndev->phydev;
 	unsigned int count;
 
 	/* The timer is different, depending on the interface speed */
-	switch (priv->phydev->speed) {
+	switch (phydev->speed) {
 	case SPEED_1000:
 		count = GFAR_GBIT_TIME;
 		break;
@@ -258,10 +258,12 @@ static unsigned int gfar_usecs2ticks(struct gfar_private *priv,
 static unsigned int gfar_ticks2usecs(struct gfar_private *priv,
 				     unsigned int ticks)
 {
+	struct net_device *ndev = priv->ndev;
+	struct phy_device *phydev = ndev->phydev;
 	unsigned int count;
 
 	/* The timer is different, depending on the interface speed */
-	switch (priv->phydev->speed) {
+	switch (phydev->speed) {
 	case SPEED_1000:
 		count = GFAR_GBIT_TIME;
 		break;
@@ -295,7 +297,7 @@ static int gfar_gcoalesce(struct net_device *dev,
 	if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_COALESCE))
 		return -EOPNOTSUPP;
 
-	if (NULL == priv->phydev)
+	if (!dev->phydev)
 		return -ENODEV;
 
 	rx_queue = priv->rx_queue[0];
@@ -356,7 +358,7 @@ static int gfar_scoalesce(struct net_device *dev,
 	if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_COALESCE))
 		return -EOPNOTSUPP;
 
-	if (NULL == priv->phydev)
+	if (!dev->phydev)
 		return -ENODEV;
 
 	/* Check the bounds of the values */
@@ -520,7 +522,7 @@ static int gfar_spauseparam(struct net_device *dev,
 			    struct ethtool_pauseparam *epause)
 {
 	struct gfar_private *priv = netdev_priv(dev);
-	struct phy_device *phydev = priv->phydev;
+	struct phy_device *phydev = dev->phydev;
 	struct gfar __iomem *regs = priv->gfargrp[0].regs;
 	u32 oldadv, newadv;
 
-- 
1.7.4.4
