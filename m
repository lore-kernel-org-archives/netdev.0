From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 7/8] bonding: refactor ARP active-backup monitor
Date: Sat, 17 May 2008 21:10:13 -0700
Message-ID: <12110838181126-git-send-email-fubar@us.ibm.com>
References: <12110838143907-git-send-email-fubar@us.ibm.com>
 <12110838151824-git-send-email-fubar@us.ibm.com>
 <12110838151104-git-send-email-fubar@us.ibm.com>
 <12110838162313-git-send-email-fubar@us.ibm.com>
 <1211083816660-git-send-email-fubar@us.ibm.com>
 <1211083817934-git-send-email-fubar@us.ibm.com>
 <1211083818228-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:36675 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875AbYEREKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2008 00:10:25 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4I471w8001103
	for <netdev@vger.kernel.org>; Sun, 18 May 2008 00:07:01 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4I4AJlW084062
	for <netdev@vger.kernel.org>; Sat, 17 May 2008 22:10:24 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4I4AJUp004659
	for <netdev@vger.kernel.org>; Sat, 17 May 2008 22:10:19 -0600
In-Reply-To: <1211083818228-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Refactor ARP monitor for active-backup mode.  The motivation for
this is to take care of locking issues in a clear manner (particularly to
correctly handle RTNL vs. the bonding locks).  Currently, the a-b ARP
monitor does not hold RTNL at all, but future changes will require RTNL
during ARP monitor failovers.

	Rather than using conditional locking, this patch instead breaks
