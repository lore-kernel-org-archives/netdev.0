From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] ipv6: implement rt_genid_bump_ipv6 with fn_sernum and remove rt6i_genid
Date: Wed, 10 Sep 2014 11:31:28 +0200
Message-ID: <130f98f49b1b90a30908bfda8f01109c91edfe1c.1410341451.git.hannes@stressinduktion.org>
References: <1410267519.27979.31.camel@localhost>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:56868 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750937AbaIJJbh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 05:31:37 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by gateway2.nyi.internal (Postfix) with ESMTP id E24C320A44
	for <netdev@vger.kernel.org>; Wed, 10 Sep 2014 05:31:36 -0400 (EDT)
In-Reply-To: <1410267519.27979.31.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some special routes will never be cloned in IPv6. Those are mainly
DST_HOST routes without RTF_NONEXTHOP or RTF_GATEWAY flags, thus mostly
routes handling the input path.

rt_genid depends on rt6_info clones being removed from the trie and
recreated with current rt6i_genid, thus bumping the genid would invalidate
all routes cached in the sockets and relookup will recreate them.  But in
case a non-cloned route ends up in the per-socket cache, it will never
be recreated, thus will never get a current rt_genid.

After the rt_genid is incremented for the first time all those routes
will always get invalidated by ip6_dst_check on the next check, thus
making early socket demultiplexing absolutely pointless for IPv6. It is
not possible to solve this with rt6i_genid, thus remove it.

In case we need to force the sockets to relookup the routes we now
increase the fn_sernum on all fibnodes in the routing tree. This is a
costly operation but should only happen if we have major routing/policy
changes in the kernel (e.g. manual route adding/removal, xfrm policy
changes). Also this patch optimized the walk over the trie a bit, we
don't touch every rt6_info but only touch the fib6_nodes.

Thanks to Eric Dumazet who noticed this problem.

Fixes: 6f3118b571b8 ("ipv6: use net->rt_genid to check dst validity")
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---

Notes:
    I based this patch on net-next, because it "only" fixes a performance
    problem so far and want it to be a bit more exposed to testing before
    a possible submission to stable.

 include/net/ip6_fib.h       |  5 ++--
 include/net/net_namespace.h |  4 +++-
 net/core/dst.c              |  8 +++++++
 net/ipv6/ip6_fib.c          | 57 ++++++++++++++++++++++++++++++++++++---------
 net/ipv6/route.c            |  4 ----
 5 files changed, 59 insertions(+), 19 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 9bcb220..a5e09b8 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -119,8 +119,6 @@ struct rt6_info {
 	struct inet6_dev		*rt6i_idev;
 	unsigned long			_rt6i_peer;
 
-	u32				rt6i_genid;
-
 	/* more non-fragment space at head required */
 	unsigned short			rt6i_nfheader_len;
 
@@ -281,7 +279,8 @@ struct fib6_node *fib6_locate(struct fib6_node *root,
 			      const struct in6_addr *daddr, int dst_len,
 			      const struct in6_addr *saddr, int src_len);
 
-void fib6_clean_all(struct net *net, int (*func)(struct rt6_info *, void *arg),
+void fib6_clean_all(struct net *net,
+		    int (*rt_visit)(struct rt6_info *, void *arg),
 		    void *arg);
 
 int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info,
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 361d260..e0b0476 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -358,9 +358,11 @@ static inline int rt_genid_ipv6(struct net *net)
 	return atomic_read(&net->ipv6.rt_genid);
 }
 
+extern void (*__rt_genid_bump_ipv6)(struct net *net);
 static inline void rt_genid_bump_ipv6(struct net *net)
 {
-	atomic_inc(&net->ipv6.rt_genid);
+	if (__rt_genid_bump_ipv6)
+		__rt_genid_bump_ipv6(net);
 }
 #else
 static inline int rt_genid_ipv6(struct net *net)
diff --git a/net/core/dst.c b/net/core/dst.c
index a028409..995183b 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -23,6 +23,14 @@
 
 #include <net/dst.h>
 
+/* as soon as the ipv6 module registers, this function is used to
+ * force all cached routing lookups to relookup
+ */
+#if IS_ENABLED(CONFIG_IPV6)
+void (*__rt_genid_bump_ipv6)(struct net *net);
+EXPORT_SYMBOL(__rt_genid_bump_ipv6);
+#endif
+
 /*
  * Theory of operations:
  * 1) We use a list, protected by a spinlock, to add
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 76b7f5e..d23b76f 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -106,10 +106,15 @@ static inline void fib6_walker_unlink(struct fib6_walker_t *w)
 }
 static __inline__ u32 fib6_new_sernum(void)
 {
-	u32 n = ++rt_sernum;
-	if ((__s32)n <= 0)
-		rt_sernum = n = 1;
-	return n;
+	u32 new, old;
+
+	do {
+		old = ACCESS_ONCE(rt_sernum);
+		new = old + 1;
+		if ((s32)new <= 0)
+			new = 1;
+	} while (cmpxchg(&rt_sernum, old, new) != old);
+	return new;
 }
 
 /*
@@ -1553,25 +1558,28 @@ static int fib6_clean_node(struct fib6_walker_t *w)
  */
 
 static void fib6_clean_tree(struct net *net, struct fib6_node *root,
-			    int (*func)(struct rt6_info *, void *arg),
+			    int (*node_visit)(struct fib6_walker_t *),
+			    int (*rt_visit)(struct rt6_info *, void *arg),
 			    int prune, void *arg)
 {
 	struct fib6_cleaner_t c;
 
 	c.w.root = root;
-	c.w.func = fib6_clean_node;
+	c.w.func = node_visit;
 	c.w.prune = prune;
 	c.w.count = 0;
 	c.w.skip = 0;
-	c.func = func;
+	c.func = rt_visit;
 	c.arg = arg;
 	c.net = net;
 
 	fib6_walk(&c.w);
 }
 
-void fib6_clean_all(struct net *net, int (*func)(struct rt6_info *, void *arg),
-		    void *arg)
+static void __fib6_clean_all(struct net *net,
+			     int (*node_visit)(struct fib6_walker_t *),
+			     int (*rt_visit)(struct rt6_info *, void *arg),
+			     void *arg)
 {
 	struct fib6_table *table;
 	struct hlist_head *head;
@@ -1583,13 +1591,20 @@ void fib6_clean_all(struct net *net, int (*func)(struct rt6_info *, void *arg),
 		hlist_for_each_entry_rcu(table, head, tb6_hlist) {
 			write_lock_bh(&table->tb6_lock);
 			fib6_clean_tree(net, &table->tb6_root,
-					func, 0, arg);
+					node_visit, rt_visit, 0, arg);
 			write_unlock_bh(&table->tb6_lock);
 		}
 	}
 	rcu_read_unlock();
 }
 
