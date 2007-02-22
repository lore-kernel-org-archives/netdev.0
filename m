From: divy@chelsio.com
Subject: [PATCH 6/7] cxgb3 - Feed Rx free list with pages
Date: Thu, 22 Feb 2007 03:59:47 -0800
Message-ID: <20070222115947.10073.57685.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:18517 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945992AbXBVL7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 06:59:51 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Populate Rx free list with pages.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/adapter.h |    9 +
 drivers/net/cxgb3/sge.c     |  322 +++++++++++++++++++++++++++++++------------
 2 files changed, 237 insertions(+), 94 deletions(-)

diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index 01b99b9..80c3d8f 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -74,6 +74,11 @@ enum {				/* adapter flags */
 struct rx_desc;
 struct rx_sw_desc;
 
+struct sge_fl_page {
+	struct skb_frag_struct frag;
+	unsigned char *va;
+};
+
 struct sge_fl {			/* SGE per free-buffer list state */
 	unsigned int buf_size;	/* size of each Rx buffer */
 	unsigned int credits;	/* # of available Rx buffers */
@@ -81,11 +86,13 @@ struct sge_fl {			/* SGE per free-buffer
 	unsigned int cidx;	/* consumer index */
 	unsigned int pidx;	/* producer index */
 	unsigned int gen;	/* free list generation */
+	unsigned int cntxt_id;	/* SGE context id for the free list */
+	struct sge_fl_page page;
 	struct rx_desc *desc;	/* address of HW Rx descriptor ring */
 	struct rx_sw_desc *sdesc;	/* address of SW Rx descriptor ring */
 	dma_addr_t phys_addr;	/* physical address of HW ring start */
-	unsigned int cntxt_id;	/* SGE context id for the free list */
 	unsigned long empty;	/* # of times queue ran out of buffers */
+	unsigned long alloc_failed; /* # of times buffer allocation failed */
 };
 
 /*
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 4ff0ab6..850bcc0 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -45,9 +45,25 @@
 #define USE_GTS 0
 
 #define SGE_RX_SM_BUF_SIZE 1536
+
+/*
+ * If USE_RX_PAGE is defined, the small freelist populated with (partial)
+ * pages instead of skbs. Pages are carved up into RX_PAGE_SIZE chunks (must
+ * be a multiple of the host page size).
+ */
+#define USE_RX_PAGE
+#define RX_PAGE_SIZE 2048
+
+/*
+ * skb freelist packets are copied into a new skb (and the freelist one is 
+ * reused) if their len is <= 
+ */
 #define SGE_RX_COPY_THRES  256
 
-# define SGE_RX_DROP_THRES 16
+/*
+ * Minimum number of freelist entries before we start dropping TUNNEL frames.
+ */
+#define SGE_RX_DROP_THRES 16
 
 /*
  * Period of the Tx buffer reclaim timer.  This timer does not need to run
@@ -85,7 +101,10 @@ struct tx_sw_desc {		/* SW state per Tx
 };
 
 struct rx_sw_desc {		/* SW state per Rx descriptor */
-	struct sk_buff *skb;
+	union {
+		struct sk_buff *skb;
+		struct sge_fl_page page;
+	} t;
 	 DECLARE_PCI_UNMAP_ADDR(dma_addr);
 };
 
@@ -332,16 +351,27 @@ static void free_rx_bufs(struct pci_dev
 
 		pci_unmap_single(pdev, pci_unmap_addr(d, dma_addr),
 				 q->buf_size, PCI_DMA_FROMDEVICE);
-		kfree_skb(d->skb);
-		d->skb = NULL;
+
+		if (q->buf_size != RX_PAGE_SIZE) {
+			kfree_skb(d->t.skb);
+			d->t.skb = NULL;
+		} else {
+			if (d->t.page.frag.page)
+				put_page(d->t.page.frag.page);
+			d->t.page.frag.page = NULL;
+		}
 		if (++cidx == q->size)
 			cidx = 0;
 	}
+
+	if (q->page.frag.page)
+		put_page(q->page.frag.page);
+	q->page.frag.page = NULL;
 }
 
 /**
  *	add_one_rx_buf - add a packet buffer to a free-buffer list
- *	@skb: the buffer to add
+ *	@va: va of the buffer to add
  *	@len: the buffer length
  *	@d: the HW Rx descriptor to write
  *	@sd: the SW Rx descriptor to write
@@ -351,14 +381,13 @@ static void free_rx_bufs(struct pci_dev
  *	Add a buffer of the given length to the supplied HW and SW Rx
  *	descriptors.
  */
