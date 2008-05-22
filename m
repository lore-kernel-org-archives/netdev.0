From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2/3 2.6.27 RESEND] cxgb3 - Add page support to jumbo frame Rx
	queue
Date: Wed, 21 May 2008 18:56:21 -0700
Message-ID: <20080522015621.25353.79841.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:24791 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933211AbYEVB4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 21:56:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Add page support to Jumbo frame Rx queues.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/adapter.h |    4 +
 drivers/net/cxgb3/sge.c     |  115 ++++++++++++++++++++++++++++++-------------
 2 files changed, 84 insertions(+), 35 deletions(-)

diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index acebe43..263e4fa 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -92,6 +92,7 @@ struct sge_fl {                     /* SGE per free-buffer list state */
 	unsigned int gen;           /* free list generation */
 	struct fl_pg_chunk pg_chunk;/* page chunk cache */
 	unsigned int use_pages;     /* whether FL uses pages or sk_buffs */
+	unsigned int order;	    /* order of page allocations */
 	struct rx_desc *desc;       /* address of HW Rx descriptor ring */
 	struct rx_sw_desc *sdesc;   /* address of SW Rx descriptor ring */
 	dma_addr_t   phys_addr;     /* physical address of HW ring start */
@@ -116,12 +117,15 @@ struct sge_rspq {		/* state for an SGE response queue */
 	unsigned int polling;	/* is the queue serviced through NAPI? */
 	unsigned int holdoff_tmr;	/* interrupt holdoff timer in 100ns */
 	unsigned int next_holdoff;	/* holdoff time for next interrupt */
+	unsigned int rx_recycle_buf; /* whether recycling occurred
+					within current sop-eop */
 	struct rsp_desc *desc;	/* address of HW response ring */
 	dma_addr_t phys_addr;	/* physical address of the ring */
 	unsigned int cntxt_id;	/* SGE context id for the response q */
 	spinlock_t lock;	/* guards response processing */
 	struct sk_buff *rx_head;	/* offload packet receive queue head */
 	struct sk_buff *rx_tail;	/* offload packet receive queue tail */
+	struct sk_buff *pg_skb; /* used to build frag list in napi handler */
 
 	unsigned long offload_pkts;
 	unsigned long offload_bundles;
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 0741deb..3e91be5 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -55,6 +55,9 @@
  * directly.
  */
 #define FL0_PG_CHUNK_SIZE  2048
+#define FL0_PG_ORDER 0
+#define FL1_PG_CHUNK_SIZE (PAGE_SIZE > 8192 ? 16384 : 8192)
+#define FL1_PG_ORDER (PAGE_SIZE > 8192 ? 0 : 1)
 
 #define SGE_RX_DROP_THRES 16
 
@@ -359,7 +362,7 @@ static void free_rx_bufs(struct pci_dev *pdev, struct sge_fl *q)
 	}
 
 	if (q->pg_chunk.page) {
-		__free_page(q->pg_chunk.page);
+		__free_pages(q->pg_chunk.page, q->order);
 		q->pg_chunk.page = NULL;
 	}
 }
@@ -396,10 +399,11 @@ static inline int add_one_rx_buf(void *va, unsigned int len,
 	return 0;
 }
 
