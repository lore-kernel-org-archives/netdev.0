From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [RFC] bonding: fix workqueue re-arming races
Date: Wed, 08 Sep 2010 17:06:31 -0700
Message-ID: <9698.1283990791@death>
References: <20100831170752.GA9743@midget.suse.cz> <20136.1283288063@death> <20100901131626.GA12447@midget.suse.cz> <24764.1283361274@death> <20100901183113.GA25227@midget.suse.cz> <12656.1283371238@death> <20100901205656.GA14982@smudla-wifi.bakulak.kosire.czf> <3617.1283388840@death> <20100902170847.GB8840@midget.suse.cz>
Cc: bonding-devel@lists.sourceforge.net, markine@google.com,
	jarkao2@gmail.com, chavey@google.com, netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:42784 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751225Ab0IIAGj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Sep 2010 20:06:39 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o88NmF5m025629
	for <netdev@vger.kernel.org>; Wed, 8 Sep 2010 19:48:15 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8906bT21896598
	for <netdev@vger.kernel.org>; Wed, 8 Sep 2010 20:06:37 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8906aWZ013293
	for <netdev@vger.kernel.org>; Wed, 8 Sep 2010 20:06:37 -0400
In-reply-to: <20100902170847.GB8840@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Bohac <jbohac@suse.cz> wrote:

>On Wed, Sep 01, 2010 at 05:54:00PM -0700, Jay Vosburgh wrote:
>> Jiri Bohac <jbohac@suse.cz> wrote:
>> 
>> 	In looking at bond_open a bit, I wonder if a contributing factor
>> to the crash (if that's what happens) is that INIT_DELAYED_WORK is being
>> done in bond_open on a work item that's already queued or running (left
>> over from the kill_timers sentinel being missed).  Calling
>> queue_delayed_work when the work item is already queued is ok, I
>> believe, so I don't think that part is an issue (or at least not a
>> panic-worthy one).
>
>Yes, it is the INIT_DELAYED_WORK (zeroes the pending flag), followed by
>queue_delayed_work(). What then happens is
>queue_delayed_work()->queue_delayed_work_on()->BUG_ON(timer_pending(timer));

	Just an update; I'm setting up this patch to give it some
testing.  I've only got one comment so far (below).  

	My current thought after having looked at the code is that this
is getting a little too complicated, so my inclination is to instead
verify that it's permissible (as in, "won't break anything") for the
various commit things to run after bond_close exits and then not worry
about the various sentinels.

	I suspect that if bond_close sets all of the slave->new_link
fields to NOCHANGE, the two commit functions won't do anything.  The
promisc one is probably not a problem here, although I haven't really
looked at it much yet.  It might need to not check for bond_is_lb, so
that the promisc setting doesn't end up orphaned if the mode changes.

