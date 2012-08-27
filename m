From: Fubo Chen <fubo.chen@gmail.com>
Subject: [PATCH] net: Avoid spinlock recursion
Date: Mon, 27 Aug 2012 14:52:22 +0000
Message-ID: <CAJAFBLCPjjBCmO0vxUeqSKJEkDkuQGF9H9hFRxWgFH92Kpz=VA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:38054 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752218Ab2H0OwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Aug 2012 10:52:23 -0400
Received: by vbbff1 with SMTP id ff1so4408376vbb.19
        for <netdev@vger.kernel.org>; Mon, 27 Aug 2012 07:52:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes a bug introduced by commit 6bdb7fe31046ac50b47e83c35cd6c6b6160a475d.

BUG: spinlock recursion on CPU#2, bash/1952
 lock: 0xffff880036d58b10, .magic: dead4ead, .owner: bash/1952, .owner_cpu: 2
Pid: 1952, comm: bash Tainted: G           O 3.6.0-rc3-debug+ #2
Call Trace:
 <IRQ>  [<ffffffff814ad307>] spin_dump+0x8a/0x8f
 [<ffffffff814ad32d>] spin_bug+0x21/0x26
 [<ffffffff8121c690>] do_raw_spin_lock+0x120/0x140
 [<ffffffff814b2f76>] _raw_spin_lock+0x66/0x80
 [<ffffffff813c45c2>] ? net_rx_action+0xc2/0x280
 [<ffffffff813c45c2>] net_rx_action+0xc2/0x280
 [<ffffffff810982e5>] ? lock_release_holdtime.part.24+0x15/0x1a0
 [<ffffffff81045fe8>] __do_softirq+0xd8/0x290
 [<ffffffff814bd47c>] call_softirq+0x1c/0x26
 <EOI>  [<ffffffff81004105>] do_softirq+0xa5/0xe0
 [<ffffffff813dc7cc>] ? netpoll_poll_dev+0x13c/0x720
 [<ffffffff81045efb>] local_bh_enable+0xeb/0x100
 [<ffffffff813dc7cc>] netpoll_poll_dev+0x13c/0x720
 [<ffffffff813dc771>] ? netpoll_poll_dev+0xe1/0x720
 [<ffffffff813b8418>] ? __alloc_skb+0x88/0x2a0
 [<ffffffff813b83e4>] ? __alloc_skb+0x54/0x2a0
 [<ffffffff813dd07c>] netpoll_send_skb_on_dev+0x2cc/0x380
 [<ffffffff813dd378>] netpoll_send_udp+0x248/0x290
 [<ffffffffa01f4269>] ? write_msg+0x39/0x120 [netconsole]
 [<ffffffffa01f42f3>] write_msg+0xc3/0x120 [netconsole]
 [<ffffffff8103ebf3>] call_console_drivers.constprop.13+0xa3/0x130
 [<ffffffff8103ee74>] console_unlock+0x1f4/0x480
 [<ffffffff8103f3de>] vprintk_emit+0x1ce/0x5c0
 [<ffffffff814a9c8f>] printk+0x4d/0x4f
 [<ffffffff81005591>] printk_address+0x31/0x40
 [<ffffffff810055dc>] print_trace_address+0x3c/0x50
 [<ffffffff81005540>] print_context_stack+0x120/0x140
 [<ffffffff810042bf>] dump_trace+0x17f/0x2c0
 [<ffffffff8100564c>] show_trace_log_lvl+0x5c/0x80
 [<ffffffff810044c6>] show_stack_log_lvl+0xc6/0x1b0
 [<ffffffff810056ac>] show_stack+0x1c/0x20
 [<ffffffff81074c28>] sched_show_task+0x98/0x100
 [<ffffffff81074d33>] show_state_filter+0xa3/0x120
 [<ffffffff81074c90>] ? sched_show_task+0x100/0x100
 [<ffffffff812a55a2>] ? __handle_sysrq+0x32/0x190
 [<ffffffff812a5203>] sysrq_handle_showstate_blocked+0x13/0x20
 [<ffffffff812a5691>] __handle_sysrq+0x121/0x190
 [<ffffffff812a5700>] ? __handle_sysrq+0x190/0x190
 [<ffffffff812a574a>] write_sysrq_trigger+0x4a/0x50
 [<ffffffff811a7016>] proc_reg_write+0x86/0xc0
 [<ffffffff8114fd05>] ? sys_close+0x95/0x100
 [<ffffffff81151dc6>] vfs_write+0xb6/0x180
 [<ffffffff811520ed>] sys_write+0x4d/0x90
 [<ffffffff814bc1a9>] system_call_fastpath+0x16/0x1b

Signed-off-by: Fubo Chen <fubo.chen@gmail.com>
Cc: Cong Wang <amwang@redhat.com>
Cc: David S. Miller <davem@davemloft.net>
---
 net/core/netpoll.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 346b1eb..633e6d9 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -173,12 +173,12 @@ static void poll_napi(struct net_device *dev)
 	list_for_each_entry(napi, &dev->napi_list, dev_list) {
 		local_irq_enable();
 		if (napi->poll_owner != smp_processor_id() &&
-		    spin_trylock(&napi->poll_lock)) {
+		    spin_trylock_bh(&napi->poll_lock)) {
 			rcu_read_lock_bh();
 			budget = poll_one_napi(rcu_dereference_bh(dev->npinfo),
 					       napi, budget);
 			rcu_read_unlock_bh();
-			spin_unlock(&napi->poll_lock);
+			spin_unlock_bh(&napi->poll_lock);

 			if (!budget) {
 				local_irq_disable();
-- 
1.7.7
