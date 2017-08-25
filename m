From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] about net: Fix inconsistent teardown and release of
 private netdev state.
Date: Fri, 25 Aug 2017 07:57:37 -0700
Message-ID: <1503673057.11498.3.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1503062029.4936.173.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170818.155835.2053259542629638150.davem@davemloft.net>
         <1503114001.14953.8.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170821.141315.2143125372476050164.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35716 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932602AbdHYO5l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 10:57:41 -0400
Received: by mail-pg0-f65.google.com with SMTP id r133so70333pgr.2
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 07:57:41 -0700 (PDT)
In-Reply-To: <20170821.141315.2143125372476050164.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-08-21 at 14:13 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 18 Aug 2017 20:40:01 -0700
> 
> > Let look at tun->pcpu_stats, for example.
> > 
> > It is allocated at line 1831, before the register_netdevice()
> > 
> > drivers/net/tun.c does not provide ndo_init()
> 
> I see the problem now.
> 
> And it's done this way because several steps need to occur, with
> various kinds of dependencies, before the register_netdevice() call is
> made.
> 
> I'll see if I can untangle this somehow.

I guess we could enforce having an ndo_init() for all drivers providing
ndo_uninit()


==================================================================
BUG: KASAN: use-after-free in hlist_move_list include/linux/list.h:729 [inline]
BUG: KASAN: use-after-free in __collect_expired_timers kernel/time/timer.c:1326 [inline]
BUG: KASAN: use-after-free in collect_expired_timers kernel/time/timer.c:1550 [inline]
BUG: KASAN: use-after-free in __run_timers+0xa2e/0xb90 kernel/time/timer.c:1597
Write of size 8 at addr ffff8801cc8bbb00 by task syz-executor3/5627

CPU: 1 PID: 5627 Comm: syz-executor3 Not tainted 4.13.0-rc6+ #45
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
Call Trace:
 <IRQ>
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x194/0x257 lib/dump_stack.c:52
 print_address_description+0x73/0x250 mm/kasan/report.c:252
 kasan_report_error mm/kasan/report.c:351 [inline]
 kasan_report+0x24e/0x340 mm/kasan/report.c:409
 __asan_report_store8_noabort+0x17/0x20 mm/kasan/report.c:435
 hlist_move_list include/linux/list.h:729 [inline]
 __collect_expired_timers kernel/time/timer.c:1326 [inline]
 collect_expired_timers kernel/time/timer.c:1550 [inline]
 __run_timers+0xa2e/0xb90 kernel/time/timer.c:1597
 run_timer_softirq+0x21/0x80 kernel/time/timer.c:1614
 __do_softirq+0x2f5/0xba3 kernel/softirq.c:284
 invoke_softirq kernel/softirq.c:364 [inline]
 irq_exit+0x1cc/0x200 kernel/softirq.c:405
 exiting_irq arch/x86/include/asm/apic.h:638 [inline]
 smp_apic_timer_interrupt+0x76/0xa0 arch/x86/kernel/apic/apic.c:1044
 apic_timer_interrupt+0x93/0xa0 arch/x86/entry/entry_64.S:702
RIP: 0010:arch_local_irq_restore arch/x86/include/asm/paravirt.h:814 [inline]
RIP: 0010:rmqueue_pcplist mm/page_alloc.c:2789 [inline]
RIP: 0010:rmqueue mm/page_alloc.c:2806 [inline]
RIP: 0010:get_page_from_freelist+0x8ec/0x3430 mm/page_alloc.c:3144
RSP: 0018:ffff8801c6b8e0c0 EFLAGS: 00000286 ORIG_RAX: ffffffffffffff10
RAX: 1ffffffff0b59431 RBX: 000000000000000f RCX: 0000000000000006
RDX: 0000000000000000 RSI: 1ffff10038ca2944 RDI: 0000000000000286
RBP: ffff8801c6b8e7a8 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: ffffea0006a8c880 R12: 0000000000000000
R13: dffffc0000000000 R14: 0000000000000000 R15: ffff8801c6b8e780
 </IRQ>
 __alloc_pages_nodemask+0x516/0xd40 mm/page_alloc.c:4096
 alloc_pages_vma+0xc8/0x4b0 mm/mempolicy.c:1938
 shmem_alloc_page+0x171/0x2c0 mm/shmem.c:1448
 shmem_alloc_and_acct_page+0x14d/0x5f0 mm/shmem.c:1478
 shmem_getpage_gfp+0x7bb/0x3870 mm/shmem.c:1757
 shmem_fault+0x2b9/0x960 mm/shmem.c:1995
 __do_fault+0xeb/0x30e mm/memory.c:3011
 do_read_fault mm/memory.c:3421 [inline]
 do_fault mm/memory.c:3521 [inline]
 handle_pte_fault mm/memory.c:3751 [inline]
 __handle_mm_fault+0x1a2d/0x3860 mm/memory.c:3869
 handle_mm_fault+0x3bb/0x860 mm/memory.c:3906
 faultin_page mm/gup.c:477 [inline]
 __get_user_pages+0x4f8/0x15d0 mm/gup.c:674
 populate_vma_page_range+0x20e/0x2f0 mm/gup.c:1127
 __mm_populate+0x23a/0x450 mm/gup.c:1177
 mm_populate include/linux/mm.h:2116 [inline]
 vm_mmap_pgoff+0x241/0x280 mm/util.c:338
 SYSC_mmap_pgoff mm/mmap.c:1517 [inline]
 SyS_mmap_pgoff+0x23b/0x5f0 mm/mmap.c:1475
 SYSC_mmap arch/x86/kernel/sys_x86_64.c:98 [inline]
 SyS_mmap+0x16/0x20 arch/x86/kernel/sys_x86_64.c:89
 entry_SYSCALL_64_fastpath+0x1f/0xbe
