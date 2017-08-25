From: Yi Yang <yi.y.yang@intel.com>
Subject: [PATCH net-next v6 3/3] openvswitch: enable NSH support
Date: Fri, 25 Aug 2017 22:20:05 +0800
Message-ID: <1503670805-31051-4-git-send-email-yi.y.yang@intel.com>
References: <1503670805-31051-1-git-send-email-yi.y.yang@intel.com>
Cc: dev@openvswitch.org, jbenc@redhat.com, e@erig.me, blp@ovn.org,
        jan.scheurich@ericsson.com, Yi Yang <yi.y.yang@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:58033 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933264AbdHYOYx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Aug 2017 10:24:53 -0400
In-Reply-To: <1503670805-31051-1-git-send-email-yi.y.yang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OVS master and 2.8 branch has merged NSH userspace
patch series, this patch is to enable NSH support
in kernel data path in order that OVS can support
NSH in compat mode by porting this.

Signed-off-by: Yi Yang <yi.y.yang@intel.com>
---
 drivers/net/vxlan.c              |   7 +
 include/uapi/linux/openvswitch.h |  28 +++
 net/openvswitch/actions.c        | 178 +++++++++++++++++
 net/openvswitch/flow.c           |  55 ++++++
 net/openvswitch/flow.h           |  11 ++
 net/openvswitch/flow_netlink.c   | 404 ++++++++++++++++++++++++++++++++++++++-
 net/openvswitch/flow_netlink.h   |   4 +
 7 files changed, 686 insertions(+), 1 deletion(-)

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
index a54a556..9ca1a84 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -43,6 +43,7 @@
 #include "flow.h"
 #include "conntrack.h"
 #include "vport.h"
+#include "flow_netlink.h"
 
 struct deferred_action {
 	struct sk_buff *skb;
@@ -380,6 +381,95 @@ static int push_eth(struct sk_buff *skb, struct sw_flow_key *key,
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
+	nsh->np = next_proto;
+	nsh->mdtype &= NSH_MDTYPE_MASK;
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
+	switch (nsh->np) {
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
@@ -602,6 +692,53 @@ static int set_ipv6(struct sk_buff *skb, struct sw_flow_key *flow_key,
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
+	switch (nsh->mdtype) {
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
@@ -1024,6 +1161,32 @@ static int execute_masked_set_action(struct sk_buff *skb,
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
@@ -1210,6 +1373,21 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 		case OVS_ACTION_ATTR_POP_ETH:
 			err = pop_eth(skb, key);
 			break;
+
+		case OVS_ACTION_ATTR_PUSH_NSH: {
+			u8 buffer[NSH_HDR_MAX_LEN];
+			struct nsh_hdr *nsh_hdr = (struct nsh_hdr *)buffer;
+			const struct nsh_hdr *nsh_src = nsh_hdr;
+
+			nsh_hdr_from_nlattr(nla_data(a), nsh_hdr,
+					    NSH_HDR_MAX_LEN);
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
index 8c94cef..34865b5 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -46,6 +46,7 @@
 #include <net/ipv6.h>
 #include <net/mpls.h>
 #include <net/ndisc.h>
+#include <net/nsh.h>
 
 #include "conntrack.h"
 #include "datapath.h"
@@ -490,6 +491,56 @@ static int parse_icmpv6(struct sk_buff *skb, struct sw_flow_key *key,
 	return 0;
 }
 
+static int parse_nsh(struct sk_buff *skb, struct sw_flow_key *key)
+{
+	struct nsh_hdr *nsh;
+	unsigned int nh_ofs = skb_network_offset(skb);
+	u8 version, length;
+	int err;
+
+	err = check_header(skb, nh_ofs + NSH_BASE_HDR_LEN);
+	if (unlikely(err))
+		return err;
+
+	nsh = (struct nsh_hdr *)skb_network_header(skb);
+	version = nsh_get_ver(nsh);
+	length = nsh_hdr_len(nsh);
+
+	if (version != 0)
+		return -EINVAL;
+
+	err = check_header(skb, nh_ofs + length);
+	if (unlikely(err))
+		return err;
+
+	nsh = (struct nsh_hdr *)skb_network_header(skb);
+	key->nsh.flags = nsh_get_flags(nsh);
+	key->nsh.ttl = nsh_get_ttl(nsh);
+	key->nsh.mdtype = nsh->mdtype;
+	key->nsh.np = nsh->np;
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
@@ -735,6 +786,10 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
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
index e8eb427..3b7f166 100644
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
+		+ nla_total_size(NSH_CTX_HDRS_MAX_LEN);
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
+			nsh->np = base->np;
+			nsh->mdtype = base->mdtype;
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
+	if ((has_md1 && nsh->mdtype != NSH_M_TYPE1) ||
+	    (has_md2 && nsh->mdtype != NSH_M_TYPE2)) {
+		OVS_NLERR(1,
+			  "nsh attribute has unmatched MD type %d.",
+			  nsh->mdtype);
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
+			if ((mdlen > NSH_CTX_HDRS_MAX_LEN) ||
+			    (mdlen <= 0))
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
