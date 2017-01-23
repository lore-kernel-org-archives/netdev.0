From: Dmitry Vyukov <dvyukov@google.com>
Subject: net: use-after-free in tw_timer_handler
Date: Mon, 23 Jan 2017 11:19:59 +0100
Message-ID: <CACT4Y+a2t=Ev1-Mp6+aHzRkNPhWaY-dSYRdMeL2Hp7b37bnbUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>
To: David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

While running syzkaller fuzzer I started seeing use-after-frees in
tw_timer_handler. It happens with very low frequency, so far I've seen
22 of them. But all reports look consistent, so I would assume that it
is real, just requires a very tricky race to happen. I've stared
seeing it around Jan 17, however I did not update kernels for some
time before that so potentially the issues was introduced somewhat
earlier. Or maybe fuzzer just figured how to trigger it, and the bug
is actually old. I am seeing it on all of torvalds/linux-next/mmotm,
some commits if it matters: 7a308bb3016f57e5be11a677d15b821536419d36,
5cf7a0f3442b2312326c39f571d637669a478235,
c497f8d17246720afe680ea1a8fa6e48e75af852.
Majority of reports points to net_drop_ns as the offending free, but
it may be red herring. Since the access happens in timer, it can
happen long after free and the memory could have been reused. I've
also seen few where the access in tw_timer_handler is reported as
out-of-bounds on task_struct and on struct filename.


BUG: KASAN: use-after-free in tw_timer_handler+0xc3/0xd0
net/ipv4/inet_timewait_sock.c:149 at addr ffff8801cb58c398
Read of size 8 by task syz-executor0/24691
CPU: 0 PID: 24691 Comm: syz-executor0 Not tainted 4.9.0 #3
Hardware name: Google Google Compute Engine/Google Compute Engine,
BIOS Google 01/01/2011
 ffff8801dc007328 ffffffff8234530f ffffffff00000000 1ffff1003b800df8
 ffffed003b800df0 0000000041b58ab3 ffffffff84b379b8 ffffffff82345021
 ffff8801d8ad8f60 ffff8801d8ad8f68 ffff8801d8ad8740 000000000000002e
Call Trace:
 [<ffffffff819dd8fe>] __asan_report_load8_noabort+0x3e/0x40
mm/kasan/report.c:329
 [<ffffffff8374fd93>] tw_timer_handler+0xc3/0xd0
net/ipv4/inet_timewait_sock.c:149
 [<ffffffff815f5b21>] call_timer_fn+0x241/0x800 kernel/time/timer.c:1308
 [<ffffffff815f84b7>] expire_timers kernel/time/timer.c:1348 [inline]
 [<ffffffff815f84b7>] __run_timers+0x9e7/0xe90 kernel/time/timer.c:1641
 [<ffffffff815f8981>] run_timer_softirq+0x21/0x80 kernel/time/timer.c:1654
 [<ffffffff84372c7f>] __do_softirq+0x31f/0xbcd kernel/softirq.c:284
 [<ffffffff8143c18c>] invoke_softirq kernel/softirq.c:364 [inline]
 [<ffffffff8143c18c>] irq_exit+0x1cc/0x200 kernel/softirq.c:405
 [<ffffffff843723ee>] exiting_irq arch/x86/include/asm/apic.h:659 [inline]
 [<ffffffff843723ee>] smp_trace_apic_timer_interrupt+0x13e/0x6a8
arch/x86/kernel/apic/apic.c:981
 [<ffffffff843713dc>] trace_apic_timer_interrupt+0x8c/0xa0
arch/x86/entry/entry_64.S:709
 <EOI> [ 2916.083183]  [<ffffffff8436ebe6>] ? arch_local_irq_enable
arch/x86/include/asm/paravirt.h:777 [inline]
 <EOI> [ 2916.083183]  [<ffffffff8436ebe6>] ? __raw_spin_unlock_irq
include/linux/spinlock_api_smp.h:170 [inline]
 <EOI> [ 2916.083183]  [<ffffffff8436ebe6>] ?
