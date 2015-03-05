From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 1/9] fib_trie: Return pointer to tnode pointer in
 resize/inflate/halve
Date: Thu, 05 Mar 2015 14:50:35 -0800
Message-ID: <20150305225035.1642.86868.stgit@ahduyck-vm-fedora20>
References: <20150305224208.1642.34205.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60986 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752975AbbCEWui (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 17:50:38 -0500
In-Reply-To: <20150305224208.1642.34205.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resize related functions now all return a pointer to the pointer that
references the object that was resized.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |  106 +++++++++++++++++++++++++++++++--------------------
 1 file changed, 65 insertions(+), 41 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index fae34ad..7e96529 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -143,7 +143,7 @@ struct trie {
 #endif
 };
 
-static void resize(struct trie *t, struct tnode *tn);
+static struct tnode **resize(struct trie *t, struct tnode *tn);
 static size_t tnode_free_size;
 
 /*
@@ -467,9 +467,11 @@ static void tnode_free(struct tnode *tn)
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
@@ -482,6 +484,9 @@ static void replace(struct trie *t, struct tnode *oldtnode, struct tnode *tn)
 	/* all pointers should be clean so we are done */
 	tnode_free(oldtnode);
 
+	/* record the pointer that is pointing to this node */
+	cptr = tp ? tp->tnode : &t->trie;
+
 	/* resize children now that oldtnode is freed */
 	for (i = tnode_child_length(tn); i;) {
 		struct tnode *inode = tnode_get_child(tn, --i);
@@ -490,9 +495,11 @@ static void replace(struct trie *t, struct tnode *oldtnode, struct tnode *tn)
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
@@ -502,7 +509,7 @@ static int inflate(struct trie *t, struct tnode *oldtnode)
 
 	tn = tnode_new(oldtnode->key, oldtnode->pos - 1, oldtnode->bits + 1);
 	if (!tn)
-		return -ENOMEM;
+		goto notnode;
 
 	/* prepare oldtnode to be freed */
 	tnode_free_init(oldtnode);
@@ -579,16 +586,15 @@ static int inflate(struct trie *t, struct tnode *oldtnode)
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
@@ -597,7 +603,7 @@ static int halve(struct trie *t, struct tnode *oldtnode)
 
 	tn = tnode_new(oldtnode->key, oldtnode->pos + 1, oldtnode->bits - 1);
 	if (!tn)
-		return -ENOMEM;
+		goto notnode;
 
 	/* prepare oldtnode to be freed */
 	tnode_free_init(oldtnode);
@@ -620,10 +626,8 @@ static int halve(struct trie *t, struct tnode *oldtnode)
 
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
@@ -636,9 +640,12 @@ static int halve(struct trie *t, struct tnode *oldtnode)
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
@@ -795,10 +802,14 @@ static bool should_collapse(const struct tnode *tn)
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
+	struct tnode __rcu **cptr = tp ? tp->tnode : &t->trie;
 	int max_work = MAX_WORK;
 
 	pr_debug("In tnode_resize %p inflate_threshold=%d threshold=%d\n",
@@ -808,52 +819,57 @@ static void resize(struct trie *t, struct tnode *tn)
 	 * doing it ourselves.  This way we can let RCU fully do its
 	 * thing without us interfering
 	 */
-	cptr = tp ? &tp->tnode[get_index(tn->key, tp)] : &t->trie;
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
@@ -862,6 +878,8 @@ static void resize(struct trie *t, struct tnode *tn)
 		if (tp && (slen > tp->slen))
 			tp->slen = slen;
 	}
+
+	return cptr;
 }
 
 static void leaf_pull_suffix(struct tnode *tp, struct tnode *l)
@@ -951,16 +969,18 @@ static struct fib_alias *fib_find_alias(struct hlist_head *fah, u8 slen,
 
 static void trie_rebalance(struct trie *t, struct tnode *tn)
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
+		tn = container_of(cptr, struct tnode, tnode[0]);
 	}
 }
 
-/* only used from updater-side */
 static int fib_insert_node(struct trie *t, struct tnode *tp,
 			   struct fib_alias *new, t_key key)
 {
@@ -968,7 +988,7 @@ static int fib_insert_node(struct trie *t, struct tnode *tp,
 
 	l = leaf_new(key, new);
 	if (!l)
-		return -ENOMEM;
+		goto noleaf;
 
 	/* retrieve child from parent node */
 	if (tp)
@@ -986,10 +1006,8 @@ static int fib_insert_node(struct trie *t, struct tnode *tp,
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
@@ -1009,6 +1027,10 @@ static int fib_insert_node(struct trie *t, struct tnode *tp,
 	trie_rebalance(t, tp);
 
 	return 0;
+notnode:
+	node_free(l);
+noleaf:
+	return -ENOMEM;
 }
 
 static int fib_insert_alias(struct trie *t, struct tnode *tp,
@@ -1562,18 +1584,20 @@ backtrace:
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
 
+				pn = container_of(cptr, struct tnode, tnode[0]);
 				cindex = get_index(pkey, pn);
 			}
 
