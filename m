From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 04/34]bnx2x: Using system page size for SGE
Date: Wed, 14 Jan 2009 18:42:51 +0200
Message-ID: <1231951371.11301.125.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1340 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761822AbZANQni (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:43:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the page size is not 4KB, the FW must be programmed to work with the right
SGE boundaries and fragment list length.
To avoid confusion with the BCM_PAGE_SIZE which is set to 4KB for the FW sake,
another alias for the system page size was added to explicitly indicate that it
is meant for the SGE

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    3 +++
 drivers/net/bnx2x_main.c |   32 ++++++++++++++++----------------
 2 files changed, 19 insertions(+), 16 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index e5346d8..73f6c21 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -150,6 +150,9 @@ struct sw_rx_page {
 
 #define PAGES_PER_SGE_SHIFT		0
 #define PAGES_PER_SGE			(1 << PAGES_PER_SGE_SHIFT)
+#define SGE_PAGE_SIZE			PAGE_SIZE
+#define SGE_PAGE_SHIFT			PAGE_SHIFT
+#define SGE_PAGE_ALIGN(addr)		PAGE_ALIGN(addr)
 
 #define BCM_RX_ETH_PAYLOAD_ALIGN	64
 
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 5a0a285..e811ecb 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -985,7 +985,7 @@ static inline void bnx2x_free_rx_sge(struct bnx2x *bp,
 		return;
 
 	pci_unmap_page(bp->pdev, pci_unmap_addr(sw_buf, mapping),
-		       BCM_PAGE_SIZE*PAGES_PER_SGE, PCI_DMA_FROMDEVICE);
+		       SGE_PAGE_SIZE*PAGES_PER_SGE, PCI_DMA_FROMDEVICE);
 	__free_pages(page, PAGES_PER_SGE_SHIFT);
 
 	sw_buf->page = NULL;
@@ -1013,7 +1013,7 @@ static inline int bnx2x_alloc_rx_sge(struct bnx2x *bp,
 	if (unlikely(page == NULL))
 		return -ENOMEM;
 
-	mapping = pci_map_page(bp->pdev, page, 0, BCM_PAGE_SIZE*PAGES_PER_SGE,
+	mapping = pci_map_page(bp->pdev, page, 0, SGE_PAGE_SIZE*PAGES_PER_SGE,
 			       PCI_DMA_FROMDEVICE);
 	if (unlikely(dma_mapping_error(&bp->pdev->dev, mapping))) {
 		__free_pages(page, PAGES_PER_SGE_SHIFT);
@@ -1109,9 +1109,9 @@ static void bnx2x_update_sge_prod(struct bnx2x_fastpath *fp,
 				  struct eth_fast_path_rx_cqe *fp_cqe)
 {
 	struct bnx2x *bp = fp->bp;
-	u16 sge_len = BCM_PAGE_ALIGN(le16_to_cpu(fp_cqe->pkt_len) -
+	u16 sge_len = SGE_PAGE_ALIGN(le16_to_cpu(fp_cqe->pkt_len) -
 				     le16_to_cpu(fp_cqe->len_on_bd)) >>
-		      BCM_PAGE_SHIFT;
+		      SGE_PAGE_SHIFT;
 	u16 last_max, last_elem, first_elem;
 	u16 delta = 0;
 	u16 i;
@@ -1216,22 +1216,22 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 			       u16 cqe_idx)
 {
 	struct sw_rx_page *rx_pg, old_rx_pg;
-	struct page *sge;
 	u16 len_on_bd = le16_to_cpu(fp_cqe->len_on_bd);
 	u32 i, frag_len, frag_size, pages;
 	int err;
 	int j;
 
 	frag_size = le16_to_cpu(fp_cqe->pkt_len) - len_on_bd;
-	pages = BCM_PAGE_ALIGN(frag_size) >> BCM_PAGE_SHIFT;
+	pages = SGE_PAGE_ALIGN(frag_size) >> SGE_PAGE_SHIFT;
 
 	/* This is needed in order to enable forwarding support */
 	if (frag_size)
-		skb_shinfo(skb)->gso_size = min((u32)BCM_PAGE_SIZE,
+		skb_shinfo(skb)->gso_size = min((u32)SGE_PAGE_SIZE,
 					       max(frag_size, (u32)len_on_bd));
 
 #ifdef BNX2X_STOP_ON_ERROR
-	if (pages > 8*PAGES_PER_SGE) {
+	if (pages >
+	    min((u32)8, (u32)MAX_SKB_FRAGS) * SGE_PAGE_SIZE * PAGES_PER_SGE) {
 		BNX2X_ERR("SGL length is too long: %d. CQE index is %d\n",
 			  pages, cqe_idx);
 		BNX2X_ERR("fp_cqe->pkt_len = %d  fp_cqe->len_on_bd = %d\n",
@@ -1247,9 +1247,8 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 
 		/* FW gives the indices of the SGE as if the ring is an array
 		   (meaning that "next" element will consume 2 indices) */
-		frag_len = min(frag_size, (u32)(BCM_PAGE_SIZE*PAGES_PER_SGE));
+		frag_len = min(frag_size, (u32)(SGE_PAGE_SIZE*PAGES_PER_SGE));
 		rx_pg = &fp->rx_page_ring[sge_idx];
-		sge = rx_pg->page;
 		old_rx_pg = *rx_pg;
 
 		/* If we fail to allocate a substitute page, we simply stop
@@ -1262,7 +1261,7 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 
 		/* Unmap the page as we r going to pass it to the stack */
 		pci_unmap_page(bp->pdev, pci_unmap_addr(&old_rx_pg, mapping),
-			      BCM_PAGE_SIZE*PAGES_PER_SGE, PCI_DMA_FROMDEVICE);
+			      SGE_PAGE_SIZE*PAGES_PER_SGE, PCI_DMA_FROMDEVICE);
 
 		/* Add one frag and update the appropriate fields in the skb */
 		skb_fill_page_desc(skb, j, old_rx_pg.page, 0, frag_len);
@@ -4555,7 +4554,7 @@ static void bnx2x_set_client_config(struct bnx2x *bp)
 
 	if (bp->flags & TPA_ENABLE_FLAG) {
 		tstorm_client.max_sges_for_packet =
-			BCM_PAGE_ALIGN(tstorm_client.mtu) >> BCM_PAGE_SHIFT;
+			SGE_PAGE_ALIGN(tstorm_client.mtu) >> SGE_PAGE_SHIFT;
 		tstorm_client.max_sges_for_packet =
 			((tstorm_client.max_sges_for_packet +
 			  PAGES_PER_SGE - 1) & (~(PAGES_PER_SGE - 1))) >>
@@ -4738,10 +4737,11 @@ static void bnx2x_init_internal_func(struct bnx2x *bp)
 			 bp->e1hov);
 	}
 
-	/* Init CQ ring mapping and aggregation size */
-	max_agg_size = min((u32)(bp->rx_buf_size +
-				 8*BCM_PAGE_SIZE*PAGES_PER_SGE),
-			   (u32)0xffff);
+	/* Init CQ ring mapping and aggregation size, the FW limit is 8 frags */
+	max_agg_size =
+		min((u32)(min((u32)8, (u32)MAX_SKB_FRAGS) *
+			  SGE_PAGE_SIZE * PAGES_PER_SGE),
+		    (u32)0xffff);
 	for_each_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
-- 
1.5.4.3