_raw_spin_unlock_irq+0x56/0x70 kernel/locking/spinlock.c:199
 [<ffffffff814cbff2>] finish_lock_switch kernel/sched/sched.h:1157 [inline]
 [<ffffffff814cbff2>] finish_task_switch+0x1c2/0x710 kernel/sched/core.c:2769
 [<ffffffff84356654>] context_switch kernel/sched/core.c:2902 [inline]
 [<ffffffff84356654>] __schedule+0x724/0x1e90 kernel/sched/core.c:3402
 [<ffffffff84357ec8>] schedule+0x108/0x440 kernel/sched/core.c:3457
 [<ffffffff8100790f>] exit_to_usermode_loop+0x20f/0x2a0
arch/x86/entry/common.c:149
 [<ffffffff81009413>] prepare_exit_to_usermode
arch/x86/entry/common.c:190 [inline]
 [<ffffffff81009413>] syscall_return_slowpath+0x4d3/0x570
arch/x86/entry/common.c:259
 [<ffffffff8436fa22>] entry_SYSCALL_64_fastpath+0xc0/0xc2
Object at ffff8801cb58c1c0, in cache net_namespace size: 6656
Allocated:
PID = 3183
 [ 2916.342108] [<ffffffff819dcd92>] kasan_slab_alloc+0x12/0x20
mm/kasan/kasan.c:537
 [ 2916.349322] [<ffffffff819d83e2>] kmem_cache_alloc+0x102/0x680 mm/slab.c:3565
 [ 2916.356776] [<ffffffff83549a86>] kmem_cache_zalloc
include/linux/slab.h:626 [inline]
 [ 2916.356776] [<ffffffff83549a86>] net_alloc
net/core/net_namespace.c:339 [inline]
 [ 2916.356776] [<ffffffff83549a86>] copy_net_ns+0x196/0x480
net/core/net_namespace.c:379
 [ 2916.363783] [<ffffffff814b1349>] create_new_namespaces+0x409/0x860
kernel/nsproxy.c:106
 [ 2916.371605] [<ffffffff814b1aed>] copy_namespaces+0x34d/0x420
kernel/nsproxy.c:164
 [ 2916.379042] [<ffffffff814197f1>]
copy_process.part.40+0x2281/0x4d30 kernel/fork.c:1659
 [ 2916.387013] [<ffffffff8141c7e0>] copy_process kernel/fork.c:1483 [inline]
 [ 2916.387013] [<ffffffff8141c7e0>] _do_fork+0x200/0xff0 kernel/fork.c:1937
 [ 2916.393730] [<ffffffff8141d6a7>] SYSC_clone kernel/fork.c:2047 [inline]
 [ 2916.393730] [<ffffffff8141d6a7>] SyS_clone+0x37/0x50 kernel/fork.c:2041
 [ 2916.400376] [<ffffffff81009798>] do_syscall_64+0x2e8/0x930
arch/x86/entry/common.c:280
 [ 2916.407563] [<ffffffff8436fa49>] return_from_SYSCALL_64+0x0/0x7a
Freed:
PID = 15107
 [ 2916.441170] [<ffffffff819da1b1>] __cache_free mm/slab.c:3507 [inline]
 [ 2916.441170] [<ffffffff819da1b1>] kmem_cache_free+0x71/0x240 mm/slab.c:3767
 [ 2916.448408] [<ffffffff83548e3e>] net_free
net/core/net_namespace.c:355 [inline]
 [ 2916.448408] [<ffffffff83548e3e>] net_drop_ns+0x11e/0x140
net/core/net_namespace.c:362
 [ 2916.455370] [<ffffffff83549652>] cleanup_net+0x7f2/0xa90
net/core/net_namespace.c:472
 [ 2916.462331] [<ffffffff81492960>] process_one_work+0xbd0/0x1c10
kernel/workqueue.c:2096
 [ 2916.469877] [<ffffffff81493bc3>] worker_thread+0x223/0x1990
kernel/workqueue.c:2230
 [ 2916.477155] [<ffffffff814abb33>] kthread+0x323/0x3e0 kernel/kthread.c:209
 [ 2916.483831] [<ffffffff8436fbea>] ret_from_fork+0x2a/0x40
arch/x86/entry/entry_64.S:433
Memory state around the buggy address:
 ffff8801cb58c280: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff8801cb58c300: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>ffff8801cb58c380: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                            ^
 ffff8801cb58c400: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff8801cb58c480: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================

