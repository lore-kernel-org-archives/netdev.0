From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net: use-after-free in neigh_timer_handler/sock_wfree
Date: Wed, 1 Mar 2017 13:24:39 -0800
Message-ID: <CAM_iQpWGAwXu7yO_XsX2Rk-whLvZPLSXd5Btok=L9VSCV5gr=Q@mail.gmail.com>
References: <CACT4Y+Y6T3hLkgEKR5o3spjjSdTj0HXys2qeVZ9CA7MKsZc15Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+Y6T3hLkgEKR5o3spjjSdTj0HXys2qeVZ9CA7MKsZc15Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 1, 2017 at 11:27 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> Hello,
>
> I am seeing the following use-after-free report while running
> syzkaller fuzzer on
> linux-next/3e7350242c6f3d41d28e03418bd781cc1b7bad5f:
>
> ==================================================================
> BUG: KASAN: use-after-free in constant_test_bit
> arch/x86/include/asm/bitops.h:324 [inline] at addr ffff8801c56d5460
> BUG: KASAN: use-after-free in sock_flag include/net/sock.h:789
> [inline] at addr ffff8801c56d5460
> BUG: KASAN: use-after-free in sock_wfree+0x118/0x120
> net/core/sock.c:1630 at addr ffff8801c56d5460
> Read of size 8 by task syz-fuzzer/3261
> CPU: 0 PID: 3261 Comm: syz-fuzzer Not tainted 4.10.0-next-20170224+ #1
> Hardware name: Google Google Compute Engine/Google Compute Engine,
> BIOS Google 01/01/2011
> Call Trace:
>  <IRQ>
>  __asan_report_load8_noabort+0x29/0x30 mm/kasan/report.c:332
>  constant_test_bit arch/x86/include/asm/bitops.h:324 [inline]
>  sock_flag include/net/sock.h:789 [inline]
>  sock_wfree+0x118/0x120 net/core/sock.c:1630
>  skb_release_head_state+0xfc/0x200 net/core/skbuff.c:654
>  skb_release_all+0x15/0x60 net/core/skbuff.c:667
>  __kfree_skb+0x15/0x20 net/core/skbuff.c:683
>  kfree_skb+0x16e/0x4c0 net/core/skbuff.c:704
>  ndisc_error_report+0xbb/0x190 net/ipv6/ndisc.c:683
>  neigh_invalidate+0x23e/0x570 net/core/neighbour.c:848
>  neigh_timer_handler+0x4e7/0x1140 net/core/neighbour.c:933
>  call_timer_fn+0x241/0x820 kernel/time/timer.c:1266
>  expire_timers kernel/time/timer.c:1305 [inline]
>  __run_timers+0x960/0xcf0 kernel/time/timer.c:1599
>  run_timer_softirq+0x21/0x80 kernel/time/timer.c:1612
>  __do_softirq+0x31f/0xbe7 kernel/softirq.c:284
>  invoke_softirq kernel/softirq.c:364 [inline]
>  irq_exit+0x1cc/0x200 kernel/softirq.c:405
>  exiting_irq arch/x86/include/asm/apic.h:658 [inline]
>  smp_apic_timer_interrupt+0x76/0xa0 arch/x86/kernel/apic/apic.c:962
>  apic_timer_interrupt+0x93/0xa0 arch/x86/entry/entry_64.S:707

This one looks very similar to a previous one:
https://groups.google.com/forum/#!topic/syzkaller/BhyN5OFd7sQ

Both happen on raw v6 sockets.

For me, it seems the sk refcnt is not correct, skb should still hold
a refcnt so it should not be freed before kfree_skb() in a timer
handler...



> RIP: 0033:0x46a7c3
> RSP: 002b:000000c83e2d5180 EFLAGS: 00000202 ORIG_RAX: ffffffffffffff10
> RAX: 0000000000000000 RBX: 000000000046a7b0 RCX: 000000c820471200
> RDX: 0000000000000020 RSI: 000000c839e1bba0 RDI: 000000c83e2d5190
> RBP: 0000000000000002 R08: 0000000000000002 R09: 0000000000000073
> R10: 000000c839a31b03 R11: 000000c839e1bbf8 R12: 0000000000000000
> R13: 0000000000000000 R14: 0000000000000010 R15: 0000000001263e90
>  </IRQ>
> Object at ffff8801c56d5400, in cache RAWv6 size: 1480
> Allocated:
> PID = 12540
>  kmem_cache_alloc+0x102/0x680 mm/slab.c:3568
>  sk_prot_alloc+0x65/0x2a0 net/core/sock.c:1332
>  sk_alloc+0x8c/0x470 net/core/sock.c:1394
>  inet6_create+0x44d/0x1140 net/ipv6/af_inet6.c:183
>  __sock_create+0x4e4/0x870 net/socket.c:1197
>  sock_create net/socket.c:1237 [inline]
>  SYSC_socket net/socket.c:1267 [inline]
>  SyS_socket+0xf9/0x230 net/socket.c:1247
>  entry_SYSCALL_64_fastpath+0x1f/0xc2
> Freed:
> PID = 12572
>  kasan_slab_free+0x6f/0xb0 mm/kasan/kasan.c:580
>  __cache_free mm/slab.c:3510 [inline]
>  kmem_cache_free+0x71/0x240 mm/slab.c:3770
>  sk_prot_free net/core/sock.c:1375 [inline]
>  __sk_destruct+0x487/0x6b0 net/core/sock.c:1450
>  sk_destruct+0x47/0x80 net/core/sock.c:1458
>  __sk_free+0x57/0x230 net/core/sock.c:1466
>  sk_free+0x23/0x30 net/core/sock.c:1477
>  sock_put include/net/sock.h:1644 [inline]
>  sk_common_release+0x3bf/0x5e0 net/core/sock.c:2781
>  rawv6_close+0x4c/0x80 net/ipv6/raw.c:1218
>  inet_release+0xed/0x1c0 net/ipv4/af_inet.c:425
>  inet6_release+0x50/0x70 net/ipv6/af_inet6.c:432
>  sock_release+0x8d/0x1e0 net/socket.c:597
>  sock_close+0x16/0x20 net/socket.c:1061
>  __fput+0x332/0x7f0 fs/file_table.c:208
>  ____fput+0x15/0x20 fs/file_table.c:244
>  task_work_run+0x18a/0x260 kernel/task_work.c:116
>  exit_task_work include/linux/task_work.h:21 [inline]
>  do_exit+0x1956/0x2900 kernel/exit.c:873
>  do_group_exit+0x149/0x420 kernel/exit.c:977
>  get_signal+0x7e0/0x1820 kernel/signal.c:2313
>  do_signal+0xd2/0x2190 arch/x86/kernel/signal.c:807
>  exit_to_usermode_loop+0x200/0x2a0 arch/x86/entry/common.c:156
>  prepare_exit_to_usermode arch/x86/entry/common.c:190 [inline]
>  syscall_return_slowpath+0x4d3/0x570 arch/x86/entry/common.c:259
>  entry_SYSCALL_64_fastpath+0xc0/0xc2
