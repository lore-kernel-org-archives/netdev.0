From: Andy Zhou <azhou@ovn.org>
Subject: [net-next sample action optimization v2 4/4] Openvswitch: Refactor sample and recirc actions implementation
Date: Tue, 14 Mar 2017 16:08:11 -0700
Message-ID: <1489532891-33497-5-git-send-email-azhou@ovn.org>
References: <1489532891-33497-1-git-send-email-azhou@ovn.org>
Cc: joe@ovn.org, pshelar@ovn.org, Andy Zhou <azhou@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34886 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752154AbdCNXIc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 19:08:32 -0400
Received: by mail-pf0-f195.google.com with SMTP id 67so86101pfg.2
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 16:08:31 -0700 (PDT)
In-Reply-To: <1489532891-33497-1-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added execute_or_defer_actions() that both sample and recirc
action's implementation can use.

Signed-off-by: Andy Zhou <azhou@ovn.org>
---
 net/openvswitch/actions.c | 96 +++++++++++++++++++++++++++++------------------
 1 file changed, 59 insertions(+), 37 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 1638370..fd7d903 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -44,10 +44,6 @@
 #include "conntrack.h"
 #include "vport.h"
 
-static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
-			      struct sw_flow_key *key,
-			      const struct nlattr *attr, int len);
-
 struct deferred_action {
 	struct sk_buff *skb;
 	const struct nlattr *actions;
@@ -166,6 +162,12 @@ static bool is_flow_key_valid(const struct sw_flow_key *key)
 	return !(key->mac_proto & SW_FLOW_KEY_INVALID);
 }
 
+static int execute_or_defer_actions(struct datapath *dp, struct sk_buff *skb,
+				    struct sw_flow_key *clone,
+				    struct sw_flow_key *key,
+				    u32 *recirc_id,
+				    const struct nlattr *actions, int len);
+
 static void update_ethertype(struct sk_buff *skb, struct ethhdr *hdr,
 			     __be16 ethertype)
 {
@@ -941,7 +943,7 @@ static int sample(struct datapath *dp, struct sk_buff *skb,
 	struct nlattr *sample_arg;
 	struct sw_flow_key *orig_key = key;
 	int rem = nla_len(attr);
-	int err = 0;
+	int err;
 	const struct sample_arg *arg;
 
 	/* The first action is always 'OVS_SAMPLE_ATTR_ARG'. */
@@ -979,15 +981,8 @@ static int sample(struct datapath *dp, struct sk_buff *skb,
 		key = clone_key(key);
 	}
 
-	if (key) {
-		err = do_execute_actions(dp, skb, key, actions, rem);
-	} else if (!add_deferred_actions(skb, orig_key, actions, rem)) {
-
-		if (net_ratelimit())
-			pr_warn("%s: deferred action limit reached, drop sample action\n",
-				ovs_dp_name(dp));
-		kfree_skb(skb);
-	}
+	err = execute_or_defer_actions(dp, skb, key, orig_key, NULL,
+				       actions, rem);
 
 	if (!arg->exec)
 		__this_cpu_dec(exec_actions_level);
@@ -1105,8 +1100,7 @@ static int execute_recirc(struct datapath *dp, struct sk_buff *skb,
 			  struct sw_flow_key *key,
 			  const struct nlattr *a, int rem)
 {
-	struct sw_flow_key *recirc_key;
-	struct deferred_action *da;
+	u32 recirc_id;
 
 	if (!is_flow_key_valid(key)) {
 		int err;
@@ -1130,27 +1124,9 @@ static int execute_recirc(struct datapath *dp, struct sk_buff *skb,
 			return 0;
 	}
 
-	/* If within the limit of 'OVS_DEFERRED_ACTION_THRESHOLD',
-	 * recirc immediately, otherwise, defer it for later execution.
-	 */
-	recirc_key = clone_key(key);
-	if (recirc_key) {
-		recirc_key->recirc_id = nla_get_u32(a);
-		ovs_dp_process_packet(skb, recirc_key);
-	} else {
-		da = add_deferred_actions(skb, key, NULL, 0);
-		if (da) {
-			recirc_key = &da->pkt_key;
-			recirc_key->recirc_id = nla_get_u32(a);
-		} else {
-			/* Log an error in case action fifo is full.  */
-			kfree_skb(skb);
-			if (net_ratelimit())
-				pr_warn("%s: deferred action limit reached, drop recirc action\n",
-					ovs_dp_name(dp));
-		}
-	}
-	return 0;
+	recirc_id = nla_get_u32(a);
+	return execute_or_defer_actions(dp, skb, clone_key(key),
+					key, &recirc_id, NULL, 0);
 }
 
 /* Execute a list of actions against 'skb'. */
@@ -1286,6 +1262,52 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 	return 0;
 }
 
+static int execute_or_defer_actions(struct datapath *dp, struct sk_buff *skb,
+				    struct sw_flow_key *clone,
+				    struct sw_flow_key *key,
+				    u32 *recirc_id,
+				    const struct nlattr *actions, int len)
+{
+	struct deferred_action *da;
+
+	/* If within the limit of 'OVS_DEFERRED_ACTION_THRESHOLD',
+	 * recirc immediately, otherwise, defer it for later execution.
+	 */
+	if (clone) {
+		if (recirc_id) {
+			clone->recirc_id = *recirc_id;
+			ovs_dp_process_packet(skb, clone);
+			return 0;
+		} else {
+			return do_execute_actions(dp, skb, clone,
+						  actions, len);
+		}
+	}
+
+	da = add_deferred_actions(skb, key, actions, len);
+	if (da) {
+		if (recirc_id) {
+			key = &da->pkt_key;
+			key->recirc_id = *recirc_id;
+		}
+	} else {
+		/* Drop the SKB and log an error. */
+		kfree_skb(skb);
+
+		if (net_ratelimit()) {
+			if (recirc_id) {
+				pr_warn("%s: deferred action limit reached, drop recirc action\n",
+					ovs_dp_name(dp));
+			} else {
+				pr_warn("%s: deferred action limit reached, drop sample action\n",
+					ovs_dp_name(dp));
+			}
+		}
+	}
+
+	return 0;
+}
+
 static void process_deferred_actions(struct datapath *dp)
 {
 	struct action_fifo *fifo = this_cpu_ptr(action_fifos);
-- 
1.8.3.1
