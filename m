From: Jarno Rajahalme <jrajahalme@nicira.com>
Subject: [RFC PATCH 5/5] openvswitch: Interface with NAT.
Date: Tue, 20 Oct 2015 15:20:29 -0700
Message-ID: <1445379629-112880-5-git-send-email-jrajahalme@nicira.com>
References: <1445379629-112880-1-git-send-email-jrajahalme@nicira.com>
Cc: dev@openvswitch.org, jrajahalme@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35819 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753862AbbJTWU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 18:20:59 -0400
Received: by pasz6 with SMTP id z6so33380530pas.2
        for <netdev@vger.kernel.org>; Tue, 20 Oct 2015 15:20:58 -0700 (PDT)
In-Reply-To: <1445379629-112880-1-git-send-email-jrajahalme@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend OVS conntrack interface to cover NAT.  New nested
OVS_CT_ATTR_NAT may be used to include NAT with a CT action.  A bare
OVS_CT_ATTR_NAT only mangles existing connections.  If
OVS_NAT_ATTR_SRC or OVS_NAT_ATTR_DST is included within the nested
attributes, new (non-committed/non-confirmed) connections are mangled
according to the rest of the nested attributes.

This work extends on a branch by Thomas Graf at
https://github.com/tgraf/ovs/tree/nat.

Signed-off-by: Jarno Rajahalme <jrajahalme@nicira.com>
---
 include/uapi/linux/openvswitch.h |  48 +++-
 net/openvswitch/actions.c        |  25 +-
 net/openvswitch/conntrack.c      | 543 ++++++++++++++++++++++++++++++++++++---
 net/openvswitch/conntrack.h      |   2 +
 net/openvswitch/flow.h           |  11 +-
 5 files changed, 580 insertions(+), 49 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 098d8b5..9d63472 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -454,6 +454,12 @@ struct ovs_key_ct_label {
 #define OVS_CS_F_REPLY_DIR         0x08 /* Flow is in the reply direction. */
 #define OVS_CS_F_INVALID           0x10 /* Could not track connection. */
 #define OVS_CS_F_TRACKED           0x20 /* Conntrack has occurred. */
+#define OVS_CS_F_SRC_NAT           0x40 /* Packet's source address/port was
+					   mangled by NAT. */
+#define OVS_CS_F_DST_NAT           0x80 /* Packet's destination address/port
+					   was mangled by NAT. */
+
+#define OVS_CS_F_NAT_MASK (OVS_CS_F_SRC_NAT | OVS_CS_F_DST_NAT)
 
 /**
  * enum ovs_flow_attr - attributes for %OVS_FLOW_* commands.
@@ -629,6 +635,8 @@ struct ovs_action_hash {
  * mask. For each bit set in the mask, the corresponding bit in the value is
  * copied to the connection tracking label field in the connection.
  * @OVS_CT_ATTR_HELPER: variable length string defining conntrack ALG.
+ * @OVS_CT_ATTR_NAT: Nested OVS_NAT_ATTR_* for performing L3 network address
+ * translation (NAT) on the packet.
  */
 enum ovs_ct_attr {
 	OVS_CT_ATTR_UNSPEC,
@@ -638,13 +646,50 @@ enum ovs_ct_attr {
 	OVS_CT_ATTR_LABEL,      /* label to associate with this connection. */
 	OVS_CT_ATTR_HELPER,     /* netlink helper to assist detection of
 				   related connections. */
+	OVS_CT_ATTR_NAT,        /* Nested OVS_NAT_ATTR_* */
 	__OVS_CT_ATTR_MAX
 };
 
 #define OVS_CT_ATTR_MAX (__OVS_CT_ATTR_MAX - 1)
 
 /**
- * enum ovs_action_attr - Action types.
+ * enum ovs_nat_attr - Attributes for %OVS_CT_ATTR_NAT.
+ * @OVS_NAT_ATTR_SRC: Flag for Source NAT (mangle source address/port).
+ * @OVS_NAT_ATTR_DST: Flag for Destination NAT (mangle destination
+ * address/port).  Only one of (@OVS_NAT_ATTR_SRC, @OVS_NAT_ATTR_DST) may be
+ * specified.  Effective only for packets for ct_state NEW connections.
+ * Packets of committed connections are mangled by the NAT action according to
+ * the committed NAT type regardless of the flags specified.  As a corollary, a
+ * NAT action without a NAT type flag will only mangle packets of committed
+ * connections.  The following NAT attributes only apply for NEW
+ * (non-committed) connections, and they may be included only when the CT
+ * action has the @OVS_CT_ATTR_COMMIT flag and either @OVS_NAT_ATTR_SRC or
+ * @OVS_NAT_ATTR_DST is also included.
+ * @OVS_NAT_ATTR_IP_MIN: struct in_addr or struct in6_addr
+ * @OVS_NAT_ATTR_IP_MAX: struct in_addr or struct in6_addr
+ * @OVS_NAT_ATTR_PROTO_MIN: u16 L4 protocol specific lower boundary (port)
+ * @OVS_NAT_ATTR_PROTO_MAX: u16 L4 protocol specific upper boundary (port)
+ * @OVS_NAT_ATTR_PERSISTENT: Flag for persistent IP mapping across reboots
+ * @OVS_NAT_ATTR_PROTO_HASH: Flag for pseudo random L4 port mapping (MD5)
+ * @OVS_NAT_ATTR_PROTO_RANDOM: Flag for fully randomized L4 port mapping
+ */
+enum ovs_nat_attr {
+	OVS_NAT_ATTR_UNSPEC,
+	OVS_NAT_ATTR_SRC,
+	OVS_NAT_ATTR_DST,
+	OVS_NAT_ATTR_IP_MIN,
+	OVS_NAT_ATTR_IP_MAX,
+	OVS_NAT_ATTR_PROTO_MIN,
+	OVS_NAT_ATTR_PROTO_MAX,
+	OVS_NAT_ATTR_PERSISTENT,
+	OVS_NAT_ATTR_PROTO_HASH,
+	OVS_NAT_ATTR_PROTO_RANDOM,
+	__OVS_NAT_ATTR_MAX,
+};
+
+#define OVS_NAT_ATTR_MAX (__OVS_NAT_ATTR_MAX - 1)
+
+/** * enum ovs_action_attr - Action types.
  *
  * @OVS_ACTION_ATTR_OUTPUT: Output packet to port.
  * @OVS_ACTION_ATTR_USERSPACE: Send packet to userspace according to nested
@@ -700,7 +745,6 @@ enum ovs_action_attr {
 				       * The data must be zero for the unmasked
 				       * bits. */
 	OVS_ACTION_ATTR_CT,           /* One nested OVS_CT_ATTR_* . */
-
 	__OVS_ACTION_ATTR_MAX,	      /* Nothing past this will be accepted
 				       * from userspace. */
 
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 1d21ab9..e31cc55 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -127,16 +127,6 @@ static struct deferred_action *add_deferred_actions(struct sk_buff *skb,
 	return da;
 }
 
-static void invalidate_flow_key(struct sw_flow_key *key)
-{
-	key->eth.type = htons(0);
-}
-
-static bool is_flow_key_valid(const struct sw_flow_key *key)
-{
-	return !!key->eth.type;
-}
-
 static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 		     const struct ovs_action_push_mpls *mpls)
 {
@@ -169,7 +159,7 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 		skb_set_inner_protocol(skb, skb->protocol);
 	skb->protocol = mpls->mpls_ethertype;
 
-	invalidate_flow_key(key);
+	ovs_invalidate_flow_key(key);
 	return 0;
 }
 
@@ -199,7 +189,7 @@ static int pop_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 	if (eth_p_mpls(skb->protocol))
 		skb->protocol = ethertype;
 
-	invalidate_flow_key(key);
+	ovs_invalidate_flow_key(key);
 	return 0;
 }
 
