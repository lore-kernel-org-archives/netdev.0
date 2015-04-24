From: Gabriel Krisman Bertazi <krisman@linux.vnet.ibm.com>
Subject: [PATCH v2] bnx2x: Alloc 4k fragment for each rx ring buffer element
Date: Fri, 24 Apr 2015 17:45:51 -0300
Message-ID: <1429908351-12262-1-git-send-email-krisman@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, cascardo@linux.vnet.ibm.com,
	cascardo@cascardo.eti.br, brking@linux.vnet.ibm.com,
	Gabriel Krisman Bertazi <krisman@linux.vnet.ibm.com>
To: ariel.elior@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:52060 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966779AbbDXUp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 16:45:59 -0400
Received: from /spool/local
	by e24smtp01.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <krisman@linux.vnet.ibm.com>;
	Fri, 24 Apr 2015 17:45:56 -0300
Received: from d24relay02.br.ibm.com (d24relay02.br.ibm.com [9.13.184.26])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id 07A30352006C
	for <netdev@vger.kernel.org>; Fri, 24 Apr 2015 16:44:52 -0400 (EDT)
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
	by d24relay02.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3OKinlH6553868
	for <netdev@vger.kernel.org>; Fri, 24 Apr 2015 17:44:50 -0300
Received: from d24av05.br.ibm.com (localhost [127.0.0.1])
	by d24av05.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3OKjpHd028379
	for <netdev@vger.kernel.org>; Fri, 24 Apr 2015 16:45:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This code assumes that pages are consumed by the device in order. This
> is not true.  The pages are consumed according to packet arrival
> order, which can be from different aggregations.

Thanks for your review.  Here is a new version that fixes the issue you
pointed out and fixes some other things I think that might be a problem.

To fix the issue you presented, I made the memory pool local for each rx
queue, so we don't need to worry about elements coming for different
queues, and also made sure we dealloc fragments separately.

I also modified the allocation code to hold a reference for the pages
that are currently being fragmented, so we can be sure it won't be freed
before using the whole page.

If you have any other concern regarding this fix, please, let me know.

-- >8 --
Subject: [PATCH] bnx2x: Alloc 4k fragment for each rx ring buffer element

The driver allocates one page for each buffer on the rx ring, which is
too much on architectures like ppc64 and can cause unexpected allocation
failures when the system is under stress.  Now, we keep a memory pool
for each rx queue, and if the architecture's PAGE_SIZE is greater than
4k, we fragment pages and assign each 4k segment to a ring element,
which reduces the overall memory consumption on such architectures.
This helps avoiding errors like the example below:

[bnx2x_alloc_rx_sge:435(eth1)]Can't alloc sge
[c00000037ffeb900] [d000000075eddeb4] .bnx2x_alloc_rx_sge+0x44/0x200 [bnx2x]
[c00000037ffeb9b0] [d000000075ee0b34] .bnx2x_fill_frag_skb+0x1ac/0x460 [bnx2x]
[c00000037ffebac0] [d000000075ee11f0] .bnx2x_tpa_stop+0x160/0x2e8 [bnx2x]
[c00000037ffebb90] [d000000075ee1560] .bnx2x_rx_int+0x1e8/0xc30 [bnx2x]
[c00000037ffebcd0] [d000000075ee2084] .bnx2x_poll+0xdc/0x3d8 [bnx2x] (unreliable)

Signed-off-by: Gabriel Krisman Bertazi <krisman@linux.vnet.ibm.com>
---

 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h     | 19 ++++++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 60 +++++++++++++++++--------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h | 33 ++++++++++++--
 3 files changed, 88 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 4085c4b..d0c8ed0 100644
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
@@ -525,6 +528,14 @@ enum bnx2x_tpa_mode_t {
 	TPA_MODE_GRO
 };
 
