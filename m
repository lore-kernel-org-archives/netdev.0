From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH 2/2] tipc: avoid possible deadlock while remove disc_timeout()
Date: Thu, 8 Aug 2013 18:45:19 +0800
Message-ID: <520376BF.7080906@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:24217 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757726Ab3HHKph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 06:45:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We met lockdep warning when enable and disable the bearer for commands such as:

tipc-config -netid=1234 -addr=1.1.3 -be=eth:eth0
tipc-config -netid=1234 -addr=1.1.3 -bd=eth:eth0

[  327.693472]
[  327.693595] ======================================================
[  327.693994] [ INFO: possible circular locking dependency detected ]
[  327.694519] 3.11.0-rc3-wwd-default #4 Tainted: G           O
[  327.694882] -------------------------------------------------------
[  327.695385] tipc-config/5825 is trying to acquire lock:
[  327.695754]  (((timer))#2){+.-...}, at: [<ffffffff8105be80>] del_timer_sync+0x0/0xd0
[  327.696018]
[  327.696018] but task is already holding lock:
[  327.696018]  (&(&b_ptr->lock)->rlock){+.-...}, at: [<ffffffffa02be58d>] bearer_disable+0xdd/0x120 [tipc]
[  327.696018]
[  327.696018] which lock already depends on the new lock.
[  327.696018]
[  327.696018]
[  327.696018] the existing dependency chain (in reverse order) is:
[  327.696018]
[  327.696018] -> #1 (&(&b_ptr->lock)->rlock){+.-...}:
[  327.696018]        [<ffffffff810b3b4d>] validate_chain+0x6dd/0x870
[  327.696018]        [<ffffffff810b40bb>] __lock_acquire+0x3db/0x670
[  327.696018]        [<ffffffff810b4453>] lock_acquire+0x103/0x130
[  327.696018]        [<ffffffff814d65b1>] _raw_spin_lock_bh+0x41/0x80
[  327.696018]        [<ffffffffa02c5d48>] disc_timeout+0x18/0xd0 [tipc]
[  327.696018]        [<ffffffff8105b92a>] call_timer_fn+0xda/0x1e0
[  327.696018]        [<ffffffff8105bcd7>] run_timer_softirq+0x2a7/0x2d0
[  327.696018]        [<ffffffff8105379a>] __do_softirq+0x16a/0x2e0
[  327.696018]        [<ffffffff81053a35>] irq_exit+0xd5/0xe0
[  327.696018]        [<ffffffff81033005>] smp_apic_timer_interrupt+0x45/0x60
[  327.696018]        [<ffffffff814df4af>] apic_timer_interrupt+0x6f/0x80
[  327.696018]        [<ffffffff8100b70e>] arch_cpu_idle+0x1e/0x30
[  327.696018]        [<ffffffff810a039d>] cpu_idle_loop+0x1fd/0x280
[  327.696018]        [<ffffffff810a043e>] cpu_startup_entry+0x1e/0x20
[  327.696018]        [<ffffffff81031589>] start_secondary+0x89/0x90
[  327.696018]
[  327.696018] -> #0 (((timer))#2){+.-...}:
[  327.696018]        [<ffffffff810b33fe>] check_prev_add+0x43e/0x4b0
[  327.696018]        [<ffffffff810b3b4d>] validate_chain+0x6dd/0x870
[  327.696018]        [<ffffffff810b40bb>] __lock_acquire+0x3db/0x670
[  327.696018]        [<ffffffff810b4453>] lock_acquire+0x103/0x130
[  327.696018]        [<ffffffff8105bebd>] del_timer_sync+0x3d/0xd0
[  327.696018]        [<ffffffffa02c5855>] tipc_disc_delete+0x15/0x30 [tipc]
[  327.696018]        [<ffffffffa02be59f>] bearer_disable+0xef/0x120 [tipc]
[  327.696018]        [<ffffffffa02be74f>] tipc_disable_bearer+0x2f/0x60 [tipc]
[  327.696018]        [<ffffffffa02bfb32>] tipc_cfg_do_cmd+0x2e2/0x550 [tipc]
[  327.696018]        [<ffffffffa02c8c79>] handle_cmd+0x49/0xe0 [tipc]
[  327.696018]        [<ffffffff8143e898>] genl_family_rcv_msg+0x268/0x340
[  327.696018]        [<ffffffff8143ed30>] genl_rcv_msg+0x70/0xd0
[  327.696018]        [<ffffffff8143d4c9>] netlink_rcv_skb+0x89/0xb0
[  327.696018]        [<ffffffff8143e617>] genl_rcv+0x27/0x40
[  327.696018]        [<ffffffff8143d21e>] netlink_unicast+0x15e/0x1b0
[  327.696018]        [<ffffffff8143ddcf>] netlink_sendmsg+0x22f/0x400
[  327.696018]        [<ffffffff813f7836>] __sock_sendmsg+0x66/0x80
[  327.696018]        [<ffffffff813f7957>] sock_aio_write+0x107/0x120
[  327.696018]        [<ffffffff8117f76d>] do_sync_write+0x7d/0xc0
[  327.696018]        [<ffffffff8117fc56>] vfs_write+0x186/0x190
[  327.696018]        [<ffffffff811803e0>] SyS_write+0x60/0xb0
[  327.696018]        [<ffffffff814de852>] system_call_fastpath+0x16/0x1b
[  327.696018]
[  327.696018] other info that might help us debug this:
[  327.696018]
[  327.696018]  Possible unsafe locking scenario:
[  327.696018]
[  327.696018]        CPU0                    CPU1
[  327.696018]        ----                    ----
[  327.696018]   lock(&(&b_ptr->lock)->rlock);
[  327.696018]                                lock(((timer))#2);
[  327.696018]                                lock(&(&b_ptr->lock)->rlock);
[  327.696018]   lock(((timer))#2);
[  327.696018]
[  327.696018]  *** DEADLOCK ***
[  327.696018]
[  327.696018] 5 locks held by tipc-config/5825:
[  327.696018]  #0:  (cb_lock){++++++}, at: [<ffffffff8143e608>] genl_rcv+0x18/0x40
[  327.696018]  #1:  (genl_mutex){+.+.+.}, at: [<ffffffff8143ed66>] genl_rcv_msg+0xa6/0xd0
[  327.696018]  #2:  (config_mutex){+.+.+.}, at: [<ffffffffa02bf889>] tipc_cfg_do_cmd+0x39/0x550 [tipc]
[  327.696018]  #3:  (tipc_net_lock){++.-..}, at: [<ffffffffa02be738>] tipc_disable_bearer+0x18/0x60 [tipc]
[  327.696018]  #4:  (&(&b_ptr->lock)->rlock){+.-...}, at: [<ffffffffa02be58d>] bearer_disable+0xdd/0x120 [tipc]
[  327.696018]
[  327.696018] stack backtrace:
[  327.696018] CPU: 2 PID: 5825 Comm: tipc-config Tainted: G           O 3.11.0-rc3-wwd-default #4
[  327.696018] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  327.696018]  00000000ffffffff ffff880037fa77a8 ffffffff814d03dd 0000000000000000
[  327.696018]  ffff880037fa7808 ffff880037fa77e8 ffffffff810b1c4f 0000000037fa77e8
[  327.696018]  ffff880037fa7808 ffff880037e4db40 0000000000000000 ffff880037e4e318
[  327.696018] Call Trace:
[  327.696018]  [<ffffffff814d03dd>] dump_stack+0x4d/0xa0
[  327.696018]  [<ffffffff810b1c4f>] print_circular_bug+0x10f/0x120
[  327.696018]  [<ffffffff810b33fe>] check_prev_add+0x43e/0x4b0
[  327.696018]  [<ffffffff810b3b4d>] validate_chain+0x6dd/0x870
[  327.696018]  [<ffffffff81087a28>] ? sched_clock_cpu+0xd8/0x110
[  327.696018]  [<ffffffff810b40bb>] __lock_acquire+0x3db/0x670
[  327.696018]  [<ffffffff810b4453>] lock_acquire+0x103/0x130
[  327.696018]  [<ffffffff8105be80>] ? try_to_del_timer_sync+0x70/0x70
[  327.696018]  [<ffffffff8105bebd>] del_timer_sync+0x3d/0xd0
[  327.696018]  [<ffffffff8105be80>] ? try_to_del_timer_sync+0x70/0x70
[  327.696018]  [<ffffffffa02c5855>] tipc_disc_delete+0x15/0x30 [tipc]
[  327.696018]  [<ffffffffa02be59f>] bearer_disable+0xef/0x120 [tipc]
[  327.696018]  [<ffffffffa02be74f>] tipc_disable_bearer+0x2f/0x60 [tipc]
[  327.696018]  [<ffffffffa02bfb32>] tipc_cfg_do_cmd+0x2e2/0x550 [tipc]
[  327.696018]  [<ffffffff81218783>] ? security_capable+0x13/0x20
[  327.696018]  [<ffffffffa02c8c79>] handle_cmd+0x49/0xe0 [tipc]
[  327.696018]  [<ffffffff8143e898>] genl_family_rcv_msg+0x268/0x340
[  327.696018]  [<ffffffff8143ed30>] genl_rcv_msg+0x70/0xd0
[  327.696018]  [<ffffffff8143ecc0>] ? genl_lock+0x20/0x20
[  327.696018]  [<ffffffff8143d4c9>] netlink_rcv_skb+0x89/0xb0
[  327.696018]  [<ffffffff8143e608>] ? genl_rcv+0x18/0x40
[  327.696018]  [<ffffffff8143e617>] genl_rcv+0x27/0x40
[  327.696018]  [<ffffffff8143d21e>] netlink_unicast+0x15e/0x1b0
[  327.696018]  [<ffffffff81289d7c>] ? memcpy_fromiovec+0x6c/0x90
[  327.696018]  [<ffffffff8143ddcf>] netlink_sendmsg+0x22f/0x400
[  327.696018]  [<ffffffff813f7836>] __sock_sendmsg+0x66/0x80
[  327.696018]  [<ffffffff813f7957>] sock_aio_write+0x107/0x120
[  327.696018]  [<ffffffff813fe29c>] ? release_sock+0x8c/0xa0
[  327.696018]  [<ffffffff8117f76d>] do_sync_write+0x7d/0xc0
[  327.696018]  [<ffffffff8117fa24>] ? rw_verify_area+0x54/0x100
[  327.696018]  [<ffffffff8117fc56>] vfs_write+0x186/0x190
[  327.696018]  [<ffffffff811803e0>] SyS_write+0x60/0xb0
[  327.696018]  [<ffffffff814de852>] system_call_fastpath+0x16/0x1b

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 net/tipc/bearer.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 7687211..9dc8c84 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -461,22 +461,22 @@ static void bearer_disable(struct tipc_bearer *b_ptr)
 	struct tipc_link *l_ptr;
 	struct tipc_link *temp_l_ptr;
 	struct list_head list;
+	struct tipc_link_req *temp_req;
 
 	pr_info("Disabling bearer <%s>\n", b_ptr->name);
 	spin_lock_bh(&b_ptr->lock);
 	b_ptr->blocked = 1;
 	b_ptr->media->disable_bearer(b_ptr);
 	list_replace_init(&b_ptr->links, &list);
+	temp_req = b_ptr->link_req;
 	spin_unlock_bh(&b_ptr->lock);
 
 	list_for_each_entry_safe(l_ptr, temp_l_ptr, &list, link_list) {
 		tipc_link_delete(l_ptr);
 	}
 
-	spin_lock_bh(&b_ptr->lock);
-	if (b_ptr->link_req)
-		tipc_disc_delete(b_ptr->link_req);
-	spin_unlock_bh(&b_ptr->lock);
+	if (temp_req)
+		tipc_disc_delete(temp_req);
 	memset(b_ptr, 0, sizeof(struct tipc_bearer));
 }
 
-- 
1.8.2.1
