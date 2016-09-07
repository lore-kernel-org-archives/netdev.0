From: Eric Garver <e@erig.me>
Subject: [PATCH net-next v22 3/3] openvswitch: 802.1AD Flow handling, actions, vlan parsing, netlink attributes
Date: Wed,  7 Sep 2016 12:56:59 -0400
Message-ID: <1473267419-6825-4-git-send-email-e@erig.me>
References: <1473267419-6825-1-git-send-email-e@erig.me>
Cc: dev@openvswitch.org, Thomas F Herbert <thomasfherbert@gmail.com>,
        Xiao Liang <shaw.leon@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49024 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933182AbcIGQ5D (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Sep 2016 12:57:03 -0400
In-Reply-To: <1473267419-6825-1-git-send-email-e@erig.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for 802.1ad including the ability to push and pop double
tagged vlans. Add support for 802.1ad to netlink parsing and flow
conversion. Uses double nested encap attributes to represent double
tagged vlan. Inner TPID encoded along with ctci in nested attributes.

This is based on Thomas F Herbert's original v20 patch. I made some
small clean ups and bug fixes.

Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
Signed-off-by: Eric Garver <e@erig.me>
---
 net/openvswitch/actions.c      |  16 ++-
 net/openvswitch/flow.c         |  65 ++++++---
 net/openvswitch/flow.h         |   8 +-
 net/openvswitch/flow_netlink.c | 310 ++++++++++++++++++++++++++++-------------
 net/openvswitch/vport.c        |   7 +-
 5 files changed, 282 insertions(+), 124 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index ca91fc33f8a9..4fe9032b1160 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -246,20 +246,24 @@ static int pop_vlan(struct sk_buff *skb, struct sw_flow_key *key)
 	int err;
 
 	err = skb_vlan_pop(skb);
-	if (skb_vlan_tag_present(skb))
+	if (skb_vlan_tag_present(skb)) {
 		invalidate_flow_key(key);
-	else
-		key->eth.tci = 0;
+	} else {
+		key->eth.vlan.tci = 0;
+		key->eth.vlan.tpid = 0;
+	}
 	return err;
 }
 
 static int push_vlan(struct sk_buff *skb, struct sw_flow_key *key,
 		     const struct ovs_action_push_vlan *vlan)
 {
-	if (skb_vlan_tag_present(skb))
+	if (skb_vlan_tag_present(skb)) {
 		invalidate_flow_key(key);
-	else
-		key->eth.tci = vlan->vlan_tci;
+	} else {
+		key->eth.vlan.tci = vlan->vlan_tci;
+		key->eth.vlan.tpid = vlan->vlan_tpid;
+	}
 	return skb_vlan_push(skb, vlan->vlan_tpid,
 			     ntohs(vlan->vlan_tci) & ~VLAN_TAG_PRESENT);
 }
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 0ea128eeeab2..1240ae3b88d2 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -302,24 +302,57 @@ static bool icmp6hdr_ok(struct sk_buff *skb)
 				  sizeof(struct icmp6hdr));
 }
 
-static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
+/**
+ * Parse vlan tag from vlan header.
+ * Returns ERROR on memory error.
+ * Returns 0 if it encounters a non-vlan or incomplete packet.
+ * Returns 1 after successfully parsing vlan tag.
+ */
+static int parse_vlan_tag(struct sk_buff *skb, struct vlan_head *key_vh)
 {
-	struct qtag_prefix {
-		__be16 eth_type; /* ETH_P_8021Q */
-		__be16 tci;
-	};
-	struct qtag_prefix *qp;
+	struct vlan_head *vh = (struct vlan_head *)skb->data;
 
-	if (unlikely(skb->len < sizeof(struct qtag_prefix) + sizeof(__be16)))
+	if (likely(!eth_type_vlan(vh->tpid)))
 		return 0;
 
-	if (unlikely(!pskb_may_pull(skb, sizeof(struct qtag_prefix) +
-					 sizeof(__be16))))
+	if (unlikely(skb->len < sizeof(struct vlan_head) + sizeof(__be16)))
+		return 0;
+
+	if (unlikely(!pskb_may_pull(skb, sizeof(struct vlan_head) +
+				 sizeof(__be16))))
 		return -ENOMEM;
 
-	qp = (struct qtag_prefix *) skb->data;
-	key->eth.tci = qp->tci | htons(VLAN_TAG_PRESENT);
-	__skb_pull(skb, sizeof(struct qtag_prefix));
+	vh = (struct vlan_head *)skb->data;
+	key_vh->tci = vh->tci | htons(VLAN_TAG_PRESENT);
+	key_vh->tpid = vh->tpid;
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
+	} else {
+		/* Parse outer vlan tag in the non-accelerated case. */
+		res = parse_vlan_tag(skb, &key->eth.vlan);
+		if (res <= 0)
+			return res;
+	}
+
+	/* Parse inner vlan tag. */
+	res = parse_vlan_tag(skb, &key->eth.cvlan);
+	if (res <= 0)
+		return res;
 
 	return 0;
 }
