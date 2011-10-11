From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/4] ipv4: Update pmtu informations on inetpeer only for
 output routes
Date: Tue, 11 Oct 2011 13:10:27 +0200
Message-ID: <20111011111027.GE1830@secunet.com>
References: <20111011110842.GC1830@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:57882 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753264Ab1JKLKf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 07:10:35 -0400
Content-Disposition: inline
In-Reply-To: <20111011110842.GC1830@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The pmtu informations on the inetpeer are visible for output and
input routes. On packet forwarding, we might propagate a learned
pmtu to the sender. As we update the pmtu informations of the
inetpeer on demand, the original sender of the forwarded packets
might never notice when the pmtu to that inetpeer increases.
So propagate the nexthop mtu instead of the pmtu to the final
destination.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/route.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 075212e..9a6623e 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1579,9 +1579,10 @@ unsigned short ip_rt_frag_needed(struct net *net, const struct iphdr *iph,
 
 static void check_peer_pmtu(struct dst_entry *dst, struct inet_peer *peer)
 {
+	struct rtable *rt = (struct rtable *) dst;
 	unsigned long expires = ACCESS_ONCE(peer->pmtu_expires);
 
-	if (!expires)
+	if (rt_is_input_route(rt) || !expires)
 		return;
 	if (time_before(jiffies, expires)) {
 		u32 orig_dst_mtu = dst_mtu(dst);
@@ -1803,6 +1804,7 @@ static void rt_init_metrics(struct rtable *rt, const struct flowi4 *fl4,
 			    struct fib_info *fi)
 {
 	struct inet_peer *peer;
+	struct dst_entry *dst = &rt->dst;
 	int create = 0;
 
 	/* If a peer entry exists for this destination, we must hook
@@ -1817,9 +1819,14 @@ static void rt_init_metrics(struct rtable *rt, const struct flowi4 *fl4,
 		if (inet_metrics_new(peer))
 			memcpy(peer->metrics, fi->fib_metrics,
 			       sizeof(u32) * RTAX_MAX);
-		dst_init_metrics(&rt->dst, peer->metrics, false);
 
-		check_peer_pmtu(&rt->dst, peer);
+		dst_init_metrics(dst, peer->metrics, false);
+		check_peer_pmtu(dst, peer);
+
+		if (rt_is_input_route(rt))
+			dst_metric_set(dst, RTAX_MTU,
+				       dst->ops->default_mtu(dst));
+
 		if (peer->redirect_learned.a4 &&
 		    peer->redirect_learned.a4 != rt->rt_gateway) {
 			rt->rt_gateway = peer->redirect_learned.a4;
@@ -1830,7 +1837,7 @@ static void rt_init_metrics(struct rtable *rt, const struct flowi4 *fl4,
 			rt->fi = fi;
 			atomic_inc(&fi->fib_clntref);
 		}
-		dst_init_metrics(&rt->dst, fi->fib_metrics, true);
+		dst_init_metrics(dst, fi->fib_metrics, true);
 	}
 }
 
-- 
1.7.0.4
