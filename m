From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH v4 net-next 08/10] openvswitch: Add original direction conntrack tuple to sw_flow_key.
Date: Thu,  9 Feb 2017 11:21:59 -0800
Message-ID: <1486668121-45709-9-git-send-email-jarno@ovn.org>
References: <1486668121-45709-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org, davem@davemloft.net, joe@ovn.org, pshelar@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:57776 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754105AbdBITWd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 14:22:33 -0500
In-Reply-To: <1486668121-45709-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the fields of the conntrack original direction 5-tuple to struct
sw_flow_key.  The new fields are initially marked as non-existent, and
are populated whenever a conntrack action is executed and either finds
or generates a conntrack entry.  This means that these fields exist
for all packets that were not rejected by conntrack as untrackable.

The original tuple fields in the sw_flow_key are filled from the
original direction tuple of the conntrack entry relating to the
current packet, or from the original direction tuple of the master
conntrack entry, if the current conntrack entry has a master.
Generally, expected connections of connections having an assigned
helper (e.g., FTP), have a master conntrack entry.

The main purpose of the new conntrack original tuple fields is to
allow matching on them for policy decision purposes, with the premise
that the admissibility of tracked connections reply packets (as well
as original direction packets), and both direction packets of any
related connections may be based on ACL rules applying to the master
connection's original direction 5-tuple.  This also makes it easier to
make policy decisions when the actual packet headers might have been
transformed by NAT, as the original direction 5-tuple represents the
packet headers before any such transformation.

When using the original direction 5-tuple the admissibility of return
and/or related packets need not be based on the mere existence of a
conntrack entry, allowing separation of admission policy from the
established conntrack state.  While existence of a conntrack entry is
required for admission of the return or related packets, policy
changes can render connections that were initially admitted to be
rejected or dropped afterwards.  If the admission of the return and
related packets was based on mere conntrack state (e.g., connection
being in an established state), a policy change that would make the
connection rejected or dropped would need to find and delete all
conntrack entries affected by such a change.  When using the original
direction 5-tuple matching the affected conntrack entries can be
allowed to time out instead, as the established state of the
connection would not need to be the basis for packet admission any
more.

It should be noted that the directionality of related connections may
be the same or different than that of the master connection, and
neither the original direction 5-tuple nor the conntrack state bits
carry this information.  If needed, the directionality of the master
connection can be stored in master's conntrack mark or labels, which
are automatically inherited by the expected related connections.

The fact that neither ARP nor ND packets are trackable by conntrack
allows mutual exclusion between ARP/ND and the new conntrack original
tuple fields.  Hence, the IP addresses are overlaid in union with ARP
and ND fields.  This allows the sw_flow_key to not grow much due to
this patch, but it also means that we must be careful to never use the
new key fields with ARP or ND packets.  ARP is easy to distinguish and
keep mutually exclusive based on the ethernet type, but ND being an
ICMPv6 protocol requires a bit more attention.

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
Acked-by: Joe Stringer <joe@ovn.org>
Acked-by: Pravin B Shelar <pshelar@ovn.org>
---
 include/uapi/linux/openvswitch.h | 20 +++++++++-
 net/openvswitch/actions.c        |  2 +
 net/openvswitch/conntrack.c      | 86 +++++++++++++++++++++++++++++++++++++---
 net/openvswitch/conntrack.h      | 10 ++++-
 net/openvswitch/flow.c           | 34 +++++++++++++---
 net/openvswitch/flow.h           | 49 ++++++++++++++++++-----
 net/openvswitch/flow_netlink.c   | 85 +++++++++++++++++++++++++++++----------
 net/openvswitch/flow_netlink.h   |  7 +++-
 8 files changed, 246 insertions(+), 47 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 96aee34..90af8b8 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -1,6 +1,6 @@
 
 /*
- * Copyright (c) 2007-2013 Nicira, Inc.
+ * Copyright (c) 2007-2017 Nicira, Inc.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
@@ -331,6 +331,8 @@ enum ovs_key_attr {
 	OVS_KEY_ATTR_CT_ZONE,	/* u16 connection tracking zone. */
 	OVS_KEY_ATTR_CT_MARK,	/* u32 connection tracking mark */
 	OVS_KEY_ATTR_CT_LABELS,	/* 16-octet connection tracking label */
