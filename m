From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/ipv6: use-after-free in sock_wfree
Date: Mon, 9 Jan 2017 18:11:30 +0100
Message-ID: <CAAeHK+yiziBBxw3JMqec3c7aLXjk6ddL2Xh1xufA3sp5ja=_TA@mail.gmail.com>
References: <CAAeHK+yfNdNTkgCbUGbdRBM9bB=2DhGv1ZPCWm44CGL7zD=TLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:35566 "EHLO
        mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935186AbdAIRLg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 12:11:36 -0500
Received: by mail-oi0-f46.google.com with SMTP id b126so698392393oia.2
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 09:11:36 -0800 (PST)
In-Reply-To: <CAAeHK+yfNdNTkgCbUGbdRBM9bB=2DhGv1ZPCWm44CGL7zD=TLg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 9, 2017 at 6:08 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> Hi!
>
> I've got the following error report while running the syzkaller fuzzer.
>
> On commit a121103c922847ba5010819a3f250f1f7fc84ab8 (4.10-rc3).
>
> A reproducer is attached.
>
> ==================================================================
> BUG: KASAN: use-after-free in sock_wfree+0x118/0x120
> Read of size 8 at addr ffff880062da0060 by task a.out/4140
>
> page:ffffea00018b6800 count:1 mapcount:0 mapping:          (null)
> index:0x0 compound_mapcount: 0
> flags: 0x100000000008100(slab|head)
> raw: 0100000000008100 0000000000000000 0000000000000000 0000000180130013
> raw: dead000000000100 dead000000000200 ffff88006741f140 0000000000000000
> page dumped because: kasan: bad access detected
>
> CPU: 0 PID: 4140 Comm: a.out Not tainted 4.10.0-rc3+ #59
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:15
>  dump_stack+0x292/0x398 lib/dump_stack.c:51
>  describe_address mm/kasan/report.c:262
>  kasan_report_error+0x121/0x560 mm/kasan/report.c:370
>  kasan_report mm/kasan/report.c:392
>  __asan_report_load8_noabort+0x3e/0x40 mm/kasan/report.c:413
>  sock_flag ./arch/x86/include/asm/bitops.h:324
>  sock_wfree+0x118/0x120 net/core/sock.c:1631
>  skb_release_head_state+0xfc/0x250 net/core/skbuff.c:655
>  skb_release_all+0x15/0x60 net/core/skbuff.c:668
>  __kfree_skb+0x15/0x20 net/core/skbuff.c:684
>  kfree_skb+0x16e/0x4e0 net/core/skbuff.c:705
>  inet_frag_destroy+0x121/0x290 net/ipv4/inet_fragment.c:304
>  inet_frag_put ./include/net/inet_frag.h:133
>  nf_ct_frag6_gather+0x1125/0x38b0 net/ipv6/netfilter/nf_conntrack_reasm.c:617
>  ipv6_defrag+0x21b/0x350 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c:68
>  nf_hook_entry_hookfn ./include/linux/netfilter.h:102
>  nf_hook_slow+0xc3/0x290 net/netfilter/core.c:310
>  nf_hook ./include/linux/netfilter.h:212
>  __ip6_local_out+0x52c/0xaf0 net/ipv6/output_core.c:160
>  ip6_local_out+0x2d/0x170 net/ipv6/output_core.c:170
>  ip6_send_skb+0xa1/0x340 net/ipv6/ip6_output.c:1722
>  ip6_push_pending_frames+0xb3/0xe0 net/ipv6/ip6_output.c:1742
>  rawv6_push_pending_frames net/ipv6/raw.c:613
>  rawv6_sendmsg+0x2cff/0x4130 net/ipv6/raw.c:927
>  inet_sendmsg+0x164/0x5b0 net/ipv4/af_inet.c:744
>  sock_sendmsg_nosec net/socket.c:635
>  sock_sendmsg+0xca/0x110 net/socket.c:645
>  sock_write_iter+0x326/0x620 net/socket.c:848
>  new_sync_write fs/read_write.c:499
>  __vfs_write+0x483/0x760 fs/read_write.c:512
>  vfs_write+0x187/0x530 fs/read_write.c:560
>  SYSC_write fs/read_write.c:607
>  SyS_write+0xfb/0x230 fs/read_write.c:599
>  entry_SYSCALL_64_fastpath+0x1f/0xc2 arch/x86/entry/entry_64.S:203
> RIP: 0033:0x7ff26e6f5b79
> RSP: 002b:00007ff268e0ed98 EFLAGS: 00000206 ORIG_RAX: 0000000000000001
> RAX: ffffffffffffffda RBX: 00007ff268e0f9c0 RCX: 00007ff26e6f5b79
> RDX: 0000000000000010 RSI: 0000000020f50fe1 RDI: 0000000000000003
> RBP: 00007ff26ebc1220 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000206 R12: 0000000000000000
> R13: 00007ff268e0f9c0 R14: 00007ff26efec040 R15: 0000000000000003
>
> The buggy address belongs to the object at ffff880062da0000
>  which belongs to the cache RAWv6 of size 1504
> The buggy address ffff880062da0060 is located 96 bytes inside
>  of 1504-byte region [ffff880062da0000, ffff880062da05e0)
>
> Freed by task 4113:
>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
>  save_stack+0x43/0xd0 mm/kasan/kasan.c:502
>  set_track mm/kasan/kasan.c:514
>  kasan_slab_free+0x73/0xc0 mm/kasan/kasan.c:578
>  slab_free_hook mm/slub.c:1352
>  slab_free_freelist_hook mm/slub.c:1374
>  slab_free mm/slub.c:2951
>  kmem_cache_free+0xb2/0x2c0 mm/slub.c:2973
>  sk_prot_free net/core/sock.c:1377
>  __sk_destruct+0x49c/0x6e0 net/core/sock.c:1452
>  sk_destruct+0x47/0x80 net/core/sock.c:1460
>  __sk_free+0x57/0x230 net/core/sock.c:1468
>  sk_free+0x23/0x30 net/core/sock.c:1479
>  sock_put ./include/net/sock.h:1638
>  sk_common_release+0x31e/0x4e0 net/core/sock.c:2782
>  rawv6_close+0x54/0x80 net/ipv6/raw.c:1214
>  inet_release+0xed/0x1c0 net/ipv4/af_inet.c:425
>  inet6_release+0x50/0x70 net/ipv6/af_inet6.c:431
>  sock_release+0x8d/0x1e0 net/socket.c:599
>  sock_close+0x16/0x20 net/socket.c:1063
>  __fput+0x332/0x7f0 fs/file_table.c:208
>  ____fput+0x15/0x20 fs/file_table.c:244
>  task_work_run+0x19b/0x270 kernel/task_work.c:116
>  exit_task_work ./include/linux/task_work.h:21
>  do_exit+0x186b/0x2800 kernel/exit.c:839
>  do_group_exit+0x149/0x420 kernel/exit.c:943
>  SYSC_exit_group kernel/exit.c:954
>  SyS_exit_group+0x1d/0x20 kernel/exit.c:952
>  entry_SYSCALL_64_fastpath+0x1f/0xc2 arch/x86/entry/entry_64.S:203
>
> Allocated by task 4115:
>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
>  save_stack+0x43/0xd0 mm/kasan/kasan.c:502
>  set_track mm/kasan/kasan.c:514
>  kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:605
>  kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:544
>  slab_post_alloc_hook mm/slab.h:432
>  slab_alloc_node mm/slub.c:2708
>  slab_alloc mm/slub.c:2716
>  kmem_cache_alloc+0x1af/0x250 mm/slub.c:2721
>  sk_prot_alloc+0x65/0x2a0 net/core/sock.c:1334
>  sk_alloc+0x105/0x1010 net/core/sock.c:1396
>  inet6_create+0x44d/0x1150 net/ipv6/af_inet6.c:183
>  __sock_create+0x4f6/0x880 net/socket.c:1199
>  sock_create net/socket.c:1239
>  SYSC_socket net/socket.c:1269
>  SyS_socket+0xf9/0x230 net/socket.c:1249
>  entry_SYSCALL_64_fastpath+0x1f/0xc2 arch/x86/entry/entry_64.S:203
>
> Memory state around the buggy address:
>  ffff880062d9ff00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>  ffff880062d9ff80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>>ffff880062da0000: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>                                                        ^
>  ffff880062da0080: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>  ffff880062da0100: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> ==================================================================

