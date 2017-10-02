From: Eric Dumazet <edumazet@google.com>
Subject: Re: v4.14-rc2/arm64 kernel BUG at net/core/skbuff.c:2626
Date: Mon, 2 Oct 2017 06:36:32 -0700
Message-ID: <CANn89i++X2rzsaHkTRayMpCED_exL8WPq12=RwD_hXsZ6cN-wQ@mail.gmail.com>
References: <20171002104947.GE20737@leverpostej>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        linux-arm-kernel@lists.infradead.org,
        syzkaller <syzkaller@googlegroups.com>,
        "David S. Miller" <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171002104947.GE20737@leverpostej>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 2, 2017 at 3:49 AM, Mark Rutland <mark.rutland@arm.com> wrote:
> Hi all,
>
> I hit the below splat at net/core/skbuff.c:2626 while fuzzing v4.14-rc2
> on arm64 with Syzkaller. This is the BUG_ON(len) at the end of
> skb_copy_and_csum_bits().
>
> I've uploaded a copy of the splat, my config, and (full) Syzkaller log
> to my kernel.org web space [1]. I haven't had the opportunity to
> reproduce this yet.
>
> This isn't a pure v4.14-rc2, as I have a not-yet-upstream fix [2]
> applied to avoid a userfaultfd bug. However, per the Syzkaller log, the
> userfaultfd syscall wasn't invoked, so I don't believe that should
> matter.
>
> Thanks,
> Mark.
>
> [1] https://www.kernel.org/pub/linux/kernel/people/mark/bugs/20171002-skbuff-bug/
> [2] https://lkml.kernel.org/r/20170920180413.26713-1-aarcange@redhat.com
>
> ------------[ cut here ]------------
> kernel BUG at net/core/skbuff.c:2626!
> Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
> Modules linked in:
> CPU: 3 PID: 0 Comm: swapper/3 Not tainted 4.14.0-rc2-00001-gd7ad33d #115
> Hardware name: linux,dummy-virt (DT)
> task: ffff80003a901a80 task.stack: ffff80003a908000
> PC is at skb_copy_and_csum_bits+0x8dc/0xae0 net/core/skbuff.c:2626
> LR is at skb_copy_and_csum_bits+0x8dc/0xae0 net/core/skbuff.c:2626
> pc : [<ffff200009e03214>] lr : [<ffff200009e03214>] pstate: 00000145
> sp : ffff80003efd7b50
> x29: ffff80003efd7b50 x28: 000000000000003c
> x27: 00000000000001e8 x26: ffff80003a901a90
> x25: 000000000000003c x24: dfff200000000000
> x23: ffff800035723a80 x22: 000000000000003c
> x21: 0000000000000000 x20: 0000000000000000
> x19: 0000000000003a6d x18: ffff20000da58140
> x17: 0000000000000000 x16: 0000000000000001
> x15: ffff20000e1485a0 x14: ffff2000082f8980
> x13: ffff200009fc73d0 x12: ffff200009fc707c
> x11: 1ffff00002c2a3fc x10: ffff100002c2a3fc
> x9 : dfff200000000000 x8 : 07030301a8ff1127
> x7 : edff11270a080204 x6 : ffff800016151fe8
> x5 : ffff100002c2a3fd x4 : 000000000000000c
> x3 : 0000000000000030 x2 : 1ffff00006ae47a1
> x1 : 01f6cee936b5bc00 x0 : 0000000000000000
> Process swapper/3 (pid: 0, stack limit = 0xffff80003a908000)
> Call trace:
> Exception stack(0xffff80003efd7a10 to 0xffff80003efd7b50)
> 7a00:                                   0000000000000000 01f6cee936b5bc00
> 7a20: 1ffff00006ae47a1 0000000000000030 000000000000000c ffff100002c2a3fd
> 7a40: ffff800016151fe8 edff11270a080204 07030301a8ff1127 dfff200000000000
> 7a60: ffff100002c2a3fc 1ffff00002c2a3fc ffff200009fc707c ffff200009fc73d0
> 7a80: ffff2000082f8980 ffff20000e1485a0 0000000000000001 0000000000000000
> 7aa0: ffff20000da58140 0000000000003a6d 0000000000000000 0000000000000000
> 7ac0: 000000000000003c ffff800035723a80 dfff200000000000 000000000000003c
> 7ae0: ffff80003a901a90 00000000000001e8 000000000000003c ffff80003efd7b50
> 7b00: ffff200009e03214 ffff80003efd7b50 ffff200009e03214 0000000000000145
> 7b20: 0000000000003a6d 0000000000000000 0001000000000000 000000000000003c
> 7b40: ffff80003efd7b50 ffff200009e03214
> [<ffff200009e03214>] skb_copy_and_csum_bits+0x8dc/0xae0 net/core/skbuff.c:2626
> [<ffff20000a01d244>] icmp_glue_bits+0xa4/0x2a0 net/ipv4/icmp.c:357
> [<ffff200009f3f0d4>] __ip_append_data+0x10e4/0x20a8 net/ipv4/ip_output.c:1018
> [<ffff200009f41a88>] ip_append_data.part.3+0xe8/0x1a0 net/ipv4/ip_output.c:1170
> [<ffff200009f46e74>] ip_append_data+0xa4/0xb0 net/ipv4/ip_output.c:1173
> [<ffff20000a01ccc8>] icmp_push_reply+0x1b8/0x690 net/ipv4/icmp.c:375
> [<ffff20000a0211b0>] icmp_send+0x1070/0x1890 net/ipv4/icmp.c:741
> [<ffff200009f41d48>] ip_fragment.constprop.4+0x208/0x340 net/ipv4/ip_output.c:552
> [<ffff200009f42228>] ip_finish_output+0x3a8/0xab0 net/ipv4/ip_output.c:315
> [<ffff200009f468c4>] NF_HOOK_COND include/linux/netfilter.h:238 [inline]
> [<ffff200009f468c4>] ip_output+0x284/0x790 net/ipv4/ip_output.c:405
> [<ffff200009f43204>] dst_output include/net/dst.h:458 [inline]
> [<ffff200009f43204>] ip_local_out+0x9c/0x1b8 net/ipv4/ip_output.c:124
> [<ffff200009f445e8>] ip_queue_xmit+0x850/0x18e0 net/ipv4/ip_output.c:504
> [<ffff200009fb091c>] tcp_transmit_skb+0x107c/0x3338 net/ipv4/tcp_output.c:1123
> [<ffff200009fbbcc4>] __tcp_retransmit_skb+0x614/0x1d18 net/ipv4/tcp_output.c:2847
> [<ffff200009fbd840>] tcp_send_loss_probe+0x478/0x7d0 net/ipv4/tcp_output.c:2457
> [<ffff200009fc707c>] tcp_write_timer_handler+0x50c/0x7e8 net/ipv4/tcp_timer.c:557
> [<ffff200009fc73d0>] tcp_write_timer+0x78/0x170 net/ipv4/tcp_timer.c:579
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
> Exception stack(0xffff80003a90bb70 to 0xffff80003a90bcb0)
> bb60:                                   ffff80003a90234c 0000000000000007
> bb80: 0000000000000000 1ffff00007520469 1fffe400017ad00c dfff200000000000
> bba0: dfff200000000000 0000000000000000 ffff80003a902350 1ffff00007520469
> bbc0: ffff80003a902348 ffff80003a902368 1ffff0000752046c 1ffff0000752046e
> bbe0: 1ffff0000752046d ffff20000e1485a0 0000000000000000 0000000000000001
> bc00: ffff20000da58140 ffff80003efd9800 ffff80003efd9800 ffff20000ae60000
> bc20: ffff80003a971a80 1ffff000075217aa 0000000000000000 ffff20000ae60000
> bc40: 0000000000000001 ffff20000a34fce0 0000dffff519f438 ffff80003a90bcb0
> bc60: ffff20000a36134c ffff80003a90bcb0 ffff20000a361350 0000000010000145
> bc80: ffff80003efd9800 ffff80003efd9800 ffffffffffffffff ffff80003efd9800
> bca0: ffff80003a90bcb0 ffff20000a361350
> [<ffff200008084034>] el1_irq+0xb4/0x12c arch/arm64/kernel/entry.S:569
> [<ffff20000a361350>] arch_local_irq_enable arch/arm64/include/asm/irqflags.h:40 [inline]
> [<ffff20000a361350>] __raw_spin_unlock_irq include/linux/spinlock_api_smp.h:168 [inline]
> [<ffff20000a361350>] _raw_spin_unlock_irq+0x30/0x100 kernel/locking/spinlock.c:199
> [<ffff2000081e0850>] finish_lock_switch kernel/sched/sched.h:1335 [inline]
> [<ffff2000081e0850>] finish_task_switch+0x1d8/0x950 kernel/sched/core.c:2657
> [<ffff20000a34fce0>] context_switch kernel/sched/core.c:2793 [inline]
> [<ffff20000a34fce0>] __schedule+0x518/0x17b0 kernel/sched/core.c:3366
> [<ffff20000a3520e8>] schedule_idle+0x58/0xc8 kernel/sched/core.c:3452
> [<ffff200008254a00>] do_idle+0x1d8/0x370 kernel/sched/idle.c:269
> [<ffff200008255138>] cpu_startup_entry+0x20/0x28 kernel/sched/idle.c:351
> [<ffff2000080a2f4c>] secondary_start_kernel+0x2fc/0x498 arch/arm64/kernel/smp.c:280
> Code: 97bcbfac 17fffe19 d503201f 97974258 (d4210000)
> ---[ end trace 3359b414c3a12466 ]---

This is most likely a bug caused by syzkaller setting a ridiculous MTU
on loopback device, below minimum size of ipv4 MTU.

I tried to track it in August [1], but it seems hard to find all the
issues with this.

commit c780a049f9bf442314335372c9abc4548bfe3e44
Author: Eric Dumazet <edumazet@google.com>
Date:   Wed Aug 16 11:09:12 2017 -0700

    ipv4: better IP_MAX_MTU enforcement

    While working on yet another syzkaller report, I found
    that our IP_MAX_MTU enforcements were not properly done.

    gcc seems to reload dev->mtu for min(dev->mtu, IP_MAX_MTU), and
    final result can be bigger than IP_MAX_MTU :/

    This is a problem because device mtu can be changed on other cpus or
    threads.

    While this patch does not fix the issue I am working on, it is
    probably worth addressing it.
