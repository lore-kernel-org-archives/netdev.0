From: David Miller <davem@davemloft.net>
Subject: [PATCH v5 7/7] ipv4: Use caller's on-stack flowi as-is in output
 route lookups.
Date: Fri, 15 Apr 2011 15:39:57 -0700 (PDT)
Message-ID: <20110415.153957.246522714.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38643
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753939Ab1DOWkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 18:40:32 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 04DAB24C088
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 15:39:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h |    2 +-
 net/ipv4/route.c    |  136 ++++++++++++++++++++++++--------------------------
 2 files changed, 66 insertions(+), 72 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 1337917..b7cab6f 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -118,7 +118,7 @@ extern int		ip_rt_init(void);
 extern void		ip_rt_redirect(__be32 old_gw, __be32 dst, __be32 new_gw,
 				       __be32 src, struct net_device *dev);
 extern void		rt_cache_flush(struct net *net, int how);
-extern struct rtable *__ip_route_output_key(struct net *, const struct flowi4 *flp);
+extern struct rtable *__ip_route_output_key(struct net *, struct flowi4 *flp);
 extern struct rtable *ip_route_output_flow(struct net *, struct flowi4 *flp,
 					   struct sock *sk);
 extern struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_orig);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e9244e0..c55620d 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1047,7 +1047,7 @@ static unsigned int ipv4_default_mtu(const struct dst_entry *dst)
 	return mtu;
 }
 
-static void rt_init_metrics(struct rtable *rt, const struct flowi4 *oldflp4,
+static void rt_init_metrics(struct rtable *rt, const struct flowi4 *fl4,
 			    struct fib_info *fi)
 {
 	struct inet_peer *peer;
@@ -1056,7 +1056,7 @@ static void rt_init_metrics(struct rtable *rt, const struct flowi4 *oldflp4,
 	/* If a peer entry exists for this destination, we must hook
 	 * it up in order to get at cached metrics.
 	 */
-	if (oldflp4 && (oldflp4->flowi4_flags & FLOWI_FLAG_PRECOW_METRICS))
+	if (fl4 && (fl4->flowi4_flags & FLOWI_FLAG_PRECOW_METRICS))
 		create = 1;
 
 	rt->peer = peer = inet_getpeer_v4(rt->rt_dst, create);
@@ -1083,7 +1083,7 @@ static void rt_init_metrics(struct rtable *rt, const struct flowi4 *oldflp4,
 	}
 }
 
-static void rt_set_nexthop(struct rtable *rt, const struct flowi4 *oldflp4,
+static void rt_set_nexthop(struct rtable *rt, const struct flowi4 *fl4,
 			   const struct fib_result *res,
 			   struct fib_info *fi, u16 type, u32 itag)
 {
@@ -1093,7 +1093,7 @@ static void rt_set_nexthop(struct rtable *rt, const struct flowi4 *oldflp4,
 		if (FIB_RES_GW(*res) &&
 		    FIB_RES_NH(*res).nh_scope == RT_SCOPE_LINK)
 			rt->rt_gateway = FIB_RES_GW(*res);
-		rt_init_metrics(rt, oldflp4, fi);
+		rt_init_metrics(rt, fl4, fi);
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		dst->tclassid = FIB_RES_NH(*res).nh_tclassid;
 #endif
@@ -1587,12 +1587,11 @@ EXPORT_SYMBOL(ip_route_input);
 /* called with rcu_read_lock() */
 static struct rtable *__mkroute_output(const struct fib_result *res,
 				       const struct flowi4 *fl4,
-				       const struct flowi4 *oldflp4,
 				       struct net_device *dev_out,
 				       unsigned int flags)
 {
 	struct fib_info *fi = res->fi;
-	u32 tos = RT_FL_TOS(oldflp4);
+	u32 tos = RT_FL_TOS(fl4);
 	struct in_device *in_dev;
 	u16 type = res->type;
 	struct rtable *rth;
@@ -1619,8 +1618,8 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
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
@@ -1645,9 +1644,9 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	rth->rt_dst	= fl4->daddr;
 	rth->rt_src	= fl4->saddr;
 	rth->rt_route_iif = 0;
-	rth->rt_iif	= oldflp4->flowi4_oif ? : dev_out->ifindex;
-	rth->rt_oif	= oldflp4->flowi4_oif;
-	rth->rt_mark    = oldflp4->flowi4_mark;
+	rth->rt_iif	= fl4->flowi4_oif ? : dev_out->ifindex;
+	rth->rt_oif	= fl4->flowi4_oif;
+	rth->rt_mark    = fl4->flowi4_mark;
 	rth->rt_gateway = fl4->daddr;
 	rth->rt_spec_dst= fl4->saddr;
 	rth->rt_peer_genid = 0;
@@ -1670,7 +1669,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 #ifdef CONFIG_IP_MROUTE
 		if (type == RTN_MULTICAST) {
 			if (IN_DEV_MFORWARD(in_dev) &&
-			    !ipv4_is_local_multicast(oldflp4->daddr)) {
+			    !ipv4_is_local_multicast(fl4->daddr)) {
 				rth->dst.input = ip_mr_input;
 				rth->dst.output = ip_mc_output;
 			}
@@ -1678,7 +1677,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 #endif
 	}
 
-	rt_set_nexthop(rth, oldflp4, res, fi, type, 0);
+	rt_set_nexthop(rth, fl4, res, fi, type, 0);
 
 	return rth;
 }
@@ -1687,13 +1686,12 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
  * Major route resolver routine.
  */
 
-struct rtable *__ip_route_output_key(struct net *net, const struct flowi4 *oldflp4)
+struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
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
 
 	res.fi		= NULL;
@@ -1701,21 +1699,17 @@ struct rtable *__ip_route_output_key(struct net *net, const struct flowi4 *oldfl
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
@@ -1726,11 +1720,11 @@ struct rtable *__ip_route_output_key(struct net *net, const struct flowi4 *oldfl
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
 
@@ -1749,20 +1743,20 @@ struct rtable *__ip_route_output_key(struct net *net, const struct flowi4 *oldfl
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
@@ -1772,37 +1766,37 @@ struct rtable *__ip_route_output_key(struct net *net, const struct flowi4 *oldfl
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
 
@@ -1821,9 +1815,9 @@ struct rtable *__ip_route_output_key(struct net *net, const struct flowi4 *oldfl
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
@@ -1832,38 +1826,38 @@ struct rtable *__ip_route_output_key(struct net *net, const struct flowi4 *oldfl
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
+	rth = __mkroute_output(&res, fl4, dev_out, flags);
 	if (!IS_ERR(rth))
 		rth = rt_finalize(rth, NULL);
 
-- 
1.7.4.3

