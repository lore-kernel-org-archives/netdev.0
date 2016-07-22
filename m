From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v1 2/5] tipc: make cluster size threshold for monitoring configurable
Date: Fri, 22 Jul 2016 08:42:45 +0200
Message-ID: <1469169768-9214-3-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1469169768-9214-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>, <jon.maloy@ericsson.com>,
	<maloy@donjonn.com>, <ying.xue@windriver.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:61205 "EHLO
	sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752171AbcGVGnB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2016 02:43:01 -0400
In-Reply-To: <1469169768-9214-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In this commit, we introduce support to configure the minimum
threshold to activate the new link monitoring algorithm.

Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 include/uapi/linux/tipc_netlink.h | 11 +++++++++++
 net/tipc/monitor.c                | 12 ++++++++++++
 net/tipc/monitor.h                |  1 +
 net/tipc/netlink.c                | 15 +++++++++++++--
 net/tipc/netlink.h                |  1 +
 net/tipc/node.c                   | 27 +++++++++++++++++++++++++++
 net/tipc/node.h                   |  1 +
 7 files changed, 66 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/tipc_netlink.h b/include/uapi/linux/tipc_netlink.h
index d4c8f142ba63..d387b65a0d97 100644
--- a/include/uapi/linux/tipc_netlink.h
+++ b/include/uapi/linux/tipc_netlink.h
@@ -56,6 +56,7 @@ enum {
 	TIPC_NL_NET_GET,
 	TIPC_NL_NET_SET,
 	TIPC_NL_NAME_TABLE_GET,
+	TIPC_NL_MON_SET,
 
 	__TIPC_NL_CMD_MAX,
 	TIPC_NL_CMD_MAX = __TIPC_NL_CMD_MAX - 1
@@ -72,6 +73,7 @@ enum {
 	TIPC_NLA_NODE,			/* nest */
 	TIPC_NLA_NET,			/* nest */
 	TIPC_NLA_NAME_TABLE,		/* nest */
+	TIPC_NLA_MON,			/* nest */
 
 	__TIPC_NLA_MAX,
 	TIPC_NLA_MAX = __TIPC_NLA_MAX - 1
@@ -166,6 +168,15 @@ enum {
 	TIPC_NLA_NAME_TABLE_MAX = __TIPC_NLA_NAME_TABLE_MAX - 1
 };
 
+/* Monitor info */
+enum {
+	TIPC_NLA_MON_UNSPEC,
+	TIPC_NLA_MON_ACTIVATION_THRESHOLD,	/* u32 */
+
+	__TIPC_NLA_MON_MAX,
+	TIPC_NLA_MON_MAX = __TIPC_NLA_MON_MAX - 1
+};
+
 /* Publication info */
 enum {
 	TIPC_NLA_PUBL_UNSPEC,
diff --git a/net/tipc/monitor.c b/net/tipc/monitor.c
index 0d489e81fcca..3892d05b8b45 100644
--- a/net/tipc/monitor.c
+++ b/net/tipc/monitor.c
@@ -649,3 +649,15 @@ void tipc_mon_delete(struct net *net, int bearer_id)
 	kfree(self);
 	kfree(mon);
 }
+
+int tipc_nl_monitor_set_threshold(struct net *net, u32 cluster_size)
+{
+	struct tipc_net *tn = tipc_net(net);
+
+	if (cluster_size > TIPC_CLUSTER_SIZE)
+		return -EINVAL;
+
+	tn->mon_threshold = cluster_size;
+
+	return 0;
+}
diff --git a/net/tipc/monitor.h b/net/tipc/monitor.h
index 598459cbed5d..91f5dd09432b 100644
--- a/net/tipc/monitor.h
+++ b/net/tipc/monitor.h
@@ -69,5 +69,6 @@ void tipc_mon_get_state(struct net *net, u32 addr,
 			int bearer_id);
 void tipc_mon_remove_peer(struct net *net, u32 addr, int bearer_id);
 
+int tipc_nl_monitor_set_threshold(struct net *net, u32 cluster_size);
 extern const int tipc_max_domain_size;
 #endif
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index 56935df2167a..1e43ac0200ed 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -52,7 +52,8 @@ static const struct nla_policy tipc_nl_policy[TIPC_NLA_MAX + 1] = {
 	[TIPC_NLA_MEDIA]	= { .type = NLA_NESTED, },
 	[TIPC_NLA_NODE]		= { .type = NLA_NESTED, },
 	[TIPC_NLA_NET]		= { .type = NLA_NESTED, },
-	[TIPC_NLA_NAME_TABLE]	= { .type = NLA_NESTED, }
+	[TIPC_NLA_NAME_TABLE]	= { .type = NLA_NESTED, },
+	[TIPC_NLA_MON]		= { .type = NLA_NESTED, },
 };
 
 const struct nla_policy
@@ -61,6 +62,11 @@ tipc_nl_name_table_policy[TIPC_NLA_NAME_TABLE_MAX + 1] = {
 	[TIPC_NLA_NAME_TABLE_PUBL]	= { .type = NLA_NESTED }
 };
 
+const struct nla_policy tipc_nl_monitor_policy[TIPC_NLA_MON_MAX + 1] = {
+	[TIPC_NLA_MON_UNSPEC]			= { .type = NLA_UNSPEC },
+	[TIPC_NLA_MON_ACTIVATION_THRESHOLD]	= { .type = NLA_U32 },
+};
+
 const struct nla_policy tipc_nl_sock_policy[TIPC_NLA_SOCK_MAX + 1] = {
 	[TIPC_NLA_SOCK_UNSPEC]		= { .type = NLA_UNSPEC },
 	[TIPC_NLA_SOCK_ADDR]		= { .type = NLA_U32 },
@@ -214,7 +220,12 @@ static const struct genl_ops tipc_genl_v2_ops[] = {
 		.cmd	= TIPC_NL_NAME_TABLE_GET,
 		.dumpit	= tipc_nl_name_table_dump,
 		.policy = tipc_nl_policy,
-	}
+	},
+	{
+		.cmd	= TIPC_NL_MON_SET,
+		.doit	= tipc_nl_node_set_monitor,
+		.policy = tipc_nl_policy,
+	},
 };
 
 int tipc_nlmsg_parse(const struct nlmsghdr *nlh, struct nlattr ***attr)
diff --git a/net/tipc/netlink.h b/net/tipc/netlink.h
index ed1dbcb4afbd..4ba0ad422110 100644
--- a/net/tipc/netlink.h
+++ b/net/tipc/netlink.h
@@ -55,6 +55,7 @@ extern const struct nla_policy tipc_nl_prop_policy[];
 extern const struct nla_policy tipc_nl_bearer_policy[];
 extern const struct nla_policy tipc_nl_media_policy[];
 extern const struct nla_policy tipc_nl_udp_policy[];
+extern const struct nla_policy tipc_nl_monitor_policy[];
 
 int tipc_netlink_start(void);
 int tipc_netlink_compat_start(void);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index a3fc0a3f4077..fa524d73b031 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -1921,3 +1921,30 @@ out:
 
 	return skb->len;
 }
