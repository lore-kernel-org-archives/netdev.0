From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 03/17] mv643xx_eth: get rid of modulo operations
Date: Wed,  3 Sep 2008 14:29:30 +0200
Message-ID: <1220444984-20150-4-git-send-email-buytenh@wantstofly.org>
References: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Cc: Dale Farnsworth <dale@farnsworth.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:52892 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751528AbYICM3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 08:29:46 -0400
In-Reply-To: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get rid of the modulo operations that are currently used for
computing successive TX/RX descriptor ring indexes.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   32 ++++++++++++++++++++++++--------
 1 files changed, 24 insertions(+), 8 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 8c812c3..2f6cec4 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -497,8 +497,10 @@ static void rxq_refill(struct rx_queue *rxq)
 			skb_reserve(skb, dma_get_cache_alignment() - unaligned);
 
 		rxq->rx_desc_count++;
-		rx = rxq->rx_used_desc;
-		rxq->rx_used_desc = (rx + 1) % rxq->rx_ring_size;
+
+		rx = rxq->rx_used_desc++;
+		if (rxq->rx_used_desc == rxq->rx_ring_size)
+			rxq->rx_used_desc = 0;
 
 		rxq->rx_desc_area[rx].buf_ptr = dma_map_single(NULL, skb->data,
 						skb_size, DMA_FROM_DEVICE);
@@ -555,7 +557,9 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 		skb = rxq->rx_skb[rxq->rx_curr_desc];
 		rxq->rx_skb[rxq->rx_curr_desc] = NULL;
 
-		rxq->rx_curr_desc = (rxq->rx_curr_desc + 1) % rxq->rx_ring_size;
+		rxq->rx_curr_desc++;
+		if (rxq->rx_curr_desc == rxq->rx_ring_size)
+			rxq->rx_curr_desc = 0;
 
 		spin_unlock_irqrestore(&mp->lock, flags);
 
@@ -684,8 +688,9 @@ static int txq_alloc_desc_index(struct tx_queue *txq)
 
 	BUG_ON(txq->tx_desc_count >= txq->tx_ring_size);
 
-	tx_desc_curr = txq->tx_curr_desc;
-	txq->tx_curr_desc = (tx_desc_curr + 1) % txq->tx_ring_size;
+	tx_desc_curr = txq->tx_curr_desc++;
+	if (txq->tx_curr_desc == txq->tx_ring_size)
+		txq->tx_curr_desc = 0;
 
 	BUG_ON(txq->tx_curr_desc == txq->tx_used_desc);
 
@@ -1515,7 +1520,12 @@ static int rxq_init(struct mv643xx_eth_private *mp, int index)
 
 	rx_desc = (struct rx_desc *)rxq->rx_desc_area;
 	for (i = 0; i < rxq->rx_ring_size; i++) {
-		int nexti = (i + 1) % rxq->rx_ring_size;
+		int nexti;
+
+		nexti = i + 1;
+		if (nexti == rxq->rx_ring_size)
+			nexti = 0;
+
 		rx_desc[i].next_desc_ptr = rxq->rx_desc_dma +
 					nexti * sizeof(struct rx_desc);
 	}
@@ -1617,7 +1627,11 @@ static int txq_init(struct mv643xx_eth_private *mp, int index)
 	tx_desc = (struct tx_desc *)txq->tx_desc_area;
 	for (i = 0; i < txq->tx_ring_size; i++) {
 		struct tx_desc *txd = tx_desc + i;
-		int nexti = (i + 1) % txq->tx_ring_size;
+		int nexti;
+
+		nexti = i + 1;
+		if (nexti == txq->tx_ring_size)
+			nexti = 0;
 
 		txd->cmd_sts = 0;
 		txd->next_desc_ptr = txq->tx_desc_dma +
@@ -1663,7 +1677,9 @@ static void txq_reclaim(struct tx_queue *txq, int force)
 			desc->cmd_sts = cmd_sts & ~BUFFER_OWNED_BY_DMA;
 		}
 
-		txq->tx_used_desc = (tx_index + 1) % txq->tx_ring_size;
+		txq->tx_used_desc = tx_index + 1;
+		if (txq->tx_used_desc == txq->tx_ring_size)
+			txq->tx_used_desc = 0;
 		txq->tx_desc_count--;
 
 		addr = desc->buf_ptr;
-- 
1.5.6.4

