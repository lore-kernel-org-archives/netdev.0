From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [FIB]: Fix rcu_dereference() abuses in fib_trie.c
Date: Tue, 15 Jan 2008 09:29:40 +0100
Message-ID: <20080115092940.311fb2c3.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:56308 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750702AbYAOI3p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2008 03:29:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

node_parent() and tnode_get_child() currently use rcu_dereference().

These functions are called from both 
- readers only paths (where rcu_dereference() is needed), and 
- writer path (where rcu_dereference() is not needed)

To make explicit where rcu_dereference() is really needed, I introduced
new node_parent_rcu() and tnode_get_child_rcu() functions which use
rcu_dereference(), while node_parent() and tnode_get_child() dont use it.

Then I changed calling sites where rcu_dereference() was really needed to
call the _rcu() variants.

This should have no impact but for alpha architecture, and may help future
sparse checks.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 6dab753..e053775 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -165,9 +165,13 @@ static struct kmem_cache *fn_alias_kmem __read_mostly;
 
 static inline struct tnode *node_parent(struct node *node)
 {
-	struct tnode *ret;
+	return (struct tnode *)(node->parent & ~NODE_TYPE_MASK);
+}
+
+static inline struct tnode *node_parent_rcu(struct node *node)
+{
+	struct tnode *ret = node_parent(node);
 
-	ret = (struct tnode *)(node->parent & ~NODE_TYPE_MASK);
 	return rcu_dereference(ret);
 }
 
@@ -177,13 +181,18 @@ static inline void node_set_parent(struct node *node, struct tnode *ptr)
 			   (unsigned long)ptr | NODE_TYPE(node));
 }
 
-/* rcu_read_lock needs to be hold by caller from readside */
+static inline struct node *tnode_get_child(struct tnode *tn, unsigned int i)
+{
+	BUG_ON(i >= 1U << tn->bits);
 
-static inline struct node *tnode_get_child(struct tnode *tn, int i)
+	return tn->child[i];
+}
+
+static inline struct node *tnode_get_child_rcu(struct tnode *tn, unsigned int i)
 {
-	BUG_ON(i >= 1 << tn->bits);
+	struct node *ret = tnode_get_child(tn, i);
 
-	return rcu_dereference(tn->child[i]);
+	return rcu_dereference(ret);
 }
 
 static inline int tnode_child_length(const struct tnode *tn)
@@ -938,7 +947,7 @@ fib_find_node(struct trie *t, u32 key)
 
 		if (tkey_sub_equals(tn->key, pos, tn->pos-pos, key)) {
 			pos = tn->pos + tn->bits;
-			n = tnode_get_child(tn, tkey_extract_bits(key, tn->pos, tn->bits));
+			n = tnode_get_child_rcu(tn, tkey_extract_bits(key, tn->pos, tn->bits));
 		} else
 			break;
 	}
@@ -1685,7 +1694,7 @@ static struct leaf *nextleaf(struct trie *t, struct leaf *thisleaf)
 
 		p = (struct tnode*) trie;  /* Start */
 	} else
-		p = node_parent(c);
+		p = node_parent_rcu(c);
 
 	while (p) {
 		int pos, last;
@@ -1722,7 +1731,7 @@ static struct leaf *nextleaf(struct trie *t, struct leaf *thisleaf)
 up:
 		/* No more children go up one step  */
 		c = (struct node *) p;
-		p = node_parent(c);
+		p = node_parent_rcu(c);
 	}
 	return NULL; /* Ready. Root of trie */
 }
@@ -1984,7 +1993,7 @@ static struct node *fib_trie_get_next(struct fib_trie_iter *iter)
 		 iter->tnode, iter->index, iter->depth);
 rescan:
 	while (cindex < (1<<tn->bits)) {
-		struct node *n = tnode_get_child(tn, cindex);
+		struct node *n = tnode_get_child_rcu(tn, cindex);
 
 		if (n) {
 			if (IS_LEAF(n)) {
@@ -2003,7 +2012,7 @@ rescan:
 	}
 
 	/* Current node exhausted, pop back up */
-	p = node_parent((struct node *)tn);
+	p = node_parent_rcu((struct node *)tn);
 	if (p) {
 		cindex = tkey_extract_bits(tn->key, p->pos, p->bits)+1;
 		tn = p;
@@ -2312,7 +2321,7 @@ static int fib_trie_seq_show(struct seq_file *seq, void *v)
 	if (v == SEQ_START_TOKEN)
 		return 0;
 
-	if (!node_parent(n)) {
+	if (!node_parent_rcu(n)) {
 		if (iter->trie == iter->trie_local)
 			seq_puts(seq, "<local>:\n");
 		else
