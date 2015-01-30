From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH 0/6 net-next] rhashtable fixes
Date: Fri, 30 Jan 2015 17:10:45 +0800
Message-ID: <54CB4A95.9060000@windriver.com>
References: <cover.1422576760.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:56909 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754544AbbA3JL3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 04:11:29 -0500
In-Reply-To: <cover.1422576760.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas,

I make sure that my local net-next tree is synchronized to the latest
version in which the commit fe6a043c535acfec8f8e554536c87923dcb45097
("rhashtable: rhashtable_remove() must unlink in both tbl and
future_tbl") is already contained, and then I manually applied the whole
series patches. But when I repeatedly run the test case I originally
posted, soft lockup happens. Please see its relevant log:

root@localhost:/mnt# d[  115.776178] ------------[ cut here ]------------
[  115.776548] WARNING: CPU: 4 PID: 0 at net/sched/sch_generic.c:303
dev_watchdog+0x247/0x250()
[  115.777106] NETDEV WATCHDOG: eth0 (e1000): transmit queue 0 timed out
[  115.777533] Modules linked in: tipc
[  115.777790] CPU: 4 PID: 0 Comm: swapper/4 Not tainted 3.19.0-rc6+ #182
[  115.778221] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  115.778602]  000000000000012f ffff880017d03d08 ffffffff8175cd25
0000000000001052
[  115.779133]  ffff880017d03d58 ffff880017d03d48 ffffffff81059717
ffffffff00000000
[  115.779661]  ffff880015c26000 ffff880015c263e0 ffff880015f07000
0000000000000001
[  115.780165] Call Trace:
[  115.780165]  <IRQ>  [<ffffffff8175cd25>] dump_stack+0x4c/0x65
[  115.780165]  [<ffffffff81059717>] warn_slowpath_common+0x97/0xe0
[  115.780165]  [<ffffffff81059816>] warn_slowpath_fmt+0x46/0x50
[  115.780165]  [<ffffffff81654537>] dev_watchdog+0x247/0x250
[  115.780165]  [<ffffffff816542f0>] ? pfifo_fast_dequeue+0xe0/0xe0
[  115.780165]  [<ffffffff816542f0>] ? pfifo_fast_dequeue+0xe0/0xe0
[  115.780165]  [<ffffffff810c5ebc>] call_timer_fn+0x8c/0x1e0
[  115.780165]  [<ffffffff810c5e35>] ? call_timer_fn+0x5/0x1e0
[  115.780165]  [<ffffffff817663b0>] ? _raw_spin_unlock_irq+0x30/0x40
[  115.780165]  [<ffffffff816542f0>] ? pfifo_fast_dequeue+0xe0/0xe0
[  115.780165]  [<ffffffff810c7994>] run_timer_softirq+0x2d4/0x320
[  115.780165]  [<ffffffff810d6214>] ? clockevents_program_event+0x74/0x100
[  115.780165]  [<ffffffff8105d653>] __do_softirq+0x123/0x360
[  115.780165]  [<ffffffff8105db2e>] irq_exit+0x8e/0xb0
[  115.780165]  [<ffffffff8176952a>] smp_apic_timer_interrupt+0x4a/0x60
[  115.780165]  [<ffffffff817678af>] apic_timer_interrupt+0x6f/0x80
[  115.780165]  <EOI>  [<ffffffff8100d174>] ? default_idle+0x24/0x100
[  115.780165]  [<ffffffff8100d172>] ? default_idle+0x22/0x100
[  115.780165]  [<ffffffff8100daaf>] arch_cpu_idle+0xf/0x20
[  115.780165]  [<ffffffff8109a509>] cpu_startup_entry+0x2c9/0x3c0
[  115.780165]  [<ffffffff810d5ea2>] ?
clockevents_register_device+0xe2/0x140
[  115.780165]  [<ffffffff810333c1>] start_secondary+0x141/0x150
[  115.780165] ---[ end trace 62da3388fe54379b ]---
[  115.780165] e1000 0000:00:03.0 eth0: Reset adapter
[  116.724005] NMI watchdog: BUG: soft lockup - CPU#7 stuck for 22s!
[bind_netlink:631]
[  116.724005] Modules linked in: tipc
[  116.724005] irq event stamp: 331179
[  116.724005] hardirqs last  enabled at (331178): [<ffffffff817675e0>]
restore_args+0x0/0x30
[  116.724005] hardirqs last disabled at (331179): [<ffffffff817678aa>]
apic_timer_interrupt+0x6a/0x80
[  116.724005] softirqs last  enabled at (318168): [<ffffffff8161897f>]
lock_sock_nested+0x4f/0xc0
[  116.724005] softirqs last disabled at (318170): [<ffffffff8139d79a>]
lock_buckets+0x3a/0x80
[  116.724005] CPU: 7 PID: 631 Comm: bind_netlink Tainted: G        W
   3.19.0-rc6+ #182
[  116.724005] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  116.724005] task: ffff880013970000 ti: ffff8800105d0000 task.ti:
ffff8800105d0000
[  116.724005] RIP: 0010:[<ffffffff8165d820>]  [<ffffffff8165d820>]
netlink_compare+0x10/0x30
[  116.724005] RSP: 0018:ffff8800105d3cf0  EFLAGS: 00000293
[  116.724005] RAX: 0000000000000000 RBX: ffffffff817675e0 RCX:
00000000dbaee169
[  116.724005] RDX: 0000000000001668 RSI: ffff8800105d3db8 RDI:
ffff88001651b800
[  116.724005] RBP: ffff8800105d3d48 R08: 00000000df2b8827 R09:
ffff880010c07468
[  116.724005] R10: 0000000000000003 R11: 0000000000000001 R12:
ffff8800105d3c68
[  116.724005] R13: 0000000000000046 R14: ffff8800105d0000 R15:
ffff880013970000
[  116.724005] FS:  0000000000000000(0000) GS:ffff880017dc0000(0063)
knlGS:00000000f75ae900
[  116.724005] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[  116.724005] CR2: 0000000008760000 CR3: 0000000015121000 CR4:
00000000000006e0
[  116.724005] Stack:
[  116.724005]  ffffffff8139de4e ffffffff8139ddc0 000000028105d9c8
07ca27d400000000
[  116.724005]  ffff8800152d13c0 ffff8800105d3d48 ffff880016500000
ffff8800152d13c0
[  116.724005]  0000000000000004 ffff8800152d13c0 ffff880010c07608
ffff8800105d3da8
[  116.724005] Call Trace:
[  116.724005]  [<ffffffff8139de4e>] ? rhashtable_lookup_compare+0x8e/0x120
[  116.724005]  [<ffffffff8139ddc0>] ? rhashtable_remove+0x200/0x200
[  116.724005]  [<ffffffff8139dfaf>]
rhashtable_lookup_compare_insert+0x9f/0x110
[  116.724005]  [<ffffffff8139df45>] ?
rhashtable_lookup_compare_insert+0x35/0x110
[  116.724005]  [<ffffffff8165d810>] ? netlink_overrun+0x50/0x50
[  116.724005]  [<ffffffff8165e0f3>] ? netlink_insert+0x43/0xf0
[  116.724005]  [<ffffffff8165e141>] netlink_insert+0x91/0xf0
[  116.724005]  [<ffffffff81660470>] netlink_bind+0x210/0x260
[  116.724005]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  116.724005]  [<ffffffff810a5b10>] ? lock_release_non_nested+0xa0/0x340
[  116.724005]  [<ffffffff81616d24>] SYSC_bind+0xa4/0xc0
[  116.724005]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  116.724005]  [<ffffffff8161701e>] SyS_bind+0xe/0x10
[  116.724005]  [<ffffffff81652318>] compat_SyS_socketcall+0xa8/0x200
[  116.724005]  [<ffffffff81768df3>] sysenter_dispatch+0x7/0x1f
[  116.724005]  [<ffffffff8139660e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  116.724005] Code: f0 ff 83 98 01 00 00 48 83 c4 08 5b 5d c3 66 66 66
66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 31 c0 8b 56 08 39 97 68 04
00 00 <55> 48 89 e5 74 0a 5d c3 0f 1f 84 00 00 00 00 00 48 8b 47 30 48
[  144.724006] NMI watchdog: BUG: soft lockup - CPU#7 stuck for 22s!
[bind_netlink:631]
[  144.724006] Modules linked in: tipc
[  144.724006] irq event stamp: 345169
[  144.724006] hardirqs last  enabled at (345168): [<ffffffff817675e0>]
restore_args+0x0/0x30
[  144.724006] hardirqs last disabled at (345169): [<ffffffff817678aa>]
apic_timer_interrupt+0x6a/0x80
[  144.724006] softirqs last  enabled at (318168): [<ffffffff8161897f>]
lock_sock_nested+0x4f/0xc0
[  144.724006] softirqs last disabled at (318170): [<ffffffff8139d79a>]
lock_buckets+0x3a/0x80
[  144.724006] CPU: 7 PID: 631 Comm: bind_netlink Tainted: G        W
 L 3.19.0-rc6+ #182
