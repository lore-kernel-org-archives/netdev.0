From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC flow-net-next 04/10] net: flow: Add counters to flows
Date: Mon, 29 Dec 2014 11:15:34 +0900
Message-ID: <1419819340-19000-5-git-send-email-simon.horman@netronome.com>
References: <1419819340-19000-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: John Fastabend <john.r.fastabend@intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:37742 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837AbaL2CQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Dec 2014 21:16:05 -0500
Received: by mail-pa0-f42.google.com with SMTP id et14so16448911pad.15
        for <netdev@vger.kernel.org>; Sun, 28 Dec 2014 18:16:05 -0800 (PST)
In-Reply-To: <1419819340-19000-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It may be useful for hardware flow table support for counters to be exposed
via the flow API. One possible use case of this is for Open vSwitch to use
the flow API in conjunction with its existing datapath flow management
scheme which in a nutshell treats the datapath as a cache that times out
idle entries.

This patch exposes optionally exposes three counters:
- Number of packets that have matched a flow
- Number of bytes of packets that have matched a flow
- The time in ms when the flow was last hit

Inspired by the flow counters present in Open Flow.

Signed-off-by: Simon Horman <simon.horman@netronome.com>

---

Compile tested only
---
 include/uapi/linux/if_flow.h | 24 ++++++++++++++++++++++++
 net/core/flow_table.c        | 27 +++++++++++++++++++++++++++
 2 files changed, 51 insertions(+)

diff --git a/include/uapi/linux/if_flow.h b/include/uapi/linux/if_flow.h
index 28da45b..18214ea 100644
--- a/include/uapi/linux/if_flow.h
+++ b/include/uapi/linux/if_flow.h
@@ -127,6 +127,9 @@
  *	     [NET_FLOW_ATTR_PRIORITY]
  *	     [NET_FLOW_ATTR_IDLE_TIMEOUT]
  *	     [NET_FLOW_ATTR_HARD_TIMEOUT]
+ *	     [NET_FLOW_ATTR_BYTE_COUNT]
+ *	     [NET_FLOW_ATTR_PACKET_COUNT]
+ *	     [NET_FLOW_ATTR_LAST_USED]
  *	     [NET_FLOW_ATTR_MATCHES]
  *	        [NET_FLOW_FIELD_REF]
  *	        [NET_FLOW_FIELD_REF]
@@ -153,6 +156,9 @@
  *     [NET_FLOW_ATTR_PRIORITY]
  *     [NET_FLOW_ATTR_IDLE_TIMEOUT]
  *     [NET_FLOW_ATTR_HARD_TIMEOUT]
+ *     [NET_FLOW_ATTR_BYTE_COUNT]
+ *     [NET_FLOW_ATTR_PACKET_COUNT]
+ *     [NET_FLOW_ATTR_LAST_USED]
  *     [NET_FLOW_MATCHES]
  *       [NET_FLOW_FIELD_REF]
  *       [NET_FLOW_FIELD_REF]
