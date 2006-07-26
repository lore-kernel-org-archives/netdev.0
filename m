From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/5] [IPV6]: Multiple Routing Tables
Date: Thu, 27 Jul 2006 00:00:02 +0200
Message-ID: <20060726221849.495778268@postel.suug.ch>
References: <20060726221100.325687073@postel.suug.ch>
Cc: vnuorval@tcs.hut.fi, usagi-core@linux-ipv6.org,
	yoshfuji@linux-ipv6.org, davem@davemloft.net, anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:21686 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751237AbWGZWUH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 18:20:07 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=ip6_mrt
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adds the framework to support multiple IPv6 routing tables.
Currently all automatically generated routes are put into the
same table. This could be changed at a later point after
considering the produced locking overhead.

When locating routes for redirects only the main table is
searched for now. Since policy rules will not be reversible
it is unclear whether it makes sense to change this.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.git/include/net/ip6_fib.h
===================================================================
--- net-2.6.git.orig/include/net/ip6_fib.h
+++ net-2.6.git/include/net/ip6_fib.h
@@ -51,6 +51,8 @@ struct rt6key
 	int		plen;
 };
 
+struct fib6_table;
+
 struct rt6_info
 {
 	union {
@@ -71,6 +73,7 @@ struct rt6_info
 	u32				rt6i_flags;
 	u32				rt6i_metric;
 	atomic_t			rt6i_ref;
+	struct fib6_table		*rt6i_table;
 
 	struct rt6key			rt6i_dst;
 	struct rt6key			rt6i_src;
@@ -143,12 +146,41 @@ struct rt6_statistics {
 
 typedef void			(*f_pnode)(struct fib6_node *fn, void *);
 
-extern struct fib6_node		ip6_routing_table;
+struct fib6_table {
+	struct hlist_node	tb6_hlist;
+	u32			tb6_id;
+	rwlock_t		tb6_lock;
+	struct fib6_node	tb6_root;
+};
+
+#define RT6_TABLE_UNSPEC	RT_TABLE_UNSPEC
+#define RT6_TABLE_MAIN		RT_TABLE_MAIN
+#define RT6_TABLE_LOCAL		RT6_TABLE_MAIN
+#define RT6_TABLE_DFLT		RT6_TABLE_MAIN
+#define RT6_TABLE_INFO		RT6_TABLE_MAIN
+
+#ifdef CONFIG_IPV6_MULTIPLE_TABLES
+#define FIB6_TABLE_MIN		1
+#define FIB6_TABLE_MAX		RT_TABLE_MAX
+#else
+#define FIB6_TABLE_MIN		RT_TABLE_MAIN
+#define FIB6_TABLE_MAX		FIB6_TABLE_MIN
+#endif
+
+#define RT6_F_STRICT		1
+
+typedef struct rt6_info *(*pol_lookup_t)(struct fib6_table *,
+					 struct flowi *, int);
 
 /*
  *	exported functions
  */
 
+extern struct fib6_table *	fib6_get_table(u32 id);
+extern struct fib6_table *	fib6_new_table(u32 id);
+extern struct dst_entry *	fib6_rule_lookup(struct flowi *fl, int flags,
+						 pol_lookup_t lookup);
+
 extern struct fib6_node		*fib6_lookup(struct fib6_node *root,
 					     struct in6_addr *daddr,
 					     struct in6_addr *saddr);
@@ -161,6 +193,9 @@ extern void			fib6_clean_tree(struct fib
 						int (*func)(struct rt6_info *, void *arg),
 						int prune, void *arg);
 
+extern void			fib6_clean_all(int (*func)(struct rt6_info *, void *arg),
+					       int prune, void *arg);
+
 extern int			fib6_walk(struct fib6_walker_t *w);
 extern int			fib6_walk_continue(struct fib6_walker_t *w);
 
Index: net-2.6.git/net/ipv6/ip6_fib.c
===================================================================
--- net-2.6.git.orig/net/ipv6/ip6_fib.c
+++ net-2.6.git/net/ipv6/ip6_fib.c
@@ -26,6 +26,7 @@
 #include <linux/netdevice.h>
 #include <linux/in6.h>
 #include <linux/init.h>
+#include <linux/list.h>
 
 #ifdef 	CONFIG_PROC_FS
 #include <linux/proc_fs.h>
@@ -147,6 +148,126 @@ static __inline__ void rt6_release(struc
 		dst_free(&rt->u.dst);
 }
 
+static struct fib6_table fib6_main_tbl = {
+	.tb6_id		= RT6_TABLE_MAIN,
+	.tb6_lock	= RW_LOCK_UNLOCKED,
+	.tb6_root	= {
+		.leaf		= &ip6_null_entry,
+		.fn_flags	= RTN_ROOT | RTN_TL_ROOT | RTN_RTINFO,
+	},
+};
+
+#ifdef CONFIG_IPV6_MULTIPLE_TABLES
+
+#define FIB_TABLE_HASHSZ 256
+static struct hlist_head fib_table_hash[FIB_TABLE_HASHSZ];
+
+static struct fib6_table *fib6_alloc_table(u32 id)
+{
+	struct fib6_table *table;
+
+	table = kzalloc(sizeof(*table), GFP_ATOMIC);
+	if (table != NULL) {
+		table->tb6_id = id;
+		table->tb6_lock = RW_LOCK_UNLOCKED;
+		table->tb6_root.leaf = &ip6_null_entry;
+		table->tb6_root.fn_flags = RTN_ROOT | RTN_TL_ROOT | RTN_RTINFO;
+	}
+
+	return table;
+}
+
+static void fib6_link_table(struct fib6_table *tb)
+{
+	unsigned int h;
+
+	h = tb->tb6_id & (FIB_TABLE_HASHSZ - 1);
+
+	/*
+	 * No protection necessary, this is the only list mutatation
+	 * operation, tables never disappear once they exist.
+	 */
+	hlist_add_head_rcu(&tb->tb6_hlist, &fib_table_hash[h]);
+}
+
+struct fib6_table *fib6_new_table(u32 id)
+{
+	struct fib6_table *tb;
+
+	if (id == 0)
+		id = RT6_TABLE_MAIN;
+	tb = fib6_get_table(id);
+	if (tb)
+		return tb;
+
+	tb = fib6_alloc_table(id);
+	if (tb != NULL)
+		fib6_link_table(tb);
+
+        return tb;
+}
+
+struct fib6_table *fib6_get_table(u32 id)
+{
+	struct fib6_table *tb;
+	struct hlist_node *node;
+	unsigned int h;
+
+	if (id == 0)
+		id = RT6_TABLE_MAIN;
+	h = id & (FIB_TABLE_HASHSZ - 1);
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(tb, node, &fib_table_hash[h], tb6_hlist) {
+		if (tb->tb6_id == id) {
+			rcu_read_unlock();
+			return tb;
+		}
+	}
+	rcu_read_unlock();
+
+	return NULL;
+}
+
+struct dst_entry *fib6_rule_lookup(struct flowi *fl, int flags,
+				   pol_lookup_t lookup)
+{
+	/*
+	 * TODO: Add rule lookup
+	 */
+	struct fib6_table *table = fib6_get_table(RT6_TABLE_MAIN);
+
+	return (struct dst_entry *) lookup(table, fl, flags);
+}
+
+static void __init fib6_tables_init(void)
+{
+	fib6_link_table(&fib6_main_tbl);
+}
+
+#else
+
+struct fib6_table *fib6_new_table(u32 id)
+{
+	return fib6_get_table(id);
+}
+
+struct fib6_table *fib6_get_table(u32 id)
+{
+	return &fib6_main_tbl;
+}
+
+struct dst_entry *fib6_rule_lookup(struct flowi *fl, int flags,
+				   pol_lookup_t lookup)
+{
+	return (struct dst_entry *) lookup(&fib6_main_tbl, fl, flags);
+}
+
+static void __init fib6_tables_init(void)
+{
+}
+
+#endif
+
 
 /*
  *	Routing Table
@@ -1064,6 +1185,22 @@ void fib6_clean_tree(struct fib6_node *r
 	fib6_walk(&c.w);
 }
 
+void fib6_clean_all(int (*func)(struct rt6_info *, void *arg),
+		    int prune, void *arg)
+{
+	int i;
+	struct fib6_table *table;
+
+	for (i = FIB6_TABLE_MIN; i <= FIB6_TABLE_MAX; i++) {
+		table = fib6_get_table(i);
+		if (table != NULL) {
+			write_lock_bh(&table->tb6_lock);
+			fib6_clean_tree(&table->tb6_root, func, prune, arg);
+			write_unlock_bh(&table->tb6_lock);
+		}
+	}
+}
+
 static int fib6_prune_clone(struct rt6_info *rt, void *arg)
 {
 	if (rt->rt6i_flags & RTF_CACHE) {
@@ -1142,11 +1279,8 @@ void fib6_run_gc(unsigned long dummy)
 	}
 	gc_args.more = 0;
 
-
-	write_lock_bh(&rt6_lock);
 	ndisc_dst_gc(&gc_args.more);
-	fib6_clean_tree(&ip6_routing_table, fib6_age, 0, NULL);
-	write_unlock_bh(&rt6_lock);
+	fib6_clean_all(fib6_age, 0, NULL);
 
 	if (gc_args.more)
 		mod_timer(&ip6_fib_timer, jiffies + ip6_rt_gc_interval);
@@ -1165,6 +1299,8 @@ void __init fib6_init(void)
 					   NULL, NULL);
 	if (!fib6_node_kmem)
 		panic("cannot create fib6_nodes cache");
+
+	fib6_tables_init();
 }
 
 void fib6_gc_cleanup(void)
Index: net-2.6.git/net/ipv6/route.c
===================================================================
--- net-2.6.git.orig/net/ipv6/route.c
+++ net-2.6.git/net/ipv6/route.c
@@ -139,16 +139,6 @@ struct rt6_info ip6_null_entry = {
 	.rt6i_ref	= ATOMIC_INIT(1),
 };
 
-struct fib6_node ip6_routing_table = {
-	.leaf		= &ip6_null_entry,
-	.fn_flags	= RTN_ROOT | RTN_TL_ROOT | RTN_RTINFO,
-};
-
-/* Protects all the ip6 fib */
-
-DEFINE_RWLOCK(rt6_lock);
-
-
 /* allocate dst with ip6_dst_ops */
 static __inline__ struct rt6_info *ip6_dst_alloc(void)
 {
@@ -187,8 +177,14 @@ static __inline__ int rt6_check_expired(
 		time_after(jiffies, rt->rt6i_expires));
 }
 
+static inline int rt6_need_strict(struct in6_addr *daddr)
+{
+	return (ipv6_addr_type(daddr) &
+		(IPV6_ADDR_MULTICAST | IPV6_ADDR_LINKLOCAL));
+}
+
 /*
- *	Route lookup. Any rt6_lock is implied.
+ *	Route lookup. Any table->tb6_lock is implied.
  */
 
 static __inline__ struct rt6_info *rt6_device_match(struct rt6_info *rt,
@@ -440,27 +436,66 @@ int rt6_route_rcv(struct net_device *dev
 }
 #endif
 
-struct rt6_info *rt6_lookup(struct in6_addr *daddr, struct in6_addr *saddr,
-			    int oif, int strict)
+#define BACKTRACK() \
+if (rt == &ip6_null_entry && flags & RT6_F_STRICT) { \
+	while ((fn = fn->parent) != NULL) { \
+		if (fn->fn_flags & RTN_TL_ROOT) { \
+			dst_hold(&rt->u.dst); \
+			goto out; \
+		} \
+		if (fn->fn_flags & RTN_RTINFO) \
+			goto restart; \
+	} \
+}
+
+static struct rt6_info *ip6_pol_route_lookup(struct fib6_table *table,
+					     struct flowi *fl, int flags)
 {
 	struct fib6_node *fn;
 	struct rt6_info *rt;
 
-	read_lock_bh(&rt6_lock);
-	fn = fib6_lookup(&ip6_routing_table, daddr, saddr);
-	rt = rt6_device_match(fn->leaf, oif, strict);
+	read_lock_bh(&table->tb6_lock);
+	fn = fib6_lookup(&table->tb6_root, &fl->fl6_dst, &fl->fl6_src);
+restart:
+	rt = fn->leaf;
+	rt = rt6_device_match(rt, fl->oif, flags & RT6_F_STRICT);
+	BACKTRACK();
 	dst_hold(&rt->u.dst);
-	rt->u.dst.__use++;
-	read_unlock_bh(&rt6_lock);
+out:
+	read_unlock_bh(&table->tb6_lock);
 
 	rt->u.dst.lastuse = jiffies;
-	if (rt->u.dst.error == 0)
-		return rt;
-	dst_release(&rt->u.dst);
+	rt->u.dst.__use++;
+
+	return rt;
+
+}
+
+struct rt6_info *rt6_lookup(struct in6_addr *daddr, struct in6_addr *saddr,
+			    int oif, int strict)
+{
+	struct flowi fl = {
+		.oif = oif,
+		.nl_u = {
+			.ip6_u = {
+				.daddr = *daddr,
+				/* TODO: saddr */
+			},
+		},
+	};
+	struct dst_entry *dst;
+	int flags = strict ? RT6_F_STRICT : 0;
+
+	dst = fib6_rule_lookup(&fl, flags, ip6_pol_route_lookup);
+	if (dst->error == 0)
+		return (struct rt6_info *) dst;
+
+	dst_release(dst);
+
 	return NULL;
 }
 
-/* ip6_ins_rt is called with FREE rt6_lock.
+/* ip6_ins_rt is called with FREE table->tb6_lock.
    It takes new route entry, the addition fails by any reason the
    route is freed. In any case, if caller does not hold it, it may
    be destroyed.
@@ -470,10 +505,12 @@ int ip6_ins_rt(struct rt6_info *rt, stru
 		void *_rtattr, struct netlink_skb_parms *req)
 {
 	int err;
+	struct fib6_table *table;
 
-	write_lock_bh(&rt6_lock);
-	err = fib6_add(&ip6_routing_table, rt, nlh, _rtattr, req);
-	write_unlock_bh(&rt6_lock);
+	table = rt->rt6i_table;
+	write_lock_bh(&table->tb6_lock);
+	err = fib6_add(&table->tb6_root, rt, nlh, _rtattr, req);
+	write_unlock_bh(&table->tb6_lock);
 
 	return err;
 }
@@ -531,51 +568,40 @@ static struct rt6_info *rt6_alloc_clone(
 	return rt;
 }
 
-#define BACKTRACK() \
-if (rt == &ip6_null_entry) { \
-       while ((fn = fn->parent) != NULL) { \
-		if (fn->fn_flags & RTN_ROOT) { \
-			goto out; \
-		} \
-		if (fn->fn_flags & RTN_RTINFO) \
-			goto restart; \
-	} \
-}
-
-
-void ip6_route_input(struct sk_buff *skb)
+struct rt6_info *ip6_pol_route_input(struct fib6_table *table, struct flowi *fl,
+				     int flags)
 {
 	struct fib6_node *fn;
 	struct rt6_info *rt, *nrt;
-	int strict;
+	int strict = 0;
 	int attempts = 3;
 	int err;
 	int reachable = RT6_SELECT_F_REACHABLE;
 
-	strict = ipv6_addr_type(&skb->nh.ipv6h->daddr) & (IPV6_ADDR_MULTICAST|IPV6_ADDR_LINKLOCAL) ? RT6_SELECT_F_IFACE : 0;
+	if (flags & RT6_F_STRICT)
+		strict = RT6_SELECT_F_IFACE;
 
 relookup:
-	read_lock_bh(&rt6_lock);
+	read_lock_bh(&table->tb6_lock);
 
 restart_2:
-	fn = fib6_lookup(&ip6_routing_table, &skb->nh.ipv6h->daddr,
-			 &skb->nh.ipv6h->saddr);
+	fn = fib6_lookup(&table->tb6_root, &fl->fl6_dst, &fl->fl6_src);
 
 restart:
-	rt = rt6_select(&fn->leaf, skb->dev->ifindex, strict | reachable);
+	rt = rt6_select(&fn->leaf, fl->iif, strict | reachable);
 	BACKTRACK();
 	if (rt == &ip6_null_entry ||
 	    rt->rt6i_flags & RTF_CACHE)
 		goto out;
 
 	dst_hold(&rt->u.dst);
-	read_unlock_bh(&rt6_lock);
+	read_unlock_bh(&table->tb6_lock);
 
 	if (!rt->rt6i_nexthop && !(rt->rt6i_flags & RTF_NONEXTHOP))
-		nrt = rt6_alloc_cow(rt, &skb->nh.ipv6h->daddr, &skb->nh.ipv6h->saddr);
+		nrt = rt6_alloc_cow(rt, &fl->fl6_dst, &fl->fl6_src);
 	else {
 #if CLONE_OFFLINK_ROUTE
-		nrt = rt6_alloc_clone(rt, &skb->nh.ipv6h->daddr);
+		nrt = rt6_alloc_clone(rt, &fl->fl6_dst);
 #else
 		goto out2;
 #endif
@@ -586,7 +612,7 @@ restart:
 
 	dst_hold(&rt->u.dst);
 	if (nrt) {
-		err = ip6_ins_rt(nrt, NULL, NULL, &NETLINK_CB(skb));
+		err = ip6_ins_rt(nrt, NULL, NULL, NULL);
 		if (!err)
 			goto out2;
 	}
@@ -595,7 +621,7 @@ restart:
 		goto out2;
 
 	/*
-	 * Race condition! In the gap, when rt6_lock was
+	 * Race condition! In the gap, when table->tb6_lock was
 	 * released someone could insert this route.  Relookup.
 	 */
 	dst_release(&rt->u.dst);
@@ -607,30 +633,54 @@ out:
 		goto restart_2;
 	}
 	dst_hold(&rt->u.dst);
-	read_unlock_bh(&rt6_lock);
+	read_unlock_bh(&table->tb6_lock);
 out2:
 	rt->u.dst.lastuse = jiffies;
 	rt->u.dst.__use++;
-	skb->dst = (struct dst_entry *) rt;
-	return;
+
+	return rt;
 }
 
-struct dst_entry * ip6_route_output(struct sock *sk, struct flowi *fl)
+void ip6_route_input(struct sk_buff *skb)
+{
+	struct ipv6hdr *iph = skb->nh.ipv6h;
+	struct flowi fl = {
+		.iif = skb->dev->ifindex,
+		.nl_u = {
+			.ip6_u = {
+				.daddr = iph->daddr,
+				.saddr = iph->saddr,
+				.flowlabel = (* (u32 *) iph)&IPV6_FLOWINFO_MASK,
+			},
+		},
+		.proto = iph->nexthdr,
+	};
+	int flags = 0;
+
+	if (rt6_need_strict(&iph->daddr))
+		flags |= RT6_F_STRICT;
+
+	skb->dst = fib6_rule_lookup(&fl, flags, ip6_pol_route_input);
+}
+
+static struct rt6_info *ip6_pol_route_output(struct fib6_table *table,
+					     struct flowi *fl, int flags)
 {
 	struct fib6_node *fn;
 	struct rt6_info *rt, *nrt;
-	int strict;
+	int strict = 0;
 	int attempts = 3;
 	int err;
 	int reachable = RT6_SELECT_F_REACHABLE;
 
-	strict = ipv6_addr_type(&fl->fl6_dst) & (IPV6_ADDR_MULTICAST|IPV6_ADDR_LINKLOCAL) ? RT6_SELECT_F_IFACE : 0;
+	if (flags & RT6_F_STRICT)
+		strict = RT6_SELECT_F_IFACE;
 
 relookup:
-	read_lock_bh(&rt6_lock);
+	read_lock_bh(&table->tb6_lock);
 
 restart_2:
-	fn = fib6_lookup(&ip6_routing_table, &fl->fl6_dst, &fl->fl6_src);
+	fn = fib6_lookup(&table->tb6_root, &fl->fl6_dst, &fl->fl6_src);
 
 restart:
 	rt = rt6_select(&fn->leaf, fl->oif, strict | reachable);
@@ -640,7 +690,7 @@ restart:
 		goto out;
 
 	dst_hold(&rt->u.dst);
-	read_unlock_bh(&rt6_lock);
+	read_unlock_bh(&table->tb6_lock);
 
 	if (!rt->rt6i_nexthop && !(rt->rt6i_flags & RTF_NONEXTHOP))
 		nrt = rt6_alloc_cow(rt, &fl->fl6_dst, &fl->fl6_src);
@@ -666,7 +716,7 @@ restart:
 		goto out2;
 
 	/*
-	 * Race condition! In the gap, when rt6_lock was
+	 * Race condition! In the gap, when table->tb6_lock was
 	 * released someone could insert this route.  Relookup.
 	 */
 	dst_release(&rt->u.dst);
@@ -678,11 +728,21 @@ out:
 		goto restart_2;
 	}
 	dst_hold(&rt->u.dst);
-	read_unlock_bh(&rt6_lock);
+	read_unlock_bh(&table->tb6_lock);
 out2:
 	rt->u.dst.lastuse = jiffies;
 	rt->u.dst.__use++;
-	return &rt->u.dst;
+	return rt;
+}
+
+struct dst_entry * ip6_route_output(struct sock *sk, struct flowi *fl)
+{
+	int flags = 0;
+
+	if (rt6_need_strict(&fl->fl6_dst))
+		flags |= RT6_F_STRICT;
+
+	return fib6_rule_lookup(fl, flags, ip6_pol_route_output);
 }
 
 
@@ -904,7 +964,8 @@ int ipv6_get_hoplimit(struct net_device 
  */
 
 int ip6_route_add(struct in6_rtmsg *rtmsg, struct nlmsghdr *nlh, 
-		void *_rtattr, struct netlink_skb_parms *req)
+		  void *_rtattr, struct netlink_skb_parms *req,
+		  u32 table_id)
 {
 	int err;
 	struct rtmsg *r;
@@ -912,6 +973,7 @@ int ip6_route_add(struct in6_rtmsg *rtms
 	struct rt6_info *rt = NULL;
 	struct net_device *dev = NULL;
 	struct inet6_dev *idev = NULL;
+	struct fib6_table *table;
 	int addr_type;
 
 	rta = (struct rtattr **) _rtattr;
@@ -935,6 +997,12 @@ int ip6_route_add(struct in6_rtmsg *rtms
 	if (rtmsg->rtmsg_metric == 0)
 		rtmsg->rtmsg_metric = IP6_RT_PRIO_USER;
 
+	table = fib6_new_table(table_id);
+	if (table == NULL) {
+		err = -ENOBUFS;
+		goto out;
+	}
+
 	rt = ip6_dst_alloc();
 
 	if (rt == NULL) {
@@ -1091,6 +1159,7 @@ install_route:
 		rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(dst_mtu(&rt->u.dst));
 	rt->u.dst.dev = dev;
 	rt->rt6i_idev = idev;
+	rt->rt6i_table = table;
 	return ip6_ins_rt(rt, nlh, _rtattr, req);
 
 out:
@@ -1106,26 +1175,35 @@ out:
 int ip6_del_rt(struct rt6_info *rt, struct nlmsghdr *nlh, void *_rtattr, struct netlink_skb_parms *req)
 {
 	int err;
+	struct fib6_table *table;
 
-	write_lock_bh(&rt6_lock);
+	table = rt->rt6i_table;
+	write_lock_bh(&table->tb6_lock);
 
 	err = fib6_del(rt, nlh, _rtattr, req);
 	dst_release(&rt->u.dst);
 
-	write_unlock_bh(&rt6_lock);
+	write_unlock_bh(&table->tb6_lock);
 
 	return err;
 }
 
-static int ip6_route_del(struct in6_rtmsg *rtmsg, struct nlmsghdr *nlh, void *_rtattr, struct netlink_skb_parms *req)
+static int ip6_route_del(struct in6_rtmsg *rtmsg, struct nlmsghdr *nlh,
+			 void *_rtattr, struct netlink_skb_parms *req,
+			 u32 table_id)
 {
+	struct fib6_table *table;
 	struct fib6_node *fn;
 	struct rt6_info *rt;
 	int err = -ESRCH;
 
-	read_lock_bh(&rt6_lock);
+	table = fib6_get_table(table_id);
+	if (table == NULL)
+		return err;
 
-	fn = fib6_locate(&ip6_routing_table,
+	read_lock_bh(&table->tb6_lock);
+
+	fn = fib6_locate(&table->tb6_root,
 			 &rtmsg->rtmsg_dst, rtmsg->rtmsg_dst_len,
 			 &rtmsg->rtmsg_src, rtmsg->rtmsg_src_len);
 	
@@ -1142,12 +1220,12 @@ static int ip6_route_del(struct in6_rtms
 			    rtmsg->rtmsg_metric != rt->rt6i_metric)
 				continue;
 			dst_hold(&rt->u.dst);
-			read_unlock_bh(&rt6_lock);
+			read_unlock_bh(&table->tb6_lock);
 
 			return ip6_del_rt(rt, nlh, _rtattr, req);
 		}
 	}
-	read_unlock_bh(&rt6_lock);
+	read_unlock_bh(&table->tb6_lock);
 
 	return err;
 }
@@ -1159,8 +1237,13 @@ void rt6_redirect(struct in6_addr *dest,
 		  struct neighbour *neigh, u8 *lladdr, int on_link)
 {
 	struct rt6_info *rt, *nrt = NULL;
-	int strict;
 	struct fib6_node *fn;
+	struct fib6_table *table;
+
+	/* TODO: Very lazy, might need to check all tables */
+	table = fib6_get_table(RT6_TABLE_MAIN);
+	if (table == NULL)
+		return;
 
 	/*
 	 * Get the "current" route for this destination and
@@ -1172,10 +1255,9 @@ void rt6_redirect(struct in6_addr *dest,
 	 * is a bit fuzzy and one might need to check all possible
 	 * routes.
 	 */
-	strict = ipv6_addr_type(dest) & (IPV6_ADDR_MULTICAST | IPV6_ADDR_LINKLOCAL);
 
-	read_lock_bh(&rt6_lock);
-	fn = fib6_lookup(&ip6_routing_table, dest, NULL);
+	read_lock_bh(&table->tb6_lock);
+	fn = fib6_lookup(&table->tb6_root, dest, NULL);
 restart:
 	for (rt = fn->leaf; rt; rt = rt->u.next) {
 		/*
@@ -1198,7 +1280,7 @@ restart:
 	}
 	if (rt)
 		dst_hold(&rt->u.dst);
-	else if (strict) {
+	else if (rt6_need_strict(dest)) {
 		while ((fn = fn->parent) != NULL) {
 			if (fn->fn_flags & RTN_ROOT)
 				break;
@@ -1206,7 +1288,7 @@ restart:
 				goto restart;
 		}
 	}
-	read_unlock_bh(&rt6_lock);
+	read_unlock_bh(&table->tb6_lock);
 
 	if (!rt) {
 		if (net_ratelimit())
@@ -1377,6 +1459,7 @@ static struct rt6_info * ip6_rt_copy(str
 #ifdef CONFIG_IPV6_SUBTREES
 		memcpy(&rt->rt6i_src, &ort->rt6i_src, sizeof(struct rt6key));
 #endif
+		rt->rt6i_table = ort->rt6i_table;
 	}
 	return rt;
 }
@@ -1387,9 +1470,14 @@ static struct rt6_info *rt6_get_route_in
 {
 	struct fib6_node *fn;
 	struct rt6_info *rt = NULL;
+	struct fib6_table *table;
 
-	write_lock_bh(&rt6_lock);
-	fn = fib6_locate(&ip6_routing_table, prefix ,prefixlen, NULL, 0);
+	table = fib6_get_table(RT6_TABLE_INFO);
+	if (table == NULL)
+		return NULL;
+
+	write_lock_bh(&table->tb6_lock);
+	fn = fib6_locate(&table->tb6_root, prefix ,prefixlen, NULL, 0);
 	if (!fn)
 		goto out;
 
@@ -1404,7 +1492,7 @@ static struct rt6_info *rt6_get_route_in
 		break;
 	}
 out:
-	write_unlock_bh(&rt6_lock);
+	write_unlock_bh(&table->tb6_lock);
 	return rt;
 }
 
@@ -1426,7 +1514,7 @@ static struct rt6_info *rt6_add_route_in
 		rtmsg.rtmsg_flags |= RTF_DEFAULT;
 	rtmsg.rtmsg_ifindex = ifindex;
 
-	ip6_route_add(&rtmsg, NULL, NULL, NULL);
+	ip6_route_add(&rtmsg, NULL, NULL, NULL, RT6_TABLE_INFO);
 
 	return rt6_get_route_info(prefix, prefixlen, gwaddr, ifindex);
 }
@@ -1435,12 +1523,15 @@ static struct rt6_info *rt6_add_route_in
 struct rt6_info *rt6_get_dflt_router(struct in6_addr *addr, struct net_device *dev)
 {	
 	struct rt6_info *rt;
-	struct fib6_node *fn;
+	struct fib6_table *table;
 
-	fn = &ip6_routing_table;
+	/* TODO: It might be better to search all tables */
+	table = fib6_get_table(RT6_TABLE_DFLT);
+	if (table == NULL)
+		return NULL;
 
-	write_lock_bh(&rt6_lock);
-	for (rt = fn->leaf; rt; rt=rt->u.next) {
+	write_lock_bh(&table->tb6_lock);
+	for (rt = table->tb6_root.leaf; rt; rt=rt->u.next) {
 		if (dev == rt->rt6i_dev &&
 		    ((rt->rt6i_flags & (RTF_ADDRCONF | RTF_DEFAULT)) == (RTF_ADDRCONF | RTF_DEFAULT)) &&
 		    ipv6_addr_equal(&rt->rt6i_gateway, addr))
@@ -1448,7 +1539,7 @@ struct rt6_info *rt6_get_dflt_router(str
 	}
 	if (rt)
 		dst_hold(&rt->u.dst);
-	write_unlock_bh(&rt6_lock);
+	write_unlock_bh(&table->tb6_lock);
 	return rt;
 }
 
@@ -1467,28 +1558,31 @@ struct rt6_info *rt6_add_dflt_router(str
 
 	rtmsg.rtmsg_ifindex = dev->ifindex;
 
-	ip6_route_add(&rtmsg, NULL, NULL, NULL);
+	ip6_route_add(&rtmsg, NULL, NULL, NULL, RT6_TABLE_DFLT);
 	return rt6_get_dflt_router(gwaddr, dev);
 }
 
 void rt6_purge_dflt_routers(void)
 {
 	struct rt6_info *rt;
+	struct fib6_table *table;
+
+	/* NOTE: Keep consistent with rt6_get_dflt_router */
+	table = fib6_get_table(RT6_TABLE_DFLT);
+	if (table == NULL)
+		return;
 
 restart:
-	read_lock_bh(&rt6_lock);
-	for (rt = ip6_routing_table.leaf; rt; rt = rt->u.next) {
+	read_lock_bh(&table->tb6_lock);
+	for (rt = table->tb6_root.leaf; rt; rt = rt->u.next) {
 		if (rt->rt6i_flags & (RTF_DEFAULT | RTF_ADDRCONF)) {
 			dst_hold(&rt->u.dst);
-
-			read_unlock_bh(&rt6_lock);
-
+			read_unlock_bh(&table->tb6_lock);
 			ip6_del_rt(rt, NULL, NULL, NULL);
-
 			goto restart;
 		}
 	}
-	read_unlock_bh(&rt6_lock);
+	read_unlock_bh(&table->tb6_lock);
 }
 
 int ipv6_route_ioctl(unsigned int cmd, void __user *arg)
@@ -1509,10 +1603,12 @@ int ipv6_route_ioctl(unsigned int cmd, v
 		rtnl_lock();
 		switch (cmd) {
 		case SIOCADDRT:
-			err = ip6_route_add(&rtmsg, NULL, NULL, NULL);
+			err = ip6_route_add(&rtmsg, NULL, NULL, NULL,
+					    RT6_TABLE_MAIN);
 			break;
 		case SIOCDELRT:
-			err = ip6_route_del(&rtmsg, NULL, NULL, NULL);
+			err = ip6_route_del(&rtmsg, NULL, NULL, NULL,
+					    RT6_TABLE_MAIN);
 			break;
 		default:
 			err = -EINVAL;
@@ -1582,6 +1678,7 @@ struct rt6_info *addrconf_dst_alloc(stru
 
 	ipv6_addr_copy(&rt->rt6i_dst.addr, addr);
 	rt->rt6i_dst.plen = 128;
+	rt->rt6i_table = fib6_get_table(RT6_TABLE_LOCAL);
 
 	atomic_set(&rt->u.dst.__refcnt, 1);
 
@@ -1600,9 +1697,7 @@ static int fib6_ifdown(struct rt6_info *
 
 void rt6_ifdown(struct net_device *dev)
 {
-	write_lock_bh(&rt6_lock);
-	fib6_clean_tree(&ip6_routing_table, fib6_ifdown, 0, dev);
-	write_unlock_bh(&rt6_lock);
+	fib6_clean_all(fib6_ifdown, 0, dev);
 }
 
 struct rt6_mtu_change_arg
@@ -1652,13 +1747,12 @@ static int rt6_mtu_change_route(struct r
 
 void rt6_mtu_change(struct net_device *dev, unsigned mtu)
 {
-	struct rt6_mtu_change_arg arg;
+	struct rt6_mtu_change_arg arg = {
+		.dev = dev,
+		.mtu = mtu,
+	};
 
-	arg.dev = dev;
-	arg.mtu = mtu;
-	read_lock_bh(&rt6_lock);
-	fib6_clean_tree(&ip6_routing_table, rt6_mtu_change_route, 0, &arg);
-	read_unlock_bh(&rt6_lock);
+	fib6_clean_all(rt6_mtu_change_route, 0, &arg);
 }
 
 static int inet6_rtm_to_rtmsg(struct rtmsg *r, struct rtattr **rta,
@@ -1708,7 +1802,7 @@ int inet6_rtm_delroute(struct sk_buff *s
 
 	if (inet6_rtm_to_rtmsg(r, arg, &rtmsg))
 		return -EINVAL;
-	return ip6_route_del(&rtmsg, nlh, arg, &NETLINK_CB(skb));
+	return ip6_route_del(&rtmsg, nlh, arg, &NETLINK_CB(skb), r->rtm_table);
 }
 
 int inet6_rtm_newroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
@@ -1718,7 +1812,7 @@ int inet6_rtm_newroute(struct sk_buff *s
 
 	if (inet6_rtm_to_rtmsg(r, arg, &rtmsg))
 		return -EINVAL;
-	return ip6_route_add(&rtmsg, nlh, arg, &NETLINK_CB(skb));
+	return ip6_route_add(&rtmsg, nlh, arg, &NETLINK_CB(skb), r->rtm_table);
 }
 
 struct rt6_rtnl_dump_arg
@@ -1750,6 +1844,10 @@ static int rt6_fill_node(struct sk_buff 
 	rtm->rtm_dst_len = rt->rt6i_dst.plen;
 	rtm->rtm_src_len = rt->rt6i_src.plen;
 	rtm->rtm_tos = 0;
+	if (rt->rt6i_table)
+		rtm->rtm_table = rt->rt6i_table->tb6_id;
+	else
+		rtm->rtm_table = RT6_TABLE_UNSPEC;
 	rtm->rtm_table = RT_TABLE_MAIN;
 	if (rt->rt6i_flags&RTF_REJECT)
 		rtm->rtm_type = RTN_UNREACHABLE;
@@ -1857,7 +1955,6 @@ static void fib6_dump_end(struct netlink
 
 	if (w) {
 		cb->args[0] = 0;
-		fib6_walker_unlink(w);
 		kfree(w);
 	}
 	cb->done = (void*)cb->args[1];
@@ -1872,13 +1969,20 @@ static int fib6_dump_done(struct netlink
 
 int inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 {
+	struct fib6_table *table;
 	struct rt6_rtnl_dump_arg arg;
 	struct fib6_walker_t *w;
-	int res;
+	int i, res = 0;
 
 	arg.skb = skb;
 	arg.cb = cb;
 
+	/*
+	 * cb->args[0] = pointer to walker structure
+	 * cb->args[1] = saved cb->done() pointer
+	 * cb->args[2] = current table being dumped
+	 */
+
 	w = (void*)cb->args[0];
 	if (w == NULL) {
 		/* New dump:
@@ -1894,24 +1998,48 @@ int inet6_dump_fib(struct sk_buff *skb, 
 		w = kzalloc(sizeof(*w), GFP_ATOMIC);
 		if (w == NULL)
 			return -ENOMEM;
-		RT6_TRACE("dump<%p", w);
-		w->root = &ip6_routing_table;
 		w->func = fib6_dump_node;
 		w->args = &arg;
 		cb->args[0] = (long)w;
-		read_lock_bh(&rt6_lock);
-		res = fib6_walk(w);
-		read_unlock_bh(&rt6_lock);
+		cb->args[2] = FIB6_TABLE_MIN;
 	} else {
 		w->args = &arg;
-		read_lock_bh(&rt6_lock);
-		res = fib6_walk_continue(w);
-		read_unlock_bh(&rt6_lock);
-	}
-#if RT6_DEBUG >= 3
-	if (res <= 0 && skb->len == 0)
-		RT6_TRACE("%p>dump end\n", w);
-#endif
+		i = cb->args[2];
+		if (i > FIB6_TABLE_MAX)
+			goto end;
+
+		table = fib6_get_table(i);
+		if (table != NULL) {
+			read_lock_bh(&table->tb6_lock);
+			w->root = &table->tb6_root;
+			res = fib6_walk_continue(w);
+			read_unlock_bh(&table->tb6_lock);
+			if (res != 0) {
+				if (res < 0)
+					fib6_walker_unlink(w);
+				goto end;
+			}
+		}
+
+		fib6_walker_unlink(w);
+		cb->args[2] = ++i;
+	}
+
+	for (i = cb->args[2]; i <= FIB6_TABLE_MAX; i++) {
+		table = fib6_get_table(i);
+		if (table == NULL)
+			continue;
+
+		read_lock_bh(&table->tb6_lock);
+		w->root = &table->tb6_root;
+		res = fib6_walk(w);
+		read_unlock_bh(&table->tb6_lock);
+		if (res)
+			break;
+	}
+end:
+	cb->args[2] = i;
+
 	res = res < 0 ? res : skb->len;
 	/* res < 0 is an error. (really, impossible)
 	   res == 0 means that dump is complete, but skb still can contain data.
@@ -2091,16 +2219,13 @@ static int rt6_info_route(struct rt6_inf
 
 static int rt6_proc_info(char *buffer, char **start, off_t offset, int length)
 {
-	struct rt6_proc_arg arg;
-	arg.buffer = buffer;
-	arg.offset = offset;
-	arg.length = length;
-	arg.skip = 0;
-	arg.len = 0;
-
-	read_lock_bh(&rt6_lock);
-	fib6_clean_tree(&ip6_routing_table, rt6_info_route, 0, &arg);
-	read_unlock_bh(&rt6_lock);
+	struct rt6_proc_arg arg = {
+		.buffer = buffer,
+		.offset = offset,
+		.length = length,
+	};
+
+	fib6_clean_all(rt6_info_route, 0, &arg);
 
 	*start = buffer;
 	if (offset)
Index: net-2.6.git/net/ipv6/Kconfig
===================================================================
--- net-2.6.git.orig/net/ipv6/Kconfig
+++ net-2.6.git/net/ipv6/Kconfig
@@ -135,3 +135,9 @@ config IPV6_TUNNEL
 
 	  If unsure, say N.
 
+config IPV6_MULTIPLE_TABLES
+	bool "IPv6: Multiple Routing Tables"
+	depends on IPV6 && EXPERIMENTAL
+	---help---
+	  Support multiple routing tables.
+
Index: net-2.6.git/include/net/ip6_route.h
===================================================================
--- net-2.6.git.orig/include/net/ip6_route.h
+++ net-2.6.git/include/net/ip6_route.h
@@ -58,7 +58,8 @@ extern int			ipv6_route_ioctl(unsigned i
 extern int			ip6_route_add(struct in6_rtmsg *rtmsg,
 					      struct nlmsghdr *,
 					      void *rtattr,
-					      struct netlink_skb_parms *req);
+					      struct netlink_skb_parms *req,
+					      u32 table_id);
 extern int			ip6_ins_rt(struct rt6_info *,
 					   struct nlmsghdr *,
 					   void *rtattr,
Index: net-2.6.git/net/ipv6/addrconf.c
===================================================================
--- net-2.6.git.orig/net/ipv6/addrconf.c
+++ net-2.6.git/net/ipv6/addrconf.c
@@ -1525,7 +1525,7 @@ addrconf_prefix_route(struct in6_addr *p
 	if (dev->type == ARPHRD_SIT && (dev->flags&IFF_POINTOPOINT))
 		rtmsg.rtmsg_flags |= RTF_NONEXTHOP;
 
-	ip6_route_add(&rtmsg, NULL, NULL, NULL);
+	ip6_route_add(&rtmsg, NULL, NULL, NULL, RT6_TABLE_MAIN);
 }
 
 /* Create "default" multicast route to the interface */
@@ -1542,7 +1542,7 @@ static void addrconf_add_mroute(struct n
 	rtmsg.rtmsg_ifindex = dev->ifindex;
 	rtmsg.rtmsg_flags = RTF_UP;
 	rtmsg.rtmsg_type = RTMSG_NEWROUTE;
-	ip6_route_add(&rtmsg, NULL, NULL, NULL);
+	ip6_route_add(&rtmsg, NULL, NULL, NULL, RT6_TABLE_MAIN);
 }
 
 static void sit_route_add(struct net_device *dev)
@@ -1559,7 +1559,7 @@ static void sit_route_add(struct net_dev
 	rtmsg.rtmsg_flags	= RTF_UP|RTF_NONEXTHOP;
 	rtmsg.rtmsg_ifindex	= dev->ifindex;
 
-	ip6_route_add(&rtmsg, NULL, NULL, NULL);
+	ip6_route_add(&rtmsg, NULL, NULL, NULL, RT6_TABLE_MAIN);
 }
 
 static void addrconf_add_lroute(struct net_device *dev)

