From: Thomas F Herbert <thomasfherbert@gmail.com>
Subject: [PATCH net-next V7 2/2] openvswitch: 802.1ad: Flow handling, actions, and vlan parsing
Date: Tue, 28 Apr 2015 18:44:19 -0400
Message-ID: <1430261059-7920-3-git-send-email-thomasfherbert@gmail.com>
References: <1430261059-7920-1-git-send-email-thomasfherbert@gmail.com>
Cc: therbert@redhat.com, ccp@atcnet.net,
	Thomas F Herbert <thomasfherbert@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vn0-f45.google.com ([209.85.216.45]:44824 "EHLO
	mail-vn0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031314AbbD1Wo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 18:44:59 -0400
Received: by vnbg7 with SMTP id g7so1365830vnb.11
        for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 15:44:58 -0700 (PDT)
In-Reply-To: <1430261059-7920-1-git-send-email-thomasfherbert@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for 802.1ad including the ability to push and pop double
tagged vlans.

Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
---
 net/openvswitch/actions.c      |  6 ++-
 net/openvswitch/flow.c         | 83 +++++++++++++++++++++++++++++++++++-------
 net/openvswitch/flow.h         |  1 +
 net/openvswitch/flow_netlink.c | 81 ++++++++++++++++++++++++++++++++++++++---
 4 files changed, 151 insertions(+), 20 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index b491c1c..0831019 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -219,7 +219,8 @@ static int pop_vlan(struct sk_buff *skb, struct sw_flow_key *key)
 	int err;
 
 	err = skb_vlan_pop(skb);
-	if (skb_vlan_tag_present(skb))
+	if (skb_vlan_tag_present(skb) &&
+	    skb->protocol != htons(ETH_P_8021Q))
 		invalidate_flow_key(key);
 	else
 		key->eth.tci = 0;
@@ -229,7 +230,8 @@ static int pop_vlan(struct sk_buff *skb, struct sw_flow_key *key)
 static int push_vlan(struct sk_buff *skb, struct sw_flow_key *key,
 		     const struct ovs_action_push_vlan *vlan)
 {
-	if (skb_vlan_tag_present(skb))
+	if (skb_vlan_tag_present(skb) &&
+	    skb->protocol != htons(ETH_P_8021Q))
 		invalidate_flow_key(key);
 	else
 		key->eth.tci = vlan->vlan_tci;
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 2dacc7b..6989451 100644
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
+	struct qtag_prefix *qp = (struct qtag_prefix *) skb->data;
 
-	if (unlikely(skb->len < sizeof(struct qtag_prefix) + sizeof(__be16)))
-		return 0;
+	struct qinqtag_prefix {
+		__be16 eth_type; /* ETH_P_8021Q  or ETH_P_8021AD */
+		__be16 tci;
+		__be16 inner_tpid; /* ETH_P_8021Q */
+		__be16 ctci;
+	};
+
+	if (likely(skb_vlan_tag_present(skb))) {
+
+		key->eth.tci = htons(skb->vlan_tci);
+
+		/*
+		 * Case where upstream
+		 * processing has already stripped the outer vlan tag.
+		 */
+		if (unlikely(skb->vlan_proto == htons(ETH_P_8021AD))) {
+
+			if (unlikely(skb->len < sizeof(struct qtag_prefix) +
+					sizeof(__be16)))
+				return 0;
+
+			if (unlikely(!pskb_may_pull(skb, sizeof(struct qtag_prefix) +
+					sizeof(__be16)))) {
+				return -ENOMEM;
+			}
+
+			if (likely(qp->eth_type == htons(ETH_P_8021Q))) {
+				key->eth.ctci = qp->tci | htons(VLAN_TAG_PRESENT);
+				__skb_pull(skb, sizeof(struct qtag_prefix));
+			}
+		}
+                return 0;
+	}
 
-	if (unlikely(!pskb_may_pull(skb, sizeof(struct qtag_prefix) +
-					 sizeof(__be16))))
-		return -ENOMEM;
 
-	qp = (struct qtag_prefix *) skb->data;
-	key->eth.tci = qp->tci | htons(VLAN_TAG_PRESENT);
-	__skb_pull(skb, sizeof(struct qtag_prefix));
+        if (qp->eth_type == htons(ETH_P_8021AD)) {
+	        struct qinqtag_prefix *qinqp = (struct qinqtag_prefix *) skb->data;
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
+                return 0;
+
+	}
+        if (qp->eth_type == htons(ETH_P_8021Q)) {
+
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
@@ -474,9 +531,9 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 	 */
 
 	key->eth.tci = 0;
-	if (skb_vlan_tag_present(skb))
-		key->eth.tci = htons(skb->vlan_tci);
-	else if (eth->h_proto == htons(ETH_P_8021Q))
+	if ((skb_vlan_tag_present(skb)) ||
+	    (eth->h_proto == htons(ETH_P_8021Q)) ||
+	    (eth->h_proto == htons(ETH_P_8021AD)))
 		if (unlikely(parse_vlan(skb, key)))
 			return -ENOMEM;
 
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index a076e44..1057de6 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -134,6 +134,7 @@ struct sw_flow_key {
 		u8     src[ETH_ALEN];	/* Ethernet source address. */
 		u8     dst[ETH_ALEN];	/* Ethernet destination address. */
 		__be16 tci;		/* 0 if no VLAN, VLAN_TAG_PRESENT set otherwise. */
+		__be16 ctci;		/* 0 if no CVLAN, VLAN_TAG_PRESENT set otherwise. */
 		__be16 type;		/* Ethernet frame type. */
 	} eth;
 	union {
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index c691b1a..4a7ff38 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -770,6 +770,28 @@ static int metadata_from_nlattrs(struct sw_flow_match *match,  u64 *attrs,
 	}
 	return 0;
 }
+static int ovs_nested_vlan_from_nlattrs(struct sw_flow_match *match,
+					u64 attrs, const struct nlattr **a,
+					bool is_mask, bool log)
+{
+        /* This should be nested inner or "customer" tci" */
+	if (attrs & (1 << OVS_KEY_ATTR_VLAN)) {
+		__be16 ctci;
+
+		ctci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
+		if (!(ctci & htons(VLAN_TAG_PRESENT))) {
+			if (is_mask)
+				OVS_NLERR(log, "VLAN TCI mask does not have exact match for VLAN_TAG_PRESENT bit.");
+			else
+				OVS_NLERR(log, "VLAN TCI does not have VLAN_TAG_PRESENT bit set.");
+
+			return -EINVAL;
+		}
+
+		SW_FLOW_KEY_PUT(match, eth.ctci, ctci, is_mask);
+	}
+	return 0;
+}
 
 static int ovs_key_from_nlattrs(struct sw_flow_match *match, u64 attrs,
 				const struct nlattr **a, bool is_mask,
@@ -1049,6 +1071,8 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 	struct nlattr *newmask = NULL;
 	u64 key_attrs = 0;
 	u64 mask_attrs = 0;
+	u64 v_attrs = 0;
+	u64 mask_v_attrs = 0;
 	bool encap_valid = false;
 	int err;
 
@@ -1058,7 +1082,8 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 
 	if ((key_attrs & (1 << OVS_KEY_ATTR_ETHERNET)) &&
 	    (key_attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) &&
-	    (nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]) == htons(ETH_P_8021Q))) {
+	    ((nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]) == htons(ETH_P_8021Q)) ||
+	     (nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]) == htons(ETH_P_8021AD)))) {
 		__be16 tci;
 
 		if (!((key_attrs & (1 << OVS_KEY_ATTR_VLAN)) &&
@@ -1074,9 +1099,28 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 		encap_valid = true;
 
 		if (tci & htons(VLAN_TAG_PRESENT)) {
-			err = parse_flow_nlattrs(encap, a, &key_attrs, log);
-			if (err)
-				return err;
+
+			if (unlikely((nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]) ==
+			    htons(ETH_P_8021AD)))) {
+
+				err = parse_flow_nlattrs(encap, a, &v_attrs, log);
+				if (err)
+					return err;
+				if (v_attrs) {
+					err = ovs_nested_vlan_from_nlattrs(match, v_attrs, a, false, log);
+					if (err)
+						return err;
+				}
+				/* Insure that tci key attribute isn't overwritten by
+				 * encapsulated customer tci.
+				 */
+				v_attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
+				key_attrs |= v_attrs;
+			} else {
+				err = parse_flow_nlattrs(encap, a, &key_attrs, log);
+				if (err)
+					return err;
+			}
 		} else if (!tci) {
 			/* Corner case for truncated 802.1Q header. */
 			if (nla_len(encap)) {
@@ -1133,6 +1177,7 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 		if (mask_attrs & 1 << OVS_KEY_ATTR_ENCAP) {
 			__be16 eth_type = 0;
 			__be16 tci = 0;
+			__be16 ctci = 0;
 
 			if (!encap_valid) {
 				OVS_NLERR(log, "Encap mask attribute is set for non-VLAN frame.");
@@ -1167,6 +1212,22 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 				err = -EINVAL;
 				goto free_newmask;
 			}
+			err = parse_flow_mask_nlattrs(encap, a, &mask_v_attrs, log);
+			if (err)
+				goto free_newmask;
+
+			if (mask_v_attrs & (1ULL << OVS_KEY_ATTR_VLAN)) {
+				ctci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
+				if (!(ctci & htons(VLAN_TAG_PRESENT))) {
+					OVS_NLERR(log, "VLAN ctag present bit must have an exact match (ctci_mask=%x).",
+					          ntohs(ctci));
+					err = -EINVAL;
+					goto free_newmask;
+				}
+				mask_v_attrs &= ~(1ULL << OVS_KEY_ATTR_VLAN);
+				mask_attrs |= mask_v_attrs;
+			}
+
 		}
 
 		err = ovs_key_from_nlattrs(match, mask_attrs, a, true, log);
@@ -1331,6 +1392,15 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
 		encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
 		if (!swkey->eth.tci)
 			goto unencap;
+	} else if (swkey->eth.tci || swkey->eth.type == htons(ETH_P_8021AD)) {
+		__be16 eth_type;
+		eth_type = !is_mask ? htons(ETH_P_8021AD) : htons(0xffff);
+		if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, eth_type) ||
+		    nla_put_be16(skb, OVS_KEY_ATTR_VLAN, output->eth.tci))
+			goto nla_put_failure;
+		encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
+		if (!swkey->eth.tci)
+			goto unencap;
 	} else
 		encap = NULL;
 
@@ -2078,7 +2148,8 @@ static int __ovs_nla_copy_actions(const struct nlattr *attr,
 
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
