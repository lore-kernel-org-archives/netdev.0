From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH 0/6 v2 net-next] rhashtable fixes
Date: Thu, 5 Feb 2015 17:14:22 +0800
Message-ID: <54D3346E.4040302@windriver.com>
References: <cover.1423097592.git.tgraf@suug.ch> <54D2D656.8060709@windriver.com> <20150205084737.GA15549@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<herbert@gondor.apana.org.au>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:42244 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752672AbbBEJO6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 04:14:58 -0500
In-Reply-To: <20150205084737.GA15549@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/05/2015 04:47 PM, Thomas Graf wrote:
> On 02/05/15 at 10:32am, Ying Xue wrote:
>> After I applied the sires, it sounds like panic doesn't occur any more. But soft
>> lockup still happens although the frequency of its reproduction is much lower
>> than before. Please take a look at its relevant log:
> 
> Thanks for testing and the report. I had run your bind_netlink test
> overnight on a 4 CPU VM. Anything particular that might help trigger it?
> 
> 

My hardware platform seems a bit advanced than you, for example, I run the test
case on a 8 CPU VM.

Additionally, I guess the port number you gave the bind_netlink application is a
little small, for instance, my given port number is 9000. Below is my complete
procedures about how to reproduce the soft lockup issue in my environment:

root@localhost:/mnt# gcc -Wall -o bind-netlink bind_netlink.c
root@localhost:/mnt# ulimit -n 100000
root@localhost:/mnt# ./bind-netlink 9000
Create 9000 ports
Created 1000 ports
Created 2000 ports
Created 3000 ports
Created 4000 ports
Created 5000 ports
Created 6000 ports
Created 7000 ports
Created 8000 ports
Created 9000 ports
Ports successfully created, terminating
root@localhost:/mnt# ./bind-netlink 9000
Create 9000 ports
Created 1000 ports
Created 2000 ports
Created 3000 ports
Created 4000 ports
Created 5000 ports
Created 6000 ports
Created 7000 ports
Created 8000 ports
Created 9000 ports
Ports successfully created, terminating
root@localhost:/mnt# ./bind-netlink 9000
Create 9000 ports
[  442.800079] ------------[ cut here ]------------
[  442.800456] WARNING: CPU: 2 PID: 0 at net/sched/sch_generic.c:303
dev_watchdog+0x247/0x250()
[  442.801002] NETDEV WATCHDOG: eth0 (e1000): transmit queue 0 timed out
[  442.801419] Modules linked in: tipc
[  442.801671] CPU: 2 PID: 0 Comm: swapper/2 Not tainted 3.19.0-rc6+ #185
[  442.802091] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  442.802460]  000000000000012f ffff880017c83d08 ffffffff8175d285 000000000000104e
[  442.802969]  ffff880017c83d58 ffff880017c83d48 ffffffff81059717 ffffffff00000000
[  442.803482]  ffff880015eb2000 ffff880015eb23e0 ffff88000008ae00 0000000000000001
[  442.803981] Call Trace:
[  442.804067]  <IRQ>  [<ffffffff8175d285>] dump_stack+0x4c/0x65
[  442.804067]  [<ffffffff81059717>] warn_slowpath_common+0x97/0xe0
[  442.804067]  [<ffffffff81059816>] warn_slowpath_fmt+0x46/0x50
[  442.804067]  [<ffffffff81654617>] dev_watchdog+0x247/0x250
[  442.804067]  [<ffffffff816543d0>] ? pfifo_fast_dequeue+0xe0/0xe0
[  442.804067]  [<ffffffff816543d0>] ? pfifo_fast_dequeue+0xe0/0xe0
[  442.804067]  [<ffffffff810c5ebc>] call_timer_fn+0x8c/0x1e0
[  442.804067]  [<ffffffff810c5e35>] ? call_timer_fn+0x5/0x1e0
[  442.804067]  [<ffffffff817669d0>] ? _raw_spin_unlock_irq+0x30/0x40
[  442.804067]  [<ffffffff816543d0>] ? pfifo_fast_dequeue+0xe0/0xe0
[  442.804067]  [<ffffffff810c7994>] run_timer_softirq+0x2d4/0x320
[  442.804067]  [<ffffffff810d6214>] ? clockevents_program_event+0x74/0x100
[  442.804067]  [<ffffffff8105d653>] __do_softirq+0x123/0x360
[  442.804067]  [<ffffffff8105db2e>] irq_exit+0x8e/0xb0
[  442.804067]  [<ffffffff81769b2a>] smp_apic_timer_interrupt+0x4a/0x60
[  442.804067]  [<ffffffff81767eaf>] apic_timer_interrupt+0x6f/0x80
[  442.804067]  <EOI>  [<ffffffff8100d174>] ? default_idle+0x24/0x100
[  442.804067]  [<ffffffff8100d172>] ? default_idle+0x22/0x100
[  442.804067]  [<ffffffff8100daaf>] arch_cpu_idle+0xf/0x20
[  442.804067]  [<ffffffff8109a509>] cpu_startup_entry+0x2c9/0x3c0
[  442.804067]  [<ffffffff810d5ea2>] ? clockevents_register_device+0xe2/0x140
[  442.804067]  [<ffffffff810333c1>] start_secondary+0x141/0x150
[  442.804067] ---[ end trace 839863d69c70be7a ]---
[  442.804067] e1000 0000:00:03.0 eth0: Reset adapter
[  452.716005] NMI watchdog: BUG: soft lockup - CPU#7 stuck for 22s!
[bind-netlink:641]
[  452.716005] Modules linked in: tipc
[  452.716005] irq event stamp: 16417
[  452.716005] hardirqs last  enabled at (16416): [<ffffffff81767be0>]
restore_args+0x0/0x30
[  452.716005] hardirqs last disabled at (16417): [<ffffffff81767eaa>]
apic_timer_interrupt+0x6a/0x80
[  452.716005] softirqs last  enabled at (4280): [<ffffffff8161893f>]
lock_sock_nested+0x4f/0xc0
[  452.716005] softirqs last disabled at (4282): [<ffffffff8139d51a>]
lock_buckets+0x3a/0x80
[  452.716005] CPU: 7 PID: 641 Comm: bind-netlink Tainted: G        W
3.19.0-rc6+ #185
[  452.716005] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  452.716005] task: ffff880013f4c220 ti: ffff880014558000 task.ti: ffff880014558000
[  452.716005] RIP: 0010:[<ffffffff8165d900>]  [<ffffffff8165d900>]
netlink_compare+0x10/0x30
[  452.716005] RSP: 0018:ffff88001455bcf0  EFLAGS: 00000293
[  452.716005] RAX: 0000000000000000 RBX: 0000000000000004 RCX: 000000000bfbcdfb
[  452.716005] RDX: 00000000000002ae RSI: ffff88001455bdb8 RDI: ffff88001651b800
[  452.716005] RBP: ffff88001455bd48 R08: 00000000bef85eb8 R09: ffff880011bf1c68
[  452.716005] R10: 0000000000000004 R11: 0000000000000001 R12: ffffffff81767be0
[  452.716005] R13: ffffffff810c2d18 R14: ffff88001455bc58 R15: 0000000000000046
[  452.716005] FS:  0000000000000000(0000) GS:ffff880017dc0000(0063)
knlGS:00000000f753e900
[  452.716005] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[  452.716005] CR2: 00000000f75f8b30 CR3: 0000000015abd000 CR4: 00000000000006e0
[  452.716005] Stack:
[  452.716005]  ffffffff8139e5ce ffffffff8139e540 000000028105d9c8 00c662f713caac00
[  452.716005]  ffff880013d15200 ffff88001455bd48 ffff880016500000 ffff880013caac00
[  452.716005]  0000000000000007 ffff880013d15200 ffff880011bf1e08 ffff88001455bda8
[  452.716005] Call Trace:
[  452.716005]  [<ffffffff8139e5ce>] ? rhashtable_lookup_compare+0x8e/0x120
[  452.716005]  [<ffffffff8139e540>] ? rht_deferred_worker+0xa0/0xa0
[  452.716005]  [<ffffffff8139e72f>] rhashtable_lookup_compare_insert+0x9f/0x110
[  452.716005]  [<ffffffff8139e6c5>] ? rhashtable_lookup_compare_insert+0x35/0x110
[  452.716005]  [<ffffffff8165d8f0>] ? netlink_overrun+0x50/0x50
[  452.716005]  [<ffffffff8165e1d3>] ? netlink_insert+0x43/0xf0
[  452.716005]  [<ffffffff8165e221>] netlink_insert+0x91/0xf0
[  452.716005]  [<ffffffff81660550>] netlink_bind+0x210/0x260
[  452.716005]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  452.716005]  [<ffffffff810a5b10>] ? lock_release_non_nested+0xa0/0x340
[  452.716005]  [<ffffffff81616ce4>] SYSC_bind+0xa4/0xc0
[  452.716005]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  452.716005]  [<ffffffff81616fde>] SyS_bind+0xe/0x10
[  452.716005]  [<ffffffff816523f8>] compat_SyS_socketcall+0xa8/0x200
[  452.716005]  [<ffffffff817693f3>] sysenter_dispatch+0x7/0x1f
[  452.716005]  [<ffffffff8139660e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  452.716005] Code: f0 ff 83 98 01 00 00 48 83 c4 08 5b 5d c3 66 66 66 66 2e 0f
1f 84 00 00 00 00 00 0f 1f 44 00 00 31 c0 8b 56 08 39 97 68 04 00 00 <55> 48 89
e5 74 0a 5d c3 0f 1f 84 00 00 00 00 00 48 8b 47 30 48
[  480.716005] NMI watchdog: BUG: soft lockup - CPU#7 stuck for 22s!
[bind-netlink:641]
[  480.716005] Modules linked in: tipc
[  480.716005] irq event stamp: 30405
[  480.716005] hardirqs last  enabled at (30404): [<ffffffff81767be0>]
restore_args+0x0/0x30
[  480.716005] hardirqs last disabled at (30405): [<ffffffff81767eaa>]
apic_timer_interrupt+0x6a/0x80
[  480.716005] softirqs last  enabled at (4280): [<ffffffff8161893f>]
lock_sock_nested+0x4f/0xc0
[  480.716005] softirqs last disabled at (4282): [<ffffffff8139d51a>]
lock_buckets+0x3a/0x80
[  480.716005] CPU: 7 PID: 641 Comm: bind-netlink Tainted: G        W    L
3.19.0-rc6+ #185
[  480.716005] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  480.716005] task: ffff880013f4c220 ti: ffff880014558000 task.ti: ffff880014558000
[  480.716005] RIP: 0010:[<ffffffff8139e5c1>]  [<ffffffff8139e5c1>]
rhashtable_lookup_compare+0x81/0x120
[  480.716005] RSP: 0018:ffff88001455bcf8  EFLAGS: 00000246
[  480.716005] RAX: 0000000000000000 RBX: ffffffff81767be0 RCX: 000000000bfbcdfb
[  480.716005] RDX: 00000000000002ae RSI: ffff88001455bdb8 RDI: ffff88001651b800
[  480.716005] RBP: ffff88001455bd48 R08: 00000000bef85eb8 R09: ffff880011bf1c68
[  480.716005] R10: 0000000000000004 R11: 0000000000000001 R12: ffff88001455bc68
[  480.716005] R13: 0000000000000046 R14: ffff880014558000 R15: ffff880013f4c220
[  480.716005] FS:  0000000000000000(0000) GS:ffff880017dc0000(0063)
knlGS:00000000f753e900
[  480.716005] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[  480.716005] CR2: 00000000f75f8b30 CR3: 0000000015abd000 CR4: 00000000000006e0
[  480.716005] Stack:
[  480.716005]  ffffffff8139e540 000000028105d9c8 00c662f713caac00 ffff880013d15200
[  480.716005]  ffff88001455bd48 ffff880016500000 ffff880013caac00 0000000000000007
[  480.716005]  ffff880013d15200 ffff880011bf1e08 ffff88001455bda8 ffffffff8139e72f
[  480.716005] Call Trace:
[  480.716005]  [<ffffffff8139e540>] ? rht_deferred_worker+0xa0/0xa0
[  480.716005]  [<ffffffff8139e72f>] rhashtable_lookup_compare_insert+0x9f/0x110
[  480.716005]  [<ffffffff8139e6c5>] ? rhashtable_lookup_compare_insert+0x35/0x110
[  480.716005]  [<ffffffff8165d8f0>] ? netlink_overrun+0x50/0x50
[  480.716005]  [<ffffffff8165e1d3>] ? netlink_insert+0x43/0xf0
[  480.716005]  [<ffffffff8165e221>] netlink_insert+0x91/0xf0
[  480.716005]  [<ffffffff81660550>] netlink_bind+0x210/0x260
[  480.716005]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  480.716005]  [<ffffffff810a5b10>] ? lock_release_non_nested+0xa0/0x340
[  480.716005]  [<ffffffff81616ce4>] SYSC_bind+0xa4/0xc0
[  480.716005]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  480.716005]  [<ffffffff81616fde>] SyS_bind+0xe/0x10
[  480.716005]  [<ffffffff816523f8>] compat_SyS_socketcall+0xa8/0x200
[  480.716005]  [<ffffffff817693f3>] sysenter_dispatch+0x7/0x1f
[  480.716005]  [<ffffffff8139660e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  480.716005] Code: 73 20 48 89 45 c8 ff 53 60 c1 e8 05 89 45 c4 48 8b 55 c8 48
8b 02 83 e8 01 23 45 c4 48 83 c0 02 4c 8b 74 c2 08 41 f6 c6 01 75 1a <4c> 89 f7
48 2b 7b 30 4c 89 ee 41 ff d4 84 c0 75 46 4d 8b 36 41
[  488.456005] INFO: rcu_sched self-detected stall on CPU { 7}  (t=15000 jiffies
g=472 c=471 q=113)
[  488.456005] Task dump for CPU 7:
[  488.456005] bind-netlink    R  running task        0   641    569 0x20020008
[  488.456005]  0000000000000239 ffff880017dc3d68 ffffffff81086c26 ffffffff81086b88
[  488.456005]  000000003b803b7f 0000000000000007 ffffffff81c53940 ffff880017dc3d88
[  488.456005]  ffffffff8108a57f ffffffff81c53940 ffffffff81c53940 ffff880017dc3db8
[  488.456005] Call Trace:
[  488.456005]  <IRQ>  [<ffffffff81086c26>] sched_show_task+0x106/0x170
[  488.456005]  [<ffffffff81086b88>] ? sched_show_task+0x68/0x170
[  488.456005]  [<ffffffff8108a57f>] dump_cpu_task+0x3f/0x50
[  488.456005]  [<ffffffff810bfa7b>] rcu_dump_cpu_stacks+0x8b/0xc0
[  488.456005]  [<ffffffff810c33d0>] rcu_check_callbacks+0x480/0x6d0
[  488.456005]  [<ffffffff810a133d>] ? trace_hardirqs_off+0xd/0x10
[  488.456005]  [<ffffffff810c8408>] update_process_times+0x38/0x70
[  488.456005]  [<ffffffff810d8623>] tick_sched_handle.isra.15+0x33/0x70
[  488.456005]  [<ffffffff810d88cb>] tick_sched_timer+0x4b/0x80
[  488.456005]  [<ffffffff810c8d8b>] __run_hrtimer+0x9b/0x290
[  488.456005]  [<ffffffff810d8880>] ? tick_sched_do_timer+0x40/0x40
[  488.456005]  [<ffffffff810c95e4>] ? hrtimer_interrupt+0x74/0x260
[  488.456005]  [<ffffffff810c9677>] hrtimer_interrupt+0x107/0x260
[  488.456005]  [<ffffffff8165d8f0>] ? netlink_overrun+0x50/0x50
[  488.456005]  [<ffffffff81034cb9>] local_apic_timer_interrupt+0x39/0x60
[  488.456005]  [<ffffffff81769b25>] smp_apic_timer_interrupt+0x45/0x60
[  488.456005]  [<ffffffff81767eaf>] apic_timer_interrupt+0x6f/0x80
[  488.456005]  <EOI>  [<ffffffff81767be0>] ? retint_restore_args+0xe/0xe
[  488.456005]  [<ffffffff8165d900>] ? netlink_compare+0x10/0x30
[  488.456005]  [<ffffffff8139e5ce>] ? rhashtable_lookup_compare+0x8e/0x120
[  488.456005]  [<ffffffff8139e540>] ? rht_deferred_worker+0xa0/0xa0
[  488.456005]  [<ffffffff8139e72f>] rhashtable_lookup_compare_insert+0x9f/0x110
[  488.456005]  [<ffffffff8139e6c5>] ? rhashtable_lookup_compare_insert+0x35/0x110
[  488.456005]  [<ffffffff8165d8f0>] ? netlink_overrun+0x50/0x50
[  488.456005]  [<ffffffff8165e1d3>] ? netlink_insert+0x43/0xf0
[  488.456005]  [<ffffffff8165e221>] netlink_insert+0x91/0xf0
[  488.456005]  [<ffffffff81660550>] netlink_bind+0x210/0x260
[  488.456005]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  488.456005]  [<ffffffff810a5b10>] ? lock_release_non_nested+0xa0/0x340
[  488.456005]  [<ffffffff81616ce4>] SYSC_bind+0xa4/0xc0
[  488.456005]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  488.456005]  [<ffffffff81616fde>] SyS_bind+0xe/0x10
[  488.456005]  [<ffffffff816523f8>] compat_SyS_socketcall+0xa8/0x200
[  488.456005]  [<ffffffff817693f3>] sysenter_dispatch+0x7/0x1f
[  488.456005]  [<ffffffff8139660e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  488.468021] INFO: rcu_sched detected stalls on CPUs/tasks: { 7} (detected by
3, t=15005 jiffies, g=472, c=471, q=113)
[  488.468021] Task dump for CPU 7:
[  488.468021] bind-netlink    R  running task        0   641    569 0x20020008
[  488.468021]  0000000000000000 0000000000000000 ffff88001455bf28 0000000000000002
[  488.468021]  00000000ff856f80 000000000000000c ffff88001455bf28 ffffffff81616fde
[  488.468021]  ffff88001455bf78 ffffffff816523f8 0000000000000001 ff856f980000002f
[  488.468021] Call Trace:
[  488.468021]  [<ffffffff81616fde>] ? SyS_bind+0xe/0x10
[  488.468021]  [<ffffffff816523f8>] ? compat_SyS_socketcall+0xa8/0x200
[  488.468021]  [<ffffffff817693f3>] ? sysenter_dispatch+0x7/0x1f
[  488.468021]  [<ffffffff8139660e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  512.716007] NMI watchdog: BUG: soft lockup - CPU#7 stuck for 22s!
[bind-netlink:641]
[  512.716007] Modules linked in: tipc
[  512.716007] irq event stamp: 46383
[  512.716007] hardirqs last  enabled at (46382): [<ffffffff81767be0>]
restore_args+0x0/0x30
[  512.716007] hardirqs last disabled at (46383): [<ffffffff81767eaa>]
apic_timer_interrupt+0x6a/0x80
[  512.716007] softirqs last  enabled at (4280): [<ffffffff8161893f>]
lock_sock_nested+0x4f/0xc0
[  512.716007] softirqs last disabled at (4282): [<ffffffff8139d51a>]
lock_buckets+0x3a/0x80
[  512.716007] CPU: 7 PID: 641 Comm: bind-netlink Tainted: G        W    L
3.19.0-rc6+ #185
[  512.716007] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  512.716007] task: ffff880013f4c220 ti: ffff880014558000 task.ti: ffff880014558000
[  512.716007] RIP: 0010:[<ffffffff8165d900>]  [<ffffffff8165d900>]
netlink_compare+0x10/0x30
[  512.716007] RSP: 0018:ffff88001455bcf0  EFLAGS: 00000293
[  512.716007] RAX: 0000000000000000 RBX: ffffffff81767be0 RCX: 000000000bfbcdfb
[  512.716007] RDX: 00000000000002ae RSI: ffff88001455bdb8 RDI: ffff88001651b800
[  512.716007] RBP: ffff88001455bd48 R08: 00000000bef85eb8 R09: ffff880011bf1c68
[  512.716007] R10: 0000000000000004 R11: 0000000000000001 R12: ffff88001455bc68
[  512.716007] R13: 0000000000000046 R14: ffff880014558000 R15: ffff880013f4c220
[  512.716007] FS:  0000000000000000(0000) GS:ffff880017dc0000(0063)
knlGS:00000000f753e900
[  512.716007] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[  512.716007] CR2: 00000000f75f8b30 CR3: 0000000015abd000 CR4: 00000000000006e0
[  512.716007] Stack:
[  512.716007]  ffffffff8139e5ce ffffffff8139e540 000000028105d9c8 00c662f713caac00
[  512.716007]  ffff880013d15200 ffff88001455bd48 ffff880016500000 ffff880013caac00
[  512.716007]  0000000000000007 ffff880013d15200 ffff880011bf1e08 ffff88001455bda8
[  512.716007] Call Trace:
[  512.716007]  [<ffffffff8139e5ce>] ? rhashtable_lookup_compare+0x8e/0x120
[  512.716007]  [<ffffffff8139e540>] ? rht_deferred_worker+0xa0/0xa0
[  512.716007]  [<ffffffff8139e72f>] rhashtable_lookup_compare_insert+0x9f/0x110
[  512.716007]  [<ffffffff8139e6c5>] ? rhashtable_lookup_compare_insert+0x35/0x110
[  512.716007]  [<ffffffff8165d8f0>] ? netlink_overrun+0x50/0x50
[  512.716007]  [<ffffffff8165e1d3>] ? netlink_insert+0x43/0xf0
[  512.716007]  [<ffffffff8165e221>] netlink_insert+0x91/0xf0
[  512.716007]  [<ffffffff81660550>] netlink_bind+0x210/0x260
[  512.716007]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  512.716007]  [<ffffffff810a5b10>] ? lock_release_non_nested+0xa0/0x340
[  512.716007]  [<ffffffff81616ce4>] SYSC_bind+0xa4/0xc0
[  512.716007]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  512.716007]  [<ffffffff81616fde>] SyS_bind+0xe/0x10
[  512.716007]  [<ffffffff816523f8>] compat_SyS_socketcall+0xa8/0x200
[  512.716007]  [<ffffffff817693f3>] sysenter_dispatch+0x7/0x1f
[  512.716007]  [<ffffffff8139660e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  512.716007] Code: f0 ff 83 98 01 00 00 48 83 c4 08 5b 5d c3 66 66 66 66 2e 0f
1f 84 00 00 00 00 00 0f 1f 44 00 00 31 c0 8b 56 08 39 97 68 04 00 00 <55> 48 89
e5 74 0a 5d c3 0f 1f 84 00 00 00 00 00 48 8b 47 30 48
[  540.716005] NMI watchdog: BUG: soft lockup - CPU#7 stuck for 22s!
[bind-netlink:641]
[  540.716005] Modules linked in: tipc
[  540.716005] irq event stamp: 60371
[  540.716005] hardirqs last  enabled at (60370): [<ffffffff81767be0>]
restore_args+0x0/0x30
[  540.716005] hardirqs last disabled at (60371): [<ffffffff81767eaa>]
apic_timer_interrupt+0x6a/0x80
[  540.716005] softirqs last  enabled at (4280): [<ffffffff8161893f>]
lock_sock_nested+0x4f/0xc0
[  540.716005] softirqs last disabled at (4282): [<ffffffff8139d51a>]
lock_buckets+0x3a/0x80
[  540.716005] CPU: 7 PID: 641 Comm: bind-netlink Tainted: G        W    L
3.19.0-rc6+ #185
[  540.716005] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  540.716005] task: ffff880013f4c220 ti: ffff880014558000 task.ti: ffff880014558000
[  540.716005] RIP: 0010:[<ffffffff8165d900>]  [<ffffffff8165d900>]
netlink_compare+0x10/0x30
[  540.716005] RSP: 0018:ffff88001455bcf0  EFLAGS: 00000293
[  540.716005] RAX: 0000000000000000 RBX: ffffffff81767be0 RCX: 000000000bfbcdfb
[  540.716005] RDX: 00000000000002ae RSI: ffff88001455bdb8 RDI: ffff88001651b800
[  540.716005] RBP: ffff88001455bd48 R08: 00000000bef85eb8 R09: ffff880011bf1c68
[  540.716005] R10: 0000000000000004 R11: 0000000000000001 R12: ffff88001455bc68
[  540.716005] R13: 0000000000000046 R14: ffff880014558000 R15: ffff880013f4c220
[  540.716005] FS:  0000000000000000(0000) GS:ffff880017dc0000(0063)
knlGS:00000000f753e900
[  540.716005] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[  540.716005] CR2: 00000000f75f8b30 CR3: 0000000015abd000 CR4: 00000000000006e0
[  540.716005] Stack:
[  540.716005]  ffffffff8139e5ce ffffffff8139e540 000000028105d9c8 00c662f713caac00
[  540.716005]  ffff880013d15200 ffff88001455bd48 ffff880016500000 ffff880013caac00
[  540.716005]  0000000000000007 ffff880013d15200 ffff880011bf1e08 ffff88001455bda8
[  540.716005] Call Trace:
[  540.716005]  [<ffffffff8139e5ce>] ? rhashtable_lookup_compare+0x8e/0x120
[  540.716005]  [<ffffffff8139e540>] ? rht_deferred_worker+0xa0/0xa0
[  540.716005]  [<ffffffff8139e72f>] rhashtable_lookup_compare_insert+0x9f/0x110
[  540.716005]  [<ffffffff8139e6c5>] ? rhashtable_lookup_compare_insert+0x35/0x110
[  540.716005]  [<ffffffff8165d8f0>] ? netlink_overrun+0x50/0x50
[  540.716005]  [<ffffffff8165e1d3>] ? netlink_insert+0x43/0xf0
[  540.716005]  [<ffffffff8165e221>] netlink_insert+0x91/0xf0
[  540.716005]  [<ffffffff81660550>] netlink_bind+0x210/0x260
[  540.716005]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  540.716005]  [<ffffffff810a5b10>] ? lock_release_non_nested+0xa0/0x340
[  540.716005]  [<ffffffff81616ce4>] SYSC_bind+0xa4/0xc0
[  540.716005]  [<ffffffff81184fc6>] ? might_fault+0x66/0xc0
[  540.716005]  [<ffffffff81616fde>] SyS_bind+0xe/0x10
[  540.716005]  [<ffffffff816523f8>] compat_SyS_socketcall+0xa8/0x200
[  540.716005]  [<ffffffff817693f3>] sysenter_dispatch+0x7/0x1f
[  540.716005]  [<ffffffff8139660e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  540.716005] Code: f0 ff 83 98 01 00 00 48 83 c4 08 5b 5d c3 66 66 66 66 2e 0f
1f 84 00 00 00 00 00 0f 1f 44 00 00 31 c0 8b 56 08 39 97 68 04 00 00 <55> 48 89
e5 74 0a 5d c3 0f 1f 84 00 00 00 00 00 48 8b 47 30

Regards,
Ying
