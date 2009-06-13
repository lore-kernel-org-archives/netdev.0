From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 6/9] bonding: elminate bad refcount code
Date: Fri, 12 Jun 2009 22:02:49 -0700
Message-ID: <20090613050422.014974866@vyatta.com>
References: <20090613050243.100086546@vyatta.com>
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: Jay Vosburg <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49236 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753608AbZFMFGS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Jun 2009 01:06:18 -0400
Content-Disposition: inline; filename=bond-refcount.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The "expected_refcount" stuff in bonding sysfs module is a mistake.
Sysfs does proper refcounting, and it is okay to remove a bond device
that has some user process holding the file open.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/bonding/bond_sysfs.c	2009-06-12 21:46:22.183394245 -0700
+++ b/drivers/net/bonding/bond_sysfs.c	2009-06-12 21:46:34.113395362 -0700
@@ -40,12 +40,6 @@
 #define to_dev(obj)	container_of(obj, struct device, kobj)
 #define to_bond(cd)	((struct bonding *)(netdev_priv(to_net_dev(cd))))
 
-/*---------------------------- Declarations -------------------------------*/
-
-static int expected_refcount = -1;
-
-/*------------------------------ Functions --------------------------------*/
-
 /*
  * "show" function for the bond_masters attribute.
  * The class parameter is ignored.
@@ -112,18 +106,6 @@ static ssize_t bonding_store_bonds(struc
 
 		list_for_each_entry(bond, &bond_dev_list, bond_list)
 			if (strnicmp(bond->dev->name, ifname, IFNAMSIZ) == 0) {
-				/* check the ref count on the bond's kobject.
-				 * If it's > expected, then there's a file open,
-				 * and we have to fail.
-				 */
-				if (atomic_read(&bond->dev->dev.kobj.kref.refcount)
-							> expected_refcount){
-					pr_info(DRV_NAME
-						": Unable remove bond %s due to open references.\n",
-						ifname);
-					res = -EPERM;
-					goto out_unlock;
-				}
 				pr_info(DRV_NAME
 					": %s is being deleted...\n",
 					bond->dev->name);
@@ -1579,9 +1561,6 @@ int bond_create_sysfs_entry(struct bondi
 	if (err)
 		printk(KERN_EMERG "eek! didn't create group!\n");
 
-	if (expected_refcount < 1)
-		expected_refcount = atomic_read(&bond->dev->dev.kobj.kref.refcount);
-
 	return err;
 }
 /*

-- 

