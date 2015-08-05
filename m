From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv2 net-next 5/9] openvswitch: Add conntrack action
Date: Tue,  4 Aug 2015 21:49:55 -0700
Message-ID: <1438750199-9061-6-git-send-email-joestringer@nicira.com>
References: <1438750199-9061-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, pablo@netfilter.org, kaber@trash.net,
	jpettit@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	jesse@nicira.com, fwestpha@redhat.com, hannes@redhat.com,
	tgraf@noironetworks.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438750199-9061-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Expose the kernel connection tracker via OVS. Userspace components can
make use of the "ct()" action, followed by "recirculate", to populate
the conntracking state in the OVS flow key, and subsequently match on
that state.

Example ODP flows allowing traffic from 1->2, only replies from 2->1:
in_port=1,tcp,action=ct(commit,zone=1),2
in_port=2,ct_state=-trk,tcp,action=ct(zone=1),recirc(1)
recirc_id=1,in_port=2,ct_state=+trk+est-new,tcp,action=1

IP fragments are handled by transparently assembling them as part of the
ct action. The maximum received unit (MRU) size is tracked so that
refragmentation can occur during output.

IP frag handling contributed by Andy Zhou.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
Signed-off-by: Justin Pettit <jpettit@nicira.com>
Signed-off-by: Andy Zhou <azhou@nicira.com>
---
This can be tested with the corresponding userspace component here:
https://www.github.com/justinpettit/openvswitch conntrack

v2: Don't take references to devs or dsts in output path.
    Shift ovs_ct_init()/ovs_ct_exit() into this patch
    Handle output case where flow key is invalidated
    Store the entire L2 header to apply to fragments
    Various minor simplifications
    Improve comments/logs
    Style fixes
    Rebase
