From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: [RFC 3/5] net/mv643xx: use generic recycling infrastructure
Date: Wed,  5 May 2010 16:47:48 +0200
Message-ID: <1273070870-7821-4-git-send-email-sebastian@breakpoint.cc>
References: <1273070870-7821-1-git-send-email-sebastian@breakpoint.cc>
Cc: tglx@linutronix.de,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:51296 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933686Ab0EEOr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 10:47:59 -0400
In-Reply-To: <1273070870-7821-1-git-send-email-sebastian@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 drivers/net/mv643xx_eth.c |   27 +++++++++------------------
 1 files changed, 9 insertions(+), 18 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 4ee9d04..f56aaac 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -404,8 +404,6 @@ struct mv643xx_eth_private {
 	u8 work_rx_refill;
 
 	int skb_size;
-	struct sk_buff_head rx_recycle;
-
 	/*
 	 * RX state.
 	 */
@@ -649,6 +647,7 @@ err:
 static int rxq_refill(struct rx_queue *rxq, int budget)
 {
 	struct mv643xx_eth_private *mp = rxq_to_mp(rxq);
+	struct net_device *dev = mp->dev;
 	int refilled;
 
 	refilled = 0;
@@ -658,10 +657,7 @@ static int rxq_refill(struct rx_queue *rxq, int budget)
 		struct rx_desc *rx_desc;
 		int size;
 
-		skb = __skb_dequeue(&mp->rx_recycle);
-		if (skb == NULL)
-			skb = dev_alloc_skb(mp->skb_size);
-
+		skb = net_recycle_get(dev);
 		if (skb == NULL) {
 			mp->oom = 1;
 			goto oom;
@@ -922,6 +918,7 @@ out:
 static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 {
 	struct mv643xx_eth_private *mp = txq_to_mp(txq);
+	struct net_device *dev = mp->dev;
 	struct netdev_queue *nq = netdev_get_tx_queue(mp->dev, txq->index);
 	int reclaimed;
 
@@ -968,14 +965,8 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 				       desc->byte_cnt, DMA_TO_DEVICE);
 		}
 
-		if (skb != NULL) {
-			if (skb_queue_len(&mp->rx_recycle) <
-					mp->rx_ring_size &&
-			    skb_recycle_check(skb, mp->skb_size))
-				__skb_queue_head(&mp->rx_recycle, skb);
-			else
-				dev_kfree_skb(skb);
-		}
+		if (skb)
+			net_recycle_add(dev, skb);
 	}
 
 	__netif_tx_unlock(nq);
@@ -1564,7 +1555,7 @@ mv643xx_eth_set_ringparam(struct net_device *dev, struct ethtool_ringparam *er)
 
 	mp->rx_ring_size = er->rx_pending < 4096 ? er->rx_pending : 4096;
 	mp->tx_ring_size = er->tx_pending < 4096 ? er->tx_pending : 4096;
-
+	net_recycle_qlen(dev, mp->rx_ring_size);
 	if (netif_running(dev)) {
 		mv643xx_eth_stop(dev);
 		if (mv643xx_eth_open(dev)) {
@@ -2340,9 +2331,9 @@ static int mv643xx_eth_open(struct net_device *dev)
 
 	mv643xx_eth_recalc_skb_size(mp);
 
-	napi_enable(&mp->napi);
+	net_recycle_init(mp->dev, mp->rx_ring_size, mp->skb_size);
 
-	skb_queue_head_init(&mp->rx_recycle);
+	napi_enable(&mp->napi);
 
 	mp->int_mask = INT_EXT;
 
@@ -2438,7 +2429,7 @@ static int mv643xx_eth_stop(struct net_device *dev)
 	mib_counters_update(mp);
 	del_timer_sync(&mp->mib_counters_timer);
 
-	skb_queue_purge(&mp->rx_recycle);
+	net_recycle_cleanup(dev);
 
 	for (i = 0; i < mp->rxq_count; i++)
 		rxq_deinit(mp->rxq + i);
-- 
1.6.6.1

