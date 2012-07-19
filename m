From: David Miller <davem@davemloft.net>
Subject: [PATCH 10/16] ipv4: Cache output routes in fib_info nexthops.
Date: Thu, 19 Jul 2012 14:35:40 -0700 (PDT)
Message-ID: <20120719.143540.747492487297004222.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48290 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751466Ab2GSVfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 17:35:41 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 1A9EC58459E
	for <netdev@vger.kernel.org>; Thu, 19 Jul 2012 14:35:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If we have an output route that lacks nexthop exceptions, we can cache
it in the FIB info nexthop.

Such routes will have DST_HOST cleared because such routes refer to a
family of destinations, rather than just one.

The sequence of the handling of exceptions during route lookup is
adjusted to make the logic work properly.

Before we allocate the route, we lookup the exception.

Then we know if we will cache this route or not, and therefore whether
DST_HOST should be set on the allocated route.

Then we use DST_HOST to key off whether we should store the resulting
route, during rt_set_nexthop(), in the FIB nexthop cache.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip_fib.h     |    2 +
 net/ipv4/fib_semantics.c |    2 +
 net/ipv4/route.c         |  134 +++++++++++++++++++++++++++++++---------------
 3 files changed, 95 insertions(+), 43 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 2daf096..fb62c59 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -46,6 +46,7 @@ struct fib_config {
  };
 
 struct fib_info;
+struct rtable;
 
 struct fib_nh_exception {
 	struct fib_nh_exception __rcu	*fnhe_next;
@@ -80,6 +81,7 @@ struct fib_nh {
 	__be32			nh_gw;
 	__be32			nh_saddr;
 	int			nh_saddr_genid;
+	struct rtable		*nh_rth_output;
 	struct fnhe_hash_bucket	*nh_exceptions;
 };
 
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 2b57d76..83d0f42 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -171,6 +171,8 @@ static void free_fib_info_rcu(struct rcu_head *head)
 			dev_put(nexthop_nh->nh_dev);
 		if (nexthop_nh->nh_exceptions)
 			free_nh_exceptions(nexthop_nh);
+		if (nexthop_nh->nh_rth_output)
+			dst_release(&nexthop_nh->nh_rth_output->dst);
 	} endfor_nexthops(fi);
 
 	release_net(fi->fib_net);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f902d08..8d8b3b2 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1158,8 +1158,7 @@ static unsigned int ipv4_mtu(const struct dst_entry *dst)
 	return mtu;
 }
 
