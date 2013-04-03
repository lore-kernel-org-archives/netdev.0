From: Simon Horman <horms@verge.net.au>
Subject: [PATCH v2] MPLS: Add limited GSO support
Date: Wed,  3 Apr 2013 18:11:55 +0900
Message-ID: <1364980315-13649-1-git-send-email-horms@verge.net.au>
Cc: Jesse Gross <jesse@nicira.com>, jarno.rajahalme@nsn.com,
	Simon Horman <horms@verge.net.au>,
	Pravin B Shelar <pshelar@nicira.com>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:36428 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759772Ab3DCJMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 05:12:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the case where a non-MPLS packet is recieved and an MPLS stack is
added it may well be the case that the original skb is GSO but the
NIC used for transmit does not support GSO of MPLS packets.

The aim of this code is to provide GSO in software for MPLS packets
whose skbs are GSO.

When an implementation adds an MPLS stack to a non-MPLS packet it should do
the following to skb metadata:

* Set skb_mac_header(skb)->protocol to the new MPLS ethertype.
  That is, either ETH_P_MPLS_UC or ETH_P_MPLS_MC.

* Leave skb->protocol as the old non-MPLS ethertype.

* Set skb->encapsulation = 1.

  This may not strictly be necessary as I believe that checking
  skb_mac_header(skb)->protocol and skb->protocol should be necessary and
  sufficient.

  However, it does seem to fit nicely with the current implementation of
  dev_hard_start_xmit() where the more expensive check of
  skb_mac_header(skb)->protocol may be guarded by an existing check of
  skb->encapsulation.

One aspect of this patch that I am unsure about is the modification I have
made to skb_segment(). This seems to be necessary as checskum accelearation
may no longer be possible as the packet has changed to be MPLS from some
other packet type which may have been supported by the hardware in use.

I will post a patch, "[PATCH v3.24] datapath: Add basic MPLS support to
kernel" which adds MPLS support to the kernel datapath of Open vSwtich.
That patch sets the above requirements in
datapath/actions.c:set_ethertype() and was used to exercise the MPLS GSO
code. The datapath patch is against the Open vSwtich tree but it is
intended that it be added to the Open vSwtich code present in the mainline
Linux kernel at some point.

Suggested by Jesse Gross. Based heavily on "v4 GRE: Add TCP segmentation
offload for GRE" by Pravin B Shelar.

Cc: Jesse Gross <jesse@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

---

v2
* As suggested by Jarno Rajahalme
  - Update NETIF_F_GSO_LAST
  - mpls_mc_offload to use ETH_P_MPLS_MC
* Remove NETIF_F_iP_CSUM|NETIF_F_IPV6_CSUM features hack in
  mpls_gso_segment()
