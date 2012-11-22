From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH] bonding: fix multiple bugs
Date: Thu, 22 Nov 2012 14:10:27 +0100
Message-ID: <1353589827-2921-1-git-send-email-nikolay@redhat.com>
Cc: fubar@us.ibm.com, andy@greyhouse.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17244 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754379Ab2KVSiG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2012 13:38:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch aims to fix multiple race conditions, missing module parameter checks and
workqueue usage. First I would give three observations which will be used later.
Observation 1: if (delayed_work_pending(wq)) cancel_delayed_work(wq)
 This usage is wrong because the pending bit is cleared just before the work's fn is
 executed and if the function re-arms itself we might end up with the work still
 running. It is safe to call cancel_delayed_work_sync() even if the work is not queued
 at all.
Observation 2: Use of INIT_DELAYED_WORK()
 Work needs to be initialized only once prior to (de/en)queueing.
Observation 3: IFF_UPP is set only after ndo_open is called

Bugs:
1. Race between bonding_store_miimon() and bonding_store_arp_interval()
 Because of Obs.1 we can end up having both works enqueued.
2. Multiple races with INIT_DELAYED_WORK()
 Since the works are not protected by anything between INIT_DELAYED_WORK() and
 calls to (en/de)queue it is possible for races between the following functions:
 (races are also possible between calls to INIT_DELAYED_WORK() and workqueue code)
 bonding_store_miimon() - bonding_store_arp_interval(), bond_close(), bond_open(),
			  enqueued functions
 bonding_store_arp_interval() - bonding_store_miimon(), bond_close(), bond_open(),
				enqueued functions
3. Race between bonding_store_slaves_active() and slave manipulation functions
 The bond_for_each_slave use in bonding_store_slaves_active() is not protected
 by any synchronization mechanisms. NULL pointer dereference is easy to reach.
4. By Obs.1 we need to change bond_cancel_all()
5. The module can be loaded with arp_ip_target="255.255.255.255" which makes it
 impossible to remove as the function in sysfs checks for that value, so we make
 the argument checks consistent with sysfs.

Bugs 1 and 2 are fixed by moving all work initializations in bond_open which by
Obs. 2 and Obs. 3 and the fact that we make sure that all works are cancelled in
bond_close(), is guaranteed not to have any work enqueued. Also RTNL lock is now
acquired in bonding_store_miimon/arp_interval so they can't race with bond_close
and bond_open. The opposing work is cancelled only if the IFF_UPP flag is set
and it is cancelled unconditionally. The opposing work is already cancelled if
the interface is down so no need to cancel it again. This way we don't need new
synchronizations for the bonding workqueue. Bug 3 is fixed by acquiring the
read_lock for the slave walk.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c  | 94 +++++++++++++---------------------------
 drivers/net/bonding/bond_sysfs.c | 36 +++++----------
 2 files changed, 42 insertions(+), 88 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 5f5b69f..d0b27a9 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3459,6 +3459,28 @@ static int bond_xmit_hash_policy_l34(struct sk_buff *skb, int count)
 
 /*-------------------------- Device entry points ----------------------------*/
 
+static void bond_work_init_all(struct bonding *bond)
+{
+	INIT_DELAYED_WORK(&bond->mcast_work, 
+			  bond_resend_igmp_join_requests_delayed);
+	INIT_DELAYED_WORK(&bond->alb_work, bond_alb_monitor);
+	INIT_DELAYED_WORK(&bond->mii_work, bond_mii_monitor);
+	if (bond->params.mode == BOND_MODE_ACTIVEBACKUP)
+		INIT_DELAYED_WORK(&bond->arp_work, bond_activebackup_arp_mon);
+	else
+		INIT_DELAYED_WORK(&bond->arp_work, bond_loadbalance_arp_mon);
+	INIT_DELAYED_WORK(&bond->ad_work, bond_3ad_state_machine_handler);
+}
+
+static void bond_work_cancel_all(struct bonding *bond)
+{
+	cancel_delayed_work_sync(&bond->mii_work);
+	cancel_delayed_work_sync(&bond->arp_work);
+	cancel_delayed_work_sync(&bond->alb_work);
+	cancel_delayed_work_sync(&bond->ad_work);
+	cancel_delayed_work_sync(&bond->mcast_work);
+}
+
 static int bond_open(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
@@ -3481,41 +3503,27 @@ static int bond_open(struct net_device *bond_dev)
 	}
 	read_unlock(&bond->lock);
 
