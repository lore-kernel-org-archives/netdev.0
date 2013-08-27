From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 07/11] openvswitch: Mega flow implementation
Date: Tue, 27 Aug 2013 13:20:44 -0700
Message-ID: <1377634848-34327-8-git-send-email-jesse@nicira.com>
References: <1377634848-34327-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Andy Zhou <azhou@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog104.obsmtp.com ([74.125.149.73]:48157 "HELO
	na3sys009aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753962Ab3H0UVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 16:21:15 -0400
Received: by mail-pa0-f42.google.com with SMTP id lj1so5314582pab.29
        for <netdev@vger.kernel.org>; Tue, 27 Aug 2013 13:21:12 -0700 (PDT)
In-Reply-To: <1377634848-34327-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>

Add wildcarded flow support in kernel datapath.

Wildcarded flow can improve OVS flow set up performance by avoid sending
matching new flows to the user space program. The exact performance boost
will largely dependent on wildcarded flow hit rate.

In case all new flows hits wildcard flows, the flow set up rate is
within 5% of that of linux bridge module.

Pravin has made significant contributions to this patch. Including API
clean ups and bug fixes.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Andy Zhou <azhou@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 Documentation/networking/openvswitch.txt |   40 +
 include/uapi/linux/openvswitch.h         |    9 +-
 net/openvswitch/actions.c                |    6 +-
 net/openvswitch/datapath.c               |  140 ++-
 net/openvswitch/datapath.h               |    6 +
 net/openvswitch/flow.c                   | 1387 ++++++++++++++++++++----------
 net/openvswitch/flow.h                   |   96 ++-
 7 files changed, 1171 insertions(+), 513 deletions(-)

diff --git a/Documentation/networking/openvswitch.txt b/Documentation/networking/openvswitch.txt
index 8fa2dd1..37c20ee 100644
--- a/Documentation/networking/openvswitch.txt
+++ b/Documentation/networking/openvswitch.txt
@@ -91,6 +91,46 @@ Often we ellipsize arguments not important to the discussion, e.g.:
     in_port(1), eth(...), eth_type(0x0800), ipv4(...), tcp(...)
 
 
+Wildcarded flow key format
+--------------------------
+
+A wildcarded flow is described with two sequences of Netlink attributes
+passed over the Netlink socket. A flow key, exactly as described above, and an
+optional corresponding flow mask.
+
+A wildcarded flow can represent a group of exact match flows. Each '1' bit
+in the mask specifies a exact match with the corresponding bit in the flow key.
+A '0' bit specifies a don't care bit, which will match either a '1' or '0' bit
+of a incoming packet. Using wildcarded flow can improve the flow set up rate
+by reduce the number of new flows need to be processed by the user space program.
+
+Support for the mask Netlink attribute is optional for both the kernel and user
+space program. The kernel can ignore the mask attribute, installing an exact
+match flow, or reduce the number of don't care bits in the kernel to less than
+what was specified by the user space program. In this case, variations in bits
+that the kernel does not implement will simply result in additional flow setups.
+The kernel module will also work with user space programs that neither support
+nor supply flow mask attributes.
+
+Since the kernel may ignore or modify wildcard bits, it can be difficult for
+the userspace program to know exactly what matches are installed. There are
+two possible approaches: reactively install flows as they miss the kernel
+flow table (and therefore not attempt to determine wildcard changes at all)
+or use the kernel's response messages to determine the installed wildcards.
+
+When interacting with userspace, the kernel should maintain the match portion
+of the key exactly as originally installed. This will provides a handle to
+identify the flow for all future operations. However, when reporting the
+mask of an installed flow, the mask should include any restrictions imposed
+by the kernel.
+
+The behavior when using overlapping wildcarded flows is undefined. It is the
+responsibility of the user space program to ensure that any incoming packet
+can match at most one flow, wildcarded or not. The current implementation
+performs best-effort detection of overlapping wildcarded flows and may reject
+some but not all of them. However, this behavior may change in future versions.
+
+
 Basic rule for evolving flow keys
 ---------------------------------
 
diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 52490b0..de1fa5d 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -1,6 +1,6 @@
 
 /*
- * Copyright (c) 2007-2011 Nicira Networks.
+ * Copyright (c) 2007-2013 Nicira, Inc.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
@@ -379,6 +379,12 @@ struct ovs_key_nd {
  * @OVS_FLOW_ATTR_CLEAR: If present in a %OVS_FLOW_CMD_SET request, clears the
  * last-used time, accumulated TCP flags, and statistics for this flow.
  * Otherwise ignored in requests.  Never present in notifications.
+ * @OVS_FLOW_ATTR_MASK: Nested %OVS_KEY_ATTR_* attributes specifying the
+ * mask bits for wildcarded flow match. Mask bit value '1' specifies exact
+ * match with corresponding flow key bit, while mask bit value '0' specifies
+ * a wildcarded match. Omitting attribute is treated as wildcarding all
+ * corresponding fields. Optional for all requests. If not present,
+ * all flow key bits are exact match bits.
  *
  * These attributes follow the &struct ovs_header within the Generic Netlink
  * payload for %OVS_FLOW_* commands.
@@ -391,6 +397,7 @@ enum ovs_flow_attr {
 	OVS_FLOW_ATTR_TCP_FLAGS, /* 8-bit OR'd TCP flags. */
 	OVS_FLOW_ATTR_USED,      /* u64 msecs last used in monotonic time. */
 	OVS_FLOW_ATTR_CLEAR,     /* Flag to clear stats, tcp_flags, used. */
+	OVS_FLOW_ATTR_MASK,      /* Sequence of OVS_KEY_ATTR_* attributes. */
 	__OVS_FLOW_ATTR_MAX
 };
 
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index ab101f7..1f68022 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2007-2012 Nicira, Inc.
+ * Copyright (c) 2007-2013 Nicira, Inc.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
@@ -376,8 +376,10 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
 	const struct nlattr *a;
 	int rem;
 
+	BUG_ON(!OVS_CB(skb)->pkt_key);
+
 	upcall.cmd = OVS_PACKET_CMD_ACTION;
-	upcall.key = &OVS_CB(skb)->flow->key;
+	upcall.key = OVS_CB(skb)->pkt_key;
 	upcall.userdata = NULL;
 	upcall.portid = 0;
 
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 9d97ef3..d29cd9a 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2007-2012 Nicira, Inc.
+ * Copyright (c) 2007-2013 Nicira, Inc.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
@@ -165,7 +165,7 @@ static void destroy_dp_rcu(struct rcu_head *rcu)
 {
 	struct datapath *dp = container_of(rcu, struct datapath, rcu);
 
-	ovs_flow_tbl_destroy((__force struct flow_table *)dp->table);
+	ovs_flow_tbl_destroy((__force struct flow_table *)dp->table, false);
 	free_percpu(dp->stats_percpu);
 	release_net(ovs_dp_get_net(dp));
 	kfree(dp->ports);
@@ -226,19 +226,18 @@ void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
 	struct sw_flow_key key;
 	u64 *stats_counter;
 	int error;
-	int key_len;
 
 	stats = this_cpu_ptr(dp->stats_percpu);
 
 	/* Extract flow from 'skb' into 'key'. */
-	error = ovs_flow_extract(skb, p->port_no, &key, &key_len);
+	error = ovs_flow_extract(skb, p->port_no, &key);
 	if (unlikely(error)) {
 		kfree_skb(skb);
 		return;
 	}
 
 	/* Look up flow. */
-	flow = ovs_flow_tbl_lookup(rcu_dereference(dp->table), &key, key_len);
+	flow = ovs_flow_lookup(rcu_dereference(dp->table), &key);
 	if (unlikely(!flow)) {
 		struct dp_upcall_info upcall;
 
@@ -253,6 +252,7 @@ void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
 	}
 
 	OVS_CB(skb)->flow = flow;
+	OVS_CB(skb)->pkt_key = &key;
 
 	stats_counter = &stats->n_hit;
 	ovs_flow_used(OVS_CB(skb)->flow, skb);
@@ -435,7 +435,7 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
 	upcall->dp_ifindex = dp_ifindex;
 
 	nla = nla_nest_start(user_skb, OVS_PACKET_ATTR_KEY);
-	ovs_flow_to_nlattrs(upcall_info->key, user_skb);
+	ovs_flow_to_nlattrs(upcall_info->key, upcall_info->key, user_skb);
 	nla_nest_end(user_skb, nla);
 
 	if (upcall_info->userdata)
@@ -468,7 +468,7 @@ static int flush_flows(struct datapath *dp)
 
 	rcu_assign_pointer(dp->table, new_table);
 
-	ovs_flow_tbl_deferred_destroy(old_table);
+	ovs_flow_tbl_destroy(old_table, true);
 	return 0;
 }
 
