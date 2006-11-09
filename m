From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/6] [NET]: Rethink mark field in struct flowi
Date: Thu, 09 Nov 2006 12:27:37 +0100
Message-ID: <20061109113245.573179984@lsx.localdomain>
References: <20061109112735.577771022@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:5584 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932815AbWKILdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Nov 2006 06:33:42 -0500
To: davem@davemloft.net
Content-Disposition: inline; filename=cleanup_flowi
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that all protocols have been made aware of the mark
field it can be moved out of the union thus simplyfing
its usage.

The config options in the IPv4/IPv6/DECnet subsystems
to enable respectively disable mark based routing only
obfuscate the code with ifdefs, the cost for the
additional comparison in the flow key is insignificant,
and most distributions have all these options enabled
by default anyway. Therefore it makes sense to remove
the config options and enable mark based routing by
default.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.20/include/net/flow.h
===================================================================
--- net-2.6.20.orig/include/net/flow.h	2006-11-08 15:34:12.000000000 +0100
+++ net-2.6.20/include/net/flow.h	2006-11-08 16:12:32.000000000 +0100
@@ -18,7 +18,6 @@
 		struct {
 			__be32			daddr;
 			__be32			saddr;
-			__u32			fwmark;
 			__u8			tos;
 			__u8			scope;
 		} ip4_u;
@@ -26,28 +25,23 @@
 		struct {
 			struct in6_addr		daddr;
 			struct in6_addr		saddr;
-			__u32			fwmark;
 			__be32			flowlabel;
 		} ip6_u;
 
 		struct {
 			__le16			daddr;
 			__le16			saddr;
-			__u32			fwmark;
 			__u8			scope;
 		} dn_u;
 	} nl_u;
 #define fld_dst		nl_u.dn_u.daddr
 #define fld_src		nl_u.dn_u.saddr
-#define fld_fwmark	nl_u.dn_u.fwmark
 #define fld_scope	nl_u.dn_u.scope
 #define fl6_dst		nl_u.ip6_u.daddr
 #define fl6_src		nl_u.ip6_u.saddr
-#define fl6_fwmark	nl_u.ip6_u.fwmark
 #define fl6_flowlabel	nl_u.ip6_u.flowlabel
 #define fl4_dst		nl_u.ip4_u.daddr
 #define fl4_src		nl_u.ip4_u.saddr
-#define fl4_fwmark	nl_u.ip4_u.fwmark
 #define fl4_tos		nl_u.ip4_u.tos
 #define fl4_scope	nl_u.ip4_u.scope
 
@@ -86,6 +80,7 @@
 #ifdef CONFIG_IPV6_MIP6
 #define fl_mh_type	uli_u.mht.type
 #endif
+	__u32		mark;
 	__u32           secid;	/* used by xfrm; see secid.txt */
 } __attribute__((__aligned__(BITS_PER_LONG/8)));
 
Index: net-2.6.20/net/decnet/dn_route.c
===================================================================
--- net-2.6.20.orig/net/decnet/dn_route.c	2006-11-08 16:12:30.000000000 +0100
+++ net-2.6.20/net/decnet/dn_route.c	2006-11-08 16:12:32.000000000 +0100
@@ -269,9 +269,7 @@
 {
 	return ((fl1->nl_u.dn_u.daddr ^ fl2->nl_u.dn_u.daddr) |
 		(fl1->nl_u.dn_u.saddr ^ fl2->nl_u.dn_u.saddr) |
-#ifdef CONFIG_DECNET_ROUTE_FWMARK
-		(fl1->nl_u.dn_u.fwmark ^ fl2->nl_u.dn_u.fwmark) |
-#endif
+		(fl1->mark ^ fl2->mark) |
 		(fl1->nl_u.dn_u.scope ^ fl2->nl_u.dn_u.scope) |
 		(fl1->oif ^ fl2->oif) |
 		(fl1->iif ^ fl2->iif)) == 0;
@@ -882,10 +880,8 @@
 				      { .daddr = oldflp->fld_dst,
 					.saddr = oldflp->fld_src,
 					.scope = RT_SCOPE_UNIVERSE,
-#ifdef CONFIG_DECNET_ROUTE_FWMARK
-					.fwmark = oldflp->fld_fwmark
-#endif
 				     } },
