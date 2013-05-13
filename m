From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net/802/mrp: fix lockdep splat
Date: Mon, 13 May 2013 05:24:11 -0700
Message-ID: <1368447851.13473.119.camel@edumazet-glaptop>
References: <6901a7785249816fe13a98e3c0b35127@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: hayeswang <hayeswang@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>,
	Cong Wang <amwang@redhat.com>,
	David Ward <david.ward@ll.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:49789 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751583Ab3EMMYO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 May 2013 08:24:14 -0400
Received: by mail-pd0-f170.google.com with SMTP id 10so4384455pdi.1
        for <netdev@vger.kernel.org>; Mon, 13 May 2013 05:24:14 -0700 (PDT)
In-Reply-To: <6901a7785249816fe13a98e3c0b35127@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On Mon, 2013-05-13 at 14:59 +0300, Denys Fedoryshchenko wrote:
> Hi
> 
> Noticed on 32-builds of my systems that r8169 is not working anymore at 
> all.
> Problem started to occur somewhere after 3.6 kernels, but it is 
> difficult to try other kernels on this semi-embedded system, and i am 
> not completely sure about that.
> Once i used another OS build, but 64-bit build with same latest kernel, 
> and it worked.
> It spits netdev watchdog timeouts, and constantly shows interface coming 
> up.
> 
> Here is max debug output(dmesg) i got, with some inline comments:

