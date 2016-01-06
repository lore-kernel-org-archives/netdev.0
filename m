From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v2 1/3] netdev: add atomic netdev callback chain
Date: Wed,  6 Jan 2016 21:20:28 +0100
Message-ID: <1452111630-16322-2-git-send-email-hannes@stressinduktion.org>
References: <1452111630-16322-1-git-send-email-hannes@stressinduktion.org>
Cc: jesse@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:49509 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751761AbcAFUUn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 15:20:43 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 7C32E21AFE
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 15:20:42 -0500 (EST)
In-Reply-To: <1452111630-16322-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This atomic notifier is later used by drivers to deliver callbacks to
the core network stack without requireing rtnl lock to be held.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/netdevice.h |  9 +++++++++
 net/core/dev.c            | 24 ++++++++++++++++++++++++
 2 files changed, 33 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c20b814e46a072..fb6064c88fc259 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2223,6 +2223,15 @@ netdev_notifier_info_to_dev(const struct netdev_notifier_info *info)
 
 int call_netdevice_notifiers(unsigned long val, struct net_device *dev);
 
+enum netdev_atomic_callback_type {
+	PLACEHOLDER = 0x1UL,
+};
+
+int register_netdev_atomic_notifier(struct notifier_block *nb);
+int unregister_netdev_atomic_notifier(struct notifier_block *nb);
+int call_netdev_atomic_notifiers(enum netdev_atomic_callback_type type,
+				 struct net_device *dev);
+
 
 extern rwlock_t				dev_base_lock;		/* Device list lock */
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 914b4a24c65436..e96248d955f1aa 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7840,6 +7840,30 @@ define_netdev_printk_level(netdev_warn, KERN_WARNING);
 define_netdev_printk_level(netdev_notice, KERN_NOTICE);
 define_netdev_printk_level(netdev_info, KERN_INFO);
 
+static ATOMIC_NOTIFIER_HEAD(netdev_atomic_notifier_chain);
+
+int register_netdev_atomic_notifier(struct notifier_block *nb)
+{
+	return atomic_notifier_chain_register(&netdev_atomic_notifier_chain,
+					      nb);
+}
+EXPORT_SYMBOL_GPL(register_netdev_atomic_notifier);
+
+int unregister_netdev_atomic_notifier(struct notifier_block *nb)
+{
+	return atomic_notifier_chain_unregister(&netdev_atomic_notifier_chain,
+						nb);
+}
+EXPORT_SYMBOL_GPL(unregister_netdev_atomic_notifier);
+
+int call_netdev_atomic_notifiers(enum netdev_atomic_callback_type type,
+				 struct net_device *dev)
+{
+	return atomic_notifier_call_chain(&netdev_atomic_notifier_chain,
+					  type, dev);
+}
+EXPORT_SYMBOL_GPL(call_netdev_atomic_notifiers);
+
 static void __net_exit netdev_exit(struct net *net)
 {
 	kfree(net->dev_name_head);
-- 
2.5.0
