From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [IPV4 3/9] fib_trie: compute size when needed
Date: Tue, 22 Jan 2008 15:37:36 -0800
Message-ID: <20080122233926.841440568@linux-foundation.org>
References: <20080122233733.404145234@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:33092 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757059AbYAWAJw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2008 19:09:52 -0500
Content-Disposition: inline; filename=fib-trie-stats-x.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compute the number of prefixes when needed, rather than doing bookeeping.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv4/fib_trie.c	2008-01-21 17:45:03.000000000 -0800
+++ b/net/ipv4/fib_trie.c	2008-01-21 17:45:03.000000000 -0800
@@ -143,12 +143,12 @@ struct trie_stat {
 	unsigned int tnodes;
 	unsigned int leaves;
 	unsigned int nullpointers;
+	unsigned int prefixes;
 	unsigned int nodesizes[MAX_STAT_DEPTH];
 };
 
 struct trie {
 	struct node *trie;
-	unsigned int size;
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 	struct trie_use_stats stats;
 #endif
@@ -1289,8 +1289,6 @@ static int fn_trie_insert(struct fib_tab
 	list_add_tail_rcu(&new_fa->fa_list,
 			  (fa ? &fa->fa_list : fa_head));
 
-	t->size++;
-
 	rt_cache_flush(-1);
 	rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen, tb->tb_id,
 		  &cfg->fc_nlinfo, 0);
@@ -1576,9 +1574,6 @@ static int trie_leaf_remove(struct trie 
 	 * Key found.
 	 * Remove the leaf and rebalance the tree
 	 */
-
-	t->size--;
-
 	tp = node_parent(n);
 	tnode_free((struct tnode *) n);
 
@@ -2111,10 +2106,17 @@ static void trie_collect_stats(struct tr
 	for (n = fib_trie_get_first(&iter, t); n;
 	     n = fib_trie_get_next(&iter)) {
 		if (IS_LEAF(n)) {
+			struct leaf *l = (struct leaf *)n;
+			struct leaf_info *li;
+			struct hlist_node *tmp;
+
 			s->leaves++;
 			s->totdepth += iter.depth;
 			if (iter.depth > s->maxdepth)
 				s->maxdepth = iter.depth;
+
+			hlist_for_each_entry_rcu(li, tmp, &l->list, hlist)
+				++s->prefixes;
 		} else {
 			const struct tnode *tn = (const struct tnode *) n;
 			int i;
@@ -2148,8 +2150,11 @@ static void trie_show_stats(struct seq_f
 	seq_printf(seq, "\tMax depth:      %u\n", stat->maxdepth);
 
 	seq_printf(seq, "\tLeaves:         %u\n", stat->leaves);
-
 	bytes = sizeof(struct leaf) * stat->leaves;
+
+	seq_printf(seq, "\tPrefixes:       %u\n", stat->prefixes);
+	bytes += sizeof(struct leaf_info) * stat->prefixes;
+
 	seq_printf(seq, "\tInternal nodes: %u\n\t", stat->tnodes);
 	bytes += sizeof(struct tnode) * stat->tnodes;
 
@@ -2193,8 +2198,8 @@ static void fib_trie_show(struct seq_fil
 {
 	struct trie_stat stat;
 
-	seq_printf(seq, "%s: %d\n", name, trie->size);
 	trie_collect_stats(trie, &stat);
+	seq_printf(seq, "%s:\n", name);
 	trie_show_stats(seq, &stat);
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 	trie_show_usage(seq, &trie->stats);

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>

