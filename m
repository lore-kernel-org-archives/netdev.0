From: Gabriel C <nix.or.die@gmail.com>
Subject: regression: ath_tx_edma_tasklet() Illegal idle entry in RCU read-side
 critical section
Date: Sun, 18 Dec 2016 14:52:48 +0100
Message-ID: <23a2a3ab-974a-ed26-6afa-aafab9bb972e@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ath9k-devel@qca.qualcomm.com, linux-wireless@vger.kernel.org,
        ath9k-devel@lists.ath9k.org,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        netdev@vger.kernel.org
To: lkml <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

while testing kernel 4.9 I run into a weird issue with the ath9k driver.

I can boot the box in console mode and it stay up sometime but is not usable.


from dmesg :

===============================
[ INFO: suspicious RCU usage. ]
4.9-fw1 #1 Tainted: G          I
-------------------------------
kernel/rcu/tree.c:705 Illegal idle entry in RCU read-side critical section.!

other info that might help us debug this:


RCU used illegally from idle CPU!
rcu_scheduler_active = 1, debug_locks = 1
RCU used illegally from extended quiescent state!
1 lock held by swapper/0/0:
  #0:  (rcu_read_lock){......}, at: [<ffffffffa0ee0240>] ath_tx_edma_tasklet+0x0/0x460 [ath9k]

stack backtrace:
CPU: 0 PID: 0 Comm: swapper/0 Tainted: G          I     4.9-fw1 #1
Hardware name: FUJITSU                          PRIMERGY TX200 S5             /D2709, BIOS 6.00 Rev. 1.14.2709              02/04/2013
  ffff88043ee03f38 ffffffff812cf0f3 ffffffff81a11540 0000000000000001
  ffff88043ee03f68 ffffffff810b7865 ffffffff81a55d58 ffff88043efcedc0
  ffff88083cb1ca00 00000000000000d1 ffff88043ee03f88 ffffffff810dbfe8
Call Trace:
  <IRQ>
  [<ffffffff812cf0f3>] dump_stack+0x86/0xc3
  [<ffffffff810b7865>] lockdep_rcu_suspicious+0xc5/0x100
  [<ffffffff810dbfe8>] rcu_eqs_enter_common.constprop.62+0x128/0x130
  [<ffffffff810ddc78>] rcu_irq_exit+0x38/0x70
  [<ffffffff81067ec4>] irq_exit+0x74/0xd0
  [<ffffffff8101e561>] do_IRQ+0x71/0x130
  [<ffffffff8158700c>] common_interrupt+0x8c/0x8c
  <EOI>
  [<ffffffff81472836>] ? cpuidle_enter_state+0x156/0x220
  [<ffffffff81472922>] cpuidle_enter+0x12/0x20
  [<ffffffff810ad23e>] call_cpuidle+0x1e/0x40
  [<ffffffff810ad46d>] cpu_startup_entry+0x11d/0x210
  [<ffffffff8157892c>] rest_init+0x12c/0x140
  [<ffffffff81d02ec3>] start_kernel+0x40f/0x41c
  [<ffffffff81d02120>] ? early_idt_handler_array+0x120/0x120
  [<ffffffff81d02299>] x86_64_start_reservations+0x2a/0x2c
  [<ffffffff81d02386>] x86_64_start_kernel+0xeb/0xf8

...

perf: interrupt took too long (2766 > 2500), lowering kernel.perf_event_max_sample_rate to 72000
perf: interrupt took too long (3510 > 3457), lowering kernel.perf_event_max_sample_rate to 56000
perf: interrupt took too long (4689 > 4387), lowering kernel.perf_event_max_sample_rate to 42000
perf: interrupt took too long (5980 > 5861), lowering kernel.perf_event_max_sample_rate to 33000
INFO: rcu_preempt detected stalls on CPUs/tasks:
	Tasks blocked on level-0 rcu_node (CPUs 0-15): P0
	(detected by 5, t=65002 jiffies, g=3241, c=3240, q=8520)
swapper/0       R  running task        0     0      0 0x00000000
  ffffffff81a03e90 ffffffff8139bf30 ffffffff81ae30b8 00000000810253a9
  ffff88083cb1e600 ffffffff81ae30a0 0000000000000002 ffffffff81ae30b8
  ffffffff81ae2fe0 ffffffff81a03ed0 ffffffff81472814 0000001823671b47
Call Trace:
  [<ffffffff8139bf30>] ? acpi_idle_enter+0x116/0x1fb
  [<ffffffff81472814>] ? cpuidle_enter_state+0x134/0x220
  [<ffffffff81472922>] ? cpuidle_enter+0x12/0x20
  [<ffffffff810ad23e>] ? call_cpuidle+0x1e/0x40
  [<ffffffff810ad46d>] ? cpu_startup_entry+0x11d/0x210
  [<ffffffff8157892c>] ? rest_init+0x12c/0x140
  [<ffffffff81d02ec3>] ? start_kernel+0x40f/0x41c
  [<ffffffff81d02120>] ? early_idt_handler_array+0x120/0x120
  [<ffffffff81d02299>] ? x86_64_start_reservations+0x2a/0x2c
  [<ffffffff81d02386>] ? x86_64_start_kernel+0xeb/0xf8
swapper/0       R  running task        0     0      0 0x00000000
  ffffffff81a03e90 ffffffff8139bf30 ffffffff81ae30b8 00000000810253a9
  ffff88083cb1e600 ffffffff81ae30a0 0000000000000002 ffffffff81ae30b8
  ffffffff81ae2fe0 ffffffff81a03ed0 ffffffff81472814 0000001823671b47
Call Trace:
  [<ffffffff8139bf30>] ? acpi_idle_enter+0x116/0x1fb
  [<ffffffff81472814>] ? cpuidle_enter_state+0x134/0x220
  [<ffffffff81472922>] ? cpuidle_enter+0x12/0x20
  [<ffffffff810ad23e>] ? call_cpuidle+0x1e/0x40
  [<ffffffff810ad46d>] ? cpu_startup_entry+0x11d/0x210
  [<ffffffff8157892c>] ? rest_init+0x12c/0x140
  [<ffffffff81d02ec3>] ? start_kernel+0x40f/0x41c
  [<ffffffff81d02120>] ? early_idt_handler_array+0x120/0x120
  [<ffffffff81d02299>] ? x86_64_start_reservations+0x2a/0x2c
  [<ffffffff81d02386>] ? x86_64_start_kernel+0xeb/0xf8
perf: interrupt took too long (7746 > 7475), lowering kernel.perf_event_max_sample_rate to 25000
systemd-hostnamed.service: State 'stop-sigterm' timed out. Killing.
systemd-hostnamed.service: Killing process 1507 (systemd-hostnam) with signal SIGKILL.
perf: interrupt took too long (10065 > 9682), lowering kernel.perf_event_max_sample_rate to 19000
perf: interrupt took too long (12596 > 12581), lowering kernel.perf_event_max_sample_rate to 15000
INFO: task systemd-hostnam:1507 blocked for more than 120 seconds.
       Tainted: G          I     4.9-fw1 #1
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
systemd-hostnam D    0  1507      1 0x00000002
  ffff88043a29f200 000000000000c460 ffff88043ab0a1c0 ffff88043cdc0000
  ffff88043f9d6718 ffffc9000b67fb88 ffffffff8157ff6e ffffc9000b67fbf8
  ffff88043ab0abc0 ffff88043f9d6718 0000000000000000 ffff88043ab0a1c0
