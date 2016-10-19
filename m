From: Andrey Konovalov <andreyknvl@google.com>
Subject: net/sctp: use-after-free in __sctp_connect
Date: Wed, 19 Oct 2016 14:25:24 +0200
Message-ID: <CAAeHK+wX8yxVTpmg-Ps7MKTD-x_HS3GgpzX6yfGh51cQE0oPjA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>,
        Kostya Serebryany <kcc@google.com>,
        Alexander Potapenko <glider@google.com>,
        Sasha Levin <sasha.levin@oracle.com>,
        Eric Dumazet <edumazet@google.com>,
        Dmitry Vyukov <dvyukov@google.com>
To: Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I've got the following error report while running the syzkaller fuzzer:

==================================================================
BUG: KASAN: use-after-free in __sctp_connect+0xabe/0xbf0 at addr
ffff88006b1dc610
Read of size 4 by task syz-executor/21837
CPU: 2 PID: 21837 Comm: syz-executor Not tainted 4.9.0-rc1+ #228
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffff8800393ef930 ffffffff81b474f4 ffff88003e80ed40 ffff88006b1dc568
 ffff88006b1dd6a0 ffff88006b1dc560 ffff8800393ef958 ffffffff8150b33c
 ffff8800393ef9e8 ffff88003e80ed40 ffff8800eb1dc610 ffff8800393ef9d8
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff81b474f4>] dump_stack+0xb3/0x10f lib/dump_stack.c:51
 [<ffffffff8150b33c>] kasan_object_err+0x1c/0x70 mm/kasan/report.c:156
 [<     inline     >] print_address_description mm/kasan/report.c:194
 [<ffffffff8150b5d7>] kasan_report_error+0x1f7/0x4d0 mm/kasan/report.c:283
 [<     inline     >] kasan_report mm/kasan/report.c:303
 [<ffffffff8150b96e>] __asan_report_load4_noabort+0x3e/0x40
mm/kasan/report.c:323
 [<ffffffff8393457e>] __sctp_connect+0xabe/0xbf0 net/sctp/socket.c:1219
 [<ffffffff83934832>] __sctp_setsockopt_connectx+0x182/0x1b0
net/sctp/socket.c:1329
 [<     inline     >] sctp_setsockopt_connectx net/sctp/socket.c:1361
 [<ffffffff8393c1d9>] sctp_setsockopt+0x1009/0x3d70 net/sctp/socket.c:3813
 [<ffffffff82b770d6>] sock_common_setsockopt+0x96/0xd0 net/core/sock.c:2688
 [<     inline     >] SYSC_setsockopt net/socket.c:1742
 [<ffffffff82b740b4>] SyS_setsockopt+0x154/0x240 net/socket.c:1721
 [<ffffffff83fc0141>] entry_SYSCALL_64_fastpath+0x1f/0xc2
Object at ffff88006b1dc568, in cache kmalloc-4096 size: 4096
Allocated:
PID = 21837
 [  270.449111] [<ffffffff8107e2d6>] save_stack_trace+0x16/0x20
arch/x86/kernel/stacktrace.c:57
 [  270.449111] [<ffffffff8150a6a6>] save_stack+0x46/0xd0 mm/kasan/kasan.c:495
 [  270.449111] [<     inline     >] set_track mm/kasan/kasan.c:507
 [  270.449111] [<ffffffff8150a91b>] kasan_kmalloc+0xab/0xe0
mm/kasan/kasan.c:598
 [  270.449111] [<ffffffff8150604c>] kmem_cache_alloc_trace+0xec/0x270
mm/slub.c:2735
 [  270.449111] [<     inline     >] kmalloc include/linux/slab.h:490
 [  270.449111] [<     inline     >] kzalloc include/linux/slab.h:636
 [  270.449111] [<ffffffff838f2b2f>] sctp_association_new+0x6f/0x1f50
net/sctp/associola.c:303
 [  270.449111] [<ffffffff8393402a>] __sctp_connect+0x56a/0xbf0
net/sctp/socket.c:1163
 [  270.449111] [<ffffffff83934832>]
__sctp_setsockopt_connectx+0x182/0x1b0 net/sctp/socket.c:1329
 [  270.449111] [<     inline     >] sctp_setsockopt_connectx
net/sctp/socket.c:1361
 [  270.449111] [<ffffffff8393c1d9>] sctp_setsockopt+0x1009/0x3d70
net/sctp/socket.c:3813
 [  270.449111] [<ffffffff82b770d6>] sock_common_setsockopt+0x96/0xd0
net/core/sock.c:2688
 [  270.449111] [<     inline     >] SYSC_setsockopt net/socket.c:1742
 [  270.449111] [<ffffffff82b740b4>] SyS_setsockopt+0x154/0x240
net/socket.c:1721
 [  270.449111] [<ffffffff83fc0141>] entry_SYSCALL_64_fastpath+0x1f/0xc2
Freed:
PID = 21837
 [  270.449111] [<ffffffff8107e2d6>] save_stack_trace+0x16/0x20
arch/x86/kernel/stacktrace.c:57
 [  270.449111] [<ffffffff8150a6a6>] save_stack+0x46/0xd0 mm/kasan/kasan.c:495
 [  270.449111] [<     inline     >] set_track mm/kasan/kasan.c:507
 [  270.449111] [<ffffffff8150af03>] kasan_slab_free+0x73/0xc0
mm/kasan/kasan.c:571
 [  270.449111] [<     inline     >] slab_free_hook mm/slub.c:1352
 [  270.449111] [<     inline     >] slab_free_freelist_hook mm/slub.c:1374
 [  270.449111] [<     inline     >] slab_free mm/slub.c:2951
 [  270.449111] [<ffffffff815073e8>] kfree+0xe8/0x2b0 mm/slub.c:3871
 [  270.449111] [<     inline     >] sctp_association_destroy
net/sctp/associola.c:426
 [  270.449111] [<ffffffff838f56e5>] sctp_association_put+0x155/0x250
net/sctp/associola.c:866
 [  270.449111] [<ffffffff8392e213>] sctp_wait_for_connect+0x313/0x460
net/sctp/socket.c:7544
 [  270.449111] [<ffffffff8393443b>] __sctp_connect+0x97b/0xbf0
net/sctp/socket.c:1217
 [  270.449111] [<ffffffff83934832>]
__sctp_setsockopt_connectx+0x182/0x1b0 net/sctp/socket.c:1329
 [  270.449111] [<     inline     >] sctp_setsockopt_connectx
net/sctp/socket.c:1361
 [  270.449111] [<ffffffff8393c1d9>] sctp_setsockopt+0x1009/0x3d70
net/sctp/socket.c:3813
 [  270.449111] [<ffffffff82b770d6>] sock_common_setsockopt+0x96/0xd0
net/core/sock.c:2688
 [  270.449111] [<     inline     >] SYSC_setsockopt net/socket.c:1742
 [  270.449111] [<ffffffff82b740b4>] SyS_setsockopt+0x154/0x240
net/socket.c:1721
 [  270.449111] [<ffffffff83fc0141>] entry_SYSCALL_64_fastpath+0x1f/0xc2
Memory state around the buggy address:
 ffff88006b1dc500: fc fc fc fc fc fc fc fc fc fc fc fc fc fb fb fb
 ffff88006b1dc580: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>ffff88006b1dc600: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                         ^
 ffff88006b1dc680: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff88006b1dc700: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================

sctp_wait_for_connect ends up freeing asoc, which is later accessed to
read asoc->assoc_id.

On commit 1a1891d762d6e64daf07b5be4817e3fbb29e3c59 (Oct 18).