-	INIT_DELAYED_WORK(&bond->mcast_work, bond_resend_igmp_join_requests_delayed);
+	bond_work_init_all(bond);
 
 	if (bond_is_lb(bond)) {
 		/* bond_alb_initialize must be called before the timer
 		 * is started.
 		 */
-		if (bond_alb_initialize(bond, (bond->params.mode == BOND_MODE_ALB))) {
-			/* something went wrong - fail the open operation */
+		if (bond_alb_initialize(bond, (bond->params.mode == BOND_MODE_ALB)))
 			return -ENOMEM;
-		}
-
-		INIT_DELAYED_WORK(&bond->alb_work, bond_alb_monitor);
 		queue_delayed_work(bond->wq, &bond->alb_work, 0);
 	}
 
-	if (bond->params.miimon) {  /* link check interval, in milliseconds. */
-		INIT_DELAYED_WORK(&bond->mii_work, bond_mii_monitor);
+	if (bond->params.miimon)  /* link check interval, in milliseconds. */
 		queue_delayed_work(bond->wq, &bond->mii_work, 0);
-	}
 
 	if (bond->params.arp_interval) {  /* arp interval, in milliseconds. */
-		if (bond->params.mode == BOND_MODE_ACTIVEBACKUP)
-			INIT_DELAYED_WORK(&bond->arp_work,
-					  bond_activebackup_arp_mon);
-		else
-			INIT_DELAYED_WORK(&bond->arp_work,
-					  bond_loadbalance_arp_mon);
-
 		queue_delayed_work(bond->wq, &bond->arp_work, 0);
 		if (bond->params.arp_validate)
 			bond->recv_probe = bond_arp_rcv;
 	}
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
-		INIT_DELAYED_WORK(&bond->ad_work, bond_3ad_state_machine_handler);
 		queue_delayed_work(bond->wq, &bond->ad_work, 0);
 		/* register to receive LACPDUs */
 		bond->recv_probe = bond_3ad_lacpdu_recv;
@@ -3530,34 +3538,10 @@ static int bond_close(struct net_device *bond_dev)
 	struct bonding *bond = netdev_priv(bond_dev);
 
 	write_lock_bh(&bond->lock);
-
 	bond->send_peer_notif = 0;
-
 	write_unlock_bh(&bond->lock);
 
