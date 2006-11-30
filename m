From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH] bonding: change spinlocks and remove timers in favor of workqueues
Date: Thu, 30 Nov 2006 11:23:23 -0500
Message-ID: <20061130162322.GA8772@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37815 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1758520AbWK3QYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Nov 2006 11:24:25 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The main purpose of this patch is to clean-up the bonding code so that
several important operations are not done in the incorrect (softirq)
context. Whenever a kernel is compiled with CONFIG_DEBUG_SPINLOCK_SLEEP
all sorts of backtraces are spewed to the log since might_sleep will
kindly remind us we are doing something in a atomic context when we
probably should not. 

In order to resolve this, the spin_[un]lock_bh needed to be converted to
spin_[un]lock and to do that the timers needed to be dropped in favor of
workqueues.  Since there isn't the chance that this work will be done in
a softirq context, the bh-locks aren't needed since we should not be
preempted to service the workqueue.  Both of those changes are included
in this patch.

I've done a bit of testing switching between modes and changing some of
the important values through sysfs, so I feel that creating and
canceling the work is working fine.  This code could use some quick
testing with 802.3ad since I didn't have access to a switch with that
capability, so if someone can verify it I would appreciate it.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---

 bond_3ad.c   |    9 +-
 bond_3ad.h   |    2 
 bond_alb.c   |   17 +++-
 bond_alb.h   |    2 
 bond_main.c  |  215 ++++++++++++++++++++++++++++++++++++++---------------------
 bond_sysfs.c |   78 ++++++++++-----------
 bonding.h    |   21 +++--
 7 files changed, 212 insertions(+), 132 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 3fb354d..e65ca19 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2097,8 +2097,10 @@ void bond_3ad_unbind_slave(struct slave 
  * times out, and it selects an aggregator for the ports that are yet not
  * related to any aggregator, and selects the active aggregator for a bond.
  */
-void bond_3ad_state_machine_handler(struct bonding *bond)
+void bond_3ad_state_machine_handler(void *work_data)
 {
+	struct net_device *bond_dev = (struct net_device *)work_data;
+	struct bonding *bond = bond_dev->priv;
 	struct port *port;
 	struct aggregator *aggregator;
 
@@ -2149,7 +2151,10 @@ void bond_3ad_state_machine_handler(stru
 	}
 
 re_arm:
-	mod_timer(&(BOND_AD_INFO(bond).ad_timer), jiffies + ad_delta_in_ticks);
+	bond_work_create(bond_dev,
+		bond_3ad_state_machine_handler,
+		&bond->ad_work,
+		ad_delta_in_ticks);
 out:
 	read_unlock(&bond->lock);
 }
diff --git a/drivers/net/bonding/bond_3ad.h b/drivers/net/bonding/bond_3ad.h
index 6ad5ad6..4fa16a9 100644
--- a/drivers/net/bonding/bond_3ad.h
+++ b/drivers/net/bonding/bond_3ad.h
@@ -276,7 +276,7 @@ struct ad_slave_info {
 void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution, int lacp_fast);
 int  bond_3ad_bind_slave(struct slave *slave);
 void bond_3ad_unbind_slave(struct slave *slave);
-void bond_3ad_state_machine_handler(struct bonding *bond);
+void bond_3ad_state_machine_handler(void *work_data);
 void bond_3ad_adapter_speed_changed(struct slave *slave);
 void bond_3ad_adapter_duplex_changed(struct slave *slave);
 void bond_3ad_handle_link_change(struct slave *slave, char link);
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 3292316..a163e3d 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1367,8 +1367,10 @@ out:
 	return 0;
 }
 
