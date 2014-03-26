From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net] vlan: Mask off vlan acceleration features on vlan device.
Date: Wed, 26 Mar 2014 16:25:21 -0400
Message-ID: <1395865521-2318-1-git-send-email-vyasevic@redhat.com>
References: <20140326.155614.1586642968372896396.davem@davemloft.net>
Cc: davem@davemloft.net, kaber@trash.net,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48539 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756058AbaCZUZh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 16:25:37 -0400
In-Reply-To: <20140326.155614.1586642968372896396.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some drivers incorrectly assign vlan acceleration features to
vlan_features thus causing issues for Q-in-Q vlan configurations.
Prevent this once and for all by masking off acceleration features
for vlan devices until such time as we support stacked acceleration.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---

Hi David

> This is at least the second time I've seen a fix exactly like this
> one, it certainly therefore deserves a tree-wide audit if anyone has
> time for that.

How about this approach instead?

 include/linux/netdev_features.h | 7 +++++++
 net/8021q/vlan_dev.c            | 4 +++-
 2 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 1005ebf..84a4e5f 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -163,4 +163,11 @@ enum {
 /* changeable features with no special hardware requirements */
 #define NETIF_F_SOFT_FEATURES	(NETIF_F_GSO | NETIF_F_GRO)
 
+#define NETIF_F_VLAN_FEATURES	(NETIF_F_HW_VLAN_CTAG_FILTER | \
+				 NETIF_F_HW_VLAN_STAG_RX | \
+				 NETIF_F_HW_VLAN_STAG_TX | \
+				 NETIF_F_HW_VLAN_STAG_FILTER | \
+				 NETIF_F_HW_VLAN_STAG_RX | \
+				 NETIF_F_HW_VLAN_STAG_TX)
+
 #endif	/* _LINUX_NETDEV_FEATURES_H */
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index a9591ff..d99e8df 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -576,7 +576,8 @@ static int vlan_dev_init(struct net_device *dev)
 			   NETIF_F_HIGHDMA | NETIF_F_SCTP_CSUM |
 			   NETIF_F_ALL_FCOE;
 
-	dev->features |= real_dev->vlan_features | NETIF_F_LLTX;
+	dev->features |= (real_dev->vlan_features & ~NETIF_F_VLAN_FEATURES) |
+			 NETIF_F_LLTX;
 	dev->gso_max_size = real_dev->gso_max_size;
 
 	/* ipv6 shared card related stuff */
@@ -651,6 +652,7 @@ static netdev_features_t vlan_dev_fix_features(struct net_device *dev,
 	features &= real_dev->features;
 
 	features |= old_features & NETIF_F_SOFT_FEATURES;
+	features &= ~NETIF_F_VLAN_FEATURES;
 	features |= NETIF_F_LLTX;
 
 	return features;
-- 
1.8.5.3
