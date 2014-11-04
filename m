From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 01/14] net: Remove MPLS GSO feature.
Date: Mon,  3 Nov 2014 22:00:51 -0800
Message-ID: <1415080851-1652-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog039.obsmtp.com ([74.125.150.113]:48277 "HELO
	na6sys009bog039.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751757AbaKEUBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 15:01:05 -0500
Received: by mail-pa0-f52.google.com with SMTP id fa1so1443109pad.11
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 12:01:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Device can export MPLS GSO support in dev->mpls_features same way
it export vlan features in dev->vlan_features. So it is safe to
remove this redundant flag.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/linux/netdev_features.h | 7 ++-----
 include/linux/netdevice.h       | 1 -
 include/linux/skbuff.h          | 3 ---
 net/core/ethtool.c              | 1 -
 net/ipv4/af_inet.c              | 1 -
 net/ipv4/tcp_offload.c          | 1 -
 net/ipv4/udp_offload.c          | 3 +--
 net/ipv6/ip6_offload.c          | 1 -
 net/ipv6/udp_offload.c          | 3 +--
 net/mpls/mpls_gso.c             | 3 +--
 10 files changed, 5 insertions(+), 19 deletions(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index dcfdecb..b7e52ba 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -47,9 +47,8 @@ enum {
 	NETIF_F_GSO_SIT_BIT,		/* ... SIT tunnel with TSO */
 	NETIF_F_GSO_UDP_TUNNEL_BIT,	/* ... UDP TUNNEL with TSO */
 	NETIF_F_GSO_UDP_TUNNEL_CSUM_BIT,/* ... UDP TUNNEL with TSO & CSUM */
-	NETIF_F_GSO_MPLS_BIT,		/* ... MPLS segmentation */
 	/**/NETIF_F_GSO_LAST =		/* last bit, see GSO_MASK */
-		NETIF_F_GSO_MPLS_BIT,
+		NETIF_F_GSO_UDP_TUNNEL_CSUM_BIT,
 
 	NETIF_F_FCOE_CRC_BIT,		/* FCoE CRC32 */
 	NETIF_F_SCTP_CSUM_BIT,		/* SCTP checksum offload */
@@ -118,7 +117,6 @@ enum {
 #define NETIF_F_GSO_SIT		__NETIF_F(GSO_SIT)
 #define NETIF_F_GSO_UDP_TUNNEL	__NETIF_F(GSO_UDP_TUNNEL)
 #define NETIF_F_GSO_UDP_TUNNEL_CSUM __NETIF_F(GSO_UDP_TUNNEL_CSUM)
-#define NETIF_F_GSO_MPLS	__NETIF_F(GSO_MPLS)
 #define NETIF_F_HW_VLAN_STAG_FILTER __NETIF_F(HW_VLAN_STAG_FILTER)
 #define NETIF_F_HW_VLAN_STAG_RX	__NETIF_F(HW_VLAN_STAG_RX)
 #define NETIF_F_HW_VLAN_STAG_TX	__NETIF_F(HW_VLAN_STAG_TX)
@@ -181,7 +179,6 @@ enum {
 				 NETIF_F_GSO_IPIP |			\
 				 NETIF_F_GSO_SIT |			\
 				 NETIF_F_GSO_UDP_TUNNEL |		\
-				 NETIF_F_GSO_UDP_TUNNEL_CSUM |		\
-				 NETIF_F_GSO_MPLS)
+				 NETIF_F_GSO_UDP_TUNNEL_CSUM)
 
 #endif	/* _LINUX_NETDEV_FEATURES_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5ed05bd..a64c023 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3583,7 +3583,6 @@ static inline bool net_gso_ok(netdev_features_t features, int gso_type)
 	BUILD_BUG_ON(SKB_GSO_SIT     != (NETIF_F_GSO_SIT >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_UDP_TUNNEL != (NETIF_F_GSO_UDP_TUNNEL >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_UDP_TUNNEL_CSUM != (NETIF_F_GSO_UDP_TUNNEL_CSUM >> NETIF_F_GSO_SHIFT));
-	BUILD_BUG_ON(SKB_GSO_MPLS    != (NETIF_F_GSO_MPLS >> NETIF_F_GSO_SHIFT));
 
 	return (features & feature) == feature;
 }
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 5ad9675..03edc07 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -370,9 +370,6 @@ enum {
 	SKB_GSO_UDP_TUNNEL = 1 << 10,
 
 	SKB_GSO_UDP_TUNNEL_CSUM = 1 << 11,
-
-	SKB_GSO_MPLS = 1 << 12,
-
 };
 
 #if BITS_PER_LONG > 32
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 06dfb29..b0f84f5 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -84,7 +84,6 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_GSO_IPIP_BIT] =	 "tx-ipip-segmentation",
 	[NETIF_F_GSO_SIT_BIT] =		 "tx-sit-segmentation",
 	[NETIF_F_GSO_UDP_TUNNEL_BIT] =	 "tx-udp_tnl-segmentation",
-	[NETIF_F_GSO_MPLS_BIT] =	 "tx-mpls-segmentation",
 
 	[NETIF_F_FCOE_CRC_BIT] =         "tx-checksum-fcoe-crc",
 	[NETIF_F_SCTP_CSUM_BIT] =        "tx-checksum-sctp",
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 8b7fe5b..b7340a3 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1222,7 +1222,6 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_TCPV6 |
 		       SKB_GSO_UDP_TUNNEL |
 		       SKB_GSO_UDP_TUNNEL_CSUM |
-		       SKB_GSO_MPLS |
 		       0)))
 		goto out;
 
diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index 5b90f2f..7902bbe 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -94,7 +94,6 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 			       SKB_GSO_GRE_CSUM |
 			       SKB_GSO_IPIP |
 			       SKB_GSO_SIT |
-			       SKB_GSO_MPLS |
 			       SKB_GSO_UDP_TUNNEL |
 			       SKB_GSO_UDP_TUNNEL_CSUM |
 			       0) ||
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 6480cea..7da2a70 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -173,8 +173,7 @@ static struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
 				      SKB_GSO_UDP_TUNNEL |
 				      SKB_GSO_UDP_TUNNEL_CSUM |
 				      SKB_GSO_IPIP |
-				      SKB_GSO_GRE | SKB_GSO_GRE_CSUM |
-				      SKB_GSO_MPLS) ||
+				      SKB_GSO_GRE | SKB_GSO_GRE_CSUM) ||
 			     !(type & (SKB_GSO_UDP))))
 			goto out;
 
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index a071563..27f3ea4 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -78,7 +78,6 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_SIT |
 		       SKB_GSO_UDP_TUNNEL |
 		       SKB_GSO_UDP_TUNNEL_CSUM |
-		       SKB_GSO_MPLS |
 		       SKB_GSO_TCPV6 |
 		       0)))
 		goto out;
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index 6b8f543..f1c4ab4 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -45,8 +45,7 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
 				      SKB_GSO_GRE |
 				      SKB_GSO_GRE_CSUM |
 				      SKB_GSO_IPIP |
-				      SKB_GSO_SIT |
-				      SKB_GSO_MPLS) ||
+				      SKB_GSO_SIT) ||
 			     !(type & (SKB_GSO_UDP))))
 			goto out;
 
diff --git a/net/mpls/mpls_gso.c b/net/mpls/mpls_gso.c
index e3545f2..ca27837 100644
--- a/net/mpls/mpls_gso.c
+++ b/net/mpls/mpls_gso.c
@@ -34,8 +34,7 @@ static struct sk_buff *mpls_gso_segment(struct sk_buff *skb,
 				  SKB_GSO_TCP_ECN |
 				  SKB_GSO_GRE |
 				  SKB_GSO_GRE_CSUM |
-				  SKB_GSO_IPIP |
-				  SKB_GSO_MPLS)))
+				  SKB_GSO_IPIP)))
 		goto out;
 
 	/* Setup inner SKB. */
-- 
1.9.3
