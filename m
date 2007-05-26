From: divy@chelsio.com
Subject: [PATCH 1/7] cxgb3 - Fix SGE page management
Date: Sat, 26 May 2007 15:59:47 -0700
Message-ID: <20070526225947.12097.82363.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:12158 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204AbXEZW7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 May 2007 18:59:51 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Streamline page management on RX.
Fix dma mappings.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/adapter.h |   38 ++--
 drivers/net/cxgb3/sge.c     |  425 ++++++++++++++++++++++---------------------
 2 files changed, 233 insertions(+), 230 deletions(-)

diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index 80c3d8f..ab72563 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -71,27 +71,29 @@ enum {				/* adapter flags */
 	QUEUES_BOUND = (1 << 3),
 };
 
+struct fl_pg_chunk {
+	struct page *page;
+	void *va;
+	unsigned int offset;
+};
+
 struct rx_desc;
 struct rx_sw_desc;
 
-struct sge_fl_page {
-	struct skb_frag_struct frag;
-	unsigned char *va;
-};
-
-struct sge_fl {			/* SGE per free-buffer list state */
-	unsigned int buf_size;	/* size of each Rx buffer */
-	unsigned int credits;	/* # of available Rx buffers */
-	unsigned int size;	/* capacity of free list */
-	unsigned int cidx;	/* consumer index */
-	unsigned int pidx;	/* producer index */
-	unsigned int gen;	/* free list generation */
-	unsigned int cntxt_id;	/* SGE context id for the free list */
-	struct sge_fl_page page;
-	struct rx_desc *desc;	/* address of HW Rx descriptor ring */
-	struct rx_sw_desc *sdesc;	/* address of SW Rx descriptor ring */
-	dma_addr_t phys_addr;	/* physical address of HW ring start */
-	unsigned long empty;	/* # of times queue ran out of buffers */
+struct sge_fl {                     /* SGE per free-buffer list state */
+	unsigned int buf_size;      /* size of each Rx buffer */
+	unsigned int credits;       /* # of available Rx buffers */
+	unsigned int size;          /* capacity of free list */
+	unsigned int cidx;          /* consumer index */
+	unsigned int pidx;          /* producer index */
+	unsigned int gen;           /* free list generation */
+	struct fl_pg_chunk pg_chunk;/* page chunk cache */
+	unsigned int use_pages;     /* whether FL uses pages or sk_buffs */
+	struct rx_desc *desc;       /* address of HW Rx descriptor ring */
+	struct rx_sw_desc *sdesc;   /* address of SW Rx descriptor ring */
+	dma_addr_t   phys_addr;     /* physical address of HW ring start */
+	unsigned int cntxt_id;      /* SGE context id for the free list */
+	unsigned long empty;        /* # of times queue ran out of buffers */
 	unsigned long alloc_failed; /* # of times buffer allocation failed */
 };
 
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 3666586..8dd5b1e 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -46,23 +46,16 @@
 
 #define SGE_RX_SM_BUF_SIZE 1536
 
-/*
- * If USE_RX_PAGE is defined, the small freelist populated with (partial)
- * pages instead of skbs. Pages are carved up into RX_PAGE_SIZE chunks (must
- * be a multiple of the host page size).
- */
-#define USE_RX_PAGE
-#define RX_PAGE_SIZE 2048
-
-/*
- * skb freelist packets are copied into a new skb (and the freelist one is 
- * reused) if their len is <= 
- */
 #define SGE_RX_COPY_THRES  256
+#define SGE_RX_PULL_LEN    128
 
 /*
- * Minimum number of freelist entries before we start dropping TUNNEL frames.
+ * Page chunk size for FL0 buffers if FL0 is to be populated with page chunks.
+ * It must be a divisor of PAGE_SIZE.  If set to 0 FL0 will use sk_buffs
+ * directly.
  */
+#define FL0_PG_CHUNK_SIZE  2048
+
 #define SGE_RX_DROP_THRES 16
 
 /*
@@ -100,12 +93,12 @@ struct tx_sw_desc {		/* SW state per Tx
 	struct sk_buff *skb;
 };
 
-struct rx_sw_desc {		/* SW state per Rx descriptor */
+struct rx_sw_desc {                /* SW state per Rx descriptor */
 	union {
 		struct sk_buff *skb;
-		struct sge_fl_page page;
-	} t;
-	 DECLARE_PCI_UNMAP_ADDR(dma_addr);
+		struct fl_pg_chunk pg_chunk;
+	};
+	DECLARE_PCI_UNMAP_ADDR(dma_addr);
 };
 
 struct rsp_desc {		/* response queue descriptor */
@@ -351,27 +344,26 @@ static void free_rx_bufs(struct pci_dev
 
 		pci_unmap_single(pdev, pci_unmap_addr(d, dma_addr),
 				 q->buf_size, PCI_DMA_FROMDEVICE);
-
-		if (q->buf_size != RX_PAGE_SIZE) {
-			kfree_skb(d->t.skb);
-			d->t.skb = NULL;
+		if (q->use_pages) {
+			put_page(d->pg_chunk.page);
+			d->pg_chunk.page = NULL;
 		} else {
-			if (d->t.page.frag.page)
-				put_page(d->t.page.frag.page);
-			d->t.page.frag.page = NULL;
+			kfree_skb(d->skb);
+			d->skb = NULL;
 		}
 		if (++cidx == q->size)
 			cidx = 0;
 	}
 
-	if (q->page.frag.page)
-		put_page(q->page.frag.page);
-	q->page.frag.page = NULL;
+	if (q->pg_chunk.page) {
+		__free_page(q->pg_chunk.page);
+		q->pg_chunk.page = NULL;
+	}
 }
 
 /**
  *	add_one_rx_buf - add a packet buffer to a free-buffer list
- *	@va: va of the buffer to add
+ *	@va:  buffer start VA
  *	@len: the buffer length
  *	@d: the HW Rx descriptor to write
  *	@sd: the SW Rx descriptor to write
@@ -381,7 +373,7 @@ static void free_rx_bufs(struct pci_dev
  *	Add a buffer of the given length to the supplied HW and SW Rx
  *	descriptors.
  */
-static inline void add_one_rx_buf(unsigned char *va, unsigned int len,
+static inline void add_one_rx_buf(void *va, unsigned int len,
 				  struct rx_desc *d, struct rx_sw_desc *sd,
 				  unsigned int gen, struct pci_dev *pdev)
 {
@@ -397,6 +389,27 @@ static inline void add_one_rx_buf(unsign
 	d->gen2 = cpu_to_be32(V_FLD_GEN2(gen));
 }
 
+static int alloc_pg_chunk(struct sge_fl *q, struct rx_sw_desc *sd, gfp_t gfp)
+{
+	if (!q->pg_chunk.page) {
+		q->pg_chunk.page = alloc_page(gfp);
+		if (unlikely(!q->pg_chunk.page))
+			return -ENOMEM;
+		q->pg_chunk.va = page_address(q->pg_chunk.page);
+		q->pg_chunk.offset = 0;
+	}
+	sd->pg_chunk = q->pg_chunk;
+
+	q->pg_chunk.offset += q->buf_size;
+	if (q->pg_chunk.offset == PAGE_SIZE)
+		q->pg_chunk.page = NULL;
+	else {
+		q->pg_chunk.va += q->buf_size;
+		get_page(q->pg_chunk.page);
+	}
+	return 0;
+}
+
 /**
  *	refill_fl - refill an SGE free-buffer list
  *	@adapter: the adapter
@@ -410,49 +423,29 @@ static inline void add_one_rx_buf(unsign
  */
 static void refill_fl(struct adapter *adap, struct sge_fl *q, int n, gfp_t gfp)
 {
+	void *buf_start;
 	struct rx_sw_desc *sd = &q->sdesc[q->pidx];
 	struct rx_desc *d = &q->desc[q->pidx];
-	struct sge_fl_page *p = &q->page;
 
 	while (n--) {
-		unsigned char *va;
-
-		if (unlikely(q->buf_size != RX_PAGE_SIZE)) {
-			struct sk_buff *skb = alloc_skb(q->buf_size, gfp);
-
-			if (!skb) {
-				q->alloc_failed++;
+		if (q->use_pages) {
+			if (unlikely(alloc_pg_chunk(q, sd, gfp))) {
+nomem:				q->alloc_failed++;
 				break;
 			}
-			va = skb->data;
-			sd->t.skb = skb;
+			buf_start = sd->pg_chunk.va;
 		} else {
-			if (!p->frag.page) {
-				p->frag.page = alloc_pages(gfp, 0);
-				if (unlikely(!p->frag.page)) {
-					q->alloc_failed++;
-					break;
-				} else {
-					p->frag.size = RX_PAGE_SIZE;
-					p->frag.page_offset = 0;
-					p->va = page_address(p->frag.page);
-				}
-			}
+			struct sk_buff *skb = alloc_skb(q->buf_size, gfp);
 
-			memcpy(&sd->t, p, sizeof(*p));
-			va = p->va;
+			if (!skb)
+				goto nomem;
 
-			p->frag.page_offset += RX_PAGE_SIZE;
-			BUG_ON(p->frag.page_offset > PAGE_SIZE);
-			p->va += RX_PAGE_SIZE;
-			if (p->frag.page_offset == PAGE_SIZE)
-				p->frag.page = NULL;
-			else
-				get_page(p->frag.page);
+			sd->skb = skb;
+			buf_start = skb->data;
 		}
 
-		add_one_rx_buf(va, q->buf_size, d, sd, q->gen, adap->pdev);
-
+		add_one_rx_buf(buf_start, q->buf_size, d, sd, q->gen,
+			       adap->pdev);
 		d++;
 		sd++;
 		if (++q->pidx == q->size) {
@@ -487,7 +480,7 @@ static void recycle_rx_buf(struct adapte
 	struct rx_desc *from = &q->desc[idx];
 	struct rx_desc *to = &q->desc[q->pidx];
 
-	memcpy(&q->sdesc[q->pidx], &q->sdesc[idx], sizeof(struct rx_sw_desc));
+	q->sdesc[q->pidx] = q->sdesc[idx];
 	to->addr_lo = from->addr_lo;	/* already big endian */
 	to->addr_hi = from->addr_hi;	/* likewise */
 	wmb();
@@ -650,6 +643,132 @@ static inline unsigned int flits_to_desc
 }
 
 /**
+ *	get_packet - return the next ingress packet buffer from a free list
+ *	@adap: the adapter that received the packet
+ *	@fl: the SGE free list holding the packet
+ *	@len: the packet length including any SGE padding
+ *	@drop_thres: # of remaining buffers before we start dropping packets
+ *
+ *	Get the next packet from a free list and complete setup of the
+ *	sk_buff.  If the packet is small we make a copy and recycle the
+ *	original buffer, otherwise we use the original buffer itself.  If a
+ *	positive drop threshold is supplied packets are dropped and their
+ *	buffers recycled if (a) the number of remaining buffers is under the
+ *	threshold and the packet is too big to copy, or (b) the packet should
+ *	be copied but there is no memory for the copy.
+ */
+static struct sk_buff *get_packet(struct adapter *adap, struct sge_fl *fl,
+				  unsigned int len, unsigned int drop_thres)
+{
+	struct sk_buff *skb = NULL;
+	struct rx_sw_desc *sd = &fl->sdesc[fl->cidx];
+
+	prefetch(sd->skb->data);
+	fl->credits--;
+
+	if (len <= SGE_RX_COPY_THRES) {
+		skb = alloc_skb(len, GFP_ATOMIC);
+		if (likely(skb != NULL)) {
+			__skb_put(skb, len);
+			pci_dma_sync_single_for_cpu(adap->pdev,
+					    pci_unmap_addr(sd, dma_addr), len,
+					    PCI_DMA_FROMDEVICE);
+			memcpy(skb->data, sd->skb->data, len);
+			pci_dma_sync_single_for_device(adap->pdev,
+					    pci_unmap_addr(sd, dma_addr), len,
+					    PCI_DMA_FROMDEVICE);
+		} else if (!drop_thres)
+			goto use_orig_buf;
+recycle:
+		recycle_rx_buf(adap, fl, fl->cidx);
+		return skb;
+	}
+
+	if (unlikely(fl->credits < drop_thres))
+		goto recycle;
+
+use_orig_buf:
+	pci_unmap_single(adap->pdev, pci_unmap_addr(sd, dma_addr),
+			 fl->buf_size, PCI_DMA_FROMDEVICE);
+	skb = sd->skb;
+	skb_put(skb, len);
+	__refill_fl(adap, fl);
+	return skb;
+}
+
+/**
+ *	get_packet_pg - return the next ingress packet buffer from a free list
+ *	@adap: the adapter that received the packet
+ *	@fl: the SGE free list holding the packet
+ *	@len: the packet length including any SGE padding
+ *	@drop_thres: # of remaining buffers before we start dropping packets
+ *
+ *	Get the next packet from a free list populated with page chunks.
+ *	If the packet is small we make a copy and recycle the original buffer,
+ *	otherwise we attach the original buffer as a page fragment to a fresh
+ *	sk_buff.  If a positive drop threshold is supplied packets are dropped
+ *	and their buffers recycled if (a) the number of remaining buffers is
+ *	under the threshold and the packet is too big to copy, or (b) there's
+ *	no system memory.
+ *
+ * 	Note: this function is similar to @get_packet but deals with Rx buffers
+ * 	that are page chunks rather than sk_buffs.
+ */
+static struct sk_buff *get_packet_pg(struct adapter *adap, struct sge_fl *fl,
+				     unsigned int len, unsigned int drop_thres)
+{
+	struct sk_buff *skb = NULL;
+	struct rx_sw_desc *sd = &fl->sdesc[fl->cidx];
+
+	if (len <= SGE_RX_COPY_THRES) {
+		skb = alloc_skb(len, GFP_ATOMIC);
+		if (likely(skb != NULL)) {
+			__skb_put(skb, len);
+			pci_dma_sync_single_for_cpu(adap->pdev,
+					    pci_unmap_addr(sd, dma_addr), len,
+					    PCI_DMA_FROMDEVICE);
+			memcpy(skb->data, sd->pg_chunk.va, len);
+			pci_dma_sync_single_for_device(adap->pdev,
+					    pci_unmap_addr(sd, dma_addr), len,
+					    PCI_DMA_FROMDEVICE);
+		} else if (!drop_thres)
+			return NULL;
+recycle:
+		fl->credits--;
+		recycle_rx_buf(adap, fl, fl->cidx);
+		return skb;
+	}
+
+	if (unlikely(fl->credits <= drop_thres))
+		goto recycle;
+
+	skb = alloc_skb(SGE_RX_PULL_LEN, GFP_ATOMIC);
+	if (unlikely(!skb)) {
+		if (!drop_thres)
+			return NULL;
+		goto recycle;
+	}
+
+	pci_unmap_single(adap->pdev, pci_unmap_addr(sd, dma_addr),
+			 fl->buf_size, PCI_DMA_FROMDEVICE);
+	__skb_put(skb, SGE_RX_PULL_LEN);
+	memcpy(skb->data, sd->pg_chunk.va, SGE_RX_PULL_LEN);
+	skb_fill_page_desc(skb, 0, sd->pg_chunk.page,
+			   sd->pg_chunk.offset + SGE_RX_PULL_LEN,
+			   len - SGE_RX_PULL_LEN);
+	skb->len = len;
+	skb->data_len = len - SGE_RX_PULL_LEN;
+	skb->truesize += skb->data_len;
+
+	fl->credits--;
+	/*
+	 * We do not refill FLs here, we let the caller do it to overlap a
+	 * prefetch.
+	 */
+	return skb;
+}
+
+/**
  *	get_imm_packet - return the next ingress packet buffer from a response
  *	@resp: the response descriptor containing the packet data
  *
@@ -1690,8 +1809,8 @@ static void rx_eth(struct adapter *adap,
 	struct port_info *pi;
 
 	skb_pull(skb, sizeof(*p) + pad);
-	skb->dev->last_rx = jiffies;
 	skb->protocol = eth_type_trans(skb, adap->port[p->iff]);
+	skb->dev->last_rx = jiffies;
 	pi = netdev_priv(skb->dev);
 	if (pi->rx_csum_offload && p->csum_valid && p->csum == 0xffff &&
 	    !p->fragment) {
@@ -1715,85 +1834,6 @@ static void rx_eth(struct adapter *adap,
 		netif_rx(skb);
 }
 
-#define SKB_DATA_SIZE 128
-
-static void skb_data_init(struct sk_buff *skb, struct sge_fl_page *p,
-			  unsigned int len)
-{
-	skb->len = len;
-	if (len <= SKB_DATA_SIZE) {
-		skb_copy_to_linear_data(skb, p->va, len);
-		skb->tail += len;
-		put_page(p->frag.page);
-	} else {
-		skb_copy_to_linear_data(skb, p->va, SKB_DATA_SIZE);
-		skb_shinfo(skb)->frags[0].page = p->frag.page;
-		skb_shinfo(skb)->frags[0].page_offset =
-		    p->frag.page_offset + SKB_DATA_SIZE;
-		skb_shinfo(skb)->frags[0].size = len - SKB_DATA_SIZE;
-		skb_shinfo(skb)->nr_frags = 1;
-		skb->data_len = len - SKB_DATA_SIZE;
-		skb->tail += SKB_DATA_SIZE;
-		skb->truesize += skb->data_len;
-	}
-}
-
-/**
-*      get_packet - return the next ingress packet buffer from a free list
-*      @adap: the adapter that received the packet
-*      @fl: the SGE free list holding the packet
-*      @len: the packet length including any SGE padding
-*      @drop_thres: # of remaining buffers before we start dropping packets
-*
-*      Get the next packet from a free list and complete setup of the
-*      sk_buff.  If the packet is small we make a copy and recycle the
-*      original buffer, otherwise we use the original buffer itself.  If a
-*      positive drop threshold is supplied packets are dropped and their
-*      buffers recycled if (a) the number of remaining buffers is under the
-*      threshold and the packet is too big to copy, or (b) the packet should
-*      be copied but there is no memory for the copy.
-*/
-static struct sk_buff *get_packet(struct adapter *adap, struct sge_fl *fl,
-				  unsigned int len, unsigned int drop_thres)
-{
-	struct sk_buff *skb = NULL;
-	struct rx_sw_desc *sd = &fl->sdesc[fl->cidx];
-
-	prefetch(sd->t.skb->data);
-
-	if (len <= SGE_RX_COPY_THRES) {
-		skb = alloc_skb(len, GFP_ATOMIC);
-		if (likely(skb != NULL)) {
-			struct rx_desc *d = &fl->desc[fl->cidx];
-			dma_addr_t mapping =
-			    (dma_addr_t)((u64) be32_to_cpu(d->addr_hi) << 32 |
-					 be32_to_cpu(d->addr_lo));
-
-			__skb_put(skb, len);
-			pci_dma_sync_single_for_cpu(adap->pdev, mapping, len,
-						    PCI_DMA_FROMDEVICE);
-			skb_copy_from_linear_data(sd->t.skb, skb->data, len);
-			pci_dma_sync_single_for_device(adap->pdev, mapping, len,
-						       PCI_DMA_FROMDEVICE);
-		} else if (!drop_thres)
-			goto use_orig_buf;
-recycle:
-		recycle_rx_buf(adap, fl, fl->cidx);
-		return skb;
-	}
-
-	if (unlikely(fl->credits < drop_thres))
-		goto recycle;
-
-use_orig_buf:
-	pci_unmap_single(adap->pdev, pci_unmap_addr(sd, dma_addr),
-			 fl->buf_size, PCI_DMA_FROMDEVICE);
-	skb = sd->t.skb;
-	skb_put(skb, len);
-	__refill_fl(adap, fl);
-	return skb;
-}
-
 /**
  *	handle_rsp_cntrl_info - handles control information in a response
  *	@qs: the queue set corresponding to the response
@@ -1935,7 +1975,7 @@ static int process_responses(struct adap
 		} else if (flags & F_RSPD_IMM_DATA_VALID) {
 			skb = get_imm_packet(r);
 			if (unlikely(!skb)) {
-			      no_mem:
+no_mem:
 				q->next_holdoff = NOMEM_INTR_DELAY;
 				q->nomem++;
 				/* consume one credit since we tried */
@@ -1945,53 +1985,29 @@ static int process_responses(struct adap
 			q->imm_data++;
 			ethpad = 0;
 		} else if ((len = ntohl(r->len_cq)) != 0) {
-			struct sge_fl *fl =
-			    (len & F_RSPD_FLQ) ? &qs->fl[1] : &qs->fl[0];
+			struct sge_fl *fl;
 
-			if (fl->buf_size == RX_PAGE_SIZE) {
-				struct rx_sw_desc *sd = &fl->sdesc[fl->cidx];
-				struct sge_fl_page *p = &sd->t.page;
-
-				prefetch(p->va);
-				prefetch(p->va + L1_CACHE_BYTES);
+			fl = (len & F_RSPD_FLQ) ? &qs->fl[1] : &qs->fl[0];
+			if (fl->use_pages) {
+				void *addr = fl->sdesc[fl->cidx].pg_chunk.va;
 
+				prefetch(addr);
+#if L1_CACHE_BYTES < 128
+				prefetch(addr + L1_CACHE_BYTES);
+#endif
 				__refill_fl(adap, fl);
 
-				pci_unmap_single(adap->pdev,
-						 pci_unmap_addr(sd, dma_addr),
-						 fl->buf_size,
-						 PCI_DMA_FROMDEVICE);
-
-				if (eth) {
-					if (unlikely(fl->credits <
-						     SGE_RX_DROP_THRES))
-						goto eth_recycle;
-
-					skb = alloc_skb(SKB_DATA_SIZE,
-							GFP_ATOMIC);
-					if (unlikely(!skb)) {
-eth_recycle:
-						q->rx_drops++;
-						recycle_rx_buf(adap, fl,
-							       fl->cidx);
-						goto eth_done;
-					}
-				} else {
-					skb = alloc_skb(SKB_DATA_SIZE,
-							GFP_ATOMIC);
-					if (unlikely(!skb))
-						goto no_mem;
-				}
-
-				skb_data_init(skb, p, G_RSPD_LEN(len));
-eth_done:
-				fl->credits--;
-				q->eth_pkts++;
-			} else {
-				fl->credits--;
+				skb = get_packet_pg(adap, fl, G_RSPD_LEN(len),
+						 eth ? SGE_RX_DROP_THRES : 0);
+			} else
 				skb = get_packet(adap, fl, G_RSPD_LEN(len),
 						 eth ? SGE_RX_DROP_THRES : 0);
-			}
+			if (unlikely(!skb)) {
+				if (!eth)
+					goto no_mem;
+				q->rx_drops++;
+			} else if (unlikely(r->rss_hdr.opcode == CPL_TRACE_PKT))
+				__skb_pull(skb, 2);
 
 			if (++fl->cidx == fl->size)
 				fl->cidx = 0;
@@ -2016,20 +2032,15 @@ eth_done:
 			q->credits = 0;
 		}
 
-		if (skb) {
-			/* Preserve the RSS info in csum & priority */
-			skb->csum = rss_hi;
-			skb->priority = rss_lo;
-
+		if (likely(skb != NULL)) {
 			if (eth)
 				rx_eth(adap, q, skb, ethpad);
 			else {
-				if (unlikely(r->rss_hdr.opcode ==
-					     CPL_TRACE_PKT))
-					__skb_pull(skb, ethpad);
-
-				ngathered = rx_offload(&adap->tdev, q,
-						       skb, offload_skbs,
+				/* Preserve the RSS info in csum & priority */
+				skb->csum = rss_hi;
+				skb->priority = rss_lo;
+				ngathered = rx_offload(&adap->tdev, q, skb,
+						       offload_skbs,
 						       ngathered);
 			}
 		}
@@ -2636,25 +2647,15 @@ int t3_sge_alloc_qset(struct adapter *ad
 	q->txq[TXQ_ETH].stop_thres = nports *
 	    flits_to_desc(sgl_len(MAX_SKB_FRAGS + 1) + 3);
 
-	if (!is_offload(adapter)) {
-#ifdef USE_RX_PAGE
-		q->fl[0].buf_size = RX_PAGE_SIZE;
+#if FL0_PG_CHUNK_SIZE > 0
+	q->fl[0].buf_size = FL0_PG_CHUNK_SIZE;
 #else
-		q->fl[0].buf_size = SGE_RX_SM_BUF_SIZE + 2 +
-		    sizeof(struct cpl_rx_pkt);
+	q->fl[0].buf_size = SGE_RX_SM_BUF_SIZE + sizeof(struct cpl_rx_data);
 #endif
-		q->fl[1].buf_size = MAX_FRAME_SIZE + 2 +
-		    sizeof(struct cpl_rx_pkt);
-	} else {
-#ifdef USE_RX_PAGE
-		q->fl[0].buf_size = RX_PAGE_SIZE;
-#else
-		q->fl[0].buf_size = SGE_RX_SM_BUF_SIZE +
-		    sizeof(struct cpl_rx_data);
-#endif
-		q->fl[1].buf_size = (16 * 1024) -
-		    SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
-	}
+	q->fl[0].use_pages = FL0_PG_CHUNK_SIZE > 0;
+	q->fl[1].buf_size = is_offload(adapter) ?
+		(16 * 1024) - SKB_DATA_ALIGN(sizeof(struct skb_shared_info)) :
+		MAX_FRAME_SIZE + 2 + sizeof(struct cpl_rx_pkt);
 
 	spin_lock(&adapter->sge.reg_lock);
 
