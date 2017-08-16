From: Yi Yang <yi.y.yang@intel.com>
Subject: [PATCH v3] openvswitch: enable NSH support
Date: Wed, 16 Aug 2017 13:35:30 +0800
Message-ID: <1502861730-76203-1-git-send-email-yi.y.yang@intel.com>
Cc: Yi Yang <yi.y.yang@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:37562 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751071AbdHPFjQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Aug 2017 01:39:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
 include/net/nsh.h                | 150 +++++++++++++++++++
 include/uapi/linux/openvswitch.h |  30 ++++
 net/openvswitch/actions.c        | 175 ++++++++++++++++++++++
 net/openvswitch/flow.c           |  39 +++++
 net/openvswitch/flow.h           |  11 ++
 net/openvswitch/flow_netlink.c   | 304 ++++++++++++++++++++++++++++++++++++++-
 net/openvswitch/flow_netlink.h   |   4 +
 8 files changed, 719 insertions(+), 1 deletion(-)
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
index 0000000..54f44f6
--- /dev/null
+++ b/include/net/nsh.h
@@ -0,0 +1,150 @@
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
+	__be32 context[4];
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
+#define NSH_M_TYPE2_MAX_LEN 256
+
+struct push_nsh_para {
+	__be16 ver_flags_len;
+	u8 md_type;
+	u8 next_proto;
+	__be32 path_hdr;
+	u8 metadata[NSH_M_TYPE2_MAX_LEN-8];
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
+static inline u16 nsh_hdr_len(const struct nsh_hdr *nsh)
+{
+	return ((ntohs(nsh->ver_flags_len) & NSH_LEN_MASK)
+		    >> NSH_LEN_SHIFT) << 2;
+}
+
+static inline struct nsh_md1_ctx *nsh_md1_ctx(struct nsh_hdr *nsh)
+{
+	return &nsh->md1;
+}
+
+static inline struct nsh_md2_tlv *nsh_md2_ctx(struct nsh_hdr *nsh)
+{
+	return nsh->md2;
+}
+
+static inline u8 nsh_get_ver(const struct nsh_hdr *nsh)
+{
+	return (ntohs(nsh->ver_flags_len) & NSH_VER_MASK) >> NSH_VER_SHIFT;
+}
+
+static inline u8 nsh_get_len(const struct nsh_hdr *nsh)
+{
+	return (ntohs(nsh->ver_flags_len) & NSH_LEN_MASK) >> NSH_LEN_SHIFT;
+}
+
+static inline u8 nsh_get_flags(const struct nsh_hdr *nsh)
+{
+	return (ntohs(nsh->ver_flags_len) & NSH_FLAGS_MASK)
+			>> NSH_FLAGS_SHIFT;
+}
+
+#endif /* __NET_NSH_H */
diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 156ee4c..596a043 100644
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
+	__u8 mdtype;
+	__u8 np;
+	__u8 pad;
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
@@ -769,6 +793,8 @@ struct ovs_action_push_eth {
 	struct ovs_key_ethernet addresses;
 };
 
+#define OVS_PUSH_NSH_MAX_MD_LEN 248
+
 /**
  * enum ovs_action_attr - Action types.
  *
@@ -806,6 +832,8 @@ struct ovs_action_push_eth {
  * packet.
  * @OVS_ACTION_ATTR_POP_ETH: Pop the outermost Ethernet header off the
  * packet.
+ * @OVS_ACTION_ATTR_PUSH_NSH: push NSH header to the packet.
+ * @OVS_ACTION_ATTR_POP_NSH: pop the outermost NSH header off the packet.
  *
  * Only a single header can be set with a single %OVS_ACTION_ATTR_SET.  Not all
  * fields within a header are modifiable, e.g. the IPv4 protocol and fragment
@@ -835,6 +863,8 @@ enum ovs_action_attr {
 	OVS_ACTION_ATTR_TRUNC,        /* u32 struct ovs_action_trunc. */
 	OVS_ACTION_ATTR_PUSH_ETH,     /* struct ovs_action_push_eth. */
 	OVS_ACTION_ATTR_POP_ETH,      /* No argument. */
+	OVS_ACTION_ATTR_PUSH_NSH,     /* Nested OVS_NSH_KEY_ATTR_*. */
+	OVS_ACTION_ATTR_POP_NSH,      /* No argument. */
 
 	__OVS_ACTION_ATTR_MAX,	      /* Nothing past this will be accepted
 				       * from userspace. */
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index e461067..38df378 100644
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
+		    const struct push_nsh_para *pnp)
+{
+	struct nsh_hdr *nsh;
+	size_t length = ((ntohs(pnp->ver_flags_len) & NSH_LEN_MASK)
+			     >> NSH_LEN_SHIFT) << 2;
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
+	memcpy(nsh, pnp, length);
+	nsh->next_proto = next_proto;
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
@@ -602,6 +695,50 @@ static int set_ipv6(struct sk_buff *skb, struct sw_flow_key *flow_key,
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
+			nsh->md1.context[i] =
+			    OVS_MASKED(nsh->md1.context[i], key->context[i],
+				       mask->context[i]);
+			flow_key->nsh.context[i] = nsh->md1.context[i];
+		}
+		break;
+	case NSH_M_TYPE2:
+		for (i = 0; i < 4; i++)
+			flow_key->nsh.context[i] = 0;
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
@@ -1024,6 +1161,31 @@ static int execute_masked_set_action(struct sk_buff *skb,
 				   get_mask(a, struct ovs_key_ethernet *));
 		break;
 
+	case OVS_KEY_ATTR_NSH: {
+		struct ovs_key_nsh nsh;
+		struct ovs_key_nsh nsh_mask;
+		size_t size = nla_len(a) / 2;
+		struct nlattr attr[1 + DIV_ROUND_UP(sizeof(struct ovs_key_ipv6)
+						    , sizeof(struct nlattr))];
+		struct nlattr mask[1 + DIV_ROUND_UP(sizeof(struct ovs_key_ipv6)
+						    , sizeof(struct nlattr))];
+
+		attr->nla_type = nla_type(a);
+		mask->nla_type = attr->nla_type;
+		attr->nla_len = NLA_HDRLEN + size;
+		mask->nla_len = attr->nla_len;
+		memcpy(attr + 1, (char *)(a + 1), size);
+		memcpy(mask + 1, (char *)(a + 1) + size, size);
+		err = nsh_key_from_nlattr(attr, &nsh);
+		if (err)
+			break;
+		err = nsh_key_from_nlattr(attr, &nsh_mask);
+		if (err)
+			break;
+		err = set_nsh(skb, flow_key, &nsh, &nsh_mask);
+		break;
+	}
+
 	case OVS_KEY_ATTR_IPV4:
 		err = set_ipv4(skb, flow_key, nla_data(a),
 			       get_mask(a, struct ovs_key_ipv4 *));
@@ -1210,6 +1372,19 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 		case OVS_ACTION_ATTR_POP_ETH:
 			err = pop_eth(skb, key);
 			break;
+
+		case OVS_ACTION_ATTR_PUSH_NSH: {
+			struct push_nsh_para pnp;
+			const struct push_nsh_para *pnpp = &pnp;
+
+			push_nsh_para_from_nlattr(nla_data(a), &pnp);
+			err = push_nsh(skb, key, pnpp);
+			break;
+		}
+
+		case OVS_ACTION_ATTR_POP_NSH:
+			err = pop_nsh(skb, key);
+			break;
 		}
 
 		if (unlikely(err)) {
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 8c94cef..e2d6463 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -46,6 +46,7 @@
 #include <net/ipv6.h>
 #include <net/mpls.h>
 #include <net/ndisc.h>
+#include <net/nsh.h>
 
 #include "conntrack.h"
 #include "datapath.h"
@@ -490,6 +491,40 @@ static int parse_icmpv6(struct sk_buff *skb, struct sw_flow_key *key,
 	return 0;
 }
 
+static int parse_nsh(struct sk_buff *skb, struct sw_flow_key *key)
+{
+	struct nsh_hdr *nsh = (struct nsh_hdr *)skb_network_header(skb);
+	u8 version, length;
+	u32 path_hdr;
+	int i;
+
+	memset(&key->nsh, 0, sizeof(struct ovs_key_nsh));
+	version = nsh_get_ver(nsh);
+	length = nsh_get_len(nsh);
+
+	key->nsh.flags = nsh_get_flags(nsh);
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
+			key->nsh.context[i] = nsh->md1.context[i];
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
@@ -735,6 +770,10 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
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
index 1875bba..6c738d0 100644
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
+	__u8 flags;
+	__u8 mdtype;
+	__u8 np;
+	__u8 pad;
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
index f07d10a..79059db 100644
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
@@ -322,12 +324,22 @@ size_t ovs_tun_key_attr_size(void)
 		+ nla_total_size(2);   /* OVS_TUNNEL_KEY_ATTR_TP_DST */
 }
 
+size_t ovs_nsh_key_attr_size(void)
+{
+	/* Whenever adding new OVS_NSH_KEY_ FIELDS, we should consider
+	 * updating this function.
+	 */
+	return  nla_total_size(8)      /* OVS_NSH_KEY_ATTR_BASE */
+		+ nla_total_size(16)   /* OVS_NSH_KEY_ATTR_MD1 */
+		+ nla_total_size(248); /* OVS_NSH_KEY_ATTR_MD2 */
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
@@ -341,6 +353,8 @@ size_t ovs_key_attr_size(void)
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_CT_MARK */
 		+ nla_total_size(16)  /* OVS_KEY_ATTR_CT_LABELS */
 		+ nla_total_size(40)  /* OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV6 */
+		+ nla_total_size(0)   /* OVS_KEY_ATTR_NSH */
+		  + ovs_nsh_key_attr_size()
 		+ nla_total_size(12)  /* OVS_KEY_ATTR_ETHERNET */
 		+ nla_total_size(2)   /* OVS_KEY_ATTR_ETHERTYPE */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_VLAN */
@@ -373,6 +387,13 @@ static const struct ovs_len_tbl ovs_tunnel_key_lens[OVS_TUNNEL_KEY_ATTR_MAX + 1]
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
@@ -405,6 +426,8 @@ static const struct ovs_len_tbl ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
 		.len = sizeof(struct ovs_key_ct_tuple_ipv4) },
 	[OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV6] = {
 		.len = sizeof(struct ovs_key_ct_tuple_ipv6) },
+	[OVS_KEY_ATTR_NSH]       = { .len = OVS_ATTR_NESTED,
+				     .next = ovs_nsh_key_attr_lens, },
 };
 
 static bool check_attr_len(unsigned int attr_len, unsigned int expected_len)
