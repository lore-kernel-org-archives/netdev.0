From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH 5/6] xen-netback: coalesce slots before copying
Date: Mon, 25 Mar 2013 11:08:21 +0000
Message-ID: <1364209702-12437-6-git-send-email-wei.liu2@citrix.com>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ian.campbell@citrix.com>, <annie.li@oracle.com>,
	<konrad.wilk@oracle.com>, <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:49608 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756399Ab3CYLIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 07:08:34 -0400
In-Reply-To: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch tries to coalesce tx requests when constructing grant copy
structures. It enables netback to deal with situation when frontend's
MAX_SKB_FRAGS is larger than backend's MAX_SKB_FRAGS.

It defines max_skb_slots, which is a estimation of the maximum number of slots
a guest can send, anything bigger than that is considered malicious. Now it is
set to 20, which should be enough to accommodate Linux (16 to 19).

Also change variable name from "frags" to "slots" in netbk_count_requests.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/netback.c |  220 ++++++++++++++++++++++++++++---------
 1 file changed, 171 insertions(+), 49 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 6e8e51a..a634dc5 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -47,11 +47,26 @@
 #include <asm/xen/hypercall.h>
 #include <asm/xen/page.h>
 
+/*
+ * This is an estimation of the maximum possible frags a SKB might
+ * have, anything larger than this is considered malicious. Typically
+ * Linux has 16 to 19.
+ */
+#define MAX_SKB_SLOTS_DEFAULT 20
+static unsigned int max_skb_slots = MAX_SKB_SLOTS_DEFAULT;
+module_param(max_skb_slots, uint, 0444);
+
+typedef unsigned int pending_ring_idx_t;
+#define INVALID_PENDING_RING_IDX (~0U)
+
 struct pending_tx_info {
-	struct xen_netif_tx_request req;
+	struct xen_netif_tx_request req; /* coalesced tx request  */
 	struct xenvif *vif;
+	pending_ring_idx_t head; /* head != INVALID_PENDING_RING_IDX
+				  * if it is head of serveral merged
+				  * tx reqs
+				  */
 };
-typedef unsigned int pending_ring_idx_t;
 
 struct netbk_rx_meta {
 	int id;
@@ -102,7 +117,11 @@ struct xen_netbk {
 	atomic_t netfront_count;
 
 	struct pending_tx_info pending_tx_info[MAX_PENDING_REQS];
-	struct gnttab_copy tx_copy_ops[MAX_PENDING_REQS];
+	/* Coalescing tx requests before copying makes number of grant
+	 * copy ops greater of equal to number of slots required. In
+	 * worst case a tx request consumes 2 gnttab_copy.
+	 */
+	struct gnttab_copy tx_copy_ops[2*MAX_PENDING_REQS];
 
 	u16 pending_ring[MAX_PENDING_REQS];
 
@@ -251,7 +270,7 @@ static int max_required_rx_slots(struct xenvif *vif)
 	int max = DIV_ROUND_UP(vif->dev->mtu, PAGE_SIZE);
 
 	if (vif->can_sg || vif->gso || vif->gso_prefix)
-		max += MAX_SKB_FRAGS + 1; /* extra_info + frags */
+		max += max_skb_slots + 1; /* extra_info + frags */
 
 	return max;
 }
@@ -657,7 +676,7 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
 		__skb_queue_tail(&rxq, skb);
 
 		/* Filled the batch queue? */
-		if (count + MAX_SKB_FRAGS >= XEN_NETIF_RX_RING_SIZE)
+		if (count + max_skb_slots >= XEN_NETIF_RX_RING_SIZE)
 			break;
 	}
 
