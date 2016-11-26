From: Dmitry Vyukov <dvyukov@google.com>
Subject: net: deadlock on genl_mutex
Date: Sat, 26 Nov 2016 18:04:12 +0100
Message-ID: <CACT4Y+ZdSNVhF2MH0=t=kBUrgNSSnCSO5uwnnc5c0KNLG+VNFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>
To: David Miller <davem@davemloft.net>,
        Matti Vaittinen <matti.vaittinen@nokia.com>,
        Tycho Andersen <tycho.andersen@canonical.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Florian Westphal <fw@strlen.de>,
        stephen hemminger <stephen@networkplumber.org>,
        Tom Herbert <tom@herbertland.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>, rgb@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:35675 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751721AbcKZREf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2016 12:04:35 -0500
Received: by mail-lf0-f47.google.com with SMTP id b14so69099425lfg.2
        for <netdev@vger.kernel.org>; Sat, 26 Nov 2016 09:04:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

The following program triggers deadlock warnings on genl_mutex:

https://gist.githubusercontent.com/dvyukov/65e33d053e507d2ab0bf6ae83d989585/raw/b3c640ec58e894b50bcbf255c471406466cfa5d0/gistfile1.txt

On commit 16ae16c6e5616c084168740990fc508bda6655d4 (Nov 24).

BUG: sleeping function called from invalid context at kernel/locking/mutex.c:620
in_atomic(): 1, irqs_disabled(): 0, pid: 32289, name: syz-executor
CPU: 0 PID: 32289 Comm: syz-executor Not tainted 4.9.0-rc5+ #54
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffff88003ec06420 ffffffff834c2e39 ffffffff00000000 1ffff10007d80c17
 ffffed0007d80c0f 0000000041b58ab3 ffffffff89575550 ffffffff834c2b4b
 ffffffff8baab1a0 dffffc0000000000 0000000000000000 ffff880068f794e0
Call Trace:
 <IRQ> [  287.394552]  [<     inline     >] __dump_stack lib/dump_stack.c:15
 <IRQ> [  287.394552]  [<ffffffff834c2e39>] dump_stack+0x2ee/0x3f5
lib/dump_stack.c:51
 [<ffffffff814b6ac3>] ___might_sleep+0x483/0x660 kernel/sched/core.c:7761
 [<ffffffff814b6d3a>] __might_sleep+0x9a/0x1a0 kernel/sched/core.c:7720
 [<ffffffff88139aaa>] mutex_lock_nested+0x1ea/0xf20 kernel/locking/mutex.c:620
 [<     inline     >] genl_lock net/netlink/genetlink.c:31
 [<ffffffff86cb5a11>] genl_lock_done+0x71/0xd0 net/netlink/genetlink.c:531
 [<ffffffff86ca5458>] netlink_sock_destruct+0xf8/0x400
net/netlink/af_netlink.c:331
 [<ffffffff86a7b234>] __sk_destruct+0xf4/0x7f0 net/core/sock.c:1423
 [<ffffffff86a87d6c>] sk_destruct+0x4c/0x80 net/core/sock.c:1453
 [<ffffffff86a87dfc>] __sk_free+0x5c/0x230 net/core/sock.c:1461
 [<ffffffff86a87ff8>] sk_free+0x28/0x30 net/core/sock.c:1472
 [<     inline     >] sock_put include/net/sock.h:1591
 [<ffffffff86ca6cd1>] deferred_put_nlk_sk+0x31/0x40 net/netlink/af_netlink.c:652
 [<     inline     >] __rcu_reclaim kernel/rcu/rcu.h:118
 [<ffffffff815cbc9d>] rcu_do_batch.isra.70+0x9ed/0xe20 kernel/rcu/tree.c:2776
 [<     inline     >] invoke_rcu_callbacks kernel/rcu/tree.c:3040
 [<     inline     >] __rcu_process_callbacks kernel/rcu/tree.c:3007
 [<ffffffff815cc55c>] rcu_process_callbacks+0x48c/0xd70 kernel/rcu/tree.c:3024
 [<ffffffff8814d53b>] __do_softirq+0x32b/0xca8 kernel/softirq.c:284
 [<     inline     >] invoke_softirq kernel/softirq.c:364
 [<ffffffff8141a941>] irq_exit+0x1d1/0x210 kernel/softirq.c:405
 [<     inline     >] exiting_irq arch/x86/include/asm/apic.h:659
 [<ffffffff8814ca30>] smp_apic_timer_interrupt+0x80/0xa0
