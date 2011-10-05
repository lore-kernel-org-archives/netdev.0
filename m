From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 2/8] xen: netback: convert to SKB paged frag API.
Date: Wed, 5 Oct 2011 11:28:46 +0100
Message-ID: <1317810532-24984-2-git-send-email-ian.campbell@citrix.com>
References: <1317810511.21903.204.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	xen-devel@lists.xensource.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:27833 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934263Ab1JEK3F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Oct 2011 06:29:05 -0400
In-Reply-To: <1317810511.21903.204.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netback currently uses frag->page to store a temporary index reference while
processing incoming requests. Since frag->page is to become opaque switch
instead to using page_offset. Add a wrapper to tidy this up and propagate the
fact that the indexes are only u16 through the code (this was already true in
practice but unsigned long and in were inconsistently used as variable and
parameter types)

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: xen-devel@lists.xensource.com
Cc: netdev@vger.kernel.org
---
 drivers/net/xen-netback/netback.c |   54 ++++++++++++++++++++++--------------
 1 files changed, 33 insertions(+), 21 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index fd00f25..8d70b44 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -60,6 +60,9 @@ struct netbk_rx_meta {
 
 #define MAX_PENDING_REQS 256
 
+/* Discriminate from any valid pending_idx value. */
+#define INVALID_PENDING_IDX 0xFFFF
+
 #define MAX_BUFFER_OFFSET PAGE_SIZE
 
 /* extra field used in struct page */
@@ -155,13 +158,13 @@ static struct xen_netif_rx_response *make_rx_response(struct xenvif *vif,
 					     u16      flags);
 
 static inline unsigned long idx_to_pfn(struct xen_netbk *netbk,
-				       unsigned int idx)
+				       u16 idx)
 {
 	return page_to_pfn(netbk->mmap_pages[idx]);
 }
 
 static inline unsigned long idx_to_kaddr(struct xen_netbk *netbk,
-					 unsigned int idx)
+					 u16 idx)
 {
 	return (unsigned long)pfn_to_kaddr(idx_to_pfn(netbk, idx));
 }
@@ -215,6 +218,16 @@ static int get_page_ext(struct page *pg,
 			 sizeof(struct iphdr) + MAX_IPOPTLEN + \
 			 sizeof(struct tcphdr) + MAX_TCP_OPTION_SPACE)
 
