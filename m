From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC flow-net-next 06/10] net: flow: Add flow removed notification
Date: Mon, 29 Dec 2014 11:15:36 +0900
Message-ID: <1419819340-19000-7-git-send-email-simon.horman@netronome.com>
References: <1419819340-19000-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: John Fastabend <john.r.fastabend@intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:65315 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837AbaL2CQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Dec 2014 21:16:11 -0500
Received: by mail-pa0-f44.google.com with SMTP id et14so16495011pad.31
        for <netdev@vger.kernel.org>; Sun, 28 Dec 2014 18:16:10 -0800 (PST)
In-Reply-To: <1419819340-19000-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The purpose of this change is to provide an optional notification mechanism
for flow removal. It is intended to be used in conjunction with proposals
to optionally allow expiry of flows due to timeouts or resource contention.

The flow removed message is designed to have two forms:

1. A summary form where NET_FLOW_REMOVED_FLOW_COUNT is present,
   indicating the number of flows that were removed, and
   NET_FLOW_REMOVED_FLOWS_FLOWS is absent. In this form no details are
   provided about the removed flows beyond which table they were removed
   from and the reason for removal.

   The intention is to provide a lightweight mechanism that may be
   useful at times of resource contention.

2. A full form where NET_FLOW_REMOVED_FLOWS_FLOWS is present, including
   the flows that were removed, and NET_FLOW_REMOVED_FLOW_COUNT is absent.
   This form provides full details of the flows removed.

Inspired by flow removed notifications in OpenFlow.

Signed-off-by: Simon Horman <simon.horman@netronome.com>

---

Compile tested only
---
 include/linux/if_flow.h      |  3 ++
 include/uapi/linux/if_flow.h | 74 ++++++++++++++++++++++++++++++++++-
 net/core/flow_table.c        | 92 ++++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 164 insertions(+), 5 deletions(-)

diff --git a/include/linux/if_flow.h b/include/linux/if_flow.h
index 4af9794..351eb30 100644
--- a/include/linux/if_flow.h
+++ b/include/linux/if_flow.h
@@ -4,4 +4,7 @@
 #include <uapi/linux/if_flow.h>
 
 int net_flow_put_flow(struct sk_buff *skb, struct net_flow_flow *flow);
+int net_flow_put_rem_flow_summary_msg(struct net_device *dev,
+				      struct net *net, u32 portid, int table,
+				      u32 reason, int n_flows, gfp_t flags);
 #endif
diff --git a/include/uapi/linux/if_flow.h b/include/uapi/linux/if_flow.h
index 96905fa..d1643f3 100644
--- a/include/uapi/linux/if_flow.h
+++ b/include/uapi/linux/if_flow.h
@@ -36,6 +36,7 @@
  *       [NET_FLOW_TABLE_ATTR_SOURCE]
  *       [NET_FLOW_TABLE_ATTR_SIZE]
  *       [NET_FLOW_TABLE_ATTR_FEATURES]
+ *       [NET_FLOW_TABLE_ATTR_FLOW_REM]
  *	 [NET_FLOW_TABLE_ATTR_MATCHES]
  *	   [NET_FLOW_FIELD_REF]
  *	   [NET_FLOW_FIELD_REF]
@@ -159,6 +160,7 @@
  *     [NET_FLOW_ATTR_BYTE_COUNT]
  *     [NET_FLOW_ATTR_PACKET_COUNT]
  *     [NET_FLOW_ATTR_LAST_USED]
+ *     [NET_FLOW_ATTR_FLOW_REM]
  *     [NET_FLOW_MATCHES]
  *       [NET_FLOW_FIELD_REF]
  *       [NET_FLOW_FIELD_REF]
@@ -196,6 +198,39 @@
  * [NET_FLOW_NOTIFICATION]
  *   [NET_FLOW_NOTIFICATION_ATTR_TYPE]
  *   [NET_FLOW_NOTIFICATION_ATTR_PIDS]
