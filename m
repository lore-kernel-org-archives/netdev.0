From: Andrey Konovalov <andreyknvl@google.com>
Subject: net/ipv6: use-after-free in ipv6_sock_ac_close
Date: Mon, 10 Apr 2017 16:28:44 +0200
Message-ID: <CAAeHK+y_7fyLyJnmUKOruWrw3_8a1V1S4htBTa_Psza=VvQdTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>,
        Eric Dumazet <edumazet@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I've got the following error report while fuzzing the kernel with syzkaller.

On commit 39da7c509acff13fc8cb12ec1bb20337c988ed36 (4.11-rc6).

Unfortunately it's not reproducible.

==================================================================
BUG: KASAN: use-after-free in ipv6_sock_ac_close+0x3d6/0x3f0
net/ipv6/anycast.c:190 at addr ffff88005d6ce020
Read of size 8 by task syz-executor6/18308
CPU: 0 PID: 18308 Comm: syz-executor6 Not tainted 4.11.0-rc6+ #206
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x292/0x398 lib/dump_stack.c:52
 kasan_object_err+0x1c/0x70 mm/kasan/report.c:164
 print_address_description mm/kasan/report.c:202 [inline]
 kasan_report_error mm/kasan/report.c:291 [inline]
 kasan_report+0x252/0x510 mm/kasan/report.c:347
 __asan_report_load8_noabort+0x14/0x20 mm/kasan/report.c:368
 ipv6_sock_ac_close+0x3d6/0x3f0 net/ipv6/anycast.c:190
 inet6_release+0x48/0x70 net/ipv6/af_inet6.c:430
 sock_release+0x8d/0x1e0 net/socket.c:597
 sock_close+0x16/0x20 net/socket.c:1072
 __fput+0x332/0x7f0 fs/file_table.c:209
 ____fput+0x15/0x20 fs/file_table.c:245
 task_work_run+0x19b/0x270 kernel/task_work.c:116
 exit_task_work include/linux/task_work.h:21 [inline]
 do_exit+0x18b6/0x2830 kernel/exit.c:878
 do_group_exit+0x149/0x420 kernel/exit.c:982
 get_signal+0x76d/0x17e0 kernel/signal.c:2318
 do_signal+0xd2/0x2190 arch/x86/kernel/signal.c:808
 exit_to_usermode_loop+0x170/0x200 arch/x86/entry/common.c:157
 prepare_exit_to_usermode arch/x86/entry/common.c:191 [inline]
 syscall_return_slowpath+0x3d3/0x420 arch/x86/entry/common.c:260
 entry_SYSCALL_64_fastpath+0xc0/0xc2
RIP: 0033:0x4458d9
RSP: 002b:00007f59304e1cf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: 0000000000000000 RBX: 0000000000708218 RCX: 00000000004458d9
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000708218
RBP: 00000000007081f8 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
R13: 0000000000000000 R14: 00007f59304e29c0 R15: 00007f59304e2700
Object at ffff88005d6ce008, in cache kmalloc-32 size: 32
Allocated:
PID = 18270
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:513
 set_track mm/kasan/kasan.c:525 [inline]
 kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:616
 __kmalloc+0xa0/0x2d0 mm/slub.c:3745
 kmalloc include/linux/slab.h:495 [inline]
 sock_kmalloc+0x11e/0x1b0 net/core/sock.c:1804
 ipv6_sock_ac_join+0x21f/0x7b0 net/ipv6/anycast.c:72
 do_ipv6_setsockopt.isra.7+0x2a77/0x3bc0 net/ipv6/ipv6_sockglue.c:655
 ipv6_setsockopt+0x9b/0x140 net/ipv6/ipv6_sockglue.c:919
 sctp_setsockopt+0x2b4/0x5f10 net/sctp/socket.c:3909
 sock_common_setsockopt+0x95/0xd0 net/core/sock.c:2750
 SYSC_setsockopt net/socket.c:1798 [inline]
 SyS_setsockopt+0x270/0x3a0 net/socket.c:1777
 entry_SYSCALL_64_fastpath+0x1f/0xc2
Freed:
PID = 18308
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:513
 set_track mm/kasan/kasan.c:525 [inline]
 kasan_slab_free+0x73/0xc0 mm/kasan/kasan.c:589
 slab_free_hook mm/slub.c:1357 [inline]
 slab_free_freelist_hook mm/slub.c:1379 [inline]
 slab_free mm/slub.c:2961 [inline]
 kfree+0xe8/0x2b0 mm/slub.c:3882
 __sock_kfree_s net/core/sock.c:1825 [inline]
 sock_kfree_s+0x29/0x70 net/core/sock.c:1831
 ipv6_sock_ac_close+0x2d0/0x3f0 net/ipv6/anycast.c:198
 inet6_release+0x48/0x70 net/ipv6/af_inet6.c:430
 sock_release+0x8d/0x1e0 net/socket.c:597
 sock_close+0x16/0x20 net/socket.c:1072
 __fput+0x332/0x7f0 fs/file_table.c:209
 ____fput+0x15/0x20 fs/file_table.c:245
 task_work_run+0x19b/0x270 kernel/task_work.c:116
 exit_task_work include/linux/task_work.h:21 [inline]
 do_exit+0x18b6/0x2830 kernel/exit.c:878
 do_group_exit+0x149/0x420 kernel/exit.c:982
 get_signal+0x76d/0x17e0 kernel/signal.c:2318
 do_signal+0xd2/0x2190 arch/x86/kernel/signal.c:808
 exit_to_usermode_loop+0x170/0x200 arch/x86/entry/common.c:157
 prepare_exit_to_usermode arch/x86/entry/common.c:191 [inline]
 syscall_return_slowpath+0x3d3/0x420 arch/x86/entry/common.c:260
 entry_SYSCALL_64_fastpath+0xc0/0xc2
Memory state around the buggy address:
 ffff88005d6cdf00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
 ffff88005d6cdf80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>ffff88005d6ce000: fc fb fb fb fb fc fc fc fc fc fc fc fc fc fc fc
                               ^
 ffff88005d6ce080: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
 ffff88005d6ce100: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
==================================================================
Disabling lock debugging due to kernel taint
