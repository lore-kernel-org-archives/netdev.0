From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/can: use-after-free in bcm_rx_thr_flush
Date: Tue, 22 Nov 2016 18:37:36 +0100
Message-ID: <CAAeHK+x+SwBFj3iRfNN0S-5=kPXLdTgGZaoBAT+L0QpdU+0-vw@mail.gmail.com>
References: <CAAeHK+xhwpVO=xHqEOyP-Tm6cx1+jDLDpYT0hpMwM2PCf7W3Jw@mail.gmail.com>
 <5abd6ebd-1249-71a9-da30-65d8371a2a36@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
        "David S. Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Alexander Potapenko <glider@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>
To: syzkaller <syzkaller@googlegroups.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5abd6ebd-1249-71a9-da30-65d8371a2a36@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 22, 2016 at 6:29 PM, Oliver Hartkopp <socketcan@hartkopp.net> wrote:
> Hi Andrey,
>
> thanks for the report.
>
> Although I can't see the issue in the code ...
>
> On 11/22/2016 10:22 AM, Andrey Konovalov wrote:
>
>> ==================================================================
>> BUG: KASAN: use-after-free in bcm_rx_thr_flush+0x284/0x2b0
>> Read of size 1 at addr ffff88006c1faae5 by task a.out/3874
>>
>> page:ffffea0001b07e80 count:1 mapcount:0 mapping:          (null)
>> index:0x0
>> flags: 0x100000000000080(slab)
>> page dumped because: kasan: bad access detected
>
>
> (..)
>
>>
>> The buggy address belongs to the object at ffff88006c1faae0
>>  which belongs to the cache kmalloc-32 of size 32
>
>
> ???
>
>> The buggy address ffff88006c1faae5 is located 5 bytes inside
>>  of 32-byte region [ffff88006c1faae0, ffff88006c1fab00)
>
>
> (..)
>
>> Memory state around the buggy address:
>>  ffff88006c1fa980: fc fc fb fb fb fb fc fc fb fb fb fb fc fc fb fb
>>  ffff88006c1faa00: fb fb fc fc fb fb fb fb fc fc fb fb fb fb fc fc
>>>
>>> ffff88006c1faa80: fb fb fb fb fc fc fb fb fb fb fc fc fb fb fb fb
>>
>>                                                        ^
>>  ffff88006c1fab00: fc fc fb fb fb fb fc fc 00 00 00 00 fc fc 00 00
>>  ffff88006c1fab80: 00 00 fc fc fb fb fb fb fc fc fb fb fb fb fc fc
>> ==================================================================
>
>
> (should be some zero initialized memory here)
>
> The relevant code of bcm_rx_do_flush() can be found here:
>
> http://lxr.free-electrons.com/source/net/can/bcm.c#L589
>
> static inline int bcm_rx_do_flush(struct bcm_op *op, int update,
>                                   unsigned int index)
> {
>         struct canfd_frame *lcf = op->last_frames + op->cfsiz * index;
>
>         if ((op->last_frames) && (lcf->flags & RX_THR)) {  <<<----- !!!
>                 if (update)
>                         bcm_rx_changed(op, lcf);
>                 return 1;
>         }
>         return 0;
> }
>
>
> lcf->flags points into an array of struct canfd_frame at offset 5 which is
> allocated here:
>
> http://lxr.free-electrons.com/source/net/can/bcm.c#L1105
>
>         /* create and init array for received CAN frames */
>         op->last_frames = kzalloc(msg_head->nframes * op->cfsiz,
>                                   GFP_KERNEL);
>
> So why does KASAN complain about accessing some kind of 32 byte cache when
> it should point into a zero initialized allocated space?

Hi Oliver,

My guess would be that this is an out-of-bounds access which doesn't
hit the redzone.
The free and alloc stack traces also look unrelated to the access.
Besides I have a bunch of related slab-out-of-bounds reports, see below.

Thanks for looking at this!

==================================================================
BUG: KASAN: slab-out-of-bounds in bcm_send_to_user+0x330/0x480
Read of size 16 at addr ffff88006de17338 by task syz-executor/30679

page:ffffea0001b78580 count:1 mapcount:0 mapping:          (null)
index:0xffff88006de16760 compound_mapcount: 0
flags: 0x500000000004080(slab|head)
page dumped because: kasan: bad access detected

