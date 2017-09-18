From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next 1/3] bpf: Implement map_delete_elem for BPF_MAP_TYPE_LPM_TRIE
Date: Mon, 18 Sep 2017 15:30:55 -0400
Message-ID: <20170918193057.37644-2-kraigatgoog@gmail.com>
References: <20170918193057.37644-1-kraigatgoog@gmail.com>
Cc: netdev@vger.kernel.org
To: Daniel Mack <daniel@zonque.org>, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f181.google.com ([209.85.216.181]:50936 "EHLO
        mail-qt0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750938AbdIRTbA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 15:31:00 -0400
Received: by mail-qt0-f181.google.com with SMTP id f15so1660886qtf.7
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 12:31:00 -0700 (PDT)
In-Reply-To: <20170918193057.37644-1-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

This is a simple non-recursive delete operation.  It prunes paths
of empty nodes in the tree, but it does not try to further compress
the tree as nodes are removed.

Signed-off-by: Craig Gallek <kraig@google.com>
---
 kernel/bpf/lpm_trie.c | 80 +++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 77 insertions(+), 3 deletions(-)

diff --git a/kernel/bpf/lpm_trie.c b/kernel/bpf/lpm_trie.c
index 1b767844a76f..9d58a576b2ae 100644
--- a/kernel/bpf/lpm_trie.c
+++ b/kernel/bpf/lpm_trie.c
@@ -389,10 +389,84 @@ static int trie_update_elem(struct bpf_map *map,
 	return ret;
 }
 
-static int trie_delete_elem(struct bpf_map *map, void *key)
+/* Called from syscall or from eBPF program */
+static int trie_delete_elem(struct bpf_map *map, void *_key)
 {
-	/* TODO */
-	return -ENOSYS;
+	struct lpm_trie *trie = container_of(map, struct lpm_trie, map);
+	struct bpf_lpm_trie_key *key = _key;
+	struct lpm_trie_node __rcu **trim;
+	struct lpm_trie_node *node;
+	unsigned long irq_flags;
+	unsigned int next_bit;
+	size_t matchlen = 0;
+	int ret = 0;
+
+	if (key->prefixlen > trie->max_prefixlen)
+		return -EINVAL;
+
+	raw_spin_lock_irqsave(&trie->lock, irq_flags);
+
+	/* Walk the tree looking for an exact key/length match and keeping
+	 * track of where we could begin trimming the tree.  The trim-point
+	 * is the sub-tree along the walk consisting of only single-child
+	 * intermediate nodes and ending at a leaf node that we want to
+	 * remove.
+	 */
+	trim = &trie->root;
+	node = rcu_dereference_protected(
+		trie->root, lockdep_is_held(&trie->lock));
+	while (node) {
+		matchlen = longest_prefix_match(trie, node, key);
+
+		if (node->prefixlen != matchlen ||
+		    node->prefixlen == key->prefixlen)
+			break;
+
+		next_bit = extract_bit(key->data, node->prefixlen);
+		/* If we hit a node that has more than one child or is a valid
+		 * prefix itself, do not remove it. Reset the root of the trim
+		 * path to its descendant on our path.
+		 */
+		if (!(node->flags & LPM_TREE_NODE_FLAG_IM) ||
+		    (node->child[0] && node->child[1]))
+			trim = &node->child[next_bit];
+		node = rcu_dereference_protected(
+			node->child[next_bit], lockdep_is_held(&trie->lock));
+	}
+
+	if (!node || node->prefixlen != key->prefixlen ||
+	    (node->flags & LPM_TREE_NODE_FLAG_IM)) {
+		ret = -ENOENT;
+		goto out;
+	}
+
+	trie->n_entries--;
+
+	/* If the node we are removing is not a leaf node, simply mark it
+	 * as intermediate and we are done.
+	 */
+	if (rcu_access_pointer(node->child[0]) ||
+	    rcu_access_pointer(node->child[1])) {
+		node->flags |= LPM_TREE_NODE_FLAG_IM;
+		goto out;
+	}
+
+	/* trim should now point to the slot holding the start of a path from
+	 * zero or more intermediate nodes to our leaf node for deletion.
+	 */
+	while ((node = rcu_dereference_protected(
+			*trim, lockdep_is_held(&trie->lock)))) {
+		RCU_INIT_POINTER(*trim, NULL);
+		trim = rcu_access_pointer(node->child[0]) ?
+			&node->child[0] :
+			&node->child[1];
+		kfree_rcu(node, rcu);
+	}
+
+out:
+	raw_spin_unlock_irqrestore(&trie->lock, irq_flags);
+
+	return ret;
 }
 
 #define LPM_DATA_SIZE_MAX	256
-- 
2.14.1.690.gbb1197296e-goog
