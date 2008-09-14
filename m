From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 2/5] mv643xx_eth: replace array of skbs awaiting transmit completion with a queue
Date: Sun, 14 Sep 2008 19:14:02 +0200
Message-ID: <20080914171402.GD28798@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>,
	Ashish Karkare <akarkare@marvell.com>,
	Nicolas Pitre <nico@cam.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:39740 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753967AbYINROD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2008 13:14:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get rid of the skb pointer array that we currently use for transmit
reclaim, and replace it with an skb queue, to which skbuffs are appended
when they are passed to the xmit function, and removed from the front
and freed when we do transmit queue reclaim and hit a descriptor with
the 'owned by device' bit clear and 'last descriptor' bit set.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   39 ++++++++++-----------------------------
 1 files changed, 10 insertions(+), 29 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 7410eca..099e0be 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -336,7 +336,8 @@ struct tx_queue {
 	struct tx_desc *tx_desc_area;
 	dma_addr_t tx_desc_dma;
 	int tx_desc_area_size;
-	struct sk_buff **tx_skb;
+
+	struct sk_buff_head tx_skb;
 
 	unsigned long tx_packets;
 	unsigned long tx_bytes;
@@ -676,10 +677,8 @@ static void txq_submit_frag_skb(struct tx_queue *txq, struct sk_buff *skb)
 			desc->cmd_sts = BUFFER_OWNED_BY_DMA |
 					ZERO_PADDING | TX_LAST_DESC |
 					TX_ENABLE_INTERRUPT;
-			txq->tx_skb[tx_index] = skb;
 		} else {
 			desc->cmd_sts = BUFFER_OWNED_BY_DMA;
-			txq->tx_skb[tx_index] = NULL;
 		}
 
 		desc->l4i_chk = 0;
@@ -712,13 +711,10 @@ static void txq_submit_skb(struct tx_queue *txq, struct sk_buff *skb)
 
 	if (nr_frags) {
 		txq_submit_frag_skb(txq, skb);
-
 		length = skb_headlen(skb);
-		txq->tx_skb[tx_index] = NULL;
 	} else {
 		cmd_sts |= ZERO_PADDING | TX_LAST_DESC | TX_ENABLE_INTERRUPT;
 		length = skb->len;
-		txq->tx_skb[tx_index] = skb;
 	}
 
 	desc->byte_cnt = length;
@@ -772,6 +768,8 @@ static void txq_submit_skb(struct tx_queue *txq, struct sk_buff *skb)
 		desc->l4i_chk = 0;
 	}
 
+	__skb_queue_tail(&txq->tx_skb, skb);
+
 	/* ensure all other descriptors are written before first cmd_sts */
 	wmb();
 	desc->cmd_sts = cmd_sts;
@@ -884,8 +882,9 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 		reclaimed++;
 		txq->tx_desc_count--;
 
-		skb = txq->tx_skb[tx_index];
-		txq->tx_skb[tx_index] = NULL;
+		skb = NULL;
+		if (cmd_sts & TX_LAST_DESC)
+			skb = __skb_dequeue(&txq->tx_skb);
 
 		if (cmd_sts & ERROR_SUMMARY) {
 			dev_printk(KERN_INFO, &mp->dev->dev, "tx error\n");
@@ -1692,18 +1691,11 @@ static int txq_init(struct mv643xx_eth_private *mp, int index)
 	if (txq->tx_desc_area == NULL) {
 		dev_printk(KERN_ERR, &mp->dev->dev,
 			   "can't allocate tx ring (%d bytes)\n", size);
-		goto out;
+		return -ENOMEM;
 	}
 	memset(txq->tx_desc_area, 0, size);
 
 	txq->tx_desc_area_size = size;
-	txq->tx_skb = kmalloc(txq->tx_ring_size * sizeof(*txq->tx_skb),
-								GFP_KERNEL);
-	if (txq->tx_skb == NULL) {
-		dev_printk(KERN_ERR, &mp->dev->dev,
-			   "can't allocate tx skb ring\n");
-		goto out_free;
-	}
 
 	tx_desc = (struct tx_desc *)txq->tx_desc_area;
 	for (i = 0; i < txq->tx_ring_size; i++) {
@@ -1719,18 +1711,9 @@ static int txq_init(struct mv643xx_eth_private *mp, int index)
 					nexti * sizeof(struct tx_desc);
 	}
 
-	return 0;
+	skb_queue_head_init(&txq->tx_skb);
 
-out_free:
-	if (index == 0 && size <= mp->tx_desc_sram_size)
-		iounmap(txq->tx_desc_area);
-	else
-		dma_free_coherent(NULL, size,
-				  txq->tx_desc_area,
-				  txq->tx_desc_dma);
-
-out:
-	return -ENOMEM;
+	return 0;
 }
 
 static void txq_deinit(struct tx_queue *txq)
@@ -1748,8 +1731,6 @@ static void txq_deinit(struct tx_queue *txq)
 	else
 		dma_free_coherent(NULL, txq->tx_desc_area_size,
 				  txq->tx_desc_area, txq->tx_desc_dma);
-
-	kfree(txq->tx_skb);
 }
 
 
-- 
1.5.6.4
