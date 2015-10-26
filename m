From: Thomas F Herbert <thomasfherbert@gmail.com>
Subject: [PATCH net-next V18 3/3] 802.1AD: Flow handling, actions, vlan parsing and netlink attributes
Date: Sun, 25 Oct 2015 20:11:26 -0400
Message-ID: <1445818286-4870-4-git-send-email-thomasfherbert@gmail.com>
References: <1445818286-4870-1-git-send-email-thomasfherbert@gmail.com>
Cc: therbert@redhat.com, dev@openvswitch.org,
	Thomas F Herbert <thomasfherbert@gmail.com>
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:34005 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497AbbJZANl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2015 20:13:41 -0400
Received: by qkfm62 with SMTP id m62so102803285qkf.1
        for <netdev@vger.kernel.org>; Sun, 25 Oct 2015 17:13:40 -0700 (PDT)
In-Reply-To: <1445818286-4870-1-git-send-email-thomasfherbert@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for 802.1ad including the ability to push and pop double
tagged vlans. Add support for 802.1ad to netlink parsing and flow
conversion. Uses double nested encap attributes to represent double
tagged vlan. Inner TPID encoded along with ctci in nested attributes. Outer
TPID is also encoded in the flow key.

Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
---
 net/openvswitch/actions.c      |   6 +-
 net/openvswitch/flow.c         |  76 ++++++++++++----
 net/openvswitch/flow.h         |   8 +-
 net/openvswitch/flow_netlink.c | 199 +++++++++++++++++++++++++++++++++++++----
 net/openvswitch/vport-netdev.c |   4 +-
 5 files changed, 252 insertions(+), 41 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 315f533..09cc1c9 100644
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
index c8db44a..ed19e2b 100644
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
index fe527d2..7ea8deb 100644
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
@@ -68,7 +73,8 @@ struct sw_flow_key {
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
index c92d6a2..7e90f8c 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -845,7 +845,7 @@ static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
 			return -EINVAL;
 		}
 
-		SW_FLOW_KEY_PUT(match, eth.tci, tci, is_mask);
+		SW_FLOW_KEY_PUT(match, eth.vlan.tci, tci, is_mask);
 		attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
 	}
 
