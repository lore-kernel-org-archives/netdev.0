From: Simon Horman <horms@verge.net.au>
Subject: [PATCH net-next v5 2/2] MPLS: Add limited GSO support
Date: Fri, 24 May 2013 16:02:52 +0900
Message-ID: <1369378972-22728-3-git-send-email-horms@verge.net.au>
References: <1369378972-22728-1-git-send-email-horms@verge.net.au>
Cc: Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	jarno.rajahalme@nsn.com, Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	Simon Horman <horms@verge.net.au>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:47214 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755994Ab3EXHC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 03:02:56 -0400
In-Reply-To: <1369378972-22728-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the case where a non-MPLS packet is received and an MPLS stack is
added it may well be the case that the original skb is GSO but the
NIC used for transmit does not support GSO of MPLS packets.

The aim of this code is to provide GSO in software for MPLS packets
whose skbs are GSO.

SKB Usage:

When an implementation adds an MPLS stack to a non-MPLS packet it should do
the following to skb metadata:

* Set skb->inner_protocol to the old non-MPLS ethertype of the packet.
  skb->inner_protocol is added by this patch.

* Set skb->protocol to the new MPLS ethertype of the packet.

* Set skb->network_header to correspond to the
  end of the L3 header, including the MPLS label stack.

I have posted a patch, "[PATCH v3.29] datapath: Add basic MPLS support to
kernel" which adds MPLS support to the kernel datapath of Open vSwtich.
That patch sets the above requirements in datapath/actions.c:push_mpls()
and was used to exercise this code.  The datapath patch is against the Open
vSwtich tree but it is intended that it be added to the Open vSwtich code
present in the mainline Linux kernel at some point.

Features:

I believe that the approach that I have taken is at least partially
consistent with the handling of other protocols.  Jesse, I understand that
you have some ideas here.  I am more than happy to change my implementation.

This patch adds dev->mpls_features which may be used by devices
to advertise features supported for MPLS packets.

A new NETIF_F_MPLS_GSO feature is added for devices which support
hardware MPLS GSO offload.  Currently no devices support this
and MPLS GSO always falls back to software.

Alternate Implementation:

One possible alternate implementation is to teach netif_skb_features()
and skb_network_protocol() about MPLS, in a similar way to their
understanding of VLANs. I believe this would avoid the need
for net/mpls/mpls_gso.c and in particular the calls to
__skb_push() and __skb_push() in mpls_gso_segment().

I have decided on the implementation in this patch as it should
not introduce any overhead in the case where mpls_gso is not compiled
into the kernel or inserted as a module.

MPLS GSO suggested by Jesse Gross.
Based in part on "v4 GRE: Add TCP segmentation offload for GRE"
by Pravin B Shelar.

Cc: Jesse Gross <jesse@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

---

MPLS GSO also requires "net: Loosen constraints for recalculating checksum
in skb_segment()" in order for segmentation of TCP/IP inner packets to
correctly recalculate checksums.

Tested using the bnx2 driver.

v5
* Move inner_protocol from below inner_mac_header to
  above inner_transport header to allow all *_header fields
  to be grouped together.
* Remove trailing blank line from mpls_gso.c

v4
* Add inner_protocol to kernel doc for struct skbuff
* As suggested by Jesse Gross
  - Refer to CONFIG_NET_MPLS_GSO rather than CONFIG_NET_GRE_GSO in
    change log
  - Reword the changelog to reflect that mac_len is not set to correspond
    to the end of l3 data. Its value is not important to the function of
    GSO as a call to skb_reset_mac_len() is made in __skb_gso_segment().

* I considered guarding the presence of inner_protocol in struct skbuff with
  #ifdef CONFIG_NET_MPLS_GSO as it is otherwise unused. However, this
  makes accessing inner_protocol from out-of tree code somewhat tedious.
  And the reference usage of this code is the out-of tree version
  of the Open vSwitch datapath.

v3
* As suggested by Ben Hutchings
  - Update NETIF_F_GSO_LAST
* Update SKB usage
  - Add and use skb->inner_protocol
  - Set skb->protocol to MPLS ethertype of packet
  - Set skb->mac_len and skb->network_header to correspond to the
    end of the L3 header.

v2
* As suggested by Jarno Rajahalme
  - Update NETIF_F_GSO_LAST
  - mpls_mc_offload to use ETH_P_MPLS_MC
* Remove NETIF_F_iP_CSUM|NETIF_F_IPV6_CSUM features hack in
  mpls_gso_segment()
