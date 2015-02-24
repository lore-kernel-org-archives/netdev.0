From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 10/29] fib_trie: Return pointer to tnode pointer in
 resize/inflate/halve
Date: Tue, 24 Feb 2015 12:49:02 -0800
Message-ID: <20150224204902.26106.63595.stgit@ahduyck-vm-fedora20>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45138 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752326AbbBXUtE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 15:49:04 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKn3mj016404
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:49:04 -0500
Received: from [192.168.122.173] (ovpn-112-73.phx2.redhat.com [10.3.112.73])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKn2SK014466
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:49:03 -0500
In-Reply-To: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resize related functions now all return a pointer to the pointer that
references the object that was resized.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |  132 +++++++++++++++++++++++++++++++--------------------
 1 file changed, 80 insertions(+), 52 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index b895ee7..be1ffe8 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -141,7 +141,7 @@ struct trie {
 	struct rcu_head rcu;
 };
 
-static void resize(struct trie *t, struct tnode *tn);
+static struct tnode **resize(struct trie *t, struct tnode *tn);
 static size_t tnode_free_size;
 
 /*
@@ -455,9 +455,11 @@ static void tnode_free(struct tnode *tn)
 	}
 }
 
-static void replace(struct trie *t, struct tnode *oldtnode, struct tnode *tn)
+static struct tnode __rcu **replace(struct trie *t, struct tnode *oldtnode,
+				    struct tnode *tn)
 {
 	struct tnode *tp = node_parent(oldtnode);
+	struct tnode **cptr;
 	unsigned long i;
 
 	/* setup the parent pointer out of and back into this node */
@@ -470,6 +472,9 @@ static void replace(struct trie *t, struct tnode *oldtnode, struct tnode *tn)
 	/* all pointers should be clean so we are done */
 	tnode_free(oldtnode);
 
+	/* record the pointer that is pointing to this node */
+	cptr = tp ? tp->child : &t->trie;
+
 	/* resize children now that oldtnode is freed */
 	for (i = tnode_child_length(tn); i;) {
 		struct tnode *inode = tnode_get_child(tn, --i);
@@ -478,9 +483,11 @@ static void replace(struct trie *t, struct tnode *oldtnode, struct tnode *tn)
 		if (tnode_full(tn, inode))
 			resize(t, inode);
 	}
+
+	return cptr;
 }
 
-static int inflate(struct trie *t, struct tnode *oldtnode)
+static struct tnode __rcu **inflate(struct trie *t, struct tnode *oldtnode)
 {
 	struct tnode *tn;
 	unsigned long i;
@@ -490,7 +497,7 @@ static int inflate(struct trie *t, struct tnode *oldtnode)
 
 	tn = tnode_new(oldtnode->key, oldtnode->pos - 1, oldtnode->bits + 1);
 	if (!tn)
-		return -ENOMEM;
+		goto notnode;
 
 	/* prepare oldtnode to be freed */
 	tnode_free_init(oldtnode);
@@ -567,16 +574,15 @@ static int inflate(struct trie *t, struct tnode *oldtnode)
 	}
 
 	/* setup the parent pointers into and out of this node */
-	replace(t, oldtnode, tn);
-
-	return 0;
+	return replace(t, oldtnode, tn);
 nomem:
 	/* all pointers should be clean so we are done */
 	tnode_free(tn);
-	return -ENOMEM;
+notnode:
+	return NULL;
 }
 
-static int halve(struct trie *t, struct tnode *oldtnode)
+static struct tnode __rcu **halve(struct trie *t, struct tnode *oldtnode)
 {
 	struct tnode *tn;
 	unsigned long i;
@@ -585,7 +591,7 @@ static int halve(struct trie *t, struct tnode *oldtnode)
 
 	tn = tnode_new(oldtnode->key, oldtnode->pos + 1, oldtnode->bits - 1);
 	if (!tn)
-		return -ENOMEM;
+		goto notnode;
 
 	/* prepare oldtnode to be freed */
 	tnode_free_init(oldtnode);
@@ -608,10 +614,8 @@ static int halve(struct trie *t, struct tnode *oldtnode)
 
 		/* Two nonempty children */
 		inode = tnode_new(node0->key, oldtnode->pos, 1);
-		if (!inode) {
-			tnode_free(tn);
-			return -ENOMEM;
-		}
+		if (!inode)
+			goto nomem;
 		tnode_free_append(tn, inode);
 
 		/* initialize pointers out of node */
@@ -624,9 +628,12 @@ static int halve(struct trie *t, struct tnode *oldtnode)
 	}
 
 	/* setup the parent pointers into and out of this node */
