From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [RFC] bonding: fix workqueue re-arming races
Date: Thu, 16 Sep 2010 15:44:33 -0700
Message-ID: <25924.1284677073@death>
References: <20100831170752.GA9743@midget.suse.cz> <20136.1283288063@death> <20100901131626.GA12447@midget.suse.cz> <24764.1283361274@death> <20100901183113.GA25227@midget.suse.cz> <12656.1283371238@death> <20100901205656.GA14982@smudla-wifi.bakulak.kosire.czf> <3617.1283388840@death> <20100902170847.GB8840@midget.suse.cz> <9698.1283990791@death>
Cc: bonding-devel@lists.sourceforge.net, markine@google.com,
	jarkao2@gmail.com, chavey@google.com, netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:50514 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752950Ab0IPWoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 18:44:38 -0400
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e36.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8GMedpV001901
	for <netdev@vger.kernel.org>; Thu, 16 Sep 2010 16:40:39 -0600
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8GMib33212002
	for <netdev@vger.kernel.org>; Thu, 16 Sep 2010 16:44:37 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8GMiaEg006851
	for <netdev@vger.kernel.org>; Thu, 16 Sep 2010 16:44:37 -0600
In-reply-to: <9698.1283990791@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh <fubar@us.ibm.com> wrote:

>Jiri Bohac <jbohac@suse.cz> wrote:
>
>>On Wed, Sep 01, 2010 at 05:54:00PM -0700, Jay Vosburgh wrote:
>>> Jiri Bohac <jbohac@suse.cz> wrote:
>>> 
>>> 	In looking at bond_open a bit, I wonder if a contributing factor
>>> to the crash (if that's what happens) is that INIT_DELAYED_WORK is being
>>> done in bond_open on a work item that's already queued or running (left
>>> over from the kill_timers sentinel being missed).  Calling
>>> queue_delayed_work when the work item is already queued is ok, I
>>> believe, so I don't think that part is an issue (or at least not a
>>> panic-worthy one).
>>
>>Yes, it is the INIT_DELAYED_WORK (zeroes the pending flag), followed by
>>queue_delayed_work(). What then happens is
>>queue_delayed_work()->queue_delayed_work_on()->BUG_ON(timer_pending(timer));
>
>	Just an update; I'm setting up this patch to give it some
>testing.  I've only got one comment so far (below).  
>
>	My current thought after having looked at the code is that this
>is getting a little too complicated, so my inclination is to instead
>verify that it's permissible (as in, "won't break anything") for the
>various commit things to run after bond_close exits and then not worry
>about the various sentinels.
>
>	I suspect that if bond_close sets all of the slave->new_link
>fields to NOCHANGE, the two commit functions won't do anything.  The
>promisc one is probably not a problem here, although I haven't really
>looked at it much yet.  It might need to not check for bond_is_lb, so
>that the promisc setting doesn't end up orphaned if the mode changes.
[...]

	I had some time to work on this, and I fixed a few nits in the
most recent patch, and also modified it as I describe above (the
new_link business).  This seems to do the right thing for the mii/arp
commit functions.

	The alb_promisc alb_promisc function, however, still has a race.
The curr_active_slave could change between the time the function is
scheduled and when it executes.  That window is pretty small, but does
exist.  Losing the race means that some interface stays promisc when it
shouldn't; I don't believe it will panic.  Fixing that is probably a
matter of stashing a pointer to the slave to be de-promisc-ified
somewhere, but that stash would have to be handled if the slave were to
be removed from the bond.

	I've tested this a bit, and it seems ok, but I can't reproduce
the original problem, so I'm not entirely sure this doesn't break
something very subtle.

	Also, I'll be out of the office for the next two weeks, so I
won't get back to this until I return.  If any interested parties could
test this out and provide some feedback before then, it would be
appreciated.

	-J



diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 822f586..8015e12 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2119,10 +2119,6 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 
 	read_lock(&bond->lock);
 
-	if (bond->kill_timers) {
-		goto out;
-	}
-
 	//check if there are any slaves
 	if (bond->slave_cnt == 0) {
 		goto re_arm;
@@ -2166,7 +2162,6 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 
 re_arm:
 	queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
-out:
 	read_unlock(&bond->lock);
 }
 
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index c746b33..8242ee2 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1397,6 +1397,40 @@ out:
 	return NETDEV_TX_OK;
 }
 
