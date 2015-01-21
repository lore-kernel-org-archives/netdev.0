From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH 1/2] net: mvneta: Fix highmem support in the non-TSO egress path
Date: Wed, 21 Jan 2015 09:54:09 -0300
Message-ID: <1421844850-30886-2-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1421844850-30886-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: B38611@freescale.com, fabio.estevam@freescale.com,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>, Russell King <linux@arm.linux.org.uk>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:36476 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753816AbbAUM4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 07:56:21 -0500
In-Reply-To: <1421844850-30886-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current implementation is broken and does not support
a skb fragment being in a highmem page. By using page_address()
to get the address of a fragment's page, we are assuming a
lowmem page. However, such assumption is incorrect and proper
highmem support is required instead.

This commit fixes this by using the skb_frag_dma_map() helper,
which takes care of mapping the skb fragment properly.

Fixes: c5aff18204da ("net: mvneta: driver for Marvell Armada 370/XP network unit")
Reported-by: Russell King <linux@arm.linux.org.uk>
Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 39 +++++++++++++++++++++--------------
 1 file changed, 24 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 96208f1..adec923 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1296,10 +1296,22 @@ static void mvneta_txq_bufs_free(struct mvneta_port *pp,
 
 		mvneta_txq_inc_get(txq);
 
-		if (!IS_TSO_HEADER(txq, tx_desc->buf_phys_addr))
-			dma_unmap_single(pp->dev->dev.parent,
-					 tx_desc->buf_phys_addr,
-					 tx_desc->data_size, DMA_TO_DEVICE);
+		if (!IS_TSO_HEADER(txq, tx_desc->buf_phys_addr)) {
+
+			/* The first descriptor is either a TSO header or
+			 * the linear part of the skb.
+			 */
+			if (tx_desc->command & MVNETA_TXD_F_DESC)
+				dma_unmap_single(pp->dev->dev.parent,
+						 tx_desc->buf_phys_addr,
+						 tx_desc->data_size,
+						 DMA_TO_DEVICE);
+			else
+				dma_unmap_page(pp->dev->dev.parent,
+					       tx_desc->buf_phys_addr,
+					       tx_desc->data_size,
+					       DMA_TO_DEVICE);
+		}
 		if (!skb)
 			continue;
 		dev_kfree_skb_any(skb);
@@ -1669,14 +1681,11 @@ static int mvneta_tx_frag_process(struct mvneta_port *pp, struct sk_buff *skb,
 
 	for (i = 0; i < nr_frags; i++) {
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-		void *addr = page_address(frag->page.p) + frag->page_offset;
-
 		tx_desc = mvneta_txq_next_desc_get(txq);
-		tx_desc->data_size = frag->size;
-
-		tx_desc->buf_phys_addr =
-			dma_map_single(pp->dev->dev.parent, addr,
-				       tx_desc->data_size, DMA_TO_DEVICE);
+		tx_desc->data_size = skb_frag_size(frag);
+		tx_desc->buf_phys_addr = skb_frag_dma_map(pp->dev->dev.parent,
+						frag, 0, tx_desc->data_size,
+						DMA_TO_DEVICE);
 
 		if (dma_mapping_error(pp->dev->dev.parent,
 				      tx_desc->buf_phys_addr)) {
@@ -1704,10 +1713,10 @@ error:
 	 */
 	for (i = i - 1; i >= 0; i--) {
 		tx_desc = txq->descs + i;
-		dma_unmap_single(pp->dev->dev.parent,
-				 tx_desc->buf_phys_addr,
-				 tx_desc->data_size,
-				 DMA_TO_DEVICE);
+		dma_unmap_page(pp->dev->dev.parent,
+			       tx_desc->buf_phys_addr,
+			       tx_desc->data_size,
+			       DMA_TO_DEVICE);
 		mvneta_txq_desc_put(txq);
 	}
 
-- 
2.2.1
