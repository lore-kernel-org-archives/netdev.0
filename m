From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH 01/10] core: Split out UFO6 support
Date: Wed, 17 Dec 2014 13:20:46 -0500
Message-ID: <1418840455-22598-2-git-send-email-vyasevic@redhat.com>
References: <1418840455-22598-1-git-send-email-vyasevic@redhat.com>
Cc: virtualization@lists.linux-foundation.org, mst@redhat.com,
	ben@decadent.org.uk, stefanha@redhat.com,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f52.google.com ([209.85.216.52]:44366 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751084AbaLQSVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 13:21:17 -0500
Received: by mail-qa0-f52.google.com with SMTP id x12so3142001qac.39
        for <netdev@vger.kernel.org>; Wed, 17 Dec 2014 10:21:16 -0800 (PST)
In-Reply-To: <1418840455-22598-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Split IPv6 support for UFO into its own feature similiar to TSO.
This will later allow us to re-enable UFO support for virtio-net
devices.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 include/linux/netdev_features.h |  7 +++++--
 include/linux/netdevice.h       |  1 +
 include/linux/skbuff.h          |  1 +
 net/core/dev.c                  | 35 +++++++++++++++++++----------------
 net/core/ethtool.c              |  2 +-
 5 files changed, 27 insertions(+), 19 deletions(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index dcfdecb..a078945 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -48,8 +48,9 @@ enum {
 	NETIF_F_GSO_UDP_TUNNEL_BIT,	/* ... UDP TUNNEL with TSO */
 	NETIF_F_GSO_UDP_TUNNEL_CSUM_BIT,/* ... UDP TUNNEL with TSO & CSUM */
 	NETIF_F_GSO_MPLS_BIT,		/* ... MPLS segmentation */
+	NETIF_F_UFO6_BIT,		/* ... UDPv6 fragmentation */
 	/**/NETIF_F_GSO_LAST =		/* last bit, see GSO_MASK */
-		NETIF_F_GSO_MPLS_BIT,
+		NETIF_F_UFO6_BIT,
 
 	NETIF_F_FCOE_CRC_BIT,		/* FCoE CRC32 */
 	NETIF_F_SCTP_CSUM_BIT,		/* SCTP checksum offload */
@@ -109,6 +110,7 @@ enum {
 #define NETIF_F_TSO_ECN		__NETIF_F(TSO_ECN)
 #define NETIF_F_TSO		__NETIF_F(TSO)
 #define NETIF_F_UFO		__NETIF_F(UFO)
+#define NETIF_F_UFO6		__NETIF_F(UFO6)
 #define NETIF_F_VLAN_CHALLENGED	__NETIF_F(VLAN_CHALLENGED)
 #define NETIF_F_RXFCS		__NETIF_F(RXFCS)
 #define NETIF_F_RXALL		__NETIF_F(RXALL)
@@ -141,7 +143,7 @@ enum {
 
 /* List of features with software fallbacks. */
 #define NETIF_F_GSO_SOFTWARE	(NETIF_F_TSO | NETIF_F_TSO_ECN | \
-				 NETIF_F_TSO6 | NETIF_F_UFO)
+				 NETIF_F_TSO6 | NETIF_F_UFO | NETIF_F_UFO6)
 
 #define NETIF_F_GEN_CSUM	NETIF_F_HW_CSUM
 #define NETIF_F_V4_CSUM		(NETIF_F_GEN_CSUM | NETIF_F_IP_CSUM)
@@ -149,6 +151,7 @@ enum {
 #define NETIF_F_ALL_CSUM	(NETIF_F_V4_CSUM | NETIF_F_V6_CSUM)
 
 #define NETIF_F_ALL_TSO 	(NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN)
+#define NETIF_F_ALL_UFO		(NETIF_F_UFO | NETIF_F_UFO6)
 
 #define NETIF_F_ALL_FCOE	(NETIF_F_FCOE_CRC | NETIF_F_FCOE_MTU | \
 				 NETIF_F_FSO)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 74fd5d3..86af10a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3559,6 +3559,7 @@ static inline bool net_gso_ok(netdev_features_t features, int gso_type)
 	/* check flags correspondence */
 	BUILD_BUG_ON(SKB_GSO_TCPV4   != (NETIF_F_TSO >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_UDP     != (NETIF_F_UFO >> NETIF_F_GSO_SHIFT));
+	BUILD_BUG_ON(SKB_GSO_UDP6    != (NETIF_F_UFO6 >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_DODGY   != (NETIF_F_GSO_ROBUST >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_TCP_ECN != (NETIF_F_TSO_ECN >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_TCPV6   != (NETIF_F_TSO6 >> NETIF_F_GSO_SHIFT));
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 6c8b6f6..8538b67 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -372,6 +372,7 @@ enum {
 
 	SKB_GSO_MPLS = 1 << 12,
 
+	SKB_GSO_UDP6 = 1 << 13
 };
 
 #if BITS_PER_LONG > 32
diff --git a/net/core/dev.c b/net/core/dev.c
index 945bbd0..fa4d2ee 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5929,6 +5929,12 @@ static netdev_features_t netdev_fix_features(struct net_device *dev,
 		features &= ~NETIF_F_ALL_TSO;
 	}
 
+	/* UFO requires that SG is present as well */
+	if ((features & NETIF_F_ALL_UFO) && !(features & NETIF_F_SG)) {
+		netdev_dbg(dev, "Dropping UFO features since no SG feature.\n");
+		features &= ~NETIF_F_ALL_UFO;
+	}
+
 	if ((features & NETIF_F_TSO) && !(features & NETIF_F_HW_CSUM) &&
 					!(features & NETIF_F_IP_CSUM)) {
 		netdev_dbg(dev, "Dropping TSO features since no CSUM feature.\n");
@@ -5952,24 +5958,21 @@ static netdev_features_t netdev_fix_features(struct net_device *dev,
 		features &= ~NETIF_F_GSO;
 	}
 
-	/* UFO needs SG and checksumming */
-	if (features & NETIF_F_UFO) {
-		/* maybe split UFO into V4 and V6? */
-		if (!((features & NETIF_F_GEN_CSUM) ||
-		    (features & (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))
-			    == (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))) {
-			netdev_dbg(dev,
-				"Dropping NETIF_F_UFO since no checksum offload features.\n");
-			features &= ~NETIF_F_UFO;
-		}
-
-		if (!(features & NETIF_F_SG)) {
-			netdev_dbg(dev,
-				"Dropping NETIF_F_UFO since no NETIF_F_SG feature.\n");
-			features &= ~NETIF_F_UFO;
-		}
+	/* UFO also needs checksumming */
+	if ((features & NETIF_F_UFO) && !(features & NETIF_F_GEN_CSUM) &&
+					!(features & NETIF_F_IP_CSUM)) {
+		netdev_dbg(dev,
+			   "Dropping NETIF_F_UFO since no checksum offload features.\n");
+		features &= ~NETIF_F_UFO;
+	}
+	if ((features & NETIF_F_UFO6) && !(features & NETIF_F_GEN_CSUM) &&
+					 !(features & NETIF_F_IPV6_CSUM)) {
+		netdev_dbg(dev,
+			   "Dropping NETIF_F_UFO6 since no checksum offload features.\n");
+		features &= ~NETIF_F_UFO6;
 	}
 
+
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	if (dev->netdev_ops->ndo_busy_poll)
 		features |= NETIF_F_BUSY_POLL;
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 06dfb29..93eff41 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -223,7 +223,7 @@ static netdev_features_t ethtool_get_feature_mask(u32 eth_cmd)
 		return NETIF_F_ALL_TSO;
 	case ETHTOOL_GUFO:
 	case ETHTOOL_SUFO:
-		return NETIF_F_UFO;
+		return NETIF_F_ALL_UFO;
 	case ETHTOOL_GGSO:
 	case ETHTOOL_SGSO:
 		return NETIF_F_GSO;
-- 
1.9.3