Call Trace:
  [<ffffffff8157ff6e>] ? __schedule+0x2ce/0x810
  [<ffffffff815804eb>] schedule+0x3b/0x90
  [<ffffffff81584e82>] schedule_timeout+0x222/0x3a0
  [<ffffffff812fe1f7>] ? debug_smp_processor_id+0x17/0x20
  [<ffffffff812fe1f7>] ? debug_smp_processor_id+0x17/0x20
  [<ffffffff810b5de9>] ? get_lock_stats+0x19/0x50
  [<ffffffff81585d17>] ? _raw_spin_unlock_irq+0x27/0x50
  [<ffffffff812fe213>] ? __this_cpu_preempt_check+0x13/0x20
  [<ffffffff810b92cf>] ? trace_hardirqs_on_caller+0xef/0x200
  [<ffffffff81580ffa>] wait_for_common+0xca/0x180
  [<ffffffff8108e150>] ? wake_up_q+0x80/0x80
  [<ffffffff815810c8>] wait_for_completion+0x18/0x20
  [<ffffffff810d82e5>] __wait_rcu_gp+0xc5/0x100
  [<ffffffff810dbccd>] synchronize_rcu.part.53+0x2d/0x50
  [<ffffffff810dc7e0>] ? __call_rcu.constprop.59+0x270/0x270
  [<ffffffff810d8210>] ? rcu_panic+0x20/0x20
  [<ffffffff81580f69>] ? wait_for_common+0x39/0x180
  [<ffffffff810dbd17>] synchronize_rcu+0x27/0x90
  [<ffffffff811fd887>] namespace_unlock+0x47/0x60
  [<ffffffff81200639>] drop_collected_mounts+0x89/0x90
  [<ffffffff8120246b>] ? put_mnt_ns+0x1b/0x30
  [<ffffffff8120246b>] put_mnt_ns+0x1b/0x30
  [<ffffffff81085798>] free_nsproxy+0x18/0xb0
  [<ffffffff8108593e>] switch_task_namespaces+0x5e/0x70
  [<ffffffff8108595b>] exit_task_namespaces+0xb/0x10
  [<ffffffff8106652e>] do_exit+0x2de/0xb30
  [<ffffffff812fe213>] ? __this_cpu_preempt_check+0x13/0x20
  [<ffffffff810b92cf>] ? trace_hardirqs_on_caller+0xef/0x200
  [<ffffffff81066e00>] do_group_exit+0x40/0xc0
  [<ffffffff81066e8f>] SyS_exit_group+0xf/0x10
  [<ffffffff81586681>] entry_SYSCALL_64_fastpath+0x1f/0xc2
  [<ffffffff812fe213>] ? __this_cpu_preempt_check+0x13/0x20

Showing all locks held in the system:
2 locks held by khungtaskd/108:
  #0:  (rcu_read_lock){......}, at: [<ffffffff811269af>] watchdog+0x9f/0x490
  #1:  (tasklist_lock){.+.+..}, at: [<ffffffff810b760d>] debug_show_all_locks+0x3d/0x1a0

=============================================

systemd-hostnamed.service: Processes still around after SIGKILL. Ignoring.
INFO: rcu_preempt detected stalls on CPUs/tasks:
	Tasks blocked on level-0 rcu_node (CPUs 0-15): P0
	(detected by 9, t=260007 jiffies, g=3241, c=3240, q=12143)
swapper/0       R  running task        0     0      0 0x00000000
  ffffffff81a11540 000000000000001f 0000000000000007 ffffffff817d2a6f
  ffffffff817a0867 ffffffffffffffcf ffffffff81472836 0000000000000010
  0000000000000212 ffffffff81a03ea0 ffffffff81085cb8 ffffffff81085c70
Call Trace:
  [<ffffffff8139bf30>] ? acpi_idle_enter+0x116/0x1fb
  [<ffffffff81472814>] ? cpuidle_enter_state+0x134/0x220
  [<ffffffff81472922>] ? cpuidle_enter+0x12/0x20
  [<ffffffff810ad23e>] ? call_cpuidle+0x1e/0x40
  [<ffffffff810ad46d>] ? cpu_startup_entry+0x11d/0x210
  [<ffffffff8157892c>] ? rest_init+0x12c/0x140
  [<ffffffff81d02ec3>] ? start_kernel+0x40f/0x41c
  [<ffffffff81d02120>] ? early_idt_handler_array+0x120/0x120
  [<ffffffff81d02299>] ? x86_64_start_reservations+0x2a/0x2c
  [<ffffffff81d02386>] ? x86_64_start_kernel+0xeb/0xf8
swapper/0       R  running task        0     0      0 0x00000000
  ffffffff81a03e90 ffffffff8139bf30 ffffffff81ae30b8 00000000810253a9
  ffff88083cb1e600 ffffffff81ae30a0 0000000000000002 ffffffff81ae30b8
  ffffffff81ae2fe0 ffffffff81a03ed0 ffffffff81472814 000000458b315be4
Call Trace:
  [<ffffffff8139bf30>] ? acpi_idle_enter+0x116/0x1fb
  [<ffffffff81472814>] ? cpuidle_enter_state+0x134/0x220
  [<ffffffff81472922>] ? cpuidle_enter+0x12/0x20
  [<ffffffff810ad23e>] ? call_cpuidle+0x1e/0x40
  [<ffffffff810ad46d>] ? cpu_startup_entry+0x11d/0x210
  [<ffffffff8157892c>] ? rest_init+0x12c/0x140
  [<ffffffff81d02ec3>] ? start_kernel+0x40f/0x41c
  [<ffffffff81d02120>] ? early_idt_handler_array+0x120/0x120
  [<ffffffff81d02299>] ? x86_64_start_reservations+0x2a/0x2c
  [<ffffffff81d02386>] ? x86_64_start_kernel+0xeb/0xf8
systemd-hostnamed.service: State 'stop-final-sigterm' timed out. Killing.
systemd-hostnamed.service: Killing process 1507 (systemd-hostnam) with signal SIGKILL.
INFO: task systemd-hostnam:1507 blocked for more than 120 seconds.
       Tainted: G          I     4.9-fw1 #1
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
systemd-hostnam D    0  1507      1 0x00000002
  ffff88043a29f200 000000000000c460 ffff88043ab0a1c0 ffff88043cdc0000
  ffff88043f9d6718 ffffc9000b67fb88 ffffffff8157ff6e ffffc9000b67fbf8
  ffff88043ab0abc0 ffff88043f9d6718 0000000000000000 ffff88043ab0a1c0
