From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC flow-net-next 07/10] net: flow: Add importance to flows
Date: Mon, 29 Dec 2014 11:15:37 +0900
Message-ID: <1419819340-19000-8-git-send-email-simon.horman@netronome.com>
References: <1419819340-19000-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: John Fastabend <john.r.fastabend@intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:46928 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751875AbaL2CQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Dec 2014 21:16:14 -0500
Received: by mail-pa0-f54.google.com with SMTP id fb1so16537590pad.27
        for <netdev@vger.kernel.org>; Sun, 28 Dec 2014 18:16:13 -0800 (PST)
In-Reply-To: <1419819340-19000-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is in preparation for adding support for eviction of flows
from tables when resource contention occurs. The importance of
a flow may be used to influence the eviction algorithm.

Inspired by the eviction feature of OpenFlow.

Signed-off-by: Simon Horman <simon.horman@netronome.com>

---

Compile tested only
---
 include/uapi/linux/if_flow.h | 14 ++++++++++++++
 net/core/flow_table.c        | 12 ++++++++++++
 2 files changed, 26 insertions(+)

diff --git a/include/uapi/linux/if_flow.h b/include/uapi/linux/if_flow.h
index d1643f3..91fcfb4 100644
--- a/include/uapi/linux/if_flow.h
+++ b/include/uapi/linux/if_flow.h
@@ -126,6 +126,7 @@
  *           [NET_FLOW_ATTR_TABLE]
  *	     [NET_FLOW_ATTR_UID]
  *	     [NET_FLOW_ATTR_PRIORITY]
+ *	     [NET_FLOW_ATTR_IMPORTANCE]
  *	     [NET_FLOW_ATTR_IDLE_TIMEOUT]
  *	     [NET_FLOW_ATTR_HARD_TIMEOUT]
  *	     [NET_FLOW_ATTR_BYTE_COUNT]
@@ -155,6 +156,7 @@
  *     [NET_FLOW_ATTR_TABLE]
  *     [NET_FLOW_ATTR_UID]
  *     [NET_FLOW_ATTR_PRIORITY]
+ *     [NET_FLOW_ATTR_IMPORTANCE]
  *     [NET_FLOW_ATTR_IDLE_TIMEOUT]
  *     [NET_FLOW_ATTR_HARD_TIMEOUT]
  *     [NET_FLOW_ATTR_BYTE_COUNT]
@@ -425,6 +427,11 @@ enum {
  *
  * @uid unique identifier for flow
  * @priority priority to execute flow match/action in table
+ * @importance importance of flow used to influence flow eviction algorithm
+ *             If eviction is enabled and uses importance then
+ *             flows with lower importance values must be evicted
+ *             before those with higher importance values.
+ *             The values 0xffff ff00 - 0xffff ffff are reserved for future use.
  * @match null terminated set of match uids match criteria
  * @action null terminated set of action uids to apply to match
  * @idle_timeout idle timeout of flow in seconds. Zero for no timeout.
@@ -442,6 +449,7 @@ struct net_flow_flow {
 	int table_id;
 	int uid;
 	int priority;
+	__u32 importance;
 	__u32 idle_timeout;
 	__u32 hard_timeout;
 	__u32 flow_rem;
@@ -484,6 +492,7 @@ enum {
 	NET_FLOW_ATTR_TABLE,
 	NET_FLOW_ATTR_UID,
 	NET_FLOW_ATTR_PRIORITY,
+	NET_FLOW_ATTR_IMPORTANCE,
 	NET_FLOW_ATTR_MATCHES,
 	NET_FLOW_ATTR_ACTIONS,
 	NET_FLOW_ATTR_IDLE_TIMEOUT,
@@ -496,6 +505,8 @@ enum {
 };
 #define NET_FLOW_ATTR_MAX (__NET_FLOW_ATTR_MAX - 1)
 
+#define NET_FLOW_ATTR_IMPORTANCE_MAX (0xfffffff00 - 1)
+
 /**
  * @struct net_flow_table
  * @brief define flow table with supported match/actions
@@ -557,6 +568,9 @@ enum {
 
 	/* Table supports last used counter for flows */
 	NET_FLOW_TABLE_F_PACKET_LAST_USED	= (1 << 4),
+
+	/* Table supports importance of flows */
+	NET_FLOW_TABLE_F_IMPORTANCE		= (1 << 5),
 };
 
 #if 0
diff --git a/net/core/flow_table.c b/net/core/flow_table.c
index 10b113f..0bf399c 100644
--- a/net/core/flow_table.c
+++ b/net/core/flow_table.c
@@ -53,6 +53,7 @@ struct nla_policy net_flow_flow_policy[NET_FLOW_ATTR_MAX + 1] = {
 	[NET_FLOW_ATTR_TABLE]	= { .type = NLA_U32 },
 	[NET_FLOW_ATTR_UID]		= { .type = NLA_U32 },
 	[NET_FLOW_ATTR_PRIORITY]	= { .type = NLA_U32 },
+	[NET_FLOW_ATTR_IMPORTANCE]	= { .type = NLA_U32 },
 	[NET_FLOW_ATTR_IDLE_TIMEOUT]	= { .type = NLA_U32 },
 	[NET_FLOW_ATTR_HARD_TIMEOUT]	= { .type = NLA_U32 },
 	[NET_FLOW_ATTR_BYTE_COUNT]	= { .type = NLA_U64 },
@@ -206,6 +207,11 @@ int net_flow_put_flow(struct sk_buff *skb, struct net_flow_flow *flow)
 	    nla_put_u32(skb, NET_FLOW_ATTR_PRIORITY, flow->priority))
 		goto flows_put_failure;
 
+	if (flow->importance &&
+	    (nla_put_u32(skb, NET_FLOW_ATTR_IMPORTANCE, flow->importance) ||
+	     flow->importance > NET_FLOW_ATTR_IMPORTANCE_MAX))
+		goto flows_put_failure;
+
 	if (flow->idle_timeout &&
 	    nla_put_u32(skb, NET_FLOW_ATTR_IDLE_TIMEOUT, flow->idle_timeout))
 		goto flows_put_failure;
@@ -556,6 +562,9 @@ static int net_flow_get_flow(struct net_flow_flow *flow, struct nlattr *attr)
 	flow->uid = nla_get_u32(f[NET_FLOW_ATTR_UID]);
 	flow->priority = nla_get_u32(f[NET_FLOW_ATTR_PRIORITY]);
 
+	if (f[NET_FLOW_ATTR_IMPORTANCE])
+		flow->importance = nla_get_u32(f[NET_FLOW_ATTR_IMPORTANCE]);
+
 	if (f[NET_FLOW_ATTR_IDLE_TIMEOUT])
 		flow->idle_timeout = nla_get_u32(f[NET_FLOW_ATTR_IDLE_TIMEOUT]);
 	if (f[NET_FLOW_ATTR_HARD_TIMEOUT])
@@ -1423,6 +1432,9 @@ static int net_flow_table_cmd_flows(struct sk_buff *recv_skb,
 		if (err)
 			goto out;
 
+		if (this.importance)
+			used_features |= NET_FLOW_TABLE_F_IMPORTANCE;
+
 		if (this.idle_timeout)
 			used_features |= NET_FLOW_TABLE_F_IDLE_TIMEOUT;
 		if (this.hard_timeout)
-- 
2.1.3
