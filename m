From: Thomas F Herbert <thomasfherbert@gmail.com>
Subject: [PATCH net-next V20 3/3] openvswitch: 802.1AD: Flow handling, actions, vlan parsing and netlink attributes
Date: Thu,  5 Nov 2015 14:34:05 -0500
Message-ID: <1446752045-5227-4-git-send-email-thomasfherbert@gmail.com>
References: <1446752045-5227-1-git-send-email-thomasfherbert@gmail.com>
Cc: therbert@redhat.com, dev@openvswitch.org,
	Thomas F Herbert <thomasfherbert@gmail.com>
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:34011 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754507AbbKETe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 14:34:27 -0500
Received: by qgeb1 with SMTP id b1so21968856qge.1
        for <netdev@vger.kernel.org>; Thu, 05 Nov 2015 11:34:26 -0800 (PST)
In-Reply-To: <1446752045-5227-1-git-send-email-thomasfherbert@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for 802.1ad including the ability to push and pop double
tagged vlans. Add support for 802.1ad to netlink parsing and flow
conversion. Uses double nested encap attributes to represent double
tagged vlan. Inner TPID encoded along with ctci in nested attributes.
vport has vlan mtu adjustment added for double tagged vlans.

Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
---
 net/openvswitch/actions.c      |   6 +-
 net/openvswitch/flow.c         |  76 ++++++++++----
 net/openvswitch/flow.h         |   8 +-
 net/openvswitch/flow_netlink.c | 233 ++++++++++++++++++++++++++++++-----------
 net/openvswitch/vport.c        |   4 +-
 5 files changed, 245 insertions(+), 82 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 221fa8b..2b4d001 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -236,7 +236,8 @@ static int pop_vlan(struct sk_buff *skb, struct sw_flow_key *key)
 	if (skb_vlan_tag_present(skb))
 		invalidate_flow_key(key);
 	else
-		key->eth.tci = 0;
+		key->eth.vlan.tci = 0;
+		key->eth.vlan.tpid = 0;
 	return err;
 }
 
@@ -246,7 +247,8 @@ static int push_vlan(struct sk_buff *skb, struct sw_flow_key *key,
 	if (skb_vlan_tag_present(skb))
 		invalidate_flow_key(key);
 	else
-		key->eth.tci = vlan->vlan_tci;
+		key->eth.vlan.tci = vlan->vlan_tci;
+		key->eth.vlan.tpid = vlan->vlan_tpid;
 	return skb_vlan_push(skb, vlan->vlan_tpid,
 			     ntohs(vlan->vlan_tci) & ~VLAN_TAG_PRESENT);
 }
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 0ea128e..e8d6bba 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -302,24 +302,68 @@ static bool icmp6hdr_ok(struct sk_buff *skb)
 				  sizeof(struct icmp6hdr));
 }
 
