From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH v2] net: mv643xx_eth: Fix highmem support in non-TSO egress path
Date: Thu, 22 Jan 2015 09:14:19 -0300
Message-ID: <1421928859-17923-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: <netdev@vger.kernel.org>, B38611@freescale.com,
	fabio.estevam@freescale.com,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: David Miller <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:43409 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751584AbbAVMQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 07:16:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 69ad0dd7af22b61d9e0e68e56b6290121618b0fb
Author: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Date:   Mon May 19 13:59:59 2014 -0300

    net: mv643xx_eth: Use dma_map_single() to map the skb fragments

caused a nasty regression by removing the support for highmem skb
fragments. By using page_address() to get the address of a fragment's
page, we are assuming a lowmem page. However, such assumption is incorrect,
as fragments can be in highmem pages, resulting in very nasty issues.

This commit fixes this by using the skb_frag_dma_map() helper,
which takes care of mapping the skb fragment properly. Additionally,
the type of mapping is now tracked, so it can be unmapped using
dma_unmap_page or dma_unmap_single when appropriate.

Fixes: 69ad0dd7af22 ("net: mv643xx_eth: Use dma_map_single() to map the skb fragments")
Reported-by: Russell King <rmk+kernel@arm.linux.org.uk>
Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
Changes from v1: 
  * Sending the mv643xx_eth fix for now.
  * Fix DMA mapping type track, to use the correct unmap call.

 drivers/net/ethernet/marvell/mv643xx_eth.c | 41 +++++++++++++++++++++++++-----
 1 file changed, 34 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index a62fc38..e4c8461 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -192,6 +192,10 @@ static char mv643xx_eth_driver_version[] = "1.4";
 #define IS_TSO_HEADER(txq, addr) \
 	((addr >= txq->tso_hdrs_dma) && \
 	 (addr < txq->tso_hdrs_dma + txq->tx_ring_size * TSO_HEADER_SIZE))
+
+#define DESC_DMA_MAP_SINGLE 0
+#define DESC_DMA_MAP_PAGE 1
+
 /*
  * RX/TX descriptors.
  */
@@ -362,6 +366,7 @@ struct tx_queue {
 	dma_addr_t tso_hdrs_dma;
 
 	struct tx_desc *tx_desc_area;
+	char *tx_desc_mapping; /* array to track the type of the dma mapping */
 	dma_addr_t tx_desc_dma;
 	int tx_desc_area_size;
 
@@ -750,6 +755,7 @@ txq_put_data_tso(struct net_device *dev, struct tx_queue *txq,
 	if (txq->tx_curr_desc == txq->tx_ring_size)
 		txq->tx_curr_desc = 0;
 	desc = &txq->tx_desc_area[tx_index];
+	txq->tx_desc_mapping[tx_index] = DESC_DMA_MAP_SINGLE;
 
 	desc->l4i_chk = 0;
 	desc->byte_cnt = length;
@@ -879,14 +885,13 @@ static void txq_submit_frag_skb(struct tx_queue *txq, struct sk_buff *skb)
 		skb_frag_t *this_frag;
 		int tx_index;
 		struct tx_desc *desc;
-		void *addr;
 
 		this_frag = &skb_shinfo(skb)->frags[frag];
-		addr = page_address(this_frag->page.p) + this_frag->page_offset;
 		tx_index = txq->tx_curr_desc++;
 		if (txq->tx_curr_desc == txq->tx_ring_size)
 			txq->tx_curr_desc = 0;
 		desc = &txq->tx_desc_area[tx_index];
+		txq->tx_desc_mapping[tx_index] = DESC_DMA_MAP_PAGE;
 
 		/*
 		 * The last fragment will generate an interrupt
@@ -902,8 +907,9 @@ static void txq_submit_frag_skb(struct tx_queue *txq, struct sk_buff *skb)
 
 		desc->l4i_chk = 0;
 		desc->byte_cnt = skb_frag_size(this_frag);
-		desc->buf_ptr = dma_map_single(mp->dev->dev.parent, addr,
-					       desc->byte_cnt, DMA_TO_DEVICE);
+		desc->buf_ptr = skb_frag_dma_map(mp->dev->dev.parent,
+						 this_frag, 0, desc->byte_cnt,
+						 DMA_TO_DEVICE);
 	}
 }
 
@@ -936,6 +942,7 @@ static int txq_submit_skb(struct tx_queue *txq, struct sk_buff *skb,
 	if (txq->tx_curr_desc == txq->tx_ring_size)
 		txq->tx_curr_desc = 0;
 	desc = &txq->tx_desc_area[tx_index];
+	txq->tx_desc_mapping[tx_index] = DESC_DMA_MAP_SINGLE;
 
 	if (nr_frags) {
 		txq_submit_frag_skb(txq, skb);
@@ -1047,9 +1054,12 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 		int tx_index;
 		struct tx_desc *desc;
 		u32 cmd_sts;
+		char desc_dma_map;
 
 		tx_index = txq->tx_used_desc;
 		desc = &txq->tx_desc_area[tx_index];
+		desc_dma_map = txq->tx_desc_mapping[tx_index];
+
 		cmd_sts = desc->cmd_sts;
 
 		if (cmd_sts & BUFFER_OWNED_BY_DMA) {
@@ -1065,9 +1075,19 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 		reclaimed++;
 		txq->tx_desc_count--;
 
-		if (!IS_TSO_HEADER(txq, desc->buf_ptr))
-			dma_unmap_single(mp->dev->dev.parent, desc->buf_ptr,
-					 desc->byte_cnt, DMA_TO_DEVICE);
+		if (!IS_TSO_HEADER(txq, desc->buf_ptr)) {
+
+			if (desc_dma_map == DESC_DMA_MAP_PAGE)
+				dma_unmap_page(mp->dev->dev.parent,
+					       desc->buf_ptr,
+					       desc->byte_cnt,
+					       DMA_TO_DEVICE);
+			else
+				dma_unmap_single(mp->dev->dev.parent,
+						 desc->buf_ptr,
+						 desc->byte_cnt,
+						 DMA_TO_DEVICE);
+		}
 
 		if (cmd_sts & TX_ENABLE_INTERRUPT) {
 			struct sk_buff *skb = __skb_dequeue(&txq->tx_skb);
@@ -2048,6 +2068,11 @@ static int txq_init(struct mv643xx_eth_private *mp, int index)
 					nexti * sizeof(struct tx_desc);
 	}
 
+	txq->tx_desc_mapping = kcalloc(txq->tx_ring_size, sizeof(char),
+				       GFP_KERNEL);
+	if (!txq->tx_desc_mapping)
+		return -ENOMEM;
+
 	/* Allocate DMA buffers for TSO MAC/IP/TCP headers */
 	txq->tso_hdrs = dma_alloc_coherent(mp->dev->dev.parent,
 					   txq->tx_ring_size * TSO_HEADER_SIZE,
@@ -2077,6 +2102,8 @@ static void txq_deinit(struct tx_queue *txq)
 	else
 		dma_free_coherent(mp->dev->dev.parent, txq->tx_desc_area_size,
 				  txq->tx_desc_area, txq->tx_desc_dma);
+	kfree(txq->tx_desc_mapping);
+
 	if (txq->tso_hdrs)
 		dma_free_coherent(mp->dev->dev.parent,
 				  txq->tx_ring_size * TSO_HEADER_SIZE,
-- 
2.2.1
