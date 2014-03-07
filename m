From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net v2] ipv6: do not overwrite inetpeer metrics prematurely
Date: Fri,  7 Mar 2014 13:36:28 +0100 (CET)
Message-ID: <20140307123628.276E7E6E04@unicorn.suse.cz>
References: <20140306200658.GA32699@unicorn.suse.cz>
Cc: netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:47313 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751082AbaCGMgd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Mar 2014 07:36:33 -0500
In-Reply-To: <20140306200658.GA32699@unicorn.suse.cz>
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
actually inserted in fib6_add_rt2node() (so that we don't have
to care about simultaneous access).

v2: rather than trying to (ab)use ipv6_cow_metrics(), add a new
function doing only what is actually needed. Keep some checks in
an inline wrapper to avoid a function call in most cases.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 include/net/ip6_route.h |  1 +
 net/ipv6/ip6_fib.c      | 10 ++++++++++
 net/ipv6/route.c        | 28 +++++++++++++++++++++++-----
 3 files changed, 34 insertions(+), 5 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 017badb..abb3bfa 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -117,6 +117,7 @@ int rt6_dump_route(struct rt6_info *rt, void *p_arg);
 void rt6_ifdown(struct net *net, struct net_device *dev);
 void rt6_mtu_change(struct net_device *dev, unsigned int mtu);
 void rt6_remove_prefsrc(struct inet6_ifaddr *ifp);
+void rt6_move_metrics_to_peer(struct rt6_info *rt);
 
 
 /*
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 075602f..454eff7 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -638,6 +638,14 @@ static inline bool rt6_qualify_for_ecmp(struct rt6_info *rt)
 	       RTF_GATEWAY;
 }
 
+static inline void rt6_metrics_to_peer(struct rt6_info *rt)
+{
+	struct dst_entry *dst = &rt->dst;
+
+	if ((dst->flags & DST_HOST) && !dst_metrics_read_only(dst))
+		rt6_move_metrics_to_peer(rt);
+}
+
 /*
  *	Insert routing information in a node.
  */
@@ -752,6 +760,7 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 
 add:
 		rt->dst.rt6_next = iter;
+		rt6_metrics_to_peer(rt);
 		*ins = rt;
 		rt->rt6i_node = fn;
 		atomic_inc(&rt->rt6i_ref);
@@ -770,6 +779,7 @@ add:
 			pr_warn("NLM_F_REPLACE set, but no existing node found!\n");
 			return -ENOENT;
 		}
+		rt6_metrics_to_peer(rt);
 		*ins = rt;
 		rt->rt6i_node = fn;
 		rt->dst.rt6_next = iter->dst.rt6_next;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index fba54a4..6edc32e 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -164,6 +164,24 @@ static u32 *ipv6_cow_metrics(struct dst_entry *dst, unsigned long old)
 	return p;
 }
 
+/*	Copy standalone metrics to inetpeer and free the block.
+ *	Assumes that route is not inserted yet and that caller checked
+ *	the metrics are not read-only.
+ */
+
+void rt6_move_metrics_to_peer(struct rt6_info *rt)
+{
+	struct dst_entry *dst = &rt->dst;
+	struct inet_peer *peer = rt6_get_peer_create(rt);
+	u32 *old = dst_metrics_ptr(dst);
+
+	if (!peer || old == peer->metrics)
+		return;
+	memcpy(peer->metrics, old, RTAX_MAX * sizeof(u32));
+	dst_init_metrics(dst, peer->metrics, false);
+	kfree(old);
+}
+
 static inline const void *choose_neigh_daddr(struct rt6_info *rt,
 					     struct sk_buff *skb,
 					     const void *daddr)
@@ -324,8 +342,10 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 	struct rt6_info *rt = (struct rt6_info *)dst;
 	struct inet6_dev *idev = rt->rt6i_idev;
 	struct dst_entry *from = dst->from;
+	struct inet_peer *peer = rt6_has_peer(rt) ? rt6_peer_ptr(rt) : NULL;
 
-	if (!(rt->dst.flags & DST_HOST))
+	if (!(dst->flags & DST_HOST) || !peer ||
+	    DST_METRICS_PTR(dst) != peer->metrics)
 		dst_destroy_metrics_generic(dst);
 
 	if (idev) {
@@ -336,10 +356,8 @@ static void ip6_dst_destroy(struct dst_entry *dst)
 	dst->from = NULL;
 	dst_release(from);
 
-	if (rt6_has_peer(rt)) {
-		struct inet_peer *peer = rt6_peer_ptr(rt);
+	if (peer)
 		inet_putpeer(peer);
-	}
 }
 
 static void ip6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
@@ -1546,7 +1564,7 @@ int ip6_route_add(struct fib6_config *cfg)
 	if (rt->rt6i_dst.plen == 128)
 	       rt->dst.flags |= DST_HOST;
 
-	if (!(rt->dst.flags & DST_HOST) && cfg->fc_mx) {
+	if (cfg->fc_mx) {
 		u32 *metrics = kzalloc(sizeof(u32) * RTAX_MAX, GFP_KERNEL);
 		if (!metrics) {
 			err = -ENOMEM;
-- 
1.8.1.4
