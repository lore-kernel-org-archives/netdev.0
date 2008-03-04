From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 07/12][NETNS][IPV6] rt6_info - make rt6_info accessed as a pointer
Date: Tue, 04 Mar 2008 22:03:33 +0100
Message-ID: <20080304211026.524539229@mai.toulouse-stg.fr.ibm.com>
References: <20080304210326.169013927@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:35484 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754423AbYCDVNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 16:13:04 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id m24LD3Rx357296
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 21:13:03 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m24LD30J2056422
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 22:13:03 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m24LD2vO014912
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 21:13:03 GMT
Content-Disposition: inline; filename=rt6-info-entries-dynamic-allocation.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch make mindless changes and prepares the code to use dynamic 
allocation  for rt6_info structure. The code accesses the rt6_info
structure as a pointer instead of a global static variable.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 include/net/ip6_route.h |    6 ++--
 net/ipv6/addrconf.c     |   12 ++++----
 net/ipv6/fib6_rules.c   |   12 ++++----
 net/ipv6/ip6_fib.c      |   18 ++++++------
 net/ipv6/route.c        |   70 +++++++++++++++++++++++++++++++++++++-----------
 5 files changed, 78 insertions(+), 40 deletions(-)

Index: net-2.6.26/include/net/ip6_route.h
===================================================================
--- net-2.6.26.orig/include/net/ip6_route.h
+++ net-2.6.26/include/net/ip6_route.h
@@ -34,11 +34,11 @@ struct route_info {
 #define RT6_LOOKUP_F_REACHABLE	0x2
 #define RT6_LOOKUP_F_HAS_SADDR	0x4
 
-extern struct rt6_info	ip6_null_entry;
+extern struct rt6_info	*ip6_null_entry;
 
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
-extern struct rt6_info	ip6_prohibit_entry;
-extern struct rt6_info	ip6_blk_hole_entry;
+extern struct rt6_info	*ip6_prohibit_entry;
+extern struct rt6_info	*ip6_blk_hole_entry;
 #endif
 
 extern void			ip6_route_input(struct sk_buff *skb);
Index: net-2.6.26/net/ipv6/addrconf.c
===================================================================
--- net-2.6.26.orig/net/ipv6/addrconf.c
+++ net-2.6.26/net/ipv6/addrconf.c
@@ -4301,13 +4301,13 @@ int __init addrconf_init(void)
 	if (err)
 		goto errlo;
 
-	ip6_null_entry.u.dst.dev = init_net.loopback_dev;
-	ip6_null_entry.rt6i_idev = in6_dev_get(init_net.loopback_dev);
+	ip6_null_entry->u.dst.dev = init_net.loopback_dev;
+	ip6_null_entry->rt6i_idev = in6_dev_get(init_net.loopback_dev);
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
-	ip6_prohibit_entry.u.dst.dev = init_net.loopback_dev;
-	ip6_prohibit_entry.rt6i_idev = in6_dev_get(init_net.loopback_dev);
-	ip6_blk_hole_entry.u.dst.dev = init_net.loopback_dev;
-	ip6_blk_hole_entry.rt6i_idev = in6_dev_get(init_net.loopback_dev);
+	ip6_prohibit_entry->u.dst.dev = init_net.loopback_dev;
+	ip6_prohibit_entry->rt6i_idev = in6_dev_get(init_net.loopback_dev);
+	ip6_blk_hole_entry->u.dst.dev = init_net.loopback_dev;
+	ip6_blk_hole_entry->rt6i_idev = in6_dev_get(init_net.loopback_dev);
 #endif
 
 	register_netdevice_notifier(&ipv6_dev_notf);
Index: net-2.6.26/net/ipv6/fib6_rules.c
===================================================================
--- net-2.6.26.orig/net/ipv6/fib6_rules.c
+++ net-2.6.26/net/ipv6/fib6_rules.c
@@ -43,8 +43,8 @@ struct dst_entry *fib6_rule_lookup(struc
 	if (arg.result)
 		return arg.result;
 
-	dst_hold(&ip6_null_entry.u.dst);
-	return &ip6_null_entry.u.dst;
+	dst_hold(&ip6_null_entry->u.dst);
+	return &ip6_null_entry->u.dst;
 }
 
 static int fib6_rule_action(struct fib_rule *rule, struct flowi *flp,
@@ -58,14 +58,14 @@ static int fib6_rule_action(struct fib_r
 	case FR_ACT_TO_TBL:
 		break;
 	case FR_ACT_UNREACHABLE:
-		rt = &ip6_null_entry;
+		rt = ip6_null_entry;
 		goto discard_pkt;
 	default:
 	case FR_ACT_BLACKHOLE:
-		rt = &ip6_blk_hole_entry;
+		rt = ip6_blk_hole_entry;
 		goto discard_pkt;
 	case FR_ACT_PROHIBIT:
-		rt = &ip6_prohibit_entry;
+		rt = ip6_prohibit_entry;
 		goto discard_pkt;
 	}
 
@@ -73,7 +73,7 @@ static int fib6_rule_action(struct fib_r
 	if (table)
 		rt = lookup(table, flp, flags);
 
-	if (rt != &ip6_null_entry) {
+	if (rt != ip6_null_entry) {
 		struct fib6_rule *r = (struct fib6_rule *)rule;
 
 		/*
Index: net-2.6.26/net/ipv6/ip6_fib.c
===================================================================
--- net-2.6.26.orig/net/ipv6/ip6_fib.c
+++ net-2.6.26/net/ipv6/ip6_fib.c
@@ -200,7 +200,7 @@ static struct fib6_table *fib6_alloc_tab
 	table = kzalloc(sizeof(*table), GFP_ATOMIC);
 	if (table != NULL) {
 		table->tb6_id = id;
-		table->tb6_root.leaf = &ip6_null_entry;
+		table->tb6_root.leaf = ip6_null_entry;
 		table->tb6_root.fn_flags = RTN_ROOT | RTN_TL_ROOT | RTN_RTINFO;
 	}
 
@@ -717,8 +717,8 @@ int fib6_add(struct fib6_node *root, str
 			if (sfn == NULL)
 				goto st_failure;
 
-			sfn->leaf = &ip6_null_entry;
-			atomic_inc(&ip6_null_entry.rt6i_ref);
+			sfn->leaf = ip6_null_entry;
+			atomic_inc(&ip6_null_entry->rt6i_ref);
 			sfn->fn_flags = RTN_ROOT;
 			sfn->fn_sernum = fib6_new_sernum();
 
@@ -777,7 +777,7 @@ out:
 #if RT6_DEBUG >= 2
 			if (!pn->leaf) {
 				BUG_TRAP(pn->leaf != NULL);
-				pn->leaf = &ip6_null_entry;
+				pn->leaf = ip6_null_entry;
 			}
 #endif
 			atomic_inc(&pn->leaf->rt6i_ref);
@@ -962,7 +962,7 @@ struct fib6_node * fib6_locate(struct fi
 static struct rt6_info * fib6_find_prefix(struct fib6_node *fn)
 {
 	if (fn->fn_flags&RTN_ROOT)
-		return &ip6_null_entry;
+		return ip6_null_entry;
 
 	while(fn) {
 		if(fn->left)
@@ -1012,7 +1012,7 @@ static struct fib6_node * fib6_repair_tr
 #if RT6_DEBUG >= 2
 			if (fn->leaf==NULL) {
 				BUG_TRAP(fn->leaf);
-				fn->leaf = &ip6_null_entry;
+				fn->leaf = ip6_null_entry;
 			}
 #endif
 			atomic_inc(&fn->leaf->rt6i_ref);
@@ -1154,7 +1154,7 @@ int fib6_del(struct rt6_info *rt, struct
 		return -ENOENT;
 	}
 #endif
-	if (fn == NULL || rt == &ip6_null_entry)
+	if (fn == NULL || rt == ip6_null_entry)
 		return -ENOENT;
 
 	BUG_TRAP(fn->fn_flags&RTN_RTINFO);
@@ -1501,7 +1501,7 @@ static int fib6_net_init(struct net *net
 		goto out_fib_table_hash;
 
 	net->ipv6.fib6_main_tbl->tb6_id = RT6_TABLE_MAIN;
-	net->ipv6.fib6_main_tbl->tb6_root.leaf = &ip6_null_entry;
+	net->ipv6.fib6_main_tbl->tb6_root.leaf = ip6_null_entry;
 	net->ipv6.fib6_main_tbl->tb6_root.fn_flags =
 		RTN_ROOT | RTN_TL_ROOT | RTN_RTINFO;
 
@@ -1511,7 +1511,7 @@ static int fib6_net_init(struct net *net
 	if (!net->ipv6.fib6_local_tbl)
 		goto out_fib6_main_tbl;
 	net->ipv6.fib6_local_tbl->tb6_id = RT6_TABLE_LOCAL;
-	net->ipv6.fib6_local_tbl->tb6_root.leaf = &ip6_null_entry;
+	net->ipv6.fib6_local_tbl->tb6_root.leaf = ip6_null_entry;
 	net->ipv6.fib6_local_tbl->tb6_root.fn_flags =
 		RTN_ROOT | RTN_TL_ROOT | RTN_RTINFO;
 #endif
Index: net-2.6.26/net/ipv6/route.c
===================================================================
--- net-2.6.26.orig/net/ipv6/route.c
+++ net-2.6.26/net/ipv6/route.c
@@ -127,7 +127,7 @@ static struct dst_ops ip6_dst_blackhole_
 	.entries		=	ATOMIC_INIT(0),
 };
 
-struct rt6_info ip6_null_entry = {
+static struct rt6_info ip6_null_entry_template = {
 	.u = {
 		.dst = {
 			.__refcnt	= ATOMIC_INIT(1),
@@ -138,7 +138,6 @@ struct rt6_info ip6_null_entry = {
 			.input		= ip6_pkt_discard,
 			.output		= ip6_pkt_discard_out,
 			.ops		= &ip6_dst_ops,
-			.path		= (struct dst_entry*)&ip6_null_entry,
 		}
 	},
 	.rt6i_flags	= (RTF_REJECT | RTF_NONEXTHOP),
@@ -146,12 +145,14 @@ struct rt6_info ip6_null_entry = {
 	.rt6i_ref	= ATOMIC_INIT(1),
 };
 
+struct rt6_info *ip6_null_entry;
+
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 
 static int ip6_pkt_prohibit(struct sk_buff *skb);
 static int ip6_pkt_prohibit_out(struct sk_buff *skb);
 
-struct rt6_info ip6_prohibit_entry = {
+struct rt6_info ip6_prohibit_entry_template = {
 	.u = {
 		.dst = {
 			.__refcnt	= ATOMIC_INIT(1),
@@ -162,7 +163,6 @@ struct rt6_info ip6_prohibit_entry = {
 			.input		= ip6_pkt_prohibit,
 			.output		= ip6_pkt_prohibit_out,
 			.ops		= &ip6_dst_ops,
-			.path		= (struct dst_entry*)&ip6_prohibit_entry,
 		}
 	},
 	.rt6i_flags	= (RTF_REJECT | RTF_NONEXTHOP),
@@ -170,7 +170,9 @@ struct rt6_info ip6_prohibit_entry = {
 	.rt6i_ref	= ATOMIC_INIT(1),
 };
 
-struct rt6_info ip6_blk_hole_entry = {
+struct rt6_info *ip6_prohibit_entry;
+
+static struct rt6_info ip6_blk_hole_entry_template = {
 	.u = {
 		.dst = {
 			.__refcnt	= ATOMIC_INIT(1),
@@ -181,7 +183,6 @@ struct rt6_info ip6_blk_hole_entry = {
 			.input		= dst_discard,
 			.output		= dst_discard,
 			.ops		= &ip6_dst_ops,
-			.path		= (struct dst_entry*)&ip6_blk_hole_entry,
 		}
 	},
 	.rt6i_flags	= (RTF_REJECT | RTF_NONEXTHOP),
@@ -189,6 +190,8 @@ struct rt6_info ip6_blk_hole_entry = {
 	.rt6i_ref	= ATOMIC_INIT(1),
 };
 
+struct rt6_info *ip6_blk_hole_entry;
+
 #endif
 
 /* allocate dst with ip6_dst_ops */
@@ -271,7 +274,7 @@ static __inline__ struct rt6_info *rt6_d
 			return local;
 
 		if (strict)
-			return &ip6_null_entry;
+			return ip6_null_entry;
 	}
 	return rt;
 }
@@ -437,7 +440,7 @@ static struct rt6_info *rt6_select(struc
 	RT6_TRACE("%s() => %p\n",
 		  __FUNCTION__, match);
 
-	return (match ? match : &ip6_null_entry);
+	return (match ? match : ip6_null_entry);
 }
 
 #ifdef CONFIG_IPV6_ROUTE_INFO
@@ -522,7 +525,7 @@ int rt6_route_rcv(struct net_device *dev
 
 #define BACKTRACK(saddr) \
 do { \
-	if (rt == &ip6_null_entry) { \
+	if (rt == ip6_null_entry) { \
 		struct fib6_node *pn; \
 		while (1) { \
 			if (fn->fn_flags & RTN_TL_ROOT) \
@@ -686,7 +689,7 @@ restart_2:
 restart:
 	rt = rt6_select(fn, oif, strict | reachable);
 	BACKTRACK(&fl->fl6_src);
-	if (rt == &ip6_null_entry ||
+	if (rt == ip6_null_entry ||
 	    rt->rt6i_flags & RTF_CACHE)
 		goto out;
 
@@ -704,7 +707,7 @@ restart:
 	}
 
 	dst_release(&rt->u.dst);
-	rt = nrt ? : &ip6_null_entry;
+	rt = nrt ? : ip6_null_entry;
 
 	dst_hold(&rt->u.dst);
 	if (nrt) {
@@ -1257,7 +1260,7 @@ static int __ip6_del_rt(struct rt6_info 
 	int err;
 	struct fib6_table *table;
 
-	if (rt == &ip6_null_entry)
+	if (rt == ip6_null_entry)
 		return -ENOENT;
 
 	table = rt->rt6i_table;
@@ -1369,7 +1372,7 @@ restart:
 	}
 
 	if (!rt)
-		rt = &ip6_null_entry;
+		rt = ip6_null_entry;
 	BACKTRACK(&fl->fl6_src);
 out:
 	dst_hold(&rt->u.dst);
@@ -1415,7 +1418,7 @@ void rt6_redirect(struct in6_addr *dest,
 
 	rt = ip6_route_redirect(dest, src, saddr, neigh->dev);
 
-	if (rt == &ip6_null_entry) {
+	if (rt == ip6_null_entry) {
 		if (net_ratelimit())
 			printk(KERN_DEBUG "rt6_redirect: source isn't a valid nexthop "
 			       "for redirect target\n");
@@ -1886,7 +1889,7 @@ struct rt6_info *addrconf_dst_alloc(stru
 static int fib6_ifdown(struct rt6_info *rt, void *arg)
 {
 	if (((void*)rt->rt6i_dev == arg || arg == NULL) &&
-	    rt != &ip6_null_entry) {
+	    rt != ip6_null_entry) {
 		RT6_TRACE("deleted by ifdown %p\n", rt);
 		return -1;
 	}
@@ -2565,9 +2568,30 @@ int __init ip6_route_init(void)
 
 	ip6_dst_blackhole_ops.kmem_cachep = ip6_dst_ops.kmem_cachep;
 
+	ret = -ENOMEM;
+	ip6_null_entry = kmemdup(&ip6_null_entry_template,
+				 sizeof(*ip6_null_entry), GFP_KERNEL);
+	if (!ip6_null_entry)
+		goto out_kmem_cache;
+	ip6_null_entry->u.dst.path = (struct dst_entry *)ip6_null_entry;
+
+#ifdef CONFIG_IPV6_MULTIPLE_TABLES
+	ip6_prohibit_entry = kmemdup(&ip6_prohibit_entry_template,
+				     sizeof(*ip6_prohibit_entry), GFP_KERNEL);
+	if (!ip6_prohibit_entry)
+		goto out_ip6_null_entry;
+	ip6_prohibit_entry->u.dst.path = (struct dst_entry *)ip6_prohibit_entry;
+
+	ip6_blk_hole_entry = kmemdup(&ip6_blk_hole_entry_template,
+				     sizeof(*ip6_blk_hole_entry), GFP_KERNEL);
+	if (!ip6_blk_hole_entry)
+		goto out_ip6_prohibit_entry;
+	ip6_blk_hole_entry->u.dst.path = (struct dst_entry *)ip6_blk_hole_entry;
+#endif
+
 	ret = fib6_init();
 	if (ret)
-		goto out_kmem_cache;
+		goto out_ip6_blk_hole_entry;
 
 	ret = xfrm6_init();
 	if (ret)
@@ -2595,6 +2619,14 @@ xfrm6_init:
 	xfrm6_fini();
 out_fib6_init:
 	fib6_gc_cleanup();
+out_ip6_blk_hole_entry:
+#ifdef CONFIG_IPV6_MULTIPLE_TABLES
+	kfree(ip6_blk_hole_entry);
+out_ip6_prohibit_entry:
+	kfree(ip6_prohibit_entry);
+out_ip6_null_entry:
+#endif
+	kfree(ip6_null_entry);
 out_kmem_cache:
 	kmem_cache_destroy(ip6_dst_ops.kmem_cachep);
 	goto out;
@@ -2607,4 +2639,10 @@ void ip6_route_cleanup(void)
 	xfrm6_fini();
 	fib6_gc_cleanup();
 	kmem_cache_destroy(ip6_dst_ops.kmem_cachep);
+
+	kfree(ip6_null_entry);
+#ifdef CONFIG_IPV6_MULTIPLE_TABLES
+	kfree(ip6_prohibit_entry);
+	kfree(ip6_blk_hole_entry);
+#endif
 }

-- 
