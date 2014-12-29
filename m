From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC flow-net-next 02/10] net: flow: Add features to tables
Date: Mon, 29 Dec 2014 11:15:32 +0900
Message-ID: <1419819340-19000-3-git-send-email-simon.horman@netronome.com>
References: <1419819340-19000-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: John Fastabend <john.r.fastabend@intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:61496 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751801AbaL2CP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Dec 2014 21:15:59 -0500
Received: by mail-pa0-f50.google.com with SMTP id bj1so16408634pad.23
        for <netdev@vger.kernel.org>; Sun, 28 Dec 2014 18:15:59 -0800 (PST)
In-Reply-To: <1419819340-19000-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is intended to allow flows to advertise optional features.
Its initial intended use case is to advertise support for flow timeouts
which will be proposed by a subsequent patch.

Signed-off-by: Simon Horman <simon.horman@netronome.com>

---

Compile tested only
---
 include/uapi/linux/if_flow.h |  3 ++
 net/core/flow_table.c        | 79 ++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 76 insertions(+), 6 deletions(-)

diff --git a/include/uapi/linux/if_flow.h b/include/uapi/linux/if_flow.h
index 25a6b31..5720698 100644
--- a/include/uapi/linux/if_flow.h
+++ b/include/uapi/linux/if_flow.h
@@ -35,6 +35,7 @@
  *       [NET_FLOW_TABLE_ATTR_UID]
  *       [NET_FLOW_TABLE_ATTR_SOURCE]
  *       [NET_FLOW_TABLE_ATTR_SIZE]
+ *       [NET_FLOW_TABLE_ATTR_FEATURES]
  *	 [NET_FLOW_TABLE_ATTR_MATCHES]
  *	   [NET_FLOW_FIELD_REF]
  *	   [NET_FLOW_FIELD_REF]
@@ -422,6 +423,7 @@ struct net_flow_table {
 	int uid;
 	int source;
 	int size;
+	__u32 features;
 	struct net_flow_field_ref *matches;
 	net_flow_action_ref *actions;
 };
@@ -441,6 +443,7 @@ enum {
 	NET_FLOW_TABLE_ATTR_SIZE,
 	NET_FLOW_TABLE_ATTR_MATCHES,
 	NET_FLOW_TABLE_ATTR_ACTIONS,
+	NET_FLOW_TABLE_ATTR_FEATURES,
 	__NET_FLOW_TABLE_ATTR_MAX,
 };
 #define NET_FLOW_TABLE_ATTR_MAX (__NET_FLOW_TABLE_ATTR_MAX - 1)
diff --git a/net/core/flow_table.c b/net/core/flow_table.c
index 5937fb7..1ea88ed 100644
--- a/net/core/flow_table.c
+++ b/net/core/flow_table.c
@@ -63,6 +63,7 @@ struct nla_policy net_flow_table_policy[NET_FLOW_TABLE_ATTR_MAX + 1] = {
 	[NET_FLOW_TABLE_ATTR_UID]	= { .type = NLA_U32 },
 	[NET_FLOW_TABLE_ATTR_SOURCE]	= { .type = NLA_U32 },
 	[NET_FLOW_TABLE_ATTR_SIZE]	= { .type = NLA_U32 },
+	[NET_FLOW_TABLE_ATTR_FEATURES]	= { .type = NLA_U32 },
 	[NET_FLOW_TABLE_ATTR_MATCHES]	= { .type = NLA_NESTED },
 	[NET_FLOW_TABLE_ATTR_ACTIONS]	= { .type = NLA_NESTED },
 };
@@ -245,6 +246,10 @@ static int net_flow_put_table(struct net_device *dev,
 	    nla_put_u32(skb, NET_FLOW_TABLE_ATTR_SIZE, t->size))
 		return -EMSGSIZE;
 
+	if (t->features &&
+	    nla_put_u32(skb, NET_FLOW_TABLE_ATTR_FEATURES, t->features))
+		return -EMSGSIZE;
+
 	matches = nla_nest_start(skb, NET_FLOW_TABLE_ATTR_MATCHES);
 	if (!matches)
 		return -EMSGSIZE;