Call Trace:
  [<ffffffff8157ff6e>] ? __schedule+0x2ce/0x810
  [<ffffffff815804eb>] schedule+0x3b/0x90
  [<ffffffff81584e82>] schedule_timeout+0x222/0x3a0
  [<ffffffff812fe1f7>] ? debug_smp_processor_id+0x17/0x20
  [<ffffffff812fe1f7>] ? debug_smp_processor_id+0x17/0x20
  [<ffffffff810b5de9>] ? get_lock_stats+0x19/0x50
  [<ffffffff81585d17>] ? _raw_spin_unlock_irq+0x27/0x50
  [<ffffffff812fe213>] ? __this_cpu_preempt_check+0x13/0x20
  [<ffffffff810b92cf>] ? trace_hardirqs_on_caller+0xef/0x200
  [<ffffffff81580ffa>] wait_for_common+0xca/0x180
  [<ffffffff8108e150>] ? wake_up_q+0x80/0x80
  [<ffffffff815810c8>] wait_for_completion+0x18/0x20
  [<ffffffff810d82e5>] __wait_rcu_gp+0xc5/0x100
  [<ffffffff810dbccd>] synchronize_rcu.part.53+0x2d/0x50
  [<ffffffff810dc7e0>] ? __call_rcu.constprop.59+0x270/0x270
  [<ffffffff810d8210>] ? rcu_panic+0x20/0x20
  [<ffffffff81580f69>] ? wait_for_common+0x39/0x180
  [<ffffffff810dbd17>] synchronize_rcu+0x27/0x90
  [<ffffffff811fd887>] namespace_unlock+0x47/0x60
  [<ffffffff81200639>] drop_collected_mounts+0x89/0x90
  [<ffffffff8120246b>] ? put_mnt_ns+0x1b/0x30
  [<ffffffff8120246b>] put_mnt_ns+0x1b/0x30
  [<ffffffff81085798>] free_nsproxy+0x18/0xb0
  [<ffffffff8108593e>] switch_task_namespaces+0x5e/0x70
  [<ffffffff8108595b>] exit_task_namespaces+0xb/0x10
  [<ffffffff8106652e>] do_exit+0x2de/0xb30
  [<ffffffff812fe213>] ? __this_cpu_preempt_check+0x13/0x20
  [<ffffffff810b92cf>] ? trace_hardirqs_on_caller+0xef/0x200
  [<ffffffff81066e00>] do_group_exit+0x40/0xc0
  [<ffffffff81066e8f>] SyS_exit_group+0xf/0x10
  [<ffffffff81586681>] entry_SYSCALL_64_fastpath+0x1f/0xc2
  [<ffffffff812fe213>] ? __this_cpu_preempt_check+0x13/0x20

Showing all locks held in the system:
2 locks held by khungtaskd/108:
  #0:  (rcu_read_lock){......}, at: [<ffffffff811269af>] watchdog+0x9f/0x490
  #1:  (tasklist_lock){.+.+..}, at: [<ffffffff810b760d>] debug_show_all_locks+0x3d/0x1a0
2 locks held by NetworkManager/1475:
  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff814c3286>] rtnetlink_rcv+0x16/0x30
  #1:  (rcu_preempt_state.exp_mutex){+.+...}, at: [<ffffffff810da7d9>] _synchronize_rcu_expedited+0x149/0x350
2 locks held by kworker/2:7/1630:
  #0:  ("events"){.+.+.+}, at: [<ffffffff8107d5c6>] process_one_work+0x1e6/0x4d0
  #1:  ((&rew.rew_work)){+.+...}, at: [<ffffffff8107d5c6>] process_one_work+0x1e6/0x4d0

=============================================

perf: interrupt took too long (15815 > 15745), lowering kernel.perf_event_max_sample_rate to 12000
INFO: rcu_preempt detected expedited stalls on CPUs/tasks: { P0 } 67953 jiffies s: 1039 root: 0x0/T
blocking rcu_node structures:
systemd-hostnamed.service: Processes still around after final SIGKILL. Entering failed mode.
systemd-hostnamed.service: Unit entered failed state.
systemd-hostnamed.service: Failed with result 'timeout'.
Starting system activity accounting tool...
INFO: task NetworkManager:1475 blocked for more than 120 seconds.
       Tainted: G          I     4.9-fw1 #1
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
NetworkManager  D    0  1475      1 0x00000000
  ffff88083a8eaf80 000000000000d4d0 ffff88083955c380 ffff8804371d4380
  ffff88043f3d6718 ffffc90007f57640 ffffffff8157ff6e ffffc90007f57608
  ffff88083955cd80 ffff88043f3d6718 0000000000000000 ffff88083955c380
Call Trace:
  [<ffffffff8157ff6e>] ? __schedule+0x2ce/0x810
  [<ffffffff815804eb>] schedule+0x3b/0x90
  [<ffffffff810da9d4>] _synchronize_rcu_expedited+0x344/0x350
  [<ffffffff810da5c0>] ? rcu_momentary_dyntick_idle+0xa0/0xa0
  [<ffffffff810acd10>] ? wake_atomic_t_function+0x50/0x50
  [<ffffffff810da5c0>] ? rcu_momentary_dyntick_idle+0xa0/0xa0
  [<ffffffff810dacf0>] ? rcu_seq_end+0x40/0x40
  [<ffffffff810daca7>] synchronize_rcu_expedited+0x17/0x20
  [<ffffffff814aaf6c>] synchronize_net+0x2c/0x30
  [<ffffffff814daf8c>] dev_deactivate_many+0x2cc/0x2e0
  [<ffffffff814a6971>] __dev_close_many+0x71/0xe0
  [<ffffffff814a6b21>] __dev_close+0x31/0x50
  [<ffffffff814b16a8>] __dev_change_flags+0x98/0x160
  [<ffffffff814b1794>] dev_change_flags+0x24/0x60
  [<ffffffff810253a9>] ? sched_clock+0x9/0x10
  [<ffffffff814c3c96>] do_setlink+0x2e6/0xcc0
  [<ffffffff810b9b64>] ? __lock_acquire+0x454/0x1b00
  [<ffffffff813081c1>] ? nla_parse+0x31/0x120
  [<ffffffff814c6750>] rtnl_newlink+0x5c0/0x860
  [<ffffffff812fe1f7>] ? debug_smp_processor_id+0x17/0x20
  [<ffffffff810b5de9>] ? get_lock_stats+0x19/0x50
  [<ffffffff814c6a6f>] rtnetlink_rcv_msg+0x7f/0x1e0
  [<ffffffff8158178a>] ? mutex_lock_nested+0x2fa/0x430
  [<ffffffff814c3286>] ? rtnetlink_rcv+0x16/0x30
  [<ffffffff814c3286>] ? rtnetlink_rcv+0x16/0x30
  [<ffffffff814c69f0>] ? rtnl_newlink+0x860/0x860
  [<ffffffff814e7eef>] netlink_rcv_skb+0x9f/0xc0
  [<ffffffff814c3295>] rtnetlink_rcv+0x25/0x30
  [<ffffffff814e7865>] netlink_unicast+0x155/0x1f0
  [<ffffffff814e7cad>] netlink_sendmsg+0x2dd/0x360
  [<ffffffff8148d682>] sock_sendmsg+0x12/0x20
  [<ffffffff8148ddfc>] ___sys_sendmsg+0x2ac/0x2c0
  [<ffffffff812fe1f7>] ? debug_smp_processor_id+0x17/0x20
  [<ffffffff811fb60b>] ? __fget+0x10b/0x1f0
  [<ffffffff811fb500>] ? expand_files+0x2a0/0x2a0
  [<ffffffff811fb730>] ? __fget_light+0x20/0x60
  [<ffffffff8148ed60>] __sys_sendmsg+0x40/0x70
  [<ffffffff8148ed9d>] SyS_sendmsg+0xd/0x20
  [<ffffffff81586681>] entry_SYSCALL_64_fastpath+0x1f/0xc2
  [<ffffffff812fe213>] ? __this_cpu_preempt_check+0x13/0x20

Showing all locks held in the system:
2 locks held by khungtaskd/108:
  #0:  (rcu_read_lock){......}, at: [<ffffffff811269af>] watchdog+0x9f/0x490
  #1:  (tasklist_lock){.+.+..}, at: [<ffffffff810b760d>] debug_show_all_locks+0x3d/0x1a0
1 lock held by sd-resolve/1445:
  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff814c3286>] rtnetlink_rcv+0x16/0x30
