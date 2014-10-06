From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH v2 net-next 1/5] ipv6: minor fib6 cleanups like type safety, bool conversion, inline removal
Date: Mon,  6 Oct 2014 19:58:34 +0200
Message-ID: <95f520991a27aa9b0dbbe2686bb1bffdcc794134.1412618014.git.hannes@stressinduktion.org>
References: <cover.1412618014.git.hannes@stressinduktion.org>
Cc: hideaki@yoshifuji.org, kafai@fb.com, cwang@twopensource.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:39234 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753065AbaJFR6y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 13:58:54 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by gateway2.nyi.internal (Postfix) with ESMTP id 4EFD220AE4
	for <netdev@vger.kernel.org>; Mon,  6 Oct 2014 13:58:53 -0400 (EDT)
In-Reply-To: <cover.1412618014.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1412618014.git.hannes@stressinduktion.org>
References: <cover.1412618014.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also renamed struct fib6_walker_t to fib6_walker and enum fib_walk_state_t
to fib6_walk_state as recommended by Cong Wang.

Cc: Cong Wang <cwang@twopensource.com>
Cc: YOSHIFUJI Hideaki <hideaki@yoshifuji.org>
Cc: Martin Lau <kafai@fb.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/ip6_fib.h | 18 ++++++++++---
 net/ipv6/ip6_fib.c    | 71 ++++++++++++++++++++++-----------------------------
 2 files changed, 45 insertions(+), 44 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index cf485f9..9221bf4 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -202,15 +202,25 @@ static inline void ip6_rt_put(struct rt6_info *rt)
 	dst_release(&rt->dst);
 }
 
