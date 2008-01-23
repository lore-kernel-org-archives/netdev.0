From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [IPV4 3/5] fib_trie: dump doesnt use RCU
Date: Wed, 23 Jan 2008 14:48:47 -0800
Message-ID: <20080123224858.918669715@linux-foundation.org>
References: <20080123224844.610730277@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:57041 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752226AbYAWXAs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2008 18:00:48 -0500
Content-Disposition: inline; filename=fib-dump-rtnl.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since fib dump (via netlink) holds the RTNL mutex, it is unnecessary
to use RCU, and it is impossible to get truncated (-EBUSY) result.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv4/fib_trie.c	2008-01-23 13:55:12.000000000 -0800
+++ b/net/ipv4/fib_trie.c	2008-01-23 14:00:35.000000000 -0800
@@ -1684,7 +1684,7 @@ static int trie_flush_leaf(struct trie *
  * Scan for the next right leaf starting at node p->child[idx]
  * Since we have back pointer, no recursion necessary.
  */
-static struct leaf *leaf_walk_rcu(struct tnode *p, struct node *c)
+static struct leaf *leaf_walk(struct tnode *p, struct node *c)
 {
 	do {
 		t_key idx;
@@ -1695,7 +1695,7 @@ static struct leaf *leaf_walk_rcu(struct
 			idx = 0;
 
 		while (idx < 1u << p->bits) {
-			c = tnode_get_child_rcu(p, idx++);
+			c = tnode_get_child(p, idx++);
 			if (!c)
 				continue;
 
@@ -1711,14 +1711,14 @@ static struct leaf *leaf_walk_rcu(struct
 
 		/* Node empty, walk back up to parent */
 		c = (struct node *) p;
-	} while ( (p = node_parent_rcu(c)) != NULL);
+	} while ( (p = node_parent(c)) != NULL);
 
 	return NULL; /* Root of trie */
 }
 
 static struct leaf *trie_firstleaf(struct trie *t)
 {
-	struct tnode *n = (struct tnode *) rcu_dereference(t->trie);
+	struct tnode *n = (struct tnode *) t->trie;
 
 	if (!n)
 		return NULL;
@@ -1726,7 +1726,7 @@ static struct leaf *trie_firstleaf(struc
 	if (IS_LEAF(n))          /* trie is just a leaf */
 		return (struct leaf *) n;
 
-	return leaf_walk_rcu(n, NULL);
+	return leaf_walk(n, NULL);
 }
 
 static struct leaf *trie_nextleaf(struct leaf *l)
@@ -1737,7 +1737,7 @@ static struct leaf *trie_nextleaf(struct
 	if (!p)
 		return NULL;	/* trie with just one leaf */
 
-	return leaf_walk_rcu(p, c);
+	return leaf_walk(p, c);
 }
 
 /*
@@ -1848,9 +1848,7 @@ static int fn_trie_dump_fa(t_key key, in
 	s_i = cb->args[4];
 	i = 0;
 
-	/* rcu_read_lock is hold by caller */
-
-	list_for_each_entry_rcu(fa, fah, fa_list) {
+	list_for_each_entry(fa, fah, fa_list) {
 		if (i < s_i) {
 			i++;
 			continue;
@@ -1885,8 +1883,7 @@ static int fn_trie_dump_leaf(struct leaf
 	s_i = cb->args[3];
 	i = 0;
 
-	/* rcu_read_lock is hold by caller */
-	hlist_for_each_entry_rcu(li, node, &l->list, hlist) {
+	hlist_for_each_entry(li, node, &l->list, hlist) {
 		if (i < s_i) {
 			i++;
 			continue;
@@ -1916,35 +1913,25 @@ static int fn_trie_dump(struct fib_table
 	struct trie *t = (struct trie *) tb->tb_data;
 	t_key key = cb->args[2];
 
-	rcu_read_lock();
+	ASSERT_RTNL();
+
 	/* Dump starting at last key.
 	 * Note: 0.0.0.0/0 (ie default) is first key.
 	 */
 	if (!key)
 		l = trie_firstleaf(t);
-	else {
+	else
 		l = fib_find_node(t, key);
-		if (!l) {
-			/* The table changed during the dump, rather than
-			 * giving partial data, just make application retry.
-			 */
-			rcu_read_unlock();
-			return -EBUSY;
-		}
-	}
 
 	while (l) {
 		cb->args[2] = l->key;
-		if (fn_trie_dump_leaf(l, tb, skb, cb) < 0) {
-			rcu_read_unlock();
+		if (fn_trie_dump_leaf(l, tb, skb, cb) < 0)
 			return -1;
-		}
 
 		l = trie_nextleaf(l);
 		memset(&cb->args[3], 0,
 		       sizeof(cb->args) - 3*sizeof(cb->args[0]));
 	}
-	rcu_read_unlock();
 
 	return skb->len;
 }

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>