---
 include/uapi/linux/openvswitch.h |  41 ++++
 net/openvswitch/Kconfig          |  11 +
 net/openvswitch/Makefile         |   2 +
 net/openvswitch/actions.c        | 154 ++++++++++++-
 net/openvswitch/conntrack.c      | 475 +++++++++++++++++++++++++++++++++++++++
 net/openvswitch/conntrack.h      |  97 ++++++++
 net/openvswitch/datapath.c       |  73 ++++--
 net/openvswitch/datapath.h       |   8 +
 net/openvswitch/flow.c           |   3 +
 net/openvswitch/flow.h           |   6 +
 net/openvswitch/flow_netlink.c   |  72 ++++--
 net/openvswitch/flow_netlink.h   |   4 +-
 net/openvswitch/vport.c          |   1 +
 13 files changed, 910 insertions(+), 37 deletions(-)
 create mode 100644 net/openvswitch/conntrack.c
 create mode 100644 net/openvswitch/conntrack.h

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index d6b8854..1dae30a 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -164,6 +164,9 @@ enum ovs_packet_cmd {
  * %OVS_USERSPACE_ATTR_EGRESS_TUN_PORT attribute, which is sent only if the
  * output port is actually a tunnel port. Contains the output tunnel key
  * extracted from the packet as nested %OVS_TUNNEL_KEY_ATTR_* attributes.
+ * @OVS_PACKET_ATTR_MRU: Present for an %OVS_PACKET_CMD_ACTION and
+ * %OVS_PACKET_ATTR_USERSPACE action specify the Maximum received fragment
+ * size.
  *
  * These attributes follow the &struct ovs_header within the Generic Netlink
  * payload for %OVS_PACKET_* commands.
@@ -180,6 +183,7 @@ enum ovs_packet_attr {
 	OVS_PACKET_ATTR_UNUSED2,
 	OVS_PACKET_ATTR_PROBE,      /* Packet operation is a feature probe,
 				       error logging should be suppressed. */
+	OVS_PACKET_ATTR_MRU,	    /* Maximum received IP fragment size. */
 	__OVS_PACKET_ATTR_MAX
 };
 
@@ -319,6 +323,8 @@ enum ovs_key_attr {
 	OVS_KEY_ATTR_MPLS,      /* array of struct ovs_key_mpls.
 				 * The implementation may restrict
 				 * the accepted length of the array. */
+	OVS_KEY_ATTR_CT_STATE,	/* u8 bitmask of OVS_CS_F_* */
+	OVS_KEY_ATTR_CT_ZONE,	/* u16 connection tracking zone. */
 
 #ifdef __KERNEL__
 	OVS_KEY_ATTR_TUNNEL_INFO,  /* struct ip_tunnel_info */
@@ -431,6 +437,15 @@ struct ovs_key_nd {
 	__u8	nd_tll[ETH_ALEN];
 };
 
+/* OVS_KEY_ATTR_CT_STATE flags */
+#define OVS_CS_F_NEW               0x01 /* Beginning of a new connection. */
+#define OVS_CS_F_ESTABLISHED       0x02 /* Part of an existing connection. */
+#define OVS_CS_F_RELATED           0x04 /* Related to an established
+					 * connection. */
+#define OVS_CS_F_INVALID           0x20 /* Could not track connection. */
+#define OVS_CS_F_REPLY_DIR         0x40 /* Flow is in the reply direction. */
+#define OVS_CS_F_TRACKED           0x80 /* Conntrack has occurred. */
+
 /**
  * enum ovs_flow_attr - attributes for %OVS_FLOW_* commands.
  * @OVS_FLOW_ATTR_KEY: Nested %OVS_KEY_ATTR_* attributes specifying the flow
@@ -595,6 +610,29 @@ struct ovs_action_hash {
 };
 
 /**
+ * enum ovs_ct_attr - Attributes for %OVS_ACTION_ATTR_CT action.
+ * @OVS_CT_ATTR_FLAGS: u32 connection tracking flags.
+ * @OVS_CT_ATTR_ZONE: u16 connection tracking zone.
+ * @OVS_CT_ATTR_HELPER: variable length string defining conntrack ALG.
+ */
+enum ovs_ct_attr {
+	OVS_CT_ATTR_UNSPEC,
+	OVS_CT_ATTR_FLAGS,      /* u8 bitmask of OVS_CT_F_*. */
+	OVS_CT_ATTR_ZONE,       /* u16 zone id. */
+	__OVS_CT_ATTR_MAX
+};
+
+#define OVS_CT_ATTR_MAX (__OVS_CT_ATTR_MAX - 1)
+
+/*
+ * OVS_CT_ATTR_FLAGS flags - bitmask of %OVS_CT_F_*
+ * @OVS_CT_F_COMMIT: Commits the flow to the conntrack hashtable in the
+ * specified zone. Future packets for the current connection will be
+ * considered as 'established' or 'related'.
+ */
+#define OVS_CT_F_COMMIT		0x01
+
+/**
  * enum ovs_action_attr - Action types.
  *
  * @OVS_ACTION_ATTR_OUTPUT: Output packet to port.
@@ -623,6 +661,8 @@ struct ovs_action_hash {
  * indicate the new packet contents. This could potentially still be
  * %ETH_P_MPLS if the resulting MPLS label stack is not empty.  If there
  * is no MPLS label stack, as determined by ethertype, no action is taken.
+ * @OVS_ACTION_ATTR_CT: Track the connection. Populate the conntrack-related
+ * entries in the flow key.
  *
  * Only a single header can be set with a single %OVS_ACTION_ATTR_SET.  Not all
  * fields within a header are modifiable, e.g. the IPv4 protocol and fragment
@@ -648,6 +688,7 @@ enum ovs_action_attr {
 				       * data immediately followed by a mask.
 				       * The data must be zero for the unmasked
 				       * bits. */
+	OVS_ACTION_ATTR_CT,           /* One nested OVS_CT_ATTR_* . */
 
 	__OVS_ACTION_ATTR_MAX,	      /* Nothing past this will be accepted
 				       * from userspace. */
diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
index 1584040..d73be5c 100644
--- a/net/openvswitch/Kconfig
+++ b/net/openvswitch/Kconfig
@@ -31,6 +31,17 @@ config OPENVSWITCH
 
 	  If unsure, say N.
 
+config OPENVSWITCH_CONNTRACK
+	bool "Open vSwitch conntrack action support"
+	depends on OPENVSWITCH
+	depends on NF_CONNTRACK
+	default OPENVSWITCH
+	---help---
+	  If you say Y here, then Open vSwitch module will be able to pass
+	  packets through conntrack.
+
+	  Say N to exclude this support and reduce the binary size.
+
 config OPENVSWITCH_GRE
 	tristate "Open vSwitch GRE tunneling support"
 	depends on OPENVSWITCH
diff --git a/net/openvswitch/Makefile b/net/openvswitch/Makefile
index 6e1701d..5b5913b 100644
--- a/net/openvswitch/Makefile
+++ b/net/openvswitch/Makefile
@@ -15,6 +15,8 @@ openvswitch-y := \
 	vport-internal_dev.o \
 	vport-netdev.o
 
+openvswitch-$(CONFIG_OPENVSWITCH_CONNTRACK) += conntrack.o
+
 obj-$(CONFIG_OPENVSWITCH_VXLAN)+= vport-vxlan.o
 obj-$(CONFIG_OPENVSWITCH_GENEVE)+= vport-geneve.o
 obj-$(CONFIG_OPENVSWITCH_GRE)	+= vport-gre.o
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index e50678d..718b223 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -22,6 +22,7 @@
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/openvswitch.h>
+#include <linux/netfilter_ipv6.h>
 #include <linux/sctp.h>
 #include <linux/tcp.h>
 #include <linux/udp.h>
@@ -29,6 +30,7 @@
 #include <linux/if_arp.h>
 #include <linux/if_vlan.h>
 
+#include <net/dst.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
 #include <net/checksum.h>
@@ -38,6 +40,7 @@
 
 #include "datapath.h"
 #include "flow.h"
+#include "conntrack.h"
 #include "vport.h"
 
 static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
@@ -52,6 +55,17 @@ struct deferred_action {
 	struct sw_flow_key pkt_key;
 };
 
+#define MAX_L2_LEN 32
+struct ovs_frag_data {
+	unsigned long dst;
+	struct vport *vport;
+	struct ovs_skb_cb cb;
+	unsigned int l2_len;
+	u8 l2_data[MAX_L2_LEN];
+};
+
+static DEFINE_PER_CPU(struct ovs_frag_data, ovs_frag_data_storage);
+
 #define DEFERRED_ACTION_FIFO_SIZE 10
 struct action_fifo {
 	int head;
@@ -594,14 +608,132 @@ static int set_sctp(struct sk_buff *skb, struct sw_flow_key *flow_key,
 	return 0;
 }
 
-static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port)
+static int ovs_vport_output(struct sock *sock, struct sk_buff *skb)
+{
+	struct ovs_frag_data *data = this_cpu_ptr(&ovs_frag_data_storage);
+	struct vport *vport = data->vport;
+
+	if (skb_cow_head(skb, data->l2_len) < 0)
+		return -ENOMEM;
+
+	skb->_skb_refdst = data->dst;
+	*OVS_CB(skb) = data->cb;
+
+	/* Reconstruct the MAC header.  */
+	skb_push(skb, data->l2_len);
+	memcpy(skb->data, &data->l2_data, data->l2_len);
+	skb_reset_mac_header(skb);
+	skb->protocol = eth_hdr(skb)->h_proto;
+	skb->vlan_tci = 0;
+
+	ovs_vport_send(vport, skb);
+	return 0;
+}
+
+unsigned int
+ovs_dst_get_mtu(const struct dst_entry *dst)
+{
+	return dst->dev->mtu;
+}
+
+static struct dst_ops ovs_dst_ops = {
+	.family = AF_UNSPEC,
+	.mtu = ovs_dst_get_mtu,
+};
+
+/* prepare_frag() is called once per (larger-than-MTU) frame; its inverse is
+ * ovs_vport_output(), which is called once per fragmented packet.
+ */
+static void prepare_frag(struct vport *vport, struct sk_buff *skb)
+{
+	unsigned int hlen = skb_network_offset(skb);
+	struct ovs_frag_data *data;
+
+	data = this_cpu_ptr(&ovs_frag_data_storage);
+	data->dst = skb->_skb_refdst & SKB_DST_NOREF;
+	data->vport = vport;
+	data->cb = *OVS_CB(skb);
+	data->l2_len = hlen;
+	memcpy(&data->l2_data, skb->data, hlen);
+
+	memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
+	skb_pull(skb, hlen);
+}
+
+static void ovs_fragment(struct vport *vport, struct sk_buff *skb,
+			 unsigned int mru, __be16 ethertype)
+{
+	if (skb_network_offset(skb) > MAX_L2_LEN) {
+		OVS_NLERR(1, "L2 header too long to fragment");
+		return;
+	}
+
+	if (ethertype == htons(ETH_P_IP)) {
+		struct dst_entry ovs_dst;
+
+		prepare_frag(vport, skb);
+		dst_init(&ovs_dst, &ovs_dst_ops, NULL, 1,
+			 DST_OBSOLETE_NONE, DST_NOCOUNT);
+		ovs_dst.dev = vport->dev;
+
+		skb_dst_set_noref(skb, &ovs_dst);
+		IPCB(skb)->frag_max_size = mru;
+
+		ip_do_fragment(skb->sk, skb, ovs_vport_output);
+	} else if (ethertype == htons(ETH_P_IPV6)) {
+		const struct nf_ipv6_ops *v6ops = nf_get_ipv6_ops();
+		struct rt6_info ovs_rt;
+
+		if (!v6ops) {
+			kfree_skb(skb);
+			return;
+		}
+
+		prepare_frag(vport, skb);
+		memset(&ovs_rt, 0, sizeof(ovs_rt));
+		dst_init(&ovs_rt.dst, &ovs_dst_ops, NULL, 1,
+			 DST_OBSOLETE_NONE, DST_NOCOUNT);
+		ovs_rt.dst.dev = vport->dev;
+
+		skb_dst_set_noref(skb, &ovs_rt.dst);
+		IP6CB(skb)->frag_max_size = mru;
+
+		v6ops->fragment(skb->sk, skb, ovs_vport_output);
+	} else {
+		WARN_ONCE(1, "Failed fragment ->%s: eth=%04x, MRU=%d, MTU=%d.",
+			  ovs_vport_name(vport), htons(ethertype), mru,
+			  vport->dev->mtu);
+		kfree_skb(skb);
+	}
+}
+
+static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port,
+		      struct sw_flow_key *key)
 {
 	struct vport *vport = ovs_vport_rcu(dp, out_port);
 
-	if (likely(vport))
-		ovs_vport_send(vport, skb);
-	else
+	if (likely(vport)) {
+		unsigned int mru = OVS_CB(skb)->mru;
+
+		if (likely(!mru || (skb->len <= mru + ETH_HLEN))) {
+			ovs_vport_send(vport, skb);
+		} else if (mru <= vport->dev->mtu) {
+			__be16 ethertype = key->eth.type;
+
+			if (!is_flow_key_valid(key)) {
+				if (eth_p_mpls(skb->protocol))
+					ethertype = skb->inner_protocol;
+				else
+					ethertype = vlan_get_protocol(skb);
+			}
+
+			ovs_fragment(vport, skb, mru, ethertype);
+		} else {
+			kfree_skb(skb);
+		}
+	} else {
 		kfree_skb(skb);
+	}
 }
 
 static int output_userspace(struct datapath *dp, struct sk_buff *skb,
@@ -615,6 +747,7 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
 
 	memset(&upcall, 0, sizeof(upcall));
 	upcall.cmd = OVS_PACKET_CMD_ACTION;
+	upcall.mru = OVS_CB(skb)->mru;
 
 	for (a = nla_data(attr), rem = nla_len(attr); rem > 0;
 		 a = nla_next(a, &rem)) {
@@ -874,7 +1007,7 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			struct sk_buff *out_skb = skb_clone(skb, GFP_ATOMIC);
 
 			if (out_skb)
-				do_output(dp, out_skb, prev_port);
+				do_output(dp, out_skb, prev_port, key);
 
 			prev_port = -1;
 		}
@@ -931,6 +1064,15 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 		case OVS_ACTION_ATTR_SAMPLE:
 			err = sample(dp, skb, key, a, attr, len);
 			break;
+
+		case OVS_ACTION_ATTR_CT:
+			err = ovs_ct_execute(ovs_dp_get_net(dp), skb, key,
+					     nla_data(a));
+
+			/* Hide stolen IP fragments from user space. */
+			if (err == -EINPROGRESS)
+				return 0;
+			break;
 		}
 
 		if (unlikely(err)) {
@@ -940,7 +1082,7 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 	}
 
 	if (prev_port != -1)
-		do_output(dp, skb, prev_port);
+		do_output(dp, skb, prev_port, key);
 	else
 		consume_skb(skb);
 
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
new file mode 100644
index 0000000..586ce66
--- /dev/null
+++ b/net/openvswitch/conntrack.c
@@ -0,0 +1,475 @@
+/*
+ * Copyright (c) 2015 Nicira, Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ */
+
+#include <linux/module.h>
+#include <linux/openvswitch.h>
+#include <net/ip.h>
+#include <net/netfilter/nf_conntrack_core.h>
+#include <net/netfilter/nf_conntrack_zones.h>
+#include <net/netfilter/ipv6/nf_defrag_ipv6.h>
+
+#include "datapath.h"
+#include "conntrack.h"
+#include "flow.h"
+#include "flow_netlink.h"
+
+struct ovs_ct_len_tbl {
+	size_t maxlen;
+	size_t minlen;
+};
+
+struct ovs_conntrack_info {
+	struct nf_conn *ct;
+	u32 flags;
+	u16 zone;
+	u16 family;
+};
+
+static u16 key_to_nfproto(const struct sw_flow_key *key)
+{
+	switch (ntohs(key->eth.type)) {
+	case ETH_P_IP:
+		return NFPROTO_IPV4;
+	case ETH_P_IPV6:
+		return NFPROTO_IPV6;
+	default:
+		return NFPROTO_UNSPEC;
+	}
+}
+
+/* Map SKB connection state into the values used by flow definition. */
+static u8 __ovs_ct_get_state(enum ip_conntrack_info ctinfo)
+{
+	u8 cstate = OVS_CS_F_TRACKED;
+
+	switch (ctinfo) {
+	case IP_CT_ESTABLISHED_REPLY:
+	case IP_CT_RELATED_REPLY:
+	case IP_CT_NEW_REPLY:
+		cstate |= OVS_CS_F_REPLY_DIR;
+		break;
+	default:
+		break;
+	}
+
+	switch (ctinfo) {
+	case IP_CT_ESTABLISHED:
+	case IP_CT_ESTABLISHED_REPLY:
+		cstate |= OVS_CS_F_ESTABLISHED;
+		break;
+	case IP_CT_RELATED:
+	case IP_CT_RELATED_REPLY:
+		cstate |= OVS_CS_F_RELATED;
+		break;
+	case IP_CT_NEW:
+	case IP_CT_NEW_REPLY:
+		cstate |= OVS_CS_F_NEW;
+		break;
+	default:
+		break;
+	}
+
+	return cstate;
+}
+
+u8 ovs_ct_get_state(const struct sk_buff *skb)
+{
+	enum ip_conntrack_info ctinfo;
+
+	if (!nf_ct_get(skb, &ctinfo))
+		return 0;
+	return __ovs_ct_get_state(ctinfo);
+}
+
+u16 ovs_ct_get_zone(const struct sk_buff *skb)
+{
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct;
+
+	ct = nf_ct_get(skb, &ctinfo);
+
+	return ct ? nf_ct_zone(ct) : NF_CT_DEFAULT_ZONE;
+}
+
+static bool __ovs_ct_state_valid(u8 state)
+{
+	return (state && !(state & OVS_CS_F_INVALID));
+}
+
+bool ovs_ct_state_valid(const struct sw_flow_key *key)
+{
+	return __ovs_ct_state_valid(key->ct.state);
+}
+
+static int handle_fragments(struct net *net, struct sw_flow_key *key,
+			    u16 zone, struct sk_buff *skb)
+{
+	struct ovs_skb_cb ovs_cb = *OVS_CB(skb);
+
+	if (key->eth.type == htons(ETH_P_IP)) {
+		enum ip_defrag_users user = IP_DEFRAG_CONNTRACK_IN + zone;
+		int err;
+
+		memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
+		err = ip_defrag(skb, user);
+		if (err)
+			return err;
+
+		ovs_cb.mru = IPCB(skb)->frag_max_size;
+	} else if (key->eth.type == htons(ETH_P_IPV6)) {
+#if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
+		enum ip6_defrag_users user = IP6_DEFRAG_CONNTRACK_IN + zone;
+		struct sk_buff *reasm;
+
+		memset(IP6CB(skb), 0, sizeof(struct inet6_skb_parm));
+		reasm = nf_ct_frag6_gather(skb, user);
+		if (!reasm)
+			return -EINPROGRESS;
+
+		if (skb == reasm)
+			return -EINVAL;
+
+		key->ip.proto = ipv6_hdr(reasm)->nexthdr;
+		skb_morph(skb, reasm);
+		consume_skb(reasm);
+		ovs_cb.mru = IP6CB(skb)->frag_max_size;
+#else
+		return -EPFNOSUPPORT;
+#endif
+	} else {
+		return -EPFNOSUPPORT;
+	}
+
+	key->ip.frag = OVS_FRAG_TYPE_NONE;
+	skb_clear_hash(skb);
+	skb->ignore_df = 1;
+	*OVS_CB(skb) = ovs_cb;
+
+	return 0;
+}
+
+static struct nf_conntrack_expect *
+ovs_ct_expect_find(struct net *net, u16 zone, u16 proto,
+		   const struct sk_buff *skb)
+{
+	struct nf_conntrack_tuple tuple;
+
+	if (!nf_ct_get_tuplepr(skb, skb_network_offset(skb), proto, &tuple))
+		return NULL;
+	return __nf_ct_expect_find(net, zone, &tuple);
+}
+
+/* Determine whether skb->nfct is equal to the result of conntrack lookup. */
+static bool skb_nfct_cached(const struct net *net, const struct sk_buff *skb,
+			    const struct ovs_conntrack_info *info)
+{
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct;
+
+	ct = nf_ct_get(skb, &ctinfo);
+	if (!ct)
+		return false;
+	if (!net_eq(net, read_pnet(&ct->ct_net)))
+		return false;
+	if (info->zone != nf_ct_zone(ct))
+		return false;
+
+	return true;
+}
+
+static void __ovs_ct_update_key(struct sk_buff *skb, struct sw_flow_key *key,
+				u8 state, u16 zone)
+{
+	key->ct.state = state;
+	key->ct.zone = zone;
+}
+
+static void ovs_ct_update_key(struct sk_buff *skb, struct sw_flow_key *key,
+			      u16 zone)
+{
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct;
+	u8 state;
+
+	ct = nf_ct_get(skb, &ctinfo);
+	if (ct) {
+		state = __ovs_ct_get_state(ctinfo);
+		zone = nf_ct_zone(ct);
+		if (ct->master)
+			state |= OVS_CS_F_RELATED;
+	} else {
+		state = OVS_CS_F_TRACKED | OVS_CS_F_INVALID;
+	}
+
+	__ovs_ct_update_key(skb, key, state, zone);
+}
+
+static int __ovs_ct_lookup(struct net *net, const struct sw_flow_key *key,
+			   const struct ovs_conntrack_info *info,
+			   struct sk_buff *skb)
+{
+	/* If we are recirculating packets to match on conntrack fields and
+	 * committing with a separate conntrack action,  then we don't need to
+	 * actually run the packet through conntrack twice unless it's for a
+	 * different zone.
+	 */
+	if (!skb_nfct_cached(net, skb, info)) {
+		struct nf_conn *tmpl = info->ct;
+
+		/* Associate skb with specified zone. */
+		if (tmpl) {
+			if (skb->nfct)
+				nf_conntrack_put(skb->nfct);
+			nf_conntrack_get(&tmpl->ct_general);
+			skb->nfct = &tmpl->ct_general;
+			skb->nfctinfo = IP_CT_NEW;
+		}
+
+		if (nf_conntrack_in(net, info->family, NF_INET_PRE_ROUTING,
+				    skb) != NF_ACCEPT)
+			return -ENOENT;
+	}
+
+	return 0;
+}
+
+/* Lookup connection and read fields into key. */
+static int ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
+			 const struct ovs_conntrack_info *info,
+			 struct sk_buff *skb)
+{
+	struct nf_conntrack_expect *exp;
+
+	exp = ovs_ct_expect_find(net, info->zone, info->family, skb);
+	if (exp) {
+		u8 state;
+
+		state = OVS_CS_F_TRACKED | OVS_CS_F_NEW | OVS_CS_F_RELATED;
+		__ovs_ct_update_key(skb, key, state, info->zone);
+	} else {
+		int err;
+
+		err = __ovs_ct_lookup(net, key, info, skb);
+		if (err)
+			return err;
+
+		ovs_ct_update_key(skb, key, info->zone);
+	}
+
+	return 0;
+}
+
+/* Lookup connection and confirm if unconfirmed. */
+static int ovs_ct_commit(struct net *net, struct sw_flow_key *key,
+			 const struct ovs_conntrack_info *info,
+			 struct sk_buff *skb)
+{
+	u8 state;
+	int err;
+
+	state = key->ct.state;
+	if (key->ct.zone == info->zone &&
+	    ((state & OVS_CS_F_TRACKED) && !(state & OVS_CS_F_NEW))) {
+		/* Previous lookup has shown that this connection is already
+		 * tracked and committed. Skip committing.
+		 */
+		return 0;
+	}
+
+	err = __ovs_ct_lookup(net, key, info, skb);
+	if (err)
+		return err;
+	if (nf_conntrack_confirm(skb) != NF_ACCEPT)
+		return -EINVAL;
+
+	ovs_ct_update_key(skb, key, info->zone);
+
+	return 0;
+}
+
+int ovs_ct_execute(struct net *net, struct sk_buff *skb,
+		   struct sw_flow_key *key,
+		   const struct ovs_conntrack_info *info)
+{
+	int nh_ofs;
+	int err;
+
+	/* The conntrack module expects to be working at L3. */
+	nh_ofs = skb_network_offset(skb);
+	skb_pull(skb, nh_ofs);
+
+	if (key->ip.frag != OVS_FRAG_TYPE_NONE) {
+		err = handle_fragments(net, key, info->zone, skb);
+		if (err)
+			return err;
+	}
+
+	if (info->flags & OVS_CT_F_COMMIT)
+		err = ovs_ct_commit(net, key, info, skb);
+	else
+		err = ovs_ct_lookup(net, key, info, skb);
+
+	skb_push(skb, nh_ofs);
+	return err;
+}
+
+static const struct ovs_ct_len_tbl ovs_ct_attr_lens[OVS_CT_ATTR_MAX + 1] = {
+	[OVS_CT_ATTR_FLAGS]	= { .minlen = sizeof(u32),
+				    .maxlen = sizeof(u32) },
+	[OVS_CT_ATTR_ZONE]	= { .minlen = sizeof(u16),
+				    .maxlen = sizeof(u16) },
+};
+
+static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
+		    bool log)
+{
+	struct nlattr *a;
+	int rem;
+
+	nla_for_each_nested(a, attr, rem) {
+		int type = nla_type(a);
+		int maxlen = ovs_ct_attr_lens[type].maxlen;
+		int minlen = ovs_ct_attr_lens[type].minlen;
+
+		if (type > OVS_CT_ATTR_MAX) {
+			OVS_NLERR(log,
+				  "Unknown conntrack attr (type=%d, max=%d)",
+				  type, OVS_CT_ATTR_MAX);
+			return -EINVAL;
+		}
+		if (nla_len(a) < minlen || nla_len(a) > maxlen) {
+			OVS_NLERR(log,
+				  "Conntrack attr type has unexpected length (type=%d, length=%d, expected=%d)",
+				  type, nla_len(a), maxlen);
+			return -EINVAL;
+		}
+
+		switch (type) {
+#ifdef CONFIG_NF_CONNTRACK_ZONES
+		case OVS_CT_ATTR_ZONE:
+			info->zone = nla_get_u16(a);
+			break;
+#endif
+		case OVS_CT_ATTR_FLAGS:
+			info->flags = nla_get_u32(a);
+			break;
+		default:
+			OVS_NLERR(log, "Unknown conntrack attr (%d)",
+				  type);
+			return -EINVAL;
+		}
+	}
+
+	if (rem > 0) {
+		OVS_NLERR(log, "Conntrack attr has %d unknown bytes", rem);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+bool ovs_ct_verify(enum ovs_key_attr attr)
+{
+	if (attr & OVS_KEY_ATTR_CT_STATE)
+		return true;
+#ifdef CONFIG_NF_CONNTRACK_ZONES
+	if (attr & OVS_KEY_ATTR_CT_ZONE)
+		return true;
+#endif
+
+	return false;
+}
+
+int ovs_ct_copy_action(struct net *net, const struct nlattr *attr,
+		       const struct sw_flow_key *key,
+		       struct sw_flow_actions **sfa,  bool log)
+{
+	struct ovs_conntrack_info ct_info;
+	u16 family;
+	int err;
+
+	family = key_to_nfproto(key);
+	if (family == NFPROTO_UNSPEC) {
+		OVS_NLERR(log, "ct family unspecified");
+		return -EINVAL;
+	}
+
+	memset(&ct_info, 0, sizeof(ct_info));
+	ct_info.family = family;
+
+	err = parse_ct(attr, &ct_info, log);
+	if (err)
+		return err;
+
+	/* Set up template for tracking connections in specific zones. */
+	ct_info.ct = nf_ct_tmpl_alloc(net, ct_info.zone, GFP_KERNEL);
+	if (!ct_info.ct) {
+		OVS_NLERR(log, "Failed to allocate conntrack template");
+		return -ENOMEM;
+	}
+
+	err = ovs_nla_add_action(sfa, OVS_ACTION_ATTR_CT, &ct_info,
+				 sizeof(ct_info), log);
+	if (err)
+		goto err_free_ct;
+
+	__set_bit(IPS_CONFIRMED_BIT, &ct_info.ct->status);
+	nf_conntrack_get(&ct_info.ct->ct_general);
+	return 0;
+err_free_ct:
+	nf_conntrack_free(ct_info.ct);
+	return err;
+}
+
+int ovs_ct_action_to_attr(const struct ovs_conntrack_info *ct_info,
+			  struct sk_buff *skb)
+{
+	struct nlattr *start;
+
+	start = nla_nest_start(skb, OVS_ACTION_ATTR_CT);
+	if (!start)
+		return -EMSGSIZE;
+
+	if (nla_put_u32(skb, OVS_CT_ATTR_FLAGS, ct_info->flags))
+		return -EMSGSIZE;
+#ifdef CONFIG_NF_CONNTRACK_ZONES
+	if (nla_put_u16(skb, OVS_CT_ATTR_ZONE, ct_info->zone))
+		return -EMSGSIZE;
+#endif
+
+	nla_nest_end(skb, start);
+
+	return 0;
+}
+
+void ovs_ct_free_action(const struct nlattr *a)
+{
+	struct ovs_conntrack_info *ct_info = nla_data(a);
+
+	if (ct_info->ct)
+		nf_ct_put(ct_info->ct);
+}
+
+void ovs_ct_init(struct net *net, struct ovs_ct_perdp_data *data)
+{
+	data->xt_v4 = !nf_ct_l3proto_try_module_get(PF_INET);
+	data->xt_v6 = !nf_ct_l3proto_try_module_get(PF_INET6);
+}
+
+void ovs_ct_exit(struct net *net, struct ovs_ct_perdp_data *data)
+{
+	if (data->xt_v4)
+		nf_ct_l3proto_module_put(PF_INET);
+	if (data->xt_v6)
+		nf_ct_l3proto_module_put(PF_INET6);
+}
diff --git a/net/openvswitch/conntrack.h b/net/openvswitch/conntrack.h
new file mode 100644
index 0000000..0e09a6d
--- /dev/null
+++ b/net/openvswitch/conntrack.h
@@ -0,0 +1,97 @@
+/*
+ * Copyright (c) 2015 Nicira, Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ */
+
+#ifndef OVS_CONNTRACK_H
+#define OVS_CONNTRACK_H 1
+
+struct sw_flow_key;
+struct sw_flow_actions;
+struct ovs_conntrack_info;
+struct ovs_key_ct_label;
+enum ovs_key_attr;
+
+struct ovs_ct_perdp_data {
+	bool xt_v4;
+	bool xt_v6;
+};
+
+#if defined(CONFIG_OPENVSWITCH_CONNTRACK)
+void ovs_ct_init(struct net *, struct ovs_ct_perdp_data *data);
+void ovs_ct_exit(struct net *, struct ovs_ct_perdp_data *data);
+bool ovs_ct_verify(enum ovs_key_attr attr);
+int ovs_ct_copy_action(struct net *, const struct nlattr *,
+		       const struct sw_flow_key *, struct sw_flow_actions **,
+		       bool log);
+int ovs_ct_action_to_attr(const struct ovs_conntrack_info *, struct sk_buff *);
+
+int ovs_ct_execute(struct net *, struct sk_buff *, struct sw_flow_key *,
+		   const struct ovs_conntrack_info *);
+
+u8 ovs_ct_get_state(const struct sk_buff *skb);
+u16 ovs_ct_get_zone(const struct sk_buff *skb);
+bool ovs_ct_state_valid(const struct sw_flow_key *key);
+void ovs_ct_free_action(const struct nlattr *a);
+#else
+#include <linux/errno.h>
+
+static inline void ovs_ct_init(struct net *net, struct ovs_ct_perdp_data *data)
+{
+}
+
+static inline void ovs_ct_exit(struct net *net, struct ovs_ct_perdp_data *data)
+{
+}
+
+static inline bool ovs_ct_verify(int attr)
+{
+	return false;
+}
+
+static inline int ovs_ct_copy_action(struct net *net, const struct nlattr *nla,
+				     const struct sw_flow_key *key,
+				     struct sw_flow_actions **acts, bool log)
+{
+	return -ENOTSUPP;
+}
+
+static inline int ovs_ct_action_to_attr(const struct ovs_conntrack_info *info,
+					struct sk_buff *skb)
+{
+	return -ENOTSUPP;
+}
+
+static inline int ovs_ct_execute(struct net *net, struct sk_buff *skb,
+				 struct sw_flow_key *key,
+				 const struct ovs_conntrack_info *info)
+{
+	return -ENOTSUPP;
+}
+
+static inline u8 ovs_ct_get_state(const struct sk_buff *skb)
+{
+	return 0;
+}
+
+static inline u16 ovs_ct_get_zone(const struct sk_buff *skb)
+{
+	return 0;
+}
+
+static inline bool ovs_ct_state_valid(const struct sw_flow_key *key)
+{
+	return false;
+}
+
+static inline void ovs_ct_free_action(const struct nlattr *a) { }
+#endif
+#endif /* ovs_conntrack.h */
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index d5b5473..fa8eadc 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -275,6 +275,7 @@ void ovs_dp_process_packet(struct sk_buff *skb, struct sw_flow_key *key)
 		memset(&upcall, 0, sizeof(upcall));
 		upcall.cmd = OVS_PACKET_CMD_MISS;
 		upcall.portid = ovs_vport_find_upcall_portid(p, skb);
+		upcall.mru = OVS_CB(skb)->mru;
 		error = ovs_dp_upcall(dp, skb, key, &upcall);
 		if (unlikely(error))
 			kfree_skb(skb);
@@ -400,9 +401,23 @@ static size_t upcall_msg_size(const struct dp_upcall_info *upcall_info,
 	if (upcall_info->actions_len)
 		size += nla_total_size(upcall_info->actions_len);
 
+	/* OVS_PACKET_ATTR_MRU */
+	if (upcall_info->mru)
+		size += nla_total_size(sizeof(unsigned int));
+
 	return size;
 }
 
+static void pad_packet(struct datapath *dp, struct sk_buff *skb)
+{
+	if (!(dp->user_features & OVS_DP_F_UNALIGNED)) {
+		size_t plen = NLA_ALIGN(skb->len) - skb->len;
+
+		if (plen > 0)
+			memset(skb_put(skb, plen), 0, plen);
+	}
+}
+
 static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 				  const struct sw_flow_key *key,
 				  const struct dp_upcall_info *upcall_info)
@@ -492,6 +507,16 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 			nla_nest_cancel(user_skb, nla);
 	}
 
