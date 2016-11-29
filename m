From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net] fib_trie: Avoid expensive update of suffix length when not required
Date: Tue, 29 Nov 2016 17:46:45 +0000
Message-ID: <1480441605-27855-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Robert Shearman <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:54199 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753367AbcK2SgB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 13:36:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With certain distributions of routes it can take a long time to add
and delete further routes at scale. For example, with a route for
10.37.96.0/20 present it takes 47s to add ~200k contiguous /24 routes
from 8.0.0.0/24 through to 11.138.207.0/24. Perf shows the bottleneck
is update_suffix:

      40.39%  [kernel]                      [k] update_suffix
       8.02%  libnl-3.so.200.19.0           [.] nl_hash_table_lookup

With these changes, the time is reduced to 4s for the same scale and
distribution of routes.

The issue is that update_suffix does an O(n) walk on the children of a
node and the with a dense distribtion of routes the number of children
in a node tends towards the number of nodes in the tree.

In the add case it isn't necessary to walk all the other children to
update the largest suffix length of the node (which is what
update_suffix is doing) since we already know what the largest suffix
length of all the other children is and we only need to update it if
the new node/leaf has a larger suffix. However, it is currently called
from resize which is called on any update to rebalance the trie.

Therefore improve the scaling by moving the responsibility of
recalculating the node's largest suffix length out of the resize
function into its callers. For fib_insert_node this can be taken care
of by extending put_child to not only update the largest suffix length
in the parent node, but to propagate it all the way up the trie as
required, using a new function, node_push_suffix, based on
leaf_push_suffix, but renamed to reflect its purpose and made safe if
the node has no parent.

No changes are required to inflate/halve since the maximum suffix
length of the sub-trie starting from the node's parent isn't changed,
and the suffix lengths of the halved/inflated nodes are updated
through the creation of the new nodes and put_child called to add the
children to them.

In both fib_table_flush and fib_table_flush_external, given that a
walk of the entire trie is being done there's a choice of optimising
either for the case of a small number of leafs being flushed by
updating the suffix on a change and propagating it up, or optimising
for large numbers of leafs being flushed by deferring the updating of
the largest suffix length to the walk up to the parent node. I opted
for the latter to keep the algorithm linear in complexity in the case
of flushing all leafs and because it is close to the status quo.

Fixes: 5405afd1a306 ("fib_trie: Add tracking value for suffix length")
Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 net/ipv4/fib_trie.c | 86 ++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 62 insertions(+), 24 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 026f309c51e9..701cae8af44a 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -421,8 +421,22 @@ static inline int tnode_full(struct key_vector *tn, struct key_vector *n)
 	return n && ((n->pos + n->bits) == tn->pos) && IS_TNODE(n);
 }
 
+static void node_push_suffix(struct key_vector *tn, struct key_vector *l)
+{
+	while (tn->slen < l->slen) {
+		tn->slen = l->slen;
+		tn = node_parent(tn);
+		if (!tn)
+			break;
+	}
+}
+
 /* Add a child at position i overwriting the old value.
  * Update the value of full_children and empty_children.
+ *
+ * The suffix length of the parent node and the rest of the tree is
+ * updated (if required) when adding/replacing a node, but is caller's
+ * responsibility on removal.
  */
 static void put_child(struct key_vector *tn, unsigned long i,
 		      struct key_vector *n)
@@ -447,8 +461,8 @@ static void put_child(struct key_vector *tn, unsigned long i,
 	else if (!wasfull && isfull)
 		tn_info(tn)->full_children++;
 
-	if (n && (tn->slen < n->slen))
-		tn->slen = n->slen;
+	if (n)
+		node_push_suffix(tn, n);
 
 	rcu_assign_pointer(tn->tnode[i], n);
 }
@@ -919,34 +933,35 @@ static struct key_vector *resize(struct trie *t, struct key_vector *tn)
 	if (max_work != MAX_WORK)
 		return tp;
 
