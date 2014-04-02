From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] net: add busy_poll device feature
Date: Wed,  2 Apr 2014 23:09:31 +0200
Message-ID: <1396472971-1450-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kaber@trash.net, edumazet@google.com,
	vyasevic@redhat.com, horms@verge.net.au, vfalico@redhat.com,
	nicolas.dichtel@6wind.com, ebiederm@xmission.com,
	stephen@networkplumber.org, hkchu@google.com, yanb@mellanox.com,
	john.r.fastabend@intel.com, dragos.foianu@gmail.com, bjorn@mork.no,
	mschmidt@redhat.com, fernando_b1@lab.ntt.co.jp, ben@decadent.org.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:61677 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933074AbaDBVJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 17:09:36 -0400
Received: by mail-wg0-f41.google.com with SMTP id n12so883957wgh.24
        for <netdev@vger.kernel.org>; Wed, 02 Apr 2014 14:09:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently there is no way how to find out if a device supports busy
polling. So add a feature and make it dependent on ndo_busy_poll
existence.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/netdev_features.h | 2 ++
 net/core/dev.c                  | 7 +++++++
 net/core/ethtool.c              | 1 +
 3 files changed, 10 insertions(+)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 5a09a48..c26d0ec 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -63,6 +63,7 @@ enum {
 	NETIF_F_HW_VLAN_STAG_RX_BIT,	/* Receive VLAN STAG HW acceleration */
 	NETIF_F_HW_VLAN_STAG_FILTER_BIT,/* Receive filtering on VLAN STAGs */
 	NETIF_F_HW_L2FW_DOFFLOAD_BIT,	/* Allow L2 Forwarding in Hardware */
+	NETIF_F_BUSY_POLL_BIT,		/* Busy poll */
 
 	/*
 	 * Add your fresh new feature above and remember to update
@@ -118,6 +119,7 @@ enum {
 #define NETIF_F_HW_VLAN_STAG_RX	__NETIF_F(HW_VLAN_STAG_RX)
 #define NETIF_F_HW_VLAN_STAG_TX	__NETIF_F(HW_VLAN_STAG_TX)
 #define NETIF_F_HW_L2FW_DOFFLOAD	__NETIF_F(HW_L2FW_DOFFLOAD)
+#define NETIF_F_BUSY_POLL	__NETIF_F(BUSY_POLL)
 
 /* Features valid for ethtool to change */
 /* = all defined minus driver/device-class-related */
diff --git a/net/core/dev.c b/net/core/dev.c
index 48d81e4..fe30c8e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5696,6 +5696,13 @@ static netdev_features_t netdev_fix_features(struct net_device *dev,
 		}
 	}
 
+#ifdef CONFIG_NET_RX_BUSY_POLL
+	if (dev->netdev_ops->ndo_busy_poll)
+		features |= NETIF_F_BUSY_POLL;
+	else
+#endif
+		features &= ~NETIF_F_BUSY_POLL;
+
 	return features;
 }
 
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 30071de..640ba0e 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -97,6 +97,7 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_RXFCS_BIT] =            "rx-fcs",
 	[NETIF_F_RXALL_BIT] =            "rx-all",
 	[NETIF_F_HW_L2FW_DOFFLOAD_BIT] = "l2-fwd-offload",
+	[NETIF_F_BUSY_POLL_BIT] =        "busy-poll",
 };
 
 static int ethtool_get_features(struct net_device *dev, void __user *useraddr)
-- 
1.9.0
