From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 2/12] d80211: better sysfs registration of symlinks to wiphy
Date: Thu,  8 Jun 2006 09:49:06 +0200 (CEST)
Message-ID: <20060608074906.0EE3F48390@silver.suse.cz>
References: <20060608094822.014829000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:51608 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964776AbWFHHrz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 03:47:55 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060608094822.014829000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lately, delayed sysfs registration of net_device (in netdev_run_todo) was
removed. This allows us to remove hack that used class interface for sysfs
registration.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c       |   18 +++++++++++++++--
 net/d80211/ieee80211_i.h     |    2 ++
 net/d80211/ieee80211_iface.c |   15 ++++++++++++++
 net/d80211/ieee80211_sysfs.c |   45 ++++++------------------------------------
 4 files changed, 39 insertions(+), 41 deletions(-)

beb1533d9181d1c6d195de5743517b3559bfd9f9
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index f549098..9724a49 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -4197,9 +4197,21 @@ int ieee80211_register_hw(struct net_dev
 
 	if (hw->fraglist)
 		dev->features |= NETIF_F_FRAGLIST;
-	result = register_netdev(dev);
-	if (result < 0)
+	rtnl_lock();
+	result = dev_alloc_name(dev, dev->name);
+	if (result < 0) {
+		rtnl_unlock();
+		goto fail_dev;
+	}
+	result = register_netdevice(dev);
+	if (result < 0) {
+		rtnl_unlock();
 		goto fail_dev;
+	}
+	result = ieee80211_sysfs_add_netdevice(dev);
+	rtnl_unlock();
+	if (result < 0)
+		goto fail_if_sysfs;
 
 	if (rate_control_initialize(local) < 0) {
 		printk(KERN_DEBUG "%s: Failed to initialize rate control "
@@ -4223,6 +4235,8 @@ int ieee80211_register_hw(struct net_dev
 	return 0;
 
 fail_rate:
+	ieee80211_sysfs_remove_netdevice(dev);
+fail_if_sysfs:
 	unregister_netdev(dev);
 fail_dev:
 	sta_info_stop(local);
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 94e151d..19d9d98 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -599,6 +599,8 @@ int ieee80211_if_add_mgmt(struct net_dev
 void ieee80211_if_del_mgmt(struct net_device *dev);
 
 /* ieee80211_sysfs.c */
+int ieee80211_sysfs_add_netdevice(struct net_device *dev);
+void ieee80211_sysfs_remove_netdevice(struct net_device *dev);
 int ieee80211_register_sysfs(struct ieee80211_local *local);
 void ieee80211_unregister_sysfs(struct ieee80211_local *local);
 int ieee80211_sysfs_init(void);
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index 6631738..d534fe4 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -76,6 +76,13 @@ int ieee80211_if_add(struct net_device *
 	ret = register_netdevice(ndev);
 	if (ret)
 		goto fail;
+	ret = ieee80211_sysfs_add_netdevice(ndev);
+	if (ret) {
+		/* ndev will be freed by ndev->destructor */
+		unregister_netdevice(ndev);
+		*new_dev = NULL;
+		return ret;
+	}
 
 	list_add(&sdata->list, &local->sub_if_list);
 	ieee80211_proc_init_virtual(ndev);
@@ -123,10 +130,16 @@ int ieee80211_if_add_mgmt(struct net_dev
 	ret = register_netdevice(ndev);
 	if (ret)
 		goto fail;
+	ret = ieee80211_sysfs_add_netdevice(ndev);
+	if (ret)
+		goto fail_sysfs;
 	if (local->open_count > 0)
 		dev_open(ndev);
 	local->apdev = ndev;
 	return 0;
+
+fail_sysfs:
+	unregister_netdevice(ndev);
 fail:
 	free_netdev(ndev);
 	return ret;
@@ -139,6 +152,7 @@ void ieee80211_if_del_mgmt(struct net_de
 
 	ASSERT_RTNL();
 	apdev = local->apdev;
+	ieee80211_sysfs_remove_netdevice(apdev);
 	local->apdev = NULL;
 	unregister_netdevice(apdev);
 }
@@ -293,6 +307,7 @@ void __ieee80211_if_del(struct ieee80211
 	ieee80211_if_reinit(dev);
 	list_del(&sdata->list);
 	ieee80211_proc_deinit_virtual(dev);
+	ieee80211_sysfs_remove_netdevice(dev);
 	unregister_netdevice(dev);
 	/* Except master interface, the net_device will be freed by
 	 * net_device->destructor (i. e. ieee80211_if_free). */
diff --git a/net/d80211/ieee80211_sysfs.c b/net/d80211/ieee80211_sysfs.c
index 463f9aa..5c7af9f 100644
--- a/net/d80211/ieee80211_sysfs.c
+++ b/net/d80211/ieee80211_sysfs.c
@@ -98,60 +98,27 @@ void ieee80211_unregister_sysfs(struct i
 	class_device_del(&local->class_dev);
 }
 
-static int ieee80211_add_netdevice(struct class_device *cd,
-				   struct class_interface *cintf)
+int ieee80211_sysfs_add_netdevice(struct net_device *dev)
 {
-	struct net_device *dev = container_of(cd, struct net_device, class_dev);
 	struct ieee80211_local *local = dev->priv;
 
-	if (ieee80211_dev_find_index(local) < 0)
-		return 0;
-	return sysfs_create_link(&cd->kobj, &local->class_dev.kobj, "wiphy");
+	return sysfs_create_link(&dev->class_dev.kobj, &local->class_dev.kobj,
+				 "wiphy");
 }
 
-static void ieee80211_remove_netdevice(struct class_device *cd,
-				       struct class_interface *cintf)
+void ieee80211_sysfs_remove_netdevice(struct net_device *dev)
 {
-	struct net_device *dev = container_of(cd, struct net_device, class_dev);
 	struct ieee80211_local *local = dev->priv;
 
-	if (ieee80211_dev_find_index(local) >= 0)
-		sysfs_remove_link(&cd->kobj, "wiphy");
-}
-
-static struct class_interface ieee80211_wiphy_cintf = {
-	.add = ieee80211_add_netdevice,
-	.remove = ieee80211_remove_netdevice,
-};
-
-/* Adds class interface watching for new network devices and adding "wiphy"
- * attribute (symlink) to them. */
-static int ieee80211_register_wiphy_cintf(void)
-{
-	ieee80211_wiphy_cintf.class = loopback_dev.class_dev.class;
-	return class_interface_register(&ieee80211_wiphy_cintf);
-}
-
-static void ieee80211_unregister_wiphy_cintf(void)
-{
-	class_interface_unregister(&ieee80211_wiphy_cintf);
+	sysfs_remove_link(&dev->class_dev.kobj, "wiphy");
 }
 
 int ieee80211_sysfs_init(void)
 {
-	int result;
-
-	result = class_register(&ieee80211_class);
-	if (result)
-		return result;
-	result = ieee80211_register_wiphy_cintf();
-	if (result)
-		class_unregister(&ieee80211_class);
-	return result;
+	return class_register(&ieee80211_class);
 }
 
 void ieee80211_sysfs_deinit(void)
 {
-	ieee80211_unregister_wiphy_cintf();
 	class_unregister(&ieee80211_class);
 }
-- 
1.3.0

