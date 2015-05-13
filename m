From: Thomas F Herbert <thomasfherbert@gmail.com>
Subject: [PATCH net-next V7 2/2] openvswitch: 802.1ad: Flow handling, actions, and vlan parsing
Date: Tue, 12 May 2015 20:06:36 -0400
Message-ID: <1431475596-16780-3-git-send-email-thomasfherbert@gmail.com>
References: <1431475596-16780-1-git-send-email-thomasfherbert@gmail.com>
Cc: therbert@redhat.com, ccp@atcnet.net, dev@openvswitch.org,
	Thomas F Herbert <thomasfherbert@gmail.com>
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:34718 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964810AbbEMAHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 20:07:10 -0400
Received: by qgfi89 with SMTP id i89so13464972qgf.1
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 17:07:09 -0700 (PDT)
In-Reply-To: <1431475596-16780-1-git-send-email-thomasfherbert@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for 802.1ad including the ability to push and pop double
tagged vlans.

Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
---
 net/openvswitch/flow.c         |  82 +++++++++++++---
 net/openvswitch/flow.h         |   3 +
 net/openvswitch/flow_netlink.c | 212 +++++++++++++++++++++++++++++++++++------
 3 files changed, 256 insertions(+), 41 deletions(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 2dacc7b..9c73a2e 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -298,21 +298,78 @@ static bool icmp6hdr_ok(struct sk_buff *skb)
 static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
 {
 	struct qtag_prefix {
-		__be16 eth_type; /* ETH_P_8021Q */
+		__be16 eth_type; /* ETH_P_8021Q  or ETH_P_8021AD */
 		__be16 tci;
 	};
-	struct qtag_prefix *qp;
+	struct qtag_prefix *qp = (struct qtag_prefix *)skb->data;
 
-	if (unlikely(skb->len < sizeof(struct qtag_prefix) + sizeof(__be16)))
+	struct qinqtag_prefix {
+		__be16 eth_type; /* ETH_P_8021Q  or ETH_P_8021AD */
+		__be16 tci;
+		__be16 inner_tpid; /* ETH_P_8021Q */
+		__be16 ctci;
+	};
+
+	if (likely(skb_vlan_tag_present(skb))) {
+		key->eth.tci = htons(skb->vlan_tci);
+
+		/* Case where upstream
+		 * processing has already stripped the outer vlan tag.
+		 */
+		if (unlikely(skb->vlan_proto == htons(ETH_P_8021AD))) {
+			if (unlikely(skb->len < sizeof(struct qtag_prefix) +
+					sizeof(__be16))) {
+				key->eth.tci = 0;
+				return 0;
+			}
+
+			if (unlikely(!pskb_may_pull(skb,
+						    sizeof(struct qtag_prefix) +
+						    sizeof(__be16)))) {
+				return -ENOMEM;
+			}
+
+			if (likely(qp->eth_type == htons(ETH_P_8021Q))) {
+				key->eth.ctci = qp->tci |
+						htons(VLAN_TAG_PRESENT);
+				__skb_pull(skb, sizeof(struct qtag_prefix));
+			}
+		}
 		return 0;
+	}
 
-	if (unlikely(!pskb_may_pull(skb, sizeof(struct qtag_prefix) +
-					 sizeof(__be16))))
-		return -ENOMEM;
 
-	qp = (struct qtag_prefix *) skb->data;
-	key->eth.tci = qp->tci | htons(VLAN_TAG_PRESENT);
-	__skb_pull(skb, sizeof(struct qtag_prefix));
+	if (qp->eth_type == htons(ETH_P_8021AD)) {
+		struct qinqtag_prefix *qinqp =
+					(struct qinqtag_prefix *)skb->data;
+
+		if (unlikely(skb->len < sizeof(struct qinqtag_prefix) +
+					sizeof(__be16)))
+			return 0;
+
+		if (unlikely(!pskb_may_pull(skb, sizeof(struct qinqtag_prefix) +
+				sizeof(__be16)))) {
+			return -ENOMEM;
+		}
+		key->eth.tci = qinqp->tci | htons(VLAN_TAG_PRESENT);
+		key->eth.ctci = qinqp->ctci | htons(VLAN_TAG_PRESENT);
+
+		__skb_pull(skb, sizeof(struct qinqtag_prefix));
+
+		return 0;
+	}
+	if (qp->eth_type == htons(ETH_P_8021Q)) {
+		if (unlikely(skb->len < sizeof(struct qtag_prefix) +
+					sizeof(__be16)))
+			return -ENOMEM;
+
+		if (unlikely(!pskb_may_pull(skb, sizeof(struct qtag_prefix) +
+				sizeof(__be16))))
+			return 0;
+		key->eth.tci = qp->tci | htons(VLAN_TAG_PRESENT);
+
+		__skb_pull(skb, sizeof(struct qtag_prefix));
+	}
 
 	return 0;
 }
@@ -474,9 +531,10 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 	 */
 
 	key->eth.tci = 0;
-	if (skb_vlan_tag_present(skb))
-		key->eth.tci = htons(skb->vlan_tci);
-	else if (eth->h_proto == htons(ETH_P_8021Q))
+	key->eth.ctci = 0;
+	if ((skb_vlan_tag_present(skb)) ||
+	    (eth->h_proto == htons(ETH_P_8021Q)) ||
+	    (eth->h_proto == htons(ETH_P_8021AD)))
 		if (unlikely(parse_vlan(skb, key)))
 			return -ENOMEM;
 
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index a076e44..fa83c61 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -134,6 +134,9 @@ struct sw_flow_key {
 		u8     src[ETH_ALEN];	/* Ethernet source address. */
 		u8     dst[ETH_ALEN];	/* Ethernet destination address. */
 		__be16 tci;		/* 0 if no VLAN, VLAN_TAG_PRESENT set otherwise. */
+		__be16 ctci;		/* 0 if no CVLAN, VLAN_TAG_PRESENT set
+					 * otherwise.
+					 */
 		__be16 type;		/* Ethernet frame type. */
 	} eth;
 	union {
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index c691b1a..062e180 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -771,6 +771,51 @@ static int metadata_from_nlattrs(struct sw_flow_match *match,  u64 *attrs,
 	return 0;
 }
 
+static int eth_type_vlan(__be16 ethertype)
+{
+	if (ethertype == htons(ETH_P_8021Q) || ethertype == htons(ETH_P_8021AD))
+		return true;
+	return false;
+}
+
+static int _ovs_vlan_from_nlattrs(struct sw_flow_match *match, u64 attrs,
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
+		if (is_mask)
+			SW_FLOW_KEY_PUT(match, eth.ctci, htons(0xffff),
+					is_mask);
+		else
+			SW_FLOW_KEY_PUT(match, eth.ctci, ctci, is_mask);
+	}
+	return 0;
+}
+
+static int ovs_vlan_from_nlattrs(struct sw_flow_match *match, u64 attrs,
+				 const struct nlattr **a, bool log)
+{
+	return _ovs_vlan_from_nlattrs(match, attrs, a, false, log);
+}
+
+static int ovs_vlan_mask_from_nlattrs(struct sw_flow_match *match, u64 attrs,
+				      const struct nlattr **a, bool log)
+{
+	return _ovs_vlan_from_nlattrs(match, attrs, a, true, log);
+}
+
 static int ovs_key_from_nlattrs(struct sw_flow_match *match, u64 attrs,
 				const struct nlattr **a, bool is_mask,
 				bool log)
@@ -1024,6 +1069,113 @@ static void mask_set_nlattr(struct nlattr *attr, u8 val)
 	nlattr_set(attr, val, ovs_key_lens);
 }
 
