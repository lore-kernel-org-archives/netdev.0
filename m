From: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
Subject: [PATCH 1/4] bonding: Fix work initing and cancelling
Date: Tue, 15 Jan 2008 15:36:05 +0900
Message-ID: <20080115063649.961619000@miraclelinux.com>
References: <20080115063604.577118000@miraclelinux.com>
Cc: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:9816 "EHLO
	dhcp-0021.miraclelinux.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751618AbYAOGeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 01:34:25 -0500
Content-Disposition: inline; filename=bonding-fix-work-manipulation-in-sysfs.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

delayed_work_pending() is used to check whether work is being queued or not,
when queueing or cancelling corresponding work. However,
delayed_work_pending() returns 0 when work is just running, and in that case,
work_struct will be destroyed or work won't be cancelled. So remove all
delayed_work_pending(), and move all INIT_DELAYED_WORK to bonding init
process, just queue or cancel work. For this purpose, arp_work is divided into
two works.

Signed-off-by: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
---

 drivers/net/bonding/bond_main.c  |   46 ++++++++++++++++++++------------------
 drivers/net/bonding/bond_sysfs.c |   36 +++++++++--------------------
 drivers/net/bonding/bonding.h    |    3 +-
 3 files changed, 39 insertions(+), 46 deletions(-)

--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2692,7 +2692,7 @@ out:
 void bond_loadbalance_arp_mon(struct work_struct *work)
 {
 	struct bonding *bond = container_of(work, struct bonding,
-					    arp_work.work);
+					    lb_arp_work.work);
 	struct slave *slave, *oldcurrent;
 	int do_failover = 0;
 	int delta_in_ticks;
@@ -2803,7 +2803,7 @@ void bond_loadbalance_arp_mon(struct wor
 
 re_arm:
 	if (bond->params.arp_interval)
-		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
+		queue_delayed_work(bond->wq, &bond->lb_arp_work, delta_in_ticks);
 out:
 	read_unlock(&bond->lock);
 }
@@ -2826,7 +2826,7 @@ out:
 void bond_activebackup_arp_mon(struct work_struct *work)
 {
 	struct bonding *bond = container_of(work, struct bonding,
-					    arp_work.work);
+					    ab_arp_work.work);
 	struct slave *slave;
 	int delta_in_ticks;
 	int i;
@@ -3060,7 +3060,7 @@ void bond_activebackup_arp_mon(struct wo
 
 re_arm:
 	if (bond->params.arp_interval) {
-		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
+		queue_delayed_work(bond->wq, &bond->ab_arp_work, delta_in_ticks);
 	}
 out:
 	read_unlock(&bond->lock);
@@ -3679,30 +3679,23 @@ static int bond_open(struct net_device *
 			return -1;
 		}
 
-		INIT_DELAYED_WORK(&bond->alb_work, bond_alb_monitor);
 		queue_delayed_work(bond->wq, &bond->alb_work, 0);
 	}
 
 	if (bond->params.miimon) {  /* link check interval, in milliseconds. */
-		INIT_DELAYED_WORK(&bond->mii_work, bond_mii_monitor);
 		queue_delayed_work(bond->wq, &bond->mii_work, 0);
 	}
 
 	if (bond->params.arp_interval) {  /* arp interval, in milliseconds. */
 		if (bond->params.mode == BOND_MODE_ACTIVEBACKUP)
-			INIT_DELAYED_WORK(&bond->arp_work,
-					  bond_activebackup_arp_mon);
+			queue_delayed_work(bond->wq, &bond->ab_arp_work, 0);
 		else
-			INIT_DELAYED_WORK(&bond->arp_work,
-					  bond_loadbalance_arp_mon);
-
-		queue_delayed_work(bond->wq, &bond->arp_work, 0);
+			queue_delayed_work(bond->wq, &bond->lb_arp_work, 0);
 		if (bond->params.arp_validate)
 			bond_register_arp(bond);
 	}
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
-		INIT_DELAYED_WORK(&bond->ad_work, bond_3ad_state_machine_handler);
 		queue_delayed_work(bond->wq, &bond->ad_work, 0);
 		/* register to receive LACPDUs */
 		bond_register_lacpdu(bond);
