From: Xin Long <lucien.xin@gmail.com>
Subject: Re: net/sctp: use-after-free in sctp_association_put
Date: Thu, 2 Mar 2017 16:06:40 +0800
Message-ID: <CADvbK_cXfXcjt-4_RumKaDnErBY0bQVz0Fs25w7J1tPC2Vby3Q@mail.gmail.com>
References: <CACT4Y+YQw66Czzf=_GT8feC969JAJjntSjz7icPM77zMjNBA1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vladislav Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        David Miller <davem@davemloft.net>, linux-sctp@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:36002 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751099AbdCBK6c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 05:58:32 -0500
In-Reply-To: <CACT4Y+YQw66Czzf=_GT8feC969JAJjntSjz7icPM77zMjNBA1A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 2, 2017 at 3:18 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> Hello,
>
> I've got the following report while running syzkaller fuzzer on
> linux-next/8813198236a044b76e251dcae937b180dd527999:
>
> BUG: KASAN: use-after-free in sctp_association_destroy
> net/sctp/associola.c:416 [inline] at addr ffff8801c0fa415c
> BUG: KASAN: use-after-free in sctp_association_put+0x294/0x300
> net/sctp/associola.c:881 at addr ffff8801c0fa415c
> Read of size 1 by task syz-executor1/10956
> CPU: 1 PID: 10956 Comm: syz-executor1 Not tainted 4.10.0-rc7-next-20170213 #1
> Hardware name: Google Google Compute Engine/Google Compute Engine,
> BIOS Google 01/01/2011
> Call Trace:
>  <IRQ>
>  __dump_stack lib/dump_stack.c:15 [inline]
>  dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
>  kasan_object_err+0x1c/0x70 mm/kasan/report.c:162
>  print_address_description mm/kasan/report.c:200 [inline]
>  kasan_report_error mm/kasan/report.c:289 [inline]
>  kasan_report.part.2+0x1e5/0x4b0 mm/kasan/report.c:311
>  kasan_report mm/kasan/report.c:329 [inline]
>  __asan_report_load1_noabort+0x29/0x30 mm/kasan/report.c:329
>  sctp_association_destroy net/sctp/associola.c:416 [inline]
>  sctp_association_put+0x294/0x300 net/sctp/associola.c:881
>  sctp_generate_timeout_event+0x115/0x360 net/sctp/sm_sideeffect.c:317
>  sctp_generate_t1_init_event+0x1a/0x20 net/sctp/sm_sideeffect.c:329
>  call_timer_fn+0x241/0x820 kernel/time/timer.c:1308
>  expire_timers kernel/time/timer.c:1348 [inline]
>  __run_timers+0x9e7/0xe90 kernel/time/timer.c:1642
>  run_timer_softirq+0x21/0x80 kernel/time/timer.c:1655
>  __do_softirq+0x31f/0xbe7 kernel/softirq.c:284
>  invoke_softirq kernel/softirq.c:364 [inline]
>  irq_exit+0x1cc/0x200 kernel/softirq.c:405
>  exiting_irq arch/x86/include/asm/apic.h:658 [inline]
>  smp_apic_timer_interrupt+0x76/0xa0 arch/x86/kernel/apic/apic.c:962
>  apic_timer_interrupt+0x93/0xa0 arch/x86/entry/entry_64.S:707
> RIP: 0010:arch_local_irq_enable arch/x86/include/asm/paravirt.h:788 [inline]
> RIP: 0010:__raw_spin_unlock_irq include/linux/spinlock_api_smp.h:168 [inline]
> RIP: 0010:_raw_spin_unlock_irq+0x56/0x70 kernel/locking/spinlock.c:199
> RSP: 0018:ffff8801c280f178 EFLAGS: 00000286 ORIG_RAX: ffffffffffffff10
> RAX: dffffc0000000000 RBX: ffff8801dbf24a00 RCX: 0000000000000006
> RDX: 1ffffffff0a18d03 RSI: ffff8801d71c88e0 RDI: ffffffff850c6818
> RBP: ffff8801c280f180 R08: 0000000000000002 R09: 0000000000000000
> R10: 0000000000000006 R11: 0000000000000000 R12: ffff8801c0f3a4c0
> R13: 1ffff10038501e38 R14: ffff8801d71c80c0 R15: ffff8801d71c80c0
>  </IRQ>
>  finish_lock_switch kernel/sched/sched.h:1248 [inline]
>  finish_task_switch+0x1c2/0x720 kernel/sched/core.c:2792
>  context_switch kernel/sched/core.c:2928 [inline]
>  __schedule+0x893/0x2290 kernel/sched/core.c:3468
>  preempt_schedule_common+0x35/0x60 kernel/sched/core.c:3579
>  _cond_resched+0x17/0x20 kernel/sched/core.c:4977
>  slab_pre_alloc_hook mm/slab.h:427 [inline]
>  slab_alloc mm/slab.c:3390 [inline]
>  __do_kmalloc mm/slab.c:3730 [inline]
>  __kmalloc_track_caller+0x26a/0x690 mm/slab.c:3747
>  kstrdup+0x39/0x70 mm/util.c:54
>  snd_timer_instance_new+0xfc/0x5d0 sound/core/timer.c:110
>  snd_timer_open+0x878/0x1740 sound/core/timer.c:290
>  snd_timer_user_tselect sound/core/timer.c:1621 [inline]
>  __snd_timer_user_ioctl sound/core/timer.c:1901 [inline]
>  snd_timer_user_ioctl+0x9b1/0x34a0 sound/core/timer.c:1931
>  vfs_ioctl fs/ioctl.c:43 [inline]
>  do_vfs_ioctl+0x1bf/0x1790 fs/ioctl.c:683
>  SYSC_ioctl fs/ioctl.c:698 [inline]
>  SyS_ioctl+0x8f/0xc0 fs/ioctl.c:689
>  entry_SYSCALL_64_fastpath+0x1f/0xc2
> RIP: 0033:0x44fb59
> RSP: 002b:00007f0dc184db58 EFLAGS: 00000212 ORIG_RAX: 0000000000000010
> RAX: ffffffffffffffda RBX: 0000000040345410 RCX: 000000000044fb59
> RDX: 0000000020001000 RSI: 0000000040345410 RDI: 0000000000000005
> RBP: 0000000000000005 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000212 R12: 0000000000708000
> R13: 0000000000a5fc57 R14: 00007f0dc184e9c0 R15: 0000000000000000
> Object at ffff8801c0fa4140, in cache kmalloc-4096 size: 4096
> Allocated:
> PID = 10965
>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
>  save_stack+0x43/0xd0 mm/kasan/kasan.c:504
>  set_track mm/kasan/kasan.c:516 [inline]
>  kasan_kmalloc+0xaa/0xd0 mm/kasan/kasan.c:607
>  kmem_cache_alloc_trace+0x10b/0x670 mm/slab.c:3634
>  kmalloc include/linux/slab.h:490 [inline]
>  kzalloc include/linux/slab.h:663 [inline]
>  sctp_association_new+0x114/0x2120 net/sctp/associola.c:306
>  sctp_sendmsg+0x1585/0x38f0 net/sctp/socket.c:1835
>  inet_sendmsg+0x164/0x5b0 net/ipv4/af_inet.c:761
>  sock_sendmsg_nosec net/socket.c:633 [inline]
>  sock_sendmsg+0xca/0x110 net/socket.c:643
>  ___sys_sendmsg+0x8fa/0x9f0 net/socket.c:1985
>  __sys_sendmsg+0x138/0x300 net/socket.c:2019
>  SYSC_sendmsg net/socket.c:2030 [inline]
>  SyS_sendmsg+0x2d/0x50 net/socket.c:2026
>  entry_SYSCALL_64_fastpath+0x1f/0xc2
> Freed:
> PID = 10965
>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
>  save_stack+0x43/0xd0 mm/kasan/kasan.c:504
>  set_track mm/kasan/kasan.c:516 [inline]
>  kasan_slab_free+0x6f/0xb0 mm/kasan/kasan.c:580
>  __cache_free mm/slab.c:3510 [inline]
>  kfree+0xd3/0x250 mm/slab.c:3827
>  sctp_association_destroy net/sctp/associola.c:432 [inline]
>  sctp_association_put+0x20e/0x300 net/sctp/associola.c:881
>  sctp_association_free+0x635/0x8d0 net/sctp/associola.c:410
>  sctp_cmd_delete_tcb net/sctp/sm_sideeffect.c:891 [inline]
>  sctp_cmd_interpreter net/sctp/sm_sideeffect.c:1306 [inline]
>  sctp_side_effects net/sctp/sm_sideeffect.c:1171 [inline]
>  sctp_do_sm+0x28a2/0x6900 net/sctp/sm_sideeffect.c:1143
>  sctp_primitive_SHUTDOWN+0xa9/0xd0 net/sctp/primitive.c:104
>  sctp_close+0x3c3/0x9d0 net/sctp/socket.c:1530
>  inet_release+0xed/0x1c0 net/ipv4/af_inet.c:425
>  inet6_release+0x50/0x70 net/ipv6/af_inet6.c:432
>  sock_release+0x8d/0x1e0 net/socket.c:597
>  sock_close+0x16/0x20 net/socket.c:1061
>  __fput+0x332/0x7f0 fs/file_table.c:208
>  ____fput+0x15/0x20 fs/file_table.c:244
>  task_work_run+0x18a/0x260 kernel/task_work.c:116
>  exit_task_work include/linux/task_work.h:21 [inline]
>  do_exit+0x1956/0x2900 kernel/exit.c:873
>  do_group_exit+0x149/0x420 kernel/exit.c:977
>  get_signal+0x7e0/0x1820 kernel/signal.c:2313
>  do_signal+0xd2/0x2190 arch/x86/kernel/signal.c:807
>  exit_to_usermode_loop+0x200/0x2a0 arch/x86/entry/common.c:156
>  prepare_exit_to_usermode arch/x86/entry/common.c:190 [inline]
>  syscall_return_slowpath+0x4d3/0x570 arch/x86/entry/common.c:259
>  entry_SYSCALL_64_fastpath+0xc0/0xc2
> Memory state around the buggy address:
>  ffff8801c0fa4000: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>  ffff8801c0fa4080: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>>ffff8801c0fa4100: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
>                                                     ^
>  ffff8801c0fa4180: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>  ffff8801c0fa4200: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> ==================================================================
>
>
>
> Shouldn't sctp_association_free call del_timer_sync instead of del_timer?
I think it's safe to use del_timer there, as the timer handler
sctp_generate_timeout_event checks asoc->base.dead under
sock lock to decide if it will call the event handler.

So even if sctp_association_free free the assoc (not destroyed),
another timer handler in other CPU will not crash the kernel.

The issue here is more like asoc's refcnt <=1 already when T1
timer handler was running, somewhere put asoc incorrectly.

Hi Dmitry, do you have reproducer and .config for this ?

Thanks.

> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
