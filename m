From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 5/5] bonding: Allow setting max_bonds to zero
Date: Fri, 13 Jun 2008 18:12:04 -0700
Message-ID: <12134059271179-git-send-email-fubar@us.ibm.com>
References: <12134059242107-git-send-email-fubar@us.ibm.com>
 <12134059253135-git-send-email-fubar@us.ibm.com>
 <12134059253839-git-send-email-fubar@us.ibm.com>
 <12134059261873-git-send-email-fubar@us.ibm.com>
 <12134059261828-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Phil Oester <kernel@linuxace.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:58284 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757882AbYFNBMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 21:12:19 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5E1C8Ud008567
	for <netdev@vger.kernel.org>; Fri, 13 Jun 2008 21:12:08 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5E1C8pi155988
	for <netdev@vger.kernel.org>; Fri, 13 Jun 2008 19:12:08 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5E1C7Cw030325
	for <netdev@vger.kernel.org>; Fri, 13 Jun 2008 19:12:08 -0600
In-Reply-To: <12134059261828-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Permit bonding to function rationally if max_bonds is set to
zero.  This will load the module, but create no master devices (which can
be created via sysfs).

	Requires some change to bond_create_sysfs; currently, the
netdev sysfs directory is determined from the first bonding device created,
but this is no longer possible.  Instead, an interface from net/core is
created to create and destroy files in net_class.

	Based on a patch submitted by Phil Oester <kernel@linuxaces.com>.
Modified by Jay Vosburgh to fix the sysfs issue mentioned above and to
update the documentation.

Signed-off-by: Phil Oester <kernel@linuxace.com>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 Documentation/networking/bonding.txt |    3 ++-
 drivers/net/bonding/bond_main.c      |    6 +++---
 drivers/net/bonding/bond_sysfs.c     |   22 +++-------------------
 include/linux/netdevice.h            |    3 +++
 net/core/net-sysfs.c                 |   13 +++++++++++++
 5 files changed, 24 insertions(+), 23 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 370b7da..7fa7fe7 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -376,7 +376,8 @@ max_bonds
 	Specifies the number of bonding devices to create for this
 	instance of the bonding driver.  E.g., if max_bonds is 3, and
 	the bonding driver is not already loaded, then bond0, bond1
-	and bond2 will be created.  The default value is 1.
+	and bond2 will be created.  The default value is 1.  Specifying
+	a value of 0 will load bonding, but will not create any devices.
 
 miimon
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 3b6d66a..d57b65d 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4750,11 +4750,11 @@ static int bond_check_params(struct bond_params *params)
 		}
 	}
 
-	if (max_bonds < 1 || max_bonds > INT_MAX) {
+	if (max_bonds < 0 || max_bonds > INT_MAX) {
 		printk(KERN_WARNING DRV_NAME
 		       ": Warning: max_bonds (%d) not in range %d-%d, so it "
 		       "was reset to BOND_DEFAULT_MAX_BONDS (%d)\n",
-		       max_bonds, 1, INT_MAX, BOND_DEFAULT_MAX_BONDS);
+		       max_bonds, 0, INT_MAX, BOND_DEFAULT_MAX_BONDS);
 		max_bonds = BOND_DEFAULT_MAX_BONDS;
 	}
 
@@ -4953,7 +4953,7 @@ static int bond_check_params(struct bond_params *params)
 
 		printk("\n");
 
-	} else {
+	} else if (max_bonds) {
 		/* miimon and arp_interval not set, we need one so things
 		 * work as expected, see bonding.txt for details
 		 */
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index dd265c6..6caac0f 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -53,7 +53,6 @@ extern struct bond_parm_tbl arp_validate_tbl[];
 extern struct bond_parm_tbl fail_over_mac_tbl[];
 
 static int expected_refcount = -1;
-static struct class *netdev_class;
 /*--------------------------- Data Structures -----------------------------*/
 
 /* Bonding sysfs lock.  Why can't we just use the subsystem lock?
@@ -1447,19 +1446,9 @@ static struct attribute_group bonding_group = {
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
-
-	netdev_class = firstbond->dev->dev.class;
-	if (!netdev_class)
-		return -ENODEV;
+	int ret;
 
-	ret = class_create_file(netdev_class, &class_attr_bonding_masters);
+	ret = netdev_class_create_file(&class_attr_bonding_masters);
 	/*
 	 * Permit multiple loads of the module by ignoring failures to
 	 * create the bonding_masters sysfs file.  Bonding devices
@@ -1478,10 +1467,6 @@ int bond_create_sysfs(void)
 			printk(KERN_ERR
 			       "network device named %s already exists in sysfs",
 			       class_attr_bonding_masters.attr.name);
-		else {
-			netdev_class = NULL;
-			return 0;
-		}
 	}
 
 	return ret;
@@ -1493,8 +1478,7 @@ int bond_create_sysfs(void)
  */
 void bond_destroy_sysfs(void)
 {
-	if (netdev_class)
-		class_remove_file(netdev_class, &class_attr_bonding_masters);
+	netdev_class_remove_file(&class_attr_bonding_masters);
 }
 
 /*
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e92fc83..9ccbfac 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1506,6 +1506,9 @@ extern void *dev_seq_next(struct seq_file *seq, void *v, loff_t *pos);
 extern void dev_seq_stop(struct seq_file *seq, void *v);
 #endif
 
+extern int netdev_class_create_file(struct class_attribute *class_attr);
+extern void netdev_class_remove_file(struct class_attribute *class_attr);
+
 extern void linkwatch_run_queue(void);
 
 extern int netdev_compute_features(unsigned long all, unsigned long one);
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index dccd737..3f79413 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -468,6 +468,19 @@ int netdev_register_kobject(struct net_device *net)
 	return device_add(dev);
 }
 
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
+
 void netdev_initialize_kobject(struct net_device *net)
 {
 	struct device *device = &(net->dev);
-- 
1.5.2.4

