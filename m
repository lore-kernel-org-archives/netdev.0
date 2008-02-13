From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/3] fib_trie: move statistics to debugfs
Date: Wed, 13 Feb 2008 11:58:06 -0800
Message-ID: <20080213195929.781366896@vyatta.com>
References: <20080213195805.493794050@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:60850 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760059AbYBMUC2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Feb 2008 15:02:28 -0500
Content-Disposition: inline; filename=fib-trie-debugfs.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't want /proc/net/fib_trie and /proc/net/fib_triestat to become
permanent kernel space ABI issues, so move to the safer confines of debugfs.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/ipv4/Kconfig    |    9 ++-
 net/ipv4/fib_trie.c |  127 +++++++++++++++++++++++++++++++++-------------------
 2 files changed, 86 insertions(+), 50 deletions(-)

--- a/net/ipv4/Kconfig	2008-02-13 10:58:51.000000000 -0800
+++ b/net/ipv4/Kconfig	2008-02-13 10:59:06.000000000 -0800
@@ -85,11 +85,12 @@ endchoice
 config IP_FIB_HASH
 	def_bool ASK_IP_FIB_HASH || !IP_ADVANCED_ROUTER
 
-config IP_FIB_TRIE_STATS
-	bool "FIB TRIE statistics"
-	depends on IP_FIB_TRIE
+config IP_FIB_TRIE_DEBUG
+	bool "FIB TRIE debugging information"
+	depends on IP_FIB_TRIE && DEBUG_FS
 	---help---
-	  Keep track of statistics on structure of FIB TRIE table.
+	  Provides interface for looking at internal structure, and
+	  statistics on for the  FIB TRIE table.
 	  Useful for testing and measuring TRIE performance.
 
 config IP_MULTIPLE_TABLES
--- a/net/ipv4/fib_trie.c	2008-02-13 10:58:51.000000000 -0800
+++ b/net/ipv4/fib_trie.c	2008-02-13 11:33:43.000000000 -0800
@@ -68,6 +68,7 @@
 #include <linux/netdevice.h>
 #include <linux/if_arp.h>
 #include <linux/proc_fs.h>
+#include <linux/debugfs.h>
 #include <linux/rcupdate.h>
 #include <linux/skbuff.h>
 #include <linux/netlink.h>
@@ -126,7 +127,8 @@ struct tnode {
 	struct node *child[0];
 };
 