@@ -480,12 +513,8 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
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
index 03378e75a67c..156a3029c17b 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -50,6 +50,11 @@ struct ovs_tunnel_info {
 	struct metadata_dst	*tun_dst;
 };
 
+struct vlan_head {
+	__be16 tpid; /* Vlan type. Generally 802.1q or 802.1ad.*/
+	__be16 tci;  /* 0 if no VLAN, VLAN_TAG_PRESENT set otherwise. */
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
index c78a6a1476fb..8efa718ddb5e 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -808,6 +808,167 @@ int ovs_nla_put_tunnel_info(struct sk_buff *skb,
 				  ip_tunnel_info_af(tun_info));
 }
 
+static int encode_vlan_from_nlattrs(struct sw_flow_match *match,
+				    const struct nlattr *a[],
+				    bool is_mask, bool inner)
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
+static int validate_vlan_from_nlattrs(const struct sw_flow_match *match,
+				      u64 key_attrs, bool inner,
+				      const struct nlattr **a, bool log)
+{
+	__be16 tci = 0;
+
+	if (!((key_attrs & (1 << OVS_KEY_ATTR_ETHERNET)) &&
+	      (key_attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) &&
+	       eth_type_vlan(nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE])))) {
+		/* Not a VLAN. */
+		return 0;
+	}
+
+	if (!((key_attrs & (1 << OVS_KEY_ATTR_VLAN)) &&
+	      (key_attrs & (1 << OVS_KEY_ATTR_ENCAP)))) {
+		OVS_NLERR(log, "Invalid %s frame", (inner) ? "C-VLAN" : "VLAN");
+		return -EINVAL;
+	}
+
+	if (a[OVS_KEY_ATTR_VLAN])
+		tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
+
+	if (!(tci & htons(VLAN_TAG_PRESENT))) {
+		if (tci) {
+			OVS_NLERR(log, "%s TCI does not have VLAN_TAG_PRESENT bit set.",
+				  (inner) ? "C-VLAN" : "VLAN");
+			return -EINVAL;
+		} else if (nla_len(a[OVS_KEY_ATTR_ENCAP])) {
+			/* Corner case for truncated VLAN header. */
+			OVS_NLERR(log, "Truncated %s header has non-zero encap attribute.",
+				  (inner) ? "C-VLAN" : "VLAN");
+			return -EINVAL;
+		}
+	}
+
+	return 1;
+}
+
+static int validate_vlan_mask_from_nlattrs(const struct sw_flow_match *match,
+					   u64 key_attrs, bool inner,
+					   const struct nlattr **a, bool log)
+{
+	__be16 tci = 0;
+	__be16 tpid = 0;
+	bool encap_valid = !!(match->key->eth.vlan.tci &
+			      htons(VLAN_TAG_PRESENT));
+	bool i_encap_valid = !!(match->key->eth.cvlan.tci &
+				htons(VLAN_TAG_PRESENT));
+
+	if (!(key_attrs & (1 << OVS_KEY_ATTR_ENCAP))) {
+		/* Not a VLAN. */
+		return 0;
+	}
+
+	if ((!inner && !encap_valid) || (inner && !i_encap_valid)) {
+		OVS_NLERR(log, "Encap mask attribute is set for non-%s frame.",
+			  (inner) ? "C-VLAN" : "VLAN");
+		return -EINVAL;
+	}
+
+	if (a[OVS_KEY_ATTR_VLAN])
+		tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
+
+	if (a[OVS_KEY_ATTR_ETHERTYPE])
+		tpid = nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]);
+
+	if (tpid != htons(0xffff)) {
+		OVS_NLERR(log, "Must have an exact match on %s TPID (mask=%x).",
+			  (inner) ? "C-VLAN" : "VLAN", ntohs(tpid));
+		return -EINVAL;
+	}
+	if (!(tci & htons(VLAN_TAG_PRESENT))) {
+		OVS_NLERR(log, "%s TCI mask does not have exact match for VLAN_TAG_PRESENT bit.",
+			  (inner) ? "C-VLAN" : "VLAN");
+		return -EINVAL;
+	}
+
+	return 1;
+}
+
+static int __parse_vlan_from_nlattrs(struct sw_flow_match *match,
+				     u64 *key_attrs, bool inner,
+				     const struct nlattr **a, bool is_mask,
+				     bool log)
+{
+	int err;
+	const struct nlattr *encap;
+
+	if (!is_mask)
+		err = validate_vlan_from_nlattrs(match, *key_attrs, inner,
+						 a, log);
+	else
+		err = validate_vlan_mask_from_nlattrs(match, *key_attrs, inner,
+						      a, log);
+	if (err <= 0)
+		return err;
+
+	err = encode_vlan_from_nlattrs(match, a, is_mask, inner);
+	if (err)
+		return err;
+
+	*key_attrs &= ~(1 << OVS_KEY_ATTR_ENCAP);
+	*key_attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
+	*key_attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
+
+	encap = a[OVS_KEY_ATTR_ENCAP];
+
+	if (!is_mask)
+		err = parse_flow_nlattrs(encap, a, key_attrs, log);
+	else
+		err = parse_flow_mask_nlattrs(encap, a, key_attrs, log);
+
+	return err;
+}
+
+static int parse_vlan_from_nlattrs(struct sw_flow_match *match,
+				   u64 *key_attrs, const struct nlattr **a,
+				   bool is_mask, bool log)
+{
+	int err;
+	bool encap_valid = false;
+
+	err = __parse_vlan_from_nlattrs(match, key_attrs, false, a,
+					is_mask, log);
+	if (err)
+		return err;
+
+	encap_valid = !!(match->key->eth.vlan.tci & htons(VLAN_TAG_PRESENT));
+	if (encap_valid) {
+		err = __parse_vlan_from_nlattrs(match, key_attrs, true, a,
+						is_mask, log);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
 static int metadata_from_nlattrs(struct net *net, struct sw_flow_match *match,
 				 u64 *attrs, const struct nlattr **a,
 				 bool is_mask, bool log)
@@ -923,20 +1084,11 @@ static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
 	}
 
 	if (attrs & (1 << OVS_KEY_ATTR_VLAN)) {
-		__be16 tci;
-
-		tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
-		if (!(tci & htons(VLAN_TAG_PRESENT))) {
-			if (is_mask)
-				OVS_NLERR(log, "VLAN TCI mask does not have exact match for VLAN_TAG_PRESENT bit.");
-			else
-				OVS_NLERR(log, "VLAN TCI does not have VLAN_TAG_PRESENT bit set.");
-
-			return -EINVAL;
-		}
-
-		SW_FLOW_KEY_PUT(match, eth.tci, tci, is_mask);
-		attrs &= ~(1 << OVS_KEY_ATTR_VLAN);
+		/* VLAN attribute is always parsed before getting here since it
+		 * may occur multiple times.
+		 */
+		OVS_NLERR(log, "VLAN attribute unexpected.");
+		return -EINVAL;
 	}
 
 	if (attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) {
@@ -1182,49 +1334,18 @@ int ovs_nla_get_match(struct net *net, struct sw_flow_match *match,
 		      bool log)
 {
 	const struct nlattr *a[OVS_KEY_ATTR_MAX + 1];
-	const struct nlattr *encap;
 	struct nlattr *newmask = NULL;
 	u64 key_attrs = 0;
 	u64 mask_attrs = 0;
-	bool encap_valid = false;
 	int err;
 
 	err = parse_flow_nlattrs(nla_key, a, &key_attrs, log);
 	if (err)
 		return err;
 
-	if ((key_attrs & (1 << OVS_KEY_ATTR_ETHERNET)) &&
-	    (key_attrs & (1 << OVS_KEY_ATTR_ETHERTYPE)) &&
-	    (nla_get_be16(a[OVS_KEY_ATTR_ETHERTYPE]) == htons(ETH_P_8021Q))) {
-		__be16 tci;
-
-		if (!((key_attrs & (1 << OVS_KEY_ATTR_VLAN)) &&
-		      (key_attrs & (1 << OVS_KEY_ATTR_ENCAP)))) {
-			OVS_NLERR(log, "Invalid Vlan frame.");
-			return -EINVAL;
-		}
-
-		key_attrs &= ~(1 << OVS_KEY_ATTR_ETHERTYPE);
-		tci = nla_get_be16(a[OVS_KEY_ATTR_VLAN]);
-		encap = a[OVS_KEY_ATTR_ENCAP];
-		key_attrs &= ~(1 << OVS_KEY_ATTR_ENCAP);
-		encap_valid = true;
-
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
-	}
+	err = parse_vlan_from_nlattrs(match, &key_attrs, a, false, log);
+	if (err)
+		return err;
 
 	err = ovs_key_from_nlattrs(net, match, key_attrs, a, false, log);
 	if (err)
@@ -1265,46 +1386,12 @@ int ovs_nla_get_match(struct net *net, struct sw_flow_match *match,
 			goto free_newmask;
 
 		/* Always match on tci. */
-		SW_FLOW_KEY_PUT(match, eth.tci, htons(0xffff), true);
-
-		if (mask_attrs & 1 << OVS_KEY_ATTR_ENCAP) {
-			__be16 eth_type = 0;
-			__be16 tci = 0;
-
-			if (!encap_valid) {
-				OVS_NLERR(log, "Encap mask attribute is set for non-VLAN frame.");
-				err = -EINVAL;
-				goto free_newmask;
-			}
-
-			mask_attrs &= ~(1 << OVS_KEY_ATTR_ENCAP);
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
+		SW_FLOW_KEY_PUT(match, eth.vlan.tci, htons(0xffff), true);
+		SW_FLOW_KEY_PUT(match, eth.cvlan.tci, htons(0xffff), true);
 
-			if (!(tci & htons(VLAN_TAG_PRESENT))) {
-				OVS_NLERR(log, "VLAN tag present bit must have an exact match (tci_mask=%x).",
-					  ntohs(tci));
-				err = -EINVAL;
-				goto free_newmask;
-			}
-		}
+		err = parse_vlan_from_nlattrs(match, &mask_attrs, a, true, log);
+		if (err)
+			goto free_newmask;
 
 		err = ovs_key_from_nlattrs(net, match, mask_attrs, a, true,
 					   log);
@@ -1410,12 +1497,25 @@ int ovs_nla_get_flow_metadata(struct net *net, const struct nlattr *attr,
 	return metadata_from_nlattrs(net, &match, &attrs, a, false, log);
 }
 
+static int ovs_nla_put_vlan(struct sk_buff *skb, const struct vlan_head *vh,
+			    bool is_mask)
+{
+	__be16 eth_type = !is_mask ? vh->tpid : htons(0xffff);
+
+	if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, eth_type) ||
+	    nla_put_be16(skb, OVS_KEY_ATTR_VLAN, vh->tci))
+		return -EMSGSIZE;
+	return 0;
+}
+
 static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
 			     const struct sw_flow_key *output, bool is_mask,
 			     struct sk_buff *skb)
 {
 	struct ovs_key_ethernet *eth_key;
-	struct nlattr *nla, *encap;
+	struct nlattr *nla;
+	struct nlattr *encap = NULL;
+	struct nlattr *in_encap = NULL;
 
 	if (nla_put_u32(skb, OVS_KEY_ATTR_RECIRC_ID, output->recirc_id))
 		goto nla_put_failure;
@@ -1464,17 +1564,21 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
 	ether_addr_copy(eth_key->eth_src, output->eth.src);
 	ether_addr_copy(eth_key->eth_dst, output->eth.dst);
 
-	if (swkey->eth.tci || swkey->eth.type == htons(ETH_P_8021Q)) {
-		__be16 eth_type;
-		eth_type = !is_mask ? htons(ETH_P_8021Q) : htons(0xffff);
-		if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, eth_type) ||
-		    nla_put_be16(skb, OVS_KEY_ATTR_VLAN, output->eth.tci))
+	if (swkey->eth.vlan.tci || eth_type_vlan(swkey->eth.type)) {
+		if (ovs_nla_put_vlan(skb, &output->eth.vlan, is_mask))
 			goto nla_put_failure;
 		encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
-		if (!swkey->eth.tci)
+		if (!swkey->eth.vlan.tci)
 			goto unencap;
-	} else
-		encap = NULL;
+
+		if (swkey->eth.cvlan.tci || eth_type_vlan(swkey->eth.type)) {
+			if (ovs_nla_put_vlan(skb, &output->eth.cvlan, is_mask))
+				goto nla_put_failure;
+			in_encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
+			if (!swkey->eth.cvlan.tci)
+				goto unencap;
+		}
+	}
 
 	if (swkey->eth.type == htons(ETH_P_802_2)) {
 		/*
@@ -1493,6 +1597,14 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
 	if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, output->eth.type))
 		goto nla_put_failure;
 
+	if (eth_type_vlan(swkey->eth.type)) {
+		/* There are 3 VLAN tags, we don't know anything about the rest
+		 * of the packet, so truncate here.
+		 */
+		WARN_ON_ONCE(!(encap && in_encap));
+		goto unencap;
+	}
+
 	if (swkey->eth.type == htons(ETH_P_IP)) {
 		struct ovs_key_ipv4 *ipv4_key;
 
@@ -1619,6 +1731,8 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
 	}
 
 unencap:
