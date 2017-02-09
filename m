From: Dmitry Vyukov <dvyukov@google.com>
Subject: net: SOFTIRQ-safe -> SOFTIRQ-unsafe lock order detected in skb_array_produce
Date: Thu, 9 Feb 2017 09:38:25 +0100
Message-ID: <CACT4Y+bs15VR7xjeYhece+0_X5Ss+5FM0w6jpJH0Dbbdu-+qCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>
To: David Miller <davem@davemloft.net>,
        "Michael S. Tsirkin" <mst@redhat.com>, jasowang@redhat.com,
        Eric Dumazet <edumazet@google.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f49.google.com ([209.85.213.49]:34858 "EHLO
        mail-vk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751675AbdBIIkB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 03:40:01 -0500
Received: by mail-vk0-f49.google.com with SMTP id x75so119226420vke.2
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 00:38:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I've got the following report while running syzkaller fuzzer on mmotm
(git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git)
remotes/mmotm/auto-latest ee4ba7533626ba7bf2f8b992266467ac9fdc045e:

[ INFO: SOFTIRQ-safe -> SOFTIRQ-unsafe lock order detected ]
4.9.0 #7 Not tainted
------------------------------------------------------
syz-executor2/13210 [HC0[0]:SC0[0]:HE0:SE1] is trying to acquire:
 (&(&r->consumer_lock)->rlock){+.+...}, at: [<ffffffff82ded0d7>]
spin_lock include/linux/spinlock.h:302 [inline]
 (&(&r->consumer_lock)->rlock){+.+...}, at: [<ffffffff82ded0d7>]
ptr_ring_consume include/linux/ptr_ring.h:249 [inline]
 (&(&r->consumer_lock)->rlock){+.+...}, at: [<ffffffff82ded0d7>]
__ptr_ring_swap_queue include/linux/ptr_ring.h:360 [inline]
 (&(&r->consumer_lock)->rlock){+.+...}, at: [<ffffffff82ded0d7>]
ptr_ring_resize_multiple include/linux/ptr_ring.h:416 [inline]
 (&(&r->consumer_lock)->rlock){+.+...}, at: [<ffffffff82ded0d7>]
skb_array_resize_multiple include/linux/skb_array.h:168 [inline]
 (&(&r->consumer_lock)->rlock){+.+...}, at: [<ffffffff82ded0d7>]
tun_queue_resize drivers/net/tun.c:2481 [inline]
 (&(&r->consumer_lock)->rlock){+.+...}, at: [<ffffffff82ded0d7>]
tun_device_event+0x897/0xc70 drivers/net/tun.c:2499
and this task is already holding:
 (&(&r->producer_lock)->rlock){+.-...}, at: [<ffffffff82ded014>]
ptr_ring_resize_multiple include/linux/ptr_ring.h:415 [inline]
 (&(&r->producer_lock)->rlock){+.-...}, at: [<ffffffff82ded014>]
skb_array_resize_multiple include/linux/skb_array.h:168 [inline]
 (&(&r->producer_lock)->rlock){+.-...}, at: [<ffffffff82ded014>]
tun_queue_resize drivers/net/tun.c:2481 [inline]
 (&(&r->producer_lock)->rlock){+.-...}, at: [<ffffffff82ded014>]
tun_device_event+0x7d4/0xc70 drivers/net/tun.c:2499
 (&(&r->producer_lock)->rlock){+.-...} -> (&(&r->consumer_lock)->rlock){+.+...}
but this new dependency connects a SOFTIRQ-irq-safe lock:
 (&(&r->producer_lock)->rlock){+.-...}
... which became SOFTIRQ-irq-safe at:
[<ffffffff8156e793>] mark_irqflags kernel/locking/lockdep.c:2923 [inline]
[<ffffffff8156e793>] __lock_acquire+0xd33/0x3430 kernel/locking/lockdep.c:3295
[<ffffffff81571d31>] lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
[<ffffffff843763e3>] __raw_spin_lock
include/linux/spinlock_api_smp.h:144 [inline]
[<ffffffff843763e3>] _raw_spin_lock+0x33/0x50 kernel/locking/spinlock.c:151
[<ffffffff82debb28>] spin_lock include/linux/spinlock.h:302 [inline]
[<ffffffff82debb28>] ptr_ring_produce include/linux/ptr_ring.h:118 [inline]
[<ffffffff82debb28>] skb_array_produce include/linux/skb_array.h:48 [inline]
[<ffffffff82debb28>] tun_net_xmit+0x6d8/0x13f0 drivers/net/tun.c:900
[<ffffffff8358d868>] __netdev_start_xmit include/linux/netdevice.h:4047 [inline]
[<ffffffff8358d868>] netdev_start_xmit include/linux/netdevice.h:4056 [inline]
[<ffffffff8358d868>] xmit_one net/core/dev.c:2914 [inline]
[<ffffffff8358d868>] dev_hard_start_xmit+0x248/0xab0 net/core/dev.c:2930
[<ffffffff8363476f>] sch_direct_xmit+0x31f/0x6d0 net/sched/sch_generic.c:182
[<ffffffff8358f7d8>] __dev_xmit_skb net/core/dev.c:3099 [inline]
[<ffffffff8358f7d8>] __dev_queue_xmit+0x13f8/0x1e70 net/core/dev.c:3359
[<ffffffff83590267>] dev_queue_xmit+0x17/0x20 net/core/dev.c:3424
[<ffffffff835b8009>] neigh_resolve_output+0x6b9/0xb10 net/core/neighbour.c:1307
[<ffffffff83987c1e>] dst_neigh_output include/net/dst.h:464 [inline]
[<ffffffff83987c1e>] ip6_finish_output2+0xabe/0x23a0 net/ipv6/ip6_output.c:121
[<ffffffff83992386>] ip6_finish_output+0x2e6/0x750 net/ipv6/ip6_output.c:139
[<ffffffff839929c2>] NF_HOOK_COND include/linux/netfilter.h:246 [inline]
[<ffffffff839929c2>] ip6_output+0x1d2/0x980 net/ipv6/ip6_output.c:153
[<ffffffff83a26d38>] dst_output include/net/dst.h:501 [inline]
[<ffffffff83a26d38>] NF_HOOK_THRESH.constprop.38+0x118/0x6e0
include/linux/netfilter.h:232
[<ffffffff83a279ed>] NF_HOOK include/linux/netfilter.h:255 [inline]
[<ffffffff83a279ed>] mld_sendpack+0x6ed/0xd10 net/ipv6/mcast.c:1653
[<ffffffff83a29805>] mld_send_cr net/ipv6/mcast.c:1944 [inline]
[<ffffffff83a29805>] mld_ifc_timer_expire+0x3c5/0x750 net/ipv6/mcast.c:2442
[<ffffffff815f5cc1>] call_timer_fn+0x241/0x800 kernel/time/timer.c:1308
[<ffffffff815f8657>] expire_timers kernel/time/timer.c:1348 [inline]
[<ffffffff815f8657>] __run_timers+0x9e7/0xe90 kernel/time/timer.c:1641
[<ffffffff815f8b21>] run_timer_softirq+0x21/0x80 kernel/time/timer.c:1654
[<ffffffff8437abbf>] __do_softirq+0x31f/0xbcd kernel/softirq.c:284
[<ffffffff8143c42c>] invoke_softirq kernel/softirq.c:364 [inline]
[<ffffffff8143c42c>] irq_exit+0x1cc/0x200 kernel/softirq.c:405
[<ffffffff8437a1cb>] exiting_irq arch/x86/include/asm/apic.h:659 [inline]
[<ffffffff8437a1cb>] smp_apic_timer_interrupt+0x7b/0xa0
arch/x86/kernel/apic/apic.c:960
[<ffffffff8437927c>] apic_timer_interrupt+0x8c/0xa0
arch/x86/entry/entry_64.S:709
[<ffffffff843763e3>] __raw_spin_lock
include/linux/spinlock_api_smp.h:144 [inline]
[<ffffffff843763e3>] _raw_spin_lock+0x33/0x50 kernel/locking/spinlock.c:151
[<ffffffff819220d6>] spin_lock include/linux/spinlock.h:302 [inline]
[<ffffffff819220d6>] zap_pte_range mm/memory.c:1138 [inline]
[<ffffffff819220d6>] zap_pmd_range mm/memory.c:1257 [inline]
[<ffffffff819220d6>] zap_pud_range mm/memory.c:1286 [inline]
[<ffffffff819220d6>] unmap_page_range+0xbf6/0x2230 mm/memory.c:1309
[<ffffffff81923958>] unmap_single_vma+0x248/0x460 mm/memory.c:1354
[<ffffffff819248e1>] unmap_vmas+0xf1/0x1b0 mm/memory.c:1384
[<ffffffff8194bc00>] exit_mmap+0x260/0x490 mm/mmap.c:2963
[<ffffffff8141508b>] __mmput kernel/fork.c:864 [inline]
[<ffffffff8141508b>] mmput+0x22b/0x6e0 kernel/fork.c:886
[<ffffffff81a45197>] exec_mmap fs/exec.c:1032 [inline]
[<ffffffff81a45197>] flush_old_exec+0xd57/0x2130 fs/exec.c:1257
[<ffffffff81ba9e7b>] load_elf_binary+0x7eb/0x46b0 fs/binfmt_elf.c:853
[<ffffffff81a43f51>] search_binary_handler+0x141/0x480 fs/exec.c:1582
[<ffffffff81a49b6c>] exec_binprm fs/exec.c:1624 [inline]
[<ffffffff81a49b6c>] do_execveat_common.isra.38+0x180c/0x2350 fs/exec.c:1744
[<ffffffff81a4b122>] do_execve fs/exec.c:1788 [inline]
[<ffffffff81a4b122>] SYSC_execve fs/exec.c:1869 [inline]
[<ffffffff81a4b122>] SyS_execve+0x42/0x50 fs/exec.c:1864
[<ffffffff81009798>] do_syscall_64+0x2e8/0x930 arch/x86/entry/common.c:280
[<ffffffff84377989>] return_from_SYSCALL_64+0x0/0x7a

to a SOFTIRQ-irq-unsafe lock:
 (&(&r->consumer_lock)->rlock){+.+...}
... which became SOFTIRQ-irq-unsafe at:
...
[<ffffffff8156e147>] mark_irqflags kernel/locking/lockdep.c:2941 [inline]
[<ffffffff8156e147>] __lock_acquire+0x6e7/0x3430 kernel/locking/lockdep.c:3295
[<ffffffff81571d31>] lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
[<ffffffff843763e3>] __raw_spin_lock
include/linux/spinlock_api_smp.h:144 [inline]
[<ffffffff843763e3>] _raw_spin_lock+0x33/0x50 kernel/locking/spinlock.c:151
[<ffffffff82ddfb56>] spin_lock include/linux/spinlock.h:302 [inline]
[<ffffffff82ddfb56>] ptr_ring_consume include/linux/ptr_ring.h:249 [inline]
[<ffffffff82ddfb56>] skb_array_consume include/linux/skb_array.h:97 [inline]
[<ffffffff82ddfb56>] tun_queue_purge+0xe6/0x210 drivers/net/tun.c:522
[<ffffffff82de43d6>] __tun_detach+0x6a6/0x1060 drivers/net/tun.c:554
[<ffffffff82de4dd4>] tun_detach drivers/net/tun.c:578 [inline]
[<ffffffff82de4dd4>] tun_chr_close+0x44/0x60 drivers/net/tun.c:2350
[<ffffffff81a34772>] __fput+0x332/0x7f0 fs/file_table.c:208
[<ffffffff81a34cb5>] ____fput+0x15/0x20 fs/file_table.c:244
[<ffffffff814a58ca>] task_work_run+0x18a/0x260 kernel/task_work.c:116
[<ffffffff8142ff8f>] exit_task_work include/linux/task_work.h:21 [inline]
[<ffffffff8142ff8f>] do_exit+0x18ef/0x2890 kernel/exit.c:830
[<ffffffff81435989>] do_group_exit+0x149/0x420 kernel/exit.c:934
[<ffffffff81465120>] get_signal+0x7e0/0x1820 kernel/signal.c:2307
[<ffffffff812665a2>] do_signal+0xd2/0x2120 arch/x86/kernel/signal.c:807
[<ffffffff81007900>] exit_to_usermode_loop+0x200/0x2a0
arch/x86/entry/common.c:156
[<ffffffff81009413>] prepare_exit_to_usermode
arch/x86/entry/common.c:190 [inline]
[<ffffffff81009413>] syscall_return_slowpath+0x4d3/0x570
arch/x86/entry/common.c:259
[<ffffffff84377962>] entry_SYSCALL_64_fastpath+0xc0/0xc2

other info that might help us debug this:

 Possible interrupt unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock(&(&r->consumer_lock)->rlock);
                               local_irq_disable();
                               lock(&(&r->producer_lock)->rlock);
                               lock(&(&r->consumer_lock)->rlock);
  <Interrupt>
    lock(&(&r->producer_lock)->rlock);

 *** DEADLOCK ***

2 locks held by syz-executor2/13210:
 #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff835cab2b>] rtnl_lock
net/core/rtnetlink.c:70 [inline]
 #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff835cab2b>]
rtnetlink_rcv+0x1b/0x40 net/core/rtnetlink.c:4039
 #1:  (&(&r->producer_lock)->rlock){+.-...}, at: [<ffffffff82ded014>]
ptr_ring_resize_multiple include/linux/ptr_ring.h:415 [inline]
 #1:  (&(&r->producer_lock)->rlock){+.-...}, at: [<ffffffff82ded014>]
skb_array_resize_multiple include/linux/skb_array.h:168 [inline]
 #1:  (&(&r->producer_lock)->rlock){+.-...}, at: [<ffffffff82ded014>]
tun_queue_resize drivers/net/tun.c:2481 [inline]
 #1:  (&(&r->producer_lock)->rlock){+.-...}, at: [<ffffffff82ded014>]
tun_device_event+0x7d4/0xc70 drivers/net/tun.c:2499

the dependencies between SOFTIRQ-irq-safe lock and the holding lock:
-> (&(&r->producer_lock)->rlock){+.-...} ops: 137 {
   HARDIRQ-ON-W at:
[<ffffffff8156e0ec>] mark_irqflags kernel/locking/lockdep.c:2937 [inline]
[<ffffffff8156e0ec>] __lock_acquire+0x68c/0x3430 kernel/locking/lockdep.c:3295
[<ffffffff81571d31>] lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
[<ffffffff843763e3>] __raw_spin_lock
include/linux/spinlock_api_smp.h:144 [inline]
[<ffffffff843763e3>] _raw_spin_lock+0x33/0x50 kernel/locking/spinlock.c:151
[<ffffffff82debb28>] spin_lock include/linux/spinlock.h:302 [inline]
[<ffffffff82debb28>] ptr_ring_produce include/linux/ptr_ring.h:118 [inline]
[<ffffffff82debb28>] skb_array_produce include/linux/skb_array.h:48 [inline]
[<ffffffff82debb28>] tun_net_xmit+0x6d8/0x13f0 drivers/net/tun.c:900
[<ffffffff8358d868>] __netdev_start_xmit include/linux/netdevice.h:4047 [inline]
[<ffffffff8358d868>] netdev_start_xmit include/linux/netdevice.h:4056 [inline]
[<ffffffff8358d868>] xmit_one net/core/dev.c:2914 [inline]
[<ffffffff8358d868>] dev_hard_start_xmit+0x248/0xab0 net/core/dev.c:2930
[<ffffffff8363476f>] sch_direct_xmit+0x31f/0x6d0 net/sched/sch_generic.c:182
[<ffffffff8358f7d8>] __dev_xmit_skb net/core/dev.c:3099 [inline]
[<ffffffff8358f7d8>] __dev_queue_xmit+0x13f8/0x1e70 net/core/dev.c:3359
[<ffffffff83590267>] dev_queue_xmit+0x17/0x20 net/core/dev.c:3424
[<ffffffff835b8009>] neigh_resolve_output+0x6b9/0xb10 net/core/neighbour.c:1307
[<ffffffff83987c1e>] dst_neigh_output include/net/dst.h:464 [inline]
[<ffffffff83987c1e>] ip6_finish_output2+0xabe/0x23a0 net/ipv6/ip6_output.c:121
[<ffffffff83992386>] ip6_finish_output+0x2e6/0x750 net/ipv6/ip6_output.c:139
[<ffffffff839929c2>] NF_HOOK_COND include/linux/netfilter.h:246 [inline]
[<ffffffff839929c2>] ip6_output+0x1d2/0x980 net/ipv6/ip6_output.c:153
[<ffffffff83a26d38>] dst_output include/net/dst.h:501 [inline]
[<ffffffff83a26d38>] NF_HOOK_THRESH.constprop.38+0x118/0x6e0
include/linux/netfilter.h:232
[<ffffffff83a279ed>] NF_HOOK include/linux/netfilter.h:255 [inline]
[<ffffffff83a279ed>] mld_sendpack+0x6ed/0xd10 net/ipv6/mcast.c:1653
[<ffffffff83a29805>] mld_send_cr net/ipv6/mcast.c:1944 [inline]
[<ffffffff83a29805>] mld_ifc_timer_expire+0x3c5/0x750 net/ipv6/mcast.c:2442
[<ffffffff815f5cc1>] call_timer_fn+0x241/0x800 kernel/time/timer.c:1308
[<ffffffff815f8657>] expire_timers kernel/time/timer.c:1348 [inline]
[<ffffffff815f8657>] __run_timers+0x9e7/0xe90 kernel/time/timer.c:1641
[<ffffffff815f8b21>] run_timer_softirq+0x21/0x80 kernel/time/timer.c:1654
[<ffffffff8437abbf>] __do_softirq+0x31f/0xbcd kernel/softirq.c:284
[<ffffffff8143c42c>] invoke_softirq kernel/softirq.c:364 [inline]
[<ffffffff8143c42c>] irq_exit+0x1cc/0x200 kernel/softirq.c:405
[<ffffffff8437a1cb>] exiting_irq arch/x86/include/asm/apic.h:659 [inline]
[<ffffffff8437a1cb>] smp_apic_timer_interrupt+0x7b/0xa0
arch/x86/kernel/apic/apic.c:960
[<ffffffff8437927c>] apic_timer_interrupt+0x8c/0xa0
arch/x86/entry/entry_64.S:709
[<ffffffff843763e3>] __raw_spin_lock
include/linux/spinlock_api_smp.h:144 [inline]
[<ffffffff843763e3>] _raw_spin_lock+0x33/0x50 kernel/locking/spinlock.c:151
[<ffffffff819220d6>] spin_lock include/linux/spinlock.h:302 [inline]
[<ffffffff819220d6>] zap_pte_range mm/memory.c:1138 [inline]
[<ffffffff819220d6>] zap_pmd_range mm/memory.c:1257 [inline]
[<ffffffff819220d6>] zap_pud_range mm/memory.c:1286 [inline]
[<ffffffff819220d6>] unmap_page_range+0xbf6/0x2230 mm/memory.c:1309
[<ffffffff81923958>] unmap_single_vma+0x248/0x460 mm/memory.c:1354
[<ffffffff819248e1>] unmap_vmas+0xf1/0x1b0 mm/memory.c:1384
[<ffffffff8194bc00>] exit_mmap+0x260/0x490 mm/mmap.c:2963
[<ffffffff8141508b>] __mmput kernel/fork.c:864 [inline]
[<ffffffff8141508b>] mmput+0x22b/0x6e0 kernel/fork.c:886
[<ffffffff81a45197>] exec_mmap fs/exec.c:1032 [inline]
[<ffffffff81a45197>] flush_old_exec+0xd57/0x2130 fs/exec.c:1257
[<ffffffff81ba9e7b>] load_elf_binary+0x7eb/0x46b0 fs/binfmt_elf.c:853
[<ffffffff81a43f51>] search_binary_handler+0x141/0x480 fs/exec.c:1582
[<ffffffff81a49b6c>] exec_binprm fs/exec.c:1624 [inline]
[<ffffffff81a49b6c>] do_execveat_common.isra.38+0x180c/0x2350 fs/exec.c:1744
[<ffffffff81a4b122>] do_execve fs/exec.c:1788 [inline]
[<ffffffff81a4b122>] SYSC_execve fs/exec.c:1869 [inline]
[<ffffffff81a4b122>] SyS_execve+0x42/0x50 fs/exec.c:1864
[<ffffffff81009798>] do_syscall_64+0x2e8/0x930 arch/x86/entry/common.c:280
[<ffffffff84377989>] return_from_SYSCALL_64+0x0/0x7a
   IN-SOFTIRQ-W at:
[<ffffffff8156e793>] mark_irqflags kernel/locking/lockdep.c:2923 [inline]
[<ffffffff8156e793>] __lock_acquire+0xd33/0x3430 kernel/locking/lockdep.c:3295
[<ffffffff81571d31>] lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
[<ffffffff843763e3>] __raw_spin_lock
include/linux/spinlock_api_smp.h:144 [inline]
[<ffffffff843763e3>] _raw_spin_lock+0x33/0x50 kernel/locking/spinlock.c:151
[<ffffffff82debb28>] spin_lock include/linux/spinlock.h:302 [inline]
[<ffffffff82debb28>] ptr_ring_produce include/linux/ptr_ring.h:118 [inline]
[<ffffffff82debb28>] skb_array_produce include/linux/skb_array.h:48 [inline]
[<ffffffff82debb28>] tun_net_xmit+0x6d8/0x13f0 drivers/net/tun.c:900
[<ffffffff8358d868>] __netdev_start_xmit include/linux/netdevice.h:4047 [inline]
[<ffffffff8358d868>] netdev_start_xmit include/linux/netdevice.h:4056 [inline]
[<ffffffff8358d868>] xmit_one net/core/dev.c:2914 [inline]
[<ffffffff8358d868>] dev_hard_start_xmit+0x248/0xab0 net/core/dev.c:2930
[<ffffffff8363476f>] sch_direct_xmit+0x31f/0x6d0 net/sched/sch_generic.c:182
[<ffffffff8358f7d8>] __dev_xmit_skb net/core/dev.c:3099 [inline]
[<ffffffff8358f7d8>] __dev_queue_xmit+0x13f8/0x1e70 net/core/dev.c:3359
[<ffffffff83590267>] dev_queue_xmit+0x17/0x20 net/core/dev.c:3424
[<ffffffff835b8009>] neigh_resolve_output+0x6b9/0xb10 net/core/neighbour.c:1307
[<ffffffff83987c1e>] dst_neigh_output include/net/dst.h:464 [inline]
[<ffffffff83987c1e>] ip6_finish_output2+0xabe/0x23a0 net/ipv6/ip6_output.c:121
[<ffffffff83992386>] ip6_finish_output+0x2e6/0x750 net/ipv6/ip6_output.c:139
[<ffffffff839929c2>] NF_HOOK_COND include/linux/netfilter.h:246 [inline]
[<ffffffff839929c2>] ip6_output+0x1d2/0x980 net/ipv6/ip6_output.c:153
[<ffffffff83a26d38>] dst_output include/net/dst.h:501 [inline]
[<ffffffff83a26d38>] NF_HOOK_THRESH.constprop.38+0x118/0x6e0
include/linux/netfilter.h:232
[<ffffffff83a279ed>] NF_HOOK include/linux/netfilter.h:255 [inline]
[<ffffffff83a279ed>] mld_sendpack+0x6ed/0xd10 net/ipv6/mcast.c:1653
[<ffffffff83a29805>] mld_send_cr net/ipv6/mcast.c:1944 [inline]
[<ffffffff83a29805>] mld_ifc_timer_expire+0x3c5/0x750 net/ipv6/mcast.c:2442
[<ffffffff815f5cc1>] call_timer_fn+0x241/0x800 kernel/time/timer.c:1308
[<ffffffff815f8657>] expire_timers kernel/time/timer.c:1348 [inline]
[<ffffffff815f8657>] __run_timers+0x9e7/0xe90 kernel/time/timer.c:1641
[<ffffffff815f8b21>] run_timer_softirq+0x21/0x80 kernel/time/timer.c:1654
[<ffffffff8437abbf>] __do_softirq+0x31f/0xbcd kernel/softirq.c:284
[<ffffffff8143c42c>] invoke_softirq kernel/softirq.c:364 [inline]
[<ffffffff8143c42c>] irq_exit+0x1cc/0x200 kernel/softirq.c:405
[<ffffffff8437a1cb>] exiting_irq arch/x86/include/asm/apic.h:659 [inline]
[<ffffffff8437a1cb>] smp_apic_timer_interrupt+0x7b/0xa0
arch/x86/kernel/apic/apic.c:960
[<ffffffff8437927c>] apic_timer_interrupt+0x8c/0xa0
arch/x86/entry/entry_64.S:709
[<ffffffff843763e3>] __raw_spin_lock
include/linux/spinlock_api_smp.h:144 [inline]
[<ffffffff843763e3>] _raw_spin_lock+0x33/0x50 kernel/locking/spinlock.c:151
[<ffffffff819220d6>] spin_lock include/linux/spinlock.h:302 [inline]
[<ffffffff819220d6>] zap_pte_range mm/memory.c:1138 [inline]
[<ffffffff819220d6>] zap_pmd_range mm/memory.c:1257 [inline]
[<ffffffff819220d6>] zap_pud_range mm/memory.c:1286 [inline]
[<ffffffff819220d6>] unmap_page_range+0xbf6/0x2230 mm/memory.c:1309
[<ffffffff81923958>] unmap_single_vma+0x248/0x460 mm/memory.c:1354
[<ffffffff819248e1>] unmap_vmas+0xf1/0x1b0 mm/memory.c:1384
[<ffffffff8194bc00>] exit_mmap+0x260/0x490 mm/mmap.c:2963
[<ffffffff8141508b>] __mmput kernel/fork.c:864 [inline]
[<ffffffff8141508b>] mmput+0x22b/0x6e0 kernel/fork.c:886
[<ffffffff81a45197>] exec_mmap fs/exec.c:1032 [inline]
[<ffffffff81a45197>] flush_old_exec+0xd57/0x2130 fs/exec.c:1257
[<ffffffff81ba9e7b>] load_elf_binary+0x7eb/0x46b0 fs/binfmt_elf.c:853
[<ffffffff81a43f51>] search_binary_handler+0x141/0x480 fs/exec.c:1582
[<ffffffff81a49b6c>] exec_binprm fs/exec.c:1624 [inline]
[<ffffffff81a49b6c>] do_execveat_common.isra.38+0x180c/0x2350 fs/exec.c:1744
[<ffffffff81a4b122>] do_execve fs/exec.c:1788 [inline]
[<ffffffff81a4b122>] SYSC_execve fs/exec.c:1869 [inline]
[<ffffffff81a4b122>] SyS_execve+0x42/0x50 fs/exec.c:1864
[<ffffffff81009798>] do_syscall_64+0x2e8/0x930 arch/x86/entry/common.c:280
[<ffffffff84377989>] return_from_SYSCALL_64+0x0/0x7a
   INITIAL USE at:
[<ffffffff8156e1d7>] __lock_acquire+0x777/0x3430 kernel/locking/lockdep.c:3299
[<ffffffff81571d31>] lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
[<ffffffff843763e3>] __raw_spin_lock
include/linux/spinlock_api_smp.h:144 [inline]
[<ffffffff843763e3>] _raw_spin_lock+0x33/0x50 kernel/locking/spinlock.c:151
[<ffffffff82debb28>] spin_lock include/linux/spinlock.h:302 [inline]
[<ffffffff82debb28>] ptr_ring_produce include/linux/ptr_ring.h:118 [inline]
[<ffffffff82debb28>] skb_array_produce include/linux/skb_array.h:48 [inline]
[<ffffffff82debb28>] tun_net_xmit+0x6d8/0x13f0 drivers/net/tun.c:900
[<ffffffff8358d868>] __netdev_start_xmit include/linux/netdevice.h:4047 [inline]
[<ffffffff8358d868>] netdev_start_xmit include/linux/netdevice.h:4056 [inline]
[<ffffffff8358d868>] xmit_one net/core/dev.c:2914 [inline]
[<ffffffff8358d868>] dev_hard_start_xmit+0x248/0xab0 net/core/dev.c:2930
[<ffffffff8363476f>] sch_direct_xmit+0x31f/0x6d0 net/sched/sch_generic.c:182
[<ffffffff8358f7d8>] __dev_xmit_skb net/core/dev.c:3099 [inline]
[<ffffffff8358f7d8>] __dev_queue_xmit+0x13f8/0x1e70 net/core/dev.c:3359
[<ffffffff83590267>] dev_queue_xmit+0x17/0x20 net/core/dev.c:3424
[<ffffffff835b8009>] neigh_resolve_output+0x6b9/0xb10 net/core/neighbour.c:1307
[<ffffffff83987c1e>] dst_neigh_output include/net/dst.h:464 [inline]
[<ffffffff83987c1e>] ip6_finish_output2+0xabe/0x23a0 net/ipv6/ip6_output.c:121
[<ffffffff83992386>] ip6_finish_output+0x2e6/0x750 net/ipv6/ip6_output.c:139
[<ffffffff839929c2>] NF_HOOK_COND include/linux/netfilter.h:246 [inline]
[<ffffffff839929c2>] ip6_output+0x1d2/0x980 net/ipv6/ip6_output.c:153
[<ffffffff83a26d38>] dst_output include/net/dst.h:501 [inline]
[<ffffffff83a26d38>] NF_HOOK_THRESH.constprop.38+0x118/0x6e0
include/linux/netfilter.h:232
[<ffffffff83a279ed>] NF_HOOK include/linux/netfilter.h:255 [inline]
[<ffffffff83a279ed>] mld_sendpack+0x6ed/0xd10 net/ipv6/mcast.c:1653
[<ffffffff83a29805>] mld_send_cr net/ipv6/mcast.c:1944 [inline]
[<ffffffff83a29805>] mld_ifc_timer_expire+0x3c5/0x750 net/ipv6/mcast.c:2442
[<ffffffff815f5cc1>] call_timer_fn+0x241/0x800 kernel/time/timer.c:1308
[<ffffffff815f8657>] expire_timers kernel/time/timer.c:1348 [inline]
[<ffffffff815f8657>] __run_timers+0x9e7/0xe90 kernel/time/timer.c:1641
[<ffffffff815f8b21>] run_timer_softirq+0x21/0x80 kernel/time/timer.c:1654
[<ffffffff8437abbf>] __do_softirq+0x31f/0xbcd kernel/softirq.c:284
[<ffffffff8143c42c>] invoke_softirq kernel/softirq.c:364 [inline]
[<ffffffff8143c42c>] irq_exit+0x1cc/0x200 kernel/softirq.c:405
[<ffffffff8437a1cb>] exiting_irq arch/x86/include/asm/apic.h:659 [inline]
[<ffffffff8437a1cb>] smp_apic_timer_interrupt+0x7b/0xa0
arch/x86/kernel/apic/apic.c:960
[<ffffffff8437927c>] apic_timer_interrupt+0x8c/0xa0
arch/x86/entry/entry_64.S:709
[<ffffffff843763e3>] __raw_spin_lock
include/linux/spinlock_api_smp.h:144 [inline]
[<ffffffff843763e3>] _raw_spin_lock+0x33/0x50 kernel/locking/spinlock.c:151
[<ffffffff819220d6>] spin_lock include/linux/spinlock.h:302 [inline]
[<ffffffff819220d6>] zap_pte_range mm/memory.c:1138 [inline]
[<ffffffff819220d6>] zap_pmd_range mm/memory.c:1257 [inline]
[<ffffffff819220d6>] zap_pud_range mm/memory.c:1286 [inline]
[<ffffffff819220d6>] unmap_page_range+0xbf6/0x2230 mm/memory.c:1309
[<ffffffff81923958>] unmap_single_vma+0x248/0x460 mm/memory.c:1354
[<ffffffff819248e1>] unmap_vmas+0xf1/0x1b0 mm/memory.c:1384
[<ffffffff8194bc00>] exit_mmap+0x260/0x490 mm/mmap.c:2963
[<ffffffff8141508b>] __mmput kernel/fork.c:864 [inline]
[<ffffffff8141508b>] mmput+0x22b/0x6e0 kernel/fork.c:886
[<ffffffff81a45197>] exec_mmap fs/exec.c:1032 [inline]
[<ffffffff81a45197>] flush_old_exec+0xd57/0x2130 fs/exec.c:1257
[<ffffffff81ba9e7b>] load_elf_binary+0x7eb/0x46b0 fs/binfmt_elf.c:853
[<ffffffff81a43f51>] search_binary_handler+0x141/0x480 fs/exec.c:1582
[<ffffffff81a49b6c>] exec_binprm fs/exec.c:1624 [inline]
[<ffffffff81a49b6c>] do_execveat_common.isra.38+0x180c/0x2350 fs/exec.c:1744
[<ffffffff81a4b122>] do_execve fs/exec.c:1788 [inline]
[<ffffffff81a4b122>] SYSC_execve fs/exec.c:1869 [inline]
[<ffffffff81a4b122>] SyS_execve+0x42/0x50 fs/exec.c:1864
[<ffffffff81009798>] do_syscall_64+0x2e8/0x930 arch/x86/entry/common.c:280
[<ffffffff84377989>] return_from_SYSCALL_64+0x0/0x7a
 }
 ... key      at: [<ffffffff86df6480>] __key.54766+0x0/0x40
 ... acquired at:
[<ffffffff81568be5>] check_irq_usage+0x65/0xe0 kernel/locking/lockdep.c:1624
[<ffffffff81569392>] check_prev_add_irq
kernel/locking/lockdep_states.h:8 [inline]
[<ffffffff81569392>] check_prev_add kernel/locking/lockdep.c:1832 [inline]
[<ffffffff81569392>] check_prevs_add+0x732/0x1c00 kernel/locking/lockdep.c:1938
[<ffffffff8156fba9>] validate_chain kernel/locking/lockdep.c:2265 [inline]
[<ffffffff8156fba9>] __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3338
[<ffffffff81571d31>] lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
[<ffffffff843763e3>] __raw_spin_lock
include/linux/spinlock_api_smp.h:144 [inline]
[<ffffffff843763e3>] _raw_spin_lock+0x33/0x50 kernel/locking/spinlock.c:151
[<ffffffff82ded0d7>] spin_lock include/linux/spinlock.h:302 [inline]
[<ffffffff82ded0d7>] ptr_ring_consume include/linux/ptr_ring.h:249 [inline]
[<ffffffff82ded0d7>] __ptr_ring_swap_queue include/linux/ptr_ring.h:360 [inline]
[<ffffffff82ded0d7>] ptr_ring_resize_multiple
include/linux/ptr_ring.h:416 [inline]
[<ffffffff82ded0d7>] skb_array_resize_multiple
include/linux/skb_array.h:168 [inline]
[<ffffffff82ded0d7>] tun_queue_resize drivers/net/tun.c:2481 [inline]
[<ffffffff82ded0d7>] tun_device_event+0x897/0xc70 drivers/net/tun.c:2499
[<ffffffff814b2745>] notifier_call_chain+0x1b5/0x2b0 kernel/notifier.c:93
[<ffffffff814b2f6d>] __raw_notifier_call_chain kernel/notifier.c:394 [inline]
[<ffffffff814b2f6d>] raw_notifier_call_chain+0x2d/0x40 kernel/notifier.c:401
[<ffffffff835626a1>] call_netdevice_notifiers_info+0x51/0x90 net/core/dev.c:1645
[<ffffffff83562768>] call_netdevice_notifiers+0x88/0xc0 net/core/dev.c:1661
[<ffffffff835cced4>] do_setlink+0xfa4/0x3d30 net/core/rtnetlink.c:2042
[<ffffffff835cfed2>] rtnl_setlink+0x272/0x3f0 net/core/rtnetlink.c:2235
[<ffffffff835df9b9>] rtnetlink_rcv_msg+0x609/0x860 net/core/rtnetlink.c:4034
[<ffffffff83673a4b>] netlink_rcv_skb+0x2ab/0x390 net/netlink/af_netlink.c:2298
[<ffffffff835cab3a>] rtnetlink_rcv+0x2a/0x40 net/core/rtnetlink.c:4040
[<ffffffff83672294>] netlink_unicast_kernel
net/netlink/af_netlink.c:1231 [inline]
[<ffffffff83672294>] netlink_unicast+0x514/0x730 net/netlink/af_netlink.c:1257
[<ffffffff83672f46>] netlink_sendmsg+0xa96/0xe50 net/netlink/af_netlink.c:1803
[<ffffffff834f6aaa>] sock_sendmsg_nosec net/socket.c:621 [inline]
[<ffffffff834f6aaa>] sock_sendmsg+0xca/0x110 net/socket.c:631
[<ffffffff834f6e16>] sock_write_iter+0x326/0x600 net/socket.c:829
[<ffffffff81a2c4b3>] do_iter_readv_writev+0x2e3/0x5b0 fs/read_write.c:695
[<ffffffff81a2edbc>] do_readv_writev+0x42c/0x9b0 fs/read_write.c:872
[<ffffffff81a2f8d7>] vfs_writev+0x87/0xc0 fs/read_write.c:911
[<ffffffff81a2fa20>] do_writev+0x110/0x2c0 fs/read_write.c:944
[<ffffffff81a330e7>] SYSC_writev fs/read_write.c:1017 [inline]
[<ffffffff81a330e7>] SyS_writev+0x27/0x30 fs/read_write.c:1014
[<ffffffff843778c1>] entry_SYSCALL_64_fastpath+0x1f/0xc2


the dependencies between the lock to be acquired
 and SOFTIRQ-irq-unsafe lock:
-> (&(&r->consumer_lock)->rlock){+.+...} ops: 302 {
   HARDIRQ-ON-W at:
[<ffffffff8156e0ec>] mark_irqflags kernel/locking/lockdep.c:2937 [inline]
[<ffffffff8156e0ec>] __lock_acquire+0x68c/0x3430 kernel/locking/lockdep.c:3295
[<ffffffff81571d31>] lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
[<ffffffff843763e3>] __raw_spin_lock
include/linux/spinlock_api_smp.h:144 [inline]
[<ffffffff843763e3>] _raw_spin_lock+0x33/0x50 kernel/locking/spinlock.c:151
[<ffffffff82ddfb56>] spin_lock include/linux/spinlock.h:302 [inline]
[<ffffffff82ddfb56>] ptr_ring_consume include/linux/ptr_ring.h:249 [inline]
[<ffffffff82ddfb56>] skb_array_consume include/linux/skb_array.h:97 [inline]
[<ffffffff82ddfb56>] tun_queue_purge+0xe6/0x210 drivers/net/tun.c:522
[<ffffffff82de43d6>] __tun_detach+0x6a6/0x1060 drivers/net/tun.c:554
[<ffffffff82de4dd4>] tun_detach drivers/net/tun.c:578 [inline]
[<ffffffff82de4dd4>] tun_chr_close+0x44/0x60 drivers/net/tun.c:2350
[<ffffffff81a34772>] __fput+0x332/0x7f0 fs/file_table.c:208
[<ffffffff81a34cb5>] ____fput+0x15/0x20 fs/file_table.c:244
[<ffffffff814a58ca>] task_work_run+0x18a/0x260 kernel/task_work.c:116
[<ffffffff8142ff8f>] exit_task_work include/linux/task_work.h:21 [inline]
[<ffffffff8142ff8f>] do_exit+0x18ef/0x2890 kernel/exit.c:830
[<ffffffff81435989>] do_group_exit+0x149/0x420 kernel/exit.c:934
[<ffffffff81465120>] get_signal+0x7e0/0x1820 kernel/signal.c:2307
[<ffffffff812665a2>] do_signal+0xd2/0x2120 arch/x86/kernel/signal.c:807
[<ffffffff81007900>] exit_to_usermode_loop+0x200/0x2a0
arch/x86/entry/common.c:156
[<ffffffff81009413>] prepare_exit_to_usermode
arch/x86/entry/common.c:190 [inline]
[<ffffffff81009413>] syscall_return_slowpath+0x4d3/0x570
arch/x86/entry/common.c:259
[<ffffffff84377962>] entry_SYSCALL_64_fastpath+0xc0/0xc2
   SOFTIRQ-ON-W at:
[<ffffffff8156e147>] mark_irqflags kernel/locking/lockdep.c:2941 [inline]
[<ffffffff8156e147>] __lock_acquire+0x6e7/0x3430 kernel/locking/lockdep.c:3295
[<ffffffff81571d31>] lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
[<ffffffff843763e3>] __raw_spin_lock
include/linux/spinlock_api_smp.h:144 [inline]
[<ffffffff843763e3>] _raw_spin_lock+0x33/0x50 kernel/locking/spinlock.c:151
[<ffffffff82ddfb56>] spin_lock include/linux/spinlock.h:302 [inline]
[<ffffffff82ddfb56>] ptr_ring_consume include/linux/ptr_ring.h:249 [inline]
[<ffffffff82ddfb56>] skb_array_consume include/linux/skb_array.h:97 [inline]
[<ffffffff82ddfb56>] tun_queue_purge+0xe6/0x210 drivers/net/tun.c:522
[<ffffffff82de43d6>] __tun_detach+0x6a6/0x1060 drivers/net/tun.c:554
[<ffffffff82de4dd4>] tun_detach drivers/net/tun.c:578 [inline]
[<ffffffff82de4dd4>] tun_chr_close+0x44/0x60 drivers/net/tun.c:2350
[<ffffffff81a34772>] __fput+0x332/0x7f0 fs/file_table.c:208
[<ffffffff81a34cb5>] ____fput+0x15/0x20 fs/file_table.c:244
[<ffffffff814a58ca>] task_work_run+0x18a/0x260 kernel/task_work.c:116
[<ffffffff8142ff8f>] exit_task_work include/linux/task_work.h:21 [inline]
[<ffffffff8142ff8f>] do_exit+0x18ef/0x2890 kernel/exit.c:830
[<ffffffff81435989>] do_group_exit+0x149/0x420 kernel/exit.c:934
[<ffffffff81465120>] get_signal+0x7e0/0x1820 kernel/signal.c:2307
[<ffffffff812665a2>] do_signal+0xd2/0x2120 arch/x86/kernel/signal.c:807
[<ffffffff81007900>] exit_to_usermode_loop+0x200/0x2a0
arch/x86/entry/common.c:156
[<ffffffff81009413>] prepare_exit_to_usermode
arch/x86/entry/common.c:190 [inline]
[<ffffffff81009413>] syscall_return_slowpath+0x4d3/0x570
arch/x86/entry/common.c:259
[<ffffffff84377962>] entry_SYSCALL_64_fastpath+0xc0/0xc2
   INITIAL USE at:
[<ffffffff8156e1d7>] __lock_acquire+0x777/0x3430 kernel/locking/lockdep.c:3299
[<ffffffff81571d31>] lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
[<ffffffff843763e3>] __raw_spin_lock
include/linux/spinlock_api_smp.h:144 [inline]
[<ffffffff843763e3>] _raw_spin_lock+0x33/0x50 kernel/locking/spinlock.c:151
[<ffffffff82ddfb56>] spin_lock include/linux/spinlock.h:302 [inline]
[<ffffffff82ddfb56>] ptr_ring_consume include/linux/ptr_ring.h:249 [inline]
[<ffffffff82ddfb56>] skb_array_consume include/linux/skb_array.h:97 [inline]
[<ffffffff82ddfb56>] tun_queue_purge+0xe6/0x210 drivers/net/tun.c:522
[<ffffffff82de43d6>] __tun_detach+0x6a6/0x1060 drivers/net/tun.c:554
[<ffffffff82de4dd4>] tun_detach drivers/net/tun.c:578 [inline]
[<ffffffff82de4dd4>] tun_chr_close+0x44/0x60 drivers/net/tun.c:2350
[<ffffffff81a34772>] __fput+0x332/0x7f0 fs/file_table.c:208
[<ffffffff81a34cb5>] ____fput+0x15/0x20 fs/file_table.c:244
[<ffffffff814a58ca>] task_work_run+0x18a/0x260 kernel/task_work.c:116
[<ffffffff8142ff8f>] exit_task_work include/linux/task_work.h:21 [inline]
[<ffffffff8142ff8f>] do_exit+0x18ef/0x2890 kernel/exit.c:830
[<ffffffff81435989>] do_group_exit+0x149/0x420 kernel/exit.c:934
[<ffffffff81465120>] get_signal+0x7e0/0x1820 kernel/signal.c:2307
[<ffffffff812665a2>] do_signal+0xd2/0x2120 arch/x86/kernel/signal.c:807
[<ffffffff81007900>] exit_to_usermode_loop+0x200/0x2a0
arch/x86/entry/common.c:156
[<ffffffff81009413>] prepare_exit_to_usermode
arch/x86/entry/common.c:190 [inline]
[<ffffffff81009413>] syscall_return_slowpath+0x4d3/0x570
arch/x86/entry/common.c:259
[<ffffffff84377962>] entry_SYSCALL_64_fastpath+0xc0/0xc2
 }
 ... key      at: [<ffffffff86df6440>] __key.54767+0x0/0x40
 ... acquired at:
[<ffffffff81568be5>] check_irq_usage+0x65/0xe0 kernel/locking/lockdep.c:1624
[<ffffffff81569392>] check_prev_add_irq
kernel/locking/lockdep_states.h:8 [inline]
[<ffffffff81569392>] check_prev_add kernel/locking/lockdep.c:1832 [inline]
[<ffffffff81569392>] check_prevs_add+0x732/0x1c00 kernel/locking/lockdep.c:1938
[<ffffffff8156fba9>] validate_chain kernel/locking/lockdep.c:2265 [inline]
[<ffffffff8156fba9>] __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3338
[<ffffffff81571d31>] lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
[<ffffffff843763e3>] __raw_spin_lock
include/linux/spinlock_api_smp.h:144 [inline]
[<ffffffff843763e3>] _raw_spin_lock+0x33/0x50 kernel/locking/spinlock.c:151
[<ffffffff82ded0d7>] spin_lock include/linux/spinlock.h:302 [inline]
[<ffffffff82ded0d7>] ptr_ring_consume include/linux/ptr_ring.h:249 [inline]
[<ffffffff82ded0d7>] __ptr_ring_swap_queue include/linux/ptr_ring.h:360 [inline]
[<ffffffff82ded0d7>] ptr_ring_resize_multiple
include/linux/ptr_ring.h:416 [inline]
[<ffffffff82ded0d7>] skb_array_resize_multiple
include/linux/skb_array.h:168 [inline]
[<ffffffff82ded0d7>] tun_queue_resize drivers/net/tun.c:2481 [inline]
[<ffffffff82ded0d7>] tun_device_event+0x897/0xc70 drivers/net/tun.c:2499
[<ffffffff814b2745>] notifier_call_chain+0x1b5/0x2b0 kernel/notifier.c:93
[<ffffffff814b2f6d>] __raw_notifier_call_chain kernel/notifier.c:394 [inline]
[<ffffffff814b2f6d>] raw_notifier_call_chain+0x2d/0x40 kernel/notifier.c:401
[<ffffffff835626a1>] call_netdevice_notifiers_info+0x51/0x90 net/core/dev.c:1645
[<ffffffff83562768>] call_netdevice_notifiers+0x88/0xc0 net/core/dev.c:1661
[<ffffffff835cced4>] do_setlink+0xfa4/0x3d30 net/core/rtnetlink.c:2042
[<ffffffff835cfed2>] rtnl_setlink+0x272/0x3f0 net/core/rtnetlink.c:2235
[<ffffffff835df9b9>] rtnetlink_rcv_msg+0x609/0x860 net/core/rtnetlink.c:4034
[<ffffffff83673a4b>] netlink_rcv_skb+0x2ab/0x390 net/netlink/af_netlink.c:2298
[<ffffffff835cab3a>] rtnetlink_rcv+0x2a/0x40 net/core/rtnetlink.c:4040
[<ffffffff83672294>] netlink_unicast_kernel
net/netlink/af_netlink.c:1231 [inline]
[<ffffffff83672294>] netlink_unicast+0x514/0x730 net/netlink/af_netlink.c:1257
[<ffffffff83672f46>] netlink_sendmsg+0xa96/0xe50 net/netlink/af_netlink.c:1803
[<ffffffff834f6aaa>] sock_sendmsg_nosec net/socket.c:621 [inline]
[<ffffffff834f6aaa>] sock_sendmsg+0xca/0x110 net/socket.c:631
[<ffffffff834f6e16>] sock_write_iter+0x326/0x600 net/socket.c:829
[<ffffffff81a2c4b3>] do_iter_readv_writev+0x2e3/0x5b0 fs/read_write.c:695
[<ffffffff81a2edbc>] do_readv_writev+0x42c/0x9b0 fs/read_write.c:872
[<ffffffff81a2f8d7>] vfs_writev+0x87/0xc0 fs/read_write.c:911
[<ffffffff81a2fa20>] do_writev+0x110/0x2c0 fs/read_write.c:944
[<ffffffff81a330e7>] SYSC_writev fs/read_write.c:1017 [inline]
[<ffffffff81a330e7>] SyS_writev+0x27/0x30 fs/read_write.c:1014
[<ffffffff843778c1>] entry_SYSCALL_64_fastpath+0x1f/0xc2


stack backtrace:
CPU: 1 PID: 13210 Comm: syz-executor2 Not tainted 4.9.0 #7
Hardware name: Google Google Compute Engine/Google Compute Engine,
BIOS Google 01/01/2011
 ffff8801c51fdff8 ffffffff8234ce1f ffffffff00000001 1ffff10038a3fb92
 ffffed0038a3fb8a 0000000041b58ab3 ffffffff84b38258 ffffffff8234cb31
 0000000000000023 ffff8801d5fcaa28 ffff8801d5fca200 0000000000000221
Call Trace:
 [<ffffffff8234ce1f>] __dump_stack lib/dump_stack.c:15 [inline]
 [<ffffffff8234ce1f>] dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
 [<ffffffff81568b22>] print_bad_irq_dependency
kernel/locking/lockdep.c:1536 [inline]
 [<ffffffff81568b22>] check_usage+0xbb2/0xc10 kernel/locking/lockdep.c:1568
 [<ffffffff81568be5>] check_irq_usage+0x65/0xe0 kernel/locking/lockdep.c:1624
 [<ffffffff81569392>] check_prev_add_irq
kernel/locking/lockdep_states.h:8 [inline]
 [<ffffffff81569392>] check_prev_add kernel/locking/lockdep.c:1832 [inline]
 [<ffffffff81569392>] check_prevs_add+0x732/0x1c00 kernel/locking/lockdep.c:1938
 [<ffffffff8156fba9>] validate_chain kernel/locking/lockdep.c:2265 [inline]
 [<ffffffff8156fba9>] __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3338
 [<ffffffff81571d31>] lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
 [<ffffffff843763e3>] __raw_spin_lock
include/linux/spinlock_api_smp.h:144 [inline]
 [<ffffffff843763e3>] _raw_spin_lock+0x33/0x50 kernel/locking/spinlock.c:151
 [<ffffffff82ded0d7>] spin_lock include/linux/spinlock.h:302 [inline]
 [<ffffffff82ded0d7>] ptr_ring_consume include/linux/ptr_ring.h:249 [inline]
 [<ffffffff82ded0d7>] __ptr_ring_swap_queue
include/linux/ptr_ring.h:360 [inline]
 [<ffffffff82ded0d7>] ptr_ring_resize_multiple
include/linux/ptr_ring.h:416 [inline]
 [<ffffffff82ded0d7>] skb_array_resize_multiple
include/linux/skb_array.h:168 [inline]
 [<ffffffff82ded0d7>] tun_queue_resize drivers/net/tun.c:2481 [inline]
 [<ffffffff82ded0d7>] tun_device_event+0x897/0xc70 drivers/net/tun.c:2499
 [<ffffffff814b2745>] notifier_call_chain+0x1b5/0x2b0 kernel/notifier.c:93
 [<ffffffff814b2f6d>] __raw_notifier_call_chain kernel/notifier.c:394 [inline]
 [<ffffffff814b2f6d>] raw_notifier_call_chain+0x2d/0x40 kernel/notifier.c:401
 [<ffffffff835626a1>] call_netdevice_notifiers_info+0x51/0x90
net/core/dev.c:1645
 [<ffffffff83562768>] call_netdevice_notifiers+0x88/0xc0 net/core/dev.c:1661
 [<ffffffff835cced4>] do_setlink+0xfa4/0x3d30 net/core/rtnetlink.c:2042
 [<ffffffff835cfed2>] rtnl_setlink+0x272/0x3f0 net/core/rtnetlink.c:2235
 [<ffffffff835df9b9>] rtnetlink_rcv_msg+0x609/0x860 net/core/rtnetlink.c:4034
 [<ffffffff83673a4b>] netlink_rcv_skb+0x2ab/0x390 net/netlink/af_netlink.c:2298
 [<ffffffff835cab3a>] rtnetlink_rcv+0x2a/0x40 net/core/rtnetlink.c:4040
 [<ffffffff83672294>] netlink_unicast_kernel
net/netlink/af_netlink.c:1231 [inline]
 [<ffffffff83672294>] netlink_unicast+0x514/0x730 net/netlink/af_netlink.c:1257
 [<ffffffff83672f46>] netlink_sendmsg+0xa96/0xe50 net/netlink/af_netlink.c:1803
 [<ffffffff834f6aaa>] sock_sendmsg_nosec net/socket.c:621 [inline]
 [<ffffffff834f6aaa>] sock_sendmsg+0xca/0x110 net/socket.c:631
 [<ffffffff834f6e16>] sock_write_iter+0x326/0x600 net/socket.c:829
 [<ffffffff81a2c4b3>] do_iter_readv_writev+0x2e3/0x5b0 fs/read_write.c:695
 [<ffffffff81a2edbc>] do_readv_writev+0x42c/0x9b0 fs/read_write.c:872
 [<ffffffff81a2f8d7>] vfs_writev+0x87/0xc0 fs/read_write.c:911
 [<ffffffff81a2fa20>] do_writev+0x110/0x2c0 fs/read_write.c:944
 [<ffffffff81a330e7>] SYSC_writev fs/read_write.c:1017 [inline]
 [<ffffffff81a330e7>] SyS_writev+0x27/0x30 fs/read_write.c:1014
 [<ffffffff843778c1>] entry_SYSCALL_64_fastpath+0x1f/0xc2
