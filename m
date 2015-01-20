From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v3 03/12] net: flow: implement flow cache for get
 routines
Date: Tue, 20 Jan 2015 12:27:28 -0800
Message-ID: <20150120202727.1741.30573.stgit@nitbit.x32>
References: <20150120202404.1741.8658.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, davem@davemloft.net,
	gerlitz.or@gmail.com, andy@greyhouse.net, ast@plumgrid.com
To: tgraf@suug.ch, simon.horman@netronome.com, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:59251 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751526AbbATU1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 15:27:46 -0500
Received: by mail-ob0-f175.google.com with SMTP id wp4so15201678obc.6
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 12:27:46 -0800 (PST)
In-Reply-To: <20150120202404.1741.8658.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I used rhashtable to implement a flow cache so software can track the
currently programmed rules without requiring every driver to
implement its own cache logic or fetch information from hardware.

I chose rhashtable to get the dynamic resizing.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/linux/if_flow.h |   24 +++++++
 net/core/flow_table.c   |  152 +++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 169 insertions(+), 7 deletions(-)

diff --git a/include/linux/if_flow.h b/include/linux/if_flow.h
index 712b54f..07d7bca 100644
--- a/include/linux/if_flow.h
+++ b/include/linux/if_flow.h
@@ -21,6 +21,7 @@
 #define _IF_FLOW_H
 
 #include <uapi/linux/if_flow.h>
