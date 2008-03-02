From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 03/11][NETNS][IPV6] ip6_fib - fib6_clean_all handle several network namespaces
Date: Sun, 02 Mar 2008 10:37:23 +0100
Message-ID: <20080302094144.746906445@mai.toulouse-stg.fr.ibm.com>
References: <20080302093720.649869114@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:51159 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752948AbYCBJn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2008 04:43:56 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.8/8.13.8) with ESMTP id m229hsYM364184
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 09:43:55 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m229hsNX528474
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 10:43:54 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m229hrUN021681
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 10:43:54 +0100
Content-Disposition: inline; filename=03_11-ip6-fib-make-fib6_clean_all-per-namespace.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function fib6_clean_all takes the network namespace
as parameter. That allows to flush the routes related to 
a specific network namespace.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 include/net/ip6_fib.h   |    3 ++-
 include/net/ip6_route.h |    2 +-
 net/ipv6/addrconf.c     |    3 ++-
 net/ipv6/ip6_fib.c      |    7 ++++---
 net/ipv6/route.c        |   28 ++++++++++++++++++++--------
 5 files changed, 29 insertions(+), 14 deletions(-)

Index: net-2.6.26/include/net/ip6_fib.h
===================================================================
--- net-2.6.26.orig/include/net/ip6_fib.h
+++ net-2.6.26/include/net/ip6_fib.h
@@ -195,7 +195,8 @@ struct fib6_node		*fib6_locate(struct fi
 					     struct in6_addr *daddr, int dst_len,
 					     struct in6_addr *saddr, int src_len);
 
