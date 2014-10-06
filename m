From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 1/5] ipv6: minor fib6 cleanups like type safety, bool conversion, inline removal
Date: Mon,  6 Oct 2014 10:52:10 +0200
Message-ID: <d848631ba3331e6e18c3208b217d8ecf9b69d650.1412585163.git.hannes@stressinduktion.org>
References: <cover.1412585162.git.hannes@stressinduktion.org>
Cc: hideaki@yoshifuji.org, kafai@fb.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:55728 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751377AbaJFIwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 04:52:23 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by gateway2.nyi.internal (Postfix) with ESMTP id 9CD4A20881
	for <netdev@vger.kernel.org>; Mon,  6 Oct 2014 04:52:22 -0400 (EDT)
In-Reply-To: <cover.1412585162.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1412585162.git.hannes@stressinduktion.org>
References: <cover.1412585162.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: YOSHIFUJI Hideaki <hideaki@yoshifuji.org>
Cc: Martin Lau <kafai@fb.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/ip6_fib.h | 14 ++++++++++++--
 net/ipv6/ip6_fib.c    | 35 +++++++++++++----------------------
 2 files changed, 25 insertions(+), 24 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index cf485f9..f4e6b3e 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -202,12 +202,22 @@ static inline void ip6_rt_put(struct rt6_info *rt)
 	dst_release(&rt->dst);
 }
 
+enum fib_walk_state_t {
+#ifdef CONFIG_IPV6_SUBTREES
+	FWS_S,
+#endif
+	FWS_L,
+	FWS_R,
+	FWS_C,
+	FWS_U
+};
+
 struct fib6_walker_t {
 	struct list_head lh;
 	struct fib6_node *root, *node;
 	struct rt6_info *leaf;
-	unsigned char state;
-	unsigned char prune;
+	enum fib_walk_state_t state;
+	bool prune;
 	unsigned int skip;
 	unsigned int count;
 	int (*func)(struct fib6_walker_t *);
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 97b9fa8..92f53db 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -46,16 +46,6 @@
 
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
 struct fib6_cleaner_t {
 	struct fib6_walker_t w;
 	struct net *net;
@@ -91,20 +81,21 @@ static void fib6_gc_timer_cb(unsigned long arg);
 static LIST_HEAD(fib6_walkers);
 #define FOR_WALKERS(w) list_for_each_entry(w, &fib6_walkers, lh)
 
-static inline void fib6_walker_link(struct fib6_walker_t *w)
+static void fib6_walker_link(struct fib6_walker_t *w)
 {
 	write_lock_bh(&fib6_walker_lock);
 	list_add(&w->lh, &fib6_walkers);
 	write_unlock_bh(&fib6_walker_lock);
 }
 
-static inline void fib6_walker_unlink(struct fib6_walker_t *w)
+static void fib6_walker_unlink(struct fib6_walker_t *w)
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
@@ -1554,7 +1545,7 @@ static int fib6_clean_node(struct fib6_walker_t *w)
 
 static void fib6_clean_tree(struct net *net, struct fib6_node *root,
 			    int (*func)(struct rt6_info *, void *arg),
-			    int prune, void *arg)
+			    bool prune, void *arg)
 {
 	struct fib6_cleaner_t c;
 
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
-- 
1.9.3
