From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bonding-devel] [PROBLEM] Bonding driver in linux-2.6.21-rc6-mm1
Date: Thu, 10 May 2007 12:57:19 -0700
Message-ID: <26826.1178827039@death>
References: <200704262058.33087.ve@vetienne.net> <46310B19.8@redhat.com> <1791.1177620299@death> <200705092047.11753.ve@vetienne.net>
Cc: Chris Snook <csnook@redhat.com>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: Vincent ETIENNE <ve@vetienne.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:60481 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751580AbXEJT5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 15:57:38 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4AJvX40028209
	for <netdev@vger.kernel.org>; Thu, 10 May 2007 15:57:33 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4AJvXRF176042
	for <netdev@vger.kernel.org>; Thu, 10 May 2007 13:57:33 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4AJvWFV023536
	for <netdev@vger.kernel.org>; Thu, 10 May 2007 13:57:33 -0600
In-reply-to: <200705092047.11753.ve@vetienne.net> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vincent ETIENNE <ve@vetienne.net> wrote:

>Any news and/or patch concerning this problem ?. Not intended to stress you 
>but time goes on... Do you think a solution could be found in a relatively 
>short timeframe (and i will delay a bit final installation) or is it better 
>to go without bonding and do an upgrade later ?.

	Our working patch is appended; I'm getting a bunch of warnings
from the lockdep stuff that I'm sorting through.  I'm not sure if
they're real concerns or just misconfiguration of lockdep itself.  This
doesn't fix everything (e.g., enslaving a VLAN device), but covers most
of the usual trouble cases.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 7e03f41..c8394a0 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2097,8 +2097,10 @@ void bond_3ad_unbind_slave(struct slave *slave)
  * times out, and it selects an aggregator for the ports that are yet not
  * related to any aggregator, and selects the active aggregator for a bond.
  */
-void bond_3ad_state_machine_handler(struct bonding *bond)
+void bond_3ad_state_machine_handler(struct work_struct *work)
 {
+	struct bonding *bond = container_of(work, struct bonding,
+					    ad_work.work);
 	struct port *port;
 	struct aggregator *aggregator;
 
@@ -2149,7 +2151,7 @@ void bond_3ad_state_machine_handler(struct bonding *bond)
 	}
 
 re_arm:
-	mod_timer(&(BOND_AD_INFO(bond).ad_timer), jiffies + ad_delta_in_ticks);
+	queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
 out:
 	read_unlock(&bond->lock);
 }
diff --git a/drivers/net/bonding/bond_3ad.h b/drivers/net/bonding/bond_3ad.h
index 6ad5ad6..cf5142d 100644
--- a/drivers/net/bonding/bond_3ad.h
+++ b/drivers/net/bonding/bond_3ad.h
@@ -276,7 +276,7 @@ struct ad_slave_info {
 void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution, int lacp_fast);
 int  bond_3ad_bind_slave(struct slave *slave);
 void bond_3ad_unbind_slave(struct slave *slave);
-void bond_3ad_state_machine_handler(struct bonding *bond);
+void bond_3ad_state_machine_handler(struct work_struct *);
 void bond_3ad_adapter_speed_changed(struct slave *slave);
 void bond_3ad_adapter_duplex_changed(struct slave *slave);
 void bond_3ad_handle_link_change(struct slave *slave, char link);
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 92c3b6f..4cdea61 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -42,7 +42,6 @@
 #include "bonding.h"
 #include "bond_alb.h"
 
-
 #define ALB_TIMER_TICKS_PER_SEC	    10	/* should be a divisor of HZ */
 #define BOND_TLB_REBALANCE_INTERVAL 10	/* In seconds, periodic re-balancing.
 					 * Used for division - never set
@@ -469,13 +468,13 @@ static void rlb_clear_slave(struct bonding *bond, struct slave *slave)
 
 	_unlock_rx_hashtbl(bond);
 
-	write_lock(&bond->curr_slave_lock);
+	write_lock_bh(&bond->curr_slave_lock);
 
 	if (slave != bond->curr_active_slave) {
 		rlb_teach_disabled_mac_on_primary(bond, slave->dev->dev_addr);
 	}
 
-	write_unlock(&bond->curr_slave_lock);
+	write_unlock_bh(&bond->curr_slave_lock);
 }
 
 static void rlb_update_client(struct rlb_client_info *client_info)
@@ -956,19 +955,33 @@ static int alb_set_slave_mac_addr(struct slave *slave, u8 addr[], int hw)
 	return 0;
 }
 
-/* Caller must hold bond lock for write or curr_slave_lock for write*/
+/*
+ * Swap MAC addresses between two slaves.
+ *
+ * Called with RTNL held, and no other locks.
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
@@ -1041,7 +1054,9 @@ static void alb_change_hw_addr_on_detach(struct bonding *bond, struct slave *sla
 		}
 
 		if (found) {
+			/* XXX locking: needs RTNL and nothing else */
 			alb_swap_mac_addr(bond, slave, tmp_slave);
