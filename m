From: Yi Yang <yi.y.yang@intel.com>
Subject: [PATCH net-next] openvswitch: add NSH support
Date: Tue,  8 Aug 2017 12:59:40 +0800
Message-ID: <1502168380-106785-1-git-send-email-yi.y.yang@intel.com>
Cc: dev@openvswitch.org, jbenc@redhat.com, davem@davemloft.net,
        Yi Yang <yi.y.yang@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:14957 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751698AbdHHFDY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 8 Aug 2017 01:03:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OVS master and 2.8 branch has merged NSH userspace
patch series, this patch is to enable NSH support
in kernel data path in order that OVS can support
NSH in 2.8 release in compat mode by porting this.

Signed-off-by: Yi Yang <yi.y.yang@intel.com>
---
 drivers/net/vxlan.c              |   7 ++
 include/net/nsh.h                | 126 ++++++++++++++++++++++++++++++
 include/uapi/linux/openvswitch.h |  33 ++++++++
 net/openvswitch/actions.c        | 165 +++++++++++++++++++++++++++++++++++++++
 net/openvswitch/flow.c           |  41 ++++++++++
 net/openvswitch/flow.h           |   1 +
 net/openvswitch/flow_netlink.c   |  54 ++++++++++++-
 7 files changed, 426 insertions(+), 1 deletion(-)
 create mode 100644 include/net/nsh.h

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index dbca067..843714c 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -27,6 +27,7 @@
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 #include <net/vxlan.h>
+#include <net/nsh.h>
 
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ip6_tunnel.h>
@@ -1267,6 +1268,9 @@ static bool vxlan_parse_gpe_hdr(struct vxlanhdr *unparsed,
 	case VXLAN_GPE_NP_IPV6:
 		*protocol = htons(ETH_P_IPV6);
 		break;
+	case VXLAN_GPE_NP_NSH:
+		*protocol = htons(ETH_P_NSH);
+		break;
 	case VXLAN_GPE_NP_ETHERNET:
 		*protocol = htons(ETH_P_TEB);
 		break;
@@ -1806,6 +1810,9 @@ static int vxlan_build_gpe_hdr(struct vxlanhdr *vxh, u32 vxflags,
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
index 0000000..96477a1
--- /dev/null
+++ b/include/net/nsh.h
@@ -0,0 +1,126 @@
+#ifndef __NET_NSH_H
+#define __NET_NSH_H 1
+
+
+/*
+ * Network Service Header:
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |Ver|O|C|R|R|R|R|R|R|    Length   |   MD Type   |  Next Proto   |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |                Service Path ID                | Service Index |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |                                                               |
+ * ~               Mandatory/Optional Context Header               ~
+ * |                                                               |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * Ver = The version field is used to ensure backward compatibility
+ *       going forward with future NSH updates.  It MUST be set to 0x0
+ *       by the sender, in this first revision of NSH.
+ *
+ * O = OAM. when set to 0x1 indicates that this packet is an operations
+ *     and management (OAM) packet.  The receiving SFF and SFs nodes
+ *     MUST examine the payload and take appropriate action.
+ *
+ * C = context. Indicates that a critical metadata TLV is present.
+ *
+ * Length : total length, in 4-byte words, of NSH including the Base
+ *          Header, the Service Path Header and the optional variable
+ *          TLVs.
+ * MD Type: indicates the format of NSH beyond the mandatory Base Header
+ *          and the Service Path Header.
+ *
+ * Next Protocol: indicates the protocol type of the original packet. A
+ *          new IANA registry will be created for protocol type.
+ *
+ * Service Path Identifier (SPI): identifies a service path.
+ *          Participating nodes MUST use this identifier for Service
+ *          Function Path selection.
+ *
+ * Service Index (SI): provides location within the SFP.
+ *
+ * [0] https://tools.ietf.org/html/draft-ietf-sfc-nsh-13
+ */
+
+/**
+ * struct nsh_md1_ctx - Keeps track of NSH context data
+ * @nshc<1-4>: NSH Contexts.
+ */
+struct nsh_md1_ctx {
+	__be32 c[4];
+};
+
+struct nsh_md2_tlv {
+	__be16 md_class;
+	u8 type;
+	u8 length;
+	u8 md_value[];
+};
+
+struct nsh_hdr {
+	__be16 ver_flags_len;
+	u8 md_type;
+	u8 next_proto;
+	__be32 path_hdr;
+	union {
+	    struct nsh_md1_ctx md1;
+	    struct nsh_md2_tlv md2[0];
+	};
+};
+
+/* Masking NSH header fields. */
+#define NSH_VER_MASK       0xc000
+#define NSH_VER_SHIFT      14
+#define NSH_FLAGS_MASK     0x3fc0
+#define NSH_FLAGS_SHIFT    6
+#define NSH_LEN_MASK       0x003f
+#define NSH_LEN_SHIFT      0
+
+#define NSH_SPI_MASK       0xffffff00
+#define NSH_SPI_SHIFT      8
+#define NSH_SI_MASK        0x000000ff
+#define NSH_SI_SHIFT       0
+
+#define NSH_DST_PORT    4790     /* UDP Port for NSH on VXLAN. */
+#define ETH_P_NSH       0x894F   /* Ethertype for NSH. */
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
+/* NSH Metadata Length. */
+#define NSH_M_TYPE1_MDLEN 16
+
+/* NSH Base Header Length */
+#define NSH_BASE_HDR_LEN  8
+
+/* NSH MD Type 1 header Length. */
+#define NSH_M_TYPE1_LEN   24
+
+static inline u16
+nsh_hdr_len(const struct nsh_hdr *nsh)
+{
+	return 4 * (ntohs(nsh->ver_flags_len) & NSH_LEN_MASK) >> NSH_LEN_SHIFT;
+}
+
+static inline struct nsh_md1_ctx *
+nsh_md1_ctx(struct nsh_hdr *nsh)
+{
+	return &nsh->md1;
+}
+
+static inline struct nsh_md2_tlv *
+nsh_md2_ctx(struct nsh_hdr *nsh)
+{
+	return nsh->md2;
+}
+
+#endif /* __NET_NSH_H */
diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 156ee4c..b9c072c 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -333,6 +333,7 @@ enum ovs_key_attr {
 	OVS_KEY_ATTR_CT_LABELS,	/* 16-octet connection tracking label */
 	OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV4,   /* struct ovs_key_ct_tuple_ipv4 */
 	OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV6,   /* struct ovs_key_ct_tuple_ipv6 */
+	OVS_KEY_ATTR_NSH,                  /* struct ovs_key_nsh */
 
 #ifdef __KERNEL__
 	OVS_KEY_ATTR_TUNNEL_INFO,  /* struct ip_tunnel_info */
@@ -491,6 +492,15 @@ struct ovs_key_ct_tuple_ipv6 {
 	__u8   ipv6_proto;
 };
 
+struct ovs_key_nsh {
+	__u8 flags;
+	__u8 mdtype;
+	__u8 np;
+	__u8 pad;
+	__be32 path_hdr;
+	__be32 c[4];
+};
+
 /**
  * enum ovs_flow_attr - attributes for %OVS_FLOW_* commands.
  * @OVS_FLOW_ATTR_KEY: Nested %OVS_KEY_ATTR_* attributes specifying the flow
@@ -769,6 +779,25 @@ struct ovs_action_push_eth {
 	struct ovs_key_ethernet addresses;
 };
 
+#define OVS_ENCAP_NSH_MAX_MD_LEN 16
+/*
+ * struct ovs_action_encap_nsh - %OVS_ACTION_ATTR_ENCAP_NSH
+ * @flags: NSH header flags.
+ * @mdtype: NSH metadata type.
+ * @mdlen: Length of NSH metadata in bytes.
+ * @np: NSH next_protocol: Inner packet type.
+ * @path_hdr: NSH service path id and service index.
+ * @metadata: NSH metadata for MD type 1 or 2
+ */
+struct ovs_action_encap_nsh {
+	__u8 flags;
+	__u8 mdtype;
+	__u8 mdlen;
+	__u8 np;
+	__be32 path_hdr;
+	__u8 metadata[OVS_ENCAP_NSH_MAX_MD_LEN];
+};
+
 /**
  * enum ovs_action_attr - Action types.
  *
@@ -806,6 +835,8 @@ struct ovs_action_push_eth {
  * packet.
  * @OVS_ACTION_ATTR_POP_ETH: Pop the outermost Ethernet header off the
  * packet.
+ * @OVS_ACTION_ATTR_ENCAP_NSH: encap NSH action to push NSH header.
+ * @OVS_ACTION_ATTR_DECAP_NSH: decap NSH action to remove NSH header.
  *
  * Only a single header can be set with a single %OVS_ACTION_ATTR_SET.  Not all
  * fields within a header are modifiable, e.g. the IPv4 protocol and fragment
@@ -835,6 +866,8 @@ enum ovs_action_attr {
 	OVS_ACTION_ATTR_TRUNC,        /* u32 struct ovs_action_trunc. */
 	OVS_ACTION_ATTR_PUSH_ETH,     /* struct ovs_action_push_eth. */
 	OVS_ACTION_ATTR_POP_ETH,      /* No argument. */
+	OVS_ACTION_ATTR_ENCAP_NSH,    /* struct ovs_action_encap_nsh. */
+	OVS_ACTION_ATTR_DECAP_NSH,    /* No argument. */
 
 	__OVS_ACTION_ATTR_MAX,	      /* Nothing past this will be accepted
 				       * from userspace. */
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index e461067..6ba67e1 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -38,6 +38,7 @@
 #include <net/dsfield.h>
 #include <net/mpls.h>
 #include <net/sctp/checksum.h>
+#include <net/nsh.h>
 
 #include "datapath.h"
 #include "flow.h"
@@ -380,6 +381,114 @@ static int push_eth(struct sk_buff *skb, struct sw_flow_key *key,
 	return 0;
 }
 
+static int encap_nsh(struct sk_buff *skb, struct sw_flow_key *key,
+		     const struct ovs_action_encap_nsh *encap)
+{
+	struct nsh_hdr *nsh;
+	size_t length = NSH_BASE_HDR_LEN + encap->mdlen;
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
+	nsh->ver_flags_len = htons((encap->flags << NSH_FLAGS_SHIFT) |
+				 (length >> 2));
+	nsh->next_proto = next_proto;
+	nsh->path_hdr = encap->path_hdr;
+	nsh->md_type = encap->mdtype;
+	switch (nsh->md_type) {
+	case NSH_M_TYPE1:
+		nsh->md1 = *(struct nsh_md1_ctx *)encap->metadata;
+		break;
+	case NSH_M_TYPE2: {
+		/* The MD2 metadata in encap is already padded to 4 bytes. */
+		size_t len = DIV_ROUND_UP(encap->mdlen, 4) * 4;
+
+		memcpy(nsh->md2, encap->metadata, len);
+		break;
+	}
+	default:
+		return -ENOTSUPP;
+	}
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
+static int decap_nsh(struct sk_buff *skb, struct sw_flow_key *key)
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
@@ -602,6 +711,49 @@ static int set_ipv6(struct sk_buff *skb, struct sw_flow_key *flow_key,
 	return 0;
 }
 
+static int set_nsh(struct sk_buff *skb, struct sw_flow_key *flow_key,
+		   const struct ovs_key_nsh *key,
+		   const struct ovs_key_nsh *mask)
+{
+	struct nsh_hdr *nsh;
+	int err;
+	u8 flags;
+	int i;
+
+	err = skb_ensure_writable(skb, skb_network_offset(skb) +
+				  sizeof(struct nsh_hdr));
+	if (unlikely(err))
+		return err;
+
+	nsh = (struct nsh_hdr *)skb_network_header(skb);
+
+	flags = (ntohs(nsh->ver_flags_len) & NSH_FLAGS_MASK) >>
+		NSH_FLAGS_SHIFT;
+	flags = OVS_MASKED(flags, key->flags, mask->flags);
+	flow_key->nsh.flags = flags;
+	nsh->ver_flags_len = htons(flags << NSH_FLAGS_SHIFT) |
+			     (nsh->ver_flags_len & ~htons(NSH_FLAGS_MASK));
+	nsh->path_hdr = OVS_MASKED(nsh->path_hdr, key->path_hdr,
+				   mask->path_hdr);
+	flow_key->nsh.path_hdr = nsh->path_hdr;
+	switch (nsh->md_type) {
+	case NSH_M_TYPE1:
+		for (i = 0; i < 4; i++) {
+			nsh->md1.c[i] =
+			    OVS_MASKED(nsh->md1.c[i], key->c[i], mask->c[i]);
+			flow_key->nsh.c[i] = nsh->md1.c[i];
+		}
+		break;
+	case NSH_M_TYPE2:
+		for (i = 0; i < 4; i++)
+			flow_key->nsh.c[i] = 0;
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
@@ -1024,6 +1176,11 @@ static int execute_masked_set_action(struct sk_buff *skb,
 				   get_mask(a, struct ovs_key_ethernet *));
 		break;
 
+	case OVS_KEY_ATTR_NSH:
+		err = set_nsh(skb, flow_key, nla_data(a),
+			      get_mask(a, struct ovs_key_nsh *));
+		break;
+
 	case OVS_KEY_ATTR_IPV4:
 		err = set_ipv4(skb, flow_key, nla_data(a),
 			       get_mask(a, struct ovs_key_ipv4 *));
@@ -1210,6 +1367,14 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 		case OVS_ACTION_ATTR_POP_ETH:
 			err = pop_eth(skb, key);
 			break;
+
+		case OVS_ACTION_ATTR_ENCAP_NSH:
+			err = encap_nsh(skb, key, nla_data(a));
+			break;
+
+		case OVS_ACTION_ATTR_DECAP_NSH:
+			err = decap_nsh(skb, key);
+			break;
 		}
 
 		if (unlikely(err)) {
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 8c94cef..dc8631c 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -46,6 +46,7 @@
 #include <net/ipv6.h>
 #include <net/mpls.h>
 #include <net/ndisc.h>
+#include <net/nsh.h>
 
 #include "conntrack.h"
 #include "datapath.h"
@@ -490,6 +491,42 @@ static int parse_icmpv6(struct sk_buff *skb, struct sw_flow_key *key,
 	return 0;
 }
 
+static int parse_nsh(struct sk_buff *skb, struct sw_flow_key *key)
+{
+	struct nsh_hdr *nsh = (struct nsh_hdr *)skb_network_header(skb);
+	u16 ver_flags_len;
+	u8 version, length;
+	u32 path_hdr;
+	int i;
+
+	memset(&key->nsh, 0, sizeof(struct ovs_key_nsh));
+	ver_flags_len = ntohs(nsh->ver_flags_len);
+	version = (ver_flags_len & NSH_VER_MASK) >> NSH_VER_SHIFT;
+	length = (ver_flags_len & NSH_LEN_MASK) >> NSH_LEN_SHIFT;
+
+	key->nsh.flags = (ver_flags_len & NSH_FLAGS_MASK) >> NSH_FLAGS_SHIFT;
+	key->nsh.mdtype = nsh->md_type;
+	key->nsh.np = nsh->next_proto;
+	path_hdr = ntohl(nsh->path_hdr);
+	key->nsh.path_hdr = nsh->path_hdr;
+	switch (key->nsh.mdtype) {
+	case NSH_M_TYPE1:
+		if ((length << 2) != NSH_M_TYPE1_LEN)
+			return -EINVAL;
+
+		for (i = 0; i < 4; i++)
+			key->nsh.c[i] = nsh->md1.c[i];
+
+		break;
+	case NSH_M_TYPE2:
+		/* Don't support MD type 2 yet */
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
@@ -735,6 +772,10 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
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
index 1875bba..d2a0e56 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -144,6 +144,7 @@ struct sw_flow_key {
 			};
 		} ipv6;
 	};
+	struct ovs_key_nsh nsh;         /* network service header */
 	struct {
 		/* Connection tracking fields not packed above. */
 		struct {
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index f07d10a..147b3c0 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -48,6 +48,7 @@
 #include <net/ndisc.h>
 #include <net/mpls.h>
 #include <net/vxlan.h>
+#include <net/nsh.h>
 
 #include "flow_netlink.h"
 
@@ -76,9 +77,11 @@ static bool actions_may_change_flow(const struct nlattr *actions)
 
 		case OVS_ACTION_ATTR_CT:
 		case OVS_ACTION_ATTR_HASH:
+		case OVS_ACTION_ATTR_DECAP_NSH:
 		case OVS_ACTION_ATTR_POP_ETH:
 		case OVS_ACTION_ATTR_POP_MPLS:
 		case OVS_ACTION_ATTR_POP_VLAN:
+		case OVS_ACTION_ATTR_ENCAP_NSH:
 		case OVS_ACTION_ATTR_PUSH_ETH:
 		case OVS_ACTION_ATTR_PUSH_MPLS:
 		case OVS_ACTION_ATTR_PUSH_VLAN:
@@ -327,7 +330,7 @@ size_t ovs_key_attr_size(void)
 	/* Whenever adding new OVS_KEY_ FIELDS, we should consider
 	 * updating this function.
 	 */
-	BUILD_BUG_ON(OVS_KEY_ATTR_TUNNEL_INFO != 28);
+	BUILD_BUG_ON(OVS_KEY_ATTR_TUNNEL_INFO != 29);
 
 	return    nla_total_size(4)   /* OVS_KEY_ATTR_PRIORITY */
 		+ nla_total_size(0)   /* OVS_KEY_ATTR_TUNNEL */
@@ -341,6 +344,7 @@ size_t ovs_key_attr_size(void)
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_CT_MARK */
 		+ nla_total_size(16)  /* OVS_KEY_ATTR_CT_LABELS */
 		+ nla_total_size(40)  /* OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV6 */
+		+ nla_total_size(24)  /* OVS_KEY_ATTR_NSH */
 		+ nla_total_size(12)  /* OVS_KEY_ATTR_ETHERNET */
 		+ nla_total_size(2)   /* OVS_KEY_ATTR_ETHERTYPE */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_VLAN */
@@ -405,6 +409,7 @@ static const struct ovs_len_tbl ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
 		.len = sizeof(struct ovs_key_ct_tuple_ipv4) },
 	[OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV6] = {
 		.len = sizeof(struct ovs_key_ct_tuple_ipv6) },
+	[OVS_KEY_ATTR_NSH]       = { .len = sizeof(struct ovs_key_nsh) },
 };
 
 static bool check_attr_len(unsigned int attr_len, unsigned int expected_len)
@@ -1306,6 +1311,22 @@ static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
 		attrs &= ~(1 << OVS_KEY_ATTR_ARP);
 	}
 
+	if (attrs & (1 << OVS_KEY_ATTR_NSH)) {
+		int i;
+		const struct ovs_key_nsh *nsh_key;
+
+		nsh_key = nla_data(a[OVS_KEY_ATTR_NSH]);
+		SW_FLOW_KEY_PUT(match, nsh.flags, nsh_key->flags, is_mask);
+		SW_FLOW_KEY_PUT(match, nsh.mdtype, nsh_key->mdtype, is_mask);
+		SW_FLOW_KEY_PUT(match, nsh.np, nsh_key->np, is_mask);
+		SW_FLOW_KEY_PUT(match, nsh.path_hdr, nsh_key->path_hdr,
+				is_mask);
+		for (i = 0; i < 4; i++)
+			SW_FLOW_KEY_PUT(match, nsh.c[i], nsh_key->c[i],
+					is_mask);
+		attrs &= ~(1 << OVS_KEY_ATTR_NSH);
+	}
+
 	if (attrs & (1 << OVS_KEY_ATTR_MPLS)) {
 		const struct ovs_key_mpls *mpls_key;
 
@@ -1750,6 +1771,21 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
 		ipv6_key->ipv6_tclass = output->ip.tos;
 		ipv6_key->ipv6_hlimit = output->ip.ttl;
 		ipv6_key->ipv6_frag = output->ip.frag;
+	} else if (swkey->eth.type == htons(ETH_P_NSH)) {
+		int i;
+		struct ovs_key_nsh *nsh_key;
+
+		nla = nla_reserve(skb, OVS_KEY_ATTR_NSH, sizeof(*nsh_key));
+		if (!nla)
+			goto nla_put_failure;
+		nsh_key = nla_data(nla);
+		memset(nsh_key, 0, sizeof(struct ovs_key_nsh));
+		nsh_key->flags = output->nsh.flags;
+		nsh_key->mdtype = output->nsh.mdtype;
+		nsh_key->np = output->nsh.np;
+		nsh_key->path_hdr = output->nsh.path_hdr;
+		for (i = 0; i < 4; i++)
+			nsh_key->c[0] = output->nsh.c[i];
 	} else if (swkey->eth.type == htons(ETH_P_ARP) ||
 		   swkey->eth.type == htons(ETH_P_RARP)) {
 		struct ovs_key_arp *arp_key;
@@ -2384,6 +2420,9 @@ static int validate_set(const struct nlattr *a,
 
 		break;
 
+	case OVS_KEY_ATTR_NSH:
+		break;
+
 	default:
 		return -EINVAL;
 	}
@@ -2482,6 +2521,8 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 			[OVS_ACTION_ATTR_TRUNC] = sizeof(struct ovs_action_trunc),
 			[OVS_ACTION_ATTR_PUSH_ETH] = sizeof(struct ovs_action_push_eth),
 			[OVS_ACTION_ATTR_POP_ETH] = 0,
+			[OVS_ACTION_ATTR_ENCAP_NSH] = sizeof(struct ovs_action_encap_nsh),
+			[OVS_ACTION_ATTR_DECAP_NSH] = 0,
 		};
 		const struct ovs_action_push_vlan *vlan;
 		int type = nla_type(a);
@@ -2636,6 +2677,17 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 			mac_proto = MAC_PROTO_ETHERNET;
 			break;
 
+		case OVS_ACTION_ATTR_ENCAP_NSH:
+			mac_proto = MAC_PROTO_NONE;
+			break;
+
+		case OVS_ACTION_ATTR_DECAP_NSH:
+			if (key->nsh.np == NSH_P_ETHERNET)
+				mac_proto = MAC_PROTO_ETHERNET;
+			else
+				mac_proto = MAC_PROTO_NONE;
+			break;
+
 		default:
 			OVS_NLERR(log, "Unknown Action type %d", type);
 			return -EINVAL;
-- 
2.5.5