2 locks held by NetworkManager/1475:
  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff814c3286>] rtnetlink_rcv+0x16/0x30
  #1:  (rcu_preempt_state.exp_mutex){+.+...}, at: [<ffffffff810da7d9>] _synchronize_rcu_expedited+0x149/0x350
2 locks held by kworker/2:7/1630:
  #0:  ("events"){.+.+.+}, at: [<ffffffff8107d5c6>] process_one_work+0x1e6/0x4d0
  #1:  ((&rew.rew_work)){+.+...}, at: [<ffffffff8107d5c6>] process_one_work+0x1e6/0x4d0
2 locks held by nano/2071:
  #0:  (&tty->ldisc_sem){++++.+}, at: [<ffffffff8158549d>] ldsem_down_read+0x2d/0x40
  #1:  (&ldata->atomic_read_lock){+.+...}, at: [<ffffffff813c4363>] n_tty_read+0xb3/0x8e0

=============================================

INFO: task systemd-hostnam:1507 blocked for more than 120 seconds.
       Tainted: G          I     4.9-fw1 #1
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
systemd-hostnam D    0  1507      1 0x00000002
  ffff88043a29f200 000000000000c460 ffff88043ab0a1c0 ffff88043cdc0000
  ffff88043f9d6718 ffffc9000b67fb88 ffffffff8157ff6e ffffc9000b67fbf8
  ffff88043ab0abc0 ffff88043f9d6718 0000000000000000 ffff88043ab0a1c0
Call Trace:
  [<ffffffff8157ff6e>] ? __schedule+0x2ce/0x810
  [<ffffffff815804eb>] schedule+0x3b/0x90
  [<ffffffff81584e82>] schedule_timeout+0x222/0x3a0
  [<ffffffff812fe1f7>] ? debug_smp_processor_id+0x17/0x20
  [<ffffffff812fe1f7>] ? debug_smp_processor_id+0x17/0x20
  [<ffffffff810b5de9>] ? get_lock_stats+0x19/0x50
  [<ffffffff81585d17>] ? _raw_spin_unlock_irq+0x27/0x50
  [<ffffffff812fe213>] ? __this_cpu_preempt_check+0x13/0x20
  [<ffffffff810b92cf>] ? trace_hardirqs_on_caller+0xef/0x200
  [<ffffffff81580ffa>] wait_for_common+0xca/0x180
  [<ffffffff8108e150>] ? wake_up_q+0x80/0x80
  [<ffffffff815810c8>] wait_for_completion+0x18/0x20
  [<ffffffff810d82e5>] __wait_rcu_gp+0xc5/0x100
  [<ffffffff810dbccd>] synchronize_rcu.part.53+0x2d/0x50
  [<ffffffff810dc7e0>] ? __call_rcu.constprop.59+0x270/0x270
  [<ffffffff810d8210>] ? rcu_panic+0x20/0x20
  [<ffffffff81580f69>] ? wait_for_common+0x39/0x180
  [<ffffffff810dbd17>] synchronize_rcu+0x27/0x90
  [<ffffffff811fd887>] namespace_unlock+0x47/0x60
  [<ffffffff81200639>] drop_collected_mounts+0x89/0x90
  [<ffffffff8120246b>] ? put_mnt_ns+0x1b/0x30
  [<ffffffff8120246b>] put_mnt_ns+0x1b/0x30
  [<ffffffff81085798>] free_nsproxy+0x18/0xb0
  [<ffffffff8108593e>] switch_task_namespaces+0x5e/0x70
  [<ffffffff8108595b>] exit_task_namespaces+0xb/0x10
  [<ffffffff8106652e>] do_exit+0x2de/0xb30
  [<ffffffff812fe213>] ? __this_cpu_preempt_check+0x13/0x20
  [<ffffffff810b92cf>] ? trace_hardirqs_on_caller+0xef/0x200
  [<ffffffff81066e00>] do_group_exit+0x40/0xc0
  [<ffffffff81066e8f>] SyS_exit_group+0xf/0x10
  [<ffffffff81586681>] entry_SYSCALL_64_fastpath+0x1f/0xc2
  [<ffffffff812fe213>] ? __this_cpu_preempt_check+0x13/0x20

Showing all locks held in the system:
2 locks held by khungtaskd/108:
  #0:  (rcu_read_lock){......}, at: [<ffffffff811269af>] watchdog+0x9f/0x490
  #1:  (tasklist_lock){.+.+..}, at: [<ffffffff810b760d>] debug_show_all_locks+0x3d/0x1a0
1 lock held by sd-resolve/1445:
  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff814c3286>] rtnetlink_rcv+0x16/0x30
2 locks held by NetworkManager/1475:
  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff814c3286>] rtnetlink_rcv+0x16/0x30
  #1:  (rcu_preempt_state.exp_mutex){+.+...}, at: [<ffffffff810da7d9>] _synchronize_rcu_expedited+0x149/0x350
2 locks held by kworker/2:7/1630:
  #0:  ("events"){.+.+.+}, at: [<ffffffff8107d5c6>] process_one_work+0x1e6/0x4d0
  #1:  ((&rew.rew_work)){+.+...}, at: [<ffffffff8107d5c6>] process_one_work+0x1e6/0x4d0
2 locks held by nano/2071:
  #0:  (&tty->ldisc_sem){++++.+}, at: [<ffffffff8158549d>] ldsem_down_read+0x2d/0x40
  #1:  (&ldata->atomic_read_lock){+.+...}, at: [<ffffffff813c4363>] n_tty_read+0xb3/0x8e0

=============================================

INFO: rcu_preempt detected stalls on CPUs/tasks:
	Tasks blocked on level-0 rcu_node (CPUs 0-15): P0
	(detected by 5, t=455012 jiffies, g=3241, c=3240, q=17768)
swapper/0       R  running task        0     0      0 0x00000000
  ffffffff81a11540 000000000000001f 0000000000000007 ffffffff817d2a6f
  ffffffff817a0867 ffffffffffffffcf ffffffff81472836 0000000000000010
  0000000000000216 ffffffff81a03ea0 0000000000000018 00000072f2ea5c0d
Call Trace:
  [<ffffffff81472836>] ? cpuidle_enter_state+0x156/0x220
  [<ffffffff815804eb>] ? schedule+0x3b/0x90
  [<ffffffff81580943>] ? schedule_preempt_disabled+0x13/0x20
  [<ffffffff810ad4c9>] ? cpu_startup_entry+0x179/0x210
  [<ffffffff8157892c>] ? rest_init+0x12c/0x140
  [<ffffffff81d02ec3>] ? start_kernel+0x40f/0x41c
  [<ffffffff81d02120>] ? early_idt_handler_array+0x120/0x120
  [<ffffffff81d02299>] ? x86_64_start_reservations+0x2a/0x2c
  [<ffffffff81d02386>] ? x86_64_start_kernel+0xeb/0xf8
swapper/0       R  running task        0     0      0 0x00000000
  ffff880439c31c80 0000000000003392 ffffffff81a11540 ffff88043cd40000
  ffff88043efd6718 ffffffff81a03ec8 ffffffff8157ff6e 00000000001d6700
  ffffffff81a11f48 ffff88043efd6718 0000000000000000 ffffffff81a11540