Sometimes this reproducer leads to another report:

INFO: rcu_sched self-detected stall on CPU
1-...: (1 GPs behind) idle=ead/140000000000001/0 softirq=8122/8123 fqs=6497
(t=26000 jiffies g=3021 c=3020 q=345)
Task dump for CPU 1:
syz-executor    R  running task    18904  3943   3941 0x0000000c
Call Trace:
 <IRQ>
 sched_show_task+0x3fa/0x560 kernel/sched/core.c:5217
 dump_cpu_task+0x71/0x90 kernel/sched/core.c:8822
 rcu_dump_cpu_stacks+0x318/0x35e kernel/rcu/tree.c:1290
 print_cpu_stall+0x39f/0x6e0 kernel/rcu/tree.c:1434
 check_cpu_stall.isra.63+0x702/0xe80 kernel/rcu/tree.c:1502
 __rcu_pending kernel/rcu/tree.c:3469
 rcu_pending kernel/rcu/tree.c:3533
 rcu_check_callbacks+0x27f/0xda0 kernel/rcu/tree.c:2867
 update_process_times+0x30/0x60 kernel/time/timer.c:1612
 tick_sched_handle.isra.18+0xb3/0xe0 kernel/time/tick-sched.c:151
 tick_sched_timer+0x72/0x120 kernel/time/tick-sched.c:1158
 __run_hrtimer kernel/time/hrtimer.c:1238
 __hrtimer_run_queues+0x38c/0xf80 kernel/time/hrtimer.c:1302
 hrtimer_interrupt+0x1ab/0x5c0 kernel/time/hrtimer.c:1336
 local_apic_timer_interrupt+0x6f/0xe0 arch/x86/kernel/apic/apic.c:936
 smp_apic_timer_interrupt+0x71/0xa0 arch/x86/kernel/apic/apic.c:960
 apic_timer_interrupt+0x93/0xa0
