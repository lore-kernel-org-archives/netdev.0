From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH v2 10/10] fib_trie: Add key vector to root,
 return parent key_vector in resize
Date: Fri, 06 Mar 2015 09:54:52 -0800
Message-ID: <20150306175452.2452.36517.stgit@ahduyck-vm-fedora20>
References: <20150306174814.2452.18308.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34302 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755198AbbCFRyy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Mar 2015 12:54:54 -0500
In-Reply-To: <20150306174814.2452.18308.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change makes it so that the root of the trie contains a key_vector, by
doing this we make room to essentially collapse the entire trie by at least
one cache line as we can store the information about the tnode or leaf that
is pointed to in the root.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |  433 ++++++++++++++++++++++++---------------------------
 1 file changed, 201 insertions(+), 232 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index b5fed2f..9095545 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -89,8 +89,9 @@
 
 typedef unsigned int t_key;
 
-#define IS_TNODE(n) ((n)->bits)
-#define IS_LEAF(n) (!(n)->bits)
+#define IS_TRIE(n)	((n)->pos >= KEYLENGTH)
+#define IS_TNODE(n)	((n)->bits)
+#define IS_LEAF(n)	(!(n)->bits)
 
 struct key_vector {
 	t_key key;
@@ -139,13 +140,13 @@ struct trie_stat {
 };
 
 struct trie {
-	struct key_vector __rcu *tnode[1];
+	struct key_vector kv[1];
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 	struct trie_use_stats __percpu *stats;
 #endif
 };
 
-static struct key_vector **resize(struct trie *t, struct key_vector *tn);
+static struct key_vector *resize(struct trie *t, struct key_vector *tn);
 static size_t tnode_free_size;
 
 /*
@@ -188,10 +189,15 @@ static inline unsigned long child_length(const struct key_vector *tn)
 	return (1ul << tn->bits) & ~(1ul);
 }
 
+#define get_cindex(key, kv) (((key) ^ (kv)->key) >> (kv)->pos)
+
 static inline unsigned long get_index(t_key key, struct key_vector *kv)
 {
 	unsigned long index = key ^ kv->key;
 
+	if ((BITS_PER_LONG <= KEYLENGTH) && (KEYLENGTH == kv->pos))
+		return 0;
+
 	return index >> kv->pos;
 }
 
@@ -427,13 +433,13 @@ static void update_children(struct key_vector *tn)
 	}
 }
 
-static inline void put_child_root(struct key_vector *tp, struct trie *t,
-				  t_key key, struct key_vector *n)
+static inline void put_child_root(struct key_vector *tp, t_key key,
+				  struct key_vector *n)
 {
-	if (tp)
-		put_child(tp, get_index(key, tp), n);
+	if (IS_TRIE(tp))
+		rcu_assign_pointer(tp->tnode[0], n);
 	else
-		rcu_assign_pointer(t->tnode[0], n);
+		put_child(tp, get_index(key, tp), n);
 }
 
 static inline void tnode_free_init(struct key_vector *tn)
@@ -466,17 +472,16 @@ static void tnode_free(struct key_vector *tn)
 	}
 }
 
-static struct key_vector __rcu **replace(struct trie *t,
-					 struct key_vector *oldtnode,
-					 struct key_vector *tn)
+static struct key_vector *replace(struct trie *t,
+				  struct key_vector *oldtnode,
+				  struct key_vector *tn)
 {
 	struct key_vector *tp = node_parent(oldtnode);
-	struct key_vector **cptr;
 	unsigned long i;
 
 	/* setup the parent pointer out of and back into this node */
 	NODE_INIT_PARENT(tn, tp);
-	put_child_root(tp, t, tn->key, tn);
+	put_child_root(tp, tn->key, tn);
 
 	/* update all of the child parent pointers */
 	update_children(tn);
@@ -484,23 +489,20 @@ static struct key_vector __rcu **replace(struct trie *t,
 	/* all pointers should be clean so we are done */
 	tnode_free(oldtnode);
 
-	/* record the pointer that is pointing to this node */
-	cptr = tp ? tp->tnode : t->tnode;
-
 	/* resize children now that oldtnode is freed */
 	for (i = child_length(tn); i;) {
 		struct key_vector *inode = get_child(tn, --i);
 
 		/* resize child node */
 		if (tnode_full(tn, inode))
-			resize(t, inode);
+			tn = resize(t, inode);
 	}
 
-	return cptr;
+	return tp;
 }
 
-static struct key_vector __rcu **inflate(struct trie *t,
-					 struct key_vector *oldtnode)
+static struct key_vector *inflate(struct trie *t,
+				  struct key_vector *oldtnode)
 {
 	struct key_vector *tn;
 	unsigned long i;
@@ -595,8 +597,8 @@ notnode:
 	return NULL;
 }
 
-static struct key_vector __rcu **halve(struct trie *t,
-				       struct key_vector *oldtnode)
+static struct key_vector *halve(struct trie *t,
+				struct key_vector *oldtnode)
 {
 	struct key_vector *tn;
 	unsigned long i;
@@ -650,7 +652,8 @@ notnode:
 	return NULL;
 }
 
-static void collapse(struct trie *t, struct key_vector *oldtnode)
+static struct key_vector *collapse(struct trie *t,
+				   struct key_vector *oldtnode)
 {
 	struct key_vector *n, *tp;
 	unsigned long i;
@@ -661,11 +664,13 @@ static void collapse(struct trie *t, struct key_vector *oldtnode)
 
 	/* compress one level */
 	tp = node_parent(oldtnode);
-	put_child_root(tp, t, oldtnode->key, n);
+	put_child_root(tp, oldtnode->key, n);
 	node_set_parent(n, tp);
 
 	/* drop dead node */
 	node_free(oldtnode);
+
+	return tp;
 }
 
 static unsigned char update_suffix(struct key_vector *tn)
@@ -766,7 +771,7 @@ static inline bool should_inflate(struct key_vector *tp, struct key_vector *tn)
 	unsigned long threshold = used;
 
 	/* Keep root node larger */
-	threshold *= tp ? inflate_threshold : inflate_threshold_root;
+	threshold *= IS_TRIE(tp) ? inflate_threshold_root : inflate_threshold;
 	used -= tn_info(tn)->empty_children;
 	used += tn_info(tn)->full_children;
 
@@ -781,7 +786,7 @@ static inline bool should_halve(struct key_vector *tp, struct key_vector *tn)
 	unsigned long threshold = used;
 
 	/* Keep root node larger */
-	threshold *= tp ? halve_threshold : halve_threshold_root;
+	threshold *= IS_TRIE(tp) ? halve_threshold_root : halve_threshold;
 	used -= tn_info(tn)->empty_children;
 
 	/* if bits == KEYLENGTH then used = 100% on wrap, and will fail below */
@@ -804,15 +809,13 @@ static inline bool should_collapse(struct key_vector *tn)
 }
 
 #define MAX_WORK 10
