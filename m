From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 04/12][NETNS][IPV6] route6 - Pass network namespace to rt6_add_route_info and rt6_get_route_info
Date: Tue, 04 Mar 2008 22:03:30 +0100
Message-ID: <20080304211018.732819926@mai.toulouse-stg.fr.ibm.com>
References: <20080304210326.169013927@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([195.212.29.135]:16175 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754043AbYCDVM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 16:12:57 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate2.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m24LCtHb060720
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 21:12:55 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m24LCtvo2113564
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 21:12:55 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m24LCtwc001082
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 21:12:55 GMT
Content-Disposition: inline; filename=route6-pass-network-namespace-to-rt6_x_route_info.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a network namespace parameter to rt6_add_route_info() and 
rt6_get_route_info to enable them to handle multiple network namespaces.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 net/ipv6/route.c |   25 +++++++++++++++++--------
 1 file changed, 17 insertions(+), 8 deletions(-)

Index: net-2.6.26/net/ipv6/route.c
===================================================================
--- net-2.6.26.orig/net/ipv6/route.c
+++ net-2.6.26/net/ipv6/route.c
@@ -88,10 +88,12 @@ static void		ip6_link_failure(struct sk_
 static void		ip6_rt_update_pmtu(struct dst_entry *dst, u32 mtu);
 
 #ifdef CONFIG_IPV6_ROUTE_INFO
-static struct rt6_info *rt6_add_route_info(struct in6_addr *prefix, int prefixlen,
+static struct rt6_info *rt6_add_route_info(struct net *net,
+					   struct in6_addr *prefix, int prefixlen,
 					   struct in6_addr *gwaddr, int ifindex,
 					   unsigned pref);
-static struct rt6_info *rt6_get_route_info(struct in6_addr *prefix, int prefixlen,
+static struct rt6_info *rt6_get_route_info(struct net *net,
+					   struct in6_addr *prefix, int prefixlen,
 					   struct in6_addr *gwaddr, int ifindex);
 #endif
 
@@ -442,6 +444,7 @@ static struct rt6_info *rt6_select(struc
 int rt6_route_rcv(struct net_device *dev, u8 *opt, int len,
 		  struct in6_addr *gwaddr)
 {
+	struct net *net = dev->nd_net;
 	struct route_info *rinfo = (struct route_info *) opt;
 	struct in6_addr prefix_buf, *prefix;
 	unsigned int pref;
@@ -489,7 +492,8 @@ int rt6_route_rcv(struct net_device *dev
 		prefix = &prefix_buf;
 	}
 
-	rt = rt6_get_route_info(prefix, rinfo->prefix_len, gwaddr, dev->ifindex);
+	rt = rt6_get_route_info(net, prefix, rinfo->prefix_len, gwaddr,
+				dev->ifindex);
 
 	if (rt && !lifetime) {
 		ip6_del_rt(rt);
@@ -497,7 +501,7 @@ int rt6_route_rcv(struct net_device *dev
 	}
 
 	if (!rt && lifetime)
-		rt = rt6_add_route_info(prefix, rinfo->prefix_len, gwaddr, dev->ifindex,
+		rt = rt6_add_route_info(net, prefix, rinfo->prefix_len, gwaddr, dev->ifindex,
 					pref);
 	else if (rt)
 		rt->rt6i_flags = RTF_ROUTEINFO |
@@ -1588,14 +1592,15 @@ static struct rt6_info * ip6_rt_copy(str
 }
 
 #ifdef CONFIG_IPV6_ROUTE_INFO
-static struct rt6_info *rt6_get_route_info(struct in6_addr *prefix, int prefixlen,
+static struct rt6_info *rt6_get_route_info(struct net *net,
+					   struct in6_addr *prefix, int prefixlen,
 					   struct in6_addr *gwaddr, int ifindex)
 {
 	struct fib6_node *fn;
 	struct rt6_info *rt = NULL;
 	struct fib6_table *table;
 
-	table = fib6_get_table(&init_net, RT6_TABLE_INFO);
+	table = fib6_get_table(net, RT6_TABLE_INFO);
 	if (table == NULL)
 		return NULL;
 
@@ -1619,7 +1624,8 @@ out:
 	return rt;
 }
 
-static struct rt6_info *rt6_add_route_info(struct in6_addr *prefix, int prefixlen,
+static struct rt6_info *rt6_add_route_info(struct net *net,
+					   struct in6_addr *prefix, int prefixlen,
 					   struct in6_addr *gwaddr, int ifindex,
 					   unsigned pref)
 {
@@ -1630,6 +1636,9 @@ static struct rt6_info *rt6_add_route_in
 		.fc_dst_len	= prefixlen,
 		.fc_flags	= RTF_GATEWAY | RTF_ADDRCONF | RTF_ROUTEINFO |
 				  RTF_UP | RTF_PREF(pref),
+		.fc_nlinfo.pid = 0,
+		.fc_nlinfo.nlh = NULL,
+		.fc_nlinfo.nl_net = net,
 	};
 
 	ipv6_addr_copy(&cfg.fc_dst, prefix);
@@ -1641,7 +1650,7 @@ static struct rt6_info *rt6_add_route_in
 
 	ip6_route_add(&cfg);
 
-	return rt6_get_route_info(prefix, prefixlen, gwaddr, ifindex);
+	return rt6_get_route_info(net, prefix, prefixlen, gwaddr, ifindex);
 }
 #endif
 

-- 