+void bond_alb_promisc_disable(struct work_struct *work)
+{
+	struct bonding *bond = container_of(work, struct bonding,
+					    alb_promisc_disable_work);
+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
+	struct net_device *dev = NULL;
+
+	/*
+	 * dev_set_promiscuity requires rtnl and
+	 * nothing else.
+	 */
+	rtnl_lock();
+	read_lock(&bond->lock);
+	read_lock(&bond->curr_slave_lock);
+
+	if (!bond_is_lb(bond))
+		goto out;
+	if (bond->curr_active_slave)
+		dev = bond->curr_active_slave->dev;
+	if (!dev)
+		goto out;
+
+	bond_info->primary_is_promisc = 0;
+	bond_info->rlb_promisc_timeout_counter = 0;
+
+out:
+	read_unlock(&bond->curr_slave_lock);
+	read_unlock(&bond->lock);
+	if (dev)
+		dev_set_promiscuity(dev, -1);
+
+	rtnl_unlock();
+}
+
 void bond_alb_monitor(struct work_struct *work)
 {
 	struct bonding *bond = container_of(work, struct bonding,
@@ -1407,10 +1441,6 @@ void bond_alb_monitor(struct work_struct *work)
 
 	read_lock(&bond->lock);
 
-	if (bond->kill_timers) {
-		goto out;
-	}
-
 	if (bond->slave_cnt == 0) {
 		bond_info->tx_rebalance_counter = 0;
 		bond_info->lp_counter = 0;
@@ -1462,25 +1492,11 @@ void bond_alb_monitor(struct work_struct *work)
 	if (bond_info->rlb_enabled) {
 		if (bond_info->primary_is_promisc &&
 		    (++bond_info->rlb_promisc_timeout_counter >= RLB_PROMISC_TIMEOUT)) {
-
-			/*
-			 * dev_set_promiscuity requires rtnl and
-			 * nothing else.
-			 */
-			read_unlock(&bond->lock);
-			rtnl_lock();
-
-			bond_info->rlb_promisc_timeout_counter = 0;
-
 			/* If the primary was set to promiscuous mode
 			 * because a slave was disabled then
 			 * it can now leave promiscuous mode.
 			 */
-			dev_set_promiscuity(bond->curr_active_slave->dev, -1);
-			bond_info->primary_is_promisc = 0;
-
-			rtnl_unlock();
-			read_lock(&bond->lock);
+			queue_work(bond->wq, &bond->alb_promisc_disable_work);
 		}
 
 		if (bond_info->rlb_rebalance) {
@@ -1505,7 +1521,6 @@ void bond_alb_monitor(struct work_struct *work)
 
 re_arm:
 	queue_delayed_work(bond->wq, &bond->alb_work, alb_delta_in_ticks);
-out:
 	read_unlock(&bond->lock);
 }
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 2cc4cfc..0ad562b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2343,10 +2343,15 @@ static int bond_miimon_inspect(struct bonding *bond)
 	return commit;
 }
 
-static void bond_miimon_commit(struct bonding *bond)
+static void bond_miimon_commit(struct work_struct *work)
 {
 	struct slave *slave;
 	int i;
+	struct bonding *bond = container_of(work, struct bonding,
+					    miimon_commit_work);
+
+	rtnl_lock();
+	read_lock(&bond->lock);
 
 	bond_for_each_slave(bond, slave, i) {
 		switch (slave->new_link) {
@@ -2421,13 +2426,14 @@ static void bond_miimon_commit(struct bonding *bond)
 		}
 
 do_failover:
-		ASSERT_RTNL();
 		write_lock_bh(&bond->curr_slave_lock);
 		bond_select_active_slave(bond);
 		write_unlock_bh(&bond->curr_slave_lock);
 	}
 
 	bond_set_carrier(bond);
+	read_unlock(&bond->lock);
+	rtnl_unlock();
 }
 
 /*
@@ -2444,8 +2450,6 @@ void bond_mii_monitor(struct work_struct *work)
 					    mii_work.work);
 
 	read_lock(&bond->lock);
-	if (bond->kill_timers)
-		goto out;
 
 	if (bond->slave_cnt == 0)
 		goto re_arm;
@@ -2462,23 +2466,14 @@ void bond_mii_monitor(struct work_struct *work)
 		read_unlock(&bond->curr_slave_lock);
 	}
 
-	if (bond_miimon_inspect(bond)) {
-		read_unlock(&bond->lock);
-		rtnl_lock();
-		read_lock(&bond->lock);
-
-		bond_miimon_commit(bond);
+	if (bond_miimon_inspect(bond))
+		queue_work(bond->wq, &bond->miimon_commit_work);
 
-		read_unlock(&bond->lock);
-		rtnl_unlock();	/* might sleep, hold no other locks */
-		read_lock(&bond->lock);
-	}
 
 re_arm:
 	if (bond->params.miimon)
 		queue_delayed_work(bond->wq, &bond->mii_work,
 				   msecs_to_jiffies(bond->params.miimon));
-out:
 	read_unlock(&bond->lock);
 }
 
@@ -2778,9 +2773,6 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 
 	delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
 
-	if (bond->kill_timers)
-		goto out;
-
 	if (bond->slave_cnt == 0)
 		goto re_arm;
 
@@ -2867,7 +2859,6 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 re_arm:
 	if (bond->params.arp_interval)
 		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
-out:
 	read_unlock(&bond->lock);
 }
 
