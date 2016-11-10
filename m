From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v13 6/8] openvswitch: netlink: support L3 packets
Date: Thu, 10 Nov 2016 16:28:22 +0100
Message-ID: <c4b1e110e7b4d67f86c45bc393a9bb9a78be644f.1478791347.git.jbenc@redhat.com>
References: <cover.1478791347.git.jbenc@redhat.com>
Cc: dev@openvswitch.org, Pravin Shelar <pshelar@ovn.org>,
        Lorand Jakab <lojakab@cisco.com>,
        Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56764 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934184AbcKJP2u (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 10:28:50 -0500
In-Reply-To: <cover.1478791347.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend the ovs flow netlink protocol to support L3 packets. Packets without
OVS_KEY_ATTR_ETHERNET attribute specify L3 packets; for those, the
OVS_KEY_ATTR_ETHERTYPE attribute is mandatory.

Push/pop vlan actions are only supported for Ethernet packets.

Based on previous versions by Lorand Jakab and Simon Horman.

Signed-off-by: Lorand Jakab <lojakab@cisco.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>
Signed-off-by: Jiri Benc <jbenc@redhat.com>
Acked-by: Pravin B Shelar <pshelar@ovn.org>
---
 net/openvswitch/flow_netlink.c | 160 +++++++++++++++++++++++++----------------
 1 file changed, 99 insertions(+), 61 deletions(-)

diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index ccb9900c5230..c3d0cc4321c3 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -123,7 +123,7 @@ static void update_range(struct sw_flow_match *match,
 static bool match_validate(const struct sw_flow_match *match,
 			   u64 key_attrs, u64 mask_attrs, bool log)
 {
-	u64 key_expected = 1 << OVS_KEY_ATTR_ETHERNET;
+	u64 key_expected = 0;
 	u64 mask_allowed = key_attrs;  /* At most allow all key attributes */
 
 	/* The following mask attributes allowed only if they
@@ -969,10 +969,33 @@ static int parse_vlan_from_nlattrs(struct sw_flow_match *match,
 	return 0;
 }
 
+static int parse_eth_type_from_nlattrs(struct sw_flow_match *match,
+				       u64 *attrs, const struct nlattr **a,
+				       bool is_mask, bool log)
+{
+	__be16 eth_type;
+
+	eth_type = nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]);
+	if (is_mask) {
+		/* Always exact match EtherType. */
+		eth_type = htons(0xffff);
+	} else if (!eth_proto_is_802_3(eth_type)) {
+		OVS_NLERR(log, "EtherType %x is less than min %x",
+				ntohs(eth_type), ETH_P_802_3_MIN);
+		return -EINVAL;
+	}
+
+	SW_FLOW_KEY_PUT(match, eth.type, eth_type, is_mask);
+	*attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
+	return 0;
+}
+
 static int metadata_from_nlattrs(struct net *net, struct sw_flow_match *match,
 				 u64 *attrs, const struct nlattr **a,
 				 bool is_mask, bool log)
 {
+	u8 mac_proto = MAC_PROTO_ETHERNET;
+
 	if (*attrs & (1 << OVS_KEY_ATTR_DP_HASH)) {
 		u32 hash_val = nla_get_u32(a[OVS_KEY_ATTR_DP_HASH]);
 
@@ -1060,9 +1083,19 @@ static int metadata_from_nlattrs(struct net *net, struct sw_flow_match *match,
 		*attrs &= ~(1ULL << OVS_KEY_ATTR_CT_LABELS);
 	}
 
+	/* For layer 3 packets the Ethernet type is provided
+	 * and treated as metadata but no MAC addresses are provided.
+	 */
+	if (!(*attrs & (1ULL << OVS_KEY_ATTR_ETHERNET)) &&
+	    (*attrs & (1ULL << OVS_KEY_ATTR_ETHERTYPE)))
+		mac_proto = MAC_PROTO_NONE;
+
 	/* Always exact match mac_proto */
-	SW_FLOW_KEY_PUT(match, mac_proto, is_mask ? 0xff : MAC_PROTO_ETHERNET,
-			is_mask);
+	SW_FLOW_KEY_PUT(match, mac_proto, is_mask ? 0xff : mac_proto, is_mask);
+
+	if (mac_proto == MAC_PROTO_NONE)
+		return parse_eth_type_from_nlattrs(match, attrs, a, is_mask,
+						   log);
 
 	return 0;
 }
@@ -1086,33 +1119,26 @@ static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
 		SW_FLOW_KEY_MEMCPY(match, eth.dst,
 				eth_key->eth_dst, ETH_ALEN, is_mask);
 		attrs &= ~(1 << OVS_KEY_ATTR_ETHERNET);
-	}
-
-	if (attrs & (1 << OVS_KEY_ATTR_VLAN)) {
-		/* VLAN attribute is always parsed before getting here since it
-		 * may occur multiple times.
-		 */
-		OVS_NLERR(log, "VLAN attribute unexpected.");
-		return -EINVAL;
-	}
-
-	if (attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) {
-		__be16 eth_type;
 
-		eth_type = nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]);
-		if (is_mask) {
-			/* Always exact match EtherType. */
-			eth_type = htons(0xffff);
-		} else if (!eth_proto_is_802_3(eth_type)) {
-			OVS_NLERR(log, "EtherType %x is less than min %x",
-				  ntohs(eth_type), ETH_P_802_3_MIN);
+		if (attrs & (1 << OVS_KEY_ATTR_VLAN)) {
+			/* VLAN attribute is always parsed before getting here since it
+			 * may occur multiple times.
+			 */
+			OVS_NLERR(log, "VLAN attribute unexpected.");
 			return -EINVAL;
 		}
 
-		SW_FLOW_KEY_PUT(match, eth.type, eth_type, is_mask);
-		attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
-	} else if (!is_mask) {
-		SW_FLOW_KEY_PUT(match, eth.type, htons(ETH_P_802_2), is_mask);
+		if (attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) {
+			err = parse_eth_type_from_nlattrs(match, &attrs, a, is_mask,
+							  log);
+			if (err)
+				return err;
+		} else if (!is_mask) {
+			SW_FLOW_KEY_PUT(match, eth.type, htons(ETH_P_802_2), is_mask);
+		}
+	} else if (!match->key->eth.type) {
+		OVS_NLERR(log, "Either Ethernet header or EtherType is required.");
+		return -EINVAL;
 	}
 
 	if (attrs & (1 << OVS_KEY_ATTR_IPV4)) {
@@ -1561,42 +1587,44 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
 	if (ovs_ct_put_key(output, skb))
 		goto nla_put_failure;
 
-	nla = nla_reserve(skb, OVS_KEY_ATTR_ETHERNET, sizeof(*eth_key));
-	if (!nla)
-		goto nla_put_failure;
-
-	eth_key = nla_data(nla);
-	ether_addr_copy(eth_key->eth_src, output->eth.src);
-	ether_addr_copy(eth_key->eth_dst, output->eth.dst);
-
-	if (swkey->eth.vlan.tci || eth_type_vlan(swkey->eth.type)) {
-		if (ovs_nla_put_vlan(skb, &output->eth.vlan, is_mask))
+	if (ovs_key_mac_proto(swkey) == MAC_PROTO_ETHERNET) {
+		nla = nla_reserve(skb, OVS_KEY_ATTR_ETHERNET, sizeof(*eth_key));
+		if (!nla)
 			goto nla_put_failure;
-		encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
-		if (!swkey->eth.vlan.tci)
-			goto unencap;
 
-		if (swkey->eth.cvlan.tci || eth_type_vlan(swkey->eth.type)) {
-			if (ovs_nla_put_vlan(skb, &output->eth.cvlan, is_mask))
+		eth_key = nla_data(nla);
+		ether_addr_copy(eth_key->eth_src, output->eth.src);
+		ether_addr_copy(eth_key->eth_dst, output->eth.dst);
+
+		if (swkey->eth.vlan.tci || eth_type_vlan(swkey->eth.type)) {
+			if (ovs_nla_put_vlan(skb, &output->eth.vlan, is_mask))
 				goto nla_put_failure;
-			in_encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
-			if (!swkey->eth.cvlan.tci)
+			encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
+			if (!swkey->eth.vlan.tci)
 				goto unencap;
+
+			if (swkey->eth.cvlan.tci || eth_type_vlan(swkey->eth.type)) {
+				if (ovs_nla_put_vlan(skb, &output->eth.cvlan, is_mask))
+					goto nla_put_failure;
+				in_encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
+				if (!swkey->eth.cvlan.tci)
+					goto unencap;
+			}
 		}
-	}
 
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
+		if (swkey->eth.type == htons(ETH_P_802_2)) {
+			/*
+			* Ethertype 802.2 is represented in the netlink with omitted
+			* OVS_KEY_ATTR_ETHERTYPE in the flow key attribute, and
+			* 0xffff in the mask attribute.  Ethertype can also
+			* be wildcarded.
+			*/
+			if (is_mask && output->eth.type)
+				if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE,
+							output->eth.type))
+					goto nla_put_failure;
+			goto unencap;
+		}
 	}
 
 	if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, output->eth.type))
