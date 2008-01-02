From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 9/9][NETNS][IPV6] make icmpv6_time sysctl per namespace
Date: Wed, 02 Jan 2008 13:25:57 +0100
Message-ID: <20080102122844.726687382@localhost.localdomain>
References: <20080102122548.629622062@localhost.localdomain>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:24817 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753387AbYABMgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 07:36:43 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id m02CaguG184402
	for <netdev@vger.kernel.org>; Wed, 2 Jan 2008 12:36:42 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m02CafTR2646174
	for <netdev@vger.kernel.org>; Wed, 2 Jan 2008 13:36:41 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m02CafMT015947
	for <netdev@vger.kernel.org>; Wed, 2 Jan 2008 13:36:41 +0100
Content-Disposition: inline; filename=move-sysctl-icmp-to-netns.patch
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
@@ -22,6 +22,7 @@ struct netns_sysctl_ipv6 {
  	int ip6_rt_gc_elasticity;
  	int ip6_rt_mtu_expires;
  	int ip6_rt_min_advmss;
+ 	int icmpv6_time;
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
@@ -124,6 +124,7 @@ static int ipv6_sysctl_net_init(struct n
    	ipv6_route_table[8].data = &net->ipv6.sysctl.ip6_rt_min_advmss;
    	ipv6_table[0].child = ipv6_route_table;
 
+  	ipv6_icmp_table[0].data = &net->ipv6.sysctl.icmpv6_time;
    	ipv6_table[1].child = ipv6_icmp_table;
 
   	ipv6_table[2].data = &net->ipv6.sysctl.bindv6only;

-- 
