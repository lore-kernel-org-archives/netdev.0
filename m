From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC flow-net-next 05/10] net: flow: Add get, set and del notifier commands
Date: Mon, 29 Dec 2014 11:15:35 +0900
Message-ID: <1419819340-19000-6-git-send-email-simon.horman@netronome.com>
References: <1419819340-19000-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: John Fastabend <john.r.fastabend@intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:65448 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827AbaL2CQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Dec 2014 21:16:08 -0500
Received: by mail-pa0-f54.google.com with SMTP id fb1so16408062pad.41
        for <netdev@vger.kernel.org>; Sun, 28 Dec 2014 18:16:07 -0800 (PST)
In-Reply-To: <1419819340-19000-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The purpose of these new commands is to manage the registration
of listeners for flow deletion notifications which will be
proposed in a subsequent patch.

Signed-off-by: Simon Horman <simon.horman@netronome.com>

---

Compile tested only
---
 include/linux/netdevice.h    |   6 ++
 include/uapi/linux/if_flow.h |  41 +++++++++++
 net/core/flow_table.c        | 161 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 208 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2defaae..1174ab7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1165,6 +1165,12 @@ struct net_device_ops {
 						      struct net_flow_flow *f);
 	int  (*ndo_flow_create_table)(struct net_device *dev,
 				      struct net_flow_table *t);
+	int			(*ndo_flow_set_notification)(struct net_device *dev,
+							     u32 type, const u32 *pids,
+							     size_t n_pids);
+	int			(*ndo_flow_get_notification)(struct net_device *dev,
+							     u32 type, u32 **pids,
+							     size_t *n_pids);
 };
 
 /**
diff --git a/include/uapi/linux/if_flow.h b/include/uapi/linux/if_flow.h
index 18214ea..96905fa 100644
--- a/include/uapi/linux/if_flow.h
+++ b/include/uapi/linux/if_flow.h
@@ -172,6 +172,30 @@
  *	 [NET_FLOW_ACTION]
  *	         [..]
  *	       [...]
+ *
+ * Set Flow Notification <Request>,
+ * Get Flow Notification <Request> and
+ * Get Flow Notification <Reply> description.
+ *
+ * Set Flow Notification registers netlink port ids to receive flow
+ * deletion notifications if the NET_FLOW_NOTIFICATION_PIDS attribute is
+ * present. Otherwise it unregisters port ids if they were previously
+ * registered by a Set Flow Notification with the
+ * NET_FLOW_NOTIFICATION_PIDS attribute present.
+ *
+ * Get Flow Notification reports the port ids if they were previously
+ * registered by a Set Flow Notification with the
+ * NET_FLOW_NOTIFICATION_PIDS.  If no ids are registered then the
+ * NET_FLOW_NOTIFICATION_PIDS attribute of the reply should be omitted.
+ *
+ * The NET_FLOW_NOTIFICATION_ATTR_PIDS attribute is an array of u32 values.
+ * If the attribute is present then it must contain at least one element.
+ * The implementation may choose to ignore some elements.  Currently the
+ * implementation ignores all elements other than the first one.
+ *
+ * [NET_FLOW_NOTIFICATION]
+ *   [NET_FLOW_NOTIFICATION_ATTR_TYPE]
+ *   [NET_FLOW_NOTIFICATION_ATTR_PIDS]
  */
 
 #ifndef _UAPI_LINUX_IF_FLOW
