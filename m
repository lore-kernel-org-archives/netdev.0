From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 06/11][NETNS][IPV6] ip6_fib - gc timer per namespace
Date: Sun, 02 Mar 2008 10:37:26 +0100
Message-ID: <20080302094206.614993059@mai.toulouse-stg.fr.ibm.com>
References: <20080302093720.649869114@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:44849 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753213AbYCBJoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2008 04:44:14 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate5.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m229iCP2120444
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 09:44:12 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m229iCV21904844
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 09:44:12 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m229iB0a009370
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 09:44:12 GMT
Content-Disposition: inline; filename=06_11-ip6-fib-gc-timer-per-namespace.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the timer initialization at the network namespace creation
and store the network namespace in the timer argument.

That enables multiple timers (one per network namespace) to do garbage
collecting.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 include/net/ip6_route.h  |    2 -
 include/net/netns/ipv6.h |    1 
 net/ipv6/ip6_fib.c       |   56 +++++++++++++++++++++++------------------------
 net/ipv6/route.c         |    5 +++-
 4 files changed, 34 insertions(+), 30 deletions(-)

Index: net-2.6.26/include/net/ip6_route.h
===================================================================
--- net-2.6.26.orig/include/net/ip6_route.h
+++ net-2.6.26/include/net/ip6_route.h
@@ -78,7 +78,7 @@ extern struct dst_entry *ndisc_dst_alloc
 					 struct in6_addr *addr,
 					 int (*output)(struct sk_buff *));
 extern int ndisc_dst_gc(int *more);
-extern void fib6_force_start_gc(void);
+extern void fib6_force_start_gc(struct net *net);
 
 extern struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 					   const struct in6_addr *addr,
