From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 08/29] fib_trie: Update insert and delete to make use of
 tp from find_node
Date: Tue, 24 Feb 2015 12:48:48 -0800
Message-ID: <20150224204848.26106.32874.stgit@ahduyck-vm-fedora20>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53725 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752326AbbBXUsv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 15:48:51 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKmowL008690
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:48:50 -0500
Received: from [192.168.122.173] (ovpn-112-73.phx2.redhat.com [10.3.112.73])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKmmDF030385
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:48:49 -0500
In-Reply-To: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change makes it so that the insert and delete functions make use of
the tnode pointer returned in the fib_find_node call.  By doing this we
will not have to rely on the parent pointer in the leaf which will be going
away soon.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |  237 ++++++++++++++++++++-------------------------------
 1 file changed, 94 insertions(+), 143 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 1cb9e92..dcdf636 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -300,7 +300,7 @@ static inline void empty_child_dec(struct tnode *n)
 	n->empty_children-- ? : n->full_children--;
 }
 
-static struct tnode *leaf_new(t_key key)
+static struct tnode *leaf_new(t_key key, struct fib_alias *fa)
 {
 	struct tnode *l = kmem_cache_alloc(trie_leaf_kmem, GFP_KERNEL);
 	if (l) {
@@ -310,12 +310,14 @@ static struct tnode *leaf_new(t_key key)
 		 * as the nodes are searched
 		 */
 		l->key = key;
-		l->slen = 0;
+		l->slen = fa->fa_slen;
 		l->pos = 0;
 		/* set bits to 0 indicating we are not a tnode */
 		l->bits = 0;
 
+		/* link leaf to fib alias */
 		INIT_HLIST_HEAD(&l->leaf);
+		hlist_add_head(&fa->fa_list, &l->leaf);
 	}
 	return l;
 }
@@ -842,10 +844,8 @@ static void resize(struct trie *t, struct tnode *tn)
 	}
 }
 
-static void leaf_pull_suffix(struct tnode *l)
+static void leaf_pull_suffix(struct tnode *tp, struct tnode *l)
 {
-	struct tnode *tp = node_parent(l);
-
 	while (tp && (tp->slen > tp->pos) && (tp->slen > l->slen)) {
 		if (update_suffix(tp) > l->slen)
 			break;
@@ -853,10 +853,8 @@ static void leaf_pull_suffix(struct tnode *l)
 	}
 }
 
-static void leaf_push_suffix(struct tnode *l)
+static void leaf_push_suffix(struct tnode *tn, struct tnode *l)
 {
-	struct tnode *tn = node_parent(l);
-
 	/* if this is a new leaf then tn will be NULL and we can sort
 	 * out parent suffix lengths as a part of trie_rebalance
 	 */
@@ -866,51 +864,6 @@ static void leaf_push_suffix(struct tnode *l)
 	}
 }
 
