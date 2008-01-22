From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [IPV4 8/9] fib_trie: avoid extra search on delete
Date: Tue, 22 Jan 2008 15:37:41 -0800
Message-ID: <20080122233927.217926990@linux-foundation.org>
References: <20080122233733.404145234@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:33108 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757318AbYAWAJw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2008 19:09:52 -0500
Content-Disposition: inline; filename=trie-remove-desquare.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get rid of extra search that made route deletion O(n).

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv4/fib_trie.c	2008-01-22 15:24:41.000000000 -0800
+++ b/net/ipv4/fib_trie.c	2008-01-22 15:25:32.000000000 -0800
@@ -1542,49 +1542,23 @@ found:
 	return ret;
 }
 
-/* only called from updater side */
-static int trie_leaf_remove(struct trie *t, t_key key)
+/*
+ * Remove the leaf and return parent.
+ */
+static void trie_leaf_remove(struct trie *t, struct leaf *l)
 {
-	t_key cindex;
-	struct tnode *tp = NULL;
-	struct node *n = t->trie;
-	struct leaf *l;
-
-	pr_debug("entering trie_leaf_remove(%p)\n", n);
-
-	/* Note that in the case skipped bits, those bits are *not* checked!
-	 * When we finish this, we will have NULL or a T_LEAF, and the
-	 * T_LEAF may or may not match our key.
-	 */
-
-	while (n != NULL && IS_TNODE(n)) {
-		struct tnode *tn = (struct tnode *) n;
-		check_tnode(tn);
-		n = tnode_get_child(tn, tkey_extract_bits(key,
-							  tn->pos, tn->bits));
-
-		BUG_ON(n && node_parent(n) != tn);
-	}
-	l = (struct leaf *) n;
-
-	if (!n || !tkey_equals(l->key, key))
-		return 0;
+	struct tnode *tp = node_parent((struct node *) l);
 
-	/*
-	 * Key found.
-	 * Remove the leaf and rebalance the tree
-	 */
-	tp = node_parent(n);
-	tnode_free((struct tnode *) n);
+	pr_debug("entering trie_leaf_remove(%p)\n", l);
 
 	if (tp) {
-		cindex = tkey_extract_bits(key, tp->pos, tp->bits);
+		t_key cindex = tkey_extract_bits(l->key, tp->pos, tp->bits);
 		put_child(t, (struct tnode *)tp, cindex, NULL);
 		rcu_assign_pointer(t->trie, trie_rebalance(t, tp));
 	} else
 		rcu_assign_pointer(t->trie, NULL);
 
-	return 1;
+	tnode_free((struct tnode *) l);
 }
 
 /*
@@ -1662,7 +1636,7 @@ static int fn_trie_delete(struct fib_tab
 	}
 
 	if (hlist_empty(&l->list))
-		trie_leaf_remove(t, key);
+		trie_leaf_remove(t, l);
 
 	if (fa->fa_state & FA_S_ACCESSED)
 		rt_cache_flush(-1);
@@ -1775,19 +1749,19 @@ static struct leaf *trie_nextleaf(struct
 static int fn_trie_flush(struct fib_table *tb)
 {
 	struct trie *t = (struct trie *) tb->tb_data;
-	struct leaf *ll = NULL, *l = NULL;
+	struct leaf *l, *ll = NULL;
 	int found = 0;
 
 	for (l = trie_firstleaf(t); l; l = trie_nextleaf(l)) {
 		found += trie_flush_leaf(t, l);
 
 		if (ll && hlist_empty(&ll->list))
-			trie_leaf_remove(t, ll->key);
+			trie_leaf_remove(t, ll);
 		ll = l;
 	}
 
 	if (ll && hlist_empty(&ll->list))
-		trie_leaf_remove(t, ll->key);
+		trie_leaf_remove(t, ll);
 
 	pr_debug("trie_flush found=%d\n", found);
 	return found;

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>

