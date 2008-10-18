From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/6] bonding: allow configuration without sysfs
Date: Fri, 17 Oct 2008 21:32:53 -0700
Message-ID: <20081018043323.385249409@vyatta.com>
References: <20081018043252.968940967@vyatta.com>
Cc: bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jay Vousburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:52221 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751189AbYJREgz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Oct 2008 00:36:55 -0400
Content-Disposition: inline; filename=bonding-no-sysfs.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In embedded environments sysfs is optional, so stub out and remove
code if not needed.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/bonding/Makefile    |    5 ++++-
 drivers/net/bonding/bond_main.c |    2 ++
 2 files changed, 6 insertions(+), 1 deletion(-)

--- a/drivers/net/bonding/Makefile	2008-10-09 14:05:35.000000000 +0200
+++ b/drivers/net/bonding/Makefile	2008-10-09 15:20:52.000000000 +0200
@@ -4,5 +4,8 @@
 
 obj-$(CONFIG_BONDING) += bonding.o
 
-bonding-objs := bond_main.o bond_3ad.o bond_alb.o bond_sysfs.o
+bonding-y := bond_main.o bond_3ad.o bond_alb.o
+
+bonding-$(CONFIG_SYSFS) += bond_sysfs.o
+
 
--- a/drivers/net/bonding/bond_main.c	2008-10-11 13:46:05.000000000 +0200
+++ b/drivers/net/bonding/bond_main.c	2008-10-11 13:53:32.000000000 +0200
@@ -150,7 +150,15 @@ LIST_HEAD(bond_dev_list);
 static struct proc_dir_entry *bond_proc_dir = NULL;
 #endif
 
-extern struct rw_semaphore bonding_rwsem;
+/* Bonding sysfs lock.  Why can't we just use the subsystem lock?
+ * Because kobject_register tries to acquire the subsystem lock.  If
+ * we already hold the lock (which we would if the user was creating
+ * a new bond through the sysfs interface), we deadlock.
+ * This lock is only needed when deleting a bond - we need to make sure
+ * that we don't collide with an ongoing ioctl.
+ */
+struct rw_semaphore bonding_rwsem;
+
 static __be32 arp_target[BOND_MAX_ARP_TARGETS] = { 0, } ;
 static int arp_ip_count	= 0;
 static int bond_mode	= BOND_MODE_ROUNDROBIN;
@@ -3474,10 +3482,12 @@ static int bond_event_changename(struct 
 	bond_remove_proc_entry(bond);
 	bond_create_proc_entry(bond);
 #endif
+#ifdef CONFIG_SYSFS
 	down_write(&(bonding_rwsem));
         bond_destroy_sysfs_entry(bond);
         bond_create_sysfs_entry(bond);
 	up_write(&(bonding_rwsem));
+#endif
 	return NOTIFY_DONE;
 }
 
--- a/drivers/net/bonding/bond_sysfs.c	2008-10-11 13:50:00.000000000 +0200
+++ b/drivers/net/bonding/bond_sysfs.c	2008-10-11 13:53:22.000000000 +0200
@@ -53,22 +53,6 @@ extern struct bond_parm_tbl arp_validate
 extern struct bond_parm_tbl fail_over_mac_tbl[];
 
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
-
-/*------------------------------ Functions --------------------------------*/
 
 /*
  * "show" function for the bond_masters attribute.
--- a/drivers/net/bonding/bonding.h	2008-10-11 13:51:18.000000000 +0200
+++ b/drivers/net/bonding/bonding.h	2008-10-11 13:51:30.000000000 +0200
@@ -310,6 +310,8 @@ static inline void bond_unset_master_alb
 	bond->dev->priv_flags &= ~IFF_MASTER_ALB;
 }
 
+extern struct rw_semaphore bonding_rwsem;
+
 struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr);
 int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
 int bond_create(char *name, struct bond_params *params);

-- 

