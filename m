From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] fib: add __rcu annotations
Date: Thu, 31 Mar 2011 10:44:32 +0200
Message-ID: <1301561072.3169.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:36364 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932410Ab1CaIoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 04:44:37 -0400
Received: by fxm17 with SMTP id 17so1656272fxm.19
        for <netdev@vger.kernel.org>; Thu, 31 Mar 2011 01:44:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add __rcu annotations and lockdep checks.

Add const qualifiers

node_parent() and node_parent_rcu() can use
rcu_dereference_index_check()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/fib_trie.c |  103 +++++++++++++++++++++++-------------------
 1 file changed, 58 insertions(+), 45 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index b92c86f..b9d1f33 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -126,7 +126,7 @@ struct tnode {
 		struct work_struct work;
 		struct tnode *tnode_free;
 	};
-	struct rt_trie_node *child[0];
+	struct rt_trie_node __rcu *child[0];
 };
 
 #ifdef CONFIG_IP_FIB_TRIE_STATS
@@ -151,7 +151,7 @@ struct trie_stat {
 };
 
 struct trie {
-	struct rt_trie_node *trie;
+	struct rt_trie_node __rcu *trie;
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 	struct trie_use_stats stats;
 #endif
@@ -177,16 +177,29 @@ static const int sync_pages = 128;
 static struct kmem_cache *fn_alias_kmem __read_mostly;
 static struct kmem_cache *trie_leaf_kmem __read_mostly;
 
-static inline struct tnode *node_parent(struct rt_trie_node *node)
+/*
+ * caller must hold RTNL
+ */
+static inline struct tnode *node_parent(const struct rt_trie_node *node)
 {
-	return (struct tnode *)(node->parent & ~NODE_TYPE_MASK);
+	unsigned long parent;
+
+	parent = rcu_dereference_index_check(node->parent, lockdep_rtnl_is_held());
+
+	return (struct tnode *)(parent & ~NODE_TYPE_MASK);
 }
 
-static inline struct tnode *node_parent_rcu(struct rt_trie_node *node)
+/*
+ * caller must hold RCU read lock or RTNL
+ */
+static inline struct tnode *node_parent_rcu(const struct rt_trie_node *node)
 {
-	struct tnode *ret = node_parent(node);
+	unsigned long parent;
+
+	parent = rcu_dereference_index_check(node->parent, rcu_read_lock_held() ||
+							   lockdep_rtnl_is_held());
 
-	return rcu_dereference_rtnl(ret);
+	return (struct tnode *)(parent & ~NODE_TYPE_MASK);
 }
 
 /* Same as rcu_assign_pointer
@@ -198,18 +211,24 @@ static inline void node_set_parent(struct rt_trie_node *node, struct tnode *ptr)
 	node->parent = (unsigned long)ptr | NODE_TYPE(node);
 }
 
-static inline struct rt_trie_node *tnode_get_child(struct tnode *tn, unsigned int i)
+/*
+ * caller must hold RTNL
+ */
+static inline struct rt_trie_node *tnode_get_child(const struct tnode *tn, unsigned int i)
 {
 	BUG_ON(i >= 1U << tn->bits);
 
-	return tn->child[i];
+	return rtnl_dereference(tn->child[i]);
 }
 
-static inline struct rt_trie_node *tnode_get_child_rcu(struct tnode *tn, unsigned int i)
+/*
+ * caller must hold RCU read lock or RTNL
+ */
+static inline struct rt_trie_node *tnode_get_child_rcu(const struct tnode *tn, unsigned int i)
 {
-	struct rt_trie_node *ret = tnode_get_child(tn, i);
+	BUG_ON(i >= 1U << tn->bits);
 
-	return rcu_dereference_rtnl(ret);
+	return rcu_dereference_rtnl(tn->child[i]);
 }
 
 static inline int tnode_child_length(const struct tnode *tn)
@@ -487,7 +506,7 @@ static inline void put_child(struct trie *t, struct tnode *tn, int i,
 static void tnode_put_child_reorg(struct tnode *tn, int i, struct rt_trie_node *n,
 				  int wasfull)
 {
-	struct rt_trie_node *chi = tn->child[i];
+	struct rt_trie_node *chi = rtnl_dereference(tn->child[i]);
 	int isfull;
 
 	BUG_ON(i >= 1<<tn->bits);
@@ -665,7 +684,7 @@ one_child:
 		for (i = 0; i < tnode_child_length(tn); i++) {
 			struct rt_trie_node *n;
 
-			n = tn->child[i];
+			n = rtnl_dereference(tn->child[i]);
 			if (!n)
 				continue;
 
@@ -679,6 +698,20 @@ one_child:
 	return (struct rt_trie_node *) tn;
 }
 
+
+static void tnode_clean_free(struct tnode *tn)
+{
+	int i;
+	struct tnode *tofree;
+
+	for (i = 0; i < tnode_child_length(tn); i++) {
+		tofree = (struct tnode *)rtnl_dereference(tn->child[i]);
+		if (tofree)
+			tnode_free(tofree);
+	}
+	tnode_free(tn);
+}
+
 static struct tnode *inflate(struct trie *t, struct tnode *tn)
 {
 	struct tnode *oldtnode = tn;
@@ -755,8 +788,8 @@ static struct tnode *inflate(struct trie *t, struct tnode *tn)
 		inode = (struct tnode *) node;
 
 		if (inode->bits == 1) {
-			put_child(t, tn, 2*i, inode->child[0]);
-			put_child(t, tn, 2*i+1, inode->child[1]);
+			put_child(t, tn, 2*i, rtnl_dereference(inode->child[0]));
+			put_child(t, tn, 2*i+1, rtnl_dereference(inode->child[1]));
 
 			tnode_free_safe(inode);
 			continue;
@@ -797,8 +830,8 @@ static struct tnode *inflate(struct trie *t, struct tnode *tn)
 
 		size = tnode_child_length(left);
 		for (j = 0; j < size; j++) {
-			put_child(t, left, j, inode->child[j]);
-			put_child(t, right, j, inode->child[j + size]);
+			put_child(t, left, j, rtnl_dereference(inode->child[j]));
+			put_child(t, right, j, rtnl_dereference(inode->child[j + size]));
 		}
 		put_child(t, tn, 2*i, resize(t, left));
 		put_child(t, tn, 2*i+1, resize(t, right));
@@ -808,18 +841,8 @@ static struct tnode *inflate(struct trie *t, struct tnode *tn)
 	tnode_free_safe(oldtnode);
 	return tn;
 nomem:
-	{
-		int size = tnode_child_length(tn);
-		int j;
-
-		for (j = 0; j < size; j++)
-			if (tn->child[j])
-				tnode_free((struct tnode *)tn->child[j]);
-
-		tnode_free(tn);
-
-		return ERR_PTR(-ENOMEM);
-	}
+	tnode_clean_free(tn);
+	return ERR_PTR(-ENOMEM);
 }
 
 static struct tnode *halve(struct trie *t, struct tnode *tn)
@@ -890,18 +913,8 @@ static struct tnode *halve(struct trie *t, struct tnode *tn)
 	tnode_free_safe(oldtnode);
 	return tn;
 nomem:
-	{
-		int size = tnode_child_length(tn);
-		int j;
-
-		for (j = 0; j < size; j++)
-			if (tn->child[j])
-				tnode_free((struct tnode *)tn->child[j]);
-
-		tnode_free(tn);
-
-		return ERR_PTR(-ENOMEM);
-	}
+	tnode_clean_free(tn);
+	return ERR_PTR(-ENOMEM);
 }
 
 /* readside must use rcu_read_lock currently dump routines
@@ -1033,7 +1046,7 @@ static struct list_head *fib_insert_node(struct trie *t, u32 key, int plen)
 	t_key cindex;
 
 	pos = 0;
-	n = t->trie;
+	n = rtnl_dereference(t->trie);
 
 	/* If we point to NULL, stop. Either the tree is empty and we should
 	 * just put a new leaf in if, or we have reached an empty child slot,
@@ -1756,7 +1769,7 @@ static struct leaf *leaf_walk_rcu(struct tnode *p, struct rt_trie_node *c)
 				continue;
 
 			if (IS_LEAF(c)) {
-				prefetch(p->child[idx]);
+				prefetch(rcu_dereference_rtnl(p->child[idx]));
 				return (struct leaf *) c;
 			}
 
@@ -2272,7 +2285,7 @@ static void *fib_trie_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 
 	/* walk rest of this hash chain */
 	h = tb->tb_id & (FIB_TABLE_HASHSZ - 1);
-	while ( (tb_node = rcu_dereference(tb->tb_hlist.next)) ) {
+	while ((tb_node = rcu_dereference(hlist_next_rcu(&tb->tb_hlist)))) {
 		tb = hlist_entry(tb_node, struct fib_table, tb_hlist);
 		n = fib_trie_get_first(iter, (struct trie *) tb->tb_data);
 		if (n)


