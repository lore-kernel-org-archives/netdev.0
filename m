From: akpm@linux-foundation.org
Subject: [patch 12/28] fib_trie: cleanup
Date: Fri, 10 Aug 2007 14:11:56 -0700
Message-ID: <200708102111.l7ALBuvR009406@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	shemminger@linux-foundation.org, paulmck@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33811 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S942303AbXHJVMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:12:05 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>

Try this out:
     * replace macro's with inlines
     * get rid of places doing multiple evaluations of NODE_PARENT

[akpm@linux-foundation.org: rcu_dereference wants an lval]
Cc: "David S. Miller" <davem@davemloft.net>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/ipv4/fib_trie.c |   68 ++++++++++++++++++++++--------------------
 1 files changed, 36 insertions(+), 32 deletions(-)

diff -puN net/ipv4/fib_trie.c~fib_trie-cleanup net/ipv4/fib_trie.c
--- a/net/ipv4/fib_trie.c~fib_trie-cleanup
+++ a/net/ipv4/fib_trie.c
@@ -93,15 +93,8 @@ typedef unsigned int t_key;
 #define T_TNODE 0
 #define T_LEAF  1
 #define NODE_TYPE_MASK	0x1UL
-#define NODE_PARENT(node) \
-	((struct tnode *)rcu_dereference(((node)->parent & ~NODE_TYPE_MASK)))
-
 #define NODE_TYPE(node) ((node)->parent & NODE_TYPE_MASK)
 
-#define NODE_SET_PARENT(node, ptr)		\
-	rcu_assign_pointer((node)->parent,	\
-			   ((unsigned long)(ptr)) | NODE_TYPE(node))
-
 #define IS_TNODE(n) (!(n->parent & T_LEAF))
 #define IS_LEAF(n) (n->parent & T_LEAF)
 
@@ -174,6 +167,19 @@ static void tnode_free(struct tnode *tn)
 static struct kmem_cache *fn_alias_kmem __read_mostly;
 static struct trie *trie_local = NULL, *trie_main = NULL;
 
+static inline struct tnode *node_parent(struct node *node)
+{
+	struct tnode *ret;
+
+	ret = (struct tnode *)(node->parent & ~NODE_TYPE_MASK);
+	return rcu_dereference(ret);
+}
+
+static inline void node_set_parent(struct node *node, struct tnode *ptr)
+{
+	rcu_assign_pointer(node->parent,
+			   (unsigned long)ptr | NODE_TYPE(node));
+}
 
 /* rcu_read_lock needs to be hold by caller from readside */
 
@@ -446,7 +452,7 @@ static void tnode_put_child_reorg(struct
 		tn->full_children++;
 
 	if (n)
-		NODE_SET_PARENT(n, tn);
+		node_set_parent(n, tn);
 
 	rcu_assign_pointer(tn->child[i], n);
 }
@@ -481,7 +487,7 @@ static struct node *resize(struct trie *
 				continue;
 
 			/* compress one level */
-			NODE_SET_PARENT(n, NULL);
+			node_set_parent(n, NULL);
 			tnode_free(tn);
 			return n;
 		}
@@ -636,7 +642,7 @@ static struct node *resize(struct trie *
 
 			/* compress one level */
 
-			NODE_SET_PARENT(n, NULL);
+			node_set_parent(n, NULL);
 			tnode_free(tn);
 			return n;
 		}
