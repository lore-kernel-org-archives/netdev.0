From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] [IPV4] fib_trie: size and statistics
Date: Mon, 14 Jan 2008 12:57:55 -0800
Message-ID: <20080114125755.6157a3bf@deepthought>
References: <20080112064646.282104074@linux-foundation.org>
	<20080112.205520.55747078.davem@davemloft.net>
	<4789A29C.6080000@linux-foundation.org>
	<20080112.214417.154179770.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: robert.olsson@its.uu.se, netdev@vger.kernel.org,
	stephen.hemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:46993 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750830AbYANVBK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 16:01:10 -0500
In-Reply-To: <20080112.214417.154179770.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Show number of entries in trie, the size field was being set but never used,
but it only counted leaves, not all entries. Refactor the two cases in
fib_triestat_seq_show into a single routine.

Note: the stat structure was being malloc'd but the stack usage isn't so
high (288 bytes) that it is worth the additional complexity.

Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>
---
Patch against current net-2.6.25

--- a/net/ipv4/fib_trie.c	2008-01-14 10:16:06.000000000 -0800
+++ b/net/ipv4/fib_trie.c	2008-01-14 10:30:11.000000000 -0800
@@ -148,10 +148,10 @@ struct trie_stat {
 
 struct trie {
 	struct node *trie;
+	unsigned int size;
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 	struct trie_use_stats stats;
 #endif
-	int size;
 };
 
 static void put_child(struct trie *t, struct tnode *tn, int i, struct node *n);
@@ -1045,7 +1045,6 @@ static struct list_head *fib_insert_node
 		insert_leaf_info(&l->list, li);
 		goto done;
 	}
-	t->size++;
 	l = leaf_new();
 
 	if (!l)
@@ -1258,6 +1257,8 @@ static int fn_trie_insert(struct fib_tab
 	list_add_tail_rcu(&new_fa->fa_list,
 			  (fa ? &fa->fa_list : fa_head));
 
+	t->size++;
+
 	rt_cache_flush(-1);
 	rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen, tb->tb_id,
 		  &cfg->fc_nlinfo, 0);
@@ -2128,50 +2129,34 @@ static void trie_show_usage(struct seq_f
 }
 #endif /*  CONFIG_IP_FIB_TRIE_STATS */
 
+static void fib_trie_show(struct seq_file *seq, const char *name, struct trie *trie)
+{
+	struct trie_stat stat;
+
+	seq_printf(seq, "%s: %d\n", name, trie->size);
+	trie_collect_stats(trie, &stat);
+	trie_show_stats(seq, &stat);
+#ifdef CONFIG_IP_FIB_TRIE_STATS
+	trie_show_usage(seq, &trie->stats);
+#endif
+}
 
 static int fib_triestat_seq_show(struct seq_file *seq, void *v)
 {
 	struct net *net = (struct net *)seq->private;
-	struct trie *trie_local, *trie_main;
-	struct trie_stat *stat;
 	struct fib_table *tb;
 
-	trie_local = NULL;
+	seq_printf(seq,
+		   "Basic info: size of leaf: %Zd bytes, size of tnode: %Zd bytes.\n",
+		   sizeof(struct leaf), sizeof(struct tnode));
+
 	tb = fib_get_table(net, RT_TABLE_LOCAL);
 	if (tb)
-		trie_local = (struct trie *) tb->tb_data;
-
-	trie_main = NULL;
+		fib_trie_show(seq, "Local", (struct trie *) tb->tb_data);
+
 	tb = fib_get_table(net, RT_TABLE_MAIN);
 	if (tb)
-		trie_main = (struct trie *) tb->tb_data;
-
-
-	stat = kmalloc(sizeof(*stat), GFP_KERNEL);
-	if (!stat)
-		return -ENOMEM;
-
-	seq_printf(seq, "Basic info: size of leaf: %Zd bytes, size of tnode: %Zd bytes.\n",
-		   sizeof(struct leaf), sizeof(struct tnode));
-
-	if (trie_local) {
-		seq_printf(seq, "Local:\n");
-		trie_collect_stats(trie_local, stat);
-		trie_show_stats(seq, stat);
-#ifdef CONFIG_IP_FIB_TRIE_STATS
-		trie_show_usage(seq, &trie_local->stats);
-#endif
-	}
-
-	if (trie_main) {
-		seq_printf(seq, "Main:\n");
-		trie_collect_stats(trie_main, stat);
-		trie_show_stats(seq, stat);
-#ifdef CONFIG_IP_FIB_TRIE_STATS
-		trie_show_usage(seq, &trie_main->stats);
-#endif
-	}
-	kfree(stat);
+		fib_trie_show(seq, "Main", (struct trie *) tb->tb_data);
 
 	return 0;
 }
