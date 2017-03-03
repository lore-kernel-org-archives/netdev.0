From: Dmitry Vyukov <dvyukov@google.com>
Subject: net/kcm: use-after-free in kcm_wq
Date: Fri, 3 Mar 2017 11:09:58 +0100
Message-ID: <CACT4Y+ZsaUAbTHdtP7BmZ+dsOTVA+f1jc8Mt=41H+8mwpkbRpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>
To: David Miller <davem@davemloft.net>,
        Tom Herbert <tom@herbertland.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Daniel Borkmann <daniel@iogearbox.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f178.google.com ([209.85.217.178]:33109 "EHLO
        mail-ua0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751460AbdCCKRW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 05:17:22 -0500
Received: by mail-ua0-f178.google.com with SMTP id c11so58223617uaa.0
        for <netdev@vger.kernel.org>; Fri, 03 Mar 2017 02:17:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I am getting the following use-after-free reports while running
syzkaller fuzzer on 86292b33d4b79ee03e2f43ea0381ef85f077c760. Seems
that work items are not properly cancelled.

==================================================================
BUG: KASAN: use-after-free in worker_thread+0x190f/0x1990
kernel/workqueue.c:2228 at addr ffff880063de5a20
Read of size 8 by task kworker/u8:0/5
CPU: 1 PID: 5 Comm: kworker/u8:0 Not tainted 4.10.0+ #260
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:15 [inline]
 dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
 kasan_object_err+0x1c/0x70 mm/kasan/report.c:166
 print_address_description mm/kasan/report.c:204 [inline]
 kasan_report_error mm/kasan/report.c:288 [inline]
 kasan_report.part.2+0x198/0x440 mm/kasan/report.c:310
 kasan_report mm/kasan/report.c:331 [inline]
 __asan_report_load8_noabort+0x29/0x30 mm/kasan/report.c:331
 worker_thread+0x190f/0x1990 kernel/workqueue.c:2228
 kthread+0x326/0x3f0 kernel/kthread.c:227
 ret_from_fork+0x31/0x40 arch/x86/entry/entry_64.S:430
Object at ffff880063de5900, in cache kcm_psock_cache size: 616
Allocated:
PID = 11085
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
 save_stack+0x43/0xd0 mm/kasan/kasan.c:502
 set_track mm/kasan/kasan.c:514 [inline]
 kasan_kmalloc+0xaa/0xd0 mm/kasan/kasan.c:605
 kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:544
 kmem_cache_alloc+0x102/0x680 mm/slab.c:3571
 kmem_cache_zalloc include/linux/slab.h:653 [inline]
 kcm_attach net/kcm/kcmsock.c:1384 [inline]
 kcm_attach_ioctl net/kcm/kcmsock.c:1455 [inline]
 kcm_ioctl+0x303/0x1800 net/kcm/kcmsock.c:1690
 sock_do_ioctl+0x65/0xb0 net/socket.c:895
 sock_ioctl+0x2c2/0x440 net/socket.c:993
 vfs_ioctl fs/ioctl.c:43 [inline]
 do_vfs_ioctl+0x1bf/0x1790 fs/ioctl.c:683
 SYSC_ioctl fs/ioctl.c:698 [inline]
 SyS_ioctl+0x8f/0xc0 fs/ioctl.c:689
 entry_SYSCALL_64_fastpath+0x1f/0xc2
Freed:
PID = 11095
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
 save_stack+0x43/0xd0 mm/kasan/kasan.c:502
 set_track mm/kasan/kasan.c:514 [inline]
 kasan_slab_free+0x6f/0xb0 mm/kasan/kasan.c:578
 __cache_free mm/slab.c:3513 [inline]
 kmem_cache_free+0x71/0x240 mm/slab.c:3773
 kcm_unattach+0xee7/0x1520 net/kcm/kcmsock.c:1558
 kcm_unattach_ioctl net/kcm/kcmsock.c:1603 [inline]
 kcm_ioctl+0xfae/0x1800 net/kcm/kcmsock.c:1700
 sock_do_ioctl+0x65/0xb0 net/socket.c:895
 sock_ioctl+0x2c2/0x440 net/socket.c:993
 vfs_ioctl fs/ioctl.c:43 [inline]
 do_vfs_ioctl+0x1bf/0x1790 fs/ioctl.c:683
 SYSC_ioctl fs/ioctl.c:698 [inline]
 SyS_ioctl+0x8f/0xc0 fs/ioctl.c:689
 entry_SYSCALL_64_fastpath+0x1f/0xc2
Memory state around the buggy address:
 ffff880063de5900: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff880063de5980: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>ffff880063de5a00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                               ^
 ffff880063de5a80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff880063de5b00: fb fb fb fb fb fb fb fb fb fb fb fb fb fc fc fc
==================================================================


==================================================================
BUG: KASAN: use-after-free in worker_thread+0x190f/0x1990
kernel/workqueue.c:2228 at addr ffff88005378ed20
Read of size 8 by task kworker/u8:2/6942
CPU: 3 PID: 6942 Comm: kworker/u8:2 Not tainted 4.10.0+ #260
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:15 [inline]
 dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
 kasan_object_err+0x1c/0x70 mm/kasan/report.c:166
 print_address_description mm/kasan/report.c:204 [inline]
 kasan_report_error mm/kasan/report.c:288 [inline]
 kasan_report.part.2+0x198/0x440 mm/kasan/report.c:310
 kasan_report mm/kasan/report.c:331 [inline]
 __asan_report_load8_noabort+0x29/0x30 mm/kasan/report.c:331
 worker_thread+0x190f/0x1990 kernel/workqueue.c:2228
 kthread+0x326/0x3f0 kernel/kthread.c:227
 ret_from_fork+0x31/0x40 arch/x86/entry/entry_64.S:430
Object at ffff88005378ec00, in cache kcm_psock_cache size: 616
Allocated:
PID = 3023
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
 save_stack+0x43/0xd0 mm/kasan/kasan.c:502
 set_track mm/kasan/kasan.c:514 [inline]
 kasan_kmalloc+0xaa/0xd0 mm/kasan/kasan.c:605
 kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:544
 kmem_cache_alloc+0x102/0x680 mm/slab.c:3571
 kmem_cache_zalloc include/linux/slab.h:653 [inline]
 kcm_attach net/kcm/kcmsock.c:1384 [inline]
 kcm_attach_ioctl net/kcm/kcmsock.c:1455 [inline]
 kcm_ioctl+0x303/0x1800 net/kcm/kcmsock.c:1690
 sock_do_ioctl+0x65/0xb0 net/socket.c:895
 sock_ioctl+0x2c2/0x440 net/socket.c:993
 vfs_ioctl fs/ioctl.c:43 [inline]
 do_vfs_ioctl+0x1bf/0x1790 fs/ioctl.c:683
 SYSC_ioctl fs/ioctl.c:698 [inline]
 SyS_ioctl+0x8f/0xc0 fs/ioctl.c:689
 entry_SYSCALL_64_fastpath+0x1f/0xc2
Freed:
PID = 6942
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
 save_stack+0x43/0xd0 mm/kasan/kasan.c:502
 set_track mm/kasan/kasan.c:514 [inline]
 kasan_slab_free+0x6f/0xb0 mm/kasan/kasan.c:578
 __cache_free mm/slab.c:3513 [inline]
 kmem_cache_free+0x71/0x240 mm/slab.c:3773
 unreserve_psock+0x585/0x760 net/kcm/kcmsock.c:545
 kcm_write_msgs+0xbba/0x1b90 net/kcm/kcmsock.c:588
 kcm_tx_work+0x2e/0x190 net/kcm/kcmsock.c:729
 process_one_work+0xbd0/0x1c10 kernel/workqueue.c:2096
 worker_thread+0x223/0x1990 kernel/workqueue.c:2230
 kthread+0x326/0x3f0 kernel/kthread.c:227
 ret_from_fork+0x31/0x40 arch/x86/entry/entry_64.S:430
Memory state around the buggy address:
 ffff88005378ec00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff88005378ec80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>ffff88005378ed00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                               ^
 ffff88005378ed80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff88005378ee00: fb fb fb fb fb fb fb fb fb fb fb fb fb fc fc fc
==================================================================
