From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [net-2.6 patch 1/2][NETNS] fix device renaming for sysfs
Date: Wed, 30 Apr 2008 23:31:14 +0200
Message-ID: <20080430213320.825349005@localhost.localdomain>
References: <20080430213113.410541118@localhost.localdomain>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:20869 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757627AbYD3Vdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2008 17:33:42 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.8/8.13.8) with ESMTP id m3ULXem8181542
	for <netdev@vger.kernel.org>; Wed, 30 Apr 2008 21:33:40 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3ULXeJT3932294
	for <netdev@vger.kernel.org>; Wed, 30 Apr 2008 23:33:40 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3ULXehE029527
	for <netdev@vger.kernel.org>; Wed, 30 Apr 2008 23:33:40 +0200
Content-Disposition: inline; filename=fix-kobject.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a netdev is moved across namespaces with the 'dev_change_net_namespace' 
function, the 'device_rename' function is used to fixup kobject and refresh 
the sysfs tree. The device_rename function will call kobject_rename and this
one will check if there is an object with the same name and this is the case
because we are renaming the object with the same name.

The use of 'device_rename' seems for me wrong because we usually don't
rename it but just move it across namespaces. As we just want to do a 
mini "netdev_[un]register", IMO the functions 'netdev_[un]register_kobject' 
should be used instead, like an usual network device [un]registering.

This patch replace device_rename by netdev_unregister_kobject, followed by
netdev_register_kobject.

The netdev_register_kobject will call device_initialize and will raise a 
warning indicating the device was already initialized. In order to fix that,
I split the device initialization into a separate function and use it together
with 'netdev_register_kobject' into register_netdevice. So we can safely call
'netdev_register_kobject' in 'dev_change_net_namespace'.

This fix will allow to properly use the sysfs per namespace which is coming
from -mm tree.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Acked-by: Benjamin Thery <benjamin.thery@bull.net>
---
 net/core/dev.c       |    4 +++-
 net/core/net-sysfs.c |    7 ++++++-
 net/core/net-sysfs.h |    2 +-
 3 files changed, 10 insertions(+), 3 deletions(-)

Index: net-2.6/net/core/dev.c
===================================================================
--- net-2.6.orig/net/core/dev.c
+++ net-2.6/net/core/dev.c
@@ -3776,6 +3776,7 @@ int register_netdevice(struct net_device
 		}
 	}
 
+	netdev_initialize_kobject(dev);
 	ret = netdev_register_kobject(dev);
 	if (ret)
 		goto err_uninit;
@@ -4208,7 +4209,8 @@ int dev_change_net_namespace(struct net_
 	}
 
 	/* Fixup kobjects */
-	err = device_rename(&dev->dev, dev->name);
+	netdev_unregister_kobject(dev);
+	err = netdev_register_kobject(dev);
 	WARN_ON(err);
 
 	/* Add the device back in the hashes */
Index: net-2.6/net/core/net-sysfs.c
===================================================================
--- net-2.6.orig/net/core/net-sysfs.c
+++ net-2.6/net/core/net-sysfs.c
@@ -449,7 +449,6 @@ int netdev_register_kobject(struct net_d
 	struct device *dev = &(net->dev);
 	struct attribute_group **groups = net->sysfs_groups;
 
-	device_initialize(dev);
 	dev->class = &net_class;
 	dev->platform_data = net;
 	dev->groups = groups;
@@ -470,6 +469,12 @@ int netdev_register_kobject(struct net_d
 	return device_add(dev);
 }
 
+void netdev_initialize_kobject(struct net_device *net)
+{
+	struct device *device = &(net->dev);
+	device_initialize(device);
+}
+
 int netdev_kobject_init(void)
 {
 	return class_register(&net_class);
Index: net-2.6/net/core/net-sysfs.h
===================================================================
--- net-2.6.orig/net/core/net-sysfs.h
+++ net-2.6/net/core/net-sysfs.h
@@ -4,5 +4,5 @@
 int netdev_kobject_init(void);
 int netdev_register_kobject(struct net_device *);
 void netdev_unregister_kobject(struct net_device *);
-
+void netdev_initialize_kobject(struct net_device *);
 #endif

-- 
