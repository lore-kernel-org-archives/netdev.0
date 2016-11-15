From: Tobias Regnery <tobias.regnery@gmail.com>
Subject: [PATCH net-next V2 7/9] alx: prepare tx path for multi queue support
Date: Tue, 15 Nov 2016 12:43:14 +0100
Message-ID: <cadef4abef735592d5c9f0d0adcd8fa6766ce354.1479208629.git.tobias.regnery@gmail.com>
References: <cover.1479208627.git.tobias.regnery@gmail.com>
Cc: davem@davemloft.net, Tobias Regnery <tobias.regnery@gmail.com>
To: netdev@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36435 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751012AbcKOLnk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 06:43:40 -0500
Received: by mail-wm0-f67.google.com with SMTP id m203so24866197wma.3
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 03:43:39 -0800 (PST)
In-Reply-To: <cover.1479208627.git.tobias.regnery@gmail.com>
In-Reply-To: <cover.1479208627.git.tobias.regnery@gmail.com>
References: <cover.1479208627.git.tobias.regnery@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch prepares the tx path to send data on multiple tx queues. It
introduces per queue register adresses and uses them in the alx_tx_queue
structs.

There are new helper functions for the queue mapping in the tx path.

Based on the downstream driver at github.com/qca/alx

Signed-off-by: Tobias Regnery <tobias.regnery@gmail.com>
---
 drivers/net/ethernet/atheros/alx/main.c | 58 +++++++++++++++++++++++++--------
 1 file changed, 45 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index c5f09d2616a4..0e773a2ca6a0 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -143,6 +143,22 @@ static int alx_refill_rx_ring(struct alx_priv *alx, gfp_t gfp)
 	return count;
 }
 
+static struct alx_tx_queue *alx_tx_queue_mapping(struct alx_priv *alx,
+						 struct sk_buff *skb)
+{
+	unsigned int r_idx = skb->queue_mapping;
+
+	if (r_idx >= alx->num_txq)
+		r_idx = r_idx % alx->num_txq;
+
+	return alx->qnapi[r_idx]->txq;
+}
+
+static struct netdev_queue *alx_get_tx_queue(const struct alx_tx_queue *txq)
+{
+	return netdev_get_tx_queue(txq->netdev, txq->queue_idx);
+}
+
 static inline int alx_tpd_avail(struct alx_tx_queue *txq)
 {
 	if (txq->write_idx >= txq->read_idx)
@@ -153,14 +169,16 @@ static inline int alx_tpd_avail(struct alx_tx_queue *txq)
 static bool alx_clean_tx_irq(struct alx_tx_queue *txq)
 {
 	struct alx_priv *alx;
+	struct netdev_queue *tx_queue;
 	u16 hw_read_idx, sw_read_idx;
 	unsigned int total_bytes = 0, total_packets = 0;
 	int budget = ALX_DEFAULT_TX_WORK;
 
 	alx = netdev_priv(txq->netdev);
+	tx_queue = alx_get_tx_queue(txq);
 
 	sw_read_idx = txq->read_idx;
-	hw_read_idx = alx_read_mem16(&alx->hw, ALX_TPD_PRI0_CIDX);
+	hw_read_idx = alx_read_mem16(&alx->hw, txq->c_reg);
 
 	if (sw_read_idx != hw_read_idx) {
 		while (sw_read_idx != hw_read_idx && budget > 0) {
@@ -180,12 +198,12 @@ static bool alx_clean_tx_irq(struct alx_tx_queue *txq)
 		}
 		txq->read_idx = sw_read_idx;
 
-		netdev_completed_queue(txq->netdev, total_packets, total_bytes);
+		netdev_tx_completed_queue(tx_queue, total_packets, total_bytes);
 	}
 
-	if (netif_queue_stopped(txq->netdev) && netif_carrier_ok(txq->netdev) &&
+	if (netif_tx_queue_stopped(tx_queue) && netif_carrier_ok(alx->dev) &&
 	    alx_tpd_avail(txq) > txq->count / 4)
-		netif_wake_queue(txq->netdev);
+		netif_tx_wake_queue(tx_queue);
 
 	return sw_read_idx == hw_read_idx;
 }
@@ -487,7 +505,7 @@ static void alx_free_txring_buf(struct alx_tx_queue *txq)
 	txq->write_idx = 0;
 	txq->read_idx = 0;
 
-	netdev_reset_queue(txq->netdev);
+	netdev_tx_reset_queue(alx_get_tx_queue(txq));
 }
 
 static void alx_free_rxring_buf(struct alx_rx_queue *rxq)
@@ -714,6 +732,10 @@ static void alx_free_napis(struct alx_priv *alx)
 	}
 }
 
