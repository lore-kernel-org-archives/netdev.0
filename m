From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 net-next 4/7] udp: Changes to udp_offload to support remote checksum offload
Date: Tue,  4 Nov 2014 09:06:54 -0800
Message-ID: <1415120817-2105-5-git-send-email-therbert@google.com>
References: <1415120817-2105-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:50554 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752372AbaKDRHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 12:07:30 -0500
Received: by mail-ie0-f182.google.com with SMTP id rd18so8050434iec.13
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 09:07:30 -0800 (PST)
In-Reply-To: <1415120817-2105-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new GSO type, SKB_GSO_TUNNEL_REMCSUM, which indicates remote
checksum offload being done (in this case inner checksum must not
be offloaded to the NIC).

Added logic in __skb_udp_tunnel_segment to handle remote checksum
offload case.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/netdev_features.h |  4 +++-
 include/linux/netdevice.h       |  1 +
 include/linux/skbuff.h          |  4 +++-
 net/core/skbuff.c               |  4 ++--
 net/ipv4/af_inet.c              |  1 +
 net/ipv4/tcp_offload.c          |  1 +
 net/ipv4/udp_offload.c          | 18 ++++++++++++++++--
 net/ipv6/ip6_offload.c          |  1 +
 net/ipv6/udp_offload.c          |  1 +
 9 files changed, 29 insertions(+), 6 deletions(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index dcfdecb..8c94b07 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -48,8 +48,9 @@ enum {
 	NETIF_F_GSO_UDP_TUNNEL_BIT,	/* ... UDP TUNNEL with TSO */
 	NETIF_F_GSO_UDP_TUNNEL_CSUM_BIT,/* ... UDP TUNNEL with TSO & CSUM */
 	NETIF_F_GSO_MPLS_BIT,		/* ... MPLS segmentation */
+	NETIF_F_GSO_TUNNEL_REMCSUM_BIT, /* ... TUNNEL with TSO & REMCSUM */
 	/**/NETIF_F_GSO_LAST =		/* last bit, see GSO_MASK */
-		NETIF_F_GSO_MPLS_BIT,
+		NETIF_F_GSO_TUNNEL_REMCSUM_BIT,
 
 	NETIF_F_FCOE_CRC_BIT,		/* FCoE CRC32 */
 	NETIF_F_SCTP_CSUM_BIT,		/* SCTP checksum offload */
@@ -119,6 +120,7 @@ enum {
 #define NETIF_F_GSO_UDP_TUNNEL	__NETIF_F(GSO_UDP_TUNNEL)
 #define NETIF_F_GSO_UDP_TUNNEL_CSUM __NETIF_F(GSO_UDP_TUNNEL_CSUM)
 #define NETIF_F_GSO_MPLS	__NETIF_F(GSO_MPLS)
+#define NETIF_F_GSO_TUNNEL_REMCSUM __NETIF_F(GSO_TUNNEL_REMCSUM)
 #define NETIF_F_HW_VLAN_STAG_FILTER __NETIF_F(HW_VLAN_STAG_FILTER)
 #define NETIF_F_HW_VLAN_STAG_RX	__NETIF_F(HW_VLAN_STAG_RX)
 #define NETIF_F_HW_VLAN_STAG_TX	__NETIF_F(HW_VLAN_STAG_TX)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5ed05bd..4767f54 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3584,6 +3584,7 @@ static inline bool net_gso_ok(netdev_features_t features, int gso_type)
 	BUILD_BUG_ON(SKB_GSO_UDP_TUNNEL != (NETIF_F_GSO_UDP_TUNNEL >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_UDP_TUNNEL_CSUM != (NETIF_F_GSO_UDP_TUNNEL_CSUM >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_MPLS    != (NETIF_F_GSO_MPLS >> NETIF_F_GSO_SHIFT));
+	BUILD_BUG_ON(SKB_GSO_TUNNEL_REMCSUM != (NETIF_F_GSO_TUNNEL_REMCSUM >> NETIF_F_GSO_SHIFT));
 
 	return (features & feature) == feature;
 }
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 5ad9675..74ed344 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -373,6 +373,7 @@ enum {
 
 	SKB_GSO_MPLS = 1 << 12,
 
+	SKB_GSO_TUNNEL_REMCSUM = 1 << 13,
 };
 
 #if BITS_PER_LONG > 32
@@ -603,7 +604,8 @@ struct sk_buff {
 #endif
 	__u8			ipvs_property:1;
 	__u8			inner_protocol_type:1;
-	/* 4 or 6 bit hole */
+	__u8			remcsum_offload:1;
+	/* 3 or 5 bit hole */
 
 #ifdef CONFIG_NET_SCHED
 	__u16			tc_index;	/* traffic control index */
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index e48e5c0..7001896 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3013,7 +3013,7 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 		if (nskb->len == len + doffset)
 			goto perform_csum_check;
 
-		if (!sg) {
+		if (!sg && !nskb->remcsum_offload) {
 			nskb->ip_summed = CHECKSUM_NONE;
 			nskb->csum = skb_copy_and_csum_bits(head_skb, offset,
 							    skb_put(nskb, len),
@@ -3085,7 +3085,7 @@ skip_fraglist:
 		nskb->truesize += nskb->data_len;
 
 perform_csum_check:
-		if (!csum) {
+		if (!csum && !nskb->remcsum_offload) {
 			nskb->csum = skb_checksum(nskb, doffset,
 						  nskb->len - doffset, 0);
 			nskb->ip_summed = CHECKSUM_NONE;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 8b7fe5b..ed2c672 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1222,6 +1222,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_TCPV6 |
 		       SKB_GSO_UDP_TUNNEL |
 		       SKB_GSO_UDP_TUNNEL_CSUM |
+		       SKB_GSO_TUNNEL_REMCSUM |
 		       SKB_GSO_MPLS |
 		       0)))
 		goto out;
diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index 5b90f2f..a1b2a56 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -97,6 +97,7 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 			       SKB_GSO_MPLS |
 			       SKB_GSO_UDP_TUNNEL |
 			       SKB_GSO_UDP_TUNNEL_CSUM |
+			       SKB_GSO_TUNNEL_REMCSUM |
 			       0) ||
 			     !(type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6))))
 			goto out;
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index a774711..0a5a70d 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -41,7 +41,8 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 	unsigned int oldlen;
 	bool need_csum = !!(skb_shinfo(skb)->gso_type &
 			    SKB_GSO_UDP_TUNNEL_CSUM);
-	bool offload_csum = false, dont_encap = need_csum;
+	bool remcsum = !!(skb_shinfo(skb)->gso_type & SKB_GSO_TUNNEL_REMCSUM);
+	bool offload_csum = false, dont_encap = (need_csum || remcsum);
 
 	oldlen = (u16)~skb->len;
 
@@ -55,6 +56,7 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 	skb->mac_len = skb_inner_network_offset(skb);
 	skb->protocol = new_protocol;
 	skb->encap_hdr_csum = need_csum;
+	skb->remcsum_offload = remcsum;
 
 	/* Try to offload checksum if possible */
 	offload_csum = !!(need_csum &&
@@ -108,11 +110,22 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 		uh->check = ~csum_fold((__force __wsum)
 				       ((__force u32)uh->check +
 					(__force u32)delta));
-
 		if (offload_csum) {
 			skb->ip_summed = CHECKSUM_PARTIAL;
 			skb->csum_start = skb_transport_header(skb) - skb->head;
 			skb->csum_offset = offsetof(struct udphdr, check);
+		} else if (remcsum) {
+			/* Need to calculate checksum from scratch,
+			 * inner checksums are never when doing
+			 * remote_checksum_offload.
+			 */
+
+			skb->csum = skb_checksum(skb, udp_offset,
+						 skb->len - udp_offset,
+						 0);
+			uh->check = csum_fold(skb->csum);
+			if (uh->check == 0)
+				uh->check = CSUM_MANGLED_0;
 		} else {
 			uh->check = gso_make_checksum(skb, ~uh->check);
 
@@ -192,6 +205,7 @@ static struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
 		if (unlikely(type & ~(SKB_GSO_UDP | SKB_GSO_DODGY |
 				      SKB_GSO_UDP_TUNNEL |
 				      SKB_GSO_UDP_TUNNEL_CSUM |
+				      SKB_GSO_TUNNEL_REMCSUM |
 				      SKB_GSO_IPIP |
 				      SKB_GSO_GRE | SKB_GSO_GRE_CSUM |
 				      SKB_GSO_MPLS) ||
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index a071563..e976707 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -78,6 +78,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_SIT |
 		       SKB_GSO_UDP_TUNNEL |
 		       SKB_GSO_UDP_TUNNEL_CSUM |
+		       SKB_GSO_TUNNEL_REMCSUM |
 		       SKB_GSO_MPLS |
 		       SKB_GSO_TCPV6 |
 		       0)))
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index 6b8f543..637ba2e 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -42,6 +42,7 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
 				      SKB_GSO_DODGY |
 				      SKB_GSO_UDP_TUNNEL |
 				      SKB_GSO_UDP_TUNNEL_CSUM |
+				      SKB_GSO_TUNNEL_REMCSUM |
 				      SKB_GSO_GRE |
 				      SKB_GSO_GRE_CSUM |
 				      SKB_GSO_IPIP |
-- 
2.1.0.rc2.206.gedb03e5
