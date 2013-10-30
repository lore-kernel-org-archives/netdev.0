From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 04/11] openvswitch: Restructure datapath.c and flow.c
Date: Tue, 29 Oct 2013 17:22:17 -0700
Message-ID: <1383092544-50599-5-git-send-email-jesse@nicira.com>
References: <1383092544-50599-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog124.obsmtp.com ([74.125.149.151]:55256 "HELO
	na3sys009aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752527Ab3J3AWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 20:22:38 -0400
Received: by mail-pb0-f43.google.com with SMTP id md4so586772pbc.30
        for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 17:22:38 -0700 (PDT)
In-Reply-To: <1383092544-50599-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>

Over the time datapath.c and flow.c has became pretty large files.
Following patch restructures functionality of component into three
different components:

flow.c: contains flow extract.
flow_netlink.c: netlink flow api.
flow_table.c: flow table api.

This patch restructures code without changing logic.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/Makefile       |    2 +
 net/openvswitch/datapath.c     |  528 +------------
 net/openvswitch/datapath.h     |    1 +
 net/openvswitch/flow.c         | 1605 +---------------------------------------
 net/openvswitch/flow.h         |  128 +---
 net/openvswitch/flow_netlink.c | 1603 +++++++++++++++++++++++++++++++++++++++
 net/openvswitch/flow_netlink.h |   60 ++
 net/openvswitch/flow_table.c   |  517 +++++++++++++
 net/openvswitch/flow_table.h   |   91 +++
 9 files changed, 2354 insertions(+), 2181 deletions(-)
 create mode 100644 net/openvswitch/flow_netlink.c
 create mode 100644 net/openvswitch/flow_netlink.h
 create mode 100644 net/openvswitch/flow_table.c
 create mode 100644 net/openvswitch/flow_table.h

diff --git a/net/openvswitch/Makefile b/net/openvswitch/Makefile
index ea36e99..3591cb5 100644
--- a/net/openvswitch/Makefile
+++ b/net/openvswitch/Makefile
@@ -9,6 +9,8 @@ openvswitch-y := \
 	datapath.o \
 	dp_notify.o \
 	flow.o \
+	flow_netlink.o \
+	flow_table.o \
 	vport.o \
 	vport-internal_dev.o \
 	vport-netdev.o
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 2e1a9c2..72e6874 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -55,10 +55,10 @@
 
 #include "datapath.h"
 #include "flow.h"
+#include "flow_netlink.h"
 #include "vport-internal_dev.h"
 #include "vport-netdev.h"
 
-
 #define REHASH_FLOW_INTERVAL (10 * 60 * HZ)
 
 int ovs_net_id __read_mostly;
@@ -235,7 +235,7 @@ void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
 	}
 
 	/* Look up flow. */
-	flow = ovs_flow_lookup(rcu_dereference(dp->table), &key);
+	flow = ovs_flow_tbl_lookup(rcu_dereference(dp->table), &key);
 	if (unlikely(!flow)) {
 		struct dp_upcall_info upcall;
 
@@ -433,7 +433,7 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
 	upcall->dp_ifindex = dp_ifindex;
 
 	nla = nla_nest_start(user_skb, OVS_PACKET_ATTR_KEY);
-	ovs_flow_to_nlattrs(upcall_info->key, upcall_info->key, user_skb);
+	ovs_nla_put_flow(upcall_info->key, upcall_info->key, user_skb);
 	nla_nest_end(user_skb, nla);
 
 	if (upcall_info->userdata)
@@ -470,381 +470,6 @@ static int flush_flows(struct datapath *dp)
 	return 0;
 }
 
