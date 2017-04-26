From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: net/ipv6: use-after-free in __call_rcu/in6_dev_finish_destroy_rcu
Date: Wed, 26 Apr 2017 08:13:48 -0700
Message-ID: <20170426151348.GR3956@linux.vnet.ibm.com>
References: <CAAeHK+y=YqG0Kb2chQ=_2E8aPttMetQjZPCxFibHKCfktQS2PQ@mail.gmail.com>
 <20170426135950.GO3956@linux.vnet.ibm.com>
 <CAAeHK+zZgV9c2RfVhX1m737Kx4mfrHUCf1txiaFi8Er4c1Zr=w@mail.gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Josh Triplett <josh@joshtriplett.org>,
        Steven Rostedt <rostedt@goodmis.org>,
        Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
        Lai Jiangshan <jiangshanlai@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAAeHK+zZgV9c2RfVhX1m737Kx4mfrHUCf1txiaFi8Er4c1Zr=w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 26, 2017 at 04:45:51PM +0200, Andrey Konovalov wrote:
> On Wed, Apr 26, 2017 at 3:59 PM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> > On Wed, Apr 26, 2017 at 02:34:15PM +0200, Andrey Konovalov wrote:
> >> Hi,
> >>
> >> I've got the following error report while fuzzing the kernel with syzkaller.
> >>
> >> On commit 5a7ad1146caa895ad718a534399e38bd2ba721b7 (4.11-rc8).
> >>
> >> Unfortunately it's not reproducible.
> >>
> >> I'm not sure whether is is an issue with rcu or ipv6.
> >>
> >> ==================================================================
> >> BUG: KASAN: use-after-free in __call_rcu.constprop.77+0x13be/0x1640
> >
> > Does building with CONFIG_DEBUG_OBJECTS_RCU_HEAD=y show any splats?
> > (Yeah, kind of a stupid question if it is not reproducible, but had
> > to ask!)
> 
> Hi Paul,
> 
> I'll try enabling this config.
> 
> In the meantime, while I was trying to reproduce this issue, I got this warning:
> 
> ------------[ cut here ]------------
> WARNING: CPU: 0 PID: 4590 at kernel/rcu/tree.c:2919
> rcu_do_batch.isra.65+0x845/0xbd0
> Modules linked in:
> CPU: 0 PID: 4590 Comm: syz-executor Not tainted 4.11.0-rc8+ #270
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Call Trace:
>  <IRQ>
>  __dump_stack lib/dump_stack.c:16
>  dump_stack+0x192/0x22d lib/dump_stack.c:52
>  __warn+0x19f/0x1e0 kernel/panic.c:549
>  warn_slowpath_null+0x2c/0x40 kernel/panic.c:584
>  rcu_do_batch.isra.65+0x845/0xbd0 kernel/rcu/tree.c:2919
>  invoke_rcu_callbacks kernel/rcu/tree.c:3142
>  __rcu_process_callbacks kernel/rcu/tree.c:3109
>  rcu_process_callbacks+0x23f/0x810 kernel/rcu/tree.c:3126
>  __do_softirq+0x253/0x78b kernel/softirq.c:284
>  invoke_softirq kernel/softirq.c:364
>  irq_exit+0x149/0x180 kernel/softirq.c:405
>  exiting_irq ./arch/x86/include/asm/apic.h:657
>  smp_apic_timer_interrupt+0x76/0xa0 arch/x86/kernel/apic/apic.c:962
>  apic_timer_interrupt+0x89/0x90
> RIP: 0010:do_anonymous_page mm/memory.c:2962
> RIP: 0010:handle_pte_fault mm/memory.c:3721
> RIP: 0010:__handle_mm_fault+0xdab/0x1c00 mm/memory.c:3841
> RSP: 0018:ffff88006a02f7d0 EFLAGS: 00000246 ORIG_RAX: ffffffffffffff10
> RAX: 000000000005dab0 RBX: 1ffff1000d405f00 RCX: 1ffff1000d28cd3f
> RDX: dffffc0000000000 RSI: 8000000000000025 RDI: ffff8800694669f8
> RBP: ffff88006a02f9a8 R08: 00000000014280ca R09: 1ffff1000d405eb0
> R10: ffff88006a02f660 R11: dffffc0000000000 R12: ffff88006a02f8e0
> R13: ffff88006a02f980 R14: ffff8800694669b0 R15: ffff880069466a00
>  </IRQ>
>  handle_mm_fault+0x1aa/0x450 mm/memory.c:3878
>  faultin_page mm/gup.c:408
>  __get_user_pages+0x606/0x14a0 mm/gup.c:607
>  populate_vma_page_range+0xd9/0x100 mm/gup.c:1062
>  __mm_populate+0x278/0x540 mm/gup.c:1112
>  mm_populate ./include/linux/mm.h:2132
>  vm_mmap_pgoff+0x258/0x280 mm/util.c:314
>  SYSC_mmap_pgoff mm/mmap.c:1503
>  SyS_mmap_pgoff+0x22c/0x5e0 mm/mmap.c:1461
>  SYSC_mmap arch/x86/kernel/sys_x86_64.c:96
>  SyS_mmap+0x16/0x20 arch/x86/kernel/sys_x86_64.c:87
>  entry_SYSCALL_64_fastpath+0x1a/0xa9 arch/x86/entry/entry_64.S:204
> RIP: 0033:0x4458e9
> RSP: 002b:00007f3a15ce4b58 EFLAGS: 00000282 ORIG_RAX: 0000000000000009
> RAX: ffffffffffffffda RBX: 00007f3a15ce5700 RCX: 00000000004458e9
> RDX: 0000000000000002 RSI: 00000000009b8000 RDI: 0000000020000000
> RBP: 0000000000000000 R08: ffffffffffffffff R09: 8000000000000000
> R10: 0000000000008032 R11: 0000000000000282 R12: 0000000000000000
> R13: 0000000000000000 R14: 00007f3a15ce59c0 R15: 00007f3a15ce5700
> ---[ end trace e36457085170396e ]---

