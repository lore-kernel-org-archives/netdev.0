From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 29/29] fib_trie: Push bits up one level,
 and move leaves up into parent key_vector array
Date: Tue, 24 Feb 2015 12:51:08 -0800
Message-ID: <20150224205108.26106.33975.stgit@ahduyck-vm-fedora20>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54520 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752492AbbBXUvL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 15:51:11 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKpAab009340
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:51:10 -0500
Received: from [192.168.122.173] (ovpn-112-73.phx2.redhat.com [10.3.112.73])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKp8Mg000388
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:51:09 -0500
In-Reply-To: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the last bit to get the key_vector up into the parent key_vector
array.  With this the bits field is moved from the local node up to the
parent, and as a result the key_vector is now defunct.

Since the key_vector is now defunct we can do a number of things.  The
first was to remove the leaf allocation since they are now just elements in
the key_vector array contained in the tnode and trie structures, and the
second was to rearrange the fib_table_lookup and fib_find_node functions to
take advantage of the fact that the trie has been pushed up one level.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |  484 ++++++++++++++++++++++++---------------------------
 1 file changed, 229 insertions(+), 255 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 0953247..8f48a03 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -112,7 +112,7 @@ struct tnode {
 	t_key full_children;		/* KEYLENGTH bits needed */
 	struct key_vector __rcu *parent;
 	struct key_vector kv[0];
-#define tn_bits kv[0].bits
+#define tn_bits kv[1].tn_pos
 };
 
 #ifdef CONFIG_IP_FIB_TRIE_STATS
@@ -160,7 +160,6 @@ static size_t tnode_free_size;
 static const int sync_pages = 128;
 
 static struct kmem_cache *fn_alias_kmem __read_mostly;
