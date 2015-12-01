From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 11/26] net: introduce change lower state notifier
Date: Tue,  1 Dec 2015 14:48:49 +0100
Message-ID: <1448977744-17930-12-git-send-email-jiri@resnulli.us>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:36320 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755418AbbLANtW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 08:49:22 -0500
Received: by wmww144 with SMTP id w144so173664890wmw.1
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 05:49:21 -0800 (PST)
In-Reply-To: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

When lower device like bonding slave, team/bridge port, etc changes its
state, it is useful for others to notice this change. Currently this is
implemented specificly for bonding as NETDEV_BONDING_INFO notifier. This
patch aims to replace this specific usage and make this more generic to
be used for all upper-lower devices.

Introduce NETDEV_CHANGELOWERSTATE netdev notifier type and
netdev_lower_state_changed() helper.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/netdevice.h |  8 ++++++++
 net/core/dev.c            | 20 ++++++++++++++++++++
 2 files changed, 28 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7ea3e83..06f17a4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2156,6 +2156,7 @@ struct netdev_lag_upper_info {
 #define NETDEV_CHANGEINFODATA	0x0018
 #define NETDEV_BONDING_INFO	0x0019
 #define NETDEV_PRECHANGEUPPER	0x001A
+#define NETDEV_CHANGELOWERSTATE	0x001B
 
 int register_netdevice_notifier(struct notifier_block *nb);
 int unregister_netdevice_notifier(struct notifier_block *nb);
@@ -2177,6 +2178,11 @@ struct netdev_notifier_changeupper_info {
 	void *upper_info; /* is upper dev info */
 };
 
+struct netdev_notifier_changelowerstate_info {
+	struct netdev_notifier_info info; /* must be first */
+	void *lower_state_info; /* is lower dev state */
+};
+
 static inline void netdev_notifier_info_init(struct netdev_notifier_info *info,
 					     struct net_device *dev)
 {
@@ -3638,6 +3644,8 @@ void netdev_upper_dev_unlink(struct net_device *dev,
 void netdev_adjacent_rename_links(struct net_device *dev, char *oldname);
 void *netdev_lower_dev_get_private(struct net_device *dev,
 				   struct net_device *lower_dev);
+void netdev_lower_state_changed(struct net_device *lower_dev,
+				void *lower_state_info);
 
 /* RSS keys are 40 or 52 bytes long */
 #define NETDEV_RSS_KEY_LEN 52
diff --git a/net/core/dev.c b/net/core/dev.c
index 3fe1ce2..caac143 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5752,6 +5752,26 @@ int dev_get_nest_level(struct net_device *dev,
 }
 EXPORT_SYMBOL(dev_get_nest_level);
 
+/**
+ * netdev_lower_change - Dispatch event about lower device state change
+ * @lower_dev: device
+ * @lower_state_info: state to dispatch
+ *
+ * Send NETDEV_CHANGELOWERSTATE to netdev notifiers with info.
+ * The caller must hold the RTNL lock.
+ */
+void netdev_lower_state_changed(struct net_device *lower_dev,
+				void *lower_state_info)
+{
+	struct netdev_notifier_changelowerstate_info changelowerstate_info;
+
+	ASSERT_RTNL();
+	changelowerstate_info.lower_state_info = lower_state_info;
+	call_netdevice_notifiers_info(NETDEV_CHANGELOWERSTATE, lower_dev,
+				      &changelowerstate_info.info);
+}
+EXPORT_SYMBOL(netdev_lower_state_changed);
+
 static void dev_change_rx_flags(struct net_device *dev, int flags)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
-- 
1.9.3
