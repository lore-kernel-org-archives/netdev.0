From: Yi Yang <yi.y.yang@intel.com>
Subject: [PATCH net-next v6 2/3] net: gso: Add GSO support for NSH
Date: Fri, 25 Aug 2017 22:20:04 +0800
Message-ID: <1503670805-31051-3-git-send-email-yi.y.yang@intel.com>
References: <1503670805-31051-1-git-send-email-yi.y.yang@intel.com>
Cc: dev@openvswitch.org, jbenc@redhat.com, e@erig.me, blp@ovn.org,
        jan.scheurich@ericsson.com, Yi Yang <yi.y.yang@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:51976 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932745AbdHYOYH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Aug 2017 10:24:07 -0400
In-Reply-To: <1503670805-31051-1-git-send-email-yi.y.yang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NSH (Network Service Header)[1] is a new protocol for service
function chaining, it can be handled as a L3 protocol like
IPv4 and IPv6, Eth + NSH + Inner packet or VxLAN-gpe + NSH +
Inner packet are two typical use cases.

We need to enbale Open vSwitch to support NSH, this patch
is to make Linux network infrastructure able to support
NSH GSO for big packet.

[1] https://datatracker.ietf.org/doc/draft-ietf-sfc-nsh/

Signed-off-by: Yi Yang <yi.y.yang@intel.com>
---
 include/linux/netdevice.h |   1 +
 include/linux/skbuff.h    |   8 +++-
 net/Kconfig               |   1 +
 net/Makefile              |   1 +
 net/core/dev.c            |  14 ++++++
 net/ipv4/udp_offload.c    |   7 +++
 net/nsh/Kconfig           |  11 +++++
 net/nsh/Makefile          |   4 ++
 net/nsh/nsh_gso.c         | 106 ++++++++++++++++++++++++++++++++++++++++++++++
 9 files changed, 151 insertions(+), 2 deletions(-)
 create mode 100644 net/nsh/Kconfig
 create mode 100644 net/nsh/Makefile
 create mode 100644 net/nsh/nsh_gso.c

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c5475b3..b017418 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3253,6 +3253,7 @@ struct sk_buff *napi_get_frags(struct napi_struct *napi);
 gro_result_t napi_gro_frags(struct napi_struct *napi);
 struct packet_offload *gro_find_receive_by_type(__be16 type);
 struct packet_offload *gro_find_complete_by_type(__be16 type);
