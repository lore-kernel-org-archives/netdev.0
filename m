From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next v3 3/9] xen-netback: Remove old TX grant copy definitons and fix indentations
Date: Wed, 8 Jan 2014 00:10:12 +0000
Message-ID: <1389139818-24458-4-git-send-email-zoltan.kiss@citrix.com>
References: <1389139818-24458-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>
To: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389139818-24458-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These became obsolate with grant mapping. I've left intentionally the
indentations in this way, to improve readability of previous patches.

v2:
- move the indentation fixup patch here

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
---
 drivers/net/xen-netback/common.h  |   37 +------------------
 drivers/net/xen-netback/netback.c |   72 ++++++++-----------------------------
 2 files changed, 15 insertions(+), 94 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 33cb12c..f286879 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -46,39 +46,9 @@
 #include <xen/xenbus.h>
 
 typedef unsigned int pending_ring_idx_t;
-#define INVALID_PENDING_RING_IDX (~0U)
 
-/* For the head field in pending_tx_info: it is used to indicate
- * whether this tx info is the head of one or more coalesced requests.
- *
- * When head != INVALID_PENDING_RING_IDX, it means the start of a new
- * tx requests queue and the end of previous queue.
- *
- * An example sequence of head fields (I = INVALID_PENDING_RING_IDX):
- *
- * ...|0 I I I|5 I|9 I I I|...
- * -->|<-INUSE----------------
- *
- * After consuming the first slot(s) we have:
- *
- * ...|V V V V|5 I|9 I I I|...
- * -----FREE->|<-INUSE--------
- *
- * where V stands for "valid pending ring index". Any number other
- * than INVALID_PENDING_RING_IDX is OK. These entries are considered
- * free and can contain any number other than
- * INVALID_PENDING_RING_IDX. In practice we use 0.
- *
- * The in use non-INVALID_PENDING_RING_IDX (say 0, 5 and 9 in the
- * above example) number is the index into pending_tx_info and
- * mmap_pages arrays.
- */
 struct pending_tx_info {
-	struct xen_netif_tx_request req; /* coalesced tx request */
-	pending_ring_idx_t head; /* head != INVALID_PENDING_RING_IDX
-				  * if it is head of one or more tx
-				  * reqs
-				  */
+	struct xen_netif_tx_request req; /* tx request */
 	/* callback data for released SKBs. The	callback is always
 	 * xenvif_zerocopy_callback, ctx points to the next fragment, desc
 	 * contains the pending_idx
@@ -128,11 +98,6 @@ struct xenvif {
 	struct pending_tx_info pending_tx_info[MAX_PENDING_REQS];
 	grant_handle_t grant_tx_handle[MAX_PENDING_REQS];
 
-	/* Coalescing tx requests before copying makes number of grant
-	 * copy ops greater or equal to number of slots required. In
-	 * worst case a tx request consumes 2 gnttab_copy.
-	 */
-	struct gnttab_copy tx_copy_ops[2*MAX_PENDING_REQS];
 	struct gnttab_map_grant_ref tx_map_ops[MAX_PENDING_REQS];
 	struct gnttab_unmap_grant_ref tx_unmap_ops[MAX_PENDING_REQS];
 	/* passed to gnttab_[un]map_refs with pages under (un)mapping */
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 20352be..88a0fad 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -71,16 +71,6 @@ module_param(fatal_skb_slots, uint, 0444);
  */
 #define XEN_NETBK_LEGACY_SLOTS_MAX XEN_NETIF_NR_SLOTS_MIN
 
-/*
- * If head != INVALID_PENDING_RING_IDX, it means this tx request is head of
- * one or more merged tx requests, otherwise it is the continuation of
- * previous tx request.
- */
-static inline int pending_tx_is_head(struct xenvif *vif, RING_IDX idx)
-{
-	return vif->pending_tx_info[idx].head != INVALID_PENDING_RING_IDX;
-}
-
 static void xenvif_idx_release(struct xenvif *vif, u16 pending_idx,
 			       u8 status);
 
@@ -762,19 +752,6 @@ static int xenvif_count_requests(struct xenvif *vif,
 	return slots;
 }
 
-static struct page *xenvif_alloc_page(struct xenvif *vif,
-				      u16 pending_idx)
-{
-	struct page *page;
-
-	page = alloc_page(GFP_ATOMIC|__GFP_COLD);
-	if (!page)
-		return NULL;
-	vif->mmap_pages[pending_idx] = page;
-
-	return page;
-}
-
 static inline void xenvif_tx_create_gop(struct xenvif *vif, u16 pending_idx,
 	       struct xen_netif_tx_request *txp,
 	       struct gnttab_map_grant_ref *gop)
@@ -797,13 +774,9 @@ static struct gnttab_map_grant_ref *xenvif_get_requests(struct xenvif *vif,
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
 	skb_frag_t *frags = shinfo->frags;
 	u16 pending_idx = *((u16 *)skb->data);
-	u16 head_idx = 0;
-	int slot, start;
-	struct page *page;
-	pending_ring_idx_t index, start_idx = 0;
-	uint16_t dst_offset;
+	int start;
+	pending_ring_idx_t index;
 	unsigned int nr_slots;
-	struct pending_tx_info *first = NULL;
 
 	/* At this point shinfo->nr_frags is in fact the number of
 	 * slots, which can be as large as XEN_NETBK_LEGACY_SLOTS_MAX.
@@ -815,8 +788,8 @@ static struct gnttab_map_grant_ref *xenvif_get_requests(struct xenvif *vif,
 
 	for (shinfo->nr_frags = start; shinfo->nr_frags < nr_slots;
 	     shinfo->nr_frags++, txp++, gop++) {
-				index = pending_index(vif->pending_cons++);
-				pending_idx = vif->pending_ring[index];
+		index = pending_index(vif->pending_cons++);
+		pending_idx = vif->pending_ring[index];
 		xenvif_tx_create_gop(vif, pending_idx, txp, gop);
 		frag_set_pending_idx(&frags[shinfo->nr_frags], pending_idx);
 	}
@@ -824,18 +797,6 @@ static struct gnttab_map_grant_ref *xenvif_get_requests(struct xenvif *vif,
 	BUG_ON(shinfo->nr_frags > MAX_SKB_FRAGS);
 
 	return gop;
-err:
-	/* Unwind, freeing all pages and sending error responses. */
-	while (shinfo->nr_frags-- > start) {
-		xenvif_idx_release(vif,
-				frag_get_pending_idx(&frags[shinfo->nr_frags]),
-				XEN_NETIF_RSP_ERROR);
-	}
-	/* The head too, if necessary. */
-	if (start)
-		xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_ERROR);
-
-	return NULL;
 }
 
 static int xenvif_tx_check_gop(struct xenvif *vif,
@@ -848,7 +809,6 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
 	struct pending_tx_info *tx_info;
 	int nr_frags = shinfo->nr_frags;
 	int i, err, start;
-	u16 peek; /* peek into next tx request */
 
 	/* Check status of header. */
 	err = gop->status;
@@ -870,14 +830,12 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
 
 	for (i = start; i < nr_frags; i++) {
 		int j, newerr;
-		pending_ring_idx_t head;
 
 		pending_idx = frag_get_pending_idx(&shinfo->frags[i]);
 		tx_info = &vif->pending_tx_info[pending_idx];
-		head = tx_info->head;
 
 		/* Check error status: if okay then remember grant handle. */
-			newerr = (++gop)->status;
+		newerr = (++gop)->status;
 
 		if (likely(!newerr)) {
 			if (vif->grant_tx_handle[pending_idx] !=
@@ -1343,7 +1301,6 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif, int budget)
 		(skb_queue_len(&vif->tx_queue) < budget)) {
 		struct xen_netif_tx_request txreq;
 		struct xen_netif_tx_request txfrags[XEN_NETBK_LEGACY_SLOTS_MAX];
-		struct page *page;
 		struct xen_netif_extra_info extras[XEN_NETIF_EXTRA_TYPE_MAX-1];
 		u16 pending_idx;
 		RING_IDX idx;
@@ -1705,18 +1662,17 @@ static void xenvif_idx_release(struct xenvif *vif, u16 pending_idx,
 {
 	struct pending_tx_info *pending_tx_info;
 	pending_ring_idx_t index;
-	u16 peek; /* peek into next tx request */
 	unsigned long flags;
 
-		pending_tx_info = &vif->pending_tx_info[pending_idx];
-		spin_lock_irqsave(&vif->response_lock, flags);
-		make_tx_response(vif, &pending_tx_info->req, status);
-		index = pending_index(vif->pending_prod);
-		vif->pending_ring[index] = pending_idx;
-		/* TX shouldn't use the index before we give it back here */
-		mb();
-		vif->pending_prod++;
-		spin_unlock_irqrestore(&vif->response_lock, flags);
+	pending_tx_info = &vif->pending_tx_info[pending_idx];
+	spin_lock_irqsave(&vif->response_lock, flags);
+	make_tx_response(vif, &pending_tx_info->req, status);
+	index = pending_index(vif->pending_prod);
+	vif->pending_ring[index] = pending_idx;
+	/* TX shouldn't use the index before we give it back here */
+	mb();
+	vif->pending_prod++;
+	spin_unlock_irqrestore(&vif->response_lock, flags);
 }
 
 void xenvif_idx_unmap(struct xenvif *vif, u16 pending_idx)
