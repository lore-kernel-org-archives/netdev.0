From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 11/11][NETNS][IPV6] rt6_stats - make the stats per network namespace
Date: Sun, 02 Mar 2008 10:37:31 +0100
Message-ID: <20080302094243.621444844@mai.toulouse-stg.fr.ibm.com>
References: <20080302093720.649869114@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:7820 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753110AbYCBJoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2008 04:44:54 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id m229irvh236020
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 09:44:53 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m229irjR540804
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 10:44:53 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m229iqLc005729
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 09:44:53 GMT
Content-Disposition: inline; filename=11_11-rt6-stats-per-namespace.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The rt6_stats is now per namespace with this patch. It is
allocated when a network namespace is created and freed
when the network namespace exits and references are relative
to the network namespace.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/net/ipv6.h       |    1 -
 include/net/netns/ipv6.h |    1 +
 net/ipv6/ip6_fib.c       |   32 +++++++++++++++-----------------
 net/ipv6/route.c         |   12 +++++++-----
 4 files changed, 23 insertions(+), 23 deletions(-)

Index: net-2.6.26/include/net/ipv6.h
===================================================================
--- net-2.6.26.orig/include/net/ipv6.h
+++ net-2.6.26/include/net/ipv6.h
@@ -610,7 +610,6 @@ extern void ipv6_misc_proc_exit(void);
 extern int snmp6_register_dev(struct inet6_dev *idev);
 extern int snmp6_unregister_dev(struct inet6_dev *idev);
 
