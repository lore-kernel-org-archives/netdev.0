From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH RFC 4/6] ipv6: new function fib6_flush_trees and use it instead of bumping removed rt6_genid
Date: Fri, 12 Sep 2014 01:21:51 +0200
Message-ID: <26eb6cb832857e3512be243110bd03dbcd6ee8f5.1410477596.git.hannes@stressinduktion.org>
References: <cover.1410477596.git.hannes@stressinduktion.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:50977 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754264AbaIKXWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 19:22:03 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by gateway2.nyi.internal (Postfix) with ESMTP id 46BFA20E5D
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 19:22:03 -0400 (EDT)
In-Reply-To: <cover.1410477596.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1410477596.git.hannes@stressinduktion.org>
References: <cover.1410477596.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fib6_flush_trees is still a very costly operation but now is only called
by xfrm code when a policy changes.

fib6_flush_tree must walk all ipv6 routing tables and modify fn_sernum,
so all sockets relookup their dst_entries. Use a NULL callback, so we
only walk the nodes without looking at the rt6_infos.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/net_namespace.h | 14 +++-----------
 include/net/netns/ipv6.h    |  1 -
 net/ipv6/addrconf_core.c    |  6 ++++++
 net/ipv6/af_inet6.c         |  1 -
 net/ipv6/ip6_fib.c          | 23 ++++++++++++++++++++---
 net/ipv6/route.c            |  4 ----
 6 files changed, 29 insertions(+), 20 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 361d260..61aad36 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -353,21 +353,13 @@ static inline void rt_genid_bump_ipv4(struct net *net)
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
-static inline int rt_genid_ipv6(struct net *net)
-{
-	return atomic_read(&net->ipv6.rt_genid);
-}
-
+extern void (*__fib6_flush_trees)(struct net *);
 static inline void rt_genid_bump_ipv6(struct net *net)
 {
-	atomic_inc(&net->ipv6.rt_genid);
+	if (__fib6_flush_trees)
+		__fib6_flush_trees(net);
 }
 #else
-static inline int rt_genid_ipv6(struct net *net)
-{
-	return 0;
-}
-
 static inline void rt_genid_bump_ipv6(struct net *net)
 {
 }
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index eade27a..3291ba6 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -76,7 +76,6 @@ struct netns_ipv6 {
 #endif
 #endif
 	atomic_t		dev_addr_genid;
-	atomic_t		rt_genid;
 };
 
 #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
diff --git a/net/ipv6/addrconf_core.c b/net/ipv6/addrconf_core.c
index e696045..8b2d99a 100644
--- a/net/ipv6/addrconf_core.c
+++ b/net/ipv6/addrconf_core.c
@@ -10,6 +10,12 @@
 
 #define IPV6_ADDR_SCOPE_TYPE(scope)	((scope) << 16)
 
+/* if ipv6 module registers this function is used by xfrm to force
+ * all sockets to relookup their nodes - this is fairly expensive
+ */
+void (*__fib6_flush_trees)(struct net *);
+EXPORT_SYMBOL(__fib6_flush_trees);
+
 static inline unsigned int ipv6_addr_scope2type(unsigned int scope)
 {
 	switch (scope) {
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index e4865a3..2189d2d 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -766,7 +766,6 @@ static int __net_init inet6_net_init(struct net *net)
 	net->ipv6.sysctl.icmpv6_time = 1*HZ;
 	net->ipv6.sysctl.flowlabel_consistency = 1;
 	net->ipv6.sysctl.auto_flowlabels = 0;
-	atomic_set(&net->ipv6.rt_genid, 0);
 
 	err = ipv6_init_mibs(net);
 	if (err)
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 590c5d2..cffee60 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1586,26 +1586,36 @@ static void fib6_clean_tree(struct net *net, struct fib6_node *root,
 	fib6_walk(&c.w);
 }
 
-void fib6_clean_all(struct net *net, int (*func)(struct rt6_info *, void *arg),
-		    void *arg)
+static void __fib6_clean_all(struct net *net,
+			     int (*func)(struct rt6_info *, void *arg),
+			     bool update_sernum, void *arg)
 {
 	struct fib6_table *table;
 	struct hlist_head *head;
 	unsigned int h;
+	u32 sernum = 0;
 
 	rcu_read_lock();
 	for (h = 0; h < FIB6_TABLE_HASHSZ; h++) {
 		head = &net->ipv6.fib_table_hash[h];
 		hlist_for_each_entry_rcu(table, head, tb6_hlist) {
 			write_lock_bh(&table->tb6_lock);
+			sernum = update_sernum && !sernum ?
+				 fib6_new_sernum() : 0;
 			fib6_clean_tree(net, &table->tb6_root,
-					func, 0, 0, arg);
+					func, 0, sernum, arg);
 			write_unlock_bh(&table->tb6_lock);
 		}
 	}
 	rcu_read_unlock();
 }
 
+void fib6_clean_all(struct net *net, int (*func)(struct rt6_info *, void *arg),
+		    void *arg)
+{
+	__fib6_clean_all(net, func, false, arg);
+}
+
 static int fib6_prune_clone(struct rt6_info *rt, void *arg)
 {
 	if (rt->rt6i_flags & RTF_CACHE) {
@@ -1622,6 +1632,11 @@ static void fib6_prune_clones(struct net *net, struct fib6_node *fn,
 	fib6_clean_tree(net, fn, fib6_prune_clone, 1, sernum, NULL);
 }
 
+static void fib6_flush_trees(struct net *net)
+{
+	__fib6_clean_all(net, NULL, true, NULL);
+}
+
 /*
  *	Garbage collection
  */
@@ -1805,6 +1820,8 @@ int __init fib6_init(void)
 			      NULL);
 	if (ret)
 		goto out_unregister_subsys;
+
+	__fib6_flush_trees = fib6_flush_trees;
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
