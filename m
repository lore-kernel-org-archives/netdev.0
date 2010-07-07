From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: RE: [PATCH 2.6.35-rc1] net: vmxnet3 fixes [1/5] Spare skb to avoid
 starvation
Date: Wed, 7 Jul 2010 11:34:29 -0700 (PDT)
Message-ID: <alpine.LRH.2.00.1007071129070.4796@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, pv-drivers@vmware.com,
	stolarchuk@vmware.com, linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.115.85.69]:35349 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756701Ab0GGSea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jul 2010 14:34:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Stephen,

Thanks for taking a look.
Comments inline.

> -----Original Message-----
> From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> Sent: Wednesday, July 07, 2010 10:47 AM
> To: Shreyas Bhatewara
> Cc: netdev@vger.kernel.org; pv-drivers@vmware.com
> Subject: Re: [PATCH 2.6.35-rc1] net: vmxnet3 fixes [1/5] Spare skb to
> avoid starvation
> 
> On Wed, 7 Jul 2010 02:21:55 -0700 (PDT)
> Shreyas Bhatewara <sbhatewara@vmware.com> wrote:
> 
> >
> >
> > From: Shreyas Bhatewara <sbhatewara@vmware.com>
> >
> > skb_alloc() failure can cause the recv ring to loose all packet
> reception.
> > Avoid this by introducing a spare buffer.
> >
> > Signed-off-by: Michael Stolarchuk <stolarchuk@vmware.com>
> > Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>
> >
> 
> I don't see how this fixes the problem, what happens when
> the spare buffer is used up? Better to design a flow control algorithm
> that holds off sender if allocation fails, and retry allocation later
> (for example with a work queue).
> 


The spare skb is only used when the ring is "empty" and an skb allocation 
failure would cause the ring to starve.
It is never handed up to netif_rx(), and instead, when the rx_interrupt 
occurs, the skb is shuffled back to reuse. 

A solution like the one below was considered,


vmxnet3_try_alloc_skb(adapter)
{
    if(!vmxnet3_rq_alloc_rx_buf(..., ringsize - 1, adapter))      //This 
will be scheduled only when ring is empty, so try allocating max
            compat_schedule_delayed_work(&alloc_work, delay)
}
 
probe()
{
....
COMPAT_INIT_DELAYED_WORK(&alloc_work, vmxnet3_try_alloc_skb, adapter);
 
...
}
 
vmxnet3_rq_rx_complete()
{
.....
if (unlikely(num_to_alloc > VMXNET3_RX_ALLOC_THRESHOLD(rq,
                                                        ring_idx, 
adapter))) {
                        if(!vmxnet3_rq_alloc_rx_buf(rq, ring_idx, 
num_to_alloc, adapter) && num_to_alloc == ring_size-1)
                                      
compat_schedule_delayed_work(&alloc_work, delay);
 
 ....
}


But the value of delay, while scheduling the deferred work is critical. A 
good value is the stdard deviation of packet inter-arrival timings (varies 
a lot from low to high throughput rate). Instead of maintaining this value 
explicitly, its much smarter to rely on packet receive interrupts as 
skb-alloc-poll events, and use them to drive the skb allocation.



> > diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c
> b/drivers/net/vmxnet3/vmxnet3_drv.c
> > index 989b742..5a50d10 100644
> ...
> 
> >  /*
> > @@ -149,6 +149,13 @@ vmxnet3_cmd_ring_desc_avail(struct
> vmxnet3_cmd_ring *ring)
> >  		ring->next2comp - ring->next2fill - 1;
> >  }
> >
> > +static inline bool
> > +vmxnet3_cmd_ring_desc_empty(struct vmxnet3_cmd_ring *ring)
> > +{
> > +	return (ring->next2comp == ring->next2fill);
> > +}
> 
> const is good practice on functions like this.

Reattaching the patch with const in the function.

---

skb_alloc() failure can cause the ring to loose all packet reception. Avoid
this by introducing a spare buffer. The spare skb is only used when the ring is
"empty" and an skb allocation failure would cause the ring to starve. It is
never handed up to netif_rx(), and instead, when the rx_interrupt occurs, the 
skb is shuffled back to reuse. Further use the incoming receive packet 
interrupts as events to poll for skb allocation.

Signed-off-by: Michael Stolarchuk <stolarchuk@vmware.com>
Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>

---

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
index 34f392f..7985ba4 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -68,10 +68,10 @@
 /*
  * Version numbers
  */
-#define VMXNET3_DRIVER_VERSION_STRING   "1.0.5.0-k"
+#define VMXNET3_DRIVER_VERSION_STRING   "1.0.6.0-k"
 
 /* a 32-bit int, each byte encode a verion number in VMXNET3_DRIVER_VERSION */
-#define VMXNET3_DRIVER_VERSION_NUM      0x01000500
+#define VMXNET3_DRIVER_VERSION_NUM      0x01000600
 
 
 /*
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








