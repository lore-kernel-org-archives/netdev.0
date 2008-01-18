From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 3/7] bonding: fix locking during alb failover and slave removal
Date: Thu, 17 Jan 2008 16:24:59 -0800
Message-ID: <12006159081875-git-send-email-fubar@us.ibm.com>
References: <12006159033257-git-send-email-fubar@us.ibm.com>
 <12006159063217-git-send-email-fubar@us.ibm.com>
 <12006159071917-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:42520 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756526AbYARAZM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2008 19:25:12 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0I0PBSs025656
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 19:25:11 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0I0PBno210740
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 19:25:11 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0I0PA8a022275
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 19:25:10 -0500
In-Reply-To: <12006159071917-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	alb_fasten_mac_swap (actually rlb_teach_disabled_mac_on_primary)
requries RTNL and no other locks.  This could cause dev_set_promiscuity
and/or dev_set_mac_address to be called with improper locking.

	Changed callers to hold only RTNL during calls to alb_fasten_mac_swap
or functions calling it.  Updated header comments in affected functions to
reflect proper reality of locking requirements.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_alb.c  |   18 ++++++++++++------
 drivers/net/bonding/bond_main.c |   14 ++++++++------
 2 files changed, 20 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 9b55a12..b57bc94 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -979,7 +979,7 @@ static void alb_swap_mac_addr(struct bonding *bond, struct slave *slave1, struct
 /*
  * Send learning packets after MAC address swap.
  *
- * Called with RTNL and bond->lock held for read.
+ * Called with RTNL and no other locks
  */
 static void alb_fasten_mac_swap(struct bonding *bond, struct slave *slave1,
 				struct slave *slave2)
@@ -987,6 +987,8 @@ static void alb_fasten_mac_swap(struct bonding *bond, struct slave *slave1,
 	int slaves_state_differ = (SLAVE_IS_OK(slave1) != SLAVE_IS_OK(slave2));
 	struct slave *disabled_slave = NULL;
 
+	ASSERT_RTNL();
+
 	/* fasten the change in the switch */
 	if (SLAVE_IS_OK(slave1)) {
 		alb_send_learning_packets(slave1, slave1->dev->dev_addr);
@@ -1031,7 +1033,7 @@ static void alb_fasten_mac_swap(struct bonding *bond, struct slave *slave1,
  * a slave that has @slave's permanet address as its current address.
  * We'll make sure that that slave no longer uses @slave's permanent address.
  *
- * Caller must hold bond lock
+ * Caller must hold RTNL and no other locks
  */
 static void alb_change_hw_addr_on_detach(struct bonding *bond, struct slave *slave)
 {
@@ -1542,7 +1544,12 @@ int bond_alb_init_slave(struct bonding *bond, struct slave *slave)
 	return 0;
 }
 
-/* Caller must hold bond lock for write */
+/*
+ * Remove slave from tlb and rlb hash tables, and fix up MAC addresses
+ * if necessary.
+ *
+ * Caller must hold RTNL and no other locks
+ */
 void bond_alb_deinit_slave(struct bonding *bond, struct slave *slave)
 {
 	if (bond->slave_cnt > 1) {
@@ -1658,12 +1665,11 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 				       bond->alb_info.rlb_enabled);
 	}
 
-	read_lock(&bond->lock);
-
 	if (swap_slave) {
 		alb_fasten_mac_swap(bond, swap_slave, new_slave);
+		read_lock(&bond->lock);
 	} else {
-		/* fasten bond mac on new current slave */
+		read_lock(&bond->lock);
 		alb_send_learning_packets(new_slave, bond->dev->dev_addr);
 	}
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b0b2603..77d004d 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1746,7 +1746,9 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 		 * has been cleared (if our_slave == old_current),
 		 * but before a new active slave is selected.
 		 */
+		write_unlock_bh(&bond->lock);
 		bond_alb_deinit_slave(bond, slave);
+		write_lock_bh(&bond->lock);
 	}
 
 	if (oldcurrent == slave) {
@@ -1905,6 +1907,12 @@ static int bond_release_all(struct net_device *bond_dev)
 		slave_dev = slave->dev;
 		bond_detach_slave(bond, slave);
 
+		/* now that the slave is detached, unlock and perform
+		 * all the undo steps that should not be called from
+		 * within a lock.
+		 */
+		write_unlock_bh(&bond->lock);
+
 		if ((bond->params.mode == BOND_MODE_TLB) ||
 		    (bond->params.mode == BOND_MODE_ALB)) {
 			/* must be called only after the slave
@@ -1915,12 +1923,6 @@ static int bond_release_all(struct net_device *bond_dev)
 
 		bond_compute_features(bond);
 
-		/* now that the slave is detached, unlock and perform
-		 * all the undo steps that should not be called from
-		 * within a lock.
-		 */
-		write_unlock_bh(&bond->lock);
-
 		bond_destroy_slave_symlinks(bond_dev, slave_dev);
 		bond_del_vlans_from_slave(bond, slave_dev);
 
-- 
1.5.3.4.206.g58ba4-dirty

