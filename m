From: Andy Zhou <azhou@ovn.org>
Subject: [net-next ovs clone action 3/3] openvswitch: kernel datapath clone action
Date: Tue, 31 Jan 2017 08:47:27 -0800
Message-ID: <1485881247-6683-3-git-send-email-azhou@ovn.org>
References: <1485881247-6683-1-git-send-email-azhou@ovn.org>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@ovn.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:32769 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750899AbdAaRK5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 12:10:57 -0500
Received: by mail-pf0-f195.google.com with SMTP id e4so28715931pfg.0
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 09:10:32 -0800 (PST)
In-Reply-To: <1485881247-6683-1-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add 'clone' kernel datapath support. In case the actions within clone
do not modify the current flow, the actions are executed without
making a copy of current key before execution. This analysis is
done once per flow installation.

On the other hand, in case the actions within clone may modify
current flow key, a key has to be copied. In case the percpu
'flow_keys' is available for the next 'exec_actions_level', the clone
actions will be executed without using the deferred fifo. Otherwise,
deferred fifo is used this clone action.

Signed-off-by: Andy Zhou <azhou@ovn.org>
---
 include/uapi/linux/openvswitch.h |   1 +
 net/openvswitch/actions.c        |  66 ++++++++++++++++++++++
 net/openvswitch/datapath.h       |   3 +
 net/openvswitch/flow_netlink.c   | 117 ++++++++++++++++++++++++++++++++++++++-
 4 files changed, 186 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 375d812..910969d 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -780,6 +780,7 @@ enum ovs_action_attr {
 	OVS_ACTION_ATTR_TRUNC,        /* u32 struct ovs_action_trunc. */
 	OVS_ACTION_ATTR_PUSH_ETH,     /* struct ovs_action_push_eth. */
 	OVS_ACTION_ATTR_POP_ETH,      /* No argument. */
+	OVS_ACTION_ATTR_CLONE,        /* Nested OVS_ACTION_ATTR_*.  */
 
 	__OVS_ACTION_ATTR_MAX,	      /* Nothing past this will be accepted
 				       * from userspace. */
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 73bd4ad..b75388f 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -1156,6 +1156,55 @@ static int execute_recirc(struct datapath *dp, struct sk_buff *skb,
 	return 0;
 }
 
+static int execute_clone(struct datapath *dp, struct sk_buff *skb,
+			 struct sw_flow_key *key, const struct nlattr *a)
+{
+	struct nlattr *actions;
+	struct sw_flow_key *orig = key;
+	int rem;
+	int err = 0;
+	bool exec = false;
+
+	actions = nla_data(a);
+	rem = nla_len(a);
+	if (nla_type(a) == OVS_CLONE_ATTR_EXEC) {
+		exec = true;
+		actions = nla_next(actions, &rem);
+	}
+
+	/* In case the clone actions won't change 'key',
+	 * we can use key for the clone execution.
+	 * Otherwise, try to allocate a key from the
+	 * next recursion level of 'flow_keys'. If
+	 * successful, we can still execute the clone
+	 * actions  without deferring.
+	 *
+	 * Defer the clone action if the action recursion
+	 * limit has been reached.
+	 */
+	if (!exec) {
+		__this_cpu_inc(exec_actions_level);
+		key = clone_key(key);
+	}
+
+	if (key) {
+		err = do_execute_actions(dp, skb, key, actions, rem);
+	} else {
+		struct deferred_action *da;
+
+		da = add_deferred_actions(skb, orig, actions, rem);
+
+		if (!da && net_ratelimit())
+			pr_warn("%s: deferred action limit reached, drop clone action\n",
+				ovs_dp_name(dp));
+	}
+
+	if (!exec)
+		__this_cpu_dec(exec_actions_level);
+
+	return err;
+}
+
 /* Execute a list of actions against 'skb'. */
 static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			      struct sw_flow_key *key,
@@ -1271,6 +1320,23 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 		case OVS_ACTION_ATTR_POP_ETH:
 			err = pop_eth(skb, key);
 			break;
+
+		case OVS_ACTION_ATTR_CLONE: {
+			bool last = nla_is_last(a, rem);
+			struct sk_buff *clone_skb;
+
+			clone_skb = last ? skb : skb_clone(skb, GFP_ATOMIC);
+
+			if (!clone_skb)
+				/* Out of memory, skip this clone action.
+				 */
+				break;
+
+			err = execute_clone(dp, clone_skb, key, a);
+			if (last)
+				return err;
+			break;
+			}
 		}
 
 		if (unlikely(err)) {
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 1c6e937..2ea9f30 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -220,4 +220,7 @@ int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb,
 	if (logging_allowed && net_ratelimit())			\
 		pr_info("netlink: " fmt "\n", ##__VA_ARGS__);	\
 } while (0)
+
+#define OVS_CLONE_ATTR_EXEC  (OVS_ACTION_ATTR_MAX + 1)
+
 #endif /* datapath.h */
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index c87d359..2d314f6 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2007-2014 Nicira, Inc.
+ * Copyright (c) 2007-2017 Nicira, Inc.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
@@ -59,6 +59,40 @@ struct ovs_len_tbl {
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
+		case OVS_ACTION_ATTR_CLONE:
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
@@ -2342,6 +2376,46 @@ static int validate_userspace(const struct nlattr *attr)
 	return 0;
 }
 
+static int copy_clone(struct net *net, const struct nlattr *attr,
+		      const struct sw_flow_key *key, int depth,
+		      struct sw_flow_actions **sfa,
+		      __be16 eth_type, __be16 vlan_tci, bool log, bool last)
+{
+	int start, err;
+	bool exec;
+
+	start = add_nested_action_start(sfa, OVS_ACTION_ATTR_CLONE, log);
+	if (start < 0)
+		return start;
+
+	/* When both skb and flow may be changed, put the clone
+	 * into a deferred fifo. On the other hand, if only skb
+	 * may be modified, the actions can be executed in place.
+	 *
+	 * Do this analysis at the flow installation time.
+	 * Set 'clone_action->exec' to true if the actions can be
+	 * executed without being deferred.
+	 *
+	 * If the clone is the last action, it can always be excuted
+	 * rather than deferred.
+	 */
+	exec = last || !actions_may_change_flow(attr);
+
+	if (exec) {
+		err = ovs_nla_add_action(sfa, OVS_CLONE_ATTR_EXEC, NULL, 0,
+					 log);
+		if (err)
+			return err;
+	}
+
+	err = __ovs_nla_copy_actions(net, attr, key, depth, sfa,
+				     eth_type, vlan_tci, log);
+
+	add_nested_action_end(*sfa, start);
+
+	return err;
+}
+
 static int copy_action(const struct nlattr *from,
 		       struct sw_flow_actions **sfa, bool log)
 {
@@ -2386,6 +2460,7 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 			[OVS_ACTION_ATTR_TRUNC] = sizeof(struct ovs_action_trunc),
 			[OVS_ACTION_ATTR_PUSH_ETH] = sizeof(struct ovs_action_push_eth),
 			[OVS_ACTION_ATTR_POP_ETH] = 0,
+			[OVS_ACTION_ATTR_CLONE] = (u32)-1,
 		};
 		const struct ovs_action_push_vlan *vlan;
 		int type = nla_type(a);
@@ -2536,6 +2611,14 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 			mac_proto = MAC_PROTO_ETHERNET;
 			break;
 
+		case OVS_ACTION_ATTR_CLONE:
+			err = copy_clone(net, a, key, depth, sfa, eth_type,
+					 vlan_tci, log, nla_is_last(a, rem));
+			if (err)
+				return err;
+			skip_copy = true;
+			break;
+
 		default:
 			OVS_NLERR(log, "Unknown Action type %d", type);
 			return -EINVAL;
@@ -2609,6 +2692,32 @@ static int sample_action_to_attr(const struct nlattr *attr, struct sk_buff *skb)
 	return err;
 }
 
