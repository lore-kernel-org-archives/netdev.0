From: akpm@osdl.org
Subject: [patch 1/9] bonding: lockdep annotation
Date: Fri, 20 Oct 2006 14:43:00 -0700
Message-ID: <200610202143.k9KLh0WO003758@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, a.p.zijlstra@chello.nl,
	mingo@elte.hu, shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:43396 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030355AbWJTVna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 17:43:30 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

=============================================
[ INFO: possible recursive locking detected ]
2.6.17-1.2600.fc6 #1
---------------------------------------------
ifconfig/2411 is trying to acquire lock:
 (&dev->_xmit_lock){-...}, at: [<ffffffff80429b9f>] dev_mc_add+0x45/0x15f

but task is already holding lock:
 (&dev->_xmit_lock){-...}, at: [<ffffffff80429b9f>] dev_mc_add+0x45/0x15f

other info that might help us debug this:
3 locks held by ifconfig/2411:
 #0:  (rtnl_mutex){--..}, at: [<ffffffff802664af>] mutex_lock+0x2a/0x2e
 #1:  (&dev->_xmit_lock){-...}, at: [<ffffffff80429b9f>] dev_mc_add+0x45/0x15f
 #2:  (&bond->lock){-.-+}, at: [<ffffffff8831b7f7>] bond_set_multicast_list+0x2c/0x26a [bonding]

stack backtrace:

Call Trace:
 [<ffffffff8026e97d>] show_trace+0xae/0x319
 [<ffffffff8026ebfd>] dump_stack+0x15/0x17
 [<ffffffff802a839b>] __lock_acquire+0x135/0xa64
 [<ffffffff802a926d>] lock_acquire+0x4b/0x69
 [<ffffffff80267981>] _spin_lock_bh+0x2a/0x36
 [<ffffffff80429b9f>] dev_mc_add+0x45/0x15f
 [<ffffffff8831b903>] :bonding:bond_set_multicast_list+0x138/0x26a
 [<ffffffff80429901>] __dev_mc_upload+0x22/0x24
 [<ffffffff80429c74>] dev_mc_add+0x11a/0x15f
 [<ffffffff8045d154>] igmp_group_added+0x55/0x10f
 [<ffffffff8045d4ab>] ip_mc_inc_group+0x1d6/0x21a
 [<ffffffff8045d535>] ip_mc_up+0x46/0x61
 [<ffffffff804594b8>] inetdev_init+0x11c/0x136
 [<ffffffff8045a0b7>] devinet_ioctl+0x3eb/0x5e9
 [<ffffffff8045a56c>] inet_ioctl+0x71/0x8f
 [<ffffffff8041ed74>] sock_ioctl+0x1e8/0x20a
 [<ffffffff80243ae0>] do_ioctl+0x2a/0x77
 [<ffffffff802325cc>] vfs_ioctl+0x25a/0x277
 [<ffffffff8024ea4b>] sys_ioctl+0x5f/0x82
 [<ffffffff8026060e>] system_call+0x7e/0x83

The bonding driver nests other drivers, give the bonding driver its own
lock class.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Acked-by: Ingo Molnar <mingo@elte.hu>
Cc: Stephen Hemminger <shemminger@osdl.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/bonding/bond_main.c |    5 +++++
 1 files changed, 5 insertions(+)

diff -puN drivers/net/bonding/bond_main.c~bonding-lockdep-annotation drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c~bonding-lockdep-annotation
+++ a/drivers/net/bonding/bond_main.c
@@ -4692,6 +4692,8 @@ static int bond_check_params(struct bond
 	return 0;
 }
 
+static struct lock_class_key bonding_netdev_xmit_lock_key;
+
 /* Create a new bond based on the specified name and bonding parameters.
  * Caller must NOT hold rtnl_lock; we need to release it here before we
  * set up our sysfs entries.
@@ -4727,6 +4729,9 @@ int bond_create(char *name, struct bond_
 	if (res < 0) {
 		goto out_bond;
 	}
+
+	lockdep_set_class(&bond_dev->_xmit_lock, &bonding_netdev_xmit_lock_key);
+
 	if (newbond)
 		*newbond = bond_dev->priv;
 
_
