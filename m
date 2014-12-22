From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 13/17] fib_trie: Push assignment of child to parent down
 into inflate/halve
Date: Mon, 22 Dec 2014 09:42:14 -0800
Message-ID: <20141222174214.1119.95969.stgit@ahduyck-vm-fedora20>
References: <20141222172632.1119.51469.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45327 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755149AbaLVRmQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Dec 2014 12:42:16 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sBMHgFlo023938
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 12:42:15 -0500
Received: from [192.168.122.173] (ovpn-112-82.phx2.redhat.com [10.3.112.82])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sBMHgE9K001544
	for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 12:42:14 -0500
In-Reply-To: <20141222172632.1119.51469.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change makes it so that the assignment of the tnode to the parent is
handled directly within whatever function is currently handling the node be
it inflate, halve, or resize.  By doing this we can avoid some of the need
to set NULL pointers in the tree while we are resizing the subnodes.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |  149 +++++++++++++++++++++++----------------------------
 1 file changed, 66 insertions(+), 83 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 7ef101c..352ecf4 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -146,9 +146,7 @@ struct trie {
 #endif
 };
 
-static void tnode_put_child_reorg(struct tnode *tn, unsigned long i,
-				  struct tnode *n, int wasfull);
-static struct tnode *resize(struct trie *t, struct tnode *tn);
+static void resize(struct trie *t, struct tnode *tn);
 /* tnodes to free after resize(); protected by RTNL */
 static struct callback_head *tnode_free_head;
 static size_t tnode_free_size;
@@ -396,22 +394,13 @@ static inline int tnode_full(const struct tnode *tn, const struct tnode *n)
 	return n && ((n->pos + n->bits) == tn->pos) && IS_TNODE(n);
 }
 
