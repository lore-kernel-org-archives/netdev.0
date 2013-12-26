From: Florian Westphal <fw@strlen.de>
Subject: [PATCH v2] macvlan: fix netdev feature propagation from lower device
Date: Thu, 26 Dec 2013 12:17:00 +0100
Message-ID: <1388056620-2008-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:51705 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751944Ab3LZLUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 06:20:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are inconsistencies wrt. feature propagation/inheritance between
macvlan and the underlying interface.

When a feature is turned off on the real device before a macvlan is
created on top, these will remain enabled on the macvlan device, whereas
turning off the feature on the lower device after macvlan creation the
kernel will propagate the changes to the macvlan.

The second issue is that, when propagating changes from underlying device
to the macvlan interface, macvlan can erronously lose its NETIF_F_LLTX flag,
as features are anded with the underlying device.

However, LLTX should be kept since it has no dependencies on physical
hardware (LLTX is set on macvlan creation regardless of the lower
device properties, see 8ffab51b3dfc54876f145f15b351c41f3f703195
(macvlan: lockless tx path).

The LLTX flag is now forced regardless of user settings in absence of
layer2 hw acceleration (a6cc0cfa72e0b6d9f2c8fd858aa,
net: Add layer 2 hardware acceleration operations for macvlan devices).

Use netdev_increment_features to rebuild the feature set on capability
changes on either the lower device or on the macvlan interface.

As pointed out by Ben Hutchings, use netdev_update_features on
NETDEV_FEAT_CHANGE event (it calls macvlan_fix_features/netdev_features_change
if needed).

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Changes since v1:
 - use netdev_update_features on NETDEV_FEAT_CHANGE event

 drivers/net/macvlan.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 24ea994..b980b2f 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -690,8 +690,19 @@ static netdev_features_t macvlan_fix_features(struct net_device *dev,
 					      netdev_features_t features)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
+	netdev_features_t mask;
 
-	return features & (vlan->set_features | ~MACVLAN_FEATURES);
+	features |= NETIF_F_ALL_FOR_ALL;
+	features &= (vlan->set_features | ~MACVLAN_FEATURES);
+	mask = features;
+
+	features = netdev_increment_features(vlan->lowerdev->features,
+					     features,
+					     mask);
+	if (!vlan->fwd_priv)
+		features |= NETIF_F_LLTX;
+
+	return features;
 }
 
 static const struct ethtool_ops macvlan_ethtool_ops = {
@@ -1010,9 +1021,8 @@ static int macvlan_device_event(struct notifier_block *unused,
 		break;
 	case NETDEV_FEAT_CHANGE:
 		list_for_each_entry(vlan, &port->vlans, list) {
-			vlan->dev->features = dev->features & MACVLAN_FEATURES;
 			vlan->dev->gso_max_size = dev->gso_max_size;
-			netdev_features_change(vlan->dev);
+			netdev_update_features(vlan->dev);
 		}
 		break;
 	case NETDEV_UNREGISTER:
-- 
1.8.1.5