-static int alloc_pg_chunk(struct sge_fl *q, struct rx_sw_desc *sd, gfp_t gfp)
+static int alloc_pg_chunk(struct sge_fl *q, struct rx_sw_desc *sd, gfp_t gfp,
+			  unsigned int order)
 {
 	if (!q->pg_chunk.page) {
-		q->pg_chunk.page = alloc_page(gfp);
+		q->pg_chunk.page = alloc_pages(gfp, order);
 		if (unlikely(!q->pg_chunk.page))
 			return -ENOMEM;
 		q->pg_chunk.va = page_address(q->pg_chunk.page);
@@ -408,7 +412,7 @@ static int alloc_pg_chunk(struct sge_fl *q, struct rx_sw_desc *sd, gfp_t gfp)
 	sd->pg_chunk = q->pg_chunk;
 
 	q->pg_chunk.offset += q->buf_size;
-	if (q->pg_chunk.offset == PAGE_SIZE)
+	if (q->pg_chunk.offset == (PAGE_SIZE << order))
 		q->pg_chunk.page = NULL;
 	else {
 		q->pg_chunk.va += q->buf_size;
@@ -439,7 +443,7 @@ static int refill_fl(struct adapter *adap, struct sge_fl *q, int n, gfp_t gfp)
 		int err;
 
 		if (q->use_pages) {
-			if (unlikely(alloc_pg_chunk(q, sd, gfp))) {
+			if (unlikely(alloc_pg_chunk(q, sd, gfp, q->order))) {
 nomem:				q->alloc_failed++;
 				break;
 			}
@@ -484,7 +488,8 @@ nomem:				q->alloc_failed++;
 
 static inline void __refill_fl(struct adapter *adap, struct sge_fl *fl)
 {
-	refill_fl(adap, fl, min(16U, fl->size - fl->credits), GFP_ATOMIC);
+	refill_fl(adap, fl, min(16U, fl->size - fl->credits),
+		  GFP_ATOMIC | __GFP_COMP);
 }
 
 /**
@@ -759,19 +764,22 @@ use_orig_buf:
  * 	that are page chunks rather than sk_buffs.
  */
 static struct sk_buff *get_packet_pg(struct adapter *adap, struct sge_fl *fl,
-				     unsigned int len, unsigned int drop_thres)
+				     struct sge_rspq *q, unsigned int len,
+				     unsigned int drop_thres)
 {
-	struct sk_buff *skb = NULL;
+	struct sk_buff *newskb, *skb;
 	struct rx_sw_desc *sd = &fl->sdesc[fl->cidx];
 
-	if (len <= SGE_RX_COPY_THRES) {
-		skb = alloc_skb(len, GFP_ATOMIC);
-		if (likely(skb != NULL)) {
-			__skb_put(skb, len);
+	newskb = skb = q->pg_skb;
+
+	if (!skb && (len <= SGE_RX_COPY_THRES)) {
+		newskb = alloc_skb(len, GFP_ATOMIC);
+		if (likely(newskb != NULL)) {
+			__skb_put(newskb, len);
 			pci_dma_sync_single_for_cpu(adap->pdev,
 					    pci_unmap_addr(sd, dma_addr), len,
 					    PCI_DMA_FROMDEVICE);
-			memcpy(skb->data, sd->pg_chunk.va, len);
+			memcpy(newskb->data, sd->pg_chunk.va, len);
 			pci_dma_sync_single_for_device(adap->pdev,
 					    pci_unmap_addr(sd, dma_addr), len,
 					    PCI_DMA_FROMDEVICE);
@@ -780,14 +788,16 @@ static struct sk_buff *get_packet_pg(struct adapter *adap, struct sge_fl *fl,
 recycle:
 		fl->credits--;
 		recycle_rx_buf(adap, fl, fl->cidx);
-		return skb;
+		q->rx_recycle_buf++;
+		return newskb;
 	}
 
-	if (unlikely(fl->credits <= drop_thres))
+	if (unlikely(q->rx_recycle_buf || (!skb && fl->credits <= drop_thres)))
 		goto recycle;
 
-	skb = alloc_skb(SGE_RX_PULL_LEN, GFP_ATOMIC);
-	if (unlikely(!skb)) {
+	if (!skb)
+		newskb = alloc_skb(SGE_RX_PULL_LEN, GFP_ATOMIC);	
+	if (unlikely(!newskb)) {
 		if (!drop_thres)
 			return NULL;
 		goto recycle;
@@ -795,21 +805,29 @@ recycle:
 
 	pci_unmap_single(adap->pdev, pci_unmap_addr(sd, dma_addr),
 			 fl->buf_size, PCI_DMA_FROMDEVICE);
-	__skb_put(skb, SGE_RX_PULL_LEN);
-	memcpy(skb->data, sd->pg_chunk.va, SGE_RX_PULL_LEN);
-	skb_fill_page_desc(skb, 0, sd->pg_chunk.page,
-			   sd->pg_chunk.offset + SGE_RX_PULL_LEN,
-			   len - SGE_RX_PULL_LEN);
-	skb->len = len;
-	skb->data_len = len - SGE_RX_PULL_LEN;
-	skb->truesize += skb->data_len;
+	if (!skb) {
+		__skb_put(newskb, SGE_RX_PULL_LEN);
+		memcpy(newskb->data, sd->pg_chunk.va, SGE_RX_PULL_LEN);
+		skb_fill_page_desc(newskb, 0, sd->pg_chunk.page,
+				   sd->pg_chunk.offset + SGE_RX_PULL_LEN,
+				   len - SGE_RX_PULL_LEN);
+		newskb->len = len;
+		newskb->data_len = len - SGE_RX_PULL_LEN;
+	} else {
+		skb_fill_page_desc(newskb, skb_shinfo(newskb)->nr_frags,
+				   sd->pg_chunk.page,
+				   sd->pg_chunk.offset, len);
+		newskb->len += len;
+		newskb->data_len += len;
+	}
+	newskb->truesize += newskb->data_len;
 
 	fl->credits--;
 	/*
 	 * We do not refill FLs here, we let the caller do it to overlap a
 	 * prefetch.
 	 */
-	return skb;
+	return newskb;
 }
 
 /**
@@ -1966,6 +1984,12 @@ static inline int is_new_response(const struct rsp_desc *r,
 	return (r->intr_gen & F_RSPD_GEN2) == q->gen;
 }
 
+static inline void clear_rspq_bufstate(struct sge_rspq * const q)
+{
+	q->pg_skb = NULL;
+	q->rx_recycle_buf = 0;
+}
+
 #define RSPD_GTS_MASK  (F_RSPD_TXQ0_GTS | F_RSPD_TXQ1_GTS)
 #define RSPD_CTRL_MASK (RSPD_GTS_MASK | \
 			V_RSPD_TXQ0_CR(M_RSPD_TXQ0_CR) | \
@@ -2003,10 +2027,11 @@ static int process_responses(struct adapter *adap, struct sge_qset *qs,
 	q->next_holdoff = q->holdoff_tmr;
 
 	while (likely(budget_left && is_new_response(r, q))) {
-		int eth, ethpad = 2;
+		int packet_complete, eth, ethpad = 2;
 		struct sk_buff *skb = NULL;
 		u32 len, flags = ntohl(r->flags);
-		__be32 rss_hi = *(const __be32 *)r, rss_lo = r->rss_hdr.rss_hash_val;
+		__be32 rss_hi = *(const __be32 *)r,
+		       rss_lo = r->rss_hdr.rss_hash_val;
 
 		eth = r->rss_hdr.opcode == CPL_RX_PKT;
 
@@ -2044,8 +2069,11 @@ no_mem:
 #endif
 				__refill_fl(adap, fl);
 
-				skb = get_packet_pg(adap, fl, G_RSPD_LEN(len),
-						 eth ? SGE_RX_DROP_THRES : 0);
+				skb = get_packet_pg(adap, fl, q,
+						    G_RSPD_LEN(len),
+						    eth ?
+						    SGE_RX_DROP_THRES : 0);
+				q->pg_skb = skb;
 			} else
 				skb = get_packet(adap, fl, G_RSPD_LEN(len),
 						 eth ? SGE_RX_DROP_THRES : 0);
@@ -2079,7 +2107,11 @@ no_mem:
 			q->credits = 0;
 		}
 
-		if (likely(skb != NULL)) {
+		packet_complete = flags &
+				  (F_RSPD_EOP | F_RSPD_IMM_DATA_VALID |
+				   F_RSPD_ASYNC_NOTIF);
+
+		if (skb != NULL && packet_complete) {
 			if (eth)
 				rx_eth(adap, q, skb, ethpad);
 			else {
@@ -2091,6 +2123,9 @@ no_mem:
 						       offload_skbs,
 						       ngathered);
 			}
+
+			if (flags & F_RSPD_EOP)
+				clear_rspq_bufstate(q);	
 		}
 		--budget_left;
 	}
@@ -2706,10 +2741,18 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 #else
 	q->fl[0].buf_size = SGE_RX_SM_BUF_SIZE + sizeof(struct cpl_rx_data);
 #endif
-	q->fl[0].use_pages = FL0_PG_CHUNK_SIZE > 0;
+#if FL1_PG_CHUNK_SIZE > 0
+	q->fl[1].buf_size = FL1_PG_CHUNK_SIZE;
+#else
 	q->fl[1].buf_size = is_offload(adapter) ?
 		(16 * 1024) - SKB_DATA_ALIGN(sizeof(struct skb_shared_info)) :
 		MAX_FRAME_SIZE + 2 + sizeof(struct cpl_rx_pkt);
+#endif
+
+	q->fl[0].use_pages = FL0_PG_CHUNK_SIZE > 0;
+	q->fl[1].use_pages = FL1_PG_CHUNK_SIZE > 0;
+	q->fl[0].order = FL0_PG_ORDER;
+	q->fl[1].order = FL1_PG_ORDER;
 
 	spin_lock_irq(&adapter->sge.reg_lock);
 
@@ -2760,7 +2803,8 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 	q->adap = adapter;
 	q->netdev = dev;
 	t3_update_qset_coalesce(q, p);
-	avail = refill_fl(adapter, &q->fl[0], q->fl[0].size, GFP_KERNEL);
+	avail = refill_fl(adapter, &q->fl[0], q->fl[0].size,
+			  GFP_KERNEL | __GFP_COMP);
 	if (!avail) {
 		CH_ALERT(adapter, "free list queue 0 initialization failed\n");
 		goto err;
@@ -2769,7 +2813,8 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 		CH_WARN(adapter, "free list queue 0 enabled with %d credits\n",
 			avail);
 
-	avail = refill_fl(adapter, &q->fl[1], q->fl[1].size, GFP_KERNEL);
+	avail = refill_fl(adapter, &q->fl[1], q->fl[1].size,
+			  GFP_KERNEL | __GFP_COMP);
 	if (avail < q->fl[1].size)
 		CH_WARN(adapter, "free list queue 1 enabled with %d credits\n",
 			avail);
@@ -2905,7 +2950,7 @@ void t3_sge_prep(struct adapter *adap, struct sge_params *p)
 		q->coalesce_usecs = 5;
 		q->rspq_size = 1024;
 		q->fl_size = 1024;
-		q->jumbo_size = 512;
+ 		q->jumbo_size = 512;
 		q->txq_size[TXQ_ETH] = 1024;
 		q->txq_size[TXQ_OFLD] = 1024;
 		q->txq_size[TXQ_CTRL] = 256;
