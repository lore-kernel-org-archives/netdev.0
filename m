From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 14/17] mv643xx_eth: transmit multiqueue support
Date: Wed,  3 Sep 2008 14:29:41 +0200
Message-ID: <1220444984-20150-15-git-send-email-buytenh@wantstofly.org>
References: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Cc: Dale Farnsworth <dale@farnsworth.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:52904 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752705AbYICM3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 08:29:48 -0400
In-Reply-To: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As all the infrastructure for multiple transmit queues already exists
in the driver, this patch is entirely trivial.

The individual transmit queues are still serialised by the driver's
per-port private spinlock, but that will disappear (i.e. be replaced
by the per-subqueue ->_xmit_lock) in a subsequent patch.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   40 ++++++++++++++++++----------------------
 1 files changed, 18 insertions(+), 22 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index e592fac..1ceed87 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -449,15 +449,10 @@ static void txq_disable(struct tx_queue *txq)
 static void __txq_maybe_wake(struct tx_queue *txq)
 {
 	struct mv643xx_eth_private *mp = txq_to_mp(txq);
-
-	/*
-	 * netif_{stop,wake}_queue() flow control only applies to
-	 * the primary queue.
-	 */
-	BUG_ON(txq->index != 0);
+	struct netdev_queue *nq = netdev_get_tx_queue(mp->dev, txq->index);
 
 	if (txq->tx_ring_size - txq->tx_desc_count >= MAX_SKB_FRAGS + 1)
-		netif_wake_queue(mp->dev);
+		netif_tx_wake_queue(nq);
 }
 
 
@@ -827,8 +822,11 @@ static int mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	struct net_device_stats *stats = &dev->stats;
+	int queue;
 	struct tx_queue *txq;
+	struct netdev_queue *nq;
 	unsigned long flags;
+	int entries_left;
 
 	if (has_tiny_unaligned_frags(skb) && __skb_linearize(skb)) {
 		stats->tx_dropped++;
@@ -838,15 +836,16 @@ static int mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_BUSY;
 	}
 
-	spin_lock_irqsave(&mp->lock, flags);
+	queue = skb_get_queue_mapping(skb);
+	txq = mp->txq + queue;
+	nq = netdev_get_tx_queue(dev, queue);
 
-	txq = mp->txq;
+	spin_lock_irqsave(&mp->lock, flags);
 
 	if (txq->tx_ring_size - txq->tx_desc_count < MAX_SKB_FRAGS + 1) {
 		spin_unlock_irqrestore(&mp->lock, flags);
-		if (txq->index == 0 && net_ratelimit())
-			dev_printk(KERN_ERR, &dev->dev,
-				   "primary tx queue full?!\n");
+		if (net_ratelimit())
+			dev_printk(KERN_ERR, &dev->dev, "tx queue full?!\n");
 		kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
@@ -856,13 +855,9 @@ static int mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	stats->tx_packets++;
 	dev->trans_start = jiffies;
 
-	if (txq->index == 0) {
-		int entries_left;
-
-		entries_left = txq->tx_ring_size - txq->tx_desc_count;
-		if (entries_left < MAX_SKB_FRAGS + 1)
-			netif_stop_queue(dev);
-	}
+	entries_left = txq->tx_ring_size - txq->tx_desc_count;
+	if (entries_left < MAX_SKB_FRAGS + 1)
+		netif_tx_stop_queue(nq);
 
 	spin_unlock_irqrestore(&mp->lock, flags);
 
@@ -2169,10 +2164,10 @@ static void tx_timeout_task(struct work_struct *ugly)
 
 	mp = container_of(ugly, struct mv643xx_eth_private, tx_timeout_task);
 	if (netif_running(mp->dev)) {
-		netif_stop_queue(mp->dev);
+		netif_tx_stop_all_queues(mp->dev);
 		port_reset(mp);
 		port_start(mp);
-		netif_wake_queue(mp->dev);
+		netif_tx_wake_all_queues(mp->dev);
 	}
 }
 
@@ -2546,7 +2541,7 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 		return -ENODEV;
 	}
 
-	dev = alloc_etherdev(sizeof(struct mv643xx_eth_private));
+	dev = alloc_etherdev_mq(sizeof(struct mv643xx_eth_private), 8);
 	if (!dev)
 		return -ENOMEM;
 
@@ -2559,6 +2554,7 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	mp->dev = dev;
 
 	set_params(mp, pd);
+	dev->real_num_tx_queues = mp->txq_count;
 
 	spin_lock_init(&mp->lock);
 
-- 
1.5.6.4

