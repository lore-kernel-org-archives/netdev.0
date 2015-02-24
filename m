From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 20/29] fib_trie: Push net pointer down into fib_trie
 insert/delete/flush calls
Date: Tue, 24 Feb 2015 12:50:10 -0800
Message-ID: <20150224205010.26106.84801.stgit@ahduyck-vm-fedora20>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54146 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752979AbbBXUuM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 15:50:12 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKoBCO009049
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:50:11 -0500
Received: from [192.168.122.173] (ovpn-112-73.phx2.redhat.com [10.3.112.73])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKoAsq030567
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:50:10 -0500
In-Reply-To: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to make use of fib_table_replace it is necessary to pass the net
pointer to the point where the call is made.  This is the first pass at
pushing this down to where it is need in the resize function.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 include/net/ip_fib.h    |    9 ++++---
 net/ipv4/fib_frontend.c |   39 +++++++++++++++++++++++++------
 net/ipv4/fib_trie.c     |   59 +++++++++++++++++++++++++----------------------
 3 files changed, 68 insertions(+), 39 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 8aa6f82..52f76c5 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -190,14 +190,15 @@ struct fib_table {
 
 int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 		     struct fib_result *res, int fib_flags);
-int fib_table_insert(struct fib_table *, struct fib_config *);
-int fib_table_delete(struct fib_table *, struct fib_config *);
+int fib_table_insert(struct net *net, struct fib_table *, struct fib_config *);
+int fib_table_delete(struct net *net, struct fib_table *, struct fib_config *);
 int fib_table_dump(struct fib_table *table, struct sk_buff *skb,
 		   struct netlink_callback *cb);
-int fib_table_flush(struct fib_table *table);
+int fib_table_flush(struct net *net, struct fib_table *table);
 void fib_free_table(struct fib_table *tb);
 
-
+void fib_replace_table(struct net *net, struct fib_table *old,
+		       struct fib_table *new);
 
 #ifndef CONFIG_IP_MULTIPLE_TABLES
 
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 220c4b4..71979ed 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -126,6 +126,29 @@ struct fib_table *fib_get_table(struct net *net, u32 id)
 }
 #endif /* CONFIG_IP_MULTIPLE_TABLES */
 
+void fib_replace_table(struct net *net, struct fib_table *old,
+		       struct fib_table *new)
+{
+#ifdef CONFIG_IP_MULTIPLE_TABLES
+	switch (new->tb_id) {
+	case RT_TABLE_LOCAL:
+		rcu_assign_pointer(net->ipv4.fib_local, new);
+		break;
+	case RT_TABLE_MAIN:
+		rcu_assign_pointer(net->ipv4.fib_main, new);
+		break;
+	case RT_TABLE_DEFAULT:
+		rcu_assign_pointer(net->ipv4.fib_default, new);
+		break;
+	default:
+		break;
+	}
+
+#endif
+	/* replace the old table in the hlist */
+	hlist_replace_rcu(&old->tb_hlist, &new->tb_hlist);
+}
+
 static void fib_flush(struct net *net)
 {
 	int flushed = 0;
@@ -137,7 +160,7 @@ static void fib_flush(struct net *net)
 		struct fib_table *tb;
 
 		hlist_for_each_entry_safe(tb, tmp, head, tb_hlist)
-			flushed += fib_table_flush(tb);
+			flushed += fib_table_flush(net, tb);
 	}
 
 	if (flushed)
@@ -499,13 +522,13 @@ int ip_rt_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 			if (cmd == SIOCDELRT) {
 				tb = fib_get_table(net, cfg.fc_table);
 				if (tb)
-					err = fib_table_delete(tb, &cfg);
+					err = fib_table_delete(net, tb, &cfg);
 				else
 					err = -ESRCH;
 			} else {
 				tb = fib_new_table(net, cfg.fc_table);
 				if (tb)
-					err = fib_table_insert(tb, &cfg);
+					err = fib_table_insert(net, tb, &cfg);
 				else
 					err = -ENOBUFS;
 			}
@@ -620,7 +643,7 @@ static int inet_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 		goto errout;
 	}
 
-	err = fib_table_delete(tb, &cfg);
+	err = fib_table_delete(net, tb, &cfg);
 errout:
 	return err;
 }
@@ -642,7 +665,7 @@ static int inet_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 		goto errout;
 	}
 
-	err = fib_table_insert(tb, &cfg);
+	err = fib_table_insert(net, tb, &cfg);
 errout:
 	return err;
 }