@@ -2131,8 +2159,8 @@ static bool validate_masked(u8 *data, int len)
 
 static int validate_set(const struct nlattr *a,
 			const struct sw_flow_key *flow_key,
-			struct sw_flow_actions **sfa,
-			bool *skip_copy, __be16 eth_type, bool masked, bool log)
+			struct sw_flow_actions **sfa, bool *skip_copy,
+			u8 mac_proto, __be16 eth_type, bool masked, bool log)
 {
 	const struct nlattr *ovs_key = nla_data(a);
 	int key_type = nla_type(ovs_key);
@@ -2162,9 +2190,12 @@ static int validate_set(const struct nlattr *a,
 	case OVS_KEY_ATTR_SKB_MARK:
 	case OVS_KEY_ATTR_CT_MARK:
 	case OVS_KEY_ATTR_CT_LABELS:
-	case OVS_KEY_ATTR_ETHERNET:
 		break;
 
+	case OVS_KEY_ATTR_ETHERNET:
+		if (mac_proto != MAC_PROTO_ETHERNET)
+			return -EINVAL;
+
 	case OVS_KEY_ATTR_TUNNEL:
 		if (masked)
 			return -EINVAL; /* Masked tunnel set not supported. */
@@ -2329,6 +2360,7 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 				  int depth, struct sw_flow_actions **sfa,
 				  __be16 eth_type, __be16 vlan_tci, bool log)
 {
+	u8 mac_proto = ovs_key_mac_proto(key);
 	const struct nlattr *a;
 	int rem, err;
 
@@ -2399,10 +2431,14 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 		}
 
 		case OVS_ACTION_ATTR_POP_VLAN:
+			if (mac_proto != MAC_PROTO_ETHERNET)
+				return -EINVAL;
 			vlan_tci = htons(0);
 			break;
 
 		case OVS_ACTION_ATTR_PUSH_VLAN:
+			if (mac_proto != MAC_PROTO_ETHERNET)
+				return -EINVAL;
 			vlan = nla_data(a);
 			if (!eth_type_vlan(vlan->vlan_tpid))
 				return -EINVAL;
@@ -2452,14 +2488,16 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 
 		case OVS_ACTION_ATTR_SET:
 			err = validate_set(a, key, sfa,
-					   &skip_copy, eth_type, false, log);
+					   &skip_copy, mac_proto, eth_type,
+					   false, log);
 			if (err)
 				return err;
 			break;
 
 		case OVS_ACTION_ATTR_SET_MASKED:
 			err = validate_set(a, key, sfa,
-					   &skip_copy, eth_type, true, log);
+					   &skip_copy, mac_proto, eth_type,
+					   true, log);
 			if (err)
 				return err;
 			break;
-- 
1.8.3.1
