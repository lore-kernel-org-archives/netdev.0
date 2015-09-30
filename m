From: Julien Grall <julien.grall@citrix.com>
Subject: [PATCH v5 17/22] net/xen-netfront: Make it running on 64KB page granularity
Date: Wed, 30 Sep 2015 11:45:32 +0100
Message-ID: <1443609937-25278-18-git-send-email-julien.grall@citrix.com>
References: <1443609937-25278-1-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>, <ian.campbell@citrix.com>,
	<stefano.stabellini@eu.citrix.com>, <linux-kernel@vger.kernel.org>,
	"Julien Grall" <julien.grall@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	<netdev@vger.kernel.org>
To: <xen-devel@lists.xenproject.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443609937-25278-1-git-send-email-julien.grall@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PV network protocol is using 4KB page granularity. The goal of this
patch is to allow a Linux using 64KB page granularity using network
device on a non-modified Xen.

It's only necessary to adapt the ring size and break skb data in small
chunk of 4KB. The rest of the code is relying on the grant table code.

Note that we allocate a Linux page for each rx skb but only the first
4KB is used. We may improve the memory usage by extending the size of
the rx skb.

Signed-off-by: Julien Grall <julien.grall@citrix.com>
Reviewed-by: David Vrabel <david.vrabel@citrix.com>

---
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: netdev@vger.kernel.org

Improvement such as support of 64KB grant is not taken into
consideration in this patch because we have the requirement to run a Linux
using 64KB pages on a non-modified Xen.

Tested with workload such as ping, ssh, wget, git... I would happy if
someone give details how to test all the path.

    Changes in v4:
        - s/gnttab_one_grant/gnttab_for_one_grant/ based on the new naming
        - Add David's reviewed-by

    Changes in v3:
        - Fix errors reported by checkpatch.pl
        - s/mfn/gfn/ base on the new naming
        - xennet_tx_setup_grant was calling itself resulting an
        guest stall when using iperf.
        - The grant callback doesn't allow anymore to change the len
        (wasn't used here)
        - gnttab_foreach_grant has been renamed to gnttab_foreach_grant_in_range
        - gnttab_page_grant_foreign_ref has been renamed to
        gnttab_foreach_grant_foreign_ref_one

    Changes in v2:
        - Use gnttab_foreach_grant to split a Linux page in grant
        - Fix count slots
---
 drivers/net/xen-netfront.c | 122 ++++++++++++++++++++++++++++++++-------------
 1 file changed, 86 insertions(+), 36 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index f821a97..badca31 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -74,8 +74,8 @@ struct netfront_cb {
 
 #define GRANT_INVALID_REF	0
 
-#define NET_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE)
-#define NET_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE)
+#define NET_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, XEN_PAGE_SIZE)
+#define NET_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, XEN_PAGE_SIZE)
 
 /* Minimum number of Rx slots (includes slot for GSO metadata). */
 #define NET_RX_SLOTS_MIN (XEN_NETIF_NR_SLOTS_MIN + 1)
@@ -291,7 +291,7 @@ static void xennet_alloc_rx_buffers(struct netfront_queue *queue)
 		struct sk_buff *skb;
 		unsigned short id;
 		grant_ref_t ref;
-		unsigned long gfn;
+		struct page *page;
 		struct xen_netif_rx_request *req;
 
 		skb = xennet_alloc_one_rx_buffer(queue);
@@ -307,14 +307,13 @@ static void xennet_alloc_rx_buffers(struct netfront_queue *queue)
 		BUG_ON((signed short)ref < 0);
 		queue->grant_rx_ref[id] = ref;
 
-		gfn = xen_page_to_gfn(skb_frag_page(&skb_shinfo(skb)->frags[0]));
+		page = skb_frag_page(&skb_shinfo(skb)->frags[0]);
 
 		req = RING_GET_REQUEST(&queue->rx, req_prod);
-		gnttab_grant_foreign_access_ref(ref,
-						queue->info->xbdev->otherend_id,
-						gfn,
-						0);
-
+		gnttab_page_grant_foreign_access_ref_one(ref,
+							 queue->info->xbdev->otherend_id,
+							 page,
+							 0);
 		req->id = id;
 		req->gref = ref;
 	}
@@ -415,25 +414,33 @@ static void xennet_tx_buf_gc(struct netfront_queue *queue)
 	xennet_maybe_wake_tx(queue);
 }
 