-#ifdef CONFIG_IP_FIB_TRIE_STATS
+#ifdef CONFIG_IP_FIB_TRIE_DEBUG
+
 struct trie_use_stats {
 	unsigned int gets;
 	unsigned int backtrack;
@@ -135,7 +137,6 @@ struct trie_use_stats {
 	unsigned int null_node_hit;
 	unsigned int resize_node_skipped;
 };
-#endif
 
 struct trie_stat {
 	unsigned int totdepth;
@@ -146,10 +147,11 @@ struct trie_stat {
 	unsigned int prefixes;
 	unsigned int nodesizes[MAX_STAT_DEPTH];
 };
+#endif
 
 struct trie {
 	struct node *trie;
-#ifdef CONFIG_IP_FIB_TRIE_STATS
+#ifdef CONFIG_IP_FIB_TRIE_DEBUG
 	struct trie_use_stats stats;
 #endif
 };
@@ -588,7 +590,7 @@ static struct node *resize(struct trie *
 
 		if (IS_ERR(tn)) {
 			tn = old_tn;
-#ifdef CONFIG_IP_FIB_TRIE_STATS
+#ifdef CONFIG_IP_FIB_TRIE_DEBUG
 			t->stats.resize_node_skipped++;
 #endif
 			break;
@@ -631,7 +633,7 @@ static struct node *resize(struct trie *
 		tn = halve(t, tn);
 		if (IS_ERR(tn)) {
 			tn = old_tn;
-#ifdef CONFIG_IP_FIB_TRIE_STATS
+#ifdef CONFIG_IP_FIB_TRIE_DEBUG
 			t->stats.resize_node_skipped++;
 #endif
 			break;
@@ -1341,7 +1343,7 @@ static int check_leaf(struct trie *t, st
 		err = fib_semantic_match(&li->falh, flp, res,
 					 htonl(l->key), mask, plen);
 
-#ifdef CONFIG_IP_FIB_TRIE_STATS
+#ifdef CONFIG_IP_FIB_TRIE_DEBUG
 		if (err <= 0)
 			t->stats.semantic_match_passed++;
 		else
@@ -1376,7 +1378,7 @@ static int fn_trie_lookup(struct fib_tab
 	if (!n)
 		goto failed;
 
-#ifdef CONFIG_IP_FIB_TRIE_STATS
+#ifdef CONFIG_IP_FIB_TRIE_DEBUG
 	t->stats.gets++;
 #endif
 
@@ -1403,7 +1405,7 @@ static int fn_trie_lookup(struct fib_tab
 		n = tnode_get_child(pn, cindex);
 
 		if (n == NULL) {
-#ifdef CONFIG_IP_FIB_TRIE_STATS
+#ifdef CONFIG_IP_FIB_TRIE_DEBUG
 			t->stats.null_node_hit++;
 #endif
 			goto backtrace;
@@ -1546,7 +1548,7 @@ backtrace:
 			pn = parent;
 			chopped_off = 0;
 
-#ifdef CONFIG_IP_FIB_TRIE_STATS
+#ifdef CONFIG_IP_FIB_TRIE_DEBUG
 			t->stats.backtrack++;
 #endif
 			goto backtrace;
@@ -2022,7 +2024,8 @@ struct fib_table *fib_hash_table(u32 id)
 	return tb;
 }
 
-#ifdef CONFIG_PROC_FS
+#ifdef CONFIG_IP_FIB_TRIE_DEBUG
+
 /* Depth first Trie walk iterator */
 struct fib_trie_iter {
 	struct seq_net_private p;
@@ -2147,7 +2150,7 @@ static void trie_collect_stats(struct tr
 }
 
 /*
- *	This outputs /proc/net/fib_triestats
+ *	This outputs debugfs/fib/triestats
  */
 static void trie_show_stats(struct seq_file *seq, struct trie_stat *stat)
 {
@@ -2189,7 +2192,6 @@ static void trie_show_stats(struct seq_f
 	seq_printf(seq, "Total size: %u  kB\n", (bytes + 1023) / 1024);
 }
 
-#ifdef CONFIG_IP_FIB_TRIE_STATS
 static void trie_show_usage(struct seq_file *seq,
 			    const struct trie_use_stats *stats)
 {
@@ -2204,7 +2206,7 @@ static void trie_show_usage(struct seq_f
 	seq_printf(seq, "skipped node resize = %u\n\n",
 		   stats->resize_node_skipped);
 }
-#endif /*  CONFIG_IP_FIB_TRIE_STATS */
+
 
 static void fib_trie_show(struct seq_file *seq, const char *name,
 			  struct trie *trie)
@@ -2214,9 +2216,7 @@ static void fib_trie_show(struct seq_fil
 	trie_collect_stats(trie, &stat);
 	seq_printf(seq, "%s:\n", name);
 	trie_show_stats(seq, &stat);
-#ifdef CONFIG_IP_FIB_TRIE_STATS
 	trie_show_usage(seq, &trie->stats);
-#endif
 }
 
 static int fib_triestat_seq_show(struct seq_file *seq, void *v)
@@ -2242,18 +2242,12 @@ static int fib_triestat_seq_show(struct 
 
 static int fib_triestat_seq_open(struct inode *inode, struct file *file)
 {
-	int err;
-	struct net *net;
+	struct net *net = maybe_get_net((struct net *)inode->i_private);
 
-	net = get_proc_net(inode);
-	if (net == NULL)
+	if (!net)
 		return -ENXIO;
-	err = single_open(file, fib_triestat_seq_show, net);
-	if (err < 0) {
-		put_net(net);
-		return err;
-	}
-	return 0;
+
+	return single_open(file, fib_triestat_seq_show, net);
 }
 
 static int fib_triestat_seq_release(struct inode *ino, struct file *f)
@@ -2447,8 +2441,19 @@ static const struct seq_operations fib_t
 
 static int fib_trie_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open_net(inode, file, &fib_trie_seq_ops,
-			    sizeof(struct fib_trie_iter));
+	struct net *net = maybe_get_net((struct net *)inode->i_private);
+	struct fib_trie_iter *iter;
+
+	if (!net)
+		return -ENXIO;
+
+	iter = __seq_open_private(file, &fib_trie_seq_ops, sizeof(*iter));
+	if (!iter) {
+		put_net(net);
+		return -ENOMEM;
+	}
+	iter->p.net = net;
+	return 0;
 }
 
 static const struct file_operations fib_trie_fops = {
@@ -2459,6 +2464,51 @@ static const struct file_operations fib_
 	.release = seq_release_net,
 };
 
+
+static struct dentry *fib_debug, *trie_debug, *triestat_debug;
+
+static void __net_init trie_debug_init(struct net *net)
+{
+	fib_debug = debugfs_create_dir("fib", NULL);
+	if (!fib_debug || IS_ERR(fib_debug))
+		goto out1;
+
+	trie_debug = debugfs_create_file("trie", S_IRUGO, fib_debug,
+					 net, &fib_trie_fops);
+	if (!trie_debug || IS_ERR(trie_debug))
+		goto out2;
+
+	triestat_debug = debugfs_create_file("triestat", S_IRUGO, fib_debug,
+					     net, &fib_triestat_fops);
+	if (!triestat_debug || IS_ERR(triestat_debug))
+		goto out3;
+
+	hold_net(net);
+	return;
+out3:
+	debugfs_remove(trie_debug);
+out2:
+	debugfs_remove(fib_debug);
+out1:
+	fib_debug = NULL;
+}
+
+static void __net_exit trie_debug_exit(struct net *net)
+{
+	if (!fib_debug)
+		return;
+
+	debugfs_remove(trie_debug);
+	debugfs_remove(triestat_debug);
+	debugfs_remove(fib_debug);
+	put_net(net);
+}
+#else
+#define trie_debug_init(n)
+#define trie_debug_exit(n)
+#endif
+
+#ifdef CONFIG_PROC_FS
 struct fib_route_iter {
 	struct seq_net_private p;
 	struct trie *main_trie;
@@ -2632,34 +2682,19 @@ static const struct file_operations fib_
 	.llseek = seq_lseek,
 	.release = seq_release_net,
 };
+#endif /* CONFIG_PROC_FS */
 
 int __net_init fib_proc_init(struct net *net)
 {
-	if (!proc_net_fops_create(net, "fib_trie", S_IRUGO, &fib_trie_fops))
-		goto out1;
-
-	if (!proc_net_fops_create(net, "fib_triestat", S_IRUGO,
-				  &fib_triestat_fops))
-		goto out2;
-
 	if (!proc_net_fops_create(net, "route", S_IRUGO, &fib_route_fops))
-		goto out3;
+		return -ENOMEM;
 
+	trie_debug_init(net);
 	return 0;
-
-out3:
-	proc_net_remove(net, "fib_triestat");
-out2:
-	proc_net_remove(net, "fib_trie");
-out1:
-	return -ENOMEM;
 }
 
 void __net_exit fib_proc_exit(struct net *net)
 {
-	proc_net_remove(net, "fib_trie");
-	proc_net_remove(net, "fib_triestat");
 	proc_net_remove(net, "route");
+	trie_debug_exit(net);
 }
-
-#endif /* CONFIG_PROC_FS */

-- 
Stephen Hemminger <shemminger@vyatta.com>

