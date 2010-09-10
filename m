From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] fib: cleanups
Date: Fri, 10 Sep 2010 11:32:28 +0200
Message-ID: <1284111148.24675.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:58265 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750988Ab0IJJcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 05:32:33 -0400
Received: by fxm16 with SMTP id 16so1563628fxm.19
        for <netdev@vger.kernel.org>; Fri, 10 Sep 2010 02:32:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use rcu_dereference_rtnl() helper

Change hard coded constants in fib_flag_trans()
 7 -> RTN_UNREACHABLE
 8 -> RTN_PROHIBIT

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/fib_trie.c |   55 +++++++++++++++++-------------------------
 1 file changed, 23 insertions(+), 32 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 4a8e370..a96e5ec 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -186,9 +186,7 @@ static inline struct tnode *node_parent_rcu(struct node *node)
 {
 	struct tnode *ret = node_parent(node);
 
-	return rcu_dereference_check(ret,
-				     rcu_read_lock_held() ||
-				     lockdep_rtnl_is_held());
+	return rcu_dereference_rtnl(ret);
 }
 
 /* Same as rcu_assign_pointer
@@ -211,9 +209,7 @@ static inline struct node *tnode_get_child_rcu(struct tnode *tn, unsigned int i)
 {
 	struct node *ret = tnode_get_child(tn, i);
 
-	return rcu_dereference_check(ret,
-				     rcu_read_lock_held() ||
-				     lockdep_rtnl_is_held());
+	return rcu_dereference_rtnl(ret);
 }
 
 static inline int tnode_child_length(const struct tnode *tn)
@@ -459,8 +455,8 @@ static struct tnode *tnode_new(t_key key, int pos, int bits)
 		tn->empty_children = 1<<bits;
 	}
 
-	pr_debug("AT %p s=%u %lu\n", tn, (unsigned int) sizeof(struct tnode),
-		 (unsigned long) (sizeof(struct node) << bits));
+	pr_debug("AT %p s=%zu %zu\n", tn, sizeof(struct tnode),
+		 sizeof(struct node) << bits);
 	return tn;
 }
 
@@ -609,11 +605,10 @@ static struct node *resize(struct trie *t, struct tnode *tn)
 
 	/* Keep root node larger  */
 