Call Trace:
  [<ffffffff8157ff6e>] ? __schedule+0x2ce/0x810
  [<ffffffff815804eb>] schedule+0x3b/0x90
  [<ffffffff811736c7>] ? quiet_vmstat+0x47/0x50
  [<ffffffff81026654>] ? arch_cpu_idle_enter+0x24/0x30
  [<ffffffff810ad46d>] ? cpu_startup_entry+0x11d/0x210
  [<ffffffff8157892c>] ? rest_init+0x12c/0x140
  [<ffffffff81d02ec3>] ? start_kernel+0x40f/0x41c
  [<ffffffff81d02120>] ? early_idt_handler_array+0x120/0x120
  [<ffffffff81d02299>] ? x86_64_start_reservations+0x2a/0x2c
  [<ffffffff81d02386>] ? x86_64_start_kernel+0xeb/0xf8
perf: interrupt took too long (19983 > 19768), lowering kernel.perf_event_max_sample_rate to 10000

......

INFO: task sd-resolve:1445 blocked for more than 120 seconds.
       Tainted: G          I     4.9-fw1 #1
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
sd-resolve      D    0  1445      1 0x00000000
  ffff88043a299300 00000000000078cb ffff88043c56c380 ffff88043cdc4380
  ffff88043fdd6718 ffffc90008093c90 ffffffff8157ff6e ffff88043c56cff0
  ffff88043c56cd80 ffff88043fdd6718 0000000000000000 ffff88043c56c380
Call Trace:
  [<ffffffff8157ff6e>] ? __schedule+0x2ce/0x810
  [<ffffffff815815ef>] ? mutex_lock_nested+0x15f/0x430
  [<ffffffff815804eb>] schedule+0x3b/0x90
  [<ffffffff81580943>] schedule_preempt_disabled+0x13/0x20
  [<ffffffff81581630>] mutex_lock_nested+0x1a0/0x430
  [<ffffffff814c3286>] ? rtnetlink_rcv+0x16/0x30
  [<ffffffff814c3286>] ? rtnetlink_rcv+0x16/0x30
  [<ffffffff814e4870>] ? netlink_deliver_tap+0x90/0x2b0
  [<ffffffff814c3286>] rtnetlink_rcv+0x16/0x30
  [<ffffffff814e7865>] netlink_unicast+0x155/0x1f0
  [<ffffffff814e7cad>] netlink_sendmsg+0x2dd/0x360
  [<ffffffff8148d682>] sock_sendmsg+0x12/0x20
  [<ffffffff8148e952>] SyS_sendto+0xf2/0x170
  [<ffffffff812fe213>] ? __this_cpu_preempt_check+0x13/0x20
  [<ffffffff810b92cf>] ? trace_hardirqs_on_caller+0xef/0x200
  [<ffffffff8100201a>] ? trace_hardirqs_on_thunk+0x1a/0x1c
  [<ffffffff81586681>] entry_SYSCALL_64_fastpath+0x1f/0xc2
  [<ffffffff812fe213>] ? __this_cpu_preempt_check+0x13/0x20

Showing all locks held in the system:
2 locks held by khungtaskd/108:
  #0:  (rcu_read_lock){......}, at: [<ffffffff811269af>] watchdog+0x9f/0x490
  #1:  (tasklist_lock){.+.+..}, at: [<ffffffff810b760d>] debug_show_all_locks+0x3d/0x1a0
1 lock held by sd-resolve/1445:
  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff814c3286>] rtnetlink_rcv+0x16/0x30
2 locks held by NetworkManager/1475:
  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff814c3286>] rtnetlink_rcv+0x16/0x30
  #1:  (rcu_preempt_state.exp_mutex){+.+...}, at: [<ffffffff810da7d9>] _synchronize_rcu_expedited+0x149/0x350
2 locks held by kworker/2:7/1630:
  #0:  ("events"){.+.+.+}, at: [<ffffffff8107d5c6>] process_one_work+0x1e6/0x4d0
  #1:  ((&rew.rew_work)){+.+...}, at: [<ffffffff8107d5c6>] process_one_work+0x1e6/0x4d0
1 lock held by sudo/2214:
  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff814c3286>] rtnetlink_rcv+0x16/0x30

=============================================

INFO: task NetworkManager:1475 blocked for more than 120 seconds.
       Tainted: G          I     4.9-fw1 #1
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
NetworkManager  D    0  1475      1 0x00000000
  ffff88083a8eaf80 000000000000d4d0 ffff88083955c380 ffff8804371d4380
  ffff88043f3d6718 ffffc90007f57640 ffffffff8157ff6e ffffc90007f57608
  ffff88083955cd80 ffff88043f3d6718 0000000000000000 ffff88083955c380
Call Trace:
  [<ffffffff8157ff6e>] ? __schedule+0x2ce/0x810
  [<ffffffff815804eb>] schedule+0x3b/0x90
  [<ffffffff810da9d4>] _synchronize_rcu_expedited+0x344/0x350
  [<ffffffff810da5c0>] ? rcu_momentary_dyntick_idle+0xa0/0xa0
  [<ffffffff810acd10>] ? wake_atomic_t_function+0x50/0x50
  [<ffffffff810da5c0>] ? rcu_momentary_dyntick_idle+0xa0/0xa0
  [<ffffffff810dacf0>] ? rcu_seq_end+0x40/0x40
  [<ffffffff810daca7>] synchronize_rcu_expedited+0x17/0x20
  [<ffffffff814aaf6c>] synchronize_net+0x2c/0x30
  [<ffffffff814daf8c>] dev_deactivate_many+0x2cc/0x2e0
  [<ffffffff814a6971>] __dev_close_many+0x71/0xe0
  [<ffffffff814a6b21>] __dev_close+0x31/0x50
  [<ffffffff814b16a8>] __dev_change_flags+0x98/0x160
  [<ffffffff814b1794>] dev_change_flags+0x24/0x60
  [<ffffffff810253a9>] ? sched_clock+0x9/0x10
  [<ffffffff814c3c96>] do_setlink+0x2e6/0xcc0
  [<ffffffff810b9b64>] ? __lock_acquire+0x454/0x1b00
  [<ffffffff813081c1>] ? nla_parse+0x31/0x120
  [<ffffffff814c6750>] rtnl_newlink+0x5c0/0x860
  [<ffffffff812fe1f7>] ? debug_smp_processor_id+0x17/0x20
  [<ffffffff810b5de9>] ? get_lock_stats+0x19/0x50
  [<ffffffff814c6a6f>] rtnetlink_rcv_msg+0x7f/0x1e0
  [<ffffffff8158178a>] ? mutex_lock_nested+0x2fa/0x430
  [<ffffffff814c3286>] ? rtnetlink_rcv+0x16/0x30
  [<ffffffff814c3286>] ? rtnetlink_rcv+0x16/0x30
  [<ffffffff814c69f0>] ? rtnl_newlink+0x860/0x860
  [<ffffffff814e7eef>] netlink_rcv_skb+0x9f/0xc0
  [<ffffffff814c3295>] rtnetlink_rcv+0x25/0x30
  [<ffffffff814e7865>] netlink_unicast+0x155/0x1f0
  [<ffffffff814e7cad>] netlink_sendmsg+0x2dd/0x360
  [<ffffffff8148d682>] sock_sendmsg+0x12/0x20
  [<ffffffff8148ddfc>] ___sys_sendmsg+0x2ac/0x2c0
  [<ffffffff812fe1f7>] ? debug_smp_processor_id+0x17/0x20
  [<ffffffff811fb60b>] ? __fget+0x10b/0x1f0
  [<ffffffff811fb500>] ? expand_files+0x2a0/0x2a0
  [<ffffffff811fb730>] ? __fget_light+0x20/0x60
  [<ffffffff8148ed60>] __sys_sendmsg+0x40/0x70
  [<ffffffff8148ed9d>] SyS_sendmsg+0xd/0x20
  [<ffffffff81586681>] entry_SYSCALL_64_fastpath+0x1f/0xc2
  [<ffffffff812fe213>] ? __this_cpu_preempt_check+0x13/0x20

