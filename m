From: David Miller <davem@davemloft.net>
Subject: [PATCH 11/25] ipv4: Use struct flowi4 internally in routing
 lookups.
Date: Sat, 12 Mar 2011 15:27:36 -0800 (PST)
Message-ID: <20110312.152736.179934199.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37588
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756024Ab1CLX07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2011 18:26:59 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 0358624C088
	for <netdev@vger.kernel.org>; Sat, 12 Mar 2011 15:27:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We will change the externally visible APIs next.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |  230 +++++++++++++++++++++++++++---------------------------
 1 files changed, 115 insertions(+), 115 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 027b4cc..9e938f9 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -109,8 +109,8 @@
 #include <linux/sysctl.h>
 #endif
 
-#define RT_FL_TOS(oldflp) \
-    ((u32)(oldflp->fl4_tos & (IPTOS_RT_MASK | RTO_ONLINK)))
+#define RT_FL_TOS(oldflp4) \
+    ((u32)(oldflp4->flowi4_tos & (IPTOS_RT_MASK | RTO_ONLINK)))
 
 #define IP_MAX_MTU	0xFFF0
 
@@ -1697,17 +1697,17 @@ void ip_rt_get_source(u8 *addr, struct rtable *rt)
 	if (rt_is_output_route(rt))
 		src = rt->rt_src;
 	else {
-		struct flowi fl = {
-			.fl4_dst = rt->rt_key_dst,
-			.fl4_src = rt->rt_key_src,
-			.fl4_tos = rt->rt_tos,
-			.flowi_oif = rt->rt_oif,
-			.flowi_iif = rt->rt_iif,
-			.flowi_mark = rt->rt_mark,
+		struct flowi4 fl4 = {
+			.daddr = rt->rt_key_dst,
+			.saddr = rt->rt_key_src,
+			.flowi4_tos = rt->rt_tos,
+			.flowi4_oif = rt->rt_oif,
+			.flowi4_iif = rt->rt_iif,
+			.flowi4_mark = rt->rt_mark,
 		};
 
 		rcu_read_lock();
-		if (fib_lookup(dev_net(rt->dst.dev), &fl.u.ip4, &res) == 0)
+		if (fib_lookup(dev_net(rt->dst.dev), &fl4, &res) == 0)
 			src = FIB_RES_PREFSRC(res);
 		else
 			src = inet_select_addr(rt->dst.dev, rt->rt_gateway,
@@ -1757,7 +1757,7 @@ static unsigned int ipv4_default_mtu(const struct dst_entry *dst)
 	return mtu;
 }
 
-static void rt_init_metrics(struct rtable *rt, const struct flowi *oldflp,
+static void rt_init_metrics(struct rtable *rt, const struct flowi4 *oldflp4,
 			    struct fib_info *fi)
 {
 	struct inet_peer *peer;
@@ -1766,7 +1766,7 @@ static void rt_init_metrics(struct rtable *rt, const struct flowi *oldflp,
 	/* If a peer entry exists for this destination, we must hook
 	 * it up in order to get at cached metrics.
 	 */
-	if (oldflp && (oldflp->flowi_flags & FLOWI_FLAG_PRECOW_METRICS))
+	if (oldflp4 && (oldflp4->flowi4_flags & FLOWI_FLAG_PRECOW_METRICS))
 		create = 1;
 
 	rt->peer = peer = inet_getpeer_v4(rt->rt_dst, create);
@@ -1793,7 +1793,7 @@ static void rt_init_metrics(struct rtable *rt, const struct flowi *oldflp,
 	}
 }
 
-static void rt_set_nexthop(struct rtable *rt, const struct flowi *oldflp,
+static void rt_set_nexthop(struct rtable *rt, const struct flowi4 *oldflp4,
 			   const struct fib_result *res,
 			   struct fib_info *fi, u16 type, u32 itag)
 {
@@ -1803,7 +1803,7 @@ static void rt_set_nexthop(struct rtable *rt, const struct flowi *oldflp,
 		if (FIB_RES_GW(*res) &&
 		    FIB_RES_NH(*res).nh_scope == RT_SCOPE_LINK)
 			rt->rt_gateway = FIB_RES_GW(*res);
-		rt_init_metrics(rt, oldflp, fi);
+		rt_init_metrics(rt, oldflp4, fi);
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		dst->tclassid = FIB_RES_NH(*res).nh_tclassid;
 #endif
@@ -2038,7 +2038,7 @@ static int __mkroute_input(struct sk_buff *skb,
 
 static int ip_mkroute_input(struct sk_buff *skb,
 			    struct fib_result *res,
-			    const struct flowi *fl,
+			    const struct flowi4 *fl4,
 			    struct in_device *in_dev,
 			    __be32 daddr, __be32 saddr, u32 tos)
 {
@@ -2057,9 +2057,9 @@ static int ip_mkroute_input(struct sk_buff *skb,
 		return err;
 
 	/* put it into the cache */
-	hash = rt_hash(daddr, saddr, fl->flowi_iif,
+	hash = rt_hash(daddr, saddr, fl4->flowi4_iif,
 		       rt_genid(dev_net(rth->dst.dev)));
-	rth = rt_intern_hash(hash, rth, skb, fl->flowi_iif);
+	rth = rt_intern_hash(hash, rth, skb, fl4->flowi4_iif);
 	if (IS_ERR(rth))
 		return PTR_ERR(rth);
 	return 0;
@@ -2081,7 +2081,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 {
 	struct fib_result res;
 	struct in_device *in_dev = __in_dev_get_rcu(dev);
-	struct flowi fl;
+	struct flowi4	fl4;
 	unsigned	flags = 0;
 	u32		itag = 0;
 	struct rtable * rth;
@@ -2118,14 +2118,14 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	/*
 	 *	Now we are ready to route packet.
 	 */
-	fl.flowi_oif = 0;
-	fl.flowi_iif = dev->ifindex;
-	fl.flowi_mark = skb->mark;
-	fl.fl4_dst = daddr;
-	fl.fl4_src = saddr;
-	fl.fl4_tos = tos;
-	fl.fl4_scope = RT_SCOPE_UNIVERSE;
-	err = fib_lookup(net, &fl.u.ip4, &res);
+	fl4.flowi4_oif = 0;
+	fl4.flowi4_iif = dev->ifindex;
+	fl4.flowi4_mark = skb->mark;
+	fl4.flowi4_tos = tos;
+	fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
+	fl4.daddr = daddr;
+	fl4.saddr = saddr;
+	err = fib_lookup(net, &fl4, &res);
 	if (err != 0) {
 		if (!IN_DEV_FORWARD(in_dev))
 			goto e_hostunreach;
@@ -2154,7 +2154,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	if (res.type != RTN_UNICAST)
 		goto martian_destination;
 
-	err = ip_mkroute_input(skb, &res, &fl, in_dev, daddr, saddr, tos);
+	err = ip_mkroute_input(skb, &res, &fl4, in_dev, daddr, saddr, tos);
 out:	return err;
 
 brd_input:
@@ -2205,8 +2205,8 @@ local_input:
 		rth->rt_flags 	&= ~RTCF_LOCAL;
 	}
 	rth->rt_type	= res.type;
-	hash = rt_hash(daddr, saddr, fl.flowi_iif, rt_genid(net));
-	rth = rt_intern_hash(hash, rth, skb, fl.flowi_iif);
+	hash = rt_hash(daddr, saddr, fl4.flowi4_iif, rt_genid(net));
+	rth = rt_intern_hash(hash, rth, skb, fl4.flowi4_iif);
 	err = 0;
 	if (IS_ERR(rth))
 		err = PTR_ERR(rth);
@@ -2335,25 +2335,25 @@ EXPORT_SYMBOL(ip_route_input_common);
 
 /* called with rcu_read_lock() */
 static struct rtable *__mkroute_output(const struct fib_result *res,
-				       const struct flowi *fl,
-				       const struct flowi *oldflp,
+				       const struct flowi4 *fl4,
+				       const struct flowi4 *oldflp4,
 				       struct net_device *dev_out,
 				       unsigned int flags)
 {
 	struct fib_info *fi = res->fi;
-	u32 tos = RT_FL_TOS(oldflp);
+	u32 tos = RT_FL_TOS(oldflp4);
 	struct in_device *in_dev;
 	u16 type = res->type;
 	struct rtable *rth;
 
-	if (ipv4_is_loopback(fl->fl4_src) && !(dev_out->flags & IFF_LOOPBACK))
+	if (ipv4_is_loopback(fl4->saddr) && !(dev_out->flags & IFF_LOOPBACK))
 		return ERR_PTR(-EINVAL);
 
-	if (ipv4_is_lbcast(fl->fl4_dst))
+	if (ipv4_is_lbcast(fl4->daddr))
 		type = RTN_BROADCAST;
-	else if (ipv4_is_multicast(fl->fl4_dst))
+	else if (ipv4_is_multicast(fl4->daddr))
 		type = RTN_MULTICAST;
-	else if (ipv4_is_zeronet(fl->fl4_dst))
+	else if (ipv4_is_zeronet(fl4->daddr))
 		return ERR_PTR(-EINVAL);
 
 	if (dev_out->flags & IFF_LOOPBACK)
@@ -2368,8 +2368,8 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 		fi = NULL;
 	} else if (type == RTN_MULTICAST) {
 		flags |= RTCF_MULTICAST | RTCF_LOCAL;
-		if (!ip_check_mc_rcu(in_dev, oldflp->fl4_dst, oldflp->fl4_src,
-				     oldflp->flowi_proto))
+		if (!ip_check_mc_rcu(in_dev, oldflp4->daddr, oldflp4->saddr,
+				     oldflp4->flowi4_proto))
 			flags &= ~RTCF_LOCAL;
 		/* If multicast route do not exist use
 		 * default one, but do not gateway in this case.
@@ -2384,20 +2384,20 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	if (!rth)
 		return ERR_PTR(-ENOBUFS);
 
-	rth->rt_key_dst	= oldflp->fl4_dst;
+	rth->rt_key_dst	= oldflp4->daddr;
 	rth->rt_tos	= tos;
-	rth->rt_key_src	= oldflp->fl4_src;
-	rth->rt_oif	= oldflp->flowi_oif;
-	rth->rt_mark    = oldflp->flowi_mark;
-	rth->rt_dst	= fl->fl4_dst;
-	rth->rt_src	= fl->fl4_src;
+	rth->rt_key_src	= oldflp4->saddr;
+	rth->rt_oif	= oldflp4->flowi4_oif;
+	rth->rt_mark    = oldflp4->flowi4_mark;
+	rth->rt_dst	= fl4->daddr;
+	rth->rt_src	= fl4->saddr;
 	rth->rt_iif	= 0;
 	/* get references to the devices that are to be hold by the routing
 	   cache entry */
 	rth->dst.dev	= dev_out;
 	dev_hold(dev_out);
-	rth->rt_gateway = fl->fl4_dst;
-	rth->rt_spec_dst= fl->fl4_src;
+	rth->rt_gateway = fl4->daddr;
+	rth->rt_spec_dst= fl4->saddr;
 
 	rth->dst.output=ip_output;
 	rth->rt_genid = rt_genid(dev_net(dev_out));
@@ -2406,10 +2406,10 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 
 	if (flags & RTCF_LOCAL) {
 		rth->dst.input = ip_local_deliver;
-		rth->rt_spec_dst = fl->fl4_dst;
+		rth->rt_spec_dst = fl4->daddr;
 	}
 	if (flags & (RTCF_BROADCAST | RTCF_MULTICAST)) {
-		rth->rt_spec_dst = fl->fl4_src;
+		rth->rt_spec_dst = fl4->saddr;
 		if (flags & RTCF_LOCAL &&
 		    !(dev_out->flags & IFF_LOOPBACK)) {
 			rth->dst.output = ip_mc_output;
@@ -2418,7 +2418,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 #ifdef CONFIG_IP_MROUTE
 		if (type == RTN_MULTICAST) {
 			if (IN_DEV_MFORWARD(in_dev) &&
-			    !ipv4_is_local_multicast(oldflp->fl4_dst)) {
+			    !ipv4_is_local_multicast(oldflp4->daddr)) {
 				rth->dst.input = ip_mr_input;
 				rth->dst.output = ip_mc_output;
 			}
@@ -2426,7 +2426,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 #endif
 	}
 
-	rt_set_nexthop(rth, oldflp, res, fi, type, 0);
+	rt_set_nexthop(rth, oldflp4, res, fi, type, 0);
 
 	rth->rt_flags = flags;
 	return rth;
@@ -2438,10 +2438,10 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
  */
 
 static struct rtable *ip_route_output_slow(struct net *net,
-					   const struct flowi *oldflp)
+					   const struct flowi4 *oldflp4)
 {
-	u32 tos	= RT_FL_TOS(oldflp);
-	struct flowi fl;
+	u32 tos	= RT_FL_TOS(oldflp4);
+	struct flowi4 fl4;
 	struct fib_result res;
 	unsigned int flags = 0;
 	struct net_device *dev_out = NULL;
@@ -2452,21 +2452,21 @@ static struct rtable *ip_route_output_slow(struct net *net,
 	res.r		= NULL;
 #endif
 
-	fl.flowi_oif = oldflp->flowi_oif;
-	fl.flowi_iif = net->loopback_dev->ifindex;
-	fl.flowi_mark = oldflp->flowi_mark;
-	fl.fl4_dst = oldflp->fl4_dst;
-	fl.fl4_src = oldflp->fl4_src;
-	fl.fl4_tos = tos & IPTOS_RT_MASK;
-	fl.fl4_scope = ((tos & RTO_ONLINK) ?
+	fl4.flowi4_oif = oldflp4->flowi4_oif;
+	fl4.flowi4_iif = net->loopback_dev->ifindex;
+	fl4.flowi4_mark = oldflp4->flowi4_mark;
+	fl4.daddr = oldflp4->daddr;
+	fl4.saddr = oldflp4->saddr;
+	fl4.flowi4_tos = tos & IPTOS_RT_MASK;
+	fl4.flowi4_scope = ((tos & RTO_ONLINK) ?
 			RT_SCOPE_LINK : RT_SCOPE_UNIVERSE);
 
 	rcu_read_lock();
-	if (oldflp->fl4_src) {
+	if (oldflp4->saddr) {
 		rth = ERR_PTR(-EINVAL);
-		if (ipv4_is_multicast(oldflp->fl4_src) ||
-		    ipv4_is_lbcast(oldflp->fl4_src) ||
-		    ipv4_is_zeronet(oldflp->fl4_src))
+		if (ipv4_is_multicast(oldflp4->saddr) ||
+		    ipv4_is_lbcast(oldflp4->saddr) ||
+		    ipv4_is_zeronet(oldflp4->saddr))
 			goto out;
 
 		/* I removed check for oif == dev_out->oif here.
@@ -2477,11 +2477,11 @@ static struct rtable *ip_route_output_slow(struct net *net,
 		      of another iface. --ANK
 		 */
 
-		if (oldflp->flowi_oif == 0 &&
-		    (ipv4_is_multicast(oldflp->fl4_dst) ||
-		     ipv4_is_lbcast(oldflp->fl4_dst))) {
+		if (oldflp4->flowi4_oif == 0 &&
+		    (ipv4_is_multicast(oldflp4->daddr) ||
+		     ipv4_is_lbcast(oldflp4->daddr))) {
 			/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
-			dev_out = __ip_dev_find(net, oldflp->fl4_src, false);
+			dev_out = __ip_dev_find(net, oldflp4->saddr, false);
 			if (dev_out == NULL)
 				goto out;
 
@@ -2500,20 +2500,20 @@ static struct rtable *ip_route_output_slow(struct net *net,
 			   Luckily, this hack is good workaround.
 			 */
 
-			fl.flowi_oif = dev_out->ifindex;
+			fl4.flowi4_oif = dev_out->ifindex;
 			goto make_route;
 		}
 
-		if (!(oldflp->flowi_flags & FLOWI_FLAG_ANYSRC)) {
+		if (!(oldflp4->flowi4_flags & FLOWI_FLAG_ANYSRC)) {
 			/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
-			if (!__ip_dev_find(net, oldflp->fl4_src, false))
+			if (!__ip_dev_find(net, oldflp4->saddr, false))
 				goto out;
 		}
 	}
 
 
-	if (oldflp->flowi_oif) {
-		dev_out = dev_get_by_index_rcu(net, oldflp->flowi_oif);
+	if (oldflp4->flowi4_oif) {
+		dev_out = dev_get_by_index_rcu(net, oldflp4->flowi4_oif);
 		rth = ERR_PTR(-ENODEV);
 		if (dev_out == NULL)
 			goto out;
@@ -2523,37 +2523,37 @@ static struct rtable *ip_route_output_slow(struct net *net,
 			rth = ERR_PTR(-ENETUNREACH);
 			goto out;
 		}
-		if (ipv4_is_local_multicast(oldflp->fl4_dst) ||
-		    ipv4_is_lbcast(oldflp->fl4_dst)) {
-			if (!fl.fl4_src)
-				fl.fl4_src = inet_select_addr(dev_out, 0,
-							      RT_SCOPE_LINK);
+		if (ipv4_is_local_multicast(oldflp4->daddr) ||
+		    ipv4_is_lbcast(oldflp4->daddr)) {
+			if (!fl4.saddr)
+				fl4.saddr = inet_select_addr(dev_out, 0,
+							     RT_SCOPE_LINK);
 			goto make_route;
 		}
-		if (!fl.fl4_src) {
-			if (ipv4_is_multicast(oldflp->fl4_dst))
-				fl.fl4_src = inet_select_addr(dev_out, 0,
-							      fl.fl4_scope);
-			else if (!oldflp->fl4_dst)
-				fl.fl4_src = inet_select_addr(dev_out, 0,
-							      RT_SCOPE_HOST);
+		if (!fl4.saddr) {
+			if (ipv4_is_multicast(oldflp4->daddr))
+				fl4.saddr = inet_select_addr(dev_out, 0,
+							     fl4.flowi4_scope);
+			else if (!oldflp4->daddr)
+				fl4.saddr = inet_select_addr(dev_out, 0,
+							     RT_SCOPE_HOST);
 		}
 	}
 
-	if (!fl.fl4_dst) {
-		fl.fl4_dst = fl.fl4_src;
-		if (!fl.fl4_dst)
-			fl.fl4_dst = fl.fl4_src = htonl(INADDR_LOOPBACK);
+	if (!fl4.daddr) {
+		fl4.daddr = fl4.saddr;
+		if (!fl4.daddr)
+			fl4.daddr = fl4.saddr = htonl(INADDR_LOOPBACK);
 		dev_out = net->loopback_dev;
-		fl.flowi_oif = net->loopback_dev->ifindex;
+		fl4.flowi4_oif = net->loopback_dev->ifindex;
 		res.type = RTN_LOCAL;
 		flags |= RTCF_LOCAL;
 		goto make_route;
 	}
 
-	if (fib_lookup(net, &fl.u.ip4, &res)) {
+	if (fib_lookup(net, &fl4, &res)) {
 		res.fi = NULL;
-		if (oldflp->flowi_oif) {
+		if (oldflp4->flowi4_oif) {
 			/* Apparently, routing tables are wrong. Assume,
 			   that the destination is on link.
 
@@ -2572,9 +2572,9 @@ static struct rtable *ip_route_output_slow(struct net *net,
 			   likely IPv6, but we do not.
 			 */
 
-			if (fl.fl4_src == 0)
-				fl.fl4_src = inet_select_addr(dev_out, 0,
-							      RT_SCOPE_LINK);
+			if (fl4.saddr == 0)
+				fl4.saddr = inet_select_addr(dev_out, 0,
+							     RT_SCOPE_LINK);
 			res.type = RTN_UNICAST;
 			goto make_route;
 		}
@@ -2583,42 +2583,42 @@ static struct rtable *ip_route_output_slow(struct net *net,
 	}
 
 	if (res.type == RTN_LOCAL) {
-		if (!fl.fl4_src) {
+		if (!fl4.saddr) {
 			if (res.fi->fib_prefsrc)
-				fl.fl4_src = res.fi->fib_prefsrc;
+				fl4.saddr = res.fi->fib_prefsrc;
 			else
-				fl.fl4_src = fl.fl4_dst;
+				fl4.saddr = fl4.daddr;
 		}
 		dev_out = net->loopback_dev;
-		fl.flowi_oif = dev_out->ifindex;
+		fl4.flowi4_oif = dev_out->ifindex;
 		res.fi = NULL;
 		flags |= RTCF_LOCAL;
 		goto make_route;
 	}
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-	if (res.fi->fib_nhs > 1 && fl.flowi_oif == 0)
+	if (res.fi->fib_nhs > 1 && fl4.flowi4_oif == 0)
 		fib_select_multipath(&res);
 	else
 #endif
-	if (!res.prefixlen && res.type == RTN_UNICAST && !fl.flowi_oif)
+	if (!res.prefixlen && res.type == RTN_UNICAST && !fl4.flowi4_oif)
 		fib_select_default(&res);
 
-	if (!fl.fl4_src)
-		fl.fl4_src = FIB_RES_PREFSRC(res);
+	if (!fl4.saddr)
+		fl4.saddr = FIB_RES_PREFSRC(res);
 
 	dev_out = FIB_RES_DEV(res);
-	fl.flowi_oif = dev_out->ifindex;
+	fl4.flowi4_oif = dev_out->ifindex;
 
 
 make_route:
-	rth = __mkroute_output(&res, &fl, oldflp, dev_out, flags);
+	rth = __mkroute_output(&res, &fl4, oldflp4, dev_out, flags);
 	if (!IS_ERR(rth)) {
 		unsigned int hash;
 
-		hash = rt_hash(oldflp->fl4_dst, oldflp->fl4_src, oldflp->flowi_oif,
+		hash = rt_hash(oldflp4->daddr, oldflp4->saddr, oldflp4->flowi4_oif,
 			       rt_genid(dev_net(dev_out)));
-		rth = rt_intern_hash(hash, rth, NULL, oldflp->flowi_oif);
+		rth = rt_intern_hash(hash, rth, NULL, oldflp4->flowi4_oif);
 	}
 
 out:
@@ -2658,7 +2658,7 @@ struct rtable *__ip_route_output_key(struct net *net, const struct flowi *flp)
 	rcu_read_unlock_bh();
 
 slow_output:
-	return ip_route_output_slow(net, flp);
+	return ip_route_output_slow(net, &flp->u.ip4);
 }
 EXPORT_SYMBOL_GPL(__ip_route_output_key);
 
@@ -2913,14 +2913,14 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 		if (err == 0 && rt->dst.error)
 			err = -rt->dst.error;
 	} else {
-		struct flowi fl = {
-			.fl4_dst = dst,
-			.fl4_src = src,
-			.fl4_tos = rtm->rtm_tos,
-			.flowi_oif = tb[RTA_OIF] ? nla_get_u32(tb[RTA_OIF]) : 0,
-			.flowi_mark = mark,
+		struct flowi4 fl4 = {
+			.daddr = dst,
+			.saddr = src,
+			.flowi4_tos = rtm->rtm_tos,
+			.flowi4_oif = tb[RTA_OIF] ? nla_get_u32(tb[RTA_OIF]) : 0,
+			.flowi4_mark = mark,
 		};
-		rt = ip_route_output_key(net, &fl);
+		rt = ip_route_output_key(net, flowi4_to_flowi(&fl4));
 
 		err = 0;
 		if (IS_ERR(rt))
-- 
1.7.4.1

