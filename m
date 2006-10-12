From: Thomas Graf <tgraf@suug.ch>
Subject: [IPv6] rules: Use RT6_LOOKUP_F_HAS_SADDR and fix source based selectors
Date: Thu, 12 Oct 2006 11:41:24 +0200
Message-ID: <20061012094124.GH12964@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kim.nordlund@nokia.com,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:45805 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1422759AbWJLJlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2006 05:41:04 -0400
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes rt6_lookup() to provide the source address in the flow
and sets RT6_LOOKUP_F_HAS_SADDR whenever it is present in
the flow.

Avoids unnecessary prefix comparisons by checking for a prefix
length first.

Fixes the rule logic to not match packets if a source selector
has been specified but no source address is available.

Thanks to Kim Nordlund <kim.nordlund@nokia.com> for working
on this patch with me.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6/net/ipv6/fib6_rules.c
===================================================================
--- net-2.6.orig/net/ipv6/fib6_rules.c	2006-10-11 22:29:50.000000000 +0200
+++ net-2.6/net/ipv6/fib6_rules.c	2006-10-12 11:01:00.000000000 +0200
@@ -117,12 +117,15 @@
 {
 	struct fib6_rule *r = (struct fib6_rule *) rule;
 
-	if (!ipv6_prefix_equal(&fl->fl6_dst, &r->dst.addr, r->dst.plen))
+	if (r->dst.plen &&
+	    !ipv6_prefix_equal(&fl->fl6_dst, &r->dst.addr, r->dst.plen))
 		return 0;
 
-	if ((flags & RT6_LOOKUP_F_HAS_SADDR) &&
-	    !ipv6_prefix_equal(&fl->fl6_src, &r->src.addr, r->src.plen))
-		return 0;
+	if (r->src.plen) {
+		if (!(flags & RT6_LOOKUP_F_HAS_SADDR) ||
+		    !ipv6_prefix_equal(&fl->fl6_src, &r->src.addr, r->src.plen))
+			return 0;
+	}
 
 	if (r->tclass && r->tclass != ((ntohl(fl->fl6_flowlabel) >> 20) & 0xff))
 		return 0;
Index: net-2.6/net/ipv6/route.c
===================================================================
--- net-2.6.orig/net/ipv6/route.c	2006-10-11 22:29:50.000000000 +0200
+++ net-2.6/net/ipv6/route.c	2006-10-12 10:59:13.000000000 +0200
@@ -529,13 +529,17 @@
 		.nl_u = {
 			.ip6_u = {
 				.daddr = *daddr,
-				/* TODO: saddr */
 			},
 		},
 	};
 	struct dst_entry *dst;
 	int flags = strict ? RT6_LOOKUP_F_IFACE : 0;
 
+	if (saddr) {
+		memcpy(&fl.fl6_src, saddr, sizeof(*saddr));
+		flags |= RT6_LOOKUP_F_HAS_SADDR;
+	}
+
 	dst = fib6_rule_lookup(&fl, flags, ip6_pol_route_lookup);
 	if (dst->error == 0)
 		return (struct rt6_info *) dst;
@@ -697,6 +701,7 @@
 void ip6_route_input(struct sk_buff *skb)
 {
 	struct ipv6hdr *iph = skb->nh.ipv6h;
+	int flags = RT6_LOOKUP_F_HAS_SADDR;
 	struct flowi fl = {
 		.iif = skb->dev->ifindex,
 		.nl_u = {
@@ -711,7 +716,9 @@
 		},
 		.proto = iph->nexthdr,
 	};
-	int flags = rt6_need_strict(&iph->daddr) ? RT6_LOOKUP_F_IFACE : 0;
+
+	if (rt6_need_strict(&iph->daddr))
+		flags |= RT6_LOOKUP_F_IFACE;
 
 	skb->dst = fib6_rule_lookup(&fl, flags, ip6_pol_route_input);
 }
@@ -794,6 +801,9 @@
 	if (rt6_need_strict(&fl->fl6_dst))
 		flags |= RT6_LOOKUP_F_IFACE;
 
+	if (!ipv6_addr_any(&fl->fl6_src))
+		flags |= RT6_LOOKUP_F_HAS_SADDR;
+
 	return fib6_rule_lookup(fl, flags, ip6_pol_route_output);
 }
 
@@ -1345,6 +1355,7 @@
 					   struct in6_addr *gateway,
 					   struct net_device *dev)
 {
+	int flags = RT6_LOOKUP_F_HAS_SADDR;
 	struct ip6rd_flowi rdfl = {
 		.fl = {
 			.oif = dev->ifindex,
@@ -1357,7 +1368,9 @@
 		},
 		.gateway = *gateway,
 	};
-	int flags = rt6_need_strict(dest) ? RT6_LOOKUP_F_IFACE : 0;
+
+	if (rt6_need_strict(dest))
+		flags |= RT6_LOOKUP_F_IFACE;
 
 	return (struct rt6_info *)fib6_rule_lookup((struct flowi *)&rdfl, flags, __ip6_route_redirect);
 }
