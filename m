From: Andy Zhou <azhou@ovn.org>
Subject: [net-next sample action optimization v4 4/4] Openvswitch: Refactor sample and recirc actions implementation
Date: Mon, 20 Mar 2017 16:32:30 -0700
Message-ID: <1490052750-60187-5-git-send-email-azhou@ovn.org>
References: <1490052750-60187-1-git-send-email-azhou@ovn.org>
Cc: joe@ovn.org, pshelar@ovn.org, Andy Zhou <azhou@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35755 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753819AbdCTXeH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 19:34:07 -0400
Received: by mail-pg0-f66.google.com with SMTP id g2so22347714pge.2
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 16:33:02 -0700 (PDT)
In-Reply-To: <1490052750-60187-1-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added clone_execute() that both the sample and the recirc
action implementation can use.

Signed-off-by: Andy Zhou <azhou@ovn.org>
---
 net/openvswitch/actions.c | 176 ++++++++++++++++++++++++----------------------
 1 file changed, 93 insertions(+), 83 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 3529f7b..e461067 100644
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
 
+static int clone_execute(struct datapath *dp, struct sk_buff *skb,
+			 struct sw_flow_key *key,
+			 u32 recirc_id,
+			 const struct nlattr *actions, int len,
+			 bool last, bool clone_flow_key);
+
 static void update_ethertype(struct sk_buff *skb, struct ethhdr *hdr,
 			     __be16 ethertype)
 {
@@ -938,10 +940,9 @@ static int sample(struct datapath *dp, struct sk_buff *skb,
 {
 	struct nlattr *actions;
 	struct nlattr *sample_arg;
-	struct sw_flow_key *orig_key = key;
 	int rem = nla_len(attr);
-	int err = 0;
 	const struct sample_arg *arg;
+	bool clone_flow_key;
 
 	/* The first action is always 'OVS_SAMPLE_ATTR_ARG'. */
 	sample_arg = nla_data(attr);
@@ -955,43 +956,9 @@ static int sample(struct datapath *dp, struct sk_buff *skb,
 		return 0;
 	}
 
-	/* Unless the last action, sample works on the clone of SKB.  */
-	skb = last ? skb : skb_clone(skb, GFP_ATOMIC);
-	if (!skb) {
-		/* Out of memory, skip this sample action.
-		 */
-		return 0;
-	}
-
-	/* In case the sample actions won't change 'key',
-	 * it can be used directly to execute sample actions.
-	 * Otherwise, allocate a new key from the
-	 * next recursion level of 'flow_keys'. If
-	 * successful, execute the sample actions without
-	 * deferring.
-	 *
-	 * Defer the sample actions if the recursion
-	 * limit has been reached.
-	 */
-	if (!arg->exec) {
-		__this_cpu_inc(exec_actions_level);
-		key = clone_key(key);
-	}
-
-	if (key) {
-		err = do_execute_actions(dp, skb, key, actions, rem);
-	} else if (!add_deferred_actions(skb, orig_key, actions, rem)) {
-
-		if (net_ratelimit())
-			pr_warn("%s: deferred action limit reached, drop sample action\n",
-				ovs_dp_name(dp));
-		kfree_skb(skb);
-	}
-
-	if (!arg->exec)
-		__this_cpu_dec(exec_actions_level);
-
-	return err;
+	clone_flow_key = !arg->exec;
+	return clone_execute(dp, skb, key, 0, actions, rem, last,
+			     clone_flow_key);
 }
 
 static void execute_hash(struct sk_buff *skb, struct sw_flow_key *key,
@@ -1102,10 +1069,9 @@ static int execute_masked_set_action(struct sk_buff *skb,
 
 static int execute_recirc(struct datapath *dp, struct sk_buff *skb,
 			  struct sw_flow_key *key,
-			  const struct nlattr *a, int rem)
+			  const struct nlattr *a, bool last)
 {
-	struct sw_flow_key *recirc_key;
-	struct deferred_action *da;
+	u32 recirc_id;
 
 	if (!is_flow_key_valid(key)) {
 		int err;
@@ -1116,40 +1082,8 @@ static int execute_recirc(struct datapath *dp, struct sk_buff *skb,
 	}
 	BUG_ON(!is_flow_key_valid(key));
 
-	if (!nla_is_last(a, rem)) {
-		/* Recirc action is the not the last action
-		 * of the action list, need to clone the skb.
-		 */
-		skb = skb_clone(skb, GFP_ATOMIC);
-
-		/* Skip the recirc action when out of memory, but
-		 * continue on with the rest of the action list.
-		 */
-		if (!skb)
-			return 0;
-	}
-
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
+	return clone_execute(dp, skb, key, recirc_id, NULL, 0, last, true);
 }
 
 /* Execute a list of actions against 'skb'. */
@@ -1221,9 +1155,11 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			err = pop_vlan(skb, key);
 			break;
 
-		case OVS_ACTION_ATTR_RECIRC:
-			err = execute_recirc(dp, skb, key, a, rem);
-			if (nla_is_last(a, rem)) {
+		case OVS_ACTION_ATTR_RECIRC: {
+			bool last = nla_is_last(a, rem);
+
+			err = execute_recirc(dp, skb, key, a, last);
+			if (last) {
 				/* If this is the last action, the skb has
 				 * been consumed or freed.
 				 * Return immediately.
@@ -1231,6 +1167,7 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 				return err;
 			}
 			break;
+		}
 
 		case OVS_ACTION_ATTR_SET:
 			err = execute_set_action(skb, key, nla_data(a));
@@ -1285,6 +1222,79 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 	return 0;
 }
 
+/* Execute the actions on the clone of the packet. The effect of the
+ * execution does not affect the original 'skb' nor the original 'key'.
+ *
+ * The execution may be deferred in case the actions can not be executed
+ * immediately.
+ */
+static int clone_execute(struct datapath *dp, struct sk_buff *skb,
+			 struct sw_flow_key *key, u32 recirc_id,
+			 const struct nlattr *actions, int len,
+			 bool last, bool clone_flow_key)
+{
+	struct deferred_action *da;
+	struct sw_flow_key *clone;
+
+	skb = last ? skb : skb_clone(skb, GFP_ATOMIC);
+	if (!skb) {
+		/* Out of memory, skip this action.
+		 */
+		return 0;
+	}
+
+	/* When clone_flow_key is false, the 'key' will not be change
+	 * by the actions, then the 'key' can be used directly.
+	 * Otherwise, try to clone key from the next recursion level of
+	 * 'flow_keys'. If clone is successful, execute the actions
+	 * without deferring.
+	 */
+	clone = clone_flow_key ? clone_key(key) : key;
+	if (clone) {
+		int err = 0;
+
+		if (actions) { /* Sample action */
+			if (clone_flow_key)
+				__this_cpu_inc(exec_actions_level);
+
+			err = do_execute_actions(dp, skb, clone,
+						 actions, len);
+
+			if (clone_flow_key)
+				__this_cpu_dec(exec_actions_level);
+		} else { /* Recirc action */
+			clone->recirc_id = recirc_id;
+			ovs_dp_process_packet(skb, clone);
+		}
+		return err;
+	}
+
+	/* Out of 'flow_keys' space. Defer actions */
+	da = add_deferred_actions(skb, key, actions, len);
+	if (da) {
+		if (!actions) { /* Recirc action */
+			key = &da->pkt_key;
+			key->recirc_id = recirc_id;
+		}
+	} else {
+		/* Out of per CPU action FIFO space. Drop the 'skb' and
+		 * log an error.
+		 */
+		kfree_skb(skb);
+
+		if (net_ratelimit()) {
+			if (actions) { /* Sample action */
+				pr_warn("%s: deferred action limit reached, drop sample action\n",
+					ovs_dp_name(dp));
+			} else {  /* Recirc action */
+				pr_warn("%s: deferred action limit reached, drop recirc action\n",
+					ovs_dp_name(dp));
+			}
+		}
+	}
+	return 0;
+}
+
 static void process_deferred_actions(struct datapath *dp)
 {
 	struct action_fifo *fifo = this_cpu_ptr(action_fifos);
-- 
1.8.3.1
