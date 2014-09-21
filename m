From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH v2 net-next 2/9] ipv6: a bit more typesafety
Date: Sun, 21 Sep 2014 16:11:46 +0200
Message-ID: <31097022ee699d738ab991fecdd36055cc73cdbb.1411308211.git.hannes@stressinduktion.org>
References: <cover.1411308211.git.hannes@stressinduktion.org>
Cc: eric.dumazet@gmail.com, hideaki@yoshifuji.org, vyasevich@gmail.com,
	nicolas.dichtel@6wind.com, kafai@fb.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:60071 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751316AbaIUOMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2014 10:12:07 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by gateway2.nyi.internal (Postfix) with ESMTP id 9326B2080C
	for <netdev@vger.kernel.org>; Sun, 21 Sep 2014 10:12:06 -0400 (EDT)
In-Reply-To: <cover.1411308211.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1411308211.git.hannes@stressinduktion.org>
References: <cover.1411308211.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert prune argument/struct member to bool and fib6_walker_t.state to
the already existing enum.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: YOSHIFUJI Hideaki <hideaki@yoshifuji.org>
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
index 900254e..67599d8 100644
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