This is current mainline, somewhere after v4.11-rc1 and linus/master?

If so, this warning indicates that RCU's callback list has been corrupted.
This could be a bug in RCU, and if this was 4.12-rc1 and later, my
first guess would be upcoming changes in RCU callback handling.  But I
am pretty sure that you are not running 4.12-rc1.

So I will instead guess that you are double-call_rcu()-ing (sort of like
double-free, except with call_rcu() and friends instead of kfree()).
Or, alternatively, the call_rcu() counterpart to use-after-free.

							Thanx, Paul

> >> kernel/rcu/tree.c:3269 at addr ffff88003b842280
> >> Write of size 8 by task kworker/u10:1/180
> >> CPU: 2 PID: 180 Comm: kworker/u10:1 Not tainted 4.11.0-rc8+ #270
> >> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> >> Workqueue: events_unbound call_usermodehelper_exec_work
> >> Call Trace:
> >>  __dump_stack lib/dump_stack.c:16 [inline]
> >>  dump_stack+0x192/0x22d lib/dump_stack.c:52
> >>  kasan_object_err+0x1c/0x70 mm/kasan/report.c:164
> >>  print_address_description mm/kasan/report.c:202 [inline]
> >>  kasan_report_error mm/kasan/report.c:291 [inline]
> >>  kasan_report+0x252/0x510 mm/kasan/report.c:347
> >>  __asan_report_store8_noabort+0x17/0x20 mm/kasan/report.c:373
> >>  __call_rcu.constprop.77+0x13be/0x1640 kernel/rcu/tree.c:3269
> >>  call_rcu_sched+0x12/0x20 kernel/rcu/tree.c:3288
> >>  free_pid+0x446/0x5d0 kernel/pid.c:293
> >>  __change_pid+0x2a1/0x3d0 kernel/pid.c:411
> >>  detach_pid+0x1f/0x30 kernel/pid.c:416
> >>  __unhash_process kernel/exit.c:74 [inline]
> >>  __exit_signal kernel/exit.c:155 [inline]
> >>  release_task+0xbb0/0x1d90 kernel/exit.c:199
> >>  wait_task_zombie kernel/exit.c:1230 [inline]
> >>  wait_consider_task+0x11fe/0x3410 kernel/exit.c:1458
> >>  do_wait_thread kernel/exit.c:1521 [inline]
> >>  do_wait+0x3ea/0x8e0 kernel/exit.c:1592
> >>  SYSC_wait4 kernel/exit.c:1720 [inline]
> >>  SyS_wait4+0x208/0x340 kernel/exit.c:1689
> >>  call_usermodehelper_exec_sync kernel/kmod.c:292 [inline]
> >>  call_usermodehelper_exec_work+0x1a7/0x2b0 kernel/kmod.c:329
> >>  process_one_work+0x9f7/0x1580 kernel/workqueue.c:2097
> >>  worker_thread+0x1df/0x14b0 kernel/workqueue.c:2231
> >>  kthread+0x31f/0x3f0 kernel/kthread.c:231
> >>  ret_from_fork+0x2c/0x40 arch/x86/entry/entry_64.S:430
> >> Object at ffff88003b842018, in cache kmalloc-1024 size: 1024
> >> Allocated:
> >> PID = 1
> >>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
> >>  save_stack+0x43/0xd0 mm/kasan/kasan.c:513
> >>  set_track mm/kasan/kasan.c:525 [inline]
> >>  kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:616
> >>  kmem_cache_alloc_trace+0x61/0x170 mm/slub.c:2745
> >>  kmalloc include/linux/slab.h:490 [inline]
> >>  kzalloc include/linux/slab.h:663 [inline]
> >>  ipv6_add_dev+0x199/0x1380 net/ipv6/addrconf.c:380
> >>  addrconf_init+0xd0/0x29a net/ipv6/addrconf.c:6405
> >>  inet6_init+0x2f6/0x584 net/ipv6/af_inet6.c:962
> >>  do_one_initcall+0xf3/0x380 init/main.c:792
> >>  do_initcall_level init/main.c:858 [inline]
> >>  do_initcalls init/main.c:866 [inline]
> >>  do_basic_setup init/main.c:884 [inline]
> >>  kernel_init_freeable+0x54d/0x622 init/main.c:1035
> >>  kernel_init+0x13/0x180 init/main.c:959
> >>  ret_from_fork+0x2c/0x40 arch/x86/entry/entry_64.S:430
> >> Freed:
> >> PID = 6479
> >>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
> >>  save_stack+0x43/0xd0 mm/kasan/kasan.c:513
> >>  set_track mm/kasan/kasan.c:525 [inline]
> >>  kasan_slab_free+0x73/0xc0 mm/kasan/kasan.c:589
> >>  slab_free_hook mm/slub.c:1357 [inline]
> >>  slab_free_freelist_hook mm/slub.c:1379 [inline]
> >>  slab_free mm/slub.c:2961 [inline]
> >>  kfree+0x91/0x190 mm/slub.c:3882
> >>  in6_dev_finish_destroy_rcu+0x97/0xc0 net/ipv6/addrconf_core.c:150
> >>  __rcu_reclaim kernel/rcu/rcu.h:118 [inline]
> >>  rcu_do_batch.isra.65+0x6de/0xbd0 kernel/rcu/tree.c:2879
> >>  invoke_rcu_callbacks kernel/rcu/tree.c:3142 [inline]
> >>  __rcu_process_callbacks kernel/rcu/tree.c:3109 [inline]
> >>  rcu_process_callbacks+0x23f/0x810 kernel/rcu/tree.c:3126
> >>  __do_softirq+0x253/0x78b kernel/softirq.c:284
> >> Memory state around the buggy address:
> >>  ffff88003b842180: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> >>  ffff88003b842200: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> >> >ffff88003b842280: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> >>                    ^
> >>  ffff88003b842300: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> >>  ffff88003b842380: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> >> ==================================================================
> >>
> >
> 
