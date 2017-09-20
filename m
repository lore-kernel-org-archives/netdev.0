From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next] bpf: Optimize lpm trie delete
Date: Wed, 20 Sep 2017 12:22:47 -0400
Message-ID: <20170920162247.63787-1-kraigatgoog@gmail.com>
Cc: netdev@vger.kernel.org
To: Daniel Mack <daniel@zonque.org>, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f171.google.com ([209.85.216.171]:44163 "EHLO
        mail-qt0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751499AbdITQWu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 12:22:50 -0400
Received: by mail-qt0-f171.google.com with SMTP id o13so3350238qtf.1
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 09:22:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

Before the delete operator was added, this datastructure maintained
an invariant that intermediate nodes were only present when necessary
to build the tree.  This patch updates the delete operation to reinstate
that invariant by removing unnecessary intermediate nodes after a node is
removed and thus keeping the tree structure at a minimal size.

Suggested-by: Daniel Mack <daniel@zonque.org>
Signed-off-by: Craig Gallek <kraig@google.com>
---
 kernel/bpf/lpm_trie.c | 55 +++++++++++++++++++++++++++------------------------
 1 file changed, 29 insertions(+), 26 deletions(-)

diff --git a/kernel/bpf/lpm_trie.c b/kernel/bpf/lpm_trie.c
index 9d58a576b2ae..b5a7d70ec8b5 100644
--- a/kernel/bpf/lpm_trie.c
+++ b/kernel/bpf/lpm_trie.c
@@ -397,7 +397,7 @@ static int trie_delete_elem(struct bpf_map *map, void *_key)
 	struct lpm_trie_node __rcu **trim;
 	struct lpm_trie_node *node;
 	unsigned long irq_flags;
-	unsigned int next_bit;
+	unsigned int next_bit = 0;
 	size_t matchlen = 0;
 	int ret = 0;
 
@@ -408,14 +408,12 @@ static int trie_delete_elem(struct bpf_map *map, void *_key)
 
 	/* Walk the tree looking for an exact key/length match and keeping
 	 * track of where we could begin trimming the tree.  The trim-point
-	 * is the sub-tree along the walk consisting of only single-child
-	 * intermediate nodes and ending at a leaf node that we want to
-	 * remove.
+	 * is the location of the pointer where we will remove a node from the
+	 * tree.
 	 */
 	trim = &trie->root;
-	node = rcu_dereference_protected(
-		trie->root, lockdep_is_held(&trie->lock));
-	while (node) {
+	while ((node = rcu_dereference_protected(
+		       *trim, lockdep_is_held(&trie->lock)))) {
 		matchlen = longest_prefix_match(trie, node, key);
 
 		if (node->prefixlen != matchlen ||
@@ -423,15 +421,7 @@ static int trie_delete_elem(struct bpf_map *map, void *_key)
 			break;
 
 		next_bit = extract_bit(key->data, node->prefixlen);
-		/* If we hit a node that has more than one child or is a valid
-		 * prefix itself, do not remove it. Reset the root of the trim
-		 * path to its descendant on our path.
-		 */
-		if (!(node->flags & LPM_TREE_NODE_FLAG_IM) ||
-		    (node->child[0] && node->child[1]))
-			trim = &node->child[next_bit];
-		node = rcu_dereference_protected(
-			node->child[next_bit], lockdep_is_held(&trie->lock));
+		trim = &node->child[next_bit];
 	}
 
 	if (!node || node->prefixlen != key->prefixlen ||
@@ -442,25 +432,38 @@ static int trie_delete_elem(struct bpf_map *map, void *_key)
 
 	trie->n_entries--;
 
-	/* If the node we are removing is not a leaf node, simply mark it
+	/* If the node we are removing has two children, simply mark it
 	 * as intermediate and we are done.
 	 */
-	if (rcu_access_pointer(node->child[0]) ||
+	if (rcu_access_pointer(node->child[0]) &&
 	    rcu_access_pointer(node->child[1])) {
 		node->flags |= LPM_TREE_NODE_FLAG_IM;
 		goto out;
 	}
 
-	/* trim should now point to the slot holding the start of a path from
-	 * zero or more intermediate nodes to our leaf node for deletion.
-	 */
-	while ((node = rcu_dereference_protected(
-			*trim, lockdep_is_held(&trie->lock)))) {
+	/* If the node has no children, it can be completely removed */
+	if (!rcu_access_pointer(node->child[0]) &&
+	    !rcu_access_pointer(node->child[1])) {
 		RCU_INIT_POINTER(*trim, NULL);
-		trim = rcu_access_pointer(node->child[0]) ?
-			&node->child[0] :
-			&node->child[1];
 		kfree_rcu(node, rcu);
+		goto out;
+	}
+
+	/* If the node has one child, we may be able to collapse the tree
+	 * while removing this node if the node's child is in the same
+	 * 'next bit' slot as this node was in its parent or if the node
+	 * itself is the root.
+	 */
+	if (trim == &trie->root) {
+		next_bit = node->child[0] ? 0 : 1;
+		rcu_assign_pointer(trie->root, node->child[next_bit]);
+		kfree_rcu(node, rcu);
+	} else if (rcu_access_pointer(node->child[next_bit])) {
+		rcu_assign_pointer(*trim, node->child[next_bit]);
+		kfree_rcu(node, rcu);
+	} else {
+		/* If we can't collapse, just mark this node as intermediate */
+		node->flags |= LPM_TREE_NODE_FLAG_IM;
 	}
 
 out:
-- 
2.14.1.821.g8fa685d3b7-goog