> 
> Here i am trying to remove module
> 
> [   19.735147] =================================
> [   19.735235] [ INFO: inconsistent lock state ]
> [   19.735324] 3.9.2-build-0063 #4 Not tainted
> [   19.735412] ---------------------------------
> [   19.735500] inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
> [   19.735592] rmmod/1840 [HC0[0]:SC0[0]:HE1:SE1] takes:
> [   19.735682]  (&(&app->lock)->rlock#2){+.?...}, at: [<f862bb5b>] 
> mrp_uninit_applicant+0x69/0xba [mrp]
> [   19.735932] {IN-SOFTIRQ-W} state was registered at:
> [   19.736002]   [<c01611d8>] __lock_acquire+0x284/0xd52
> [   19.736002]   [<c0162068>] lock_acquire+0x71/0x85
> [   19.736002]   [<c03e4ad5>] _raw_spin_lock+0x33/0x40
> [   19.736002]   [<f862b5dc>] mrp_join_timer+0x11/0x3d [mrp]
> [   19.736002]   [<c0136102>] call_timer_fn+0x69/0xdc
> [   19.736002]   [<c01362e6>] run_timer_softirq+0x171/0x1ab
> [   19.736002]   [<c0131963>] __do_softirq+0x98/0x153
> [   19.736002]   [<c0131afa>] irq_exit+0x47/0x82
> [   19.736002]   [<c011c274>] smp_apic_timer_interrupt+0x64/0x71
> [   19.736002]   [<c03e5616>] apic_timer_interrupt+0x32/0x38
> [   19.736002]   [<c010902c>] cpu_idle+0x55/0x6f
> [   19.736002]   [<c03d7d19>] rest_init+0xa1/0xa7
> [   19.736002]   [<c057792f>] start_kernel+0x300/0x307
> [   19.736002]   [<c05772a3>] i386_start_kernel+0x79/0x7d
> [   19.736002] irq event stamp: 4379
> [   19.736002] hardirqs last  enabled at (4379): [<c03e50bb>] 
> _raw_spin_unlock_irqrestore+0x36/0x3c
> [   19.736002] hardirqs last disabled at (4378): [<c03e4b92>] 
> _raw_spin_lock_irqsave+0x16/0x50
> [   19.736002] softirqs last  enabled at (4342): [<c0379c22>] 
> neigh_ifdown+0x95/0xb5
> [   19.736002] softirqs last disabled at (4340): [<c03e4cc9>] 
> _raw_write_lock_bh+0xe/0x45
> [   19.736002]
> [   19.736002] other info that might help us debug this:
> [   19.736002]  Possible unsafe locking scenario:
> [   19.736002]
> [   19.736002]        CPU0
> [   19.736002]        ----
> [   19.736002]   lock(&(&app->lock)->rlock#2);
> [   19.736002]   <Interrupt>
> [   19.736002]     lock(&(&app->lock)->rlock#2);
> [   19.736002]
> [   19.736002]  *** DEADLOCK ***
> [   19.736002]
> [   19.736002] 3 locks held by rmmod/1840:
> [   19.736002]  #0:  (&__lockdep_no_validate__){......}, at: 
> [<c02c195c>] device_lock+0xd/0xf
> [   19.736002]  #1:  (&__lockdep_no_validate__){......}, at: 
> [<c02c195c>] device_lock+0xd/0xf
> [   19.736002]  #2:  (rtnl_mutex){+.+.+.}, at: [<c037d71b>] 
> rtnl_lock+0xf/0x11
> [   19.736002]
> [   19.736002] stack backtrace:
> [   19.736002] Pid: 1840, comm: rmmod Not tainted 3.9.2-build-0063 #4
> [   19.736002] Call Trace:
> [   19.736002]  [<c0160d8e>] valid_state+0x1f6/0x201
> [   19.736002]  [<c0160e6a>] mark_lock+0xd1/0x1bb
> [   19.736002]  [<c01606b1>] ? check_usage_forwards+0x77/0x77
> [   19.736002]  [<c016124c>] __lock_acquire+0x2f8/0xd52
> [   19.736002]  [<c0160d00>] ? valid_state+0x168/0x201
> [   19.736002]  [<c0160dbf>] ? mark_lock+0x26/0x1bb
> [   19.736002]  [<c016230e>] ? mark_held_locks+0x5d/0x7b
> [   19.736002]  [<c03e50bb>] ? _raw_spin_unlock_irqrestore+0x36/0x3c
> [   19.736002]  [<c0162068>] lock_acquire+0x71/0x85
> [   19.736002]  [<f862bb5b>] ? mrp_uninit_applicant+0x69/0xba [mrp]
> [   19.736002]  [<c03e4ad5>] _raw_spin_lock+0x33/0x40
> [   19.736002]  [<f862bb5b>] ? mrp_uninit_applicant+0x69/0xba [mrp]
> [   19.736002]  [<f862bb5b>] mrp_uninit_applicant+0x69/0xba [mrp]
> [   19.736002]  [<c0172e67>] ? kfree_call_rcu+0x17/0x19
> [   19.736002]  [<f8647bf6>] vlan_mvrp_uninit_applicant+0xd/0xf [8021q]
> [   19.736002]  [<f8646198>] unregister_vlan_dev+0xb8/0xe2 [8021q]
> [   19.736002]  [<c03d1ae8>] ? packet_mm_close+0x1f/0x1f
> [   19.736002]  [<f86464c9>] vlan_device_event+0x307/0x35a [8021q]
> [   19.736002]  [<c03d1ce7>] ? rcu_read_unlock+0x17/0x19
> [   19.736002]  [<c0146215>] notifier_call_chain+0x26/0x48
> [   19.736002]  [<c0146283>] raw_notifier_call_chain+0x1a/0x1c
> [   19.736002]  [<c0370310>] call_netdevice_notifiers+0x44/0x4b
> [   19.736002]  [<c0370604>] rollback_registered_many+0xe2/0x185
> [   19.736002]  [<c037070d>] rollback_registered+0x1f/0x2c
> [   19.736002]  [<c0370777>] unregister_netdevice_queue+0x5d/0x87
> [   19.736002]  [<c03e3464>] ? mutex_lock_nested+0x20/0x22
> [   19.736002]  [<c037d71b>] ? rtnl_lock+0xf/0x11
> [   19.736002]  [<c0370851>] unregister_netdev+0x18/0x1f
> [   19.736002]  [<f85cb017>] rtl_remove_one+0x7f/0xf9 [r8169]
> [   19.736002]  [<c02c9117>] ? __pm_runtime_resume+0x48/0x50
> [   19.736002]  [<c026cea9>] pci_device_remove+0x27/0x76
> [   19.736002]  [<c02c1b70>] __device_release_driver+0x66/0xaa
> [   19.736002]  [<c02c20a3>] driver_detach+0x62/0x83
> [   19.736002]  [<c02c1919>] bus_remove_driver+0x69/0x88
> [   19.736002]  [<c02c23be>] driver_unregister+0x53/0x5a
> [   19.736002]  [<c016243a>] ? trace_hardirqs_on_caller+0x10e/0x13f
> [   19.736002]  [<c026cf87>] pci_unregister_driver+0x10/0x5a
> [   19.736002]  [<f85cd8fb>] rtl8169_pci_driver_exit+0xd/0xf [r8169]
> [   19.736002]  [<c01688cf>] sys_delete_module+0x175/0x1c1
> [   19.736002]  [<c03e5367>] ? restore_all+0xf/0xf
> [   19.736002]  [<c03e5334>] syscall_call+0x7/0xb

Thanks for the report. Could you please try the following fix for the
module unload problem.

[PATCH] net/802/mrp: fix lockdep splat

commit fb745e9a037895 ("net/802/mrp: fix possible race condition when
calling mrp_pdu_queue()") introduced a lockdep splat.

[   19.735147] =================================
[   19.735235] [ INFO: inconsistent lock state ]
[   19.735324] 3.9.2-build-0063 #4 Not tainted
[   19.735412] ---------------------------------
[   19.735500] inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
[   19.735592] rmmod/1840 [HC0[0]:SC0[0]:HE1:SE1] takes:
[   19.735682]  (&(&app->lock)->rlock#2){+.?...}, at: [<f862bb5b>] 
mrp_uninit_applicant+0x69/0xba [mrp]

app->lock is normally taken under softirq context, so disable BH to
avoid the splat.

Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: David Ward <david.ward@ll.mit.edu>
Cc: Cong Wang <amwang@redhat.com>
---
 net/802/mrp.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/802/mrp.c b/net/802/mrp.c
index e085bcc..1eb05d8 100644
--- a/net/802/mrp.c
+++ b/net/802/mrp.c
@@ -871,10 +871,10 @@ void mrp_uninit_applicant(struct net_device *dev, struct mrp_application *appl)
 	 */
 	del_timer_sync(&app->join_timer);
 
-	spin_lock(&app->lock);
+	spin_lock_bh(&app->lock);
 	mrp_mad_event(app, MRP_EVENT_TX);
 	mrp_pdu_queue(app);
-	spin_unlock(&app->lock);
+	spin_unlock_bh(&app->lock);
 
 	mrp_queue_xmit(app);
 
