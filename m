From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 21/24] Introduce rb_replace_node_rcu()
Date: Tue, 05 Jul 2016 14:14:41 +0100
Message-ID: <146772448187.21657.2344729324665773888.stgit@warthog.procyon.org.uk>
References: <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Peter Zijlstra \(Intel\)" <peterz@infradead.org>,
	dhowells@redhat.com, linux-afs@lists.infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46301 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755284AbcGENOo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2016 09:14:44 -0400
In-Reply-To: <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement an RCU-safe variant of rb_replace_node() and rearrange
rb_replace_node() to do things in the same order.

Signed-off-by: David Howells <dhowells@redhat.com>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---

 include/linux/rbtree.h           |    2 ++
 include/linux/rbtree_augmented.h |   13 +++++++++++++
 lib/rbtree.c                     |   26 ++++++++++++++++++++++++--
 3 files changed, 39 insertions(+), 2 deletions(-)

diff --git a/include/linux/rbtree.h b/include/linux/rbtree.h
index b6900099ea81..e585018498d5 100644
--- a/include/linux/rbtree.h
+++ b/include/linux/rbtree.h
@@ -76,6 +76,8 @@ extern struct rb_node *rb_next_postorder(const struct rb_node *);
 /* Fast replacement of a single node without remove/rebalance/add/rebalance */
 extern void rb_replace_node(struct rb_node *victim, struct rb_node *new,
 			    struct rb_root *root);
+extern void rb_replace_node_rcu(struct rb_node *victim, struct rb_node *new,
+				struct rb_root *root);
 
 static inline void rb_link_node(struct rb_node *node, struct rb_node *parent,
 				struct rb_node **rb_link)
diff --git a/include/linux/rbtree_augmented.h b/include/linux/rbtree_augmented.h
index 14d7b831b63a..d076183e49be 100644
--- a/include/linux/rbtree_augmented.h
+++ b/include/linux/rbtree_augmented.h
@@ -130,6 +130,19 @@ __rb_change_child(struct rb_node *old, struct rb_node *new,
 		WRITE_ONCE(root->rb_node, new);
 }
 
+static inline void
+__rb_change_child_rcu(struct rb_node *old, struct rb_node *new,
+		      struct rb_node *parent, struct rb_root *root)
+{
+	if (parent) {
+		if (parent->rb_left == old)
+			rcu_assign_pointer(parent->rb_left, new);
+		else
+			rcu_assign_pointer(parent->rb_right, new);
+	} else
+		rcu_assign_pointer(root->rb_node, new);
+}
+
 extern void __rb_erase_color(struct rb_node *parent, struct rb_root *root,
 	void (*augment_rotate)(struct rb_node *old, struct rb_node *new));
 
diff --git a/lib/rbtree.c b/lib/rbtree.c
index 1356454e36de..eb8a19fee110 100644
--- a/lib/rbtree.c
+++ b/lib/rbtree.c
@@ -539,17 +539,39 @@ void rb_replace_node(struct rb_node *victim, struct rb_node *new,
 {
 	struct rb_node *parent = rb_parent(victim);
 
+	/* Copy the pointers/colour from the victim to the replacement */
+	*new = *victim;
+
 	/* Set the surrounding nodes to point to the replacement */
-	__rb_change_child(victim, new, parent, root);
 	if (victim->rb_left)
 		rb_set_parent(victim->rb_left, new);
 	if (victim->rb_right)
 		rb_set_parent(victim->rb_right, new);
+	__rb_change_child(victim, new, parent, root);
+}
+EXPORT_SYMBOL(rb_replace_node);
+
+void rb_replace_node_rcu(struct rb_node *victim, struct rb_node *new,
+			 struct rb_root *root)
+{
+	struct rb_node *parent = rb_parent(victim);
 
 	/* Copy the pointers/colour from the victim to the replacement */
 	*new = *victim;
+
+	/* Set the surrounding nodes to point to the replacement */
+	if (victim->rb_left)
+		rb_set_parent(victim->rb_left, new);
+	if (victim->rb_right)
+		rb_set_parent(victim->rb_right, new);
+
+	/* Set the parent's pointer to the new node last after an RCU barrier
+	 * so that the pointers onwards are seen to be set correctly when doing
+	 * an RCU walk over the tree.
+	 */
+	__rb_change_child_rcu(victim, new, parent, root);
 }
-EXPORT_SYMBOL(rb_replace_node);
+EXPORT_SYMBOL(rb_replace_node_rcu);
 
 static struct rb_node *rb_left_deepest_node(const struct rb_node *node)
 {
