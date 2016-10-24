From: Andrey Konovalov <andreyknvl@google.com>
Subject: net/sctp: slab-out-of-bounds in sctp_sf_ootb
Date: Mon, 24 Oct 2016 17:30:04 +0200
Message-ID: <CAAeHK+xqO0gVjOMMLUksUF7oaQgzE+vr5cdUJa1Oa0r89FM7eQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>,
        Kostya Serebryany <kcc@google.com>,
        Alexander Potapenko <glider@google.com>,
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
BUG: KASAN: slab-out-of-bounds in sctp_sf_ootb+0x634/0x6c0 at addr
ffff88006bc1f210
Read of size 2 by task syz-executor/13493
CPU: 3 PID: 13493 Comm: syz-executor Not tainted 4.9.0-rc2+ #300
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffff88003e256e40 ffffffff81b47264 ffff88003e80ccc0 ffff88006bc1eed8
 ffff88006bc1f210 ffff88006bc1eed0 ffff88003e256e68 ffffffff8150b34c
 ffff88003e256ef8 ffff88003e80ccc0 ffff8800ebc1f210 ffff88003e256ee8
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff81b47264>] dump_stack+0xb3/0x10f lib/dump_stack.c:51
 [<ffffffff8150b34c>] kasan_object_err+0x1c/0x70 mm/kasan/report.c:156
 [<     inline     >] print_address_description mm/kasan/report.c:194
 [<ffffffff8150b5e7>] kasan_report_error+0x1f7/0x4d0 mm/kasan/report.c:283
 [<     inline     >] kasan_report mm/kasan/report.c:303
 [<ffffffff8150bb7a>] __asan_report_load_n_noabort+0x3a/0x40
mm/kasan/report.c:334
 [<ffffffff838d6ad4>] sctp_sf_ootb+0x634/0x6c0 net/sctp/sm_statefuns.c:3448
 [<ffffffff838e5914>] sctp_do_sm+0x104/0x4ed0 net/sctp/sm_sideeffect.c:1108
 [<ffffffff838f13cd>] sctp_endpoint_bh_rcv+0x32d/0x9c0
net/sctp/endpointola.c:452
 [<ffffffff839168a4>] sctp_inq_push+0x134/0x1a0 net/sctp/inqueue.c:95
 [<ffffffff83950f68>] sctp_rcv+0x1fa8/0x2d00 net/sctp/input.c:268
 [<ffffffff8306aae2>] ip_local_deliver_finish+0x332/0xad0
net/ipv4/ip_input.c:216
 [<     inline     >] NF_HOOK_THRESH include/linux/netfilter.h:232
 [<     inline     >] NF_HOOK include/linux/netfilter.h:255
 [<ffffffff8306b992>] ip_local_deliver+0x1c2/0x4b0 net/ipv4/ip_input.c:257
 [<     inline     >] dst_input include/net/dst.h:507
 [<ffffffff830692c0>] ip_rcv_finish+0x750/0x1c40 net/ipv4/ip_input.c:396
 [<     inline     >] NF_HOOK_THRESH include/linux/netfilter.h:232
 [<     inline     >] NF_HOOK include/linux/netfilter.h:255
 [<ffffffff8306c5ef>] ip_rcv+0x96f/0x12f0 net/ipv4/ip_input.c:487
 [<ffffffff82bdafb7>] __netif_receive_skb_core+0x1897/0x2a50 net/core/dev.c:4212
 [<ffffffff82bdc19a>] __netif_receive_skb+0x2a/0x170 net/core/dev.c:4250
 [<ffffffff82bdc493>] netif_receive_skb_internal+0x1b3/0x390 net/core/dev.c:4278
 [<ffffffff82bdc6b8>] netif_receive_skb+0x48/0x250 net/core/dev.c:4302
 [<ffffffff82420705>] tun_get_user+0xbd5/0x28a0 drivers/net/tun.c:1308
 [<ffffffff824225ea>] tun_chr_write_iter+0xda/0x190 drivers/net/tun.c:1332
 [<     inline     >] new_sync_write fs/read_write.c:499
 [<ffffffff8151c954>] __vfs_write+0x334/0x570 fs/read_write.c:512
 [<ffffffff8152046b>] vfs_write+0x17b/0x500 fs/read_write.c:560
 [<     inline     >] SYSC_write fs/read_write.c:607
 [<ffffffff81523d94>] SyS_write+0xd4/0x1a0 fs/read_write.c:599
 [<ffffffff83fc0941>] entry_SYSCALL_64_fastpath+0x1f/0xc2
