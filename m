From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH RFC] net/core: API to create/destroy /sys/class/net entries
Date: Wed, 16 Apr 2008 18:06:26 -0700
Message-ID: <14079.1208394386@death>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:42437 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753983AbYDQBGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 21:06:33 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3H16S97015999
	for <netdev@vger.kernel.org>; Wed, 16 Apr 2008 21:06:28 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3H16Svo205060
	for <netdev@vger.kernel.org>; Wed, 16 Apr 2008 19:06:28 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3H16RVA021527
	for <netdev@vger.kernel.org>; Wed, 16 Apr 2008 19:06:28 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Some background: 

	Bonding creates a file in sysfs, /sys/class/net/bonding_masters,
which is used to create and destroy bonding devices.  Currently, when
bonding is loaded, it does some poking through the device structure of
the first bonding device to find the net_class, and then uses that
pointer to create the file (by calling class_create_file).

	Now, I'm working on a patch to permit bonding to load and not
create any devices initially (at the request of a user).  Without the
initial bonding device, there's nothing to backtrack to find the
net_class, and so there's no good way to create the bonding_masters
file, and therefore no way to create any bonding devices.

	I'm attaching the relevant portion of a work-in-progress patch
below to get some input on the best way to create the bonding_masters
file.

	The patch below creates an API in net/core/net-sysfs.c to create
and destroy files within net_class.  Is this the best way to do this, or
would it be preferrable to simply export net_class?

	Comments, please.  This feels cleaner overall to me, but I'd
like some feedback.

	-J


diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 979c2d0..b54ab1d 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -52,7 +52,6 @@ extern struct bond_parm_tbl xmit_hashtype_tbl[];
 extern struct bond_parm_tbl arp_validate_tbl[];
 
 static int expected_refcount = -1;
-static struct class *netdev_class;
 /*--------------------------- Data Structures -----------------------------*/
 
 /* Bonding sysfs lock.  Why can't we just use the subsystem lock?
@@ -1412,19 +1411,9 @@ static struct attribute_group bonding_group = {
  */
 int bond_create_sysfs(void)
 {
-	int ret = 0;
-	struct bonding *firstbond;
-
-	/* get the netdev class pointer */
-	firstbond = container_of(bond_dev_list.next, struct bonding, bond_list);
-	if (!firstbond)
-		return -ENODEV;
+	int ret;
 
-	netdev_class = firstbond->dev->dev.class;
-	if (!netdev_class)
-		return -ENODEV;
-
-	ret = class_create_file(netdev_class, &class_attr_bonding_masters);
+	ret = netdev_class_create_file(&class_attr_bonding_masters);
 	/*
 	 * Permit multiple loads of the module by ignoring failures to
 	 * create the bonding_masters sysfs file.  Bonding devices
@@ -1436,10 +1425,8 @@ int bond_create_sysfs(void)
 	 * initscripts/sysconfig, which load bonding multiple times to
 	 * configure multiple bonding devices.
 	 */
-	if (ret == -EEXIST) {
-		netdev_class = NULL;
+	if (ret == -EEXIST)
 		return 0;
-	}
 
 	return ret;
 
@@ -1450,8 +1437,7 @@ int bond_create_sysfs(void)
  */
 void bond_destroy_sysfs(void)
 {
-	if (netdev_class)
-		class_remove_file(netdev_class, &class_attr_bonding_masters);
+	netdev_class_remove_file(&class_attr_bonding_masters);
 }
 
 /*
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7c1d446..85adc92 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1485,6 +1485,11 @@ extern void *dev_seq_next(struct seq_file *seq, void *v, loff_t *pos);
 extern void dev_seq_stop(struct seq_file *seq, void *v);
 #endif
 
+#ifdef CONFIG_SYSFS
+extern int netdev_class_create_file(struct class_attribute *class_attr);
+extern void netdev_class_remove_file(struct class_attribute *class_attr);
+#endif /* CONFIG_SYSFS */
+
 extern void linkwatch_run_queue(void);
 
 extern int netdev_compute_features(unsigned long all, unsigned long one);
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 7635d3f..3ab1dab 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -468,6 +468,21 @@ int netdev_register_kobject(struct net_device *net)
 	return device_add(dev);
 }
 
+#ifdef CONFIG_SYSFS
+int netdev_class_create_file(struct class_attribute *class_attr)
+{
+	return class_create_file(&net_class, class_attr);
+}
+
+void netdev_class_remove_file(struct class_attribute *class_attr)
+{
+	class_remove_file(&net_class, class_attr);
+}
+
+EXPORT_SYMBOL(netdev_class_create_file);
+EXPORT_SYMBOL(netdev_class_remove_file);
+#endif /* CONFIG_SYSFS */
+
 int netdev_kobject_init(void)
 {
 	return class_register(&net_class);


---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