>> 	I suspect that the INIT_DELAYED_WORK calls will have to move to
>> bond_create if any of the work items end up be able to run beyond the
>> end of close (which seems likely; I'm running out of ideas).
>
>Yes, with my patch, I have INIT_WORK done in bond_init() for the
>"commit" work items. The re-arming delayed work items now don't
>live after bond_close(), so INIT_DELAYED_WORK can stay on
>bond_open().
>
>> >They are doing "rcnetwork restart", which will do the
>> >close->open. Perhaps all the contention on the rtnl (lots of work
>> >with other network interfaces) makes the race window longer. I
>> >couldn't reproduce this.
>> 
>> 	What actually happens when the failure occurs?  Is there a stack
>> dump?
>
>yes, see above; The stack dump is
>
>[  305.953690] kernel BUG at /usr/src/packages/BUILD/kernel-default-2.6.32.11/linux-2.6.32/kernel/workqueue.c:243!
>[  305.963746] invalid opcode: 0000 [#1] SMP 
>[  305.967849] last sysfs file: /sys/devices/virtual/net/bond1/bonding/slaves
>[  305.974698] CPU 2 
>[  305.976739] Modules linked in: iptable_filter ip_tables x_tables ext2
>nls_iso8859_1 nls_cp437 vfat fat iscsi_tcp libiscsi_tcp libiscsi
>scsi_transport_iscsi iscsi_trgt crc32c ipv6 bonding microcode fuse loop dm_mod
>iTCO_wdt rtc_cmos usb_storage sr_mod ses serio_raw pcspkr dcdbas(X) joydev bnx2
>rtc_core iTCO_vendor_support cdrom enclosure power_meter rtc_lib button sg
>usbhid hid uhci_hcd ehci_hcd usbcore sd_mod crc_t10dif edd ext3 mbcache jbd fan
>processor ide_pci_generic ide_core ata_generic ata_piix libata megaraid_sas
>scsi_mod thermal thermal_sys hwmon
>[  306.026413] Supported: Yes
>[  306.029114] Pid: 8668, comm: bond1 Tainted: G           X 2.6.32.11-0.3-default #1 PowerEdge R910
>[  306.037954] RIP: 0010:[<ffffffff810603a9>]  [<ffffffff810603a9>] queue_delayed_work_on+0xf9/0x100
>[  306.046816] RSP: 0018:ffff880858cb3de0  EFLAGS: 00010286
>[  306.052108] RAX: 0000000000000000 RBX: ffff88085aec8b60 RCX: 0000000000000019
>[  306.059524] RDX: 0000000000000000 RSI: ffff880858f5a8c0 RDI: 00000000ffffffff
>[  306.066635] RBP: ffff88085aec8b60 R08: 0000000000000018 R09: 0000000000000001
>[  306.073746] R10: 0000000000000001 R11: 0000000000000006 R12: ffff880858f5a8c0
>[  306.080856] R13: 00000000ffffffff R14: 0000000000000019 R15: ffff88085c7406a8
>[  306.087967] FS:  0000000000000000(0000) GS:ffff88109c600000(0000) knlGS:0000000000000000
>[  306.096028] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
>[  306.101753] CR2: 0000000000700540 CR3: 0000000001804000 CR4: 00000000000006e0
>[  306.108864] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>[  306.115973] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>[  306.123083] Process bond1 (pid: 8668, threadinfo ffff880858cb2000, task ffff88085c740040)
>[  306.131229] Stack:
>[  306.133232]  ffff88002e41b680 ffff88085aec8b60 ffff88085aec8780 ffff88085aec87ac
>[  306.140462] <0> ffff88085c740040 ffffffffa028d029 0000000000013600 ffff88002e41b680
>[  306.148149] <0> ffffffffa028cf40 ffff880858cb3fd8 ffff88002e41b688 ffffffff8105f558
>[  306.156092] Call Trace:
>[  306.158553]  [<ffffffffa028d029>] bond_mii_monitor+0xe9/0x140 [bonding]
>[  306.165167]  [<ffffffff8105f558>] run_workqueue+0xb8/0x140
>[  306.170638]  [<ffffffff8105f676>] worker_thread+0x96/0x110
>[  306.176110]  [<ffffffff810636f6>] kthread+0x96/0xa0
>[  306.180976]  [<ffffffff81003fba>] child_rip+0xa/0x20
>[  306.185926] Code: 8b 74 24 28 48 89 ef e8 76 7b ff ff e9 7a ff ff ff 44 89
>ee 48 89 ef e8 06 7d ff ff ba 01 00 00 00 90 e9 2c ff ff ff 0f 0b eb fe <0f> 0b
>eb fe 0f 1f 00 48 89 f0 48 8b 35 5e 75 8c 00 48 89 d1 48 
>[  306.205568] RIP  [<ffffffff810603a9>] queue_delayed_work_on+0xf9/0x100
>[  306.212089]  RSP <ffff880858cb3de0>
>
>workqueue.c:243 is the BUG_ON(timer_pending(timer)) inside queue_delayed_work_on() in our kernel.
>
>
>
>This is an updated version of my patch:
>
>- it fixes the issues in bond_alb_promisc_disable()
>
>- it only the original bond->wq workqueue. The second workqueue
>  is indeed not needed.  Thanks to Jarek for pointing that out.
>  It is really safe to call cancel_delayed_work_sync(foo) under
>  rtnl, even if there are work items on the workqueue that hold
>  rtnl. Unless foo grabs rtnl itself, of course.
>
>- it now has three flags that prevent any of the work items from
>  doing unexpected stuff after bond_close():
>  miimon_commit_work_active, ab_arp_commit_work_active and
>  alb_promisc_disable_work_active.
>  
>  bond_close() zeroes them with rtnl held. The work items do
>  everything under rtnl and they check these flags after rtnl is
>  acquired. The only way the "commit" work items queued before a
>  bond_close() might do anything after the bond_close() is when
>  bond_open() is called and it schedules the delayed re-arming
>  work item again.  The re-arming work then tries to queue the
>  "commit" work item which fails, because it is already queued.
>  However, it sets the flag to 1. So the work item queued from before
>  bond_close() would just take over the job the newly queued one
>  was supposed to do.  
>  
>  (In practice, I don't think this can even happen anyway, because the
>  newly scheduled re-arming work item is queued after the
>  "commit" work item on the workqueue. So the "commit" work item
>  will just do nothing and return, and the flag will be set only
>  after that.)
>
>
>Signed-off-by: Jiri Bohac <jbohac@suse.cz>
>
>diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>index 822f586..8015e12 100644
>--- a/drivers/net/bonding/bond_3ad.c
>+++ b/drivers/net/bonding/bond_3ad.c
>@@ -2119,10 +2119,6 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
>
> 	read_lock(&bond->lock);
>
>-	if (bond->kill_timers) {
>-		goto out;
>-	}
>-
> 	//check if there are any slaves
> 	if (bond->slave_cnt == 0) {
> 		goto re_arm;
>@@ -2166,7 +2162,6 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
>
> re_arm:
> 	queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
>-out:
> 	read_unlock(&bond->lock);
> }
>
>diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
>index c746b33..5c9d7ab 100644
>--- a/drivers/net/bonding/bond_alb.c
>+++ b/drivers/net/bonding/bond_alb.c
>@@ -1397,6 +1397,43 @@ out:
> 	return NETDEV_TX_OK;
> }
>
>+void bond_alb_promisc_disable(struct work_struct *work)
>+{
>+	struct bonding *bond = container_of(work, struct bonding,
>+					    alb_promisc_disable_work);
>+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>+	struct net_device *dev = NULL;
>+
>+	/*
>+	 * dev_set_promiscuity requires rtnl and
>+	 * nothing else.
>+	 */
>+	rtnl_lock();
>+	read_lock(&bond->lock);
>+	read_lock(&bond->curr_slave_lock);
>+
>+	if (!bond->alb_promisc_disable_work_active)
>+		goto out;
>+	bond->alb_promisc_disable_work_active = 0;
>+
>+	if (!bond_is_lb(bond))
>+		goto out;
>+	dev = bond->curr_active_slave;
>+	if (!dev)
>+		goto out;
>+
>+	bond_info->primary_is_promisc = 0;
>+	bond_info->rlb_promisc_timeout_counter = 0;
>+
>+out:
>+	read_unlock(&bond->curr_slave_lock);
>+	read_unlock(&bond->lock);
>+	rtnl_unlock();
>+
>+	if (dev)
>+		dev_set_promiscuity(dev, -1);

	This is what I mentioned above: the dev_set_promisc needs to
happen with rtnl held.

>+
> void bond_alb_monitor(struct work_struct *work)
> {
> 	struct bonding *bond = container_of(work, struct bonding,
>@@ -1407,10 +1444,6 @@ void bond_alb_monitor(struct work_struct *work)
>
> 	read_lock(&bond->lock);
>
>-	if (bond->kill_timers) {
>-		goto out;
>-	}
>-
> 	if (bond->slave_cnt == 0) {
> 		bond_info->tx_rebalance_counter = 0;
> 		bond_info->lp_counter = 0;
>@@ -1462,25 +1495,12 @@ void bond_alb_monitor(struct work_struct *work)
> 	if (bond_info->rlb_enabled) {
> 		if (bond_info->primary_is_promisc &&
> 		    (++bond_info->rlb_promisc_timeout_counter >= RLB_PROMISC_TIMEOUT)) {
>-
>-			/*
>-			 * dev_set_promiscuity requires rtnl and
>-			 * nothing else.
>-			 */
>-			read_unlock(&bond->lock);
>-			rtnl_lock();
>-
>-			bond_info->rlb_promisc_timeout_counter = 0;
>-
> 			/* If the primary was set to promiscuous mode
> 			 * because a slave was disabled then
> 			 * it can now leave promiscuous mode.
> 			 */
>-			dev_set_promiscuity(bond->curr_active_slave->dev, -1);
>-			bond_info->primary_is_promisc = 0;
>-
>-			rtnl_unlock();
>-			read_lock(&bond->lock);
>+			queue_work(bond->wq, &bond->alb_promisc_disable_work);
>+			bond->alb_promisc_disable_work_active = 1;
> 		}
>
> 		if (bond_info->rlb_rebalance) {
>@@ -1505,7 +1525,6 @@ void bond_alb_monitor(struct work_struct *work)
>
> re_arm:
> 	queue_delayed_work(bond->wq, &bond->alb_work, alb_delta_in_ticks);
>-out:
> 	read_unlock(&bond->lock);
> }
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 2cc4cfc..f72487a 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -2343,10 +2343,19 @@ static int bond_miimon_inspect(struct bonding *bond)
> 	return commit;
> }
>
>-static void bond_miimon_commit(struct bonding *bond)
>+static void bond_miimon_commit(struct work_struct *work)
> {
> 	struct slave *slave;
> 	int i;
>+	struct bonding *bond = container_of(work, struct bonding,
>+					    miimon_commit_work);
>+
>+	rtnl_lock();
>+	read_lock(&bond->lock);
>+
>+	if (!bond->miimon_commit_work_active)
>+		goto out;
>+	bond->miimon_commit_work_active = 0;
>
> 	bond_for_each_slave(bond, slave, i) {
> 		switch (slave->new_link) {
>@@ -2421,15 +2430,18 @@ static void bond_miimon_commit(struct bonding *bond)
> 		}
>
> do_failover:
>-		ASSERT_RTNL();
> 		write_lock_bh(&bond->curr_slave_lock);
> 		bond_select_active_slave(bond);
> 		write_unlock_bh(&bond->curr_slave_lock);
> 	}
>
> 	bond_set_carrier(bond);
>+out:
>+	read_unlock(&bond->lock);
>+	rtnl_unlock();
> }
>
>+
> /*
>  * bond_mii_monitor
>  *
>@@ -2438,14 +2450,13 @@ do_failover:
>  * an acquisition of appropriate locks followed by a commit phase to
>  * implement whatever link state changes are indicated.
>  */
>+
> void bond_mii_monitor(struct work_struct *work)
> {
> 	struct bonding *bond = container_of(work, struct bonding,
> 					    mii_work.work);
>
> 	read_lock(&bond->lock);
>-	if (bond->kill_timers)
>-		goto out;
>
> 	if (bond->slave_cnt == 0)
> 		goto re_arm;
>@@ -2463,22 +2474,15 @@ void bond_mii_monitor(struct work_struct *work)
> 	}
>
> 	if (bond_miimon_inspect(bond)) {
>-		read_unlock(&bond->lock);
>-		rtnl_lock();
>-		read_lock(&bond->lock);
>-
>-		bond_miimon_commit(bond);
>-
>-		read_unlock(&bond->lock);
>-		rtnl_unlock();	/* might sleep, hold no other locks */
>-		read_lock(&bond->lock);
>+		queue_work(bond->wq, &bond->miimon_commit_work);
>+		bond->miimon_commit_work_active = 1;
> 	}
>
>+
> re_arm:
> 	if (bond->params.miimon)
> 		queue_delayed_work(bond->wq, &bond->mii_work,
> 				   msecs_to_jiffies(bond->params.miimon));
>-out:
> 	read_unlock(&bond->lock);
> }
>
>@@ -2778,9 +2782,6 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
>
> 	delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
>
>-	if (bond->kill_timers)
>-		goto out;
>-
> 	if (bond->slave_cnt == 0)
> 		goto re_arm;
>
>@@ -2867,7 +2868,6 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
> re_arm:
> 	if (bond->params.arp_interval)
> 		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
>-out:
> 	read_unlock(&bond->lock);
> }
>
>@@ -2949,13 +2949,23 @@ static int bond_ab_arp_inspect(struct bonding *bond, int delta_in_ticks)
> /*
>  * Called to commit link state changes noted by inspection step of
>  * active-backup mode ARP monitor.
>- *
>- * Called with RTNL and bond->lock for read.
>  */
>-static void bond_ab_arp_commit(struct bonding *bond, int delta_in_ticks)
>+static void bond_ab_arp_commit(struct work_struct *work)
> {
> 	struct slave *slave;
> 	int i;
>+	int delta_in_ticks;
>+	struct bonding *bond = container_of(work, struct bonding,
>+					    ab_arp_commit_work);
>+
>+	rtnl_lock();
>+	read_lock(&bond->lock);
>+
>+	if (!bond->ab_arp_commit_work_active)
>+		goto out;
>+	bond->ab_arp_commit_work_active = 0;
>+
>+	delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
>
> 	bond_for_each_slave(bond, slave, i) {
> 		switch (slave->new_link) {
>@@ -3014,6 +3024,9 @@ do_failover:
> 	}
>
> 	bond_set_carrier(bond);
>+out:
>+	read_unlock(&bond->lock);
>+	rtnl_unlock();
> }
>
> /*
>@@ -3093,9 +3106,6 @@ void bond_activebackup_arp_mon(struct work_struct *work)
>
> 	read_lock(&bond->lock);
>
>-	if (bond->kill_timers)
>-		goto out;
>-
> 	delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
>
> 	if (bond->slave_cnt == 0)
>@@ -3114,23 +3124,16 @@ void bond_activebackup_arp_mon(struct work_struct *work)
> 	}
>
> 	if (bond_ab_arp_inspect(bond, delta_in_ticks)) {
>-		read_unlock(&bond->lock);
>-		rtnl_lock();
>-		read_lock(&bond->lock);
>-
>-		bond_ab_arp_commit(bond, delta_in_ticks);
>-
>-		read_unlock(&bond->lock);
>-		rtnl_unlock();
>-		read_lock(&bond->lock);
>+		queue_work(bond->wq, &bond->ab_arp_commit_work);
>+		bond->ab_arp_commit_work_active = 1;
> 	}
>
>+
> 	bond_ab_arp_probe(bond);
>
> re_arm:
> 	if (bond->params.arp_interval)
> 		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
>-out:
> 	read_unlock(&bond->lock);
> }
>
>@@ -3720,8 +3723,6 @@ static int bond_open(struct net_device *bond_dev)
> {
> 	struct bonding *bond = netdev_priv(bond_dev);
>
>-	bond->kill_timers = 0;
>-
> 	if (bond_is_lb(bond)) {
> 		/* bond_alb_initialize must be called before the timer
> 		 * is started.
>@@ -3781,31 +3782,31 @@ static int bond_close(struct net_device *bond_dev)
> 	bond->send_grat_arp = 0;
> 	bond->send_unsol_na = 0;
>
>-	/* signal timers not to re-arm */
>-	bond->kill_timers = 1;
>-
> 	write_unlock_bh(&bond->lock);
>
> 	if (bond->params.miimon) {  /* link check interval, in milliseconds. */
>-		cancel_delayed_work(&bond->mii_work);
>+		cancel_delayed_work_sync(&bond->mii_work);
> 	}
>
> 	if (bond->params.arp_interval) {  /* arp interval, in milliseconds. */
>-		cancel_delayed_work(&bond->arp_work);
>+		cancel_delayed_work_sync(&bond->arp_work);
> 	}
>
> 	switch (bond->params.mode) {
> 	case BOND_MODE_8023AD:
>-		cancel_delayed_work(&bond->ad_work);
>+		cancel_delayed_work_sync(&bond->ad_work);
> 		break;
> 	case BOND_MODE_TLB:
> 	case BOND_MODE_ALB:
>-		cancel_delayed_work(&bond->alb_work);
>+		cancel_delayed_work_sync(&bond->alb_work);
> 		break;
> 	default:
> 		break;
> 	}
>
>+	bond->miimon_commit_work_active = 0;
>+	bond->ab_arp_commit_work_active = 0;
>+	bond->alb_promisc_disable_work_active = 0;
>
> 	if (bond_is_lb(bond)) {
> 		/* Must be called only after all
>@@ -4660,23 +4661,19 @@ static void bond_setup(struct net_device *bond_dev)
>
> static void bond_work_cancel_all(struct bonding *bond)
> {
>-	write_lock_bh(&bond->lock);
>-	bond->kill_timers = 1;
>-	write_unlock_bh(&bond->lock);
>-
> 	if (bond->params.miimon && delayed_work_pending(&bond->mii_work))
>-		cancel_delayed_work(&bond->mii_work);
>+		cancel_delayed_work_sync(&bond->mii_work);
>
> 	if (bond->params.arp_interval && delayed_work_pending(&bond->arp_work))
>-		cancel_delayed_work(&bond->arp_work);
>+		cancel_delayed_work_sync(&bond->arp_work);
>
> 	if (bond->params.mode == BOND_MODE_ALB &&
> 	    delayed_work_pending(&bond->alb_work))
>-		cancel_delayed_work(&bond->alb_work);
>+		cancel_delayed_work_sync(&bond->alb_work);
>
> 	if (bond->params.mode == BOND_MODE_8023AD &&
> 	    delayed_work_pending(&bond->ad_work))
>-		cancel_delayed_work(&bond->ad_work);
>+		cancel_delayed_work_sync(&bond->ad_work);
> }
>
> /*
>@@ -5094,6 +5091,9 @@ static int bond_init(struct net_device *bond_dev)
> 	bond_prepare_sysfs_group(bond);
>
> 	__hw_addr_init(&bond->mc_list);
>+	INIT_WORK(&bond->miimon_commit_work, bond_miimon_commit);
>+	INIT_WORK(&bond->ab_arp_commit_work, bond_ab_arp_commit);
>+	INIT_WORK(&bond->alb_promisc_disable_work, bond_alb_promisc_disable);
> 	return 0;
> }
>
>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>index c6fdd85..e771f5d 100644
>--- a/drivers/net/bonding/bonding.h
>+++ b/drivers/net/bonding/bonding.h
>@@ -198,7 +198,6 @@ struct bonding {
> 	s32      slave_cnt; /* never change this value outside the attach/detach wrappers */
> 	rwlock_t lock;
> 	rwlock_t curr_slave_lock;
>-	s8       kill_timers;
> 	s8	 send_grat_arp;
> 	s8	 send_unsol_na;
> 	s8	 setup_by_slave;
>@@ -223,6 +222,12 @@ struct bonding {
> 	struct   delayed_work arp_work;
> 	struct   delayed_work alb_work;
> 	struct   delayed_work ad_work;
>+	struct   work_struct miimon_commit_work;
>+	int	 miimon_commit_work_active;
>+	struct   work_struct ab_arp_commit_work;
>+	int	 ab_arp_commit_work_active;
>+	struct   work_struct alb_promisc_disable_work;
>+	int	 alb_promisc_disable_work_active;
> #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> 	struct   in6_addr master_ipv6;
> #endif
>@@ -348,6 +353,7 @@ void bond_select_active_slave(struct bonding *bond);
> void bond_change_active_slave(struct bonding *bond, struct slave *new_active);
> void bond_register_arp(struct bonding *);
> void bond_unregister_arp(struct bonding *);
>+void bond_alb_promisc_disable(struct work_struct *work);
>
> struct bond_net {
> 	struct net *		net;	/* Associated network namespace */
>
>-- 
>Jiri Bohac <jbohac@suse.cz>
>SUSE Labs, SUSE CZ

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
