From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 5/6] fib_trie: move leaf and tnode to occupy the
 same spot in the key vector
Date: Mon, 02 Mar 2015 13:32:48 -0800
Message-ID: <20150302213247.1490.45691.stgit@ahduyck-vm-fedora20>
References: <20150302212637.1490.33609.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39758 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753689AbbCBVcu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2015 16:32:50 -0500
In-Reply-To: <20150302212637.1490.33609.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we are going to compact the leaf and tnode we first need to make sure
the fields are all in the same place.  In that regard I am moving the leaf
pointer which represents the fib_alias hash list to occupy what is
currently the first key_vector pointer.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |   51 +++++++++++++++++++++++++++------------------------
 1 file changed, 27 insertions(+), 24 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 454b8c5..502c89c 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -94,24 +94,27 @@ typedef unsigned int t_key;
 #define get_index(_key, _kv) (((_key) ^ (_kv)->key) >> (_kv)->pos)
 
 struct tnode {
+	struct rcu_head rcu;
+
+	t_key empty_children; /* KEYLENGTH bits needed */
+	t_key full_children;  /* KEYLENGTH bits needed */
+	struct tnode __rcu *parent;
+
 	t_key key;
-	unsigned char bits;		/* 2log(KEYLENGTH) bits needed */
 	unsigned char pos;		/* 2log(KEYLENGTH) bits needed */
+	unsigned char bits;		/* 2log(KEYLENGTH) bits needed */
 	unsigned char slen;
-	struct tnode __rcu *parent;
-	struct rcu_head rcu;
 	union {
-		/* The fields in this struct are valid if bits > 0 (TNODE) */
-		struct {
-			t_key empty_children; /* KEYLENGTH bits needed */
-			t_key full_children;  /* KEYLENGTH bits needed */
-			struct tnode __rcu *child[0];
-		};
-		/* This list pointer if valid if bits == 0 (LEAF) */
+		/* This list pointer if valid if (pos | bits) == 0 (LEAF) */
 		struct hlist_head leaf;
+		/* This array is valid if (pos | bits) > 0 (TNODE) */
+		struct tnode __rcu *tnode[0];
 	};
 };
 