+	if (in_encap)
+		nla_nest_end(skb, in_encap);
 	if (encap)
 		nla_nest_end(skb, encap);
 
@@ -2283,7 +2397,7 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 
 		case OVS_ACTION_ATTR_PUSH_VLAN:
 			vlan = nla_data(a);
-			if (vlan->vlan_tpid != htons(ETH_P_8021Q))
+			if (!eth_type_vlan(vlan->vlan_tpid))
 				return -EINVAL;
 			if (!(vlan->vlan_tci & htons(VLAN_TAG_PRESENT)))
 				return -EINVAL;
@@ -2388,7 +2502,7 @@ int ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 
 	(*sfa)->orig_len = nla_len(attr);
 	err = __ovs_nla_copy_actions(net, attr, key, 0, sfa, key->eth.type,
-				     key->eth.tci, log);
+				     key->eth.vlan.tci, log);
 	if (err)
 		ovs_nla_free_flow_actions(*sfa);
 
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 6b21fd068d87..8f198437c724 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -485,9 +485,14 @@ static unsigned int packet_length(const struct sk_buff *skb)
 {
 	unsigned int length = skb->len - ETH_HLEN;
 
-	if (skb->protocol == htons(ETH_P_8021Q))
+	if (skb_vlan_tagged(skb))
 		length -= VLAN_HLEN;
 
+	/* Don't subtract for multiple VLAN tags. Most (all?) drivers allow
+	 * (ETH_LEN + VLAN_HLEN) in addition to the mtu value, but almost none
+	 * account for 802.1ad. e.g. is_skb_forwardable().
+	 */
+
 	return length;
 }
 
-- 
2.5.5
