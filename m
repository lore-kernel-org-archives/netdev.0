From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net: heap out-of-bounds in fib6_clean_node/rt6_fill_node/fib6_age/fib6_prune_clone
Date: Tue, 7 Mar 2017 10:21:51 +0100
Message-ID: <CACT4Y+aDzAYs9mbNGeFEkYSB2wTwomZTGEKn4hDH0PAb4uiLqw@mail.gmail.com>
References: <CACT4Y+YrA45diWz_8f4St8oX6aTC1kuGXMUvniGRbqXSGwawZQ@mail.gmail.com>
 <f707c195-251f-6058-5f4c-d55710533b11@cumulusnetworks.com>
 <CACT4Y+YCPxKkaZBfAabxtAV71R0ghLT-vUKVewJpm9wb2GXaEQ@mail.gmail.com>
 <1488658514.9415.356.camel@edumazet-glaptop3.roam.corp.google.com>
 <4e4d7d51-82de-b21e-cb5d-d804f7b88999@cumulusnetworks.com>
 <CACT4Y+Z1MvKbb35-jhaY=jEoR+t2u2TiUpkCR_oG3=VNmKjqvQ@mail.gmail.com>
 <14c01aea-6c2f-6ba5-6aee-52c55f410da7@cumulusnetworks.com> <CACT4Y+aomj0W8M9JNr1GLsT8EFFHV9YsOTYzWkvwKZANE9hiBQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+aomj0W8M9JNr1GLsT8EFFHV9YsOTYzWkvwKZANE9hiBQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 7, 2017 at 9:43 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Tue, Mar 7, 2017 at 12:41 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
