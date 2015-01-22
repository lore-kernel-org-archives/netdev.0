From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [next-next PATCH 4/7] fib_trie: Add collapse() and
 should_collapse() to resize
Date: Thu, 22 Jan 2015 15:51:26 -0800
Message-ID: <20150122235126.5779.89954.stgit@ahduyck-vm-fedora20>
References: <20150122234652.5779.44251.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50585 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753930AbbAVXv2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 18:51:28 -0500
In-Reply-To: <20150122234652.5779.44251.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch really does two things.

First it pulls the logic for determining if we should collapse one node out
of the tree and the actual code doing the collapse into a separate pair of
functions.  This helps to make the changes to these areas more readable.

Second it encodes the upper 32b of the empty_children value onto the
full_children value in the case of bits == KEYLENGTH.  By doing this we are
able to handle the case of a 32b node where empty_children would appear to
be 0 when it was actually 1ul << 32.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |  100 +++++++++++++++++++++++++++++++++------------------
 1 file changed, 65 insertions(+), 35 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 80892f5..f874e18 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -83,7 +83,8 @@
 
 #define MAX_STAT_DEPTH 32
 
-#define KEYLENGTH (8*sizeof(t_key))
+#define KEYLENGTH	(8*sizeof(t_key))
+#define KEY_MAX		((t_key)~0)
 
 typedef unsigned int t_key;
 
