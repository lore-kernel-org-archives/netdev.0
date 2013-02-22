From: Dave Jones <davej@redhat.com>
Subject: lockdep trace from sockstat_seq_show
Date: Fri, 22 Feb 2013 12:13:43 -0500
Message-ID: <20130222171343.GB27619@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just hit this on Linus' current tree.

[ 1789.629729] =========================================================
[ 1789.629731] [ INFO: possible irq lock inversion dependency detected ]
[ 1789.629736] 3.8.0+ #76 Not tainted
[ 1789.629738] ---------------------------------------------------------
[ 1789.629742] swapper/0/0 just changed the state of lock:
[ 1789.629744] blocked:  (&(&q->lock)->rlock){+.-...}, instance: ffff88006c24da58, at: [<ffffffff8151c6d8>] ip_expire+0x28/0x220
[ 1789.629762] but this lock took another, SOFTIRQ-unsafe lock in the past:
[ 1789.629765]  (key#15){+.+...}

and interrupts could create inverse lock ordering between them.

[ 1789.629772] 
other info that might help us debug this:
[ 1789.629775]  Possible interrupt unsafe locking scenario:

[ 1789.629778]        CPU0                    CPU1
[ 1789.629780]        ----                    ----
[ 1789.629782]   lock(key#15);
[ 1789.629788]                                local_irq_disable();
[ 1789.629790]                                lock(&(&q->lock)->rlock);
[ 1789.629794]                                lock(key#15);
[ 1789.629799]   <Interrupt>
[ 1789.629801]     lock(&(&q->lock)->rlock);
[ 1789.629805] 
 *** DEADLOCK ***

[ 1789.629809] 1 lock on stack by swapper/0/0:
[ 1789.629812]  #0: blocked:  (((&q->timer))){+.-...}, instance: ffff880119803dd0, at: [<ffffffff81056ad5>] call_timer_fn+0x5/0x1f0
[ 1789.629826] 
the shortest dependencies between 2nd lock and 1st lock:
[ 1789.629844]  -> (key#15){+.+...} ops: 132 {
[ 1789.629854]     HARDIRQ-ON-W at:
[ 1789.629857]                       [<ffffffff810ade4a>] __lock_acquire+0x64a/0x1cb0
[ 1789.629865]                       [<ffffffff810afab6>] lock_acquire+0x96/0x150
[ 1789.629871]                       [<ffffffff815ac090>] _raw_spin_lock+0x40/0x80
[ 1789.629878]                       [<ffffffff81308d79>] __percpu_counter_sum+0x19/0xc0
[ 1789.629885]                       [<ffffffff8151c905>] ip_frag_mem+0x15/0x30
[ 1789.629891]                       [<ffffffff81567448>] sockstat_seq_show+0x128/0x170
[ 1789.629898]                       [<ffffffff811b744c>] seq_read+0xcc/0x460
[ 1789.629904]                       [<ffffffff811f5ec0>] proc_reg_read+0x80/0xc0
[ 1789.629910]                       [<ffffffff81193e5c>] vfs_read+0xac/0x180
[ 1789.629916]                       [<ffffffff81193f85>] sys_read+0x55/0xa0
[ 1789.629920]                       [<ffffffff815b4a99>] system_call_fastpath+0x16/0x1b
[ 1789.629926]     SOFTIRQ-ON-W at:
[ 1789.629929]                       [<ffffffff810ade86>] __lock_acquire+0x686/0x1cb0
[ 1789.629935]                       [<ffffffff810afab6>] lock_acquire+0x96/0x150
[ 1789.629941]                       [<ffffffff815ac090>] _raw_spin_lock+0x40/0x80
[ 1789.629946]                       [<ffffffff81308d79>] __percpu_counter_sum+0x19/0xc0
[ 1789.629951]                       [<ffffffff8151c905>] ip_frag_mem+0x15/0x30
[ 1789.629957]                       [<ffffffff81567448>] sockstat_seq_show+0x128/0x170
[ 1789.629963]                       [<ffffffff811b744c>] seq_read+0xcc/0x460
[ 1789.629968]                       [<ffffffff811f5ec0>] proc_reg_read+0x80/0xc0
[ 1789.629973]                       [<ffffffff81193e5c>] vfs_read+0xac/0x180
[ 1789.629977]                       [<ffffffff81193f85>] sys_read+0x55/0xa0
[ 1789.629981]                       [<ffffffff815b4a99>] system_call_fastpath+0x16/0x1b
[ 1789.629986]     INITIAL USE at:
[ 1789.629989]                      [<ffffffff810adb0d>] __lock_acquire+0x30d/0x1cb0
[ 1789.629995]                      [<ffffffff810afab6>] lock_acquire+0x96/0x150
[ 1789.630001]                      [<ffffffff815ac090>] _raw_spin_lock+0x40/0x80
[ 1789.630006]                      [<ffffffff81308d79>] __percpu_counter_sum+0x19/0xc0
[ 1789.630012]                      [<ffffffff8151c905>] ip_frag_mem+0x15/0x30
[ 1789.630017]                      [<ffffffff81567448>] sockstat_seq_show+0x128/0x170
[ 1789.630023]                      [<ffffffff811b744c>] seq_read+0xcc/0x460
[ 1789.630028]                      [<ffffffff811f5ec0>] proc_reg_read+0x80/0xc0
[ 1789.630033]                      [<ffffffff81193e5c>] vfs_read+0xac/0x180
[ 1789.630038]                      [<ffffffff81193f85>] sys_read+0x55/0xa0
[ 1789.630042]                      [<ffffffff815b4a99>] system_call_fastpath+0x16/0x1b
[ 1789.630047]   }
[ 1789.630049]   ... key      at: [<ffffffff829fb1e8>] __key.23045+0x0/0x8
[ 1789.630055]   ... acquired at:
[ 1789.630057]    [<ffffffff810afab6>] lock_acquire+0x96/0x150
[ 1789.630063]    [<ffffffff815ac090>] _raw_spin_lock+0x40/0x80
[ 1789.630068]    [<ffffffff81308b74>] __percpu_counter_add+0x54/0xc0
[ 1789.630073]    [<ffffffff8151bea4>] ip_defrag+0x6e4/0xd40
[ 1789.630079]    [<ffffffff8151ac64>] ip_local_deliver+0x34/0x2e0
[ 1789.630084]    [<ffffffff8151b27d>] ip_rcv+0x36d/0x5c0
[ 1789.630090]    [<ffffffff814eec6a>] __netif_receive_skb_core+0x3da/0x6d0
[ 1789.630095]    [<ffffffff814eef81>] __netif_receive_skb+0x21/0x70
[ 1789.630099]    [<ffffffff814ef193>] netif_receive_skb+0x23/0x100
[ 1789.630103]    [<ffffffffa04cacf3>] ieee80211_deliver_skb.isra.30+0xa3/0x200 [mac80211]
[ 1789.630132]    [<ffffffffa04cc16e>] ieee80211_rx_handlers+0xcae/0x23b0 [mac80211]
[ 1789.630152]    [<ffffffffa04cda10>] ieee80211_prepare_and_rx_handle+0x1a0/0xb00 [mac80211]
[ 1789.630170]    [<ffffffffa04ce69d>] ieee80211_rx+0x32d/0x910 [mac80211]
[ 1789.630188]    [<ffffffffa0584280>] iwlagn_rx_reply_rx+0x3f0/0x760 [iwldvm]
[ 1789.630201]    [<ffffffffa0585473>] iwl_rx_dispatch+0xa3/0x110 [iwldvm]
[ 1789.630212]    [<ffffffffa02d95cf>] iwl_pcie_irq_handler+0x93f/0xe00 [iwlwifi]
[ 1789.630225]    [<ffffffff810db569>] irq_thread_fn+0x29/0x50
[ 1789.630232]    [<ffffffff810dbacf>] irq_thread+0x12f/0x160
[ 1789.630237]    [<ffffffff8106c5ed>] kthread+0xed/0x100
[ 1789.630243]    [<ffffffff815b49ec>] ret_from_fork+0x7c/0xb0

[ 1789.630251] -> (&(&q->lock)->rlock){+.-...} ops: 18 {
[ 1789.630260]    HARDIRQ-ON-W at:
[ 1789.630264]                     [<ffffffff810ade4a>] __lock_acquire+0x64a/0x1cb0
[ 1789.630270]                     [<ffffffff810afab6>] lock_acquire+0x96/0x150
[ 1789.630276]                     [<ffffffff815ac090>] _raw_spin_lock+0x40/0x80
[ 1789.630281]                     [<ffffffff8151b8df>] ip_defrag+0x11f/0xd40
[ 1789.630287]                     [<ffffffff8151ac64>] ip_local_deliver+0x34/0x2e0
[ 1789.630292]                     [<ffffffff8151b27d>] ip_rcv+0x36d/0x5c0
[ 1789.630297]                     [<ffffffff814eec6a>] __netif_receive_skb_core+0x3da/0x6d0
[ 1789.630301]                     [<ffffffff814eef81>] __netif_receive_skb+0x21/0x70
[ 1789.630305]                     [<ffffffff814ef193>] netif_receive_skb+0x23/0x100
[ 1789.630310]                     [<ffffffffa04cacf3>] ieee80211_deliver_skb.isra.30+0xa3/0x200 [mac80211]
[ 1789.630330]                     [<ffffffffa04cc16e>] ieee80211_rx_handlers+0xcae/0x23b0 [mac80211]
[ 1789.630348]                     [<ffffffffa04cda10>] ieee80211_prepare_and_rx_handle+0x1a0/0xb00 [mac80211]
[ 1789.630365]                     [<ffffffffa04ce69d>] ieee80211_rx+0x32d/0x910 [mac80211]
[ 1789.630382]                     [<ffffffffa0584280>] iwlagn_rx_reply_rx+0x3f0/0x760 [iwldvm]
[ 1789.630392]                     [<ffffffffa0585473>] iwl_rx_dispatch+0xa3/0x110 [iwldvm]
[ 1789.630402]                     [<ffffffffa02d95cf>] iwl_pcie_irq_handler+0x93f/0xe00 [iwlwifi]
[ 1789.630412]                     [<ffffffff810db569>] irq_thread_fn+0x29/0x50
[ 1789.630418]                     [<ffffffff810dbacf>] irq_thread+0x12f/0x160
[ 1789.630423]                     [<ffffffff8106c5ed>] kthread+0xed/0x100
[ 1789.630429]                     [<ffffffff815b49ec>] ret_from_fork+0x7c/0xb0
[ 1789.630434]    IN-SOFTIRQ-W at:
[ 1789.630437]                     [<ffffffff810ade03>] __lock_acquire+0x603/0x1cb0
[ 1789.630444]                     [<ffffffff810afab6>] lock_acquire+0x96/0x150
[ 1789.630449]                     [<ffffffff815ac090>] _raw_spin_lock+0x40/0x80
[ 1789.630454]                     [<ffffffff8151c6d8>] ip_expire+0x28/0x220
[ 1789.630460]                     [<ffffffff81056b5a>] call_timer_fn+0x8a/0x1f0
[ 1789.630466]                     [<ffffffff81056ef4>] run_timer_softirq+0x234/0x2e0
[ 1789.630471]                     [<ffffffff8104eae8>] __do_softirq+0xf8/0x2b0
[ 1789.630478]                     [<ffffffff815b5e3c>] call_softirq+0x1c/0x26
[ 1789.630483]                     [<ffffffff81003eb5>] do_softirq+0xa5/0xe0
[ 1789.630488]                     [<ffffffff8104ee85>] irq_exit+0xd5/0xe0
[ 1789.630494]                     [<ffffffff815b5f8b>] smp_apic_timer_interrupt+0x6b/0x98
[ 1789.630499]                     [<ffffffff815b56f2>] apic_timer_interrupt+0x72/0x80
[ 1789.630504]                     [<ffffffff814a1bf0>] cpuidle_enter_tk+0x10/0x20
[ 1789.630510]                     [<ffffffff814a1835>] cpuidle_idle_call+0xa5/0x250
[ 1789.630516]                     [<ffffffff8100b545>] cpu_idle+0xd5/0x170
[ 1789.630521]                     [<ffffffff81591321>] rest_init+0xc1/0xd0
[ 1789.630528]                     [<ffffffff81cbaea5>] start_kernel+0x403/0x410
[ 1789.630536]                     [<ffffffff81cba59b>] x86_64_start_reservations+0x2a/0x2c
[ 1789.630541]                     [<ffffffff81cba689>] x86_64_start_kernel+0xec/0xfb
[ 1789.630547]    INITIAL USE at:
[ 1789.630550]                    [<ffffffff810adb0d>] __lock_acquire+0x30d/0x1cb0
[ 1789.630556]                    [<ffffffff810afab6>] lock_acquire+0x96/0x150
[ 1789.630562]                    [<ffffffff815ac090>] _raw_spin_lock+0x40/0x80
[ 1789.630566]                    [<ffffffff8151b8df>] ip_defrag+0x11f/0xd40
[ 1789.630572]                    [<ffffffff8151ac64>] ip_local_deliver+0x34/0x2e0
[ 1789.630577]                    [<ffffffff8151b27d>] ip_rcv+0x36d/0x5c0
[ 1789.630583]                    [<ffffffff814eec6a>] __netif_receive_skb_core+0x3da/0x6d0
[ 1789.630587]                    [<ffffffff814eef81>] __netif_receive_skb+0x21/0x70
[ 1789.630591]                    [<ffffffff814ef193>] netif_receive_skb+0x23/0x100
[ 1789.630595]                    [<ffffffffa04cacf3>] ieee80211_deliver_skb.isra.30+0xa3/0x200 [mac80211]
[ 1789.630615]                    [<ffffffffa04cc16e>] ieee80211_rx_handlers+0xcae/0x23b0 [mac80211]
[ 1789.630631]                    [<ffffffffa04cda10>] ieee80211_prepare_and_rx_handle+0x1a0/0xb00 [mac80211]
[ 1789.630647]                    [<ffffffffa04ce69d>] ieee80211_rx+0x32d/0x910 [mac80211]
[ 1789.630664]                    [<ffffffffa0584280>] iwlagn_rx_reply_rx+0x3f0/0x760 [iwldvm]
[ 1789.630674]                    [<ffffffffa0585473>] iwl_rx_dispatch+0xa3/0x110 [iwldvm]
[ 1789.630684]                    [<ffffffffa02d95cf>] iwl_pcie_irq_handler+0x93f/0xe00 [iwlwifi]
[ 1789.630694]                    [<ffffffff810db569>] irq_thread_fn+0x29/0x50
[ 1789.630700]                    [<ffffffff810dbacf>] irq_thread+0x12f/0x160
[ 1789.630705]                    [<ffffffff8106c5ed>] kthread+0xed/0x100
[ 1789.630711]                    [<ffffffff815b49ec>] ret_from_fork+0x7c/0xb0
[ 1789.630716]  }
[ 1789.630718]  ... key      at: [<ffffffff829fb1f8>] __key.32665+0x0/0x8
[ 1789.630723]  ... acquired at:
[ 1789.630726]    [<ffffffff810ace86>] check_usage_forwards+0x136/0x140
[ 1789.630732]    [<ffffffff810ad6c6>] mark_lock+0x176/0x2b0
[ 1789.630737]    [<ffffffff810ade03>] __lock_acquire+0x603/0x1cb0
[ 1789.630743]    [<ffffffff810afab6>] lock_acquire+0x96/0x150
[ 1789.630748]    [<ffffffff815ac090>] _raw_spin_lock+0x40/0x80
[ 1789.630753]    [<ffffffff8151c6d8>] ip_expire+0x28/0x220
[ 1789.630759]    [<ffffffff81056b5a>] call_timer_fn+0x8a/0x1f0
[ 1789.630765]    [<ffffffff81056ef4>] run_timer_softirq+0x234/0x2e0
[ 1789.630770]    [<ffffffff8104eae8>] __do_softirq+0xf8/0x2b0
[ 1789.630776]    [<ffffffff815b5e3c>] call_softirq+0x1c/0x26
[ 1789.630781]    [<ffffffff81003eb5>] do_softirq+0xa5/0xe0
[ 1789.630785]    [<ffffffff8104ee85>] irq_exit+0xd5/0xe0
[ 1789.630791]    [<ffffffff815b5f8b>] smp_apic_timer_interrupt+0x6b/0x98
[ 1789.630796]    [<ffffffff815b56f2>] apic_timer_interrupt+0x72/0x80
[ 1789.630800]    [<ffffffff814a1bf0>] cpuidle_enter_tk+0x10/0x20
[ 1789.630806]    [<ffffffff814a1835>] cpuidle_idle_call+0xa5/0x250
[ 1789.630811]    [<ffffffff8100b545>] cpu_idle+0xd5/0x170
[ 1789.630816]    [<ffffffff81591321>] rest_init+0xc1/0xd0
[ 1789.630822]    [<ffffffff81cbaea5>] start_kernel+0x403/0x410
[ 1789.630828]    [<ffffffff81cba59b>] x86_64_start_reservations+0x2a/0x2c
[ 1789.630833]    [<ffffffff81cba689>] x86_64_start_kernel+0xec/0xfb

[ 1789.630841] 
stack backtrace:
[ 1789.630846] Pid: 0, comm: swapper/0 Not tainted 3.8.0+ #76
[ 1789.630849] Call Trace:
[ 1789.630851]  <IRQ>  [<ffffffff815a2065>] print_irq_inversion_bug.part.39+0x1b0/0x1bf
[ 1789.630865]  [<ffffffff810ace86>] check_usage_forwards+0x136/0x140
[ 1789.630873]  [<ffffffff810acd50>] ? check_usage_backwards+0x140/0x140
[ 1789.630880]  [<ffffffff810ad6c6>] mark_lock+0x176/0x2b0
[ 1789.630886]  [<ffffffff810ade03>] __lock_acquire+0x603/0x1cb0
[ 1789.630893]  [<ffffffff810ad763>] ? mark_lock+0x213/0x2b0
[ 1789.630900]  [<ffffffff810ae380>] ? __lock_acquire+0xb80/0x1cb0
[ 1789.630907]  [<ffffffff810afab6>] lock_acquire+0x96/0x150
[ 1789.630913]  [<ffffffff8151c6d8>] ? ip_expire+0x28/0x220
[ 1789.630919]  [<ffffffff81009a69>] ? sched_clock+0x9/0x10
[ 1789.630925]  [<ffffffff8151c6b0>] ? ip_check_defrag+0x1b0/0x1b0
[ 1789.630931]  [<ffffffff815ac090>] _raw_spin_lock+0x40/0x80
[ 1789.630938]  [<ffffffff8151c6d8>] ? ip_expire+0x28/0x220
[ 1789.630943]  [<ffffffff81009a69>] ? sched_clock+0x9/0x10
[ 1789.630949]  [<ffffffff8151c6d8>] ip_expire+0x28/0x220
[ 1789.630956]  [<ffffffff81056b5a>] call_timer_fn+0x8a/0x1f0
[ 1789.630961]  [<ffffffff81056ad5>] ? call_timer_fn+0x5/0x1f0
[ 1789.630968]  [<ffffffff8151c6b0>] ? ip_check_defrag+0x1b0/0x1b0
[ 1789.630974]  [<ffffffff81056ef4>] run_timer_softirq+0x234/0x2e0
[ 1789.630981]  [<ffffffff814a11a0>] ? read_measured_perf_ctrs+0x90/0x90
[ 1789.630987]  [<ffffffff8104eae8>] __do_softirq+0xf8/0x2b0
[ 1789.630994]  [<ffffffff814a11a0>] ? read_measured_perf_ctrs+0x90/0x90
[ 1789.630999]  [<ffffffff815b5e3c>] call_softirq+0x1c/0x26
[ 1789.631004]  [<ffffffff81003eb5>] do_softirq+0xa5/0xe0
[ 1789.631010]  [<ffffffff8104ee85>] irq_exit+0xd5/0xe0
[ 1789.631016]  [<ffffffff815b5f8b>] smp_apic_timer_interrupt+0x6b/0x98
[ 1789.631022]  [<ffffffff815b56f2>] apic_timer_interrupt+0x72/0x80
[ 1789.631024]  <EOI>  [<ffffffff81034e1f>] ? leave_mm+0x6f/0xa0
[ 1789.631036]  [<ffffffff814a1b98>] ? cpuidle_wrap_enter+0x58/0xa0
[ 1789.631042]  [<ffffffff814a1b91>] ? cpuidle_wrap_enter+0x51/0xa0
[ 1789.631049]  [<ffffffff814a1bf0>] cpuidle_enter_tk+0x10/0x20
[ 1789.631055]  [<ffffffff814a1835>] cpuidle_idle_call+0xa5/0x250
[ 1789.631061]  [<ffffffff8100b545>] cpu_idle+0xd5/0x170
[ 1789.631067]  [<ffffffff81591321>] rest_init+0xc1/0xd0
[ 1789.631074]  [<ffffffff81591265>] ? rest_init+0x5/0xd0
[ 1789.631080]  [<ffffffff81cbaea5>] start_kernel+0x403/0x410
[ 1789.631086]  [<ffffffff81cba8a1>] ? repair_env_string+0x5e/0x5e
[ 1789.631093]  [<ffffffff81cba59b>] x86_64_start_reservations+0x2a/0x2c
[ 1789.631098]  [<ffffffff81cba689>] x86_64_start_kernel+0xec/0xfb
