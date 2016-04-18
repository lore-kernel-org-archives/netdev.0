From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 6/7] vxlan: break dependency with netdev drivers
Date: Mon, 18 Apr 2016 21:19:47 +0200
Message-ID: <1461007188-1603-7-git-send-email-hannes@stressinduktion.org>
References: <1461007188-1603-1-git-send-email-hannes@stressinduktion.org>
Cc: jesse@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:34808 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751658AbcDRTUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 15:20:09 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 8A51820A8F
	for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 15:20:08 -0400 (EDT)
In-Reply-To: <1461007188-1603-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently all drivers depend and autoload the vxlan module because how
vxlan_get_rx_port is linked into them. Remove this dependency:

By using a new event type in the netdevice notifier call chain we proxy
the request from the drivers to flush and resetup the vxlan ports not
directly via function call but by the already existing netdevice
notifier call chain.

I added a separate new event type, NETDEV_OFFLOAD_PUSH_VXLAN, to do so.
We don't need to save those ids, as the event type field is an unsigned
long and using specialized event types for this purpose seemed to be a
more elegant way. This also comes in beneficial if in future we want to
add offloading knobs for vxlan.

Cc: Jesse Gross <jesse@kernel.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/vxlan.c       | 14 +++++++++-----
 include/linux/netdevice.h |  1 +
 include/net/vxlan.h       |  6 ++----
 3 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index c2e22c2532a1a8..6fb93b57a72489 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2527,7 +2527,7 @@ static struct device_type vxlan_type = {
  * supply the listening VXLAN udp ports. Callers are expected
  * to implement the ndo_add_vxlan_port.
  */
-void vxlan_get_rx_port(struct net_device *dev)
+static void vxlan_push_rx_ports(struct net_device *dev)
 {
 	struct vxlan_sock *vs;
 	struct net *net = dev_net(dev);
@@ -2536,6 +2536,9 @@ void vxlan_get_rx_port(struct net_device *dev)
 	__be16 port;
 	unsigned int i;
 
+	if (!dev->netdev_ops->ndo_add_vxlan_port)
+		return;
+
 	spin_lock(&vn->sock_lock);
 	for (i = 0; i < PORT_HASH_SIZE; ++i) {
 		hlist_for_each_entry_rcu(vs, &vn->sock_list[i], hlist) {
@@ -2547,7 +2550,6 @@ void vxlan_get_rx_port(struct net_device *dev)
 	}
 	spin_unlock(&vn->sock_lock);
 }
-EXPORT_SYMBOL_GPL(vxlan_get_rx_port);
 
 /* Initialize the device structure. */
 static void vxlan_setup(struct net_device *dev)
@@ -3283,20 +3285,22 @@ static void vxlan_handle_lowerdev_unregister(struct vxlan_net *vn,
 	unregister_netdevice_many(&list_kill);
 }
 
-static int vxlan_lowerdev_event(struct notifier_block *unused,
-				unsigned long event, void *ptr)
+static int vxlan_netdevice_event(struct notifier_block *unused,
+				 unsigned long event, void *ptr)
 {
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
 	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
 
 	if (event == NETDEV_UNREGISTER)
 		vxlan_handle_lowerdev_unregister(vn, dev);
+	else if (event == NETDEV_OFFLOAD_PUSH_VXLAN)
+		vxlan_push_rx_ports(dev);
 
 	return NOTIFY_DONE;
 }
 
 static struct notifier_block vxlan_notifier_block __read_mostly = {
-	.notifier_call = vxlan_lowerdev_event,
+	.notifier_call = vxlan_netdevice_event,
 };
 
 static __net_init int vxlan_init_net(struct net *net)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a3bb534576a383..d4c8cd424f8dbc 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2244,6 +2244,7 @@ struct netdev_lag_lower_state_info {
 #define NETDEV_BONDING_INFO	0x0019
 #define NETDEV_PRECHANGEUPPER	0x001A
 #define NETDEV_CHANGELOWERSTATE	0x001B
+#define NETDEV_OFFLOAD_PUSH_VXLAN	0x001C
 
 int register_netdevice_notifier(struct notifier_block *nb);
 int unregister_netdevice_notifier(struct notifier_block *nb);
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index d442eb3129cde4..673e9f9e6da768 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -390,13 +390,11 @@ static inline __be32 vxlan_compute_rco(unsigned int start, unsigned int offset)
 	return vni_field;
 }
 
-#if IS_ENABLED(CONFIG_VXLAN)
-void vxlan_get_rx_port(struct net_device *netdev);
-#else
 static inline void vxlan_get_rx_port(struct net_device *netdev)
 {
+	ASSERT_RTNL();
+	call_netdevice_notifiers(NETDEV_OFFLOAD_PUSH_VXLAN, netdev);
 }
-#endif
 
 static inline unsigned short vxlan_get_sk_family(struct vxlan_sock *vs)
 {
-- 
2.5.5