arch/x86/kernel/apic/apic.c:960
 [<ffffffff8814badc>] apic_timer_interrupt+0x8c/0xa0
arch/x86/entry/entry_64.S:489
 <EOI> [  287.403717]  [<ffffffff8155c987>] ? lock_is_held+0x247/0x310
 [<ffffffff814b6bde>] ___might_sleep+0x59e/0x660 kernel/sched/core.c:7729
 [<ffffffff814b6d3a>] __might_sleep+0x9a/0x1a0 kernel/sched/core.c:7720
 [<ffffffff88142d08>] down_read+0x78/0x160 kernel/locking/rwsem.c:21
 [<     inline     >] anon_vma_lock_read include/linux/rmap.h:127
 [<ffffffff81968295>] validate_mm+0xe5/0x880 mm/mmap.c:347
 [<ffffffff8196bf0b>] vma_link+0x11b/0x180 mm/mmap.c:605
 [<ffffffff81977f46>] mmap_region+0x1076/0x1880 mm/mmap.c:1692
 [<ffffffff81978e4f>] do_mmap+0x6ff/0xe80 mm/mmap.c:1450
 [<     inline     >] do_mmap_pgoff include/linux/mm.h:2039
 [<ffffffff818fd527>] vm_mmap_pgoff+0x1b7/0x210 mm/util.c:305
 [<     inline     >] SYSC_mmap_pgoff mm/mmap.c:1500
 [<ffffffff8196f961>] SyS_mmap_pgoff+0x231/0x5e0 mm/mmap.c:1458
 [<     inline     >] SYSC_mmap arch/x86/kernel/sys_x86_64.c:95
 [<ffffffff8124bf4b>] SyS_mmap+0x1b/0x30 arch/x86/kernel/sys_x86_64.c:86
 [<ffffffff88149dc5>] entry_SYSCALL_64_fastpath+0x23/0xc6