-static inline void put_child(struct tnode *tn, unsigned long i,
-			     struct tnode *n)
-{
-	tnode_put_child_reorg(tn, i, n, -1);
-}
-
- /*
-  * Add a child at position i overwriting the old value.
-  * Update the value of full_children and empty_children.
-  */
-
-static void tnode_put_child_reorg(struct tnode *tn, unsigned long i,
-				  struct tnode *n, int wasfull)
+/* Add a child at position i overwriting the old value.
+ * Update the value of full_children and empty_children.
+ */
+static void put_child(struct tnode *tn, unsigned long i, struct tnode *n)
 {
 	struct tnode *chi = rtnl_dereference(tn->child[i]);
-	int isfull;
+	int isfull, wasfull;
 
 	BUG_ON(i >= tnode_child_length(tn));
 
@@ -422,10 +411,9 @@ static void tnode_put_child_reorg(struct tnode *tn, unsigned long i,
 		tn->empty_children--;
 
 	/* update fullChildren */
-	if (wasfull == -1)
-		wasfull = tnode_full(tn, chi);
-
+	wasfull = tnode_full(tn, chi);
 	isfull = tnode_full(tn, n);
+
 	if (wasfull && !isfull)
 		tn->full_children--;
 	else if (!wasfull && isfull)
@@ -458,9 +446,10 @@ static void tnode_clean_free(struct tnode *tn)
 	node_free(tn);
 }
 
-static struct tnode *inflate(struct trie *t, struct tnode *oldtnode)
+static int inflate(struct trie *t, struct tnode *oldtnode)
 {
 	unsigned long olen = tnode_child_length(oldtnode);
+	struct tnode *tp = node_parent(oldtnode);
 	struct tnode *tn;
 	unsigned long i;
 	t_key m;
@@ -468,9 +457,8 @@ static struct tnode *inflate(struct trie *t, struct tnode *oldtnode)
 	pr_debug("In inflate\n");
 
 	tn = tnode_new(oldtnode->key, oldtnode->pos - 1, oldtnode->bits + 1);
-
 	if (!tn)
-		return ERR_PTR(-ENOMEM);
+		return -ENOMEM;
 
 	/*
 	 * Preallocate and store tnodes before the actual work so we
@@ -564,30 +552,36 @@ static struct tnode *inflate(struct trie *t, struct tnode *oldtnode)
 			put_child(left, j, rtnl_dereference(inode->child[j]));
 			put_child(right, j, rtnl_dereference(inode->child[j + size]));
 		}
-		put_child(tn, 2*i, resize(t, left));
-		put_child(tn, 2*i+1, resize(t, right));
+
+		put_child(tn, 2 * i, left);
+		put_child(tn, 2 * i + 1, right);
 
 		tnode_free_safe(inode);
+
+		resize(t, left);
+		resize(t, right);
 	}
+
+	put_child_root(tp, t, tn->key, tn);
 	tnode_free_safe(oldtnode);
-	return tn;
+	return 0;
 nomem:
 	tnode_clean_free(tn);
-	return ERR_PTR(-ENOMEM);
+	return -ENOMEM;
 }
 
-static struct tnode *halve(struct trie *t, struct tnode *oldtnode)
+static int halve(struct trie *t, struct tnode *oldtnode)
 {
 	unsigned long olen = tnode_child_length(oldtnode);
+	struct tnode *tp = node_parent(oldtnode);
 	struct tnode *tn, *left, *right;
 	int i;
 
 	pr_debug("In halve\n");
 
 	tn = tnode_new(oldtnode->key, oldtnode->pos + 1, oldtnode->bits - 1);
-
 	if (!tn)
-		return ERR_PTR(-ENOMEM);
+		return -ENOMEM;
 
 	/*
 	 * Preallocate and store tnodes before the actual work so we
@@ -606,8 +600,10 @@ static struct tnode *halve(struct trie *t, struct tnode *oldtnode)
 
 			newn = tnode_new(left->key, oldtnode->pos, 1);
 
-			if (!newn)
-				goto nomem;
+			if (!newn) {
+				tnode_clean_free(tn);
+				return -ENOMEM;
+			}
 
 			put_child(tn, i/2, newn);
 		}
@@ -635,16 +631,18 @@ static struct tnode *halve(struct trie *t, struct tnode *oldtnode)
 
 		/* Two nonempty children */
 		newBinNode = tnode_get_child(tn, i/2);
-		put_child(tn, i/2, NULL);
 		put_child(newBinNode, 0, left);
 		put_child(newBinNode, 1, right);
-		put_child(tn, i/2, resize(t, newBinNode));
+
+		put_child(tn, i / 2, newBinNode);
+
+		resize(t, newBinNode);
 	}
+
+	put_child_root(tp, t, tn->key, tn);
 	tnode_free_safe(oldtnode);
-	return tn;
-nomem:
-	tnode_clean_free(tn);
-	return ERR_PTR(-ENOMEM);
+
+	return 0;
 }
 
 /* From "Implementing a dynamic compressed trie" by Stefan Nilsson of
@@ -704,45 +702,48 @@ nomem:
  *    tnode_child_length(tn)
  *
  */
-static bool should_inflate(const struct tnode *tn)
+static bool should_inflate(const struct tnode *tp, const struct tnode *tn)
 {
 	unsigned long used = tnode_child_length(tn);
 	unsigned long threshold = used;
 
 	/* Keep root node larger */
-	threshold *= node_parent(tn) ? inflate_threshold :
-				       inflate_threshold_root;
+	threshold *= tp ? inflate_threshold : inflate_threshold_root;
 	used += tn->full_children;
 	used -= tn->empty_children;
 
 	return tn->pos && ((50 * used) >= threshold);
 }
 
-static bool should_halve(const struct tnode *tn)
+static bool should_halve(const struct tnode *tp, const struct tnode *tn)
 {
 	unsigned long used = tnode_child_length(tn);
 	unsigned long threshold = used;
 
 	/* Keep root node larger */
-	threshold *= node_parent(tn) ? halve_threshold :
-				       halve_threshold_root;
+	threshold *= tp ? halve_threshold : halve_threshold_root;
 	used -= tn->empty_children;
 
 	return (tn->bits > 1) && ((100 * used) < threshold);
 }
 
 #define MAX_WORK 10