@@ -234,7 +224,7 @@ static int pop_vlan(struct sk_buff *skb, struct sw_flow_key *key)
 
 	err = skb_vlan_pop(skb);
 	if (skb_vlan_tag_present(skb))
-		invalidate_flow_key(key);
+		ovs_invalidate_flow_key(key);
 	else
 		key->eth.tci = 0;
 	return err;
@@ -244,7 +234,7 @@ static int push_vlan(struct sk_buff *skb, struct sw_flow_key *key,
 		     const struct ovs_action_push_vlan *vlan)
 {
 	if (skb_vlan_tag_present(skb))
-		invalidate_flow_key(key);
+		ovs_invalidate_flow_key(key);
 	else
 		key->eth.tci = vlan->vlan_tci;
 	return skb_vlan_push(skb, vlan->vlan_tpid,
@@ -746,7 +736,7 @@ static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port,
 			struct net *net = read_pnet(&dp->net);
 			__be16 ethertype = key->eth.type;
 
-			if (!is_flow_key_valid(key)) {
+			if (!ovs_is_flow_key_valid(key)) {
 				if (eth_p_mpls(skb->protocol))
 					ethertype = skb->inner_protocol;
 				else
@@ -983,14 +973,14 @@ static int execute_recirc(struct datapath *dp, struct sk_buff *skb,
 {
 	struct deferred_action *da;
 
-	if (!is_flow_key_valid(key)) {
+	if (!ovs_is_flow_key_valid(key)) {
 		int err;
 
 		err = ovs_flow_key_update(skb, key);
 		if (err)
 			return err;
 	}
-	BUG_ON(!is_flow_key_valid(key));
+	BUG_ON(!ovs_is_flow_key_valid(key));
 
 	if (!nla_is_last(a, rem)) {
 		/* Recirc action is the not the last action
@@ -1100,6 +1090,7 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			break;
 
 		case OVS_ACTION_ATTR_CT:
+			/* XXX: 'key' must be valid. */
 			err = ovs_ct_execute(ovs_dp_get_net(dp), skb, key,
 					     nla_data(a));
 
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 6997107..4a1b56a 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -12,6 +12,7 @@
  */
 
 #include <linux/module.h>
+
 #include <linux/openvswitch.h>
 #include <net/ip.h>
 #include <net/netfilter/nf_conntrack_core.h>
@@ -20,6 +21,13 @@
 #include <net/netfilter/nf_conntrack_zones.h>
 #include <net/netfilter/ipv6/nf_defrag_ipv6.h>
 
+#ifdef CONFIG_NF_NAT_NEEDED
+#include <linux/netfilter/nf_nat.h>
+#include <net/netfilter/nf_nat_core.h>
+#include <net/netfilter/nf_nat_l3proto.h>
+#include <net/netfilter/nf_conntrack_seqadj.h>
+#endif
+
 #include "datapath.h"
 #include "conntrack.h"
 #include "flow.h"
@@ -42,7 +50,16 @@ struct md_label {
 	struct ovs_key_ct_label mask;
 };
 
-#define OVS_CT_F_COMMIT		0x01
+#define OVS_CT_F_COMMIT		0x01   /* Commit the connection. */
+#ifdef CONFIG_NF_NAT_NEEDED
+#define OVS_CT_F_NAT		0x02   /* NAT for committed connections
+					  only. */
+#define OVS_CT_F_SRC_NAT	0x04   /* Source NAT for NEW connections. */
+#define OVS_CT_F_DST_NAT	0x08   /* Destination NAT for NEW
+					  connections. */
+
+#define OVS_CT_F_NAT_MASK (OVS_CT_F_NAT | OVS_CT_F_SRC_NAT | OVS_CT_F_DST_NAT)
+#endif
 
 /* Conntrack action context for execution. */
 struct ovs_conntrack_info {
@@ -53,6 +70,9 @@ struct ovs_conntrack_info {
 	u16 family;
 	struct md_mark mark;
 	struct md_label label;
+#ifdef CONFIG_NF_NAT_NEEDED
+	struct nf_nat_range range;   /* Only present for SNAT and DNAT. */
+#endif
 };
 
 static u16 key_to_nfproto(const struct sw_flow_key *key)
@@ -87,6 +107,8 @@ static u8 ovs_ct_get_state(enum ip_conntrack_info ctinfo)
 		ct_state |= OVS_CS_F_ESTABLISHED;
 		break;
 	case IP_CT_RELATED:
+		ct_state |= OVS_CS_F_NEW;
+		/* Fall through. */
 	case IP_CT_RELATED_REPLY:
 		ct_state |= OVS_CS_F_RELATED;
 		break;
@@ -137,11 +159,17 @@ static void __ovs_ct_update_key(struct sw_flow_key *key, u8 state,
 	ovs_ct_get_label(ct, &key->ct.label);
 }
 
-/* Update 'key' based on skb->nfct. If 'post_ct' is true, then OVS has
- * previously sent the packet to conntrack via the ct action.
+/* Update 'key' based on skb->nfct.  If 'post_ct' is true, then OVS has
+ * previously sent the packet to conntrack via the ct action.  If
+ * 'keep_nat_flags' is true, the existing NAT flags retained, else they are
+ * initialized from the connection status.
  */
 static void ovs_ct_update_key(const struct sk_buff *skb,
-			      struct sw_flow_key *key, bool post_ct)
+			      struct sw_flow_key *key, bool post_ct
+#ifdef CONFIG_NF_NAT_NEEDED
+			      , bool keep_nat_flags
+#endif
+			      )
 {
 	const struct nf_conntrack_zone *zone = &nf_ct_zone_dflt;
 	enum ip_conntrack_info ctinfo;
@@ -151,8 +179,20 @@ static void ovs_ct_update_key(const struct sk_buff *skb,
 	ct = nf_ct_get(skb, &ctinfo);
 	if (ct) {
 		state = ovs_ct_get_state(ctinfo);
+		/* OVS persists the related flag for the duration of the
+		 * connection. */
 		if (ct->master)
 			state |= OVS_CS_F_RELATED;
+#ifdef CONFIG_NF_NAT_NEEDED
+		if (keep_nat_flags)
+			state |= key->ct.state & OVS_CS_F_NAT_MASK;
+		else {
+			if (ct->status & IPS_SRC_NAT)
+				state |= OVS_CS_F_SRC_NAT;
+			if (ct->status & IPS_DST_NAT)
+				state |= OVS_CS_F_DST_NAT;
+		}
+#endif
 		zone = nf_ct_zone(ct);
 	} else if (post_ct) {
 		state = OVS_CS_F_TRACKED | OVS_CS_F_INVALID;
@@ -160,9 +200,15 @@ static void ovs_ct_update_key(const struct sk_buff *skb,
 	__ovs_ct_update_key(key, state, zone, ct);
 }
 
+/* This is called to initialize CT key fields possibly coming in from the local
+ * stack. */
 void ovs_ct_fill_key(const struct sk_buff *skb, struct sw_flow_key *key)
 {
-	ovs_ct_update_key(skb, key, false);
+	ovs_ct_update_key(skb, key, false
+#ifdef CONFIG_NF_NAT_NEEDED
+			  , false
+#endif
+			  );
 }
 
 int ovs_ct_put_key(const struct sw_flow_key *key, struct sk_buff *skb)
@@ -291,7 +337,16 @@ static int ovs_ct_helper(struct sk_buff *skb, u16 proto)
 		return NF_DROP;
 	}
 
-	return helper->help(skb, protoff, ct, ctinfo);
+	if (helper->help(skb, protoff, ct, ctinfo) != NF_ACCEPT)
+		return NF_DROP;
+
+#ifdef CONFIG_NF_NAT_NEEDED
+	/* Adjust seqs after helper. */
+	if (test_bit(IPS_SEQ_ADJUST_BIT, &ct->status)
+	    && !nf_ct_seq_adjust(skb, ct, ctinfo, protoff))
+		return NF_DROP;
+#endif
+	return NF_ACCEPT;
 }
 
 static int handle_fragments(struct net *net, struct sw_flow_key *key,
@@ -377,7 +432,211 @@ static bool skb_nfct_cached(const struct net *net, const struct sk_buff *skb,
 	return true;
 }
 
-static int __ovs_ct_lookup(struct net *net, const struct sw_flow_key *key,
+#ifdef CONFIG_NF_NAT_NEEDED
+/* Modeled after nf_nat_ipv[46]_fn().
+ * range is only used for new, uninitialized NAT state.
+ * Returns either NF_ACCEPT or NF_DROP. */
+static int ovs_ct_nat_execute(struct sk_buff *skb, struct nf_conn *ct,
+			      enum ip_conntrack_info ctinfo,
+			      const struct nf_nat_range *range,
+			      enum nf_nat_manip_type maniptype)
+{
+	int hooknum, nh_off, err = NF_ACCEPT;
+
+	nh_off = skb_network_offset(skb);
+	skb_pull(skb, nh_off);
+
+	/* See HOOK2MANIP(). */
+	if (maniptype == NF_NAT_MANIP_SRC)
+		hooknum = NF_INET_LOCAL_IN; /* Source NAT */
+	else
+		hooknum = NF_INET_LOCAL_OUT; /* Destination NAT */
+
+	switch (ctinfo) {
+	case IP_CT_RELATED:
+	case IP_CT_RELATED_REPLY:
+		if (skb->protocol == htons(ETH_P_IP)
+		    && ip_hdr(skb)->protocol == IPPROTO_ICMP) {
+			if (!nf_nat_icmp_reply_translation(skb, ct, ctinfo,
+							   hooknum))
+				err = NF_DROP;
+			goto push;
+		} else if (skb->protocol == htons(ETH_P_IPV6)) {
+			__be16 frag_off;
+			u8 nexthdr = ipv6_hdr(skb)->nexthdr;
+			int hdrlen = ipv6_skip_exthdr(skb,
+						      sizeof(struct ipv6hdr),
+						      &nexthdr, &frag_off);
+
+			if (hdrlen >= 0 && nexthdr == IPPROTO_ICMPV6) {
+				if (!nf_nat_icmpv6_reply_translation(skb, ct,
+								     ctinfo,
+								     hooknum,
+								     hdrlen))
+					err = NF_DROP;
+				goto push;
+			}
+		}
+		/* Non-ICMP, fall thru to initialize if needed. */
+	case IP_CT_NEW:
+		/* Seen it before?  This can happen for loopback, retrans,
+		 * or local packets.
+		 */
+		if (!nf_nat_initialized(ct, maniptype)) {
+			/* Initialize according to the NAT action. */
+			err = (range && range->flags & NF_NAT_RANGE_MAP_IPS)
+				/* Action is set up to establish a new
+				 * mapping */
+				? nf_nat_setup_info(ct, range, maniptype)
+				: nf_nat_alloc_null_binding(ct, hooknum);
+		}
+		break;
+
+	case IP_CT_ESTABLISHED:
+	case IP_CT_ESTABLISHED_REPLY:
+		break;
+
+	default:
+		err = NF_DROP;
+		goto push;
+	}
+
+	if (err == NF_ACCEPT)
+		err = nf_nat_packet(ct, ctinfo, hooknum, skb);
+push:
+	skb_push(skb, nh_off);
+
+	return err;
+}
+
+/* Find an existing conntrack entry for which this packet was already applied
+ * to.  This is only called when there is evidence that the packet was already
+ * tracked and commited, but we lost the ct reference due to an userspace
+ * upcall. This means that on entry skb->nfct is NULL.
+ * On success, returns conntrack ptr, sets skb->nfct and ctinfo.
+ * Must be called rcu_read_lock()ed. */
+static struct nf_conn *
+ovs_ct_find_existing(struct net *net, const struct nf_conntrack_zone *zone,
+		     u_int8_t l3num, struct sk_buff *skb,
+		     enum ip_conntrack_info *ctinfo)
+{
+	struct nf_conntrack_l3proto *l3proto;
+	struct nf_conntrack_l4proto *l4proto;
+	struct nf_conntrack_tuple tuple;
+	struct nf_conntrack_tuple_hash *h;
+	struct nf_conn *ct;
+	unsigned int dataoff;
+	u_int8_t protonum;
+
+	BUG_ON(skb->nfct != NULL);
+
+	l3proto = __nf_ct_l3proto_find(l3num);
+	if (!l3proto)
+		return NULL;
+	if (l3proto->get_l4proto(skb, skb_network_offset(skb), &dataoff,
+				 &protonum) <= 0) {
+		pr_warn("ovs_ct_find_existing: Can't get l4proto\n");
+		return NULL;
+	}
+	l4proto = __nf_ct_l4proto_find(l3num, protonum);
+	if (!l4proto)
+		return NULL;
+
+	if (!nf_ct_get_tuple(skb, skb_network_offset(skb), dataoff, l3num,
+			     protonum, net, &tuple, l3proto, l4proto)) {
+		pr_warn("ovs_ct_find_existing: Can't get tuple\n");
+		return NULL;
+	}
+
+	/* look for tuple match */
+	h = nf_conntrack_find_get(net, zone, &tuple);
+	if (!h) {
+		pr_warn("ovs_ct_find_existing: Can't find tuple\n");
+		return NULL;
+	}
+	ct = nf_ct_tuplehash_to_ctrack(h);
+
+	*ctinfo = nf_ct_get_info(h);
+	if (*ctinfo == IP_CT_NEW) {
+		/* This should not happen. */
+		pr_warn("ovs_ct_find_existing: new packet for %p\n", ct);
+	}
+	skb->nfct = &ct->ct_general;
+	skb->nfctinfo = *ctinfo;
+	return ct;
+}
+
+/* Returns NF_DROP if the packet should be dropped, NF_ACCEPT otherwise.
+ * This action can be used to both NAT and reverse NAT, however, reverse NAT
+ * can also be done with the conntrack action. */
+static int ovs_ct_nat(struct net *net, struct sw_flow_key *key,
+		      const struct ovs_conntrack_info *info,
+		      struct sk_buff *skb)
+{
+	enum nf_nat_manip_type maniptype;
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct;
+	int err;
+
+	/* No NAT action or already NATed? */
+	if (!(info->flags & OVS_CT_F_NAT_MASK)
+	    || key->ct.state & OVS_CS_F_NAT_MASK)
+		return NF_ACCEPT;
+
+	ct = nf_ct_get(skb, &ctinfo);
+	/* Check if an existing conntrack entry may be found for this skb.
+	 * This happens when we lose the ct entry pointer due to an upcall.
+	 * Don't lookup invalid connections. */
+	if (!ct && key->ct.state & OVS_CS_F_TRACKED
+	    && !(key->ct.state & OVS_CS_F_INVALID))
+		ct = ovs_ct_find_existing(net, &info->zone, info->family, skb,
+					  &ctinfo);
+	if (!ct || nf_ct_is_untracked(ct))
+		/* A NAT action may only be performed on tracked packets. */
+		return NF_ACCEPT;
+
+	/* Add NAT extension if not commited yet. */
+	if (!nf_ct_is_confirmed(ct)) {
+		if (!nf_ct_nat_ext_add(ct))
+			return NF_ACCEPT;   /* Can't NAT. */
+	}
+
+	/* Determine NAT type.
+	 * Check if the NAT type can be deduced from the tracked connection.
+	 * Make sure expected traffic is NATted only when commiting. */
+	if (info->flags & OVS_CT_F_NAT && ctinfo != IP_CT_NEW
+	    && ct->status & IPS_NAT_MASK
+	    && (!(ct->status & IPS_EXPECTED_BIT)
+		|| info->flags & OVS_CT_F_COMMIT)) {
+		/* NAT an established or related connection like before. */
+		if (CTINFO2DIR(ctinfo) == IP_CT_DIR_REPLY)
+			/* This is the REPLY direction for a connection
+			 * for which NAT was applied in the forward
+			 * direction.  Do the reverse NAT. */
+			maniptype = ct->status & IPS_SRC_NAT
+				? NF_NAT_MANIP_DST : NF_NAT_MANIP_SRC;
+		else
+			maniptype = ct->status & IPS_SRC_NAT
+				? NF_NAT_MANIP_SRC : NF_NAT_MANIP_DST;
+	}
+	else if (info->flags & OVS_CT_F_SRC_NAT)
+		maniptype = NF_NAT_MANIP_SRC;
+	else if (info->flags & OVS_CT_F_DST_NAT)
+		maniptype = NF_NAT_MANIP_DST;
+	else
+		return NF_ACCEPT; /* Connection is not NATed. */
+
+	err = ovs_ct_nat_execute(skb, ct, ctinfo, &info->range, maniptype);
+
+	/* Mark NAT done if successful. */
+	if (err == NF_ACCEPT)
+		key->ct.state |= (maniptype == NF_NAT_MANIP_SRC)
+			? OVS_CS_F_SRC_NAT : OVS_CS_F_DST_NAT;
+	return err;
+}
+#endif
+
+static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
 			   const struct ovs_conntrack_info *info,
 			   struct sk_buff *skb)
 {
@@ -386,7 +645,9 @@ static int __ovs_ct_lookup(struct net *net, const struct sw_flow_key *key,
 	 * actually run the packet through conntrack twice unless it's for a
 	 * different zone.
 	 */
-	if (!skb_nfct_cached(net, skb, info)) {
+	bool cached = skb_nfct_cached(net, skb, info);
+
+	if (!cached) {
 		struct nf_conn *tmpl = info->ct;
 
 		/* Associate skb with specified zone. */
@@ -402,10 +663,38 @@ static int __ovs_ct_lookup(struct net *net, const struct sw_flow_key *key,
 				    skb) != NF_ACCEPT)
 			return -ENOENT;
 
-		if (ovs_ct_helper(skb, info->family) != NF_ACCEPT) {
-			WARN_ONCE(1, "helper rejected packet");
-			return -EINVAL;
-		}
+		/* Clear CT state NAT flags to mark that we have not yet done
+		 * NAT after the nf_conntrack_in() call.  We can actually clear
+		 * the whole state, as it will be re-initialized below. */
+		key->ct.state = 0;
+
+		/* Update the key, but keep the NAT flags. */
+		ovs_ct_update_key(skb, key, true
+#ifdef CONFIG_NF_NAT_NEEDED
+				  , true);
+#endif
+	}
+
+	/* Never NAT or Help NEW connections without commit. */
+	if ((key->ct.state & OVS_CS_F_NEW) && !(info->flags & OVS_CT_F_COMMIT))
+		return 0;
+
+#ifdef CONFIG_NF_NAT_NEEDED
+	/* NAT action must be executed once on every packet, and before the
+	 * helper, if any. */
+	if (ovs_ct_nat(net, key, info, skb) != NF_ACCEPT) {
+		WARN_ONCE(1, "NAT rejected packet");
+		return -EINVAL;
+	}
+#endif
+	/* Call helper after the first time nf_conntrack_in is called,
+	 * and for new connections that are being commited. */
+	if ((!cached ||
+	     ((key->ct.state & OVS_CS_F_NEW)
+	      && (info->flags & OVS_CT_F_COMMIT)))
+	    && ovs_ct_helper(skb, info->family) != NF_ACCEPT) {
+		WARN_ONCE(1, "helper rejected packet");
+		return -EINVAL;
 	}
 
 	return 0;
@@ -422,18 +711,13 @@ static int ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
 	if (exp) {
 		u8 state;
 
+		/* NOTE: New connections are NATted and Helped only when
+		 * commited, so we are not calling into NAT here. */
 		state = OVS_CS_F_TRACKED | OVS_CS_F_NEW | OVS_CS_F_RELATED;
 		__ovs_ct_update_key(key, state, &info->zone, exp->master);
 	} else {
-		int err;
-
-		err = __ovs_ct_lookup(net, key, info, skb);
-		if (err)
-			return err;
-
-		ovs_ct_update_key(skb, key, true);
+		return __ovs_ct_lookup(net, key, info, skb);
 	}
-
 	return 0;
 }
 
@@ -448,9 +732,8 @@ static int ovs_ct_commit(struct net *net, struct sw_flow_key *key,
 	state = key->ct.state;
 	if (key->ct.zone == info->zone.id &&
 	    ((state & OVS_CS_F_TRACKED) && !(state & OVS_CS_F_NEW))) {
-		/* Previous lookup has shown that this connection is already
-		 * tracked and committed. Skip committing.
-		 */
+		/* Previous lookup has shown that this packet is already
+		 * tracked and the connection is committed. Skip committing. */
 		return 0;
 	}
 
@@ -459,9 +742,6 @@ static int ovs_ct_commit(struct net *net, struct sw_flow_key *key,
 		return err;
 	if (nf_conntrack_confirm(skb) != NF_ACCEPT)
 		return -EINVAL;
-
-	ovs_ct_update_key(skb, key, true);
-
 	return 0;
 }
 
@@ -495,8 +775,9 @@ int ovs_ct_execute(struct net *net, struct sk_buff *skb,
 
 	if (info->flags & OVS_CT_F_COMMIT)
 		err = ovs_ct_commit(net, key, info, skb);
-	else
+	else {
 		err = ovs_ct_lookup(net, key, info, skb);
+	}
 	if (err)
 		goto err;
 
@@ -538,6 +819,131 @@ static int ovs_ct_add_helper(struct ovs_conntrack_info *info, const char *name,
 	return 0;
 }
 
+#ifdef CONFIG_NF_NAT_NEEDED
+static int parse_nat(const struct nlattr *attr,
+		     struct ovs_conntrack_info *info, bool log)
+{
+	struct nlattr *a;
+	int rem;
+	bool have_ip_max = false;
+	bool have_proto_max = false;
+	bool ip_vers = (info->family == NFPROTO_IPV6);
+
+	nla_for_each_nested(a, attr, rem) {
+		static const u16 ovs_nat_attr_lens[OVS_NAT_ATTR_MAX + 1][2] = {
+			[OVS_NAT_ATTR_SRC] = {0, 0},
+			[OVS_NAT_ATTR_DST] = {0, 0},
+			[OVS_NAT_ATTR_IP_MIN] = {sizeof(struct in_addr),
+						 sizeof(struct in6_addr)},
+			[OVS_NAT_ATTR_IP_MAX] = {sizeof(struct in_addr),
+						 sizeof(struct in6_addr)},
+			[OVS_NAT_ATTR_PROTO_MIN] = {sizeof(u16),sizeof(u16)},
+			[OVS_NAT_ATTR_PROTO_MAX] = {sizeof(u16),sizeof(u16)},
+			[OVS_NAT_ATTR_PERSISTENT] = {0, 0},
+			[OVS_NAT_ATTR_PROTO_HASH] = {0, 0},
+			[OVS_NAT_ATTR_PROTO_RANDOM] = {0, 0},
+		};
+		int type = nla_type(a);
+
+		if (type > OVS_NAT_ATTR_MAX) {
+			OVS_NLERR(log, "Unknown nat attribute (type=%d, max=%d).\n",
+			type, OVS_NAT_ATTR_MAX);
+			return -EINVAL;
+		}
+
+		if (ovs_nat_attr_lens[type][ip_vers] != nla_len(a)) {
+			OVS_NLERR(log, "NAT attribute type has unexpected "
+				  " length (type=%d, length=%d, expected=%d).\n",
+				  type, nla_len(a),
+				  ovs_nat_attr_lens[type][ip_vers]);
+			return -EINVAL;
+		}
+
+		switch (type) {
+		case OVS_NAT_ATTR_SRC:
+		case OVS_NAT_ATTR_DST:
+			if (info->flags & OVS_CT_F_NAT) {
+				OVS_NLERR(log, "Only one type of NAT may be "
+					  "specified.\n");
+				return -ERANGE;
+			}
+			info->flags |= OVS_CT_F_NAT;
+			info->flags |= ((type == OVS_NAT_ATTR_SRC)
+					? OVS_CT_F_SRC_NAT : OVS_CT_F_DST_NAT);
+			break;
+
+		case OVS_NAT_ATTR_IP_MIN:
+			nla_memcpy(&info->range.min_addr, a, nla_len(a));
+			info->range.flags |= NF_NAT_RANGE_MAP_IPS;
+			break;
+
+		case OVS_NAT_ATTR_IP_MAX:
+			have_ip_max = true;
+			nla_memcpy(&info->range.max_addr, a,
+				   sizeof(info->range.max_addr));
+			info->range.flags |= NF_NAT_RANGE_MAP_IPS;
+			break;
+
+		case OVS_NAT_ATTR_PROTO_MIN:
+			info->range.min_proto.all = nla_get_u16(a);
+			info->range.flags |= NF_NAT_RANGE_PROTO_SPECIFIED;
+			break;
+
+		case OVS_NAT_ATTR_PROTO_MAX:
+			have_proto_max = true;
+			info->range.max_proto.all = nla_get_u16(a);
+			info->range.flags |= NF_NAT_RANGE_PROTO_SPECIFIED;
+			break;
+
+		case OVS_NAT_ATTR_PERSISTENT:
+			info->range.flags |= NF_NAT_RANGE_PERSISTENT;
+			break;
+
+		case OVS_NAT_ATTR_PROTO_HASH:
+			info->range.flags |= NF_NAT_RANGE_PROTO_RANDOM;
+			break;
+
+		case OVS_NAT_ATTR_PROTO_RANDOM:
+			info->range.flags |= NF_NAT_RANGE_PROTO_RANDOM_FULLY;
+			break;
+
+		default:
+			OVS_NLERR(log, "Unknown nat attribute (%d).\n", type);
+			return -EINVAL;
+		}
+	}
+
+	if (rem > 0) {
+		OVS_NLERR(log, "NAT attribute has %d unknown bytes.\n", rem);
+		return -EINVAL;
+	}
+	if (!(info->flags & OVS_CT_F_NAT)) {
+		/* Do not allow range if no type is given. */
+		if (info->range.flags) {
+			OVS_NLERR(log, "NAT flags may be given only when NAT "
+				  "range (SRC or DST) is also specified.\n");
+			return -EINVAL;
+		}
+		info->flags |= OVS_CT_F_NAT;   /* NAT existing connections. */
+	} else if (!(info->flags & OVS_CT_F_COMMIT)) {
+		OVS_NLERR(log, "NAT attributes may be specified only "
+			  "when CT COMMIT flag is also specified.\n");
+		return -EINVAL;
+	}
+	/* Allow missing IP_MAX. */
+	if (info->range.flags & NF_NAT_RANGE_MAP_IPS && !have_ip_max) {
+		memcpy(&info->range.max_addr, &info->range.min_addr,
+		       sizeof(info->range.max_addr));
+	}
+	/* Allow missing PROTO_MAX. */
+	if (info->range.flags & NF_NAT_RANGE_PROTO_SPECIFIED
+	    && !have_proto_max) {
+		info->range.max_proto.all = info->range.min_proto.all;
+	}
+	return 0;
+}
+#endif
+
 static const struct ovs_ct_len_tbl ovs_ct_attr_lens[OVS_CT_ATTR_MAX + 1] = {
 	[OVS_CT_ATTR_COMMIT]	= { .minlen = 0,
 				    .maxlen = 0 },
@@ -548,7 +954,11 @@ static const struct ovs_ct_len_tbl ovs_ct_attr_lens[OVS_CT_ATTR_MAX + 1] = {
 	[OVS_CT_ATTR_LABEL]	= { .minlen = sizeof(struct md_label),
 				    .maxlen = sizeof(struct md_label) },
 	[OVS_CT_ATTR_HELPER]	= { .minlen = 1,
-				    .maxlen = NF_CT_HELPER_NAME_LEN }
+				    .maxlen = NF_CT_HELPER_NAME_LEN },
+#ifdef CONFIG_NF_NAT_NEEDED
+	[OVS_CT_ATTR_NAT]	= { .minlen = 0,
+				    .maxlen = 96 }
+#endif
 };
 
 static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
@@ -607,6 +1017,14 @@ static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
 				return -EINVAL;
 			}
 			break;
+#ifdef CONFIG_NF_NAT_NEEDED
+		case OVS_CT_ATTR_NAT: {
+			int err = parse_nat(a, info, log);
+			if (err)
+				return err;
+			break;
+		}
+#endif
 		default:
 			OVS_NLERR(log, "Unknown conntrack attr (%d)",
 				  type);
@@ -692,6 +1110,69 @@ err_free_ct:
 	return err;
 }
 
+#ifdef CONFIG_NF_NAT_NEEDED
+static bool ovs_ct_nat_to_attr(const struct ovs_conntrack_info *info,
+			       struct sk_buff *skb)
+{
+	struct nlattr *start;
+
+	start = nla_nest_start(skb, OVS_CT_ATTR_NAT);
+	if (!start)
+		return false;
+
+	if (info->flags & OVS_CT_F_SRC_NAT) {
+		if (nla_put_flag(skb, OVS_NAT_ATTR_SRC))
+			return false;
+	} else if (info->flags & OVS_CT_F_DST_NAT) {
+		if (nla_put_flag(skb, OVS_NAT_ATTR_DST))
+			return false;
+	} else {
+		goto out;
+	}
+
+	if (info->range.flags & NF_NAT_RANGE_MAP_IPS) {
+		if (info->family == NFPROTO_IPV4) {
+			if (nla_put_in_addr(skb, OVS_NAT_ATTR_IP_MIN,
+					info->range.min_addr.ip) ||
+			    (info->range.max_addr.ip != info->range.min_addr.ip
+			     && (nla_put_in_addr(skb, OVS_NAT_ATTR_IP_MAX,
+						 info->range.max_addr.ip))))
+				return false;
+		} else { /* IPv6 */
+			if (nla_put_in6_addr(skb, OVS_NAT_ATTR_IP_MIN,
+					     &info->range.min_addr.in6) ||
+			    (memcmp(&info->range.max_addr.in6,
+				    &info->range.min_addr.in6,
+				    sizeof info->range.max_addr.in6)
+			     && (nla_put_in6_addr(skb, OVS_NAT_ATTR_IP_MAX,
+						  &info->range.max_addr.in6))))
+				return false;
+		}
+	}
+	if (info->range.flags & NF_NAT_RANGE_PROTO_SPECIFIED &&
+	    (nla_put_u16(skb, OVS_NAT_ATTR_PROTO_MIN,
+			 info->range.min_proto.all)
+	     || (info->range.max_proto.all != info->range.min_proto.all
+		 && nla_put_u16(skb, OVS_NAT_ATTR_PROTO_MAX,
+				info->range.max_proto.all))))
+		return false;
+
+	if (info->range.flags & NF_NAT_RANGE_PERSISTENT &&
+	    nla_put_flag(skb, OVS_NAT_ATTR_PERSISTENT))
+		return false;
+	if (info->range.flags & NF_NAT_RANGE_PROTO_RANDOM &&
+	    nla_put_flag(skb, OVS_NAT_ATTR_PROTO_HASH))
+		return false;
+	if (info->range.flags & NF_NAT_RANGE_PROTO_RANDOM_FULLY &&
+	    nla_put_flag(skb, OVS_NAT_ATTR_PROTO_RANDOM))
+		return false;
+out:
+	nla_nest_end(skb, start);
+
+	return true;
+}
+#endif
+
 int ovs_ct_action_to_attr(const struct ovs_conntrack_info *ct_info,
 			  struct sk_buff *skb)
 {
@@ -720,7 +1201,11 @@ int ovs_ct_action_to_attr(const struct ovs_conntrack_info *ct_info,
 				   ct_info->helper->name))
 			return -EMSGSIZE;
 	}
-
+#ifdef CONFIG_NF_NAT_NEEDED
+	if (ct_info->flags & OVS_CT_F_NAT_MASK &&
+	    !ovs_ct_nat_to_attr(ct_info, skb))
+		return -EMSGSIZE;
+#endif
 	nla_nest_end(skb, start);
 
 	return 0;
diff --git a/net/openvswitch/conntrack.h b/net/openvswitch/conntrack.h
index 43f5dd7..2b8ff65 100644
--- a/net/openvswitch/conntrack.h
+++ b/net/openvswitch/conntrack.h
@@ -34,6 +34,7 @@ int ovs_ct_execute(struct net *, struct sk_buff *, struct sw_flow_key *,
 void ovs_ct_fill_key(const struct sk_buff *skb, struct sw_flow_key *key);
 int ovs_ct_put_key(const struct sw_flow_key *key, struct sk_buff *skb);
 void ovs_ct_free_action(const struct nlattr *a);
+
 #else
 #include <linux/errno.h>
 
@@ -82,5 +83,6 @@ static inline int ovs_ct_put_key(const struct sw_flow_key *key,
 }
 
 static inline void ovs_ct_free_action(const struct nlattr *a) { }
+
 #endif /* CONFIG_NF_CONNTRACK */
 #endif /* ovs_conntrack.h */
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 5688e33..2837690 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -119,7 +119,6 @@ struct sw_flow_key {
 		u8 state;
 		struct ovs_key_ct_label label;
 	} ct;
-
 } __aligned(BITS_PER_LONG/8); /* Ensure that we can do comparisons as longs. */
 
 struct sw_flow_key_range {
@@ -210,6 +209,16 @@ static inline bool ovs_identifier_is_key(const struct sw_flow_id *sfid)
 	return !ovs_identifier_is_ufid(sfid);
 }
 
+static inline void ovs_invalidate_flow_key(struct sw_flow_key *key)
+{
+	key->eth.type = htons(0);
+}
+
+static inline bool ovs_is_flow_key_valid(const struct sw_flow_key *key)
+{
+	return !!key->eth.type;
+}
+
 void ovs_flow_stats_update(struct sw_flow *, __be16 tcp_flags,
 			   const struct sk_buff *);
 void ovs_flow_stats_get(const struct sw_flow *, struct ovs_flow_stats *,
-- 
2.1.4