+			    .mark = oldflp->mark,
 			    .iif = loopback_dev.ifindex,
 			    .oif = oldflp->oif };
 	struct dn_route *rt = NULL;
@@ -903,7 +899,7 @@
 		       "dn_route_output_slow: dst=%04x src=%04x mark=%d"
 		       " iif=%d oif=%d\n", dn_ntohs(oldflp->fld_dst),
 		       dn_ntohs(oldflp->fld_src),
-                       oldflp->fld_fwmark, loopback_dev.ifindex, oldflp->oif);
+                       oldflp->mark, loopback_dev.ifindex, oldflp->oif);
 
 	/* If we have an output interface, verify its a DECnet device */
 	if (oldflp->oif) {
@@ -1108,9 +1104,7 @@
 	rt->fl.fld_dst    = oldflp->fld_dst;
 	rt->fl.oif        = oldflp->oif;
 	rt->fl.iif        = 0;
-#ifdef CONFIG_DECNET_ROUTE_FWMARK
-	rt->fl.fld_fwmark = oldflp->fld_fwmark;
-#endif
+	rt->fl.mark       = oldflp->mark;
 
 	rt->rt_saddr      = fl.fld_src;
 	rt->rt_daddr      = fl.fld_dst;
@@ -1178,9 +1172,7 @@
 			rt = rcu_dereference(rt->u.rt_next)) {
 			if ((flp->fld_dst == rt->fl.fld_dst) &&
 			    (flp->fld_src == rt->fl.fld_src) &&
-#ifdef CONFIG_DECNET_ROUTE_FWMARK
-			    (flp->fld_fwmark == rt->fl.fld_fwmark) &&
-#endif
+			    (flp->mark == rt->fl.mark) &&
 			    (rt->fl.iif == 0) &&
 			    (rt->fl.oif == flp->oif)) {
 				rt->u.dst.lastuse = jiffies;
@@ -1235,10 +1227,8 @@
 				     { .daddr = cb->dst,
 				       .saddr = cb->src,
 				       .scope = RT_SCOPE_UNIVERSE,
-#ifdef CONFIG_DECNET_ROUTE_FWMARK
-				       .fwmark = skb->mark
-#endif
 				    } },
+			    .mark = skb->mark,
 			    .iif = skb->dev->ifindex };
 	struct dn_fib_res res = { .fi = NULL, .type = RTN_UNREACHABLE };
 	int err = -EINVAL;
@@ -1385,7 +1375,7 @@
 	rt->fl.fld_dst    = cb->dst;
 	rt->fl.oif        = 0;
 	rt->fl.iif        = in_dev->ifindex;
-	rt->fl.fld_fwmark = fl.fld_fwmark;
+	rt->fl.mark       = fl.mark;
 
 	rt->u.dst.flags = DST_HOST;
 	rt->u.dst.neighbour = neigh;
@@ -1457,9 +1447,7 @@
 		if ((rt->fl.fld_src == cb->src) &&
 	 	    (rt->fl.fld_dst == cb->dst) &&
 		    (rt->fl.oif == 0) &&
-#ifdef CONFIG_DECNET_ROUTE_FWMARK
-		    (rt->fl.fld_fwmark == skb->mark) &&
-#endif
+		    (rt->fl.mark == skb->mark) &&
 		    (rt->fl.iif == cb->iif)) {
 			rt->u.dst.lastuse = jiffies;
 			dst_hold(&rt->u.dst);
Index: net-2.6.20/net/decnet/dn_rules.c
===================================================================
--- net-2.6.20.orig/net/decnet/dn_rules.c	2006-11-08 15:34:12.000000000 +0100
+++ net-2.6.20/net/decnet/dn_rules.c	2006-11-08 16:12:32.000000000 +0100
@@ -45,10 +45,8 @@
 	__le16			dstmask;
 	__le16			srcmap;
 	u8			flags;
-#ifdef CONFIG_DECNET_ROUTE_FWMARK
 	u32			fwmark;
 	u32			fwmask;
-#endif
 };
 
 static struct dn_fib_rule default_rule = {
@@ -131,10 +129,8 @@
 	    ((daddr ^ r->dst) & r->dstmask))
 		return 0;
 
