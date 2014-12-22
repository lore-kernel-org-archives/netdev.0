From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 07/17] fib_trie: Optimize fib_table_insert
Date: Mon, 22 Dec 2014 09:41:36 -0800
Message-ID: <20141222174136.1119.15995.stgit@ahduyck-vm-fedora20>
References: <20141222172632.1119.51469.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41752 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755071AbaLVRli (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Dec 2014 12:41:38 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sBMHfbgA021468
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 12:41:38 -0500
Received: from [192.168.122.173] (ovpn-112-82.phx2.redhat.com [10.3.112.82])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sBMHfa7A014272
	for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 12:41:37 -0500
In-Reply-To: <20141222172632.1119.51469.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the fib_table_insert function to take advantage of the
changes made to improve the performance of fib_table_lookup.  As a result
the code should be smaller and run faster then the original.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |  196 ++++++++++++++++++---------------------------------
 1 file changed, 71 insertions(+), 125 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index c182143..969ecf3 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -222,31 +222,6 @@ static inline t_key tkey_extract_bits(t_key a, unsigned int offset, unsigned int
 		return 0;
 }
 
-static inline int tkey_equals(t_key a, t_key b)
-{
-	return a == b;
-}
-
-static inline int tkey_sub_equals(t_key a, int offset, int bits, t_key b)
-{
-	if (bits == 0 || offset >= KEYLENGTH)
-		return 1;
-	bits = bits > KEYLENGTH ? KEYLENGTH : bits;
-	return ((a ^ b) << offset) >> (KEYLENGTH - bits) == 0;
-}
-
-static inline int tkey_mismatch(t_key a, int offset, t_key b)
-{
-	t_key diff = a ^ b;
-	int i = offset;
-
-	if (!diff)
-		return 0;
-	while ((diff << i) >> (KEYLENGTH-1) == 0)
-		i++;
-	return i;
-}
-
 /*
   To understand this stuff, an understanding of keys and all their bits is
   necessary. Every node in the trie has a key associated with it, but not
@@ -485,6 +460,15 @@ static void tnode_put_child_reorg(struct tnode *tn, int i, struct tnode *n,
 	rcu_assign_pointer(tn->child[i], n);
 }
 
+static void put_child_root(struct tnode *tp, struct trie *t,
+			   t_key key, struct tnode *n)
+{
+	if (tp)
+		put_child(tp, get_index(key, tp), n);
+	else
+		rcu_assign_pointer(t->trie, n);
+}
+
 #define MAX_WORK 10
 static struct tnode *resize(struct trie *t, struct tnode *tn)
 {
@@ -959,138 +943,100 @@ static void trie_rebalance(struct trie *t, struct tnode *tn)
 
 static struct list_head *fib_insert_node(struct trie *t, u32 key, int plen)
 {
-	int pos, newpos;
-	struct tnode *tp = NULL, *tn = NULL;
-	struct tnode *n;
-	struct tnode *l;
-	int missbit;
 	struct list_head *fa_head = NULL;
+	struct tnode *l, *n, *tp = NULL;
 	struct leaf_info *li;
-	t_key cindex;
 
-	pos = 0;
+	li = leaf_info_new(plen);
+	if (!li)
+		return NULL;
+	fa_head = &li->falh;
+
 	n = rtnl_dereference(t->trie);
 
 	/* If we point to NULL, stop. Either the tree is empty and we should
 	 * just put a new leaf in if, or we have reached an empty child slot,
 	 * and we should just put our new leaf in that.
-	 * If we point to a T_TNODE, check if it matches our key. Note that
-	 * a T_TNODE might be skipping any number of bits - its 'pos' need
-	 * not be the parent's 'pos'+'bits'!
-	 *
-	 * If it does match the current key, get pos/bits from it, extract
-	 * the index from our key, push the T_TNODE and walk the tree.
-	 *
-	 * If it doesn't, we have to replace it with a new T_TNODE.
 	 *
-	 * If we point to a T_LEAF, it might or might not have the same key
-	 * as we do. If it does, just change the value, update the T_LEAF's
-	 * value, and return it.
-	 * If it doesn't, we need to replace it with a T_TNODE.
+	 * If we hit a node with a key that does't match then we should stop
+	 * and create a new tnode to replace that node and insert ourselves
+	 * and the other node into the new tnode.
 	 */
+	while (n) {
+		unsigned long index = get_index(key, n);
 
-	while (n && IS_TNODE(n)) {
-		if (tkey_sub_equals(n->key, pos, n->pos-pos, key)) {
-			tp = n;
-			pos = n->pos + n->bits;
-			n = tnode_get_child(n,
-					    tkey_extract_bits(key,
-							      n->pos,
-							      n->bits));
-
-			BUG_ON(n && node_parent(n) != tp);
-		} else
+		/* This bit of code is a bit tricky but it combines multiple
+		 * checks into a single check.  The prefix consists of the
+		 * prefix plus zeros for the "bits" in the prefix. The index
+		 * is the difference between the key and this value.  From
+		 * this we can actually derive several pieces of data.
+		 *   if !(index >> bits)
+		 *     we know the value is child index
+		 *   else
+		 *     we have a mismatch in skip bits and failed
+		 */
+		if (index >> n->bits)
 			break;
-	}
-
-	/*
-	 * n  ----> NULL, LEAF or TNODE
-	 *
-	 * tp is n's (parent) ----> NULL or TNODE
-	 */
-
-	BUG_ON(tp && IS_LEAF(tp));
-
-	/* Case 1: n is a leaf. Compare prefixes */
-
-	if (n != NULL && IS_LEAF(n) && tkey_equals(key, n->key)) {
-		li = leaf_info_new(plen);
 
-		if (!li)
-			return NULL;
+		/* we have found a leaf. Prefixes have already been compared */
+		if (IS_LEAF(n)) {
+			/* Case 1: n is a leaf, and prefixes match*/
+			insert_leaf_info(&n->list, li);
+			return fa_head;
+		}
 
-		fa_head = &li->falh;
-		insert_leaf_info(&n->list, li);
-		goto done;
+		tp = n;
+		n = rcu_dereference_rtnl(n->child[index]);
 	}
-	l = leaf_new(key);
-
-	if (!l)
-		return NULL;
-
-	li = leaf_info_new(plen);
 
-	if (!li) {
-		node_free(l);
+	l = leaf_new(key);
+	if (!l) {
+		free_leaf_info(li);
 		return NULL;
 	}
 
-	fa_head = &li->falh;
 	insert_leaf_info(&l->list, li);
 
-	if (t->trie && n == NULL) {
-		/* Case 2: n is NULL, and will just insert a new leaf */
-
-		node_set_parent(l, tp);
-
-		cindex = tkey_extract_bits(key, tp->pos, tp->bits);
-		put_child(tp, cindex, l);
-	} else {
-		/* Case 3: n is a LEAF or a TNODE and the key doesn't match. */
-		/*
-		 *  Add a new tnode here
-		 *  first tnode need some special handling
-		 */
+	/* Case 2: n is a LEAF or a TNODE and the key doesn't match.
+	 *
+	 *  Add a new tnode here
+	 *  first tnode need some special handling
+	 *  leaves us in position for handling as case 3
+	 */
+	if (n) {
+		struct tnode *tn;
+		int newpos;
 
-		if (n) {
-			pos = tp ? tp->pos+tp->bits : 0;
-			newpos = tkey_mismatch(key, pos, n->key);
-			tn = tnode_new(n->key, newpos, 1);
-		} else {
-			newpos = 0;
-			tn = tnode_new(key, newpos, 1); /* First tnode */
-		}
+		newpos = KEYLENGTH - __fls(n->key ^ key) - 1;
 
+		tn = tnode_new(key, newpos, 1);
 		if (!tn) {
 			free_leaf_info(li);
 			node_free(l);
 			return NULL;
 		}
 
-		node_set_parent(tn, tp);
-
-		missbit = tkey_extract_bits(key, newpos, 1);
-		put_child(tn, missbit, l);
-		put_child(tn, 1-missbit, n);
+		/* initialize routes out of node */
+		NODE_INIT_PARENT(tn, tp);
+		put_child(tn, get_index(key, tn) ^ 1, n);
 
-		if (tp) {
-			cindex = tkey_extract_bits(key, tp->pos, tp->bits);
-			put_child(tp, cindex, tn);
-		} else {
-			rcu_assign_pointer(t->trie, tn);
-		}
+		/* start adding routes into the node */
+		put_child_root(tp, t, key, tn);
+		node_set_parent(n, tn);
 
+		/* parent now has a NULL spot where the leaf can go */
 		tp = tn;
 	}
 
-	if (tp && tp->pos + tp->bits > 32)
-		pr_warn("fib_trie tp=%p pos=%d, bits=%d, key=%0x plen=%d\n",
-			tp, tp->pos, tp->bits, key, plen);
-
-	/* Rebalance the trie */
+	/* Case 3: n is NULL, and will just insert a new leaf */
+	if (tp) {
+		NODE_INIT_PARENT(l, tp);
+		put_child(tp, get_index(key, tp), l);
+		trie_rebalance(t, tp);
+	} else {
+		rcu_assign_pointer(t->trie, l);
+	}
 
-	trie_rebalance(t, tp);
-done:
 	return fa_head;
 }
 
@@ -1466,11 +1412,11 @@ static void trie_leaf_remove(struct trie *t, struct tnode *l)
 	pr_debug("entering trie_leaf_remove(%p)\n", l);
 
 	if (tp) {
-		t_key cindex = tkey_extract_bits(l->key, tp->pos, tp->bits);
-		put_child(tp, cindex, NULL);
+		put_child(tp, get_index(l->key, tp), NULL);
 		trie_rebalance(t, tp);
-	} else
+	} else {
 		RCU_INIT_POINTER(t->trie, NULL);
+	}
 
 	node_free(l);
 }
