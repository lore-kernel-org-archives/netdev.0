From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 14/17] fib_trie: Push tnode flushing down to
 inflate/halve
Date: Mon, 22 Dec 2014 09:42:20 -0800
Message-ID: <20141222174220.1119.91062.stgit@ahduyck-vm-fedora20>
References: <20141222172632.1119.51469.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39864 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755149AbaLVRmW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Dec 2014 12:42:22 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sBMHgLs0013498
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 12:42:21 -0500
Received: from [192.168.122.173] (ovpn-112-82.phx2.redhat.com [10.3.112.82])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sBMHgKGW021891
	for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 12:42:20 -0500
In-Reply-To: <20141222172632.1119.51469.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change pushes the tnode freeing down into the inflate and halve
functions.  It makes more sense here as we have a better grasp of what is
going on and when a given cluster of nodes is ready to be freed.

I believe this may address a bug in the freeing logic as well.  For some
reason if the freelist got to a certain size we would call
synchronize_rcu().  I'm assuming that what they meant to do is call
synchronize_rcu() after they had handed off that much memory via
call_rcu().  As such that is what I have updated the behavior to be.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |  103 +++++++++++++++++++++++++--------------------------
 1 file changed, 50 insertions(+), 53 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 352ecf4..a41abf8 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -147,8 +147,6 @@ struct trie {
 };
 
 static void resize(struct trie *t, struct tnode *tn);
-/* tnodes to free after resize(); protected by RTNL */
-static struct callback_head *tnode_free_head;
 static size_t tnode_free_size;
 
 /*
@@ -307,32 +305,6 @@ static struct tnode *tnode_alloc(size_t size)
 		return vzalloc(size);
 }
 
-static void tnode_free_safe(struct tnode *tn)
-{
-	BUG_ON(IS_LEAF(tn));
-	tn->rcu.next = tnode_free_head;
-	tnode_free_head = &tn->rcu;
-}
-
-static void tnode_free_flush(void)
-{
-	struct callback_head *head;
-
-	while ((head = tnode_free_head)) {
-		struct tnode *tn = container_of(head, struct tnode, rcu);
-
-		tnode_free_head = head->next;
-		tnode_free_size += offsetof(struct tnode, child[1 << tn->bits]);
-
-		node_free(tn);
-	}
-
-	if (tnode_free_size >= PAGE_SIZE * sync_pages) {
-		tnode_free_size = 0;
-		synchronize_rcu();
-	}
-}
-
 static struct tnode *leaf_new(t_key key)
 {
 	struct tnode *l = kmem_cache_alloc(trie_leaf_kmem, GFP_KERNEL);
@@ -433,17 +405,33 @@ static void put_child_root(struct tnode *tp, struct trie *t,
 		rcu_assign_pointer(t->trie, n);
 }
 
-static void tnode_clean_free(struct tnode *tn)
+static inline void tnode_free_init(struct tnode *tn)
 {
-	struct tnode *tofree;
-	unsigned long i;
+	tn->rcu.next = NULL;
+}
+
+static inline void tnode_free_append(struct tnode *tn, struct tnode *n)
+{
+	n->rcu.next = tn->rcu.next;
+	tn->rcu.next = &n->rcu;
+}
 
-	for (i = 0; i < tnode_child_length(tn); i++) {
-		tofree = tnode_get_child(tn, i);
-		if (tofree)
-			node_free(tofree);
+static void tnode_free(struct tnode *tn)
+{
+	struct callback_head *head = &tn->rcu;
+
+	while (head) {
+		head = head->next;
+		tnode_free_size += offsetof(struct tnode, child[1 << tn->bits]);
+		node_free(tn);
+
+		tn = container_of(head, struct tnode, rcu);
+	}
+
+	if (tnode_free_size >= PAGE_SIZE * sync_pages) {
+		tnode_free_size = 0;
+		synchronize_rcu();
 	}
-	node_free(tn);
 }
 
 static int inflate(struct trie *t, struct tnode *oldtnode)
@@ -476,20 +464,23 @@ static int inflate(struct trie *t, struct tnode *oldtnode)
 					 inode->bits - 1);
 			if (!left)
 				goto nomem;
+			tnode_free_append(tn, left);
 
 			right = tnode_new(inode->key | m, inode->pos,
 					  inode->bits - 1);
 
-			if (!right) {
-				node_free(left);
+			if (!right)
 				goto nomem;
-			}
+			tnode_free_append(tn, right);
 
 			put_child(tn, 2*i, left);
 			put_child(tn, 2*i+1, right);
 		}
 	}
 
+	/* prepare oldtnode to be freed */
+	tnode_free_init(oldtnode);
+
 	for (i = 0; i < olen; i++) {
 		struct tnode *inode = tnode_get_child(oldtnode, i);
 		struct tnode *left, *right;
@@ -505,12 +496,13 @@ static int inflate(struct trie *t, struct tnode *oldtnode)
 			continue;
 		}
 