-struct fib6_walker_t {
+enum fib6_walk_state {
+#ifdef CONFIG_IPV6_SUBTREES
+	FWS_S,
+#endif
+	FWS_L,
+	FWS_R,
+	FWS_C,
+	FWS_U
+};
+
+struct fib6_walker {
 	struct list_head lh;
 	struct fib6_node *root, *node;
 	struct rt6_info *leaf;
-	unsigned char state;
-	unsigned char prune;
+	enum fib6_walk_state state;
+	bool prune;
 	unsigned int skip;
 	unsigned int count;
-	int (*func)(struct fib6_walker_t *);
+	int (*func)(struct fib6_walker *);
 	void *args;
 };
 
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 97b9fa8..e8d7465 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -46,18 +46,8 @@
 
 static struct kmem_cache *fib6_node_kmem __read_mostly;
 
-enum fib_walk_state_t {
-#ifdef CONFIG_IPV6_SUBTREES
-	FWS_S,
-#endif
-	FWS_L,
-	FWS_R,
-	FWS_C,
-	FWS_U
-};
-
-struct fib6_cleaner_t {
-	struct fib6_walker_t w;
+struct fib6_cleaner {
+	struct fib6_walker w;
 	struct net *net;
 	int (*func)(struct rt6_info *, void *arg);
 	void *arg;
@@ -74,8 +64,8 @@ static DEFINE_RWLOCK(fib6_walker_lock);
 static void fib6_prune_clones(struct net *net, struct fib6_node *fn);
 static struct rt6_info *fib6_find_prefix(struct net *net, struct fib6_node *fn);
 static struct fib6_node *fib6_repair_tree(struct net *net, struct fib6_node *fn);
-static int fib6_walk(struct fib6_walker_t *w);
-static int fib6_walk_continue(struct fib6_walker_t *w);
+static int fib6_walk(struct fib6_walker *w);
+static int fib6_walk_continue(struct fib6_walker *w);
 
 /*
  *	A routing update causes an increase of the serial number on the
@@ -91,20 +81,21 @@ static void fib6_gc_timer_cb(unsigned long arg);
 static LIST_HEAD(fib6_walkers);
 #define FOR_WALKERS(w) list_for_each_entry(w, &fib6_walkers, lh)
 
-static inline void fib6_walker_link(struct fib6_walker_t *w)
+static void fib6_walker_link(struct fib6_walker *w)
 {
 	write_lock_bh(&fib6_walker_lock);
 	list_add(&w->lh, &fib6_walkers);
 	write_unlock_bh(&fib6_walker_lock);
 }
 
-static inline void fib6_walker_unlink(struct fib6_walker_t *w)
+static void fib6_walker_unlink(struct fib6_walker *w)
 {
 	write_lock_bh(&fib6_walker_lock);
 	list_del(&w->lh);
 	write_unlock_bh(&fib6_walker_lock);
 }
-static __inline__ u32 fib6_new_sernum(void)
+
+static u32 fib6_new_sernum(void)
 {
 	u32 n = ++rt_sernum;
 	if ((__s32)n <= 0)
@@ -128,7 +119,7 @@ static __inline__ u32 fib6_new_sernum(void)
 # define BITOP_BE32_SWIZZLE	0
 #endif
 
-static __inline__ __be32 addr_bit_set(const void *token, int fn_bit)
+static __be32 addr_bit_set(const void *token, int fn_bit)
 {
 	const __be32 *addr = token;
 	/*
@@ -142,7 +133,7 @@ static __inline__ __be32 addr_bit_set(const void *token, int fn_bit)
 	       addr[fn_bit >> 5];
 }
 
-static __inline__ struct fib6_node *node_alloc(void)
+static struct fib6_node *node_alloc(void)
 {
 	struct fib6_node *fn;
 
@@ -151,12 +142,12 @@ static __inline__ struct fib6_node *node_alloc(void)
 	return fn;
 }
 
-static __inline__ void node_free(struct fib6_node *fn)
+static void node_free(struct fib6_node *fn)
 {
 	kmem_cache_free(fib6_node_kmem, fn);
 }
 
-static __inline__ void rt6_release(struct rt6_info *rt)
+static void rt6_release(struct rt6_info *rt)
 {
 	if (atomic_dec_and_test(&rt->rt6i_ref))
 		dst_free(&rt->dst);
@@ -267,7 +258,7 @@ static void __net_init fib6_tables_init(struct net *net)
 
 #endif
 
-static int fib6_dump_node(struct fib6_walker_t *w)
+static int fib6_dump_node(struct fib6_walker *w)
 {
 	int res;
 	struct rt6_info *rt;
@@ -287,7 +278,7 @@ static int fib6_dump_node(struct fib6_walker_t *w)
 
 static void fib6_dump_end(struct netlink_callback *cb)
 {
-	struct fib6_walker_t *w = (void *)cb->args[2];
+	struct fib6_walker *w = (void *)cb->args[2];
 
 	if (w) {
 		if (cb->args[4]) {
@@ -310,7 +301,7 @@ static int fib6_dump_done(struct netlink_callback *cb)
 static int fib6_dump_table(struct fib6_table *table, struct sk_buff *skb,
 			   struct netlink_callback *cb)
 {
-	struct fib6_walker_t *w;
+	struct fib6_walker *w;
 	int res;
 
 	w = (void *)cb->args[2];
@@ -355,7 +346,7 @@ static int inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 	unsigned int h, s_h;
 	unsigned int e = 0, s_e;
 	struct rt6_rtnl_dump_arg arg;
-	struct fib6_walker_t *w;
+	struct fib6_walker *w;
 	struct fib6_table *tb;
 	struct hlist_head *head;
 	int res = 0;
@@ -627,7 +618,7 @@ insert_above:
 	return ln;
 }
 
-static inline bool rt6_qualify_for_ecmp(struct rt6_info *rt)
+static bool rt6_qualify_for_ecmp(struct rt6_info *rt)
 {
 	return (rt->rt6i_flags & (RTF_GATEWAY|RTF_ADDRCONF|RTF_DYNAMIC)) ==
 	       RTF_GATEWAY;
@@ -820,7 +811,7 @@ add:
 	return 0;
 }
 
-static __inline__ void fib6_start_gc(struct net *net, struct rt6_info *rt)
+static void fib6_start_gc(struct net *net, struct rt6_info *rt)
 {
 	if (!timer_pending(&net->ipv6.ip6_fib_timer) &&
 	    (rt->rt6i_flags & (RTF_EXPIRES | RTF_CACHE)))
@@ -1174,7 +1165,7 @@ static struct fib6_node *fib6_repair_tree(struct net *net,
 	int children;
 	int nstate;
 	struct fib6_node *child, *pn;
-	struct fib6_walker_t *w;
+	struct fib6_walker *w;
 	int iter = 0;
 
 	for (;;) {
@@ -1276,7 +1267,7 @@ static struct fib6_node *fib6_repair_tree(struct net *net,
 static void fib6_del_route(struct fib6_node *fn, struct rt6_info **rtp,
 			   struct nl_info *info)
 {
-	struct fib6_walker_t *w;
+	struct fib6_walker *w;
 	struct rt6_info *rt = *rtp;
 	struct net *net = info->nl_net;
 
@@ -1414,7 +1405,7 @@ int fib6_del(struct rt6_info *rt, struct nl_info *info)
  *	<0  -> walk is terminated by an error.
  */
 
-static int fib6_walk_continue(struct fib6_walker_t *w)
+static int fib6_walk_continue(struct fib6_walker *w)
 {
 	struct fib6_node *fn, *pn;
 
@@ -1498,7 +1489,7 @@ skip:
 	}
 }
 
-static int fib6_walk(struct fib6_walker_t *w)
+static int fib6_walk(struct fib6_walker *w)
 {
 	int res;
 
@@ -1512,11 +1503,11 @@ static int fib6_walk(struct fib6_walker_t *w)
 	return res;
 }
 
-static int fib6_clean_node(struct fib6_walker_t *w)
+static int fib6_clean_node(struct fib6_walker *w)
 {
 	int res;
 	struct rt6_info *rt;
-	struct fib6_cleaner_t *c = container_of(w, struct fib6_cleaner_t, w);
+	struct fib6_cleaner *c = container_of(w, struct fib6_cleaner, w);
 	struct nl_info info = {
 		.nl_net = c->net,
 	};
@@ -1554,9 +1545,9 @@ static int fib6_clean_node(struct fib6_walker_t *w)
 
 static void fib6_clean_tree(struct net *net, struct fib6_node *root,
 			    int (*func)(struct rt6_info *, void *arg),
-			    int prune, void *arg)
+			    bool prune, void *arg)
 {
-	struct fib6_cleaner_t c;
+	struct fib6_cleaner c;
 
 	c.w.root = root;
 	c.w.func = fib6_clean_node;
@@ -1583,7 +1574,7 @@ void fib6_clean_all(struct net *net, int (*func)(struct rt6_info *, void *arg),
 		hlist_for_each_entry_rcu(table, head, tb6_hlist) {
 			write_lock_bh(&table->tb6_lock);
 			fib6_clean_tree(net, &table->tb6_root,
-					func, 0, arg);
+					func, false, arg);
 			write_unlock_bh(&table->tb6_lock);
 		}
 	}
@@ -1602,7 +1593,7 @@ static int fib6_prune_clone(struct rt6_info *rt, void *arg)
 
 static void fib6_prune_clones(struct net *net, struct fib6_node *fn)
 {
-	fib6_clean_tree(net, fn, fib6_prune_clone, 1, NULL);
+	fib6_clean_tree(net, fn, fib6_prune_clone, true, NULL);
 }
 
 static int fib6_update_sernum(struct rt6_info *rt, void *arg)
@@ -1828,7 +1819,7 @@ void fib6_gc_cleanup(void)
 
 struct ipv6_route_iter {
 	struct seq_net_private p;
-	struct fib6_walker_t w;
+	struct fib6_walker w;
 	loff_t skip;
 	struct fib6_table *tbl;
 	__u32 sernum;
@@ -1859,7 +1850,7 @@ static int ipv6_route_seq_show(struct seq_file *seq, void *v)
 	return 0;
 }
 
-static int ipv6_route_yield(struct fib6_walker_t *w)
+static int ipv6_route_yield(struct fib6_walker *w)
 {
 	struct ipv6_route_iter *iter = w->args;
 
@@ -1980,7 +1971,7 @@ static void *ipv6_route_seq_start(struct seq_file *seq, loff_t *pos)
 
 static bool ipv6_route_iter_active(struct ipv6_route_iter *iter)
 {
-	struct fib6_walker_t *w = &iter->w;
+	struct fib6_walker *w = &iter->w;
 	return w->node && !(w->state == FWS_U && w->node == w->root);
 }
 
-- 
1.9.3
