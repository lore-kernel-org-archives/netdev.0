From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v2 3/3] geneve: use netdev_atomic notifier chain to remove dependency from drivers
Date: Wed,  6 Jan 2016 21:20:30 +0100
Message-ID: <1452111630-16322-4-git-send-email-hannes@stressinduktion.org>
References: <1452111630-16322-1-git-send-email-hannes@stressinduktion.org>
Cc: jesse@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:45068 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752003AbcAFUUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 15:20:47 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 0F39521AEC
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 15:20:47 -0500 (EST)
In-Reply-To: <1452111630-16322-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/geneve.c      | 30 +++++++++++++++++++++++++++---
 include/linux/netdevice.h |  1 +
 include/net/geneve.h      |  6 ++----
 3 files changed, 30 insertions(+), 7 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 24b077a32c1c9c..e04a7678438999 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -1110,7 +1110,7 @@ static struct device_type geneve_type = {
  * supply the listening GENEVE udp ports. Callers are expected
  * to implement the ndo_add_geneve_port.
  */
-void geneve_get_rx_port(struct net_device *dev)
+static void geneve_netdev_refresh_offload(struct net_device *dev)
 {
 	struct net *net = dev_net(dev);
 	struct geneve_net *gn = net_generic(net, geneve_net_id);
@@ -1128,7 +1128,6 @@ void geneve_get_rx_port(struct net_device *dev)
 	}
 	rcu_read_unlock();
 }
-EXPORT_SYMBOL_GPL(geneve_get_rx_port);
 
 /* Initialize the device structure. */
 static void geneve_setup(struct net_device *dev)
@@ -1427,6 +1426,24 @@ static struct rtnl_link_ops geneve_link_ops __read_mostly = {
 	.fill_info	= geneve_fill_info,
 };
 
+static int geneve_atomic_event(struct notifier_block *unused,
+			       unsigned long event, void *ptr)
+{
+	struct net_device *dev = ptr;
+
+	switch (event) {
+	case NETDEV_OFFLOAD_REFRESH_GENEVE:
+		geneve_netdev_refresh_offload(dev);
+		break;
+	}
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block geneve_atomic_notifier_block __read_mostly = {
+	.notifier_call = geneve_atomic_event,
+};
+
 struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
 					u8 name_assign_type, u16 dst_port)
 {
@@ -1502,11 +1519,17 @@ static int __init geneve_init_module(void)
 	if (rc)
 		goto out1;
 
-	rc = rtnl_link_register(&geneve_link_ops);
+	rc = register_netdev_atomic_notifier(&geneve_atomic_notifier_block);
 	if (rc)
 		goto out2;
 
+	rc = rtnl_link_register(&geneve_link_ops);
+	if (rc)
+		goto out3;
+
 	return 0;
+out3:
+	unregister_netdev_atomic_notifier(&geneve_atomic_notifier_block);
 out2:
 	unregister_pernet_subsys(&geneve_net_ops);
 out1:
@@ -1517,6 +1540,7 @@ late_initcall(geneve_init_module);
 static void __exit geneve_cleanup_module(void)
 {
 	rtnl_link_unregister(&geneve_link_ops);
+	unregister_netdev_atomic_notifier(&geneve_atomic_notifier_block);
 	unregister_pernet_subsys(&geneve_net_ops);
 }
 module_exit(geneve_cleanup_module);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b2b943b1896c57..21cdb1afc5cd20 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2225,6 +2225,7 @@ int call_netdevice_notifiers(unsigned long val, struct net_device *dev);
 
 enum netdev_atomic_callback_type {
 	NETDEV_OFFLOAD_REFRESH_VXLAN = 0x1UL,
+	NETDEV_OFFLOAD_REFRESH_GENEVE = 0x2UL,
 };
 
 int register_netdev_atomic_notifier(struct notifier_block *nb);
diff --git a/include/net/geneve.h b/include/net/geneve.h
index e6c23dc765f7ec..e09476ed8feb20 100644
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
+	call_netdev_atomic_notifiers(NETDEV_OFFLOAD_REFRESH_GENEVE,
+				     netdev);
 }
-#endif
 
 #ifdef CONFIG_INET
 struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
-- 
2.5.0
