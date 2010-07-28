From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next] bonding: take rtnl in bond_loadbalance_arp_mon
Date: Wed, 28 Jul 2010 14:39:49 -0700
Message-ID: <29111.1280353189@death>
References: <1280351076-19973-1-git-send-email-andy@greyhouse.net>
Cc: netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:56399 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755378Ab0G1Vjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jul 2010 17:39:54 -0400
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6SLZDjx032411
	for <netdev@vger.kernel.org>; Wed, 28 Jul 2010 15:35:13 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6SLdqIp125940
	for <netdev@vger.kernel.org>; Wed, 28 Jul 2010 15:39:52 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6SLdpY1006152
	for <netdev@vger.kernel.org>; Wed, 28 Jul 2010 15:39:52 -0600
In-reply-to: <1280351076-19973-1-git-send-email-andy@greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek <andy@greyhouse.net> wrote:

>With the latest code in net-next-2.6 the following (and similar) are
>spewed when using arp monitoring and balance-alb.

	Does the ARP monitor function correctly for balance-alb?  My
recollection is that the ARP monitor probes interfere with the tailored
ARP messages that balance-alb sends.  The bond_check_params function
disallows setting arp_interval (it forces miimon on).  I suspect this
nuance was missed when setting up the sysfs code, but if it does work,
then perhaps it is too strict.

	As I recall, I had deliberately left acquiring rtnl out of the
loadbalance_arp_mon function, since none of the modes that used it
required rtnl for failover.

	-J

>RTNL: assertion failed at drivers/net/bonding/bond_alb.c (1663)
>Pid: 1653, comm: bond0 Tainted: G        W   2.6.35-rc1-net-next #9
>Call Trace:
> [<ffffffffa0385bb3>] bond_alb_handle_active_change+0x10e/0x17f [bonding]
> [<ffffffffa037f2e4>] bond_change_active_slave+0x20c/0x42f [bonding]
> [<ffffffffa0380062>] ? bond_loadbalance_arp_mon+0x1d8/0x222 [bonding]
> [<ffffffffa037f95a>] bond_select_active_slave+0xe0/0x10e [bonding]
> [<ffffffffa038006a>] bond_loadbalance_arp_mon+0x1e0/0x222 [bonding]
> [<ffffffff81065f7d>] worker_thread+0x26a/0x363
> [<ffffffff81065f25>] ? worker_thread+0x212/0x363
> [<ffffffff81048b19>] ? finish_task_switch+0x70/0xe4
> [<ffffffff81048aa9>] ? finish_task_switch+0x0/0xe4
> [<ffffffffa037fe8a>] ? bond_loadbalance_arp_mon+0x0/0x222 [bonding]
> [<ffffffff8106a45a>] ? autoremove_wake_function+0x0/0x39
> [<ffffffff81065d13>] ? worker_thread+0x0/0x363
> [<ffffffff81069f98>] kthread+0x9a/0xa2
> [<ffffffff8107b4f7>] ? trace_hardirqs_on_caller+0x111/0x135
> [<ffffffff8100aa64>] kernel_thread_helper+0x4/0x10
> [<ffffffff81475e50>] ? restore_args+0x0/0x30
> [<ffffffff81069efe>] ? kthread+0x0/0xa2
> [<ffffffff8100aa60>] ? kernel_thread_helper+0x0/0x10
>
>This is essentially the same thing done in bond_activebackup_arp_mon to
>address not holding rtnl when needed.
>
>Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
>
>---
> drivers/net/bonding/bond_main.c |    6 ++++++
> 1 files changed, 6 insertions(+), 0 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 2cc4cfc..d624cf9 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -2857,11 +2857,17 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
> 	}
>
> 	if (do_failover) {
>+		read_unlock(&bond->lock);
>+		rtnl_lock();
>+		read_lock(&bond->lock);
> 		write_lock_bh(&bond->curr_slave_lock);
>
> 		bond_select_active_slave(bond);
>
> 		write_unlock_bh(&bond->curr_slave_lock);
>+		read_unlock(&bond->lock);
>+		rtnl_unlock();
>+		read_lock(&bond->lock);
> 	}
>
> re_arm:
>-- 
>1.7.0.1
>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
