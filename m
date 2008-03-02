From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 10/11][NETNS][IPV6] rt6_stats - dynamically allocate the routes statistics
Date: Sun, 02 Mar 2008 10:37:30 +0100
Message-ID: <20080302094239.479993746@mai.toulouse-stg.fr.ibm.com>
References: <20080302093720.649869114@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:36195 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753291AbYCBJoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2008 04:44:46 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id m229iisP096854
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 09:44:44 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m229iipO512186
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 10:44:44 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m229ihRx021927
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 10:44:44 +0100
Content-Disposition: inline; filename=10_11-rt6-stats-dynamic-allocation.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allocates the rt6_stats struct dynamically when
the fib6 is initialized. That provides the ability to create
several instances of this structure for the network namespaces.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 include/net/ipv6.h |    2 +-
 net/ipv6/ip6_fib.c |   22 +++++++++++++++-------
 net/ipv6/route.c   |    8 ++++----
 3 files changed, 20 insertions(+), 12 deletions(-)

Index: net-2.6.26/include/net/ipv6.h
===================================================================
--- net-2.6.26.orig/include/net/ipv6.h
+++ net-2.6.26/include/net/ipv6.h
@@ -610,7 +610,7 @@ extern void ipv6_misc_proc_exit(void);
 extern int snmp6_register_dev(struct inet6_dev *idev);
 extern int snmp6_unregister_dev(struct inet6_dev *idev);
 
-extern struct rt6_statistics rt6_stats;
+extern struct rt6_statistics *rt6_stats;
 #else
 static inline int snmp6_register_dev(struct inet6_dev *idev)
 {
Index: net-2.6.26/net/ipv6/ip6_fib.c
===================================================================
--- net-2.6.26.orig/net/ipv6/ip6_fib.c
+++ net-2.6.26/net/ipv6/ip6_fib.c
@@ -48,7 +48,7 @@
 #define RT6_TRACE(x...) do { ; } while (0)
 #endif
 
-struct rt6_statistics	rt6_stats;
+struct rt6_statistics *rt6_stats;
 
 static struct kmem_cache * fib6_node_kmem __read_mostly;
 
@@ -653,10 +653,10 @@ static int fib6_add_rt2node(struct fib6_
 	rt->rt6i_node = fn;
 	atomic_inc(&rt->rt6i_ref);
 	inet6_rt_notify(RTM_NEWROUTE, rt, info);
-	rt6_stats.fib_rt_entries++;
+	rt6_stats->fib_rt_entries++;
 
 	if ((fn->fn_flags & RTN_RTINFO) == 0) {
-		rt6_stats.fib_route_nodes++;
+		rt6_stats->fib_route_nodes++;
 		fn->fn_flags |= RTN_RTINFO;
 	}
 
@@ -1093,8 +1093,8 @@ static void fib6_del_route(struct fib6_n
 	/* Unlink it */
 	*rtp = rt->u.dst.rt6_next;
 	rt->rt6i_node = NULL;
-	rt6_stats.fib_rt_entries--;
-	rt6_stats.fib_discarded_routes++;
+	rt6_stats->fib_rt_entries--;
+	rt6_stats->fib_discarded_routes++;
 
 	/* Reset round-robin state, if necessary */
 	if (fn->rr_ptr == rt)
@@ -1117,7 +1117,7 @@ static void fib6_del_route(struct fib6_n
 	/* If it was last route, expunge its radix tree node */
 	if (fn->leaf == NULL) {
 		fn->fn_flags &= ~RTN_RTINFO;
-		rt6_stats.fib_route_nodes--;
+		rt6_stats->fib_route_nodes--;
 		fn = fib6_repair_tree(fn);
 	}
 
@@ -1556,9 +1556,14 @@ int __init fib6_init(void)
 	if (!fib6_node_kmem)
 		goto out;
 
+	ret = -ENOMEM;
+	rt6_stats = kzalloc(sizeof(*rt6_stats), GFP_KERNEL);
+	if (!rt6_stats)
+		goto out_kmem_cache_create;
+
 	ret = register_pernet_subsys(&fib6_net_ops);
 	if (ret)
-		goto out_kmem_cache_create;
+		goto out_rt6_stats;
 
 	ret = __rtnl_register(PF_INET6, RTM_GETROUTE, NULL, inet6_dump_fib);
 	if (ret)
@@ -1568,6 +1573,8 @@ out:
 
 out_unregister_subsys:
 	unregister_pernet_subsys(&fib6_net_ops);
+out_rt6_stats:
+	kfree(rt6_stats);
 out_kmem_cache_create:
 	kmem_cache_destroy(fib6_node_kmem);
 	goto out;
@@ -1576,5 +1583,6 @@ out_kmem_cache_create:
 void fib6_gc_cleanup(void)
 {
 	unregister_pernet_subsys(&fib6_net_ops);
+	kfree(rt6_stats);
 	kmem_cache_destroy(fib6_node_kmem);
 }
Index: net-2.6.26/net/ipv6/route.c
===================================================================
--- net-2.6.26.orig/net/ipv6/route.c
+++ net-2.6.26/net/ipv6/route.c
@@ -2354,11 +2354,11 @@ static const struct file_operations ipv6
 static int rt6_stats_seq_show(struct seq_file *seq, void *v)
 {
 	seq_printf(seq, "%04x %04x %04x %04x %04x %04x %04x\n",
-		      rt6_stats.fib_nodes, rt6_stats.fib_route_nodes,
-		      rt6_stats.fib_rt_alloc, rt6_stats.fib_rt_entries,
-		      rt6_stats.fib_rt_cache,
+		      rt6_stats->fib_nodes, rt6_stats->fib_route_nodes,
+		      rt6_stats->fib_rt_alloc, rt6_stats->fib_rt_entries,
+		      rt6_stats->fib_rt_cache,
 		      atomic_read(&ip6_dst_ops.entries),
-		      rt6_stats.fib_discarded_routes);
+		      rt6_stats->fib_discarded_routes);
 
 	return 0;
 }

-- 