+	OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV4,   /* struct ovs_key_ct_tuple_ipv4 */
+	OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV6,   /* struct ovs_key_ct_tuple_ipv6 */
 
 #ifdef __KERNEL__
 	OVS_KEY_ATTR_TUNNEL_INFO,  /* struct ip_tunnel_info */
@@ -472,6 +474,22 @@ struct ovs_key_ct_labels {
 
 #define OVS_CS_F_NAT_MASK (OVS_CS_F_SRC_NAT | OVS_CS_F_DST_NAT)
 
+struct ovs_key_ct_tuple_ipv4 {
+	__be32 ipv4_src;
+	__be32 ipv4_dst;
+	__be16 src_port;
+	__be16 dst_port;
+	__u8   ipv4_proto;
+};
+
+struct ovs_key_ct_tuple_ipv6 {
+	__be32 ipv6_src[4];
+	__be32 ipv6_dst[4];
+	__be16 src_port;
+	__be16 dst_port;
+	__u8   ipv6_proto;
+};
+
 /**
  * enum ovs_flow_attr - attributes for %OVS_FLOW_* commands.
  * @OVS_FLOW_ATTR_KEY: Nested %OVS_KEY_ATTR_* attributes specifying the flow
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index efa9a88..b1beb2b 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -1074,6 +1074,8 @@ static int execute_masked_set_action(struct sk_buff *skb,
 	case OVS_KEY_ATTR_CT_ZONE:
 	case OVS_KEY_ATTR_CT_MARK:
 	case OVS_KEY_ATTR_CT_LABELS:
+	case OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV4:
+	case OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV6:
 		err = -EINVAL;
 		break;
 	}
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index f989ccf..bfd7606 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -147,6 +147,20 @@ static void ovs_ct_get_labels(const struct nf_conn *ct,
 		memset(labels, 0, OVS_CT_LABELS_LEN);
 }
 
+static void __ovs_ct_update_key_orig_tp(struct sw_flow_key *key,
+					const struct nf_conntrack_tuple *orig,
+					u8 icmp_proto)
+{
+	key->ct.orig_proto = orig->dst.protonum;
+	if (orig->dst.protonum == icmp_proto) {
+		key->ct.orig_tp.src = htons(orig->dst.u.icmp.type);
+		key->ct.orig_tp.dst = htons(orig->dst.u.icmp.code);
+	} else {
+		key->ct.orig_tp.src = orig->src.u.all;
+		key->ct.orig_tp.dst = orig->dst.u.all;
+	}
+}
+
 static void __ovs_ct_update_key(struct sw_flow_key *key, u8 state,
 				const struct nf_conntrack_zone *zone,
 				const struct nf_conn *ct)
@@ -155,6 +169,35 @@ static void __ovs_ct_update_key(struct sw_flow_key *key, u8 state,
 	key->ct.zone = zone->id;
 	key->ct.mark = ovs_ct_get_mark(ct);
 	ovs_ct_get_labels(ct, &key->ct.labels);
+
+	if (ct) {
+		const struct nf_conntrack_tuple *orig;
+
+		/* Use the master if we have one. */
+		if (ct->master)
+			ct = ct->master;
+		orig = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
+
+		/* IP version must match with the master connection. */
+		if (key->eth.type == htons(ETH_P_IP) &&
+		    nf_ct_l3num(ct) == NFPROTO_IPV4) {
+			key->ipv4.ct_orig.src = orig->src.u3.ip;
+			key->ipv4.ct_orig.dst = orig->dst.u3.ip;
+			__ovs_ct_update_key_orig_tp(key, orig, IPPROTO_ICMP);
+			return;
+		} else if (key->eth.type == htons(ETH_P_IPV6) &&
+			   !sw_flow_key_is_nd(key) &&
+			   nf_ct_l3num(ct) == NFPROTO_IPV6) {
+			key->ipv6.ct_orig.src = orig->src.u3.in6;
+			key->ipv6.ct_orig.dst = orig->dst.u3.in6;
+			__ovs_ct_update_key_orig_tp(key, orig, NEXTHDR_ICMP);
+			return;
+		}
+	}
+	/* Clear 'ct.orig_proto' to mark the non-existence of conntrack
+	 * original direction key fields.
+	 */
+	key->ct.orig_proto = 0;
 }
 
 /* Update 'key' based on skb->_nfct.  If 'post_ct' is true, then OVS has
@@ -208,24 +251,55 @@ void ovs_ct_fill_key(const struct sk_buff *skb, struct sw_flow_key *key)
 	ovs_ct_update_key(skb, NULL, key, false, false);
 }
 
-int ovs_ct_put_key(const struct sw_flow_key *key, struct sk_buff *skb)
+#define IN6_ADDR_INITIALIZER(ADDR) \
+	{ (ADDR).s6_addr32[0], (ADDR).s6_addr32[1], \
+	  (ADDR).s6_addr32[2], (ADDR).s6_addr32[3] }
+
+int ovs_ct_put_key(const struct sw_flow_key *swkey,
+		   const struct sw_flow_key *output, struct sk_buff *skb)
 {
-	if (nla_put_u32(skb, OVS_KEY_ATTR_CT_STATE, key->ct.state))
+	if (nla_put_u32(skb, OVS_KEY_ATTR_CT_STATE, output->ct.state))
 		return -EMSGSIZE;
 
 	if (IS_ENABLED(CONFIG_NF_CONNTRACK_ZONES) &&
-	    nla_put_u16(skb, OVS_KEY_ATTR_CT_ZONE, key->ct.zone))
+	    nla_put_u16(skb, OVS_KEY_ATTR_CT_ZONE, output->ct.zone))
 		return -EMSGSIZE;
 
 	if (IS_ENABLED(CONFIG_NF_CONNTRACK_MARK) &&
-	    nla_put_u32(skb, OVS_KEY_ATTR_CT_MARK, key->ct.mark))
+	    nla_put_u32(skb, OVS_KEY_ATTR_CT_MARK, output->ct.mark))
 		return -EMSGSIZE;
 
 	if (IS_ENABLED(CONFIG_NF_CONNTRACK_LABELS) &&
-	    nla_put(skb, OVS_KEY_ATTR_CT_LABELS, sizeof(key->ct.labels),
-		    &key->ct.labels))
+	    nla_put(skb, OVS_KEY_ATTR_CT_LABELS, sizeof(output->ct.labels),
+		    &output->ct.labels))
 		return -EMSGSIZE;
 
+	if (swkey->ct.orig_proto) {
+		if (swkey->eth.type == htons(ETH_P_IP)) {
+			struct ovs_key_ct_tuple_ipv4 orig = {
+				output->ipv4.ct_orig.src,
+				output->ipv4.ct_orig.dst,
+				output->ct.orig_tp.src,
+				output->ct.orig_tp.dst,
+				output->ct.orig_proto,
+			};
+			if (nla_put(skb, OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV4,
+				    sizeof(orig), &orig))
+				return -EMSGSIZE;
+		} else if (swkey->eth.type == htons(ETH_P_IPV6)) {
+			struct ovs_key_ct_tuple_ipv6 orig = {
+				IN6_ADDR_INITIALIZER(output->ipv6.ct_orig.src),
+				IN6_ADDR_INITIALIZER(output->ipv6.ct_orig.dst),
+				output->ct.orig_tp.src,
+				output->ct.orig_tp.dst,
+				output->ct.orig_proto,
+			};
+			if (nla_put(skb, OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV6,
+				    sizeof(orig), &orig))
+				return -EMSGSIZE;
+		}
+	}
+
 	return 0;
 }
 
diff --git a/net/openvswitch/conntrack.h b/net/openvswitch/conntrack.h
index 8f6230b..9e92445 100644
--- a/net/openvswitch/conntrack.h
+++ b/net/openvswitch/conntrack.h
@@ -32,7 +32,8 @@ int ovs_ct_execute(struct net *, struct sk_buff *, struct sw_flow_key *,
 		   const struct ovs_conntrack_info *);
 
 void ovs_ct_fill_key(const struct sk_buff *skb, struct sw_flow_key *key);
-int ovs_ct_put_key(const struct sw_flow_key *key, struct sk_buff *skb);
+int ovs_ct_put_key(const struct sw_flow_key *swkey,
+		   const struct sw_flow_key *output, struct sk_buff *skb);
 void ovs_ct_free_action(const struct nlattr *a);
 
 #define CT_SUPPORTED_MASK (OVS_CS_F_NEW | OVS_CS_F_ESTABLISHED | \
@@ -79,9 +80,14 @@ static inline void ovs_ct_fill_key(const struct sk_buff *skb,
 	key->ct.zone = 0;
 	key->ct.mark = 0;
 	memset(&key->ct.labels, 0, sizeof(key->ct.labels));
+	/* Clear 'ct.orig_proto' to mark the non-existence of original
+	 * direction key fields.
+	 */
+	key->ct.orig_proto = 0;
 }
 
