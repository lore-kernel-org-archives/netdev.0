From: David Miller <davem@davemloft.net>
Subject: [PATCH 15/16] ipv4: Calling ->cow_metrics() now is a bug.
Date: Tue, 10 Jul 2012 08:07:55 -0700 (PDT)
Message-ID: <20120710.080755.834084229701598192.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38429 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754962Ab2GJPHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 11:07:55 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 63E45586620
	for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 08:07:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Nothing every writes to ipv4 metrics any longer.

PMTU is stored in rt->rt_pmtu.

Dynamic TCP metrics are stored in a special TCP metrics cache,
completely outside of the routes.

Therefore ->cow_metrics() can simply nothing more than a WARN_ON
trigger so we can catch anyone who tries to add new writes to
ipv4 route metrics.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |   30 ++----------------------------
 1 file changed, 2 insertions(+), 28 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a967df5..9cc00f8 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -158,34 +158,8 @@ static void ipv4_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 
 static u32 *ipv4_cow_metrics(struct dst_entry *dst, unsigned long old)
 {
-	struct rtable *rt = (struct rtable *) dst;
-	struct inet_peer *peer;
-	u32 *p = NULL;
-
-	peer = rt_get_peer_create(rt, rt->rt_dst);
-	if (peer) {
-		u32 *old_p = __DST_METRICS_PTR(old);
-		unsigned long prev, new;
-
-		p = peer->metrics;
-		if (inet_metrics_new(peer))
-			memcpy(p, old_p, sizeof(u32) * RTAX_MAX);
-
-		new = (unsigned long) p;
-		prev = cmpxchg(&dst->_metrics, old, new);
-
-		if (prev != old) {
-			p = __DST_METRICS_PTR(prev);
-			if (prev & DST_METRICS_READ_ONLY)
-				p = NULL;
-		} else {
-			if (rt->fi) {
-				fib_info_put(rt->fi);
-				rt->fi = NULL;
-			}
-		}
-	}
-	return p;
+	WARN_ON(1);
+	return NULL;
 }
 
 static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst,
-- 
1.7.10.4
