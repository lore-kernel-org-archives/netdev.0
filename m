From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/ipv4: use-after-free in ip_check_mc_rcu
Date: Mon, 10 Apr 2017 16:07:12 -0700
Message-ID: <CAM_iQpUurECWXx+kxz4V2QKa9+fn5gDLPZOQaqdQ1XikzHbX-Q@mail.gmail.com>
References: <CAAeHK+wWEp1awDbb+ahfAHSQjooy0WXfNPG5jzCBJeBigTJW2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+wWEp1awDbb+ahfAHSQjooy0WXfNPG5jzCBJeBigTJW2g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 10, 2017 at 7:33 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
> Hi,
>
> I've got the following error report while fuzzing the kernel with syzkaller.
>
> On commit 39da7c509acff13fc8cb12ec1bb20337c988ed36 (4.11-rc6).
>
> Unfortunately it's not reproducible.
>
> BUG: KASAN: use-after-free in ip_check_mc_rcu+0x805/0x8b0
> net/ipv4/igmp.c:2645 at addr ffff880065b21cb8
> Read of size 8 by task syz-executor1/2843
> CPU: 3 PID: 2843 Comm: syz-executor1 Not tainted 4.11.0-rc6+ #206
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:16 [inline]
>  dump_stack+0x292/0x398 lib/dump_stack.c:52
>  kasan_object_err+0x1c/0x70 mm/kasan/report.c:164
>  print_address_description mm/kasan/report.c:202 [inline]
>  kasan_report_error mm/kasan/report.c:291 [inline]
>  kasan_report+0x252/0x510 mm/kasan/report.c:347
>  __asan_report_load8_noabort+0x14/0x20 mm/kasan/report.c:368
>  ip_check_mc_rcu+0x805/0x8b0 net/ipv4/igmp.c:2645
>  __mkroute_output net/ipv4/route.c:2103 [inline]
>  __ip_route_output_key_hash+0x241d/0x2ea0 net/ipv4/route.c:2375
>  __ip_route_output_key include/net/route.h:122 [inline]
>  ip_route_output_flow+0x29/0xa0 net/ipv4/route.c:2461
>  udp_sendmsg+0x1565/0x2cd0 net/ipv4/udp.c:1015
>  inet_sendmsg+0x164/0x5b0 net/ipv4/af_inet.c:762
>  sock_sendmsg_nosec net/socket.c:633 [inline]
>  sock_sendmsg+0xca/0x110 net/socket.c:643
>  SYSC_sendto+0x660/0x810 net/socket.c:1696
>  SyS_sendto+0x40/0x50 net/socket.c:1664
>  entry_SYSCALL_64_fastpath+0x1f/0xc2

The singly linked list pmc->sources is probably supposed to be
protected by RCU, but we don't use kfree_rcu() to free it. I think
this is probably why we have this bug. Perhaps it is time now
to convert it to a doubly linked list which is much easier for RCU.

I will work on a patch.

Thanks!

> RIP: 0033:0x4458d9
> RSP: 002b:00007f030b49bb58 EFLAGS: 00000282 ORIG_RAX: 000000000000002c
> RAX: ffffffffffffffda RBX: 0000000000000005 RCX: 00000000004458d9
> RDX: 0000000000001000 RSI: 0000000020004000 RDI: 0000000000000005
> RBP: 00000000006e2fc0 R08: 000000002000a000 R09: 0000000000000010
> R10: 0000000000000000 R11: 0000000000000282 R12: 0000000000708000
> R13: 0000000000000005 R14: 0000000020000ff3 R15: 0000000020006ffc
> Object at ffff880065b21cb8, in cache kmalloc-64 size: 64
> Allocated:
> PID = 2841
>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
>  save_stack+0x43/0xd0 mm/kasan/kasan.c:513
>  set_track mm/kasan/kasan.c:525 [inline]
>  kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:616
>  kmem_cache_alloc_trace+0x82/0x270 mm/slub.c:2745
>  kmalloc include/linux/slab.h:490 [inline]
>  kzalloc include/linux/slab.h:663 [inline]
>  ip_mc_add1_src net/ipv4/igmp.c:1909 [inline]
>  ip_mc_add_src+0xbea/0x1020 net/ipv4/igmp.c:2033
>  ip_mc_msfilter+0x5e5/0xcf0 net/ipv4/igmp.c:2403
>  do_ip_setsockopt.isra.12+0x2a9f/0x36c0 net/ipv4/ip_sockglue.c:967
>  ip_setsockopt+0x3a/0xb0 net/ipv4/ip_sockglue.c:1264
>  raw_setsockopt+0xb7/0xd0 net/ipv4/raw.c:839
>  sock_common_setsockopt+0x95/0xd0 net/core/sock.c:2750
>  SYSC_setsockopt net/socket.c:1798 [inline]
>  SyS_setsockopt+0x270/0x3a0 net/socket.c:1777
>  entry_SYSCALL_64_fastpath+0x1f/0xc2
> Freed:
> PID = 2841
>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
>  save_stack+0x43/0xd0 mm/kasan/kasan.c:513
>  set_track mm/kasan/kasan.c:525 [inline]
>  kasan_slab_free+0x73/0xc0 mm/kasan/kasan.c:589
>  slab_free_hook mm/slub.c:1357 [inline]
>  slab_free_freelist_hook mm/slub.c:1379 [inline]
>  slab_free mm/slub.c:2961 [inline]
>  kfree+0xe8/0x2b0 mm/slub.c:3882
>  ip_mc_del1_src+0x842/0x9d0 net/ipv4/igmp.c:1822
>  ip_mc_del_src+0x59a/0xbe0 net/ipv4/igmp.c:1863
>  ip_mc_leave_src+0x15d/0x320 net/ipv4/igmp.c:2155
>  ip_mc_drop_socket+0x113/0x230 net/ipv4/igmp.c:2607
>  inet_release+0x4e/0x1c0 net/ipv4/af_inet.c:411
>  sock_release+0x8d/0x1e0 net/socket.c:597
>  sock_close+0x16/0x20 net/socket.c:1072
>  __fput+0x332/0x7f0 fs/file_table.c:209
>  ____fput+0x15/0x20 fs/file_table.c:245
>  task_work_run+0x19b/0x270 kernel/task_work.c:116
>  exit_task_work include/linux/task_work.h:21 [inline]
>  do_exit+0x18b6/0x2830 kernel/exit.c:878
>  do_group_exit+0x149/0x420 kernel/exit.c:982
>  get_signal+0x76d/0x17e0 kernel/signal.c:2318
>  do_signal+0xd2/0x2190 arch/x86/kernel/signal.c:808
>  exit_to_usermode_loop+0x170/0x200 arch/x86/entry/common.c:157
>  prepare_exit_to_usermode arch/x86/entry/common.c:191 [inline]
>  syscall_return_slowpath+0x3d3/0x420 arch/x86/entry/common.c:260
>  entry_SYSCALL_64_fastpath+0xc0/0xc2
> Memory state around the buggy address:
>  ffff880065b21b80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>  ffff880065b21c00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>>ffff880065b21c80: fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb fc
>                                         ^
>  ffff880065b21d00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>  ffff880065b21d80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
> ==================================================================
