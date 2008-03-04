From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 08/12][NETNS][IPV6] rt6_info - move rt6_info structure inside the namespace
Date: Tue, 04 Mar 2008 22:03:34 +0100
Message-ID: <20080304211029.031430619@mai.toulouse-stg.fr.ibm.com>
References: <20080304210326.169013927@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:36280 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755134AbYCDVNJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 16:13:09 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id m24LD6B7070562
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 21:13:06 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m24LD6HC2044042
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 22:13:06 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m24LD59w019446
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 21:13:05 GMT
Content-Disposition: inline; filename=rt6-info-entries-per-namespace.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The rt6_info structures are moved inside the network namespace
structure. All references to these structures are now relative
to the initial network namespace.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 include/net/ip6_fib.h    |    3 
 include/net/netns/ipv6.h |    3 
 net/ipv6/addrconf.c      |    9 --
 net/ipv6/fib6_rules.c    |   17 ++-
 net/ipv6/ip6_fib.c       |   45 +++++-----
 net/ipv6/route.c         |  202 ++++++++++++++++++++++++++++++-----------------
 6 files changed, 171 insertions(+), 108 deletions(-)

Index: net-2.6.26/include/net/ip6_fib.h
===================================================================
--- net-2.6.26.orig/include/net/ip6_fib.h
+++ net-2.6.26/include/net/ip6_fib.h
@@ -174,7 +174,8 @@ struct fib6_table {
 #define RT6_TABLE_LOCAL		RT6_TABLE_MAIN
 #endif
 
-typedef struct rt6_info *(*pol_lookup_t)(struct fib6_table *,
+typedef struct rt6_info *(*pol_lookup_t)(struct net *,
+					 struct fib6_table *,
 					 struct flowi *, int);
 
 /*
Index: net-2.6.26/include/net/netns/ipv6.h
===================================================================
--- net-2.6.26.orig/include/net/netns/ipv6.h
+++ net-2.6.26/include/net/netns/ipv6.h
@@ -36,11 +36,14 @@ struct netns_ipv6 {
 	struct xt_table		*ip6table_mangle;
 	struct xt_table		*ip6table_raw;
 #endif
+	struct rt6_info         *ip6_null_entry;
 	struct rt6_statistics   *rt6_stats;
 	struct timer_list       *ip6_fib_timer;
 	struct hlist_head       *fib_table_hash;
 	struct fib6_table       *fib6_main_tbl;
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
+	struct rt6_info         *ip6_prohibit_entry;
+	struct rt6_info         *ip6_blk_hole_entry;
 	struct fib6_table       *fib6_local_tbl;
 	struct fib_rules_ops    *fib6_rules_ops;
 #endif
Index: net-2.6.26/net/ipv6/addrconf.c
===================================================================
--- net-2.6.26.orig/net/ipv6/addrconf.c
+++ net-2.6.26/net/ipv6/addrconf.c
@@ -4301,15 +4301,6 @@ int __init addrconf_init(void)
 	if (err)
 		goto errlo;
 
-	ip6_null_entry->u.dst.dev = init_net.loopback_dev;
-	ip6_null_entry->rt6i_idev = in6_dev_get(init_net.loopback_dev);
-#ifdef CONFIG_IPV6_MULTIPLE_TABLES
-	ip6_prohibit_entry->u.dst.dev = init_net.loopback_dev;
-	ip6_prohibit_entry->rt6i_idev = in6_dev_get(init_net.loopback_dev);
-	ip6_blk_hole_entry->u.dst.dev = init_net.loopback_dev;
-	ip6_blk_hole_entry->rt6i_idev = in6_dev_get(init_net.loopback_dev);
-#endif
-
 	register_netdevice_notifier(&ipv6_dev_notf);
 
 	addrconf_verify(0);
Index: net-2.6.26/net/ipv6/fib6_rules.c
===================================================================
--- net-2.6.26.orig/net/ipv6/fib6_rules.c
+++ net-2.6.26/net/ipv6/fib6_rules.c
@@ -43,8 +43,8 @@ struct dst_entry *fib6_rule_lookup(struc
 	if (arg.result)
 		return arg.result;
 
-	dst_hold(&ip6_null_entry->u.dst);
-	return &ip6_null_entry->u.dst;
+	dst_hold(&net->ipv6.ip6_null_entry->u.dst);
+	return &net->ipv6.ip6_null_entry->u.dst;
 }
 
 static int fib6_rule_action(struct fib_rule *rule, struct flowi *flp,
@@ -52,28 +52,29 @@ static int fib6_rule_action(struct fib_r
 {
 	struct rt6_info *rt = NULL;
 	struct fib6_table *table;
+	struct net *net = rule->fr_net;
 	pol_lookup_t lookup = arg->lookup_ptr;
 
 	switch (rule->action) {
 	case FR_ACT_TO_TBL:
 		break;
 	case FR_ACT_UNREACHABLE:
-		rt = ip6_null_entry;
+		rt = net->ipv6.ip6_null_entry;
 		goto discard_pkt;
 	default:
 	case FR_ACT_BLACKHOLE:
-		rt = ip6_blk_hole_entry;
+		rt = net->ipv6.ip6_blk_hole_entry;
 		goto discard_pkt;
 	case FR_ACT_PROHIBIT:
-		rt = ip6_prohibit_entry;
+		rt = net->ipv6.ip6_prohibit_entry;
 		goto discard_pkt;
 	}
 
-	table = fib6_get_table(rule->fr_net, rule->table);
+	table = fib6_get_table(net, rule->table);
 	if (table)
-		rt = lookup(table, flp, flags);
+		rt = lookup(net, table, flp, flags);
 
-	if (rt != ip6_null_entry) {
+	if (rt != net->ipv6.ip6_null_entry) {
 		struct fib6_rule *r = (struct fib6_rule *)rule;
 
 		/*
Index: net-2.6.26/net/ipv6/ip6_fib.c
===================================================================
--- net-2.6.26.orig/net/ipv6/ip6_fib.c
+++ net-2.6.26/net/ipv6/ip6_fib.c
@@ -79,8 +79,8 @@ static DEFINE_RWLOCK(fib6_walker_lock);
 
 static void fib6_prune_clones(struct net *net, struct fib6_node *fn,
 			      struct rt6_info *rt);
-static struct rt6_info * fib6_find_prefix(struct fib6_node *fn);
-static struct fib6_node * fib6_repair_tree(struct fib6_node *fn);
+static struct rt6_info *fib6_find_prefix(struct net *net, struct fib6_node *fn);
+static struct fib6_node *fib6_repair_tree(struct net *net, struct fib6_node *fn);
 static int fib6_walk(struct fib6_walker_t *w);
 static int fib6_walk_continue(struct fib6_walker_t *w);
 
@@ -193,14 +193,14 @@ static void fib6_link_table(struct net *
 
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 
-static struct fib6_table *fib6_alloc_table(u32 id)
+static struct fib6_table *fib6_alloc_table(struct net *net, u32 id)
 {
 	struct fib6_table *table;
 
 	table = kzalloc(sizeof(*table), GFP_ATOMIC);
 	if (table != NULL) {
 		table->tb6_id = id;
-		table->tb6_root.leaf = ip6_null_entry;
+		table->tb6_root.leaf = net->ipv6.ip6_null_entry;
 		table->tb6_root.fn_flags = RTN_ROOT | RTN_TL_ROOT | RTN_RTINFO;
 	}
 
@@ -217,7 +217,7 @@ struct fib6_table *fib6_new_table(struct
 	if (tb)
 		return tb;
 
-	tb = fib6_alloc_table(id);
+	tb = fib6_alloc_table(net, id);
 	if (tb != NULL)
 		fib6_link_table(net, tb);
 
@@ -267,7 +267,7 @@ struct fib6_table *fib6_get_table(struct
 struct dst_entry *fib6_rule_lookup(struct net *net, struct flowi *fl,
 				   int flags, pol_lookup_t lookup)
 {
-	return (struct dst_entry *) lookup(net->ipv6.fib6_main_tbl, fl, flags);
+	return (struct dst_entry *) lookup(net, net->ipv6.fib6_main_tbl, fl, flags);
 }
 
 static void fib6_tables_init(struct net *net)
@@ -717,8 +717,8 @@ int fib6_add(struct fib6_node *root, str
 			if (sfn == NULL)
 				goto st_failure;
 
-			sfn->leaf = ip6_null_entry;
-			atomic_inc(&ip6_null_entry->rt6i_ref);
+			sfn->leaf = info->nl_net->ipv6.ip6_null_entry;
+			atomic_inc(&info->nl_net->ipv6.ip6_null_entry->rt6i_ref);
 			sfn->fn_flags = RTN_ROOT;
 			sfn->fn_sernum = fib6_new_sernum();
 
@@ -773,11 +773,11 @@ out:
 		 * super-tree leaf node we have to find a new one for it.
 		 */
 		if (pn != fn && !pn->leaf && !(pn->fn_flags & RTN_RTINFO)) {
-			pn->leaf = fib6_find_prefix(pn);
+			pn->leaf = fib6_find_prefix(info->nl_net, pn);
 #if RT6_DEBUG >= 2
 			if (!pn->leaf) {
 				BUG_TRAP(pn->leaf != NULL);
-				pn->leaf = ip6_null_entry;
+				pn->leaf = info->nl_net->ipv6.ip6_null_entry;
 			}
 #endif
 			atomic_inc(&pn->leaf->rt6i_ref);
@@ -793,7 +793,7 @@ out:
 	 */
 st_failure:
 	if (fn && !(fn->fn_flags & (RTN_RTINFO|RTN_ROOT)))
-		fib6_repair_tree(fn);
+		fib6_repair_tree(info->nl_net, fn);
 	dst_free(&rt->u.dst);
 	return err;
 #endif
@@ -959,10 +959,10 @@ struct fib6_node * fib6_locate(struct fi
  *
  */
 
-static struct rt6_info * fib6_find_prefix(struct fib6_node *fn)
+static struct rt6_info *fib6_find_prefix(struct net *net, struct fib6_node *fn)
 {
 	if (fn->fn_flags&RTN_ROOT)
-		return ip6_null_entry;
+		return net->ipv6.ip6_null_entry;
 
 	while(fn) {
 		if(fn->left)
@@ -981,7 +981,8 @@ static struct rt6_info * fib6_find_prefi
  *	is the node we want to try and remove.
  */
 
-static struct fib6_node * fib6_repair_tree(struct fib6_node *fn)
+static struct fib6_node *fib6_repair_tree(struct net *net,
+					   struct fib6_node *fn)
 {
 	int children;
 	int nstate;
@@ -1008,11 +1009,11 @@ static struct fib6_node * fib6_repair_tr
 		    || (children && fn->fn_flags&RTN_ROOT)
 #endif
 		    ) {
-			fn->leaf = fib6_find_prefix(fn);
+			fn->leaf = fib6_find_prefix(net, fn);
 #if RT6_DEBUG >= 2
 			if (fn->leaf==NULL) {
 				BUG_TRAP(fn->leaf);
-				fn->leaf = ip6_null_entry;
+				fn->leaf = net->ipv6.ip6_null_entry;
 			}
 #endif
 			atomic_inc(&fn->leaf->rt6i_ref);
@@ -1117,7 +1118,7 @@ static void fib6_del_route(struct fib6_n
 	if (fn->leaf == NULL) {
 		fn->fn_flags &= ~RTN_RTINFO;
 		net->ipv6.rt6_stats->fib_route_nodes--;
-		fn = fib6_repair_tree(fn);
+		fn = fib6_repair_tree(net, fn);
 	}
 
 	if (atomic_read(&rt->rt6i_ref) != 1) {
@@ -1129,7 +1130,7 @@ static void fib6_del_route(struct fib6_n
 		 */
 		while (fn) {
 			if (!(fn->fn_flags&RTN_RTINFO) && fn->leaf == rt) {
-				fn->leaf = fib6_find_prefix(fn);
+				fn->leaf = fib6_find_prefix(net, fn);
 				atomic_inc(&fn->leaf->rt6i_ref);
 				rt6_release(rt);
 			}
@@ -1145,6 +1146,7 @@ static void fib6_del_route(struct fib6_n
 
 int fib6_del(struct rt6_info *rt, struct nl_info *info)
 {
+	struct net *net = info->nl_net;
 	struct fib6_node *fn = rt->rt6i_node;
 	struct rt6_info **rtp;
 
@@ -1154,7 +1156,7 @@ int fib6_del(struct rt6_info *rt, struct
 		return -ENOENT;
 	}
 #endif
-	if (fn == NULL || rt == ip6_null_entry)
+	if (fn == NULL || rt == net->ipv6.ip6_null_entry)
 		return -ENOENT;
 
 	BUG_TRAP(fn->fn_flags&RTN_RTINFO);
@@ -1501,7 +1503,7 @@ static int fib6_net_init(struct net *net
 		goto out_fib_table_hash;
 
 	net->ipv6.fib6_main_tbl->tb6_id = RT6_TABLE_MAIN;
-	net->ipv6.fib6_main_tbl->tb6_root.leaf = ip6_null_entry;
+	net->ipv6.fib6_main_tbl->tb6_root.leaf = net->ipv6.ip6_null_entry;
 	net->ipv6.fib6_main_tbl->tb6_root.fn_flags =
 		RTN_ROOT | RTN_TL_ROOT | RTN_RTINFO;
 
@@ -1511,7 +1513,7 @@ static int fib6_net_init(struct net *net
 	if (!net->ipv6.fib6_local_tbl)
 		goto out_fib6_main_tbl;
 	net->ipv6.fib6_local_tbl->tb6_id = RT6_TABLE_LOCAL;
-	net->ipv6.fib6_local_tbl->tb6_root.leaf = ip6_null_entry;
+	net->ipv6.fib6_local_tbl->tb6_root.leaf = net->ipv6.ip6_null_entry;
 	net->ipv6.fib6_local_tbl->tb6_root.fn_flags =
 		RTN_ROOT | RTN_TL_ROOT | RTN_RTINFO;
 #endif
@@ -1536,6 +1538,7 @@ out_timer:
 
 static void fib6_net_exit(struct net *net)
 {
+	rt6_ifdown(net, NULL);
 	del_timer(net->ipv6.ip6_fib_timer);
 	kfree(net->ipv6.ip6_fib_timer);
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
Index: net-2.6.26/net/ipv6/route.c
===================================================================
--- net-2.6.26.orig/net/ipv6/route.c
+++ net-2.6.26/net/ipv6/route.c
@@ -145,8 +145,6 @@ static struct rt6_info ip6_null_entry_te
 	.rt6i_ref	= ATOMIC_INIT(1),
 };
 
-struct rt6_info *ip6_null_entry;
-
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 
 static int ip6_pkt_prohibit(struct sk_buff *skb);
@@ -170,8 +168,6 @@ struct rt6_info ip6_prohibit_entry_templ
 	.rt6i_ref	= ATOMIC_INIT(1),
 };
 
-struct rt6_info *ip6_prohibit_entry;
-
 static struct rt6_info ip6_blk_hole_entry_template = {
 	.u = {
 		.dst = {
@@ -190,8 +186,6 @@ static struct rt6_info ip6_blk_hole_entr
 	.rt6i_ref	= ATOMIC_INIT(1),
 };
 
-struct rt6_info *ip6_blk_hole_entry;
-
 #endif
 
 /* allocate dst with ip6_dst_ops */
@@ -245,7 +239,8 @@ static inline int rt6_need_strict(struct
  *	Route lookup. Any table->tb6_lock is implied.
  */
 
-static __inline__ struct rt6_info *rt6_device_match(struct rt6_info *rt,
+static inline struct rt6_info *rt6_device_match(struct net *net,
+						    struct rt6_info *rt,
 						    int oif,
 						    int strict)
 {
@@ -274,7 +269,7 @@ static __inline__ struct rt6_info *rt6_d
 			return local;
 
 		if (strict)
-			return ip6_null_entry;
+			return net->ipv6.ip6_null_entry;
 	}
 	return rt;
 }
@@ -415,6 +410,7 @@ static struct rt6_info *find_rr_leaf(str
 static struct rt6_info *rt6_select(struct fib6_node *fn, int oif, int strict)
 {
 	struct rt6_info *match, *rt0;
+	struct net *net;
 
 	RT6_TRACE("%s(fn->leaf=%p, oif=%d)\n",
 		  __FUNCTION__, fn->leaf, oif);
@@ -440,7 +436,8 @@ static struct rt6_info *rt6_select(struc
 	RT6_TRACE("%s() => %p\n",
 		  __FUNCTION__, match);
 
-	return (match ? match : ip6_null_entry);
+	net = rt0->rt6i_dev->nd_net;
+	return (match ? match : net->ipv6.ip6_null_entry);
 }
 
 #ifdef CONFIG_IPV6_ROUTE_INFO
@@ -523,9 +520,9 @@ int rt6_route_rcv(struct net_device *dev
 }
 #endif
 
-#define BACKTRACK(saddr) \
+#define BACKTRACK(__net, saddr)			\
 do { \
-	if (rt == ip6_null_entry) { \
+	if (rt == __net->ipv6.ip6_null_entry) {	\
 		struct fib6_node *pn; \
 		while (1) { \
 			if (fn->fn_flags & RTN_TL_ROOT) \
@@ -541,7 +538,8 @@ do { \
 	} \
 } while(0)
 
-static struct rt6_info *ip6_pol_route_lookup(struct fib6_table *table,
+static struct rt6_info *ip6_pol_route_lookup(struct net *net,
+					     struct fib6_table *table,
 					     struct flowi *fl, int flags)
 {
 	struct fib6_node *fn;
@@ -551,8 +549,8 @@ static struct rt6_info *ip6_pol_route_lo
 	fn = fib6_lookup(&table->tb6_root, &fl->fl6_dst, &fl->fl6_src);
 restart:
 	rt = fn->leaf;
-	rt = rt6_device_match(rt, fl->oif, flags);
-	BACKTRACK(&fl->fl6_src);
+	rt = rt6_device_match(net, rt, fl->oif, flags);
+	BACKTRACK(net, &fl->fl6_src);
 out:
 	dst_use(&rt->u.dst, jiffies);
 	read_unlock_bh(&table->tb6_lock);
@@ -668,8 +666,8 @@ static struct rt6_info *rt6_alloc_clone(
 	return rt;
 }
 
-static struct rt6_info *ip6_pol_route(struct fib6_table *table, int oif,
-					    struct flowi *fl, int flags)
+static struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table, int oif,
+				      struct flowi *fl, int flags)
 {
 	struct fib6_node *fn;
 	struct rt6_info *rt, *nrt;
@@ -688,8 +686,9 @@ restart_2:
 
 restart:
 	rt = rt6_select(fn, oif, strict | reachable);
-	BACKTRACK(&fl->fl6_src);
-	if (rt == ip6_null_entry ||
+
+	BACKTRACK(net, &fl->fl6_src);
+	if (rt == net->ipv6.ip6_null_entry ||
 	    rt->rt6i_flags & RTF_CACHE)
 		goto out;
 
@@ -707,7 +706,7 @@ restart:
 	}
 
 	dst_release(&rt->u.dst);
-	rt = nrt ? : ip6_null_entry;
+	rt = nrt ? : net->ipv6.ip6_null_entry;
 
 	dst_hold(&rt->u.dst);
 	if (nrt) {
@@ -740,10 +739,10 @@ out2:
 	return rt;
 }
 
-static struct rt6_info *ip6_pol_route_input(struct fib6_table *table,
+static struct rt6_info *ip6_pol_route_input(struct net *net, struct fib6_table *table,
 					    struct flowi *fl, int flags)
 {
-	return ip6_pol_route(table, fl->iif, fl, flags);
+	return ip6_pol_route(net, table, fl->iif, fl, flags);
 }
 
 void ip6_route_input(struct sk_buff *skb)
@@ -770,10 +769,10 @@ void ip6_route_input(struct sk_buff *skb
 	skb->dst = fib6_rule_lookup(net, &fl, flags, ip6_pol_route_input);
 }
 
-static struct rt6_info *ip6_pol_route_output(struct fib6_table *table,
+static struct rt6_info *ip6_pol_route_output(struct net *net, struct fib6_table *table,
 					     struct flowi *fl, int flags)
 {
-	return ip6_pol_route(table, fl->oif, fl, flags);
+	return ip6_pol_route(net, table, fl->oif, fl, flags);
 }
 
 struct dst_entry * ip6_route_output(struct sock *sk, struct flowi *fl)
@@ -1259,8 +1258,9 @@ static int __ip6_del_rt(struct rt6_info 
 {
 	int err;
 	struct fib6_table *table;
+	struct net *net = rt->rt6i_dev->nd_net;
 
-	if (rt == ip6_null_entry)
+	if (rt == net->ipv6.ip6_null_entry)
 		return -ENOENT;
 
 	table = rt->rt6i_table;
@@ -1329,7 +1329,8 @@ struct ip6rd_flowi {
 	struct in6_addr gateway;
 };
 
-static struct rt6_info *__ip6_route_redirect(struct fib6_table *table,
+static struct rt6_info *__ip6_route_redirect(struct net *net,
+					     struct fib6_table *table,
 					     struct flowi *fl,
 					     int flags)
 {
@@ -1372,8 +1373,8 @@ restart:
 	}
 
 	if (!rt)
-		rt = ip6_null_entry;
-	BACKTRACK(&fl->fl6_src);
+		rt = net->ipv6.ip6_null_entry;
+	BACKTRACK(net, &fl->fl6_src);
 out:
 	dst_hold(&rt->u.dst);
 
@@ -1415,10 +1416,11 @@ void rt6_redirect(struct in6_addr *dest,
 {
 	struct rt6_info *rt, *nrt = NULL;
 	struct netevent_redirect netevent;
+	struct net *net = neigh->dev->nd_net;
 
 	rt = ip6_route_redirect(dest, src, saddr, neigh->dev);
 
-	if (rt == ip6_null_entry) {
+	if (rt == net->ipv6.ip6_null_entry) {
 		if (net_ratelimit())
 			printk(KERN_DEBUG "rt6_redirect: source isn't a valid nexthop "
 			       "for redirect target\n");
@@ -1886,10 +1888,18 @@ struct rt6_info *addrconf_dst_alloc(stru
 	return rt;
 }
 
+struct arg_dev_net {
+	struct net_device *dev;
+	struct net *net;
+};
+
 static int fib6_ifdown(struct rt6_info *rt, void *arg)
 {
-	if (((void*)rt->rt6i_dev == arg || arg == NULL) &&
-	    rt != ip6_null_entry) {
+	struct net_device *dev = ((struct arg_dev_net *)arg)->dev;
+	struct net *net = ((struct arg_dev_net *)arg)->net;
+
+	if (((void *)rt->rt6i_dev == dev || dev == NULL) &&
+	    rt != net->ipv6.ip6_null_entry) {
 		RT6_TRACE("deleted by ifdown %p\n", rt);
 		return -1;
 	}
@@ -1898,7 +1908,12 @@ static int fib6_ifdown(struct rt6_info *
 
 void rt6_ifdown(struct net *net, struct net_device *dev)
 {
-	fib6_clean_all(net, fib6_ifdown, 0, dev);
+	struct arg_dev_net adn = {
+		.dev = dev,
+		.net = net,
+	};
+
+	fib6_clean_all(net, fib6_ifdown, 0, &adn);
 }
 
 struct rt6_mtu_change_arg
@@ -2289,6 +2304,26 @@ errout:
 		rtnl_set_sk_err(net, RTNLGRP_IPV6_ROUTE, err);
 }
 
+static int ip6_route_dev_notify(struct notifier_block *this,
+				unsigned long event, void *data)
+{
+	struct net_device *dev = (struct net_device *)data;
+	struct net *net = dev->nd_net;
+
+	if (event == NETDEV_REGISTER && (dev->flags & IFF_LOOPBACK)) {
+		net->ipv6.ip6_null_entry->u.dst.dev = dev;
+		net->ipv6.ip6_null_entry->rt6i_idev = in6_dev_get(dev);
+#ifdef CONFIG_IPV6_MULTIPLE_TABLES
+		net->ipv6.ip6_prohibit_entry->u.dst.dev = dev;
+		net->ipv6.ip6_prohibit_entry->rt6i_idev = in6_dev_get(dev);
+		net->ipv6.ip6_blk_hole_entry->u.dst.dev = dev;
+		net->ipv6.ip6_blk_hole_entry->rt6i_idev = in6_dev_get(dev);
+#endif
+	}
+
+	return NOTIFY_OK;
+}
+
 /*
  *	/proc
  */
@@ -2535,11 +2570,47 @@ struct ctl_table *ipv6_route_sysctl_init
 
 static int ip6_route_net_init(struct net *net)
 {
+	int ret = 0;
+
+	ret = -ENOMEM;
+	net->ipv6.ip6_null_entry = kmemdup(&ip6_null_entry_template,
+					   sizeof(*net->ipv6.ip6_null_entry),
+					   GFP_KERNEL);
+	if (!net->ipv6.ip6_null_entry)
+		goto out;
+	net->ipv6.ip6_null_entry->u.dst.path =
+		(struct dst_entry *)net->ipv6.ip6_null_entry;
+
+#ifdef CONFIG_IPV6_MULTIPLE_TABLES
+	net->ipv6.ip6_prohibit_entry = kmemdup(&ip6_prohibit_entry_template,
+					       sizeof(*net->ipv6.ip6_prohibit_entry),
+					       GFP_KERNEL);
+	if (!net->ipv6.ip6_prohibit_entry) {
+		kfree(net->ipv6.ip6_null_entry);
+		goto out;
+	}
+	net->ipv6.ip6_prohibit_entry->u.dst.path =
+		(struct dst_entry *)net->ipv6.ip6_prohibit_entry;
+
+	net->ipv6.ip6_blk_hole_entry = kmemdup(&ip6_blk_hole_entry_template,
+					       sizeof(*net->ipv6.ip6_blk_hole_entry),
+					       GFP_KERNEL);
+	if (!net->ipv6.ip6_blk_hole_entry) {
+		kfree(net->ipv6.ip6_null_entry);
+		kfree(net->ipv6.ip6_prohibit_entry);
+		goto out;
+	}
+	net->ipv6.ip6_blk_hole_entry->u.dst.path =
+		(struct dst_entry *)net->ipv6.ip6_blk_hole_entry;
+#endif
+
 #ifdef CONFIG_PROC_FS
 	proc_net_fops_create(net, "ipv6_route", 0, &ipv6_route_proc_fops);
 	proc_net_fops_create(net, "rt6_stats", S_IRUGO, &rt6_stats_seq_fops);
 #endif
-	return 0;
+	ret = 0;
+out:
+	return ret;
 }
 
 static void ip6_route_net_exit(struct net *net)
@@ -2548,7 +2619,11 @@ static void ip6_route_net_exit(struct ne
 	proc_net_remove(net, "ipv6_route");
 	proc_net_remove(net, "rt6_stats");
 #endif
-	rt6_ifdown(net, NULL);
+	kfree(net->ipv6.ip6_null_entry);
+#ifdef CONFIG_IPV6_MULTIPLE_TABLES
+	kfree(net->ipv6.ip6_prohibit_entry);
+	kfree(net->ipv6.ip6_blk_hole_entry);
+#endif
 }
 
 static struct pernet_operations ip6_route_net_ops = {
@@ -2556,6 +2631,11 @@ static struct pernet_operations ip6_rout
 	.exit = ip6_route_net_exit,
 };
 
+static struct notifier_block ip6_route_dev_notifier = {
+	.notifier_call = ip6_route_dev_notify,
+	.priority = 0,
+};
+
 int __init ip6_route_init(void)
 {
 	int ret;
@@ -2568,30 +2648,24 @@ int __init ip6_route_init(void)
 
 	ip6_dst_blackhole_ops.kmem_cachep = ip6_dst_ops.kmem_cachep;
 
-	ret = -ENOMEM;
-	ip6_null_entry = kmemdup(&ip6_null_entry_template,
-				 sizeof(*ip6_null_entry), GFP_KERNEL);
-	if (!ip6_null_entry)
+	ret = register_pernet_subsys(&ip6_route_net_ops);
+	if (ret)
 		goto out_kmem_cache;
-	ip6_null_entry->u.dst.path = (struct dst_entry *)ip6_null_entry;
-
-#ifdef CONFIG_IPV6_MULTIPLE_TABLES
-	ip6_prohibit_entry = kmemdup(&ip6_prohibit_entry_template,
-				     sizeof(*ip6_prohibit_entry), GFP_KERNEL);
-	if (!ip6_prohibit_entry)
-		goto out_ip6_null_entry;
-	ip6_prohibit_entry->u.dst.path = (struct dst_entry *)ip6_prohibit_entry;
-
-	ip6_blk_hole_entry = kmemdup(&ip6_blk_hole_entry_template,
-				     sizeof(*ip6_blk_hole_entry), GFP_KERNEL);
-	if (!ip6_blk_hole_entry)
-		goto out_ip6_prohibit_entry;
-	ip6_blk_hole_entry->u.dst.path = (struct dst_entry *)ip6_blk_hole_entry;
-#endif
 
+	/* Registering of the loopback is done before this portion of code,
+	 * the loopback reference in rt6_info will not be taken, do it
+	 * manually for init_net */
+	init_net.ipv6.ip6_null_entry->u.dst.dev = init_net.loopback_dev;
+	init_net.ipv6.ip6_null_entry->rt6i_idev = in6_dev_get(init_net.loopback_dev);
+  #ifdef CONFIG_IPV6_MULTIPLE_TABLES
+	init_net.ipv6.ip6_prohibit_entry->u.dst.dev = init_net.loopback_dev;
+	init_net.ipv6.ip6_prohibit_entry->rt6i_idev = in6_dev_get(init_net.loopback_dev);
+	init_net.ipv6.ip6_blk_hole_entry->u.dst.dev = init_net.loopback_dev;
+	init_net.ipv6.ip6_blk_hole_entry->rt6i_idev = in6_dev_get(init_net.loopback_dev);
+  #endif
 	ret = fib6_init();
 	if (ret)
-		goto out_ip6_blk_hole_entry;
+		goto out_register_subsys;
 
 	ret = xfrm6_init();
 	if (ret)
@@ -2607,9 +2681,10 @@ int __init ip6_route_init(void)
 	    __rtnl_register(PF_INET6, RTM_GETROUTE, inet6_rtm_getroute, NULL))
 		goto fib6_rules_init;
 
-	ret = register_pernet_subsys(&ip6_route_net_ops);
+	ret = register_netdevice_notifier(&ip6_route_dev_notifier);
 	if (ret)
 		goto fib6_rules_init;
+
 out:
 	return ret;
 
@@ -2619,14 +2694,8 @@ xfrm6_init:
 	xfrm6_fini();
 out_fib6_init:
 	fib6_gc_cleanup();
-out_ip6_blk_hole_entry:
-#ifdef CONFIG_IPV6_MULTIPLE_TABLES
-	kfree(ip6_blk_hole_entry);
-out_ip6_prohibit_entry:
-	kfree(ip6_prohibit_entry);
-out_ip6_null_entry:
-#endif
-	kfree(ip6_null_entry);
+out_register_subsys:
+	unregister_pernet_subsys(&ip6_route_net_ops);
 out_kmem_cache:
 	kmem_cache_destroy(ip6_dst_ops.kmem_cachep);
 	goto out;
@@ -2634,15 +2703,10 @@ out_kmem_cache:
 
 void ip6_route_cleanup(void)
 {
-	unregister_pernet_subsys(&ip6_route_net_ops);
+	unregister_netdevice_notifier(&ip6_route_dev_notifier);
 	fib6_rules_cleanup();
 	xfrm6_fini();
 	fib6_gc_cleanup();
+	unregister_pernet_subsys(&ip6_route_net_ops);
 	kmem_cache_destroy(ip6_dst_ops.kmem_cachep);
-
-	kfree(ip6_null_entry);
-#ifdef CONFIG_IPV6_MULTIPLE_TABLES
-	kfree(ip6_prohibit_entry);
-	kfree(ip6_blk_hole_entry);
-#endif
 }

-- 
