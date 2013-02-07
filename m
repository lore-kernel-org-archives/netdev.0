From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH v2 3/4] xen/netback: free already allocated memory on failure in xen_netbk_get_requests
Date: Thu, 7 Feb 2013 09:41:37 +0000
Message-ID: <1360230098-28218-3-git-send-email-ian.campbell@citrix.com>
References: <1360230078.32479.41.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xen-devel@lists.xen.org>, Ian Campbell <ian.campbell@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:26424 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754553Ab3BGJlk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 04:41:40 -0500
In-Reply-To: <1360230078.32479.41.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: <stable@vger.kernel.org> # 3.0+
---
v2: s/reponses/responses/ (blp) & fixup block comment style (DaveM)
---
 drivers/net/xen-netback/netback.c |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index bf692df..dcb2d4d 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -978,7 +978,7 @@ static struct gnttab_copy *xen_netbk_get_requests(struct xen_netbk *netbk,
 		pending_idx = netbk->pending_ring[index];
 		page = xen_netbk_alloc_page(netbk, skb, pending_idx);
 		if (!page)
-			return NULL;
+			goto err;
 
 		gop->source.u.ref = txp->gref;
 		gop->source.domid = vif->domid;
@@ -1000,6 +1000,17 @@ static struct gnttab_copy *xen_netbk_get_requests(struct xen_netbk *netbk,
 	}
 
 	return gop;
+err:
+	/* Unwind, freeing all pages and sending error responses. */
+	while (i-- > start) {
+		xen_netbk_idx_release(netbk, frag_get_pending_idx(&frags[i]),
+				      XEN_NETIF_RSP_ERROR);
+	}
+	/* The head too, if necessary. */
+	if (start)
+		xen_netbk_idx_release(netbk, pending_idx, XEN_NETIF_RSP_ERROR);
+
+	return NULL;
 }
 
 static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
-- 
1.7.2.5
