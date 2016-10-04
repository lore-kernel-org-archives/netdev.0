From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH v2 net-next 3/7] xen-netback: refactor guest rx
Date: Tue, 4 Oct 2016 10:29:14 +0100
Message-ID: <1475573358-32414-4-git-send-email-paul.durrant@citrix.com>
References: <1475573358-32414-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
        Paul Durrant <paul.durrant@citrix.com>,
        Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:53048 "EHLO SMTP.CITRIX.COM"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932197AbcJDJtK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Oct 2016 05:49:10 -0400
In-Reply-To: <1475573358-32414-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>

Refactor the to-guest (rx) path to:

1. Push responses for completed skbs earlier, reducing latency.

2. Reduce the per-queue memory overhead by greatly reducing the
   maximum number of grant copy ops in each hypercall (from 4352 to
   64).  Each struct xenvif_queue is now only 44 kB instead of 220 kB.

3. Make the code more maintainable.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
[re-based]
Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
---
Cc: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/common.h |  23 +-
 drivers/net/xen-netback/rx.c     | 654 +++++++++++++++------------------------
 2 files changed, 254 insertions(+), 423 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 0ba5910..7d12a38 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -91,13 +91,6 @@ struct xenvif_rx_meta {
  */
 #define MAX_XEN_SKB_FRAGS (65536 / XEN_PAGE_SIZE + 1)
 
-/* It's possible for an skb to have a maximal number of frags
- * but still be less than MAX_BUFFER_OFFSET in size. Thus the
- * worst-case number of copy operations is MAX_XEN_SKB_FRAGS per
- * ring slot.
- */
-#define MAX_GRANT_COPY_OPS (MAX_XEN_SKB_FRAGS * XEN_NETIF_RX_RING_SIZE)
-
 #define NETBACK_INVALID_HANDLE -1
 
 /* To avoid confusion, we define XEN_NETBK_LEGACY_SLOTS_MAX indicating
@@ -133,6 +126,14 @@ struct xenvif_stats {
 	unsigned long tx_frag_overflow;
 };
 
+#define COPY_BATCH_SIZE 64
+
+struct xenvif_copy_state {
+	struct gnttab_copy op[COPY_BATCH_SIZE];
+	RING_IDX idx[COPY_BATCH_SIZE];
+	unsigned int num;
+};
+
 struct xenvif_queue { /* Per-queue data for xenvif */
 	unsigned int id; /* Queue ID, 0-based */
 	char name[QUEUE_NAME_SIZE]; /* DEVNAME-qN */
@@ -189,12 +190,7 @@ struct xenvif_queue { /* Per-queue data for xenvif */
 	unsigned long last_rx_time;
 	bool stalled;
 
-	struct gnttab_copy grant_copy_op[MAX_GRANT_COPY_OPS];
-
-	/* We create one meta structure per ring request we consume, so
-	 * the maximum number is the same as the ring size.
-	 */
-	struct xenvif_rx_meta meta[XEN_NETIF_RX_RING_SIZE];
+	struct xenvif_copy_state rx_copy;
 
 	/* Transmit shaping: allow 'credit_bytes' every 'credit_usec'. */
 	unsigned long   credit_bytes;
@@ -358,6 +354,7 @@ int xenvif_dealloc_kthread(void *data);
 
 irqreturn_t xenvif_ctrl_irq_fn(int irq, void *data);
 
+void xenvif_rx_action(struct xenvif_queue *queue);
 void xenvif_rx_queue_tail(struct xenvif_queue *queue, struct sk_buff *skb);
 
 void xenvif_carrier_on(struct xenvif *vif);
diff --git a/drivers/net/xen-netback/rx.c b/drivers/net/xen-netback/rx.c
index 6bd7d6e..b0ce4c6 100644
--- a/drivers/net/xen-netback/rx.c
+++ b/drivers/net/xen-netback/rx.c
@@ -26,7 +26,6 @@
  * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
  * IN THE SOFTWARE.
  */
-
 #include "common.h"
 
 #include <linux/kthread.h>
@@ -137,464 +136,299 @@ static void xenvif_rx_queue_drop_expired(struct xenvif_queue *queue)
 	}
 }
 
