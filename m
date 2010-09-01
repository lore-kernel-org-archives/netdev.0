From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [RFC] bonding: fix workqueue re-arming races
Date: Wed, 1 Sep 2010 15:16:26 +0200
Message-ID: <20100901131626.GA12447@midget.suse.cz>
References: <20100831170752.GA9743@midget.suse.cz>
 <20136.1283288063@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Bohac <jbohac@suse.cz>, bonding-devel@lists.sourceforge.net,
	markine@google.com, jarkao2@gmail.com, chavey@google.com,
	netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:47817 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753217Ab0IANOz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Sep 2010 09:14:55 -0400
Content-Disposition: inline
In-Reply-To: <20136.1283288063@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 31, 2010 at 01:54:23PM -0700, Jay Vosburgh wrote:
> Jiri Bohac <jbohac@suse.cz> wrote:
> >[note, this does not deal with bond_loadbalance_arp_mon(), where
> >rtnl is now taken as well in net-next; I'll do this if you think
> >the idea is good ]
> 
> 	I don't believe the loadbalance_arp_mon acquires RTNL in
> net-next.  I recall discussing this with Andy not too long ago, but I
> didn't think that change went in, and I don't see it in the tree.

Of course, you are right, I misread the e-mail thread and did not look at
the code.

> >+void bond_alb_promisc_disable(struct work_struct *work)
> >+{
> >+	struct bonding *bond = container_of(work, struct bonding,
> >+					    alb_promisc_disable_work);
> >+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
> >+
> >+	/*
> >+	 * dev_set_promiscuity requires rtnl and
> >+	 * nothing else.
> >+	 */
> >+	rtnl_lock();
> >+	dev_set_promiscuity(bond->curr_active_slave->dev, -1);
> >+	bond_info->primary_is_promisc = 0;
> >+	bond_info->rlb_promisc_timeout_counter = 0;
> >+	rtnl_unlock();
> >+}
> 
> 	What prevents this from deadlocking such that cpu A is in
> bond_close, holding RTNL and in cancel_delayed_work_sync, while cpu B is
> in the above function, trying to acquire RTNL?

The main idea of the patch is to move the code (the "commit"
functions) that needs rtnl to another work item. Then
cancel_delayed_work_sync() can be used to cancel the re-arming
work. But you are absolutely right, there is still a deadlock,
since I queue the "commit" work on the same workqueue. So when
cancel_delayed_work_sync() waits for the re-arming work to
finish, it can wait forever because a previously queued "commit"
work is waiting for rtnl.

The solution is to move the "commit" work items to a different
workqueue. Fixed in the new version of the patch below
(bond->wq_rtnl).

> 	Also, assuming for the moment that the above isn't a problem,
> curr_active_slave may be NULL if the last slave is removed between the
> time bond_alb_promisc_disable is scheduled and when it runs.  I'm not
> sure that the alb_bond_info can be guaranteed to be valid, either, if
> the mode changed.

Yes, there may be problems like these, but these are present
already in the current code. Because bond->lock() is released
before rtnl is taken. 

Sure, it would be good to deal with these problems, but I don't
think this patch introduces new races like these. They are
already there ... (see below)

