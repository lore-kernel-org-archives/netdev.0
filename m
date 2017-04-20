From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 01/16] net: Add ESP offload features
Date: Thu, 20 Apr 2017 10:55:00 +0200
Message-ID: <1492678515-14347-2-git-send-email-steffen.klassert@secunet.com>
References: <1492678515-14347-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:51554 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S939519AbdDTI4C (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 04:56:02 -0400
In-Reply-To: <1492678515-14347-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds netdev features to configure IPsec offloads.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/linux/netdev_features.h | 8 +++++++-
 include/linux/netdevice.h       | 1 +
 include/linux/skbuff.h          | 2 ++
 net/core/ethtool.c              | 3 +++
 4 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 9a04195..1d4737c 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -54,8 +54,9 @@ enum {
 					 */
 	NETIF_F_GSO_TUNNEL_REMCSUM_BIT, /* ... TUNNEL with TSO & REMCSUM */
 	NETIF_F_GSO_SCTP_BIT,		/* ... SCTP fragmentation */
+	NETIF_F_GSO_ESP_BIT,		/* ... ESP with TSO */
 	/**/NETIF_F_GSO_LAST =		/* last bit, see GSO_MASK */
-		NETIF_F_GSO_SCTP_BIT,
+		NETIF_F_GSO_ESP_BIT,
 
 	NETIF_F_FCOE_CRC_BIT,		/* FCoE CRC32 */
 	NETIF_F_SCTP_CRC_BIT,		/* SCTP checksum offload */
@@ -73,6 +74,8 @@ enum {
 	NETIF_F_HW_L2FW_DOFFLOAD_BIT,	/* Allow L2 Forwarding in Hardware */
 
 	NETIF_F_HW_TC_BIT,		/* Offload TC infrastructure */
+	NETIF_F_HW_ESP_BIT,		/* Hardware ESP transformation offload */
+	NETIF_F_HW_ESP_TX_CSUM_BIT,	/* ESP with TX checksum offload */
 
 	/*
 	 * Add your fresh new feature above and remember to update
@@ -129,11 +132,14 @@ enum {
 #define NETIF_F_GSO_PARTIAL	 __NETIF_F(GSO_PARTIAL)
 #define NETIF_F_GSO_TUNNEL_REMCSUM __NETIF_F(GSO_TUNNEL_REMCSUM)
 #define NETIF_F_GSO_SCTP	__NETIF_F(GSO_SCTP)
+#define NETIF_F_GSO_ESP		__NETIF_F(GSO_ESP)
 #define NETIF_F_HW_VLAN_STAG_FILTER __NETIF_F(HW_VLAN_STAG_FILTER)
 #define NETIF_F_HW_VLAN_STAG_RX	__NETIF_F(HW_VLAN_STAG_RX)
 #define NETIF_F_HW_VLAN_STAG_TX	__NETIF_F(HW_VLAN_STAG_TX)
 #define NETIF_F_HW_L2FW_DOFFLOAD	__NETIF_F(HW_L2FW_DOFFLOAD)
 #define NETIF_F_HW_TC		__NETIF_F(HW_TC)
+#define NETIF_F_HW_ESP		__NETIF_F(HW_ESP)
+#define NETIF_F_HW_ESP_TX_CSUM	__NETIF_F(HW_ESP_TX_CSUM)
 
 #define for_each_netdev_feature(mask_addr, bit)	\
 	for_each_set_bit(bit, (unsigned long *)mask_addr, NETDEV_FEATURE_COUNT)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index cc07c3b..5bb03d1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -4070,6 +4070,7 @@ static inline bool net_gso_ok(netdev_features_t features, int gso_type)
 	BUILD_BUG_ON(SKB_GSO_PARTIAL != (NETIF_F_GSO_PARTIAL >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_TUNNEL_REMCSUM != (NETIF_F_GSO_TUNNEL_REMCSUM >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_SCTP    != (NETIF_F_GSO_SCTP >> NETIF_F_GSO_SHIFT));
+	BUILD_BUG_ON(SKB_GSO_ESP != (NETIF_F_GSO_ESP >> NETIF_F_GSO_SHIFT));
 
 	return (features & feature) == feature;
 }
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 741d75c..81ef53f 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -492,6 +492,8 @@ enum {
 	SKB_GSO_TUNNEL_REMCSUM = 1 << 14,
 
 	SKB_GSO_SCTP = 1 << 15,
+
+	SKB_GSO_ESP = 1 << 16,
 };
 
 #if BITS_PER_LONG > 32
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 905a88a..03111a2 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -90,6 +90,7 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_GSO_UDP_TUNNEL_CSUM_BIT] = "tx-udp_tnl-csum-segmentation",
 	[NETIF_F_GSO_PARTIAL_BIT] =	 "tx-gso-partial",
 	[NETIF_F_GSO_SCTP_BIT] =	 "tx-sctp-segmentation",
+	[NETIF_F_GSO_ESP_BIT] =		 "tx-esp-segmentation",
 
 	[NETIF_F_FCOE_CRC_BIT] =         "tx-checksum-fcoe-crc",
 	[NETIF_F_SCTP_CRC_BIT] =        "tx-checksum-sctp",
@@ -103,6 +104,8 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_RXALL_BIT] =            "rx-all",
 	[NETIF_F_HW_L2FW_DOFFLOAD_BIT] = "l2-fwd-offload",
 	[NETIF_F_HW_TC_BIT] =		 "hw-tc-offload",
+	[NETIF_F_HW_ESP_BIT] =		 "esp-hw-offload",
+	[NETIF_F_HW_ESP_TX_CSUM_BIT] =	 "esp-tx-csum-hw-offload",
 };
 
 static const char
-- 
2.7.4
