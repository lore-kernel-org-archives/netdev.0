From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net: heap out-of-bounds in fib6_clean_node/rt6_fill_node/fib6_age/fib6_prune_clone
Date: Fri, 3 Mar 2017 20:14:00 +0100
Message-ID: <CACT4Y+Z01vCL0is-Z80YMvVm+58WnL8OXc_uYovCs=Cr1fqfMw@mail.gmail.com>
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


This is not from fib6_walk, but looks like the same problem:

==================================================================
BUG: KASAN: slab-out-of-bounds in find_rr_leaf net/ipv6/route.c:722
[inline] at addr ffff88004afe6f68
BUG: KASAN: slab-out-of-bounds in rt6_select net/ipv6/route.c:758
[inline] at addr ffff88004afe6f68
BUG: KASAN: slab-out-of-bounds in ip6_pol_route+0x19ff/0x1f30
net/ipv6/route.c:1091 at addr ffff88004afe6f68
Read of size 4 by task syz-executor0/24839
CPU: 1 PID: 24839 Comm: syz-executor0 Not tainted 4.10.0+ #248
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
 find_rr_leaf net/ipv6/route.c:722 [inline]
 rt6_select net/ipv6/route.c:758 [inline]
 ip6_pol_route+0x19ff/0x1f30 net/ipv6/route.c:1091
 ip6_pol_route_output+0x4c/0x60 net/ipv6/route.c:1212
 fib6_rule_lookup+0x52/0x150 net/ipv6/ip6_fib.c:291
 ip6_route_output_flags+0x1f1/0x2b0 net/ipv6/route.c:1240
 ip6_route_output include/net/ip6_route.h:79 [inline]
 ip6_dst_lookup_tail+0x4fb/0x990 net/ipv6/ip6_output.c:954
 ip6_dst_lookup+0x4b/0x60 net/ipv6/ip6_output.c:1056
 icmpv6_route_lookup+0x107/0x750 net/ipv6/icmp.c:347
 icmp6_send+0x145e/0x24d0 net/ipv6/icmp.c:536
 icmpv6_send+0x12e/0x260 net/ipv6/ip6_icmp.c:42
 ip6_fragment+0x57f/0x38a0 net/ipv6/ip6_output.c:865
 ip6_finish_output+0x319/0x950 net/ipv6/ip6_output.c:147
 NF_HOOK_COND include/linux/netfilter.h:246 [inline]
 ip6_output+0x1cb/0x8c0 net/ipv6/ip6_output.c:163
 dst_output include/net/dst.h:486 [inline]
 ip6_local_out+0x95/0x170 net/ipv6/output_core.c:172
 ip6_send_skb+0xa1/0x340 net/ipv6/ip6_output.c:1734
 ip6_push_pending_frames+0xb3/0xe0 net/ipv6/ip6_output.c:1754
 rawv6_push_pending_frames net/ipv6/raw.c:613 [inline]
 rawv6_sendmsg+0x2e10/0x3fd0 net/ipv6/raw.c:930
 inet_sendmsg+0x164/0x5b0 net/ipv4/af_inet.c:761
 sock_sendmsg_nosec net/socket.c:633 [inline]
 sock_sendmsg+0xca/0x110 net/socket.c:643
 SYSC_sendto+0x660/0x810 net/socket.c:1685
 SyS_sendto+0x40/0x50 net/socket.c:1653
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x4458d9
RSP: 002b:00007f227bcfab58 EFLAGS: 00000282 ORIG_RAX: 000000000000002c
RAX: ffffffffffffffda RBX: 0000000000000006 RCX: 00000000004458d9
RDX: 0000000000001001 RSI: 0000000020725000 RDI: 0000000000000006
RBP: 00000000006e1bb0 R08: 00000000201ccff8 R09: 0000000000000018
R10: 0040000000004004 R11: 0000000000000282 R12: 0000000000708000
R13: 0000000020001ff7 R14: 0000000000000003 R15: 0000000000060040
Object at ffff88004afe6e00, in cache ip_dst_cache size: 216
Allocated:
PID = 1307
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
 save_stack+0x43/0xd0 mm/kasan/kasan.c:502
 set_track mm/kasan/kasan.c:514 [inline]
 kasan_kmalloc+0xaa/0xd0 mm/kasan/kasan.c:605
 kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:544
 kmem_cache_alloc+0x102/0x680 mm/slab.c:3571
 dst_alloc+0x11b/0x1a0 net/core/dst.c:209
 rt_dst_alloc+0xf0/0x580 net/ipv4/route.c:1482
 ip_route_input_slow+0xdf2/0x2160 net/ipv4/route.c:1935
 ip_route_input_noref+0x137/0x10e0 net/ipv4/route.c:2056
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
PID = 22752
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
 ffff88004afe6e00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 ffff88004afe6e80: 00 00 00 00 00 00 00 00 00 00 00 fc fc fc fc fc
>ffff88004afe6f00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
                                                          ^
 ffff88004afe6f80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
 ffff88004afe7000: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
==================================================================
