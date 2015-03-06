From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH v2 04/10] fib_trie: replace tnode_get_child
 functions with get_child macros
Date: Fri, 06 Mar 2015 09:54:14 -0800
Message-ID: <20150306175414.2452.28316.stgit@ahduyck-vm-fedora20>
References: <20150306174814.2452.18308.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45465 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754395AbbCFRyQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Mar 2015 12:54:16 -0500
In-Reply-To: <20150306174814.2452.18308.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am replacing the tnode_get_child call with get_child since we are
techically pulling the child out of a key_vector now and not a tnode.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |   60 ++++++++++++++++++++-------------------------------
 1 file changed, 24 insertions(+), 36 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 8b21fc3..b9e2a61 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -159,9 +159,11 @@ static struct kmem_cache *trie_leaf_kmem __read_mostly;
 
 /* caller must hold RTNL */
 #define node_parent(n) rtnl_dereference((n)->parent)
+#define get_child(tn, i) rtnl_dereference((tn)->tnode[i])
 
 /* caller must hold RCU read lock or RTNL */
 #define node_parent_rcu(n) rcu_dereference_rtnl((n)->parent)
+#define get_child_rcu(tn, i) rcu_dereference_rtnl((tn)->tnode[i])
 
 /* wrapper for rcu_assign_pointer */
 static inline void node_set_parent(struct key_vector *n, struct key_vector *tp)
@@ -180,20 +182,6 @@ static inline unsigned long tnode_child_length(const struct key_vector *tn)
 	return (1ul << tn->bits) & ~(1ul);
 }
 