+void fib6_clean_all(struct net *net,
+		    int (*rt_visit)(struct rt6_info *, void *arg),
+		    void *arg)
+{
+	__fib6_clean_all(net, fib6_clean_node, rt_visit, arg);
+}
+
 static int fib6_prune_clone(struct rt6_info *rt, void *arg)
 {
 	if (rt->rt6i_flags & RTF_CACHE) {
@@ -1602,7 +1617,25 @@ static int fib6_prune_clone(struct rt6_info *rt, void *arg)
 
 static void fib6_prune_clones(struct net *net, struct fib6_node *fn)
 {
-	fib6_clean_tree(net, fn, fib6_prune_clone, 1, NULL);
+	fib6_clean_tree(net, fn, fib6_clean_node, fib6_prune_clone, 1, NULL);
+}
+
+static int fib6_upd_sernum(struct fib6_walker_t *w)
+{
+	struct fib6_cleaner_t *c = container_of(w, struct fib6_cleaner_t, w);
+	int *sernum = c->arg;
+
+	w->node->fn_sernum = *sernum;
+	w->leaf = NULL;
+	return 0;
+}
+
+static void fib6_genid_bump(struct net *net)
+{
+	int sernum;
+
+	sernum = fib6_new_sernum();
+	__fib6_clean_all(net, fib6_upd_sernum, NULL, &sernum);
 }
 
 /*
@@ -1788,6 +1821,8 @@ int __init fib6_init(void)
 			      NULL);
 	if (ret)
 		goto out_unregister_subsys;
+
+	__rt_genid_bump_ipv6 = fib6_genid_bump;
 out:
 	return ret;
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f74b041..a318dd89 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -314,7 +314,6 @@ static inline struct rt6_info *ip6_dst_alloc(struct net *net,
 
 		memset(dst + 1, 0, sizeof(*rt) - sizeof(*dst));
 		rt6_init_peer(rt, table ? &table->tb6_peers : net->ipv6.peers);
-		rt->rt6i_genid = rt_genid_ipv6(net);
 		INIT_LIST_HEAD(&rt->rt6i_siblings);
 	}
 	return rt;
@@ -1096,9 +1095,6 @@ static struct dst_entry *ip6_dst_check(struct dst_entry *dst, u32 cookie)
 	 * DST_OBSOLETE_FORCE_CHK which forces validation calls down
 	 * into this function always.
 	 */
-	if (rt->rt6i_genid != rt_genid_ipv6(dev_net(rt->dst.dev)))
-		return NULL;
-
 	if (!rt->rt6i_node || (rt->rt6i_node->fn_sernum != cookie))
 		return NULL;
 
-- 
1.9.3
