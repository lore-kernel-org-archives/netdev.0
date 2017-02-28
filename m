From: Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: net/rds: use-after-free in inet_create
Date: Tue, 28 Feb 2017 17:51:02 +0100
Message-ID: <CACT4Y+Y5eM8hKQ7BgA4hEN7ozkhRGgvGJRU6Smrths6noC-PMw@mail.gmail.com>
References: <CACT4Y+bi=rZr9yrajA0o0iUeR4N0q-sXYudBVsOeOiHbuApBeA@mail.gmail.com>
 <20170228153737.GG31155@oracle.com> <CACT4Y+aobp+g_AYoX6j1eftyyirK4pBxhOXz9hDu+XU+-jxSYw@mail.gmail.com>
 <20170228161544.GH31155@oracle.com> <CACT4Y+bWWAiMYQN_Fvxs7CKR9hRAA+r0t_YZhja3B5xGcZ4vcQ@mail.gmail.com>
 <20170228163833.GI31155@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        syzkaller <syzkaller-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
To: Sowmini Varadhan <sowmini.varadhan-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170228163833.GI31155-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 28, 2017 at 5:38 PM, Sowmini Varadhan
<sowmini.varadhan-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org> wrote:
> On (02/28/17 17:32), Dmitry Vyukov wrote:
>> Not reproducible so far.
>>
>> rds is compiled into kernel (no modules):
>> CONFIG_RDS=y
>> CONFIG_RDS_TCP=y
>
> I see. So if it never gets unloaded, the rds_connections "should"
> be around forever.. let me inspect code and see if I spot some
> race-window..
>
>> Also fuzzer actively creates and destroys namespaces.
>> Yes, I don't see socket(0x15) in the log. Probably it was truncated.
>
> I see. May be useful if we coudl get a crash dump to see what
> other threads were going on (might give a hint about which threads
> were racing). I'll try reproducing this at my end too.


Searching other crashes for "net/rds" I found 2 more crashes that may
be related. They suggest that the delayed works are not properly
stopped when the socket is destroyed. That would explain how
rds_connect_worker accesses freed net, right?


BUG: KASAN: use-after-free in memcmp+0xe3/0x160 lib/string.c:768 at
addr ffff88018d49cb20
Read of size 1 by task kworker/u4:4/3546
CPU: 1 PID: 3546 Comm: kworker/u4:4 Not tainted 4.9.0 #7
Hardware name: Google Google Compute Engine/Google Compute Engine,
BIOS Google 01/01/2011
Workqueue: krdsd rds_send_worker
 ffff8801ccd46628 ffffffff8234ce1f ffffffff00000001 1ffff100399a8c58
 ffffed00399a8c50 0000000041b58ab3 ffffffff84b38258 ffffffff8234cb31
 0000000000000000 00000000000010bf 000000008156afb0 ffffffff858c8e58
Call Trace:
 [<ffffffff8234ce1f>] __dump_stack lib/dump_stack.c:15 [inline]
 [<ffffffff8234ce1f>] dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
 [<ffffffff819e242c>] kasan_object_err+0x1c/0x70 mm/kasan/report.c:162
 [<ffffffff819e26c5>] print_address_description mm/kasan/report.c:200 [inline]
 [<ffffffff819e26c5>] kasan_report_error mm/kasan/report.c:289 [inline]
 [<ffffffff819e26c5>] kasan_report.part.2+0x1e5/0x4b0 mm/kasan/report.c:311
 [<ffffffff819e29b9>] kasan_report mm/kasan/report.c:329 [inline]
 [<ffffffff819e29b9>] __asan_report_load1_noabort+0x29/0x30
mm/kasan/report.c:329
 [<ffffffff82377e13>] memcmp+0xe3/0x160 lib/string.c:768
 [<ffffffff83e8febe>] rhashtable_compare include/linux/rhashtable.h:556 [inline]
 [<ffffffff83e8febe>] __rhashtable_lookup
include/linux/rhashtable.h:578 [inline]
 [<ffffffff83e8febe>] rhashtable_lookup include/linux/rhashtable.h:610 [inline]
 [<ffffffff83e8febe>] rhashtable_lookup_fast
include/linux/rhashtable.h:636 [inline]
 [<ffffffff83e8febe>] rds_find_bound+0x4fe/0x8a0 net/rds/bind.c:63
 [<ffffffff83e9d03c>] rds_recv_incoming+0x5fc/0x1300 net/rds/recv.c:313
 [<ffffffff83eac385>] rds_loop_xmit+0x1c5/0x480 net/rds/loop.c:82
 [<ffffffff83ea468a>] rds_send_xmit+0x104a/0x2420 net/rds/send.c:348
 [<ffffffff83eab602>] rds_send_worker+0x122/0x2a0 net/rds/threads.c:189
 [<ffffffff81492c00>] process_one_work+0xbd0/0x1c10 kernel/workqueue.c:2096
 [<ffffffff81493e63>] worker_thread+0x223/0x1990 kernel/workqueue.c:2230
 [<ffffffff814abd53>] kthread+0x323/0x3e0 kernel/kthread.c:209
 [<ffffffff84377b2a>] ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:433
