From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH] ipv4: FIB Local/MAIN table collapse
Date: Fri, 06 Mar 2015 13:47:00 -0800
Message-ID: <20150306213830.1139.16932.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, jiri@resnulli.us, sfeldma@gmail.com,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60301 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751247AbbCFVrK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Mar 2015 16:47:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is meant to collapse local and main into one by converting
tb_data from an array to a pointer.  Doing this allows us to point the
local table into the main while maintaining the same variables in the
table.

As such the tb_data was converted from an array to a pointer, and a new
array called data is added in order to still provide an object for tb_data
to point to.

In order to track the origin of the fib aliases a tb_id value was added in
a hole that existed on 64b systems.  Using this we can also reverse the
merge in the event that custom FIB rules are enabled.

With this patch I am seeing an improvement of 20ns to 30ns for routing
lookups as long as custom rules are not enabled, with custom rules enabled
we fall back to split tables and the original behavior.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---

Changes since the RFC:
  Added tb_id value so I could split main and local for custom rules
  Added functionality to split tables if custom rules were enabled
  Added table replacement and unmerge functions

I have done some testing on this to verify performance gains and that I can
split the tables correctly when I enable custom rules, but this patch is
what I would consider to be high risk since I am certain there are things I
have not considered.

If this gets pulled into someone's switchdev tree instead of into net-next I
would be perfectly fine with that as I am sure this can use some additional
testing.

 include/net/fib_rules.h |    2 -
 include/net/ip_fib.h    |   26 ++-----
 net/core/fib_rules.c    |    8 ++
 net/ipv4/fib_frontend.c |   59 ++++++++++++++--
 net/ipv4/fib_lookup.h   |    1 
 net/ipv4/fib_rules.c    |   20 ++++-
 net/ipv4/fib_trie.c     |  172 +++++++++++++++++++++++++++++++++++++++++++++--
 7 files changed, 250 insertions(+), 38 deletions(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index e584de1..88d2ae5 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -58,7 +58,7 @@ struct fib_rules_ops {
 					     struct sk_buff *,
 					     struct fib_rule_hdr *,
 					     struct nlattr **);
-	void			(*delete)(struct fib_rule *);
+	int			(*delete)(struct fib_rule *);
 	int			(*compare)(struct fib_rule *,
 					   struct fib_rule_hdr *,
 					   struct nlattr **);
diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 1657604..54271ed 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -186,7 +186,8 @@ struct fib_table {
 	int			tb_default;
 	int			tb_num_default;
 	struct rcu_head		rcu;
-	unsigned long		tb_data[0];
+	unsigned long 		*tb_data;
+	unsigned long		__data[0];
 };
 
 int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
@@ -196,11 +197,10 @@ int fib_table_delete(struct fib_table *, struct fib_config *);
 int fib_table_dump(struct fib_table *table, struct sk_buff *skb,
 		   struct netlink_callback *cb);
 int fib_table_flush(struct fib_table *table);
+struct fib_table *fib_trie_unmerge(struct fib_table *main_tb);
 void fib_table_flush_external(struct fib_table *table);
 void fib_free_table(struct fib_table *tb);
 
-
-
 #ifndef CONFIG_IP_MULTIPLE_TABLES
 
 #define TABLE_LOCAL_INDEX	(RT_TABLE_LOCAL & (FIB_TABLE_HASHSZ - 1))
@@ -229,18 +229,13 @@ static inline int fib_lookup(struct net *net, const struct flowi4 *flp,
 			     struct fib_result *res)
 {
 	struct fib_table *tb;
-	int err;
+	int err = -ENETUNREACH;
 
 	rcu_read_lock();
 
-	for (err = 0; !err; err = -ENETUNREACH) {
-		tb = fib_get_table(net, RT_TABLE_LOCAL);
-		if (tb && !fib_table_lookup(tb, flp, res, FIB_LOOKUP_NOREF))
-			break;
-		tb = fib_get_table(net, RT_TABLE_MAIN);
-		if (tb && !fib_table_lookup(tb, flp, res, FIB_LOOKUP_NOREF))
-			break;
-	}
+	tb = fib_get_table(net, RT_TABLE_MAIN);
+	if (tb && !fib_table_lookup(tb, flp, res, FIB_LOOKUP_NOREF))
+		err = 0;
 
 	rcu_read_unlock();
 
@@ -270,10 +265,6 @@ static inline int fib_lookup(struct net *net, struct flowi4 *flp,
 	res->tclassid = 0;
 
 	for (err = 0; !err; err = -ENETUNREACH) {
-		tb = rcu_dereference_rtnl(net->ipv4.fib_local);
-		if (tb && !fib_table_lookup(tb, flp, res, FIB_LOOKUP_NOREF))
-			break;
-
 		tb = rcu_dereference_rtnl(net->ipv4.fib_main);
 		if (tb && !fib_table_lookup(tb, flp, res, FIB_LOOKUP_NOREF))
 			break;
@@ -309,6 +300,7 @@ static inline int fib_num_tclassid_users(struct net *net)
 	return 0;
 }
 #endif
+int fib_unmerge(struct net *net);
 void fib_flush_external(struct net *net);
 
 /* Exported by fib_semantics.c */
@@ -320,7 +312,7 @@ void fib_select_multipath(struct fib_result *res);
 
 /* Exported by fib_trie.c */
 void fib_trie_init(void);
-struct fib_table *fib_trie_table(u32 id);
+struct fib_table *fib_trie_table(u32 id, struct fib_table *alias);
 
 static inline void fib_combine_itag(u32 *itag, const struct fib_result *res)
 {
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 44706e8..b55677f 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -492,6 +492,12 @@ static int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 			goto errout;
 		}
 
+		if (ops->delete) {
+			err = ops->delete(rule);
+			if (err)
+				goto errout;
+		}
+
 		list_del_rcu(&rule->list);
 
 		if (rule->action == FR_ACT_GOTO) {
@@ -517,8 +523,6 @@ static int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 
 		notify_rule_change(RTM_DELRULE, rule, ops, nlh,
 				   NETLINK_CB(skb).portid);
-		if (ops->delete)
-			ops->delete(rule);
 		fib_rule_put(rule);
 		flush_route_cache(ops);
 		rules_ops_put(ops);
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index e067770..7cda3b0 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -52,14 +52,14 @@ static int __net_init fib4_rules_init(struct net *net)
 {
 	struct fib_table *local_table, *main_table;
 
-	local_table = fib_trie_table(RT_TABLE_LOCAL);
-	if (local_table == NULL)
-		return -ENOMEM;
-
-	main_table  = fib_trie_table(RT_TABLE_MAIN);
+	main_table  = fib_trie_table(RT_TABLE_MAIN, NULL);
 	if (main_table == NULL)
 		goto fail;
 
+	local_table = fib_trie_table(RT_TABLE_LOCAL, main_table);
+	if (local_table == NULL)
+		return -ENOMEM;
+
 	hlist_add_head_rcu(&local_table->tb_hlist,
 				&net->ipv4.fib_table_hash[TABLE_LOCAL_INDEX]);
 	hlist_add_head_rcu(&main_table->tb_hlist,
@@ -74,7 +74,7 @@ fail:
 
 struct fib_table *fib_new_table(struct net *net, u32 id)
 {
-	struct fib_table *tb;
+	struct fib_table *tb, *alias = NULL;
 	unsigned int h;
 
 	if (id == 0)
@@ -83,7 +83,10 @@ struct fib_table *fib_new_table(struct net *net, u32 id)
 	if (tb)
 		return tb;
 
-	tb = fib_trie_table(id);
+	if (id == RT_TABLE_LOCAL)
+		alias = fib_new_table(net, RT_TABLE_MAIN);
+
+	tb = fib_trie_table(id, alias);
 	if (!tb)
 		return NULL;
 
@@ -126,6 +129,48 @@ struct fib_table *fib_get_table(struct net *net, u32 id)
 }
 #endif /* CONFIG_IP_MULTIPLE_TABLES */
 
+static void fib_replace_table(struct net *net, struct fib_table *old,
+			      struct fib_table *new)
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
+int fib_unmerge(struct net *net)
+{
+	struct fib_table *old, *new;
+
+	old = fib_get_table(net, RT_TABLE_LOCAL);
+	new = fib_trie_unmerge(old);
+
+	if (!new)
+		return -ENOMEM;
+
+	/* replace merged table with clean table */
+	if (new != old) {
+		fib_replace_table(net, old, new);
+		fib_free_table(old);
+	}
+
+	return 0;
+}
+
 static void fib_flush(struct net *net)
 {
 	int flushed = 0;
diff --git a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
index ae2e6ee..c6211ed 100644
--- a/net/ipv4/fib_lookup.h
+++ b/net/ipv4/fib_lookup.h
@@ -12,6 +12,7 @@ struct fib_alias {
 	u8			fa_type;
 	u8			fa_state;
 	u8			fa_slen;
+	u32			tb_id;
 	struct rcu_head		rcu;
 };
 
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 190d0d0..e9bc5e4 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -174,6 +174,11 @@ static int fib4_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
 	if (frh->tos & ~IPTOS_TOS_MASK)
 		goto errout;
 
+	/* split local/main if they are not already split */
+	err = fib_unmerge(net);
+	if (err)
+		goto errout;
+
 	if (rule->table == RT_TABLE_UNSPEC) {
 		if (rule->action == FR_ACT_TO_TBL) {
 			struct fib_table *table;
@@ -216,17 +221,24 @@ errout:
 	return err;
 }
 
-static void fib4_rule_delete(struct fib_rule *rule)
+static int fib4_rule_delete(struct fib_rule *rule)
 {
 	struct net *net = rule->fr_net;
-#ifdef CONFIG_IP_ROUTE_CLASSID
-	struct fib4_rule *rule4 = (struct fib4_rule *) rule;
+	int err;
 
-	if (rule4->tclassid)
+	/* split local/main if they are not already split */
+	err = fib_unmerge(net);
+	if (err)
+		goto errout;
+
+#ifdef CONFIG_IP_ROUTE_CLASSID
+	if (((struct fib4_rule *)rule)->tclassid)
 		net->ipv4.fib_num_tclassid_users--;
 #endif
 	net->ipv4.fib_has_custom_rules = true;
 	fib_flush_external(rule->fr_net);
+errout:
+	return err;
 }
 
 static int fib4_rule_compare(struct fib_rule *rule, struct fib_rule_hdr *frh,
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 9095545..1fa862b 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1122,6 +1122,9 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 				break;
 			if (fa->fa_info->fib_priority != fi->fib_priority)
 				break;
+			/* duplicate entry from another table */
+			if (WARN_ON(fa->tb_id != tb->tb_id))
+				continue;
 			if (fa->fa_type == cfg->fc_type &&
 			    fa->fa_info == fi) {
 				fa_match = fa;
@@ -1198,6 +1201,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 	new_fa->fa_type = cfg->fc_type;
 	new_fa->fa_state = 0;
 	new_fa->fa_slen = slen;
+	new_fa->tb_id = tb->tb_id;
 
 	/* (Optionally) offload fib entry to switch hardware. */
 	err = netdev_switch_fib_ipv4_add(key, plen, fi, tos,
@@ -1216,7 +1220,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 		tb->tb_num_default++;
 
 	rt_cache_flush(cfg->fc_nlinfo.nl_net);
-	rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen, tb->tb_id,
+	rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen, new_fa->tb_id,
 		  &cfg->fc_nlinfo, 0);
 succeeded:
 	return 0;
@@ -1242,7 +1246,7 @@ static inline t_key prefix_mismatch(t_key key, struct key_vector *n)
 int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 		     struct fib_result *res, int fib_flags)
 {
-	struct trie *t = (struct trie *)tb->tb_data;
+	struct trie *t = (struct trie *) tb->tb_data;
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 	struct trie_use_stats __percpu *stats = t->stats;
 #endif
@@ -1482,6 +1486,9 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 		if ((fa->fa_slen != slen) || (fa->fa_tos != tos))
 			break;
 
+		if (fa->tb_id != tb->tb_id)
+			continue;
+
 		if ((!cfg->fc_type || fa->fa_type == cfg->fc_type) &&
 		    (cfg->fc_scope == RT_SCOPE_NOWHERE ||
 		     fa->fa_info->fib_scope == cfg->fc_scope) &&
@@ -1575,6 +1582,120 @@ found:
 	return n;
 }
 
+static void fib_trie_free(struct fib_table *tb)
+{
+	struct trie *t = (struct trie *)tb->tb_data;
+	struct key_vector *pn = t->kv;
+	unsigned long cindex = 1;
+	struct hlist_node *tmp;
+	struct fib_alias *fa;
+
+	/* walk trie in reverse order and free everything */
+	for (;;) {
+		struct key_vector *n;
+
+		if (!(cindex--)) {
+			t_key pkey = pn->key;
+
+			if (IS_TRIE(pn))
+				break;
+
+			n = pn;
+			pn = node_parent(pn);
+
+			/* drop emptied tnode */
+			put_child_root(pn, n->key, NULL);
+			node_free(n);
+
+			cindex = get_index(pkey, pn);
+
+			continue;
+		}
+
+		/* grab the next available node */
+		n = get_child(pn, cindex);
+		if (!n)
+			continue;
+
+		if (IS_TNODE(n)) {
+			/* record pn and cindex for leaf walking */
+			pn = n;
+			cindex = 1ul << n->bits;
+
+			continue;
+		}
+
+		hlist_for_each_entry_safe(fa, tmp, &n->leaf, fa_list) {
+			hlist_del_rcu(&fa->fa_list);
+			alias_free_mem_rcu(fa);
+		}
+
+		put_child_root(pn, n->key, NULL);
+		node_free(n);
+	}
+
+#ifdef CONFIG_IP_FIB_TRIE_STATS
+	free_percpu(t->stats);
+#endif
+	kfree(tb);
+}
+
+struct fib_table *fib_trie_unmerge(struct fib_table *oldtb)
+{
+	struct trie *ot = (struct trie *)oldtb->tb_data;
+	struct key_vector *l, *tp = ot->kv;
+	struct fib_table *local_tb;
+	struct fib_alias *fa;
+	struct trie *lt;
+	t_key key = 0;
+
+	if (oldtb->tb_data == oldtb->__data)
+		return oldtb;
+
+	local_tb = fib_trie_table(RT_TABLE_LOCAL, NULL);
+	if (!local_tb)
+		return NULL;
+
+	lt = (struct trie *)local_tb->tb_data;
+
+	while ((l = leaf_walk_rcu(&tp, key)) != NULL) {
+		struct key_vector *local_l = NULL, *local_tp;
+
+		hlist_for_each_entry_rcu(fa, &l->leaf, fa_list) {
+			struct fib_alias *new_fa;
+
+			if (local_tb->tb_id != fa->tb_id)
+				continue;
+
+			/* clone fa for new local table */
+			new_fa = kmem_cache_alloc(fn_alias_kmem, GFP_KERNEL);
+			if (!new_fa)
+				goto out;
+
+			memcpy(new_fa, fa, sizeof(*fa));
+
+			/* insert clone into table */
+			if (!local_l)
+				local_l = fib_find_node(lt, &local_tp, l->key);
+
+			if (fib_insert_alias(lt, local_tp, local_l, new_fa,
+					     NULL, l->key))
+				goto out;
+		}
+
+		/* stop loop if key wrapped back to 0 */
+		key = l->key + 1;
+		if (key < l->key)
+			break;
+	}
+
+	return local_tb;
+out:
+	fib_trie_free(local_tb);
+
+	return NULL;
+}
+
 /* Caller must hold RTNL */
 void fib_table_flush_external(struct fib_table *tb)
 {
@@ -1586,6 +1707,7 @@ void fib_table_flush_external(struct fib_table *tb)
 
 	/* walk trie in reverse order */
 	for (;;) {
+		unsigned char slen = 0;
 		struct key_vector *n;
 
 		if (!(cindex--)) {
@@ -1595,8 +1717,8 @@ void fib_table_flush_external(struct fib_table *tb)
 			if (IS_TRIE(pn))
 				break;
 
-			/* no need to resize like in flush below */
-			pn = node_parent(pn);
+			/* resize completed node */
+			pn = resize(t, pn);
 			cindex = get_index(pkey, pn);
 
 			continue;
@@ -1618,6 +1740,18 @@ void fib_table_flush_external(struct fib_table *tb)
 		hlist_for_each_entry_safe(fa, tmp, &n->leaf, fa_list) {
 			struct fib_info *fi = fa->fa_info;
 
+			/* if alias was cloned to local then we just
+			 * need to remove the local copy from main
+			 */
+			if (tb->tb_id != fa->tb_id) {
+				hlist_del_rcu(&fa->fa_list);
+				alias_free_mem_rcu(fa);
+				continue;
+			}
+
+			/* record local slen */
+			slen = fa->fa_slen;
+
 			if (!fi || !(fi->fib_flags & RTNH_F_EXTERNAL))
 				continue;
 
@@ -1626,6 +1760,16 @@ void fib_table_flush_external(struct fib_table *tb)
 						   fi, fa->fa_tos,
 						   fa->fa_type, tb->tb_id);
 		}
+
+		/* update leaf slen */
+		n->slen = slen;
+
+		if (hlist_empty(&n->leaf)) {
+			put_child_root(pn, n->key, NULL);
+			node_free(n);
+		} else {
+			leaf_pull_suffix(pn, n);
+		}
 	}
 }
 
@@ -1710,7 +1854,8 @@ static void __trie_free_rcu(struct rcu_head *head)
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 	struct trie *t = (struct trie *)tb->tb_data;
 
-	free_percpu(t->stats);
+	if (tb->tb_data == tb->__data)
+		free_percpu(t->stats);
 #endif /* CONFIG_IP_FIB_TRIE_STATS */
 	kfree(tb);
 }
@@ -1737,6 +1882,11 @@ static int fn_trie_dump_leaf(struct key_vector *l, struct fib_table *tb,
 			continue;
 		}
 
+		if (tb->tb_id != fa->tb_id) {
+			i++;
+			continue;
+		}
+
 		if (fib_dump_info(skb, NETLINK_CB(cb->skb).portid,
 				  cb->nlh->nlmsg_seq,
 				  RTM_NEWROUTE,
@@ -1803,18 +1953,26 @@ void __init fib_trie_init(void)
 					   0, SLAB_PANIC, NULL);
 }
 
-struct fib_table *fib_trie_table(u32 id)
+struct fib_table *fib_trie_table(u32 id, struct fib_table *alias)
 {
 	struct fib_table *tb;
 	struct trie *t;
+	size_t sz = sizeof(*tb);
+
+	if (!alias)
+		sz += sizeof(struct trie);
 
-	tb = kzalloc(sizeof(*tb) + sizeof(struct trie), GFP_KERNEL);
+	tb = kzalloc(sz, GFP_KERNEL);
 	if (tb == NULL)
 		return NULL;
 
 	tb->tb_id = id;
 	tb->tb_default = -1;
 	tb->tb_num_default = 0;
+	tb->tb_data = (alias ? alias->__data : tb->__data);
+
+	if (alias)
+		return tb;
 
 	t = (struct trie *) tb->tb_data;
 	t->kv[0].pos = KEYLENGTH;
