From: Yi Yang <yi.y.yang@intel.com>
Subject: [PATCH net-next v5] openvswitch: enable NSH support
Date: Mon, 21 Aug 2017 13:54:23 +0800
Message-ID: <1503294863-12859-1-git-send-email-yi.y.yang@intel.com>
Cc: dev@openvswitch.org, blp@ovn.org, jbenc@redhat.com, e@erig.me,
        jan.scheurich@ericsson.com, Yi Yang <yi.y.yang@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:25008 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750985AbdHUF6L (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 01:58:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v4->v5
 - Fix many comments by Jiri Benc and Eric Garver
   for v4.

v3->v4
 - Add new NSH match field ttl
 - Update NSH header to the latest format
   which will be final format and won't change
   per its author's confirmation.
 - Fix comments for v3.

v2->v3
 - Change OVS_KEY_ATTR_NSH to nested key to handle
   length-fixed attributes and length-variable
   attriubte more flexibly.
 - Remove struct ovs_action_push_nsh completely
 - Add code to handle nested attribute for SET_MASKED
 - Change PUSH_NSH to use the nested OVS_KEY_ATTR_NSH
   to transfer NSH header data.
 - Fix comments and coding style issues by Jiri and Eric

v1->v2
 - Change encap_nsh and decap_nsh to push_nsh and pop_nsh
 - Dynamically allocate struct ovs_action_push_nsh for
   length-variable metadata.

OVS master and 2.8 branch has merged NSH userspace
patch series, this patch is to enable NSH support
in kernel data path in order that OVS can support
NSH in 2.8 release in compat mode by porting this.

Signed-off-by: Yi Yang <yi.y.yang@intel.com>
---
 drivers/net/vxlan.c              |   7 +
 include/net/nsh.h                | 307 +++++++++++++++++++++++++++++
 include/uapi/linux/if_ether.h    |   1 +
 include/uapi/linux/openvswitch.h |  28 +++
 net/openvswitch/actions.c        | 181 ++++++++++++++++++
 net/openvswitch/flow.c           |  50 +++++
 net/openvswitch/flow.h           |  11 ++
 net/openvswitch/flow_netlink.c   | 404 ++++++++++++++++++++++++++++++++++++++-
 net/openvswitch/flow_netlink.h   |   4 +
 9 files changed, 992 insertions(+), 1 deletion(-)
 create mode 100644 include/net/nsh.h

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index ae3a1da..a36c41e 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -27,6 +27,7 @@
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 #include <net/vxlan.h>
+#include <net/nsh.h>
 
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ip6_tunnel.h>
@@ -1268,6 +1269,9 @@ static bool vxlan_parse_gpe_hdr(struct vxlanhdr *unparsed,
 	case VXLAN_GPE_NP_IPV6:
 		*protocol = htons(ETH_P_IPV6);
 		break;
+	case VXLAN_GPE_NP_NSH:
+		*protocol = htons(ETH_P_NSH);
+		break;
 	case VXLAN_GPE_NP_ETHERNET:
 		*protocol = htons(ETH_P_TEB);
 		break;
@@ -1807,6 +1811,9 @@ static int vxlan_build_gpe_hdr(struct vxlanhdr *vxh, u32 vxflags,
 	case htons(ETH_P_IPV6):
 		gpe->next_protocol = VXLAN_GPE_NP_IPV6;
 		return 0;
+	case htons(ETH_P_NSH):
+		gpe->next_protocol = VXLAN_GPE_NP_NSH;
+		return 0;
 	case htons(ETH_P_TEB):
 		gpe->next_protocol = VXLAN_GPE_NP_ETHERNET;
 		return 0;
diff --git a/include/net/nsh.h b/include/net/nsh.h
new file mode 100644
index 0000000..df5812e
--- /dev/null
+++ b/include/net/nsh.h
@@ -0,0 +1,307 @@
+#ifndef __NET_NSH_H
+#define __NET_NSH_H 1
+
+/*
+ * Network Service Header:
+ *  0                   1                   2                   3
+ *  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |Ver|O|U|    TTL    |   Length  |U|U|U|U|MD Type| Next Protocol |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |          Service Path Identifier (SPI)        | Service Index |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |                                                               |
+ * ~               Mandatory/Optional Context Headers              ~
+ * |                                                               |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *
+ * Version: The version field is used to ensure backward compatibility
+ * going forward with future NSH specification updates.  It MUST be set
+ * to 0x0 by the sender, in this first revision of NSH.  Given the
+ * widespread implementation of existing hardware that uses the first
+ * nibble after an MPLS label stack for ECMP decision processing, this
+ * document reserves version 01b and this value MUST NOT be used in
+ * future versions of the protocol.  Please see [RFC7325] for further
+ * discussion of MPLS-related forwarding requirements.
+ *
+ * O bit: Setting this bit indicates an Operations, Administration, and
+ * Maintenance (OAM) packet.  The actual format and processing of SFC
+ * OAM packets is outside the scope of this specification (see for
+ * example [I-D.ietf-sfc-oam-framework] for one approach).
+ *
+ * The O bit MUST be set for OAM packets and MUST NOT be set for non-OAM
+ * packets.  The O bit MUST NOT be modified along the SFP.
+ *
+ * SF/SFF/SFC Proxy/Classifier implementations that do not support SFC
+ * OAM procedures SHOULD discard packets with O bit set, but MAY support
+ * a configurable parameter to enable forwarding received SFC OAM
+ * packets unmodified to the next element in the chain.  Forwarding OAM
+ * packets unmodified by SFC elements that do not support SFC OAM
+ * procedures may be acceptable for a subset of OAM functions, but can
+ * result in unexpected outcomes for others, thus it is recommended to
+ * analyze the impact of forwarding an OAM packet for all OAM functions
+ * prior to enabling this behavior.  The configurable parameter MUST be
+ * disabled by default.
+ *
+ * TTL: Indicates the maximum SFF hops for an SFP.  This field is used
+ * for service plane loop detection.  The initial TTL value SHOULD be
+ * configurable via the control plane; the configured initial value can
+ * be specific to one or more SFPs.  If no initial value is explicitly
+ * provided, the default initial TTL value of 63 MUST be used.  Each SFF
+ * involved in forwarding an NSH packet MUST decrement the TTL value by
+ * 1 prior to NSH forwarding lookup.  Decrementing by 1 from an incoming
+ * value of 0 shall result in a TTL value of 63.  The packet MUST NOT be
+ * forwarded if TTL is, after decrement, 0.
+ *
+ * All other flag fields, marked U, are unassigned and available for
+ * future use, see Section 11.2.1.  Unassigned bits MUST be set to zero
+ * upon origination, and MUST be ignored and preserved unmodified by
+ * other NSH supporting elements.  Elements which do not understand the
+ * meaning of any of these bits MUST NOT modify their actions based on
+ * those unknown bits.
+ *
+ * Length: The total length, in 4-byte words, of NSH including the Base
+ * Header, the Service Path Header, the Fixed Length Context Header or
+ * Variable Length Context Header(s).  The length MUST be 0x6 for MD
+ * Type equal to 0x1, and MUST be 0x2 or greater for MD Type equal to
+ * 0x2.  The length of the NSH header MUST be an integer multiple of 4
+ * bytes, thus variable length metadata is always padded out to a
+ * multiple of 4 bytes.
+ *
+ * MD Type: Indicates the format of NSH beyond the mandatory Base Header
+ * and the Service Path Header.  MD Type defines the format of the
+ * metadata being carried.
+ *
+ * 0x0 - This is a reserved value.  Implementations SHOULD silently
+ * discard packets with MD Type 0x0.
+ *
+ * 0x1 - This indicates that the format of the header includes a fixed
+ * length Context Header (see Figure 4 below).
+ *
+ * 0x2 - This does not mandate any headers beyond the Base Header and
+ * Service Path Header, but may contain optional variable length Context
+ * Header(s).  The semantics of the variable length Context Header(s)
+ * are not defined in this document.  The format of the optional
+ * variable length Context Headers is provided in Section 2.5.1.
+ *
+ * 0xF - This value is reserved for experimentation and testing, as per
+ * [RFC3692].  Implementations not explicitly configured to be part of
+ * an experiment SHOULD silently discard packets with MD Type 0xF.
+ *
+ * Next Protocol: indicates the protocol type of the encapsulated data.
+ * NSH does not alter the inner payload, and the semantics on the inner
+ * protocol remain unchanged due to NSH service function chaining.
+ * Please see the IANA Considerations section below, Section 11.2.5.
+ *
+ * This document defines the following Next Protocol values:
+ *
+ * 0x1: IPv4
+ * 0x2: IPv6
+ * 0x3: Ethernet
+ * 0x4: NSH
+ * 0x5: MPLS
+ * 0xFE: Experiment 1
+ * 0xFF: Experiment 2
+ *
+ * Packets with Next Protocol values not supported SHOULD be silently
+ * dropped by default, although an implementation MAY provide a
+ * configuration parameter to forward them.  Additionally, an
+ * implementation not explicitly configured for a specific experiment
+ * [RFC3692] SHOULD silently drop packets with Next Protocol values 0xFE
+ * and 0xFF.
+ *
+ * Service Path Identifier (SPI): Identifies a service path.
+ * Participating nodes MUST use this identifier for Service Function
+ * Path selection.  The initial classifier MUST set the appropriate SPI
+ * for a given classification result.
+ *
+ * Service Index (SI): Provides location within the SFP.  The initial
+ * classifier for a given SFP SHOULD set the SI to 255, however the
+ * control plane MAY configure the initial value of SI as appropriate
+ * (i.e., taking into account the length of the service function path).
+ * The Service Index MUST be decremented by a value of 1 by Service
+ * Functions or by SFC Proxy nodes after performing required services
+ * and the new decremented SI value MUST be used in the egress packet's
+ * NSH.  The initial Classifier MUST send the packet to the first SFF in
+ * the identified SFP for forwarding along an SFP.  If re-classification
+ * occurs, and that re-classification results in a new SPI, the
+ * (re)classifier is, in effect, the initial classifier for the
+ * resultant SPI.
+ *
+ * The SI is used in conjunction the with Service Path Identifier for
+ * Service Function Path Selection and for determining the next SFF/SF
+ * in the path.  The SI is also valuable when troubleshooting or
+ * reporting service paths.  Additionally, while the TTL field is the
+ * main mechanism for service plane loop detection, the SI can also be
+ * used for detecting service plane loops.
+ *
+ * When the Base Header specifies MD Type = 0x1, a Fixed Length Context
+ * Header (16-bytes) MUST be present immediately following the Service
+ * Path Header. The value of a Fixed Length Context
+ * Header that carries no metadata MUST be set to zero.
+ *
+ * When the base header specifies MD Type = 0x2, zero or more Variable
+ * Length Context Headers MAY be added, immediately following the
+ * Service Path Header (see Figure 5).  Therefore, Length = 0x2,
+ * indicates that only the Base Header followed by the Service Path
+ * Header are present.  The optional Variable Length Context Headers
+ * MUST be of an integer number of 4-bytes.  The base header Length
+ * field MUST be used to determine the offset to locate the original
+ * packet or frame for SFC nodes that require access to that
+ * information.
+ *
+ * The format of the optional variable length Context Headers
+ *
+ *  0                   1                   2                   3
+ *  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |          Metadata Class       |      Type     |U|    Length   |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |                      Variable Metadata                        |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *
+ * Metadata Class (MD Class): Defines the scope of the 'Type' field to
+ * provide a hierarchical namespace.  The IANA Considerations
+ * Section 11.2.4 defines how the MD Class values can be allocated to
+ * standards bodies, vendors, and others.
+ *
+ * Type: Indicates the explicit type of metadata being carried.  The
+ * definition of the Type is the responsibility of the MD Class owner.
+ *
+ * Unassigned bit: One unassigned bit is available for future use. This
+ * bit MUST NOT be set, and MUST be ignored on receipt.
+ *
+ * Length: Indicates the length of the variable metadata, in bytes.  In
+ * case the metadata length is not an integer number of 4-byte words,
+ * the sender MUST add pad bytes immediately following the last metadata
+ * byte to extend the metadata to an integer number of 4-byte words.
+ * The receiver MUST round up the length field to the nearest 4-byte
+ * word boundary, to locate and process the next field in the packet.
+ * The receiver MUST access only those bytes in the metadata indicated
+ * by the length field (i.e., actual number of bytes) and MUST ignore
+ * the remaining bytes up to the nearest 4-byte word boundary.  The
+ * Length may be 0 or greater.
+ *
+ * A value of 0 denotes a Context Header without a Variable Metadata
+ * field.
+ *
+ * [0] https://datatracker.ietf.org/doc/draft-ietf-sfc-nsh/
+ */
+
+/**
+ * struct nsh_md1_ctx - Keeps track of NSH context data
+ * @nshc<1-4>: NSH Contexts.
+ */
+struct nsh_md1_ctx {
+	__be32 context[4];
+};
+
+struct nsh_md2_tlv {
+	__be16 md_class;
+	u8 type;
+	u8 length;
+	/* Followed by variable-length data. */
+};
+
+struct nsh_hdr {
+	__be16 ver_flags_ttl_len;
+	u8 md_type;
+	u8 next_proto;
+	__be32 path_hdr;
+	union {
+	    struct nsh_md1_ctx md1;
+	    struct nsh_md2_tlv md2;
+	};
+};
+
+/* Masking NSH header fields. */
+#define NSH_VER_MASK       0xc000
+#define NSH_VER_SHIFT      14
+#define NSH_FLAGS_MASK     0x3000
+#define NSH_FLAGS_SHIFT    12
+#define NSH_TTL_MASK       0x0fc0
+#define NSH_TTL_SHIFT      6
+#define NSH_LEN_MASK       0x003f
+#define NSH_LEN_SHIFT      0
+
+#define NSH_MDTYPE_MASK    0x0f
+#define NSH_MDTYPE_SHIFT   0
+
+#define NSH_SPI_MASK       0xffffff00
+#define NSH_SPI_SHIFT      8
+#define NSH_SI_MASK        0x000000ff
+#define NSH_SI_SHIFT       0
+
+/* NSH Base Header Next Protocol. */
+#define NSH_P_IPV4        0x01
+#define NSH_P_IPV6        0x02
+#define NSH_P_ETHERNET    0x03
+#define NSH_P_NSH         0x04
+#define NSH_P_MPLS        0x05
+
+/* MD Type Registry. */
+#define NSH_M_TYPE1     0x01
+#define NSH_M_TYPE2     0x02
+#define NSH_M_EXP1      0xFE
+#define NSH_M_EXP2      0xFF
+
+/* NSH Base Header Length */
+#define NSH_BASE_HDR_LEN  8
+
+/* NSH MD Type 1 header Length. */
+#define NSH_M_TYPE1_LEN   24
+
+/* NSH MD Type 2 header maximum Length. */
+#define NSH_M_TYPE2_MAX_LEN 256
+
+/* NSH MD Type 2 Metadata maximum Length. */
+#define NSH_M_TYPE2_MD_MAX_LEN (NSH_M_TYPE2_MAX_LEN - NSH_BASE_HDR_LEN)
+
+static inline u16 nsh_hdr_len(const struct nsh_hdr *nsh)
+{
+	return ((ntohs(nsh->ver_flags_ttl_len) & NSH_LEN_MASK)
+		>> NSH_LEN_SHIFT) << 2;
+}
+
+static inline u8 nsh_get_ver(const struct nsh_hdr *nsh)
+{
+	return (ntohs(nsh->ver_flags_ttl_len) & NSH_VER_MASK)
+		>> NSH_VER_SHIFT;
+}
+
+static inline u8 nsh_get_flags(const struct nsh_hdr *nsh)
+{
+	return (ntohs(nsh->ver_flags_ttl_len) & NSH_FLAGS_MASK)
+		>> NSH_FLAGS_SHIFT;
+}
+
+static inline u8 nsh_get_ttl(const struct nsh_hdr *nsh)
+{
+	return (ntohs(nsh->ver_flags_ttl_len) & NSH_TTL_MASK)
+		>> NSH_TTL_SHIFT;
+}
+
+static inline void __nsh_set_xflag(struct nsh_hdr *nsh, u16 xflag, u16 xmask)
+{
+	nsh->ver_flags_ttl_len
+		= (nsh->ver_flags_ttl_len & ~htons(xmask)) | htons(xflag);
+}
+
+static inline void nsh_set_flags_and_ttl(struct nsh_hdr *nsh, u8 flags, u8 ttl)
+{
+	__nsh_set_xflag(nsh, ((flags << NSH_FLAGS_SHIFT) & NSH_FLAGS_MASK) |
+			     ((ttl << NSH_TTL_SHIFT) & NSH_TTL_MASK),
+			NSH_FLAGS_MASK | NSH_TTL_MASK);
+}
+
+static inline void nsh_set_flags_ttl_len(struct nsh_hdr *nsh, u8 flags,
+					 u8 ttl, u8 len)
+{
+	len = len >> 2;
+	__nsh_set_xflag(nsh, ((flags << NSH_FLAGS_SHIFT) & NSH_FLAGS_MASK) |
+			     ((ttl << NSH_TTL_SHIFT) & NSH_TTL_MASK) |
+			     ((len << NSH_LEN_SHIFT) & NSH_LEN_MASK),
+			NSH_FLAGS_MASK | NSH_TTL_MASK | NSH_LEN_MASK);
+}
+
+#endif /* __NET_NSH_H */
diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
index 5bc9bfd..e7f1a61 100644
--- a/include/uapi/linux/if_ether.h
+++ b/include/uapi/linux/if_ether.h
@@ -137,6 +137,7 @@
 #define ETH_P_IEEE802154 0x00F6		/* IEEE802.15.4 frame		*/
 #define ETH_P_CAIF	0x00F7		/* ST-Ericsson CAIF protocol	*/
 #define ETH_P_XDSA	0x00F8		/* Multiplexed DSA protocol	*/
+#define ETH_P_NSH	0x894F		/* Ethertype for NSH. */
 
 /*
  *	This is an Ethernet frame header.
diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 156ee4c..91dee5b 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -333,6 +333,7 @@ enum ovs_key_attr {
 	OVS_KEY_ATTR_CT_LABELS,	/* 16-octet connection tracking label */
 	OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV4,   /* struct ovs_key_ct_tuple_ipv4 */
 	OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV6,   /* struct ovs_key_ct_tuple_ipv6 */
+	OVS_KEY_ATTR_NSH,       /* Nested set of ovs_nsh_key_* */
 
 #ifdef __KERNEL__
 	OVS_KEY_ATTR_TUNNEL_INFO,  /* struct ip_tunnel_info */
@@ -491,6 +492,29 @@ struct ovs_key_ct_tuple_ipv6 {
 	__u8   ipv6_proto;
 };
 
+enum ovs_nsh_key_attr {
+	OVS_NSH_KEY_ATTR_BASE,  /* struct ovs_nsh_key_base. */
+	OVS_NSH_KEY_ATTR_MD1,   /* struct ovs_nsh_key_md1. */
+	OVS_NSH_KEY_ATTR_MD2,   /* variable-length octets for MD type 2. */
+	__OVS_NSH_KEY_ATTR_MAX
+};
+
+#define OVS_NSH_KEY_ATTR_MAX (__OVS_NSH_KEY_ATTR_MAX - 1)
+
+struct ovs_nsh_key_base {
+	__u8 flags;
+	__u8 ttl;
+	__u8 mdtype;
+	__u8 np;
+	__be32 path_hdr;
+};
+
+#define NSH_MD1_CONTEXT_SIZE 4
+
+struct ovs_nsh_key_md1 {
+	__be32 context[NSH_MD1_CONTEXT_SIZE];
+};
+
 /**
  * enum ovs_flow_attr - attributes for %OVS_FLOW_* commands.
  * @OVS_FLOW_ATTR_KEY: Nested %OVS_KEY_ATTR_* attributes specifying the flow
@@ -806,6 +830,8 @@ struct ovs_action_push_eth {
  * packet.
  * @OVS_ACTION_ATTR_POP_ETH: Pop the outermost Ethernet header off the
  * packet.
+ * @OVS_ACTION_ATTR_PUSH_NSH: push NSH header to the packet.
+ * @OVS_ACTION_ATTR_POP_NSH: pop the outermost NSH header off the packet.
  *
  * Only a single header can be set with a single %OVS_ACTION_ATTR_SET.  Not all
  * fields within a header are modifiable, e.g. the IPv4 protocol and fragment
@@ -835,6 +861,8 @@ enum ovs_action_attr {
 	OVS_ACTION_ATTR_TRUNC,        /* u32 struct ovs_action_trunc. */
 	OVS_ACTION_ATTR_PUSH_ETH,     /* struct ovs_action_push_eth. */
 	OVS_ACTION_ATTR_POP_ETH,      /* No argument. */
+	OVS_ACTION_ATTR_PUSH_NSH,     /* Nested OVS_NSH_KEY_ATTR_*. */
+	OVS_ACTION_ATTR_POP_NSH,      /* No argument. */
 
 	__OVS_ACTION_ATTR_MAX,	      /* Nothing past this will be accepted
 				       * from userspace. */
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index e461067..efdcd37 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -43,6 +43,7 @@
 #include "flow.h"
 #include "conntrack.h"
 #include "vport.h"
+#include "flow_netlink.h"
 
 struct deferred_action {
 	struct sk_buff *skb;
@@ -380,6 +381,98 @@ static int push_eth(struct sk_buff *skb, struct sw_flow_key *key,
 	return 0;
 }
 
+static int push_nsh(struct sk_buff *skb, struct sw_flow_key *key,
+		    const struct nsh_hdr *nsh_src)
+{
+	struct nsh_hdr *nsh;
+	size_t length = nsh_hdr_len(nsh_src);
+	u8 next_proto;
+
+	if (key->mac_proto == MAC_PROTO_ETHERNET) {
+		next_proto = NSH_P_ETHERNET;
+	} else {
+		switch (ntohs(skb->protocol)) {
+		case ETH_P_IP:
+			next_proto = NSH_P_IPV4;
+			break;
+		case ETH_P_IPV6:
+			next_proto = NSH_P_IPV6;
+			break;
+		case ETH_P_NSH:
+			next_proto = NSH_P_NSH;
+			break;
+		default:
+			return -ENOTSUPP;
+		}
+	}
+
+	/* Add the NSH header */
+	if (skb_cow_head(skb, length) < 0)
+		return -ENOMEM;
+
+	skb_push(skb, length);
+	nsh = (struct nsh_hdr *)(skb->data);
+	memcpy(nsh, nsh_src, length);
+	nsh->next_proto = next_proto;
+	nsh->md_type &= NSH_MDTYPE_MASK;
+
+	if (!skb->inner_protocol)
+		skb_set_inner_protocol(skb, skb->protocol);
+
+	skb->protocol = htons(ETH_P_NSH);
+	key->eth.type = htons(ETH_P_NSH);
+	skb_reset_mac_header(skb);
+	skb_reset_mac_len(skb);
+
+	/* safe right before invalidate_flow_key */
+	key->mac_proto = MAC_PROTO_NONE;
+	invalidate_flow_key(key);
+	return 0;
+}
+
+static int pop_nsh(struct sk_buff *skb, struct sw_flow_key *key)
+{
+	struct nsh_hdr *nsh = (struct nsh_hdr *)(skb->data);
+	size_t length;
+	u16 inner_proto;
+
+	if (ovs_key_mac_proto(key) != MAC_PROTO_NONE ||
+	    skb->protocol != htons(ETH_P_NSH)) {
+		return -EINVAL;
+	}
+
+	switch (nsh->next_proto) {
+	case NSH_P_ETHERNET:
+		inner_proto = htons(ETH_P_TEB);
+		break;
+	case NSH_P_IPV4:
+		inner_proto = htons(ETH_P_IP);
+		break;
+	case NSH_P_IPV6:
+		inner_proto = htons(ETH_P_IPV6);
+		break;
+	case NSH_P_NSH:
+		inner_proto = htons(ETH_P_NSH);
+		break;
+	default:
+		return -ENOTSUPP;
+	}
+
+	length = nsh_hdr_len(nsh);
+	skb_pull(skb, length);
+	skb_reset_mac_header(skb);
+	skb_reset_mac_len(skb);
+	skb->protocol = inner_proto;
+
+	/* safe right before invalidate_flow_key */
+	if (inner_proto == htons(ETH_P_TEB))
+		key->mac_proto = MAC_PROTO_ETHERNET;
+	else
+		key->mac_proto = MAC_PROTO_NONE;
+	invalidate_flow_key(key);
+	return 0;
+}
+
 static void update_ip_l4_checksum(struct sk_buff *skb, struct iphdr *nh,
 				  __be32 addr, __be32 new_addr)
 {
@@ -602,6 +695,53 @@ static int set_ipv6(struct sk_buff *skb, struct sw_flow_key *flow_key,
 	return 0;
 }
 
+static int set_nsh(struct sk_buff *skb, struct sw_flow_key *flow_key,
+		   const struct ovs_key_nsh *key,
+		   const struct ovs_key_nsh *mask)
+{
+	struct nsh_hdr *nsh;
+	int err;
+	u8 flags;
+	u8 ttl;
+	int i;
+
+	err = skb_ensure_writable(skb, skb_network_offset(skb) +
+				  sizeof(struct nsh_hdr));
+	if (unlikely(err))
+		return err;
+
+	nsh = (struct nsh_hdr *)skb_network_header(skb);
+
+	flags = nsh_get_flags(nsh);
+	flags = OVS_MASKED(flags, key->flags, mask->flags);
+	flow_key->nsh.flags = flags;
+	ttl = nsh_get_ttl(nsh);
+	ttl = OVS_MASKED(ttl, key->ttl, mask->ttl);
+	flow_key->nsh.ttl = ttl;
+	nsh_set_flags_and_ttl(nsh, flags, ttl);
+	nsh->path_hdr = OVS_MASKED(nsh->path_hdr, key->path_hdr,
+				   mask->path_hdr);
+	flow_key->nsh.path_hdr = nsh->path_hdr;
+	switch (nsh->md_type) {
+	case NSH_M_TYPE1:
+		for (i = 0; i < NSH_MD1_CONTEXT_SIZE; i++) {
+			nsh->md1.context[i] =
+			    OVS_MASKED(nsh->md1.context[i], key->context[i],
+				       mask->context[i]);
+		}
+		memcpy(flow_key->nsh.context, nsh->md1.context,
+		       sizeof(nsh->md1.context));
+		break;
+	case NSH_M_TYPE2:
+		memset(flow_key->nsh.context, 0,
+		       sizeof(flow_key->nsh.context));
+		break;
+	default:
+		return -EINVAL;
+	}
+	return 0;
+}
+
 /* Must follow skb_ensure_writable() since that can move the skb data. */
 static void set_tp_port(struct sk_buff *skb, __be16 *port,
 			__be16 new_port, __sum16 *check)
@@ -1024,6 +1164,32 @@ static int execute_masked_set_action(struct sk_buff *skb,
 				   get_mask(a, struct ovs_key_ethernet *));
 		break;
 
+	case OVS_KEY_ATTR_NSH: {
+		struct ovs_key_nsh nsh;
+		struct ovs_key_nsh nsh_mask;
+		size_t size = nla_len(a) / 2;
+		struct {
+			struct nlattr nla;
+			u8 data[size];
+		} attr, mask;
+
+		attr.nla.nla_type = nla_type(a);
+		attr.nla.nla_len = NLA_HDRLEN + size;
+		memcpy(attr.data, (char *)(a + 1), size);
+
+		mask.nla = attr.nla;
+		memcpy(mask.data, (char *)(a + 1) + size, size);
+
+		err = nsh_key_from_nlattr(&attr.nla, &nsh);
+		if (err)
+			break;
+		err = nsh_key_from_nlattr(&mask.nla, &nsh_mask);
+		if (err)
+			break;
+		err = set_nsh(skb, flow_key, &nsh, &nsh_mask);
+		break;
+	}
+
 	case OVS_KEY_ATTR_IPV4:
 		err = set_ipv4(skb, flow_key, nla_data(a),
 			       get_mask(a, struct ovs_key_ipv4 *));
@@ -1210,6 +1376,21 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 		case OVS_ACTION_ATTR_POP_ETH:
 			err = pop_eth(skb, key);
 			break;
+
+		case OVS_ACTION_ATTR_PUSH_NSH: {
+			u8 buffer[NSH_M_TYPE2_MAX_LEN];
+			struct nsh_hdr *nsh_hdr = (struct nsh_hdr *)buffer;
+			const struct nsh_hdr *nsh_src = nsh_hdr;
+
+			nsh_hdr_from_nlattr(nla_data(a), nsh_hdr,
+					    NSH_M_TYPE2_MAX_LEN);
+			err = push_nsh(skb, key, nsh_src);
+			break;
+		}
+
+		case OVS_ACTION_ATTR_POP_NSH:
+			err = pop_nsh(skb, key);
+			break;
 		}
 
 		if (unlikely(err)) {
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 8c94cef..301bf71 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -46,6 +46,7 @@
 #include <net/ipv6.h>
 #include <net/mpls.h>
 #include <net/ndisc.h>
+#include <net/nsh.h>
 
 #include "conntrack.h"
 #include "datapath.h"
@@ -490,6 +491,51 @@ static int parse_icmpv6(struct sk_buff *skb, struct sw_flow_key *key,
 	return 0;
 }
 
+static int parse_nsh(struct sk_buff *skb, struct sw_flow_key *key)
+{
+	struct nsh_hdr *nsh = (struct nsh_hdr *)skb_network_header(skb);
+	u8 version, length;
+	int err;
+
+	if (unlikely(skb->len < NSH_BASE_HDR_LEN))
+		return -EINVAL;
+
+	version = nsh_get_ver(nsh);
+	length = nsh_hdr_len(nsh);
+
+	if (version != 0)
+		return -EINVAL;
+
+	if (unlikely(skb->len < length))
+		return -EINVAL;
+
+	key->nsh.flags = nsh_get_flags(nsh);
+	key->nsh.ttl = nsh_get_ttl(nsh);
+	key->nsh.mdtype = nsh->md_type;
+	key->nsh.np = nsh->next_proto;
+	key->nsh.path_hdr = nsh->path_hdr;
+	switch (key->nsh.mdtype) {
+	case NSH_M_TYPE1:
+		if (length != NSH_M_TYPE1_LEN)
+			return -EINVAL;
+		memcpy(key->nsh.context, nsh->md1.context,
+		       sizeof(nsh->md1));
+		break;
+	case NSH_M_TYPE2:
+		/* Don't support MD type 2 metedata parsing yet */
+		if (length < NSH_BASE_HDR_LEN)
+			return -EINVAL;
+
+		memset(key->nsh.context, 0,
+		       sizeof(nsh->md1));
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
 /**
  * key_extract - extracts a flow key from an Ethernet frame.
  * @skb: sk_buff that contains the frame, with skb->data pointing to the
@@ -735,6 +781,10 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 				memset(&key->tp, 0, sizeof(key->tp));
 			}
 		}
+	} else if (key->eth.type == htons(ETH_P_NSH)) {
+		error = parse_nsh(skb, key);
+		if (error)
+			return error;
 	}
 	return 0;
 }
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 1875bba..6a3cd9c 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -35,6 +35,7 @@
 #include <net/inet_ecn.h>
 #include <net/ip_tunnels.h>
 #include <net/dst_metadata.h>
+#include <net/nsh.h>
 
 struct sk_buff;
 
@@ -66,6 +67,15 @@ struct vlan_head {
 	(offsetof(struct sw_flow_key, recirc_id) +	\
 	FIELD_SIZEOF(struct sw_flow_key, recirc_id))
 
+struct ovs_key_nsh {
+	u8 flags;
+	u8 ttl;
+	u8 mdtype;
+	u8 np;
+	__be32 path_hdr;
+	__be32 context[NSH_MD1_CONTEXT_SIZE];
+};
+
 struct sw_flow_key {
 	u8 tun_opts[IP_TUNNEL_OPTS_MAX];
 	u8 tun_opts_len;
@@ -144,6 +154,7 @@ struct sw_flow_key {
 			};
 		} ipv6;
 	};
+	struct ovs_key_nsh nsh;         /* network service header */
 	struct {
 		/* Connection tracking fields not packed above. */
 		struct {
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index e8eb427..1cd4785 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -78,9 +78,11 @@ static bool actions_may_change_flow(const struct nlattr *actions)
 		case OVS_ACTION_ATTR_HASH:
 		case OVS_ACTION_ATTR_POP_ETH:
 		case OVS_ACTION_ATTR_POP_MPLS:
+		case OVS_ACTION_ATTR_POP_NSH:
 		case OVS_ACTION_ATTR_POP_VLAN:
 		case OVS_ACTION_ATTR_PUSH_ETH:
 		case OVS_ACTION_ATTR_PUSH_MPLS:
+		case OVS_ACTION_ATTR_PUSH_NSH:
 		case OVS_ACTION_ATTR_PUSH_VLAN:
 		case OVS_ACTION_ATTR_SAMPLE:
 		case OVS_ACTION_ATTR_SET:
@@ -322,12 +324,27 @@ size_t ovs_tun_key_attr_size(void)
 		+ nla_total_size(2);   /* OVS_TUNNEL_KEY_ATTR_TP_DST */
 }
 
+size_t ovs_nsh_key_attr_size(void)
+{
+	/* Whenever adding new OVS_NSH_KEY_ FIELDS, we should consider
+	 * updating this function.
+	 */
+	return  nla_total_size(NSH_BASE_HDR_LEN) /* OVS_NSH_KEY_ATTR_BASE */
+		/* OVS_NSH_KEY_ATTR_MD1 and OVS_NSH_KEY_ATTR_MD2 are
+		 * mutually exclusive, so the bigger one can cover
+		 * the small one.
+		 *
+		 * OVS_NSH_KEY_ATTR_MD2
+		 */
+		+ nla_total_size(NSH_M_TYPE2_MD_MAX_LEN);
+}
+
 size_t ovs_key_attr_size(void)
 {
 	/* Whenever adding new OVS_KEY_ FIELDS, we should consider
 	 * updating this function.
 	 */
-	BUILD_BUG_ON(OVS_KEY_ATTR_TUNNEL_INFO != 28);
+	BUILD_BUG_ON(OVS_KEY_ATTR_TUNNEL_INFO != 29);
 
 	return    nla_total_size(4)   /* OVS_KEY_ATTR_PRIORITY */
 		+ nla_total_size(0)   /* OVS_KEY_ATTR_TUNNEL */
@@ -341,6 +358,8 @@ size_t ovs_key_attr_size(void)
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_CT_MARK */
 		+ nla_total_size(16)  /* OVS_KEY_ATTR_CT_LABELS */
 		+ nla_total_size(40)  /* OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV6 */
+		+ nla_total_size(0)   /* OVS_KEY_ATTR_NSH */
+		  + ovs_nsh_key_attr_size()
 		+ nla_total_size(12)  /* OVS_KEY_ATTR_ETHERNET */
 		+ nla_total_size(2)   /* OVS_KEY_ATTR_ETHERTYPE */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_VLAN */
@@ -373,6 +392,13 @@ static const struct ovs_len_tbl ovs_tunnel_key_lens[OVS_TUNNEL_KEY_ATTR_MAX + 1]
 	[OVS_TUNNEL_KEY_ATTR_IPV6_DST]      = { .len = sizeof(struct in6_addr) },
 };
 
+static const struct ovs_len_tbl
+ovs_nsh_key_attr_lens[OVS_NSH_KEY_ATTR_MAX + 1] = {
+	[OVS_NSH_KEY_ATTR_BASE]     = { .len = 8 },
+	[OVS_NSH_KEY_ATTR_MD1]      = { .len = 16 },
+	[OVS_NSH_KEY_ATTR_MD2]      = { .len = OVS_ATTR_VARIABLE },
+};
+
 /* The size of the argument for each %OVS_KEY_ATTR_* Netlink attribute.  */
 static const struct ovs_len_tbl ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
 	[OVS_KEY_ATTR_ENCAP]	 = { .len = OVS_ATTR_NESTED },
@@ -405,6 +431,8 @@ static const struct ovs_len_tbl ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
 		.len = sizeof(struct ovs_key_ct_tuple_ipv4) },
 	[OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV6] = {
 		.len = sizeof(struct ovs_key_ct_tuple_ipv6) },
+	[OVS_KEY_ATTR_NSH]       = { .len = OVS_ATTR_NESTED,
+				     .next = ovs_nsh_key_attr_lens, },
 };
 
 static bool check_attr_len(unsigned int attr_len, unsigned int expected_len)
@@ -1179,6 +1207,303 @@ static int metadata_from_nlattrs(struct net *net, struct sw_flow_match *match,
 	return 0;
 }
 
+int nsh_hdr_from_nlattr(const struct nlattr *attr,
+			struct nsh_hdr *nsh, size_t size)
+{
+	struct nlattr *a;
+	int rem;
+	u8 flags = 0;
+	u8 ttl = 0;
+	int mdlen = 0;
+	bool has_md1 = false;
+	bool has_md2 = false;
+	u8 len;
+
+	nla_for_each_nested(a, attr, rem) {
+		int type = nla_type(a);
+
+		if (type > OVS_NSH_KEY_ATTR_MAX) {
+			OVS_NLERR(1, "nsh attr %d is out of range max %d",
+				  type, OVS_NSH_KEY_ATTR_MAX);
+			return -EINVAL;
+		}
+
+		if (!check_attr_len(nla_len(a),
+				    ovs_nsh_key_attr_lens[type].len)) {
+			OVS_NLERR(
+			    1,
+			    "nsh attr %d has unexpected len %d expected %d",
+			    type,
+			    nla_len(a),
+			    ovs_nsh_key_attr_lens[type].len
+			);
+			return -EINVAL;
+		}
+
+		switch (type) {
+		case OVS_NSH_KEY_ATTR_BASE: {
+			const struct ovs_nsh_key_base *base =
+				(struct ovs_nsh_key_base *)nla_data(a);
+			flags = base->flags;
+			ttl = base->ttl;
+			nsh->next_proto = base->np;
+			nsh->md_type = base->mdtype;
+			nsh->path_hdr = base->path_hdr;
+			break;
+		}
+		case OVS_NSH_KEY_ATTR_MD1: {
+			const struct ovs_nsh_key_md1 *md1 =
+				(struct ovs_nsh_key_md1 *)nla_data(a);
+			struct nsh_md1_ctx *md1_dst = &nsh->md1;
+
+			has_md1 = true;
+			mdlen = nla_len(a);
+			if (((mdlen + NSH_BASE_HDR_LEN) != NSH_M_TYPE1_LEN) ||
+			    ((mdlen + NSH_BASE_HDR_LEN) > size) ||
+			    (mdlen <= 0)) {
+				OVS_NLERR(
+				    1,
+				    "length %d of nsh attr %d is invalid",
+				    mdlen,
+				    type
+				);
+				return -EINVAL;
+			}
+			memcpy(md1_dst, md1, mdlen);
+			break;
+		}
+		case OVS_NSH_KEY_ATTR_MD2: {
+			const struct u8 *md2 = nla_data(a);
+			struct nsh_md2_tlv *md2_dst = &nsh->md2;
+
+			has_md2 = true;
+			mdlen = nla_len(a);
+			if (((mdlen + NSH_BASE_HDR_LEN) > size) ||
+			    (mdlen <= 0)) {
+				OVS_NLERR(
+				    1,
+				    "length %d of nsh attr %d is invalid",
+				    mdlen,
+				    type
+				);
+				return -EINVAL;
+			}
+			memcpy(md2_dst, md2, mdlen);
+			break;
+		}
+		default:
+			OVS_NLERR(1, "Unknown nsh attribute %d",
+				  type);
+			return -EINVAL;
+		}
+	}
+
+	if (rem > 0) {
+		OVS_NLERR(1, "nsh attribute has %d unknown bytes.", rem);
+		return -EINVAL;
+	}
+
+	if ((has_md1 && nsh->md_type != NSH_M_TYPE1) ||
+	    (has_md2 && nsh->md_type != NSH_M_TYPE2)) {
+		OVS_NLERR(1,
+			  "nsh attribute has unmatched MD type %d.",
+			  nsh->md_type);
+		return -EINVAL;
+	}
+
+	if (unlikely(has_md1 && has_md2)) {
+		OVS_NLERR(1, "both nsh md1 and md2 attribute are there");
+		return -EINVAL;
+	}
+
+	if (unlikely(!has_md1 && !has_md2)) {
+		OVS_NLERR(1, "neither nsh md1 nor md2 attribute is there");
+		return -EINVAL;
+	}
+
+	/* nsh header length  = NSH_BASE_HDR_LEN + mdlen */
+	len = NSH_BASE_HDR_LEN + mdlen;
+	nsh_set_flags_ttl_len(nsh, flags, ttl, len);
+
+	return 0;
+}
+
+int nsh_key_from_nlattr(const struct nlattr *attr,
+			struct ovs_key_nsh *nsh)
+{
+	struct nlattr *a;
+	int rem;
+	bool has_md1 = false;
+
+	nla_for_each_nested(a, attr, rem) {
+		int type = nla_type(a);
+
+		if (type > OVS_NSH_KEY_ATTR_MAX) {
+			OVS_NLERR(1, "nsh attr %d is out of range max %d",
+				  type, OVS_NSH_KEY_ATTR_MAX);
+			return -EINVAL;
+		}
+
+		if (!check_attr_len(nla_len(a),
+				    ovs_nsh_key_attr_lens[type].len)) {
+			OVS_NLERR(
+			    1,
+			    "nsh attr %d has unexpected len %d expected %d",
+			    type,
+			    nla_len(a),
+			    ovs_nsh_key_attr_lens[type].len
+			);
+			return -EINVAL;
+		}
+
+		switch (type) {
+		case OVS_NSH_KEY_ATTR_BASE: {
+			const struct ovs_nsh_key_base *base =
+				(struct ovs_nsh_key_base *)nla_data(a);
+
+			memcpy(nsh, base, sizeof(*base));
+			break;
+		}
+		case OVS_NSH_KEY_ATTR_MD1: {
+			const struct ovs_nsh_key_md1 *md1 =
+				(struct ovs_nsh_key_md1 *)nla_data(a);
+
+			has_md1 = true;
+			memcpy(nsh->context, md1->context, sizeof(*md1));
+			break;
+		}
+		case OVS_NSH_KEY_ATTR_MD2:
+			/* Not supported yet */
+			return -ENOTSUPP;
+		default:
+			OVS_NLERR(1, "Unknown nsh attribute %d",
+				  type);
+			return -EINVAL;
+		}
+	}
+
+	if (rem > 0) {
+		OVS_NLERR(1, "nsh attribute has %d unknown bytes.", rem);
+		return -EINVAL;
+	}
+
+	if ((has_md1 && nsh->mdtype != NSH_M_TYPE1)) {
+		OVS_NLERR(1, "nsh attribute has unmatched MD type %d.",
+			  nsh->mdtype);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int nsh_key_put_from_nlattr(const struct nlattr *attr,
+				   struct sw_flow_match *match, bool is_mask,
+				   bool is_push_nsh, bool log)
+{
+	struct nlattr *a;
+	int rem;
+	bool has_md1 = false;
+	bool has_md2 = false;
+	u8 mdtype = 0;
+	int mdlen = 0;
+
+	nla_for_each_nested(a, attr, rem) {
+		int type = nla_type(a);
+		int i;
+
+		if (type > OVS_NSH_KEY_ATTR_MAX) {
+			OVS_NLERR(log, "nsh attr %d is out of range max %d",
+				  type, OVS_NSH_KEY_ATTR_MAX);
+			return -EINVAL;
+		}
+
+		if (!check_attr_len(nla_len(a),
+				    ovs_nsh_key_attr_lens[type].len)) {
+			OVS_NLERR(
+			    log,
+			    "nsh attr %d has unexpected len %d expected %d",
+			    type,
+			    nla_len(a),
+			    ovs_nsh_key_attr_lens[type].len
+			);
+			return -EINVAL;
+		}
+
+		switch (type) {
+		case OVS_NSH_KEY_ATTR_BASE: {
+			const struct ovs_nsh_key_base *base =
+				(struct ovs_nsh_key_base *)nla_data(a);
+
+			mdtype = base->mdtype;
+			SW_FLOW_KEY_PUT(match, nsh.flags,
+					base->flags, is_mask);
+			SW_FLOW_KEY_PUT(match, nsh.ttl,
+					base->ttl, is_mask);
+			SW_FLOW_KEY_PUT(match, nsh.mdtype,
+					base->mdtype, is_mask);
+			SW_FLOW_KEY_PUT(match, nsh.np,
+					base->np, is_mask);
+			SW_FLOW_KEY_PUT(match, nsh.path_hdr,
+					base->path_hdr, is_mask);
+			break;
+		}
+		case OVS_NSH_KEY_ATTR_MD1: {
+			const struct ovs_nsh_key_md1 *md1 =
+				(struct ovs_nsh_key_md1 *)nla_data(a);
+
+			has_md1 = true;
+			for (i = 0; i < NSH_MD1_CONTEXT_SIZE; i++)
+				SW_FLOW_KEY_PUT(match, nsh.context[i],
+						md1->context[i], is_mask);
+			break;
+		}
+		case OVS_NSH_KEY_ATTR_MD2:
+			if (!is_push_nsh) /* Not supported MD type 2 yet */
+				return -ENOTSUPP;
+
+			has_md2 = true;
+			mdlen = nla_len(a);
+			if ((mdlen + NSH_BASE_HDR_LEN) > NSH_M_TYPE2_MAX_LEN ||
+			    mdlen <= 0)
+				return -EINVAL;
+			break;
+		default:
+			OVS_NLERR(log, "Unknown nsh attribute %d",
+				  type);
+			return -EINVAL;
+		}
+	}
+
+	if (rem > 0) {
+		OVS_NLERR(log, "nsh attribute has %d unknown bytes.", rem);
+		return -EINVAL;
+	}
+
+	if (!is_mask) {
+		if ((has_md1 && mdtype != NSH_M_TYPE1)) {
+			OVS_NLERR(1, "nsh attribute has unmatched MD type %d.",
+				  mdtype);
+			return -EINVAL;
+		}
+	}
+
+	if (is_push_nsh & !is_mask) {
+		if ((has_md1 && mdtype != NSH_M_TYPE1) ||
+		    (has_md2 && mdtype != NSH_M_TYPE2) ||
+		    (has_md1 && has_md2) ||
+		    (!has_md1 && !has_md2)) {
+			OVS_NLERR(
+			    1,
+			    "push nsh attributes are invalid for type %d.",
+			    mdtype
+			);
+			return -EINVAL;
+		}
+	}
+
+	return 0;
+}
+
 static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
 				u64 attrs, const struct nlattr **a,
 				bool is_mask, bool log)
@@ -1306,6 +1631,13 @@ static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
 		attrs &= ~(1 << OVS_KEY_ATTR_ARP);
 	}
 
+	if (attrs & (1 << OVS_KEY_ATTR_NSH)) {
+		if (nsh_key_put_from_nlattr(a[OVS_KEY_ATTR_NSH], match,
+					    is_mask, false, log) < 0)
+			return -EINVAL;
+		attrs &= ~(1 << OVS_KEY_ATTR_NSH);
+	}
+
 	if (attrs & (1 << OVS_KEY_ATTR_MPLS)) {
 		const struct ovs_key_mpls *mpls_key;
 
@@ -1622,6 +1954,40 @@ static int ovs_nla_put_vlan(struct sk_buff *skb, const struct vlan_head *vh,
 	return 0;
 }
 
+static int nsh_key_to_nlattr(const struct ovs_key_nsh *nsh, bool is_mask,
+			     struct sk_buff *skb)
+{
+	struct nlattr *start;
+	struct ovs_nsh_key_base base;
+	struct ovs_nsh_key_md1 md1;
+
+	memcpy(&base, nsh, sizeof(base));
+
+	if (is_mask || nsh->mdtype == NSH_M_TYPE1)
+		memcpy(md1.context, nsh->context, sizeof(md1));
+
+	start = nla_nest_start(skb, OVS_KEY_ATTR_NSH);
+	if (!start)
+		return -EMSGSIZE;
+
+	if (nla_put(skb, OVS_NSH_KEY_ATTR_BASE, sizeof(base), &base))
+		goto nla_put_failure;
+
+	if (is_mask || nsh->mdtype == NSH_M_TYPE1) {
+		if (nla_put(skb, OVS_NSH_KEY_ATTR_MD1, sizeof(md1), &md1))
+			goto nla_put_failure;
+	}
+
+	/* Don't support MD type 2 yet */
+
+	nla_nest_end(skb, start);
+
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
 static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
 			     const struct sw_flow_key *output, bool is_mask,
 			     struct sk_buff *skb)
@@ -1750,6 +2116,9 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
 		ipv6_key->ipv6_tclass = output->ip.tos;
 		ipv6_key->ipv6_hlimit = output->ip.ttl;
 		ipv6_key->ipv6_frag = output->ip.frag;
+	} else if (swkey->eth.type == htons(ETH_P_NSH)) {
+		if (nsh_key_to_nlattr(&output->nsh, is_mask, skb))
+			goto nla_put_failure;
 	} else if (swkey->eth.type == htons(ETH_P_ARP) ||
 		   swkey->eth.type == htons(ETH_P_RARP)) {
 		struct ovs_key_arp *arp_key;
@@ -2242,6 +2611,19 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 	return err;
 }
 
+static bool validate_nsh(const struct nlattr *attr, bool is_mask,
+			 bool is_push_nsh, bool log)
+{
+	struct sw_flow_match match;
+	struct sw_flow_key key;
+	int ret = 0;
+
+	ovs_match_init(&match, &key, true, NULL);
+	ret = nsh_key_put_from_nlattr(attr, &match, is_mask,
+				      is_push_nsh, log);
+	return ((ret != 0) ? false : true);
+}
+
 /* Return false if there are any non-masked bits set.
  * Mask follows data immediately, before any netlink padding.
  */
@@ -2384,6 +2766,11 @@ static int validate_set(const struct nlattr *a,
 
 		break;
 
+	case OVS_KEY_ATTR_NSH:
+		if (!validate_nsh(nla_data(a), masked, false, log))
+			return -EINVAL;
+		break;
+
 	default:
 		return -EINVAL;
 	}
@@ -2482,6 +2869,8 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 			[OVS_ACTION_ATTR_TRUNC] = sizeof(struct ovs_action_trunc),
 			[OVS_ACTION_ATTR_PUSH_ETH] = sizeof(struct ovs_action_push_eth),
 			[OVS_ACTION_ATTR_POP_ETH] = 0,
+			[OVS_ACTION_ATTR_PUSH_NSH] = (u32)-1,
+			[OVS_ACTION_ATTR_POP_NSH] = 0,
 		};
 		const struct ovs_action_push_vlan *vlan;
 		int type = nla_type(a);
@@ -2636,6 +3025,19 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 			mac_proto = MAC_PROTO_ETHERNET;
 			break;
 
+		case OVS_ACTION_ATTR_PUSH_NSH:
+			mac_proto = MAC_PROTO_NONE;
+			if (!validate_nsh(nla_data(a), false, true, true))
+				return -EINVAL;
+			break;
+
+		case OVS_ACTION_ATTR_POP_NSH:
+			if (key->nsh.np == NSH_P_ETHERNET)
+				mac_proto = MAC_PROTO_ETHERNET;
+			else
+				mac_proto = MAC_PROTO_NONE;
+			break;
+
 		default:
 			OVS_NLERR(log, "Unknown Action type %d", type);
 			return -EINVAL;
diff --git a/net/openvswitch/flow_netlink.h b/net/openvswitch/flow_netlink.h
index 929c665..a849945 100644
--- a/net/openvswitch/flow_netlink.h
+++ b/net/openvswitch/flow_netlink.h
@@ -79,4 +79,8 @@ int ovs_nla_put_actions(const struct nlattr *attr,
 void ovs_nla_free_flow_actions(struct sw_flow_actions *);
 void ovs_nla_free_flow_actions_rcu(struct sw_flow_actions *);
 
+int nsh_key_from_nlattr(const struct nlattr *attr, struct ovs_key_nsh *nsh);
+int nsh_hdr_from_nlattr(const struct nlattr *attr, struct nsh_hdr *nsh_src,
+			size_t size);
+
 #endif /* flow_netlink.h */
-- 
2.5.5
