From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: marvell: mvneta: use phydev from struct net_device
Date: Sat, 30 Jul 2016 17:42:11 +0200
Message-ID: <1469893332-24535-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: thomas.petazzoni@free-electrons.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35979 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751177AbcG3PmW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jul 2016 11:42:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phy_dev in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/marvell/mvneta.c |   34 +++++++++++++++-----------------
 1 files changed, 16 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index f92018b..410adc7 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -399,7 +399,6 @@ struct mvneta_port {
 	u16 rx_ring_size;
 
 	struct mii_bus *mii_bus;
-	struct phy_device *phy_dev;
 	phy_interface_t phy_interface;
 	struct device_node *phy_node;
 	unsigned int link;
@@ -2651,6 +2650,7 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
 	u32 cause_rx_tx;
 	int rx_queue;
 	struct mvneta_port *pp = netdev_priv(napi->dev);
+	struct net_device *ndev = pp->dev;
 	struct mvneta_pcpu_port *port = this_cpu_ptr(pp->ports);
 
 	if (!netif_running(pp->dev)) {
@@ -2668,7 +2668,7 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
 				(MVNETA_CAUSE_PHY_STATUS_CHANGE |
 				 MVNETA_CAUSE_LINK_CHANGE |
 				 MVNETA_CAUSE_PSC_SYNC_CHANGE))) {
-			mvneta_fixed_link_update(pp, pp->phy_dev);
+			mvneta_fixed_link_update(pp, ndev->phydev);
 		}
 	}
 
@@ -2963,6 +2963,7 @@ static int mvneta_setup_txqs(struct mvneta_port *pp)
 static void mvneta_start_dev(struct mvneta_port *pp)
 {
 	int cpu;
+	struct net_device *ndev = pp->dev;
 
 	mvneta_max_rx_size_set(pp, pp->pkt_size);
 	mvneta_txq_max_tx_size_set(pp, pp->pkt_size);
@@ -2985,15 +2986,16 @@ static void mvneta_start_dev(struct mvneta_port *pp)
 		    MVNETA_CAUSE_LINK_CHANGE |
 		    MVNETA_CAUSE_PSC_SYNC_CHANGE);
 
-	phy_start(pp->phy_dev);
+	phy_start(ndev->phydev);
 	netif_tx_start_all_queues(pp->dev);
 }
 
 static void mvneta_stop_dev(struct mvneta_port *pp)
 {
 	unsigned int cpu;
+	struct net_device *ndev = pp->dev;
 
-	phy_stop(pp->phy_dev);
+	phy_stop(ndev->phydev);
 
 	for_each_online_cpu(cpu) {
 		struct mvneta_pcpu_port *port = per_cpu_ptr(pp->ports, cpu);
@@ -3166,7 +3168,7 @@ static int mvneta_set_mac_addr(struct net_device *dev, void *addr)
 static void mvneta_adjust_link(struct net_device *ndev)
 {
 	struct mvneta_port *pp = netdev_priv(ndev);
-	struct phy_device *phydev = pp->phy_dev;
+	struct phy_device *phydev = ndev->phydev;
 	int status_change = 0;
 
 	if (phydev->link) {
@@ -3244,7 +3246,6 @@ static int mvneta_mdio_probe(struct mvneta_port *pp)
 	phy_dev->supported &= PHY_GBIT_FEATURES;
 	phy_dev->advertising = phy_dev->supported;
 
-	pp->phy_dev = phy_dev;
 	pp->link    = 0;
 	pp->duplex  = 0;
 	pp->speed   = 0;
@@ -3254,8 +3255,9 @@ static int mvneta_mdio_probe(struct mvneta_port *pp)
 
 static void mvneta_mdio_remove(struct mvneta_port *pp)
 {
-	phy_disconnect(pp->phy_dev);
-	pp->phy_dev = NULL;
+	struct net_device *ndev = pp->dev;
+
+	phy_disconnect(ndev->phydev);
 }
 
 /* Electing a CPU must be done in an atomic way: it should be done
@@ -3495,12 +3497,10 @@ static int mvneta_stop(struct net_device *dev)
 
 static int mvneta_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	struct mvneta_port *pp = netdev_priv(dev);
-
-	if (!pp->phy_dev)
+	if (!dev->phydev)
 		return -ENOTSUPP;
 
-	return phy_mii_ioctl(pp->phy_dev, ifr, cmd);
+	return phy_mii_ioctl(dev->phydev, ifr, cmd);
 }
 
 /* Ethtool methods */
@@ -3508,19 +3508,17 @@ static int mvneta_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 /* Get settings (phy address, speed) for ethtools */
 int mvneta_ethtool_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct mvneta_port *pp = netdev_priv(dev);
-
-	if (!pp->phy_dev)
+	if (!dev->phydev)
 		return -ENODEV;
 
-	return phy_ethtool_gset(pp->phy_dev, cmd);
+	return phy_ethtool_gset(dev->phydev, cmd);
 }
 
 /* Set settings (phy address, speed) for ethtools */
 int mvneta_ethtool_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct mvneta_port *pp = netdev_priv(dev);
-	struct phy_device *phydev = pp->phy_dev;
+	struct phy_device *phydev = dev->phydev;
 
 	if (!phydev)
 		return -ENODEV;
@@ -3557,7 +3555,7 @@ int mvneta_ethtool_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		}
 	}
 
-	return phy_ethtool_sset(pp->phy_dev, cmd);
+	return phy_ethtool_sset(dev->phydev, cmd);
 }
 
 /* Set interrupt coalescing for ethtools */
-- 
1.7.4.4
