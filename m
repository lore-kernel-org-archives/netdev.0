From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v6 05/11] openvswitch: Add recirc action
Date: Sun, 20 Jul 2014 23:17:21 -0700
Message-ID: <1405923441-2000-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:59167 "HELO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753218AbaGUGRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 02:17:22 -0400
Received: by mail-pa0-f48.google.com with SMTP id et14so9081228pad.7
        for <netdev@vger.kernel.org>; Sun, 20 Jul 2014 23:17:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>

Recirc action allows a packet to reenter openvswitch processing.
currently openvswitch lookup flow for packet received and execute
set of actions on that packet, with help of recirc action we can
process/modify the packet and recirculate it back in openvswitch
for another pass.

MPLS flow processing can make use of recirc by first striping off
MPLS portion of packet then passing inner packet back to
openvswitch for further processing.
For example:
Match on: mpls with ip addr x; action: decrement ttl.
Results in two flows
1. Match on: mpls flow; action: pop_mpls, recirc(id)
2. Match on: ip addr x flow with and recirc-id == id; action: dec_ttl

Signed-off-by: Andy Zhou <azhou@nicira.com>
Acked-by: Jesse Gross <jesse@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/uapi/linux/openvswitch.h |  2 ++
 net/openvswitch/actions.c        | 46 +++++++++++++++++++++++++++++++++++-
 net/openvswitch/datapath.c       | 50 ++++++++++++++++++++++++++++------------
 net/openvswitch/datapath.h       |  8 +++++--
 net/openvswitch/flow.h           |  1 +
 net/openvswitch/flow_netlink.c   | 16 +++++++++++++
 6 files changed, 105 insertions(+), 18 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index eaf2d68..f91e2ff 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -291,6 +291,7 @@ enum ovs_key_attr {
 	OVS_KEY_ATTR_TCP_FLAGS,	/* be16 TCP flags. */
 	OVS_KEY_ATTR_DP_HASH,      /* u32 hash value. Value 0 indicates the hash
 				   is not computed by the datapath. */
+	OVS_KEY_ATTR_RECIRC_ID, /* u32 recirc id */
 
 #ifdef __KERNEL__
 	OVS_KEY_ATTR_IPV4_TUNNEL,  /* struct ovs_key_ipv4_tunnel */
@@ -544,6 +545,7 @@ enum ovs_action_attr {
 	OVS_ACTION_ATTR_PUSH_VLAN,    /* struct ovs_action_push_vlan. */
 	OVS_ACTION_ATTR_POP_VLAN,     /* No argument. */
 	OVS_ACTION_ATTR_SAMPLE,       /* Nested OVS_SAMPLE_ATTR_*. */
+	OVS_ACTION_ATTR_RECIRC,       /* u32 recirc_id. */
 	OVS_ACTION_ATTR_HASH,         /* struct ovs_action_hash. */
 	__OVS_ACTION_ATTR_MAX
 };
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 75eccf9..8f8b4ba 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2007-2013 Nicira, Inc.
+ * Copyright (c) 2007-2014 Nicira, Inc.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
@@ -520,6 +520,26 @@ static int execute_set_action(struct sk_buff *skb,
 	return err;
 }
 
+static int execute_recirc(struct datapath *dp, struct sk_buff *skb,
+			  const struct nlattr *a)
+{
+	struct sw_flow_key recirc_key;
+	const struct vport *p = OVS_CB(skb)->input_vport;
+	uint32_t hash = OVS_CB(skb)->pkt_key->ovs_flow_hash;
+	int err;
+
+	err = ovs_flow_extract(skb, p->port_no, &recirc_key);
+	if (err)
+		return err;
+
+	recirc_key.ovs_flow_hash = hash;
+	recirc_key.recirc_id = nla_get_u32(a);
+
+	ovs_dp_process_packet_with_key(skb, &recirc_key);
+
+	return 0;
+}
+
 /* Execute a list of actions against 'skb'. */
 static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			const struct nlattr *attr, int len, bool keep_skb)
@@ -564,6 +584,30 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			err = pop_vlan(skb);
 			break;
 
+		case OVS_ACTION_ATTR_RECIRC: {
+			struct sk_buff *recirc_skb;
+			const bool last_action = (a->nla_len == rem);
+
+			if (__this_cpu_read(net_xmit_recursion) > NET_RECURSION_LIMIT) {
+				net_crit_ratelimited("Net recursion limit readched\n");
+				break;
+			}
+
+			if (!last_action || keep_skb)
+				recirc_skb = skb_clone(skb, GFP_ATOMIC);
+			else
+				recirc_skb = skb;
+
+			__this_cpu_inc(net_xmit_recursion);
+			err = execute_recirc(dp, recirc_skb, a);
+			__this_cpu_dec(net_xmit_recursion);
+
+			if (last_action || err)
+				return err;
+
+			break;
+		}
+
 		case OVS_ACTION_ATTR_SET:
 			err = execute_set_action(skb, nla_data(a));
 			break;
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 8625f13..ae1a5bf 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -238,33 +238,25 @@ void ovs_dp_detach_port(struct vport *p)
 	ovs_vport_del(p);
 }
 
