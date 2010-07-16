From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: Re: [PATCH 2.6.35-rc1] net-next: vmxnet3 fixes [1/5] Spare skb to
 avoid starvation
Date: Thu, 15 Jul 2010 18:19:39 -0700 (PDT)
Message-ID: <alpine.LRH.2.00.1007151656140.10176@localhost.localdomain>
References: <alpine.LRH.2.00.1007070214400.6105@localhost.localdomain> <alpine.LRH.2.00.1007131743520.32055@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: pv-drivers@vmware.com, linux-kernel@vger.kernel.org,
	sbhatewara@vmware.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.115.85.69]:56607 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935038Ab0GPBTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 21:19:39 -0400
In-Reply-To: <alpine.LRH.2.00.1007131743520.32055@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Reposting this patch with struct vmxnet3_cmd_ring *ring made const 
according to Stephen's feedback.

---

skb_alloc() failure can cause the ring to loose all packet reception. Avoid
this by introducing a spare buffer. The spare skb is only used when the ring
is "empty" and an skb allocation failure would cause the ring to starve. It is
never handed up to netif_rx(), and instead, when the rx_interrupt occurs, the
skb is shuffled back to reuse. Further use the incoming receive packet
interrupts as events to poll for skb allocation.


Signed-off-by: Michael Stolarchuk <stolarchuk@vmware.com>
Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>

---

 drivers/net/vmxnet3/vmxnet3_drv.c |   61 +++++++++++++++++++++++++++++++++++--
 drivers/net/vmxnet3/vmxnet3_int.h |   12 ++++++-
 2 files changed, 68 insertions(+), 5 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 989b742..5a50d10 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -541,7 +541,12 @@ vmxnet3_rq_alloc_rx_buf(struct vmxnet3_rx_queue *rq, u32 ring_idx,
 							 NET_IP_ALIGN);
 				if (unlikely(rbi->skb == NULL)) {
 					rq->stats.rx_buf_alloc_failure++;
-					break;
+					/* starvation prevention */
+					if (vmxnet3_cmd_ring_desc_empty(
+							rq->rx_ring + ring_idx))
+						rbi->skb = rq->spare_skb;
+					else
+						break;
 				}
 				rbi->skb->dev = adapter->netdev;
 
@@ -611,6 +616,29 @@ vmxnet3_append_frag(struct sk_buff *skb, struct Vmxnet3_RxCompDesc *rcd,
 }
 
 
+/*
+ * Free any pages which were attached to the frags of the spare skb.  This can
+ * happen when the spare skb is attached to the rx ring to prevent starvation,
+ * but there was no issue with page allocation.
+ */
+
+static void
+vmxnet3_rx_spare_skb_free_frags(struct vmxnet3_adapter *adapter)
+{
+	struct sk_buff *skb = adapter->rx_queue.spare_skb;
+	int i;
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[i];
+		BUG_ON(frag->page != 0);
+		put_page(frag->page);
+		frag->page = 0;
+		frag->size = 0;
+	}
+	skb_shinfo(skb)->nr_frags = 0;
+	skb->data_len = 0;
+}
+
+
 static void
 vmxnet3_map_pkt(struct sk_buff *skb, struct vmxnet3_tx_ctx *ctx,
 		struct vmxnet3_tx_queue *tq, struct pci_dev *pdev,
@@ -1060,8 +1088,12 @@ vmxnet3_rx_error(struct vmxnet3_rx_queue *rq, struct Vmxnet3_RxCompDesc *rcd,
 	 * ctx->skb may be NULL if this is the first and the only one
 	 * desc for the pkt
 	 */
-	if (ctx->skb)
-		dev_kfree_skb_irq(ctx->skb);
+	if (ctx->skb) {
+		if (ctx->skb == rq->spare_skb)
+			vmxnet3_rx_spare_skb_free_frags(adapter);
+		else
+			dev_kfree_skb_irq(ctx->skb);
+	}
 
 	ctx->skb = NULL;
 }
@@ -1159,6 +1191,12 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 
 		skb = ctx->skb;
 		if (rcd->eop) {
+			if (skb == rq->spare_skb) {
+				rq->stats.drop_total++;
+				vmxnet3_rx_spare_skb_free_frags(adapter);
+				ctx->skb = NULL;
+				goto rcd_done;
+			}
 			skb->len += skb->data_len;
 			skb->truesize += skb->data_len;
 
@@ -1244,6 +1282,14 @@ vmxnet3_rq_cleanup(struct vmxnet3_rx_queue *rq,
 		rq->uncommitted[ring_idx] = 0;
 	}
 
+	/* free starvation prevention skb if allocated */
+	if (rq->spare_skb) {
+		vmxnet3_rx_spare_skb_free_frags(adapter);
+		dev_kfree_skb(rq->spare_skb);
+		rq->spare_skb = NULL;
+	}
+
+
 	rq->comp_ring.gen = VMXNET3_INIT_GEN;
 	rq->comp_ring.next2proc = 0;
 }
@@ -1325,6 +1371,15 @@ vmxnet3_rq_init(struct vmxnet3_rx_queue *rq,
 	}
 	vmxnet3_rq_alloc_rx_buf(rq, 1, rq->rx_ring[1].size - 1, adapter);
 
+	/* allocate ring starvation protection */
+	rq->spare_skb = dev_alloc_skb(PAGE_SIZE);
+	if (rq->spare_skb == NULL) {
+		vmxnet3_rq_cleanup(rq, adapter);
+		return -ENOMEM;
+	}
+
+
+
 	/* reset the comp ring */
 	rq->comp_ring.next2proc = 0;
 	memset(rq->comp_ring.base, 0, rq->comp_ring.size *
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 34f392f..9c2fe9a 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -149,6 +149,13 @@ vmxnet3_cmd_ring_desc_avail(struct vmxnet3_cmd_ring *ring)
 		ring->next2comp - ring->next2fill - 1;
 }
 
+static inline bool
+vmxnet3_cmd_ring_desc_empty(const struct vmxnet3_cmd_ring *ring)
+{
+	return (ring->next2comp == ring->next2fill);
+}
+
+
 struct vmxnet3_comp_ring {
 	union Vmxnet3_GenericDesc *base;
 	u32               size;
@@ -266,9 +273,10 @@ struct vmxnet3_rx_queue {
 	u32 qid2;           /* rqID in RCD for buffer from 2nd ring */
 	u32 uncommitted[2]; /* # of buffers allocated since last RXPROD
 				* update */
-	struct vmxnet3_rx_buf_info     *buf_info[2];
-	struct Vmxnet3_RxQueueCtrl            *shared;
+	struct vmxnet3_rx_buf_info	*buf_info[2];
+	struct Vmxnet3_RxQueueCtrl	*shared;
 	struct vmxnet3_rq_driver_stats  stats;
+	struct sk_buff			*spare_skb;      /* starvation skb */
 } __attribute__((__aligned__(SMP_CACHE_BYTES)));
 
 #define VMXNET3_LINUX_MAX_MSIX_VECT     1
