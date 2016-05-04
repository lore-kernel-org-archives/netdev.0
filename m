From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH v9 net-next 6/7] openvswitch: extend layer 3 support to cover non-IP packets
Date: Wed,  4 May 2016 16:36:32 +0900
Message-ID: <1462347393-22354-7-git-send-email-simon.horman@netronome.com>
References: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34222 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757240AbcEDHhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 03:37:12 -0400
Received: by mail-pa0-f53.google.com with SMTP id r5so21735872pag.1
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 00:37:11 -0700 (PDT)
In-Reply-To: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend support for layer 3 packets to cover non-IP packets.

This removes the assumption that the first octet of a layer 3 packet
indicates the IP protocol version - true for IP (v4 and v6), but not
for necessarily for other protocols.

The key motivation for this is to allow forwarding of MPLS packets which
are technically layer 2.5 rather than 3 but the distinction seems unimportant
here.

This sets OVS_KEY_ATTR_PACKET_ETHERTYPE to the ethernet type corresponding
to the protocol of layer 3 packets on a flow miss.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
v9
* New patch
---
 net/openvswitch/flow_netlink.c | 121 ++++++++++++++++++++---------------------
 1 file changed, 59 insertions(+), 62 deletions(-)

diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 2bca1e5e9a18..1e1392c3c0ed 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -817,7 +817,7 @@ static int metadata_from_nlattrs(struct net *net, struct sw_flow_match *match,
 				 u64 *attrs, const struct nlattr **a,
 				 bool is_mask, bool log)
 {
-	bool is_layer3;
+	bool is_layer3 = false;
 
 	if (*attrs & (1 << OVS_KEY_ATTR_DP_HASH)) {
 		u32 hash_val = nla_get_u32(a[OVS_KEY_ATTR_DP_HASH]);
@@ -906,48 +906,40 @@ static int metadata_from_nlattrs(struct net *net, struct sw_flow_match *match,
 		*attrs &= ~(1ULL << OVS_KEY_ATTR_CT_LABELS);
 	}
 
-	/* For full flow keys the layer is determined based on the presence of
-	 * OVS_KEY_ATTR_ETHERNET
-	 */
-	if (is_mask)
-		/* Always exact match is_layer3 */
-		is_layer3 = true;
-	else
-		is_layer3 =  !(*attrs & (1ULL << OVS_KEY_ATTR_ETHERNET));
-	/* Packets from user space for execution only have metadata key
-	 * attributes.  OVS_KEY_ATTR_PACKET_ETHERTYPE is then used to specify
-	 * the starting layer of the packet.  Packets with Ethernet headers
-	 * have this attribute set to 0
+	/* For layer 3 packets the ethernet type is provided by by the
+	 * metadata field OVS_KEY_ATTR_PACKET_ETHERTYPE which has a
+	 * non-zero value. Otherwise the ethernet type is provided by the
+	 * packet and reflected by OVS_KEY_ATTR_PACKET_ETHERTYPE.
 	 */
 	if (*attrs & (1ULL << OVS_KEY_ATTR_PACKET_ETHERTYPE)) {
+		/* This is duplicate code from ovs_key_from_nlattrs*/
 		__be16 eth_type;
 
-		if (is_mask) {
+		if (is_mask)
 			/* Always exact match packet EtherType */
 			eth_type = htons(0xffff);
-		} else {
+		else
 			eth_type = nla_get_be16(a[OVS_KEY_ATTR_PACKET_ETHERTYPE]);
-			is_layer3 = ((eth_type == htons(ETH_P_IP)) ||
-				     (eth_type == htons(ETH_P_IPV6)));
+
+		if (eth_type != htons(0)) {
+			is_layer3 = true;
+			SW_FLOW_KEY_PUT(match, eth.type, eth_type, is_mask);
 		}
-		SW_FLOW_KEY_PUT(match, eth.type, eth_type, is_mask);
+
+		*attrs &= ~(1ULL << OVS_KEY_ATTR_PACKET_ETHERTYPE);
 	}
 
-	SW_FLOW_KEY_PUT(match, phy.is_layer3, is_layer3, is_mask);
-	return 0;
+	/* Always exact match is_layer3 */
+	SW_FLOW_KEY_PUT(match, phy.is_layer3, is_mask ? true : is_layer3,
+			is_mask);
+	return is_layer3;
 }
 
-static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
-				u64 attrs, const struct nlattr **a,
-				bool is_mask, bool log)
+static int l2_from_nlattrs(struct net *net, struct sw_flow_match *match,
+			   u64 *attrs, const struct nlattr **a,
+			   bool is_mask, bool log)
 {
-	int err;
-
-	err = metadata_from_nlattrs(net, match, &attrs, a, is_mask, log);
-	if (err)
-		return err;
-
-	if (attrs & (1 << OVS_KEY_ATTR_ETHERNET)) {
+	if (*attrs & (1 << OVS_KEY_ATTR_ETHERNET)) {
 		const struct ovs_key_ethernet *eth_key;
 
 		eth_key = nla_data(a[OVS_KEY_ATTR_ETHERNET]);
@@ -955,10 +947,10 @@ static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
 				eth_key->eth_src, ETH_ALEN, is_mask);
 		SW_FLOW_KEY_MEMCPY(match, eth.dst,
 				eth_key->eth_dst, ETH_ALEN, is_mask);
-		attrs &= ~(1 << OVS_KEY_ATTR_ETHERNET);
+		*attrs &= ~(1 << OVS_KEY_ATTR_ETHERNET);
 	}
 
-	if (attrs & (1 << OVS_KEY_ATTR_VLAN)) {
+	if (*attrs & (1 << OVS_KEY_ATTR_VLAN)) {
 		__be16 tci;
 
 		tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
@@ -972,10 +964,10 @@ static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
 		}
 
 		SW_FLOW_KEY_PUT(match, eth.tci, tci, is_mask);
-		attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
+		*attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
 	}
 
-	if (attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) {
+	if (*attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) {
 		__be16 eth_type;
 
 		eth_type = nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]);
@@ -989,24 +981,34 @@ static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
 		}
 
 		SW_FLOW_KEY_PUT(match, eth.type, eth_type, is_mask);
-		attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
+		*attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
 	} else if (!is_mask) {
 		SW_FLOW_KEY_PUT(match, eth.type, htons(ETH_P_802_2), is_mask);
 	}
 