@@ -611,10 +611,12 @@ static int validate_tp_port(const struct sw_flow_key *flow_key)
 static int validate_and_copy_set_tun(const struct nlattr *attr,
 				     struct sw_flow_actions **sfa)
 {
-	struct ovs_key_ipv4_tunnel tun_key;
+	struct sw_flow_match match;
+	struct sw_flow_key key;
 	int err, start;
 
-	err = ovs_ipv4_tun_from_nlattr(nla_data(attr), &tun_key);
+	ovs_match_init(&match, &key, NULL);
+	err = ovs_ipv4_tun_from_nlattr(nla_data(attr), &match, false);
 	if (err)
 		return err;
 
@@ -622,7 +624,8 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 	if (start < 0)
 		return start;
 
-	err = add_action(sfa, OVS_KEY_ATTR_IPV4_TUNNEL, &tun_key, sizeof(tun_key));
+	err = add_action(sfa, OVS_KEY_ATTR_IPV4_TUNNEL, &match.key->tun_key,
+			sizeof(match.key->tun_key));
 	add_nested_action_end(*sfa, start);
 
 	return err;
@@ -857,7 +860,6 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	struct ethhdr *eth;
 	int len;
 	int err;
-	int key_len;
 
 	err = -EINVAL;
 	if (!a[OVS_PACKET_ATTR_PACKET] || !a[OVS_PACKET_ATTR_KEY] ||
@@ -890,11 +892,11 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	if (IS_ERR(flow))
 		goto err_kfree_skb;
 
-	err = ovs_flow_extract(packet, -1, &flow->key, &key_len);
+	err = ovs_flow_extract(packet, -1, &flow->key);
 	if (err)
 		goto err_flow_free;
 
-	err = ovs_flow_metadata_from_nlattrs(flow, key_len, a[OVS_PACKET_ATTR_KEY]);
+	err = ovs_flow_metadata_from_nlattrs(flow, a[OVS_PACKET_ATTR_KEY]);
 	if (err)
 		goto err_flow_free;
 	acts = ovs_flow_actions_alloc(nla_len(a[OVS_PACKET_ATTR_ACTIONS]));
@@ -908,6 +910,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 		goto err_flow_free;
 
 	OVS_CB(packet)->flow = flow;
+	OVS_CB(packet)->pkt_key = &flow->key;
 	packet->priority = flow->key.phy.priority;
 	packet->mark = flow->key.phy.skb_mark;
 
@@ -922,13 +925,13 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	local_bh_enable();
 	rcu_read_unlock();
 
-	ovs_flow_free(flow);
+	ovs_flow_free(flow, false);
 	return err;
 
 err_unlock:
 	rcu_read_unlock();
 err_flow_free:
-	ovs_flow_free(flow);
+	ovs_flow_free(flow, false);
 err_kfree_skb:
 	kfree_skb(packet);
 err:
@@ -1045,7 +1048,8 @@ static int set_action_to_attr(const struct nlattr *a, struct sk_buff *skb)
 		if (!start)
 			return -EMSGSIZE;
 
-		err = ovs_ipv4_tun_to_nlattr(skb, nla_data(ovs_key));
+		err = ovs_ipv4_tun_to_nlattr(skb, nla_data(ovs_key),
+					     nla_data(ovs_key));
 		if (err)
 			return err;
 		nla_nest_end(skb, start);
@@ -1093,6 +1097,7 @@ static size_t ovs_flow_cmd_msg_size(const struct sw_flow_actions *acts)
 {
 	return NLMSG_ALIGN(sizeof(struct ovs_header))
 		+ nla_total_size(key_attr_size()) /* OVS_FLOW_ATTR_KEY */
+		+ nla_total_size(key_attr_size()) /* OVS_FLOW_ATTR_MASK */
 		+ nla_total_size(sizeof(struct ovs_flow_stats)) /* OVS_FLOW_ATTR_STATS */
 		+ nla_total_size(1) /* OVS_FLOW_ATTR_TCP_FLAGS */
 		+ nla_total_size(8) /* OVS_FLOW_ATTR_USED */
@@ -1119,12 +1124,25 @@ static int ovs_flow_cmd_fill_info(struct sw_flow *flow, struct datapath *dp,
 
 	ovs_header->dp_ifindex = get_dpifindex(dp);
 
+	/* Fill flow key. */
 	nla = nla_nest_start(skb, OVS_FLOW_ATTR_KEY);
 	if (!nla)
 		goto nla_put_failure;
-	err = ovs_flow_to_nlattrs(&flow->key, skb);
+
+	err = ovs_flow_to_nlattrs(&flow->unmasked_key,
+			&flow->unmasked_key, skb);
+	if (err)
+		goto error;
+	nla_nest_end(skb, nla);
+
+	nla = nla_nest_start(skb, OVS_FLOW_ATTR_MASK);
+	if (!nla)
+		goto nla_put_failure;
+
+	err = ovs_flow_to_nlattrs(&flow->key, &flow->mask->key, skb);
 	if (err)
 		goto error;
+
 	nla_nest_end(skb, nla);
 
 	spin_lock_bh(&flow->lock);
@@ -1214,20 +1232,24 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 {
 	struct nlattr **a = info->attrs;
 	struct ovs_header *ovs_header = info->userhdr;
-	struct sw_flow_key key;
-	struct sw_flow *flow;
+	struct sw_flow_key key, masked_key;
+	struct sw_flow *flow = NULL;
+	struct sw_flow_mask mask;
 	struct sk_buff *reply;
 	struct datapath *dp;
 	struct flow_table *table;
 	struct sw_flow_actions *acts = NULL;
+	struct sw_flow_match match;
 	int error;
-	int key_len;
 
 	/* Extract key. */
 	error = -EINVAL;
 	if (!a[OVS_FLOW_ATTR_KEY])
 		goto error;
-	error = ovs_flow_from_nlattrs(&key, &key_len, a[OVS_FLOW_ATTR_KEY]);
+
+	ovs_match_init(&match, &key, &mask);
+	error = ovs_match_from_nlattrs(&match,
+			a[OVS_FLOW_ATTR_KEY], a[OVS_FLOW_ATTR_MASK]);
 	if (error)
 		goto error;
 
@@ -1238,9 +1260,13 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 		if (IS_ERR(acts))
 			goto error;
 
-		error = validate_and_copy_actions(a[OVS_FLOW_ATTR_ACTIONS], &key,  0, &acts);
-		if (error)
+		ovs_flow_key_mask(&masked_key, &key, &mask);
+		error = validate_and_copy_actions(a[OVS_FLOW_ATTR_ACTIONS],
+						  &masked_key, 0, &acts);
+		if (error) {
+			OVS_NLERR("Flow actions may not be safe on all matching packets.\n");
 			goto err_kfree;
+		}
 	} else if (info->genlhdr->cmd == OVS_FLOW_CMD_NEW) {
 		error = -EINVAL;
 		goto error;
@@ -1253,8 +1279,11 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 		goto err_unlock_ovs;
 
 	table = ovsl_dereference(dp->table);
-	flow = ovs_flow_tbl_lookup(table, &key, key_len);
+
+	/* Check if this is a duplicate flow */
+	flow = ovs_flow_lookup(table, &key);
 	if (!flow) {
+		struct sw_flow_mask *mask_p;
 		/* Bail out if we're not allowed to create a new flow. */
 		error = -ENOENT;
 		if (info->genlhdr->cmd == OVS_FLOW_CMD_SET)
@@ -1267,7 +1296,7 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 			new_table = ovs_flow_tbl_expand(table);
 			if (!IS_ERR(new_table)) {
 				rcu_assign_pointer(dp->table, new_table);
-				ovs_flow_tbl_deferred_destroy(table);
+				ovs_flow_tbl_destroy(table, true);
 				table = ovsl_dereference(dp->table);
 			}
 		}
@@ -1280,14 +1309,30 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 		}
 		clear_stats(flow);
 
+		flow->key = masked_key;
+		flow->unmasked_key = key;
+
+		/* Make sure mask is unique in the system */
+		mask_p = ovs_sw_flow_mask_find(table, &mask);
+		if (!mask_p) {
+			/* Allocate a new mask if none exsits. */
+			mask_p = ovs_sw_flow_mask_alloc();
+			if (!mask_p)
+				goto err_flow_free;
+			mask_p->key = mask.key;
+			mask_p->range = mask.range;
+			ovs_sw_flow_mask_insert(table, mask_p);
+		}
+
+		ovs_sw_flow_mask_add_ref(mask_p);
+		flow->mask = mask_p;
 		rcu_assign_pointer(flow->sf_acts, acts);
 
 		/* Put flow in bucket. */
-		ovs_flow_tbl_insert(table, flow, &key, key_len);
+		ovs_flow_insert(table, flow);
 
 		reply = ovs_flow_cmd_build_info(flow, dp, info->snd_portid,
-						info->snd_seq,
-						OVS_FLOW_CMD_NEW);
+						info->snd_seq, OVS_FLOW_CMD_NEW);
 	} else {
 		/* We found a matching flow. */
 		struct sw_flow_actions *old_acts;
@@ -1303,6 +1348,13 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 		    info->nlhdr->nlmsg_flags & (NLM_F_CREATE | NLM_F_EXCL))
 			goto err_unlock_ovs;
 
+		/* The unmasked key has to be the same for flow updates. */
+		error = -EINVAL;
+		if (!ovs_flow_cmp_unmasked_key(flow, &key, match.range.end)) {
+			OVS_NLERR("Flow modification message rejected, unmasked key does not match.\n");
+			goto err_unlock_ovs;
+		}
+
 		/* Update actions. */
 		old_acts = ovsl_dereference(flow->sf_acts);
 		rcu_assign_pointer(flow->sf_acts, acts);
@@ -1327,6 +1379,8 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 				ovs_dp_flow_multicast_group.id, PTR_ERR(reply));
 	return 0;
 
+err_flow_free:
+	ovs_flow_free(flow, false);
 err_unlock_ovs:
 	ovs_unlock();
 err_kfree:
@@ -1344,12 +1398,16 @@ static int ovs_flow_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	struct sw_flow *flow;
 	struct datapath *dp;
 	struct flow_table *table;
+	struct sw_flow_match match;
 	int err;
-	int key_len;
 
-	if (!a[OVS_FLOW_ATTR_KEY])
+	if (!a[OVS_FLOW_ATTR_KEY]) {
+		OVS_NLERR("Flow get message rejected, Key attribute missing.\n");
 		return -EINVAL;
-	err = ovs_flow_from_nlattrs(&key, &key_len, a[OVS_FLOW_ATTR_KEY]);
+	}
+
+	ovs_match_init(&match, &key, NULL);
+	err = ovs_match_from_nlattrs(&match, a[OVS_FLOW_ATTR_KEY], NULL);
 	if (err)
 		return err;
 
@@ -1361,7 +1419,7 @@ static int ovs_flow_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	}
 
 	table = ovsl_dereference(dp->table);
-	flow = ovs_flow_tbl_lookup(table, &key, key_len);
+	flow = ovs_flow_lookup_unmasked_key(table, &match);
 	if (!flow) {
 		err = -ENOENT;
 		goto unlock;
@@ -1390,8 +1448,8 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	struct sw_flow *flow;
 	struct datapath *dp;
 	struct flow_table *table;
+	struct sw_flow_match match;
 	int err;
-	int key_len;
 
 	ovs_lock();
 	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
@@ -1404,12 +1462,14 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 		err = flush_flows(dp);
 		goto unlock;
 	}
-	err = ovs_flow_from_nlattrs(&key, &key_len, a[OVS_FLOW_ATTR_KEY]);
+
+	ovs_match_init(&match, &key, NULL);
+	err = ovs_match_from_nlattrs(&match, a[OVS_FLOW_ATTR_KEY], NULL);
 	if (err)
 		goto unlock;
 
 	table = ovsl_dereference(dp->table);
-	flow = ovs_flow_tbl_lookup(table, &key, key_len);
+	flow = ovs_flow_lookup_unmasked_key(table, &match);
 	if (!flow) {
 		err = -ENOENT;
 		goto unlock;
@@ -1421,13 +1481,13 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 		goto unlock;
 	}
 
-	ovs_flow_tbl_remove(table, flow);
+	ovs_flow_remove(table, flow);
 
 	err = ovs_flow_cmd_fill_info(flow, dp, reply, info->snd_portid,
 				     info->snd_seq, 0, OVS_FLOW_CMD_DEL);
 	BUG_ON(err < 0);
 
-	ovs_flow_deferred_free(flow);
+	ovs_flow_free(flow, true);
 	ovs_unlock();
 
 	ovs_notify(reply, info, &ovs_dp_flow_multicast_group);
@@ -1457,7 +1517,7 @@ static int ovs_flow_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 
 		bucket = cb->args[0];
 		obj = cb->args[1];
-		flow = ovs_flow_tbl_next(table, &bucket, &obj);
+		flow = ovs_flow_dump_next(table, &bucket, &obj);
 		if (!flow)
 			break;
 
@@ -1680,7 +1740,7 @@ err_destroy_ports_array:
 err_destroy_percpu:
 	free_percpu(dp->stats_percpu);
 err_destroy_table:
-	ovs_flow_tbl_destroy(ovsl_dereference(dp->table));
+	ovs_flow_tbl_destroy(ovsl_dereference(dp->table), false);
 err_free_dp:
 	release_net(ovs_dp_get_net(dp));
 	kfree(dp);
