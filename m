From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v4 07/10] vxlan: break dependency to network drivers
Date: Sat,  9 Jan 2016 16:07:29 +0100
Message-ID: <1452352052-27574-8-git-send-email-hannes@stressinduktion.org>
References: <1452352052-27574-1-git-send-email-hannes@stressinduktion.org>
Cc: jesse@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:53135 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754865AbcAIPHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2016 10:07:50 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 27B2620933
	for <netdev@vger.kernel.org>; Sat,  9 Jan 2016 10:07:50 -0500 (EST)
In-Reply-To: <1452352052-27574-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/vxlan.c | 20 ++++++++++++++------
 include/net/vxlan.h |  5 +----
 2 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index fecf7b6c732e96..ee45c796cb03cd 100644
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
@@ -2477,6 +2477,9 @@ void vxlan_get_rx_port(struct net_device *dev)
 	__be16 port;
 	unsigned int i;
 
+	if (!dev->netdev_ops->ndo_add_vxlan_port)
+		return;
+
 	spin_lock(&vn->sock_lock);
 	for (i = 0; i < PORT_HASH_SIZE; ++i) {
 		hlist_for_each_entry_rcu(vs, &vn->sock_list[i], hlist) {
@@ -2488,7 +2491,6 @@ void vxlan_get_rx_port(struct net_device *dev)
 	}
 	spin_unlock(&vn->sock_lock);
 }
-EXPORT_SYMBOL_GPL(vxlan_get_rx_port);
 
 /* Initialize the device structure. */
 static void vxlan_setup(struct net_device *dev)
@@ -3164,20 +3166,26 @@ static void vxlan_handle_lowerdev_unregister(struct vxlan_net *vn,
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