+struct packet_offload *find_gso_segment_by_type(__be16 type);
 
 static inline void napi_free_frags(struct napi_struct *napi)
 {
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 7594e19..aafc8ff 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -766,7 +766,7 @@ struct sk_buff {
 	__u8			ndisc_nodetype:2;
 #endif
 	__u8			ipvs_property:1;
-	__u8			inner_protocol_type:1;
+	__u8			inner_protocol_type:2;
 	__u8			remcsum_offload:1;
 #ifdef CONFIG_NET_SWITCHDEV
 	__u8			offload_fwd_mark:1;
@@ -2174,12 +2174,16 @@ static inline void skb_tailroom_reserve(struct sk_buff *skb, unsigned int mtu,
 
 #define ENCAP_TYPE_ETHER	0
 #define ENCAP_TYPE_IPPROTO	1
+#define ENCAP_TYPE_NSH		2
 
 static inline void skb_set_inner_protocol(struct sk_buff *skb,
 					  __be16 protocol)
 {
 	skb->inner_protocol = protocol;
-	skb->inner_protocol_type = ENCAP_TYPE_ETHER;
+	if (skb->inner_protocol == htons(ETH_P_NSH))
+		skb->inner_protocol_type = ENCAP_TYPE_NSH;
+	else
+		skb->inner_protocol_type = ENCAP_TYPE_ETHER;
 }
 
 static inline void skb_set_inner_ipproto(struct sk_buff *skb,
diff --git a/net/Kconfig b/net/Kconfig
index 7d57ef3..818df7a 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -240,6 +240,7 @@ source "net/switchdev/Kconfig"
 source "net/l3mdev/Kconfig"
 source "net/qrtr/Kconfig"
 source "net/ncsi/Kconfig"
+source "net/nsh/Kconfig"
 
 config RPS
 	bool
diff --git a/net/Makefile b/net/Makefile
index bed80fa..82bfac6 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -85,3 +85,4 @@ obj-y				+= l3mdev/
 endif
 obj-$(CONFIG_QRTR)		+= qrtr/
 obj-$(CONFIG_NET_NCSI)		+= ncsi/
+obj-$(CONFIG_NET_NSH_GSO)		+= nsh/
diff --git a/net/core/dev.c b/net/core/dev.c
index 270b547..02a988d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4874,6 +4874,20 @@ struct packet_offload *gro_find_complete_by_type(__be16 type)
 }
 EXPORT_SYMBOL(gro_find_complete_by_type);
 
+struct packet_offload *find_gso_segment_by_type(__be16 type)
+{
+	struct list_head *offload_head = &offload_base;
+	struct packet_offload *ptype;
+
+	list_for_each_entry_rcu(ptype, offload_head, list) {
+		if (ptype->type != type || !ptype->callbacks.gso_segment)
+			continue;
+		return ptype;
+	}
+	return NULL;
+}
+EXPORT_SYMBOL(find_gso_segment_by_type);
+
 static void napi_skb_free_stolen_head(struct sk_buff *skb)
 {
 	skb_dst_drop(skb);
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 97658bf..31f9383 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -155,6 +155,7 @@ struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 	__be16 protocol = skb->protocol;
 	const struct net_offload **offloads;
 	const struct net_offload *ops;
+	const struct packet_offload *po;
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	struct sk_buff *(*gso_inner_segment)(struct sk_buff *skb,
 					     netdev_features_t features);
@@ -173,6 +174,12 @@ struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 			goto out_unlock;
 		gso_inner_segment = ops->callbacks.gso_segment;
 		break;
+	case ENCAP_TYPE_NSH:
+		protocol = skb->inner_protocol;
+		po = find_gso_segment_by_type(protocol);
+		if (!po || !po->callbacks.gso_segment)
+			goto out_unlock;
+		gso_inner_segment = po->callbacks.gso_segment;
 	default:
 		goto out_unlock;
 	}
diff --git a/net/nsh/Kconfig b/net/nsh/Kconfig
new file mode 100644
index 0000000..0157b26
--- /dev/null
+++ b/net/nsh/Kconfig
@@ -0,0 +1,11 @@
+#
+# NSH GSO support
+#
+
+config NET_NSH_GSO
+	bool "NSH GSO support"
+	depends on INET
+	default y
+	---help---
+	  This allows segmentation of GSO packet that have had NSH header
+	  pushed onto them and thus become NSH GSO packets.
diff --git a/net/nsh/Makefile b/net/nsh/Makefile
new file mode 100644
index 0000000..eb4bca0
--- /dev/null
+++ b/net/nsh/Makefile
@@ -0,0 +1,4 @@
+#
+# Makefile for NSH GSO.
+#
+obj-$(CONFIG_NET_NSH_GSO) += nsh_gso.o
diff --git a/net/nsh/nsh_gso.c b/net/nsh/nsh_gso.c
new file mode 100644
index 0000000..4b6fb29
--- /dev/null
+++ b/net/nsh/nsh_gso.c
@@ -0,0 +1,106 @@
+/*
+ *	NSH GSO Support
+ *
+ *	Authors: Yi Yang (yi.y.yang@intel.com)
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ *
+ *	Based on: net/mpls/mpls_gso.c
+ */
+
+#include <linux/err.h>
+#include <linux/netdev_features.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <net/protocol.h>
+#include <net/nsh.h>
+
+struct sk_buff *nsh_gso_segment(struct sk_buff *skb,
+				netdev_features_t features)
+{
+	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	int nshoff;
+	__be16 inner_proto;
+	struct nsh_hdr *nsh;
+	unsigned int nsh_hlen;
+	struct packet_offload *po;
+	struct sk_buff *(*gso_inner_segment)(struct sk_buff *skb,
+					     netdev_features_t features);
+
+	skb_reset_network_header(skb);
+	nshoff = skb_network_header(skb) - skb_mac_header(skb);
+
+	if (unlikely(!pskb_may_pull(skb, NSH_BASE_HDR_LEN)))
+		goto out;
+
+	nsh = (struct nsh_hdr *)skb_network_header(skb);
+	nsh_hlen = nsh_hdr_len(nsh);
+	if (unlikely(!pskb_may_pull(skb, nsh_hlen)))
+		goto out;
+
+	nsh = (struct nsh_hdr *)skb_network_header(skb);
+	__skb_pull(skb, nsh_hlen);
+
+	skb_reset_transport_header(skb);
+
+	switch (nsh->np) {
+	case NSH_P_ETHERNET:
+		inner_proto = htons(ETH_P_TEB);
+		gso_inner_segment = skb_mac_gso_segment;
+		break;
+	case NSH_P_IPV4:
+		inner_proto = htons(ETH_P_IP);
+		po = find_gso_segment_by_type(inner_proto);
+		if (!po || !po->callbacks.gso_segment)
+			goto out;
+		gso_inner_segment = po->callbacks.gso_segment;
+		break;
+	case NSH_P_IPV6:
+		inner_proto = htons(ETH_P_IPV6);
+		po = find_gso_segment_by_type(inner_proto);
+		if (!po || !po->callbacks.gso_segment)
+			goto out;
+		gso_inner_segment = po->callbacks.gso_segment;
+		break;
+	case NSH_P_NSH:
+		inner_proto = htons(ETH_P_NSH);
+		gso_inner_segment = nsh_gso_segment;
+		break;
+	default:
+		goto out;
+	}
+
+	segs = gso_inner_segment(skb, features);
+	if (IS_ERR_OR_NULL(segs))
+		goto out;
+
+	skb = segs;
+	do {
+		nsh = (struct nsh_hdr *)(skb_mac_header(skb) + nshoff);
+		skb->network_header = (u8 *)nsh - skb->head;
+	} while ((skb = skb->next));
+
+out:
+	return segs;
+}
+EXPORT_SYMBOL(nsh_gso_segment);
+
+static struct packet_offload nsh_offload __read_mostly = {
+	.type = cpu_to_be16(ETH_P_NSH),
+	.priority = 15,
+	.callbacks = {
+		.gso_segment    =	nsh_gso_segment,
+	},
+};
+
+static int __init nsh_gso_init(void)
+{
+	dev_add_offload(&nsh_offload);
+
+	return 0;
+}
+
+device_initcall(nsh_gso_init);
-- 
2.5.5