>> On 3/6/17 11:51 AM, Dmitry Vyukov wrote:
>>> We hit it several thousand times, but we get only several dozens of
>>> crashes per day on ~80 VMs. So if you try to reproduce it on a single
>>> machine it can take days for a single crash.
>>> If you are ready to go that route, here are some instructions on
>>> setting up syzkaller:
>>> https://github.com/google/syzkaller
>>> You also need kernel built with CONFIG_KASAN.
>>
>> ack and I have it setup on ubuntu 16.10 which has a fairly new compiler.
>>
>>> I am ready to help with resolving any issues.
>>>
>>> Another possible route is if you give me a patch with some additional
>>> WARNINGs. Then I can deploy it to bots and collect stacks.
>>
>> try the attached.
>
>
> This is on c1ae3cfa0e89fa1a7ecc4c99031f5e9ae99d9201. No other kernel
> output from your patch (pr_err).
>
> ------------[ cut here ]------------
> WARNING: CPU: 1 PID: 30179 at net/ipv6/ip6_fib.c:158
> rt6_rcu_free+0x61/0x70 net/ipv6/ip6_fib.c:158
> Kernel panic - not syncing: panic_on_warn set ...
>
> CPU: 1 PID: 30179 Comm: syz-executor3 Not tainted 4.11.0-rc1+ #310
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:16 [inline]
>  dump_stack+0x2fb/0x3fd lib/dump_stack.c:52
>  panic+0x20f/0x426 kernel/panic.c:180
>  __warn+0x1c4/0x1e0 kernel/panic.c:541
>  warn_slowpath_null+0x2c/0x40 kernel/panic.c:584
>  rt6_rcu_free+0x61/0x70 net/ipv6/ip6_fib.c:158
>  rt6_release+0x1ee/0x290 net/ipv6/ip6_fib.c:189
>  fib6_add_rt2node net/ipv6/ip6_fib.c:922 [inline]
>  fib6_add+0x1d51/0x3290 net/ipv6/ip6_fib.c:1081
>  __ip6_ins_rt+0x60/0x80 net/ipv6/route.c:948
>  ip6_route_add+0x1a7/0x310 net/ipv6/route.c:2130
>  inet6_rtm_newroute+0x191/0x1b0 net/ipv6/route.c:3294
>  rtnetlink_rcv_msg+0x609/0x860 net/core/rtnetlink.c:4104
>  netlink_rcv_skb+0x2ab/0x390 net/netlink/af_netlink.c:2298
>  rtnetlink_rcv+0x2a/0x40 net/core/rtnetlink.c:4110
>  netlink_unicast_kernel net/netlink/af_netlink.c:1231 [inline]
>  netlink_unicast+0x525/0x730 net/netlink/af_netlink.c:1257
>  netlink_sendmsg+0xab3/0xe70 net/netlink/af_netlink.c:1803
>  sock_sendmsg_nosec net/socket.c:633 [inline]
>  sock_sendmsg+0xca/0x110 net/socket.c:643
>  sock_write_iter+0x326/0x600 net/socket.c:846
>  call_write_iter include/linux/fs.h:1733 [inline]
>  do_iter_readv_writev fs/read_write.c:696 [inline]
>  __do_readv_writev+0xbbc/0x10a0 fs/read_write.c:862
>  do_readv_writev+0x13f/0x200 fs/read_write.c:894
>  vfs_writev+0x87/0xc0 fs/read_write.c:921
>  do_writev+0x110/0x2c0 fs/read_write.c:954
>  SYSC_writev fs/read_write.c:1027 [inline]
>  SyS_writev+0x27/0x30 fs/read_write.c:1024
>  entry_SYSCALL_64_fastpath+0x1f/0xc2
> RIP: 0033:0x4458d9
> RSP: 002b:00007f31fcf33b58 EFLAGS: 00000292 ORIG_RAX: 0000000000000014
> RAX: ffffffffffffffda RBX: 0000000000000005 RCX: 00000000004458d9
> RDX: 0000000000000001 RSI: 00000000207cd000 RDI: 0000000000000005
> RBP: 00000000006e30c0 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000292 R12: 0000000000708000
> R13: 0000000020fad000 R14: 0000000000001000 R15: 0000000000000003
>
>
>
> ------------[ cut here ]------------
> WARNING: CPU: 2 PID: 31175 at net/ipv6/ip6_fib.c:158
> rt6_rcu_free+0x61/0x70 net/ipv6/ip6_fib.c:158
> Kernel panic - not syncing: panic_on_warn set ...
>
> CPU: 2 PID: 31175 Comm: syz-executor1 Not tainted 4.11.0-rc1+ #310
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:16 [inline]
>  dump_stack+0x2fb/0x3fd lib/dump_stack.c:52
>  panic+0x20f/0x426 kernel/panic.c:180
>  __warn+0x1c4/0x1e0 kernel/panic.c:541
>  warn_slowpath_null+0x2c/0x40 kernel/panic.c:584
>  rt6_rcu_free+0x61/0x70 net/ipv6/ip6_fib.c:158
>  rt6_release+0x1ee/0x290 net/ipv6/ip6_fib.c:189
>  fib6_add_rt2node net/ipv6/ip6_fib.c:922 [inline]
>  fib6_add+0x1d51/0x3290 net/ipv6/ip6_fib.c:1081
> kvm_vm_ioctl_deassign_device: device hasn't been assigned before, so
> cannot be deassigned
>  __ip6_ins_rt+0x60/0x80 net/ipv6/route.c:948
>  ip6_route_add+0x1a7/0x310 net/ipv6/route.c:2130
>  inet6_rtm_newroute+0x191/0x1b0 net/ipv6/route.c:3294
>  rtnetlink_rcv_msg+0x609/0x860 net/core/rtnetlink.c:4104
>  netlink_rcv_skb+0x2ab/0x390 net/netlink/af_netlink.c:2298
>  rtnetlink_rcv+0x2a/0x40 net/core/rtnetlink.c:4110
>  netlink_unicast_kernel net/netlink/af_netlink.c:1231 [inline]
>  netlink_unicast+0x525/0x730 net/netlink/af_netlink.c:1257
>  netlink_sendmsg+0xab3/0xe70 net/netlink/af_netlink.c:1803
>  sock_sendmsg_nosec net/socket.c:633 [inline]
>  sock_sendmsg+0xca/0x110 net/socket.c:643
>  sock_write_iter+0x326/0x600 net/socket.c:846
>  call_write_iter include/linux/fs.h:1733 [inline]
>  do_iter_readv_writev fs/read_write.c:696 [inline]
>  __do_readv_writev+0xbbc/0x10a0 fs/read_write.c:862
>  do_readv_writev+0x13f/0x200 fs/read_write.c:894
>  vfs_writev+0x87/0xc0 fs/read_write.c:921
>  do_writev+0x110/0x2c0 fs/read_write.c:954
>  SYSC_writev fs/read_write.c:1027 [inline]
>  SyS_writev+0x27/0x30 fs/read_write.c:1024
>  entry_SYSCALL_64_fastpath+0x1f/0xc2
> RIP: 0033:0x4458d9
> RSP: 002b:00007f1639006b58 EFLAGS: 00000292 ORIG_RAX: 0000000000000014
> RAX: ffffffffffffffda RBX: 0000000000000019 RCX: 00000000004458d9
> RDX: 0000000000000001 RSI: 00000000207cd000 RDI: 0000000000000019
> RBP: 00000000006e30c0 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000292 R12: 0000000000708000
> R13: 0000000000000010 R14: 0000000000000003 R15: 0000000000000000