-extern void			fib6_clean_all(int (*func)(struct rt6_info *, void *arg),
+extern void			fib6_clean_all(struct net *net,
+					       int (*func)(struct rt6_info *, void *arg),
 					       int prune, void *arg);
 
 extern int			fib6_add(struct fib6_node *root,
Index: net-2.6.26/include/net/ip6_route.h
===================================================================
--- net-2.6.26.orig/include/net/ip6_route.h
+++ net-2.6.26/include/net/ip6_route.h
@@ -121,7 +121,7 @@ struct rt6_rtnl_dump_arg
 };
 
 extern int rt6_dump_route(struct rt6_info *rt, void *p_arg);
-extern void rt6_ifdown(struct net_device *dev);
+extern void rt6_ifdown(struct net *net, struct net_device *dev);
 extern void rt6_mtu_change(struct net_device *dev, unsigned mtu);
 
 extern rwlock_t rt6_lock;
Index: net-2.6.26/net/ipv6/addrconf.c
===================================================================
--- net-2.6.26.orig/net/ipv6/addrconf.c
+++ net-2.6.26/net/ipv6/addrconf.c
@@ -2438,6 +2438,7 @@ static int addrconf_ifdown(struct net_de
 {
 	struct inet6_dev *idev;
 	struct inet6_ifaddr *ifa, **bifa;
+	struct net *net = dev->nd_net;
 	int i;
 
 	ASSERT_RTNL();
@@ -2445,7 +2446,7 @@ static int addrconf_ifdown(struct net_de
 	if (dev == init_net.loopback_dev && how == 1)
 		how = 0;
 
-	rt6_ifdown(dev);
+	rt6_ifdown(net, dev);
 	neigh_ifdown(&nd_tbl, dev);
 
 	idev = __in6_dev_get(dev);
Index: net-2.6.26/net/ipv6/ip6_fib.c
===================================================================
--- net-2.6.26.orig/net/ipv6/ip6_fib.c
+++ net-2.6.26/net/ipv6/ip6_fib.c
@@ -1350,7 +1350,7 @@ static void fib6_clean_tree(struct fib6_
 	fib6_walk(&c.w);
 }
 
-void fib6_clean_all(int (*func)(struct rt6_info *, void *arg),
+void fib6_clean_all(struct net *net, int (*func)(struct rt6_info *, void *arg),
 		    int prune, void *arg)
 {
 	struct fib6_table *table;
@@ -1360,7 +1360,7 @@ void fib6_clean_all(int (*func)(struct r
 
 	rcu_read_lock();
 	for (h = 0; h < FIB_TABLE_HASHSZ; h++) {
-		head = &init_net.ipv6.fib_table_hash[h];
+		head = &net->ipv6.fib_table_hash[h];
 		hlist_for_each_entry_rcu(table, node, head, tb6_hlist) {
 			write_lock_bh(&table->tb6_lock);
 			fib6_clean_tree(&table->tb6_root, func, prune, arg);
@@ -1450,7 +1450,8 @@ void fib6_run_gc(unsigned long dummy)
 	gc_args.more = 0;
 
 	ndisc_dst_gc(&gc_args.more);
-	fib6_clean_all(fib6_age, 0, NULL);
+
+	fib6_clean_all(&init_net, fib6_age, 0, NULL);
 
 	if (gc_args.more)
 		mod_timer(&ip6_fib_timer, jiffies +
Index: net-2.6.26/net/ipv6/route.c
===================================================================
--- net-2.6.26.orig/net/ipv6/route.c
+++ net-2.6.26/net/ipv6/route.c
@@ -1871,9 +1871,9 @@ static int fib6_ifdown(struct rt6_info *
 	return 0;
 }
 
-void rt6_ifdown(struct net_device *dev)
+void rt6_ifdown(struct net *net, struct net_device *dev)
 {
-	fib6_clean_all(fib6_ifdown, 0, dev);
+	fib6_clean_all(net, fib6_ifdown, 0, dev);
 }
 
 struct rt6_mtu_change_arg
@@ -1929,7 +1929,7 @@ void rt6_mtu_change(struct net_device *d
 		.mtu = mtu,
 	};
 
-	fib6_clean_all(rt6_mtu_change_route, 0, &arg);
+	fib6_clean_all(dev->nd_net, rt6_mtu_change_route, 0, &arg);
 }
 
 static const struct nla_policy rtm_ipv6_policy[RTA_MAX+1] = {
@@ -2318,13 +2318,25 @@ static int rt6_info_route(struct rt6_inf
 
 static int ipv6_route_show(struct seq_file *m, void *v)
 {
-	fib6_clean_all(rt6_info_route, 0, m);
+	struct net *net = (struct net *)m->private;
+	fib6_clean_all(net, rt6_info_route, 0, m);
 	return 0;
 }
 
 static int ipv6_route_open(struct inode *inode, struct file *file)
 {
-	return single_open(file, ipv6_route_show, NULL);
+	struct net *net = get_proc_net(inode);
+	if (!net)
+		return -ENXIO;
+	return single_open(file, ipv6_route_show, net);
+}
+
+static int ipv6_route_release(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq = file->private_data;
+	struct net *net = seq->private;
+	put_net(net);
+	return single_release(inode, file);
 }
 
 static const struct file_operations ipv6_route_proc_fops = {
@@ -2332,7 +2344,7 @@ static const struct file_operations ipv6
 	.open		= ipv6_route_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
-	.release	= single_release,
+	.release	= ipv6_route_release,
 };
 
 static int rt6_stats_seq_show(struct seq_file *seq, void *v)
@@ -2556,7 +2568,7 @@ xfrm6_init:
 out_proc_init:
 	ipv6_route_proc_fini(&init_net);
 out_fib6_init:
-	rt6_ifdown(NULL);
+	rt6_ifdown(&init_net, NULL);
 	fib6_gc_cleanup();
 out_kmem_cache:
 	kmem_cache_destroy(ip6_dst_ops.kmem_cachep);
@@ -2568,7 +2580,7 @@ void ip6_route_cleanup(void)
 	fib6_rules_cleanup();
 	ipv6_route_proc_fini(&init_net);
 	xfrm6_fini();
-	rt6_ifdown(NULL);
+	rt6_ifdown(&init_net, NULL);
 	fib6_gc_cleanup();
 	kmem_cache_destroy(ip6_dst_ops.kmem_cachep);
 }

-- 