@@ -908,34 +927,34 @@ static int netbk_count_requests(struct xenvif *vif,
 				int work_to_do)
 {
 	RING_IDX cons = vif->tx.req_cons;
-	int frags = 0;
+	int slots = 0;
 
 	if (!(first->flags & XEN_NETTXF_more_data))
 		return 0;
 
 	do {
-		if (frags >= work_to_do) {
-			netdev_err(vif->dev, "Need more frags\n");
+		if (slots >= work_to_do) {
+			netdev_err(vif->dev, "Need more slots\n");
 			netbk_fatal_tx_err(vif);
 			return -ENODATA;
 		}
 
-		if (unlikely(frags >= MAX_SKB_FRAGS)) {
-			netdev_err(vif->dev, "Too many frags\n");
+		if (unlikely(slots >= max_skb_slots)) {
+			netdev_err(vif->dev, "Too many slots\n");
 			netbk_fatal_tx_err(vif);
 			return -E2BIG;
 		}
 
-		memcpy(txp, RING_GET_REQUEST(&vif->tx, cons + frags),
+		memcpy(txp, RING_GET_REQUEST(&vif->tx, cons + slots),
 		       sizeof(*txp));
 		if (txp->size > first->size) {
-			netdev_err(vif->dev, "Frag is bigger than frame.\n");
+			netdev_err(vif->dev, "Packet is bigger than frame.\n");
 			netbk_fatal_tx_err(vif);
 			return -EIO;
 		}
 
 		first->size -= txp->size;
-		frags++;
+		slots++;
 
 		if (unlikely((txp->offset + txp->size) > PAGE_SIZE)) {
 			netdev_err(vif->dev, "txp->offset: %x, size: %u\n",
@@ -944,7 +963,7 @@ static int netbk_count_requests(struct xenvif *vif,
 			return -EINVAL;
 		}
 	} while ((txp++)->flags & XEN_NETTXF_more_data);
-	return frags;
+	return slots;
 }
 
 static struct page *xen_netbk_alloc_page(struct xen_netbk *netbk,
@@ -968,48 +987,114 @@ static struct gnttab_copy *xen_netbk_get_requests(struct xen_netbk *netbk,
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
 	skb_frag_t *frags = shinfo->frags;
 	u16 pending_idx = *((u16 *)skb->data);
-	int i, start;
+	u16 head_idx = 0;
+	int slot, start;
+	struct page *page;
+	pending_ring_idx_t index, start_idx = 0;
+	uint16_t dst_offset;
+	unsigned int nr_slots;
+	struct pending_tx_info *first = NULL;
+
+	/* At this point shinfo->nr_frags is in fact the number of
+	 * slots, which can be as large as max_skb_slots.
+	 */
+	nr_slots = shinfo->nr_frags;
 
 	/* Skip first skb fragment if it is on same page as header fragment. */
 	start = (frag_get_pending_idx(&shinfo->frags[0]) == pending_idx);
 
-	for (i = start; i < shinfo->nr_frags; i++, txp++) {
-		struct page *page;
-		pending_ring_idx_t index;
+	/* Coalesce tx requests, at this point the packet passed in
+	 * should be <= 64K. Any packets larger than 64K have been
+	 * handled in netbk_count_requests().
+	 */
+	for (shinfo->nr_frags = slot = start; slot < nr_slots;
+	     shinfo->nr_frags++) {
 		struct pending_tx_info *pending_tx_info =
 			netbk->pending_tx_info;
 
-		index = pending_index(netbk->pending_cons++);
-		pending_idx = netbk->pending_ring[index];
-		page = xen_netbk_alloc_page(netbk, pending_idx);
+		page = alloc_page(GFP_KERNEL|__GFP_COLD);
 		if (!page)
 			goto err;
 
-		gop->source.u.ref = txp->gref;
-		gop->source.domid = vif->domid;
-		gop->source.offset = txp->offset;
-
-		gop->dest.u.gmfn = virt_to_mfn(page_address(page));
-		gop->dest.domid = DOMID_SELF;
-		gop->dest.offset = txp->offset;
-
-		gop->len = txp->size;
-		gop->flags = GNTCOPY_source_gref;
+		dst_offset = 0;
+		first = NULL;
+		while (dst_offset < PAGE_SIZE && slot < nr_slots) {
+			gop->flags = GNTCOPY_source_gref;
+
+			gop->source.u.ref = txp->gref;
+			gop->source.domid = vif->domid;
+			gop->source.offset = txp->offset;
+
+			gop->dest.domid = DOMID_SELF;
+
+			gop->dest.offset = dst_offset;
+			gop->dest.u.gmfn = virt_to_mfn(page_address(page));
+
+			if (dst_offset + txp->size > PAGE_SIZE) {
+				/* This page can only merge a portion
+				 * of tx request. Do not increment any
+				 * pointer / counter here. The txp
+				 * will be dealt with in future
+				 * rounds, eventually hitting the
+				 * `else` branch.
+				 */
+				gop->len = PAGE_SIZE - dst_offset;
+				txp->offset += gop->len;
+				txp->size -= gop->len;
+				dst_offset += gop->len; /* quit loop */
+			} else {
+				/* This tx request can be merged in the page */
+				gop->len = txp->size;
+				dst_offset += gop->len;
+
+				index = pending_index(netbk->pending_cons++);
+
+				pending_idx = netbk->pending_ring[index];
+
+				memcpy(&pending_tx_info[pending_idx].req, txp,
+				       sizeof(*txp));
+				xenvif_get(vif);
+
+				pending_tx_info[pending_idx].vif = vif;
+
+				/* Poison these fields, corresponding
+				 * fields for head tx req will be set
+				 * to correct values after the loop.
+				 */
+				netbk->mmap_pages[pending_idx] = (void *)(~0UL);
+				pending_tx_info[pending_idx].head =
+					INVALID_PENDING_RING_IDX;
+
+				if (unlikely(!first)) {
+					first = &pending_tx_info[pending_idx];
+					start_idx = index;
+					head_idx = pending_idx;
+				}
+
+				txp++;
+				slot++;
+			}
 
-		gop++;
+			gop++;
+		}
 
-		memcpy(&pending_tx_info[pending_idx].req, txp, sizeof(*txp));
-		xenvif_get(vif);
-		pending_tx_info[pending_idx].vif = vif;
-		frag_set_pending_idx(&frags[i], pending_idx);
+		first->req.offset = 0;
+		first->req.size = dst_offset;
+		first->head = start_idx;
+		set_page_ext(page, netbk, head_idx);
+		netbk->mmap_pages[head_idx] = page;
+		frag_set_pending_idx(&frags[shinfo->nr_frags], head_idx);
 	}
 
+	BUG_ON(shinfo->nr_frags > MAX_SKB_FRAGS);
+
 	return gop;
 err:
 	/* Unwind, freeing all pages and sending error responses. */
-	while (i-- > start) {
-		xen_netbk_idx_release(netbk, frag_get_pending_idx(&frags[i]),
-				      XEN_NETIF_RSP_ERROR);
+	while (shinfo->nr_frags-- > start) {
+		xen_netbk_idx_release(netbk,
+				frag_get_pending_idx(&frags[shinfo->nr_frags]),
+				XEN_NETIF_RSP_ERROR);
 	}
 	/* The head too, if necessary. */
 	if (start)
@@ -1025,8 +1110,10 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
 	struct gnttab_copy *gop = *gopp;
 	u16 pending_idx = *((u16 *)skb->data);
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
+	struct pending_tx_info *tx_info;
 	int nr_frags = shinfo->nr_frags;
 	int i, err, start;
+	u16 peek; /* peek into next tx request */
 
 	/* Check status of header. */
 	err = gop->status;
@@ -1038,11 +1125,21 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
 
 	for (i = start; i < nr_frags; i++) {
 		int j, newerr;
+		pending_ring_idx_t head;
 
 		pending_idx = frag_get_pending_idx(&shinfo->frags[i]);
+		tx_info = &netbk->pending_tx_info[pending_idx];
+		head = tx_info->head;
 
 		/* Check error status: if okay then remember grant handle. */
-		newerr = (++gop)->status;
+		do {
+			newerr = (++gop)->status;
+			if (newerr)
+				break;
+			peek = netbk->pending_ring[pending_index(++head)];
+		} while (netbk->pending_tx_info[peek].head
+			 == INVALID_PENDING_RING_IDX);
+
 		if (likely(!newerr)) {
 			/* Had a previous error? Invalidate this fragment. */
 			if (unlikely(err))
@@ -1267,11 +1364,11 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
 	struct sk_buff *skb;
 	int ret;
 
-	while (((nr_pending_reqs(netbk) + MAX_SKB_FRAGS) < MAX_PENDING_REQS) &&
+	while (((nr_pending_reqs(netbk) + max_skb_slots) < MAX_PENDING_REQS) &&
 		!list_empty(&netbk->net_schedule_list)) {
 		struct xenvif *vif;
 		struct xen_netif_tx_request txreq;
-		struct xen_netif_tx_request txfrags[MAX_SKB_FRAGS];
+		struct xen_netif_tx_request txfrags[max_skb_slots];
 		struct page *page;
 		struct xen_netif_extra_info extras[XEN_NETIF_EXTRA_TYPE_MAX-1];
 		u16 pending_idx;
@@ -1359,7 +1456,7 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
 		pending_idx = netbk->pending_ring[index];
 
 		data_len = (txreq.size > PKT_PROT_LEN &&
-			    ret < MAX_SKB_FRAGS) ?
+			    ret < max_skb_slots) ?
 			PKT_PROT_LEN : txreq.size;
 
 		skb = alloc_skb(data_len + NET_SKB_PAD + NET_IP_ALIGN,
@@ -1409,6 +1506,7 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
 		memcpy(&netbk->pending_tx_info[pending_idx].req,
 		       &txreq, sizeof(txreq));
 		netbk->pending_tx_info[pending_idx].vif = vif;
+		netbk->pending_tx_info[pending_idx].head = index;
 		*((u16 *)skb->data) = pending_idx;
 
 		__skb_put(skb, data_len);
@@ -1539,7 +1637,10 @@ static void xen_netbk_idx_release(struct xen_netbk *netbk, u16 pending_idx,
 {
 	struct xenvif *vif;
 	struct pending_tx_info *pending_tx_info;
-	pending_ring_idx_t index;
+	pending_ring_idx_t head;
+	u16 peek; /* peek into next tx request */
+
+	BUG_ON(netbk->mmap_pages[pending_idx] == (void *)(~0UL));
 
 	/* Already complete? */
 	if (netbk->mmap_pages[pending_idx] == NULL)
@@ -1548,13 +1649,34 @@ static void xen_netbk_idx_release(struct xen_netbk *netbk, u16 pending_idx,
 	pending_tx_info = &netbk->pending_tx_info[pending_idx];
 
 	vif = pending_tx_info->vif;
+	head = pending_tx_info->head;
 
-	make_tx_response(vif, &pending_tx_info->req, status);
+	BUG_ON(head == INVALID_PENDING_RING_IDX);
+	BUG_ON(netbk->pending_ring[pending_index(head)] != pending_idx);
 
-	index = pending_index(netbk->pending_prod++);
-	netbk->pending_ring[index] = pending_idx;
+	do {
+		pending_ring_idx_t index;
+		pending_ring_idx_t idx = pending_index(head);
+		u16 info_idx = netbk->pending_ring[idx];
 
-	xenvif_put(vif);
+		pending_tx_info = &netbk->pending_tx_info[info_idx];
+		make_tx_response(vif, &pending_tx_info->req, status);
+
+		/* Setting any number other than
+		 * INVALID_PENDING_RING_IDX indicates this slot is
+		 * starting a new packet / ending a previous packet.
+		 */
+		pending_tx_info->head = 0;
+
+		index = pending_index(netbk->pending_prod++);
+		netbk->pending_ring[index] = netbk->pending_ring[info_idx];
+
+		xenvif_put(vif);
+
+		peek = netbk->pending_ring[pending_index(++head)];
+
+	} while (netbk->pending_tx_info[peek].head
+		 == INVALID_PENDING_RING_IDX);
 
 	netbk->mmap_pages[pending_idx]->mapping = 0;
 	put_page(netbk->mmap_pages[pending_idx]);
@@ -1613,7 +1735,7 @@ static inline int rx_work_todo(struct xen_netbk *netbk)
 static inline int tx_work_todo(struct xen_netbk *netbk)
 {
 
-	if (((nr_pending_reqs(netbk) + MAX_SKB_FRAGS) < MAX_PENDING_REQS) &&
+	if (((nr_pending_reqs(netbk) + max_skb_slots) < MAX_PENDING_REQS) &&
 			!list_empty(&netbk->net_schedule_list))
 		return 1;
 
-- 
1.7.10.4
