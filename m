From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v3 7/8] vxlan: break dependency to network drivers
Date: Thu,  7 Jan 2016 00:39:30 +0100
Message-ID: <1452123571-19140-8-git-send-email-hannes@stressinduktion.org>
References: <1452123571-19140-1-git-send-email-hannes@stressinduktion.org>
Cc: jesse@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:52394 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752709AbcAFXju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 18:39:50 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 3CCEC20566
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 18:39:50 -0500 (EST)
In-Reply-To: <1452123571-19140-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/vxlan.c | 17 +++++++++++------
 include/net/vxlan.h |  5 +----
 2 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index fecf7b6c732e96..10f1304d58e1ea 100644
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
+	case NETDEV_REFRESH_OFFLOADS:
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
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 0fb86442544b26..48d0450160c91f 100644
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
+	call_netdevice_notifiers(NETDEV_REFRESH_OFFLOADS, netdev);
 }
-#endif
 
 static inline unsigned short vxlan_get_sk_family(struct vxlan_sock *vs)
 {
-- 
2.5.0