RIP: 0010:__sanitizer_cov_trace_pc+0x46/0x60 kernel/kcov.c:93
RSP: 0018:ffff88006ad66a98 EFLAGS: 00000216 ORIG_RAX: ffffffffffffff10
RAX: 0000000000004000 RBX: ffff880068f4e500 RCX: ffffc90000e6c000
RDX: 0000000000004000 RSI: ffffffff83d652b7 RDI: ffff880064f09f51
RBP: ffff88006ad66a98 R08: ffffed000d633ca1 R09: ffffed000d633ca1
R10: 0000000000000001 R11: ffffed000d633ca0 R12: ffff880064f00020
R13: ffff88006ad66c28 R14: 0000000000009f38 R15: dffffc0000000000
 </IRQ>
 _decode_session6+0x8a7/0x13f0 net/ipv6/xfrm6_policy.c:147
 __xfrm_decode_session+0x63/0x100 net/xfrm/xfrm_policy.c:2475
 xfrm_decode_session_reverse ./include/net/xfrm.h:1117
 icmpv6_route_lookup+0x410/0x780 net/ipv6/icmp.c:362
 icmp6_send+0x1611/0x29b0 net/ipv6/icmp.c:515
 icmpv6_send+0x12e/0x260 net/ipv6/ip6_icmp.c:42
 ip6_fragment+0x583/0x3920 net/ipv6/ip6_output.c:864
 ip6_finish_output+0x322/0x960 net/ipv6/ip6_output.c:146
 NF_HOOK_COND ./include/linux/netfilter.h:246
 ip6_output+0x1cb/0x8d0 net/ipv6/ip6_output.c:162
 dst_output ./include/net/dst.h:501
 ip6_local_out+0x95/0x170 net/ipv6/output_core.c:172
 ip6_send_skb+0xa1/0x340 net/ipv6/ip6_output.c:1722
 ip6_push_pending_frames+0xb3/0xe0 net/ipv6/ip6_output.c:1742
 rawv6_push_pending_frames net/ipv6/raw.c:613
 rawv6_sendmsg+0x2cff/0x4130 net/ipv6/raw.c:927
 inet_sendmsg+0x164/0x5b0 net/ipv4/af_inet.c:744
 sock_sendmsg_nosec net/socket.c:635
 sock_sendmsg+0xca/0x110 net/socket.c:645
 sock_write_iter+0x326/0x620 net/socket.c:848
 new_sync_write fs/read_write.c:499
 __vfs_write+0x483/0x760 fs/read_write.c:512
 vfs_write+0x187/0x530 fs/read_write.c:560
 SYSC_write fs/read_write.c:607
 SyS_write+0xfb/0x230 fs/read_write.c:599
 entry_SYSCALL_64_fastpath+0x1f/0xc2 arch/x86/entry/entry_64.S:203
RIP: 0033:0x4421d9
RSP: 002b:00007f090e289b58 EFLAGS: 00000296 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 0000000000000005 RCX: 00000000004421d9
RDX: 000000000000ffff RSI: 0000000020aa4fda RDI: 0000000000000005
RBP: 00000000006de8c0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000296 R12: 0000000000700000
R13: ffffffffffffffff R14: 0000000020f4a000 R15: 0000000000000010
