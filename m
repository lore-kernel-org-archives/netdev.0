From: Andy Zhou <azhou@ovn.org>
Subject: [net-next sample action optimization v3 3/4] openvswitch: Optimize sample action for the clone use cases
Date: Thu, 16 Mar 2017 15:48:29 -0700
Message-ID: <1489704510-35975-4-git-send-email-azhou@ovn.org>
References: <1489704510-35975-1-git-send-email-azhou@ovn.org>
Cc: joe@ovn.org, pshelar@ovn.org, Andy Zhou <azhou@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35604 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752563AbdCPW4h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 18:56:37 -0400
Received: by mail-pg0-f68.google.com with SMTP id g2so7526083pge.2
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 15:56:29 -0700 (PDT)
In-Reply-To: <1489704510-35975-1-git-send-email-azhou@ovn.org>
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

The main optimization implemented in this series removes the static
nesting limit check, instead, implement the run time recursion limit
check, and recursion avoidance similar to that of the 'recirc' action.
This optimization solve both #1 and #2 issues above.

One related optimization attempts to avoid copying flow key as
long as the actions enclosed does not change the flow key. The
detection is performed only once at the flow downloading time.

Another related optimization is to rewrite the action list
at flow downloading time in order to save the fast path from parsing
the sample action list in its original form repeatedly.

Signed-off-by: Andy Zhou <azhou@ovn.org>
---
 include/uapi/linux/openvswitch.h |  15 +++++
 net/openvswitch/actions.c        | 107 ++++++++++++++---------------
 net/openvswitch/datapath.h       |   2 -
 net/openvswitch/flow_netlink.c   | 141 +++++++++++++++++++++++++++------------
 4 files changed, 167 insertions(+), 98 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 7f41f7d..66d1c3c 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -578,10 +578,25 @@ enum ovs_sample_attr {
 	OVS_SAMPLE_ATTR_PROBABILITY, /* u32 number */
 	OVS_SAMPLE_ATTR_ACTIONS,     /* Nested OVS_ACTION_ATTR_* attributes. */
 	__OVS_SAMPLE_ATTR_MAX,
+
+#ifdef __KERNEL__
+	OVS_SAMPLE_ATTR_ARG          /* struct sample_arg  */
+#endif
 };
 
 #define OVS_SAMPLE_ATTR_MAX (__OVS_SAMPLE_ATTR_MAX - 1)
 
