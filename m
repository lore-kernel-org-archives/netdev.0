From: Dmitry Vyukov <dvyukov@google.com>
Subject: net/packet: use-after-free in packet_rcv_fanout
Date: Thu, 9 Feb 2017 14:14:25 +0100
Message-ID: <CACT4Y+a2tTARdXKtjtWny9hAPc9b8Q-v8ya3TOV-T+8s=PR2HQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>
To: David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>, jarno@ovn.org,
        sowmini.varadhan@oracle.com, philip.pettersson@gmail.com,
        weongyo.linux@gmail.com, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I've got the following use-after-free report in packet_rcv_fanout
while running syzkaller fuzzer on linux-next
e3e6c5f3544c5d05c6b3b309a34f4f2c3537e993. So far it happened once and
is not reproducible, but maybe the stacks will allow you to figure out
what happens.

BUG: KASAN: use-after-free in __lock_acquire+0x3212/0x3430
kernel/locking/lockdep.c:3224 at addr ffff8801d903d538
Read of size 8 by task syz-executor1/10596
CPU: 1 PID: 10596 Comm: syz-executor1 Not tainted 4.10.0-rc7-next-20170208 #1
Hardware name: Google Google Compute Engine/Google Compute Engine,
BIOS Google 01/01/2011

Call Trace:
 __asan_report_load8_noabort+0x29/0x30 mm/kasan/report.c:332
 __lock_acquire+0x3212/0x3430 kernel/locking/lockdep.c:3224
 lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
 __raw_spin_lock_bh include/linux/spinlock_api_smp.h:135 [inline]
 _raw_spin_lock_bh+0x3a/0x50 kernel/locking/spinlock.c:175
 spin_lock_bh include/linux/spinlock.h:304 [inline]
 packet_rcv_has_room+0x25/0xb0 net/packet/af_packet.c:1308
 fanout_demux_rollover+0x3bb/0x6b0 net/packet/af_packet.c:1388
 packet_rcv_fanout+0x674/0x800 net/packet/af_packet.c:1490
 dev_queue_xmit_nit+0x73a/0xa90 net/core/dev.c:1898
 xmit_one net/core/dev.c:2870 [inline]
 dev_hard_start_xmit+0x16b/0xab0 net/core/dev.c:2890
 __dev_queue_xmit+0x16d1/0x1e60 net/core/dev.c:3355
 dev_queue_xmit+0x17/0x20 net/core/dev.c:3388
 neigh_hh_output include/net/neighbour.h:468 [inline]
 dst_neigh_output include/net/dst.h:452 [inline]
 ip6_finish_output2+0x1461/0x2380 net/ipv6/ip6_output.c:123
 ip6_finish_output+0x2f9/0x950 net/ipv6/ip6_output.c:149
 NF_HOOK_COND include/linux/netfilter.h:246 [inline]
 ip6_output+0x1cb/0x8c0 net/ipv6/ip6_output.c:163
 ip6_xmit+0xc2f/0x1e80 include/net/dst.h:498
 inet6_csk_xmit+0x320/0x5d0 net/ipv6/inet6_connection_sock.c:139
 tcp_transmit_skb+0x1ab4/0x3460 net/ipv4/tcp_output.c:1054
 tcp_send_syn_data net/ipv4/tcp_output.c:3343 [inline]
 tcp_connect+0x11a7/0x2f50 net/ipv4/tcp_output.c:3375
 tcp_v6_connect+0x1a6e/0x1f70 net/ipv6/tcp_ipv6.c:295
 __inet_stream_connect+0x2d1/0xf80 net/ipv4/af_inet.c:618
 tcp_sendmsg_fastopen net/ipv4/tcp.c:1110 [inline]
 tcp_sendmsg+0x23ac/0x3bd0 net/ipv4/tcp.c:1133
 inet_sendmsg+0x164/0x5b0 net/ipv4/af_inet.c:761
 sock_sendmsg_nosec net/socket.c:633 [inline]
 sock_sendmsg+0xca/0x110 net/socket.c:643
 SYSC_sendto+0x660/0x810 net/socket.c:1685
 SyS_sendto+0x40/0x50 net/socket.c:1653
 entry_SYSCALL_64_fastpath+0x1f/0xc2