-struct netrx_pending_operations {
-	unsigned int copy_prod, copy_cons;
-	unsigned int meta_prod, meta_cons;
-	struct gnttab_copy *copy;
-	struct xenvif_rx_meta *meta;
-	int copy_off;
-	grant_ref_t copy_gref;
-};
-
-static struct xenvif_rx_meta *get_next_rx_buffer(
-	struct xenvif_queue *queue,
-	struct netrx_pending_operations *npo)
+static void xenvif_rx_copy_flush(struct xenvif_queue *queue)
 {
-	struct xenvif_rx_meta *meta;
-	struct xen_netif_rx_request req;
+	unsigned int i;
 
-	RING_COPY_REQUEST(&queue->rx, queue->rx.req_cons++, &req);
+	gnttab_batch_copy(queue->rx_copy.op, queue->rx_copy.num);
 
-	meta = npo->meta + npo->meta_prod++;
-	meta->gso_type = XEN_NETIF_GSO_TYPE_NONE;
-	meta->gso_size = 0;
-	meta->size = 0;
-	meta->id = req.id;
+	for (i = 0; i < queue->rx_copy.num; i++) {
+		struct gnttab_copy *op;
 
-	npo->copy_off = 0;
-	npo->copy_gref = req.gref;
+		op = &queue->rx_copy.op[i];
 
-	return meta;
+		/* If the copy failed, overwrite the status field in
+		 * the corresponding response.
+		 */
+		if (unlikely(op->status != GNTST_okay)) {
+			struct xen_netif_rx_response *rsp;
+
+			rsp = RING_GET_RESPONSE(&queue->rx,
+						queue->rx_copy.idx[i]);
+			rsp->status = op->status;
+		}
+	}
+
+	queue->rx_copy.num = 0;
 }
 
-struct gop_frag_copy {
-	struct xenvif_queue *queue;
-	struct netrx_pending_operations *npo;
-	struct xenvif_rx_meta *meta;
-	int head;
-	int gso_type;
-	int protocol;
-	int hash_present;
-
-	struct page *page;
-};
-
-static void xenvif_setup_copy_gop(unsigned long gfn,
-				  unsigned int offset,
-				  unsigned int *len,
-				  struct gop_frag_copy *info)
+static void xenvif_rx_copy_add(struct xenvif_queue *queue,
+			       struct xen_netif_rx_request *req,
+			       unsigned int offset, void *data, size_t len)
 {
-	struct gnttab_copy *copy_gop;
+	struct gnttab_copy *op;
+	struct page *page;
 	struct xen_page_foreign *foreign;
-	/* Convenient aliases */
-	struct xenvif_queue *queue = info->queue;
-	struct netrx_pending_operations *npo = info->npo;
-	struct page *page = info->page;
 
-	WARN_ON(npo->copy_off > MAX_BUFFER_OFFSET);
+	if (queue->rx_copy.num == COPY_BATCH_SIZE)
+		xenvif_rx_copy_flush(queue);
 
-	if (npo->copy_off == MAX_BUFFER_OFFSET)
-		info->meta = get_next_rx_buffer(queue, npo);
+	op = &queue->rx_copy.op[queue->rx_copy.num];
 
-	if (npo->copy_off + *len > MAX_BUFFER_OFFSET)
-		*len = MAX_BUFFER_OFFSET - npo->copy_off;
+	page = virt_to_page(data);
 
-	copy_gop = npo->copy + npo->copy_prod++;
-	copy_gop->flags = GNTCOPY_dest_gref;
-	copy_gop->len = *len;
+	op->flags = GNTCOPY_dest_gref;
 
 	foreign = xen_page_foreign(page);
 	if (foreign) {
-		copy_gop->source.domid = foreign->domid;
-		copy_gop->source.u.ref = foreign->gref;
-		copy_gop->flags |= GNTCOPY_source_gref;
+		op->source.domid = foreign->domid;
+		op->source.u.ref = foreign->gref;
+		op->flags |= GNTCOPY_source_gref;
 	} else {
-		copy_gop->source.domid = DOMID_SELF;
-		copy_gop->source.u.gmfn = gfn;
+		op->source.u.gmfn = virt_to_gfn(data);
+		op->source.domid  = DOMID_SELF;
 	}
-	copy_gop->source.offset = offset;
 
-	copy_gop->dest.domid = queue->vif->domid;
-	copy_gop->dest.offset = npo->copy_off;
-	copy_gop->dest.u.ref = npo->copy_gref;
+	op->source.offset = xen_offset_in_page(data);
+	op->dest.u.ref    = req->gref;
+	op->dest.domid    = queue->vif->domid;
+	op->dest.offset   = offset;
+	op->len           = len;
 
-	npo->copy_off += *len;
-	info->meta->size += *len;
-
-	if (!info->head)
-		return;
-
-	/* Leave a gap for the GSO descriptor. */
-	if ((1 << info->gso_type) & queue->vif->gso_mask)
-		queue->rx.req_cons++;
-
-	/* Leave a gap for the hash extra segment. */
-	if (info->hash_present)
-		queue->rx.req_cons++;
-
-	info->head = 0; /* There must be something in this buffer now */
+	queue->rx_copy.idx[queue->rx_copy.num] = queue->rx.req_cons;
+	queue->rx_copy.num++;
 }
 
