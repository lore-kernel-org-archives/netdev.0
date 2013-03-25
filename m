From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH 3/6] xen-netfront: frags -> slots in xennet_get_responses
Date: Mon, 25 Mar 2013 11:08:19 +0000
Message-ID: <1364209702-12437-4-git-send-email-wei.liu2@citrix.com>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ian.campbell@citrix.com>, <annie.li@oracle.com>,
	<konrad.wilk@oracle.com>, <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:56407 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756518Ab3CYLJE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Mar 2013 07:09:04 -0400
In-Reply-To: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function is in fact counting the ring slots required for responses.
Separate the concepts of ring slots and skb frags make the code clearer, as
now netfront and netback can have different MAX_SKB_FRAGS, slot and frag are
not mapped 1:1 any more.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netfront.c |   18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 3ae9dc1..52f5010 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -724,7 +724,7 @@ static int xennet_get_responses(struct netfront_info *np,
 	struct sk_buff *skb = xennet_get_rx_skb(np, cons);
 	grant_ref_t ref = xennet_get_rx_ref(np, cons);
 	int max = MAX_SKB_FRAGS + (rx->status <= RX_COPY_THRESHOLD);
-	int frags = 1;
+	int slots = 1;
 	int err = 0;
 	unsigned long ret;
 
@@ -768,27 +768,27 @@ next:
 		if (!(rx->flags & XEN_NETRXF_more_data))
 			break;
 
-		if (cons + frags == rp) {
+		if (cons + slots == rp) {
 			if (net_ratelimit())
-				dev_warn(dev, "Need more frags\n");
+				dev_warn(dev, "Need more slots\n");
 			err = -ENOENT;
 			break;
 		}
 
-		rx = RING_GET_RESPONSE(&np->rx, cons + frags);
-		skb = xennet_get_rx_skb(np, cons + frags);
-		ref = xennet_get_rx_ref(np, cons + frags);
-		frags++;
+		rx = RING_GET_RESPONSE(&np->rx, cons + slots);
+		skb = xennet_get_rx_skb(np, cons + slots);
+		ref = xennet_get_rx_ref(np, cons + slots);
+		slots++;
 	}
 
-	if (unlikely(frags > max)) {
+	if (unlikely(slots > max)) {
 		if (net_ratelimit())
 			dev_warn(dev, "Too many frags\n");
 		err = -E2BIG;
 	}
 
 	if (unlikely(err))
-		np->rx.rsp_cons = cons + frags;
+		np->rx.rsp_cons = cons + slots;
 
 	return err;
 }
-- 
1.7.10.4