I've commented that warning just to see I can obtain more information.
Then I also got this:

------------[ cut here ]------------
WARNING: CPU: 2 PID: 3990 at net/ipv6/ip6_fib.c:991
fib6_add+0x2e12/0x3290 net/ipv6/ip6_fib.c:991 net/ipv6/ip6_fib.c:991
Kernel panic - not syncing: panic_on_warn set ...

CPU: 2 PID: 3990 Comm: kworker/2:4 Not tainted 4.11.0-rc1+ #311
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Workqueue: ipv6_addrconf addrconf_dad_work
Call Trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 __dump_stack lib/dump_stack.c:16 [inline] lib/dump_stack.c:52
 dump_stack+0x2fb/0x3fd lib/dump_stack.c:52 lib/dump_stack.c:52
 panic+0x20f/0x426 kernel/panic.c:180 kernel/panic.c:180
 __warn+0x1c4/0x1e0 kernel/panic.c:541 kernel/panic.c:541
 warn_slowpath_null+0x2c/0x40 kernel/panic.c:584 kernel/panic.c:584
 fib6_add+0x2e12/0x3290 net/ipv6/ip6_fib.c:991 net/ipv6/ip6_fib.c:991
 __ip6_ins_rt+0x60/0x80 net/ipv6/route.c:948 net/ipv6/route.c:948
 ip6_ins_rt+0x19b/0x220 net/ipv6/route.c:959 net/ipv6/route.c:959
 __ipv6_ifa_notify+0x62e/0x7a0 net/ipv6/addrconf.c:5485 net/ipv6/addrconf.c:5485
 ipv6_ifa_notify+0xdf/0x1d0 net/ipv6/addrconf.c:5518 net/ipv6/addrconf.c:5518
 addrconf_dad_completed+0xe6/0x950 net/ipv6/addrconf.c:3983
net/ipv6/addrconf.c:3983
 addrconf_dad_begin net/ipv6/addrconf.c:3797 [inline]
 addrconf_dad_begin net/ipv6/addrconf.c:3797 [inline] net/ipv6/addrconf.c:3897
 addrconf_dad_work+0x32a/0xea0 net/ipv6/addrconf.c:3897 net/ipv6/addrconf.c:3897
 process_one_work+0xc06/0x1c40 kernel/workqueue.c:2096 kernel/workqueue.c:2096
 worker_thread+0x223/0x19f0 kernel/workqueue.c:2230 kernel/workqueue.c:2230
 kthread+0x334/0x400 kernel/kthread.c:229 kernel/kthread.c:229
 ret_from_fork+0x31/0x40 arch/x86/entry/entry_64.S:430
arch/x86/entry/entry_64.S:430



And this without any preceding warnings:

