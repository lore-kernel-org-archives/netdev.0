From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 4/6] Convert locks to _bh, rework alb locking for new locking
Date: Wed, 10 Oct 2007 21:14:07 -0700
Message-ID: <11920760532491-git-send-email-fubar@us.ibm.com>
References: <11920760494096-git-send-email-fubar@us.ibm.com>
 <11920760502756-git-send-email-fubar@us.ibm.com>
 <1192076051437-git-send-email-fubar@us.ibm.com>
 <11920760522759-git-send-email-fubar@us.ibm.com>
Cc: andy@greyhouse.net, Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:40627 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343AbXJKEOP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 00:14:15 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9B4EEDn001885
	for <netdev@vger.kernel.org>; Thu, 11 Oct 2007 00:14:14 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9B4EEY1383058
	for <netdev@vger.kernel.org>; Wed, 10 Oct 2007 22:14:14 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9B4EDPp027212
	for <netdev@vger.kernel.org>; Wed, 10 Oct 2007 22:14:14 -0600
In-Reply-To: <11920760522759-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	Convert locking-related activity to new & improved system.
Convert some lock acquisitions to _bh and rework parts of ALB mode, both
to avoid deadlocks with workqueue activity.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_alb.c  |   69 +++++++++++++++++++++++++++++++---
 drivers/net/bonding/bond_main.c |   78 +++++++++++++++++++++++++++------------
 2 files changed, 117 insertions(+), 30 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index eb320c3..f2e2872 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -959,19 +959,34 @@ static int alb_set_slave_mac_addr(struct slave *slave, u8 addr[], int hw)
 	return 0;
 }
 
-/* Caller must hold bond lock for write or curr_slave_lock for write*/
+/*
+ * Swap MAC addresses between two slaves.
+ *
+ * Called with RTNL held, and no other locks.
+ *
+ */
+
 static void alb_swap_mac_addr(struct bonding *bond, struct slave *slave1, struct slave *slave2)
 {
-	struct slave *disabled_slave = NULL;
 	u8 tmp_mac_addr[ETH_ALEN];
-	int slaves_state_differ;
-
-	slaves_state_differ = (SLAVE_IS_OK(slave1) != SLAVE_IS_OK(slave2));
 
 	memcpy(tmp_mac_addr, slave1->dev->dev_addr, ETH_ALEN);
 	alb_set_slave_mac_addr(slave1, slave2->dev->dev_addr, bond->alb_info.rlb_enabled);
 	alb_set_slave_mac_addr(slave2, tmp_mac_addr, bond->alb_info.rlb_enabled);
 
+}
+
+/*
+ * Send learning packets after MAC address swap.
+ *
+ * Called with RTNL and bond->lock held for read.
+ */
+static void alb_fasten_mac_swap(struct bonding *bond, struct slave *slave1,
+				struct slave *slave2)
+{
+	int slaves_state_differ = (SLAVE_IS_OK(slave1) != SLAVE_IS_OK(slave2));
+	struct slave *disabled_slave = NULL;
+
 	/* fasten the change in the switch */
 	if (SLAVE_IS_OK(slave1)) {
 		alb_send_learning_packets(slave1, slave1->dev->dev_addr);
@@ -1044,7 +1059,9 @@ static void alb_change_hw_addr_on_detach(struct bonding *bond, struct slave *sla
 		}
 
 		if (found) {
+			/* locking: needs RTNL and nothing else */
 			alb_swap_mac_addr(bond, slave, tmp_slave);
+			alb_fasten_mac_swap(bond, slave, tmp_slave);
 		}
 	}
 }
@@ -1571,13 +1588,21 @@ void bond_alb_handle_link_change(struct bonding *bond, struct slave *slave, char
  * Set the bond->curr_active_slave to @new_slave and handle
  * mac address swapping and promiscuity changes as needed.
  *
- * Caller must hold bond curr_slave_lock for write (or bond lock for write)
+ * If new_slave is NULL, caller must hold curr_slave_lock or
+ * bond->lock for write.
+ *
+ * If new_slave is not NULL, caller must hold RTNL, bond->lock for
+ * read and curr_slave_lock for write.  Processing here may sleep, so
+ * no other locks may be held.
  */
 void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave)
 {
 	struct slave *swap_slave;
 	int i;
 
+	if (new_slave)
+		ASSERT_RTNL();
+
 	if (bond->curr_active_slave == new_slave) {
 		return;
 	}
@@ -1610,6 +1635,19 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 		}
 	}
 
