From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH net-next] bonding: eliminate bond_close race conditions
Date: Fri, 28 Oct 2011 18:42:50 -0700
Message-ID: <21320.1319852570@death>
References: <4EA4E2EE.4050201@hitachi.com> <2216.1319650260@death> <4EAA0ADF.5020504@hitachi.com> <20111027.231520.698587739433841485.davem@davemloft.net>
Cc: mitsuo.hayasaka.hu@hitachi.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, shemminger@vyatta.com,
	andy@greyhouse.net, linux-kernel@vger.kernel.org,
	yrl.pp-manager.tt@hitachi.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:49251 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752618Ab1J2Bnm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Oct 2011 21:43:42 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Fri, 28 Oct 2011 21:43:41 -0400
In-reply-to: <20111027.231520.698587739433841485.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	This patch resolves two sets of race conditions.

	Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com> reported the
first, as follows:

The bond_close() calls cancel_delayed_work() to cancel delayed works.
It, however, cannot cancel works that were already queued in workqueue.
The bond_open() initializes work->data, and proccess_one_work() refers
get_work_cwq(work)->wq->flags. The get_work_cwq() returns NULL when
work->data has been initialized. Thus, a panic occurs.

	He included a patch that converted the cancel_delayed_work calls
in bond_close to flush_delayed_work_sync, which eliminated the above
problem.

	His patch is incorporated, at least in principle, into this
patch.  In this patch, we use cancel_delayed_work_sync in place of
flush_delayed_work_sync, and also convert bond_uninit in addition to
bond_close.

	This conversion to _sync, however, opens new races between
bond_close and three periodically executing workqueue functions:
bond_mii_monitor, bond_alb_monitor and bond_activebackup_arp_mon.

	The race occurs because bond_close and bond_uninit are always
called with RTNL held, and these workqueue functions may acquire RTNL to
perform failover-related activities.  If bond_close or bond_uninit is
waiting in cancel_delayed_work_sync, deadlock occurs.

	These deadlocks are resolved by having the workqueue functions
acquire RTNL conditionally.  If the rtnl_trylock() fails, the functions
reschedule and return immediately.  For the cases that are attempting to
perform link failover, a delay of 1 is used; for the other cases, the
normal interval is used (as those activities are not as time critical).

	Additionally, the bond_mii_monitor function now stores the delay
in a variable (mimicing the structure of activebackup_arp_mon).

	Lastly, all of the above renders the kill_timers sentinel moot,
and therefore it has been removed.

Tested-by: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

---
 drivers/net/bonding/bond_3ad.c  |    8 +---
 drivers/net/bonding/bond_alb.c  |   16 +++----
 drivers/net/bonding/bond_main.c |   96 +++++++++++++++++++++------------------
 drivers/net/bonding/bonding.h   |    1 -
 4 files changed, 61 insertions(+), 60 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index b33c099..0ae0d7c 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2110,9 +2110,6 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 
 	read_lock(&bond->lock);
 
-	if (bond->kill_timers)
-		goto out;
-
 	//check if there are any slaves
 	if (bond->slave_cnt == 0)
 		goto re_arm;
@@ -2161,9 +2158,8 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 	}
 
 re_arm:
-	if (!bond->kill_timers)
-		queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
-out:
+	queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
+
 	read_unlock(&bond->lock);
 }
 
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index d4fbd2e..106b88a 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1343,10 +1343,6 @@ void bond_alb_monitor(struct work_struct *work)
 
 	read_lock(&bond->lock);
 
-	if (bond->kill_timers) {
-		goto out;
-	}
-
 	if (bond->slave_cnt == 0) {
 		bond_info->tx_rebalance_counter = 0;
 		bond_info->lp_counter = 0;
@@ -1401,10 +1397,13 @@ void bond_alb_monitor(struct work_struct *work)
 
 			/*
 			 * dev_set_promiscuity requires rtnl and
-			 * nothing else.
+			 * nothing else.  Avoid race with bond_close.
 			 */
 			read_unlock(&bond->lock);
-			rtnl_lock();
+			if (!rtnl_trylock()) {
+				read_lock(&bond->lock);
+				goto re_arm;
+			}
 
 			bond_info->rlb_promisc_timeout_counter = 0;
 
@@ -1440,9 +1439,8 @@ void bond_alb_monitor(struct work_struct *work)
 	}
 
 re_arm:
