From: Wei Wang <weiwan@google.com>
Subject: [PATCH net] ipv6: remove incorrect WARN_ON() in fib6_del()
Date: Mon, 25 Sep 2017 10:35:22 -0700
Message-ID: <20170925173522.99892-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:45040 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934132AbdIYRfr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 13:35:47 -0400
Received: by mail-pg0-f51.google.com with SMTP id j16so4374198pga.1
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 10:35:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

fib6_del() generates WARN_ON() when rt->dst.obsolete > 0. This does not
make sense because it is possible that the route passed in is already
deleted by some other thread and rt->dst.obsolete is set to
DST_OBSOLETE_DEAD.
So this commit deletes this WARN_ON() and also remove the
"#ifdef RT6_DEBUG >= 2" condition so that if the route is already
obsolete, we return right at the beginning of fib6_del().

Syzkaller hit this WARN_ON() in the following call trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x194/0x257 lib/dump_stack.c:52
 panic+0x1e4/0x417 kernel/panic.c:180
 __warn+0x1c4/0x1d9 kernel/panic.c:541
 report_bug+0x211/0x2d0 lib/bug.c:183
 fixup_bug+0x40/0x90 arch/x86/kernel/traps.c:190
 do_trap_no_signal arch/x86/kernel/traps.c:224 [inline]
 do_trap+0x260/0x390 arch/x86/kernel/traps.c:273
 do_error_trap+0x120/0x390 arch/x86/kernel/traps.c:310
 do_invalid_op+0x1b/0x20 arch/x86/kernel/traps.c:323
 invalid_op+0x1e/0x30 arch/x86/entry/entry_64.S:846
RIP: 0010:fib6_del+0x947/0xca0 net/ipv6/ip6_fib.c:1477
RSP: 0018:ffff8801db2074d8 EFLAGS: 00010206
RAX: ffff8801d1500080 RBX: ffff8801d01638c0 RCX: 0000000000000000
RDX: 0000000000000100 RSI: ffff8801db207650 RDI: ffff8801d0163924
RBP: ffff8801db2075f0 R08: ffffffff86df5f98 R09: 0000000000000002
R10: ffff8801db2074b8 R11: 1ffff1003a2a026b R12: dffffc0000000000
R13: ffff8801db207650 R14: ffff8801a0748180 R15: 1ffff1003b640ea5
 __ip6_del_rt+0xc7/0x120 net/ipv6/route.c:2136
 ip6_del_rt+0x132/0x1a0 net/ipv6/route.c:2149
 ip6_link_failure+0x244/0x380 net/ipv6/route.c:1359
 dst_link_failure include/net/dst.h:454 [inline]
 ndisc_error_report+0xae/0x180 net/ipv6/ndisc.c:682
 neigh_invalidate+0x225/0x530 net/core/neighbour.c:883
 neigh_timer_handler+0x883/0xca0 net/core/neighbour.c:969
 call_timer_fn+0x233/0x830 kernel/time/timer.c:1268
 expire_timers kernel/time/timer.c:1307 [inline]
 __run_timers+0x7fd/0xb90 kernel/time/timer.c:1601
 run_timer_softirq+0x21/0x80 kernel/time/timer.c:1614
 __do_softirq+0x2f5/0xba3 kernel/softirq.c:284
 invoke_softirq kernel/softirq.c:364 [inline]
 irq_exit+0x1cc/0x200 kernel/softirq.c:405
 exiting_irq arch/x86/include/asm/apic.h:638 [inline]
 smp_apic_timer_interrupt+0x76/0xa0 arch/x86/kernel/apic/apic.c:1044
 apic_timer_interrupt+0x93/0xa0 arch/x86/entry/entry_64.S:702
RIP: 0010:arch_local_irq_enable arch/x86/include/asm/paravirt.h:824 [inline]
RIP: 0010:__raw_spin_unlock_irq include/linux/spinlock_api_smp.h:168 [inline]
RIP: 0010:_raw_spin_unlock_irq+0x56/0x70 kernel/locking/spinlock.c:199
RSP: 0018:ffff8801d0407040 EFLAGS: 00000286 ORIG_RAX: ffffffffffffff10
RAX: dffffc0000000000 RBX: ffff8801db225780 RCX: 0000000000000000
RDX: 1ffffffff0b59433 RSI: 0000000000000001 RDI: ffffffff85aca198
RBP: ffff8801d0407048 R08: 0000000000000001 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: ffff8801c6820400
R13: 1ffff1003a080e11 R14: ffff8801d1500080 R15: ffff8801d1500080
 </IRQ>
 finish_lock_switch kernel/sched/sched.h:1334 [inline]
 finish_task_switch+0x1d3/0x740 kernel/sched/core.c:2638
 context_switch kernel/sched/core.c:2774 [inline]
 __schedule+0x8f0/0x2070 kernel/sched/core.c:3332
 schedule+0x108/0x440 kernel/sched/core.c:3391
 schedule_hrtimeout_range_clock+0x23e/0x810 kernel/time/hrtimer.c:1708
 schedule_hrtimeout_range+0x2a/0x40 kernel/time/hrtimer.c:1753
 poll_schedule_timeout+0x10f/0x1f0 fs/select.c:242
 do_select+0x11ea/0x1710 fs/select.c:581
 core_sys_select+0x480/0x960 fs/select.c:655
 do_pselect fs/select.c:732 [inline]
 SYSC_pselect6 fs/select.c:773 [inline]
 SyS_pselect6+0x54a/0x650 fs/select.c:758
 entry_SYSCALL_64_fastpath+0x1f/0xbe
RIP: 0033:0x45f181
RSP: 002b:00007f91306e1db0 EFLAGS: 00000246 ORIG_RAX: 000000000000010e
RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 000000000045f181
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000000
RBP: 0000000000000086 R08: 00007f91306e1db0 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00007ffdd9621670
R13: 00007f91306e29c0 R14: 00007f9130eac040 R15: 0000000000000003

Note: there is no Fixes tag because this bug was introduced long ago.

Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/ip6_fib.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index e5308d7cbd75..693bcd7ef6d2 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1592,13 +1592,7 @@ int fib6_del(struct rt6_info *rt, struct nl_info *info)
 	struct net *net = info->nl_net;
 	struct rt6_info **rtp;
 
-#if RT6_DEBUG >= 2
-	if (rt->dst.obsolete > 0) {
-		WARN_ON(fn);
-		return -ENOENT;
-	}
-#endif
-	if (!fn || rt == net->ipv6.ip6_null_entry)
+	if (!fn || rt->dst.obsolete > 0 || rt == net->ipv6.ip6_null_entry)
 		return -ENOENT;
 
 	WARN_ON(!(fn->fn_flags & RTN_RTINFO));
-- 
2.14.1.821.g8fa685d3b7-goog
