From: Dmitry Vyukov <dvyukov@google.com>
Subject: net: sleeping function called from invalid context in net_enable_timestamp
Date: Wed, 1 Mar 2017 20:51:58 +0100
Message-ID: <CACT4Y+bHh=mzTXw1J8vxbzimrQULss16B=693T4SMcndoNoPPg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>
To: David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I've got the following report while running syzkaller fuzzer on
e5d56efc97f8240d0b5d66c03949382b6d7e5570:

BUG: sleeping function called from invalid context at kernel/locking/mutex.c:745
in_atomic(): 1, irqs_disabled(): 0, pid: 23233, name: syz-executor5
INFO: lockdep is turned off.
CPU: 1 PID: 23233 Comm: syz-executor5 Not tainted 4.10.0+ #229
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 <IRQ>
 __dump_stack lib/dump_stack.c:15 [inline]
 dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
 ___might_sleep+0x47e/0x670 kernel/sched/core.c:6196
 __might_sleep+0x95/0x1a0 kernel/sched/core.c:6151
 __mutex_lock_common kernel/locking/mutex.c:745 [inline]
 __mutex_lock+0x144/0x1730 kernel/locking/mutex.c:891
 mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:906
 jump_label_lock kernel/jump_label.c:26 [inline]
 static_key_slow_inc+0x21f/0x3c0 kernel/jump_label.c:127
 net_enable_timestamp+0x15/0x20 net/core/dev.c:1713
 sk_clone_lock+0xef0/0x12c0 net/core/sock.c:1588
 inet_csk_clone_lock+0x91/0x4f0 net/ipv4/inet_connection_sock.c:781
 tcp_create_openreq_child+0xab/0x1e80 net/ipv4/tcp_minisocks.c:436
 tcp_v6_syn_recv_sock+0x210/0x1fb0 net/ipv6/tcp_ipv6.c:1101
 tcp_get_cookie_sock+0x115/0x530 net/ipv4/syncookies.c:212
 cookie_v6_check+0x16f9/0x20d0 net/ipv6/syncookies.c:245
 tcp_v6_cookie_check net/ipv6/tcp_ipv6.c:987 [inline]
 tcp_v6_do_rcv+0xfc3/0x1420 net/ipv6/tcp_ipv6.c:1296
 tcp_v6_rcv+0x22d2/0x2da0 net/ipv6/tcp_ipv6.c:1485
 ip6_input_finish+0x45b/0x1700 net/ipv6/ip6_input.c:279
 NF_HOOK include/linux/netfilter.h:257 [inline]
 ip6_input+0xdb/0x580 net/ipv6/ip6_input.c:322
 dst_input include/net/dst.h:492 [inline]
 ip6_rcv_finish+0x194/0x720 net/ipv6/ip6_input.c:69
 NF_HOOK include/linux/netfilter.h:257 [inline]
 ipv6_rcv+0x12df/0x2380 net/ipv6/ip6_input.c:203
 __netif_receive_skb_core+0x1fb3/0x33a0 net/core/dev.c:4179
 __netif_receive_skb+0x2a/0x170 net/core/dev.c:4217
 process_backlog+0x11e/0x730 net/core/dev.c:4837
 napi_poll net/core/dev.c:5171 [inline]
 net_rx_action+0xeb4/0x1580 net/core/dev.c:5236
 __do_softirq+0x31f/0xbe7 kernel/softirq.c:284
 do_softirq_own_stack+0x1c/0x30 arch/x86/entry/entry_64.S:902
 </IRQ>
 do_softirq.part.21+0x2c0/0x300 kernel/softirq.c:328
 do_softirq kernel/softirq.c:176 [inline]
 __local_bh_enable_ip+0x24c/0x290 kernel/softirq.c:181
 local_bh_enable include/linux/bottom_half.h:31 [inline]
 rcu_read_unlock_bh include/linux/rcupdate.h:971 [inline]
 ip6_finish_output2+0xb85/0x2380 net/ipv6/ip6_output.c:124
 ip6_finish_output+0x2f9/0x950 net/ipv6/ip6_output.c:149
 NF_HOOK_COND include/linux/netfilter.h:246 [inline]
 ip6_output+0x1cb/0x8c0 net/ipv6/ip6_output.c:163
 ip6_xmit+0xc36/0x1e80 include/net/dst.h:486
 inet6_csk_xmit+0x320/0x5d0 net/ipv6/inet6_connection_sock.c:139
 tcp_transmit_skb+0x1ab4/0x3460 net/ipv4/tcp_output.c:1057
 tcp_write_xmit+0x6e6/0x50d0 net/ipv4/tcp_output.c:2260
 __tcp_push_pending_frames+0xfa/0x380 net/ipv4/tcp_output.c:2445
 tcp_push+0x4e8/0x770 net/ipv4/tcp.c:683
 tcp_sendmsg+0x1275/0x39a0 net/ipv4/tcp.c:1337
 inet_sendmsg+0x164/0x5b0 net/ipv4/af_inet.c:761
 sock_sendmsg_nosec net/socket.c:633 [inline]
 sock_sendmsg+0xca/0x110 net/socket.c:643
 SYSC_sendto+0x660/0x810 net/socket.c:1685
 SyS_sendto+0x40/0x50 net/socket.c:1653
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x4458d9
RSP: 002b:00007fdc14160b58 EFLAGS: 00000282 ORIG_RAX: 000000000000002c
RAX: ffffffffffffffda RBX: 000000000000001f RCX: 00000000004458d9
RDX: 0000000000000ee8 RSI: 0000000020051000 RDI: 000000000000001f
RBP: 00000000006e1b70 R08: 0000000020018fe0 R09: 000000000000000e
R10: 0000000000000800 R11: 0000000000000282 R12: 00000000007080a8
R13: ffffffffffffffff R14: ffffffffffffffff R15: 0000000020e42000
BUG: scheduling while atomic: syz-executor5/23233/0x00000106
INFO: lockdep is turned off.
Modules linked in:
Kernel panic - not syncing: scheduling while atomic

