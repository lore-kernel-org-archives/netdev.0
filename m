From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
Subject: [PATCH V8 net-next 4/6] xen-netfront: Factor
	queue-specific data into queue struct.
Date: Wed, 14 May 2014 14:52:28 +0100
Message-ID: <1400075550-4580-5-git-send-email-andrew.bennieston@citrix.com>
References: <1400075550-4580-1-git-send-email-andrew.bennieston@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, ian.campbell@citrix.com, netdev@vger.kernel.org,
	paul.durrant@citrix.com, david.vrabel@citrix.com, zoltan.kiss@citrix.com,
	"Andrew J. Bennieston" <andrew.bennieston@citrix.com>
To: <xen-devel@lists.xenproject.org>, <davem@davemloft.net>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1400075550-4580-1-git-send-email-andrew.bennieston@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>

In preparation for multi-queue support in xen-netfront, move the
queue-specific data from struct netfront_info to struct netfront_queue,
and update the rest of the code to use this.

Also adds loops over queues where appropriate, even though only one is
configured at this point, and uses alloc_etherdev_mq() and the
corresponding multi-queue netif wake/start/stop functions in preparation
for multiple active queues.

Finally, implements a trivial queue selection function suitable for
ndo_select_queue, which simply returns 0, selecting the first (and
only) queue.

Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>
Acked-by: Wei Liu <wei.liu2@citrix.com>
Reviewed-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netfront.c |  972 ++++++++++++++++++++++++++------------------
 1 file changed, 579 insertions(+), 393 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 895355d..af8cd95 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -73,6 +73,12 @@ struct netfront_cb {
 #define NET_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE)
 #define TX_MAX_TARGET min_t(int, NET_TX_RING_SIZE, 256)
 
+/* Queue name is interface name with "-qNNN" appended */
+#define QUEUE_NAME_SIZE (IFNAMSIZ + 6)
+
+/* IRQ name is queue name with "-tx" or "-rx" appended */
+#define IRQ_NAME_SIZE (QUEUE_NAME_SIZE + 3)
+
 struct netfront_stats {
 	u64			rx_packets;
 	u64			tx_packets;
@@ -81,9 +87,12 @@ struct netfront_stats {
 	struct u64_stats_sync	syncp;
 };
 
-struct netfront_info {
-	struct list_head list;
-	struct net_device *netdev;
+struct netfront_info;
+
+struct netfront_queue {
+	unsigned int id; /* Queue ID, 0-based */
+	char name[QUEUE_NAME_SIZE]; /* DEVNAME-qN */
+	struct netfront_info *info;
 
 	struct napi_struct napi;
 
@@ -93,10 +102,8 @@ struct netfront_info {
 	unsigned int tx_evtchn, rx_evtchn;
 	unsigned int tx_irq, rx_irq;
 	/* Only used when split event channels support is enabled */
-	char tx_irq_name[IFNAMSIZ+4]; /* DEVNAME-tx */
-	char rx_irq_name[IFNAMSIZ+4]; /* DEVNAME-rx */
-
-	struct xenbus_device *xbdev;
+	char tx_irq_name[IRQ_NAME_SIZE]; /* DEVNAME-qN-tx */
+	char rx_irq_name[IRQ_NAME_SIZE]; /* DEVNAME-qN-rx */
 
 	spinlock_t   tx_lock;
 	struct xen_netif_tx_front_ring tx;
@@ -140,11 +147,21 @@ struct netfront_info {
 	unsigned long rx_pfn_array[NET_RX_RING_SIZE];
 	struct multicall_entry rx_mcl[NET_RX_RING_SIZE+1];
 	struct mmu_update rx_mmu[NET_RX_RING_SIZE];
+};
+
+struct netfront_info {
+	struct list_head list;
+	struct net_device *netdev;
+
+	struct xenbus_device *xbdev;
+
+	/* Multi-queue support */
+	struct netfront_queue *queues;
 
 	/* Statistics */
 	struct netfront_stats __percpu *stats;
 
-	unsigned long rx_gso_checksum_fixup;
+	atomic_t rx_gso_checksum_fixup;
 };
 
 struct netfront_rx_info {
@@ -187,21 +204,21 @@ static int xennet_rxidx(RING_IDX idx)
 	return idx & (NET_RX_RING_SIZE - 1);
 }
 
-static struct sk_buff *xennet_get_rx_skb(struct netfront_info *np,
+static struct sk_buff *xennet_get_rx_skb(struct netfront_queue *queue,
 					 RING_IDX ri)
 {
 	int i = xennet_rxidx(ri);
-	struct sk_buff *skb = np->rx_skbs[i];
-	np->rx_skbs[i] = NULL;
+	struct sk_buff *skb = queue->rx_skbs[i];
+	queue->rx_skbs[i] = NULL;
 	return skb;
 }
 
-static grant_ref_t xennet_get_rx_ref(struct netfront_info *np,
+static grant_ref_t xennet_get_rx_ref(struct netfront_queue *queue,
 					    RING_IDX ri)
 {
 	int i = xennet_rxidx(ri);
-	grant_ref_t ref = np->grant_rx_ref[i];
-	np->grant_rx_ref[i] = GRANT_INVALID_REF;
+	grant_ref_t ref = queue->grant_rx_ref[i];
+	queue->grant_rx_ref[i] = GRANT_INVALID_REF;
 	return ref;
 }
 
@@ -221,41 +238,40 @@ static bool xennet_can_sg(struct net_device *dev)
 
 static void rx_refill_timeout(unsigned long data)
 {
-	struct net_device *dev = (struct net_device *)data;
-	struct netfront_info *np = netdev_priv(dev);
-	napi_schedule(&np->napi);
+	struct netfront_queue *queue = (struct netfront_queue *)data;
+	napi_schedule(&queue->napi);
 }
 
-static int netfront_tx_slot_available(struct netfront_info *np)
+static int netfront_tx_slot_available(struct netfront_queue *queue)
 {
-	return (np->tx.req_prod_pvt - np->tx.rsp_cons) <
+	return (queue->tx.req_prod_pvt - queue->tx.rsp_cons) <
 		(TX_MAX_TARGET - MAX_SKB_FRAGS - 2);
 }
 
-static void xennet_maybe_wake_tx(struct net_device *dev)
+static void xennet_maybe_wake_tx(struct netfront_queue *queue)
 {
-	struct netfront_info *np = netdev_priv(dev);
+	struct net_device *dev = queue->info->netdev;
+	struct netdev_queue *dev_queue = netdev_get_tx_queue(dev, queue->id);
 
-	if (unlikely(netif_queue_stopped(dev)) &&
-	    netfront_tx_slot_available(np) &&
+	if (unlikely(netif_tx_queue_stopped(dev_queue)) &&
+	    netfront_tx_slot_available(queue) &&
 	    likely(netif_running(dev)))
-		netif_wake_queue(dev);
+		netif_tx_wake_queue(netdev_get_tx_queue(dev, queue->id));
 }
 
-static void xennet_alloc_rx_buffers(struct net_device *dev)
+static void xennet_alloc_rx_buffers(struct netfront_queue *queue)
 {
 	unsigned short id;
-	struct netfront_info *np = netdev_priv(dev);
 	struct sk_buff *skb;
 	struct page *page;
 	int i, batch_target, notify;
-	RING_IDX req_prod = np->rx.req_prod_pvt;
+	RING_IDX req_prod = queue->rx.req_prod_pvt;
 	grant_ref_t ref;
 	unsigned long pfn;
 	void *vaddr;
 	struct xen_netif_rx_request *req;
 
-	if (unlikely(!netif_carrier_ok(dev)))
+	if (unlikely(!netif_carrier_ok(queue->info->netdev)))
 		return;
 
 	/*
@@ -264,9 +280,10 @@ static void xennet_alloc_rx_buffers(struct net_device *dev)
 	 * allocator, so should reduce the chance of failed allocation requests
 	 * both for ourself and for other kernel subsystems.
 	 */
-	batch_target = np->rx_target - (req_prod - np->rx.rsp_cons);
-	for (i = skb_queue_len(&np->rx_batch); i < batch_target; i++) {
-		skb = __netdev_alloc_skb(dev, RX_COPY_THRESHOLD + NET_IP_ALIGN,
+	batch_target = queue->rx_target - (req_prod - queue->rx.rsp_cons);
+	for (i = skb_queue_len(&queue->rx_batch); i < batch_target; i++) {
+		skb = __netdev_alloc_skb(queue->info->netdev,
+					 RX_COPY_THRESHOLD + NET_IP_ALIGN,
 					 GFP_ATOMIC | __GFP_NOWARN);
 		if (unlikely(!skb))
 			goto no_skb;
@@ -279,7 +296,7 @@ static void xennet_alloc_rx_buffers(struct net_device *dev)
 			kfree_skb(skb);
 no_skb:
 			/* Could not allocate any skbuffs. Try again later. */
-			mod_timer(&np->rx_refill_timer,
+			mod_timer(&queue->rx_refill_timer,
 				  jiffies + (HZ/10));
 
 			/* Any skbuffs queued for refill? Force them out. */
@@ -289,44 +306,44 @@ no_skb:
 		}
 
 		skb_add_rx_frag(skb, 0, page, 0, 0, PAGE_SIZE);
-		__skb_queue_tail(&np->rx_batch, skb);
+		__skb_queue_tail(&queue->rx_batch, skb);
 	}
 
 	/* Is the batch large enough to be worthwhile? */
-	if (i < (np->rx_target/2)) {
-		if (req_prod > np->rx.sring->req_prod)
+	if (i < (queue->rx_target/2)) {
+		if (req_prod > queue->rx.sring->req_prod)
 			goto push;
 		return;
 	}
 
 	/* Adjust our fill target if we risked running out of buffers. */
-	if (((req_prod - np->rx.sring->rsp_prod) < (np->rx_target / 4)) &&
-	    ((np->rx_target *= 2) > np->rx_max_target))
-		np->rx_target = np->rx_max_target;
+	if (((req_prod - queue->rx.sring->rsp_prod) < (queue->rx_target / 4)) &&
+	    ((queue->rx_target *= 2) > queue->rx_max_target))
+		queue->rx_target = queue->rx_max_target;
 
  refill:
 	for (i = 0; ; i++) {
-		skb = __skb_dequeue(&np->rx_batch);
+		skb = __skb_dequeue(&queue->rx_batch);
 		if (skb == NULL)
 			break;
 
-		skb->dev = dev;
+		skb->dev = queue->info->netdev;
 
 		id = xennet_rxidx(req_prod + i);
 
-		BUG_ON(np->rx_skbs[id]);
-		np->rx_skbs[id] = skb;
+		BUG_ON(queue->rx_skbs[id]);
+		queue->rx_skbs[id] = skb;
 
-		ref = gnttab_claim_grant_reference(&np->gref_rx_head);
+		ref = gnttab_claim_grant_reference(&queue->gref_rx_head);
 		BUG_ON((signed short)ref < 0);
-		np->grant_rx_ref[id] = ref;
+		queue->grant_rx_ref[id] = ref;
 
 		pfn = page_to_pfn(skb_frag_page(&skb_shinfo(skb)->frags[0]));
 		vaddr = page_address(skb_frag_page(&skb_shinfo(skb)->frags[0]));
 
-		req = RING_GET_REQUEST(&np->rx, req_prod + i);
+		req = RING_GET_REQUEST(&queue->rx, req_prod + i);
 		gnttab_grant_foreign_access_ref(ref,
-						np->xbdev->otherend_id,
+						queue->info->xbdev->otherend_id,
 						pfn_to_mfn(pfn),
 						0);
 
@@ -337,72 +354,77 @@ no_skb:
 	wmb();		/* barrier so backend seens requests */
 
 	/* Above is a suitable barrier to ensure backend will see requests. */
-	np->rx.req_prod_pvt = req_prod + i;
+	queue->rx.req_prod_pvt = req_prod + i;
  push:
-	RING_PUSH_REQUESTS_AND_CHECK_NOTIFY(&np->rx, notify);
+	RING_PUSH_REQUESTS_AND_CHECK_NOTIFY(&queue->rx, notify);
 	if (notify)
-		notify_remote_via_irq(np->rx_irq);
+		notify_remote_via_irq(queue->rx_irq);
 }
 
 static int xennet_open(struct net_device *dev)
 {
 	struct netfront_info *np = netdev_priv(dev);
-
-	napi_enable(&np->napi);
-
-	spin_lock_bh(&np->rx_lock);
-	if (netif_carrier_ok(dev)) {
-		xennet_alloc_rx_buffers(dev);
-		np->rx.sring->rsp_event = np->rx.rsp_cons + 1;
-		if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx))
-			napi_schedule(&np->napi);
+	unsigned int num_queues = dev->real_num_tx_queues;
+	unsigned int i = 0;
+	struct netfront_queue *queue = NULL;
+
+	for (i = 0; i < num_queues; ++i) {
+		queue = &np->queues[i];
+		napi_enable(&queue->napi);
+
+		spin_lock_bh(&queue->rx_lock);
+		if (netif_carrier_ok(dev)) {
+			xennet_alloc_rx_buffers(queue);
+			queue->rx.sring->rsp_event = queue->rx.rsp_cons + 1;
+			if (RING_HAS_UNCONSUMED_RESPONSES(&queue->rx))
+				napi_schedule(&queue->napi);
+		}
+		spin_unlock_bh(&queue->rx_lock);
 	}
-	spin_unlock_bh(&np->rx_lock);
 
-	netif_start_queue(dev);
+	netif_tx_start_all_queues(dev);
 
 	return 0;
 }
 
-static void xennet_tx_buf_gc(struct net_device *dev)
+static void xennet_tx_buf_gc(struct netfront_queue *queue)
 {
 	RING_IDX cons, prod;
 	unsigned short id;
-	struct netfront_info *np = netdev_priv(dev);
 	struct sk_buff *skb;
 
-	BUG_ON(!netif_carrier_ok(dev));
+	BUG_ON(!netif_carrier_ok(queue->info->netdev));
 
 	do {
-		prod = np->tx.sring->rsp_prod;
+		prod = queue->tx.sring->rsp_prod;
 		rmb(); /* Ensure we see responses up to 'rp'. */
 
-		for (cons = np->tx.rsp_cons; cons != prod; cons++) {
+		for (cons = queue->tx.rsp_cons; cons != prod; cons++) {
 			struct xen_netif_tx_response *txrsp;
 
-			txrsp = RING_GET_RESPONSE(&np->tx, cons);
+			txrsp = RING_GET_RESPONSE(&queue->tx, cons);
 			if (txrsp->status == XEN_NETIF_RSP_NULL)
 				continue;
 
 			id  = txrsp->id;
-			skb = np->tx_skbs[id].skb;
+			skb = queue->tx_skbs[id].skb;
 			if (unlikely(gnttab_query_foreign_access(
-				np->grant_tx_ref[id]) != 0)) {
+				queue->grant_tx_ref[id]) != 0)) {
 				pr_alert("%s: warning -- grant still in use by backend domain\n",
 					 __func__);
 				BUG();
 			}
 			gnttab_end_foreign_access_ref(
-				np->grant_tx_ref[id], GNTMAP_readonly);
+				queue->grant_tx_ref[id], GNTMAP_readonly);
 			gnttab_release_grant_reference(
-				&np->gref_tx_head, np->grant_tx_ref[id]);
-			np->grant_tx_ref[id] = GRANT_INVALID_REF;
-			np->grant_tx_page[id] = NULL;
-			add_id_to_freelist(&np->tx_skb_freelist, np->tx_skbs, id);
+				&queue->gref_tx_head, queue->grant_tx_ref[id]);
+			queue->grant_tx_ref[id] = GRANT_INVALID_REF;
+			queue->grant_tx_page[id] = NULL;
+			add_id_to_freelist(&queue->tx_skb_freelist, queue->tx_skbs, id);
 			dev_kfree_skb_irq(skb);
 		}
 
-		np->tx.rsp_cons = prod;
+		queue->tx.rsp_cons = prod;
 
 		/*
 		 * Set a new event, then check for race with update of tx_cons.
@@ -412,21 +434,20 @@ static void xennet_tx_buf_gc(struct net_device *dev)
 		 * data is outstanding: in such cases notification from Xen is
 		 * likely to be the only kick that we'll get.
 		 */
-		np->tx.sring->rsp_event =
-			prod + ((np->tx.sring->req_prod - prod) >> 1) + 1;
+		queue->tx.sring->rsp_event =
+			prod + ((queue->tx.sring->req_prod - prod) >> 1) + 1;
 		mb();		/* update shared area */
-	} while ((cons == prod) && (prod != np->tx.sring->rsp_prod));
+	} while ((cons == prod) && (prod != queue->tx.sring->rsp_prod));
 
-	xennet_maybe_wake_tx(dev);
+	xennet_maybe_wake_tx(queue);
 }
 
-static void xennet_make_frags(struct sk_buff *skb, struct net_device *dev,
+static void xennet_make_frags(struct sk_buff *skb, struct netfront_queue *queue,
 			      struct xen_netif_tx_request *tx)
 {
-	struct netfront_info *np = netdev_priv(dev);
 	char *data = skb->data;
 	unsigned long mfn;
-	RING_IDX prod = np->tx.req_prod_pvt;
+	RING_IDX prod = queue->tx.req_prod_pvt;
 	int frags = skb_shinfo(skb)->nr_frags;
 	unsigned int offset = offset_in_page(data);
 	unsigned int len = skb_headlen(skb);
@@ -443,19 +464,19 @@ static void xennet_make_frags(struct sk_buff *skb, struct net_device *dev,
 		data += tx->size;
 		offset = 0;
 
-		id = get_id_from_freelist(&np->tx_skb_freelist, np->tx_skbs);
-		np->tx_skbs[id].skb = skb_get(skb);
-		tx = RING_GET_REQUEST(&np->tx, prod++);
+		id = get_id_from_freelist(&queue->tx_skb_freelist, queue->tx_skbs);
+		queue->tx_skbs[id].skb = skb_get(skb);
+		tx = RING_GET_REQUEST(&queue->tx, prod++);
 		tx->id = id;
-		ref = gnttab_claim_grant_reference(&np->gref_tx_head);
+		ref = gnttab_claim_grant_reference(&queue->gref_tx_head);
 		BUG_ON((signed short)ref < 0);
 
 		mfn = virt_to_mfn(data);
-		gnttab_grant_foreign_access_ref(ref, np->xbdev->otherend_id,
+		gnttab_grant_foreign_access_ref(ref, queue->info->xbdev->otherend_id,
 						mfn, GNTMAP_readonly);
 
-		np->grant_tx_page[id] = virt_to_page(data);
-		tx->gref = np->grant_tx_ref[id] = ref;
+		queue->grant_tx_page[id] = virt_to_page(data);
+		tx->gref = queue->grant_tx_ref[id] = ref;
 		tx->offset = offset;
 		tx->size = len;
 		tx->flags = 0;
@@ -487,21 +508,21 @@ static void xennet_make_frags(struct sk_buff *skb, struct net_device *dev,
 
 			tx->flags |= XEN_NETTXF_more_data;
 
-			id = get_id_from_freelist(&np->tx_skb_freelist,
-						  np->tx_skbs);
-			np->tx_skbs[id].skb = skb_get(skb);
-			tx = RING_GET_REQUEST(&np->tx, prod++);
+			id = get_id_from_freelist(&queue->tx_skb_freelist,
+						  queue->tx_skbs);
+			queue->tx_skbs[id].skb = skb_get(skb);
+			tx = RING_GET_REQUEST(&queue->tx, prod++);
 			tx->id = id;
-			ref = gnttab_claim_grant_reference(&np->gref_tx_head);
+			ref = gnttab_claim_grant_reference(&queue->gref_tx_head);
 			BUG_ON((signed short)ref < 0);
 
 			mfn = pfn_to_mfn(page_to_pfn(page));
 			gnttab_grant_foreign_access_ref(ref,
-							np->xbdev->otherend_id,
+							queue->info->xbdev->otherend_id,
 							mfn, GNTMAP_readonly);
 
-			np->grant_tx_page[id] = page;
-			tx->gref = np->grant_tx_ref[id] = ref;
+			queue->grant_tx_page[id] = page;
+			tx->gref = queue->grant_tx_ref[id] = ref;
 			tx->offset = offset;
 			tx->size = bytes;
 			tx->flags = 0;
@@ -518,7 +539,7 @@ static void xennet_make_frags(struct sk_buff *skb, struct net_device *dev,
 		}
 	}
 
-	np->tx.req_prod_pvt = prod;
+	queue->tx.req_prod_pvt = prod;
 }
 
 /*
@@ -544,6 +565,12 @@ static int xennet_count_skb_frag_slots(struct sk_buff *skb)
 	return pages;
 }
 
+static u16 xennet_select_queue(struct net_device *dev, struct sk_buff *skb)
+{
+	/* Stub for later implementation of queue selection */
+	return 0;
+}
+
 static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned short id;
@@ -559,6 +586,16 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned int offset = offset_in_page(data);
 	unsigned int len = skb_headlen(skb);
 	unsigned long flags;
+	struct netfront_queue *queue = NULL;
+	unsigned int num_queues = dev->real_num_tx_queues;
+	u16 queue_index;
+
+	/* Drop the packet if no queues are set up */
+	if (num_queues < 1)
+		goto drop;
+	/* Determine which queue to transmit this SKB on */
+	queue_index = skb_get_queue_mapping(skb);
+	queue = &np->queues[queue_index];
 
 	/* If skb->len is too big for wire format, drop skb and alert
 	 * user about misconfiguration.
@@ -578,30 +615,30 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto drop;
 	}
 
-	spin_lock_irqsave(&np->tx_lock, flags);
+	spin_lock_irqsave(&queue->tx_lock, flags);
 
 	if (unlikely(!netif_carrier_ok(dev) ||
 		     (slots > 1 && !xennet_can_sg(dev)) ||
 		     netif_needs_gso(skb, netif_skb_features(skb)))) {
-		spin_unlock_irqrestore(&np->tx_lock, flags);
+		spin_unlock_irqrestore(&queue->tx_lock, flags);
 		goto drop;
 	}
 
-	i = np->tx.req_prod_pvt;
+	i = queue->tx.req_prod_pvt;
 
-	id = get_id_from_freelist(&np->tx_skb_freelist, np->tx_skbs);
-	np->tx_skbs[id].skb = skb;
+	id = get_id_from_freelist(&queue->tx_skb_freelist, queue->tx_skbs);
+	queue->tx_skbs[id].skb = skb;
 
-	tx = RING_GET_REQUEST(&np->tx, i);
+	tx = RING_GET_REQUEST(&queue->tx, i);
 
 	tx->id   = id;
-	ref = gnttab_claim_grant_reference(&np->gref_tx_head);
+	ref = gnttab_claim_grant_reference(&queue->gref_tx_head);
 	BUG_ON((signed short)ref < 0);
 	mfn = virt_to_mfn(data);
 	gnttab_grant_foreign_access_ref(
-		ref, np->xbdev->otherend_id, mfn, GNTMAP_readonly);
-	np->grant_tx_page[id] = virt_to_page(data);
-	tx->gref = np->grant_tx_ref[id] = ref;
+		ref, queue->info->xbdev->otherend_id, mfn, GNTMAP_readonly);
+	queue->grant_tx_page[id] = virt_to_page(data);
+	tx->gref = queue->grant_tx_ref[id] = ref;
 	tx->offset = offset;
 	tx->size = len;
 
@@ -617,7 +654,7 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		struct xen_netif_extra_info *gso;
 
 		gso = (struct xen_netif_extra_info *)
-			RING_GET_REQUEST(&np->tx, ++i);
+			RING_GET_REQUEST(&queue->tx, ++i);
 
 		tx->flags |= XEN_NETTXF_extra_info;
 
@@ -632,14 +669,14 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		gso->flags = 0;
 	}
 
-	np->tx.req_prod_pvt = i + 1;
+	queue->tx.req_prod_pvt = i + 1;
 
-	xennet_make_frags(skb, dev, tx);
+	xennet_make_frags(skb, queue, tx);
 	tx->size = skb->len;
 
-	RING_PUSH_REQUESTS_AND_CHECK_NOTIFY(&np->tx, notify);
+	RING_PUSH_REQUESTS_AND_CHECK_NOTIFY(&queue->tx, notify);
 	if (notify)
-		notify_remote_via_irq(np->tx_irq);
+		notify_remote_via_irq(queue->tx_irq);
 
 	u64_stats_update_begin(&stats->syncp);
 	stats->tx_bytes += skb->len;
@@ -647,12 +684,12 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	u64_stats_update_end(&stats->syncp);
 
 	/* Note: It is not safe to access skb after xennet_tx_buf_gc()! */
-	xennet_tx_buf_gc(dev);
+	xennet_tx_buf_gc(queue);
 
-	if (!netfront_tx_slot_available(np))
-		netif_stop_queue(dev);
+	if (!netfront_tx_slot_available(queue))
+		netif_tx_stop_queue(netdev_get_tx_queue(dev, queue->id));
 
-	spin_unlock_irqrestore(&np->tx_lock, flags);
+	spin_unlock_irqrestore(&queue->tx_lock, flags);
 
 	return NETDEV_TX_OK;
 
@@ -665,32 +702,38 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 static int xennet_close(struct net_device *dev)
 {
 	struct netfront_info *np = netdev_priv(dev);
-	netif_stop_queue(np->netdev);
-	napi_disable(&np->napi);
+	unsigned int num_queues = dev->real_num_tx_queues;
+	unsigned int i;
+	struct netfront_queue *queue;
+	netif_tx_stop_all_queues(np->netdev);
+	for (i = 0; i < num_queues; ++i) {
+		queue = &np->queues[i];
+		napi_disable(&queue->napi);
+	}
 	return 0;
 }
 
-static void xennet_move_rx_slot(struct netfront_info *np, struct sk_buff *skb,
+static void xennet_move_rx_slot(struct netfront_queue *queue, struct sk_buff *skb,
 				grant_ref_t ref)
 {
-	int new = xennet_rxidx(np->rx.req_prod_pvt);
-
-	BUG_ON(np->rx_skbs[new]);
-	np->rx_skbs[new] = skb;
-	np->grant_rx_ref[new] = ref;
-	RING_GET_REQUEST(&np->rx, np->rx.req_prod_pvt)->id = new;
-	RING_GET_REQUEST(&np->rx, np->rx.req_prod_pvt)->gref = ref;
-	np->rx.req_prod_pvt++;
+	int new = xennet_rxidx(queue->rx.req_prod_pvt);
+
+	BUG_ON(queue->rx_skbs[new]);
+	queue->rx_skbs[new] = skb;
+	queue->grant_rx_ref[new] = ref;
+	RING_GET_REQUEST(&queue->rx, queue->rx.req_prod_pvt)->id = new;
+	RING_GET_REQUEST(&queue->rx, queue->rx.req_prod_pvt)->gref = ref;
+	queue->rx.req_prod_pvt++;
 }
 
-static int xennet_get_extras(struct netfront_info *np,
+static int xennet_get_extras(struct netfront_queue *queue,
 			     struct xen_netif_extra_info *extras,
 			     RING_IDX rp)
 
 {
 	struct xen_netif_extra_info *extra;
-	struct device *dev = &np->netdev->dev;
-	RING_IDX cons = np->rx.rsp_cons;
+	struct device *dev = &queue->info->netdev->dev;
+	RING_IDX cons = queue->rx.rsp_cons;
 	int err = 0;
 
 	do {
@@ -705,7 +748,7 @@ static int xennet_get_extras(struct netfront_info *np,
 		}
 
 		extra = (struct xen_netif_extra_info *)
-			RING_GET_RESPONSE(&np->rx, ++cons);
+			RING_GET_RESPONSE(&queue->rx, ++cons);
 
 		if (unlikely(!extra->type ||
 			     extra->type >= XEN_NETIF_EXTRA_TYPE_MAX)) {
@@ -718,33 +761,33 @@ static int xennet_get_extras(struct netfront_info *np,
 			       sizeof(*extra));
 		}
 
-		skb = xennet_get_rx_skb(np, cons);
-		ref = xennet_get_rx_ref(np, cons);
-		xennet_move_rx_slot(np, skb, ref);
+		skb = xennet_get_rx_skb(queue, cons);
+		ref = xennet_get_rx_ref(queue, cons);
+		xennet_move_rx_slot(queue, skb, ref);
 	} while (extra->flags & XEN_NETIF_EXTRA_FLAG_MORE);
 
-	np->rx.rsp_cons = cons;
+	queue->rx.rsp_cons = cons;
 	return err;
 }
 
-static int xennet_get_responses(struct netfront_info *np,
+static int xennet_get_responses(struct netfront_queue *queue,
 				struct netfront_rx_info *rinfo, RING_IDX rp,
 				struct sk_buff_head *list)
 {
 	struct xen_netif_rx_response *rx = &rinfo->rx;
 	struct xen_netif_extra_info *extras = rinfo->extras;
-	struct device *dev = &np->netdev->dev;
-	RING_IDX cons = np->rx.rsp_cons;
-	struct sk_buff *skb = xennet_get_rx_skb(np, cons);
-	grant_ref_t ref = xennet_get_rx_ref(np, cons);
+	struct device *dev = &queue->info->netdev->dev;
+	RING_IDX cons = queue->rx.rsp_cons;
+	struct sk_buff *skb = xennet_get_rx_skb(queue, cons);
+	grant_ref_t ref = xennet_get_rx_ref(queue, cons);
 	int max = MAX_SKB_FRAGS + (rx->status <= RX_COPY_THRESHOLD);
 	int slots = 1;
 	int err = 0;
 	unsigned long ret;
 
 	if (rx->flags & XEN_NETRXF_extra_info) {
-		err = xennet_get_extras(np, extras, rp);
-		cons = np->rx.rsp_cons;
+		err = xennet_get_extras(queue, extras, rp);
+		cons = queue->rx.rsp_cons;
 	}
 
 	for (;;) {
@@ -753,7 +796,7 @@ static int xennet_get_responses(struct netfront_info *np,
 			if (net_ratelimit())
 				dev_warn(dev, "rx->offset: %x, size: %u\n",
 					 rx->offset, rx->status);
-			xennet_move_rx_slot(np, skb, ref);
+			xennet_move_rx_slot(queue, skb, ref);
 			err = -EINVAL;
 			goto next;
 		}
@@ -774,7 +817,7 @@ static int xennet_get_responses(struct netfront_info *np,
 		ret = gnttab_end_foreign_access_ref(ref, 0);
 		BUG_ON(!ret);
 
-		gnttab_release_grant_reference(&np->gref_rx_head, ref);
+		gnttab_release_grant_reference(&queue->gref_rx_head, ref);
 
 		__skb_queue_tail(list, skb);
 
@@ -789,9 +832,9 @@ next:
 			break;
 		}
 
-		rx = RING_GET_RESPONSE(&np->rx, cons + slots);
-		skb = xennet_get_rx_skb(np, cons + slots);
-		ref = xennet_get_rx_ref(np, cons + slots);
+		rx = RING_GET_RESPONSE(&queue->rx, cons + slots);
+		skb = xennet_get_rx_skb(queue, cons + slots);
+		ref = xennet_get_rx_ref(queue, cons + slots);
 		slots++;
 	}
 
@@ -802,7 +845,7 @@ next:
 	}
 
 	if (unlikely(err))
-		np->rx.rsp_cons = cons + slots;
+		queue->rx.rsp_cons = cons + slots;
 
 	return err;
 }
@@ -836,17 +879,17 @@ static int xennet_set_skb_gso(struct sk_buff *skb,
 	return 0;
 }
 
-static RING_IDX xennet_fill_frags(struct netfront_info *np,
+static RING_IDX xennet_fill_frags(struct netfront_queue *queue,
 				  struct sk_buff *skb,
 				  struct sk_buff_head *list)
 {
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
-	RING_IDX cons = np->rx.rsp_cons;
+	RING_IDX cons = queue->rx.rsp_cons;
 	struct sk_buff *nskb;
 
 	while ((nskb = __skb_dequeue(list))) {
 		struct xen_netif_rx_response *rx =
-			RING_GET_RESPONSE(&np->rx, ++cons);
+			RING_GET_RESPONSE(&queue->rx, ++cons);
 		skb_frag_t *nfrag = &skb_shinfo(nskb)->frags[0];
 
 		if (shinfo->nr_frags == MAX_SKB_FRAGS) {
@@ -879,7 +922,7 @@ static int checksum_setup(struct net_device *dev, struct sk_buff *skb)
 	 */
 	if (skb->ip_summed != CHECKSUM_PARTIAL && skb_is_gso(skb)) {
 		struct netfront_info *np = netdev_priv(dev);
-		np->rx_gso_checksum_fixup++;
+		atomic_inc(&np->rx_gso_checksum_fixup);
 		skb->ip_summed = CHECKSUM_PARTIAL;
 		recalculate_partial_csum = true;
 	}
@@ -891,11 +934,10 @@ static int checksum_setup(struct net_device *dev, struct sk_buff *skb)
 	return skb_checksum_setup(skb, recalculate_partial_csum);
 }
 
-static int handle_incoming_queue(struct net_device *dev,
+static int handle_incoming_queue(struct netfront_queue *queue,
 				 struct sk_buff_head *rxq)
 {
-	struct netfront_info *np = netdev_priv(dev);
-	struct netfront_stats *stats = this_cpu_ptr(np->stats);
+	struct netfront_stats *stats = this_cpu_ptr(queue->info->stats);
 	int packets_dropped = 0;
 	struct sk_buff *skb;
 
@@ -906,13 +948,13 @@ static int handle_incoming_queue(struct net_device *dev,
 			__pskb_pull_tail(skb, pull_to - skb_headlen(skb));
 
 		/* Ethernet work: Delayed to here as it peeks the header. */
-		skb->protocol = eth_type_trans(skb, dev);
+		skb->protocol = eth_type_trans(skb, queue->info->netdev);
 		skb_reset_network_header(skb);
 
-		if (checksum_setup(dev, skb)) {
+		if (checksum_setup(queue->info->netdev, skb)) {
 			kfree_skb(skb);
 			packets_dropped++;
-			dev->stats.rx_errors++;
+			queue->info->netdev->stats.rx_errors++;
 			continue;
 		}
 
@@ -922,7 +964,7 @@ static int handle_incoming_queue(struct net_device *dev,
 		u64_stats_update_end(&stats->syncp);
 
 		/* Pass it up. */
-		napi_gro_receive(&np->napi, skb);
+		napi_gro_receive(&queue->napi, skb);
 	}
 
 	return packets_dropped;
@@ -930,8 +972,8 @@ static int handle_incoming_queue(struct net_device *dev,
 
 static int xennet_poll(struct napi_struct *napi, int budget)
 {
-	struct netfront_info *np = container_of(napi, struct netfront_info, napi);
-	struct net_device *dev = np->netdev;
+	struct netfront_queue *queue = container_of(napi, struct netfront_queue, napi);
+	struct net_device *dev = queue->info->netdev;
 	struct sk_buff *skb;
 	struct netfront_rx_info rinfo;
 	struct xen_netif_rx_response *rx = &rinfo.rx;
@@ -944,29 +986,29 @@ static int xennet_poll(struct napi_struct *napi, int budget)
 	unsigned long flags;
 	int err;
 
-	spin_lock(&np->rx_lock);
+	spin_lock(&queue->rx_lock);
 
 	skb_queue_head_init(&rxq);
 	skb_queue_head_init(&errq);
 	skb_queue_head_init(&tmpq);
 
-	rp = np->rx.sring->rsp_prod;
+	rp = queue->rx.sring->rsp_prod;
 	rmb(); /* Ensure we see queued responses up to 'rp'. */
 
-	i = np->rx.rsp_cons;
+	i = queue->rx.rsp_cons;
 	work_done = 0;
 	while ((i != rp) && (work_done < budget)) {
-		memcpy(rx, RING_GET_RESPONSE(&np->rx, i), sizeof(*rx));
+		memcpy(rx, RING_GET_RESPONSE(&queue->rx, i), sizeof(*rx));
 		memset(extras, 0, sizeof(rinfo.extras));
 
-		err = xennet_get_responses(np, &rinfo, rp, &tmpq);
+		err = xennet_get_responses(queue, &rinfo, rp, &tmpq);
 
 		if (unlikely(err)) {
 err:
 			while ((skb = __skb_dequeue(&tmpq)))
 				__skb_queue_tail(&errq, skb);
 			dev->stats.rx_errors++;
-			i = np->rx.rsp_cons;
+			i = queue->rx.rsp_cons;
 			continue;
 		}
 
@@ -978,7 +1020,7 @@ err:
 
 			if (unlikely(xennet_set_skb_gso(skb, gso))) {
 				__skb_queue_head(&tmpq, skb);
-				np->rx.rsp_cons += skb_queue_len(&tmpq);
+				queue->rx.rsp_cons += skb_queue_len(&tmpq);
 				goto err;
 			}
 		}
@@ -992,7 +1034,7 @@ err:
 		skb->data_len = rx->status;
 		skb->len += rx->status;
 
-		i = xennet_fill_frags(np, skb, &tmpq);
+		i = xennet_fill_frags(queue, skb, &tmpq);
 
 		if (rx->flags & XEN_NETRXF_csum_blank)
 			skb->ip_summed = CHECKSUM_PARTIAL;
@@ -1001,22 +1043,22 @@ err:
 
 		__skb_queue_tail(&rxq, skb);
 
-		np->rx.rsp_cons = ++i;
+		queue->rx.rsp_cons = ++i;
 		work_done++;
 	}
 
 	__skb_queue_purge(&errq);
 
-	work_done -= handle_incoming_queue(dev, &rxq);
+	work_done -= handle_incoming_queue(queue, &rxq);
 
 	/* If we get a callback with very few responses, reduce fill target. */
 	/* NB. Note exponential increase, linear decrease. */
-	if (((np->rx.req_prod_pvt - np->rx.sring->rsp_prod) >
-	     ((3*np->rx_target) / 4)) &&
-	    (--np->rx_target < np->rx_min_target))
-		np->rx_target = np->rx_min_target;
+	if (((queue->rx.req_prod_pvt - queue->rx.sring->rsp_prod) >
+	     ((3*queue->rx_target) / 4)) &&
+	    (--queue->rx_target < queue->rx_min_target))
+		queue->rx_target = queue->rx_min_target;
 
-	xennet_alloc_rx_buffers(dev);
+	xennet_alloc_rx_buffers(queue);
 
 	if (work_done < budget) {
 		int more_to_do = 0;
@@ -1025,14 +1067,14 @@ err:
 
 		local_irq_save(flags);
 
-		RING_FINAL_CHECK_FOR_RESPONSES(&np->rx, more_to_do);
+		RING_FINAL_CHECK_FOR_RESPONSES(&queue->rx, more_to_do);
 		if (!more_to_do)
 			__napi_complete(napi);
 
 		local_irq_restore(flags);
 	}
 
-	spin_unlock(&np->rx_lock);
+	spin_unlock(&queue->rx_lock);
 
 	return work_done;
 }
@@ -1080,43 +1122,43 @@ static struct rtnl_link_stats64 *xennet_get_stats64(struct net_device *dev,
 	return tot;
 }
 
-static void xennet_release_tx_bufs(struct netfront_info *np)
+static void xennet_release_tx_bufs(struct netfront_queue *queue)
 {
 	struct sk_buff *skb;
 	int i;
 
 	for (i = 0; i < NET_TX_RING_SIZE; i++) {
 		/* Skip over entries which are actually freelist references */
-		if (skb_entry_is_link(&np->tx_skbs[i]))
+		if (skb_entry_is_link(&queue->tx_skbs[i]))
 			continue;
 
-		skb = np->tx_skbs[i].skb;
-		get_page(np->grant_tx_page[i]);
-		gnttab_end_foreign_access(np->grant_tx_ref[i],
+		skb = queue->tx_skbs[i].skb;
+		get_page(queue->grant_tx_page[i]);
+		gnttab_end_foreign_access(queue->grant_tx_ref[i],
 					  GNTMAP_readonly,
-					  (unsigned long)page_address(np->grant_tx_page[i]));
-		np->grant_tx_page[i] = NULL;
-		np->grant_tx_ref[i] = GRANT_INVALID_REF;
-		add_id_to_freelist(&np->tx_skb_freelist, np->tx_skbs, i);
+					  (unsigned long)page_address(queue->grant_tx_page[i]));
+		queue->grant_tx_page[i] = NULL;
+		queue->grant_tx_ref[i] = GRANT_INVALID_REF;
+		add_id_to_freelist(&queue->tx_skb_freelist, queue->tx_skbs, i);
 		dev_kfree_skb_irq(skb);
 	}
 }
 
-static void xennet_release_rx_bufs(struct netfront_info *np)
+static void xennet_release_rx_bufs(struct netfront_queue *queue)
 {
 	int id, ref;
 
-	spin_lock_bh(&np->rx_lock);
+	spin_lock_bh(&queue->rx_lock);
 
 	for (id = 0; id < NET_RX_RING_SIZE; id++) {
 		struct sk_buff *skb;
 		struct page *page;
 
-		skb = np->rx_skbs[id];
+		skb = queue->rx_skbs[id];
 		if (!skb)
 			continue;
 
-		ref = np->grant_rx_ref[id];
+		ref = queue->grant_rx_ref[id];
 		if (ref == GRANT_INVALID_REF)
 			continue;
 
@@ -1128,21 +1170,28 @@ static void xennet_release_rx_bufs(struct netfront_info *np)
 		get_page(page);
 		gnttab_end_foreign_access(ref, 0,
 					  (unsigned long)page_address(page));
-		np->grant_rx_ref[id] = GRANT_INVALID_REF;
+		queue->grant_rx_ref[id] = GRANT_INVALID_REF;
 
 		kfree_skb(skb);
 	}
 
-	spin_unlock_bh(&np->rx_lock);
+	spin_unlock_bh(&queue->rx_lock);
 }
 
 static void xennet_uninit(struct net_device *dev)
 {
 	struct netfront_info *np = netdev_priv(dev);
-	xennet_release_tx_bufs(np);
-	xennet_release_rx_bufs(np);
-	gnttab_free_grant_references(np->gref_tx_head);
-	gnttab_free_grant_references(np->gref_rx_head);
+	unsigned int num_queues = dev->real_num_tx_queues;
+	struct netfront_queue *queue;
+	unsigned int i;
+
+	for (i = 0; i < num_queues; ++i) {
+		queue = &np->queues[i];
+		xennet_release_tx_bufs(queue);
+		xennet_release_rx_bufs(queue);
+		gnttab_free_grant_references(queue->gref_tx_head);
+		gnttab_free_grant_references(queue->gref_rx_head);
+	}
 }
 
 static netdev_features_t xennet_fix_features(struct net_device *dev,
@@ -1203,25 +1252,24 @@ static int xennet_set_features(struct net_device *dev,
 
 static irqreturn_t xennet_tx_interrupt(int irq, void *dev_id)
 {
-	struct netfront_info *np = dev_id;
-	struct net_device *dev = np->netdev;
+	struct netfront_queue *queue = dev_id;
 	unsigned long flags;
 
-	spin_lock_irqsave(&np->tx_lock, flags);
-	xennet_tx_buf_gc(dev);
-	spin_unlock_irqrestore(&np->tx_lock, flags);
+	spin_lock_irqsave(&queue->tx_lock, flags);
+	xennet_tx_buf_gc(queue);
+	spin_unlock_irqrestore(&queue->tx_lock, flags);
 
 	return IRQ_HANDLED;
 }
 
 static irqreturn_t xennet_rx_interrupt(int irq, void *dev_id)
 {
-	struct netfront_info *np = dev_id;
-	struct net_device *dev = np->netdev;
+	struct netfront_queue *queue = dev_id;
+	struct net_device *dev = queue->info->netdev;
 
 	if (likely(netif_carrier_ok(dev) &&
-		   RING_HAS_UNCONSUMED_RESPONSES(&np->rx)))
-			napi_schedule(&np->napi);
+		   RING_HAS_UNCONSUMED_RESPONSES(&queue->rx)))
+			napi_schedule(&queue->napi);
 
 	return IRQ_HANDLED;
 }
@@ -1236,7 +1284,12 @@ static irqreturn_t xennet_interrupt(int irq, void *dev_id)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void xennet_poll_controller(struct net_device *dev)
 {
-	xennet_interrupt(0, dev);
+	/* Poll each queue */
+	struct netfront_info *info = netdev_priv(dev);
+	unsigned int num_queues = dev->real_num_tx_queues;
+	unsigned int i;
+	for (i = 0; i < num_queues; ++i)
+		xennet_interrupt(0, &info->queues[i]);
 }
 #endif
 
@@ -1251,6 +1304,7 @@ static const struct net_device_ops xennet_netdev_ops = {
 	.ndo_validate_addr   = eth_validate_addr,
 	.ndo_fix_features    = xennet_fix_features,
 	.ndo_set_features    = xennet_set_features,
+	.ndo_select_queue    = xennet_select_queue,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = xennet_poll_controller,
 #endif
@@ -1258,66 +1312,30 @@ static const struct net_device_ops xennet_netdev_ops = {
 
 static struct net_device *xennet_create_dev(struct xenbus_device *dev)
 {
-	int i, err;
+	int err;
 	struct net_device *netdev;
 	struct netfront_info *np;
 
-	netdev = alloc_etherdev(sizeof(struct netfront_info));
+	netdev = alloc_etherdev_mq(sizeof(struct netfront_info), 1);
 	if (!netdev)
 		return ERR_PTR(-ENOMEM);
 
 	np                   = netdev_priv(netdev);
 	np->xbdev            = dev;
 
-	spin_lock_init(&np->tx_lock);
-	spin_lock_init(&np->rx_lock);
-
-	skb_queue_head_init(&np->rx_batch);
-	np->rx_target     = RX_DFL_MIN_TARGET;
-	np->rx_min_target = RX_DFL_MIN_TARGET;
-	np->rx_max_target = RX_MAX_TARGET;
-
-	init_timer(&np->rx_refill_timer);
-	np->rx_refill_timer.data = (unsigned long)netdev;
-	np->rx_refill_timer.function = rx_refill_timeout;
+	/* No need to use rtnl_lock() before the call below as it
+	 * happens before register_netdev().
+	 */
+	netif_set_real_num_tx_queues(netdev, 0);
+	np->queues = NULL;
 
 	err = -ENOMEM;
 	np->stats = netdev_alloc_pcpu_stats(struct netfront_stats);
 	if (np->stats == NULL)
 		goto exit;
 
-	/* Initialise tx_skbs as a free chain containing every entry. */
-	np->tx_skb_freelist = 0;
-	for (i = 0; i < NET_TX_RING_SIZE; i++) {
-		skb_entry_set_link(&np->tx_skbs[i], i+1);
-		np->grant_tx_ref[i] = GRANT_INVALID_REF;
-		np->grant_tx_page[i] = NULL;
-	}
-
-	/* Clear out rx_skbs */
-	for (i = 0; i < NET_RX_RING_SIZE; i++) {
-		np->rx_skbs[i] = NULL;
-		np->grant_rx_ref[i] = GRANT_INVALID_REF;
-	}
-
-	/* A grant for every tx ring slot */
-	if (gnttab_alloc_grant_references(TX_MAX_TARGET,
-					  &np->gref_tx_head) < 0) {
-		pr_alert("can't alloc tx grant refs\n");
-		err = -ENOMEM;
-		goto exit_free_stats;
-	}
-	/* A grant for every rx ring slot */
-	if (gnttab_alloc_grant_references(RX_MAX_TARGET,
-					  &np->gref_rx_head) < 0) {
-		pr_alert("can't alloc rx grant refs\n");
-		err = -ENOMEM;
-		goto exit_free_tx;
-	}
-
 	netdev->netdev_ops	= &xennet_netdev_ops;
 
-	netif_napi_add(netdev, &np->napi, xennet_poll, 64);
 	netdev->features        = NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
 				  NETIF_F_GSO_ROBUST;
 	netdev->hw_features	= NETIF_F_SG |
@@ -1343,10 +1361,6 @@ static struct net_device *xennet_create_dev(struct xenbus_device *dev)
 
 	return netdev;
 
- exit_free_tx:
-	gnttab_free_grant_references(np->gref_tx_head);
- exit_free_stats:
-	free_percpu(np->stats);
  exit:
 	free_netdev(netdev);
 	return ERR_PTR(err);
@@ -1404,30 +1418,36 @@ static void xennet_end_access(int ref, void *page)
 
 static void xennet_disconnect_backend(struct netfront_info *info)
 {
-	/* Stop old i/f to prevent errors whilst we rebuild the state. */
-	spin_lock_bh(&info->rx_lock);
-	spin_lock_irq(&info->tx_lock);
-	netif_carrier_off(info->netdev);
-	spin_unlock_irq(&info->tx_lock);
-	spin_unlock_bh(&info->rx_lock);
-
-	if (info->tx_irq && (info->tx_irq == info->rx_irq))
-		unbind_from_irqhandler(info->tx_irq, info);
-	if (info->tx_irq && (info->tx_irq != info->rx_irq)) {
-		unbind_from_irqhandler(info->tx_irq, info);
-		unbind_from_irqhandler(info->rx_irq, info);
-	}
-	info->tx_evtchn = info->rx_evtchn = 0;
-	info->tx_irq = info->rx_irq = 0;
+	unsigned int i = 0;
+	struct netfront_queue *queue = NULL;
+	unsigned int num_queues = info->netdev->real_num_tx_queues;
+
+	for (i = 0; i < num_queues; ++i) {
+		/* Stop old i/f to prevent errors whilst we rebuild the state. */
+		spin_lock_bh(&queue->rx_lock);
+		spin_lock_irq(&queue->tx_lock);
+		netif_carrier_off(queue->info->netdev);
+		spin_unlock_irq(&queue->tx_lock);
+		spin_unlock_bh(&queue->rx_lock);
+
+		if (queue->tx_irq && (queue->tx_irq == queue->rx_irq))
+			unbind_from_irqhandler(queue->tx_irq, queue);
+		if (queue->tx_irq && (queue->tx_irq != queue->rx_irq)) {
+			unbind_from_irqhandler(queue->tx_irq, queue);
+			unbind_from_irqhandler(queue->rx_irq, queue);
+		}
+		queue->tx_evtchn = queue->rx_evtchn = 0;
+		queue->tx_irq = queue->rx_irq = 0;
 
-	/* End access and free the pages */
-	xennet_end_access(info->tx_ring_ref, info->tx.sring);
-	xennet_end_access(info->rx_ring_ref, info->rx.sring);
+		/* End access and free the pages */
+		xennet_end_access(queue->tx_ring_ref, queue->tx.sring);
+		xennet_end_access(queue->rx_ring_ref, queue->rx.sring);
 
-	info->tx_ring_ref = GRANT_INVALID_REF;
-	info->rx_ring_ref = GRANT_INVALID_REF;
-	info->tx.sring = NULL;
-	info->rx.sring = NULL;
+		queue->tx_ring_ref = GRANT_INVALID_REF;
+		queue->rx_ring_ref = GRANT_INVALID_REF;
+		queue->tx.sring = NULL;
+		queue->rx.sring = NULL;
+	}
 }
 
 /**
@@ -1468,100 +1488,86 @@ static int xen_net_read_mac(struct xenbus_device *dev, u8 mac[])
 	return 0;
 }
 
-static int setup_netfront_single(struct netfront_info *info)
+static int setup_netfront_single(struct netfront_queue *queue)
 {
 	int err;
 
-	err = xenbus_alloc_evtchn(info->xbdev, &info->tx_evtchn);
+	err = xenbus_alloc_evtchn(queue->info->xbdev, &queue->tx_evtchn);
 	if (err < 0)
 		goto fail;
 
-	err = bind_evtchn_to_irqhandler(info->tx_evtchn,
+	err = bind_evtchn_to_irqhandler(queue->tx_evtchn,
 					xennet_interrupt,
-					0, info->netdev->name, info);
+					0, queue->info->netdev->name, queue);
 	if (err < 0)
 		goto bind_fail;
-	info->rx_evtchn = info->tx_evtchn;
-	info->rx_irq = info->tx_irq = err;
+	queue->rx_evtchn = queue->tx_evtchn;
+	queue->rx_irq = queue->tx_irq = err;
 
 	return 0;
 
 bind_fail:
-	xenbus_free_evtchn(info->xbdev, info->tx_evtchn);
-	info->tx_evtchn = 0;
+	xenbus_free_evtchn(queue->info->xbdev, queue->tx_evtchn);
+	queue->tx_evtchn = 0;
 fail:
 	return err;
 }
 
-static int setup_netfront_split(struct netfront_info *info)
+static int setup_netfront_split(struct netfront_queue *queue)
 {
 	int err;
 
-	err = xenbus_alloc_evtchn(info->xbdev, &info->tx_evtchn);
+	err = xenbus_alloc_evtchn(queue->info->xbdev, &queue->tx_evtchn);
 	if (err < 0)
 		goto fail;
-	err = xenbus_alloc_evtchn(info->xbdev, &info->rx_evtchn);
+	err = xenbus_alloc_evtchn(queue->info->xbdev, &queue->rx_evtchn);
 	if (err < 0)
 		goto alloc_rx_evtchn_fail;
 
-	snprintf(info->tx_irq_name, sizeof(info->tx_irq_name),
-		 "%s-tx", info->netdev->name);
-	err = bind_evtchn_to_irqhandler(info->tx_evtchn,
+	snprintf(queue->tx_irq_name, sizeof(queue->tx_irq_name),
+		 "%s-tx", queue->name);
+	err = bind_evtchn_to_irqhandler(queue->tx_evtchn,
 					xennet_tx_interrupt,
-					0, info->tx_irq_name, info);
+					0, queue->tx_irq_name, queue);
 	if (err < 0)
 		goto bind_tx_fail;
-	info->tx_irq = err;
+	queue->tx_irq = err;
 
-	snprintf(info->rx_irq_name, sizeof(info->rx_irq_name),
-		 "%s-rx", info->netdev->name);
-	err = bind_evtchn_to_irqhandler(info->rx_evtchn,
+	snprintf(queue->rx_irq_name, sizeof(queue->rx_irq_name),
+		 "%s-rx", queue->name);
+	err = bind_evtchn_to_irqhandler(queue->rx_evtchn,
 					xennet_rx_interrupt,
-					0, info->rx_irq_name, info);
+					0, queue->rx_irq_name, queue);
 	if (err < 0)
 		goto bind_rx_fail;
-	info->rx_irq = err;
+	queue->rx_irq = err;
 
 	return 0;
 
 bind_rx_fail:
-	unbind_from_irqhandler(info->tx_irq, info);
-	info->tx_irq = 0;
+	unbind_from_irqhandler(queue->tx_irq, queue);
+	queue->tx_irq = 0;
 bind_tx_fail:
-	xenbus_free_evtchn(info->xbdev, info->rx_evtchn);
-	info->rx_evtchn = 0;
+	xenbus_free_evtchn(queue->info->xbdev, queue->rx_evtchn);
+	queue->rx_evtchn = 0;
 alloc_rx_evtchn_fail:
-	xenbus_free_evtchn(info->xbdev, info->tx_evtchn);
-	info->tx_evtchn = 0;
+	xenbus_free_evtchn(queue->info->xbdev, queue->tx_evtchn);
+	queue->tx_evtchn = 0;
 fail:
 	return err;
 }
 
-static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
+static int setup_netfront(struct xenbus_device *dev,
+			struct netfront_queue *queue, unsigned int feature_split_evtchn)
 {
 	struct xen_netif_tx_sring *txs;
 	struct xen_netif_rx_sring *rxs;
 	int err;
-	struct net_device *netdev = info->netdev;
-	unsigned int feature_split_evtchn;
 
-	info->tx_ring_ref = GRANT_INVALID_REF;
-	info->rx_ring_ref = GRANT_INVALID_REF;
-	info->rx.sring = NULL;
-	info->tx.sring = NULL;
-	netdev->irq = 0;
-
-	err = xenbus_scanf(XBT_NIL, info->xbdev->otherend,
-			   "feature-split-event-channels", "%u",
-			   &feature_split_evtchn);
-	if (err < 0)
-		feature_split_evtchn = 0;
-
-	err = xen_net_read_mac(dev, netdev->dev_addr);
-	if (err) {
-		xenbus_dev_fatal(dev, err, "parsing %s/mac", dev->nodename);
-		goto fail;
-	}
+	queue->tx_ring_ref = GRANT_INVALID_REF;
+	queue->rx_ring_ref = GRANT_INVALID_REF;
+	queue->rx.sring = NULL;
+	queue->tx.sring = NULL;
 
 	txs = (struct xen_netif_tx_sring *)get_zeroed_page(GFP_NOIO | __GFP_HIGH);
 	if (!txs) {
@@ -1570,13 +1576,13 @@ static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
 		goto fail;
 	}
 	SHARED_RING_INIT(txs);
-	FRONT_RING_INIT(&info->tx, txs, PAGE_SIZE);
+	FRONT_RING_INIT(&queue->tx, txs, PAGE_SIZE);
 
 	err = xenbus_grant_ring(dev, virt_to_mfn(txs));
 	if (err < 0)
 		goto grant_tx_ring_fail;
+	queue->tx_ring_ref = err;
 
-	info->tx_ring_ref = err;
 	rxs = (struct xen_netif_rx_sring *)get_zeroed_page(GFP_NOIO | __GFP_HIGH);
 	if (!rxs) {
 		err = -ENOMEM;
@@ -1584,21 +1590,21 @@ static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
 		goto alloc_rx_ring_fail;
 	}
 	SHARED_RING_INIT(rxs);
-	FRONT_RING_INIT(&info->rx, rxs, PAGE_SIZE);
+	FRONT_RING_INIT(&queue->rx, rxs, PAGE_SIZE);
 
 	err = xenbus_grant_ring(dev, virt_to_mfn(rxs));
 	if (err < 0)
 		goto grant_rx_ring_fail;
-	info->rx_ring_ref = err;
+	queue->rx_ring_ref = err;
 
 	if (feature_split_evtchn)
-		err = setup_netfront_split(info);
+		err = setup_netfront_split(queue);
 	/* setup single event channel if
 	 *  a) feature-split-event-channels == 0
 	 *  b) feature-split-event-channels == 1 but failed to setup
 	 */
 	if (!feature_split_evtchn || (feature_split_evtchn && err))
-		err = setup_netfront_single(info);
+		err = setup_netfront_single(queue);
 
 	if (err)
 		goto alloc_evtchn_fail;
@@ -1609,17 +1615,78 @@ static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
 	 * granted pages because backend is not accessing it at this point.
 	 */
 alloc_evtchn_fail:
-	gnttab_end_foreign_access_ref(info->rx_ring_ref, 0);
+	gnttab_end_foreign_access_ref(queue->rx_ring_ref, 0);
 grant_rx_ring_fail:
 	free_page((unsigned long)rxs);
 alloc_rx_ring_fail:
-	gnttab_end_foreign_access_ref(info->tx_ring_ref, 0);
+	gnttab_end_foreign_access_ref(queue->tx_ring_ref, 0);
 grant_tx_ring_fail:
 	free_page((unsigned long)txs);
 fail:
 	return err;
 }
 
+/* Queue-specific initialisation
+ * This used to be done in xennet_create_dev() but must now
+ * be run per-queue.
+ */
+static int xennet_init_queue(struct netfront_queue *queue)
+{
+	unsigned short i;
+	int err = 0;
+
+	spin_lock_init(&queue->tx_lock);
+	spin_lock_init(&queue->rx_lock);
+
+	skb_queue_head_init(&queue->rx_batch);
+	queue->rx_target     = RX_DFL_MIN_TARGET;
+	queue->rx_min_target = RX_DFL_MIN_TARGET;
+	queue->rx_max_target = RX_MAX_TARGET;
+
+	init_timer(&queue->rx_refill_timer);
+	queue->rx_refill_timer.data = (unsigned long)queue;
+	queue->rx_refill_timer.function = rx_refill_timeout;
+
+	/* Initialise tx_skbs as a free chain containing every entry. */
+	queue->tx_skb_freelist = 0;
+	for (i = 0; i < NET_TX_RING_SIZE; i++) {
+		skb_entry_set_link(&queue->tx_skbs[i], i+1);
+		queue->grant_tx_ref[i] = GRANT_INVALID_REF;
+		queue->grant_tx_page[i] = NULL;
+	}
+
+	/* Clear out rx_skbs */
+	for (i = 0; i < NET_RX_RING_SIZE; i++) {
+		queue->rx_skbs[i] = NULL;
+		queue->grant_rx_ref[i] = GRANT_INVALID_REF;
+	}
+
+	/* A grant for every tx ring slot */
+	if (gnttab_alloc_grant_references(TX_MAX_TARGET,
+					  &queue->gref_tx_head) < 0) {
+		pr_alert("can't alloc tx grant refs\n");
+		err = -ENOMEM;
+		goto exit;
+	}
+
+	/* A grant for every rx ring slot */
+	if (gnttab_alloc_grant_references(RX_MAX_TARGET,
+					  &queue->gref_rx_head) < 0) {
+		pr_alert("can't alloc rx grant refs\n");
+		err = -ENOMEM;
+		goto exit_free_tx;
+	}
+
+	netif_napi_add(queue->info->netdev, &queue->napi, xennet_poll, 64);
+
+	return 0;
+
+ exit_free_tx:
+	gnttab_free_grant_references(queue->gref_tx_head);
+ exit:
+	return err;
+}
+
 /* Common code used when first setting up, and when resuming. */
 static int talk_to_netback(struct xenbus_device *dev,
 			   struct netfront_info *info)
@@ -1627,13 +1694,79 @@ static int talk_to_netback(struct xenbus_device *dev,
 	const char *message;
 	struct xenbus_transaction xbt;
 	int err;
+	unsigned int feature_split_evtchn;
+	unsigned int i = 0;
+	struct netfront_queue *queue = NULL;
+	unsigned int num_queues = 1;
 
-	/* Create shared ring, alloc event channel. */
-	err = setup_netfront(dev, info);
-	if (err)
+	info->netdev->irq = 0;
+
+	/* Check feature-split-event-channels */
+	err = xenbus_scanf(XBT_NIL, info->xbdev->otherend,
+			   "feature-split-event-channels", "%u",
+			   &feature_split_evtchn);
+	if (err < 0)
+		feature_split_evtchn = 0;
+
+	/* Read mac addr. */
+	err = xen_net_read_mac(dev, info->netdev->dev_addr);
+	if (err) {
+		xenbus_dev_fatal(dev, err, "parsing %s/mac", dev->nodename);
+		goto out;
+	}
+
+	/* Allocate array of queues */
+	info->queues = kcalloc(num_queues, sizeof(struct netfront_queue), GFP_KERNEL);
+	if (!info->queues) {
+		err = -ENOMEM;
 		goto out;
+	}
+	rtnl_lock();
+	netif_set_real_num_tx_queues(info->netdev, num_queues);
+	rtnl_unlock();
+
+	/* Create shared ring, alloc event channel -- for each queue */
+	for (i = 0; i < num_queues; ++i) {
+		queue = &info->queues[i];
+		queue->id = i;
+		queue->info = info;
+		err = xennet_init_queue(queue);
+		if (err) {
+			/* xennet_init_queue() cleans up after itself on failure,
+			 * but we still have to clean up any previously initialised
+			 * queues. If i > 0, set num_queues to i, then goto
+			 * destroy_ring, which calls xennet_disconnect_backend()
+			 * to tidy up.
+			 */
+			if (i > 0) {
+				rtnl_lock();
+				netif_set_real_num_tx_queues(info->netdev, i);
+				rtnl_unlock();
+				goto destroy_ring;
+			} else {
+				goto out;
+			}
+		}
+		err = setup_netfront(dev, queue, feature_split_evtchn);
+		if (err) {
+			/* As for xennet_init_queue(), setup_netfront() will tidy
+			 * up the current queue on error, but we need to clean up
+			 * those already allocated.
+			 */
+			if (i > 0) {
+				rtnl_lock();
+				netif_set_real_num_tx_queues(info->netdev, i);
+				rtnl_unlock();
+				goto destroy_ring;
+			} else {
+				goto out;
+			}
+		}
+	}
 
 again:
+	queue = &info->queues[0]; /* Use first queue only */
+
 	err = xenbus_transaction_start(&xbt);
 	if (err) {
 		xenbus_dev_fatal(dev, err, "starting transaction");
@@ -1641,34 +1774,34 @@ again:
 	}
 
 	err = xenbus_printf(xbt, dev->nodename, "tx-ring-ref", "%u",
-			    info->tx_ring_ref);
+			    queue->tx_ring_ref);
 	if (err) {
 		message = "writing tx ring-ref";
 		goto abort_transaction;
 	}
 	err = xenbus_printf(xbt, dev->nodename, "rx-ring-ref", "%u",
-			    info->rx_ring_ref);
+			    queue->rx_ring_ref);
 	if (err) {
 		message = "writing rx ring-ref";
 		goto abort_transaction;
 	}
 
-	if (info->tx_evtchn == info->rx_evtchn) {
+	if (queue->tx_evtchn == queue->rx_evtchn) {
 		err = xenbus_printf(xbt, dev->nodename,
-				    "event-channel", "%u", info->tx_evtchn);
+				    "event-channel", "%u", queue->tx_evtchn);
 		if (err) {
 			message = "writing event-channel";
 			goto abort_transaction;
 		}
 	} else {
 		err = xenbus_printf(xbt, dev->nodename,
-				    "event-channel-tx", "%u", info->tx_evtchn);
+				    "event-channel-tx", "%u", queue->tx_evtchn);
 		if (err) {
 			message = "writing event-channel-tx";
 			goto abort_transaction;
 		}
 		err = xenbus_printf(xbt, dev->nodename,
-				    "event-channel-rx", "%u", info->rx_evtchn);
+				    "event-channel-rx", "%u", queue->rx_evtchn);
 		if (err) {
 			message = "writing event-channel-rx";
 			goto abort_transaction;
@@ -1728,6 +1861,11 @@ again:
 	xenbus_dev_fatal(dev, err, "%s", message);
  destroy_ring:
 	xennet_disconnect_backend(info);
+	kfree(info->queues);
+	info->queues = NULL;
+	rtnl_lock();
+	netif_set_real_num_tx_queues(info->netdev, 0);
+	rtnl_lock();
  out:
 	return err;
 }
@@ -1735,11 +1873,14 @@ again:
 static int xennet_connect(struct net_device *dev)
 {
 	struct netfront_info *np = netdev_priv(dev);
+	unsigned int num_queues = 0;
 	int i, requeue_idx, err;
 	struct sk_buff *skb;
 	grant_ref_t ref;
 	struct xen_netif_rx_request *req;
 	unsigned int feature_rx_copy;
+	unsigned int j = 0;
+	struct netfront_queue *queue = NULL;
 
 	err = xenbus_scanf(XBT_NIL, np->xbdev->otherend,
 			   "feature-rx-copy", "%u", &feature_rx_copy);
@@ -1756,40 +1897,47 @@ static int xennet_connect(struct net_device *dev)
 	if (err)
 		return err;
 
+	/* talk_to_netback() sets the correct number of queues */
+	num_queues = dev->real_num_tx_queues;
+
 	rtnl_lock();
 	netdev_update_features(dev);
 	rtnl_unlock();
 
-	spin_lock_bh(&np->rx_lock);
-	spin_lock_irq(&np->tx_lock);
+	/* By now, the queue structures have been set up */
+	for (j = 0; j < num_queues; ++j) {
+		queue = &np->queues[j];
+		spin_lock_bh(&queue->rx_lock);
+		spin_lock_irq(&queue->tx_lock);
 
-	/* Step 1: Discard all pending TX packet fragments. */
-	xennet_release_tx_bufs(np);
+		/* Step 1: Discard all pending TX packet fragments. */
+		xennet_release_tx_bufs(queue);
 
-	/* Step 2: Rebuild the RX buffer freelist and the RX ring itself. */
-	for (requeue_idx = 0, i = 0; i < NET_RX_RING_SIZE; i++) {
-		skb_frag_t *frag;
-		const struct page *page;
-		if (!np->rx_skbs[i])
-			continue;
+		/* Step 2: Rebuild the RX buffer freelist and the RX ring itself. */
+		for (requeue_idx = 0, i = 0; i < NET_RX_RING_SIZE; i++) {
+			skb_frag_t *frag;
+			const struct page *page;
+			if (!queue->rx_skbs[i])
+				continue;
 
-		skb = np->rx_skbs[requeue_idx] = xennet_get_rx_skb(np, i);
-		ref = np->grant_rx_ref[requeue_idx] = xennet_get_rx_ref(np, i);
-		req = RING_GET_REQUEST(&np->rx, requeue_idx);
+			skb = queue->rx_skbs[requeue_idx] = xennet_get_rx_skb(queue, i);
+			ref = queue->grant_rx_ref[requeue_idx] = xennet_get_rx_ref(queue, i);
+			req = RING_GET_REQUEST(&queue->rx, requeue_idx);
 
-		frag = &skb_shinfo(skb)->frags[0];
-		page = skb_frag_page(frag);
-		gnttab_grant_foreign_access_ref(
-			ref, np->xbdev->otherend_id,
-			pfn_to_mfn(page_to_pfn(page)),
-			0);
-		req->gref = ref;
-		req->id   = requeue_idx;
+			frag = &skb_shinfo(skb)->frags[0];
+			page = skb_frag_page(frag);
+			gnttab_grant_foreign_access_ref(
+				ref, queue->info->xbdev->otherend_id,
+				pfn_to_mfn(page_to_pfn(page)),
+				0);
+			req->gref = ref;
+			req->id   = requeue_idx;
 
-		requeue_idx++;
-	}
+			requeue_idx++;
+		}
 
-	np->rx.req_prod_pvt = requeue_idx;
+		queue->rx.req_prod_pvt = requeue_idx;
+	}
 
 	/*
 	 * Step 3: All public and private state should now be sane.  Get
@@ -1798,14 +1946,17 @@ static int xennet_connect(struct net_device *dev)
 	 * packets.
 	 */
 	netif_carrier_on(np->netdev);
-	notify_remote_via_irq(np->tx_irq);
-	if (np->tx_irq != np->rx_irq)
-		notify_remote_via_irq(np->rx_irq);
-	xennet_tx_buf_gc(dev);
-	xennet_alloc_rx_buffers(dev);
-
-	spin_unlock_irq(&np->tx_lock);
-	spin_unlock_bh(&np->rx_lock);
+	for (j = 0; j < num_queues; ++j) {
+		queue = &np->queues[j];
+		notify_remote_via_irq(queue->tx_irq);
+		if (queue->tx_irq != queue->rx_irq)
+			notify_remote_via_irq(queue->rx_irq);
+		xennet_tx_buf_gc(queue);
+		xennet_alloc_rx_buffers(queue);
+
+		spin_unlock_irq(&queue->tx_lock);
+		spin_unlock_bh(&queue->rx_lock);
+	}
 
 	return 0;
 }
@@ -1878,7 +2029,7 @@ static void xennet_get_ethtool_stats(struct net_device *dev,
 	int i;
 
 	for (i = 0; i < ARRAY_SIZE(xennet_stats); i++)
-		data[i] = *(unsigned long *)(np + xennet_stats[i].offset);
+		data[i] = atomic_read((atomic_t *)(np + xennet_stats[i].offset));
 }
 
 static void xennet_get_strings(struct net_device *dev, u32 stringset, u8 * data)
@@ -1909,8 +2060,12 @@ static ssize_t show_rxbuf_min(struct device *dev,
 {
 	struct net_device *netdev = to_net_dev(dev);
 	struct netfront_info *info = netdev_priv(netdev);
+	unsigned int num_queues = netdev->real_num_tx_queues;
 
-	return sprintf(buf, "%u\n", info->rx_min_target);
+	if (num_queues)
+		return sprintf(buf, "%u\n", info->queues[0].rx_min_target);
+	else
+		return sprintf(buf, "%u\n", RX_MIN_TARGET);
 }
 
 static ssize_t store_rxbuf_min(struct device *dev,
@@ -1919,8 +2074,11 @@ static ssize_t store_rxbuf_min(struct device *dev,
 {
 	struct net_device *netdev = to_net_dev(dev);
 	struct netfront_info *np = netdev_priv(netdev);
+	unsigned int num_queues = netdev->real_num_tx_queues;
 	char *endp;
 	unsigned long target;
+	unsigned int i;
+	struct netfront_queue *queue;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -1934,16 +2092,19 @@ static ssize_t store_rxbuf_min(struct device *dev,
 	if (target > RX_MAX_TARGET)
 		target = RX_MAX_TARGET;
 
-	spin_lock_bh(&np->rx_lock);
-	if (target > np->rx_max_target)
-		np->rx_max_target = target;
-	np->rx_min_target = target;
-	if (target > np->rx_target)
-		np->rx_target = target;
+	for (i = 0; i < num_queues; ++i) {
+		queue = &np->queues[i];
+		spin_lock_bh(&queue->rx_lock);
+		if (target > queue->rx_max_target)
+			queue->rx_max_target = target;
+		queue->rx_min_target = target;
+		if (target > queue->rx_target)
+			queue->rx_target = target;
 
-	xennet_alloc_rx_buffers(netdev);
+		xennet_alloc_rx_buffers(queue);
 
-	spin_unlock_bh(&np->rx_lock);
+		spin_unlock_bh(&queue->rx_lock);
+	}
 	return len;
 }
 
@@ -1952,8 +2113,12 @@ static ssize_t show_rxbuf_max(struct device *dev,
 {
 	struct net_device *netdev = to_net_dev(dev);
 	struct netfront_info *info = netdev_priv(netdev);
+	unsigned int num_queues = netdev->real_num_tx_queues;
 
-	return sprintf(buf, "%u\n", info->rx_max_target);
+	if (num_queues)
+		return sprintf(buf, "%u\n", info->queues[0].rx_max_target);
+	else
+		return sprintf(buf, "%u\n", RX_MAX_TARGET);
 }
 
 static ssize_t store_rxbuf_max(struct device *dev,
@@ -1962,8 +2127,11 @@ static ssize_t store_rxbuf_max(struct device *dev,
 {
 	struct net_device *netdev = to_net_dev(dev);
 	struct netfront_info *np = netdev_priv(netdev);
+	unsigned int num_queues = netdev->real_num_tx_queues;
 	char *endp;
 	unsigned long target;
+	unsigned int i = 0;
+	struct netfront_queue *queue = NULL;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -1977,16 +2145,19 @@ static ssize_t store_rxbuf_max(struct device *dev,
 	if (target > RX_MAX_TARGET)
 		target = RX_MAX_TARGET;
 
-	spin_lock_bh(&np->rx_lock);
-	if (target < np->rx_min_target)
-		np->rx_min_target = target;
-	np->rx_max_target = target;
-	if (target < np->rx_target)
-		np->rx_target = target;
+	for (i = 0; i < num_queues; ++i) {
+		queue = &np->queues[i];
+		spin_lock_bh(&queue->rx_lock);
+		if (target < queue->rx_min_target)
+			queue->rx_min_target = target;
+		queue->rx_max_target = target;
+		if (target < queue->rx_target)
+			queue->rx_target = target;
 
-	xennet_alloc_rx_buffers(netdev);
+		xennet_alloc_rx_buffers(queue);
 
-	spin_unlock_bh(&np->rx_lock);
+		spin_unlock_bh(&queue->rx_lock);
+	}
 	return len;
 }
 
@@ -1995,8 +2166,12 @@ static ssize_t show_rxbuf_cur(struct device *dev,
 {
 	struct net_device *netdev = to_net_dev(dev);
 	struct netfront_info *info = netdev_priv(netdev);
+	unsigned int num_queues = netdev->real_num_tx_queues;
 
-	return sprintf(buf, "%u\n", info->rx_target);
+	if (num_queues)
+		return sprintf(buf, "%u\n", info->queues[0].rx_target);
+	else
+		return sprintf(buf, "0\n");
 }
 
 static struct device_attribute xennet_attrs[] = {
@@ -2043,6 +2218,9 @@ static const struct xenbus_device_id netfront_ids[] = {
 static int xennet_remove(struct xenbus_device *dev)
 {
 	struct netfront_info *info = dev_get_drvdata(&dev->dev);
+	unsigned int num_queues = info->netdev->real_num_tx_queues;
+	struct netfront_queue *queue = NULL;
+	unsigned int i = 0;
 
 	dev_dbg(&dev->dev, "%s\n", dev->nodename);
 
@@ -2052,7 +2230,15 @@ static int xennet_remove(struct xenbus_device *dev)
 
 	unregister_netdev(info->netdev);
 
-	del_timer_sync(&info->rx_refill_timer);
+	for (i = 0; i < num_queues; ++i) {
+		queue = &info->queues[i];
+		del_timer_sync(&queue->rx_refill_timer);
+	}
+
+	if (num_queues) {
+		kfree(info->queues);
+		info->queues = NULL;
+	}
 
 	free_percpu(info->stats);
 
-- 
1.7.10.4
