From: Dmitry Vyukov <dvyukov@google.com>
Subject: net/kcm: double free of kcm inode
Date: Thu, 23 Mar 2017 13:09:59 +0100
Message-ID: <CACT4Y+Y=Wg6Dzn6jZnTwhRCTHA5M6+uaJPZbiR_50Xy5XLDeUQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>
To: David Miller <davem@davemloft.net>,
        Tom Herbert <tom@herbertland.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Ingo Molnar <mingo@kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Al Viro <viro@zeniv.linux.org.uk>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I've got the following report while running syzkaller fuzzer. Note the
preceding kmem_cache_alloc injected failure, it's most likely the root
cause.

FAULT_INJECTION: forcing a failure.
name failslab, interval 1, probability 0, space 0, times 0
CPU: 1 PID: 21839 Comm: syz-executor4 Not tainted 4.11.0-rc3+ #364
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x1b8/0x28d lib/dump_stack.c:52
 fail_dump lib/fault-inject.c:45 [inline]
 should_fail+0x78a/0x870 lib/fault-inject.c:154
 should_failslab+0xec/0x120 mm/failslab.c:31
 slab_pre_alloc_hook mm/slab.h:434 [inline]
 slab_alloc mm/slab.c:3394 [inline]
 kmem_cache_alloc+0x200/0x720 mm/slab.c:3570
 sk_prot_alloc+0x65/0x2a0 net/core/sock.c:1331
 sk_alloc+0x8c/0x710 net/core/sock.c:1393
 kcm_clone net/kcm/kcmsock.c:1655 [inline]
 kcm_ioctl+0xb65/0x17e0 net/kcm/kcmsock.c:1713
 sock_do_ioctl+0x65/0xb0 net/socket.c:895
 sock_ioctl+0x2c2/0x440 net/socket.c:993
 vfs_ioctl fs/ioctl.c:45 [inline]
 do_vfs_ioctl+0x1af/0x16d0 fs/ioctl.c:685
 SYSC_ioctl fs/ioctl.c:700 [inline]
 SyS_ioctl+0x8f/0xc0 fs/ioctl.c:691
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x445b79
RSP: 002b:00007f05eb28e858 EFLAGS: 00000286 ORIG_RAX: 0000000000000010
RAX: ffffffffffffffda RBX: 0000000000708000 RCX: 0000000000445b79
RDX: 0000000020001000 RSI: 00000000000089e2 RDI: 0000000000000005
RBP: 0000000000000086 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000286 R12: 00000000004a7e31
R13: 0000000000000000 R14: 00007f05eb28e618 R15: 00007f05eb28e788
==================================================================
BUG: KASAN: use-after-free in __fput+0x6b0/0x7f0 fs/file_table.c:211
at addr ffff880037a25670
Read of size 2 by task syz-executor4/21839
CPU: 1 PID: 21839 Comm: syz-executor4 Not tainted 4.11.0-rc3+ #364
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x1b8/0x28d lib/dump_stack.c:52
 kasan_object_err+0x1c/0x70 mm/kasan/report.c:166
 print_address_description mm/kasan/report.c:210 [inline]
 kasan_report_error mm/kasan/report.c:294 [inline]
 kasan_report.part.2+0x1be/0x480 mm/kasan/report.c:316
 kasan_report mm/kasan/report.c:335 [inline]
 __asan_report_load2_noabort+0x29/0x30 mm/kasan/report.c:335
 __fput+0x6b0/0x7f0 fs/file_table.c:211
 ____fput+0x15/0x20 fs/file_table.c:245
 task_work_run+0x1a4/0x270 kernel/task_work.c:116
 tracehook_notify_resume include/linux/tracehook.h:191 [inline]
 exit_to_usermode_loop+0x24d/0x2d0 arch/x86/entry/common.c:161
 prepare_exit_to_usermode arch/x86/entry/common.c:191 [inline]
 syscall_return_slowpath+0x3bd/0x460 arch/x86/entry/common.c:260
 entry_SYSCALL_64_fastpath+0xc0/0xc2
RIP: 0033:0x445b79
RSP: 002b:00007f05eb28e858 EFLAGS: 00000286 ORIG_RAX: 0000000000000010
RAX: fffffffffffffff4 RBX: 0000000000708000 RCX: 0000000000445b79
RDX: 0000000020001000 RSI: 00000000000089e2 RDI: 0000000000000005
RBP: 0000000000002170 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000286 R12: 00000000006e0230
R13: 00000000000089e2 R14: 0000000020001000 R15: 0000000000000005
Object at ffff880037a25640, in cache sock_inode_cache size: 944
Allocated:
PID = 21839
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:517
 set_track mm/kasan/kasan.c:529 [inline]
 kasan_kmalloc+0xbc/0xf0 mm/kasan/kasan.c:620
 kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:559
 kmem_cache_alloc+0x110/0x720 mm/slab.c:3572
 sock_alloc_inode+0x70/0x300 net/socket.c:250
 alloc_inode+0x65/0x180 fs/inode.c:207
 new_inode_pseudo+0x69/0x190 fs/inode.c:889
 sock_alloc+0x41/0x270 net/socket.c:565
 kcm_clone net/kcm/kcmsock.c:1634 [inline]
 kcm_ioctl+0x990/0x17e0 net/kcm/kcmsock.c:1713
 sock_do_ioctl+0x65/0xb0 net/socket.c:895
 sock_ioctl+0x2c2/0x440 net/socket.c:993
 vfs_ioctl fs/ioctl.c:45 [inline]
 do_vfs_ioctl+0x1af/0x16d0 fs/ioctl.c:685
 SYSC_ioctl fs/ioctl.c:700 [inline]
 SyS_ioctl+0x8f/0xc0 fs/ioctl.c:691
 entry_SYSCALL_64_fastpath+0x1f/0xc2
Freed:
PID = 21839
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:517
 set_track mm/kasan/kasan.c:529 [inline]
 kasan_slab_free+0x81/0xc0 mm/kasan/kasan.c:593
 __cache_free mm/slab.c:3514 [inline]
 kmem_cache_free+0x71/0x240 mm/slab.c:3774
 sock_destroy_inode+0x56/0x70 net/socket.c:280
 destroy_inode+0x15d/0x200 fs/inode.c:264
 evict+0x57e/0x920 fs/inode.c:570
 iput_final fs/inode.c:1515 [inline]
 iput+0x62b/0xa20 fs/inode.c:1542
 sock_release+0x168/0x1e0 net/socket.c:607
 sock_close+0x16/0x20 net/socket.c:1061
 __fput+0x327/0x7f0 fs/file_table.c:209
 ____fput+0x15/0x20 fs/file_table.c:245
 task_work_run+0x1a4/0x270 kernel/task_work.c:116
 tracehook_notify_resume include/linux/tracehook.h:191 [inline]
 exit_to_usermode_loop+0x24d/0x2d0 arch/x86/entry/common.c:161
 prepare_exit_to_usermode arch/x86/entry/common.c:191 [inline]
 syscall_return_slowpath+0x3bd/0x460 arch/x86/entry/common.c:260
 entry_SYSCALL_64_fastpath+0xc0/0xc2
Memory state around the buggy address:
 ffff880037a25500: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff880037a25580: fb fb fb fb fb fb fc fc fc fc fc fc fc fc fc fc
>ffff880037a25600: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
                                                             ^
 ffff880037a25680: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff880037a25700: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================

On commit 093b995e3b55a0ae0670226ddfcb05bfbf0099ae
