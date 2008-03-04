From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 02/12][NETNS][IPV6] route6 - Pass the network namespace parameter to rt6_lookup
Date: Tue, 04 Mar 2008 22:03:28 +0100
Message-ID: <20080304211007.874550410@mai.toulouse-stg.fr.ibm.com>
References: <20080304210326.169013927@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:59351 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753848AbYCDVMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 16:12:51 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id m24LCoNi468460
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 21:12:50 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m24LCo4J1921278
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 22:12:50 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m24LCnuM026663
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 22:12:50 +0100
Content-Disposition: inline; filename=route6-pass-network-namespace-to-rt6_lookup.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a network namespace parameter to rt6_lookup().

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 include/net/ip6_route.h |    3 ++-
 net/ipv6/addrconf.c     |    4 ++--
 net/ipv6/anycast.c      |    2 +-
 net/ipv6/ip6_tunnel.c   |    4 ++--
 net/ipv6/mcast.c        |    4 ++--
 net/ipv6/route.c        |   10 +++++-----
 net/ipv6/sit.c          |    4 ++--
 7 files changed, 16 insertions(+), 15 deletions(-)

Index: net-2.6.26/include/net/ip6_route.h
===================================================================
--- net-2.6.26.orig/include/net/ip6_route.h
+++ net-2.6.26/include/net/ip6_route.h
@@ -69,7 +69,8 @@ extern void			rt6_sndmsg(int type, struc
 					   int dstlen, int srclen,
 					   int metric, __u32 flags);
 