@@ -729,9 +752,9 @@ static void fib_magic(int cmd, int type, __be32 dst, int dst_len, struct in_ifad
 		cfg.fc_scope = RT_SCOPE_HOST;
 
 	if (cmd == RTM_NEWROUTE)
-		fib_table_insert(tb, &cfg);
+		fib_table_insert(net, tb, &cfg);
 	else
-		fib_table_delete(tb, &cfg);
+		fib_table_delete(net, tb, &cfg);
 }
 
 void fib_add_ifaddr(struct in_ifaddr *ifa)
@@ -1128,7 +1151,7 @@ static void ip_fib_net_exit(struct net *net)
 		 * tnodes at the root as the table shrinks.
 		 */
 		hlist_for_each_entry_safe(tb, tmp, head, tb_hlist)
-			fib_table_flush(tb);
+			fib_table_flush(net, tb);
 
 		hlist_for_each_entry_safe(tb, tmp, head, tb_hlist) {
 #ifdef CONFIG_IP_MULTIPLE_TABLES
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 432a875..2db318e 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -143,7 +143,8 @@ struct trie {
 	struct rcu_head rcu;
 };
 
-static struct key_vector *resize(struct trie *t, struct key_vector *tn);
+static struct key_vector *resize(struct net *net, struct trie *t,
+				 struct key_vector *tn);
 static size_t tnode_free_size;
 
 /*
@@ -468,7 +469,7 @@ static void tnode_free(struct key_vector *tn)
 	}
 }
 
-static struct key_vector *replace(struct trie *t,
+static struct key_vector *replace(struct net *net, struct trie *t,
 				  struct key_vector *oldtnode,
 				  struct key_vector *tn)
 {
@@ -491,13 +492,13 @@ static struct key_vector *replace(struct trie *t,
 
 		/* resize child node */
 		if (tnode_full(tn, inode))
-			tn = resize(t, inode);
+			tn = resize(net, t, inode);
 	}
 
 	return tp;
 }
 