-/* Must be called with rcu_read_lock. */
-void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
+void ovs_dp_process_packet_with_key(struct sk_buff *skb,
+				    struct sw_flow_key *pkt_key)
 {
+	const struct vport *p = OVS_CB(skb)->input_vport;
 	struct datapath *dp = p->dp;
 	struct sw_flow *flow;
 	struct dp_stats_percpu *stats;
-	struct sw_flow_key key;
 	u64 *stats_counter;
 	u32 n_mask_hit;
-	int error;
 
 	stats = this_cpu_ptr(dp->stats_percpu);
 
-	/* Extract flow from 'skb' into 'key'. */
-	error = ovs_flow_extract(skb, p->port_no, &key);
-	if (unlikely(error)) {
-		kfree_skb(skb);
-		return;
-	}
-
 	/* Look up flow. */
-	flow = ovs_flow_tbl_lookup_stats(&dp->table, &key, &n_mask_hit);
+	flow = ovs_flow_tbl_lookup_stats(&dp->table, pkt_key, &n_mask_hit);
 	if (unlikely(!flow)) {
 		struct dp_upcall_info upcall;
 
 		upcall.cmd = OVS_PACKET_CMD_MISS;
-		upcall.key = &key;
+		upcall.key = pkt_key;
 		upcall.userdata = NULL;
 		upcall.portid = ovs_vport_find_upcall_portid(p, skb);
 		ovs_dp_upcall(dp, skb, &upcall);
@@ -274,9 +266,9 @@ void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
 	}
 
 	OVS_CB(skb)->flow = flow;
-	OVS_CB(skb)->pkt_key = &key;
+	OVS_CB(skb)->pkt_key = pkt_key;
 
-	ovs_flow_stats_update(OVS_CB(skb)->flow, key.tp.flags, skb);
+	ovs_flow_stats_update(OVS_CB(skb)->flow, pkt_key->tp.flags, skb);
 	ovs_execute_actions(dp, skb);
 	stats_counter = &stats->n_hit;
 
@@ -288,6 +280,24 @@ out:
 	u64_stats_update_end(&stats->syncp);
 }
 
