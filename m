From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [IPV4 2/9] fib_trie: style cleanup
Date: Tue, 22 Jan 2008 15:37:35 -0800
Message-ID: <20080122233926.766053592@linux-foundation.org>
References: <20080122233733.404145234@linux-foundation.org>
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen.hemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:33113 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757786AbYAWAJx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2008 19:09:53 -0500
Content-Disposition: inline; filename=fib-trie-style.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Style cleanups:
      * make check_leaf return -1 or plen, rather than by reference
      * Get rid of #ifdef that is always set
      * split out embedded function calls in if statements.
      * checkpatch warnings

Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>

--- a/net/ipv4/fib_trie.c	2008-01-21 10:18:42.000000000 -0800
+++ b/net/ipv4/fib_trie.c	2008-01-21 10:19:00.000000000 -0800
@@ -155,7 +155,8 @@ struct trie {
 };
 
 static void put_child(struct trie *t, struct tnode *tn, int i, struct node *n);
-static void tnode_put_child_reorg(struct tnode *tn, int i, struct node *n, int wasfull);
+static void tnode_put_child_reorg(struct tnode *tn, int i, struct node *n,
+				  int wasfull);
 static struct node *resize(struct trie *t, struct tnode *tn);
 static struct tnode *inflate(struct trie *t, struct tnode *tn);
 static struct tnode *halve(struct trie *t, struct tnode *tn);
@@ -395,7 +396,7 @@ static struct leaf_info *leaf_info_new(i
 	return li;
 }
 
