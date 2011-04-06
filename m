From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH 04/20] net-vlan: extending (hw_/wanted_/vlan_)features fields to a bitmap.
Date: Tue,  5 Apr 2011 17:44:09 -0700
Message-ID: <1302050665-10460-5-git-send-email-maheshb@google.com>
References: <1302050665-10460-1-git-send-email-maheshb@google.com>
 <1302050665-10460-2-git-send-email-maheshb@google.com>
 <1302050665-10460-3-git-send-email-maheshb@google.com>
 <1302050665-10460-4-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:28060 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754147Ab1DFAoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 20:44:54 -0400
In-Reply-To: <1302050665-10460-4-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Converting current use of (hw_/wanted_/vlan_)features to
legacy_(hw_/wanted_/vlan_)features to differntiate from the proposed usage.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 include/linux/if_vlan.h |    4 ++--
 net/8021q/vlan.c        |   12 ++++++------
 net/8021q/vlan_dev.c    |    9 +++++----
 3 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 635e1fa..1c71568 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -276,7 +276,7 @@ static inline struct sk_buff *__vlan_hwaccel_put_tag(struct sk_buff *skb,
  */
 static inline struct sk_buff *vlan_put_tag(struct sk_buff *skb, u16 vlan_tci)
 {
-	if (skb->dev->features & NETIF_F_HW_VLAN_TX) {
+	if (skb->dev->legacy_features & NETIF_F_HW_VLAN_TX) {
 		return __vlan_hwaccel_put_tag(skb, vlan_tci);
 	} else {
 		return __vlan_put_tag(skb, vlan_tci);
@@ -332,7 +332,7 @@ static inline int __vlan_hwaccel_get_tag(const struct sk_buff *skb,
  */
 static inline int vlan_get_tag(const struct sk_buff *skb, u16 *vlan_tci)
 {
-	if (skb->dev->features & NETIF_F_HW_VLAN_TX) {
+	if (skb->dev->legacy_features & NETIF_F_HW_VLAN_TX) {
 		return __vlan_hwaccel_get_tag(skb, vlan_tci);
 	} else {
 		return __vlan_get_tag(skb, vlan_tci);
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index e47600b..93325b8 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -119,7 +119,7 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 	 * HW accelerating devices or SW vlan input packet processing if
 	 * VLAN is not 0 (leave it there for 802.1p).
 	 */
-	if (vlan_id && (real_dev->features & NETIF_F_HW_VLAN_FILTER))
+	if (vlan_id && (real_dev->legacy_features & NETIF_F_HW_VLAN_FILTER))
 		ops->ndo_vlan_rx_kill_vid(real_dev, vlan_id);
 
 	grp->nr_vlans--;
@@ -151,12 +151,12 @@ int vlan_check_real_dev(struct net_device *real_dev, u16 vlan_id)
 	const char *name = real_dev->name;
 	const struct net_device_ops *ops = real_dev->netdev_ops;
 
-	if (real_dev->features & NETIF_F_VLAN_CHALLENGED) {
+	if (real_dev->legacy_features & NETIF_F_VLAN_CHALLENGED) {
 		pr_info("8021q: VLANs not supported on %s\n", name);
 		return -EOPNOTSUPP;
 	}
 
-	if ((real_dev->features & NETIF_F_HW_VLAN_FILTER) &&
+	if ((real_dev->legacy_features & NETIF_F_HW_VLAN_FILTER) &&
 	    (!ops->ndo_vlan_rx_add_vid || !ops->ndo_vlan_rx_kill_vid)) {
 		pr_info("8021q: Device %s has buggy VLAN hw accel\n", name);
 		return -EOPNOTSUPP;
@@ -212,7 +212,7 @@ int register_vlan_dev(struct net_device *dev)
 			ops->ndo_vlan_rx_register(real_dev, ngrp);
 		rcu_assign_pointer(real_dev->vlgrp, ngrp);
 	}
-	if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
+	if (real_dev->legacy_features & NETIF_F_HW_VLAN_FILTER)
 		ops->ndo_vlan_rx_add_vid(real_dev, vlan_id);
 
 	return 0;
@@ -329,7 +329,7 @@ static void vlan_transfer_features(struct net_device *dev,
 {
 	vlandev->gso_max_size = dev->gso_max_size;
 
-	if (dev->features & NETIF_F_HW_VLAN_TX)
+	if (dev->legacy_features & NETIF_F_HW_VLAN_TX)
 		vlandev->hard_header_len = dev->hard_header_len;
 	else
 		vlandev->hard_header_len = dev->hard_header_len + VLAN_HLEN;
@@ -375,7 +375,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 		__vlan_device_event(dev, event);
 
 	if ((event == NETDEV_UP) &&
-	    (dev->features & NETIF_F_HW_VLAN_FILTER) &&
+	    (dev->legacy_features & NETIF_F_HW_VLAN_FILTER) &&
 	    dev->netdev_ops->ndo_vlan_rx_add_vid) {
 		pr_info("8021q: adding VLAN 0 to HW filter on device %s\n",
 			dev->name);
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index b84a46b..52f2f44 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -704,8 +704,9 @@ static int vlan_dev_init(struct net_device *dev)
 					  (1<<__LINK_STATE_DORMANT))) |
 		      (1<<__LINK_STATE_PRESENT);
 
-	dev->hw_features = real_dev->vlan_features & NETIF_F_ALL_TX_OFFLOADS;
-	dev->features |= real_dev->vlan_features | NETIF_F_LLTX;
+	dev->legacy_hw_features =
+		real_dev->legacy_vlan_features & NETIF_F_ALL_TX_OFFLOADS;
+	dev->legacy_features |= real_dev->legacy_vlan_features | NETIF_F_LLTX;
 	dev->gso_max_size = real_dev->gso_max_size;
 
 	/* ipv6 shared card related stuff */
@@ -721,7 +722,7 @@ static int vlan_dev_init(struct net_device *dev)
 #endif
 
 	dev->needed_headroom = real_dev->needed_headroom;
-	if (real_dev->features & NETIF_F_HW_VLAN_TX) {
+	if (real_dev->legacy_features & NETIF_F_HW_VLAN_TX) {
 		dev->header_ops      = real_dev->header_ops;
 		dev->hard_header_len = real_dev->hard_header_len;
 	} else {
@@ -763,7 +764,7 @@ static u32 vlan_dev_fix_features(struct net_device *dev, u32 features)
 {
 	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
 
-	features &= (real_dev->features | NETIF_F_LLTX);
+	features &= (real_dev->legacy_features | NETIF_F_LLTX);
 	if (dev_ethtool_get_rx_csum(real_dev))
 		features |= NETIF_F_RXCSUM;
 
-- 
1.7.3.1

