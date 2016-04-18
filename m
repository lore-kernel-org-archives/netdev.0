From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 7/7] geneve: break dependency with netdev drivers
Date: Mon, 18 Apr 2016 21:19:48 +0200
Message-ID: <1461007188-1603-8-git-send-email-hannes@stressinduktion.org>
References: <1461007188-1603-1-git-send-email-hannes@stressinduktion.org>
Cc: jesse@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:34943 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751941AbcDRTUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 15:20:10 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id D46A320A85
	for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 15:20:09 -0400 (EDT)
In-Reply-To: <1461007188-1603-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Equivalent to "vxlan: break dependency with netdev drivers", don't
autoload geneve module in case the driver is loaded. Instead make the
coupling weaker by using netdevice notifiers as proxy.

Cc: Jesse Gross <jesse@kernel.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/geneve.c      | 31 ++++++++++++++++++++++++++++---
 include/linux/netdevice.h |  1 +
 include/net/geneve.h      |  6 ++----
 3 files changed, 31 insertions(+), 7 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index efbc7ceedc3a13..59314cf47584e4 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -1172,7 +1172,7 @@ static struct device_type geneve_type = {
  * supply the listening GENEVE udp ports. Callers are expected
  * to implement the ndo_add_geneve_port.
  */
-void geneve_get_rx_port(struct net_device *dev)
+static void geneve_push_rx_ports(struct net_device *dev)
 {
 	struct net *net = dev_net(dev);
 	struct geneve_net *gn = net_generic(net, geneve_net_id);
@@ -1181,6 +1181,9 @@ void geneve_get_rx_port(struct net_device *dev)
 	struct sock *sk;
 	__be16 port;
 
+	if (!dev->netdev_ops->ndo_add_geneve_port)
+		return;
+
 	rcu_read_lock();
 	list_for_each_entry_rcu(gs, &gn->sock_list, list) {
 		sk = gs->sock->sk;
@@ -1190,7 +1193,6 @@ void geneve_get_rx_port(struct net_device *dev)
 	}
 	rcu_read_unlock();
 }
-EXPORT_SYMBOL_GPL(geneve_get_rx_port);
 
 /* Initialize the device structure. */
 static void geneve_setup(struct net_device *dev)
@@ -1538,6 +1540,21 @@ struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
 }
 EXPORT_SYMBOL_GPL(geneve_dev_create_fb);
 
+static int geneve_netdevice_event(struct notifier_block *unused,
+				  unsigned long event, void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+
+	if (event == NETDEV_OFFLOAD_PUSH_GENEVE)
+		geneve_push_rx_ports(dev);
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block geneve_notifier_block __read_mostly = {
+	.notifier_call = geneve_netdevice_event,
+};
+
 static __net_init int geneve_init_net(struct net *net)
 {
 	struct geneve_net *gn = net_generic(net, geneve_net_id);
@@ -1590,11 +1607,18 @@ static int __init geneve_init_module(void)
 	if (rc)
 		goto out1;
 
-	rc = rtnl_link_register(&geneve_link_ops);
+	rc = register_netdevice_notifier(&geneve_notifier_block);
 	if (rc)
 		goto out2;
 
+	rc = rtnl_link_register(&geneve_link_ops);
+	if (rc)
+		goto out3;
+
 	return 0;
+
+out3:
+	unregister_netdevice_notifier(&geneve_notifier_block);
 out2:
 	unregister_pernet_subsys(&geneve_net_ops);
 out1:
@@ -1605,6 +1629,7 @@ late_initcall(geneve_init_module);
 static void __exit geneve_cleanup_module(void)
 {
 	rtnl_link_unregister(&geneve_link_ops);
+	unregister_netdevice_notifier(&geneve_notifier_block);
 	unregister_pernet_subsys(&geneve_net_ops);
 }
 module_exit(geneve_cleanup_module);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d4c8cd424f8dbc..1f6d5db471a24f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2245,6 +2245,7 @@ struct netdev_lag_lower_state_info {
 #define NETDEV_PRECHANGEUPPER	0x001A
 #define NETDEV_CHANGELOWERSTATE	0x001B
 #define NETDEV_OFFLOAD_PUSH_VXLAN	0x001C
+#define NETDEV_OFFLOAD_PUSH_GENEVE	0x001D
 
 int register_netdevice_notifier(struct notifier_block *nb);
 int unregister_netdevice_notifier(struct notifier_block *nb);
diff --git a/include/net/geneve.h b/include/net/geneve.h
index e6c23dc765f7ec..cb544a530146c2 100644
--- a/include/net/geneve.h
+++ b/include/net/geneve.h
@@ -62,13 +62,11 @@ struct genevehdr {
 	struct geneve_opt options[];
 };
 
-#if IS_ENABLED(CONFIG_GENEVE)
-void geneve_get_rx_port(struct net_device *netdev);
-#else
 static inline void geneve_get_rx_port(struct net_device *netdev)
 {
+	ASSERT_RTNL();
+	call_netdevice_notifiers(NETDEV_OFFLOAD_PUSH_GENEVE, netdev);
 }
-#endif
 
 #ifdef CONFIG_INET
 struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
-- 
2.5.5
