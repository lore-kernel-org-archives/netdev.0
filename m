From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: v4.14-rc2/arm64 misaligned atomic in ip_expire() / skb_clone()
Date: Mon, 02 Oct 2017 06:44:41 -0700
Message-ID: <1506951881.8061.2.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171002115730.GA21696@leverpostej>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, syzkaller@googlegroups.com,
        "David S. Miller" <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171002115730.GA21696@leverpostej>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-10-02 at 12:57 +0100, Mark Rutland wrote:
> Hi all,
> 
> I'm intermittently hitting splats like below in skb_clone() while
> fuzzing v4.14-rc2 on arm64 with Syzkaller. It looks like the
> atomic_inc() at the end of __skb_clone() is being passed a misaligned
> pointer.
> 
> I've uploaded a number of splats and their associated (full) Syzkaller
> logs, along with my kernel config to my kernel.org webspace [1]. It
> might take a while for that to appear.
> 
> This isn't a pure v4.14-rc2, as I have a not-yet-upstream fix [2]
> applied to avoid a userfaultfd bug. The userfaultfd syscall appears in
> all of the Syzkaller logs, so there is the chance that this is related,
> but as I've not seen any other issues I suspect that's unlikely.
> 
> Thanks,
> Mark.
> 
> [1] https://www.kernel.org/pub/linux/kernel/people/mark/bugs/20171002-skb_clone-misaligned-atomic
> [2] https://lkml.kernel.org/r/20170920180413.26713-1-aarcange@redhat.com
> 
> Unable to handle kernel paging request at virtual address ffff80002fd714a2
> Mem abort info:
>   Exception class = DABT (current EL), IL = 32 bits
>   SET = 0, FnV = 0
>   EA = 0, S1PTW = 0
> Data abort info:
>   ISV = 0, ISS = 0x00000033
>   CM = 0, WnR = 0
> swapper pgtable: 4k pages, 48-bit VAs, pgd = ffff20000eeb2000
> [ffff80002fd714a2] *pgd=000000007eff7003, *pud=000000007eff6003, *pmd=00f800006fc00711
> Internal error: Oops: 96000021 [#1] PREEMPT SMP
> Modules linked in:
> CPU: 3 PID: 0 Comm: swapper/3 Not tainted 4.14.0-rc2-00001-gd7ad33d #115
> Hardware name: linux,dummy-virt (DT)
> task: ffff80003a901a80 task.stack: ffff80003a908000
> PC is at __ll_sc_atomic_add+0x4/0x18 arch/arm64/include/asm/atomic_ll_sc.h:113
> LR is at atomic_add arch/arm64/include/asm/atomic_lse.h:45 [inline]
> LR is at __skb_clone+0x4a8/0x6c0 net/core/skbuff.c:873
> pc : [<ffff20000a30ce44>] lr : [<ffff200009dffb58>] pstate: 10000145
> sp : ffff80003efd86e0
> x29: ffff80003efd86e0 x28: 000060003418b000 
> x27: ffff20000ae55360 x26: ffff8000182c1608 
> x25: ffff80002fd7137e x24: ffff8000182c1610 
> x23: ffff20000ae60000 x22: ffff80001577871c 
> x21: 1ffff00007dfb0e8 x20: ffff8000182c1540 
> x19: ffff800015778640 x18: ffff20000da58140 
> x17: 0000000000000000 x16: 0000000000000002 
> x15: ffff20000e1485a0 x14: ffff2000082f912c 
> x13: ffff2000082f8dcc x12: ffff2000082f8980 
> x11: 1ffff00002aef0df x10: ffff100002aef0df 
> x9 : dfff200000000000 x8 : 0082009000a40008 
> x7 : 0000000000000000 x6 : ffff800015778700 
> x5 : ffff100002aef0e0 x4 : 0000000000000000 
> x3 : 1ffff00002aef0e3 x2 : ffff80002fd7147e 
> x1 : ffff80002fd714a2 x0 : 0000000000000001 
> Process swapper/3 (pid: 0, stack limit = 0xffff80003a908000)
> Call trace:
> Exception stack(0xffff80003efd85a0 to 0xffff80003efd86e0)
> 85a0: 0000000000000001 ffff80002fd714a2 ffff80002fd7147e 1ffff00002aef0e3
> 85c0: 0000000000000000 ffff100002aef0e0 ffff800015778700 0000000000000000
> 85e0: 0082009000a40008 dfff200000000000 ffff100002aef0df 1ffff00002aef0df
> 8600: ffff2000082f8980 ffff2000082f8dcc ffff2000082f912c ffff20000e1485a0
> 8620: 0000000000000002 0000000000000000 ffff20000da58140 ffff800015778640
> 8640: ffff8000182c1540 1ffff00007dfb0e8 ffff80001577871c ffff20000ae60000
> 8660: ffff8000182c1610 ffff80002fd7137e ffff8000182c1608 ffff20000ae55360
> 8680: 000060003418b000 ffff80003efd86e0 ffff200009dffb58 ffff80003efd86e0
> 86a0: ffff20000a30ce44 0000000010000145 ffff800015778640 ffff8000182c1540
> 86c0: 0001000000000000 ffff8000182c15ce ffff80003efd86e0 ffff20000a30ce44
> [<ffff20000a30ce44>] __ll_sc_atomic_add+0x4/0x18 arch/arm64/include/asm/atomic_ll_sc.h:113
> [<ffff200009e1009c>] skb_clone+0x1c4/0x3b0 net/core/skbuff.c:1286
> [<ffff200009f2ff80>] ip_expire+0x4e8/0x7c0 net/ipv4/ip_fragment.c:239
> [<ffff2000082f8980>] call_timer_fn+0x1b8/0x430 kernel/time/timer.c:1281
> [<ffff2000082f8dcc>] expire_timers+0x1d4/0x320 kernel/time/timer.c:1320
> [<ffff2000082f912c>] __run_timers kernel/time/timer.c:1620 [inline]
> [<ffff2000082f912c>] run_timer_softirq+0x214/0x5f0 kernel/time/timer.c:1646
> [<ffff2000080826c0>] __do_softirq+0x350/0xc0c kernel/softirq.c:284
> [<ffff200008170af4>] do_softirq_own_stack include/linux/interrupt.h:498 [inline]
> [<ffff200008170af4>] invoke_softirq kernel/softirq.c:371 [inline]
> [<ffff200008170af4>] irq_exit+0x1dc/0x2f8 kernel/softirq.c:405
> [<ffff2000082a95bc>] __handle_domain_irq+0xdc/0x230 kernel/irq/irqdesc.c:647
> [<ffff2000080820ac>] handle_domain_irq include/linux/irqdesc.h:175 [inline]
> [<ffff2000080820ac>] gic_handle_irq+0x6c/0xe0 drivers/irqchip/irq-gic.c:367
> Exception stack(0xffff80003a90bd70 to 0xffff80003a90beb0)
> bd60:                                   ffff80003a90234c 0000000000000007
> bd80: 0000000000000000 1ffff00007520469 1fffe400017ad00c ffffffffffffe540
> bda0: 0000000000000000 0000000000000000 ffff80003a902350 1ffff00007520469
> bdc0: ffff80003a902348 ffff80003a902368 1ffff0000752046c 1ffff0000752046e
> bde0: 1ffff0000752046d ffff20000e1485a0 0000000000000000 0000000000029d44
> be00: ffff20000da58140 ffff80003a901a80 ffff80003a901a80 dfff200000000000
> be20: ffff20000ae60e98 ffff0400015cc1d3 0000000000000000 ffff20000ae60df8
> be40: ffff20000ae60df8 0000000000000000 0000000000000000 ffff80003a90beb0
> be60: ffff200008089b50 ffff80003a90beb0 ffff200008089b54 0000000010000145
> be80: ffff80003a901a80 ffff80003a901a80 ffffffffffffffff 01f6cee936b5bc00
> bea0: ffff80003a90beb0 ffff200008089b54
> [<ffff200008084034>] el1_irq+0xb4/0x12c arch/arm64/kernel/entry.S:569
> [<ffff200008089b54>] arch_local_irq_enable arch/arm64/include/asm/irqflags.h:40 [inline]
> [<ffff200008089b54>] arch_cpu_idle+0x1c/0x28 arch/arm64/kernel/process.c:87
> [<ffff20000a360a94>] default_idle_call+0x34/0x78 kernel/sched/idle.c:98
> [<ffff200008254a34>] cpuidle_idle_call kernel/sched/idle.c:156 [inline]
> [<ffff200008254a34>] do_idle+0x20c/0x370 kernel/sched/idle.c:246
> [<ffff20000825513c>] cpu_startup_entry+0x24/0x28 kernel/sched/idle.c:351
> [<ffff2000080a2f4c>] secondary_start_kernel+0x2fc/0x498 arch/arm64/kernel/smp.c:280
> Code: 978b7cfd 17ffff91 00000000 f9800031 (885f7c31) 
> ---[ end trace e4e9a51ab15d3a5f ]---
> 

skb->head is allocated by a kmalloc() call or similar.

This would happen if skb->end is mangled to not be a multiple of
NET_SKB_PAD  (or at least 4 in your case)
