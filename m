From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net-next 1/6] net: add new netdevice feature for tunnel offloading
Date: Fri, 30 Jun 2017 15:19:45 +0200
Message-ID: <79e58d61b15ff497524cde07c00c2165cf033ef2.1498743778.git.sd@queasysnail.net>
References: <cover.1498743778.git.sd@queasysnail.net>
Cc: Jiri Benc <jbenc@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27052 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751899AbdF3NUY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Jun 2017 09:20:24 -0400
In-Reply-To: <cover.1498743778.git.sd@queasysnail.net>
In-Reply-To: <cover.1498743778.git.sd@queasysnail.net>
References: <cover.1498743778.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a new netdevice feature, so that tunnel offloading can be
disabled by the administrator on some netdevices, using the
"tunnel-offload" ethtool feature.

This feature is set for all devices that provide ndo_udp_tunnel_add.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 include/linux/netdev_features.h | 2 ++
 net/core/dev.c                  | 6 ++++++
 net/core/ethtool.c              | 1 +
 3 files changed, 9 insertions(+)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 1d4737cffc71..40a098e40d5d 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -76,6 +76,7 @@ enum {
 	NETIF_F_HW_TC_BIT,		/* Offload TC infrastructure */
 	NETIF_F_HW_ESP_BIT,		/* Hardware ESP transformation offload */
 	NETIF_F_HW_ESP_TX_CSUM_BIT,	/* ESP with TX checksum offload */
+	NETIF_F_TUNNEL_OFFLOAD_BIT,     /* Tunnel offloads */
 
 	/*
 	 * Add your fresh new feature above and remember to update
@@ -140,6 +141,7 @@ enum {
 #define NETIF_F_HW_TC		__NETIF_F(HW_TC)
 #define NETIF_F_HW_ESP		__NETIF_F(HW_ESP)
 #define NETIF_F_HW_ESP_TX_CSUM	__NETIF_F(HW_ESP_TX_CSUM)
+#define	NETIF_F_TUNNEL_OFFLOAD  __NETIF_F(TUNNEL_OFFLOAD)
 
 #define for_each_netdev_feature(mask_addr, bit)	\
 	for_each_set_bit(bit, (unsigned long *)mask_addr, NETDEV_FEATURE_COUNT)
diff --git a/net/core/dev.c b/net/core/dev.c
index a91572aa73d5..d97f7b39df23 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7505,6 +7505,12 @@ int register_netdevice(struct net_device *dev)
 	 */
 	dev->hw_features |= NETIF_F_SOFT_FEATURES;
 	dev->features |= NETIF_F_SOFT_FEATURES;
+
+	if (dev->netdev_ops->ndo_udp_tunnel_add) {
+		dev->features |= NETIF_F_TUNNEL_OFFLOAD;
+		dev->hw_features |= NETIF_F_TUNNEL_OFFLOAD;
+	}
+
 	dev->wanted_features = dev->features & dev->hw_features;
 
 	if (!(dev->flags & IFF_LOOPBACK))
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 03111a2d6653..b693421d5d71 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -106,6 +106,7 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_HW_TC_BIT] =		 "hw-tc-offload",
 	[NETIF_F_HW_ESP_BIT] =		 "esp-hw-offload",
 	[NETIF_F_HW_ESP_TX_CSUM_BIT] =	 "esp-tx-csum-hw-offload",
+	[NETIF_F_TUNNEL_OFFLOAD_BIT] =	 "tunnel-offload",
 };
 
 static const char
-- 
2.13.2
