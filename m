From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: ixp4xx_eth: use phydev from struct net_device
Date: Sat,  2 Jul 2016 14:06:14 +0200
Message-ID: <1467461175-25137-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: khalasa@piap.pl, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35047 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161AbcGBMG1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 08:06:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phy in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/xscale/ixp4xx_eth.c |   36 +++++++++++++----------------
 1 files changed, 16 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/xscale/ixp4xx_eth.c b/drivers/net/ethernet/xscale/ixp4xx_eth.c
index 5138407..a7778d9 100644
--- a/drivers/net/ethernet/xscale/ixp4xx_eth.c
+++ b/drivers/net/ethernet/xscale/ixp4xx_eth.c
@@ -171,7 +171,6 @@ struct port {
 	struct npe *npe;
 	struct net_device *netdev;
 	struct napi_struct napi;
-	struct phy_device *phydev;
 	struct eth_plat_info *plat;
 	buffer_t *rx_buff_tab[RX_DESCS], *tx_buff_tab[TX_DESCS];
 	struct desc *desc_tab;	/* coherent */
@@ -562,7 +561,7 @@ static void ixp4xx_mdio_remove(void)
 static void ixp4xx_adjust_link(struct net_device *dev)
 {
 	struct port *port = netdev_priv(dev);
-	struct phy_device *phydev = port->phydev;
+	struct phy_device *phydev = dev->phydev;
 
 	if (!phydev->link) {
 		if (port->speed) {
@@ -976,8 +975,6 @@ static void eth_set_mcast_list(struct net_device *dev)
 
 static int eth_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 {
-	struct port *port = netdev_priv(dev);
-
 	if (!netif_running(dev))
 		return -EINVAL;
 
@@ -988,7 +985,7 @@ static int eth_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 			return hwtstamp_get(dev, req);
 	}
 
-	return phy_mii_ioctl(port->phydev, req, cmd);
+	return phy_mii_ioctl(dev->phydev, req, cmd);
 }
 
 /* ethtool support */
@@ -1007,20 +1004,17 @@ static void ixp4xx_get_drvinfo(struct net_device *dev,
 
 static int ixp4xx_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct port *port = netdev_priv(dev);
-	return phy_ethtool_gset(port->phydev, cmd);
+	return phy_ethtool_gset(dev->phydev, cmd);
 }
 
 static int ixp4xx_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct port *port = netdev_priv(dev);
-	return phy_ethtool_sset(port->phydev, cmd);
+	return phy_ethtool_sset(dev->phydev, cmd);
 }
 
 static int ixp4xx_nway_reset(struct net_device *dev)
 {
-	struct port *port = netdev_priv(dev);
-	return phy_start_aneg(port->phydev);
+	return phy_start_aneg(dev->phydev);
 }
 
 int ixp46x_phc_index = -1;
@@ -1259,7 +1253,7 @@ static int eth_open(struct net_device *dev)
 	}
 
 	port->speed = 0;	/* force "link up" message */
-	phy_start(port->phydev);
+	phy_start(dev->phydev);
 
 	for (i = 0; i < ETH_ALEN; i++)
 		__raw_writel(dev->dev_addr[i], &port->regs->hw_addr[i]);
@@ -1380,7 +1374,7 @@ static int eth_close(struct net_device *dev)
 		printk(KERN_CRIT "%s: unable to disable loopback\n",
 		       dev->name);
 
-	phy_stop(port->phydev);
+	phy_stop(dev->phydev);
 
 	if (!ports_open)
 		qmgr_disable_irq(TXDONE_QUEUE);
@@ -1405,6 +1399,7 @@ static int eth_init_one(struct platform_device *pdev)
 	struct port *port;
 	struct net_device *dev;
 	struct eth_plat_info *plat = dev_get_platdata(&pdev->dev);
+	struct phy_device *phydev = NULL;
 	u32 regs_phys;
 	char phy_id[MII_BUS_ID_SIZE + 3];
 	int err;
@@ -1466,14 +1461,14 @@ static int eth_init_one(struct platform_device *pdev)
 
 	snprintf(phy_id, MII_BUS_ID_SIZE + 3, PHY_ID_FMT,
 		mdio_bus->id, plat->phy);
-	port->phydev = phy_connect(dev, phy_id, &ixp4xx_adjust_link,
-				   PHY_INTERFACE_MODE_MII);
-	if (IS_ERR(port->phydev)) {
-		err = PTR_ERR(port->phydev);
+	phydev = phy_connect(dev, phy_id, &ixp4xx_adjust_link,
+			     PHY_INTERFACE_MODE_MII);
+	if (IS_ERR(phydev)) {
+		err = PTR_ERR(phydev);
 		goto err_free_mem;
 	}
 
-	port->phydev->irq = PHY_POLL;
+	phydev->irq = PHY_POLL;
 
 	if ((err = register_netdev(dev)))
 		goto err_phy_dis;
@@ -1484,7 +1479,7 @@ static int eth_init_one(struct platform_device *pdev)
 	return 0;
 
 err_phy_dis:
-	phy_disconnect(port->phydev);
+	phy_disconnect(phydev);
 err_free_mem:
 	npe_port_tab[NPE_ID(port->id)] = NULL;
 	release_resource(port->mem_res);
@@ -1498,10 +1493,11 @@ err_free:
 static int eth_remove_one(struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
+	struct phy_device *phydev = dev->phydev;
 	struct port *port = netdev_priv(dev);
 
 	unregister_netdev(dev);
-	phy_disconnect(port->phydev);
+	phy_disconnect(phydev);
 	npe_port_tab[NPE_ID(port->id)] = NULL;
 	npe_release(port->npe);
 	release_resource(port->mem_res);
-- 
1.7.4.4
