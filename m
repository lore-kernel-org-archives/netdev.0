From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/9] bonding: bond_create always called with default parameters
Date: Fri, 12 Jun 2009 22:02:44 -0700
Message-ID: <20090613050421.520406512@vyatta.com>
References: <20090613050243.100086546@vyatta.com>
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: Jay Vosburg <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49234 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753525AbZFMFGS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Jun 2009 01:06:18 -0400
Content-Disposition: inline; filename=bond-default-params.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bond_create() is always called with same parameters so move the argument
down.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/bonding/bond_main.c	2009-06-12 07:10:29.629556854 -0700
+++ b/drivers/net/bonding/bond_main.c	2009-06-12 11:14:15.847243005 -0700
@@ -101,7 +101,7 @@ static int arp_interval = BOND_LINK_ARP_
 static char *arp_ip_target[BOND_MAX_ARP_TARGETS] = { NULL, };
 static char *arp_validate = NULL;
 static char *fail_over_mac = NULL;
-struct bond_params bonding_defaults;
+static struct bond_params bonding_defaults;
 
 module_param(max_bonds, int, 0);
 MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
@@ -4592,7 +4592,7 @@ static const struct net_device_ops bond_
  * Does not allocate but creates a /proc entry.
  * Allowed to fail.
  */
-static int bond_init(struct net_device *bond_dev, struct bond_params *params)
+static int bond_init(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 
@@ -4602,7 +4602,7 @@ static int bond_init(struct net_device *
 	rwlock_init(&bond->lock);
 	rwlock_init(&bond->curr_slave_lock);
 
-	bond->params = *params; /* copy params struct */
+	bond->params = bonding_defaults;
 
 	bond->wq = create_singlethread_workqueue(bond_dev->name);
 	if (!bond->wq)
@@ -5116,7 +5116,7 @@ static void bond_set_lockdep_class(struc
  * Caller must NOT hold rtnl_lock; we need to release it here before we
  * set up our sysfs entries.
  */
-int bond_create(char *name, struct bond_params *params)
+int bond_create(const char *name)
 {
 	struct net_device *bond_dev;
 	struct bonding *bond;
@@ -5159,7 +5159,7 @@ int bond_create(char *name, struct bond_
 	 * need to set function pointers.
 	 */
 
-	res = bond_init(bond_dev, params);
+	res = bond_init(bond_dev);
 	if (res < 0) {
 		goto out_netdev;
 	}
@@ -5212,7 +5212,7 @@ static int __init bonding_init(void)
 	init_rwsem(&bonding_rwsem);
 
 	for (i = 0; i < max_bonds; i++) {
-		res = bond_create(NULL, &bonding_defaults);
+		res = bond_create(NULL);
 		if (res)
 			goto err;
 	}
--- a/drivers/net/bonding/bond_sysfs.c	2009-06-12 07:10:29.655894986 -0700
+++ b/drivers/net/bonding/bond_sysfs.c	2009-06-12 11:12:49.939186681 -0700
@@ -112,7 +112,7 @@ static ssize_t bonding_store_bonds(struc
 	if (command[0] == '+') {
 		printk(KERN_INFO DRV_NAME
 			": %s is being created...\n", ifname);
-		rv = bond_create(ifname, &bonding_defaults);
+		rv = bond_create(ifname);
 		if (rv) {
 			printk(KERN_INFO DRV_NAME ": Bond creation failed.\n");
 			res = rv;
--- a/drivers/net/bonding/bonding.h	2009-06-12 07:10:29.645594813 -0700
+++ b/drivers/net/bonding/bonding.h	2009-06-12 11:12:49.927192098 -0700
@@ -321,7 +321,7 @@ static inline void bond_unset_master_alb
 
 struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr);
 int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
-int bond_create(char *name, struct bond_params *params);
+int bond_create(const char *name);
 void bond_destroy(struct bonding *bond);
 int  bond_release_and_destroy(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_create_sysfs(void);
@@ -349,7 +349,6 @@ extern const struct bond_parm_tbl bond_m
 extern const struct bond_parm_tbl xmit_hashtype_tbl[];
 extern const struct bond_parm_tbl arp_validate_tbl[];
 extern const struct bond_parm_tbl fail_over_mac_tbl[];
-extern struct bond_params bonding_defaults;
 extern struct bond_parm_tbl ad_select_tbl[];
 
 /* exported from bond_sysfs.c */

-- 

