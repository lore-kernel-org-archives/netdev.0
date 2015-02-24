From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 21/29] fib_trie: Rewrite handling of RCU to include
 parent in replacement
Date: Tue, 24 Feb 2015 12:50:16 -0800
Message-ID: <20150224205016.26106.87489.stgit@ahduyck-vm-fedora20>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45595 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752997AbbBXUuT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 15:50:19 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKoIPC016766
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:50:19 -0500
Received: from [192.168.122.173] (ovpn-112-73.phx2.redhat.com [10.3.112.73])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKoGNj031080
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:50:17 -0500
In-Reply-To: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change makes it so that when we either insert, or resize a tnode or
leaf we will also replace the parent of that tnode or leaf.  This is
necessary to allow for the introduction of a key_vector array inside of the
root node and tnodes.  By doing this it will be possible to push the values
currently contained in the key_vector up one level so that they can be
accessed sooner.

This is still a work in progress.  The current implementation makes resize
more expensive since we have to re-allocate the node for each child that
gets resized.  I hope to make it so that we can cut this down to at most 2
allocations per node in the future.

For example if I allocate 8K subnets on a dummy interface it used to take
.6 seconds to remove dummy0, now it takes ~2.4.  Most of this is due to the
fact that there are 8K child tnodes that are collapsed meaning that the
parent tnode has to be replaced 8K times.

The same issue doesn't seem to occur though if I am using only routes.  So
for example if I assing 8K routes to the same interface it still removes
all 8K very quickly. I believe this is due to the fact that the local table
is doing a mish-mash of the fib_table_flush and fib_table_delete whereas
the main routing table is likely handling all routes by flagging them as
dead and then flushing them.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |  320 +++++++++++++++++++++++++++++++++++----------------
 1 file changed, 217 insertions(+), 103 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 2db318e..58c8a89 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -136,6 +136,10 @@ struct trie_stat {
 };
 
 struct trie {
+	/* key vector must be first to allow for use of tb->tb_data to get
+	 * get the key vector OR trie as there are a few spots where getting
+	 * the kv via the trie is messier than just getting it from tb_data.
+	 */
 	struct key_vector kv[1];
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 	struct trie_use_stats __percpu *stats;
@@ -179,12 +183,7 @@ static inline struct fib_table *table_info(struct key_vector *kv)
 #define get_child_rcu(tn, i) rcu_dereference_rtnl((tn)->tnode[i])
 
 /* wrapper for rcu_assign_pointer */
-static inline void node_set_parent(struct key_vector *n, struct key_vector *tp)
-{
-	if (n)
-		rcu_assign_pointer(tn_info(n)->parent, tp);
-}
-
+#define node_set_parent(n, p) rcu_assign_pointer(tn_info(n)->parent, p)
 #define NODE_INIT_PARENT(n, p) RCU_INIT_POINTER(tn_info(n)->parent, p)
 
 /* This provides us with the number of children in this node, in the case of a
@@ -339,35 +338,6 @@ static struct key_vector *leaf_new(t_key key, struct fib_alias *fa)
 	return l;
 }
 
-static struct key_vector *tnode_new(t_key key, int pos, int bits)
-{
-	size_t sz = TNODE_SIZE(1ul << bits);
-	struct tnode *tnode = tnode_alloc(sz);
-	unsigned int shift = pos + bits;
-	struct key_vector *tn = tnode->kv;
-
-	/* verify bits and pos their msb bits clear and values are valid */
-	BUG_ON(!bits || (shift > KEYLENGTH));
-
-	pr_debug("AT %p s=%zu %zu\n", tnode, TNODE_SIZE(0),
-		 sizeof(struct key_vector *) << bits);
-
-	if (!tnode)
-		return NULL;
-
-	if (bits == KEYLENGTH)
-		tnode->full_children = 1;
-	else
-		tnode->empty_children = 1ul << bits;
-
-	tn->key = (shift < KEYLENGTH) ? (key >> shift) << shift : 0;
-	tn->pos = pos;
-	tn->bits = bits;
-	tn->slen = pos;
-
-	return tn;
-}
-
 /* Check whether a tnode 'n' is "full", i.e. it is an internal node
  * and no bits are skipped. See discussion in dyntree paper p. 6
  */
@@ -413,7 +383,7 @@ static void update_children(struct key_vector *tn)
 	unsigned long i;
 
 	/* update all of the child parent pointers */
