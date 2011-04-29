From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/3] ipv4: Use caller's on-stack flowi as-is in output
 route lookups.
Date: Thu, 28 Apr 2011 22:25:15 -0700 (PDT)
Message-ID: <20110428.222515.189697584.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37481
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752981Ab1D2FZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 01:25:48 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 4CE9C24C087
	for <netdev@vger.kernel.org>; Thu, 28 Apr 2011 22:25:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h |    2 +-
 net/ipv4/route.c    |  158 ++++++++++++++++++++++++++-------------------------
 2 files changed, 81 insertions(+), 79 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index fdbdb92..81b6cf2 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -115,7 +115,7 @@ extern void		ip_rt_redirect(__be32 old_gw, __be32 dst, __be32 new_gw,
 				       __be32 src, struct net_device *dev);
 extern void		rt_cache_flush(struct net *net, int how);
 extern void		rt_cache_flush_batch(struct net *net);
-extern struct rtable *__ip_route_output_key(struct net *, const struct flowi4 *flp);
+extern struct rtable *__ip_route_output_key(struct net *, struct flowi4 *flp);
 extern struct rtable *ip_route_output_flow(struct net *, struct flowi4 *flp,
 					   struct sock *sk);
 extern struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_orig);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index fb9211a..93f71be 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1767,7 +1767,7 @@ static unsigned int ipv4_default_mtu(const struct dst_entry *dst)
 	return mtu;
 }
 