-void bond_alb_monitor(struct bonding *bond)
+void bond_alb_monitor(void *work_data)
 {
+	struct net_device *bond_dev = (struct net_device *)work_data;
+	struct bonding *bond = bond_dev->priv;
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
 	struct slave *slave;
 	int i;
@@ -1433,7 +1435,7 @@ void bond_alb_monitor(struct bonding *bo
 		 * write lock to protect from other code that also
 		 * sets the promiscuity.
 		 */
-		write_lock_bh(&bond->curr_slave_lock);
+		write_lock(&bond->curr_slave_lock);
 
 		if (bond_info->primary_is_promisc &&
 		    (++bond_info->rlb_promisc_timeout_counter >= RLB_PROMISC_TIMEOUT)) {
@@ -1448,7 +1450,7 @@ void bond_alb_monitor(struct bonding *bo
 			bond_info->primary_is_promisc = 0;
 		}
 
-		write_unlock_bh(&bond->curr_slave_lock);
+		write_unlock(&bond->curr_slave_lock);
 
 		if (bond_info->rlb_rebalance) {
 			bond_info->rlb_rebalance = 0;
@@ -1471,7 +1473,10 @@ void bond_alb_monitor(struct bonding *bo
 	}
 
 re_arm:
-	mod_timer(&(bond_info->alb_timer), jiffies + alb_delta_in_ticks);
+	bond_work_create(bond_dev,
+		bond_alb_monitor,
+		&bond->alb_work,
+		alb_delta_in_ticks);
 out:
 	read_unlock(&bond->lock);
 }
@@ -1492,11 +1497,11 @@ int bond_alb_init_slave(struct bonding *
 	/* caller must hold the bond lock for write since the mac addresses
 	 * are compared and may be swapped.
 	 */
-	write_lock_bh(&bond->lock);
+	write_lock(&bond->lock);
 
 	res = alb_handle_addr_collision_on_attach(bond, slave);
 
-	write_unlock_bh(&bond->lock);
+	write_unlock(&bond->lock);
 
 	if (res) {
 		return res;
diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
index 28f2a2f..7f17492 100644
--- a/drivers/net/bonding/bond_alb.h
+++ b/drivers/net/bonding/bond_alb.h
@@ -125,7 +125,7 @@ void bond_alb_deinit_slave(struct bondin
 void bond_alb_handle_link_change(struct bonding *bond, struct slave *slave, char link);
 void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave);
 int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev);
-void bond_alb_monitor(struct bonding *bond);
+void bond_alb_monitor(void *work_data);
 int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr);
 void bond_alb_clear_vlan(struct bonding *bond, unsigned short vlan_id);
 #endif /* __BOND_ALB_H__ */
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 17a4611..81ca778 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -234,11 +234,11 @@ static int bond_add_vlan(struct bonding 
 	vlan->vlan_id = vlan_id;
 	vlan->vlan_ip = 0;
 
-	write_lock_bh(&bond->lock);
+	write_lock(&bond->lock);
 
 	list_add_tail(&vlan->vlan_list, &bond->vlan_list);
 
-	write_unlock_bh(&bond->lock);
+	write_unlock(&bond->lock);
 
 	dprintk("added VLAN ID %d on bond %s\n", vlan_id, bond->dev->name);
 
@@ -259,7 +259,7 @@ static int bond_del_vlan(struct bonding 
 
 	dprintk("bond: %s, vlan id %d\n", bond->dev->name, vlan_id);
 
-	write_lock_bh(&bond->lock);
+	write_lock(&bond->lock);
 
 	list_for_each_entry_safe(vlan, next, &bond->vlan_list, vlan_list) {
 		if (vlan->vlan_id == vlan_id) {
@@ -294,7 +294,7 @@ static int bond_del_vlan(struct bonding 
 		bond->dev->name);
 
 out:
-	write_unlock_bh(&bond->lock);
+	write_unlock(&bond->lock);
 	return res;
 }
 
@@ -507,7 +507,7 @@ static void bond_add_vlans_on_slave(stru
 {
 	struct vlan_entry *vlan;
 
-	write_lock_bh(&bond->lock);
+	write_lock(&bond->lock);
 
 	if (list_empty(&bond->vlan_list)) {
 		goto out;
@@ -528,7 +528,7 @@ static void bond_add_vlans_on_slave(stru
 	}
 
 out:
-	write_unlock_bh(&bond->lock);
+	write_unlock(&bond->lock);
 }
 
 static void bond_del_vlans_from_slave(struct bonding *bond, struct net_device *slave_dev)
@@ -536,7 +536,7 @@ static void bond_del_vlans_from_slave(st
 	struct vlan_entry *vlan;
 	struct net_device *vlan_dev;
 
-	write_lock_bh(&bond->lock);
+	write_lock(&bond->lock);
 
 	if (list_empty(&bond->vlan_list)) {
 		goto out;
@@ -563,7 +563,7 @@ unreg:
 	}
 
 out:
-	write_unlock_bh(&bond->lock);
+	write_unlock(&bond->lock);
 }
 
 /*------------------------------- Link status -------------------------------*/
@@ -1426,7 +1426,7 @@ int bond_enslave(struct net_device *bond
 
 	bond_add_vlans_on_slave(bond, slave_dev);
 
-	write_lock_bh(&bond->lock);
+	write_lock(&bond->lock);
 
 	bond_attach_slave(bond, new_slave);
 
@@ -1568,7 +1568,7 @@ int bond_enslave(struct net_device *bond
 
 	bond_set_carrier(bond);
 
-	write_unlock_bh(&bond->lock);
+	write_unlock(&bond->lock);
 
 	res = bond_create_slave_symlinks(bond_dev, slave_dev);
 	if (res)
@@ -1631,7 +1631,7 @@ int bond_release(struct net_device *bond
 		return -EINVAL;
 	}
 
-	write_lock_bh(&bond->lock);
+	write_lock(&bond->lock);
 
 	slave = bond_get_slave_by_dev(bond, slave_dev);
 	if (!slave) {
@@ -1639,7 +1639,7 @@ int bond_release(struct net_device *bond
 		printk(KERN_INFO DRV_NAME
 		       ": %s: %s not enslaved\n",
 		       bond_dev->name, slave_dev->name);
-		write_unlock_bh(&bond->lock);
+		write_unlock(&bond->lock);
 		return -EINVAL;
 	}
 
@@ -1740,7 +1740,7 @@ int bond_release(struct net_device *bond
 		bond_dev->features &= ~NETIF_F_VLAN_CHALLENGED;
 	}
 
-	write_unlock_bh(&bond->lock);
+	write_unlock(&bond->lock);
 
 	/* must do this from outside any spinlocks */
 	bond_destroy_slave_symlinks(bond_dev, slave_dev);
@@ -1795,7 +1795,7 @@ static int bond_release_all(struct net_d
 	struct net_device *slave_dev;
 	struct sockaddr addr;
 
-	write_lock_bh(&bond->lock);
+	write_lock(&bond->lock);
 
 	netif_carrier_off(bond_dev);
 
@@ -1832,7 +1832,7 @@ static int bond_release_all(struct net_d
 		 * all the undo steps that should not be called from
 		 * within a lock.
 		 */
-		write_unlock_bh(&bond->lock);
+		write_unlock(&bond->lock);
 
 		bond_destroy_slave_symlinks(bond_dev, slave_dev);
 		bond_del_vlans_from_slave(bond, slave_dev);
@@ -1872,7 +1872,7 @@ static int bond_release_all(struct net_d
 		kfree(slave);
 
 		/* re-acquire the lock before getting the next slave */
-		write_lock_bh(&bond->lock);
+		write_lock(&bond->lock);
 	}
 
 	/* zero the mac address of the master so it will be
@@ -1894,12 +1894,15 @@ static int bond_release_all(struct net_d
 		       bond_dev->name);
 	}
 
+	/* destroy the bonds workqueue */
+	bond_wq_destroy(bond_dev);
+
 	printk(KERN_INFO DRV_NAME
 	       ": %s: released all slaves\n",
 	       bond_dev->name);
 
 out:
-	write_unlock_bh(&bond->lock);
+	write_unlock(&bond->lock);
 
 	return 0;
 }
@@ -1932,7 +1935,7 @@ static int bond_ioctl_change_active(stru
 		return -EINVAL;
 	}
 
-	write_lock_bh(&bond->lock);
+	write_lock(&bond->lock);
 
 	old_active = bond->curr_active_slave;
 	new_active = bond_get_slave_by_dev(bond, slave_dev);
@@ -1941,7 +1944,7 @@ static int bond_ioctl_change_active(stru
 	 * Changing to the current active: do nothing; return success.
 	 */
 	if (new_active && (new_active == old_active)) {
-		write_unlock_bh(&bond->lock);
+		write_unlock(&bond->lock);
 		return 0;
 	}
 
@@ -1954,7 +1957,7 @@ static int bond_ioctl_change_active(stru
 		res = -EINVAL;
 	}
 
-	write_unlock_bh(&bond->lock);
+	write_unlock(&bond->lock);
 
 	return res;
 }
@@ -1966,9 +1969,9 @@ static int bond_info_query(struct net_de
 	info->bond_mode = bond->params.mode;
 	info->miimon = bond->params.miimon;
 
-	read_lock_bh(&bond->lock);
+	read_lock(&bond->lock);
 	info->num_slaves = bond->slave_cnt;
-	read_unlock_bh(&bond->lock);
+	read_unlock(&bond->lock);
 
 	return 0;
 }
@@ -1983,7 +1986,7 @@ static int bond_slave_info_query(struct 
 		return -ENODEV;
 	}
 
-	read_lock_bh(&bond->lock);
+	read_lock(&bond->lock);
 
 	bond_for_each_slave(bond, slave, i) {
 		if (i == (int)info->slave_id) {
@@ -1992,7 +1995,7 @@ static int bond_slave_info_query(struct 
 		}
 	}
 
-	read_unlock_bh(&bond->lock);
+	read_unlock(&bond->lock);
 
 	if (found) {
 		strcpy(info->slave_name, slave->dev->name);
@@ -2006,11 +2009,56 @@ static int bond_slave_info_query(struct 
 	return 0;
 }
 
+
+/*-------------------------------- Workqueues -------------------------------*/
+
+/* add work to the bonding wq */
+void bond_work_create(struct net_device *bond_dev, void (*fn)(void *),
+			struct work_struct *work, unsigned long delay)
+{
+	struct bonding *bond = bond_dev->priv;
+	INIT_WORK(work, fn, (void *)bond_dev);
+
+	/* here we will kick off any work the bonding driver needs */
+	if (delay) {
+		queue_delayed_work(bond->wq, work, delay);
+	}
+	else {
+		queue_work(bond->wq, work);
+	}
+}
+
+void bond_wq_destroy(struct net_device *bond_dev)
+{
+	struct bonding *bond = bond_dev->priv;
+	
+	/* make sure all work is finished */
+	cancel_delayed_work(&bond->mii_work);
+	cancel_delayed_work(&bond->arp_work);
+	cancel_delayed_work(&bond->alb_work);
+	cancel_delayed_work(&bond->ad_work);
+	
+	destroy_workqueue(bond->wq);	
+}
+
+void bond_work_cancel(struct work_struct *work)
+{
+	struct bonding *bond = ((struct net_device *)work->data)->priv;
+
+	if (work->pending) {
+		write_lock(&bond->lock);
+		cancel_delayed_work(work);
+		write_unlock(&bond->lock);
+	}
+
+}
+
 /*-------------------------------- Monitoring -------------------------------*/
 
 /* this function is called regularly to monitor each slave's link. */
-void bond_mii_monitor(struct net_device *bond_dev)
+void bond_mii_monitor(void *work_data)
 {
+	struct net_device *bond_dev = (struct net_device *)work_data;
 	struct bonding *bond = bond_dev->priv;
 	struct slave *slave, *oldcurrent;
 	int do_failover = 0;
@@ -2241,7 +2289,10 @@ void bond_mii_monitor(struct net_device 
 
 re_arm:
 	if (bond->params.miimon) {
-		mod_timer(&bond->mii_timer, jiffies + delta_in_ticks);
+		bond_work_create(bond_dev,
+			bond_mii_monitor,
+			&bond->mii_work,
+			delta_in_ticks);
 	}
 out:
 	read_unlock(&bond->lock);
@@ -2542,8 +2593,9 @@ out:
  * arp is transmitted to generate traffic. see activebackup_arp_monitor for
  * arp monitoring in active backup mode.
  */
-void bond_loadbalance_arp_mon(struct net_device *bond_dev)
+void bond_loadbalance_arp_mon(void *work_data)
 {
+	struct net_device *bond_dev = (struct net_device *)work_data;
 	struct bonding *bond = bond_dev->priv;
 	struct slave *slave, *oldcurrent;
 	int do_failover = 0;
@@ -2562,6 +2614,7 @@ void bond_loadbalance_arp_mon(struct net
 		goto re_arm;
 	}
 
+
 	read_lock(&bond->curr_slave_lock);
 	oldcurrent = bond->curr_active_slave;
 	read_unlock(&bond->curr_slave_lock);
@@ -2575,6 +2628,7 @@ void bond_loadbalance_arp_mon(struct net
 	 *       so it can wait
 	 */
 	bond_for_each_slave(bond, slave, i) {
+
 		if (slave->link != BOND_LINK_UP) {
 			if (((jiffies - slave->dev->trans_start) <= delta_in_ticks) &&
 			    ((jiffies - slave->dev->last_rx) <= delta_in_ticks)) {
@@ -2652,7 +2706,10 @@ void bond_loadbalance_arp_mon(struct net
 
 re_arm:
 	if (bond->params.arp_interval) {
-		mod_timer(&bond->arp_timer, jiffies + delta_in_ticks);
+		bond_work_create(bond_dev,
+			bond_loadbalance_arp_mon,
+			&bond->arp_work,
+			delta_in_ticks);
 	}
 out:
 	read_unlock(&bond->lock);
@@ -2673,8 +2730,9 @@ out:
  * may have received.
  * see loadbalance_arp_monitor for arp monitoring in load balancing mode
  */
-void bond_activebackup_arp_mon(struct net_device *bond_dev)
+void bond_activebackup_arp_mon(void *work_data)
 {
+	struct net_device *bond_dev = (struct net_device *)work_data;
 	struct bonding *bond = bond_dev->priv;
 	struct slave *slave;
 	int delta_in_ticks;
@@ -2900,7 +2958,10 @@ void bond_activebackup_arp_mon(struct ne
 
 re_arm:
 	if (bond->params.arp_interval) {
-		mod_timer(&bond->arp_timer, jiffies + delta_in_ticks);
+		bond_work_create(bond_dev,
+			bond_activebackup_arp_mon,
+			&bond->arp_work,
+			delta_in_ticks);
 	}
 out:
 	read_unlock(&bond->lock);
@@ -2921,7 +2982,7 @@ static void *bond_info_seq_start(struct 
 
 	/* make sure the bond won't be taken away */
 	read_lock(&dev_base_lock);
-	read_lock_bh(&bond->lock);
+	read_lock(&bond->lock);
 
 	if (*pos == 0) {
 		return SEQ_START_TOKEN;
@@ -2955,7 +3016,7 @@ static void bond_info_seq_stop(struct se
 {
 	struct bonding *bond = seq->private;
 
-	read_unlock_bh(&bond->lock);
+	read_unlock(&bond->lock);
 	read_unlock(&dev_base_lock);
 }
 
@@ -3475,14 +3536,11 @@ static int bond_xmit_hash_policy_l2(stru
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
@@ -3492,43 +3550,42 @@ static int bond_open(struct net_device *
 			return -1;
 		}
 
-		init_timer(alb_timer);
-		alb_timer->expires  = jiffies + 1;
-		alb_timer->data     = (unsigned long)bond;
-		alb_timer->function = (void *)&bond_alb_monitor;
-		add_timer(alb_timer);
+		bond_work_create(bond_dev,
+			bond_alb_monitor,
+			&bond->alb_work,
+			0);
 	}
 
 	if (bond->params.miimon) {  /* link check interval, in milliseconds. */
-		init_timer(mii_timer);
-		mii_timer->expires  = jiffies + 1;
-		mii_timer->data     = (unsigned long)bond_dev;
-		mii_timer->function = (void *)&bond_mii_monitor;
-		add_timer(mii_timer);
+		bond_work_create(bond_dev,
+			bond_mii_monitor,
+			&bond->mii_work,
+			0);
 	}
 
 	if (bond->params.arp_interval) {  /* arp interval, in milliseconds. */
-		init_timer(arp_timer);
-		arp_timer->expires  = jiffies + 1;
-		arp_timer->data     = (unsigned long)bond_dev;
+		
 		if (bond->params.mode == BOND_MODE_ACTIVEBACKUP) {
-			arp_timer->function = (void *)&bond_activebackup_arp_mon;
+			bond_work_create(bond_dev,
+				bond_activebackup_arp_mon,
+				&bond->arp_work,
+				0);
 		} else {
-			arp_timer->function = (void *)&bond_loadbalance_arp_mon;
+			bond_work_create(bond_dev,
+				bond_loadbalance_arp_mon,
+				&bond->arp_work,
+				0);
 		}
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
+
+		bond_work_create(bond_dev,
+			bond_3ad_state_machine_handler,
+			&bond->ad_work,
+			0);
 
 		/* register to receive LACPDUs */
 		bond_register_lacpdu(bond);
@@ -3549,38 +3606,37 @@ static int bond_close(struct net_device 
 	if (bond->params.arp_validate)
 		bond_unregister_arp(bond);
 
-	write_lock_bh(&bond->lock);
-
+	write_lock(&bond->lock);
 
 	/* signal timers not to re-arm */
 	bond->kill_timers = 1;
 
-	write_unlock_bh(&bond->lock);
+	write_unlock(&bond->lock);
 
-	/* del_timer_sync must run without holding the bond->lock
-	 * because a running timer might be trying to hold it too
+	/* Release the lock here since bond_work_cancel will take it 
+	 * again and releasing it will give scheduled work a change
+	 * to run.
 	 */
 
 	if (bond->params.miimon) {  /* link check interval, in milliseconds. */
-		del_timer_sync(&bond->mii_timer);
+		bond_work_cancel(&bond->mii_work);
 	}
-
+	
 	if (bond->params.arp_interval) {  /* arp interval, in milliseconds. */
-		del_timer_sync(&bond->arp_timer);
+		bond_work_cancel(&bond->arp_work);
 	}
 
 	switch (bond->params.mode) {
 	case BOND_MODE_8023AD:
-		del_timer_sync(&(BOND_AD_INFO(bond).ad_timer));
+		bond_work_cancel(&bond->ad_work);
 		break;
 	case BOND_MODE_TLB:
 	case BOND_MODE_ALB:
-		del_timer_sync(&(BOND_ALB_INFO(bond).alb_timer));
+		bond_work_cancel(&bond->alb_work);
 		break;
 	default:
 		break;
-	}
-
+        }
 
 	if ((bond->params.mode == BOND_MODE_TLB) ||
 	    (bond->params.mode == BOND_MODE_ALB)) {
@@ -3602,7 +3658,7 @@ static struct net_device_stats *bond_get
 
 	memset(stats, 0, sizeof(struct net_device_stats));
 
-	read_lock_bh(&bond->lock);
+	read_lock(&bond->lock);
 
 	bond_for_each_slave(bond, slave, i) {
 		sstats = slave->dev->get_stats(slave->dev);
@@ -3634,7 +3690,7 @@ static struct net_device_stats *bond_get
 		stats->tx_window_errors += sstats->tx_window_errors;
 	}
 
-	read_unlock_bh(&bond->lock);
+	read_unlock(&bond->lock);
 
 	return stats;
 }
@@ -3673,13 +3729,13 @@ static int bond_do_ioctl(struct net_devi
 		if (mii->reg_num == 1) {
 			struct bonding *bond = bond_dev->priv;
 			mii->val_out = 0;
-			read_lock_bh(&bond->lock);
+			read_lock(&bond->lock);
 			read_lock(&bond->curr_slave_lock);
 			if (bond->curr_active_slave) {
 				mii->val_out = BMSR_LSTATUS;
 			}
 			read_unlock(&bond->curr_slave_lock);
-			read_unlock_bh(&bond->lock);
+			read_unlock(&bond->lock);
 		}
 
 		return 0;
@@ -3766,7 +3822,7 @@ static void bond_set_multicast_list(stru
 	struct bonding *bond = bond_dev->priv;
 	struct dev_mc_list *dmi;
 
-	write_lock_bh(&bond->lock);
+	write_lock(&bond->lock);
 
 	/*
 	 * Do promisc before checking multicast_mode
@@ -3808,7 +3864,7 @@ static void bond_set_multicast_list(stru
 	bond_mc_list_destroy(bond);
 	bond_mc_list_copy(bond_dev->mc_list, bond, GFP_ATOMIC);
 
-	write_unlock_bh(&bond->lock);
+	write_unlock(&bond->lock);
 }
 
 /*
@@ -4282,6 +4338,13 @@ static int bond_init(struct net_device *
 
 	bond->params = *params; /* copy params struct */
 
+	/* initialize individual workqueue */
+        bond->wq = create_singlethread_workqueue(bond_dev->name);
+
+        if (!bond->wq) { 
+		return -ENOMEM;
+	} 
+
 	/* Initialize pointers */
 	bond->first_slave = NULL;
 	bond->curr_active_slave = NULL;
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index ced9ed8..403db7e 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -232,7 +232,7 @@ static ssize_t bonding_show_slaves(struc
 	int i, res = 0;
 	struct bonding *bond = to_bond(cd);
 
-	read_lock_bh(&bond->lock);
+	read_lock(&bond->lock);
 	bond_for_each_slave(bond, slave, i) {
 		if (res > (PAGE_SIZE - IFNAMSIZ)) {
 			/* not enough space for another interface name */
@@ -243,7 +243,7 @@ static ssize_t bonding_show_slaves(struc
 		}
 		res += sprintf(buf + res, "%s ", slave->dev->name);
 	}
-	read_unlock_bh(&bond->lock);
+	read_unlock(&bond->lock);
 	res += sprintf(buf + res, "\n");
 	res++;
 	return res;
@@ -284,18 +284,18 @@ static ssize_t bonding_store_slaves(stru
 
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
@@ -594,11 +594,12 @@ static ssize_t bonding_store_arp_interva
 		       bond->dev->name, bond->dev->name);
 		bond->params.miimon = 0;
 		/* Kill MII timer, else it brings bond's link down */
-		if (bond->arp_timer.function) {
+
+		if (bond->mii_work.pending) {
 			printk(KERN_INFO DRV_NAME
 			": %s: Kill MII timer, else it brings bond's link down...\n",
 		       bond->dev->name);
-			del_timer_sync(&bond->mii_timer);
+			bond_work_cancel(&bond->mii_work);
 		}
 	}
 	if (!bond->params.arp_targets[0]) {
@@ -613,25 +614,25 @@ static ssize_t bonding_store_arp_interva
 		 * timer will get fired off when the open function
 		 * is called.
 		 */
-		if (bond->arp_timer.function) {
-			/* The timer's already set up, so fire it off */
-			mod_timer(&bond->arp_timer, jiffies + 1);
+		if (bond->arp_work.pending) {
+			bond_work_cancel(&bond->arp_work);
+			bond_work_create(bond->dev,
+				bond->arp_work.func,
+				&bond->arp_work,
+				(bond->params.arp_interval * HZ) / 1000);
+			
 		} else {
-			/* Set up the timer. */
-			init_timer(&bond->arp_timer);
-			bond->arp_timer.expires = jiffies + 1;
-			bond->arp_timer.data =
-				(unsigned long) bond->dev;
 			if (bond->params.mode == BOND_MODE_ACTIVEBACKUP) {
-				bond->arp_timer.function =
-					(void *)
-					&bond_activebackup_arp_mon;
+				bond_work_create(bond->dev,
+					bond_activebackup_arp_mon,
+					&bond->arp_work,
+					0);
 			} else {
-				bond->arp_timer.function =
-					(void *)
-					&bond_loadbalance_arp_mon;
+				bond_work_create(bond->dev,
+					bond_loadbalance_arp_mon,
+					&bond->arp_work,
+					0);
 			}
-			add_timer(&bond->arp_timer);
 		}
 	}
 
@@ -968,11 +969,11 @@ static ssize_t bonding_store_miimon(stru
 					BOND_ARP_VALIDATE_NONE;
 			}
 			/* Kill ARP timer, else it brings bond's link down */
-			if (bond->mii_timer.function) {
+			if (bond->arp_work.pending) {
 				printk(KERN_INFO DRV_NAME
 				": %s: Kill ARP timer, else it brings bond's link down...\n",
 			       bond->dev->name);
-				del_timer_sync(&bond->arp_timer);
+				bond_work_cancel(&bond->arp_work);
 			}
 		}
 
@@ -982,18 +983,17 @@ static ssize_t bonding_store_miimon(stru
 			 * timer will get fired off when the open function
 			 * is called.
 			 */
-			if (bond->mii_timer.function) {
-				/* The timer's already set up, so fire it off */
-				mod_timer(&bond->mii_timer, jiffies + 1);
+			if (bond->mii_work.pending) {
+				bond_work_cancel(&bond->mii_work);
+				bond_work_create(bond->dev,
+					bond_mii_monitor,
+					&bond->mii_work,
+					(bond->params.miimon * HZ) / 1000);
 			} else {
-				/* Set up the timer. */
-				init_timer(&bond->mii_timer);
-				bond->mii_timer.expires = jiffies + 1;
-				bond->mii_timer.data =
-					(unsigned long) bond->dev;
-				bond->mii_timer.function =
-					(void *) &bond_mii_monitor;
-				add_timer(&bond->mii_timer);
+				bond_work_create(bond->dev,
+					bond_mii_monitor,
+					&bond->mii_work,
+					0);
 			}
 		}
 	}
@@ -1028,7 +1028,7 @@ static ssize_t bonding_store_primary(str
 	struct slave *slave;
 	struct bonding *bond = to_bond(cd);
 
-	write_lock_bh(&bond->lock);
+	write_lock(&bond->lock);
 	if (!USES_PRIMARY(bond->params.mode)) {
 		printk(KERN_INFO DRV_NAME
 		       ": %s: Unable to set primary slave; %s is in mode %d\n",
@@ -1062,7 +1062,7 @@ static ssize_t bonding_store_primary(str
 		}
 	}
 out:
-	write_unlock_bh(&bond->lock);
+	write_unlock(&bond->lock);
 	return count;
 }
 static CLASS_DEVICE_ATTR(primary, S_IRUGO | S_IWUSR, bonding_show_primary, bonding_store_primary);
@@ -1134,7 +1134,7 @@ static ssize_t bonding_store_active_slav
         struct slave *new_active = NULL;
 	struct bonding *bond = to_bond(cd);
 
-	write_lock_bh(&bond->lock);
+	write_lock(&bond->lock);
 	if (!USES_PRIMARY(bond->params.mode)) {
 		printk(KERN_INFO DRV_NAME
 		       ": %s: Unable to change active slave; %s is in mode %d\n",
@@ -1190,7 +1190,7 @@ static ssize_t bonding_store_active_slav
 		}
 	}
 out:
-	write_unlock_bh(&bond->lock);
+	write_unlock(&bond->lock);
 	return count;
 
 }
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index dc434fb..11e9a07 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -22,8 +22,8 @@ #include <linux/kobject.h>
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION	"3.1.1"
-#define DRV_RELDATE	"September 26, 2006"
+#define DRV_VERSION	"3.2.0"
+#define DRV_RELDATE	"November 21, 2006"
 #define DRV_NAME	"bonding"
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
@@ -182,8 +182,6 @@ struct bonding {
 	s32      slave_cnt; /* never change this value outside the attach/detach wrappers */
 	rwlock_t lock;
 	rwlock_t curr_slave_lock;
-	struct   timer_list mii_timer;
-	struct   timer_list arp_timer;
 	s8       kill_timers;
 	struct   net_device_stats stats;
 #ifdef CONFIG_PROC_FS
@@ -201,6 +199,11 @@ #endif /* CONFIG_PROC_FS */
 	struct   list_head vlan_list;
 	struct   vlan_group *vlgrp;
 	struct   packet_type arp_mon_pt;
+	struct   workqueue_struct *wq;
+	struct   work_struct mii_work;
+	struct   work_struct arp_work;
+	struct   work_struct alb_work;
+	struct   work_struct ad_work;
 };
 
 /**
@@ -300,9 +303,9 @@ void bond_destroy_slave_symlinks(struct 
 int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_release(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_sethwaddr(struct net_device *bond_dev, struct net_device *slave_dev);
-void bond_mii_monitor(struct net_device *bond_dev);
-void bond_loadbalance_arp_mon(struct net_device *bond_dev);
-void bond_activebackup_arp_mon(struct net_device *bond_dev);
+void bond_mii_monitor(void *work_data);
+void bond_loadbalance_arp_mon(void *work_data);
+void bond_activebackup_arp_mon(void *work_data);
 void bond_set_mode_ops(struct bonding *bond, int mode);
 int bond_parse_parm(char *mode_arg, struct bond_parm_tbl *tbl);
 const char *bond_mode_name(int mode);
@@ -310,6 +313,10 @@ void bond_select_active_slave(struct bon
 void bond_change_active_slave(struct bonding *bond, struct slave *new_active);
 void bond_register_arp(struct bonding *);
 void bond_unregister_arp(struct bonding *);
+void bond_work_create(struct net_device *bond_dev, void (*fn)(void *), struct work_struct *work, unsigned long delay);
+void bond_work_cancel(struct work_struct *work);
+void bond_work_reschedule(struct bonding *bond, struct work_struct *work);
+void bond_wq_destroy(struct net_device *bond_dev);
 
 #endif /* _LINUX_BONDING_H */
 
