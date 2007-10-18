From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 1/6] Convert bonding timers to workqueues
Date: Wed, 17 Oct 2007 17:37:45 -0700
Message-ID: <1192667875793-git-send-email-fubar@us.ibm.com>
References: <1192667871139-git-send-email-fubar@us.ibm.com>
Cc: andy@greyhouse.net, Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:38715 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761862AbXJRAh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 20:37:59 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9I0bu8F024937
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 20:37:56 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9I0bu87464468
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 18:37:56 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9I0btXN021277
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 18:37:56 -0600
In-Reply-To: <1192667871139-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	Convert bonding timers to workqueues.  This converts the various
monitor functions to run in periodic work queues instead of timers.  This
patch introduces the framework and convers the calls, but does not resolve
various locking issues, and does not stand alone.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_3ad.c   |    6 +-
 drivers/net/bonding/bond_3ad.h   |    2 +-
 drivers/net/bonding/bond_alb.c   |    6 +-
 drivers/net/bonding/bond_alb.h   |    2 +-
 drivers/net/bonding/bond_main.c  |  147 ++++++++++++++++++++-----------------
 drivers/net/bonding/bond_sysfs.c |   63 +++++-----------
 drivers/net/bonding/bonding.h    |   13 ++--
 7 files changed, 117 insertions(+), 122 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 7a045a3..2471d3b 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2074,8 +2074,10 @@ void bond_3ad_unbind_slave(struct slave *slave)
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
 
@@ -2126,7 +2128,7 @@ void bond_3ad_state_machine_handler(struct bonding *bond)
 	}
 
 re_arm:
-	mod_timer(&(BOND_AD_INFO(bond).ad_timer), jiffies + ad_delta_in_ticks);
+	queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
 out:
 	read_unlock(&bond->lock);
 }
diff --git a/drivers/net/bonding/bond_3ad.h b/drivers/net/bonding/bond_3ad.h
index 862952f..dde02b0 100644
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
index aea2217..eb320c3 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1375,8 +1375,10 @@ out:
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
@@ -1479,7 +1481,7 @@ void bond_alb_monitor(struct bonding *bond)
 	}
 
 re_arm:
-	mod_timer(&(bond_info->alb_timer), jiffies + alb_delta_in_ticks);
+	queue_delayed_work(bond->wq, &bond->alb_work, alb_delta_in_ticks);
 out:
 	read_unlock(&bond->lock);
 }
diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
index fd87264..50968f8 100644
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
index 6f85cc3..ed361d6 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2089,9 +2089,10 @@ static int bond_slave_info_query(struct net_device *bond_dev, struct ifslave *in
 /*-------------------------------- Monitoring -------------------------------*/
 
 /* this function is called regularly to monitor each slave's link. */
-void bond_mii_monitor(struct net_device *bond_dev)
+void bond_mii_monitor(struct work_struct *work)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = container_of(work, struct bonding,
+					    mii_work.work);
 	struct slave *slave, *oldcurrent;
 	int do_failover = 0;
 	int delta_in_ticks;
@@ -2156,7 +2157,7 @@ void bond_mii_monitor(struct net_device *bond_dev)
 					       ": %s: link status down for %s "
 					       "interface %s, disabling it in "
 					       "%d ms.\n",
-					       bond_dev->name,
+					       bond->dev->name,
 					       IS_UP(slave_dev)
 					       ? ((bond->params.mode == BOND_MODE_ACTIVEBACKUP)
 						  ? ((slave == oldcurrent)
@@ -2189,7 +2190,7 @@ void bond_mii_monitor(struct net_device *bond_dev)
 					       ": %s: link status definitely "
 					       "down for interface %s, "
 					       "disabling it\n",
-					       bond_dev->name,
+					       bond->dev->name,
 					       slave_dev->name);
 
 					/* notify ad that the link status has changed */
@@ -2215,7 +2216,7 @@ void bond_mii_monitor(struct net_device *bond_dev)
 				printk(KERN_INFO DRV_NAME
 				       ": %s: link status up again after %d "
 				       "ms for interface %s.\n",
-				       bond_dev->name,
+				       bond->dev->name,
 				       (bond->params.downdelay - slave->delay) * bond->params.miimon,
 				       slave_dev->name);
 			}
@@ -2235,7 +2236,7 @@ void bond_mii_monitor(struct net_device *bond_dev)
 					       ": %s: link status up for "
 					       "interface %s, enabling it "
 					       "in %d ms.\n",
-					       bond_dev->name,
+					       bond->dev->name,
 					       slave_dev->name,
 					       bond->params.updelay * bond->params.miimon);
 				}
