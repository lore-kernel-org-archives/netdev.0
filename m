From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/2] ipv4: Consolidate all default route selection
 implementations.
Date: Mon, 31 Jan 2011 16:25:51 -0800 (PST)
Message-ID: <20110131.162551.15243101.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43031
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754297Ab1BAAZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jan 2011 19:25:16 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 1132A24C087
	for <netdev@vger.kernel.org>; Mon, 31 Jan 2011 16:25:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Both fib_trie and fib_hash have a local implementation of
fib_table_select_default().  This is completely unnecessary
code duplication.

Since we now remember the fib_table and the head of the fib
alias list of the default route, we can implement one single
generic version of this routine.

Looking at the fib_hash implementation you may get the impression
that it's possible for there to be multiple top-level routes in
the table for the default route.  The truth is, it isn't, the
insert code will only allow one entry to exist in the zero
prefix hash table, because all keys evaluate to zero and all
keys in a hash table must be unique.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip_fib.h     |    6 +---
 net/ipv4/fib_frontend.c  |   15 ---------
 net/ipv4/fib_hash.c      |   72 --------------------------------------------
 net/ipv4/fib_semantics.c |   56 ++++++++++++++++++++++++++++++++++
 net/ipv4/fib_trie.c      |   74 ----------------------------------------------
 net/ipv4/route.c         |    2 +-
 6 files changed, 58 insertions(+), 167 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index f5199b0..819d61c 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -158,9 +158,6 @@ extern int fib_table_delete(struct fib_table *, struct fib_config *);
 extern int fib_table_dump(struct fib_table *table, struct sk_buff *skb,
 			  struct netlink_callback *cb);
 extern int fib_table_flush(struct fib_table *table);
-extern void fib_table_select_default(struct fib_table *table,
-				     const struct flowi *flp,
-				     struct fib_result *res);
 extern void fib_free_table(struct fib_table *tb);
 
 
@@ -221,8 +218,7 @@ extern void		ip_fib_init(void);
 extern int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 			       struct net_device *dev, __be32 *spec_dst,
 			       u32 *itag, u32 mark);
-extern void fib_select_default(struct net *net, const struct flowi *flp,
-			       struct fib_result *res);
+extern void fib_select_default(struct fib_result *res);
 
 /* Exported by fib_semantics.c */
 extern int ip_fib_check_default(__be32 gw, struct net_device *dev);
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 1d2cdd4..930768b 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -114,21 +114,6 @@ struct fib_table *fib_get_table(struct net *net, u32 id)
 }
 #endif /* CONFIG_IP_MULTIPLE_TABLES */
 
-void fib_select_default(struct net *net,
-			const struct flowi *flp, struct fib_result *res)
-{
-	struct fib_table *tb;
-	int table = RT_TABLE_MAIN;
-#ifdef CONFIG_IP_MULTIPLE_TABLES
-	if (res->r == NULL || res->r->action != FR_ACT_TO_TBL)
-		return;
-	table = res->r->table;
-#endif
-	tb = fib_get_table(net, table);
-	if (FIB_RES_GW(*res) && FIB_RES_NH(*res).nh_scope == RT_SCOPE_LINK)
-		fib_table_select_default(tb, flp, res);
-}
-
 static void fib_flush(struct net *net)
 {
 	int flushed = 0;
diff --git a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
index 0a88866..fadb602 100644
--- a/net/ipv4/fib_hash.c
+++ b/net/ipv4/fib_hash.c
@@ -302,78 +302,6 @@ out:
 	return err;
 }
 
-void fib_table_select_default(struct fib_table *tb,
-			      const struct flowi *flp, struct fib_result *res)
-{
-	int order, last_idx;
-	struct hlist_node *node;
-	struct fib_node *f;
-	struct fib_info *fi = NULL;
-	struct fib_info *last_resort;
-	struct fn_hash *t = (struct fn_hash *)tb->tb_data;
-	struct fn_zone *fz = t->fn_zones[0];
-	struct hlist_head *head;
-
-	if (fz == NULL)
-		return;
-
-	last_idx = -1;
-	last_resort = NULL;
-	order = -1;
-
-	rcu_read_lock();
-	head = rcu_dereference(fz->fz_hash);
-	hlist_for_each_entry_rcu(f, node, head, fn_hash) {
-		struct fib_alias *fa;
-
-		list_for_each_entry_rcu(fa, &f->fn_alias, fa_list) {
-			struct fib_info *next_fi = fa->fa_info;
-
-			if (fa->fa_scope != res->scope ||
-			    fa->fa_type != RTN_UNICAST)
-				continue;
-
-			if (next_fi->fib_priority > res->fi->fib_priority)
-				break;
-			if (!next_fi->fib_nh[0].nh_gw ||
-			    next_fi->fib_nh[0].nh_scope != RT_SCOPE_LINK)
-				continue;
-
-			fib_alias_accessed(fa);
-
-			if (fi == NULL) {
-				if (next_fi != res->fi)
-					break;
-			} else if (!fib_detect_death(fi, order, &last_resort,
-						&last_idx, tb->tb_default)) {
-				fib_result_assign(res, fi);
-				tb->tb_default = order;
-				goto out;
-			}
-			fi = next_fi;
-			order++;
-		}
-	}
-
-	if (order <= 0 || fi == NULL) {
-		tb->tb_default = -1;
-		goto out;
-	}
-
-	if (!fib_detect_death(fi, order, &last_resort, &last_idx,
-				tb->tb_default)) {
-		fib_result_assign(res, fi);
-		tb->tb_default = order;
-		goto out;
-	}
-
-	if (last_idx >= 0)
-		fib_result_assign(res, last_resort);
-	tb->tb_default = last_idx;
-out:
-	rcu_read_unlock();
-}
-
 /* Insert node F to FZ. */
 static inline void fib_insert_node(struct fn_zone *fz, struct fib_node *f)
 {
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 1bf6fb9..b15857d 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1136,6 +1136,62 @@ int fib_sync_down_dev(struct net_device *dev, int force)
 	return ret;
 }
 