-static void xenvif_gop_frag_copy_grant(unsigned long gfn,
-				       unsigned int offset,
-				       unsigned int len,
-				       void *data)
+static unsigned int xenvif_gso_type(struct sk_buff *skb)
 {
-	unsigned int bytes;
-
-	while (len) {
-		bytes = len;
-		xenvif_setup_copy_gop(gfn, offset, &bytes, data);
-		offset += bytes;
-		len -= bytes;
-	}
-}
-
-/* Set up the grant operations for this fragment. If it's a flipping
- * interface, we also set up the unmap request from here.
- */
-static void xenvif_gop_frag_copy(struct xenvif_queue *queue,
-				 struct sk_buff *skb,
-				 struct netrx_pending_operations *npo,
-				 struct page *page, unsigned long size,
-				 unsigned long offset, int *head)
-{
-	struct gop_frag_copy info = {
-		.queue = queue,
-		.npo = npo,
-		.head = *head,
-		.gso_type = XEN_NETIF_GSO_TYPE_NONE,
-		/* xenvif_set_skb_hash() will have either set a s/w
-		 * hash or cleared the hash depending on
-		 * whether the the frontend wants a hash for this skb.
-		 */
-		.hash_present = skb->sw_hash,
-	};
-	unsigned long bytes;
-
 	if (skb_is_gso(skb)) {
 		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
-			info.gso_type = XEN_NETIF_GSO_TYPE_TCPV4;
-		else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
-			info.gso_type = XEN_NETIF_GSO_TYPE_TCPV6;
-	}
-
-	/* Data must not cross a page boundary. */
-	WARN_ON(size + offset > (PAGE_SIZE << compound_order(page)));
-
-	info.meta = npo->meta + npo->meta_prod - 1;
-
-	/* Skip unused frames from start of page */
-	page += offset >> PAGE_SHIFT;
-	offset &= ~PAGE_MASK;
-
-	while (size > 0) {
-		WARN_ON(offset >= PAGE_SIZE);
-
-		bytes = PAGE_SIZE - offset;
-		if (bytes > size)
-			bytes = size;
-
-		info.page = page;
-		gnttab_foreach_grant_in_range(page, offset, bytes,
-					      xenvif_gop_frag_copy_grant,
-					      &info);
-		size -= bytes;
-		offset = 0;
-
-		/* Next page */
-		if (size) {
-			WARN_ON(!PageCompound(page));
-			page++;
-		}
-	}
-
-	*head = info.head;
-}
-
-/* Prepare an SKB to be transmitted to the frontend.
- *
- * This function is responsible for allocating grant operations, meta
- * structures, etc.
- *
- * It returns the number of meta structures consumed. The number of
- * ring slots used is always equal to the number of meta slots used
- * plus the number of GSO descriptors used. Currently, we use either
- * zero GSO descriptors (for non-GSO packets) or one descriptor (for
- * frontend-side LRO).
- */
-static int xenvif_gop_skb(struct sk_buff *skb,
-			  struct netrx_pending_operations *npo,
-			  struct xenvif_queue *queue)
-{
-	struct xenvif *vif = netdev_priv(skb->dev);
-	int nr_frags = skb_shinfo(skb)->nr_frags;
-	int i;
-	struct xen_netif_rx_request req;
-	struct xenvif_rx_meta *meta;
-	unsigned char *data;
-	int head = 1;
-	int old_meta_prod;
-	int gso_type;
-
-	old_meta_prod = npo->meta_prod;
-
-	gso_type = XEN_NETIF_GSO_TYPE_NONE;
-	if (skb_is_gso(skb)) {
-		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
-			gso_type = XEN_NETIF_GSO_TYPE_TCPV4;
-		else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
-			gso_type = XEN_NETIF_GSO_TYPE_TCPV6;
-	}
-
-	RING_COPY_REQUEST(&queue->rx, queue->rx.req_cons++, &req);
-	meta = npo->meta + npo->meta_prod++;
-
-	if ((1 << gso_type) & vif->gso_mask) {
-		meta->gso_type = gso_type;
-		meta->gso_size = skb_shinfo(skb)->gso_size;
-	} else {
-		meta->gso_type = XEN_NETIF_GSO_TYPE_NONE;
-		meta->gso_size = 0;
-	}
-
-	meta->size = 0;
-	meta->id = req.id;
-	npo->copy_off = 0;
-	npo->copy_gref = req.gref;
-
-	data = skb->data;
-	while (data < skb_tail_pointer(skb)) {
-		unsigned int offset = offset_in_page(data);
-		unsigned int len = PAGE_SIZE - offset;
-
-		if (data + len > skb_tail_pointer(skb))
-			len = skb_tail_pointer(skb) - data;
-
-		xenvif_gop_frag_copy(queue, skb, npo,
-				     virt_to_page(data), len, offset, &head);
-		data += len;
-	}
-
-	for (i = 0; i < nr_frags; i++) {
-		xenvif_gop_frag_copy(queue, skb, npo,
-				     skb_frag_page(&skb_shinfo(skb)->frags[i]),
-				     skb_frag_size(&skb_shinfo(skb)->frags[i]),
-				     skb_shinfo(skb)->frags[i].page_offset,
-				     &head);
-	}
-
-	return npo->meta_prod - old_meta_prod;
-}
-
-/* This is a twin to xenvif_gop_skb.  Assume that xenvif_gop_skb was
- * used to set up the operations on the top of
- * netrx_pending_operations, which have since been done.  Check that
- * they didn't give any errors and advance over them.
- */
-static int xenvif_check_gop(struct xenvif *vif, int nr_meta_slots,
-			    struct netrx_pending_operations *npo)
-{
-	struct gnttab_copy     *copy_op;
-	int status = XEN_NETIF_RSP_OKAY;
-	int i;
-
-	for (i = 0; i < nr_meta_slots; i++) {
-		copy_op = npo->copy + npo->copy_cons++;
-		if (copy_op->status != GNTST_okay) {
-			netdev_dbg(vif->dev,
-				   "Bad status %d from copy to DOM%d.\n",
-				   copy_op->status, vif->domid);
-			status = XEN_NETIF_RSP_ERROR;
-		}
-	}
-
-	return status;
-}
-
-static struct xen_netif_rx_response *make_rx_response(
-	struct xenvif_queue *queue, u16 id, s8 st, u16 offset, u16 size,
-	u16 flags)
-{
-	RING_IDX i = queue->rx.rsp_prod_pvt;
-	struct xen_netif_rx_response *resp;
-
-	resp = RING_GET_RESPONSE(&queue->rx, i);
-	resp->offset     = offset;
-	resp->flags      = flags;
-	resp->id         = id;
-	resp->status     = (s16)size;
-	if (st < 0)
-		resp->status = (s16)st;
-
-	queue->rx.rsp_prod_pvt = ++i;
-
-	return resp;
-}
-
-static void xenvif_add_frag_responses(struct xenvif_queue *queue,
-				      int status,
-				      struct xenvif_rx_meta *meta,
-				      int nr_meta_slots)
-{
-	int i;
-	unsigned long offset;
-
-	/* No fragments used */
-	if (nr_meta_slots <= 1)
-		return;
-
-	nr_meta_slots--;
-
-	for (i = 0; i < nr_meta_slots; i++) {
-		int flags;
-
-		if (i == nr_meta_slots - 1)
-			flags = 0;
+			return XEN_NETIF_GSO_TYPE_TCPV4;
 		else
-			flags = XEN_NETRXF_more_data;
-
-		offset = 0;
-		make_rx_response(queue, meta[i].id, status, offset,
-				 meta[i].size, flags);
+			return XEN_NETIF_GSO_TYPE_TCPV6;
 	}
+	return XEN_NETIF_GSO_TYPE_NONE;
 }
 