@@ -365,6 +371,9 @@ enum {
  * @idle_timeout idle timeout of flow in seconds. Zero for no timeout.
  * @hard_timeout timeout of flow regardless of use in seconds.
  *               Zero for no timeout.
+ * @byte_count bytes recieved
+ * @byte_count packets recieved
+ * @last_used time of most recent use (msec since system initialisation)
  *
  * Flows must match all entries in match set.
  */
@@ -374,6 +383,9 @@ struct net_flow_flow {
 	int priority;
 	__u32 idle_timeout;
 	__u32 hard_timeout;
+	__u64 byte_count;
+	__u64 packet_count;
+	__u64 last_used;
 	struct net_flow_field_ref *matches;
 	struct net_flow_action *actions;
 };
@@ -414,6 +426,9 @@ enum {
 	NET_FLOW_ATTR_ACTIONS,
 	NET_FLOW_ATTR_IDLE_TIMEOUT,
 	NET_FLOW_ATTR_HARD_TIMEOUT,
+	NET_FLOW_ATTR_BYTE_COUNT,
+	NET_FLOW_ATTR_PACKET_COUNT,
+	NET_FLOW_ATTR_LAST_USED,
 	__NET_FLOW_ATTR_MAX,
 };
 #define NET_FLOW_ATTR_MAX (__NET_FLOW_ATTR_MAX - 1)
@@ -465,6 +480,15 @@ enum {
 
 	/* Table supports idle timeout of flows */
 	NET_FLOW_TABLE_F_HARD_TIMEOUT		= (1 << 1),
+
+	/* Table supports byte counter for flows */
+	NET_FLOW_TABLE_F_BYTE_COUNT		= (1 << 2),
+
+	/* Table supports packet counter for flows */
+	NET_FLOW_TABLE_F_PACKET_COUNT		= (1 << 3),
+
+	/* Table supports last used counter for flows */
+	NET_FLOW_TABLE_F_PACKET_LAST_USED	= (1 << 4),
 };
 
 #if 0
diff --git a/net/core/flow_table.c b/net/core/flow_table.c
index 89ba9bc..070e646 100644
--- a/net/core/flow_table.c
+++ b/net/core/flow_table.c
@@ -54,6 +54,9 @@ struct nla_policy net_flow_flow_policy[NET_FLOW_ATTR_MAX + 1] = {
 	[NET_FLOW_ATTR_PRIORITY]	= { .type = NLA_U32 },
 	[NET_FLOW_ATTR_IDLE_TIMEOUT]	= { .type = NLA_U32 },
 	[NET_FLOW_ATTR_HARD_TIMEOUT]	= { .type = NLA_U32 },
+	[NET_FLOW_ATTR_BYTE_COUNT]	= { .type = NLA_U64 },
+	[NET_FLOW_ATTR_PACKET_COUNT]	= { .type = NLA_U64 },
+	[NET_FLOW_ATTR_LAST_USED]	= { .type = NLA_U64 },
 	[NET_FLOW_ATTR_MATCHES]	= { .type = NLA_NESTED },
 	[NET_FLOW_ATTR_ACTIONS]	= { .type = NLA_NESTED },
 };
@@ -206,6 +209,16 @@ int net_flow_put_flow(struct sk_buff *skb, struct net_flow_flow *flow)
 	    nla_put_u32(skb, NET_FLOW_ATTR_HARD_TIMEOUT, flow->hard_timeout))
 		goto flows_put_failure;
 
+	if (flow->byte_count &&
+	    nla_put_u32(skb, NET_FLOW_ATTR_BYTE_COUNT, flow->byte_count))
+		goto flows_put_failure;
+	if (flow->packet_count &&
+	    nla_put_u32(skb, NET_FLOW_ATTR_PACKET_COUNT, flow->packet_count))
+		goto flows_put_failure;
+	if (flow->last_used &&
+	    nla_put_u32(skb, NET_FLOW_ATTR_LAST_USED, flow->last_used))
+		goto flows_put_failure;
+
 	matches = nla_nest_start(skb, NET_FLOW_ATTR_MATCHES);
 	if (!matches)
 		goto flows_put_failure;
@@ -536,6 +549,13 @@ static int net_flow_get_flow(struct net_flow_flow *flow, struct nlattr *attr)
 	if (f[NET_FLOW_ATTR_HARD_TIMEOUT])
 		flow->hard_timeout = nla_get_u32(f[NET_FLOW_ATTR_HARD_TIMEOUT]);
 
+	if (f[NET_FLOW_ATTR_BYTE_COUNT])
+		flow->byte_count = nla_get_u64(f[NET_FLOW_ATTR_BYTE_COUNT]);
+	if (f[NET_FLOW_ATTR_PACKET_COUNT])
+		flow->packet_count = nla_get_u64(f[NET_FLOW_ATTR_PACKET_COUNT]);
+	if (f[NET_FLOW_ATTR_LAST_USED])
+		flow->last_used = nla_get_u64(f[NET_FLOW_ATTR_LAST_USED]);
+
 	flow->matches = NULL;
 	flow->actions = NULL;
 
@@ -1386,6 +1406,13 @@ static int net_flow_table_cmd_flows(struct sk_buff *recv_skb,
 		if (this.hard_timeout)
 			used_features |= NET_FLOW_TABLE_F_HARD_TIMEOUT;
 
+		if (this.byte_count)
+			used_features |= NET_FLOW_TABLE_F_BYTE_COUNT;
+		if (this.packet_count)
+			used_features |= NET_FLOW_TABLE_F_PACKET_COUNT;
+		if (this.last_used)
+			used_features |= NET_FLOW_TABLE_F_PACKET_LAST_USED;
+
 		err = net_flow_table_check_features(dev, this.table_id,
 						    used_features);
 		if (err)
-- 
2.1.3
