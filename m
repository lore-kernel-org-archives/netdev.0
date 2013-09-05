From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH] bnx2x: avoid atomic allocations during initialization
Date: Thu,  5 Sep 2013 22:13:09 +0200
Message-ID: <1378411989-19775-1-git-send-email-mschmidt@redhat.com>
Cc: Ariel Elior <ariele@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1566 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753914Ab3IEUNM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Sep 2013 16:13:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During initialization bnx2x allocates significant amounts of memory
(for rx data, rx SGEs, TPA pool) using atomic allocations.

I received a report where bnx2x failed to allocate SGEs and it had
to fall back to TPA-less operation.

Let's use GFP_KERNEL allocations during initialization, which runs
in process context. Add gfp_t parameters to functions that are used
both in initialization and in the receive path.

Use an unlikely branch in bnx2x_frag_alloc() to avoid atomic allocation
by netdev_alloc_frag(). The branch is taken several thousands of times
during initialization, but then never more. Note that fp->rx_frag_size
is never greater than PAGE_SIZE, so __get_free_page() can be used here.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 38 +++++++++++++++----------
 1 file changed, 23 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 8d726f6..884e8ad 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -484,10 +484,10 @@ static void bnx2x_set_gro_params(struct sk_buff *skb, u16 parsing_flags,
 	NAPI_GRO_CB(skb)->count = num_of_coalesced_segs;
 }
 
-static int bnx2x_alloc_rx_sge(struct bnx2x *bp,
-			      struct bnx2x_fastpath *fp, u16 index)
+static int bnx2x_alloc_rx_sge(struct bnx2x *bp, struct bnx2x_fastpath *fp,
+			      u16 index, gfp_t gfp_mask)
 {
-	struct page *page = alloc_pages(GFP_ATOMIC, PAGES_PER_SGE_SHIFT);
+	struct page *page = alloc_pages(gfp_mask, PAGES_PER_SGE_SHIFT);
 	struct sw_rx_page *sw_buf = &fp->rx_page_ring[index];
 	struct eth_rx_sge *sge = &fp->rx_sge_ring[index];
 	dma_addr_t mapping;
@@ -566,7 +566,7 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 
 		/* If we fail to allocate a substitute page, we simply stop
 		   where we are and drop the whole packet */
-		err = bnx2x_alloc_rx_sge(bp, fp, sge_idx);
+		err = bnx2x_alloc_rx_sge(bp, fp, sge_idx, GFP_ATOMIC);
 		if (unlikely(err)) {
 			bnx2x_fp_qstats(bp, fp)->rx_skb_alloc_failed++;
 			return err;
@@ -610,12 +610,17 @@ static void bnx2x_frag_free(const struct bnx2x_fastpath *fp, void *data)
 		kfree(data);
 }
 
-static void *bnx2x_frag_alloc(const struct bnx2x_fastpath *fp)
+static void *bnx2x_frag_alloc(const struct bnx2x_fastpath *fp, gfp_t gfp_mask)
 {
-	if (fp->rx_frag_size)
+	if (fp->rx_frag_size) {
+		/* GFP_KERNEL allocations are used only during initialization */
+		if (unlikely(gfp_mask & __GFP_WAIT))
+			return (void *)__get_free_page(gfp_mask);
+
 		return netdev_alloc_frag(fp->rx_frag_size);
+	}
 
-	return kmalloc(fp->rx_buf_size + NET_SKB_PAD, GFP_ATOMIC);
+	return kmalloc(fp->rx_buf_size + NET_SKB_PAD, gfp_mask);
 }
 
 #ifdef CONFIG_INET
@@ -695,7 +700,7 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 		goto drop;
 
 	/* Try to allocate the new data */
-	new_data = bnx2x_frag_alloc(fp);
+	new_data = bnx2x_frag_alloc(fp, GFP_ATOMIC);
 	/* Unmap skb in the pool anyway, as we are going to change
 	   pool entry status to BNX2X_TPA_STOP even if new skb allocation
 	   fails. */
@@ -746,15 +751,15 @@ drop:
 	bnx2x_fp_stats(bp, fp)->eth_q_stats.rx_skb_alloc_failed++;
 }
 
-static int bnx2x_alloc_rx_data(struct bnx2x *bp,
-			       struct bnx2x_fastpath *fp, u16 index)
+static int bnx2x_alloc_rx_data(struct bnx2x *bp, struct bnx2x_fastpath *fp,
+			       u16 index, gfp_t gfp_mask)
 {
 	u8 *data;
 	struct sw_rx_bd *rx_buf = &fp->rx_buf_ring[index];
 	struct eth_rx_bd *rx_bd = &fp->rx_desc_ring[index];
 	dma_addr_t mapping;
 
-	data = bnx2x_frag_alloc(fp);
+	data = bnx2x_frag_alloc(fp, gfp_mask);
 	if (unlikely(data == NULL))
 		return -ENOMEM;
 
@@ -947,7 +952,8 @@ int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 			memcpy(skb->data, data + pad, len);
 			bnx2x_reuse_rx_data(fp, bd_cons, bd_prod);
 		} else {
-			if (likely(bnx2x_alloc_rx_data(bp, fp, bd_prod) == 0)) {
+			if (likely(bnx2x_alloc_rx_data(bp, fp, bd_prod,
+						       GFP_ATOMIC) == 0)) {
 				dma_unmap_single(&bp->pdev->dev,
 						 dma_unmap_addr(rx_buf, mapping),
 						 fp->rx_buf_size,
@@ -1307,7 +1313,8 @@ void bnx2x_init_rx_rings(struct bnx2x *bp)
 				struct sw_rx_bd *first_buf =
 					&tpa_info->first_buf;
 
-				first_buf->data = bnx2x_frag_alloc(fp);
+				first_buf->data =
+					bnx2x_frag_alloc(fp, GFP_KERNEL);
 				if (!first_buf->data) {
 					BNX2X_ERR("Failed to allocate TPA skb pool for queue[%d] - disabling TPA on this queue!\n",
 						  j);
@@ -1329,7 +1336,8 @@ void bnx2x_init_rx_rings(struct bnx2x *bp)
 			for (i = 0, ring_prod = 0;
 			     i < MAX_RX_SGE_CNT*NUM_RX_SGE_PAGES; i++) {
 
-				if (bnx2x_alloc_rx_sge(bp, fp, ring_prod) < 0) {
+				if (bnx2x_alloc_rx_sge(bp, fp, ring_prod,
+						       GFP_KERNEL) < 0) {
 					BNX2X_ERR("was only able to allocate %d rx sges\n",
 						  i);
 					BNX2X_ERR("disabling TPA for queue[%d]\n",
@@ -4214,7 +4222,7 @@ static int bnx2x_alloc_rx_bds(struct bnx2x_fastpath *fp,
 	 * fp->eth_q_stats.rx_skb_alloc_failed = 0
 	 */
 	for (i = 0; i < rx_ring_size; i++) {
-		if (bnx2x_alloc_rx_data(bp, fp, ring_prod) < 0) {
+		if (bnx2x_alloc_rx_data(bp, fp, ring_prod, GFP_KERNEL) < 0) {
 			failure_cnt++;
 			continue;
 		}
-- 
1.8.3.1