+/* Must be called with rcu_read_lock. */
+void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
+{
+	int error;
+	struct sw_flow_key key;
+
+	OVS_CB(skb)->input_vport = p;
+
+	/* Extract flow from 'skb' into 'key'. */
+	error = ovs_flow_extract(skb, p->port_no, &key);
+	if (unlikely(error)) {
+		kfree_skb(skb);
+		return;
+	}
+
+	ovs_dp_process_packet_with_key(skb, &key);
+}
+
 int ovs_dp_upcall(struct datapath *dp, struct sk_buff *skb,
 		  const struct dp_upcall_info *upcall_info)
 {
@@ -511,6 +521,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	struct sw_flow *flow;
 	struct datapath *dp;
 	struct ethhdr *eth;
+	struct vport *input_vport;
 	int len;
 	int err;
 
@@ -574,6 +585,15 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	if (!dp)
 		goto err_unlock;
 
+	input_vport = ovs_vport_rcu(dp, flow->key.phy.in_port);
+	if (!input_vport)
+		input_vport = ovs_vport_rcu(dp, OVSP_LOCAL);
+
+	if (!input_vport)
+		goto err_unlock;
+
+	OVS_CB(packet)->input_vport = input_vport;
+
 	local_bh_disable();
 	err = ovs_execute_actions(dp, packet);
 	local_bh_enable();
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 7ede507..6ff2352 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2007-2012 Nicira, Inc.
+ * Copyright (c) 2007-2014 Nicira, Inc.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
@@ -97,12 +97,14 @@ struct datapath {
  * @flow: The flow associated with this packet.  May be %NULL if no flow.
  * @pkt_key: The flow information extracted from the packet.  Must be nonnull.
  * @tun_key: Key for the tunnel that encapsulated this packet. NULL if the
- * packet is not being tunneled.
+ * @input_vport: The original vport packet came in on. This value is cached
+ * when a packet is received by OVS.
  */
 struct ovs_skb_cb {
 	struct sw_flow		*flow;
 	struct sw_flow_key	*pkt_key;
 	struct ovs_key_ipv4_tunnel  *tun_key;
+	struct vport	*input_vport;
 };
 #define OVS_CB(skb) ((struct ovs_skb_cb *)(skb)->cb)
 
@@ -184,6 +186,8 @@ extern struct notifier_block ovs_dp_device_notifier;
 extern struct genl_family dp_vport_genl_family;
 
 void ovs_dp_process_received_packet(struct vport *, struct sk_buff *);
+void ovs_dp_process_packet_with_key(struct sk_buff *,
+				    struct sw_flow_key *pkt_key);
 void ovs_dp_detach_port(struct vport *);
 int ovs_dp_upcall(struct datapath *, struct sk_buff *,
 		  const struct dp_upcall_info *);
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 39c5fc6..5a84925 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -73,6 +73,7 @@ struct sw_flow_key {
 		u16	in_port;	/* Input switch port (or DP_MAX_PORTS). */
 	} __packed phy; /* Safe when right after 'tun_key'. */
 	u32 ovs_flow_hash;		/* Datapath computed hash value.  */
+	u32 recirc_id;			/* Recirculation ID.  */
 	struct {
 		u8     src[ETH_ALEN];	/* Ethernet source address. */
 		u8     dst[ETH_ALEN];	/* Ethernet destination address. */
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 504f794..686e2f2 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -252,6 +252,7 @@ static const int ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
 	[OVS_KEY_ATTR_ARP] = sizeof(struct ovs_key_arp),
 	[OVS_KEY_ATTR_ND] = sizeof(struct ovs_key_nd),
 	[OVS_KEY_ATTR_DP_HASH] = sizeof(u32),
+	[OVS_KEY_ATTR_RECIRC_ID] = sizeof(u32),
 	[OVS_KEY_ATTR_TUNNEL] = -1,
 };
 
@@ -462,6 +463,13 @@ static int metadata_from_nlattrs(struct sw_flow_match *match,  u64 *attrs,
 		*attrs &= ~(1 << OVS_KEY_ATTR_DP_HASH);
 	}
 
+	if (*attrs & (1 << OVS_KEY_ATTR_RECIRC_ID)) {
+		u32 recirc_id = nla_get_u32(a[OVS_KEY_ATTR_RECIRC_ID]);
+
+		SW_FLOW_KEY_PUT(match, recirc_id, recirc_id, is_mask);
+		*attrs &= ~(1 << OVS_KEY_ATTR_RECIRC_ID);
+	}
+
 	if (*attrs & (1 << OVS_KEY_ATTR_PRIORITY)) {
 		SW_FLOW_KEY_PUT(match, phy.priority,
 			  nla_get_u32(a[OVS_KEY_ATTR_PRIORITY]), is_mask);
@@ -867,6 +875,7 @@ int ovs_nla_get_flow_metadata(struct sw_flow *flow,
 	flow->key.phy.priority = 0;
 	flow->key.phy.skb_mark = 0;
 	flow->key.ovs_flow_hash = 0;
+	flow->key.recirc_id = 0;
 	memset(tun_key, 0, sizeof(flow->key.tun_key));
 
 	err = parse_flow_nlattrs(attr, a, &attrs);
@@ -893,6 +902,9 @@ int ovs_nla_put_flow(const struct sw_flow_key *swkey,
 	if (nla_put_u32(skb, OVS_KEY_ATTR_DP_HASH, output->ovs_flow_hash))
 		goto nla_put_failure;
 
+	if (nla_put_u32(skb, OVS_KEY_ATTR_RECIRC_ID, output->recirc_id))
+		goto nla_put_failure;
+
 	if (nla_put_u32(skb, OVS_KEY_ATTR_PRIORITY, output->phy.priority))
 		goto nla_put_failure;
 
@@ -1421,6 +1433,7 @@ int ovs_nla_copy_actions(const struct nlattr *attr,
 		/* Expected argument lengths, (u32)-1 for variable length. */
 		static const u32 action_lens[OVS_ACTION_ATTR_MAX + 1] = {
 			[OVS_ACTION_ATTR_OUTPUT] = sizeof(u32),
+			[OVS_ACTION_ATTR_RECIRC] = sizeof(u32),
 			[OVS_ACTION_ATTR_USERSPACE] = (u32)-1,
 			[OVS_ACTION_ATTR_PUSH_VLAN] = sizeof(struct ovs_action_push_vlan),
 			[OVS_ACTION_ATTR_POP_VLAN] = 0,
@@ -1477,6 +1490,9 @@ int ovs_nla_copy_actions(const struct nlattr *attr,
 				return -EINVAL;
 			break;
 
+		case OVS_ACTION_ATTR_RECIRC:
+			break;
+
 		case OVS_ACTION_ATTR_SET:
 			err = validate_set(a, key, sfa, &skip_copy);
 			if (err)
-- 
1.9.3