@@ -2287,7 +2347,7 @@ static void rehash_flow_table(struct work_struct *work)
 			new_table = ovs_flow_tbl_rehash(old_table);
 			if (!IS_ERR(new_table)) {
 				rcu_assign_pointer(dp->table, new_table);
-				ovs_flow_tbl_deferred_destroy(old_table);
+				ovs_flow_tbl_destroy(old_table, true);
 			}
 		}
 	}
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index a914864..4d109c1 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -88,11 +88,13 @@ struct datapath {
 /**
  * struct ovs_skb_cb - OVS data in skb CB
  * @flow: The flow associated with this packet.  May be %NULL if no flow.
+ * @pkt_key: The flow information extracted from the packet.  Must be nonnull.
  * @tun_key: Key for the tunnel that encapsulated this packet. NULL if the
  * packet is not being tunneled.
  */
 struct ovs_skb_cb {
 	struct sw_flow		*flow;
+	struct sw_flow_key	*pkt_key;
 	struct ovs_key_ipv4_tunnel  *tun_key;
 };
 #define OVS_CB(skb) ((struct ovs_skb_cb *)(skb)->cb)
@@ -183,4 +185,8 @@ struct sk_buff *ovs_vport_cmd_build_info(struct vport *, u32 pid, u32 seq,
 
 int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb);
 void ovs_dp_notify_wq(struct work_struct *work);
+
+#define OVS_NLERR(fmt, ...) \
+	pr_info_once("netlink: " fmt, ##__VA_ARGS__)
+
 #endif /* datapath.h */
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index fca2825..1fceb96 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2007-2011 Nicira, Inc.
+ * Copyright (c) 2007-2013 Nicira, Inc.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
@@ -46,6 +46,184 @@
 
 static struct kmem_cache *flow_cache;
 
+static void ovs_sw_flow_mask_set(struct sw_flow_mask *mask,
+		struct sw_flow_key_range *range, u8 val);
+
+static void update_range__(struct sw_flow_match *match,
+			  size_t offset, size_t size, bool is_mask)
+{
+	struct sw_flow_key_range *range = NULL;
+	size_t start = offset;
+	size_t end = offset + size;
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
+static bool ovs_match_validate(const struct sw_flow_match *match,
+		u64 key_attrs, u64 mask_attrs)
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
 static int check_header(struct sk_buff *skb, int len)
 {
 	if (unlikely(skb->len < len))
@@ -121,12 +299,7 @@ u64 ovs_flow_used_time(unsigned long flow_jiffies)
 	return cur_ms - idle_ms;
 }
 
-#define SW_FLOW_KEY_OFFSET(field)		\
-	(offsetof(struct sw_flow_key, field) +	\
-	 FIELD_SIZEOF(struct sw_flow_key, field))
-
-static int parse_ipv6hdr(struct sk_buff *skb, struct sw_flow_key *key,
-			 int *key_lenp)
+static int parse_ipv6hdr(struct sk_buff *skb, struct sw_flow_key *key)
 {
 	unsigned int nh_ofs = skb_network_offset(skb);
 	unsigned int nh_len;
@@ -136,8 +309,6 @@ static int parse_ipv6hdr(struct sk_buff *skb, struct sw_flow_key *key,
 	__be16 frag_off;
 	int err;
 
-	*key_lenp = SW_FLOW_KEY_OFFSET(ipv6.label);
-
 	err = check_header(skb, nh_ofs + sizeof(*nh));
 	if (unlikely(err))
 		return err;
@@ -176,6 +347,21 @@ static bool icmp6hdr_ok(struct sk_buff *skb)
 				  sizeof(struct icmp6hdr));
 }
 
+void ovs_flow_key_mask(struct sw_flow_key *dst, const struct sw_flow_key *src,
+		       const struct sw_flow_mask *mask)
+{
+	u8 *m = (u8 *)&mask->key + mask->range.start;
+	u8 *s = (u8 *)src + mask->range.start;
+	u8 *d = (u8 *)dst + mask->range.start;
+	int i;
+
+	memset(dst, 0, sizeof(*dst));
+	for (i = 0; i < ovs_sw_flow_mask_size_roundup(mask); i++) {
+		*d = *s & *m;
+		d++, s++, m++;
+	}
+}
+
 #define TCP_FLAGS_OFFSET 13
 #define TCP_FLAG_MASK 0x3f
 
@@ -224,6 +410,7 @@ struct sw_flow *ovs_flow_alloc(void)
 
 	spin_lock_init(&flow->lock);
 	flow->sf_acts = NULL;
+	flow->mask = NULL;
 
 	return flow;
 }
@@ -263,7 +450,7 @@ static void free_buckets(struct flex_array *buckets)
 	flex_array_free(buckets);
 }
 
-struct flow_table *ovs_flow_tbl_alloc(int new_size)
+static struct flow_table *__flow_tbl_alloc(int new_size)
 {
 	struct flow_table *table = kmalloc(sizeof(*table), GFP_KERNEL);
 
@@ -281,17 +468,15 @@ struct flow_table *ovs_flow_tbl_alloc(int new_size)
 	table->node_ver = 0;
 	table->keep_flows = false;
 	get_random_bytes(&table->hash_seed, sizeof(u32));
+	table->mask_list = NULL;
 
 	return table;
 }
 
-void ovs_flow_tbl_destroy(struct flow_table *table)
+static void __flow_tbl_destroy(struct flow_table *table)
 {
 	int i;
 
-	if (!table)
-		return;
-
 	if (table->keep_flows)
 		goto skip_flows;
 
@@ -303,31 +488,55 @@ void ovs_flow_tbl_destroy(struct flow_table *table)
 
 		hlist_for_each_entry_safe(flow, n, head, hash_node[ver]) {
 			hlist_del(&flow->hash_node[ver]);
-			ovs_flow_free(flow);
+			ovs_flow_free(flow, false);
 		}
 	}
 
+	BUG_ON(!list_empty(table->mask_list));
+	kfree(table->mask_list);
+
 skip_flows:
 	free_buckets(table->buckets);
 	kfree(table);
 }
 
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
 static void flow_tbl_destroy_rcu_cb(struct rcu_head *rcu)
 {
 	struct flow_table *table = container_of(rcu, struct flow_table, rcu);
 
-	ovs_flow_tbl_destroy(table);
+	__flow_tbl_destroy(table);
 }
 
-void ovs_flow_tbl_deferred_destroy(struct flow_table *table)
+void ovs_flow_tbl_destroy(struct flow_table *table, bool deferred)
 {
 	if (!table)
 		return;
 
-	call_rcu(&table->rcu, flow_tbl_destroy_rcu_cb);
+	if (deferred)
+		call_rcu(&table->rcu, flow_tbl_destroy_rcu_cb);
+	else
+		__flow_tbl_destroy(table);
 }
 
-struct sw_flow *ovs_flow_tbl_next(struct flow_table *table, u32 *bucket, u32 *last)
+struct sw_flow *ovs_flow_dump_next(struct flow_table *table, u32 *bucket, u32 *last)
 {
 	struct sw_flow *flow;
 	struct hlist_head *head;
@@ -353,11 +562,13 @@ struct sw_flow *ovs_flow_tbl_next(struct flow_table *table, u32 *bucket, u32 *la
 	return NULL;
 }
 
-static void __flow_tbl_insert(struct flow_table *table, struct sw_flow *flow)
+static void __tbl_insert(struct flow_table *table, struct sw_flow *flow)
 {
 	struct hlist_head *head;
+
 	head = find_bucket(table, flow->hash);
 	hlist_add_head_rcu(&flow->hash_node[table->node_ver], head);
+
 	table->count++;
 }
 
@@ -377,8 +588,10 @@ static void flow_table_copy_flows(struct flow_table *old, struct flow_table *new
 		head = flex_array_get(old->buckets, i);
 
 		hlist_for_each_entry(flow, head, hash_node[old_ver])
-			__flow_tbl_insert(new, flow);
+			__tbl_insert(new, flow);
 	}
+
+	new->mask_list = old->mask_list;
 	old->keep_flows = true;
 }
 