[  144.724006] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  144.724006] task: ffff880013970000 ti: ffff8800105d0000 task.ti:
ffff8800105d0000
[  144.724006] RIP: 0010:[<ffffffff8165d826>]  [<ffffffff8165d826>]
netlink_compare+0x16/0x30
[  144.724006] RSP: 0018:ffff8800105d3ce8  EFLAGS: 00000293
[  144.724006] RAX: 0000000000000000 RBX: ffff8800105d3c68 RCX:
00000000dbaee169
[  144.724006] RDX: 0000000000001668 RSI: ffff8800105d3db8 RDI:
ffff88001651b800
[  144.724006] RBP: ffff8800105d3ce8 R08: 00000000df2b8827 R09:
ffff880010c07468
[  144.724006] R10: 0000000000000003 R11: 0000000000000001 R12:
ffff8800105d0000
[  144.724006] R13: ffff880013970000 R14: 0000000000000000 R15:
0000000000000001
[  144.724006] FS:  0000000000000000(0000) GS:ffff880017dc0000(0063)
knlGS:00000000f75ae900
[  144.724006] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[  144.724006] CR2: 0000000008760000 CR3: 0000000015121000 CR4:
00000000000006e0
[  144.724006] Stack:
[  144.724006]  ffff8800105d3d48 ffffffff8139de4e ffffffff8139ddc0
000000028105d9c8
[  144.724006]  07ca27d400000000 ffff8800152d13c0 ffff8800105d3d48
ffff880016500000
[  144.724006]  ffff8800152d13c0 0000000000000004 ffff8800152d13c0
ffff880010c07608
[  144.724006] Call Trace:
[  144.724006]  [<ffffffff8139de4e>] rhashtable_lookup_compare+0x8e/0x120
[  144.724006]  [<ffffffff8139ddc0>] ? rhashtable_remove+0x200/0x200
[  144.724006]  [<ffffffff8139dfaf>]
rhashtable_lookup_compare_insert+0x9f/0x110
[  144.724006]  [<ffffffff8139df45>] ?
rhashtable_lookup_compare_insert+0x35/0x110
[  144.724006]  [<ffffffff8165d810>] ? netlink_overrun+0x50/0x50
[  144.724006]  [<ffffffff8165e0f3>] ? netlink_insert+0x43/0xf0
[  144.724006]  [<ffffffff8165e141>] netlink_insert+0x91/0xf0
[  144.724006]  [<ffffffff81660470>] netlink_bind+0x210/0x260
[  144.724006]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  144.724006]  [<ffffffff810a5b10>] ? lock_release_non_nested+0xa0/0x340
[  144.724006]  [<ffffffff81616d24>] SYSC_bind+0xa4/0xc0
[  144.724006]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  144.724006]  [<ffffffff8161701e>] SyS_bind+0xe/0x10
[  144.724006]  [<ffffffff81652318>] compat_SyS_socketcall+0xa8/0x200
[  144.724006]  [<ffffffff81768df3>] sysenter_dispatch+0x7/0x1f
[  144.724006]  [<ffffffff8139660e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  144.724006] Code: 00 48 83 c4 08 5b 5d c3 66 66 66 66 2e 0f 1f 84 00
00 00 00 00 0f 1f 44 00 00 31 c0 8b 56 08 39 97 68 04 00 00 55 48 89 e5
74 0a <5d> c3 0f 1f 84 00 00 00 00 00 48 8b 47 30 48 39 06 5d 0f 94 c0
[  150.732004] INFO: rcu_sched self-detected stall on CPU { 7}  (t=15000
jiffies g=674 c=673 q=18)
[  150.732004] Task dump for CPU 7:
[  150.732004] bind_netlink    R  running task        0   631    561
0x20020008
[  150.732004]  0000000000000231 ffff880017dc3d68 ffffffff81086c26
ffffffff81086b88
[  150.732004]  00000000a5f9a5f8 0000000000000007 ffffffff81c53940
ffff880017dc3d88
[  150.732004]  ffffffff8108a57f ffffffff81c53940 ffffffff81c53940
ffff880017dc3db8
[  150.732004] Call Trace:
[  150.732004]  <IRQ>  [<ffffffff81086c26>] sched_show_task+0x106/0x170
[  150.732004]  [<ffffffff81086b88>] ? sched_show_task+0x68/0x170
[  150.732004]  [<ffffffff8108a57f>] dump_cpu_task+0x3f/0x50
[  150.732004]  [<ffffffff810bfa7b>] rcu_dump_cpu_stacks+0x8b/0xc0
[  150.732004]  [<ffffffff810c33d0>] rcu_check_callbacks+0x480/0x6d0
[  150.732004]  [<ffffffff810a133d>] ? trace_hardirqs_off+0xd/0x10
[  150.732004]  [<ffffffff810c8408>] update_process_times+0x38/0x70
[  150.732004]  [<ffffffff810d8623>] tick_sched_handle.isra.15+0x33/0x70
[  150.732004]  [<ffffffff810d88cb>] tick_sched_timer+0x4b/0x80
[  150.732004]  [<ffffffff810c8d8b>] __run_hrtimer+0x9b/0x290
[  150.732004]  [<ffffffff810d8880>] ? tick_sched_do_timer+0x40/0x40
[  150.732004]  [<ffffffff810c95e4>] ? hrtimer_interrupt+0x74/0x260
[  150.732004]  [<ffffffff810c9677>] hrtimer_interrupt+0x107/0x260
[  150.732004]  [<ffffffff8165d810>] ? netlink_overrun+0x50/0x50
[  150.732004]  [<ffffffff81034cb9>] local_apic_timer_interrupt+0x39/0x60
[  150.732004]  [<ffffffff81769525>] smp_apic_timer_interrupt+0x45/0x60
[  150.732004]  [<ffffffff817678af>] apic_timer_interrupt+0x6f/0x80
[  150.732004]  <EOI>  [<ffffffff817675e0>] ? retint_restore_args+0xe/0xe
[  150.732004]  [<ffffffff8165d817>] ? netlink_compare+0x7/0x30
[  150.732004]  [<ffffffff8139de4e>] ? rhashtable_lookup_compare+0x8e/0x120
[  150.732004]  [<ffffffff8139ddc0>] ? rhashtable_remove+0x200/0x200
[  150.732004]  [<ffffffff8139dfaf>]
rhashtable_lookup_compare_insert+0x9f/0x110
[  150.732004]  [<ffffffff8139df45>] ?
rhashtable_lookup_compare_insert+0x35/0x110
[  150.732004]  [<ffffffff8165d810>] ? netlink_overrun+0x50/0x50
[  150.732004]  [<ffffffff8165e0f3>] ? netlink_insert+0x43/0xf0
[  150.732004]  [<ffffffff8165e141>] netlink_insert+0x91/0xf0
[  150.732004]  [<ffffffff81660470>] netlink_bind+0x210/0x260
[  150.732004]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  150.732004]  [<ffffffff810a5b10>] ? lock_release_non_nested+0xa0/0x340
[  150.732004]  [<ffffffff81616d24>] SYSC_bind+0xa4/0xc0
[  150.732004]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  150.732004]  [<ffffffff8161701e>] SyS_bind+0xe/0x10
[  150.732004]  [<ffffffff81652318>] compat_SyS_socketcall+0xa8/0x200
[  150.732004]  [<ffffffff81768df3>] sysenter_dispatch+0x7/0x1f
[  150.732004]  [<ffffffff8139660e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  176.724005] NMI watchdog: BUG: soft lockup - CPU#7 stuck for 22s!
[bind_netlink:631]
[  176.724005] Modules linked in: tipc
[  176.724005] irq event stamp: 361143
[  176.724005] hardirqs last  enabled at (361142): [<ffffffff817675e0>]
restore_args+0x0/0x30
[  176.724005] hardirqs last disabled at (361143): [<ffffffff817678aa>]
apic_timer_interrupt+0x6a/0x80
[  176.724005] softirqs last  enabled at (318168): [<ffffffff8161897f>]
lock_sock_nested+0x4f/0xc0
[  176.724005] softirqs last disabled at (318170): [<ffffffff8139d79a>]
lock_buckets+0x3a/0x80
[  176.724005] CPU: 7 PID: 631 Comm: bind_netlink Tainted: G        W
 L 3.19.0-rc6+ #182
[  176.724005] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  176.724005] task: ffff880013970000 ti: ffff8800105d0000 task.ti:
ffff8800105d0000
[  176.724005] RIP: 0010:[<ffffffff8139de55>]  [<ffffffff8139de55>]
rhashtable_lookup_compare+0x95/0x120
[  176.724005] RSP: 0018:ffff8800105d3cf8  EFLAGS: 00000246
[  176.724005] RAX: 0000000000000000 RBX: 0000000000000003 RCX:
00000000dbaee169
[  176.724005] RDX: 0000000000001668 RSI: ffff8800105d3db8 RDI:
ffff88001651b800
[  176.724005] RBP: ffff8800105d3d48 R08: 00000000df2b8827 R09:
ffff880010c07468
[  176.724005] R10: 0000000000000003 R11: 0000000000000001 R12:
ffffffff817675e0
[  176.724005] R13: ffffffff810c2d18 R14: ffff8800105d3c58 R15:
0000000000000046
[  176.724005] FS:  0000000000000000(0000) GS:ffff880017dc0000(0063)
knlGS:00000000f75ae900
[  176.724005] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[  176.724005] CR2: 0000000008760000 CR3: 0000000015121000 CR4:
00000000000006e0
[  176.724005] Stack:
[  176.724005]  ffffffff8139ddc0 000000028105d9c8 07ca27d400000000
ffff8800152d13c0
[  176.724005]  ffff8800105d3d48 ffff880016500000 ffff8800152d13c0
0000000000000004
[  176.724005]  ffff8800152d13c0 ffff880010c07608 ffff8800105d3da8
ffffffff8139dfaf
[  176.724005] Call Trace:
[  176.724005]  [<ffffffff8139ddc0>] ? rhashtable_remove+0x200/0x200
[  176.724005]  [<ffffffff8139dfaf>]
rhashtable_lookup_compare_insert+0x9f/0x110
[  176.724005]  [<ffffffff8139df45>] ?
rhashtable_lookup_compare_insert+0x35/0x110
[  176.724005]  [<ffffffff8165d810>] ? netlink_overrun+0x50/0x50
[  176.724005]  [<ffffffff8165e0f3>] ? netlink_insert+0x43/0xf0
[  176.724005]  [<ffffffff8165e141>] netlink_insert+0x91/0xf0
[  176.724005]  [<ffffffff81660470>] netlink_bind+0x210/0x260
[  176.724005]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  176.724005]  [<ffffffff810a5b10>] ? lock_release_non_nested+0xa0/0x340
[  176.724005]  [<ffffffff81616d24>] SYSC_bind+0xa4/0xc0
[  176.724005]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  176.724005]  [<ffffffff8161701e>] SyS_bind+0xe/0x10
[  176.724005]  [<ffffffff81652318>] compat_SyS_socketcall+0xa8/0x200
[  176.724005]  [<ffffffff81768df3>] sysenter_dispatch+0x7/0x1f
[  176.724005]  [<ffffffff8139660e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  176.724005] Code: 8b 02 83 e8 01 23 45 c4 48 83 c0 02 4c 8b 74 c2 08
41 f6 c6 01 75 1a 4c 89 f7 48 2b 7b 30 4c 89 ee 41 ff d4 84 c0 75 46 4d
8b 36 <41> f6 c6 01 74 e6 4c 39 7d c8 75 6c 48 c7 c2 61 de 39 81 be 01
[  204.724005] NMI watchdog: BUG: soft lockup - CPU#7 stuck for 22s!
[bind_netlink:631]
[  204.724005] Modules linked in: tipc
[  204.724005] irq event stamp: 375131
[  204.724005] hardirqs last  enabled at (375130): [<ffffffff817675e0>]
restore_args+0x0/0x30
[  204.724005] hardirqs last disabled at (375131): [<ffffffff817678aa>]
apic_timer_interrupt+0x6a/0x80
[  204.724005] softirqs last  enabled at (318168): [<ffffffff8161897f>]
lock_sock_nested+0x4f/0xc0
[  204.724005] softirqs last disabled at (318170): [<ffffffff8139d79a>]
lock_buckets+0x3a/0x80
[  204.724005] CPU: 7 PID: 631 Comm: bind_netlink Tainted: G        W
 L 3.19.0-rc6+ #182
