From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 2/4] xen/netback: don't leak pages on failure in xen_netbk_tx_check_gop.
Date: Wed, 6 Feb 2013 17:18:16 +0000
Message-ID: <1360171098-1240-2-git-send-email-ian.campbell@citrix.com>
References: <1360171081.32479.20.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xen-devel@lists.xen.org>, Matthew Daley <mattjd@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:46083 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756080Ab3BFRSV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 12:18:21 -0500
In-Reply-To: <1360171081.32479.20.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Daley <mattjd@gmail.com>

Signed-off-by: Matthew Daley <mattjd@gmail.com>
Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Acked-by: Ian Campbell <ian.campbell@citrix.com>
Acked-by: Jan Beulich <JBeulich@suse.com>
---
 drivers/net/xen-netback/netback.c |   38 ++++++++++++------------------------
 1 files changed, 13 insertions(+), 25 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 1a449f9..975241e 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -147,7 +147,8 @@ void xen_netbk_remove_xenvif(struct xenvif *vif)
 	atomic_dec(&netbk->netfront_count);
 }
 
-static void xen_netbk_idx_release(struct xen_netbk *netbk, u16 pending_idx);
+static void xen_netbk_idx_release(struct xen_netbk *netbk, u16 pending_idx,
+				  u8 status);
 static void make_tx_response(struct xenvif *vif,
 			     struct xen_netif_tx_request *txp,
 			     s8       st);
@@ -1007,30 +1008,20 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
 {
 	struct gnttab_copy *gop = *gopp;
 	u16 pending_idx = *((u16 *)skb->data);
-	struct pending_tx_info *pending_tx_info = netbk->pending_tx_info;
-	struct xenvif *vif = pending_tx_info[pending_idx].vif;
-	struct xen_netif_tx_request *txp;
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
 	int nr_frags = shinfo->nr_frags;
 	int i, err, start;
 
 	/* Check status of header. */
 	err = gop->status;
-	if (unlikely(err)) {
-		pending_ring_idx_t index;
-		index = pending_index(netbk->pending_prod++);
-		txp = &pending_tx_info[pending_idx].req;
-		make_tx_response(vif, txp, XEN_NETIF_RSP_ERROR);
-		netbk->pending_ring[index] = pending_idx;
-		xenvif_put(vif);
-	}
+	if (unlikely(err))
+		xen_netbk_idx_release(netbk, pending_idx, XEN_NETIF_RSP_ERROR);
 
 	/* Skip first skb fragment if it is on same page as header fragment. */
 	start = (frag_get_pending_idx(&shinfo->frags[0]) == pending_idx);
 
 	for (i = start; i < nr_frags; i++) {
 		int j, newerr;
-		pending_ring_idx_t index;
 
 		pending_idx = frag_get_pending_idx(&shinfo->frags[i]);
 
@@ -1039,16 +1030,12 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
 		if (likely(!newerr)) {
 			/* Had a previous error? Invalidate this fragment. */
 			if (unlikely(err))
-				xen_netbk_idx_release(netbk, pending_idx);
+				xen_netbk_idx_release(netbk, pending_idx, XEN_NETIF_RSP_OKAY);
 			continue;
 		}
 
 		/* Error on this fragment: respond to client with an error. */
-		txp = &netbk->pending_tx_info[pending_idx].req;
-		make_tx_response(vif, txp, XEN_NETIF_RSP_ERROR);
-		index = pending_index(netbk->pending_prod++);
-		netbk->pending_ring[index] = pending_idx;
-		xenvif_put(vif);
+		xen_netbk_idx_release(netbk, pending_idx, XEN_NETIF_RSP_ERROR);
 
 		/* Not the first error? Preceding frags already invalidated. */
 		if (err)
@@ -1056,10 +1043,10 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
 
 		/* First error: invalidate header and preceding fragments. */
 		pending_idx = *((u16 *)skb->data);
-		xen_netbk_idx_release(netbk, pending_idx);
+		xen_netbk_idx_release(netbk, pending_idx, XEN_NETIF_RSP_OKAY);
 		for (j = start; j < i; j++) {
 			pending_idx = frag_get_pending_idx(&shinfo->frags[j]);
-			xen_netbk_idx_release(netbk, pending_idx);
+			xen_netbk_idx_release(netbk, pending_idx, XEN_NETIF_RSP_OKAY);
 		}
 
 		/* Remember the error: invalidate all subsequent fragments. */
@@ -1093,7 +1080,7 @@ static void xen_netbk_fill_frags(struct xen_netbk *netbk, struct sk_buff *skb)
 
 		/* Take an extra reference to offset xen_netbk_idx_release */
 		get_page(netbk->mmap_pages[pending_idx]);
-		xen_netbk_idx_release(netbk, pending_idx);
+		xen_netbk_idx_release(netbk, pending_idx, XEN_NETIF_RSP_OKAY);
 	}
 }
 
@@ -1477,7 +1464,7 @@ static void xen_netbk_tx_submit(struct xen_netbk *netbk)
 			txp->size -= data_len;
 		} else {
 			/* Schedule a response immediately. */
-			xen_netbk_idx_release(netbk, pending_idx);
+			xen_netbk_idx_release(netbk, pending_idx, XEN_NETIF_RSP_OKAY);
 		}
 
 		if (txp->flags & XEN_NETTXF_csum_blank)
@@ -1529,7 +1516,8 @@ static void xen_netbk_tx_action(struct xen_netbk *netbk)
 	xen_netbk_tx_submit(netbk);
 }
 
-static void xen_netbk_idx_release(struct xen_netbk *netbk, u16 pending_idx)
+static void xen_netbk_idx_release(struct xen_netbk *netbk, u16 pending_idx,
+				  u8 status)
 {
 	struct xenvif *vif;
 	struct pending_tx_info *pending_tx_info;
@@ -1543,7 +1531,7 @@ static void xen_netbk_idx_release(struct xen_netbk *netbk, u16 pending_idx)
 
 	vif = pending_tx_info->vif;
 
-	make_tx_response(vif, &pending_tx_info->req, XEN_NETIF_RSP_OKAY);
+	make_tx_response(vif, &pending_tx_info->req, status);
 
 	index = pending_index(netbk->pending_prod++);
 	netbk->pending_ring[index] = pending_idx;
-- 
1.7.2.5
