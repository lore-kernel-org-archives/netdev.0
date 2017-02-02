From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 02/12] bnxt_en: Don't use DEFINE_DMA_UNMAP_ADDR to store DMA address in RX path.
Date: Thu,  2 Feb 2017 11:55:30 -0500
Message-ID: <1486054540-366-3-git-send-email-michael.chan@broadcom.com>
References: <1486054540-366-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:32997 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752070AbdBBQz6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 11:55:58 -0500
Received: by mail-pf0-f176.google.com with SMTP id y143so6518229pfb.0
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 08:55:58 -0800 (PST)
In-Reply-To: <1486054540-366-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To support XDP_TX, we need the RX buffer's DMA address to transmit the
packet.  Convert the DMA address field to a permanent field in
bnxt_sw_rx_bd.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 21 +++++++++------------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  2 +-
 2 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 48fb719..c67d74d 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -608,7 +608,7 @@ static inline int bnxt_alloc_rx_data(struct bnxt *bp,
 
 	rx_buf->data = data;
 	rx_buf->data_ptr = data + BNXT_RX_OFFSET;
-	dma_unmap_addr_set(rx_buf, mapping, mapping);
+	rx_buf->mapping = mapping;
 
 	rxbd->rx_bd_haddr = cpu_to_le64(mapping);
 
@@ -628,8 +628,7 @@ static void bnxt_reuse_rx_data(struct bnxt_rx_ring_info *rxr, u16 cons,
 	prod_rx_buf->data = data;
 	prod_rx_buf->data_ptr = cons_rx_buf->data_ptr;
 
-	dma_unmap_addr_set(prod_rx_buf, mapping,
-			   dma_unmap_addr(cons_rx_buf, mapping));
+	prod_rx_buf->mapping = cons_rx_buf->mapping;
 
 	prod_bd = &rxr->rx_desc_ring[RX_RING(prod)][RX_IDX(prod)];
 	cons_bd = &rxr->rx_desc_ring[RX_RING(cons)][RX_IDX(cons)];
@@ -814,7 +813,7 @@ static struct sk_buff *bnxt_rx_pages(struct bnxt *bp, struct bnxt_napi *bnapi,
 		 * a sw_prod index that equals the cons index, so we
 		 * need to clear the cons entry now.
 		 */
-		mapping = dma_unmap_addr(cons_rx_buf, mapping);
+		mapping = cons_rx_buf->mapping;
 		page = cons_rx_buf->page;
 		cons_rx_buf->page = NULL;
 
@@ -957,7 +956,7 @@ static void bnxt_tpa_start(struct bnxt *bp, struct bnxt_rx_ring_info *rxr,
 	prod_rx_buf->data_ptr = tpa_info->data_ptr;
 
 	mapping = tpa_info->mapping;
-	dma_unmap_addr_set(prod_rx_buf, mapping, mapping);
+	prod_rx_buf->mapping = mapping;
 
 	prod_bd = &rxr->rx_desc_ring[RX_RING(prod)][RX_IDX(prod)];
 
@@ -966,7 +965,7 @@ static void bnxt_tpa_start(struct bnxt *bp, struct bnxt_rx_ring_info *rxr,
 	tpa_info->data = cons_rx_buf->data;
 	tpa_info->data_ptr = cons_rx_buf->data_ptr;
 	cons_rx_buf->data = NULL;
-	tpa_info->mapping = dma_unmap_addr(cons_rx_buf, mapping);
+	tpa_info->mapping = cons_rx_buf->mapping;
 
 	tpa_info->len =
 		le32_to_cpu(tpa_start->rx_tpa_start_cmp_len_flags_type) >>
@@ -1403,7 +1402,7 @@ static int bnxt_rx_pkt(struct bnxt *bp, struct bnxt_napi *bnapi, u32 *raw_cons,
 	}
 
 	len = le32_to_cpu(rxcmp->rx_cmp_len_flags_type) >> RX_CMP_LEN_SHIFT;
-	dma_addr = dma_unmap_addr(rx_buf, mapping);
+	dma_addr = rx_buf->mapping;
 
 	if (len <= bp->rx_copy_thresh) {
 		skb = bnxt_copy_skb(bnapi, data_ptr, len, dma_addr);
@@ -1878,7 +1877,7 @@ static void bnxt_free_rx_skbs(struct bnxt *bp)
 
 				dma_unmap_single(
 					&pdev->dev,
-					dma_unmap_addr(tpa_info, mapping),
+					tpa_info->mapping,
 					bp->rx_buf_use_size,
 					PCI_DMA_FROMDEVICE);
 
@@ -1895,8 +1894,7 @@ static void bnxt_free_rx_skbs(struct bnxt *bp)
 			if (!data)
 				continue;
 
-			dma_unmap_single(&pdev->dev,
-					 dma_unmap_addr(rx_buf, mapping),
+			dma_unmap_single(&pdev->dev, rx_buf->mapping,
 					 bp->rx_buf_use_size,
 					 PCI_DMA_FROMDEVICE);
 
@@ -1913,8 +1911,7 @@ static void bnxt_free_rx_skbs(struct bnxt *bp)
 			if (!page)
 				continue;
 
-			dma_unmap_page(&pdev->dev,
-				       dma_unmap_addr(rx_agg_buf, mapping),
+			dma_unmap_page(&pdev->dev, rx_agg_buf->mapping,
 				       BNXT_RX_PAGE_SIZE, PCI_DMA_FROMDEVICE);
 
 			rx_agg_buf->page = NULL;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 33302b0..1707c8b 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -518,7 +518,7 @@ struct bnxt_sw_tx_bd {
 struct bnxt_sw_rx_bd {
 	void			*data;
 	u8			*data_ptr;
-	DEFINE_DMA_UNMAP_ADDR(mapping);
+	dma_addr_t		mapping;
 };
 
 struct bnxt_sw_rx_agg_bd {
-- 
1.8.3.1