-	if (!bond->kill_timers)
-		queue_delayed_work(bond->wq, &bond->alb_work, alb_delta_in_ticks);
-out:
+	queue_delayed_work(bond->wq, &bond->alb_work, alb_delta_in_ticks);
+
 	read_unlock(&bond->lock);
 }
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 71efff3..9931a16 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -774,9 +774,6 @@ static void bond_resend_igmp_join_requests(struct bonding *bond)
 
 	read_lock(&bond->lock);
 
-	if (bond->kill_timers)
-		goto out;
-
 	/* rejoin all groups on bond device */
 	__bond_resend_igmp_join_requests(bond->dev);
 
@@ -790,9 +787,9 @@ static void bond_resend_igmp_join_requests(struct bonding *bond)
 			__bond_resend_igmp_join_requests(vlan_dev);
 	}
 
-	if ((--bond->igmp_retrans > 0) && !bond->kill_timers)
+	if (--bond->igmp_retrans > 0)
 		queue_delayed_work(bond->wq, &bond->mcast_work, HZ/5);
-out:
+
 	read_unlock(&bond->lock);
 }
 
@@ -2518,10 +2515,11 @@ void bond_mii_monitor(struct work_struct *work)
 	struct bonding *bond = container_of(work, struct bonding,
 					    mii_work.work);
 	bool should_notify_peers = false;
+	unsigned long delay;
 
 	read_lock(&bond->lock);
-	if (bond->kill_timers)
-		goto out;
+
+	delay = msecs_to_jiffies(bond->params.miimon);
 
 	if (bond->slave_cnt == 0)
 		goto re_arm;
@@ -2530,7 +2528,15 @@ void bond_mii_monitor(struct work_struct *work)
 
 	if (bond_miimon_inspect(bond)) {
 		read_unlock(&bond->lock);
-		rtnl_lock();
+
+		/* Race avoidance with bond_close cancel of workqueue */
+		if (!rtnl_trylock()) {
+			read_lock(&bond->lock);
+			delay = 1;
+			should_notify_peers = false;
+			goto re_arm;
+		}
+
 		read_lock(&bond->lock);
 
 		bond_miimon_commit(bond);
@@ -2541,14 +2547,18 @@ void bond_mii_monitor(struct work_struct *work)
 	}
 
 re_arm:
-	if (bond->params.miimon && !bond->kill_timers)
-		queue_delayed_work(bond->wq, &bond->mii_work,
-				   msecs_to_jiffies(bond->params.miimon));
-out:
+	if (bond->params.miimon)
+		queue_delayed_work(bond->wq, &bond->mii_work, delay);
+
 	read_unlock(&bond->lock);
 
 	if (should_notify_peers) {
-		rtnl_lock();
+		if (!rtnl_trylock()) {
+			read_lock(&bond->lock);
+			bond->send_peer_notif++;
+			read_unlock(&bond->lock);
+			return;
+		}
 		netdev_bonding_change(bond->dev, NETDEV_NOTIFY_PEERS);
 		rtnl_unlock();
 	}
@@ -2790,9 +2800,6 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 
 	delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
 
-	if (bond->kill_timers)
-		goto out;
-
 	if (bond->slave_cnt == 0)
 		goto re_arm;
 
@@ -2889,9 +2896,9 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 	}
 
 re_arm:
-	if (bond->params.arp_interval && !bond->kill_timers)
+	if (bond->params.arp_interval)
 		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
-out:
+
 	read_unlock(&bond->lock);
 }
 
@@ -3132,9 +3139,6 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 
 	read_lock(&bond->lock);
 
-	if (bond->kill_timers)
-		goto out;
-
 	delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
 
 	if (bond->slave_cnt == 0)
