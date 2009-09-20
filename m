From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] ipv4: fib table algorithm performance improvement
Date: Sun, 20 Sep 2009 13:35:36 -0700
Message-ID: <20090920133536.1511a2ad@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39046 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750918AbZITUfj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Sep 2009 16:35:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The FIB algorithim for IPV4 is set at compile time, but kernel goes through
the overhead of function call indirection at runtime. Save some
cycles by turning the indirect calls to direct calls to either
hash or trie code.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/include/net/ip_fib.h	2009-09-20 12:16:02.819467348 -0700
+++ b/include/net/ip_fib.h	2009-09-20 12:37:53.391940040 -0700
@@ -144,18 +144,21 @@ struct fib_table {
 	struct hlist_node tb_hlist;
 	u32		tb_id;
 	int		tb_default;
-	int		(*tb_lookup)(struct fib_table *tb, const struct flowi *flp, struct fib_result *res);
-	int		(*tb_insert)(struct fib_table *, struct fib_config *);
-	int		(*tb_delete)(struct fib_table *, struct fib_config *);
-	int		(*tb_dump)(struct fib_table *table, struct sk_buff *skb,
-				     struct netlink_callback *cb);
-	int		(*tb_flush)(struct fib_table *table);
-	void		(*tb_select_default)(struct fib_table *table,
-					     const struct flowi *flp, struct fib_result *res);
-
 	unsigned char	tb_data[0];
 };
 
+extern int fib_table_lookup(struct fib_table *tb, const struct flowi *flp,
+			    struct fib_result *res);
+extern int fib_table_insert(struct fib_table *, struct fib_config *);
+extern int fib_table_delete(struct fib_table *, struct fib_config *);
+extern int fib_table_dump(struct fib_table *table, struct sk_buff *skb,
+			  struct netlink_callback *cb);
+extern int fib_table_flush(struct fib_table *table);
+extern void fib_table_select_default(struct fib_table *table,
+				     const struct flowi *flp,
+				     struct fib_result *res);
+
+
 #ifndef CONFIG_IP_MULTIPLE_TABLES
 
 #define TABLE_LOCAL_INDEX	0
@@ -182,11 +185,11 @@ static inline int fib_lookup(struct net 
 	struct fib_table *table;
 
 	table = fib_get_table(net, RT_TABLE_LOCAL);
-	if (!table->tb_lookup(table, flp, res))
+	if (!fib_table_lookup(table, flp, res))
 		return 0;
 
 	table = fib_get_table(net, RT_TABLE_MAIN);
-	if (!table->tb_lookup(table, flp, res))
+	if (!fib_table_lookup(table, flp, res))
 		return 0;
 	return -ENETUNREACH;
 }
--- a/net/ipv4/fib_frontend.c	2009-09-20 12:23:52.199466411 -0700
+++ b/net/ipv4/fib_frontend.c	2009-09-20 12:26:45.969439904 -0700
@@ -125,7 +125,7 @@ void fib_select_default(struct net *net,
 #endif
 	tb = fib_get_table(net, table);
 	if (FIB_RES_GW(*res) && FIB_RES_NH(*res).nh_scope == RT_SCOPE_LINK)
-		tb->tb_select_default(tb, flp, res);
+		fib_table_select_default(tb, flp, res);
 }
 
 static void fib_flush(struct net *net)
@@ -139,7 +139,7 @@ static void fib_flush(struct net *net)
 	for (h = 0; h < FIB_TABLE_HASHSZ; h++) {
 		head = &net->ipv4.fib_table_hash[h];
 		hlist_for_each_entry(tb, node, head, tb_hlist)
-			flushed += tb->tb_flush(tb);
+			flushed += fib_table_flush(tb);
 	}
 
 	if (flushed)