+struct bnx2x_alloc_pool {
+	struct page	*page;
+	dma_addr_t	dma;
+	int		len;
+	int		offset;
+	int		last_offset;
+};
+
 struct bnx2x_fastpath {
 	struct bnx2x		*bp; /* parent */
 
@@ -611,6 +622,8 @@ struct bnx2x_fastpath {
 	     4 (for the digits and to make it DWORD aligned) */
 #define FP_NAME_SIZE		(sizeof(((struct net_device *)0)->name) + 8)
 	char			name[FP_NAME_SIZE];
+
+	struct bnx2x_alloc_pool	page_pool;
 };
 
 #define bnx2x_fp(bp, nr, var)	((bp)->fp[(nr)].var)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 0a9faa1..2039325 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -544,30 +544,52 @@ static void bnx2x_set_gro_params(struct sk_buff *skb, u16 parsing_flags,
 static int bnx2x_alloc_rx_sge(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 			      u16 index, gfp_t gfp_mask)
 {
-	struct page *page = alloc_pages(gfp_mask, PAGES_PER_SGE_SHIFT);
 	struct sw_rx_page *sw_buf = &fp->rx_page_ring[index];
 	struct eth_rx_sge *sge = &fp->rx_sge_ring[index];
+	struct bnx2x_alloc_pool *pool = &fp->page_pool;
 	dma_addr_t mapping;
 
-	if (unlikely(page == NULL)) {
-		BNX2X_ERR("Can't alloc sge\n");
-		return -ENOMEM;
-	}
+	if (!pool->page || pool->offset > pool->last_offset) {
 
-	mapping = dma_map_page(&bp->pdev->dev, page, 0,
-			       SGE_PAGES, DMA_FROM_DEVICE);
-	if (unlikely(dma_mapping_error(&bp->pdev->dev, mapping))) {
-		__free_pages(page, PAGES_PER_SGE_SHIFT);
-		BNX2X_ERR("Can't map sge\n");
-		return -ENOMEM;
+		/* put page reference used by the memory pool, since we
+		 * won't be using this page as the mempool anymore.
+		 */
+		if (pool->page)
+			put_page(pool->page);
+
+		pool->page = alloc_pages(gfp_mask, PAGES_PER_SGE_SHIFT);
+		if (unlikely(!pool->page)) {
+			BNX2X_ERR("Can't alloc sge\n");
+			return -ENOMEM;
+		}
+
+		pool->dma = dma_map_page(&bp->pdev->dev, pool->page, 0,
+					 PAGE_SIZE, DMA_FROM_DEVICE);
+		if (unlikely(dma_mapping_error(&bp->pdev->dev,
+					       pool->dma))) {
+			__free_pages(pool->page, PAGES_PER_SGE_SHIFT);
+			BNX2X_ERR("Can't map sge\n");
+			return -ENOMEM;
+		}
+		pool->offset = 0;
+		pool->len = PAGE_SIZE;
+		pool->last_offset = ((PAGE_SIZE / SGE_PAGE_SIZE - 1)
+				     * SGE_PAGE_SIZE);
 	}
 
-	sw_buf->page = page;
+	get_page(pool->page);
+	sw_buf->page = pool->page;
+	sw_buf->len = SGE_PAGE_SIZE;
+	sw_buf->offset = pool->offset;
+
+	mapping = pool->dma + sw_buf->offset;
 	dma_unmap_addr_set(sw_buf, mapping, mapping);
 
 	sge->addr_hi = cpu_to_le32(U64_HI(mapping));
 	sge->addr_lo = cpu_to_le32(U64_LO(mapping));
 
+	pool->offset += SGE_PAGE_SIZE;
+
 	return 0;
 }
 
@@ -629,20 +651,22 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 			return err;
 		}
 
-		/* Unmap the page as we're going to pass it to the stack */
-		dma_unmap_page(&bp->pdev->dev,
-			       dma_unmap_addr(&old_rx_pg, mapping),
-			       SGE_PAGES, DMA_FROM_DEVICE);
+		dma_unmap_single(&bp->pdev->dev,
+				 dma_unmap_addr(&old_rx_pg, mapping),
+				 old_rx_pg.len, DMA_FROM_DEVICE);
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
index adcacda..3842d51 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -804,9 +804,14 @@ static inline void bnx2x_free_rx_sge(struct bnx2x *bp,
 	if (!page)
 		return;
 
-	dma_unmap_page(&bp->pdev->dev, dma_unmap_addr(sw_buf, mapping),
-		       SGE_PAGES, DMA_FROM_DEVICE);
-	__free_pages(page, PAGES_PER_SGE_SHIFT);
+	/* Since many fragments can share the same page, make sure to
+	 * only unmap and free the page once.
+	 */
+	dma_unmap_single(&bp->pdev->dev,
+			 dma_unmap_addr(sw_buf, mapping),
+			 sw_buf->len, DMA_FROM_DEVICE);
+
+	put_page(page);
 
 	sw_buf->page = NULL;
 	sge->addr_hi = 0;
@@ -964,6 +969,26 @@ static inline void bnx2x_set_fw_mac_addr(__le16 *fw_hi, __le16 *fw_mid,
 	((u8 *)fw_lo)[1]  = mac[4];
 }
 
+static inline void bnx2x_free_rx_mem_pool(struct bnx2x *bp,
+					  struct bnx2x_alloc_pool *pool)
+{
+	if (!pool->page)
+		return;
+
+	/* Page was not fully fragmented.  Unmap unused space */
+	if (pool->offset <= pool->last_offset) {
+		dma_addr_t dma = pool->dma + pool->offset;
+
+		dma_unmap_single(&bp->pdev->dev, dma,
+				 pool->len - pool->offset,
+				 DMA_FROM_DEVICE);
+	}
+
+	put_page(pool->page);
+
+	pool->page = NULL;
+}
+
 static inline void bnx2x_free_rx_sge_range(struct bnx2x *bp,
 					   struct bnx2x_fastpath *fp, int last)
 {
@@ -974,6 +999,8 @@ static inline void bnx2x_free_rx_sge_range(struct bnx2x *bp,
 
 	for (i = 0; i < last; i++)
 		bnx2x_free_rx_sge(bp, fp, i);
+
+	bnx2x_free_rx_mem_pool(bp, &fp->page_pool);
 }
 
 static inline void bnx2x_set_next_page_rx_bd(struct bnx2x_fastpath *fp)
-- 
2.1.0