CPU: 2 PID: 30679 Comm: syz-executor Not tainted 4.9.0-rc6+ #429
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffff88003cd277b0 ffffffff81b472e4 ffff88003cd27840 ffff88006de17338
 00000000000000fb 00000000000000fc ffff88003cd27830 ffffffff8150ad42
 0000000000000000 ffffffff81509f65 ffff88006aef9830 0000000000000282
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff81b472e4>] dump_stack+0xb3/0x10f lib/dump_stack.c:51
 [<     inline     >] describe_address mm/kasan/report.c:259
 [<ffffffff8150ad42>] kasan_report_error+0x122/0x560 mm/kasan/report.c:365
 [<ffffffff8150b536>] kasan_report+0x36/0x40 mm/kasan/report.c:387
 [<     inline     >] check_memory_region_inline mm/kasan/kasan.c:308
 [<ffffffff81509d2e>] check_memory_region+0x13e/0x1a0 mm/kasan/kasan.c:315
 [<ffffffff8150a223>] memcpy+0x23/0x50 mm/kasan/kasan.c:350
 [<ffffffff83574410>] bcm_send_to_user+0x330/0x480 net/can/bcm.c:325
 [<ffffffff8357478e>] bcm_rx_changed+0x22e/0x2a0 net/can/bcm.c:443
 [<     inline     >] bcm_rx_do_flush net/can/bcm.c:591
 [<ffffffff83577d1e>] bcm_rx_thr_flush+0x19e/0x2b0 net/can/bcm.c:612
 [<     inline     >] bcm_rx_setup net/can/bcm.c:1199
 [<ffffffff83578b36>] bcm_sendmsg+0xbb6/0x30e0 net/can/bcm.c:1351
 [<     inline     >] sock_sendmsg_nosec net/socket.c:621
 [<ffffffff82b7176c>] sock_sendmsg+0xcc/0x110 net/socket.c:631
 [<ffffffff82b73651>] ___sys_sendmsg+0x771/0x8b0 net/socket.c:1954
 [<ffffffff82b7563e>] __sys_sendmsg+0xce/0x170 net/socket.c:1988
 [<     inline     >] SYSC_sendmsg net/socket.c:1999
 [<ffffffff82b7570d>] SyS_sendmsg+0x2d/0x50 net/socket.c:1995
 [<ffffffff83fc4301>] entry_SYSCALL_64_fastpath+0x1f/0xc2

The buggy address belongs to the object at ffff88006de17320
 which belongs to the cache kmalloc-32 of size 32
The buggy address ffff88006de17338 is located 24 bytes inside
 of 32-byte region [ffff88006de17320, ffff88006de17340)

Freed by task 0:
 [<ffffffff8107e236>] save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
 [<ffffffff81509e56>] save_stack+0x46/0xd0 mm/kasan/kasan.c:495
 [<     inline     >] set_track mm/kasan/kasan.c:507
 [<ffffffff8150a6b3>] kasan_slab_free+0x73/0xc0 mm/kasan/kasan.c:571
 [<     inline     >] slab_free_hook mm/slub.c:1352
 [<     inline     >] slab_free_freelist_hook mm/slub.c:1374
 [<     inline     >] slab_free mm/slub.c:2951
 [<ffffffff81506b98>] kfree+0xe8/0x2b0 mm/slub.c:3871
 [<ffffffff819dd8c1>] selinux_cred_free+0x51/0x80 security/selinux/hooks.c:3725
 [<ffffffff819ce358>] security_cred_free+0x48/0x80 security/security.c:907
 [<ffffffff8117e27d>] put_cred_rcu+0xed/0x390 kernel/cred.c:116
 [<     inline     >] __rcu_reclaim kernel/rcu/rcu.h:118
 [<     inline     >] rcu_do_batch kernel/rcu/tree.c:2776
 [<     inline     >] invoke_rcu_callbacks kernel/rcu/tree.c:3040
 [<     inline     >] __rcu_process_callbacks kernel/rcu/tree.c:3007
 [<ffffffff8125dfe0>] rcu_process_callbacks+0xa40/0x1190 kernel/rcu/tree.c:3024
 [<ffffffff83fc70af>] __do_softirq+0x23f/0x8e5 kernel/softirq.c:284

Allocated by task 4074:
 [<ffffffff8107e236>] save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
 [<ffffffff81509e56>] save_stack+0x46/0xd0 mm/kasan/kasan.c:495
 [<     inline     >] set_track mm/kasan/kasan.c:507
 [<ffffffff8150a0cb>] kasan_kmalloc+0xab/0xe0 mm/kasan/kasan.c:598
 [<ffffffff8150a632>] kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:537
 [<     inline     >] slab_post_alloc_hook mm/slab.h:417
 [<     inline     >] slab_alloc_node mm/slub.c:2708
 [<     inline     >] slab_alloc mm/slub.c:2716
 [<ffffffff815090ef>] __kmalloc_track_caller+0xcf/0x2a0 mm/slub.c:4240
 [<ffffffff8146bf84>] kmemdup+0x24/0x50 mm/util.c:113
 [<ffffffff819dcbe9>] selinux_cred_prepare+0x49/0xb0
security/selinux/hooks.c:3739
 [<ffffffff819ce40d>] security_prepare_creds+0x7d/0xb0 security/security.c:912
 [<ffffffff8117fab3>] prepare_creds+0x243/0x340 kernel/cred.c:277
 [<ffffffff811876a4>] set_current_groups+0x14/0x50 kernel/groups.c:155
 [<     inline     >] SYSC_setgroups kernel/groups.c:221
 [<ffffffff8118807f>] SyS_setgroups+0x17f/0x1d0 kernel/groups.c:202
 [<ffffffff83fc4301>] entry_SYSCALL_64_fastpath+0x1f/0xc2

Memory state around the buggy address:
 ffff88006de17200: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
 ffff88006de17280: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>ffff88006de17300: fc fc fc fc 00 00 00 00 fc fc fc fc fc fc fc fc
                                           ^
 ffff88006de17380: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
 ffff88006de17400: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
==================================================================


>
> I will write some other test cases with a similar setting of options to
> check if I can trigger the instability too.
>
> Tnx & regards,
> Oliver
>
> --
> You received this message because you are subscribed to the Google Groups
> "syzkaller" group.
> To unsubscribe from this group and stop receiving emails from it, send an
> email to syzkaller+unsubscribe@googlegroups.com.
> For more options, visit https://groups.google.com/d/optout.