-static struct nlattr *reserve_sfa_size(struct sw_flow_actions **sfa, int attr_len)
-{
-
-	struct sw_flow_actions *acts;
-	int new_acts_size;
-	int req_size = NLA_ALIGN(attr_len);
-	int next_offset = offsetof(struct sw_flow_actions, actions) +
-					(*sfa)->actions_len;
-
-	if (req_size <= (ksize(*sfa) - next_offset))
-		goto out;
-
-	new_acts_size = ksize(*sfa) * 2;
-
-	if (new_acts_size > MAX_ACTIONS_BUFSIZE) {
-		if ((MAX_ACTIONS_BUFSIZE - next_offset) < req_size)
-			return ERR_PTR(-EMSGSIZE);
-		new_acts_size = MAX_ACTIONS_BUFSIZE;
-	}
-
-	acts = ovs_flow_actions_alloc(new_acts_size);
-	if (IS_ERR(acts))
-		return (void *)acts;
-
-	memcpy(acts->actions, (*sfa)->actions, (*sfa)->actions_len);
-	acts->actions_len = (*sfa)->actions_len;
-	kfree(*sfa);
-	*sfa = acts;
-
-out:
-	(*sfa)->actions_len += req_size;
-	return  (struct nlattr *) ((unsigned char *)(*sfa) + next_offset);
-}
-
-static int add_action(struct sw_flow_actions **sfa, int attrtype, void *data, int len)
-{
-	struct nlattr *a;
-
-	a = reserve_sfa_size(sfa, nla_attr_size(len));
-	if (IS_ERR(a))
-		return PTR_ERR(a);
-
-	a->nla_type = attrtype;
-	a->nla_len = nla_attr_size(len);
-
-	if (data)
-		memcpy(nla_data(a), data, len);
-	memset((unsigned char *) a + a->nla_len, 0, nla_padlen(len));
-
-	return 0;
-}
-
-static inline int add_nested_action_start(struct sw_flow_actions **sfa, int attrtype)
-{
-	int used = (*sfa)->actions_len;
-	int err;
-
-	err = add_action(sfa, attrtype, NULL, 0);
-	if (err)
-		return err;
-
-	return used;
-}
-
-static inline void add_nested_action_end(struct sw_flow_actions *sfa, int st_offset)
-{
-	struct nlattr *a = (struct nlattr *) ((unsigned char *)sfa->actions + st_offset);
-
-	a->nla_len = sfa->actions_len - st_offset;
-}
-
-static int validate_and_copy_actions(const struct nlattr *attr,
-				     const struct sw_flow_key *key, int depth,
-				     struct sw_flow_actions **sfa);
-
-static int validate_and_copy_sample(const struct nlattr *attr,
-				    const struct sw_flow_key *key, int depth,
-				    struct sw_flow_actions **sfa)
-{
-	const struct nlattr *attrs[OVS_SAMPLE_ATTR_MAX + 1];
-	const struct nlattr *probability, *actions;
-	const struct nlattr *a;
-	int rem, start, err, st_acts;
-
-	memset(attrs, 0, sizeof(attrs));
-	nla_for_each_nested(a, attr, rem) {
-		int type = nla_type(a);
-		if (!type || type > OVS_SAMPLE_ATTR_MAX || attrs[type])
-			return -EINVAL;
-		attrs[type] = a;
-	}
-	if (rem)
-		return -EINVAL;
-
-	probability = attrs[OVS_SAMPLE_ATTR_PROBABILITY];
-	if (!probability || nla_len(probability) != sizeof(u32))
-		return -EINVAL;
-
-	actions = attrs[OVS_SAMPLE_ATTR_ACTIONS];
-	if (!actions || (nla_len(actions) && nla_len(actions) < NLA_HDRLEN))
-		return -EINVAL;
-
-	/* validation done, copy sample action. */
-	start = add_nested_action_start(sfa, OVS_ACTION_ATTR_SAMPLE);
-	if (start < 0)
-		return start;
-	err = add_action(sfa, OVS_SAMPLE_ATTR_PROBABILITY, nla_data(probability), sizeof(u32));
-	if (err)
-		return err;
-	st_acts = add_nested_action_start(sfa, OVS_SAMPLE_ATTR_ACTIONS);
-	if (st_acts < 0)
-		return st_acts;
-
-	err = validate_and_copy_actions(actions, key, depth + 1, sfa);
-	if (err)
-		return err;
-
-	add_nested_action_end(*sfa, st_acts);
-	add_nested_action_end(*sfa, start);
-
-	return 0;
-}
-
-static int validate_tp_port(const struct sw_flow_key *flow_key)
-{
-	if (flow_key->eth.type == htons(ETH_P_IP)) {
-		if (flow_key->ipv4.tp.src || flow_key->ipv4.tp.dst)
-			return 0;
-	} else if (flow_key->eth.type == htons(ETH_P_IPV6)) {
-		if (flow_key->ipv6.tp.src || flow_key->ipv6.tp.dst)
-			return 0;
-	}
-
-	return -EINVAL;
-}
-
-static int validate_and_copy_set_tun(const struct nlattr *attr,
-				     struct sw_flow_actions **sfa)
-{
-	struct sw_flow_match match;
-	struct sw_flow_key key;
-	int err, start;
-
-	ovs_match_init(&match, &key, NULL);
-	err = ovs_ipv4_tun_from_nlattr(nla_data(attr), &match, false);
-	if (err)
-		return err;
-
-	start = add_nested_action_start(sfa, OVS_ACTION_ATTR_SET);
-	if (start < 0)
-		return start;
-
-	err = add_action(sfa, OVS_KEY_ATTR_IPV4_TUNNEL, &match.key->tun_key,
-			sizeof(match.key->tun_key));
-	add_nested_action_end(*sfa, start);
-
-	return err;
-}
-
-static int validate_set(const struct nlattr *a,
-			const struct sw_flow_key *flow_key,
-			struct sw_flow_actions **sfa,
-			bool *set_tun)
-{
-	const struct nlattr *ovs_key = nla_data(a);
-	int key_type = nla_type(ovs_key);
-
-	/* There can be only one key in a action */
-	if (nla_total_size(nla_len(ovs_key)) != nla_len(a))
-		return -EINVAL;
-
-	if (key_type > OVS_KEY_ATTR_MAX ||
-	   (ovs_key_lens[key_type] != nla_len(ovs_key) &&
-	    ovs_key_lens[key_type] != -1))
-		return -EINVAL;
-
-	switch (key_type) {
-	const struct ovs_key_ipv4 *ipv4_key;
-	const struct ovs_key_ipv6 *ipv6_key;
-	int err;
-
-	case OVS_KEY_ATTR_PRIORITY:
-	case OVS_KEY_ATTR_SKB_MARK:
-	case OVS_KEY_ATTR_ETHERNET:
-		break;
-
-	case OVS_KEY_ATTR_TUNNEL:
-		*set_tun = true;
-		err = validate_and_copy_set_tun(a, sfa);
-		if (err)
-			return err;
-		break;
-
-	case OVS_KEY_ATTR_IPV4:
-		if (flow_key->eth.type != htons(ETH_P_IP))
-			return -EINVAL;
-
-		if (!flow_key->ip.proto)
-			return -EINVAL;
-
-		ipv4_key = nla_data(ovs_key);
-		if (ipv4_key->ipv4_proto != flow_key->ip.proto)
-			return -EINVAL;
-
-		if (ipv4_key->ipv4_frag != flow_key->ip.frag)
-			return -EINVAL;
-
-		break;
-
-	case OVS_KEY_ATTR_IPV6:
-		if (flow_key->eth.type != htons(ETH_P_IPV6))
-			return -EINVAL;
-
-		if (!flow_key->ip.proto)
-			return -EINVAL;
-
-		ipv6_key = nla_data(ovs_key);
-		if (ipv6_key->ipv6_proto != flow_key->ip.proto)
-			return -EINVAL;
-
-		if (ipv6_key->ipv6_frag != flow_key->ip.frag)
-			return -EINVAL;
-
-		if (ntohl(ipv6_key->ipv6_label) & 0xFFF00000)
-			return -EINVAL;
-
-		break;
-
-	case OVS_KEY_ATTR_TCP:
-		if (flow_key->ip.proto != IPPROTO_TCP)
-			return -EINVAL;
-
-		return validate_tp_port(flow_key);
-
-	case OVS_KEY_ATTR_UDP:
-		if (flow_key->ip.proto != IPPROTO_UDP)
-			return -EINVAL;
-
-		return validate_tp_port(flow_key);
-
-	case OVS_KEY_ATTR_SCTP:
-		if (flow_key->ip.proto != IPPROTO_SCTP)
-			return -EINVAL;
-
-		return validate_tp_port(flow_key);
-
-	default:
-		return -EINVAL;
-	}
-
-	return 0;
-}
-
-static int validate_userspace(const struct nlattr *attr)
-{
-	static const struct nla_policy userspace_policy[OVS_USERSPACE_ATTR_MAX + 1] =	{
-		[OVS_USERSPACE_ATTR_PID] = {.type = NLA_U32 },
-		[OVS_USERSPACE_ATTR_USERDATA] = {.type = NLA_UNSPEC },
-	};
-	struct nlattr *a[OVS_USERSPACE_ATTR_MAX + 1];
-	int error;
-
-	error = nla_parse_nested(a, OVS_USERSPACE_ATTR_MAX,
-				 attr, userspace_policy);
-	if (error)
-		return error;
-
-	if (!a[OVS_USERSPACE_ATTR_PID] ||
-	    !nla_get_u32(a[OVS_USERSPACE_ATTR_PID]))
-		return -EINVAL;
-
-	return 0;
-}
-
-static int copy_action(const struct nlattr *from,
-		       struct sw_flow_actions **sfa)
-{
-	int totlen = NLA_ALIGN(from->nla_len);
-	struct nlattr *to;
-
-	to = reserve_sfa_size(sfa, from->nla_len);
-	if (IS_ERR(to))
-		return PTR_ERR(to);
-
-	memcpy(to, from, totlen);
-	return 0;
-}
-
-static int validate_and_copy_actions(const struct nlattr *attr,
-				     const struct sw_flow_key *key,
-				     int depth,
-				     struct sw_flow_actions **sfa)
-{
-	const struct nlattr *a;
-	int rem, err;
-
-	if (depth >= SAMPLE_ACTION_DEPTH)
-		return -EOVERFLOW;
-
-	nla_for_each_nested(a, attr, rem) {
-		/* Expected argument lengths, (u32)-1 for variable length. */
-		static const u32 action_lens[OVS_ACTION_ATTR_MAX + 1] = {
-			[OVS_ACTION_ATTR_OUTPUT] = sizeof(u32),
-			[OVS_ACTION_ATTR_USERSPACE] = (u32)-1,
-			[OVS_ACTION_ATTR_PUSH_VLAN] = sizeof(struct ovs_action_push_vlan),
-			[OVS_ACTION_ATTR_POP_VLAN] = 0,
-			[OVS_ACTION_ATTR_SET] = (u32)-1,
-			[OVS_ACTION_ATTR_SAMPLE] = (u32)-1
-		};
-		const struct ovs_action_push_vlan *vlan;
-		int type = nla_type(a);
-		bool skip_copy;
-
-		if (type > OVS_ACTION_ATTR_MAX ||
-		    (action_lens[type] != nla_len(a) &&
-		     action_lens[type] != (u32)-1))
-			return -EINVAL;
-
-		skip_copy = false;
-		switch (type) {
-		case OVS_ACTION_ATTR_UNSPEC:
-			return -EINVAL;
-
-		case OVS_ACTION_ATTR_USERSPACE:
-			err = validate_userspace(a);
-			if (err)
-				return err;
-			break;
-
-		case OVS_ACTION_ATTR_OUTPUT:
-			if (nla_get_u32(a) >= DP_MAX_PORTS)
-				return -EINVAL;
-			break;
-
-
-		case OVS_ACTION_ATTR_POP_VLAN:
-			break;
-
-		case OVS_ACTION_ATTR_PUSH_VLAN:
-			vlan = nla_data(a);
-			if (vlan->vlan_tpid != htons(ETH_P_8021Q))
-				return -EINVAL;
-			if (!(vlan->vlan_tci & htons(VLAN_TAG_PRESENT)))
-				return -EINVAL;
-			break;
-
-		case OVS_ACTION_ATTR_SET:
-			err = validate_set(a, key, sfa, &skip_copy);
-			if (err)
-				return err;
-			break;
-
-		case OVS_ACTION_ATTR_SAMPLE:
-			err = validate_and_copy_sample(a, key, depth, sfa);
-			if (err)
-				return err;
-			skip_copy = true;
-			break;
-
-		default:
-			return -EINVAL;
-		}
-		if (!skip_copy) {
-			err = copy_action(a, sfa);
-			if (err)
-				return err;
-		}
-	}
-
-	if (rem > 0)
-		return -EINVAL;
-
-	return 0;
-}
-
 static void clear_stats(struct sw_flow *flow)
 {
 	flow->used = 0;
@@ -900,15 +525,16 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	if (err)
 		goto err_flow_free;
 
-	err = ovs_flow_metadata_from_nlattrs(flow, a[OVS_PACKET_ATTR_KEY]);
+	err = ovs_nla_get_flow_metadata(flow, a[OVS_PACKET_ATTR_KEY]);
 	if (err)
 		goto err_flow_free;
-	acts = ovs_flow_actions_alloc(nla_len(a[OVS_PACKET_ATTR_ACTIONS]));
+	acts = ovs_nla_alloc_flow_actions(nla_len(a[OVS_PACKET_ATTR_ACTIONS]));
 	err = PTR_ERR(acts);
 	if (IS_ERR(acts))
 		goto err_flow_free;
 
-	err = validate_and_copy_actions(a[OVS_PACKET_ATTR_ACTIONS], &flow->key, 0, &acts);
+	err = ovs_nla_copy_actions(a[OVS_PACKET_ATTR_ACTIONS],
+				   &flow->key, 0, &acts);
 	rcu_assign_pointer(flow->sf_acts, acts);
 	if (err)
 		goto err_flow_free;
@@ -1003,100 +629,6 @@ static struct genl_multicast_group ovs_dp_flow_multicast_group = {
 	.name = OVS_FLOW_MCGROUP
 };
 
-static int actions_to_attr(const struct nlattr *attr, int len, struct sk_buff *skb);
-static int sample_action_to_attr(const struct nlattr *attr, struct sk_buff *skb)
-{
-	const struct nlattr *a;
-	struct nlattr *start;
-	int err = 0, rem;
-
-	start = nla_nest_start(skb, OVS_ACTION_ATTR_SAMPLE);
-	if (!start)
-		return -EMSGSIZE;
-
-	nla_for_each_nested(a, attr, rem) {
-		int type = nla_type(a);
-		struct nlattr *st_sample;
-
-		switch (type) {
-		case OVS_SAMPLE_ATTR_PROBABILITY:
-			if (nla_put(skb, OVS_SAMPLE_ATTR_PROBABILITY, sizeof(u32), nla_data(a)))
-				return -EMSGSIZE;
-			break;
-		case OVS_SAMPLE_ATTR_ACTIONS:
-			st_sample = nla_nest_start(skb, OVS_SAMPLE_ATTR_ACTIONS);
-			if (!st_sample)
-				return -EMSGSIZE;
-			err = actions_to_attr(nla_data(a), nla_len(a), skb);
-			if (err)
-				return err;
-			nla_nest_end(skb, st_sample);
-			break;
-		}
-	}
-
-	nla_nest_end(skb, start);
-	return err;
-}
-
-static int set_action_to_attr(const struct nlattr *a, struct sk_buff *skb)
-{
-	const struct nlattr *ovs_key = nla_data(a);
-	int key_type = nla_type(ovs_key);
-	struct nlattr *start;
-	int err;
-
-	switch (key_type) {
-	case OVS_KEY_ATTR_IPV4_TUNNEL:
-		start = nla_nest_start(skb, OVS_ACTION_ATTR_SET);
-		if (!start)
-			return -EMSGSIZE;
-
-		err = ovs_ipv4_tun_to_nlattr(skb, nla_data(ovs_key),
-					     nla_data(ovs_key));
-		if (err)
-			return err;
-		nla_nest_end(skb, start);
-		break;
-	default:
-		if (nla_put(skb, OVS_ACTION_ATTR_SET, nla_len(a), ovs_key))
-			return -EMSGSIZE;
-		break;
-	}
-
-	return 0;
-}
-
-static int actions_to_attr(const struct nlattr *attr, int len, struct sk_buff *skb)
-{
-	const struct nlattr *a;
-	int rem, err;
-
-	nla_for_each_attr(a, attr, len, rem) {
-		int type = nla_type(a);
-
-		switch (type) {
-		case OVS_ACTION_ATTR_SET:
-			err = set_action_to_attr(a, skb);
-			if (err)
-				return err;
-			break;
-
-		case OVS_ACTION_ATTR_SAMPLE:
-			err = sample_action_to_attr(a, skb);
-			if (err)
-				return err;
-			break;
-		default:
-			if (nla_put(skb, type, nla_len(a), nla_data(a)))
-				return -EMSGSIZE;
-			break;
-		}
-	}
-
-	return 0;
-}
-
 static size_t ovs_flow_cmd_msg_size(const struct sw_flow_actions *acts)
 {
 	return NLMSG_ALIGN(sizeof(struct ovs_header))
@@ -1133,8 +665,7 @@ static int ovs_flow_cmd_fill_info(struct sw_flow *flow, struct datapath *dp,
 	if (!nla)
 		goto nla_put_failure;
 
-	err = ovs_flow_to_nlattrs(&flow->unmasked_key,
-			&flow->unmasked_key, skb);
+	err = ovs_nla_put_flow(&flow->unmasked_key, &flow->unmasked_key, skb);
 	if (err)
 		goto error;
 	nla_nest_end(skb, nla);
@@ -1143,7 +674,7 @@ static int ovs_flow_cmd_fill_info(struct sw_flow *flow, struct datapath *dp,
 	if (!nla)
 		goto nla_put_failure;
 
-	err = ovs_flow_to_nlattrs(&flow->key, &flow->mask->key, skb);
+	err = ovs_nla_put_flow(&flow->key, &flow->mask->key, skb);
 	if (err)
 		goto error;
 
@@ -1186,7 +717,8 @@ static int ovs_flow_cmd_fill_info(struct sw_flow *flow, struct datapath *dp,
 		sf_acts = rcu_dereference_check(flow->sf_acts,
 						lockdep_ovsl_is_held());
 
-		err = actions_to_attr(sf_acts->actions, sf_acts->actions_len, skb);
+		err = ovs_nla_put_actions(sf_acts->actions,
+					  sf_acts->actions_len, skb);
 		if (!err)
 			nla_nest_end(skb, start);
 		else {
@@ -1252,21 +784,21 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 		goto error;
 
 	ovs_match_init(&match, &key, &mask);
-	error = ovs_match_from_nlattrs(&match,
-			a[OVS_FLOW_ATTR_KEY], a[OVS_FLOW_ATTR_MASK]);
+	error = ovs_nla_get_match(&match,
+				  a[OVS_FLOW_ATTR_KEY], a[OVS_FLOW_ATTR_MASK]);
 	if (error)
 		goto error;
 
 	/* Validate actions. */
 	if (a[OVS_FLOW_ATTR_ACTIONS]) {
-		acts = ovs_flow_actions_alloc(nla_len(a[OVS_FLOW_ATTR_ACTIONS]));
+		acts = ovs_nla_alloc_flow_actions(nla_len(a[OVS_FLOW_ATTR_ACTIONS]));
 		error = PTR_ERR(acts);
 		if (IS_ERR(acts))
 			goto error;
 
-		ovs_flow_key_mask(&masked_key, &key, &mask);
-		error = validate_and_copy_actions(a[OVS_FLOW_ATTR_ACTIONS],
-						  &masked_key, 0, &acts);
+		ovs_flow_mask_key(&masked_key, &key, &mask);
+		error = ovs_nla_copy_actions(a[OVS_FLOW_ATTR_ACTIONS],
+					     &masked_key, 0, &acts);
 		if (error) {
 			OVS_NLERR("Flow actions may not be safe on all matching packets.\n");
 			goto err_kfree;
@@ -1285,7 +817,7 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 	table = ovsl_dereference(dp->table);
 
 	/* Check if this is a duplicate flow */
-	flow = ovs_flow_lookup(table, &key);
+	flow = ovs_flow_tbl_lookup(table, &key);
 	if (!flow) {
 		struct flow_table *new_table = NULL;
 		struct sw_flow_mask *mask_p;
@@ -1336,7 +868,7 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 		rcu_assign_pointer(flow->sf_acts, acts);
 
 		/* Put flow in bucket. */
-		ovs_flow_insert(table, flow);
+		ovs_flow_tbl_insert(table, flow);
 
 		reply = ovs_flow_cmd_build_info(flow, dp, info->snd_portid,
 						info->snd_seq, OVS_FLOW_CMD_NEW);
@@ -1357,7 +889,7 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 
 		/* The unmasked key has to be the same for flow updates. */
 		error = -EINVAL;
-		if (!ovs_flow_cmp_unmasked_key(flow, &key, match.range.end)) {
+		if (!ovs_flow_cmp_unmasked_key(flow, &match)) {
 			OVS_NLERR("Flow modification message rejected, unmasked key does not match.\n");
 			goto err_unlock_ovs;
 		}
@@ -1365,7 +897,7 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 		/* Update actions. */
 		old_acts = ovsl_dereference(flow->sf_acts);
 		rcu_assign_pointer(flow->sf_acts, acts);
-		ovs_flow_deferred_free_acts(old_acts);
+		ovs_nla_free_flow_actions(old_acts);
 
 		reply = ovs_flow_cmd_build_info(flow, dp, info->snd_portid,
 					       info->snd_seq, OVS_FLOW_CMD_NEW);
@@ -1414,7 +946,7 @@ static int ovs_flow_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	}
 
 	ovs_match_init(&match, &key, NULL);
-	err = ovs_match_from_nlattrs(&match, a[OVS_FLOW_ATTR_KEY], NULL);
+	err = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY], NULL);
 	if (err)
 		return err;
 
@@ -1426,8 +958,8 @@ static int ovs_flow_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	}
 
 	table = ovsl_dereference(dp->table);
-	flow = ovs_flow_lookup_unmasked_key(table, &match);
-	if (!flow) {
+	flow = ovs_flow_tbl_lookup(table, &key);
+	if (!flow || !ovs_flow_cmp_unmasked_key(flow, &match)) {
 		err = -ENOENT;
 		goto unlock;
 	}
@@ -1471,13 +1003,13 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	}
 
 	ovs_match_init(&match, &key, NULL);
-	err = ovs_match_from_nlattrs(&match, a[OVS_FLOW_ATTR_KEY], NULL);
+	err = ovs_nla_get_match(&match, a[OVS_FLOW_ATTR_KEY], NULL);
 	if (err)
 		goto unlock;
 
 	table = ovsl_dereference(dp->table);
-	flow = ovs_flow_lookup_unmasked_key(table, &match);
-	if (!flow) {
+	flow = ovs_flow_tbl_lookup(table, &key);
+	if (!flow || !ovs_flow_cmp_unmasked_key(flow, &match)) {
 		err = -ENOENT;
 		goto unlock;
 	}
@@ -1488,7 +1020,7 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 		goto unlock;
 	}
 
-	ovs_flow_remove(table, flow);
+	ovs_flow_tbl_remove(table, flow);
 
 	err = ovs_flow_cmd_fill_info(flow, dp, reply, info->snd_portid,
 				     info->snd_seq, 0, OVS_FLOW_CMD_DEL);
@@ -1524,7 +1056,7 @@ static int ovs_flow_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 
 		bucket = cb->args[0];
 		obj = cb->args[1];
-		flow = ovs_flow_dump_next(table, &bucket, &obj);
+		flow = ovs_flow_tbl_dump_next(table, &bucket, &obj);
 		if (!flow)
 			break;
 
@@ -1700,7 +1232,7 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	}
 
 	dp->ports = kmalloc(DP_VPORT_HASH_BUCKETS * sizeof(struct hlist_head),
-			GFP_KERNEL);
+			    GFP_KERNEL);
 	if (!dp->ports) {
 		err = -ENOMEM;
 		goto err_destroy_percpu;
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 2c15541..a6982ef 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -27,6 +27,7 @@
 #include <linux/u64_stats_sync.h>
 
 #include "flow.h"
+#include "flow_table.h"
 #include "vport.h"
 
 #define DP_MAX_PORTS           USHRT_MAX
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 410db90..617810f 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -45,202 +45,40 @@
 #include <net/ipv6.h>
 #include <net/ndisc.h>
 
-static struct kmem_cache *flow_cache;
-
-static void ovs_sw_flow_mask_set(struct sw_flow_mask *mask,
-		struct sw_flow_key_range *range, u8 val);
-
-static void update_range__(struct sw_flow_match *match,
-			  size_t offset, size_t size, bool is_mask)
+u64 ovs_flow_used_time(unsigned long flow_jiffies)
 {
-	struct sw_flow_key_range *range = NULL;
-	size_t start = rounddown(offset, sizeof(long));
-	size_t end = roundup(offset + size, sizeof(long));
-
-	if (!is_mask)
-		range = &match->range;
-	else if (match->mask)
-		range = &match->mask->range;
-
-	if (!range)
-		return;
-
-	if (range->start == range->end) {
-		range->start = start;
-		range->end = end;
-		return;
-	}
-
-	if (range->start > start)
-		range->start = start;
+	struct timespec cur_ts;
+	u64 cur_ms, idle_ms;
 
-	if (range->end < end)
-		range->end = end;
-}
+	ktime_get_ts(&cur_ts);
+	idle_ms = jiffies_to_msecs(jiffies - flow_jiffies);
+	cur_ms = (u64)cur_ts.tv_sec * MSEC_PER_SEC +
+		 cur_ts.tv_nsec / NSEC_PER_MSEC;
 
-#define SW_FLOW_KEY_PUT(match, field, value, is_mask) \
-	do { \
-		update_range__(match, offsetof(struct sw_flow_key, field),  \
-				     sizeof((match)->key->field), is_mask); \
-		if (is_mask) {						    \
-			if ((match)->mask)				    \
-				(match)->mask->key.field = value;	    \
-		} else {                                                    \
-			(match)->key->field = value;		            \
-		}                                                           \
-	} while (0)
-
-#define SW_FLOW_KEY_MEMCPY(match, field, value_p, len, is_mask) \
-	do { \
-		update_range__(match, offsetof(struct sw_flow_key, field),  \
-				len, is_mask);                              \
-		if (is_mask) {						    \
-			if ((match)->mask)				    \
-				memcpy(&(match)->mask->key.field, value_p, len);\
-		} else {                                                    \
-			memcpy(&(match)->key->field, value_p, len);         \
-		}                                                           \
-	} while (0)
-
-static u16 range_n_bytes(const struct sw_flow_key_range *range)
-{
-	return range->end - range->start;
+	return cur_ms - idle_ms;
 }
 
-void ovs_match_init(struct sw_flow_match *match,
-		    struct sw_flow_key *key,
-		    struct sw_flow_mask *mask)
-{
-	memset(match, 0, sizeof(*match));
-	match->key = key;
-	match->mask = mask;
-
-	memset(key, 0, sizeof(*key));
-
-	if (mask) {
-		memset(&mask->key, 0, sizeof(mask->key));
-		mask->range.start = mask->range.end = 0;
-	}
-}
+#define TCP_FLAGS_OFFSET 13
+#define TCP_FLAG_MASK 0x3f
 
-static bool ovs_match_validate(const struct sw_flow_match *match,
-		u64 key_attrs, u64 mask_attrs)
+void ovs_flow_used(struct sw_flow *flow, struct sk_buff *skb)
 {
-	u64 key_expected = 1 << OVS_KEY_ATTR_ETHERNET;
-	u64 mask_allowed = key_attrs;  /* At most allow all key attributes */
-
-	/* The following mask attributes allowed only if they
-	 * pass the validation tests. */
-	mask_allowed &= ~((1 << OVS_KEY_ATTR_IPV4)
-			| (1 << OVS_KEY_ATTR_IPV6)
-			| (1 << OVS_KEY_ATTR_TCP)
-			| (1 << OVS_KEY_ATTR_UDP)
-			| (1 << OVS_KEY_ATTR_SCTP)
-			| (1 << OVS_KEY_ATTR_ICMP)
-			| (1 << OVS_KEY_ATTR_ICMPV6)
-			| (1 << OVS_KEY_ATTR_ARP)
-			| (1 << OVS_KEY_ATTR_ND));
-
-	/* Always allowed mask fields. */
-	mask_allowed |= ((1 << OVS_KEY_ATTR_TUNNEL)
-		       | (1 << OVS_KEY_ATTR_IN_PORT)
-		       | (1 << OVS_KEY_ATTR_ETHERTYPE));
-
-	/* Check key attributes. */
-	if (match->key->eth.type == htons(ETH_P_ARP)
-			|| match->key->eth.type == htons(ETH_P_RARP)) {
-		key_expected |= 1 << OVS_KEY_ATTR_ARP;
-		if (match->mask && (match->mask->key.eth.type == htons(0xffff)))
-			mask_allowed |= 1 << OVS_KEY_ATTR_ARP;
-	}
-
-	if (match->key->eth.type == htons(ETH_P_IP)) {
-		key_expected |= 1 << OVS_KEY_ATTR_IPV4;
-		if (match->mask && (match->mask->key.eth.type == htons(0xffff)))
-			mask_allowed |= 1 << OVS_KEY_ATTR_IPV4;
-
-		if (match->key->ip.frag != OVS_FRAG_TYPE_LATER) {
-			if (match->key->ip.proto == IPPROTO_UDP) {
-				key_expected |= 1 << OVS_KEY_ATTR_UDP;
-				if (match->mask && (match->mask->key.ip.proto == 0xff))
-					mask_allowed |= 1 << OVS_KEY_ATTR_UDP;
-			}
-
-			if (match->key->ip.proto == IPPROTO_SCTP) {
-				key_expected |= 1 << OVS_KEY_ATTR_SCTP;
-				if (match->mask && (match->mask->key.ip.proto == 0xff))
-					mask_allowed |= 1 << OVS_KEY_ATTR_SCTP;
-			}
-
-			if (match->key->ip.proto == IPPROTO_TCP) {
-				key_expected |= 1 << OVS_KEY_ATTR_TCP;
-				if (match->mask && (match->mask->key.ip.proto == 0xff))
-					mask_allowed |= 1 << OVS_KEY_ATTR_TCP;
-			}
-
-			if (match->key->ip.proto == IPPROTO_ICMP) {
-				key_expected |= 1 << OVS_KEY_ATTR_ICMP;
-				if (match->mask && (match->mask->key.ip.proto == 0xff))
-					mask_allowed |= 1 << OVS_KEY_ATTR_ICMP;
-			}
-		}
-	}
-
-	if (match->key->eth.type == htons(ETH_P_IPV6)) {
-		key_expected |= 1 << OVS_KEY_ATTR_IPV6;
-		if (match->mask && (match->mask->key.eth.type == htons(0xffff)))
-			mask_allowed |= 1 << OVS_KEY_ATTR_IPV6;
-
-		if (match->key->ip.frag != OVS_FRAG_TYPE_LATER) {
-			if (match->key->ip.proto == IPPROTO_UDP) {
-				key_expected |= 1 << OVS_KEY_ATTR_UDP;
-				if (match->mask && (match->mask->key.ip.proto == 0xff))
-					mask_allowed |= 1 << OVS_KEY_ATTR_UDP;
-			}
-
-			if (match->key->ip.proto == IPPROTO_SCTP) {
-				key_expected |= 1 << OVS_KEY_ATTR_SCTP;
-				if (match->mask && (match->mask->key.ip.proto == 0xff))
-					mask_allowed |= 1 << OVS_KEY_ATTR_SCTP;
-			}
-
-			if (match->key->ip.proto == IPPROTO_TCP) {
-				key_expected |= 1 << OVS_KEY_ATTR_TCP;
-				if (match->mask && (match->mask->key.ip.proto == 0xff))
-					mask_allowed |= 1 << OVS_KEY_ATTR_TCP;
-			}
-
-			if (match->key->ip.proto == IPPROTO_ICMPV6) {
-				key_expected |= 1 << OVS_KEY_ATTR_ICMPV6;
-				if (match->mask && (match->mask->key.ip.proto == 0xff))
-					mask_allowed |= 1 << OVS_KEY_ATTR_ICMPV6;
-
-				if (match->key->ipv6.tp.src ==
-						htons(NDISC_NEIGHBOUR_SOLICITATION) ||
-				    match->key->ipv6.tp.src == htons(NDISC_NEIGHBOUR_ADVERTISEMENT)) {
-					key_expected |= 1 << OVS_KEY_ATTR_ND;
-					if (match->mask && (match->mask->key.ipv6.tp.src == htons(0xffff)))
-						mask_allowed |= 1 << OVS_KEY_ATTR_ND;
-				}
-			}
-		}
-	}
-
-	if ((key_attrs & key_expected) != key_expected) {
-		/* Key attributes check failed. */
-		OVS_NLERR("Missing expected key attributes (key_attrs=%llx, expected=%llx).\n",
-				key_attrs, key_expected);
-		return false;
-	}
+	u8 tcp_flags = 0;
 
-	if ((mask_attrs & mask_allowed) != mask_attrs) {
-		/* Mask attributes check failed. */
-		OVS_NLERR("Contain more than allowed mask fields (mask_attrs=%llx, mask_allowed=%llx).\n",
-				mask_attrs, mask_allowed);
-		return false;
+	if ((flow->key.eth.type == htons(ETH_P_IP) ||
+	     flow->key.eth.type == htons(ETH_P_IPV6)) &&
+	    flow->key.ip.proto == IPPROTO_TCP &&
+	    likely(skb->len >= skb_transport_offset(skb) + sizeof(struct tcphdr))) {
+		u8 *tcp = (u8 *)tcp_hdr(skb);
+		tcp_flags = *(tcp + TCP_FLAGS_OFFSET) & TCP_FLAG_MASK;
 	}
 
-	return true;
+	spin_lock(&flow->lock);
+	flow->used = jiffies;
+	flow->packet_count++;
+	flow->byte_count += skb->len;
+	flow->tcp_flags |= tcp_flags;
+	spin_unlock(&flow->lock);
 }
 
 static int check_header(struct sk_buff *skb, int len)
@@ -311,19 +149,6 @@ static bool icmphdr_ok(struct sk_buff *skb)
 				  sizeof(struct icmphdr));
 }
 
-u64 ovs_flow_used_time(unsigned long flow_jiffies)
-{
-	struct timespec cur_ts;
-	u64 cur_ms, idle_ms;
-
-	ktime_get_ts(&cur_ts);
-	idle_ms = jiffies_to_msecs(jiffies - flow_jiffies);
-	cur_ms = (u64)cur_ts.tv_sec * MSEC_PER_SEC +
-		 cur_ts.tv_nsec / NSEC_PER_MSEC;
-
-	return cur_ms - idle_ms;
-}
-
 static int parse_ipv6hdr(struct sk_buff *skb, struct sw_flow_key *key)
 {
 	unsigned int nh_ofs = skb_network_offset(skb);
@@ -372,311 +197,6 @@ static bool icmp6hdr_ok(struct sk_buff *skb)
 				  sizeof(struct icmp6hdr));
 }
 
-void ovs_flow_key_mask(struct sw_flow_key *dst, const struct sw_flow_key *src,
-		       const struct sw_flow_mask *mask)
-{
-	const long *m = (long *)((u8 *)&mask->key + mask->range.start);
-	const long *s = (long *)((u8 *)src + mask->range.start);
-	long *d = (long *)((u8 *)dst + mask->range.start);
-	int i;
-
-	/* The memory outside of the 'mask->range' are not set since
-	 * further operations on 'dst' only uses contents within
-	 * 'mask->range'.
-	 */
-	for (i = 0; i < range_n_bytes(&mask->range); i += sizeof(long))
-		*d++ = *s++ & *m++;
-}
-
-#define TCP_FLAGS_OFFSET 13
-#define TCP_FLAG_MASK 0x3f
-
-void ovs_flow_used(struct sw_flow *flow, struct sk_buff *skb)
-{
-	u8 tcp_flags = 0;
-
-	if ((flow->key.eth.type == htons(ETH_P_IP) ||
-	     flow->key.eth.type == htons(ETH_P_IPV6)) &&
-	    flow->key.ip.proto == IPPROTO_TCP &&
-	    likely(skb->len >= skb_transport_offset(skb) + sizeof(struct tcphdr))) {
-		u8 *tcp = (u8 *)tcp_hdr(skb);
-		tcp_flags = *(tcp + TCP_FLAGS_OFFSET) & TCP_FLAG_MASK;
-	}
-
-	spin_lock(&flow->lock);
-	flow->used = jiffies;
-	flow->packet_count++;
-	flow->byte_count += skb->len;
-	flow->tcp_flags |= tcp_flags;
-	spin_unlock(&flow->lock);
-}
-
-struct sw_flow_actions *ovs_flow_actions_alloc(int size)
-{
-	struct sw_flow_actions *sfa;
-
-	if (size > MAX_ACTIONS_BUFSIZE)
-		return ERR_PTR(-EINVAL);
-
-	sfa = kmalloc(sizeof(*sfa) + size, GFP_KERNEL);
-	if (!sfa)
-		return ERR_PTR(-ENOMEM);
-
-	sfa->actions_len = 0;
-	return sfa;
-}
-
-struct sw_flow *ovs_flow_alloc(void)
-{
-	struct sw_flow *flow;
-
-	flow = kmem_cache_alloc(flow_cache, GFP_KERNEL);
-	if (!flow)
-		return ERR_PTR(-ENOMEM);
-
-	spin_lock_init(&flow->lock);
-	flow->sf_acts = NULL;
-	flow->mask = NULL;
-
-	return flow;
-}
-
-static struct hlist_head *find_bucket(struct flow_table *table, u32 hash)
-{
-	hash = jhash_1word(hash, table->hash_seed);
-	return flex_array_get(table->buckets,
-				(hash & (table->n_buckets - 1)));
-}
-
-static struct flex_array *alloc_buckets(unsigned int n_buckets)
-{
-	struct flex_array *buckets;
-	int i, err;
-
-	buckets = flex_array_alloc(sizeof(struct hlist_head),
-				   n_buckets, GFP_KERNEL);
-	if (!buckets)
-		return NULL;
-
-	err = flex_array_prealloc(buckets, 0, n_buckets, GFP_KERNEL);
-	if (err) {
-		flex_array_free(buckets);
-		return NULL;
-	}
-
-	for (i = 0; i < n_buckets; i++)
-		INIT_HLIST_HEAD((struct hlist_head *)
-					flex_array_get(buckets, i));
-
-	return buckets;
-}
-
-static void free_buckets(struct flex_array *buckets)
-{
-	flex_array_free(buckets);
-}
-
-static struct flow_table *__flow_tbl_alloc(int new_size)
-{
-	struct flow_table *table = kmalloc(sizeof(*table), GFP_KERNEL);
-
-	if (!table)
-		return NULL;
-
-	table->buckets = alloc_buckets(new_size);
-
-	if (!table->buckets) {
-		kfree(table);
-		return NULL;
-	}
-	table->n_buckets = new_size;
-	table->count = 0;
-	table->node_ver = 0;
-	table->keep_flows = false;
-	get_random_bytes(&table->hash_seed, sizeof(u32));
-	table->mask_list = NULL;
-
-	return table;
-}
-
-static void __flow_tbl_destroy(struct flow_table *table)
-{
-	int i;
-
-	if (table->keep_flows)
-		goto skip_flows;
-
-	for (i = 0; i < table->n_buckets; i++) {
-		struct sw_flow *flow;
-		struct hlist_head *head = flex_array_get(table->buckets, i);
-		struct hlist_node *n;
-		int ver = table->node_ver;
-
-		hlist_for_each_entry_safe(flow, n, head, hash_node[ver]) {
-			hlist_del(&flow->hash_node[ver]);
-			ovs_flow_free(flow, false);
-		}
-	}
-
-	BUG_ON(!list_empty(table->mask_list));
-	kfree(table->mask_list);
-
-skip_flows:
-	free_buckets(table->buckets);
-	kfree(table);
-}
-
-struct flow_table *ovs_flow_tbl_alloc(int new_size)
-{
-	struct flow_table *table = __flow_tbl_alloc(new_size);
-
-	if (!table)
-		return NULL;
-
-	table->mask_list = kmalloc(sizeof(struct list_head), GFP_KERNEL);
-	if (!table->mask_list) {
-		table->keep_flows = true;
-		__flow_tbl_destroy(table);
-		return NULL;
-	}
-	INIT_LIST_HEAD(table->mask_list);
-
-	return table;
-}
-
-static void flow_tbl_destroy_rcu_cb(struct rcu_head *rcu)
-{
-	struct flow_table *table = container_of(rcu, struct flow_table, rcu);
-
-	__flow_tbl_destroy(table);
-}
-
-void ovs_flow_tbl_destroy(struct flow_table *table, bool deferred)
-{
-	if (!table)
-		return;
-
-	if (deferred)
-		call_rcu(&table->rcu, flow_tbl_destroy_rcu_cb);
-	else
-		__flow_tbl_destroy(table);
-}
-
-struct sw_flow *ovs_flow_dump_next(struct flow_table *table, u32 *bucket, u32 *last)
-{
-	struct sw_flow *flow;
-	struct hlist_head *head;
-	int ver;
-	int i;
-
-	ver = table->node_ver;
-	while (*bucket < table->n_buckets) {
-		i = 0;
-		head = flex_array_get(table->buckets, *bucket);
-		hlist_for_each_entry_rcu(flow, head, hash_node[ver]) {
-			if (i < *last) {
-				i++;
-				continue;
-			}
-			*last = i + 1;
-			return flow;
-		}
-		(*bucket)++;
-		*last = 0;
-	}
-
-	return NULL;
-}
-
-static void __tbl_insert(struct flow_table *table, struct sw_flow *flow)
-{
-	struct hlist_head *head;
-
-	head = find_bucket(table, flow->hash);
-	hlist_add_head_rcu(&flow->hash_node[table->node_ver], head);
-
-	table->count++;
-}
-
-static void flow_table_copy_flows(struct flow_table *old, struct flow_table *new)
-{
-	int old_ver;
-	int i;
-
-	old_ver = old->node_ver;
-	new->node_ver = !old_ver;
-
-	/* Insert in new table. */
-	for (i = 0; i < old->n_buckets; i++) {
-		struct sw_flow *flow;
-		struct hlist_head *head;
-
-		head = flex_array_get(old->buckets, i);
-
-		hlist_for_each_entry(flow, head, hash_node[old_ver])
-			__tbl_insert(new, flow);
-	}
-
-	new->mask_list = old->mask_list;
-	old->keep_flows = true;
-}
-
-static struct flow_table *__flow_tbl_rehash(struct flow_table *table, int n_buckets)
-{
-	struct flow_table *new_table;
-
-	new_table = __flow_tbl_alloc(n_buckets);
-	if (!new_table)
-		return ERR_PTR(-ENOMEM);
-
-	flow_table_copy_flows(table, new_table);
-
-	return new_table;
-}
-
-struct flow_table *ovs_flow_tbl_rehash(struct flow_table *table)
-{
-	return __flow_tbl_rehash(table, table->n_buckets);
-}
-
-struct flow_table *ovs_flow_tbl_expand(struct flow_table *table)
-{
-	return __flow_tbl_rehash(table, table->n_buckets * 2);
-}
-
-static void __flow_free(struct sw_flow *flow)
-{
-	kfree((struct sf_flow_acts __force *)flow->sf_acts);
-	kmem_cache_free(flow_cache, flow);
-}
-
-static void rcu_free_flow_callback(struct rcu_head *rcu)
-{
-	struct sw_flow *flow = container_of(rcu, struct sw_flow, rcu);
-
-	__flow_free(flow);
-}
-
-void ovs_flow_free(struct sw_flow *flow, bool deferred)
-{
-	if (!flow)
-		return;
-
-	ovs_sw_flow_mask_del_ref(flow->mask, deferred);
-
-	if (deferred)
-		call_rcu(&flow->rcu, rcu_free_flow_callback);
-	else
-		__flow_free(flow);
-}
-
-/* Schedules 'sf_acts' to be freed after the next RCU grace period.
- * The caller must hold rcu_read_lock for this to be sensible. */
-void ovs_flow_deferred_free_acts(struct sw_flow_actions *sf_acts)
-{
-	kfree_rcu(sf_acts, rcu);
-}
-
 static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
 {
 	struct qtag_prefix {
@@ -1002,1080 +522,3 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key)
 
 	return 0;
 }
-
-static u32 ovs_flow_hash(const struct sw_flow_key *key, int key_start,
-			 int key_end)
-{
-	u32 *hash_key = (u32 *)((u8 *)key + key_start);
-	int hash_u32s = (key_end - key_start) >> 2;
-
-	/* Make sure number of hash bytes are multiple of u32. */
-	BUILD_BUG_ON(sizeof(long) % sizeof(u32));
-
-	return jhash2(hash_key, hash_u32s, 0);
-}
-
-static int flow_key_start(const struct sw_flow_key *key)
-{
-	if (key->tun_key.ipv4_dst)
-		return 0;
-	else
-		return rounddown(offsetof(struct sw_flow_key, phy),
-					  sizeof(long));
-}
-
-static bool __cmp_key(const struct sw_flow_key *key1,
-		const struct sw_flow_key *key2,  int key_start, int key_end)
-{
-	const long *cp1 = (long *)((u8 *)key1 + key_start);
-	const long *cp2 = (long *)((u8 *)key2 + key_start);
-	long diffs = 0;
-	int i;
-
-	for (i = key_start; i < key_end;  i += sizeof(long))
-		diffs |= *cp1++ ^ *cp2++;
-
-	return diffs == 0;
-}
-
-static bool __flow_cmp_masked_key(const struct sw_flow *flow,
-		const struct sw_flow_key *key, int key_start, int key_end)
-{
-	return __cmp_key(&flow->key, key, key_start, key_end);
-}
-
-static bool __flow_cmp_unmasked_key(const struct sw_flow *flow,
-		  const struct sw_flow_key *key, int key_start, int key_end)
-{
-	return __cmp_key(&flow->unmasked_key, key, key_start, key_end);
-}
-
-bool ovs_flow_cmp_unmasked_key(const struct sw_flow *flow,
-		const struct sw_flow_key *key, int key_end)
-{
-	int key_start;
-	key_start = flow_key_start(key);
-
-	return __flow_cmp_unmasked_key(flow, key, key_start, key_end);
-
-}
-
-struct sw_flow *ovs_flow_lookup_unmasked_key(struct flow_table *table,
-				       struct sw_flow_match *match)
-{
-	struct sw_flow_key *unmasked = match->key;
-	int key_end = match->range.end;
-	struct sw_flow *flow;
-
-	flow = ovs_flow_lookup(table, unmasked);
-	if (flow && (!ovs_flow_cmp_unmasked_key(flow, unmasked, key_end)))
-		flow = NULL;
-
-	return flow;
-}
-
-static struct sw_flow *ovs_masked_flow_lookup(struct flow_table *table,
-				    const struct sw_flow_key *unmasked,
-				    struct sw_flow_mask *mask)
-{
-	struct sw_flow *flow;
-	struct hlist_head *head;
-	int key_start = mask->range.start;
-	int key_end = mask->range.end;
-	u32 hash;
-	struct sw_flow_key masked_key;
-
-	ovs_flow_key_mask(&masked_key, unmasked, mask);
-	hash = ovs_flow_hash(&masked_key, key_start, key_end);
-	head = find_bucket(table, hash);
-	hlist_for_each_entry_rcu(flow, head, hash_node[table->node_ver]) {
-		if (flow->mask == mask &&
-		    __flow_cmp_masked_key(flow, &masked_key,
-					  key_start, key_end))
-			return flow;
-	}
-	return NULL;
-}
-
-struct sw_flow *ovs_flow_lookup(struct flow_table *tbl,
-				const struct sw_flow_key *key)
-{
-	struct sw_flow *flow = NULL;
-	struct sw_flow_mask *mask;
-
-	list_for_each_entry_rcu(mask, tbl->mask_list, list) {
-		flow = ovs_masked_flow_lookup(tbl, key, mask);
-		if (flow)  /* Found */
-			break;
-	}
-
-	return flow;
-}
-
-
-void ovs_flow_insert(struct flow_table *table, struct sw_flow *flow)
-{
-	flow->hash = ovs_flow_hash(&flow->key, flow->mask->range.start,
-			flow->mask->range.end);
-	__tbl_insert(table, flow);
-}
-
-void ovs_flow_remove(struct flow_table *table, struct sw_flow *flow)
-{
-	BUG_ON(table->count == 0);
-	hlist_del_rcu(&flow->hash_node[table->node_ver]);
-	table->count--;
-}
-
-/* The size of the argument for each %OVS_KEY_ATTR_* Netlink attribute.  */
-const int ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
-	[OVS_KEY_ATTR_ENCAP] = -1,
-	[OVS_KEY_ATTR_PRIORITY] = sizeof(u32),
-	[OVS_KEY_ATTR_IN_PORT] = sizeof(u32),
-	[OVS_KEY_ATTR_SKB_MARK] = sizeof(u32),
-	[OVS_KEY_ATTR_ETHERNET] = sizeof(struct ovs_key_ethernet),
-	[OVS_KEY_ATTR_VLAN] = sizeof(__be16),
-	[OVS_KEY_ATTR_ETHERTYPE] = sizeof(__be16),
-	[OVS_KEY_ATTR_IPV4] = sizeof(struct ovs_key_ipv4),
-	[OVS_KEY_ATTR_IPV6] = sizeof(struct ovs_key_ipv6),
-	[OVS_KEY_ATTR_TCP] = sizeof(struct ovs_key_tcp),
-	[OVS_KEY_ATTR_UDP] = sizeof(struct ovs_key_udp),
-	[OVS_KEY_ATTR_SCTP] = sizeof(struct ovs_key_sctp),
-	[OVS_KEY_ATTR_ICMP] = sizeof(struct ovs_key_icmp),
-	[OVS_KEY_ATTR_ICMPV6] = sizeof(struct ovs_key_icmpv6),
-	[OVS_KEY_ATTR_ARP] = sizeof(struct ovs_key_arp),
-	[OVS_KEY_ATTR_ND] = sizeof(struct ovs_key_nd),
-	[OVS_KEY_ATTR_TUNNEL] = -1,
-};
-
-static bool is_all_zero(const u8 *fp, size_t size)
-{
-	int i;
-
-	if (!fp)
-		return false;
-
-	for (i = 0; i < size; i++)
-		if (fp[i])
-			return false;
-
-	return true;
-}
-
-static int __parse_flow_nlattrs(const struct nlattr *attr,
-			      const struct nlattr *a[],
-			      u64 *attrsp, bool nz)
-{
-	const struct nlattr *nla;
-	u32 attrs;
-	int rem;
-
-	attrs = *attrsp;
-	nla_for_each_nested(nla, attr, rem) {
-		u16 type = nla_type(nla);
-		int expected_len;
-
-		if (type > OVS_KEY_ATTR_MAX) {
-			OVS_NLERR("Unknown key attribute (type=%d, max=%d).\n",
-				  type, OVS_KEY_ATTR_MAX);
-			return -EINVAL;
-		}
-
-		if (attrs & (1 << type)) {
-			OVS_NLERR("Duplicate key attribute (type %d).\n", type);
-			return -EINVAL;
-		}
-
-		expected_len = ovs_key_lens[type];
-		if (nla_len(nla) != expected_len && expected_len != -1) {
-			OVS_NLERR("Key attribute has unexpected length (type=%d"
-				  ", length=%d, expected=%d).\n", type,
-				  nla_len(nla), expected_len);
-			return -EINVAL;
-		}
-
-		if (!nz || !is_all_zero(nla_data(nla), expected_len)) {
-			attrs |= 1 << type;
-			a[type] = nla;
-		}
-	}
-	if (rem) {
-		OVS_NLERR("Message has %d unknown bytes.\n", rem);
-		return -EINVAL;
-	}
-
-	*attrsp = attrs;
-	return 0;
-}
-
-static int parse_flow_mask_nlattrs(const struct nlattr *attr,
-			      const struct nlattr *a[], u64 *attrsp)
-{
-	return __parse_flow_nlattrs(attr, a, attrsp, true);
-}
-
-static int parse_flow_nlattrs(const struct nlattr *attr,
-			      const struct nlattr *a[], u64 *attrsp)
-{
-	return __parse_flow_nlattrs(attr, a, attrsp, false);
-}
-
-int ovs_ipv4_tun_from_nlattr(const struct nlattr *attr,
-			     struct sw_flow_match *match, bool is_mask)
-{
-	struct nlattr *a;
-	int rem;
-	bool ttl = false;
-	__be16 tun_flags = 0;
-
-	nla_for_each_nested(a, attr, rem) {
-		int type = nla_type(a);
-		static const u32 ovs_tunnel_key_lens[OVS_TUNNEL_KEY_ATTR_MAX + 1] = {
-			[OVS_TUNNEL_KEY_ATTR_ID] = sizeof(u64),
-			[OVS_TUNNEL_KEY_ATTR_IPV4_SRC] = sizeof(u32),
-			[OVS_TUNNEL_KEY_ATTR_IPV4_DST] = sizeof(u32),
-			[OVS_TUNNEL_KEY_ATTR_TOS] = 1,
-			[OVS_TUNNEL_KEY_ATTR_TTL] = 1,
-			[OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT] = 0,
-			[OVS_TUNNEL_KEY_ATTR_CSUM] = 0,
-		};
-
-		if (type > OVS_TUNNEL_KEY_ATTR_MAX) {
-			OVS_NLERR("Unknown IPv4 tunnel attribute (type=%d, max=%d).\n",
-			type, OVS_TUNNEL_KEY_ATTR_MAX);
-			return -EINVAL;
-		}
-
-		if (ovs_tunnel_key_lens[type] != nla_len(a)) {
-			OVS_NLERR("IPv4 tunnel attribute type has unexpected "
-				  " length (type=%d, length=%d, expected=%d).\n",
-				  type, nla_len(a), ovs_tunnel_key_lens[type]);
-			return -EINVAL;
-		}
-
-		switch (type) {
-		case OVS_TUNNEL_KEY_ATTR_ID:
-			SW_FLOW_KEY_PUT(match, tun_key.tun_id,
-					nla_get_be64(a), is_mask);
-			tun_flags |= TUNNEL_KEY;
-			break;
-		case OVS_TUNNEL_KEY_ATTR_IPV4_SRC:
-			SW_FLOW_KEY_PUT(match, tun_key.ipv4_src,
-					nla_get_be32(a), is_mask);
-			break;
-		case OVS_TUNNEL_KEY_ATTR_IPV4_DST:
-			SW_FLOW_KEY_PUT(match, tun_key.ipv4_dst,
-					nla_get_be32(a), is_mask);
-			break;
-		case OVS_TUNNEL_KEY_ATTR_TOS:
-			SW_FLOW_KEY_PUT(match, tun_key.ipv4_tos,
-					nla_get_u8(a), is_mask);
-			break;
-		case OVS_TUNNEL_KEY_ATTR_TTL:
-			SW_FLOW_KEY_PUT(match, tun_key.ipv4_ttl,
-					nla_get_u8(a), is_mask);
-			ttl = true;
-			break;
-		case OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT:
-			tun_flags |= TUNNEL_DONT_FRAGMENT;
-			break;
-		case OVS_TUNNEL_KEY_ATTR_CSUM:
-			tun_flags |= TUNNEL_CSUM;
-			break;
-		default:
-			return -EINVAL;
-		}
-	}
-
-	SW_FLOW_KEY_PUT(match, tun_key.tun_flags, tun_flags, is_mask);
-
-	if (rem > 0) {
-		OVS_NLERR("IPv4 tunnel attribute has %d unknown bytes.\n", rem);
-		return -EINVAL;
-	}
-
-	if (!is_mask) {
-		if (!match->key->tun_key.ipv4_dst) {
-			OVS_NLERR("IPv4 tunnel destination address is zero.\n");
-			return -EINVAL;
-		}
-
-		if (!ttl) {
-			OVS_NLERR("IPv4 tunnel TTL not specified.\n");
-			return -EINVAL;
-		}
-	}
-
-	return 0;
-}
-
-int ovs_ipv4_tun_to_nlattr(struct sk_buff *skb,
-			   const struct ovs_key_ipv4_tunnel *tun_key,
-			   const struct ovs_key_ipv4_tunnel *output)
-{
-	struct nlattr *nla;
-
-	nla = nla_nest_start(skb, OVS_KEY_ATTR_TUNNEL);
-	if (!nla)
-		return -EMSGSIZE;
-
-	if (output->tun_flags & TUNNEL_KEY &&
-	    nla_put_be64(skb, OVS_TUNNEL_KEY_ATTR_ID, output->tun_id))
-		return -EMSGSIZE;
-	if (output->ipv4_src &&
-		nla_put_be32(skb, OVS_TUNNEL_KEY_ATTR_IPV4_SRC, output->ipv4_src))
-		return -EMSGSIZE;
-	if (output->ipv4_dst &&
-		nla_put_be32(skb, OVS_TUNNEL_KEY_ATTR_IPV4_DST, output->ipv4_dst))
-		return -EMSGSIZE;
-	if (output->ipv4_tos &&
-		nla_put_u8(skb, OVS_TUNNEL_KEY_ATTR_TOS, output->ipv4_tos))
-		return -EMSGSIZE;
-	if (nla_put_u8(skb, OVS_TUNNEL_KEY_ATTR_TTL, output->ipv4_ttl))
-		return -EMSGSIZE;
-	if ((output->tun_flags & TUNNEL_DONT_FRAGMENT) &&
-		nla_put_flag(skb, OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT))
-		return -EMSGSIZE;
-	if ((output->tun_flags & TUNNEL_CSUM) &&
-		nla_put_flag(skb, OVS_TUNNEL_KEY_ATTR_CSUM))
-		return -EMSGSIZE;
-
-	nla_nest_end(skb, nla);
-	return 0;
-}
-
-static int metadata_from_nlattrs(struct sw_flow_match *match,  u64 *attrs,
-		const struct nlattr **a, bool is_mask)
-{
-	if (*attrs & (1 << OVS_KEY_ATTR_PRIORITY)) {
-		SW_FLOW_KEY_PUT(match, phy.priority,
-			  nla_get_u32(a[OVS_KEY_ATTR_PRIORITY]), is_mask);
-		*attrs &= ~(1 << OVS_KEY_ATTR_PRIORITY);
-	}
-
-	if (*attrs & (1 << OVS_KEY_ATTR_IN_PORT)) {
-		u32 in_port = nla_get_u32(a[OVS_KEY_ATTR_IN_PORT]);
-
-		if (is_mask)
-			in_port = 0xffffffff; /* Always exact match in_port. */
-		else if (in_port >= DP_MAX_PORTS)
-			return -EINVAL;
-
-		SW_FLOW_KEY_PUT(match, phy.in_port, in_port, is_mask);
-		*attrs &= ~(1 << OVS_KEY_ATTR_IN_PORT);
-	} else if (!is_mask) {
-		SW_FLOW_KEY_PUT(match, phy.in_port, DP_MAX_PORTS, is_mask);
-	}
-
-	if (*attrs & (1 << OVS_KEY_ATTR_SKB_MARK)) {
-		uint32_t mark = nla_get_u32(a[OVS_KEY_ATTR_SKB_MARK]);
-
-		SW_FLOW_KEY_PUT(match, phy.skb_mark, mark, is_mask);
-		*attrs &= ~(1 << OVS_KEY_ATTR_SKB_MARK);
-	}
-	if (*attrs & (1 << OVS_KEY_ATTR_TUNNEL)) {
-		if (ovs_ipv4_tun_from_nlattr(a[OVS_KEY_ATTR_TUNNEL], match,
-					is_mask))
-			return -EINVAL;
-		*attrs &= ~(1 << OVS_KEY_ATTR_TUNNEL);
-	}
-	return 0;
-}
-
-static int ovs_key_from_nlattrs(struct sw_flow_match *match,  u64 attrs,
-		const struct nlattr **a, bool is_mask)
-{
-	int err;
-	u64 orig_attrs = attrs;
-
-	err = metadata_from_nlattrs(match, &attrs, a, is_mask);
-	if (err)
-		return err;
-
-	if (attrs & (1 << OVS_KEY_ATTR_ETHERNET)) {
-		const struct ovs_key_ethernet *eth_key;
-
-		eth_key = nla_data(a[OVS_KEY_ATTR_ETHERNET]);
-		SW_FLOW_KEY_MEMCPY(match, eth.src,
-				eth_key->eth_src, ETH_ALEN, is_mask);
-		SW_FLOW_KEY_MEMCPY(match, eth.dst,
-				eth_key->eth_dst, ETH_ALEN, is_mask);
-		attrs &= ~(1 << OVS_KEY_ATTR_ETHERNET);
-	}
-
-	if (attrs & (1 << OVS_KEY_ATTR_VLAN)) {
-		__be16 tci;
-
-		tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
-		if (!(tci & htons(VLAN_TAG_PRESENT))) {
-			if (is_mask)
-				OVS_NLERR("VLAN TCI mask does not have exact match for VLAN_TAG_PRESENT bit.\n");
-			else
-				OVS_NLERR("VLAN TCI does not have VLAN_TAG_PRESENT bit set.\n");
-
-			return -EINVAL;
-		}
-
-		SW_FLOW_KEY_PUT(match, eth.tci, tci, is_mask);
-		attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
-	} else if (!is_mask)
-		SW_FLOW_KEY_PUT(match, eth.tci, htons(0xffff), true);
-
-	if (attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) {
-		__be16 eth_type;
-
-		eth_type = nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]);
-		if (is_mask) {
-			/* Always exact match EtherType. */
-			eth_type = htons(0xffff);
-		} else if (ntohs(eth_type) < ETH_P_802_3_MIN) {
-			OVS_NLERR("EtherType is less than minimum (type=%x, min=%x).\n",
-					ntohs(eth_type), ETH_P_802_3_MIN);
-			return -EINVAL;
-		}
-
-		SW_FLOW_KEY_PUT(match, eth.type, eth_type, is_mask);
-		attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
-	} else if (!is_mask) {
-		SW_FLOW_KEY_PUT(match, eth.type, htons(ETH_P_802_2), is_mask);
-	}
-
-	if (attrs & (1 << OVS_KEY_ATTR_IPV4)) {
-		const struct ovs_key_ipv4 *ipv4_key;
-
-		ipv4_key = nla_data(a[OVS_KEY_ATTR_IPV4]);
-		if (!is_mask && ipv4_key->ipv4_frag > OVS_FRAG_TYPE_MAX) {
-			OVS_NLERR("Unknown IPv4 fragment type (value=%d, max=%d).\n",
-				ipv4_key->ipv4_frag, OVS_FRAG_TYPE_MAX);
-			return -EINVAL;
-		}
-		SW_FLOW_KEY_PUT(match, ip.proto,
-				ipv4_key->ipv4_proto, is_mask);
-		SW_FLOW_KEY_PUT(match, ip.tos,
-				ipv4_key->ipv4_tos, is_mask);
-		SW_FLOW_KEY_PUT(match, ip.ttl,
-				ipv4_key->ipv4_ttl, is_mask);
-		SW_FLOW_KEY_PUT(match, ip.frag,
-				ipv4_key->ipv4_frag, is_mask);
-		SW_FLOW_KEY_PUT(match, ipv4.addr.src,
-				ipv4_key->ipv4_src, is_mask);
-		SW_FLOW_KEY_PUT(match, ipv4.addr.dst,
-				ipv4_key->ipv4_dst, is_mask);
-		attrs &= ~(1 << OVS_KEY_ATTR_IPV4);
-	}
-
-	if (attrs & (1 << OVS_KEY_ATTR_IPV6)) {
-		const struct ovs_key_ipv6 *ipv6_key;
-
-		ipv6_key = nla_data(a[OVS_KEY_ATTR_IPV6]);
-		if (!is_mask && ipv6_key->ipv6_frag > OVS_FRAG_TYPE_MAX) {
-			OVS_NLERR("Unknown IPv6 fragment type (value=%d, max=%d).\n",
-				ipv6_key->ipv6_frag, OVS_FRAG_TYPE_MAX);
-			return -EINVAL;
-		}
-		SW_FLOW_KEY_PUT(match, ipv6.label,
-				ipv6_key->ipv6_label, is_mask);
-		SW_FLOW_KEY_PUT(match, ip.proto,
-				ipv6_key->ipv6_proto, is_mask);
-		SW_FLOW_KEY_PUT(match, ip.tos,
-				ipv6_key->ipv6_tclass, is_mask);
-		SW_FLOW_KEY_PUT(match, ip.ttl,
-				ipv6_key->ipv6_hlimit, is_mask);
-		SW_FLOW_KEY_PUT(match, ip.frag,
-				ipv6_key->ipv6_frag, is_mask);
-		SW_FLOW_KEY_MEMCPY(match, ipv6.addr.src,
-				ipv6_key->ipv6_src,
-				sizeof(match->key->ipv6.addr.src),
-				is_mask);
-		SW_FLOW_KEY_MEMCPY(match, ipv6.addr.dst,
-				ipv6_key->ipv6_dst,
-				sizeof(match->key->ipv6.addr.dst),
-				is_mask);
-
-		attrs &= ~(1 << OVS_KEY_ATTR_IPV6);
-	}
-
-	if (attrs & (1 << OVS_KEY_ATTR_ARP)) {
-		const struct ovs_key_arp *arp_key;
-
-		arp_key = nla_data(a[OVS_KEY_ATTR_ARP]);
-		if (!is_mask && (arp_key->arp_op & htons(0xff00))) {
-			OVS_NLERR("Unknown ARP opcode (opcode=%d).\n",
-				  arp_key->arp_op);
-			return -EINVAL;
-		}
-
-		SW_FLOW_KEY_PUT(match, ipv4.addr.src,
-				arp_key->arp_sip, is_mask);
-		SW_FLOW_KEY_PUT(match, ipv4.addr.dst,
-			arp_key->arp_tip, is_mask);
-		SW_FLOW_KEY_PUT(match, ip.proto,
-				ntohs(arp_key->arp_op), is_mask);
-		SW_FLOW_KEY_MEMCPY(match, ipv4.arp.sha,
-				arp_key->arp_sha, ETH_ALEN, is_mask);
-		SW_FLOW_KEY_MEMCPY(match, ipv4.arp.tha,
-				arp_key->arp_tha, ETH_ALEN, is_mask);
-
-		attrs &= ~(1 << OVS_KEY_ATTR_ARP);
-	}
-
-	if (attrs & (1 << OVS_KEY_ATTR_TCP)) {
-		const struct ovs_key_tcp *tcp_key;
-
-		tcp_key = nla_data(a[OVS_KEY_ATTR_TCP]);
-		if (orig_attrs & (1 << OVS_KEY_ATTR_IPV4)) {
-			SW_FLOW_KEY_PUT(match, ipv4.tp.src,
-					tcp_key->tcp_src, is_mask);
-			SW_FLOW_KEY_PUT(match, ipv4.tp.dst,
-					tcp_key->tcp_dst, is_mask);
-		} else {
-			SW_FLOW_KEY_PUT(match, ipv6.tp.src,
-					tcp_key->tcp_src, is_mask);
-			SW_FLOW_KEY_PUT(match, ipv6.tp.dst,
-					tcp_key->tcp_dst, is_mask);
-		}
-		attrs &= ~(1 << OVS_KEY_ATTR_TCP);
-	}
-
-	if (attrs & (1 << OVS_KEY_ATTR_UDP)) {
-		const struct ovs_key_udp *udp_key;
-
-		udp_key = nla_data(a[OVS_KEY_ATTR_UDP]);
-		if (orig_attrs & (1 << OVS_KEY_ATTR_IPV4)) {
-			SW_FLOW_KEY_PUT(match, ipv4.tp.src,
-					udp_key->udp_src, is_mask);
-			SW_FLOW_KEY_PUT(match, ipv4.tp.dst,
-					udp_key->udp_dst, is_mask);
-		} else {
-			SW_FLOW_KEY_PUT(match, ipv6.tp.src,
-					udp_key->udp_src, is_mask);
-			SW_FLOW_KEY_PUT(match, ipv6.tp.dst,
-					udp_key->udp_dst, is_mask);
-		}
-		attrs &= ~(1 << OVS_KEY_ATTR_UDP);
-	}
-
-	if (attrs & (1 << OVS_KEY_ATTR_SCTP)) {
-		const struct ovs_key_sctp *sctp_key;
-
-		sctp_key = nla_data(a[OVS_KEY_ATTR_SCTP]);
-		if (orig_attrs & (1 << OVS_KEY_ATTR_IPV4)) {
-			SW_FLOW_KEY_PUT(match, ipv4.tp.src,
-					sctp_key->sctp_src, is_mask);
-			SW_FLOW_KEY_PUT(match, ipv4.tp.dst,
-					sctp_key->sctp_dst, is_mask);
-		} else {
-			SW_FLOW_KEY_PUT(match, ipv6.tp.src,
-					sctp_key->sctp_src, is_mask);
-			SW_FLOW_KEY_PUT(match, ipv6.tp.dst,
-					sctp_key->sctp_dst, is_mask);
-		}
-		attrs &= ~(1 << OVS_KEY_ATTR_SCTP);
-	}
-
-	if (attrs & (1 << OVS_KEY_ATTR_ICMP)) {
-		const struct ovs_key_icmp *icmp_key;
-
-		icmp_key = nla_data(a[OVS_KEY_ATTR_ICMP]);
-		SW_FLOW_KEY_PUT(match, ipv4.tp.src,
-				htons(icmp_key->icmp_type), is_mask);
-		SW_FLOW_KEY_PUT(match, ipv4.tp.dst,
-				htons(icmp_key->icmp_code), is_mask);
-		attrs &= ~(1 << OVS_KEY_ATTR_ICMP);
-	}
-
-	if (attrs & (1 << OVS_KEY_ATTR_ICMPV6)) {
-		const struct ovs_key_icmpv6 *icmpv6_key;
-
-		icmpv6_key = nla_data(a[OVS_KEY_ATTR_ICMPV6]);
-		SW_FLOW_KEY_PUT(match, ipv6.tp.src,
-				htons(icmpv6_key->icmpv6_type), is_mask);
-		SW_FLOW_KEY_PUT(match, ipv6.tp.dst,
-				htons(icmpv6_key->icmpv6_code), is_mask);
-		attrs &= ~(1 << OVS_KEY_ATTR_ICMPV6);
-	}
-
-	if (attrs & (1 << OVS_KEY_ATTR_ND)) {
-		const struct ovs_key_nd *nd_key;
-
-		nd_key = nla_data(a[OVS_KEY_ATTR_ND]);
-		SW_FLOW_KEY_MEMCPY(match, ipv6.nd.target,
-			nd_key->nd_target,
-			sizeof(match->key->ipv6.nd.target),
-			is_mask);
-		SW_FLOW_KEY_MEMCPY(match, ipv6.nd.sll,
-			nd_key->nd_sll, ETH_ALEN, is_mask);
-		SW_FLOW_KEY_MEMCPY(match, ipv6.nd.tll,
-				nd_key->nd_tll, ETH_ALEN, is_mask);
-		attrs &= ~(1 << OVS_KEY_ATTR_ND);
-	}
-
-	if (attrs != 0)
-		return -EINVAL;
-
-	return 0;
-}
-
-/**
- * ovs_match_from_nlattrs - parses Netlink attributes into a flow key and
- * mask. In case the 'mask' is NULL, the flow is treated as exact match
- * flow. Otherwise, it is treated as a wildcarded flow, except the mask
- * does not include any don't care bit.
- * @match: receives the extracted flow match information.
- * @key: Netlink attribute holding nested %OVS_KEY_ATTR_* Netlink attribute
- * sequence. The fields should of the packet that triggered the creation
- * of this flow.
- * @mask: Optional. Netlink attribute holding nested %OVS_KEY_ATTR_* Netlink
- * attribute specifies the mask field of the wildcarded flow.
- */
-int ovs_match_from_nlattrs(struct sw_flow_match *match,
-			   const struct nlattr *key,
-			   const struct nlattr *mask)
-{
-	const struct nlattr *a[OVS_KEY_ATTR_MAX + 1];
-	const struct nlattr *encap;
-	u64 key_attrs = 0;
-	u64 mask_attrs = 0;
-	bool encap_valid = false;
-	int err;
-
-	err = parse_flow_nlattrs(key, a, &key_attrs);
-	if (err)
-		return err;
-
-	if ((key_attrs & (1 << OVS_KEY_ATTR_ETHERNET)) &&
-	    (key_attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) &&
-	    (nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]) == htons(ETH_P_8021Q))) {
-		__be16 tci;
-
-		if (!((key_attrs & (1 << OVS_KEY_ATTR_VLAN)) &&
-		      (key_attrs & (1 << OVS_KEY_ATTR_ENCAP)))) {
-			OVS_NLERR("Invalid Vlan frame.\n");
-			return -EINVAL;
-		}
-
-		key_attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
-		tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
-		encap = a[OVS_KEY_ATTR_ENCAP];
-		key_attrs &= ~(1 << OVS_KEY_ATTR_ENCAP);
-		encap_valid = true;
-
-		if (tci & htons(VLAN_TAG_PRESENT)) {
-			err = parse_flow_nlattrs(encap, a, &key_attrs);
-			if (err)
-				return err;
-		} else if (!tci) {
-			/* Corner case for truncated 802.1Q header. */
-			if (nla_len(encap)) {
-				OVS_NLERR("Truncated 802.1Q header has non-zero encap attribute.\n");
-				return -EINVAL;
-			}
-		} else {
-			OVS_NLERR("Encap attribute is set for a non-VLAN frame.\n");
-			return  -EINVAL;
-		}
-	}
-
-	err = ovs_key_from_nlattrs(match, key_attrs, a, false);
-	if (err)
-		return err;
-
-	if (mask) {
-		err = parse_flow_mask_nlattrs(mask, a, &mask_attrs);
-		if (err)
-			return err;
-
-		if (mask_attrs & 1ULL << OVS_KEY_ATTR_ENCAP)  {
-			__be16 eth_type = 0;
-			__be16 tci = 0;
-
-			if (!encap_valid) {
-				OVS_NLERR("Encap mask attribute is set for non-VLAN frame.\n");
-				return  -EINVAL;
-			}
-
-			mask_attrs &= ~(1 << OVS_KEY_ATTR_ENCAP);
-			if (a[OVS_KEY_ATTR_ETHERTYPE])
-				eth_type = nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]);
-
-			if (eth_type == htons(0xffff)) {
-				mask_attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
-				encap = a[OVS_KEY_ATTR_ENCAP];
-				err = parse_flow_mask_nlattrs(encap, a, &mask_attrs);
-			} else {
-				OVS_NLERR("VLAN frames must have an exact match on the TPID (mask=%x).\n",
-						ntohs(eth_type));
-				return -EINVAL;
-			}
-
-			if (a[OVS_KEY_ATTR_VLAN])
-				tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
-
-			if (!(tci & htons(VLAN_TAG_PRESENT))) {
-				OVS_NLERR("VLAN tag present bit must have an exact match (tci_mask=%x).\n", ntohs(tci));
-				return -EINVAL;
-			}
-		}
-
-		err = ovs_key_from_nlattrs(match, mask_attrs, a, true);
-		if (err)
-			return err;
-	} else {
-		/* Populate exact match flow's key mask. */
-		if (match->mask)
-			ovs_sw_flow_mask_set(match->mask, &match->range, 0xff);
-	}
-
-	if (!ovs_match_validate(match, key_attrs, mask_attrs))
-		return -EINVAL;
-
-	return 0;
-}
-
-/**
- * ovs_flow_metadata_from_nlattrs - parses Netlink attributes into a flow key.
- * @flow: Receives extracted in_port, priority, tun_key and skb_mark.
- * @attr: Netlink attribute holding nested %OVS_KEY_ATTR_* Netlink attribute
- * sequence.
- *
- * This parses a series of Netlink attributes that form a flow key, which must
- * take the same form accepted by flow_from_nlattrs(), but only enough of it to
- * get the metadata, that is, the parts of the flow key that cannot be
- * extracted from the packet itself.
- */
-
-int ovs_flow_metadata_from_nlattrs(struct sw_flow *flow,
-		const struct nlattr *attr)
-{
-	struct ovs_key_ipv4_tunnel *tun_key = &flow->key.tun_key;
-	const struct nlattr *a[OVS_KEY_ATTR_MAX + 1];
-	u64 attrs = 0;
-	int err;
-	struct sw_flow_match match;
-
-	flow->key.phy.in_port = DP_MAX_PORTS;
-	flow->key.phy.priority = 0;
-	flow->key.phy.skb_mark = 0;
-	memset(tun_key, 0, sizeof(flow->key.tun_key));
-
-	err = parse_flow_nlattrs(attr, a, &attrs);
-	if (err)
-		return -EINVAL;
-
-	memset(&match, 0, sizeof(match));
-	match.key = &flow->key;
-
-	err = metadata_from_nlattrs(&match, &attrs, a, false);
-	if (err)
-		return err;
-
-	return 0;
-}
-
-int ovs_flow_to_nlattrs(const struct sw_flow_key *swkey,
-		const struct sw_flow_key *output, struct sk_buff *skb)
-{
-	struct ovs_key_ethernet *eth_key;
-	struct nlattr *nla, *encap;
-	bool is_mask = (swkey != output);
-
-	if (nla_put_u32(skb, OVS_KEY_ATTR_PRIORITY, output->phy.priority))
-		goto nla_put_failure;
-
-	if ((swkey->tun_key.ipv4_dst || is_mask) &&
-	    ovs_ipv4_tun_to_nlattr(skb, &swkey->tun_key, &output->tun_key))
-		goto nla_put_failure;
-
-	if (swkey->phy.in_port == DP_MAX_PORTS) {
-		if (is_mask && (output->phy.in_port == 0xffff))
-			if (nla_put_u32(skb, OVS_KEY_ATTR_IN_PORT, 0xffffffff))
-				goto nla_put_failure;
-	} else {
-		u16 upper_u16;
-		upper_u16 = !is_mask ? 0 : 0xffff;
-
-		if (nla_put_u32(skb, OVS_KEY_ATTR_IN_PORT,
-				(upper_u16 << 16) | output->phy.in_port))
-			goto nla_put_failure;
-	}
-
-	if (nla_put_u32(skb, OVS_KEY_ATTR_SKB_MARK, output->phy.skb_mark))
-		goto nla_put_failure;
-
-	nla = nla_reserve(skb, OVS_KEY_ATTR_ETHERNET, sizeof(*eth_key));
-	if (!nla)
-		goto nla_put_failure;
-
-	eth_key = nla_data(nla);
-	memcpy(eth_key->eth_src, output->eth.src, ETH_ALEN);
-	memcpy(eth_key->eth_dst, output->eth.dst, ETH_ALEN);
-
-	if (swkey->eth.tci || swkey->eth.type == htons(ETH_P_8021Q)) {
-		__be16 eth_type;
-		eth_type = !is_mask ? htons(ETH_P_8021Q) : htons(0xffff);
-		if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, eth_type) ||
-		    nla_put_be16(skb, OVS_KEY_ATTR_VLAN, output->eth.tci))
-			goto nla_put_failure;
-		encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
-		if (!swkey->eth.tci)
-			goto unencap;
-	} else
-		encap = NULL;
-
-	if (swkey->eth.type == htons(ETH_P_802_2)) {
-		/*
-		 * Ethertype 802.2 is represented in the netlink with omitted
-		 * OVS_KEY_ATTR_ETHERTYPE in the flow key attribute, and
-		 * 0xffff in the mask attribute.  Ethertype can also
-		 * be wildcarded.
-		 */
-		if (is_mask && output->eth.type)
-			if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE,
-						output->eth.type))
-				goto nla_put_failure;
-		goto unencap;
-	}
-
-	if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, output->eth.type))
-		goto nla_put_failure;
-
-	if (swkey->eth.type == htons(ETH_P_IP)) {
-		struct ovs_key_ipv4 *ipv4_key;
-
-		nla = nla_reserve(skb, OVS_KEY_ATTR_IPV4, sizeof(*ipv4_key));
-		if (!nla)
-			goto nla_put_failure;
-		ipv4_key = nla_data(nla);
-		ipv4_key->ipv4_src = output->ipv4.addr.src;
-		ipv4_key->ipv4_dst = output->ipv4.addr.dst;
-		ipv4_key->ipv4_proto = output->ip.proto;
-		ipv4_key->ipv4_tos = output->ip.tos;
-		ipv4_key->ipv4_ttl = output->ip.ttl;
-		ipv4_key->ipv4_frag = output->ip.frag;
-	} else if (swkey->eth.type == htons(ETH_P_IPV6)) {
-		struct ovs_key_ipv6 *ipv6_key;
-
-		nla = nla_reserve(skb, OVS_KEY_ATTR_IPV6, sizeof(*ipv6_key));
-		if (!nla)
-			goto nla_put_failure;
-		ipv6_key = nla_data(nla);
-		memcpy(ipv6_key->ipv6_src, &output->ipv6.addr.src,
-				sizeof(ipv6_key->ipv6_src));
-		memcpy(ipv6_key->ipv6_dst, &output->ipv6.addr.dst,
-				sizeof(ipv6_key->ipv6_dst));
-		ipv6_key->ipv6_label = output->ipv6.label;
-		ipv6_key->ipv6_proto = output->ip.proto;
-		ipv6_key->ipv6_tclass = output->ip.tos;
-		ipv6_key->ipv6_hlimit = output->ip.ttl;
-		ipv6_key->ipv6_frag = output->ip.frag;
-	} else if (swkey->eth.type == htons(ETH_P_ARP) ||
-		   swkey->eth.type == htons(ETH_P_RARP)) {
-		struct ovs_key_arp *arp_key;
-
-		nla = nla_reserve(skb, OVS_KEY_ATTR_ARP, sizeof(*arp_key));
-		if (!nla)
-			goto nla_put_failure;
-		arp_key = nla_data(nla);
-		memset(arp_key, 0, sizeof(struct ovs_key_arp));
-		arp_key->arp_sip = output->ipv4.addr.src;
-		arp_key->arp_tip = output->ipv4.addr.dst;
-		arp_key->arp_op = htons(output->ip.proto);
-		memcpy(arp_key->arp_sha, output->ipv4.arp.sha, ETH_ALEN);
-		memcpy(arp_key->arp_tha, output->ipv4.arp.tha, ETH_ALEN);
-	}
-
-	if ((swkey->eth.type == htons(ETH_P_IP) ||
-	     swkey->eth.type == htons(ETH_P_IPV6)) &&
-	     swkey->ip.frag != OVS_FRAG_TYPE_LATER) {
-
-		if (swkey->ip.proto == IPPROTO_TCP) {
-			struct ovs_key_tcp *tcp_key;
-
-			nla = nla_reserve(skb, OVS_KEY_ATTR_TCP, sizeof(*tcp_key));
-			if (!nla)
-				goto nla_put_failure;
-			tcp_key = nla_data(nla);
-			if (swkey->eth.type == htons(ETH_P_IP)) {
-				tcp_key->tcp_src = output->ipv4.tp.src;
-				tcp_key->tcp_dst = output->ipv4.tp.dst;
-			} else if (swkey->eth.type == htons(ETH_P_IPV6)) {
-				tcp_key->tcp_src = output->ipv6.tp.src;
-				tcp_key->tcp_dst = output->ipv6.tp.dst;
-			}
-		} else if (swkey->ip.proto == IPPROTO_UDP) {
-			struct ovs_key_udp *udp_key;
-
-			nla = nla_reserve(skb, OVS_KEY_ATTR_UDP, sizeof(*udp_key));
-			if (!nla)
-				goto nla_put_failure;
-			udp_key = nla_data(nla);
-			if (swkey->eth.type == htons(ETH_P_IP)) {
-				udp_key->udp_src = output->ipv4.tp.src;
-				udp_key->udp_dst = output->ipv4.tp.dst;
-			} else if (swkey->eth.type == htons(ETH_P_IPV6)) {
-				udp_key->udp_src = output->ipv6.tp.src;
-				udp_key->udp_dst = output->ipv6.tp.dst;
-			}
-		} else if (swkey->ip.proto == IPPROTO_SCTP) {
-			struct ovs_key_sctp *sctp_key;
-
-			nla = nla_reserve(skb, OVS_KEY_ATTR_SCTP, sizeof(*sctp_key));
-			if (!nla)
-				goto nla_put_failure;
-			sctp_key = nla_data(nla);
-			if (swkey->eth.type == htons(ETH_P_IP)) {
-				sctp_key->sctp_src = swkey->ipv4.tp.src;
-				sctp_key->sctp_dst = swkey->ipv4.tp.dst;
-			} else if (swkey->eth.type == htons(ETH_P_IPV6)) {
-				sctp_key->sctp_src = swkey->ipv6.tp.src;
-				sctp_key->sctp_dst = swkey->ipv6.tp.dst;
-			}
-		} else if (swkey->eth.type == htons(ETH_P_IP) &&
-			   swkey->ip.proto == IPPROTO_ICMP) {
-			struct ovs_key_icmp *icmp_key;
-
-			nla = nla_reserve(skb, OVS_KEY_ATTR_ICMP, sizeof(*icmp_key));
-			if (!nla)
-				goto nla_put_failure;
-			icmp_key = nla_data(nla);
-			icmp_key->icmp_type = ntohs(output->ipv4.tp.src);
-			icmp_key->icmp_code = ntohs(output->ipv4.tp.dst);
-		} else if (swkey->eth.type == htons(ETH_P_IPV6) &&
-			   swkey->ip.proto == IPPROTO_ICMPV6) {
-			struct ovs_key_icmpv6 *icmpv6_key;
-
-			nla = nla_reserve(skb, OVS_KEY_ATTR_ICMPV6,
-						sizeof(*icmpv6_key));
-			if (!nla)
-				goto nla_put_failure;
-			icmpv6_key = nla_data(nla);
-			icmpv6_key->icmpv6_type = ntohs(output->ipv6.tp.src);
-			icmpv6_key->icmpv6_code = ntohs(output->ipv6.tp.dst);
-
-			if (icmpv6_key->icmpv6_type == NDISC_NEIGHBOUR_SOLICITATION ||
-			    icmpv6_key->icmpv6_type == NDISC_NEIGHBOUR_ADVERTISEMENT) {
-				struct ovs_key_nd *nd_key;
-
-				nla = nla_reserve(skb, OVS_KEY_ATTR_ND, sizeof(*nd_key));
-				if (!nla)
-					goto nla_put_failure;
-				nd_key = nla_data(nla);
-				memcpy(nd_key->nd_target, &output->ipv6.nd.target,
-							sizeof(nd_key->nd_target));
-				memcpy(nd_key->nd_sll, output->ipv6.nd.sll, ETH_ALEN);
-				memcpy(nd_key->nd_tll, output->ipv6.nd.tll, ETH_ALEN);
-			}
-		}
-	}
-
-unencap:
-	if (encap)
-		nla_nest_end(skb, encap);
-
-	return 0;
-
-nla_put_failure:
-	return -EMSGSIZE;
-}
-
-/* Initializes the flow module.
- * Returns zero if successful or a negative error code. */
-int ovs_flow_init(void)
-{
-	BUILD_BUG_ON(__alignof__(struct sw_flow_key) % __alignof__(long));
-	BUILD_BUG_ON(sizeof(struct sw_flow_key) % sizeof(long));
-
-	flow_cache = kmem_cache_create("sw_flow", sizeof(struct sw_flow), 0,
-					0, NULL);
-	if (flow_cache == NULL)
-		return -ENOMEM;
-
-	return 0;
-}
-
-/* Uninitializes the flow module. */
-void ovs_flow_exit(void)
-{
-	kmem_cache_destroy(flow_cache);
-}
-
-struct sw_flow_mask *ovs_sw_flow_mask_alloc(void)
-{
-	struct sw_flow_mask *mask;
-
-	mask = kmalloc(sizeof(*mask), GFP_KERNEL);
-	if (mask)
-		mask->ref_count = 0;
-
-	return mask;
-}
-
-void ovs_sw_flow_mask_add_ref(struct sw_flow_mask *mask)
-{
-	mask->ref_count++;
-}
-
-void ovs_sw_flow_mask_del_ref(struct sw_flow_mask *mask, bool deferred)
-{
-	if (!mask)
-		return;
-
-	BUG_ON(!mask->ref_count);
-	mask->ref_count--;
-
-	if (!mask->ref_count) {
-		list_del_rcu(&mask->list);
-		if (deferred)
-			kfree_rcu(mask, rcu);
-		else
-			kfree(mask);
-	}
-}
-
-static bool ovs_sw_flow_mask_equal(const struct sw_flow_mask *a,
-		const struct sw_flow_mask *b)
-{
-	u8 *a_ = (u8 *)&a->key + a->range.start;
-	u8 *b_ = (u8 *)&b->key + b->range.start;
-
-	return  (a->range.end == b->range.end)
-		&& (a->range.start == b->range.start)
-		&& (memcmp(a_, b_, range_n_bytes(&a->range)) == 0);
-}
-
-struct sw_flow_mask *ovs_sw_flow_mask_find(const struct flow_table *tbl,
-                                           const struct sw_flow_mask *mask)
-{
-	struct list_head *ml;
-
-	list_for_each(ml, tbl->mask_list) {
-		struct sw_flow_mask *m;
-		m = container_of(ml, struct sw_flow_mask, list);
-		if (ovs_sw_flow_mask_equal(mask, m))
-			return m;
-	}
-
-	return NULL;
-}
-
-/**
- * add a new mask into the mask list.
- * The caller needs to make sure that 'mask' is not the same
- * as any masks that are already on the list.
- */
-void ovs_sw_flow_mask_insert(struct flow_table *tbl, struct sw_flow_mask *mask)
-{
-	list_add_rcu(&mask->list, tbl->mask_list);
-}
-
-/**
- * Set 'range' fields in the mask to the value of 'val'.
- */
-static void ovs_sw_flow_mask_set(struct sw_flow_mask *mask,
-		struct sw_flow_key_range *range, u8 val)
-{
-	u8 *m = (u8 *)&mask->key + range->start;
-
-	mask->range = *range;
-	memset(m, val, range_n_bytes(range));
-}
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 212fbf7..098fd1d 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -33,14 +33,6 @@
 #include <net/inet_ecn.h>
 
 struct sk_buff;
