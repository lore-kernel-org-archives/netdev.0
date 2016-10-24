From: Andrey Konovalov <andreyknvl@google.com>
Subject: net/ipv4: warning in inet_sock_destruct
Date: Mon, 24 Oct 2016 17:40:41 +0200
Message-ID: <CAAeHK+xvURmftN0oBWH7q_jz0JB6Nmyy+YRiBR96DxTazMYE_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>,
        Kostya Serebryany <kcc@google.com>,
        Alexander Potapenko <glider@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Dmitry Vyukov <dvyukov@google.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I've got the following error report while running the syzkaller fuzzer:

------------[ cut here ]------------
WARNING: CPU: 1 PID: 0 at net/ipv4/af_inet.c:153[<        none
>] inet_sock_destruct+0x64d/0x810 net/ipv4/af_inet.c:153
Modules linked in:
CPU: 1 PID: 0 Comm: swapper/1 Not tainted 4.9.0-rc2+ #301
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffff88006cd07d88 ffffffff81b47264 0000000000000000 0000000000000000
 ffffffff84465d80 0000000000000000 ffff88006cd07dd0 ffffffff81111237
 ffff88006cd19100[   60.531224]  0000000000000099 ffffffff84465d80
0000000000000099
Call Trace:
 <IRQ> [   60.531224]  [<ffffffff81b47264>] dump_stack+0xb3/0x10f
 [<ffffffff81111237>] __warn+0x1a7/0x1f0 kernel/panic.c:550
 [<ffffffff8111144c>] warn_slowpath_null+0x2c/0x40 kernel/panic.c:585
 [<ffffffff8316e64d>] inet_sock_destruct+0x64d/0x810 net/ipv4/af_inet.c:153
 [<ffffffff82b7c3a1>] __sk_destruct+0x51/0x480 net/core/sock.c:1422
 [<     inline     >] __rcu_reclaim kernel/rcu/rcu.h:118
 [<     inline     >] rcu_do_batch kernel/rcu/tree.c:2776
 [<     inline     >] invoke_rcu_callbacks kernel/rcu/tree.c:3040
 [<     inline     >] __rcu_process_callbacks kernel/rcu/tree.c:3007
 [<ffffffff8125e090>] rcu_process_callbacks+0xa40/0x1190 kernel/rcu/tree.c:3024
 [<ffffffff83fc376f>] __do_softirq+0x23f/0x8e5 kernel/softirq.c:284
 [<     inline     >] invoke_softirq kernel/softirq.c:364
 [<ffffffff811262b7>] irq_exit+0x1a7/0x1e0 kernel/softirq.c:405
 [<     inline     >] exiting_irq ./arch/x86/include/asm/apic.h:659
 [<ffffffff83fc309b>] smp_apic_timer_interrupt+0x7b/0xa0
arch/x86/kernel/apic/apic.c:960
 [<ffffffff83fc214c>] apic_timer_interrupt+0x8c/0xa0
 <EOI> [   60.531224]  [<ffffffff83fbf866>] ? native_safe_halt+0x6/0x10
 [<     inline     >] arch_safe_halt ./arch/x86/include/asm/paravirt.h:103
 [<ffffffff83fbef92>] default_idle+0x22/0x2d0 arch/x86/kernel/process.c:308
 [<ffffffff8106ef6a>] arch_cpu_idle+0xa/0x10 arch/x86/kernel/process.c:299
 [<ffffffff83fbfc16>] default_idle_call+0x36/0x60 kernel/sched/idle.c:96
 [<     inline     >] cpuidle_idle_call kernel/sched/idle.c:154
 [<     inline     >] cpu_idle_loop kernel/sched/idle.c:247
 [<ffffffff811f8024>] cpu_startup_entry+0x244/0x300 kernel/sched/idle.c:302
 [<ffffffff810b3ec0>] start_secondary+0x250/0x2d0 arch/x86/kernel/smpboot.c:263
---[ end trace 3cd7480984cd70d8 ]---

===============================
[ INFO: suspicious RCU usage. ]
4.9.0-rc2+ #301 Tainted: G        W
-------------------------------
net/core/sock.c:1425 suspicious rcu_dereference_check() usage!

other info that might help us debug this:


rcu_scheduler_active = 1, debug_locks = 0
1 lock held by swapper/1/0:
 #0: [   60.560631]  (
rcu_callback[   60.560930] ){......}
, at: [   60.561271] [<ffffffff8125e03b>] rcu_process_callbacks+0x9eb/0x1190

stack backtrace:
CPU: 1 PID: 0 Comm: swapper/1 Tainted: G        W       4.9.0-rc2+ #301
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffff88006cd07e20 ffffffff81b47264 ffff88006c180000 0000000000000000
 0000000000000001 ffffffff843fe660 ffff88006cd07e50 ffffffff81204a4f
 ffff880066438440 ffff880066438000 ffff8800664381b0 0000000000000000
Call Trace:
 <IRQ> [   60.563304]  [<ffffffff81b47264>] dump_stack+0xb3/0x10f
 [<ffffffff81204a4f>] lockdep_rcu_suspicious+0x13f/0x190
kernel/locking/lockdep.c:4445
 [<ffffffff82b7c710>] __sk_destruct+0x3c0/0x480 net/core/sock.c:1424
 [<     inline     >] __rcu_reclaim kernel/rcu/rcu.h:118
 [<     inline     >] rcu_do_batch kernel/rcu/tree.c:2776
 [<     inline     >] invoke_rcu_callbacks kernel/rcu/tree.c:3040
 [<     inline     >] __rcu_process_callbacks kernel/rcu/tree.c:3007
 [<ffffffff8125e090>] rcu_process_callbacks+0xa40/0x1190 kernel/rcu/tree.c:3024
 [<ffffffff83fc376f>] __do_softirq+0x23f/0x8e5 kernel/softirq.c:284
 [<     inline     >] invoke_softirq kernel/softirq.c:364
 [<ffffffff811262b7>] irq_exit+0x1a7/0x1e0 kernel/softirq.c:405
 [<     inline     >] exiting_irq ./arch/x86/include/asm/apic.h:659
 [<ffffffff83fc309b>] smp_apic_timer_interrupt+0x7b/0xa0
arch/x86/kernel/apic/apic.c:960
 [<ffffffff83fc214c>] apic_timer_interrupt+0x8c/0xa0
 <EOI> [   60.563304]  [<ffffffff83fbf866>] ? native_safe_halt+0x6/0x10
 [<     inline     >] arch_safe_halt ./arch/x86/include/asm/paravirt.h:103
 [<ffffffff83fbef92>] default_idle+0x22/0x2d0 arch/x86/kernel/process.c:308
 [<ffffffff8106ef6a>] arch_cpu_idle+0xa/0x10 arch/x86/kernel/process.c:299
 [<ffffffff83fbfc16>] default_idle_call+0x36/0x60 kernel/sched/idle.c:96
 [<     inline     >] cpuidle_idle_call kernel/sched/idle.c:154
 [<     inline     >] cpu_idle_loop kernel/sched/idle.c:247
 [<ffffffff811f8024>] cpu_startup_entry+0x244/0x300 kernel/sched/idle.c:302
 [<ffffffff810b3ec0>] start_secondary+0x250/0x2d0 arch/x86/kernel/smpboot.c:263



On commit 07d9a380680d1c0eb51ef87ff2eab5c994949e69 (Oct 23).