+static int _parse_vlan_from_nlattrs(const struct nlattr *nla,
+				    struct sw_flow_match *match,
+				    u64 *key_attrs,
+				    const struct nlattr **a, bool is_mask,
+				    bool log)
+{
+	int err;
+	__be16 tci;
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
+				if (v_attrs) {
+					err = ovs_vlan_from_nlattrs(match,
+								    v_attrs, a,
+								    log);
+					if (err)
+						return err;
+				}
+				/* Insure that tci key attribute isn't
+				 * overwritten by encapsulated customer tci.
+				 */
+				v_attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
+				*key_attrs |= v_attrs;
+			} else {
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
+			__be16 ctci = 0;
+
+			ctci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
+			err = ovs_vlan_mask_from_nlattrs(match, mask_v_attrs,
+							 a, log);
+			if (err)
+				return err;
+
+			if (!(ctci & htons(VLAN_TAG_PRESENT))) {
+				OVS_NLERR(log, "VLAN ctag present bit must have an exact match (ctci_mask=%x).",
+					  ntohs(ctci));
+				err = -EINVAL;
+				return err;
+		       }
+		       mask_v_attrs &= ~(1ULL << OVS_KEY_ATTR_VLAN);
+		       *key_attrs |= mask_v_attrs;
+	       }
+	}
+	return 0;
+}
+
+static int parse_vlan_from_nlattrs(const struct nlattr *nla,
+				   struct sw_flow_match *match,
+				   u64 *key_attrs,
+				   const struct nlattr **a,
+				   bool log)
+{
+	return _parse_vlan_from_nlattrs(nla, match, key_attrs, a, false, log);
+}
+
+static int parse_vlan_mask_from_nlattrs(const struct nlattr *nla,
+					struct sw_flow_match *match,
+					u64 *key_attrs,
+					const struct nlattr **a,
+					bool log)
+{
+	return _parse_vlan_from_nlattrs(nla, match, key_attrs, a, true, log);
+}
+
 /**
  * ovs_nla_get_match - parses Netlink attributes into a flow key and
  * mask. In case the 'mask' is NULL, the flow is treated as exact match
@@ -1058,35 +1210,24 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 
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
+		err = parse_vlan_from_nlattrs(encap, match, &key_attrs, a,
+					      log);
+		if (err)
+			return err;
+
 	}
 
 	err = ovs_key_from_nlattrs(match, key_attrs, a, false, log);
@@ -1132,7 +1273,6 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 
 		if (mask_attrs & 1 << OVS_KEY_ATTR_ENCAP) {
 			__be16 eth_type = 0;
-			__be16 tci = 0;
 
 			if (!encap_valid) {
 				OVS_NLERR(log, "Encap mask attribute is set for non-VLAN frame.");
@@ -1158,15 +1298,12 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 				goto free_newmask;
 			}
 
-			if (a[OVS_KEY_ATTR_VLAN])
-				tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
-
-			if (!(tci & htons(VLAN_TAG_PRESENT))) {
-				OVS_NLERR(log, "VLAN tag present bit must have an exact match (tci_mask=%x).",
-					  ntohs(tci));
-				err = -EINVAL;
+			err = parse_vlan_mask_from_nlattrs(encap, match,
+							   &mask_attrs,
+							   a, log);
+			if (err)
 				goto free_newmask;
-			}
+
 		}
 
 		err = ovs_key_from_nlattrs(match, mask_attrs, a, true, log);
@@ -1331,6 +1468,22 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
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
+		if (nla_put_be16(skb, OVS_KEY_ATTR_VLAN, output->eth.ctci))
+			goto nla_put_failure;
+		if (!swkey->eth.ctci)
+			goto unencap;
 	} else
 		encap = NULL;
 
@@ -2078,7 +2231,8 @@ static int __ovs_nla_copy_actions(const struct nlattr *attr,
 
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
