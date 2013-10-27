From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v2 0/5] bonding: patchset for rcu use in bonding
Date: Sun, 27 Oct 2013 23:53:17 +0100
Message-ID: <20131027225317.GB11209@redhat.com>
References: <52688F33.30904@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21908 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753397Ab3J0Wzk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Oct 2013 18:55:40 -0400
Content-Disposition: inline
In-Reply-To: <52688F33.30904@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 24, 2013 at 11:08:35AM +0800, Ding Tianhong wrote:
>Hi:
>
>The slave list will add and del by bond_master_upper_dev_link() and bond_upper_dev_unlink(),
>which will call call_netdevice_notifiers(), even it is safe to call it in write bond lock now,
>but we can't sure that whether it is safe later, because other drivers may deal NETDEV_CHANGEUPPER
>in sleep way, so I didn't admit move the bond_upper_dev_unlink() in write bond lock.
>
>now the bond_for_each_slave only protect by rtnl_lock(), maybe use bond_for_each_slave_rcu is a good
>way to protect slave list for bond, but as a system slow path, it is no need to transform bond_for_each_slave()
>to bond_for_each_slave_rcu() in slow path, so in the patchset, I will remove the unused read bond lock
>for monitor function, maybe it is a better way, I will wait to accept any relay for it.
>
>Thanks for the Veaceslav Falico opinion.
>
>v2: add and modify commit for patchset and patch, it will be the first step for the whole patchset.
>
>Ding Tianhong (5):
>  bonding: remove bond read lock for bond_mii_monitor()
>  bonding: remove bond read lock for bond_alb_monitor()
>  bonding: remove bond read lock for bond_loadbalance_arp_mon()
>  bonding: remove bond read lock for bond_activebackup_arp_mon()

This patch introduces a regression by boot-test with active backup mode:

bond_activebackup_arp_mon() is already not holding the bond->lock, however
it might call bond_change_active_slave(), which does (in case of new_active):

  912                         write_unlock_bh(&bond->curr_slave_lock);
  913                         read_unlock(&bond->lock);
  914 
  915                         call_netdevice_notifiers(NETDEV_BONDING_FAILOVER, bond->dev);
  916                         if (should_notify_peers)
  917                                 call_netdevice_notifiers(NETDEV_NOTIFY_PEERS,
  918                                                          bond->dev);
  919 
  920                         read_lock(&bond->lock);
  921                         write_lock_bh(&bond->curr_slave_lock);

so it drops the bond->lock (which wasn't taken previously), and then takes
it (without anyone dropping it afterwards).

I don't know how to fix it - cause a lot of other callers already take it,
and we can't just drop them (we'd race), and we can't remove it here (cause
we can't call notifiers while atomic).

Which begs the question - was this patchset tested at all?

[   21.796823] =====================================
[   21.796823] [ BUG: bad unlock balance detected! ]
[   21.796823] 3.12.0-rc6+ #305 Tainted: G          I 
[   21.796823] -------------------------------------
[   21.796823] kworker/u8:5/59 is trying to release lock (&bond->lock) at:
[   21.796823] [<ffffffffa00b6c38>] bond_change_active_slave+0x2c8/0x390 [bonding]
[   21.796823] but there are no more locks to release!
[   21.796823] 
[   21.796823] other info that might help us debug this:
[   21.796823] 3 locks held by kworker/u8:5/59:
[   21.796823]  #0:  (%s#4){.+.+..}, at: [<ffffffff810cfeb9>] process_one_work+0x189/0x580
[   21.796823]  #1:  ((&(&bond->arp_work)->work)){+.+...}, at: [<ffffffff810cfeb9>] process_one_work+0x189/0x580
[   21.796823]  #2:  (rtnl_mutex){+.+.+.}, at: [<ffffffff8169ea05>] rtnl_trylock+0x15/0x20
[   21.796823] 
[   21.796823] stack backtrace:
[   21.796823] CPU: 0 PID: 59 Comm: kworker/u8:5 Tainted: G          I  3.12.0-rc6+ #305
[   21.796823] Hardware name: Hewlett-Packard HP xw4600 Workstation/0AA0h, BIOS 786F3 v01.15 08/28/2008
[   21.796823] Workqueue: bond0 bond_activebackup_arp_mon [bonding]
[   21.796823]  ffffffffa00b6c38 ffff880079ecdae8 ffffffff817aa048 0000000000000002
[   21.796823]  ffff880079ec4b40 ffff880079ecdb18 ffffffff81129af9 00000000001d5400
[   21.796823]  ffff880079ec4b40 ffff880078a36c88 ffff880079ec5440 ffff880079ecdba8
[   21.796823] Call Trace:
[   21.796823]  [<ffffffffa00b6c38>] ? bond_change_active_slave+0x2c8/0x390 [bonding]
[   21.796823]  [<ffffffff817aa048>] dump_stack+0x59/0x81
[   21.796823]  [<ffffffff81129af9>] print_unlock_imbalance_bug+0xf9/0x100
[   21.796823]  [<ffffffff8112d67f>] lock_release_non_nested+0x26f/0x3f0
[   21.796823]  [<ffffffff810f3aa8>] ? sched_clock_cpu+0xb8/0x120
[   21.796823]  [<ffffffffa00b6c38>] ? bond_change_active_slave+0x2c8/0x390 [bonding]
[   21.796823]  [<ffffffffa00b6c38>] ? bond_change_active_slave+0x2c8/0x390 [bonding]
[   21.796823]  [<ffffffff8112d892>] __lock_release+0x92/0x1b0
[   21.796823]  [<ffffffffa00b6c38>] ? bond_change_active_slave+0x2c8/0x390 [bonding]
[   21.796823]  [<ffffffff8112da0b>] lock_release+0x5b/0x130
[   21.796823]  [<ffffffff817b0553>] _raw_read_unlock+0x23/0x50
[   21.796823]  [<ffffffffa00b6c38>] bond_change_active_slave+0x2c8/0x390 [bonding]
[   21.796823]  [<ffffffffa00b6df7>] bond_select_active_slave+0xf7/0x1d0 [bonding]
[   21.796823]  [<ffffffffa00b7006>] bond_ab_arp_commit+0x136/0x200 [bonding]
[   21.796823]  [<ffffffffa00b9dd8>] bond_activebackup_arp_mon+0xc8/0xd0 [bonding]
[   21.796823]  [<ffffffff810cff2a>] process_one_work+0x1fa/0x580
[   21.796823]  [<ffffffff810cfeb9>] ? process_one_work+0x189/0x580
[   21.796823]  [<ffffffff810d231f>] worker_thread+0x11f/0x3a0
[   21.796823]  [<ffffffff810d2200>] ? manage_workers+0x170/0x170
[   21.796823]  [<ffffffff810dbdfe>] kthread+0xee/0x100
[   21.796823]  [<ffffffff8112d93b>] ? __lock_release+0x13b/0x1b0
[   21.796823]  [<ffffffff810dbd10>] ? __init_kthread_worker+0x70/0x70
[   21.796823]  [<ffffffff817ba3ec>] ret_from_fork+0x7c/0xb0
[   21.796823]  [<ffffffff810dbd10>] ? __init_kthread_worker+0x70/0x70


>  bonding: remove bond read lock for bond_3ad_state_machine_handler()
>
> drivers/net/bonding/bond_3ad.c  |   9 ++--
> drivers/net/bonding/bond_alb.c  |  20 ++------
> drivers/net/bonding/bond_main.c | 100 +++++++++++++---------------------------
> 3 files changed, 40 insertions(+), 89 deletions(-)
>
>-- 
>1.8.2.1
>
>
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