-	/* push the suffix length to the parent node */
-	if (tn->slen > tn->pos) {
-		unsigned char slen = update_suffix(tn);
-
-		if (slen > tp->slen)
-			tp->slen = slen;
-	}
-
 	return tp;
 }
 
-static void leaf_pull_suffix(struct key_vector *tp, struct key_vector *l)
+static void node_set_suffix(struct key_vector *tp, unsigned char slen)
 {
-	while ((tp->slen > tp->pos) && (tp->slen > l->slen)) {
-		if (update_suffix(tp) > l->slen)
+	if (slen > tp->slen)
+		tp->slen = slen;
+}
+
+static void node_pull_suffix(struct key_vector *tn)
+{
+	struct key_vector *tp;
+	unsigned char slen;
+
+	slen = update_suffix(tn);
+	tp = node_parent(tn);
+	while ((tp->slen > tp->pos) && (tp->slen > slen)) {
+		if (update_suffix(tp) > slen)
 			break;
 		tp = node_parent(tp);
 	}
 }
 
-static void leaf_push_suffix(struct key_vector *tn, struct key_vector *l)
+static void leaf_pull_suffix(struct key_vector *tp, struct key_vector *l)
 {
-	/* if this is a new leaf then tn will be NULL and we can sort
-	 * out parent suffix lengths as a part of trie_rebalance
-	 */
-	while (tn->slen < l->slen) {
-		tn->slen = l->slen;
-		tn = node_parent(tn);
+	while ((tp->slen > tp->pos) && (tp->slen > l->slen)) {
+		if (update_suffix(tp) > l->slen)
+			break;
+		tp = node_parent(tp);
 	}
 }
 
@@ -1107,7 +1122,7 @@ static int fib_insert_alias(struct trie *t, struct key_vector *tp,
 	/* if we added to the tail node then we need to update slen */
 	if (l->slen < new->fa_slen) {
 		l->slen = new->fa_slen;
-		leaf_push_suffix(tp, l);
+		node_push_suffix(tp, l);
 	}
 
 	return 0;
@@ -1495,12 +1510,15 @@ static void fib_remove_alias(struct trie *t, struct key_vector *tp,
 	/* remove the fib_alias from the list */
 	hlist_del_rcu(&old->fa_list);
 
-	/* if we emptied the list this leaf will be freed and we can sort
-	 * out parent suffix lengths as a part of trie_rebalance
-	 */
+	/* if we emptied the list this leaf will be freed */
 	if (hlist_empty(&l->leaf)) {
 		put_child_root(tp, l->key, NULL);
 		node_free(l);
+		/* only need to update suffixes if this alias was
+		 * possibly the one with the largest suffix in the parent
+		 */
+		if (tp->slen == old->fa_slen)
+			node_pull_suffix(tp);
 		trie_rebalance(t, tp);
 		return;
 	}
@@ -1783,6 +1801,16 @@ void fib_table_flush_external(struct fib_table *tb)
 			if (IS_TRIE(pn))
 				break;
 
+			/* push the suffix length to the parent node,
+			 * since a previous leaf removal may have
+			 * caused it to change
+			 */
+			if (pn->slen > pn->pos) {
+				unsigned char slen = update_suffix(pn);
+
+				node_set_suffix(node_parent(pn), slen);
+			}
+
 			/* resize completed node */
 			pn = resize(t, pn);
 			cindex = get_index(pkey, pn);
@@ -1849,6 +1877,16 @@ int fib_table_flush(struct net *net, struct fib_table *tb)
 			if (IS_TRIE(pn))
 				break;
 
+			/* push the suffix length to the parent node,
+			 * since a previous leaf removal may have
+			 * caused it to change
+			 */
+			if (pn->slen > pn->pos) {
+				unsigned char slen = update_suffix(pn);
+
+				node_set_suffix(node_parent(pn), slen);
+			}
+
 			/* resize completed node */
 			pn = resize(t, pn);
 			cindex = get_index(pkey, pn);
-- 
2.1.4
