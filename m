From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 2/6] bond: Simply bond sysfs group creation
Date: Thu, 29 Oct 2009 17:18:22 -0700
Message-ID: <1256861906-5059-2-git-send-email-ebiederm@xmission.com>
References: <m1tyxhwxah.fsf@fess.ebiederm.org>
Cc: <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:35830 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755430AbZJ3ASl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 20:18:41 -0400
In-Reply-To: <m1tyxhwxah.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@aristanetworks.com>

This patch delegates the work of creating the sysfs groups
to the netdev layer and ultimately to the device layer.  This
closes races between uevents.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 drivers/net/bonding/bond_main.c  |   11 +----------
 drivers/net/bonding/bond_sysfs.c |   20 ++------------------
 drivers/net/bonding/bonding.h    |    3 +--
 3 files changed, 4 insertions(+), 30 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 8c5ebfb..f73d2de 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2011,7 +2011,6 @@ static void bond_uninit(struct net_device *bond_dev)
 	struct bonding *bond = netdev_priv(bond_dev);
 
 	bond_deinit(bond_dev);
-	bond_destroy_sysfs_entry(bond);
 
 	if (bond->wq)
 		destroy_workqueue(bond->wq);
@@ -3457,9 +3456,6 @@ static int bond_event_changename(struct bonding *bond)
 	bond_remove_proc_entry(bond);
 	bond_create_proc_entry(bond);
 
-	bond_destroy_sysfs_entry(bond);
-	bond_create_sysfs_entry(bond);
-
 	return NOTIFY_DONE;
 }
 
@@ -5078,6 +5074,7 @@ static int bond_init(struct net_device *bond_dev)
 	bond_create_proc_entry(bond);
 	list_add_tail(&bond->bond_list, &bond_dev_list);
 
+	bond_prepare_sysfs_group(bond);
 	return 0;
 }
 
@@ -5120,15 +5117,9 @@ int bond_create(const char *name)
 	if (res < 0)
 		goto out_bond;
 
-	res = bond_create_sysfs_entry(netdev_priv(bond_dev));
-	if (res < 0)
-		goto out_unreg;
-
 	rtnl_unlock();
 	return 0;
 
-out_unreg:
-	unregister_netdevice(bond_dev);
 out_bond:
 	bond_deinit(bond_dev);
 out_netdev:
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index dca7d82..f924a0b 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1616,24 +1616,8 @@ void bond_destroy_sysfs(void)
  * Initialize sysfs for each bond.  This sets up and registers
  * the 'bondctl' directory for each individual bond under /sys/class/net.
  */
-int bond_create_sysfs_entry(struct bonding *bond)
+void bond_prepare_sysfs_group(struct bonding *bond)
 {
-	struct net_device *dev = bond->dev;
-	int err;
-
-	err = sysfs_create_group(&(dev->dev.kobj), &bonding_group);
-	if (err)
-		pr_emerg("eek! didn't create group!\n");
-
-	return err;
-}
-/*
- * Remove sysfs entries for each bond.
- */
-void bond_destroy_sysfs_entry(struct bonding *bond)
-{
-	struct net_device *dev = bond->dev;
-
-	sysfs_remove_group(&(dev->dev.kobj), &bonding_group);
+	bond->dev->sysfs_groups[0] = &bonding_group;
 }
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 9b520b0..013be29 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -331,8 +331,7 @@ int bond_create(const char *name);
 int  bond_release_and_destroy(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_create_sysfs(void);
 void bond_destroy_sysfs(void);
-void bond_destroy_sysfs_entry(struct bonding *bond);
-int bond_create_sysfs_entry(struct bonding *bond);
+void bond_prepare_sysfs_group(struct bonding *bond);
 int bond_create_slave_symlinks(struct net_device *master, struct net_device *slave);
 void bond_destroy_slave_symlinks(struct net_device *master, struct net_device *slave);
 int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev);
-- 
1.6.3.1.54.g99dd.dirty