-static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
+/* Parse vlan tag from vlan header.
+ * Returns ERROR on memory error.
+ * Returns 0 if it encounters a non-vlan or incomplete packet.
+ * Returns 1 after successfully parsing vlan tag.
+ */
+
+static int parse_vlan_tag(struct sk_buff *skb, struct vlan_head *vlan)
 {
-	struct qtag_prefix {
-		__be16 eth_type; /* ETH_P_8021Q */
-		__be16 tci;
-	};
-	struct qtag_prefix *qp;
+	struct vlan_head *qp = (struct vlan_head *)skb->data;
+
+	if (likely(!eth_type_vlan(qp->tpid)))
+		return 0;
 
-	if (unlikely(skb->len < sizeof(struct qtag_prefix) + sizeof(__be16)))
+	if (unlikely(skb->len < sizeof(struct vlan_head) + sizeof(__be16)))
 		return 0;
 
-	if (unlikely(!pskb_may_pull(skb, sizeof(struct qtag_prefix) +
-					 sizeof(__be16))))
+	if (unlikely(!pskb_may_pull(skb, sizeof(struct vlan_head) +
+				 sizeof(__be16))))
 		return -ENOMEM;
 
-	qp = (struct qtag_prefix *) skb->data;
-	key->eth.tci = qp->tci | htons(VLAN_TAG_PRESENT);
-	__skb_pull(skb, sizeof(struct qtag_prefix));
+	vlan->tci = qp->tci | htons(VLAN_TAG_PRESENT);
+	vlan->tpid = qp->tpid;
+
+	__skb_pull(skb, sizeof(struct vlan_head));
+	return 1;
+}
+
+static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
+{
+	int res;
+
+	key->eth.vlan.tci = 0;
+	key->eth.vlan.tpid = 0;
+	key->eth.cvlan.tci = 0;
+	key->eth.cvlan.tpid = 0;
+
+	if (likely(skb_vlan_tag_present(skb))) {
+		key->eth.vlan.tci = htons(skb->vlan_tci);
+		key->eth.vlan.tpid = skb->vlan_proto;
+
+		/* Case where ingress processing has already stripped
+		 * the outer vlan tag.
+		 */
+		res = parse_vlan_tag(skb, &key->eth.cvlan);
+		if (res < 0)
+			return res;
+		/* For inner tag, return 0 because neither
+		 * non-existent nor partial inner tag is an error.
+		 */
+		return 0;
+	}
+	res = parse_vlan_tag(skb, &key->eth.vlan);
+	if (res <= 0)
+		/* This is an outer tag in the non-accelerated VLAN
+		 * case. Return error unless it is a complete vlan tag.
+		 */
+		return res;
+
+	/* Parse inner vlan tag if present for non-accelerated case. */
+	res = parse_vlan_tag(skb, &key->eth.cvlan);
+	if (res <= 0)
+		return res;
 
 	return 0;
 }
@@ -480,12 +524,8 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 	 * update skb->csum here.
 	 */
 
-	key->eth.tci = 0;
-	if (skb_vlan_tag_present(skb))
-		key->eth.tci = htons(skb->vlan_tci);
-	else if (eth->h_proto == htons(ETH_P_8021Q))
-		if (unlikely(parse_vlan(skb, key)))
-			return -ENOMEM;
+	if (unlikely(parse_vlan(skb, key)))
+		return -ENOMEM;
 
 	key->eth.type = parse_ethertype(skb);
 	if (unlikely(key->eth.type == htons(0)))
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 1d055c5..97821dd 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -50,6 +50,11 @@ struct ovs_tunnel_info {
 	struct metadata_dst	*tun_dst;
 };
 
+struct vlan_head {
+	__be16 tpid;	/* Vlan type. Generally 802.1q or 802.1ad.*/
+	__be16 tci;	/* 0 if no VLAN, VLAN_TAG_PRESENT set otherwise. */
+};
+
 #define OVS_SW_FLOW_KEY_METADATA_SIZE			\
 	(offsetof(struct sw_flow_key, recirc_id) +	\
 	FIELD_SIZEOF(struct sw_flow_key, recirc_id))
@@ -69,7 +74,8 @@ struct sw_flow_key {
 	struct {
 		u8     src[ETH_ALEN];	/* Ethernet source address. */
 		u8     dst[ETH_ALEN];	/* Ethernet destination address. */
-		__be16 tci;		/* 0 if no VLAN, VLAN_TAG_PRESENT set otherwise. */
+		struct vlan_head vlan;
+		struct vlan_head cvlan;
 		__be16 type;		/* Ethernet frame type. */
 	} eth;
 	union {
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 907d6fd..d098f30 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -934,7 +934,7 @@ static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
 			return -EINVAL;
 		}
 
-		SW_FLOW_KEY_PUT(match, eth.tci, tci, is_mask);
+		SW_FLOW_KEY_PUT(match, eth.vlan.tci, tci, is_mask);
 		attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
 	}
 
@@ -1159,6 +1159,140 @@ static void mask_set_nlattr(struct nlattr *attr, u8 val)
 	nlattr_set(attr, val, ovs_key_lens);
 }
 