+	/*
+	 * Arrange for swap_slave and new_slave to temporarily be
+	 * ignored so we can mess with their MAC addresses without
+	 * fear of interference from transmit activity.
+	 */
+	if (swap_slave) {
+		tlb_clear_slave(bond, swap_slave, 1);
+	}
+	tlb_clear_slave(bond, new_slave, 1);
+
+	write_unlock_bh(&bond->curr_slave_lock);
+	read_unlock(&bond->lock);
+
 	/* curr_active_slave must be set before calling alb_swap_mac_addr */
 	if (swap_slave) {
 		/* swap mac address */
@@ -1618,11 +1656,23 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 		/* set the new_slave to the bond mac address */
 		alb_set_slave_mac_addr(new_slave, bond->dev->dev_addr,
 				       bond->alb_info.rlb_enabled);
+	}
+
+	read_lock(&bond->lock);
+
+	if (swap_slave) {
+		alb_fasten_mac_swap(bond, swap_slave, new_slave);
+	} else {
 		/* fasten bond mac on new current slave */
 		alb_send_learning_packets(new_slave, bond->dev->dev_addr);
 	}
+
+	write_lock_bh(&bond->curr_slave_lock);
 }
 
+/*
+ * Called with RTNL
+ */
 int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 {
 	struct bonding *bond = bond_dev->priv;
@@ -1659,8 +1709,12 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 		}
 	}
 
+	write_unlock_bh(&bond->curr_slave_lock);
+	read_unlock(&bond->lock);
+
 	if (swap_slave) {
 		alb_swap_mac_addr(bond, swap_slave, bond->curr_active_slave);
+		alb_fasten_mac_swap(bond, swap_slave, bond->curr_active_slave);
 	} else {
 		alb_set_slave_mac_addr(bond->curr_active_slave, bond_dev->dev_addr,
 				       bond->alb_info.rlb_enabled);
@@ -1672,6 +1726,9 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 		}
 	}
 
+	read_lock(&bond->lock);
+	write_lock_bh(&bond->curr_slave_lock);
+
 	return 0;
 }
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index d7f98c2..2bb5b50 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1523,15 +1523,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	case BOND_MODE_TLB:
 	case BOND_MODE_ALB:
 		new_slave->state = BOND_STATE_ACTIVE;
-		if ((!bond->curr_active_slave) &&
-		    (new_slave->link != BOND_LINK_DOWN)) {
-			/* first slave or no active slave yet, and this link
-			 * is OK, so make this interface the active one
-			 */
-			bond_change_active_slave(bond, new_slave);
-		} else {
-			bond_set_slave_inactive_flags(new_slave);
-		}
+		bond_set_slave_inactive_flags(new_slave);
 		break;
 	default:
 		dprintk("This slave is always active in trunk mode\n");
@@ -1685,9 +1677,23 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 		bond_alb_deinit_slave(bond, slave);
 	}
 
-	if (oldcurrent == slave)
+	if (oldcurrent == slave) {
+		/*
+		 * Note that we hold RTNL over this sequence, so there
+		 * is no concern that another slave add/remove event
+		 * will interfere.
+		 */
+		write_unlock_bh(&bond->lock);
+		read_lock(&bond->lock);
+		write_lock_bh(&bond->curr_slave_lock);
+
 		bond_select_active_slave(bond);
 
+		write_unlock_bh(&bond->curr_slave_lock);
+		read_unlock(&bond->lock);
+		write_lock_bh(&bond->lock);
+	}
+
 	if (bond->slave_cnt == 0) {
 		bond_set_carrier(bond);
 
@@ -1910,16 +1916,19 @@ static int bond_ioctl_change_active(struct net_device *bond_dev, struct net_devi
 		return -EINVAL;
 	}
 
-	write_lock_bh(&bond->lock);
+	read_lock(&bond->lock);
 
+	read_lock(&bond->curr_slave_lock);
 	old_active = bond->curr_active_slave;
+	read_unlock(&bond->curr_slave_lock);
+
 	new_active = bond_get_slave_by_dev(bond, slave_dev);
 
 	/*
 	 * Changing to the current active: do nothing; return success.
 	 */
 	if (new_active && (new_active == old_active)) {
-		write_unlock_bh(&bond->lock);
+		read_unlock(&bond->lock);
 		return 0;
 	}
 
@@ -1927,12 +1936,14 @@ static int bond_ioctl_change_active(struct net_device *bond_dev, struct net_devi
 	    (old_active) &&
 	    (new_active->link == BOND_LINK_UP) &&
 	    IS_UP(new_active->dev)) {
+		write_lock_bh(&bond->curr_slave_lock);
 		bond_change_active_slave(bond, new_active);
+		write_unlock_bh(&bond->curr_slave_lock);
 	} else {
 		res = -EINVAL;
 	}
 
-	write_unlock_bh(&bond->lock);
+	read_unlock(&bond->lock);
 
 	return res;
 }