-	if (attrs & (1 << OVS_KEY_ATTR_IPV4)) {
-		const struct ovs_key_ipv4 *ipv4_key;
+	return 0;
+}
 
-		/* Add eth.type value for layer 3 flows */
-		if (!(attrs & (1ULL << OVS_KEY_ATTR_ETHERTYPE))) {
-			__be16 eth_type;
+static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
+				u64 attrs, const struct nlattr **a,
+				bool is_mask, bool log)
+{
+	int err;
+	bool is_layer3;
 
-			if (is_mask)
-				eth_type = htons(0xffff);
-			else
-				eth_type = htons(ETH_P_IP);
-			SW_FLOW_KEY_PUT(match, eth.type, eth_type, is_mask);
-		}
+	err = metadata_from_nlattrs(net, match, &attrs, a, is_mask, log);
+	if (err < 0)
+		return err;
+	is_layer3 = err != 0;
+
+	if (!is_layer3) {
+		err = l2_from_nlattrs(net, match, &attrs, a, is_mask, log);
+		if (err < 0)
+			return err;
+	}
+
+	if (attrs & (1 << OVS_KEY_ATTR_IPV4)) {
+		const struct ovs_key_ipv4 *ipv4_key;
 
 		ipv4_key = nla_data(a[OVS_KEY_ATTR_IPV4]);
 		if (!is_mask && ipv4_key->ipv4_frag > OVS_FRAG_TYPE_MAX) {
@@ -1032,17 +1034,6 @@ static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
 	if (attrs & (1 << OVS_KEY_ATTR_IPV6)) {
 		const struct ovs_key_ipv6 *ipv6_key;
 
-		/* Add eth.type value for layer 3 flows */
-		if (!(attrs & (1ULL << OVS_KEY_ATTR_ETHERTYPE))) {
-			__be16 eth_type;
-
-			if (is_mask)
-				eth_type = htons(0xffff);
-			else
-				eth_type = htons(ETH_P_IPV6);
-			SW_FLOW_KEY_PUT(match, eth.type, eth_type, is_mask);
-		}
-
 		ipv6_key = nla_data(a[OVS_KEY_ATTR_IPV6]);
 		if (!is_mask && ipv6_key->ipv6_frag > OVS_FRAG_TYPE_MAX) {
 			OVS_NLERR(log, "IPv6 frag type %d is out of range max %d",
@@ -1465,7 +1456,11 @@ int ovs_nla_get_flow_metadata(struct net *net, const struct nlattr *attr,
 	memset(&key->ct, 0, sizeof(key->ct));
 	key->phy.in_port = DP_MAX_PORTS;
 
-	return metadata_from_nlattrs(net, &match, &attrs, a, false, log);
+	err = metadata_from_nlattrs(net, &match, &attrs, a, false, log);
+	if (err < 0)
+		return err;
+
+	return 0;
 }
 
 static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
@@ -1551,6 +1546,10 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
 
 		if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, output->eth.type))
 			goto nla_put_failure;
+	} else {
+		if (nla_put_be16(skb, OVS_KEY_ATTR_PACKET_ETHERTYPE,
+				 output->eth.type))
+			goto nla_put_failure;
 	}
 
 	if (swkey->eth.type == htons(ETH_P_IP)) {
@@ -2184,8 +2183,6 @@ static int validate_set(const struct nlattr *a,
 		break;
 
 	case OVS_KEY_ATTR_MPLS:
-		if (is_layer3)
-			return -EINVAL;
 		if (!eth_p_mpls(eth_type))
 			return -EINVAL;
 		break;
@@ -2360,7 +2357,7 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 		case OVS_ACTION_ATTR_PUSH_MPLS: {
 			const struct ovs_action_push_mpls *mpls = nla_data(a);
 
-			if (is_layer3 || !eth_p_mpls(mpls->mpls_ethertype))
+			if (!eth_p_mpls(mpls->mpls_ethertype))
 				return -EINVAL;
 			/* Prohibit push MPLS other than to a white list
 			 * for packets that have a known tag order.
@@ -2377,7 +2374,7 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 		}
 
 		case OVS_ACTION_ATTR_POP_MPLS:
-			if (is_layer3 || vlan_tci & htons(VLAN_TAG_PRESENT) ||
+			if (vlan_tci & htons(VLAN_TAG_PRESENT) ||
 			    !eth_p_mpls(eth_type))
 				return -EINVAL;
 
-- 
2.7.0.rc3.207.g0ac5344