+#ifdef __KERNEL__
+struct sample_arg {
+	bool exec;                   /* When true, actions in sample will not
+				      * change flow keys. False otherwise.
+				      */
+	u32  probability;            /* Same value as
+				      * 'OVS_SAMPLE_ATTR_PROBABILITY'.
+				      */
+};
+#endif
+
 /**
  * enum ovs_userspace_attr - Attributes for %OVS_ACTION_ATTR_USERSPACE action.
  * @OVS_USERSPACE_ATTR_PID: u32 Netlink PID to which the %OVS_PACKET_CMD_ACTION
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 8c9c60c..3529f7b 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -928,73 +928,70 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
 	return ovs_dp_upcall(dp, skb, key, &upcall, cutlen);
 }
 
+/* When 'last' is true, sample() should always consume the 'skb'.
+ * Otherwise, sample() should keep 'skb' intact regardless what
+ * actions are executed within sample().
+ */
 static int sample(struct datapath *dp, struct sk_buff *skb,
 		  struct sw_flow_key *key, const struct nlattr *attr,
-		  const struct nlattr *actions, int actions_len)
+		  bool last)
 {
-	const struct nlattr *acts_list = NULL;
-	const struct nlattr *a;
-	int rem;
-	u32 cutlen = 0;
+	struct nlattr *actions;
+	struct nlattr *sample_arg;
+	struct sw_flow_key *orig_key = key;
+	int rem = nla_len(attr);
+	int err = 0;
+	const struct sample_arg *arg;
 
-	for (a = nla_data(attr), rem = nla_len(attr); rem > 0;
-		 a = nla_next(a, &rem)) {
-		u32 probability;
+	/* The first action is always 'OVS_SAMPLE_ATTR_ARG'. */
+	sample_arg = nla_data(attr);
+	arg = nla_data(sample_arg);
+	actions = nla_next(sample_arg, &rem);
 
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
+	if ((arg->probability != U32_MAX) &&
+	    (!arg->probability || prandom_u32() > arg->probability)) {
+		if (last)
+			consume_skb(skb);
+		return 0;
 	}
 
-	rem = nla_len(acts_list);
-	a = nla_data(acts_list);
-
-	/* Actions list is empty, do nothing */
-	if (unlikely(!rem))
+	/* Unless the last action, sample works on the clone of SKB.  */
+	skb = last ? skb : skb_clone(skb, GFP_ATOMIC);
+	if (!skb) {
+		/* Out of memory, skip this sample action.
+		 */
 		return 0;
+	}
 
-	/* The only known usage of sample action is having a single user-space
-	 * action, or having a truncate action followed by a single user-space
-	 * action. Treat this usage as a special case.
-	 * The output_userspace() should clone the skb to be sent to the
-	 * user space. This skb will be consumed by its caller.
+	/* In case the sample actions won't change 'key',
+	 * it can be used directly to execute sample actions.
+	 * Otherwise, allocate a new key from the
+	 * next recursion level of 'flow_keys'. If
+	 * successful, execute the sample actions without
+	 * deferring.
+	 *
+	 * Defer the sample actions if the recursion
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
+	if (key) {
+		err = do_execute_actions(dp, skb, key, actions, rem);
+	} else if (!add_deferred_actions(skb, orig_key, actions, rem)) {
 
-	skb = skb_clone(skb, GFP_ATOMIC);
-	if (!skb)
-		/* Skip the sample action when out of memory. */
-		return 0;
-
-	if (!add_deferred_actions(skb, key, nla_data(acts_list),
-				  nla_len(acts_list))) {
 		if (net_ratelimit())
-			pr_warn("%s: deferred actions limit reached, dropping sample action\n",
+			pr_warn("%s: deferred action limit reached, drop sample action\n",
 				ovs_dp_name(dp));
-
 		kfree_skb(skb);
 	}
-	return 0;
+
+	if (!arg->exec)
+		__this_cpu_dec(exec_actions_level);
+
+	return err;
 }
 
 static void execute_hash(struct sk_buff *skb, struct sw_flow_key *key,
@@ -1244,9 +1241,15 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			err = execute_masked_set_action(skb, key, nla_data(a));
 			break;
 
-		case OVS_ACTION_ATTR_SAMPLE:
-			err = sample(dp, skb, key, a, attr, len);
+		case OVS_ACTION_ATTR_SAMPLE: {
+			bool last = nla_is_last(a, rem);
+
+			err = sample(dp, skb, key, a, last);
+			if (last)
+				return err;
+
 			break;
+		}
 
 		case OVS_ACTION_ATTR_CT:
 			if (!is_flow_key_valid(key)) {
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 1c6e937..da931bd 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -34,8 +34,6 @@
 #define DP_MAX_PORTS           USHRT_MAX
 #define DP_VPORT_HASH_BUCKETS  1024
 
-#define SAMPLE_ACTION_DEPTH 3
-
 /**
  * struct dp_stats_percpu - per-cpu packet processing statistics for a given
  * datapath.
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 6f5fa50..2acfb5a 100644
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
+		case OVS_ACTION_ATTR_TRUNC:
+		case OVS_ACTION_ATTR_USERSPACE:
+			break;
+
+		case OVS_ACTION_ATTR_CT:
+		case OVS_ACTION_ATTR_HASH:
+		case OVS_ACTION_ATTR_POP_ETH:
+		case OVS_ACTION_ATTR_POP_MPLS:
+		case OVS_ACTION_ATTR_POP_VLAN:
+		case OVS_ACTION_ATTR_PUSH_ETH:
+		case OVS_ACTION_ATTR_PUSH_MPLS:
+		case OVS_ACTION_ATTR_PUSH_VLAN:
+		case OVS_ACTION_ATTR_SAMPLE:
+		case OVS_ACTION_ATTR_SET:
+		case OVS_ACTION_ATTR_SET_MASKED:
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
@@ -2021,18 +2054,20 @@ static inline void add_nested_action_end(struct sw_flow_actions *sfa,
 
 static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 				  const struct sw_flow_key *key,
-				  int depth, struct sw_flow_actions **sfa,
+				  struct sw_flow_actions **sfa,
 				  __be16 eth_type, __be16 vlan_tci, bool log);
 
 static int validate_and_copy_sample(struct net *net, const struct nlattr *attr,
-				    const struct sw_flow_key *key, int depth,
+				    const struct sw_flow_key *key,
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
+	err = __ovs_nla_copy_actions(net, actions, key, sfa,
 				     eth_type, vlan_tci, log);
+
 	if (err)
 		return err;
 
-	add_nested_action_end(*sfa, st_acts);
 	add_nested_action_end(*sfa, start);
 
 	return 0;
@@ -2406,16 +2453,13 @@ static int copy_action(const struct nlattr *from,
 
 static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 				  const struct sw_flow_key *key,
-				  int depth, struct sw_flow_actions **sfa,
+				  struct sw_flow_actions **sfa,
 				  __be16 eth_type, __be16 vlan_tci, bool log)
 {
 	u8 mac_proto = ovs_key_mac_proto(key);
 	const struct nlattr *a;
 	int rem, err;
 
-	if (depth >= SAMPLE_ACTION_DEPTH)
-		return -EOVERFLOW;
-
 	nla_for_each_nested(a, attr, rem) {
 		/* Expected argument lengths, (u32)-1 for variable length. */
 		static const u32 action_lens[OVS_ACTION_ATTR_MAX + 1] = {
@@ -2553,13 +2597,17 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 				return err;
 			break;
 
-		case OVS_ACTION_ATTR_SAMPLE:
-			err = validate_and_copy_sample(net, a, key, depth, sfa,
-						       eth_type, vlan_tci, log);
+		case OVS_ACTION_ATTR_SAMPLE: {
+			bool last = nla_is_last(a, rem);
+
+			err = validate_and_copy_sample(net, a, key, sfa,
+						       eth_type, vlan_tci,
+						       log, last);
 			if (err)
 				return err;
 			skip_copy = true;
 			break;
+		}
 
 		case OVS_ACTION_ATTR_CT:
 			err = ovs_ct_copy_action(net, a, key, sfa, log);
@@ -2613,7 +2661,7 @@ int ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 		return PTR_ERR(*sfa);
 
 	(*sfa)->orig_len = nla_len(attr);
-	err = __ovs_nla_copy_actions(net, attr, key, 0, sfa, key->eth.type,
+	err = __ovs_nla_copy_actions(net, attr, key, sfa, key->eth.type,
 				     key->eth.vlan.tci, log);
 	if (err)
 		ovs_nla_free_flow_actions(*sfa);
@@ -2621,39 +2669,44 @@ int ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 	return err;
 }
 
-static int sample_action_to_attr(const struct nlattr *attr, struct sk_buff *skb)
+static int sample_action_to_attr(const struct nlattr *attr,
+				 struct sk_buff *skb)
 {
-	const struct nlattr *a;
-	struct nlattr *start;
-	int err = 0, rem;
+	struct nlattr *start, *ac_start = NULL, *sample_arg;
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
+	if (nla_put_u32(skb, OVS_SAMPLE_ATTR_PROBABILITY, arg->probability)) {
+		err = -EMSGSIZE;
+		goto out;
+	}
+
+	ac_start = nla_nest_start(skb, OVS_SAMPLE_ATTR_ACTIONS);
+	if (!ac_start) {
+		err = -EMSGSIZE;
+		goto out;
+	}
+
+	err = ovs_nla_put_actions(actions, rem, skb);
+
+out:
+	if (err) {
+		nla_nest_cancel(skb, ac_start);
+		nla_nest_cancel(skb, start);
+	} else {
+		nla_nest_end(skb, ac_start);
+		nla_nest_end(skb, start);
 	}
 
-	nla_nest_end(skb, start);
 	return err;
 }
 
-- 
1.8.3.1