==================================================================
BUG: KASAN: slab-out-of-bounds in fib6_age+0x3fd/0x480
net/ipv6/ip6_fib.c:1787 at addr ffff88004d4fbe54
Read of size 4 by task swapper/2/0
CPU: 2 PID: 0 Comm: swapper/2 Not tainted 4.11.0-rc1+ #311
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 <IRQ>
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x2fb/0x3fd lib/dump_stack.c:52
 kasan_object_err+0x1c/0x90 mm/kasan/report.c:166
 print_address_description mm/kasan/report.c:208 [inline]
 kasan_report_error mm/kasan/report.c:292 [inline]
 kasan_report.part.2+0x1b0/0x460 mm/kasan/report.c:314
 kasan_report mm/kasan/report.c:334 [inline]
 __asan_report_load4_noabort+0x29/0x30 mm/kasan/report.c:334
 fib6_age+0x3fd/0x480 net/ipv6/ip6_fib.c:1787
 fib6_clean_node+0x356/0x550 net/ipv6/ip6_fib.c:1665
 fib6_walk_continue+0x4b3/0x620 net/ipv6/ip6_fib.c:1594
 fib6_walk+0x91/0xf0 net/ipv6/ip6_fib.c:1639
 fib6_clean_tree+0x266/0x3a0 net/ipv6/ip6_fib.c:1711
 __fib6_clean_all+0x1e1/0x360 net/ipv6/ip6_fib.c:1727
 fib6_clean_all net/ipv6/ip6_fib.c:1738 [inline]
 fib6_run_gc+0x185/0x3d0 net/ipv6/ip6_fib.c:1835
 fib6_gc_timer_cb+0x1c/0x20 net/ipv6/ip6_fib.c:1850
 call_timer_fn+0x241/0x820 kernel/time/timer.c:1268
 expire_timers kernel/time/timer.c:1307 [inline]
 __run_timers+0x960/0xcf0 kernel/time/timer.c:1601
 run_timer_softirq+0x21/0x80 kernel/time/timer.c:1614
 __do_softirq+0x31f/0xbe7 kernel/softirq.c:284
 invoke_softirq kernel/softirq.c:364 [inline]
 irq_exit+0x1cc/0x200 kernel/softirq.c:405
 exiting_irq arch/x86/include/asm/apic.h:657 [inline]
 smp_apic_timer_interrupt+0x76/0xa0 arch/x86/kernel/apic/apic.c:962
 apic_timer_interrupt+0x93/0xa0 arch/x86/entry/entry_64.S:487
RIP: 0010:native_safe_halt+0x6/0x10 arch/x86/include/asm/irqflags.h:53
RSP: 0018:ffff880089437c10 EFLAGS: 00000286 ORIG_RAX: ffffffffffffff10
RAX: dffffc0000000000 RBX: 1ffff10011286f85 RCX: 0000000000000000
RDX: 1ffffffff0a18ebc RSI: 0000000000000001 RDI: ffffffff850c75e0
RBP: ffff880089437c10 R08: ffffed00113835c2 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 1ffff10011286fa9
R13: ffff880089437cc8 R14: ffffffff856973f8 R15: ffff880089437e68
 </IRQ>
 arch_safe_halt arch/x86/include/asm/paravirt.h:98 [inline]
 default_idle+0xbf/0x440 arch/x86/kernel/process.c:275
 arch_cpu_idle+0xa/0x10 arch/x86/kernel/process.c:266
 default_idle_call+0x36/0x90 kernel/sched/idle.c:97
 cpuidle_idle_call kernel/sched/idle.c:155 [inline]
 do_idle+0x373/0x520 kernel/sched/idle.c:244
 cpu_startup_entry+0x18/0x20 kernel/sched/idle.c:346
 start_secondary+0x36c/0x460 arch/x86/kernel/smpboot.c:275
 start_cpu+0x14/0x14 arch/x86/kernel/head_64.S:306
