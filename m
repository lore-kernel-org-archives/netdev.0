From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 2/8] ipv6: a bit more typesafety
Date: Sun, 21 Sep 2014 00:05:19 +0200
Message-ID: <fab79c190ca6d2b728a2bacb30c234c0f054e76b.1411249633.git.hannes@stressinduktion.org>
References: <cover.1411249633.git.hannes@stressinduktion.org>
Cc: eric.dumazet@gmail.com, vyasevich@gmail.com,
	nicolas.dichtel@6wind.com, kafai@fb.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:56189 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750800AbaITWFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 18:05:35 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by gateway2.nyi.internal (Postfix) with ESMTP id 4616D20755
	for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 18:05:35 -0400 (EDT)
In-Reply-To: <cover.1411249633.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1411249633.git.hannes@stressinduktion.org>
References: <cover.1411249633.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert bool to bool and fib6_walker_t.state to the already existing enum.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Cc: Martin Lau <kafai@fb.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/ip6_fib.h | 14 ++++++++++++--
 net/ipv6/ip6_fib.c    | 17 ++++-------------
 2 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 1cdd46e..a09e554 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -205,12 +205,22 @@ static inline void ip6_rt_put(struct rt6_info *rt)
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
index 559d03c..c5e7e04 100644
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
@@ -1562,7 +1552,7 @@ static int fib6_clean_node(struct fib6_walker_t *w)
 
 static void fib6_clean_tree(struct net *net, struct fib6_node *root,
 			    int (*func)(struct rt6_info *, void *arg),
-			    int prune, u32 sernum, void *arg)
+			    bool prune, u32 sernum, void *arg)
 {
 	struct fib6_cleaner_t c;
 
@@ -1592,7 +1582,8 @@ void fib6_clean_all(struct net *net, int (*func)(struct rt6_info *, void *arg),
 		hlist_for_each_entry_rcu(table, head, tb6_hlist) {
 			write_lock_bh(&table->tb6_lock);
 			fib6_clean_tree(net, &table->tb6_root,
-					func, 0, FIB6_NO_SERNUM_CHANGE, arg);
+					func, false, FIB6_NO_SERNUM_CHANGE,
+					arg);
 			write_unlock_bh(&table->tb6_lock);
 		}
 	}
@@ -1611,7 +1602,7 @@ static int fib6_prune_clone(struct rt6_info *rt, void *arg)
 
 static void fib6_prune_clones(struct net *net, struct fib6_node *fn, u32 sernum)
 {
-	fib6_clean_tree(net, fn, fib6_prune_clone, 1, sernum, NULL);
+	fib6_clean_tree(net, fn, fib6_prune_clone, true, sernum, NULL);
 }
 
 /*
-- 
1.9.3
