From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Don't miss existing cached metrics in new routes.
Date: Fri, 04 Feb 2011 14:40:10 -0800 (PST)
Message-ID: <20110204.144010.39169602.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60173
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751911Ab1BDWjf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Feb 2011 17:39:35 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 078A224C087
	for <netdev@vger.kernel.org>; Fri,  4 Feb 2011 14:40:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Always lookup to see if we have an existing inetpeer entry for
a route.  Let FLOWI_FLAG_PRECOW_METRICS merely influence the
"create" argument to rt_bind_peer().

Also, call rt_bind_peer() unconditionally since it is not
possible for rt->peer to be non-NULL at this point.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

Committed to net-next-2.6

 net/ipv4/route.c |   31 +++++++++++++++++--------------
 1 files changed, 17 insertions(+), 14 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e4c8165..0ba6a38 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1859,25 +1859,28 @@ static unsigned int ipv4_default_mtu(const struct dst_entry *dst)
 
 static void rt_init_metrics(struct rtable *rt, struct fib_info *fi)
 {
-	if (!(rt->fl.flags & FLOWI_FLAG_PRECOW_METRICS)) {
-	no_cow:
-		if (fi->fib_metrics != (u32 *) dst_default_metrics) {
-			rt->fi = fi;
-			atomic_inc(&fi->fib_clntref);
-		}
-		dst_init_metrics(&rt->dst, fi->fib_metrics, true);
-	} else {
-		struct inet_peer *peer;
+	struct inet_peer *peer;
+	int create = 0;
 
-		if (!rt->peer)
-			rt_bind_peer(rt, 1);
-		peer = rt->peer;
-		if (!peer)
-			goto no_cow;
+	/* If a peer entry exists for this destination, we must hook
+	 * it up in order to get at cached metrics.
+	 */
+	if (rt->fl.flags & FLOWI_FLAG_PRECOW_METRICS)
+		create = 1;
+
+	rt_bind_peer(rt, create);
+	peer = rt->peer;
+	if (peer) {
 		if (inet_metrics_new(peer))
 			memcpy(peer->metrics, fi->fib_metrics,
 			       sizeof(u32) * RTAX_MAX);
 		dst_init_metrics(&rt->dst, peer->metrics, false);
+	} else {
+		if (fi->fib_metrics != (u32 *) dst_default_metrics) {
+			rt->fi = fi;
+			atomic_inc(&fi->fib_clntref);
+		}
+		dst_init_metrics(&rt->dst, fi->fib_metrics, true);
 	}
 }
 
-- 
1.7.4

