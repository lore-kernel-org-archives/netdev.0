From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/2] net: bcmgenet: add byte queue limits support
Date: Fri, 13 Mar 2015 15:58:32 -0700
Message-ID: <1426287512-10742-3-git-send-email-f.fainelli@gmail.com>
References: <1426287512-10742-1-git-send-email-f.fainelli@gmail.com>
Cc: edumazet@google.com, Florian Fainelli <f.fainelli@gmail.com>,
	davem@davemloft.net, jaedon.shin@gmail.com, pgynther@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:42710 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757280AbbCMW7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 18:59:44 -0400
Received: by pdbfl12 with SMTP id fl12so32236824pdb.9
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 15:59:43 -0700 (PDT)
In-Reply-To: <1426287512-10742-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for byte queue limits by hooking onto our transmit path and
reclaim routine. In order to account for whether the transmit state
block (64bytes) is enabled or not, make sure that we record the packet
length that will be sent on the wire, not pushed to the TDMA engine.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 18 ++++++++++++++++--
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  6 ++++++
 2 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index cee86c24b35f..2e481669f199 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -982,7 +982,7 @@ static unsigned int __bcmgenet_tx_reclaim(struct net_device *dev,
 	struct bcmgenet_priv *priv = netdev_priv(dev);
 	struct enet_cb *tx_cb_ptr;
 	struct netdev_queue *txq;
-	unsigned int pkts_compl = 0;
+	unsigned int pkts_compl = 0, bytes_compl = 0;
 	unsigned int c_index;
 	unsigned int txbds_ready;
 	unsigned int txbds_processed = 0;
@@ -1005,6 +1005,7 @@ static unsigned int __bcmgenet_tx_reclaim(struct net_device *dev,
 		tx_cb_ptr = &priv->tx_cbs[ring->clean_ptr];
 		if (tx_cb_ptr->skb) {
 			pkts_compl++;
+			bytes_compl += GENET_CB(tx_cb_ptr->skb)->bytes_sent;
 			dev->stats.tx_packets++;
 			dev->stats.tx_bytes += tx_cb_ptr->skb->len;
 			dma_unmap_single(&dev->dev,
@@ -1032,8 +1033,10 @@ static unsigned int __bcmgenet_tx_reclaim(struct net_device *dev,
 	ring->free_bds += txbds_processed;
 	ring->c_index = (ring->c_index + txbds_processed) & DMA_C_INDEX_MASK;
 
+	txq = netdev_get_tx_queue(dev, ring->queue);
+	netdev_tx_completed_queue(txq, pkts_compl, bytes_compl);
+
 	if (ring->free_bds > (MAX_SKB_FRAGS + 1)) {
-		txq = netdev_get_tx_queue(dev, ring->queue);
 		if (netif_tx_queue_stopped(txq))
 			netif_tx_wake_queue(txq);
 	}
@@ -1240,6 +1243,7 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct bcmgenet_tx_ring *ring = NULL;
 	struct netdev_queue *txq;
 	unsigned long flags = 0;
+	unsigned int skb_len;
 	int nr_frags, index;
 	u16 dma_desc_flags;
 	int ret;
@@ -1276,6 +1280,12 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto out;
 	}
 
+	/* Retain how many bytes will be sent on the wire, without FCB inserted
+	 * by transmit checksum offload
+	 */
+	skb_len = skb->len;
+	GENET_CB(skb)->bytes_sent = skb_len;
+
 	/* set the SKB transmit checksum */
 	if (priv->desc_64b_en) {
 		skb = bcmgenet_put_tx_csum(dev, skb);
@@ -1315,6 +1325,8 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
 	ring->prod_index += nr_frags + 1;
 	ring->prod_index &= DMA_P_INDEX_MASK;
 
+	netdev_tx_sent_queue(txq, skb_len);
+
 	if (ring->free_bds <= (MAX_SKB_FRAGS + 1))
 		netif_tx_stop_queue(txq);
 
@@ -1764,9 +1776,11 @@ static void bcmgenet_fini_tx_ring(struct bcmgenet_priv *priv,
 				  unsigned int index)
 {
 	struct bcmgenet_tx_ring *ring = &priv->tx_rings[index];
+	struct netdev_queue *txq = netdev_get_tx_queue(priv->dev, ring->queue);
 
 	napi_disable(&ring->napi);
 	netif_napi_del(&ring->napi);
+	netdev_tx_reset_queue(txq);
 }
 
 /* Initialize a RDMA ring */
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 2a8113898aed..23008c5ed235 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -519,6 +519,12 @@ struct bcmgenet_hw_params {
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
2.1.0