+			alb_fasten_mac_swap(bond, slave, tmp_slave);
 		}
 	}
 }
@@ -1373,8 +1388,10 @@ out:
 	return 0;
 }
 
-void bond_alb_monitor(struct bonding *bond)
+void bond_alb_monitor(struct work_struct *work)
 {
+	struct bonding *bond = container_of(work, struct bonding,
+					    alb_work.work);
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
 	struct slave *slave;
 	int i;
@@ -1477,7 +1494,7 @@ void bond_alb_monitor(struct bonding *bond)
 	}
 
 re_arm:
-	mod_timer(&(bond_info->alb_timer), jiffies + alb_delta_in_ticks);
+	queue_delayed_work(bond->wq, &bond->alb_work, alb_delta_in_ticks);
 out:
 	read_unlock(&bond->lock);
 }
@@ -1498,11 +1515,11 @@ int bond_alb_init_slave(struct bonding *bond, struct slave *slave)
 	/* caller must hold the bond lock for write since the mac addresses
 	 * are compared and may be swapped.
 	 */
-	write_lock_bh(&bond->lock);
+	read_lock(&bond->lock);
 
 	res = alb_handle_addr_collision_on_attach(bond, slave);
 
-	write_unlock_bh(&bond->lock);
+	read_unlock(&bond->lock);
 
 	if (res) {
 		return res;
@@ -1567,7 +1584,12 @@ void bond_alb_handle_link_change(struct bonding *bond, struct slave *slave, char
  * Set the bond->curr_active_slave to @new_slave and handle
  * mac address swapping and promiscuity changes as needed.
  *
- * Caller must hold bond curr_slave_lock for write (or bond lock for write)
+ * If new_slave is NULL, caller must hold curr_slave_lock or
+ * bond->lock for write.
+ *
+ * If new_slave is not NULL, caller must hold RTNL, bond->lock for
+ * read and curr_slave_lock for write_bh.  Processing here may sleep, so
+ * no other locks may be held.
  */
 void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave)
 {
@@ -1606,19 +1628,30 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 		}
 	}
 
+	write_unlock_bh(&bond->curr_slave_lock);
+	read_unlock(&bond->lock);
+
 	/* curr_active_slave must be set before calling alb_swap_mac_addr */
-	if (swap_slave) {
-		/* swap mac address */
+	if (swap_slave)
 		alb_swap_mac_addr(bond, swap_slave, new_slave);
-	} else {
+	else
 		/* set the new_slave to the bond mac address */
 		alb_set_slave_mac_addr(new_slave, bond->dev->dev_addr,
 				       bond->alb_info.rlb_enabled);
+
+	read_lock(&bond->lock);
+	write_lock_bh(&bond->curr_slave_lock);
+
+	if (swap_slave)
+		alb_fasten_mac_swap(bond, swap_slave, new_slave);
+	else
 		/* fasten bond mac on new current slave */
 		alb_send_learning_packets(new_slave, bond->dev->dev_addr);
-	}
 }
 
+/*
+ * Called with RTNL
+ */
 int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 {
 	struct bonding *bond = bond_dev->priv;
@@ -1655,8 +1688,12 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
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
@@ -1668,6 +1705,9 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 		}
 	}
 
+	read_lock(&bond->lock);
+	write_lock_bh(&bond->curr_slave_lock);
+
 	return 0;
 }
 
diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
index 28f2a2f..5a37e43 100644
--- a/drivers/net/bonding/bond_alb.h
+++ b/drivers/net/bonding/bond_alb.h
@@ -125,7 +125,7 @@ void bond_alb_deinit_slave(struct bonding *bond, struct slave *slave);
 void bond_alb_handle_link_change(struct bonding *bond, struct slave *slave, char link);
 void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave);
 int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev);
-void bond_alb_monitor(struct bonding *bond);
+void bond_alb_monitor(struct work_struct *);
 int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr);
 void bond_alb_clear_vlan(struct bonding *bond, unsigned short vlan_id);
 #endif /* __BOND_ALB_H__ */
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 724bce5..7c003fc 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1,4 +1,4 @@
-/*
+ /*
  * originally based on the dummy device.
  *
  * Copyright 1999, Thomas Davis, tadavis@lbl.gov.
@@ -1567,7 +1567,15 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 			/* first slave or no active slave yet, and this link
 			 * is OK, so make this interface the active one
 			 */
+			write_unlock_bh(&bond->lock);
+			read_lock(&bond->lock);
+			write_lock_bh(&bond->curr_slave_lock);
+
 			bond_change_active_slave(bond, new_slave);
+
+			write_unlock_bh(&bond->curr_slave_lock);
+			read_unlock(&bond->lock);
+			write_lock_bh(&bond->lock);
 		} else {
 			bond_set_slave_inactive_flags(new_slave);
 		}
@@ -1729,9 +1737,23 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
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
 
