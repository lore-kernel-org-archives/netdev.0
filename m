From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: bcmsysport: use phydev from struct net_device
Date: Sun, 19 Jun 2016 20:39:08 +0200
Message-ID: <1466361549-6291-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: f.fainelli@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34006 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750865AbcFSSjT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 14:39:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phydev in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c |   31 ++++++++++++---------------
 drivers/net/ethernet/broadcom/bcmsysport.h |    1 -
 2 files changed, 14 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 543bf38..9775c78 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -99,23 +99,19 @@ static inline void tdma_port_write_desc_addr(struct bcm_sysport_priv *priv,
 static int bcm_sysport_set_settings(struct net_device *dev,
 				    struct ethtool_cmd *cmd)
 {
-	struct bcm_sysport_priv *priv = netdev_priv(dev);
-
 	if (!netif_running(dev))
 		return -EINVAL;
 
-	return phy_ethtool_sset(priv->phydev, cmd);
+	return phy_ethtool_sset(dev->phydev, cmd);
 }
 
 static int bcm_sysport_get_settings(struct net_device *dev,
 				    struct ethtool_cmd *cmd)
 {
-	struct bcm_sysport_priv *priv = netdev_priv(dev);
-
 	if (!netif_running(dev))
 		return -EINVAL;
 
-	return phy_ethtool_gset(priv->phydev, cmd);
+	return phy_ethtool_gset(dev->phydev, cmd);
 }
 
 static int bcm_sysport_set_rx_csum(struct net_device *dev,
@@ -1127,7 +1123,7 @@ static void bcm_sysport_tx_timeout(struct net_device *dev)
 static void bcm_sysport_adj_link(struct net_device *dev)
 {
 	struct bcm_sysport_priv *priv = netdev_priv(dev);
-	struct phy_device *phydev = priv->phydev;
+	struct phy_device *phydev = dev->phydev;
 	unsigned int changed = 0;
 	u32 cmd_bits = 0, reg;
 
@@ -1182,7 +1178,7 @@ static void bcm_sysport_adj_link(struct net_device *dev)
 		umac_writel(priv, reg, UMAC_CMD);
 	}
 
-	phy_print_status(priv->phydev);
+	phy_print_status(phydev);
 }
 
 static int bcm_sysport_init_tx_ring(struct bcm_sysport_priv *priv,
@@ -1525,7 +1521,7 @@ static void bcm_sysport_netif_start(struct net_device *dev)
 	/* Enable RX interrupt and TX ring full interrupt */
 	intrl2_0_mask_clear(priv, INTRL2_0_RDMA_MBDONE | INTRL2_0_TX_RING_FULL);
 
-	phy_start(priv->phydev);
+	phy_start(dev->phydev);
 
 	/* Enable TX interrupts for the 32 TXQs */
 	intrl2_1_mask_clear(priv, 0xffffffff);
@@ -1546,6 +1542,7 @@ static void rbuf_init(struct bcm_sysport_priv *priv)
 static int bcm_sysport_open(struct net_device *dev)
 {
 	struct bcm_sysport_priv *priv = netdev_priv(dev);
+	struct phy_device *phydev;
 	unsigned int i;
 	int ret;
 
@@ -1570,9 +1567,9 @@ static int bcm_sysport_open(struct net_device *dev)
 	/* Read CRC forward */
 	priv->crc_fwd = !!(umac_readl(priv, UMAC_CMD) & CMD_CRC_FWD);
 
-	priv->phydev = of_phy_connect(dev, priv->phy_dn, bcm_sysport_adj_link,
-					0, priv->phy_interface);
-	if (!priv->phydev) {
+	phydev = of_phy_connect(dev, priv->phy_dn, bcm_sysport_adj_link,
+				0, priv->phy_interface);
+	if (!phydev) {
 		netdev_err(dev, "could not attach to PHY\n");
 		return -ENODEV;
 	}
@@ -1650,7 +1647,7 @@ out_free_tx_ring:
 out_free_irq0:
 	free_irq(priv->irq0, dev);
 out_phy_disconnect:
-	phy_disconnect(priv->phydev);
+	phy_disconnect(phydev);
 	return ret;
 }
 
@@ -1661,7 +1658,7 @@ static void bcm_sysport_netif_stop(struct net_device *dev)
 	/* stop all software from updating hardware */
 	netif_tx_stop_all_queues(dev);
 	napi_disable(&priv->napi);
-	phy_stop(priv->phydev);
+	phy_stop(dev->phydev);
 
 	/* mask all interrupts */
 	intrl2_0_mask_set(priv, 0xffffffff);
@@ -1708,7 +1705,7 @@ static int bcm_sysport_stop(struct net_device *dev)
 	free_irq(priv->irq1, dev);
 
 	/* Disconnect from PHY */
-	phy_disconnect(priv->phydev);
+	phy_disconnect(dev->phydev);
 
 	return 0;
 }
@@ -1929,7 +1926,7 @@ static int bcm_sysport_suspend(struct device *d)
 
 	bcm_sysport_netif_stop(dev);
 
-	phy_suspend(priv->phydev);
+	phy_suspend(dev->phydev);
 
 	netif_device_detach(dev);
 
@@ -2055,7 +2052,7 @@ static int bcm_sysport_resume(struct device *d)
 		goto out_free_rx_ring;
 	}
 
-	phy_resume(priv->phydev);
+	phy_resume(dev->phydev);
 
 	bcm_sysport_netif_start(dev);
 
diff --git a/drivers/net/ethernet/broadcom/bcmsysport.h b/drivers/net/ethernet/broadcom/bcmsysport.h
index f28bf54..1c82e3d 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.h
+++ b/drivers/net/ethernet/broadcom/bcmsysport.h
@@ -670,7 +670,6 @@ struct bcm_sysport_priv {
 
 	/* PHY device */
 	struct device_node	*phy_dn;
-	struct phy_device	*phydev;
 	phy_interface_t		phy_interface;
 	int			old_pause;
 	int			old_link;
-- 
1.7.4.4