+static int encode_vlan_from_nlattrs(struct sw_flow_match *match,
+				    const struct nlattr *a[],
+				    bool is_mask, bool inner, bool log)
+{
+	__be16 tci = 0;
+	__be16 tpid = 0;
+
+	if (a[OVS_KEY_ATTR_VLAN])
+		tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
+
+	if (a[OVS_KEY_ATTR_ETHERTYPE])
+		tpid = nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]);
+
+	if (is_mask && tpid != htons(0xffff)) {
+		if (likely(!inner))
+			OVS_NLERR(log, "VLAN frames must have an exact match on the TPID (mask=%x).",
+				  ntohs(tpid));
+		else
+			OVS_NLERR(log, "VLAN frames must have an exact match on the CTPID (mask=%x).",
+				  ntohs(tpid));
+		return -EINVAL;
+	}
+	if (!(tci & htons(VLAN_TAG_PRESENT))) {
+		if (is_mask)
+			if (likely(!inner))
+				OVS_NLERR(log, "VLAN TCI mask does not have exact match for VLAN_TAG_PRESENT bit.");
+			else
+				OVS_NLERR(log, "VLAN CTCI mask does not have exact match for VLAN_TAG_PRESENT bit.");
+		else
+			if (likely(!inner))
+				OVS_NLERR(log, "VLAN TCI does not have VLAN_TAG_PRESENT bit set.");
+			else
+				OVS_NLERR(log, "VLAN CTCI does not have VLAN_TAG_PRESENT bit set.");
+		return -EINVAL;
+	}
+	if (likely(!inner)) {
+		SW_FLOW_KEY_PUT(match, eth.vlan.tpid, tpid, is_mask);
+		SW_FLOW_KEY_PUT(match, eth.vlan.tci, tci, is_mask);
+	} else {
+		SW_FLOW_KEY_PUT(match, eth.cvlan.tpid, tpid, is_mask);
+		SW_FLOW_KEY_PUT(match, eth.cvlan.tci, tci, is_mask);
+	}
+	return 0;
+}
+
+static int __parse_vlan_from_nlattrs(struct sw_flow_match *match,
+				     u64 *key_attrs, u64 *en_attrs, bool inner,
+				     const struct nlattr **a, bool is_mask,
+				     bool log)
+{
+	int err;
+	u64 attrs = *key_attrs;
+	const struct nlattr *encap;
+
+	err = encode_vlan_from_nlattrs(match, a, is_mask, inner, log);
+	if (err)
+		return err;
+
+	attrs &= ~(1 << OVS_KEY_ATTR_ENCAP);
+
+	/* Insure that tci key attribute isn't
+	 * overwritten by encapsulated customer tci.
+	 * Ethertype is cleared because it is c_tpid.
+	 */
+	attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
+	attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
+
+	encap = a[OVS_KEY_ATTR_ENCAP];
+
+	*key_attrs = attrs;
+
+	if (unlikely(inner)) {
+		err = parse_flow_nlattrs(encap, a, en_attrs, log);
+		if (err)
+			return err;
+	}
+	return 0;
+}
+
+static int parse_vlan_from_nlattrs(struct sw_flow_match *match,
+				   u64 *key_attrs, bool *ie_valid,
+				   const struct nlattr **a, bool is_mask,
+				   bool log)
+{
+	int err;
+	u64 v_attrs = 0;
+
+	if (!is_mask) {
+		err = __parse_vlan_from_nlattrs(match, key_attrs, &v_attrs,
+						false, a, is_mask, log);
+		if (err)
+			return err;
+
+
+		if ((v_attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) &&
+		    eth_type_vlan(nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]))) {
+			u64 en_attrs = 0;
+
+			if (!((v_attrs & (1 << OVS_KEY_ATTR_VLAN)) &&
+			      (v_attrs & (1 << OVS_KEY_ATTR_ENCAP)))) {
+				OVS_NLERR(log, "Invalid Inner VLAN frame");
+				return -EINVAL;
+			}
+			*ie_valid = true;
+			err = __parse_vlan_from_nlattrs(match, &v_attrs, &en_attrs,
+							true, a, is_mask, log);
+			if (err)
+				return err;
+			*key_attrs |= en_attrs;
+		}
+	} else {
+		err = __parse_vlan_from_nlattrs(match, key_attrs, &v_attrs,
+						false, a, is_mask, log);
+		if (err)
+			return err;
+
+		if (v_attrs & (1 << OVS_KEY_ATTR_ENCAP)) {
+			u64 en_attrs = 0;
+
+			if (!*ie_valid) {
+				OVS_NLERR(log, "Encap mask attribute is set for non-CVLAN frame.");
+				return -EINVAL;
+			}
+			err = __parse_vlan_from_nlattrs(match, &v_attrs,
+							&en_attrs, true,
+							a, is_mask, log);
+			if (err)
+				return err;
+			*key_attrs |= en_attrs;
+		}
+	}
+	return 0;
+}
+
 /**
  * ovs_nla_get_match - parses Netlink attributes into a flow key and
  * mask. In case the 'mask' is NULL, the flow is treated as exact match
@@ -1181,11 +1315,11 @@ int ovs_nla_get_match(struct net *net, struct sw_flow_match *match,
 		      bool log)
 {
 	const struct nlattr *a[OVS_KEY_ATTR_MAX + 1];
-	const struct nlattr *encap;
 	struct nlattr *newmask = NULL;
 	u64 key_attrs = 0;
 	u64 mask_attrs = 0;
 	bool encap_valid = false;
+	bool i_encap_valid = false;
 	int err;
 
 	err = parse_flow_nlattrs(nla_key, a, &key_attrs, log);
@@ -1194,35 +1328,20 @@ int ovs_nla_get_match(struct net *net, struct sw_flow_match *match,
 
 	if ((key_attrs & (1 << OVS_KEY_ATTR_ETHERNET)) &&
 	    (key_attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) &&
-	    (nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]) == htons(ETH_P_8021Q))) {
-		__be16 tci;
+	    eth_type_vlan(nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]))) {
 
 		if (!((key_attrs & (1 << OVS_KEY_ATTR_VLAN)) &&
 		      (key_attrs & (1 << OVS_KEY_ATTR_ENCAP)))) {
 			OVS_NLERR(log, "Invalid Vlan frame.");
 			return -EINVAL;
 		}
-
-		key_attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
-		tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
-		encap = a[OVS_KEY_ATTR_ENCAP];
-		key_attrs &= ~(1 << OVS_KEY_ATTR_ENCAP);
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
+		err = parse_vlan_from_nlattrs(match, &key_attrs,
+					      &i_encap_valid, a, false,
+					      log);
+		if (err)
+			return err;
 	}
 
 	err = ovs_key_from_nlattrs(net, match, key_attrs, a, false, log);
@@ -1255,7 +1374,6 @@ int ovs_nla_get_match(struct net *net, struct sw_flow_match *match,
 			if (match->key->tun_proto)
 				SW_FLOW_KEY_MEMSET_FIELD(match, tun_key,
 							 0xff, true);
-
 			nla_mask = newmask;
 		}
 
@@ -1264,11 +1382,10 @@ int ovs_nla_get_match(struct net *net, struct sw_flow_match *match,
 			goto free_newmask;
 
 		/* Always match on tci. */