-	for (i = child_length(tn); i;) {
+	for (i = IS_TRIE(tn) ? 1 : child_length(tn); i;) {
 		struct key_vector *inode = get_child(tn, --i);
 
 		if (!inode)
@@ -439,6 +409,106 @@ static inline void put_child_root(struct key_vector *tp, t_key key,
 		put_child(tp, get_index(key, tp), n);
 }
 
+static struct key_vector *tnode_new(struct key_vector *pn, t_key key,
+				    int pos, int bits)
+{
+	size_t sz = TNODE_SIZE(1ul << bits);
+	struct tnode *tnode = tnode_alloc(sz);
+	struct key_vector *tn = tnode->kv;
+	unsigned int shift = pos + bits;
+
+	/* verify bits and pos their msb bits clear and values are valid */
+	BUG_ON(!bits || (shift > KEYLENGTH));
+
+	pr_debug("AT %p s=%zu %zu\n", tnode, TNODE_SIZE(0),
+		 sizeof(struct key_vector *) << bits);
+
+	if (!tnode)
+		return NULL;
+
+	/* populate tn_info section */
+	if (bits == KEYLENGTH)
+		tnode->full_children = 1;
+	else
+		tnode->empty_children = 1ul << bits;
+
+	/* populate key vector */
+	tn->key = (shift < KEYLENGTH) ? (key >> shift) << shift : 0;
+	tn->pos = pos;
+	tn->bits = bits;
+	tn->slen = pos;
+
+	/* link parent to node */
+	NODE_INIT_PARENT(tn, pn);
+	put_child_root(pn, tn->key, tn);
+
+	return tn;
+}
+
+static struct key_vector *tnode_clone(struct tnode *oldtnode)
+{
+	size_t sz = TNODE_SIZE(1ul << oldtnode->tn_bits);
+	struct tnode *tn = tnode_alloc(sz);
+
+	if (!tn)
+		return NULL;
+
+	memcpy(tn, oldtnode, sz);
+	return tn->kv;
+}
+
+static void tnode_replace(struct key_vector *oldtn,
+			  struct key_vector *tn)
+{
+	struct key_vector *pn = node_parent(oldtn);
+	unsigned long i = get_index(tn->key, pn);
+
+	/* setup the parent pointer out of and back into this node */
+	rcu_assign_pointer(pn->tnode[i], tn);
+
+	/* update all of the child parent pointers */
+	update_children(tn);
+
+	/* all pointers should be clean so we are done */
+	node_free(oldtn);
+}
+
+static struct key_vector *fib_table_clone(struct fib_table *oldtb)
+{
+	size_t sz = sizeof(struct fib_table) + sizeof(struct trie);
+	struct fib_table *tb;
+
+	tb = kmalloc(sz, GFP_KERNEL);
+	if (!tb)
+		return NULL;
+
+	memcpy(tb, oldtb, sz);
+	return (struct key_vector *)tb->tb_data;
+}
+
+static void __trie_drop_rcu(struct rcu_head *head)
+{
+	struct trie *t = container_of(head, struct trie, rcu);
+
+	kfree(table_info(t->kv));
+}
+
+static inline void fib_trie_replace(struct net *net,
+				    struct key_vector *oldtn,
+				    struct key_vector *tn)
+{
+	struct fib_table *tb = table_info(oldtn);
+	struct trie *t = (struct trie *)tb->tb_data;
+
+	/* replace the old table */
+	fib_replace_table(net, tb, table_info(tn));
+
+	/* update any child pointers */
+	update_children(tn);
+
+	call_rcu(&t->rcu, __trie_drop_rcu);
+}
+
 static inline void tnode_free_init(struct key_vector *tn)
 {
 	tn_info(tn)->rcu.next = NULL;
@@ -457,7 +527,7 @@ static void tnode_free(struct key_vector *tn)
 
 	while (head) {
 		head = head->next;
-		tnode_free_size += TNODE_SIZE(1 << tn->bits);
+		tnode_free_size += TNODE_SIZE(1ul << tn->bits);
 		node_free(tn);
 
 		tn = container_of(head, struct tnode, rcu)->kv;
@@ -469,22 +539,37 @@ static void tnode_free(struct key_vector *tn)
 	}
 }
 
-static struct key_vector *replace(struct net *net, struct trie *t,
-				  struct key_vector *oldtnode,
-				  struct key_vector *tn)
+static struct key_vector *vector_clone(struct key_vector *kv)
 {
-	struct key_vector *tp = node_parent(oldtnode);
-	unsigned long i;
+	/* generate a clone of either the trie, or the tnode based
+	 * if the key vector indicates if it is the root.
+	 */
+	return IS_TRIE(kv) ? fib_table_clone(table_info(kv)) :
+			     tnode_clone(tn_info(kv));
+}
 
-	/* setup the parent pointer out of and back into this node */
-	NODE_INIT_PARENT(tn, tp);
-	put_child_root(tp, tn->key, tn);
+static void vector_free(struct key_vector *kv)
+{
+	if (IS_TRIE(kv))
+		kfree(table_info(kv));
+	else
+		node_free(kv);
+}
 
-	/* update all of the child parent pointers */
-	update_children(tn);
+static void vector_replace(struct net *net, struct key_vector *oldtn,
+			   struct key_vector *tn)
+{
+	/* setup the parent pointer out of and back into this node */
+	if (IS_TRIE(oldtn))
+		fib_trie_replace(net, oldtn, tn);
+	else
+		tnode_replace(oldtn, tn);
+}
 
-	/* all pointers should be clean so we are done */
-	tnode_free(oldtnode);
+static struct key_vector *resize_children(struct net *net, struct trie *t,
+					  struct key_vector *tn)
+{
+	unsigned long i;
 
 	/* resize children now that oldtnode is freed */
 	for (i = child_length(tn); i;) {
@@ -495,19 +580,25 @@ static struct key_vector *replace(struct net *net, struct trie *t,
 			tn = resize(net, t, inode);
 	}
 
-	return tp;
+	return node_parent(tn);
 }
 
 static struct key_vector *inflate(struct net *net, struct trie *t,
 				  struct key_vector *oldtnode)
 {
-	struct key_vector *tn;
+	struct key_vector *tn, *pn;
 	unsigned long i;
 	t_key m;
 
 	pr_debug("In inflate\n");
 
-	tn = tnode_new(oldtnode->key, oldtnode->pos - 1, oldtnode->bits + 1);
+	/* clone parent for us to place new tnode into */
+	pn = vector_clone(node_parent(oldtnode));
+	if (!pn)
+		return NULL;
+
+	tn = tnode_new(pn, oldtnode->key,
+		       oldtnode->pos - 1, oldtnode->bits + 1);
 	if (!tn)
 		goto notnode;
 
@@ -558,10 +649,12 @@ static struct key_vector *inflate(struct net *net, struct trie *t,
 		 * node0 and node1. So... we synthesize that bit in the
 		 * two new keys.
 		 */
-		node1 = tnode_new(inode->key | m, inode->pos, inode->bits - 1);
+		node1 = tnode_new(tn, inode->key | m,
+				  inode->pos, inode->bits - 1);
 		if (!node1)
 			goto nomem;
-		node0 = tnode_new(inode->key, inode->pos, inode->bits - 1);
+		node0 = tnode_new(tn, inode->key,
+				  inode->pos, inode->bits - 1);
 
 		tnode_free_append(tn, node1);
 		if (!node0)
@@ -575,40 +668,40 @@ static struct key_vector *inflate(struct net *net, struct trie *t,
 			put_child(node1, --j, get_child(inode, --k));
 			put_child(node0, j, get_child(inode, j));
 		}
-
-		/* link new nodes to parent */
-		NODE_INIT_PARENT(node1, tn);
-		NODE_INIT_PARENT(node0, tn);
-
-		/* link parent to nodes */
-		put_child(tn, 2 * i + 1, node1);
-		put_child(tn, 2 * i, node0);
 	}
 
-	/* setup the parent pointers into and out of this node */
-	return replace(net, t, oldtnode, tn);
+	/* swap new parent for old and free oldtnode */
+	vector_replace(net, node_parent(oldtnode), pn);
+	tnode_free(oldtnode);
+
+	return resize_children(net, t, tn);
 nomem:
 	/* all pointers should be clean so we are done */
 	tnode_free(tn);
 notnode:
+	vector_free(pn);
+
 	return NULL;
 }
 
 static struct key_vector *halve(struct net *net, struct trie *t,
 				struct key_vector *oldtnode)
 {
-	struct key_vector *tn;
+	struct key_vector *tn, *pn;
 	unsigned long i;
 
 	pr_debug("In halve\n");
 
-	tn = tnode_new(oldtnode->key, oldtnode->pos + 1, oldtnode->bits - 1);
+	/* clone parent for us to place new tnode into */
+	pn = vector_clone(node_parent(oldtnode));
+	if (!pn)
+		return NULL;
+
+	tn = tnode_new(pn, oldtnode->key,
+		       oldtnode->pos + 1, oldtnode->bits - 1);
 	if (!tn)
 		goto notnode;
 
-	/* prepare oldtnode to be freed */
-	tnode_free_init(oldtnode);
-
 	/* Assemble all of the pointers in our cluster, in this case that
 	 * represents all of the pointers out of our allocated nodes that
 	 * point to existing tnodes and the links between our allocated
@@ -626,7 +719,7 @@ static struct key_vector *halve(struct net *net, struct trie *t,
 		}
 
 		/* Two nonempty children */
-		inode = tnode_new(node0->key, oldtnode->pos, 1);
+		inode = tnode_new(tn, node0->key, oldtnode->pos, 1);
 		if (!inode)
 			goto nomem;
 		tnode_free_append(tn, inode);
@@ -634,40 +727,56 @@ static struct key_vector *halve(struct net *net, struct trie *t,
 		/* initialize pointers out of node */
 		put_child(inode, 1, node1);
 		put_child(inode, 0, node0);
-		NODE_INIT_PARENT(inode, tn);
-
-		/* link parent to node */
-		put_child(tn, i / 2, inode);
 	}
 
-	/* setup the parent pointers into and out of this node */
-	return replace(net, t, oldtnode, tn);
+	/* swap new parent for old and free oldtnode */
+	vector_replace(net, node_parent(oldtnode), pn);
+	node_free(oldtnode);
+
+	return resize_children(net, t, tn);
 nomem:
 	/* all pointers should be clean so we are done */
 	tnode_free(tn);
 notnode:
+	vector_free(pn);
+
 	return NULL;
 }
 
 static struct key_vector *collapse(struct net *net, struct trie *t,
 				   struct key_vector *oldtnode)
 {
-	struct key_vector *n, *tp;
+	struct key_vector *pn = node_parent(oldtnode);
 	unsigned long i;
 
 	/* scan the tnode looking for that one child that might still exist */
-	for (n = NULL, i = child_length(oldtnode); !n && i;)
-		n = get_child(oldtnode, --i);
+	for (i = child_length(oldtnode); i--;) {
+		struct key_vector *n = get_child(oldtnode, i);
+
+		if (!n)
+			continue;
 
-	/* compress one level */
-	tp = node_parent(oldtnode);
-	put_child_root(tp, oldtnode->key, n);
-	node_set_parent(n, tp);
+		/* attempt to clone parent, on failure return old parent */
+		pn = vector_clone(pn);
+		if (!pn)
+			return node_parent(oldtnode);
 
-	/* drop dead node */
+		/* compress one level */
+		put_child_root(pn, oldtnode->key, n);
+
+		/* drop dead node */
+		vector_replace(net, node_parent(oldtnode), pn);
+		node_free(oldtnode);
+
+		/* resize child since it could be promoted to root */
+		return IS_TNODE(n) ? resize(net, t, n) : pn;
+	}
+
+	/* no children, just update pointer to NULL */
+	put_child_root(pn, oldtnode->key, NULL);
 	node_free(oldtnode);
 
-	return tp;
+	return pn;
 }
 
 static unsigned char update_suffix(struct key_vector *tn)
@@ -974,11 +1083,16 @@ static struct fib_table *trie_rebalance(struct net *net, struct trie *t,
 
 static struct fib_table *fib_insert_node(struct net *net, struct trie *t,
 					 struct key_vector *tp,
-					 struct fib_alias *new,
-					 t_key key)
+					 struct fib_alias *new, t_key key)
 {
-	struct key_vector *n, *l;
+	struct key_vector *tn, *l, *n;
 
+	/* allocate the new parent that must be replaced */
+	tn = vector_clone(tp);
+	if (!tn)
+		return NULL;
+
+	/* allocate the new leaf we will insert */
 	l = leaf_new(key, new);
 	if (!l)
 		goto noleaf;
@@ -993,32 +1107,33 @@ static struct fib_table *fib_insert_node(struct net *net, struct trie *t,
 	 *  leaves us in position for handling as case 3
 	 */
 	if (n) {
-		struct key_vector *tn;
-
-		tn = tnode_new(key, __fls(key ^ n->key), 1);
+		tn = tnode_new(tn, key, __fls(key ^ n->key), 1);
 		if (!tn)
 			goto notnode;
 
 		/* initialize routes out of node */
-		NODE_INIT_PARENT(tn, tp);
 		put_child(tn, get_index(key, tn) ^ 1, n);
 
-		/* start adding routes into the node */
-		put_child_root(tp, key, tn);
-		node_set_parent(n, tn);
-
-		/* parent now has a NULL spot where the leaf can go */
-		tp = tn;
+		/* pop back out to bring tn to the same level as tp */
+		n = tn;
+		tn = node_parent(tn);
+	} else {
+		/* indicate we are inserting at parent */
+		n = tn;
 	}
 
 	/* Case 3: n is NULL, and will just insert a new leaf */
-	NODE_INIT_PARENT(l, tp);
-	put_child_root(tp, key, l);
+	NODE_INIT_PARENT(l, n);
+	put_child_root(n, key, l);
 
-	return trie_rebalance(net, t, tp);
+	vector_replace(net, tp, tn);
+
+	return trie_rebalance(net, t, n);
 notnode:
 	node_free(l);
 noleaf:
+	vector_free(tn);
+
 	return NULL;
 }
 
@@ -1026,8 +1141,7 @@ static struct fib_table *fib_insert_alias(struct net *net, struct trie *t,
 					  struct key_vector *tp,
 					  struct key_vector *l,
 					  struct fib_alias *new,
-					  struct fib_alias *fa,
-					  t_key key)
+					  struct fib_alias *fa, t_key key)
 {
 	if (!l)
 		return fib_insert_node(net, t, tp, new, key);