-	if (bond->params.miimon) {  /* link check interval, in milliseconds. */
-		cancel_delayed_work_sync(&bond->mii_work);
-	}
-
-	if (bond->params.arp_interval) {  /* arp interval, in milliseconds. */
-		cancel_delayed_work_sync(&bond->arp_work);
-	}
-
-	switch (bond->params.mode) {
-	case BOND_MODE_8023AD:
-		cancel_delayed_work_sync(&bond->ad_work);
-		break;
-	case BOND_MODE_TLB:
-	case BOND_MODE_ALB:
-		cancel_delayed_work_sync(&bond->alb_work);
-		break;
-	default:
-		break;
-	}
-
-	if (delayed_work_pending(&bond->mcast_work))
-		cancel_delayed_work_sync(&bond->mcast_work);
-
+	bond_work_cancel_all(bond);
 	if (bond_is_lb(bond)) {
 		/* Must be called only after all
 		 * slaves have been released
@@ -4436,26 +4420,6 @@ static void bond_setup(struct net_device *bond_dev)
 	bond_dev->features |= bond_dev->hw_features;
 }
 
-static void bond_work_cancel_all(struct bonding *bond)
-{
-	if (bond->params.miimon && delayed_work_pending(&bond->mii_work))
-		cancel_delayed_work_sync(&bond->mii_work);
-
-	if (bond->params.arp_interval && delayed_work_pending(&bond->arp_work))
-		cancel_delayed_work_sync(&bond->arp_work);
-
-	if (bond->params.mode == BOND_MODE_ALB &&
-	    delayed_work_pending(&bond->alb_work))
-		cancel_delayed_work_sync(&bond->alb_work);
-
-	if (bond->params.mode == BOND_MODE_8023AD &&
-	    delayed_work_pending(&bond->ad_work))
-		cancel_delayed_work_sync(&bond->ad_work);
-
-	if (delayed_work_pending(&bond->mcast_work))
-		cancel_delayed_work_sync(&bond->mcast_work);
-}
-
 /*
 * Destroy a bonding device.
 * Must be under rtnl_lock when this function is called.
@@ -4706,12 +4670,14 @@ static int bond_check_params(struct bond_params *params)
 	     arp_ip_count++) {
 		/* not complete check, but should be good enough to
 		   catch mistakes */
-		if (!isdigit(arp_ip_target[arp_ip_count][0])) {
+		__be32 ip = in_aton(arp_ip_target[arp_ip_count]);
+		if (!isdigit(arp_ip_target[arp_ip_count][0]) 
+		    || ip == 0
+		    || ip == htonl(INADDR_BROADCAST)) {
 			pr_warning("Warning: bad arp_ip_target module parameter (%s), ARP monitoring will not be performed\n",
 				   arp_ip_target[arp_ip_count]);
 			arp_interval = 0;
 		} else {
-			__be32 ip = in_aton(arp_ip_target[arp_ip_count]);
 			arp_target[arp_ip_count] = ip;
 		}
 	}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index ef8d2a0..1877ed7 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -513,6 +513,8 @@ static ssize_t bonding_store_arp_interval(struct device *d,
 	int new_value, ret = count;
 	struct bonding *bond = to_bond(d);
 
+	if (!rtnl_trylock())
+		return restart_syscall();
 	if (sscanf(buf, "%d", &new_value) != 1) {
 		pr_err("%s: no arp_interval value specified.\n",
 		       bond->dev->name);
@@ -539,10 +541,6 @@ static ssize_t bonding_store_arp_interval(struct device *d,
 		pr_info("%s: ARP monitoring cannot be used with MII monitoring. %s Disabling MII monitoring.\n",
 			bond->dev->name, bond->dev->name);
 		bond->params.miimon = 0;
-		if (delayed_work_pending(&bond->mii_work)) {
-			cancel_delayed_work(&bond->mii_work);
-			flush_workqueue(bond->wq);
-		}
 	}
 	if (!bond->params.arp_targets[0]) {
 		pr_info("%s: ARP monitoring has been set up, but no ARP targets have been specified.\n",
@@ -554,19 +552,12 @@ static ssize_t bonding_store_arp_interval(struct device *d,
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
+		cancel_delayed_work_sync(&bond->mii_work);
+		queue_delayed_work(bond->wq, &bond->arp_work, 0);
 	}
 
 out:
+	rtnl_unlock();
 	return ret;
 }
 static DEVICE_ATTR(arp_interval, S_IRUGO | S_IWUSR,
@@ -962,6 +953,8 @@ static ssize_t bonding_store_miimon(struct device *d,
 	int new_value, ret = count;
 	struct bonding *bond = to_bond(d);
 
+	if (!rtnl_trylock())
+		return restart_syscall();
 	if (sscanf(buf, "%d", &new_value) != 1) {
 		pr_err("%s: no miimon value specified.\n",
 		       bond->dev->name);
@@ -993,10 +986,6 @@ static ssize_t bonding_store_miimon(struct device *d,
 				bond->params.arp_validate =
 					BOND_ARP_VALIDATE_NONE;
 			}
-			if (delayed_work_pending(&bond->arp_work)) {
-				cancel_delayed_work(&bond->arp_work);
-				flush_workqueue(bond->wq);
-			}
 		}
 
 		if (bond->dev->flags & IFF_UP) {
@@ -1005,15 +994,12 @@ static ssize_t bonding_store_miimon(struct device *d,
 			 * timer will get fired off when the open function
 			 * is called.
 			 */
-			if (!delayed_work_pending(&bond->mii_work)) {
-				INIT_DELAYED_WORK(&bond->mii_work,
-						  bond_mii_monitor);
-				queue_delayed_work(bond->wq,
-						   &bond->mii_work, 0);
-			}
+			cancel_delayed_work_sync(&bond->arp_work);
+			queue_delayed_work(bond->wq, &bond->mii_work, 0);
 		}
 	}
 out:
+	rtnl_unlock();
 	return ret;
 }
 static DEVICE_ATTR(miimon, S_IRUGO | S_IWUSR,
@@ -1582,6 +1568,7 @@ static ssize_t bonding_store_slaves_active(struct device *d,
 		goto out;
 	}
 
+	read_lock(&bond->lock);
 	bond_for_each_slave(bond, slave, i) {
 		if (!bond_is_active_slave(slave)) {
 			if (new_value)
@@ -1590,6 +1577,7 @@ static ssize_t bonding_store_slaves_active(struct device *d,
 				slave->inactive = 1;
 		}
 	}
+	read_unlock(&bond->lock);
 out:
 	return ret;
 }
-- 
1.7.11.7
