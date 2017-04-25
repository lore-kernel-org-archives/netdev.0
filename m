From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net: heap out-of-bounds in fib6_clean_node/rt6_fill_node/fib6_age/fib6_prune_clone
Date: Tue, 25 Apr 2017 18:36:30 +0200
Message-ID: <CAAeHK+zVkJ1t1xMhMXO2wUyMfJrbXsARHyQ6A5hh2O9pqPRxiw@mail.gmail.com>
References: <CACT4Y+YrA45diWz_8f4St8oX6aTC1kuGXMUvniGRbqXSGwawZQ@mail.gmail.com>
 <f707c195-251f-6058-5f4c-d55710533b11@cumulusnetworks.com>
 <CACT4Y+YCPxKkaZBfAabxtAV71R0ghLT-vUKVewJpm9wb2GXaEQ@mail.gmail.com> <381a3e2d-dbf8-5e26-e6b2-4dc291d49dbe@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Mahesh Bandewar <maheshb@google.com>,
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f182.google.com ([209.85.213.182]:33563 "EHLO
        mail-yb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1947881AbdDYQgi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 12:36:38 -0400
Received: by mail-yb0-f182.google.com with SMTP id 81so69448497ybp.0
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 09:36:37 -0700 (PDT)
In-Reply-To: <381a3e2d-dbf8-5e26-e6b2-4dc291d49dbe@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 5:56 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 3/4/17 11:57 AM, Dmitry Vyukov wrote:
>> ==================================================================
>> BUG: KASAN: slab-out-of-bounds in rt6_dump_route+0x293/0x2f0
>> net/ipv6/route.c:3551 at addr ffff88007e523694
>> Read of size 4 by task syz-executor3/24426
>> CPU: 2 PID: 24426 Comm: syz-executor3 Not tainted 4.10.0+ #293
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>> Call Trace:
>>  __dump_stack lib/dump_stack.c:16 [inline]
>>  dump_stack+0x2fb/0x3fd lib/dump_stack.c:52
>>  kasan_object_err+0x1c/0x90 mm/kasan/report.c:166
>>  print_address_description mm/kasan/report.c:208 [inline]
>>  kasan_report_error mm/kasan/report.c:292 [inline]
>>  kasan_report.part.2+0x1b0/0x460 mm/kasan/report.c:314
>>  kasan_report mm/kasan/report.c:334 [inline]
>>  __asan_report_load4_noabort+0x29/0x30 mm/kasan/report.c:334
>>  rt6_dump_route+0x293/0x2f0 net/ipv6/route.c:3551
>>  fib6_dump_node+0x101/0x1a0 net/ipv6/ip6_fib.c:315
>>  fib6_walk_continue+0x4b3/0x620 net/ipv6/ip6_fib.c:1576
>>  fib6_walk+0x91/0xf0 net/ipv6/ip6_fib.c:1621
>>  fib6_dump_table net/ipv6/ip6_fib.c:374 [inline]
>>  inet6_dump_fib+0x832/0xea0 net/ipv6/ip6_fib.c:447
>
> My expectation is that this one is fixed with the ipv6 patch I have sent
> (not yet committed). Are you seeing this backtrace with that patch?

Before applying your patch I was hitting reports related to fib6 all the time.
I've stopped seeing them for some time after I applied your patch.
However today another one was triggered:

==================================================================
BUG: KASAN: slab-out-of-bounds in find_rr_leaf net/ipv6/route.c:722
[inline] at addr ffff880033dddaa8
BUG: KASAN: slab-out-of-bounds in rt6_select net/ipv6/route.c:758
[inline] at addr ffff880033dddaa8
BUG: KASAN: slab-out-of-bounds in ip6_pol_route+0x1b1e/0x1ba0
net/ipv6/route.c:1091 at addr ffff880033dddaa8
Read of size 4 by task syz-executor7/9808
CPU: 2 PID: 9808 Comm: syz-executor7 Not tainted 4.11.0-rc8+ #268
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x192/0x22d lib/dump_stack.c:52
 kasan_object_err+0x1c/0x70 mm/kasan/report.c:164
 print_address_description mm/kasan/report.c:202 [inline]
 kasan_report_error mm/kasan/report.c:291 [inline]
 kasan_report+0x252/0x510 mm/kasan/report.c:347
 __asan_report_load4_noabort+0x14/0x20 mm/kasan/report.c:367
 find_rr_leaf net/ipv6/route.c:722 [inline]
 rt6_select net/ipv6/route.c:758 [inline]
 ip6_pol_route+0x1b1e/0x1ba0 net/ipv6/route.c:1091
 ip6_pol_route_output+0x4c/0x60 net/ipv6/route.c:1212
 fib6_rule_action+0x261/0x8a0 net/ipv6/fib6_rules.c:100
 fib_rules_lookup+0x34b/0xae0 net/core/fib_rules.c:265
 fib6_rule_lookup+0x175/0x360 net/ipv6/fib6_rules.c:44
 ip6_route_output_flags+0x260/0x2f0 net/ipv6/route.c:1240
 ip6_route_output include/net/ip6_route.h:79 [inline]
 ip6_dst_lookup_tail+0xe59/0x1640 net/ipv6/ip6_output.c:959
 ip6_dst_lookup_flow+0xb1/0x260 net/ipv6/ip6_output.c:1082
 ip6_sk_dst_lookup_flow+0x2c6/0x7f0 net/ipv6/ip6_output.c:1113
 udpv6_sendmsg+0x2350/0x3310 net/ipv6/udp.c:1219
 inet_sendmsg+0x164/0x490 net/ipv4/af_inet.c:762
 sock_sendmsg_nosec net/socket.c:633 [inline]
 sock_sendmsg+0xca/0x110 net/socket.c:643
 SYSC_sendto+0x660/0x810 net/socket.c:1696
 SyS_sendto+0x40/0x50 net/socket.c:1664
 entry_SYSCALL_64_fastpath+0x1a/0xa9
RIP: 0033:0x4458d9
RSP: 002b:00007ff3a5343b58 EFLAGS: 00000282 ORIG_RAX: 000000000000002c
RAX: ffffffffffffffda RBX: 0000000000708000 RCX: 00000000004458d9
RDX: 0000000000000fa8 RSI: 0000000020000000 RDI: 0000000000000005
RBP: 0000000000004300 R08: 0000000020006000 R09: 000000000000001c
R10: 0000000000040000 R11: 0000000000000282 R12: 00000000006e33c0
R13: 0000000000000005 R14: 0000000000000029 R15: 0000000000000023
Object at ffff880033ddd940, in cache ip_dst_cache size: 224
Allocated:
PID = 9717
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:513
 set_track mm/kasan/kasan.c:525 [inline]
 kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:616
 kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:555
 slab_post_alloc_hook mm/slab.h:456 [inline]
 slab_alloc_node mm/slub.c:2718 [inline]
 slab_alloc mm/slub.c:2726 [inline]
 kmem_cache_alloc+0xa8/0x160 mm/slub.c:2731
 dst_alloc+0x11b/0x1a0 net/core/dst.c:209
 rt_dst_alloc+0xf0/0x5d0 net/ipv4/route.c:1497
 __mkroute_output net/ipv4/route.c:2181 [inline]
 __ip_route_output_key_hash+0xdc4/0x2930 net/ipv4/route.c:2391
 __ip_route_output_key include/net/route.h:123 [inline]
 ip_route_output_flow+0x29/0xa0 net/ipv4/route.c:2477
 ip_route_output_key include/net/route.h:133 [inline]
 sctp_v4_get_dst+0x606/0x1420 net/sctp/protocol.c:458
 sctp_transport_route+0xa8/0x420 net/sctp/transport.c:287
 sctp_assoc_add_peer+0x5a5/0x1470 net/sctp/associola.c:656
 sctp_sendmsg+0x18a8/0x3b50 net/sctp/socket.c:1871
 inet_sendmsg+0x164/0x490 net/ipv4/af_inet.c:762
 sock_sendmsg_nosec net/socket.c:633 [inline]
 sock_sendmsg+0xca/0x110 net/socket.c:643
 SYSC_sendto+0x660/0x810 net/socket.c:1696
 SyS_sendto+0x40/0x50 net/socket.c:1664
 entry_SYSCALL_64_fastpath+0x1a/0xa9
Freed:
PID = 868
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:513
 set_track mm/kasan/kasan.c:525 [inline]
 kasan_slab_free+0x73/0xc0 mm/kasan/kasan.c:589
 slab_free_hook mm/slub.c:1357 [inline]
 slab_free_freelist_hook mm/slub.c:1379 [inline]
 slab_free mm/slub.c:2961 [inline]
 kmem_cache_free+0x72/0x190 mm/slub.c:2983
 dst_destroy+0x24c/0x390 net/core/dst.c:269
 dst_free include/net/dst.h:428 [inline]
 rt_fibinfo_free net/ipv4/fib_semantics.c:155 [inline]
 free_fib_info_rcu+0x852/0xa10 net/ipv4/fib_semantics.c:214
 __rcu_reclaim kernel/rcu/rcu.h:118 [inline]
 rcu_do_batch.isra.65+0x6de/0xbd0 kernel/rcu/tree.c:2879
 invoke_rcu_callbacks kernel/rcu/tree.c:3142 [inline]
 __rcu_process_callbacks kernel/rcu/tree.c:3109 [inline]
 rcu_process_callbacks+0x23f/0x810 kernel/rcu/tree.c:3126
 __do_softirq+0x253/0x78b kernel/softirq.c:284
Memory state around the buggy address:
 ffff880033ddd980: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 ffff880033ddda00: 00 00 00 00 fc fc fc fc fc fc fc fc fc fc fc fc
>ffff880033ddda80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
                                  ^
 ffff880033dddb00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
 ffff880033dddb80: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
==================================================================.

>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller+unsubscribe@googlegroups.com.
> For more options, visit https://groups.google.com/d/optout.
