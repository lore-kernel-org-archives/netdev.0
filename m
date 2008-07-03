From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 1/5] bonding: refactor mii monitor
Date: Wed,  2 Jul 2008 18:21:58 -0700
Message-ID: <12150481241992-git-send-email-fubar@us.ibm.com>
References: <12150481222323-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:51968 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751533AbYGCBWG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 21:22:06 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m631M6wD008620
	for <netdev@vger.kernel.org>; Wed, 2 Jul 2008 21:22:06 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m631M6BL162804
	for <netdev@vger.kernel.org>; Wed, 2 Jul 2008 21:22:06 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m631M5LZ004139
	for <netdev@vger.kernel.org>; Wed, 2 Jul 2008 21:22:06 -0400
In-Reply-To: <12150481222323-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Refactor mii monitor.  As with the previous ARP monitor refactor,
the motivation for this is to handle locking rationally (in this case,
removing conditional locking) and generally clean up the code.

	This patch breaks up the monolithic mii monitor into two phases:
an inspection phase, followed by an optional commit phase.  The commit phase
is the only portion that requires RTNL or makes changes to state, and is
only called when inspection finds something to change.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_3ad.c  |    1 +
 drivers/net/bonding/bond_main.c |  394 +++++++++++++++++----------------------
 2 files changed, 173 insertions(+), 222 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index ebb539e..6106660 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2107,6 +2107,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 			aggregator = __get_first_agg(port);
 			ad_agg_selection_logic(aggregator);
 		}
