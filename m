From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] ipv4: igmp: fix a use after free
Date: Fri, 9 Jun 2017 02:22:12 +0800
Message-ID: <CADvbK_fWOFWZxKc8gbzeDeU1ALq5GHxKvoGsPt+GsdAP0a601w@mail.gmail.com>
References: <CAAeHK+xmSxokDidhzP1VWgmbbwege4OaGvOA4PwTP1scs6J5zA@mail.gmail.com>
 <1496929425.736.73.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Andrey Konovalov <andreyknvl@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:35298 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751132AbdFHSWN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 14:22:13 -0400
Received: by mail-qt0-f194.google.com with SMTP id x58so10018060qtc.2
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 11:22:13 -0700 (PDT)
In-Reply-To: <1496929425.736.73.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 8, 2017 at 9:43 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Andrey reported a use-after-free in add_grec(), courtesy of syzkaller.
>
> Problem here is that igmp_stop_timer() uses a del_timer(), so we can not
> guarantee that another cpu is not servicing the timer.
>
> Therefore, if igmp_group_dropped() call from ip_mc_dec_group() is
> immediately followed by ip_mc_clear_src(), ip_mc_clear_src() might free
> memory that could be used by the other cpu servicing the timer.
>
> To fix this issue, we should defer the memory freeing
> (ip_mc_clear_src()) to the point all references to (struct
> ip_mc_list)->refcnt have been released.
> This happens in ip_ma_put()
>
>
> ==================================================================
> BUG: KASAN: use-after-free in add_grec+0x101e/0x1090 net/ipv4/igmp.c:473
> Read of size 8 at addr ffff88003053c1a0 by task swapper/0/0
>
> CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.12.0-rc3+ #370
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Call Trace:
>  <IRQ>
>  __dump_stack lib/dump_stack.c:16 [inline]
>  dump_stack+0x292/0x395 lib/dump_stack.c:52
>  print_address_description+0x73/0x280 mm/kasan/report.c:252
>  kasan_report_error mm/kasan/report.c:351 [inline]
>  kasan_report+0x22b/0x340 mm/kasan/report.c:408
>  __asan_report_load8_noabort+0x14/0x20 mm/kasan/report.c:429
>  add_grec+0x101e/0x1090 net/ipv4/igmp.c:473
>  igmpv3_send_cr net/ipv4/igmp.c:663 [inline]
>  igmp_ifc_timer_expire+0x46d/0xa80 net/ipv4/igmp.c:768
the call trace is igmp_ifc_timer_expire -> igmpv3_send_cr -> add_grec
and the timer should be in_dev->mr_ifc_timer.
but igmp_stop_timer you mentioned is used to stop im->timer

It's possible that ip_mc_clear_src is done in ip_ma_put()
while igmp_ifc_timer_expire is still using ip_mc_list under
rcu_read_lock(). no ?

