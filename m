From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC flow-net-next 08/10] net: flow: Add get and set table config commands
Date: Mon, 29 Dec 2014 11:15:38 +0900
Message-ID: <1419819340-19000-9-git-send-email-simon.horman@netronome.com>
References: <1419819340-19000-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: John Fastabend <john.r.fastabend@intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:62025 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827AbaL2CQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Dec 2014 21:16:17 -0500
Received: by mail-pa0-f51.google.com with SMTP id ey11so16565272pad.10
        for <netdev@vger.kernel.org>; Sun, 28 Dec 2014 18:16:16 -0800 (PST)
In-Reply-To: <1419819340-19000-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The intention of this is to allow querying and setting of
configuration attributes of tables which may be useful to manipulate
at runtime. A subsequent patch which proposes per-table eviction settings
will make use of this.

Signed-off-by: Simon Horman <simon.horman@netronome.com>

---

Compile tested only
---
 include/linux/netdevice.h    |   4 +
 include/uapi/linux/if_flow.h |  39 ++++++++++
 net/core/flow_table.c        | 176 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 219 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1174ab7..6073004 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1171,6 +1171,10 @@ struct net_device_ops {
 	int			(*ndo_flow_get_notification)(struct net_device *dev,
 							     u32 type, u32 **pids,
 							     size_t *n_pids);
+	struct net_flow_table_config *(*ndo_flow_table_get_table_config)(struct net_device *dev,
+									 int table);
+	int		        (*ndo_flow_table_set_table_config)(struct net_device *dev,
+								   struct net_flow_table_config *tc);
 };
 
 /**
diff --git a/include/uapi/linux/if_flow.h b/include/uapi/linux/if_flow.h
index 91fcfb4..bd29145 100644
--- a/include/uapi/linux/if_flow.h
+++ b/include/uapi/linux/if_flow.h
@@ -177,6 +177,17 @@
  *	         [..]
  *	       [...]
  *
+ * Get Table Settings <REQUEST> and <REPLY>, and
+ * Set Table Settings <REQUEST> description
+ *
+ * This is intended for configuring run-time attributes of a table.
+ * No such attributes are defined yet.
+ *
+ * [NET_FLOW_TABLE_CONFIGS]
+ *   [NET_FLOW_TABLE_CONFIG_TABLE]
+ *     [NET_FLOW_TABLE_CONFIG_TABLE_ATTR_UID]
+ *   ...
+ *
  * Set Flow Notification <Request>,
  * Get Flow Notification <Request> and
  * Get Flow Notification <Reply> description.
@@ -726,6 +737,30 @@ enum {
 };
 #define NET_FLOW_NOTIFICATION_ATTR_MAX (__NET_FLOW_NOTIFICATION_ATTR_MAX - 1)
 
+/**
+ * @struct net_flow_table
+ * @brief flow table configuration
+ *
+ * @table unique identifier of table
+ */
+struct net_flow_table_config {
+	int table;
+};
+
+enum {
+	NET_FLOW_TABLE_CONFIG_UNSPEC,
+	NET_FLOW_TABLE_CONFIG_TABLE,
+	__NET_FLOW_TABLE_CONFIG_MAX,
+};
+#define NET_FLOW_TABLE_CONFIG_MAX (__NET_FLOW_TABLE_CONFIG_MAX - 1)
+
+enum {
+	NET_FLOW_TABLE_CONFIG_TABLE_ATTR_UNSPEC,
+	NET_FLOW_TABLE_CONFIG_TABLE_ATTR_UID,
+	__NET_FLOW_TABLE_CONFIG_TABLE_ATTR_MAX,
+};
+#define NET_FLOW_TABLE_CONFIG_TABLE_ATTR_MAX (__NET_FLOW_TABLE_CONFIG_TABLE_ATTR_MAX - 1)
+
 enum {
 	NET_FLOW_REM_FLOW_UNSPEC,
 	NET_FLOW_REM_FLOW_TABLE,
@@ -763,6 +798,7 @@ enum {
 	NET_FLOW_FLOWS_ERROR,
 	NET_FLOW_NOTIFICATION,
 	NET_FLOW_REM_FLOW,
+	NET_FLOW_TABLE_CONFIGS,
 
 	__NET_FLOW_MAX,
 	NET_FLOW_MAX = (__NET_FLOW_MAX - 1),
@@ -784,6 +820,9 @@ enum {
 	NET_FLOW_TABLE_CMD_CREATE_TABLE,
 	NET_FLOW_TABLE_CMD_DESTROY_TABLE,
 
+	NET_FLOW_TABLE_CMD_SET_TABLE_CONFIG,
+	NET_FLOW_TABLE_CMD_GET_TABLE_CONFIG,
+
 	NET_FLOW_TABLE_CMD_SET_NOTIFICATION,
 	NET_FLOW_TABLE_CMD_GET_NOTIFICATION,
 
diff --git a/net/core/flow_table.c b/net/core/flow_table.c
index 0bf399c..6c44311 100644
--- a/net/core/flow_table.c
+++ b/net/core/flow_table.c
@@ -1514,6 +1514,172 @@ out:
 }
 
 static const
+
+struct nla_policy net_flow_table_config_policy[NET_FLOW_TABLE_CONFIG_MAX + 1] = {
+	[NET_FLOW_TABLE_CONFIG_TABLE]   = { .type = NLA_U32,},
+};
+
+static int net_flow_table_cmd_get_table_config(struct sk_buff *skb,
+					       struct genl_info *info)
+{
+	int rem, err;
+	struct genlmsghdr *hdr;
+	struct net_device *dev;
+	struct nlattr *tattr;
+	struct sk_buff *msg = NULL;
+
+	dev = net_flow_table_get_dev(info);
+	if (!dev)
+		return -EINVAL;
+
+	if (!dev->netdev_ops->ndo_flow_table_get_table_config) {
+		err = -EOPNOTSUPP;
+		goto err;
+	}
+
+	if (!info->attrs[NET_FLOW_TABLE_CONFIGS]) {
+		err = -EINVAL;
+		goto err;
+	}
+
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!msg) {
+		err = -ENOBUFS;
+		goto err;
+	}
+
+	hdr = genlmsg_put(msg, info->snd_portid, info->snd_seq,
+			  &net_flow_nl_family, 0,
+			  NET_FLOW_TABLE_CMD_GET_TABLE_CONFIG);
+	if (!hdr) {
+		err = -ENOBUFS;
+		goto err;
+	}
+
+	if (nla_put_u32(msg, NET_FLOW_IDENTIFIER_TYPE, NET_FLOW_IDENTIFIER_IFINDEX) ||
+	    nla_put_u32(msg, NET_FLOW_IDENTIFIER, dev->ifindex)) {
+		err = -ENOBUFS;
+		goto err;
+	}
+
+	nla_for_each_nested(tattr, info->attrs[NET_FLOW_TABLE_CONFIGS], rem) {
+		const struct net_flow_table_config *tc;
+		int table;
+		struct nlattr *config;
+		struct nlattr *tb[NET_FLOW_TABLE_CONFIG_TABLE_ATTR_MAX+1];
+
+		if (nla_type(tattr) != NET_FLOW_TABLE_CONFIG_TABLE)
+			continue;
+
+		err = nla_parse_nested(tb, NET_FLOW_TABLE_FLOWS_MAX,
+				       tattr, net_flow_table_flows_policy);
+		if (err)
+			goto err;
+
+		if (!tb[NET_FLOW_TABLE_CONFIG_TABLE_ATTR_UID]) {
+			err = -EINVAL;
+			goto err;
+		}
+		table = nla_get_u32(tb[NET_FLOW_TABLE_CONFIG_TABLE_ATTR_UID]);
+
+		tc = dev->netdev_ops->ndo_flow_table_get_table_config(dev, table);
+		if (IS_ERR(tc)) {
+			err = PTR_ERR(tc);
+			goto err;
+		}
+
+		config = nla_nest_start(msg, NET_FLOW_FLOWS);
+		if (!config) {
+			err = -EMSGSIZE;
+			goto err;
+		}
+
+		if (nla_put_u32(msg, NET_FLOW_TABLE_CONFIG_TABLE_ATTR_UID,
+				table)) {
+			err = -ENOBUFS;
+			goto err;
+		}
+
+		/* Write other attributes of tc: Currently none are defined. */
+
+		nla_nest_end(msg, config);
+	}
+
+	err = genlmsg_end(msg, hdr);
+	if (err < 0)
+		goto err;
+
+	dev_put(dev);
+
+	return genlmsg_reply(msg, info);
+
+err:
+	dev_put(dev);
+	nlmsg_free(msg);
+	return err;
+}
+
+static int net_flow_table_cmd_set_table_config(struct sk_buff *skb,
+					       struct genl_info *info)
+{
+	int rem, err;
+	struct net_device *dev;
+	struct nlattr *tattr;
+
+	dev = net_flow_table_get_dev(info);
+	if (!dev)
+		return -EINVAL;
+
+	if (!dev->netdev_ops->ndo_flow_table_get_table_config ||
+	    !dev->netdev_ops->ndo_flow_table_set_table_config) {
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+
+	if (!info->attrs[NET_FLOW_TABLE_CONFIGS]) {
+		err = -EINVAL;
+		goto out;
+	}
+
+	nla_for_each_nested(tattr, info->attrs[NET_FLOW_TABLE_CONFIGS], rem) {
+		int table;
+		struct net_flow_table_config *tc;
+		struct net_flow_table_config new_tc;
+		struct nlattr *tb[NET_FLOW_TABLE_CONFIG_TABLE_ATTR_MAX+1];
+
+		if (nla_type(tattr) != NET_FLOW_TABLE_CONFIG_TABLE)
+			continue;
+
+		err = nla_parse_nested(tb, NET_FLOW_TABLE_FLOWS_MAX,
+				       tattr, net_flow_table_flows_policy);
+		if (err)
+			goto out;
+
+		if (!tb[NET_FLOW_TABLE_CONFIG_TABLE_ATTR_UID]) {
+			err = -EINVAL;
+			goto out;
+		}
+		table = nla_get_u32(tb[NET_FLOW_TABLE_CONFIG_TABLE_ATTR_UID]);
+
+		tc = dev->netdev_ops->ndo_flow_table_get_table_config(dev, table);
+		if (IS_ERR(tc)) {
+			err = PTR_ERR(tc);
+			goto out;
+		}
+
+		new_tc = *tc;
+
+		err = dev->netdev_ops->ndo_flow_table_set_table_config(dev, &new_tc);
+		if (err)
+			goto out;
+	}
+
+out:
+	dev_put(dev);
+	return err;
+}
+
+static const
 struct nla_policy net_flow_notification_policy[NET_FLOW_NOTIFICATION_ATTR_MAX + 1] = {
 	[NET_FLOW_NOTIFICATION_ATTR_TYPE] = { .type = NLA_U32,},
 	[NET_FLOW_NOTIFICATION_ATTR_PIDS] = { .type = NLA_U32,},
@@ -1789,6 +1955,16 @@ static const struct genl_ops net_flow_table_nl_ops[] = {
 		.flags = GENL_ADMIN_PERM,
 	},
 	{
+		.cmd = NET_FLOW_TABLE_CMD_SET_TABLE_CONFIG,
+		.doit = net_flow_table_cmd_set_table_config,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = NET_FLOW_TABLE_CMD_GET_TABLE_CONFIG,
+		.doit = net_flow_table_cmd_get_table_config,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
 		.cmd = NET_FLOW_TABLE_CMD_SET_NOTIFICATION,
 		.doit = net_flow_table_cmd_set_notification,
 		.flags = GENL_ADMIN_PERM,
-- 
2.1.3
