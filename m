From: Nick Jones <nick.jones@network-box.com>
Subject: [PATCH net-next] ipv6: perform inetpeer binding at dst creation,
 with readonly option
Date: Tue, 06 Mar 2012 23:49:31 +0800
Message-ID: <4F56320B.60400@network-box.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from network-box.com ([175.45.17.220]:37717 "EHLO network-box.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754022Ab2CFQIs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2012 11:08:48 -0500
Received: from hqnickjones-macbook.local (unknown [10.8.2.241])
	by network-box.com (Postfix) with ESMTP id B38B73EAF4
	for <netdev@vger.kernel.org>; Tue,  6 Mar 2012 23:49:31 +0800 (HKT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A neighbour advertises itself as obsolete and at a later time, the host
sends solicitations to the neighbours direct address.  The NS icmp6
packets have hoplimit explicitly set to 255.

The neighbour re-advertises itself.  All subsequent packets sent to the
neighbour address will now have hoplimit stuck at 255 because the setup
of the NS packet wrote 255 to the cached metrics of the inetpeer that
the neighbour address' ip6_dst was bound to.  If the neighbour was a
router, a RA that attempts to update the hoplimit for the route will
have no effect because of the way ip6_dst_hoplimit works.

This patch adds an rt6_init_metrics method that is called shortly after
a call to ip6_dst_alloc, it performs the inetpeer binding at that time.

It allows the caller to indicate whether they want the new ip6_dst
metrics, and thus the inetpeer metrics, to be writable.  icmp6_dst_alloc
will now no longer permanently alter the peer metrics.

Signed-off-by: Nick Jones <nick.jones@network-box.com>
---
 net/ipv6/route.c |   57 ++++++++++++++++++++++++++++-------------------------
 1 files changed, 30 insertions(+), 27 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 92be12b..81836ad 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -90,35 +90,10 @@ static struct rt6_info *rt6_get_route_info(struct net *net,

 static u32 *ipv6_cow_metrics(struct dst_entry *dst, unsigned long old)
 {
-	struct rt6_info *rt = (struct rt6_info *) dst;
-	struct inet_peer *peer;
-	u32 *p = NULL;
-
-	if (!(rt->dst.flags & DST_HOST))
+	if (!(dst->flags & DST_HOST))
 		return NULL;

-	if (!rt->rt6i_peer)
-		rt6_bind_peer(rt, 1);
-
-	peer = rt->rt6i_peer;
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
-		}
-	}
-	return p;
+	return dst_cow_metrics_generic(dst, old);
 }

 static inline const void *choose_neigh_daddr(struct rt6_info *rt, const void *daddr)
@@ -309,6 +284,28 @@ void rt6_bind_peer(struct rt6_info *rt, int create)
 		rt->rt6i_peer_genid = rt6_peer_genid();
 }

+static void rt6_init_metrics(struct rt6_info *rt, int readonly)
+{
+	struct inet_peer *peer;
+
+	if (!(rt->dst.flags & DST_HOST))
+		return;
+
+	if (!rt->rt6i_peer)
+		rt6_bind_peer(rt, 1);
+
+	peer = rt->rt6i_peer;
+	if (peer) {
+		u32 *old_p = DST_METRICS_PTR(&rt->dst);
+		u32 *p = peer->metrics;
+
+		if (inet_metrics_new(peer))
+			memcpy(p, old_p, sizeof(u32) * RTAX_MAX);
+
+		dst_init_metrics(&rt->dst, p, readonly);
+	}
+}
+
 static void ip6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 			   int how)
 {
@@ -1117,6 +1114,8 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	rt->rt6i_dst.addr = fl6->daddr;
 	rt->rt6i_dst.plen = 128;
 	rt->rt6i_idev     = idev;
+
+	rt6_init_metrics(rt, 1);
 	dst_metric_set(&rt->dst, RTAX_HOPLIMIT, 255);

 	spin_lock_bh(&icmp6_dst_lock);
@@ -1313,6 +1312,8 @@ int ip6_route_add(struct fib6_config *cfg)
 			goto out;
 		}
 		dst_init_metrics(&rt->dst, metrics, 0);
+	} else if (rt->dst.flags & DST_HOST) {
+		rt6_init_metrics(rt, 0);
 	}
 #ifdef CONFIG_IPV6_SUBTREES
 	ipv6_addr_prefix(&rt->rt6i_src.addr, &cfg->fc_src, cfg->fc_src_len);
@@ -2111,6 +2112,8 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 	rt->rt6i_dst.plen = 128;
 	rt->rt6i_table = fib6_get_table(net, RT6_TABLE_LOCAL);

+	rt6_init_metrics(rt, 0);
+
 	atomic_set(&rt->dst.__refcnt, 1);

 	return rt;
-- 
1.7.1
