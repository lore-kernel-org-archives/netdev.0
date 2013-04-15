From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH V5 2/7] xen-netfront: frags -> slots in xennet_get_responses
Date: Mon, 15 Apr 2013 18:06:16 +0100
Message-ID: <1366045581-31349-3-git-send-email-wei.liu2@citrix.com>
References: <1366045581-31349-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <annie.li@oracle.com>, <konrad.wilk@oracle.com>,
	<jbeulich@suse.com>, <ian.campbell@citrix.com>,
	<wdauchy@gmail.com>, <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:32804 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755325Ab3DORGk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 13:06:40 -0400
In-Reply-To: <1366045581-31349-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function is in fact counting the ring slots required for responses.
Separate the concepts of ring slots and skb frags make the code clearer, as
now netfront and netback can have different MAX_SKB_FRAGS, slot and frag are
not mapped 1:1 any more.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Reviewed-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netfront.c |   18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 5527663..d9097a7 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -712,7 +712,7 @@ static int xennet_get_responses(struct netfront_info *np,
 	struct sk_buff *skb = xennet_get_rx_skb(np, cons);
 	grant_ref_t ref = xennet_get_rx_ref(np, cons);
 	int max = MAX_SKB_FRAGS + (rx->status <= RX_COPY_THRESHOLD);
-	int frags = 1;
+	int slots = 1;
 	int err = 0;
 	unsigned long ret;
 
@@ -756,27 +756,27 @@ next:
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
