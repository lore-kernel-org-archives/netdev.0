From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net: heap out-of-bounds in fib6_clean_node/rt6_fill_node/fib6_age/fib6_prune_clone
Date: Sat, 4 Mar 2017 19:57:31 +0100
Message-ID: <CACT4Y+YCPxKkaZBfAabxtAV71R0ghLT-vUKVewJpm9wb2GXaEQ@mail.gmail.com>
References: <CACT4Y+YrA45diWz_8f4St8oX6aTC1kuGXMUvniGRbqXSGwawZQ@mail.gmail.com>
 <f707c195-251f-6058-5f4c-d55710533b11@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mahesh Bandewar <maheshb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        syzkaller <syzkaller@googlegroups.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f707c195-251f-6058-5f4c-d55710533b11@cumulusnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 3, 2017 at 8:12 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 3/3/17 6:39 AM, Dmitry Vyukov wrote:
>> I am getting heap out-of-bounds reports in
>> fib6_clean_node/rt6_fill_node/fib6_age/fib6_prune_clone while running
>> syzkaller fuzzer on 86292b33d4b79ee03e2f43ea0381ef85f077c760. They all
>> follow the same pattern: an object of size 216 is allocated from
>> ip_dst_cache slab, and then accessed at offset 272/276 withing
>> fib6_walk. Looks like type confusion. Unfortunately this is not
>> reproducible.
>
> I'll take a look this weekend or Monday at the latest.


I've got some additional useful info on this. I think this is
use-after-free rather than out-of-bounds. I've collected stack where
the route was disposed with call_rcu, see the last "Disposed" stack.
The crash happens when cmpxchg in rt_cache_route replaces an existing
route. And that route seems to have some existing pointers to it
(rt->dst.rt6_next) which fib6_walk uses to get to it after its
deletion.

==================================================================
BUG: KASAN: slab-out-of-bounds in rt6_dump_route+0x293/0x2f0
net/ipv6/route.c:3551 at addr ffff88007e523694
Read of size 4 by task syz-executor3/24426
CPU: 2 PID: 24426 Comm: syz-executor3 Not tainted 4.10.0+ #293
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x2fb/0x3fd lib/dump_stack.c:52
 kasan_object_err+0x1c/0x90 mm/kasan/report.c:166
 print_address_description mm/kasan/report.c:208 [inline]
 kasan_report_error mm/kasan/report.c:292 [inline]
 kasan_report.part.2+0x1b0/0x460 mm/kasan/report.c:314
 kasan_report mm/kasan/report.c:334 [inline]
 __asan_report_load4_noabort+0x29/0x30 mm/kasan/report.c:334
 rt6_dump_route+0x293/0x2f0 net/ipv6/route.c:3551
 fib6_dump_node+0x101/0x1a0 net/ipv6/ip6_fib.c:315
 fib6_walk_continue+0x4b3/0x620 net/ipv6/ip6_fib.c:1576
 fib6_walk+0x91/0xf0 net/ipv6/ip6_fib.c:1621
 fib6_dump_table net/ipv6/ip6_fib.c:374 [inline]
 inet6_dump_fib+0x832/0xea0 net/ipv6/ip6_fib.c:447
 rtnl_dump_all+0x8a/0x2a0 net/core/rtnetlink.c:2776
 netlink_dump+0x54d/0xd40 net/netlink/af_netlink.c:2127
 __netlink_dump_start+0x50e/0x790 net/netlink/af_netlink.c:2217
 netlink_dump_start include/linux/netlink.h:165 [inline]
 rtnetlink_rcv_msg+0x4a3/0x860 net/core/rtnetlink.c:4094
 netlink_rcv_skb+0x2ab/0x390 net/netlink/af_netlink.c:2298
 rtnetlink_rcv+0x2a/0x40 net/core/rtnetlink.c:4110
 netlink_unicast_kernel net/netlink/af_netlink.c:1231 [inline]
 netlink_unicast+0x525/0x730 net/netlink/af_netlink.c:1257
 netlink_sendmsg+0xab3/0xe70 net/netlink/af_netlink.c:1803
 sock_sendmsg_nosec net/socket.c:633 [inline]
 sock_sendmsg+0xca/0x110 net/socket.c:643
 sock_write_iter+0x326/0x600 net/socket.c:846
 call_write_iter include/linux/fs.h:1733 [inline]
 new_sync_write fs/read_write.c:497 [inline]
 __vfs_write+0x483/0x740 fs/read_write.c:510
 vfs_write+0x187/0x530 fs/read_write.c:558
 SYSC_write fs/read_write.c:605 [inline]
 SyS_write+0xfb/0x230 fs/read_write.c:597
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x4458d9
RSP: 002b:00007feb6f154b58 EFLAGS: 00000292 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 0000000000000006 RCX: 00000000004458d9
RDX: 000000000000001f RSI: 00000000208a8000 RDI: 0000000000000006
RBP: 00000000006e2fc0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000292 R12: 0000000000708000
R13: 0000000000000005 R14: 0000000020078fd0 R15: 0000000000000030
Object at ffff88007e523580, in cache ip_dst_cache size: 216
Allocated:
PID = 21468
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:513
 set_track mm/kasan/kasan.c:525 [inline]
 kasan_kmalloc+0xaa/0xd0 mm/kasan/kasan.c:616
 kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:555
 kmem_cache_alloc+0x102/0x6e0 mm/slab.c:3572
 dst_alloc+0x11b/0x1a0 net/core/dst.c:209
 rt_dst_alloc+0xf0/0x580 net/ipv4/route.c:1482
 __mkroute_output net/ipv4/route.c:2165 [inline]
 __ip_route_output_key_hash+0xce3/0x2ca0 net/ipv4/route.c:2375
 __ip_route_output_key include/net/route.h:122 [inline]
 ip_route_connect include/net/route.h:289 [inline]
 tcp_v4_connect+0x11f2/0x2070 net/ipv4/tcp_ipv4.c:170
 __inet_stream_connect+0x2d1/0xf90 net/ipv4/af_inet.c:618
 inet_stream_connect+0x58/0xa0 net/ipv4/af_inet.c:682
 SYSC_connect+0x251/0x580 net/socket.c:1577
 SyS_connect+0x24/0x30 net/socket.c:1558
 entry_SYSCALL_64_fastpath+0x1f/0xc2
