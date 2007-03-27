From: akpm@linux-foundation.org
Subject: [patch 5/7] bonding: replace system timer with work queue
Date: Mon, 26 Mar 2007 21:50:01 -0800
Message-ID: <200703270550.l2R5o16M008387@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, perex@suse.cz,
	ctindel@users.sourceforge.net, fubar@us.ibm.com, oleg@tv-sign.ru,
	shemminger@linux-foundation.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40390 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934029AbXC0Fun (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 01:50:43 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jaroslav Kysela <perex@suse.cz>

Replace system timer with work queue in monitor functions.  The reason for
this change is that bonding handlers calls various sleeping functions from
the timer handler which is not allowed.  Because we cannot share the main
workqueue threads (rtnl_lock is used also in linkwatch_event) - new bond
workqueue thread is created.

[akpm@linux-foundation.org: cleanups]
Signed-off-by: Jaroslav Kysela <perex@suse.cz>
Cc: Stephen Hemminger <shemminger@osdl.org>
Cc: Oleg Nesterov <oleg@tv-sign.ru>
Cc: Chad Tindel <ctindel@users.sourceforge.net>
Cc: Jay Vosburgh <fubar@us.ibm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/bonding/bond_3ad.c   |    9 ++
 drivers/net/bonding/bond_3ad.h   |    4 -
 drivers/net/bonding/bond_alb.c   |   12 ++-
 drivers/net/bonding/bond_alb.h   |    4 -
 drivers/net/bonding/bond_main.c  |   92 +++++++++++++----------------
 drivers/net/bonding/bond_sysfs.c |   60 ++++--------------
 drivers/net/bonding/bonding.h    |   15 ++--
 7 files changed, 83 insertions(+), 113 deletions(-)

diff -puN drivers/net/bonding/bond_3ad.c~bonding-replace-system-timer-with-work-queue drivers/net/bonding/bond_3ad.c
--- a/drivers/net/bonding/bond_3ad.c~bonding-replace-system-timer-with-work-queue
+++ a/drivers/net/bonding/bond_3ad.c
@@ -2097,11 +2097,16 @@ void bond_3ad_unbind_slave(struct slave 
  * times out, and it selects an aggregator for the ports that are yet not
  * related to any aggregator, and selects the active aggregator for a bond.
  */
-void bond_3ad_state_machine_handler(struct bonding *bond)
+void bond_3ad_state_machine_handler(struct work_struct *work)
 {
+	struct ad_bond_info *ad_info;
+	struct bonding *bond;
 	struct port *port;
 	struct aggregator *aggregator;
 
+	ad_info = container_of(work, struct ad_bond_info, ad_work.work);
+	bond = container_of(ad_info, struct bonding, ad_info);
+
 	read_lock(&bond->lock);
 
 	if (bond->kill_timers) {
@@ -2149,7 +2154,7 @@ void bond_3ad_state_machine_handler(stru
 	}
 
 re_arm:
-	mod_timer(&(BOND_AD_INFO(bond).ad_timer), jiffies + ad_delta_in_ticks);
+	queue_delayed_work(bond_wq, &(BOND_AD_INFO(bond).ad_work), ad_delta_in_ticks);
 out:
 	read_unlock(&bond->lock);
 }
diff -puN drivers/net/bonding/bond_3ad.h~bonding-replace-system-timer-with-work-queue drivers/net/bonding/bond_3ad.h
--- a/drivers/net/bonding/bond_3ad.h~bonding-replace-system-timer-with-work-queue
+++ a/drivers/net/bonding/bond_3ad.h
@@ -261,7 +261,7 @@ struct ad_bond_info {
 	int lacp_fast;		/* whether fast periodic tx should be
 				 * requested
 				 */
-	struct timer_list ad_timer;
+	struct delayed_work ad_work;
 	struct packet_type ad_pkt_type;
 };
 
@@ -276,7 +276,7 @@ struct ad_slave_info {
 void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution, int lacp_fast);
 int  bond_3ad_bind_slave(struct slave *slave);
 void bond_3ad_unbind_slave(struct slave *slave);
-void bond_3ad_state_machine_handler(struct bonding *bond);
+void bond_3ad_state_machine_handler(struct work_struct *work);
 void bond_3ad_adapter_speed_changed(struct slave *slave);
 void bond_3ad_adapter_duplex_changed(struct slave *slave);
 void bond_3ad_handle_link_change(struct slave *slave, char link);
diff -puN drivers/net/bonding/bond_alb.c~bonding-replace-system-timer-with-work-queue drivers/net/bonding/bond_alb.c
--- a/drivers/net/bonding/bond_alb.c~bonding-replace-system-timer-with-work-queue
+++ a/drivers/net/bonding/bond_alb.c
@@ -28,7 +28,7 @@
 #include <linux/pkt_sched.h>
 #include <linux/spinlock.h>
 #include <linux/slab.h>
-#include <linux/timer.h>
+#include <linux/workqueue.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <linux/if_arp.h>
@@ -1365,12 +1365,16 @@ out:
 	return 0;
 }
 
-void bond_alb_monitor(struct bonding *bond)
+void bond_alb_monitor(struct work_struct *work)
 {
-	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
+	struct alb_bond_info *bond_info;
+	struct bonding *bond;
 	struct slave *slave;
 	int i;
 
+	bond_info = container_of(work, struct alb_bond_info, alb_work.work);
+	bond = container_of(bond_info, struct bonding, alb_info);
+
 	read_lock(&bond->lock);
 
 	if (bond->kill_timers) {
@@ -1469,7 +1473,7 @@ void bond_alb_monitor(struct bonding *bo
 	}
 
 re_arm:
-	mod_timer(&(bond_info->alb_timer), jiffies + alb_delta_in_ticks);
+	queue_delayed_work(bond_wq, &(bond_info->alb_work), alb_delta_in_ticks);
 out:
 	read_unlock(&bond->lock);
 }
diff -puN drivers/net/bonding/bond_alb.h~bonding-replace-system-timer-with-work-queue drivers/net/bonding/bond_alb.h
--- a/drivers/net/bonding/bond_alb.h~bonding-replace-system-timer-with-work-queue
+++ a/drivers/net/bonding/bond_alb.h
@@ -84,7 +84,7 @@ struct tlb_slave_info {
 };
 
 struct alb_bond_info {
-	struct timer_list	alb_timer;
+	struct delayed_work	alb_work;
 	struct tlb_client_info	*tx_hashtbl; /* Dynamically allocated */
 	spinlock_t		tx_hashtbl_lock;
 	u32			unbalanced_load;
@@ -125,7 +125,7 @@ void bond_alb_deinit_slave(struct bondin
 void bond_alb_handle_link_change(struct bonding *bond, struct slave *slave, char link);
 void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave);
 int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev);
-void bond_alb_monitor(struct bonding *bond);
+void bond_alb_monitor(struct work_struct *work);
 int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr);
 void bond_alb_clear_vlan(struct bonding *bond, unsigned short vlan_id);
 #endif /* __BOND_ALB_H__ */
diff -puN drivers/net/bonding/bond_main.c~bonding-replace-system-timer-with-work-queue drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c~bonding-replace-system-timer-with-work-queue
+++ a/drivers/net/bonding/bond_main.c
@@ -48,7 +48,7 @@
 #include <linux/slab.h>
 #include <linux/string.h>
 #include <linux/init.h>
-#include <linux/timer.h>
+#include <linux/workqueue.h>
 #include <linux/socket.h>
 #include <linux/ctype.h>
 #include <linux/inet.h>
@@ -137,6 +137,7 @@ static const char * const version =
 	DRV_DESCRIPTION ": v" DRV_VERSION " (" DRV_RELDATE ")\n";
 
 LIST_HEAD(bond_dev_list);
+struct workqueue_struct *bond_wq;
 
 #ifdef CONFIG_PROC_FS
 static struct proc_dir_entry *bond_proc_dir = NULL;
@@ -2038,9 +2039,10 @@ static int bond_slave_info_query(struct 
 /*-------------------------------- Monitoring -------------------------------*/
 
 /* this function is called regularly to monitor each slave's link. */
-void bond_mii_monitor(struct net_device *bond_dev)
+void bond_mii_monitor(struct work_struct *work)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = container_of(work, struct bonding, mii_work.work);
+	struct net_device *bond_dev = bond->dev;
 	struct slave *slave, *oldcurrent;
 	int do_failover = 0;
 	int delta_in_ticks;
@@ -2269,9 +2271,8 @@ void bond_mii_monitor(struct net_device 
 		bond_set_carrier(bond);
 
 re_arm:
-	if (bond->params.miimon) {
-		mod_timer(&bond->mii_timer, jiffies + delta_in_ticks);
-	}
+	if (bond->params.miimon)
+		queue_delayed_work(bond_wq, &bond->mii_work, delta_in_ticks);
 out:
 	read_unlock(&bond->lock);
 }
@@ -2571,9 +2572,10 @@ out:
  * arp is transmitted to generate traffic. see activebackup_arp_monitor for
  * arp monitoring in active backup mode.
  */
-void bond_loadbalance_arp_mon(struct net_device *bond_dev)
+void bond_loadbalance_arp_mon(struct work_struct *work)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = container_of(work, struct bonding, arp_work.work);
+	struct net_device *bond_dev = bond->dev;
 	struct slave *slave, *oldcurrent;
 	int do_failover = 0;
 	int delta_in_ticks;
@@ -2680,9 +2682,8 @@ void bond_loadbalance_arp_mon(struct net
 	}
 
 re_arm:
-	if (bond->params.arp_interval) {
-		mod_timer(&bond->arp_timer, jiffies + delta_in_ticks);
-	}
+	if (bond->params.arp_interval)
+		queue_delayed_work(bond_wq, &bond->arp_work, delta_in_ticks);
 out:
 	read_unlock(&bond->lock);
 }
@@ -2702,9 +2703,10 @@ out:
  * may have received.
  * see loadbalance_arp_monitor for arp monitoring in load balancing mode
  */
-void bond_activebackup_arp_mon(struct net_device *bond_dev)
+void bond_activebackup_arp_mon(struct work_struct *work)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = container_of(work, struct bonding, arp_work.work);
+	struct net_device *bond_dev = bond->dev;
 	struct slave *slave;
 	int delta_in_ticks;
 	int i;
@@ -2928,9 +2930,8 @@ void bond_activebackup_arp_mon(struct ne
 	}
 
 re_arm:
-	if (bond->params.arp_interval) {
-		mod_timer(&bond->arp_timer, jiffies + delta_in_ticks);
-	}
+	if (bond->params.arp_interval)
+		queue_delayed_work(bond_wq, &bond->arp_work, delta_in_ticks);
 out:
 	read_unlock(&bond->lock);
 }
@@ -3510,14 +3511,12 @@ static int bond_xmit_hash_policy_l2(stru
 static int bond_open(struct net_device *bond_dev)
 {
 	struct bonding *bond = bond_dev->priv;
-	struct timer_list *mii_timer = &bond->mii_timer;
-	struct timer_list *arp_timer = &bond->arp_timer;
 
 	bond->kill_timers = 0;
 
 	if ((bond->params.mode == BOND_MODE_TLB) ||
 	    (bond->params.mode == BOND_MODE_ALB)) {
-		struct timer_list *alb_timer = &(BOND_ALB_INFO(bond).alb_timer);
+		struct delayed_work *alb_work = &(BOND_ALB_INFO(bond).alb_work);
 
 		/* bond_alb_initialize must be called before the timer
 		 * is started.
@@ -3527,43 +3526,24 @@ static int bond_open(struct net_device *
 			return -1;
 		}
 
-		init_timer(alb_timer);
-		alb_timer->expires  = jiffies + 1;
-		alb_timer->data     = (unsigned long)bond;
-		alb_timer->function = (void *)&bond_alb_monitor;
-		add_timer(alb_timer);
+		INIT_DELAYED_WORK(alb_work, bond_alb_monitor);
+		queue_delayed_work(bond_wq, alb_work, 1);
 	}
 
 	if (bond->params.miimon) {  /* link check interval, in milliseconds. */
-		init_timer(mii_timer);
-		mii_timer->expires  = jiffies + 1;
-		mii_timer->data     = (unsigned long)bond_dev;
-		mii_timer->function = (void *)&bond_mii_monitor;
-		add_timer(mii_timer);
+		queue_delayed_work(bond_wq, &bond->mii_work, 1);
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
 		if (bond->params.arp_validate)
 			bond_register_arp(bond);
-
-		add_timer(arp_timer);
+		queue_delayed_work(bond_wq, &bond->arp_work, 1);
 	}
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
-		struct timer_list *ad_timer = &(BOND_AD_INFO(bond).ad_timer);
-		init_timer(ad_timer);
-		ad_timer->expires  = jiffies + 1;
-		ad_timer->data     = (unsigned long)bond;
-		ad_timer->function = (void *)&bond_3ad_state_machine_handler;
-		add_timer(ad_timer);
+		struct delayed_work *ad_work = &(BOND_AD_INFO(bond).ad_work);
+		INIT_DELAYED_WORK(ad_work, bond_3ad_state_machine_handler);
+		queue_delayed_work(bond_wq, ad_work, 1);
 
 		/* register to receive LACPDUs */
 		bond_register_lacpdu(bond);
@@ -3597,20 +3577,20 @@ static int bond_close(struct net_device 
 	 */
 
 	if (bond->params.miimon) {  /* link check interval, in milliseconds. */
-		del_timer_sync(&bond->mii_timer);
+		cancel_rearming_delayed_workqueue(bond_wq, &bond->mii_work);
 	}
 
 	if (bond->params.arp_interval) {  /* arp interval, in milliseconds. */
-		del_timer_sync(&bond->arp_timer);
+		cancel_rearming_delayed_workqueue(bond_wq, &bond->arp_work);
 	}
 
 	switch (bond->params.mode) {
 	case BOND_MODE_8023AD:
-		del_timer_sync(&(BOND_AD_INFO(bond).ad_timer));
+		cancel_rearming_delayed_workqueue(bond_wq, &(BOND_AD_INFO(bond).ad_work));
 		break;
 	case BOND_MODE_TLB:
 	case BOND_MODE_ALB:
-		del_timer_sync(&(BOND_ALB_INFO(bond).alb_timer));
+		cancel_rearming_delayed_workqueue(bond_wq, &(BOND_ALB_INFO(bond).alb_work));
 		break;
 	default:
 		break;
@@ -4266,6 +4246,13 @@ static int bond_init(struct net_device *
 	rwlock_init(&bond->lock);
 	rwlock_init(&bond->curr_slave_lock);
 
+	/* initialize work */
+	INIT_DELAYED_WORK(&bond->mii_work, bond_mii_monitor);
+	if (params->mode == BOND_MODE_ACTIVEBACKUP)
+	        INIT_DELAYED_WORK(&bond->arp_work, bond_activebackup_arp_mon);
+	else
+		INIT_DELAYED_WORK(&bond->arp_work, bond_loadbalance_arp_mon);
+
 	bond->params = *params; /* copy params struct */
 
 	/* Initialize pointers */
@@ -4770,6 +4757,12 @@ static int __init bonding_init(void)
 			goto err;
 	}
 
+	bond_wq = create_singlethread_workqueue("bond");
+	if (bond_wq == NULL) {
+		res = -ENOMEM;
+		goto err;
+	}
+
 	res = bond_create_sysfs();
 	if (res)
 		goto err;
@@ -4795,6 +4788,7 @@ static void __exit bonding_exit(void)
 
 	rtnl_lock();
 	bond_free_all();
+	destroy_workqueue(bond_wq);
 	bond_destroy_sysfs();
 	rtnl_unlock();
 }
diff -puN drivers/net/bonding/bond_sysfs.c~bonding-replace-system-timer-with-work-queue drivers/net/bonding/bond_sysfs.c
--- a/drivers/net/bonding/bond_sysfs.c~bonding-replace-system-timer-with-work-queue
+++ a/drivers/net/bonding/bond_sysfs.c
@@ -1,4 +1,3 @@
-
 /*
  * Copyright(c) 2004-2005 Intel Corporation. All rights reserved.
  *
@@ -434,6 +433,13 @@ static ssize_t bonding_store_mode(struct
 		if (bond->params.mode == BOND_MODE_ALB)
 			bond_unset_master_alb_flags(bond);
 
+		if (new_value == BOND_MODE_ACTIVEBACKUP)
+			INIT_DELAYED_WORK(&bond->arp_work,
+					bond_activebackup_arp_mon);
+		else
+			INIT_DELAYED_WORK(&bond->arp_work,
+					bond_loadbalance_arp_mon);
+
 		bond->params.mode = new_value;
 		bond_set_mode_ops(bond, bond->params.mode);
 		printk(KERN_INFO DRV_NAME ": %s: setting mode to %s (%d).\n",
@@ -609,13 +615,7 @@ static ssize_t bonding_store_arp_interva
 		       "%s Disabling MII monitoring.\n",
 		       bond->dev->name, bond->dev->name);
 		bond->params.miimon = 0;
-		/* Kill MII timer, else it brings bond's link down */
-		if (bond->arp_timer.function) {
-			printk(KERN_INFO DRV_NAME
-			": %s: Kill MII timer, else it brings bond's link down...\n",
-		       bond->dev->name);
-			del_timer_sync(&bond->mii_timer);
-		}
+		cancel_rearming_delayed_workqueue(bond_wq, &bond->mii_work);
 	}
 	if (!bond->params.arp_targets[0]) {
 		printk(KERN_INFO DRV_NAME
@@ -629,26 +629,8 @@ static ssize_t bonding_store_arp_interva
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
-		}
+		cancel_rearming_delayed_workqueue(bond_wq, &bond->arp_work);
+		queue_delayed_work(bond_wq, &bond->arp_work, 1);
 	}
 
 out:
@@ -1004,12 +986,7 @@ static ssize_t bonding_store_miimon(stru
 					BOND_ARP_VALIDATE_NONE;
 			}
 			/* Kill ARP timer, else it brings bond's link down */
-			if (bond->mii_timer.function) {
-				printk(KERN_INFO DRV_NAME
-				": %s: Kill ARP timer, else it brings bond's link down...\n",
-			       bond->dev->name);
-				del_timer_sync(&bond->arp_timer);
-			}
+			cancel_rearming_delayed_workqueue(bond_wq, &bond->arp_work);
 		}
 
 		if (bond->dev->flags & IFF_UP) {
@@ -1018,19 +995,8 @@ static ssize_t bonding_store_miimon(stru
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
-			}
+			cancel_rearming_delayed_workqueue(bond_wq, &bond->mii_work);
+			queue_delayed_work(bond_wq, &bond->mii_work, 1);
 		}
 	}
 out:
diff -puN drivers/net/bonding/bonding.h~bonding-replace-system-timer-with-work-queue drivers/net/bonding/bonding.h
--- a/drivers/net/bonding/bonding.h~bonding-replace-system-timer-with-work-queue
+++ a/drivers/net/bonding/bonding.h
@@ -15,7 +15,7 @@
 #ifndef _LINUX_BONDING_H
 #define _LINUX_BONDING_H
 
-#include <linux/timer.h>
+#include <linux/workqueue.h>
 #include <linux/proc_fs.h>
 #include <linux/if_bonding.h>
 #include <linux/kobject.h>
@@ -182,8 +182,8 @@ struct bonding {
 	s32      slave_cnt; /* never change this value outside the attach/detach wrappers */
 	rwlock_t lock;
 	rwlock_t curr_slave_lock;
-	struct   timer_list mii_timer;
-	struct   timer_list arp_timer;
+	struct   delayed_work mii_work;
+	struct   delayed_work arp_work;
 	s8       kill_timers;
 	struct   net_device_stats stats;
 #ifdef CONFIG_PROC_FS
@@ -302,9 +302,9 @@ void bond_destroy_slave_symlinks(struct 
 int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_release(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_sethwaddr(struct net_device *bond_dev, struct net_device *slave_dev);
-void bond_mii_monitor(struct net_device *bond_dev);
-void bond_loadbalance_arp_mon(struct net_device *bond_dev);
-void bond_activebackup_arp_mon(struct net_device *bond_dev);
+void bond_mii_monitor(struct work_struct *work);
+void bond_loadbalance_arp_mon(struct work_struct *work);
+void bond_activebackup_arp_mon(struct work_struct *work);
 void bond_set_mode_ops(struct bonding *bond, int mode);
 int bond_parse_parm(char *mode_arg, struct bond_parm_tbl *tbl);
 const char *bond_mode_name(int mode);
@@ -313,5 +313,6 @@ void bond_change_active_slave(struct bon
 void bond_register_arp(struct bonding *);
 void bond_unregister_arp(struct bonding *);
 
-#endif /* _LINUX_BONDING_H */
+extern struct workqueue_struct *bond_wq;
 
+#endif /* _LINUX_BONDING_H */
_
