From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 3/3] bnxt_en: Divide a page into 32K buffers for the aggregation ring if necessary.
Date: Mon, 25 Apr 2016 02:30:51 -0400
Message-ID: <1461565851-32524-4-git-send-email-michael.chan@broadcom.com>
References: <1461565851-32524-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:2753 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753522AbcDYGax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 02:30:53 -0400
In-Reply-To: <1461565851-32524-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If PAGE_SIZE is bigger than BNXT_RX_PAGE_SIZE, that means the native CPU
page is bigger than the maximum length of the RX BD.  Divide the page
into multiple 32K buffers for the aggregation ring.

Add an offset field in the bnxt_sw_rx_agg_bd struct to keep track of the
page offset of each buffer.  Since each page can be referenced by multiple
buffer entries, call get_page() as needed to get the proper reference
count.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 35 ++++++++++++++++++++++++++-----
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  4 ++++
 2 files changed, 34 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 28480f6..72eb29e 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -581,12 +581,30 @@ static inline int bnxt_alloc_rx_page(struct bnxt *bp,
 	struct page *page;
 	dma_addr_t mapping;
 	u16 sw_prod = rxr->rx_sw_agg_prod;
+	unsigned int offset = 0;
 
-	page = alloc_page(gfp);
-	if (!page)
-		return -ENOMEM;
+	if (PAGE_SIZE > BNXT_RX_PAGE_SIZE) {
+		page = rxr->rx_page;
+		if (!page) {
+			page = alloc_page(gfp);
+			if (!page)
+				return -ENOMEM;
+			rxr->rx_page = page;
+			rxr->rx_page_offset = 0;
+		}
+		offset = rxr->rx_page_offset;
+		rxr->rx_page_offset += BNXT_RX_PAGE_SIZE;
+		if (rxr->rx_page_offset == PAGE_SIZE)
+			rxr->rx_page = NULL;
+		else
+			get_page(page);
+	} else {
+		page = alloc_page(gfp);
+		if (!page)
+			return -ENOMEM;
+	}
 
-	mapping = dma_map_page(&pdev->dev, page, 0, BNXT_RX_PAGE_SIZE,
+	mapping = dma_map_page(&pdev->dev, page, offset, BNXT_RX_PAGE_SIZE,
 			       PCI_DMA_FROMDEVICE);
 	if (dma_mapping_error(&pdev->dev, mapping)) {
 		__free_page(page);
@@ -601,6 +619,7 @@ static inline int bnxt_alloc_rx_page(struct bnxt *bp,
 	rxr->rx_sw_agg_prod = NEXT_RX_AGG(sw_prod);
 
 	rx_agg_buf->page = page;
+	rx_agg_buf->offset = offset;
 	rx_agg_buf->mapping = mapping;
 	rxbd->rx_bd_haddr = cpu_to_le64(mapping);
 	rxbd->rx_bd_opaque = sw_prod;
@@ -642,6 +661,7 @@ static void bnxt_reuse_rx_agg_bufs(struct bnxt_napi *bnapi, u16 cp_cons,
 		page = cons_rx_buf->page;
 		cons_rx_buf->page = NULL;
 		prod_rx_buf->page = page;
+		prod_rx_buf->offset = cons_rx_buf->offset;
 
 		prod_rx_buf->mapping = cons_rx_buf->mapping;
 
@@ -709,7 +729,8 @@ static struct sk_buff *bnxt_rx_pages(struct bnxt *bp, struct bnxt_napi *bnapi,
 			    RX_AGG_CMP_LEN) >> RX_AGG_CMP_LEN_SHIFT;
 
 		cons_rx_buf = &rxr->rx_agg_ring[cons];
-		skb_fill_page_desc(skb, i, cons_rx_buf->page, 0, frag_len);
+		skb_fill_page_desc(skb, i, cons_rx_buf->page,
+				   cons_rx_buf->offset, frag_len);
 		__clear_bit(cons, rxr->rx_agg_bmap);
 
 		/* It is possible for bnxt_alloc_rx_page() to allocate
@@ -1591,6 +1612,10 @@ static void bnxt_free_rx_skbs(struct bnxt *bp)
 
 			__free_page(page);
 		}
+		if (rxr->rx_page) {
+			__free_page(rxr->rx_page);
+			rxr->rx_page = NULL;
+		}
 	}
 }
 
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 0cf1e2a..8b823ff 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -515,6 +515,7 @@ struct bnxt_sw_rx_bd {
 
 struct bnxt_sw_rx_agg_bd {
 	struct page		*page;
+	unsigned int		offset;
 	dma_addr_t		mapping;
 };
 
@@ -595,6 +596,9 @@ struct bnxt_rx_ring_info {
 	unsigned long		*rx_agg_bmap;
 	u16			rx_agg_bmap_size;
 
+	struct page		*rx_page;
+	unsigned int		rx_page_offset;
+
 	dma_addr_t		rx_desc_mapping[MAX_RX_PAGES];
 	dma_addr_t		rx_agg_desc_mapping[MAX_RX_AGG_PAGES];
 
-- 
1.8.3.1
