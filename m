From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 6/6] net: Expose all network devices in a namespaces in sysfs
Date: Tue,  4 May 2010 17:36:49 -0700
Message-ID: <1273019809-16472-6-git-send-email-ebiederm@xmission.com>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org>
Cc: Kay Sievers <kay.sievers@vrfy.org>, linux-kernel@vger.kernel.org,
	Tejun Heo <tj@kernel.org>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>,
	Serge Hallyn <serue@us.ibm.com>, <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:34782 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934493Ab0EEAhE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 20:37:04 -0400
In-Reply-To: <m1fx3hk6gw.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

This reverts commit aaf8cdc34ddba08122f02217d9d684e2f9f5d575.

Drivers like the ipw2100 call device_create_group when they
are initialized and device_remove_group when they are shutdown.
Moving them between namespaces deletes their sysfs groups early.

In particular the following call chain results.
netdev_unregister_kobject -> device_del -> kobject_del -> sysfs_remove_dir
With sysfs_remove_dir recursively deleting all of it's subdirectories,
and nothing adding them back.

Ouch!

Therefore we need to call something that ultimate calls sysfs_mv_dir
as that sysfs function can move sysfs directories between namespaces
without deleting their subdirectories or their contents.   Allowing
us to avoid placing extra boiler plate into every driver that does
something interesting with sysfs.

Currently the function that provides that capability is device_rename.
That is the code works without nasty side effects as originally written.

So remove the misguided fix for moving devices between namespaces.  The
bug in the kobject layer that inspired it has now been recognized and
fixed.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/core/dev.c       |   28 +++++-----------------------
 net/core/net-sysfs.c |   16 +---------------
 net/core/net-sysfs.h |    1 -
 3 files changed, 6 insertions(+), 39 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index bcc490c..fa54819 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -983,15 +983,10 @@ int dev_change_name(struct net_device *dev, const char *newname)
 		return err;
 
 rollback:
-	/* For now only devices in the initial network namespace
-	 * are in sysfs.
-	 */
-	if (net_eq(net, &init_net)) {
-		ret = device_rename(&dev->dev, dev->name);
-		if (ret) {
-			memcpy(dev->name, oldname, IFNAMSIZ);
-			return ret;
-		}
+	ret = device_rename(&dev->dev, dev->name);
+	if (ret) {
+		memcpy(dev->name, oldname, IFNAMSIZ);
+		return ret;
 	}
 
 	write_lock_bh(&dev_base_lock);
@@ -5106,8 +5101,6 @@ int register_netdevice(struct net_device *dev)
 	if (dev->features & NETIF_F_SG)
 		dev->features |= NETIF_F_GSO;
 
-	netdev_initialize_kobject(dev);
-
 	ret = call_netdevice_notifiers(NETDEV_POST_INIT, dev);
 	ret = notifier_to_errno(ret);
 	if (ret)
@@ -5628,15 +5621,6 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	if (dev->features & NETIF_F_NETNS_LOCAL)
 		goto out;
 
-#ifdef CONFIG_SYSFS
-	/* Don't allow real devices to be moved when sysfs
-	 * is enabled.
-	 */
-	err = -EINVAL;
-	if (dev->dev.parent)
-		goto out;
-#endif
-
 	/* Ensure the device has been registrered */
 	err = -EINVAL;
 	if (dev->reg_state != NETREG_REGISTERED)
@@ -5687,8 +5671,6 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	dev_unicast_flush(dev);
 	dev_addr_discard(dev);
 
-	netdev_unregister_kobject(dev);
-
 	/* Actually switch the network namespace */
 	dev_net_set(dev, net);
 
@@ -5701,7 +5683,7 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	}
 
 	/* Fixup kobjects */
-	err = netdev_register_kobject(dev);
+	err = device_rename(&dev->dev, dev->name);
 	WARN_ON(err);
 
 	/* Add the device back in the hashes */
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 1b98e36..0727c57 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -507,9 +507,6 @@ static int netdev_uevent(struct device *d, struct kobj_uevent_env *env)
 	struct net_device *dev = to_net_dev(d);
 	int retval;
 
-	if (!net_eq(dev_net(dev), &init_net))
-		return 0;
-
 	/* pass interface to uevent. */
 	retval = add_uevent_var(env, "INTERFACE=%s", dev->name);
 	if (retval)
@@ -568,9 +565,6 @@ void netdev_unregister_kobject(struct net_device * net)
 
 	kobject_get(&dev->kobj);
 
-	if (!net_eq(dev_net(net), &init_net))
-		return;
-
 	device_del(dev);
 }
 
@@ -580,6 +574,7 @@ int netdev_register_kobject(struct net_device *net)
 	struct device *dev = &(net->dev);
 	const struct attribute_group **groups = net->sysfs_groups;
 
+	device_initialize(dev);
 	dev->class = &net_class;
 	dev->platform_data = net;
 	dev->groups = groups;
@@ -602,9 +597,6 @@ int netdev_register_kobject(struct net_device *net)
 #endif
 #endif /* CONFIG_SYSFS */
 
-	if (!net_eq(dev_net(net), &init_net))
-		return 0;
-
 	return device_add(dev);
 }
 
@@ -621,12 +613,6 @@ void netdev_class_remove_file(struct class_attribute *class_attr)
 EXPORT_SYMBOL(netdev_class_create_file);
 EXPORT_SYMBOL(netdev_class_remove_file);
 
-void netdev_initialize_kobject(struct net_device *net)
-{
-	struct device *device = &(net->dev);
-	device_initialize(device);
-}
-
 int netdev_kobject_init(void)
 {
 	kobj_ns_type_register(&net_ns_type_operations);
diff --git a/net/core/net-sysfs.h b/net/core/net-sysfs.h
index 14e7524..805555e 100644
--- a/net/core/net-sysfs.h
+++ b/net/core/net-sysfs.h
@@ -4,5 +4,4 @@
 int netdev_kobject_init(void);
 int netdev_register_kobject(struct net_device *);
 void netdev_unregister_kobject(struct net_device *);
-void netdev_initialize_kobject(struct net_device *);
 #endif
-- 
1.6.5.2.143.g8cc62

