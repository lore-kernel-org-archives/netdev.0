From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] fib_trie: print information on all routing tables
Date: Mon, 17 Mar 2008 14:02:36 -0700
Message-ID: <20080317140236.6160fb4f@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:60938 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752649AbYCQV1S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2008 17:27:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make /proc/net/fib_trie and /proc/net/fib_triestat display
all routing tables, not just local and main.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
 net/ipv4/fib_trie.c |  179 +++++++++++++++++++++++++++------------------------
 1 files changed, 95 insertions(+), 84 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 1ff446d..a7d089e 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -2026,9 +2026,8 @@ struct fib_table *fib_hash_table(u32 id)
 /* Depth first Trie walk iterator */
 struct fib_trie_iter {
 	struct seq_net_private p;
-	struct trie *trie_local, *trie_main;
+	struct fib_table *tb;
 	struct tnode *tnode;
-	struct trie *trie;
 	unsigned index;
 	unsigned depth;
 };
@@ -2081,31 +2080,26 @@ rescan:
 static struct node *fib_trie_get_first(struct fib_trie_iter *iter,
 				       struct trie *t)
 {
-	struct node *n ;
+	struct node *n;
 
 	if (!t)
 		return NULL;
 
 	n = rcu_dereference(t->trie);
-
-	if (!iter)
+	if (!n)
 		return NULL;
 
-	if (n) {
-		if (IS_TNODE(n)) {
-			iter->tnode = (struct tnode *) n;
-			iter->trie = t;
-			iter->index = 0;
-			iter->depth = 1;
-		} else {
-			iter->tnode = NULL;
-			iter->trie  = t;
-			iter->index = 0;
-			iter->depth = 0;
-		}
-		return n;
+	if (IS_TNODE(n)) {
+		iter->tnode = (struct tnode *) n;
+		iter->index = 0;
+		iter->depth = 1;
+	} else {
+		iter->tnode = NULL;
+		iter->index = 0;
+		iter->depth = 0;
 	}
-	return NULL;
+
+	return n;
 }
 
 static void trie_collect_stats(struct trie *t, struct trie_stat *s)
@@ -2116,8 +2110,7 @@ static void trie_collect_stats(struct trie *t, struct trie_stat *s)
 	memset(s, 0, sizeof(*s));
 
 	rcu_read_lock();
-	for (n = fib_trie_get_first(&iter, t); n;
-	     n = fib_trie_get_next(&iter)) {
+	for (n = fib_trie_get_first(&iter, t); n; n = fib_trie_get_next(&iter)) {
 		if (IS_LEAF(n)) {
 			struct leaf *l = (struct leaf *)n;
 			struct leaf_info *li;
@@ -2206,36 +2199,48 @@ static void trie_show_usage(struct seq_file *seq,
 }
 #endif /*  CONFIG_IP_FIB_TRIE_STATS */
 
-static void fib_trie_show(struct seq_file *seq, const char *name,
-			  struct trie *trie)
+static void fib_table_print(struct seq_file *seq, struct fib_table *tb)
 {
-	struct trie_stat stat;
-
-	trie_collect_stats(trie, &stat);
-	seq_printf(seq, "%s:\n", name);
-	trie_show_stats(seq, &stat);
-#ifdef CONFIG_IP_FIB_TRIE_STATS
-	trie_show_usage(seq, &trie->stats);
-#endif
+	if (tb->tb_id == RT_TABLE_LOCAL)
+		seq_puts(seq, "Local:\n");
+	else if (tb->tb_id == RT_TABLE_MAIN)
+		seq_puts(seq, "Main:\n");
+	else
+		seq_printf(seq, "Id %d:\n", tb->tb_id);
 }
 
+
 static int fib_triestat_seq_show(struct seq_file *seq, void *v)
 {
 	struct net *net = (struct net *)seq->private;
-	struct fib_table *tb;
+	unsigned int h;
 
 	seq_printf(seq,
 		   "Basic info: size of leaf:"
 		   " %Zd bytes, size of tnode: %Zd bytes.\n",
 		   sizeof(struct leaf), sizeof(struct tnode));
 
-	tb = fib_get_table(net, RT_TABLE_LOCAL);
-	if (tb)
-		fib_trie_show(seq, "Local", (struct trie *) tb->tb_data);
+	for (h = 0; h < FIB_TABLE_HASHSZ; h++) {
+		struct hlist_head *head = &net->ipv4.fib_table_hash[h];
+		struct hlist_node *node;
+		struct fib_table *tb;
+
+		hlist_for_each_entry_rcu(tb, node, head, tb_hlist) {
+			struct trie *t = (struct trie *) tb->tb_data;
+			struct trie_stat stat;
+
+			if (!t)
+				continue;
 
-	tb = fib_get_table(net, RT_TABLE_MAIN);
-	if (tb)
-		fib_trie_show(seq, "Main", (struct trie *) tb->tb_data);
+			fib_table_print(seq, tb);
+
+			trie_collect_stats(t, &stat);
+			trie_show_stats(seq, &stat);
+#ifdef CONFIG_IP_FIB_TRIE_STATS
+			trie_show_usage(seq, &t->stats);
+#endif
+		}
+	}
 
 	return 0;
 }
@@ -2271,23 +2276,30 @@ static const struct file_operations fib_triestat_fops = {
 	.release = fib_triestat_seq_release,
 };
 
-static struct node *fib_trie_get_idx(struct fib_trie_iter *iter,
-				      loff_t pos)
+static struct node *fib_trie_get_idx(struct fib_trie_iter *iter, loff_t pos)
 {
+	struct net *net = iter->p.net;
 	loff_t idx = 0;
-	struct node *n;
+	unsigned int h;
 
-	for (n = fib_trie_get_first(iter, iter->trie_local);
-	     n; ++idx, n = fib_trie_get_next(iter)) {
-		if (pos == idx)
-			return n;
-	}
+	for (h = 0; h < FIB_TABLE_HASHSZ; h++) {
+		struct hlist_head *head = &net->ipv4.fib_table_hash[h];
+		struct hlist_node *node;
+		struct fib_table *tb;
 
-	for (n = fib_trie_get_first(iter, iter->trie_main);
-	     n; ++idx, n = fib_trie_get_next(iter)) {
-		if (pos == idx)
-			return n;
+		hlist_for_each_entry_rcu(tb, node, head, tb_hlist) {
+			struct node *n;
+
+			for (n = fib_trie_get_first(iter,
+						    (struct trie *) tb->tb_data);
+			     n; n = fib_trie_get_next(iter))
+				if (pos == idx++) {
+					iter->tb = tb;
+					return n;
+				}
+		}
 	}
+
 	return NULL;
 }
 
@@ -2295,43 +2307,49 @@ static void *fib_trie_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(RCU)
 {
 	struct fib_trie_iter *iter = seq->private;
-	struct fib_table *tb;
 
-	if (!iter->trie_local) {
-		tb = fib_get_table(iter->p.net, RT_TABLE_LOCAL);
-		if (tb)
-			iter->trie_local = (struct trie *) tb->tb_data;
-	}
-	if (!iter->trie_main) {
-		tb = fib_get_table(iter->p.net, RT_TABLE_MAIN);
-		if (tb)
-			iter->trie_main = (struct trie *) tb->tb_data;
-	}
 	rcu_read_lock();
-	if (*pos == 0)
-		return SEQ_START_TOKEN;
-	return fib_trie_get_idx(iter, *pos - 1);
+	return fib_trie_get_idx(iter, *pos);
 }
 
 static void *fib_trie_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct fib_trie_iter *iter = seq->private;
-	void *l = v;
+	struct net *net = iter->p.net;
+	struct fib_table *tb = iter->tb;
+	struct hlist_node *tb_node;
+	unsigned int h;
+	struct node *n;
 
 	++*pos;
-	if (v == SEQ_START_TOKEN)
-		return fib_trie_get_idx(iter, 0);
-
-	v = fib_trie_get_next(iter);
-	BUG_ON(v == l);
-	if (v)
-		return v;
+	/* next node in same table */
+	n = fib_trie_get_next(iter);
+	if (n)
+		return n;
 
-	/* continue scan in next trie */
-	if (iter->trie == iter->trie_local)
-		return fib_trie_get_first(iter, iter->trie_main);
+	/* walk rest of this hash chain */
+	h = tb->tb_id & (FIB_TABLE_HASHSZ - 1);
+	while ( (tb_node = rcu_dereference(tb->tb_hlist.next)) ) {
+		tb = hlist_entry(tb_node, struct fib_table, tb_hlist);
+		n = fib_trie_get_first(iter, (struct trie *) tb->tb_data);
+		if (n)
+			goto found;
+	}
 
+	/* new hash chain */
+	while (++h < FIB_TABLE_HASHSZ) {
+		struct hlist_head *head = &net->ipv4.fib_table_hash[h];
+		hlist_for_each_entry_rcu(tb, tb_node, head, tb_hlist) {
+			n = fib_trie_get_first(iter, (struct trie *) tb->tb_data);
+			if (n)
+				goto found;
+		}
+	}
 	return NULL;
+
+found:
+	iter->tb = tb;
+	return n;
 }
 
 static void fib_trie_seq_stop(struct seq_file *seq, void *v)
@@ -2388,15 +2406,8 @@ static int fib_trie_seq_show(struct seq_file *seq, void *v)
 	const struct fib_trie_iter *iter = seq->private;
 	struct node *n = v;
 
-	if (v == SEQ_START_TOKEN)
-		return 0;
-
-	if (!node_parent_rcu(n)) {
-		if (iter->trie == iter->trie_local)
-			seq_puts(seq, "<local>:\n");
-		else
-			seq_puts(seq, "<main>:\n");
-	}
+	if (!node_parent_rcu(n))
+		fib_table_print(seq, iter->tb);
 
 	if (IS_TNODE(n)) {
 		struct tnode *tn = (struct tnode *) n;
-- 
1.5.4.3

