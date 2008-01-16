From: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
Subject: Re: [PATCH 1/4] bonding: Fix work initing and cancelling
Date: Wed, 16 Jan 2008 14:17:02 +0900
Message-ID: <478D934E.8090505@miraclelinux.com>
References: <20080115105601.GC1696@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Makito SHIOKAWA <mshiokawa@miraclelinux.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:2724 "EHLO
	mail.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751997AbYAPFS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 00:18:58 -0500
In-Reply-To: <20080115105601.GC1696@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I wonder why don't you use cancel_delayed_work_sync() here (and in a
> few other places), like in bond_work_cancel_all() from patch 2/4?
In bond_close(), you can't use cancel_delayed_work_sync() because you can't
unlock RTNL in it. (So, on current implementation, it becomes work cancel is
not ensured on bond_close().)
In sysfs, I think you are right, thanks. So, I will modify the patch as below
(other patches won't be affected).

---

  drivers/net/bonding/bond_main.c  |   46 ++++++++++++++++++++------------------
  drivers/net/bonding/bond_sysfs.c |   34 ++++++++--------------------
  drivers/net/bonding/bonding.h    |    3 +-
  3 files changed, 37 insertions(+), 46 deletions(-)

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
@@ -643,10 +643,7 @@ static ssize_t bonding_store_arp_interva
  		       "%s Disabling MII monitoring.\n",
  		       bond->dev->name, bond->dev->name);
  		bond->params.miimon = 0;
-		if (delayed_work_pending(&bond->mii_work)) {
-			cancel_delayed_work(&bond->mii_work);
-			flush_workqueue(bond->wq);
-		}
+		cancel_delayed_work_sync(&bond->mii_work);
  	}
  	if (!bond->params.arp_targets[0]) {
  		printk(KERN_INFO DRV_NAME
@@ -660,16 +657,10 @@ static ssize_t bonding_store_arp_interva
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
@@ -1022,10 +1013,10 @@ static ssize_t bonding_store_miimon(stru
  				bond->params.arp_validate =
  					BOND_ARP_VALIDATE_NONE;
  			}
-			if (delayed_work_pending(&bond->arp_work)) {
-				cancel_delayed_work(&bond->arp_work);
-				flush_workqueue(bond->wq);
-			}
+			if (bond->params.mode == BOND_MODE_ACTIVEBACKUP)
+				cancel_delayed_work_sync(&bond->ab_arp_work);
+			else
+				cancel_delayed_work_sync(&bond->lb_arp_work);
  		}

  		if (bond->dev->flags & IFF_UP) {
@@ -1034,12 +1025,7 @@ static ssize_t bonding_store_miimon(stru
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

