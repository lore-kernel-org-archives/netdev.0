From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC 07/13] net: Add ESP offload features
Date: Thu, 4 Feb 2016 07:37:00 +0100
Message-ID: <1454567826-13018-8-git-send-email-steffen.klassert@secunet.com>
References: <1454567826-13018-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	<sowmini.varadhan@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36687 "EHLO
	h-62.96.220.36.host.de.colt.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752866AbcBDHFw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 02:05:52 -0500
In-Reply-To: <1454567826-13018-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds netdev features to configure IPsec offloads.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/linux/netdev_features.h | 6 +++++-
 include/linux/netdevice.h       | 1 +
 include/linux/skbuff.h          | 2 ++
 net/core/ethtool.c              | 2 ++
 4 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index d9654f0e..4a62acb 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -48,8 +48,9 @@ enum {
 	NETIF_F_GSO_UDP_TUNNEL_BIT,	/* ... UDP TUNNEL with TSO */
 	NETIF_F_GSO_UDP_TUNNEL_CSUM_BIT,/* ... UDP TUNNEL with TSO & CSUM */
 	NETIF_F_GSO_TUNNEL_REMCSUM_BIT, /* ... TUNNEL with TSO & REMCSUM */
+	NETIF_F_GSO_ESP_BIT,		/* ... ESP with TSO */
 	/**/NETIF_F_GSO_LAST =		/* last bit, see GSO_MASK */
-		NETIF_F_GSO_TUNNEL_REMCSUM_BIT,
+		NETIF_F_GSO_ESP_BIT,
 
 	NETIF_F_FCOE_CRC_BIT,		/* FCoE CRC32 */
 	NETIF_F_SCTP_CRC_BIT,		/* SCTP checksum offload */
@@ -66,6 +67,7 @@ enum {
 	NETIF_F_HW_VLAN_STAG_FILTER_BIT,/* Receive filtering on VLAN STAGs */
 	NETIF_F_HW_L2FW_DOFFLOAD_BIT,	/* Allow L2 Forwarding in Hardware */
 	NETIF_F_BUSY_POLL_BIT,		/* Busy poll */
+	NETIF_F_ESP_OFFLOAD_BIT,	/* ESP transformation offload */
 
 	/*
 	 * Add your fresh new feature above and remember to update
@@ -119,11 +121,13 @@ enum {
 #define NETIF_F_GSO_UDP_TUNNEL	__NETIF_F(GSO_UDP_TUNNEL)
 #define NETIF_F_GSO_UDP_TUNNEL_CSUM __NETIF_F(GSO_UDP_TUNNEL_CSUM)
 #define NETIF_F_GSO_TUNNEL_REMCSUM __NETIF_F(GSO_TUNNEL_REMCSUM)
+#define NETIF_F_GSO_ESP		__NETIF_F(GSO_ESP)
 #define NETIF_F_HW_VLAN_STAG_FILTER __NETIF_F(HW_VLAN_STAG_FILTER)
 #define NETIF_F_HW_VLAN_STAG_RX	__NETIF_F(HW_VLAN_STAG_RX)
 #define NETIF_F_HW_VLAN_STAG_TX	__NETIF_F(HW_VLAN_STAG_TX)
 #define NETIF_F_HW_L2FW_DOFFLOAD	__NETIF_F(HW_L2FW_DOFFLOAD)
 #define NETIF_F_BUSY_POLL	__NETIF_F(BUSY_POLL)
+#define NETIF_F_ESP_OFFLOAD	__NETIF_F(ESP_OFFLOAD)
 
 #define for_each_netdev_feature(mask_addr, bit)	\
 	for_each_set_bit(bit, (unsigned long *)mask_addr, NETDEV_FEATURE_COUNT)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 6936e96f..adbca16 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3938,6 +3938,7 @@ static inline bool net_gso_ok(netdev_features_t features, int gso_type)
 	BUILD_BUG_ON(SKB_GSO_UDP_TUNNEL != (NETIF_F_GSO_UDP_TUNNEL >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_UDP_TUNNEL_CSUM != (NETIF_F_GSO_UDP_TUNNEL_CSUM >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_TUNNEL_REMCSUM != (NETIF_F_GSO_TUNNEL_REMCSUM >> NETIF_F_GSO_SHIFT));
+	BUILD_BUG_ON(SKB_GSO_ESP != (NETIF_F_GSO_ESP >> NETIF_F_GSO_SHIFT));
 
 	return (features & feature) == feature;
 }
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index b84245f..4652f2c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -481,6 +481,8 @@ enum {
 	SKB_GSO_UDP_TUNNEL_CSUM = 1 << 11,
 
 	SKB_GSO_TUNNEL_REMCSUM = 1 << 12,
+
+	SKB_GSO_ESP = 1 << 13,
 };
 
 #if BITS_PER_LONG > 32
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index daf0470..d9baba1 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -85,6 +85,7 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_GSO_IPIP_BIT] =	 "tx-ipip-segmentation",
 	[NETIF_F_GSO_SIT_BIT] =		 "tx-sit-segmentation",
 	[NETIF_F_GSO_UDP_TUNNEL_BIT] =	 "tx-udp_tnl-segmentation",
+	[NETIF_F_GSO_ESP_BIT] =		 "tx-esp-segmentation",
 
 	[NETIF_F_FCOE_CRC_BIT] =         "tx-checksum-fcoe-crc",
 	[NETIF_F_SCTP_CRC_BIT] =        "tx-checksum-sctp",
@@ -98,6 +99,7 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_RXALL_BIT] =            "rx-all",
 	[NETIF_F_HW_L2FW_DOFFLOAD_BIT] = "l2-fwd-offload",
 	[NETIF_F_BUSY_POLL_BIT] =        "busy-poll",
+	[NETIF_F_ESP_OFFLOAD_BIT] =       "tx-esp-offload",
 };
 
 static const char
-- 
1.9.1