+ *
+ * Flow Removed Notification <Kernel-to-user notification>
+ *
+ * [NET_FLOW_REM_FLOW]
+ *   [NET_FLOW_REM_FLOW_TABLE]
+ *   [NET_FLOW_REM_FLOW_REASON]
+ *   [NET_FLOW_REM_FLOW_COUNT]
+ *   [NET_FLOW_REM_FLOWS_FLOWS]
+ *      [NET_FLOW_FLOW]
+ *           [NET_FLOW_ATTR_TABLE]
+ *	     [NET_FLOW_ATTR_UID]
+ *	     [NET_FLOW_ATTR_PRIORITY]
+ *	     [NET_FLOW_ATTR_IDLE_TIMEOUT]
+ *	     [NET_FLOW_ATTR_HARD_TIMEOUT]
+ *	     [NET_FLOW_ATTR_BYTE_COUNT]
+ *	     [NET_FLOW_ATTR_PACKET_COUNT]
+ *	     [NET_FLOW_ATTR_USED]
+ *	     [NET_FLOW_ATTR_FLOW_REM]
+ *	     [NET_FLOW_ATTR_MATCHES]
+ *	        [NET_FLOW_FIELD_REF]
+ *	        [NET_FLOW_FIELD_REF]
+ *	        [...]
+ *	     [NET_FLOW_ATTR_ACTIONS]
+ *	        [NET_FLOW_ACTION]
+ *	          [NET_FLOW_ACTION_ATTR_UID]
+ *	          [NET_FLOW_ACTION_ATTR_SIGNATURE]
+ *		     [NET_FLOW_ACTION_ARG]
+ *	             [...]
+ *	        [NET_FLOW_ACTION]
+ *	          [..]
+ *	        [...]
+ *    [NET_FLOW_FLOW]
+ *	    [...]
  */
 
 #ifndef _UAPI_LINUX_IF_FLOW