[  204.724005] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  204.724005] task: ffff880013970000 ti: ffff8800105d0000 task.ti:
ffff8800105d0000
[  204.724005] RIP: 0010:[<ffffffff8139de4b>]  [<ffffffff8139de4b>]
rhashtable_lookup_compare+0x8b/0x120
[  204.724005] RSP: 0018:ffff8800105d3cf8  EFLAGS: 00000286
[  204.724005] RAX: 0000000000000000 RBX: ffffffff817675e0 RCX:
00000000dbaee169
[  204.724005] RDX: 0000000000001668 RSI: ffff8800105d3db8 RDI:
ffff88001651b800
[  204.724005] RBP: ffff8800105d3d48 R08: 00000000df2b8827 R09:
ffff880010c07468
[  204.724005] R10: 0000000000000003 R11: 0000000000000001 R12:
ffff8800105d3c68
[  204.724005] R13: 0000000000000046 R14: ffff8800105d0000 R15:
ffff880013970000
[  204.724005] FS:  0000000000000000(0000) GS:ffff880017dc0000(0063)
knlGS:00000000f75ae900
[  204.724005] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[  204.724005] CR2: 0000000008760000 CR3: 0000000015121000 CR4:
00000000000006e0
[  204.724005] Stack:
[  204.724005]  ffffffff8139ddc0 000000028105d9c8 07ca27d400000000
ffff8800152d13c0
[  204.724005]  ffff8800105d3d48 ffff880016500000 ffff8800152d13c0
0000000000000004
[  204.724005]  ffff8800152d13c0 ffff880010c07608 ffff8800105d3da8
ffffffff8139dfaf
[  204.724005] Call Trace:
[  204.724005]  [<ffffffff8139ddc0>] ? rhashtable_remove+0x200/0x200
[  204.724005]  [<ffffffff8139dfaf>]
rhashtable_lookup_compare_insert+0x9f/0x110
[  204.724005]  [<ffffffff8139df45>] ?
rhashtable_lookup_compare_insert+0x35/0x110
[  204.724005]  [<ffffffff8165d810>] ? netlink_overrun+0x50/0x50
[  204.724005]  [<ffffffff8165e0f3>] ? netlink_insert+0x43/0xf0
[  204.724005]  [<ffffffff8165e141>] netlink_insert+0x91/0xf0
[  204.724005]  [<ffffffff81660470>] netlink_bind+0x210/0x260
[  204.724005]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  204.724005]  [<ffffffff810a5b10>] ? lock_release_non_nested+0xa0/0x340
[  204.724005]  [<ffffffff81616d24>] SYSC_bind+0xa4/0xc0
[  204.724005]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  204.724005]  [<ffffffff8161701e>] SyS_bind+0xe/0x10
[  204.724005]  [<ffffffff81652318>] compat_SyS_socketcall+0xa8/0x200
[  204.724005]  [<ffffffff81768df3>] sysenter_dispatch+0x7/0x1f
[  204.724005]  [<ffffffff8139660e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  204.724005] Code: e8 05 89 45 c4 48 8b 55 c8 48 8b 02 83 e8 01 23 45
c4 48 83 c0 02 4c 8b 74 c2 08 41 f6 c6 01 75 1a 4c 89 f7 48 2b 7b 30 4c
89 ee <41> ff d4 84 c0 75 46 4d 8b 36 41 f6 c6 01 74 e6 4c 39 7d c8 75
[  232.724005] NMI watchdog: BUG: soft lockup - CPU#7 stuck for 22s!
[bind_netlink:631]
[  232.724005] Modules linked in: tipc
[  232.724005] irq event stamp: 389119
[  232.724005] hardirqs last  enabled at (389118): [<ffffffff817675e0>]
restore_args+0x0/0x30
[  232.724005] hardirqs last disabled at (389119): [<ffffffff817678aa>]
apic_timer_interrupt+0x6a/0x80
[  232.724005] softirqs last  enabled at (318168): [<ffffffff8161897f>]
lock_sock_nested+0x4f/0xc0
[  232.724005] softirqs last disabled at (318170): [<ffffffff8139d79a>]
lock_buckets+0x3a/0x80
[  232.724005] CPU: 7 PID: 631 Comm: bind_netlink Tainted: G        W
 L 3.19.0-rc6+ #182
