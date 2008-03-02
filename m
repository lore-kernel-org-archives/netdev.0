From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 02/11][NETNS][IPV6] ip6_fib - make it per network namespace
Date: Sun, 02 Mar 2008 10:37:22 +0100
Message-ID: <20080302094133.726696590@mai.toulouse-stg.fr.ibm.com>
References: <20080302093720.649869114@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:45572 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750963AbYCBJnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2008 04:43:47 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id m229hklM176240
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 09:43:46 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m229hjgk536828
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 10:43:45 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m229hjQX030420
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 09:43:45 GMT
Content-Disposition: inline; filename=02_11-ip6-fib-per-network-namespace.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fib table for ipv6 are moved to the network namespace structure.
All references to them are made relatively to the network namespace.

All external calls to the ip6_fib functions taking the network namespace 
parameter are made using the init_net variable, so the ip6_fib engine is
ready for the namespaces but the callers not yet.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 include/net/ip6_fib.h    |    9 +-
 include/net/netns/ipv6.h |    5 +
 net/ipv6/fib6_rules.c    |    8 +-
 net/ipv6/ip6_fib.c       |  161 +++++++++++++++++++++++++++--------------------
 net/ipv6/route.c         |   22 +++---
 5 files changed, 119 insertions(+), 86 deletions(-)

Index: net-2.6.26/include/net/ip6_fib.h
===================================================================
--- net-2.6.26.orig/include/net/ip6_fib.h
+++ net-2.6.26/include/net/ip6_fib.h
@@ -181,10 +181,11 @@ typedef struct rt6_info *(*pol_lookup_t)
  *	exported functions
  */
 