@@ -3736,7 +3729,10 @@ static int bond_close(struct net_device 
 	}
 
 	if (bond->params.arp_interval) {  /* arp interval, in milliseconds. */
-		cancel_delayed_work(&bond->arp_work);
+		if (bond->params.mode == BOND_MODE_ACTIVEBACKUP)
+			cancel_delayed_work(&bond->ab_arp_work);
+		else
+			cancel_delayed_work(&bond->lb_arp_work);
 	}
 
 	switch (bond->params.mode) {
@@ -4416,6 +4412,12 @@ static int bond_init(struct net_device *
 	if (!bond->wq)
 		return -ENOMEM;
 
+	INIT_DELAYED_WORK(&bond->alb_work, bond_alb_monitor);
+	INIT_DELAYED_WORK(&bond->mii_work, bond_mii_monitor);
+	INIT_DELAYED_WORK(&bond->ab_arp_work, bond_activebackup_arp_mon);
+	INIT_DELAYED_WORK(&bond->lb_arp_work, bond_loadbalance_arp_mon);
+	INIT_DELAYED_WORK(&bond->ad_work, bond_3ad_state_machine_handler);
+
 	/* Initialize pointers */
 	bond->first_slave = NULL;
 	bond->curr_active_slave = NULL;
@@ -4498,18 +4500,20 @@ static void bond_work_cancel_all(struct 
 	bond->kill_timers = 1;
 	write_unlock_bh(&bond->lock);
 
-	if (bond->params.miimon && delayed_work_pending(&bond->mii_work))
+	if (bond->params.miimon)
 		cancel_delayed_work(&bond->mii_work);
 
-	if (bond->params.arp_interval && delayed_work_pending(&bond->arp_work))
-		cancel_delayed_work(&bond->arp_work);
+	if (bond->params.arp_interval) {
+		if (bond->params.mode == BOND_MODE_ACTIVEBACKUP)
+			cancel_delayed_work(&bond->ab_arp_work);
+		else
+			cancel_delayed_work(&bond->lb_arp_work);
+	}
 
-	if (bond->params.mode == BOND_MODE_ALB &&
-	    delayed_work_pending(&bond->alb_work))
+	if (bond->params.mode == BOND_MODE_ALB)
 		cancel_delayed_work(&bond->alb_work);
 
-	if (bond->params.mode == BOND_MODE_8023AD &&
-	    delayed_work_pending(&bond->ad_work))
+	if (bond->params.mode == BOND_MODE_8023AD)
 		cancel_delayed_work(&bond->ad_work);
 }
 
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -643,10 +643,8 @@ static ssize_t bonding_store_arp_interva
 		       "%s Disabling MII monitoring.\n",
 		       bond->dev->name, bond->dev->name);
 		bond->params.miimon = 0;
-		if (delayed_work_pending(&bond->mii_work)) {
-			cancel_delayed_work(&bond->mii_work);
-			flush_workqueue(bond->wq);
-		}
+		cancel_delayed_work(&bond->mii_work);
+		flush_workqueue(bond->wq);
 	}
 	if (!bond->params.arp_targets[0]) {
 		printk(KERN_INFO DRV_NAME
@@ -660,16 +658,10 @@ static ssize_t bonding_store_arp_interva
 		 * timer will get fired off when the open function
 		 * is called.
 		 */
-		if (!delayed_work_pending(&bond->arp_work)) {
-			if (bond->params.mode == BOND_MODE_ACTIVEBACKUP)
-				INIT_DELAYED_WORK(&bond->arp_work,
-						  bond_activebackup_arp_mon);
-			else
-				INIT_DELAYED_WORK(&bond->arp_work,
-						  bond_loadbalance_arp_mon);
-
-			queue_delayed_work(bond->wq, &bond->arp_work, 0);
-		}
+		if (bond->params.mode == BOND_MODE_ACTIVEBACKUP)
+			queue_delayed_work(bond->wq, &bond->ab_arp_work, 0);
+		else
+			queue_delayed_work(bond->wq, &bond->lb_arp_work, 0);
 	}
 
 out:
@@ -1022,10 +1014,11 @@ static ssize_t bonding_store_miimon(stru
 				bond->params.arp_validate =
 					BOND_ARP_VALIDATE_NONE;
 			}
-			if (delayed_work_pending(&bond->arp_work)) {
-				cancel_delayed_work(&bond->arp_work);
-				flush_workqueue(bond->wq);
-			}
+			if (bond->params.mode == BOND_MODE_ACTIVEBACKUP)
+				cancel_delayed_work(&bond->ab_arp_work);
+			else
+				cancel_delayed_work(&bond->lb_arp_work);
+			flush_workqueue(bond->wq);
 		}
 
 		if (bond->dev->flags & IFF_UP) {
@@ -1034,12 +1027,7 @@ static ssize_t bonding_store_miimon(stru
 			 * timer will get fired off when the open function
 			 * is called.
 			 */
-			if (!delayed_work_pending(&bond->mii_work)) {
-				INIT_DELAYED_WORK(&bond->mii_work,
-						  bond_mii_monitor);
-				queue_delayed_work(bond->wq,
-						   &bond->mii_work, 0);
-			}
+			queue_delayed_work(bond->wq, &bond->mii_work, 0);
 		}
 	}
 out:
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -206,7 +206,8 @@ struct bonding {
 	struct   packet_type arp_mon_pt;
 	struct   workqueue_struct *wq;
 	struct   delayed_work mii_work;
-	struct   delayed_work arp_work;
+	struct   delayed_work ab_arp_work;
+	struct   delayed_work lb_arp_work;
 	struct   delayed_work alb_work;
 	struct   delayed_work ad_work;
 };

-- 
Makito SHIOKAWA
MIRACLE LINUX CORPORATION 
