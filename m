From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v4 03/11] openvswitch: Add hash action
Date: Wed, 16 Jul 2014 17:18:25 -0700
Message-ID: <1405556305-1740-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog134.obsmtp.com ([74.125.149.83]:59367 "HELO
	na3sys009aog134.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753720AbaGQAS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 20:18:28 -0400
Received: by mail-pa0-f44.google.com with SMTP id eu11so2225546pac.31
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 17:18:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>

OVS hash action calculates 5-tupple hash and set hash in flow-key
hash. This can be used along with recirculation for distributing
packets among different ports.
For example:
OVS bonding can use following actions:
Match on: bond flow; Action: hash, recirc(id)
Match on: recirc-id == id and hash lower bits == a;
          Action: output port_bond_a

Signed-off-by: Andy Zhou <azhou@nicira.com>
Acked-by: Jesse Gross <jesse@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/uapi/linux/openvswitch.h | 24 ++++++++++++++++++++++++
 net/openvswitch/actions.c        | 19 +++++++++++++++++++
 net/openvswitch/flow.h           |  1 +
 net/openvswitch/flow_netlink.c   | 27 ++++++++++++++++++++++++++-
 4 files changed, 70 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index a794d1d..eaf2d68 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -289,6 +289,8 @@ enum ovs_key_attr {
 	OVS_KEY_ATTR_TUNNEL,    /* Nested set of ovs_tunnel attributes */
 	OVS_KEY_ATTR_SCTP,      /* struct ovs_key_sctp */
 	OVS_KEY_ATTR_TCP_FLAGS,	/* be16 TCP flags. */
+	OVS_KEY_ATTR_DP_HASH,      /* u32 hash value. Value 0 indicates the hash
+				   is not computed by the datapath. */
 
 #ifdef __KERNEL__
 	OVS_KEY_ATTR_IPV4_TUNNEL,  /* struct ovs_key_ipv4_tunnel */
@@ -493,6 +495,27 @@ struct ovs_action_push_vlan {
 	__be16 vlan_tci;	/* 802.1Q TCI (VLAN ID and priority). */
 };
 
+/* Data path hash algorithm for computing Datapath hash.
+ *
+ * The algorithm type only specifies the fields in a flow
+ * will be used as part of the hash. Each datapath is free
+ * to use its own hash algorithm. The hash value will be
+ * opaque to the user space daemon.
+ */
+enum ovs_hash_alg {
+	OVS_HASH_ALG_L4,
+};
+
+/*
+ * struct ovs_action_hash - %OVS_ACTION_ATTR_HASH action argument.
+ * @hash_alg: Algorithm used to compute hash prior to recirculation.
+ * @hash_basis: basis used for computing hash.
+ */
+struct ovs_action_hash {
+	uint32_t  hash_alg;     /* One of ovs_hash_alg. */
+	uint32_t  hash_basis;
+};
+
 /**
  * enum ovs_action_attr - Action types.
  *
@@ -521,6 +544,7 @@ enum ovs_action_attr {
 	OVS_ACTION_ATTR_PUSH_VLAN,    /* struct ovs_action_push_vlan. */
 	OVS_ACTION_ATTR_POP_VLAN,     /* No argument. */
 	OVS_ACTION_ATTR_SAMPLE,       /* Nested OVS_SAMPLE_ATTR_*. */
+	OVS_ACTION_ATTR_HASH,         /* struct ovs_action_hash. */
 	__OVS_ACTION_ATTR_MAX
 };
 
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index c36856a..56c22f0 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -459,6 +459,21 @@ static int sample(struct datapath *dp, struct sk_buff *skb,
 						 nla_len(acts_list), true);
 }
 