BUG: KASAN: use-after-free in tw_timer_handler+0xc3/0xd0
net/ipv4/inet_timewait_sock.c:149 at addr ffff8801cd4ec298
Read of size 8 by task swapper/1/0
CPU: 1 PID: 0 Comm: swapper/1 Not tainted 4.9.0 #3
Hardware name: Google Google Compute Engine/Google Compute Engine,
BIOS Google 01/01/2011
 ffff8801dc107468 ffffffff8234530f ffffffff00000001 1ffff1003b820e20
 ffffed003b820e18 0000000041b58ab3 ffffffff84b379b8 ffffffff82345021
 1ffff1003b820e17 ffff8801daf0e2c0 0000000041b58ab3 ffffffff84af4170
Call Trace:
 [<ffffffff819dd8fe>] __asan_report_load8_noabort+0x3e/0x40
mm/kasan/report.c:329
 [<ffffffff8374fd93>] tw_timer_handler+0xc3/0xd0
net/ipv4/inet_timewait_sock.c:149
 [<ffffffff815f5b21>] call_timer_fn+0x241/0x800 kernel/time/timer.c:1308
 [<ffffffff815f84b7>] expire_timers kernel/time/timer.c:1348 [inline]
 [<ffffffff815f84b7>] __run_timers+0x9e7/0xe90 kernel/time/timer.c:1641
 [<ffffffff815f8981>] run_timer_softirq+0x21/0x80 kernel/time/timer.c:1654
 [<ffffffff84372c7f>] __do_softirq+0x31f/0xbcd kernel/softirq.c:284
 [<ffffffff8143c18c>] invoke_softirq kernel/softirq.c:364 [inline]
 [<ffffffff8143c18c>] irq_exit+0x1cc/0x200 kernel/softirq.c:405
 [<ffffffff8437228b>] exiting_irq arch/x86/include/asm/apic.h:659 [inline]
 [<ffffffff8437228b>] smp_apic_timer_interrupt+0x7b/0xa0
arch/x86/kernel/apic/apic.c:960
 [<ffffffff8437133c>] apic_timer_interrupt+0x8c/0xa0
arch/x86/entry/entry_64.S:709
 <EOI> [ 1412.821824]  [<ffffffff8436dbb6>] ?
native_safe_halt+0x6/0x10 arch/x86/include/asm/irqflags.h:53
 [<ffffffff8436d08f>] arch_safe_halt
arch/x86/include/asm/paravirt.h:103 [inline]
 [<ffffffff8436d08f>] default_idle+0xbf/0x440 arch/x86/kernel/process.c:308
 [<ffffffff8128a5ca>] arch_cpu_idle+0xa/0x10 arch/x86/kernel/process.c:299
 [<ffffffff8436e0d6>] default_idle_call+0x36/0x90 kernel/sched/idle.c:96
 [<ffffffff815549a7>] cpuidle_idle_call kernel/sched/idle.c:154 [inline]
 [<ffffffff815549a7>] cpu_idle_loop kernel/sched/idle.c:247 [inline]
 [<ffffffff815549a7>] cpu_startup_entry+0x327/0x4b0 kernel/sched/idle.c:302
 [<ffffffff812e47ac>] start_secondary+0x36c/0x460 arch/x86/kernel/smpboot.c:263
Object at ffff8801cd4ec0c0, in cache net_namespace size: 6656
Allocated:
PID = 3131
 [ 1412.940699] [<ffffffff819d83e2>] kmem_cache_alloc+0x102/0x680 mm/slab.c:3565
 [ 1412.948084] [<ffffffff83549a86>] kmem_cache_zalloc
include/linux/slab.h:626 [inline]
 [ 1412.948084] [<ffffffff83549a86>] net_alloc
net/core/net_namespace.c:339 [inline]
 [ 1412.948084] [<ffffffff83549a86>] copy_net_ns+0x196/0x480
net/core/net_namespace.c:379
 [ 1412.955019] [<ffffffff814b1349>] create_new_namespaces+0x409/0x860
kernel/nsproxy.c:106
 [ 1412.962817] [<ffffffff814b1aed>] copy_namespaces+0x34d/0x420
kernel/nsproxy.c:164
 [ 1412.970094] [<ffffffff814197f1>]
