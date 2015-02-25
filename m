From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next] net: bcmgenet: simplify __bcmgenet_tx_reclaim()
Date: Wed, 25 Feb 2015 10:55:00 -0800 (PST)
Message-ID: <20150225185500.C7EBC2211C6@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f74.google.com ([209.85.220.74]:34330 "EHLO
	mail-pa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751866AbbBYSzC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 13:55:02 -0500
Received: by pabkx10 with SMTP id kx10so1829522pab.1
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 10:55:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. Use c_index and ring->c_index to determine how many TxCBs/TxBDs are
   ready for cleanup
   - c_index = the current value of TDMA_CONS_INDEX
   - TDMA_CONS_INDEX is HW-incremented and auto-wraparound (0x0-0xFFFF)
   - ring->c_index = __bcmgenet_tx_reclaim() cleaned up to this point on
     the previous invocation

2. Add bcmgenet_tx_ring->clean_ptr
   - index of the next TxCB to be cleaned
   - incremented as TxCBs/TxBDs are processed
   - value always in range [ring->cb_ptr, ring->end_ptr]

3. Fix incrementing of dev->stats.tx_packets
   - should be incremented only when tx_cb_ptr->skb != NULL

These changes simplify __bcmgenet_tx_reclaim(). Furthermore, Tx ring size
can now be any value.

With the old code, Tx ring size had to be a power-of-2:
   num_tx_bds = ring->size;
   c_index &= (num_tx_bds - 1);
   last_c_index &= (num_tx_bds - 1);

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 45 ++++++++++++--------------
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  1 +
 2 files changed, 22 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 5130053..a64dd9a6 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -975,37 +975,30 @@ static void __bcmgenet_tx_reclaim(struct net_device *dev,
 				  struct bcmgenet_tx_ring *ring)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
-	int last_tx_cn, last_c_index, num_tx_bds;
 	struct enet_cb *tx_cb_ptr;
 	struct netdev_queue *txq;
-	unsigned int bds_compl;
 	unsigned int c_index;
+	unsigned int txbds_ready;
+	unsigned int txbds_processed = 0;
 
 	/* Compute how many buffers are transmitted since last xmit call */
 	c_index = bcmgenet_tdma_ring_readl(priv, ring->index, TDMA_CONS_INDEX);
-	txq = netdev_get_tx_queue(dev, ring->queue);
-
-	last_c_index = ring->c_index;
-	num_tx_bds = ring->size;
+	c_index &= DMA_C_INDEX_MASK;
 
-	c_index &= (num_tx_bds - 1);
-
-	if (c_index >= last_c_index)
-		last_tx_cn = c_index - last_c_index;
+	if (likely(c_index >= ring->c_index))
+		txbds_ready = c_index - ring->c_index;
 	else
-		last_tx_cn = num_tx_bds - last_c_index + c_index;
+		txbds_ready = (DMA_C_INDEX_MASK + 1) - ring->c_index + c_index;
 
 	netif_dbg(priv, tx_done, dev,
-		  "%s ring=%d index=%d last_tx_cn=%d last_index=%d\n",
-		  __func__, ring->index,
-		  c_index, last_tx_cn, last_c_index);
+		  "%s ring=%d old_c_index=%u c_index=%u txbds_ready=%u\n",
+		  __func__, ring->index, ring->c_index, c_index, txbds_ready);
 
 	/* Reclaim transmitted buffers */
-	while (last_tx_cn-- > 0) {
-		tx_cb_ptr = ring->cbs + last_c_index;
-		bds_compl = 0;
+	while (txbds_processed < txbds_ready) {
+		tx_cb_ptr = &priv->tx_cbs[ring->clean_ptr];
 		if (tx_cb_ptr->skb) {
-			bds_compl = skb_shinfo(tx_cb_ptr->skb)->nr_frags + 1;
+			dev->stats.tx_packets++;
 			dev->stats.tx_bytes += tx_cb_ptr->skb->len;
 			dma_unmap_single(&dev->dev,
 					 dma_unmap_addr(tx_cb_ptr, dma_addr),
@@ -1021,20 +1014,23 @@ static void __bcmgenet_tx_reclaim(struct net_device *dev,
 				       DMA_TO_DEVICE);
 			dma_unmap_addr_set(tx_cb_ptr, dma_addr, 0);
 		}
-		dev->stats.tx_packets++;
-		ring->free_bds += bds_compl;
 
-		last_c_index++;
-		last_c_index &= (num_tx_bds - 1);
+		txbds_processed++;
+		if (likely(ring->clean_ptr < ring->end_ptr))
+			ring->clean_ptr++;
+		else
+			ring->clean_ptr = ring->cb_ptr;
 	}
 
+	ring->free_bds += txbds_processed;
+	ring->c_index = (ring->c_index + txbds_processed) & DMA_C_INDEX_MASK;
+
 	if (ring->free_bds > (MAX_SKB_FRAGS + 1))
 		ring->int_disable(priv, ring);
 
+	txq = netdev_get_tx_queue(dev, ring->queue);
 	if (netif_tx_queue_stopped(txq))
 		netif_tx_wake_queue(txq);
-
-	ring->c_index = c_index;
 }
 
 static void bcmgenet_tx_reclaim(struct net_device *dev,
@@ -1702,6 +1698,7 @@ static void bcmgenet_init_tx_ring(struct bcmgenet_priv *priv,
 	}
 	ring->cbs = priv->tx_cbs + start_ptr;
 	ring->size = size;
+	ring->clean_ptr = start_ptr;
 	ring->c_index = 0;
 	ring->free_bds = size;
 	ring->write_ptr = start_ptr;
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 3a8a90f..87b5923 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -524,6 +524,7 @@ struct bcmgenet_tx_ring {
 	unsigned int	queue;		/* queue index */
 	struct enet_cb	*cbs;		/* tx ring buffer control block*/
 	unsigned int	size;		/* size of each tx ring */
+	unsigned int    clean_ptr;      /* Tx ring clean pointer */
 	unsigned int	c_index;	/* last consumer index of each ring*/
 	unsigned int	free_bds;	/* # of free bds for each ring */
 	unsigned int	write_ptr;	/* Tx ring write pointer SW copy */
-- 
2.2.0.rc0.207.ga3a616c
