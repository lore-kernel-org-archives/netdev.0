From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 3/8] xen: netfront: convert to SKB paged frag API.
Date: Wed, 5 Oct 2011 11:28:47 +0100
Message-ID: <1317810532-24984-3-git-send-email-ian.campbell@citrix.com>
References: <1317810511.21903.204.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	xen-devel@lists.xensource.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:34524 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934263Ab1JEK26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 06:28:58 -0400
In-Reply-To: <1317810511.21903.204.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: xen-devel@lists.xensource.com
Cc: netdev@vger.kernel.org
---
 drivers/net/xen-netfront.c |   34 +++++++++++++++++++---------------
 1 files changed, 19 insertions(+), 15 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index d7c8a98..6e5d4c0 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -275,7 +275,7 @@ no_skb:
 			break;
 		}
 
-		skb_shinfo(skb)->frags[0].page = page;
+		__skb_fill_page_desc(skb, 0, page, 0, 0);
 		skb_shinfo(skb)->nr_frags = 1;
 		__skb_queue_tail(&np->rx_batch, skb);
 	}
@@ -309,8 +309,8 @@ no_skb:
 		BUG_ON((signed short)ref < 0);
 		np->grant_rx_ref[id] = ref;
 
-		pfn = page_to_pfn(skb_shinfo(skb)->frags[0].page);
-		vaddr = page_address(skb_shinfo(skb)->frags[0].page);
+		pfn = page_to_pfn(skb_frag_page(&skb_shinfo(skb)->frags[0]));
+		vaddr = page_address(skb_frag_page(&skb_shinfo(skb)->frags[0]));
 
 		req = RING_GET_REQUEST(&np->rx, req_prod + i);
 		gnttab_grant_foreign_access_ref(ref,
@@ -461,7 +461,7 @@ static void xennet_make_frags(struct sk_buff *skb, struct net_device *dev,
 		ref = gnttab_claim_grant_reference(&np->gref_tx_head);
 		BUG_ON((signed short)ref < 0);
 
-		mfn = pfn_to_mfn(page_to_pfn(frag->page));
+		mfn = pfn_to_mfn(page_to_pfn(skb_frag_page(frag)));
 		gnttab_grant_foreign_access_ref(ref, np->xbdev->otherend_id,
 						mfn, GNTMAP_readonly);
 
@@ -762,23 +762,22 @@ static RING_IDX xennet_fill_frags(struct netfront_info *np,
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
 	int nr_frags = shinfo->nr_frags;
 	RING_IDX cons = np->rx.rsp_cons;
-	skb_frag_t *frag = shinfo->frags + nr_frags;
 	struct sk_buff *nskb;
 
 	while ((nskb = __skb_dequeue(list))) {
 		struct xen_netif_rx_response *rx =
 			RING_GET_RESPONSE(&np->rx, ++cons);
+		skb_frag_t *nfrag = &skb_shinfo(nskb)->frags[0];
 
-		frag->page = skb_shinfo(nskb)->frags[0].page;
-		frag->page_offset = rx->offset;
-		frag->size = rx->status;
+		__skb_fill_page_desc(skb, nr_frags,
+				     skb_frag_page(nfrag),
+				     rx->offset, rx->status);
 
 		skb->data_len += rx->status;
 
 		skb_shinfo(nskb)->nr_frags = 0;
 		kfree_skb(nskb);
 
-		frag++;
 		nr_frags++;
 	}
 
@@ -873,7 +872,7 @@ static int handle_incoming_queue(struct net_device *dev,
 		memcpy(skb->data, vaddr + offset,
 		       skb_headlen(skb));
 
-		if (page != skb_shinfo(skb)->frags[0].page)
+		if (page != skb_frag_page(&skb_shinfo(skb)->frags[0]))
 			__free_page(page);
 
 		/* Ethernet work: Delayed to here as it peeks the header. */
@@ -954,7 +953,8 @@ err:
 			}
 		}
 
-		NETFRONT_SKB_CB(skb)->page = skb_shinfo(skb)->frags[0].page;
+		NETFRONT_SKB_CB(skb)->page =
+			skb_frag_page(&skb_shinfo(skb)->frags[0]);
 		NETFRONT_SKB_CB(skb)->offset = rx->offset;
 
 		len = rx->status;
@@ -968,7 +968,7 @@ err:
 			skb_shinfo(skb)->frags[0].size = rx->status - len;
 			skb->data_len = rx->status - len;
 		} else {
-			skb_shinfo(skb)->frags[0].page = NULL;
+			__skb_fill_page_desc(skb, 0, NULL, 0, 0);
 			skb_shinfo(skb)->nr_frags = 0;
 		}
 
@@ -1143,7 +1143,8 @@ static void xennet_release_rx_bufs(struct netfront_info *np)
 
 		if (!xen_feature(XENFEAT_auto_translated_physmap)) {
 			/* Remap the page. */
-			struct page *page = skb_shinfo(skb)->frags[0].page;
+			const struct page *page =
+				skb_frag_page(&skb_shinfo(skb)->frags[0]);
 			unsigned long pfn = page_to_pfn(page);
 			void *vaddr = page_address(page);
 
@@ -1650,6 +1651,8 @@ static int xennet_connect(struct net_device *dev)
 
 	/* Step 2: Rebuild the RX buffer freelist and the RX ring itself. */
 	for (requeue_idx = 0, i = 0; i < NET_RX_RING_SIZE; i++) {
+		skb_frag_t *frag;
+		const struct page *page;
 		if (!np->rx_skbs[i])
 			continue;
 
@@ -1657,10 +1660,11 @@ static int xennet_connect(struct net_device *dev)
 		ref = np->grant_rx_ref[requeue_idx] = xennet_get_rx_ref(np, i);
 		req = RING_GET_REQUEST(&np->rx, requeue_idx);
 
+		frag = &skb_shinfo(skb)->frags[0];
+		page = skb_frag_page(frag);
 		gnttab_grant_foreign_access_ref(
 			ref, np->xbdev->otherend_id,
-			pfn_to_mfn(page_to_pfn(skb_shinfo(skb)->
-					       frags->page)),
+			pfn_to_mfn(page_to_pfn(page)),
 			0);
 		req->gref = ref;
 		req->id   = requeue_idx;
-- 
1.7.2.5
