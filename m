From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net] ipv6: do not overwrite inetpeer metrics prematurely
Date: Thu,  6 Mar 2014 10:50:54 +0100 (CET)
Message-ID: <20140306095054.EEC5EE6E04@unicorn.suse.cz>
Cc: netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:50506 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750908AbaCFJu5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2014 04:50:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an IPv6 host route with metrics exists, an attempt to add a
new route for the same target with different metrics fails but
rewrites the metrics anyway:

12sp0:~ # ip route add fec0::1 dev eth0 rto_min 1000
12sp0:~ # ip -6 route show
fe80::/64 dev eth0  proto kernel  metric 256
fec0::1 dev eth0  metric 1024  rto_min lock 1s
12sp0:~ # ip route add fec0::1 dev eth0 rto_min 1500
RTNETLINK answers: File exists
12sp0:~ # ip -6 route show
fe80::/64 dev eth0  proto kernel  metric 256
fec0::1 dev eth0  metric 1024  rto_min lock 1.5s

This is caused by all IPv6 host routes using the metrics in
their inetpeer (or the shared default). This also holds for the
new route created in ip6_route_add() which shares the metrics
with the already existing route and thus ip6_route_add()
rewrites the metrics even if the new route ends up not being
used at all.

Allocate separate metrics in ip6_route_add() and copy them into
inetpeer (and update dst->_metrics) just before the new route is
actually inserted in fib6_add_rt2node().

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 net/ipv6/ip6_fib.c | 28 ++++++++++++++++++++++++++++
 net/ipv6/route.c   | 10 +++++-----
 2 files changed, 33 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 075602f..3067715 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -638,6 +638,32 @@ static inline bool rt6_qualify_for_ecmp(struct rt6_info *rt)
 	       RTF_GATEWAY;
 }
 
+/*	Called just before inserting a new route into the tree.
+ *	If it is a host route and has its own metrics allocated, copy
+ *	them to its inetpeer (create and/or bind if needed) and free
+ *	the temporary block.
+ */
+
+static void rt6_metrics_to_peer(struct rt6_info *rt)
+{
+	struct inet_peer *peer = rt6_has_peer(rt) ? rt6_peer_ptr(rt) : NULL;
+	struct dst_entry *dst = &rt->dst;
+	unsigned long old = dst->_metrics;
+
+	if (!(rt->dst.flags & DST_HOST) || dst_metrics_read_only(dst))
+		return;
+	if (peer && dst_metrics_ptr(dst) == peer->metrics)
+		return;
+
+	dst->ops->cow_metrics(dst, old);
+	if (dst->_metrics != old) {
+		u32 *old_p = __DST_METRICS_PTR(old);
+
+		memcpy(dst_metrics_ptr(dst), old_p, RTAX_MAX * sizeof(u32));
+		kfree(old_p);
+	}
+}
+
 /*
  *	Insert routing information in a node.
  */
@@ -752,6 +778,7 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 
 add:
 		rt->dst.rt6_next = iter;
+		rt6_metrics_to_peer(rt);
 		*ins = rt;
 		rt->rt6i_node = fn;
 		atomic_inc(&rt->rt6i_ref);
@@ -770,6 +797,7 @@ add:
 			pr_warn("NLM_F_REPLACE set, but no existing node found!\n");
 			return -ENOENT;
 		}
+		rt6_metrics_to_peer(rt);
 		*ins = rt;
 		rt->rt6i_node = fn;
 		rt->dst.rt6_next = iter->dst.rt6_next;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 11dac21..4ba981e 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -324,8 +324,10 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 	struct rt6_info *rt = (struct rt6_info *)dst;
 	struct inet6_dev *idev = rt->rt6i_idev;
 	struct dst_entry *from = dst->from;
+	struct inet_peer *peer = rt6_has_peer(rt) ? rt6_peer_ptr(rt) : NULL;
 
-	if (!(rt->dst.flags & DST_HOST))
+	if (!(dst->flags & DST_HOST) || !peer ||
+	    DST_METRICS_PTR(dst) != peer->metrics)
 		dst_destroy_metrics_generic(dst);
 
 	if (idev) {
@@ -336,10 +338,8 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 	dst->from = NULL;
 	dst_release(from);
 
-	if (rt6_has_peer(rt)) {
-		struct inet_peer *peer = rt6_peer_ptr(rt);
+	if (peer)
 		inet_putpeer(peer);
-	}
 }
 
 static void ip6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
@@ -1546,7 +1546,7 @@ int ip6_route_add(struct fib6_config *cfg)
 	if (rt->rt6i_dst.plen == 128)
 	       rt->dst.flags |= DST_HOST;
 
-	if (!(rt->dst.flags & DST_HOST) && cfg->fc_mx) {
+	if (cfg->fc_mx) {
 		u32 *metrics = kzalloc(sizeof(u32) * RTAX_MAX, GFP_KERNEL);
 		if (!metrics) {
 			err = -ENOMEM;
-- 
1.8.1.4