+#define TNODE_SIZE(n)	offsetof(struct tnode, tnode[n])
+#define LEAF_SIZE	TNODE_SIZE(1)
+
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 struct trie_use_stats {
 	unsigned int gets;
@@ -180,14 +183,14 @@ static inline unsigned long tnode_child_length(const struct tnode *tn)
 static inline struct tnode *tnode_get_child(const struct tnode *tn,
 					    unsigned long i)
 {
-	return rtnl_dereference(tn->child[i]);
+	return rtnl_dereference(tn->tnode[i]);
 }
 
 /* caller must hold RCU read lock or RTNL */
 static inline struct tnode *tnode_get_child_rcu(const struct tnode *tn,
 						unsigned long i)
 {
-	return rcu_dereference_rtnl(tn->child[i]);
+	return rcu_dereference_rtnl(tn->tnode[i]);
 }
 
 /* To understand this stuff, an understanding of keys and all their bits is
@@ -266,7 +269,7 @@ static inline void alias_free_mem_rcu(struct fib_alias *fa)
 }
 
 #define TNODE_KMALLOC_MAX \
-	ilog2((PAGE_SIZE - sizeof(struct tnode)) / sizeof(struct tnode *))
+	ilog2((PAGE_SIZE - TNODE_SIZE(0)) / sizeof(struct tnode *))
 
 static void __node_free_rcu(struct rcu_head *head)
 {
@@ -324,7 +327,7 @@ static struct tnode *leaf_new(t_key key, struct fib_alias *fa)
 
 static struct tnode *tnode_new(t_key key, int pos, int bits)
 {
-	size_t sz = offsetof(struct tnode, child[1ul << bits]);
+	size_t sz = TNODE_SIZE(1ul << bits);
 	struct tnode *tn = tnode_alloc(sz);
 	unsigned int shift = pos + bits;
 
@@ -343,7 +346,7 @@ static struct tnode *tnode_new(t_key key, int pos, int bits)
 			tn->empty_children = 1ul << bits;
 	}
 
-	pr_debug("AT %p s=%zu %zu\n", tn, sizeof(struct tnode),
+	pr_debug("AT %p s=%zu %zu\n", tn, TNODE_SIZE(0),
 		 sizeof(struct tnode *) << bits);
 	return tn;
 }
@@ -384,7 +387,7 @@ static void put_child(struct tnode *tn, unsigned long i, struct tnode *n)
 	if (n && (tn->slen < n->slen))
 		tn->slen = n->slen;
 
-	rcu_assign_pointer(tn->child[i], n);
+	rcu_assign_pointer(tn->tnode[i], n);
 }
 
 static void update_children(struct tnode *tn)
@@ -435,7 +438,7 @@ static void tnode_free(struct tnode *tn)
 
 	while (head) {
 		head = head->next;
-		tnode_free_size += offsetof(struct tnode, child[1 << tn->bits]);
+		tnode_free_size += TNODE_SIZE(1ul << tn->bits);
 		node_free(tn);
 
 		tn = container_of(head, struct tnode, rcu);
@@ -788,7 +791,7 @@ static void resize(struct trie *t, struct tnode *tn)
 	 * doing it ourselves.  This way we can let RCU fully do its
 	 * thing without us interfering
 	 */
-	cptr = tp ? &tp->child[get_index(tn->key, tp)] : &t->trie;
+	cptr = tp ? &tp->tnode[get_index(tn->key, tp)] : &t->trie;
 	BUG_ON(tn != rtnl_dereference(*cptr));
 
 	/* Double as long as the resulting node has a number of
@@ -1235,7 +1238,7 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 	/* Step 2: Sort out leaves and begin backtracing for longest prefix */
 	for (;;) {
 		/* record the pointer where our next node pointer is stored */
-		struct tnode __rcu **cptr = n->child;
+		struct tnode __rcu **cptr = n->tnode;
 
 		/* This test verifies that none of the bits that differ
 		 * between the key and the prefix exist in the region of
@@ -1281,7 +1284,7 @@ backtrace:
 			cindex &= cindex - 1;
 
 			/* grab pointer for next child node */
-			cptr = &pn->child[cindex];
+			cptr = &pn->tnode[cindex];
 		}
 	}
 
@@ -1679,7 +1682,7 @@ void __init fib_trie_init(void)
 					  0, SLAB_PANIC, NULL);
 
 	trie_leaf_kmem = kmem_cache_create("ip_fib_trie",
-					   sizeof(struct tnode),
+					   LEAF_SIZE,
 					   0, SLAB_PANIC, NULL);
 }
 
@@ -1837,13 +1840,13 @@ static void trie_show_stats(struct seq_file *seq, struct trie_stat *stat)
 	seq_printf(seq, "\tMax depth:      %u\n", stat->maxdepth);
 
 	seq_printf(seq, "\tLeaves:         %u\n", stat->leaves);
-	bytes = sizeof(struct tnode) * stat->leaves;
+	bytes = LEAF_SIZE * stat->leaves;
 
 	seq_printf(seq, "\tPrefixes:       %u\n", stat->prefixes);
 	bytes += sizeof(struct fib_alias) * stat->prefixes;
 
 	seq_printf(seq, "\tInternal nodes: %u\n\t", stat->tnodes);
-	bytes += sizeof(struct tnode) * stat->tnodes;
+	bytes += TNODE_SIZE(0) * stat->tnodes;
 
 	max = MAX_STAT_DEPTH;
 	while (max > 0 && stat->nodesizes[max-1] == 0)
@@ -1912,7 +1915,7 @@ static int fib_triestat_seq_show(struct seq_file *seq, void *v)
 	seq_printf(seq,
 		   "Basic info: size of leaf:"
 		   " %Zd bytes, size of tnode: %Zd bytes.\n",
-		   sizeof(struct tnode), sizeof(struct tnode));
+		   LEAF_SIZE, TNODE_SIZE(0));
 
 	for (h = 0; h < FIB_TABLE_HASHSZ; h++) {
 		struct hlist_head *head = &net->ipv4.fib_table_hash[h];