---
 include/linux/netdev_features.h |    4 +-
 include/linux/skbuff.h          |   15 +++--
 net/Kconfig                     |    1 +
 net/Makefile                    |    1 +
 net/core/dev.c                  |    9 ++-
 net/core/ethtool.c              |    1 +
 net/core/skbuff.c               |    3 +-
 net/ipv4/af_inet.c              |    1 +
 net/ipv4/tcp.c                  |    1 +
 net/ipv4/udp.c                  |    2 +-
 net/ipv6/ip6_offload.c          |    1 +
 net/ipv6/udp_offload.c          |    3 +-
 net/mpls/Kconfig                |    9 +++
 net/mpls/Makefile               |    4 ++
 net/mpls/mpls_gso.c             |  124 +++++++++++++++++++++++++++++++++++++++
 15 files changed, 170 insertions(+), 9 deletions(-)
 create mode 100644 net/mpls/Kconfig
 create mode 100644 net/mpls/Makefile
 create mode 100644 net/mpls/mpls_gso.c

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index d6ee2d0..340f5cd 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -43,8 +43,9 @@ enum {
 	NETIF_F_FSO_BIT,		/* ... FCoE segmentation */
 	NETIF_F_GSO_GRE_BIT,		/* ... GRE with TSO */
 	NETIF_F_GSO_UDP_TUNNEL_BIT,	/* ... UDP TUNNEL with TSO */
+	NETIF_F_GSO_MPLS_BIT,		/* ... MPLS segmentation */
 	/**/NETIF_F_GSO_LAST =		/* last bit, see GSO_MASK */
-		NETIF_F_GSO_UDP_TUNNEL_BIT,
+		NETIF_F_GSO_MPLS_BIT,
 
 	NETIF_F_FCOE_CRC_BIT,		/* FCoE CRC32 */
 	NETIF_F_SCTP_CSUM_BIT,		/* SCTP checksum offload */
@@ -104,6 +105,7 @@ enum {
 #define NETIF_F_RXALL		__NETIF_F(RXALL)
 #define NETIF_F_GSO_GRE		__NETIF_F(GSO_GRE)
 #define NETIF_F_GSO_UDP_TUNNEL	__NETIF_F(GSO_UDP_TUNNEL)
+#define NETIF_F_GSO_MPLS	__NETIF_F(GSO_MPLS)
 
 /* Features valid for ethtool to change */
 /* = all defined minus driver/device-class-related */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 878e0ee..9a6c9ca 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -319,6 +319,8 @@ enum {
 	SKB_GSO_GRE = 1 << 6,
 
 	SKB_GSO_UDP_TUNNEL = 1 << 7,
+
+	SKB_GSO_MPLS = 1 << 8,
 };
 
 #if BITS_PER_LONG > 32
@@ -2789,12 +2791,17 @@ static inline struct sec_path *skb_sec_path(struct sk_buff *skb)
 }
 #endif
 
-/* Keeps track of mac header offset relative to skb->head.
- * It is useful for TSO of Tunneling protocol. e.g. GRE.
- * For non-tunnel skb it points to skb_mac_header() and for
- * tunnel skb it points to outer mac header. */
 struct skb_gso_cb {
+	/* Keeps track of mac header offset relative to skb->head.
+	 * It is useful for TSO of Tunneling protocol. e.g. GRE.
+	 * For non-tunnel skb it points to skb_mac_header() and for
+	 * tunnel skb it points to outer mac header. */
 	int mac_offset;
+
+	/* Keeps track of the ethernet type of an encapsualted
+	 * packet where it is otherwise unknown. This is the case
+	 * if an MPLS stack is added to a non-MPLS packet. */
+	__be16 encap_eth_type;
 };
 #define SKB_GSO_CB(skb) ((struct skb_gso_cb *)(skb)->cb)
 
diff --git a/net/Kconfig b/net/Kconfig
index 2ddc904..d32a7fe 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -218,6 +218,7 @@ source "net/batman-adv/Kconfig"
 source "net/openvswitch/Kconfig"
 source "net/vmw_vsock/Kconfig"
 source "net/netlink/Kconfig"
+source "net/mpls/Kconfig"
 
 config RPS
 	boolean
diff --git a/net/Makefile b/net/Makefile
index 091e7b04..9492e8c 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -70,3 +70,4 @@ obj-$(CONFIG_BATMAN_ADV)	+= batman-adv/
 obj-$(CONFIG_NFC)		+= nfc/
 obj-$(CONFIG_OPENVSWITCH)	+= openvswitch/
 obj-$(CONFIG_VSOCKETS)	+= vmw_vsock/
+obj-$(CONFIG_NET_MPLS_GSO)	+= mpls/
diff --git a/net/core/dev.c b/net/core/dev.c
index 63e2533..3bc68df 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2493,8 +2493,15 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 		 * hardware encapsulation features instead of standard
 		 * features for the netdev
 		 */
-		if (skb->encapsulation)
+		if (skb->encapsulation) {
+			struct ethhdr *hdr = (struct ethhdr *)skb_mac_header(skb);
 			features &= dev->hw_enc_features;
+			if (hdr->h_proto == htons(ETH_P_MPLS_UC) ||
+			    hdr->h_proto == htons(ETH_P_MPLS_MC)) {
+				SKB_GSO_CB(skb)->encap_eth_type = skb->protocol;
+				skb->protocol = hdr->h_proto;
+			}
+		}
 
 		if (netif_needs_gso(skb, features)) {
 			if (unlikely(dev_gso_segment(skb, features)))
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index adc1351..f6d5d06 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -79,6 +79,7 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_FSO_BIT] =              "tx-fcoe-segmentation",
 	[NETIF_F_GSO_GRE_BIT] =		 "tx-gre-segmentation",
 	[NETIF_F_GSO_UDP_TUNNEL_BIT] =	 "tx-udp_tnl-segmentation",
+	[NETIF_F_GSO_MPLS_BIT] =	 "tx-mpls-segmentation",
 
 	[NETIF_F_FCOE_CRC_BIT] =         "tx-checksum-fcoe-crc",
 	[NETIF_F_SCTP_CSUM_BIT] =        "tx-checksum-sctp",
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index ba64614..d63292b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2824,7 +2824,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 						 doffset + tnl_hlen);
 
 		if (fskb != skb_shinfo(skb)->frag_list)