-#ifdef CONFIG_DECNET_ROUTE_FWMARK
-	if ((r->fwmark ^ fl->fld_fwmark) & r->fwmask)
+	if ((r->fwmark ^ fl->mark) & r->fwmask)
 		return 0;
-#endif
 
 	return 1;
 }
@@ -169,7 +165,6 @@
 	if (tb[FRA_DST])
 		r->dst = nla_get_u16(tb[FRA_DST]);
 
-#ifdef CONFIG_DECNET_ROUTE_FWMARK
 	if (tb[FRA_FWMARK]) {
 		r->fwmark = nla_get_u32(tb[FRA_FWMARK]);
 		if (r->fwmark)
@@ -181,7 +176,6 @@
 
 	if (tb[FRA_FWMASK])
 		r->fwmask = nla_get_u32(tb[FRA_FWMASK]);
-#endif
 
 	r->src_len = frh->src_len;
 	r->srcmask = dnet_make_mask(r->src_len);
@@ -203,13 +197,11 @@
 	if (frh->dst_len && (r->dst_len != frh->dst_len))
 		return 0;
 
-#ifdef CONFIG_DECNET_ROUTE_FWMARK
 	if (tb[FRA_FWMARK] && (r->fwmark != nla_get_u32(tb[FRA_FWMARK])))
 		return 0;
 
 	if (tb[FRA_FWMASK] && (r->fwmask != nla_get_u32(tb[FRA_FWMASK])))
 		return 0;
-#endif
 
 	if (tb[FRA_SRC] && (r->src != nla_get_u16(tb[FRA_SRC])))
 		return 0;
@@ -248,12 +240,10 @@
 	frh->src_len = r->src_len;
 	frh->tos = 0;
 
-#ifdef CONFIG_DECNET_ROUTE_FWMARK
 	if (r->fwmark)
 		NLA_PUT_U32(skb, FRA_FWMARK, r->fwmark);
 	if (r->fwmask || r->fwmark)
 		NLA_PUT_U32(skb, FRA_FWMASK, r->fwmask);
-#endif
 	if (r->dst_len)
 		NLA_PUT_U16(skb, FRA_DST, r->dst);
 	if (r->src_len)
Index: net-2.6.20/net/ipv6/fib6_rules.c
===================================================================
--- net-2.6.20.orig/net/ipv6/fib6_rules.c	2006-11-08 15:34:13.000000000 +0100
+++ net-2.6.20/net/ipv6/fib6_rules.c	2006-11-08 16:12:32.000000000 +0100
@@ -25,10 +25,8 @@
 	struct fib_rule		common;
 	struct rt6key		src;
 	struct rt6key		dst;
-#ifdef CONFIG_IPV6_ROUTE_FWMARK
 	u32			fwmark;
 	u32			fwmask;
-#endif
 	u8			tclass;
 };
 
@@ -130,10 +128,8 @@
 	if (r->tclass && r->tclass != ((ntohl(fl->fl6_flowlabel) >> 20) & 0xff))
 		return 0;
 
-#ifdef CONFIG_IPV6_ROUTE_FWMARK
-	if ((r->fwmark ^ fl->fl6_fwmark) & r->fwmask)
+	if ((r->fwmark ^ fl->mark) & r->fwmask)
 		return 0;
-#endif
 
 	return 1;
 }
@@ -177,7 +173,6 @@
 		nla_memcpy(&rule6->dst.addr, tb[FRA_DST],
 			   sizeof(struct in6_addr));
 