=================================
[ INFO: inconsistent lock state ]
4.9.0-rc5+ #54 Tainted: G        W
---------------------------------
inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
syz-executor/32289 [HC0[0]:SC1[1]:HE1:SE0] takes:
 ([  287.580014] genl_mutex
[<     inline     >] genl_lock net/netlink/genetlink.c:31
[<ffffffff86cb5a11>] genl_lock_done+0x71/0xd0 net/netlink/genetlink.c:531
{SOFTIRQ-ON-W} state was registered at:
  [  287.580014] [<     inline     >] mark_irqflags
kernel/locking/lockdep.c:2938
  [  287.580014] [<ffffffff81567ad7>] __lock_acquire+0x6e7/0x3380
kernel/locking/lockdep.c:3292
  [  287.580014] [<ffffffff8156b642>] lock_acquire+0x2a2/0x790
kernel/locking/lockdep.c:3746
  [  287.580014] [<     inline     >] __mutex_lock_common
kernel/locking/mutex.c:521
  [  287.580014] [<ffffffff88139aff>] mutex_lock_nested+0x23f/0xf20
kernel/locking/mutex.c:621
  [  287.580014] [<     inline     >] genl_lock net/netlink/genetlink.c:31
  [  287.580014] [<     inline     >] genl_lock_all net/netlink/genetlink.c:52
  [  287.580014] [<ffffffff86cba52e>]
__genl_register_family+0x2ce/0x1870 net/netlink/genetlink.c:374
  [  287.580014] [<     inline     >]
_genl_register_family_with_ops_grps include/net/genetlink.h:173
  [  287.580014] [<ffffffff8ab90c02>] genl_init+0x11d/0x185
net/netlink/genetlink.c:1084
  [  287.580014] [<ffffffff8100244b>] do_one_initcall+0xfb/0x3f0 init/main.c:778
  [  287.580014] [<     inline     >] do_initcall_level init/main.c:844
  [  287.580014] [<     inline     >] do_initcalls init/main.c:852
  [  287.580014] [<     inline     >] do_basic_setup init/main.c:870
  [  287.580014] [<ffffffff8aa3d03d>] kernel_init_freeable+0x5c4/0x69e
init/main.c:1017
  [  287.580014] [<ffffffff88129c88>] kernel_init+0x18/0x180 init/main.c:943
  [  287.580014] [<ffffffff8814a05a>] ret_from_fork+0x2a/0x40
arch/x86/entry/entry_64.S:433

[   78.258919] [ INFO: inconsistent lock state ]
[   78.258919] 4.9.0-rc5+ #54 Tainted: G        W
[   78.258919] ---------------------------------
[   78.258919] inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
[   78.258919] syz-fuzzer/5211 [HC0[0]:SC1[1]:HE1:SE0] takes:
[   78.258919]  ([   78.258919] genl_mutex
){+.?.+.}[   78.258919] , at:
[   78.258919] [<ffffffff86cb5a11>] genl_lock_done+0x71/0xd0
[   78.258919] {SOFTIRQ-ON-W} state was registered at:
[   78.258919]   [   78.258919] [<ffffffff81567ad7>] __lock_acquire+0x6e7/0x3380
[   78.258919]   [   78.258919] [<ffffffff8156b642>] lock_acquire+0x2a2/0x790
[   78.258919]   [   78.258919] [<ffffffff88139aff>]
mutex_lock_nested+0x23f/0xf20
[   78.258919]   [   78.258919] [<ffffffff86cba52e>]
__genl_register_family+0x2ce/0x1870
[   78.258919]   [   78.258919] [<ffffffff8ab90c02>] genl_init+0x11d/0x185
[   78.258919]   [   78.258919] [<ffffffff8100244b>] do_one_initcall+0xfb/0x3f0
[   78.258919]   [   78.258919] [<ffffffff8aa3d03d>]
kernel_init_freeable+0x5c4/0x69e
[   78.258919]   [   78.258919] [<ffffffff88129c88>] kernel_init+0x18/0x180
[   78.258919]   [   78.258919] [<ffffffff8814a05a>] ret_from_fork+0x2a/0x40
[   78.258919] irq event stamp: 149484
[   78.258919] hardirqs last  enabled at (149484): [   78.258919]
[<ffffffff8814a7df>] restore_regs_and_iret+0x0/0x1d
[   78.258919] hardirqs last disabled at (149483): [   78.258919]
[<ffffffff8814bad7>] apic_timer_interrupt+0x87/0xa0
[   78.258919] softirqs last  enabled at (149302): [   78.258919]
[<ffffffff8814da39>] __do_softirq+0x829/0xca8
[   78.258919] softirqs last disabled at (149437): [   78.258919]
[<ffffffff8141a941>] irq_exit+0x1d1/0x210

[   78.258919]
[   78.258919] other info that might help us debug this:
[   78.258919]  Possible unsafe locking scenario:
[   78.258919]
[   78.258919]        CPU0
[   78.258919]        ----
[   78.258919]   lock([   78.258919] genl_mutex
[   78.258919] );
[   78.258919]   <Interrupt>
[   78.258919]     lock([   78.258919] genl_mutex
[   78.258919] );
[   78.258919]
[   78.258919]  *** DEADLOCK ***
[   78.258919]
[   78.258919] 1 lock held by syz-fuzzer/5211:
[   78.258919]  #0: [   78.258919]  (
rcu_callback[   78.258919] ){......}
, at: [   78.258919] [<ffffffff815cbc43>] rcu_do_batch.isra.70+0x993/0xe20
[   78.258919]
[   78.258919] stack backtrace:

CPU: 0 PID: 32289 Comm: syz-executor Tainted: G        W       4.9.0-rc5+ #54
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffff88003ec05db8 ffffffff834c2e39 ffffffff00000000 1ffff10007d80b4a
 ffffed0007d80b42 0000000041b58ab3 ffffffff89575550 ffffffff834c2b4b
 ffff88003948a340 ffff88003ec22cc0 ffff8800384dd280 0000000041b58ab3
Call Trace:
 <IRQ> [  287.580014]  [<     inline     >] __dump_stack lib/dump_stack.c:15
 <IRQ> [  287.580014]  [<ffffffff834c2e39>] dump_stack+0x2ee/0x3f5
