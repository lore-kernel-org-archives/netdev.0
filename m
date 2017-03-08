From: Andy Zhou <azhou@ovn.org>
Subject: [RFC net-next sample action optimization 2/3] openvswitch: Refactor recirc key allocation.
Date: Tue,  7 Mar 2017 16:15:36 -0800
Message-ID: <1488932137-120383-3-git-send-email-azhou@ovn.org>
References: <1488932137-120383-1-git-send-email-azhou@ovn.org>
Cc: joe@ovn.org, pshelar@ovn.org, Andy Zhou <azhou@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34319 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933322AbdCHAop (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 19:44:45 -0500
Received: by mail-pg0-f66.google.com with SMTP id b5so1596095pgg.1
        for <netdev@vger.kernel.org>; Tue, 07 Mar 2017 16:43:04 -0800 (PST)
In-Reply-To: <1488932137-120383-1-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The logic of allocating and copy key for each 'exec_actions_level'
was specific to execute_recirc(). However, future patches will reuse
as well.  Refactor the logic into its own function clone_key().

Signed-off-by: Andy Zhou <azhou@ovn.org>
---
 net/openvswitch/actions.c | 72 +++++++++++++++++++++++++++++------------------
 1 file changed, 44 insertions(+), 28 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 75182e9..259aea9 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2007-2014 Nicira, Inc.
+ * Copyright (c) 2007-2017 Nicira, Inc.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
@@ -75,7 +75,7 @@ struct ovs_frag_data {
 
 #define DEFERRED_ACTION_FIFO_SIZE 10
 #define OVS_RECURSION_LIMIT 5
-#define OVS_DEFERRED_ACTION_THRESHOLD (OVS_RECURSION_LIMIT - 2)
+#define OVS_ACTION_RECURSION_THRESHOLD (OVS_RECURSION_LIMIT - 2)
 struct action_fifo {
 	int head;
 	int tail;
@@ -83,14 +83,32 @@ struct action_fifo {
 	struct deferred_action fifo[DEFERRED_ACTION_FIFO_SIZE];
 };
 
-struct recirc_keys {
-	struct sw_flow_key key[OVS_DEFERRED_ACTION_THRESHOLD];
+struct action_flow_keys {
+	struct sw_flow_key key[OVS_ACTION_RECURSION_THRESHOLD];
 };
 
 static struct action_fifo __percpu *action_fifos;
-static struct recirc_keys __percpu *recirc_keys;
+static struct action_flow_keys __percpu *flow_keys;
 static DEFINE_PER_CPU(int, exec_actions_level);
 
+/* Make a clone of the 'key', using the pre-allocated percpu 'flow_keys'
+ * space. Since the storage is pre-allocated, the caller does not
+ * need to check for NULL return pointer.
+ */
+static struct sw_flow_key *clone_key(const struct sw_flow_key *key_)
+{
+	struct action_flow_keys *keys = this_cpu_ptr(flow_keys);
+	int level = this_cpu_read(exec_actions_level);
+	struct sw_flow_key *key = NULL;
+
+	if (level <= OVS_ACTION_RECURSION_THRESHOLD) {
+		key = &keys->key[level - 1];
+		*key = *key_;
+	}
+
+	return key;
+}
+
 static void action_fifo_init(struct action_fifo *fifo)
 {
 	fifo->head = 0;
@@ -1090,8 +1108,8 @@ static int execute_recirc(struct datapath *dp, struct sk_buff *skb,
 			  struct sw_flow_key *key,
 			  const struct nlattr *a, int rem)
 {
+	struct sw_flow_key *recirc_key;
 	struct deferred_action *da;
-	int level;
 
 	if (!is_flow_key_valid(key)) {
 		int err;
@@ -1115,29 +1133,27 @@ static int execute_recirc(struct datapath *dp, struct sk_buff *skb,
 			return 0;
 	}
 
-	level = this_cpu_read(exec_actions_level);
-	if (level <= OVS_DEFERRED_ACTION_THRESHOLD) {
-		struct recirc_keys *rks = this_cpu_ptr(recirc_keys);
-		struct sw_flow_key *recirc_key = &rks->key[level - 1];
-
-		*recirc_key = *key;
+	/* If we are within the limit of 'OVS_ACTION_RECURSION_THRESHOLD',
+	 * recirc immediately, otherwise, defer it for later execution.
+	 */
+	recirc_key = clone_key(key);
+	if (recirc_key) {
 		recirc_key->recirc_id = nla_get_u32(a);
 		ovs_dp_process_packet(skb, recirc_key);
-
-		return 0;
-	}
-
-	da = add_deferred_actions(skb, key, NULL, 0);
-	if (da) {
-		da->pkt_key.recirc_id = nla_get_u32(a);
 	} else {
-		kfree_skb(skb);
-
-		if (net_ratelimit())
-			pr_warn("%s: deferred action limit reached, drop recirc action\n",
-				ovs_dp_name(dp));
+		da = add_deferred_actions(skb, key, NULL, 0);
+		if (da) {
+			recirc_key = &da->pkt_key;
+			recirc_key->recirc_id = nla_get_u32(a);
+		} else {
+			/* Log an error in case action fifo is full.
+			 */
+			kfree_skb(skb);
+			if (net_ratelimit())
+				pr_warn("%s: deferred action limit reached, drop recirc action\n",
+					ovs_dp_name(dp));
+		}
 	}
-
 	return 0;
 }
 
@@ -1327,8 +1343,8 @@ int action_fifos_init(void)
 	if (!action_fifos)
 		return -ENOMEM;
 
-	recirc_keys = alloc_percpu(struct recirc_keys);
-	if (!recirc_keys) {
+	flow_keys = alloc_percpu(struct action_flow_keys);
+	if (!flow_keys) {
 		free_percpu(action_fifos);
 		return -ENOMEM;
 	}
@@ -1339,5 +1355,5 @@ int action_fifos_init(void)
 void action_fifos_exit(void)
 {
 	free_percpu(action_fifos);
-	free_percpu(recirc_keys);
+	free_percpu(flow_keys);
 }
-- 
1.8.3.1
