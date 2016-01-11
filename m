From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v5 08/10] geneve: break dependency to network drivers
Date: Mon, 11 Jan 2016 13:17:29 +0100
Message-ID: <1452514651-15445-9-git-send-email-hannes@stressinduktion.org>
References: <1452514651-15445-1-git-send-email-hannes@stressinduktion.org>
Cc: jesse@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:43732 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932848AbcAKMRq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 07:17:46 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 68E8820B4C
	for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 07:17:46 -0500 (EST)
In-Reply-To: <1452514651-15445-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reviewed-by: Jesse Gross <jesse@kernel.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/geneve.c | 37 ++++++++++++++++++++++++++++++-------
 include/net/geneve.h |  7 +++----
 2 files changed, 33 insertions(+), 11 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 24b077a32c1c9c..ebc1bba33f189c 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -1106,11 +1106,7 @@ static struct device_type geneve_type = {
 	.name = "geneve",
 };
 
-/* Calls the ndo_add_geneve_port of the caller in order to
- * supply the listening GENEVE udp ports. Callers are expected
- * to implement the ndo_add_geneve_port.
- */
-void geneve_get_rx_port(struct net_device *dev)
+static void geneve_notify_refresh_netdev(struct net_device *dev)
 {
 	struct net *net = dev_net(dev);
 	struct geneve_net *gn = net_generic(net, geneve_net_id);
@@ -1119,6 +1115,9 @@ void geneve_get_rx_port(struct net_device *dev)
 	struct sock *sk;
 	__be16 port;
 
+	if (!dev->netdev_ops->ndo_add_geneve_port)
+		return;
+
 	rcu_read_lock();
 	list_for_each_entry_rcu(gs, &gn->sock_list, list) {
 		sk = gs->sock->sk;
@@ -1128,7 +1127,6 @@ void geneve_get_rx_port(struct net_device *dev)
 	}
 	rcu_read_unlock();
 }
-EXPORT_SYMBOL_GPL(geneve_get_rx_port);
 
 /* Initialize the device structure. */
 static void geneve_setup(struct net_device *dev)
@@ -1450,6 +1448,24 @@ struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
 }
 EXPORT_SYMBOL_GPL(geneve_dev_create_fb);
 
+static int geneve_notifier(struct notifier_block *unused,
+			   unsigned long event, void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+
+	switch (event) {
+	case NETDEV_REFRESH_OFFLOADS:
+		geneve_notify_refresh_netdev(dev);
+		break;
+	}
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block geneve_notifier_block __read_mostly = {
+	.notifier_call = geneve_notifier,
+};
+
 static __net_init int geneve_init_net(struct net *net)
 {
 	struct geneve_net *gn = net_generic(net, geneve_net_id);
@@ -1502,11 +1518,17 @@ static int __init geneve_init_module(void)
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
+out3:
+	unregister_netdevice_notifier(&geneve_notifier_block);
 out2:
 	unregister_pernet_subsys(&geneve_net_ops);
 out1:
@@ -1517,6 +1539,7 @@ late_initcall(geneve_init_module);
 static void __exit geneve_cleanup_module(void)
 {
 	rtnl_link_unregister(&geneve_link_ops);
+	unregister_netdevice_notifier(&geneve_notifier_block);
 	unregister_pernet_subsys(&geneve_net_ops);
 }
 module_exit(geneve_cleanup_module);
diff --git a/include/net/geneve.h b/include/net/geneve.h
index e6c23dc765f7ec..7d52077b72faa3 100644
--- a/include/net/geneve.h
+++ b/include/net/geneve.h
@@ -1,6 +1,8 @@
 #ifndef __NET_GENEVE_H
 #define __NET_GENEVE_H  1
 
+#include <linux/netdevice.h>
+
 #ifdef CONFIG_INET
 #include <net/udp_tunnel.h>
 #endif
@@ -62,13 +64,10 @@ struct genevehdr {
 	struct geneve_opt options[];
 };
 
-#if IS_ENABLED(CONFIG_GENEVE)
-void geneve_get_rx_port(struct net_device *netdev);
-#else
 static inline void geneve_get_rx_port(struct net_device *netdev)
 {
+	call_netdevice_notifiers(NETDEV_REFRESH_OFFLOADS, netdev);
 }
-#endif
 
 #ifdef CONFIG_INET
 struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
-- 
2.5.0
