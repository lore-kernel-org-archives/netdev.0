From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 10/12][NETNS][IPV6] route6 - move ip6_dst_ops inside the network namespace
Date: Tue, 04 Mar 2008 22:03:36 +0100
Message-ID: <20080304211034.368890169@mai.toulouse-stg.fr.ibm.com>
References: <20080304210326.169013927@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:36281 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755248AbYCDVNS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 16:13:18 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id m24LDG1L090420
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 21:13:16 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m24LDGxV2031682
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 22:13:16 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m24LDFPn015085
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 21:13:16 GMT
Content-Disposition: inline; filename=route6-ip6_dst_ops-per-namespace.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ip6_dst_ops is moved inside the network namespace structure. 
All references to this structure are now relative to the initial network 
namespace.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/net/netns/ipv6.h |    1 
 net/ipv6/route.c         |   62 +++++++++++++++++++++++------------------------
 2 files changed, 32 insertions(+), 31 deletions(-)

Index: net-2.6.26/include/net/netns/ipv6.h
===================================================================
--- net-2.6.26.orig/include/net/netns/ipv6.h
+++ net-2.6.26/include/net/netns/ipv6.h
@@ -41,6 +41,7 @@ struct netns_ipv6 {
 	struct timer_list       *ip6_fib_timer;
 	struct hlist_head       *fib_table_hash;
 	struct fib6_table       *fib6_main_tbl;
+	struct dst_ops		*ip6_dst_ops;
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	struct rt6_info         *ip6_prohibit_entry;
 	struct rt6_info         *ip6_blk_hole_entry;
Index: net-2.6.26/net/ipv6/route.c
===================================================================
--- net-2.6.26.orig/net/ipv6/route.c
+++ net-2.6.26/net/ipv6/route.c
@@ -113,8 +113,6 @@ static struct dst_ops ip6_dst_ops_templa
 	.entries		=	ATOMIC_INIT(0),
 };
 
-static struct dst_ops *ip6_dst_ops;
-
 static void ip6_rt_blackhole_update_pmtu(struct dst_entry *dst, u32 mtu)
 {
 }
@@ -188,9 +186,9 @@ static struct rt6_info ip6_blk_hole_entr
 #endif
 
 /* allocate dst with ip6_dst_ops */
-static __inline__ struct rt6_info *ip6_dst_alloc(void)
+static inline struct rt6_info *ip6_dst_alloc(struct dst_ops *ops)
 {
-	return (struct rt6_info *)dst_alloc(ip6_dst_ops);
+	return (struct rt6_info *)dst_alloc(ops);
 }
 
 static void ip6_dst_destroy(struct dst_entry *dst)
