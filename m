From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH 2/8] net: mvneta: Limit the TSO segments and adjust stop/wake thresholds
Date: Fri, 30 May 2014 13:40:05 -0300
Message-ID: <1401468011-10609-3-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1401468011-10609-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Tawfik Bayouk <tawfik@marvell.com>, fugang.duan@freescale.com,
	Willy Tarreau <w@1wt.eu>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:58422 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932564AbaE3QlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 12:41:11 -0400
In-Reply-To: <1401468011-10609-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently small MSS values may require too many TSO descriptors for
the default queue size. This commit prevents this situation by fixing
the maximum supported TSO number of segments to 100 and by setting a
minimum Tx queue size. The minimum Tx queue size is set so that at
least 2 worst-case skb can be accommodated.

In addition, the queue stop and wake thresholds values are adjusted
accordingly. The queue is stopped when there's room for only 1 worst-case
skb and waked when the number of descriptors is half that value.

Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 28 ++++++++++++++++++++++++----
 1 file changed, 24 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index af1ac82..57a2e76 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -251,6 +251,11 @@
 /* Max number of Tx descriptors */
 #define MVNETA_MAX_TXD 532
 
+/* Max number of allowed TCP segments for software TSO */
+#define MVNETA_MAX_TSO_SEGS 100
+
+#define MVNETA_MAX_SKB_DESCS (MVNETA_MAX_TSO_SEGS * 2 + MAX_SKB_FRAGS)
+
 /* descriptor aligned size */
 #define MVNETA_DESC_ALIGNED_SIZE	32
 
@@ -388,6 +393,8 @@ struct mvneta_tx_queue {
 	 * descriptor ring
 	 */
 	int count;
+	int tx_stop_threshold;
+	int tx_wake_threshold;
 
 	/* Array of transmitted skb */
 	struct sk_buff **tx_skb;
@@ -1309,7 +1316,7 @@ static void mvneta_txq_done(struct mvneta_port *pp,
 	txq->count -= tx_done;
 
 	if (netif_tx_queue_stopped(nq)) {
-		if (txq->size - txq->count >= MAX_SKB_FRAGS + 1)
+		if (txq->count <= txq->tx_wake_threshold)
 			netif_tx_wake_queue(nq);
 	}
 }
@@ -1769,7 +1776,7 @@ out:
 		txq->count += frags;
 		mvneta_txq_pend_desc_add(pp, txq, frags);
 
-		if (txq->size - txq->count < MAX_SKB_FRAGS + 1)
+		if (txq->count >= txq->tx_stop_threshold)
 			netif_tx_stop_queue(nq);
 
 		u64_stats_update_begin(&stats->syncp);
@@ -2208,6 +2215,14 @@ static int mvneta_txq_init(struct mvneta_port *pp,
 {
 	txq->size = pp->tx_ring_size;
 
+	/* A queue must always have room for at least one skb.
+	 * Therefore, stop the queue when the free entries reaches
+	 * the maximum number of descriptors per skb.
+	 */
+	txq->tx_stop_threshold = txq->size - MVNETA_MAX_SKB_DESCS;
+	txq->tx_wake_threshold = txq->tx_stop_threshold / 2;
+
+
 	/* Allocate memory for TX descriptors */
 	txq->descs = dma_alloc_coherent(pp->dev->dev.parent,
 					txq->size * MVNETA_DESC_ALIGNED_SIZE,
@@ -2742,8 +2757,12 @@ static int mvneta_ethtool_set_ringparam(struct net_device *dev,
 		return -EINVAL;
 	pp->rx_ring_size = ring->rx_pending < MVNETA_MAX_RXD ?
 		ring->rx_pending : MVNETA_MAX_RXD;
-	pp->tx_ring_size = ring->tx_pending < MVNETA_MAX_TXD ?
-		ring->tx_pending : MVNETA_MAX_TXD;
+
+	pp->tx_ring_size = clamp_t(u16, ring->tx_pending,
+				   MVNETA_MAX_SKB_DESCS * 2, MVNETA_MAX_TXD);
+	if (pp->tx_ring_size != ring->tx_pending)
+		netdev_warn(dev, "TX queue size set to %u (requested %u)\n",
+			    pp->tx_ring_size, ring->tx_pending);
 
 	if (netif_running(dev)) {
 		mvneta_stop(dev);
@@ -3028,6 +3047,7 @@ static int mvneta_probe(struct platform_device *pdev)
 	dev->hw_features |= dev->features;
 	dev->vlan_features |= dev->features;
 	dev->priv_flags |= IFF_UNICAST_FLT;
+	dev->gso_max_segs = MVNETA_MAX_TSO_SEGS;
 
 	err = register_netdev(dev);
 	if (err < 0) {
-- 
1.9.1
