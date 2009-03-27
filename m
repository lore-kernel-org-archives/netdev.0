From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2.6.30 5/5] cxgb3: map entire Rx page,
	feed map+offset to Rx ring.
Date: Thu, 26 Mar 2009 19:39:29 -0700
Message-ID: <20090327023929.32137.65704.stgit@speedy5>
References: <20090327023909.32137.93884.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:31281 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755724AbZC0Cjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 22:39:33 -0400
In-Reply-To: <20090327023909.32137.93884.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

DMA mapping can be expensive in the presence of iommus.
Reduce the Rx iommu activity by mapping an entire page, and provide the H/W
the mapped address + offset of the current page chunk.
Reserve bits at the end of the page to track mapping references, so the page
can be unmapped.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/adapter.h |    3 +
 drivers/net/cxgb3/sge.c     |  138 ++++++++++++++++++++++++++++++++-----------
 2 files changed, 106 insertions(+), 35 deletions(-)

diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index 2cf6c92..714df2b 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -85,6 +85,8 @@ struct fl_pg_chunk {
 	struct page *page;
 	void *va;
 	unsigned int offset;
+	u64 *p_cnt;
+	DECLARE_PCI_UNMAP_ADDR(mapping);
 };
 
 struct rx_desc;
@@ -101,6 +103,7 @@ struct sge_fl {                     /* SGE per free-buffer list state */
 	struct fl_pg_chunk pg_chunk;/* page chunk cache */
 	unsigned int use_pages;     /* whether FL uses pages or sk_buffs */
 	unsigned int order;	    /* order of page allocations */
+	unsigned int alloc_size;    /* size of allocated buffer */
 	struct rx_desc *desc;       /* address of HW Rx descriptor ring */
 	struct rx_sw_desc *sdesc;   /* address of SW Rx descriptor ring */
 	dma_addr_t   phys_addr;     /* physical address of HW ring start */
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
old mode 100755
new mode 100644
index 54667f0..26d3587
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -50,6 +50,7 @@
 #define SGE_RX_COPY_THRES  256
 #define SGE_RX_PULL_LEN    128
 
+#define SGE_PG_RSVD SMP_CACHE_BYTES
 /*
  * Page chunk size for FL0 buffers if FL0 is to be populated with page chunks.
  * It must be a divisor of PAGE_SIZE.  If set to 0 FL0 will use sk_buffs
@@ -57,8 +58,10 @@
  */
 #define FL0_PG_CHUNK_SIZE  2048
 #define FL0_PG_ORDER 0
+#define FL0_PG_ALLOC_SIZE (PAGE_SIZE << FL0_PG_ORDER)
 #define FL1_PG_CHUNK_SIZE (PAGE_SIZE > 8192 ? 16384 : 8192)
 #define FL1_PG_ORDER (PAGE_SIZE > 8192 ? 0 : 1)
+#define FL1_PG_ALLOC_SIZE (PAGE_SIZE << FL1_PG_ORDER)
 
 #define SGE_RX_DROP_THRES 16
 #define RX_RECLAIM_PERIOD (HZ/4)
@@ -345,13 +348,21 @@ static inline int should_restart_tx(const struct sge_txq *q)
 	return q->in_use - r < (q->size >> 1);
 }
 
