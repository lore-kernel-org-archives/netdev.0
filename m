From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 01/17] fib_trie: Update usage stats to be percpu
 instead of global variables
Date: Wed, 31 Dec 2014 10:55:29 -0800
Message-ID: <20141231185529.3006.54531.stgit@ahduyck-vm-fedora20>
References: <20141231184649.3006.29958.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43797 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751801AbaLaSzb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Dec 2014 13:55:31 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sBVItUw7029057
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 13:55:30 -0500
Received: from [192.168.122.173] (ovpn-112-50.phx2.redhat.com [10.3.112.50])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sBVItTvb026121
	for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 13:55:29 -0500
In-Reply-To: <20141231184649.3006.29958.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The trie usage stats were currently being shared by all threads that were
calling fib_table_lookup.  As a result when multiple threads were
performing lookups simultaneously the trie would begin to cache bounce
between those threads.

In order to prevent this I have updated the usage stats to use a set of
percpu variables.  By doing this we should be able to avoid the cache
bouncing and still make use of these stats.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_frontend.c |    2 +
 net/ipv4/fib_trie.c     |   68 +++++++++++++++++++++++++++++++++--------------
 2 files changed, 49 insertions(+), 21 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 23104a3..6689020 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -67,7 +67,7 @@ static int __net_init fib4_rules_init(struct net *net)
 	return 0;
 
 fail:
-	kfree(local_table);
+	fib_free_table(local_table);
 	return -ENOMEM;
 }
 #else
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 18bcaf2..d3dbb48 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -153,7 +153,7 @@ struct trie_stat {
 struct trie {
 	struct rt_trie_node __rcu *trie;
 #ifdef CONFIG_IP_FIB_TRIE_STATS
-	struct trie_use_stats stats;
+	struct trie_use_stats __percpu *stats;
 #endif
 };
 
@@ -631,7 +631,7 @@ static struct rt_trie_node *resize(struct trie *t, struct tnode *tn)
 		if (IS_ERR(tn)) {
 			tn = old_tn;
 #ifdef CONFIG_IP_FIB_TRIE_STATS
-			t->stats.resize_node_skipped++;
+			this_cpu_inc(t->stats->resize_node_skipped);
 #endif
 			break;
 		}
@@ -658,7 +658,7 @@ static struct rt_trie_node *resize(struct trie *t, struct tnode *tn)
 		if (IS_ERR(tn)) {
 			tn = old_tn;
 #ifdef CONFIG_IP_FIB_TRIE_STATS
-			t->stats.resize_node_skipped++;
+			this_cpu_inc(t->stats->resize_node_skipped);
 #endif
 			break;
 		}
@@ -1357,7 +1357,7 @@ static int check_leaf(struct fib_table *tb, struct trie *t, struct leaf *l,
 			err = fib_props[fa->fa_type].error;
 			if (err) {
 #ifdef CONFIG_IP_FIB_TRIE_STATS
-				t->stats.semantic_match_passed++;
+				this_cpu_inc(t->stats->semantic_match_passed);
 #endif
 				return err;
 			}
@@ -1372,7 +1372,7 @@ static int check_leaf(struct fib_table *tb, struct trie *t, struct leaf *l,
 					continue;
 
 #ifdef CONFIG_IP_FIB_TRIE_STATS
-				t->stats.semantic_match_passed++;
+				this_cpu_inc(t->stats->semantic_match_passed);
 #endif
 				res->prefixlen = li->plen;
 				res->nh_sel = nhsel;
@@ -1388,7 +1388,7 @@ static int check_leaf(struct fib_table *tb, struct trie *t, struct leaf *l,
 		}
 
 #ifdef CONFIG_IP_FIB_TRIE_STATS
-		t->stats.semantic_match_miss++;
+		this_cpu_inc(t->stats->semantic_match_miss);
 #endif
 	}
 
@@ -1399,6 +1399,9 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 		     struct fib_result *res, int fib_flags)
 {
 	struct trie *t = (struct trie *) tb->tb_data;
+#ifdef CONFIG_IP_FIB_TRIE_STATS
+	struct trie_use_stats __percpu *stats = t->stats;
+#endif
 	int ret;
 	struct rt_trie_node *n;
 	struct tnode *pn;
@@ -1417,7 +1420,7 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 		goto failed;
 
 #ifdef CONFIG_IP_FIB_TRIE_STATS
-	t->stats.gets++;
+	this_cpu_inc(stats->gets);
 #endif
 
 	/* Just a leaf? */
@@ -1441,7 +1444,7 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 
 		if (n == NULL) {
 #ifdef CONFIG_IP_FIB_TRIE_STATS
-			t->stats.null_node_hit++;
+			this_cpu_inc(stats->null_node_hit);
 #endif
 			goto backtrace;
 		}
@@ -1576,7 +1579,7 @@ backtrace:
 			chopped_off = 0;
 
 #ifdef CONFIG_IP_FIB_TRIE_STATS
-			t->stats.backtrack++;
+			this_cpu_inc(stats->backtrack);
 #endif
 			goto backtrace;
 		}
@@ -1830,6 +1833,11 @@ int fib_table_flush(struct fib_table *tb)
 
 void fib_free_table(struct fib_table *tb)
 {
+#ifdef CONFIG_IP_FIB_TRIE_STATS
+	struct trie *t = (struct trie *)tb->tb_data;
+
+	free_percpu(t->stats);
+#endif /* CONFIG_IP_FIB_TRIE_STATS */
 	kfree(tb);
 }
 
@@ -1973,7 +1981,14 @@ struct fib_table *fib_trie_table(u32 id)
 	tb->tb_num_default = 0;
 
 	t = (struct trie *) tb->tb_data;
-	memset(t, 0, sizeof(*t));
+	RCU_INIT_POINTER(t->trie, NULL);
+#ifdef CONFIG_IP_FIB_TRIE_STATS
+	t->stats = alloc_percpu(struct trie_use_stats);
+	if (!t->stats) {
+		kfree(tb);
+		tb = NULL;
+	}
+#endif
 
 	return tb;
 }