+		/* drop the node in the old tnode free list */
+		tnode_free_append(oldtnode, inode);
+
 		/* An internal node with two children */
 		if (inode->bits == 1) {
 			put_child(tn, 2*i, rtnl_dereference(inode->child[0]));
 			put_child(tn, 2*i+1, rtnl_dereference(inode->child[1]));
-
-			tnode_free_safe(inode);
 			continue;
 		}
 
@@ -556,17 +548,19 @@ static int inflate(struct trie *t, struct tnode *oldtnode)
 		put_child(tn, 2 * i, left);
 		put_child(tn, 2 * i + 1, right);
 
-		tnode_free_safe(inode);
-
+		/* resize child nodes */
 		resize(t, left);
 		resize(t, right);
 	}
 
 	put_child_root(tp, t, tn->key, tn);
-	tnode_free_safe(oldtnode);
+
+	/* we completed without error, prepare to free old node */
+	tnode_free(oldtnode);
 	return 0;
 nomem:
-	tnode_clean_free(tn);
+	/* all pointers should be clean so we are done */
+	tnode_free(tn);
 	return -ENOMEM;
 }
 
@@ -599,17 +593,20 @@ static int halve(struct trie *t, struct tnode *oldtnode)
 			struct tnode *newn;
 
 			newn = tnode_new(left->key, oldtnode->pos, 1);
-
 			if (!newn) {
-				tnode_clean_free(tn);
+				tnode_free(tn);
 				return -ENOMEM;
 			}
+			tnode_free_append(tn, newn);
 
 			put_child(tn, i/2, newn);
 		}
 
 	}
 
+	/* prepare oldtnode to be freed */
+	tnode_free_init(oldtnode);
+
 	for (i = 0; i < olen; i += 2) {
 		struct tnode *newBinNode;
 
@@ -636,11 +633,14 @@ static int halve(struct trie *t, struct tnode *oldtnode)
 
 		put_child(tn, i / 2, newBinNode);
 
+		/* resize child node */
 		resize(t, newBinNode);
 	}
 
 	put_child_root(tp, t, tn->key, tn);
-	tnode_free_safe(oldtnode);
+
+	/* all pointers should be clean so we are done */
+	tnode_free(oldtnode);
 
 	return 0;
 }
@@ -798,7 +798,8 @@ no_children:
 		node_set_parent(n, tp);
 
 		/* drop dead node */
-		tnode_free_safe(tn);
+		tnode_free_init(tn);
+		tnode_free(tn);
 	}
 }
 
@@ -884,16 +885,12 @@ static void trie_rebalance(struct trie *t, struct tnode *tn)
 
 	while ((tp = node_parent(tn)) != NULL) {
 		resize(t, tn);
-
-		tnode_free_flush();
 		tn = tp;
 	}
 
 	/* Handle last (top) tnode */
 	if (IS_TNODE(tn))
 		resize(t, tn);
-
-	tnode_free_flush();
 }
 
 /* only used from updater-side */