-			continue;
+			goto csum;
 
 		if (!sg) {
 			nskb->ip_summed = CHECKSUM_NONE;
@@ -2888,6 +2888,7 @@ skip_fraglist:
 		nskb->len += nskb->data_len;
 		nskb->truesize += nskb->data_len;
 
+csum:
 		if (!csum) {
 			nskb->csum = skb_checksum(nskb, doffset,
 						  nskb->len - doffset, 0);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 93824c5..f5b4c9a 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1291,6 +1291,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_TCP_ECN |
 		       SKB_GSO_GRE |
 		       SKB_GSO_UDP_TUNNEL |
+		       SKB_GSO_MPLS |
 		       0)))
 		goto out;
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index a96f7b5..425c933 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2914,6 +2914,7 @@ struct sk_buff *tcp_tso_segment(struct sk_buff *skb,
 			       SKB_GSO_TCP_ECN |
 			       SKB_GSO_TCPV6 |
 			       SKB_GSO_GRE |
+			       SKB_GSO_MPLS |
 			       SKB_GSO_UDP_TUNNEL |
 			       0) ||
 			     !(type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6))))
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 7117d14..0b5b57f 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2371,7 +2371,7 @@ struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
 
 		if (unlikely(type & ~(SKB_GSO_UDP | SKB_GSO_DODGY |
 				      SKB_GSO_UDP_TUNNEL |
-				      SKB_GSO_GRE) ||
+				      SKB_GSO_GRE | SKB_GSO_MPLS) ||
 			     !(type & (SKB_GSO_UDP))))
 			goto out;
 
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 71b766e..a263b99 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -98,6 +98,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_TCP_ECN |
 		       SKB_GSO_GRE |
 		       SKB_GSO_UDP_TUNNEL |
+		       SKB_GSO_MPLS |
 		       SKB_GSO_TCPV6 |
 		       0)))
 		goto out;
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index 3bb3a89..76d401a 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -63,7 +63,8 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
 		if (unlikely(type & ~(SKB_GSO_UDP |
 				      SKB_GSO_DODGY |
 				      SKB_GSO_UDP_TUNNEL |
-				      SKB_GSO_GRE) ||
+				      SKB_GSO_GRE |
+				      SKB_GSO_MPLS) ||
 			     !(type & (SKB_GSO_UDP))))
 			goto out;
 