copy_process.part.40+0x2281/0x4d30 kernel/fork.c:1659
 [ 1412.978004] [<ffffffff8141c7e0>] copy_process kernel/fork.c:1483 [inline]
 [ 1412.978004] [<ffffffff8141c7e0>] _do_fork+0x200/0xff0 kernel/fork.c:1937
 [ 1412.984677] [<ffffffff8141d6a7>] SYSC_clone kernel/fork.c:2047 [inline]
 [ 1412.984677] [<ffffffff8141d6a7>] SyS_clone+0x37/0x50 kernel/fork.c:2041
 [ 1412.991276] [<ffffffff81009798>] do_syscall_64+0x2e8/0x930
arch/x86/entry/common.c:280
 [ 1412.998394] [<ffffffff8436fa49>] return_from_SYSCALL_64+0x0/0x7a
Freed:
PID = 9846
 [ 1413.031603] [<ffffffff819da1b1>] __cache_free mm/slab.c:3507 [inline]
 [ 1413.031603] [<ffffffff819da1b1>] kmem_cache_free+0x71/0x240 mm/slab.c:3767
 [ 1413.038796] [<ffffffff83548e3e>] net_free
net/core/net_namespace.c:355 [inline]
 [ 1413.038796] [<ffffffff83548e3e>] net_drop_ns+0x11e/0x140
net/core/net_namespace.c:362
 [ 1413.045734] [<ffffffff83549652>] cleanup_net+0x7f2/0xa90
net/core/net_namespace.c:472
 [ 1413.052667] [<ffffffff81492960>] process_one_work+0xbd0/0x1c10
kernel/workqueue.c:2096
 [ 1413.060120] [<ffffffff81493bc3>] worker_thread+0x223/0x1990
kernel/workqueue.c:2230
 [ 1413.067357] [<ffffffff814abb33>] kthread+0x323/0x3e0 kernel/kthread.c:209
 [ 1413.073944] [<ffffffff8436fbea>] ret_from_fork+0x2a/0x40
arch/x86/entry/entry_64.S:433
Memory state around the buggy address:
 ffff8801cd4ec180: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff8801cd4ec200: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>ffff8801cd4ec280: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                            ^
 ffff8801cd4ec300: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff8801cd4ec380: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================

BUG: KASAN: use-after-free in tw_timer_handler+0xc3/0xd0
net/ipv4/inet_timewait_sock.c:149 at addr ffff8801b7b50358
Read of size 8 by task swapper/0/0
CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.9.0 #3
Hardware name: Google Google Compute Engine/Google Compute Engine,
BIOS Google 01/01/2011
 ffff8801dc007468 ffffffff8234530f ffffffff00000000 1ffff1003b800e20
 ffffed003b800e18 0000000041b58ab3 ffffffff84b379b8 ffffffff82345021
 ffffffff84e2bba0 ffffffff84e2bba8 ffffffff84e2b380 000000000000002e
Call Trace:
 [<ffffffff819dd8fe>] __asan_report_load8_noabort+0x3e/0x40
mm/kasan/report.c:329
 [<ffffffff8374fd93>] tw_timer_handler+0xc3/0xd0
net/ipv4/inet_timewait_sock.c:149
 [<ffffffff815f5b21>] call_timer_fn+0x241/0x800 kernel/time/timer.c:1308
 [<ffffffff815f84b7>] expire_timers kernel/time/timer.c:1348 [inline]
 [<ffffffff815f84b7>] __run_timers+0x9e7/0xe90 kernel/time/timer.c:1641
 [<ffffffff815f8981>] run_timer_softirq+0x21/0x80 kernel/time/timer.c:1654
 [<ffffffff84372c7f>] __do_softirq+0x31f/0xbcd kernel/softirq.c:284
 [<ffffffff8143c18c>] invoke_softirq kernel/softirq.c:364 [inline]
 [<ffffffff8143c18c>] irq_exit+0x1cc/0x200 kernel/softirq.c:405
 [<ffffffff8437228b>] exiting_irq arch/x86/include/asm/apic.h:659 [inline]
 [<ffffffff8437228b>] smp_apic_timer_interrupt+0x7b/0xa0
arch/x86/kernel/apic/apic.c:960
 [<ffffffff8437133c>] apic_timer_interrupt+0x8c/0xa0
arch/x86/entry/entry_64.S:709
 <EOI> [ 1965.936792]  [<ffffffff8436dbb6>] ?