-static struct xen_netif_tx_request *xennet_make_one_txreq(
-	struct netfront_queue *queue, struct sk_buff *skb,
-	struct page *page, unsigned int offset, unsigned int len)
+struct xennet_gnttab_make_txreq {
+	struct netfront_queue *queue;
+	struct sk_buff *skb;
+	struct page *page;
+	struct xen_netif_tx_request *tx; /* Last request */
+	unsigned int size;
+};
+
+static void xennet_tx_setup_grant(unsigned long gfn, unsigned int offset,
+				  unsigned int len, void *data)
 {
+	struct xennet_gnttab_make_txreq *info = data;
 	unsigned int id;
 	struct xen_netif_tx_request *tx;
 	grant_ref_t ref;
-
-	len = min_t(unsigned int, PAGE_SIZE - offset, len);
+	/* convenient aliases */
+	struct page *page = info->page;
+	struct netfront_queue *queue = info->queue;
+	struct sk_buff *skb = info->skb;
 
 	id = get_id_from_freelist(&queue->tx_skb_freelist, queue->tx_skbs);
 	tx = RING_GET_REQUEST(&queue->tx, queue->tx.req_prod_pvt++);
 	ref = gnttab_claim_grant_reference(&queue->gref_tx_head);
 	BUG_ON((signed short)ref < 0);
 
-	gnttab_grant_foreign_access_ref(ref,
-					queue->info->xbdev->otherend_id,
-					xen_page_to_gfn(page),
-					GNTMAP_readonly);
+	gnttab_grant_foreign_access_ref(ref, queue->info->xbdev->otherend_id,
+					gfn, GNTMAP_readonly);
 
 	queue->tx_skbs[id].skb = skb;
 	queue->grant_tx_page[id] = page;
@@ -445,7 +452,34 @@ static struct xen_netif_tx_request *xennet_make_one_txreq(
 	tx->size = len;
 	tx->flags = 0;
 
-	return tx;
+	info->tx = tx;
+	info->size += tx->size;
+}
+
+static struct xen_netif_tx_request *xennet_make_first_txreq(
+	struct netfront_queue *queue, struct sk_buff *skb,
+	struct page *page, unsigned int offset, unsigned int len)
+{
+	struct xennet_gnttab_make_txreq info = {
+		.queue = queue,
+		.skb = skb,
+		.page = page,
+		.size = 0,
+	};
+
+	gnttab_for_one_grant(page, offset, len, xennet_tx_setup_grant, &info);
+
+	return info.tx;
+}
+
+static void xennet_make_one_txreq(unsigned long gfn, unsigned int offset,
+				  unsigned int len, void *data)
+{
+	struct xennet_gnttab_make_txreq *info = data;
+
+	info->tx->flags |= XEN_NETTXF_more_data;
+	skb_get(info->skb);
+	xennet_tx_setup_grant(gfn, offset, len, data);
 }
 
 static struct xen_netif_tx_request *xennet_make_txreqs(
@@ -453,20 +487,30 @@ static struct xen_netif_tx_request *xennet_make_txreqs(
 	struct sk_buff *skb, struct page *page,
 	unsigned int offset, unsigned int len)
 {
+	struct xennet_gnttab_make_txreq info = {
+		.queue = queue,
+		.skb = skb,
+		.tx = tx,
+	};
+
 	/* Skip unused frames from start of page */
 	page += offset >> PAGE_SHIFT;
 	offset &= ~PAGE_MASK;
 
 	while (len) {
-		tx->flags |= XEN_NETTXF_more_data;
-		tx = xennet_make_one_txreq(queue, skb_get(skb),
-					   page, offset, len);
+		info.page = page;
+		info.size = 0;
+
+		gnttab_foreach_grant_in_range(page, offset, len,
+					      xennet_make_one_txreq,
+					      &info);
+
 		page++;
 		offset = 0;
-		len -= tx->size;
+		len -= info.size;
 	}
 
-	return tx;
+	return info.tx;
 }
 
 /*
@@ -476,9 +520,10 @@ static struct xen_netif_tx_request *xennet_make_txreqs(
 static int xennet_count_skb_slots(struct sk_buff *skb)
 {
 	int i, frags = skb_shinfo(skb)->nr_frags;
-	int pages;
+	int slots;
 
-	pages = PFN_UP(offset_in_page(skb->data) + skb_headlen(skb));
+	slots = gnttab_count_grant(offset_in_page(skb->data),
+				   skb_headlen(skb));
 
 	for (i = 0; i < frags; i++) {
 		skb_frag_t *frag = skb_shinfo(skb)->frags + i;
@@ -488,10 +533,10 @@ static int xennet_count_skb_slots(struct sk_buff *skb)
 		/* Skip unused frames from start of page */
 		offset &= ~PAGE_MASK;
 
-		pages += PFN_UP(offset + size);
+		slots += gnttab_count_grant(offset, size);
 	}
 
-	return pages;
+	return slots;
 }
 
 static u16 xennet_select_queue(struct net_device *dev, struct sk_buff *skb,
@@ -512,6 +557,8 @@ static u16 xennet_select_queue(struct net_device *dev, struct sk_buff *skb,
 	return queue_idx;
 }
 
+#define MAX_XEN_SKB_FRAGS (65536 / XEN_PAGE_SIZE + 1)
+
 static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct netfront_info *np = netdev_priv(dev);
@@ -546,7 +593,7 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	slots = xennet_count_skb_slots(skb);
-	if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
+	if (unlikely(slots > MAX_XEN_SKB_FRAGS + 1)) {
 		net_dbg_ratelimited("xennet: skb rides the rocket: %d slots, %d bytes\n",
 				    slots, skb->len);
 		if (skb_linearize(skb))
@@ -567,10 +614,13 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	/* First request for the linear area. */
-	first_tx = tx = xennet_make_one_txreq(queue, skb,
-					      page, offset, len);
-	page++;
-	offset = 0;
+	first_tx = tx = xennet_make_first_txreq(queue, skb,
+						page, offset, len);
+	offset += tx->size;
+	if (offset == PAGE_SIZE) {
+		page++;
+		offset = 0;
+	}
 	len -= tx->size;
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL)
@@ -732,7 +782,7 @@ static int xennet_get_responses(struct netfront_queue *queue,
 
 	for (;;) {
 		if (unlikely(rx->status < 0 ||
-			     rx->offset + rx->status > PAGE_SIZE)) {
+			     rx->offset + rx->status > XEN_PAGE_SIZE)) {
 			if (net_ratelimit())
 				dev_warn(dev, "rx->offset: %u, size: %d\n",
 					 rx->offset, rx->status);
@@ -1496,7 +1546,7 @@ static int setup_netfront(struct xenbus_device *dev,
 		goto fail;
 	}
 	SHARED_RING_INIT(txs);
-	FRONT_RING_INIT(&queue->tx, txs, PAGE_SIZE);
+	FRONT_RING_INIT(&queue->tx, txs, XEN_PAGE_SIZE);
 
 	err = xenbus_grant_ring(dev, txs, 1, &gref);
 	if (err < 0)
@@ -1510,7 +1560,7 @@ static int setup_netfront(struct xenbus_device *dev,
 		goto alloc_rx_ring_fail;
 	}
 	SHARED_RING_INIT(rxs);
-	FRONT_RING_INIT(&queue->rx, rxs, PAGE_SIZE);
+	FRONT_RING_INIT(&queue->rx, rxs, XEN_PAGE_SIZE);
 
 	err = xenbus_grant_ring(dev, rxs, 1, &gref);
 	if (err < 0)
-- 
2.1.4
