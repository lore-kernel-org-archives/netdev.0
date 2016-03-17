From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] vlan: propagate gso_max_segs
Date: Wed, 16 Mar 2016 21:59:49 -0700
Message-ID: <1458190789.7353.33.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34538 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751678AbcCQE7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 00:59:50 -0400
Received: by mail-pf0-f176.google.com with SMTP id x3so103960531pfb.1
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 21:59:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

vlan drivers lack proper propagation of gso_max_segs from
lower device.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ipvlan/ipvlan_main.c |    2 ++
 drivers/net/macvlan.c            |    2 ++
 net/8021q/vlan.c                 |    1 +
 net/8021q/vlan_dev.c             |    1 +
 4 files changed, 6 insertions(+)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 5802b90..57941d3 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -119,6 +119,7 @@ static int ipvlan_init(struct net_device *dev)
 	dev->features = phy_dev->features & IPVLAN_FEATURES;
 	dev->features |= NETIF_F_LLTX;
 	dev->gso_max_size = phy_dev->gso_max_size;
+	dev->gso_max_segs = phy_dev->gso_max_segs;
 	dev->hard_header_len = phy_dev->hard_header_len;
 
 	ipvlan_set_lockdep_class(dev);
@@ -592,6 +593,7 @@ static int ipvlan_device_event(struct notifier_block *unused,
 		list_for_each_entry(ipvlan, &port->ipvlans, pnode) {
 			ipvlan->dev->features = dev->features & IPVLAN_FEATURES;
 			ipvlan->dev->gso_max_size = dev->gso_max_size;
+			ipvlan->dev->gso_max_segs = dev->gso_max_segs;
 			netdev_features_change(ipvlan->dev);
 		}
 		break;
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 6e953e3..2bcf1f3 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -803,6 +803,7 @@ static int macvlan_init(struct net_device *dev)
 	dev->hw_features	|= NETIF_F_LRO;
 	dev->vlan_features	= lowerdev->vlan_features & MACVLAN_FEATURES;
 	dev->gso_max_size	= lowerdev->gso_max_size;
+	dev->gso_max_segs	= lowerdev->gso_max_segs;
 	dev->hard_header_len	= lowerdev->hard_header_len;
 
 	macvlan_set_lockdep_class(dev);
@@ -1532,6 +1533,7 @@ static int macvlan_device_event(struct notifier_block *unused,
 	case NETDEV_FEAT_CHANGE:
 		list_for_each_entry(vlan, &port->vlans, list) {
 			vlan->dev->gso_max_size = dev->gso_max_size;
+			vlan->dev->gso_max_segs = dev->gso_max_segs;
 			netdev_update_features(vlan->dev);
 		}
 		break;
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 69929c0..a1e273a 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -311,6 +311,7 @@ static void vlan_transfer_features(struct net_device *dev,
 	struct vlan_dev_priv *vlan = vlan_dev_priv(vlandev);
 
 	vlandev->gso_max_size = dev->gso_max_size;
+	vlandev->gso_max_segs = dev->gso_max_segs;
 
 	if (vlan_hw_offload_capable(dev->features, vlan->vlan_proto))
 		vlandev->hard_header_len = dev->hard_header_len;
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index e416a40..e7e6257 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -551,6 +551,7 @@ static int vlan_dev_init(struct net_device *dev)
 	dev->features |= real_dev->vlan_features | NETIF_F_LLTX |
 			 NETIF_F_GSO_SOFTWARE;
 	dev->gso_max_size = real_dev->gso_max_size;
+	dev->gso_max_segs = real_dev->gso_max_segs;
 	if (dev->features & NETIF_F_VLAN_FEATURES)
 		netdev_warn(real_dev, "VLAN features are set incorrectly.  Q-in-Q configurations may not work correctly.\n");
 
