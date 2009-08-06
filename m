From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/8] Revert "sky2: Avoid transmits during sky2_down()"
Date: Thu, 06 Aug 2009 09:12:14 -0700
Message-ID: <20090806161232.524840939@vyatta.com>
References: <20090806161213.148382653@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:38262 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756200AbZHFQom (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Aug 2009 12:44:42 -0400
Content-Disposition: inline; filename=sky2-revert.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit f6caa14aa0b126d4a2933907d1519611b2a8524a.
Better solution to same problem was done in later patches.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/sky2.c |   14 +-------------
 drivers/net/sky2.h |    1 -
 2 files changed, 1 insertion(+), 14 deletions(-)

--- a/drivers/net/sky2.c	2009-08-06 08:25:15.485025569 -0700
+++ b/drivers/net/sky2.c	2009-08-06 08:25:49.579125976 -0700
@@ -1488,8 +1488,6 @@ static int sky2_up(struct net_device *de
 	sky2_set_vlan_mode(hw, port, sky2->vlgrp != NULL);
 #endif
 
-	sky2->restarting = 0;
-
 	err = sky2_rx_start(sky2);
 	if (err)
 		goto err_out;
@@ -1502,9 +1500,6 @@ static int sky2_up(struct net_device *de
 
 	sky2_set_multicast(dev);
 
-	/* wake queue incase we are restarting */
-	netif_wake_queue(dev);
-
 	if (netif_msg_ifup(sky2))
 		printk(KERN_INFO PFX "%s: enabling interface\n", dev->name);
 	return 0;
@@ -1538,8 +1533,6 @@ static inline int tx_dist(unsigned tail,
 /* Number of list elements available for next tx */
 static inline int tx_avail(const struct sky2_port *sky2)
 {
-	if (unlikely(sky2->restarting))
-		return 0;
 	return sky2->tx_pending - tx_dist(sky2->tx_cons, sky2->tx_prod);
 }
 
@@ -1825,10 +1818,6 @@ static int sky2_down(struct net_device *
 	if (netif_msg_ifdown(sky2))
 		printk(KERN_INFO PFX "%s: disabling interface\n", dev->name);
 
-	/* explicitly shut off tx incase we're restarting */
-	sky2->restarting = 1;
-	netif_tx_disable(dev);
-
 	/* Force flow control off */
 	sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_OFF);
 
@@ -2370,7 +2359,7 @@ static inline void sky2_tx_done(struct n
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
 
-	if (likely(netif_running(dev) && !sky2->restarting)) {
+	if (netif_running(dev)) {
 		netif_tx_lock(dev);
 		sky2_tx_complete(sky2, last);
 		netif_tx_unlock(dev);
@@ -4294,7 +4283,6 @@ static __devinit struct net_device *sky2
 	spin_lock_init(&sky2->phy_lock);
 	sky2->tx_pending = TX_DEF_PENDING;
 	sky2->rx_pending = RX_DEF_PENDING;
-	sky2->restarting = 0;
 
 	hw->dev[port] = dev;
 
--- a/drivers/net/sky2.h	2009-08-06 08:25:15.498381527 -0700
+++ b/drivers/net/sky2.h	2009-08-06 08:25:49.580038902 -0700
@@ -2051,7 +2051,6 @@ struct sky2_port {
 	u8		     duplex;	/* DUPLEX_HALF, DUPLEX_FULL */
 	u8		     rx_csum;
 	u8		     wol;
-	u8		     restarting;
  	enum flow_control    flow_mode;
  	enum flow_control    flow_status;
 

-- 

