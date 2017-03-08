From: Andy Zhou <azhou@ovn.org>
Subject: [RFC net-next sample action optimization 3/3] openvswitch: Optimize sample action for the clone use cases
Date: Tue,  7 Mar 2017 16:15:37 -0800
Message-ID: <1488932137-120383-4-git-send-email-azhou@ovn.org>
References: <1488932137-120383-1-git-send-email-azhou@ovn.org>
Cc: joe@ovn.org, pshelar@ovn.org, Andy Zhou <azhou@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34249 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756523AbdCHArz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 19:47:55 -0500
Received: by mail-pf0-f194.google.com with SMTP id o126so1751811pfb.1
        for <netdev@vger.kernel.org>; Tue, 07 Mar 2017 16:46:35 -0800 (PST)
In-Reply-To: <1488932137-120383-1-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the introduction of open flow 'clone' action, the OVS user space
can now translate the 'clone' action into kernel datapath 'sample'
action, with 100% probability, to ensure that the clone semantics,
which is that the packet seen by the clone action is the same as the
packet seen by the action after clone, is faithfully carried out
in the datapath.

While the sample action in the datpath has the matching semantics,
its implementation is only optimized for its original use.
Specifically, there are two limitation: First, there is a 3 level of
nesting restriction, enforced at the flow downloading time. This
limit turns out to be too restrictive for the 'clone' use case.
Second, the implementation avoid recursive call only if the sample
action list has a single userspace action.

The optimization implemented in this series removes the static
nesting limit check, instead, implement the run time recursion limit
check, and recursion avoidance similar to that of the 'recirc' action.
This optimization solve both #1 and #2 issues above.

Another optimization implemented is to avoid coping flow key as
long as the actions enclosed does not change the flow key. The
detection is performed only once at the flow downloading time.

The third optimization implemented is to rewrite the action list
at flow downloading time in order to save the fast path from parsing
the sample action list in its original form repeatedly.

