From: Andrey Konovalov <andreyknvl@google.com>
Subject: net/ipv6: slab-out-of-bounds in ip6_tnl_xmit
Date: Mon, 24 Apr 2017 17:03:00 +0200
Message-ID: <CAAeHK+w-EYicrLHhBR0LHMMTc22GjsB=PTmgswm44w4VpfQ_hA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.161.172]:35495 "EHLO
        mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1170452AbdDXPDB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 11:03:01 -0400
Received: by mail-yw0-f172.google.com with SMTP id u70so81761127ywe.2
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 08:03:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've got the following error report while fuzzing the kernel with syzkaller.

On commit 5a7ad1146caa895ad718a534399e38bd2ba721b7 (4.11-rc8).

Unfortunately it's not reproducible.

The issue might be similar to this one:
https://groups.google.com/forum/#!topic/syzkaller/IDoQHFmrnRI

==================================================================
BUG: KASAN: slab-out-of-bounds in ip6_tnl_xmit+0x25dd/0x28f0
net/ipv6/ip6_tunnel.c:1078 at addr ffff88005dcc5f98
Read of size 16 by task syz-executor7/8076
CPU: 3 PID: 8076 Comm: syz-executor7 Not tainted 4.11.0-rc8+ #266
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x192/0x22d lib/dump_stack.c:52
 kasan_object_err+0x1c/0x70 mm/kasan/report.c:164
 print_address_description mm/kasan/report.c:202 [inline]
 kasan_report_error mm/kasan/report.c:291 [inline]
 kasan_report+0x252/0x510 mm/kasan/report.c:347
 __asan_report_load_n_noabort+0xf/0x20 mm/kasan/report.c:378
 ip6_tnl_xmit+0x25dd/0x28f0 net/ipv6/ip6_tunnel.c:1078
 ip4ip6_tnl_xmit net/ipv6/ip6_tunnel.c:1268 [inline]
 ip6_tnl_start_xmit+0xc1e/0x1890 net/ipv6/ip6_tunnel.c:1370
 __netdev_start_xmit include/linux/netdevice.h:3980 [inline]
 netdev_start_xmit include/linux/netdevice.h:3989 [inline]
 xmit_one net/core/dev.c:2908 [inline]
 dev_hard_start_xmit+0x213/0x800 net/core/dev.c:2924
 __dev_queue_xmit+0x1abc/0x2580 net/core/dev.c:3391
 dev_queue_xmit+0x17/0x20 net/core/dev.c:3424
 neigh_direct_output+0x15/0x20 net/core/neighbour.c:1349
 neigh_output include/net/neighbour.h:478 [inline]
 ip_finish_output2+0x7cd/0x1020 net/ipv4/ip_output.c:228
 ip_finish_output+0x83d/0xc30 net/ipv4/ip_output.c:316
 NF_HOOK_COND include/linux/netfilter.h:246 [inline]
 ip_output+0x1e7/0x5d0 net/ipv4/ip_output.c:404
 dst_output include/net/dst.h:486 [inline]
 ip_local_out+0x82/0xb0 net/ipv4/ip_output.c:124
 ip_send_skb+0x3c/0xc0 net/ipv4/ip_output.c:1492
 ip_push_pending_frames+0x64/0x80 net/ipv4/ip_output.c:1512
 ping_v4_push_pending_frames net/ipv4/ping.c:653 [inline]
 ping_v4_sendmsg+0x1b35/0x23e0 net/ipv4/ping.c:840
 inet_sendmsg+0x164/0x490 net/ipv4/af_inet.c:762
 sock_sendmsg_nosec net/socket.c:633 [inline]
 sock_sendmsg+0xca/0x110 net/socket.c:643
 SYSC_sendto+0x660/0x810 net/socket.c:1696
 SyS_sendto+0x40/0x50 net/socket.c:1664
 entry_SYSCALL_64_fastpath+0x1a/0xa9
