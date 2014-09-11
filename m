From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH net-next] Allow to set net namespace for wireless device via RTM_LINK
Date: Thu, 11 Sep 2014 23:35:23 +0300
Message-ID: <1410467723-2550-1-git-send-email-vadim4j@gmail.com>
Cc: linux-wireless@vger.kernel.org, Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:64391 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932149AbaIKUni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 16:43:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added new netdev_ops callback for setting namespace in specific
for this device way

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 include/linux/netdevice.h | 4 ++++
 include/net/cfg80211.h    | 3 +++
 net/core/rtnetlink.c      | 7 ++++++-
 net/mac80211/iface.c      | 6 ++++++
 net/wireless/core.c       | 8 ++++++--
 5 files changed, 25 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ba72f6b..e5cc49c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -997,6 +997,8 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *	Callback to use for xmit over the accelerated station. This
  *	is used in place of ndo_start_xmit on accelerated net
  *	devices.
+ * int (*ndo_set_netns)(struct net_device *dev, struct net *net);
+ *      Callback to set net namespace in specific way for this device.
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -1146,6 +1148,8 @@ struct net_device_ops {
 							struct net_device *dev,
 							void *priv);
 	int			(*ndo_get_lock_subclass)(struct net_device *dev);
+	int			(*ndo_set_netns)(struct net_device *dev,
+							struct net *net);
 };
 
 /**
diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index ab21299..853f97c 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -4844,6 +4844,9 @@ void cfg80211_shutdown_all_interfaces(struct wiphy *wiphy);
 /* ethtool helper */
 void cfg80211_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info);
 
+/* cfg80211_wiphy_switch_netns - switch wiphy dev to net namespace */
+int cfg80211_wiphy_switch_netns(struct wiphy *wiphy, struct net *net);
+
 /* Logging, debugging and troubleshooting/diagnostic helpers. */
 
 /* wiphy_printk helpers, similar to dev_printk */
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a688268..3c2e5e3 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1501,7 +1501,12 @@ static int do_setlink(const struct sk_buff *skb,
 			err = -EPERM;
 			goto errout;
 		}
-		err = dev_change_net_namespace(dev, net, ifname);
+
+		if (dev->netdev_ops->ndo_set_netns)
+			err = dev->netdev_ops->ndo_set_netns(dev, net);
+		else
+			err = dev_change_net_namespace(dev, net, ifname);
+
 		put_net(net);
 		if (err)
 			goto errout;
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index f75e5f1..7d60367 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -1080,6 +1080,11 @@ static u16 ieee80211_netdev_select_queue(struct net_device *dev,
 	return ieee80211_select_queue(IEEE80211_DEV_TO_SUB_IF(dev), skb);
 }
 
+static int ieee80211_set_netns(struct net_device *dev, struct net *net)
+{
+	return cfg80211_wiphy_switch_netns(dev->ieee80211_ptr->wiphy, net);
+}
+
 static const struct net_device_ops ieee80211_dataif_ops = {
 	.ndo_open		= ieee80211_open,
 	.ndo_stop		= ieee80211_stop,
@@ -1089,6 +1094,7 @@ static const struct net_device_ops ieee80211_dataif_ops = {
 	.ndo_change_mtu 	= ieee80211_change_mtu,
 	.ndo_set_mac_address 	= ieee80211_change_mac,
 	.ndo_select_queue	= ieee80211_netdev_select_queue,
+	.ndo_set_netns		= ieee80211_set_netns,
 };
 
 static u16 ieee80211_monitor_select_queue(struct net_device *dev,
diff --git a/net/wireless/core.c b/net/wireless/core.c
index c6620aa..f4742e7 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -179,6 +179,12 @@ int cfg80211_switch_netns(struct cfg80211_registered_device *rdev,
 	return 0;
 }
 
+int cfg80211_wiphy_switch_netns(struct wiphy *wiphy, struct net *net)
+{
+	return cfg80211_switch_netns(wiphy_to_rdev(wiphy), net);
+}
+EXPORT_SYMBOL(cfg80211_wiphy_switch_netns);
+
 static void cfg80211_rfkill_poll(struct rfkill *rfkill, void *data)
 {
 	struct cfg80211_registered_device *rdev = data;
@@ -898,8 +904,6 @@ static int cfg80211_netdev_notifier_call(struct notifier_block *nb,
 		wdev->identifier = ++rdev->wdev_id;
 		list_add_rcu(&wdev->list, &rdev->wdev_list);
 		rdev->devlist_generation++;
-		/* can only change netns with wiphy */
-		dev->features |= NETIF_F_NETNS_LOCAL;
 
 		if (sysfs_create_link(&dev->dev.kobj, &rdev->wiphy.dev.kobj,
 				      "phy80211")) {
-- 
2.1.0