Showing all locks held in the system:
2 locks held by khungtaskd/108:
  #0:  (rcu_read_lock){......}, at: [<ffffffff811269af>] watchdog+0x9f/0x490
  #1:  (tasklist_lock){.+.+..}, at: [<ffffffff810b760d>] debug_show_all_locks+0x3d/0x1a0
1 lock held by sd-resolve/1445:
  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff814c3286>] rtnetlink_rcv+0x16/0x30
2 locks held by NetworkManager/1475:
  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff814c3286>] rtnetlink_rcv+0x16/0x30
  #1:  (rcu_preempt_state.exp_mutex){+.+...}, at: [<ffffffff810da7d9>] _synchronize_rcu_expedited+0x149/0x350
2 locks held by kworker/2:7/1630:
  #0:  ("events"){.+.+.+}, at: [<ffffffff8107d5c6>] process_one_work+0x1e6/0x4d0
  #1:  ((&rew.rew_work)){+.+...}, at: [<ffffffff8107d5c6>] process_one_work+0x1e6/0x4d0
1 lock held by sudo/2214:
  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff814c3286>] rtnetlink_rcv+0x16/0x30

=============================================

INFO: task systemd-hostnam:1507 blocked for more than 120 seconds.
       Tainted: G          I     4.9-fw1 #1
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
systemd-hostnam D    0  1507      1 0x00000002
  ffff88043a29f200 000000000000c460 ffff88043ab0a1c0 ffff88043cdc0000
  ffff88043f9d6718 ffffc9000b67fb88 ffffffff8157ff6e ffffc9000b67fbf8
  ffff88043ab0abc0 ffff88043f9d6718 0000000000000000 ffff88043ab0a1c0
Call Trace:
  [<ffffffff8157ff6e>] ? __schedule+0x2ce/0x810
  [<ffffffff815804eb>] schedule+0x3b/0x90
  [<ffffffff81584e82>] schedule_timeout+0x222/0x3a0
  [<ffffffff812fe1f7>] ? debug_smp_processor_id+0x17/0x20
  [<ffffffff812fe1f7>] ? debug_smp_processor_id+0x17/0x20
  [<ffffffff810b5de9>] ? get_lock_stats+0x19/0x50
  [<ffffffff81585d17>] ? _raw_spin_unlock_irq+0x27/0x50
  [<ffffffff812fe213>] ? __this_cpu_preempt_check+0x13/0x20
  [<ffffffff810b92cf>] ? trace_hardirqs_on_caller+0xef/0x200
  [<ffffffff81580ffa>] wait_for_common+0xca/0x180
  [<ffffffff8108e150>] ? wake_up_q+0x80/0x80
  [<ffffffff815810c8>] wait_for_completion+0x18/0x20
  [<ffffffff810d82e5>] __wait_rcu_gp+0xc5/0x100
  [<ffffffff810dbccd>] synchronize_rcu.part.53+0x2d/0x50
  [<ffffffff810dc7e0>] ? __call_rcu.constprop.59+0x270/0x270
  [<ffffffff810d8210>] ? rcu_panic+0x20/0x20
  [<ffffffff81580f69>] ? wait_for_common+0x39/0x180
  [<ffffffff810dbd17>] synchronize_rcu+0x27/0x90
  [<ffffffff811fd887>] namespace_unlock+0x47/0x60
  [<ffffffff81200639>] drop_collected_mounts+0x89/0x90
  [<ffffffff8120246b>] ? put_mnt_ns+0x1b/0x30
  [<ffffffff8120246b>] put_mnt_ns+0x1b/0x30
  [<ffffffff81085798>] free_nsproxy+0x18/0xb0
  [<ffffffff8108593e>] switch_task_namespaces+0x5e/0x70
  [<ffffffff8108595b>] exit_task_namespaces+0xb/0x10
  [<ffffffff8106652e>] do_exit+0x2de/0xb30
  [<ffffffff812fe213>] ? __this_cpu_preempt_check+0x13/0x20
  [<ffffffff810b92cf>] ? trace_hardirqs_on_caller+0xef/0x200
  [<ffffffff81066e00>] do_group_exit+0x40/0xc0
  [<ffffffff81066e8f>] SyS_exit_group+0xf/0x10
  [<ffffffff81586681>] entry_SYSCALL_64_fastpath+0x1f/0xc2
  [<ffffffff812fe213>] ? __this_cpu_preempt_check+0x13/0x20

Showing all locks held in the system:
2 locks held by khungtaskd/108:
  #0:  (rcu_read_lock){......}, at: [<ffffffff811269af>] watchdog+0x9f/0x490
  #1:  (tasklist_lock){.+.+..}, at: [<ffffffff810b760d>] debug_show_all_locks+0x3d/0x1a0
1 lock held by sd-resolve/1445:
  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff814c3286>] rtnetlink_rcv+0x16/0x30
2 locks held by NetworkManager/1475:
  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff814c3286>] rtnetlink_rcv+0x16/0x30
  #1:  (rcu_preempt_state.exp_mutex){+.+...}, at: [<ffffffff810da7d9>] _synchronize_rcu_expedited+0x149/0x350
2 locks held by kworker/2:7/1630:
  #0:  ("events"){.+.+.+}, at: [<ffffffff8107d5c6>] process_one_work+0x1e6/0x4d0
  #1:  ((&rew.rew_work)){+.+...}, at: [<ffffffff8107d5c6>] process_one_work+0x1e6/0x4d0
1 lock held by sudo/2214:
  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff814c3286>] rtnetlink_rcv+0x16/0x30

=============================================

INFO: task kworker/2:7:1630 blocked for more than 120 seconds.
       Tainted: G          I     4.9-fw1 #1
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
kworker/2:7     D    0  1630      2 0x00000000
Workqueue: events wait_rcu_exp_gp
  ffff880439c31c80 000000000000affb ffff8804371d4380 ffff88043bddc380
  ffff88043f3d6718 ffffc9000c157be8 ffffffff8157ff6e ffffc9000c157bb0
  ffff8804371d4d80 ffff88043f3d6718 0000000000000000 ffff8804371d4380
Call Trace:
  [<ffffffff8157ff6e>] ? __schedule+0x2ce/0x810
  [<ffffffff815804eb>] schedule+0x3b/0x90
  [<ffffffff81584e4b>] schedule_timeout+0x1eb/0x3a0
  [<ffffffff810e1410>] ? del_timer_sync+0xd0/0xd0
  [<ffffffff810acdf7>] ? prepare_to_swait+0x67/0x90
  [<ffffffff810daff5>] wait_rcu_exp_gp+0x305/0xa10
  [<ffffffff8107d62c>] process_one_work+0x24c/0x4d0
  [<ffffffff8107d5c6>] ? process_one_work+0x1e6/0x4d0
  [<ffffffff8107d8f6>] worker_thread+0x46/0x4f0
  [<ffffffff8107d8b0>] ? process_one_work+0x4d0/0x4d0
  [<ffffffff810840fe>] kthread+0xee/0x110
  [<ffffffff81084010>] ? kthread_park+0x60/0x60
  [<ffffffff815868ea>] ret_from_fork+0x2a/0x40