-#ifdef CONFIG_IPV6_ROUTE_FWMARK
 	if (tb[FRA_FWMARK]) {
 		rule6->fwmark = nla_get_u32(tb[FRA_FWMARK]);
 		if (rule6->fwmark) {
@@ -192,7 +187,6 @@
 
 	if (tb[FRA_FWMASK])
 		rule6->fwmask = nla_get_u32(tb[FRA_FWMASK]);
-#endif
 
 	rule6->src.plen = frh->src_len;
 	rule6->dst.plen = frh->dst_len;
@@ -225,13 +219,11 @@
 	    nla_memcmp(tb[FRA_DST], &rule6->dst.addr, sizeof(struct in6_addr)))
 		return 0;
 
-#ifdef CONFIG_IPV6_ROUTE_FWMARK
 	if (tb[FRA_FWMARK] && (rule6->fwmark != nla_get_u32(tb[FRA_FWMARK])))
 		return 0;
 
 	if (tb[FRA_FWMASK] && (rule6->fwmask != nla_get_u32(tb[FRA_FWMASK])))
 		return 0;
-#endif
 
 	return 1;
 }
@@ -254,13 +246,11 @@
 		NLA_PUT(skb, FRA_SRC, sizeof(struct in6_addr),
 			&rule6->src.addr);
 
-#ifdef CONFIG_IPV6_ROUTE_FWMARK
 	if (rule6->fwmark)
 		NLA_PUT_U32(skb, FRA_FWMARK, rule6->fwmark);
 
 	if (rule6->fwmask || rule6->fwmark)
 		NLA_PUT_U32(skb, FRA_FWMASK, rule6->fwmask);
-#endif
 
 	return 0;
 
Index: net-2.6.20/net/ipv6/route.c
===================================================================
--- net-2.6.20.orig/net/ipv6/route.c	2006-11-08 16:12:30.000000000 +0100
+++ net-2.6.20/net/ipv6/route.c	2006-11-08 16:12:32.000000000 +0100
@@ -710,12 +710,10 @@
 			.ip6_u = {
 				.daddr = iph->daddr,
 				.saddr = iph->saddr,
-#ifdef CONFIG_IPV6_ROUTE_FWMARK
-				.fwmark = skb->mark,
-#endif
 				.flowlabel = (* (__be32 *) iph)&IPV6_FLOWINFO_MASK,
 			},
 		},
+ 		.mark = skb->mark,
 		.proto = iph->nexthdr,
 	};
 
Index: net-2.6.20/net/ipv4/route.c
===================================================================
--- net-2.6.20.orig/net/ipv4/route.c	2006-11-08 16:12:30.000000000 +0100
+++ net-2.6.20/net/ipv4/route.c	2006-11-08 16:12:32.000000000 +0100
@@ -568,9 +568,7 @@
 {
 	return ((fl1->nl_u.ip4_u.daddr ^ fl2->nl_u.ip4_u.daddr) |
 		(fl1->nl_u.ip4_u.saddr ^ fl2->nl_u.ip4_u.saddr) |
-#ifdef CONFIG_IP_ROUTE_FWMARK
-		(fl1->nl_u.ip4_u.fwmark ^ fl2->nl_u.ip4_u.fwmark) |
-#endif
+		(fl1->mark ^ fl2->mark) |
 		(*(u16 *)&fl1->nl_u.ip4_u.tos ^
 		 *(u16 *)&fl2->nl_u.ip4_u.tos) |
 		(fl1->oif ^ fl2->oif) |
@@ -1643,9 +1641,7 @@
 	rth->fl.fl4_dst	= daddr;
 	rth->rt_dst	= daddr;
 	rth->fl.fl4_tos	= tos;
-#ifdef CONFIG_IP_ROUTE_FWMARK
-	rth->fl.fl4_fwmark= skb->mark;
-#endif
+	rth->fl.mark    = skb->mark;
 	rth->fl.fl4_src	= saddr;
 	rth->rt_src	= saddr;
 #ifdef CONFIG_NET_CLS_ROUTE
@@ -1789,9 +1785,7 @@
 	rth->fl.fl4_dst	= daddr;
 	rth->rt_dst	= daddr;
 	rth->fl.fl4_tos	= tos;
-#ifdef CONFIG_IP_ROUTE_FWMARK
-	rth->fl.fl4_fwmark= skb->mark;
-#endif
+	rth->fl.mark    = skb->mark;
 	rth->fl.fl4_src	= saddr;
 	rth->rt_src	= saddr;
 	rth->rt_gateway	= daddr;
@@ -1920,10 +1914,8 @@
 					.saddr = saddr,
 					.tos = tos,
 					.scope = RT_SCOPE_UNIVERSE,
-#ifdef CONFIG_IP_ROUTE_FWMARK
-					.fwmark = skb->mark
-#endif
 				      } },