@@ -397,7 +432,9 @@ enum {
  *               Zero for no timeout.
  * @byte_count bytes recieved
  * @byte_count packets recieved
- * @last_used time of most recent use (msec since system initialisation)
+ * @used time of most recent use (msec)
+ * @flow_rem flow notifications to send.
+ *           Bitmap of NET_FLOW_REM_F_*
  *
  * Flows must match all entries in match set.
  */
@@ -407,6 +444,7 @@ struct net_flow_flow {
 	int priority;
 	__u32 idle_timeout;
 	__u32 hard_timeout;
+	__u32 flow_rem;
 	__u64 byte_count;
 	__u64 packet_count;
 	__u64 last_used;
@@ -453,6 +491,7 @@ enum {
 	NET_FLOW_ATTR_BYTE_COUNT,
 	NET_FLOW_ATTR_PACKET_COUNT,
 	NET_FLOW_ATTR_LAST_USED,
+	NET_FLOW_ATTR_FLOW_REM,
 	__NET_FLOW_ATTR_MAX,
 };
 #define NET_FLOW_ATTR_MAX (__NET_FLOW_ATTR_MAX - 1)
@@ -464,6 +503,9 @@ enum {
  * @uid unique identifier for table
  * @source uid of parent table
  * @size max number of entries for table or -1 for unbounded
+ * @features Features supported by table. Bitmap of NET_FLOW_TABLE_F_*
+ * @flow_rem Flow removal notifications supported by table.
+             Bitmap of NET_FLOW_REM_F_*
  * @matches null terminated set of supported match types given by match uid
  * @actions null terminated set of supported action types given by action uid
  * @flows set of flows
@@ -474,6 +516,7 @@ struct net_flow_table {
 	int source;
 	int size;
 	__u32 features;
+	__u32 flow_rem;
 	struct net_flow_field_ref *matches;
 	net_flow_action_ref *actions;
 };
@@ -494,6 +537,7 @@ enum {
 	NET_FLOW_TABLE_ATTR_MATCHES,
 	NET_FLOW_TABLE_ATTR_ACTIONS,
 	NET_FLOW_TABLE_ATTR_FEATURES,
+	NET_FLOW_TABLE_ATTR_FLOW_REM,
 	__NET_FLOW_TABLE_ATTR_MAX,
 };
 #define NET_FLOW_TABLE_ATTR_MAX (__NET_FLOW_TABLE_ATTR_MAX - 1)
@@ -669,6 +713,29 @@ enum {
 #define NET_FLOW_NOTIFICATION_ATTR_MAX (__NET_FLOW_NOTIFICATION_ATTR_MAX - 1)
 
 enum {
+	NET_FLOW_REM_FLOW_UNSPEC,
+	NET_FLOW_REM_FLOW_TABLE,
+	NET_FLOW_REM_FLOW_REASON,
+	NET_FLOW_REM_FLOW_COUNT,
+	NET_FLOW_REM_FLOW_FLOWS,
+
+	__NET_FLOW_REM_FLOW_MAX,
+	NET_FLOW_REM_FLOW_MAX = (__NET_FLOW_REM_FLOW_MAX - 1),
+};
+
+enum net_flow_rem_reason {
+	NET_FLOW_REM_FLOW_REASON_IDLE_TIMEOUT,	/* Idle timeout */
+	NET_FLOW_REM_FLOW_REASON_HARD_TIMEOUT,	/* Hard timeout */
+	NET_FLOW_REM_FLOW_REASON_DELETE,	/* Deleted (by NET_FLOW_TABLE_CMD_DEL_FLOWS) */
+};
+
+enum {
+	NET_FLOW_REM_F_IDLE_TIMEOUT	= (1 << NET_FLOW_REM_FLOW_REASON_IDLE_TIMEOUT),
+	NET_FLOW_REM_F_HARD_TIMEOUT	= (1 << NET_FLOW_REM_FLOW_REASON_HARD_TIMEOUT),
+	NET_FLOW_REM_F_DELETE		= (1 << NET_FLOW_REM_FLOW_REASON_DELETE),
+};
+
+enum {
 	NET_FLOW_UNSPEC,
 	NET_FLOW_IDENTIFIER_TYPE,
 	NET_FLOW_IDENTIFIER,
@@ -681,12 +748,14 @@ enum {
 	NET_FLOW_FLOWS,
 	NET_FLOW_FLOWS_ERROR,
 	NET_FLOW_NOTIFICATION,
+	NET_FLOW_REM_FLOW,
 
 	__NET_FLOW_MAX,
 	NET_FLOW_MAX = (__NET_FLOW_MAX - 1),
 };
 
 enum {
+	/* Userspace commands. */
 	NET_FLOW_TABLE_CMD_GET_TABLES,
 	NET_FLOW_TABLE_CMD_GET_HEADERS,
 	NET_FLOW_TABLE_CMD_GET_ACTIONS,
@@ -704,6 +773,9 @@ enum {
 	NET_FLOW_TABLE_CMD_SET_NOTIFICATION,
 	NET_FLOW_TABLE_CMD_GET_NOTIFICATION,
 
+	/* Kernel-to-user notifications. */
+	NET_FLOW_TABLE_CMD_REM_FLOW,
+
 	__NET_FLOW_CMD_MAX,
 	NET_FLOW_CMD_MAX = (__NET_FLOW_CMD_MAX - 1),
 };
diff --git a/net/core/flow_table.c b/net/core/flow_table.c
index e8047eb..10b113f 100644
--- a/net/core/flow_table.c
+++ b/net/core/flow_table.c
@@ -58,6 +58,7 @@ struct nla_policy net_flow_flow_policy[NET_FLOW_ATTR_MAX + 1] = {
 	[NET_FLOW_ATTR_BYTE_COUNT]	= { .type = NLA_U64 },
 	[NET_FLOW_ATTR_PACKET_COUNT]	= { .type = NLA_U64 },
 	[NET_FLOW_ATTR_LAST_USED]	= { .type = NLA_U64 },
+	[NET_FLOW_ATTR_FLOW_REM]	= { .type = NLA_U32 },
 	[NET_FLOW_ATTR_MATCHES]	= { .type = NLA_NESTED },
 	[NET_FLOW_ATTR_ACTIONS]	= { .type = NLA_NESTED },
 };
@@ -70,6 +71,7 @@ struct nla_policy net_flow_table_policy[NET_FLOW_TABLE_ATTR_MAX + 1] = {
 	[NET_FLOW_TABLE_ATTR_SOURCE]	= { .type = NLA_U32 },
 	[NET_FLOW_TABLE_ATTR_SIZE]	= { .type = NLA_U32 },
 	[NET_FLOW_TABLE_ATTR_FEATURES]	= { .type = NLA_U32 },
+	[NET_FLOW_TABLE_ATTR_FLOW_REM]	= { .type = NLA_U32 },
 	[NET_FLOW_TABLE_ATTR_MATCHES]	= { .type = NLA_NESTED },
 	[NET_FLOW_TABLE_ATTR_ACTIONS]	= { .type = NLA_NESTED },
 };
@@ -190,7 +192,8 @@ int net_flow_put_flow_action(struct sk_buff *skb, struct net_flow_action *a)
 
 int net_flow_put_flow(struct sk_buff *skb, struct net_flow_flow *flow)
 {
-	struct nlattr *flows, *matches;
+	struct nlattr *flows;
+	struct nlattr *matches = NULL; /* must be null to unwind */
 	struct nlattr *actions = NULL; /* must be null to unwind */
 	int err, j, i = 0;
 
@@ -220,6 +223,10 @@ int net_flow_put_flow(struct sk_buff *skb, struct net_flow_flow *flow)
 	    nla_put_u32(skb, NET_FLOW_ATTR_LAST_USED, flow->last_used))
 		goto flows_put_failure;
 
+	if (flow->flow_rem &&
+	    nla_put_u32(skb, NET_FLOW_ATTR_FLOW_REM,
+			flow->flow_rem))
+
 	matches = nla_nest_start(skb, NET_FLOW_ATTR_MATCHES);
 	if (!matches)
 		goto flows_put_failure;
@@ -273,6 +280,10 @@ static int net_flow_put_table(struct net_device *dev,
 	    nla_put_u32(skb, NET_FLOW_TABLE_ATTR_FEATURES, t->features))
 		return -EMSGSIZE;
 
+	if (t->flow_rem &&
+	    nla_put_u32(skb, NET_FLOW_TABLE_ATTR_FLOW_REM, t->flow_rem))
+		return -EMSGSIZE;
+
 	matches = nla_nest_start(skb, NET_FLOW_TABLE_ATTR_MATCHES);
 	if (!matches)
 		return -EMSGSIZE;
@@ -556,6 +567,8 @@ static int net_flow_get_flow(struct net_flow_flow *flow, struct nlattr *attr)
 		flow->packet_count = nla_get_u64(f[NET_FLOW_ATTR_PACKET_COUNT]);
 	if (f[NET_FLOW_ATTR_LAST_USED])
 		flow->last_used = nla_get_u64(f[NET_FLOW_ATTR_LAST_USED]);
+	if (f[NET_FLOW_ATTR_FLOW_REM])
+		flow->flow_rem = nla_get_u32(f[NET_FLOW_ATTR_FLOW_REM]);
 
 	flow->matches = NULL;
 	flow->actions = NULL;
@@ -654,6 +667,9 @@ static int net_flow_get_table(struct net_flow_table *table, struct nlattr *nla)
 	table->features = tbl[NET_FLOW_TABLE_ATTR_FEATURES] ?
 		          nla_get_u32(tbl[NET_FLOW_TABLE_ATTR_FEATURES]) : 0;
 
+	table->flow_rem = tbl[NET_FLOW_TABLE_ATTR_FLOW_REM] ?
+		          nla_get_u32(tbl[NET_FLOW_TABLE_ATTR_FLOW_REM]) : 0;
+
 	if (tbl[NET_FLOW_TABLE_ATTR_MATCHES]) {
 		cnt = 0;
 		nla_for_each_nested(i, tbl[NET_FLOW_TABLE_ATTR_MATCHES], rem)
@@ -796,11 +812,13 @@ static struct net_flow_table *net_flow_table_get_table(struct net_device *dev,
 }
 
 static int net_flow_table_check_features(struct net_device *dev,
-					 int table_uid, u32 used_features)
+					 int table_uid, u32 used_features,
+					 u32 used_flow_rem)
 {
 	struct net_flow_table *table;
 
-	if (!used_features) /* No features: no problems */
+	/* No features, no flags: no problems */
+	if (!used_features && !used_flow_rem)
 		return 0;
 
 	table = net_flow_table_get_table(dev, table_uid);
@@ -810,6 +828,9 @@ static int net_flow_table_check_features(struct net_device *dev,
 	if ((used_features & table->features) != used_features)
 		return -EINVAL;
 
+	if ((used_flow_rem & table->flow_rem) != used_flow_rem)
+		return -EINVAL;
+
 	return 0;
 }
 
@@ -1415,7 +1436,8 @@ static int net_flow_table_cmd_flows(struct sk_buff *recv_skb,
 			used_features |= NET_FLOW_TABLE_F_PACKET_LAST_USED;
 
 		err = net_flow_table_check_features(dev, this.table_id,
-						    used_features);
+						    used_features,
+						    this.flow_rem);
 		if (err)
 			break;
 
@@ -1629,6 +1651,68 @@ err:
 	return err;
 }
 
+/**
+ * net_flow_put_rem_flow_summary_msg
+ * @dev: network device of flow table from which flows that were removed
+ * @net: network namespce to use when sending message
+ * @portid: netlink portid of the destination socket
+ * @table: table that flows were removed from
+ * @reason: reason for removal
+ * @n_flows: number of flows rem
+ * @flags: the type of memory to allocate
+ */
+int net_flow_put_rem_flow_summary_msg(struct net_device *dev,
+				      struct net *net, u32 portid, int table,
+				      u32 reason, int n_flows, gfp_t flags)
+{
+	int err = -ENOBUFS;
+	struct genl_info info = {
+		.dst_sk = net->genl_sock,
+		.snd_portid = portid,
+	};
+	struct genlmsghdr *hdr;
+	struct nlattr *start;
+	struct sk_buff *skb;
+
+	skb = genlmsg_new_unicast(NLMSG_DEFAULT_SIZE, &info, flags);
+	if (!skb)
+		goto err;
+
+	hdr = genlmsg_put(skb, 0, 0, &net_flow_nl_family, 0,
+			  NET_FLOW_TABLE_CMD_REM_FLOW);
+	if (!hdr)
+		goto err;
+
+	if (nla_put_u32(skb, NET_FLOW_IDENTIFIER_TYPE, NET_FLOW_IDENTIFIER_IFINDEX) ||
+	    nla_put_u32(skb, NET_FLOW_IDENTIFIER, dev->ifindex))
+		goto err;
+
+	start = nla_nest_start(skb, NET_FLOW_REM_FLOW);
+	if (!start) {
+		err = -EMSGSIZE;
+		goto err;
+	}
+
+	if (nla_put_u32(skb, NET_FLOW_REM_FLOW_TABLE, table) ||
+	    nla_put_u32(skb, NET_FLOW_REM_FLOW_REASON, reason) ||
+	    nla_put_u32(skb, NET_FLOW_REM_FLOW_COUNT, n_flows))
+		goto err;
+
+	nla_nest_end(skb, start);
+
+	err = genlmsg_end(skb, hdr);
+	if (err < 0)
+		goto err;
+
+	err = genlmsg_unicast(net, skb, portid);
+	skb = NULL;
+
+err:
+	kfree_skb(skb);
+	return err;
+}
+EXPORT_SYMBOL(net_flow_put_rem_flow_summary_msg);
+
 static const struct genl_ops net_flow_table_nl_ops[] = {
 	{
 		.cmd = NET_FLOW_TABLE_CMD_GET_TABLES,
-- 
2.1.3
