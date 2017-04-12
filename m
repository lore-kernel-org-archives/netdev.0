From: Andrey Konovalov <andreyknvl@google.com>
Subject: net/ipv4: use-after-free in ipv4_datagram_support_cmsg
Date: Wed, 12 Apr 2017 16:44:22 +0200
Message-ID: <CAAeHK+ysUb+yuES_XYYPDWGrXS4VUXLmQRrD2dJTeXDPL5BKpw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I've got the following error report while fuzzing the kernel with syzkaller.

On commit 39da7c509acff13fc8cb12ec1bb20337c988ed36 (4.11-rc6).

Unfortunately it's not reproducible.

==================================================================
BUG: KASAN: use-after-free in ipv4_datagram_support_cmsg
net/ipv4/ip_sockglue.c:500 [inline] at addr ffff880059be0128
BUG: KASAN: use-after-free in ip_recv_error+0xb37/0xed0
net/ipv4/ip_sockglue.c:553 at addr ffff880059be0128
Read of size 4 by task syz-executor5/22308
CPU: 0 PID: 22308 Comm: syz-executor5 Not tainted 4.11.0-rc6+ #213
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x292/0x398 lib/dump_stack.c:52
 kasan_object_err+0x1c/0x70 mm/kasan/report.c:164
 print_address_description mm/kasan/report.c:202 [inline]
 kasan_report_error mm/kasan/report.c:291 [inline]
 kasan_report+0x252/0x510 mm/kasan/report.c:347
 __asan_report_load4_noabort+0x14/0x20 mm/kasan/report.c:367
 ipv4_datagram_support_cmsg net/ipv4/ip_sockglue.c:500 [inline]
 ip_recv_error+0xb37/0xed0 net/ipv4/ip_sockglue.c:553
 udp_recvmsg+0xe70/0x1370 net/ipv4/udp.c:1421
 inet_recvmsg+0x13e/0x600 net/ipv4/af_inet.c:793
 sock_recvmsg_nosec net/socket.c:751 [inline]
 sock_recvmsg+0xd7/0x110 net/socket.c:758
 ___sys_recvmsg+0x2f4/0x730 net/socket.c:2156
 __sys_recvmsg+0x135/0x320 net/socket.c:2201
 SYSC_recvmsg net/socket.c:2213 [inline]
 SyS_recvmsg+0x2d/0x50 net/socket.c:2208
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x4458d9
RSP: 002b:00007f230ab31b58 EFLAGS: 00000286 ORIG_RAX: 000000000000002f
RAX: ffffffffffffffda RBX: 0000000000000005 RCX: 00000000004458d9
RDX: 0000000040002102 RSI: 0000000020edffc8 RDI: 0000000000000005
RBP: 00000000006e2d00 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000286 R12: 0000000000708000
R13: 0000000000000002 R14: 0000000000708008 R15: 00007f230ab32700
Object at ffff880059be0008, in cache kmalloc-8192 size: 8192
Allocated:
PID = 16445
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:513
 set_track mm/kasan/kasan.c:525 [inline]
 kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:616
 __kmalloc+0xa0/0x2d0 mm/slub.c:3745
 kzalloc include/linux/slab.h:495 [inline]
 alloc_netdev_mqs+0xbc1/0xf40 net/core/dev.c:7706
 br_add_bridge+0x34/0xd0 net/bridge/br_if.c:384
 br_ioctl_deviceless_stub+0x7fc/0xa30 net/bridge/br_ioctl.c:378
 sock_ioctl+0x256/0x440 net/socket.c:971
 vfs_ioctl fs/ioctl.c:45 [inline]
 do_vfs_ioctl+0x1bf/0x1780 fs/ioctl.c:685
 SYSC_ioctl fs/ioctl.c:700 [inline]
 SyS_ioctl+0x8f/0xc0 fs/ioctl.c:691
 entry_SYSCALL_64_fastpath+0x1f/0xc2
Freed:
PID = 22308
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:513
 set_track mm/kasan/kasan.c:525 [inline]
 kasan_slab_free+0x73/0xc0 mm/kasan/kasan.c:589
 slab_free_hook mm/slub.c:1357 [inline]
 slab_free_freelist_hook mm/slub.c:1379 [inline]
 slab_free mm/slub.c:2961 [inline]
 kfree+0xe8/0x2b0 mm/slub.c:3882
 kvfree+0x36/0x60 mm/util.c:337
 netdev_freemem+0x4c/0x60 net/core/dev.c:7658
 netdev_release+0x76/0x90 net/core/net-sysfs.c:1502
 device_release+0x18d/0x220 drivers/base/core.c:814
 kobject_cleanup lib/kobject.c:645 [inline]
 kobject_release+0xfa/0x1a0 lib/kobject.c:674
 kref_put include/linux/kref.h:72 [inline]
 kobject_put+0x6e/0xd0 lib/kobject.c:691
 netdev_run_todo+0x6b2/0xa40 net/core/dev.c:7563
 rtnl_unlock+0xe/0x10 net/core/rtnetlink.c:104
 br_del_bridge+0xb6/0xe0 net/bridge/br_if.c:422
 br_ioctl_deviceless_stub+0x324/0xa30 net/bridge/br_ioctl.c:380
 sock_ioctl+0x256/0x440 net/socket.c:971
 vfs_ioctl fs/ioctl.c:45 [inline]
 do_vfs_ioctl+0x1bf/0x1780 fs/ioctl.c:685
 SYSC_ioctl fs/ioctl.c:700 [inline]
 SyS_ioctl+0x8f/0xc0 fs/ioctl.c:691
 entry_SYSCALL_64_fastpath+0x1f/0xc2
Memory state around the buggy address:
 ffff880059be0000: fc fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff880059be0080: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>ffff880059be0100: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                                  ^
 ffff880059be0180: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff880059be0200: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================
