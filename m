From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 22/29] fib_trie: Allocate tnode as array of key_vectors
 instead of key_vector as array of tnode pointers
Date: Tue, 24 Feb 2015 12:50:24 -0800
Message-ID: <20150224205023.26106.72566.stgit@ahduyck-vm-fedora20>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45640 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753011AbbBXUuZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 15:50:25 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKoPJ5016805
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:50:25 -0500
Received: from [192.168.122.173] (ovpn-112-73.phx2.redhat.com [10.3.112.73])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKoODT031170
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:50:24 -0500
In-Reply-To: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change makes it so that we allocate a tnode as an array of key vectors
instead of a key vector with an array of tnode pointers.  By doing this we
set things up for a 1 cache line reduction since this places the key, key
info, and pointer to the next object all within 16B on 64b systems, and
within 12B on 32b systems.

In addition I have reordered the layout of the key_vector so that the leaf
and tnode pointers are at the start of the structure.  By doing this what
we end up doing is effectively navigating a list of pointers one after the
other to get to the fib_alias we are looking for, and we make it so that
there are no holes in the structure.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |   99 ++++++++++++++++++++++++++-------------------------
 1 file changed, 51 insertions(+), 48 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 58c8a89..f9abbf4 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -93,16 +93,16 @@ typedef unsigned int t_key;
 #define IS_LEAF(n)	(!(n)->bits)
 
 struct key_vector {
-	t_key key;
-	unsigned char pos;		/* 2log(KEYLENGTH) bits needed */
-	unsigned char bits;		/* 2log(KEYLENGTH) bits needed */
-	unsigned char slen;
 	union {
 		/* This list pointer if valid if bits == 0 (LEAF) */
 		struct hlist_head leaf;
 		/* The fields in this struct are valid if bits > 0 (TNODE) */
-		struct key_vector __rcu *tnode[0];
+		struct key_vector __rcu *tnode;
 	};
+	t_key key;
+	unsigned char pos;		/* 2log(KEYLENGTH) bits needed */
+	unsigned char bits;		/* 2log(KEYLENGTH) bits needed */
+	unsigned char slen;
 };
 
 struct tnode {
@@ -110,7 +110,7 @@ struct tnode {
 	t_key empty_children;		/* KEYLENGTH bits needed */
 	t_key full_children;		/* KEYLENGTH bits needed */
 	struct key_vector __rcu *parent;
-	struct key_vector kv[1];
+	struct key_vector kv[0];
 #define tn_bits kv[0].bits
 };
 
@@ -176,11 +176,11 @@ static inline struct fib_table *table_info(struct key_vector *kv)
 
 /* caller must hold RTNL */
 #define node_parent(tn) rtnl_dereference(tn_info(tn)->parent)
-#define get_child(tn, i) rtnl_dereference((tn)->tnode[i])
+#define get_child(tn) rtnl_dereference((tn)->tnode)
 
 /* caller must hold RCU read lock or RTNL */
 #define node_parent_rcu(tn) rcu_dereference_rtnl(tn_info(tn)->parent)
-#define get_child_rcu(tn, i) rcu_dereference_rtnl((tn)->tnode[i])
+#define get_child_rcu(tn) rcu_dereference_rtnl((tn)->tnode)
 
 /* wrapper for rcu_assign_pointer */
 #define node_set_parent(n, p) rcu_assign_pointer(tn_info(n)->parent, p)
@@ -281,9 +281,9 @@ static inline void alias_free_mem_rcu(struct fib_alias *fa)
 	call_rcu(&fa->rcu, __alias_free_mem);
 }
 
-#define TNODE_SIZE(n) offsetof(struct tnode, kv[0].tnode[n])
+#define TNODE_SIZE(n) offsetof(struct tnode, kv[n])
 #define TNODE_KMALLOC_MAX \