diff --git a/net/mpls/Kconfig b/net/mpls/Kconfig
new file mode 100644
index 0000000..37421db
--- /dev/null
+++ b/net/mpls/Kconfig
@@ -0,0 +1,9 @@
+#
+# MPLS configuration
+#
+config NET_MPLS_GSO
+	tristate "MPLS: GSO support"
+	help
+	 This is helper module to allow segmentation of non-MPLS GSO packets
+	 that have had MPLS stack entries pushed onto them and thus
+	 become MPLS GSO packets.
diff --git a/net/mpls/Makefile b/net/mpls/Makefile
new file mode 100644
index 0000000..0a3c171
--- /dev/null
+++ b/net/mpls/Makefile
@@ -0,0 +1,4 @@
+#
+# Makefile for MPLS.
+#
+obj-y += mpls_gso.o
diff --git a/net/mpls/mpls_gso.c b/net/mpls/mpls_gso.c
new file mode 100644
index 0000000..f96e5b0
--- /dev/null
+++ b/net/mpls/mpls_gso.c
@@ -0,0 +1,124 @@
+/*
+ *	MPLS GSO Support
+ *
+ *	Authors: Simon Horman (horms@verge.net.au)
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ *
+ *	Based on: GSO portions of net/ipv4/gre.c
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/err.h>
+#include <linux/module.h>
+#include <linux/netdev_features.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+
+#define MPLS_BOS_MASK	0x00000100	/* Bottom of Stack bit */
+#define MPLS_HLEN	(sizeof(__be32))
+
+static struct sk_buff *mpls_gso_segment(struct sk_buff *skb,
+				       netdev_features_t features)
+{
+	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	netdev_features_t enc_features;
+	int stack_len = 0;
+	int mac_len = skb->mac_len;
+
+	if (unlikely(skb_shinfo(skb)->gso_type &
+				~(SKB_GSO_TCPV4 |
+				  SKB_GSO_TCPV6 |
+				  SKB_GSO_UDP |
+				  SKB_GSO_DODGY |
+				  SKB_GSO_TCP_ECN |
+				  SKB_GSO_GRE |
+				  SKB_GSO_MPLS)))
+		goto out;
+
+	while (1) {
+		__be32 lse = *(__be32 *)(skb_network_header(skb) + stack_len);
+
+		stack_len += MPLS_HLEN;
+		if (unlikely(!pskb_may_pull(skb, MPLS_HLEN)))
+			goto out;
+		__skb_pull(skb, MPLS_HLEN);
+
+		if (lse & htonl(MPLS_BOS_MASK))
+			break;
+	}
+
+	/* setup inner skb. */
+	skb_reset_mac_header(skb);
+	skb_reset_network_header(skb);
+	skb->mac_len = 0;
+	skb->protocol = SKB_GSO_CB(skb)->encap_eth_type;
+	skb->encapsulation = 0;
+
+	/* segment inner packet. */
+	enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
+	segs = skb_mac_gso_segment(skb, enc_features);
+	if (IS_ERR_OR_NULL(segs))
+		goto out;
+
+	skb = segs;
+	do {
+		__skb_push(skb,  stack_len + mac_len);
+		skb_reset_mac_header(skb);
+		skb_set_network_header(skb, mac_len);
+		skb->mac_len = mac_len;
+	} while ((skb = skb->next));
+out:
+	return segs;
+}
+
+static int mpls_gso_send_check(struct sk_buff *skb)
+{
+	if (!skb->encapsulation)
+		return -EINVAL;
+	return 0;
+}
+
+static struct packet_offload mpls_mc_offload = {
+	.type = cpu_to_be16(ETH_P_MPLS_MC),
+	.callbacks = {
+		.gso_send_check =	mpls_gso_send_check,
+		.gso_segment    =	mpls_gso_segment,
+	},
+};
+
+static struct packet_offload mpls_uc_offload = {
+	.type = cpu_to_be16(ETH_P_MPLS_UC),
+	.callbacks = {
+		.gso_send_check =	mpls_gso_send_check,
+		.gso_segment    =	mpls_gso_segment,
+	},
+};
+
+static int __init mpls_gso_init(void)
+{
+	pr_info("MPLS GSO support\n");
+
+	dev_add_offload(&mpls_uc_offload);
+	dev_add_offload(&mpls_mc_offload);
+
+	return 0;
+}
+
+static void __exit mpls_gso_exit(void)
+{
+	dev_remove_offload(&mpls_uc_offload);
+	dev_remove_offload(&mpls_mc_offload);
+}
+
+module_init(mpls_gso_init);
+module_exit(mpls_gso_exit);
+
+MODULE_DESCRIPTION("MPLS GSO support");
+MODULE_AUTHOR("Simon Horman (horms@verge.net.au)");
+MODULE_LICENSE("GPL");
+
-- 
1.7.10.4
