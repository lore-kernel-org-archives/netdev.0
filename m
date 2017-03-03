From: Dmitry Vyukov <dvyukov@google.com>
Subject: net: heap out-of-bounds in fib6_clean_node/rt6_fill_node/fib6_age/fib6_prune_clone
Date: Fri, 3 Mar 2017 15:39:14 +0100
Message-ID: <CACT4Y+YrA45diWz_8f4St8oX6aTC1kuGXMUvniGRbqXSGwawZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>
To: David Ahern <dsa@cumulusnetworks.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f171.google.com ([209.85.217.171]:35075 "EHLO
        mail-ua0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751551AbdCCPIY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 10:08:24 -0500
Received: by mail-ua0-f171.google.com with SMTP id q7so82732285uaf.2
        for <netdev@vger.kernel.org>; Fri, 03 Mar 2017 07:07:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I am getting heap out-of-bounds reports in
fib6_clean_node/rt6_fill_node/fib6_age/fib6_prune_clone while running
syzkaller fuzzer on 86292b33d4b79ee03e2f43ea0381ef85f077c760. They all
follow the same pattern: an object of size 216 is allocated from
ip_dst_cache slab, and then accessed at offset 272/276 withing
fib6_walk. Looks like type confusion. Unfortunately this is not
reproducible.

==================================================================
BUG: KASAN: slab-out-of-bounds in rt6_dump_route+0x293/0x2f0
net/ipv6/route.c:3547 at addr ffff88004b864514
Read of size 4 by task syz-executor7/25042
CPU: 0 PID: 25042 Comm: syz-executor7 Not tainted 4.10.0+ #234
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:15 [inline]
 dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
 kasan_object_err+0x1c/0x70 mm/kasan/report.c:166
 print_address_description mm/kasan/report.c:204 [inline]
 kasan_report_error mm/kasan/report.c:288 [inline]
 kasan_report.part.2+0x198/0x440 mm/kasan/report.c:310
 kasan_report mm/kasan/report.c:330 [inline]
 __asan_report_load4_noabort+0x29/0x30 mm/kasan/report.c:330
 rt6_dump_route+0x293/0x2f0 net/ipv6/route.c:3547
 fib6_dump_node+0x101/0x1a0 net/ipv6/ip6_fib.c:315
 fib6_walk_continue+0x4b3/0x620 net/ipv6/ip6_fib.c:1576
 fib6_walk+0x1cf/0x300 net/ipv6/ip6_fib.c:1621
 fib6_dump_table net/ipv6/ip6_fib.c:374 [inline]
 inet6_dump_fib+0x832/0xea0 net/ipv6/ip6_fib.c:447
 rtnl_dump_all+0x8a/0x2a0 net/core/rtnetlink.c:2776
 netlink_dump+0x54d/0xd40 net/netlink/af_netlink.c:2127
 __netlink_dump_start+0x4e5/0x760 net/netlink/af_netlink.c:2217
 netlink_dump_start include/linux/netlink.h:165 [inline]
 rtnetlink_rcv_msg+0x4a3/0x860 net/core/rtnetlink.c:4094
 netlink_rcv_skb+0x2ab/0x390 net/netlink/af_netlink.c:2298
 rtnetlink_rcv+0x2a/0x40 net/core/rtnetlink.c:4110
 netlink_unicast_kernel net/netlink/af_netlink.c:1231 [inline]
 netlink_unicast+0x514/0x730 net/netlink/af_netlink.c:1257
 netlink_sendmsg+0xa9f/0xe50 net/netlink/af_netlink.c:1803
 sock_sendmsg_nosec net/socket.c:633 [inline]
 sock_sendmsg+0xca/0x110 net/socket.c:643
 sock_write_iter+0x326/0x600 net/socket.c:846
 new_sync_write fs/read_write.c:499 [inline]
 __vfs_write+0x483/0x740 fs/read_write.c:512
 vfs_write+0x187/0x530 fs/read_write.c:560
 SYSC_write fs/read_write.c:607 [inline]
 SyS_write+0xfb/0x230 fs/read_write.c:599
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x4458d9
RSP: 002b:00007fe10102bb58 EFLAGS: 00000292 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 0000000000000006 RCX: 00000000004458d9
RDX: 000000000000001f RSI: 0000000020691000 RDI: 0000000000000006
RBP: 00000000006e2fc0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000292 R12: 0000000000708000
R13: 00000000209e1ff7 R14: 0000000000000001 R15: fffffffffffffffd
Object at ffff88004b864400, in cache ip_dst_cache size: 216
Allocated:
PID = 21976
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
 save_stack+0x43/0xd0 mm/kasan/kasan.c:502
 set_track mm/kasan/kasan.c:514 [inline]
 kasan_kmalloc+0xaa/0xd0 mm/kasan/kasan.c:605
 kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:544
 kmem_cache_alloc+0x102/0x680 mm/slab.c:3571
 dst_alloc+0x11b/0x1a0 net/core/dst.c:209
 rt_dst_alloc+0xf0/0x580 net/ipv4/route.c:1482
 __mkroute_output net/ipv4/route.c:2163 [inline]
 __ip_route_output_key_hash+0xce3/0x2c70 net/ipv4/route.c:2373
 __ip_route_output_key include/net/route.h:122 [inline]
 ip_route_output_flow+0x29/0xa0 net/ipv4/route.c:2459
 ip_route_output_key include/net/route.h:132 [inline]
 sctp_v4_get_dst+0x5d2/0x1570 net/sctp/protocol.c:454
 sctp_transport_route+0xa8/0x420 net/sctp/transport.c:292
 sctp_assoc_add_peer+0x5a5/0x1470 net/sctp/associola.c:653
 sctp_sendmsg+0x1800/0x3970 net/sctp/socket.c:1870
 inet_sendmsg+0x164/0x5b0 net/ipv4/af_inet.c:761
 sock_sendmsg_nosec net/socket.c:633 [inline]
 sock_sendmsg+0xca/0x110 net/socket.c:643
 ___sys_sendmsg+0x4a3/0x9f0 net/socket.c:1985
 __sys_sendmmsg+0x25c/0x750 net/socket.c:2075
 SYSC_sendmmsg net/socket.c:2106 [inline]
 SyS_sendmmsg+0x35/0x60 net/socket.c:2101
 entry_SYSCALL_64_fastpath+0x1f/0xc2
Freed:
PID = 15058
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
 save_stack+0x43/0xd0 mm/kasan/kasan.c:502
 set_track mm/kasan/kasan.c:514 [inline]
 kasan_slab_free+0x6f/0xb0 mm/kasan/kasan.c:578
 __cache_free mm/slab.c:3513 [inline]
 kmem_cache_free+0x71/0x240 mm/slab.c:3773
 dst_destroy+0x1fd/0x330 net/core/dst.c:269
 dst_free include/net/dst.h:428 [inline]
 rt_fibinfo_free_cpus net/ipv4/fib_semantics.c:198 [inline]
 free_fib_info_rcu+0x399/0x590 net/ipv4/fib_semantics.c:213
 __rcu_reclaim kernel/rcu/rcu.h:118 [inline]
 rcu_do_batch.isra.67+0xa31/0xe50 kernel/rcu/tree.c:2877
 invoke_rcu_callbacks kernel/rcu/tree.c:3140 [inline]
 __rcu_process_callbacks kernel/rcu/tree.c:3107 [inline]
 rcu_process_callbacks+0x45b/0xc50 kernel/rcu/tree.c:3124
 __do_softirq+0x31f/0xbe7 kernel/softirq.c:284
Memory state around the buggy address:
 ffff88004b864400: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 ffff88004b864480: 00 00 00 00 00 00 00 00 00 00 00 fc fc fc fc fc
>ffff88004b864500: fc fc fc fc fc fc fc fc 00 00 00 00 00 00 00 00
                         ^
 ffff88004b864580: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 ffff88004b864600: 00 00 00 fc fc fc fc fc fc fc fc fc fc fc fc fc
==================================================================

==================================================================
BUG: KASAN: slab-out-of-bounds in fib6_age+0x3fd/0x480
net/ipv6/ip6_fib.c:1769 at addr ffff880088d1bb54
Read of size 4 by task swapper/1/0
CPU: 1 PID: 0 Comm: swapper/1 Not tainted 4.10.0+ #260
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 <IRQ>
 __dump_stack lib/dump_stack.c:15 [inline]
 dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
 kasan_object_err+0x1c/0x70 mm/kasan/report.c:166
 print_address_description mm/kasan/report.c:204 [inline]
 kasan_report_error mm/kasan/report.c:288 [inline]
 kasan_report.part.2+0x198/0x440 mm/kasan/report.c:310
 kasan_report mm/kasan/report.c:330 [inline]
 __asan_report_load4_noabort+0x29/0x30 mm/kasan/report.c:330
 fib6_age+0x3fd/0x480 net/ipv6/ip6_fib.c:1769
 fib6_clean_node+0x356/0x550 net/ipv6/ip6_fib.c:1647
 fib6_walk_continue+0x4b3/0x620 net/ipv6/ip6_fib.c:1576
 fib6_walk+0x1cf/0x300 net/ipv6/ip6_fib.c:1621
 fib6_clean_tree+0x266/0x3a0 net/ipv6/ip6_fib.c:1693
 __fib6_clean_all+0x1e1/0x360 net/ipv6/ip6_fib.c:1709
 fib6_clean_all net/ipv6/ip6_fib.c:1720 [inline]
 fib6_run_gc+0x185/0x3d0 net/ipv6/ip6_fib.c:1817
 fib6_gc_timer_cb+0x1c/0x20 net/ipv6/ip6_fib.c:1832
 call_timer_fn+0x241/0x820 kernel/time/timer.c:1266
 expire_timers kernel/time/timer.c:1305 [inline]
 __run_timers+0x960/0xcf0 kernel/time/timer.c:1599
 run_timer_softirq+0x21/0x80 kernel/time/timer.c:1612
 __do_softirq+0x31f/0xbe7 kernel/softirq.c:284
 invoke_softirq kernel/softirq.c:364 [inline]
 irq_exit+0x1cc/0x200 kernel/softirq.c:405
 exiting_irq arch/x86/include/asm/apic.h:658 [inline]
 smp_apic_timer_interrupt+0x76/0xa0 arch/x86/kernel/apic/apic.c:962
 apic_timer_interrupt+0x93/0xa0 arch/x86/entry/entry_64.S:487
RIP: 0010:native_safe_halt+0x6/0x10 arch/x86/include/asm/irqflags.h:53
RSP: 0018:ffff88004dd8fc10 EFLAGS: 00000282 ORIG_RAX: ffffffffffffff10
RAX: dffffc0000000000 RBX: 1ffff10009bb1f85 RCX: 0000000000000000
RDX: 1ffffffff0a18ebc RSI: 0000000000000001 RDI: ffffffff850c75e0
RBP: ffff88004dd8fc10 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 1ffff10009bb1fa9
R13: ffff88004dd8fcc8 R14: ffffffff85697338 R15: ffff88004dd8fe68
 </IRQ>
 arch_safe_halt arch/x86/include/asm/paravirt.h:98 [inline]
 default_idle+0xbf/0x440 arch/x86/kernel/process.c:271
 arch_cpu_idle+0xa/0x10 arch/x86/kernel/process.c:262
 default_idle_call+0x36/0x90 kernel/sched/idle.c:96
 cpuidle_idle_call kernel/sched/idle.c:154 [inline]
 do_idle+0x373/0x520 kernel/sched/idle.c:243
 cpu_startup_entry+0x18/0x20 kernel/sched/idle.c:345
 start_secondary+0x36c/0x460 arch/x86/kernel/smpboot.c:272
 start_cpu+0x14/0x14 arch/x86/kernel/head_64.S:306
Object at ffff880088d1ba40, in cache ip_dst_cache size: 216
Allocated:
PID = 30165
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
 save_stack+0x43/0xd0 mm/kasan/kasan.c:502
 set_track mm/kasan/kasan.c:514 [inline]
 kasan_kmalloc+0xaa/0xd0 mm/kasan/kasan.c:605
 kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:544
 kmem_cache_alloc+0x102/0x680 mm/slab.c:3571
 dst_alloc+0x11b/0x1a0 net/core/dst.c:209
 rt_dst_alloc+0xf0/0x580 net/ipv4/route.c:1482
 __mkroute_output net/ipv4/route.c:2165 [inline]
 __ip_route_output_key_hash+0xce3/0x2c70 net/ipv4/route.c:2375
 __ip_route_output_key include/net/route.h:122 [inline]
 ip_route_output_flow+0x29/0xa0 net/ipv4/route.c:2461
 ip_route_output_key include/net/route.h:132 [inline]
 sctp_v4_get_dst+0x5d2/0x1570 net/sctp/protocol.c:458
 sctp_transport_route+0xa8/0x420 net/sctp/transport.c:292
 sctp_assoc_add_peer+0x5a5/0x1470 net/sctp/associola.c:653
 sctp_sendmsg+0x1800/0x3970 net/sctp/socket.c:1870
 inet_sendmsg+0x164/0x5b0 net/ipv4/af_inet.c:761
 sock_sendmsg_nosec net/socket.c:633 [inline]
 sock_sendmsg+0xca/0x110 net/socket.c:643
 SYSC_sendto+0x660/0x810 net/socket.c:1685
 SyS_sendto+0x40/0x50 net/socket.c:1653
 entry_SYSCALL_64_fastpath+0x1f/0xc2
Freed:
PID = 28880
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
 save_stack+0x43/0xd0 mm/kasan/kasan.c:502
 set_track mm/kasan/kasan.c:514 [inline]
 kasan_slab_free+0x6f/0xb0 mm/kasan/kasan.c:578
 __cache_free mm/slab.c:3513 [inline]
 kmem_cache_free+0x71/0x240 mm/slab.c:3773
 dst_destroy+0x1fd/0x330 net/core/dst.c:269
 dst_destroy_rcu+0x15/0x40 net/core/dst.c:294
 __rcu_reclaim kernel/rcu/rcu.h:118 [inline]
 rcu_do_batch.isra.67+0xa31/0xe50 kernel/rcu/tree.c:2877
 invoke_rcu_callbacks kernel/rcu/tree.c:3140 [inline]
 __rcu_process_callbacks kernel/rcu/tree.c:3107 [inline]
 rcu_process_callbacks+0x45b/0xc50 kernel/rcu/tree.c:3124
 __do_softirq+0x31f/0xbe7 kernel/softirq.c:284
Memory state around the buggy address:
 ffff880088d1ba00: fc fc fc fc fc fc fc fc 00 00 00 00 00 00 00 00
 ffff880088d1ba80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>ffff880088d1bb00: 00 00 00 fc fc fc fc fc fc fc fc fc fc fc fc fc
                                                 ^
 ffff880088d1bb80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 ffff880088d1bc00: 00 00 00 00 00 00 00 00 00 00 00 fc fc fc fc fc
==================================================================

==================================================================
BUG: KASAN: slab-out-of-bounds in rt6_fill_node.isra.61+0x1434/0x1780
net/ipv6/route.c:3396 at addr ffff88004b5c0790
Read of size 4 by task syz-executor3/3502
CPU: 0 PID: 3502 Comm: syz-executor3 Not tainted 4.10.0+ #260
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:15 [inline]
 dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
 kasan_object_err+0x1c/0x70 mm/kasan/report.c:166
 print_address_description mm/kasan/report.c:204 [inline]
 kasan_report_error mm/kasan/report.c:288 [inline]
 kasan_report.part.2+0x198/0x440 mm/kasan/report.c:310
 kasan_report mm/kasan/report.c:330 [inline]
 __asan_report_load4_noabort+0x29/0x30 mm/kasan/report.c:330
 rt6_fill_node.isra.61+0x1434/0x1780 net/ipv6/route.c:3396
 rt6_dump_route+0x245/0x2f0 net/ipv6/route.c:3557
 fib6_dump_node+0x101/0x1a0 net/ipv6/ip6_fib.c:315
 fib6_walk_continue+0x4b3/0x620 net/ipv6/ip6_fib.c:1576
 fib6_walk+0x1cf/0x300 net/ipv6/ip6_fib.c:1621
 fib6_dump_table net/ipv6/ip6_fib.c:374 [inline]
 inet6_dump_fib+0x832/0xea0 net/ipv6/ip6_fib.c:447
 rtnl_dump_all+0x8a/0x2a0 net/core/rtnetlink.c:2776
 netlink_dump+0x54d/0xd40 net/netlink/af_netlink.c:2127
 netlink_recvmsg+0xb6a/0x1500 net/netlink/af_netlink.c:1886
 sock_recvmsg_nosec net/socket.c:740 [inline]
 sock_recvmsg+0xd7/0x110 net/socket.c:747
 ___sys_recvmsg+0x2b8/0x6b0 net/socket.c:2144
 __sys_recvmsg+0x135/0x300 net/socket.c:2189
 SYSC_recvmsg net/socket.c:2201 [inline]
 SyS_recvmsg+0x2d/0x50 net/socket.c:2196
 do_syscall_64+0x2e8/0x930 arch/x86/entry/common.c:280
 entry_SYSCALL64_slow_path+0x25/0x25
RIP: 0033:0x4458d9
RSP: 002b:00007f694bf1fb58 EFLAGS: 00000286 ORIG_RAX: 000000000000002f
RAX: ffffffffffffffda RBX: 0000000000708000 RCX: 00000000004458d9
RDX: 0000000000000000 RSI: 00000000206a2fc8 RDI: 0000000000000019
RBP: 00000000000036d0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000286 R12: 00000000006e1790
R13: 0000000000000019 R14: 00000000206a2fc8 R15: 0000000000000000
Object at ffff88004b5c0680, in cache ip_dst_cache size: 216
Allocated:
PID = 1362
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
 save_stack+0x43/0xd0 mm/kasan/kasan.c:502
 set_track mm/kasan/kasan.c:514 [inline]
 kasan_kmalloc+0xaa/0xd0 mm/kasan/kasan.c:605
 kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:544
 kmem_cache_alloc+0x102/0x680 mm/slab.c:3571
 dst_alloc+0x11b/0x1a0 net/core/dst.c:209
 rt_dst_alloc+0xf0/0x580 net/ipv4/route.c:1482
 ip_route_input_slow+0xe67/0x21e0 net/ipv4/route.c:1936
 ip_route_input_noref+0x13c/0x10b0 net/ipv4/route.c:2058
 ip_rcv_finish+0x301/0x1b40 net/ipv4/ip_input.c:344
 NF_HOOK include/linux/netfilter.h:257 [inline]
 ip_rcv+0xd75/0x19a0 net/ipv4/ip_input.c:487
 __netif_receive_skb_core+0x1ac8/0x33f0 net/core/dev.c:4179
 __netif_receive_skb+0x2a/0x170 net/core/dev.c:4217
 netif_receive_skb_internal+0xf0/0x400 net/core/dev.c:4245
 napi_skb_finish net/core/dev.c:4602 [inline]
 napi_gro_receive+0x4d4/0x670 net/core/dev.c:4636
 e1000_receive_skb drivers/net/ethernet/intel/e1000/e1000_main.c:4033 [inline]
 e1000_clean_rx_irq+0x5e0/0x1490
drivers/net/ethernet/intel/e1000/e1000_main.c:4489
 e1000_clean+0xb94/0x2920 drivers/net/ethernet/intel/e1000/e1000_main.c:3834
 napi_poll net/core/dev.c:5171 [inline]
 net_rx_action+0xeb4/0x1580 net/core/dev.c:5236
 __do_softirq+0x31f/0xbe7 kernel/softirq.c:284
Freed:
PID = 25328
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
 save_stack+0x43/0xd0 mm/kasan/kasan.c:502
 set_track mm/kasan/kasan.c:514 [inline]
 kasan_slab_free+0x6f/0xb0 mm/kasan/kasan.c:578
 __cache_free mm/slab.c:3513 [inline]
 kmem_cache_free+0x71/0x240 mm/slab.c:3773
 dst_destroy+0x1fd/0x330 net/core/dst.c:269
 dst_free include/net/dst.h:428 [inline]
 dst_rcu_free+0x152/0x190 include/net/dst.h:438
 __rcu_reclaim kernel/rcu/rcu.h:118 [inline]
 rcu_do_batch.isra.67+0xa31/0xe50 kernel/rcu/tree.c:2877
 invoke_rcu_callbacks kernel/rcu/tree.c:3140 [inline]
 __rcu_process_callbacks kernel/rcu/tree.c:3107 [inline]
 rcu_process_callbacks+0x45b/0xc50 kernel/rcu/tree.c:3124
 __do_softirq+0x31f/0xbe7 kernel/softirq.c:284
Memory state around the buggy address:
 ffff88004b5c0680: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 ffff88004b5c0700: 00 00 00 00 00 00 00 00 00 00 00 fc fc fc fc fc
>ffff88004b5c0780: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
                         ^
 ffff88004b5c0800: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff88004b5c0880: fb fb fb fc fc fc fc fc fc fc fc fc fc fc fc fc
==================================================================

==================================================================
BUG: KASAN: slab-out-of-bounds in fib6_prune_clone+0x4e/0x50
net/ipv6/ip6_fib.c:1725 at addr ffff880053497d14
Read of size 4 by task syz-executor1/20792
CPU: 0 PID: 20792 Comm: syz-executor1 Not tainted 4.10.0+ #260
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:15 [inline]
 dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
 kasan_object_err+0x1c/0x70 mm/kasan/report.c:166
 print_address_description mm/kasan/report.c:204 [inline]
 kasan_report_error mm/kasan/report.c:288 [inline]
 kasan_report.part.2+0x198/0x440 mm/kasan/report.c:310
 kasan_report mm/kasan/report.c:330 [inline]
 __asan_report_load4_noabort+0x29/0x30 mm/kasan/report.c:330
 fib6_prune_clone+0x4e/0x50 net/ipv6/ip6_fib.c:1725
 fib6_clean_node+0x356/0x550 net/ipv6/ip6_fib.c:1647
 fib6_walk_continue+0x4b3/0x620 net/ipv6/ip6_fib.c:1576
 fib6_walk+0x1cf/0x300 net/ipv6/ip6_fib.c:1621
 fib6_clean_tree+0x266/0x3a0 net/ipv6/ip6_fib.c:1693
 fib6_prune_clones net/ipv6/ip6_fib.c:1735 [inline]
 fib6_add+0x2612/0x30a0 net/ipv6/ip6_fib.c:1068
 __ip6_ins_rt+0x60/0x80 net/ipv6/route.c:948
 ip6_route_add+0x1a7/0x310 net/ipv6/route.c:2127
 addrconf_prefix_route+0x391/0x560 net/ipv6/addrconf.c:2247
 inet6_addr_add+0x2aa/0x370 net/ipv6/addrconf.c:2799
 addrconf_add_ifaddr+0x169/0x200 net/ipv6/addrconf.c:2878
 inet6_ioctl+0x111/0x1e0 net/ipv6/af_inet6.c:523
 sock_do_ioctl+0x65/0xb0 net/socket.c:895
 sock_ioctl+0x2c2/0x440 net/socket.c:993
 vfs_ioctl fs/ioctl.c:43 [inline]
 do_vfs_ioctl+0x1bf/0x1790 fs/ioctl.c:683
 SYSC_ioctl fs/ioctl.c:698 [inline]
 SyS_ioctl+0x8f/0xc0 fs/ioctl.c:689
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x4458d9
RSP: 002b:00007fce75526b58 EFLAGS: 00000286 ORIG_RAX: 0000000000000010
RAX: ffffffffffffffda RBX: 0000000000000005 RCX: 00000000004458d9
RDX: 0000000020000000 RSI: 0000000000008916 RDI: 0000000000000005
RBP: 00000000006df0c0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000286 R12: 0000000000708000
R13: 0000000020df4ff5 R14: 0000000000000007 R15: 0000000000034800
Object at ffff880053497c00, in cache ip_dst_cache size: 216
Allocated:
PID = 1306
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
 save_stack+0x43/0xd0 mm/kasan/kasan.c:502
 set_track mm/kasan/kasan.c:514 [inline]
 kasan_kmalloc+0xaa/0xd0 mm/kasan/kasan.c:605
 kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:544
 kmem_cache_alloc+0x102/0x680 mm/slab.c:3571
 dst_alloc+0x11b/0x1a0 net/core/dst.c:209
 rt_dst_alloc+0xf0/0x580 net/ipv4/route.c:1482
 __mkroute_output net/ipv4/route.c:2165 [inline]
 __ip_route_output_key_hash+0xce3/0x2c70 net/ipv4/route.c:2375
 __ip_route_output_key include/net/route.h:122 [inline]
 ip_route_output_flow+0x29/0xa0 net/ipv4/route.c:2461
 ip_route_output_ports include/net/route.h:159 [inline]
 ip_queue_xmit+0x1581/0x1a20 net/ipv4/ip_output.c:459
 tcp_transmit_skb+0x1ab4/0x3460 net/ipv4/tcp_output.c:1057
 tcp_write_xmit+0x6e6/0x50d0 net/ipv4/tcp_output.c:2260
 __tcp_push_pending_frames+0xfa/0x380 net/ipv4/tcp_output.c:2445
 tcp_push+0x4e8/0x770 net/ipv4/tcp.c:683
 tcp_sendmsg+0x1275/0x39a0 net/ipv4/tcp.c:1337
 inet_sendmsg+0x164/0x5b0 net/ipv4/af_inet.c:761
 sock_sendmsg_nosec net/socket.c:633 [inline]
 sock_sendmsg+0xca/0x110 net/socket.c:643
 sock_write_iter+0x326/0x600 net/socket.c:846
 new_sync_write fs/read_write.c:499 [inline]
 __vfs_write+0x483/0x740 fs/read_write.c:512
 vfs_write+0x187/0x530 fs/read_write.c:560
 SYSC_write fs/read_write.c:607 [inline]
 SyS_write+0xfb/0x230 fs/read_write.c:599
 entry_SYSCALL_64_fastpath+0x1f/0xc2
Freed:
PID = 0
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
 save_stack+0x43/0xd0 mm/kasan/kasan.c:502
 set_track mm/kasan/kasan.c:514 [inline]
 kasan_slab_free+0x6f/0xb0 mm/kasan/kasan.c:578
 __cache_free mm/slab.c:3513 [inline]
 kmem_cache_free+0x71/0x240 mm/slab.c:3773
 dst_destroy+0x1fd/0x330 net/core/dst.c:269
 dst_free include/net/dst.h:428 [inline]
 dst_rcu_free+0x152/0x190 include/net/dst.h:438
 __rcu_reclaim kernel/rcu/rcu.h:118 [inline]
 rcu_do_batch.isra.67+0xa31/0xe50 kernel/rcu/tree.c:2877
 invoke_rcu_callbacks kernel/rcu/tree.c:3140 [inline]
 __rcu_process_callbacks kernel/rcu/tree.c:3107 [inline]
 rcu_process_callbacks+0x45b/0xc50 kernel/rcu/tree.c:3124
 __do_softirq+0x31f/0xbe7 kernel/softirq.c:284
Memory state around the buggy address:
 ffff880053497c00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 ffff880053497c80: 00 00 00 00 00 00 00 00 00 00 00 fc fc fc fc fc
>ffff880053497d00: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
                         ^
 ffff880053497d80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff880053497e00: fb fb fb fc fc fc fc fc fc fc fc fc fc fc fc fc
==================================================================

==================================================================
BUG: KASAN: slab-out-of-bounds in rt6_fill_node.isra.61+0x1434/0x1780
net/ipv6/route.c:3396 at addr ffff88004af7a650
Read of size 4 by task syz-executor0/14836
CPU: 1 PID: 14836 Comm: syz-executor0 Not tainted 4.10.0+ #260
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:15 [inline]
 dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
9pnet_virtio: no channels available for device ./bus
 kasan_object_err+0x1c/0x70 mm/kasan/report.c:166
 print_address_description mm/kasan/report.c:204 [inline]
 kasan_report_error mm/kasan/report.c:288 [inline]
 kasan_report.part.2+0x198/0x440 mm/kasan/report.c:310
 kasan_report mm/kasan/report.c:330 [inline]
 __asan_report_load4_noabort+0x29/0x30 mm/kasan/report.c:330
 rt6_fill_node.isra.61+0x1434/0x1780 net/ipv6/route.c:3396
 rt6_dump_route+0x245/0x2f0 net/ipv6/route.c:3557
 fib6_dump_node+0x101/0x1a0 net/ipv6/ip6_fib.c:315
 fib6_walk_continue+0x4b3/0x620 net/ipv6/ip6_fib.c:1576
 fib6_walk+0x1cf/0x300 net/ipv6/ip6_fib.c:1621
 fib6_dump_table net/ipv6/ip6_fib.c:374 [inline]
 inet6_dump_fib+0x832/0xea0 net/ipv6/ip6_fib.c:447
 rtnl_dump_all+0x8a/0x2a0 net/core/rtnetlink.c:2776
 netlink_dump+0x54d/0xd40 net/netlink/af_netlink.c:2127
 netlink_recvmsg+0xb6a/0x1500 net/netlink/af_netlink.c:1886
 sock_recvmsg_nosec net/socket.c:740 [inline]
 sock_recvmsg+0xd7/0x110 net/socket.c:747
 ___sys_recvmsg+0x2b8/0x6b0 net/socket.c:2144
 __sys_recvmsg+0x135/0x300 net/socket.c:2189
 SYSC_recvmsg net/socket.c:2201 [inline]
 SyS_recvmsg+0x2d/0x50 net/socket.c:2196
 do_syscall_64+0x2e8/0x930 arch/x86/entry/common.c:280
 entry_SYSCALL64_slow_path+0x25/0x25
RIP: 0033:0x4458d9
RSP: 002b:00007f84c4ef1b58 EFLAGS: 00000286 ORIG_RAX: 000000000000002f
RAX: ffffffffffffffda RBX: 00000000007083f0 RCX: 00000000004458d9
RDX: 0000000000000000 RSI: 00000000206a2fc8 RDI: 000000000000001a
RBP: 00000000000036d0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000286 R12: 00000000006e1790
R13: 000000000000001a R14: 00000000206a2fc8 R15: 0000000000000000
Object at ffff88004af7a540, in cache ip_dst_cache size: 216
Allocated:
PID = 1298
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
 save_stack+0x43/0xd0 mm/kasan/kasan.c:502
 set_track mm/kasan/kasan.c:514 [inline]
 kasan_kmalloc+0xaa/0xd0 mm/kasan/kasan.c:605
 kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:544
 kmem_cache_alloc+0x102/0x680 mm/slab.c:3571
 dst_alloc+0x11b/0x1a0 net/core/dst.c:209
 rt_dst_alloc+0xf0/0x580 net/ipv4/route.c:1482
 ip_route_input_slow+0xe67/0x21e0 net/ipv4/route.c:1936
 ip_route_input_noref+0x13c/0x10b0 net/ipv4/route.c:2058
 ip_rcv_finish+0x301/0x1b40 net/ipv4/ip_input.c:344
 NF_HOOK include/linux/netfilter.h:257 [inline]
 ip_rcv+0xd75/0x19a0 net/ipv4/ip_input.c:487
 __netif_receive_skb_core+0x1ac8/0x33f0 net/core/dev.c:4179
 __netif_receive_skb+0x2a/0x170 net/core/dev.c:4217
 netif_receive_skb_internal+0xf0/0x400 net/core/dev.c:4245
 napi_skb_finish net/core/dev.c:4602 [inline]
 napi_gro_receive+0x4d4/0x670 net/core/dev.c:4636
 e1000_receive_skb drivers/net/ethernet/intel/e1000/e1000_main.c:4033 [inline]
 e1000_clean_rx_irq+0x5e0/0x1490
drivers/net/ethernet/intel/e1000/e1000_main.c:4489
 e1000_clean+0xb94/0x2920 drivers/net/ethernet/intel/e1000/e1000_main.c:3834
 napi_poll net/core/dev.c:5171 [inline]
 net_rx_action+0xeb4/0x1580 net/core/dev.c:5236
 __do_softirq+0x31f/0xbe7 kernel/softirq.c:284
Freed:
PID = 3947
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
 save_stack+0x43/0xd0 mm/kasan/kasan.c:502
 set_track mm/kasan/kasan.c:514 [inline]
 kasan_slab_free+0x6f/0xb0 mm/kasan/kasan.c:578
 __cache_free mm/slab.c:3513 [inline]
 kmem_cache_free+0x71/0x240 mm/slab.c:3773
 dst_destroy+0x1fd/0x330 net/core/dst.c:269
 dst_destroy_rcu+0x15/0x40 net/core/dst.c:294
 __rcu_reclaim kernel/rcu/rcu.h:118 [inline]
 rcu_do_batch.isra.67+0xa31/0xe50 kernel/rcu/tree.c:2877
 invoke_rcu_callbacks kernel/rcu/tree.c:3140 [inline]
 __rcu_process_callbacks kernel/rcu/tree.c:3107 [inline]
 rcu_process_callbacks+0x45b/0xc50 kernel/rcu/tree.c:3124
 __do_softirq+0x31f/0xbe7 kernel/softirq.c:284
Memory state around the buggy address:
 ffff88004af7a500: fc fc fc fc fc fc fc fc 00 00 00 00 00 00 00 00
 ffff88004af7a580: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>ffff88004af7a600: 00 00 00 fc fc fc fc fc fc fc fc fc fc fc fc fc
                                                 ^
 ffff88004af7a680: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff88004af7a700: fb fb fb fb fb fb fb fb fb fb fb fc fc fc fc fc
==================================================================