+	/* Add OVS_PACKET_ATTR_MRU */
+	if (upcall_info->mru) {
+		if (nla_put_u16(user_skb, OVS_PACKET_ATTR_MRU,
+				upcall_info->mru)) {
+			err = -ENOBUFS;
+			goto out;
+		}
+		pad_packet(dp, user_skb);
+	}
+
 	/* Only reserve room for attribute header, packet data is added
 	 * in skb_zerocopy() */
 	if (!(nla = nla_reserve(user_skb, OVS_PACKET_ATTR_PACKET, 0))) {
@@ -505,12 +530,7 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 		goto out;
 
 	/* Pad OVS_PACKET_ATTR_PACKET if linear copy was performed */
-	if (!(dp->user_features & OVS_DP_F_UNALIGNED)) {
-		size_t plen = NLA_ALIGN(user_skb->len) - user_skb->len;
-
-		if (plen > 0)
-			memset(skb_put(user_skb, plen), 0, plen);
-	}
+	pad_packet(dp, user_skb);
 
 	((struct nlmsghdr *) user_skb->data)->nlmsg_len = user_skb->len;
 
@@ -527,6 +547,7 @@ out:
 static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 {
 	struct ovs_header *ovs_header = info->userhdr;
+	struct net *net = sock_net(skb->sk);
 	struct nlattr **a = info->attrs;
 	struct sw_flow_actions *acts;
 	struct sk_buff *packet;
@@ -538,6 +559,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	int len;
 	int err;
 	bool log = !a[OVS_PACKET_ATTR_PROBE];
+	unsigned int mru;
 
 	err = -EINVAL;
 	if (!a[OVS_PACKET_ATTR_PACKET] || !a[OVS_PACKET_ATTR_KEY] ||
@@ -564,6 +586,14 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	else
 		packet->protocol = htons(ETH_P_802_2);
 
+	/* Set packet's mru */
+	mru = 0;
+	if (a[OVS_PACKET_ATTR_MRU]) {
+		mru = nla_get_u16(a[OVS_PACKET_ATTR_MRU]);
+		packet->ignore_df = 1;
+	}
+	OVS_CB(packet)->mru = mru;
+
 	/* Build an sw_flow for sending this packet. */
 	flow = ovs_flow_alloc();
 	err = PTR_ERR(flow);
@@ -575,7 +605,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	if (err)
 		goto err_flow_free;
 
-	err = ovs_nla_copy_actions(a[OVS_PACKET_ATTR_ACTIONS],
+	err = ovs_nla_copy_actions(net, a[OVS_PACKET_ATTR_ACTIONS],
 				   &flow->key, &acts, log);
 	if (err)
 		goto err_flow_free;
@@ -586,7 +616,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	packet->mark = flow->key.phy.skb_mark;
 
 	rcu_read_lock();
-	dp = get_dp_rcu(sock_net(skb->sk), ovs_header->dp_ifindex);
+	dp = get_dp_rcu(net, ovs_header->dp_ifindex);
 	err = -ENODEV;
 	if (!dp)
 		goto err_unlock;
@@ -598,6 +628,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	if (!input_vport)
 		goto err_unlock;
 
+	packet->dev = input_vport->dev;
 	OVS_CB(packet)->input_vport = input_vport;
 	sf_acts = rcu_dereference(flow->sf_acts);
 
@@ -624,6 +655,7 @@ static const struct nla_policy packet_policy[OVS_PACKET_ATTR_MAX + 1] = {
 	[OVS_PACKET_ATTR_KEY] = { .type = NLA_NESTED },
 	[OVS_PACKET_ATTR_ACTIONS] = { .type = NLA_NESTED },
 	[OVS_PACKET_ATTR_PROBE] = { .type = NLA_FLAG },
+	[OVS_PACKET_ATTR_MRU] = { .type = NLA_U16 },
 };
 
 static const struct genl_ops dp_packet_genl_ops[] = {
@@ -880,6 +912,7 @@ static struct sk_buff *ovs_flow_cmd_build_info(const struct sw_flow *flow,
 
 static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 {
+	struct net *net = sock_net(skb->sk);
 	struct nlattr **a = info->attrs;
 	struct ovs_header *ovs_header = info->userhdr;
 	struct sw_flow *flow = NULL, *new_flow;
@@ -929,8 +962,8 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		goto err_kfree_flow;
 
 	/* Validate actions. */
-	error = ovs_nla_copy_actions(a[OVS_FLOW_ATTR_ACTIONS], &new_flow->key,
-				     &acts, log);
+	error = ovs_nla_copy_actions(net, a[OVS_FLOW_ATTR_ACTIONS],
+				     &new_flow->key, &acts, log);
 	if (error) {
 		OVS_NLERR(log, "Flow actions may not be safe on all matching packets.");
 		goto err_kfree_flow;
@@ -944,7 +977,7 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	}
 
 	ovs_lock();
-	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
+	dp = get_dp(net, ovs_header->dp_ifindex);
 	if (unlikely(!dp)) {
 		error = -ENODEV;
 		goto err_unlock_ovs;
@@ -1038,7 +1071,8 @@ error:
 }
 
 /* Factor out action copy to avoid "Wframe-larger-than=1024" warning. */
-static struct sw_flow_actions *get_flow_actions(const struct nlattr *a,
+static struct sw_flow_actions *get_flow_actions(struct net *net,
+						const struct nlattr *a,
 						const struct sw_flow_key *key,
 						const struct sw_flow_mask *mask,
 						bool log)
@@ -1048,7 +1082,7 @@ static struct sw_flow_actions *get_flow_actions(const struct nlattr *a,
 	int error;
 
 	ovs_flow_mask_key(&masked_key, key, mask);
-	error = ovs_nla_copy_actions(a, &masked_key, &acts, log);
+	error = ovs_nla_copy_actions(net, a, &masked_key, &acts, log);
 	if (error) {
 		OVS_NLERR(log,
 			  "Actions may not be safe on all matching packets");
@@ -1060,6 +1094,7 @@ static struct sw_flow_actions *get_flow_actions(const struct nlattr *a,
 
 static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 {
+	struct net *net = sock_net(skb->sk);
 	struct nlattr **a = info->attrs;
 	struct ovs_header *ovs_header = info->userhdr;
 	struct sw_flow_key key;
@@ -1091,8 +1126,8 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 
 	/* Validate actions. */
 	if (a[OVS_FLOW_ATTR_ACTIONS]) {
-		acts = get_flow_actions(a[OVS_FLOW_ATTR_ACTIONS], &key, &mask,
-					log);
+		acts = get_flow_actions(net, a[OVS_FLOW_ATTR_ACTIONS], &key,
+					&mask, log);
 		if (IS_ERR(acts)) {
 			error = PTR_ERR(acts);
 			goto error;
@@ -1108,7 +1143,7 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	}
 
 	ovs_lock();
-	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
+	dp = get_dp(net, ovs_header->dp_ifindex);
 	if (unlikely(!dp)) {
 		error = -ENODEV;
 		goto err_unlock_ovs;
@@ -1547,6 +1582,9 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 
 	ovs_dp_change(dp, a);
 
+	/* Set up conntrack dependencies. */
+	ovs_ct_init(ovs_dp_get_net(dp), &dp->ct);
+
 	/* So far only local changes have been made, now need the lock. */
 	ovs_lock();
 
@@ -1583,6 +1621,7 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 err_destroy_ports_array:
 	ovs_unlock();
 	kfree(dp->ports);
+	ovs_ct_exit(ovs_dp_get_net(dp), &dp->ct);
 err_destroy_percpu:
 	free_percpu(dp->stats_percpu);
 err_destroy_table:
@@ -1616,6 +1655,8 @@ static void __dp_destroy(struct datapath *dp)
 	 */
 	ovs_dp_detach_port(ovs_vport_ovsl(dp, OVSP_LOCAL));
 
+	ovs_ct_exit(ovs_dp_get_net(dp), &dp->ct);
+
 	/* RCU destroy the flow table */
 	call_rcu(&dp->rcu, destroy_dp_rcu);
 }
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 487a85f..fd8d146 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -27,6 +27,7 @@
 #include <linux/u64_stats_sync.h>
 #include <net/ip_tunnels.h>
 
+#include "conntrack.h"
 #include "flow.h"
 #include "flow_table.h"
 #include "vport.h"
@@ -89,6 +90,8 @@ struct datapath {
 	possible_net_t net;
 
 	u32 user_features;
+
+	struct ovs_ct_perdp_data ct;
 };
 
 /**
@@ -97,10 +100,13 @@ struct datapath {
  * NULL if the packet is not being tunneled.
  * @input_vport: The original vport packet came in on. This value is cached
  * when a packet is received by OVS.
+ * @mru: The maximum received fragement size; 0 if the packet is not
+ * fragmented.
  */
 struct ovs_skb_cb {
 	struct ip_tunnel_info  *egress_tun_info;
 	struct vport		*input_vport;
+	unsigned int		mru;
 };
 #define OVS_CB(skb) ((struct ovs_skb_cb *)(skb)->cb)
 
@@ -113,6 +119,7 @@ struct ovs_skb_cb {
  * then no packet is sent and the packet is accounted in the datapath's @n_lost
  * counter.
  * @egress_tun_info: If nonnull, becomes %OVS_PACKET_ATTR_EGRESS_TUN_KEY.
+ * @mru: If not zero, Maximum received IP fragment size.
  */
 struct dp_upcall_info {
 	const struct ip_tunnel_info *egress_tun_info;
@@ -121,6 +128,7 @@ struct dp_upcall_info {
 	int actions_len;
 	u32 portid;
 	u8 cmd;
+	unsigned int mru;
 };
 
 /**
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 8db22ef..131b807 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -49,6 +49,7 @@
 #include "datapath.h"
 #include "flow.h"
 #include "flow_netlink.h"
+#include "conntrack.h"
 
 u64 ovs_flow_used_time(unsigned long flow_jiffies)
 {
@@ -707,6 +708,8 @@ int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
 	key->phy.priority = skb->priority;
 	key->phy.in_port = OVS_CB(skb)->input_vport->port_no;
 	key->phy.skb_mark = skb->mark;
+	key->ct.state = ovs_ct_get_state(skb);
+	key->ct.zone = ovs_ct_get_zone(skb);
 	key->ovs_flow_hash = 0;
 	key->recirc_id = 0;
 
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 082a87b..312c7d7 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -111,6 +111,12 @@ struct sw_flow_key {
 			} nd;
 		} ipv6;
 	};
+	struct {
+		/* Connection tracking fields. */
+		u16 zone;
+		u8 state;
+	} ct;
+
 } __aligned(BITS_PER_LONG/8); /* Ensure that we can do comparisons as longs. */
 
 struct sw_flow_key_range {
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index d536fb7..1b42310 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -281,7 +281,7 @@ size_t ovs_key_attr_size(void)
 	/* Whenever adding new OVS_KEY_ FIELDS, we should consider
 	 * updating this function.
 	 */
-	BUILD_BUG_ON(OVS_KEY_ATTR_TUNNEL_INFO != 22);
+	BUILD_BUG_ON(OVS_KEY_ATTR_TUNNEL_INFO != 24);
 
 	return    nla_total_size(4)   /* OVS_KEY_ATTR_PRIORITY */
 		+ nla_total_size(0)   /* OVS_KEY_ATTR_TUNNEL */
@@ -290,6 +290,8 @@ size_t ovs_key_attr_size(void)
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_SKB_MARK */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_DP_HASH */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_RECIRC_ID */
+		+ nla_total_size(1)   /* OVS_KEY_ATTR_CT_STATE */
+		+ nla_total_size(2)   /* OVS_KEY_ATTR_CT_ZONE */
 		+ nla_total_size(12)  /* OVS_KEY_ATTR_ETHERNET */
 		+ nla_total_size(2)   /* OVS_KEY_ATTR_ETHERTYPE */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_VLAN */
@@ -339,6 +341,8 @@ static const struct ovs_len_tbl ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
 	[OVS_KEY_ATTR_TUNNEL]	 = { .len = OVS_ATTR_NESTED,
 				     .next = ovs_tunnel_key_lens, },
 	[OVS_KEY_ATTR_MPLS]	 = { .len = sizeof(struct ovs_key_mpls) },
+	[OVS_KEY_ATTR_CT_STATE]	 = { .len = sizeof(u8) },
+	[OVS_KEY_ATTR_CT_ZONE]	 = { .len = sizeof(u16) },
 };
 
 static bool is_all_zero(const u8 *fp, size_t size)
@@ -768,6 +772,21 @@ static int metadata_from_nlattrs(struct sw_flow_match *match,  u64 *attrs,
 			return -EINVAL;
 		*attrs &= ~(1 << OVS_KEY_ATTR_TUNNEL);
 	}
+
+	if (*attrs & (1 << OVS_KEY_ATTR_CT_STATE) &&
+	    ovs_ct_verify(OVS_KEY_ATTR_CT_STATE)) {
+		u8 ct_state = nla_get_u8(a[OVS_KEY_ATTR_CT_STATE]);
+
+		SW_FLOW_KEY_PUT(match, ct.state, ct_state, is_mask);
+		*attrs &= ~(1ULL << OVS_KEY_ATTR_CT_STATE);
+	}
+	if (*attrs & (1 << OVS_KEY_ATTR_CT_ZONE) &&
+	    ovs_ct_verify(OVS_KEY_ATTR_CT_ZONE)) {
+		u16 ct_zone = nla_get_u16(a[OVS_KEY_ATTR_CT_ZONE]);
+
+		SW_FLOW_KEY_PUT(match, ct.zone, ct_zone, is_mask);
+		*attrs &= ~(1ULL << OVS_KEY_ATTR_CT_ZONE);
+	}
 	return 0;
 }
 
@@ -1266,6 +1285,7 @@ int ovs_nla_get_flow_metadata(const struct nlattr *attr,
 	memset(&match, 0, sizeof(match));
 	match.key = key;
 
+	memset(&key->ct, 0, sizeof(key->ct));
 	key->phy.in_port = DP_MAX_PORTS;
 
 	return metadata_from_nlattrs(&match, &attrs, a, false, log);
@@ -1314,6 +1334,12 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
 	if (nla_put_u32(skb, OVS_KEY_ATTR_SKB_MARK, output->phy.skb_mark))
 		goto nla_put_failure;
 
+	if (nla_put_u8(skb, OVS_KEY_ATTR_CT_STATE, output->ct.state))
+		goto nla_put_failure;
+
+	if (nla_put_u16(skb, OVS_KEY_ATTR_CT_ZONE, output->ct.zone))
+		goto nla_put_failure;
+
 	nla = nla_reserve(skb, OVS_KEY_ATTR_ETHERNET, sizeof(*eth_key));
 	if (!nla)
 		goto nla_put_failure;
@@ -1575,6 +1601,9 @@ void ovs_nla_free_flow_actions(struct sw_flow_actions *sf_acts)
 		case OVS_ACTION_ATTR_SET:
 			ovs_nla_free_set_action(a);
 			break;
+		case OVS_ACTION_ATTR_CT:
+			ovs_ct_free_action(a);
+			break;
 		}
 	}
 
@@ -1647,8 +1676,8 @@ static struct nlattr *__add_action(struct sw_flow_actions **sfa,
 	return a;
 }
 
-static int add_action(struct sw_flow_actions **sfa, int attrtype,
-		      void *data, int len, bool log)
+int ovs_nla_add_action(struct sw_flow_actions **sfa, int attrtype, void *data,
+		       int len, bool log)
 {
 	struct nlattr *a;
 
@@ -1663,7 +1692,7 @@ static inline int add_nested_action_start(struct sw_flow_actions **sfa,
 	int used = (*sfa)->actions_len;
 	int err;
 
-	err = add_action(sfa, attrtype, NULL, 0, log);
+	err = ovs_nla_add_action(sfa, attrtype, NULL, 0, log);
 	if (err)
 		return err;
 
@@ -1679,12 +1708,12 @@ static inline void add_nested_action_end(struct sw_flow_actions *sfa,
 	a->nla_len = sfa->actions_len - st_offset;
 }
 
-static int __ovs_nla_copy_actions(const struct nlattr *attr,
+static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 				  const struct sw_flow_key *key,
 				  int depth, struct sw_flow_actions **sfa,
 				  __be16 eth_type, __be16 vlan_tci, bool log);
 
-static int validate_and_copy_sample(const struct nlattr *attr,
+static int validate_and_copy_sample(struct net *net, const struct nlattr *attr,
 				    const struct sw_flow_key *key, int depth,
 				    struct sw_flow_actions **sfa,
 				    __be16 eth_type, __be16 vlan_tci, bool log)
@@ -1716,15 +1745,15 @@ static int validate_and_copy_sample(const struct nlattr *attr,
 	start = add_nested_action_start(sfa, OVS_ACTION_ATTR_SAMPLE, log);
 	if (start < 0)
 		return start;
-	err = add_action(sfa, OVS_SAMPLE_ATTR_PROBABILITY,
-			 nla_data(probability), sizeof(u32), log);
+	err = ovs_nla_add_action(sfa, OVS_SAMPLE_ATTR_PROBABILITY,
+				 nla_data(probability), sizeof(u32), log);
 	if (err)
 		return err;
 	st_acts = add_nested_action_start(sfa, OVS_SAMPLE_ATTR_ACTIONS, log);
 	if (st_acts < 0)
 		return st_acts;
 
-	err = __ovs_nla_copy_actions(actions, key, depth + 1, sfa,
+	err = __ovs_nla_copy_actions(net, actions, key, depth + 1, sfa,
 				     eth_type, vlan_tci, log);
 	if (err)
 		return err;
@@ -2058,7 +2087,7 @@ static int copy_action(const struct nlattr *from,
 	return 0;
 }
 
-static int __ovs_nla_copy_actions(const struct nlattr *attr,
+static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 				  const struct sw_flow_key *key,
 				  int depth, struct sw_flow_actions **sfa,
 				  __be16 eth_type, __be16 vlan_tci, bool log)
@@ -2082,7 +2111,8 @@ static int __ovs_nla_copy_actions(const struct nlattr *attr,
 			[OVS_ACTION_ATTR_SET] = (u32)-1,
 			[OVS_ACTION_ATTR_SET_MASKED] = (u32)-1,
 			[OVS_ACTION_ATTR_SAMPLE] = (u32)-1,
-			[OVS_ACTION_ATTR_HASH] = sizeof(struct ovs_action_hash)
+			[OVS_ACTION_ATTR_HASH] = sizeof(struct ovs_action_hash),
+			[OVS_ACTION_ATTR_CT] = (u32)-1,
 		};
 		const struct ovs_action_push_vlan *vlan;
 		int type = nla_type(a);
@@ -2189,13 +2219,20 @@ static int __ovs_nla_copy_actions(const struct nlattr *attr,
 			break;
 
 		case OVS_ACTION_ATTR_SAMPLE:
-			err = validate_and_copy_sample(a, key, depth, sfa,
+			err = validate_and_copy_sample(net, a, key, depth, sfa,
 						       eth_type, vlan_tci, log);
 			if (err)
 				return err;
 			skip_copy = true;
 			break;
 
+		case OVS_ACTION_ATTR_CT:
+			err = ovs_ct_copy_action(net, a, key, sfa, log);
+			if (err)
+				return err;
+			skip_copy = true;
+			break;
+
 		default:
 			OVS_NLERR(log, "Unknown Action type %d", type);
 			return -EINVAL;
@@ -2214,7 +2251,7 @@ static int __ovs_nla_copy_actions(const struct nlattr *attr,
 }
 
 /* 'key' must be the masked key. */
-int ovs_nla_copy_actions(const struct nlattr *attr,
+int ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 			 const struct sw_flow_key *key,
 			 struct sw_flow_actions **sfa, bool log)
 {
@@ -2224,7 +2261,7 @@ int ovs_nla_copy_actions(const struct nlattr *attr,
 	if (IS_ERR(*sfa))
 		return PTR_ERR(*sfa);
 
-	err = __ovs_nla_copy_actions(attr, key, 0, sfa, key->eth.type,
+	err = __ovs_nla_copy_actions(net, attr, key, 0, sfa, key->eth.type,
 				     key->eth.tci, log);
 	if (err)
 		ovs_nla_free_flow_actions(*sfa);
@@ -2349,6 +2386,13 @@ int ovs_nla_put_actions(const struct nlattr *attr, int len, struct sk_buff *skb)
 			if (err)
 				return err;
 			break;
+
+		case OVS_ACTION_ATTR_CT:
+			err = ovs_ct_action_to_attr(nla_data(a), skb);
+			if (err)
+				return err;
+			break;
+
 		default:
 			if (nla_put(skb, type, nla_len(a), nla_data(a)))
 				return -EMSGSIZE;
diff --git a/net/openvswitch/flow_netlink.h b/net/openvswitch/flow_netlink.h
index acd0744..c0b484b 100644
--- a/net/openvswitch/flow_netlink.h
+++ b/net/openvswitch/flow_netlink.h
@@ -62,9 +62,11 @@ int ovs_nla_get_identifier(struct sw_flow_id *sfid, const struct nlattr *ufid,
 			   const struct sw_flow_key *key, bool log);
 u32 ovs_nla_get_ufid_flags(const struct nlattr *attr);
 
-int ovs_nla_copy_actions(const struct nlattr *attr,
+int ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 			 const struct sw_flow_key *key,
 			 struct sw_flow_actions **sfa, bool log);
+int ovs_nla_add_action(struct sw_flow_actions **sfa, int attrtype,
+		       void *data, int len, bool log);
 int ovs_nla_put_actions(const struct nlattr *attr,
 			int len, struct sk_buff *skb);
 
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index d14f594..492357f 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -484,6 +484,7 @@ void ovs_vport_receive(struct vport *vport, struct sk_buff *skb,
 
 	OVS_CB(skb)->input_vport = vport;
 	OVS_CB(skb)->egress_tun_info = NULL;
+	OVS_CB(skb)->mru = 0;
 	/* Extract flow from 'skb' into 'key'. */
 	error = ovs_flow_key_extract(tun_info, skb, &key);
 	if (unlikely(error)) {
-- 
2.1.4