+static int clone_action_to_attr(const struct nlattr *clone,
+				struct sk_buff *skb)
+{
+	struct nlattr *start, *actions;
+	int rem, err = 0;
+
+	start = nla_nest_start(skb, OVS_ACTION_ATTR_CLONE);
+	if (!start)
+		return -EMSGSIZE;
+
+	actions = nla_data(clone);
+	rem = nla_len(clone);
+	/* Skip internal 'OVS_CLONE_ATTR_EXEC' flag, if present,
+	 */
+	if (nla_type(actions) == OVS_CLONE_ATTR_EXEC)
+		actions = nla_next(actions, &rem);
+
+	err = ovs_nla_put_actions(actions, rem, skb);
+	if (err)
+		return err;
+
+	nla_nest_end(skb, start);
+
+	return err;
+}
+
 static int set_action_to_attr(const struct nlattr *a, struct sk_buff *skb)
 {
 	const struct nlattr *ovs_key = nla_data(a);
@@ -2697,6 +2806,12 @@ int ovs_nla_put_actions(const struct nlattr *attr, int len, struct sk_buff *skb)
 				return err;
 			break;
 
+		case OVS_ACTION_ATTR_CLONE:
+			err = clone_action_to_attr(a, skb);
+			if (err)
+				return err;
+			break;
+
 		default:
 			if (nla_put(skb, type, nla_len(a), nla_data(a)))
 				return -EMSGSIZE;
-- 
1.8.3.1