@@ -2251,7 +2252,7 @@ void bond_mii_monitor(struct net_device *bond_dev)
 				printk(KERN_INFO DRV_NAME
 				       ": %s: link status down again after %d "
 				       "ms for interface %s.\n",
-				       bond_dev->name,
+				       bond->dev->name,
 				       (bond->params.updelay - slave->delay) * bond->params.miimon,
 				       slave_dev->name);
 			} else {
@@ -2275,7 +2276,7 @@ void bond_mii_monitor(struct net_device *bond_dev)
 					printk(KERN_INFO DRV_NAME
 					       ": %s: link status definitely "
 					       "up for interface %s.\n",
-					       bond_dev->name,
+					       bond->dev->name,
 					       slave_dev->name);
 
 					/* notify ad that the link status has changed */
@@ -2301,7 +2302,7 @@ void bond_mii_monitor(struct net_device *bond_dev)
 			/* Should not happen */
 			printk(KERN_ERR DRV_NAME
 			       ": %s: Error: %s Illegal value (link=%d)\n",
-			       bond_dev->name,
+			       bond->dev->name,
 			       slave->dev->name,
 			       slave->link);
 			goto out;
@@ -2331,9 +2332,8 @@ void bond_mii_monitor(struct net_device *bond_dev)
 		bond_set_carrier(bond);
 
 re_arm:
-	if (bond->params.miimon) {
-		mod_timer(&bond->mii_timer, jiffies + delta_in_ticks);
-	}
+	if (bond->params.miimon)
+		queue_delayed_work(bond->wq, &bond->mii_work, delta_in_ticks);
 out:
 	read_unlock(&bond->lock);
 }
@@ -2636,9 +2636,10 @@ out:
  * arp is transmitted to generate traffic. see activebackup_arp_monitor for
  * arp monitoring in active backup mode.
  */
-void bond_loadbalance_arp_mon(struct net_device *bond_dev)
+void bond_loadbalance_arp_mon(struct work_struct *work)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = container_of(work, struct bonding,
+					    arp_work.work);
 	struct slave *slave, *oldcurrent;
 	int do_failover = 0;
 	int delta_in_ticks;
@@ -2685,13 +2686,13 @@ void bond_loadbalance_arp_mon(struct net_device *bond_dev)
 					printk(KERN_INFO DRV_NAME
 					       ": %s: link status definitely "
 					       "up for interface %s, ",
-					       bond_dev->name,
+					       bond->dev->name,
 					       slave->dev->name);
 					do_failover = 1;
 				} else {
 					printk(KERN_INFO DRV_NAME
 					       ": %s: interface %s is now up\n",
-					       bond_dev->name,
+					       bond->dev->name,
 					       slave->dev->name);
 				}
 			}
@@ -2715,7 +2716,7 @@ void bond_loadbalance_arp_mon(struct net_device *bond_dev)
 
 				printk(KERN_INFO DRV_NAME
 				       ": %s: interface %s is now down.\n",
-				       bond_dev->name,
+				       bond->dev->name,
 				       slave->dev->name);
 
 				if (slave == oldcurrent) {
@@ -2745,9 +2746,8 @@ void bond_loadbalance_arp_mon(struct net_device *bond_dev)
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
@@ -2767,9 +2767,10 @@ out:
  * may have received.
  * see loadbalance_arp_monitor for arp monitoring in load balancing mode
  */
-void bond_activebackup_arp_mon(struct net_device *bond_dev)
+void bond_activebackup_arp_mon(struct work_struct *work)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = container_of(work, struct bonding,
+					    arp_work.work);
 	struct slave *slave;
 	int delta_in_ticks;
 	int i;
@@ -2821,14 +2822,14 @@ void bond_activebackup_arp_mon(struct net_device *bond_dev)
 					printk(KERN_INFO DRV_NAME
 					       ": %s: %s is up and now the "
 					       "active interface\n",
-					       bond_dev->name,
+					       bond->dev->name,
 					       slave->dev->name);
 					netif_carrier_on(bond->dev);
 				} else {
 					printk(KERN_INFO DRV_NAME
 					       ": %s: backup interface %s is "
 					       "now up\n",
-					       bond_dev->name,
+					       bond->dev->name,
 					       slave->dev->name);
 				}
 