+			    .mark = skb->mark,
 			    .iif = dev->ifindex };
 	unsigned	flags = 0;
 	u32		itag = 0;
@@ -2034,9 +2026,7 @@
 	rth->fl.fl4_dst	= daddr;
 	rth->rt_dst	= daddr;
 	rth->fl.fl4_tos	= tos;
-#ifdef CONFIG_IP_ROUTE_FWMARK
-	rth->fl.fl4_fwmark= skb->mark;
-#endif
+	rth->fl.mark    = skb->mark;
 	rth->fl.fl4_src	= saddr;
 	rth->rt_src	= saddr;
 #ifdef CONFIG_NET_CLS_ROUTE
@@ -2113,9 +2103,7 @@
 		    rth->fl.fl4_src == saddr &&
 		    rth->fl.iif == iif &&
 		    rth->fl.oif == 0 &&
-#ifdef CONFIG_IP_ROUTE_FWMARK
-		    rth->fl.fl4_fwmark == skb->mark &&
-#endif
+		    rth->fl.mark == skb->mark &&
 		    rth->fl.fl4_tos == tos) {
 			rth->u.dst.lastuse = jiffies;
 			dst_hold(&rth->u.dst);
@@ -2239,9 +2227,7 @@
 	rth->fl.fl4_tos	= tos;
 	rth->fl.fl4_src	= oldflp->fl4_src;
 	rth->fl.oif	= oldflp->oif;
-#ifdef CONFIG_IP_ROUTE_FWMARK
-	rth->fl.fl4_fwmark= oldflp->fl4_fwmark;
-#endif
+	rth->fl.mark    = oldflp->mark;
 	rth->rt_dst	= fl->fl4_dst;
 	rth->rt_src	= fl->fl4_src;
 	rth->rt_iif	= oldflp->oif ? : dev_out->ifindex;
@@ -2385,10 +2371,8 @@
 					.scope = ((tos & RTO_ONLINK) ?
 						  RT_SCOPE_LINK :
 						  RT_SCOPE_UNIVERSE),
-#ifdef CONFIG_IP_ROUTE_FWMARK
-					.fwmark = oldflp->fl4_fwmark
-#endif
 				      } },
+			    .mark = oldflp->mark,
 			    .iif = loopback_dev.ifindex,
 			    .oif = oldflp->oif };
 	struct fib_result res;
@@ -2583,9 +2567,7 @@
 		    rth->fl.fl4_src == flp->fl4_src &&
 		    rth->fl.iif == 0 &&
 		    rth->fl.oif == flp->oif &&