+/* Must be invoked inside of an RCU protected region.  */
+void fib_select_default(struct fib_result *res)
+{
+	struct fib_info *fi = NULL, *last_resort = NULL;
+	struct list_head *fa_head = res->fa_head;
+	struct fib_table *tb = res->table;
+	int order = -1, last_idx = -1;
+	struct fib_alias *fa;
+
+	list_for_each_entry_rcu(fa, fa_head, fa_list) {
+		struct fib_info *next_fi = fa->fa_info;
+
+		if (fa->fa_scope != res->scope ||
+		    fa->fa_type != RTN_UNICAST)
+			continue;
+
+		if (next_fi->fib_priority > res->fi->fib_priority)
+			break;
+		if (!next_fi->fib_nh[0].nh_gw ||
+		    next_fi->fib_nh[0].nh_scope != RT_SCOPE_LINK)
+			continue;
+
+		fib_alias_accessed(fa);
+
+		if (fi == NULL) {
+			if (next_fi != res->fi)
+				break;
+		} else if (!fib_detect_death(fi, order, &last_resort,
+					     &last_idx, tb->tb_default)) {
+			fib_result_assign(res, fi);
+			tb->tb_default = order;
+			goto out;
+		}
+		fi = next_fi;
+		order++;
+	}
+
+	if (order <= 0 || fi == NULL) {
+		tb->tb_default = -1;
+		goto out;
+	}
+
+	if (!fib_detect_death(fi, order, &last_resort, &last_idx,
+				tb->tb_default)) {
+		fib_result_assign(res, fi);
+		tb->tb_default = order;
+		goto out;
+	}
+
+	if (last_idx >= 0)
+		fib_result_assign(res, last_resort);
+	tb->tb_default = last_idx;
+out:
+	rcu_read_unlock();
+}
+
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 
 /*
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 8cee5c8..16d589c 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1802,80 +1802,6 @@ void fib_free_table(struct fib_table *tb)
 	kfree(tb);
 }
 
-void fib_table_select_default(struct fib_table *tb,
-			      const struct flowi *flp,
-			      struct fib_result *res)
-{
-	struct trie *t = (struct trie *) tb->tb_data;
-	int order, last_idx;
-	struct fib_info *fi = NULL;
-	struct fib_info *last_resort;
-	struct fib_alias *fa = NULL;
-	struct list_head *fa_head;
-	struct leaf *l;
-
-	last_idx = -1;
-	last_resort = NULL;
-	order = -1;
-
-	rcu_read_lock();
-
-	l = fib_find_node(t, 0);
-	if (!l)
-		goto out;
-
-	fa_head = get_fa_head(l, 0);
-	if (!fa_head)
-		goto out;
-
-	if (list_empty(fa_head))
-		goto out;
-
-	list_for_each_entry_rcu(fa, fa_head, fa_list) {
-		struct fib_info *next_fi = fa->fa_info;
-
-		if (fa->fa_scope != res->scope ||
-		    fa->fa_type != RTN_UNICAST)
-			continue;
-
-		if (next_fi->fib_priority > res->fi->fib_priority)
-			break;
-		if (!next_fi->fib_nh[0].nh_gw ||
-		    next_fi->fib_nh[0].nh_scope != RT_SCOPE_LINK)
-			continue;
-
-		fib_alias_accessed(fa);
-
-		if (fi == NULL) {
-			if (next_fi != res->fi)
-				break;
-		} else if (!fib_detect_death(fi, order, &last_resort,
-					     &last_idx, tb->tb_default)) {
-			fib_result_assign(res, fi);
-			tb->tb_default = order;
-			goto out;
-		}
-		fi = next_fi;
-		order++;
-	}
-	if (order <= 0 || fi == NULL) {
-		tb->tb_default = -1;
-		goto out;
-	}
-
-	if (!fib_detect_death(fi, order, &last_resort, &last_idx,
-				tb->tb_default)) {
-		fib_result_assign(res, fi);
-		tb->tb_default = order;
-		goto out;
-	}
-	if (last_idx >= 0)
-		fib_result_assign(res, last_resort);
-	tb->tb_default = last_idx;
-out:
-	rcu_read_unlock();
-}
-
 static int fn_trie_dump_fa(t_key key, int plen, struct list_head *fah,
 			   struct fib_table *tb,
 			   struct sk_buff *skb, struct netlink_callback *cb)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index b1e5d3a..242a3de 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2711,7 +2711,7 @@ static int ip_route_output_slow(struct net *net, struct rtable **rp,
 	else
 #endif
 	if (!res.prefixlen && res.type == RTN_UNICAST && !fl.oif)
-		fib_select_default(net, &fl, &res);
+		fib_select_default(&res);
 
 	if (!fl.fl4_src)
 		fl.fl4_src = FIB_RES_PREFSRC(res);
-- 
1.7.4