[  232.724005] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  232.724005] task: ffff880013970000 ti: ffff8800105d0000 task.ti:
ffff8800105d0000
[  232.724005] RIP: 0010:[<ffffffff8165d820>]  [<ffffffff8165d820>]
netlink_compare+0x10/0x30
[  232.724005] RSP: 0018:ffff8800105d3cf0  EFLAGS: 00000293
[  232.724005] RAX: 0000000000000000 RBX: ffffffff817675e0 RCX:
00000000dbaee169
[  232.724005] RDX: 0000000000001668 RSI: ffff8800105d3db8 RDI:
ffff88001651b800
[  232.724005] RBP: ffff8800105d3d48 R08: 00000000df2b8827 R09:
ffff880010c07468
[  232.724005] R10: 0000000000000003 R11: 0000000000000001 R12:
ffff8800105d3c68
[  232.724005] R13: 0000000000000046 R14: ffff8800105d0000 R15:
ffff880013970000
[  232.724005] FS:  0000000000000000(0000) GS:ffff880017dc0000(0063)
knlGS:00000000f75ae900
[  232.724005] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[  232.724005] CR2: 0000000008760000 CR3: 0000000015121000 CR4:
00000000000006e0
[  232.724005] Stack:
[  232.724005]  ffffffff8139de4e ffffffff8139ddc0 000000028105d9c8
07ca27d400000000
[  232.724005]  ffff8800152d13c0 ffff8800105d3d48 ffff880016500000
ffff8800152d13c0
[  232.724005]  0000000000000004 ffff8800152d13c0 ffff880010c07608
ffff8800105d3da8
[  232.724005] Call Trace:
[  232.724005]  [<ffffffff8139de4e>] ? rhashtable_lookup_compare+0x8e/0x120
[  232.724005]  [<ffffffff8139ddc0>] ? rhashtable_remove+0x200/0x200
[  232.724005]  [<ffffffff8139dfaf>]
rhashtable_lookup_compare_insert+0x9f/0x110
[  232.724005]  [<ffffffff8139df45>] ?
rhashtable_lookup_compare_insert+0x35/0x110
[  232.724005]  [<ffffffff8165d810>] ? netlink_overrun+0x50/0x50
[  232.724005]  [<ffffffff8165e0f3>] ? netlink_insert+0x43/0xf0
[  232.724005]  [<ffffffff8165e141>] netlink_insert+0x91/0xf0
[  232.724005]  [<ffffffff81660470>] netlink_bind+0x210/0x260
[  232.724005]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  232.724005]  [<ffffffff810a5b10>] ? lock_release_non_nested+0xa0/0x340
[  232.724005]  [<ffffffff81616d24>] SYSC_bind+0xa4/0xc0
[  232.724005]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  232.724005]  [<ffffffff8161701e>] SyS_bind+0xe/0x10
[  232.724005]  [<ffffffff81652318>] compat_SyS_socketcall+0xa8/0x200
[  232.724005]  [<ffffffff81768df3>] sysenter_dispatch+0x7/0x1f
[  232.724005]  [<ffffffff8139660e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  232.724005] Code: f0 ff 83 98 01 00 00 48 83 c4 08 5b 5d c3 66 66 66
66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 31 c0 8b 56 08 39 97 68 04
00 00 <55> 48 89 e5 74 0a 5d c3 0f 1f 84 00 00 00 00 00 48 8b 47 30 48
[  240.772081] INFO: task kworker/7:1:70 blocked for more than 120 seconds.
[  240.773035]       Tainted: G        W    L 3.19.0-rc6+ #182
[  240.773811] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[  240.774897] kworker/7:1     D ffff8800167c3af8     0    70      2
0x00000000
[  240.775940] Workqueue: events rht_deferred_worker
[  240.776676]  ffff8800167c3af8 0000000000001ffb ffff8800167b8000
00000000000139c0
[  240.777763]  ffff8800167c3fd8 0000000000000000 00000000000139c0
ffff880013970000
[  240.778845]  ffff8800167b8000 0000000000000000 ffff8800167c3c58
7fffffffffffffff
[  240.779928] Call Trace:
[  240.780318]  [<ffffffff81760879>] schedule+0x29/0x70
[  240.781014]  [<ffffffff81764de5>] schedule_timeout+0x1d5/0x230
[  240.781826]  [<ffffffff810a68fa>] ? mark_held_locks+0x6a/0x90
[  240.782622]  [<ffffffff817663b0>] ? _raw_spin_unlock_irq+0x30/0x40
[  240.783459]  [<ffffffff810a6a25>] ? trace_hardirqs_on_caller+0x105/0x1d0
[  240.784483]  [<ffffffff81761d1b>] wait_for_completion+0xbb/0x120
[  240.785322]  [<ffffffff81087910>] ? try_to_wake_up+0x3c0/0x3c0
[  240.786179]  [<ffffffff810c12f0>] ? __call_rcu.constprop.61+0x260/0x260
[  240.787122]  [<ffffffff810bea9d>] wait_rcu_gp+0x4d/0x60
[  240.787906]  [<ffffffff810beab0>] ? wait_rcu_gp+0x60/0x60
[  240.788721]  [<ffffffff810c1cfd>] synchronize_sched+0x5d/0x70
[  240.789538]  [<ffffffff8139e653>] rhashtable_shrink+0x113/0x150
[  240.790385]  [<ffffffff8139ea30>] rht_deferred_worker+0x80/0xa0
[  240.791235]  [<ffffffff81073449>] process_one_work+0x1b9/0x530
[  240.792100]  [<ffffffff810733d2>] ? process_one_work+0x142/0x530
[  240.792960]  [<ffffffff81073c5f>] worker_thread+0x11f/0x480
[  240.793740]  [<ffffffff81073b40>] ? rescuer_thread+0x340/0x340
[  240.794552]  [<ffffffff81079b4f>] kthread+0xef/0x110
[  240.795268]  [<ffffffff81079a60>] ? flush_kthread_worker+0xf0/0xf0
[  240.796185]  [<ffffffff817668ec>] ret_from_fork+0x7c/0xb0
[  240.796938]  [<ffffffff81079a60>] ? flush_kthread_worker+0xf0/0xf0
[  240.797785] 3 locks held by kworker/7:1/70:
[  240.798411]  #0:  ("events"){.+.+.+}, at: [<ffffffff810733d2>]
process_one_work+0x142/0x530
[  240.799699]  #1:  ((&ht->run_work)){+.+.+.}, at: [<ffffffff810733d2>]
process_one_work+0x142/0x530
[  240.801082]  #2:  (&ht->mutex){+.+.+.}, at: [<ffffffff8139e9dd>]
rht_deferred_worker+0x2d/0xa0
[  260.724007] NMI watchdog: BUG: soft lockup - CPU#7 stuck for 22s!
[bind_netlink:631]
[  260.724007] Modules linked in: tipc
[  260.724007] irq event stamp: 403107
[  260.724007] hardirqs last  enabled at (403106): [<ffffffff817675e0>]
restore_args+0x0/0x30
[  260.724007] hardirqs last disabled at (403107): [<ffffffff817678aa>]
apic_timer_interrupt+0x6a/0x80
[  260.724007] softirqs last  enabled at (318168): [<ffffffff8161897f>]
lock_sock_nested+0x4f/0xc0
[  260.724007] softirqs last disabled at (318170): [<ffffffff8139d79a>]
lock_buckets+0x3a/0x80
[  260.724007] CPU: 7 PID: 631 Comm: bind_netlink Tainted: G        W
 L 3.19.0-rc6+ #182
[  260.724007] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  260.724007] task: ffff880013970000 ti: ffff8800105d0000 task.ti:
ffff8800105d0000
[  260.724007] RIP: 0010:[<ffffffff8165d826>]  [<ffffffff8165d826>]
netlink_compare+0x16/0x30
[  260.724007] RSP: 0018:ffff8800105d3ce8  EFLAGS: 00000293
[  260.724007] RAX: 0000000000000000 RBX: ffff8800105d3c68 RCX:
00000000dbaee169
[  260.724007] RDX: 0000000000001668 RSI: ffff8800105d3db8 RDI:
ffff88001651b800
[  260.724007] RBP: ffff8800105d3ce8 R08: 00000000df2b8827 R09:
ffff880010c07468
[  260.724007] R10: 0000000000000003 R11: 0000000000000001 R12:
ffff8800105d0000
[  260.724007] R13: ffff880013970000 R14: 0000000000000000 R15:
0000000000000001
[  260.724007] FS:  0000000000000000(0000) GS:ffff880017dc0000(0063)
knlGS:00000000f75ae900
[  260.724007] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[  260.724007] CR2: 0000000008760000 CR3: 0000000015121000 CR4:
00000000000006e0
[  260.724007] Stack:
[  260.724007]  ffff8800105d3d48 ffffffff8139de4e ffffffff8139ddc0
000000028105d9c8
[  260.724007]  07ca27d400000000 ffff8800152d13c0 ffff8800105d3d48
ffff880016500000
[  260.724007]  ffff8800152d13c0 0000000000000004 ffff8800152d13c0
ffff880010c07608
[  260.724007] Call Trace:
[  260.724007]  [<ffffffff8139de4e>] rhashtable_lookup_compare+0x8e/0x120
[  260.724007]  [<ffffffff8139ddc0>] ? rhashtable_remove+0x200/0x200
[  260.724007]  [<ffffffff8139dfaf>]
rhashtable_lookup_compare_insert+0x9f/0x110
[  260.724007]  [<ffffffff8139df45>] ?
rhashtable_lookup_compare_insert+0x35/0x110
[  260.724007]  [<ffffffff8165d810>] ? netlink_overrun+0x50/0x50
[  260.724007]  [<ffffffff8165e0f3>] ? netlink_insert+0x43/0xf0
[  260.724007]  [<ffffffff8165e141>] netlink_insert+0x91/0xf0
[  260.724007]  [<ffffffff81660470>] netlink_bind+0x210/0x260
[  260.724007]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  260.724007]  [<ffffffff810a5b10>] ? lock_release_non_nested+0xa0/0x340
[  260.724007]  [<ffffffff81616d24>] SYSC_bind+0xa4/0xc0
[  260.724007]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  260.724007]  [<ffffffff8161701e>] SyS_bind+0xe/0x10
[  260.724007]  [<ffffffff81652318>] compat_SyS_socketcall+0xa8/0x200
[  260.724007]  [<ffffffff81768df3>] sysenter_dispatch+0x7/0x1f
[  260.724007]  [<ffffffff8139660e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  260.724007] Code: 00 48 83 c4 08 5b 5d c3 66 66 66 66 2e 0f 1f 84 00
00 00 00 00 0f 1f 44 00 00 31 c0 8b 56 08 39 97 68 04 00 00 55 48 89 e5
74 0a <5d> c3 0f 1f 84 00 00 00 00 00 48 8b 47 30 48 39 06 5d 0f 94 c0
[  288.724004] NMI watchdog: BUG: soft lockup - CPU#7 stuck for 22s!
[bind_netlink:631]
[  288.724004] Modules linked in: tipc
[  288.724004] irq event stamp: 417095
[  288.724004] hardirqs last  enabled at (417094): [<ffffffff817675e0>]
restore_args+0x0/0x30
[  288.724004] hardirqs last disabled at (417095): [<ffffffff817678aa>]
apic_timer_interrupt+0x6a/0x80
[  288.724004] softirqs last  enabled at (318168): [<ffffffff8161897f>]
lock_sock_nested+0x4f/0xc0
[  288.724004] softirqs last disabled at (318170): [<ffffffff8139d79a>]
lock_buckets+0x3a/0x80
[  288.724004] CPU: 7 PID: 631 Comm: bind_netlink Tainted: G        W
 L 3.19.0-rc6+ #182