-static struct tnode* tnode_new(t_key key, int pos, int bits)
+static struct tnode *tnode_new(t_key key, int pos, int bits)
 {
 	size_t sz = sizeof(struct tnode) + (sizeof(struct node *) << bits);
 	struct tnode *tn = tnode_alloc(sz);
@@ -427,7 +428,8 @@ static inline int tnode_full(const struc
 	return ((struct tnode *) n)->pos == tn->pos + tn->bits;
 }
 
-static inline void put_child(struct trie *t, struct tnode *tn, int i, struct node *n)
+static inline void put_child(struct trie *t, struct tnode *tn, int i,
+			     struct node *n)
 {
 	tnode_put_child_reorg(tn, i, n, -1);
 }
@@ -437,7 +439,8 @@ static inline void put_child(struct trie
   * Update the value of full_children and empty_children.
   */
 
-static void tnode_put_child_reorg(struct tnode *tn, int i, struct node *n, int wasfull)
+static void tnode_put_child_reorg(struct tnode *tn, int i, struct node *n,
+				  int wasfull)
 {
 	struct node *chi = tn->child[i];
 	int isfull;
@@ -577,11 +580,13 @@ static struct node *resize(struct trie *
 	err = 0;
 	max_resize = 10;
 	while ((tn->full_children > 0 &&  max_resize-- &&
-	       50 * (tn->full_children + tnode_child_length(tn) - tn->empty_children) >=
-				inflate_threshold_use * tnode_child_length(tn))) {
+		50 * (tn->full_children + tnode_child_length(tn)
+		      - tn->empty_children)
+		>= inflate_threshold_use * tnode_child_length(tn))) {
 
 		old_tn = tn;
 		tn = inflate(t, tn);
+
 		if (IS_ERR(tn)) {
 			tn = old_tn;
 #ifdef CONFIG_IP_FIB_TRIE_STATS
@@ -593,11 +598,13 @@ static struct node *resize(struct trie *
 
 	if (max_resize < 0) {
 		if (!tn->parent)
-			printk(KERN_WARNING "Fix inflate_threshold_root. Now=%d size=%d bits\n",
-			       inflate_threshold_root, tn->bits);
+			pr_warning("Fix inflate_threshold_root."
+				   " Now=%d size=%d bits\n",
+				   inflate_threshold_root, tn->bits);
 		else
-			printk(KERN_WARNING "Fix inflate_threshold. Now=%d size=%d bits\n",
-			       inflate_threshold, tn->bits);
+			pr_warning("Fix inflate_threshold."
+				   " Now=%d size=%d bits\n",
+				   inflate_threshold, tn->bits);
 	}
 
 	check_tnode(tn);
@@ -634,11 +641,13 @@ static struct node *resize(struct trie *
 
 	if (max_resize < 0) {
 		if (!tn->parent)
-			printk(KERN_WARNING "Fix halve_threshold_root. Now=%d size=%d bits\n",
-			       halve_threshold_root, tn->bits);
+			pr_warning("Fix halve_threshold_root."
+				   " Now=%d size=%d bits\n",
+				   halve_threshold_root, tn->bits);
 		else
-			printk(KERN_WARNING "Fix halve_threshold. Now=%d size=%d bits\n",
-			       halve_threshold, tn->bits);
+			pr_warning("Fix halve_threshold."
+				   " Now=%d size=%d bits\n",
+				   halve_threshold, tn->bits);
 	}
 
 	/* Only one child remains */
@@ -681,8 +690,9 @@ static struct tnode *inflate(struct trie
 	 */
 
 	for (i = 0; i < olen; i++) {
-		struct tnode *inode = (struct tnode *) tnode_get_child(oldtnode, i);
+		struct tnode *inode;
 
+		inode = (struct tnode *) tnode_get_child(oldtnode, i);
 		if (inode &&
 		    IS_TNODE(inode) &&
 		    inode->pos == oldtnode->pos + oldtnode->bits &&
@@ -722,8 +732,9 @@ static struct tnode *inflate(struct trie
 
 		if (IS_LEAF(node) || ((struct tnode *) node)->pos >
 		   tn->pos + tn->bits - 1) {
-			if (tkey_extract_bits(node->key, oldtnode->pos + oldtnode->bits,
-					     1) == 0)
+			if (tkey_extract_bits(node->key,
+					      oldtnode->pos + oldtnode->bits,
+					      1) == 0)
 				put_child(t, tn, 2*i, node);
 			else
 				put_child(t, tn, 2*i+1, node);
@@ -899,7 +910,7 @@ static struct leaf_info *find_leaf_info(
 	return NULL;
 }
 
-static inline struct list_head * get_fa_head(struct leaf *l, int plen)
+static inline struct list_head *get_fa_head(struct leaf *l, int plen)
 {
 	struct leaf_info *li = find_leaf_info(l, plen);
 
@@ -949,7 +960,10 @@ fib_find_node(struct trie *t, u32 key)
 
 		if (tkey_sub_equals(tn->key, pos, tn->pos-pos, key)) {
 			pos = tn->pos + tn->bits;
-			n = tnode_get_child_rcu(tn, tkey_extract_bits(key, tn->pos, tn->bits));
+			n = tnode_get_child_rcu(tn,
+						tkey_extract_bits(key,
+								  tn->pos,
+								  tn->bits));
 		} else
 			break;
 	}
@@ -970,8 +984,10 @@ static struct node *trie_rebalance(struc
 	while (tn != NULL && (tp = node_parent((struct node *)tn)) != NULL) {
 		cindex = tkey_extract_bits(key, tp->pos, tp->bits);
 		wasfull = tnode_full(tp, tnode_get_child(tp, cindex));
-		tn = (struct tnode *) resize (t, (struct tnode *)tn);
-		tnode_put_child_reorg((struct tnode *)tp, cindex,(struct node*)tn, wasfull);
+		tn = (struct tnode *) resize(t, (struct tnode *)tn);
+
+		tnode_put_child_reorg((struct tnode *)tp, cindex,
+				      (struct node *)tn, wasfull);
 
 		tp = node_parent((struct node *) tn);
 		if (!tp)
@@ -981,9 +997,9 @@ static struct node *trie_rebalance(struc
 
 	/* Handle last (top) tnode */
 	if (IS_TNODE(tn))
-		tn = (struct tnode*) resize(t, (struct tnode *)tn);
+		tn = (struct tnode *)resize(t, (struct tnode *)tn);
 
-	return (struct node*) tn;
+	return (struct node *)tn;
 }
 
 /* only used from updater-side */
@@ -1028,7 +1044,10 @@ static struct list_head *fib_insert_node
 		if (tkey_sub_equals(tn->key, pos, tn->pos-pos, key)) {
 			tp = tn;
 			pos = tn->pos + tn->bits;
-			n = tnode_get_child(tn, tkey_extract_bits(key, tn->pos, tn->bits));
+			n = tnode_get_child(tn,
+					    tkey_extract_bits(key,
+							      tn->pos,
+							      tn->bits));
 
 			BUG_ON(n && node_parent(n) != tn);
 		} else
@@ -1113,16 +1132,18 @@ static struct list_head *fib_insert_node
 
 		if (tp) {
 			cindex = tkey_extract_bits(key, tp->pos, tp->bits);
-			put_child(t, (struct tnode *)tp, cindex, (struct node *)tn);
+			put_child(t, (struct tnode *)tp, cindex,
+				  (struct node *)tn);
 		} else {
-			rcu_assign_pointer(t->trie, (struct node *)tn); /* First tnode */
+			rcu_assign_pointer(t->trie, (struct node *)tn);
 			tp = tn;
 		}
 	}
 
 	if (tp && tp->pos + tp->bits > 32)
-		printk(KERN_WARNING "fib_trie tp=%p pos=%d, bits=%d, key=%0x plen=%d\n",
-		       tp, tp->pos, tp->bits, key, plen);
+		pr_warning("fib_trie"
+			   " tp=%p pos=%d, bits=%d, key=%0x plen=%d\n",
+			   tp, tp->pos, tp->bits, key, plen);
 
 	/* Rebalance the trie */
 
@@ -1232,10 +1253,10 @@ static int fn_trie_insert(struct fib_tab
 				break;
 			if (fa->fa_type == cfg->fc_type &&
 			    fa->fa_scope == cfg->fc_scope &&
-			    fa->fa_info == fi) {
+			    fa->fa_info == fi)
 				goto out;
-			}
 		}
+
 		if (!(cfg->fc_nlflags & NLM_F_APPEND))
 			fa = fa_orig;
 	}
@@ -1286,38 +1307,40 @@ err:
 
 
 /* should be called with rcu_read_lock */
-static inline int check_leaf(struct trie *t, struct leaf *l,
-			     t_key key, int *plen, const struct flowi *flp,
-			     struct fib_result *res)
+static int check_leaf(struct trie *t, struct leaf *l,
+		      t_key key,  const struct flowi *flp,
+		      struct fib_result *res)
 {
-	int err, i;
-	__be32 mask;
 	struct leaf_info *li;
 	struct hlist_head *hhead = &l->list;
 	struct hlist_node *node;
 
 	hlist_for_each_entry_rcu(li, node, hhead, hlist) {
-		i = li->plen;
-		mask = inet_make_mask(i);
+		int err;
+		int plen = li->plen;
+		__be32 mask = inet_make_mask(plen);
+
 		if (l->key != (key & ntohl(mask)))
 			continue;
 
-		if ((err = fib_semantic_match(&li->falh, flp, res, htonl(l->key), mask, i)) <= 0) {
-			*plen = i;
+		err = fib_semantic_match(&li->falh, flp, res,
+					 htonl(l->key), mask, plen);
+
 #ifdef CONFIG_IP_FIB_TRIE_STATS
+		if (err <= 0)
 			t->stats.semantic_match_passed++;
+		else
+			t->stats.semantic_match_miss++;
 #endif
-			return err;
-		}
-#ifdef CONFIG_IP_FIB_TRIE_STATS
-		t->stats.semantic_match_miss++;
-#endif
+		if (err <= 0)
+			return plen;
 	}
-	return 1;
+
+	return -1;
 }
 
-static int
-fn_trie_lookup(struct fib_table *tb, const struct flowi *flp, struct fib_result *res)
+static int fn_trie_lookup(struct fib_table *tb, const struct flowi *flp,
+			  struct fib_result *res)
 {
 	struct trie *t = (struct trie *) tb->tb_data;
 	int plen, ret = 0;
@@ -1344,10 +1367,13 @@ fn_trie_lookup(struct fib_table *tb, con
 
 	/* Just a leaf? */
 	if (IS_LEAF(n)) {
-		if ((ret = check_leaf(t, (struct leaf *)n, key, &plen, flp, res)) <= 0)
-			goto found;
-		goto failed;
+		plen = check_leaf(t, (struct leaf *)n, key, flp, res);
+		if (plen < 0)
+			goto failed;
+		ret = 0;
+		goto found;
 	}
+
 	pn = (struct tnode *) n;
 	chopped_off = 0;
 
@@ -1369,14 +1395,14 @@ fn_trie_lookup(struct fib_table *tb, con
 		}
 
 		if (IS_LEAF(n)) {
-			if ((ret = check_leaf(t, (struct leaf *)n, key, &plen, flp, res)) <= 0)
-				goto found;
-			else
+			plen = check_leaf(t, (struct leaf *)n, key, flp, res);
+			if (plen < 0)
 				goto backtrace;
+
+			ret = 0;
+			goto found;
 		}
 
-#define HL_OPTIMIZE
-#ifdef HL_OPTIMIZE
 		cn = (struct tnode *)n;
 
 		/*
@@ -1405,12 +1431,13 @@ fn_trie_lookup(struct fib_table *tb, con
 		 * *are* zero.
 		 */
 
-		/* NOTA BENE: CHECKING ONLY SKIPPED BITS FOR THE NEW NODE HERE */
+		/* NOTA BENE: Checking only skipped bits
+		   for the new node here */
 
 		if (current_prefix_length < pos+bits) {
 			if (tkey_extract_bits(cn->key, current_prefix_length,
-						cn->pos - current_prefix_length) != 0 ||
-			    !(cn->child[0]))
+						cn->pos - current_prefix_length)
+			    || !(cn->child[0]))
 				goto backtrace;
 		}
 
@@ -1433,14 +1460,17 @@ fn_trie_lookup(struct fib_table *tb, con
 		 * new tnode's key.
 		 */
 
-		/* Note: We aren't very concerned about the piece of the key
-		 * that precede pn->pos+pn->bits, since these have already been
-		 * checked. The bits after cn->pos aren't checked since these are
-		 * by definition "unknown" at this point. Thus, what we want to
-		 * see is if we are about to enter the "prefix matching" state,
-		 * and in that case verify that the skipped bits that will prevail
-		 * throughout this subtree are zero, as they have to be if we are
-		 * to find a matching prefix.
+		/*
+		 * Note: We aren't very concerned about the piece of
+		 * the key that precede pn->pos+pn->bits, since these
+		 * have already been checked. The bits after cn->pos
+		 * aren't checked since these are by definition
+		 * "unknown" at this point. Thus, what we want to see
+		 * is if we are about to enter the "prefix matching"
+		 * state, and in that case verify that the skipped
+		 * bits that will prevail throughout this subtree are
+		 * zero, as they have to be if we are to find a
+		 * matching prefix.
 		 */
 
 		node_prefix = mask_pfx(cn->key, cn->pos);
@@ -1448,13 +1478,15 @@ fn_trie_lookup(struct fib_table *tb, con
 		pref_mismatch = key_prefix^node_prefix;
 		mp = 0;
 
-		/* In short: If skipped bits in this node do not match the search
-		 * key, enter the "prefix matching" state.directly.
+		/*
+		 * In short: If skipped bits in this node do not match
+		 * the search key, enter the "prefix matching"
+		 * state.directly.
 		 */
 		if (pref_mismatch) {
 			while (!(pref_mismatch & (1<<(KEYLENGTH-1)))) {
 				mp++;
-				pref_mismatch = pref_mismatch <<1;
+				pref_mismatch = pref_mismatch << 1;
 			}
 			key_prefix = tkey_extract_bits(cn->key, mp, cn->pos-mp);
 
@@ -1464,7 +1496,7 @@ fn_trie_lookup(struct fib_table *tb, con
 			if (current_prefix_length >= cn->pos)
 				current_prefix_length = mp;
 		}
-#endif
+
 		pn = (struct tnode *)n; /* Descend */
 		chopped_off = 0;
 		continue;
@@ -1473,12 +1505,14 @@ backtrace:
 		chopped_off++;
 
 		/* As zero don't change the child key (cindex) */
-		while ((chopped_off <= pn->bits) && !(cindex & (1<<(chopped_off-1))))
+		while ((chopped_off <= pn->bits)
+		       && !(cindex & (1<<(chopped_off-1))))
 			chopped_off++;
 
 		/* Decrease current_... with bits chopped off */
 		if (current_prefix_length > pn->pos + pn->bits - chopped_off)
-			current_prefix_length = pn->pos + pn->bits - chopped_off;
+			current_prefix_length = pn->pos + pn->bits
+				- chopped_off;
 
 		/*
 		 * Either we do the actual chop off according or if we have
@@ -1528,7 +1562,8 @@ static int trie_leaf_remove(struct trie 
 	while (n != NULL && IS_TNODE(n)) {
 		struct tnode *tn = (struct tnode *) n;
 		check_tnode(tn);
-		n = tnode_get_child(tn ,tkey_extract_bits(key, tn->pos, tn->bits));
+		n = tnode_get_child(tn, tkey_extract_bits(key,
+							  tn->pos, tn->bits));
 
 		BUG_ON(n && node_parent(n) != tn);
 	}
@@ -1694,7 +1729,7 @@ static struct leaf *nextleaf(struct trie
 		if (IS_LEAF(trie))          /* trie w. just a leaf */
 			return (struct leaf *) trie;
 
-		p = (struct tnode*) trie;  /* Start */
+		p = (struct tnode *)trie;  /* Start */
 	} else
 		p = node_parent_rcu(c);
 
@@ -1762,8 +1797,9 @@ static int fn_trie_flush(struct fib_tabl
 	return found;
 }
 
-static void
-fn_trie_select_default(struct fib_table *tb, const struct flowi *flp, struct fib_result *res)
+static void fn_trie_select_default(struct fib_table *tb,
+				   const struct flowi *flp,
+				   struct fib_result *res)
 {
 	struct trie *t = (struct trie *) tb->tb_data;
 	int order, last_idx;
@@ -1834,7 +1870,8 @@ out:
 	rcu_read_unlock();
 }
 
-static int fn_trie_dump_fa(t_key key, int plen, struct list_head *fah, struct fib_table *tb,
+static int fn_trie_dump_fa(t_key key, int plen, struct list_head *fah,
+			   struct fib_table *tb,
 			   struct sk_buff *skb, struct netlink_callback *cb)
 {
 	int i, s_i;
@@ -1873,8 +1910,8 @@ static int fn_trie_dump_fa(t_key key, in
 	return skb->len;
 }
 
-static int fn_trie_dump_plen(struct trie *t, int plen, struct fib_table *tb, struct sk_buff *skb,
-			     struct netlink_callback *cb)
+static int fn_trie_dump_plen(struct trie *t, int plen, struct fib_table *tb,
+			     struct sk_buff *skb, struct netlink_callback *cb)
 {
 	int h, s_h;
 	struct list_head *fa_head;
@@ -1897,7 +1934,7 @@ static int fn_trie_dump_plen(struct trie
 		if (list_empty(fa_head))
 			continue;
 
-		if (fn_trie_dump_fa(l->key, plen, fa_head, tb, skb, cb)<0) {
+		if (fn_trie_dump_fa(l->key, plen, fa_head, tb, skb, cb) < 0) {
 			cb->args[3] = h;
 			return -1;
 		}
@@ -1906,7 +1943,8 @@ static int fn_trie_dump_plen(struct trie
 	return skb->len;
 }
 
-static int fn_trie_dump(struct fib_table *tb, struct sk_buff *skb, struct netlink_callback *cb)
+static int fn_trie_dump(struct fib_table *tb, struct sk_buff *skb,
+			struct netlink_callback *cb)
 {
 	int m, s_m;
 	struct trie *t = (struct trie *) tb->tb_data;
@@ -1921,7 +1959,7 @@ static int fn_trie_dump(struct fib_table
 			memset(&cb->args[3], 0,
 				sizeof(cb->args) - 3*sizeof(cb->args[0]));
 
-		if (fn_trie_dump_plen(t, 32-m, tb, skb, cb)<0) {
+		if (fn_trie_dump_plen(t, 32-m, tb, skb, cb) < 0) {
 			cb->args[2] = m;
 			goto out;
 		}
@@ -1936,7 +1974,8 @@ out:
 
 void __init fib_hash_init(void)
 {
-	fn_alias_kmem = kmem_cache_create("ip_fib_alias", sizeof(struct fib_alias),
+	fn_alias_kmem = kmem_cache_create("ip_fib_alias",
+					  sizeof(struct fib_alias),
 					  0, SLAB_PANIC, NULL);
 
 	trie_leaf_kmem = kmem_cache_create("ip_fib_trie",
@@ -1970,7 +2009,7 @@ struct fib_table *fib_hash_table(u32 id)
 	memset(t, 0, sizeof(*t));
 
 	if (id == RT_TABLE_LOCAL)
-		printk(KERN_INFO "IPv4 FIB: Using LC-trie version %s\n", VERSION);
+		pr_info("IPv4 FIB: Using LC-trie version %s\n", VERSION);
 
 	return tb;
 }
@@ -2104,7 +2143,8 @@ static void trie_show_stats(struct seq_f
 	else
 		avdepth = 0;
 
-	seq_printf(seq, "\tAver depth:     %u.%02d\n", avdepth / 100, avdepth % 100 );
+	seq_printf(seq, "\tAver depth:     %u.%02d\n",
+		   avdepth / 100, avdepth % 100);
 	seq_printf(seq, "\tMax depth:      %u\n", stat->maxdepth);
 
 	seq_printf(seq, "\tLeaves:         %u\n", stat->leaves);
@@ -2136,16 +2176,20 @@ static void trie_show_usage(struct seq_f
 			    const struct trie_use_stats *stats)
 {
 	seq_printf(seq, "\nCounters:\n---------\n");
-	seq_printf(seq,"gets = %u\n", stats->gets);
-	seq_printf(seq,"backtracks = %u\n", stats->backtrack);
-	seq_printf(seq,"semantic match passed = %u\n", stats->semantic_match_passed);
-	seq_printf(seq,"semantic match miss = %u\n", stats->semantic_match_miss);
-	seq_printf(seq,"null node hit= %u\n", stats->null_node_hit);
-	seq_printf(seq,"skipped node resize = %u\n\n", stats->resize_node_skipped);
+	seq_printf(seq, "gets = %u\n", stats->gets);
+	seq_printf(seq, "backtracks = %u\n", stats->backtrack);
+	seq_printf(seq, "semantic match passed = %u\n",
+		   stats->semantic_match_passed);
+	seq_printf(seq, "semantic match miss = %u\n",
+		   stats->semantic_match_miss);
+	seq_printf(seq, "null node hit= %u\n", stats->null_node_hit);
+	seq_printf(seq, "skipped node resize = %u\n\n",
+		   stats->resize_node_skipped);
 }
 #endif /*  CONFIG_IP_FIB_TRIE_STATS */
 
-static void fib_trie_show(struct seq_file *seq, const char *name, struct trie *trie)
+static void fib_trie_show(struct seq_file *seq, const char *name,
+			  struct trie *trie)
 {
 	struct trie_stat stat;
 
@@ -2163,7 +2207,8 @@ static int fib_triestat_seq_show(struct 
 	struct fib_table *tb;
 
 	seq_printf(seq,
-		   "Basic info: size of leaf: %Zd bytes, size of tnode: %Zd bytes.\n",
+		   "Basic info: size of leaf:"
+		   " %Zd bytes, size of tnode: %Zd bytes.\n",
 		   sizeof(struct leaf), sizeof(struct tnode));
 
 	tb = fib_get_table(net, RT_TABLE_LOCAL);
@@ -2436,10 +2481,11 @@ static int fib_route_seq_show(struct seq
 
 	if (iter->trie == iter->trie_local)
 		return 0;
+
 	if (IS_TNODE(l))
 		return 0;
 
-	for (i=32; i>=0; i--) {
+	for (i = 32; i >= 0; i--) {
 		struct leaf_info *li = find_leaf_info(l, i);
 		struct fib_alias *fa;
 		__be32 mask, prefix;
@@ -2466,7 +2512,8 @@ static int fib_route_seq_show(struct seq
 					 fi->fib_nh->nh_gw, flags, 0, 0,
 					 fi->fib_priority,
 					 mask,
-					 (fi->fib_advmss ? fi->fib_advmss + 40 : 0),
+					 (fi->fib_advmss ?
+					  fi->fib_advmss + 40 : 0),
 					 fi->fib_window,
 					 fi->fib_rtt >> 3);
 			else

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>

