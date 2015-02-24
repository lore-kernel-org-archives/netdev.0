From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 11/29] fib_trie: Rename tnode to key_vector
Date: Tue, 24 Feb 2015 12:49:09 -0800
Message-ID: <20150224204909.26106.16294.stgit@ahduyck-vm-fedora20>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53824 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751866AbbBXUtL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 15:49:11 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKnAtE008775
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:49:11 -0500
Received: from [192.168.122.173] (ovpn-112-73.phx2.redhat.com [10.3.112.73])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKn9du031040
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:49:10 -0500
In-Reply-To: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename the tnode to key_vector.  The key_vector will be the eventual
container for all of the information needed by either a leaf or a tnode.
The final result should be much smaller than the 40 bytes currently needed
for either one.

This also updates the trie struct so that it contains an array of size 1 of
tnode pointers.  This is to bring the structure more inline with how an
actual tnode itself is configured.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |  267 +++++++++++++++++++++++++++------------------------
 1 file changed, 141 insertions(+), 126 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index be1ffe8..cffbe47 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -93,19 +93,19 @@ typedef unsigned int t_key;
 
 #define get_index(_key, _kv) (((_key) ^ (_kv)->key) >> (_kv)->pos)
 
-struct tnode {
+struct key_vector {
 	t_key key;
 	unsigned char bits;		/* 2log(KEYLENGTH) bits needed */
 	unsigned char pos;		/* 2log(KEYLENGTH) bits needed */
 	unsigned char slen;
-	struct tnode __rcu *parent;
+	struct key_vector __rcu *parent;
 	struct rcu_head rcu;
 	union {
 		/* The fields in this struct are valid if bits > 0 (TNODE) */
 		struct {
 			t_key empty_children; /* KEYLENGTH bits needed */
 			t_key full_children;  /* KEYLENGTH bits needed */
-			struct tnode __rcu *child[0];
+			struct key_vector __rcu *tnode[0];
 		};
 		/* This list pointer if valid if bits == 0 (LEAF) */
 		struct hlist_head leaf;
@@ -134,14 +134,14 @@ struct trie_stat {
 };
 
 struct trie {
-	struct tnode __rcu *trie;
+	struct key_vector __rcu *tnode[1];
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 	struct trie_use_stats __percpu *stats;
 #endif
 	struct rcu_head rcu;
 };
 
-static struct tnode **resize(struct trie *t, struct tnode *tn);
+static struct key_vector **resize(struct trie *t, struct key_vector *tn);
 static size_t tnode_free_size;
 
 /*
@@ -161,7 +161,7 @@ static struct kmem_cache *trie_leaf_kmem __read_mostly;
 #define node_parent_rcu(n) rcu_dereference_rtnl((n)->parent)
 
 /* wrapper for rcu_assign_pointer */
-static inline void node_set_parent(struct tnode *n, struct tnode *tp)
+static inline void node_set_parent(struct key_vector *n, struct key_vector *tp)
 {
 	if (n)
 		rcu_assign_pointer(n->parent, tp);
@@ -172,23 +172,23 @@ static inline void node_set_parent(struct tnode *n, struct tnode *tp)
 /* This provides us with the number of children in this node, in the case of a
  * leaf this will return 0 meaning none of the children are accessible.
  */
-static inline unsigned long tnode_child_length(const struct tnode *tn)
+static inline unsigned long tnode_child_length(const struct key_vector *tn)
 {
 	return (1ul << tn->bits) & ~(1ul);
 }
 
 /* caller must hold RTNL */
-static inline struct tnode *tnode_get_child(const struct tnode *tn,
-					    unsigned long i)
+static inline struct key_vector *tnode_get_child(struct key_vector *tn,
+						 unsigned long i)
 {
-	return rtnl_dereference(tn->child[i]);
+	return rtnl_dereference(tn->tnode[i]);
 }
 
 /* caller must hold RCU read lock or RTNL */
-static inline struct tnode *tnode_get_child_rcu(const struct tnode *tn,
-						unsigned long i)
+static inline struct key_vector *tnode_get_child_rcu(struct key_vector *tn,
+						     unsigned long i)
 {
-	return rcu_dereference_rtnl(tn->child[i]);
+	return rcu_dereference_rtnl(tn->tnode[i]);
 }
 
 static inline struct fib_table *trie_get_table(struct trie *t)
@@ -273,12 +273,13 @@ static inline void alias_free_mem_rcu(struct fib_alias *fa)
 	call_rcu(&fa->rcu, __alias_free_mem);
 }
 
+#define TNODE_SIZE sizeof(struct key_vector)
 #define TNODE_KMALLOC_MAX \
-	ilog2((PAGE_SIZE - sizeof(struct tnode)) / sizeof(struct tnode *))
+	ilog2((PAGE_SIZE - TNODE_SIZE) / sizeof(struct key_vector *))
 
 static void __node_free_rcu(struct rcu_head *head)
 {
-	struct tnode *n = container_of(head, struct tnode, rcu);
+	struct key_vector *n = container_of(head, struct key_vector, rcu);
 
 	if (IS_LEAF(n))
 		kmem_cache_free(trie_leaf_kmem, n);
@@ -290,7 +291,7 @@ static void __node_free_rcu(struct rcu_head *head)
 
 #define node_free(n) call_rcu(&n->rcu, __node_free_rcu)
 
-static struct tnode *tnode_alloc(size_t size)
+static struct key_vector *tnode_alloc(size_t size)
 {
 	if (size <= PAGE_SIZE)
 		return kzalloc(size, GFP_KERNEL);
@@ -298,19 +299,19 @@ static struct tnode *tnode_alloc(size_t size)
 		return vzalloc(size);
 }
 
-static inline void empty_child_inc(struct tnode *n)
+static inline void empty_child_inc(struct key_vector *n)
 {
 	++n->empty_children ? : ++n->full_children;
 }
 
-static inline void empty_child_dec(struct tnode *n)
+static inline void empty_child_dec(struct key_vector *n)
 {
 	n->empty_children-- ? : n->full_children--;
 }
 
-static struct tnode *leaf_new(t_key key, struct fib_alias *fa)
+static struct key_vector *leaf_new(t_key key, struct fib_alias *fa)
 {
-	struct tnode *l = kmem_cache_alloc(trie_leaf_kmem, GFP_KERNEL);
+	struct key_vector *l = kmem_cache_alloc(trie_leaf_kmem, GFP_KERNEL);
 	if (l) {
 		l->parent = NULL;
 		/* set key and pos to reflect full key value
@@ -330,10 +331,10 @@ static struct tnode *leaf_new(t_key key, struct fib_alias *fa)
 	return l;
 }
 
-static struct tnode *tnode_new(t_key key, int pos, int bits)
+static struct key_vector *tnode_new(t_key key, int pos, int bits)
 {
-	size_t sz = offsetof(struct tnode, child[1ul << bits]);
-	struct tnode *tn = tnode_alloc(sz);
+	size_t sz = offsetof(struct key_vector, tnode[1ul << bits]);
+	struct key_vector *tn = tnode_alloc(sz);
 	unsigned int shift = pos + bits;
 
 	/* verify bits and pos their msb bits clear and values are valid */
@@ -351,15 +352,15 @@ static struct tnode *tnode_new(t_key key, int pos, int bits)
 			tn->empty_children = 1ul << bits;
 	}
 
-	pr_debug("AT %p s=%zu %zu\n", tn, sizeof(struct tnode),
-		 sizeof(struct tnode *) << bits);
+	pr_debug("AT %p s=%zu %zu\n", tn, TNODE_SIZE,
+		 sizeof(struct key_vector *) << bits);
 	return tn;
 }
 
 /* Check whether a tnode 'n' is "full", i.e. it is an internal node
  * and no bits are skipped. See discussion in dyntree paper p. 6
  */
-static inline int tnode_full(const struct tnode *tn, const struct tnode *n)
+static inline int tnode_full(struct key_vector *tn, struct key_vector *n)
 {
 	return n && ((n->pos + n->bits) == tn->pos) && IS_TNODE(n);
 }
@@ -367,9 +368,10 @@ static inline int tnode_full(const struct tnode *tn, const struct tnode *n)
 /* Add a child at position i overwriting the old value.
  * Update the value of full_children and empty_children.
  */
-static void put_child(struct tnode *tn, unsigned long i, struct tnode *n)
+static void put_child(struct key_vector *tn, unsigned long i,
+		      struct key_vector *n)
 {
-	struct tnode *chi = tnode_get_child(tn, i);
+	struct key_vector *chi = tnode_get_child(tn, i);
 	int isfull, wasfull;
 
 	BUG_ON(i >= tnode_child_length(tn));
@@ -392,16 +394,16 @@ static void put_child(struct tnode *tn, unsigned long i, struct tnode *n)
 	if (n && (tn->slen < n->slen))
 		tn->slen = n->slen;
 
-	rcu_assign_pointer(tn->child[i], n);
+	rcu_assign_pointer(tn->tnode[i], n);
 }
 
-static void update_children(struct tnode *tn)
+static void update_children(struct key_vector *tn)
 {
 	unsigned long i;
 
 	/* update all of the child parent pointers */
 	for (i = tnode_child_length(tn); i;) {
-		struct tnode *inode = tnode_get_child(tn, --i);
+		struct key_vector *inode = tnode_get_child(tn, --i);
 
 		if (!inode)
 			continue;
@@ -417,36 +419,38 @@ static void update_children(struct tnode *tn)
 	}
 }
 
-static inline void put_child_root(struct tnode *tp, struct trie *t,
-				  t_key key, struct tnode *n)
+static inline void put_child_root(struct key_vector *tp, struct trie *t,
+				  t_key key, struct key_vector *n)
 {
 	if (tp)
 		put_child(tp, get_index(key, tp), n);
 	else
-		rcu_assign_pointer(t->trie, n);
+		rcu_assign_pointer(t->tnode[0], n);
 }
 
-static inline void tnode_free_init(struct tnode *tn)
+static inline void tnode_free_init(struct key_vector *tn)
 {
 	tn->rcu.next = NULL;
 }
 
-static inline void tnode_free_append(struct tnode *tn, struct tnode *n)
+static inline void tnode_free_append(struct key_vector *tn,
+				     struct key_vector *n)
 {
 	n->rcu.next = tn->rcu.next;
 	tn->rcu.next = &n->rcu;
 }
 
-static void tnode_free(struct tnode *tn)
+static void tnode_free(struct key_vector *tn)
 {
 	struct callback_head *head = &tn->rcu;
 
 	while (head) {
 		head = head->next;
-		tnode_free_size += offsetof(struct tnode, child[1 << tn->bits]);
+		tnode_free_size += offsetof(struct key_vector,
+					    tnode[1 << tn->bits]);
 		node_free(tn);
 
-		tn = container_of(head, struct tnode, rcu);
+		tn = container_of(head, struct key_vector, rcu);
 	}
 
 	if (tnode_free_size >= PAGE_SIZE * sync_pages) {
@@ -455,11 +459,12 @@ static void tnode_free(struct tnode *tn)
 	}
 }
 
-static struct tnode __rcu **replace(struct trie *t, struct tnode *oldtnode,
-				    struct tnode *tn)
+static struct key_vector __rcu **replace(struct trie *t,
+					 struct key_vector *oldtnode,
+					 struct key_vector *tn)
 {
-	struct tnode *tp = node_parent(oldtnode);
-	struct tnode **cptr;
+	struct key_vector *tp = node_parent(oldtnode);
+	struct key_vector **cptr;
 	unsigned long i;
 
 	/* setup the parent pointer out of and back into this node */
@@ -473,11 +478,11 @@ static struct tnode __rcu **replace(struct trie *t, struct tnode *oldtnode,
 	tnode_free(oldtnode);
 
 	/* record the pointer that is pointing to this node */
-	cptr = tp ? tp->child : &t->trie;
+	cptr = tp ? tp->tnode : t->tnode;
 
 	/* resize children now that oldtnode is freed */
 	for (i = tnode_child_length(tn); i;) {
-		struct tnode *inode = tnode_get_child(tn, --i);
+		struct key_vector *inode = tnode_get_child(tn, --i);
 
 		/* resize child node */
 		if (tnode_full(tn, inode))
@@ -487,9 +492,10 @@ static struct tnode __rcu **replace(struct trie *t, struct tnode *oldtnode,
 	return cptr;
 }
 
-static struct tnode __rcu **inflate(struct trie *t, struct tnode *oldtnode)
+static struct key_vector __rcu **inflate(struct trie *t,
+					 struct key_vector *oldtnode)
 {
-	struct tnode *tn;
+	struct key_vector *tn;
 	unsigned long i;
 	t_key m;
 
@@ -508,8 +514,8 @@ static struct tnode __rcu **inflate(struct trie *t, struct tnode *oldtnode)
 	 * nodes.
 	 */
 	for (i = tnode_child_length(oldtnode), m = 1u << tn->pos; i;) {
-		struct tnode *inode = tnode_get_child(oldtnode, --i);
-		struct tnode *node0, *node1;
+		struct key_vector *inode = tnode_get_child(oldtnode, --i);
+		struct key_vector *node0, *node1;
 		unsigned long j, k;
 
 		/* An empty child */
@@ -582,9 +588,10 @@ notnode:
 	return NULL;
 }
 
-static struct tnode __rcu **halve(struct trie *t, struct tnode *oldtnode)
+static struct key_vector __rcu **halve(struct trie *t,
+				       struct key_vector *oldtnode)
 {
-	struct tnode *tn;
+	struct key_vector *tn;
 	unsigned long i;
 
 	pr_debug("In halve\n");
@@ -602,9 +609,9 @@ static struct tnode __rcu **halve(struct trie *t, struct tnode *oldtnode)
 	 * nodes.
 	 */
 	for (i = tnode_child_length(oldtnode); i;) {
-		struct tnode *node1 = tnode_get_child(oldtnode, --i);
-		struct tnode *node0 = tnode_get_child(oldtnode, --i);
-		struct tnode *inode;
+		struct key_vector *node1 = tnode_get_child(oldtnode, --i);
+		struct key_vector *node0 = tnode_get_child(oldtnode, --i);
+		struct key_vector *inode;
 
 		/* At least one of the children is empty */
 		if (!node1 || !node0) {
@@ -636,9 +643,9 @@ notnode:
 	return NULL;
 }
 
-static void collapse(struct trie *t, struct tnode *oldtnode)
+static void collapse(struct trie *t, struct key_vector *oldtnode)
 {
-	struct tnode *n, *tp;
+	struct key_vector *n, *tp;
 	unsigned long i;
 
 	/* scan the tnode looking for that one child that might still exist */
@@ -654,7 +661,7 @@ static void collapse(struct trie *t, struct tnode *oldtnode)
 	node_free(oldtnode);
 }
 
-static unsigned char update_suffix(struct tnode *tn)
+static unsigned char update_suffix(struct key_vector *tn)
 {
 	unsigned char slen = tn->pos;
 	unsigned long stride, i;
@@ -665,7 +672,7 @@ static unsigned char update_suffix(struct tnode *tn)
 	 * represent the nodes with suffix length equal to tn->pos
 	 */
 	for (i = 0, stride = 0x2ul ; i < tnode_child_length(tn); i += stride) {
-		struct tnode *n = tnode_get_child(tn, i);
+		struct key_vector *n = tnode_get_child(tn, i);
 
 		if (!n || (n->slen <= slen))
 			continue;
@@ -746,7 +753,7 @@ static unsigned char update_suffix(struct tnode *tn)
  *    tnode_child_length(tn)
  *
  */
-static bool should_inflate(const struct tnode *tp, const struct tnode *tn)
+static inline bool should_inflate(struct key_vector *tp, struct key_vector *tn)
 {
 	unsigned long used = tnode_child_length(tn);
 	unsigned long threshold = used;
@@ -761,7 +768,7 @@ static bool should_inflate(const struct tnode *tp, const struct tnode *tn)
 	return (used > 1) && tn->pos && ((50 * used) >= threshold);
 }
 
-static bool should_halve(const struct tnode *tp, const struct tnode *tn)
+static inline bool should_halve(struct key_vector *tp, struct key_vector *tn)
 {
 	unsigned long used = tnode_child_length(tn);
 	unsigned long threshold = used;
@@ -775,7 +782,7 @@ static bool should_halve(const struct tnode *tp, const struct tnode *tn)
 	return (used > 1) && (tn->bits > 1) && ((100 * used) < threshold);
 }
 
-static bool should_collapse(const struct tnode *tn)
+static inline bool should_collapse(struct key_vector *tn)
 {
 	unsigned long used = tnode_child_length(tn);
 
@@ -790,14 +797,15 @@ static bool should_collapse(const struct tnode *tn)
 }
 
 #define MAX_WORK 10
-static struct tnode __rcu **resize(struct trie *t, struct tnode *tn)
+static struct key_vector __rcu **resize(struct trie *t,
+					struct key_vector *tn)
 {
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 	struct trie_use_stats __percpu *stats = t->stats;
 #endif
-	struct tnode *tp = node_parent(tn);
+	struct key_vector *tp = node_parent(tn);
 	unsigned long cindex = tp ? get_index(tn->key, tp) : 0;
-	struct tnode __rcu **cptr = tp ? tp->child : &t->trie;
+	struct key_vector __rcu **cptr = tp ? tp->tnode : t->tnode;
 	int max_work = MAX_WORK;
 
 	pr_debug("In tnode_resize %p inflate_threshold=%d threshold=%d\n",
@@ -813,7 +821,7 @@ static struct tnode __rcu **resize(struct trie *t, struct tnode *tn)
 	 * nonempty nodes that are above the threshold.
 	 */
 	while (should_inflate(tp, tn) && max_work) {
-		struct tnode __rcu **tcptr = inflate(t, tn);
+		struct key_vector __rcu **tcptr = inflate(t, tn);
 
 		if (!tcptr) {
 #ifdef CONFIG_IP_FIB_TRIE_STATS
@@ -835,7 +843,7 @@ static struct tnode __rcu **resize(struct trie *t, struct tnode *tn)
 	 * node is above threshold.
 	 */
 	while (should_halve(tp, tn) && max_work) {
-		struct tnode __rcu **tcptr = halve(t, tn);
+		struct key_vector __rcu **tcptr = halve(t, tn);
 
 		if (!tcptr) {
 #ifdef CONFIG_IP_FIB_TRIE_STATS
@@ -870,7 +878,7 @@ static struct tnode __rcu **resize(struct trie *t, struct tnode *tn)
 	return cptr;
 }
 
-static void leaf_pull_suffix(struct tnode *tp, struct tnode *l)
+static void leaf_pull_suffix(struct key_vector *tp, struct key_vector *l)
 {
 	while (tp && (tp->slen > tp->pos) && (tp->slen > l->slen)) {
 		if (update_suffix(tp) > l->slen)
@@ -879,7 +887,7 @@ static void leaf_pull_suffix(struct tnode *tp, struct tnode *l)
 	}
 }
 
-static void leaf_push_suffix(struct tnode *tn, struct tnode *l)
+static void leaf_push_suffix(struct key_vector *tn, struct key_vector *l)
 {
 	/* if this is a new leaf then tn will be NULL and we can sort
 	 * out parent suffix lengths as a part of trie_rebalance
@@ -891,9 +899,10 @@ static void leaf_push_suffix(struct tnode *tn, struct tnode *l)
 }
 
 /* rcu_read_lock needs to be hold by caller from readside */
-static struct tnode *fib_find_node(struct trie *t, struct tnode **tp, u32 key)
+static struct key_vector *fib_find_node(struct trie *t,
+					struct key_vector **tp, u32 key)
 {
-	struct tnode *n = rcu_dereference_rtnl(t->trie);
+	struct key_vector *n = rcu_dereference_rtnl(t->tnode[0]);
 
 	*tp = NULL;
 
@@ -949,26 +958,29 @@ static struct fib_alias *fib_find_alias(struct hlist_head *fah, u8 slen,
 	return NULL;
 }
 
-static struct fib_table *trie_rebalance(struct trie *t, struct tnode *tn)
+static struct fib_table *trie_rebalance(struct trie *t,
+					struct key_vector *tn)
 {
-	struct tnode __rcu **cptr = &t->trie;
+	struct key_vector __rcu **cptr = t->tnode;
 
 	while (tn) {
-		struct tnode *tp = node_parent(tn);
+		struct key_vector *tp = node_parent(tn);
 
 		cptr = resize(t, tn);
 		if (!tp)
 			break;
-		tn = container_of(cptr, struct tnode, child[0]);
+		tn = container_of(cptr, struct key_vector, tnode[0]);
 	}
 
-	return trie_get_table(container_of(cptr, struct trie, trie));
+	return trie_get_table(container_of(cptr, struct trie, tnode[0]));
 }
 
-static struct fib_table *fib_insert_node(struct trie *t, struct tnode *tp,
-					 struct fib_alias *new, t_key key)
+static struct fib_table *fib_insert_node(struct trie *t,
+					 struct key_vector *tp,
+					 struct fib_alias *new,
+					 t_key key)
 {
-	struct tnode *n, *l;
+	struct key_vector *n, *l;
 
 	l = leaf_new(key, new);
 	if (!l)
@@ -978,7 +990,7 @@ static struct fib_table *fib_insert_node(struct trie *t, struct tnode *tp,
 	if (tp)
 		n = tnode_get_child(tp, get_index(key, tp));
 	else
-		n = rcu_dereference_rtnl(t->trie);
+		n = rcu_dereference_rtnl(t->tnode[0]);
 
 	/* Case 2: n is a LEAF or a TNODE and the key doesn't match.
 	 *
@@ -987,7 +999,7 @@ static struct fib_table *fib_insert_node(struct trie *t, struct tnode *tp,
 	 *  leaves us in position for handling as case 3
 	 */
 	if (n) {
-		struct tnode *tn;
+		struct key_vector *tn;
 
 		tn = tnode_new(key, __fls(key ^ n->key), 1);
 		if (!tn)
@@ -1017,7 +1029,8 @@ noleaf:
 }
 
 static struct fib_table *fib_insert_alias(struct trie *t,
-					  struct tnode *tp, struct tnode *l,
+					  struct key_vector *tp,
+					  struct key_vector *l,
 					  struct fib_alias *new,
 					  struct fib_alias *fa,
 					  t_key key)
@@ -1054,7 +1067,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 {
 	struct trie *t = (struct trie *)tb->tb_data;
 	struct fib_alias *fa, *new_fa;
-	struct tnode *l, *tp;
+	struct key_vector *l, *tp;
 	struct fib_info *fi;
 	u8 plen = cfg->fc_dst_len;
 	u8 slen = KEYLENGTH - plen;
@@ -1201,7 +1214,7 @@ err:
 	return err;
 }
 
-static inline t_key prefix_mismatch(t_key key, struct tnode *n)
+static inline t_key prefix_mismatch(t_key key, struct key_vector *n)
 {
 	t_key prefix = n->key;
 
@@ -1217,11 +1230,11 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 	struct trie_use_stats __percpu *stats = t->stats;
 #endif
 	const t_key key = ntohl(flp->daddr);
-	struct tnode *n, *pn;
+	struct key_vector *n, *pn;
 	struct fib_alias *fa;
 	t_key cindex;
 
-	n = rcu_dereference(t->trie);
+	n = rcu_dereference(t->tnode[0]);
 	if (!n)
 		return -EAGAIN;
 
@@ -1269,7 +1282,7 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 	/* Step 2: Sort out leaves and begin backtracing for longest prefix */
 	for (;;) {
 		/* record the pointer where our next node pointer is stored */
-		struct tnode __rcu **cptr = n->child;
+		struct key_vector __rcu **cptr = n->tnode;
 
 		/* This test verifies that none of the bits that differ
 		 * between the key and the prefix exist in the region of
@@ -1315,7 +1328,7 @@ backtrace:
 			cindex &= cindex - 1;
 
 			/* grab pointer for next child node */
-			cptr = &pn->child[cindex];
+			cptr = &pn->tnode[cindex];
 		}
 	}
 
@@ -1375,8 +1388,8 @@ found:
 }
 EXPORT_SYMBOL_GPL(fib_table_lookup);
 
-static void fib_remove_alias(struct trie *t, struct tnode *tp,
-			     struct tnode *l, struct fib_alias *old)
+static void fib_remove_alias(struct trie *t, struct key_vector *tp,
+			     struct key_vector *l, struct fib_alias *old)
 {
 	/* record the location of the previous list_info entry */
 	struct hlist_node **pprev = old->fa_list.pprev;
@@ -1409,7 +1422,7 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 {
 	struct trie *t = (struct trie *) tb->tb_data;
 	struct fib_alias *fa, *fa_to_delete;
-	struct tnode *l, *tp;
+	struct key_vector *l, *tp;
 	u8 plen = cfg->fc_dst_len;
 	u8 slen = KEYLENGTH - plen;
 	u8 tos = cfg->fc_tos;
@@ -1473,9 +1486,9 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 }
 
 /* Scan for the next leaf starting at the provided key value */
-static struct tnode *leaf_walk_rcu(struct tnode **pn, t_key key)
+static struct key_vector *leaf_walk_rcu(struct key_vector **pn, t_key key)
 {
-	struct tnode *tn = NULL, *n = *pn;
+	struct key_vector *tn = NULL, *n = *pn;
 	unsigned long cindex;
 
 	/* record parent node for backtracing */
@@ -1540,14 +1553,14 @@ found:
 int fib_table_flush(struct fib_table *tb)
 {
 	struct trie *t = (struct trie *)tb->tb_data;
+	struct key_vector *n, *pn;
 	struct hlist_node *tmp;
 	struct fib_alias *fa;
-	struct tnode *n, *pn;
 	unsigned long cindex;
 	unsigned char slen;
 	int found = 0;
 
-	n = rcu_dereference(t->trie);
+	n = rcu_dereference(t->tnode[0]);
 	if (!n)
 		goto flush_complete;
 
@@ -1562,7 +1575,7 @@ backtrace:
 		/* walk trie in reverse order */
 		do {
 			while (!(cindex--)) {
-				struct tnode __rcu **cptr;
+				struct key_vector __rcu **cptr;
 				t_key pkey = pn->key;
 
 				n = pn;
@@ -1575,7 +1588,8 @@ backtrace:
 				if (!pn)
 					goto flush_complete;
 
-				pn = container_of(cptr, struct tnode, child[0]);
+				pn = container_of(cptr, struct key_vector,
+						  tnode[0]);
 				cindex = get_index(pkey, pn);
 			}
 
@@ -1638,7 +1652,7 @@ void fib_free_table(struct fib_table *tb)
 	call_rcu(&t->rcu, __trie_free_rcu);
 }
 
-static int fn_trie_dump_leaf(struct tnode *l, struct fib_table *tb,
+static int fn_trie_dump_leaf(struct key_vector *l, struct fib_table *tb,
 			     struct sk_buff *skb, struct netlink_callback *cb)
 {
 	__be32 xkey = htonl(l->key);
@@ -1679,14 +1693,14 @@ int fib_table_dump(struct fib_table *tb, struct sk_buff *skb,
 		   struct netlink_callback *cb)
 {
 	struct trie *t = (struct trie *)tb->tb_data;
-	struct tnode *l, *tp;
+	struct key_vector *l, *tp;
 	/* Dump starting at last key.
 	 * Note: 0.0.0.0/0 (ie default) is first key.
 	 */
 	int count = cb->args[2];
 	t_key key = cb->args[3];
 
-	tp = rcu_dereference_rtnl(t->trie);
+	tp = rcu_dereference_rtnl(t->tnode[0]);
 
 	while ((l = leaf_walk_rcu(&tp, key)) != NULL) {
 		if (fn_trie_dump_leaf(l, tb, skb, cb) < 0) {
@@ -1719,7 +1733,7 @@ void __init fib_trie_init(void)
 					  0, SLAB_PANIC, NULL);
 
 	trie_leaf_kmem = kmem_cache_create("ip_fib_trie",
-					   sizeof(struct tnode),
+					   TNODE_SIZE,
 					   0, SLAB_PANIC, NULL);
 }
 
@@ -1739,7 +1753,7 @@ struct fib_table *fib_trie_table(u32 id)
 	tb->tb_num_default = 0;
 
 	t = (struct trie *) tb->tb_data;
-	RCU_INIT_POINTER(t->trie, NULL);
+	RCU_INIT_POINTER(t->tnode[0], NULL);
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 	t->stats = alloc_percpu(struct trie_use_stats);
 	if (!t->stats) {
@@ -1756,16 +1770,16 @@ struct fib_table *fib_trie_table(u32 id)
 struct fib_trie_iter {
 	struct seq_net_private p;
 	struct fib_table *tb;
-	struct tnode *tnode;
+	struct key_vector *tnode;
 	unsigned int index;
 	unsigned int depth;
 };
 
-static struct tnode *fib_trie_get_next(struct fib_trie_iter *iter)
+static struct key_vector *fib_trie_get_next(struct fib_trie_iter *iter)
 {
 	unsigned long cindex = iter->index;
-	struct tnode *tn = iter->tnode;
-	struct tnode *p;
+	struct key_vector *tn = iter->tnode;
+	struct key_vector *p;
 
 	/* A single entry routing table */
 	if (!tn)
@@ -1775,7 +1789,7 @@ static struct tnode *fib_trie_get_next(struct fib_trie_iter *iter)
 		 iter->tnode, iter->index, iter->depth);
 rescan:
 	while (cindex < tnode_child_length(tn)) {
-		struct tnode *n = tnode_get_child_rcu(tn, cindex);
+		struct key_vector *n = tnode_get_child_rcu(tn, cindex);
 
 		if (n) {
 			if (IS_LEAF(n)) {
@@ -1806,15 +1820,15 @@ rescan:
 	return NULL;
 }
 
-static struct tnode *fib_trie_get_first(struct fib_trie_iter *iter,
-				       struct trie *t)
+static struct key_vector *fib_trie_get_first(struct fib_trie_iter *iter,
+					     struct trie *t)
 {
-	struct tnode *n;
+	struct key_vector *n;
 
 	if (!t)
 		return NULL;
 
-	n = rcu_dereference(t->trie);
+	n = rcu_dereference(t->tnode[0]);
 	if (!n)
 		return NULL;
 
@@ -1833,7 +1847,7 @@ static struct tnode *fib_trie_get_first(struct fib_trie_iter *iter,
 
 static void trie_collect_stats(struct trie *t, struct trie_stat *s)
 {
-	struct tnode *n;
+	struct key_vector *n;
 	struct fib_trie_iter iter;
 
 	memset(s, 0, sizeof(*s));
@@ -1877,13 +1891,13 @@ static void trie_show_stats(struct seq_file *seq, struct trie_stat *stat)
 	seq_printf(seq, "\tMax depth:      %u\n", stat->maxdepth);
 
 	seq_printf(seq, "\tLeaves:         %u\n", stat->leaves);
-	bytes = sizeof(struct tnode) * stat->leaves;
+	bytes = TNODE_SIZE * stat->leaves;
 
 	seq_printf(seq, "\tPrefixes:       %u\n", stat->prefixes);
 	bytes += sizeof(struct fib_alias) * stat->prefixes;
 
 	seq_printf(seq, "\tInternal nodes: %u\n\t", stat->tnodes);
-	bytes += sizeof(struct tnode) * stat->tnodes;
+	bytes += TNODE_SIZE * stat->tnodes;
 
 	max = MAX_STAT_DEPTH;
 	while (max > 0 && stat->nodesizes[max-1] == 0)
@@ -1898,7 +1912,7 @@ static void trie_show_stats(struct seq_file *seq, struct trie_stat *stat)
 	seq_putc(seq, '\n');
 	seq_printf(seq, "\tPointers: %u\n", pointers);
 
-	bytes += sizeof(struct tnode *) * pointers;
+	bytes += sizeof(struct key_vector *) * pointers;
 	seq_printf(seq, "Null ptrs: %u\n", stat->nullpointers);
 	seq_printf(seq, "Total size: %u  kB\n", (bytes + 1023) / 1024);
 }
@@ -1952,7 +1966,7 @@ static int fib_triestat_seq_show(struct seq_file *seq, void *v)
 	seq_printf(seq,
 		   "Basic info: size of leaf:"
 		   " %Zd bytes, size of tnode: %Zd bytes.\n",
-		   sizeof(struct tnode), sizeof(struct tnode));
+		   TNODE_SIZE, TNODE_SIZE);
 
 	for (h = 0; h < FIB_TABLE_HASHSZ; h++) {
 		struct hlist_head *head = &net->ipv4.fib_table_hash[h];
@@ -1991,7 +2005,7 @@ static const struct file_operations fib_triestat_fops = {
 	.release = single_release_net,
 };
 
-static struct tnode *fib_trie_get_idx(struct seq_file *seq, loff_t pos)
+static struct key_vector *fib_trie_get_idx(struct seq_file *seq, loff_t pos)
 {
 	struct fib_trie_iter *iter = seq->private;
 	struct net *net = seq_file_net(seq);
@@ -2003,7 +2017,7 @@ static struct tnode *fib_trie_get_idx(struct seq_file *seq, loff_t pos)
 		struct fib_table *tb;
 
 		hlist_for_each_entry_rcu(tb, head, tb_hlist) {
-			struct tnode *n;
+			struct key_vector *n;
 
 			for (n = fib_trie_get_first(iter,
 						    (struct trie *) tb->tb_data);
@@ -2032,7 +2046,7 @@ static void *fib_trie_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	struct fib_table *tb = iter->tb;
 	struct hlist_node *tb_node;
 	unsigned int h;
-	struct tnode *n;
+	struct key_vector *n;
 
 	++*pos;
 	/* next node in same table */
@@ -2118,7 +2132,7 @@ static inline const char *rtn_type(char *buf, size_t len, unsigned int t)
 static int fib_trie_seq_show(struct seq_file *seq, void *v)
 {
 	const struct fib_trie_iter *iter = seq->private;
-	struct tnode *n = v;
+	struct key_vector *n = v;
 
 	if (!node_parent_rcu(n))
 		fib_table_print(seq, iter->tb);
@@ -2180,15 +2194,16 @@ static const struct file_operations fib_trie_fops = {
 struct fib_route_iter {
 	struct seq_net_private p;
 	struct fib_table *main_tb;
-	struct tnode *tnode;
+	struct key_vector *tnode;
 	loff_t	pos;
 	t_key	key;
 };
 
-static struct tnode *fib_route_get_idx(struct fib_route_iter *iter, loff_t pos)
+static struct key_vector *fib_route_get_idx(struct fib_route_iter *iter,
+					    loff_t pos)
 {
 	struct fib_table *tb = iter->main_tb;
-	struct tnode *l, **tp = &iter->tnode;
+	struct key_vector *l, **tp = &iter->tnode;
 	struct trie *t;
 	t_key key;
 
@@ -2198,7 +2213,7 @@ static struct tnode *fib_route_get_idx(struct fib_route_iter *iter, loff_t pos)
 		key = iter->key;
 	} else {
 		t = (struct trie *)tb->tb_data;
-		iter->tnode = rcu_dereference_rtnl(t->trie);
+		iter->tnode = rcu_dereference_rtnl(t->tnode[0]);
 		iter->pos = 0;
 		key = 0;
 	}
@@ -2244,7 +2259,7 @@ static void *fib_route_seq_start(struct seq_file *seq, loff_t *pos)
 		return fib_route_get_idx(iter, *pos);
 
 	t = (struct trie *)tb->tb_data;
-	iter->tnode = rcu_dereference_rtnl(t->trie);
+	iter->tnode = rcu_dereference_rtnl(t->tnode[0]);
 	iter->pos = 0;
 	iter->key = 0;
 
@@ -2254,7 +2269,7 @@ static void *fib_route_seq_start(struct seq_file *seq, loff_t *pos)
 static void *fib_route_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct fib_route_iter *iter = seq->private;
-	struct tnode *l = NULL;
+	struct key_vector *l = NULL;
 	t_key key = iter->key;
 
 	++*pos;
@@ -2302,7 +2317,7 @@ static unsigned int fib_flag_trans(int type, __be32 mask, const struct fib_info
 static int fib_route_seq_show(struct seq_file *seq, void *v)
 {
 	struct fib_alias *fa;
-	struct tnode *l = v;
+	struct key_vector *l = v;
 	__be32 prefix;
 
 	if (v == SEQ_START_TOKEN) {