-static void rt_init_metrics(struct rtable *rt, const struct flowi4 *fl4,
-			    struct fib_info *fi)
+static void rt_init_metrics(struct rtable *rt, struct fib_info *fi)
 {
 	if (fi->fib_metrics != (u32 *) dst_default_metrics) {
 		rt->fi = fi;
@@ -1168,50 +1167,77 @@ static void rt_init_metrics(struct rtable *rt, const struct flowi4 *fl4,
 	dst_init_metrics(&rt->dst, fi->fib_metrics, true);
 }
 
-static void rt_bind_exception(struct rtable *rt, struct fib_nh *nh, __be32 daddr)
+static struct fib_nh_exception *find_exception(struct fib_nh *nh, __be32 daddr)
 {
 	struct fnhe_hash_bucket *hash = nh->nh_exceptions;
 	struct fib_nh_exception *fnhe;
 	u32 hval;
 
+	if (!hash)
+		return NULL;
+
 	hval = fnhe_hashfun(daddr);
 
-restart:
 	for (fnhe = rcu_dereference(hash[hval].chain); fnhe;
 	     fnhe = rcu_dereference(fnhe->fnhe_next)) {
-		__be32 fnhe_daddr, gw;
-		unsigned long expires;
-		unsigned int seq;
-		u32 pmtu;
-
-		seq = read_seqbegin(&fnhe_seqlock);
-		fnhe_daddr = fnhe->fnhe_daddr;
-		gw = fnhe->fnhe_gw;
-		pmtu = fnhe->fnhe_pmtu;
-		expires = fnhe->fnhe_expires;
-		if (read_seqretry(&fnhe_seqlock, seq))
-			goto restart;
-		if (daddr != fnhe_daddr)
-			continue;
-		if (pmtu) {
-			unsigned long diff = expires - jiffies;
+		if (fnhe->fnhe_daddr == daddr)
+			return fnhe;
+	}
+	return NULL;
+}
 
-			if (time_before(jiffies, expires)) {
-				rt->rt_pmtu = pmtu;
-				dst_set_expires(&rt->dst, diff);
-			}
-		}
-		if (gw) {
-			rt->rt_flags |= RTCF_REDIRECTED;
-			rt->rt_gateway = gw;
+static void rt_bind_exception(struct rtable *rt, struct fib_nh_exception *fnhe,
+			      __be32 daddr)
+{
+	__be32 fnhe_daddr, gw;
+	unsigned long expires;
+	unsigned int seq;
+	u32 pmtu;
+
+restart:
+	seq = read_seqbegin(&fnhe_seqlock);
+	fnhe_daddr = fnhe->fnhe_daddr;
+	gw = fnhe->fnhe_gw;
+	pmtu = fnhe->fnhe_pmtu;
+	expires = fnhe->fnhe_expires;
+	if (read_seqretry(&fnhe_seqlock, seq))
+		goto restart;
+
+	if (daddr != fnhe_daddr)
+		return;
+
+	if (pmtu) {
+		unsigned long diff = expires - jiffies;
+
+		if (time_before(jiffies, expires)) {
+			rt->rt_pmtu = pmtu;
+			dst_set_expires(&rt->dst, diff);
 		}
-		fnhe->fnhe_stamp = jiffies;
-		break;
+	}
+	if (gw) {
+		rt->rt_flags |= RTCF_REDIRECTED;
+		rt->rt_gateway = gw;
+	}
+	fnhe->fnhe_stamp = jiffies;
+}
+
+static void rt_cache_route(struct fib_nh *nh, struct rtable *rt)
+{
+	struct rtable *orig, *prev, **p = &nh->nh_rth_output;
+
+	orig = *p;
+
+	prev = cmpxchg(p, orig, rt);
+	if (prev == orig) {
+		dst_clone(&rt->dst);
+		if (orig)
+			dst_release(&orig->dst);
 	}
 }
 
-static void rt_set_nexthop(struct rtable *rt, const struct flowi4 *fl4,
+static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
 			   const struct fib_result *res,
+			   struct fib_nh_exception *fnhe,
 			   struct fib_info *fi, u16 type, u32 itag)
 {
 	if (fi) {
@@ -1219,12 +1245,15 @@ static void rt_set_nexthop(struct rtable *rt, const struct flowi4 *fl4,
 
 		if (nh->nh_gw && nh->nh_scope == RT_SCOPE_LINK)
 			rt->rt_gateway = nh->nh_gw;
-		if (unlikely(nh->nh_exceptions))
-			rt_bind_exception(rt, nh, fl4->daddr);
-		rt_init_metrics(rt, fl4, fi);
+		if (unlikely(fnhe))
+			rt_bind_exception(rt, fnhe, daddr);
+		rt_init_metrics(rt, fi);
 #ifdef CONFIG_IP_ROUTE_CLASSID
-		rt->dst.tclassid = FIB_RES_NH(*res).nh_tclassid;
+		rt->dst.tclassid = nh->nh_tclassid;
 #endif
+		if (!(rt->dst.flags & DST_HOST) &&
+		    rt_is_output_route(rt))
+			rt_cache_route(nh, rt);
 	}
 
 #ifdef CONFIG_IP_ROUTE_CLASSID
@@ -1236,10 +1265,10 @@ static void rt_set_nexthop(struct rtable *rt, const struct flowi4 *fl4,
 }
 
 static struct rtable *rt_dst_alloc(struct net_device *dev,
-				   bool nopolicy, bool noxfrm)
+				   bool nopolicy, bool noxfrm, bool will_cache)
 {
 	return dst_alloc(&ipv4_dst_ops, dev, 1, DST_OBSOLETE_FORCE_CHK,
-			 DST_HOST | DST_NOCACHE |
+			 (will_cache ? 0 : DST_HOST) | DST_NOCACHE |
 			 (nopolicy ? DST_NOPOLICY : 0) |
 			 (noxfrm ? DST_NOXFRM : 0));
 }
@@ -1276,7 +1305,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 			goto e_err;
 	}
 	rth = rt_dst_alloc(dev_net(dev)->loopback_dev,
-			   IN_DEV_CONF_GET(in_dev, NOPOLICY), false);
+			   IN_DEV_CONF_GET(in_dev, NOPOLICY), false, false);
 	if (!rth)
 		goto e_nobufs;
 
@@ -1349,6 +1378,7 @@ static int __mkroute_input(struct sk_buff *skb,
 			   __be32 daddr, __be32 saddr, u32 tos,
 			   struct rtable **result)
 {
+	struct fib_nh_exception *fnhe;
 	struct rtable *rth;
 	int err;
 	struct in_device *out_dev;
@@ -1395,9 +1425,13 @@ static int __mkroute_input(struct sk_buff *skb,
 		}
 	}
 
+	fnhe = NULL;
+	if (res->fi)
+		fnhe = find_exception(&FIB_RES_NH(*res), daddr);
+
 	rth = rt_dst_alloc(out_dev->dev,
 			   IN_DEV_CONF_GET(in_dev, NOPOLICY),
-			   IN_DEV_CONF_GET(out_dev, NOXFRM));
+			   IN_DEV_CONF_GET(out_dev, NOXFRM), false);
 	if (!rth) {
 		err = -ENOBUFS;
 		goto cleanup;
@@ -1416,7 +1450,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->dst.input = ip_forward;
 	rth->dst.output = ip_output;
 
-	rt_set_nexthop(rth, NULL, res, res->fi, res->type, itag);
+	rt_set_nexthop(rth, daddr, res, fnhe, res->fi, res->type, itag);
 
 	*result = rth;
 	err = 0;
@@ -1558,7 +1592,7 @@ brd_input:
 
 local_input:
 	rth = rt_dst_alloc(net->loopback_dev,
-			   IN_DEV_CONF_GET(in_dev, NOPOLICY), false);
+			   IN_DEV_CONF_GET(in_dev, NOPOLICY), false, false);
 	if (!rth)
 		goto e_nobufs;
 
@@ -1672,6 +1706,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 				       unsigned int flags)
 {
 	struct fib_info *fi = res->fi;
+	struct fib_nh_exception *fnhe;
 	struct in_device *in_dev;
 	u16 type = res->type;
 	struct rtable *rth;
@@ -1710,9 +1745,22 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 			fi = NULL;
 	}
 
+	fnhe = NULL;
+	if (fi) {
+		fnhe = find_exception(&FIB_RES_NH(*res), fl4->daddr);
+		if (!fnhe) {
+			rth = FIB_RES_NH(*res).nh_rth_output;
+			if (rth &&
+			    rth->dst.obsolete == DST_OBSOLETE_FORCE_CHK) {
+				dst_use(&rth->dst, jiffies);
+				return rth;
+			}
+		}
+	}
 	rth = rt_dst_alloc(dev_out,
 			   IN_DEV_CONF_GET(in_dev, NOPOLICY),
-			   IN_DEV_CONF_GET(in_dev, NOXFRM));
+			   IN_DEV_CONF_GET(in_dev, NOXFRM),
+			   fi && !fnhe);
 	if (!rth)
 		return ERR_PTR(-ENOBUFS);
 
@@ -1749,7 +1797,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 #endif
 	}
 
-	rt_set_nexthop(rth, fl4, res, fi, type, 0);
+	rt_set_nexthop(rth, fl4->daddr, res, fnhe, fi, type, 0);
 
 	if (fl4->flowi4_flags & FLOWI_FLAG_RT_NOCACHE)
 		rth->dst.flags |= DST_NOCACHE;
-- 
1.7.10.4