+#include <linux/rhashtable.h>
 
 /**
  * @struct net_flow_fields
@@ -134,6 +135,7 @@ struct net_flow_field_ref {
  * @size max number of entries for table or -1 for unbounded
  * @matches null terminated set of supported match types given by match uid
  * @actions null terminated set of supported action types given by action uid
+ * @cache software cache of hardware flows
  */
 struct net_flow_tbl {
 	char *name;
@@ -143,6 +145,7 @@ struct net_flow_tbl {
 	__u32 size;
 	struct net_flow_field_ref *matches;
 	__u32 *actions;
+	struct rhashtable cache;
 };
 
 /**
@@ -190,6 +193,8 @@ struct net_flow_tbl_node {
  * @struct net_flow_rule
  * @brief describes the match/action entry
  *
+ * @node node for resizable hash table used for software cache of rules
+ * @rcu used to support delayed freeing via call_rcu in software cache
  * @uid unique identifier for flow
  * @priority priority to execute flow match/action in table
  * @match null terminated set of match uids match criteria
@@ -198,10 +203,29 @@ struct net_flow_tbl_node {
  * Flows must match all entries in match set.
  */
 struct net_flow_rule {
+	struct rhash_head node;
+	struct rcu_head rcu;
 	__u32 table_id;
 	__u32 uid;
 	__u32 priority;
 	struct net_flow_field_ref *matches;
 	struct net_flow_action *actions;
 };
+
+#ifdef CONFIG_NET_FLOW_TABLES
+int net_flow_init_cache(struct net_flow_tbl *table);
+void net_flow_destroy_cache(struct net_flow_tbl *table);
+#else
+static inline int
+net_flow_init_cache(struct net_flow_tbl *table)
+{
+	return 0;
+}
+
+static inline void
+net_flow_destroy_cache(struct net_flow_tbl *table)
+{
+	return;
+}
+#endif /* CONFIG_NET_FLOW_TABLES */
 #endif /* _IF_FLOW_H_ */
diff --git a/net/core/flow_table.c b/net/core/flow_table.c
index 7b85e53..c1a9716 100644
--- a/net/core/flow_table.c
+++ b/net/core/flow_table.c
@@ -26,6 +26,8 @@
 #include <net/genetlink.h>
 #include <net/rtnetlink.h>
 #include <linux/module.h>
+#include <linux/rhashtable.h>
+#include <linux/jhash.h>
 
 static DEFINE_MUTEX(net_flow_mutex);
 
@@ -919,6 +921,27 @@ static int net_flow_cmd_get_table_graph(struct sk_buff *skb,
 	return genlmsg_reply(msg, info);
 }
 
+static struct net_flow_tbl *net_flow_get_table(struct net_device *dev,
+					       int table_id)
+{
+	struct net_flow_tbl **tables;
+	int i;
+
+	if (!dev->netdev_ops->ndo_flow_get_tbls)
+		return NULL;
+
+	tables = dev->netdev_ops->ndo_flow_get_tbls(dev);
+	if (!tables)
+		return NULL;
+
+	for (i = 0; tables[i]; i++) {
+		if (tables[i]->uid == table_id)
+			return tables[i];
+	}
+
+	return NULL;
+}
+
 static int net_flow_put_flow_action(struct sk_buff *skb,
 				    struct net_flow_action *a)
 {
@@ -1017,11 +1040,39 @@ put_failure:
 	return err;
 }
 
+static int net_flow_get_rule_cache(struct sk_buff *skb,
+				   struct net_flow_tbl *table,
+				   int min, int max)
+{
+	const struct bucket_table *tbl;
+	struct net_flow_rule *he;
+	int i, err = 0;
+
+	rcu_read_lock();
+	tbl = rht_dereference_rcu(table->cache.tbl, &table->cache);
+
+	for (i = 0; i < tbl->size; i++) {
+		struct rhash_head *pos;
+
+		rht_for_each_entry_rcu(he, pos, tbl, i, node) {
+			if (he->uid < min || (max > 0 && he->uid > max))
+				continue;
+			err = net_flow_put_rule(skb, he);
+			if (err)
+				goto out;
+		}
+	}
+out:
+	rcu_read_unlock();
+	return err;
+}
+
 static struct sk_buff *net_flow_build_flows_msg(struct net_device *dev,
 						u32 portid, int seq, u8 cmd,
 						int min, int max, int table)
 {
 	struct genlmsghdr *hdr;
+	struct net_flow_tbl *t;
 	struct nlattr *flows;
 	struct sk_buff *skb;
 	int err = -ENOBUFS;
@@ -1042,15 +1093,23 @@ static struct sk_buff *net_flow_build_flows_msg(struct net_device *dev,
 		goto out;
 	}
 
+	t = net_flow_get_table(dev, table);
+	if (!t) {
+		err = -EINVAL;
+		goto out;
+	}
+
 	flows = nla_nest_start(skb, NFL_FLOWS);
 	if (!flows) {
 		err = -EMSGSIZE;
 		goto out;
 	}
 
-	err = -EOPNOTSUPP;
-	if (err < 0)
-		goto out_cancel;
+	err = net_flow_get_rule_cache(skb, t, min, max);
+	if (err < 0) {
+		nla_nest_cancel(skb, flows);
+		goto out;
+	}
 
 	nla_nest_end(skb, flows);
 
@@ -1059,8 +1118,6 @@ static struct sk_buff *net_flow_build_flows_msg(struct net_device *dev,
 		goto out;
 
 	return skb;
-out_cancel:
-	nla_nest_cancel(skb, flows);
 out:
 	nlmsg_free(skb);
 	return ERR_PTR(err);
@@ -1300,6 +1357,13 @@ static void net_flow_rule_free(struct net_flow_rule *rule)
 	kfree(rule);
 }
 
+static void net_flow_rule_free_rcu(struct rcu_head *head)
+{
+	struct net_flow_rule *r = container_of(head, struct net_flow_rule, rcu);
+
+	net_flow_rule_free(r);
+}
+
 static const
 struct nla_policy net_flow_actarg_policy[NFL_ACTION_ARG_MAX + 1] = {
 	[NFL_ACTION_ARG_NAME]  = { .type = NLA_STRING },
@@ -1505,6 +1569,70 @@ static int net_flow_get_rule(struct net_flow_rule *rule, struct nlattr *attr)
 	return 0;
 }
 
+#define NFL_TABLE_ELEM_HINT 10
+int net_flow_init_cache(struct net_flow_tbl *table)
+{
+	struct rhashtable_params params = {
+		.nelem_hint = NFL_TABLE_ELEM_HINT,
+		.head_offset = offsetof(struct net_flow_rule, node),
+		.key_offset = offsetof(struct net_flow_rule, uid),
+		.key_len = sizeof(__u32),
+		.hashfn = jhash,
+		.grow_decision = rht_grow_above_75,
+		.shrink_decision = rht_shrink_below_30
+	};
+
+	return rhashtable_init(&table->cache, &params);
+}
+EXPORT_SYMBOL(net_flow_init_cache);
+
+void net_flow_destroy_cache(struct net_flow_tbl *table)
+{
+	struct rhashtable *cache = &table->cache;
+	const struct bucket_table *tbl;
+	struct net_flow_rule *he;
+	struct rhash_head *pos, *next;
+	unsigned int i;
+
+	/* Stop an eventual async resizing */
+	cache->being_destroyed = true;
+	mutex_lock(&cache->mutex);
+
+	tbl = rht_dereference(cache->tbl, cache);
+	for (i = 0; i < tbl->size; i++) {
+		rht_for_each_entry_safe(he, pos, next, tbl, i, node) {
+			rhashtable_remove(&table->cache, &he->node);
+			call_rcu(&he->rcu, net_flow_rule_free_rcu);
+		}
+	}
+
+	mutex_unlock(&cache->mutex);
+	rhashtable_destroy(cache);
+}
+EXPORT_SYMBOL(net_flow_destroy_cache);
+
+static void net_flow_add_rule_cache(struct net_flow_tbl *table,
+				    struct net_flow_rule *this)
+{
+	rhashtable_insert(&table->cache, &this->node);
+}
+
+static int net_flow_del_rule_cache(struct net_flow_tbl *table,
+				   struct net_flow_rule *this)
+{
+	struct net_flow_rule *he;
+
+	he = rhashtable_lookup(&table->cache, &this->uid);
+	if (he) {
+		rhashtable_remove(&table->cache, &he->node);
+		synchronize_rcu();
+		net_flow_rule_free(he);
+		return 0;
+	}
+
+	return -EEXIST;
+}
+
 static int net_flow_table_cmd_flows(struct sk_buff *recv_skb,
 				    struct genl_info *info)
 {
@@ -1546,6 +1674,8 @@ static int net_flow_table_cmd_flows(struct sk_buff *recv_skb,
 
 	net_flow_lock();
 	nla_for_each_nested(flow, info->attrs[NFL_FLOWS], rem) {
+		struct net_flow_tbl *table;
+
 		if (nla_type(flow) != NFL_FLOW)
 			continue;
 
@@ -1563,12 +1693,22 @@ static int net_flow_table_cmd_flows(struct sk_buff *recv_skb,
 		if (err)
 			goto out_locked;
 
+		table = net_flow_get_table(dev, this->table_id);
+		if (!table) {
+			err = -EINVAL;
+			goto skip;
+		}
+
 		switch (cmd) {
 		case NFL_TABLE_CMD_SET_FLOWS:
 			err = dev->netdev_ops->ndo_flow_set_rule(dev, this);
+			if (!err)
+				net_flow_add_rule_cache(table, this);
 			break;
 		case NFL_TABLE_CMD_DEL_FLOWS:
 			err = dev->netdev_ops->ndo_flow_del_rule(dev, this);
+			if (!err)
+				err = net_flow_del_rule_cache(table, this);
 			break;
 		default:
 			err = -EOPNOTSUPP;
@@ -1597,8 +1737,6 @@ skip:
 			net_flow_put_rule(skb, this);
 		}
 
-		net_flow_rule_free(this);
-
 		if (err && err_handle == NFL_FLOWS_ERROR_ABORT)
 			goto out_locked;
 	}