[  288.724004] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  288.724004] task: ffff880013970000 ti: ffff8800105d0000 task.ti:
ffff8800105d0000
[  288.724004] RIP: 0010:[<ffffffff8139de4b>]  [<ffffffff8139de4b>]
rhashtable_lookup_compare+0x8b/0x120
[  288.724004] RSP: 0018:ffff8800105d3cf8  EFLAGS: 00000286
[  288.724004] RAX: 0000000000000000 RBX: ffffffff817675e0 RCX:
00000000dbaee169
[  288.724004] RDX: 0000000000001668 RSI: ffff8800105d3db8 RDI:
ffff88001651b800
[  288.724004] RBP: ffff8800105d3d48 R08: 00000000df2b8827 R09:
ffff880010c07468
[  288.724004] R10: 0000000000000003 R11: 0000000000000001 R12:
ffff8800105d3c68
[  288.724004] R13: 0000000000000046 R14: ffff8800105d0000 R15:
ffff880013970000
[  288.724004] FS:  0000000000000000(0000) GS:ffff880017dc0000(0063)
knlGS:00000000f75ae900
[  288.724004] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[  288.724004] CR2: 0000000008760000 CR3: 0000000015121000 CR4:
00000000000006e0
[  288.724004] Stack:
[  288.724004]  ffffffff8139ddc0 000000028105d9c8 07ca27d400000000
ffff8800152d13c0
[  288.724004]  ffff8800105d3d48 ffff880016500000 ffff8800152d13c0
0000000000000004
[  288.724004]  ffff8800152d13c0 ffff880010c07608 ffff8800105d3da8
ffffffff8139dfaf
[  288.724004] Call Trace:
[  288.724004]  [<ffffffff8139ddc0>] ? rhashtable_remove+0x200/0x200
[  288.724004]  [<ffffffff8139dfaf>]
rhashtable_lookup_compare_insert+0x9f/0x110
[  288.724004]  [<ffffffff8139df45>] ?
rhashtable_lookup_compare_insert+0x35/0x110
[  288.724004]  [<ffffffff8165d810>] ? netlink_overrun+0x50/0x50
[  288.724004]  [<ffffffff8165e0f3>] ? netlink_insert+0x43/0xf0
[  288.724004]  [<ffffffff8165e141>] netlink_insert+0x91/0xf0
[  288.724004]  [<ffffffff81660470>] netlink_bind+0x210/0x260
[  288.724004]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  288.724004]  [<ffffffff810a5b10>] ? lock_release_non_nested+0xa0/0x340
[  288.724004]  [<ffffffff81616d24>] SYSC_bind+0xa4/0xc0
[  288.724004]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  288.724004]  [<ffffffff8161701e>] SyS_bind+0xe/0x10
[  288.724004]  [<ffffffff81652318>] compat_SyS_socketcall+0xa8/0x200
[  288.724004]  [<ffffffff81768df3>] sysenter_dispatch+0x7/0x1f
[  288.724004]  [<ffffffff8139660e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  288.724004] Code: e8 05 89 45 c4 48 8b 55 c8 48 8b 02 83 e8 01 23 45
c4 48 83 c0 02 4c 8b 74 c2 08 41 f6 c6 01 75 1a 4c 89 f7 48 2b 7b 30 4c
89 ee <41> ff d4 84 c0 75 46 4d 8b 36 41 f6 c6 01 74 e6 4c 39 7d c8 75
[  316.724005] NMI watchdog: BUG: soft lockup - CPU#7 stuck for 22s!
[bind_netlink:631]
[  316.724005] Modules linked in: tipc
[  316.724005] irq event stamp: 431083
[  316.724005] hardirqs last  enabled at (431082): [<ffffffff817675e0>]
restore_args+0x0/0x30
[  316.724005] hardirqs last disabled at (431083): [<ffffffff817678aa>]
apic_timer_interrupt+0x6a/0x80
[  316.724005] softirqs last  enabled at (318168): [<ffffffff8161897f>]
lock_sock_nested+0x4f/0xc0
[  316.724005] softirqs last disabled at (318170): [<ffffffff8139d79a>]
lock_buckets+0x3a/0x80
[  316.724005] CPU: 7 PID: 631 Comm: bind_netlink Tainted: G        W
 L 3.19.0-rc6+ #182
[  316.724005] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  316.724005] task: ffff880013970000 ti: ffff8800105d0000 task.ti:
ffff8800105d0000
[  316.724005] RIP: 0010:[<ffffffff8139de4b>]  [<ffffffff8139de4b>]
rhashtable_lookup_compare+0x8b/0x120
[  316.724005] RSP: 0018:ffff8800105d3cf8  EFLAGS: 00000286
[  316.724005] RAX: 0000000000000000 RBX: ffffffff817675e0 RCX:
00000000dbaee169
[  316.724005] RDX: 0000000000001668 RSI: ffff8800105d3db8 RDI:
ffff88001651b800
[  316.724005] RBP: ffff8800105d3d48 R08: 00000000df2b8827 R09:
ffff880010c07468
[  316.724005] R10: 0000000000000003 R11: 0000000000000001 R12:
ffff8800105d3c68
[  316.724005] R13: 0000000000000046 R14: ffff8800105d0000 R15:
ffff880013970000
[  316.724005] FS:  0000000000000000(0000) GS:ffff880017dc0000(0063)
knlGS:00000000f75ae900
[  316.724005] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[  316.724005] CR2: 0000000008760000 CR3: 0000000015121000 CR4:
00000000000006e0
[  316.724005] Stack:
[  316.724005]  ffffffff8139ddc0 000000028105d9c8 07ca27d400000000
ffff8800152d13c0
[  316.724005]  ffff8800105d3d48 ffff880016500000 ffff8800152d13c0
0000000000000004
[  316.724005]  ffff8800152d13c0 ffff880010c07608 ffff8800105d3da8
ffffffff8139dfaf
[  316.724005] Call Trace:
[  316.724005]  [<ffffffff8139ddc0>] ? rhashtable_remove+0x200/0x200
[  316.724005]  [<ffffffff8139dfaf>]
rhashtable_lookup_compare_insert+0x9f/0x110
[  316.724005]  [<ffffffff8139df45>] ?
rhashtable_lookup_compare_insert+0x35/0x110
[  316.724005]  [<ffffffff8165d810>] ? netlink_overrun+0x50/0x50
[  316.724005]  [<ffffffff8165e0f3>] ? netlink_insert+0x43/0xf0
[  316.724005]  [<ffffffff8165e141>] netlink_insert+0x91/0xf0
[  316.724005]  [<ffffffff81660470>] netlink_bind+0x210/0x260
[  316.724005]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  316.724005]  [<ffffffff810a5b10>] ? lock_release_non_nested+0xa0/0x340
[  316.724005]  [<ffffffff81616d24>] SYSC_bind+0xa4/0xc0
[  316.724005]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  316.724005]  [<ffffffff8161701e>] SyS_bind+0xe/0x10
[  316.724005]  [<ffffffff81652318>] compat_SyS_socketcall+0xa8/0x200
[  316.724005]  [<ffffffff81768df3>] sysenter_dispatch+0x7/0x1f
[  316.724005]  [<ffffffff8139660e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  316.724005] Code: e8 05 89 45 c4 48 8b 55 c8 48 8b 02 83 e8 01 23 45
c4 48 83 c0 02 4c 8b 74 c2 08 41 f6 c6 01 75 1a 4c 89 f7 48 2b 7b 30 4c
89 ee <41> ff d4 84 c0 75 46 4d 8b 36 41 f6 c6 01 74 e6 4c 39 7d c8 75
[  330.748004] INFO: rcu_sched self-detected stall on CPU { 7}  (t=60004
jiffies g=674 c=673 q=100)
[  330.748004] Task dump for CPU 7:
[  330.748004] bind_netlink    R  running task        0   631    561
0x20020008
[  330.748004]  0000000000000231 ffff880017dc3d68 ffffffff81086c26
ffffffff81086b88
[  330.748004]  00000000f75af759 0000000000000007 ffffffff81c53940
ffff880017dc3d88
[  330.748004]  ffffffff8108a57f ffffffff81c53940 ffffffff81c53940
ffff880017dc3db8
[  330.748004] Call Trace:
[  330.748004]  <IRQ>  [<ffffffff81086c26>] sched_show_task+0x106/0x170
[  330.748004]  [<ffffffff81086b88>] ? sched_show_task+0x68/0x170
[  330.748004]  [<ffffffff8108a57f>] dump_cpu_task+0x3f/0x50
[  330.748004]  [<ffffffff810bfa7b>] rcu_dump_cpu_stacks+0x8b/0xc0
[  330.748004]  [<ffffffff810c33d0>] rcu_check_callbacks+0x480/0x6d0
[  330.748004]  [<ffffffff810a133d>] ? trace_hardirqs_off+0xd/0x10
[  330.748004]  [<ffffffff810c8408>] update_process_times+0x38/0x70
[  330.748004]  [<ffffffff810d8623>] tick_sched_handle.isra.15+0x33/0x70
[  330.748004]  [<ffffffff810d88cb>] tick_sched_timer+0x4b/0x80
[  330.748004]  [<ffffffff810c8d8b>] __run_hrtimer+0x9b/0x290
[  330.748004]  [<ffffffff810d8880>] ? tick_sched_do_timer+0x40/0x40
[  330.748004]  [<ffffffff810c95e4>] ? hrtimer_interrupt+0x74/0x260
[  330.748004]  [<ffffffff810c9677>] hrtimer_interrupt+0x107/0x260
[  330.748004]  [<ffffffff8165d810>] ? netlink_overrun+0x50/0x50
[  330.748004]  [<ffffffff81034cb9>] local_apic_timer_interrupt+0x39/0x60
[  330.748004]  [<ffffffff81769525>] smp_apic_timer_interrupt+0x45/0x60
[  330.748004]  [<ffffffff817678af>] apic_timer_interrupt+0x6f/0x80
[  330.748004]  <EOI>  [<ffffffff817675e0>] ? retint_restore_args+0xe/0xe
[  330.748004]  [<ffffffff8165d817>] ? netlink_compare+0x7/0x30
[  330.748004]  [<ffffffff8139de4e>] ? rhashtable_lookup_compare+0x8e/0x120
[  330.748004]  [<ffffffff8139ddc0>] ? rhashtable_remove+0x200/0x200
[  330.748004]  [<ffffffff8139dfaf>]
rhashtable_lookup_compare_insert+0x9f/0x110
[  330.748004]  [<ffffffff8139df45>] ?
rhashtable_lookup_compare_insert+0x35/0x110
[  330.748004]  [<ffffffff8165d810>] ? netlink_overrun+0x50/0x50
[  330.748004]  [<ffffffff8165e0f3>] ? netlink_insert+0x43/0xf0
[  330.748004]  [<ffffffff8165e141>] netlink_insert+0x91/0xf0
[  330.748004]  [<ffffffff81660470>] netlink_bind+0x210/0x260
[  330.748004]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  330.748004]  [<ffffffff810a5b10>] ? lock_release_non_nested+0xa0/0x340
[  330.748004]  [<ffffffff81616d24>] SYSC_bind+0xa4/0xc0
[  330.748004]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  330.748004]  [<ffffffff8161701e>] SyS_bind+0xe/0x10
[  330.748004]  [<ffffffff81652318>] compat_SyS_socketcall+0xa8/0x200
[  330.748004]  [<ffffffff81768df3>] sysenter_dispatch+0x7/0x1f
[  330.748004]  [<ffffffff8139660e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  330.771015] INFO: rcu_sched detected stalls on CPUs/tasks: { 7}
(detected by 1, t=60009 jiffies, g=674, c=673, q=100)
[  330.772011] Task dump for CPU 7:
[  330.772011] bind_netlink    R  running task        0   631    561
0x20020008
[  330.772011]  0000000000000000 0000000000000000 ffff8800105d3f28
0000000000000002
[  330.772011]  00000000ffdfca20 000000000000000c ffff8800105d3f28
ffffffff8161701e
[  330.772011]  ffff8800105d3f78 ffffffff81652318 0000000000000001
ffdfca38000013f3
[  330.772011] Call Trace:
[  330.772011]  [<ffffffff8161701e>] ? SyS_bind+0xe/0x10
[  330.772011]  [<ffffffff81652318>] ? compat_SyS_socketcall+0xa8/0x200
[  330.772011]  [<ffffffff81768df3>] ? sysenter_dispatch+0x7/0x1f
[  330.772011]  [<ffffffff8139660e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  356.724013] NMI watchdog: BUG: soft lockup - CPU#7 stuck for 23s!
[bind_netlink:631]
[  356.724013] Modules linked in: tipc
[  356.724013] irq event stamp: 451061
[  356.724013] hardirqs last  enabled at (451060): [<ffffffff817675e0>]
restore_args+0x0/0x30
[  356.724013] hardirqs last disabled at (451061): [<ffffffff817678aa>]
apic_timer_interrupt+0x6a/0x80
[  356.724013] softirqs last  enabled at (318168): [<ffffffff8161897f>]
lock_sock_nested+0x4f/0xc0
[  356.724013] softirqs last disabled at (318170): [<ffffffff8139d79a>]
lock_buckets+0x3a/0x80
[  356.724013] CPU: 7 PID: 631 Comm: bind_netlink Tainted: G        W
 L 3.19.0-rc6+ #182