@@ -2864,7 +2865,7 @@ void bond_activebackup_arp_mon(struct net_device *bond_dev)
 
 				printk(KERN_INFO DRV_NAME
 				       ": %s: backup interface %s is now down\n",
-				       bond_dev->name,
+				       bond->dev->name,
 				       slave->dev->name);
 			} else {
 				read_unlock(&bond->curr_slave_lock);
@@ -2899,7 +2900,7 @@ void bond_activebackup_arp_mon(struct net_device *bond_dev)
 			printk(KERN_INFO DRV_NAME
 			       ": %s: link status down for active interface "
 			       "%s, disabling it\n",
-			       bond_dev->name,
+			       bond->dev->name,
 			       slave->dev->name);
 
 			write_lock(&bond->curr_slave_lock);
@@ -2921,7 +2922,7 @@ void bond_activebackup_arp_mon(struct net_device *bond_dev)
 			printk(KERN_INFO DRV_NAME
 			       ": %s: changing from interface %s to primary "
 			       "interface %s\n",
-			       bond_dev->name,
+			       bond->dev->name,
 			       slave->dev->name,
 			       bond->primary_slave->dev->name);
 
@@ -2985,7 +2986,7 @@ void bond_activebackup_arp_mon(struct net_device *bond_dev)
 					printk(KERN_INFO DRV_NAME
 					       ": %s: backup interface %s is "
 					       "now down.\n",
-					       bond_dev->name,
+					       bond->dev->name,
 					       slave->dev->name);
 				}
 			}
@@ -2994,7 +2995,7 @@ void bond_activebackup_arp_mon(struct net_device *bond_dev)
 
 re_arm:
 	if (bond->params.arp_interval) {
-		mod_timer(&bond->arp_timer, jiffies + delta_in_ticks);
+		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
 	}
 out:
 	read_unlock(&bond->lock);
