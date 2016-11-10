From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v13 7/8] openvswitch: add Ethernet push and pop actions
Date: Thu, 10 Nov 2016 16:28:23 +0100
Message-ID: <fefa3d36d50639e176e831fefbc53d38ab2f04f6.1478791347.git.jbenc@redhat.com>
References: <cover.1478791347.git.jbenc@redhat.com>
Cc: dev@openvswitch.org, Pravin Shelar <pshelar@ovn.org>,
        Lorand Jakab <lojakab@cisco.com>,
        Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43392 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934214AbcKJP2w (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 10:28:52 -0500
In-Reply-To: <cover.1478791347.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's not allowed to push Ethernet header in front of another Ethernet
header.

It's not allowed to pop Ethernet header if there's a vlan tag. This
preserves the invariant that L3 packet never has a vlan tag.

Based on previous versions by Lorand Jakab and Simon Horman.

Signed-off-by: Lorand Jakab <lojakab@cisco.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
v13: use skb_reset_mac_len in push_eth and pop_eth
---
 include/uapi/linux/openvswitch.h | 15 ++++++++++++
 net/openvswitch/actions.c        | 49 ++++++++++++++++++++++++++++++++++++++++
 net/openvswitch/flow_netlink.c   | 18 +++++++++++++++
 3 files changed, 82 insertions(+)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 59ed3992c760..375d812fea36 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -705,6 +705,15 @@ enum ovs_nat_attr {
 
 #define OVS_NAT_ATTR_MAX (__OVS_NAT_ATTR_MAX - 1)
 
+/*
+ * struct ovs_action_push_eth - %OVS_ACTION_ATTR_PUSH_ETH action argument.
+ * @addresses: Source and destination MAC addresses.
+ * @eth_type: Ethernet type
+ */
+struct ovs_action_push_eth {
+	struct ovs_key_ethernet addresses;
+};
+
 /**
  * enum ovs_action_attr - Action types.
  *
@@ -738,6 +747,10 @@ enum ovs_nat_attr {
  * is no MPLS label stack, as determined by ethertype, no action is taken.
  * @OVS_ACTION_ATTR_CT: Track the connection. Populate the conntrack-related
  * entries in the flow key.
+ * @OVS_ACTION_ATTR_PUSH_ETH: Push a new outermost Ethernet header onto the
+ * packet.
+ * @OVS_ACTION_ATTR_POP_ETH: Pop the outermost Ethernet header off the
+ * packet.
  *
  * Only a single header can be set with a single %OVS_ACTION_ATTR_SET.  Not all
  * fields within a header are modifiable, e.g. the IPv4 protocol and fragment
@@ -765,6 +778,8 @@ enum ovs_action_attr {
 				       * bits. */
 	OVS_ACTION_ATTR_CT,           /* Nested OVS_CT_ATTR_* . */
 	OVS_ACTION_ATTR_TRUNC,        /* u32 struct ovs_action_trunc. */
+	OVS_ACTION_ATTR_PUSH_ETH,     /* struct ovs_action_push_eth. */
+	OVS_ACTION_ATTR_POP_ETH,      /* No argument. */
 
 	__OVS_ACTION_ATTR_MAX,	      /* Nothing past this will be accepted
 				       * from userspace. */
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 064cbcb7b0c5..514f7bcf7c63 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -317,6 +317,47 @@ static int set_eth_addr(struct sk_buff *skb, struct sw_flow_key *flow_key,
 	return 0;
 }
 
+/* pop_eth does not support VLAN packets as this action is never called
+ * for them.
+ */
+static int pop_eth(struct sk_buff *skb, struct sw_flow_key *key)
+{
+	skb_pull_rcsum(skb, ETH_HLEN);
+	skb_reset_mac_header(skb);
+	skb_reset_mac_len(skb);
+
+	/* safe right before invalidate_flow_key */
+	key->mac_proto = MAC_PROTO_NONE;
+	invalidate_flow_key(key);
+	return 0;
+}
+
+static int push_eth(struct sk_buff *skb, struct sw_flow_key *key,
+		    const struct ovs_action_push_eth *ethh)
+{
+	struct ethhdr *hdr;
+
+	/* Add the new Ethernet header */
+	if (skb_cow_head(skb, ETH_HLEN) < 0)
+		return -ENOMEM;
+
+	skb_push(skb, ETH_HLEN);
+	skb_reset_mac_header(skb);
+	skb_reset_mac_len(skb);
+
+	hdr = eth_hdr(skb);
+	ether_addr_copy(hdr->h_source, ethh->addresses.eth_src);
+	ether_addr_copy(hdr->h_dest, ethh->addresses.eth_dst);
+	hdr->h_proto = skb->protocol;
+
+	skb_postpush_rcsum(skb, hdr, ETH_HLEN);
+
+	/* safe right before invalidate_flow_key */
+	key->mac_proto = MAC_PROTO_ETHERNET;
+	invalidate_flow_key(key);
+	return 0;
+}
+
 static void update_ip_l4_checksum(struct sk_buff *skb, struct iphdr *nh,
 				  __be32 addr, __be32 new_addr)
 {
@@ -1200,6 +1241,14 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			if (err)
 				return err == -EINPROGRESS ? 0 : err;
 			break;
+
+		case OVS_ACTION_ATTR_PUSH_ETH:
+			err = push_eth(skb, key, nla_data(a));
+			break;
+
+		case OVS_ACTION_ATTR_POP_ETH:
+			err = pop_eth(skb, key);
+			break;
 		}
 
 		if (unlikely(err)) {
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index c3d0cc4321c3..d19044f2b1f4 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -2383,6 +2383,8 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 			[OVS_ACTION_ATTR_HASH] = sizeof(struct ovs_action_hash),
 			[OVS_ACTION_ATTR_CT] = (u32)-1,
 			[OVS_ACTION_ATTR_TRUNC] = sizeof(struct ovs_action_trunc),
+			[OVS_ACTION_ATTR_PUSH_ETH] = sizeof(struct ovs_action_push_eth),
+			[OVS_ACTION_ATTR_POP_ETH] = 0,
 		};
 		const struct ovs_action_push_vlan *vlan;
 		int type = nla_type(a);
@@ -2517,6 +2519,22 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 			skip_copy = true;
 			break;
 
+		case OVS_ACTION_ATTR_PUSH_ETH:
+			/* Disallow pushing an Ethernet header if one
+			 * is already present */
+			if (mac_proto != MAC_PROTO_NONE)
+				return -EINVAL;
+			mac_proto = MAC_PROTO_NONE;
+			break;
+
+		case OVS_ACTION_ATTR_POP_ETH:
+			if (mac_proto != MAC_PROTO_ETHERNET)
+				return -EINVAL;
+			if (vlan_tci & htons(VLAN_TAG_PRESENT))
+				return -EINVAL;
+			mac_proto = MAC_PROTO_ETHERNET;
+			break;
+
 		default:
 			OVS_NLERR(log, "Unknown Action type %d", type);
 			return -EINVAL;
-- 
1.8.3.1
