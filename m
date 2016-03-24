From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net v2 1/2] net: bcmgenet: fix dev->stats.tx_bytes accounting
Date: Thu, 24 Mar 2016 11:27:20 -0700
Message-ID: <1458844041-71532-1-git-send-email-pgynther@google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, jaedon.shin@gmail.com,
	edumazet@google.com, Petri Gynther <pgynther@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33288 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042AbcCXS2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 14:28:01 -0400
Received: by mail-pf0-f176.google.com with SMTP id 4so64551925pfd.0
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 11:28:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. Add bytes_compl local variable to __bcmgenet_tx_reclaim() to collect
   transmitted bytes. dev->stats updates can then be moved outside the
   while-loop. bytes_compl is also needed for future BQL support.
2. When bcmgenet device uses Tx checksum offload, each transmitted skb
   gets an extra 64-byte header prepended to it. Before this header is
   prepended to the skb, we need to save the skb "wire" length in
   GENET_CB(skb)->bytes_sent, so that proper Tx bytes accounting can
   be done in __bcmgenet_tx_reclaim().
3. skb->len covers the entire length of skb, whether it is linear or
   fragmented. Thus, when we clean the fragments, do not increase
   transmitted bytes.

Fixes: 1c1008c793fa ("net: bcmgenet: add main driver file")
Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 14 ++++++++++----
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  6 ++++++
 2 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 6746fd0..c1c7c0e 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1171,6 +1171,7 @@ static unsigned int __bcmgenet_tx_reclaim(struct net_device *dev,
 	struct enet_cb *tx_cb_ptr;
 	struct netdev_queue *txq;
 	unsigned int pkts_compl = 0;
+	unsigned int bytes_compl = 0;
 	unsigned int c_index;
 	unsigned int txbds_ready;
 	unsigned int txbds_processed = 0;
@@ -1193,16 +1194,13 @@ static unsigned int __bcmgenet_tx_reclaim(struct net_device *dev,
 		tx_cb_ptr = &priv->tx_cbs[ring->clean_ptr];
 		if (tx_cb_ptr->skb) {
 			pkts_compl++;
-			dev->stats.tx_packets++;
-			dev->stats.tx_bytes += tx_cb_ptr->skb->len;
+			bytes_compl += GENET_CB(tx_cb_ptr->skb)->bytes_sent;
 			dma_unmap_single(&dev->dev,
 					 dma_unmap_addr(tx_cb_ptr, dma_addr),
 					 dma_unmap_len(tx_cb_ptr, dma_len),
 					 DMA_TO_DEVICE);
 			bcmgenet_free_cb(tx_cb_ptr);
 		} else if (dma_unmap_addr(tx_cb_ptr, dma_addr)) {
-			dev->stats.tx_bytes +=
-				dma_unmap_len(tx_cb_ptr, dma_len);
 			dma_unmap_page(&dev->dev,
 				       dma_unmap_addr(tx_cb_ptr, dma_addr),
 				       dma_unmap_len(tx_cb_ptr, dma_len),
@@ -1220,6 +1218,9 @@ static unsigned int __bcmgenet_tx_reclaim(struct net_device *dev,
 	ring->free_bds += txbds_processed;
 	ring->c_index = (ring->c_index + txbds_processed) & DMA_C_INDEX_MASK;
 
+	dev->stats.tx_packets += pkts_compl;
+	dev->stats.tx_bytes += bytes_compl;
+
 	if (ring->free_bds > (MAX_SKB_FRAGS + 1)) {
 		txq = netdev_get_tx_queue(dev, ring->queue);
 		if (netif_tx_queue_stopped(txq))
@@ -1464,6 +1465,11 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto out;
 	}
 
+	/* Retain how many bytes will be sent on the wire, without TSB inserted
+	 * by transmit checksum offload
+	 */
+	GENET_CB(skb)->bytes_sent = skb->len;
+
 	/* set the SKB transmit checksum */
 	if (priv->desc_64b_en) {
 		skb = bcmgenet_put_tx_csum(dev, skb);
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 9673675..1e2dc34 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -531,6 +531,12 @@ struct bcmgenet_hw_params {
 	u32		flags;
 };
 
+struct bcmgenet_skb_cb {
+	unsigned int bytes_sent;	/* bytes on the wire (no TSB) */
+};
+
+#define GENET_CB(skb)	((struct bcmgenet_skb_cb *)((skb)->cb))
+
 struct bcmgenet_tx_ring {
 	spinlock_t	lock;		/* ring lock */
 	struct napi_struct napi;	/* NAPI per tx queue */
-- 
2.8.0.rc3.226.g39d4020