Object at ffff88006bc1eed8, in cache kmalloc-512 size: 512
Allocated:
PID = 9755
 [  182.804017] [<ffffffff8107e236>] save_stack_trace+0x16/0x20
arch/x86/kernel/stacktrace.c:57
 [  182.804017] [<ffffffff8150a6b6>] save_stack+0x46/0xd0 mm/kasan/kasan.c:495
 [  182.804017] [<     inline     >] set_track mm/kasan/kasan.c:507
 [  182.804017] [<ffffffff8150a92b>] kasan_kmalloc+0xab/0xe0
mm/kasan/kasan.c:598
 [  182.804017] [<ffffffff8150ae92>] kasan_slab_alloc+0x12/0x20
mm/kasan/kasan.c:537
 [  182.804017] [<     inline     >] slab_post_alloc_hook mm/slab.h:417
 [  182.804017] [<     inline     >] slab_alloc_node mm/slub.c:2708
 [  182.804017] [<ffffffff81509beb>]
__kmalloc_node_track_caller+0xcb/0x390 mm/slub.c:4270
 [  182.804017] [<ffffffff82b8a5d1>]
__kmalloc_reserve.isra.35+0x41/0xe0 net/core/skbuff.c:138
 [  182.804017] [<ffffffff82b90b00>] __alloc_skb+0xf0/0x600
net/core/skbuff.c:231
 [  182.804017] [<     inline     >] alloc_skb include/linux/skbuff.h:921
 [  182.804017] [<ffffffff82b7d5b3>] sock_wmalloc+0xa3/0xf0 net/core/sock.c:1757
 [  182.804017] [<ffffffff8307c948>]
__ip_append_data.isra.46+0x1e38/0x28c0 net/ipv4/ip_output.c:1010
 [  182.804017] [<ffffffff8307d4c1>] ip_append_data.part.47+0xf1/0x170
net/ipv4/ip_output.c:1201
 [  182.804017] [<     inline     >] ip_append_data net/ipv4/ip_output.c:1605
 [  182.804017] [<ffffffff83089851>] ip_send_unicast_reply+0x831/0xe20
net/ipv4/ip_output.c:1605
 [  182.804017] [<ffffffff8311132a>] tcp_v4_send_reset+0xb0a/0x1700
net/ipv4/tcp_ipv4.c:696
 [  182.804017] [<ffffffff831167cb>] tcp_v4_rcv+0x198b/0x2e50
net/ipv4/tcp_ipv4.c:1719
 [  182.804017] [<ffffffff8306aae2>]
ip_local_deliver_finish+0x332/0xad0 net/ipv4/ip_input.c:216
 [  182.804017] [<     inline     >] NF_HOOK_THRESH
include/linux/netfilter.h:232
 [  182.804017] [<     inline     >] NF_HOOK include/linux/netfilter.h:255
 [  182.804017] [<ffffffff8306b992>] ip_local_deliver+0x1c2/0x4b0
net/ipv4/ip_input.c:257
 [  182.804017] [<     inline     >] dst_input include/net/dst.h:507
 [  182.804017] [<ffffffff830692c0>] ip_rcv_finish+0x750/0x1c40
net/ipv4/ip_input.c:396
 [  182.804017] [<     inline     >] NF_HOOK_THRESH
include/linux/netfilter.h:232
 [  182.804017] [<     inline     >] NF_HOOK include/linux/netfilter.h:255
 [  182.804017] [<ffffffff8306c5ef>] ip_rcv+0x96f/0x12f0 net/ipv4/ip_input.c:487
 [  182.804017] [<ffffffff82bdafb7>]
__netif_receive_skb_core+0x1897/0x2a50 net/core/dev.c:4212
 [  182.804017] [<ffffffff82bdc19a>] __netif_receive_skb+0x2a/0x170
net/core/dev.c:4250
 [  182.804017] [<ffffffff82bdc493>]
netif_receive_skb_internal+0x1b3/0x390 net/core/dev.c:4278
 [  182.804017] [<ffffffff82bdc6b8>] netif_receive_skb+0x48/0x250
net/core/dev.c:4302
 [  182.804017] [<ffffffff82420705>] tun_get_user+0xbd5/0x28a0
drivers/net/tun.c:1308
 [  182.804017] [<ffffffff824225ea>] tun_chr_write_iter+0xda/0x190
