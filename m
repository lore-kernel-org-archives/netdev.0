From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 2/3] bnxt_en: Limit RX BD pages to be no bigger than 32K.
Date: Mon, 25 Apr 2016 02:30:50 -0400
Message-ID: <1461565851-32524-3-git-send-email-michael.chan@broadcom.com>
References: <1461565851-32524-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:53516 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753476AbcDYGaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 02:30:52 -0400
In-Reply-To: <1461565851-32524-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The RX BD length field of this device is 16-bit, so the largest buffer
size is 65535.  For LRO and GRO, we allocate native CPU pages for the
aggregation ring buffers.  It won't work if the native CPU page size is
64K or bigger.

We fix this by defining BNXT_RX_PAGE_SIZE to be native CPU page size
up to 32K.  Replace PAGE_SIZE with BNXT_RX_PAGE_SIZE in all appropriate
places related to the rx aggregation ring logic.

The next patch will add additional logic to divide the page into 32K
chunks for aggrgation ring buffers if PAGE_SIZE is bigger than
BNXT_RX_PAGE_SIZE.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 18 +++++++++---------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  9 +++++++++
 2 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index e787deb..28480f6 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -586,7 +586,7 @@ static inline int bnxt_alloc_rx_page(struct bnxt *bp,
 	if (!page)
 		return -ENOMEM;
 
-	mapping = dma_map_page(&pdev->dev, page, 0, PAGE_SIZE,
+	mapping = dma_map_page(&pdev->dev, page, 0, BNXT_RX_PAGE_SIZE,
 			       PCI_DMA_FROMDEVICE);
 	if (dma_mapping_error(&pdev->dev, mapping)) {
 		__free_page(page);
@@ -740,7 +740,7 @@ static struct sk_buff *bnxt_rx_pages(struct bnxt *bp, struct bnxt_napi *bnapi,
 			return NULL;
 		}
 
-		dma_unmap_page(&pdev->dev, mapping, PAGE_SIZE,
+		dma_unmap_page(&pdev->dev, mapping, BNXT_RX_PAGE_SIZE,
 			       PCI_DMA_FROMDEVICE);
 
 		skb->data_len += frag_len;
@@ -1584,7 +1584,7 @@ static void bnxt_free_rx_skbs(struct bnxt *bp)
 
 			dma_unmap_page(&pdev->dev,
 				       dma_unmap_addr(rx_agg_buf, mapping),
-				       PAGE_SIZE, PCI_DMA_FROMDEVICE);
+				       BNXT_RX_PAGE_SIZE, PCI_DMA_FROMDEVICE);
 
 			rx_agg_buf->page = NULL;
 			__clear_bit(j, rxr->rx_agg_bmap);
@@ -1973,7 +1973,7 @@ static int bnxt_init_one_rx_ring(struct bnxt *bp, int ring_nr)
 	if (!(bp->flags & BNXT_FLAG_AGG_RINGS))
 		return 0;
 
-	type = ((u32)PAGE_SIZE << RX_BD_LEN_SHIFT) |
+	type = ((u32)BNXT_RX_PAGE_SIZE << RX_BD_LEN_SHIFT) |
 		RX_BD_TYPE_RX_AGG_BD | RX_BD_FLAGS_SOP;
 
 	bnxt_init_rxbd_pages(ring, type);
@@ -2164,7 +2164,7 @@ void bnxt_set_ring_params(struct bnxt *bp)
 	bp->rx_agg_nr_pages = 0;
 
 	if (bp->flags & BNXT_FLAG_TPA)
-		agg_factor = 4;
+		agg_factor = min_t(u32, 4, 65536 / BNXT_RX_PAGE_SIZE);
 
 	bp->flags &= ~BNXT_FLAG_JUMBO;
 	if (rx_space > PAGE_SIZE) {
@@ -3020,12 +3020,12 @@ static int bnxt_hwrm_vnic_set_tpa(struct bnxt *bp, u16 vnic_id, u32 tpa_flags)
 		/* Number of segs are log2 units, and first packet is not
 		 * included as part of this units.
 		 */
-		if (mss <= PAGE_SIZE) {
-			n = PAGE_SIZE / mss;
+		if (mss <= BNXT_RX_PAGE_SIZE) {
+			n = BNXT_RX_PAGE_SIZE / mss;
 			nsegs = (MAX_SKB_FRAGS - 1) * n;
 		} else {
-			n = mss / PAGE_SIZE;
-			if (mss & (PAGE_SIZE - 1))
+			n = mss / BNXT_RX_PAGE_SIZE;
+			if (mss & (BNXT_RX_PAGE_SIZE - 1))
 				n++;
 			nsegs = (MAX_SKB_FRAGS - n) / n;
 		}
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 709b95b..0cf1e2a 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -407,6 +407,15 @@ struct rx_tpa_end_cmp_ext {
 
 #define BNXT_PAGE_SIZE	(1 << BNXT_PAGE_SHIFT)
 
+/* The RXBD length is 16-bit so we can only support page sizes < 64K */
+#if (PAGE_SHIFT > 15)
+#define BNXT_RX_PAGE_SHIFT 15
+#else
+#define BNXT_RX_PAGE_SHIFT PAGE_SHIFT
+#endif
+
+#define BNXT_RX_PAGE_SIZE (1 << BNXT_RX_PAGE_SHIFT)
+
 #define BNXT_MIN_PKT_SIZE	45
 
 #define BNXT_NUM_TESTS(bp)	0
-- 
1.8.3.1
