From: Lin Ming <mlin@ss.pku.edu.cn>
Subject: [PATCH] ipv4: clean up put_child
Date: Sun, 29 Jul 2012 20:00:03 +0800
Message-ID: <1343563203.16365.1.camel@monkey32>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [124.207.24.138] ([124.207.24.138]:48999 "EHLO
	mail.ss.pku.edu.cn" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751631Ab2G2MAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jul 2012 08:00:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first parameter struct trie *t is not used anymore.
Remove it.

Signed-off-by: Lin Ming <mlin@ss.pku.edu.cn>
---
 net/ipv4/fib_trie.c |   51 +++++++++++++++++++++++++--------------------------
 1 files changed, 25 insertions(+), 26 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 2a6fdc2..f0cdb30 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -159,7 +159,6 @@ struct trie {
 #endif
 };
 
-static void put_child(struct trie *t, struct tnode *tn, int i, struct rt_trie_node *n);
 static void tnode_put_child_reorg(struct tnode *tn, int i, struct rt_trie_node *n,
 				  int wasfull);
 static struct rt_trie_node *resize(struct trie *t, struct tnode *tn);
@@ -490,7 +489,7 @@ static inline int tnode_full(const struct tnode *tn, const struct rt_trie_node *
 	return ((struct tnode *) n)->pos == tn->pos + tn->bits;
 }
 
-static inline void put_child(struct trie *t, struct tnode *tn, int i,
+static inline void put_child(struct tnode *tn, int i,
 			     struct rt_trie_node *n)
 {
 	tnode_put_child_reorg(tn, i, n, -1);
@@ -754,8 +753,8 @@ static struct tnode *inflate(struct trie *t, struct tnode *tn)
 				goto nomem;
 			}
 
-			put_child(t, tn, 2*i, (struct rt_trie_node *) left);
-			put_child(t, tn, 2*i+1, (struct rt_trie_node *) right);
+			put_child(tn, 2*i, (struct rt_trie_node *) left);
+			put_child(tn, 2*i+1, (struct rt_trie_node *) right);
 		}
 	}
 
@@ -776,9 +775,9 @@ static struct tnode *inflate(struct trie *t, struct tnode *tn)
 			if (tkey_extract_bits(node->key,
 					      oldtnode->pos + oldtnode->bits,
 					      1) == 0)
-				put_child(t, tn, 2*i, node);
+				put_child(tn, 2*i, node);
 			else
-				put_child(t, tn, 2*i+1, node);
+				put_child(tn, 2*i+1, node);
 			continue;
 		}
 
@@ -786,8 +785,8 @@ static struct tnode *inflate(struct trie *t, struct tnode *tn)
 		inode = (struct tnode *) node;
 
 		if (inode->bits == 1) {
-			put_child(t, tn, 2*i, rtnl_dereference(inode->child[0]));
-			put_child(t, tn, 2*i+1, rtnl_dereference(inode->child[1]));
+			put_child(tn, 2*i, rtnl_dereference(inode->child[0]));
+			put_child(tn, 2*i+1, rtnl_dereference(inode->child[1]));
 
 			tnode_free_safe(inode);
 			continue;
@@ -817,22 +816,22 @@ static struct tnode *inflate(struct trie *t, struct tnode *tn)
 		 */
 
 		left = (struct tnode *) tnode_get_child(tn, 2*i);
-		put_child(t, tn, 2*i, NULL);
+		put_child(tn, 2*i, NULL);
 
 		BUG_ON(!left);
 
 		right = (struct tnode *) tnode_get_child(tn, 2*i+1);
-		put_child(t, tn, 2*i+1, NULL);
+		put_child(tn, 2*i+1, NULL);
 
 		BUG_ON(!right);
 
 		size = tnode_child_length(left);
 		for (j = 0; j < size; j++) {
-			put_child(t, left, j, rtnl_dereference(inode->child[j]));
-			put_child(t, right, j, rtnl_dereference(inode->child[j + size]));
+			put_child(left, j, rtnl_dereference(inode->child[j]));
+			put_child(right, j, rtnl_dereference(inode->child[j + size]));
 		}
-		put_child(t, tn, 2*i, resize(t, left));
-		put_child(t, tn, 2*i+1, resize(t, right));
+		put_child(tn, 2*i, resize(t, left));
+		put_child(tn, 2*i+1, resize(t, right));
 
 		tnode_free_safe(inode);
 	}
@@ -877,7 +876,7 @@ static struct tnode *halve(struct trie *t, struct tnode *tn)
 			if (!newn)
 				goto nomem;
 
-			put_child(t, tn, i/2, (struct rt_trie_node *)newn);
+			put_child(tn, i/2, (struct rt_trie_node *)newn);
 		}
 
 	}
@@ -892,21 +891,21 @@ static struct tnode *halve(struct trie *t, struct tnode *tn)
 		if (left == NULL) {
 			if (right == NULL)    /* Both are empty */
 				continue;
-			put_child(t, tn, i/2, right);
+			put_child(tn, i/2, right);
 			continue;
 		}
 
 		if (right == NULL) {
-			put_child(t, tn, i/2, left);
+			put_child(tn, i/2, left);
 			continue;
 		}
 
 		/* Two nonempty children */
 		newBinNode = (struct tnode *) tnode_get_child(tn, i/2);
-		put_child(t, tn, i/2, NULL);
-		put_child(t, newBinNode, 0, left);
-		put_child(t, newBinNode, 1, right);
-		put_child(t, tn, i/2, resize(t, newBinNode));
+		put_child(tn, i/2, NULL);
+		put_child(newBinNode, 0, left);
+		put_child(newBinNode, 1, right);
+		put_child(tn, i/2, resize(t, newBinNode));
 	}
 	tnode_free_safe(oldtnode);
 	return tn;
@@ -1125,7 +1124,7 @@ static struct list_head *fib_insert_node(struct trie *t, u32 key, int plen)
 		node_set_parent((struct rt_trie_node *)l, tp);
 
 		cindex = tkey_extract_bits(key, tp->pos, tp->bits);
-		put_child(t, tp, cindex, (struct rt_trie_node *)l);
+		put_child(tp, cindex, (struct rt_trie_node *)l);
 	} else {
 		/* Case 3: n is a LEAF or a TNODE and the key doesn't match. */
 		/*
@@ -1155,12 +1154,12 @@ static struct list_head *fib_insert_node(struct trie *t, u32 key, int plen)
 		node_set_parent((struct rt_trie_node *)tn, tp);
 
 		missbit = tkey_extract_bits(key, newpos, 1);
-		put_child(t, tn, missbit, (struct rt_trie_node *)l);
-		put_child(t, tn, 1-missbit, n);
+		put_child(tn, missbit, (struct rt_trie_node *)l);
+		put_child(tn, 1-missbit, n);
 
 		if (tp) {
 			cindex = tkey_extract_bits(key, tp->pos, tp->bits);
-			put_child(t, tp, cindex, (struct rt_trie_node *)tn);
+			put_child(tp, cindex, (struct rt_trie_node *)tn);
 		} else {
 			rcu_assign_pointer(t->trie, (struct rt_trie_node *)tn);
 			tp = tn;
@@ -1619,7 +1618,7 @@ static void trie_leaf_remove(struct trie *t, struct leaf *l)
 
 	if (tp) {
 		t_key cindex = tkey_extract_bits(l->key, tp->pos, tp->bits);
-		put_child(t, tp, cindex, NULL);
+		put_child(tp, cindex, NULL);
 		trie_rebalance(t, tp);
 	} else
 		RCU_INIT_POINTER(t->trie, NULL);
-- 
1.7.2.5
