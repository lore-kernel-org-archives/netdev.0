From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: BUG: IPv4: Attempt to release TCP socket in state 1
Date: Tue, 05 Mar 2013 11:47:13 +0800
Message-ID: <51356AC1.4090302@gmail.com>
References: <alpine.DEB.2.02.1303041547080.7811@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: dormando <dormando@rydia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:50766 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758940Ab3CEDr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 22:47:28 -0500
In-Reply-To: <alpine.DEB.2.02.1303041547080.7811@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Cc'ing the right netdev mailing list...)

On 03/05/2013 08:01 AM, dormando wrote:
> Hi!
>
> I have a (core lockup?) with 3.7.6+ and 3.8.2 which appears to be under
> ixgbe. The machine appears to still be up but network stays in a severely
> hobbled state. Either lagging or not responding to the network at all.
>
> On a new box the hang happens within 8-24 hours of giving it production
> network traffic. On an older machine (6 cores instead of 8, etc) it can
> run for a week or more before hanging.
>
> The hang from 3.7 might be slightly different than 3.8. They seem to be
> mostly the same aside from 3.8 hanging in the GRO path. Don't see anything
> obvious in 3.9-rc1 that would fix it, and haven't tried 3.9-rc1.
>
> I've not yet figured out how to reproduce outside of production (as
> always, sigh). This doesn't seem to happen with 3.6.6, but we have
> different and less frequent kernel panics there.
>
>  From 3.7:
>
> [21934.669780] IPv4: Attempt to release TCP socket in state 1
> ffff882785e3db00
> [21969.265883] ------------[ cut here ]------------
> [21969.265898] WARNING: at net/sched/sch_generic.c:255
> dev_watchdog+0x258/0x270()
> [21969.265900] Hardware name: X9DR3-F
> [21969.265902] NETDEV WATCHDOG: eth2 (ixgbe): transmit queue 11 timed out
> [21969.265903] Modules linked in: macvlan bridge ipmi_watchdog
> ipmi_devintf coretemp ghash_clmulni_intel gpio_ich microcode ixgbe sb_edac
> mdio lpc_ich edac_core mei mfd_core ipmi_si ipmi_msghandler isci libsas
> igb
> [21969.265930] Pid: 0, comm: swapper/10 Not tainted 3.7.8 #1
> [21969.265931] Call Trace:
> [21969.265933]  <IRQ>  [<ffffffff810484ff>] warn_slowpath_common+0x7f/0xc0
> [21969.265945]  [<ffffffff815a712e>] ? ip_local_deliver_finish+0xde/0x290
> [21969.265948]  [<ffffffff810485f6>] warn_slowpath_fmt+0x46/0x50
> [21969.265950]  [<ffffffff815a69b9>] ? ip_rcv_finish+0x119/0x360
> [21969.265953]  [<ffffffff8157d538>] dev_watchdog+0x258/0x270
> [21969.265956]  [<ffffffff8157d2e0>] ? __netdev_watchdog_up+0x80/0x80
> [21969.265960]  [<ffffffff81058349>] call_timer_fn+0x49/0x130
> [21969.265963]  [<ffffffff81078f9f>] ? scheduler_tick+0x15f/0x190
> [21969.265965]  [<ffffffff81058944>] run_timer_softirq+0x224/0x290
> [21969.265967]  [<ffffffff81058066>] ? update_process_times+0x76/0x90
> [21969.265969]  [<ffffffff8157d2e0>] ? __netdev_watchdog_up+0x80/0x80
> [21969.265974]  [<ffffffff8108b4f4>] ? ktime_get+0x54/0xe0
> [21969.265977]  [<ffffffff810509c7>] __do_softirq+0xc7/0x230
> [21969.265990]  [<ffffffff816757cc>] call_softirq+0x1c/0x30
> [21969.265995]  [<ffffffff81004475>] do_softirq+0x55/0x90
> [21969.265997]  [<ffffffff810507c5>] irq_exit+0x85/0xa0
> [21969.265999]  [<ffffffff81675dfe>] smp_apic_timer_interrupt+0x6e/0x99
> [21969.266002]  [<ffffffff816751ca>] apic_timer_interrupt+0x6a/0x70
> [21969.266003]  <EOI>  [<ffffffff8166b17a>] ? __schedule+0x3aa/0x750
> [21969.266011]  [<ffffffff8100b2ed>] ? mwait_idle+0xad/0x1f0
> [21969.266013]  [<ffffffff8100a7a3>] cpu_idle+0xb3/0x100
> [21969.266017]  [<ffffffff816632e3>] start_secondary+0x1c9/0x1d0
> [21969.266019] ---[ end trace 0739ad788910e77e ]---
> [21969.266059] ixgbe 0000:83:00.0 eth2: Reset adapter
> [22019.676899] INFO: rcu_sched self-detected stall on CPU { 30}  (t=15001
> jiffies)
> [22019.676963] Pid: 0, comm: swapper/30 Tainted: G        W    3.7.8 #1
> [22019.676966] Call Trace:
> [22019.676968]  <IRQ>  [<ffffffff810bb144>]
> rcu_check_callbacks+0x1b4/0x600
> [22019.676985]  [<ffffffff8107e1b8>] ? account_system_time+0xe8/0x1e0
> [22019.676988]  [<ffffffff81058038>] update_process_times+0x48/0x90
> [22019.676993]  [<ffffffff81092aa7>] tick_sched_timer+0x77/0x160
> [22019.677006]  [<ffffffff8106f66d>] __run_hrtimer+0x7d/0x1c0
> [22019.677008]  [<ffffffff81092a30>] ? tick_setup_sched_timer+0x110/0x110
> [22019.677010]  [<ffffffff8106fa26>] hrtimer_interrupt+0xf6/0x230
> [22019.677015]  [<ffffffff81675df9>] smp_apic_timer_interrupt+0x69/0x99
> [22019.677018]  [<ffffffff816751ca>] apic_timer_interrupt+0x6a/0x70
> [22019.677023]  [<ffffffff815afaa0>] ?
> __inet_lookup_established+0xc0/0x280
> [22019.677026]  [<ffffffff815a68a0>] ? inet_del_protocol+0x40/0x40
> [22019.677030]  [<ffffffff815cc383>] tcp_v4_early_demux+0xa3/0x170
> [22019.677033]  [<ffffffff815a69ed>] ip_rcv_finish+0x14d/0x360
> [22019.677035]  [<ffffffff815a6f66>] ip_rcv+0x226/0x310
> [22019.677041]  [<ffffffff815609f2>] __netif_receive_skb+0x492/0x640
> [22019.677043]  [<ffffffff81074209>] ? __wake_up_common+0x59/0x90
> [22019.677051]  [<ffffffffa00f284b>] ? ixgbe_poll+0xe3b/0x1140 [ixgbe]
> [22019.677054]  [<ffffffff81560c94>] process_backlog+0xf4/0x1e0
> [22019.677056]  [<ffffffff815619c5>] net_rx_action+0xf5/0x260
> [22019.677070]  [<ffffffff810509c7>] __do_softirq+0xc7/0x230
> [22019.677072]  [<ffffffff816757cc>] call_softirq+0x1c/0x30
> [22019.677076]  [<ffffffff81004475>] do_softirq+0x55/0x90
> [22019.677078]  [<ffffffff810507c5>] irq_exit+0x85/0xa0
> [22019.677080]  [<ffffffff81675d16>] do_IRQ+0x66/0xe0
> [22019.677084]  [<ffffffff8166c8aa>] common_interrupt+0x6a/0x6a
> [22019.677085]  <EOI>  [<ffffffff8166b17a>] ? __schedule+0x3aa/0x750
> [22019.677090]  [<ffffffff8100b2ed>] ? mwait_idle+0xad/0x1f0
> [22019.677092]  [<ffffffff8100a7a3>] cpu_idle+0xb3/0x100
> [22019.677096]  [<ffffffff816632e3>] start_secondary+0x1c9/0x1d0
> [22188.695704] INFO: task kworker/10:2:676 blocked for more than 120
> seconds.
> [22188.695750] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables
> this message.
> [22188.695807] kworker/10:2    D ffffffff81806e40     0   676      2
> 0x00000000
> [22188.695813]  ffff882ff9dadad8 0000000000000046 ffff882ff9082d80
> 00000000000126c0
> [22188.695816]  ffff882ff9dadfd8 ffff882ff9dac010 00000000000126c0
> 00000000000126c0
> [22188.695818]  ffff882ff9dadfd8 00000000000126c0 ffff882ffb185b00
> ffff882ff9082d80
> [22188.695820] Call Trace:
> [22188.695830]  [<ffffffff8166b5e9>] schedule+0x29/0x70
> [22188.695833]  [<ffffffff816698e5>] schedule_timeout+0x165/0x200
> [22188.695838]  [<ffffffff810796b5>] ? ttwu_do_wakeup+0x45/0x100
> [22188.695840]  [<ffffffff810797b9>] ? T.1871+0x49/0x60
> [22188.695843]  [<ffffffff8107c28e>] ? try_to_wake_up+0x23e/0x2b0
> [22188.695845]  [<ffffffff8166ac58>] wait_for_common+0xc8/0x160
> [22188.695847]  [<ffffffff8107c300>] ? try_to_wake_up+0x2b0/0x2b0
> [22188.695852]  [<ffffffff810b90c0>] ? rcu_cpu_stall_reset+0x60/0x60
> [22188.695854]  [<ffffffff8166adcd>] wait_for_completion+0x1d/0x20
> [22188.695859]  [<ffffffff810aed96>] __stop_cpus+0x56/0x80
> [22188.695861]  [<ffffffff810b90c0>] ? rcu_cpu_stall_reset+0x60/0x60
> [22188.695864]  [<ffffffff810aee0d>] try_stop_cpus+0x4d/0x80
> [22188.695867]  [<ffffffff810bb62a>]
> synchronize_sched_expedited+0x9a/0x120
> [22188.695869]  [<ffffffff810bb6be>] synchronize_rcu_expedited+0xe/0x10
> [22188.695874]  [<ffffffff8155a8e5>] synchronize_net+0x25/0x30
> [22188.695880]  [<ffffffff8157dbb4>] dev_deactivate_many+0x254/0x260
> [22188.695882]  [<ffffffff8157dbed>] dev_deactivate+0x2d/0x40
> [22188.695886]  [<ffffffff8156fff4>] linkwatch_do_dev+0x34/0x60
> [22188.695888]  [<ffffffff815701d3>] __linkwatch_run_queue+0xf3/0x1e0
> [22188.695891]  [<ffffffff815702e5>] linkwatch_event+0x25/0x30
> [22188.695894]  [<ffffffff81064180>] process_one_work+0x160/0x460
> [22188.695896]  [<ffffffff815702c0>] ? __linkwatch_run_queue+0x1e0/0x1e0
> [22188.695899]  [<ffffffff8106631b>] worker_thread+0x12b/0x3d0
> [22188.695901]  [<ffffffff810661f0>] ? manage_workers+0x300/0x300
> [22188.695904]  [<ffffffff8106b26e>] kthread+0xce/0xe0
> [22188.695907]  [<ffffffff8106b1a0>] ?
> kthread_freezable_should_stop+0x70/0x70
> [22188.695911]  [<ffffffff8167475c>] ret_from_fork+0x7c/0xb0
> [22188.695913]  [<ffffffff8106b1a0>] ?
> kthread_freezable_should_stop+0x70/0x70
>
> [tons of processes hung in a similar way]
>
> Then every few hundred seconds swapper bails:
>
> [22919.239167] INFO: rcu_sched self-detected stall on CPU { 30}  (t=240021
> jiffies)
> [22919.239409] Pid: 0, comm: swapper/30 Tainted: G        W    3.7.8 #1
> [22919.239411] Call Trace:
> [22919.239413]  <IRQ>  [<ffffffff810bb144>]
> rcu_check_callbacks+0x1b4/0x600
> [22919.239430]  [<ffffffff8107e1b8>] ? account_system_time+0xe8/0x1e0
> [22919.239434]  [<ffffffff81058038>] update_process_times+0x48/0x90
> [22919.239439]  [<ffffffff81092aa7>] tick_sched_timer+0x77/0x160
> [22919.239442]  [<ffffffff8106f66d>] __run_hrtimer+0x7d/0x1c0
> [22919.239445]  [<ffffffff81092a30>] ? tick_setup_sched_timer+0x110/0x110
> [22919.239447]  [<ffffffff8106fa26>] hrtimer_interrupt+0xf6/0x230
> [22919.239453]  [<ffffffff81675df9>] smp_apic_timer_interrupt+0x69/0x99
> [22919.239455]  [<ffffffff816751ca>] apic_timer_interrupt+0x6a/0x70
> [22919.239461]  [<ffffffff815afaab>] ?
> __inet_lookup_established+0xcb/0x280
> [22919.239463]  [<ffffffff815a68a0>] ? inet_del_protocol+0x40/0x40
> [22919.239468]  [<ffffffff815cc383>] tcp_v4_early_demux+0xa3/0x170
> [22919.239470]  [<ffffffff815a69ed>] ip_rcv_finish+0x14d/0x360
> [22919.239472]  [<ffffffff815a6f66>] ip_rcv+0x226/0x310
> [22919.239478]  [<ffffffff815609f2>] __netif_receive_skb+0x492/0x640
> [22919.239481]  [<ffffffff81074209>] ? __wake_up_common+0x59/0x90
> [22919.239490]  [<ffffffffa00f284b>] ? ixgbe_poll+0xe3b/0x1140 [ixgbe]
> [22919.239493]  [<ffffffff81560c94>] process_backlog+0xf4/0x1e0
> [22919.239495]  [<ffffffff815619c5>] net_rx_action+0xf5/0x260
> [22919.239499]  [<ffffffff810509c7>] __do_softirq+0xc7/0x230
> [22919.239501]  [<ffffffff816757cc>] call_softirq+0x1c/0x30
> [22919.239505]  [<ffffffff81004475>] do_softirq+0x55/0x90
> [22919.239507]  [<ffffffff810507c5>] irq_exit+0x85/0xa0
> [22919.239509]  [<ffffffff81675d16>] do_IRQ+0x66/0xe0
> [22919.239513]  [<ffffffff8166c8aa>] common_interrupt+0x6a/0x6a
> [22919.239514]  <EOI>  [<ffffffff8166b17a>] ? __schedule+0x3aa/0x750
> [22919.239520]  [<ffffffff8100b2ed>] ? mwait_idle+0xad/0x1f0
> [22919.239522]  [<ffffffff8100a7a3>] cpu_idle+0xb3/0x100
> [22919.239526]  [<ffffffff816632e3>] start_secondary+0x1c9/0x1d0
> [23099.151590] INFO: rcu_sched self-detected stall on CPU { 30}  (t=285025
> jiffies)
> [23099.151823] Pid: 0, comm: swapper/30 Tainted: G        W
> [23099.151825] Call Trace:
> [23099.151827]  <IRQ>  [<ffffffff810bb144>]
> rcu_check_callbacks+0x1b4/0x600
> [23099.151841]  [<ffffffff8107e1b8>] ? account_system_time+0xe8/0x1e0
> [23099.151845]  [<ffffffff81058038>] update_process_times+0x48/0x90
> [23099.151849]  [<ffffffff81092aa7>] tick_sched_timer+0x77/0x160
> [23099.151853]  [<ffffffff8106f66d>] __run_hrtimer+0x7d/0x1c0
> [23099.151856]  [<ffffffff81092a30>] ? tick_setup_sched_timer+0x110/0x110
> [23099.151857]  [<ffffffff8106fa26>] hrtimer_interrupt+0xf6/0x230
> [23099.151863]  [<ffffffff81675df9>] smp_apic_timer_interrupt+0x69/0x99
> [23099.151865]  [<ffffffff816751ca>] apic_timer_interrupt+0x6a/0x70
> [23099.151870]  [<ffffffff815afb53>] ?
> __inet_lookup_established+0x173/0x280
> [23099.151873]  [<ffffffff815a68a0>] ? inet_del_protocol+0x40/0x40
> [23099.151877]  [<ffffffff815cc383>] tcp_v4_early_demux+0xa3/0x170
> [23099.151880]  [<ffffffff815a69ed>] ip_rcv_finish+0x14d/0x360
> [23099.151882]  [<ffffffff815a6f66>] ip_rcv+0x226/0x310
> [23099.151887]  [<ffffffff815609f2>] __netif_receive_skb+0x492/0x640
> [23099.151890]  [<ffffffff81074209>] ? __wake_up_common+0x59/0x90
> [23099.151897]  [<ffffffffa00f284b>] ? ixgbe_poll+0xe3b/0x1140 [ixgbe]
> [23099.151900]  [<ffffffff81560c94>] process_backlog+0xf4/0x1e0
> [23099.151902]  [<ffffffff815619c5>] net_rx_action+0xf5/0x260
> [23099.151906]  [<ffffffff810509c7>] __do_softirq+0xc7/0x230
> [23099.151908]  [<ffffffff816757cc>] call_softirq+0x1c/0x30
> [23099.151912]  [<ffffffff81004475>] do_softirq+0x55/0x90
> [23099.151914]  [<ffffffff810507c5>] irq_exit+0x85/0xa0
> [23099.151916]  [<ffffffff81675d16>] do_IRQ+0x66/0xe0
> [23099.151920]  [<ffffffff8166c8aa>] common_interrupt+0x6a/0x6a
> [23099.151920]  <EOI>  [<ffffffff8166b17a>] ? __schedule+0x3aa/0x750
> [23099.151926]  [<ffffffff8100b2ed>] ? mwait_idle+0xad/0x1f0
> [23099.151928]  [<ffffffff8100a7a3>] cpu_idle+0xb3/0x100
> [23099.151931]  [<ffffffff816632e3>] start_secondary+0x1c9/0x1d0
>
> Under 3.8.2:
>
> [33486.326977] IPv4: Attempt to release TCP socket in state 1
> ffff883269ea2300
> [33486.342971] IPv4: Attempt to release TCP socket in state 1
> ffff8835efccbf00
> [33505.595925] ------------[ cut here ]------------
> [33505.595934] WARNING: at net/sched/sch_generic.c:254
> dev_watchdog+0x258/0x270()
> [33505.595935] Hardware name: X9DR3-F
> [33505.595937] NETDEV WATCHDOG: eth2 (ixgbe): transmit queue 0 timed out
> [33505.595938] Modules linked in: macvlan iptable_nat nf_nat_ipv4 nf_nat
> bridge coretemp ghash_clmulni_intel gpio_ich ixgbe microcode sb_edac mei
> lpc_ich edac_core mfd_core mdio isci libsas igb ptp pps_core
> [33505.595951] Pid: 0, comm: swapper/4 Not tainted 3.8.2 #2
> [33505.595952] Call Trace:
> [33505.595954]  <IRQ>  [<ffffffff8104964f>] warn_slowpath_common+0x7f/0xc0
> [33505.595960]  [<ffffffff81049746>] warn_slowpath_fmt+0x46/0x50
> [33505.595962]  [<ffffffff815a1548>] dev_watchdog+0x258/0x270
> [33505.595965]  [<ffffffff815a12f0>] ? __netdev_watchdog_up+0x80/0x80
> [33505.595968]  [<ffffffff81059259>] call_timer_fn+0x49/0x130
> [33505.595972]  [<ffffffff8107a07f>] ? scheduler_tick+0x15f/0x190
> [33505.595974]  [<ffffffff81059854>] run_timer_softirq+0x224/0x290
> [33505.595976]  [<ffffffff81058f76>] ? update_process_times+0x76/0x90
> [33505.595978]  [<ffffffff815a12f0>] ? __netdev_watchdog_up+0x80/0x80
> [33505.595981]  [<ffffffff8108ebd4>] ? ktime_get+0x54/0xe0
> [33505.595983]  [<ffffffff810518a7>] __do_softirq+0xc7/0x230
> [33505.595987]  [<ffffffff8168fe0c>] call_softirq+0x1c/0x30
> [33505.595990]  [<ffffffff81004415>] do_softirq+0x55/0x90
> [33505.595993]  [<ffffffff810516a5>] irq_exit+0x85/0xa0
> [33505.595996]  [<ffffffff8169042e>] smp_apic_timer_interrupt+0x6e/0x99
> [33505.596000]  [<ffffffff8168f80a>] apic_timer_interrupt+0x6a/0x70
> [33505.596002]  <EOI>  [<ffffffff8168567c>] ? __schedule+0x3ac/0x750
> [33505.596009]  [<ffffffff8100b1fd>] ? mwait_idle+0xad/0x1f0
> [33505.596011]  [<ffffffff8100a743>] cpu_idle+0xb3/0x100
> [33505.596014]  [<ffffffff8167d7d2>] start_secondary+0x1d7/0x1de
> [33505.596015] ---[ end trace 3d817d7c7ae67386 ]---
> [33505.596064] ixgbe 0000:83:00.0 eth2: Reset adapter
> [33556.011932] INFO: rcu_sched self-detected stall on CPU { 24}  (t=15001
> jiffies g=1985385 c=1985384 q=270786)
> [33556.011968] Pid: 0, comm: swapper/24 Tainted: G        W    3.8.2 #2
> [33556.011970] Call Trace:
> [33556.011972]  <IRQ>  [<ffffffff810bea1e>]
> rcu_check_callbacks+0x21e/0x7c0
> [33556.011986]  [<ffffffff8107f518>] ? account_system_time+0xe8/0x1e0
> [33556.011992]  [<ffffffff81058f48>] update_process_times+0x48/0x90
> [33556.011996]  [<ffffffff81095e06>] tick_sched_timer+0x56/0x130
> [33556.012000]  [<ffffffff8107099d>] __run_hrtimer+0x7d/0x1c0
> [33556.012002]  [<ffffffff81095db0>] ? tick_setup_sched_timer+0x110/0x110
> [33556.012004]  [<ffffffff81070d56>] hrtimer_interrupt+0xf6/0x230
> [33556.012010]  [<ffffffff81690429>] smp_apic_timer_interrupt+0x69/0x99
> [33556.012013]  [<ffffffff8168f80a>] apic_timer_interrupt+0x6a/0x70
> [33556.012017]  [<ffffffff815d3deb>] ?
> __inet_lookup_established+0xcb/0x2d0
> [33556.012020]  [<ffffffff815cab80>] ? inet_del_protocol+0x40/0x40
> [33556.012024]  [<ffffffff815f078c>] tcp_v4_early_demux+0xac/0x170
> [33556.012025]  [<ffffffff815caccd>] ip_rcv_finish+0x14d/0x360
> [33556.012027]  [<ffffffff815cb246>] ip_rcv+0x226/0x310
> [33556.012032]  [<ffffffff815841a2>] __netif_receive_skb+0x492/0x640
> [33556.012034]  [<ffffffff8158455d>] netif_receive_skb+0x2d/0x90
> [33556.012036]  [<ffffffff815ed450>] ? tcp4_gro_receive+0xb0/0x130
> [33556.012038]  [<ffffffff81584655>] napi_gro_complete+0x95/0xe0
> [33556.012040]  [<ffffffff81584956>] dev_gro_receive+0x2b6/0x3b0
> [33556.012043]  [<ffffffff8158508b>] napi_gro_receive+0x5b/0x130
> [33556.012051]  [<ffffffffa01db04a>] ixgbe_poll+0x54a/0x1180 [ixgbe]
> [33556.012054]  [<ffffffff810792fa>] ? enqueue_task+0x6a/0x80
> [33556.012056]  [<ffffffff81584c15>] net_rx_action+0xf5/0x260
> [33556.012058]  [<ffffffff810518a7>] __do_softirq+0xc7/0x230
> [33556.012061]  [<ffffffff8168fe0c>] call_softirq+0x1c/0x30
> [33556.012064]  [<ffffffff81004415>] do_softirq+0x55/0x90
> [33556.012066]  [<ffffffff810516a5>] irq_exit+0x85/0xa0
> [33556.012068]  [<ffffffff81690346>] do_IRQ+0x66/0xe0
> [33556.012071]  [<ffffffff81686daa>] common_interrupt+0x6a/0x6a
> [33556.012073]  <EOI>  [<ffffffff8168567c>] ? __schedule+0x3ac/0x750
> [33556.012078]  [<ffffffff8100b1fd>] ? mwait_idle+0xad/0x1f0
> [33556.012080]  [<ffffffff8100a743>] cpu_idle+0xb3/0x100
> [33556.012082]  [<ffffffff8167d7d2>] start_secondary+0x1d7/0x1de
> [33716.090584] INFO: task kworker/4:2:882 blocked for more than 120
> seconds.
> [33716.090602] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables
> this message.
> [33716.090618] kworker/4:2     D ffffffff81807160     0   882      2
> 0x00000000
> [33716.090622]  ffff881fd2547ad8 0000000000000046 ffff881fd0ac2dc0
> 0000000000012700
> [33716.090624]  ffff881fd2547fd8 ffff881fd2546010 0000000000012700
> 0000000000012700
> [33716.090626]  ffff881fd2547fd8 0000000000012700 ffff881fd3655b80
> ffff881fd0ac2dc0
> [33716.090628] Call Trace:
> [33716.090639]  [<ffffffff81685ae9>] schedule+0x29/0x70
> [33716.090642]  [<ffffffff81683de5>] schedule_timeout+0x165/0x200
> [33716.090647]  [<ffffffff810283fe>] ? physflat_send_IPI_mask+0xe/0x10
> [33716.090650]  [<ffffffff8107d02e>] ? try_to_wake_up+0x23e/0x2b0
> [33716.090653]  [<ffffffff81685158>] wait_for_common+0xc8/0x160
> [33716.090654]  [<ffffffff8107d0a0>] ? try_to_wake_up+0x2b0/0x2b0
> [33716.090660]  [<ffffffff810bc890>] ? rcu_cpu_stall_reset+0x60/0x60
> [33716.090662]  [<ffffffff816852cd>] wait_for_completion+0x1d/0x20
> [33716.090665]  [<ffffffff810b2536>] __stop_cpus+0x56/0x80
> [33716.090667]  [<ffffffff810bc890>] ? rcu_cpu_stall_reset+0x60/0x60
> [33716.090669]  [<ffffffff810b25ad>] try_stop_cpus+0x4d/0x80
> [33716.090672]  [<ffffffff810bf0bb>]
> synchronize_sched_expedited+0xfb/0x1d0
> [33716.090674]  [<ffffffff810bf19e>] synchronize_rcu_expedited+0xe/0x10
> [33716.090678]  [<ffffffff8157e1f5>] synchronize_net+0x25/0x30
> [33716.090683]  [<ffffffff815a1bc4>] dev_deactivate_many+0x254/0x260
> [33716.090685]  [<ffffffff815a1bfd>] dev_deactivate+0x2d/0x40
> [33716.090688]  [<ffffffff81593dc4>] linkwatch_do_dev+0x34/0x60
> [33716.090690]  [<ffffffff81593fa3>] __linkwatch_run_queue+0xf3/0x1e0
> [33716.090692]  [<ffffffff815940b5>] linkwatch_event+0x25/0x30
> [33716.090696]  [<ffffffff810653f8>] process_one_work+0x168/0x450
> [33716.090699]  [<ffffffff8106757b>] worker_thread+0x12b/0x3d0
> [33716.090702]  [<ffffffff81067450>] ? manage_workers+0x300/0x300
> [33716.090704]  [<ffffffff8106c5ee>] kthread+0xce/0xe0
> [33716.090706]  [<ffffffff8106c520>] ?
> kthread_freezable_should_stop+0x70/0x70
> [33716.090709]  [<ffffffff8168ec5c>] ret_from_fork+0x7c/0xb0
> [33716.090711]  [<ffffffff8106c520>] ?
> kthread_freezable_should_stop+0x70/0x70
>
> [more hung processes bailing]
>
> [37335.739761] INFO: rcu_sched self-detected stall on CPU { 24}  (t=960083
> jiffies g=1985385 c=1985384 q=19390495)
> [37335.739828] Pid: 0, comm: swapper/24 Tainted: G        W    3.8.2 #2
> [37335.739830] Call Trace:
> [37335.739832]  <IRQ>  [<ffffffff810bea1e>]
> rcu_check_callbacks+0x21e/0x7c0
> [37335.739847]  [<ffffffff8107f518>] ? account_system_time+0xe8/0x1e0
> [37335.739853]  [<ffffffff81058f48>] update_process_times+0x48/0x90
> [37335.739857]  [<ffffffff81095e06>] tick_sched_timer+0x56/0x130
> [37335.739860]  [<ffffffff8107099d>] __run_hrtimer+0x7d/0x1c0
> [37335.739863]  [<ffffffff81095db0>] ? tick_setup_sched_timer+0x110/0x110
> [37335.739865]  [<ffffffff81070d56>] hrtimer_interrupt+0xf6/0x230
> [37335.739871]  [<ffffffff81690429>] smp_apic_timer_interrupt+0x69/0x99
> [37335.739874]  [<ffffffff8168f80a>] apic_timer_interrupt+0x6a/0x70
> [37335.739878]  [<ffffffff815d3def>] ?
> __inet_lookup_established+0xcf/0x2d0
> [37335.739880]  [<ffffffff815cab80>] ? inet_del_protocol+0x40/0x40
> [37335.739884]  [<ffffffff815f078c>] tcp_v4_early_demux+0xac/0x170
> [37335.739886]  [<ffffffff815caccd>] ip_rcv_finish+0x14d/0x360
> [37335.739888]  [<ffffffff815cb246>] ip_rcv+0x226/0x310
> [37335.739892]  [<ffffffff815841a2>] __netif_receive_skb+0x492/0x640
> [37335.739895]  [<ffffffff8158455d>] netif_receive_skb+0x2d/0x90
> [37335.739897]  [<ffffffff815ed450>] ? tcp4_gro_receive+0xb0/0x130
> [37335.739899]  [<ffffffff81584655>] napi_gro_complete+0x95/0xe0
> [37335.739901]  [<ffffffff81584956>] dev_gro_receive+0x2b6/0x3b0
> [37335.739903]  [<ffffffff8158508b>] napi_gro_receive+0x5b/0x130
> [37335.739911]  [<ffffffffa01db04a>] ixgbe_poll+0x54a/0x1180 [ixgbe]
> [37335.739915]  [<ffffffff810792fa>] ? enqueue_task+0x6a/0x80
> [37335.739917]  [<ffffffff81584c15>] net_rx_action+0xf5/0x260
> [37335.739919]  [<ffffffff810518a7>] __do_softirq+0xc7/0x230
> [37335.739922]  [<ffffffff8168fe0c>] call_softirq+0x1c/0x30
> [37335.739927]  [<ffffffff81004415>] do_softirq+0x55/0x90
> [37335.739928]  [<ffffffff810516a5>] irq_exit+0x85/0xa0
> [37335.739931]  [<ffffffff81690346>] do_IRQ+0x66/0xe0
> [37335.739937]  [<ffffffff81686daa>] common_interrupt+0x6a/0x6a
> [37335.739938]  <EOI>  [<ffffffff8168567c>] ? __schedule+0x3ac/0x750
> [37335.739943]  [<ffffffff8100b1fd>] ? mwait_idle+0xad/0x1f0
> [37335.739945]  [<ffffffff8100a743>] cpu_idle+0xb3/0x100
> [37335.739948]  [<ffffffff8167d7d2>] start_secondary+0x1d7/0x1de
> [37515.727179] INFO: rcu_sched self-detected stall on CPU { 24}
> (t=1005087 jiffies g=1985385 c=1985384 q=20855557)
> [37515.727246] Pid: 0, comm: swapper/24 Tainted: G        W    3.8.2 #2
> [37515.727249] Call Trace:
> [37515.727251]  <IRQ>  [<ffffffff810bea1e>]
> rcu_check_callbacks+0x21e/0x7c0
> [37515.727265]  [<ffffffff8107f518>] ? account_system_time+0xe8/0x1e0
> [37515.727271]  [<ffffffff81058f48>] update_process_times+0x48/0x90
> [37515.727275]  [<ffffffff81095e06>] tick_sched_timer+0x56/0x130
> [37515.727279]  [<ffffffff8107099d>] __run_hrtimer+0x7d/0x1c0
> [37515.727281]  [<ffffffff81095db0>] ? tick_setup_sched_timer+0x110/0x110
> [37515.727283]  [<ffffffff81070d56>] hrtimer_interrupt+0xf6/0x230
> [37515.727289]  [<ffffffff81690429>] smp_apic_timer_interrupt+0x69/0x99
> [37515.727292]  [<ffffffff8168f80a>] apic_timer_interrupt+0x6a/0x70
> [37515.727296]  [<ffffffff815d3deb>] ?
> __inet_lookup_established+0xcb/0x2d0
> [37515.727298]  [<ffffffff815cab80>] ? inet_del_protocol+0x40/0x40
> [37515.727302]  [<ffffffff815f078c>] tcp_v4_early_demux+0xac/0x170
> [37515.727304]  [<ffffffff815caccd>] ip_rcv_finish+0x14d/0x360
> [37515.727306]  [<ffffffff815cb246>] ip_rcv+0x226/0x310
> [37515.727310]  [<ffffffff815841a2>] __netif_receive_skb+0x492/0x640
> [37515.727312]  [<ffffffff8158455d>] netif_receive_skb+0x2d/0x90
> [37515.727315]  [<ffffffff815ed450>] ? tcp4_gro_receive+0xb0/0x130
> [37515.727317]  [<ffffffff81584655>] napi_gro_complete+0x95/0xe0
> [37515.727319]  [<ffffffff81584956>] dev_gro_receive+0x2b6/0x3b0
> [37515.727322]  [<ffffffff8158508b>] napi_gro_receive+0x5b/0x130
> [37515.727330]  [<ffffffffa01db04a>] ixgbe_poll+0x54a/0x1180 [ixgbe]
> [37515.727334]  [<ffffffff810792fa>] ? enqueue_task+0x6a/0x80
> [37515.727336]  [<ffffffff81584c15>] net_rx_action+0xf5/0x260
> [37515.727338]  [<ffffffff810518a7>] __do_softirq+0xc7/0x230
> [37515.727341]  [<ffffffff8168fe0c>] call_softirq+0x1c/0x30
> [37515.727345]  [<ffffffff81004415>] do_softirq+0x55/0x90
> [37515.727346]  [<ffffffff810516a5>] irq_exit+0x85/0xa0
> [37515.727349]  [<ffffffff81690346>] do_IRQ+0x66/0xe0
> [37515.727354]  [<ffffffff81686daa>] common_interrupt+0x6a/0x6a
> [37515.727355]  <EOI>  [<ffffffff8168567c>] ? __schedule+0x3ac/0x750
> [37515.727360]  [<ffffffff8100b1fd>] ? mwait_idle+0xad/0x1f0
> [37515.727362]  [<ffffffff8100a743>] cpu_idle+0xb3/0x100
> [37515.727365]  [<ffffffff8167d7d2>] start_secondary+0x1d7/0x1de
>
> ... then swapped just does this until someone reboots the box.
>
> Apologies for the ugly paste.
>
> Thanks,
> -Dormando
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
