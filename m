From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH net-next 7/7] openvswitch: Pack struct sw_flow_key.
Date: Thu,  2 Feb 2017 17:10:06 -0800
Message-ID: <1486084206-109903-7-git-send-email-jarno@ovn.org>
References: <1486084206-109903-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:39237 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752069AbdBCBKu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 20:10:50 -0500
In-Reply-To: <1486084206-109903-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct sw_flow_key has two 16-bit holes. Move the most matched
conntrack match fields there.  In some typical cases this reduces the
size of the key that needs to be hashed into half and into one cache
line.

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
 net/openvswitch/conntrack.c    | 42 +++++++++++++++++++++---------------------
 net/openvswitch/conntrack.h    |  6 +++---
 net/openvswitch/flow.h         | 14 ++++++++------
 net/openvswitch/flow_netlink.c |  8 ++++----
 4 files changed, 36 insertions(+), 34 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 1f27f44..e8d29c0 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -152,8 +152,8 @@ static void __ovs_ct_update_key(struct sw_flow_key *key, u8 state,
 				const struct nf_conntrack_zone *zone,
 				const struct nf_conn *ct)
 {
-	key->ct.state = state;
-	key->ct.zone = zone->id;
+	key->ct_state = state;
+	key->ct_zone = zone->id;
 	key->ct.mark = ovs_ct_get_mark(ct);
 	ovs_ct_get_labels(ct, &key->ct.labels);
 
@@ -161,7 +161,7 @@ static void __ovs_ct_update_key(struct sw_flow_key *key, u8 state,
 	if (ct && ct->master)
 		ct = ct->master;
 
-	key->ct.orig_proto = 0;
+	key->ct_orig_proto = 0;
 	key->ct.orig_tp.src = 0;
 	key->ct.orig_tp.dst = 0;
 	if (key->eth.type == htons(ETH_P_IP)) {
@@ -172,7 +172,7 @@ static void __ovs_ct_update_key(struct sw_flow_key *key, u8 state,
 
 			key->ipv4.ct_orig.src = orig->src.u3.ip;
 			key->ipv4.ct_orig.dst = orig->dst.u3.ip;
-			key->ct.orig_proto = orig->dst.protonum;
+			key->ct_orig_proto = orig->dst.protonum;
 			if (orig->dst.protonum == IPPROTO_ICMP) {
 				key->ct.orig_tp.src
 					= htons(orig->dst.u.icmp.type);
@@ -195,7 +195,7 @@ static void __ovs_ct_update_key(struct sw_flow_key *key, u8 state,
 
 			key->ipv6.ct_orig.src = orig->src.u3.in6;
 			key->ipv6.ct_orig.dst = orig->dst.u3.in6;
-			key->ct.orig_proto = orig->dst.protonum;
+			key->ct_orig_proto = orig->dst.protonum;
 			if (orig->dst.protonum == IPPROTO_ICMPV6) {
 				key->ct.orig_tp.src
 					= htons(orig->dst.u.icmp.type);
@@ -238,7 +238,7 @@ static void ovs_ct_update_key(const struct sk_buff *skb,
 		if (ct->master)
 			state |= OVS_CS_F_RELATED;
 		if (keep_nat_flags) {
-			state |= key->ct.state & OVS_CS_F_NAT_MASK;
+			state |= key->ct_state & OVS_CS_F_NAT_MASK;
 		} else {
 			if (ct->status & IPS_SRC_NAT)
 				state |= OVS_CS_F_SRC_NAT;
@@ -269,11 +269,11 @@ void ovs_ct_fill_key(const struct sk_buff *skb, struct sw_flow_key *key)
 int ovs_ct_put_key(const struct sw_flow_key *swkey,
 		   const struct sw_flow_key *output, struct sk_buff *skb)
 {
-	if (nla_put_u32(skb, OVS_KEY_ATTR_CT_STATE, output->ct.state))
+	if (nla_put_u32(skb, OVS_KEY_ATTR_CT_STATE, output->ct_state))
 		return -EMSGSIZE;
 
 	if (IS_ENABLED(CONFIG_NF_CONNTRACK_ZONES) &&
-	    nla_put_u16(skb, OVS_KEY_ATTR_CT_ZONE, output->ct.zone))
+	    nla_put_u16(skb, OVS_KEY_ATTR_CT_ZONE, output->ct_zone))
 		return -EMSGSIZE;
 
 	if (IS_ENABLED(CONFIG_NF_CONNTRACK_MARK) &&
@@ -285,25 +285,25 @@ int ovs_ct_put_key(const struct sw_flow_key *swkey,
 		    &output->ct.labels))
 		return -EMSGSIZE;
 
-	if (swkey->eth.type == htons(ETH_P_IP) && swkey->ct.orig_proto) {
+	if (swkey->eth.type == htons(ETH_P_IP) && swkey->ct_orig_proto) {
 		struct ovs_key_ct_tuple_ipv4 orig = {
 			output->ipv4.ct_orig.src,
 			output->ipv4.ct_orig.dst,
 			output->ct.orig_tp.src,
 			output->ct.orig_tp.dst,
-			output->ct.orig_proto,
+			output->ct_orig_proto,
 		};
 		if (nla_put(skb, OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV4, sizeof(orig),
 			    &orig))
 			return -EMSGSIZE;
 	} else if (swkey->eth.type == htons(ETH_P_IPV6) &&
-		   swkey->ct.orig_proto) {
+		   swkey->ct_orig_proto) {
 		struct ovs_key_ct_tuple_ipv6 orig = {
 			IN6_ADDR_INITIALIZER(output->ipv6.ct_orig.src),
 			IN6_ADDR_INITIALIZER(output->ipv6.ct_orig.dst),
 			output->ct.orig_tp.src,
 			output->ct.orig_tp.dst,
-			output->ct.orig_proto,
+			output->ct_orig_proto,
 		};
 		if (nla_put(skb, OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV6, sizeof(orig),
 			    &orig))
@@ -630,11 +630,11 @@ static bool skb_nfct_cached(struct net *net,
 	 * due to an upcall.  If the connection was not confirmed, it is not
 	 * cached and needs to be run through conntrack again.
 	 */
-	if (!ct && key->ct.state & OVS_CS_F_TRACKED &&
-	    !(key->ct.state & OVS_CS_F_INVALID) &&
-	    key->ct.zone == info->zone.id) {
+	if (!ct && key->ct_state & OVS_CS_F_TRACKED &&
+	    !(key->ct_state & OVS_CS_F_INVALID) &&
+	    key->ct_zone == info->zone.id) {
 		ct = ovs_ct_find_existing(net, &info->zone, info->family, skb,
-					  !!(key->ct.state
+					  !!(key->ct_state
 					     & OVS_CS_F_NAT_MASK));
 		if (ct)
 			nf_ct_get(skb, &ctinfo);
@@ -759,7 +759,7 @@ static void ovs_nat_update_key(struct sw_flow_key *key,
 	if (maniptype == NF_NAT_MANIP_SRC) {
 		__be16 src;
 
-		key->ct.state |= OVS_CS_F_SRC_NAT;
+		key->ct_state |= OVS_CS_F_SRC_NAT;
 		if (key->eth.type == htons(ETH_P_IP))
 			key->ipv4.addr.src = ip_hdr(skb)->saddr;
 		else if (key->eth.type == htons(ETH_P_IPV6))
@@ -781,7 +781,7 @@ static void ovs_nat_update_key(struct sw_flow_key *key,
 	} else {
 		__be16 dst;
 
-		key->ct.state |= OVS_CS_F_DST_NAT;
+		key->ct_state |= OVS_CS_F_DST_NAT;
 		if (key->eth.type == htons(ETH_P_IP))
 			key->ipv4.addr.dst = ip_hdr(skb)->daddr;
 		else if (key->eth.type == htons(ETH_P_IPV6))
@@ -906,7 +906,7 @@ static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
 		 * NAT after the nf_conntrack_in() call.  We can actually clear
 		 * the whole state, as it will be re-initialized below.
 		 */
-		key->ct.state = 0;
+		key->ct_state = 0;
 
 		/* Update the key, but keep the NAT flags. */
 		ovs_ct_update_key(skb, info, key, true, true);
@@ -922,9 +922,9 @@ static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
 		 *
 		 * NAT will be done only if the CT action has NAT, and only
 		 * once per packet (per zone), as guarded by the NAT bits in
-		 * the key->ct.state.
+		 * the key->ct_state.
 		 */
-		if (info->nat && !(key->ct.state & OVS_CS_F_NAT_MASK) &&
+		if (info->nat && !(key->ct_state & OVS_CS_F_NAT_MASK) &&
 		    (nf_ct_is_confirmed(ct) || info->commit) &&
 		    ovs_ct_nat(net, key, info, skb, ct, ctinfo) != NF_ACCEPT) {
 			return -EINVAL;
diff --git a/net/openvswitch/conntrack.h b/net/openvswitch/conntrack.h
index 8573ab3..b5f7130 100644
--- a/net/openvswitch/conntrack.h
+++ b/net/openvswitch/conntrack.h
@@ -76,11 +76,11 @@ static inline int ovs_ct_execute(struct net *net, struct sk_buff *skb,
 static inline void ovs_ct_fill_key(const struct sk_buff *skb,
 				   struct sw_flow_key *key)
 {
-	key->ct.state = 0;
-	key->ct.zone = 0;
+	key->ct_state = 0;
+	key->ct_zone = 0;
 	key->ct.mark = 0;
 	memset(&key->ct.labels, 0, sizeof(key->ct.labels));
-	key->ct.orig_proto = 0;
+	key->ct_orig_proto = 0;
 	key->ct.orig_tp.src = 0;
 	key->ct.orig_tp.dst = 0;
 	if (key->eth.type == htons(ETH_P_IP))
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 19dc4d2..60ef942 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -85,6 +85,11 @@ struct sw_flow_key {
 		struct vlan_head cvlan;
 		__be16 type;		/* Ethernet frame type. */
 	} eth;
+	/* Filling a hole of two bytes. */
+	u8 ct_state;
+	u8 ct_orig_proto;		/* CT original direction tuple IP
+					 * protocol.
+					 */
 	union {
 		struct {
 			__be32 top_lse;	/* top label stack entry */
@@ -96,6 +101,7 @@ struct sw_flow_key {
 			u8     frag;	/* One of OVS_FRAG_TYPE_*. */
 		} ip;
 	};
+	u16 ct_zone;			/* Conntrack zone. */
 	struct {
 		__be16 src;		/* TCP/UDP/SCTP source port. */
 		__be16 dst;		/* TCP/UDP/SCTP destination port. */
@@ -138,16 +144,12 @@ struct sw_flow_key {
 		} ipv6;
 	};
 	struct {
-		/* Connection tracking fields. */
-		u8 state;
-		u8 orig_proto;		/* CT orig tuple IP protocol. */
-		u16 zone;
-		u32 mark;
+		/* Connection tracking fields not packed above. */
 		struct {
 			__be16 src;	/* CT orig tuple tp src port. */
 			__be16 dst;	/* CT orig tuple tp dst port. */
 		} orig_tp;
-
+		u32 mark;
 		struct ovs_key_ct_labels labels;
 	} ct;
 
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index b2594bb..82c3f1e 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -1074,14 +1074,14 @@ static int metadata_from_nlattrs(struct net *net, struct sw_flow_match *match,
 			return -EINVAL;
 		}
 
-		SW_FLOW_KEY_PUT(match, ct.state, ct_state, is_mask);
+		SW_FLOW_KEY_PUT(match, ct_state, ct_state, is_mask);
 		*attrs &= ~(1ULL << OVS_KEY_ATTR_CT_STATE);
 	}
 	if (*attrs & (1 << OVS_KEY_ATTR_CT_ZONE) &&
 	    ovs_ct_verify(net, OVS_KEY_ATTR_CT_ZONE)) {
 		u16 ct_zone = nla_get_u16(a[OVS_KEY_ATTR_CT_ZONE]);
 
-		SW_FLOW_KEY_PUT(match, ct.zone, ct_zone, is_mask);
+		SW_FLOW_KEY_PUT(match, ct_zone, ct_zone, is_mask);
 		*attrs &= ~(1ULL << OVS_KEY_ATTR_CT_ZONE);
 	}
 	if (*attrs & (1 << OVS_KEY_ATTR_CT_MARK) &&
@@ -1109,7 +1109,7 @@ static int metadata_from_nlattrs(struct net *net, struct sw_flow_match *match,
 		SW_FLOW_KEY_PUT(match, ipv4.ct_orig.dst, ct->ipv4_dst, is_mask);
 		SW_FLOW_KEY_PUT(match, ct.orig_tp.src, ct->src_port, is_mask);
 		SW_FLOW_KEY_PUT(match, ct.orig_tp.dst, ct->dst_port, is_mask);
-		SW_FLOW_KEY_PUT(match, ct.orig_proto, ct->ipv4_proto, is_mask);
+		SW_FLOW_KEY_PUT(match, ct_orig_proto, ct->ipv4_proto, is_mask);
 		*attrs &= ~(1ULL << OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV4);
 	}
 	if (*attrs & (1ULL << OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV6)) {
@@ -1125,7 +1125,7 @@ static int metadata_from_nlattrs(struct net *net, struct sw_flow_match *match,
 				   is_mask);
 		SW_FLOW_KEY_PUT(match, ct.orig_tp.src, ct->src_port, is_mask);
 		SW_FLOW_KEY_PUT(match, ct.orig_tp.dst, ct->dst_port, is_mask);
-		SW_FLOW_KEY_PUT(match, ct.orig_proto, ct->ipv6_proto, is_mask);
+		SW_FLOW_KEY_PUT(match, ct_orig_proto, ct->ipv6_proto, is_mask);
 		*attrs &= ~(1ULL << OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV6);
 	}
 
-- 
2.1.4