> IPVS: length: 51 != 8
>  call_timer_fn+0x23f/0x800 kernel/time/timer.c:1268
>  expire_timers kernel/time/timer.c:1307 [inline]
>  __run_timers+0x94e/0xcd0 kernel/time/timer.c:1601
>  run_timer_softirq+0x21/0x80 kernel/time/timer.c:1614
>  __do_softirq+0x2fb/0xb99 kernel/softirq.c:284
>  invoke_softirq kernel/softirq.c:364 [inline]
>  irq_exit+0x19e/0x1d0 kernel/softirq.c:405
>  exiting_irq arch/x86/include/asm/apic.h:652 [inline]
>  smp_apic_timer_interrupt+0x76/0xa0 arch/x86/kernel/apic/apic.c:966
>  apic_timer_interrupt+0x93/0xa0 arch/x86/entry/entry_64.S:481
> RIP: 0010:native_safe_halt+0x6/0x10 arch/x86/include/asm/irqflags.h:53
> RSP: 0018:ffffffff85a079a8 EFLAGS: 00000282 ORIG_RAX: ffffffffffffff10
> RAX: dffffc0000000020 RBX: 1ffffffff0b40f38 RCX: 0000000000000000
> RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffffffff85a2a9e4
> RBP: ffffffff85a079a8 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000000 R12: dffffc0000000000
> R13: ffffffff85a07a60 R14: ffffffff86171338 R15: 1ffffffff0b40f5b
>  </IRQ>
>  arch_safe_halt arch/x86/include/asm/paravirt.h:98 [inline]
>  default_idle+0x8f/0x440 arch/x86/kernel/process.c:341
>  arch_cpu_idle+0xa/0x10 arch/x86/kernel/process.c:332
>  default_idle_call+0x36/0x60 kernel/sched/idle.c:98
>  cpuidle_idle_call kernel/sched/idle.c:156 [inline]
>  do_idle+0x348/0x420 kernel/sched/idle.c:245
>  cpu_startup_entry+0x18/0x20 kernel/sched/idle.c:350
>  rest_init+0x18d/0x1a0 init/main.c:415
>  start_kernel+0x747/0x779 init/main.c:679
>  x86_64_start_reservations+0x2a/0x2c arch/x86/kernel/head64.c:196
>  x86_64_start_kernel+0x132/0x141 arch/x86/kernel/head64.c:177
>  secondary_startup_64+0x9f/0x9f arch/x86/kernel/head_64.S:304
>
> Allocated by task 30543:
>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
>  save_stack+0x43/0xd0 mm/kasan/kasan.c:513
>  set_track mm/kasan/kasan.c:525 [inline]
>  kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:617
>  kmem_cache_alloc_trace+0x82/0x270 mm/slub.c:2745
>  kmalloc include/linux/slab.h:492 [inline]
>  kzalloc include/linux/slab.h:665 [inline]
>  ip_mc_add1_src net/ipv4/igmp.c:1909 [inline]
>  ip_mc_add_src+0x6cd/0x1020 net/ipv4/igmp.c:2033
>  ip_mc_msfilter+0x5e5/0xcf0 net/ipv4/igmp.c:2403
>  do_ip_setsockopt.isra.12+0x2d47/0x38c0 net/ipv4/ip_sockglue.c:959
>  ip_setsockopt+0x3a/0xb0 net/ipv4/ip_sockglue.c:1256
>  tcp_setsockopt+0x82/0xd0 net/ipv4/tcp.c:2740
>  sock_common_setsockopt+0x95/0xd0 net/core/sock.c:2844
>  SYSC_setsockopt net/socket.c:1798 [inline]
>  SyS_setsockopt+0x270/0x3a0 net/socket.c:1777
>  entry_SYSCALL_64_fastpath+0x1f/0xbe
>
> Freed by task 30543:
>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
>  save_stack+0x43/0xd0 mm/kasan/kasan.c:513
>  set_track mm/kasan/kasan.c:525 [inline]
>  kasan_slab_free+0x72/0xc0 mm/kasan/kasan.c:590
>  slab_free_hook mm/slub.c:1357 [inline]
>  slab_free_freelist_hook mm/slub.c:1379 [inline]
>  slab_free mm/slub.c:2961 [inline]
>  kfree+0xe8/0x2b0 mm/slub.c:3882
>  ip_mc_clear_src+0x69/0x1c0 net/ipv4/igmp.c:2078
>  ip_mc_dec_group+0x19a/0x470 net/ipv4/igmp.c:1618
>  ip_mc_drop_socket+0x145/0x230 net/ipv4/igmp.c:2609
>  inet_release+0x4e/0x1c0 net/ipv4/af_inet.c:411
>  sock_release+0x8d/0x1e0 net/socket.c:597
>  sock_close+0x16/0x20 net/socket.c:1072
>  __fput+0x332/0x7f0 fs/file_table.c:209
>  ____fput+0x15/0x20 fs/file_table.c:245
>  task_work_run+0x19b/0x270 kernel/task_work.c:116
>  exit_task_work include/linux/task_work.h:21 [inline]
>  do_exit+0x18a3/0x2820 kernel/exit.c:878
>  do_group_exit+0x149/0x420 kernel/exit.c:982
>  get_signal+0x76d/0x1790 kernel/signal.c:2318
>  do_signal+0xd2/0x2130 arch/x86/kernel/signal.c:808
>  exit_to_usermode_loop+0x17a/0x210 arch/x86/entry/common.c:157
>  prepare_exit_to_usermode arch/x86/entry/common.c:194 [inline]
>  syscall_return_slowpath+0x3ba/0x410 arch/x86/entry/common.c:263
>  entry_SYSCALL_64_fastpath+0xbc/0xbe
>
> The buggy address belongs to the object at ffff88003053c1a0
>  which belongs to the cache kmalloc-64 of size 64
> The buggy address is located 0 bytes inside of
>  64-byte region [ffff88003053c1a0, ffff88003053c1e0)
> The buggy address belongs to the page:
> page:ffffea0000c14f00 count:1 mapcount:0 mapping:          (null)
> index:0x0 compound_mapcount: 0
> flags: 0x100000000008100(slab|head)
> raw: 0100000000008100 0000000000000000 0000000000000000 0000000100140014
> raw: ffffea0000c2f520 ffffea0000e20aa0 ffff88003e80f740 0000000000000000
> page dumped because: kasan: bad access detected
>
> Memory state around the buggy address:
>  ffff88003053c080: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>  ffff88003053c100: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>>ffff88003053c180: fc fc fc fc fb fb fb fb fb fb fb fb fc fc fc fc
>                                ^
>  ffff88003053c200: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>  ffff88003053c280: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
> ==================================================================
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  net/ipv4/igmp.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
> index 44fd86de2823dd17de16276a8ec01b190e69b8b4..f172d251c5f2cda8fc8bedd65fa16cdfe33a4d40 100644
> --- a/net/ipv4/igmp.c
> +++ b/net/ipv4/igmp.c
> @@ -174,6 +174,7 @@ static int ip_mc_add_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
>  static void ip_ma_put(struct ip_mc_list *im)
>  {
>         if (atomic_dec_and_test(&im->refcnt)) {
> +               ip_mc_clear_src(im);
>                 in_dev_put(im->interface);
>                 kfree_rcu(im, rcu);
>         }
> @@ -1615,7 +1616,6 @@ void ip_mc_dec_group(struct in_device *in_dev, __be32 addr)
>                                 *ip = i->next_rcu;
>                                 in_dev->mc_count--;
>                                 igmp_group_dropped(i);
> -                               ip_mc_clear_src(i);
>
>                                 if (!in_dev->dead)
>                                         ip_rt_multicast_event(in_dev);
>
>
>