---
 include/linux/netdev_features.h |   4 +-
 include/linux/netdevice.h       |   2 +
 include/linux/skbuff.h          |   4 ++
 net/Kconfig                     |   1 +
 net/Makefile                    |   1 +
 net/core/dev.c                  |   4 ++
 net/core/ethtool.c              |   1 +
 net/ipv4/af_inet.c              |   1 +
 net/ipv4/tcp.c                  |   1 +
 net/ipv4/udp.c                  |   2 +-
 net/ipv6/ip6_offload.c          |   1 +
 net/ipv6/udp_offload.c          |   3 +-
 net/mpls/Kconfig                |   9 ++++
 net/mpls/Makefile               |   4 ++
 net/mpls/mpls_gso.c             | 108 ++++++++++++++++++++++++++++++++++++++++
 15 files changed, 143 insertions(+), 3 deletions(-)
 create mode 100644 net/mpls/Kconfig
 create mode 100644 net/mpls/Makefile
 create mode 100644 net/mpls/mpls_gso.c

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 09906b7..a2a89a5 100644
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
@@ -107,6 +108,7 @@ enum {
 #define NETIF_F_RXALL		__NETIF_F(RXALL)
 #define NETIF_F_GSO_GRE		__NETIF_F(GSO_GRE)
 #define NETIF_F_GSO_UDP_TUNNEL	__NETIF_F(GSO_UDP_TUNNEL)
+#define NETIF_F_GSO_MPLS	__NETIF_F(GSO_MPLS)
 #define NETIF_F_HW_VLAN_STAG_FILTER __NETIF_F(HW_VLAN_STAG_FILTER)
 #define NETIF_F_HW_VLAN_STAG_RX	__NETIF_F(HW_VLAN_STAG_RX)
 #define NETIF_F_HW_VLAN_STAG_TX	__NETIF_F(HW_VLAN_STAG_TX)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7dd535d..c7b608b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1088,6 +1088,8 @@ struct net_device {
 	 * need to set them appropriately.
 	 */
 	netdev_features_t	hw_enc_features;
+	/* mask of fetures inheritable by MPLS */
+	netdev_features_t	mpls_features;
 
 	/* Interface index. Unique device identifier	*/
 	int			ifindex;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 5663e35..8f2b830 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -319,6 +319,8 @@ enum {
 	SKB_GSO_GRE = 1 << 6,
 
 	SKB_GSO_UDP_TUNNEL = 1 << 7,
+
+	SKB_GSO_MPLS = 1 << 8,
 };
 
 #if BITS_PER_LONG > 32
@@ -389,6 +391,7 @@ typedef unsigned char *sk_buff_data_t;
  *	@dropcount: total number of sk_receive_queue overflows
  *	@vlan_proto: vlan encapsulation protocol
  *	@vlan_tci: vlan tag control information
+ *	@inner_protocol: Protocol (encapsulation)
  *	@inner_transport_header: Inner transport layer header (encapsulation)
  *	@inner_network_header: Network layer header (encapsulation)
  *	@inner_mac_header: Link layer header (encapsulation)
@@ -509,6 +512,7 @@ struct sk_buff {
 		__u32		reserved_tailroom;
 	};
 
+	__be16			inner_protocol;
 	__u16			inner_transport_header;
 	__u16			inner_network_header;
 	__u16			inner_mac_header;
diff --git a/net/Kconfig b/net/Kconfig
index 08de901..523e43e 100644
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
index 7229bc3..3cb489f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5276,6 +5276,10 @@ int register_netdevice(struct net_device *dev)
 	 */
 	dev->hw_enc_features |= NETIF_F_SG;
 
+	/* Make NETIF_F_SG inheritable to MPLS.
+	 */
+	dev->mpls_features |= NETIF_F_SG;
+
 	ret = call_netdevice_notifiers(NETDEV_POST_INIT, dev);
 	ret = notifier_to_errno(ret);
 	if (ret)
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 22efdaa..4e6f63a 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -82,6 +82,7 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_FSO_BIT] =              "tx-fcoe-segmentation",
 	[NETIF_F_GSO_GRE_BIT] =		 "tx-gre-segmentation",
 	[NETIF_F_GSO_UDP_TUNNEL_BIT] =	 "tx-udp_tnl-segmentation",
+	[NETIF_F_GSO_MPLS_BIT] =	 "tx-mpls-segmentation",
 
 	[NETIF_F_FCOE_CRC_BIT] =         "tx-checksum-fcoe-crc",
 	[NETIF_F_SCTP_CSUM_BIT] =        "tx-checksum-sctp",
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index d01be2a..b05ae96 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1295,6 +1295,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_GRE |
 		       SKB_GSO_TCPV6 |
 		       SKB_GSO_UDP_TUNNEL |
+		       SKB_GSO_MPLS |
 		       0)))
 		goto out;
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 53d9c12..6201e57 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2916,6 +2916,7 @@ struct sk_buff *tcp_tso_segment(struct sk_buff *skb,
 			       SKB_GSO_TCP_ECN |
 			       SKB_GSO_TCPV6 |
 			       SKB_GSO_GRE |
+			       SKB_GSO_MPLS |
 			       SKB_GSO_UDP_TUNNEL |
 			       0) ||
 			     !(type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6))))
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 0bf5d39..aa5eff4 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2381,7 +2381,7 @@ struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
 
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
index 0000000..1bec121
--- /dev/null
+++ b/net/mpls/mpls_gso.c
@@ -0,0 +1,108 @@
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
+static struct sk_buff *mpls_gso_segment(struct sk_buff *skb,
+				       netdev_features_t features)
+{
+	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	netdev_features_t mpls_features;
+	__be16 mpls_protocol;
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
+	/* Setup inner SKB. */
+	mpls_protocol = skb->protocol;
+	skb->protocol = skb->inner_protocol;
+
+	/* Push back the mac header that skb_mac_gso_segment() has pulled.
+	 * It will be re-pulled by the call to skb_mac_gso_segment() below
+	 */
+	__skb_push(skb, skb->mac_len);
+
+	/* Segment inner packet. */
+	mpls_features = skb->dev->mpls_features & netif_skb_features(skb);
+	segs = skb_mac_gso_segment(skb, mpls_features);
+
+
+	/* Restore outer protocol. */
+	skb->protocol = mpls_protocol;
+
+	/* Re-pull the mac header that the call to skb_mac_gso_segment()
+	 * above pulled.  It will be re-pushed after returning
+	 * skb_mac_gso_segment(), an indirect caller of this function.
+	 */
+	__skb_push(skb, skb->data - skb_mac_header(skb));
+
+out:
+	return segs;
+}
+
+static int mpls_gso_send_check(struct sk_buff *skb)
+{
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
-- 
1.8.2.1