@@ -1954,16 +1976,19 @@ static int bond_ioctl_change_active(struct net_device *bond_dev, struct net_devi
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
 
@@ -1971,12 +1996,14 @@ static int bond_ioctl_change_active(struct net_device *bond_dev, struct net_devi
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
@@ -1988,9 +2015,9 @@ static int bond_info_query(struct net_device *bond_dev, struct ifbond *info)
 	info->bond_mode = bond->params.mode;
 	info->miimon = bond->params.miimon;
 
-	read_lock_bh(&bond->lock);
+	read_lock(&bond->lock);
 	info->num_slaves = bond->slave_cnt;
-	read_unlock_bh(&bond->lock);
+	read_unlock(&bond->lock);
 
 	return 0;
 }
@@ -2005,7 +2032,7 @@ static int bond_slave_info_query(struct net_device *bond_dev, struct ifslave *in
 		return -ENODEV;
 	}
 
-	read_lock_bh(&bond->lock);
+	read_lock(&bond->lock);
 
 	bond_for_each_slave(bond, slave, i) {
 		if (i == (int)info->slave_id) {
@@ -2014,7 +2041,7 @@ static int bond_slave_info_query(struct net_device *bond_dev, struct ifslave *in
 		}
 	}
 
-	read_unlock_bh(&bond->lock);
+	read_unlock(&bond->lock);
 
 	if (found) {
 		strcpy(info->slave_name, slave->dev->name);
@@ -2028,28 +2055,52 @@ static int bond_slave_info_query(struct net_device *bond_dev, struct ifslave *in
 	return 0;
 }
 
+
+/*-------------------------------- Workqueues -------------------------------*/
+
+void bond_work_cancel_all(struct bonding *bond)
+{
+	write_lock_bh(&bond->lock);
+	bond->kill_timers = 1;
+	write_unlock_bh(&bond->lock);
+
+	if (bond->params.miimon && delayed_work_pending(&bond->mii_work))
+		cancel_delayed_work(&bond->mii_work);
+
+	if (bond->params.arp_interval && delayed_work_pending(&bond->arp_work))
+		cancel_delayed_work(&bond->arp_work);
+
+	if (bond->params.mode == BOND_MODE_ALB &&
+	    delayed_work_pending(&bond->alb_work))
+		cancel_delayed_work(&bond->alb_work);
+
+	if (bond->params.mode == BOND_MODE_8023AD &&
+	    delayed_work_pending(&bond->ad_work))
+		cancel_delayed_work(&bond->ad_work);
+}
+
 /*-------------------------------- Monitoring -------------------------------*/
 
-/* this function is called regularly to monitor each slave's link. */
-void bond_mii_monitor(struct net_device *bond_dev)
+/*
+ * if !have_locks, return nonzero if a failover is necessary.
+ * if have_locks, do whatever failover activities are needed.
+ *
+ * This is to separate the inspection and failover steps for locking
+ * purposes; failover requires rtnl, but acquiring it for every
+ * inspection is undesirable, so an initial call does inspection, and
+ * the wrapper acquires the necessary locks and calls again to perform
+ * failover if needed.  Since all locks are dropped, a complete
+ * restart is needed between calls.
+ */
+static int __bond_mii_monitor(struct bonding *bond, int have_locks)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct net_device *bond_dev = bond->dev;
 	struct slave *slave, *oldcurrent;
 	int do_failover = 0;
-	int delta_in_ticks;
 	int i;
 
-	read_lock(&bond->lock);
-
-	delta_in_ticks = (bond->params.miimon * HZ) / 1000;
-
-	if (bond->kill_timers) {
+	if (bond->slave_cnt == 0)
 		goto out;
-	}
-
-	if (bond->slave_cnt == 0) {
-		goto re_arm;
-	}
 
 	/* we will try to read the link status of each of our slaves, and
 	 * set their IFF_RUNNING flag appropriately. For each slave not
@@ -2105,6 +2156,9 @@ void bond_mii_monitor(struct net_device *bond_dev)
 			if (link_state != BMSR_LSTATUS) {
 				/* link stays down */
 				if (slave->delay <= 0) {
+					if (!have_locks)
+						return 1;
+
 					/* link down for too long time */
 					slave->link = BOND_LINK_DOWN;
 
@@ -2188,6 +2242,9 @@ void bond_mii_monitor(struct net_device *bond_dev)
 			} else {
 				/* link stays up */
 				if (slave->delay == 0) {
+					if (!have_locks)
+						return 1;
+
 					/* now the link has been up for long time enough */
 					slave->link = BOND_LINK_UP;
 					slave->jiffies = jiffies;
@@ -2253,22 +2310,39 @@ void bond_mii_monitor(struct net_device *bond_dev)
 	} /* end of for */
 
 	if (do_failover) {
-		write_lock(&bond->curr_slave_lock);
-
+		write_lock_bh(&bond->curr_slave_lock);
 		bond_select_active_slave(bond);
-
-		write_unlock(&bond->curr_slave_lock);
+		write_unlock_bh(&bond->curr_slave_lock);
 	} else
 		bond_set_carrier(bond);
 
-re_arm:
-	if (bond->params.miimon) {
-		mod_timer(&bond->mii_timer, jiffies + delta_in_ticks);
-	}
 out:
-	read_unlock(&bond->lock);
+	return 0;
 }
 
+void bond_mii_monitor(struct work_struct *work)
+{
+	struct bonding *bond = container_of(work, struct bonding,
+					    mii_work.work);
+	unsigned long delay;
+
+	read_lock(&bond->lock);
+	if (bond->kill_timers) {
+		read_unlock(&bond->lock);
+		return;
+	}
+	if (__bond_mii_monitor(bond, 0)) {
+		read_unlock(&bond->lock);
+		rtnl_lock();
+		read_lock(&bond->lock);
+		__bond_mii_monitor(bond, 1);
+		rtnl_unlock();
+	}
+
+	delay = ((bond->params.miimon * HZ) / 1000) ? : 1;
+	read_unlock(&bond->lock);
+	queue_delayed_work(bond->wq, &bond->mii_work, delay);
+}
 
 static u32 bond_glean_dev_ip(struct net_device *dev)
 {
@@ -2564,9 +2638,11 @@ out:
  * arp is transmitted to generate traffic. see activebackup_arp_monitor for
  * arp monitoring in active backup mode.
  */
-void bond_loadbalance_arp_mon(struct net_device *bond_dev)
+void bond_loadbalance_arp_mon(struct work_struct *work)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = container_of(work, struct bonding,
+					    arp_work.work);
+	struct net_device *bond_dev = bond->dev;
 	struct slave *slave, *oldcurrent;
 	int do_failover = 0;
 	int delta_in_ticks;
@@ -2665,17 +2741,16 @@ void bond_loadbalance_arp_mon(struct net_device *bond_dev)
 	}
 
 	if (do_failover) {
-		write_lock(&bond->curr_slave_lock);
+		write_lock_bh(&bond->curr_slave_lock);
 
 		bond_select_active_slave(bond);
 
-		write_unlock(&bond->curr_slave_lock);
+		write_unlock_bh(&bond->curr_slave_lock);
 	}
 
 re_arm:
-	if (bond->params.arp_interval) {
-		mod_timer(&bond->arp_timer, jiffies + delta_in_ticks);
-	}
+	if (bond->params.arp_interval)
+		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
 out:
 	read_unlock(&bond->lock);
 }
@@ -2695,9 +2770,11 @@ out:
  * may have received.
  * see loadbalance_arp_monitor for arp monitoring in load balancing mode
  */
-void bond_activebackup_arp_mon(struct net_device *bond_dev)
+void bond_activebackup_arp_mon(struct work_struct *work)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = container_of(work, struct bonding,
+					    arp_work.work);
+	struct net_device *bond_dev = bond->dev;
 	struct slave *slave;
 	int delta_in_ticks;
 	int i;
@@ -2726,7 +2803,7 @@ void bond_activebackup_arp_mon(struct net_device *bond_dev)
 
 				slave->link = BOND_LINK_UP;
 
-				write_lock(&bond->curr_slave_lock);
+				write_lock_bh(&bond->curr_slave_lock);
 
 				if ((!bond->curr_active_slave) &&
 				    ((jiffies - slave->dev->trans_start) <= delta_in_ticks)) {
@@ -2760,7 +2837,7 @@ void bond_activebackup_arp_mon(struct net_device *bond_dev)
 					       slave->dev->name);
 				}
 
-				write_unlock(&bond->curr_slave_lock);
+				write_unlock_bh(&bond->curr_slave_lock);
 			}
 		} else {
 			read_lock(&bond->curr_slave_lock);
@@ -2830,12 +2907,12 @@ void bond_activebackup_arp_mon(struct net_device *bond_dev)
 			       bond_dev->name,
 			       slave->dev->name);
 