-#ifdef CONFIG_IP_ROUTE_FWMARK
-		    rth->fl.fl4_fwmark == flp->fl4_fwmark &&
-#endif
+		    rth->fl.mark == flp->mark &&
 		    !((rth->fl.fl4_tos ^ flp->fl4_tos) &
 			    (IPTOS_RT_MASK | RTO_ONLINK))) {
 
Index: net-2.6.20/net/ipv4/fib_frontend.c
===================================================================
--- net-2.6.20.orig/net/ipv4/fib_frontend.c	2006-11-08 15:34:12.000000000 +0100
+++ net-2.6.20/net/ipv4/fib_frontend.c	2006-11-08 16:12:32.000000000 +0100
@@ -768,8 +768,8 @@
 {
 	
 	struct fib_result       res;
-	struct flowi            fl = { .nl_u = { .ip4_u = { .daddr = frn->fl_addr, 
-							    .fwmark = frn->fl_fwmark,
+	struct flowi            fl = { .mark = frn->fl_fwmark,
+				       .nl_u = { .ip4_u = { .daddr = frn->fl_addr,
 							    .tos = frn->fl_tos,
 							    .scope = frn->fl_scope } } };
 	if (tb) {
Index: net-2.6.20/net/ipv4/netfilter.c
===================================================================
--- net-2.6.20.orig/net/ipv4/netfilter.c	2006-11-08 16:12:30.000000000 +0100
+++ net-2.6.20/net/ipv4/netfilter.c	2006-11-08 16:12:32.000000000 +0100
@@ -27,9 +27,7 @@
 		fl.nl_u.ip4_u.saddr = iph->saddr;
 		fl.nl_u.ip4_u.tos = RT_TOS(iph->tos);
 		fl.oif = (*pskb)->sk ? (*pskb)->sk->sk_bound_dev_if : 0;
-#ifdef CONFIG_IP_ROUTE_FWMARK
-		fl.nl_u.ip4_u.fwmark = (*pskb)->mark;
-#endif
+		fl.mark = (*pskb)->mark;
 		if (ip_route_output_key(&rt, &fl) != 0)
 			return -1;
 
Index: net-2.6.20/include/net/ip_mp_alg.h
===================================================================
--- net-2.6.20.orig/include/net/ip_mp_alg.h	2006-11-08 15:34:12.000000000 +0100
+++ net-2.6.20/include/net/ip_mp_alg.h	2006-11-08 16:12:32.000000000 +0100
@@ -88,9 +88,7 @@
 	return flp1->fl4_dst == flp2->fl4_dst &&
 		flp1->fl4_src == flp2->fl4_src &&
 		flp1->oif == flp2->oif &&
-#ifdef CONFIG_IP_ROUTE_FWMARK
-		flp1->fl4_fwmark == flp2->fl4_fwmark &&
-#endif
+		flp1->mark == flp2->mark &&
 		!((flp1->fl4_tos ^ flp2->fl4_tos) &
 		  (IPTOS_RT_MASK | RTO_ONLINK));
 }
Index: net-2.6.20/net/ipv4/fib_rules.c
===================================================================
--- net-2.6.20.orig/net/ipv4/fib_rules.c	2006-11-08 15:34:12.000000000 +0100
+++ net-2.6.20/net/ipv4/fib_rules.c	2006-11-08 16:12:32.000000000 +0100
@@ -44,10 +44,8 @@
 	__be32			srcmask;
 	__be32			dst;
 	__be32			dstmask;
-#ifdef CONFIG_IP_ROUTE_FWMARK
 	u32			fwmark;
 	u32			fwmask;
-#endif
 #ifdef CONFIG_NET_CLS_ROUTE
 	u32			tclassid;
 #endif
@@ -160,10 +158,8 @@
 	if (r->tos && (r->tos != fl->fl4_tos))
 		return 0;
 
-#ifdef CONFIG_IP_ROUTE_FWMARK
-	if ((r->fwmark ^ fl->fl4_fwmark) & r->fwmask)
+	if ((r->fwmark ^ fl->mark) & r->fwmask)
 		return 0;
-#endif
 
 	return 1;
 }
@@ -220,7 +216,6 @@
 	if (tb[FRA_DST])
 		rule4->dst = nla_get_be32(tb[FRA_DST]);
 
-#ifdef CONFIG_IP_ROUTE_FWMARK
 	if (tb[FRA_FWMARK]) {
 		rule4->fwmark = nla_get_u32(tb[FRA_FWMARK]);
 		if (rule4->fwmark)
@@ -232,7 +227,6 @@
 
 	if (tb[FRA_FWMASK])
 		rule4->fwmask = nla_get_u32(tb[FRA_FWMASK]);
-#endif
 
 #ifdef CONFIG_NET_CLS_ROUTE
 	if (tb[FRA_FLOW])
@@ -264,13 +258,11 @@
 	if (frh->tos && (rule4->tos != frh->tos))
 		return 0;
 
-#ifdef CONFIG_IP_ROUTE_FWMARK
 	if (tb[FRA_FWMARK] && (rule4->fwmark != nla_get_u32(tb[FRA_FWMARK])))
 		return 0;
 
 	if (tb[FRA_FWMASK] && (rule4->fwmask != nla_get_u32(tb[FRA_FWMASK])))
 		return 0;
-#endif
 
 #ifdef CONFIG_NET_CLS_ROUTE
 	if (tb[FRA_FLOW] && (rule4->tclassid != nla_get_u32(tb[FRA_FLOW])))
@@ -296,13 +288,11 @@
 	frh->src_len = rule4->src_len;
 	frh->tos = rule4->tos;
 
-#ifdef CONFIG_IP_ROUTE_FWMARK
 	if (rule4->fwmark)
 		NLA_PUT_U32(skb, FRA_FWMARK, rule4->fwmark);
 
 	if (rule4->fwmask || rule4->fwmark)
 		NLA_PUT_U32(skb, FRA_FWMASK, rule4->fwmask);
-#endif
 
 	if (rule4->dst_len)
 		NLA_PUT_BE32(skb, FRA_DST, rule4->dst);
Index: net-2.6.20/net/ipv4/Kconfig
===================================================================
--- net-2.6.20.orig/net/ipv4/Kconfig	2006-11-08 15:34:13.000000000 +0100
+++ net-2.6.20/net/ipv4/Kconfig	2006-11-08 16:12:32.000000000 +0100
@@ -104,13 +104,6 @@
 
 	  If unsure, say N.
 
-config IP_ROUTE_FWMARK
-	bool "IP: use netfilter MARK value as routing key"
-	depends on IP_MULTIPLE_TABLES && NETFILTER
-	help
-	  If you say Y here, you will be able to specify different routes for
-	  packets with different mark values (see iptables(8), MARK target).
-
 config IP_ROUTE_MULTIPATH
 	bool "IP: equal cost multipath"
 	depends on IP_ADVANCED_ROUTER
Index: net-2.6.20/net/ipv4/netfilter/iptable_mangle.c
===================================================================
--- net-2.6.20.orig/net/ipv4/netfilter/iptable_mangle.c	2006-11-08 16:12:30.000000000 +0100
+++ net-2.6.20/net/ipv4/netfilter/iptable_mangle.c	2006-11-08 16:12:32.000000000 +0100
@@ -153,9 +153,7 @@
 	if (ret != NF_DROP && ret != NF_STOLEN && ret != NF_QUEUE
 	    && ((*pskb)->nh.iph->saddr != saddr
 		|| (*pskb)->nh.iph->daddr != daddr
-#ifdef CONFIG_IP_ROUTE_FWMARK
 		|| (*pskb)->mark != mark
-#endif
 		|| (*pskb)->nh.iph->tos != tos))
 		if (ip_route_me_harder(pskb, RTN_UNSPEC))
 			ret = NF_DROP;
Index: net-2.6.20/net/decnet/Kconfig
===================================================================
--- net-2.6.20.orig/net/decnet/Kconfig	2006-11-08 15:34:12.000000000 +0100
+++ net-2.6.20/net/decnet/Kconfig	2006-11-08 16:12:32.000000000 +0100
@@ -41,11 +41,3 @@
 
 	  See <file:Documentation/networking/decnet.txt> for more information.
 
-config DECNET_ROUTE_FWMARK
-	bool "DECnet: use FWMARK value as routing key (EXPERIMENTAL)"
-	depends on DECNET_ROUTER && NETFILTER
-	help
-	  If you say Y here, you will be able to specify different routes for
-	  packets with different FWMARK ("firewalling mark") values
-	  (see ipchains(8), "-m" argument).
-
Index: net-2.6.20/net/ipv6/Kconfig
===================================================================
--- net-2.6.20.orig/net/ipv6/Kconfig	2006-11-08 15:34:13.000000000 +0100
+++ net-2.6.20/net/ipv6/Kconfig	2006-11-08 16:12:32.000000000 +0100
@@ -196,10 +196,3 @@
 
 	  If unsure, say N.
 
-config IPV6_ROUTE_FWMARK
-	bool "IPv6: use netfilter MARK value as routing key"
-	depends on IPV6_MULTIPLE_TABLES && NETFILTER
-	---help---
-	  If you say Y here, you will be able to specify different routes for
-	  packets with different mark values (see iptables(8), MARK target).
-

--