-static void xenvif_rx_action(struct xenvif_queue *queue)
-{
-	struct xenvif *vif = queue->vif;
-	s8 status;
-	u16 flags;
-	struct xen_netif_rx_response *resp;
-	struct sk_buff_head rxq;
+struct xenvif_pkt_state {
 	struct sk_buff *skb;
-	LIST_HEAD(notify);
-	int ret;
-	unsigned long offset;
-	bool need_to_notify = false;
+	size_t remaining_len;
+	int frag; /* frag == -1 => skb->head */
+	unsigned int frag_offset;
+	struct xen_netif_extra_info extras[XEN_NETIF_EXTRA_TYPE_MAX - 1];
+	unsigned int extra_count;
+	unsigned int slot;
+};
 
-	struct netrx_pending_operations npo = {
-		.copy  = queue->grant_copy_op,
-		.meta  = queue->meta,
-	};
+static void xenvif_rx_next_skb(struct xenvif_queue *queue,
+			       struct xenvif_pkt_state *pkt)
+{
+	struct sk_buff *skb;
+	unsigned int gso_type;
 
-	skb_queue_head_init(&rxq);
+	skb = xenvif_rx_dequeue(queue);
 
-	while (xenvif_rx_ring_slots_available(queue) &&
-	       (skb = xenvif_rx_dequeue(queue)) != NULL) {
-		queue->last_rx_time = jiffies;
+	queue->stats.tx_bytes += skb->len;
+	queue->stats.tx_packets++;
 
-		XENVIF_RX_CB(skb)->meta_slots_used =
-			xenvif_gop_skb(skb, &npo, queue);
+	/* Reset packet state. */
+	memset(pkt, 0, sizeof(struct xenvif_pkt_state));
 
-		__skb_queue_tail(&rxq, skb);
+	pkt->skb = skb;
+	pkt->remaining_len = skb->len;
+	pkt->frag = -1;
+
+	gso_type = xenvif_gso_type(skb);
+	if ((1 << gso_type) & queue->vif->gso_mask) {
+		struct xen_netif_extra_info *extra;
+
+		extra = &pkt->extras[XEN_NETIF_EXTRA_TYPE_GSO - 1];
+
+		extra->u.gso.type = gso_type;
+		extra->u.gso.size = skb_shinfo(skb)->gso_size;
+		extra->u.gso.pad = 0;
+		extra->u.gso.features = 0;
+		extra->type = XEN_NETIF_EXTRA_TYPE_GSO;
+		extra->flags = 0;
+
+		pkt->extra_count++;
 	}
 
-	WARN_ON(npo.meta_prod > ARRAY_SIZE(queue->meta));
+	if (skb->sw_hash) {
+		struct xen_netif_extra_info *extra;
 
-	if (!npo.copy_prod)
-		goto done;
+		extra = &pkt->extras[XEN_NETIF_EXTRA_TYPE_HASH - 1];
 
-	WARN_ON(npo.copy_prod > MAX_GRANT_COPY_OPS);
-	gnttab_batch_copy(queue->grant_copy_op, npo.copy_prod);
+		extra->u.hash.algorithm =
+			XEN_NETIF_CTRL_HASH_ALGORITHM_TOEPLITZ;
 
-	while ((skb = __skb_dequeue(&rxq)) != NULL) {
-		struct xen_netif_extra_info *extra = NULL;
-
-		queue->stats.tx_bytes += skb->len;
-		queue->stats.tx_packets++;
-
-		status = xenvif_check_gop(vif,
-					  XENVIF_RX_CB(skb)->meta_slots_used,
-					  &npo);
-
-		if (XENVIF_RX_CB(skb)->meta_slots_used == 1)
-			flags = 0;
+		if (skb->l4_hash)
+			extra->u.hash.type =
+				skb->protocol == htons(ETH_P_IP) ?
+				_XEN_NETIF_CTRL_HASH_TYPE_IPV4_TCP :
+				_XEN_NETIF_CTRL_HASH_TYPE_IPV6_TCP;
 		else
-			flags = XEN_NETRXF_more_data;
+			extra->u.hash.type =
+				skb->protocol == htons(ETH_P_IP) ?
+				_XEN_NETIF_CTRL_HASH_TYPE_IPV4 :
+				_XEN_NETIF_CTRL_HASH_TYPE_IPV6;
 
-		if (skb->ip_summed == CHECKSUM_PARTIAL) /* local packet? */
+		*(uint32_t *)extra->u.hash.value = skb_get_hash_raw(skb);
+
+		extra->type = XEN_NETIF_EXTRA_TYPE_HASH;
+		extra->flags = 0;
+
+		pkt->extra_count++;
+	}
+}
+
+static void xenvif_rx_complete(struct xenvif_queue *queue,
+			       struct xenvif_pkt_state *pkt)
+{
+	int notify;
+
+	/* Complete any outstanding copy ops for this skb. */
+	xenvif_rx_copy_flush(queue);
+
+	/* Push responses and notify. */
+	queue->rx.rsp_prod_pvt = queue->rx.req_cons;
+	RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&queue->rx, notify);
+	if (notify)
+		notify_remote_via_irq(queue->rx_irq);
+
+	dev_kfree_skb(pkt->skb);
+}
+
+static void xenvif_rx_next_chunk(struct xenvif_queue *queue,
+				 struct xenvif_pkt_state *pkt,
+				 unsigned int offset, void **data,
+				 size_t *len)
+{
+	struct sk_buff *skb = pkt->skb;
+	void *frag_data;
+	size_t frag_len, chunk_len;
+
+	if (pkt->frag == -1) {
+		frag_data = skb->data;
+		frag_len = skb_headlen(skb);
+	} else {
+		skb_frag_t *frag = &skb_shinfo(skb)->frags[pkt->frag];
+
+		frag_data = skb_frag_address(frag);
+		frag_len = skb_frag_size(frag);
+	}
+
+	frag_data += pkt->frag_offset;
+	frag_len -= pkt->frag_offset;
+
+	chunk_len = min(frag_len, XEN_PAGE_SIZE - offset);
+	chunk_len = min(chunk_len,
+			XEN_PAGE_SIZE -	xen_offset_in_page(frag_data));
+
+	pkt->frag_offset += chunk_len;
+
+	/* Advance to next frag? */
+	if (frag_len == chunk_len) {
+		pkt->frag++;
+		pkt->frag_offset = 0;
+	}
+
+	*data = frag_data;
+	*len = chunk_len;
+}
+
+static void xenvif_rx_data_slot(struct xenvif_queue *queue,
+				struct xenvif_pkt_state *pkt,
+				struct xen_netif_rx_request *req,
+				struct xen_netif_rx_response *rsp)
+{
+	unsigned int offset = 0;
+	unsigned int flags;
+
+	do {
+		size_t len;
+		void *data;
+
+		xenvif_rx_next_chunk(queue, pkt, offset, &data, &len);
+		xenvif_rx_copy_add(queue, req, offset, data, len);
+
+		offset += len;
+		pkt->remaining_len -= len;
+
+	} while (offset < XEN_PAGE_SIZE && pkt->remaining_len > 0);
+
+	if (pkt->remaining_len > 0)
+		flags = XEN_NETRXF_more_data;
+	else
+		flags = 0;
+
+	if (pkt->slot == 0) {
+		struct sk_buff *skb = pkt->skb;
+
+		if (skb->ip_summed == CHECKSUM_PARTIAL)
 			flags |= XEN_NETRXF_csum_blank |
 				 XEN_NETRXF_data_validated;
 		else if (skb->ip_summed == CHECKSUM_UNNECESSARY)
-			/* remote but checksummed. */
 			flags |= XEN_NETRXF_data_validated;
 
-		offset = 0;
-		resp = make_rx_response(queue, queue->meta[npo.meta_cons].id,
-					status, offset,
-					queue->meta[npo.meta_cons].size,
-					flags);
-
-		if ((1 << queue->meta[npo.meta_cons].gso_type) &
-		    vif->gso_mask) {
-			extra = (struct xen_netif_extra_info *)
-				RING_GET_RESPONSE(&queue->rx,
-						  queue->rx.rsp_prod_pvt++);
-
-			resp->flags |= XEN_NETRXF_extra_info;
-
-			extra->u.gso.type = queue->meta[npo.meta_cons].gso_type;
-			extra->u.gso.size = queue->meta[npo.meta_cons].gso_size;
-			extra->u.gso.pad = 0;
-			extra->u.gso.features = 0;
-
-			extra->type = XEN_NETIF_EXTRA_TYPE_GSO;
-			extra->flags = 0;
-		}
-
-		if (skb->sw_hash) {
-			/* Since the skb got here via xenvif_select_queue()
-			 * we know that the hash has been re-calculated
-			 * according to a configuration set by the frontend
-			 * and therefore we know that it is legitimate to
-			 * pass it to the frontend.
-			 */
-			if (resp->flags & XEN_NETRXF_extra_info)
-				extra->flags |= XEN_NETIF_EXTRA_FLAG_MORE;
-			else
-				resp->flags |= XEN_NETRXF_extra_info;
-
-			extra = (struct xen_netif_extra_info *)
-				RING_GET_RESPONSE(&queue->rx,
-						  queue->rx.rsp_prod_pvt++);
-
-			extra->u.hash.algorithm =
-				XEN_NETIF_CTRL_HASH_ALGORITHM_TOEPLITZ;
-
-			if (skb->l4_hash)
-				extra->u.hash.type =
-					skb->protocol == htons(ETH_P_IP) ?
-					_XEN_NETIF_CTRL_HASH_TYPE_IPV4_TCP :
-					_XEN_NETIF_CTRL_HASH_TYPE_IPV6_TCP;
-			else
-				extra->u.hash.type =
-					skb->protocol == htons(ETH_P_IP) ?
-					_XEN_NETIF_CTRL_HASH_TYPE_IPV4 :
-					_XEN_NETIF_CTRL_HASH_TYPE_IPV6;
-
-			*(uint32_t *)extra->u.hash.value =
-				skb_get_hash_raw(skb);
-
-			extra->type = XEN_NETIF_EXTRA_TYPE_HASH;
-			extra->flags = 0;
-		}
-
-		xenvif_add_frag_responses(queue, status,
-					  queue->meta + npo.meta_cons + 1,
-					  XENVIF_RX_CB(skb)->meta_slots_used);
-
-		RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&queue->rx, ret);
-
-		need_to_notify |= !!ret;
-
-		npo.meta_cons += XENVIF_RX_CB(skb)->meta_slots_used;
-		dev_kfree_skb(skb);
+		if (pkt->extra_count != 0)
+			flags |= XEN_NETRXF_extra_info;
 	}
 
-done:
-	if (need_to_notify)
-		notify_remote_via_irq(queue->rx_irq);
+	rsp->offset = 0;
+	rsp->flags = flags;
+	rsp->id = req->id;
+	rsp->status = (s16)offset;
+}
+
+static void xenvif_rx_extra_slot(struct xenvif_queue *queue,
+				 struct xenvif_pkt_state *pkt,
+				 struct xen_netif_rx_request *req,
+				 struct xen_netif_rx_response *rsp)
+{
+	struct xen_netif_extra_info *extra = (void *)rsp;
+	unsigned int i;
+
+	pkt->extra_count--;
+
+	for (i = 0; i < ARRAY_SIZE(pkt->extras); i++) {
+		if (pkt->extras[i].type) {
+			*extra = pkt->extras[i];
+
+			if (pkt->extra_count != 0)
+				extra->flags |= XEN_NETIF_EXTRA_FLAG_MORE;
+
+			pkt->extras[i].type = 0;
+			return;
+		}
+	}
+	BUG();
+}
+
+void xenvif_rx_action(struct xenvif_queue *queue)
+{
+	struct xenvif_pkt_state pkt;
+
+	xenvif_rx_next_skb(queue, &pkt);
+
+	do {
+		struct xen_netif_rx_request *req;
+		struct xen_netif_rx_response *rsp;
+
+		req = RING_GET_REQUEST(&queue->rx, queue->rx.req_cons);
+		rsp = RING_GET_RESPONSE(&queue->rx, queue->rx.req_cons);
+
+		/* Extras must go after the first data slot */
+		if (pkt.slot != 0 && pkt.extra_count != 0)
+			xenvif_rx_extra_slot(queue, &pkt, req, rsp);
+		else
+			xenvif_rx_data_slot(queue, &pkt, req, rsp);
+
+		queue->rx.req_cons++;
+		pkt.slot++;
+	} while (pkt.remaining_len > 0 || pkt.extra_count != 0);
+
+	xenvif_rx_complete(queue, &pkt);
 }
 
 static bool xenvif_rx_queue_stalled(struct xenvif_queue *queue)
-- 
2.1.4