@@ -1179,6 +1202,209 @@ static int metadata_from_nlattrs(struct net *net, struct sw_flow_match *match,
 	return 0;
 }
 
+int push_nsh_para_from_nlattr(const struct nlattr *attr,
+			      struct push_nsh_para *pnp)
+{
+	struct nlattr *a;
+	int rem;
+	u8 flags = 0;
+	size_t mdlen = 0;
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
+			pnp->next_proto = base->np;
+			pnp->md_type = base->mdtype;
+			pnp->path_hdr = base->path_hdr;
+			break;
+		}
+		case OVS_NSH_KEY_ATTR_MD1: {
+			const struct ovs_nsh_key_md1 *md1 =
+				(struct ovs_nsh_key_md1 *)nla_data(a);
+
+			mdlen = nla_len(a);
+			memcpy(pnp->metadata, md1, mdlen);
+			break;
+		}
+		case OVS_NSH_KEY_ATTR_MD2: {
+			const struct u8 *md2 = nla_data(a);
+
+			mdlen = nla_len(a);
+			memcpy(pnp->metadata, md2, mdlen);
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
+	/* nsh header length  = NSH_BASE_HDR_LEN + mdlen */
+	pnp->ver_flags_len = htons(flags << NSH_FLAGS_SHIFT |
+				   (NSH_BASE_HDR_LEN + mdlen) >> 2);
+
+	return 0;
+}
+
+int nsh_key_from_nlattr(const struct nlattr *attr,
+			struct ovs_key_nsh *nsh)
+{
+	struct nlattr *a;
+	int rem;
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
+			nsh->flags = base->flags;
+			nsh->mdtype = base->mdtype;
+			nsh->np = base->np;
+			nsh->path_hdr = base->path_hdr;
+			break;
+		}
+		case OVS_NSH_KEY_ATTR_MD1: {
+			const struct ovs_nsh_key_md1 *md1 =
+				(struct ovs_nsh_key_md1 *)nla_data(a);
+			memcpy(nsh->context, md1->context, sizeof(*md1));
+			break;
+		}
+		case OVS_NSH_KEY_ATTR_MD2:
+			/* Not supported yet */
+			break;
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
+	return 0;
+}
+
+static int nsh_key_put_from_nlattr(const struct nlattr *attr,
+				   struct sw_flow_match *match, bool is_mask,
+				   bool log)
+{
+	struct nlattr *a;
+	int rem;
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
+			SW_FLOW_KEY_PUT(match, nsh.flags,
+					base->flags, is_mask);
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
+			for (i = 0; i < 4; i++)
+				SW_FLOW_KEY_PUT(match, nsh.context[i],
+						md1->context[i], is_mask);
+			break;
+		}
+		case OVS_NSH_KEY_ATTR_MD2:
+			/* Not supported yet */
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
+	return 0;
+}
+
 static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
 				u64 attrs, const struct nlattr **a,
 				bool is_mask, bool log)
