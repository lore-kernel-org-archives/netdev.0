From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net-next] macvlan: allow setting LRO independently of lower
 device
Date: Fri, 5 Dec 2014 17:05:49 +0100
Message-ID: <20141205190937.99BD6A0BB0@unicorn.suse.cz>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since commit fbe168ba91f7 ("net: generic dev_disable_lro() stacked
device handling"), dev_disable_lro() zeroes NETIF_F_LRO feature flag
first for a macvlan device and then for its lower device. As an attempt
to set NETIF_F_LRO to zero is ignored, dev_disable_lro() issues a
warning and taints kernel.

Allowing NETIF_F_LRO to be set independently of the lower device
consists of three parts:

  - add the flag to hw_features to allow toggling it
  - allow setting it to 0 even if lower device has the flag set
  - add the flag to MACVLAN_FEATURES to restore copying from lower
    device on macvlan creation

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 drivers/net/macvlan.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 9538674..10604db 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -747,7 +747,7 @@ static struct lock_class_key macvlan_netdev_addr_lock_key;
 
 #define MACVLAN_FEATURES \
 	(NETIF_F_SG | NETIF_F_ALL_CSUM | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST | \
-	 NETIF_F_GSO | NETIF_F_TSO | NETIF_F_UFO | \
+	 NETIF_F_GSO | NETIF_F_TSO | NETIF_F_UFO | NETIF_F_LRO | \
 	 NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_GRO | NETIF_F_RXCSUM | \
 	 NETIF_F_HW_VLAN_CTAG_FILTER | NETIF_F_HW_VLAN_STAG_FILTER)
 
@@ -784,6 +784,7 @@ static int macvlan_init(struct net_device *dev)
 				  (lowerdev->state & MACVLAN_STATE_MASK);
 	dev->features 		= lowerdev->features & MACVLAN_FEATURES;
 	dev->features		|= ALWAYS_ON_FEATURES;
+	dev->hw_features	|= NETIF_F_LRO;
 	dev->vlan_features	= lowerdev->vlan_features & MACVLAN_FEATURES;
 	dev->gso_max_size	= lowerdev->gso_max_size;
 	dev->iflink		= lowerdev->ifindex;
@@ -936,15 +937,15 @@ static netdev_features_t macvlan_fix_features(struct net_device *dev,
 					      netdev_features_t features)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
+	netdev_features_t lowerdev_features = vlan->lowerdev->features;
 	netdev_features_t mask;
 
 	features |= NETIF_F_ALL_FOR_ALL;
 	features &= (vlan->set_features | ~MACVLAN_FEATURES);
 	mask = features;
 
-	features = netdev_increment_features(vlan->lowerdev->features,
-					     features,
-					     mask);
+	lowerdev_features &= (features | ~NETIF_F_LRO);
+	features = netdev_increment_features(lowerdev_features, features, mask);
 	features |= ALWAYS_ON_FEATURES;
 	features &= ~NETIF_F_NETNS_LOCAL;
 
-- 
1.8.4.5