@@ -3144,7 +3148,15 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 
 	if (bond_ab_arp_inspect(bond, delta_in_ticks)) {
 		read_unlock(&bond->lock);
-		rtnl_lock();
+
+		/* Race avoidance with bond_close flush of workqueue */
+		if (!rtnl_trylock()) {
+			read_lock(&bond->lock);
+			delta_in_ticks = 1;
+			should_notify_peers = false;
+			goto re_arm;
+		}
+
 		read_lock(&bond->lock);
 
 		bond_ab_arp_commit(bond, delta_in_ticks);
@@ -3157,13 +3169,18 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 	bond_ab_arp_probe(bond);
 
 re_arm:
-	if (bond->params.arp_interval && !bond->kill_timers)
+	if (bond->params.arp_interval)
 		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
-out:
+
 	read_unlock(&bond->lock);
 
 	if (should_notify_peers) {
-		rtnl_lock();
+		if (!rtnl_trylock()) {
+			read_lock(&bond->lock);
+			bond->send_peer_notif++;
+			read_unlock(&bond->lock);
+			return;
+		}
 		netdev_bonding_change(bond->dev, NETDEV_NOTIFY_PEERS);
 		rtnl_unlock();
 	}
@@ -3425,8 +3442,6 @@ static int bond_open(struct net_device *bond_dev)
 	struct slave *slave;
 	int i;
 
-	bond->kill_timers = 0;
-
 	/* reset slave->backup and slave->inactive */
 	read_lock(&bond->lock);
 	if (bond->slave_cnt > 0) {
@@ -3495,33 +3510,30 @@ static int bond_close(struct net_device *bond_dev)
 
 	bond->send_peer_notif = 0;
 
-	/* signal timers not to re-arm */
-	bond->kill_timers = 1;
-
 	write_unlock_bh(&bond->lock);
 
 	if (bond->params.miimon) {  /* link check interval, in milliseconds. */
-		cancel_delayed_work(&bond->mii_work);
+		cancel_delayed_work_sync(&bond->mii_work);
 	}
 
 	if (bond->params.arp_interval) {  /* arp interval, in milliseconds. */
-		cancel_delayed_work(&bond->arp_work);
+		cancel_delayed_work_sync(&bond->arp_work);
 	}
 
 	switch (bond->params.mode) {
 	case BOND_MODE_8023AD:
-		cancel_delayed_work(&bond->ad_work);
+		cancel_delayed_work_sync(&bond->ad_work);
 		break;
 	case BOND_MODE_TLB:
 	case BOND_MODE_ALB:
-		cancel_delayed_work(&bond->alb_work);
+		cancel_delayed_work_sync(&bond->alb_work);
 		break;
 	default:
 		break;
 	}
 
 	if (delayed_work_pending(&bond->mcast_work))
-		cancel_delayed_work(&bond->mcast_work);
+		cancel_delayed_work_sync(&bond->mcast_work);
 
 	if (bond_is_lb(bond)) {
 		/* Must be called only after all
@@ -4368,26 +4380,22 @@ static void bond_setup(struct net_device *bond_dev)
 
 static void bond_work_cancel_all(struct bonding *bond)
 {
-	write_lock_bh(&bond->lock);
-	bond->kill_timers = 1;
-	write_unlock_bh(&bond->lock);
-
 	if (bond->params.miimon && delayed_work_pending(&bond->mii_work))
-		cancel_delayed_work(&bond->mii_work);
+		cancel_delayed_work_sync(&bond->mii_work);
 
 	if (bond->params.arp_interval && delayed_work_pending(&bond->arp_work))
-		cancel_delayed_work(&bond->arp_work);
+		cancel_delayed_work_sync(&bond->arp_work);
 
 	if (bond->params.mode == BOND_MODE_ALB &&
 	    delayed_work_pending(&bond->alb_work))
-		cancel_delayed_work(&bond->alb_work);
+		cancel_delayed_work_sync(&bond->alb_work);
 
 	if (bond->params.mode == BOND_MODE_8023AD &&
 	    delayed_work_pending(&bond->ad_work))
-		cancel_delayed_work(&bond->ad_work);
+		cancel_delayed_work_sync(&bond->ad_work);
 
 	if (delayed_work_pending(&bond->mcast_work))
-		cancel_delayed_work(&bond->mcast_work);
+		cancel_delayed_work_sync(&bond->mcast_work);
 }
 
 /*
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 82fec5f..1aecc37 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -222,7 +222,6 @@ struct bonding {
 			       struct slave *);
 	rwlock_t lock;
 	rwlock_t curr_slave_lock;
-	s8       kill_timers;
 	u8	 send_peer_notif;
 	s8	 setup_by_slave;
 	s8       igmp_retrans;
-- 
1.7.1