+static u16 frag_get_pending_idx(skb_frag_t *frag)
+{
+	return (u16)frag->page_offset;
+}
+
+static void frag_set_pending_idx(skb_frag_t *frag, u16 pending_idx)
+{
+	frag->page_offset = pending_idx;
+}
+
 static inline pending_ring_idx_t pending_index(unsigned i)
 {
 	return i & (MAX_PENDING_REQS-1);
@@ -512,7 +525,7 @@ static int netbk_gop_skb(struct sk_buff *skb,
 
 	for (i = 0; i < nr_frags; i++) {
 		netbk_gop_frag_copy(vif, skb, npo,
-				    skb_shinfo(skb)->frags[i].page,
+				    skb_frag_page(&skb_shinfo(skb)->frags[i]),
 				    skb_shinfo(skb)->frags[i].size,
 				    skb_shinfo(skb)->frags[i].page_offset,
 				    &head);
@@ -890,7 +903,7 @@ static int netbk_count_requests(struct xenvif *vif,
 
 static struct page *xen_netbk_alloc_page(struct xen_netbk *netbk,
 					 struct sk_buff *skb,
-					 unsigned long pending_idx)
+					 u16 pending_idx)
 {
 	struct page *page;
 	page = alloc_page(GFP_KERNEL|__GFP_COLD);
@@ -909,11 +922,11 @@ static struct gnttab_copy *xen_netbk_get_requests(struct xen_netbk *netbk,
 {
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
 	skb_frag_t *frags = shinfo->frags;
-	unsigned long pending_idx = *((u16 *)skb->data);
+	u16 pending_idx = *((u16 *)skb->data);
 	int i, start;
 
 	/* Skip first skb fragment if it is on same page as header fragment. */
-	start = ((unsigned long)shinfo->frags[0].page == pending_idx);
+	start = (frag_get_pending_idx(&shinfo->frags[0]) == pending_idx);
 
 	for (i = start; i < shinfo->nr_frags; i++, txp++) {
 		struct page *page;
@@ -945,7 +958,7 @@ static struct gnttab_copy *xen_netbk_get_requests(struct xen_netbk *netbk,
 		memcpy(&pending_tx_info[pending_idx].req, txp, sizeof(*txp));
 		xenvif_get(vif);
 		pending_tx_info[pending_idx].vif = vif;
-		frags[i].page = (void *)pending_idx;
+		frag_set_pending_idx(&frags[i], pending_idx);
 	}
 
 	return gop;
@@ -956,7 +969,7 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
 				  struct gnttab_copy **gopp)
 {
 	struct gnttab_copy *gop = *gopp;
-	int pending_idx = *((u16 *)skb->data);
+	u16 pending_idx = *((u16 *)skb->data);
 	struct pending_tx_info *pending_tx_info = netbk->pending_tx_info;
 	struct xenvif *vif = pending_tx_info[pending_idx].vif;
 	struct xen_netif_tx_request *txp;
@@ -976,13 +989,13 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
 	}
 
 	/* Skip first skb fragment if it is on same page as header fragment. */
-	start = ((unsigned long)shinfo->frags[0].page == pending_idx);
+	start = (frag_get_pending_idx(&shinfo->frags[0]) == pending_idx);
 
 	for (i = start; i < nr_frags; i++) {
 		int j, newerr;
 		pending_ring_idx_t index;
 
-		pending_idx = (unsigned long)shinfo->frags[i].page;
+		pending_idx = frag_get_pending_idx(&shinfo->frags[i]);
 
 		/* Check error status: if okay then remember grant handle. */
 		newerr = (++gop)->status;
@@ -1008,7 +1021,7 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
 		pending_idx = *((u16 *)skb->data);
 		xen_netbk_idx_release(netbk, pending_idx);
 		for (j = start; j < i; j++) {
-			pending_idx = (unsigned long)shinfo->frags[i].page;
+			pending_idx = frag_get_pending_idx(&shinfo->frags[i]);
 			xen_netbk_idx_release(netbk, pending_idx);
 		}
 
@@ -1029,15 +1042,14 @@ static void xen_netbk_fill_frags(struct xen_netbk *netbk, struct sk_buff *skb)
 	for (i = 0; i < nr_frags; i++) {
 		skb_frag_t *frag = shinfo->frags + i;
 		struct xen_netif_tx_request *txp;
-		unsigned long pending_idx;
+		struct page *page;
+		u16 pending_idx;
 
-		pending_idx = (unsigned long)frag->page;
+		pending_idx = frag_get_pending_idx(frag);
 
 		txp = &netbk->pending_tx_info[pending_idx].req;
-		frag->page = virt_to_page(idx_to_kaddr(netbk, pending_idx));
-		frag->size = txp->size;
-		frag->page_offset = txp->offset;
-
+		page = virt_to_page(idx_to_kaddr(netbk, pending_idx));
+		__skb_fill_page_desc(skb, i, page, txp->offset, txp->size);
 		skb->len += txp->size;
 		skb->data_len += txp->size;
 		skb->truesize += txp->size;
@@ -1349,11 +1361,11 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
 		skb_shinfo(skb)->nr_frags = ret;
 		if (data_len < txreq.size) {
 			skb_shinfo(skb)->nr_frags++;
-			skb_shinfo(skb)->frags[0].page =
-				(void *)(unsigned long)pending_idx;
+			frag_set_pending_idx(&skb_shinfo(skb)->frags[0],
+					     pending_idx);
 		} else {
-			/* Discriminate from any valid pending_idx value. */
-			skb_shinfo(skb)->frags[0].page = (void *)~0UL;
+			frag_set_pending_idx(&skb_shinfo(skb)->frags[0],
+					     INVALID_PENDING_IDX);
 		}
 
 		__skb_queue_tail(&netbk->tx_queue, skb);
-- 
1.7.2.5