-	ilog2((PAGE_SIZE - TNODE_SIZE(0)) / sizeof(struct key_vector *))
+	ilog2((PAGE_SIZE - TNODE_SIZE(0)) / sizeof(struct key_vector))
 
 static void __node_free_rcu(struct rcu_head *head)
 {
@@ -352,7 +352,7 @@ static inline int tnode_full(struct key_vector *tn, struct key_vector *n)
 static void put_child(struct key_vector *tn, unsigned long i,
 		      struct key_vector *n)
 {
-	struct key_vector *chi = get_child(tn, i);
+	struct key_vector *chi = get_child(tn + i);
 	int isfull, wasfull;
 
 	BUG_ON(i >= child_length(tn));
@@ -375,7 +375,10 @@ static void put_child(struct key_vector *tn, unsigned long i,
 	if (n && (tn->slen < n->slen))
 		tn->slen = n->slen;
 
-	rcu_assign_pointer(tn->tnode[i], n);
+	/* update offset to correct key_vector for update */
+	tn += i;
+
+	rcu_assign_pointer(tn->tnode, n);
 }
 
 static void update_children(struct key_vector *tn)
@@ -384,7 +387,7 @@ static void update_children(struct key_vector *tn)
 
 	/* update all of the child parent pointers */
 	for (i = IS_TRIE(tn) ? 1 : child_length(tn); i;) {
-		struct key_vector *inode = get_child(tn, --i);
+		struct key_vector *inode = get_child(tn + --i);
 
 		if (!inode)
 			continue;
@@ -404,7 +407,7 @@ static inline void put_child_root(struct key_vector *tp, t_key key,
 				  struct key_vector *n)
 {
 	if (IS_TRIE(tp))
-		rcu_assign_pointer(tp->tnode[0], n);
+		rcu_assign_pointer(tp->tnode, n);
 	else
 		put_child(tp, get_index(key, tp), n);
 }
@@ -461,10 +464,12 @@ static void tnode_replace(struct key_vector *oldtn,
 			  struct key_vector *tn)
 {
 	struct key_vector *pn = node_parent(oldtn);
-	unsigned long i = get_index(tn->key, pn);
+
+	/* update offset to correct key_vector for pointer update */
+	pn += get_index(tn->key, pn);
 
 	/* setup the parent pointer out of and back into this node */
-	rcu_assign_pointer(pn->tnode[i], tn);
+	rcu_assign_pointer(pn->tnode, tn);
 
 	/* update all of the child parent pointers */
 	update_children(tn);
@@ -573,7 +578,7 @@ static struct key_vector *resize_children(struct net *net, struct trie *t,
 
 	/* resize children now that oldtnode is freed */
 	for (i = child_length(tn); i;) {
-		struct key_vector *inode = get_child(tn, --i);
+		struct key_vector *inode = get_child(tn + --i);
 
 		/* resize child node */
 		if (tnode_full(tn, inode))
@@ -611,7 +616,7 @@ static struct key_vector *inflate(struct net *net, struct trie *t,
 	 * nodes.
 	 */
 	for (i = child_length(oldtnode), m = 1u << tn->pos; i;) {
-		struct key_vector *inode = get_child(oldtnode, --i);
+		struct key_vector *inode = get_child(oldtnode + --i);
 		struct key_vector *node0, *node1;
 		unsigned long j, k;
 
@@ -630,8 +635,8 @@ static struct key_vector *inflate(struct net *net, struct trie *t,
 
 		/* An internal node with two children */
 		if (inode->bits == 1) {
-			put_child(tn, 2 * i + 1, get_child(inode, 1));
-			put_child(tn, 2 * i, get_child(inode, 0));
+			put_child(tn, 2 * i + 1, get_child(inode + 1));
+			put_child(tn, 2 * i, get_child(inode));
 			continue;
 		}
 
@@ -663,10 +668,10 @@ static struct key_vector *inflate(struct net *net, struct trie *t,
 
 		/* populate child pointers in new nodes */
 		for (k = child_length(inode), j = k / 2; j;) {
-			put_child(node1, --j, get_child(inode, --k));
-			put_child(node0, j, get_child(inode, j));
-			put_child(node1, --j, get_child(inode, --k));
-			put_child(node0, j, get_child(inode, j));
+			put_child(node1, --j, get_child(inode + --k));
+			put_child(node0, j, get_child(inode + j));
+			put_child(node1, --j, get_child(inode + --k));
+			put_child(node0, j, get_child(inode + j));
 		}
 	}
 
@@ -708,8 +713,8 @@ static struct key_vector *halve(struct net *net, struct trie *t,
 	 * nodes.
 	 */
 	for (i = child_length(oldtnode); i;) {
-		struct key_vector *node1 = get_child(oldtnode, --i);
-		struct key_vector *node0 = get_child(oldtnode, --i);
+		struct key_vector *node1 = get_child(oldtnode + --i);
+		struct key_vector *node0 = get_child(oldtnode + --i);
 		struct key_vector *inode;
 
 		/* At least one of the children is empty */
@@ -751,7 +756,7 @@ static struct key_vector *collapse(struct net *net, struct trie *t,
 
 	/* scan the tnode looking for that one child that might still exist */
 	for (i = child_length(oldtnode); i--;) {
-		struct key_vector *n = get_child(oldtnode, i);
+		struct key_vector *n = get_child(oldtnode + i);
 
 		if (!n)
 			continue;
@@ -790,7 +795,7 @@ static unsigned char update_suffix(struct key_vector *tn)
 	 * represent the nodes with suffix length equal to tn->pos
 	 */
 	for (i = 0, stride = 0x2ul ; i < child_length(tn); i += stride) {
-		struct key_vector *n = get_child(tn, i);
+		struct key_vector *n = get_child(tn + i);
 
 		if (!n || (n->slen <= slen))
 			continue;
@@ -932,7 +937,7 @@ static struct key_vector *resize(struct net *net, struct trie *t,
 	 * doing it ourselves.  This way we can let RCU fully do its
 	 * thing without us interfering
 	 */
-	BUG_ON(tn != get_child(tp, cindex));
+	BUG_ON(tn != get_child(tp + cindex));
 
 	/* Double as long as the resulting node has a number of
 	 * nonempty nodes that are above the threshold.
@@ -947,7 +952,7 @@ static struct key_vector *resize(struct net *net, struct trie *t,
 		}
 
 		max_work--;
-		tn = get_child(tp, cindex);
+		tn = get_child(tp + cindex);
 	}
 
 	/* Return if at least one inflate is run */
@@ -967,7 +972,7 @@ static struct key_vector *resize(struct net *net, struct trie *t,
 		}
 
 		max_work--;
-		tn = get_child(tp, cindex);
+		tn = get_child(tp + cindex);
 	}
 
 	/* Only one child remains */
@@ -1021,7 +1026,7 @@ static struct key_vector *fib_find_node(struct trie *t,
 
 	do {
 		*tp = n;
-		n = get_child_rcu(n, index);
+		n = get_child_rcu(n + index);
 
 		if (!n)
 			break;
@@ -1098,7 +1103,7 @@ static struct fib_table *fib_insert_node(struct net *net, struct trie *t,
 		goto noleaf;
 
 	/* retrieve child from parent node */
-	n = get_child(tp, get_index(key, tp));
+	n = get_child(tp + get_index(key, tp));
 
 	/* Case 2: n is a LEAF or a TNODE and the key doesn't match.
 	 *
@@ -1346,7 +1351,7 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 	pn = t->kv;
 	cindex = 0;
 
-	n = get_child_rcu(pn, cindex);
+	n = get_child_rcu(pn);
 	if (!n)
 		return -EAGAIN;
 
@@ -1383,16 +1388,13 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 			cindex = index;
 		}
 
-		n = get_child_rcu(n, index);
+		n = get_child_rcu(n + index);
 		if (unlikely(!n))
 			goto backtrace;
 	}
 
 	/* Step 2: Sort out leaves and begin backtracing for longest prefix */
 	for (;;) {
-		/* record the pointer where our next node pointer is stored */
-		struct key_vector __rcu **cptr = n->tnode;
-
 		/* This test verifies that none of the bits that differ
 		 * between the key and the prefix exist in the region of
 		 * the lsb and higher in the prefix.
@@ -1409,7 +1411,7 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 		 * we started this traversal anyway
 		 */
 
-		while ((n = rcu_dereference(*cptr)) == NULL) {
+		while ((n = get_child_rcu(n)) == NULL) {
 backtrace:
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 			if (!n)
@@ -1441,7 +1443,7 @@ backtrace:
 			cindex &= cindex - 1;
 
 			/* grab pointer for next child node */
-			cptr = &pn->tnode[cindex];
+			n = pn + cindex;
 		}
 	}
 
@@ -1616,7 +1618,7 @@ static struct key_vector *leaf_walk_rcu(struct key_vector **pn, t_key key)
 			break;
 
 		/* descend into the next child */
-		n = get_child_rcu(tn, cindex++);
+		n = get_child_rcu(tn + cindex++);
 		if (!n)
 			break;
 
@@ -1637,7 +1639,7 @@ static struct key_vector *leaf_walk_rcu(struct key_vector **pn, t_key key)
 		}
 
 		/* grab the next available node */
-		n = get_child_rcu(tn, cindex++);
+		n = get_child_rcu(tn + cindex++);
 		if (!n)
 			continue;
 
@@ -1688,7 +1690,7 @@ int fib_table_flush(struct net *net, struct fib_table *tb)
 		}
 
 		/* grab the next available node */
-		n = get_child(pn, cindex);
+		n = get_child(pn + cindex);
 		if (!n)
 			continue;
 
@@ -1827,7 +1829,8 @@ void __init fib_trie_init(void)
 					  0, SLAB_PANIC, NULL);
 
 	trie_leaf_kmem = kmem_cache_create("ip_fib_trie",
-					   sizeof(struct tnode),
+					   sizeof(struct tnode) +
+					   sizeof(struct key_vector),
 					   0, SLAB_PANIC, NULL);
 }
 
@@ -1879,7 +1882,7 @@ static struct key_vector *fib_trie_get_next(struct fib_trie_iter *iter)
 
 	while (!IS_TRIE(pn)) {
 		while (cindex < child_length(pn)) {
-			struct key_vector *n = get_child_rcu(pn, cindex++);
+			struct key_vector *n = get_child_rcu(pn + cindex++);
 
 			if (!n)
 				continue;
@@ -1919,7 +1922,7 @@ static struct key_vector *fib_trie_get_first(struct fib_trie_iter *iter,
 	if (!t)
 		return NULL;
 
-	n = rcu_dereference(pn->tnode[0]);
+	n = rcu_dereference(pn->tnode);
 	if (!n)
 		return NULL;
 
@@ -2003,8 +2006,8 @@ static void trie_show_stats(struct seq_file *seq, struct trie_stat *stat)
 	seq_putc(seq, '\n');
 	seq_printf(seq, "\tPointers: %u\n", pointers);
 
-	bytes += sizeof(struct key_vector *) * pointers;
-	seq_printf(seq, "Null ptrs: %u\n", stat->nullpointers);
+	bytes += sizeof(struct key_vector) * pointers;
+	seq_printf(seq, "Empty vectors: %u\n", stat->nullpointers);
 	seq_printf(seq, "Total size: %u  kB\n", (bytes + 1023) / 1024);
 }
 