-static struct kmem_cache *trie_leaf_kmem __read_mostly;
 
 static inline struct tnode *tn_info(struct key_vector *kv)
 {
@@ -190,9 +189,9 @@ static inline struct fib_table *table_info(struct key_vector *kv)
 /* This provides us with the number of children in this node, in the case of a
  * leaf this will return 0 meaning none of the children are accessible.
  */
-static inline unsigned long child_length(const struct key_vector *tn)
+static inline unsigned long child_length(struct key_vector *tn)
 {
-	return (1ul << tn->bits) & ~(1ul);
+	return (1ul << tn_info(tn)->tn_bits);
 }
 
 #define get_cindex(key, kv) (((key) ^ (kv)->key) >> (kv)->pos)
@@ -297,9 +296,7 @@ static void __node_free_rcu(struct rcu_head *head)
 {
 	struct tnode *n = container_of(head, struct tnode, rcu);
 
-	if (!n->tn_bits)
-		kmem_cache_free(trie_leaf_kmem, n);
-	else if (n->tn_bits <= TNODE_KMALLOC_MAX)
+	if (n->tn_bits <= TNODE_KMALLOC_MAX)
 		kfree(n);
 	else
 		vfree(n);
@@ -325,55 +322,12 @@ static inline void empty_child_dec(struct key_vector *n)
 	tn_info(n)->empty_children-- ? : tn_info(n)->full_children--;
 }
 
-static struct key_vector *leaf_new(t_key key, struct fib_alias *fa)
-{
-	struct tnode *kv = kmem_cache_alloc(trie_leaf_kmem, GFP_KERNEL);
-	struct key_vector *l = kv->kv;
-
-	if (!kv)
-		return NULL;
-
-	/* initialize key vector */
-	l->key = key;
-	l->pos = 0;
-	l->bits = 0;
-	l->slen = fa->fa_slen;
-	l->tn_pos = 0;
-
-	/* link leaf to fib alias */
-	INIT_HLIST_HEAD(&l->leaf);
-	hlist_add_head(&fa->fa_list, &l->leaf);
-
-	return l;
-}
-
 /* Check whether a tnode 'n' is "full", i.e. it is an internal node
  * and no bits are skipped. See discussion in dyntree paper p. 6
  */
 static inline int tnode_full(struct key_vector *tn, struct key_vector *n)
 {
-	return n && IS_TNODE(n) && ((n->tn_pos + n->bits) == tn->tn_pos);
-}
-
-static void drop_child(struct key_vector *tn, t_key key)
-{
-	/* update parent tnode statistics */
-	if (!IS_TRIE(tn)) {
-		unsigned long i = get_index(key, tn);
-		struct key_vector *n = get_child(tn + i);
-
-		if (n) {
-			empty_child_inc(tn);
-			if (tnode_full(tn, n))
-				tn_info(tn)->full_children--;
-		}
-
-		/* update offset to correct key_vector for update */
-		tn += i;
-	}
-
-	/* clear tnode pointers */
-	RCU_INIT_POINTER(tn->tnode, NULL);
+	return IS_TNODE(n) && ((n->pos + n->bits) == tn->tn_pos);
 }
 
 /* Add a child at position i overwriting the old value.
@@ -385,12 +339,12 @@ static void put_child(struct key_vector *tn, unsigned long i,
 	struct key_vector *tnode = get_child(n);
 
 	if (!IS_TRIE(tn)) {
-		struct key_vector *chi = get_child(tn + i);
+		struct key_vector *chi = tn + i;
 
 		BUG_ON(i >= child_length(tn));
 
 		/* update emptyChildren and fullChildren */
-		if (chi) {
+		if (get_child(chi)) {
 			empty_child_inc(tn);
 			if (tnode_full(tn, chi))
 				tn_info(tn)->full_children--;
@@ -399,7 +353,7 @@ static void put_child(struct key_vector *tn, unsigned long i,
 			struct key_vector *kv = get_vector(tn);
 
 			empty_child_dec(tn);
-			if (tnode_full(tn, tnode))
+			if (tnode_full(tn, n))
 				tn_info(tn)->full_children++;
 
 			/* update suffix length */
@@ -408,11 +362,12 @@ static void put_child(struct key_vector *tn, unsigned long i,
 		}
 
 		/* update offset to correct key_vector for update */
-		tn += i;
+		tn = chi;
 	}
 
 	tn->key = n->key;
 	tn->pos = n->pos;
+	tn->bits = n->bits;
 	tn->slen = n->slen;
 
 	rcu_assign_pointer(tn->tnode, tnode);
@@ -424,54 +379,60 @@ static void update_children(struct key_vector *tn)
 
 	/* update all of the child parent pointers */
 	for (i = IS_TRIE(tn) ? 1 : child_length(tn); i;) {
-		struct key_vector *inode = get_child(tn + --i);
-
-		if (!inode)
-			continue;
+		struct key_vector *inode = tn + --i;
 
 		/* Either update the children of a tnode that
 		 * already belongs to us or update the child
 		 * to point to ourselves.
 		 */
-		if (node_parent(inode) == tn)
-			update_children(inode);
-		else
-			node_set_parent(inode, tn);
+		if (IS_TNODE(inode)) {
+			struct key_vector *n = get_child(inode);
+
+			if (!n)
+				continue;
+
+			if (node_parent(n) == tn)
+				update_children(n);
+			else
+				node_set_parent(n, tn);
+		} else if (inode->leaf.first) {
+			/* update hash to point to us */
+			rcu_assign_pointer(inode->leaf.first->pprev,
+					   &inode->leaf.first);
+		}
 	}
 }
 
-static void leaf_init(struct key_vector *tn, t_key key, struct key_vector *l)
+static void leaf_init(struct key_vector *tn, t_key key, struct fib_alias *fa)
 {
-	/* link leaf to parent */
-	NODE_INIT_PARENT(l, tn);
-
 	/* update parent node stats */
 	if (!IS_TRIE(tn)) {
 		struct key_vector *kv = get_vector(tn);
 		unsigned long i = get_index(key, tn);
-		struct key_vector *n = get_child(tn + i);
 
 		BUG_ON(i >= child_length(tn));
 
-		if (!n)
-			empty_child_dec(tn);
-		else if (tnode_full(tn, n))
-			tn_info(tn)->full_children--;
+		empty_child_dec(tn);
 
 		/* update suffix length */
-		if (kv->slen < l->slen)
-			kv->slen = l->slen;
+		if (kv->slen < fa->fa_slen)
+			kv->slen = fa->fa_slen;
 
 		/* update offset to correct key_vector for update */
 		tn += i;
 	}
 
+	/* We should always be handed an empty slot */
+	BUG_ON(!hlist_empty(&tn->leaf));
+
 	/* populate key vector */
 	tn->key = key;
 	tn->pos = 0;
-	tn->slen = l->slen;
+	tn->bits = 0;
+	tn->slen = fa->fa_slen;
 
-	rcu_assign_pointer(tn->tnode, l);
+	/* clean the area and drop in the new leaf */
+	hlist_add_head(&fa->fa_list, &tn->leaf);
 }
 
 static struct key_vector *tnode_new(struct key_vector *tn, t_key key,
@@ -496,11 +457,11 @@ static struct key_vector *tnode_new(struct key_vector *tn, t_key key,
 	/* update parent node stats */
 	if (!IS_TRIE(tn)) {
 		unsigned long idx = get_index(key, tn);
-		struct key_vector *n = get_child(tn + idx);
+		struct key_vector *n = tn + idx;
 
 		BUG_ON(idx >= child_length(tn));
 
-		if (!n)
+		if (!get_child(n))
 			empty_child_dec(tn);
 		else if (tnode_full(tn, n))
 			tn_info(tn)->full_children--;
@@ -508,7 +469,7 @@ static struct key_vector *tnode_new(struct key_vector *tn, t_key key,
 			tn_info(tn)->full_children++;
 
 		/* update offset to correct key_vector for update */
-		tn += idx;
+		tn = n;
 	}
 
 	/* populate tn_info section */
@@ -518,7 +479,7 @@ static struct key_vector *tnode_new(struct key_vector *tn, t_key key,
 	else
 		tnode->empty_children = 1ul << bits;
 	tnode->kv[0].tn_pos = pos;
-	tnode->kv[0].bits = bits;
+	tnode->tn_bits = bits;
 
 	/* populate keys as though we are full of leaves */
 	for (i = (1ul << bits); i--;)
@@ -527,6 +488,7 @@ static struct key_vector *tnode_new(struct key_vector *tn, t_key key,
 	/* populate key vector */
 	tn->key = key;
 	tn->pos = pos;
+	tn->bits = bits;
 	tn->slen = pos;
 
 	rcu_assign_pointer(tn->tnode, tnode->kv);
@@ -618,7 +580,7 @@ static void tnode_free(struct key_vector *tn)
 
 	while (head) {
 		head = head->next;
-		tnode_free_size += TNODE_SIZE(1ul << tn->bits);
+		tnode_free_size += TNODE_SIZE(child_length(tn));
 		node_free(tn);
 
 		tn = container_of(head, struct tnode, rcu)->kv;
@@ -664,11 +626,12 @@ static struct key_vector *resize_children(struct net *net, struct trie *t,
 
 	/* resize children now that oldtnode is freed */
 	for (i = child_length(tn); i;) {
-		struct key_vector *inode = get_child(tn + --i);
+		struct key_vector *inode = tn + --i;
+		struct key_vector *tnode = get_child(inode);
 
 		/* resize child node */
-		if (tnode_full(tn, inode))
-			tn = resize(net, t, inode);
+		if (tnode && tnode_full(tn, inode))
+			tn = resize(net, t, tnode);
 	}
 
 	return node_parent(tn);
@@ -689,7 +652,7 @@ static struct key_vector *inflate(struct net *net, struct trie *t,
 		return NULL;
 
 	tn = tnode_new(pn, oldtnode->key,
-		       oldtnode->tn_pos - 1, oldtnode->bits + 1);
+		       oldtnode->tn_pos - 1, tn_info(oldtnode)->tn_bits + 1);
 	if (!tn)
 		goto notnode;
 
@@ -712,7 +675,7 @@ static struct key_vector *inflate(struct net *net, struct trie *t,
 			continue;
 
 		/* A leaf or an internal node with skipped bits */
-		if (!tnode_full(oldtnode, tnode)) {
+		if (!tnode_full(oldtnode, inode)) {
 			put_child(tn, get_index(inode->key, tn), inode);
 			continue;
 		}
@@ -721,7 +684,7 @@ static struct key_vector *inflate(struct net *net, struct trie *t,
 		tnode_free_append(oldtnode, tnode);
 
 		/* An internal node with two children */
-		if (tnode->bits == 1) {
+		if (inode->bits == 1) {
 			put_child(tn, 2 * i + 1, tnode + 1);
 			put_child(tn, 2 * i, tnode);
 			continue;
@@ -742,11 +705,11 @@ static struct key_vector *inflate(struct net *net, struct trie *t,
 		 * two new keys.
 		 */
 		node1 = tnode_new(tn, inode->key | m,
-				  inode->pos, tnode->bits - 1);
+				  inode->pos, inode->bits - 1);
 		if (!node1)
 			goto nomem;
 		node0 = tnode_new(tn, inode->key,
-				  inode->pos, tnode->bits - 1);
+				  inode->pos, inode->bits - 1);
 
 		tnode_free_append(tn, node1);
 		if (!node0)
@@ -790,7 +753,7 @@ static struct key_vector *halve(struct net *net, struct trie *t,
 		return NULL;
 
 	tn = tnode_new(pn, oldtnode->key,
-		       oldtnode->tn_pos + 1, oldtnode->bits - 1);
+		       oldtnode->tn_pos + 1, tn_info(oldtnode)->tn_bits - 1);
 	if (!tn)
 		goto notnode;
 
@@ -842,13 +805,12 @@ notnode:
 static struct key_vector *collapse(struct net *net, struct trie *t,
 				   struct key_vector *oldtnode)
 {
-	struct key_vector *pn = node_parent(oldtnode);
+	struct key_vector *n, *pn = node_parent(oldtnode);
 	unsigned long i;
 
 	/* scan the tnode looking for that one child that might still exist */
 	for (i = child_length(oldtnode); i--;) {
-		struct key_vector *n = get_child(oldtnode + i);
-
+		n = get_child(oldtnode + i);
 		if (!n)
 			continue;
 
@@ -865,11 +827,24 @@ static struct key_vector *collapse(struct net *net, struct trie *t,
 		node_free(oldtnode);
 
 		/* resize child since it could be promoted to root */
-		return IS_TNODE(n) ? resize(net, t, n) : pn;
+		return IS_TNODE(oldtnode + i) ? resize(net, t, n) : pn;
 	}
 
 	/* no children, just update pointer to NULL */
-	drop_child(pn, oldtnode->key);
+	n = pn;
+
+	/* update parent tnode statistics */
+	if (!IS_TRIE(pn)) {
+		/* update offset to correct key_vector for update */
+		n = get_vector(oldtnode);
+
+		empty_child_inc(pn);
+		if (tnode_full(pn, n))
+			tn_info(pn)->full_children--;
+	}
+
+	/* clear tnode pointers */
+	RCU_INIT_POINTER(n->tnode, NULL);
 	node_free(oldtnode);
 
 	return pn;
@@ -909,7 +884,7 @@ static unsigned char update_suffix(struct key_vector *tn)
 		 * 0 and 1 << (bits - 1) could have that as their suffix
 		 * length.
 		 */
-		if ((slen + 1) >= (tn->pos + tp->bits))
+		if ((slen + 1) >= (tn->pos + tn->bits))
 			break;
 	}
 
@@ -1004,7 +979,7 @@ static inline bool should_halve(struct key_vector *tp, struct key_vector *tn)
 
 	/* if bits == KEYLENGTH then used = 100% on wrap, and will fail below */
 
-	return (used > 1) && (tn->bits > 1) && ((100 * used) < threshold);
+	return (used > 1) && (tn_info(tn)->tn_bits > 1) && ((100 * used) < threshold);
 }
 
 static inline bool should_collapse(struct key_vector *tn)
@@ -1014,7 +989,7 @@ static inline bool should_collapse(struct key_vector *tn)
 	used -= tn_info(tn)->empty_children;
 
 	/* account for bits == KEYLENGTH case */
-	if ((tn->bits == KEYLENGTH) && tn_info(tn)->full_children)
+	if ((tn_info(tn)->tn_bits == KEYLENGTH) && tn_info(tn)->full_children)
 		used -= KEY_MAX;
 
 	/* One child or none, time to drop us from the trie */
@@ -1096,11 +1071,6 @@ static struct key_vector *resize(struct net *net, struct trie *t,
 
 static void leaf_pull_suffix(struct key_vector *tp, struct key_vector *l)
 {
-	struct key_vector *n = tp + get_index(l->key, tp);
-
-	/* update our local vector first */
-	n->slen = l->slen;
-
 	/* work our way back up the trie sorting out slen in the key vectors */
 	while (!IS_TRIE(tp)) {
 		/* if the suffix doesn't change then we are done */
@@ -1113,20 +1083,13 @@ static void leaf_pull_suffix(struct key_vector *tp, struct key_vector *l)
 
 static void leaf_push_suffix(struct key_vector *tn, struct key_vector *l)
 {
-	struct key_vector *n = tn + get_index(l->key, tn);
-
-	/* update our local vector first */
-	n->slen = l->slen;
-
 	/* work our way back up the trie sorting out slen in the key vectors */
-	while (!IS_TRIE(tn)) {
-		n = get_vector(tn);
+	if (!IS_TRIE(tn)) {
+		struct key_vector *n = get_vector(tn);
 
 		/* if the suffix doesn't change then we are done */
 		if (n->slen < l->slen)
 			n->slen = l->slen;
-
-		tn = node_parent(tn);
 	}
 }
 
@@ -1142,9 +1105,6 @@ static struct key_vector *fib_find_node(struct trie *t,
 		n += index;
 
 		index = get_cindex(key, n);
-		n = get_child_rcu(n);
-		if (!n)
-			break;
 
 		/* This bit of code is a bit tricky but it combines multiple
 		 * checks into a single check.  The prefix consists of the
@@ -1160,7 +1120,11 @@ static struct key_vector *fib_find_node(struct trie *t,
 			return NULL;
 
 		/* keep searching until we find a perfect match leaf or NULL */
-	} while (IS_TNODE(n));
+		if (IS_LEAF(n))
+			break;
+
+		n = get_child_rcu(n);
+	} while (n);
 
 	return n;
 }
@@ -1203,18 +1167,13 @@ static struct fib_table *fib_insert_node(struct net *net, struct trie *t,
 					 struct key_vector *tp,
 					 struct fib_alias *new, t_key key)
 {
-	struct key_vector *tn, *l, *n;
+	struct key_vector *tn, *n;
 
 	/* allocate the new parent that must be replaced */
 	tn = vector_clone(tp);
 	if (!tn)
 		return NULL;
 
-	/* allocate the new leaf we will insert */
-	l = leaf_new(key, new);
-	if (!l)
-		goto noleaf;
-
 	/* retrieve child from parent node */
 	n = tp + get_index(key, tp);
 
@@ -1241,14 +1200,12 @@ static struct fib_table *fib_insert_node(struct net *net, struct trie *t,
 	}
 
 	/* Case 3: n is NULL, and will just insert a new leaf */
-	leaf_init(n, key, l);
+	leaf_init(n, key, new);
 
 	vector_replace(net, tp, tn);
 
 	return trie_rebalance(net, t, n);
 notnode:
-	node_free(l);
-noleaf:
 	vector_free(tn);
 
 	return NULL;
@@ -1266,6 +1223,9 @@ static struct fib_table *fib_insert_alias(struct net *net, struct trie *t,
 	if (!fa) {
 		struct fib_alias *last;
 
+		if (hlist_empty(&l->leaf) && !IS_TRIE(tp))
+			empty_child_dec(tp);
+
 		hlist_for_each_entry(last, &l->leaf, fa_list) {
 			if (new->fa_slen < last->fa_slen)
 				break;
@@ -1284,7 +1244,7 @@ static struct fib_table *fib_insert_alias(struct net *net, struct trie *t,
 		leaf_push_suffix(tp, l);
 	}
 
-	return table_info(t->kv);
+	return trie_rebalance(net, t, tp);
 }
 
 /* Caller must hold RTNL. */
@@ -1456,25 +1416,20 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 	struct trie_use_stats __percpu *stats = t->stats;
 #endif
 	const t_key key = ntohl(flp->daddr);
-	struct key_vector *n, *pn, *tn;
-	unsigned long cindex;
+	struct key_vector *pn, *n, *l = t->kv;
+	unsigned long cindex, index = 0;
 	struct fib_alias *fa;
 
-	pn = t->kv;
-	cindex = 0;
-
-	tn = pn;
-	n = get_child_rcu(tn);
-	if (!n)
-		return -EAGAIN;
-
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 	this_cpu_inc(stats->gets);
 #endif
+	pn = l;
+	cindex = index;
 
 	/* Step 1: Travel to the longest prefix match in the trie */
 	for (;;) {
-		unsigned long index = get_cindex(key, tn);
+		n = l + index;
+		index = get_cindex(key, n);
 
 		/* This bit of code is a bit tricky but it combines multiple
 		 * checks into a single check.  The prefix consists of the
@@ -1489,6 +1444,11 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 		if (index & (~0ul << n->bits))
 			break;
 
+		/* grab the pointers for the next object */
+		l = get_child_rcu(n);
+		if (!l)
+			goto backtrace;
+
 		/* we have found a leaf. Prefixes have already been compared */
 		if (IS_LEAF(n))
 			goto found;
@@ -1496,43 +1456,19 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 		/* only record pn and cindex if we are going to be chopping
 		 * bits later.  Otherwise we are just wasting cycles.
 		 */
-		if (tn->slen > tn->pos) {
-			pn = n;
+		if (n->slen > n->pos) {
+			pn = l;
 			cindex = index;
 		}
-
-		tn = n + index;
-
-		/* verify there is a tnode to go with the key vector */
-		n = get_child_rcu(tn);
-		if (unlikely(!n))
-			goto backtrace;
 	}
 
 	/* Step 2: Sort out leaves and begin backtracing for longest prefix */
 	for (;;) {
-		/* This test verifies that none of the bits that differ
-		 * between the key and the prefix exist in the region of
-		 * the lsb and higher in the prefix.
-		 */
-		if (unlikely(prefix_mismatch(key, tn)) || (tn->slen <= tn->pos))
-			goto backtrace;
-
-		/* exit out and process leaf */
-		if (unlikely(IS_LEAF(n)))
-			break;
-
-		/* Don't bother recording parent info.  Since we are in
-		 * prefix match mode we will have to come back to wherever
-		 * we started this traversal anyway
-		 */
-
-		tn = n;
-
-		while ((n = get_child_rcu(tn)) == NULL) {
+		/* grab the pointers for the next object */
+		while ((l = get_child_rcu(n)) == NULL) {
 backtrace:
 #ifdef CONFIG_IP_FIB_TRIE_STATS
-			if (!n)
+			if (!l)
 				this_cpu_inc(stats->null_node_hit);
 #endif
 			/* If we are at cindex 0 there are no more bits for
@@ -1561,24 +1497,46 @@ backtrace:
 			cindex &= cindex - 1;
 
 			/* grab pointer for next child node */
-			tn = pn + cindex;
+			n = pn + cindex;
 		}
-	}
 
+		/* This test verifies that none of the bits that differ
+		 * between the key and the prefix exist in the region of
+		 * the lsb and higher in the prefix.
+		 */
+		if (unlikely(prefix_mismatch(key, n)) || (n->slen <= n->pos))
+			goto backtrace;
+
+		/* exit out and process leaf */
+		if (unlikely(IS_LEAF(n)))
+			break;
+
+		/* Don't bother recording parent info.  Since we are in
+		 * prefix match mode we will have to come back to wherever
+		 * we started this traversal anyway
+		 */
+
+		n = l;
+	}
 found:
 	/* Step 3: Process the leaf, if that fails fall back to backtracing */
-	hlist_for_each_entry_rcu(fa, &n->leaf, fa_list) {
-		struct fib_info *fi = fa->fa_info;
+	fa = hlist_entry(&l->leaf.first, typeof(*fa), fa_list.next);
+	hlist_for_each_entry_from_rcu(fa, fa_list) {
+		struct fib_info *fi;
 		int nhsel, err;
 
-		if (((key ^ n->key) >> fa->fa_slen) &&
-		    (fa->fa_slen != KEYLENGTH))
+		if (((unsigned long)(key ^ n->key) >> fa->fa_slen) &&
+		    ((BITS_PER_LONG > KEYLENGTH) ||
+		     (fa->fa_slen != KEYLENGTH)))
 			continue;
 		if (fa->fa_tos && fa->fa_tos != flp->flowi4_tos)
 			continue;
+
+		fi = fa->fa_info;
+
 		if (fi->fib_dead)
 			continue;
-		if (fa->fa_info->fib_scope < flp->flowi4_scope)
+		if (fi->fib_scope < flp->flowi4_scope)
 			continue;
 		fib_alias_accessed(fa);
 		err = fib_props[fa->fa_type].error;
@@ -1636,9 +1594,13 @@ static void fib_remove_alias(struct net *net, struct trie *t,
 	 * out parent suffix lengths as a part of trie_rebalance
 	 */
 	if (hlist_empty(&l->leaf)) {
-		drop_child(tp, l->key);
-		node_free(l);
-		trie_rebalance(net, t, tp);
+		l->slen = 0;
+
+		if (!IS_TRIE(tp)) {
+			empty_child_inc(tp);
+			trie_rebalance(net, t, tp);
+		}
+
 		return;
 	}
 
@@ -1723,51 +1685,55 @@ int fib_table_delete(struct net *net, struct fib_table *tb,
 /* Scan for the next leaf starting at the provided key value */
 static struct key_vector *leaf_walk_rcu(struct key_vector **pn, t_key key)
 {
-	struct key_vector *tn, *n = *pn;
-	unsigned long cindex;
+	struct key_vector *l, *n, *tn = *pn;
+	unsigned long cindex = get_index(key, tn);
 
 	/* this loop is meant to try and find the key in the trie */
-	do {
-		/* record parent and next child index */
-		tn = n;
-		cindex = get_index(key, tn);
+	while (cindex < child_length(tn)) {
+		n = tn + cindex++;
 
-		if (cindex >> tn->bits)
-			break;
-
-		/* descend into the next child */
-		n = get_child_rcu(tn + cindex++);
-		if (!n)
+		l = get_child_rcu(n);
+		if (!l)
 			break;
 
 		/* guarantee forward progress on the keys */
-		if (IS_LEAF(n) && (n->key >= key))
+		if (IS_LEAF(n)) {
+			if (n->key < key)
+				break;
 			goto found;
-	} while (IS_TNODE(n));
+		}
+
+		/* record parent and next child index */
+		tn = l;
+		cindex = get_index(key, tn);
+	}
 
 	/* this loop will search for the next leaf with a greater key */
 	while (!IS_TRIE(tn)) {
+		t_key pkey;
+
 		/* if we exhausted the parent node we will need to climb */
-		if (cindex >> tn->bits) {
-			t_key pkey = tn->key;
+		while (cindex < child_length(tn)) {
+			/* grab the next available node */
+			n = tn + cindex++;
 
-			tn = node_parent_rcu(tn);
-			cindex = get_index(pkey, tn) + 1;
-			continue;
-		}
+			l = get_child_rcu(n);
+			if (!l)
+				continue;
 
-		/* grab the next available node */
-		n = get_child_rcu(tn + cindex++);
-		if (!n)
-			continue;
+			/* no need to compare keys since we bumped the index */
+			if (IS_LEAF(n))
+				goto found;
 
-		/* no need to compare keys since we bumped the index */
-		if (IS_LEAF(n))
-			goto found;
+			/* Rescan start scanning in new node */
+			tn = l;
+			cindex = 0;
+		}
 
-		/* Rescan start scanning in new node */
-		tn = n;
-		cindex = 0;
+		pkey = tn->key;
+
+		tn = node_parent_rcu(tn);
+		cindex = get_index(pkey, tn) + 1;
 	}
 
 	*pn = tn;
@@ -1790,7 +1756,6 @@ int fib_table_flush(struct net *net, struct fib_table *tb)
 
 	/* walk trie in reverse order */
 	for (;;) {
-		unsigned char slen = 0;
 		struct key_vector *n;
 
 		if (!(cindex--)) {
@@ -1807,42 +1772,47 @@ int fib_table_flush(struct net *net, struct fib_table *tb)
 			continue;
 		}
 
-		/* grab the next available node */
-		n = get_child(pn + cindex);
-		if (!n)
-			continue;
+		/* locate key vector within the array */
+		n = pn + cindex;
 
 		if (IS_TNODE(n)) {
+			/* grab the next available node */
+			n = get_child(n);
+
 			/* record pn and cindex for leaf walking */
-			pn = n;
-			cindex = 1ul << n->bits;
+			if (n) {
+				pn = n;
+				cindex = child_length(n);
+			}
 
 			continue;
 		}
 
-		hlist_for_each_entry_safe(fa, tmp, &n->leaf, fa_list) {
-			struct fib_info *fi = fa->fa_info;
+		if (!hlist_empty(&n->leaf)) {
+			unsigned char slen = 0;
 
-			if (fi && (fi->fib_flags & RTNH_F_DEAD)) {
-				hlist_del_rcu(&fa->fa_list);
-				fib_release_info(fa->fa_info);
-				alias_free_mem_rcu(fa);
-				found++;
+			hlist_for_each_entry_safe(fa, tmp, &n->leaf, fa_list) {
+				struct fib_info *fi = fa->fa_info;
 
-				continue;
-			}
+				if (fi && (fi->fib_flags & RTNH_F_DEAD)) {
+					hlist_del_rcu(&fa->fa_list);
+					fib_release_info(fa->fa_info);
+					alias_free_mem_rcu(fa);
+					found++;
 
-			slen = fa->fa_slen;
-		}
+					continue;
+				}
+
+				/* track suffix length of non-flushed leaves */
+				slen = fa->fa_slen;
+			}
 
-		/* update leaf slen */
-		n->slen = slen;
+			/* reset slen and update tnode */
+			n->slen = slen;
 
-		if (hlist_empty(&n->leaf)) {
-			drop_child(pn, n->key);
-			node_free(n);
-		} else {
-			leaf_pull_suffix(pn, n);
+			/* update parent status */
+			if (hlist_empty(&n->leaf) && !IS_TRIE(pn))
+				empty_child_inc(pn);
 		}
 	}
 
@@ -1945,11 +1915,6 @@ void __init fib_trie_init(void)
 	fn_alias_kmem = kmem_cache_create("ip_fib_alias",
 					  sizeof(struct fib_alias),
 					  0, SLAB_PANIC, NULL);
-
-	trie_leaf_kmem = kmem_cache_create("ip_fib_trie",
-					   sizeof(struct tnode) +
-					   sizeof(struct key_vector),
-					   0, SLAB_PANIC, NULL);
 }
 
 struct fib_table *fib_trie_table(u32 id)
@@ -1999,17 +1964,22 @@ static struct key_vector *fib_trie_get_next(struct fib_trie_iter *iter)
 
 	while (!IS_TRIE(pn)) {
 		while (cindex < child_length(pn)) {
-			struct key_vector *n = get_child_rcu(pn + cindex++);
-
-			if (!n)
-				continue;
+			struct key_vector *n = pn + cindex++;
 
 			if (IS_LEAF(n)) {
+				if (hlist_empty(&n->leaf))
+					continue;
+
 				iter->tnode = pn;
 				iter->index = cindex;
 			} else {
+				struct key_vector *tnode = get_child_rcu(n);
+
+				if (!tnode)
+					continue;
+
 				/* push down one level */
-				iter->tnode = n;
+				iter->tnode = tnode;
 				iter->index = 0;
 				++iter->depth;
 			}
@@ -2034,26 +2004,30 @@ static struct key_vector *fib_trie_get_next(struct fib_trie_iter *iter)
 static struct key_vector *fib_trie_get_first(struct fib_trie_iter *iter,
 					     struct trie *t)
 {
-	struct key_vector *n, *pn = t->kv;
+	struct key_vector *pn = t->kv;
 
 	if (!t)
 		return NULL;
 
-	n = rcu_dereference(pn->tnode);
-	if (!n)
-		return NULL;
+	if (IS_TNODE(pn)) {
+		struct key_vector *n = get_child_rcu(pn);
+
+		if (!n)
+			return NULL;
 
-	if (IS_TNODE(n)) {
 		iter->tnode = n;
 		iter->index = 0;
 		iter->depth = 1;
 	} else {
+		if (hlist_empty(&pn->leaf))
+			return NULL;
+
 		iter->tnode = pn;
 		iter->index = 0;
 		iter->depth = 0;
 	}
 
-	return n;
+	return pn;
 }
 
 static void trie_collect_stats(struct trie *t, struct trie_stat *s)
@@ -2079,7 +2053,7 @@ static void trie_collect_stats(struct trie *t, struct trie_stat *s)
 			s->tnodes++;
 			if (n->bits < MAX_STAT_DEPTH)
 				s->nodesizes[n->bits]++;
-			s->nullpointers += tn_info(n)->empty_children;
+			s->nullpointers += tn_info(iter.tnode)->empty_children;
 		}
 	}
 	rcu_read_unlock();
@@ -2124,7 +2098,7 @@ static void trie_show_stats(struct seq_file *seq, struct trie_stat *stat)
 	seq_printf(seq, "\tPointers: %u\n", pointers);
 
 	bytes += sizeof(struct key_vector) * pointers;
-	seq_printf(seq, "Empty vectors: %u\n", stat->nullpointers);
+	seq_printf(seq, "Empty leaves: %u\n", stat->nullpointers);
 	seq_printf(seq, "Total size: %u  kB\n", (bytes + 1023) / 1024);
 }
 
@@ -2177,7 +2151,7 @@ static int fib_triestat_seq_show(struct seq_file *seq, void *v)
 	seq_printf(seq,
 		   "Basic info: size of leaf:"
 		   " %Zd bytes, size of tnode: %Zd bytes.\n",
-		   TNODE_SIZE(1), TNODE_SIZE(0));
+		   sizeof(struct key_vector), TNODE_SIZE(0));
 
 	for (h = 0; h < FIB_TABLE_HASHSZ; h++) {
 		struct hlist_head *head = &net->ipv4.fib_table_hash[h];
@@ -2345,17 +2319,17 @@ static int fib_trie_seq_show(struct seq_file *seq, void *v)
 	const struct fib_trie_iter *iter = seq->private;
 	struct key_vector *n = v;
 
-	if (IS_TRIE(node_parent_rcu(n)))
+	if (IS_TRIE(n))
 		fib_table_print(seq, iter->tb);
 
 	if (IS_TNODE(n)) {
-		__be32 prf = htonl((n->key >> n->tn_pos) << n->tn_pos);
+		__be32 prf = htonl(n->key);
 
 		seq_indent(seq, iter->depth-1);
 		seq_printf(seq, "  +-- %pI4/%zu %u %u %u\n",
-			   &prf, KEYLENGTH - n->tn_pos - n->bits, n->bits,
-			   tn_info(n)->full_children,
-			   tn_info(n)->empty_children);
+			   &prf, KEYLENGTH - n->pos - n->bits, n->bits,
+			   tn_info(iter->tnode)->full_children,
+			   tn_info(iter->tnode)->empty_children);
 	} else {
 		__be32 val = htonl(n->key);
 		struct fib_alias *fa;