lib/dump_stack.c:51
 [<ffffffff815648df>] print_usage_bug+0x3ef/0x450 kernel/locking/lockdep.c:2388
 [<     inline     >] valid_state kernel/locking/lockdep.c:2401
 [<     inline     >] mark_lock_irq kernel/locking/lockdep.c:2599
 [<ffffffff81565870>] mark_lock+0xf30/0x1410 kernel/locking/lockdep.c:3062
 [<     inline     >] mark_irqflags kernel/locking/lockdep.c:2920
 [<ffffffff8156811e>] __lock_acquire+0xd2e/0x3380 kernel/locking/lockdep.c:3292
 [<ffffffff8156b642>] lock_acquire+0x2a2/0x790 kernel/locking/lockdep.c:3746
 [<     inline     >] __mutex_lock_common kernel/locking/mutex.c:521
 [<ffffffff88139aff>] mutex_lock_nested+0x23f/0xf20 kernel/locking/mutex.c:621
 [<     inline     >] genl_lock net/netlink/genetlink.c:31
 [<ffffffff86cb5a11>] genl_lock_done+0x71/0xd0 net/netlink/genetlink.c:531
 [<ffffffff86ca5458>] netlink_sock_destruct+0xf8/0x400
net/netlink/af_netlink.c:331
 [<ffffffff86a7b234>] __sk_destruct+0xf4/0x7f0 net/core/sock.c:1423
 [<ffffffff86a87d6c>] sk_destruct+0x4c/0x80 net/core/sock.c:1453
 [<ffffffff86a87dfc>] __sk_free+0x5c/0x230 net/core/sock.c:1461
 [<ffffffff86a87ff8>] sk_free+0x28/0x30 net/core/sock.c:1472
 [<     inline     >] sock_put include/net/sock.h:1591
 [<ffffffff86ca6cd1>] deferred_put_nlk_sk+0x31/0x40 net/netlink/af_netlink.c:652
 [<     inline     >] __rcu_reclaim kernel/rcu/rcu.h:118
 [<ffffffff815cbc9d>] rcu_do_batch.isra.70+0x9ed/0xe20 kernel/rcu/tree.c:2776
 [<     inline     >] invoke_rcu_callbacks kernel/rcu/tree.c:3040
 [<     inline     >] __rcu_process_callbacks kernel/rcu/tree.c:3007
 [<ffffffff815cc55c>] rcu_process_callbacks+0x48c/0xd70 kernel/rcu/tree.c:3024
 [<ffffffff8814d53b>] __do_softirq+0x32b/0xca8 kernel/softirq.c:284
 [<     inline     >] invoke_softirq kernel/softirq.c:364
 [<ffffffff8141a941>] irq_exit+0x1d1/0x210 kernel/softirq.c:405
 [<     inline     >] exiting_irq arch/x86/include/asm/apic.h:659
 [<ffffffff8814ca30>] smp_apic_timer_interrupt+0x80/0xa0
arch/x86/kernel/apic/apic.c:960
 [<ffffffff8814badc>] apic_timer_interrupt+0x8c/0xa0
arch/x86/entry/entry_64.S:489
 <EOI> [  287.580014]  [<ffffffff8155c987>] ? lock_is_held+0x247/0x310
 [<ffffffff814b6bde>] ___might_sleep+0x59e/0x660 kernel/sched/core.c:7729
 [<ffffffff814b6d3a>] __might_sleep+0x9a/0x1a0 kernel/sched/core.c:7720
 [<ffffffff88142d08>] down_read+0x78/0x160 kernel/locking/rwsem.c:21
 [<     inline     >] anon_vma_lock_read include/linux/rmap.h:127
 [<ffffffff81968295>] validate_mm+0xe5/0x880 mm/mmap.c:347
 [<ffffffff8196bf0b>] vma_link+0x11b/0x180 mm/mmap.c:605
 [<ffffffff81977f46>] mmap_region+0x1076/0x1880 mm/mmap.c:1692
 [<ffffffff81978e4f>] do_mmap+0x6ff/0xe80 mm/mmap.c:1450
 [<     inline     >] do_mmap_pgoff include/linux/mm.h:2039
 [<ffffffff818fd527>] vm_mmap_pgoff+0x1b7/0x210 mm/util.c:305
 [<     inline     >] SYSC_mmap_pgoff mm/mmap.c:1500
 [<ffffffff8196f961>] SyS_mmap_pgoff+0x231/0x5e0 mm/mmap.c:1458
 [<     inline     >] SYSC_mmap arch/x86/kernel/sys_x86_64.c:95
 [<ffffffff8124bf4b>] SyS_mmap+0x1b/0x30 arch/x86/kernel/sys_x86_64.c:86
 [<ffffffff88149dc5>] entry_SYSCALL_64_fastpath+0x23/0xc6
