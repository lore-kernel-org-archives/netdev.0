From: greearb@candelatech.com
Subject: [PATCH 1/2] net:  Support RXFCS feature flag.
Date: Thu, 23 Jun 2011 16:13:38 -0700
Message-ID: <1308870819-15938-2-git-send-email-greearb@candelatech.com>
References: <1308870819-15938-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:37365 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934569Ab1FWXOA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 19:14:00 -0400
In-Reply-To: <1308870819-15938-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

When set, this causes the Ethernet FCS to be appended
to the end of the skb.

Useful for sniffing packets.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 06a8318... afdc2da... M	include/linux/ethtool.h
:100644 100644 d0ab610... 55f359e... M	include/linux/netdev_features.h
:100644 100644 80b88fe... 4920c73... M	net/core/ethtool.c
 include/linux/ethtool.h         |    1 +
 include/linux/netdev_features.h |    2 ++
 net/core/ethtool.c              |   10 ++++++++--
 3 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 06a8318..afdc2da 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -347,6 +347,7 @@ struct ethtool_perm_addr {
  * flag differs from the read-only value.
  */
 enum ethtool_flags {
+	ETH_FLAG_RXFCS		= (1 << 0),	/* Append FCS to skb */
 	ETH_FLAG_TXVLAN		= (1 << 7),	/* TX VLAN offload enabled */
 	ETH_FLAG_RXVLAN		= (1 << 8),	/* RX VLAN offload enabled */
 	ETH_FLAG_LRO		= (1 << 15),	/* LRO is enabled */
diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index d0ab610..55f359e 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -54,6 +54,7 @@ enum {
 	NETIF_F_RXCSUM_BIT,		/* Receive checksumming offload */
 	NETIF_F_NOCACHE_COPY_BIT,	/* Use no-cache copyfromuser */
 	NETIF_F_LOOPBACK_BIT,		/* Enable loopback */
+	NETIF_F_RXFCS_BIT,		/* Append FCS to skb */
 
 	/*
 	 * Add your fresh new feature above and remember to update
@@ -98,6 +99,7 @@ enum {
 #define NETIF_F_RXCSUM		__NETIF_F(RXCSUM)
 #define NETIF_F_NOCACHE_COPY	__NETIF_F(NOCACHE_COPY)
 #define NETIF_F_LOOPBACK	__NETIF_F(LOOPBACK)
+#define NETIF_F_RXFCS		__NETIF_F(RXFCS)
 
 /* Features valid for ethtool to change */
 /* = all defined minus driver/device-class-related */
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 80b88fe..4920c73 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -74,6 +74,7 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_RXCSUM_BIT] =           "rx-checksum",
 	[NETIF_F_NOCACHE_COPY_BIT] =     "tx-nocache-copy",
 	[NETIF_F_LOOPBACK_BIT] =         "loopback",
+	[NETIF_F_RXFCS_BIT] =            "rx-fcs",
 };
 
 static int ethtool_get_features(struct net_device *dev, void __user *useraddr)
@@ -249,9 +250,10 @@ static int ethtool_set_one_feature(struct net_device *dev,
 }
 
 #define ETH_ALL_FLAGS    (ETH_FLAG_LRO | ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN | \
-			  ETH_FLAG_NTUPLE | ETH_FLAG_RXHASH)
+			  ETH_FLAG_NTUPLE | ETH_FLAG_RXHASH | ETH_FLAG_RXFCS)
 #define ETH_ALL_FEATURES (NETIF_F_LRO | NETIF_F_HW_VLAN_RX | \
-			  NETIF_F_HW_VLAN_TX | NETIF_F_NTUPLE | NETIF_F_RXHASH)
+			  NETIF_F_HW_VLAN_TX | NETIF_F_NTUPLE | \
+			  NETIF_F_RXHASH | NETIF_F_RXFCS)
 
 static u32 __ethtool_get_flags(struct net_device *dev)
 {
@@ -262,6 +264,8 @@ static u32 __ethtool_get_flags(struct net_device *dev)
 	if (dev->features & NETIF_F_HW_VLAN_TX)	flags |= ETH_FLAG_TXVLAN;
 	if (dev->features & NETIF_F_NTUPLE)	flags |= ETH_FLAG_NTUPLE;
 	if (dev->features & NETIF_F_RXHASH)	flags |= ETH_FLAG_RXHASH;
+	if (dev->features & NETIF_F_RXFCS)
+		flags |= ETH_FLAG_RXFCS;
 
 	return flags;
 }
@@ -278,6 +282,8 @@ static int __ethtool_set_flags(struct net_device *dev, u32 data)
 	if (data & ETH_FLAG_TXVLAN)	features |= NETIF_F_HW_VLAN_TX;
 	if (data & ETH_FLAG_NTUPLE)	features |= NETIF_F_NTUPLE;
 	if (data & ETH_FLAG_RXHASH)	features |= NETIF_F_RXHASH;
+	if (data & ETH_FLAG_RXFCS)
+		features |= NETIF_F_RXFCS;
 
 	/* allow changing only bits set in hw_features */
 	changed = (features ^ dev->features) & ETH_ALL_FEATURES;
-- 
1.7.3.4

