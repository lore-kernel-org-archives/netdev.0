From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH 0/6 v2 net-next] rhashtable fixes
Date: Thu, 5 Feb 2015 10:32:54 +0800
Message-ID: <54D2D656.8060709@windriver.com>
References: <cover.1423097592.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <herbert@gondor.apana.org.au>
To: Thomas Graf <tgraf@suug.ch>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:44982 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751360AbbBECde (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 21:33:34 -0500
In-Reply-To: <cover.1423097592.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas,

After I applied the sires, it sounds like panic doesn't occur any more. But soft
lockup still happens although the frequency of its reproduction is much lower
than before. Please take a look at its relevant log:

root@localhost:/mnt# ./bind2 10000
Create 10000 ports
^[[A[   83.760030] ------------[ cut here ]------------
[   83.760428] WARNING: CPU: 6 PID: 0 at net/sched/sch_generic.c:303
dev_watchdog+0x247/0x250()
[   83.760944] NETDEV WATCHDOG: eth0 (e1000): transmit queue 0 timed out
[   83.761357] Modules linked in: tipc
[   83.761607] CPU: 6 PID: 0 Comm: swapper/6 Not tainted 3.19.0-rc6+ #185
[   83.762025] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[   83.762385]  000000000000012f ffff880017d83d08 ffffffff8175d285 000000000000104b
[   83.762884]  ffff880017d83d58 ffff880017d83d48 ffffffff81059717 ffffffff00000000
[   83.763384]  ffff880015e92000 ffff880015e923e0 ffff88000008ae00 0000000000000001
[   83.763883] Call Trace:
[   83.764018]  <IRQ>  [<ffffffff8175d285>] dump_stack+0x4c/0x65
[   83.764018]  [<ffffffff81059717>] warn_slowpath_common+0x97/0xe0
[   83.764018]  [<ffffffff81059816>] warn_slowpath_fmt+0x46/0x50
[   83.764018]  [<ffffffff81654617>] dev_watchdog+0x247/0x250
[   83.764018]  [<ffffffff816543d0>] ? pfifo_fast_dequeue+0xe0/0xe0
[   83.764018]  [<ffffffff816543d0>] ? pfifo_fast_dequeue+0xe0/0xe0
[   83.764018]  [<ffffffff810c5ebc>] call_timer_fn+0x8c/0x1e0
[   83.764018]  [<ffffffff810c5e35>] ? call_timer_fn+0x5/0x1e0
[   83.764018]  [<ffffffff817669d0>] ? _raw_spin_unlock_irq+0x30/0x40
[   83.764018]  [<ffffffff816543d0>] ? pfifo_fast_dequeue+0xe0/0xe0
[   83.764018]  [<ffffffff810c7994>] run_timer_softirq+0x2d4/0x320
[   83.764018]  [<ffffffff810d6214>] ? clockevents_program_event+0x74/0x100
[   83.764018]  [<ffffffff8105d653>] __do_softirq+0x123/0x360
[   83.764018]  [<ffffffff8105db2e>] irq_exit+0x8e/0xb0
[   83.764018]  [<ffffffff81769b2a>] smp_apic_timer_interrupt+0x4a/0x60
[   83.764018]  [<ffffffff81767eaf>] apic_timer_interrupt+0x6f/0x80
[   83.764018]  <EOI>  [<ffffffff8100d174>] ? default_idle+0x24/0x100
[   83.764018]  [<ffffffff8100d172>] ? default_idle+0x22/0x100
[   83.764018]  [<ffffffff8100daaf>] arch_cpu_idle+0xf/0x20
[   83.764018]  [<ffffffff8109a509>] cpu_startup_entry+0x2c9/0x3c0
[   83.764018]  [<ffffffff810d5ea2>] ? clockevents_register_device+0xe2/0x140
[   83.764018]  [<ffffffff810333c1>] start_secondary+0x141/0x150
[   83.764018] ---[ end trace 57f25794303fa7e9 ]---
[   83.776059] e1000 0000:00:03.0 eth0: Reset adapter
[   88.088005] NMI watchdog: BUG: soft lockup - CPU#0 stuck for 23s! [bind2:667]
[   88.088005] Modules linked in: tipc
[   88.088005] irq event stamp: 25367
[   88.088005] hardirqs last  enabled at (25366): [<ffffffff81767be0>]
restore_args+0x0/0x30
[   88.088005] hardirqs last disabled at (25367): [<ffffffff81767eaa>]
apic_timer_interrupt+0x6a/0x80
[   88.088005] softirqs last  enabled at (11842): [<ffffffff8139d66a>]
unlock_buckets+0x5a/0x70
[   88.088005] softirqs last disabled at (11880): [<ffffffff8139d51a>]
lock_buckets+0x3a/0x80
[   88.088005] CPU: 0 PID: 667 Comm: bind2 Tainted: G        W      3.19.0-rc6+ #185
[   88.088005] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[   88.088005] task: ffff880015038000 ti: ffff880000198000 task.ti: ffff880000198000
[   88.088005] RIP: 0010:[<ffffffff81390b6a>]  [<ffffffff81390b6a>] memcmp+0x3a/0x50
[   88.088005] RSP: 0018:ffff88000019bcf8  EFLAGS: 00000212
[   88.088005] RAX: 00000000000000a8 RBX: ffff880000198000 RCX: 000000000000002b
[   88.088005] RDX: 0000000000000004 RSI: ffff8800153dd87c RDI: ffff88000019747c
[   88.088005] RBP: ffff88000019bcf8 R08: 000000002d196482 R09: ffff8800153dd87c
[   88.088005] R10: 0000000000000002 R11: 0000000000000001 R12: 0000000000000000
[   88.088005] R13: 0000000000000001 R14: 0000000000000000 R15: 0000000000000000
[   88.088005] FS:  0000000000000000(0000) GS:ffff880017c00000(0063)
knlGS:00000000f75b3900
[   88.088005] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[   88.088005] CR2: 0000000008acec4c CR3: 000000001479e000 CR4: 00000000000006f0
[   88.088005] Stack:
[   88.088005]  ffff88000019bd08 ffffffff8139d698 ffff88000019bd68 ffffffff8139e5ce
[   88.088005]  ffffffff8139e540 00000002810a6a25 069b23b200000000 ffff88001328e000
[   88.088005]  ffff88000019bd68 ffff880000149090 ffff88001328e000 00000000000001b2
[   88.088005] Call Trace:
[   88.088005]  [<ffffffff8139d698>] rhashtable_compare+0x18/0x20
[   88.088005]  [<ffffffff8139e5ce>] rhashtable_lookup_compare+0x8e/0x120
[   88.088005]  [<ffffffff8139e540>] ? rht_deferred_worker+0xa0/0xa0
[   88.088005]  [<ffffffff8139e72f>] rhashtable_lookup_compare_insert+0x9f/0x110
[   88.088005]  [<ffffffff8139e6c5>] ? rhashtable_lookup_compare_insert+0x35/0x110
[   88.088005]  [<ffffffff8139d680>] ? unlock_buckets+0x70/0x70
[   88.088005]  [<ffffffff8139e7d2>] rhashtable_lookup_insert+0x32/0x40
[   88.088005]  [<ffffffffa00164ec>] tipc_sk_create+0x1ec/0x340 [tipc]
[   88.088005]  [<ffffffffa00163a2>] ? tipc_sk_create+0xa2/0x340 [tipc]
[   88.088005]  [<ffffffff81615e60>] __sock_create+0x170/0x270
[   88.088005]  [<ffffffff81615daf>] ? __sock_create+0xbf/0x270
[   88.088005]  [<ffffffff81615fc0>] sock_create+0x30/0x40
[   88.088005]  [<ffffffff81616d36>] SyS_socket+0x36/0xb0
[   88.088005]  [<ffffffff8118500f>] ? might_fault+0xaf/0xc0
[   88.088005]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[   88.088005]  [<ffffffff816523bb>] compat_SyS_socketcall+0x6b/0x200
[   88.088005]  [<ffffffff817693f3>] sysenter_dispatch+0x7/0x1f
[   88.088005]  [<ffffffff8139660e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[   88.088005] Code: b6 0e 29 c8 75 25 48 83 ea 01 31 c9 eb 18 0f 1f 00 44 0f b6
4c 0f 01 44 0f b6 44 0e 01 48 83 c1 01 45 29 c1 75 0b 48 39 d1 75 e6 <5d> c3 0f
1f 40 00 44 89 c8 5d c3 66 66 2e 0f 1f 84 00 00 00 00
[  116.088006] NMI watchdog: BUG: soft lockup - CPU#0 stuck for 23s! [bind2:667]
[  116.088006] Modules linked in: tipc
[  116.088006] irq event stamp: 39357
[  116.088006] hardirqs last  enabled at (39356): [<ffffffff81767be0>]
restore_args+0x0/0x30
[  116.088006] hardirqs last disabled at (39357): [<ffffffff81767eaa>]
apic_timer_interrupt+0x6a/0x80
[  116.088006] softirqs last  enabled at (11842): [<ffffffff8139d66a>]
unlock_buckets+0x5a/0x70
[  116.088006] softirqs last disabled at (11880): [<ffffffff8139d51a>]
lock_buckets+0x3a/0x80
[  116.088006] CPU: 0 PID: 667 Comm: bind2 Tainted: G        W    L 3.19.0-rc6+ #185
[  116.088006] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  116.088006] task: ffff880015038000 ti: ffff880000198000 task.ti: ffff880000198000
[  116.088006] RIP: 0010:[<ffffffff81390b3e>]  [<ffffffff81390b3e>] memcmp+0xe/0x50
[  116.088006] RSP: 0018:ffff88000019bcf8  EFLAGS: 00000202
[  116.088006] RAX: 00000000000000d3 RBX: ffffffff81767be0 RCX: 000000000000002b
[  116.088006] RDX: 0000000000000004 RSI: ffff8800153dd87c RDI: ffff88000019747c
[  116.088006] RBP: ffff88000019bcf8 R08: 000000002d196482 R09: ffff8800153dd87c
[  116.088006] R10: 0000000000000002 R11: 0000000000000001 R12: ffff88000019bc68
[  116.088006] R13: 0000000000000046 R14: ffff880000198000 R15: ffff880015038000
[  116.088006] FS:  0000000000000000(0000) GS:ffff880017c00000(0063)
knlGS:00000000f75b3900
[  116.088006] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[  116.088006] CR2: 0000000008acec4c CR3: 000000001479e000 CR4: 00000000000006f0
[  116.088006] Stack:
[  116.088006]  ffff88000019bd08 ffffffff8139d698 ffff88000019bd68 ffffffff8139e5ce
[  116.088006]  ffffffff8139e540 00000002810a6a25 069b23b200000000 ffff88001328e000
[  116.088006]  ffff88000019bd68 ffff880000149090 ffff88001328e000 00000000000001b2
[  116.088006] Call Trace:
[  116.088006]  [<ffffffff8139d698>] rhashtable_compare+0x18/0x20
[  116.088006]  [<ffffffff8139e5ce>] rhashtable_lookup_compare+0x8e/0x120
[  116.088006]  [<ffffffff8139e540>] ? rht_deferred_worker+0xa0/0xa0
[  116.088006]  [<ffffffff8139e72f>] rhashtable_lookup_compare_insert+0x9f/0x110
[  116.088006]  [<ffffffff8139e6c5>] ? rhashtable_lookup_compare_insert+0x35/0x110
[  116.088006]  [<ffffffff8139d680>] ? unlock_buckets+0x70/0x70
[  116.088006]  [<ffffffff8139e7d2>] rhashtable_lookup_insert+0x32/0x40
[  116.088006]  [<ffffffffa00164ec>] tipc_sk_create+0x1ec/0x340 [tipc]
[  116.088006]  [<ffffffffa00163a2>] ? tipc_sk_create+0xa2/0x340 [tipc]
[  116.088006]  [<ffffffff81615e60>] __sock_create+0x170/0x270
[  116.088006]  [<ffffffff81615daf>] ? __sock_create+0xbf/0x270
[  116.088006]  [<ffffffff81615fc0>] sock_create+0x30/0x40
[  116.088006]  [<ffffffff81616d36>] SyS_socket+0x36/0xb0
[  116.088006]  [<ffffffff8118500f>] ? might_fault+0xaf/0xc0
[  116.088006]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  116.088006]  [<ffffffff816523bb>] compat_SyS_socketcall+0x6b/0x200
[  116.088006]  [<ffffffff817693f3>] sysenter_dispatch+0x7/0x1f
[  116.088006]  [<ffffffff8139660e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  116.088006] Code: 06 01 5d c3 66 0f 1f 84 00 00 00 00 00 31 c0 c6 06 00 5d c3
66 0f 1f 84 00 00 00 00 00 55 31 c0 48 85 d2 48 89 e5 74 2f 0f b6 07 <0f> b6 0e
29 c8 75 25 48 83 ea 01 31 c9 eb 18 0f 1f 00 44 0f b6
[  121.200005] INFO: rcu_sched self-detected stall on CPU { 0}  (t=15000 jiffies
g=915 c=914 q=1273)
[  121.200005] Task dump for CPU 0:
[  121.200005] bind2           R  running task        0   667    614 0x20020008
[  121.200005]  0000000000000266 ffff880017c03d68 ffffffff81086c26 ffffffff81086b88
[  121.200005]  00000000bd07bd06 0000000000000000 ffffffff81c53940 ffff880017c03d88
[  121.200005]  ffffffff8108a57f ffffffff81c53940 ffffffff81c53940 ffff880017c03db8
[  121.200005] Call Trace:
[  121.200005]  <IRQ>  [<ffffffff81086c26>] sched_show_task+0x106/0x170
[  121.200005]  [<ffffffff81086b88>] ? sched_show_task+0x68/0x170
[  121.200005]  [<ffffffff8108a57f>] dump_cpu_task+0x3f/0x50
[  121.200005]  [<ffffffff810bfa7b>] rcu_dump_cpu_stacks+0x8b/0xc0
[  121.200005]  [<ffffffff810c33d0>] rcu_check_callbacks+0x480/0x6d0
[  121.200005]  [<ffffffff810a133d>] ? trace_hardirqs_off+0xd/0x10
[  121.200005]  [<ffffffff810c8408>] update_process_times+0x38/0x70
[  121.200005]  [<ffffffff810d8623>] tick_sched_handle.isra.15+0x33/0x70
[  121.200005]  [<ffffffff810d88cb>] tick_sched_timer+0x4b/0x80
[  121.200005]  [<ffffffff810c8d8b>] __run_hrtimer+0x9b/0x290
[  121.200005]  [<ffffffff810d8880>] ? tick_sched_do_timer+0x40/0x40
[  121.200005]  [<ffffffff810c95e4>] ? hrtimer_interrupt+0x74/0x260
[  121.200005]  [<ffffffff810c9677>] hrtimer_interrupt+0x107/0x260
[  121.200005]  [<ffffffff8139d680>] ? unlock_buckets+0x70/0x70
[  121.200005]  [<ffffffff81034cb9>] local_apic_timer_interrupt+0x39/0x60
[  121.200005]  [<ffffffff81769b25>] smp_apic_timer_interrupt+0x45/0x60
[  121.200005]  [<ffffffff81767eaf>] apic_timer_interrupt+0x6f/0x80
[  121.200005]  <EOI>  [<ffffffff8139e5c8>] ? rhashtable_lookup_compare+0x88/0x120
[  121.200005]  [<ffffffff8139e5ce>] ? rhashtable_lookup_compare+0x8e/0x120
[  121.200005]  [<ffffffff8139e540>] ? rht_deferred_worker+0xa0/0xa0
[  121.200005]  [<ffffffff8139e72f>] rhashtable_lookup_compare_insert+0x9f/0x110
[  121.200005]  [<ffffffff8139e6c5>] ? rhashtable_lookup_compare_insert+0x35/0x110
[  121.200005]  [<ffffffff8139d680>] ? unlock_buckets+0x70/0x70
[  121.200005]  [<ffffffff8139e7d2>] rhashtable_lookup_insert+0x32/0x40
[  121.200005]  [<ffffffffa00164ec>] tipc_sk_create+0x1ec/0x340 [tipc]
[  121.200005]  [<ffffffffa00163a2>] ? tipc_sk_create+0xa2/0x340 [tipc]
[  121.200005]  [<ffffffff81615e60>] __sock_create+0x170/0x270
[  121.200005]  [<ffffffff81615daf>] ? __sock_create+0xbf/0x270
[  121.200005]  [<ffffffff81615fc0>] sock_create+0x30/0x40
[  121.200005]  [<ffffffff81616d36>] SyS_socket+0x36/0xb0
[  121.200005]  [<ffffffff8118500f>] ? might_fault+0xaf/0xc0
[  121.200005]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  121.200005]  [<ffffffff816523bb>] compat_SyS_socketcall+0x6b/0x200
[  121.200005]  [<ffffffff817693f3>] sysenter_dispatch+0x7/0x1f
[  121.200005]  [<ffffffff8139660e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  121.220016] INFO: rcu_sched detected stalls on CPUs/tasks: { 0} (detected by
5, t=15006 jiffies, g=915, c=914, q=1273)
[  121.223334] Task dump for CPU 0:
[  121.223334] bind2           R  running task        0   667    614 0x20020008
[  121.223334]  000000000000002b 0000000000000004 ffff8800153dd87c ffff88000019747c
[  121.223334]  ffffffffffffff10 ffffffff81390b6a ffff8800153dd87c ffff880000197000
[  121.228029]  ffffffffffffff10 ffffffff8139e5c8 0000000000000010 ffff88000019bd08
[  121.228029] Call Trace:
[  121.228029]  [<ffffffff8139e5c8>] ? rhashtable_lookup_compare+0x88/0x120
[  121.228029]  [<ffffffff8139d698>] ? rhashtable_compare+0x18/0x20
[  121.228029]  [<ffffffff8139e5ce>] ? rhashtable_lookup_compare+0x8e/0x120
[  121.228029]  [<ffffffff8139e540>] ? rht_deferred_worker+0xa0/0xa0
[  121.228029]  [<ffffffff8139e72f>] ? rhashtable_lookup_compare_insert+0x9f/0x110
[  121.228029]  [<ffffffff8139e6c5>] ? rhashtable_lookup_compare_insert+0x35/0x110
[  121.228029]  [<ffffffff8139d680>] ? unlock_buckets+0x70/0x70
[  121.236021]  [<ffffffff8139e7d2>] ? rhashtable_lookup_insert+0x32/0x40
[  121.236021]  [<ffffffffa00164ec>] ? tipc_sk_create+0x1ec/0x340 [tipc]
[  121.236021]  [<ffffffffa00163a2>] ? tipc_sk_create+0xa2/0x340 [tipc]
[  121.236021]  [<ffffffff81615e60>] ? __sock_create+0x170/0x270
[  121.236021]  [<ffffffff81615daf>] ? __sock_create+0xbf/0x270
[  121.236021]  [<ffffffff81615fc0>] ? sock_create+0x30/0x40
[  121.236021]  [<ffffffff81616d36>] ? SyS_socket+0x36/0xb0
[  121.236021]  [<ffffffff8118500f>] ? might_fault+0xaf/0xc0
[  121.236021]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  121.244025]  [<ffffffff816523bb>] ? compat_SyS_socketcall+0x6b/0x200
[  121.244025]  [<ffffffff817693f3>] ? sysenter_dispatch+0x7/0x1f
[  121.244025]  [<ffffffff8139660e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  148.088005] NMI watchdog: BUG: soft lockup - CPU#0 stuck for 22s! [bind2:667]
[  148.088005] Modules linked in: tipc
[  148.088005] irq event stamp: 55335
[  148.088005] hardirqs last  enabled at (55334): [<ffffffff81767be0>]
restore_args+0x0/0x30
[  148.088005] hardirqs last disabled at (55335): [<ffffffff81767eaa>]
apic_timer_interrupt+0x6a/0x80
[  148.088005] softirqs last  enabled at (11842): [<ffffffff8139d66a>]
unlock_buckets+0x5a/0x70
[  148.088005] softirqs last disabled at (11880): [<ffffffff8139d51a>]
lock_buckets+0x3a/0x80
[  148.088005] CPU: 0 PID: 667 Comm: bind2 Tainted: G        W    L 3.19.0-rc6+ #185
[  148.088005] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  148.088005] task: ffff880015038000 ti: ffff880000198000 task.ti: ffff880000198000
[  148.088005] RIP: 0010:[<ffffffff81390b31>]  [<ffffffff81390b31>] memcmp+0x1/0x50
[  148.088005] RSP: 0018:ffff88000019bcf8  EFLAGS: 00000282
[  148.088005] RAX: ffff880000149090 RBX: ffff88000019bc78 RCX: 000000000000002b
[  148.088005] RDX: 0000000000000004 RSI: ffff8800153dd87c RDI: ffff88000019747c
[  148.088005] RBP: ffff88000019bd08 R08: 000000002d196482 R09: ffff8800153dd87c
[  148.088005] R10: 0000000000000002 R11: 0000000000000001 R12: ffff880000198000
[  148.088005] R13: ffff880015038000 R14: 0000000000000000 R15: 0000000000000001
[  148.088005] FS:  0000000000000000(0000) GS:ffff880017c00000(0063)
knlGS:00000000f75b3900
[  148.088005] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[  148.088005] CR2: 0000000008acec4c CR3: 000000001479e000 CR4: 00000000000006f0
[  148.088005] Stack:
[  148.088005]  ffff88000019bd08 ffffffff8139d698 ffff88000019bd68 ffffffff8139e5ce
[  148.088005]  ffffffff8139e540 00000002810a6a25 069b23b200000000 ffff88001328e000
[  148.088005]  ffff88000019bd68 ffff880000149090 ffff88001328e000 00000000000001b2
[  148.088005] Call Trace:
[  148.088005]  [<ffffffff8139d698>] ? rhashtable_compare+0x18/0x20
[  148.088005]  [<ffffffff8139e5ce>] rhashtable_lookup_compare+0x8e/0x120
[  148.088005]  [<ffffffff8139e540>] ? rht_deferred_worker+0xa0/0xa0
[  148.088005]  [<ffffffff8139e72f>] rhashtable_lookup_compare_insert+0x9f/0x110
[  148.088005]  [<ffffffff8139e6c5>] ? rhashtable_lookup_compare_insert+0x35/0x110
[  148.088005]  [<ffffffff8139d680>] ? unlock_buckets+0x70/0x70
[  148.088005]  [<ffffffff8139e7d2>] rhashtable_lookup_insert+0x32/0x40
[  148.088005]  [<ffffffffa00164ec>] tipc_sk_create+0x1ec/0x340 [tipc]
[  148.088005]  [<ffffffffa00163a2>] ? tipc_sk_create+0xa2/0x340 [tipc]
[  148.088005]  [<ffffffff81615e60>] __sock_create+0x170/0x270
[  148.088005]  [<ffffffff81615daf>] ? __sock_create+0xbf/0x270
[  148.088005]  [<ffffffff81615fc0>] sock_create+0x30/0x40
[  148.088005]  [<ffffffff81616d36>] SyS_socket+0x36/0xb0
[  148.088005]  [<ffffffff8118500f>] ? might_fault+0xaf/0xc0
[  148.088005]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  148.088005]  [<ffffffff816523bb>] compat_SyS_socketcall+0x6b/0x200
[  148.088005]  [<ffffffff817693f3>] sysenter_dispatch+0x7/0x1f
[  148.088005]  [<ffffffff8139660e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  148.088005] Code: 00 00 3c 30 74 14 3c 31 75 e9 31 c0 c6 06 01 5d c3 66 0f 1f
84 00 00 00 00 00 31 c0 c6 06 00 5d c3 66 0f 1f 84 00 00 00 00 00 55 <31> c0 48
85 d2 48 89 e5 74 2f 0f b6 07 0f b6 0e 29 c8 75 25 48

Regards,
Ying

On 02/05/2015 09:03 AM, Thomas Graf wrote:
> This series fixes all remaining known issues with rhashtable that
> have been reported. In particular the race condition reported by
> Ying Xue.
> 
> ---
> Dave/Herbert: I'm posting this now as it fixes real issues. I'm
> fine with taking Herbert's rehash patches instead if they resolve
> all the reported issues as well.
> 
> v2:
>  - Rebased on top of Herbert Xu's iterator code
>  - Fixed last remaining race that remained. Special thanks
>    to Daniel Borkmann for assistance while debugging.
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
>  lib/rhashtable.c | 305 ++++++++++++++++++++++++++++++-------------------------
>  1 file changed, 167 insertions(+), 138 deletions(-)
> 
> 
