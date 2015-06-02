From: Thomas F Herbert <thomasfherbert@gmail.com>
Subject: [PATCH net-next V10 4/4] 8021AD: Flow key parsing and netlink attributes.
Date: Tue,  2 Jun 2015 13:50:44 -0400
Message-ID: <1433267444-26025-5-git-send-email-thomasfherbert@gmail.com>
References: <1433267444-26025-1-git-send-email-thomasfherbert@gmail.com>
Cc: therbert@redhat.com, dev@openvswitch.org,
	Thomas F Herbert <thomasfherbert@gmail.com>
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:34698 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759648AbbFBRvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 13:51:17 -0400
Received: by ykfl8 with SMTP id l8so56087417ykf.1
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2015 10:51:17 -0700 (PDT)
In-Reply-To: <1433267444-26025-1-git-send-email-thomasfherbert@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for 802.1ad to netlink parsing and flow conversation. Uses
double nested encap attributes to represent double tagged vlan.

Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
---
 net/openvswitch/flow_netlink.c | 186 ++++++++++++++++++++++++++++++++++-------
 1 file changed, 157 insertions(+), 29 deletions(-)

diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index c691b1a..8fd4f63 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -771,6 +771,28 @@ static int metadata_from_nlattrs(struct sw_flow_match *match,  u64 *attrs,
 	return 0;
 }
 
+static int cust_vlan_from_nlattrs(struct sw_flow_match *match, u64 attrs,
+				  const struct nlattr **a, bool is_mask,
+				  bool log)
+{
+	/* This should be nested inner or "customer" tci" */
+	if (attrs & (1 << OVS_KEY_ATTR_VLAN)) {
+		__be16 ctci;
+
+		ctci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
+		if (!(ctci & htons(VLAN_TAG_PRESENT))) {
+			if (is_mask)
+				OVS_NLERR(log, "VLAN CTCI mask does not have exact match for VLAN_TAG_PRESENT bit.");
+			else
+				OVS_NLERR(log, "VLAN CTCI does not have VLAN_TAG_PRESENT bit set.");
+
+			return -EINVAL;
+		}
+		SW_FLOW_KEY_PUT(match, eth.ctci, ctci, is_mask);
+	}
+	return 0;
+}
+
 static int ovs_key_from_nlattrs(struct sw_flow_match *match, u64 attrs,
 				const struct nlattr **a, bool is_mask,
 				bool log)
@@ -1024,6 +1046,105 @@ static void mask_set_nlattr(struct nlattr *attr, u8 val)
 	nlattr_set(attr, val, ovs_key_lens);
 }
 
+static int parse_vlan_from_nlattrs(const struct nlattr *nla,
+				   struct sw_flow_match *match,
+				   u64 *key_attrs, bool *ie_valid,
+				   const struct nlattr **a, bool is_mask,
+				   bool log)
+{
+	int err;
+	__be16 tci;
+	const struct nlattr *encap;
+
+	if (!is_mask) {
+		u64 v_attrs = 0;
+
+		tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
+
+		if (tci & htons(VLAN_TAG_PRESENT)) {
+			if (unlikely((nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]) ==
+				      htons(ETH_P_8021AD)))) {
+				err = parse_flow_nlattrs(nla, a, &v_attrs, log);
+				if (err)
+					return err;
+				if (!v_attrs)
+					return -EINVAL;
+
+				if (!((v_attrs &
+				       (1ULL << OVS_KEY_ATTR_VLAN)) &&
+				      (v_attrs &
+				       (1ULL << OVS_KEY_ATTR_ENCAP)))) {
+					OVS_NLERR(log, "Invalid Vlan frame.");
+					return -EINVAL;
+				}
+				v_attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
+				encap = a[OVS_KEY_ATTR_ENCAP];
+				v_attrs &= ~(1 << OVS_KEY_ATTR_ENCAP);
+				*ie_valid = true;
+
+				err = cust_vlan_from_nlattrs(match, v_attrs,
+							     &encap, is_mask,
+							     log);
+				if (err)
+					return err;
+				/* Insure that tci key attribute isn't
+				 * overwritten by encapsulated customer tci.
+				 */
+				v_attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
+				*key_attrs |= v_attrs;
+			} else {
+				*key_attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
+				err = parse_flow_nlattrs(nla, a, key_attrs,
+							 log);
+				if (err)
+					return err;
+			}
+		} else if (!tci) {
+			/* Corner case for truncated 802.1Q header. */
+			if (nla_len(nla)) {
+				OVS_NLERR(log, "Truncated 802.1Q header has non-zero encap attribute.");
+				return -EINVAL;
+			}
+		} else {
+			OVS_NLERR(log, "Encap attr is set for non-VLAN frame");
+			return  -EINVAL;
+		}
+
+	} else {
+		u64 mask_v_attrs = 0;
+
+		tci = 0;
+		if (a[OVS_KEY_ATTR_VLAN])
+			tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
+
+		if (!(tci & htons(VLAN_TAG_PRESENT))) {
+			OVS_NLERR(log, "VLAN tag present bit must have an exact match (tci_mask=%x).",
+				  ntohs(tci));
+			err = -EINVAL;
+			return err;
+		}
+		err = parse_flow_mask_nlattrs(nla, a, &mask_v_attrs,
+					      log);
+		if (err)
+			return err;
+
+		if (mask_v_attrs & (1ULL << OVS_KEY_ATTR_VLAN)) {
+			err = cust_vlan_from_nlattrs(match, mask_v_attrs,
+						     a, is_mask, log);
+			if (err)
+				return err;
+
+			mask_v_attrs &= ~(1ULL << OVS_KEY_ATTR_VLAN);
+			*key_attrs |= mask_v_attrs;
+	       } else {
+			*key_attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
+			if (err)
+				return err;
+		}
+	}
+	return 0;
+}
+
 /**
  * ovs_nla_get_match - parses Netlink attributes into a flow key and
  * mask. In case the 'mask' is NULL, the flow is treated as exact match
@@ -1050,6 +1171,7 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 	u64 key_attrs = 0;
 	u64 mask_attrs = 0;
 	bool encap_valid = false;
+	bool i_encap_valid = false;
 	int err;
 
 	err = parse_flow_nlattrs(nla_key, a, &key_attrs, log);
@@ -1058,35 +1180,24 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 
 	if ((key_attrs & (1 << OVS_KEY_ATTR_ETHERNET)) &&
 	    (key_attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) &&
-	    (nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]) == htons(ETH_P_8021Q))) {
-		__be16 tci;
+	    eth_type_vlan(nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]))) {
 
-		if (!((key_attrs & (1 << OVS_KEY_ATTR_VLAN)) &&
-		      (key_attrs & (1 << OVS_KEY_ATTR_ENCAP)))) {
+		if (!((key_attrs & (1ULL << OVS_KEY_ATTR_VLAN)) &&
+		      (key_attrs & (1ULL << OVS_KEY_ATTR_ENCAP)))) {
 			OVS_NLERR(log, "Invalid Vlan frame.");
 			return -EINVAL;
 		}
 
 		key_attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
-		tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
 		encap = a[OVS_KEY_ATTR_ENCAP];
 		key_attrs &= ~(1 << OVS_KEY_ATTR_ENCAP);
 		encap_valid = true;
 
-		if (tci & htons(VLAN_TAG_PRESENT)) {
-			err = parse_flow_nlattrs(encap, a, &key_attrs, log);
-			if (err)
-				return err;
-		} else if (!tci) {
-			/* Corner case for truncated 802.1Q header. */
-			if (nla_len(encap)) {
-				OVS_NLERR(log, "Truncated 802.1Q header has non-zero encap attribute.");
-				return -EINVAL;
-			}
-		} else {
-			OVS_NLERR(log, "Encap attr is set for non-VLAN frame");
-			return  -EINVAL;
-		}
+		err = parse_vlan_from_nlattrs(encap, match, &key_attrs,
+					      &i_encap_valid, a, false, log);
+		if (err)
+			return err;
+
 	}
 
 	err = ovs_key_from_nlattrs(match, key_attrs, a, false, log);