Freed:
PID = 20
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:513
 set_track mm/kasan/kasan.c:525 [inline]
 kasan_slab_free+0x6f/0xb0 mm/kasan/kasan.c:589
 __cache_free mm/slab.c:3514 [inline]
 kmem_cache_free+0x71/0x240 mm/slab.c:3774
 dst_destroy+0x211/0x340 net/core/dst.c:269
 dst_free include/net/dst.h:428 [inline]
 dst_rcu_free+0x152/0x190 include/net/dst.h:438
 __rcu_reclaim kernel/rcu/rcu.h:118 [inline]
 rcu_do_batch.isra.66+0xa31/0xe50 kernel/rcu/tree.c:2880
 invoke_rcu_callbacks kernel/rcu/tree.c:3143 [inline]
 __rcu_process_callbacks kernel/rcu/tree.c:3110 [inline]
 rcu_process_callbacks+0x45b/0xc50 kernel/rcu/tree.c:3127
 __do_softirq+0x31f/0xbe7 kernel/softirq.c:284
Disposed:
PID = 22571
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:513
 set_track mm/kasan/kasan.c:525 [inline]
 kasan_set_rcu_track+0xcf/0xf0 mm/kasan/kasan.c:694
 __call_rcu.constprop.77+0x1d6/0x15a0 kernel/rcu/tree.c:3230
 call_rcu_sched+0x12/0x20 kernel/rcu/tree.c:3291
 rt_free net/ipv4/route.c:592 [inline]
 rt_cache_route+0xf5/0x130 net/ipv4/route.c:1365
 rt_set_nexthop.constprop.57+0x408/0xfa0 net/ipv4/route.c:1453
 __mkroute_output net/ipv4/route.c:2195 [inline]
 __ip_route_output_key_hash+0xe50/0x2ca0 net/ipv4/route.c:2375
 __ip_route_output_key include/net/route.h:122 [inline]
 ip_route_output_flow+0x29/0xa0 net/ipv4/route.c:2461
 ip_route_connect include/net/route.h:296 [inline]
 tcp_v4_connect+0x784/0x2070 net/ipv4/tcp_ipv4.c:170
 __inet_stream_connect+0x2d1/0xf90 net/ipv4/af_inet.c:618
 inet_stream_connect+0x58/0xa0 net/ipv4/af_inet.c:682
 SYSC_connect+0x251/0x580 net/socket.c:1577
 SyS_connect+0x24/0x30 net/socket.c:1558
 entry_SYSCALL_64_fastpath+0x1f/0xc2
Memory state around the buggy address:
 ffff88007e523580: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 ffff88007e523600: 00 00 00 00 00 00 00 00 00 00 00 fc fc fc fc fc
>ffff88007e523680: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
                         ^
 ffff88007e523700: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff88007e523780: fb fb fb fc fc fc fc fc fc fc fc fc fc fc fc fc
==================================================================