@@ -961,24 +967,21 @@ fib_find_node(struct trie *t, u32 key)
 static struct node *trie_rebalance(struct trie *t, struct tnode *tn)
 {
 	int wasfull;
-	t_key cindex, key;
-	struct tnode *tp = NULL;
-
-	key = tn->key;
+	t_key cindex, key = tn->key;
+	struct tnode *tp;
 
-	while (tn != NULL && NODE_PARENT(tn) != NULL) {
-
-		tp = NODE_PARENT(tn);
+	while (tn != NULL && (tp = node_parent((struct node *)tn)) != NULL) {
 		cindex = tkey_extract_bits(key, tp->pos, tp->bits);
 		wasfull = tnode_full(tp, tnode_get_child(tp, cindex));
 		tn = (struct tnode *) resize (t, (struct tnode *)tn);
 		tnode_put_child_reorg((struct tnode *)tp, cindex,(struct node*)tn, wasfull);
 
-		if (!NODE_PARENT(tn))
+		tp = node_parent((struct node *) tn);
+		if (!tp)
 			break;
-
-		tn = NODE_PARENT(tn);
+		tn = tp;
 	}
+
 	/* Handle last (top) tnode */
 	if (IS_TNODE(tn))
 		tn = (struct tnode*) resize(t, (struct tnode *)tn);
@@ -1031,7 +1034,7 @@ fib_insert_node(struct trie *t, int *err
 			pos = tn->pos + tn->bits;
 			n = tnode_get_child(tn, tkey_extract_bits(key, tn->pos, tn->bits));
 
-			BUG_ON(n && NODE_PARENT(n) != tn);
+			BUG_ON(n && node_parent(n) != tn);
 		} else
 			break;
 	}
@@ -1083,7 +1086,7 @@ fib_insert_node(struct trie *t, int *err
 	if (t->trie && n == NULL) {
 		/* Case 2: n is NULL, and will just insert a new leaf */
 
-		NODE_SET_PARENT(l, tp);
+		node_set_parent((struct node *)l, tp);
 
 		cindex = tkey_extract_bits(key, tp->pos, tp->bits);
 		put_child(t, (struct tnode *)tp, cindex, (struct node *)l);
@@ -1114,7 +1117,7 @@ fib_insert_node(struct trie *t, int *err
 			goto err;
 		}
 
-		NODE_SET_PARENT(tn, tp);
+		node_set_parent((struct node *)tn, tp);
 
 		missbit = tkey_extract_bits(key, newpos, 1);
 		put_child(t, tn, missbit, (struct node *)l);
@@ -1495,12 +1498,13 @@ backtrace:
 		if (chopped_off <= pn->bits) {
 			cindex &= ~(1 << (chopped_off-1));
 		} else {
-			if (NODE_PARENT(pn) == NULL)
+			struct tnode *parent = node_parent((struct node *) pn);
+			if (!parent)
 				goto failed;
 
 			/* Get Child's index */
-			cindex = tkey_extract_bits(pn->key, NODE_PARENT(pn)->pos, NODE_PARENT(pn)->bits);
-			pn = NODE_PARENT(pn);
+			cindex = tkey_extract_bits(pn->key, parent->pos, parent->bits);
+			pn = parent;
 			chopped_off = 0;
 
 #ifdef CONFIG_IP_FIB_TRIE_STATS
@@ -1536,7 +1540,7 @@ static int trie_leaf_remove(struct trie 
 		check_tnode(tn);
 		n = tnode_get_child(tn ,tkey_extract_bits(key, tn->pos, tn->bits));
 
-		BUG_ON(n && NODE_PARENT(n) != tn);
+		BUG_ON(n && node_parent(n) != tn);
 	}
 	l = (struct leaf *) n;
 
@@ -1551,7 +1555,7 @@ static int trie_leaf_remove(struct trie 
 	t->revision++;
 	t->size--;
 
-	tp = NODE_PARENT(n);
+	tp = node_parent(n);
 	tnode_free((struct tnode *) n);
 
 	if (tp) {
@@ -1703,7 +1707,7 @@ static struct leaf *nextleaf(struct trie
 
 		p = (struct tnode*) trie;  /* Start */
 	} else
-		p = (struct tnode *) NODE_PARENT(c);
+		p = node_parent(c);
 
 	while (p) {
 		int pos, last;
@@ -1740,7 +1744,7 @@ static struct leaf *nextleaf(struct trie
 up:
 		/* No more children go up one step  */
 		c = (struct node *) p;
-		p = (struct tnode *) NODE_PARENT(p);
+		p = node_parent(c);
 	}
 	return NULL; /* Ready. Root of trie */
 }
@@ -2043,7 +2047,7 @@ rescan:
 	}
 
 	/* Current node exhausted, pop back up */
-	p = NODE_PARENT(tn);
+	p = node_parent((struct node *)tn);
 	if (p) {
 		cindex = tkey_extract_bits(tn->key, p->pos, p->bits)+1;
 		tn = p;
@@ -2317,7 +2321,7 @@ static int fib_trie_seq_show(struct seq_
 	if (v == SEQ_START_TOKEN)
 		return 0;
 
-	if (!NODE_PARENT(n)) {
+	if (!node_parent(n)) {
 		if (iter->trie == trie_local)
 			seq_puts(seq, "<local>:\n");
 		else
_