-/* caller must hold RTNL */
-static inline struct key_vector *tnode_get_child(struct key_vector *tn,
-						 unsigned long i)
-{
-	return rtnl_dereference(tn->tnode[i]);
-}
-
-/* caller must hold RCU read lock or RTNL */
-static inline struct key_vector *tnode_get_child_rcu(struct key_vector *tn,
-						     unsigned long i)
-{
-	return rcu_dereference_rtnl(tn->tnode[i]);
-}
-
 static inline struct fib_table *trie_get_table(struct trie *t)
 {
 	unsigned long *tb_data = (unsigned long *)t;
@@ -383,7 +371,7 @@ static inline int tnode_full(struct key_vector *tn, struct key_vector *n)
 static void put_child(struct key_vector *tn, unsigned long i,
 		      struct key_vector *n)
 {
-	struct key_vector *chi = tnode_get_child(tn, i);
+	struct key_vector *chi = get_child(tn, i);
 	int isfull, wasfull;
 
 	BUG_ON(i >= tnode_child_length(tn));
@@ -415,7 +403,7 @@ static void update_children(struct key_vector *tn)
 
 	/* update all of the child parent pointers */
 	for (i = tnode_child_length(tn); i;) {
-		struct key_vector *inode = tnode_get_child(tn, --i);
+		struct key_vector *inode = get_child(tn, --i);
 
 		if (!inode)
 			continue;
@@ -493,7 +481,7 @@ static struct key_vector __rcu **replace(struct trie *t,
 
 	/* resize children now that oldtnode is freed */
 	for (i = tnode_child_length(tn); i;) {
-		struct key_vector *inode = tnode_get_child(tn, --i);
+		struct key_vector *inode = get_child(tn, --i);
 
 		/* resize child node */
 		if (tnode_full(tn, inode))
@@ -525,7 +513,7 @@ static struct key_vector __rcu **inflate(struct trie *t,
 	 * nodes.
 	 */
 	for (i = tnode_child_length(oldtnode), m = 1u << tn->pos; i;) {
-		struct key_vector *inode = tnode_get_child(oldtnode, --i);
+		struct key_vector *inode = get_child(oldtnode, --i);
 		struct key_vector *node0, *node1;
 		unsigned long j, k;
 
@@ -544,8 +532,8 @@ static struct key_vector __rcu **inflate(struct trie *t,
 
 		/* An internal node with two children */
 		if (inode->bits == 1) {
-			put_child(tn, 2 * i + 1, tnode_get_child(inode, 1));
-			put_child(tn, 2 * i, tnode_get_child(inode, 0));
+			put_child(tn, 2 * i + 1, get_child(inode, 1));
+			put_child(tn, 2 * i, get_child(inode, 0));
 			continue;
 		}
 
@@ -575,10 +563,10 @@ static struct key_vector __rcu **inflate(struct trie *t,
 
 		/* populate child pointers in new nodes */
 		for (k = tnode_child_length(inode), j = k / 2; j;) {
-			put_child(node1, --j, tnode_get_child(inode, --k));
-			put_child(node0, j, tnode_get_child(inode, j));
-			put_child(node1, --j, tnode_get_child(inode, --k));
-			put_child(node0, j, tnode_get_child(inode, j));
+			put_child(node1, --j, get_child(inode, --k));
+			put_child(node0, j, get_child(inode, j));
+			put_child(node1, --j, get_child(inode, --k));
+			put_child(node0, j, get_child(inode, j));
 		}
 
 		/* link new nodes to parent */
@@ -620,8 +608,8 @@ static struct key_vector __rcu **halve(struct trie *t,
 	 * nodes.
 	 */
 	for (i = tnode_child_length(oldtnode); i;) {
-		struct key_vector *node1 = tnode_get_child(oldtnode, --i);
-		struct key_vector *node0 = tnode_get_child(oldtnode, --i);
+		struct key_vector *node1 = get_child(oldtnode, --i);
+		struct key_vector *node0 = get_child(oldtnode, --i);
 		struct key_vector *inode;
 
 		/* At least one of the children is empty */
@@ -661,7 +649,7 @@ static void collapse(struct trie *t, struct key_vector *oldtnode)
 
 	/* scan the tnode looking for that one child that might still exist */
 	for (n = NULL, i = tnode_child_length(oldtnode); !n && i;)
-		n = tnode_get_child(oldtnode, --i);
+		n = get_child(oldtnode, --i);
 
 	/* compress one level */
 	tp = node_parent(oldtnode);
@@ -683,7 +671,7 @@ static unsigned char update_suffix(struct key_vector *tn)
 	 * represent the nodes with suffix length equal to tn->pos
 	 */
 	for (i = 0, stride = 0x2ul ; i < tnode_child_length(tn); i += stride) {
-		struct key_vector *n = tnode_get_child(tn, i);
+		struct key_vector *n = get_child(tn, i);
 
 		if (!n || (n->slen <= slen))
 			continue;
@@ -942,7 +930,7 @@ static struct key_vector *fib_find_node(struct trie *t,
 			break;
 
 		pn = n;
-		n = tnode_get_child_rcu(n, index);
+		n = get_child_rcu(n, index);
 	}
 
 	*tp = pn;
@@ -1000,7 +988,7 @@ static int fib_insert_node(struct trie *t, struct key_vector *tp,
 
 	/* retrieve child from parent node */
 	if (tp)
-		n = tnode_get_child(tp, get_index(key, tp));
+		n = get_child(tp, get_index(key, tp));
 	else
 		n = rcu_dereference_rtnl(t->tnode[0]);
 
@@ -1309,7 +1297,7 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 			cindex = index;
 		}
 
-		n = tnode_get_child_rcu(n, index);
+		n = get_child_rcu(n, index);
 		if (unlikely(!n))
 			goto backtrace;
 	}
@@ -1551,7 +1539,7 @@ static struct key_vector *leaf_walk_rcu(struct key_vector **tn, t_key key)
 		cindex = idx;
 
 		/* descend into the next child */
-		n = tnode_get_child_rcu(pn, cindex++);
+		n = get_child_rcu(pn, cindex++);
 	}
 
 	/* this loop will search for the next leaf with a greater key */
@@ -1569,7 +1557,7 @@ static struct key_vector *leaf_walk_rcu(struct key_vector **tn, t_key key)
 		}
 
 		/* grab the next available node */
-		n = tnode_get_child_rcu(pn, cindex++);
+		n = get_child_rcu(pn, cindex++);
 		if (!n)
 			continue;
 
@@ -1624,7 +1612,7 @@ backtrace:
 			}
 
 			/* grab the next available node */
-			n = tnode_get_child(pn, cindex);
+			n = get_child(pn, cindex);
 		} while (!n);
 	}
 
@@ -1690,7 +1678,7 @@ backtrace:
 			}
 
 			/* grab the next available node */
-			n = tnode_get_child(pn, cindex);
+			n = get_child(pn, cindex);
 		} while (!n);
 	}
 
@@ -1887,7 +1875,7 @@ static struct key_vector *fib_trie_get_next(struct fib_trie_iter *iter)
 		 iter->tnode, iter->index, iter->depth);
 rescan:
 	while (cindex < tnode_child_length(tn)) {
-		struct key_vector *n = tnode_get_child_rcu(tn, cindex);
+		struct key_vector *n = get_child_rcu(tn, cindex);
 
 		if (n) {
 			if (IS_LEAF(n)) {