-static void fib_remove_alias(struct tnode *l, struct fib_alias *old)
-{
-	/* record the location of the previous list_info entry */
-	struct hlist_node **pprev = old->fa_list.pprev;
-	struct fib_alias *fa = hlist_entry(pprev, typeof(*fa), fa_list.next);
-
-	/* remove the fib_alias from the list */
-	hlist_del_rcu(&old->fa_list);
-
-	/* only access fa if it is pointing at the last valid hlist_node */
-	if (hlist_empty(&l->leaf) || (*pprev))
-		return;
-
-	/* update the trie with the latest suffix length */
-	l->slen = fa->fa_slen;
-	leaf_pull_suffix(l);
-}
-
-static void fib_insert_alias(struct tnode *l, struct fib_alias *fa,
-			     struct fib_alias *new)
-{
-	struct hlist_head *head = &l->leaf;
-
-	if (!fa) {
-		struct fib_alias *last;
-
-		hlist_for_each_entry(last, head, fa_list) {
-			if (new->fa_slen < last->fa_slen)
-				break;
-			fa = last;
-		}
-	}
-
-	if (fa)
-		hlist_add_behind_rcu(&new->fa_list, &fa->fa_list);
-	else
-		hlist_add_head_rcu(&new->fa_list, head);
-
-	/* if we added to the tail node then we need to update slen */
-	if (l->slen < new->fa_slen) {
-		l->slen = new->fa_slen;
-		leaf_push_suffix(l);
-	}
-}
-
 /* rcu_read_lock needs to be hold by caller from readside */
 static struct tnode *fib_find_node(struct trie *t, struct tnode **tp, u32 key)
 {
@@ -974,61 +927,28 @@ static void trie_rebalance(struct trie *t, struct tnode *tn)
 {
 	struct tnode *tp;
 
-	while ((tp = node_parent(tn)) != NULL) {
+	while (tn) {
+		tp = node_parent(tn);
 		resize(t, tn);
 		tn = tp;
 	}
-
-	/* Handle last (top) tnode */
-	if (IS_TNODE(tn))
-		resize(t, tn);
 }
 
 /* only used from updater-side */
-
-static struct tnode *fib_insert_node(struct trie *t, u32 key, int plen)
+static int fib_insert_node(struct trie *t, struct tnode *tp,
+			   struct fib_alias *new, t_key key)
 {
-	struct tnode *l, *n, *tp = NULL;
-
-	n = rtnl_dereference(t->trie);
-
-	/* If we point to NULL, stop. Either the tree is empty and we should
-	 * just put a new leaf in if, or we have reached an empty child slot,
-	 * and we should just put our new leaf in that.
-	 *
-	 * If we hit a node with a key that does't match then we should stop
-	 * and create a new tnode to replace that node and insert ourselves
-	 * and the other node into the new tnode.
-	 */
-	while (n) {
-		unsigned long index = get_index(key, n);
+	struct tnode *n, *l;
 
-		/* This bit of code is a bit tricky but it combines multiple
-		 * checks into a single check.  The prefix consists of the
-		 * prefix plus zeros for the "bits" in the prefix. The index
-		 * is the difference between the key and this value.  From
-		 * this we can actually derive several pieces of data.
-		 *   if !(index >> bits)
-		 *     we know the value is child index
-		 *   else
-		 *     we have a mismatch in skip bits and failed
-		 */
-		if (index >> n->bits)
-			break;
-
-		/* we have found a leaf. Prefixes have already been compared */
-		if (IS_LEAF(n)) {
-			/* Case 1: n is a leaf, and prefixes match*/
-			return n;
-		}
-
-		tp = n;
-		n = tnode_get_child_rcu(n, index);
-	}
-
-	l = leaf_new(key);
+	l = leaf_new(key, new);
 	if (!l)
-		return NULL;
+		return -ENOMEM;
+
+	/* retrieve child from parent node */
+	if (tp)
+		n = tnode_get_child(tp, get_index(key, tp));
+	else
+		n = rcu_dereference_rtnl(t->trie);
 
 	/* Case 2: n is a LEAF or a TNODE and the key doesn't match.
 	 *
@@ -1042,7 +962,7 @@ static struct tnode *fib_insert_node(struct trie *t, u32 key, int plen)
 		tn = tnode_new(key, __fls(key ^ n->key), 1);
 		if (!tn) {
 			node_free(l);
-			return NULL;
+			return -ENOMEM;
 		}
 
 		/* initialize routes out of node */
@@ -1058,20 +978,45 @@ static struct tnode *fib_insert_node(struct trie *t, u32 key, int plen)
 	}
 
 	/* Case 3: n is NULL, and will just insert a new leaf */
-	if (tp) {
-		NODE_INIT_PARENT(l, tp);
-		put_child(tp, get_index(key, tp), l);
-		trie_rebalance(t, tp);
-	} else {
-		rcu_assign_pointer(t->trie, l);
+	NODE_INIT_PARENT(l, tp);
+	put_child_root(tp, t, key, l);
+	trie_rebalance(t, tp);
+
+	return 0;
+}
+
+static int fib_insert_alias(struct trie *t, struct tnode *tp,
+			    struct tnode *l, struct fib_alias *new,
+			    struct fib_alias *fa, t_key key)
+{
+	if (!l)
+		return fib_insert_node(t, tp, new, key);
+
+	if (!fa) {
+		struct fib_alias *last;
+
+		hlist_for_each_entry(last, &l->leaf, fa_list) {
+			if (new->fa_slen < last->fa_slen)
+				break;
+			fa = last;
+		}
 	}
 
-	return l;
+	if (fa)
+		hlist_add_behind_rcu(&new->fa_list, &fa->fa_list);
+	else
+		hlist_add_head_rcu(&new->fa_list, &l->leaf);
+
+	/* if we added to the tail node then we need to update slen */
+	if (l->slen < new->fa_slen) {
+		l->slen = new->fa_slen;
+		leaf_push_suffix(tp, l);
+	}
+
+	return 0;
 }
 
-/*
- * Caller must hold RTNL.
- */
+/* Caller must hold RTNL. */
 int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 {
 	struct trie *t = (struct trie *)tb->tb_data;
@@ -1201,19 +1146,13 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 	new_fa->fa_slen = slen;
 
 	/* Insert new entry to the list. */
-	if (!l) {
-		l = fib_insert_node(t, key, plen);
-		if (unlikely(!l)) {
-			err = -ENOMEM;
-			goto out_free_new_fa;
-		}
-	}
+	err = fib_insert_alias(t, tp, l, new_fa, fa, key);
+	if (err)
+		goto out_free_new_fa;
 
 	if (!plen)
 		tb->tb_num_default++;
 
-	fib_insert_alias(l, fa, new_fa);
-
 	rt_cache_flush(cfg->fc_nlinfo.nl_net);
 	rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen, tb->tb_id,
 		  &cfg->fc_nlinfo, 0);
@@ -1402,9 +1341,36 @@ found:
 }
 EXPORT_SYMBOL_GPL(fib_table_lookup);
 
-/*
- * Caller must hold RTNL.
- */
+static void fib_remove_alias(struct trie *t, struct tnode *tp,
+			     struct tnode *l, struct fib_alias *old)
+{
+	/* record the location of the previous list_info entry */
+	struct hlist_node **pprev = old->fa_list.pprev;
+	struct fib_alias *fa = hlist_entry(pprev, typeof(*fa), fa_list.next);
+
+	/* remove the fib_alias from the list */
+	hlist_del_rcu(&old->fa_list);
+
+	/* if we emptied the list this leaf will be freed and we can sort
+	 * out parent suffix lengths as a part of trie_rebalance
+	 */
+	if (hlist_empty(&l->leaf)) {
+		put_child_root(tp, t, l->key, NULL);
+		node_free(l);
+		trie_rebalance(t, tp);
+		return;
+	}
+
+	/* only access fa if it is pointing at the last valid hlist_node */
+	if (*pprev)
+		return;
+
+	/* update the trie with the latest suffix length */
+	l->slen = fa->fa_slen;
+	leaf_pull_suffix(tp, l);
+}
+
+/* Caller must hold RTNL. */
 int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 {
 	struct trie *t = (struct trie *) tb->tb_data;
@@ -1428,7 +1394,6 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 		return -ESRCH;
 
 	fa = fib_find_alias(&l->leaf, slen, tos, 0);
-
 	if (!fa)
 		return -ESRCH;
 
@@ -1457,33 +1422,19 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 	if (!fa_to_delete)
 		return -ESRCH;
 
-	fa = fa_to_delete;
-	rtmsg_fib(RTM_DELROUTE, htonl(key), fa, plen, tb->tb_id,
+	rtmsg_fib(RTM_DELROUTE, htonl(key), fa_to_delete, plen, tb->tb_id,
 		  &cfg->fc_nlinfo, 0);
 
-	fib_remove_alias(l, fa);
-
 	if (!plen)
 		tb->tb_num_default--;
 
-	if (hlist_empty(&l->leaf)) {
-		struct tnode *tp = node_parent(l);
-
-		if (tp) {
-			put_child(tp, get_index(l->key, tp), NULL);
-			trie_rebalance(t, tp);
-		} else {
-			RCU_INIT_POINTER(t->trie, NULL);
-		}
-
-		node_free(l);
-	}
+	fib_remove_alias(t, tp, l, fa_to_delete);
 
-	if (fa->fa_state & FA_S_ACCESSED)
+	if (fa_to_delete->fa_state & FA_S_ACCESSED)
 		rt_cache_flush(cfg->fc_nlinfo.nl_net);
 
-	fib_release_info(fa->fa_info);
-	alias_free_mem_rcu(fa);
+	fib_release_info(fa_to_delete->fa_info);
+	alias_free_mem_rcu(fa_to_delete);
 	return 0;
 }
 
@@ -1622,7 +1573,7 @@ backtrace:
 		put_child_root(pn, t, n->key, NULL);
 		node_free(n);
 	} else {
-		leaf_pull_suffix(n);
+		leaf_pull_suffix(pn, n);
 	}
 
 	/* if trie is leaf only loop is completed */