-	replace(t, oldtnode, tn);
-
-	return 0;
+	return replace(t, oldtnode, tn);
+nomem:
+	/* all pointers should be clean so we are done */
+	tnode_free(tn);
+notnode:
+	return NULL;
 }
 
 static void collapse(struct trie *t, struct tnode *oldtnode)
@@ -783,10 +790,14 @@ static bool should_collapse(const struct tnode *tn)
 }
 
 #define MAX_WORK 10
-static void resize(struct trie *t, struct tnode *tn)
+static struct tnode __rcu **resize(struct trie *t, struct tnode *tn)
 {
+#ifdef CONFIG_IP_FIB_TRIE_STATS
+	struct trie_use_stats __percpu *stats = t->stats;
+#endif
 	struct tnode *tp = node_parent(tn);
-	struct tnode __rcu **cptr;
+	unsigned long cindex = tp ? get_index(tn->key, tp) : 0;
+	struct tnode __rcu **cptr = tp ? tp->child : &t->trie;
 	int max_work = MAX_WORK;
 
 	pr_debug("In tnode_resize %p inflate_threshold=%d threshold=%d\n",
@@ -796,52 +807,57 @@ static void resize(struct trie *t, struct tnode *tn)
 	 * doing it ourselves.  This way we can let RCU fully do its
 	 * thing without us interfering
 	 */
-	cptr = tp ? &tp->child[get_index(tn->key, tp)] : &t->trie;
-	BUG_ON(tn != rtnl_dereference(*cptr));
+	BUG_ON(tn != rtnl_dereference(cptr[cindex]));
 
 	/* Double as long as the resulting node has a number of
 	 * nonempty nodes that are above the threshold.
 	 */
 	while (should_inflate(tp, tn) && max_work) {
-		if (inflate(t, tn)) {
+		struct tnode __rcu **tcptr = inflate(t, tn);
+
+		if (!tcptr) {
 #ifdef CONFIG_IP_FIB_TRIE_STATS
-			this_cpu_inc(t->stats->resize_node_skipped);
+			this_cpu_inc(stats->resize_node_skipped);
 #endif
 			break;
 		}
 
 		max_work--;
-		tn = rtnl_dereference(*cptr);
+		cptr = tcptr;
+		tn = rtnl_dereference(cptr[cindex]);
 	}
 
 	/* Return if at least one inflate is run */
 	if (max_work != MAX_WORK)
-		return;
+		return cptr;
 
 	/* Halve as long as the number of empty children in this
 	 * node is above threshold.
 	 */
 	while (should_halve(tp, tn) && max_work) {
-		if (halve(t, tn)) {
+		struct tnode __rcu **tcptr = halve(t, tn);
+
+		if (!tcptr) {
 #ifdef CONFIG_IP_FIB_TRIE_STATS
-			this_cpu_inc(t->stats->resize_node_skipped);
+			this_cpu_inc(stats->resize_node_skipped);
 #endif
 			break;
 		}
 
 		max_work--;
-		tn = rtnl_dereference(*cptr);
+		cptr = tcptr;
+		tn = rtnl_dereference(cptr[cindex]);
 	}
 
 	/* Only one child remains */
 	if (should_collapse(tn)) {
 		collapse(t, tn);
-		return;
+		return cptr;
 	}
 
 	/* Return if at least one deflate was run */
 	if (max_work != MAX_WORK)
-		return;
+		return cptr;
 
 	/* push the suffix length to the parent node */
 	if (tn->slen > tn->pos) {
@@ -850,6 +866,8 @@ static void resize(struct trie *t, struct tnode *tn)
 		if (tp && (slen > tp->slen))
 			tp->slen = slen;
 	}
+
+	return cptr;
 }
 
 static void leaf_pull_suffix(struct tnode *tp, struct tnode *l)
@@ -931,26 +949,30 @@ static struct fib_alias *fib_find_alias(struct hlist_head *fah, u8 slen,
 	return NULL;
 }
 
-static void trie_rebalance(struct trie *t, struct tnode *tn)
+static struct fib_table *trie_rebalance(struct trie *t, struct tnode *tn)
 {
-	struct tnode *tp;
+	struct tnode __rcu **cptr = &t->trie;
 
 	while (tn) {
-		tp = node_parent(tn);
-		resize(t, tn);
-		tn = tp;
+		struct tnode *tp = node_parent(tn);
+
+		cptr = resize(t, tn);
+		if (!tp)
+			break;
+		tn = container_of(cptr, struct tnode, child[0]);
 	}
+
+	return trie_get_table(container_of(cptr, struct trie, trie));
 }
 
-/* only used from updater-side */
-static int fib_insert_node(struct trie *t, struct tnode *tp,
-			   struct fib_alias *new, t_key key)
+static struct fib_table *fib_insert_node(struct trie *t, struct tnode *tp,
+					 struct fib_alias *new, t_key key)
 {
 	struct tnode *n, *l;
 
 	l = leaf_new(key, new);
 	if (!l)
-		return -ENOMEM;
+		goto noleaf;
 
 	/* retrieve child from parent node */
 	if (tp)
@@ -968,10 +990,8 @@ static int fib_insert_node(struct trie *t, struct tnode *tp,
 		struct tnode *tn;
 
 		tn = tnode_new(key, __fls(key ^ n->key), 1);
-		if (!tn) {
-			node_free(l);
-			return -ENOMEM;
-		}
+		if (!tn)
+			goto notnode;
 
 		/* initialize routes out of node */
 		NODE_INIT_PARENT(tn, tp);
@@ -988,14 +1008,19 @@ static int fib_insert_node(struct trie *t, struct tnode *tp,
 	/* Case 3: n is NULL, and will just insert a new leaf */
 	NODE_INIT_PARENT(l, tp);
 	put_child_root(tp, t, key, l);
-	trie_rebalance(t, tp);
 
-	return 0;
+	return trie_rebalance(t, tp);
+notnode:
+	node_free(l);
+noleaf:
+	return NULL;
 }
 
-static int fib_insert_alias(struct trie *t, struct tnode *tp,
-			    struct tnode *l, struct fib_alias *new,
-			    struct fib_alias *fa, t_key key)
+static struct fib_table *fib_insert_alias(struct trie *t,
+					  struct tnode *tp, struct tnode *l,
+					  struct fib_alias *new,
+					  struct fib_alias *fa,
+					  t_key key)
 {
 	if (!l)
 		return fib_insert_node(t, tp, new, key);
@@ -1021,7 +1046,7 @@ static int fib_insert_alias(struct trie *t, struct tnode *tp,
 		leaf_push_suffix(tp, l);
 	}
 
-	return 0;
+	return trie_get_table(t);
 }
 
 /* Caller must hold RTNL. */
@@ -1154,8 +1179,9 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 	new_fa->fa_slen = slen;
 
 	/* Insert new entry to the list. */
-	err = fib_insert_alias(t, tp, l, new_fa, fa, key);
-	if (err)
+	err = -ENOMEM;
+	tb = fib_insert_alias(t, tp, l, new_fa, fa, key);
+	if (!tb)
 		goto out_free_new_fa;
 
 	if (!plen)
@@ -1536,18 +1562,20 @@ backtrace:
 		/* walk trie in reverse order */
 		do {
 			while (!(cindex--)) {
+				struct tnode __rcu **cptr;
 				t_key pkey = pn->key;
 
 				n = pn;
 				pn = node_parent(n);
 
 				/* resize completed node */
-				resize(t, n);
+				cptr = resize(t, n);
 
 				/* if we got the root we are done */
 				if (!pn)
 					goto flush_complete;
 
+				pn = container_of(cptr, struct tnode, child[0]);
 				cindex = get_index(pkey, pn);
 			}
 