@@ -3582,15 +3583,11 @@ static int bond_xmit_hash_policy_l2(struct sk_buff *skb,
 static int bond_open(struct net_device *bond_dev)
 {
 	struct bonding *bond = bond_dev->priv;
-	struct timer_list *mii_timer = &bond->mii_timer;
-	struct timer_list *arp_timer = &bond->arp_timer;
 
 	bond->kill_timers = 0;
 
 	if ((bond->params.mode == BOND_MODE_TLB) ||
 	    (bond->params.mode == BOND_MODE_ALB)) {
-		struct timer_list *alb_timer = &(BOND_ALB_INFO(bond).alb_timer);
-
 		/* bond_alb_initialize must be called before the timer
 		 * is started.
 		 */
@@ -3599,44 +3596,31 @@ static int bond_open(struct net_device *bond_dev)
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
+		INIT_DELAYED_WORK(&bond->ad_work, bond_alb_monitor);
+		queue_delayed_work(bond->wq, &bond->ad_work, 0);
 		/* register to receive LACPDUs */
 		bond_register_lacpdu(bond);
 	}
@@ -3664,25 +3648,21 @@ static int bond_close(struct net_device *bond_dev)
 
 	write_unlock_bh(&bond->lock);
 
-	/* del_timer_sync must run without holding the bond->lock
-	 * because a running timer might be trying to hold it too
-	 */
-
 	if (bond->params.miimon) {  /* link check interval, in milliseconds. */
-		del_timer_sync(&bond->mii_timer);
+		cancel_delayed_work(&bond->mii_work);
 	}
 
 	if (bond->params.arp_interval) {  /* arp interval, in milliseconds. */
-		del_timer_sync(&bond->arp_timer);
+		cancel_delayed_work(&bond->arp_work);
 	}
 
 	switch (bond->params.mode) {
 	case BOND_MODE_8023AD:
-		del_timer_sync(&(BOND_AD_INFO(bond).ad_timer));
+		cancel_delayed_work(&bond->ad_work);
 		break;
 	case BOND_MODE_TLB:
 	case BOND_MODE_ALB:
-		del_timer_sync(&(BOND_ALB_INFO(bond).alb_timer));
+		cancel_delayed_work(&bond->alb_work);
 		break;
 	default:
 		break;
@@ -4340,6 +4320,10 @@ static int bond_init(struct net_device *bond_dev, struct bond_params *params)
 
 	bond->params = *params; /* copy params struct */
 
+	bond->wq = create_singlethread_workqueue(bond_dev->name);
+	if (!bond->wq)
+		return -ENOMEM;
+
 	/* Initialize pointers */
 	bond->first_slave = NULL;
 	bond->curr_active_slave = NULL;
@@ -4826,10 +4810,32 @@ out_rtnl:
 	return res;
 }
 
+static void bond_work_cancel_all(struct bonding *bond)
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
 static int __init bonding_init(void)
 {
 	int i;
 	int res;
+	struct bonding *bond, *nxt;
 
 	printk(KERN_INFO "%s", version);
 
@@ -4856,6 +4862,11 @@ static int __init bonding_init(void)
 
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
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 80c0c8c..ffa62a7 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -662,12 +662,9 @@ static ssize_t bonding_store_arp_interval(struct device *d,
 		       "%s Disabling MII monitoring.\n",
 		       bond->dev->name, bond->dev->name);
 		bond->params.miimon = 0;
-		/* Kill MII timer, else it brings bond's link down */
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
@@ -682,25 +679,15 @@ static ssize_t bonding_store_arp_interval(struct device *d,
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
 
@@ -1056,12 +1043,9 @@ static ssize_t bonding_store_miimon(struct device *d,
 				bond->params.arp_validate =
 					BOND_ARP_VALIDATE_NONE;
 			}
-			/* Kill ARP timer, else it brings bond's link down */
-			if (bond->mii_timer.function) {
-				printk(KERN_INFO DRV_NAME
-				": %s: Kill ARP timer, else it brings bond's link down...\n",
-			       bond->dev->name);
-				del_timer_sync(&bond->arp_timer);
+			if (delayed_work_pending(&bond->arp_work)) {
+				cancel_delayed_work(&bond->arp_work);
+				flush_workqueue(bond->wq);
 			}
 		}
 
@@ -1071,18 +1055,11 @@ static ssize_t bonding_store_miimon(struct device *d,
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
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index b818060..a8f2384 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -184,8 +184,6 @@ struct bonding {
 	s32      slave_cnt; /* never change this value outside the attach/detach wrappers */
 	rwlock_t lock;
 	rwlock_t curr_slave_lock;
-	struct   timer_list mii_timer;
-	struct   timer_list arp_timer;
 	s8       kill_timers;
 	s8	 send_grat_arp;
 	s8	 setup_by_slave;
@@ -205,6 +203,11 @@ struct bonding {
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
@@ -307,9 +310,9 @@ int bond_create_slave_symlinks(struct net_device *master, struct net_device *sla
 void bond_destroy_slave_symlinks(struct net_device *master, struct net_device *slave);
 int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_release(struct net_device *bond_dev, struct net_device *slave_dev);
-void bond_mii_monitor(struct net_device *bond_dev);
-void bond_loadbalance_arp_mon(struct net_device *bond_dev);
-void bond_activebackup_arp_mon(struct net_device *bond_dev);
+void bond_mii_monitor(struct work_struct *);
+void bond_loadbalance_arp_mon(struct work_struct *);
+void bond_activebackup_arp_mon(struct work_struct *);
 void bond_set_mode_ops(struct bonding *bond, int mode);
 int bond_parse_parm(char *mode_arg, struct bond_parm_tbl *tbl);
 void bond_select_active_slave(struct bonding *bond);
-- 
1.5.3.4.206.g58ba4-dirty

