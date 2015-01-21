From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH 2/2] net: mv643xx_eth: Fix highmem support in non-TSO egress path
Date: Wed, 21 Jan 2015 09:54:10 -0300
Message-ID: <1421844850-30886-3-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1421844850-30886-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: B38611@freescale.com, fabio.estevam@freescale.com,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>, Russell King <linux@arm.linux.org.uk>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:36480 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753855AbbAUM4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 07:56:23 -0500
In-Reply-To: <1421844850-30886-1-git-send-email-ezequiel.garcia@free-electrons.com>
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
which takes care of mapping the skb fragment properly.

Fixes: 69ad0dd7af22 ("net: mv643xx_eth: Use dma_map_single() to map the skb fragments")
Reported-by: Russell King <linux@arm.linux.org.uk>
Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c | 26 +++++++++++++++++++-------
 1 file changed, 19 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index a62fc38..0c77f0e 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -879,10 +879,8 @@ static void txq_submit_frag_skb(struct tx_queue *txq, struct sk_buff *skb)
 		skb_frag_t *this_frag;
 		int tx_index;
 		struct tx_desc *desc;
-		void *addr;
 
 		this_frag = &skb_shinfo(skb)->frags[frag];
-		addr = page_address(this_frag->page.p) + this_frag->page_offset;
 		tx_index = txq->tx_curr_desc++;
 		if (txq->tx_curr_desc == txq->tx_ring_size)
 			txq->tx_curr_desc = 0;
@@ -902,8 +900,9 @@ static void txq_submit_frag_skb(struct tx_queue *txq, struct sk_buff *skb)
 
 		desc->l4i_chk = 0;
 		desc->byte_cnt = skb_frag_size(this_frag);
-		desc->buf_ptr = dma_map_single(mp->dev->dev.parent, addr,
-					       desc->byte_cnt, DMA_TO_DEVICE);
+		desc->buf_ptr = skb_frag_dma_map(mp->dev->dev.parent,
+						 this_frag, 0, desc->byte_cnt,
+						 DMA_TO_DEVICE);
 	}
 }
 
@@ -1065,9 +1064,22 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 		reclaimed++;
 		txq->tx_desc_count--;
 
-		if (!IS_TSO_HEADER(txq, desc->buf_ptr))
-			dma_unmap_single(mp->dev->dev.parent, desc->buf_ptr,
-					 desc->byte_cnt, DMA_TO_DEVICE);
+		if (!IS_TSO_HEADER(txq, desc->buf_ptr)) {
+
+			/* The first descriptor is either a TSO header or
+			 * the linear part of the skb.
+			 */
+			if (desc->cmd_sts & TX_FIRST_DESC)
+				dma_unmap_single(mp->dev->dev.parent,
+						 desc->buf_ptr,
+						 desc->byte_cnt,
+						 DMA_TO_DEVICE);
+			else
+				dma_unmap_page(mp->dev->dev.parent,
+					       desc->buf_ptr,
+					       desc->byte_cnt,
+					       DMA_TO_DEVICE);
+		}
 
 		if (cmd_sts & TX_ENABLE_INTERRUPT) {
 			struct sk_buff *skb = __skb_dequeue(&txq->tx_skb);
-- 
2.2.1