Showing all locks held in the system:
2 locks held by khungtaskd/108:
  #0:  (rcu_read_lock){......}, at: [<ffffffff811269af>] watchdog+0x9f/0x490
  #1:  (tasklist_lock){.+.+..}, at: [<ffffffff810b760d>] debug_show_all_locks+0x3d/0x1a0
1 lock held by sd-resolve/1445:
  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff814c3286>] rtnetlink_rcv+0x16/0x30
2 locks held by NetworkManager/1475:
  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff814c3286>] rtnetlink_rcv+0x16/0x30
  #1:  (rcu_preempt_state.exp_mutex){+.+...}, at: [<ffffffff810da7d9>] _synchronize_rcu_expedited+0x149/0x350
2 locks held by kworker/2:7/1630:
  #0:  ("events"){.+.+.+}, at: [<ffffffff8107d5c6>] process_one_work+0x1e6/0x4d0
  #1:  ((&rew.rew_work)){+.+...}, at: [<ffffffff8107d5c6>] process_one_work+0x1e6/0x4d0
1 lock held by sudo/2214:
  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff814c3286>] rtnetlink_rcv+0x16/0x30

=============================================

INFO: rcu_preempt detected expedited stalls on CPUs/tasks: { P0 } 264561 jiffies s: 1039 root: 0x0/T
blocking rcu_node structures:
session-c1.scope: Stopping timed out. Killing.
session-c1.scope: Killing process 2214 (sudo) with signal SIGKILL.
gpm.service: State 'stop-sigterm' timed out. Killing.
gpm.service: Killing process 1461 (gpm) with signal SIGKILL.
perf: interrupt took too long (25099 > 24978), lowering kernel.perf_event_max_sample_rate to 7000
INFO: rcu_preempt detected stalls on CPUs/tasks:
	Tasks blocked on level-0 rcu_node (CPUs 0-15): P0
	(detected by 1, t=650017 jiffies, g=3241, c=3240, q=28138)
swapper/0       R  running task        0     0      0 0x00000000
  ffffffff81a03e90 ffffffff8139bf30 ffffffff81ae30b8 00000000810253a9
  ffff88083cb1e600 ffffffff81ae30a0 0000000000000002 ffffffff81ae30b8
  ffffffff81ae2fe0 ffffffff81a03ed0 ffffffff81472814 000000a05ac4422f
Call Trace:
  [<ffffffff8139bf30>] ? acpi_idle_enter+0x116/0x1fb
  [<ffffffff81472814>] ? cpuidle_enter_state+0x134/0x220
  [<ffffffff81472922>] ? cpuidle_enter+0x12/0x20
  [<ffffffff810ad23e>] ? call_cpuidle+0x1e/0x40
  [<ffffffff810ad46d>] ? cpu_startup_entry+0x11d/0x210
  [<ffffffff8157892c>] ? rest_init+0x12c/0x140
  [<ffffffff81d02ec3>] ? start_kernel+0x40f/0x41c
  [<ffffffff81d02120>] ? early_idt_handler_array+0x120/0x120
  [<ffffffff81d02299>] ? x86_64_start_reservations+0x2a/0x2c
  [<ffffffff81d02386>] ? x86_64_start_kernel+0xeb/0xf8
swapper/0       R  running task        0     0      0 0x00000000
  ffffffff81a03e90 ffffffff8139bf30 ffffffff81ae30b8 00000000810253a9
  ffff88083cb1e600 ffffffff81ae30a0 0000000000000002 ffffffff81ae30b8
  ffffffff81ae2fe0 ffffffff81a03ed0 ffffffff81472814 000000a05ac4422f
Call Trace:
  [<ffffffff8139bf30>] ? acpi_idle_enter+0x116/0x1fb
  [<ffffffff81472814>] ? cpuidle_enter_state+0x134/0x220
  [<ffffffff81472922>] ? cpuidle_enter+0x12/0x20
  [<ffffffff810ad23e>] ? call_cpuidle+0x1e/0x40
  [<ffffffff810ad46d>] ? cpu_startup_entry+0x11d/0x210
  [<ffffffff8157892c>] ? rest_init+0x12c/0x140
  [<ffffffff81d02ec3>] ? start_kernel+0x40f/0x41c
  [<ffffffff81d02120>] ? early_idt_handler_array+0x120/0x120
  [<ffffffff81d02299>] ? x86_64_start_reservations+0x2a/0x2c
  [<ffffffff81d02386>] ? x86_64_start_kernel+0xeb/0xf8
session-c1.scope: Still around after SIGKILL. Ignoring.
Stopped Session c1 of user root.
session-c1.scope: Unit entered failed state.
gpm.service: Processes still around after SIGKILL. Ignoring.
Removed slice User Slice of root.
Stopping Login Service...
Stopping Permit User Sessions...
Stopped Permit User Sessions.
Stopped target Remote File Systems.
Stopped target Network.
Stopping Network Manager...
Stopping WPA supplicant...
INFO: task sd-resolve:1445 blocked for more than 120 seconds.
       Tainted: G          I     4.9-fw1 #1
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
sd-resolve      D    0  1445      1 0x00000000
  ffff88043a299300 00000000000078cb ffff88043c56c380 ffff88043cdc4380
  ffff88043fdd6718 ffffc90008093c90 ffffffff8157ff6e ffff88043c56cff0
  ffff88043c56cd80 ffff88043fdd6718 0000000000000000 ffff88043c56c380
Call Trace:
  [<ffffffff8157ff6e>] ? __schedule+0x2ce/0x810
  [<ffffffff815815ef>] ? mutex_lock_nested+0x15f/0x430
  [<ffffffff815804eb>] schedule+0x3b/0x90
  [<ffffffff81580943>] schedule_preempt_disabled+0x13/0x20
  [<ffffffff81581630>] mutex_lock_nested+0x1a0/0x430
  [<ffffffff814c3286>] ? rtnetlink_rcv+0x16/0x30
  [<ffffffff814c3286>] ? rtnetlink_rcv+0x16/0x30
  [<ffffffff814e4870>] ? netlink_deliver_tap+0x90/0x2b0
  [<ffffffff814c3286>] rtnetlink_rcv+0x16/0x30
  [<ffffffff814e7865>] netlink_unicast+0x155/0x1f0
  [<ffffffff814e7cad>] netlink_sendmsg+0x2dd/0x360
  [<ffffffff8148d682>] sock_sendmsg+0x12/0x20
  [<ffffffff8148e952>] SyS_sendto+0xf2/0x170
  [<ffffffff812fe213>] ? __this_cpu_preempt_check+0x13/0x20
  [<ffffffff810b92cf>] ? trace_hardirqs_on_caller+0xef/0x200
  [<ffffffff8100201a>] ? trace_hardirqs_on_thunk+0x1a/0x1c
  [<ffffffff81586681>] entry_SYSCALL_64_fastpath+0x1f/0xc2
  [<ffffffff812fe213>] ? __this_cpu_preempt_check+0x13/0x20

Showing all locks held in the system:
2 locks held by khungtaskd/108:
  #0:  (rcu_read_lock){......}, at: [<ffffffff811269af>] watchdog+0x9f/0x490
  #1:  (tasklist_lock){.+.+..}, at: [<ffffffff810b760d>] debug_show_all_locks+0x3d/0x1a0
1 lock held by sd-resolve/1445:
  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff814c3286>] rtnetlink_rcv+0x16/0x30
2 locks held by NetworkManager/1475:
  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff814c3286>] rtnetlink_rcv+0x16/0x30
  #1:  (rcu_preempt_state.exp_mutex){+.+...}, at: [<ffffffff810da7d9>] _synchronize_rcu_expedited+0x149/0x350
