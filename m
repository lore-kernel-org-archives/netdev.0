From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (10/12) skge: use lockless transmit
Date: Thu, 3 Mar 2005 11:43:04 -0800
Message-ID: <20050303114304.1d3b05f5@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Support lockless transmit, because there is existing transmit
lock. Also small declaration style fix.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- skge-2.6.11/drivers/net/skge.c.orig	2005-03-03 10:28:11.000000000 -0800
+++ skge-2.6.11/drivers/net/skge.c	2005-03-03 10:29:41.000000000 -0800
@@ -2289,13 +2289,20 @@
 	struct skge_tx_desc *td;
 	int i;
 	u32 control, len;
-	u64 map; unsigned long flags;
+	u64 map;
+	unsigned long flags;
 
 	skb = skb_padto(skb, ETH_ZLEN);
 	if (!skb)
 		return NETDEV_TX_OK;
 
-	spin_lock_irqsave(&skge->tx_lock, flags);
+	local_irq_save(flags);
+	if (!spin_trylock(&skge->tx_lock)) {
+ 		/* Collision - tell upper layer to requeue */ 
+ 		local_irq_restore(flags); 
+ 		return NETDEV_TX_LOCKED; 
+ 	} 
+
 	if (unlikely(skge->tx_avail < skb_shinfo(skb)->nr_frags +1)) {
 		netif_stop_queue(dev);
 		spin_unlock_irqrestore(&skge->tx_lock, flags);
@@ -3089,6 +3096,7 @@
 	dev->poll_controller = skge_netpoll;
 #endif
 	dev->irq = hw->pdev->irq;
+	dev->features = NETIF_F_LLTX;
 
 	skge = netdev_priv(dev);
 	skge->netdev = dev;
