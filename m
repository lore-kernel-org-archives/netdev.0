From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/3] net: add flags for HW assisted extraction/insertions of switch tags
Date: Wed, 29 Jul 2015 15:32:38 -0700
Message-ID: <1438209160-6898-2-git-send-email-f.fainelli@gmail.com>
References: <1438209160-6898-1-git-send-email-f.fainelli@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438209160-6898-1-git-send-email-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some hardware (e.g: Broadcom's SYSTEMPORT) is capable of automatically
extracting and inserting a proprietary switch tag (e.g: Broadcom tag)
which saves us packet modifications when using DSA. Add the required
ethtool changes and netdevice feature bits to support such devices.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/linux/netdev_features.h |  4 ++++
 include/uapi/linux/ethtool.h    |  2 ++
 net/core/ethtool.c              | 16 ++++++++++++++--
 3 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 9672781c593d..08e00e341497 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -66,6 +66,8 @@ enum {
 	NETIF_F_HW_VLAN_STAG_FILTER_BIT,/* Receive filtering on VLAN STAGs */
 	NETIF_F_HW_L2FW_DOFFLOAD_BIT,	/* Allow L2 Forwarding in Hardware */
 	NETIF_F_BUSY_POLL_BIT,		/* Busy poll */
+	NETIF_F_HW_SWITCH_TAG_RX_BIT,	/* Receive switch tag acceleration */
+	NETIF_F_HW_SWITCH_TAG_TX_BIT,	/* Transmit switch tag acceleration */
 
 	/*
 	 * Add your fresh new feature above and remember to update
@@ -124,6 +126,8 @@ enum {
 #define NETIF_F_HW_VLAN_STAG_TX	__NETIF_F(HW_VLAN_STAG_TX)
 #define NETIF_F_HW_L2FW_DOFFLOAD	__NETIF_F(HW_L2FW_DOFFLOAD)
 #define NETIF_F_BUSY_POLL	__NETIF_F(BUSY_POLL)
+#define NETIF_F_HW_SWITCH_TAG_RX __NETIF_F(HW_SWITCH_TAG_RX)
+#define NETIF_F_HW_SWITCH_TAG_TX __NETIF_F(HW_SWITCH_TAG_TX)
 
 /* Features valid for ethtool to change */
 /* = all defined minus driver/device-class-related */
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index cd1629170103..93710e249032 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -684,6 +684,8 @@ enum ethtool_flags {
 	ETH_FLAG_LRO		= (1 << 15),	/* LRO is enabled */
 	ETH_FLAG_NTUPLE		= (1 << 27),	/* N-tuple filters enabled */
 	ETH_FLAG_RXHASH		= (1 << 28),
+	ETH_FLAG_RXSWITCH	= (1 << 29),	/* RX switch tag offload */
+	ETH_FLAG_TXSWITCH	= (1 << 30),	/* TX switch tag offload */
 };
 
 /* The following structures are for supporting RX network flow
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index b495ab1797fa..6f642dc4bd1d 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -98,6 +98,8 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_RXALL_BIT] =            "rx-all",
 	[NETIF_F_HW_L2FW_DOFFLOAD_BIT] = "l2-fwd-offload",
 	[NETIF_F_BUSY_POLL_BIT] =        "busy-poll",
+	[NETIF_F_HW_SWITCH_TAG_RX_BIT]	= "rx-switch-tag-hw-parse",
+	[NETIF_F_HW_SWITCH_TAG_TX_BIT]	= "tx-switch-tag-hw-insert",
 };
 
 static const char
@@ -298,10 +300,12 @@ static int ethtool_set_one_feature(struct net_device *dev,
 }
 
 #define ETH_ALL_FLAGS    (ETH_FLAG_LRO | ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN | \
-			  ETH_FLAG_NTUPLE | ETH_FLAG_RXHASH)
+			  ETH_FLAG_NTUPLE | ETH_FLAG_RXHASH | ETH_FLAG_RXSWITCH | \
+			  ETH_FLAG_TXSWITCH)
 #define ETH_ALL_FEATURES (NETIF_F_LRO | NETIF_F_HW_VLAN_CTAG_RX | \
 			  NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_NTUPLE | \
-			  NETIF_F_RXHASH)
+			  NETIF_F_RXHASH | NETIF_F_HW_SWITCH_TAG_RX | \
+			  NETIF_F_HW_SWITCH_TAG_TX)
 
 static u32 __ethtool_get_flags(struct net_device *dev)
 {
@@ -317,6 +321,10 @@ static u32 __ethtool_get_flags(struct net_device *dev)
 		flags |= ETH_FLAG_NTUPLE;
 	if (dev->features & NETIF_F_RXHASH)
 		flags |= ETH_FLAG_RXHASH;
+	if (dev->features & NETIF_F_HW_SWITCH_TAG_RX)
+		flags |= ETH_FLAG_RXSWITCH;
+	if (dev->features & NETIF_F_HW_SWITCH_TAG_TX)
+		flags |= ETH_FLAG_TXSWITCH;
 
 	return flags;
 }
@@ -338,6 +346,10 @@ static int __ethtool_set_flags(struct net_device *dev, u32 data)
 		features |= NETIF_F_NTUPLE;
 	if (data & ETH_FLAG_RXHASH)
 		features |= NETIF_F_RXHASH;
+	if (data & ETH_FLAG_RXSWITCH)
+		features |= NETIF_F_HW_SWITCH_TAG_RX;
+	if (data & ETH_FLAG_TXSWITCH)
+		features |= NETIF_F_HW_SWITCH_TAG_TX;
 
 	/* allow changing only bits set in hw_features */
 	changed = (features ^ dev->features) & ETH_ALL_FEATURES;
-- 
2.1.0