-	if (!node_parent((struct node*) tn)) {
+	if (!node_parent((struct node *)tn)) {
 		inflate_threshold_use = inflate_threshold_root;
 		halve_threshold_use = halve_threshold_root;
-	}
-	else {
+	} else {
 		inflate_threshold_use = inflate_threshold;
 		halve_threshold_use = halve_threshold;
 	}
@@ -639,7 +634,7 @@ static struct node *resize(struct trie *t, struct tnode *tn)
 	check_tnode(tn);
 
 	/* Return if at least one inflate is run */
-	if( max_work != MAX_WORK)
+	if (max_work != MAX_WORK)
 		return (struct node *) tn;
 
 	/*
@@ -966,9 +961,7 @@ fib_find_node(struct trie *t, u32 key)
 	struct node *n;
 
 	pos = 0;
-	n = rcu_dereference_check(t->trie,
-				  rcu_read_lock_held() ||
-				  lockdep_rtnl_is_held());
+	n = rcu_dereference_rtnl(t->trie);
 
 	while (n != NULL &&  NODE_TYPE(n) == T_TNODE) {
 		tn = (struct tnode *) n;
@@ -1748,16 +1741,14 @@ static struct leaf *leaf_walk_rcu(struct tnode *p, struct node *c)
 
 		/* Node empty, walk back up to parent */
 		c = (struct node *) p;
-	} while ( (p = node_parent_rcu(c)) != NULL);
+	} while ((p = node_parent_rcu(c)) != NULL);
 
 	return NULL; /* Root of trie */
 }
 
 static struct leaf *trie_firstleaf(struct trie *t)
 {
-	struct tnode *n = (struct tnode *) rcu_dereference_check(t->trie,
-							rcu_read_lock_held() ||
-							lockdep_rtnl_is_held());
+	struct tnode *n = (struct tnode *)rcu_dereference_rtnl(t->trie);
 
 	if (!n)
 		return NULL;
@@ -2043,14 +2034,14 @@ struct fib_trie_iter {
 	struct seq_net_private p;
 	struct fib_table *tb;
 	struct tnode *tnode;
-	unsigned index;
-	unsigned depth;
+	unsigned int index;
+	unsigned int depth;
 };
 
 static struct node *fib_trie_get_next(struct fib_trie_iter *iter)
 {
 	struct tnode *tn = iter->tnode;
-	unsigned cindex = iter->index;
+	unsigned int cindex = iter->index;
 	struct tnode *p;
 
 	/* A single entry routing table */
@@ -2159,7 +2150,7 @@ static void trie_collect_stats(struct trie *t, struct trie_stat *s)
  */
 static void trie_show_stats(struct seq_file *seq, struct trie_stat *stat)
 {
-	unsigned i, max, pointers, bytes, avdepth;
+	unsigned int i, max, pointers, bytes, avdepth;
 
 	if (stat->leaves)
 		avdepth = stat->totdepth*100 / stat->leaves;
@@ -2356,7 +2347,8 @@ static void fib_trie_seq_stop(struct seq_file *seq, void *v)
 
 static void seq_indent(struct seq_file *seq, int n)
 {
-	while (n-- > 0) seq_puts(seq, "   ");
+	while (n-- > 0)
+		seq_puts(seq, "   ");
 }
 
 static inline const char *rtn_scope(char *buf, size_t len, enum rt_scope_t s)
@@ -2388,7 +2380,7 @@ static const char *const rtn_type_names[__RTN_MAX] = {
 	[RTN_XRESOLVE] = "XRESOLVE",
 };
 
-static inline const char *rtn_type(char *buf, size_t len, unsigned t)
+static inline const char *rtn_type(char *buf, size_t len, unsigned int t)
 {
 	if (t < __RTN_MAX && rtn_type_names[t])
 		return rtn_type_names[t];
@@ -2544,13 +2536,12 @@ static void fib_route_seq_stop(struct seq_file *seq, void *v)
 	rcu_read_unlock();
 }
 
-static unsigned fib_flag_trans(int type, __be32 mask, const struct fib_info *fi)
+static unsigned int fib_flag_trans(int type, __be32 mask, const struct fib_info *fi)
 {
-	static unsigned type2flags[RTN_MAX + 1] = {
-		[7] = RTF_REJECT, [8] = RTF_REJECT,
-	};
-	unsigned flags = type2flags[type];
+	unsigned int flags = 0;
 
+	if (type == RTN_UNREACHABLE || type == RTN_PROHIBIT)
+		flags = RTF_REJECT;
 	if (fi && fi->fib_nh->nh_gw)
 		flags |= RTF_GATEWAY;
 	if (mask == htonl(0xFFFFFFFF))
@@ -2562,7 +2553,7 @@ static unsigned fib_flag_trans(int type, __be32 mask, const struct fib_info *fi)
 /*
  *	This outputs /proc/net/route.
  *	The format of the file is not supposed to be changed
- * 	and needs to be same as fib_hash output to avoid breaking
+ *	and needs to be same as fib_hash output to avoid breaking
  *	legacy utilities
  */
 static int fib_route_seq_show(struct seq_file *seq, void *v)
@@ -2587,7 +2578,7 @@ static int fib_route_seq_show(struct seq_file *seq, void *v)
 
 		list_for_each_entry_rcu(fa, &li->falh, fa_list) {
 			const struct fib_info *fi = fa->fa_info;
-			unsigned flags = fib_flag_trans(fa->fa_type, mask, fi);
+			unsigned int flags = fib_flag_trans(fa->fa_type, mask, fi);
 			int len;
 
 			if (fa->fa_type == RTN_BROADCAST