-static struct tnode *resize(struct trie *t, struct tnode *tn)
+static void resize(struct trie *t, struct tnode *tn)
 {
-	struct tnode *old_tn, *n = NULL;
+	struct tnode *tp = node_parent(tn), *n = NULL;
+	struct tnode __rcu **cptr;
 	int max_work;
 
-	if (!tn)
-		return NULL;
-
 	pr_debug("In tnode_resize %p inflate_threshold=%d threshold=%d\n",
 		 tn, inflate_threshold, halve_threshold);
 
+	/* track the tnode via the pointer from the parent instead of
+	 * doing it ourselves.  This way we can let RCU fully do its
+	 * thing without us interfering
+	 */
+	cptr = tp ? &tp->child[get_index(tn->key, tp)] : &t->trie;
+	BUG_ON(tn != rtnl_dereference(*cptr));
+
 	/* No children */
 	if (tn->empty_children > (tnode_child_length(tn) - 1))
 		goto no_children;
@@ -755,39 +756,35 @@ static struct tnode *resize(struct trie *t, struct tnode *tn)
 	 * nonempty nodes that are above the threshold.
 	 */
 	max_work = MAX_WORK;
-	while (should_inflate(tn) && max_work--) {
-		old_tn = tn;
-		tn = inflate(t, tn);
-
-		if (IS_ERR(tn)) {
-			tn = old_tn;
+	while (should_inflate(tp, tn) && max_work--) {
+		if (inflate(t, tn)) {
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 			this_cpu_inc(t->stats->resize_node_skipped);
 #endif
 			break;
 		}
+
+		tn = rtnl_dereference(*cptr);
 	}
 
 	/* Return if at least one inflate is run */
 	if (max_work != MAX_WORK)
-		return tn;
+		return;
 
 	/* Halve as long as the number of empty children in this
 	 * node is above threshold.
 	 */
 	max_work = MAX_WORK;
-	while (should_halve(tn) && max_work--) {
-		old_tn = tn;
-		tn = halve(t, tn);
-		if (IS_ERR(tn)) {
-			tn = old_tn;
+	while (should_halve(tp, tn) && max_work--) {
+		if (halve(t, tn)) {
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 			this_cpu_inc(t->stats->resize_node_skipped);
 #endif
 			break;
 		}
-	}
 
+		tn = rtnl_dereference(*cptr);
+	}
 
 	/* Only one child remains */
 	if (tn->empty_children == (tnode_child_length(tn) - 1)) {
@@ -797,11 +794,12 @@ one_child:
 			n = tnode_get_child(tn, --i);
 no_children:
 		/* compress one level */
-		node_set_parent(n, NULL);
+		put_child_root(tp, t, tn->key, n);
+		node_set_parent(n, tp);
+
+		/* drop dead node */
 		tnode_free_safe(tn);
-		return n;
 	}
-	return tn;
 }
 
 /* readside must use rcu_read_lock currently dump routines
@@ -882,34 +880,19 @@ static struct tnode *fib_find_node(struct trie *t, u32 key)
 
 static void trie_rebalance(struct trie *t, struct tnode *tn)
 {
-	int wasfull;
-	t_key cindex, key;
 	struct tnode *tp;
 
-	key = tn->key;
-
-	while (tn != NULL && (tp = node_parent(tn)) != NULL) {
-		cindex = get_index(key, tp);
-		wasfull = tnode_full(tp, tnode_get_child(tp, cindex));
-		tn = resize(t, tn);
-
-		tnode_put_child_reorg(tp, cindex, tn, wasfull);
-
-		tp = node_parent(tn);
-		if (!tp)
-			rcu_assign_pointer(t->trie, tn);
+	while ((tp = node_parent(tn)) != NULL) {
+		resize(t, tn);
 
 		tnode_free_flush();
-		if (!tp)
-			break;
 		tn = tp;
 	}
 
 	/* Handle last (top) tnode */
 	if (IS_TNODE(tn))
-		tn = resize(t, tn);
+		resize(t, tn);
 
-	rcu_assign_pointer(t->trie, tn);
 	tnode_free_flush();
 }
 
