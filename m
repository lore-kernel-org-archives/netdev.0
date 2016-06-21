From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: macb: use phydev from struct net_device
Date: Wed, 22 Jun 2016 00:32:35 +0200
Message-ID: <1466548356-19166-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:35430 "EHLO
	mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751537AbcFUWdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 18:33:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phydev in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/cadence/macb.c |   28 +++++++++++++---------------
 drivers/net/ethernet/cadence/macb.h |    1 -
 2 files changed, 13 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index cb07d95..090463f 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -304,7 +304,7 @@ static void macb_set_tx_clk(struct clk *clk, int speed, struct net_device *dev)
 static void macb_handle_link_change(struct net_device *dev)
 {
 	struct macb *bp = netdev_priv(dev);
-	struct phy_device *phydev = bp->phy_dev;
+	struct phy_device *phydev = dev->phydev;
 	unsigned long flags;
 	int status_change = 0;
 
@@ -414,7 +414,6 @@ static int macb_mii_probe(struct net_device *dev)
 	bp->link = 0;
 	bp->speed = 0;
 	bp->duplex = -1;
-	bp->phy_dev = phydev;
 
 	return 0;
 }
@@ -1886,7 +1885,7 @@ static int macb_open(struct net_device *dev)
 	netif_carrier_off(dev);
 
 	/* if the phy is not yet register, retry later*/
-	if (!bp->phy_dev)
+	if (!dev->phydev)
 		return -EAGAIN;
 
 	/* RX buffers initialization */
@@ -1905,7 +1904,7 @@ static int macb_open(struct net_device *dev)
 	macb_init_hw(bp);
 
 	/* schedule a link state check */
-	phy_start(bp->phy_dev);
+	phy_start(dev->phydev);
 
 	netif_tx_start_all_queues(dev);
 
@@ -1920,8 +1919,8 @@ static int macb_close(struct net_device *dev)
 	netif_tx_stop_all_queues(dev);
 	napi_disable(&bp->napi);
 
-	if (bp->phy_dev)
-		phy_stop(bp->phy_dev);
+	if (dev->phydev)
+		phy_stop(dev->phydev);
 
 	spin_lock_irqsave(&bp->lock, flags);
 	macb_reset_hw(bp);
@@ -2095,7 +2094,7 @@ static struct net_device_stats *macb_get_stats(struct net_device *dev)
 static int macb_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct macb *bp = netdev_priv(dev);
-	struct phy_device *phydev = bp->phy_dev;
+	struct phy_device *phydev = dev->phydev;
 
 	if (!phydev)
 		return -ENODEV;
@@ -2106,7 +2105,7 @@ static int macb_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 static int macb_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct macb *bp = netdev_priv(dev);
-	struct phy_device *phydev = bp->phy_dev;
+	struct phy_device *phydev = dev->phydev;
 
 	if (!phydev)
 		return -ENODEV;
@@ -2210,8 +2209,7 @@ static const struct ethtool_ops gem_ethtool_ops = {
 
 static int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct macb *bp = netdev_priv(dev);
-	struct phy_device *phydev = bp->phy_dev;
+	struct phy_device *phydev = dev->phydev;
 
 	if (!netif_running(dev))
 		return -EINVAL;
@@ -2570,7 +2568,7 @@ static int at91ether_open(struct net_device *dev)
 			     MACB_BIT(HRESP));
 
 	/* schedule a link state check */
-	phy_start(lp->phy_dev);
+	phy_start(dev->phydev);
 
 	netif_start_queue(dev);
 
@@ -3010,7 +3008,7 @@ static int macb_probe(struct platform_device *pdev)
 	if (err)
 		goto err_out_free_netdev;
 
-	phydev = bp->phy_dev;
+	phydev = dev->phydev;
 
 	netif_carrier_off(dev);
 
@@ -3029,7 +3027,7 @@ static int macb_probe(struct platform_device *pdev)
 	return 0;
 
 err_out_unregister_mdio:
-	phy_disconnect(bp->phy_dev);
+	phy_disconnect(dev->phydev);
 	mdiobus_unregister(bp->mii_bus);
 	mdiobus_free(bp->mii_bus);
 
@@ -3057,8 +3055,8 @@ static int macb_remove(struct platform_device *pdev)
 
 	if (dev) {
 		bp = netdev_priv(dev);
-		if (bp->phy_dev)
-			phy_disconnect(bp->phy_dev);
+		if (dev->phydev)
+			phy_disconnect(dev->phydev);
 		mdiobus_unregister(bp->mii_bus);
 		mdiobus_free(bp->mii_bus);
 
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 8a13824..36893d8 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -823,7 +823,6 @@ struct macb {
 	struct macb_or_gem_ops	macbgem_ops;
 
 	struct mii_bus		*mii_bus;
-	struct phy_device	*phy_dev;
 	int 			link;
 	int 			speed;
 	int 			duplex;
-- 
1.7.4.4
