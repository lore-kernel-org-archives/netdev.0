From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCH 3/3] xen-netfront: refactor making Tx requests
Date: Tue, 13 Jan 2015 17:16:44 +0000
Message-ID: <1421169404-27461-4-git-send-email-david.vrabel@citrix.com>
References: <1421169404-27461-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:59758 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752228AbbAMRUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 12:20:24 -0500
In-Reply-To: <1421169404-27461-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eliminate all the duplicate code for making Tx requests by
consolidating them into a single xennet_make_one_txreq() function.

xennet_make_one_txreq() and xennet_make_txreqs() work with pages and
offsets so it will be easier to make netfront handle highmem frags in
the future.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netfront.c |  181 ++++++++++++++++----------------------------
 1 file changed, 67 insertions(+), 114 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 6b29b3a..68e0e8f 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -425,99 +425,56 @@ static void xennet_tx_buf_gc(struct netfront_queue *queue)
 	xennet_maybe_wake_tx(queue);
 }
 
-static void xennet_make_frags(struct sk_buff *skb, struct netfront_queue *queue,
-			      struct xen_netif_tx_request *tx)
-{
-	char *data = skb->data;
-	unsigned long mfn;
-	RING_IDX prod = queue->tx.req_prod_pvt;
-	int frags = skb_shinfo(skb)->nr_frags;
-	unsigned int offset = offset_in_page(data);
-	unsigned int len = skb_headlen(skb);
+static struct xen_netif_tx_request *xennet_make_one_txreq(
+	struct netfront_queue *queue, struct sk_buff *skb,
+	struct page *page, unsigned int offset, unsigned int len)
+{
 	unsigned int id;
+	struct xen_netif_tx_request *tx;
 	grant_ref_t ref;
-	int i;
 
-	/* While the header overlaps a page boundary (including being
-	   larger than a page), split it it into page-sized chunks. */
-	while (len > PAGE_SIZE - offset) {
-		tx->size = PAGE_SIZE - offset;
-		tx->flags |= XEN_NETTXF_more_data;
-		len -= tx->size;
-		data += tx->size;
-		offset = 0;
+	len = min_t(unsigned int, PAGE_SIZE - offset, len);
 
-		id = get_id_from_freelist(&queue->tx_skb_freelist, queue->tx_skbs);
-		queue->tx_skbs[id].skb = skb_get(skb);
-		tx = RING_GET_REQUEST(&queue->tx, prod++);
-		tx->id = id;
-		ref = gnttab_claim_grant_reference(&queue->gref_tx_head);
-		BUG_ON((signed short)ref < 0);
+	id = get_id_from_freelist(&queue->tx_skb_freelist, queue->tx_skbs);
+	tx = RING_GET_REQUEST(&queue->tx, queue->tx.req_prod_pvt++);
+	ref = gnttab_claim_grant_reference(&queue->gref_tx_head);
+	BUG_ON((signed short)ref < 0);
 
-		mfn = virt_to_mfn(data);
-		gnttab_grant_foreign_access_ref(ref, queue->info->xbdev->otherend_id,
-						mfn, GNTMAP_readonly);
+	gnttab_grant_foreign_access_ref(ref, queue->info->xbdev->otherend_id,
+					page_to_mfn(page), GNTMAP_readonly);
 
-		queue->grant_tx_page[id] = virt_to_page(data);
-		tx->gref = queue->grant_tx_ref[id] = ref;
-		tx->offset = offset;
-		tx->size = len;
-		tx->flags = 0;
-	}
+	queue->tx_skbs[id].skb = skb;
+	queue->grant_tx_page[id] = page;
+	queue->grant_tx_ref[id] = ref;
 
-	/* Grant backend access to each skb fragment page. */
-	for (i = 0; i < frags; i++) {
-		skb_frag_t *frag = skb_shinfo(skb)->frags + i;
-		struct page *page = skb_frag_page(frag);
+	tx->id = id;
+	tx->gref = ref;
+	tx->offset = offset;
+	tx->size = len;
+	tx->flags = 0;
 
-		len = skb_frag_size(frag);
-		offset = frag->page_offset;
+	return tx;
+}
 
-		/* Skip unused frames from start of page */
-		page += offset >> PAGE_SHIFT;
-		offset &= ~PAGE_MASK;
+static struct xen_netif_tx_request *xennet_make_txreqs(
+	struct netfront_queue *queue, struct xen_netif_tx_request *tx,
+	struct sk_buff *skb, struct page *page,
+	unsigned int offset, unsigned int len)
+{
+	/* Skip unused frames from start of page */
+	page += offset >> PAGE_SHIFT;
+	offset &= ~PAGE_MASK;
 
-		while (len > 0) {
-			unsigned long bytes;
-
-			bytes = PAGE_SIZE - offset;
-			if (bytes > len)
-				bytes = len;
-
-			tx->flags |= XEN_NETTXF_more_data;
-
-			id = get_id_from_freelist(&queue->tx_skb_freelist,
-						  queue->tx_skbs);
-			queue->tx_skbs[id].skb = skb_get(skb);
-			tx = RING_GET_REQUEST(&queue->tx, prod++);
-			tx->id = id;
-			ref = gnttab_claim_grant_reference(&queue->gref_tx_head);
-			BUG_ON((signed short)ref < 0);
-
-			mfn = pfn_to_mfn(page_to_pfn(page));
-			gnttab_grant_foreign_access_ref(ref,
-							queue->info->xbdev->otherend_id,
-							mfn, GNTMAP_readonly);
-
-			queue->grant_tx_page[id] = page;
-			tx->gref = queue->grant_tx_ref[id] = ref;
-			tx->offset = offset;
-			tx->size = bytes;
-			tx->flags = 0;
-
-			offset += bytes;
-			len -= bytes;
-
-			/* Next frame */
-			if (offset == PAGE_SIZE && len) {
-				BUG_ON(!PageCompound(page));
-				page++;
-				offset = 0;
-			}
-		}
+	while (len) {
+		tx->flags |= XEN_NETTXF_more_data;
+		tx = xennet_make_one_txreq(queue, skb_get(skb),
+					   page, offset, len);
+		page++;
+		offset = 0;
+		len -= tx->size;
 	}
 
-	queue->tx.req_prod_pvt = prod;
+	return tx;
 }
 
 /*
@@ -565,18 +522,15 @@ static u16 xennet_select_queue(struct net_device *dev, struct sk_buff *skb,
 
 static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	unsigned short id;
 	struct netfront_info *np = netdev_priv(dev);
 	struct netfront_stats *stats = this_cpu_ptr(np->stats);
-	struct xen_netif_tx_request *tx;
-	char *data = skb->data;
-	RING_IDX i;
-	grant_ref_t ref;
-	unsigned long mfn;
+	struct xen_netif_tx_request *tx, *first_tx;
+	unsigned int i;
 	int notify;
 	int slots;
-	unsigned int offset = offset_in_page(data);
-	unsigned int len = skb_headlen(skb);
+	struct page *page;
+	unsigned int offset;
+	unsigned int len;
 	unsigned long flags;
 	struct netfront_queue *queue = NULL;
 	unsigned int num_queues = dev->real_num_tx_queues;
@@ -605,11 +559,12 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 				    slots, skb->len);
 		if (skb_linearize(skb))
 			goto drop;
-		data = skb->data;
-		offset = offset_in_page(data);
-		len = skb_headlen(skb);
 	}
 
+	page = virt_to_page(skb->data);
+	offset = offset_in_page(skb->data);
+	len = skb_headlen(skb);
+
 	spin_lock_irqsave(&queue->tx_lock, flags);
 
 	if (unlikely(!netif_carrier_ok(dev) ||
@@ -619,25 +574,13 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto drop;
 	}
 
-	i = queue->tx.req_prod_pvt;
-
-	id = get_id_from_freelist(&queue->tx_skb_freelist, queue->tx_skbs);
-	queue->tx_skbs[id].skb = skb;
-
-	tx = RING_GET_REQUEST(&queue->tx, i);
+	/* First request for the linear area. */
+	first_tx = tx = xennet_make_one_txreq(queue, skb,
+					      page, offset, len);
+	page++;
+	offset = 0;
+	len -= tx->size;
 
-	tx->id   = id;
-	ref = gnttab_claim_grant_reference(&queue->gref_tx_head);
-	BUG_ON((signed short)ref < 0);
-	mfn = virt_to_mfn(data);
-	gnttab_grant_foreign_access_ref(
-		ref, queue->info->xbdev->otherend_id, mfn, GNTMAP_readonly);
-	queue->grant_tx_page[id] = virt_to_page(data);
-	tx->gref = queue->grant_tx_ref[id] = ref;
-	tx->offset = offset;
-	tx->size = len;
-
-	tx->flags = 0;
 	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		/* local packet? */
 		tx->flags |= XEN_NETTXF_csum_blank | XEN_NETTXF_data_validated;
@@ -645,11 +588,12 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		/* remote but checksummed. */
 		tx->flags |= XEN_NETTXF_data_validated;
 
+	/* Optional extra info after the first request. */
 	if (skb_shinfo(skb)->gso_size) {
 		struct xen_netif_extra_info *gso;
 
 		gso = (struct xen_netif_extra_info *)
-			RING_GET_REQUEST(&queue->tx, ++i);
+			RING_GET_REQUEST(&queue->tx, queue->tx.req_prod_pvt++);
 
 		tx->flags |= XEN_NETTXF_extra_info;
 
@@ -664,10 +608,19 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		gso->flags = 0;
 	}
 
-	queue->tx.req_prod_pvt = i + 1;
+	/* Requests for the rest of the linear area. */
+	tx = xennet_make_txreqs(queue, tx, skb, page, offset, len);
+
+	/* Requests for all the frags. */
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+		tx = xennet_make_txreqs(queue, tx, skb,
+					skb_frag_page(frag), frag->page_offset,
+					skb_frag_size(frag));
+	}
 
-	xennet_make_frags(skb, queue, tx);
-	tx->size = skb->len;
+	/* First request has the packet length. */
+	first_tx->size = skb->len;
 
 	RING_PUSH_REQUESTS_AND_CHECK_NOTIFY(&queue->tx, notify);
 	if (notify)
-- 
1.7.10.4
