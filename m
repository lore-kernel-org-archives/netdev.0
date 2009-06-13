From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/9] Subjec: bonding: remove bonding read/write semaphore
Date: Fri, 12 Jun 2009 22:02:46 -0700
Message-ID: <20090613050421.699009135@vyatta.com>
References: <20090613050243.100086546@vyatta.com>
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: Jay Vosburg <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49225 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750742AbZFMFGN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Jun 2009 01:06:13 -0400
Content-Disposition: inline; filename=bond-sema.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The whole read/write semaphore locking can be removed. It doesn't add any
protection that isn't already done by using the RTNL mutex properly.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/bonding/bond_main.c	2009-06-12 07:27:12.459766764 -0700
+++ b/drivers/net/bonding/bond_main.c	2009-06-12 07:27:19.557928468 -0700
@@ -3489,10 +3489,10 @@ static int bond_event_changename(struct 
 {
 	bond_remove_proc_entry(bond);
 	bond_create_proc_entry(bond);
-	down_write(&(bonding_rwsem));
+
         bond_destroy_sysfs_entry(bond);
         bond_create_sysfs_entry(bond);
-	up_write(&(bonding_rwsem));
+
 	return NOTIFY_DONE;
 }
 
@@ -4015,7 +4015,6 @@ static int bond_do_ioctl(struct net_devi
 		return -EPERM;
 	}
 
-	down_write(&(bonding_rwsem));
 	slave_dev = dev_get_by_name(&init_net, ifr->ifr_slave);
 
 	pr_debug("slave_dev=%p: \n", slave_dev);
@@ -4048,7 +4047,6 @@ static int bond_do_ioctl(struct net_devi
 		dev_put(slave_dev);
 	}
 
-	up_write(&(bonding_rwsem));
 	return res;
 }
 
@@ -5123,8 +5121,6 @@ int bond_create(const char *name)
 	int res;
 
 	rtnl_lock();
-	down_write(&bonding_rwsem);
-
 	/* Check to see if the bond already exists. */
 	if (name) {
 		list_for_each_entry(bond, &bond_dev_list, bond_list)
@@ -5173,24 +5169,20 @@ int bond_create(const char *name)
 		goto out_bond;
 	}
 
-	up_write(&bonding_rwsem);
-	rtnl_unlock(); /* allows sysfs registration of net device */
 	res = bond_create_sysfs_entry(netdev_priv(bond_dev));
 	if (res < 0)
 		goto out_unreg;
 
+	rtnl_unlock();
 	return 0;
 
 out_unreg:
-	rtnl_lock();
-	down_write(&bonding_rwsem);
 	unregister_netdevice(bond_dev);
 out_bond:
 	bond_deinit(bond_dev);
 out_netdev:
 	free_netdev(bond_dev);
 out_rtnl:
-	up_write(&bonding_rwsem);
 	rtnl_unlock();
 	return res;
 }
@@ -5209,8 +5201,6 @@ static int __init bonding_init(void)
 
 	bond_create_proc_dir();
 
-	init_rwsem(&bonding_rwsem);
-
 	for (i = 0; i < max_bonds; i++) {
 		res = bond_create(NULL);
 		if (res)
--- a/drivers/net/bonding/bond_sysfs.c	2009-06-12 07:25:18.155802980 -0700
+++ b/drivers/net/bonding/bond_sysfs.c	2009-06-12 07:27:19.558928513 -0700
@@ -44,20 +44,6 @@
 /*---------------------------- Declarations -------------------------------*/
 
 static int expected_refcount = -1;
-/*--------------------------- Data Structures -----------------------------*/
-
-/* Bonding sysfs lock.  Why can't we just use the subsystem lock?
- * Because kobject_register tries to acquire the subsystem lock.  If
- * we already hold the lock (which we would if the user was creating
- * a new bond through the sysfs interface), we deadlock.
- * This lock is only needed when deleting a bond - we need to make sure
- * that we don't collide with an ongoing ioctl.
- */
-
-struct rw_semaphore bonding_rwsem;
-
-
-
 
 /*------------------------------ Functions --------------------------------*/
 
@@ -70,7 +56,7 @@ static ssize_t bonding_show_bonds(struct
 	int res = 0;
 	struct bonding *bond;
 
-	down_read(&(bonding_rwsem));
+	rtnl_lock();
 
 	list_for_each_entry(bond, &bond_dev_list, bond_list) {
 		if (res > (PAGE_SIZE - IFNAMSIZ)) {
@@ -84,7 +70,8 @@ static ssize_t bonding_show_bonds(struct
 	}
 	if (res)
 		buf[res-1] = '\n'; /* eat the leftover space */
-	up_read(&(bonding_rwsem));
+
+	rtnl_unlock();
 	return res;
 }
 
@@ -122,7 +109,6 @@ static ssize_t bonding_store_bonds(struc
 
 	if (command[0] == '-') {
 		rtnl_lock();
-		down_write(&bonding_rwsem);
 
 		list_for_each_entry(bond, &bond_dev_list, bond_list)
 			if (strnicmp(bond->dev->name, ifname, IFNAMSIZ) == 0) {
@@ -157,7 +143,6 @@ err_no_cmd:
 	return -EPERM;
 
 out_unlock:
-	up_write(&bonding_rwsem);
 	rtnl_unlock();
 
 	/* Always return either count or an error.  If you return 0, you'll
@@ -253,7 +238,6 @@ static ssize_t bonding_store_slaves(stru
 
 	if (!rtnl_trylock())
 		return restart_syscall();
-	down_write(&(bonding_rwsem));
 
 	sscanf(buffer, "%16s", command); /* IFNAMSIZ*/
 	ifname = command + 1;
@@ -357,7 +341,6 @@ err_no_cmd:
 	ret = -EPERM;
 
 out:
-	up_write(&(bonding_rwsem));
 	rtnl_unlock();
 	return ret;
 }
--- a/drivers/net/bonding/bonding.h	2009-06-12 07:25:18.145850134 -0700
+++ b/drivers/net/bonding/bonding.h	2009-06-12 07:27:19.560013885 -0700
@@ -351,9 +351,6 @@ extern const struct bond_parm_tbl arp_va
 extern const struct bond_parm_tbl fail_over_mac_tbl[];
 extern struct bond_parm_tbl ad_select_tbl[];
 
-/* exported from bond_sysfs.c */
-extern struct rw_semaphore bonding_rwsem;
-
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 void bond_send_unsolicited_na(struct bonding *bond);
 void bond_register_ipv6_notifier(void);

-- 

