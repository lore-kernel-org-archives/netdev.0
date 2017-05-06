From: David Ahern <dsahern@gmail.com>
Subject: [PATCH RFC net-next 4/6] net: Do not intialize kobject for lightweight netdevs
Date: Sat,  6 May 2017 10:07:32 -0600
Message-ID: <20170506160734.47084-5-dsahern@gmail.com>
References: <20170506160734.47084-1-dsahern@gmail.com>
Cc: roopa@cumulusnetworks.com, f.fainelli@gmail.com,
        nicolas.dichtel@6wind.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34222 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752374AbdEFQHs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 6 May 2017 12:07:48 -0400
Received: by mail-pg0-f67.google.com with SMTP id u187so4635472pgb.1
        for <netdev@vger.kernel.org>; Sat, 06 May 2017 09:07:48 -0700 (PDT)
In-Reply-To: <20170506160734.47084-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lightweight netdevices are not added to sysfs; bypass kobject
initialization.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/linux/netdevice.h |  3 +++
 net/core/dev.c            |  9 ++++++---
 net/core/net-sysfs.c      | 14 +++++++++++---
 3 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 08151fd34973..4ddd0ac7e1cb 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -4282,6 +4282,9 @@ static inline const char *netdev_reg_state(const struct net_device *dev)
 
 static inline struct kobject *netdev_kobject(struct net_device *dev)
 {
+	if (netif_is_lwd(dev))
+		return NULL;
+
 	return &dev->dev.kobj;
 }
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 48a0252037d5..52bb01041d12 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7993,7 +7993,8 @@ void free_netdev(struct net_device *dev)
 	dev->reg_state = NETREG_RELEASED;
 
 	/* will free via device release */
-	put_device(&dev->dev);
+	if (!netif_is_lwd(dev))
+		put_device(&dev->dev);
 }
 EXPORT_SYMBOL(free_netdev);
 
@@ -8179,8 +8180,10 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	netdev_adjacent_add_links(dev);
 
 	/* Fixup kobjects */
-	err = device_rename(&dev->dev, dev->name);
-	WARN_ON(err);
+	if (!netif_is_lwd(dev)) {
+		err = device_rename(&dev->dev, dev->name);
+		WARN_ON(err);
+	}
 
 	/* Add the device back in the hashes */
 	list_netdevice(dev);
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 9df53b688f5b..725348cdeb3b 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -1559,18 +1559,22 @@ EXPORT_SYMBOL(of_find_net_device_by_node);
  */
 void netdev_unregister_kobject(struct net_device *ndev)
 {
+	struct kobject *kobj = netdev_kobject(ndev);
 	struct device *dev = &(ndev->dev);
 
 	if (!atomic_read(&dev_net(ndev)->count))
 		dev_set_uevent_suppress(dev, 1);
 
-	kobject_get(&dev->kobj);
+	if (kobj)
+		kobject_get(kobj);
 
-	remove_queue_kobjects(ndev);
+	if (!netif_is_lwd(ndev))
+		remove_queue_kobjects(ndev);
 
 	pm_runtime_set_memalloc_noio(dev, false);
 
-	device_del(dev);
+	if (!netif_is_lwd(ndev))
+		device_del(dev);
 }
 
 /* Create sysfs entries for network device. */
@@ -1580,6 +1584,9 @@ int netdev_register_kobject(struct net_device *ndev)
 	const struct attribute_group **groups = ndev->sysfs_groups;
 	int error = 0;
 
+	if (netif_is_lwd(ndev))
+		goto pm;
+
 	device_initialize(dev);
 	dev->class = &net_class;
 	dev->platform_data = ndev;
@@ -1614,6 +1621,7 @@ int netdev_register_kobject(struct net_device *ndev)
 		return error;
 	}
 
+pm:
 	pm_runtime_set_memalloc_noio(dev, true);
 
 	return error;
-- 
2.11.0 (Apple Git-81)
