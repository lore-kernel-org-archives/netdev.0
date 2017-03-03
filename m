From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/kcm: use-after-free in kcm_wq
Date: Fri, 3 Mar 2017 12:03:11 -0800
Message-ID: <CAM_iQpW7CVYd1og=w=DG_m_cqVTb6VKzb6xfAoqVgtjrdp5aSA@mail.gmail.com>
References: <CACT4Y+ZsaUAbTHdtP7BmZ+dsOTVA+f1jc8Mt=41H+8mwpkbRpA@mail.gmail.com>
 <CACT4Y+Zwk_82rKowdW3tLaZQC_q73swNoZ6mj5kvapHAGztaMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Tom Herbert <tom@herbertland.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Daniel Borkmann <daniel@iogearbox.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f179.google.com ([209.85.128.179]:34154 "EHLO
        mail-wr0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751963AbdCCUDp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 15:03:45 -0500
In-Reply-To: <CACT4Y+Zwk_82rKowdW3tLaZQC_q73swNoZ6mj5kvapHAGztaMQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 3, 2017 at 2:11 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> Also like this one:
>
> ==================================================================
> BUG: KASAN: use-after-free in atomic_long_read
> include/linux/compiler.h:254 [inline] at addr ffff8800538aba60
> BUG: KASAN: use-after-free in get_work_pool+0x2f2/0x340
> kernel/workqueue.c:709 at addr ffff8800538aba60
> Read of size 8 by task syz-executor6/7965
> CPU: 2 PID: 7965 Comm: syz-executor6 Not tainted 4.10.0+ #248
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:15 [inline]
>  dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
>  kasan_object_err+0x1c/0x70 mm/kasan/report.c:166
>  print_address_description mm/kasan/report.c:204 [inline]
>  kasan_report_error mm/kasan/report.c:288 [inline]
>  kasan_report.part.2+0x198/0x440 mm/kasan/report.c:310
>  kasan_report mm/kasan/report.c:331 [inline]
>  __asan_report_load8_noabort+0x29/0x30 mm/kasan/report.c:331
>  atomic_long_read include/linux/compiler.h:254 [inline]
>  get_work_pool+0x2f2/0x340 kernel/workqueue.c:709
>  __queue_work+0x2b3/0x1210 kernel/workqueue.c:1401
>  queue_work_on+0x2e9/0x330 kernel/workqueue.c:1486
>  queue_work include/linux/workqueue.h:487 [inline]
>  strp_check_rcv+0x25/0x30 net/strparser/strparser.c:494


It is not kcm_wq, it is strp_wq, and the work struct is strp->rx_work
which lives in struct kcm_psock. The work is cancelled by strp_done(),
it seems get queued again after strp_done()...


>  kcm_attach net/kcm/kcmsock.c:1434 [inline]
>  kcm_attach_ioctl net/kcm/kcmsock.c:1455 [inline]
>  kcm_ioctl+0x8bb/0x1800 net/kcm/kcmsock.c:1690
>  sock_do_ioctl+0x65/0xb0 net/socket.c:895
>  sock_ioctl+0x2c2/0x440 net/socket.c:993
>  vfs_ioctl fs/ioctl.c:43 [inline]
>  do_vfs_ioctl+0x1bf/0x1790 fs/ioctl.c:683
>  SYSC_ioctl fs/ioctl.c:698 [inline]
>  SyS_ioctl+0x8f/0xc0 fs/ioctl.c:689
>  entry_SYSCALL_64_fastpath+0x1f/0xc2
> RIP: 0033:0x4458d9
> RSP: 002b:00007f1dce9d1b58 EFLAGS: 00000286 ORIG_RAX: 0000000000000010
> RAX: ffffffffffffffda RBX: 0000000000000024 RCX: 00000000004458d9
> RDX: 0000000020b68000 RSI: 00000000000089e0 RDI: 0000000000000024
> RBP: 00000000006e0220 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000286 R12: 00000000007080a8
> R13: 0000000000000000 R14: 00007f1dce9d29c0 R15: 00007f1dce9d2700
> Object at ffff8800538ab940, in cache kcm_psock_cache size: 616
> Allocated:
> PID = 7965
>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
>  save_stack+0x43/0xd0 mm/kasan/kasan.c:502
>  set_track mm/kasan/kasan.c:514 [inline]
>  kasan_kmalloc+0xaa/0xd0 mm/kasan/kasan.c:605
>  kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:544
>  kmem_cache_alloc+0x102/0x680 mm/slab.c:3571
>  kmem_cache_zalloc include/linux/slab.h:653 [inline]
>  kcm_attach net/kcm/kcmsock.c:1384 [inline]
>  kcm_attach_ioctl net/kcm/kcmsock.c:1455 [inline]
>  kcm_ioctl+0x303/0x1800 net/kcm/kcmsock.c:1690
>  sock_do_ioctl+0x65/0xb0 net/socket.c:895
>  sock_ioctl+0x2c2/0x440 net/socket.c:993
>  vfs_ioctl fs/ioctl.c:43 [inline]
>  do_vfs_ioctl+0x1bf/0x1790 fs/ioctl.c:683
>  SYSC_ioctl fs/ioctl.c:698 [inline]
>  SyS_ioctl+0x8f/0xc0 fs/ioctl.c:689
>  entry_SYSCALL_64_fastpath+0x1f/0xc2
> Freed:
> PID = 7982
>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
>  save_stack+0x43/0xd0 mm/kasan/kasan.c:502
>  set_track mm/kasan/kasan.c:514 [inline]
>  kasan_slab_free+0x6f/0xb0 mm/kasan/kasan.c:578
>  __cache_free mm/slab.c:3513 [inline]
>  kmem_cache_free+0x71/0x240 mm/slab.c:3773
>  kcm_unattach+0xee7/0x1520 net/kcm/kcmsock.c:1558
>  kcm_unattach_ioctl net/kcm/kcmsock.c:1603 [inline]
>  kcm_ioctl+0xfae/0x1800 net/kcm/kcmsock.c:1700
>  sock_do_ioctl+0x65/0xb0 net/socket.c:895
>  sock_ioctl+0x2c2/0x440 net/socket.c:993
>  vfs_ioctl fs/ioctl.c:43 [inline]
>  do_vfs_ioctl+0x1bf/0x1790 fs/ioctl.c:683
>  SYSC_ioctl fs/ioctl.c:698 [inline]
>  SyS_ioctl+0x8f/0xc0 fs/ioctl.c:689
>  entry_SYSCALL_64_fastpath+0x1f/0xc2
> Memory state around the buggy address:
>  ffff8800538ab900: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
>  ffff8800538ab980: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>ffff8800538aba00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>                                                        ^
>  ffff8800538aba80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>  ffff8800538abb00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> ==================================================================
