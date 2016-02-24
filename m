From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net] net/8021q: Check the correct vlan filter capability
Date: Wed, 24 Feb 2016 18:39:19 +0200
Message-ID: <1456331959-3573-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Gal Pressman <galp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Patrick McHardy <kaber@trash.net>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:43308 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758173AbcBXQlD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 11:41:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Use dev->hw_features in vlan_hw_filter_capable instead of dev->features,
since dev->features can be turned on/off dynamically.

Netdev features can be changed dynamically to off after vlan_vid_add
was called, thus vlan_vid_del will skip ndo_vlan_rx_kill_vid and will
leave the device driver with un-freed resources.

Fixes: 8ad227ff89a7 ("net: vlan: add 802.1ad support")
Signed-off-by: Gal Pressman <galp@mellanox.com>
Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 net/8021q/vlan.c      |    4 ++--
 net/8021q/vlan_core.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index d2cd9de..f744d8c 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -365,7 +365,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 	}
 
 	if ((event == NETDEV_UP) &&
-	    (dev->features & NETIF_F_HW_VLAN_CTAG_FILTER)) {
+	    (dev->hw_features & NETIF_F_HW_VLAN_CTAG_FILTER)) {
 		pr_info("adding VLAN 0 to HW filter on device %s\n",
 			dev->name);
 		vlan_vid_add(dev, htons(ETH_P_8021Q), 0);
@@ -417,7 +417,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 		struct net_device *tmp;
 		LIST_HEAD(close_list);
 
-		if (dev->features & NETIF_F_HW_VLAN_CTAG_FILTER)
+		if (dev->hw_features & NETIF_F_HW_VLAN_CTAG_FILTER)
 			vlan_vid_del(dev, htons(ETH_P_8021Q), 0);
 
 		/* Put all VLANs for this dev in the down state too.  */
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index e2ed698..bab95bd 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -162,10 +162,10 @@ static bool vlan_hw_filter_capable(const struct net_device *dev,
 				     const struct vlan_vid_info *vid_info)
 {
 	if (vid_info->proto == htons(ETH_P_8021Q) &&
-	    dev->features & NETIF_F_HW_VLAN_CTAG_FILTER)
+	    dev->hw_features & NETIF_F_HW_VLAN_CTAG_FILTER)
 		return true;
 	if (vid_info->proto == htons(ETH_P_8021AD) &&
-	    dev->features & NETIF_F_HW_VLAN_STAG_FILTER)
+	    dev->hw_features & NETIF_F_HW_VLAN_STAG_FILTER)
 		return true;
 	return false;
 }
-- 
1.7.1