-static void clear_rx_desc(const struct sge_fl *q, struct rx_sw_desc *d)
+static void clear_rx_desc(struct pci_dev *pdev, const struct sge_fl *q,
+			  struct rx_sw_desc *d)
 {
-	if (q->use_pages) {
-		if (d->pg_chunk.page)
-			put_page(d->pg_chunk.page);
+	if (q->use_pages && d->pg_chunk.page) {
+		(*d->pg_chunk.p_cnt)--;
+		if (!*d->pg_chunk.p_cnt)
+			pci_unmap_page(pdev,
+				       pci_unmap_addr(&d->pg_chunk, mapping),
+				       q->alloc_size, PCI_DMA_FROMDEVICE);
+
+		put_page(d->pg_chunk.page);
 		d->pg_chunk.page = NULL;
 	} else {
+		pci_unmap_single(pdev, pci_unmap_addr(d, dma_addr),
+				 q->buf_size, PCI_DMA_FROMDEVICE);
 		kfree_skb(d->skb);
 		d->skb = NULL;
 	}
@@ -372,9 +383,8 @@ static void free_rx_bufs(struct pci_dev *pdev, struct sge_fl *q)
 	while (q->credits--) {
 		struct rx_sw_desc *d = &q->sdesc[cidx];
 
-		pci_unmap_single(pdev, pci_unmap_addr(d, dma_addr),
-				 q->buf_size, PCI_DMA_FROMDEVICE);
-		clear_rx_desc(q, d);
+
+		clear_rx_desc(pdev, q, d);
 		if (++cidx == q->size)
 			cidx = 0;
 	}
@@ -417,18 +427,39 @@ static inline int add_one_rx_buf(void *va, unsigned int len,
 	return 0;
 }
 
-static int alloc_pg_chunk(struct sge_fl *q, struct rx_sw_desc *sd, gfp_t gfp,
+static inline int add_one_rx_chunk(dma_addr_t mapping, struct rx_desc *d,
+				   unsigned int gen)
+{
+	d->addr_lo = cpu_to_be32(mapping);
+	d->addr_hi = cpu_to_be32((u64) mapping >> 32);
+	wmb();
+	d->len_gen = cpu_to_be32(V_FLD_GEN1(gen));
+	d->gen2 = cpu_to_be32(V_FLD_GEN2(gen));
+	return 0;
+}
+
+static int alloc_pg_chunk(struct adapter *adapter, struct sge_fl *q,
+			  struct rx_sw_desc *sd, gfp_t gfp,
 			  unsigned int order)
 {
 	if (!q->pg_chunk.page) {
+		dma_addr_t mapping;
+
 		q->pg_chunk.page = alloc_pages(gfp, order);
 		if (unlikely(!q->pg_chunk.page))
 			return -ENOMEM;
 		q->pg_chunk.va = page_address(q->pg_chunk.page);
+		q->pg_chunk.p_cnt = q->pg_chunk.va + (PAGE_SIZE << order) -
+				    SGE_PG_RSVD;
 		q->pg_chunk.offset = 0;
+		mapping = pci_map_page(adapter->pdev, q->pg_chunk.page,
+				       0, q->alloc_size, PCI_DMA_FROMDEVICE);
+		pci_unmap_addr_set(&q->pg_chunk, mapping, mapping);
 	}
 	sd->pg_chunk = q->pg_chunk;
 
+	prefetch(sd->pg_chunk.p_cnt);
+
 	q->pg_chunk.offset += q->buf_size;
 	if (q->pg_chunk.offset == (PAGE_SIZE << order))
 		q->pg_chunk.page = NULL;
@@ -436,6 +467,12 @@ static int alloc_pg_chunk(struct sge_fl *q, struct rx_sw_desc *sd, gfp_t gfp,
 		q->pg_chunk.va += q->buf_size;
 		get_page(q->pg_chunk.page);
 	}
+
+	if (sd->pg_chunk.offset == 0)
+		*sd->pg_chunk.p_cnt = 1;
+	else
+		*sd->pg_chunk.p_cnt += 1;
+
 	return 0;
 }
 
@@ -460,35 +497,43 @@ static inline void ring_fl_db(struct adapter *adap, struct sge_fl *q)
  */
 static int refill_fl(struct adapter *adap, struct sge_fl *q, int n, gfp_t gfp)
 {
-	void *buf_start;
 	struct rx_sw_desc *sd = &q->sdesc[q->pidx];
 	struct rx_desc *d = &q->desc[q->pidx];
 	unsigned int count = 0;
 
 	while (n--) {
+		dma_addr_t mapping;
 		int err;
 
 		if (q->use_pages) {
-			if (unlikely(alloc_pg_chunk(q, sd, gfp, q->order))) {
+			if (unlikely(alloc_pg_chunk(adap, q, sd, gfp,
+						    q->order))) {
 nomem:				q->alloc_failed++;
 				break;
 			}
-			buf_start = sd->pg_chunk.va;
+			mapping = pci_unmap_addr(&sd->pg_chunk, mapping) +
+						 sd->pg_chunk.offset;
+			pci_unmap_addr_set(sd, dma_addr, mapping);
+
+			add_one_rx_chunk(mapping, d, q->gen);
+			pci_dma_sync_single_for_device(adap->pdev, mapping,
+						q->buf_size - SGE_PG_RSVD,
+						PCI_DMA_FROMDEVICE);
 		} else {
-			struct sk_buff *skb = alloc_skb(q->buf_size, gfp);
+			void *buf_start;
 
+			struct sk_buff *skb = alloc_skb(q->buf_size, gfp);
 			if (!skb)
 				goto nomem;
 
 			sd->skb = skb;
 			buf_start = skb->data;
-		}
-
-		err = add_one_rx_buf(buf_start, q->buf_size, d, sd, q->gen,
-				     adap->pdev);
-		if (unlikely(err)) {
-			clear_rx_desc(q, sd);
-			break;
+			err = add_one_rx_buf(buf_start, q->buf_size, d, sd,
+					     q->gen, adap->pdev);
+			if (unlikely(err)) {
+				clear_rx_desc(adap->pdev, q, sd);
+				break;
+			}
 		}
 
 		d++;
@@ -795,19 +840,19 @@ static struct sk_buff *get_packet_pg(struct adapter *adap, struct sge_fl *fl,
 	struct sk_buff *newskb, *skb;
 	struct rx_sw_desc *sd = &fl->sdesc[fl->cidx];
 
-	newskb = skb = q->pg_skb;
+	dma_addr_t dma_addr = pci_unmap_addr(sd, dma_addr);
 
+	newskb = skb = q->pg_skb;
 	if (!skb && (len <= SGE_RX_COPY_THRES)) {
 		newskb = alloc_skb(len, GFP_ATOMIC);
 		if (likely(newskb != NULL)) {
 			__skb_put(newskb, len);
-			pci_dma_sync_single_for_cpu(adap->pdev,
-					    pci_unmap_addr(sd, dma_addr), len,
+			pci_dma_sync_single_for_cpu(adap->pdev, dma_addr, len,
 					    PCI_DMA_FROMDEVICE);
 			memcpy(newskb->data, sd->pg_chunk.va, len);
-			pci_dma_sync_single_for_device(adap->pdev,
-					    pci_unmap_addr(sd, dma_addr), len,
-					    PCI_DMA_FROMDEVICE);
+			pci_dma_sync_single_for_device(adap->pdev, dma_addr,
+						       len,
+						       PCI_DMA_FROMDEVICE);
 		} else if (!drop_thres)
 			return NULL;
 recycle:
@@ -820,16 +865,25 @@ recycle:
 	if (unlikely(q->rx_recycle_buf || (!skb && fl->credits <= drop_thres)))
 		goto recycle;
 
+	prefetch(sd->pg_chunk.p_cnt);
+
 	if (!skb)
 		newskb = alloc_skb(SGE_RX_PULL_LEN, GFP_ATOMIC);
+
 	if (unlikely(!newskb)) {
 		if (!drop_thres)
 			return NULL;
 		goto recycle;
 	}
 
-	pci_unmap_single(adap->pdev, pci_unmap_addr(sd, dma_addr),
-			 fl->buf_size, PCI_DMA_FROMDEVICE);
+	pci_dma_sync_single_for_cpu(adap->pdev, dma_addr, len,
+				    PCI_DMA_FROMDEVICE);
+	(*sd->pg_chunk.p_cnt)--;
+	if (!*sd->pg_chunk.p_cnt)
+		pci_unmap_page(adap->pdev,
+			       pci_unmap_addr(&sd->pg_chunk, mapping),
+			       fl->alloc_size,
+			       PCI_DMA_FROMDEVICE);
 	if (!skb) {
 		__skb_put(newskb, SGE_RX_PULL_LEN);
 		memcpy(newskb->data, sd->pg_chunk.va, SGE_RX_PULL_LEN);
@@ -1958,8 +2012,8 @@ static void rx_eth(struct adapter *adap, struct sge_rspq *rq,
 	skb_pull(skb, sizeof(*p) + pad);
 	skb->protocol = eth_type_trans(skb, adap->port[p->iff]);
 	pi = netdev_priv(skb->dev);
-	if ((pi->rx_offload & T3_RX_CSUM) && p->csum_valid && p->csum == htons(0xffff) &&
-	    !p->fragment) {
+	if ((pi->rx_offload & T3_RX_CSUM) && p->csum_valid &&
+	    p->csum == htons(0xffff) && !p->fragment) {
 		qs->port_stats[SGE_PSTAT_RX_CSUM_GOOD]++;
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	} else
@@ -2034,10 +2088,19 @@ static void lro_add_page(struct adapter *adap, struct sge_qset *qs,
 	fl->credits--;
 
 	len -= offset;
-	pci_unmap_single(adap->pdev, pci_unmap_addr(sd, dma_addr),
-			 fl->buf_size, PCI_DMA_FROMDEVICE);
+	pci_dma_sync_single_for_cpu(adap->pdev,
+				    pci_unmap_addr(sd, dma_addr),
+				    fl->buf_size - SGE_PG_RSVD,
+				    PCI_DMA_FROMDEVICE);
+
+	(*sd->pg_chunk.p_cnt)--;
+	if (!*sd->pg_chunk.p_cnt)
+		pci_unmap_page(adap->pdev,
+			       pci_unmap_addr(&sd->pg_chunk, mapping),
+			       fl->alloc_size,
+			       PCI_DMA_FROMDEVICE);
 
-	prefetch(&qs->lro_frag_tbl);
+	prefetch(qs->lro_va);
 
 	rx_frag += nr_frags;
 	rx_frag->page = sd->pg_chunk.page;
@@ -2047,6 +2110,7 @@ static void lro_add_page(struct adapter *adap, struct sge_qset *qs,
 	qs->lro_frag_tbl.nr_frags++;
 	qs->lro_frag_tbl.len = frag_len;
 
+
 	if (!complete)
 		return;
 
@@ -2236,6 +2300,8 @@ no_mem:
 			if (fl->use_pages) {
 				void *addr = fl->sdesc[fl->cidx].pg_chunk.va;
 
+				prefetch(&qs->lro_frag_tbl);
+
 				prefetch(addr);
 #if L1_CACHE_BYTES < 128
 				prefetch(addr + L1_CACHE_BYTES);
@@ -2972,21 +3038,23 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 	q->fl[1].use_pages = FL1_PG_CHUNK_SIZE > 0;
 	q->fl[0].order = FL0_PG_ORDER;
 	q->fl[1].order = FL1_PG_ORDER;
+	q->fl[0].alloc_size = FL0_PG_ALLOC_SIZE;
+	q->fl[1].alloc_size = FL1_PG_ALLOC_SIZE;
 
 	spin_lock_irq(&adapter->sge.reg_lock);
 
 	/* FL threshold comparison uses < */
 	ret = t3_sge_init_rspcntxt(adapter, q->rspq.cntxt_id, irq_vec_idx,
 				   q->rspq.phys_addr, q->rspq.size,
-				   q->fl[0].buf_size, 1, 0);
+				   q->fl[0].buf_size - SGE_PG_RSVD, 1, 0);
 	if (ret)
 		goto err_unlock;
 
 	for (i = 0; i < SGE_RXQ_PER_SET; ++i) {
 		ret = t3_sge_init_flcntxt(adapter, q->fl[i].cntxt_id, 0,
 					  q->fl[i].phys_addr, q->fl[i].size,
-					  q->fl[i].buf_size, p->cong_thres, 1,
-					  0);
+					  q->fl[i].buf_size - SGE_PG_RSVD,
+					  p->cong_thres, 1, 0);
 		if (ret)
 			goto err_unlock;
 	}