native_safe_halt+0x6/0x10 arch/x86/include/asm/irqflags.h:53
 [<ffffffff8436d08f>] arch_safe_halt
arch/x86/include/asm/paravirt.h:103 [inline]
 [<ffffffff8436d08f>] default_idle+0xbf/0x440 arch/x86/kernel/process.c:308
 [<ffffffff8128a5ca>] arch_cpu_idle+0xa/0x10 arch/x86/kernel/process.c:299
 [<ffffffff8436e0d6>] default_idle_call+0x36/0x90 kernel/sched/idle.c:96
 [<ffffffff815549a7>] cpuidle_idle_call kernel/sched/idle.c:154 [inline]
 [<ffffffff815549a7>] cpu_idle_loop kernel/sched/idle.c:247 [inline]
 [<ffffffff815549a7>] cpu_startup_entry+0x327/0x4b0 kernel/sched/idle.c:302
 [<ffffffff8434f05d>] rest_init+0x18d/0x1a0 init/main.c:408
 [<ffffffff85481b16>] start_kernel+0x7a0/0x7d2 init/main.c:660
 [<ffffffff854802e6>] x86_64_start_reservations+0x2a/0x2c
arch/x86/kernel/head64.c:195
 [<ffffffff85480424>] x86_64_start_kernel+0x13c/0x149
arch/x86/kernel/head64.c:176
Object at ffff8801b7b50180, in cache net_namespace size: 6656
Allocated:
PID = 3169
 [ 1966.129951] [<ffffffff819d83e2>] kmem_cache_alloc+0x102/0x680 mm/slab.c:3565
 [ 1966.137357] [<ffffffff83549a86>] kmem_cache_zalloc
include/linux/slab.h:626 [inline]
 [ 1966.137357] [<ffffffff83549a86>] net_alloc
net/core/net_namespace.c:339 [inline]
 [ 1966.137357] [<ffffffff83549a86>] copy_net_ns+0x196/0x480
net/core/net_namespace.c:379
 [ 1966.144350] [<ffffffff814b1349>] create_new_namespaces+0x409/0x860
kernel/nsproxy.c:106
 [ 1966.152254] [<ffffffff814b1aed>] copy_namespaces+0x34d/0x420
kernel/nsproxy.c:164
 [ 1966.159567] [<ffffffff814197f1>]
copy_process.part.40+0x2281/0x4d30 kernel/fork.c:1659
 [ 1966.167484] [<ffffffff8141c7e0>] copy_process kernel/fork.c:1483 [inline]
 [ 1966.167484] [<ffffffff8141c7e0>] _do_fork+0x200/0xff0 kernel/fork.c:1937
 [ 1966.174207] [<ffffffff8141d6a7>] SYSC_clone kernel/fork.c:2047 [inline]
 [ 1966.174207] [<ffffffff8141d6a7>] SyS_clone+0x37/0x50 kernel/fork.c:2041
 [ 1966.180832] [<ffffffff81009798>] do_syscall_64+0x2e8/0x930
arch/x86/entry/common.c:280
 [ 1966.187973] [<ffffffff8436fa49>] return_from_SYSCALL_64+0x0/0x7a
Freed:
PID = 8938
 [ 1966.221347] [<ffffffff819da1b1>] __cache_free mm/slab.c:3507 [inline]
 [ 1966.221347] [<ffffffff819da1b1>] kmem_cache_free+0x71/0x240 mm/slab.c:3767
 [ 1966.228568] [<ffffffff83548e3e>] net_free
net/core/net_namespace.c:355 [inline]
 [ 1966.228568] [<ffffffff83548e3e>] net_drop_ns+0x11e/0x140
net/core/net_namespace.c:362
 [ 1966.235564] [<ffffffff83549652>] cleanup_net+0x7f2/0xa90
net/core/net_namespace.c:472
 [ 1966.242517] [<ffffffff81492960>] process_one_work+0xbd0/0x1c10
kernel/workqueue.c:2096
 [ 1966.249995] [<ffffffff81493bc3>] worker_thread+0x223/0x1990
kernel/workqueue.c:2230
 [ 1966.257258] [<ffffffff814abb33>] kthread+0x323/0x3e0 kernel/kthread.c:209
 [ 1966.263879] [<ffffffff8436fbea>] ret_from_fork+0x2a/0x40
