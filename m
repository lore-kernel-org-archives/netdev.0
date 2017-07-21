From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net-next v2 1/6] net: add new netdevice feature for offload of RX port for UDP tunnels
Date: Fri, 21 Jul 2017 12:49:28 +0200
Message-ID: <7ce4d7e67952fd718f01deedf218c9e3eb130c08.1500632570.git.sd@queasysnail.net>
References: <cover.1500632570.git.sd@queasysnail.net>
Cc: Jiri Benc <jbenc@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39308 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753509AbdGUKtx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Jul 2017 06:49:53 -0400
In-Reply-To: <cover.1500632570.git.sd@queasysnail.net>
In-Reply-To: <cover.1500632570.git.sd@queasysnail.net>
References: <cover.1500632570.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a new netdevice feature, so that the offloading of RX port for
UDP tunnels can be disabled by the administrator on some netdevices,
using the "rx-udp_tunnel-port-offload" feature in ethtool.

This feature is set for all devices that provide ndo_udp_tunnel_add.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 include/linux/netdev_features.h | 2 ++
 net/core/dev.c                  | 6 ++++++
 net/core/ethtool.c              | 1 +
 3 files changed, 9 insertions(+)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index ebd273627334..dc8b4896b77b 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -75,6 +75,7 @@ enum {
 	NETIF_F_HW_TC_BIT,		/* Offload TC infrastructure */
 	NETIF_F_HW_ESP_BIT,		/* Hardware ESP transformation offload */
 	NETIF_F_HW_ESP_TX_CSUM_BIT,	/* ESP with TX checksum offload */
+	NETIF_F_RX_UDP_TUNNEL_PORT_BIT, /* Offload of RX port for UDP tunnels */
 
 	/*
 	 * Add your fresh new feature above and remember to update
@@ -138,6 +139,7 @@ enum {
 #define NETIF_F_HW_TC		__NETIF_F(HW_TC)
 #define NETIF_F_HW_ESP		__NETIF_F(HW_ESP)
 #define NETIF_F_HW_ESP_TX_CSUM	__NETIF_F(HW_ESP_TX_CSUM)
+#define	NETIF_F_RX_UDP_TUNNEL_PORT  __NETIF_F(RX_UDP_TUNNEL_PORT)
 
 #define for_each_netdev_feature(mask_addr, bit)	\
 	for_each_set_bit(bit, (unsigned long *)mask_addr, NETDEV_FEATURE_COUNT)
diff --git a/net/core/dev.c b/net/core/dev.c
index 509af6ce8831..9081134adc0d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7530,6 +7530,12 @@ int register_netdevice(struct net_device *dev)
 	 */
 	dev->hw_features |= NETIF_F_SOFT_FEATURES;
 	dev->features |= NETIF_F_SOFT_FEATURES;
+
+	if (dev->netdev_ops->ndo_udp_tunnel_add) {
+		dev->features |= NETIF_F_RX_UDP_TUNNEL_PORT;
+		dev->hw_features |= NETIF_F_RX_UDP_TUNNEL_PORT;
+	}
+
 	dev->wanted_features = dev->features & dev->hw_features;
 
 	if (!(dev->flags & IFF_LOOPBACK))
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 78408ab77a10..b987bc475fc8 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -105,6 +105,7 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_HW_TC_BIT] =		 "hw-tc-offload",
 	[NETIF_F_HW_ESP_BIT] =		 "esp-hw-offload",
 	[NETIF_F_HW_ESP_TX_CSUM_BIT] =	 "esp-tx-csum-hw-offload",
+	[NETIF_F_RX_UDP_TUNNEL_PORT_BIT] =	 "rx-udp_tunnel-port-offload",
 };
 
 static const char
-- 
2.13.2