Object at ffff88004d4fbd40, in cache ip_dst_cache size: 216
Allocated:
PID = 8122
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
 ip_route_output_flow+0x29/0xa0 net/ipv4/route.c:2461
 ip_route_output_key include/net/route.h:132 [inline]
 sctp_v4_get_dst+0x5d2/0x1570 net/sctp/protocol.c:458
 sctp_transport_route+0xa8/0x420 net/sctp/transport.c:292
 sctp_assoc_add_peer+0x5a5/0x1470 net/sctp/associola.c:653
 sctp_sendmsg+0x180d/0x3980 net/sctp/socket.c:1871
 inet_sendmsg+0x164/0x5b0 net/ipv4/af_inet.c:761
 sock_sendmsg_nosec net/socket.c:633 [inline]
 sock_sendmsg+0xca/0x110 net/socket.c:643
 SYSC_sendto+0x660/0x810 net/socket.c:1685
 SyS_sendto+0x40/0x50 net/socket.c:1653
 entry_SYSCALL_64_fastpath+0x1f/0xc2
Freed:
PID = 2038
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:513
 set_track mm/kasan/kasan.c:525 [inline]
 kasan_slab_free+0x6f/0xb0 mm/kasan/kasan.c:589
 __cache_free mm/slab.c:3514 [inline]
 kmem_cache_free+0x71/0x240 mm/slab.c:3774
 dst_destroy+0x211/0x340 net/core/dst.c:272
 dst_free include/net/dst.h:429 [inline]
 dst_rcu_free+0x152/0x190 include/net/dst.h:439
 __rcu_reclaim kernel/rcu/rcu.h:118 [inline]
 rcu_do_batch.isra.66+0xa31/0xe50 kernel/rcu/tree.c:2880
 invoke_rcu_callbacks kernel/rcu/tree.c:3143 [inline]
 __rcu_process_callbacks kernel/rcu/tree.c:3110 [inline]
 rcu_process_callbacks+0x45b/0xc50 kernel/rcu/tree.c:3127
 __do_softirq+0x31f/0xbe7 kernel/softirq.c:284
Disposed:
PID = 26270
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
 ip_route_output_key include/net/route.h:132 [inline]
 sctp_v4_get_dst+0x5d2/0x1570 net/sctp/protocol.c:458
 sctp_transport_route+0xa8/0x420 net/sctp/transport.c:292
 sctp_assoc_add_peer+0x5a5/0x1470 net/sctp/associola.c:653
 sctp_process_param net/sctp/sm_make_chunk.c:2548 [inline]
 sctp_process_init+0xf71/0x2320 net/sctp/sm_make_chunk.c:2354
 sctp_sf_do_unexpected_init.isra.28+0x7b8/0x1470 net/sctp/sm_statefuns.c:1510
 sctp_sf_do_5_2_1_siminit+0x35/0x40 net/sctp/sm_statefuns.c:1199
 sctp_do_sm+0x1e5/0x6a30 net/sctp/sm_sideeffect.c:1144
 sctp_assoc_bh_rcv+0x285/0x4b0 net/sctp/associola.c:1063
 sctp_inq_push+0x22b/0x2e0 net/sctp/inqueue.c:95
 sctp_backlog_rcv+0x177/0xb40 net/sctp/input.c:350
 sk_backlog_rcv include/net/sock.h:896 [inline]
 __release_sock+0x126/0x3a0 net/core/sock.c:2058
 release_sock+0xa5/0x2b0 net/core/sock.c:2545
 sctp_sendmsg+0x2b05/0x3980 net/sctp/socket.c:2011
 inet_sendmsg+0x164/0x5b0 net/ipv4/af_inet.c:761
 sock_sendmsg_nosec net/socket.c:633 [inline]
 sock_sendmsg+0xca/0x110 net/socket.c:643
 SYSC_sendto+0x660/0x810 net/socket.c:1685
 SyS_sendto+0x40/0x50 net/socket.c:1653
 entry_SYSCALL_64_fastpath+0x1f/0xc2
Memory state around the buggy address:
 ffff88004d4fbd00: fc fc fc fc fc fc fc fc 00 00 00 00 00 00 00 00
 ffff88004d4fbd80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>ffff88004d4fbe00: 00 00 00 fc fc fc fc fc fc fc fc fc fc fc fc fc
                                                 ^
 ffff88004d4fbe80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 ffff88004d4fbf00: 00 00 00 00 00 00 00 00 00 00 00 fc fc fc fc fc
==================================================================
