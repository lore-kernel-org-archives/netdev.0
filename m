From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: [PATCH] net/802/mrp: fix lockdep splat
Date: Mon, 13 May 2013 15:53:30 +0300
Message-ID: <16b0a5ee4602cb9005dd67ea7ad0d4e8@visp.net.lb>
References: <6901a7785249816fe13a98e3c0b35127@visp.net.lb>
 <1368447851.13473.119.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <amwang@redhat.com>, David Ward <david.ward@ll.mit.edu>,
	hayeswang <hayeswang@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:52386 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502Ab3EMMxd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 May 2013 08:53:33 -0400
In-Reply-To: <1368447851.13473.119.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

Thank you for superfast answer :)
It is changed a bit, but not disappeared. Relevant part from new dmesg:

[    3.936191] =================================
[    3.936279] [ INFO: inconsistent lock state ]
[    3.936367] 3.9.2-build-0064 #6 Not tainted
[    3.936453] ---------------------------------
[    3.936540] inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
[    3.936630] rmmod/1843 [HC0[0]:SC0[0]:HE1:SE1] takes:
[    3.936718]  (&(&app->lock)->rlock#2){+.?...}, at: [<f862bb5b>] 
mrp_uninit_applicant+0x69/0xba [mrp]
[    3.936967] {IN-SOFTIRQ-W} state was registered at:
[    3.937055]   [<c01611d8>] __lock_acquire+0x284/0xd52
[    3.937058]   [<c0162068>] lock_acquire+0x71/0x85
[    3.937058]   [<c03e4cae>] _raw_spin_lock_bh+0x38/0x45
[    3.937058]   [<f862b5dc>] mrp_join_timer+0x11/0x3d [mrp]
[    3.937058]   [<c0136102>] call_timer_fn+0x69/0xdc
[    3.937058]   [<c01362e6>] run_timer_softirq+0x171/0x1ab
[    3.937058]   [<c0131963>] __do_softirq+0x98/0x153
[    3.937058]   [<c0131afa>] irq_exit+0x47/0x82
[    3.937058]   [<c011c274>] smp_apic_timer_interrupt+0x64/0x71
[    3.937058]   [<c03e5616>] apic_timer_interrupt+0x32/0x38
[    3.937058]   [<c03e3464>] mutex_lock_nested+0x20/0x22
[    3.937058]   [<c019a272>] unlink_file_vma+0x25/0x75
[    3.937058]   [<c0195dfc>] free_pgtables+0x55/0x99
[    3.937058]   [<c019b4a2>] exit_mmap+0x83/0xd5
[    3.937058]   [<c0129fe7>] mmput+0x4c/0xc4
[    3.937058]   [<c013004d>] do_exit+0x2ac/0x730
[    3.937058]   [<c0130615>] do_group_exit+0x60/0x83
[    3.937058]   [<c013064b>] sys_exit_group+0x13/0x17
[    3.937058]   [<c03e5334>] syscall_call+0x7/0xb
[    3.937058] irq event stamp: 4683
[    3.937058] hardirqs last  enabled at (4683): [<c03e50bb>] 
_raw_spin_unlock_irqrestore+0x36/0x3c
[    3.937058] hardirqs last disabled at (4682): [<c03e4b92>] 
_raw_spin_lock_irqsave+0x16/0x50
[    3.937058] softirqs last  enabled at (4646): [<c0379c22>] 
neigh_ifdown+0x95/0xb5
[    3.937058] softirqs last disabled at (4644): [<c03e4cc9>] 
_raw_write_lock_bh+0xe/0x45
[    3.937058]
[    3.937058] other info that might help us debug this:
[    3.937058]  Possible unsafe locking scenario:
[    3.937058]
[    3.937058]        CPU0
[    3.937058]        ----
[    3.937058]   lock(&(&app->lock)->rlock#2);
[    3.937058]   <Interrupt>
[    3.937058]     lock(&(&app->lock)->rlock#2);
[    3.937058]
[    3.937058]  *** DEADLOCK ***
[    3.937058]
[    3.937058] 3 locks held by rmmod/1843:
[    3.937058]  #0:  (&__lockdep_no_validate__){......}, at: 
[<c02c195c>] device_lock+0xd/0xf
[    3.937058]  #1:  (&__lockdep_no_validate__){......}, at: 
[<c02c195c>] device_lock+0xd/0xf
[    3.937058]  #2:  (rtnl_mutex){+.+.+.}, at: [<c037d71b>] 
rtnl_lock+0xf/0x11
[    3.937058]
[    3.937058] stack backtrace:
[    3.937058] Pid: 1843, comm: rmmod Not tainted 3.9.2-build-0064 #6
[    3.937058] Call Trace:
[    3.937058]  [<c0160d8e>] valid_state+0x1f6/0x201
[    3.937058]  [<c0160e6a>] mark_lock+0xd1/0x1bb
[    3.937058]  [<c01606b1>] ? check_usage_forwards+0x77/0x77
[    3.937058]  [<c016124c>] __lock_acquire+0x2f8/0xd52
[    3.937058]  [<c0160d00>] ? valid_state+0x168/0x201
[    3.937058]  [<c0160dbf>] ? mark_lock+0x26/0x1bb
[    3.937058]  [<c016230e>] ? mark_held_locks+0x5d/0x7b
[    3.937058]  [<c03e50bb>] ? _raw_spin_unlock_irqrestore+0x36/0x3c
[    3.937058]  [<c0162068>] lock_acquire+0x71/0x85
[    3.937058]  [<f862bb5b>] ? mrp_uninit_applicant+0x69/0xba [mrp]
[    3.937058]  [<c03e4ad5>] _raw_spin_lock+0x33/0x40
[    3.937058]  [<f862bb5b>] ? mrp_uninit_applicant+0x69/0xba [mrp]
[    3.937058]  [<f862bb5b>] mrp_uninit_applicant+0x69/0xba [mrp]
[    3.937058]  [<c0172e67>] ? kfree_call_rcu+0x17/0x19
[    3.937058]  [<f8647bf6>] vlan_mvrp_uninit_applicant+0xd/0xf [8021q]
[    3.937058]  [<f8646198>] unregister_vlan_dev+0xb8/0xe2 [8021q]
[    3.937058]  [<c03d1ae8>] ? packet_mm_close+0x1f/0x1f
[    3.937058]  [<f86464c9>] vlan_device_event+0x307/0x35a [8021q]
[    3.937058]  [<c03d1ce7>] ? rcu_read_unlock+0x17/0x19
[    3.937058]  [<c0146215>] notifier_call_chain+0x26/0x48
[    3.937058]  [<c0146283>] raw_notifier_call_chain+0x1a/0x1c
[    3.937058]  [<c0370310>] call_netdevice_notifiers+0x44/0x4b
[    3.937058]  [<c0370604>] rollback_registered_many+0xe2/0x185
[    3.937058]  [<c037070d>] rollback_registered+0x1f/0x2c
[    3.937058]  [<c0370777>] unregister_netdevice_queue+0x5d/0x87
[    3.937058]  [<c03e3464>] ? mutex_lock_nested+0x20/0x22
[    3.937058]  [<c037d71b>] ? rtnl_lock+0xf/0x11
[    3.937058]  [<c0370851>] unregister_netdev+0x18/0x1f
[    3.937058]  [<f85cb017>] rtl_remove_one+0x7f/0xf9 [r8169]
[    3.937058]  [<c02c9117>] ? __pm_runtime_resume+0x48/0x50
[    3.937058]  [<c026cea9>] pci_device_remove+0x27/0x76
[    3.937058]  [<c02c1b70>] __device_release_driver+0x66/0xaa
[    3.937058]  [<c02c20a3>] driver_detach+0x62/0x83
[    3.937058]  [<c02c1919>] bus_remove_driver+0x69/0x88
[    3.937058]  [<c02c23be>] driver_unregister+0x53/0x5a
[    3.937058]  [<c016243a>] ? trace_hardirqs_on_caller+0x10e/0x13f
[    3.937058]  [<c026cf87>] pci_unregister_driver+0x10/0x5a
[    3.937058]  [<f85cd8fb>] rtl8169_pci_driver_exit+0xd/0xf [r8169]
[    3.937058]  [<c01688cf>] sys_delete_module+0x175/0x1c1
[    3.937058]  [<c03e5367>] ? restore_all+0xf/0xf
[    3.937058]  [<c03e5334>] syscall_call+0x7/0xb



On 2013-05-13 15:24, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> On Mon, 2013-05-13 at 14:59 +0300, Denys Fedoryshchenko wrote:
> Hi
> 
> Noticed on 32-builds of my systems that r8169 is not working anymore at
> all.
> Problem started to occur somewhere after 3.6 kernels, but it is
> difficult to try other kernels on this semi-embedded system, and i am
> not completely sure about that.
> Once i used another OS build, but 64-bit build with same latest kernel,
> and it worked.
> It spits netdev watchdog timeouts, and constantly shows interface 
> coming
> up.
> 
> Here is max debug output(dmesg) i got, with some inline comments:
> 
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
> 
> Thanks for the report. Could you please try the following fix for the
> module unload problem.
> 
> [PATCH] net/802/mrp: fix lockdep splat
> 
> commit fb745e9a037895 ("net/802/mrp: fix possible race condition when
> calling mrp_pdu_queue()") introduced a lockdep splat.
> 
> [   19.735147] =================================
> [   19.735235] [ INFO: inconsistent lock state ]
> [   19.735324] 3.9.2-build-0063 #4 Not tainted
> [   19.735412] ---------------------------------
> [   19.735500] inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
> [   19.735592] rmmod/1840 [HC0[0]:SC0[0]:HE1:SE1] takes:
> [   19.735682]  (&(&app->lock)->rlock#2){+.?...}, at: [<f862bb5b>]
> mrp_uninit_applicant+0x69/0xba [mrp]
> 
> app->lock is normally taken under softirq context, so disable BH to
> avoid the splat.
> 
> Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: David Ward <david.ward@ll.mit.edu>
> Cc: Cong Wang <amwang@redhat.com>
> ---
> net/802/mrp.c |    4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/802/mrp.c b/net/802/mrp.c
> index e085bcc..1eb05d8 100644
> --- a/net/802/mrp.c
> +++ b/net/802/mrp.c
> @@ -871,10 +871,10 @@ void mrp_uninit_applicant(struct net_device
> *dev, struct mrp_application *appl)
> 	 */
> 	del_timer_sync(&app->join_timer);
> 
> -	spin_lock(&app->lock);
> +	spin_lock_bh(&app->lock);
> 	mrp_mad_event(app, MRP_EVENT_TX);
> 	mrp_pdu_queue(app);
> -	spin_unlock(&app->lock);
> +	spin_unlock_bh(&app->lock);
> 
> 	mrp_queue_xmit(app);

---
Denys Fedoryshchenko, Network Engineer, Virtual ISP S.A.L.
