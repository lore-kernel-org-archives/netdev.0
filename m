From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH net-next] bonding: take rtnl in bond_loadbalance_arp_mon
Date: Wed, 28 Jul 2010 17:04:36 -0400
Message-ID: <1280351076-19973-1-git-send-email-andy@greyhouse.net>
Cc: fubar@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17393 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755299Ab0G1VC3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jul 2010 17:02:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the latest code in net-next-2.6 the following (and similar) are
spewed when using arp monitoring and balance-alb.

RTNL: assertion failed at drivers/net/bonding/bond_alb.c (1663)
Pid: 1653, comm: bond0 Tainted: G        W   2.6.35-rc1-net-next #9
Call Trace:
 [<ffffffffa0385bb3>] bond_alb_handle_active_change+0x10e/0x17f [bonding]
 [<ffffffffa037f2e4>] bond_change_active_slave+0x20c/0x42f [bonding]
 [<ffffffffa0380062>] ? bond_loadbalance_arp_mon+0x1d8/0x222 [bonding]
 [<ffffffffa037f95a>] bond_select_active_slave+0xe0/0x10e [bonding]
 [<ffffffffa038006a>] bond_loadbalance_arp_mon+0x1e0/0x222 [bonding]
 [<ffffffff81065f7d>] worker_thread+0x26a/0x363
 [<ffffffff81065f25>] ? worker_thread+0x212/0x363
 [<ffffffff81048b19>] ? finish_task_switch+0x70/0xe4
 [<ffffffff81048aa9>] ? finish_task_switch+0x0/0xe4
 [<ffffffffa037fe8a>] ? bond_loadbalance_arp_mon+0x0/0x222 [bonding]
 [<ffffffff8106a45a>] ? autoremove_wake_function+0x0/0x39
 [<ffffffff81065d13>] ? worker_thread+0x0/0x363
 [<ffffffff81069f98>] kthread+0x9a/0xa2
 [<ffffffff8107b4f7>] ? trace_hardirqs_on_caller+0x111/0x135
 [<ffffffff8100aa64>] kernel_thread_helper+0x4/0x10
 [<ffffffff81475e50>] ? restore_args+0x0/0x30
 [<ffffffff81069efe>] ? kthread+0x0/0xa2
 [<ffffffff8100aa60>] ? kernel_thread_helper+0x0/0x10

This is essentially the same thing done in bond_activebackup_arp_mon to
address not holding rtnl when needed.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

---
 drivers/net/bonding/bond_main.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 2cc4cfc..d624cf9 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2857,11 +2857,17 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 	}
 
 	if (do_failover) {
+		read_unlock(&bond->lock);
+		rtnl_lock();
+		read_lock(&bond->lock);
 		write_lock_bh(&bond->curr_slave_lock);
 
 		bond_select_active_slave(bond);
 
 		write_unlock_bh(&bond->curr_slave_lock);
+		read_unlock(&bond->lock);
+		rtnl_unlock();
+		read_lock(&bond->lock);
 	}
 
 re_arm:
-- 
1.7.0.1