@@ -1306,6 +1532,13 @@ static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
 		attrs &= ~(1 << OVS_KEY_ATTR_ARP);
 	}
 
+	if (attrs & (1 << OVS_KEY_ATTR_NSH)) {
+		if (nsh_key_put_from_nlattr(a[OVS_KEY_ATTR_NSH], match,
+					    is_mask, log) < 0)
+			return -EINVAL;
+		attrs &= ~(1 << OVS_KEY_ATTR_NSH);
+	}
+
 	if (attrs & (1 << OVS_KEY_ATTR_MPLS)) {
 		const struct ovs_key_mpls *mpls_key;
 
@@ -1622,6 +1855,43 @@ static int ovs_nla_put_vlan(struct sk_buff *skb, const struct vlan_head *vh,
 	return 0;
 }
 
+static int nsh_key_to_nlattr(const struct ovs_key_nsh *nsh, bool is_mask,
+			     struct sk_buff *skb)
+{
+	struct nlattr *start;
+	struct ovs_nsh_key_base base;
+	struct ovs_nsh_key_md1 md1;
+
+	base.flags = nsh->flags;
+	base.mdtype = nsh->mdtype;
+	base.np = nsh->np;
+	base.path_hdr = nsh->path_hdr;
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
@@ -1750,6 +2020,9 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
 		ipv6_key->ipv6_tclass = output->ip.tos;
 		ipv6_key->ipv6_hlimit = output->ip.ttl;
 		ipv6_key->ipv6_frag = output->ip.frag;
+	} else if (swkey->eth.type == htons(ETH_P_NSH)) {
+		if (nsh_key_to_nlattr(&output->nsh, is_mask, skb))
+			goto nla_put_failure;
 	} else if (swkey->eth.type == htons(ETH_P_ARP) ||
 		   swkey->eth.type == htons(ETH_P_RARP)) {
 		struct ovs_key_arp *arp_key;
@@ -2242,6 +2515,17 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 	return err;
 }
 
+static bool validate_nsh(const struct nlattr *attr, bool is_mask, bool log)
+{
+	struct sw_flow_match match;
+	struct sw_flow_key key;
+	int ret = 0;
+
+	ovs_match_init(&match, &key, true, NULL);
+	ret = nsh_key_put_from_nlattr(nla_data(attr), &match, is_mask, log);
+	return ((ret != 0) ? false : true);
+}
+
 /* Return false if there are any non-masked bits set.
  * Mask follows data immediately, before any netlink padding.
  */
@@ -2384,6 +2668,11 @@ static int validate_set(const struct nlattr *a,
 
 		break;
 
+	case OVS_KEY_ATTR_NSH:
+		if (!validate_nsh(a, masked, log))
+			return -EINVAL;
+		break;
+
 	default:
 		return -EINVAL;
 	}
@@ -2482,6 +2771,8 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 			[OVS_ACTION_ATTR_TRUNC] = sizeof(struct ovs_action_trunc),
 			[OVS_ACTION_ATTR_PUSH_ETH] = sizeof(struct ovs_action_push_eth),
 			[OVS_ACTION_ATTR_POP_ETH] = 0,
+			[OVS_ACTION_ATTR_PUSH_NSH] = (u32)-1,
+			[OVS_ACTION_ATTR_POP_NSH] = 0,
 		};
 		const struct ovs_action_push_vlan *vlan;
 		int type = nla_type(a);
@@ -2636,6 +2927,17 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 			mac_proto = MAC_PROTO_ETHERNET;
 			break;
 
+		case OVS_ACTION_ATTR_PUSH_NSH:
+			mac_proto = MAC_PROTO_NONE;
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
index 929c665..f9c14be 100644
--- a/net/openvswitch/flow_netlink.h
+++ b/net/openvswitch/flow_netlink.h
@@ -79,4 +79,8 @@ int ovs_nla_put_actions(const struct nlattr *attr,
 void ovs_nla_free_flow_actions(struct sw_flow_actions *);
 void ovs_nla_free_flow_actions_rcu(struct sw_flow_actions *);
 
+int nsh_key_from_nlattr(const struct nlattr *attr, struct ovs_key_nsh *nsh);
+int push_nsh_para_from_nlattr(const struct nlattr *attr,
+			      struct push_nsh_para *pnp);
+
 #endif /* flow_netlink.h */
-- 
2.5.5