-			write_lock(&bond->curr_slave_lock);
+			write_lock_bh(&bond->curr_slave_lock);
 
 			bond_select_active_slave(bond);
 			slave = bond->curr_active_slave;
 
-			write_unlock(&bond->curr_slave_lock);
+			write_unlock_bh(&bond->curr_slave_lock);
 
 			bond->current_arp_slave = slave;
 
@@ -2854,9 +2931,9 @@ void bond_activebackup_arp_mon(struct net_device *bond_dev)
 			       bond->primary_slave->dev->name);
 
 			/* primary is up so switch to it */
-			write_lock(&bond->curr_slave_lock);
+			write_lock_bh(&bond->curr_slave_lock);
 			bond_change_active_slave(bond, bond->primary_slave);
-			write_unlock(&bond->curr_slave_lock);
+			write_unlock_bh(&bond->curr_slave_lock);
 
 			slave = bond->primary_slave;
 			slave->jiffies = jiffies;
@@ -2921,9 +2998,8 @@ void bond_activebackup_arp_mon(struct net_device *bond_dev)
 	}
 
 re_arm:
-	if (bond->params.arp_interval) {
-		mod_timer(&bond->arp_timer, jiffies + delta_in_ticks);
-	}
+	if (bond->params.arp_interval)
+		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
 out:
 	read_unlock(&bond->lock);
 }