-static inline int ovs_ct_put_key(const struct sw_flow_key *key,
+static inline int ovs_ct_put_key(const struct sw_flow_key *swkey,
+				 const struct sw_flow_key *output,
 				 struct sk_buff *skb)
 {
 	return 0;
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 2c0a00f..9d4bb8e 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -765,7 +765,7 @@ static int key_extract_mac_proto(struct sk_buff *skb)
 int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
 			 struct sk_buff *skb, struct sw_flow_key *key)
 {
-	int res;
+	int res, err;
 
 	/* Extract metadata from packet. */
 	if (tun_info) {
@@ -792,7 +792,6 @@ int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
 	key->phy.priority = skb->priority;
 	key->phy.in_port = OVS_CB(skb)->input_vport->port_no;
 	key->phy.skb_mark = skb->mark;
-	ovs_ct_fill_key(skb, key);
 	key->ovs_flow_hash = 0;
 	res = key_extract_mac_proto(skb);
 	if (res < 0)
@@ -800,17 +799,26 @@ int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
 	key->mac_proto = res;
 	key->recirc_id = 0;
 
-	return key_extract(skb, key);
+	err = key_extract(skb, key);
+	if (!err)
+		ovs_ct_fill_key(skb, key);   /* Must be after key_extract(). */
+	return err;
 }
 
 int ovs_flow_key_extract_userspace(struct net *net, const struct nlattr *attr,
 				   struct sk_buff *skb,
 				   struct sw_flow_key *key, bool log)
 {
+	const struct nlattr *a[OVS_KEY_ATTR_MAX + 1];
+	u64 attrs = 0;
 	int err;
 
+	err = parse_flow_nlattrs(attr, a, &attrs, log);
+	if (err)
+		return -EINVAL;
+
 	/* Extract metadata from netlink attributes. */
-	err = ovs_nla_get_flow_metadata(net, attr, key, log);
+	err = ovs_nla_get_flow_metadata(net, a, attrs, key, log);
 	if (err)
 		return err;
 
@@ -824,5 +832,21 @@ int ovs_flow_key_extract_userspace(struct net *net, const struct nlattr *attr,
 	 */
 
 	skb->protocol = key->eth.type;
-	return key_extract(skb, key);
+	err = key_extract(skb, key);
+	if (err)
+		return err;
+
+	/* Check that we have conntrack original direction tuple metadata only
+	 * for packets for which it makes sense.  Otherwise the key may be
+	 * corrupted due to overlapping key fields.
+	 */
+	if (attrs & (1 << OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV4) &&
+	    key->eth.type != htons(ETH_P_IP))
+		return -EINVAL;
+	if (attrs & (1 << OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV6) &&
+	    (key->eth.type != htons(ETH_P_IPV6) ||
+	     sw_flow_key_is_nd(key)))
+		return -EINVAL;
+
+	return 0;
 }
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index f61cae7..76e05b2 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2007-2014 Nicira, Inc.
+ * Copyright (c) 2007-2017 Nicira, Inc.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
@@ -107,10 +107,16 @@ struct sw_flow_key {
 				__be32 src;	/* IP source address. */
 				__be32 dst;	/* IP destination address. */
 			} addr;
-			struct {
-				u8 sha[ETH_ALEN];	/* ARP source hardware address. */
-				u8 tha[ETH_ALEN];	/* ARP target hardware address. */
-			} arp;
+			union {
+				struct {
+					__be32 src;
+					__be32 dst;
+				} ct_orig;	/* Conntrack original direction fields. */
+				struct {
+					u8 sha[ETH_ALEN];	/* ARP source hardware address. */
+					u8 tha[ETH_ALEN];	/* ARP target hardware address. */
+				} arp;
+			};
 		} ipv4;
 		struct {
 			struct {
@@ -118,23 +124,44 @@ struct sw_flow_key {
 				struct in6_addr dst;	/* IPv6 destination address. */
 			} addr;
 			__be32 label;			/* IPv6 flow label. */
-			struct {
-				struct in6_addr target;	/* ND target address. */
-				u8 sll[ETH_ALEN];	/* ND source link layer address. */
-				u8 tll[ETH_ALEN];	/* ND target link layer address. */
-			} nd;
+			union {
+				struct {
+					struct in6_addr src;
+					struct in6_addr dst;
+				} ct_orig;	/* Conntrack original direction fields. */
+				struct {
+					struct in6_addr target;	/* ND target address. */
+					u8 sll[ETH_ALEN];	/* ND source link layer address. */
+					u8 tll[ETH_ALEN];	/* ND target link layer address. */
+				} nd;
+			};
 		} ipv6;
 	};
 	struct {
 		/* Connection tracking fields. */
+		u8 state;
+		u8 orig_proto;		/* CT orig tuple IP protocol. */
 		u16 zone;
 		u32 mark;
-		u8 state;
+		struct {
+			__be16 src;	/* CT orig tuple tp src port. */
+			__be16 dst;	/* CT orig tuple tp dst port. */
+		} orig_tp;
+
 		struct ovs_key_ct_labels labels;
 	} ct;
 
 } __aligned(BITS_PER_LONG/8); /* Ensure that we can do comparisons as longs. */
 
+static inline bool sw_flow_key_is_nd(const struct sw_flow_key *key)
+{
+	return key->eth.type == htons(ETH_P_IPV6) &&
+		key->ip.proto == NEXTHDR_ICMP &&
+		key->tp.dst == 0 &&
+		(key->tp.src == htons(NDISC_NEIGHBOUR_SOLICITATION) ||
+		 key->tp.src == htons(NDISC_NEIGHBOUR_ADVERTISEMENT));
+}
+
 struct sw_flow_key_range {
 	unsigned short int start;
 	unsigned short int end;
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index c87d359..989f38f 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -129,7 +129,9 @@ static bool match_validate(const struct sw_flow_match *match,
 	/* The following mask attributes allowed only if they
 	 * pass the validation tests. */
 	mask_allowed &= ~((1 << OVS_KEY_ATTR_IPV4)
+			| (1 << OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV4)
 			| (1 << OVS_KEY_ATTR_IPV6)
+			| (1 << OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV6)
 			| (1 << OVS_KEY_ATTR_TCP)
 			| (1 << OVS_KEY_ATTR_TCP_FLAGS)
 			| (1 << OVS_KEY_ATTR_UDP)
@@ -161,8 +163,10 @@ static bool match_validate(const struct sw_flow_match *match,
 
 	if (match->key->eth.type == htons(ETH_P_IP)) {
 		key_expected |= 1 << OVS_KEY_ATTR_IPV4;
-		if (match->mask && (match->mask->key.eth.type == htons(0xffff)))
+		if (match->mask && match->mask->key.eth.type == htons(0xffff)) {
 			mask_allowed |= 1 << OVS_KEY_ATTR_IPV4;
+			mask_allowed |= 1 << OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV4;
+		}
 
 		if (match->key->ip.frag != OVS_FRAG_TYPE_LATER) {
 			if (match->key->ip.proto == IPPROTO_UDP) {
@@ -196,8 +200,10 @@ static bool match_validate(const struct sw_flow_match *match,
 
 	if (match->key->eth.type == htons(ETH_P_IPV6)) {
 		key_expected |= 1 << OVS_KEY_ATTR_IPV6;
-		if (match->mask && (match->mask->key.eth.type == htons(0xffff)))
+		if (match->mask && match->mask->key.eth.type == htons(0xffff)) {
 			mask_allowed |= 1 << OVS_KEY_ATTR_IPV6;
+			mask_allowed |= 1 << OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV6;
+		}
 
 		if (match->key->ip.frag != OVS_FRAG_TYPE_LATER) {
 			if (match->key->ip.proto == IPPROTO_UDP) {
@@ -230,6 +236,12 @@ static bool match_validate(const struct sw_flow_match *match,
 						htons(NDISC_NEIGHBOUR_SOLICITATION) ||
 				    match->key->tp.src == htons(NDISC_NEIGHBOUR_ADVERTISEMENT)) {
 					key_expected |= 1 << OVS_KEY_ATTR_ND;
+					/* Original direction conntrack tuple
+					 * uses the same space as the ND fields
+					 * in the key, so both are not allowed
+					 * at the same time.
+					 */
+					mask_allowed &= ~(1ULL << OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV6);
 					if (match->mask && (match->mask->key.tp.src == htons(0xff)))
 						mask_allowed |= 1 << OVS_KEY_ATTR_ND;
 				}
@@ -282,7 +294,7 @@ size_t ovs_key_attr_size(void)
 	/* Whenever adding new OVS_KEY_ FIELDS, we should consider
 	 * updating this function.
 	 */
-	BUILD_BUG_ON(OVS_KEY_ATTR_TUNNEL_INFO != 26);
+	BUILD_BUG_ON(OVS_KEY_ATTR_TUNNEL_INFO != 28);
 
 	return    nla_total_size(4)   /* OVS_KEY_ATTR_PRIORITY */
 		+ nla_total_size(0)   /* OVS_KEY_ATTR_TUNNEL */
@@ -295,6 +307,7 @@ size_t ovs_key_attr_size(void)
 		+ nla_total_size(2)   /* OVS_KEY_ATTR_CT_ZONE */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_CT_MARK */
 		+ nla_total_size(16)  /* OVS_KEY_ATTR_CT_LABELS */
+		+ nla_total_size(40)  /* OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV6 */
 		+ nla_total_size(12)  /* OVS_KEY_ATTR_ETHERNET */
 		+ nla_total_size(2)   /* OVS_KEY_ATTR_ETHERTYPE */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_VLAN */
@@ -355,6 +368,10 @@ static const struct ovs_len_tbl ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
 	[OVS_KEY_ATTR_CT_ZONE]	 = { .len = sizeof(u16) },
 	[OVS_KEY_ATTR_CT_MARK]	 = { .len = sizeof(u32) },
 	[OVS_KEY_ATTR_CT_LABELS] = { .len = sizeof(struct ovs_key_ct_labels) },
+	[OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV4] = {
+		.len = sizeof(struct ovs_key_ct_tuple_ipv4) },
+	[OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV6] = {
+		.len = sizeof(struct ovs_key_ct_tuple_ipv6) },
 };
 
 static bool check_attr_len(unsigned int attr_len, unsigned int expected_len)
@@ -430,9 +447,8 @@ static int parse_flow_mask_nlattrs(const struct nlattr *attr,
 	return __parse_flow_nlattrs(attr, a, attrsp, log, true);
 }
 
-static int parse_flow_nlattrs(const struct nlattr *attr,
-			      const struct nlattr *a[], u64 *attrsp,
-			      bool log)
+int parse_flow_nlattrs(const struct nlattr *attr, const struct nlattr *a[],
+		       u64 *attrsp, bool log)
 {
 	return __parse_flow_nlattrs(attr, a, attrsp, log, false);
 }
@@ -1082,6 +1098,34 @@ static int metadata_from_nlattrs(struct net *net, struct sw_flow_match *match,
 				   sizeof(*cl), is_mask);
 		*attrs &= ~(1ULL << OVS_KEY_ATTR_CT_LABELS);
 	}
+	if (*attrs & (1ULL << OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV4)) {
+		const struct ovs_key_ct_tuple_ipv4 *ct;
+
+		ct = nla_data(a[OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV4]);
+
+		SW_FLOW_KEY_PUT(match, ipv4.ct_orig.src, ct->ipv4_src, is_mask);
+		SW_FLOW_KEY_PUT(match, ipv4.ct_orig.dst, ct->ipv4_dst, is_mask);
+		SW_FLOW_KEY_PUT(match, ct.orig_tp.src, ct->src_port, is_mask);
+		SW_FLOW_KEY_PUT(match, ct.orig_tp.dst, ct->dst_port, is_mask);
+		SW_FLOW_KEY_PUT(match, ct.orig_proto, ct->ipv4_proto, is_mask);
+		*attrs &= ~(1ULL << OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV4);
+	}
+	if (*attrs & (1ULL << OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV6)) {
+		const struct ovs_key_ct_tuple_ipv6 *ct;
+
+		ct = nla_data(a[OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV6]);
+
+		SW_FLOW_KEY_MEMCPY(match, ipv6.ct_orig.src, &ct->ipv6_src,
+				   sizeof(match->key->ipv6.ct_orig.src),
+				   is_mask);
+		SW_FLOW_KEY_MEMCPY(match, ipv6.ct_orig.dst, &ct->ipv6_dst,
+				   sizeof(match->key->ipv6.ct_orig.dst),
+				   is_mask);
+		SW_FLOW_KEY_PUT(match, ct.orig_tp.src, ct->src_port, is_mask);
+		SW_FLOW_KEY_PUT(match, ct.orig_tp.dst, ct->dst_port, is_mask);
+		SW_FLOW_KEY_PUT(match, ct.orig_proto, ct->ipv6_proto, is_mask);
+		*attrs &= ~(1ULL << OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV6);
+	}
 
 	/* For layer 3 packets the Ethernet type is provided
 	 * and treated as metadata but no MAC addresses are provided.
@@ -1493,9 +1537,12 @@ u32 ovs_nla_get_ufid_flags(const struct nlattr *attr)
 
 /**
  * ovs_nla_get_flow_metadata - parses Netlink attributes into a flow key.
- * @key: Receives extracted in_port, priority, tun_key and skb_mark.
- * @attr: Netlink attribute holding nested %OVS_KEY_ATTR_* Netlink attribute
- * sequence.
+ * @net: Network namespace.
+ * @key: Receives extracted in_port, priority, tun_key, skb_mark and conntrack
+ * metadata.
+ * @a: Array of netlink attributes holding parsed %OVS_KEY_ATTR_* Netlink
+ * attributes.
+ * @attrs: Bit mask for the netlink attributes included in @a.
  * @log: Boolean to allow kernel error logging.  Normally true, but when
  * probing for feature compatibility this should be passed in as false to
  * suppress unnecessary error logging.
@@ -1504,25 +1551,23 @@ u32 ovs_nla_get_ufid_flags(const struct nlattr *attr)
  * take the same form accepted by flow_from_nlattrs(), but only enough of it to
  * get the metadata, that is, the parts of the flow key that cannot be
  * extracted from the packet itself.
+ *
+ * This must be called before the packet key fields are filled in 'key'.
  */
 
-int ovs_nla_get_flow_metadata(struct net *net, const struct nlattr *attr,
-			      struct sw_flow_key *key,
-			      bool log)
+int ovs_nla_get_flow_metadata(struct net *net,
+			      const struct nlattr *a[OVS_KEY_ATTR_MAX + 1],
+			      u64 attrs, struct sw_flow_key *key, bool log)
 {
-	const struct nlattr *a[OVS_KEY_ATTR_MAX + 1];
 	struct sw_flow_match match;
-	u64 attrs = 0;
-	int err;
-
-	err = parse_flow_nlattrs(attr, a, &attrs, log);
-	if (err)
-		return -EINVAL;
 
 	memset(&match, 0, sizeof(match));
 	match.key = key;
 
 	memset(&key->ct, 0, sizeof(key->ct));
+	memset(&key->ipv4.ct_orig, 0, sizeof(key->ipv4.ct_orig));
+	memset(&key->ipv6.ct_orig, 0, sizeof(key->ipv6.ct_orig));
+
 	key->phy.in_port = DP_MAX_PORTS;
 
 	return metadata_from_nlattrs(net, &match, &attrs, a, false, log);
@@ -1584,7 +1629,7 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
 	if (nla_put_u32(skb, OVS_KEY_ATTR_SKB_MARK, output->phy.skb_mark))
 		goto nla_put_failure;
 
-	if (ovs_ct_put_key(output, skb))
+	if (ovs_ct_put_key(swkey, output, skb))
 		goto nla_put_failure;
 
 	if (ovs_key_mac_proto(swkey) == MAC_PROTO_ETHERNET) {
diff --git a/net/openvswitch/flow_netlink.h b/net/openvswitch/flow_netlink.h
index 45f9769..929c665 100644
--- a/net/openvswitch/flow_netlink.h
+++ b/net/openvswitch/flow_netlink.h
@@ -46,8 +46,11 @@ void ovs_match_init(struct sw_flow_match *match,
 
 int ovs_nla_put_key(const struct sw_flow_key *, const struct sw_flow_key *,
 		    int attr, bool is_mask, struct sk_buff *);
-int ovs_nla_get_flow_metadata(struct net *, const struct nlattr *,
-			      struct sw_flow_key *, bool log);
+int parse_flow_nlattrs(const struct nlattr *attr, const struct nlattr *a[],
+		       u64 *attrsp, bool log);
+int ovs_nla_get_flow_metadata(struct net *net,
+			      const struct nlattr *a[OVS_KEY_ATTR_MAX + 1],
+			      u64 attrs, struct sw_flow_key *key, bool log);
 
 int ovs_nla_put_identifier(const struct sw_flow *flow, struct sk_buff *skb);
 int ovs_nla_put_masked_key(const struct sw_flow *flow, struct sk_buff *skb);
-- 
2.1.4