Object at ffff88018d49c6c0, in cache RDS size: 1464
Allocated:
PID = 5431
 [   40.943107] [<ffffffff8129c696>] save_stack_trace+0x16/0x20
arch/x86/kernel/stacktrace.c:57
 [   40.950346] [<ffffffff819e16c3>] save_stack+0x43/0xd0 mm/kasan/kasan.c:495
 [   40.957064] [<ffffffff819e194a>] set_track mm/kasan/kasan.c:507 [inline]
 [   40.957064] [<ffffffff819e194a>] kasan_kmalloc+0xaa/0xd0
mm/kasan/kasan.c:598
 [   40.964040] [<ffffffff819e1f42>] kasan_slab_alloc+0x12/0x20
mm/kasan/kasan.c:537
 [   40.971282] [<ffffffff819dd592>] kmem_cache_alloc+0x102/0x680 mm/slab.c:3573
 [   40.978696] [<ffffffff835017e5>] sk_prot_alloc+0x65/0x2a0
net/core/sock.c:1327
 [   40.985766] [<ffffffff8350a20c>] sk_alloc+0x8c/0x460 net/core/sock.c:1389
 [   40.992398] [<ffffffff83e8c90c>] rds_create+0x11c/0x5e0 net/rds/af_rds.c:504
 [   40.999296] [<ffffffff834f9f24>] __sock_create+0x4e4/0x870 net/socket.c:1168
 [   41.006446] [<ffffffff834fa4e9>] sock_create net/socket.c:1208 [inline]
 [   41.006446] [<ffffffff834fa4e9>] SYSC_socket net/socket.c:1238 [inline]
 [   41.006446] [<ffffffff834fa4e9>] SyS_socket+0xf9/0x230 net/socket.c:1218
 [   41.013251] [<ffffffff843778c1>] entry_SYSCALL_64_fastpath+0x1f/0xc2
Freed:
PID = 5431
 [   41.025881] [<ffffffff8129c696>] save_stack_trace+0x16/0x20
arch/x86/kernel/stacktrace.c:57
 [   41.033124] [<ffffffff819e16c3>] save_stack+0x43/0xd0 mm/kasan/kasan.c:495
 [   41.039840] [<ffffffff819e1fbf>] set_track mm/kasan/kasan.c:507 [inline]
 [   41.039840] [<ffffffff819e1fbf>] kasan_slab_free+0x6f/0xb0
mm/kasan/kasan.c:571
 [   41.046992] [<ffffffff819df361>] __cache_free mm/slab.c:3515 [inline]
 [   41.046992] [<ffffffff819df361>] kmem_cache_free+0x71/0x240 mm/slab.c:3775
 [   41.054232] [<ffffffff835054ed>] sk_prot_free net/core/sock.c:1370 [inline]
 [   41.054232] [<ffffffff835054ed>] __sk_destruct+0x47d/0x6a0
net/core/sock.c:1445
 [   41.061383] [<ffffffff8350fa77>] sk_destruct+0x47/0x80 net/core/sock.c:1453
 [   41.068199] [<ffffffff8350fb07>] __sk_free+0x57/0x230 net/core/sock.c:1461
 [   41.074921] [<ffffffff8350fd03>] sk_free+0x23/0x30 net/core/sock.c:1472
 [   41.081398] [<ffffffff83e8c488>] sock_put include/net/sock.h:1591 [inline]
 [   41.081398] [<ffffffff83e8c488>] rds_release+0x358/0x500 net/rds/af_rds.c:89
 [   41.088376] [<ffffffff834f258d>] sock_release+0x8d/0x1e0 net/socket.c:585
 [   41.095358] [<ffffffff834f26f6>] sock_close+0x16/0x20 net/socket.c:1032
 [   41.102083] [<ffffffff81a34772>] __fput+0x332/0x7f0 fs/file_table.c:208
 [   41.108628] [<ffffffff81a34cb5>] ____fput+0x15/0x20 fs/file_table.c:244
 [   41.115184] [<ffffffff814a58ca>] task_work_run+0x18a/0x260
kernel/task_work.c:116
 [   41.122337] [<ffffffff8100793b>] tracehook_notify_resume
include/linux/tracehook.h:191 [inline]
 [   41.122337] [<ffffffff8100793b>] exit_to_usermode_loop+0x23b/0x2a0
arch/x86/entry/common.c:160
 [   41.130193] [<ffffffff81009413>] prepare_exit_to_usermode
arch/x86/entry/common.c:190 [inline]
 [   41.130193] [<ffffffff81009413>]
syscall_return_slowpath+0x4d3/0x570 arch/x86/entry/common.c:259
 [   41.138220] [<ffffffff84377962>] entry_SYSCALL_64_fastpath+0xc0/0xc2
Memory state around the buggy address:
 ffff88018d49ca00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff88018d49ca80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>ffff88018d49cb00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                               ^
 ffff88018d49cb80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff88018d49cc00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fc
==================================================================