RIP: 0033:0x44fb59
RSP: 002b:00007f4fe6d53b58 EFLAGS: 00000212 ORIG_RAX: 000000000000002c
RAX: ffffffffffffffda RBX: 0000000020475000 RCX: 000000000044fb59
RDX: 0000000000000000 RSI: 0000000020475000 RDI: 0000000000000022
RBP: 0000000000000022 R08: 000000002000afe0 R09: 0000000000000020
R10: c2b66bc2f9e666dc R11: 0000000000000212 R12: 0000000000708000
R13: 0000000000800003 R14: 0000000000181000 R15: 0000000000000000

Object at ffff8801d903d380, in cache kmalloc-2048 size: 2048
Allocated:
PID = 10570
[<ffffffff8362fc61>] kmalloc include/linux/slab.h:497 [inline]
[<ffffffff8362fc61>] sk_prot_alloc+0x101/0x2a0 net/core/sock.c:1338
[<ffffffff8363878c>] sk_alloc+0x8c/0x470 net/core/sock.c:1394
[<ffffffff83c0fb33>] packet_create+0x163/0xb00 net/packet/af_packet.c:3144
[<ffffffff83628264>] __sock_create+0x4e4/0x870 net/socket.c:1197
[<ffffffff83628829>] sock_create net/socket.c:1237 [inline]
[<ffffffff83628829>] SYSC_socket net/socket.c:1267 [inline]
[<ffffffff83628829>] SyS_socket+0xf9/0x230 net/socket.c:1247

Freed:
PID = 10574
[<ffffffff81a36f43>] kfree+0xd3/0x250 mm/slab.c:3827
[<ffffffff83633b6f>] sk_prot_free net/core/sock.c:1377 [inline]
[<ffffffff83633b6f>] __sk_destruct+0x5af/0x6b0 net/core/sock.c:1450
[<ffffffff8363e047>] sk_destruct+0x47/0x80 net/core/sock.c:1458
[<ffffffff8363e0d7>] __sk_free+0x57/0x230 net/core/sock.c:1466
[<ffffffff8363e2d3>] sk_free+0x23/0x30 net/core/sock.c:1477
[<ffffffff83c14bec>] sock_put include/net/sock.h:1644 [inline]
[<ffffffff83c14bec>] packet_release+0x7ac/0x970 net/packet/af_packet.c:2984
[<ffffffff836205fd>] sock_release+0x8d/0x1e0 net/socket.c:597
[<ffffffff83620766>] sock_close+0x16/0x20 net/socket.c:1061
[<ffffffff81a8d412>] __fput+0x332/0x7f0 fs/file_table.c:208
[<ffffffff81a8d955>] ____fput+0x15/0x20 fs/file_table.c:244
[<ffffffff814aae3a>] task_work_run+0x18a/0x260 kernel/task_work.c:116
[<ffffffff814351f6>] exit_task_work include/linux/task_work.h:21 [inline]
[<ffffffff814351f6>] do_exit+0x1956/0x2900 kernel/exit.c:873
[<ffffffff8143ace9>] do_group_exit+0x149/0x420 kernel/exit.c:977
[<ffffffff81469fd0>] get_signal+0x7e0/0x1820 kernel/signal.c:2313
[<ffffffff8126b992>] do_signal+0xd2/0x2190 arch/x86/kernel/signal.c:807
[<ffffffff81007900>] exit_to_usermode_loop+0x200/0x2a0
arch/x86/entry/common.c:156
[<ffffffff81009413>] prepare_exit_to_usermode
arch/x86/entry/common.c:190 [inline]
[<ffffffff81009413>] syscall_return_slowpath+0x4d3/0x570
arch/x86/entry/common.c:259
[<ffffffff844cb522>] entry_SYSCALL_64_fastpath+0xc0/0xc2