@@ -386,7 +599,7 @@ static struct flow_table *__flow_tbl_rehash(struct flow_table *table, int n_buck
 {
 	struct flow_table *new_table;
 
-	new_table = ovs_flow_tbl_alloc(n_buckets);
+	new_table = __flow_tbl_alloc(n_buckets);
 	if (!new_table)
 		return ERR_PTR(-ENOMEM);
 
@@ -405,28 +618,30 @@ struct flow_table *ovs_flow_tbl_expand(struct flow_table *table)
 	return __flow_tbl_rehash(table, table->n_buckets * 2);
 }
 
-void ovs_flow_free(struct sw_flow *flow)
+static void __flow_free(struct sw_flow *flow)
 {
-	if (unlikely(!flow))
-		return;
-
 	kfree((struct sf_flow_acts __force *)flow->sf_acts);
 	kmem_cache_free(flow_cache, flow);
 }
 
-/* RCU callback used by ovs_flow_deferred_free. */
 static void rcu_free_flow_callback(struct rcu_head *rcu)
 {
 	struct sw_flow *flow = container_of(rcu, struct sw_flow, rcu);
 
-	ovs_flow_free(flow);
+	__flow_free(flow);
 }
 
-/* Schedules 'flow' to be freed after the next RCU grace period.
- * The caller must hold rcu_read_lock for this to be sensible. */
-void ovs_flow_deferred_free(struct sw_flow *flow)
+void ovs_flow_free(struct sw_flow *flow, bool deferred)
 {
-	call_rcu(&flow->rcu, rcu_free_flow_callback);
+	if (!flow)
+		return;
+
+	ovs_sw_flow_mask_del_ref(flow->mask, deferred);
+
+	if (deferred)
+		call_rcu(&flow->rcu, rcu_free_flow_callback);
+	else
+		__flow_free(flow);
 }
 
 /* Schedules 'sf_acts' to be freed after the next RCU grace period.
@@ -497,18 +712,15 @@ static __be16 parse_ethertype(struct sk_buff *skb)
 }
 
 static int parse_icmpv6(struct sk_buff *skb, struct sw_flow_key *key,
-			int *key_lenp, int nh_len)
+			int nh_len)
 {
 	struct icmp6hdr *icmp = icmp6_hdr(skb);
-	int error = 0;
-	int key_len;
 
 	/* The ICMPv6 type and code fields use the 16-bit transport port
 	 * fields, so we need to store them in 16-bit network byte order.
 	 */
 	key->ipv6.tp.src = htons(icmp->icmp6_type);
 	key->ipv6.tp.dst = htons(icmp->icmp6_code);
-	key_len = SW_FLOW_KEY_OFFSET(ipv6.tp);
 
 	if (icmp->icmp6_code == 0 &&
 	    (icmp->icmp6_type == NDISC_NEIGHBOUR_SOLICITATION ||
@@ -517,21 +729,17 @@ static int parse_icmpv6(struct sk_buff *skb, struct sw_flow_key *key,
 		struct nd_msg *nd;
 		int offset;
 
-		key_len = SW_FLOW_KEY_OFFSET(ipv6.nd);
-
 		/* In order to process neighbor discovery options, we need the
 		 * entire packet.
 		 */
 		if (unlikely(icmp_len < sizeof(*nd)))
-			goto out;
-		if (unlikely(skb_linearize(skb))) {
-			error = -ENOMEM;
-			goto out;
-		}
+			return 0;
+
+		if (unlikely(skb_linearize(skb)))
+			return -ENOMEM;
 
 		nd = (struct nd_msg *)skb_transport_header(skb);
 		key->ipv6.nd.target = nd->target;
-		key_len = SW_FLOW_KEY_OFFSET(ipv6.nd);
 
 		icmp_len -= sizeof(*nd);
 		offset = 0;
@@ -541,7 +749,7 @@ static int parse_icmpv6(struct sk_buff *skb, struct sw_flow_key *key,
 			int opt_len = nd_opt->nd_opt_len * 8;
 
 			if (unlikely(!opt_len || opt_len > icmp_len))
-				goto invalid;
+				return 0;
 
 			/* Store the link layer address if the appropriate
 			 * option is provided.  It is considered an error if
@@ -566,16 +774,14 @@ static int parse_icmpv6(struct sk_buff *skb, struct sw_flow_key *key,
 		}
 	}
 
-	goto out;
+	return 0;
 
 invalid:
 	memset(&key->ipv6.nd.target, 0, sizeof(key->ipv6.nd.target));
 	memset(key->ipv6.nd.sll, 0, sizeof(key->ipv6.nd.sll));
 	memset(key->ipv6.nd.tll, 0, sizeof(key->ipv6.nd.tll));
 
-out:
-	*key_lenp = key_len;
-	return error;
+	return 0;
 }
 
 /**
@@ -584,7 +790,6 @@ out:
  * Ethernet header
  * @in_port: port number on which @skb was received.
  * @key: output flow key
- * @key_lenp: length of output flow key
  *
  * The caller must ensure that skb->len >= ETH_HLEN.
  *
@@ -602,11 +807,9 @@ out:
  *      of a correct length, otherwise the same as skb->network_header.
  *      For other key->eth.type values it is left untouched.
  */
-int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key,
-		 int *key_lenp)
+int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key)
 {
-	int error = 0;
-	int key_len = SW_FLOW_KEY_OFFSET(eth);
+	int error;
 	struct ethhdr *eth;
 
 	memset(key, 0, sizeof(*key));
@@ -649,15 +852,13 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key,
 		struct iphdr *nh;
 		__be16 offset;
 
-		key_len = SW_FLOW_KEY_OFFSET(ipv4.addr);
-
 		error = check_iphdr(skb);
 		if (unlikely(error)) {
 			if (error == -EINVAL) {
 				skb->transport_header = skb->network_header;
 				error = 0;
 			}
-			goto out;
+			return error;
 		}
 
 		nh = ip_hdr(skb);
@@ -671,7 +872,7 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key,
 		offset = nh->frag_off & htons(IP_OFFSET);
 		if (offset) {
 			key->ip.frag = OVS_FRAG_TYPE_LATER;
-			goto out;
+			return 0;
 		}
 		if (nh->frag_off & htons(IP_MF) ||
 			 skb_shinfo(skb)->gso_type & SKB_GSO_UDP)
@@ -679,21 +880,18 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key,
 
 		/* Transport layer. */
 		if (key->ip.proto == IPPROTO_TCP) {
-			key_len = SW_FLOW_KEY_OFFSET(ipv4.tp);
 			if (tcphdr_ok(skb)) {
 				struct tcphdr *tcp = tcp_hdr(skb);
 				key->ipv4.tp.src = tcp->source;
 				key->ipv4.tp.dst = tcp->dest;
 			}
 		} else if (key->ip.proto == IPPROTO_UDP) {
-			key_len = SW_FLOW_KEY_OFFSET(ipv4.tp);
 			if (udphdr_ok(skb)) {
 				struct udphdr *udp = udp_hdr(skb);
 				key->ipv4.tp.src = udp->source;
 				key->ipv4.tp.dst = udp->dest;
 			}
 		} else if (key->ip.proto == IPPROTO_ICMP) {
-			key_len = SW_FLOW_KEY_OFFSET(ipv4.tp);
 			if (icmphdr_ok(skb)) {
 				struct icmphdr *icmp = icmp_hdr(skb);
 				/* The ICMP type and code fields use the 16-bit
@@ -722,53 +920,49 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key,
 			memcpy(&key->ipv4.addr.dst, arp->ar_tip, sizeof(key->ipv4.addr.dst));
 			memcpy(key->ipv4.arp.sha, arp->ar_sha, ETH_ALEN);
 			memcpy(key->ipv4.arp.tha, arp->ar_tha, ETH_ALEN);
-			key_len = SW_FLOW_KEY_OFFSET(ipv4.arp);
 		}
 	} else if (key->eth.type == htons(ETH_P_IPV6)) {
 		int nh_len;             /* IPv6 Header + Extensions */
 
-		nh_len = parse_ipv6hdr(skb, key, &key_len);
+		nh_len = parse_ipv6hdr(skb, key);
 		if (unlikely(nh_len < 0)) {
-			if (nh_len == -EINVAL)
+			if (nh_len == -EINVAL) {
 				skb->transport_header = skb->network_header;
-			else
+				error = 0;
+			} else {
 				error = nh_len;
-			goto out;
+			}
+			return error;
 		}
 
 		if (key->ip.frag == OVS_FRAG_TYPE_LATER)
-			goto out;
+			return 0;
 		if (skb_shinfo(skb)->gso_type & SKB_GSO_UDP)
 			key->ip.frag = OVS_FRAG_TYPE_FIRST;
 
 		/* Transport layer. */
 		if (key->ip.proto == NEXTHDR_TCP) {
-			key_len = SW_FLOW_KEY_OFFSET(ipv6.tp);
 			if (tcphdr_ok(skb)) {
 				struct tcphdr *tcp = tcp_hdr(skb);
 				key->ipv6.tp.src = tcp->source;
 				key->ipv6.tp.dst = tcp->dest;
 			}
 		} else if (key->ip.proto == NEXTHDR_UDP) {
-			key_len = SW_FLOW_KEY_OFFSET(ipv6.tp);
 			if (udphdr_ok(skb)) {
 				struct udphdr *udp = udp_hdr(skb);
 				key->ipv6.tp.src = udp->source;
 				key->ipv6.tp.dst = udp->dest;
 			}
 		} else if (key->ip.proto == NEXTHDR_ICMP) {
-			key_len = SW_FLOW_KEY_OFFSET(ipv6.tp);
 			if (icmp6hdr_ok(skb)) {
-				error = parse_icmpv6(skb, key, &key_len, nh_len);
-				if (error < 0)
-					goto out;
+				error = parse_icmpv6(skb, key, nh_len);
+				if (error)
+					return error;
 			}
 		}
 	}
 
-out:
-	*key_lenp = key_len;
-	return error;
+	return 0;
 }
 
 static u32 ovs_flow_hash(const struct sw_flow_key *key, int key_start, int key_len)
@@ -777,7 +971,7 @@ static u32 ovs_flow_hash(const struct sw_flow_key *key, int key_start, int key_l
 		      DIV_ROUND_UP(key_len - key_start, sizeof(u32)), 0);
 }
 
-static int flow_key_start(struct sw_flow_key *key)
+static int flow_key_start(const struct sw_flow_key *key)
 {
 	if (key->tun_key.ipv4_dst)
 		return 0;
@@ -785,39 +979,95 @@ static int flow_key_start(struct sw_flow_key *key)
 		return offsetof(struct sw_flow_key, phy);
 }
 
-struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *table,
-				struct sw_flow_key *key, int key_len)
+static bool __cmp_key(const struct sw_flow_key *key1,
+		const struct sw_flow_key *key2,  int key_start, int key_len)
+{
+	return !memcmp((u8 *)key1 + key_start,
+			(u8 *)key2 + key_start, (key_len - key_start));
+}
+
+static bool __flow_cmp_key(const struct sw_flow *flow,
+		const struct sw_flow_key *key, int key_start, int key_len)
+{
+	return __cmp_key(&flow->key, key, key_start, key_len);
+}
+
+static bool __flow_cmp_unmasked_key(const struct sw_flow *flow,
+		  const struct sw_flow_key *key, int key_start, int key_len)
+{
+	return __cmp_key(&flow->unmasked_key, key, key_start, key_len);
+}
+
+bool ovs_flow_cmp_unmasked_key(const struct sw_flow *flow,
+		const struct sw_flow_key *key, int key_len)
+{
+	int key_start;
+	key_start = flow_key_start(key);
+
+	return __flow_cmp_unmasked_key(flow, key, key_start, key_len);
+
+}
+
+struct sw_flow *ovs_flow_lookup_unmasked_key(struct flow_table *table,
+				       struct sw_flow_match *match)
+{
+	struct sw_flow_key *unmasked = match->key;
+	int key_len = match->range.end;
+	struct sw_flow *flow;
+
+	flow = ovs_flow_lookup(table, unmasked);
+	if (flow && (!ovs_flow_cmp_unmasked_key(flow, unmasked, key_len)))
+		flow = NULL;
+
+	return flow;
+}
+
+static struct sw_flow *ovs_masked_flow_lookup(struct flow_table *table,
+				    const struct sw_flow_key *flow_key,
+				    struct sw_flow_mask *mask)
 {
 	struct sw_flow *flow;
 	struct hlist_head *head;
-	u8 *_key;
-	int key_start;
+	int key_start = mask->range.start;
+	int key_len = mask->range.end;
 	u32 hash;
+	struct sw_flow_key masked_key;
 
-	key_start = flow_key_start(key);
-	hash = ovs_flow_hash(key, key_start, key_len);
-
-	_key = (u8 *) key + key_start;
+	ovs_flow_key_mask(&masked_key, flow_key, mask);
+	hash = ovs_flow_hash(&masked_key, key_start, key_len);
 	head = find_bucket(table, hash);
 	hlist_for_each_entry_rcu(flow, head, hash_node[table->node_ver]) {
-
-		if (flow->hash == hash &&
-		    !memcmp((u8 *)&flow->key + key_start, _key, key_len - key_start)) {
+		if (flow->mask == mask &&
+		    __flow_cmp_key(flow, &masked_key, key_start, key_len))
 			return flow;
-		}
 	}
 	return NULL;
 }
 
-void ovs_flow_tbl_insert(struct flow_table *table, struct sw_flow *flow,
-			 struct sw_flow_key *key, int key_len)
+struct sw_flow *ovs_flow_lookup(struct flow_table *tbl,
+				const struct sw_flow_key *key)
 {
-	flow->hash = ovs_flow_hash(key, flow_key_start(key), key_len);
-	memcpy(&flow->key, key, sizeof(flow->key));
-	__flow_tbl_insert(table, flow);
+	struct sw_flow *flow = NULL;
+	struct sw_flow_mask *mask;
+
+	list_for_each_entry_rcu(mask, tbl->mask_list, list) {
+		flow = ovs_masked_flow_lookup(tbl, key, mask);
+		if (flow)  /* Found */
+			break;
+	}
+
+	return flow;
 }
 
-void ovs_flow_tbl_remove(struct flow_table *table, struct sw_flow *flow)
+
+void ovs_flow_insert(struct flow_table *table, struct sw_flow *flow)
+{
+	flow->hash = ovs_flow_hash(&flow->key, flow->mask->range.start,
+			flow->mask->range.end);
+	__tbl_insert(table, flow);
+}
+
+void ovs_flow_remove(struct flow_table *table, struct sw_flow *flow)
 {
 	BUG_ON(table->count == 0);
 	hlist_del_rcu(&flow->hash_node[table->node_ver]);
@@ -844,149 +1094,84 @@ const int ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
 	[OVS_KEY_ATTR_TUNNEL] = -1,
 };
 
-static int ipv4_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_len,
-				  const struct nlattr *a[], u32 *attrs)
-{
-	const struct ovs_key_icmp *icmp_key;
-	const struct ovs_key_tcp *tcp_key;
-	const struct ovs_key_udp *udp_key;
-
-	switch (swkey->ip.proto) {
-	case IPPROTO_TCP:
-		if (!(*attrs & (1 << OVS_KEY_ATTR_TCP)))
-			return -EINVAL;
-		*attrs &= ~(1 << OVS_KEY_ATTR_TCP);
-
-		*key_len = SW_FLOW_KEY_OFFSET(ipv4.tp);
-		tcp_key = nla_data(a[OVS_KEY_ATTR_TCP]);
-		swkey->ipv4.tp.src = tcp_key->tcp_src;
-		swkey->ipv4.tp.dst = tcp_key->tcp_dst;
-		break;
-
-	case IPPROTO_UDP:
-		if (!(*attrs & (1 << OVS_KEY_ATTR_UDP)))
-			return -EINVAL;
-		*attrs &= ~(1 << OVS_KEY_ATTR_UDP);
-
-		*key_len = SW_FLOW_KEY_OFFSET(ipv4.tp);
-		udp_key = nla_data(a[OVS_KEY_ATTR_UDP]);
-		swkey->ipv4.tp.src = udp_key->udp_src;
-		swkey->ipv4.tp.dst = udp_key->udp_dst;
-		break;
-
-	case IPPROTO_ICMP:
-		if (!(*attrs & (1 << OVS_KEY_ATTR_ICMP)))
-			return -EINVAL;
-		*attrs &= ~(1 << OVS_KEY_ATTR_ICMP);
-
-		*key_len = SW_FLOW_KEY_OFFSET(ipv4.tp);
-		icmp_key = nla_data(a[OVS_KEY_ATTR_ICMP]);
-		swkey->ipv4.tp.src = htons(icmp_key->icmp_type);
-		swkey->ipv4.tp.dst = htons(icmp_key->icmp_code);
-		break;
-	}
-
-	return 0;
-}
-
-static int ipv6_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_len,
-				  const struct nlattr *a[], u32 *attrs)
+static bool is_all_zero(const u8 *fp, size_t size)
 {
-	const struct ovs_key_icmpv6 *icmpv6_key;
-	const struct ovs_key_tcp *tcp_key;
-	const struct ovs_key_udp *udp_key;
-
-	switch (swkey->ip.proto) {
-	case IPPROTO_TCP:
-		if (!(*attrs & (1 << OVS_KEY_ATTR_TCP)))
-			return -EINVAL;
-		*attrs &= ~(1 << OVS_KEY_ATTR_TCP);
-
-		*key_len = SW_FLOW_KEY_OFFSET(ipv6.tp);
-		tcp_key = nla_data(a[OVS_KEY_ATTR_TCP]);
-		swkey->ipv6.tp.src = tcp_key->tcp_src;
-		swkey->ipv6.tp.dst = tcp_key->tcp_dst;
-		break;
-
-	case IPPROTO_UDP:
-		if (!(*attrs & (1 << OVS_KEY_ATTR_UDP)))
-			return -EINVAL;
-		*attrs &= ~(1 << OVS_KEY_ATTR_UDP);
-
-		*key_len = SW_FLOW_KEY_OFFSET(ipv6.tp);
-		udp_key = nla_data(a[OVS_KEY_ATTR_UDP]);
-		swkey->ipv6.tp.src = udp_key->udp_src;
-		swkey->ipv6.tp.dst = udp_key->udp_dst;
-		break;
-
-	case IPPROTO_ICMPV6:
-		if (!(*attrs & (1 << OVS_KEY_ATTR_ICMPV6)))
-			return -EINVAL;
-		*attrs &= ~(1 << OVS_KEY_ATTR_ICMPV6);
-
-		*key_len = SW_FLOW_KEY_OFFSET(ipv6.tp);
-		icmpv6_key = nla_data(a[OVS_KEY_ATTR_ICMPV6]);
-		swkey->ipv6.tp.src = htons(icmpv6_key->icmpv6_type);
-		swkey->ipv6.tp.dst = htons(icmpv6_key->icmpv6_code);
+	int i;
 
-		if (swkey->ipv6.tp.src == htons(NDISC_NEIGHBOUR_SOLICITATION) ||
-		    swkey->ipv6.tp.src == htons(NDISC_NEIGHBOUR_ADVERTISEMENT)) {
-			const struct ovs_key_nd *nd_key;
+	if (!fp)
+		return false;
 
-			if (!(*attrs & (1 << OVS_KEY_ATTR_ND)))
-				return -EINVAL;
-			*attrs &= ~(1 << OVS_KEY_ATTR_ND);
-
-			*key_len = SW_FLOW_KEY_OFFSET(ipv6.nd);
-			nd_key = nla_data(a[OVS_KEY_ATTR_ND]);
-			memcpy(&swkey->ipv6.nd.target, nd_key->nd_target,
-			       sizeof(swkey->ipv6.nd.target));
-			memcpy(swkey->ipv6.nd.sll, nd_key->nd_sll, ETH_ALEN);
-			memcpy(swkey->ipv6.nd.tll, nd_key->nd_tll, ETH_ALEN);
-		}
-		break;
-	}
+	for (i = 0; i < size; i++)
+		if (fp[i])
+			return false;
 
-	return 0;
+	return true;
 }
 
