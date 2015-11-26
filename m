From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH net-next v3 8/8] openvswitch: Interface with NAT.
Date: Wed, 25 Nov 2015 16:08:21 -0800
Message-ID: <1448496501-109561-9-git-send-email-jarno@ovn.org>
References: <1448496501-109561-1-git-send-email-jarno@ovn.org>
Cc: netfilter-devel@vger.kernel.org, dev@openvswitch.org, jarno@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:42816 "EHLO
	relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753198AbbKZAI7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 19:08:59 -0500
In-Reply-To: <1448496501-109561-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend OVS conntrack interface to cover NAT.  New nested
OVS_CT_ATTR_NAT attribute may be used to include NAT with a CT action.
A bare OVS_CT_ATTR_NAT only mangles existing and expected connections.
If OVS_NAT_ATTR_SRC or OVS_NAT_ATTR_DST is included within the nested
attributes, new (non-committed/non-confirmed) connections are mangled
according to the rest of the nested attributes.

The corresponding OVS userspace patch series includes test cases (in
tests/system-traffic.at) that also serve as example uses.

This work extends on a branch by Thomas Graf at
https://github.com/tgraf/ovs/tree/nat.

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
 include/uapi/linux/openvswitch.h |  47 ++++
 net/openvswitch/conntrack.c      | 520 +++++++++++++++++++++++++++++++++++++--
 net/openvswitch/conntrack.h      |   3 +-
 3 files changed, 544 insertions(+), 26 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 28ccedd..1a4bbdc 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -454,6 +454,12 @@ struct ovs_key_ct_labels {
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
@@ -632,6 +638,8 @@ struct ovs_action_hash {
  * mask. For each bit set in the mask, the corresponding bit in the value is
  * copied to the connection tracking label field in the connection.
  * @OVS_CT_ATTR_HELPER: variable length string defining conntrack ALG.
+ * @OVS_CT_ATTR_NAT: Nested OVS_NAT_ATTR_* for performing L3 network address
+ * translation (NAT) on the packet.
  */
 enum ovs_ct_attr {
 	OVS_CT_ATTR_UNSPEC,
@@ -641,12 +649,51 @@ enum ovs_ct_attr {
 	OVS_CT_ATTR_LABELS,     /* labels to associate with this connection. */
 	OVS_CT_ATTR_HELPER,     /* netlink helper to assist detection of
 				   related connections. */
+	OVS_CT_ATTR_NAT,        /* Nested OVS_NAT_ATTR_* */
 	__OVS_CT_ATTR_MAX
 };
 
 #define OVS_CT_ATTR_MAX (__OVS_CT_ATTR_MAX - 1)
 
 /**
+ * enum ovs_nat_attr - Attributes for %OVS_CT_ATTR_NAT.
+ *
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
+/**
  * enum ovs_action_attr - Action types.
  *
  * @OVS_ACTION_ATTR_OUTPUT: Output packet to port.
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index ba44287..b1f18ae 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -20,6 +20,16 @@
 #include <net/netfilter/nf_conntrack_zones.h>
 #include <net/netfilter/ipv6/nf_defrag_ipv6.h>
 
+#ifdef CONFIG_NF_NAT_NEEDED
+#include <linux/netfilter/nf_nat.h>
+#include <net/netfilter/nf_nat_core.h>
+#include <net/netfilter/nf_nat_l3proto.h>
+#include <net/netfilter/nf_conntrack_seqadj.h>
+#include <linux/sctp.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
+#endif
+
 #include "datapath.h"
 #include "conntrack.h"
 #include "flow.h"
@@ -42,15 +52,29 @@ struct md_labels {
 	struct ovs_key_ct_labels mask;
 };
 
+#ifdef CONFIG_NF_NAT_NEEDED
+enum ovs_ct_nat {
+	OVS_CT_NAT = 1 << 0,     /* NAT for committed connections only. */
+	OVS_CT_SRC_NAT = 1 << 1, /* Source NAT for NEW connections. */
+	OVS_CT_DST_NAT = 1 << 2, /* Destination NAT for NEW connections. */
+};
+#endif
+
 /* Conntrack action context for execution. */
 struct ovs_conntrack_info {
 	struct nf_conntrack_helper *helper;
 	struct nf_conntrack_zone zone;
 	struct nf_conn *ct;
 	u8 commit : 1;
+#ifdef CONFIG_NF_NAT_NEEDED
+	u8 nat : 3;                 /* enum ovs_ct_nat */
+#endif
 	u16 family;
 	struct md_mark mark;
 	struct md_labels labels;
+#ifdef CONFIG_NF_NAT_NEEDED
+	struct nf_nat_range range;  /* Only present for SRC NAT and DST NAT. */
+#endif
 };
 
 static u16 key_to_nfproto(const struct sw_flow_key *key)
@@ -135,11 +159,14 @@ static void __ovs_ct_update_key(struct sw_flow_key *key, u8 state,
 	ovs_ct_get_labels(ct, &key->ct.labels);
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
+			      struct sw_flow_key *key, bool post_ct,
+			      bool keep_nat_flags)
 {
 	const struct nf_conntrack_zone *zone = &nf_ct_zone_dflt;
 	enum ip_conntrack_info ctinfo;
@@ -149,10 +176,24 @@ static void ovs_ct_update_key(const struct sk_buff *skb,
 	ct = nf_ct_get(skb, &ctinfo);
 	if (ct) {
 		state = ovs_ct_get_state(ctinfo);
+		/* All unconfirmed entries are NEW connections. */
 		if (!nf_ct_is_confirmed(ct))
 			state |= OVS_CS_F_NEW;
+		/* OVS persists the related flag for the duration of the
+		 * connection.
+		 */
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
@@ -160,9 +201,11 @@ static void ovs_ct_update_key(const struct sk_buff *skb,
 	__ovs_ct_update_key(key, state, zone, ct);
 }
 
+/* This is called to initialize CT key fields possibly coming in from the local
+ * stack. */
 void ovs_ct_fill_key(const struct sk_buff *skb, struct sw_flow_key *key)
 {
-	ovs_ct_update_key(skb, key, false);
+	ovs_ct_update_key(skb, key, false, false);
 }
 
 int ovs_ct_put_key(const struct sw_flow_key *key, struct sk_buff *skb)
@@ -251,6 +294,7 @@ static int ovs_ct_helper(struct sk_buff *skb, u16 proto)
 	enum ip_conntrack_info ctinfo;
 	unsigned int protoff;
 	struct nf_conn *ct;
+	int err;
 
 	ct = nf_ct_get(skb, &ctinfo);
 	if (!ct || ctinfo == IP_CT_RELATED_REPLY)
@@ -287,7 +331,20 @@ static int ovs_ct_helper(struct sk_buff *skb, u16 proto)
 		return NF_DROP;
 	}
 
-	return helper->help(skb, protoff, ct, ctinfo);
+	err = helper->help(skb, protoff, ct, ctinfo);
+	if (err != NF_ACCEPT)
+		return err;
+
+#ifdef CONFIG_NF_NAT_NEEDED
+	/* Adjust seqs after helper.  This is needed due to some helpers (e.g.,
+	 * FTP with NAT) adusting the TCP payload size when mangling IP
+	 * addresses and/or port numbers in the text-based control connection.
+	 */
+	if (test_bit(IPS_SEQ_ADJUST_BIT, &ct->status)
+	    && !nf_ct_seq_adjust(skb, ct, ctinfo, protoff))
+		return NF_DROP;
+#endif
+	return NF_ACCEPT;
 }
 
 /* Returns 0 on success, -EINPROGRESS if 'skb' is stolen, or other nonzero
@@ -455,6 +512,189 @@ static bool skb_nfct_cached(struct net *net,
 	return true;
 }
 
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
+			if (err != NF_ACCEPT)
+				goto push;
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
+	err = nf_nat_packet(ct, ctinfo, hooknum, skb);
+push:
+	skb_push(skb, nh_off);
+
+	return err;
+}
+
+static void ovs_nat_update_key(struct sw_flow_key *key,
+			       const struct sk_buff *skb,
+			       enum nf_nat_manip_type maniptype)
+{
+	if (maniptype == NF_NAT_MANIP_SRC) {
+		__be16 src;
+
+		key->ct.state |= OVS_CS_F_SRC_NAT;
+		if (key->eth.type == htons(ETH_P_IP))
+			key->ipv4.addr.src = ip_hdr(skb)->saddr;
+		else if (key->eth.type == htons(ETH_P_IPV6))
+			memcpy(&key->ipv6.addr.src, &ipv6_hdr(skb)->saddr,
+			       sizeof(key->ipv6.addr.src));
+		else
+			return;
+
+		if (key->ip.proto == IPPROTO_UDP)
+			src = udp_hdr(skb)->source;
+		else if (key->ip.proto == IPPROTO_TCP)
+			src = tcp_hdr(skb)->source;
+		else if (key->ip.proto == IPPROTO_SCTP)
+			src = sctp_hdr(skb)->source;
+		else
+			return;
+
+		key->tp.src = src;
+	} else {
+		__be16 dst;
+
+		key->ct.state |= OVS_CS_F_DST_NAT;
+		if (key->eth.type == htons(ETH_P_IP))
+			key->ipv4.addr.dst = ip_hdr(skb)->daddr;
+		else if (key->eth.type == htons(ETH_P_IPV6))
+			memcpy(&key->ipv6.addr.dst, &ipv6_hdr(skb)->daddr,
+			       sizeof(key->ipv6.addr.dst));
+		else
+			return;
+
+		if (key->ip.proto == IPPROTO_UDP)
+			dst = udp_hdr(skb)->dest;
+		else if (key->ip.proto == IPPROTO_TCP)
+			dst = tcp_hdr(skb)->dest;
+		else if (key->ip.proto == IPPROTO_SCTP)
+			dst = sctp_hdr(skb)->dest;
+		else
+			return;
+
+		key->tp.dst = dst;
+	}
+}
+
+/* Returns NF_DROP if the packet should be dropped, NF_ACCEPT otherwise. */
+static int ovs_ct_nat(struct net *net, struct sw_flow_key *key,
+		      const struct ovs_conntrack_info *info,
+		      struct sk_buff *skb, struct nf_conn *ct,
+		      enum ip_conntrack_info ctinfo)
+{
+	enum nf_nat_manip_type maniptype;
+	int err;
+
+	if (nf_ct_is_untracked(ct)) {
+		/* A NAT action may only be performed on tracked packets. */
+		return NF_ACCEPT;
+	}
+
+	/* Add NAT extension if not confirmed yet. */
+	if (!nf_ct_is_confirmed(ct) && !nf_ct_nat_ext_add(ct))
+		return NF_ACCEPT;   /* Can't NAT. */
+
+	/* Determine NAT type.
+	 * Check if the NAT type can be deduced from the tracked connection.
+	 * Make sure expected traffic is NATted only when commiting.
+	 */
+	if (info->nat & OVS_CT_NAT && ctinfo != IP_CT_NEW
+	    && ct->status & IPS_NAT_MASK
+	    && (!(ct->status & IPS_EXPECTED_BIT) || info->commit)) {
+		/* NAT an established or related connection like before. */
+		if (CTINFO2DIR(ctinfo) == IP_CT_DIR_REPLY)
+			/* This is the REPLY direction for a connection
+			 * for which NAT was applied in the forward
+			 * direction.  Do the reverse NAT.
+			 */
+			maniptype = ct->status & IPS_SRC_NAT
+				? NF_NAT_MANIP_DST : NF_NAT_MANIP_SRC;
+		else
+			maniptype = ct->status & IPS_SRC_NAT
+				? NF_NAT_MANIP_SRC : NF_NAT_MANIP_DST;
+	}
+	else if (info->nat & OVS_CT_SRC_NAT)
+		maniptype = NF_NAT_MANIP_SRC;
+	else if (info->nat & OVS_CT_DST_NAT)
+		maniptype = NF_NAT_MANIP_DST;
+	else
+		return NF_ACCEPT; /* Connection is not NATed. */
+
+	err = ovs_ct_nat_execute(skb, ct, ctinfo, &info->range, maniptype);
+
+	/* Mark NAT done if successful and update the flow key. */
+	if (err == NF_ACCEPT)
+		ovs_nat_update_key(key, skb, maniptype);
+
+	return err;
+}
+#endif
+
 /* Pass 'skb' through conntrack in 'net', using zone configured in 'info', if
  * not done already.  Update key with new CT state after passing the packet
  * through conntrack.
@@ -495,17 +735,45 @@ static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
 		if (err != NF_ACCEPT)
 			return -ENOENT;
 
-		ovs_ct_update_key(skb, key, true);
+		/* Clear CT state NAT flags to mark that we have not yet done
+		 * NAT after the nf_conntrack_in() call.  We can actually clear
+		 * the whole state, as it will be re-initialized below.
+		 */
+		key->ct.state = 0;
+
+		/* Update the key, but keep the NAT flags. */
+		ovs_ct_update_key(skb, key, true, true);
 	}
 
-	/* Call the helper right after nf_conntrack_in() for confirmed
-	 * connections, but only when commiting for unconfirmed connections.
-	 */
 	ct = nf_ct_get(skb, &ctinfo);
-	if (ct && (nf_ct_is_confirmed(ct) ? !cached : info->commit)
-	    && ovs_ct_helper(skb, info->family) != NF_ACCEPT) {
-		WARN_ONCE(1, "helper rejected packet");
-		return -EINVAL;
+	if (ct) {
+#ifdef CONFIG_NF_NAT_NEEDED
+		/* Packets starting a new connection must be NATted before the
+		 * helper, so that the helper knows about the NAT.  We enforce
+		 * this by delaying both NAT and helper calls for unconfirmed
+		 * connections until the commiting CT action.  For later
+		 * packets NAT and Helper may be called in either order.
+		 *
+		 * NAT will be done only if the CT action has NAT, and only
+		 * once per packet (per zone), as guarded by the NAT bits in
+		 * the key->ct.state.
+		 */
+		if (info->nat && !(key->ct.state & OVS_CS_F_NAT_MASK) &&
+		    (nf_ct_is_confirmed(ct) || info->commit) &&
+		    ovs_ct_nat(net, key, info, skb, ct, ctinfo) != NF_ACCEPT) {
+			WARN_ONCE(1, "NAT rejected packet");
+			return -EINVAL;
+		}
+#endif
+		/* Call the helper whenever nf_conntrack_in() was called for
+		 * confirmed connections, but only when commiting for
+		 * unconfirmed connections.
+		 */
+		if ((nf_ct_is_confirmed(ct) ? !cached : info->commit)
+		    && ovs_ct_helper(skb, info->family) != NF_ACCEPT) {
+			WARN_ONCE(1, "helper rejected packet");
+			return -EINVAL;
+		}
 	}
 
 	return 0;
@@ -529,15 +797,13 @@ static int ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
 	if (exp) {
 		u8 state;
 
+		/* NOTE: New connections are NATted and Helped only when
+		 * commited, so we are not calling into NAT here.
+		 */
 		state = OVS_CS_F_TRACKED | OVS_CS_F_NEW | OVS_CS_F_RELATED;
 		__ovs_ct_update_key(key, state, &info->zone, exp->master);
-	} else {
-		int err;
-
-		err = __ovs_ct_lookup(net, key, info, skb);
-		if (err)
-			return err;
-	}
+	} else
+		return __ovs_ct_lookup(net, key, info, skb);
 
 	return 0;
 }
@@ -637,6 +903,131 @@ static int ovs_ct_add_helper(struct ovs_conntrack_info *info, const char *name,
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
+			if (info->nat) {
+				OVS_NLERR(log, "Only one type of NAT may be "
+					  "specified.\n");
+				return -ERANGE;
+			}
+			info->nat |= OVS_CT_NAT;
+			info->nat |= ((type == OVS_NAT_ATTR_SRC)
+					? OVS_CT_SRC_NAT : OVS_CT_DST_NAT);
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
+			info->range.min_proto.all = htons(nla_get_u16(a));
+			info->range.flags |= NF_NAT_RANGE_PROTO_SPECIFIED;
+			break;
+
+		case OVS_NAT_ATTR_PROTO_MAX:
+			have_proto_max = true;
+			info->range.max_proto.all = htons(nla_get_u16(a));
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
+	if (!info->nat) {
+		/* Do not allow flags if no type is given. */
+		if (info->range.flags) {
+			OVS_NLERR(log, "NAT flags may be given only when NAT "
+				  "range (SRC or DST) is also specified.\n");
+			return -EINVAL;
+		}
+		info->nat = OVS_CT_NAT;   /* NAT existing connections. */
+	} else if (!info->commit) {
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
 	[OVS_CT_ATTR_COMMIT]	= { .minlen = 0, .maxlen = 0 },
 	[OVS_CT_ATTR_ZONE]	= { .minlen = sizeof(u16),
@@ -646,7 +1037,11 @@ static const struct ovs_ct_len_tbl ovs_ct_attr_lens[OVS_CT_ATTR_MAX + 1] = {
 	[OVS_CT_ATTR_LABELS]	= { .minlen = sizeof(struct md_labels),
 				    .maxlen = sizeof(struct md_labels) },
 	[OVS_CT_ATTR_HELPER]	= { .minlen = 1,
-				    .maxlen = NF_CT_HELPER_NAME_LEN }
+				    .maxlen = NF_CT_HELPER_NAME_LEN },
+#ifdef CONFIG_NF_NAT_NEEDED
+	/* NAT length is checked when parsing the nested attributes. */
+	[OVS_CT_ATTR_NAT]	= { .minlen = 0, .maxlen = SIZE_MAX },
+#endif
 };
 
 static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
@@ -657,8 +1052,8 @@ static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
 
 	nla_for_each_nested(a, attr, rem) {
 		int type = nla_type(a);
-		int maxlen = ovs_ct_attr_lens[type].maxlen;
-		int minlen = ovs_ct_attr_lens[type].minlen;
+		size_t maxlen = ovs_ct_attr_lens[type].maxlen;
+		size_t minlen = ovs_ct_attr_lens[type].minlen;
 
 		if (type > OVS_CT_ATTR_MAX) {
 			OVS_NLERR(log,
@@ -668,7 +1063,7 @@ static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
 		}
 		if (nla_len(a) < minlen || nla_len(a) > maxlen) {
 			OVS_NLERR(log,
-				  "Conntrack attr type has unexpected length (type=%d, length=%d, expected=%d)",
+				  "Conntrack attr type has unexpected length (type=%d, length=%d, expected=%lu)",
 				  type, nla_len(a), maxlen);
 			return -EINVAL;
 		}
@@ -713,6 +1108,14 @@ static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
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
@@ -798,6 +1201,70 @@ err_free_ct:
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
+	if (info->nat & OVS_CT_SRC_NAT) {
+		if (nla_put_flag(skb, OVS_NAT_ATTR_SRC))
+			return false;
+	} else if (info->nat & OVS_CT_DST_NAT) {
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
+		} else if (info->family == NFPROTO_IPV6) {
+			if (nla_put_in6_addr(skb, OVS_NAT_ATTR_IP_MIN,
+					     &info->range.min_addr.in6) ||
+			    (memcmp(&info->range.max_addr.in6,
+				    &info->range.min_addr.in6,
+				    sizeof info->range.max_addr.in6)
+			     && (nla_put_in6_addr(skb, OVS_NAT_ATTR_IP_MAX,
+						  &info->range.max_addr.in6))))
+				return false;
+		} else
+			return false;
+	}
+	if (info->range.flags & NF_NAT_RANGE_PROTO_SPECIFIED &&
+	    (nla_put_u16(skb, OVS_NAT_ATTR_PROTO_MIN,
+			 ntohs(info->range.min_proto.all))
+	     || (info->range.max_proto.all != info->range.min_proto.all
+		 && nla_put_u16(skb, OVS_NAT_ATTR_PROTO_MAX,
+				ntohs(info->range.max_proto.all)))))
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
@@ -826,7 +1293,10 @@ int ovs_ct_action_to_attr(const struct ovs_conntrack_info *ct_info,
 				   ct_info->helper->name))
 			return -EMSGSIZE;
 	}
-
+#ifdef CONFIG_NF_NAT_NEEDED
+	if (ct_info->nat && !ovs_ct_nat_to_attr(ct_info, skb))
+		return -EMSGSIZE;
+#endif
 	nla_nest_end(skb, start);
 
 	return 0;
diff --git a/net/openvswitch/conntrack.h b/net/openvswitch/conntrack.h
index a7544f4..8f6230b 100644
--- a/net/openvswitch/conntrack.h
+++ b/net/openvswitch/conntrack.h
@@ -37,7 +37,8 @@ void ovs_ct_free_action(const struct nlattr *a);
 
 #define CT_SUPPORTED_MASK (OVS_CS_F_NEW | OVS_CS_F_ESTABLISHED | \
 			   OVS_CS_F_RELATED | OVS_CS_F_REPLY_DIR | \
-			   OVS_CS_F_INVALID | OVS_CS_F_TRACKED)
+			   OVS_CS_F_INVALID | OVS_CS_F_TRACKED | \
+			   OVS_CS_F_SRC_NAT | OVS_CS_F_DST_NAT)
 #else
 #include <linux/errno.h>
 
-- 
2.1.4