drivers/net/tun.c:1332
 [  182.804017] [<     inline     >] new_sync_write fs/read_write.c:499
 [  182.804017] [<ffffffff8151c954>] __vfs_write+0x334/0x570 fs/read_write.c:512
 [  182.804017] [<ffffffff8152046b>] vfs_write+0x17b/0x500 fs/read_write.c:560
 [  182.804017] [<     inline     >] SYSC_write fs/read_write.c:607
 [  182.804017] [<ffffffff81523d94>] SyS_write+0xd4/0x1a0 fs/read_write.c:599
 [  182.804017] [<ffffffff83fc0941>] entry_SYSCALL_64_fastpath+0x1f/0xc2
Freed:
PID = 9207
 [  182.804017] [<ffffffff8107e236>] save_stack_trace+0x16/0x20
arch/x86/kernel/stacktrace.c:57
 [  182.804017] [<ffffffff8150a6b6>] save_stack+0x46/0xd0 mm/kasan/kasan.c:495
 [  182.804017] [<     inline     >] set_track mm/kasan/kasan.c:507
 [  182.804017] [<ffffffff8150af13>] kasan_slab_free+0x73/0xc0
mm/kasan/kasan.c:571
 [  182.804017] [<     inline     >] slab_free_hook mm/slub.c:1352
 [  182.804017] [<     inline     >] slab_free_freelist_hook mm/slub.c:1374
 [  182.804017] [<     inline     >] slab_free mm/slub.c:2951
 [  182.804017] [<ffffffff815073f8>] kfree+0xe8/0x2b0 mm/slub.c:3871
 [  182.804017] [<ffffffff82b896b8>] skb_free_head+0x78/0xb0
net/core/skbuff.c:580
 [  182.804017] [<ffffffff82b92748>] skb_release_data+0x308/0x3a0
net/core/skbuff.c:611
 [  182.804017] [<ffffffff82b9282a>] skb_release_all+0x4a/0x60
net/core/skbuff.c:670
 [  182.804017] [<ffffffff82b92855>] __kfree_skb+0x15/0x20 net/core/skbuff.c:684
 [  182.804017] [<ffffffff82b92964>] kfree_skb+0x104/0x300 net/core/skbuff.c:705
 [  182.804017] [<ffffffff8306902e>] ip_rcv_finish+0x4be/0x1c40
net/ipv4/ip_input.c:399
 [  182.804017] [<     inline     >] NF_HOOK_THRESH
include/linux/netfilter.h:232
 [  182.804017] [<     inline     >] NF_HOOK include/linux/netfilter.h:255
 [  182.804017] [<ffffffff8306c5ef>] ip_rcv+0x96f/0x12f0 net/ipv4/ip_input.c:487
 [  182.804017] [<ffffffff82bdafb7>]
__netif_receive_skb_core+0x1897/0x2a50 net/core/dev.c:4212
 [  182.804017] [<ffffffff82bdc19a>] __netif_receive_skb+0x2a/0x170
net/core/dev.c:4250
 [  182.804017] [<ffffffff82bdc493>]
netif_receive_skb_internal+0x1b3/0x390 net/core/dev.c:4278
 [  182.804017] [<ffffffff82bdc6b8>] netif_receive_skb+0x48/0x250
net/core/dev.c:4302
 [  182.804017] [<ffffffff82420705>] tun_get_user+0xbd5/0x28a0
drivers/net/tun.c:1308
 [  182.804017] [<ffffffff824225ea>] tun_chr_write_iter+0xda/0x190
drivers/net/tun.c:1332
 [  182.804017] [<     inline     >] new_sync_write fs/read_write.c:499
 [  182.804017] [<ffffffff8151c954>] __vfs_write+0x334/0x570 fs/read_write.c:512
 [  182.804017] [<ffffffff8152046b>] vfs_write+0x17b/0x500 fs/read_write.c:560
 [  182.804017] [<     inline     >] SYSC_write fs/read_write.c:607
 [  182.804017] [<ffffffff81523d94>] SyS_write+0xd4/0x1a0 fs/read_write.c:599
 [  182.804017] [<ffffffff83fc0941>] entry_SYSCALL_64_fastpath+0x1f/0xc2
Memory state around the buggy address:
 ffff88006bc1f100: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
 ffff88006bc1f180: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>ffff88006bc1f200: fc fc fc fc fc fc fb fb fb fb fb fb fb fb fb fb
                         ^
 ffff88006bc1f280: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff88006bc1f300: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================

The problem is that sctp_walk_errors walks the chunk before its length
is checked for overflow.

On commit 07d9a380680d1c0eb51ef87ff2eab5c994949e69 (Oct 23).