+static void execute_hash(struct sk_buff *skb, const struct nlattr *attr)
+{
+	struct sw_flow_key *key = OVS_CB(skb)->pkt_key;
+	struct ovs_action_hash *hash_act = nla_data(attr);
+	u32 hash = 0;
+
+	/* OVS_HASH_ALG_L4 is the only possible hash algorithm.  */
+	hash = skb_get_hash(skb);
+	hash = jhash_1word(hash, hash_act->hash_basis);
+	if (!hash)
+		hash = 0x1;
+
+	key->ovs_flow_hash = hash;
+}
+
 static int execute_set_action(struct sk_buff *skb,
 				 const struct nlattr *nested_attr)
 {
@@ -535,6 +550,10 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			output_userspace(dp, skb, a);
 			break;
 
+		case OVS_ACTION_ATTR_HASH:
+			execute_hash(skb, a);
+			break;
+
 		case OVS_ACTION_ATTR_PUSH_VLAN:
 			err = push_vlan(skb, nla_data(a));
 			if (unlikely(err)) /* skb already freed. */
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index ac395d2..ae15599 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -72,6 +72,7 @@ struct sw_flow_key {
 		u32	skb_mark;	/* SKB mark. */
 		u16	in_port;	/* Input switch port (or DP_MAX_PORTS). */
 	} __packed phy; /* Safe when right after 'tun_key'. */
+	u32 ovs_flow_hash;		/* Datapath computed hash value.  */
 	struct {
 		u8     src[ETH_ALEN];	/* Ethernet source address. */
 		u8     dst[ETH_ALEN];	/* Ethernet destination address. */
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index d757848..504f794 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -251,6 +251,7 @@ static const int ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
 	[OVS_KEY_ATTR_ICMPV6] = sizeof(struct ovs_key_icmpv6),
 	[OVS_KEY_ATTR_ARP] = sizeof(struct ovs_key_arp),
 	[OVS_KEY_ATTR_ND] = sizeof(struct ovs_key_nd),
+	[OVS_KEY_ATTR_DP_HASH] = sizeof(u32),
 	[OVS_KEY_ATTR_TUNNEL] = -1,
 };
 
@@ -454,6 +455,13 @@ static int ipv4_tun_to_nlattr(struct sk_buff *skb,
 static int metadata_from_nlattrs(struct sw_flow_match *match,  u64 *attrs,
 				 const struct nlattr **a, bool is_mask)
 {
+	if (*attrs & (1 << OVS_KEY_ATTR_DP_HASH)) {
+		u32 hash_val = nla_get_u32(a[OVS_KEY_ATTR_DP_HASH]);
+
+		SW_FLOW_KEY_PUT(match, ovs_flow_hash, hash_val, is_mask);
+		*attrs &= ~(1 << OVS_KEY_ATTR_DP_HASH);
+	}
+
 	if (*attrs & (1 << OVS_KEY_ATTR_PRIORITY)) {
 		SW_FLOW_KEY_PUT(match, phy.priority,
 			  nla_get_u32(a[OVS_KEY_ATTR_PRIORITY]), is_mask);
@@ -858,6 +866,7 @@ int ovs_nla_get_flow_metadata(struct sw_flow *flow,
 	flow->key.phy.in_port = DP_MAX_PORTS;
 	flow->key.phy.priority = 0;
 	flow->key.phy.skb_mark = 0;
+	flow->key.ovs_flow_hash = 0;
 	memset(tun_key, 0, sizeof(flow->key.tun_key));
 
 	err = parse_flow_nlattrs(attr, a, &attrs);
@@ -881,6 +890,9 @@ int ovs_nla_put_flow(const struct sw_flow_key *swkey,
 	struct nlattr *nla, *encap;
 	bool is_mask = (swkey != output);
 
+	if (nla_put_u32(skb, OVS_KEY_ATTR_DP_HASH, output->ovs_flow_hash))
+		goto nla_put_failure;
+
 	if (nla_put_u32(skb, OVS_KEY_ATTR_PRIORITY, output->phy.priority))
 		goto nla_put_failure;
 
@@ -1413,7 +1425,8 @@ int ovs_nla_copy_actions(const struct nlattr *attr,
 			[OVS_ACTION_ATTR_PUSH_VLAN] = sizeof(struct ovs_action_push_vlan),
 			[OVS_ACTION_ATTR_POP_VLAN] = 0,
 			[OVS_ACTION_ATTR_SET] = (u32)-1,
-			[OVS_ACTION_ATTR_SAMPLE] = (u32)-1
+			[OVS_ACTION_ATTR_SAMPLE] = (u32)-1,
+			[OVS_ACTION_ATTR_HASH] = sizeof(struct ovs_action_hash)
 		};
 		const struct ovs_action_push_vlan *vlan;
 		int type = nla_type(a);
@@ -1440,6 +1453,18 @@ int ovs_nla_copy_actions(const struct nlattr *attr,
 				return -EINVAL;
 			break;
 
+		case OVS_ACTION_ATTR_HASH: {
+			const struct ovs_action_hash *act_hash = nla_data(a);
+
+			switch (act_hash->hash_alg) {
+			case OVS_HASH_ALG_L4:
+				break;
+			default:
+				return  -EINVAL;
+			}
+
+			break;
+		}
 
 		case OVS_ACTION_ATTR_POP_VLAN:
 			break;
-- 
1.9.3