+
+int tipc_nl_node_set_monitor(struct sk_buff *skb, struct genl_info *info)
+{
+	struct nlattr *attrs[TIPC_NLA_MON_MAX + 1];
+	struct net *net = sock_net(skb->sk);
+	int err;
+
+	if (!info->attrs[TIPC_NLA_MON])
+		return -EINVAL;
+
+	err = nla_parse_nested(attrs, TIPC_NLA_MON_MAX,
+			       info->attrs[TIPC_NLA_MON],
+			       tipc_nl_monitor_policy);
+	if (err)
+		return err;
+
+	if (attrs[TIPC_NLA_MON_ACTIVATION_THRESHOLD]) {
+		u32 val;
+
+		val = nla_get_u32(attrs[TIPC_NLA_MON_ACTIVATION_THRESHOLD]);
+		err = tipc_nl_monitor_set_threshold(net, val);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 8264b3d97dc4..65aa12ede8a5 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -78,4 +78,5 @@ int tipc_nl_node_reset_link_stats(struct sk_buff *skb, struct genl_info *info);
 int tipc_nl_node_get_link(struct sk_buff *skb, struct genl_info *info);
 int tipc_nl_node_set_link(struct sk_buff *skb, struct genl_info *info);
 
+int tipc_nl_node_set_monitor(struct sk_buff *skb, struct genl_info *info);
 #endif
-- 
2.1.4
