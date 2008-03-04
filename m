From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 09/12][NETNS][IPV6] route6 - dynamically allocate ip6_dst_ops
Date: Tue, 04 Mar 2008 22:03:35 +0100
Message-ID: <20080304211031.696107983@mai.toulouse-stg.fr.ibm.com>
References: <20080304210326.169013927@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:4953 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754291AbYCDVNM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 16:13:12 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m24LD95O048000
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 21:13:09 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m24LD9OM1720376
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 21:13:09 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m24LD8Lu001232
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 21:13:08 GMT
Content-Disposition: inline; filename=route6-alloc-ip6_dst_ops-dynamically.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip6_dst_ops is dynamically allocated in init and exit functions.
That provides the ability to do multiple instanciations of this structure.

This will be needed for network namespaces, indeed dst_ops stores 
data that are required to be per namespace: entries and gc_thresh.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/ipv6/route.c |   47 +++++++++++++++++++++++++++++------------------
 1 file changed, 29 insertions(+), 18 deletions(-)

Index: net-2.6.26/net/ipv6/route.c
===================================================================
--- net-2.6.26.orig/net/ipv6/route.c
+++ net-2.6.26/net/ipv6/route.c
@@ -97,7 +97,7 @@ static struct rt6_info *rt6_get_route_in
 					   struct in6_addr *gwaddr, int ifindex);
 #endif
 
-static struct dst_ops ip6_dst_ops = {
+static struct dst_ops ip6_dst_ops_template = {
 	.family			=	AF_INET6,
 	.protocol		=	__constant_htons(ETH_P_IPV6),
 	.gc			=	ip6_dst_gc,
@@ -113,6 +113,8 @@ static struct dst_ops ip6_dst_ops = {
 	.entries		=	ATOMIC_INIT(0),
 };
 
+static struct dst_ops *ip6_dst_ops;
+
 static void ip6_rt_blackhole_update_pmtu(struct dst_entry *dst, u32 mtu)
 {
 }
@@ -137,7 +139,6 @@ static struct rt6_info ip6_null_entry_te
 			.metrics	= { [RTAX_HOPLIMIT - 1] = 255, },
 			.input		= ip6_pkt_discard,
 			.output		= ip6_pkt_discard_out,
-			.ops		= &ip6_dst_ops,
 		}
 	},
 	.rt6i_flags	= (RTF_REJECT | RTF_NONEXTHOP),
@@ -160,7 +161,6 @@ struct rt6_info ip6_prohibit_entry_templ
 			.metrics	= { [RTAX_HOPLIMIT - 1] = 255, },
 			.input		= ip6_pkt_prohibit,
 			.output		= ip6_pkt_prohibit_out,
-			.ops		= &ip6_dst_ops,
 		}
 	},
 	.rt6i_flags	= (RTF_REJECT | RTF_NONEXTHOP),
@@ -178,7 +178,6 @@ static struct rt6_info ip6_blk_hole_entr
 			.metrics	= { [RTAX_HOPLIMIT - 1] = 255, },
 			.input		= dst_discard,
 			.output		= dst_discard,
-			.ops		= &ip6_dst_ops,
 		}
 	},
 	.rt6i_flags	= (RTF_REJECT | RTF_NONEXTHOP),
@@ -191,7 +190,7 @@ static struct rt6_info ip6_blk_hole_entr
 /* allocate dst with ip6_dst_ops */
 static __inline__ struct rt6_info *ip6_dst_alloc(void)
 {
-	return (struct rt6_info *)dst_alloc(&ip6_dst_ops);
+	return (struct rt6_info *)dst_alloc(ip6_dst_ops);
 }
 
 static void ip6_dst_destroy(struct dst_entry *dst)
@@ -1000,18 +999,18 @@ static int ip6_dst_gc(struct dst_ops *op
 	unsigned long now = jiffies;
 
 	if (time_after(last_gc + init_net.ipv6.sysctl.ip6_rt_gc_min_interval, now) &&
-	    atomic_read(&ip6_dst_ops.entries) <= init_net.ipv6.sysctl.ip6_rt_max_size)
+	    atomic_read(&ip6_dst_ops->entries) <= init_net.ipv6.sysctl.ip6_rt_max_size)
 		goto out;
 
 	expire++;
 	fib6_run_gc(expire, &init_net);
 	last_gc = now;
-	if (atomic_read(&ip6_dst_ops.entries) < ip6_dst_ops.gc_thresh)
+	if (atomic_read(&ip6_dst_ops->entries) < ip6_dst_ops->gc_thresh)
 		expire = init_net.ipv6.sysctl.ip6_rt_gc_timeout>>1;
 
 out:
 	expire -= expire>>init_net.ipv6.sysctl.ip6_rt_gc_elasticity;