-static int parse_flow_nlattrs(const struct nlattr *attr,
-			      const struct nlattr *a[], u32 *attrsp)
+static int __parse_flow_nlattrs(const struct nlattr *attr,
+			      const struct nlattr *a[],
+			      u64 *attrsp, bool nz)
 {
 	const struct nlattr *nla;
 	u32 attrs;
 	int rem;
 
-	attrs = 0;
+	attrs = *attrsp;
 	nla_for_each_nested(nla, attr, rem) {
 		u16 type = nla_type(nla);
 		int expected_len;
 
-		if (type > OVS_KEY_ATTR_MAX || attrs & (1 << type))
+		if (type > OVS_KEY_ATTR_MAX) {
+			OVS_NLERR("Unknown key attribute (type=%d, max=%d).\n",
+				  type, OVS_KEY_ATTR_MAX);
+		}
+
+		if (attrs & (1 << type)) {
+			OVS_NLERR("Duplicate key attribute (type %d).\n", type);
 			return -EINVAL;
+		}
 
 		expected_len = ovs_key_lens[type];
-		if (nla_len(nla) != expected_len && expected_len != -1)
+		if (nla_len(nla) != expected_len && expected_len != -1) {
+			OVS_NLERR("Key attribute has unexpected length (type=%d"
+				  ", length=%d, expected=%d).\n", type,
+				  nla_len(nla), expected_len);
 			return -EINVAL;
+		}
 
-		attrs |= 1 << type;
-		a[type] = nla;
+		if (!nz || !is_all_zero(nla_data(nla), expected_len)) {
+			attrs |= 1 << type;
+			a[type] = nla;
+		}
 	}
-	if (rem)
+	if (rem) {
+		OVS_NLERR("Message has %d unknown bytes.\n", rem);
 		return -EINVAL;
+	}
 
 	*attrsp = attrs;
 	return 0;
 }
 
