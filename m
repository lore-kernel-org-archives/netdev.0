From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 6/7] bonding: fix lock ordering for rtnl and bonding_rwsem
Date: Thu, 17 Jan 2008 16:25:02 -0800
Message-ID: <12006159123054-git-send-email-fubar@us.ibm.com>
References: <12006159033257-git-send-email-fubar@us.ibm.com>
 <12006159063217-git-send-email-fubar@us.ibm.com>
 <12006159071917-git-send-email-fubar@us.ibm.com>
 <12006159081875-git-send-email-fubar@us.ibm.com>
 <12006159102124-git-send-email-fubar@us.ibm.com>
 <12006159111680-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:43892 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756561AbYARAZQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2008 19:25:16 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0I0PFYv021407
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 19:25:15 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0I0PEuH1080344
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 19:25:14 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0I0PDgG022655
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 19:25:14 -0500
In-Reply-To: <12006159111680-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the handling of rtnl and the bonding_rwsem to always be acquired
in a consistent order (rtnl, then bonding_rwsem).

The existing code sometimes acquired them in this order, and sometimes
in the opposite order, which opens a window for deadlock between ifenslave
and sysfs.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c  |   19 ++++++++++++++++
 drivers/net/bonding/bond_sysfs.c |   43 ++++++++++++++-----------------------
 2 files changed, 35 insertions(+), 27 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 379c5d8..2c6da49 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4874,9 +4874,22 @@ static struct lock_class_key bonding_netdev_xmit_lock_key;
 int bond_create(char *name, struct bond_params *params, struct bonding **newbond)
 {
 	struct net_device *bond_dev;
+	struct bonding *bond, *nxt;
 	int res;
 
 	rtnl_lock();
+	down_write(&bonding_rwsem);
+
+	/* Check to see if the bond already exists. */
+	list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list)
+		if (strnicmp(bond->dev->name, name, IFNAMSIZ) == 0) {
+			printk(KERN_ERR DRV_NAME
+			       ": cannot add bond %s; it already exists\n",
+			       name);
+			res = -EPERM;
+			goto out_rtnl;
+		}
+
 	bond_dev = alloc_netdev(sizeof(struct bonding), name ? name : "",
 				ether_setup);
 	if (!bond_dev) {
@@ -4915,10 +4928,12 @@ int bond_create(char *name, struct bond_params *params, struct bonding **newbond
 
 	netif_carrier_off(bond_dev);
 
+	up_write(&bonding_rwsem);
 	rtnl_unlock(); /* allows sysfs registration of net device */
 	res = bond_create_sysfs_entry(bond_dev->priv);
 	if (res < 0) {
 		rtnl_lock();
+		down_write(&bonding_rwsem);
 		goto out_bond;
 	}
 
@@ -4929,6 +4944,7 @@ out_bond:
 out_netdev:
 	free_netdev(bond_dev);
 out_rtnl:
+	up_write(&bonding_rwsem);
 	rtnl_unlock();
 	return res;
 }
@@ -4949,6 +4965,9 @@ static int __init bonding_init(void)
 #ifdef CONFIG_PROC_FS
 	bond_create_proc_dir();
 #endif
+
+	init_rwsem(&bonding_rwsem);
+
 	for (i = 0; i < max_bonds; i++) {
 		res = bond_create(NULL, &bonding_defaults, NULL);
 		if (res)
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index bff4f2b..90a1f31 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -109,11 +109,10 @@ static ssize_t bonding_store_bonds(struct class *cls, const char *buffer, size_t
 {
 	char command[IFNAMSIZ + 1] = {0, };
 	char *ifname;
-	int res = count;
+	int rv, res = count;
 	struct bonding *bond;
 	struct bonding *nxt;
 
-	down_write(&(bonding_rwsem));
 	sscanf(buffer, "%16s", command); /* IFNAMSIZ*/
 	ifname = command + 1;
 	if ((strlen(command) <= 1) ||
@@ -121,39 +120,28 @@ static ssize_t bonding_store_bonds(struct class *cls, const char *buffer, size_t
 		goto err_no_cmd;
 
 	if (command[0] == '+') {
-
-		/* Check to see if the bond already exists. */
-		list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list)
-			if (strnicmp(bond->dev->name, ifname, IFNAMSIZ) == 0) {
-				printk(KERN_ERR DRV_NAME
-					": cannot add bond %s; it already exists\n",
-					ifname);
-				res = -EPERM;
-				goto out;
-			}
-
 		printk(KERN_INFO DRV_NAME
 			": %s is being created...\n", ifname);
-		if (bond_create(ifname, &bonding_defaults, &bond)) {
-			printk(KERN_INFO DRV_NAME
-			": %s interface already exists. Bond creation failed.\n",
-			ifname);
-			res = -EPERM;
+		rv = bond_create(ifname, &bonding_defaults, &bond);
+		if (rv) {
+			printk(KERN_INFO DRV_NAME ": Bond creation failed.\n");
+			res = rv;
 		}
 		goto out;
 	}
 
 	if (command[0] == '-') {
+		rtnl_lock();
+		down_write(&bonding_rwsem);
+
 		list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list)
 			if (strnicmp(bond->dev->name, ifname, IFNAMSIZ) == 0) {
-				rtnl_lock();
 				/* check the ref count on the bond's kobject.
 				 * If it's > expected, then there's a file open,
 				 * and we have to fail.
 				 */
 				if (atomic_read(&bond->dev->dev.kobj.kref.refcount)
 							> expected_refcount){
-					rtnl_unlock();
 					printk(KERN_INFO DRV_NAME
 						": Unable remove bond %s due to open references.\n",
 						ifname);
@@ -164,6 +152,7 @@ static ssize_t bonding_store_bonds(struct class *cls, const char *buffer, size_t
 					": %s is being deleted...\n",
 					bond->dev->name);
 				bond_destroy(bond);
+				up_write(&bonding_rwsem);
 				rtnl_unlock();
 				goto out;
 			}
@@ -171,6 +160,8 @@ static ssize_t bonding_store_bonds(struct class *cls, const char *buffer, size_t
 		printk(KERN_ERR DRV_NAME
 			": unable to delete non-existent bond %s\n", ifname);
 		res = -ENODEV;
+		up_write(&bonding_rwsem);
+		rtnl_unlock();
 		goto out;
 	}
 
@@ -183,7 +174,6 @@ err_no_cmd:
 	 * get called forever, which is bad.
 	 */
 out:
-	up_write(&(bonding_rwsem));
 	return res;
 }
 /* class attribute for bond_masters file.  This ends up in /sys/class/net */
@@ -271,6 +261,9 @@ static ssize_t bonding_store_slaves(struct device *d,
 
 	/* Note:  We can't hold bond->lock here, as bond_create grabs it. */
 
+	rtnl_lock();
+	down_write(&(bonding_rwsem));
+
 	sscanf(buffer, "%16s", command); /* IFNAMSIZ*/
 	ifname = command + 1;
 	if ((strlen(command) <= 1) ||
@@ -336,12 +329,10 @@ static ssize_t bonding_store_slaves(struct device *d,
 				dev->mtu = bond->dev->mtu;
 			}
 		}
-		rtnl_lock();
 		res = bond_enslave(bond->dev, dev);
 		bond_for_each_slave(bond, slave, i)
 			if (strnicmp(slave->dev->name, ifname, IFNAMSIZ) == 0)
 				slave->original_mtu = original_mtu;
-		rtnl_unlock();
 		if (res) {
 			ret = res;
 		}
@@ -359,12 +350,10 @@ static ssize_t bonding_store_slaves(struct device *d,
 		if (dev) {
 			printk(KERN_INFO DRV_NAME ": %s: Removing slave %s\n",
 				bond->dev->name, dev->name);
-			rtnl_lock();
 			if (bond->setup_by_slave)
 				res = bond_release_and_destroy(bond->dev, dev);
 			else
 				res = bond_release(bond->dev, dev);
-			rtnl_unlock();
 			if (res) {
 				ret = res;
 				goto out;
@@ -389,6 +378,8 @@ err_no_cmd:
 	ret = -EPERM;
 
 out:
+	up_write(&(bonding_rwsem));
+	rtnl_unlock();
 	return ret;
 }
 
@@ -1423,8 +1414,6 @@ int bond_create_sysfs(void)
 	int ret = 0;
 	struct bonding *firstbond;
 
-	init_rwsem(&bonding_rwsem);
-
 	/* get the netdev class pointer */
 	firstbond = container_of(bond_dev_list.next, struct bonding, bond_list);
 	if (!firstbond)
-- 
1.5.3.4.206.g58ba4-dirty