@@ -2949,13 +2940,19 @@ static int bond_ab_arp_inspect(struct bonding *bond, int delta_in_ticks)
 /*
  * Called to commit link state changes noted by inspection step of
  * active-backup mode ARP monitor.
- *
- * Called with RTNL and bond->lock for read.
  */
-static void bond_ab_arp_commit(struct bonding *bond, int delta_in_ticks)
+static void bond_ab_arp_commit(struct work_struct *work)
 {
 	struct slave *slave;
 	int i;
+	int delta_in_ticks;
+	struct bonding *bond = container_of(work, struct bonding,
+					    ab_arp_commit_work);
+
+	rtnl_lock();
+	read_lock(&bond->lock);
+
+	delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
 
 	bond_for_each_slave(bond, slave, i) {
 		switch (slave->new_link) {
@@ -3014,6 +3011,8 @@ do_failover:
 	}
 
 	bond_set_carrier(bond);
+	read_unlock(&bond->lock);
+	rtnl_unlock();
 }
 
 /*
@@ -3093,9 +3092,6 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 
 	read_lock(&bond->lock);
 
-	if (bond->kill_timers)
-		goto out;
-
 	delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
 
 	if (bond->slave_cnt == 0)
@@ -3113,24 +3109,14 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 		read_unlock(&bond->curr_slave_lock);
 	}
 
-	if (bond_ab_arp_inspect(bond, delta_in_ticks)) {
-		read_unlock(&bond->lock);
-		rtnl_lock();
-		read_lock(&bond->lock);
-
-		bond_ab_arp_commit(bond, delta_in_ticks);
-
-		read_unlock(&bond->lock);
-		rtnl_unlock();
-		read_lock(&bond->lock);
-	}
+	if (bond_ab_arp_inspect(bond, delta_in_ticks))
+		queue_work(bond->wq, &bond->ab_arp_commit_work);
 
 	bond_ab_arp_probe(bond);
 
 re_arm:
 	if (bond->params.arp_interval)
 		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
-out:
 	read_unlock(&bond->lock);
 }
 
@@ -3720,8 +3706,6 @@ static int bond_open(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 
-	bond->kill_timers = 0;
-
 	if (bond_is_lb(bond)) {
 		/* bond_alb_initialize must be called before the timer
 		 * is started.
@@ -3767,6 +3751,8 @@ static int bond_open(struct net_device *bond_dev)
 static int bond_close(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
+	struct slave *slave;
+	int i;
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		/* Unregister the receive of LACPDUs */
@@ -3781,32 +3767,36 @@ static int bond_close(struct net_device *bond_dev)
 	bond->send_grat_arp = 0;
 	bond->send_unsol_na = 0;
 
-	/* signal timers not to re-arm */
-	bond->kill_timers = 1;
+	/* There's a race between close and the rearming timers over RNTL,
+	 * so any RTNL-needing work is done as a separate work item.
+	 * Here, we arrange for the monitor commit functions to do nothing
+	 * should they happen to run after bond_close.
+	 */
+	bond_for_each_slave(bond, slave, i)
+		slave->new_link = BOND_LINK_NOCHANGE;
 
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
 
-
 	if (bond_is_lb(bond)) {
 		/* Must be called only after all
 		 * slaves have been released
@@ -4660,23 +4650,19 @@ static void bond_setup(struct net_device *bond_dev)
 
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
 }
 
 /*
@@ -5094,6 +5080,9 @@ static int bond_init(struct net_device *bond_dev)
 	bond_prepare_sysfs_group(bond);
 
 	__hw_addr_init(&bond->mc_list);
+	INIT_WORK(&bond->miimon_commit_work, bond_miimon_commit);
+	INIT_WORK(&bond->ab_arp_commit_work, bond_ab_arp_commit);
+	INIT_WORK(&bond->alb_promisc_disable_work, bond_alb_promisc_disable);
 	return 0;
 }
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index c6fdd85..ddf3a94 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -198,7 +198,6 @@ struct bonding {
 	s32      slave_cnt; /* never change this value outside the attach/detach wrappers */
 	rwlock_t lock;
 	rwlock_t curr_slave_lock;
-	s8       kill_timers;
 	s8	 send_grat_arp;
 	s8	 send_unsol_na;
 	s8	 setup_by_slave;
@@ -223,6 +222,9 @@ struct bonding {
 	struct   delayed_work arp_work;
 	struct   delayed_work alb_work;
 	struct   delayed_work ad_work;
+	struct   work_struct miimon_commit_work;
+	struct   work_struct ab_arp_commit_work;
+	struct   work_struct alb_promisc_disable_work;
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	struct   in6_addr master_ipv6;
 #endif
@@ -348,6 +350,7 @@ void bond_select_active_slave(struct bonding *bond);
 void bond_change_active_slave(struct bonding *bond, struct slave *new_active);
 void bond_register_arp(struct bonding *);
 void bond_unregister_arp(struct bonding *);
+void bond_alb_promisc_disable(struct work_struct *work);
 
 struct bond_net {
 	struct net *		net;	/* Associated network namespace */


---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