@@ -611,6 +616,9 @@ static int net_flow_get_table(struct net_flow_table *table, struct nlattr *nla)
 	table->size = tbl[NET_FLOW_TABLE_ATTR_SIZE] ?
 		      nla_get_u32(tbl[NET_FLOW_TABLE_ATTR_SIZE]) : 0;
 
+	table->features = tbl[NET_FLOW_TABLE_ATTR_FEATURES] ?
+		          nla_get_u32(tbl[NET_FLOW_TABLE_ATTR_FEATURES]) : 0;
+
 	if (tbl[NET_FLOW_TABLE_ATTR_MATCHES]) {
 		cnt = 0;
 		nla_for_each_nested(i, tbl[NET_FLOW_TABLE_ATTR_MATCHES], rem)
@@ -719,6 +727,57 @@ static int net_flow_table_cmd_destroy_tables(struct sk_buff *skb,
 	return -EOPNOTSUPP;
 }
 
+static struct net_flow_table **
+net_flow_get_tables(struct net_device *dev)
+{
+	struct net_flow_table **tables;
+
+	if (!dev->netdev_ops->ndo_flow_get_tables)
+		return ERR_PTR(-EOPNOTSUPP);
+
+	tables = dev->netdev_ops->ndo_flow_get_tables(dev);
+	if (!tables) /* transient failure should always have some table */
+		return ERR_PTR(-EBUSY);
+
+	return tables;
+}
+
+static struct net_flow_table *net_flow_table_get_table(struct net_device *dev,
+						       int table_uid)
+{
+	struct net_flow_table **tables;
+	int i;
+
+	tables = net_flow_get_tables(dev);
+	if (IS_ERR(tables))
+		return ERR_PTR(PTR_ERR(tables));
+
+	for (i = 0; tables[i]->uid; i++) {
+		if (tables[i]->uid == table_uid)
+			return tables[i];
+	}
+
+	return ERR_PTR(-ENOENT);
+}
+
+static int net_flow_table_check_features(struct net_device *dev,
+					 int table_uid, u32 used_features)
+{
+	struct net_flow_table *table;
+
+	if (!used_features) /* No features: no problems */
+		return 0;
+
+	table = net_flow_table_get_table(dev, table_uid);
+	if (IS_ERR(table))
+		return PTR_ERR(table);
+
+	if ((used_features & table->features) != used_features)
+		return -EINVAL;
+
+	return 0;
+}
+
 static int net_flow_table_cmd_get_tables(struct sk_buff *skb,
 					 struct genl_info *info)
 {
@@ -730,15 +789,12 @@ static int net_flow_table_cmd_get_tables(struct sk_buff *skb,
 	if (!dev)
 		return -EINVAL;
 
-	if (!dev->netdev_ops->ndo_flow_get_tables) {
+	tables = net_flow_get_tables(dev);
+	if (IS_ERR(tables)) {
 		dev_put(dev);
-		return -EOPNOTSUPP;
+		return PTR_ERR(tables);
 	}
 
-	tables = dev->netdev_ops->ndo_flow_get_tables(dev);
-	if (!tables) /* transient failure should always have some table */
-		return -EBUSY;
-
 	msg = net_flow_build_tables_msg(tables, dev,
 					info->snd_portid,
 					info->snd_seq,
@@ -1302,6 +1358,8 @@ static int net_flow_table_cmd_flows(struct sk_buff *recv_skb,
 		err_handle = nla_get_u32(info->attrs[NET_FLOW_FLOWS_ERROR]);
 
 	nla_for_each_nested(flow, info->attrs[NET_FLOW_FLOWS], rem) {
+		u32 used_features = 0;
+
 		if (nla_type(flow) != NET_FLOW_FLOW)
 			continue;
 
@@ -1309,6 +1367,15 @@ static int net_flow_table_cmd_flows(struct sk_buff *recv_skb,
 		if (err)
 			goto out;
 
+		/* Set used_features here for each table feature that is used.
+		 * (Currently no table features are defined)
+		 */
+
+		err = net_flow_table_check_features(dev, this.table_id,
+						    used_features);
+		if (err)
+			break;
+
 		switch (cmd) {
 		case NET_FLOW_TABLE_CMD_SET_FLOWS:
 			err = dev->netdev_ops->ndo_flow_set_flows(dev, &this);
-- 
2.1.3
