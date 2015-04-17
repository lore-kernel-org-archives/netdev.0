From: Gabriel Krisman Bertazi <krisman@linux.vnet.ibm.com>
Subject: [PATCH] bnx2x: Alloc 4k fragment for each rx ring buffer element
Date: Fri, 17 Apr 2015 14:58:44 -0300
Message-ID: <1429293524-26897-1-git-send-email-krisman@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, cascardo@linux.vnet.ibm.com,
	Gabriel Krisman Bertazi <krisman@linux.vnet.ibm.com>
To: ariel.elior@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp04.br.ibm.com ([32.104.18.25]:57760 "EHLO
	e24smtp04.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932462AbbDQR7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2015 13:59:36 -0400
Received: from /spool/local
	by e24smtp04.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <krisman@linux.vnet.ibm.com>;
	Fri, 17 Apr 2015 14:59:33 -0300
Received: from d24relay03.br.ibm.com (d24relay03.br.ibm.com [9.13.184.25])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id 057DE1DC0057
	for <netdev@vger.kernel.org>; Fri, 17 Apr 2015 13:58:31 -0400 (EDT)
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by d24relay03.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3HHwXYh52559926
	for <netdev@vger.kernel.org>; Fri, 17 Apr 2015 14:58:34 -0300
Received: from d24av04.br.ibm.com (localhost [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3HHxR0C027313
	for <netdev@vger.kernel.org>; Fri, 17 Apr 2015 14:59:27 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver allocates one page for each buffer on the rx ring, which is
too much on architectures like ppc64 and can cause unexpected allocation
failures when the system is under stress.  Now, if the architecture's
PAGE_SIZE is greater than 4k, we fragment pages and assign each 4k
segment to a ring element, which reduces the overall memory consumption
on such architectures.  This helps avoiding errors like the example
below:

[bnx2x_alloc_rx_sge:435(eth1)]Can't alloc sge
[c00000037ffeb900] [d000000075eddeb4] .bnx2x_alloc_rx_sge+0x44/0x200 [bnx2x]
[c00000037ffeb9b0] [d000000075ee0b34] .bnx2x_fill_frag_skb+0x1ac/0x460 [bnx2x]
[c00000037ffebac0] [d000000075ee11f0] .bnx2x_tpa_stop+0x160/0x2e8 [bnx2x]
[c00000037ffebb90] [d000000075ee1560] .bnx2x_rx_int+0x1e8/0xc30 [bnx2x]
[c00000037ffebcd0] [d000000075ee2084] .bnx2x_poll+0xdc/0x3d8 [bnx2x] (unreliable)

Signed-off-by: Gabriel Krisman Bertazi <krisman@linux.vnet.ibm.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h     | 18 ++++++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 61 +++++++++++++++++--------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h | 10 ++--
 3 files changed, 65 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 4085c4b..292176a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -356,6 +356,8 @@ struct sw_tx_bd {
 
 struct sw_rx_page {
 	struct page	*page;
+	int		len;
+	int		offset;
 	DEFINE_DMA_UNMAP_ADDR(mapping);
 };
 
@@ -381,9 +383,10 @@ union db_prod {
 
 #define PAGES_PER_SGE_SHIFT	0
 #define PAGES_PER_SGE		(1 << PAGES_PER_SGE_SHIFT)
-#define SGE_PAGE_SIZE		PAGE_SIZE
-#define SGE_PAGE_SHIFT		PAGE_SHIFT
-#define SGE_PAGE_ALIGN(addr)	PAGE_ALIGN((typeof(PAGE_SIZE))(addr))
+#define SGE_PAGE_SHIFT		12
+#define SGE_PAGE_SIZE		(1 << SGE_PAGE_SHIFT)
+#define SGE_PAGE_MASK		(~(SGE_PAGE_SIZE - 1))
+#define SGE_PAGE_ALIGN(addr)	(((addr) + SGE_PAGE_SIZE - 1) & SGE_PAGE_MASK)
 #define SGE_PAGES		(SGE_PAGE_SIZE * PAGES_PER_SGE)
 #define TPA_AGG_SIZE		min_t(u32, (min_t(u32, 8, MAX_SKB_FRAGS) * \
 					    SGE_PAGES), 0xffff)
@@ -1450,6 +1453,13 @@ enum {
 	SUB_MF_MODE_NPAR1_DOT_5,
 };
 
+struct bnx2x_alloc_pool {
+	struct page	*page;
+	dma_addr_t	dma;
+	int		len;
+	int		offset;
+};
+
 struct bnx2x {
 	/* Fields used in the tx and intr/napi performance paths
 	 * are grouped together in the beginning of the structure
@@ -1562,6 +1572,8 @@ struct bnx2x {
 	__le16			*eq_cons_sb;
 	atomic_t		eq_spq_left; /* COMMON_XXX ramrods credit */
 
+	struct bnx2x_alloc_pool	page_pool;
+
 	/* Counter for marking that there is a STAT_QUERY ramrod pending */
 	u16			stats_pending;
 	/*  Counter for completed statistics ramrods */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 0a9faa1..47cc31f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -544,30 +544,46 @@ static void bnx2x_set_gro_params(struct sk_buff *skb, u16 parsing_flags,
 static int bnx2x_alloc_rx_sge(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 			      u16 index, gfp_t gfp_mask)
 {
-	struct page *page = alloc_pages(gfp_mask, PAGES_PER_SGE_SHIFT);
 	struct sw_rx_page *sw_buf = &fp->rx_page_ring[index];
 	struct eth_rx_sge *sge = &fp->rx_sge_ring[index];
+	struct page **page = &bp->page_pool.page;
 	dma_addr_t mapping;
 
-	if (unlikely(page == NULL)) {
-		BNX2X_ERR("Can't alloc sge\n");
-		return -ENOMEM;
-	}
+	if (!*page ||
+	    (bp->page_pool.len - bp->page_pool.offset) < SGE_PAGE_SIZE) {
+		*page = alloc_pages(gfp_mask, PAGES_PER_SGE_SHIFT);
 
-	mapping = dma_map_page(&bp->pdev->dev, page, 0,
-			       SGE_PAGES, DMA_FROM_DEVICE);
-	if (unlikely(dma_mapping_error(&bp->pdev->dev, mapping))) {
-		__free_pages(page, PAGES_PER_SGE_SHIFT);
-		BNX2X_ERR("Can't map sge\n");
-		return -ENOMEM;
+		if (unlikely(!*page)) {
+			BNX2X_ERR("Can't alloc sge\n");
+			return -ENOMEM;
+		}
+		bp->page_pool.dma = dma_map_page(&bp->pdev->dev, *page, 0,
+						 PAGE_SIZE, DMA_FROM_DEVICE);
+		if (unlikely(dma_mapping_error(&bp->pdev->dev,
+					       bp->page_pool.dma))) {
+			__free_pages(*page, PAGES_PER_SGE_SHIFT);
+			BNX2X_ERR("Can't map sge\n");
+			return -ENOMEM;
+		}
+
+		bp->page_pool.offset = 0;
+		bp->page_pool.len = PAGE_SIZE;
+	} else {
+		get_page(bp->page_pool.page);
 	}
 
-	sw_buf->page = page;
+	sw_buf->page = *page;
+	sw_buf->len = SGE_PAGE_SIZE;
+	sw_buf->offset = bp->page_pool.offset;
+
+	mapping = bp->page_pool.dma + sw_buf->offset;
 	dma_unmap_addr_set(sw_buf, mapping, mapping);
 
 	sge->addr_hi = cpu_to_le32(U64_HI(mapping));
 	sge->addr_lo = cpu_to_le32(U64_LO(mapping));
 
+	bp->page_pool.offset += SGE_PAGE_SIZE;
+
 	return 0;
 }
 
@@ -628,21 +644,30 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 			bnx2x_fp_qstats(bp, fp)->rx_skb_alloc_failed++;
 			return err;
 		}
+		if (old_rx_pg.offset + old_rx_pg.len >= PAGE_SIZE) {
+			/* Unmap the page as we finished passing it to
+			 * the stack
+			 */
+			old_rx_pg.mapping = old_rx_pg.mapping -
+				old_rx_pg.offset;
+			dma_unmap_page(&bp->pdev->dev,
+				       dma_unmap_addr(&old_rx_pg, mapping),
+				       PAGE_SIZE, DMA_FROM_DEVICE);
+		}
 
-		/* Unmap the page as we're going to pass it to the stack */
-		dma_unmap_page(&bp->pdev->dev,
-			       dma_unmap_addr(&old_rx_pg, mapping),
-			       SGE_PAGES, DMA_FROM_DEVICE);
 		/* Add one frag and update the appropriate fields in the skb */
 		if (fp->mode == TPA_MODE_LRO)
-			skb_fill_page_desc(skb, j, old_rx_pg.page, 0, frag_len);
+			skb_fill_page_desc(skb, j, old_rx_pg.page,
+					   old_rx_pg.offset, frag_len);
 		else { /* GRO */
 			int rem;
 			int offset = 0;
 			for (rem = frag_len; rem > 0; rem -= gro_size) {
 				int len = rem > gro_size ? gro_size : rem;
 				skb_fill_page_desc(skb, frag_id++,
-						   old_rx_pg.page, offset, len);
+						   old_rx_pg.page,
+						   old_rx_pg.offset + offset,
+						   len);
 				if (offset)
 					get_page(old_rx_pg.page);
 				offset += len;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index adcacda..80a54ac 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -799,14 +799,18 @@ static inline void bnx2x_free_rx_sge(struct bnx2x *bp,
 	struct sw_rx_page *sw_buf = &fp->rx_page_ring[index];
 	struct page *page = sw_buf->page;
 	struct eth_rx_sge *sge = &fp->rx_sge_ring[index];
+	dma_addr_t dma;
 
 	/* Skip "next page" elements */
 	if (!page)
 		return;
 
-	dma_unmap_page(&bp->pdev->dev, dma_unmap_addr(sw_buf, mapping),
-		       SGE_PAGES, DMA_FROM_DEVICE);
-	__free_pages(page, PAGES_PER_SGE_SHIFT);
+	if (sw_buf->offset + sw_buf->len >= PAGE_SIZE) {
+		dma = sw_buf->mapping - sw_buf->offset;
+		dma_unmap_page(&bp->pdev->dev, dma,
+			       PAGE_SIZE, DMA_FROM_DEVICE);
+	}
+	put_page(page);
 
 	sw_buf->page = NULL;
 	sge->addr_hi = 0;
-- 
2.1.0