-static inline void add_one_rx_buf(struct sk_buff *skb, unsigned int len,
+static inline void add_one_rx_buf(unsigned char *va, unsigned int len,
 				  struct rx_desc *d, struct rx_sw_desc *sd,
 				  unsigned int gen, struct pci_dev *pdev)
 {
 	dma_addr_t mapping;
 
-	sd->skb = skb;
-	mapping = pci_map_single(pdev, skb->data, len, PCI_DMA_FROMDEVICE);
+	mapping = pci_map_single(pdev, va, len, PCI_DMA_FROMDEVICE);
 	pci_unmap_addr_set(sd, dma_addr, mapping);
 
 	d->addr_lo = cpu_to_be32(mapping);
@@ -383,14 +412,47 @@ static void refill_fl(struct adapter *ad
 {
 	struct rx_sw_desc *sd = &q->sdesc[q->pidx];
 	struct rx_desc *d = &q->desc[q->pidx];
+	struct sge_fl_page *p = &q->page;
 
 	while (n--) {
-		struct sk_buff *skb = alloc_skb(q->buf_size, gfp);
+		unsigned char *va;
 
-		if (!skb)
-			break;
+		if (unlikely(q->buf_size != RX_PAGE_SIZE)) {
+			struct sk_buff *skb = alloc_skb(q->buf_size, gfp);
+
+			if (!skb) {
+				q->alloc_failed++;
+				break;
+			}
+			va = skb->data;
+			sd->t.skb = skb;
+		} else {
+			if (!p->frag.page) {
+				p->frag.page = alloc_pages(gfp, 0);
+				if (unlikely(!p->frag.page)) {
+					q->alloc_failed++;
+					break;
+				} else {
+					p->frag.size = RX_PAGE_SIZE;
+					p->frag.page_offset = 0;
+					p->va = page_address(p->frag.page);
+				}
+			}
+
+			memcpy(&sd->t, p, sizeof(*p));
+			va = p->va;
+
+			p->frag.page_offset += RX_PAGE_SIZE;
+			BUG_ON(p->frag.page_offset > PAGE_SIZE);
+			p->va += RX_PAGE_SIZE;
+			if (p->frag.page_offset == PAGE_SIZE)
+				p->frag.page = NULL;
+			else
+				get_page(p->frag.page);
+		}
+
+		add_one_rx_buf(va, q->buf_size, d, sd, q->gen, adap->pdev);
 
-		add_one_rx_buf(skb, q->buf_size, d, sd, q->gen, adap->pdev);
 		d++;
 		sd++;
 		if (++q->pidx == q->size) {
@@ -425,9 +487,9 @@ static void recycle_rx_buf(struct adapte
 	struct rx_desc *from = &q->desc[idx];
 	struct rx_desc *to = &q->desc[q->pidx];
 
-	q->sdesc[q->pidx] = q->sdesc[idx];
-	to->addr_lo = from->addr_lo;	/* already big endian */
-	to->addr_hi = from->addr_hi;	/* likewise */
+	memcpy(&q->sdesc[q->pidx], &q->sdesc[idx], sizeof(struct rx_sw_desc));
+	to->addr_lo = from->addr_lo;	// already big endian
+	to->addr_hi = from->addr_hi;	// likewise
 	wmb();
 	to->len_gen = cpu_to_be32(V_FLD_GEN1(q->gen));
 	to->gen2 = cpu_to_be32(V_FLD_GEN2(q->gen));
@@ -458,7 +520,7 @@ static void recycle_rx_buf(struct adapte
  *	of the SW ring.
  */
 static void *alloc_ring(struct pci_dev *pdev, size_t nelem, size_t elem_size,
-			size_t sw_size, dma_addr_t *phys, void *metadata)
+			size_t sw_size, dma_addr_t * phys, void *metadata)
 {
 	size_t len = nelem * elem_size;
 	void *s = NULL;
@@ -588,61 +650,6 @@ static inline unsigned int flits_to_desc
 }
 
 /**
- *	get_packet - return the next ingress packet buffer from a free list
- *	@adap: the adapter that received the packet
- *	@fl: the SGE free list holding the packet
- *	@len: the packet length including any SGE padding
- *	@drop_thres: # of remaining buffers before we start dropping packets
- *
- *	Get the next packet from a free list and complete setup of the
- *	sk_buff.  If the packet is small we make a copy and recycle the
- *	original buffer, otherwise we use the original buffer itself.  If a
- *	positive drop threshold is supplied packets are dropped and their
- *	buffers recycled if (a) the number of remaining buffers is under the
- *	threshold and the packet is too big to copy, or (b) the packet should
- *	be copied but there is no memory for the copy.
- */
-static struct sk_buff *get_packet(struct adapter *adap, struct sge_fl *fl,
-				  unsigned int len, unsigned int drop_thres)
-{
-	struct sk_buff *skb = NULL;
-	struct rx_sw_desc *sd = &fl->sdesc[fl->cidx];
-
-	prefetch(sd->skb->data);
-
-	if (len <= SGE_RX_COPY_THRES) {
-		skb = alloc_skb(len, GFP_ATOMIC);
-		if (likely(skb != NULL)) {
-			__skb_put(skb, len);
-			pci_dma_sync_single_for_cpu(adap->pdev,
-						    pci_unmap_addr(sd,
-								   dma_addr),
-						    len, PCI_DMA_FROMDEVICE);
-			memcpy(skb->data, sd->skb->data, len);
-			pci_dma_sync_single_for_device(adap->pdev,
-						       pci_unmap_addr(sd,
-								      dma_addr),
-						       len, PCI_DMA_FROMDEVICE);
-		} else if (!drop_thres)
-			goto use_orig_buf;
-	      recycle:
-		recycle_rx_buf(adap, fl, fl->cidx);
-		return skb;
-	}
-
-	if (unlikely(fl->credits < drop_thres))
-		goto recycle;
-
-      use_orig_buf:
-	pci_unmap_single(adap->pdev, pci_unmap_addr(sd, dma_addr),
-			 fl->buf_size, PCI_DMA_FROMDEVICE);
-	skb = sd->skb;
-	skb_put(skb, len);
-	__refill_fl(adap, fl);
-	return skb;
-}
-
-/**
  *	get_imm_packet - return the next ingress packet buffer from a response
  *	@resp: the response descriptor containing the packet data
  *
@@ -1676,7 +1683,6 @@ static void rx_eth(struct adapter *adap,
 	struct cpl_rx_pkt *p = (struct cpl_rx_pkt *)(skb->data + pad);
 	struct port_info *pi;
 
-	rq->eth_pkts++;
 	skb_pull(skb, sizeof(*p) + pad);
 	skb->dev = adap->port[p->iff];
 	skb->dev->last_rx = jiffies;
@@ -1704,6 +1710,85 @@ static void rx_eth(struct adapter *adap,
 		netif_rx(skb);
 }
 
+#define SKB_DATA_SIZE 128
+
+static void skb_data_init(struct sk_buff *skb, struct sge_fl_page *p,
+			  unsigned int len)
+{
+	skb->len = len;
+	if (len <= SKB_DATA_SIZE) {
+		memcpy(skb->data, p->va, len);
+		skb->tail += len;
+		put_page(p->frag.page);
+	} else {
+		memcpy(skb->data, p->va, SKB_DATA_SIZE);
+		skb_shinfo(skb)->frags[0].page = p->frag.page;
+		skb_shinfo(skb)->frags[0].page_offset =
+		    p->frag.page_offset + SKB_DATA_SIZE;
+		skb_shinfo(skb)->frags[0].size = len - SKB_DATA_SIZE;
+		skb_shinfo(skb)->nr_frags = 1;
+		skb->data_len = len - SKB_DATA_SIZE;
+		skb->tail += SKB_DATA_SIZE;
+		skb->truesize += skb->data_len;
+	}
+}
+
+/**
+*      get_packet - return the next ingress packet buffer from a free list
+*      @adap: the adapter that received the packet
+*      @fl: the SGE free list holding the packet
+*      @len: the packet length including any SGE padding
+*      @drop_thres: # of remaining buffers before we start dropping packets
+*
+*      Get the next packet from a free list and complete setup of the
+*      sk_buff.  If the packet is small we make a copy and recycle the
+*      original buffer, otherwise we use the original buffer itself.  If a
+*      positive drop threshold is supplied packets are dropped and their
+*      buffers recycled if (a) the number of remaining buffers is under the
+*      threshold and the packet is too big to copy, or (b) the packet should
+*      be copied but there is no memory for the copy.
+*/
+static struct sk_buff *get_packet(struct adapter *adap, struct sge_fl *fl,
+				  unsigned int len, unsigned int drop_thres)
+{
+	struct sk_buff *skb = NULL;
+	struct rx_sw_desc *sd = &fl->sdesc[fl->cidx];
+
+	prefetch(sd->t.skb->data);
+
+	if (len <= SGE_RX_COPY_THRES) {
+		skb = alloc_skb(len, GFP_ATOMIC);
+		if (likely(skb != NULL)) {
+			struct rx_desc *d = &fl->desc[fl->cidx];
+			dma_addr_t mapping =
+			    (dma_addr_t)((u64) be32_to_cpu(d->addr_hi) << 32 |
+					 be32_to_cpu(d->addr_lo));
+
+			__skb_put(skb, len);
+			pci_dma_sync_single_for_cpu(adap->pdev, mapping, len,
+						    PCI_DMA_FROMDEVICE);
+			memcpy(skb->data, sd->t.skb->data, len);
+			pci_dma_sync_single_for_device(adap->pdev, mapping, len,
+						       PCI_DMA_FROMDEVICE);
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
+	skb = sd->t.skb;
+	skb_put(skb, len);
+	__refill_fl(adap, fl);
+	return skb;
+}
+
 /**
  *	handle_rsp_cntrl_info - handles control information in a response
  *	@qs: the queue set corresponding to the response
@@ -1826,7 +1911,7 @@ static int process_responses(struct adap
 	q->next_holdoff = q->holdoff_tmr;
 
 	while (likely(budget_left && is_new_response(r, q))) {
-		int eth, ethpad = 0;
+		int eth, ethpad = 2;
 		struct sk_buff *skb = NULL;
 		u32 len, flags = ntohl(r->flags);
 		u32 rss_hi = *(const u32 *)r, rss_lo = r->rss_hdr.rss_hash_val;
@@ -1853,18 +1938,56 @@ static int process_responses(struct adap
 				break;
 			}
 			q->imm_data++;
+			ethpad = 0;
 		} else if ((len = ntohl(r->len_cq)) != 0) {
-			struct sge_fl *fl;
+			struct sge_fl *fl =
+			    (len & F_RSPD_FLQ) ? &qs->fl[1] : &qs->fl[0];
+
+			if (fl->buf_size == RX_PAGE_SIZE) {
+				struct rx_sw_desc *sd = &fl->sdesc[fl->cidx];
+				struct sge_fl_page *p = &sd->t.page;
+
+				prefetch(p->va);
+				prefetch(p->va + L1_CACHE_BYTES);
+
+				__refill_fl(adap, fl);
+
+				pci_unmap_single(adap->pdev,
+						 pci_unmap_addr(sd, dma_addr),
+						 fl->buf_size,
+						 PCI_DMA_FROMDEVICE);
+
+				if (eth) {
+					if (unlikely(fl->credits <
+						     SGE_RX_DROP_THRES))
+						goto eth_recycle;
+
+					skb = alloc_skb(SKB_DATA_SIZE,
+							GFP_ATOMIC);
+					if (unlikely(!skb)) {
+eth_recycle:
+						q->rx_drops++;
+						recycle_rx_buf(adap, fl,
+							       fl->cidx);
+						goto eth_done;
+					}
+				} else {
+					skb = alloc_skb(SKB_DATA_SIZE,
+							GFP_ATOMIC);
+					if (unlikely(!skb))
+						goto no_mem;
+				}
+
+				skb_data_init(skb, p, G_RSPD_LEN(len));
+eth_done:
+				fl->credits--;
+				q->eth_pkts++;
+			} else {
+				fl->credits--;
+				skb = get_packet(adap, fl, G_RSPD_LEN(len),
+						 eth ? SGE_RX_DROP_THRES : 0);
+			}
 
-			fl = (len & F_RSPD_FLQ) ? &qs->fl[1] : &qs->fl[0];
-			fl->credits--;
-			skb = get_packet(adap, fl, G_RSPD_LEN(len),
-					 eth ? SGE_RX_DROP_THRES : 0);
-			if (!skb)
-				q->rx_drops++;
-			else if (r->rss_hdr.opcode == CPL_TRACE_PKT)
-				__skb_pull(skb, 2);
-			ethpad = 2;
 			if (++fl->cidx == fl->size)
 				fl->cidx = 0;
 		} else
@@ -1888,18 +2011,23 @@ static int process_responses(struct adap
 			q->credits = 0;
 		}
 
-		if (likely(skb != NULL)) {
+		if (skb) {
+			/* Preserve the RSS info in csum & priority */
+			skb->csum = rss_hi;
+			skb->priority = rss_lo;
+
 			if (eth)
 				rx_eth(adap, q, skb, ethpad);
 			else {
-				/* Preserve the RSS info in csum & priority */
-				skb->csum = rss_hi;
-				skb->priority = rss_lo;
-				ngathered = rx_offload(&adap->tdev, q, skb,
-						       offload_skbs, ngathered);
+				if (unlikely(r->rss_hdr.opcode ==
+					     CPL_TRACE_PKT))
+					__skb_pull(skb, ethpad);
+
+				ngathered = rx_offload(&adap->tdev, q,
+						       skb, offload_skbs,
+						       ngathered);
 			}
 		}
-
 		--budget_left;
 	}
 
@@ -2376,7 +2504,7 @@ static void sge_timer_cb(unsigned long d
 		spin_unlock(&qs->txq[TXQ_OFLD].lock);
 	}
 	lock = (adap->flags & USING_MSIX) ? &qs->rspq.lock :
-					    &adap->sge.qs[0].rspq.lock;
+	    &adap->sge.qs[0].rspq.lock;
 	if (spin_trylock_irq(lock)) {
 		if (!napi_is_scheduled(qs->netdev)) {
 			u32 status = t3_read_reg(adap, A_SG_RSPQ_FL_STATUS);
@@ -2392,7 +2520,7 @@ static void sge_timer_cb(unsigned long d
 					refill_rspq(adap, &qs->rspq, 1);
 					qs->rspq.credits--;
 					qs->rspq.restarted++;
-					t3_write_reg(adap, A_SG_RSPQ_FL_STATUS, 
+					t3_write_reg(adap, A_SG_RSPQ_FL_STATUS,
 						     1 << qs->rspq.cntxt_id);
 				}
 			}
@@ -2504,13 +2632,21 @@ int t3_sge_alloc_qset(struct adapter *ad
 	    flits_to_desc(sgl_len(MAX_SKB_FRAGS + 1) + 3);
 
 	if (ntxq == 1) {
+#ifdef USE_RX_PAGE
+		q->fl[0].buf_size = RX_PAGE_SIZE;
+#else
 		q->fl[0].buf_size = SGE_RX_SM_BUF_SIZE + 2 +
 		    sizeof(struct cpl_rx_pkt);
+#endif
 		q->fl[1].buf_size = MAX_FRAME_SIZE + 2 +
 		    sizeof(struct cpl_rx_pkt);
 	} else {
+#ifdef USE_RX_PAGE
+		q->fl[0].buf_size = RX_PAGE_SIZE;
+#else
 		q->fl[0].buf_size = SGE_RX_SM_BUF_SIZE +
 		    sizeof(struct cpl_rx_data);
+#endif
 		q->fl[1].buf_size = (16 * 1024) -
 		    SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 	}
@@ -2704,7 +2840,7 @@ void __devinit t3_sge_prep(struct adapte
 		q->polling = adap->params.rev > 0;
 		q->coalesce_usecs = 5;
 		q->rspq_size = 1024;
-		q->fl_size = 4096;
+		q->fl_size = 1024;
 		q->jumbo_size = 512;
 		q->txq_size[TXQ_ETH] = 1024;
 		q->txq_size[TXQ_OFLD] = 1024;
