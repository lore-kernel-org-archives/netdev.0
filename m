From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] cfg80211: support sysfs namespaces
Date: Thu, 05 Aug 2010 17:45:15 +0200
Message-ID: <1281023115.4058.11.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: John Linville <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:43916 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933385Ab0HEPpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 11:45:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Enable using network namespaces with
wireless devices even when sysfs is
enabled using the same infrastructure
that was built for netdevs.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
NB: This generates a harmless gcc warning, I submitted
    a patch to fix it here:
    http://thread.gmane.org/gmane.linux.kernel/1019330

 include/linux/netdevice.h |    2 ++
 net/core/net-sysfs.c      |    3 ++-
 net/wireless/core.c       |    7 ++++++-
 net/wireless/sysfs.c      |    9 +++++++++
 4 files changed, 19 insertions(+), 2 deletions(-)

--- wireless-testing.orig/net/core/net-sysfs.c	2010-08-05 17:33:47.000000000 +0200
+++ wireless-testing/net/core/net-sysfs.c	2010-08-05 17:38:27.000000000 +0200
@@ -789,12 +789,13 @@ static const void *net_netlink_ns(struct
 	return sock_net(sk);
 }
 
-static struct kobj_ns_type_operations net_ns_type_operations = {
+struct kobj_ns_type_operations net_ns_type_operations = {
 	.type = KOBJ_NS_TYPE_NET,
 	.current_ns = net_current_ns,
 	.netlink_ns = net_netlink_ns,
 	.initial_ns = net_initial_ns,
 };
+EXPORT_SYMBOL_GPL(net_ns_type_operations);
 
 static void net_kobj_ns_exit(struct net *net)
 {
--- wireless-testing.orig/net/wireless/sysfs.c	2010-08-05 17:33:47.000000000 +0200
+++ wireless-testing/net/wireless/sysfs.c	2010-08-05 17:39:11.000000000 +0200
@@ -110,6 +110,13 @@ static int wiphy_resume(struct device *d
 	return ret;
 }
 
+static const void *wiphy_namespace(struct device *d)
+{
+	struct wiphy *wiphy = container_of(d, struct wiphy, dev);
+
+	return wiphy_net(wiphy);
+}
+
 struct class ieee80211_class = {
 	.name = "ieee80211",
 	.owner = THIS_MODULE,
@@ -120,6 +127,8 @@ struct class ieee80211_class = {
 #endif
 	.suspend = wiphy_suspend,
 	.resume = wiphy_resume,
+	.ns_type = &net_ns_type_operations,
+	.namespace = wiphy_namespace,
 };
 
 int wiphy_sysfs_init(void)
--- wireless-testing.orig/net/wireless/core.c	2010-08-05 17:33:47.000000000 +0200
+++ wireless-testing/net/wireless/core.c	2010-08-05 17:38:27.000000000 +0200
@@ -253,11 +253,16 @@ int cfg80211_switch_netns(struct cfg8021
 			WARN_ON(err);
 			wdev->netdev->features |= NETIF_F_NETNS_LOCAL;
 		}
+
+		return err;
 	}
 
 	wiphy_net_set(&rdev->wiphy, net);
 
-	return err;
+	err = device_rename(&rdev->wiphy.dev, dev_name(&rdev->wiphy.dev));
+	WARN_ON(err);
+
+	return 0;
 }
 
 static void cfg80211_rfkill_poll(struct rfkill *rfkill, void *data)
--- wireless-testing.orig/include/linux/netdevice.h	2010-08-05 17:13:50.000000000 +0200
+++ wireless-testing/include/linux/netdevice.h	2010-08-05 17:39:02.000000000 +0200
@@ -2171,6 +2171,8 @@ extern void dev_seq_stop(struct seq_file
 extern int netdev_class_create_file(struct class_attribute *class_attr);
 extern void netdev_class_remove_file(struct class_attribute *class_attr);
 
+extern struct kobj_ns_type_operations net_ns_type_operations;
+
 extern char *netdev_drivername(const struct net_device *dev, char *buffer, int len);
 
 extern void linkwatch_run_queue(void);