@@ -925,7 +923,7 @@ struct dst_entry *icmp6_dst_alloc(struct
 	if (unlikely(idev == NULL))
 		return NULL;
 
-	rt = ip6_dst_alloc();
+	rt = ip6_dst_alloc(net->ipv6.ip6_dst_ops);
 	if (unlikely(rt == NULL)) {
 		in6_dev_put(idev);
 		goto out;
@@ -999,18 +997,18 @@ static int ip6_dst_gc(struct dst_ops *op
 	unsigned long now = jiffies;
 
 	if (time_after(last_gc + init_net.ipv6.sysctl.ip6_rt_gc_min_interval, now) &&
-	    atomic_read(&ip6_dst_ops->entries) <= init_net.ipv6.sysctl.ip6_rt_max_size)
+	    atomic_read(&init_net.ipv6.ip6_dst_ops->entries) <= init_net.ipv6.sysctl.ip6_rt_max_size)
 		goto out;
 
 	expire++;
 	fib6_run_gc(expire, &init_net);
 	last_gc = now;
-	if (atomic_read(&ip6_dst_ops->entries) < ip6_dst_ops->gc_thresh)
+	if (atomic_read(&init_net.ipv6.ip6_dst_ops->entries) < init_net.ipv6.ip6_dst_ops->gc_thresh)
 		expire = init_net.ipv6.sysctl.ip6_rt_gc_timeout>>1;
 
 out:
 	expire -= expire>>init_net.ipv6.sysctl.ip6_rt_gc_elasticity;
-	return (atomic_read(&ip6_dst_ops->entries) > init_net.ipv6.sysctl.ip6_rt_max_size);
+	return (atomic_read(&init_net.ipv6.ip6_dst_ops->entries) > init_net.ipv6.sysctl.ip6_rt_max_size);
 }
 
 /* Clean host part of a prefix. Not necessary in radix tree,
@@ -1084,7 +1082,7 @@ int ip6_route_add(struct fib6_config *cf
 		goto out;
 	}
 
-	rt = ip6_dst_alloc();
+	rt = ip6_dst_alloc(net->ipv6.ip6_dst_ops);
 
 	if (rt == NULL) {
 		err = -ENOMEM;
@@ -1570,7 +1568,8 @@ out:
 
 static struct rt6_info * ip6_rt_copy(struct rt6_info *ort)
 {
-	struct rt6_info *rt = ip6_dst_alloc();
+	struct net *net = ort->rt6i_dev->nd_net;
+	struct rt6_info *rt = ip6_dst_alloc(net->ipv6.ip6_dst_ops);
 
 	if (rt) {
 		rt->u.dst.input = ort->u.dst.input;
@@ -1849,7 +1848,7 @@ struct rt6_info *addrconf_dst_alloc(stru
 				    int anycast)
 {
 	struct net *net = idev->dev->nd_net;
-	struct rt6_info *rt = ip6_dst_alloc();
+	struct rt6_info *rt = ip6_dst_alloc(net->ipv6.ip6_dst_ops);
 
 	if (rt == NULL)
 		return ERR_PTR(-ENOMEM);
@@ -2407,7 +2406,7 @@ static int rt6_stats_seq_show(struct seq
 		   net->ipv6.rt6_stats->fib_rt_alloc,
 		   net->ipv6.rt6_stats->fib_rt_entries,
 		   net->ipv6.rt6_stats->fib_rt_cache,
-		   atomic_read(&ip6_dst_ops->entries),
+		   atomic_read(&net->ipv6.ip6_dst_ops->entries),
 		   net->ipv6.rt6_stats->fib_discarded_routes);
 
 	return 0;
@@ -2552,7 +2551,7 @@ struct ctl_table *ipv6_route_sysctl_init
 
 	if (table) {
 		table[0].data = &net->ipv6.sysctl.flush_delay;
-		table[1].data = &ip6_dst_ops_template.gc_thresh;
+		table[1].data = &net->ipv6.ip6_dst_ops->gc_thresh;
 		table[2].data = &net->ipv6.sysctl.ip6_rt_max_size;
 		table[3].data = &net->ipv6.sysctl.ip6_rt_gc_min_interval;
 		table[4].data = &net->ipv6.sysctl.ip6_rt_gc_timeout;
@@ -2571,14 +2570,21 @@ static int ip6_route_net_init(struct net
 	int ret = 0;
 
 	ret = -ENOMEM;
+	net->ipv6.ip6_dst_ops = kmemdup(&ip6_dst_ops_template,
+					sizeof(*net->ipv6.ip6_dst_ops),
+					GFP_KERNEL);
+	if (!net->ipv6.ip6_dst_ops)
+		goto out;
+	net->ipv6.ip6_dst_ops->dst_net = net;
+
 	net->ipv6.ip6_null_entry = kmemdup(&ip6_null_entry_template,
 					   sizeof(*net->ipv6.ip6_null_entry),
 					   GFP_KERNEL);
 	if (!net->ipv6.ip6_null_entry)
-		goto out;
+		goto out_ip6_dst_ops;
 	net->ipv6.ip6_null_entry->u.dst.path =
 		(struct dst_entry *)net->ipv6.ip6_null_entry;
-	net->ipv6.ip6_null_entry->u.dst.ops = ip6_dst_ops;
+	net->ipv6.ip6_null_entry->u.dst.ops = net->ipv6.ip6_dst_ops;
 
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	net->ipv6.ip6_prohibit_entry = kmemdup(&ip6_prohibit_entry_template,
@@ -2590,7 +2596,7 @@ static int ip6_route_net_init(struct net
 	}
 	net->ipv6.ip6_prohibit_entry->u.dst.path =
 		(struct dst_entry *)net->ipv6.ip6_prohibit_entry;
-	net->ipv6.ip6_prohibit_entry->u.dst.ops = ip6_dst_ops;
+	net->ipv6.ip6_prohibit_entry->u.dst.ops = net->ipv6.ip6_dst_ops;
 
 	net->ipv6.ip6_blk_hole_entry = kmemdup(&ip6_blk_hole_entry_template,
 					       sizeof(*net->ipv6.ip6_blk_hole_entry),
@@ -2602,7 +2608,7 @@ static int ip6_route_net_init(struct net
 	}
 	net->ipv6.ip6_blk_hole_entry->u.dst.path =
 		(struct dst_entry *)net->ipv6.ip6_blk_hole_entry;
-	net->ipv6.ip6_blk_hole_entry->u.dst.ops = ip6_dst_ops;
+	net->ipv6.ip6_blk_hole_entry->u.dst.ops = net->ipv6.ip6_dst_ops;
 #endif
 
 #ifdef CONFIG_PROC_FS
@@ -2612,6 +2618,10 @@ static int ip6_route_net_init(struct net
 	ret = 0;
 out:
 	return ret;
+
+out_ip6_dst_ops:
+	kfree(net->ipv6.ip6_dst_ops);
+	goto out;
 }
 
 static void ip6_route_net_exit(struct net *net)
@@ -2625,6 +2635,7 @@ static void ip6_route_net_exit(struct ne
 	kfree(net->ipv6.ip6_prohibit_entry);
 	kfree(net->ipv6.ip6_blk_hole_entry);
 #endif
+	kfree(net->ipv6.ip6_dst_ops);
 }
 
 static struct pernet_operations ip6_route_net_ops = {
@@ -2641,20 +2652,12 @@ int __init ip6_route_init(void)
 {
 	int ret;
 
-	ip6_dst_ops = kmemdup(&ip6_dst_ops_template,
-			      sizeof(*ip6_dst_ops), GFP_KERNEL);
-	if (!ip6_dst_ops)
-		return -ENOMEM;
-
 	ret = -ENOMEM;
 	ip6_dst_ops_template.kmem_cachep =
 		kmem_cache_create("ip6_dst_cache", sizeof(struct rt6_info), 0,
 				  SLAB_HWCACHE_ALIGN, NULL);
 	if (!ip6_dst_ops_template.kmem_cachep)
-		goto out_ip6_dst_ops;
-
-	ip6_dst_ops->kmem_cachep = ip6_dst_ops_template.kmem_cachep;
-	ip6_dst_blackhole_ops.kmem_cachep = ip6_dst_ops_template.kmem_cachep;
+		goto out;;
 
 	ret = register_pernet_subsys(&ip6_route_net_ops);
 	if (ret)
@@ -2705,9 +2708,7 @@ out_fib6_init:
 out_register_subsys:
 	unregister_pernet_subsys(&ip6_route_net_ops);
 out_kmem_cache:
-	kmem_cache_destroy(ip6_dst_ops->kmem_cachep);
-out_ip6_dst_ops:
-	kfree(ip6_dst_ops);
+	kmem_cache_destroy(ip6_dst_ops_template.kmem_cachep);
 	goto out;
 }
 
@@ -2718,6 +2719,5 @@ void ip6_route_cleanup(void)
 	xfrm6_fini();
 	fib6_gc_cleanup();
 	unregister_pernet_subsys(&ip6_route_net_ops);
-	kmem_cache_destroy(ip6_dst_ops->kmem_cachep);
-	kfree(ip6_dst_ops);
+	kmem_cache_destroy(ip6_dst_ops_template.kmem_cachep);
 }

-- 