-extern struct fib6_table *	fib6_get_table(u32 id);
-extern struct fib6_table *	fib6_new_table(u32 id);
-extern struct dst_entry *	fib6_rule_lookup(struct flowi *fl, int flags,
-						 pol_lookup_t lookup);
+extern struct fib6_table        *fib6_get_table(struct net *net, u32 id);
+extern struct fib6_table        *fib6_new_table(struct net *net, u32 id);
+extern struct dst_entry         *fib6_rule_lookup(struct net *net,
+						  struct flowi *fl, int flags,
+						  pol_lookup_t lookup);
 
 extern struct fib6_node		*fib6_lookup(struct fib6_node *root,
 					     struct in6_addr *daddr,
Index: net-2.6.26/include/net/netns/ipv6.h
===================================================================
--- net-2.6.26.orig/include/net/netns/ipv6.h
+++ net-2.6.26/include/net/netns/ipv6.h
@@ -36,6 +36,11 @@ struct netns_ipv6 {
 	struct xt_table		*ip6table_mangle;
 	struct xt_table		*ip6table_raw;
 #endif
+	struct hlist_head       *fib_table_hash;
+	struct fib6_table       *fib6_main_tbl;
+#ifdef CONFIG_IPV6_MULTIPLE_TABLES
+	struct fib6_table       *fib6_local_tbl;
+#endif
 	struct sock		**icmp_sk;
 };
 #endif
Index: net-2.6.26/net/ipv6/fib6_rules.c
===================================================================
--- net-2.6.26.orig/net/ipv6/fib6_rules.c
+++ net-2.6.26/net/ipv6/fib6_rules.c
@@ -31,8 +31,8 @@ struct fib6_rule
 
 static struct fib_rules_ops fib6_rules_ops;
 
-struct dst_entry *fib6_rule_lookup(struct flowi *fl, int flags,
-				   pol_lookup_t lookup)
+struct dst_entry *fib6_rule_lookup(struct net *net, struct flowi *fl,
+				   int flags, pol_lookup_t lookup)
 {
 	struct fib_lookup_arg arg = {
 		.lookup_ptr = lookup,
@@ -71,7 +71,7 @@ static int fib6_rule_action(struct fib_r
 		goto discard_pkt;
 	}
 
-	table = fib6_get_table(rule->table);
+	table = fib6_get_table(&init_net, rule->table);
 	if (table)
 		rt = lookup(table, flp, flags);
 
@@ -151,7 +151,7 @@ static int fib6_rule_configure(struct fi
 		if (rule->table == RT6_TABLE_UNSPEC)
 			goto errout;
 
-		if (fib6_new_table(rule->table) == NULL) {
+		if (fib6_new_table(&init_net, rule->table) == NULL) {
 			err = -ENOBUFS;
 			goto errout;
 		}
Index: net-2.6.26/net/ipv6/ip6_fib.c
===================================================================
--- net-2.6.26.orig/net/ipv6/ip6_fib.c
+++ net-2.6.26/net/ipv6/ip6_fib.c
@@ -166,16 +166,13 @@ static __inline__ void rt6_release(struc
 		dst_free(&rt->u.dst);
 }
 
-static struct fib6_table *fib6_main_tbl;
-
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 #define FIB_TABLE_HASHSZ 256
 #else
 #define FIB_TABLE_HASHSZ 1
 #endif
-static struct hlist_head *fib_table_hash;
 
-static void fib6_link_table(struct fib6_table *tb)
+static void fib6_link_table(struct net *net, struct fib6_table *tb)
 {
 	unsigned int h;
 
@@ -191,13 +188,11 @@ static void fib6_link_table(struct fib6_
 	 * No protection necessary, this is the only list mutatation
 	 * operation, tables never disappear once they exist.
 	 */
-	hlist_add_head_rcu(&tb->tb6_hlist, &fib_table_hash[h]);
+	hlist_add_head_rcu(&tb->tb6_hlist, &net->ipv6.fib_table_hash[h]);
 }
 
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 
-static struct fib6_table *fib6_local_tbl;
-
 static struct fib6_table *fib6_alloc_table(u32 id)
 {
 	struct fib6_table *table;
@@ -212,26 +207,27 @@ static struct fib6_table *fib6_alloc_tab
 	return table;
 }
 
-struct fib6_table *fib6_new_table(u32 id)
+struct fib6_table *fib6_new_table(struct net *net, u32 id)
 {
 	struct fib6_table *tb;
 
 	if (id == 0)
 		id = RT6_TABLE_MAIN;
-	tb = fib6_get_table(id);
+	tb = fib6_get_table(net, id);
 	if (tb)
 		return tb;
 
 	tb = fib6_alloc_table(id);
 	if (tb != NULL)
-		fib6_link_table(tb);
+		fib6_link_table(net, tb);
 
 	return tb;
 }
 
-struct fib6_table *fib6_get_table(u32 id)
+struct fib6_table *fib6_get_table(struct net *net, u32 id)
 {
 	struct fib6_table *tb;
+	struct hlist_head *head;
 	struct hlist_node *node;
 	unsigned int h;
 
@@ -239,7 +235,8 @@ struct fib6_table *fib6_get_table(u32 id
 		id = RT6_TABLE_MAIN;
 	h = id & (FIB_TABLE_HASHSZ - 1);
 	rcu_read_lock();
-	hlist_for_each_entry_rcu(tb, node, &fib_table_hash[h], tb6_hlist) {
+	head = &net->ipv6.fib_table_hash[h];
+	hlist_for_each_entry_rcu(tb, node, head, tb6_hlist) {
 		if (tb->tb6_id == id) {
 			rcu_read_unlock();
 			return tb;
@@ -250,33 +247,32 @@ struct fib6_table *fib6_get_table(u32 id
 	return NULL;
 }
 
-static void __init fib6_tables_init(void)
+static void fib6_tables_init(struct net *net)
 {
-	fib6_link_table(fib6_main_tbl);
-	fib6_link_table(fib6_local_tbl);
+	fib6_link_table(net, net->ipv6.fib6_main_tbl);
+	fib6_link_table(net, net->ipv6.fib6_local_tbl);
 }
-
 #else
 
-struct fib6_table *fib6_new_table(u32 id)
+struct fib6_table *fib6_new_table(struct net *net, u32 id)
 {
-	return fib6_get_table(id);
+	return fib6_get_table(net, id);
 }
 
-struct fib6_table *fib6_get_table(u32 id)
+struct fib6_table *fib6_get_table(struct net *net, u32 id)
 {
-	return fib6_main_tbl;
+	  return net->ipv6.fib6_main_tbl;
 }
 
-struct dst_entry *fib6_rule_lookup(struct flowi *fl, int flags,
-				   pol_lookup_t lookup)
+struct dst_entry *fib6_rule_lookup(struct net *net, struct flowi *fl,
+				   int flags, pol_lookup_t lookup)
 {
-	return (struct dst_entry *) lookup(fib6_main_tbl, fl, flags);
+	return (struct dst_entry *) lookup(net->ipv6.fib6_main_tbl, fl, flags);
 }
 
-static void __init fib6_tables_init(void)
+static void fib6_tables_init(struct net *net)
 {
-	fib6_link_table(fib6_main_tbl);
+	fib6_link_table(net, net->ipv6.fib6_main_tbl);
 }
 
 #endif
@@ -357,11 +353,9 @@ static int inet6_dump_fib(struct sk_buff
 	struct fib6_walker_t *w;
 	struct fib6_table *tb;
 	struct hlist_node *node;
+	struct hlist_head *head;
 	int res = 0;
 
-	if (net != &init_net)
-		return 0;
-
 	s_h = cb->args[0];
 	s_e = cb->args[1];
 
@@ -390,7 +384,8 @@ static int inet6_dump_fib(struct sk_buff
 
 	for (h = s_h; h < FIB_TABLE_HASHSZ; h++, s_e = 0) {
 		e = 0;
-		hlist_for_each_entry(tb, node, &fib_table_hash[h], tb6_hlist) {
+		head = &net->ipv6.fib_table_hash[h];
+		hlist_for_each_entry(tb, node, head, tb6_hlist) {
 			if (e < s_e)
 				goto next;
 			res = fib6_dump_table(tb, skb, cb);
@@ -1360,12 +1355,13 @@ void fib6_clean_all(int (*func)(struct r
 {
 	struct fib6_table *table;
 	struct hlist_node *node;
+	struct hlist_head *head;
 	unsigned int h;
 
 	rcu_read_lock();
 	for (h = 0; h < FIB_TABLE_HASHSZ; h++) {
-		hlist_for_each_entry_rcu(table, node, &fib_table_hash[h],
-					 tb6_hlist) {
+		head = &init_net.ipv6.fib_table_hash[h];
+		hlist_for_each_entry_rcu(table, node, head, tb6_hlist) {
 			write_lock_bh(&table->tb6_lock);
 			fib6_clean_tree(&table->tb6_root, func, prune, arg);
 			write_unlock_bh(&table->tb6_lock);
@@ -1466,55 +1462,88 @@ void fib6_run_gc(unsigned long dummy)
 	spin_unlock_bh(&fib6_gc_lock);
 }
 
-int __init fib6_init(void)
+static int fib6_net_init(struct net *net)
 {
-	int ret = -ENOMEM;
-	fib6_node_kmem = kmem_cache_create("fib6_nodes",
-					   sizeof(struct fib6_node),
-					   0, SLAB_HWCACHE_ALIGN,
-					   NULL);
-	if (!fib6_node_kmem)
-		goto out;
+	int ret;
 
-	fib_table_hash = kzalloc(sizeof(*fib_table_hash)*FIB_TABLE_HASHSZ,
-				 GFP_KERNEL);
-	if (!fib_table_hash)
-		goto out_kmem_cache_create;
+	ret = -ENOMEM;
+	net->ipv6.fib_table_hash =
+		kzalloc(sizeof(*net->ipv6.fib_table_hash)*FIB_TABLE_HASHSZ,
+			GFP_KERNEL);
+	if (!net->ipv6.fib_table_hash)
+		goto out;
 
-	fib6_main_tbl = kzalloc(sizeof(*fib6_main_tbl), GFP_KERNEL);
-	if (!fib6_main_tbl)
+	net->ipv6.fib6_main_tbl = kzalloc(sizeof(*net->ipv6.fib6_main_tbl),
+					  GFP_KERNEL);
+	if (!net->ipv6.fib6_main_tbl)
 		goto out_fib_table_hash;
 
-	fib6_main_tbl->tb6_id = RT6_TABLE_MAIN;
-	fib6_main_tbl->tb6_root.leaf = &ip6_null_entry;
-	fib6_main_tbl->tb6_root.fn_flags = RTN_ROOT | RTN_TL_ROOT | RTN_RTINFO;
+	net->ipv6.fib6_main_tbl->tb6_id = RT6_TABLE_MAIN;
+	net->ipv6.fib6_main_tbl->tb6_root.leaf = &ip6_null_entry;
+	net->ipv6.fib6_main_tbl->tb6_root.fn_flags =
+		RTN_ROOT | RTN_TL_ROOT | RTN_RTINFO;
 
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
-	fib6_local_tbl = kzalloc(sizeof(*fib6_local_tbl), GFP_KERNEL);
-	if (!fib6_local_tbl)
+	net->ipv6.fib6_local_tbl = kzalloc(sizeof(*net->ipv6.fib6_local_tbl),
+					   GFP_KERNEL);
+	if (!net->ipv6.fib6_local_tbl)
 		goto out_fib6_main_tbl;
-
-	fib6_local_tbl->tb6_id = RT6_TABLE_LOCAL;
-	fib6_local_tbl->tb6_root.leaf = &ip6_null_entry;
-	fib6_local_tbl->tb6_root.fn_flags = RTN_ROOT | RTN_TL_ROOT | RTN_RTINFO;
+	net->ipv6.fib6_local_tbl->tb6_id = RT6_TABLE_LOCAL;
+	net->ipv6.fib6_local_tbl->tb6_root.leaf = &ip6_null_entry;
+	net->ipv6.fib6_local_tbl->tb6_root.fn_flags =
+		RTN_ROOT | RTN_TL_ROOT | RTN_RTINFO;
 #endif
+	fib6_tables_init(net);
 
-	fib6_tables_init();
-
-	ret = __rtnl_register(PF_INET6, RTM_GETROUTE, NULL, inet6_dump_fib);
-	if (ret)
-		goto out_fib6_local_tbl;
+	ret = 0;
 out:
 	return ret;
 
-out_fib6_local_tbl:
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
-	kfree(fib6_local_tbl);
 out_fib6_main_tbl:
+	kfree(net->ipv6.fib6_main_tbl);
 #endif
-	kfree(fib6_main_tbl);
 out_fib_table_hash:
-	kfree(fib_table_hash);
+	kfree(net->ipv6.fib_table_hash);
+	goto out;
+ }
+
+static void fib6_net_exit(struct net *net)
+{
+#ifdef CONFIG_IPV6_MULTIPLE_TABLES
+	kfree(net->ipv6.fib6_local_tbl);
+#endif
+	kfree(net->ipv6.fib6_main_tbl);
+	kfree(net->ipv6.fib_table_hash);
+}
+
+static struct pernet_operations fib6_net_ops = {
+	.init = fib6_net_init,
+	.exit = fib6_net_exit,
+};
+
+int __init fib6_init(void)
+{
+	int ret = -ENOMEM;
+	fib6_node_kmem = kmem_cache_create("fib6_nodes",
+					   sizeof(struct fib6_node),
+					   0, SLAB_HWCACHE_ALIGN,
+					   NULL);
+	if (!fib6_node_kmem)
+		goto out;
+
+	ret = register_pernet_subsys(&fib6_net_ops);
+	if (ret)
+		goto out_kmem_cache_create;
+
+	ret = __rtnl_register(PF_INET6, RTM_GETROUTE, NULL, inet6_dump_fib);
+	if (ret)
+		goto out_unregister_subsys;
+out:
+	return ret;
+
+out_unregister_subsys:
+	unregister_pernet_subsys(&fib6_net_ops);
 out_kmem_cache_create:
 	kmem_cache_destroy(fib6_node_kmem);
 	goto out;
@@ -1523,10 +1552,6 @@ out_kmem_cache_create:
 void fib6_gc_cleanup(void)
 {
 	del_timer(&ip6_fib_timer);
-#ifdef CONFIG_IPV6_MULTIPLE_TABLES
-	kfree(fib6_local_tbl);
-#endif
-	kfree(fib6_main_tbl);
-	kfree(fib_table_hash);
+	unregister_pernet_subsys(&fib6_net_ops);
 	kmem_cache_destroy(fib6_node_kmem);
 }
Index: net-2.6.26/net/ipv6/route.c
===================================================================
--- net-2.6.26.orig/net/ipv6/route.c
+++ net-2.6.26/net/ipv6/route.c
@@ -571,7 +571,7 @@ struct rt6_info *rt6_lookup(struct in6_a
 		flags |= RT6_LOOKUP_F_HAS_SADDR;
 	}
 
-	dst = fib6_rule_lookup(&fl, flags, ip6_pol_route_lookup);
+	dst = fib6_rule_lookup(&init_net, &fl, flags, ip6_pol_route_lookup);
 	if (dst->error == 0)
 		return (struct rt6_info *) dst;
 
@@ -758,7 +758,7 @@ void ip6_route_input(struct sk_buff *skb
 	if (rt6_need_strict(&iph->daddr))
 		flags |= RT6_LOOKUP_F_IFACE;
 
-	skb->dst = fib6_rule_lookup(&fl, flags, ip6_pol_route_input);
+	skb->dst = fib6_rule_lookup(&init_net, &fl, flags, ip6_pol_route_input);
 }
 
 static struct rt6_info *ip6_pol_route_output(struct fib6_table *table,
@@ -777,7 +777,7 @@ struct dst_entry * ip6_route_output(stru
 	if (!ipv6_addr_any(&fl->fl6_src))
 		flags |= RT6_LOOKUP_F_HAS_SADDR;
 
-	return fib6_rule_lookup(fl, flags, ip6_pol_route_output);
+	return fib6_rule_lookup(&init_net, fl, flags, ip6_pol_route_output);
 }
 
 EXPORT_SYMBOL(ip6_route_output);
@@ -1070,7 +1070,7 @@ int ip6_route_add(struct fib6_config *cf
 	if (cfg->fc_metric == 0)
 		cfg->fc_metric = IP6_RT_PRIO_USER;
 
-	table = fib6_new_table(cfg->fc_table);
+	table = fib6_new_table(&init_net, cfg->fc_table);
 	if (table == NULL) {
 		err = -ENOBUFS;
 		goto out;
@@ -1276,7 +1276,7 @@ static int ip6_route_del(struct fib6_con
 	struct rt6_info *rt;
 	int err = -ESRCH;
 
-	table = fib6_get_table(cfg->fc_table);
+	table = fib6_get_table(&init_net, cfg->fc_table);
 	if (table == NULL)
 		return err;
 
@@ -1391,7 +1391,9 @@ static struct rt6_info *ip6_route_redire
 	if (rt6_need_strict(dest))
 		flags |= RT6_LOOKUP_F_IFACE;
 
-	return (struct rt6_info *)fib6_rule_lookup((struct flowi *)&rdfl, flags, __ip6_route_redirect);
+	return (struct rt6_info *)fib6_rule_lookup(&init_net,
+						   (struct flowi *)&rdfl,
+						   flags, __ip6_route_redirect);
 }
 
 void rt6_redirect(struct in6_addr *dest, struct in6_addr *src,
@@ -1590,7 +1592,7 @@ static struct rt6_info *rt6_get_route_in
 	struct rt6_info *rt = NULL;
 	struct fib6_table *table;
 
-	table = fib6_get_table(RT6_TABLE_INFO);
+	table = fib6_get_table(&init_net, RT6_TABLE_INFO);
 	if (table == NULL)
 		return NULL;
 
@@ -1645,7 +1647,7 @@ struct rt6_info *rt6_get_dflt_router(str
 	struct rt6_info *rt;
 	struct fib6_table *table;
 
-	table = fib6_get_table(RT6_TABLE_DFLT);
+	table = fib6_get_table(&init_net, RT6_TABLE_DFLT);
 	if (table == NULL)
 		return NULL;
 
@@ -1689,7 +1691,7 @@ void rt6_purge_dflt_routers(void)
 	struct fib6_table *table;
 
 	/* NOTE: Keep consistent with rt6_get_dflt_router */
-	table = fib6_get_table(RT6_TABLE_DFLT);
+	table = fib6_get_table(&init_net, RT6_TABLE_DFLT);
 	if (table == NULL)
 		return;
 
@@ -1852,7 +1854,7 @@ struct rt6_info *addrconf_dst_alloc(stru
 
 	ipv6_addr_copy(&rt->rt6i_dst.addr, addr);
 	rt->rt6i_dst.plen = 128;
-	rt->rt6i_table = fib6_get_table(RT6_TABLE_LOCAL);
+	rt->rt6i_table = fib6_get_table(&init_net, RT6_TABLE_LOCAL);
 
 	atomic_set(&rt->u.dst.__refcnt, 1);
 

-- 
