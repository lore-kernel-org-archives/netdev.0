From: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
Subject: [PATCH 4/4] bonding: Fix some RTNL taking
Date: Tue, 15 Jan 2008 15:36:08 +0900
Message-ID: <20080115063650.236883000@miraclelinux.com>
References: <20080115063604.577118000@miraclelinux.com>
Cc: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:9820 "EHLO
	dhcp-0021.miraclelinux.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751781AbYAOGeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 01:34:25 -0500
Content-Disposition: inline; filename=bonding-fix-some-rtnl-taking.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix some RTNL lock taking:

* RTNL (mutex; may sleep) must not be taken under read_lock (spinlock; must be
atomic). However, RTNL is taken under read_lock in bond_loadbalance_arp_mon()
and bond_activebackup_arp_mon(). So change code to take RTNL outside of read_lock.

* rtnl_unlock() calls netdev_run_todo() which takes net_todo_run_mutex, and
rtnl_unlock() is called under read_lock in bond_mii_monitor(). So for the same
reason as above, change code to call rtnl_unlock() outside of read_lock.

Signed-off-by: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
---
 drivers/net/bonding/bond_main.c |   24 ++++++++++--------------
 1 file changed, 10 insertions(+), 14 deletions(-)

--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2372,6 +2372,7 @@ void bond_mii_monitor(struct work_struct
 	struct bonding *bond = container_of(work, struct bonding,
 					    mii_work.work);
 	unsigned long delay;
+	int need_unlock = 0;
 
 	read_lock(&bond->lock);
 	if (bond->kill_timers) {
@@ -2383,13 +2384,16 @@ void bond_mii_monitor(struct work_struct
 		rtnl_lock();
 		read_lock(&bond->lock);
 		__bond_mii_monitor(bond, 1);
-		rtnl_unlock();
+		need_unlock = 1;
 	}
 
 	delay = ((bond->params.miimon * HZ) / 1000) ? : 1;
-	read_unlock(&bond->lock);
 	if (bond->params.miimon)
 		queue_delayed_work(bond->wq, &bond->mii_work, delay);
+	read_unlock(&bond->lock);
+	/* rtnl_unlock() may sleep, so call it after read_unlock() */
+	if (need_unlock)
+		rtnl_unlock();
 }
 
 static __be32 bond_glean_dev_ip(struct net_device *dev)
@@ -2698,6 +2702,7 @@ void bond_loadbalance_arp_mon(struct wor
 	int delta_in_ticks;
 	int i;
 
+	rtnl_lock();
 	read_lock(&bond->lock);
 
 	delta_in_ticks = (bond->params.arp_interval * HZ) / 1000;
@@ -2791,14 +2796,11 @@ void bond_loadbalance_arp_mon(struct wor
 	}
 
 	if (do_failover) {
-		rtnl_lock();
 		write_lock_bh(&bond->curr_slave_lock);
 
 		bond_select_active_slave(bond);
 
 		write_unlock_bh(&bond->curr_slave_lock);
-		rtnl_unlock();
-
 	}
 
 re_arm:
@@ -2806,6 +2808,7 @@ re_arm:
 		queue_delayed_work(bond->wq, &bond->lb_arp_work, delta_in_ticks);
 out:
 	read_unlock(&bond->lock);
+	rtnl_unlock();
 }
 
 /*
@@ -2831,6 +2834,7 @@ void bond_activebackup_arp_mon(struct wo
 	int delta_in_ticks;
 	int i;
 
+	rtnl_lock();
 	read_lock(&bond->lock);
 
 	delta_in_ticks = (bond->params.arp_interval * HZ) / 1000;
@@ -2855,8 +2859,6 @@ void bond_activebackup_arp_mon(struct wo
 
 				slave->link = BOND_LINK_UP;
 
-				rtnl_lock();
-
 				write_lock_bh(&bond->curr_slave_lock);
 
 				if ((!bond->curr_active_slave) &&
@@ -2892,7 +2894,6 @@ void bond_activebackup_arp_mon(struct wo
 				}
 
 				write_unlock_bh(&bond->curr_slave_lock);
-				rtnl_unlock();
 			}
 		} else {
 			read_lock(&bond->curr_slave_lock);
@@ -2962,7 +2963,6 @@ void bond_activebackup_arp_mon(struct wo
 			       bond->dev->name,
 			       slave->dev->name);
 
-			rtnl_lock();
 			write_lock_bh(&bond->curr_slave_lock);
 
 			bond_select_active_slave(bond);
@@ -2970,8 +2970,6 @@ void bond_activebackup_arp_mon(struct wo
 
 			write_unlock_bh(&bond->curr_slave_lock);
 
-			rtnl_unlock();
-
 			bond->current_arp_slave = slave;
 
 			if (slave) {
@@ -2989,13 +2987,10 @@ void bond_activebackup_arp_mon(struct wo
 			       bond->primary_slave->dev->name);
 
 			/* primary is up so switch to it */
-			rtnl_lock();
 			write_lock_bh(&bond->curr_slave_lock);
 			bond_change_active_slave(bond, bond->primary_slave);
 			write_unlock_bh(&bond->curr_slave_lock);
 
-			rtnl_unlock();
-
 			slave = bond->primary_slave;
 			slave->jiffies = jiffies;
 		} else {
@@ -3064,6 +3059,7 @@ re_arm:
 	}
 out:
 	read_unlock(&bond->lock);
+	rtnl_unlock();
 }
 
 /*------------------------------ proc/seq_file-------------------------------*/

-- 
Makito SHIOKAWA
MIRACLE LINUX CORPORATION 