-static void rt_init_metrics(struct rtable *rt, const struct flowi4 *oldflp4,
+static void rt_init_metrics(struct rtable *rt, const struct flowi4 *fl4,
 			    struct fib_info *fi)
 {
 	struct inet_peer *peer;
@@ -1776,7 +1776,7 @@ static void rt_init_metrics(struct rtable *rt, const struct flowi4 *oldflp4,
 	/* If a peer entry exists for this destination, we must hook
 	 * it up in order to get at cached metrics.
 	 */
-	if (oldflp4 && (oldflp4->flowi4_flags & FLOWI_FLAG_PRECOW_METRICS))
+	if (fl4 && (fl4->flowi4_flags & FLOWI_FLAG_PRECOW_METRICS))
 		create = 1;
 
 	rt->peer = peer = inet_getpeer_v4(rt->rt_dst, create);
@@ -1803,7 +1803,7 @@ static void rt_init_metrics(struct rtable *rt, const struct flowi4 *oldflp4,
 	}
 }
 
-static void rt_set_nexthop(struct rtable *rt, const struct flowi4 *oldflp4,
+static void rt_set_nexthop(struct rtable *rt, const struct flowi4 *fl4,
 			   const struct fib_result *res,
 			   struct fib_info *fi, u16 type, u32 itag)
 {
@@ -1813,7 +1813,7 @@ static void rt_set_nexthop(struct rtable *rt, const struct flowi4 *oldflp4,
 		if (FIB_RES_GW(*res) &&
 		    FIB_RES_NH(*res).nh_scope == RT_SCOPE_LINK)
 			rt->rt_gateway = FIB_RES_GW(*res);
-		rt_init_metrics(rt, oldflp4, fi);
+		rt_init_metrics(rt, fl4, fi);
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		dst->tclassid = FIB_RES_NH(*res).nh_tclassid;
 #endif
@@ -2354,12 +2354,12 @@ EXPORT_SYMBOL(ip_route_input_common);
 /* called with rcu_read_lock() */
 static struct rtable *__mkroute_output(const struct fib_result *res,
 				       const struct flowi4 *fl4,
-				       const struct flowi4 *oldflp4,
-				       struct net_device *dev_out,
+				       __be32 orig_daddr, __be32 orig_saddr,
+				       int orig_oif, struct net_device *dev_out,
 				       unsigned int flags)
 {
 	struct fib_info *fi = res->fi;
-	u32 tos = RT_FL_TOS(oldflp4);
+	u32 tos = RT_FL_TOS(fl4);
 	struct in_device *in_dev;
 	u16 type = res->type;
 	struct rtable *rth;
@@ -2386,8 +2386,8 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 		fi = NULL;
 	} else if (type == RTN_MULTICAST) {
 		flags |= RTCF_MULTICAST | RTCF_LOCAL;
-		if (!ip_check_mc_rcu(in_dev, oldflp4->daddr, oldflp4->saddr,
-				     oldflp4->flowi4_proto))
+		if (!ip_check_mc_rcu(in_dev, fl4->daddr, fl4->saddr,
+				     fl4->flowi4_proto))
 			flags &= ~RTCF_LOCAL;
 		/* If multicast route do not exist use
 		 * default one, but do not gateway in this case.
@@ -2405,8 +2405,8 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 
 	rth->dst.output = ip_output;
 
-	rth->rt_key_dst	= oldflp4->daddr;
-	rth->rt_key_src	= oldflp4->saddr;
+	rth->rt_key_dst	= orig_daddr;
+	rth->rt_key_src	= orig_saddr;
 	rth->rt_genid = rt_genid(dev_net(dev_out));
 	rth->rt_flags	= flags;
 	rth->rt_type	= type;
@@ -2414,9 +2414,9 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	rth->rt_dst	= fl4->daddr;
 	rth->rt_src	= fl4->saddr;
 	rth->rt_route_iif = 0;
-	rth->rt_iif	= oldflp4->flowi4_oif ? : dev_out->ifindex;
-	rth->rt_oif	= oldflp4->flowi4_oif;
-	rth->rt_mark    = oldflp4->flowi4_mark;
+	rth->rt_iif	= orig_oif ? : dev_out->ifindex;
+	rth->rt_oif	= orig_oif;
+	rth->rt_mark    = fl4->flowi4_mark;
 	rth->rt_gateway = fl4->daddr;
 	rth->rt_spec_dst= fl4->saddr;
 	rth->rt_peer_genid = 0;
@@ -2439,7 +2439,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 #ifdef CONFIG_IP_MROUTE
 		if (type == RTN_MULTICAST) {
 			if (IN_DEV_MFORWARD(in_dev) &&
-			    !ipv4_is_local_multicast(oldflp4->daddr)) {
+			    !ipv4_is_local_multicast(fl4->daddr)) {
 				rth->dst.input = ip_mr_input;
 				rth->dst.output = ip_mc_output;
 			}
@@ -2447,7 +2447,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 #endif
 	}
 
-	rt_set_nexthop(rth, oldflp4, res, fi, type, 0);
+	rt_set_nexthop(rth, fl4, res, fi, type, 0);
 
 	return rth;
 }
@@ -2457,36 +2457,37 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
  * called with rcu_read_lock();
  */
 
-static struct rtable *ip_route_output_slow(struct net *net,
-					   const struct flowi4 *oldflp4)
+static struct rtable *ip_route_output_slow(struct net *net, struct flowi4 *fl4)
 {
-	u32 tos	= RT_FL_TOS(oldflp4);
-	struct flowi4 fl4;
-	struct fib_result res;
-	unsigned int flags = 0;
 	struct net_device *dev_out = NULL;
+	u32 tos	= RT_FL_TOS(fl4);
+	unsigned int flags = 0;
+	struct fib_result res;
 	struct rtable *rth;
+	__be32 orig_daddr;
+	__be32 orig_saddr;
+	int orig_oif;
 
 	res.fi		= NULL;
 #ifdef CONFIG_IP_MULTIPLE_TABLES
 	res.r		= NULL;
 #endif
 
-	fl4.flowi4_oif = oldflp4->flowi4_oif;
-	fl4.flowi4_iif = net->loopback_dev->ifindex;
-	fl4.flowi4_mark = oldflp4->flowi4_mark;
-	fl4.daddr = oldflp4->daddr;
-	fl4.saddr = oldflp4->saddr;
-	fl4.flowi4_tos = tos & IPTOS_RT_MASK;
-	fl4.flowi4_scope = ((tos & RTO_ONLINK) ?
-			RT_SCOPE_LINK : RT_SCOPE_UNIVERSE);
+	orig_daddr = fl4->daddr;
+	orig_saddr = fl4->saddr;
+	orig_oif = fl4->flowi4_oif;
+
+	fl4->flowi4_iif = net->loopback_dev->ifindex;
+	fl4->flowi4_tos = tos & IPTOS_RT_MASK;
+	fl4->flowi4_scope = ((tos & RTO_ONLINK) ?
+			 RT_SCOPE_LINK : RT_SCOPE_UNIVERSE);
 
 	rcu_read_lock();
-	if (oldflp4->saddr) {
+	if (fl4->saddr) {
 		rth = ERR_PTR(-EINVAL);
-		if (ipv4_is_multicast(oldflp4->saddr) ||
-		    ipv4_is_lbcast(oldflp4->saddr) ||
-		    ipv4_is_zeronet(oldflp4->saddr))
+		if (ipv4_is_multicast(fl4->saddr) ||
+		    ipv4_is_lbcast(fl4->saddr) ||
+		    ipv4_is_zeronet(fl4->saddr))
 			goto out;
 
 		/* I removed check for oif == dev_out->oif here.
@@ -2497,11 +2498,11 @@ static struct rtable *ip_route_output_slow(struct net *net,
 		      of another iface. --ANK
 		 */
 
-		if (oldflp4->flowi4_oif == 0 &&
-		    (ipv4_is_multicast(oldflp4->daddr) ||
-		     ipv4_is_lbcast(oldflp4->daddr))) {
+		if (fl4->flowi4_oif == 0 &&
+		    (ipv4_is_multicast(fl4->daddr) ||
+		     ipv4_is_lbcast(fl4->daddr))) {
 			/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
-			dev_out = __ip_dev_find(net, oldflp4->saddr, false);
+			dev_out = __ip_dev_find(net, fl4->saddr, false);
 			if (dev_out == NULL)
 				goto out;
 
@@ -2520,20 +2521,20 @@ static struct rtable *ip_route_output_slow(struct net *net,
 			   Luckily, this hack is good workaround.
 			 */
 
-			fl4.flowi4_oif = dev_out->ifindex;
+			fl4->flowi4_oif = dev_out->ifindex;
 			goto make_route;
 		}
 
-		if (!(oldflp4->flowi4_flags & FLOWI_FLAG_ANYSRC)) {
+		if (!(fl4->flowi4_flags & FLOWI_FLAG_ANYSRC)) {
 			/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
-			if (!__ip_dev_find(net, oldflp4->saddr, false))
+			if (!__ip_dev_find(net, fl4->saddr, false))
 				goto out;
 		}
 	}
 
 
-	if (oldflp4->flowi4_oif) {
-		dev_out = dev_get_by_index_rcu(net, oldflp4->flowi4_oif);
+	if (fl4->flowi4_oif) {
+		dev_out = dev_get_by_index_rcu(net, fl4->flowi4_oif);
 		rth = ERR_PTR(-ENODEV);
 		if (dev_out == NULL)
 			goto out;
@@ -2543,37 +2544,37 @@ static struct rtable *ip_route_output_slow(struct net *net,
 			rth = ERR_PTR(-ENETUNREACH);
 			goto out;
 		}
-		if (ipv4_is_local_multicast(oldflp4->daddr) ||
-		    ipv4_is_lbcast(oldflp4->daddr)) {
-			if (!fl4.saddr)
-				fl4.saddr = inet_select_addr(dev_out, 0,
-							     RT_SCOPE_LINK);
+		if (ipv4_is_local_multicast(fl4->daddr) ||
+		    ipv4_is_lbcast(fl4->daddr)) {
+			if (!fl4->saddr)
+				fl4->saddr = inet_select_addr(dev_out, 0,
+							      RT_SCOPE_LINK);
 			goto make_route;
 		}
-		if (!fl4.saddr) {
-			if (ipv4_is_multicast(oldflp4->daddr))
-				fl4.saddr = inet_select_addr(dev_out, 0,
-							     fl4.flowi4_scope);
-			else if (!oldflp4->daddr)
-				fl4.saddr = inet_select_addr(dev_out, 0,
-							     RT_SCOPE_HOST);
+		if (fl4->saddr) {
+			if (ipv4_is_multicast(fl4->daddr))
+				fl4->saddr = inet_select_addr(dev_out, 0,
+							      fl4->flowi4_scope);
+			else if (!fl4->daddr)
+				fl4->saddr = inet_select_addr(dev_out, 0,
+							      RT_SCOPE_HOST);
 		}
 	}
 
-	if (!fl4.daddr) {
-		fl4.daddr = fl4.saddr;
-		if (!fl4.daddr)
-			fl4.daddr = fl4.saddr = htonl(INADDR_LOOPBACK);
+	if (!fl4->daddr) {
+		fl4->daddr = fl4->saddr;
+		if (!fl4->daddr)
+			fl4->daddr = fl4->saddr = htonl(INADDR_LOOPBACK);
 		dev_out = net->loopback_dev;
-		fl4.flowi4_oif = net->loopback_dev->ifindex;
+		fl4->flowi4_oif = net->loopback_dev->ifindex;
 		res.type = RTN_LOCAL;
 		flags |= RTCF_LOCAL;
 		goto make_route;
 	}
 
-	if (fib_lookup(net, &fl4, &res)) {
+	if (fib_lookup(net, fl4, &res)) {
 		res.fi = NULL;
-		if (oldflp4->flowi4_oif) {
+		if (fl4->flowi4_oif) {
 			/* Apparently, routing tables are wrong. Assume,
 			   that the destination is on link.
 
@@ -2592,9 +2593,9 @@ static struct rtable *ip_route_output_slow(struct net *net,
 			   likely IPv6, but we do not.
 			 */
 
-			if (fl4.saddr == 0)
-				fl4.saddr = inet_select_addr(dev_out, 0,
-							     RT_SCOPE_LINK);
+			if (fl4->saddr == 0)
+				fl4->saddr = inet_select_addr(dev_out, 0,
+							      RT_SCOPE_LINK);
 			res.type = RTN_UNICAST;
 			goto make_route;
 		}
@@ -2603,44 +2604,45 @@ static struct rtable *ip_route_output_slow(struct net *net,
 	}
 
 	if (res.type == RTN_LOCAL) {
-		if (!fl4.saddr) {
+		if (!fl4->saddr) {
 			if (res.fi->fib_prefsrc)
-				fl4.saddr = res.fi->fib_prefsrc;
+				fl4->saddr = res.fi->fib_prefsrc;
 			else
-				fl4.saddr = fl4.daddr;
+				fl4->saddr = fl4->daddr;
 		}
 		dev_out = net->loopback_dev;
-		fl4.flowi4_oif = dev_out->ifindex;
+		fl4->flowi4_oif = dev_out->ifindex;
 		res.fi = NULL;
 		flags |= RTCF_LOCAL;
 		goto make_route;
 	}
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-	if (res.fi->fib_nhs > 1 && fl4.flowi4_oif == 0)
+	if (res.fi->fib_nhs > 1 && fl4->flowi4_oif == 0)
 		fib_select_multipath(&res);
 	else
 #endif
 	if (!res.prefixlen &&
 	    res.table->tb_num_default > 1 &&
-	    res.type == RTN_UNICAST && !fl4.flowi4_oif)
+	    res.type == RTN_UNICAST && !fl4->flowi4_oif)
 		fib_select_default(&res);
 
-	if (!fl4.saddr)
-		fl4.saddr = FIB_RES_PREFSRC(net, res);
+	if (!fl4->saddr)
+		fl4->saddr = FIB_RES_PREFSRC(net, res);
 
 	dev_out = FIB_RES_DEV(res);
-	fl4.flowi4_oif = dev_out->ifindex;
+	fl4->flowi4_oif = dev_out->ifindex;
 
 
 make_route:
-	rth = __mkroute_output(&res, &fl4, oldflp4, dev_out, flags);
+	rth = __mkroute_output(&res, fl4, orig_daddr, orig_saddr, orig_oif,
+			       dev_out, flags);
 	if (!IS_ERR(rth)) {
 		unsigned int hash;
 
-		hash = rt_hash(oldflp4->daddr, oldflp4->saddr, oldflp4->flowi4_oif,
+		hash = rt_hash(orig_daddr, orig_saddr, orig_oif,
 			       rt_genid(dev_net(dev_out)));
-		rth = rt_intern_hash(hash, rth, NULL, oldflp4->flowi4_oif);
+		rth = rt_intern_hash(hash, rth, NULL, orig_oif);
 	}
 
 out:
@@ -2648,7 +2650,7 @@ out:
 	return rth;
 }
 
-struct rtable *__ip_route_output_key(struct net *net, const struct flowi4 *flp4)
+struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *flp4)
 {
 	struct rtable *rth;
 	unsigned int hash;
-- 
1.7.4.5