@@ -162,7 +162,7 @@ struct net_device * ip_dev_find(struct n
 #endif
 
 	local_table = fib_get_table(net, RT_TABLE_LOCAL);
-	if (!local_table || local_table->tb_lookup(local_table, &fl, &res))
+	if (!local_table || fib_table_lookup(local_table, &fl, &res))
 		return NULL;
 	if (res.type != RTN_LOCAL)
 		goto out;
@@ -200,7 +200,7 @@ static inline unsigned __inet_dev_addr_t
 	local_table = fib_get_table(net, RT_TABLE_LOCAL);
 	if (local_table) {
 		ret = RTN_UNICAST;
-		if (!local_table->tb_lookup(local_table, &fl, &res)) {
+		if (!fib_table_lookup(local_table, &fl, &res)) {
 			if (!dev || dev == res.fi->fib_dev)
 				ret = res.type;
 			fib_res_put(&res);
@@ -473,13 +473,13 @@ int ip_rt_ioctl(struct net *net, unsigne
 			if (cmd == SIOCDELRT) {
 				tb = fib_get_table(net, cfg.fc_table);
 				if (tb)
-					err = tb->tb_delete(tb, &cfg);
+					err = fib_table_delete(tb, &cfg);
 				else
 					err = -ESRCH;
 			} else {
 				tb = fib_new_table(net, cfg.fc_table);
 				if (tb)
-					err = tb->tb_insert(tb, &cfg);
+					err = fib_table_insert(tb, &cfg);
 				else
 					err = -ENOBUFS;
 			}
@@ -594,7 +594,7 @@ static int inet_rtm_delroute(struct sk_b
 		goto errout;
 	}
 
-	err = tb->tb_delete(tb, &cfg);
+	err = fib_table_delete(tb, &cfg);
 errout:
 	return err;
 }
@@ -616,7 +616,7 @@ static int inet_rtm_newroute(struct sk_b
 		goto errout;
 	}
 
-	err = tb->tb_insert(tb, &cfg);
+	err = fib_table_insert(tb, &cfg);
 errout:
 	return err;
 }
@@ -647,7 +647,7 @@ static int inet_dump_fib(struct sk_buff 
 			if (dumped)
 				memset(&cb->args[2], 0, sizeof(cb->args) -
 						 2 * sizeof(cb->args[0]));
-			if (tb->tb_dump(tb, skb, cb) < 0)
+			if (fib_table_dump(tb, skb, cb) < 0)
 				goto out;
 			dumped = 1;
 next:
@@ -701,9 +701,9 @@ static void fib_magic(int cmd, int type,
 		cfg.fc_scope = RT_SCOPE_HOST;
 
 	if (cmd == RTM_NEWROUTE)
-		tb->tb_insert(tb, &cfg);
+		fib_table_insert(tb, &cfg);
 	else
-		tb->tb_delete(tb, &cfg);
+		fib_table_delete(tb, &cfg);
 }
 
 void fib_add_ifaddr(struct in_ifaddr *ifa)
@@ -832,7 +832,7 @@ static void nl_fib_lookup(struct fib_res
 		local_bh_disable();
 
 		frn->tb_id = tb->tb_id;
-		frn->err = tb->tb_lookup(tb, &fl, &res);
+		frn->err = fib_table_lookup(tb, &fl, &res);
 
 		if (!frn->err) {
 			frn->prefixlen = res.prefixlen;
@@ -1009,7 +1009,7 @@ static void __net_exit ip_fib_net_exit(s
 		head = &net->ipv4.fib_table_hash[i];
 		hlist_for_each_entry_safe(tb, node, tmp, head, tb_hlist) {
 			hlist_del(node);
-			tb->tb_flush(tb);
+			fib_table_flush(tb);
 			kfree(tb);
 		}
 	}
--- a/net/ipv4/fib_rules.c	2009-09-20 12:30:43.159471244 -0700
+++ b/net/ipv4/fib_rules.c	2009-09-20 12:32:08.709470541 -0700
@@ -94,7 +94,7 @@ static int fib4_rule_action(struct fib_r
 	if ((tbl = fib_get_table(rule->fr_net, rule->table)) == NULL)
 		goto errout;
 
-	err = tbl->tb_lookup(tbl, flp, (struct fib_result *) arg->result);
+	err = fib_table_lookup(tbl, flp, (struct fib_result *) arg->result);
 	if (err > 0)
 		err = -EAGAIN;
 errout:
--- a/net/ipv4/fib_trie.c	2009-09-20 12:23:59.409447223 -0700
+++ b/net/ipv4/fib_trie.c	2009-09-20 12:29:45.041693219 -0700
@@ -1174,7 +1174,7 @@ done:
 /*
  * Caller must hold RTNL.
  */
-static int fn_trie_insert(struct fib_table *tb, struct fib_config *cfg)
+int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 {
 	struct trie *t = (struct trie *) tb->tb_data;
 	struct fib_alias *fa, *new_fa;
@@ -1373,8 +1373,8 @@ static int check_leaf(struct trie *t, st
 	return 1;
 }
 
-static int fn_trie_lookup(struct fib_table *tb, const struct flowi *flp,
-			  struct fib_result *res)
+int fib_table_lookup(struct fib_table *tb, const struct flowi *flp,
+		     struct fib_result *res)
 {
 	struct trie *t = (struct trie *) tb->tb_data;
 	int ret;
@@ -1595,7 +1595,7 @@ static void trie_leaf_remove(struct trie
 /*
  * Caller must hold RTNL.
  */
-static int fn_trie_delete(struct fib_table *tb, struct fib_config *cfg)
+int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 {
 	struct trie *t = (struct trie *) tb->tb_data;
 	u32 key, mask;
@@ -1786,7 +1786,7 @@ static struct leaf *trie_leafindex(struc
 /*
  * Caller must hold RTNL.
  */
-static int fn_trie_flush(struct fib_table *tb)
+int fib_table_flush(struct fib_table *tb)
 {
 	struct trie *t = (struct trie *) tb->tb_data;
 	struct leaf *l, *ll = NULL;
@@ -1807,9 +1807,9 @@ static int fn_trie_flush(struct fib_tabl
 	return found;
 }
 
-static void fn_trie_select_default(struct fib_table *tb,
-				   const struct flowi *flp,
-				   struct fib_result *res)
+void fib_table_select_default(struct fib_table *tb,
+			      const struct flowi *flp,
+			      struct fib_result *res)
 {
 	struct trie *t = (struct trie *) tb->tb_data;
 	int order, last_idx;
@@ -1952,8 +1952,8 @@ static int fn_trie_dump_leaf(struct leaf
 	return skb->len;
 }
 
-static int fn_trie_dump(struct fib_table *tb, struct sk_buff *skb,
-			struct netlink_callback *cb)
+int fib_table_dump(struct fib_table *tb, struct sk_buff *skb,
+		   struct netlink_callback *cb)
 {
 	struct leaf *l;
 	struct trie *t = (struct trie *) tb->tb_data;
@@ -2020,12 +2020,6 @@ struct fib_table *fib_hash_table(u32 id)
 
 	tb->tb_id = id;
 	tb->tb_default = -1;
-	tb->tb_lookup = fn_trie_lookup;
-	tb->tb_insert = fn_trie_insert;
-	tb->tb_delete = fn_trie_delete;
-	tb->tb_flush = fn_trie_flush;
-	tb->tb_select_default = fn_trie_select_default;
-	tb->tb_dump = fn_trie_dump;
 
 	t = (struct trie *) tb->tb_data;
 	memset(t, 0, sizeof(*t));
--- a/net/ipv4/fib_hash.c	2009-09-20 12:23:55.799439103 -0700
+++ b/net/ipv4/fib_hash.c	2009-09-20 12:46:25.700353394 -0700
@@ -242,8 +242,8 @@ fn_new_zone(struct fn_hash *table, int z
 	return fz;
 }
 
-static int
-fn_hash_lookup(struct fib_table *tb, const struct flowi *flp, struct fib_result *res)
+int fib_table_lookup(struct fib_table *tb,
+		     const struct flowi *flp, struct fib_result *res)
 {
 	int err;
 	struct fn_zone *fz;
@@ -274,8 +274,8 @@ out:
 	return err;
 }
 
-static void
-fn_hash_select_default(struct fib_table *tb, const struct flowi *flp, struct fib_result *res)
+void fib_table_select_default(struct fib_table *tb,
+			      const struct flowi *flp, struct fib_result *res)
 {
 	int order, last_idx;
 	struct hlist_node *node;
@@ -366,7 +366,7 @@ static struct fib_node *fib_find_node(st
 	return NULL;
 }
 
-static int fn_hash_insert(struct fib_table *tb, struct fib_config *cfg)
+int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 {
 	struct fn_hash *table = (struct fn_hash *) tb->tb_data;
 	struct fib_node *new_f = NULL;
@@ -544,8 +544,7 @@ out:
 	return err;
 }
 
-
-static int fn_hash_delete(struct fib_table *tb, struct fib_config *cfg)
+int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 {
 	struct fn_hash *table = (struct fn_hash *)tb->tb_data;
 	struct fib_node *f;
@@ -662,7 +661,7 @@ static int fn_flush_list(struct fn_zone 
 	return found;
 }
 
-static int fn_hash_flush(struct fib_table *tb)
+int fib_table_flush(struct fib_table *tb)
 {
 	struct fn_hash *table = (struct fn_hash *) tb->tb_data;
 	struct fn_zone *fz;
@@ -743,7 +742,8 @@ fn_hash_dump_zone(struct sk_buff *skb, s
 	return skb->len;
 }
 
-static int fn_hash_dump(struct fib_table *tb, struct sk_buff *skb, struct netlink_callback *cb)
+int fib_table_dump(struct fib_table *tb, struct sk_buff *skb,
+		   struct netlink_callback *cb)
 {
 	int m, s_m;
 	struct fn_zone *fz;
@@ -787,12 +787,7 @@ struct fib_table *fib_hash_table(u32 id)
 
 	tb->tb_id = id;
 	tb->tb_default = -1;
-	tb->tb_lookup = fn_hash_lookup;
-	tb->tb_insert = fn_hash_insert;
-	tb->tb_delete = fn_hash_delete;
-	tb->tb_flush = fn_hash_flush;
-	tb->tb_select_default = fn_hash_select_default;
-	tb->tb_dump = fn_hash_dump;
+
 	memset(tb->tb_data, 0, sizeof(struct fn_hash));
 	return tb;
 }