@@ -1064,6 +1064,146 @@ static void mask_set_nlattr(struct nlattr *attr, u8 val)
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
+static int __parse_vlan_from_nlattrs(const struct nlattr **nla,
+				     struct sw_flow_match *match,
+				     u64 *key_attrs, bool inner,
+				     const struct nlattr **a, bool is_mask,
+				     bool log)
+{
+	int err;
+	u64 v_attrs = *key_attrs;
+
+	err = encode_vlan_from_nlattrs(match, a, is_mask, inner, log);
+	if (err)
+		return err;
+
+	v_attrs &= ~(1 << OVS_KEY_ATTR_ENCAP);
+
+	/* Insure that tci key attribute isn't
+	 * overwritten by encapsulated customer tci.
+	 * Ethertype is cleared because it is c_tpid.
+	 */
+	v_attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
+	v_attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
+
+	*key_attrs = v_attrs;
+
+	return 0;
+}
+
+static int parse_vlan_from_nlattrs(const struct nlattr **nla,
+				   struct sw_flow_match *match,
+				   u64 *key_attrs, bool *ie_valid,
+				   const struct nlattr **a, bool is_mask,
+				   bool log)
+{
+	int err;
+	const struct nlattr *encap;
+	u64 v_attrs = 0;
+
+	if (!is_mask) {
+		err = __parse_vlan_from_nlattrs(nla, match, key_attrs,
+						false, a, is_mask, log);
+		if (err)
+			return err;
+
+		/* Another encap attribute here indicates
+		 * the presence of a double tagged vlan.
+		 */
+		encap = a[OVS_KEY_ATTR_ENCAP];
+
+		err = parse_flow_nlattrs(encap, a, &v_attrs, log);
+		if (err)
+			return err;
+
+		if ((v_attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) &&
+		    eth_type_vlan(nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]))) {
+			if (!((v_attrs & (1 << OVS_KEY_ATTR_VLAN)) &&
+			      (v_attrs & (1 << OVS_KEY_ATTR_ENCAP)))) {
+				OVS_NLERR(log, "Invalid Inner VLAN frame");
+				return -EINVAL;
+			}
+			*ie_valid = true;
+			err = __parse_vlan_from_nlattrs(&encap, match, &v_attrs,
+							true, a, is_mask, log);
+			if (err)
+				return err;
+			*key_attrs |= v_attrs;
+		}
+	} else {
+		err = __parse_vlan_from_nlattrs(nla, match, key_attrs,
+						false, a, is_mask, log);
+		if (err)
+			return err;
+
+		encap = a[OVS_KEY_ATTR_ENCAP];
+
+		err = parse_flow_nlattrs(encap, a, &v_attrs, log);
+		if (err)
+			return err;
+
+		if (v_attrs & 1 << OVS_KEY_ATTR_ENCAP) {
+			if (!*ie_valid) {
+				OVS_NLERR(log, "Encap mask attribute is set for non-CVLAN frame.");
+				return -EINVAL;
+			}
+			err = __parse_vlan_from_nlattrs(nla, match,
+							&v_attrs, true, a,
+							is_mask,
+							log);
+			if (err)
+				return err;
+			*key_attrs |= v_attrs;
+		}
+	}
+	return 0;
+}
+
 /**
  * ovs_nla_get_match - parses Netlink attributes into a flow key and
  * mask. In case the 'mask' is NULL, the flow is treated as exact match
@@ -1091,6 +1231,7 @@ int ovs_nla_get_match(struct net *net, struct sw_flow_match *match,
 	u64 key_attrs = 0;
 	u64 mask_attrs = 0;
 	bool encap_valid = false;
+	bool i_encap_valid = false;
 	int err;
 
 	err = parse_flow_nlattrs(nla_key, a, &key_attrs, log);
@@ -1099,25 +1240,27 @@ int ovs_nla_get_match(struct net *net, struct sw_flow_match *match,
 
 	if ((key_attrs & (1 << OVS_KEY_ATTR_ETHERNET)) &&
 	    (key_attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) &&
-	    (nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]) == htons(ETH_P_8021Q))) {
+	    eth_type_vlan(nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]))) {
 		__be16 tci;
 
-		if (!((key_attrs & (1 << OVS_KEY_ATTR_VLAN)) &&
-		      (key_attrs & (1 << OVS_KEY_ATTR_ENCAP)))) {
+		if (!((key_attrs & (1ULL << OVS_KEY_ATTR_VLAN)) &&
+		      (key_attrs & (1ULL << OVS_KEY_ATTR_ENCAP)))) {
 			OVS_NLERR(log, "Invalid Vlan frame.");
 			return -EINVAL;
 		}
 
-		key_attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
 		tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
 		encap = a[OVS_KEY_ATTR_ENCAP];
-		key_attrs &= ~(1 << OVS_KEY_ATTR_ENCAP);
 		encap_valid = true;
 
 		if (tci & htons(VLAN_TAG_PRESENT)) {
-			err = parse_flow_nlattrs(encap, a, &key_attrs, log);
+			err = parse_vlan_from_nlattrs(&encap, match,
+						      &key_attrs,
+						      &i_encap_valid, a, false,
+						      log);
 			if (err)
 				return err;
+
 		} else if (!tci) {
 			/* Corner case for truncated 802.1Q header. */
 			if (nla_len(encap)) {
@@ -1169,7 +1312,7 @@ int ovs_nla_get_match(struct net *net, struct sw_flow_match *match,
 			goto free_newmask;
 
 		/* Always match on tci. */
-		SW_FLOW_KEY_PUT(match, eth.tci, htons(0xffff), true);
+		SW_FLOW_KEY_PUT(match, eth.vlan.tci, htons(0xffff), true);
 
 		if (mask_attrs & 1 << OVS_KEY_ATTR_ENCAP) {
 			__be16 eth_type = 0;
@@ -1188,10 +1331,13 @@ int ovs_nla_get_match(struct net *net, struct sw_flow_match *match,
 			if (eth_type == htons(0xffff)) {
 				mask_attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
 				encap = a[OVS_KEY_ATTR_ENCAP];
-				err = parse_flow_mask_nlattrs(encap, a,
-							      &mask_attrs, log);
+				err = parse_vlan_from_nlattrs(&nla_mask, match,
+							      &mask_attrs,
+							      &i_encap_valid,
+							      a, true, log);
 				if (err)
 					goto free_newmask;
+
 			} else {
 				OVS_NLERR(log, "VLAN frames must have an exact match on the TPID (mask=%x).",
 					  ntohs(eth_type));
@@ -1320,6 +1466,7 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
 {
 	struct ovs_key_ethernet *eth_key;
 	struct nlattr *nla, *encap;
+	struct nlattr *in_encap = NULL;
 
 	if (nla_put_u32(skb, OVS_KEY_ATTR_RECIRC_ID, output->recirc_id))
 		goto nla_put_failure;
@@ -1368,17 +1515,29 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
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
+			if (!swkey->eth.cvlan.tci)
+				goto unencap;
+		}
+	} else {
 		encap = NULL;
+	}
 
 	if (swkey->eth.type == htons(ETH_P_802_2)) {
 		/*
@@ -1523,6 +1682,8 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
 	}
 
 unencap:
+	if (in_encap)
+		nla_nest_end(skb, in_encap);
 	if (encap)
 		nla_nest_end(skb, encap);
 
@@ -2174,7 +2335,7 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 
 		case OVS_ACTION_ATTR_PUSH_VLAN:
 			vlan = nla_data(a);
-			if (vlan->vlan_tpid != htons(ETH_P_8021Q))
+			if (!eth_type_vlan(vlan->vlan_tpid))
 				return -EINVAL;
 			if (!(vlan->vlan_tci & htons(VLAN_TAG_PRESENT)))
 				return -EINVAL;
@@ -2279,7 +2440,7 @@ int ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 
 	(*sfa)->orig_len = nla_len(attr);
 	err = __ovs_nla_copy_actions(net, attr, key, 0, sfa, key->eth.type,
-				     key->eth.tci, log);
+				     key->eth.vlan.tci, log);
 	if (err)
 		ovs_nla_free_flow_actions(*sfa);
 
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index f7e8dcc..d2581b7 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -194,7 +194,9 @@ static unsigned int packet_length(const struct sk_buff *skb)
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