-		SW_FLOW_KEY_PUT(match, eth.tci, htons(0xffff), true);
+		SW_FLOW_KEY_PUT(match, eth.vlan.tci, htons(0xffff), true);
+		SW_FLOW_KEY_PUT(match, eth.cvlan.tci, htons(0xffff), true);
 
 		if (mask_attrs & 1 << OVS_KEY_ATTR_ENCAP) {
-			__be16 eth_type = 0;
-			__be16 tci = 0;
 
 			if (!encap_valid) {
 				OVS_NLERR(log, "Encap mask attribute is set for non-VLAN frame.");
@@ -1277,32 +1394,13 @@ int ovs_nla_get_match(struct net *net, struct sw_flow_match *match,
 			}
 
 			mask_attrs &= ~(1 << OVS_KEY_ATTR_ENCAP);
-			if (a[OVS_KEY_ATTR_ETHERTYPE])
-				eth_type = nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]);
-
-			if (eth_type == htons(0xffff)) {
-				mask_attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
-				encap = a[OVS_KEY_ATTR_ENCAP];
-				err = parse_flow_mask_nlattrs(encap, a,
-							      &mask_attrs, log);
-				if (err)
-					goto free_newmask;
-			} else {
-				OVS_NLERR(log, "VLAN frames must have an exact match on the TPID (mask=%x).",
-					  ntohs(eth_type));
-				err = -EINVAL;
-				goto free_newmask;
-			}
-
-			if (a[OVS_KEY_ATTR_VLAN])
-				tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
+			mask_attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
 
