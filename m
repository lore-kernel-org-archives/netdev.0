From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: net/ipv6: use-after-free in __call_rcu/in6_dev_finish_destroy_rcu
Date: Wed, 26 Apr 2017 06:59:50 -0700
Message-ID: <20170426135950.GO3956@linux.vnet.ibm.com>
References: <CAAeHK+y=YqG0Kb2chQ=_2E8aPttMetQjZPCxFibHKCfktQS2PQ@mail.gmail.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:44263 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S3000871AbdDZN77 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 09:59:59 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3QDs9kF074344
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 09:59:58 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2a2ebxdkdp-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 09:59:58 -0400
Received: from localhost
        by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
        Wed, 26 Apr 2017 09:59:57 -0400
Content-Disposition: inline
In-Reply-To: <CAAeHK+y=YqG0Kb2chQ=_2E8aPttMetQjZPCxFibHKCfktQS2PQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 02:34:15PM +0200, Andrey Konovalov wrote:
> Hi,
> 
> I've got the following error report while fuzzing the kernel with syzkaller.
> 
> On commit 5a7ad1146caa895ad718a534399e38bd2ba721b7 (4.11-rc8).
> 
> Unfortunately it's not reproducible.
> 
> I'm not sure whether is is an issue with rcu or ipv6.
> 
> ==================================================================
> BUG: KASAN: use-after-free in __call_rcu.constprop.77+0x13be/0x1640

Does building with CONFIG_DEBUG_OBJECTS_RCU_HEAD=y show any splats?
(Yeah, kind of a stupid question if it is not reproducible, but had
to ask!)

							Thanx, Paul

> kernel/rcu/tree.c:3269 at addr ffff88003b842280
> Write of size 8 by task kworker/u10:1/180
> CPU: 2 PID: 180 Comm: kworker/u10:1 Not tainted 4.11.0-rc8+ #270
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Workqueue: events_unbound call_usermodehelper_exec_work
> Call Trace:
>  __dump_stack lib/dump_stack.c:16 [inline]
>  dump_stack+0x192/0x22d lib/dump_stack.c:52
>  kasan_object_err+0x1c/0x70 mm/kasan/report.c:164
>  print_address_description mm/kasan/report.c:202 [inline]
>  kasan_report_error mm/kasan/report.c:291 [inline]
>  kasan_report+0x252/0x510 mm/kasan/report.c:347
>  __asan_report_store8_noabort+0x17/0x20 mm/kasan/report.c:373
>  __call_rcu.constprop.77+0x13be/0x1640 kernel/rcu/tree.c:3269
>  call_rcu_sched+0x12/0x20 kernel/rcu/tree.c:3288
>  free_pid+0x446/0x5d0 kernel/pid.c:293
>  __change_pid+0x2a1/0x3d0 kernel/pid.c:411
>  detach_pid+0x1f/0x30 kernel/pid.c:416
>  __unhash_process kernel/exit.c:74 [inline]
>  __exit_signal kernel/exit.c:155 [inline]
>  release_task+0xbb0/0x1d90 kernel/exit.c:199
>  wait_task_zombie kernel/exit.c:1230 [inline]
>  wait_consider_task+0x11fe/0x3410 kernel/exit.c:1458
>  do_wait_thread kernel/exit.c:1521 [inline]
>  do_wait+0x3ea/0x8e0 kernel/exit.c:1592
>  SYSC_wait4 kernel/exit.c:1720 [inline]
>  SyS_wait4+0x208/0x340 kernel/exit.c:1689
>  call_usermodehelper_exec_sync kernel/kmod.c:292 [inline]
>  call_usermodehelper_exec_work+0x1a7/0x2b0 kernel/kmod.c:329
>  process_one_work+0x9f7/0x1580 kernel/workqueue.c:2097
>  worker_thread+0x1df/0x14b0 kernel/workqueue.c:2231
>  kthread+0x31f/0x3f0 kernel/kthread.c:231
>  ret_from_fork+0x2c/0x40 arch/x86/entry/entry_64.S:430
> Object at ffff88003b842018, in cache kmalloc-1024 size: 1024
> Allocated:
> PID = 1
>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
>  save_stack+0x43/0xd0 mm/kasan/kasan.c:513
>  set_track mm/kasan/kasan.c:525 [inline]
>  kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:616
>  kmem_cache_alloc_trace+0x61/0x170 mm/slub.c:2745
>  kmalloc include/linux/slab.h:490 [inline]
>  kzalloc include/linux/slab.h:663 [inline]
>  ipv6_add_dev+0x199/0x1380 net/ipv6/addrconf.c:380
>  addrconf_init+0xd0/0x29a net/ipv6/addrconf.c:6405
>  inet6_init+0x2f6/0x584 net/ipv6/af_inet6.c:962
>  do_one_initcall+0xf3/0x380 init/main.c:792
>  do_initcall_level init/main.c:858 [inline]
>  do_initcalls init/main.c:866 [inline]
>  do_basic_setup init/main.c:884 [inline]
>  kernel_init_freeable+0x54d/0x622 init/main.c:1035
>  kernel_init+0x13/0x180 init/main.c:959
>  ret_from_fork+0x2c/0x40 arch/x86/entry/entry_64.S:430
> Freed:
> PID = 6479
>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
>  save_stack+0x43/0xd0 mm/kasan/kasan.c:513
>  set_track mm/kasan/kasan.c:525 [inline]
>  kasan_slab_free+0x73/0xc0 mm/kasan/kasan.c:589
>  slab_free_hook mm/slub.c:1357 [inline]
>  slab_free_freelist_hook mm/slub.c:1379 [inline]
>  slab_free mm/slub.c:2961 [inline]
>  kfree+0x91/0x190 mm/slub.c:3882
>  in6_dev_finish_destroy_rcu+0x97/0xc0 net/ipv6/addrconf_core.c:150
>  __rcu_reclaim kernel/rcu/rcu.h:118 [inline]
>  rcu_do_batch.isra.65+0x6de/0xbd0 kernel/rcu/tree.c:2879
>  invoke_rcu_callbacks kernel/rcu/tree.c:3142 [inline]
>  __rcu_process_callbacks kernel/rcu/tree.c:3109 [inline]
>  rcu_process_callbacks+0x23f/0x810 kernel/rcu/tree.c:3126
>  __do_softirq+0x253/0x78b kernel/softirq.c:284
> Memory state around the buggy address:
>  ffff88003b842180: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>  ffff88003b842200: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> >ffff88003b842280: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>                    ^
>  ffff88003b842300: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>  ffff88003b842380: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> ==================================================================
> 