+static int parse_flow_mask_nlattrs(const struct nlattr *attr,
+			      const struct nlattr *a[], u64 *attrsp)
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
 int ovs_ipv4_tun_from_nlattr(const struct nlattr *attr,
-			     struct ovs_key_ipv4_tunnel *tun_key)
+			     struct sw_flow_match *match, bool is_mask)
 {
 	struct nlattr *a;
 	int rem;
 	bool ttl = false;
-
-	memset(tun_key, 0, sizeof(*tun_key));
+	__be16 tun_flags = 0;
 
 	nla_for_each_nested(a, attr, rem) {
 		int type = nla_type(a);
@@ -1000,53 +1185,78 @@ int ovs_ipv4_tun_from_nlattr(const struct nlattr *attr,
 			[OVS_TUNNEL_KEY_ATTR_CSUM] = 0,
 		};
 
-		if (type > OVS_TUNNEL_KEY_ATTR_MAX ||
-			ovs_tunnel_key_lens[type] != nla_len(a))
+		if (type > OVS_TUNNEL_KEY_ATTR_MAX) {
+			OVS_NLERR("Unknown IPv4 tunnel attribute (type=%d, max=%d).\n",
+			type, OVS_TUNNEL_KEY_ATTR_MAX);
 			return -EINVAL;
+		}
+
+		if (ovs_tunnel_key_lens[type] != nla_len(a)) {
+			OVS_NLERR("IPv4 tunnel attribute type has unexpected "
+				  " length (type=%d, length=%d, expected=%d).\n",
+				  type, nla_len(a), ovs_tunnel_key_lens[type]);
+			return -EINVAL;
+		}
 
 		switch (type) {
 		case OVS_TUNNEL_KEY_ATTR_ID:
-			tun_key->tun_id = nla_get_be64(a);
-			tun_key->tun_flags |= TUNNEL_KEY;
+			SW_FLOW_KEY_PUT(match, tun_key.tun_id,
+					nla_get_be64(a), is_mask);
+			tun_flags |= TUNNEL_KEY;
 			break;
 		case OVS_TUNNEL_KEY_ATTR_IPV4_SRC:
-			tun_key->ipv4_src = nla_get_be32(a);
+			SW_FLOW_KEY_PUT(match, tun_key.ipv4_src,
+					nla_get_be32(a), is_mask);
 			break;
 		case OVS_TUNNEL_KEY_ATTR_IPV4_DST:
-			tun_key->ipv4_dst = nla_get_be32(a);
+			SW_FLOW_KEY_PUT(match, tun_key.ipv4_dst,
+					nla_get_be32(a), is_mask);
 			break;
 		case OVS_TUNNEL_KEY_ATTR_TOS:
-			tun_key->ipv4_tos = nla_get_u8(a);
+			SW_FLOW_KEY_PUT(match, tun_key.ipv4_tos,
+					nla_get_u8(a), is_mask);
 			break;
 		case OVS_TUNNEL_KEY_ATTR_TTL:
-			tun_key->ipv4_ttl = nla_get_u8(a);
+			SW_FLOW_KEY_PUT(match, tun_key.ipv4_ttl,
+					nla_get_u8(a), is_mask);
 			ttl = true;
 			break;
 		case OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT:
-			tun_key->tun_flags |= TUNNEL_DONT_FRAGMENT;
+			tun_flags |= TUNNEL_DONT_FRAGMENT;
 			break;
 		case OVS_TUNNEL_KEY_ATTR_CSUM:
-			tun_key->tun_flags |= TUNNEL_CSUM;
+			tun_flags |= TUNNEL_CSUM;
 			break;
 		default:
 			return -EINVAL;
-
 		}
 	}
-	if (rem > 0)
-		return -EINVAL;
 
-	if (!tun_key->ipv4_dst)
-		return -EINVAL;
+	SW_FLOW_KEY_PUT(match, tun_key.tun_flags, tun_flags, is_mask);
 
-	if (!ttl)
+	if (rem > 0) {
+		OVS_NLERR("IPv4 tunnel attribute has %d unknown bytes.\n", rem);
 		return -EINVAL;
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
 
 	return 0;
 }
 
 int ovs_ipv4_tun_to_nlattr(struct sk_buff *skb,
-			   const struct ovs_key_ipv4_tunnel *tun_key)
+			   const struct ovs_key_ipv4_tunnel *tun_key,
+			   const struct ovs_key_ipv4_tunnel *output)
 {
 	struct nlattr *nla;
 
@@ -1054,23 +1264,24 @@ int ovs_ipv4_tun_to_nlattr(struct sk_buff *skb,
 	if (!nla)
 		return -EMSGSIZE;
 
-	if (tun_key->tun_flags & TUNNEL_KEY &&
-	    nla_put_be64(skb, OVS_TUNNEL_KEY_ATTR_ID, tun_key->tun_id))
+	if (output->tun_flags & TUNNEL_KEY &&
+	    nla_put_be64(skb, OVS_TUNNEL_KEY_ATTR_ID, output->tun_id))
 		return -EMSGSIZE;
-	if (tun_key->ipv4_src &&
-	    nla_put_be32(skb, OVS_TUNNEL_KEY_ATTR_IPV4_SRC, tun_key->ipv4_src))
+	if (output->ipv4_src &&
+		nla_put_be32(skb, OVS_TUNNEL_KEY_ATTR_IPV4_SRC, output->ipv4_src))
 		return -EMSGSIZE;
-	if (nla_put_be32(skb, OVS_TUNNEL_KEY_ATTR_IPV4_DST, tun_key->ipv4_dst))
+	if (output->ipv4_dst &&
+		nla_put_be32(skb, OVS_TUNNEL_KEY_ATTR_IPV4_DST, output->ipv4_dst))
 		return -EMSGSIZE;
-	if (tun_key->ipv4_tos &&
-	    nla_put_u8(skb, OVS_TUNNEL_KEY_ATTR_TOS, tun_key->ipv4_tos))
+	if (output->ipv4_tos &&
+		nla_put_u8(skb, OVS_TUNNEL_KEY_ATTR_TOS, output->ipv4_tos))
 		return -EMSGSIZE;
-	if (nla_put_u8(skb, OVS_TUNNEL_KEY_ATTR_TTL, tun_key->ipv4_ttl))
+	if (nla_put_u8(skb, OVS_TUNNEL_KEY_ATTR_TTL, output->ipv4_ttl))
 		return -EMSGSIZE;
-	if ((tun_key->tun_flags & TUNNEL_DONT_FRAGMENT) &&
+	if ((output->tun_flags & TUNNEL_DONT_FRAGMENT) &&
 		nla_put_flag(skb, OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT))
 		return -EMSGSIZE;
-	if ((tun_key->tun_flags & TUNNEL_CSUM) &&
+	if ((output->tun_flags & TUNNEL_CSUM) &&
 		nla_put_flag(skb, OVS_TUNNEL_KEY_ATTR_CSUM))
 		return -EMSGSIZE;
 
@@ -1078,176 +1289,372 @@ int ovs_ipv4_tun_to_nlattr(struct sk_buff *skb,
 	return 0;
 }
 
-/**
- * ovs_flow_from_nlattrs - parses Netlink attributes into a flow key.
- * @swkey: receives the extracted flow key.
- * @key_lenp: number of bytes used in @swkey.
- * @attr: Netlink attribute holding nested %OVS_KEY_ATTR_* Netlink attribute
- * sequence.
- */
-int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
-		      const struct nlattr *attr)
+static int metadata_from_nlattrs(struct sw_flow_match *match,  u64 *attrs,
+		const struct nlattr **a, bool is_mask)
 {
-	const struct nlattr *a[OVS_KEY_ATTR_MAX + 1];
-	const struct ovs_key_ethernet *eth_key;
-	int key_len;
-	u32 attrs;
-	int err;
+	if (*attrs & (1 << OVS_KEY_ATTR_PRIORITY)) {
+		SW_FLOW_KEY_PUT(match, phy.priority,
+			  nla_get_u32(a[OVS_KEY_ATTR_PRIORITY]), is_mask);
+		*attrs &= ~(1 << OVS_KEY_ATTR_PRIORITY);
+	}
 
-	memset(swkey, 0, sizeof(struct sw_flow_key));
-	key_len = SW_FLOW_KEY_OFFSET(eth);
+	if (*attrs & (1 << OVS_KEY_ATTR_IN_PORT)) {
+		u32 in_port = nla_get_u32(a[OVS_KEY_ATTR_IN_PORT]);
 
-	err = parse_flow_nlattrs(attr, a, &attrs);
-	if (err)
-		return err;
+		if (is_mask)
+			in_port = 0xffffffff; /* Always exact match in_port. */
+		else if (in_port >= DP_MAX_PORTS)
+			return -EINVAL;
 
-	/* Metadata attributes. */
-	if (attrs & (1 << OVS_KEY_ATTR_PRIORITY)) {
-		swkey->phy.priority = nla_get_u32(a[OVS_KEY_ATTR_PRIORITY]);
-		attrs &= ~(1 << OVS_KEY_ATTR_PRIORITY);
+		SW_FLOW_KEY_PUT(match, phy.in_port, in_port, is_mask);
+		*attrs &= ~(1 << OVS_KEY_ATTR_IN_PORT);
+	} else if (!is_mask) {
+		SW_FLOW_KEY_PUT(match, phy.in_port, DP_MAX_PORTS, is_mask);
 	}
-	if (attrs & (1 << OVS_KEY_ATTR_IN_PORT)) {
-		u32 in_port = nla_get_u32(a[OVS_KEY_ATTR_IN_PORT]);
-		if (in_port >= DP_MAX_PORTS)
-			return -EINVAL;
-		swkey->phy.in_port = in_port;
-		attrs &= ~(1 << OVS_KEY_ATTR_IN_PORT);
-	} else {
-		swkey->phy.in_port = DP_MAX_PORTS;
+
+	if (*attrs & (1 << OVS_KEY_ATTR_SKB_MARK)) {
+		uint32_t mark = nla_get_u32(a[OVS_KEY_ATTR_SKB_MARK]);
+
+		SW_FLOW_KEY_PUT(match, phy.skb_mark, mark, is_mask);
+		*attrs &= ~(1 << OVS_KEY_ATTR_SKB_MARK);
 	}
-	if (attrs & (1 << OVS_KEY_ATTR_SKB_MARK)) {
-		swkey->phy.skb_mark = nla_get_u32(a[OVS_KEY_ATTR_SKB_MARK]);
-		attrs &= ~(1 << OVS_KEY_ATTR_SKB_MARK);
+	if (*attrs & (1 << OVS_KEY_ATTR_TUNNEL)) {
+		if (ovs_ipv4_tun_from_nlattr(a[OVS_KEY_ATTR_TUNNEL], match,
+					is_mask))
+			return -EINVAL;
+		*attrs &= ~(1 << OVS_KEY_ATTR_TUNNEL);
 	}
+	return 0;
+}
 
-	if (attrs & (1 << OVS_KEY_ATTR_TUNNEL)) {
-		err = ovs_ipv4_tun_from_nlattr(a[OVS_KEY_ATTR_TUNNEL], &swkey->tun_key);
-		if (err)
-			return err;
+static int ovs_key_from_nlattrs(struct sw_flow_match *match,  u64 attrs,
+		const struct nlattr **a, bool is_mask)
+{
+	int err;
+	u64 orig_attrs = attrs;
 
-		attrs &= ~(1 << OVS_KEY_ATTR_TUNNEL);
-	}
+	err = metadata_from_nlattrs(match, &attrs, a, is_mask);
+	if (err)
+		return err;
 
-	/* Data attributes. */
-	if (!(attrs & (1 << OVS_KEY_ATTR_ETHERNET)))
-		return -EINVAL;
-	attrs &= ~(1 << OVS_KEY_ATTR_ETHERNET);
+	if (attrs & (1 << OVS_KEY_ATTR_ETHERNET)) {
+		const struct ovs_key_ethernet *eth_key;
 
-	eth_key = nla_data(a[OVS_KEY_ATTR_ETHERNET]);
-	memcpy(swkey->eth.src, eth_key->eth_src, ETH_ALEN);
-	memcpy(swkey->eth.dst, eth_key->eth_dst, ETH_ALEN);
+		eth_key = nla_data(a[OVS_KEY_ATTR_ETHERNET]);
+		SW_FLOW_KEY_MEMCPY(match, eth.src,
+				eth_key->eth_src, ETH_ALEN, is_mask);
+		SW_FLOW_KEY_MEMCPY(match, eth.dst,
+				eth_key->eth_dst, ETH_ALEN, is_mask);
+		attrs &= ~(1 << OVS_KEY_ATTR_ETHERNET);
+	}
 
-	if (attrs & (1u << OVS_KEY_ATTR_ETHERTYPE) &&
-	    nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]) == htons(ETH_P_8021Q)) {
-		const struct nlattr *encap;
+	if (attrs & (1 << OVS_KEY_ATTR_VLAN)) {
 		__be16 tci;
 
-		if (attrs != ((1 << OVS_KEY_ATTR_VLAN) |
-			      (1 << OVS_KEY_ATTR_ETHERTYPE) |
-			      (1 << OVS_KEY_ATTR_ENCAP)))
-			return -EINVAL;
-
-		encap = a[OVS_KEY_ATTR_ENCAP];
 		tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
-		if (tci & htons(VLAN_TAG_PRESENT)) {
-			swkey->eth.tci = tci;
-
-			err = parse_flow_nlattrs(encap, a, &attrs);
-			if (err)
-				return err;
-		} else if (!tci) {
-			/* Corner case for truncated 802.1Q header. */
-			if (nla_len(encap))
-				return -EINVAL;
+		if (!(tci & htons(VLAN_TAG_PRESENT))) {
+			if (is_mask)
+				OVS_NLERR("VLAN TCI mask does not have exact match for VLAN_TAG_PRESENT bit.\n");
+			else
+				OVS_NLERR("VLAN TCI does not have VLAN_TAG_PRESENT bit set.\n");
 
-			swkey->eth.type = htons(ETH_P_8021Q);
-			*key_lenp = key_len;
-			return 0;
-		} else {
 			return -EINVAL;
 		}
-	}
+
+		SW_FLOW_KEY_PUT(match, eth.tci, tci, is_mask);
+		attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
+	} else if (!is_mask)
+		SW_FLOW_KEY_PUT(match, eth.tci, htons(0xffff), true);
 
 	if (attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) {
-		swkey->eth.type = nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]);
-		if (ntohs(swkey->eth.type) < ETH_P_802_3_MIN)
+		__be16 eth_type;
+
+		eth_type = nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]);
+		if (is_mask) {
+			/* Always exact match EtherType. */
+			eth_type = htons(0xffff);
+		} else if (ntohs(eth_type) < ETH_P_802_3_MIN) {
+			OVS_NLERR("EtherType is less than minimum (type=%x, min=%x).\n",
+					ntohs(eth_type), ETH_P_802_3_MIN);
 			return -EINVAL;
+		}
+
+		SW_FLOW_KEY_PUT(match, eth.type, eth_type, is_mask);
 		attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
-	} else {
-		swkey->eth.type = htons(ETH_P_802_2);
+	} else if (!is_mask) {
+		SW_FLOW_KEY_PUT(match, eth.type, htons(ETH_P_802_2), is_mask);
 	}
 
-	if (swkey->eth.type == htons(ETH_P_IP)) {
+	if (attrs & (1 << OVS_KEY_ATTR_IPV4)) {
 		const struct ovs_key_ipv4 *ipv4_key;
 
-		if (!(attrs & (1 << OVS_KEY_ATTR_IPV4)))
-			return -EINVAL;
-		attrs &= ~(1 << OVS_KEY_ATTR_IPV4);
-
-		key_len = SW_FLOW_KEY_OFFSET(ipv4.addr);
 		ipv4_key = nla_data(a[OVS_KEY_ATTR_IPV4]);
-		if (ipv4_key->ipv4_frag > OVS_FRAG_TYPE_MAX)
+		if (!is_mask && ipv4_key->ipv4_frag > OVS_FRAG_TYPE_MAX) {
+			OVS_NLERR("Unknown IPv4 fragment type (value=%d, max=%d).\n",
+				ipv4_key->ipv4_frag, OVS_FRAG_TYPE_MAX);
 			return -EINVAL;
-		swkey->ip.proto = ipv4_key->ipv4_proto;
-		swkey->ip.tos = ipv4_key->ipv4_tos;
-		swkey->ip.ttl = ipv4_key->ipv4_ttl;
-		swkey->ip.frag = ipv4_key->ipv4_frag;
-		swkey->ipv4.addr.src = ipv4_key->ipv4_src;
-		swkey->ipv4.addr.dst = ipv4_key->ipv4_dst;
-
-		if (swkey->ip.frag != OVS_FRAG_TYPE_LATER) {
-			err = ipv4_flow_from_nlattrs(swkey, &key_len, a, &attrs);
-			if (err)
-				return err;
 		}
-	} else if (swkey->eth.type == htons(ETH_P_IPV6)) {
-		const struct ovs_key_ipv6 *ipv6_key;
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
 
-		if (!(attrs & (1 << OVS_KEY_ATTR_IPV6)))
-			return -EINVAL;
-		attrs &= ~(1 << OVS_KEY_ATTR_IPV6);
+	if (attrs & (1 << OVS_KEY_ATTR_IPV6)) {
+		const struct ovs_key_ipv6 *ipv6_key;
 
-		key_len = SW_FLOW_KEY_OFFSET(ipv6.label);
 		ipv6_key = nla_data(a[OVS_KEY_ATTR_IPV6]);
-		if (ipv6_key->ipv6_frag > OVS_FRAG_TYPE_MAX)
+		if (!is_mask && ipv6_key->ipv6_frag > OVS_FRAG_TYPE_MAX) {
+			OVS_NLERR("Unknown IPv6 fragment type (value=%d, max=%d).\n",
+				ipv6_key->ipv6_frag, OVS_FRAG_TYPE_MAX);
 			return -EINVAL;
-		swkey->ipv6.label = ipv6_key->ipv6_label;
-		swkey->ip.proto = ipv6_key->ipv6_proto;
-		swkey->ip.tos = ipv6_key->ipv6_tclass;
-		swkey->ip.ttl = ipv6_key->ipv6_hlimit;
-		swkey->ip.frag = ipv6_key->ipv6_frag;
-		memcpy(&swkey->ipv6.addr.src, ipv6_key->ipv6_src,
-		       sizeof(swkey->ipv6.addr.src));
-		memcpy(&swkey->ipv6.addr.dst, ipv6_key->ipv6_dst,
-		       sizeof(swkey->ipv6.addr.dst));
-
-		if (swkey->ip.frag != OVS_FRAG_TYPE_LATER) {
-			err = ipv6_flow_from_nlattrs(swkey, &key_len, a, &attrs);
-			if (err)
-				return err;
 		}
-	} else if (swkey->eth.type == htons(ETH_P_ARP) ||
-		   swkey->eth.type == htons(ETH_P_RARP)) {
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
 		const struct ovs_key_arp *arp_key;
 
-		if (!(attrs & (1 << OVS_KEY_ATTR_ARP)))
+		arp_key = nla_data(a[OVS_KEY_ATTR_ARP]);
+		if (!is_mask && (arp_key->arp_op & htons(0xff00))) {
+			OVS_NLERR("Unknown ARP opcode (opcode=%d).\n",
+				  arp_key->arp_op);
 			return -EINVAL;
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
 		attrs &= ~(1 << OVS_KEY_ATTR_ARP);
+	}
 
-		key_len = SW_FLOW_KEY_OFFSET(ipv4.arp);
-		arp_key = nla_data(a[OVS_KEY_ATTR_ARP]);
-		swkey->ipv4.addr.src = arp_key->arp_sip;
-		swkey->ipv4.addr.dst = arp_key->arp_tip;
-		if (arp_key->arp_op & htons(0xff00))
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
+/**
+ * ovs_match_from_nlattrs - parses Netlink attributes into a flow key and
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
+int ovs_match_from_nlattrs(struct sw_flow_match *match,
+			   const struct nlattr *key,
+			   const struct nlattr *mask)
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
 			return -EINVAL;
-		swkey->ip.proto = ntohs(arp_key->arp_op);
-		memcpy(swkey->ipv4.arp.sha, arp_key->arp_sha, ETH_ALEN);
-		memcpy(swkey->ipv4.arp.tha, arp_key->arp_tha, ETH_ALEN);
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
 	}
 
-	if (attrs)
+	err = ovs_key_from_nlattrs(match, key_attrs, a, false);
+	if (err)
+		return err;
+
+	if (mask) {
+		err = parse_flow_mask_nlattrs(mask, a, &mask_attrs);
+		if (err)
+			return err;
+
+		if (mask_attrs & 1ULL << OVS_KEY_ATTR_ENCAP)  {
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
+			ovs_sw_flow_mask_set(match->mask, &match->range, 0xff);
+	}
+
+	if (!ovs_match_validate(match, key_attrs, mask_attrs))
 		return -EINVAL;
-	*key_lenp = key_len;
 
 	return 0;
 }
@@ -1255,7 +1662,6 @@ int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
 /**
  * ovs_flow_metadata_from_nlattrs - parses Netlink attributes into a flow key.
  * @flow: Receives extracted in_port, priority, tun_key and skb_mark.
- * @key_len: Length of key in @flow.  Used for calculating flow hash.
  * @attr: Netlink attribute holding nested %OVS_KEY_ATTR_* Netlink attribute
  * sequence.
  *
@@ -1264,102 +1670,100 @@ int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
  * get the metadata, that is, the parts of the flow key that cannot be
  * extracted from the packet itself.
  */
-int ovs_flow_metadata_from_nlattrs(struct sw_flow *flow, int key_len,
-				   const struct nlattr *attr)
+
+int ovs_flow_metadata_from_nlattrs(struct sw_flow *flow,
+		const struct nlattr *attr)
 {
 	struct ovs_key_ipv4_tunnel *tun_key = &flow->key.tun_key;
-	const struct nlattr *nla;
-	int rem;
+	const struct nlattr *a[OVS_KEY_ATTR_MAX + 1];
+	u64 attrs = 0;
+	int err;
+	struct sw_flow_match match;
 
 	flow->key.phy.in_port = DP_MAX_PORTS;
 	flow->key.phy.priority = 0;
 	flow->key.phy.skb_mark = 0;
 	memset(tun_key, 0, sizeof(flow->key.tun_key));
 
-	nla_for_each_nested(nla, attr, rem) {
-		int type = nla_type(nla);
-
-		if (type <= OVS_KEY_ATTR_MAX && ovs_key_lens[type] > 0) {
-			int err;
-
-			if (nla_len(nla) != ovs_key_lens[type])
-				return -EINVAL;
-
-			switch (type) {
-			case OVS_KEY_ATTR_PRIORITY:
-				flow->key.phy.priority = nla_get_u32(nla);
-				break;
-
-			case OVS_KEY_ATTR_TUNNEL:
-				err = ovs_ipv4_tun_from_nlattr(nla, tun_key);
-				if (err)
-					return err;
-				break;
-
-			case OVS_KEY_ATTR_IN_PORT:
-				if (nla_get_u32(nla) >= DP_MAX_PORTS)
-					return -EINVAL;
-				flow->key.phy.in_port = nla_get_u32(nla);
-				break;
-
-			case OVS_KEY_ATTR_SKB_MARK:
-				flow->key.phy.skb_mark = nla_get_u32(nla);
-				break;
-			}
-		}
-	}
-	if (rem)
+	err = parse_flow_nlattrs(attr, a, &attrs);
+	if (err)
 		return -EINVAL;
 
-	flow->hash = ovs_flow_hash(&flow->key,
-				   flow_key_start(&flow->key), key_len);
+	memset(&match, 0, sizeof(match));
+	match.key = &flow->key;
+
+	err = metadata_from_nlattrs(&match, &attrs, a, false);
+	if (err)
+		return err;
 
 	return 0;
 }
 
-int ovs_flow_to_nlattrs(const struct sw_flow_key *swkey, struct sk_buff *skb)
+int ovs_flow_to_nlattrs(const struct sw_flow_key *swkey,
+		const struct sw_flow_key *output, struct sk_buff *skb)
 {
 	struct ovs_key_ethernet *eth_key;
 	struct nlattr *nla, *encap;
+	bool is_mask = (swkey != output);
 
-	if (swkey->phy.priority &&
-	    nla_put_u32(skb, OVS_KEY_ATTR_PRIORITY, swkey->phy.priority))
+	if (nla_put_u32(skb, OVS_KEY_ATTR_PRIORITY, output->phy.priority))
 		goto nla_put_failure;
 
-	if (swkey->tun_key.ipv4_dst &&
-	    ovs_ipv4_tun_to_nlattr(skb, &swkey->tun_key))
+	if ((swkey->tun_key.ipv4_dst || is_mask) &&
+	    ovs_ipv4_tun_to_nlattr(skb, &swkey->tun_key, &output->tun_key))
 		goto nla_put_failure;
 
-	if (swkey->phy.in_port != DP_MAX_PORTS &&
-	    nla_put_u32(skb, OVS_KEY_ATTR_IN_PORT, swkey->phy.in_port))
-		goto nla_put_failure;
+	if (swkey->phy.in_port == DP_MAX_PORTS) {
+		if (is_mask && (output->phy.in_port == 0xffff))
+			if (nla_put_u32(skb, OVS_KEY_ATTR_IN_PORT, 0xffffffff))
+				goto nla_put_failure;
+	} else {
+		u16 upper_u16;
+		upper_u16 = !is_mask ? 0 : 0xffff;
 
-	if (swkey->phy.skb_mark &&
-	    nla_put_u32(skb, OVS_KEY_ATTR_SKB_MARK, swkey->phy.skb_mark))
+		if (nla_put_u32(skb, OVS_KEY_ATTR_IN_PORT,
+				(upper_u16 << 16) | output->phy.in_port))
+			goto nla_put_failure;
+	}
+
+	if (nla_put_u32(skb, OVS_KEY_ATTR_SKB_MARK, output->phy.skb_mark))
 		goto nla_put_failure;
 
 	nla = nla_reserve(skb, OVS_KEY_ATTR_ETHERNET, sizeof(*eth_key));
 	if (!nla)
 		goto nla_put_failure;
+
 	eth_key = nla_data(nla);
-	memcpy(eth_key->eth_src, swkey->eth.src, ETH_ALEN);
-	memcpy(eth_key->eth_dst, swkey->eth.dst, ETH_ALEN);
+	memcpy(eth_key->eth_src, output->eth.src, ETH_ALEN);
+	memcpy(eth_key->eth_dst, output->eth.dst, ETH_ALEN);
 
 	if (swkey->eth.tci || swkey->eth.type == htons(ETH_P_8021Q)) {
-		if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, htons(ETH_P_8021Q)) ||
-		    nla_put_be16(skb, OVS_KEY_ATTR_VLAN, swkey->eth.tci))
+		__be16 eth_type;
+		eth_type = !is_mask ? htons(ETH_P_8021Q) : htons(0xffff);
+		if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, eth_type) ||
+		    nla_put_be16(skb, OVS_KEY_ATTR_VLAN, output->eth.tci))
 			goto nla_put_failure;
 		encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
 		if (!swkey->eth.tci)
 			goto unencap;
-	} else {
+	} else
 		encap = NULL;
-	}
 
-	if (swkey->eth.type == htons(ETH_P_802_2))
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
 		goto unencap;
+	}
 
-	if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, swkey->eth.type))
+	if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, output->eth.type))
 		goto nla_put_failure;
 
 	if (swkey->eth.type == htons(ETH_P_IP)) {
@@ -1369,12 +1773,12 @@ int ovs_flow_to_nlattrs(const struct sw_flow_key *swkey, struct sk_buff *skb)
 		if (!nla)
 			goto nla_put_failure;
 		ipv4_key = nla_data(nla);
-		ipv4_key->ipv4_src = swkey->ipv4.addr.src;
-		ipv4_key->ipv4_dst = swkey->ipv4.addr.dst;
-		ipv4_key->ipv4_proto = swkey->ip.proto;
-		ipv4_key->ipv4_tos = swkey->ip.tos;
-		ipv4_key->ipv4_ttl = swkey->ip.ttl;
-		ipv4_key->ipv4_frag = swkey->ip.frag;
+		ipv4_key->ipv4_src = output->ipv4.addr.src;
+		ipv4_key->ipv4_dst = output->ipv4.addr.dst;
+		ipv4_key->ipv4_proto = output->ip.proto;
+		ipv4_key->ipv4_tos = output->ip.tos;
+		ipv4_key->ipv4_ttl = output->ip.ttl;
+		ipv4_key->ipv4_frag = output->ip.frag;
 	} else if (swkey->eth.type == htons(ETH_P_IPV6)) {
 		struct ovs_key_ipv6 *ipv6_key;
 
@@ -1382,15 +1786,15 @@ int ovs_flow_to_nlattrs(const struct sw_flow_key *swkey, struct sk_buff *skb)
 		if (!nla)
 			goto nla_put_failure;
 		ipv6_key = nla_data(nla);
-		memcpy(ipv6_key->ipv6_src, &swkey->ipv6.addr.src,
+		memcpy(ipv6_key->ipv6_src, &output->ipv6.addr.src,
 				sizeof(ipv6_key->ipv6_src));
-		memcpy(ipv6_key->ipv6_dst, &swkey->ipv6.addr.dst,
+		memcpy(ipv6_key->ipv6_dst, &output->ipv6.addr.dst,
 				sizeof(ipv6_key->ipv6_dst));
-		ipv6_key->ipv6_label = swkey->ipv6.label;
-		ipv6_key->ipv6_proto = swkey->ip.proto;
-		ipv6_key->ipv6_tclass = swkey->ip.tos;
-		ipv6_key->ipv6_hlimit = swkey->ip.ttl;
-		ipv6_key->ipv6_frag = swkey->ip.frag;
+		ipv6_key->ipv6_label = output->ipv6.label;
+		ipv6_key->ipv6_proto = output->ip.proto;
+		ipv6_key->ipv6_tclass = output->ip.tos;
+		ipv6_key->ipv6_hlimit = output->ip.ttl;
+		ipv6_key->ipv6_frag = output->ip.frag;
 	} else if (swkey->eth.type == htons(ETH_P_ARP) ||
 		   swkey->eth.type == htons(ETH_P_RARP)) {
 		struct ovs_key_arp *arp_key;
@@ -1400,11 +1804,11 @@ int ovs_flow_to_nlattrs(const struct sw_flow_key *swkey, struct sk_buff *skb)
 			goto nla_put_failure;
 		arp_key = nla_data(nla);
 		memset(arp_key, 0, sizeof(struct ovs_key_arp));
-		arp_key->arp_sip = swkey->ipv4.addr.src;
-		arp_key->arp_tip = swkey->ipv4.addr.dst;
-		arp_key->arp_op = htons(swkey->ip.proto);
-		memcpy(arp_key->arp_sha, swkey->ipv4.arp.sha, ETH_ALEN);
-		memcpy(arp_key->arp_tha, swkey->ipv4.arp.tha, ETH_ALEN);
+		arp_key->arp_sip = output->ipv4.addr.src;
+		arp_key->arp_tip = output->ipv4.addr.dst;
+		arp_key->arp_op = htons(output->ip.proto);
+		memcpy(arp_key->arp_sha, output->ipv4.arp.sha, ETH_ALEN);
+		memcpy(arp_key->arp_tha, output->ipv4.arp.tha, ETH_ALEN);
 	}
 
 	if ((swkey->eth.type == htons(ETH_P_IP) ||
@@ -1419,11 +1823,11 @@ int ovs_flow_to_nlattrs(const struct sw_flow_key *swkey, struct sk_buff *skb)
 				goto nla_put_failure;
 			tcp_key = nla_data(nla);
 			if (swkey->eth.type == htons(ETH_P_IP)) {
-				tcp_key->tcp_src = swkey->ipv4.tp.src;
-				tcp_key->tcp_dst = swkey->ipv4.tp.dst;
+				tcp_key->tcp_src = output->ipv4.tp.src;
+				tcp_key->tcp_dst = output->ipv4.tp.dst;
 			} else if (swkey->eth.type == htons(ETH_P_IPV6)) {
-				tcp_key->tcp_src = swkey->ipv6.tp.src;
-				tcp_key->tcp_dst = swkey->ipv6.tp.dst;
+				tcp_key->tcp_src = output->ipv6.tp.src;
+				tcp_key->tcp_dst = output->ipv6.tp.dst;
 			}
 		} else if (swkey->ip.proto == IPPROTO_UDP) {
 			struct ovs_key_udp *udp_key;
@@ -1433,11 +1837,11 @@ int ovs_flow_to_nlattrs(const struct sw_flow_key *swkey, struct sk_buff *skb)
 				goto nla_put_failure;
 			udp_key = nla_data(nla);
 			if (swkey->eth.type == htons(ETH_P_IP)) {
-				udp_key->udp_src = swkey->ipv4.tp.src;
-				udp_key->udp_dst = swkey->ipv4.tp.dst;
+				udp_key->udp_src = output->ipv4.tp.src;
+				udp_key->udp_dst = output->ipv4.tp.dst;
 			} else if (swkey->eth.type == htons(ETH_P_IPV6)) {
-				udp_key->udp_src = swkey->ipv6.tp.src;
-				udp_key->udp_dst = swkey->ipv6.tp.dst;
+				udp_key->udp_src = output->ipv6.tp.src;
+				udp_key->udp_dst = output->ipv6.tp.dst;
 			}
 		} else if (swkey->eth.type == htons(ETH_P_IP) &&
 			   swkey->ip.proto == IPPROTO_ICMP) {
@@ -1447,8 +1851,8 @@ int ovs_flow_to_nlattrs(const struct sw_flow_key *swkey, struct sk_buff *skb)
 			if (!nla)
 				goto nla_put_failure;
 			icmp_key = nla_data(nla);
-			icmp_key->icmp_type = ntohs(swkey->ipv4.tp.src);
-			icmp_key->icmp_code = ntohs(swkey->ipv4.tp.dst);
+			icmp_key->icmp_type = ntohs(output->ipv4.tp.src);
+			icmp_key->icmp_code = ntohs(output->ipv4.tp.dst);
 		} else if (swkey->eth.type == htons(ETH_P_IPV6) &&
 			   swkey->ip.proto == IPPROTO_ICMPV6) {
 			struct ovs_key_icmpv6 *icmpv6_key;
@@ -1458,8 +1862,8 @@ int ovs_flow_to_nlattrs(const struct sw_flow_key *swkey, struct sk_buff *skb)
 			if (!nla)
 				goto nla_put_failure;
 			icmpv6_key = nla_data(nla);
-			icmpv6_key->icmpv6_type = ntohs(swkey->ipv6.tp.src);
-			icmpv6_key->icmpv6_code = ntohs(swkey->ipv6.tp.dst);
+			icmpv6_key->icmpv6_type = ntohs(output->ipv6.tp.src);
+			icmpv6_key->icmpv6_code = ntohs(output->ipv6.tp.dst);
 
 			if (icmpv6_key->icmpv6_type == NDISC_NEIGHBOUR_SOLICITATION ||
 			    icmpv6_key->icmpv6_type == NDISC_NEIGHBOUR_ADVERTISEMENT) {
@@ -1469,10 +1873,10 @@ int ovs_flow_to_nlattrs(const struct sw_flow_key *swkey, struct sk_buff *skb)
 				if (!nla)
 					goto nla_put_failure;
 				nd_key = nla_data(nla);
-				memcpy(nd_key->nd_target, &swkey->ipv6.nd.target,
+				memcpy(nd_key->nd_target, &output->ipv6.nd.target,
 							sizeof(nd_key->nd_target));
-				memcpy(nd_key->nd_sll, swkey->ipv6.nd.sll, ETH_ALEN);
-				memcpy(nd_key->nd_tll, swkey->ipv6.nd.tll, ETH_ALEN);
+				memcpy(nd_key->nd_sll, output->ipv6.nd.sll, ETH_ALEN);
+				memcpy(nd_key->nd_tll, output->ipv6.nd.tll, ETH_ALEN);
 			}
 		}
 	}
@@ -1504,3 +1908,84 @@ void ovs_flow_exit(void)
 {
 	kmem_cache_destroy(flow_cache);
 }
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
+			kfree_rcu(mask, rcu);
+		else
+			kfree(mask);
+	}
+}
+
+static bool ovs_sw_flow_mask_equal(const struct sw_flow_mask *a,
+		const struct sw_flow_mask *b)
+{
+	u8 *a_ = (u8 *)&a->key + a->range.start;
+	u8 *b_ = (u8 *)&b->key + b->range.start;
+
+	return  (a->range.end == b->range.end)
+		&& (a->range.start == b->range.start)
+		&& (memcmp(a_, b_, ovs_sw_flow_mask_actual_size(a)) == 0);
+}
+
+struct sw_flow_mask *ovs_sw_flow_mask_find(const struct flow_table *tbl,
+                                           const struct sw_flow_mask *mask)
+{
+	struct list_head *ml;
+
+	list_for_each(ml, tbl->mask_list) {
+		struct sw_flow_mask *m;
+		m = container_of(ml, struct sw_flow_mask, list);
+		if (ovs_sw_flow_mask_equal(mask, m))
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
+/**
+ * Set 'range' fields in the mask to the value of 'val'.
+ */
+static void ovs_sw_flow_mask_set(struct sw_flow_mask *mask,
+		struct sw_flow_key_range *range, u8 val)
+{
+	u8 *m = (u8 *)&mask->key + range->start;
+
+	mask->range = *range;
+	memset(m, val, ovs_sw_flow_mask_size_roundup(mask));
+}
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 66ef722..9674e45 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2007-2011 Nicira, Inc.
+ * Copyright (c) 2007-2013 Nicira, Inc.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
@@ -33,6 +33,8 @@
 #include <net/inet_ecn.h>
 
 struct sk_buff;
+struct sw_flow_mask;
+struct flow_table;
 
 struct sw_flow_actions {
 	struct rcu_head rcu;
@@ -131,6 +133,8 @@ struct sw_flow {
 	u32 hash;
 
 	struct sw_flow_key key;
+	struct sw_flow_key unmasked_key;
+	struct sw_flow_mask *mask;
 	struct sw_flow_actions __rcu *sf_acts;
 
 	spinlock_t lock;	/* Lock for values below. */
@@ -140,6 +144,25 @@ struct sw_flow {
 	u8 tcp_flags;		/* Union of seen TCP flags. */
 };
 
+struct sw_flow_key_range {
+	size_t start;
+	size_t end;
+};
+
+static inline u16 ovs_sw_flow_key_range_actual_size(const struct sw_flow_key_range *range)
+{
+	return range->end - range->start;
+}
+
+struct sw_flow_match {
+	struct sw_flow_key *key;
+	struct sw_flow_key_range range;
+	struct sw_flow_mask *mask;
+};
+
+void ovs_match_init(struct sw_flow_match *match,
+		struct sw_flow_key *key, struct sw_flow_mask *mask);
+
 struct arp_eth_header {
 	__be16      ar_hrd;	/* format of hardware address   */
 	__be16      ar_pro;	/* format of protocol address   */
@@ -159,21 +182,21 @@ void ovs_flow_exit(void);
 
 struct sw_flow *ovs_flow_alloc(void);
 void ovs_flow_deferred_free(struct sw_flow *);
-void ovs_flow_free(struct sw_flow *flow);
+void ovs_flow_free(struct sw_flow *, bool deferred);
 
 struct sw_flow_actions *ovs_flow_actions_alloc(int actions_len);
 void ovs_flow_deferred_free_acts(struct sw_flow_actions *);
 
-int ovs_flow_extract(struct sk_buff *, u16 in_port, struct sw_flow_key *,
-		     int *key_lenp);
+int ovs_flow_extract(struct sk_buff *, u16 in_port, struct sw_flow_key *);
 void ovs_flow_used(struct sw_flow *, struct sk_buff *);
 u64 ovs_flow_used_time(unsigned long flow_jiffies);
-
-int ovs_flow_to_nlattrs(const struct sw_flow_key *, struct sk_buff *);
-int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
+int ovs_flow_to_nlattrs(const struct sw_flow_key *,
+		const struct sw_flow_key *, struct sk_buff *);
+int ovs_match_from_nlattrs(struct sw_flow_match *match,
+		      const struct nlattr *,
 		      const struct nlattr *);
-int ovs_flow_metadata_from_nlattrs(struct sw_flow *flow, int key_len,
-				  const struct nlattr *attr);
+int ovs_flow_metadata_from_nlattrs(struct sw_flow *flow,
+		const struct nlattr *attr);
 
 #define MAX_ACTIONS_BUFSIZE    (32 * 1024)
 #define TBL_MIN_BUCKETS		1024
@@ -182,6 +205,7 @@ struct flow_table {
 	struct flex_array *buckets;
 	unsigned int count, n_buckets;
 	struct rcu_head rcu;
+	struct list_head *mask_list;
 	int node_ver;
 	u32 hash_seed;
 	bool keep_flows;
@@ -197,22 +221,56 @@ static inline int ovs_flow_tbl_need_to_expand(struct flow_table *table)
 	return (table->count > table->n_buckets);
 }
 
-struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *table,
-				    struct sw_flow_key *key, int len);
-void ovs_flow_tbl_destroy(struct flow_table *table);
-void ovs_flow_tbl_deferred_destroy(struct flow_table *table);
+struct sw_flow *ovs_flow_lookup(struct flow_table *,
+				const struct sw_flow_key *);
+struct sw_flow *ovs_flow_lookup_unmasked_key(struct flow_table *table,
+				    struct sw_flow_match *match);
+
+void ovs_flow_tbl_destroy(struct flow_table *table, bool deferred);
 struct flow_table *ovs_flow_tbl_alloc(int new_size);
 struct flow_table *ovs_flow_tbl_expand(struct flow_table *table);
 struct flow_table *ovs_flow_tbl_rehash(struct flow_table *table);
-void ovs_flow_tbl_insert(struct flow_table *table, struct sw_flow *flow,
-			 struct sw_flow_key *key, int key_len);
-void ovs_flow_tbl_remove(struct flow_table *table, struct sw_flow *flow);
 
-struct sw_flow *ovs_flow_tbl_next(struct flow_table *table, u32 *bucket, u32 *idx);
+void ovs_flow_insert(struct flow_table *table, struct sw_flow *flow);
+void ovs_flow_remove(struct flow_table *table, struct sw_flow *flow);
+
+struct sw_flow *ovs_flow_dump_next(struct flow_table *table, u32 *bucket, u32 *idx);
 extern const int ovs_key_lens[OVS_KEY_ATTR_MAX + 1];
 int ovs_ipv4_tun_from_nlattr(const struct nlattr *attr,
-			 struct ovs_key_ipv4_tunnel *tun_key);
+			     struct sw_flow_match *match, bool is_mask);
 int ovs_ipv4_tun_to_nlattr(struct sk_buff *skb,
-			const struct ovs_key_ipv4_tunnel *tun_key);
+			   const struct ovs_key_ipv4_tunnel *tun_key,
+			   const struct ovs_key_ipv4_tunnel *output);
+
+bool ovs_flow_cmp_unmasked_key(const struct sw_flow *flow,
+		const struct sw_flow_key *key, int key_len);
+
+struct sw_flow_mask {
+	int ref_count;
+	struct rcu_head rcu;
+	struct list_head list;
+	struct sw_flow_key_range range;
+	struct sw_flow_key key;
+};
+
+static inline u16
+ovs_sw_flow_mask_actual_size(const struct sw_flow_mask *mask)
+{
+	return ovs_sw_flow_key_range_actual_size(&mask->range);
+}
+
+static inline u16
+ovs_sw_flow_mask_size_roundup(const struct sw_flow_mask *mask)
+{
+	return roundup(ovs_sw_flow_mask_actual_size(mask), sizeof(u32));
+}
 
+struct sw_flow_mask *ovs_sw_flow_mask_alloc(void);
+void ovs_sw_flow_mask_add_ref(struct sw_flow_mask *);
+void ovs_sw_flow_mask_del_ref(struct sw_flow_mask *, bool deferred);
+void ovs_sw_flow_mask_insert(struct flow_table *, struct sw_flow_mask *);
+struct sw_flow_mask *ovs_sw_flow_mask_find(const struct flow_table *,
+		const struct sw_flow_mask *);
+void ovs_flow_key_mask(struct sw_flow_key *dst, const struct sw_flow_key *src,
+		       const struct sw_flow_mask *mask);
 #endif /* flow.h */
-- 
1.8.1.2
