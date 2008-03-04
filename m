From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 11/12][NETNS][IPV6] route6 - make garbage collection work with multiple network namespaces
Date: Tue, 04 Mar 2008 22:03:37 +0100
Message-ID: <20080304211041.890761515@mai.toulouse-stg.fr.ibm.com>
References: <20080304210326.169013927@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:23127 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755552AbYCDVNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 16:13:22 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate5.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m24LDIvc431208
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 21:13:18 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m24LDINA1720386
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 21:13:18 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m24LDIGR029899
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 21:13:18 GMT
Content-Disposition: inline; filename=route6-make-ip6_dst_gc-per-namespace.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the necessary changes to make IPv6 dst_entry garbage 
collection work with multiple network namespaces.

In ip6_dst_gc(), static local variables are now declared per-namespace.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/net/netns/ipv6.h |    2 ++
 net/ipv6/route.c         |   23 ++++++++++++-----------
 2 files changed, 14 insertions(+), 11 deletions(-)

Index: net-2.6.26/include/net/netns/ipv6.h
===================================================================
--- net-2.6.26.orig/include/net/netns/ipv6.h
+++ net-2.6.26/include/net/netns/ipv6.h
@@ -42,6 +42,8 @@ struct netns_ipv6 {
 	struct hlist_head       *fib_table_hash;
 	struct fib6_table       *fib6_main_tbl;
 	struct dst_ops		*ip6_dst_ops;
+	unsigned int		 ip6_rt_gc_expire;
+	unsigned long		 ip6_rt_last_gc;
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	struct rt6_info         *ip6_prohibit_entry;
 	struct rt6_info         *ip6_blk_hole_entry;
Index: net-2.6.26/net/ipv6/route.c
===================================================================
--- net-2.6.26.orig/net/ipv6/route.c
+++ net-2.6.26/net/ipv6/route.c
@@ -992,23 +992,22 @@ int icmp6_dst_gc(int *more)
 
 static int ip6_dst_gc(struct dst_ops *ops)
 {
-	static unsigned expire = 30*HZ;
-	static unsigned long last_gc;
+	struct net *net = ops->dst_net;
 	unsigned long now = jiffies;
 
-	if (time_after(last_gc + init_net.ipv6.sysctl.ip6_rt_gc_min_interval, now) &&
-	    atomic_read(&init_net.ipv6.ip6_dst_ops->entries) <= init_net.ipv6.sysctl.ip6_rt_max_size)
+	if (time_after(net->ipv6.ip6_rt_last_gc + net->ipv6.sysctl.ip6_rt_gc_min_interval, now) &&
+	    atomic_read(&net->ipv6.ip6_dst_ops->entries) <= net->ipv6.sysctl.ip6_rt_max_size)
 		goto out;
 
-	expire++;
-	fib6_run_gc(expire, &init_net);
-	last_gc = now;
-	if (atomic_read(&init_net.ipv6.ip6_dst_ops->entries) < init_net.ipv6.ip6_dst_ops->gc_thresh)
-		expire = init_net.ipv6.sysctl.ip6_rt_gc_timeout>>1;
+	net->ipv6.ip6_rt_gc_expire++;
+	fib6_run_gc(net->ipv6.ip6_rt_gc_expire, net);
+	net->ipv6.ip6_rt_last_gc = now;
+	if (atomic_read(&net->ipv6.ip6_dst_ops->entries) < net->ipv6.ip6_dst_ops->gc_thresh)
+		net->ipv6.ip6_rt_gc_expire = net->ipv6.sysctl.ip6_rt_gc_timeout>>1;
 
 out:
-	expire -= expire>>init_net.ipv6.sysctl.ip6_rt_gc_elasticity;
-	return (atomic_read(&init_net.ipv6.ip6_dst_ops->entries) > init_net.ipv6.sysctl.ip6_rt_max_size);
+	net->ipv6.ip6_rt_gc_expire -= net->ipv6.ip6_rt_gc_expire>>net->ipv6.sysctl.ip6_rt_gc_elasticity;
+	return (atomic_read(&net->ipv6.ip6_dst_ops->entries) > net->ipv6.sysctl.ip6_rt_max_size);
 }
 
 /* Clean host part of a prefix. Not necessary in radix tree,
@@ -2615,6 +2614,8 @@ static int ip6_route_net_init(struct net
 	proc_net_fops_create(net, "ipv6_route", 0, &ipv6_route_proc_fops);
 	proc_net_fops_create(net, "rt6_stats", S_IRUGO, &rt6_stats_seq_fops);
 #endif
+	net->ipv6.ip6_rt_gc_expire = 30*HZ;
+
 	ret = 0;
 out:
 	return ret;

-- 
