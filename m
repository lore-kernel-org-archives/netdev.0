From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 9/9][NETNS][IPV6] make icmpv6_time sysctl per namespace
Date: Fri, 04 Jan 2008 12:12:35 +0100
Message-ID: <20080104111452.437994451@localhost.localdomain>
References: <20080104111226.776105484@localhost.localdomain>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:19161 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751750AbYADLXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 06:23:22 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m04BNLLY151204
	for <netdev@vger.kernel.org>; Fri, 4 Jan 2008 11:23:21 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m04BNKmg4956244
	for <netdev@vger.kernel.org>; Fri, 4 Jan 2008 11:23:20 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m04BNE2O000747
	for <netdev@vger.kernel.org>; Fri, 4 Jan 2008 11:23:14 GMT
Content-Disposition: inline; filename=sysctl/move-sysctl-icmp-to-netns.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves the icmpv6_time sysctl to the network namespace
structure. A small initialization helper function has been added.

Because the ipv6 protocol is not yet per namespace, the variable is
accessed relatively to the initial network namespace.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/net/netns/ipv6.h   |    1 +
 net/ipv6/icmp.c            |    8 ++++----
 net/ipv6/sysctl_net_ipv6.c |    1 +
 3 files changed, 6 insertions(+), 4 deletions(-)

Index: net-2.6.25/include/net/netns/ipv6.h
===================================================================
--- net-2.6.25.orig/include/net/netns/ipv6.h
+++ net-2.6.25/include/net/netns/ipv6.h
@@ -21,6 +21,7 @@ struct netns_sysctl_ipv6 {
   	int ip6_rt_gc_elasticity;
   	int ip6_rt_mtu_expires;
   	int ip6_rt_min_advmss;
+	int icmpv6_time;
 };
 
 struct netns_ipv6 {
Index: net-2.6.25/net/ipv6/icmp.c
===================================================================
--- net-2.6.25.orig/net/ipv6/icmp.c
+++ net-2.6.25/net/ipv6/icmp.c
@@ -154,8 +154,6 @@ static int is_ineligible(struct sk_buff 
 	return 0;
 }
 
-static int sysctl_icmpv6_time __read_mostly = 1*HZ;
-
 /*
  * Check the ICMP output rate limit
  */
@@ -186,7 +184,7 @@ static inline int icmpv6_xrlim_allow(str
 		res = 1;
 	} else {
 		struct rt6_info *rt = (struct rt6_info *)dst;
-		int tmo = sysctl_icmpv6_time;
+		int tmo = init_net.ipv6.sysctl.icmpv6_time;
 
 		/* Give more bandwidth to wider prefixes. */
 		if (rt->rt6i_dst.plen < 128)
@@ -913,7 +911,7 @@ ctl_table ipv6_icmp_table_template[] = {
 	{
 		.ctl_name	= NET_IPV6_ICMP_RATELIMIT,
 		.procname	= "ratelimit",
-		.data		= &sysctl_icmpv6_time,
+		.data		= &init_net.ipv6.sysctl.icmpv6_time,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec
@@ -925,6 +923,8 @@ struct ctl_table *ipv6_icmp_sysctl_init(
 {
 	struct ctl_table *table;
 
+	net->ipv6.sysctl.icmpv6_time = 1*HZ;
+
    	table = kmemdup(ipv6_icmp_table_template,
 			sizeof(ipv6_icmp_table_template),
 			GFP_KERNEL);
Index: net-2.6.25/net/ipv6/sysctl_net_ipv6.c
===================================================================
--- net-2.6.25.orig/net/ipv6/sysctl_net_ipv6.c
+++ net-2.6.25/net/ipv6/sysctl_net_ipv6.c
@@ -123,6 +123,7 @@ static int ipv6_sysctl_net_init(struct n
    	ipv6_route_table[8].data = &net->ipv6.sysctl.ip6_rt_min_advmss;
    	ipv6_table[0].child = ipv6_route_table;
 
+  	ipv6_icmp_table[0].data = &net->ipv6.sysctl.icmpv6_time;
    	ipv6_table[1].child = ipv6_icmp_table;
 
   	ipv6_table[2].data = &net->ipv6.sysctl.bindv6only;

-- 
