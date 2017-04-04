From: Eric Dumazet <edumazet@google.com>
Subject: Re: net/ipv4: use-after-free in ipv4_mtu
Date: Tue, 4 Apr 2017 11:51:43 -0700
Message-ID: <CANn89iKuT+VBZqbJ4=hTAgUbnhuZ0berg0PK+imd1CKuWLy1eQ@mail.gmail.com>
References: <CAAeHK+zJ20r8O=MhPY69UPK7sObODp2ByK5136JXgw5U9SMofw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+zJ20r8O=MhPY69UPK7sObODp2ByK5136JXgw5U9SMofw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 4, 2017 at 7:50 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
>
> Hi,
>
> I've got the following error report while fuzzing the kernel with syzkaller.
>
> On commit a71c9a1c779f2499fb2afc0553e543f18aff6edf (4.11-rc5).
>
> Unfortunately it's not reproducible.
>
> ==================================================================
> BUG: KASAN: use-after-free in dst_metric_raw include/net/dst.h:176
> [inline] at addr ffff88003d6a965c
> BUG: KASAN: use-after-free in ipv4_mtu+0x3f2/0x4b0
> net/ipv4/route.c:1270 at addr ffff88003d6a965c
> Read of size 4 by task syz-executor3/20611
> CPU: 3 PID: 20611 Comm: syz-executor3 Not tainted 4.11.0-rc5+ #199
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:16 [inline]
>  dump_stack+0x292/0x398 lib/dump_stack.c:52
>  kasan_object_err+0x1c/0x70 mm/kasan/report.c:164
>  print_address_description mm/kasan/report.c:202 [inline]
>  kasan_report_error mm/kasan/report.c:291 [inline]
>  kasan_report+0x252/0x510 mm/kasan/report.c:347
>  __asan_report_load4_noabort+0x14/0x20 mm/kasan/report.c:367
>  dst_metric_raw include/net/dst.h:176 [inline]
>  ipv4_mtu+0x3f2/0x4b0 net/ipv4/route.c:1270
>  dst_mtu include/net/dst.h:221 [inline]
>  do_ip_getsockopt+0x71d/0x2290 net/ipv4/ip_sockglue.c:1433
>  ip_getsockopt+0x90/0x230 net/ipv4/ip_sockglue.c:1578
>  tcp_getsockopt+0x82/0xd0 net/ipv4/tcp.c:3131
>  sock_common_getsockopt+0x95/0xd0 net/core/sock.c:2709
>  SYSC_getsockopt net/socket.c:1829 [inline]
>  SyS_getsockopt+0x252/0x390 net/socket.c:1811
>  entry_SYSCALL_64_fastpath+0x1f/0xc2
> RIP: 0033:0x4458d9
> RSP: 002b:00007fe87f452b58 EFLAGS: 00000286 ORIG_RAX: 0000000000000037
> RAX: ffffffffffffffda RBX: 0000000000000005 RCX: 00000000004458d9
> RDX: 000000000000000e RSI: 0000000000000000 RDI: 0000000000000005
> RBP: 00000000006e0020 R08: 0000000020db6000 R09: 0000000000000000
> R10: 00000000207e8000 R11: 0000000000000286 R12: 0000000000708150
> R13: 0000000020db8000 R14: 0000000000001000 R15: 0000000000000003
> Object at ffff88003d6a9658, in cache kmalloc-64 size: 64
> Allocated:
> PID = 20110
>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
>  save_stack+0x43/0xd0 mm/kasan/kasan.c:513
>  set_track mm/kasan/kasan.c:525 [inline]
>  kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:616
>  kmem_cache_alloc_trace+0x82/0x270 mm/slub.c:2745
>  kmalloc include/linux/slab.h:490 [inline]
>  kzalloc include/linux/slab.h:663 [inline]
>  fib_create_info+0x8e0/0x3a30 net/ipv4/fib_semantics.c:1040
>  fib_table_insert+0x1a5/0x1550 net/ipv4/fib_trie.c:1221
>  ip_rt_ioctl+0xddc/0x1590 net/ipv4/fib_frontend.c:597
>  inet_ioctl+0xf2/0x1c0 net/ipv4/af_inet.c:882
> sctp: [Deprecated]: syz-executor0 (pid 20638) Use of int in max_burst
> socket option.
> Use struct sctp_assoc_value instead
>  sock_do_ioctl+0x65/0xb0 net/socket.c:906
>  sock_ioctl+0x28f/0x440 net/socket.c:1004
>  vfs_ioctl fs/ioctl.c:45 [inline]
>  do_vfs_ioctl+0x1bf/0x1780 fs/ioctl.c:685
>  SYSC_ioctl fs/ioctl.c:700 [inline]
>  SyS_ioctl+0x8f/0xc0 fs/ioctl.c:691
>  entry_SYSCALL_64_fastpath+0x1f/0xc2
> Freed:
> PID = 4439
>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
>  save_stack+0x43/0xd0 mm/kasan/kasan.c:513
>  set_track mm/kasan/kasan.c:525 [inline]
>  kasan_slab_free+0x73/0xc0 mm/kasan/kasan.c:589
>  slab_free_hook mm/slub.c:1357 [inline]
>  slab_free_freelist_hook mm/slub.c:1379 [inline]
>  slab_free mm/slub.c:2961 [inline]
>  kfree+0xe8/0x2b0 mm/slub.c:3882
>  free_fib_info_rcu+0x4ba/0x5e0 net/ipv4/fib_semantics.c:218
>  __rcu_reclaim kernel/rcu/rcu.h:118 [inline]
>  rcu_do_batch.isra.64+0x947/0xcc0 kernel/rcu/tree.c:2879
>  invoke_rcu_callbacks kernel/rcu/tree.c:3142 [inline]
>  __rcu_process_callbacks kernel/rcu/tree.c:3109 [inline]
>  rcu_process_callbacks+0x2cc/0xb90 kernel/rcu/tree.c:3126
>  __do_softirq+0x2fb/0xb7d kernel/softirq.c:284
> Memory state around the buggy address:
>  ffff88003d6a9500: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>  ffff88003d6a9580: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
> >ffff88003d6a9600: fc fc fc fc fc fc fc fc fc fc fc fb fb fb fb fb
>                                                     ^
>  ffff88003d6a9680: fb fb fb fc fc fc fc fc fc fc fc fc fc fc fc fc
>  ffff88003d6a9700: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
> ==================================================================

Thanks for the report Andrey

Looking at fib->fib_metrics, I fail to understand how the following can work :

dst_init_metrics(&rt->dst, fi->fib_metrics, true);

In the cases fi->fib_metrics is _not_ dst_default_metrics,
fi->fib_metrics can be freed when the fib is deleted,
while dst(s) have still the 'read only pointer'.

RCU grace period before fi->fib_metrics freeing does not help.

Without refcounts, it looks like we need to copy the fib_metrics.