@@ -2027,7 +2038,11 @@ static int __bond_mii_monitor(struct bonding *bond, int have_locks)
 		switch (slave->link) {
 		case BOND_LINK_UP:	/* the link was up */
 			if (link_state == BMSR_LSTATUS) {
-				/* link stays up, nothing more to do */
+				if (!oldcurrent) {
+					if (!have_locks)
+						return 1;
+					do_failover = 1;
+				}
 				break;
 			} else { /* link going down */
 				slave->link  = BOND_LINK_FAIL;
@@ -2214,11 +2229,14 @@ static int __bond_mii_monitor(struct bonding *bond, int have_locks)
 	} /* end of for */
 
 	if (do_failover) {
-		write_lock(&bond->curr_slave_lock);
+		ASSERT_RTNL();
+
+		write_lock_bh(&bond->curr_slave_lock);
 
 		bond_select_active_slave(bond);
 
-		write_unlock(&bond->curr_slave_lock);
+		write_unlock_bh(&bond->curr_slave_lock);
+
 	} else
 		bond_set_carrier(bond);
 
@@ -2657,11 +2675,14 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 	}
 
 	if (do_failover) {
-		write_lock(&bond->curr_slave_lock);
+		rtnl_lock();
+		write_lock_bh(&bond->curr_slave_lock);
 
 		bond_select_active_slave(bond);
 
-		write_unlock(&bond->curr_slave_lock);
+		write_unlock_bh(&bond->curr_slave_lock);
+		rtnl_unlock();
+
 	}
 
 re_arm:
@@ -2718,7 +2739,9 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 
 				slave->link = BOND_LINK_UP;
 
-				write_lock(&bond->curr_slave_lock);
+				rtnl_lock();
+
+				write_lock_bh(&bond->curr_slave_lock);
 
 				if ((!bond->curr_active_slave) &&
 				    ((jiffies - slave->dev->trans_start) <= delta_in_ticks)) {
@@ -2752,7 +2775,8 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 					       slave->dev->name);
 				}
 
-				write_unlock(&bond->curr_slave_lock);
+				write_unlock_bh(&bond->curr_slave_lock);
+				rtnl_unlock();
 			}
 		} else {
 			read_lock(&bond->curr_slave_lock);
@@ -2822,12 +2846,15 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 			       bond->dev->name,
 			       slave->dev->name);
 
-			write_lock(&bond->curr_slave_lock);
+			rtnl_lock();
+			write_lock_bh(&bond->curr_slave_lock);
 
 			bond_select_active_slave(bond);
 			slave = bond->curr_active_slave;
 
-			write_unlock(&bond->curr_slave_lock);
+			write_unlock_bh(&bond->curr_slave_lock);
+
+			rtnl_unlock();
 
 			bond->current_arp_slave = slave;
 
@@ -2846,9 +2873,12 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 			       bond->primary_slave->dev->name);
 
 			/* primary is up so switch to it */
-			write_lock(&bond->curr_slave_lock);
+			rtnl_lock();
+			write_lock_bh(&bond->curr_slave_lock);
 			bond_change_active_slave(bond, bond->primary_slave);
-			write_unlock(&bond->curr_slave_lock);
+			write_unlock_bh(&bond->curr_slave_lock);
+
+			rtnl_unlock();
 
 			slave = bond->primary_slave;
 			slave->jiffies = jiffies;
-- 
1.5.3.1