CPU: 1 PID: 23233 Comm: syz-executor5 Tainted: G        W       4.10.0+ #229
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 <IRQ>
 __dump_stack lib/dump_stack.c:15 [inline]
 dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
 panic+0x1fb/0x412 kernel/panic.c:179
 __schedule_bug+0x224/0x240 kernel/sched/core.c:3238
 schedule_debug kernel/sched/core.c:3255 [inline]
 __schedule+0x1332/0x2290 kernel/sched/core.c:3355
 schedule+0x108/0x440 kernel/sched/core.c:3479
 schedule_preempt_disabled+0x10/0x20 kernel/sched/core.c:3512
 mutex_optimistic_spin kernel/locking/mutex.c:579 [inline]
 __mutex_lock_common kernel/locking/mutex.c:757 [inline]
 __mutex_lock+0x112d/0x1730 kernel/locking/mutex.c:891
 mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:906
 jump_label_lock kernel/jump_label.c:26 [inline]
 static_key_slow_inc+0x21f/0x3c0 kernel/jump_label.c:127
 net_enable_timestamp+0x15/0x20 net/core/dev.c:1713
 sk_clone_lock+0xef0/0x12c0 net/core/sock.c:1588
 inet_csk_clone_lock+0x91/0x4f0 net/ipv4/inet_connection_sock.c:781
 tcp_create_openreq_child+0xab/0x1e80 net/ipv4/tcp_minisocks.c:436
 tcp_v6_syn_recv_sock+0x210/0x1fb0 net/ipv6/tcp_ipv6.c:1101
 tcp_get_cookie_sock+0x115/0x530 net/ipv4/syncookies.c:212
 cookie_v6_check+0x16f9/0x20d0 net/ipv6/syncookies.c:245
 tcp_v6_cookie_check net/ipv6/tcp_ipv6.c:987 [inline]
 tcp_v6_do_rcv+0xfc3/0x1420 net/ipv6/tcp_ipv6.c:1296
 tcp_v6_rcv+0x22d2/0x2da0 net/ipv6/tcp_ipv6.c:1485
 ip6_input_finish+0x45b/0x1700 net/ipv6/ip6_input.c:279
 NF_HOOK include/linux/netfilter.h:257 [inline]
 ip6_input+0xdb/0x580 net/ipv6/ip6_input.c:322
 dst_input include/net/dst.h:492 [inline]
 ip6_rcv_finish+0x194/0x720 net/ipv6/ip6_input.c:69
 NF_HOOK include/linux/netfilter.h:257 [inline]
 ipv6_rcv+0x12df/0x2380 net/ipv6/ip6_input.c:203
 __netif_receive_skb_core+0x1fb3/0x33a0 net/core/dev.c:4179
 __netif_receive_skb+0x2a/0x170 net/core/dev.c:4217
 process_backlog+0x11e/0x730 net/core/dev.c:4837
 napi_poll net/core/dev.c:5171 [inline]
 net_rx_action+0xeb4/0x1580 net/core/dev.c:5236
 __do_softirq+0x31f/0xbe7 kernel/softirq.c:284
 do_softirq_own_stack+0x1c/0x30 arch/x86/entry/entry_64.S:902
 </IRQ>
 do_softirq.part.21+0x2c0/0x300 kernel/softirq.c:328
 do_softirq kernel/softirq.c:176 [inline]
 __local_bh_enable_ip+0x24c/0x290 kernel/softirq.c:181
 local_bh_enable include/linux/bottom_half.h:31 [inline]
 rcu_read_unlock_bh include/linux/rcupdate.h:971 [inline]
 ip6_finish_output2+0xb85/0x2380 net/ipv6/ip6_output.c:124
 ip6_finish_output+0x2f9/0x950 net/ipv6/ip6_output.c:149
 NF_HOOK_COND include/linux/netfilter.h:246 [inline]
 ip6_output+0x1cb/0x8c0 net/ipv6/ip6_output.c:163
 ip6_xmit+0xc36/0x1e80 include/net/dst.h:486
 inet6_csk_xmit+0x320/0x5d0 net/ipv6/inet6_connection_sock.c:139
 tcp_transmit_skb+0x1ab4/0x3460 net/ipv4/tcp_output.c:1057
 tcp_write_xmit+0x6e6/0x50d0 net/ipv4/tcp_output.c:2260
 __tcp_push_pending_frames+0xfa/0x380 net/ipv4/tcp_output.c:2445
 tcp_push+0x4e8/0x770 net/ipv4/tcp.c:683
 tcp_sendmsg+0x1275/0x39a0 net/ipv4/tcp.c:1337
 inet_sendmsg+0x164/0x5b0 net/ipv4/af_inet.c:761
 sock_sendmsg_nosec net/socket.c:633 [inline]
 sock_sendmsg+0xca/0x110 net/socket.c:643
 SYSC_sendto+0x660/0x810 net/socket.c:1685
 SyS_sendto+0x40/0x50 net/socket.c:1653
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x4458d9
RSP: 002b:00007fdc14160b58 EFLAGS: 00000282 ORIG_RAX: 000000000000002c
RAX: ffffffffffffffda RBX: 000000000000001f RCX: 00000000004458d9
RDX: 0000000000000ee8 RSI: 0000000020051000 RDI: 000000000000001f
RBP: 00000000006e1b70 R08: 0000000020018fe0 R09: 000000000000000e
R10: 0000000000000800 R11: 0000000000000282 R12: 00000000007080a8
R13: ffffffffffffffff R14: ffffffffffffffff R15: 0000000020e42000