@@ -2943,7 +3019,7 @@ static void *bond_info_seq_start(struct seq_file *seq, loff_t *pos)
 
 	/* make sure the bond won't be taken away */
 	read_lock(&dev_base_lock);
-	read_lock_bh(&bond->lock);
+	read_lock(&bond->lock);
 
 	if (*pos == 0) {
 		return SEQ_START_TOKEN;
@@ -2977,7 +3053,7 @@ static void bond_info_seq_stop(struct seq_file *seq, void *v)
 {
 	struct bonding *bond = seq->private;
 
-	read_unlock_bh(&bond->lock);
+	read_unlock(&bond->lock);
 	read_unlock(&dev_base_lock);
 }
 
@@ -3503,14 +3579,11 @@ static int bond_xmit_hash_policy_l2(struct sk_buff *skb,
 static int bond_open(struct net_device *bond_dev)
 {
 	struct bonding *bond = bond_dev->priv;
-	struct timer_list *mii_timer = &bond->mii_timer;
-	struct timer_list *arp_timer = &bond->arp_timer;
 
 	bond->kill_timers = 0;
 
 	if ((bond->params.mode == BOND_MODE_TLB) ||
 	    (bond->params.mode == BOND_MODE_ALB)) {
-		struct timer_list *alb_timer = &(BOND_ALB_INFO(bond).alb_timer);
 
 		/* bond_alb_initialize must be called before the timer
 		 * is started.
@@ -3520,44 +3593,33 @@ static int bond_open(struct net_device *bond_dev)
 			return -1;
 		}
 
-		init_timer(alb_timer);
-		alb_timer->expires  = jiffies + 1;
-		alb_timer->data     = (unsigned long)bond;
-		alb_timer->function = (void *)&bond_alb_monitor;
-		add_timer(alb_timer);
+		INIT_DELAYED_WORK(&bond->alb_work, bond_alb_monitor);
+		queue_delayed_work(bond->wq, &bond->alb_work, 0);
 	}
 
 	if (bond->params.miimon) {  /* link check interval, in milliseconds. */
-		init_timer(mii_timer);
-		mii_timer->expires  = jiffies + 1;
-		mii_timer->data     = (unsigned long)bond_dev;
-		mii_timer->function = (void *)&bond_mii_monitor;
-		add_timer(mii_timer);
+		INIT_DELAYED_WORK(&bond->mii_work, bond_mii_monitor);
+		queue_delayed_work(bond->wq, &bond->mii_work, 0);
 	}
 
 	if (bond->params.arp_interval) {  /* arp interval, in milliseconds. */
-		init_timer(arp_timer);
-		arp_timer->expires  = jiffies + 1;
-		arp_timer->data     = (unsigned long)bond_dev;
-		if (bond->params.mode == BOND_MODE_ACTIVEBACKUP) {
-			arp_timer->function = (void *)&bond_activebackup_arp_mon;
-		} else {
-			arp_timer->function = (void *)&bond_loadbalance_arp_mon;
-		}
+
+		if (bond->params.mode == BOND_MODE_ACTIVEBACKUP)
+			INIT_DELAYED_WORK(&bond->arp_work,
+					  bond_activebackup_arp_mon);
+		else
+			INIT_DELAYED_WORK(&bond->arp_work,
+					  bond_loadbalance_arp_mon);
+
+		queue_delayed_work(bond->wq, &bond->arp_work, 0);
 		if (bond->params.arp_validate)
 			bond_register_arp(bond);
-
-		add_timer(arp_timer);
 	}
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
-		struct timer_list *ad_timer = &(BOND_AD_INFO(bond).ad_timer);
-		init_timer(ad_timer);
-		ad_timer->expires  = jiffies + 1;
-		ad_timer->data     = (unsigned long)bond;
-		ad_timer->function = (void *)&bond_3ad_state_machine_handler;
-		add_timer(ad_timer);
-
+		INIT_DELAYED_WORK(&bond->ad_work,
+				  bond_3ad_state_machine_handler);
+		queue_delayed_work(bond->wq, &bond->ad_work, 0);
 		/* register to receive LACPDUs */
 		bond_register_lacpdu(bond);
 	}
@@ -3579,36 +3641,36 @@ static int bond_close(struct net_device *bond_dev)
 
 	write_lock_bh(&bond->lock);
 
-
 	/* signal timers not to re-arm */
 	bond->kill_timers = 1;
 
 	write_unlock_bh(&bond->lock);
 
-	/* del_timer_sync must run without holding the bond->lock
-	 * because a running timer might be trying to hold it too
+	/*
+	 * Release the lock here since cancel_delayed_work will take
+	 * it again and releasing it will give scheduled work a chance
+	 * to run.
 	 */
 
-	if (bond->params.miimon) {  /* link check interval, in milliseconds. */
-		del_timer_sync(&bond->mii_timer);
-	}
+	if (bond->params.miimon && delayed_work_pending(&bond->mii_work))
+		cancel_delayed_work(&bond->mii_work);
 
-	if (bond->params.arp_interval) {  /* arp interval, in milliseconds. */
-		del_timer_sync(&bond->arp_timer);
-	}
+	if (bond->params.arp_interval && delayed_work_pending(&bond->arp_work))
+		cancel_delayed_work(&bond->arp_work);
 
 	switch (bond->params.mode) {
 	case BOND_MODE_8023AD:
-		del_timer_sync(&(BOND_AD_INFO(bond).ad_timer));
+		if (delayed_work_pending(&bond->ad_work))
+			cancel_delayed_work(&bond->ad_work);
 		break;
 	case BOND_MODE_TLB:
 	case BOND_MODE_ALB:
-		del_timer_sync(&(BOND_ALB_INFO(bond).alb_timer));
+		if (delayed_work_pending(&bond->alb_work))
+			cancel_delayed_work(&bond->alb_work);
 		break;
 	default:
 		break;
-	}
-
+        }
 
 	if ((bond->params.mode == BOND_MODE_TLB) ||
 	    (bond->params.mode == BOND_MODE_ALB)) {
@@ -3630,7 +3692,7 @@ static struct net_device_stats *bond_get_stats(struct net_device *bond_dev)
 
 	memset(stats, 0, sizeof(struct net_device_stats));
 
-	read_lock_bh(&bond->lock);
+	read_lock(&bond->lock);
 
 	bond_for_each_slave(bond, slave, i) {
 		sstats = slave->dev->get_stats(slave->dev);
@@ -3661,7 +3723,7 @@ static struct net_device_stats *bond_get_stats(struct net_device *bond_dev)
 		stats->tx_window_errors += sstats->tx_window_errors;
 	}
 
-	read_unlock_bh(&bond->lock);
+	read_unlock(&bond->lock);
 
 	return stats;
 }
@@ -3700,13 +3762,13 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 		if (mii->reg_num == 1) {
 			struct bonding *bond = bond_dev->priv;
 			mii->val_out = 0;
-			read_lock_bh(&bond->lock);
+			read_lock(&bond->lock);
 			read_lock(&bond->curr_slave_lock);
 			if (netif_carrier_ok(bond->dev)) {
 				mii->val_out = BMSR_LSTATUS;
 			}
 			read_unlock(&bond->curr_slave_lock);
-			read_unlock_bh(&bond->lock);
+			read_unlock(&bond->lock);
 		}
 
 		return 0;
@@ -3991,7 +4053,7 @@ static int bond_xmit_roundrobin(struct sk_buff *skb, struct net_device *bond_dev
 {
 	struct bonding *bond = bond_dev->priv;
 	struct slave *slave, *start_at;
-	int i;
+	int i, slave_no;
 	int res = 1;
 
 	read_lock(&bond->lock);
@@ -4000,29 +4062,30 @@ static int bond_xmit_roundrobin(struct sk_buff *skb, struct net_device *bond_dev
 		goto out;
 	}
 
-	read_lock(&bond->curr_slave_lock);
-	slave = start_at = bond->curr_active_slave;
-	read_unlock(&bond->curr_slave_lock);
+	/*
+	 * Concurrent TX may collide on rr_tx_counter; we accept that
+	 * as being rare enough to not justify using an atomic op here
+	 */
+	slave_no = bond->rr_tx_counter++ % bond->slave_cnt;
 
-	if (!slave) {
-		goto out;
+	bond_for_each_slave(bond, slave, i) {
+		slave_no--;
+		if (slave_no < 0) {
+			break;
+		}
 	}
 
+	start_at = slave;
+
 	bond_for_each_slave_from(bond, slave, i, start_at) {
 		if (IS_UP(slave->dev) &&
 		    (slave->link == BOND_LINK_UP) &&
 		    (slave->state == BOND_STATE_ACTIVE)) {
 			res = bond_dev_queue_xmit(bond, skb, slave->dev);
-
-			write_lock(&bond->curr_slave_lock);
-			bond->curr_active_slave = slave->next;
-			write_unlock(&bond->curr_slave_lock);
-
 			break;
 		}
 	}
 
-
 out:
 	if (res) {
 		/* no suitable interface, frame not sent */
@@ -4258,6 +4321,12 @@ static int bond_init(struct net_device *bond_dev, struct bond_params *params)
 
 	bond->params = *params; /* copy params struct */
 
+	/* initialize individual workqueue */
+        bond->wq = create_singlethread_workqueue(bond_dev->name);
+
+        if (!bond->wq)
+		return -ENOMEM;
+
 	/* Initialize pointers */
 	bond->first_slave = NULL;
 	bond->curr_active_slave = NULL;
@@ -4743,6 +4812,7 @@ static int __init bonding_init(void)
 {
 	int i;
 	int res;
+	struct bonding *bond, *nxt;
 
 	printk(KERN_INFO "%s", version);
 
@@ -4769,10 +4839,16 @@ static int __init bonding_init(void)
 
 	goto out;
 err:
+	list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list) {
+		bond_work_cancel_all(bond);
+		destroy_workqueue(bond->wq);
+	}
+
 	rtnl_lock();
 	bond_free_all();
 	bond_destroy_sysfs();
 	rtnl_unlock();
+
 out:
 	return res;
 
@@ -4780,9 +4856,18 @@ out:
 
 static void __exit bonding_exit(void)
 {
+	struct bonding *bond, *nxt;
+
 	unregister_netdevice_notifier(&bond_netdev_notifier);
 	unregister_inetaddr_notifier(&bond_inetaddr_notifier);
 
+	list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list) {
+		if (bond && bond->dev) {
+			bond_work_cancel_all(bond);
+			destroy_workqueue(bond->wq);
+		}
+	}
+
 	rtnl_lock();
 	bond_free_all();
 	bond_destroy_sysfs();
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index a122baa..ee17fd4 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -231,7 +231,7 @@ static ssize_t bonding_show_slaves(struct device *d,
 	int i, res = 0;
 	struct bonding *bond = to_bond(d);
 
-	read_lock_bh(&bond->lock);
+	read_lock(&bond->lock);
 	bond_for_each_slave(bond, slave, i) {
 		if (res > (PAGE_SIZE - IFNAMSIZ)) {
 			/* not enough space for another interface name */
@@ -242,7 +242,7 @@ static ssize_t bonding_show_slaves(struct device *d,
 		}
 		res += sprintf(buf + res, "%s ", slave->dev->name);
 	}
-	read_unlock_bh(&bond->lock);
+	read_unlock(&bond->lock);
 	res += sprintf(buf + res, "\n");
 	res++;
 	return res;
@@ -285,18 +285,18 @@ static ssize_t bonding_store_slaves(struct device *d,
 
 		/* Got a slave name in ifname.  Is it already in the list? */
 		found = 0;
-		read_lock_bh(&bond->lock);
+		read_lock(&bond->lock);
 		bond_for_each_slave(bond, slave, i)
 			if (strnicmp(slave->dev->name, ifname, IFNAMSIZ) == 0) {
 				printk(KERN_ERR DRV_NAME
 				       ": %s: Interface %s is already enslaved!\n",
 				       bond->dev->name, ifname);
 				ret = -EPERM;
-				read_unlock_bh(&bond->lock);
+				read_unlock(&bond->lock);
 				goto out;
 			}
 
-		read_unlock_bh(&bond->lock);
+		read_unlock(&bond->lock);
 		printk(KERN_INFO DRV_NAME ": %s: Adding slave %s.\n",
 		       bond->dev->name, ifname);
 		dev = dev_get_by_name(ifname);
@@ -610,11 +610,9 @@ static ssize_t bonding_store_arp_interval(struct device *d,
 		       bond->dev->name, bond->dev->name);
 		bond->params.miimon = 0;
 		/* Kill MII timer, else it brings bond's link down */
-		if (bond->arp_timer.function) {
-			printk(KERN_INFO DRV_NAME
-			": %s: Kill MII timer, else it brings bond's link down...\n",
-		       bond->dev->name);
-			del_timer_sync(&bond->mii_timer);
+		if (delayed_work_pending(&bond->mii_work)) {
+			cancel_delayed_work(&bond->mii_work);
+			flush_workqueue(bond->wq);
 		}
 	}
 	if (!bond->params.arp_targets[0]) {
@@ -629,25 +627,15 @@ static ssize_t bonding_store_arp_interval(struct device *d,
 		 * timer will get fired off when the open function
 		 * is called.
 		 */
-		if (bond->arp_timer.function) {
-			/* The timer's already set up, so fire it off */
-			mod_timer(&bond->arp_timer, jiffies + 1);
-		} else {
-			/* Set up the timer. */
-			init_timer(&bond->arp_timer);
-			bond->arp_timer.expires = jiffies + 1;
-			bond->arp_timer.data =
-				(unsigned long) bond->dev;
-			if (bond->params.mode == BOND_MODE_ACTIVEBACKUP) {
-				bond->arp_timer.function =
-					(void *)
-					&bond_activebackup_arp_mon;
-			} else {
-				bond->arp_timer.function =
-					(void *)
-					&bond_loadbalance_arp_mon;
-			}
-			add_timer(&bond->arp_timer);
+		if (!delayed_work_pending(&bond->arp_work)) {
+			if (bond->params.mode == BOND_MODE_ACTIVEBACKUP)
+				INIT_DELAYED_WORK(&bond->arp_work,
+						  bond_activebackup_arp_mon);
+			else
+				INIT_DELAYED_WORK(&bond->arp_work,
+						  bond_loadbalance_arp_mon);
+
+			queue_delayed_work(bond->wq, &bond->arp_work, 0);
 		}
 	}
 
@@ -1004,11 +992,12 @@ static ssize_t bonding_store_miimon(struct device *d,
 					BOND_ARP_VALIDATE_NONE;
 			}
 			/* Kill ARP timer, else it brings bond's link down */
-			if (bond->mii_timer.function) {
+			if (delayed_work_pending(&bond->arp_work)) {
 				printk(KERN_INFO DRV_NAME
 				": %s: Kill ARP timer, else it brings bond's link down...\n",
 			       bond->dev->name);
-				del_timer_sync(&bond->arp_timer);
+				cancel_delayed_work(&bond->arp_work);
+				flush_workqueue(bond->wq);
 			}
 		}
 
@@ -1018,18 +1007,11 @@ static ssize_t bonding_store_miimon(struct device *d,
 			 * timer will get fired off when the open function
 			 * is called.
 			 */
-			if (bond->mii_timer.function) {
-				/* The timer's already set up, so fire it off */
-				mod_timer(&bond->mii_timer, jiffies + 1);
-			} else {
-				/* Set up the timer. */
-				init_timer(&bond->mii_timer);
-				bond->mii_timer.expires = jiffies + 1;
-				bond->mii_timer.data =
-					(unsigned long) bond->dev;
-				bond->mii_timer.function =
-					(void *) &bond_mii_monitor;
-				add_timer(&bond->mii_timer);
+			if (!delayed_work_pending(&bond->mii_work)) {
+				INIT_DELAYED_WORK(&bond->mii_work,
+						  bond_mii_monitor);
+				queue_delayed_work(bond->wq,
+						   &bond->mii_work, 0);
 			}
 		}
 	}
@@ -1068,6 +1050,7 @@ static ssize_t bonding_store_primary(struct device *d,
 	struct slave *slave;
 	struct bonding *bond = to_bond(d);
 
+	rtnl_lock();
 	write_lock_bh(&bond->lock);
 	if (!USES_PRIMARY(bond->params.mode)) {
 		printk(KERN_INFO DRV_NAME
@@ -1103,6 +1086,8 @@ static ssize_t bonding_store_primary(struct device *d,
 	}
 out:
 	write_unlock_bh(&bond->lock);
+	rtnl_unlock();
+
 	return count;
 }
 static DEVICE_ATTR(primary, S_IRUGO | S_IWUSR, bonding_show_primary, bonding_store_primary);
@@ -1182,6 +1167,7 @@ static ssize_t bonding_store_active_slave(struct device *d,
         struct slave *new_active = NULL;
 	struct bonding *bond = to_bond(d);
 
+	rtnl_lock();
 	write_lock_bh(&bond->lock);
 	if (!USES_PRIMARY(bond->params.mode)) {
 		printk(KERN_INFO DRV_NAME
@@ -1239,6 +1225,8 @@ static ssize_t bonding_store_active_slave(struct device *d,
 	}
 out:
 	write_unlock_bh(&bond->lock);
+	rtnl_unlock();
+
 	return count;
 
 }
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 41aa78b..d8a23b0 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -182,9 +182,8 @@ struct bonding {
 	s32      slave_cnt; /* never change this value outside the attach/detach wrappers */
 	rwlock_t lock;
 	rwlock_t curr_slave_lock;
-	struct   timer_list mii_timer;
-	struct   timer_list arp_timer;
 	s8       kill_timers;
+	u16	 rr_tx_counter;
 	struct   net_device_stats stats;
 #ifdef CONFIG_PROC_FS
 	struct   proc_dir_entry *proc_entry;
@@ -201,6 +200,11 @@ struct bonding {
 	struct   list_head vlan_list;
 	struct   vlan_group *vlgrp;
 	struct   packet_type arp_mon_pt;
+	struct   workqueue_struct *wq;
+	struct   delayed_work mii_work;
+	struct   delayed_work arp_work;
+	struct   delayed_work alb_work;
+	struct   delayed_work ad_work;
 };
 
 /**
@@ -302,9 +306,9 @@ void bond_destroy_slave_symlinks(struct net_device *master, struct net_device *s
 int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_release(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_sethwaddr(struct net_device *bond_dev, struct net_device *slave_dev);
-void bond_mii_monitor(struct net_device *bond_dev);
-void bond_loadbalance_arp_mon(struct net_device *bond_dev);
-void bond_activebackup_arp_mon(struct net_device *bond_dev);
+void bond_mii_monitor(struct work_struct *);
+void bond_loadbalance_arp_mon(struct work_struct *);
+void bond_activebackup_arp_mon(struct work_struct *);
 void bond_set_mode_ops(struct bonding *bond, int mode);
 int bond_parse_parm(char *mode_arg, struct bond_parm_tbl *tbl);
 const char *bond_mode_name(int mode);
@@ -312,6 +316,8 @@ void bond_select_active_slave(struct bonding *bond);
 void bond_change_active_slave(struct bonding *bond, struct slave *new_active);
 void bond_register_arp(struct bonding *);
 void bond_unregister_arp(struct bonding *);
+void bond_wq_destroy(struct net_device *bond_dev);
+
 
 #endif /* _LINUX_BONDING_H */
 