[  356.724013] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  356.724013] task: ffff880013970000 ti: ffff8800105d0000 task.ti:
ffff8800105d0000
[  356.724013] RIP: 0010:[<ffffffff8139de55>]  [<ffffffff8139de55>]
rhashtable_lookup_compare+0x95/0x120
[  356.724013] RSP: 0018:ffff8800105d3cf8  EFLAGS: 00000246
[  356.724013] RAX: 0000000000000000 RBX: ffffffff817675e0 RCX:
00000000dbaee169
[  356.724013] RDX: 0000000000001668 RSI: ffff8800105d3db8 RDI:
ffff88001651b800
[  356.724013] RBP: ffff8800105d3d48 R08: 00000000df2b8827 R09:
ffff880010c07468
[  356.724013] R10: 0000000000000003 R11: 0000000000000001 R12:
ffff8800105d3c68
[  356.724013] R13: 0000000000000046 R14: ffff8800105d0000 R15:
ffff880013970000
[  356.724013] FS:  0000000000000000(0000) GS:ffff880017dc0000(0063)
knlGS:00000000f75ae900
[  356.724013] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[  356.724013] CR2: 0000000008760000 CR3: 0000000015121000 CR4:
00000000000006e0
[  356.724013] Stack:
[  356.724013]  ffffffff8139ddc0 000000028105d9c8 07ca27d400000000
ffff8800152d13c0
[  356.724013]  ffff8800105d3d48 ffff880016500000 ffff8800152d13c0
0000000000000004
[  356.724013]  ffff8800152d13c0 ffff880010c07608 ffff8800105d3da8
ffffffff8139dfaf
[  356.724013] Call Trace:
[  356.724013]  [<ffffffff8139ddc0>] ? rhashtable_remove+0x200/0x200
[  356.724013]  [<ffffffff8139dfaf>]
rhashtable_lookup_compare_insert+0x9f/0x110
[  356.724013]  [<ffffffff8139df45>] ?
rhashtable_lookup_compare_insert+0x35/0x110
[  356.724013]  [<ffffffff8165d810>] ? netlink_overrun+0x50/0x50
[  356.724013]  [<ffffffff8165e0f3>] ? netlink_insert+0x43/0xf0
[  356.724013]  [<ffffffff8165e141>] netlink_insert+0x91/0xf0
[  356.724013]  [<ffffffff81660470>] netlink_bind+0x210/0x260
[  356.724013]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  356.724013]  [<ffffffff810a5b10>] ? lock_release_non_nested+0xa0/0x340
[  356.724013]  [<ffffffff81616d24>] SYSC_bind+0xa4/0xc0
[  356.724013]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  356.724013]  [<ffffffff8161701e>] SyS_bind+0xe/0x10
[  356.724013]  [<ffffffff81652318>] compat_SyS_socketcall+0xa8/0x200
[  356.724013]  [<ffffffff81768df3>] sysenter_dispatch+0x7/0x1f
[  356.724013]  [<ffffffff8139660e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  356.724013] Code: 8b 02 83 e8 01 23 45 c4 48 83 c0 02 4c 8b 74 c2 08
41 f6 c6 01 75 1a 4c 89 f7 48 2b 7b 30 4c 89 ee 41 ff d4 84 c0 75 46 4d
8b 36 <41> f6 c6 01 74 e6 4c 39 7d c8 75 6c 48 c7 c2 61 de 39 81 be 01
[  360.800040] INFO: task kworker/7:1:70 blocked for more than 120 seconds.
[  360.800687]       Tainted: G        W    L 3.19.0-rc6+ #182
[  360.801176] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[  360.801858] kworker/7:1     D ffff8800167c3af8     0    70      2
0x00000000
[  360.802495] Workqueue: events rht_deferred_worker
[  360.802943]  ffff8800167c3af8 0000000000001ffb ffff8800167b8000
00000000000139c0
[  360.803624]  ffff8800167c3fd8 0000000000000000 00000000000139c0
ffff880013970000
[  360.804388]  ffff8800167b8000 0000000000000000 ffff8800167c3c58
7fffffffffffffff
[  360.805071] Call Trace:
[  360.805295]  [<ffffffff81760879>] schedule+0x29/0x70
[  360.805751]  [<ffffffff81764de5>] schedule_timeout+0x1d5/0x230
[  360.806262]  [<ffffffff810a68fa>] ? mark_held_locks+0x6a/0x90
[  360.806764]  [<ffffffff817663b0>] ? _raw_spin_unlock_irq+0x30/0x40
[  360.807323]  [<ffffffff810a6a25>] ? trace_hardirqs_on_caller+0x105/0x1d0
[  360.808109]  [<ffffffff81761d1b>] wait_for_completion+0xbb/0x120
[  360.808653]  [<ffffffff81087910>] ? try_to_wake_up+0x3c0/0x3c0
[  360.809178]  [<ffffffff810c12f0>] ? __call_rcu.constprop.61+0x260/0x260
[  360.809772]  [<ffffffff810bea9d>] wait_rcu_gp+0x4d/0x60
[  360.810246]  [<ffffffff810beab0>] ? wait_rcu_gp+0x60/0x60
[  360.810733]  [<ffffffff810c1cfd>] synchronize_sched+0x5d/0x70
[  360.811358]  [<ffffffff8139e653>] rhashtable_shrink+0x113/0x150
[  360.811876]  [<ffffffff8139ea30>] rht_deferred_worker+0x80/0xa0
[  360.812424]  [<ffffffff81073449>] process_one_work+0x1b9/0x530
[  360.812957]  [<ffffffff810733d2>] ? process_one_work+0x142/0x530
[  360.813481]  [<ffffffff81073c5f>] worker_thread+0x11f/0x480
[  360.813969]  [<ffffffff81073b40>] ? rescuer_thread+0x340/0x340
[  360.814480]  [<ffffffff81079b4f>] kthread+0xef/0x110
[  360.814919]  [<ffffffff81079a60>] ? flush_kthread_worker+0xf0/0xf0
[  360.815459]  [<ffffffff817668ec>] ret_from_fork+0x7c/0xb0
[  360.815945]  [<ffffffff81079a60>] ? flush_kthread_worker+0xf0/0xf0
[  360.816523] 3 locks held by kworker/7:1/70:
[  360.816893]  #0:  ("events"){.+.+.+}, at: [<ffffffff810733d2>]
process_one_work+0x142/0x530
[  360.817696]  #1:  ((&ht->run_work)){+.+.+.}, at: [<ffffffff810733d2>]
process_one_work+0x142/0x530
[  360.818527]  #2:  (&ht->mutex){+.+.+.}, at: [<ffffffff8139e9dd>]
rht_deferred_worker+0x2d/0xa0
[  360.819349] INFO: task jbd2/sda-8:116 blocked for more than 120 seconds.
[  360.819943]       Tainted: G        W    L 3.19.0-rc6+ #182
[  360.820472] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[  360.821157] jbd2/sda-8      D ffff8800159a3af8     0   116      2
0x00000000
[  360.821832]  ffff8800159a3af8 ffff8800159a3aa8 ffff8800159c2110
00000000000139c0
[  360.822515]  ffff8800159a3fd8 ffff8800159a3ab8 00000000000139c0
ffff880015a64220
[  360.823222]  ffff8800159c2110 ffffffff81118113 ffff880017d14330
ffff8800159c2110
[  360.823907] Call Trace:
[  360.824162]  [<ffffffff81118113>] ? __delayacct_blkio_start+0x23/0x30
[  360.824817]  [<ffffffff81761250>] ? bit_wait_timeout+0x80/0x80
[  360.825397]  [<ffffffff81760879>] schedule+0x29/0x70
[  360.825863]  [<ffffffff8176094e>] io_schedule+0x8e/0xd0
[  360.826406]  [<ffffffff8176127c>] bit_wait_io+0x2c/0x50
[  360.826966]  [<ffffffff81760fe5>] __wait_on_bit+0x65/0x90
[  360.827458]  [<ffffffff811f83bc>] ? _submit_bh+0x11c/0x150
[  360.827952]  [<ffffffff81761250>] ? bit_wait_timeout+0x80/0x80
[  360.828488]  [<ffffffff8176113c>] out_of_line_wait_on_bit+0x7c/0x90
[  360.829056]  [<ffffffff81099f30>] ? wake_atomic_t_function+0x40/0x40
[  360.829628]  [<ffffffff811f64a9>] __wait_on_buffer+0x49/0x50
[  360.830147]  [<ffffffff812bce65>]
jbd2_journal_commit_transaction+0x16c5/0x1be0
[  360.830806]  [<ffffffff810a6afd>] ? trace_hardirqs_on+0xd/0x10
[  360.831319]  [<ffffffff810c6335>] ? del_timer_sync+0x5/0xd0
[  360.831811]  [<ffffffff812c0a21>] kjournald2+0xc1/0x280
[  360.832331]  [<ffffffff81099eb0>] ? prepare_to_wait_event+0x120/0x120
[  360.832897]  [<ffffffff812c0960>] ? commit_timeout+0x10/0x10
[  360.833416]  [<ffffffff81079b4f>] kthread+0xef/0x110
[  360.833854]  [<ffffffff81079a60>] ? flush_kthread_worker+0xf0/0xf0
[  360.834398]  [<ffffffff817668ec>] ret_from_fork+0x7c/0xb0
[  360.834873]  [<ffffffff81079a60>] ? flush_kthread_worker+0xf0/0xf0
[  360.835413] no locks held by jbd2/sda-8/116.
[  384.724008] NMI watchdog: BUG: soft lockup - CPU#7 stuck for 23s!
[bind_netlink:631]
[  384.724008] Modules linked in: tipc
[  384.724008] irq event stamp: 465049
[  384.724008] hardirqs last  enabled at (465048): [<ffffffff817675e0>]
restore_args+0x0/0x30
[  384.724008] hardirqs last disabled at (465049): [<ffffffff817678aa>]
apic_timer_interrupt+0x6a/0x80
[  384.724008] softirqs last  enabled at (318168): [<ffffffff8161897f>]
lock_sock_nested+0x4f/0xc0
[  384.724008] softirqs last disabled at (318170): [<ffffffff8139d79a>]
lock_buckets+0x3a/0x80
[  384.724008] CPU: 7 PID: 631 Comm: bind_netlink Tainted: G        W
 L 3.19.0-rc6+ #182