1 lock held by wpa_supplicant/1512:
  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff814c3286>] rtnetlink_rcv+0x16/0x30
2 locks held by kworker/2:7/1630:
  #0:  ("events"){.+.+.+}, at: [<ffffffff8107d5c6>] process_one_work+0x1e6/0x4d0
  #1:  ((&rew.rew_work)){+.+...}, at: [<ffffffff8107d5c6>] process_one_work+0x1e6/0x4d0
1 lock held by sudo/2214:
  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff814c3286>] rtnetlink_rcv+0x16/0x30

=============================================

INFO: task gpm:1461 blocked for more than 120 seconds.
       Tainted: G          I     4.9-fw1 #1
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
gpm             D    0  1461      1 0x00000002
  ffff880439d59300 0000000000001482 ffff8804371bc380 ffff88083c8e8000
  ffff88083efd6718 ffffc9000b523b78 ffffffff8157ff6e ffffc9000b523be8
  ffff8804371bcd80 ffff88083efd6718 0000000000000000 ffff8804371bc380
Call Trace:
  [<ffffffff8157ff6e>] ? __schedule+0x2ce/0x810
  [<ffffffff815804eb>] schedule+0x3b/0x90
  [<ffffffff81584e82>] schedule_timeout+0x222/0x3a0
  [<ffffffff812fe1f7>] ? debug_smp_processor_id+0x17/0x20
  [<ffffffff812fe1f7>] ? debug_smp_processor_id+0x17/0x20
  [<ffffffff810b5de9>] ? get_lock_stats+0x19/0x50
  [<ffffffff81585d17>] ? _raw_spin_unlock_irq+0x27/0x50
  [<ffffffff812fe213>] ? __this_cpu_preempt_check+0x13/0x20
  [<ffffffff810b92cf>] ? trace_hardirqs_on_caller+0xef/0x200
  [<ffffffff81580ffa>] wait_for_common+0xca/0x180
  [<ffffffff8108e150>] ? wake_up_q+0x80/0x80
  [<ffffffff815810c8>] wait_for_completion+0x18/0x20
  [<ffffffff810d82e5>] __wait_rcu_gp+0xc5/0x100
  [<ffffffff810dbccd>] synchronize_rcu.part.53+0x2d/0x50
  [<ffffffff810dc7e0>] ? __call_rcu.constprop.59+0x270/0x270
  [<ffffffff810d8210>] ? rcu_panic+0x20/0x20
  [<ffffffff81580f69>] ? wait_for_common+0x39/0x180
  [<ffffffff810dbd17>] synchronize_rcu+0x27/0x90
  [<ffffffff81459c5e>] mousedev_release+0x4e/0x70
  [<ffffffff811dc51a>] __fput+0xba/0x200
  [<ffffffff811dc699>] ____fput+0x9/0x10
  [<ffffffff81082680>] task_work_run+0x80/0xb0
  [<ffffffff81066533>] do_exit+0x2e3/0xb30
  [<ffffffff812fe213>] ? __this_cpu_preempt_check+0x13/0x20
  [<ffffffff810b92cf>] ? trace_hardirqs_on_caller+0xef/0x200
  [<ffffffff81066e00>] do_group_exit+0x40/0xc0
  [<ffffffff81066e8f>] SyS_exit_group+0xf/0x10
  [<ffffffff81586681>] entry_SYSCALL_64_fastpath+0x1f/0xc2
  [<ffffffff812fe213>] ? __this_cpu_preempt_check+0x13/0x20

Showing all locks held in the system:
2 locks held by khungtaskd/108:
  #0:  (rcu_read_lock){......}, at: [<ffffffff811269af>] watchdog+0x9f/0x490
  #1:  (tasklist_lock){.+.+..}, at: [<ffffffff810b760d>] debug_show_all_locks+0x3d/0x1a0
1 lock held by sd-resolve/1445:
  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff814c3286>] rtnetlink_rcv+0x16/0x30
2 locks held by NetworkManager/1475:
  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff814c3286>] rtnetlink_rcv+0x16/0x30
  #1:  (rcu_preempt_state.exp_mutex){+.+...}, at: [<ffffffff810da7d9>] _synchronize_rcu_expedited+0x149/0x350
1 lock held by wpa_supplicant/1512:
  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff814c3286>] rtnetlink_rcv+0x16/0x30
2 locks held by kworker/2:7/1630:
  #0:  ("events"){.+.+.+}, at: [<ffffffff8107d5c6>] process_one_work+0x1e6/0x4d0
  #1:  ((&rew.rew_work)){+.+...}, at: [<ffffffff8107d5c6>] process_one_work+0x1e6/0x4d0
1 lock held by sudo/2214:
  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff814c3286>] rtnetlink_rcv+0x16/0x30

=============================================


Full log can be found there :

http://ftp.frugalware.org/pub/other/people/crazy/journalctl-4.9-log

lspci -vv for the card :

02:00.0 Network controller: Qualcomm Atheros AR93xx Wireless Network Adapter (rev 01)
         Subsystem: Qualcomm Atheros AR93xx Wireless Network Adapter
         Physical Slot: 6
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
         Latency: 0, Cache Line Size: 32 bytes
         Interrupt: pin A routed to IRQ 25
         Region 0: Memory at b0220000 (64-bit, non-prefetchable) [size=128K]
         [virtual] Expansion ROM at b0200000 [disabled] [size=64K]
         Capabilities: [40] Power Management version 3
                 Flags: PMEClk- DSI- D1+ D2- AuxCurrent=375mA PME(D0+,D1+,D2-,D3hot+,D3cold-)
                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
         Capabilities: [50] MSI: Enable- Count=1/4 Maskable+ 64bit+
                 Address: 0000000000000000  Data: 0000
                 Masking: 00000000  Pending: 00000000
         Capabilities: [70] Express (v2) Endpoint, MSI 00
                 DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <1us, L1 <8us
                         ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset- SlotPowerLimit 25.000W
                 DevCtl: Report errors: Correctable- Non-Fatal+ Fatal+ Unsupported-
                         RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
                         MaxPayload 128 bytes, MaxReadReq 512 bytes
                 DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr- TransPend-
                 LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency L0s <2us, L1 <64us
                         ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp-
                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk+
                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                 LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
                 DevCap2: Completion Timeout: Not Supported, TimeoutDis+, LTR-, OBFF Not Supported
                 DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF Disabled
                 LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-
                          Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
                          Compliance De-emphasis: -6dB
                 LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-, EqualizationPhase1-
                          EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
         Capabilities: [100 v1] Advanced Error Reporting
                 UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                 UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-
                 UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
                 CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
                 CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
                 AERCap: First Error Pointer: 00, GenCap- CGenEn- ChkCap- ChkEn-
         Capabilities: [140 v1] Virtual Channel
                 Caps:   LPEVC=0 RefClk=100ns PATEntryBits=1
                 Arb:    Fixed- WRR32- WRR64- WRR128-
                 Ctrl:   ArbSelect=Fixed
                 Status: InProgress-
                 VC0:    Caps:   PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
                         Arb:    Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
                         Ctrl:   Enable+ ID=0 ArbSelect=Fixed TC/VC=ff
                         Status: NegoPending- InProgress-
         Capabilities: [300 v1] Device Serial Number 00-00-00-00-00-00-00-00
         Kernel driver in use: ath9k
         Kernel modules: ath9k



Also when disabling the ath9k driver or blacklisting it everything seems normal.

Please let me know when you need more infos.

Best Regards,

Gabrile C