@@ -1132,7 +1243,6 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 
 		if (mask_attrs & 1 << OVS_KEY_ATTR_ENCAP) {
 			__be16 eth_type = 0;
-			__be16 tci = 0;
 
 			if (!encap_valid) {
 				OVS_NLERR(log, "Encap mask attribute is set for non-VLAN frame.");
@@ -1158,15 +1268,13 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 				goto free_newmask;
 			}
 
-			if (a[OVS_KEY_ATTR_VLAN])
-				tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
-
-			if (!(tci & htons(VLAN_TAG_PRESENT))) {
-				OVS_NLERR(log, "VLAN tag present bit must have an exact match (tci_mask=%x).",
-					  ntohs(tci));
-				err = -EINVAL;
+			err = parse_vlan_from_nlattrs(encap, match,
+						      &mask_attrs,
+						      &i_encap_valid, a, true,
+						      log);
+			if (err)
 				goto free_newmask;
-			}
+
 		}
 
 		err = ovs_key_from_nlattrs(match, mask_attrs, a, true, log);
@@ -1331,6 +1439,25 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
 		encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
 		if (!swkey->eth.tci)
 			goto unencap;
+	} else if (swkey->eth.ctci || swkey->eth.type == htons(ETH_P_8021AD)) {
+		__be16 eth_type;
+
+		eth_type = !is_mask ? htons(ETH_P_8021AD) : htons(0xffff);
+		if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, eth_type) ||
+		    nla_put_be16(skb, OVS_KEY_ATTR_VLAN, output->eth.tci))
+			goto nla_put_failure;
+		encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
+		if (!swkey->eth.tci)
+			goto unencap;
+		/* Customer tci is nested but uses same key attribute.
+		 */
+		eth_type = !is_mask ? htons(ETH_P_8021Q) : htons(0xffff);
+		if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, eth_type) ||
+		    nla_put_be16(skb, OVS_KEY_ATTR_VLAN, output->eth.ctci))
+			goto nla_put_failure;
+		encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
+		if (!swkey->eth.ctci)
+			goto unencap;
 	} else
 		encap = NULL;
 
@@ -2078,7 +2205,8 @@ static int __ovs_nla_copy_actions(const struct nlattr *attr,
 
 		case OVS_ACTION_ATTR_PUSH_VLAN:
 			vlan = nla_data(a);
-			if (vlan->vlan_tpid != htons(ETH_P_8021Q))
+			if ((vlan->vlan_tpid != htons(ETH_P_8021Q)) &&
+			    (vlan->vlan_tpid != htons(ETH_P_8021AD)))
 				return -EINVAL;
 			if (!(vlan->vlan_tci & htons(VLAN_TAG_PRESENT)))
 				return -EINVAL;
-- 
2.1.0