-			if (!(tci & htons(VLAN_TAG_PRESENT))) {
-				OVS_NLERR(log, "VLAN tag present bit must have an exact match (tci_mask=%x).",
-					  ntohs(tci));
-				err = -EINVAL;
+			err = parse_vlan_from_nlattrs(match, &mask_attrs,
+						      &i_encap_valid,
+						      a, true, log);
+			if (err)
 				goto free_newmask;
-			}
 		}
 
 		err = ovs_key_from_nlattrs(net, match, mask_attrs, a, true,
@@ -1415,6 +1513,7 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
 {
 	struct ovs_key_ethernet *eth_key;
 	struct nlattr *nla, *encap;
+	struct nlattr *in_encap = NULL;
 
 	if (nla_put_u32(skb, OVS_KEY_ATTR_RECIRC_ID, output->recirc_id))
 		goto nla_put_failure;
@@ -1463,17 +1562,29 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
 	ether_addr_copy(eth_key->eth_src, output->eth.src);
 	ether_addr_copy(eth_key->eth_dst, output->eth.dst);
 
-	if (swkey->eth.tci || swkey->eth.type == htons(ETH_P_8021Q)) {
-		__be16 eth_type;
-		eth_type = !is_mask ? htons(ETH_P_8021Q) : htons(0xffff);
-		if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, eth_type) ||
-		    nla_put_be16(skb, OVS_KEY_ATTR_VLAN, output->eth.tci))
+	if (swkey->eth.vlan.tci || eth_type_vlan(swkey->eth.type)) {
+		if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE,
+				 output->eth.vlan.tpid) ||
+		    nla_put_be16(skb, OVS_KEY_ATTR_VLAN, output->eth.vlan.tci))
 			goto nla_put_failure;
 		encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
-		if (!swkey->eth.tci)
+		if (!swkey->eth.vlan.tci)
 			goto unencap;
-	} else
+		if (swkey->eth.cvlan.tci) {
+			/* Customer tci is nested but uses same key attribute.
+			 */
+			if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE,
+					 output->eth.cvlan.tpid) ||
+			    nla_put_be16(skb, OVS_KEY_ATTR_VLAN,
+					 output->eth.cvlan.tci))
+				goto nla_put_failure;
+			in_encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
+		} else {
+			goto unencap;
+		}
+	} else {
 		encap = NULL;
+	}
 
 	if (swkey->eth.type == htons(ETH_P_802_2)) {
 		/*
@@ -1618,6 +1729,8 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
 	}
 
 unencap:
+	if (in_encap)
+		nla_nest_end(skb, in_encap);
 	if (encap)
 		nla_nest_end(skb, encap);
 
@@ -2270,7 +2383,7 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 
 		case OVS_ACTION_ATTR_PUSH_VLAN:
 			vlan = nla_data(a);
-			if (vlan->vlan_tpid != htons(ETH_P_8021Q))
+			if (!eth_type_vlan(vlan->vlan_tpid))
 				return -EINVAL;
 			if (!(vlan->vlan_tci & htons(VLAN_TAG_PRESENT)))
 				return -EINVAL;
@@ -2375,7 +2488,7 @@ int ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 
 	(*sfa)->orig_len = nla_len(attr);
 	err = __ovs_nla_copy_actions(net, attr, key, 0, sfa, key->eth.type,
-				     key->eth.tci, log);
+				     key->eth.vlan.tci, log);
 	if (err)
 		ovs_nla_free_flow_actions(*sfa);
 
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 0ac0fd0..62b6979 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -484,7 +484,9 @@ static unsigned int packet_length(const struct sk_buff *skb)
 {
 	unsigned int length = skb->len - ETH_HLEN;
 
-	if (skb->protocol == htons(ETH_P_8021Q))
+	if (eth_type_vlan(skb->protocol))
+		length -= VLAN_HLEN;
+	if (skb->protocol == htons(ETH_P_8021AD))
 		length -= VLAN_HLEN;
 
 	return length;
-- 
2.4.3