RIP: 0033:0x4512e9
RSP: 002b:00007f5effbabc08 EFLAGS: 00000216 ORIG_RAX: 0000000000000009
RAX: ffffffffffffffda RBX: 0000000000718000 RCX: 00000000004512e9
RDX: 0000000001000001 RSI: 0000000000b36000 RDI: 0000000020000000
RBP: 0000000000000086 R08: ffffffffffffffff R09: 0000000000000000
R10: 0000000000008031 R11: 0000000000000216 R12: 00000000004b8a52
R13: 00000000ffffffff R14: ffffffffffffffff R15: 0000000000005417

Allocated by task 5206:
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:447
 set_track mm/kasan/kasan.c:459 [inline]
 kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:551
 __do_kmalloc_node mm/slab.c:3689 [inline]
 __kmalloc_node+0x47/0x70 mm/slab.c:3696
 kmalloc_node include/linux/slab.h:535 [inline]
 kvmalloc_node+0x64/0xd0 mm/util.c:397
 kvmalloc include/linux/mm.h:524 [inline]
 kvzalloc include/linux/mm.h:532 [inline]
 alloc_netdev_mqs+0x16e/0xed0 net/core/dev.c:7968
 tun_set_iff drivers/net/tun.c:1808 [inline]
 __tun_chr_ioctl+0x12b2/0x3d60 drivers/net/tun.c:2067
 tun_chr_ioctl+0x2a/0x40 drivers/net/tun.c:2312
 vfs_ioctl fs/ioctl.c:45 [inline]
 do_vfs_ioctl+0x1b1/0x1520 fs/ioctl.c:685
 SYSC_ioctl fs/ioctl.c:700 [inline]
 SyS_ioctl+0x8f/0xc0 fs/ioctl.c:691
 entry_SYSCALL_64_fastpath+0x1f/0xbe

Freed by task 5206:
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:447
 set_track mm/kasan/kasan.c:459 [inline]
 kasan_slab_free+0x71/0xc0 mm/kasan/kasan.c:524
 __cache_free mm/slab.c:3503 [inline]
 kfree+0xca/0x250 mm/slab.c:3820
 kvfree+0x36/0x60 mm/util.c:416
 netdev_freemem net/core/dev.c:7920 [inline]
 free_netdev+0x2cf/0x360 net/core/dev.c:8082
 tun_set_iff drivers/net/tun.c:1891 [inline]
 __tun_chr_ioctl+0x2d24/0x3d60 drivers/net/tun.c:2067
 tun_chr_ioctl+0x2a/0x40 drivers/net/tun.c:2312
 vfs_ioctl fs/ioctl.c:45 [inline]
 do_vfs_ioctl+0x1b1/0x1520 fs/ioctl.c:685
 SYSC_ioctl fs/ioctl.c:700 [inline]
 SyS_ioctl+0x8f/0xc0 fs/ioctl.c:691
 entry_SYSCALL_64_fastpath+0x1f/0xbe

The buggy address belongs to the object at ffff8801cc8b87c0
 which belongs to the cache kmalloc-16384 of size 16384
The buggy address is located 13120 bytes inside of
 16384-byte region [ffff8801cc8b87c0, ffff8801cc8bc7c0)
The buggy address belongs to the page:
page:ffffea0007322e00 count:1 mapcount:0 mapping:ffff8801cc8b87c0 index:0x0 compound_mapcount: 0
flags: 0x200000000008100(slab|head)
raw: 0200000000008100 ffff8801cc8b87c0 0000000000000000 0000000100000001
raw: ffffea0007320c20 ffffea0007329220 ffff8801dac02200 0000000000000000
page dumped because: kasan: bad access detected

Memory state around the buggy address:
 ffff8801cc8bba00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff8801cc8bba80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>ffff8801cc8bbb00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                   ^
 ffff8801cc8bbb80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff8801cc8bbc00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================
