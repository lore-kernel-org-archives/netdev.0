From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next v2] xen-netfront: clean up code in
 xennet_release_rx_bufs
Date: Fri, 17 Jan 2014 17:50:43 +0000
Message-ID: <52D96D73.1030803@citrix.com>
References: <1389830228-2381-1-git-send-email-Annie.li@oracle.com> <52D7BE19.2010009@citrix.com> <52D8CCE4.9010804@oracle.com> <20140117120810.GA11681@zion.uk.xensource.com> <52D922DD.2060407@oracle.com> <20140117140246.GB11681@zion.uk.xensource.com> <52D94F8C.7060509@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, <ian.campbell@citrix.com>,
	<netdev@vger.kernel.org>, <xen-devel@lists.xen.org>,
	<andrew.bennieston@citrix.com>, <davem@davemloft.net>
To: annie li <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:44913 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750937AbaAQRur (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 12:50:47 -0500
In-Reply-To: <52D94F8C.7060509@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/01/14 15:43, annie li wrote:
> 
> No, I am trying to implement 2 patches.

I don't understand the need for two patches here, particularly when
the first patch introduces a security issue.  You can fold the following 
(untested) patch into your v2 patch and give it a try?

Thanks.

David

8<----------------------
xen-netfront: prevent unsafe reuse of rx buf pages after uninit

---
 drivers/net/xen-netfront.c |   21 +++++++++++++++++----
 1 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 692589e..47aa599 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1134,19 +1134,32 @@ static void xennet_release_tx_bufs(struct netfront_info *np)
 
 static void xennet_release_rx_bufs(struct netfront_info *np)
 {
-	struct sk_buff *skb;
 	int id, ref;
 
 	spin_lock_bh(&np->rx_lock);
 
 	for (id = 0; id < NET_RX_RING_SIZE; id++) {
+		struct sk_buff *skb;
+		skb_frag_t *frag;
+		const struct page *page;
+
+		skb = np->rx_skbs[id];
+		if (!skb)
+			continue;
+
 		ref = np->grant_rx_ref[id];
 		if (ref == GRANT_INVALID_REF)
 			continue;
 
-		skb = np->rx_skbs[id];
-		gnttab_end_foreign_access_ref(ref, 0);
-		gnttab_release_grant_reference(&np->gref_rx_head, ref);
+		frag = &skb_shinfo(skb)->frags[0];
+		page = skb_frag_page(frag);
+
+		/* gnttab_end_foreign_access() needs a page ref until
+		 * foreign access is ended (which may be deferred).
+		 */
+		get_page(page);
+
+		gnttab_end_foreign_access(ref, 0, page);
 		np->grant_rx_ref[id] = GRANT_INVALID_REF;
 
 		kfree_skb(skb);
-- 
1.7.2.5