> > void bond_alb_monitor(struct work_struct *work)
> > {
> > 	struct bonding *bond = container_of(work, struct bonding,
> >@@ -1407,10 +1424,6 @@ void bond_alb_monitor(struct work_struct *work)
> >
> > 	read_lock(&bond->lock);
> >
> >-	if (bond->kill_timers) {
> >-		goto out;
> >-	}
> >-
> > 	if (bond->slave_cnt == 0) {
> > 		bond_info->tx_rebalance_counter = 0;
> > 		bond_info->lp_counter = 0;
> >@@ -1462,25 +1475,11 @@ void bond_alb_monitor(struct work_struct *work)
> > 	if (bond_info->rlb_enabled) {
> > 		if (bond_info->primary_is_promisc &&
> > 		    (++bond_info->rlb_promisc_timeout_counter >= RLB_PROMISC_TIMEOUT)) {
> >-
> >-			/*
> >-			 * dev_set_promiscuity requires rtnl and
> >-			 * nothing else.
> >-			 */
> >-			read_unlock(&bond->lock);

... e.g. here; the current slave may change/disappear, the mode
may change .... 

> >-			rtnl_lock();
> >-
> >-			bond_info->rlb_promisc_timeout_counter = 0;
> >-

I fixed both issues in this new version of the patch.

Signed-off-by: Jiri Bohac <jbohac@suse.cz>


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
index c746b33..e4fa3a5 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1397,6 +1397,35 @@ out:
 	return NETDEV_TX_OK;
 }
 
+void bond_alb_promisc_disable(struct work_struct *work)
+{
+	struct bonding *bond = container_of(work, struct bonding,
+					    alb_promisc_disable_work);
+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
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
+	if (!bond->curr_active_slave)
+		goto out;
+
+	dev_set_promiscuity(bond->curr_active_slave->dev, -1);
+	bond_info->primary_is_promisc = 0;
+	bond_info->rlb_promisc_timeout_counter = 0;
+
+out:
+	read_unlock(&bond->curr_slave_lock);
+	read_unlock(&bond->lock);
+	rtnl_unlock();
+}
+
 void bond_alb_monitor(struct work_struct *work)
 {
 	struct bonding *bond = container_of(work, struct bonding,
@@ -1407,10 +1436,6 @@ void bond_alb_monitor(struct work_struct *work)
 
 	read_lock(&bond->lock);
 
-	if (bond->kill_timers) {
-		goto out;
-	}
-
 	if (bond->slave_cnt == 0) {
 		bond_info->tx_rebalance_counter = 0;
 		bond_info->lp_counter = 0;
@@ -1462,25 +1487,11 @@ void bond_alb_monitor(struct work_struct *work)
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
+			queue_work(bond->wq_rtnl, &bond->alb_promisc_disable_work);
 		}
 
 		if (bond_info->rlb_rebalance) {
@@ -1505,7 +1516,6 @@ void bond_alb_monitor(struct work_struct *work)
 
 re_arm:
 	queue_delayed_work(bond->wq, &bond->alb_work, alb_delta_in_ticks);
-out:
 	read_unlock(&bond->lock);
 }
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 2cc4cfc..aae2864 100644
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
@@ -2421,15 +2426,18 @@ static void bond_miimon_commit(struct bonding *bond)
 		}
 
 do_failover:
-		ASSERT_RTNL();
 		write_lock_bh(&bond->curr_slave_lock);
 		bond_select_active_slave(bond);
 		write_unlock_bh(&bond->curr_slave_lock);
 	}
 
 	bond_set_carrier(bond);
+
+	read_unlock(&bond->lock);
+	rtnl_unlock();
 }
 
+
 /*
  * bond_mii_monitor
  *
@@ -2438,14 +2446,13 @@ do_failover:
  * an acquisition of appropriate locks followed by a commit phase to
  * implement whatever link state changes are indicated.
  */
+
 void bond_mii_monitor(struct work_struct *work)
 {
 	struct bonding *bond = container_of(work, struct bonding,
 					    mii_work.work);
 
 	read_lock(&bond->lock);
-	if (bond->kill_timers)
-		goto out;
 
 	if (bond->slave_cnt == 0)
 		goto re_arm;
@@ -2462,23 +2469,14 @@ void bond_mii_monitor(struct work_struct *work)
 		read_unlock(&bond->curr_slave_lock);
 	}
 
-	if (bond_miimon_inspect(bond)) {
-		read_unlock(&bond->lock);
-		rtnl_lock();
-		read_lock(&bond->lock);
+	if (bond_miimon_inspect(bond))
+		queue_work(bond->wq_rtnl, &bond->miimon_commit_work);
 
-		bond_miimon_commit(bond);
-
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
 
@@ -2778,9 +2776,6 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 
 	delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
 
-	if (bond->kill_timers)
-		goto out;
-
 	if (bond->slave_cnt == 0)
 		goto re_arm;
 
@@ -2867,7 +2862,6 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 re_arm:
 	if (bond->params.arp_interval)
 		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
-out:
 	read_unlock(&bond->lock);
 }
 
@@ -2949,13 +2943,19 @@ static int bond_ab_arp_inspect(struct bonding *bond, int delta_in_ticks)
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
@@ -3014,6 +3014,9 @@ do_failover:
 	}
 
 	bond_set_carrier(bond);
+
+	read_unlock(&bond->lock);
+	rtnl_unlock();
 }
 
 /*
@@ -3093,9 +3096,6 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 
 	read_lock(&bond->lock);
 
-	if (bond->kill_timers)
-		goto out;
-
 	delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
 
 	if (bond->slave_cnt == 0)
@@ -3113,24 +3113,15 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 		read_unlock(&bond->curr_slave_lock);
 	}
 
-	if (bond_ab_arp_inspect(bond, delta_in_ticks)) {
-		read_unlock(&bond->lock);
-		rtnl_lock();
-		read_lock(&bond->lock);
+	if (bond_ab_arp_inspect(bond, delta_in_ticks))
+		queue_work(bond->wq_rtnl, &bond->ab_arp_commit_work);
 
-		bond_ab_arp_commit(bond, delta_in_ticks);
-
-		read_unlock(&bond->lock);
-		rtnl_unlock();
-		read_lock(&bond->lock);
-	}
 
 	bond_ab_arp_probe(bond);
 
 re_arm:
 	if (bond->params.arp_interval)
 		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
-out:
 	read_unlock(&bond->lock);
 }
 
@@ -3720,8 +3711,6 @@ static int bond_open(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 
-	bond->kill_timers = 0;
-
 	if (bond_is_lb(bond)) {
 		/* bond_alb_initialize must be called before the timer
 		 * is started.
@@ -3781,26 +3770,23 @@ static int bond_close(struct net_device *bond_dev)
 	bond->send_grat_arp = 0;
 	bond->send_unsol_na = 0;
 
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
@@ -4601,6 +4587,8 @@ static void bond_destructor(struct net_device *bond_dev)
 	struct bonding *bond = netdev_priv(bond_dev);
 	if (bond->wq)
 		destroy_workqueue(bond->wq);
+	if (bond->wq_rtnl)
+		destroy_workqueue(bond->wq_rtnl);
 	free_netdev(bond_dev);
 }
 
@@ -4660,23 +4648,19 @@ static void bond_setup(struct net_device *bond_dev)
 
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
@@ -5083,6 +5067,12 @@ static int bond_init(struct net_device *bond_dev)
 	bond->wq = create_singlethread_workqueue(bond_dev->name);
 	if (!bond->wq)
 		return -ENOMEM;
+	bond->wq_rtnl = create_singlethread_workqueue(bond_dev->name);
+	if (!bond->wq_rtnl) {
+		destroy_workqueue(bond->wq);
+		bond->wq = NULL;
+		return -ENOMEM;
+	}
 
 	bond_set_lockdep_class(bond_dev);
 
@@ -5094,6 +5084,9 @@ static int bond_init(struct net_device *bond_dev)
 	bond_prepare_sysfs_group(bond);
 
 	__hw_addr_init(&bond->mc_list);
+	INIT_WORK(&bond->miimon_commit_work, bond_miimon_commit);
+	INIT_WORK(&bond->ab_arp_commit_work, bond_ab_arp_commit);
+	INIT_WORK(&bond->alb_promisc_disable_work, bond_alb_promisc_disable);
 	return 0;
 }
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index c6fdd85..43ba807 100644
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
@@ -219,10 +218,14 @@ struct bonding {
 	struct   vlan_group *vlgrp;
 	struct   packet_type arp_mon_pt;
 	struct   workqueue_struct *wq;
+	struct   workqueue_struct *wq_rtnl;
 	struct   delayed_work mii_work;
 	struct   delayed_work arp_work;
 	struct   delayed_work alb_work;
 	struct   delayed_work ad_work;
+	struct    work_struct miimon_commit_work;
+	struct    work_struct ab_arp_commit_work;
+	struct    work_struct alb_promisc_disable_work;
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	struct   in6_addr master_ipv6;
 #endif
@@ -348,6 +351,7 @@ void bond_select_active_slave(struct bonding *bond);
 void bond_change_active_slave(struct bonding *bond, struct slave *new_active);
 void bond_register_arp(struct bonding *);
 void bond_unregister_arp(struct bonding *);
+void bond_alb_promisc_disable(struct work_struct *work);
 
 struct bond_net {
 	struct net *		net;	/* Associated network namespace */

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