-static struct key_vector __rcu **resize(struct trie *t,
-					struct key_vector *tn)
+static struct key_vector *resize(struct trie *t, struct key_vector *tn)
 {
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 	struct trie_use_stats __percpu *stats = t->stats;
 #endif
 	struct key_vector *tp = node_parent(tn);
-	unsigned long cindex = tp ? get_index(tn->key, tp) : 0;
-	struct key_vector __rcu **cptr = tp ? tp->tnode : t->tnode;
+	unsigned long cindex = get_index(tn->key, tp);
 	int max_work = MAX_WORK;
 
 	pr_debug("In tnode_resize %p inflate_threshold=%d threshold=%d\n",
@@ -822,15 +825,14 @@ static struct key_vector __rcu **resize(struct trie *t,
 	 * doing it ourselves.  This way we can let RCU fully do its
 	 * thing without us interfering
 	 */
-	BUG_ON(tn != rtnl_dereference(cptr[cindex]));
+	BUG_ON(tn != get_child(tp, cindex));
 
 	/* Double as long as the resulting node has a number of
 	 * nonempty nodes that are above the threshold.
 	 */
 	while (should_inflate(tp, tn) && max_work) {
-		struct key_vector __rcu **tcptr = inflate(t, tn);
-
-		if (!tcptr) {
+		tp = inflate(t, tn);
+		if (!tp) {
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 			this_cpu_inc(stats->resize_node_skipped);
 #endif
@@ -838,21 +840,19 @@ static struct key_vector __rcu **resize(struct trie *t,
 		}
 
 		max_work--;
-		cptr = tcptr;
-		tn = rtnl_dereference(cptr[cindex]);
+		tn = get_child(tp, cindex);
 	}
 
 	/* Return if at least one inflate is run */
 	if (max_work != MAX_WORK)
-		return cptr;
+		return node_parent(tn);
 
 	/* Halve as long as the number of empty children in this
 	 * node is above threshold.
 	 */
 	while (should_halve(tp, tn) && max_work) {
-		struct key_vector __rcu **tcptr = halve(t, tn);
-
-		if (!tcptr) {
+		tp = halve(t, tn);
+		if (!tp) {
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 			this_cpu_inc(stats->resize_node_skipped);
 #endif
@@ -860,34 +860,34 @@ static struct key_vector __rcu **resize(struct trie *t,
 		}
 
 		max_work--;
-		cptr = tcptr;
-		tn = rtnl_dereference(cptr[cindex]);
+		tn = get_child(tp, cindex);
 	}
 
 	/* Only one child remains */
-	if (should_collapse(tn)) {
-		collapse(t, tn);
-		return cptr;
-	}
+	if (should_collapse(tn))
+		return collapse(t, tn);
+
+	/* update parent in case inflate or halve failed */
+	tp = node_parent(tn);
 
 	/* Return if at least one deflate was run */
 	if (max_work != MAX_WORK)
-		return cptr;
+		return tp;
 
 	/* push the suffix length to the parent node */
 	if (tn->slen > tn->pos) {
 		unsigned char slen = update_suffix(tn);
 
-		if (tp && (slen > tp->slen))
+		if (slen > tp->slen)
 			tp->slen = slen;
 	}
 
-	return cptr;
+	return tp;
 }
 
 static void leaf_pull_suffix(struct key_vector *tp, struct key_vector *l)
 {
-	while (tp && (tp->slen > tp->pos) && (tp->slen > l->slen)) {
+	while ((tp->slen > tp->pos) && (tp->slen > l->slen)) {
 		if (update_suffix(tp) > l->slen)
 			break;
 		tp = node_parent(tp);
@@ -899,7 +899,7 @@ static void leaf_push_suffix(struct key_vector *tn, struct key_vector *l)
 	/* if this is a new leaf then tn will be NULL and we can sort
 	 * out parent suffix lengths as a part of trie_rebalance
 	 */
-	while (tn && (tn->slen < l->slen)) {
+	while (tn->slen < l->slen) {
 		tn->slen = l->slen;
 		tn = node_parent(tn);
 	}
@@ -909,10 +909,17 @@ static void leaf_push_suffix(struct key_vector *tn, struct key_vector *l)
 static struct key_vector *fib_find_node(struct trie *t,
 					struct key_vector **tp, u32 key)
 {
-	struct key_vector *pn = NULL, *n = rcu_dereference_rtnl(t->tnode[0]);
+	struct key_vector *pn, *n = t->kv;
+	unsigned long index = 0;
+
+	do {
+		pn = n;
+		n = get_child_rcu(n, index);
+
+		if (!n)
+			break;
 
-	while (n) {
-		unsigned long index = get_index(key, n);
+		index = get_cindex(key, n);
 
 		/* This bit of code is a bit tricky but it combines multiple
 		 * checks into a single check.  The prefix consists of the
@@ -933,13 +940,8 @@ static struct key_vector *fib_find_node(struct trie *t,
 			break;
 		}
 
-		/* we have found a leaf. Prefixes have already been compared */
-		if (IS_LEAF(n))
-			break;
-
-		pn = n;
-		n = get_child_rcu(n, index);
-	}
+		/* keep searching until we find a perfect match leaf or NULL */
+	} while (IS_TNODE(n));
 
 	*tp = pn;
 
@@ -973,16 +975,8 @@ static struct fib_alias *fib_find_alias(struct hlist_head *fah, u8 slen,
 
 static void trie_rebalance(struct trie *t, struct key_vector *tn)
 {
-	struct key_vector __rcu **cptr = t->tnode;
-
-	while (tn) {
-		struct key_vector *tp = node_parent(tn);
-
-		cptr = resize(t, tn);
-		if (!tp)
-			break;
-		tn = container_of(cptr, struct key_vector, tnode[0]);
-	}
+	while (!IS_TRIE(tn))
+		tn = resize(t, tn);
 }
 
 static int fib_insert_node(struct trie *t, struct key_vector *tp,
@@ -995,10 +989,7 @@ static int fib_insert_node(struct trie *t, struct key_vector *tp,
 		goto noleaf;
 
 	/* retrieve child from parent node */
-	if (tp)
-		n = get_child(tp, get_index(key, tp));
-	else
-		n = rcu_dereference_rtnl(t->tnode[0]);
+	n = get_child(tp, get_index(key, tp));
 
 	/* Case 2: n is a LEAF or a TNODE and the key doesn't match.
 	 *
@@ -1018,7 +1009,7 @@ static int fib_insert_node(struct trie *t, struct key_vector *tp,
 		put_child(tn, get_index(key, tn) ^ 1, n);
 
 		/* start adding routes into the node */
-		put_child_root(tp, t, key, tn);
+		put_child_root(tp, key, tn);
 		node_set_parent(n, tn);
 
 		/* parent now has a NULL spot where the leaf can go */
@@ -1027,7 +1018,7 @@ static int fib_insert_node(struct trie *t, struct key_vector *tp,
 
 	/* Case 3: n is NULL, and will just insert a new leaf */
 	NODE_INIT_PARENT(l, tp);
-	put_child_root(tp, t, key, l);
+	put_child_root(tp, key, l);
 	trie_rebalance(t, tp);
 
 	return 0;
@@ -1261,7 +1252,10 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 	unsigned long index;
 	t_key cindex;
 
-	n = rcu_dereference(t->tnode[0]);
+	pn = t->kv;
+	cindex = 0;
+
+	n = get_child_rcu(pn, cindex);
 	if (!n)
 		return -EAGAIN;
 
@@ -1269,12 +1263,9 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 	this_cpu_inc(stats->gets);
 #endif
 
-	pn = n;
-	cindex = 0;
-
 	/* Step 1: Travel to the longest prefix match in the trie */
 	for (;;) {
-		index = get_index(key, n);
+		index = get_cindex(key, n);
 
 		/* This bit of code is a bit tricky but it combines multiple
 		 * checks into a single check.  The prefix consists of the
@@ -1345,13 +1336,17 @@ backtrace:
 			while (!cindex) {
 				t_key pkey = pn->key;
 
-				pn = node_parent_rcu(pn);
-				if (unlikely(!pn))
+				/* If we don't have a parent then there is
+				 * nothing for us to do as we do not have any
+				 * further nodes to parse.
+				 */
+				if (IS_TRIE(pn))
 					return -EAGAIN;
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 				this_cpu_inc(stats->backtrack);
 #endif
 				/* Get Child's index */
+				pn = node_parent_rcu(pn);
 				cindex = get_index(pkey, pn);
 			}
 
@@ -1436,7 +1431,7 @@ static void fib_remove_alias(struct trie *t, struct key_vector *tp,
 	 * out parent suffix lengths as a part of trie_rebalance
 	 */
 	if (hlist_empty(&l->leaf)) {
-		put_child_root(tp, t, l->key, NULL);
+		put_child_root(tp, l->key, NULL);
 		node_free(l);
 		trie_rebalance(t, tp);
 		return;
@@ -1528,38 +1523,32 @@ static struct key_vector *leaf_walk_rcu(struct key_vector **tn, t_key key)
 	struct key_vector *pn, *n = *tn;
 	unsigned long cindex;
 
-	/* record parent node for backtracing */
-	pn = n;
-	cindex = n ? get_index(key, n) : 0;
-
 	/* this loop is meant to try and find the key in the trie */
-	while (n) {
-		unsigned long idx = get_index(key, n);
-
-		/* guarantee forward progress on the keys */
-		if (IS_LEAF(n) && (n->key >= key))
-			goto found;
-		if (idx >= (1ul << n->bits))
-			break;
-
+	do {
 		/* record parent and next child index */
 		pn = n;
-		cindex = idx;
+		cindex = get_index(key, pn);
+
+		if (cindex >> pn->bits)
+			break;
 
 		/* descend into the next child */
 		n = get_child_rcu(pn, cindex++);
-	}
+		if (!n)
+			break;
+
+		/* guarantee forward progress on the keys */
+		if (IS_LEAF(n) && (n->key >= key))
+			goto found;
+	} while (IS_TNODE(n));
 
 	/* this loop will search for the next leaf with a greater key */
-	while (pn) {
+	while (!IS_TRIE(pn)) {
 		/* if we exhausted the parent node we will need to climb */
 		if (cindex >= (1ul << pn->bits)) {
 			t_key pkey = pn->key;
 
 			pn = node_parent_rcu(pn);
-			if (!pn)
-				break;
-
 			cindex = get_index(pkey, pn) + 1;
 			continue;
 		}
@@ -1582,7 +1571,7 @@ static struct key_vector *leaf_walk_rcu(struct key_vector **tn, t_key key)
 	return NULL; /* Root of trie */
 found:
 	/* if we are at the limit for keys just return NULL for the tnode */
-	*tn = (n->key == KEY_MAX) ? NULL : pn;
+	*tn = pn;
 	return n;
 }
 
@@ -1590,113 +1579,106 @@ found:
 void fib_table_flush_external(struct fib_table *tb)
 {
 	struct trie *t = (struct trie *)tb->tb_data;
+	struct key_vector *pn = t->kv;
+	unsigned long cindex = 1;
+	struct hlist_node *tmp;
 	struct fib_alias *fa;
-	struct key_vector *n, *pn;
-	unsigned long cindex;
 
-	n = rcu_dereference(t->tnode[0]);
-	if (!n)
-		return;
+	/* walk trie in reverse order */
+	for (;;) {
+		struct key_vector *n;
 
-	pn = NULL;
-	cindex = 0;
+		if (!(cindex--)) {
+			t_key pkey = pn->key;
 
-	while (IS_TNODE(n)) {
-		/* record pn and cindex for leaf walking */
-		pn = n;
-		cindex = 1ul << n->bits;
-backtrace:
-		/* walk trie in reverse order */
-		do {
-			while (!(cindex--)) {
-				t_key pkey = pn->key;
+			/* cannot resize the trie vector */
+			if (IS_TRIE(pn))
+				break;
 
-				/* if we got the root we are done */
-				pn = node_parent(pn);
-				if (!pn)
-					return;
+			/* no need to resize like in flush below */
+			pn = node_parent(pn);
+			cindex = get_index(pkey, pn);
 
-				cindex = get_index(pkey, pn);
-			}
+			continue;
+		}
 
-			/* grab the next available node */
-			n = get_child(pn, cindex);
-		} while (!n);
-	}
+		/* grab the next available node */
+		n = get_child(pn, cindex);
+		if (!n)
+			continue;
 
-	hlist_for_each_entry(fa, &n->leaf, fa_list) {
-		struct fib_info *fi = fa->fa_info;
+		if (IS_TNODE(n)) {
+			/* record pn and cindex for leaf walking */
+			pn = n;
+			cindex = 1ul << n->bits;
 
-		if (!fi || !(fi->fib_flags & RTNH_F_EXTERNAL))
 			continue;
+		}
 
-		netdev_switch_fib_ipv4_del(n->key,
-					   KEYLENGTH - fa->fa_slen,
-					   fi, fa->fa_tos,
-					   fa->fa_type, tb->tb_id);
-	}
+		hlist_for_each_entry_safe(fa, tmp, &n->leaf, fa_list) {
+			struct fib_info *fi = fa->fa_info;
+
+			if (!fi || !(fi->fib_flags & RTNH_F_EXTERNAL))
+				continue;
 
-	/* if trie is leaf only loop is completed */
-	if (pn)
-		goto backtrace;
+			netdev_switch_fib_ipv4_del(n->key,
+						   KEYLENGTH - fa->fa_slen,
+						   fi, fa->fa_tos,
+						   fa->fa_type, tb->tb_id);
+		}
+	}
 }
 
 /* Caller must hold RTNL. */
 int fib_table_flush(struct fib_table *tb)
 {
 	struct trie *t = (struct trie *)tb->tb_data;
-	struct key_vector *n, *pn;
+	struct key_vector *pn = t->kv;
+	unsigned long cindex = 1;
 	struct hlist_node *tmp;
 	struct fib_alias *fa;
-	unsigned long cindex;
-	unsigned char slen;
 	int found = 0;
 
-	n = rcu_dereference(t->tnode[0]);
-	if (!n)
-		goto flush_complete;
+	/* walk trie in reverse order */
+	for (;;) {
+		unsigned char slen = 0;
+		struct key_vector *n;
 
-	pn = NULL;
-	cindex = 0;
+		if (!(cindex--)) {
+			t_key pkey = pn->key;
 
-	while (IS_TNODE(n)) {
-		/* record pn and cindex for leaf walking */
-		pn = n;
-		cindex = 1ul << n->bits;
-backtrace:
-		/* walk trie in reverse order */
-		do {
-			while (!(cindex--)) {
-				struct key_vector __rcu **cptr;
-				t_key pkey = pn->key;
+			/* cannot resize the trie vector */
+			if (IS_TRIE(pn))
+				break;
 
-				n = pn;
-				pn = node_parent(n);
+			/* resize completed node */
+			pn = resize(t, pn);
+			cindex = get_index(pkey, pn);
 
-				/* resize completed node */
-				cptr = resize(t, n);
+			continue;
+		}
 
-				/* if we got the root we are done */
-				if (!pn)
-					goto flush_complete;
+		/* grab the next available node */
+		n = get_child(pn, cindex);
+		if (!n)
+			continue;
 
-				pn = container_of(cptr, struct key_vector,
-						  tnode[0]);
-				cindex = get_index(pkey, pn);
-			}
+		if (IS_TNODE(n)) {
+			/* record pn and cindex for leaf walking */
+			pn = n;
+			cindex = 1ul << n->bits;
 
-			/* grab the next available node */
-			n = get_child(pn, cindex);
-		} while (!n);
-	}
+			continue;
+		}
 
-	/* track slen in case any prefixes survive */
-	slen = 0;
+		hlist_for_each_entry_safe(fa, tmp, &n->leaf, fa_list) {
+			struct fib_info *fi = fa->fa_info;
 
-	hlist_for_each_entry_safe(fa, tmp, &n->leaf, fa_list) {
-		struct fib_info *fi = fa->fa_info;
+			if (!fi || !(fi->fib_flags & RTNH_F_DEAD)) {
+				slen = fa->fa_slen;
+				continue;
+			}
 
-		if (fi && (fi->fib_flags & RTNH_F_DEAD)) {
 			netdev_switch_fib_ipv4_del(n->key,
 						   KEYLENGTH - fa->fa_slen,
 						   fi, fa->fa_tos,
@@ -1705,27 +1687,19 @@ backtrace:
 			fib_release_info(fa->fa_info);
 			alias_free_mem_rcu(fa);
 			found++;
-
-			continue;
 		}
 
-		slen = fa->fa_slen;
-	}
-
-	/* update leaf slen */
-	n->slen = slen;
+		/* update leaf slen */
+		n->slen = slen;
 
-	if (hlist_empty(&n->leaf)) {
-		put_child_root(pn, t, n->key, NULL);
-		node_free(n);
-	} else {
-		leaf_pull_suffix(pn, n);
+		if (hlist_empty(&n->leaf)) {
+			put_child_root(pn, n->key, NULL);
+			node_free(n);
+		} else {
+			leaf_pull_suffix(pn, n);
+		}
 	}
 
-	/* if trie is leaf only loop is completed */
-	if (pn)
-		goto backtrace;
-flush_complete:
 	pr_debug("trie_flush found=%d\n", found);
 	return found;
 }
@@ -1787,15 +1761,13 @@ int fib_table_dump(struct fib_table *tb, struct sk_buff *skb,
 		   struct netlink_callback *cb)
 {
 	struct trie *t = (struct trie *)tb->tb_data;
-	struct key_vector *l, *tp;
+	struct key_vector *l, *tp = t->kv;
 	/* Dump starting at last key.
 	 * Note: 0.0.0.0/0 (ie default) is first key.
 	 */
 	int count = cb->args[2];
 	t_key key = cb->args[3];
 
-	tp = rcu_dereference_rtnl(t->tnode[0]);
-
 	while ((l = leaf_walk_rcu(&tp, key)) != NULL) {
 		if (fn_trie_dump_leaf(l, tb, skb, cb) < 0) {
 			cb->args[3] = key;
@@ -1831,14 +1803,12 @@ void __init fib_trie_init(void)
 					   0, SLAB_PANIC, NULL);
 }
 
-
 struct fib_table *fib_trie_table(u32 id)
 {
 	struct fib_table *tb;
 	struct trie *t;
 
-	tb = kmalloc(sizeof(struct fib_table) + sizeof(struct trie),
-		     GFP_KERNEL);
+	tb = kzalloc(sizeof(*tb) + sizeof(struct trie), GFP_KERNEL);
 	if (tb == NULL)
 		return NULL;
 
@@ -1847,7 +1817,8 @@ struct fib_table *fib_trie_table(u32 id)
 	tb->tb_num_default = 0;
 
 	t = (struct trie *) tb->tb_data;
-	RCU_INIT_POINTER(t->tnode[0], NULL);
+	t->kv[0].pos = KEYLENGTH;
+	t->kv[0].slen = KEYLENGTH;
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 	t->stats = alloc_percpu(struct trie_use_stats);
 	if (!t->stats) {
@@ -1872,57 +1843,55 @@ struct fib_trie_iter {
 static struct key_vector *fib_trie_get_next(struct fib_trie_iter *iter)
 {
 	unsigned long cindex = iter->index;
-	struct key_vector *tn = iter->tnode;
-	struct key_vector *p;
-
-	/* A single entry routing table */
-	if (!tn)
-		return NULL;
+	struct key_vector *pn = iter->tnode;
+	t_key pkey;
 
 	pr_debug("get_next iter={node=%p index=%d depth=%d}\n",
 		 iter->tnode, iter->index, iter->depth);
-rescan:
-	while (cindex < child_length(tn)) {
-		struct key_vector *n = get_child_rcu(tn, cindex);
 
-		if (n) {
+	while (!IS_TRIE(pn)) {
+		while (cindex < child_length(pn)) {
+			struct key_vector *n = get_child_rcu(pn, cindex++);
+
+			if (!n)
+				continue;
+
 			if (IS_LEAF(n)) {
-				iter->tnode = tn;
-				iter->index = cindex + 1;
+				iter->tnode = pn;
+				iter->index = cindex;
 			} else {
 				/* push down one level */
 				iter->tnode = n;
 				iter->index = 0;
 				++iter->depth;
 			}
+
 			return n;
 		}
 
-		++cindex;
-	}
-
-	/* Current node exhausted, pop back up */
-	p = node_parent_rcu(tn);
-	if (p) {
-		cindex = get_index(tn->key, p) + 1;
-		tn = p;
+		/* Current node exhausted, pop back up */
+		pkey = pn->key;
+		pn = node_parent_rcu(pn);
+		cindex = get_index(pkey, pn) + 1;
 		--iter->depth;
-		goto rescan;
 	}
 
-	/* got root? */
+	/* record root node so further searches know we are done */
+	iter->tnode = pn;
+	iter->index = 0;
+
 	return NULL;
 }
 
 static struct key_vector *fib_trie_get_first(struct fib_trie_iter *iter,
 					     struct trie *t)
 {
-	struct key_vector *n;
+	struct key_vector *n, *pn = t->kv;
 
 	if (!t)
 		return NULL;
 
-	n = rcu_dereference(t->tnode[0]);
+	n = rcu_dereference(pn->tnode[0]);
 	if (!n)
 		return NULL;
 
@@ -1931,7 +1900,7 @@ static struct key_vector *fib_trie_get_first(struct fib_trie_iter *iter,
 		iter->index = 0;
 		iter->depth = 1;
 	} else {
-		iter->tnode = NULL;
+		iter->tnode = pn;
 		iter->index = 0;
 		iter->depth = 0;
 	}
@@ -2228,7 +2197,7 @@ static int fib_trie_seq_show(struct seq_file *seq, void *v)
 	const struct fib_trie_iter *iter = seq->private;
 	struct key_vector *n = v;
 
-	if (!node_parent_rcu(n))
+	if (IS_TRIE(node_parent_rcu(n)))
 		fib_table_print(seq, iter->tb);
 
 	if (IS_TNODE(n)) {
@@ -2308,7 +2277,7 @@ static struct key_vector *fib_route_get_idx(struct fib_route_iter *iter,
 		key = iter->key;
 	} else {
 		t = (struct trie *)tb->tb_data;
-		iter->tnode = rcu_dereference_rtnl(t->tnode[0]);
+		iter->tnode = t->kv;
 		iter->pos = 0;
 		key = 0;
 	}
@@ -2354,7 +2323,7 @@ static void *fib_route_seq_start(struct seq_file *seq, loff_t *pos)
 		return fib_route_get_idx(iter, *pos);
 
 	t = (struct trie *)tb->tb_data;
-	iter->tnode = rcu_dereference_rtnl(t->tnode[0]);
+	iter->tnode = t->kv;
 	iter->pos = 0;
 	iter->key = 0;
 
