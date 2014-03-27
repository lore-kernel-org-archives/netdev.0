From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net-next v5] ipv6: do not overwrite inetpeer metrics
 prematurely
Date: Thu, 27 Mar 2014 13:04:08 +0100 (CET)
Message-ID: <20140327120408.03BECE66C2@unicorn.suse.cz>
References: <20140327050618.GK22086@order.stressinduktion.org>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:35823 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754849AbaC0MEK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2014 08:04:10 -0400
In-Reply-To: <20140327050618.GK22086@order.stressinduktion.org>
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

Another problem is that old metrics in inetpeer can reappear
unexpectedly for a new route, e.g.

12sp0:~ # ip route add fec0::1 dev eth0 rto_min 1000
12sp0:~ # ip route del fec0::1
12sp0:~ # ip route add fec0::1 dev eth0
12sp0:~ # ip route change fec0::1 dev eth0 hoplimit 10
12sp0:~ # ip -6 route show
fe80::/64 dev eth0  proto kernel  metric 256
fec0::1 dev eth0  metric 1024  hoplimit 10 rto_min lock 1s

Resolve the first problem by moving the setting of metrics down
into fib6_add_rt2node() to the point we are sure we are
inserting the new route into the tree. Second problem is
addressed by introducing new flag DST_METRICS_FORCE_OVERWRITE
which is set for a new host route in ip6_route_add() and makes
ipv6_cow_metrics() always overwrite the metrics in inetpeer
(even if they are not "new"); it is reset after that.

v5: use a flag in _metrics member rather than one in flags

v4: fix a typo making a condition always true (thanks to Hannes
Frederic Sowa)

v3: rewritten based on David Miller's idea to move setting the
metrics (and allocation in non-host case) down to the point we
already know the route is to be inserted. Also rebased to
net-next as it is quite late in the cycle.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 include/net/dst.h     | 11 +++++++++--
 include/net/ip6_fib.h |  3 ++-
 net/ipv6/ip6_fib.c    | 47 ++++++++++++++++++++++++++++++++++++++++++++---
 net/ipv6/route.c      | 44 +++++++++++---------------------------------
 4 files changed, 66 insertions(+), 39 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index e01a826..46ed958 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -108,9 +108,11 @@ struct dst_entry {
 u32 *dst_cow_metrics_generic(struct dst_entry *dst, unsigned long old);
 extern const u32 dst_default_metrics[];
 
-#define DST_METRICS_READ_ONLY	0x1UL
+#define DST_METRICS_READ_ONLY		0x1UL
+#define DST_METRICS_FORCE_OVERWRITE	0x2UL
+#define DST_METRICS_FLAGS		0x3UL
 #define __DST_METRICS_PTR(Y)	\
-	((u32 *)((Y) & ~DST_METRICS_READ_ONLY))
+	((u32 *)((Y) & ~DST_METRICS_FLAGS))
 #define DST_METRICS_PTR(X)	__DST_METRICS_PTR((X)->_metrics)
 
 static inline bool dst_metrics_read_only(const struct dst_entry *dst)
@@ -118,6 +120,11 @@ static inline bool dst_metrics_read_only(const struct dst_entry *dst)
 	return dst->_metrics & DST_METRICS_READ_ONLY;
 }
 
+static inline void dst_metrics_set_force_overwrite(struct dst_entry *dst)
+{
+	dst->_metrics |= DST_METRICS_FORCE_OVERWRITE;
+}
+
 void __dst_destroy_metrics_generic(struct dst_entry *dst, unsigned long old);
 
 static inline void dst_destroy_metrics_generic(struct dst_entry *dst)
diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index aca0c27..9bcb220 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -284,7 +284,8 @@ struct fib6_node *fib6_locate(struct fib6_node *root,
 void fib6_clean_all(struct net *net, int (*func)(struct rt6_info *, void *arg),
 		    void *arg);
 
-int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info);
+int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info,
+	     struct nlattr *mx, int mx_len);
 
 int fib6_del(struct rt6_info *rt, struct nl_info *info);
 
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 075602f..4ee487b 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -638,12 +638,41 @@ static inline bool rt6_qualify_for_ecmp(struct rt6_info *rt)
 	       RTF_GATEWAY;
 }
 
+static int fib6_commit_metrics(struct dst_entry *dst,
+			       struct nlattr *mx, int mx_len)
+{
+	struct nlattr *nla;
+	int remaining;
+	u32 *mp;
+
+	if (dst->flags & DST_HOST) {
+		mp = dst_metrics_write_ptr(dst);
+	} else {
+		mp = kzalloc(sizeof(u32) * RTAX_MAX, GFP_KERNEL);
+		if (!mp)
+			return -ENOMEM;
+		dst_init_metrics(dst, mp, 0);
+	}
+
+	nla_for_each_attr(nla, mx, mx_len, remaining) {
+		int type = nla_type(nla);
+
+		if (type) {
+			if (type > RTAX_MAX)
+				return -EINVAL;
+
+			mp[type - 1] = nla_get_u32(nla);
+		}
+	}
+	return 0;
+}
+
 /*
  *	Insert routing information in a node.
  */
 
 static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
-			    struct nl_info *info)
+			    struct nl_info *info, struct nlattr *mx, int mx_len)
 {
 	struct rt6_info *iter = NULL;
 	struct rt6_info **ins;
@@ -653,6 +682,7 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 		   (info->nlh->nlmsg_flags & NLM_F_CREATE));
 	int found = 0;
 	bool rt_can_ecmp = rt6_qualify_for_ecmp(rt);
