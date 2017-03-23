From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net/kcm: use-after-free in kcm_wq
Date: Thu, 23 Mar 2017 13:59:06 +0100
Message-ID: <CACT4Y+atvz2c0PcDRSEp3YQiX+Jbv-XBfKCHn_tgPKBVkD7Yog@mail.gmail.com>
References: <CACT4Y+ZsaUAbTHdtP7BmZ+dsOTVA+f1jc8Mt=41H+8mwpkbRpA@mail.gmail.com>
 <CACT4Y+Zwk_82rKowdW3tLaZQC_q73swNoZ6mj5kvapHAGztaMQ@mail.gmail.com> <CAM_iQpW7CVYd1og=w=DG_m_cqVTb6VKzb6xfAoqVgtjrdp5aSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Tom Herbert <tom@herbertland.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Daniel Borkmann <daniel@iogearbox.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpW7CVYd1og=w=DG_m_cqVTb6VKzb6xfAoqVgtjrdp5aSA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 3, 2017 at 9:03 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Fri, Mar 3, 2017 at 2:11 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>> Also like this one:
>>
>> ==================================================================
>> BUG: KASAN: use-after-free in atomic_long_read
>> include/linux/compiler.h:254 [inline] at addr ffff8800538aba60
>> BUG: KASAN: use-after-free in get_work_pool+0x2f2/0x340
>> kernel/workqueue.c:709 at addr ffff8800538aba60
>> Read of size 8 by task syz-executor6/7965
>> CPU: 2 PID: 7965 Comm: syz-executor6 Not tainted 4.10.0+ #248
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>> Call Trace:
>>  __dump_stack lib/dump_stack.c:15 [inline]
>>  dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
>>  kasan_object_err+0x1c/0x70 mm/kasan/report.c:166
>>  print_address_description mm/kasan/report.c:204 [inline]
>>  kasan_report_error mm/kasan/report.c:288 [inline]
>>  kasan_report.part.2+0x198/0x440 mm/kasan/report.c:310
>>  kasan_report mm/kasan/report.c:331 [inline]
>>  __asan_report_load8_noabort+0x29/0x30 mm/kasan/report.c:331
>>  atomic_long_read include/linux/compiler.h:254 [inline]
>>  get_work_pool+0x2f2/0x340 kernel/workqueue.c:709
>>  __queue_work+0x2b3/0x1210 kernel/workqueue.c:1401
>>  queue_work_on+0x2e9/0x330 kernel/workqueue.c:1486
>>  queue_work include/linux/workqueue.h:487 [inline]
>>  strp_check_rcv+0x25/0x30 net/strparser/strparser.c:494
>
>
> It is not kcm_wq, it is strp_wq, and the work struct is strp->rx_work
> which lives in struct kcm_psock. The work is cancelled by strp_done(),
> it seems get queued again after strp_done()...


on 093b995e3b55a0ae0670226ddfcb05bfbf0099ae:

==================================================================
BUG: KASAN: use-after-free in worker_thread+0x1024/0x1340
kernel/workqueue.c:2229 at addr ffff88006d164ae0
Read of size 8 by task kworker/u8:3/25139
CPU: 2 PID: 25139 Comm: kworker/u8:3 Not tainted 4.11.0-rc3+ #364
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x1b8/0x28d lib/dump_stack.c:52
 kasan_object_err+0x1c/0x70 mm/kasan/report.c:166
 print_address_description mm/kasan/report.c:210 [inline]
 kasan_report_error mm/kasan/report.c:294 [inline]
 kasan_report.part.2+0x1be/0x480 mm/kasan/report.c:316
 kasan_report mm/kasan/report.c:337 [inline]
 __asan_report_load8_noabort+0x29/0x30 mm/kasan/report.c:337
 worker_thread+0x1024/0x1340 kernel/workqueue.c:2229
 kthread+0x359/0x420 kernel/kthread.c:229
 ret_from_fork+0x31/0x40 arch/x86/entry/entry_64.S:430
Object at ffff88006d1649c0, in cache kcm_psock_cache size: 616
Allocated:
PID = 25123
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:517
 set_track mm/kasan/kasan.c:529 [inline]
 kasan_kmalloc+0xbc/0xf0 mm/kasan/kasan.c:620
 kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:559
 kmem_cache_alloc+0x110/0x720 mm/slab.c:3572
 kmem_cache_zalloc include/linux/slab.h:653 [inline]
 kcm_attach net/kcm/kcmsock.c:1386 [inline]
 kcm_attach_ioctl net/kcm/kcmsock.c:1457 [inline]
 kcm_ioctl+0x2bc/0x17e0 net/kcm/kcmsock.c:1692
 sock_do_ioctl+0x65/0xb0 net/socket.c:895
 sock_ioctl+0x2c2/0x440 net/socket.c:993
 vfs_ioctl fs/ioctl.c:45 [inline]
 do_vfs_ioctl+0x1af/0x16d0 fs/ioctl.c:685
 SYSC_ioctl fs/ioctl.c:700 [inline]
 SyS_ioctl+0x8f/0xc0 fs/ioctl.c:691
 entry_SYSCALL_64_fastpath+0x1f/0xc2
Freed:
PID = 25139
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
 save_stack+0x43/0xd0 mm/kasan/kasan.c:517
 set_track mm/kasan/kasan.c:529 [inline]
 kasan_slab_free+0x81/0xc0 mm/kasan/kasan.c:593
 __cache_free mm/slab.c:3514 [inline]
 kmem_cache_free+0x71/0x240 mm/slab.c:3774
 unreserve_psock+0x5d4/0x7b0 net/kcm/kcmsock.c:547
 kcm_write_msgs+0xba6/0x1ba0 net/kcm/kcmsock.c:590
 kcm_tx_work+0x32/0x1f0 net/kcm/kcmsock.c:731
 process_one_work+0xb20/0x1b40 kernel/workqueue.c:2097
 worker_thread+0x1b4/0x1340 kernel/workqueue.c:2231
 kthread+0x359/0x420 kernel/kthread.c:229
 ret_from_fork+0x31/0x40 arch/x86/entry/entry_64.S:430
Memory state around the buggy address:
 ffff88006d164980: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
 ffff88006d164a00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>ffff88006d164a80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                                                       ^
 ffff88006d164b00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff88006d164b80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================
