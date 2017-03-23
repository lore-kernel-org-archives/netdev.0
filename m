From: Dmitry Vyukov <dvyukov@google.com>
Subject: netlink: NULL timer crash
Date: Thu, 23 Mar 2017 13:55:31 +0100
Message-ID: <CACT4Y+Yb9BvzcRT84EriUCqx6hnz_kciYNHjHNX56y1jDb70vw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>
To: David Miller <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Alexei Starovoitov <ast@kernel.org>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

The following program triggers call of NULL timer func:

https://gist.githubusercontent.com/dvyukov/c210d01c74b911273469a93862ea7788/raw/2a3182772a6a6e20af3e71c02c2a1c2895d803fb/gistfile1.txt


BUG: unable to handle kernel NULL pointer dereference at           (null)
IP:           (null)
PGD 0
Oops: 0010 [#1] SMP KASAN
Modules linked in:
CPU: 2 PID: 0 Comm: swapper/2 Not tainted 4.11.0-rc3+ #365
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff88006c634300 task.stack: ffff88006c640000
RIP: 0010:          (null)
RSP: 0018:ffff88006d1077c8 EFLAGS: 00010246
RAX: dffffc0000000000 RBX: ffff880062bddb00 RCX: ffffffff8154e161
RDX: 1ffffffff090c1f1 RSI: 0000000000000000 RDI: ffff880062bddb00
RBP: ffff88006d1077e8 R08: fffffbfff0a936a8 R09: 0000000000000001
R10: 0000000000000001 R11: fffffbfff0a936a7 R12: ffffffff84860f80
R13: 0000000000000000 R14: ffff880062bddb60 R15: 1ffff1000da20f05
FS:  0000000000000000(0000) GS:ffff88006d100000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000000 CR3: 0000000004e21000 CR4: 00000000001406e0
Call Trace:
 <IRQ>
 neigh_timer_handler+0x365/0xd40 net/core/neighbour.c:944
 call_timer_fn+0x232/0x8c0 kernel/time/timer.c:1268
 expire_timers kernel/time/timer.c:1307 [inline]
 __run_timers+0x6f7/0xbd0 kernel/time/timer.c:1601
 run_timer_softirq+0x21/0x80 kernel/time/timer.c:1614
 __do_softirq+0x2d6/0xb54 kernel/softirq.c:284
 invoke_softirq kernel/softirq.c:364 [inline]
 irq_exit+0x1b1/0x1e0 kernel/softirq.c:405
 exiting_irq arch/x86/include/asm/apic.h:657 [inline]
 smp_apic_timer_interrupt+0x76/0xa0 arch/x86/kernel/apic/apic.c:962
 apic_timer_interrupt+0x93/0xa0 arch/x86/entry/entry_64.S:487
RIP: 0010:native_safe_halt+0x6/0x10 arch/x86/include/asm/irqflags.h:53
RSP: 0018:ffff88006c647dc0 EFLAGS: 00000286 ORIG_RAX: ffffffffffffff10
RAX: dffffc0000000000 RBX: 1ffff1000d8c8fbb RCX: 0000000000000000
RDX: 1ffffffff09d8ed4 RSI: 0000000000000001 RDI: ffffffff84ec76a0
RBP: ffff88006c647dc0 R08: ffffed000d8c6861 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: fffffbfff09d8ed2
R13: ffff88006c647e78 R14: ffffffff84ec7690 R15: 0000000000000002
 </IRQ>
 arch_safe_halt arch/x86/include/asm/paravirt.h:98 [inline]
 default_idle+0xba/0x450 arch/x86/kernel/process.c:275
 arch_cpu_idle+0xa/0x10 arch/x86/kernel/process.c:266
 default_idle_call+0x37/0x80 kernel/sched/idle.c:97
 cpuidle_idle_call kernel/sched/idle.c:155 [inline]
 do_idle+0x230/0x380 kernel/sched/idle.c:244
 cpu_startup_entry+0x18/0x20 kernel/sched/idle.c:346
 start_secondary+0x2a7/0x340 arch/x86/kernel/smpboot.c:275
 start_cpu+0x14/0x14 arch/x86/kernel/head_64.S:306
Code:  Bad RIP value.
RIP:           (null) RSP: ffff88006d1077c8
CR2: 0000000000000000
---[ end trace 845120b8a0d21411 ]---

On commit 093b995e3b55a0ae0670226ddfcb05bfbf0099ae
