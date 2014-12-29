From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC flow-net-next 03/10] net: flow: Add timeouts to flows
Date: Mon, 29 Dec 2014 11:15:33 +0900
Message-ID: <1419819340-19000-4-git-send-email-simon.horman@netronome.com>
References: <1419819340-19000-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: John Fastabend <john.r.fastabend@intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:62364 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827AbaL2CQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Dec 2014 21:16:03 -0500
Received: by mail-pa0-f44.google.com with SMTP id et14so16472767pad.17
        for <netdev@vger.kernel.org>; Sun, 28 Dec 2014 18:16:02 -0800 (PST)
In-Reply-To: <1419819340-19000-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It may be useful for hardware flow table support for timeouts to be exposed
via the flow API. One possible use case of this is for Open vSwitch to use
the flow API in conjunction with its existing datapath flow management
scheme which in a nutshell treats the datapath as a cache that times out
idle entries.

Inspired by the timeouts present in OpenFlow.

Signed-off-by: Simon Horman <simon.horman@netronome.com>

---

Compile tested only

Note to John Fastabend: This patch adds u32 fields to struct net_flow_flow.
This is in contrast to existing int fields of that structure. It is unclear
to me which is best and in practice (2^31-1)s seems to be more than ample
for a timeout.
---
 include/uapi/linux/if_flow.h | 19 +++++++++++++++++++
 net/core/flow_table.c        | 21 ++++++++++++++++++---
 2 files changed, 37 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/if_flow.h b/include/uapi/linux/if_flow.h
index 5720698..28da45b 100644
--- a/include/uapi/linux/if_flow.h
+++ b/include/uapi/linux/if_flow.h
@@ -125,6 +125,8 @@
  *           [NET_FLOW_ATTR_TABLE]
  *	     [NET_FLOW_ATTR_UID]
  *	     [NET_FLOW_ATTR_PRIORITY]
+ *	     [NET_FLOW_ATTR_IDLE_TIMEOUT]
+ *	     [NET_FLOW_ATTR_HARD_TIMEOUT]
  *	     [NET_FLOW_ATTR_MATCHES]
  *	        [NET_FLOW_FIELD_REF]
  *	        [NET_FLOW_FIELD_REF]
@@ -149,6 +151,8 @@
  *     [NET_FLOW_ATTR_TABLE]
  *     [NET_FLOW_ATTR_UID]
  *     [NET_FLOW_ATTR_PRIORITY]
+ *     [NET_FLOW_ATTR_IDLE_TIMEOUT]
+ *     [NET_FLOW_ATTR_HARD_TIMEOUT]
  *     [NET_FLOW_MATCHES]
  *       [NET_FLOW_FIELD_REF]
  *       [NET_FLOW_FIELD_REF]