+		bond_3ad_set_carrier(bond);
 	}
 
 	// for each port run the state machines
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index d57b65d..6ee6db0 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2208,272 +2208,217 @@ static int bond_slave_info_query(struct net_device *bond_dev, struct ifslave *in
 
 /*-------------------------------- Monitoring -------------------------------*/
 
-/*
- * if !have_locks, return nonzero if a failover is necessary.  if
- * have_locks, do whatever failover activities are needed.
- *
- * This is to separate the inspection and failover steps for locking
- * purposes; failover requires rtnl, but acquiring it for every
- * inspection is undesirable, so a wrapper first does inspection, and
- * the acquires the necessary locks and calls again to perform
- * failover if needed.  Since all locks are dropped, a complete
- * restart is needed between calls.
- */
-static int __bond_mii_monitor(struct bonding *bond, int have_locks)
-{
-	struct slave *slave, *oldcurrent;
-	int do_failover = 0;
-	int i;
-
-	if (bond->slave_cnt == 0)
-		goto out;
 
-	/* we will try to read the link status of each of our slaves, and
-	 * set their IFF_RUNNING flag appropriately. For each slave not
-	 * supporting MII status, we won't do anything so that a user-space
-	 * program could monitor the link itself if needed.
-	 */
-
-	read_lock(&bond->curr_slave_lock);
-	oldcurrent = bond->curr_active_slave;
-	read_unlock(&bond->curr_slave_lock);
+static int bond_miimon_inspect(struct bonding *bond)
+{
+	struct slave *slave;
+	int i, link_state, commit = 0;
 
 	bond_for_each_slave(bond, slave, i) {
-		struct net_device *slave_dev = slave->dev;
-		int link_state;
-		u16 old_speed = slave->speed;
-		u8 old_duplex = slave->duplex;
+		slave->new_link = BOND_LINK_NOCHANGE;
 
-		link_state = bond_check_dev_link(bond, slave_dev, 0);
+		link_state = bond_check_dev_link(bond, slave->dev, 0);
 
 		switch (slave->link) {
-		case BOND_LINK_UP:	/* the link was up */
-			if (link_state == BMSR_LSTATUS) {
-				if (!oldcurrent) {
-					if (!have_locks)
-						return 1;
-					do_failover = 1;
-				}
-				break;
-			} else { /* link going down */
-				slave->link  = BOND_LINK_FAIL;
-				slave->delay = bond->params.downdelay;
-
-				if (slave->link_failure_count < UINT_MAX) {
-					slave->link_failure_count++;
-				}
+		case BOND_LINK_UP:
+			if (link_state)
+				continue;
 
-				if (bond->params.downdelay) {
-					printk(KERN_INFO DRV_NAME
-					       ": %s: link status down for %s "
-					       "interface %s, disabling it in "
-					       "%d ms.\n",
-					       bond->dev->name,
-					       IS_UP(slave_dev)
-					       ? ((bond->params.mode == BOND_MODE_ACTIVEBACKUP)
-						  ? ((slave == oldcurrent)
-						     ? "active " : "backup ")
-						  : "")
-					       : "idle ",
-					       slave_dev->name,
-					       bond->params.downdelay * bond->params.miimon);
-				}
+			slave->link = BOND_LINK_FAIL;
+			slave->delay = bond->params.downdelay;
+			if (slave->delay) {
+				printk(KERN_INFO DRV_NAME
+				       ": %s: link status down for %s"
+				       "interface %s, disabling it in %d ms.\n",
+				       bond->dev->name,
+				       (bond->params.mode ==
+					BOND_MODE_ACTIVEBACKUP) ?
+				       ((slave->state == BOND_STATE_ACTIVE) ?
+					"active " : "backup ") : "",
+				       slave->dev->name,
+				       bond->params.downdelay * bond->params.miimon);
 			}
-			/* no break ! fall through the BOND_LINK_FAIL test to
-			   ensure proper action to be taken
-			*/
-		case BOND_LINK_FAIL:	/* the link has just gone down */
-			if (link_state != BMSR_LSTATUS) {
-				/* link stays down */
-				if (slave->delay <= 0) {
-					if (!have_locks)
-						return 1;
-
-					/* link down for too long time */
-					slave->link = BOND_LINK_DOWN;
-
-					/* in active/backup mode, we must
-					 * completely disable this interface
-					 */
-					if ((bond->params.mode == BOND_MODE_ACTIVEBACKUP) ||
-					    (bond->params.mode == BOND_MODE_8023AD)) {
-						bond_set_slave_inactive_flags(slave);
-					}
-
-					printk(KERN_INFO DRV_NAME
-					       ": %s: link status definitely "
-					       "down for interface %s, "
-					       "disabling it\n",
-					       bond->dev->name,
-					       slave_dev->name);
-
-					/* notify ad that the link status has changed */
-					if (bond->params.mode == BOND_MODE_8023AD) {
-						bond_3ad_handle_link_change(slave, BOND_LINK_DOWN);
-					}
-
-					if ((bond->params.mode == BOND_MODE_TLB) ||
-					    (bond->params.mode == BOND_MODE_ALB)) {
-						bond_alb_handle_link_change(bond, slave, BOND_LINK_DOWN);
-					}
-
-					if (slave == oldcurrent) {
-						do_failover = 1;
-					}
-				} else {
-					slave->delay--;
-				}
-			} else {
-				/* link up again */
-				slave->link  = BOND_LINK_UP;
+			/*FALLTHRU*/
+		case BOND_LINK_FAIL:
+			if (link_state) {
+				/*
+				 * recovered before downdelay expired
+				 */
+				slave->link = BOND_LINK_UP;
 				slave->jiffies = jiffies;
 				printk(KERN_INFO DRV_NAME
 				       ": %s: link status up again after %d "
 				       "ms for interface %s.\n",
 				       bond->dev->name,
-				       (bond->params.downdelay - slave->delay) * bond->params.miimon,
-				       slave_dev->name);
+				       (bond->params.downdelay - slave->delay) *
+				       bond->params.miimon,
+				       slave->dev->name);
+				continue;
 			}
-			break;
-		case BOND_LINK_DOWN:	/* the link was down */
-			if (link_state != BMSR_LSTATUS) {
-				/* the link stays down, nothing more to do */
-				break;
-			} else {	/* link going up */
-				slave->link  = BOND_LINK_BACK;
-				slave->delay = bond->params.updelay;
 
-				if (bond->params.updelay) {
-					/* if updelay == 0, no need to
-					   advertise about a 0 ms delay */
-					printk(KERN_INFO DRV_NAME
-					       ": %s: link status up for "
-					       "interface %s, enabling it "
-					       "in %d ms.\n",
-					       bond->dev->name,
-					       slave_dev->name,
-					       bond->params.updelay * bond->params.miimon);
-				}
+			if (slave->delay <= 0) {
+				slave->new_link = BOND_LINK_DOWN;
+				commit++;
+				continue;
 			}
-			/* no break ! fall through the BOND_LINK_BACK state in
-			   case there's something to do.
-			*/
-		case BOND_LINK_BACK:	/* the link has just come back */
-			if (link_state != BMSR_LSTATUS) {
-				/* link down again */
-				slave->link  = BOND_LINK_DOWN;
 
+			slave->delay--;
+			break;
+
+		case BOND_LINK_DOWN:
+			if (!link_state)
+				continue;
+
+			slave->link = BOND_LINK_BACK;
+			slave->delay = bond->params.updelay;
+
+			if (slave->delay) {
+				printk(KERN_INFO DRV_NAME
+				       ": %s: link status up for "
+				       "interface %s, enabling it in %d ms.\n",
+				       bond->dev->name, slave->dev->name,
+				       bond->params.updelay *
+				       bond->params.miimon);
+			}
+			/*FALLTHRU*/
+		case BOND_LINK_BACK:
+			if (!link_state) {
+				slave->link = BOND_LINK_DOWN;
 				printk(KERN_INFO DRV_NAME
 				       ": %s: link status down again after %d "
 				       "ms for interface %s.\n",
 				       bond->dev->name,
-				       (bond->params.updelay - slave->delay) * bond->params.miimon,
-				       slave_dev->name);
-			} else {
-				/* link stays up */
-				if (slave->delay == 0) {
-					if (!have_locks)
-						return 1;
-
-					/* now the link has been up for long time enough */
-					slave->link = BOND_LINK_UP;
-					slave->jiffies = jiffies;
-
-					if (bond->params.mode == BOND_MODE_8023AD) {
-						/* prevent it from being the active one */
-						slave->state = BOND_STATE_BACKUP;
-					} else if (bond->params.mode != BOND_MODE_ACTIVEBACKUP) {
-						/* make it immediately active */
-						slave->state = BOND_STATE_ACTIVE;
-					} else if (slave != bond->primary_slave) {
-						/* prevent it from being the active one */
-						slave->state = BOND_STATE_BACKUP;
-					}
+				       (bond->params.updelay - slave->delay) *
+				       bond->params.miimon,
+				       slave->dev->name);
 
-					printk(KERN_INFO DRV_NAME
-					       ": %s: link status definitely "
-					       "up for interface %s.\n",
-					       bond->dev->name,
-					       slave_dev->name);
-
-					/* notify ad that the link status has changed */
-					if (bond->params.mode == BOND_MODE_8023AD) {
-						bond_3ad_handle_link_change(slave, BOND_LINK_UP);
-					}
-
-					if ((bond->params.mode == BOND_MODE_TLB) ||
-					    (bond->params.mode == BOND_MODE_ALB)) {
-						bond_alb_handle_link_change(bond, slave, BOND_LINK_UP);
-					}
-
-					if ((!oldcurrent) ||
-					    (slave == bond->primary_slave)) {
-						do_failover = 1;
-					}
-				} else {
-					slave->delay--;
-				}
+				continue;
 			}
+
+			if (slave->delay <= 0) {
+				slave->new_link = BOND_LINK_UP;
+				commit++;
+				continue;
+			}
+
+			slave->delay--;
 			break;
-		default:
-			/* Should not happen */
-			printk(KERN_ERR DRV_NAME
-			       ": %s: Error: %s Illegal value (link=%d)\n",
-			       bond->dev->name,
-			       slave->dev->name,
-			       slave->link);
-			goto out;
-		} /* end of switch (slave->link) */
+		}
+	}
 
-		bond_update_speed_duplex(slave);
+	return commit;
+}
 
-		if (bond->params.mode == BOND_MODE_8023AD) {
-			if (old_speed != slave->speed) {
-				bond_3ad_adapter_speed_changed(slave);
-			}
+static void bond_miimon_commit(struct bonding *bond)
+{
+	struct slave *slave;
+	int i;
+
+	bond_for_each_slave(bond, slave, i) {
+		switch (slave->new_link) {
+		case BOND_LINK_NOCHANGE:
+			continue;
+
+		case BOND_LINK_UP:
+			slave->link = BOND_LINK_UP;
+			slave->jiffies = jiffies;
 
-			if (old_duplex != slave->duplex) {
-				bond_3ad_adapter_duplex_changed(slave);
+			if (bond->params.mode == BOND_MODE_8023AD) {
+				/* prevent it from being the active one */
+				slave->state = BOND_STATE_BACKUP;
+			} else if (bond->params.mode != BOND_MODE_ACTIVEBACKUP) {
+				/* make it immediately active */
+				slave->state = BOND_STATE_ACTIVE;
+			} else if (slave != bond->primary_slave) {
+				/* prevent it from being the active one */
+				slave->state = BOND_STATE_BACKUP;
 			}
-		}
 
-	} /* end of for */
+			printk(KERN_INFO DRV_NAME
+			       ": %s: link status definitely "
+			       "up for interface %s.\n",
+			       bond->dev->name, slave->dev->name);
 
-	if (do_failover) {
-		ASSERT_RTNL();
+			/* notify ad that the link status has changed */
+			if (bond->params.mode == BOND_MODE_8023AD)
+				bond_3ad_handle_link_change(slave, BOND_LINK_UP);
 
-		write_lock_bh(&bond->curr_slave_lock);
+			if ((bond->params.mode == BOND_MODE_TLB) ||
+			    (bond->params.mode == BOND_MODE_ALB))
+				bond_alb_handle_link_change(bond, slave,
+							    BOND_LINK_UP);
 
-		bond_select_active_slave(bond);
+			if (!bond->curr_active_slave ||
+			    (slave == bond->primary_slave))
+				goto do_failover;
 
-		write_unlock_bh(&bond->curr_slave_lock);
+			continue;
 
-	} else
-		bond_set_carrier(bond);
+		case BOND_LINK_DOWN:
+			slave->link = BOND_LINK_DOWN;
 
-out:
-	return 0;
+			if (bond->params.mode == BOND_MODE_ACTIVEBACKUP ||
+			    bond->params.mode == BOND_MODE_8023AD)
+				bond_set_slave_inactive_flags(slave);
+
+			printk(KERN_INFO DRV_NAME
+			       ": %s: link status definitely down for "
+			       "interface %s, disabling it\n",
+			       bond->dev->name, slave->dev->name);
+
+			if (bond->params.mode == BOND_MODE_8023AD)
+				bond_3ad_handle_link_change(slave,
+							    BOND_LINK_DOWN);
+
+			if (bond->params.mode == BOND_MODE_TLB ||
+			    bond->params.mode == BOND_MODE_ALB)
+				bond_alb_handle_link_change(bond, slave,
+							    BOND_LINK_DOWN);
+
+			if (slave == bond->curr_active_slave)
+				goto do_failover;
+
+			continue;
+
+		default:
+			printk(KERN_ERR DRV_NAME
+			       ": %s: invalid new link %d on slave %s\n",
+			       bond->dev->name, slave->new_link,
+			       slave->dev->name);
+			slave->new_link = BOND_LINK_NOCHANGE;
+
+			continue;
+		}
+
+do_failover:
+		ASSERT_RTNL();
+		write_lock_bh(&bond->curr_slave_lock);
+		bond_select_active_slave(bond);
+		write_unlock_bh(&bond->curr_slave_lock);
+	}
+
+	bond_set_carrier(bond);
 }
 
 /*
  * bond_mii_monitor
  *
  * Really a wrapper that splits the mii monitor into two phases: an
- * inspection, then (if inspection indicates something needs to be
- * done) an acquisition of appropriate locks followed by another pass
- * to implement whatever link state changes are indicated.
+ * inspection, then (if inspection indicates something needs to be done)
+ * an acquisition of appropriate locks followed by a commit phase to
+ * implement whatever link state changes are indicated.
  */
 void bond_mii_monitor(struct work_struct *work)
 {
 	struct bonding *bond = container_of(work, struct bonding,
 					    mii_work.work);
-	unsigned long delay;
 
 	read_lock(&bond->lock);
-	if (bond->kill_timers) {
-		read_unlock(&bond->lock);
-		return;
-	}
+	if (bond->kill_timers)
+		goto out;
+
+	if (bond->slave_cnt == 0)
+		goto re_arm;
 
 	if (bond->send_grat_arp) {
 		read_lock(&bond->curr_slave_lock);
@@ -2481,19 +2426,24 @@ void bond_mii_monitor(struct work_struct *work)
 		read_unlock(&bond->curr_slave_lock);
 	}
 
-	if (__bond_mii_monitor(bond, 0)) {
+	if (bond_miimon_inspect(bond)) {
 		read_unlock(&bond->lock);
 		rtnl_lock();
 		read_lock(&bond->lock);
-		__bond_mii_monitor(bond, 1);
+
+		bond_miimon_commit(bond);
+
 		read_unlock(&bond->lock);
 		rtnl_unlock();	/* might sleep, hold no other locks */
 		read_lock(&bond->lock);
 	}
 
-	delay = msecs_to_jiffies(bond->params.miimon);
+re_arm:
+	if (bond->params.miimon)
+		queue_delayed_work(bond->wq, &bond->mii_work,
+				   msecs_to_jiffies(bond->params.miimon));
+out:
 	read_unlock(&bond->lock);
-	queue_delayed_work(bond->wq, &bond->mii_work, delay);
 }
 
 static __be32 bond_glean_dev_ip(struct net_device *dev)
-- 
1.5.2.4

