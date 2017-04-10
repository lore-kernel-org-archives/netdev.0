From: Andrey Konovalov <andreyknvl@google.com>
Subject: net: use-after-free in __ns_get_path
Date: Mon, 10 Apr 2017 16:37:17 +0200
Message-ID: <CAAeHK+xS17Mf-9Tkup6mOYUqgq3w3V5ELG1bWQVf5jL2NJy7Lw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34227 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753604AbdDJOhS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 10:37:18 -0400
Received: by mail-pf0-f169.google.com with SMTP id c198so23181362pfc.1
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 07:37:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've got the following error report while fuzzing the kernel with syzkaller.

On commit 39da7c509acff13fc8cb12ec1bb20337c988ed36 (4.11-rc6).

Unfortunately it's not reproducible.

==================================================================
BUG: KASAN: use-after-free in __read_once_size
include/linux/compiler.h:254 [inline] at addr ffff880059ce6590
BUG: KASAN: use-after-free in atomic_read
arch/x86/include/asm/atomic.h:26 [inline] at addr ffff880059ce6590
BUG: KASAN: use-after-free in virt_spin_lock
arch/x86/include/asm/qspinlock.h:62 [inline] at addr ffff880059ce6590
BUG: KASAN: use-after-free in queued_spin_lock_slowpath+0xb0a/0xfd0
kernel/locking/qspinlock.c:421 at addr ffff880059ce6590
Read of size 4 by task syz-executor6/567
CPU: 1 PID: 567 Comm: syz-executor6 Not tainted 4.11.0-rc6+ #206
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x292/0x398 lib/dump_stack.c:52
 kasan_object_err+0x1c/0x70 mm/kasan/report.c:164
 print_address_description mm/kasan/report.c:202 [inline]
 kasan_report_error mm/kasan/report.c:291 [inline]
 kasan_report+0x252/0x510 mm/kasan/report.c:347
 __asan_report_load4_noabort+0x14/0x20 mm/kasan/report.c:367
 __read_once_size include/linux/compiler.h:254 [inline]
 atomic_read arch/x86/include/asm/atomic.h:26 [inline]
 virt_spin_lock arch/x86/include/asm/qspinlock.h:62 [inline]
 queued_spin_lock_slowpath+0xb0a/0xfd0 kernel/locking/qspinlock.c:421
 queued_spin_lock include/asm-generic/qspinlock.h:103 [inline]
 do_raw_spin_lock+0x151/0x1e0 kernel/locking/spinlock_debug.c:113
 __raw_spin_lock include/linux/spinlock_api_smp.h:143 [inline]
 _raw_spin_lock+0x32/0x40 kernel/locking/spinlock.c:151
 spin_lock include/linux/spinlock.h:299 [inline]
 lockref_get_not_dead+0x19/0x80 lib/lockref.c:179
 __ns_get_path+0x197/0x860 fs/nsfs.c:66
 open_related_ns+0xda/0x200 fs/nsfs.c:143
 sock_ioctl+0x39d/0x440 net/socket.c:1001
 vfs_ioctl fs/ioctl.c:45 [inline]
 do_vfs_ioctl+0x1bf/0x1780 fs/ioctl.c:685
 SYSC_ioctl fs/ioctl.c:700 [inline]
 SyS_ioctl+0x8f/0xc0 fs/ioctl.c:691
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x4458d9
RSP: 002b:00007f1c9259eb58 EFLAGS: 00000286 ORIG_RAX: 0000000000000010
RAX: ffffffffffffffda RBX: 0000000000000016 RCX: 00000000004458d9
RDX: 000000002090affc RSI: 000000000000894c RDI: 0000000000000016
RBP: 00000000006e1c50 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000286 R12: 0000000000708150
R13: 0000000000000000 R14: 00007f1c9259f9c0 R15: 00007f1c9259f700
Object at ffff880059ce6510, in cache dentry size: 288
Allocated:
PID = 565
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:513
 set_track mm/kasan/kasan.c:525 [inline]
 kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:616
 kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:555
 slab_post_alloc_hook mm/slab.h:456 [inline]
 slab_alloc_node mm/slub.c:2718 [inline]
 slab_alloc mm/slub.c:2726 [inline]
 kmem_cache_alloc+0x1af/0x250 mm/slub.c:2731
 __d_alloc+0xb3/0xbd0 fs/dcache.c:1571
 d_alloc_pseudo+0x1d/0x30 fs/dcache.c:1692
 __ns_get_path+0x3e8/0x860 fs/nsfs.c:88
 open_related_ns+0xda/0x200 fs/nsfs.c:143
 sock_ioctl+0x39d/0x440 net/socket.c:1001
 vfs_ioctl fs/ioctl.c:45 [inline]
 do_vfs_ioctl+0x1bf/0x1780 fs/ioctl.c:685
 SYSC_ioctl fs/ioctl.c:700 [inline]
 SyS_ioctl+0x8f/0xc0 fs/ioctl.c:691
 entry_SYSCALL_64_fastpath+0x1f/0xc2
Freed:
PID = 566
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:513
 set_track mm/kasan/kasan.c:525 [inline]
 kasan_slab_free+0x73/0xc0 mm/kasan/kasan.c:589
 slab_free_hook mm/slub.c:1357 [inline]
 slab_free_freelist_hook mm/slub.c:1379 [inline]
 slab_free mm/slub.c:2961 [inline]
 kmem_cache_free+0xb2/0x2c0 mm/slub.c:2983
 __d_free fs/dcache.c:265 [inline]
 dentry_free+0xd5/0x150 fs/dcache.c:314
 __dentry_kill+0x485/0x6e0 fs/dcache.c:552
 dentry_kill fs/dcache.c:579 [inline]
 dput.part.25+0x5cd/0x7c0 fs/dcache.c:791
 dput+0x1f/0x30 fs/dcache.c:753
 __fput+0x527/0x7f0 fs/file_table.c:227
 ____fput+0x15/0x20 fs/file_table.c:245
 task_work_run+0x19b/0x270 kernel/task_work.c:116
 tracehook_notify_resume include/linux/tracehook.h:191 [inline]
 exit_to_usermode_loop+0x1c2/0x200 arch/x86/entry/common.c:161
 prepare_exit_to_usermode arch/x86/entry/common.c:191 [inline]
 syscall_return_slowpath+0x3d3/0x420 arch/x86/entry/common.c:260
 entry_SYSCALL_64_fastpath+0xc0/0xc2
Memory state around the buggy address:
 ffff880059ce6480: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
 ffff880059ce6500: fc fc fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>ffff880059ce6580: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                         ^
 ffff880059ce6600: fb fb fb fb fb fb fc fc fc fc fc fc fc fc fc fc
 ffff880059ce6680: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
==================================================================
