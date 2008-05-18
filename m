From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 3/8] bonding: Remove redundant argument from bond_create.
Date: Sat, 17 May 2008 21:10:09 -0700
Message-ID: <12110838162313-git-send-email-fubar@us.ibm.com>
References: <12110838143907-git-send-email-fubar@us.ibm.com>
 <12110838151824-git-send-email-fubar@us.ibm.com>
 <12110838151104-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, Pavel Emelyanov <xemul@openvz.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:46290 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751492AbYEREKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2008 00:10:30 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4I4AMj2024500
	for <netdev@vger.kernel.org>; Sun, 18 May 2008 00:10:22 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4I4AHuJ111422
	for <netdev@vger.kernel.org>; Sat, 17 May 2008 22:10:22 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4I4AGHQ004584
	for <netdev@vger.kernel.org>; Sat, 17 May 2008 22:10:17 -0600
In-Reply-To: <12110838151104-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>

While we're fixing the bond_create, I hope it's OK to polish it
a bit after the fixes.

The third argument is NULL at the first caller and is ignored by
the second one, so remove it.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
Acked-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c  |    7 ++-----
 drivers/net/bonding/bond_sysfs.c |    2 +-
 drivers/net/bonding/bonding.h    |    2 +-
 3 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index e3da1e5..6b12164 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4848,7 +4848,7 @@ static struct lock_class_key bonding_netdev_xmit_lock_key;
  * Caller must NOT hold rtnl_lock; we need to release it here before we
  * set up our sysfs entries.
  */
-int bond_create(char *name, struct bond_params *params, struct bonding **newbond)
+int bond_create(char *name, struct bond_params *params)
 {
 	struct net_device *bond_dev;
 	struct bonding *bond, *nxt;
@@ -4902,9 +4902,6 @@ int bond_create(char *name, struct bond_params *params, struct bonding **newbond
 
 	lockdep_set_class(&bond_dev->_xmit_lock, &bonding_netdev_xmit_lock_key);
 
-	if (newbond)
-		*newbond = bond_dev->priv;
-
 	netif_carrier_off(bond_dev);
 
 	up_write(&bonding_rwsem);
@@ -4950,7 +4947,7 @@ static int __init bonding_init(void)
 	init_rwsem(&bonding_rwsem);
 
 	for (i = 0; i < max_bonds; i++) {
-		res = bond_create(NULL, &bonding_defaults, NULL);
+		res = bond_create(NULL, &bonding_defaults);
 		if (res)
 			goto err;
 	}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 08f3d39..452a789 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -122,7 +122,7 @@ static ssize_t bonding_store_bonds(struct class *cls, const char *buffer, size_t
 	if (command[0] == '+') {
 		printk(KERN_INFO DRV_NAME
 			": %s is being created...\n", ifname);
-		rv = bond_create(ifname, &bonding_defaults, &bond);
+		rv = bond_create(ifname, &bonding_defaults);
 		if (rv) {
 			printk(KERN_INFO DRV_NAME ": Bond creation failed.\n");
 			res = rv;
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index a3c74e2..0ce7f4a 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -301,7 +301,7 @@ static inline void bond_unset_master_alb_flags(struct bonding *bond)
 
 struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr);
 int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
-int bond_create(char *name, struct bond_params *params, struct bonding **newbond);
+int bond_create(char *name, struct bond_params *params);
 void bond_destroy(struct bonding *bond);
 int  bond_release_and_destroy(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_create_sysfs(void);
-- 
1.5.2.4