@@ -2139,18 +2154,31 @@ static void trie_show_stats(struct seq_file *seq, struct trie_stat *stat)
 
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 static void trie_show_usage(struct seq_file *seq,
-			    const struct trie_use_stats *stats)
+			    const struct trie_use_stats __percpu *stats)
 {
+	struct trie_use_stats s = { 0 };
+	int cpu;
+
+	/* loop through all of the CPUs and gather up the stats */
+	for_each_possible_cpu(cpu) {
+		const struct trie_use_stats *pcpu = per_cpu_ptr(stats, cpu);
+
+		s.gets += pcpu->gets;
+		s.backtrack += pcpu->backtrack;
+		s.semantic_match_passed += pcpu->semantic_match_passed;
+		s.semantic_match_miss += pcpu->semantic_match_miss;
+		s.null_node_hit += pcpu->null_node_hit;
+		s.resize_node_skipped += pcpu->resize_node_skipped;
+	}
+
 	seq_printf(seq, "\nCounters:\n---------\n");
-	seq_printf(seq, "gets = %u\n", stats->gets);
-	seq_printf(seq, "backtracks = %u\n", stats->backtrack);
+	seq_printf(seq, "gets = %u\n", s.gets);
+	seq_printf(seq, "backtracks = %u\n", s.backtrack);
 	seq_printf(seq, "semantic match passed = %u\n",
-		   stats->semantic_match_passed);
-	seq_printf(seq, "semantic match miss = %u\n",
-		   stats->semantic_match_miss);
-	seq_printf(seq, "null node hit= %u\n", stats->null_node_hit);
-	seq_printf(seq, "skipped node resize = %u\n\n",
-		   stats->resize_node_skipped);
+		   s.semantic_match_passed);
+	seq_printf(seq, "semantic match miss = %u\n", s.semantic_match_miss);
+	seq_printf(seq, "null node hit= %u\n", s.null_node_hit);
+	seq_printf(seq, "skipped node resize = %u\n\n", s.resize_node_skipped);
 }
 #endif /*  CONFIG_IP_FIB_TRIE_STATS */
 
@@ -2191,7 +2219,7 @@ static int fib_triestat_seq_show(struct seq_file *seq, void *v)
 			trie_collect_stats(t, &stat);
 			trie_show_stats(seq, &stat);
 #ifdef CONFIG_IP_FIB_TRIE_STATS
-			trie_show_usage(seq, &t->stats);
+			trie_show_usage(seq, t->stats);
 #endif
 		}
 	}