@@ -102,8 +103,8 @@ struct tnode {
 	union {
 		/* The fields in this struct are valid if bits > 0 (TNODE) */
 		struct {
-			unsigned int full_children;  /* KEYLENGTH bits needed */
-			unsigned int empty_children; /* KEYLENGTH bits needed */
+			t_key empty_children; /* KEYLENGTH bits needed */
+			t_key full_children;  /* KEYLENGTH bits needed */
 			struct tnode __rcu *child[0];
 		};
 		/* This list pointer if valid if bits == 0 (LEAF) */
@@ -302,6 +303,16 @@ static struct tnode *tnode_alloc(size_t size)
 		return vzalloc(size);
 }
 
+static inline void empty_child_inc(struct tnode *n)
+{
+	++n->empty_children ? : ++n->full_children;
+}
+
+static inline void empty_child_dec(struct tnode *n)
+{
+	n->empty_children-- ? : n->full_children--;
+}
+
 static struct tnode *leaf_new(t_key key)
 {
 	struct tnode *l = kmem_cache_alloc(trie_leaf_kmem, GFP_KERNEL);
@@ -335,7 +346,7 @@ static struct leaf_info *leaf_info_new(int plen)
 
 static struct tnode *tnode_new(t_key key, int pos, int bits)
 {
-	size_t sz = offsetof(struct tnode, child[1 << bits]);
+	size_t sz = offsetof(struct tnode, child[1ul << bits]);
 	struct tnode *tn = tnode_alloc(sz);
 	unsigned int shift = pos + bits;
 
@@ -348,8 +359,10 @@ static struct tnode *tnode_new(t_key key, int pos, int bits)
 		tn->pos = pos;
 		tn->bits = bits;
 		tn->key = (shift < KEYLENGTH) ? (key >> shift) << shift : 0;
-		tn->full_children = 0;
-		tn->empty_children = 1<<bits;
+		if (bits == KEYLENGTH)
+			tn->full_children = 1;
+		else
+			tn->empty_children = 1ul << bits;
 	}
 
 	pr_debug("AT %p s=%zu %zu\n", tn, sizeof(struct tnode),
@@ -375,11 +388,11 @@ static void put_child(struct tnode *tn, unsigned long i, struct tnode *n)
 
 	BUG_ON(i >= tnode_child_length(tn));
 
-	/* update emptyChildren */
+	/* update emptyChildren, overflow into fullChildren */
 	if (n == NULL && chi != NULL)
-		tn->empty_children++;
-	else if (n != NULL && chi == NULL)
-		tn->empty_children--;
+		empty_child_inc(tn);
+	if (n != NULL && chi == NULL)
+		empty_child_dec(tn);
 
 	/* update fullChildren */
 	wasfull = tnode_full(tn, chi);
@@ -630,6 +643,24 @@ static int halve(struct trie *t, struct tnode *oldtnode)
 	return 0;
 }
 
+static void collapse(struct trie *t, struct tnode *oldtnode)
+{
+	struct tnode *n, *tp;
+	unsigned long i;
+
+	/* scan the tnode looking for that one child that might still exist */
+	for (n = NULL, i = tnode_child_length(oldtnode); !n && i;)
+		n = tnode_get_child(oldtnode, --i);
+
+	/* compress one level */
+	tp = node_parent(oldtnode);
+	put_child_root(tp, t, oldtnode->key, n);
+	node_set_parent(n, tp);
+
+	/* drop dead node */
+	node_free(oldtnode);
+}
+
 static unsigned char update_suffix(struct tnode *tn)
 {
 	unsigned char slen = tn->pos;
@@ -729,10 +760,12 @@ static bool should_inflate(const struct tnode *tp, const struct tnode *tn)
 
 	/* Keep root node larger */
 	threshold *= tp ? inflate_threshold : inflate_threshold_root;
-	used += tn->full_children;
 	used -= tn->empty_children;
+	used += tn->full_children;
 
-	return tn->pos && ((50 * used) >= threshold);
+	/* if bits == KEYLENGTH then pos = 0, and will fail below */
+
+	return (used > 1) && tn->pos && ((50 * used) >= threshold);
 }
 
 static bool should_halve(const struct tnode *tp, const struct tnode *tn)
@@ -744,13 +777,29 @@ static bool should_halve(const struct tnode *tp, const struct tnode *tn)
 	threshold *= tp ? halve_threshold : halve_threshold_root;
 	used -= tn->empty_children;
 
-	return (tn->bits > 1) && ((100 * used) < threshold);
+	/* if bits == KEYLENGTH then used = 100% on wrap, and will fail below */
+
+	return (used > 1) && (tn->bits > 1) && ((100 * used) < threshold);
+}
+
+static bool should_collapse(const struct tnode *tn)
+{
+	unsigned long used = tnode_child_length(tn);
+
+	used -= tn->empty_children;
+
+	/* account for bits == KEYLENGTH case */
+	if ((tn->bits == KEYLENGTH) && tn->full_children)
+		used -= KEY_MAX;
+
+	/* One child or none, time to drop us from the trie */
+	return used < 2;
 }
 
 #define MAX_WORK 10
 static void resize(struct trie *t, struct tnode *tn)
 {
-	struct tnode *tp = node_parent(tn), *n = NULL;
+	struct tnode *tp = node_parent(tn);
 	struct tnode __rcu **cptr;
 	int max_work = MAX_WORK;
 
@@ -764,14 +813,6 @@ static void resize(struct trie *t, struct tnode *tn)
 	cptr = tp ? &tp->child[get_index(tn->key, tp)] : &t->trie;
 	BUG_ON(tn != rtnl_dereference(*cptr));
 
-	/* No children */
-	if (tn->empty_children > (tnode_child_length(tn) - 1))
-		goto no_children;
-
-	/* One child */
-	if (tn->empty_children == (tnode_child_length(tn) - 1))
-		goto one_child;
-
 	/* Double as long as the resulting node has a number of
 	 * nonempty nodes that are above the threshold.
 	 */
@@ -807,19 +848,8 @@ static void resize(struct trie *t, struct tnode *tn)
 	}
 
 	/* Only one child remains */
-	if (tn->empty_children == (tnode_child_length(tn) - 1)) {
-		unsigned long i;
-one_child:
-		for (i = tnode_child_length(tn); !n && i;)
-			n = tnode_get_child(tn, --i);
-no_children:
-		/* compress one level */
-		put_child_root(tp, t, tn->key, n);
-		node_set_parent(n, tp);
-
-		/* drop dead node */
-		tnode_free_init(tn);
-		tnode_free(tn);
+	if (should_collapse(tn)) {
+		collapse(t, tn);
 		return;
 	}
 