@@ -633,6 +657,18 @@ enum {
 };
 
 enum {
+	NET_FLOW_NOTIFICATION_TYPE_FLOW_REM,
+};
+
+enum {
+	NET_FLOW_NOTIFICATION_ATTR_UNSPEC,
+	NET_FLOW_NOTIFICATION_ATTR_TYPE,
+	NET_FLOW_NOTIFICATION_ATTR_PIDS,
+	__NET_FLOW_NOTIFICATION_ATTR_MAX,
+};
+#define NET_FLOW_NOTIFICATION_ATTR_MAX (__NET_FLOW_NOTIFICATION_ATTR_MAX - 1)
+
+enum {
 	NET_FLOW_UNSPEC,
 	NET_FLOW_IDENTIFIER_TYPE,
 	NET_FLOW_IDENTIFIER,
@@ -644,6 +680,7 @@ enum {
 	NET_FLOW_TABLE_GRAPH,
 	NET_FLOW_FLOWS,
 	NET_FLOW_FLOWS_ERROR,
+	NET_FLOW_NOTIFICATION,
 
 	__NET_FLOW_MAX,
 	NET_FLOW_MAX = (__NET_FLOW_MAX - 1),
@@ -663,6 +700,10 @@ enum {
 
 	NET_FLOW_TABLE_CMD_CREATE_TABLE,
 	NET_FLOW_TABLE_CMD_DESTROY_TABLE,
+
+	NET_FLOW_TABLE_CMD_SET_NOTIFICATION,
+	NET_FLOW_TABLE_CMD_GET_NOTIFICATION,
+
 	__NET_FLOW_CMD_MAX,
 	NET_FLOW_CMD_MAX = (__NET_FLOW_CMD_MAX - 1),
 };
diff --git a/net/core/flow_table.c b/net/core/flow_table.c
index 070e646..e8047eb 100644
--- a/net/core/flow_table.c
+++ b/net/core/flow_table.c
@@ -21,6 +21,7 @@
 #include <uapi/linux/if_flow.h>
 #include <linux/if_bridge.h>
 #include <linux/types.h>
+#include <net/sock.h>
 #include <net/netlink.h>
 #include <net/genetlink.h>
 #include <net/rtnetlink.h>
@@ -1478,6 +1479,156 @@ out:
 	return -EINVAL;
 }
 
+static const
+struct nla_policy net_flow_notification_policy[NET_FLOW_NOTIFICATION_ATTR_MAX + 1] = {
+	[NET_FLOW_NOTIFICATION_ATTR_TYPE] = { .type = NLA_U32,},
+	[NET_FLOW_NOTIFICATION_ATTR_PIDS] = { .type = NLA_U32,},
+};
+
+static int net_flow_table_cmd_set_notification(struct sk_buff *skb,
+					       struct genl_info *info)
+{
+	int err;
+	struct net_device *dev;
+	struct nlattr *tb[NET_FLOW_NOTIFICATION_ATTR_MAX+1];
+	u32 type;
+
+	dev = net_flow_table_get_dev(info);
+	if (!dev)
+		return -EINVAL;
+
+	if (!dev->netdev_ops->ndo_flow_set_notification) {
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+
+	if (!info->attrs[NET_FLOW_NOTIFICATION]) {
+		err = -EINVAL;
+		goto out;
+	}
+
+	err = nla_parse_nested(tb, NET_FLOW_NOTIFICATION_ATTR_MAX,
+			       info->attrs[NET_FLOW_NOTIFICATION],
+			       net_flow_notification_policy);
+	if (err)
+		goto out;
+
+	if (!tb[NET_FLOW_NOTIFICATION_ATTR_TYPE]) {
+		err = -EINVAL;
+		goto out;
+	}
+	type = nla_get_u32(tb[NET_FLOW_NOTIFICATION_ATTR_TYPE]);
+	if (type != NET_FLOW_NOTIFICATION_TYPE_FLOW_REM) {
+		err = -EOPNOTSUPP;
+		goto out;
+	}
+
+	if (tb[NET_FLOW_NOTIFICATION_ATTR_PIDS]) {
+		u32 pid;
+
+		/* Only the first pid is used at this time */
+		pid = nla_get_u32(tb[NET_FLOW_NOTIFICATION_ATTR_PIDS]);
+
+		err = dev->netdev_ops->ndo_flow_set_notification(dev, type,
+								 &pid, 1);
+	} else {
+		err = dev->netdev_ops->ndo_flow_set_notification(dev, type,
+								 NULL, 0);
+	}
+
+out:
+	dev_put(dev);
+	return err;
+}
+
+static int net_flow_table_cmd_get_notification(struct sk_buff *skb,
+					       struct genl_info *info)
+{
+	int err;
+	size_t n_pids;
+	struct genlmsghdr *hdr;
+	struct net_device *dev;
+	struct nlattr *start;
+	struct nlattr *tb[NET_FLOW_NOTIFICATION_ATTR_MAX+1];
+	struct sk_buff *msg = NULL;
+	u32 *pids, type;
+
+	dev = net_flow_table_get_dev(info);
+	if (!dev)
+		return -EINVAL;
+
+	if (!dev->netdev_ops->ndo_flow_get_notification) {
+		err = -EOPNOTSUPP;
+		goto err;
+	}
+
+	if (!info->attrs[NET_FLOW_NOTIFICATION]) {
+		err = -EINVAL;
+		goto err;
+	}
+
+	err = nla_parse_nested(tb, NET_FLOW_NOTIFICATION_ATTR_MAX,
+			       info->attrs[NET_FLOW_NOTIFICATION],
+			       net_flow_notification_policy);
+	if (err)
+		goto err;
+
+	if (!tb[NET_FLOW_NOTIFICATION_ATTR_TYPE]) {
+		err = -EINVAL;
+		goto err;
+	}
+	type = nla_get_u32(tb[NET_FLOW_NOTIFICATION_ATTR_TYPE]);
+
+	err = dev->netdev_ops->ndo_flow_get_notification(dev, type, &pids,
+							 &n_pids);
+	if (err)
+		goto err;
+
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!msg) {
+		err = -ENOBUFS;
+		goto err;
+	}
+
+	hdr = genlmsg_put(msg, info->snd_portid, info->snd_seq,
+			  &net_flow_nl_family, 0,
+			  NET_FLOW_TABLE_CMD_GET_NOTIFICATION);
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
+	start = nla_nest_start(msg, NET_FLOW_NOTIFICATION);
+	if (!start)
+		return -EMSGSIZE;
+
+	if (nla_put_u32(msg, NET_FLOW_NOTIFICATION_ATTR_TYPE, type) ||
+	    (n_pids > 0 &&
+	     nla_put_u32(msg, NET_FLOW_NOTIFICATION_ATTR_PIDS, pids[0])))
+		return -ENOBUFS;
+
+	nla_nest_end(msg, start);
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
+	nlmsg_free(msg);
+	dev_put(dev);
+	return err;
+}
+
 static const struct genl_ops net_flow_table_nl_ops[] = {
 	{
 		.cmd = NET_FLOW_TABLE_CMD_GET_TABLES,
@@ -1541,6 +1692,16 @@ static const struct genl_ops net_flow_table_nl_ops[] = {
 		.doit = net_flow_table_cmd_destroy_tables,
 		.flags = GENL_ADMIN_PERM,
 	},
+	{
+		.cmd = NET_FLOW_TABLE_CMD_SET_NOTIFICATION,
+		.doit = net_flow_table_cmd_set_notification,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = NET_FLOW_TABLE_CMD_GET_NOTIFICATION,
+		.doit = net_flow_table_cmd_get_notification,
+		.flags = GENL_ADMIN_PERM,
+	},
 };
 
 static int __init net_flow_nl_module_init(void)
-- 
2.1.3