[  384.724008] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  384.724008] task: ffff880013970000 ti: ffff8800105d0000 task.ti:
ffff8800105d0000
[  384.724008] RIP: 0010:[<ffffffff8165d810>]  [<ffffffff8165d810>]
netlink_compare+0x0/0x30
[  384.724008] RSP: 0018:ffff8800105d3cf0  EFLAGS: 00000286
[  384.724008] RAX: 0000000000000000 RBX: ffffffff817675e0 RCX:
00000000dbaee169
[  384.724008] RDX: 0000000000001668 RSI: ffff8800105d3db8 RDI:
ffff88001651b800
[  384.724008] RBP: ffff8800105d3d48 R08: 00000000df2b8827 R09:
ffff880010c07468
[  384.724008] R10: 0000000000000003 R11: 0000000000000001 R12:
ffff8800105d3c68
[  384.724008] R13: 0000000000000046 R14: ffff8800105d0000 R15:
ffff880013970000
[  384.724008] FS:  0000000000000000(0000) GS:ffff880017dc0000(0063)
knlGS:00000000f75ae900
[  384.724008] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[  384.724008] CR2: 0000000008760000 CR3: 0000000015121000 CR4:
00000000000006e0
[  384.724008] Stack:
[  384.724008]  ffffffff8139de4e ffffffff8139ddc0 000000028105d9c8
07ca27d400000000
[  384.724008]  ffff8800152d13c0 ffff8800105d3d48 ffff880016500000
ffff8800152d13c0
[  384.724008]  0000000000000004 ffff8800152d13c0 ffff880010c07608
ffff8800105d3da8
[  384.724008] Call Trace:
[  384.724008]  [<ffffffff8139de4e>] ? rhashtable_lookup_compare+0x8e/0x120
[  384.724008]  [<ffffffff8139ddc0>] ? rhashtable_remove+0x200/0x200
[  384.724008]  [<ffffffff8139dfaf>]
rhashtable_lookup_compare_insert+0x9f/0x110
[  384.724008]  [<ffffffff8139df45>] ?
rhashtable_lookup_compare_insert+0x35/0x110
[  384.724008]  [<ffffffff8165d810>] ? netlink_overrun+0x50/0x50
[  384.724008]  [<ffffffff8165e0f3>] ? netlink_insert+0x43/0xf0
[  384.724008]  [<ffffffff8165e141>] netlink_insert+0x91/0xf0
[  384.724008]  [<ffffffff81660470>] netlink_bind+0x210/0x260
[  384.724008]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  384.724008]  [<ffffffff810a5b10>] ? lock_release_non_nested+0xa0/0x340
[  384.724008]  [<ffffffff81616d24>] SYSC_bind+0xa4/0xc0
[  384.724008]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  384.724008]  [<ffffffff8161701e>] SyS_bind+0xe/0x10
[  384.724008]  [<ffffffff81652318>] compat_SyS_socketcall+0xa8/0x200
[  384.724008]  [<ffffffff81768df3>] sysenter_dispatch+0x7/0x1f
[  384.724008]  [<ffffffff8139660e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  384.724008] Code: c7 87 30 03 00 00 69 00 00 00 ff 93 50 04 00 00 f0
ff 83 98 01 00 00 48 83 c4 08 5b 5d c3 66 66 66 66 2e 0f 1f 84 00 00 00
00 00 <0f> 1f 44 00 00 31 c0 8b 56 08 39 97 68 04 00 00 55 48 89 e5 74
[  412.724006] NMI watchdog: BUG: soft lockup - CPU#7 stuck for 22s!
[bind_netlink:631]
[  412.724006] Modules linked in: tipc
[  412.724006] irq event stamp: 479037
[  412.724006] hardirqs last  enabled at (479036): [<ffffffff817675e0>]
restore_args+0x0/0x30
[  412.724006] hardirqs last disabled at (479037): [<ffffffff817678aa>]
apic_timer_interrupt+0x6a/0x80
[  412.724006] softirqs last  enabled at (318168): [<ffffffff8161897f>]
lock_sock_nested+0x4f/0xc0
[  412.724006] softirqs last disabled at (318170): [<ffffffff8139d79a>]
lock_buckets+0x3a/0x80
[  412.724006] CPU: 7 PID: 631 Comm: bind_netlink Tainted: G        W
 L 3.19.0-rc6+ #182
[  412.724006] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  412.724006] task: ffff880013970000 ti: ffff8800105d0000 task.ti:
ffff8800105d0000
[  412.724006] RIP: 0010:[<ffffffff8165d820>]  [<ffffffff8165d820>]
netlink_compare+0x10/0x30
[  412.724006] RSP: 0018:ffff8800105d3cf0  EFLAGS: 00000293
[  412.724006] RAX: 0000000000000000 RBX: 0000000000000003 RCX:
00000000dbaee169
[  412.724006] RDX: 0000000000001668 RSI: ffff8800105d3db8 RDI:
ffff88001651b800
[  412.724006] RBP: ffff8800105d3d48 R08: 00000000df2b8827 R09:
ffff880010c07468
[  412.724006] R10: 0000000000000003 R11: 0000000000000001 R12:
ffffffff817675e0
[  412.724006] R13: ffffffff810c2d18 R14: ffff8800105d3c58 R15:
0000000000000046
[  412.724006] FS:  0000000000000000(0000) GS:ffff880017dc0000(0063)
knlGS:00000000f75ae900
[  412.724006] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[  412.724006] CR2: 0000000008760000 CR3: 0000000015121000 CR4:
00000000000006e0
[  412.724006] Stack:
[  412.724006]  ffffffff8139de4e ffffffff8139ddc0 000000028105d9c8
07ca27d400000000
[  412.724006]  ffff8800152d13c0 ffff8800105d3d48 ffff880016500000
ffff8800152d13c0
[  412.724006]  0000000000000004 ffff8800152d13c0 ffff880010c07608
ffff8800105d3da8
[  412.724006] Call Trace:
[  412.724006]  [<ffffffff8139de4e>] ? rhashtable_lookup_compare+0x8e/0x120
[  412.724006]  [<ffffffff8139ddc0>] ? rhashtable_remove+0x200/0x200
[  412.724006]  [<ffffffff8139dfaf>]
rhashtable_lookup_compare_insert+0x9f/0x110
[  412.724006]  [<ffffffff8139df45>] ?
rhashtable_lookup_compare_insert+0x35/0x110
[  412.724006]  [<ffffffff8165d810>] ? netlink_overrun+0x50/0x50
[  412.724006]  [<ffffffff8165e0f3>] ? netlink_insert+0x43/0xf0
[  412.724006]  [<ffffffff8165e141>] netlink_insert+0x91/0xf0
[  412.724006]  [<ffffffff81660470>] netlink_bind+0x210/0x260
[  412.724006]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  412.724006]  [<ffffffff810a5b10>] ? lock_release_non_nested+0xa0/0x340
[  412.724006]  [<ffffffff81616d24>] SYSC_bind+0xa4/0xc0
[  412.724006]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  412.724006]  [<ffffffff8161701e>] SyS_bind+0xe/0x10
[  412.724006]  [<ffffffff81652318>] compat_SyS_socketcall+0xa8/0x200
[  412.724006]  [<ffffffff81768df3>] sysenter_dispatch+0x7/0x1f
[  412.724006]  [<ffffffff8139660e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  412.724006] Code: f0 ff 83 98 01 00 00 48 83 c4 08 5b 5d c3 66 66 66
66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 31 c0 8b 56 08 39 97 68 04
00 00 <55> 48 89 e5 74 0a 5d c3 0f 1f 84 00 00 00 00 00 48 8b 47 30 48
[  440.724005] NMI watchdog: BUG: soft lockup - CPU#7 stuck for 22s!
[bind_netlink:631]
[  440.724005] Modules linked in: tipc
[  440.724005] irq event stamp: 493025
[  440.724005] hardirqs last  enabled at (493024): [<ffffffff817675e0>]
restore_args+0x0/0x30
[  440.724005] hardirqs last disabled at (493025): [<ffffffff817678aa>]
apic_timer_interrupt+0x6a/0x80
[  440.724005] softirqs last  enabled at (318168): [<ffffffff8161897f>]
lock_sock_nested+0x4f/0xc0
[  440.724005] softirqs last disabled at (318170): [<ffffffff8139d79a>]
lock_buckets+0x3a/0x80
[  440.724005] CPU: 7 PID: 631 Comm: bind_netlink Tainted: G        W
 L 3.19.0-rc6+ #182