-struct sw_flow_mask;
-struct flow_table;
-
-struct sw_flow_actions {
-	struct rcu_head rcu;
-	u32 actions_len;
-	struct nlattr actions[];
-};
 
 /* Used to memset ovs_key_ipv4_tunnel padding. */
 #define OVS_TUNNEL_KEY_SIZE					\
@@ -127,6 +119,31 @@ struct sw_flow_key {
 	};
 } __aligned(BITS_PER_LONG/8); /* Ensure that we can do comparisons as longs. */
 
+struct sw_flow_key_range {
+	size_t start;
+	size_t end;
+};
+
+struct sw_flow_mask {
+	int ref_count;
+	struct rcu_head rcu;
+	struct list_head list;
+	struct sw_flow_key_range range;
+	struct sw_flow_key key;
+};
+
+struct sw_flow_match {
+	struct sw_flow_key *key;
+	struct sw_flow_key_range range;
+	struct sw_flow_mask *mask;
+};
+
+struct sw_flow_actions {
+	struct rcu_head rcu;
+	u32 actions_len;
+	struct nlattr actions[];
+};
+
 struct sw_flow {
 	struct rcu_head rcu;
 	struct hlist_node hash_node[2];
@@ -144,20 +161,6 @@ struct sw_flow {
 	u8 tcp_flags;		/* Union of seen TCP flags. */
 };
 
-struct sw_flow_key_range {
-	size_t start;
-	size_t end;
-};
-
-struct sw_flow_match {
-	struct sw_flow_key *key;
-	struct sw_flow_key_range range;
-	struct sw_flow_mask *mask;
-};
-
-void ovs_match_init(struct sw_flow_match *match,
-		struct sw_flow_key *key, struct sw_flow_mask *mask);
-
 struct arp_eth_header {
 	__be16      ar_hrd;	/* format of hardware address   */
 	__be16      ar_pro;	/* format of protocol address   */
@@ -172,88 +175,9 @@ struct arp_eth_header {
 	unsigned char       ar_tip[4];		/* target IP address        */
 } __packed;
 
-int ovs_flow_init(void);
-void ovs_flow_exit(void);
-
-struct sw_flow *ovs_flow_alloc(void);
-void ovs_flow_deferred_free(struct sw_flow *);
-void ovs_flow_free(struct sw_flow *, bool deferred);
-
-struct sw_flow_actions *ovs_flow_actions_alloc(int actions_len);
-void ovs_flow_deferred_free_acts(struct sw_flow_actions *);
-
-int ovs_flow_extract(struct sk_buff *, u16 in_port, struct sw_flow_key *);
 void ovs_flow_used(struct sw_flow *, struct sk_buff *);
 u64 ovs_flow_used_time(unsigned long flow_jiffies);
-int ovs_flow_to_nlattrs(const struct sw_flow_key *,
-		const struct sw_flow_key *, struct sk_buff *);
-int ovs_match_from_nlattrs(struct sw_flow_match *match,
-		      const struct nlattr *,
-		      const struct nlattr *);
-int ovs_flow_metadata_from_nlattrs(struct sw_flow *flow,
-		const struct nlattr *attr);
 
-#define MAX_ACTIONS_BUFSIZE    (32 * 1024)
-#define TBL_MIN_BUCKETS		1024
-
-struct flow_table {
-	struct flex_array *buckets;
-	unsigned int count, n_buckets;
-	struct rcu_head rcu;
-	struct list_head *mask_list;
-	int node_ver;
-	u32 hash_seed;
-	bool keep_flows;
-};
-
-static inline int ovs_flow_tbl_count(struct flow_table *table)
-{
-	return table->count;
-}
-
-static inline int ovs_flow_tbl_need_to_expand(struct flow_table *table)
-{
-	return (table->count > table->n_buckets);
-}
-
-struct sw_flow *ovs_flow_lookup(struct flow_table *,
-				const struct sw_flow_key *);
-struct sw_flow *ovs_flow_lookup_unmasked_key(struct flow_table *table,
-				    struct sw_flow_match *match);
-
-void ovs_flow_tbl_destroy(struct flow_table *table, bool deferred);
-struct flow_table *ovs_flow_tbl_alloc(int new_size);
-struct flow_table *ovs_flow_tbl_expand(struct flow_table *table);
-struct flow_table *ovs_flow_tbl_rehash(struct flow_table *table);
-
-void ovs_flow_insert(struct flow_table *table, struct sw_flow *flow);
-void ovs_flow_remove(struct flow_table *table, struct sw_flow *flow);
-
-struct sw_flow *ovs_flow_dump_next(struct flow_table *table, u32 *bucket, u32 *idx);
-extern const int ovs_key_lens[OVS_KEY_ATTR_MAX + 1];
-int ovs_ipv4_tun_from_nlattr(const struct nlattr *attr,
-			     struct sw_flow_match *match, bool is_mask);
-int ovs_ipv4_tun_to_nlattr(struct sk_buff *skb,
-			   const struct ovs_key_ipv4_tunnel *tun_key,
-			   const struct ovs_key_ipv4_tunnel *output);
-
-bool ovs_flow_cmp_unmasked_key(const struct sw_flow *flow,
-		const struct sw_flow_key *key, int key_end);
-
-struct sw_flow_mask {
-	int ref_count;
-	struct rcu_head rcu;
-	struct list_head list;
-	struct sw_flow_key_range range;
-	struct sw_flow_key key;
-};
+int ovs_flow_extract(struct sk_buff *, u16 in_port, struct sw_flow_key *);
 
-struct sw_flow_mask *ovs_sw_flow_mask_alloc(void);
-void ovs_sw_flow_mask_add_ref(struct sw_flow_mask *);
-void ovs_sw_flow_mask_del_ref(struct sw_flow_mask *, bool deferred);
-void ovs_sw_flow_mask_insert(struct flow_table *, struct sw_flow_mask *);
-struct sw_flow_mask *ovs_sw_flow_mask_find(const struct flow_table *,
-		const struct sw_flow_mask *);
-void ovs_flow_key_mask(struct sw_flow_key *dst, const struct sw_flow_key *src,
-		       const struct sw_flow_mask *mask);
 #endif /* flow.h */
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
new file mode 100644
index 0000000..e04649c
--- /dev/null
+++ b/net/openvswitch/flow_netlink.c
@@ -0,0 +1,1603 @@
+/*
+ * Copyright (c) 2007-2013 Nicira, Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+
+#include "flow.h"
+#include "datapath.h"
+#include <linux/uaccess.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/if_ether.h>
+#include <linux/if_vlan.h>
+#include <net/llc_pdu.h>
+#include <linux/kernel.h>
+#include <linux/jhash.h>
+#include <linux/jiffies.h>
+#include <linux/llc.h>
+#include <linux/module.h>
+#include <linux/in.h>
+#include <linux/rcupdate.h>
+#include <linux/if_arp.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/sctp.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
+#include <linux/icmp.h>
+#include <linux/icmpv6.h>
+#include <linux/rculist.h>
+#include <net/ip.h>
+#include <net/ipv6.h>
+#include <net/ndisc.h>
+
+#include "flow_netlink.h"
+
+static void update_range__(struct sw_flow_match *match,
+			   size_t offset, size_t size, bool is_mask)
+{
+	struct sw_flow_key_range *range = NULL;
+	size_t start = rounddown(offset, sizeof(long));
+	size_t end = roundup(offset + size, sizeof(long));
+
+	if (!is_mask)
+		range = &match->range;
+	else if (match->mask)
+		range = &match->mask->range;
+
+	if (!range)
+		return;
+
+	if (range->start == range->end) {
+		range->start = start;
+		range->end = end;
+		return;
+	}
+
+	if (range->start > start)
+		range->start = start;
+
+	if (range->end < end)
+		range->end = end;
+}
+
+#define SW_FLOW_KEY_PUT(match, field, value, is_mask) \
+	do { \
+		update_range__(match, offsetof(struct sw_flow_key, field),  \
+				     sizeof((match)->key->field), is_mask); \
+		if (is_mask) {						    \
+			if ((match)->mask)				    \
+				(match)->mask->key.field = value;	    \
+		} else {                                                    \
+			(match)->key->field = value;		            \
+		}                                                           \
+	} while (0)
+
+#define SW_FLOW_KEY_MEMCPY(match, field, value_p, len, is_mask) \
+	do { \
+		update_range__(match, offsetof(struct sw_flow_key, field),  \
+				len, is_mask);                              \
+		if (is_mask) {						    \
+			if ((match)->mask)				    \
+				memcpy(&(match)->mask->key.field, value_p, len);\
+		} else {                                                    \
+			memcpy(&(match)->key->field, value_p, len);         \
+		}                                                           \
+	} while (0)
+
+static u16 range_n_bytes(const struct sw_flow_key_range *range)
+{
+	return range->end - range->start;
+}
+
+static bool match_validate(const struct sw_flow_match *match,
+			   u64 key_attrs, u64 mask_attrs)
+{
+	u64 key_expected = 1 << OVS_KEY_ATTR_ETHERNET;
+	u64 mask_allowed = key_attrs;  /* At most allow all key attributes */
+
+	/* The following mask attributes allowed only if they
+	 * pass the validation tests. */
+	mask_allowed &= ~((1 << OVS_KEY_ATTR_IPV4)
+			| (1 << OVS_KEY_ATTR_IPV6)
+			| (1 << OVS_KEY_ATTR_TCP)
+			| (1 << OVS_KEY_ATTR_UDP)
+			| (1 << OVS_KEY_ATTR_SCTP)
+			| (1 << OVS_KEY_ATTR_ICMP)
+			| (1 << OVS_KEY_ATTR_ICMPV6)
+			| (1 << OVS_KEY_ATTR_ARP)
+			| (1 << OVS_KEY_ATTR_ND));
+
+	/* Always allowed mask fields. */
+	mask_allowed |= ((1 << OVS_KEY_ATTR_TUNNEL)
+		       | (1 << OVS_KEY_ATTR_IN_PORT)
+		       | (1 << OVS_KEY_ATTR_ETHERTYPE));
+
+	/* Check key attributes. */
+	if (match->key->eth.type == htons(ETH_P_ARP)
+			|| match->key->eth.type == htons(ETH_P_RARP)) {
+		key_expected |= 1 << OVS_KEY_ATTR_ARP;
+		if (match->mask && (match->mask->key.eth.type == htons(0xffff)))
+			mask_allowed |= 1 << OVS_KEY_ATTR_ARP;
+	}
+
+	if (match->key->eth.type == htons(ETH_P_IP)) {
+		key_expected |= 1 << OVS_KEY_ATTR_IPV4;
+		if (match->mask && (match->mask->key.eth.type == htons(0xffff)))
+			mask_allowed |= 1 << OVS_KEY_ATTR_IPV4;
+
+		if (match->key->ip.frag != OVS_FRAG_TYPE_LATER) {
+			if (match->key->ip.proto == IPPROTO_UDP) {
+				key_expected |= 1 << OVS_KEY_ATTR_UDP;
+				if (match->mask && (match->mask->key.ip.proto == 0xff))
+					mask_allowed |= 1 << OVS_KEY_ATTR_UDP;
+			}
+
+			if (match->key->ip.proto == IPPROTO_SCTP) {
+				key_expected |= 1 << OVS_KEY_ATTR_SCTP;
+				if (match->mask && (match->mask->key.ip.proto == 0xff))
+					mask_allowed |= 1 << OVS_KEY_ATTR_SCTP;
+			}
+
+			if (match->key->ip.proto == IPPROTO_TCP) {
+				key_expected |= 1 << OVS_KEY_ATTR_TCP;
+				if (match->mask && (match->mask->key.ip.proto == 0xff))
+					mask_allowed |= 1 << OVS_KEY_ATTR_TCP;
+			}
+
+			if (match->key->ip.proto == IPPROTO_ICMP) {
+				key_expected |= 1 << OVS_KEY_ATTR_ICMP;
+				if (match->mask && (match->mask->key.ip.proto == 0xff))
+					mask_allowed |= 1 << OVS_KEY_ATTR_ICMP;
+			}
+		}
+	}
+
+	if (match->key->eth.type == htons(ETH_P_IPV6)) {
+		key_expected |= 1 << OVS_KEY_ATTR_IPV6;
+		if (match->mask && (match->mask->key.eth.type == htons(0xffff)))
+			mask_allowed |= 1 << OVS_KEY_ATTR_IPV6;
+
+		if (match->key->ip.frag != OVS_FRAG_TYPE_LATER) {
+			if (match->key->ip.proto == IPPROTO_UDP) {
+				key_expected |= 1 << OVS_KEY_ATTR_UDP;
+				if (match->mask && (match->mask->key.ip.proto == 0xff))
+					mask_allowed |= 1 << OVS_KEY_ATTR_UDP;
+			}
+
+			if (match->key->ip.proto == IPPROTO_SCTP) {
+				key_expected |= 1 << OVS_KEY_ATTR_SCTP;
+				if (match->mask && (match->mask->key.ip.proto == 0xff))
+					mask_allowed |= 1 << OVS_KEY_ATTR_SCTP;
+			}
+
+			if (match->key->ip.proto == IPPROTO_TCP) {
+				key_expected |= 1 << OVS_KEY_ATTR_TCP;
+				if (match->mask && (match->mask->key.ip.proto == 0xff))
+					mask_allowed |= 1 << OVS_KEY_ATTR_TCP;
+			}
+
+			if (match->key->ip.proto == IPPROTO_ICMPV6) {
+				key_expected |= 1 << OVS_KEY_ATTR_ICMPV6;
+				if (match->mask && (match->mask->key.ip.proto == 0xff))
+					mask_allowed |= 1 << OVS_KEY_ATTR_ICMPV6;
+
+				if (match->key->ipv6.tp.src ==
+						htons(NDISC_NEIGHBOUR_SOLICITATION) ||
+				    match->key->ipv6.tp.src == htons(NDISC_NEIGHBOUR_ADVERTISEMENT)) {
+					key_expected |= 1 << OVS_KEY_ATTR_ND;
+					if (match->mask && (match->mask->key.ipv6.tp.src == htons(0xffff)))
+						mask_allowed |= 1 << OVS_KEY_ATTR_ND;
+				}
+			}
+		}
+	}
+
+	if ((key_attrs & key_expected) != key_expected) {
+		/* Key attributes check failed. */
+		OVS_NLERR("Missing expected key attributes (key_attrs=%llx, expected=%llx).\n",
+				key_attrs, key_expected);
+		return false;
+	}
+
+	if ((mask_attrs & mask_allowed) != mask_attrs) {
+		/* Mask attributes check failed. */
+		OVS_NLERR("Contain more than allowed mask fields (mask_attrs=%llx, mask_allowed=%llx).\n",
+				mask_attrs, mask_allowed);
+		return false;
+	}
+
+	return true;
+}
+
+/* The size of the argument for each %OVS_KEY_ATTR_* Netlink attribute.  */
+static const int ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
+	[OVS_KEY_ATTR_ENCAP] = -1,
+	[OVS_KEY_ATTR_PRIORITY] = sizeof(u32),
+	[OVS_KEY_ATTR_IN_PORT] = sizeof(u32),
+	[OVS_KEY_ATTR_SKB_MARK] = sizeof(u32),
+	[OVS_KEY_ATTR_ETHERNET] = sizeof(struct ovs_key_ethernet),
+	[OVS_KEY_ATTR_VLAN] = sizeof(__be16),
+	[OVS_KEY_ATTR_ETHERTYPE] = sizeof(__be16),
+	[OVS_KEY_ATTR_IPV4] = sizeof(struct ovs_key_ipv4),
+	[OVS_KEY_ATTR_IPV6] = sizeof(struct ovs_key_ipv6),
+	[OVS_KEY_ATTR_TCP] = sizeof(struct ovs_key_tcp),
+	[OVS_KEY_ATTR_UDP] = sizeof(struct ovs_key_udp),
+	[OVS_KEY_ATTR_SCTP] = sizeof(struct ovs_key_sctp),
+	[OVS_KEY_ATTR_ICMP] = sizeof(struct ovs_key_icmp),
+	[OVS_KEY_ATTR_ICMPV6] = sizeof(struct ovs_key_icmpv6),
+	[OVS_KEY_ATTR_ARP] = sizeof(struct ovs_key_arp),
+	[OVS_KEY_ATTR_ND] = sizeof(struct ovs_key_nd),
+	[OVS_KEY_ATTR_TUNNEL] = -1,
+};
+
+static bool is_all_zero(const u8 *fp, size_t size)
+{
+	int i;
+
+	if (!fp)
+		return false;
+
+	for (i = 0; i < size; i++)
+		if (fp[i])
+			return false;
+
+	return true;
+}
+
+static int __parse_flow_nlattrs(const struct nlattr *attr,
+				const struct nlattr *a[],
+				u64 *attrsp, bool nz)
+{
+	const struct nlattr *nla;
+	u64 attrs;
+	int rem;
+
+	attrs = *attrsp;
+	nla_for_each_nested(nla, attr, rem) {
+		u16 type = nla_type(nla);
+		int expected_len;
+
+		if (type > OVS_KEY_ATTR_MAX) {
+			OVS_NLERR("Unknown key attribute (type=%d, max=%d).\n",
+				  type, OVS_KEY_ATTR_MAX);
+			return -EINVAL;
+		}
+
+		if (attrs & (1 << type)) {
+			OVS_NLERR("Duplicate key attribute (type %d).\n", type);
+			return -EINVAL;
+		}
+
+		expected_len = ovs_key_lens[type];
+		if (nla_len(nla) != expected_len && expected_len != -1) {
+			OVS_NLERR("Key attribute has unexpected length (type=%d"
+				  ", length=%d, expected=%d).\n", type,
+				  nla_len(nla), expected_len);
+			return -EINVAL;
+		}
+
+		if (!nz || !is_all_zero(nla_data(nla), expected_len)) {
+			attrs |= 1 << type;
+			a[type] = nla;
+		}
+	}
+	if (rem) {
+		OVS_NLERR("Message has %d unknown bytes.\n", rem);
+		return -EINVAL;
+	}
+
+	*attrsp = attrs;
+	return 0;
+}
+
+static int parse_flow_mask_nlattrs(const struct nlattr *attr,
+				   const struct nlattr *a[], u64 *attrsp)
+{
+	return __parse_flow_nlattrs(attr, a, attrsp, true);
+}
+
+static int parse_flow_nlattrs(const struct nlattr *attr,
+			      const struct nlattr *a[], u64 *attrsp)
+{
+	return __parse_flow_nlattrs(attr, a, attrsp, false);
+}
+
+static int ipv4_tun_from_nlattr(const struct nlattr *attr,
+				struct sw_flow_match *match, bool is_mask)
+{
+	struct nlattr *a;
+	int rem;
+	bool ttl = false;
+	__be16 tun_flags = 0;
+
+	nla_for_each_nested(a, attr, rem) {
+		int type = nla_type(a);
+		static const u32 ovs_tunnel_key_lens[OVS_TUNNEL_KEY_ATTR_MAX + 1] = {
+			[OVS_TUNNEL_KEY_ATTR_ID] = sizeof(u64),
+			[OVS_TUNNEL_KEY_ATTR_IPV4_SRC] = sizeof(u32),
+			[OVS_TUNNEL_KEY_ATTR_IPV4_DST] = sizeof(u32),
+			[OVS_TUNNEL_KEY_ATTR_TOS] = 1,
+			[OVS_TUNNEL_KEY_ATTR_TTL] = 1,
+			[OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT] = 0,
+			[OVS_TUNNEL_KEY_ATTR_CSUM] = 0,
+		};
+
+		if (type > OVS_TUNNEL_KEY_ATTR_MAX) {
+			OVS_NLERR("Unknown IPv4 tunnel attribute (type=%d, max=%d).\n",
+			type, OVS_TUNNEL_KEY_ATTR_MAX);
+			return -EINVAL;
+		}
+
+		if (ovs_tunnel_key_lens[type] != nla_len(a)) {
+			OVS_NLERR("IPv4 tunnel attribute type has unexpected "
+				  " length (type=%d, length=%d, expected=%d).\n",
+				  type, nla_len(a), ovs_tunnel_key_lens[type]);
+			return -EINVAL;
+		}
+
+		switch (type) {
+		case OVS_TUNNEL_KEY_ATTR_ID:
+			SW_FLOW_KEY_PUT(match, tun_key.tun_id,
+					nla_get_be64(a), is_mask);
+			tun_flags |= TUNNEL_KEY;
+			break;
+		case OVS_TUNNEL_KEY_ATTR_IPV4_SRC:
+			SW_FLOW_KEY_PUT(match, tun_key.ipv4_src,
+					nla_get_be32(a), is_mask);
+			break;
+		case OVS_TUNNEL_KEY_ATTR_IPV4_DST:
+			SW_FLOW_KEY_PUT(match, tun_key.ipv4_dst,
+					nla_get_be32(a), is_mask);
+			break;
+		case OVS_TUNNEL_KEY_ATTR_TOS:
+			SW_FLOW_KEY_PUT(match, tun_key.ipv4_tos,
+					nla_get_u8(a), is_mask);
+			break;
+		case OVS_TUNNEL_KEY_ATTR_TTL:
+			SW_FLOW_KEY_PUT(match, tun_key.ipv4_ttl,
+					nla_get_u8(a), is_mask);
+			ttl = true;
+			break;
+		case OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT:
+			tun_flags |= TUNNEL_DONT_FRAGMENT;
+			break;
+		case OVS_TUNNEL_KEY_ATTR_CSUM:
+			tun_flags |= TUNNEL_CSUM;
+			break;
+		default:
+			return -EINVAL;
+		}
+	}
+
+	SW_FLOW_KEY_PUT(match, tun_key.tun_flags, tun_flags, is_mask);
+
+	if (rem > 0) {
+		OVS_NLERR("IPv4 tunnel attribute has %d unknown bytes.\n", rem);
+		return -EINVAL;
+	}
+
+	if (!is_mask) {
+		if (!match->key->tun_key.ipv4_dst) {
+			OVS_NLERR("IPv4 tunnel destination address is zero.\n");
+			return -EINVAL;
+		}
+
+		if (!ttl) {
+			OVS_NLERR("IPv4 tunnel TTL not specified.\n");
+			return -EINVAL;
+		}
+	}
+
+	return 0;
+}
+
+static int ipv4_tun_to_nlattr(struct sk_buff *skb,
+			      const struct ovs_key_ipv4_tunnel *tun_key,
+			      const struct ovs_key_ipv4_tunnel *output)
+{
+	struct nlattr *nla;
+
+	nla = nla_nest_start(skb, OVS_KEY_ATTR_TUNNEL);
+	if (!nla)
+		return -EMSGSIZE;
+
+	if (output->tun_flags & TUNNEL_KEY &&
+	    nla_put_be64(skb, OVS_TUNNEL_KEY_ATTR_ID, output->tun_id))
+		return -EMSGSIZE;
+	if (output->ipv4_src &&
+		nla_put_be32(skb, OVS_TUNNEL_KEY_ATTR_IPV4_SRC, output->ipv4_src))
+		return -EMSGSIZE;
+	if (output->ipv4_dst &&
+		nla_put_be32(skb, OVS_TUNNEL_KEY_ATTR_IPV4_DST, output->ipv4_dst))
+		return -EMSGSIZE;
+	if (output->ipv4_tos &&
+		nla_put_u8(skb, OVS_TUNNEL_KEY_ATTR_TOS, output->ipv4_tos))
+		return -EMSGSIZE;
+	if (nla_put_u8(skb, OVS_TUNNEL_KEY_ATTR_TTL, output->ipv4_ttl))
+		return -EMSGSIZE;
+	if ((output->tun_flags & TUNNEL_DONT_FRAGMENT) &&
+		nla_put_flag(skb, OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT))
+		return -EMSGSIZE;
+	if ((output->tun_flags & TUNNEL_CSUM) &&
+		nla_put_flag(skb, OVS_TUNNEL_KEY_ATTR_CSUM))
+		return -EMSGSIZE;
+
+	nla_nest_end(skb, nla);
+	return 0;
+}
+
+
+static int metadata_from_nlattrs(struct sw_flow_match *match,  u64 *attrs,
+				 const struct nlattr **a, bool is_mask)
+{
+	if (*attrs & (1 << OVS_KEY_ATTR_PRIORITY)) {
+		SW_FLOW_KEY_PUT(match, phy.priority,
+			  nla_get_u32(a[OVS_KEY_ATTR_PRIORITY]), is_mask);
+		*attrs &= ~(1 << OVS_KEY_ATTR_PRIORITY);
+	}
+
+	if (*attrs & (1 << OVS_KEY_ATTR_IN_PORT)) {
+		u32 in_port = nla_get_u32(a[OVS_KEY_ATTR_IN_PORT]);
+
+		if (is_mask)
+			in_port = 0xffffffff; /* Always exact match in_port. */
+		else if (in_port >= DP_MAX_PORTS)
+			return -EINVAL;
+
+		SW_FLOW_KEY_PUT(match, phy.in_port, in_port, is_mask);
+		*attrs &= ~(1 << OVS_KEY_ATTR_IN_PORT);
+	} else if (!is_mask) {
+		SW_FLOW_KEY_PUT(match, phy.in_port, DP_MAX_PORTS, is_mask);
+	}
+
+	if (*attrs & (1 << OVS_KEY_ATTR_SKB_MARK)) {
+		uint32_t mark = nla_get_u32(a[OVS_KEY_ATTR_SKB_MARK]);
+
+		SW_FLOW_KEY_PUT(match, phy.skb_mark, mark, is_mask);
+		*attrs &= ~(1 << OVS_KEY_ATTR_SKB_MARK);
+	}
+	if (*attrs & (1 << OVS_KEY_ATTR_TUNNEL)) {
+		if (ipv4_tun_from_nlattr(a[OVS_KEY_ATTR_TUNNEL], match,
+					 is_mask))
+			return -EINVAL;
+		*attrs &= ~(1 << OVS_KEY_ATTR_TUNNEL);
+	}
+	return 0;
+}
+
+static int ovs_key_from_nlattrs(struct sw_flow_match *match,  u64 attrs,
+				const struct nlattr **a, bool is_mask)
+{
+	int err;
+	u64 orig_attrs = attrs;
+
+	err = metadata_from_nlattrs(match, &attrs, a, is_mask);
+	if (err)
+		return err;
+
+	if (attrs & (1 << OVS_KEY_ATTR_ETHERNET)) {
+		const struct ovs_key_ethernet *eth_key;
+
+		eth_key = nla_data(a[OVS_KEY_ATTR_ETHERNET]);
+		SW_FLOW_KEY_MEMCPY(match, eth.src,
+				eth_key->eth_src, ETH_ALEN, is_mask);
+		SW_FLOW_KEY_MEMCPY(match, eth.dst,
+				eth_key->eth_dst, ETH_ALEN, is_mask);
+		attrs &= ~(1 << OVS_KEY_ATTR_ETHERNET);
+	}
+
+	if (attrs & (1 << OVS_KEY_ATTR_VLAN)) {
+		__be16 tci;
+
+		tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
+		if (!(tci & htons(VLAN_TAG_PRESENT))) {
+			if (is_mask)
+				OVS_NLERR("VLAN TCI mask does not have exact match for VLAN_TAG_PRESENT bit.\n");
+			else
+				OVS_NLERR("VLAN TCI does not have VLAN_TAG_PRESENT bit set.\n");
+
+			return -EINVAL;
+		}
+
+		SW_FLOW_KEY_PUT(match, eth.tci, tci, is_mask);
+		attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
+	} else if (!is_mask)
+		SW_FLOW_KEY_PUT(match, eth.tci, htons(0xffff), true);
+
+	if (attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) {
+		__be16 eth_type;
+
+		eth_type = nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]);
+		if (is_mask) {
+			/* Always exact match EtherType. */
+			eth_type = htons(0xffff);
+		} else if (ntohs(eth_type) < ETH_P_802_3_MIN) {
+			OVS_NLERR("EtherType is less than minimum (type=%x, min=%x).\n",
+					ntohs(eth_type), ETH_P_802_3_MIN);
+			return -EINVAL;
+		}
+
+		SW_FLOW_KEY_PUT(match, eth.type, eth_type, is_mask);
+		attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
+	} else if (!is_mask) {
+		SW_FLOW_KEY_PUT(match, eth.type, htons(ETH_P_802_2), is_mask);
+	}
+
+	if (attrs & (1 << OVS_KEY_ATTR_IPV4)) {
+		const struct ovs_key_ipv4 *ipv4_key;
+
+		ipv4_key = nla_data(a[OVS_KEY_ATTR_IPV4]);
+		if (!is_mask && ipv4_key->ipv4_frag > OVS_FRAG_TYPE_MAX) {
+			OVS_NLERR("Unknown IPv4 fragment type (value=%d, max=%d).\n",
+				ipv4_key->ipv4_frag, OVS_FRAG_TYPE_MAX);
+			return -EINVAL;
+		}
+		SW_FLOW_KEY_PUT(match, ip.proto,
+				ipv4_key->ipv4_proto, is_mask);
+		SW_FLOW_KEY_PUT(match, ip.tos,
+				ipv4_key->ipv4_tos, is_mask);
+		SW_FLOW_KEY_PUT(match, ip.ttl,
+				ipv4_key->ipv4_ttl, is_mask);
+		SW_FLOW_KEY_PUT(match, ip.frag,
+				ipv4_key->ipv4_frag, is_mask);
+		SW_FLOW_KEY_PUT(match, ipv4.addr.src,
+				ipv4_key->ipv4_src, is_mask);
+		SW_FLOW_KEY_PUT(match, ipv4.addr.dst,
+				ipv4_key->ipv4_dst, is_mask);
+		attrs &= ~(1 << OVS_KEY_ATTR_IPV4);
+	}
+
+	if (attrs & (1 << OVS_KEY_ATTR_IPV6)) {
+		const struct ovs_key_ipv6 *ipv6_key;
+
+		ipv6_key = nla_data(a[OVS_KEY_ATTR_IPV6]);
+		if (!is_mask && ipv6_key->ipv6_frag > OVS_FRAG_TYPE_MAX) {
+			OVS_NLERR("Unknown IPv6 fragment type (value=%d, max=%d).\n",
+				ipv6_key->ipv6_frag, OVS_FRAG_TYPE_MAX);
+			return -EINVAL;
+		}
+		SW_FLOW_KEY_PUT(match, ipv6.label,
+				ipv6_key->ipv6_label, is_mask);
+		SW_FLOW_KEY_PUT(match, ip.proto,
+				ipv6_key->ipv6_proto, is_mask);
+		SW_FLOW_KEY_PUT(match, ip.tos,
+				ipv6_key->ipv6_tclass, is_mask);
+		SW_FLOW_KEY_PUT(match, ip.ttl,
+				ipv6_key->ipv6_hlimit, is_mask);
+		SW_FLOW_KEY_PUT(match, ip.frag,
+				ipv6_key->ipv6_frag, is_mask);
+		SW_FLOW_KEY_MEMCPY(match, ipv6.addr.src,
+				ipv6_key->ipv6_src,
+				sizeof(match->key->ipv6.addr.src),
+				is_mask);
+		SW_FLOW_KEY_MEMCPY(match, ipv6.addr.dst,
+				ipv6_key->ipv6_dst,
+				sizeof(match->key->ipv6.addr.dst),
+				is_mask);
+
+		attrs &= ~(1 << OVS_KEY_ATTR_IPV6);
+	}
+
+	if (attrs & (1 << OVS_KEY_ATTR_ARP)) {
+		const struct ovs_key_arp *arp_key;
+
+		arp_key = nla_data(a[OVS_KEY_ATTR_ARP]);
+		if (!is_mask && (arp_key->arp_op & htons(0xff00))) {
+			OVS_NLERR("Unknown ARP opcode (opcode=%d).\n",
+				  arp_key->arp_op);
+			return -EINVAL;
+		}
+
+		SW_FLOW_KEY_PUT(match, ipv4.addr.src,
+				arp_key->arp_sip, is_mask);
+		SW_FLOW_KEY_PUT(match, ipv4.addr.dst,
+			arp_key->arp_tip, is_mask);
+		SW_FLOW_KEY_PUT(match, ip.proto,
+				ntohs(arp_key->arp_op), is_mask);
+		SW_FLOW_KEY_MEMCPY(match, ipv4.arp.sha,
+				arp_key->arp_sha, ETH_ALEN, is_mask);
+		SW_FLOW_KEY_MEMCPY(match, ipv4.arp.tha,
+				arp_key->arp_tha, ETH_ALEN, is_mask);
+
+		attrs &= ~(1 << OVS_KEY_ATTR_ARP);
+	}
+
+	if (attrs & (1 << OVS_KEY_ATTR_TCP)) {
+		const struct ovs_key_tcp *tcp_key;
+
+		tcp_key = nla_data(a[OVS_KEY_ATTR_TCP]);
+		if (orig_attrs & (1 << OVS_KEY_ATTR_IPV4)) {
+			SW_FLOW_KEY_PUT(match, ipv4.tp.src,
+					tcp_key->tcp_src, is_mask);
+			SW_FLOW_KEY_PUT(match, ipv4.tp.dst,
+					tcp_key->tcp_dst, is_mask);
+		} else {
+			SW_FLOW_KEY_PUT(match, ipv6.tp.src,
+					tcp_key->tcp_src, is_mask);
+			SW_FLOW_KEY_PUT(match, ipv6.tp.dst,
+					tcp_key->tcp_dst, is_mask);
+		}
+		attrs &= ~(1 << OVS_KEY_ATTR_TCP);
+	}
+
+	if (attrs & (1 << OVS_KEY_ATTR_UDP)) {
+		const struct ovs_key_udp *udp_key;
+
+		udp_key = nla_data(a[OVS_KEY_ATTR_UDP]);
+		if (orig_attrs & (1 << OVS_KEY_ATTR_IPV4)) {
+			SW_FLOW_KEY_PUT(match, ipv4.tp.src,
+					udp_key->udp_src, is_mask);
+			SW_FLOW_KEY_PUT(match, ipv4.tp.dst,
+					udp_key->udp_dst, is_mask);
+		} else {
+			SW_FLOW_KEY_PUT(match, ipv6.tp.src,
+					udp_key->udp_src, is_mask);
+			SW_FLOW_KEY_PUT(match, ipv6.tp.dst,
+					udp_key->udp_dst, is_mask);
+		}
+		attrs &= ~(1 << OVS_KEY_ATTR_UDP);
+	}
+
+	if (attrs & (1 << OVS_KEY_ATTR_SCTP)) {
+		const struct ovs_key_sctp *sctp_key;
+
+		sctp_key = nla_data(a[OVS_KEY_ATTR_SCTP]);
+		if (orig_attrs & (1 << OVS_KEY_ATTR_IPV4)) {
+			SW_FLOW_KEY_PUT(match, ipv4.tp.src,
+					sctp_key->sctp_src, is_mask);
+			SW_FLOW_KEY_PUT(match, ipv4.tp.dst,
+					sctp_key->sctp_dst, is_mask);
+		} else {
+			SW_FLOW_KEY_PUT(match, ipv6.tp.src,
+					sctp_key->sctp_src, is_mask);
+			SW_FLOW_KEY_PUT(match, ipv6.tp.dst,
+					sctp_key->sctp_dst, is_mask);
+		}
+		attrs &= ~(1 << OVS_KEY_ATTR_SCTP);
+	}
+
+	if (attrs & (1 << OVS_KEY_ATTR_ICMP)) {
+		const struct ovs_key_icmp *icmp_key;
+
+		icmp_key = nla_data(a[OVS_KEY_ATTR_ICMP]);
+		SW_FLOW_KEY_PUT(match, ipv4.tp.src,
+				htons(icmp_key->icmp_type), is_mask);
+		SW_FLOW_KEY_PUT(match, ipv4.tp.dst,
+				htons(icmp_key->icmp_code), is_mask);
+		attrs &= ~(1 << OVS_KEY_ATTR_ICMP);
+	}
+
+	if (attrs & (1 << OVS_KEY_ATTR_ICMPV6)) {
+		const struct ovs_key_icmpv6 *icmpv6_key;
+
+		icmpv6_key = nla_data(a[OVS_KEY_ATTR_ICMPV6]);
+		SW_FLOW_KEY_PUT(match, ipv6.tp.src,
+				htons(icmpv6_key->icmpv6_type), is_mask);
+		SW_FLOW_KEY_PUT(match, ipv6.tp.dst,
+				htons(icmpv6_key->icmpv6_code), is_mask);
+		attrs &= ~(1 << OVS_KEY_ATTR_ICMPV6);
+	}
+
+	if (attrs & (1 << OVS_KEY_ATTR_ND)) {
+		const struct ovs_key_nd *nd_key;
+
+		nd_key = nla_data(a[OVS_KEY_ATTR_ND]);
+		SW_FLOW_KEY_MEMCPY(match, ipv6.nd.target,
+			nd_key->nd_target,
+			sizeof(match->key->ipv6.nd.target),
+			is_mask);
+		SW_FLOW_KEY_MEMCPY(match, ipv6.nd.sll,
+			nd_key->nd_sll, ETH_ALEN, is_mask);
+		SW_FLOW_KEY_MEMCPY(match, ipv6.nd.tll,
+				nd_key->nd_tll, ETH_ALEN, is_mask);
+		attrs &= ~(1 << OVS_KEY_ATTR_ND);
+	}
+
+	if (attrs != 0)
+		return -EINVAL;
+
+	return 0;
+}
+
+static void sw_flow_mask_set(struct sw_flow_mask *mask,
+			     struct sw_flow_key_range *range, u8 val)
+{
+	u8 *m = (u8 *)&mask->key + range->start;
+
+	mask->range = *range;
+	memset(m, val, range_n_bytes(range));
+}
+
+/**
+ * ovs_nla_get_match - parses Netlink attributes into a flow key and
+ * mask. In case the 'mask' is NULL, the flow is treated as exact match
+ * flow. Otherwise, it is treated as a wildcarded flow, except the mask
+ * does not include any don't care bit.
+ * @match: receives the extracted flow match information.
+ * @key: Netlink attribute holding nested %OVS_KEY_ATTR_* Netlink attribute
+ * sequence. The fields should of the packet that triggered the creation
+ * of this flow.
+ * @mask: Optional. Netlink attribute holding nested %OVS_KEY_ATTR_* Netlink
+ * attribute specifies the mask field of the wildcarded flow.
+ */
+int ovs_nla_get_match(struct sw_flow_match *match,
+		      const struct nlattr *key,
+		      const struct nlattr *mask)
+{
+	const struct nlattr *a[OVS_KEY_ATTR_MAX + 1];
+	const struct nlattr *encap;
+	u64 key_attrs = 0;
+	u64 mask_attrs = 0;
+	bool encap_valid = false;
+	int err;
+
+	err = parse_flow_nlattrs(key, a, &key_attrs);
+	if (err)
+		return err;
+
+	if ((key_attrs & (1 << OVS_KEY_ATTR_ETHERNET)) &&
+	    (key_attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) &&
+	    (nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]) == htons(ETH_P_8021Q))) {
+		__be16 tci;
+
+		if (!((key_attrs & (1 << OVS_KEY_ATTR_VLAN)) &&
+		      (key_attrs & (1 << OVS_KEY_ATTR_ENCAP)))) {
+			OVS_NLERR("Invalid Vlan frame.\n");
+			return -EINVAL;
+		}
+
+		key_attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
+		tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
+		encap = a[OVS_KEY_ATTR_ENCAP];
+		key_attrs &= ~(1 << OVS_KEY_ATTR_ENCAP);
+		encap_valid = true;
+
+		if (tci & htons(VLAN_TAG_PRESENT)) {
+			err = parse_flow_nlattrs(encap, a, &key_attrs);
+			if (err)
+				return err;
+		} else if (!tci) {
+			/* Corner case for truncated 802.1Q header. */
+			if (nla_len(encap)) {
+				OVS_NLERR("Truncated 802.1Q header has non-zero encap attribute.\n");
+				return -EINVAL;
+			}
+		} else {
+			OVS_NLERR("Encap attribute is set for a non-VLAN frame.\n");
+			return  -EINVAL;
+		}
+	}
+
+	err = ovs_key_from_nlattrs(match, key_attrs, a, false);
+	if (err)
+		return err;
+
+	if (mask) {
+		err = parse_flow_mask_nlattrs(mask, a, &mask_attrs);
+		if (err)
+			return err;
+
+		if (mask_attrs & 1 << OVS_KEY_ATTR_ENCAP)  {
+			__be16 eth_type = 0;
+			__be16 tci = 0;
+
+			if (!encap_valid) {
+				OVS_NLERR("Encap mask attribute is set for non-VLAN frame.\n");
+				return  -EINVAL;
+			}
+
+			mask_attrs &= ~(1 << OVS_KEY_ATTR_ENCAP);
+			if (a[OVS_KEY_ATTR_ETHERTYPE])
+				eth_type = nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]);
+
+			if (eth_type == htons(0xffff)) {
+				mask_attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
+				encap = a[OVS_KEY_ATTR_ENCAP];
+				err = parse_flow_mask_nlattrs(encap, a, &mask_attrs);
+			} else {
+				OVS_NLERR("VLAN frames must have an exact match on the TPID (mask=%x).\n",
+						ntohs(eth_type));
+				return -EINVAL;
+			}
+
+			if (a[OVS_KEY_ATTR_VLAN])
+				tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
+
+			if (!(tci & htons(VLAN_TAG_PRESENT))) {
+				OVS_NLERR("VLAN tag present bit must have an exact match (tci_mask=%x).\n", ntohs(tci));
+				return -EINVAL;
+			}
+		}
+
+		err = ovs_key_from_nlattrs(match, mask_attrs, a, true);
+		if (err)
+			return err;
+	} else {
+		/* Populate exact match flow's key mask. */
+		if (match->mask)
+			sw_flow_mask_set(match->mask, &match->range, 0xff);
+	}
+
+	if (!match_validate(match, key_attrs, mask_attrs))
+		return -EINVAL;
+
+	return 0;
+}
+
+/**
+ * ovs_nla_get_flow_metadata - parses Netlink attributes into a flow key.
+ * @flow: Receives extracted in_port, priority, tun_key and skb_mark.
+ * @attr: Netlink attribute holding nested %OVS_KEY_ATTR_* Netlink attribute
+ * sequence.
+ *
+ * This parses a series of Netlink attributes that form a flow key, which must
+ * take the same form accepted by flow_from_nlattrs(), but only enough of it to
+ * get the metadata, that is, the parts of the flow key that cannot be
+ * extracted from the packet itself.
+ */
+
+int ovs_nla_get_flow_metadata(struct sw_flow *flow,
+			      const struct nlattr *attr)
+{
+	struct ovs_key_ipv4_tunnel *tun_key = &flow->key.tun_key;
+	const struct nlattr *a[OVS_KEY_ATTR_MAX + 1];
+	u64 attrs = 0;
+	int err;
+	struct sw_flow_match match;
+
+	flow->key.phy.in_port = DP_MAX_PORTS;
+	flow->key.phy.priority = 0;
+	flow->key.phy.skb_mark = 0;
+	memset(tun_key, 0, sizeof(flow->key.tun_key));
+
+	err = parse_flow_nlattrs(attr, a, &attrs);
+	if (err)
+		return -EINVAL;
+
+	memset(&match, 0, sizeof(match));
+	match.key = &flow->key;
+
+	err = metadata_from_nlattrs(&match, &attrs, a, false);
+	if (err)
+		return err;
+
+	return 0;
+}
+
+int ovs_nla_put_flow(const struct sw_flow_key *swkey,
+		     const struct sw_flow_key *output, struct sk_buff *skb)
+{
+	struct ovs_key_ethernet *eth_key;
+	struct nlattr *nla, *encap;
+	bool is_mask = (swkey != output);
+
+	if (nla_put_u32(skb, OVS_KEY_ATTR_PRIORITY, output->phy.priority))
+		goto nla_put_failure;
+
+	if ((swkey->tun_key.ipv4_dst || is_mask) &&
+	    ipv4_tun_to_nlattr(skb, &swkey->tun_key, &output->tun_key))
+		goto nla_put_failure;
+
+	if (swkey->phy.in_port == DP_MAX_PORTS) {
+		if (is_mask && (output->phy.in_port == 0xffff))
+			if (nla_put_u32(skb, OVS_KEY_ATTR_IN_PORT, 0xffffffff))
+				goto nla_put_failure;
+	} else {
+		u16 upper_u16;
+		upper_u16 = !is_mask ? 0 : 0xffff;
+
+		if (nla_put_u32(skb, OVS_KEY_ATTR_IN_PORT,
+				(upper_u16 << 16) | output->phy.in_port))
+			goto nla_put_failure;
+	}
+
+	if (nla_put_u32(skb, OVS_KEY_ATTR_SKB_MARK, output->phy.skb_mark))
+		goto nla_put_failure;
+
+	nla = nla_reserve(skb, OVS_KEY_ATTR_ETHERNET, sizeof(*eth_key));
+	if (!nla)
+		goto nla_put_failure;
+
+	eth_key = nla_data(nla);
+	memcpy(eth_key->eth_src, output->eth.src, ETH_ALEN);
+	memcpy(eth_key->eth_dst, output->eth.dst, ETH_ALEN);
+
+	if (swkey->eth.tci || swkey->eth.type == htons(ETH_P_8021Q)) {
+		__be16 eth_type;
+		eth_type = !is_mask ? htons(ETH_P_8021Q) : htons(0xffff);
+		if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, eth_type) ||
+		    nla_put_be16(skb, OVS_KEY_ATTR_VLAN, output->eth.tci))
+			goto nla_put_failure;
+		encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
+		if (!swkey->eth.tci)
+			goto unencap;
+	} else
+		encap = NULL;
+
+	if (swkey->eth.type == htons(ETH_P_802_2)) {
+		/*
+		 * Ethertype 802.2 is represented in the netlink with omitted
+		 * OVS_KEY_ATTR_ETHERTYPE in the flow key attribute, and
+		 * 0xffff in the mask attribute.  Ethertype can also
+		 * be wildcarded.
+		 */
+		if (is_mask && output->eth.type)
+			if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE,
+						output->eth.type))
+				goto nla_put_failure;
+		goto unencap;
+	}
+
+	if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, output->eth.type))
+		goto nla_put_failure;
+
+	if (swkey->eth.type == htons(ETH_P_IP)) {
+		struct ovs_key_ipv4 *ipv4_key;
+
+		nla = nla_reserve(skb, OVS_KEY_ATTR_IPV4, sizeof(*ipv4_key));
+		if (!nla)
+			goto nla_put_failure;
+		ipv4_key = nla_data(nla);
+		ipv4_key->ipv4_src = output->ipv4.addr.src;
+		ipv4_key->ipv4_dst = output->ipv4.addr.dst;
+		ipv4_key->ipv4_proto = output->ip.proto;
+		ipv4_key->ipv4_tos = output->ip.tos;
+		ipv4_key->ipv4_ttl = output->ip.ttl;
+		ipv4_key->ipv4_frag = output->ip.frag;
+	} else if (swkey->eth.type == htons(ETH_P_IPV6)) {
+		struct ovs_key_ipv6 *ipv6_key;
+
+		nla = nla_reserve(skb, OVS_KEY_ATTR_IPV6, sizeof(*ipv6_key));
+		if (!nla)
+			goto nla_put_failure;
+		ipv6_key = nla_data(nla);
+		memcpy(ipv6_key->ipv6_src, &output->ipv6.addr.src,
+				sizeof(ipv6_key->ipv6_src));
+		memcpy(ipv6_key->ipv6_dst, &output->ipv6.addr.dst,
+				sizeof(ipv6_key->ipv6_dst));
+		ipv6_key->ipv6_label = output->ipv6.label;
+		ipv6_key->ipv6_proto = output->ip.proto;
+		ipv6_key->ipv6_tclass = output->ip.tos;
+		ipv6_key->ipv6_hlimit = output->ip.ttl;
+		ipv6_key->ipv6_frag = output->ip.frag;
+	} else if (swkey->eth.type == htons(ETH_P_ARP) ||
+		   swkey->eth.type == htons(ETH_P_RARP)) {
+		struct ovs_key_arp *arp_key;
+
+		nla = nla_reserve(skb, OVS_KEY_ATTR_ARP, sizeof(*arp_key));
+		if (!nla)
+			goto nla_put_failure;
+		arp_key = nla_data(nla);
+		memset(arp_key, 0, sizeof(struct ovs_key_arp));
+		arp_key->arp_sip = output->ipv4.addr.src;
+		arp_key->arp_tip = output->ipv4.addr.dst;
+		arp_key->arp_op = htons(output->ip.proto);
+		memcpy(arp_key->arp_sha, output->ipv4.arp.sha, ETH_ALEN);
+		memcpy(arp_key->arp_tha, output->ipv4.arp.tha, ETH_ALEN);
+	}
+
+	if ((swkey->eth.type == htons(ETH_P_IP) ||
+	     swkey->eth.type == htons(ETH_P_IPV6)) &&
+	     swkey->ip.frag != OVS_FRAG_TYPE_LATER) {
+
+		if (swkey->ip.proto == IPPROTO_TCP) {
+			struct ovs_key_tcp *tcp_key;
+
+			nla = nla_reserve(skb, OVS_KEY_ATTR_TCP, sizeof(*tcp_key));
+			if (!nla)
+				goto nla_put_failure;
+			tcp_key = nla_data(nla);
+			if (swkey->eth.type == htons(ETH_P_IP)) {
+				tcp_key->tcp_src = output->ipv4.tp.src;
+				tcp_key->tcp_dst = output->ipv4.tp.dst;
+			} else if (swkey->eth.type == htons(ETH_P_IPV6)) {
+				tcp_key->tcp_src = output->ipv6.tp.src;
+				tcp_key->tcp_dst = output->ipv6.tp.dst;
+			}
+		} else if (swkey->ip.proto == IPPROTO_UDP) {
+			struct ovs_key_udp *udp_key;
+
+			nla = nla_reserve(skb, OVS_KEY_ATTR_UDP, sizeof(*udp_key));
+			if (!nla)
+				goto nla_put_failure;
+			udp_key = nla_data(nla);
+			if (swkey->eth.type == htons(ETH_P_IP)) {
+				udp_key->udp_src = output->ipv4.tp.src;
+				udp_key->udp_dst = output->ipv4.tp.dst;
+			} else if (swkey->eth.type == htons(ETH_P_IPV6)) {
+				udp_key->udp_src = output->ipv6.tp.src;
+				udp_key->udp_dst = output->ipv6.tp.dst;
+			}
+		} else if (swkey->ip.proto == IPPROTO_SCTP) {
+			struct ovs_key_sctp *sctp_key;
+
+			nla = nla_reserve(skb, OVS_KEY_ATTR_SCTP, sizeof(*sctp_key));
+			if (!nla)
+				goto nla_put_failure;
+			sctp_key = nla_data(nla);
+			if (swkey->eth.type == htons(ETH_P_IP)) {
+				sctp_key->sctp_src = swkey->ipv4.tp.src;
+				sctp_key->sctp_dst = swkey->ipv4.tp.dst;
+			} else if (swkey->eth.type == htons(ETH_P_IPV6)) {
+				sctp_key->sctp_src = swkey->ipv6.tp.src;
+				sctp_key->sctp_dst = swkey->ipv6.tp.dst;
+			}
+		} else if (swkey->eth.type == htons(ETH_P_IP) &&
+			   swkey->ip.proto == IPPROTO_ICMP) {
+			struct ovs_key_icmp *icmp_key;
+
+			nla = nla_reserve(skb, OVS_KEY_ATTR_ICMP, sizeof(*icmp_key));
+			if (!nla)
+				goto nla_put_failure;
+			icmp_key = nla_data(nla);
+			icmp_key->icmp_type = ntohs(output->ipv4.tp.src);
+			icmp_key->icmp_code = ntohs(output->ipv4.tp.dst);
+		} else if (swkey->eth.type == htons(ETH_P_IPV6) &&
+			   swkey->ip.proto == IPPROTO_ICMPV6) {
+			struct ovs_key_icmpv6 *icmpv6_key;
+
+			nla = nla_reserve(skb, OVS_KEY_ATTR_ICMPV6,
+						sizeof(*icmpv6_key));
+			if (!nla)
+				goto nla_put_failure;
+			icmpv6_key = nla_data(nla);
+			icmpv6_key->icmpv6_type = ntohs(output->ipv6.tp.src);
+			icmpv6_key->icmpv6_code = ntohs(output->ipv6.tp.dst);
+
+			if (icmpv6_key->icmpv6_type == NDISC_NEIGHBOUR_SOLICITATION ||
+			    icmpv6_key->icmpv6_type == NDISC_NEIGHBOUR_ADVERTISEMENT) {
+				struct ovs_key_nd *nd_key;
+
+				nla = nla_reserve(skb, OVS_KEY_ATTR_ND, sizeof(*nd_key));
+				if (!nla)
+					goto nla_put_failure;
+				nd_key = nla_data(nla);
+				memcpy(nd_key->nd_target, &output->ipv6.nd.target,
+							sizeof(nd_key->nd_target));
+				memcpy(nd_key->nd_sll, output->ipv6.nd.sll, ETH_ALEN);
+				memcpy(nd_key->nd_tll, output->ipv6.nd.tll, ETH_ALEN);
+			}
+		}
+	}
+
+unencap:
+	if (encap)
+		nla_nest_end(skb, encap);
+
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
+#define MAX_ACTIONS_BUFSIZE	(32 * 1024)
+
+struct sw_flow_actions *ovs_nla_alloc_flow_actions(int size)
+{
+	struct sw_flow_actions *sfa;
+
+	if (size > MAX_ACTIONS_BUFSIZE)
+		return ERR_PTR(-EINVAL);
+
+	sfa = kmalloc(sizeof(*sfa) + size, GFP_KERNEL);
+	if (!sfa)
+		return ERR_PTR(-ENOMEM);
+
+	sfa->actions_len = 0;
+	return sfa;
+}
+
+/* RCU callback used by ovs_nla_free_flow_actions. */
+static void rcu_free_acts_callback(struct rcu_head *rcu)
+{
+	struct sw_flow_actions *sf_acts = container_of(rcu,
+			struct sw_flow_actions, rcu);
+	kfree(sf_acts);
+}
+
+/* Schedules 'sf_acts' to be freed after the next RCU grace period.
+ * The caller must hold rcu_read_lock for this to be sensible. */
+void ovs_nla_free_flow_actions(struct sw_flow_actions *sf_acts)
+{
+	call_rcu(&sf_acts->rcu, rcu_free_acts_callback);
+}
+
+static struct nlattr *reserve_sfa_size(struct sw_flow_actions **sfa,
+				       int attr_len)
+{
+
+	struct sw_flow_actions *acts;
+	int new_acts_size;
+	int req_size = NLA_ALIGN(attr_len);
+	int next_offset = offsetof(struct sw_flow_actions, actions) +
+					(*sfa)->actions_len;
+
+	if (req_size <= (ksize(*sfa) - next_offset))
+		goto out;
+
+	new_acts_size = ksize(*sfa) * 2;
+
+	if (new_acts_size > MAX_ACTIONS_BUFSIZE) {
+		if ((MAX_ACTIONS_BUFSIZE - next_offset) < req_size)
+			return ERR_PTR(-EMSGSIZE);
+		new_acts_size = MAX_ACTIONS_BUFSIZE;
+	}
+
+	acts = ovs_nla_alloc_flow_actions(new_acts_size);
+	if (IS_ERR(acts))
+		return (void *)acts;
+
+	memcpy(acts->actions, (*sfa)->actions, (*sfa)->actions_len);
+	acts->actions_len = (*sfa)->actions_len;
+	kfree(*sfa);
+	*sfa = acts;
+
+out:
+	(*sfa)->actions_len += req_size;
+	return  (struct nlattr *) ((unsigned char *)(*sfa) + next_offset);
+}
+
+static int add_action(struct sw_flow_actions **sfa, int attrtype, void *data, int len)
+{
+	struct nlattr *a;
+
+	a = reserve_sfa_size(sfa, nla_attr_size(len));
+	if (IS_ERR(a))
+		return PTR_ERR(a);
+
+	a->nla_type = attrtype;
+	a->nla_len = nla_attr_size(len);
+
+	if (data)
+		memcpy(nla_data(a), data, len);
+	memset((unsigned char *) a + a->nla_len, 0, nla_padlen(len));
+
+	return 0;
+}
+
+static inline int add_nested_action_start(struct sw_flow_actions **sfa,
+					  int attrtype)
+{
+	int used = (*sfa)->actions_len;
+	int err;
+
+	err = add_action(sfa, attrtype, NULL, 0);
+	if (err)
+		return err;
+
+	return used;
+}
+
+static inline void add_nested_action_end(struct sw_flow_actions *sfa,
+					 int st_offset)
+{
+	struct nlattr *a = (struct nlattr *) ((unsigned char *)sfa->actions +
+							       st_offset);
+
+	a->nla_len = sfa->actions_len - st_offset;
+}
+
+static int validate_and_copy_sample(const struct nlattr *attr,
+				    const struct sw_flow_key *key, int depth,
+				    struct sw_flow_actions **sfa)
+{
+	const struct nlattr *attrs[OVS_SAMPLE_ATTR_MAX + 1];
+	const struct nlattr *probability, *actions;
+	const struct nlattr *a;
+	int rem, start, err, st_acts;
+
+	memset(attrs, 0, sizeof(attrs));
+	nla_for_each_nested(a, attr, rem) {
+		int type = nla_type(a);
+		if (!type || type > OVS_SAMPLE_ATTR_MAX || attrs[type])
+			return -EINVAL;
+		attrs[type] = a;
+	}
+	if (rem)
+		return -EINVAL;
+
+	probability = attrs[OVS_SAMPLE_ATTR_PROBABILITY];
+	if (!probability || nla_len(probability) != sizeof(u32))
+		return -EINVAL;
+
+	actions = attrs[OVS_SAMPLE_ATTR_ACTIONS];
+	if (!actions || (nla_len(actions) && nla_len(actions) < NLA_HDRLEN))
+		return -EINVAL;
+
+	/* validation done, copy sample action. */
+	start = add_nested_action_start(sfa, OVS_ACTION_ATTR_SAMPLE);
+	if (start < 0)
+		return start;
+	err = add_action(sfa, OVS_SAMPLE_ATTR_PROBABILITY,
+			 nla_data(probability), sizeof(u32));
+	if (err)
+		return err;
+	st_acts = add_nested_action_start(sfa, OVS_SAMPLE_ATTR_ACTIONS);
+	if (st_acts < 0)
+		return st_acts;
+
+	err = ovs_nla_copy_actions(actions, key, depth + 1, sfa);
+	if (err)
+		return err;
+
+	add_nested_action_end(*sfa, st_acts);
+	add_nested_action_end(*sfa, start);
+
+	return 0;
+}
+
+static int validate_tp_port(const struct sw_flow_key *flow_key)
+{
+	if (flow_key->eth.type == htons(ETH_P_IP)) {
+		if (flow_key->ipv4.tp.src || flow_key->ipv4.tp.dst)
+			return 0;
+	} else if (flow_key->eth.type == htons(ETH_P_IPV6)) {
+		if (flow_key->ipv6.tp.src || flow_key->ipv6.tp.dst)
+			return 0;
+	}
+
+	return -EINVAL;
+}
+
+void ovs_match_init(struct sw_flow_match *match,
+		    struct sw_flow_key *key,
+		    struct sw_flow_mask *mask)
+{
+	memset(match, 0, sizeof(*match));
+	match->key = key;
+	match->mask = mask;
+
+	memset(key, 0, sizeof(*key));
+
+	if (mask) {
+		memset(&mask->key, 0, sizeof(mask->key));
+		mask->range.start = mask->range.end = 0;
+	}
+}
+
+static int validate_and_copy_set_tun(const struct nlattr *attr,
+				     struct sw_flow_actions **sfa)
+{
+	struct sw_flow_match match;
+	struct sw_flow_key key;
+	int err, start;
+
+	ovs_match_init(&match, &key, NULL);
+	err = ipv4_tun_from_nlattr(nla_data(attr), &match, false);
+	if (err)
+		return err;
+
+	start = add_nested_action_start(sfa, OVS_ACTION_ATTR_SET);
+	if (start < 0)
+		return start;
+
+	err = add_action(sfa, OVS_KEY_ATTR_IPV4_TUNNEL, &match.key->tun_key,
+			sizeof(match.key->tun_key));
+	add_nested_action_end(*sfa, start);
+
+	return err;
+}
+
+static int validate_set(const struct nlattr *a,
+			const struct sw_flow_key *flow_key,
+			struct sw_flow_actions **sfa,
+			bool *set_tun)
+{
+	const struct nlattr *ovs_key = nla_data(a);
+	int key_type = nla_type(ovs_key);
+
+	/* There can be only one key in a action */
+	if (nla_total_size(nla_len(ovs_key)) != nla_len(a))
+		return -EINVAL;
+
+	if (key_type > OVS_KEY_ATTR_MAX ||
+	    (ovs_key_lens[key_type] != nla_len(ovs_key) &&
+	     ovs_key_lens[key_type] != -1))
+		return -EINVAL;
+
+	switch (key_type) {
+	const struct ovs_key_ipv4 *ipv4_key;
+	const struct ovs_key_ipv6 *ipv6_key;
+	int err;
+
+	case OVS_KEY_ATTR_PRIORITY:
+	case OVS_KEY_ATTR_SKB_MARK:
+	case OVS_KEY_ATTR_ETHERNET:
+		break;
+
+	case OVS_KEY_ATTR_TUNNEL:
+		*set_tun = true;
+		err = validate_and_copy_set_tun(a, sfa);
+		if (err)
+			return err;
+		break;
+
+	case OVS_KEY_ATTR_IPV4:
+		if (flow_key->eth.type != htons(ETH_P_IP))
+			return -EINVAL;
+
+		if (!flow_key->ip.proto)
+			return -EINVAL;
+
+		ipv4_key = nla_data(ovs_key);
+		if (ipv4_key->ipv4_proto != flow_key->ip.proto)
+			return -EINVAL;
+
+		if (ipv4_key->ipv4_frag != flow_key->ip.frag)
+			return -EINVAL;
+
+		break;
+
+	case OVS_KEY_ATTR_IPV6:
+		if (flow_key->eth.type != htons(ETH_P_IPV6))
+			return -EINVAL;
+
+		if (!flow_key->ip.proto)
+			return -EINVAL;
+
+		ipv6_key = nla_data(ovs_key);
+		if (ipv6_key->ipv6_proto != flow_key->ip.proto)
+			return -EINVAL;
+
+		if (ipv6_key->ipv6_frag != flow_key->ip.frag)
+			return -EINVAL;
+
+		if (ntohl(ipv6_key->ipv6_label) & 0xFFF00000)
+			return -EINVAL;
+
+		break;
+
+	case OVS_KEY_ATTR_TCP:
+		if (flow_key->ip.proto != IPPROTO_TCP)
+			return -EINVAL;
+
+		return validate_tp_port(flow_key);
+
+	case OVS_KEY_ATTR_UDP:
+		if (flow_key->ip.proto != IPPROTO_UDP)
+			return -EINVAL;
+
+		return validate_tp_port(flow_key);
+
+	case OVS_KEY_ATTR_SCTP:
+		if (flow_key->ip.proto != IPPROTO_SCTP)
+			return -EINVAL;
+
+		return validate_tp_port(flow_key);
+
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int validate_userspace(const struct nlattr *attr)
+{
+	static const struct nla_policy userspace_policy[OVS_USERSPACE_ATTR_MAX + 1] = {
+		[OVS_USERSPACE_ATTR_PID] = {.type = NLA_U32 },
+		[OVS_USERSPACE_ATTR_USERDATA] = {.type = NLA_UNSPEC },
+	};
+	struct nlattr *a[OVS_USERSPACE_ATTR_MAX + 1];
+	int error;
+
+	error = nla_parse_nested(a, OVS_USERSPACE_ATTR_MAX,
+				 attr, userspace_policy);
+	if (error)
+		return error;
+
+	if (!a[OVS_USERSPACE_ATTR_PID] ||
+	    !nla_get_u32(a[OVS_USERSPACE_ATTR_PID]))
+		return -EINVAL;
+
+	return 0;
+}
+
+static int copy_action(const struct nlattr *from,
+		       struct sw_flow_actions **sfa)
+{
+	int totlen = NLA_ALIGN(from->nla_len);
+	struct nlattr *to;
+
+	to = reserve_sfa_size(sfa, from->nla_len);
+	if (IS_ERR(to))
+		return PTR_ERR(to);
+
+	memcpy(to, from, totlen);
+	return 0;
+}
+
+int ovs_nla_copy_actions(const struct nlattr *attr,
+			 const struct sw_flow_key *key,
+			 int depth,
+			 struct sw_flow_actions **sfa)
+{
+	const struct nlattr *a;
+	int rem, err;
+
+	if (depth >= SAMPLE_ACTION_DEPTH)
+		return -EOVERFLOW;
+
+	nla_for_each_nested(a, attr, rem) {
+		/* Expected argument lengths, (u32)-1 for variable length. */
+		static const u32 action_lens[OVS_ACTION_ATTR_MAX + 1] = {
+			[OVS_ACTION_ATTR_OUTPUT] = sizeof(u32),
+			[OVS_ACTION_ATTR_USERSPACE] = (u32)-1,
+			[OVS_ACTION_ATTR_PUSH_VLAN] = sizeof(struct ovs_action_push_vlan),
+			[OVS_ACTION_ATTR_POP_VLAN] = 0,
+			[OVS_ACTION_ATTR_SET] = (u32)-1,
+			[OVS_ACTION_ATTR_SAMPLE] = (u32)-1
+		};
+		const struct ovs_action_push_vlan *vlan;
+		int type = nla_type(a);
+		bool skip_copy;
+
+		if (type > OVS_ACTION_ATTR_MAX ||
+		    (action_lens[type] != nla_len(a) &&
+		     action_lens[type] != (u32)-1))
+			return -EINVAL;
+
+		skip_copy = false;
+		switch (type) {
+		case OVS_ACTION_ATTR_UNSPEC:
+			return -EINVAL;
+
+		case OVS_ACTION_ATTR_USERSPACE:
+			err = validate_userspace(a);
+			if (err)
+				return err;
+			break;
+
+		case OVS_ACTION_ATTR_OUTPUT:
+			if (nla_get_u32(a) >= DP_MAX_PORTS)
+				return -EINVAL;
+			break;
+
+
+		case OVS_ACTION_ATTR_POP_VLAN:
+			break;
+
+		case OVS_ACTION_ATTR_PUSH_VLAN:
+			vlan = nla_data(a);
+			if (vlan->vlan_tpid != htons(ETH_P_8021Q))
+				return -EINVAL;
+			if (!(vlan->vlan_tci & htons(VLAN_TAG_PRESENT)))
+				return -EINVAL;
+			break;
+
+		case OVS_ACTION_ATTR_SET:
+			err = validate_set(a, key, sfa, &skip_copy);
+			if (err)
+				return err;
+			break;
+
+		case OVS_ACTION_ATTR_SAMPLE:
+			err = validate_and_copy_sample(a, key, depth, sfa);
+			if (err)
+				return err;
+			skip_copy = true;
+			break;
+
+		default:
+			return -EINVAL;
+		}
+		if (!skip_copy) {
+			err = copy_action(a, sfa);
+			if (err)
+				return err;
+		}
+	}
+
+	if (rem > 0)
+		return -EINVAL;
+
+	return 0;
+}
+
+static int sample_action_to_attr(const struct nlattr *attr, struct sk_buff *skb)
+{
+	const struct nlattr *a;
+	struct nlattr *start;
+	int err = 0, rem;
+
+	start = nla_nest_start(skb, OVS_ACTION_ATTR_SAMPLE);
+	if (!start)
+		return -EMSGSIZE;
+
+	nla_for_each_nested(a, attr, rem) {
+		int type = nla_type(a);
+		struct nlattr *st_sample;
+
+		switch (type) {
+		case OVS_SAMPLE_ATTR_PROBABILITY:
+			if (nla_put(skb, OVS_SAMPLE_ATTR_PROBABILITY,
+				    sizeof(u32), nla_data(a)))
+				return -EMSGSIZE;
+			break;
+		case OVS_SAMPLE_ATTR_ACTIONS:
+			st_sample = nla_nest_start(skb, OVS_SAMPLE_ATTR_ACTIONS);
+			if (!st_sample)
+				return -EMSGSIZE;
+			err = ovs_nla_put_actions(nla_data(a), nla_len(a), skb);
+			if (err)
+				return err;
+			nla_nest_end(skb, st_sample);
+			break;
+		}
+	}
+
+	nla_nest_end(skb, start);
+	return err;
+}
+
+static int set_action_to_attr(const struct nlattr *a, struct sk_buff *skb)
+{
+	const struct nlattr *ovs_key = nla_data(a);
+	int key_type = nla_type(ovs_key);
+	struct nlattr *start;
+	int err;
+
+	switch (key_type) {
+	case OVS_KEY_ATTR_IPV4_TUNNEL:
+		start = nla_nest_start(skb, OVS_ACTION_ATTR_SET);
+		if (!start)
+			return -EMSGSIZE;
+
+		err = ipv4_tun_to_nlattr(skb, nla_data(ovs_key),
+					     nla_data(ovs_key));
+		if (err)
+			return err;
+		nla_nest_end(skb, start);
+		break;
+	default:
+		if (nla_put(skb, OVS_ACTION_ATTR_SET, nla_len(a), ovs_key))
+			return -EMSGSIZE;
+		break;
+	}
+
+	return 0;
+}
+
+int ovs_nla_put_actions(const struct nlattr *attr, int len, struct sk_buff *skb)
+{
+	const struct nlattr *a;
+	int rem, err;
+
+	nla_for_each_attr(a, attr, len, rem) {
+		int type = nla_type(a);
+
+		switch (type) {
+		case OVS_ACTION_ATTR_SET:
+			err = set_action_to_attr(a, skb);
+			if (err)
+				return err;
+			break;
+
+		case OVS_ACTION_ATTR_SAMPLE:
+			err = sample_action_to_attr(a, skb);
+			if (err)
+				return err;
+			break;
+		default:
+			if (nla_put(skb, type, nla_len(a), nla_data(a)))
+				return -EMSGSIZE;
+			break;
+		}
+	}
+
+	return 0;
+}
diff --git a/net/openvswitch/flow_netlink.h b/net/openvswitch/flow_netlink.h
new file mode 100644
index 0000000..4401510
--- /dev/null
+++ b/net/openvswitch/flow_netlink.h
@@ -0,0 +1,60 @@
+/*
+ * Copyright (c) 2007-2013 Nicira, Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+
+
+#ifndef FLOW_NETLINK_H
+#define FLOW_NETLINK_H 1
+
+#include <linux/kernel.h>
+#include <linux/netlink.h>
+#include <linux/openvswitch.h>
+#include <linux/spinlock.h>
+#include <linux/types.h>
+#include <linux/rcupdate.h>
+#include <linux/if_ether.h>
+#include <linux/in6.h>
+#include <linux/jiffies.h>
+#include <linux/time.h>
+#include <linux/flex_array.h>
+
+#include <net/inet_ecn.h>
+#include <net/ip_tunnels.h>
+
+#include "flow.h"
+
+void ovs_match_init(struct sw_flow_match *match,
+		    struct sw_flow_key *key, struct sw_flow_mask *mask);
+
+int ovs_nla_put_flow(const struct sw_flow_key *,
+		     const struct sw_flow_key *, struct sk_buff *);
+int ovs_nla_get_flow_metadata(struct sw_flow *flow,
+			      const struct nlattr *attr);
+int ovs_nla_get_match(struct sw_flow_match *match,
+		      const struct nlattr *,
+		      const struct nlattr *);
+
+int ovs_nla_copy_actions(const struct nlattr *attr,
+			 const struct sw_flow_key *key, int depth,
+			 struct sw_flow_actions **sfa);
+int ovs_nla_put_actions(const struct nlattr *attr,
+			int len, struct sk_buff *skb);
+
+struct sw_flow_actions *ovs_nla_alloc_flow_actions(int actions_len);
+void ovs_nla_free_flow_actions(struct sw_flow_actions *);
+
+#endif /* flow_netlink.h */
diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
new file mode 100644
index 0000000..dcadb75
--- /dev/null
+++ b/net/openvswitch/flow_table.c
@@ -0,0 +1,517 @@
+/*
+ * Copyright (c) 2007-2013 Nicira, Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+
+#include "flow.h"
+#include "datapath.h"
+#include <linux/uaccess.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/if_ether.h>
+#include <linux/if_vlan.h>
+#include <net/llc_pdu.h>
+#include <linux/kernel.h>
+#include <linux/jhash.h>
+#include <linux/jiffies.h>
+#include <linux/llc.h>
+#include <linux/module.h>
+#include <linux/in.h>
+#include <linux/rcupdate.h>
+#include <linux/if_arp.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/sctp.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
+#include <linux/icmp.h>
+#include <linux/icmpv6.h>
+#include <linux/rculist.h>
+#include <net/ip.h>
+#include <net/ipv6.h>
+#include <net/ndisc.h>
+
+static struct kmem_cache *flow_cache;
+
+static u16 range_n_bytes(const struct sw_flow_key_range *range)
+{
+	return range->end - range->start;
+}
+
+void ovs_flow_mask_key(struct sw_flow_key *dst, const struct sw_flow_key *src,
+		       const struct sw_flow_mask *mask)
+{
+	const long *m = (long *)((u8 *)&mask->key + mask->range.start);
+	const long *s = (long *)((u8 *)src + mask->range.start);
+	long *d = (long *)((u8 *)dst + mask->range.start);
+	int i;
+
+	/* The memory outside of the 'mask->range' are not set since
+	 * further operations on 'dst' only uses contents within
+	 * 'mask->range'.
+	 */
+	for (i = 0; i < range_n_bytes(&mask->range); i += sizeof(long))
+		*d++ = *s++ & *m++;
+}
+
+struct sw_flow *ovs_flow_alloc(void)
+{
+	struct sw_flow *flow;
+
+	flow = kmem_cache_alloc(flow_cache, GFP_KERNEL);
+	if (!flow)
+		return ERR_PTR(-ENOMEM);
+
+	spin_lock_init(&flow->lock);
+	flow->sf_acts = NULL;
+	flow->mask = NULL;
+
+	return flow;
+}
+
+static struct flex_array *alloc_buckets(unsigned int n_buckets)
+{
+	struct flex_array *buckets;
+	int i, err;
+
+	buckets = flex_array_alloc(sizeof(struct hlist_head),
+				   n_buckets, GFP_KERNEL);
+	if (!buckets)
+		return NULL;
+
+	err = flex_array_prealloc(buckets, 0, n_buckets, GFP_KERNEL);
+	if (err) {
+		flex_array_free(buckets);
+		return NULL;
+	}
+
+	for (i = 0; i < n_buckets; i++)
+		INIT_HLIST_HEAD((struct hlist_head *)
+					flex_array_get(buckets, i));
+
+	return buckets;
+}
+
+static void flow_free(struct sw_flow *flow)
+{
+	kfree((struct sf_flow_acts __force *)flow->sf_acts);
+	kmem_cache_free(flow_cache, flow);
+}
+
+static void rcu_free_flow_callback(struct rcu_head *rcu)
+{
+	struct sw_flow *flow = container_of(rcu, struct sw_flow, rcu);
+
+	flow_free(flow);
+}
+
+void ovs_flow_free(struct sw_flow *flow, bool deferred)
+{
+	if (!flow)
+		return;
+
+	ovs_sw_flow_mask_del_ref(flow->mask, deferred);
+
+	if (deferred)
+		call_rcu(&flow->rcu, rcu_free_flow_callback);
+	else
+		flow_free(flow);
+}
+
+static void free_buckets(struct flex_array *buckets)
+{
+	flex_array_free(buckets);
+}
+
+static void __flow_tbl_destroy(struct flow_table *table)
+{
+	int i;
+
+	if (table->keep_flows)
+		goto skip_flows;
+
+	for (i = 0; i < table->n_buckets; i++) {
+		struct sw_flow *flow;
+		struct hlist_head *head = flex_array_get(table->buckets, i);
+		struct hlist_node *n;
+		int ver = table->node_ver;
+
+		hlist_for_each_entry_safe(flow, n, head, hash_node[ver]) {
+			hlist_del(&flow->hash_node[ver]);
+			ovs_flow_free(flow, false);
+		}
+	}
+
+	BUG_ON(!list_empty(table->mask_list));
+	kfree(table->mask_list);
+
+skip_flows:
+	free_buckets(table->buckets);
+	kfree(table);
+}
+
+static struct flow_table *__flow_tbl_alloc(int new_size)
+{
+	struct flow_table *table = kmalloc(sizeof(*table), GFP_KERNEL);
+
+	if (!table)
+		return NULL;
+
+	table->buckets = alloc_buckets(new_size);
+
+	if (!table->buckets) {
+		kfree(table);
+		return NULL;
+	}
+	table->n_buckets = new_size;
+	table->count = 0;
+	table->node_ver = 0;
+	table->keep_flows = false;
+	get_random_bytes(&table->hash_seed, sizeof(u32));
+	table->mask_list = NULL;
+
+	return table;
+}
+
+struct flow_table *ovs_flow_tbl_alloc(int new_size)
+{
+	struct flow_table *table = __flow_tbl_alloc(new_size);
+
+	if (!table)
+		return NULL;
+
+	table->mask_list = kmalloc(sizeof(struct list_head), GFP_KERNEL);
+	if (!table->mask_list) {
+		table->keep_flows = true;
+		__flow_tbl_destroy(table);
+		return NULL;
+	}
+	INIT_LIST_HEAD(table->mask_list);
+
+	return table;
+}
+
+static void flow_tbl_destroy_rcu_cb(struct rcu_head *rcu)
+{
+	struct flow_table *table = container_of(rcu, struct flow_table, rcu);
+
+	__flow_tbl_destroy(table);
+}
+
+void ovs_flow_tbl_destroy(struct flow_table *table, bool deferred)
+{
+	if (!table)
+		return;
+
+	if (deferred)
+		call_rcu(&table->rcu, flow_tbl_destroy_rcu_cb);
+	else
+		__flow_tbl_destroy(table);
+}
+
+struct sw_flow *ovs_flow_tbl_dump_next(struct flow_table *table,
+				       u32 *bucket, u32 *last)
+{
+	struct sw_flow *flow;
+	struct hlist_head *head;
+	int ver;
+	int i;
+
+	ver = table->node_ver;
+	while (*bucket < table->n_buckets) {
+		i = 0;
+		head = flex_array_get(table->buckets, *bucket);
+		hlist_for_each_entry_rcu(flow, head, hash_node[ver]) {
+			if (i < *last) {
+				i++;
+				continue;
+			}
+			*last = i + 1;
+			return flow;
+		}
+		(*bucket)++;
+		*last = 0;
+	}
+
+	return NULL;
+}
+
+static struct hlist_head *find_bucket(struct flow_table *table, u32 hash)
+{
+	hash = jhash_1word(hash, table->hash_seed);
+	return flex_array_get(table->buckets,
+				(hash & (table->n_buckets - 1)));
+}
+
+static void __tbl_insert(struct flow_table *table, struct sw_flow *flow)
+{
+	struct hlist_head *head;
+
+	head = find_bucket(table, flow->hash);
+	hlist_add_head_rcu(&flow->hash_node[table->node_ver], head);
+
+	table->count++;
+}
+
+static void flow_table_copy_flows(struct flow_table *old,
+				  struct flow_table *new)
+{
+	int old_ver;
+	int i;
+
+	old_ver = old->node_ver;
+	new->node_ver = !old_ver;
+
+	/* Insert in new table. */
+	for (i = 0; i < old->n_buckets; i++) {
+		struct sw_flow *flow;
+		struct hlist_head *head;
+
+		head = flex_array_get(old->buckets, i);
+
+		hlist_for_each_entry(flow, head, hash_node[old_ver])
+			__tbl_insert(new, flow);
+	}
+
+	new->mask_list = old->mask_list;
+	old->keep_flows = true;
+}
+
+static struct flow_table *__flow_tbl_rehash(struct flow_table *table,
+					    int n_buckets)
+{
+	struct flow_table *new_table;
+
+	new_table = __flow_tbl_alloc(n_buckets);
+	if (!new_table)
+		return ERR_PTR(-ENOMEM);
+
+	flow_table_copy_flows(table, new_table);
+
+	return new_table;
+}
+
+struct flow_table *ovs_flow_tbl_rehash(struct flow_table *table)
+{
+	return __flow_tbl_rehash(table, table->n_buckets);
+}
+
+struct flow_table *ovs_flow_tbl_expand(struct flow_table *table)
+{
+	return __flow_tbl_rehash(table, table->n_buckets * 2);
+}
+
+static u32 flow_hash(const struct sw_flow_key *key, int key_start,
+		     int key_end)
+{
+	u32 *hash_key = (u32 *)((u8 *)key + key_start);
+	int hash_u32s = (key_end - key_start) >> 2;
+
+	/* Make sure number of hash bytes are multiple of u32. */
+	BUILD_BUG_ON(sizeof(long) % sizeof(u32));
+
+	return jhash2(hash_key, hash_u32s, 0);
+}
+
+static int flow_key_start(const struct sw_flow_key *key)
+{
+	if (key->tun_key.ipv4_dst)
+		return 0;
+	else
+		return rounddown(offsetof(struct sw_flow_key, phy),
+					  sizeof(long));
+}
+
+static bool cmp_key(const struct sw_flow_key *key1,
+		    const struct sw_flow_key *key2,
+		    int key_start, int key_end)
+{
+	const long *cp1 = (long *)((u8 *)key1 + key_start);
+	const long *cp2 = (long *)((u8 *)key2 + key_start);
+	long diffs = 0;
+	int i;
+
+	for (i = key_start; i < key_end;  i += sizeof(long))
+		diffs |= *cp1++ ^ *cp2++;
+
+	return diffs == 0;
+}
+
+static bool flow_cmp_masked_key(const struct sw_flow *flow,
+				const struct sw_flow_key *key,
+				int key_start, int key_end)
+{
+	return cmp_key(&flow->key, key, key_start, key_end);
+}
+
+bool ovs_flow_cmp_unmasked_key(const struct sw_flow *flow,
+			       struct sw_flow_match *match)
+{
+	struct sw_flow_key *key = match->key;
+	int key_start = flow_key_start(key);
+	int key_end = match->range.end;
+
+	return cmp_key(&flow->unmasked_key, key, key_start, key_end);
+}
+
+static struct sw_flow *masked_flow_lookup(struct flow_table *table,
+					  const struct sw_flow_key *unmasked,
+					  struct sw_flow_mask *mask)
+{
+	struct sw_flow *flow;
+	struct hlist_head *head;
+	int key_start = mask->range.start;
+	int key_end = mask->range.end;
+	u32 hash;
+	struct sw_flow_key masked_key;
+
+	ovs_flow_mask_key(&masked_key, unmasked, mask);
+	hash = flow_hash(&masked_key, key_start, key_end);
+	head = find_bucket(table, hash);
+	hlist_for_each_entry_rcu(flow, head, hash_node[table->node_ver]) {
+		if (flow->mask == mask &&
+		    flow_cmp_masked_key(flow, &masked_key,
+					  key_start, key_end))
+			return flow;
+	}
+	return NULL;
+}
+
+struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *tbl,
+				    const struct sw_flow_key *key)
+{
+	struct sw_flow *flow = NULL;
+	struct sw_flow_mask *mask;
+
+	list_for_each_entry_rcu(mask, tbl->mask_list, list) {
+		flow = masked_flow_lookup(tbl, key, mask);
+		if (flow)  /* Found */
+			break;
+	}
+
+	return flow;
+}
+
+void ovs_flow_tbl_insert(struct flow_table *table, struct sw_flow *flow)
+{
+	flow->hash = flow_hash(&flow->key, flow->mask->range.start,
+			flow->mask->range.end);
+	__tbl_insert(table, flow);
+}
+
+void ovs_flow_tbl_remove(struct flow_table *table, struct sw_flow *flow)
+{
+	BUG_ON(table->count == 0);
+	hlist_del_rcu(&flow->hash_node[table->node_ver]);
+	table->count--;
+}
+
+struct sw_flow_mask *ovs_sw_flow_mask_alloc(void)
+{
+	struct sw_flow_mask *mask;
+
+	mask = kmalloc(sizeof(*mask), GFP_KERNEL);
+	if (mask)
+		mask->ref_count = 0;
+
+	return mask;
+}
+
+void ovs_sw_flow_mask_add_ref(struct sw_flow_mask *mask)
+{
+	mask->ref_count++;
+}
+
+static void rcu_free_sw_flow_mask_cb(struct rcu_head *rcu)
+{
+	struct sw_flow_mask *mask = container_of(rcu, struct sw_flow_mask, rcu);
+
+	kfree(mask);
+}
+
+void ovs_sw_flow_mask_del_ref(struct sw_flow_mask *mask, bool deferred)
+{
+	if (!mask)
+		return;
+
+	BUG_ON(!mask->ref_count);
+	mask->ref_count--;
+
+	if (!mask->ref_count) {
+		list_del_rcu(&mask->list);
+		if (deferred)
+			call_rcu(&mask->rcu, rcu_free_sw_flow_mask_cb);
+		else
+			kfree(mask);
+	}
+}
+
+static bool mask_equal(const struct sw_flow_mask *a,
+		       const struct sw_flow_mask *b)
+{
+	u8 *a_ = (u8 *)&a->key + a->range.start;
+	u8 *b_ = (u8 *)&b->key + b->range.start;
+
+	return  (a->range.end == b->range.end)
+		&& (a->range.start == b->range.start)
+		&& (memcmp(a_, b_, range_n_bytes(&a->range)) == 0);
+}
+
+struct sw_flow_mask *ovs_sw_flow_mask_find(const struct flow_table *tbl,
+					   const struct sw_flow_mask *mask)
+{
+	struct list_head *ml;
+
+	list_for_each(ml, tbl->mask_list) {
+		struct sw_flow_mask *m;
+		m = container_of(ml, struct sw_flow_mask, list);
+		if (mask_equal(mask, m))
+			return m;
+	}
+
+	return NULL;
+}
+
+/**
+ * add a new mask into the mask list.
+ * The caller needs to make sure that 'mask' is not the same
+ * as any masks that are already on the list.
+ */
+void ovs_sw_flow_mask_insert(struct flow_table *tbl, struct sw_flow_mask *mask)
+{
+	list_add_rcu(&mask->list, tbl->mask_list);
+}
+
+/* Initializes the flow module.
+ * Returns zero if successful or a negative error code. */
+int ovs_flow_init(void)
+{
+	BUILD_BUG_ON(__alignof__(struct sw_flow_key) % __alignof__(long));
+	BUILD_BUG_ON(sizeof(struct sw_flow_key) % sizeof(long));
+
+	flow_cache = kmem_cache_create("sw_flow", sizeof(struct sw_flow), 0,
+					0, NULL);
+	if (flow_cache == NULL)
+		return -ENOMEM;
+
+	return 0;
+}
+
+/* Uninitializes the flow module. */
+void ovs_flow_exit(void)
+{
+	kmem_cache_destroy(flow_cache);
+}
diff --git a/net/openvswitch/flow_table.h b/net/openvswitch/flow_table.h
new file mode 100644
index 0000000..d7a1144
--- /dev/null
+++ b/net/openvswitch/flow_table.h
@@ -0,0 +1,91 @@
+/*
+ * Copyright (c) 2007-2013 Nicira, Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+
+#ifndef FLOW_TABLE_H
+#define FLOW_TABLE_H 1
+
+#include <linux/kernel.h>
+#include <linux/netlink.h>
+#include <linux/openvswitch.h>
+#include <linux/spinlock.h>
+#include <linux/types.h>
+#include <linux/rcupdate.h>
+#include <linux/if_ether.h>
+#include <linux/in6.h>
+#include <linux/jiffies.h>
+#include <linux/time.h>
+#include <linux/flex_array.h>
+
+#include <net/inet_ecn.h>
+#include <net/ip_tunnels.h>
+
+#include "flow.h"
+
+#define TBL_MIN_BUCKETS		1024
+
+struct flow_table {
+	struct flex_array *buckets;
+	unsigned int count, n_buckets;
+	struct rcu_head rcu;
+	struct list_head *mask_list;
+	int node_ver;
+	u32 hash_seed;
+	bool keep_flows;
+};
+
+int ovs_flow_init(void);
+void ovs_flow_exit(void);
+
+struct sw_flow *ovs_flow_alloc(void);
+void ovs_flow_free(struct sw_flow *, bool deferred);
+
+static inline int ovs_flow_tbl_count(struct flow_table *table)
+{
+	return table->count;
+}
+
+static inline int ovs_flow_tbl_need_to_expand(struct flow_table *table)
+{
+	return (table->count > table->n_buckets);
+}
+
+struct flow_table *ovs_flow_tbl_alloc(int new_size);
+struct flow_table *ovs_flow_tbl_expand(struct flow_table *table);
+struct flow_table *ovs_flow_tbl_rehash(struct flow_table *table);
+void ovs_flow_tbl_destroy(struct flow_table *table, bool deferred);
+
+void ovs_flow_tbl_insert(struct flow_table *table, struct sw_flow *flow);
+void ovs_flow_tbl_remove(struct flow_table *table, struct sw_flow *flow);
+struct sw_flow *ovs_flow_tbl_dump_next(struct flow_table *table,
+				       u32 *bucket, u32 *idx);
+struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *,
+				    const struct sw_flow_key *);
+
+bool ovs_flow_cmp_unmasked_key(const struct sw_flow *flow,
+			       struct sw_flow_match *match);
+
+struct sw_flow_mask *ovs_sw_flow_mask_alloc(void);
+void ovs_sw_flow_mask_add_ref(struct sw_flow_mask *);
+void ovs_sw_flow_mask_del_ref(struct sw_flow_mask *, bool deferred);
+void ovs_sw_flow_mask_insert(struct flow_table *, struct sw_flow_mask *);
+struct sw_flow_mask *ovs_sw_flow_mask_find(const struct flow_table *,
+					   const struct sw_flow_mask *);
+void ovs_flow_mask_key(struct sw_flow_key *dst, const struct sw_flow_key *src,
+		       const struct sw_flow_mask *mask);
+
+#endif /* flow_table.h */
-- 
1.8.3.2
