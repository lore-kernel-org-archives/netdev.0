From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next v2] bpf: Optimize lpm trie delete
Date: Thu, 21 Sep 2017 18:43:29 -0400
Message-ID: <20170921224329.101928-1-kraigatgoog@gmail.com>
Cc: netdev@vger.kernel.org
To: Daniel Mack <daniel@zonque.org>, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:53280 "EHLO
        mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751728AbdIUWnc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 18:43:32 -0400
Received: by mail-qk0-f173.google.com with SMTP id t184so7225598qke.10
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 15:43:32 -0700 (PDT)
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
v2:
  I really failed the interview on this one.  v1 did not collapse all
  extra intermediate node possibilities.  I believe this one does by
	additionally tracking node parent information.  See comments.

 kernel/bpf/lpm_trie.c | 71 +++++++++++++++++++++++++++++++--------------------
 1 file changed, 43 insertions(+), 28 deletions(-)

diff --git a/kernel/bpf/lpm_trie.c b/kernel/bpf/lpm_trie.c
index 9d58a576b2ae..34d8a690ea05 100644
--- a/kernel/bpf/lpm_trie.c
+++ b/kernel/bpf/lpm_trie.c
@@ -394,8 +394,8 @@ static int trie_delete_elem(struct bpf_map *map, void *_key)
 {
 	struct lpm_trie *trie = container_of(map, struct lpm_trie, map);
 	struct bpf_lpm_trie_key *key = _key;
-	struct lpm_trie_node __rcu **trim;
-	struct lpm_trie_node *node;
+	struct lpm_trie_node __rcu **trim, **trim2;
+	struct lpm_trie_node *node, *parent;
 	unsigned long irq_flags;
 	unsigned int next_bit;
 	size_t matchlen = 0;
@@ -407,31 +407,26 @@ static int trie_delete_elem(struct bpf_map *map, void *_key)
 	raw_spin_lock_irqsave(&trie->lock, irq_flags);
 
 	/* Walk the tree looking for an exact key/length match and keeping
-	 * track of where we could begin trimming the tree.  The trim-point
-	 * is the sub-tree along the walk consisting of only single-child
-	 * intermediate nodes and ending at a leaf node that we want to
-	 * remove.
+	 * track of the path we traverse.  We will need to know the node
+	 * we wish to delete, and the slot that points to the node we want
+	 * to delete.  We may also need to know the nodes parent and the
+	 * slot that contains it.
 	 */
 	trim = &trie->root;
-	node = rcu_dereference_protected(
-		trie->root, lockdep_is_held(&trie->lock));
-	while (node) {
+	trim2 = trim;
+	parent = NULL;
+	while ((node = rcu_dereference_protected(
+		       *trim, lockdep_is_held(&trie->lock)))) {
 		matchlen = longest_prefix_match(trie, node, key);
 
 		if (node->prefixlen != matchlen ||
 		    node->prefixlen == key->prefixlen)
 			break;
 
+		parent = node;
+		trim2 = trim;
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
@@ -442,27 +437,47 @@ static int trie_delete_elem(struct bpf_map *map, void *_key)
 
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
+	/* If the parent of the node we are about to delete is an intermediate
+	 * node, and the deleted node doesn't have any children, we can delete
+	 * the intermediate parent as well and promote its other child
+	 * up the tree.  Doing this maintains the invariant that all
+	 * intermediate nodes have exactly 2 children and that there are no
+	 * unnecessary intermediate nodes in the tree.
 	 */
-	while ((node = rcu_dereference_protected(
-			*trim, lockdep_is_held(&trie->lock)))) {
-		RCU_INIT_POINTER(*trim, NULL);
-		trim = rcu_access_pointer(node->child[0]) ?
-			&node->child[0] :
-			&node->child[1];
+	if (parent && (parent->flags & LPM_TREE_NODE_FLAG_IM) &&
+	    !node->child[0] && !node->child[1]) {
+		if (node == rcu_access_pointer(parent->child[0]))
+			rcu_assign_pointer(
+				*trim2, rcu_access_pointer(parent->child[1]));
+		else
+			rcu_assign_pointer(
+				*trim2, rcu_access_pointer(parent->child[0]));
+		kfree_rcu(parent, rcu);
 		kfree_rcu(node, rcu);
+		goto out;
 	}
 
+	/* The node we are removing has either zero or one child. If there
+	 * is a child, move it into the removed node's slot then delete
+	 * the node.  Otherwise just clear the slot and delete the node.
+	 */
+	if (node->child[0])
+		rcu_assign_pointer(*trim, rcu_access_pointer(node->child[0]));
+	else if (node->child[1])
+		rcu_assign_pointer(*trim, rcu_access_pointer(node->child[1]));
+	else
+		RCU_INIT_POINTER(*trim, NULL);
+	kfree_rcu(node, rcu);
+
 out:
 	raw_spin_unlock_irqrestore(&trie->lock, irq_flags);
 
-- 
2.14.1.821.g8fa685d3b7-goog