[  440.724005] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  440.724005] task: ffff880013970000 ti: ffff8800105d0000 task.ti:
ffff8800105d0000
[  440.724005] RIP: 0010:[<ffffffff8165d820>]  [<ffffffff8165d820>]
netlink_compare+0x10/0x30
[  440.724005] RSP: 0018:ffff8800105d3cf0  EFLAGS: 00000293
[  440.724005] RAX: 0000000000000000 RBX: ffffffff817675e0 RCX:
00000000dbaee169
[  440.724005] RDX: 0000000000001668 RSI: ffff8800105d3db8 RDI:
ffff88001651b800
[  440.724005] RBP: ffff8800105d3d48 R08: 00000000df2b8827 R09:
ffff880010c07468
[  440.724005] R10: 0000000000000003 R11: 0000000000000001 R12:
ffff8800105d3c68
[  440.724005] R13: 0000000000000046 R14: ffff8800105d0000 R15:
ffff880013970000
[  440.724005] FS:  0000000000000000(0000) GS:ffff880017dc0000(0063)
knlGS:00000000f75ae900
[  440.724005] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[  440.724005] CR2: 0000000008760000 CR3: 0000000015121000 CR4:
00000000000006e0
[  440.724005] Stack:
[  440.724005]  ffffffff8139de4e ffffffff8139ddc0 000000028105d9c8
07ca27d400000000
[  440.724005]  ffff8800152d13c0 ffff8800105d3d48 ffff880016500000
ffff8800152d13c0
[  440.724005]  0000000000000004 ffff8800152d13c0 ffff880010c07608
ffff8800105d3da8
[  440.724005] Call Trace:
[  440.724005]  [<ffffffff8139de4e>] ? rhashtable_lookup_compare+0x8e/0x120
[  440.724005]  [<ffffffff8139ddc0>] ? rhashtable_remove+0x200/0x200
[  440.724005]  [<ffffffff8139dfaf>]
rhashtable_lookup_compare_insert+0x9f/0x110
[  440.724005]  [<ffffffff8139df45>] ?
rhashtable_lookup_compare_insert+0x35/0x110
[  440.724005]  [<ffffffff8165d810>] ? netlink_overrun+0x50/0x50
[  440.724005]  [<ffffffff8165e0f3>] ? netlink_insert+0x43/0xf0
[  440.724005]  [<ffffffff8165e141>] netlink_insert+0x91/0xf0
[  440.724005]  [<ffffffff81660470>] netlink_bind+0x210/0x260
[  440.724005]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  440.724005]  [<ffffffff810a5b10>] ? lock_release_non_nested+0xa0/0x340
[  440.724005]  [<ffffffff81616d24>] SYSC_bind+0xa4/0xc0
[  440.724005]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  440.724005]  [<ffffffff8161701e>] SyS_bind+0xe/0x10
[  440.724005]  [<ffffffff81652318>] compat_SyS_socketcall+0xa8/0x200
[  440.724005]  [<ffffffff81768df3>] sysenter_dispatch+0x7/0x1f
[  440.724005]  [<ffffffff8139660e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  440.724005] Code: f0 ff 83 98 01 00 00 48 83 c4 08 5b 5d c3 66 66 66
66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 31 c0 8b 56 08 39 97 68 04
00 00 <55> 48 89 e5 74 0a 5d c3 0f 1f 84 00 00 00 00 00 48 8b 47 30 48
[  468.724005] NMI watchdog: BUG: soft lockup - CPU#7 stuck for 22s!
[bind_netlink:631]
[  468.724005] Modules linked in: tipc
[  468.724005] irq event stamp: 507013
[  468.724005] hardirqs last  enabled at (507012): [<ffffffff817675e0>]
restore_args+0x0/0x30
[  468.724005] hardirqs last disabled at (507013): [<ffffffff817678aa>]
apic_timer_interrupt+0x6a/0x80
[  468.724005] softirqs last  enabled at (318168): [<ffffffff8161897f>]
lock_sock_nested+0x4f/0xc0
[  468.724005] softirqs last disabled at (318170): [<ffffffff8139d79a>]
lock_buckets+0x3a/0x80
[  468.724005] CPU: 7 PID: 631 Comm: bind_netlink Tainted: G        W
 L 3.19.0-rc6+ #182
[  468.724005] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  468.724005] task: ffff880013970000 ti: ffff8800105d0000 task.ti:
ffff8800105d0000
[  468.724005] RIP: 0010:[<ffffffff8165d820>]  [<ffffffff8165d820>]
netlink_compare+0x10/0x30
[  468.724005] RSP: 0018:ffff8800105d3cf0  EFLAGS: 00000293
[  468.724005] RAX: 0000000000000000 RBX: ffffffff817675e0 RCX:
00000000dbaee169
[  468.724005] RDX: 0000000000001668 RSI: ffff8800105d3db8 RDI:
ffff88001651b800
[  468.724005] RBP: ffff8800105d3d48 R08: 00000000df2b8827 R09:
ffff880010c07468
[  468.724005] R10: 0000000000000003 R11: 0000000000000001 R12:
ffff8800105d3c68
[  468.724005] R13: 0000000000000046 R14: ffff8800105d0000 R15:
ffff880013970000
[  468.724005] FS:  0000000000000000(0000) GS:ffff880017dc0000(0063)
knlGS:00000000f75ae900
[  468.724005] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[  468.724005] CR2: 0000000008760000 CR3: 0000000015121000 CR4:
00000000000006e0
[  468.724005] Stack:
[  468.724005]  ffffffff8139de4e ffffffff8139ddc0 000000028105d9c8
07ca27d400000000
[  468.724005]  ffff8800152d13c0 ffff8800105d3d48 ffff880016500000
ffff8800152d13c0
[  468.724005]  0000000000000004 ffff8800152d13c0 ffff880010c07608
ffff8800105d3da8
[  468.724005] Call Trace:
[  468.724005]  [<ffffffff8139de4e>] ? rhashtable_lookup_compare+0x8e/0x120
[  468.724005]  [<ffffffff8139ddc0>] ? rhashtable_remove+0x200/0x200
[  468.724005]  [<ffffffff8139dfaf>]
rhashtable_lookup_compare_insert+0x9f/0x110
[  468.724005]  [<ffffffff8139df45>] ?
rhashtable_lookup_compare_insert+0x35/0x110
[  468.724005]  [<ffffffff8165d810>] ? netlink_overrun+0x50/0x50
[  468.724005]  [<ffffffff8165e0f3>] ? netlink_insert+0x43/0xf0
[  468.724005]  [<ffffffff8165e141>] netlink_insert+0x91/0xf0
[  468.724005]  [<ffffffff81660470>] netlink_bind+0x210/0x260
[  468.724005]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  468.724005]  [<ffffffff810a5b10>] ? lock_release_non_nested+0xa0/0x340
[  468.724005]  [<ffffffff81616d24>] SYSC_bind+0xa4/0xc0
[  468.724005]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  468.724005]  [<ffffffff8161701e>] SyS_bind+0xe/0x10
[  468.724005]  [<ffffffff81652318>] compat_SyS_socketcall+0xa8/0x200
[  468.724005]  [<ffffffff81768df3>] sysenter_dispatch+0x7/0x1f
[  468.724005]  [<ffffffff8139660e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  468.724005] Code: f0 ff 83 98 01 00 00 48 83 c4 08 5b 5d c3 66 66 66
66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 31 c0 8b 56 08 39 97 68 04
00 00 <55> 48 89 e5 74 0a 5d c3 0f 1f 84 00 00 00 00 00 48 8b 47 30 48

Regards,
Ying

On 01/30/2015 08:20 AM, Thomas Graf wrote:
> This is a series of fixes which have accumulated while tracking
> down the race condition reoprted by Ying Xue. The original
> DEBUG_PAGEALLOC splat is resolved.
> 
> However, there is still a race (harder to trigger) remaining in
> which certain entries are unfindable when removing them from the
> table via netlink_remove() and thus they cause a use after free
> later on.
> 
> Regardless, these fixes can go in now.
> 
> Thomas Graf (6):
>   rhashtable: key_hashfn() must return full hash value
>   rhashtable: Use a single bucket lock for sibling buckets
>   rhashtable: Wait for RCU readers after final unzip work
>   rhashtable: Dump bucket tables on locking violation under
>     PROVE_LOCKING
>   rhashtable: Add more lock verification
>   rhashtable: Avoid bucket cross reference after removal
> 
>  lib/rhashtable.c | 301 ++++++++++++++++++++++++++++++-------------------------
>  1 file changed, 166 insertions(+), 135 deletions(-)
> 
