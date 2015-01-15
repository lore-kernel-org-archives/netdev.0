From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/2] switchdev: introduce switchdev notifier
Date: Thu, 15 Jan 2015 23:49:36 +0100
Message-ID: <1421362177-10719-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, sfeldma@gmail.co,
	stephen@networkplumber.org, linus.luessing@web.de, tgraf@suug.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:41134 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932258AbbAOWtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 17:49:40 -0500
Received: by mail-wi0-f177.google.com with SMTP id l15so510954wiw.4
        for <netdev@vger.kernel.org>; Thu, 15 Jan 2015 14:49:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces new notifier for purposes of exposing events which happen
on switch driver side. The consumers of the event messages are mainly involved
masters, namely bridge and ovs.

Suggested-by: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/net/switchdev.h   | 31 ++++++++++++++++++++++
 net/switchdev/switchdev.c | 65 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 96 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 8a6d164..7f8d743 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -11,12 +11,27 @@
 #define _LINUX_SWITCHDEV_H_
 
 #include <linux/netdevice.h>
+#include <linux/notifier.h>
+
+struct netdev_switch_notifier_info {
+	struct net_device *dev;
+};
+
+static inline struct net_device *
+netdev_switch_notifier_info_to_dev(const struct netdev_switch_notifier_info *info)
+{
+	return info->dev;
+}
 
 #ifdef CONFIG_NET_SWITCHDEV
 
 int netdev_switch_parent_id_get(struct net_device *dev,
 				struct netdev_phys_item_id *psid);
 int netdev_switch_port_stp_update(struct net_device *dev, u8 state);
+int register_netdev_switch_notifier(struct notifier_block *nb);
+int unregister_netdev_switch_notifier(struct notifier_block *nb);
+int call_netdev_switch_notifiers(unsigned long val, struct net_device *dev,
+				 struct netdev_switch_notifier_info *info);
 
 #else
 
@@ -32,6 +47,22 @@ static inline int netdev_switch_port_stp_update(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
+static inline int register_netdev_switch_notifier(struct notifier_block *nb)
+{
+	return 0;
+}
+
+static inline int unregister_netdev_switch_notifier(struct notifier_block *nb)
+{
+	return 0;
+}
+
+static inline int call_netdev_switch_notifiers(unsigned long val, struct net_device *dev,
+					       struct netdev_switch_notifier_info *info);
+{
+	return NOTIFY_DONE;
+}
+
 #endif
 
 #endif /* _LINUX_SWITCHDEV_H_ */
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index d162b21..22e02f4 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -11,6 +11,8 @@
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/init.h>
+#include <linux/mutex.h>
+#include <linux/notifier.h>
 #include <linux/netdevice.h>
 #include <net/switchdev.h>
 
@@ -50,3 +52,66 @@ int netdev_switch_port_stp_update(struct net_device *dev, u8 state)
 	return ops->ndo_switch_port_stp_update(dev, state);
 }
 EXPORT_SYMBOL(netdev_switch_port_stp_update);
+
+static DEFINE_MUTEX(netdev_switch_mutex);
+static RAW_NOTIFIER_HEAD(netdev_switch_notif_chain);
+
+/**
+ *	register_netdev_switch_notifier - Register nofifier
+ *	@nb: notifier_block
+ *
+ *	Register switch device notifier. This should be used by code
+ *	which needs to monitor events happening in particular device.
+ *	Return values are same as for atomic_notifier_chain_register().
+ */
+int register_netdev_switch_notifier(struct notifier_block *nb)
+{
+	int err;
+
+	mutex_lock(&netdev_switch_mutex);
+	err = raw_notifier_chain_register(&netdev_switch_notif_chain, nb);
+	mutex_unlock(&netdev_switch_mutex);
+	return err;
+}
+EXPORT_SYMBOL(register_netdev_switch_notifier);
+
+/**
+ *	unregister_netdev_switch_notifier - Unregister nofifier
+ *	@nb: notifier_block
+ *
+ *	Unregister switch device notifier.
+ *	Return values are same as for atomic_notifier_chain_unregister().
+ */
+int unregister_netdev_switch_notifier(struct notifier_block *nb)
+{
+	int err;
+
+	mutex_lock(&netdev_switch_mutex);
+	err = raw_notifier_chain_unregister(&netdev_switch_notif_chain, nb);
+	mutex_unlock(&netdev_switch_mutex);
+	return err;
+}
+EXPORT_SYMBOL(unregister_netdev_switch_notifier);
+
+/**
+ *	call_netdev_switch_notifiers - Call nofifiers
+ *	@val: value passed unmodified to notifier function
+ *	@dev: port device
+ *	@info: notifier information data
+ *
+ *	Call all network notifier blocks. This should be called by driver
+ *	when it needs to propagate hardware event.
+ *	Return values are same as for atomic_notifier_call_chain().
+ */
+int call_netdev_switch_notifiers(unsigned long val, struct net_device *dev,
+				 struct netdev_switch_notifier_info *info)
+{
+	int err;
+
+	info->dev = dev;
+	mutex_lock(&netdev_switch_mutex);
+	err = raw_notifier_call_chain(&netdev_switch_notif_chain, val, info);
+	mutex_unlock(&netdev_switch_mutex);
+	return err;
+}
+EXPORT_SYMBOL(call_netdev_switch_notifiers);
-- 
1.9.3
