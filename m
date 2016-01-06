From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 1/2] vxlan: break dependency to network drivers
Date: Wed,  6 Jan 2016 16:41:42 +0100
Message-ID: <1452094903-12934-2-git-send-email-hannes@stressinduktion.org>
References: <1452094903-12934-1-git-send-email-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:41679 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751572AbcAFPlu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 10:41:50 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 283A320B5F
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 10:41:50 -0500 (EST)
Received: from z.localhost.localdomain (unknown [217.192.177.51])
	by mail.messagingengine.com (Postfix) with ESMTPA id A2D1BC016C4
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 10:41:49 -0500 (EST)
In-Reply-To: <1452094903-12934-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/vxlan.c       | 17 +++++++++++------
 include/linux/netdevice.h |  1 +
 include/net/vxlan.h       |  5 +----
 3 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index fecf7b6c732e96..fbfac24238c06c 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2468,7 +2468,7 @@ static struct device_type vxlan_type = {
  * supply the listening VXLAN udp ports. Callers are expected
  * to implement the ndo_add_vxlan_port.
  */
-void vxlan_get_rx_port(struct net_device *dev)
+static void vxlan_notify_refresh_netdev(struct net_device *dev)
 {
 	struct vxlan_sock *vs;
 	struct net *net = dev_net(dev);
@@ -2488,7 +2488,6 @@ void vxlan_get_rx_port(struct net_device *dev)
 	}
 	spin_unlock(&vn->sock_lock);
 }
-EXPORT_SYMBOL_GPL(vxlan_get_rx_port);
 
 /* Initialize the device structure. */
 static void vxlan_setup(struct net_device *dev)
@@ -3164,20 +3163,26 @@ static void vxlan_handle_lowerdev_unregister(struct vxlan_net *vn,
 	unregister_netdevice_many(&list_kill);
 }
 
-static int vxlan_lowerdev_event(struct notifier_block *unused,
-				unsigned long event, void *ptr)
+static int vxlan_notifier(struct notifier_block *unused,
+			  unsigned long event, void *ptr)
 {
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
 	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
 
-	if (event == NETDEV_UNREGISTER)
+	switch (event) {
+	case NETDEV_REFRESH_OFFLOAD_VXLAN:
+		vxlan_notify_refresh_netdev(dev);
+		break;
+	case NETDEV_UNREGISTER:
 		vxlan_handle_lowerdev_unregister(vn, dev);
+		break;
+	}
 
 	return NOTIFY_DONE;
 }
 
 static struct notifier_block vxlan_notifier_block __read_mostly = {
-	.notifier_call = vxlan_lowerdev_event,
+	.notifier_call = vxlan_notifier,
 };
 
 static __net_init int vxlan_init_net(struct net *net)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c20b814e46a072..d57d5074b33315 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2183,6 +2183,7 @@ struct netdev_lag_lower_state_info {
 #define NETDEV_BONDING_INFO	0x0019
 #define NETDEV_PRECHANGEUPPER	0x001A
 #define NETDEV_CHANGELOWERSTATE	0x001B
+#define NETDEV_REFRESH_OFFLOAD_VXLAN	0x001C
 
 int register_netdevice_notifier(struct notifier_block *nb);
 int unregister_netdevice_notifier(struct notifier_block *nb);
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 0fb86442544b26..2b5617850e4097 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -242,13 +242,10 @@ static inline netdev_features_t vxlan_features_check(struct sk_buff *skb,
 /* IPv6 header + UDP + VXLAN + Ethernet header */
 #define VXLAN6_HEADROOM (40 + 8 + 8 + 14)
 
-#if IS_ENABLED(CONFIG_VXLAN)
-void vxlan_get_rx_port(struct net_device *netdev);
-#else
 static inline void vxlan_get_rx_port(struct net_device *netdev)
 {
+	call_netdevice_notifiers(NETDEV_REFRESH_OFFLOAD_VXLAN, netdev);
 }
-#endif
 
 static inline unsigned short vxlan_get_sk_family(struct vxlan_sock *vs)
 {
-- 
2.5.0