BUG: KASAN: use-after-free in memcmp+0xe3/0x160 lib/string.c:768 at
addr ffff88006a2b84b0
Read of size 1 by task kworker/u8:0/5
CPU: 0 PID: 5 Comm: kworker/u8:0 Not tainted 4.10.0-rc8+ #5
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Workqueue: krdsd rds_send_worker
Call Trace:
 __dump_stack lib/dump_stack.c:15 [inline]
 dump_stack+0x292/0x398 lib/dump_stack.c:51
 kasan_object_err+0x1c/0x70 mm/kasan/report.c:162
 print_address_description mm/kasan/report.c:200 [inline]
 kasan_report_error mm/kasan/report.c:289 [inline]
 kasan_report.part.1+0x20e/0x4e0 mm/kasan/report.c:311
 kasan_report mm/kasan/report.c:329 [inline]
 __asan_report_load1_noabort+0x29/0x30 mm/kasan/report.c:329
 memcmp+0xe3/0x160 lib/string.c:768
 rhashtable_compare include/linux/rhashtable.h:556 [inline]
 __rhashtable_lookup include/linux/rhashtable.h:578 [inline]
 rhashtable_lookup include/linux/rhashtable.h:610 [inline]
 rhashtable_lookup_fast include/linux/rhashtable.h:636 [inline]
 rds_find_bound+0x4fe/0x8a0 net/rds/bind.c:63
 rds_recv_incoming+0x5f3/0x12c0 net/rds/recv.c:349
 rds_loop_xmit+0x1c5/0x490 net/rds/loop.c:82
 rds_send_xmit+0x1170/0x24a0 net/rds/send.c:349
 rds_send_worker+0x12b/0x2b0 net/rds/threads.c:188
 process_one_work+0xc06/0x1c20 kernel/workqueue.c:2098
 worker_thread+0x223/0x19c0 kernel/workqueue.c:2232
hrtimer: interrupt took 2979772 ns
 kthread+0x326/0x3f0 kernel/kthread.c:227
 ret_from_fork+0x31/0x40 arch/x86/entry/entry_64.S:430
Object at ffff88006a2b8040, in cache RDS size: 1480
Allocated:
PID = 5235
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
 save_stack+0x43/0xd0 mm/kasan/kasan.c:502
 set_track mm/kasan/kasan.c:514 [inline]
 kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:605
 kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:544
 slab_post_alloc_hook mm/slab.h:432 [inline]
 slab_alloc_node mm/slub.c:2715 [inline]
 slab_alloc mm/slub.c:2723 [inline]
 kmem_cache_alloc+0x1af/0x250 mm/slub.c:2728
 sk_prot_alloc+0x65/0x2a0 net/core/sock.c:1334
 sk_alloc+0x105/0x1010 net/core/sock.c:1396
 rds_create+0x11c/0x600 net/rds/af_rds.c:504
 __sock_create+0x4f6/0x880 net/socket.c:1199
 sock_create net/socket.c:1239 [inline]
 SYSC_socket net/socket.c:1269 [inline]
 SyS_socket+0xf9/0x230 net/socket.c:1249
 entry_SYSCALL_64_fastpath+0x1f/0xc2
Freed:
PID = 5235
 save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
 save_stack+0x43/0xd0 mm/kasan/kasan.c:502
 set_track mm/kasan/kasan.c:514 [inline]
 kasan_slab_free+0x73/0xc0 mm/kasan/kasan.c:578
 slab_free_hook mm/slub.c:1355 [inline]
 slab_free_freelist_hook mm/slub.c:1377 [inline]
 slab_free mm/slub.c:2958 [inline]
 kmem_cache_free+0xb2/0x2c0 mm/slub.c:2980
 sk_prot_free net/core/sock.c:1377 [inline]
 __sk_destruct+0x49c/0x6e0 net/core/sock.c:1452
 sk_destruct+0x47/0x80 net/core/sock.c:1460
 __sk_free+0x57/0x230 net/core/sock.c:1468
 sk_free+0x23/0x30 net/core/sock.c:1479
 sock_put include/net/sock.h:1638 [inline]
 rds_release+0x3a1/0x4d0 net/rds/af_rds.c:89
 sock_release+0x8d/0x1e0 net/socket.c:599
 sock_close+0x16/0x20 net/socket.c:1063
 __fput+0x332/0x7f0 fs/file_table.c:208
 ____fput+0x15/0x20 fs/file_table.c:244
 task_work_run+0x19b/0x270 kernel/task_work.c:116
 tracehook_notify_resume include/linux/tracehook.h:191 [inline]
 exit_to_usermode_loop+0x1c2/0x200 arch/x86/entry/common.c:160
 prepare_exit_to_usermode arch/x86/entry/common.c:190 [inline]
 syscall_return_slowpath+0x3d3/0x420 arch/x86/entry/common.c:259
 entry_SYSCALL_64_fastpath+0xc0/0xc2
Memory state around the buggy address:
 ffff88006a2b8380: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff88006a2b8400: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>ffff88006a2b8480: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                                     ^
 ffff88006a2b8500: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff88006a2b8580: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