@@ -358,6 +362,9 @@ enum {
  * @priority priority to execute flow match/action in table
  * @match null terminated set of match uids match criteria
  * @action null terminated set of action uids to apply to match
+ * @idle_timeout idle timeout of flow in seconds. Zero for no timeout.
+ * @hard_timeout timeout of flow regardless of use in seconds.
+ *               Zero for no timeout.
  *
  * Flows must match all entries in match set.
  */
@@ -365,6 +372,8 @@ struct net_flow_flow {
 	int table_id;
 	int uid;
 	int priority;
+	__u32 idle_timeout;
+	__u32 hard_timeout;
 	struct net_flow_field_ref *matches;
 	struct net_flow_action *actions;
 };
@@ -403,6 +412,8 @@ enum {
 	NET_FLOW_ATTR_PRIORITY,
 	NET_FLOW_ATTR_MATCHES,
 	NET_FLOW_ATTR_ACTIONS,
+	NET_FLOW_ATTR_IDLE_TIMEOUT,
+	NET_FLOW_ATTR_HARD_TIMEOUT,
 	__NET_FLOW_ATTR_MAX,
 };
 #define NET_FLOW_ATTR_MAX (__NET_FLOW_ATTR_MAX - 1)
@@ -448,6 +459,14 @@ enum {
 };
 #define NET_FLOW_TABLE_ATTR_MAX (__NET_FLOW_TABLE_ATTR_MAX - 1)
 
+enum {
+	/* Table supports idle timeout of flows */
+	NET_FLOW_TABLE_F_IDLE_TIMEOUT		= (1 << 0),
+
+	/* Table supports idle timeout of flows */
+	NET_FLOW_TABLE_F_HARD_TIMEOUT		= (1 << 1),
+};
+
 #if 0
 struct net_flow_offset {
 	int offset;
diff --git a/net/core/flow_table.c b/net/core/flow_table.c
index 1ea88ed..89ba9bc 100644
--- a/net/core/flow_table.c
+++ b/net/core/flow_table.c
@@ -52,6 +52,8 @@ struct nla_policy net_flow_flow_policy[NET_FLOW_ATTR_MAX + 1] = {
 	[NET_FLOW_ATTR_TABLE]	= { .type = NLA_U32 },
 	[NET_FLOW_ATTR_UID]		= { .type = NLA_U32 },
 	[NET_FLOW_ATTR_PRIORITY]	= { .type = NLA_U32 },
+	[NET_FLOW_ATTR_IDLE_TIMEOUT]	= { .type = NLA_U32 },
+	[NET_FLOW_ATTR_HARD_TIMEOUT]	= { .type = NLA_U32 },
 	[NET_FLOW_ATTR_MATCHES]	= { .type = NLA_NESTED },
 	[NET_FLOW_ATTR_ACTIONS]	= { .type = NLA_NESTED },
 };
@@ -197,6 +199,13 @@ int net_flow_put_flow(struct sk_buff *skb, struct net_flow_flow *flow)
 	    nla_put_u32(skb, NET_FLOW_ATTR_PRIORITY, flow->priority))
 		goto flows_put_failure;
 
+	if (flow->idle_timeout &&
+	    nla_put_u32(skb, NET_FLOW_ATTR_IDLE_TIMEOUT, flow->idle_timeout))
+		goto flows_put_failure;
+	if (flow->hard_timeout &&
+	    nla_put_u32(skb, NET_FLOW_ATTR_HARD_TIMEOUT, flow->hard_timeout))
+		goto flows_put_failure;
+
 	matches = nla_nest_start(skb, NET_FLOW_ATTR_MATCHES);
 	if (!matches)
 		goto flows_put_failure;
@@ -522,6 +531,11 @@ static int net_flow_get_flow(struct net_flow_flow *flow, struct nlattr *attr)
 	flow->uid = nla_get_u32(f[NET_FLOW_ATTR_UID]);
 	flow->priority = nla_get_u32(f[NET_FLOW_ATTR_PRIORITY]);
 
+	if (f[NET_FLOW_ATTR_IDLE_TIMEOUT])
+		flow->idle_timeout = nla_get_u32(f[NET_FLOW_ATTR_IDLE_TIMEOUT]);
+	if (f[NET_FLOW_ATTR_HARD_TIMEOUT])
+		flow->hard_timeout = nla_get_u32(f[NET_FLOW_ATTR_HARD_TIMEOUT]);
+
 	flow->matches = NULL;
 	flow->actions = NULL;
 
@@ -1367,9 +1381,10 @@ static int net_flow_table_cmd_flows(struct sk_buff *recv_skb,
 		if (err)
 			goto out;
 
-		/* Set used_features here for each table feature that is used.
-		 * (Currently no table features are defined)
-		 */
+		if (this.idle_timeout)
+			used_features |= NET_FLOW_TABLE_F_IDLE_TIMEOUT;
+		if (this.hard_timeout)
+			used_features |= NET_FLOW_TABLE_F_HARD_TIMEOUT;
 
 		err = net_flow_table_check_features(dev, this.table_id,
 						    used_features);
-- 
2.1.3