+	int err;
 
 	ins = &fn->leaf;
 
@@ -751,6 +781,11 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 			pr_warn("NLM_F_CREATE should be set when creating new route\n");
 
 add:
+		if (mx) {
+			err = fib6_commit_metrics(&rt->dst, mx, mx_len);
+			if (err)
+				return err;
+		}
 		rt->dst.rt6_next = iter;
 		*ins = rt;
 		rt->rt6i_node = fn;
@@ -770,6 +805,11 @@ add:
 			pr_warn("NLM_F_REPLACE set, but no existing node found!\n");
 			return -ENOENT;
 		}
+		if (mx) {
+			err = fib6_commit_metrics(&rt->dst, mx, mx_len);
+			if (err)
+				return err;
+		}
 		*ins = rt;
 		rt->rt6i_node = fn;
 		rt->dst.rt6_next = iter->dst.rt6_next;
@@ -806,7 +846,8 @@ void fib6_force_start_gc(struct net *net)
  *	with source addr info in sub-trees
  */
 
-int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info)
+int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info,
+	     struct nlattr *mx, int mx_len)
 {
 	struct fib6_node *fn, *pn = NULL;
 	int err = -ENOMEM;
@@ -900,7 +941,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info)
 	}
 #endif
 
-	err = fib6_add_rt2node(fn, rt, info);
+	err = fib6_add_rt2node(fn, rt, info, mx, mx_len);
 	if (!err) {
 		fib6_start_gc(info->nl_net, rt);
 		if (!(rt->rt6i_flags & RTF_CACHE))
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index fba54a4..b93ae6a 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -149,7 +149,8 @@ static u32 *ipv6_cow_metrics(struct dst_entry *dst, unsigned long old)
 		unsigned long prev, new;
 
 		p = peer->metrics;
-		if (inet_metrics_new(peer))
+		if (inet_metrics_new(peer) ||
+		    (old & DST_METRICS_FORCE_OVERWRITE))
 			memcpy(p, old_p, sizeof(u32) * RTAX_MAX);
 
 		new = (unsigned long) p;
@@ -857,14 +858,15 @@ EXPORT_SYMBOL(rt6_lookup);
    be destroyed.
  */
 
-static int __ip6_ins_rt(struct rt6_info *rt, struct nl_info *info)
+static int __ip6_ins_rt(struct rt6_info *rt, struct nl_info *info,
+			struct nlattr *mx, int mx_len)
 {
 	int err;
 	struct fib6_table *table;
 
 	table = rt->rt6i_table;
 	write_lock_bh(&table->tb6_lock);
-	err = fib6_add(&table->tb6_root, rt, info);
+	err = fib6_add(&table->tb6_root, rt, info, mx, mx_len);
 	write_unlock_bh(&table->tb6_lock);
 
 	return err;
@@ -875,7 +877,7 @@ int ip6_ins_rt(struct rt6_info *rt)
 	struct nl_info info = {
 		.nl_net = dev_net(rt->dst.dev),
 	};
-	return __ip6_ins_rt(rt, &info);
+	return __ip6_ins_rt(rt, &info, NULL, 0);
 }
 
 static struct rt6_info *rt6_alloc_cow(struct rt6_info *ort,
@@ -1543,17 +1545,11 @@ int ip6_route_add(struct fib6_config *cfg)
 
 	ipv6_addr_prefix(&rt->rt6i_dst.addr, &cfg->fc_dst, cfg->fc_dst_len);
 	rt->rt6i_dst.plen = cfg->fc_dst_len;
-	if (rt->rt6i_dst.plen == 128)
-	       rt->dst.flags |= DST_HOST;
-
-	if (!(rt->dst.flags & DST_HOST) && cfg->fc_mx) {
-		u32 *metrics = kzalloc(sizeof(u32) * RTAX_MAX, GFP_KERNEL);
-		if (!metrics) {
-			err = -ENOMEM;
-			goto out;
-		}
-		dst_init_metrics(&rt->dst, metrics, 0);
+	if (rt->rt6i_dst.plen == 128) {
+		rt->dst.flags |= DST_HOST;
+		dst_metrics_set_force_overwrite(&rt->dst);
 	}
+
 #ifdef CONFIG_IPV6_SUBTREES
 	ipv6_addr_prefix(&rt->rt6i_src.addr, &cfg->fc_src, cfg->fc_src_len);
 	rt->rt6i_src.plen = cfg->fc_src_len;
@@ -1672,31 +1668,13 @@ int ip6_route_add(struct fib6_config *cfg)
 	rt->rt6i_flags = cfg->fc_flags;
 
 install_route:
-	if (cfg->fc_mx) {
-		struct nlattr *nla;
-		int remaining;
-
-		nla_for_each_attr(nla, cfg->fc_mx, cfg->fc_mx_len, remaining) {
-			int type = nla_type(nla);
-
-			if (type) {
-				if (type > RTAX_MAX) {
-					err = -EINVAL;
-					goto out;
-				}
-
-				dst_metric_set(&rt->dst, type, nla_get_u32(nla));
-			}
-		}
-	}
-
 	rt->dst.dev = dev;
 	rt->rt6i_idev = idev;
 	rt->rt6i_table = table;
 
 	cfg->fc_nlinfo.nl_net = dev_net(dev);
 
-	return __ip6_ins_rt(rt, &cfg->fc_nlinfo);
+	return __ip6_ins_rt(rt, &cfg->fc_nlinfo, cfg->fc_mx, cfg->fc_mx_len);
 
 out:
 	if (dev)
-- 
1.8.1.4