-extern struct rt6_info		*rt6_lookup(struct in6_addr *daddr,
+extern struct rt6_info		*rt6_lookup(struct net *net,
+					    struct in6_addr *daddr,
 					    struct in6_addr *saddr,
 					    int oif, int flags);
 
Index: net-2.6.26/net/ipv6/addrconf.c
===================================================================
--- net-2.6.26.orig/net/ipv6/addrconf.c
+++ net-2.6.26/net/ipv6/addrconf.c
@@ -753,7 +753,7 @@ static void ipv6_del_addr(struct inet6_i
 		struct rt6_info *rt;
 
 		ipv6_addr_prefix(&prefix, &ifp->addr, ifp->prefix_len);
-		rt = rt6_lookup(&prefix, NULL, ifp->idev->dev->ifindex, 1);
+		rt = rt6_lookup(&init_net, &prefix, NULL, ifp->idev->dev->ifindex, 1);
 
 		if (rt && ((rt->rt6i_flags & (RTF_GATEWAY | RTF_DEFAULT)) == 0)) {
 			if (onlink == 0) {
@@ -1700,7 +1700,7 @@ void addrconf_prefix_rcv(struct net_devi
 
 	if (pinfo->onlink) {
 		struct rt6_info *rt;
-		rt = rt6_lookup(&pinfo->prefix, NULL, dev->ifindex, 1);
+		rt = rt6_lookup(&init_net, &pinfo->prefix, NULL, dev->ifindex, 1);
 
 		if (rt && ((rt->rt6i_flags & (RTF_GATEWAY | RTF_DEFAULT)) == 0)) {
 			if (rt->rt6i_flags&RTF_EXPIRES) {
Index: net-2.6.26/net/ipv6/anycast.c
===================================================================
--- net-2.6.26.orig/net/ipv6/anycast.c
+++ net-2.6.26/net/ipv6/anycast.c
@@ -101,7 +101,7 @@ int ipv6_sock_ac_join(struct sock *sk, i
 	if (ifindex == 0) {
 		struct rt6_info *rt;
 
-		rt = rt6_lookup(addr, NULL, 0, 0);
+		rt = rt6_lookup(&init_net, addr, NULL, 0, 0);
 		if (rt) {
 			dev = rt->rt6i_dev;
 			dev_hold(dev);
Index: net-2.6.26/net/ipv6/ip6_tunnel.c
===================================================================
--- net-2.6.26.orig/net/ipv6/ip6_tunnel.c
+++ net-2.6.26/net/ipv6/ip6_tunnel.c
@@ -602,7 +602,7 @@ ip6ip6_err(struct sk_buff *skb, struct i
 		skb_reset_network_header(skb2);
 
 		/* Try to guess incoming interface */
-		rt = rt6_lookup(&ipv6_hdr(skb2)->saddr, NULL, 0, 0);
+		rt = rt6_lookup(&init_net, &ipv6_hdr(skb2)->saddr, NULL, 0, 0);
 
 		if (rt && rt->rt6i_dev)
 			skb2->dev = rt->rt6i_dev;
@@ -1112,7 +1112,7 @@ static void ip6_tnl_link_config(struct i
 		int strict = (ipv6_addr_type(&p->raddr) &
 			      (IPV6_ADDR_MULTICAST|IPV6_ADDR_LINKLOCAL));
 
-		struct rt6_info *rt = rt6_lookup(&p->raddr, &p->laddr,
+		struct rt6_info *rt = rt6_lookup(&init_net, &p->raddr, &p->laddr,
 						 p->link, strict);
 
 		if (rt == NULL)
Index: net-2.6.26/net/ipv6/mcast.c
===================================================================
--- net-2.6.26.orig/net/ipv6/mcast.c
+++ net-2.6.26/net/ipv6/mcast.c
@@ -208,7 +208,7 @@ int ipv6_sock_mc_join(struct sock *sk, i
 
 	if (ifindex == 0) {
 		struct rt6_info *rt;
-		rt = rt6_lookup(addr, NULL, 0, 0);
+		rt = rt6_lookup(&init_net, addr, NULL, 0, 0);
 		if (rt) {
 			dev = rt->rt6i_dev;
 			dev_hold(dev);
@@ -294,7 +294,7 @@ static struct inet6_dev *ip6_mc_find_dev
 	if (ifindex == 0) {
 		struct rt6_info *rt;
 
-		rt = rt6_lookup(group, NULL, 0, 0);
+		rt = rt6_lookup(&init_net, group, NULL, 0, 0);
 		if (rt) {
 			dev = rt->rt6i_dev;
 			dev_hold(dev);
Index: net-2.6.26/net/ipv6/route.c
===================================================================
--- net-2.6.26.orig/net/ipv6/route.c
+++ net-2.6.26/net/ipv6/route.c
@@ -553,8 +553,8 @@ out:
 
 }
 
-struct rt6_info *rt6_lookup(struct in6_addr *daddr, struct in6_addr *saddr,
-			    int oif, int strict)
+struct rt6_info *rt6_lookup(struct net *net, struct in6_addr *daddr,
+			    struct in6_addr *saddr, int oif, int strict)
 {
 	struct flowi fl = {
 		.oif = oif,
@@ -572,7 +572,7 @@ struct rt6_info *rt6_lookup(struct in6_a
 		flags |= RT6_LOOKUP_F_HAS_SADDR;
 	}
 
-	dst = fib6_rule_lookup(&init_net, &fl, flags, ip6_pol_route_lookup);
+	dst = fib6_rule_lookup(net, &fl, flags, ip6_pol_route_lookup);
 	if (dst->error == 0)
 		return (struct rt6_info *) dst;
 
@@ -1159,7 +1159,7 @@ int ip6_route_add(struct fib6_config *cf
 			if (!(gwa_type&IPV6_ADDR_UNICAST))
 				goto out;
 
-			grt = rt6_lookup(gw_addr, NULL, cfg->fc_ifindex, 1);
+			grt = rt6_lookup(&init_net, gw_addr, NULL, cfg->fc_ifindex, 1);
 
 			err = -EHOSTUNREACH;
 			if (grt == NULL)
@@ -1483,7 +1483,7 @@ void rt6_pmtu_discovery(struct in6_addr 
 	struct rt6_info *rt, *nrt;
 	int allfrag = 0;
 
-	rt = rt6_lookup(daddr, saddr, dev->ifindex, 0);
+	rt = rt6_lookup(dev->nd_net, daddr, saddr, dev->ifindex, 0);
 	if (rt == NULL)
 		return;
 
Index: net-2.6.26/net/ipv6/sit.c
===================================================================
--- net-2.6.26.orig/net/ipv6/sit.c
+++ net-2.6.26/net/ipv6/sit.c
@@ -339,11 +339,11 @@ out:
 	skb_reset_network_header(skb2);
 
 	/* Try to guess incoming interface */
-	rt6i = rt6_lookup(&iph6->saddr, NULL, NULL, 0);
+	rt6i = rt6_lookup(&init_net, &iph6->saddr, NULL, NULL, 0);
 	if (rt6i && rt6i->rt6i_dev) {
 		skb2->dev = rt6i->rt6i_dev;
 
-		rt6i = rt6_lookup(&iph6->daddr, &iph6->saddr, NULL, 0);
+		rt6i = rt6_lookup(&init_net, &iph6->daddr, &iph6->saddr, NULL, 0);
 
 		if (rt6i && rt6i->rt6i_dev && rt6i->rt6i_dev->type == ARPHRD_SIT) {
 			struct ip_tunnel *t = netdev_priv(rt6i->rt6i_dev);

-- 