-extern struct rt6_statistics *rt6_stats;
 #else
 static inline int snmp6_register_dev(struct inet6_dev *idev)
 {
Index: net-2.6.26/include/net/netns/ipv6.h
===================================================================
--- net-2.6.26.orig/include/net/netns/ipv6.h
+++ net-2.6.26/include/net/netns/ipv6.h
@@ -36,6 +36,7 @@ struct netns_ipv6 {
 	struct xt_table		*ip6table_mangle;
 	struct xt_table		*ip6table_raw;
 #endif
+	struct rt6_statistics   *rt6_stats;
 	struct timer_list       *ip6_fib_timer;
 	struct hlist_head       *fib_table_hash;
 	struct fib6_table       *fib6_main_tbl;
Index: net-2.6.26/net/ipv6/ip6_fib.c
===================================================================
--- net-2.6.26.orig/net/ipv6/ip6_fib.c
+++ net-2.6.26/net/ipv6/ip6_fib.c
@@ -48,8 +48,6 @@
 #define RT6_TRACE(x...) do { ; } while (0)
 #endif
 
-struct rt6_statistics *rt6_stats;
-
 static struct kmem_cache * fib6_node_kmem __read_mostly;
 
 enum fib_walk_state_t
@@ -653,10 +651,10 @@ static int fib6_add_rt2node(struct fib6_
 	rt->rt6i_node = fn;
 	atomic_inc(&rt->rt6i_ref);
 	inet6_rt_notify(RTM_NEWROUTE, rt, info);
-	rt6_stats->fib_rt_entries++;
+	info->nl_net->ipv6.rt6_stats->fib_rt_entries++;
 
 	if ((fn->fn_flags & RTN_RTINFO) == 0) {
-		rt6_stats->fib_route_nodes++;
+		info->nl_net->ipv6.rt6_stats->fib_route_nodes++;
 		fn->fn_flags |= RTN_RTINFO;
 	}
 
@@ -1087,14 +1085,15 @@ static void fib6_del_route(struct fib6_n
 {
 	struct fib6_walker_t *w;
 	struct rt6_info *rt = *rtp;
+	struct net *net = info->nl_net;
 
 	RT6_TRACE("fib6_del_route\n");
 
 	/* Unlink it */
 	*rtp = rt->u.dst.rt6_next;
 	rt->rt6i_node = NULL;
-	rt6_stats->fib_rt_entries--;
-	rt6_stats->fib_discarded_routes++;
+	net->ipv6.rt6_stats->fib_rt_entries--;
+	net->ipv6.rt6_stats->fib_discarded_routes++;
 
 	/* Reset round-robin state, if necessary */
 	if (fn->rr_ptr == rt)
@@ -1117,7 +1116,7 @@ static void fib6_del_route(struct fib6_n
 	/* If it was last route, expunge its radix tree node */
 	if (fn->leaf == NULL) {
 		fn->fn_flags &= ~RTN_RTINFO;
-		rt6_stats->fib_route_nodes--;
+		net->ipv6.rt6_stats->fib_route_nodes--;
 		fn = fib6_repair_tree(fn);
 	}
 
@@ -1486,11 +1485,15 @@ static int fib6_net_init(struct net *net
 	setup_timer(timer, fib6_gc_timer_cb, (unsigned long)net);
 	net->ipv6.ip6_fib_timer = timer;
 
+	net->ipv6.rt6_stats = kzalloc(sizeof(*net->ipv6.rt6_stats), GFP_KERNEL);
+	if (!net->ipv6.rt6_stats)
+		goto out_timer;
+
 	net->ipv6.fib_table_hash =
 		kzalloc(sizeof(*net->ipv6.fib_table_hash)*FIB_TABLE_HASHSZ,
 			GFP_KERNEL);
 	if (!net->ipv6.fib_table_hash)
-		goto out_timer;
+		goto out_rt6_stats;
 
 	net->ipv6.fib6_main_tbl = kzalloc(sizeof(*net->ipv6.fib6_main_tbl),
 					  GFP_KERNEL);
@@ -1524,6 +1527,8 @@ out_fib6_main_tbl:
 #endif
 out_fib_table_hash:
 	kfree(net->ipv6.fib_table_hash);
+out_rt6_stats:
+	kfree(net->ipv6.rt6_stats);
 out_timer:
 	kfree(timer);
 	goto out;
@@ -1538,6 +1543,7 @@ static void fib6_net_exit(struct net *ne
 #endif
 	kfree(net->ipv6.fib6_main_tbl);
 	kfree(net->ipv6.fib_table_hash);
+	kfree(net->ipv6.rt6_stats);
 }
 
 static struct pernet_operations fib6_net_ops = {
@@ -1556,14 +1562,9 @@ int __init fib6_init(void)
 	if (!fib6_node_kmem)
 		goto out;
 
-	ret = -ENOMEM;
-	rt6_stats = kzalloc(sizeof(*rt6_stats), GFP_KERNEL);
-	if (!rt6_stats)
-		goto out_kmem_cache_create;
-
 	ret = register_pernet_subsys(&fib6_net_ops);
 	if (ret)
-		goto out_rt6_stats;
+		goto out_kmem_cache_create;
 
 	ret = __rtnl_register(PF_INET6, RTM_GETROUTE, NULL, inet6_dump_fib);
 	if (ret)
@@ -1573,8 +1574,6 @@ out:
 
 out_unregister_subsys:
 	unregister_pernet_subsys(&fib6_net_ops);
-out_rt6_stats:
-	kfree(rt6_stats);
 out_kmem_cache_create:
 	kmem_cache_destroy(fib6_node_kmem);
 	goto out;
@@ -1583,6 +1582,5 @@ out_kmem_cache_create:
 void fib6_gc_cleanup(void)
 {
 	unregister_pernet_subsys(&fib6_net_ops);
-	kfree(rt6_stats);
 	kmem_cache_destroy(fib6_node_kmem);
 }
Index: net-2.6.26/net/ipv6/route.c
===================================================================
--- net-2.6.26.orig/net/ipv6/route.c
+++ net-2.6.26/net/ipv6/route.c
@@ -2354,11 +2354,13 @@ static const struct file_operations ipv6
 static int rt6_stats_seq_show(struct seq_file *seq, void *v)
 {
 	seq_printf(seq, "%04x %04x %04x %04x %04x %04x %04x\n",
-		      rt6_stats->fib_nodes, rt6_stats->fib_route_nodes,
-		      rt6_stats->fib_rt_alloc, rt6_stats->fib_rt_entries,
-		      rt6_stats->fib_rt_cache,
-		      atomic_read(&ip6_dst_ops.entries),
-		      rt6_stats->fib_discarded_routes);
+		   init_net.ipv6.rt6_stats->fib_nodes,
+		   init_net.ipv6.rt6_stats->fib_route_nodes,
+		   init_net.ipv6.rt6_stats->fib_rt_alloc,
+		   init_net.ipv6.rt6_stats->fib_rt_entries,
+		   init_net.ipv6.rt6_stats->fib_rt_cache,
+		   atomic_read(&ip6_dst_ops.entries),
+		   init_net.ipv6.rt6_stats->fib_discarded_routes);
 
 	return 0;
 }

-- 