arch/x86/entry/entry_64.S:433
Memory state around the buggy address:
 ffff8801b7b50200: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff8801b7b50280: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>ffff8801b7b50300: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                                                    ^
 ffff8801b7b50380: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff8801b7b50400: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================

BUG: KASAN: slab-out-of-bounds in tw_timer_handler+0xc3/0xd0
net/ipv4/inet_timewait_sock.c:149 at addr ffff8801c98f43a0
Read of size 8 by task syz-executor8/3423
CPU: 0 PID: 3423 Comm: syz-executor8 Not tainted 4.10.0-rc5 #19
Hardware name: Google Google Compute Engine/Google Compute Engine,
BIOS Google 01/01/2011
Call Trace:
 <IRQ>
 __dump_stack lib/dump_stack.c:15 [inline]
 dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
 kasan_object_err+0x1c/0x70 mm/kasan/report.c:161
 print_address_description mm/kasan/report.c:199 [inline]
 kasan_report_error+0x1d1/0x4d0 mm/kasan/report.c:288
 kasan_report mm/kasan/report.c:308 [inline]
 __asan_report_load8_noabort+0x3e/0x40 mm/kasan/report.c:329
 tw_timer_handler+0xc3/0xd0 net/ipv4/inet_timewait_sock.c:149
 call_timer_fn+0x241/0x820 kernel/time/timer.c:1308
 expire_timers kernel/time/timer.c:1348 [inline]
 __run_timers+0x9e7/0xe90 kernel/time/timer.c:1642
 run_timer_softirq+0x21/0x80 kernel/time/timer.c:1655
 __do_softirq+0x31f/0xbe7 kernel/softirq.c:284
 invoke_softirq kernel/softirq.c:364 [inline]
 irq_exit+0x1cc/0x200 kernel/softirq.c:405
 exiting_irq arch/x86/include/asm/apic.h:658 [inline]
 smp_apic_timer_interrupt+0x76/0xa0 arch/x86/kernel/apic/apic.c:961
 apic_timer_interrupt+0x93/0xa0 arch/x86/entry/entry_64.S:707