-static struct key_vector *inflate(struct trie *t,
+static struct key_vector *inflate(struct net *net, struct trie *t,
 				  struct key_vector *oldtnode)
 {
 	struct key_vector *tn;
@@ -585,7 +586,7 @@ static struct key_vector *inflate(struct trie *t,
 	}
 
 	/* setup the parent pointers into and out of this node */
-	return replace(t, oldtnode, tn);
+	return replace(net, t, oldtnode, tn);
 nomem:
 	/* all pointers should be clean so we are done */
 	tnode_free(tn);
@@ -593,7 +594,7 @@ notnode:
 	return NULL;
 }
 
-static struct key_vector *halve(struct trie *t,
+static struct key_vector *halve(struct net *net, struct trie *t,
 				struct key_vector *oldtnode)
 {
 	struct key_vector *tn;
@@ -640,7 +641,7 @@ static struct key_vector *halve(struct trie *t,
 	}
 
 	/* setup the parent pointers into and out of this node */
-	return replace(t, oldtnode, tn);
+	return replace(net, t, oldtnode, tn);
 nomem:
 	/* all pointers should be clean so we are done */
 	tnode_free(tn);
@@ -648,7 +649,7 @@ notnode:
 	return NULL;
 }
 
-static struct key_vector *collapse(struct trie *t,
+static struct key_vector *collapse(struct net *net, struct trie *t,
 				   struct key_vector *oldtnode)
 {
 	struct key_vector *n, *tp;
@@ -805,7 +806,8 @@ static inline bool should_collapse(struct key_vector *tn)
 }
 
 #define MAX_WORK 10
-static struct key_vector *resize(struct trie *t, struct key_vector *tn)
+static struct key_vector *resize(struct net *net, struct trie *t,
+				 struct key_vector *tn)
 {
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 	struct trie_use_stats __percpu *stats = t->stats;
@@ -827,7 +829,7 @@ static struct key_vector *resize(struct trie *t, struct key_vector *tn)
 	 * nonempty nodes that are above the threshold.
 	 */
 	while (should_inflate(tp, tn) && max_work) {
-		tp = inflate(t, tn);
+		tp = inflate(net, t, tn);
 		if (!tp) {
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 			this_cpu_inc(stats->resize_node_skipped);
@@ -847,7 +849,7 @@ static struct key_vector *resize(struct trie *t, struct key_vector *tn)
 	 * node is above threshold.
 	 */
 	while (should_halve(tp, tn) && max_work) {
-		tp = halve(t, tn);
+		tp = halve(net, t, tn);
 		if (!tp) {
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 			this_cpu_inc(stats->resize_node_skipped);
@@ -861,7 +863,7 @@ static struct key_vector *resize(struct trie *t, struct key_vector *tn)
 
 	/* Only one child remains */
 	if (should_collapse(tn))
-		return collapse(t, tn);
+		return collapse(net, t, tn);
 
 	/* update parent in case inflate or halve failed */
 	tp = node_parent(tn);
@@ -961,16 +963,16 @@ static struct fib_alias *fib_find_alias(struct hlist_head *fah, u8 slen,
 	return NULL;
 }
 
-static struct fib_table *trie_rebalance(struct trie *t,
+static struct fib_table *trie_rebalance(struct net *net, struct trie *t,
 					struct key_vector *tn)
 {
 	while (!IS_TRIE(tn))
-		tn = resize(t, tn);
+		tn = resize(net, t, tn);
 
 	return table_info(tn);
 }
 
-static struct fib_table *fib_insert_node(struct trie *t,
+static struct fib_table *fib_insert_node(struct net *net, struct trie *t,
 					 struct key_vector *tp,
 					 struct fib_alias *new,
 					 t_key key)
@@ -1013,14 +1015,14 @@ static struct fib_table *fib_insert_node(struct trie *t,
 	NODE_INIT_PARENT(l, tp);
 	put_child_root(tp, key, l);
 
-	return trie_rebalance(t, tp);
+	return trie_rebalance(net, t, tp);
 notnode:
 	node_free(l);
 noleaf:
 	return NULL;
 }
 
-static struct fib_table *fib_insert_alias(struct trie *t,
+static struct fib_table *fib_insert_alias(struct net *net, struct trie *t,
 					  struct key_vector *tp,
 					  struct key_vector *l,
 					  struct fib_alias *new,
@@ -1028,7 +1030,7 @@ static struct fib_table *fib_insert_alias(struct trie *t,
 					  t_key key)
 {
 	if (!l)
-		return fib_insert_node(t, tp, new, key);
+		return fib_insert_node(net, t, tp, new, key);
 
 	if (!fa) {
 		struct fib_alias *last;
@@ -1055,7 +1057,8 @@ static struct fib_table *fib_insert_alias(struct trie *t,
 }
 
 /* Caller must hold RTNL. */
-int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
+int fib_table_insert(struct net *net, struct fib_table *tb,
+		     struct fib_config *cfg)
 {
 	struct trie *t = (struct trie *)tb->tb_data;
 	struct fib_alias *fa, *new_fa;
@@ -1185,7 +1188,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 
 	/* Insert new entry to the list. */
 	err = -ENOMEM;
-	tb = fib_insert_alias(t, tp, l, new_fa, fa, key);
+	tb = fib_insert_alias(net, t, tp, l, new_fa, fa, key);
 	if (!tb)
 		goto out_free_new_fa;
 
@@ -1384,8 +1387,9 @@ found:
 }
 EXPORT_SYMBOL_GPL(fib_table_lookup);
 
-static void fib_remove_alias(struct trie *t, struct key_vector *tp,
-			     struct key_vector *l, struct fib_alias *old)
+static void fib_remove_alias(struct net *net, struct trie *t,
+			     struct key_vector *tp, struct key_vector *l,
+			     struct fib_alias *old)
 {
 	/* record the location of the previous list_info entry */
 	struct hlist_node **pprev = old->fa_list.pprev;
@@ -1400,7 +1404,7 @@ static void fib_remove_alias(struct trie *t, struct key_vector *tp,
 	if (hlist_empty(&l->leaf)) {
 		put_child_root(tp, l->key, NULL);
 		node_free(l);
-		trie_rebalance(t, tp);
+		trie_rebalance(net, t, tp);
 		return;
 	}
 
@@ -1414,7 +1418,8 @@ static void fib_remove_alias(struct trie *t, struct key_vector *tp,
 }
 
 /* Caller must hold RTNL. */
-int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
+int fib_table_delete(struct net *net, struct fib_table *tb,
+		     struct fib_config *cfg)
 {
 	struct trie *t = (struct trie *) tb->tb_data;
 	struct fib_alias *fa, *fa_to_delete;
@@ -1471,7 +1476,7 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 	if (!plen)
 		tb->tb_num_default--;
 
-	fib_remove_alias(t, tp, l, fa_to_delete);
+	fib_remove_alias(net, t, tp, l, fa_to_delete);
 
 	if (fa_to_delete->fa_state & FA_S_ACCESSED)
 		rt_cache_flush(cfg->fc_nlinfo.nl_net);
@@ -1540,7 +1545,7 @@ found:
 }
 
 /* Caller must hold RTNL. */
-int fib_table_flush(struct fib_table *tb)
+int fib_table_flush(struct net *net, struct fib_table *tb)
 {
 	struct trie *t = (struct trie *)tb->tb_data;
 	struct key_vector *pn = t->kv;
@@ -1562,7 +1567,7 @@ int fib_table_flush(struct fib_table *tb)
 				break;
 
 			/* resize completed node */
-			pn = resize(t, pn);
+			pn = resize(net, t, pn);
 			cindex = get_index(pkey, pn);
 
 			continue;
