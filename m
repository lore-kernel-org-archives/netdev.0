From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 62/75] xen: netback: convert to SKB paged frag
	API.
Date: Fri, 19 Aug 2011 14:27:34 +0100
Message-ID: <1313760467-8598-62-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
List-Unsubscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: xen-devel@lists.xensource.com
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/xen-netback/netback.c |   34 +++++++++++++++++++++++-----------
 1 files changed, 23 insertions(+), 11 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index fd00f25..3068f67 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -215,6 +215,16 @@ static int get_page_ext(struct page *pg,
 			 sizeof(struct iphdr) + MAX_IPOPTLEN + \
 			 sizeof(struct tcphdr) + MAX_TCP_OPTION_SPACE)
 
+static unsigned long frag_get_pending_idx(skb_frag_t *frag)
+{
+	return (unsigned long)skb_frag_page(frag);
+}
+
+static void frag_set_pending_idx(skb_frag_t *frag, unsigned long pending_idx)
+{
+	__skb_frag_set_page(frag, (void *)pending_idx);
+}
+
 static inline pending_ring_idx_t pending_index(unsigned i)
 {
 	return i & (MAX_PENDING_REQS-1);
@@ -512,7 +522,7 @@ static int netbk_gop_skb(struct sk_buff *skb,
 
 	for (i = 0; i < nr_frags; i++) {
 		netbk_gop_frag_copy(vif, skb, npo,
-				    skb_shinfo(skb)->frags[i].page,
+				    skb_frag_page(&skb_shinfo(skb)->frags[i]),
 				    skb_shinfo(skb)->frags[i].size,
 				    skb_shinfo(skb)->frags[i].page_offset,
 				    &head);
@@ -913,7 +923,7 @@ static struct gnttab_copy *xen_netbk_get_requests(struct xen_netbk *netbk,
 	int i, start;
 
 	/* Skip first skb fragment if it is on same page as header fragment. */
-	start = ((unsigned long)shinfo->frags[0].page == pending_idx);
+	start = (frag_get_pending_idx(&shinfo->frags[0]) == pending_idx);
 
 	for (i = start; i < shinfo->nr_frags; i++, txp++) {
 		struct page *page;
@@ -945,7 +955,7 @@ static struct gnttab_copy *xen_netbk_get_requests(struct xen_netbk *netbk,
 		memcpy(&pending_tx_info[pending_idx].req, txp, sizeof(*txp));
 		xenvif_get(vif);
 		pending_tx_info[pending_idx].vif = vif;
-		frags[i].page = (void *)pending_idx;
+		frag_set_pending_idx(&frags[i], pending_idx);
 	}
 
 	return gop;
@@ -976,13 +986,13 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
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
@@ -1008,7 +1018,7 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
 		pending_idx = *((u16 *)skb->data);
 		xen_netbk_idx_release(netbk, pending_idx);
 		for (j = start; j < i; j++) {
-			pending_idx = (unsigned long)shinfo->frags[i].page;
+			pending_idx = frag_get_pending_idx(&shinfo->frags[i]);
 			xen_netbk_idx_release(netbk, pending_idx);
 		}
 
@@ -1029,12 +1039,14 @@ static void xen_netbk_fill_frags(struct xen_netbk *netbk, struct sk_buff *skb)
 	for (i = 0; i < nr_frags; i++) {
 		skb_frag_t *frag = shinfo->frags + i;
 		struct xen_netif_tx_request *txp;
+		struct page *page;
 		unsigned long pending_idx;
 
-		pending_idx = (unsigned long)frag->page;
+		pending_idx = frag_get_pending_idx(frag);
 
 		txp = &netbk->pending_tx_info[pending_idx].req;
-		frag->page = virt_to_page(idx_to_kaddr(netbk, pending_idx));
+		page = virt_to_page(idx_to_kaddr(netbk, pending_idx));
+		__skb_frag_set_page(frag, page);
 		frag->size = txp->size;
 		frag->page_offset = txp->offset;
 
@@ -1349,11 +1361,11 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
 		skb_shinfo(skb)->nr_frags = ret;
 		if (data_len < txreq.size) {
 			skb_shinfo(skb)->nr_frags++;
-			skb_shinfo(skb)->frags[0].page =
-				(void *)(unsigned long)pending_idx;
+			frag_set_pending_idx(&skb_shinfo(skb)->frags[0],
+					     pending_idx);
 		} else {
 			/* Discriminate from any valid pending_idx value. */
-			skb_shinfo(skb)->frags[0].page = (void *)~0UL;
+			frag_set_pending_idx(&skb_shinfo(skb)->frags[0], ~0UL);
 		}
 
 		__skb_queue_tail(&netbk->tx_queue, skb);
-- 
1.7.2.5