Signed-off-by: Andy Zhou <azhou@ovn.org>
---
 net/openvswitch/actions.c      | 106 ++++++++++++++++++------------------
 net/openvswitch/datapath.h     |   7 +++
 net/openvswitch/flow_netlink.c | 118 ++++++++++++++++++++++++++++-------------
 3 files changed, 140 insertions(+), 91 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 259aea9..2e8c372 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -930,71 +930,52 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
 }
 
 static int sample(struct datapath *dp, struct sk_buff *skb,
-		  struct sw_flow_key *key, const struct nlattr *attr,
-		  const struct nlattr *actions, int actions_len)
+		  struct sw_flow_key *key, const struct nlattr *attr)
 {
-	const struct nlattr *acts_list = NULL;
-	const struct nlattr *a;
-	int rem;
-	u32 cutlen = 0;
-
-	for (a = nla_data(attr), rem = nla_len(attr); rem > 0;
-		 a = nla_next(a, &rem)) {
-		u32 probability;
-
-		switch (nla_type(a)) {
-		case OVS_SAMPLE_ATTR_PROBABILITY:
-			probability = nla_get_u32(a);
-			if (!probability || prandom_u32() > probability)
-				return 0;
-			break;
-
-		case OVS_SAMPLE_ATTR_ACTIONS:
-			acts_list = a;
-			break;
-		}
-	}
+	struct nlattr *actions;
+	struct nlattr *sample_arg;
+	struct sw_flow_key *orig = key;
+	int rem = nla_len(attr);
+	int err = 0;
+	const struct sample_arg *arg;
 
-	rem = nla_len(acts_list);
-	a = nla_data(acts_list);
+	/* The first action is always 'OVS_SAMPLE_ATTR_AUX'. */
+	sample_arg = nla_data(attr);
+	arg = nla_data(sample_arg);
+	actions = nla_next(sample_arg, &rem);
 
-	/* Actions list is empty, do nothing */
-	if (unlikely(!rem))
-		return 0;
+	if (arg->probability != U32_MAX)
+		if (!arg->probability || prandom_u32() > arg->probability)
+			return 0;
 
-	/* The only known usage of sample action is having a single user-space
-	 * action, or having a truncate action followed by a single user-space
-	 * action. Treat this usage as a special case.
-	 * The output_userspace() should clone the skb to be sent to the
-	 * user space. This skb will be consumed by its caller.
+	/* In case the sample actions won't change 'key',
+	 * we can use key for the clone execution.
+	 * Otherwise, try to allocate a key from the
+	 * next recursion level of 'flow_keys'. If
+	 * successful, we can still execute the clone
+	 * actions  without deferring.
+	 *
+	 * Defer the clone action if the action recursion
+	 * limit has been reached.
 	 */
-	if (unlikely(nla_type(a) == OVS_ACTION_ATTR_TRUNC)) {
-		struct ovs_action_trunc *trunc = nla_data(a);
-
-		if (skb->len > trunc->max_len)
-			cutlen = skb->len - trunc->max_len;
-
-		a = nla_next(a, &rem);
+	if (!arg->exec) {
+		__this_cpu_inc(exec_actions_level);
+		key = clone_key(key);
 	}
 
-	if (likely(nla_type(a) == OVS_ACTION_ATTR_USERSPACE &&
-		   nla_is_last(a, rem)))
-		return output_userspace(dp, skb, key, a, actions,
-					actions_len, cutlen);
-
-	skb = skb_clone(skb, GFP_ATOMIC);
-	if (!skb)
-		/* Skip the sample action when out of memory. */
-		return 0;
+	if (key) {
+		err = do_execute_actions(dp, skb, key, actions, rem);
+	} else if (!add_deferred_actions(skb, orig, actions, rem)) {
 
-	if (!add_deferred_actions(skb, key, nla_data(acts_list),
-				  nla_len(acts_list))) {
 		if (net_ratelimit())
-			pr_warn("%s: deferred actions limit reached, dropping sample action\n",
+			pr_warn("%s: deferred action limit reached, drop clone action\n",
 				ovs_dp_name(dp));
-
 		kfree_skb(skb);
 	}
+
+	if (!arg->exec)
+		__this_cpu_dec(exec_actions_level);
+
 	return 0;
 }
 
@@ -1246,9 +1227,24 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			err = execute_masked_set_action(skb, key, nla_data(a));
 			break;
 
-		case OVS_ACTION_ATTR_SAMPLE:
-			err = sample(dp, skb, key, a, attr, len);
+		case OVS_ACTION_ATTR_SAMPLE: {
+			bool last = nla_is_last(a, rem);
+			struct sk_buff *clone_skb;
+
+			clone_skb = last ? skb : skb_clone(skb, GFP_ATOMIC);
+
+			if (!clone_skb)
+				/* Out of memory, skip this sample action.
+				 */
+				break;
+
+			err = sample(dp, clone_skb, key, a);
+			if (last)
+				return err;
+
+			pr_err("executing sample");
 			break;
+			}
 
 		case OVS_ACTION_ATTR_CT:
 			if (!is_flow_key_valid(key)) {
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 1c6e937..d7a6e803 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -220,4 +220,11 @@ int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb,
 	if (logging_allowed && net_ratelimit())			\
 		pr_info("netlink: " fmt "\n", ##__VA_ARGS__);	\
 } while (0)
+
+#define OVS_SAMPLE_ATTR_ARG  (OVS_ACTION_ATTR_MAX + 1)
+struct sample_arg {
+	bool exec;
+	u32  probability;
+};
+
 #endif /* datapath.h */
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 6f5fa50..0e7cf13 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2007-2014 Nicira, Inc.
+ * Copyright (c) 2007-2017 Nicira, Inc.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
@@ -59,6 +59,39 @@ struct ovs_len_tbl {
 #define OVS_ATTR_NESTED -1
 #define OVS_ATTR_VARIABLE -2
 
+static bool actions_may_change_flow(const struct nlattr *actions)
+{
+	struct nlattr *nla;
+	int rem;
+
+	nla_for_each_nested(nla, actions, rem) {
+		u16 action = nla_type(nla);
+
+		switch (action) {
+		case OVS_ACTION_ATTR_OUTPUT:
+		case OVS_ACTION_ATTR_RECIRC:
+		case OVS_ACTION_ATTR_USERSPACE:
+		case OVS_ACTION_ATTR_SAMPLE:
+		case OVS_ACTION_ATTR_TRUNC:
+			break;
+
+		case OVS_ACTION_ATTR_PUSH_MPLS:
+		case OVS_ACTION_ATTR_POP_MPLS:
+		case OVS_ACTION_ATTR_PUSH_VLAN:
+		case OVS_ACTION_ATTR_POP_VLAN:
+		case OVS_ACTION_ATTR_SET:
+		case OVS_ACTION_ATTR_SET_MASKED:
+		case OVS_ACTION_ATTR_HASH:
+		case OVS_ACTION_ATTR_CT:
+		case OVS_ACTION_ATTR_PUSH_ETH:
+		case OVS_ACTION_ATTR_POP_ETH:
+		default:
+			return true;
+		}
+	}
+	return false;
+}
+
 static void update_range(struct sw_flow_match *match,
 			 size_t offset, size_t size, bool is_mask)
 {
@@ -2027,12 +2060,14 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 static int validate_and_copy_sample(struct net *net, const struct nlattr *attr,
 				    const struct sw_flow_key *key, int depth,
 				    struct sw_flow_actions **sfa,
-				    __be16 eth_type, __be16 vlan_tci, bool log)
+				    __be16 eth_type, __be16 vlan_tci,
+				    bool log, bool last)
 {
 	const struct nlattr *attrs[OVS_SAMPLE_ATTR_MAX + 1];
 	const struct nlattr *probability, *actions;
 	const struct nlattr *a;
-	int rem, start, err, st_acts;
+	int rem, start, err;
+	struct sample_arg arg;
 
 	memset(attrs, 0, sizeof(attrs));
 	nla_for_each_nested(a, attr, rem) {
@@ -2056,20 +2091,32 @@ static int validate_and_copy_sample(struct net *net, const struct nlattr *attr,
 	start = add_nested_action_start(sfa, OVS_ACTION_ATTR_SAMPLE, log);
 	if (start < 0)
 		return start;
-	err = ovs_nla_add_action(sfa, OVS_SAMPLE_ATTR_PROBABILITY,
-				 nla_data(probability), sizeof(u32), log);
+
+	/* When both skb and flow may be changed, put the sample
+	 * into a deferred fifo. On the other hand, if only skb
+	 * may be modified, the actions can be executed in place.
+	 *
+	 * Do this analysis at the flow installation time.
+	 * Set 'clone_action->exec' to true if the actions can be
+	 * executed without being deferred.
+	 *
+	 * If the sample is the last action, it can always be excuted
+	 * rather than deferred.
+	 */
+	arg.exec = last || !actions_may_change_flow(actions);
+	arg.probability = nla_get_u32(probability);
+
+	err = ovs_nla_add_action(sfa, OVS_SAMPLE_ATTR_ARG, &arg, sizeof(arg),
+				 log);
 	if (err)
 		return err;
-	st_acts = add_nested_action_start(sfa, OVS_SAMPLE_ATTR_ACTIONS, log);
-	if (st_acts < 0)
-		return st_acts;
 
-	err = __ovs_nla_copy_actions(net, actions, key, depth + 1, sfa,
+	err = __ovs_nla_copy_actions(net, actions, key, depth, sfa,
 				     eth_type, vlan_tci, log);
+
 	if (err)
 		return err;
 
-	add_nested_action_end(*sfa, st_acts);
 	add_nested_action_end(*sfa, start);
 
 	return 0;
@@ -2554,8 +2601,10 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 			break;
 
 		case OVS_ACTION_ATTR_SAMPLE:
-			err = validate_and_copy_sample(net, a, key, depth, sfa,
-						       eth_type, vlan_tci, log);
+			err = validate_and_copy_sample(net, a, key, depth,
+						       sfa, eth_type,
+						       vlan_tci, log,
+						       nla_is_last(a, rem));
 			if (err)
 				return err;
 			skip_copy = true;
@@ -2621,39 +2670,36 @@ int ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 	return err;
 }
 
-static int sample_action_to_attr(const struct nlattr *attr, struct sk_buff *skb)
+static int sample_action_to_attr(const struct nlattr *attr,
+				 struct sk_buff *skb)
 {
-	const struct nlattr *a;
-	struct nlattr *start;
-	int err = 0, rem;
+	struct nlattr *start, *ac_start, *sample_arg;
+	int err = 0, rem = nla_len(attr);
+	const struct sample_arg *arg;
+	struct nlattr *actions;
 
 	start = nla_nest_start(skb, OVS_ACTION_ATTR_SAMPLE);
 	if (!start)
 		return -EMSGSIZE;
 
-	nla_for_each_nested(a, attr, rem) {
-		int type = nla_type(a);
-		struct nlattr *st_sample;
+	sample_arg = nla_data(attr);
+	arg = nla_data(sample_arg);
+	actions = nla_next(sample_arg, &rem);
 
-		switch (type) {
-		case OVS_SAMPLE_ATTR_PROBABILITY:
-			if (nla_put(skb, OVS_SAMPLE_ATTR_PROBABILITY,
-				    sizeof(u32), nla_data(a)))
-				return -EMSGSIZE;
-			break;
-		case OVS_SAMPLE_ATTR_ACTIONS:
-			st_sample = nla_nest_start(skb, OVS_SAMPLE_ATTR_ACTIONS);
-			if (!st_sample)
-				return -EMSGSIZE;
-			err = ovs_nla_put_actions(nla_data(a), nla_len(a), skb);
-			if (err)
-				return err;
-			nla_nest_end(skb, st_sample);
-			break;
-		}
-	}
+	if (nla_put_u32(skb, OVS_SAMPLE_ATTR_PROBABILITY, arg->probability))
+		return -EMSGSIZE;
 
+	ac_start = nla_nest_start(skb, OVS_SAMPLE_ATTR_ACTIONS);
+	if (!ac_start)
+		return -EMSGSIZE;
+
+	err = ovs_nla_put_actions(actions, rem, skb);
+	if (err)
+		return err;
+
+	nla_nest_end(skb, ac_start);
 	nla_nest_end(skb, start);
+
 	return err;
 }
 
-- 
1.8.3.1