-	return (atomic_read(&ip6_dst_ops.entries) > init_net.ipv6.sysctl.ip6_rt_max_size);
+	return (atomic_read(&ip6_dst_ops->entries) > init_net.ipv6.sysctl.ip6_rt_max_size);
 }
 
 /* Clean host part of a prefix. Not necessary in radix tree,
@@ -2408,7 +2407,7 @@ static int rt6_stats_seq_show(struct seq
 		   net->ipv6.rt6_stats->fib_rt_alloc,
 		   net->ipv6.rt6_stats->fib_rt_entries,
 		   net->ipv6.rt6_stats->fib_rt_cache,
-		   atomic_read(&ip6_dst_ops.entries),
+		   atomic_read(&ip6_dst_ops->entries),
 		   net->ipv6.rt6_stats->fib_discarded_routes);
 
 	return 0;
@@ -2464,7 +2463,7 @@ ctl_table ipv6_route_table_template[] = 
 	{
 		.ctl_name	=	NET_IPV6_ROUTE_GC_THRESH,
 		.procname	=	"gc_thresh",
-		.data		=	&ip6_dst_ops.gc_thresh,
+		.data		=	&ip6_dst_ops_template.gc_thresh,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
 		.proc_handler	=	&proc_dointvec,
@@ -2553,8 +2552,7 @@ struct ctl_table *ipv6_route_sysctl_init
 
 	if (table) {
 		table[0].data = &net->ipv6.sysctl.flush_delay;
-		/* table[1].data will be handled when we have
-		   routes per namespace */
+		table[1].data = &ip6_dst_ops_template.gc_thresh;
 		table[2].data = &net->ipv6.sysctl.ip6_rt_max_size;
 		table[3].data = &net->ipv6.sysctl.ip6_rt_gc_min_interval;
 		table[4].data = &net->ipv6.sysctl.ip6_rt_gc_timeout;
@@ -2580,6 +2578,7 @@ static int ip6_route_net_init(struct net
 		goto out;
 	net->ipv6.ip6_null_entry->u.dst.path =
 		(struct dst_entry *)net->ipv6.ip6_null_entry;
+	net->ipv6.ip6_null_entry->u.dst.ops = ip6_dst_ops;
 
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	net->ipv6.ip6_prohibit_entry = kmemdup(&ip6_prohibit_entry_template,
@@ -2591,6 +2590,7 @@ static int ip6_route_net_init(struct net
 	}
 	net->ipv6.ip6_prohibit_entry->u.dst.path =
 		(struct dst_entry *)net->ipv6.ip6_prohibit_entry;
+	net->ipv6.ip6_prohibit_entry->u.dst.ops = ip6_dst_ops;
 
 	net->ipv6.ip6_blk_hole_entry = kmemdup(&ip6_blk_hole_entry_template,
 					       sizeof(*net->ipv6.ip6_blk_hole_entry),
@@ -2602,6 +2602,7 @@ static int ip6_route_net_init(struct net
 	}
 	net->ipv6.ip6_blk_hole_entry->u.dst.path =
 		(struct dst_entry *)net->ipv6.ip6_blk_hole_entry;
+	net->ipv6.ip6_blk_hole_entry->u.dst.ops = ip6_dst_ops;
 #endif
 
 #ifdef CONFIG_PROC_FS
@@ -2640,13 +2641,20 @@ int __init ip6_route_init(void)
 {
 	int ret;
 
-	ip6_dst_ops.kmem_cachep =
+	ip6_dst_ops = kmemdup(&ip6_dst_ops_template,
+			      sizeof(*ip6_dst_ops), GFP_KERNEL);
+	if (!ip6_dst_ops)
+		return -ENOMEM;
+
+	ret = -ENOMEM;
+	ip6_dst_ops_template.kmem_cachep =
 		kmem_cache_create("ip6_dst_cache", sizeof(struct rt6_info), 0,
 				  SLAB_HWCACHE_ALIGN, NULL);
-	if (!ip6_dst_ops.kmem_cachep)
-		return -ENOMEM;
+	if (!ip6_dst_ops_template.kmem_cachep)
+		goto out_ip6_dst_ops;
 
-	ip6_dst_blackhole_ops.kmem_cachep = ip6_dst_ops.kmem_cachep;
+	ip6_dst_ops->kmem_cachep = ip6_dst_ops_template.kmem_cachep;
+	ip6_dst_blackhole_ops.kmem_cachep = ip6_dst_ops_template.kmem_cachep;
 
 	ret = register_pernet_subsys(&ip6_route_net_ops);
 	if (ret)
@@ -2697,7 +2705,9 @@ out_fib6_init:
 out_register_subsys:
 	unregister_pernet_subsys(&ip6_route_net_ops);
 out_kmem_cache:
-	kmem_cache_destroy(ip6_dst_ops.kmem_cachep);
+	kmem_cache_destroy(ip6_dst_ops->kmem_cachep);
+out_ip6_dst_ops:
+	kfree(ip6_dst_ops);
 	goto out;
 }
 
@@ -2708,5 +2718,6 @@ void ip6_route_cleanup(void)
 	xfrm6_fini();
 	fib6_gc_cleanup();
 	unregister_pernet_subsys(&ip6_route_net_ops);
-	kmem_cache_destroy(ip6_dst_ops.kmem_cachep);
+	kmem_cache_destroy(ip6_dst_ops->kmem_cachep);
+	kfree(ip6_dst_ops);
 }

-- 
