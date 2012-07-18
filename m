From: David Miller <davem@davemloft.net>
Subject: [PATCH 09/15] ipv4: Cache output routes in fib_info nexthops.
Date: Wed, 18 Jul 2012 11:24:04 -0700 (PDT)
Message-ID: <20120718.112404.1910372180742347127.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36934 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755405Ab2GRSYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 14:24:05 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id D8C02583FCF
	for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 11:24:06 -0700 (PDT)
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

To counter adding a new argument to rt_set_nexthop() I'm removing the
'fl4' arg to rt_set_nexthop() and rt_init_metrics(), which is no
longer used.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip_fib.h     |    2 +
 net/ipv4/fib_semantics.c |    2 +
 net/ipv4/route.c         |  109 ++++++++++++++++++++++++++++++++--------------
 3 files changed, 80 insertions(+), 33 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index e9ee1ca..23c9f9e 100644
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
index 4d170a1..2e66b9a 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1151,8 +1151,7 @@ static unsigned int ipv4_mtu(const struct dst_entry *dst)
 	return mtu;
 }
 
-static void rt_init_metrics(struct rtable *rt, const struct flowi4 *fl4,
-			    struct fib_info *fi)
+static void rt_init_metrics(struct rtable *rt, struct fib_info *fi)
 {
 	if (fi->fib_metrics != (u32 *) dst_default_metrics) {
 		rt->fi = fi;
@@ -1161,38 +1160,61 @@ static void rt_init_metrics(struct rtable *rt, const struct flowi4 *fl4,
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
 
 	for (fnhe = rcu_dereference(hash[hval].chain); fnhe;
 	     fnhe = rcu_dereference(fnhe->fnhe_next)) {
-		if (fnhe->fnhe_daddr == daddr) {
-			if (fnhe->fnhe_pmtu) {
-				unsigned long expires = fnhe->fnhe_expires;
-				unsigned long diff = jiffies - expires;
-
-				if (time_before(jiffies, expires)) {
-					rt->rt_pmtu = fnhe->fnhe_pmtu;
-					dst_set_expires(&rt->dst, diff);
-				}
-			}
-			if (fnhe->fnhe_gw) {
-				rt->rt_flags |= RTCF_REDIRECTED;
-				rt->rt_gateway = fnhe->fnhe_gw;
-			}
-			fnhe->fnhe_stamp = jiffies;
-			break;
+		if (fnhe->fnhe_daddr == daddr)
+			return fnhe;
+	}
+	return NULL;
+}
+
+static void rt_bind_exception(struct rtable *rt, struct fib_nh_exception *fnhe)
+{
+	if (fnhe->fnhe_pmtu) {
+		unsigned long expires = fnhe->fnhe_expires;
+		unsigned long diff = jiffies - expires;
+
+		if (time_before(jiffies, expires)) {
+			rt->rt_pmtu = fnhe->fnhe_pmtu;
+			dst_set_expires(&rt->dst, diff);
 		}
 	}
+	if (fnhe->fnhe_gw) {
+		rt->rt_flags |= RTCF_REDIRECTED;
+		rt->rt_gateway = fnhe->fnhe_gw;
+	}
+	fnhe->fnhe_stamp = jiffies;
 }
 
-static void rt_set_nexthop(struct rtable *rt, const struct flowi4 *fl4,
-			   const struct fib_result *res,
+static void rt_cache_route(struct fib_nh *nh, struct rtable *rt)
+{
+	static DEFINE_SPINLOCK(fib_cache_lock);
+	struct rtable **p = &nh->nh_rth_output;
+
+	if (*p)
+		return;
+
+	spin_lock_bh(&fib_cache_lock);
+	if (!*p) {
+		*p = rt;
+		dst_clone(&rt->dst);
+	}
+	spin_unlock_bh(&fib_cache_lock);
+}
+
+static void rt_set_nexthop(struct rtable *rt, const struct fib_result *res,
+			   struct fib_nh_exception *fnhe,
 			   struct fib_info *fi, u16 type, u32 itag)
 {
 	if (fi) {
@@ -1200,12 +1222,15 @@ static void rt_set_nexthop(struct rtable *rt, const struct flowi4 *fl4,
 
 		if (nh->nh_gw && nh->nh_scope == RT_SCOPE_LINK)
 			rt->rt_gateway = nh->nh_gw;
-		if (unlikely(nh->nh_exceptions))
-			rt_bind_exception(rt, nh, fl4->daddr);
-		rt_init_metrics(rt, fl4, fi);
+		if (unlikely(fnhe))
+			rt_bind_exception(rt, fnhe);
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
@@ -1217,10 +1242,10 @@ static void rt_set_nexthop(struct rtable *rt, const struct flowi4 *fl4,
 }
 
 static struct rtable *rt_dst_alloc(struct net_device *dev,
-				   bool nopolicy, bool noxfrm)
+				   bool nopolicy, bool noxfrm, bool will_cache)
 {
 	return dst_alloc(&ipv4_dst_ops, dev, 1, -1,
-			 DST_HOST | DST_NOCACHE |
+			 (will_cache ? 0 : DST_HOST) | DST_NOCACHE |
 			 (nopolicy ? DST_NOPOLICY : 0) |
 			 (noxfrm ? DST_NOXFRM : 0));
 }
@@ -1257,7 +1282,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 			goto e_err;
 	}
 	rth = rt_dst_alloc(dev_net(dev)->loopback_dev,
-			   IN_DEV_CONF_GET(in_dev, NOPOLICY), false);
+			   IN_DEV_CONF_GET(in_dev, NOPOLICY), false, false);
 	if (!rth)
 		goto e_nobufs;
 
@@ -1330,6 +1355,7 @@ static int __mkroute_input(struct sk_buff *skb,
 			   __be32 daddr, __be32 saddr, u32 tos,
 			   struct rtable **result)
 {
+	struct fib_nh_exception *fnhe;
 	struct rtable *rth;
 	int err;
 	struct in_device *out_dev;
@@ -1376,9 +1402,13 @@ static int __mkroute_input(struct sk_buff *skb,
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
@@ -1397,7 +1427,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->dst.input = ip_forward;
 	rth->dst.output = ip_output;
 
-	rt_set_nexthop(rth, NULL, res, res->fi, res->type, itag);
+	rt_set_nexthop(rth, res, fnhe, res->fi, res->type, itag);
 
 	*result = rth;
 	err = 0;
@@ -1539,7 +1569,7 @@ brd_input:
 
 local_input:
 	rth = rt_dst_alloc(net->loopback_dev,
-			   IN_DEV_CONF_GET(in_dev, NOPOLICY), false);
+			   IN_DEV_CONF_GET(in_dev, NOPOLICY), false, false);
 	if (!rth)
 		goto e_nobufs;
 
@@ -1653,6 +1683,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 				       unsigned int flags)
 {
 	struct fib_info *fi = res->fi;
+	struct fib_nh_exception *fnhe;
 	struct in_device *in_dev;
 	u16 type = res->type;
 	struct rtable *rth;
@@ -1691,9 +1722,21 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 			fi = NULL;
 	}
 
+	fnhe = NULL;
+	if (fi) {
+		fnhe = find_exception(&FIB_RES_NH(*res), fl4->daddr);
+		if (!fnhe) {
+			rth = FIB_RES_NH(*res).nh_rth_output;
+			if (rth) {
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
 
@@ -1730,7 +1773,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 #endif
 	}
 
-	rt_set_nexthop(rth, fl4, res, fi, type, 0);
+	rt_set_nexthop(rth, res, fnhe, fi, type, 0);
 
 	if (fl4->flowi4_flags & FLOWI_FLAG_RT_NOCACHE)
 		rth->dst.flags |= DST_NOCACHE;
-- 
1.7.10.4
