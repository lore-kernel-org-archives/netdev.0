From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v2 2/3] vxlan: use netdev_atomic notifier chain to remove dependency from drivers
Date: Wed,  6 Jan 2016 21:20:29 +0100
Message-ID: <1452111630-16322-3-git-send-email-hannes@stressinduktion.org>
References: <1452111630-16322-1-git-send-email-hannes@stressinduktion.org>
Cc: jesse@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:50985 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751959AbcAFUUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 15:20:45 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id AB3F721AD1
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 15:20:44 -0500 (EST)
In-Reply-To: <1452111630-16322-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/vxlan.c       | 35 ++++++++++++++++++++++++++++++-----
 include/linux/netdevice.h |  2 +-
 include/net/vxlan.h       |  6 ++----
 3 files changed, 33 insertions(+), 10 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index fecf7b6c732e96..47da2045ca1b19 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2468,7 +2468,7 @@ static struct device_type vxlan_type = {
  * supply the listening VXLAN udp ports. Callers are expected
  * to implement the ndo_add_vxlan_port.
  */
-void vxlan_get_rx_port(struct net_device *dev)
+static void vxlan_netdev_refresh_offload(struct net_device *dev)
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
@@ -3180,6 +3179,24 @@ static struct notifier_block vxlan_notifier_block __read_mostly = {
 	.notifier_call = vxlan_lowerdev_event,
 };
 
+static int vxlan_atomic_event(struct notifier_block *unused,
+			      unsigned long event, void *ptr)
+{
+	struct net_device *dev = ptr;
+
+	switch (event) {
+	case NETDEV_OFFLOAD_REFRESH_VXLAN:
+		vxlan_netdev_refresh_offload(dev);
+		break;
+	}
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block vxlan_atomic_notifier_block __read_mostly = {
+	.notifier_call = vxlan_atomic_event,
+};
+
 static __net_init int vxlan_init_net(struct net *net)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
@@ -3241,17 +3258,24 @@ static int __init vxlan_init_module(void)
 	if (rc)
 		goto out1;
 
-	rc = register_netdevice_notifier(&vxlan_notifier_block);
+	rc = register_netdev_atomic_notifier(&vxlan_atomic_notifier_block);
 	if (rc)
 		goto out2;
 
-	rc = rtnl_link_register(&vxlan_link_ops);
+	rc = register_netdevice_notifier(&vxlan_notifier_block);
 	if (rc)
 		goto out3;
 
+	rc = rtnl_link_register(&vxlan_link_ops);
+	if (rc)
+		goto out4;
+
 	return 0;
-out3:
+
+out4:
 	unregister_netdevice_notifier(&vxlan_notifier_block);
+out3:
+	unregister_netdev_atomic_notifier(&vxlan_atomic_notifier_block);
 out2:
 	unregister_pernet_subsys(&vxlan_net_ops);
 out1:
@@ -3263,6 +3287,7 @@ late_initcall(vxlan_init_module);
 static void __exit vxlan_cleanup_module(void)
 {
 	rtnl_link_unregister(&vxlan_link_ops);
+	unregister_netdev_atomic_notifier(&vxlan_atomic_notifier_block);
 	unregister_netdevice_notifier(&vxlan_notifier_block);
 	destroy_workqueue(vxlan_wq);
 	unregister_pernet_subsys(&vxlan_net_ops);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index fb6064c88fc259..b2b943b1896c57 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2224,7 +2224,7 @@ netdev_notifier_info_to_dev(const struct netdev_notifier_info *info)
 int call_netdevice_notifiers(unsigned long val, struct net_device *dev);
 
 enum netdev_atomic_callback_type {
-	PLACEHOLDER = 0x1UL,
+	NETDEV_OFFLOAD_REFRESH_VXLAN = 0x1UL,
 };
 
 int register_netdev_atomic_notifier(struct notifier_block *nb);
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 0fb86442544b26..cebe08569b5129 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -242,13 +242,11 @@ static inline netdev_features_t vxlan_features_check(struct sk_buff *skb,
 /* IPv6 header + UDP + VXLAN + Ethernet header */
 #define VXLAN6_HEADROOM (40 + 8 + 8 + 14)
 
-#if IS_ENABLED(CONFIG_VXLAN)
-void vxlan_get_rx_port(struct net_device *netdev);
-#else
 static inline void vxlan_get_rx_port(struct net_device *netdev)
 {
+	call_netdev_atomic_notifiers(NETDEV_OFFLOAD_REFRESH_VXLAN,
+				     netdev);
 }
-#endif
 
 static inline unsigned short vxlan_get_sk_family(struct vxlan_sock *vs)
 {
-- 
2.5.0
