From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 2/6] d80211: use invisible network device for wmaster
Date: Mon, 29 Jan 2007 18:48:07 +0100 (CET)
Message-ID: <20070129174807.4C29C48495@silver.suse.cz>
References: <20070129184707.885764375.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:41729 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752057AbXA2Rrz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jan 2007 12:47:55 -0500
In-Reply-To: <20070129184707.885764375.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use register_invisible_netdevice for master interface.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---
 net/d80211/ieee80211.c       |   22 ++--------------------
 net/d80211/ieee80211_iface.c |    8 ++++++--
 2 files changed, 8 insertions(+), 22 deletions(-)

--- dscape.orig/net/d80211/ieee80211.c
+++ dscape/net/d80211/ieee80211.c
@@ -4540,23 +4540,11 @@ int ieee80211_register_hw(struct ieee802
 	memcpy(local->mdev->dev_addr, local->hw.perm_addr, ETH_ALEN);
 	SET_NETDEV_DEV(local->mdev, local->hw.dev);
 
-	result = register_netdevice(local->mdev);
+	result = register_invisible_netdevice(local->mdev);
 	if (result < 0) {
 		rtnl_unlock();
 		goto fail_dev;
 	}
-	result = sysfs_create_link(&local->class_dev.kobj,
-				   &local->mdev->class_dev.kobj,
-				   "master");
-	if (result < 0) {
-		rtnl_unlock();
-		goto fail_masterlink;
-	}
-	result = ieee80211_sysfs_add_netdevice(local->mdev);
-	if (result < 0) {
-		rtnl_unlock();
-		goto fail_if_sysfs;
-	}
 
 	result = ieee80211_init_rate_ctrl_alg(local, NULL);
 	rtnl_unlock();
@@ -4593,11 +4581,7 @@ int ieee80211_register_hw(struct ieee802
 fail_wep:
 	rate_control_deinitialize(local);
 fail_rate:
-	ieee80211_sysfs_remove_netdevice(local->mdev);
-fail_if_sysfs:
-	sysfs_remove_link(&local->class_dev.kobj, "master");
-fail_masterlink:
-	unregister_netdev(local->mdev);
+	unregister_invisible_netdevice(local->mdev);
 fail_dev:
 	sta_info_stop(local);
 fail_sta_info:
@@ -4655,8 +4639,6 @@ void ieee80211_unregister_hw(struct ieee
 	if (local->apdev)
 		ieee80211_if_del_mgmt(local);
 
-	sysfs_remove_link(&local->class_dev.kobj, "master");
-
 	list_for_each_entry_safe(sdata, tmp, &local->sub_if_list, list)
 		__ieee80211_if_del(local, sdata);
 
--- dscape.orig/net/d80211/ieee80211_iface.c
+++ dscape/net/d80211/ieee80211_iface.c
@@ -309,8 +309,12 @@ void __ieee80211_if_del(struct ieee80211
 	struct net_device *dev = sdata->dev;
 
 	list_del(&sdata->list);
-	ieee80211_sysfs_remove_netdevice(dev);
-	unregister_netdevice(dev);
+	if (dev == local->mdev)
+		unregister_invisible_netdevice(dev);
+	else {
+		ieee80211_sysfs_remove_netdevice(dev);
+		unregister_netdevice(dev);
+	}
 	/* Except master interface, the net_device will be freed by
 	 * net_device->destructor (i. e. ieee80211_if_free). */
 }
