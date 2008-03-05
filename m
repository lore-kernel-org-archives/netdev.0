From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 6/9][NETNS][IPV6] route6 - add netns parameter to ip6_route_output
Date: Wed, 05 Mar 2008 18:56:55 +0100
Message-ID: <20080305180202.072396975@mai.toulouse-stg.fr.ibm.com>
References: <20080305175649.348451657@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.uk.ibm.com ([195.212.29.141]:38725 "EHLO
	mtagate8.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753572AbYCESCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 13:02:12 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate8.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m25I2BLD209982
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 18:02:11 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m25I2As41925348
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 18:02:11 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m25I2Ath019855
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 18:02:10 GMT
Content-Disposition: inline; filename=ip6_route_output.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add an netns parameter to ip6_route_output. That will allow to access
to the right routing table for outgoing traffic.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 include/net/ip6_route.h          |    3 ++-
 net/ipv6/icmp.c                  |    2 +-
 net/ipv6/ip6_output.c            |    4 ++--
 net/ipv6/ip6_tunnel.c            |    2 +-
 net/ipv6/ndisc.c                 |    2 +-
 net/ipv6/netfilter.c             |    4 ++--
 net/ipv6/netfilter/ip6t_REJECT.c |    2 +-
 net/ipv6/route.c                 |    7 ++++---
 net/ipv6/sit.c                   |    2 +-
 net/ipv6/xfrm6_policy.c          |    2 +-
 net/sctp/ipv6.c                  |    2 +-
 11 files changed, 17 insertions(+), 15 deletions(-)

Index: net-2.6.26/include/net/ip6_route.h
===================================================================
--- net-2.6.26.orig/include/net/ip6_route.h
+++ net-2.6.26/include/net/ip6_route.h
@@ -43,7 +43,8 @@ extern struct rt6_info	*ip6_blk_hole_ent
 
 extern void			ip6_route_input(struct sk_buff *skb);
 
-extern struct dst_entry *	ip6_route_output(struct sock *sk,
+extern struct dst_entry *	ip6_route_output(struct net *net,
+						 struct sock *sk,
 						 struct flowi *fl);
 
 extern int			ip6_route_init(void);
Index: net-2.6.26/net/ipv6/icmp.c
===================================================================
--- net-2.6.26.orig/net/ipv6/icmp.c
+++ net-2.6.26/net/ipv6/icmp.c
@@ -178,7 +178,7 @@ static inline int icmpv6_xrlim_allow(str
 	 * XXX: perhaps the expire for routing entries cloned by
 	 * this lookup should be more aggressive (not longer than timeout).
 	 */
-	dst = ip6_route_output(sk, fl);
+	dst = ip6_route_output(&init_net, sk, fl);
 	if (dst->error) {
 		IP6_INC_STATS(ip6_dst_idev(dst),
 			      IPSTATS_MIB_OUTNOROUTES);
Index: net-2.6.26/net/ipv6/ip6_output.c
===================================================================
--- net-2.6.26.orig/net/ipv6/ip6_output.c
+++ net-2.6.26/net/ipv6/ip6_output.c
@@ -913,7 +913,7 @@ static int ip6_dst_lookup_tail(struct so
 	int err;
 
 	if (*dst == NULL)
-		*dst = ip6_route_output(sk, fl);
+		*dst = ip6_route_output(&init_net, sk, fl);
 
 	if ((err = (*dst)->error))
 		goto out_err_release;
@@ -954,7 +954,7 @@ static int ip6_dst_lookup_tail(struct so
 				dst_release(*dst);
 				memcpy(&fl_gw, fl, sizeof(struct flowi));
 				memset(&fl_gw.fl6_dst, 0, sizeof(struct in6_addr));
-				*dst = ip6_route_output(sk, &fl_gw);
+				*dst = ip6_route_output(&init_net, sk, &fl_gw);
 				if ((err = (*dst)->error))
 					goto out_err_release;
 			}
Index: net-2.6.26/net/ipv6/ip6_tunnel.c
===================================================================
--- net-2.6.26.orig/net/ipv6/ip6_tunnel.c
+++ net-2.6.26/net/ipv6/ip6_tunnel.c
@@ -847,7 +847,7 @@ static int ip6_tnl_xmit2(struct sk_buff 
 	if ((dst = ip6_tnl_dst_check(t)) != NULL)
 		dst_hold(dst);
 	else {
-		dst = ip6_route_output(NULL, fl);
+		dst = ip6_route_output(&init_net, NULL, fl);
 
 		if (dst->error || xfrm_lookup(&dst, fl, NULL, 0) < 0)
 			goto tx_err_link_failure;
Index: net-2.6.26/net/ipv6/ndisc.c
===================================================================
--- net-2.6.26.orig/net/ipv6/ndisc.c
+++ net-2.6.26/net/ipv6/ndisc.c
@@ -1427,7 +1427,7 @@ void ndisc_send_redirect(struct sk_buff 
 	icmpv6_flow_init(ndisc_socket->sk, &fl, NDISC_REDIRECT,
 			 &saddr_buf, &ipv6_hdr(skb)->saddr, dev->ifindex);
 
-	dst = ip6_route_output(NULL, &fl);
+	dst = ip6_route_output(&init_net, NULL, &fl);
 	if (dst == NULL)
 		return;
 
Index: net-2.6.26/net/ipv6/netfilter.c
===================================================================
--- net-2.6.26.orig/net/ipv6/netfilter.c
+++ net-2.6.26/net/ipv6/netfilter.c
@@ -23,7 +23,7 @@ int ip6_route_me_harder(struct sk_buff *
 		    .saddr = iph->saddr, } },
 	};
 
-	dst = ip6_route_output(skb->sk, &fl);
+	dst = ip6_route_output(&init_net, skb->sk, &fl);
 
 #ifdef CONFIG_XFRM
 	if (!(IP6CB(skb)->flags & IP6SKB_XFRM_TRANSFORMED) &&
@@ -86,7 +86,7 @@ static int nf_ip6_reroute(struct sk_buff
 
 static int nf_ip6_route(struct dst_entry **dst, struct flowi *fl)
 {
-	*dst = ip6_route_output(NULL, fl);
+	*dst = ip6_route_output(&init_net, NULL, fl);
 	return (*dst)->error;
 }
 
Index: net-2.6.26/net/ipv6/netfilter/ip6t_REJECT.c
===================================================================
--- net-2.6.26.orig/net/ipv6/netfilter/ip6t_REJECT.c
+++ net-2.6.26/net/ipv6/netfilter/ip6t_REJECT.c
@@ -93,7 +93,7 @@ static void send_reset(struct sk_buff *o
 	fl.fl_ip_sport = otcph.dest;
 	fl.fl_ip_dport = otcph.source;
 	security_skb_classify_flow(oldskb, &fl);
-	dst = ip6_route_output(NULL, &fl);
+	dst = ip6_route_output(&init_net, NULL, &fl);
 	if (dst == NULL)
 		return;
 	if (dst->error || xfrm_lookup(&dst, &fl, NULL, 0))
Index: net-2.6.26/net/ipv6/route.c
===================================================================
--- net-2.6.26.orig/net/ipv6/route.c
+++ net-2.6.26/net/ipv6/route.c
@@ -772,7 +772,8 @@ static struct rt6_info *ip6_pol_route_ou
 	return ip6_pol_route(net, table, fl->oif, fl, flags);
 }
 
-struct dst_entry * ip6_route_output(struct sock *sk, struct flowi *fl)
+struct dst_entry * ip6_route_output(struct net *net, struct sock *sk,
+				    struct flowi *fl)
 {
 	int flags = 0;
 
@@ -782,7 +783,7 @@ struct dst_entry * ip6_route_output(stru
 	if (!ipv6_addr_any(&fl->fl6_src))
 		flags |= RT6_LOOKUP_F_HAS_SADDR;
 
-	return fib6_rule_lookup(&init_net, fl, flags, ip6_pol_route_output);
+	return fib6_rule_lookup(net, fl, flags, ip6_pol_route_output);
 }
 
 EXPORT_SYMBOL(ip6_route_output);
@@ -2260,7 +2261,7 @@ static int inet6_rtm_getroute(struct sk_
 	skb_reset_mac_header(skb);
 	skb_reserve(skb, MAX_HEADER + sizeof(struct ipv6hdr));
 
-	rt = (struct rt6_info*) ip6_route_output(NULL, &fl);
+	rt = (struct rt6_info*) ip6_route_output(&init_net, NULL, &fl);
 	skb->dst = &rt->u.dst;
 
 	err = rt6_fill_node(skb, rt, &fl.fl6_dst, &fl.fl6_src, iif,
Index: net-2.6.26/net/ipv6/sit.c
===================================================================
--- net-2.6.26.orig/net/ipv6/sit.c
+++ net-2.6.26/net/ipv6/sit.c
@@ -393,7 +393,7 @@ isatap_srcok(struct sk_buff *skb, struct
 	fl.oif = dev->ifindex;
 	security_skb_classify_flow(skb, &fl);
 
-	dst = ip6_route_output(NULL, &fl);
+	dst = ip6_route_output(&init_net, NULL, &fl);
 	if (!dst->error && (dst->dev == dev) && (neigh = dst->neighbour)) {
 
 		addr6 = (struct in6_addr*)&neigh->primary_key;
Index: net-2.6.26/net/ipv6/xfrm6_policy.c
===================================================================
--- net-2.6.26.orig/net/ipv6/xfrm6_policy.c
+++ net-2.6.26/net/ipv6/xfrm6_policy.c
@@ -38,7 +38,7 @@ static struct dst_entry *xfrm6_dst_looku
 	if (saddr)
 		memcpy(&fl.fl6_src, saddr, sizeof(fl.fl6_src));
 
-	dst = ip6_route_output(NULL, &fl);
+	dst = ip6_route_output(&init_net, NULL, &fl);
 
 	err = dst->error;
 	if (dst->error) {
Index: net-2.6.26/net/sctp/ipv6.c
===================================================================
--- net-2.6.26.orig/net/sctp/ipv6.c
+++ net-2.6.26/net/sctp/ipv6.c
@@ -257,7 +257,7 @@ static struct dst_entry *sctp_v6_get_dst
 			NIP6(fl.fl6_src));
 	}
 
-	dst = ip6_route_output(NULL, &fl);
+	dst = ip6_route_output(&init_net, NULL, &fl);
 	if (!dst->error) {
 		struct rt6_info *rt;
 		rt = (struct rt6_info *)dst;

-- 