RIP: 0010:arch_local_save_flags arch/x86/include/asm/paravirt.h:762 [inline]
RIP: 0010:arch_local_irq_save arch/x86/include/asm/paravirt.h:784 [inline]
RIP: 0010:lock_is_held_type+0x124/0x310 kernel/locking/lockdep.c:3787
RSP: 0018:ffff8801c946f558 EFLAGS: 00000286 ORIG_RAX: ffffffffffffff10
RAX: 0000000000000286 RBX: 1ffff1003928deac RCX: 1ffff1003928deb0
RDX: 1ffffffff0a18984 RSI: 00000000ffffffff RDI: ffffffff850c4c20
RBP: ffff8801c946f6a8 R08: 0000000000000002 R09: 0000000000000001
R10: 000000000000000a R11: 0000000000000000 R12: ffff8801c946f680
R13: ffff8801c9492640 R14: ffffffff85130ec0 R15: 0000000000000bff
 </IRQ>
 lock_is_held include/linux/lockdep.h:348 [inline]
 ___might_sleep+0x5b3/0x650 kernel/sched/core.c:7748
 __might_sleep+0x95/0x1a0 kernel/sched/core.c:7739
 cache_alloc_debugcheck_before mm/slab.c:3071 [inline]
 slab_alloc mm/slab.c:3386 [inline]
 kmem_cache_alloc+0x273/0x680 mm/slab.c:3558
 shmem_alloc_inode+0x1b/0x40 mm/shmem.c:3647
 alloc_inode+0x61/0x180 fs/inode.c:207
 new_inode_pseudo+0x69/0x170 fs/inode.c:889
 new_inode+0x1c/0x40 fs/inode.c:918
 shmem_get_inode+0xd1/0x8a0 mm/shmem.c:2120
 shmem_mknod+0x58/0x1b0 mm/shmem.c:2824
 shmem_mkdir+0x29/0x50 mm/shmem.c:2875
 vfs_mkdir+0x3be/0x600 fs/namei.c:3738
 SYSC_mkdirat fs/namei.c:3761 [inline]
 SyS_mkdirat fs/namei.c:3745 [inline]
 SYSC_mkdir fs/namei.c:3772 [inline]
 SyS_mkdir+0x16e/0x290 fs/namei.c:3770
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x44ec87
RSP: 002b:0000000001a2fe40 EFLAGS: 00000212 ORIG_RAX: 0000000000000053
RAX: ffffffffffffffda RBX: 0000000000000010 RCX: 000000000044ec87
RDX: 0000000001a2fe6e RSI: 00000000000001ff RDI: 0000000001a2fe68
RBP: 00000000000019ec R08: 0000000000000000 R09: 0000000000000006
R10: 0000000000000064 R11: 0000000000000212 R12: 0000000001ef390c
R13: 0000000000000000 R14: 00000000000a43b5 R15: 00000000000019ec
Object at ffff8801c98f44c0, in cache task_struct size: 5696
Allocated:
PID = 3452
[<ffffffff8129f656>] save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
[<ffffffff819f6f53>] save_stack+0x43/0xd0 mm/kasan/kasan.c:502
[<ffffffff819f71da>] set_track mm/kasan/kasan.c:514 [inline]
[<ffffffff819f71da>] kasan_kmalloc+0xaa/0xd0 mm/kasan/kasan.c:605
[<ffffffff819f77d2>] kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:544
[<ffffffff819f1652>] kmem_cache_alloc_node+0x122/0x690 mm/slab.c:3650
[<ffffffff81421fe2>] alloc_task_struct_node kernel/fork.c:142 [inline]
[<ffffffff81421fe2>] dup_task_struct kernel/fork.c:482 [inline]
[<ffffffff81421fe2>] copy_process.part.42+0x1a32/0x5fd0 kernel/fork.c:1515
[<ffffffff81426ac0>] copy_process kernel/fork.c:1486 [inline]
[<ffffffff81426ac0>] _do_fork+0x200/0xff0 kernel/fork.c:1942
[<ffffffff81427987>] SYSC_clone kernel/fork.c:2052 [inline]
[<ffffffff81427987>] SyS_clone+0x37/0x50 kernel/fork.c:2046
[<ffffffff81009798>] do_syscall_64+0x2e8/0x930 arch/x86/entry/common.c:280
[<ffffffff8440fb09>] return_from_SYSCALL_64+0x0/0x7a
Freed:
PID = 29885
[<ffffffff8129f656>] save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
[<ffffffff819f6f53>] save_stack+0x43/0xd0 mm/kasan/kasan.c:502
[<ffffffff819f784f>] set_track mm/kasan/kasan.c:514 [inline]
[<ffffffff819f784f>] kasan_slab_free+0x6f/0xb0 mm/kasan/kasan.c:578
[<ffffffff819f4bf1>] __cache_free mm/slab.c:3502 [inline]
[<ffffffff819f4bf1>] kmem_cache_free+0x71/0x240 mm/slab.c:3762
[<ffffffff8141f041>] free_task_struct kernel/fork.c:147 [inline]
[<ffffffff8141f041>] free_task+0x151/0x1d0 kernel/fork.c:359
[<ffffffff8141f30b>] __put_task_struct+0x24b/0x5f0 kernel/fork.c:396
[<ffffffff81435baa>] put_task_struct include/linux/sched.h:2257 [inline]
[<ffffffff81435baa>] delayed_put_task_struct+0xca/0x3f0 kernel/exit.c:173
[<ffffffff815ef250>] __rcu_reclaim kernel/rcu/rcu.h:118 [inline]
[<ffffffff815ef250>] rcu_do_batch.isra.70+0x9e0/0xdf0 kernel/rcu/tree.c:2780
[<ffffffff815efad2>] invoke_rcu_callbacks kernel/rcu/tree.c:3043 [inline]
[<ffffffff815efad2>] __rcu_process_callbacks kernel/rcu/tree.c:3010 [inline]
[<ffffffff815efad2>] rcu_process_callbacks+0x472/0xc70 kernel/rcu/tree.c:3027
[<ffffffff84412d7f>] __do_softirq+0x31f/0xbe7 kernel/softirq.c:284
Memory state around the buggy address:
 ffff8801c98f4280: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
 ffff8801c98f4300: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>ffff8801c98f4380: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
                               ^
 ffff8801c98f4400: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
 ffff8801c98f4480: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
==================================================================