Index: net-2.6.26/include/net/netns/ipv6.h
===================================================================
--- net-2.6.26.orig/include/net/netns/ipv6.h
+++ net-2.6.26/include/net/netns/ipv6.h
@@ -36,6 +36,7 @@ struct netns_ipv6 {
 	struct xt_table		*ip6table_mangle;
 	struct xt_table		*ip6table_raw;
 #endif
+	struct timer_list       *ip6_fib_timer;
 	struct hlist_head       *fib_table_hash;
 	struct fib6_table       *fib6_main_tbl;
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
Index: net-2.6.26/net/ipv6/ip6_fib.c
===================================================================
--- net-2.6.26.orig/net/ipv6/ip6_fib.c
+++ net-2.6.26/net/ipv6/ip6_fib.c
@@ -95,8 +95,6 @@ static __u32 rt_sernum;
 
 static void fib6_gc_timer_cb(unsigned long arg);
 
-static struct timer_list *ip6_fib_timer;
-
 static struct fib6_walker_t fib6_walker_list = {
 	.prev	= &fib6_walker_list,
 	.next	= &fib6_walker_list,
@@ -663,19 +661,19 @@ static int fib6_add_rt2node(struct fib6_
 	return 0;
 }
 
-static __inline__ void fib6_start_gc(struct rt6_info *rt)
+static __inline__ void fib6_start_gc(struct net *net, struct rt6_info *rt)
 {
-	if (ip6_fib_timer->expires == 0 &&
+	if (net->ipv6.ip6_fib_timer->expires == 0 &&
 	    (rt->rt6i_flags & (RTF_EXPIRES|RTF_CACHE)))
-		mod_timer(ip6_fib_timer, jiffies +
-			  init_net.ipv6.sysctl.ip6_rt_gc_interval);
+		mod_timer(net->ipv6.ip6_fib_timer, jiffies +
+			  net->ipv6.sysctl.ip6_rt_gc_interval);
 }
 
-void fib6_force_start_gc(void)
+void fib6_force_start_gc(struct net *net)
 {
-	if (ip6_fib_timer->expires == 0)
-		mod_timer(ip6_fib_timer, jiffies +
-			  init_net.ipv6.sysctl.ip6_rt_gc_interval);
+	if (net->ipv6.ip6_fib_timer->expires == 0)
+		mod_timer(net->ipv6.ip6_fib_timer, jiffies +
+			  net->ipv6.sysctl.ip6_rt_gc_interval);
 }
 
 /*
@@ -762,7 +760,7 @@ int fib6_add(struct fib6_node *root, str
 	err = fib6_add_rt2node(fn, rt, info);
 
 	if (err == 0) {
-		fib6_start_gc(rt);
+		fib6_start_gc(info->nl_net, rt);
 		if (!(rt->rt6i_flags&RTF_CACHE))
 			fib6_prune_clones(pn, rt);
 	}
@@ -1443,7 +1441,7 @@ void fib6_run_gc(unsigned long expires, 
 	} else {
 		local_bh_disable();
 		if (!spin_trylock(&fib6_gc_lock)) {
-			mod_timer(ip6_fib_timer, jiffies + HZ);
+			mod_timer(net->ipv6.ip6_fib_timer, jiffies + HZ);
 			local_bh_enable();
 			return;
 		}
@@ -1456,11 +1454,11 @@ void fib6_run_gc(unsigned long expires, 
 	fib6_clean_all(net, fib6_age, 0, NULL);
 
 	if (gc_args.more)
-		mod_timer(ip6_fib_timer, jiffies +
+		mod_timer(net->ipv6.ip6_fib_timer, jiffies +
 			  net->ipv6.sysctl.ip6_rt_gc_interval);
 	else {
-		del_timer(ip6_fib_timer);
-		ip6_fib_timer->expires = 0;
+		del_timer(net->ipv6.ip6_fib_timer);
+		net->ipv6.ip6_fib_timer->expires = 0;
 	}
 	spin_unlock_bh(&fib6_gc_lock);
 }
@@ -1473,13 +1471,21 @@ static void fib6_gc_timer_cb(unsigned lo
 static int fib6_net_init(struct net *net)
 {
 	int ret;
+	struct timer_list *timer;
 
 	ret = -ENOMEM;
+	timer = kzalloc(sizeof(*timer), GFP_KERNEL);
+	if (!timer)
+		goto out;
+
+	setup_timer(timer, fib6_gc_timer_cb, (unsigned long)net);
+	net->ipv6.ip6_fib_timer = timer;
+
 	net->ipv6.fib_table_hash =
 		kzalloc(sizeof(*net->ipv6.fib_table_hash)*FIB_TABLE_HASHSZ,
 			GFP_KERNEL);
 	if (!net->ipv6.fib_table_hash)
-		goto out;
+		goto out_timer;
 
 	net->ipv6.fib6_main_tbl = kzalloc(sizeof(*net->ipv6.fib6_main_tbl),
 					  GFP_KERNEL);
@@ -1513,11 +1519,15 @@ out_fib6_main_tbl:
 #endif
 out_fib_table_hash:
 	kfree(net->ipv6.fib_table_hash);
+out_timer:
+	kfree(timer);
 	goto out;
  }
 
 static void fib6_net_exit(struct net *net)
 {
+	del_timer(net->ipv6.ip6_fib_timer);
+	kfree(net->ipv6.ip6_fib_timer);
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	kfree(net->ipv6.fib6_local_tbl);
 #endif
@@ -1533,6 +1543,7 @@ static struct pernet_operations fib6_net
 int __init fib6_init(void)
 {
 	int ret = -ENOMEM;
+
 	fib6_node_kmem = kmem_cache_create("fib6_nodes",
 					   sizeof(struct fib6_node),
 					   0, SLAB_HWCACHE_ALIGN,
@@ -1540,16 +1551,9 @@ int __init fib6_init(void)
 	if (!fib6_node_kmem)
 		goto out;
 
-	ret = -ENOMEM;
-	ip6_fib_timer = kzalloc(sizeof(*ip6_fib_timer), GFP_KERNEL);
-	if (!ip6_fib_timer)
-		goto out_kmem_cache_create;
-
-	setup_timer(ip6_fib_timer, fib6_gc_timer_cb, (unsigned long)&init_net);
-
 	ret = register_pernet_subsys(&fib6_net_ops);
 	if (ret)
-		goto out_timer;
+		goto out_kmem_cache_create;
 
 	ret = __rtnl_register(PF_INET6, RTM_GETROUTE, NULL, inet6_dump_fib);
 	if (ret)
@@ -1559,8 +1563,6 @@ out:
 
 out_unregister_subsys:
 	unregister_pernet_subsys(&fib6_net_ops);
-out_timer:
-	kfree(ip6_fib_timer);
 out_kmem_cache_create:
 	kmem_cache_destroy(fib6_node_kmem);
 	goto out;
@@ -1568,8 +1570,6 @@ out_kmem_cache_create:
 
 void fib6_gc_cleanup(void)
 {
-	del_timer(ip6_fib_timer);
-	kfree(ip6_fib_timer);
 	unregister_pernet_subsys(&fib6_net_ops);
 	kmem_cache_destroy(fib6_node_kmem);
 }
Index: net-2.6.26/net/ipv6/route.c
===================================================================
--- net-2.6.26.orig/net/ipv6/route.c
+++ net-2.6.26/net/ipv6/route.c
@@ -953,7 +953,7 @@ struct dst_entry *ndisc_dst_alloc(struct
 	ndisc_dst_gc_list = &rt->u.dst;
 	spin_unlock_bh(&ndisc_lock);
 
-	fib6_force_start_gc();
+	fib6_force_start_gc(dev->nd_net);
 
 out:
 	return &rt->u.dst;
@@ -1231,6 +1231,9 @@ install_route:
 	rt->u.dst.dev = dev;
 	rt->rt6i_idev = idev;
 	rt->rt6i_table = table;
+
+	cfg->fc_nlinfo.nl_net = dev->nd_net;
+
 	return __ip6_ins_rt(rt, &cfg->fc_nlinfo);
 
 out:

-- 