RIP: 0033:0x4458d9
RSP: 002b:00007f853159db58 EFLAGS: 00000282 ORIG_RAX: 000000000000002c
RAX: ffffffffffffffda RBX: 0000000000708000 RCX: 00000000004458d9
RDX: 0000000000000008 RSI: 00000000204f9fe1 RDI: 0000000000000017
RBP: 0000000000003410 R08: 0000000020235000 R09: 0000000000000010
R10: 0000000000000000 R11: 0000000000000282 R12: 00000000006e24d0
R13: 0000000020ef8000 R14: 0000000000001000 R15: 0000000000000003
Object at ffff88005dcc5e20, in cache kmalloc-512 size: 512
Allocated:
PID = 8076
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:513
 set_track mm/kasan/kasan.c:525 [inline]
 kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:616
 __kmalloc+0x7c/0x1c0 mm/slub.c:3745
 kmalloc include/linux/slab.h:495 [inline]
 kzalloc include/linux/slab.h:663 [inline]
 neigh_alloc net/core/neighbour.c:286 [inline]
 __neigh_create+0x386/0x1da0 net/core/neighbour.c:458
 neigh_create include/net/neighbour.h:313 [inline]
 ipv4_neigh_lookup+0x4bb/0x730 net/ipv4/route.c:463
 dst_neigh_lookup include/net/dst.h:447 [inline]
 ip6_tnl_xmit+0x1598/0x28f0 net/ipv6/ip6_tunnel.c:1067
 ip4ip6_tnl_xmit net/ipv6/ip6_tunnel.c:1268 [inline]
 ip6_tnl_start_xmit+0xc1e/0x1890 net/ipv6/ip6_tunnel.c:1370
 __netdev_start_xmit include/linux/netdevice.h:3980 [inline]
 netdev_start_xmit include/linux/netdevice.h:3989 [inline]
 xmit_one net/core/dev.c:2908 [inline]
 dev_hard_start_xmit+0x213/0x800 net/core/dev.c:2924
 __dev_queue_xmit+0x1abc/0x2580 net/core/dev.c:3391
 dev_queue_xmit+0x17/0x20 net/core/dev.c:3424
 neigh_direct_output+0x15/0x20 net/core/neighbour.c:1349
 neigh_output include/net/neighbour.h:478 [inline]
 ip_finish_output2+0x7cd/0x1020 net/ipv4/ip_output.c:228
 ip_finish_output+0x83d/0xc30 net/ipv4/ip_output.c:316
 NF_HOOK_COND include/linux/netfilter.h:246 [inline]
 ip_output+0x1e7/0x5d0 net/ipv4/ip_output.c:404
 dst_output include/net/dst.h:486 [inline]
 ip_local_out+0x82/0xb0 net/ipv4/ip_output.c:124
 ip_send_skb+0x3c/0xc0 net/ipv4/ip_output.c:1492
 ip_push_pending_frames+0x64/0x80 net/ipv4/ip_output.c:1512
 ping_v4_push_pending_frames net/ipv4/ping.c:653 [inline]
 ping_v4_sendmsg+0x1b35/0x23e0 net/ipv4/ping.c:840
 inet_sendmsg+0x164/0x490 net/ipv4/af_inet.c:762
 sock_sendmsg_nosec net/socket.c:633 [inline]
 sock_sendmsg+0xca/0x110 net/socket.c:643
 SYSC_sendto+0x660/0x810 net/socket.c:1696
 SyS_sendto+0x40/0x50 net/socket.c:1664
 entry_SYSCALL_64_fastpath+0x1a/0xa9
Freed:
PID = 7604
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:513
 set_track mm/kasan/kasan.c:525 [inline]
 kasan_slab_free+0x73/0xc0 mm/kasan/kasan.c:589
 slab_free_hook mm/slub.c:1357 [inline]
 slab_free_freelist_hook mm/slub.c:1379 [inline]
 slab_free mm/slub.c:2961 [inline]
 kfree+0x91/0x190 mm/slub.c:3882
 skb_free_head+0x74/0xb0 net/core/skbuff.c:579
 skb_release_data+0x37c/0x440 net/core/skbuff.c:610
 skb_release_all+0x4a/0x60 net/core/skbuff.c:669
 __kfree_skb net/core/skbuff.c:683 [inline]
 consume_skb+0x130/0x2f0 net/core/skbuff.c:756
 netlink_broadcast_filtered+0x5fa/0x1420 net/netlink/af_netlink.c:1473
 netlink_broadcast net/netlink/af_netlink.c:1495 [inline]
 nlmsg_multicast include/net/netlink.h:577 [inline]
 nlmsg_notify+0x9c/0x140 net/netlink/af_netlink.c:2382
 rtnl_notify+0xbb/0xe0 net/core/rtnetlink.c:674
 rtmsg_fib+0x3a7/0x4b0 net/ipv4/fib_semantics.c:422
 fib_table_delete+0x836/0x1140 net/ipv4/fib_trie.c:1659
 fib_magic.isra.14+0x4b3/0x890 net/ipv4/fib_frontend.c:840
 fib_del_ifaddr+0xb20/0xe10 net/ipv4/fib_frontend.c:1013
 fib_inetaddr_event+0xaf/0x200 net/ipv4/fib_frontend.c:1150
 notifier_call_chain+0x145/0x2f0 kernel/notifier.c:93
 __blocking_notifier_call_chain kernel/notifier.c:317 [inline]
 blocking_notifier_call_chain+0x109/0x1a0 kernel/notifier.c:328
 __inet_del_ifa+0x4b5/0xb00 net/ipv4/devinet.c:402
 inet_del_ifa net/ipv4/devinet.c:432 [inline]
 devinet_ioctl+0xa75/0x1a10 net/ipv4/devinet.c:1073
 inet_ioctl+0x117/0x1c0 net/ipv4/af_inet.c:900
 sock_do_ioctl+0x65/0xb0 net/socket.c:906
 sock_ioctl+0x27a/0x410 net/socket.c:1004
 vfs_ioctl fs/ioctl.c:45 [inline]
 do_vfs_ioctl+0x1cd/0x15a0 fs/ioctl.c:685
 SYSC_ioctl fs/ioctl.c:700 [inline]
 SyS_ioctl+0x8f/0xc0 fs/ioctl.c:691
 entry_SYSCALL_64_fastpath+0x1a/0xa9
Memory state around the buggy address:
 ffff88005dcc5e80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 ffff88005dcc5f00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>ffff88005dcc5f80: 00 00 00 00 fc fc fc fc fc fc fc fc fc fc fc fc
                               ^
 ffff88005dcc6000: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
 ffff88005dcc6080: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
==================================================================