up the ARP monitor into three discrete steps: inspection, commit changes,
and probe.  The inspection phase marks slaves that require link state
changes.  The commit phase is only called if inspection detects that
changes are needed, and is called with RTNL.  Lastly, the probe phase
issues the ARP probes that the inspection phase uses to determine link
state.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |  427 ++++++++++++++++++++++-----------------
 drivers/net/bonding/bonding.h   |    6 +
 2 files changed, 248 insertions(+), 185 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index fa3c210..51e0f2d 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1051,6 +1051,8 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 	}
 
 	if (new_active) {
+		new_active->jiffies = jiffies;
+
 		if (new_active->link == BOND_LINK_BACK) {
 			if (USES_PRIMARY(bond->params.mode)) {
 				printk(KERN_INFO DRV_NAME
@@ -1062,7 +1064,6 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 
 			new_active->delay = 0;
 			new_active->link = BOND_LINK_UP;
-			new_active->jiffies = jiffies;
 
 			if (bond->params.mode == BOND_MODE_8023AD) {
 				bond_3ad_handle_link_change(new_active, BOND_LINK_UP);
@@ -2795,243 +2796,299 @@ out:
 }
 
 /*
- * When using arp monitoring in active-backup mode, this function is
- * called to determine if any backup slaves have went down or a new
- * current slave needs to be found.
- * The backup slaves never generate traffic, they are considered up by merely
- * receiving traffic. If the current slave goes down, each backup slave will
- * be given the opportunity to tx/rx an arp before being taken down - this
- * prevents all slaves from being taken down due to the current slave not
- * sending any traffic for the backups to receive. The arps are not necessarily
- * necessary, any tx and rx traffic will keep the current slave up. While any
- * rx traffic will keep the backup slaves up, the current slave is responsible
- * for generating traffic to keep them up regardless of any other traffic they
- * may have received.
- * see loadbalance_arp_monitor for arp monitoring in load balancing mode
+ * Called to inspect slaves for active-backup mode ARP monitor link state
+ * changes.  Sets new_link in slaves to specify what action should take
+ * place for the slave.  Returns 0 if no changes are found, >0 if changes
+ * to link states must be committed.
+ *
+ * Called with bond->lock held for read.
  */
-void bond_activebackup_arp_mon(struct work_struct *work)
+static int bond_ab_arp_inspect(struct bonding *bond, int delta_in_ticks)
 {
-	struct bonding *bond = container_of(work, struct bonding,
-					    arp_work.work);
 	struct slave *slave;
-	int delta_in_ticks;
-	int i;
+	int i, commit = 0;
 
-	read_lock(&bond->lock);
+	bond_for_each_slave(bond, slave, i) {
+		slave->new_link = BOND_LINK_NOCHANGE;
 
-	delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
+		if (slave->link != BOND_LINK_UP) {
+			if (time_before_eq(jiffies, slave_last_rx(bond, slave) +
+					   delta_in_ticks)) {
+				slave->new_link = BOND_LINK_UP;
+				commit++;
+			}
 
-	if (bond->kill_timers) {
-		goto out;
-	}
+			continue;
+		}
 
-	if (bond->slave_cnt == 0) {
-		goto re_arm;
+		/*
+		 * Give slaves 2*delta after being enslaved or made
+		 * active.  This avoids bouncing, as the last receive
+		 * times need a full ARP monitor cycle to be updated.
+		 */
+		if (!time_after_eq(jiffies, slave->jiffies +
+				   2 * delta_in_ticks))
+			continue;
+
+		/*
+		 * Backup slave is down if:
+		 * - No current_arp_slave AND
+		 * - more than 3*delta since last receive AND
+		 * - the bond has an IP address
+		 *
+		 * Note: a non-null current_arp_slave indicates
+		 * the curr_active_slave went down and we are
+		 * searching for a new one; under this condition
+		 * we only take the curr_active_slave down - this
+		 * gives each slave a chance to tx/rx traffic
+		 * before being taken out
+		 */
+		if (slave->state == BOND_STATE_BACKUP &&
+		    !bond->current_arp_slave &&
+		    time_after(jiffies, slave_last_rx(bond, slave) +
+			       3 * delta_in_ticks)) {
+			slave->new_link = BOND_LINK_DOWN;
+			commit++;
+		}
+
+		/*
+		 * Active slave is down if:
+		 * - more than 2*delta since transmitting OR
+		 * - (more than 2*delta since receive AND
+		 *    the bond has an IP address)
+		 */
+		if ((slave->state == BOND_STATE_ACTIVE) &&
+		    (time_after_eq(jiffies, slave->dev->trans_start +
+				    2 * delta_in_ticks) ||
+		      (time_after_eq(jiffies, slave_last_rx(bond, slave)
+				     + 2 * delta_in_ticks)))) {
+			slave->new_link = BOND_LINK_DOWN;
+			commit++;
+		}
 	}
 
-	/* determine if any slave has come up or any backup slave has
-	 * gone down
-	 * TODO: what about up/down delay in arp mode? it wasn't here before
-	 *       so it can wait
+	read_lock(&bond->curr_slave_lock);
+
+	/*
+	 * Trigger a commit if the primary option setting has changed.
 	 */
-	bond_for_each_slave(bond, slave, i) {
-		if (slave->link != BOND_LINK_UP) {
-			if (time_before_eq(jiffies,
-			    slave_last_rx(bond, slave) + delta_in_ticks)) {
+	if (bond->primary_slave &&
+	    (bond->primary_slave != bond->curr_active_slave) &&
+	    (bond->primary_slave->link == BOND_LINK_UP))
+		commit++;
 
-				slave->link = BOND_LINK_UP;
+	read_unlock(&bond->curr_slave_lock);
 
-				write_lock_bh(&bond->curr_slave_lock);
+	return commit;
+}
 
-				if ((!bond->curr_active_slave) &&
-				    time_before_eq(jiffies, slave->dev->trans_start + delta_in_ticks)) {
-					bond_change_active_slave(bond, slave);
-					bond->current_arp_slave = NULL;
-				} else if (bond->curr_active_slave != slave) {
-					/* this slave has just come up but we
-					 * already have a current slave; this
-					 * can also happen if bond_enslave adds
-					 * a new slave that is up while we are
-					 * searching for a new slave
-					 */
-					bond_set_slave_inactive_flags(slave);
-					bond->current_arp_slave = NULL;
-				}
+/*
+ * Called to commit link state changes noted by inspection step of
+ * active-backup mode ARP monitor.
+ *
+ * Called with RTNL and bond->lock for read.
+ */
+static void bond_ab_arp_commit(struct bonding *bond, int delta_in_ticks)
+{
+	struct slave *slave;
+	int i;
 
-				bond_set_carrier(bond);
+	bond_for_each_slave(bond, slave, i) {
+		switch (slave->new_link) {
+		case BOND_LINK_NOCHANGE:
+			continue;
 
-				if (slave == bond->curr_active_slave) {
-					printk(KERN_INFO DRV_NAME
-					       ": %s: %s is up and now the "
-					       "active interface\n",
-					       bond->dev->name,
-					       slave->dev->name);
-					netif_carrier_on(bond->dev);
-				} else {
-					printk(KERN_INFO DRV_NAME
-					       ": %s: backup interface %s is "
-					       "now up\n",
-					       bond->dev->name,
-					       slave->dev->name);
-				}
+		case BOND_LINK_UP:
+			write_lock_bh(&bond->curr_slave_lock);
 
-				write_unlock_bh(&bond->curr_slave_lock);
-			}
-		} else {
-			read_lock(&bond->curr_slave_lock);
+			if (!bond->curr_active_slave &&
+			    time_before_eq(jiffies, slave->dev->trans_start +
+					   delta_in_ticks)) {
+				slave->link = BOND_LINK_UP;
+				bond_change_active_slave(bond, slave);
+				bond->current_arp_slave = NULL;
 
-			if ((slave != bond->curr_active_slave) &&
-			    (!bond->current_arp_slave) &&
-			    (time_after_eq(jiffies, slave_last_rx(bond, slave) + 3*delta_in_ticks))) {
-				/* a backup slave has gone down; three times
-				 * the delta allows the current slave to be
-				 * taken out before the backup slave.
-				 * note: a non-null current_arp_slave indicates
-				 * the curr_active_slave went down and we are
-				 * searching for a new one; under this
-				 * condition we only take the curr_active_slave
-				 * down - this gives each slave a chance to
-				 * tx/rx traffic before being taken out
+				printk(KERN_INFO DRV_NAME
+				       ": %s: %s is up and now the "
+				       "active interface\n",
+				       bond->dev->name, slave->dev->name);
+
+			} else if (bond->curr_active_slave != slave) {
+				/* this slave has just come up but we
+				 * already have a current slave; this can
+				 * also happen if bond_enslave adds a new
+				 * slave that is up while we are searching
+				 * for a new slave
 				 */
+				slave->link = BOND_LINK_UP;
+				bond_set_slave_inactive_flags(slave);
+				bond->current_arp_slave = NULL;
+
+				printk(KERN_INFO DRV_NAME
+				       ": %s: backup interface %s is now up\n",
+				       bond->dev->name, slave->dev->name);
+			}
 
-				read_unlock(&bond->curr_slave_lock);
+			write_unlock_bh(&bond->curr_slave_lock);
 
-				slave->link  = BOND_LINK_DOWN;
+			break;
 
-				if (slave->link_failure_count < UINT_MAX) {
-					slave->link_failure_count++;
-				}
+		case BOND_LINK_DOWN:
+			if (slave->link_failure_count < UINT_MAX)
+				slave->link_failure_count++;
+
+			slave->link = BOND_LINK_DOWN;
+
+			if (slave == bond->curr_active_slave) {
+				printk(KERN_INFO DRV_NAME
+				       ": %s: link status down for active "
+				       "interface %s, disabling it\n",
+				       bond->dev->name, slave->dev->name);
 
 				bond_set_slave_inactive_flags(slave);
 
+				write_lock_bh(&bond->curr_slave_lock);
+
+				bond_select_active_slave(bond);
+				if (bond->curr_active_slave)
+					bond->curr_active_slave->jiffies =
+						jiffies;
+
+				write_unlock_bh(&bond->curr_slave_lock);
+
+				bond->current_arp_slave = NULL;
+
+			} else if (slave->state == BOND_STATE_BACKUP) {
 				printk(KERN_INFO DRV_NAME
 				       ": %s: backup interface %s is now down\n",
-				       bond->dev->name,
-				       slave->dev->name);
-			} else {
-				read_unlock(&bond->curr_slave_lock);
+				       bond->dev->name, slave->dev->name);
+
+				bond_set_slave_inactive_flags(slave);
 			}
+			break;
+
+		default:
+			printk(KERN_ERR DRV_NAME
+			       ": %s: impossible: new_link %d on slave %s\n",
+			       bond->dev->name, slave->new_link,
+			       slave->dev->name);
 		}
 	}
 
-	read_lock(&bond->curr_slave_lock);
-	slave = bond->curr_active_slave;
-	read_unlock(&bond->curr_slave_lock);
-
-	if (slave) {
-		/* if we have sent traffic in the past 2*arp_intervals but
-		 * haven't xmit and rx traffic in that time interval, select
-		 * a different slave. slave->jiffies is only updated when
-		 * a slave first becomes the curr_active_slave - not necessarily
-		 * after every arp; this ensures the slave has a full 2*delta
-		 * before being taken out. if a primary is being used, check
-		 * if it is up and needs to take over as the curr_active_slave
-		 */
-		if ((time_after_eq(jiffies, slave->dev->trans_start + 2*delta_in_ticks) ||
-		     (time_after_eq(jiffies, slave_last_rx(bond, slave) + 2*delta_in_ticks))) &&
-			time_after_eq(jiffies, slave->jiffies + 2*delta_in_ticks)) {
+	/*
+	 * No race with changes to primary via sysfs, as we hold rtnl.
+	 */
+	if (bond->primary_slave &&
+	    (bond->primary_slave != bond->curr_active_slave) &&
+	    (bond->primary_slave->link == BOND_LINK_UP)) {
+		write_lock_bh(&bond->curr_slave_lock);
+		bond_change_active_slave(bond, bond->primary_slave);
+		write_unlock_bh(&bond->curr_slave_lock);
+	}
 
-			slave->link  = BOND_LINK_DOWN;
+	bond_set_carrier(bond);
+}
 
-			if (slave->link_failure_count < UINT_MAX) {
-				slave->link_failure_count++;
-			}
+/*
+ * Send ARP probes for active-backup mode ARP monitor.
+ *
+ * Called with bond->lock held for read.
+ */
+static void bond_ab_arp_probe(struct bonding *bond)
+{
+	struct slave *slave;
+	int i;
 
-			printk(KERN_INFO DRV_NAME
-			       ": %s: link status down for active interface "
-			       "%s, disabling it\n",
-			       bond->dev->name,
-			       slave->dev->name);
+	read_lock(&bond->curr_slave_lock);
 
-			write_lock_bh(&bond->curr_slave_lock);
+	if (bond->current_arp_slave && bond->curr_active_slave)
+		printk("PROBE: c_arp %s && cas %s BAD\n",
+		       bond->current_arp_slave->dev->name,
+		       bond->curr_active_slave->dev->name);
 
-			bond_select_active_slave(bond);
-			slave = bond->curr_active_slave;
+	if (bond->curr_active_slave) {
+		bond_arp_send_all(bond, bond->curr_active_slave);
+		read_unlock(&bond->curr_slave_lock);
+		return;
+	}
 
-			write_unlock_bh(&bond->curr_slave_lock);
+	read_unlock(&bond->curr_slave_lock);
 
-			bond->current_arp_slave = slave;
+	/* if we don't have a curr_active_slave, search for the next available
+	 * backup slave from the current_arp_slave and make it the candidate
+	 * for becoming the curr_active_slave
+	 */
 
-			if (slave) {
-				slave->jiffies = jiffies;
-			}
-		} else if ((bond->primary_slave) &&
-			   (bond->primary_slave != slave) &&
-			   (bond->primary_slave->link == BOND_LINK_UP)) {
-			/* at this point, slave is the curr_active_slave */
-			printk(KERN_INFO DRV_NAME
-			       ": %s: changing from interface %s to primary "
-			       "interface %s\n",
-			       bond->dev->name,
-			       slave->dev->name,
-			       bond->primary_slave->dev->name);
+	if (!bond->current_arp_slave) {
+		bond->current_arp_slave = bond->first_slave;
+		if (!bond->current_arp_slave)
+			return;
+	}
 
-			/* primary is up so switch to it */
-			write_lock_bh(&bond->curr_slave_lock);
-			bond_change_active_slave(bond, bond->primary_slave);
-			write_unlock_bh(&bond->curr_slave_lock);
+	bond_set_slave_inactive_flags(bond->current_arp_slave);
 
-			slave = bond->primary_slave;
+	/* search for next candidate */
+	bond_for_each_slave_from(bond, slave, i, bond->current_arp_slave->next) {
+		if (IS_UP(slave->dev)) {
+			slave->link = BOND_LINK_BACK;
+			bond_set_slave_active_flags(slave);
+			bond_arp_send_all(bond, slave);
 			slave->jiffies = jiffies;
-		} else {
-			bond->current_arp_slave = NULL;
+			bond->current_arp_slave = slave;
+			break;
 		}
 
-		/* the current slave must tx an arp to ensure backup slaves
-		 * rx traffic
+		/* if the link state is up at this point, we
+		 * mark it down - this can happen if we have
+		 * simultaneous link failures and
+		 * reselect_active_interface doesn't make this
+		 * one the current slave so it is still marked
+		 * up when it is actually down
 		 */
-		if (slave && IS_UP(slave->dev))
-			bond_arp_send_all(bond, slave);
-	}
+		if (slave->link == BOND_LINK_UP) {
+			slave->link = BOND_LINK_DOWN;
+			if (slave->link_failure_count < UINT_MAX)
+				slave->link_failure_count++;
 
-	/* if we don't have a curr_active_slave, search for the next available
-	 * backup slave from the current_arp_slave and make it the candidate
-	 * for becoming the curr_active_slave
-	 */
-	if (!slave) {
-		if (!bond->current_arp_slave) {
-			bond->current_arp_slave = bond->first_slave;
+			bond_set_slave_inactive_flags(slave);
+
+			printk(KERN_INFO DRV_NAME
+			       ": %s: backup interface %s is now down.\n",
+			       bond->dev->name, slave->dev->name);
 		}
+	}
+}
 
-		if (bond->current_arp_slave) {
-			bond_set_slave_inactive_flags(bond->current_arp_slave);
+void bond_activebackup_arp_mon(struct work_struct *work)
+{
+	struct bonding *bond = container_of(work, struct bonding,
+					    arp_work.work);
+	int delta_in_ticks;
 
-			/* search for next candidate */
-			bond_for_each_slave_from(bond, slave, i, bond->current_arp_slave->next) {
-				if (IS_UP(slave->dev)) {
-					slave->link = BOND_LINK_BACK;
-					bond_set_slave_active_flags(slave);
-					bond_arp_send_all(bond, slave);
-					slave->jiffies = jiffies;
-					bond->current_arp_slave = slave;
-					break;
-				}
+	read_lock(&bond->lock);
 
-				/* if the link state is up at this point, we
-				 * mark it down - this can happen if we have
-				 * simultaneous link failures and
-				 * reselect_active_interface doesn't make this
-				 * one the current slave so it is still marked
-				 * up when it is actually down
-				 */
-				if (slave->link == BOND_LINK_UP) {
-					slave->link  = BOND_LINK_DOWN;
-					if (slave->link_failure_count < UINT_MAX) {
-						slave->link_failure_count++;
-					}
+	if (bond->kill_timers)
+		goto out;
 
-					bond_set_slave_inactive_flags(slave);
+	delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
 
-					printk(KERN_INFO DRV_NAME
-					       ": %s: backup interface %s is "
-					       "now down.\n",
-					       bond->dev->name,
-					       slave->dev->name);
-				}
-			}
-		}
+	if (bond->slave_cnt == 0)
+		goto re_arm;
+
+	if (bond_ab_arp_inspect(bond, delta_in_ticks)) {
+		read_unlock(&bond->lock);
+		rtnl_lock();
+		read_lock(&bond->lock);
+
+		bond_ab_arp_commit(bond, delta_in_ticks);
+
+		read_unlock(&bond->lock);
+		rtnl_unlock();
+		read_lock(&bond->lock);
 	}
 
+	bond_ab_arp_probe(bond);
+
 re_arm:
 	if (bond->params.arp_interval) {
 		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 46a2ed5..8766b12 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -158,6 +158,7 @@ struct slave {
 	unsigned long jiffies;
 	unsigned long last_arp_rx;
 	s8     link;    /* one of BOND_LINK_XXXX */
+	s8     new_link;
 	s8     state;   /* one of BOND_STATE_XXXX */
 	u32    original_flags;
 	u32    original_mtu;
@@ -170,6 +171,11 @@ struct slave {
 };
 
 /*
+ * Link pseudo-state only used internally by monitors
+ */
+#define BOND_LINK_NOCHANGE -1
+
+/*
  * Here are the locking policies for the two bonding locks:
  *
  * 1) Get bond->lock when reading/writing slave list.
-- 
1.5.2.4