+static const u16 tx_pidx_reg[] = {ALX_TPD_PRI0_PIDX, ALX_TPD_PRI1_PIDX,
+				  ALX_TPD_PRI2_PIDX, ALX_TPD_PRI3_PIDX};
+static const u16 tx_cidx_reg[] = {ALX_TPD_PRI0_CIDX, ALX_TPD_PRI1_CIDX,
+				  ALX_TPD_PRI2_CIDX, ALX_TPD_PRI3_CIDX};
 static const u32 tx_vect_mask[] = {ALX_ISR_TX_Q0, ALX_ISR_TX_Q1,
 				   ALX_ISR_TX_Q2, ALX_ISR_TX_Q3};
 static const u32 rx_vect_mask[] = {ALX_ISR_RX_Q0, ALX_ISR_RX_Q1,
@@ -749,6 +771,8 @@ static int alx_alloc_napis(struct alx_priv *alx)
 			goto err_out;
 
 		np->txq = txq;
+		txq->p_reg = tx_pidx_reg[i];
+		txq->c_reg = tx_cidx_reg[i];
 		txq->queue_idx = i;
 		txq->count = alx->tx_ringsz;
 		txq->netdev = alx->dev;
@@ -1501,16 +1525,17 @@ static int alx_map_tx_skb(struct alx_tx_queue *txq, struct sk_buff *skb)
 	return -ENOMEM;
 }
 
-static netdev_tx_t alx_start_xmit(struct sk_buff *skb,
-				  struct net_device *netdev)
+static netdev_tx_t alx_start_xmit_ring(struct sk_buff *skb,
+				       struct alx_tx_queue *txq)
 {
-	struct alx_priv *alx = netdev_priv(netdev);
-	struct alx_tx_queue *txq = alx->qnapi[0]->txq;
+	struct alx_priv *alx;
 	struct alx_txd *first;
 	int tso;
 
+	alx = netdev_priv(txq->netdev);
+
 	if (alx_tpd_avail(txq) < alx_tpd_req(skb)) {
-		netif_stop_queue(txq->netdev);
+		netif_tx_stop_queue(alx_get_tx_queue(txq));
 		goto drop;
 	}
 
@@ -1526,14 +1551,14 @@ static netdev_tx_t alx_start_xmit(struct sk_buff *skb,
 	if (alx_map_tx_skb(txq, skb) < 0)
 		goto drop;
 
-	netdev_sent_queue(txq->netdev, skb->len);
+	netdev_tx_sent_queue(alx_get_tx_queue(txq), skb->len);
 
 	/* flush updates before updating hardware */
 	wmb();
-	alx_write_mem16(&alx->hw, ALX_TPD_PRI0_PIDX, txq->write_idx);
+	alx_write_mem16(&alx->hw, txq->p_reg, txq->write_idx);
 
 	if (alx_tpd_avail(txq) < txq->count / 8)
-		netif_stop_queue(txq->netdev);
+		netif_tx_stop_queue(alx_get_tx_queue(txq));
 
 	return NETDEV_TX_OK;
 
@@ -1542,6 +1567,13 @@ static netdev_tx_t alx_start_xmit(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 }
 
+static netdev_tx_t alx_start_xmit(struct sk_buff *skb,
+				  struct net_device *netdev)
+{
+	struct alx_priv *alx = netdev_priv(netdev);
+	return alx_start_xmit_ring(skb, alx_tx_queue_mapping(alx, skb));
+}
+
 static void alx_tx_timeout(struct net_device *dev)
 {
 	struct alx_priv *alx = netdev_priv(dev);
-- 
2.7.4
