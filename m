From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: KASAN: use-after-free Read in tipc_group_self
Date: Tue, 24 Oct 2017 13:30:44 -0700
Message-ID: <CAM_iQpWfc8UC2otEdGeqc9JvAp9FqNyhz-OLmORWNEJJ-hbrmA@mail.gmail.com>
References: <001a113f327c9352cd055c4c63c8@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>, jon.maloy@ericsson.com,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        syzkaller-bugs@googlegroups.com,
        tipc-discussion@lists.sourceforge.net, ying.xue@windriver.com
To: syzbot
        <bot+dbf0bb71d5568dfcd9d9cfddad8414c0d4f294c3@syzkaller.appspotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:45735 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751608AbdJXUbF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 16:31:05 -0400
In-Reply-To: <001a113f327c9352cd055c4c63c8@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 24, 2017 at 8:14 AM, syzbot
<bot+dbf0bb71d5568dfcd9d9cfddad8414c0d4f294c3@syzkaller.appspotmail.com>
wrote:
> Hello,
>
> syzkaller hit the following crash on
> 65302eba00aea2f1bc715f0438afb63470ac138b
> git://git.cmpxchg.org/linux-mmots.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
> C reproducer is attached
> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
> for information about syzkaller reproducers
>
>
> BUG: KASAN: use-after-free in tipc_group_self+0x1a2/0x1b0
> net/tipc/group.c:335
> Read of size 4 at addr ffff8801d805726c by task syzkaller195348/2990
>
> CPU: 0 PID: 2990 Comm: syzkaller195348 Not tainted 4.14.0-rc5-mm1+ #19
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:16 [inline]
>  dump_stack+0x194/0x257 lib/dump_stack.c:52
>  print_address_description+0x73/0x250 mm/kasan/report.c:252
>  kasan_report_error mm/kasan/report.c:351 [inline]
>  kasan_report+0x25b/0x340 mm/kasan/report.c:409
>  __asan_report_load4_noabort+0x14/0x20 mm/kasan/report.c:429
>  tipc_group_self+0x1a2/0x1b0 net/tipc/group.c:335
>  tipc_sk_leave+0xfc/0x200 net/tipc/socket.c:2781
>  tipc_release+0x154/0xfe0 net/tipc/socket.c:575
>  sock_release+0x8d/0x1e0 net/socket.c:596
>  sock_close+0x16/0x20 net/socket.c:1125
>  __fput+0x327/0x7e0 fs/file_table.c:210
>  ____fput+0x15/0x20 fs/file_table.c:244
>  task_work_run+0x199/0x270 kernel/task_work.c:112
>  exit_task_work include/linux/task_work.h:21 [inline]
>  do_exit+0x9b5/0x1ad0 kernel/exit.c:869
>  do_group_exit+0x149/0x400 kernel/exit.c:972
>  SYSC_exit_group kernel/exit.c:983 [inline]
>  SyS_exit_group+0x1d/0x20 kernel/exit.c:981
>  entry_SYSCALL_64_fastpath+0x1f/0xbe
> RIP: 0033:0x43e978
> RSP: 002b:00007ffcae951f88 EFLAGS: 00000246 ORIG_RAX: 00000000000000e7
> RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 000000000043e978
> RDX: 0000000000000000 RSI: 000000000000003c RDI: 0000000000000000
> RBP: 0000000000000082 R08: 00000000000000e7 R09: ffffffffffffffd0
> R10: 000000002010e000 R11: 0000000000000246 R12: 00000000006ca858
> R13: 00000000006ca858 R14: 0000000000000000 R15: 0000000000002710
>
> Allocated by task 2990:
>  save_stack+0x43/0xd0 mm/kasan/kasan.c:447
>  set_track mm/kasan/kasan.c:459 [inline]
>  kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:551
>  kmem_cache_alloc_trace+0x136/0x750 mm/slab.c:3614
>  kmalloc include/linux/slab.h:499 [inline]
>  kzalloc include/linux/slab.h:688 [inline]
>  tipc_group_create+0x116/0x9c0 net/tipc/group.c:167
>  tipc_sk_join net/tipc/socket.c:2751 [inline]
>  tipc_setsockopt+0x25e/0xc00 net/tipc/socket.c:2863
>  SYSC_setsockopt net/socket.c:1851 [inline]
>  SyS_setsockopt+0x189/0x360 net/socket.c:1830
>  entry_SYSCALL_64_fastpath+0x1f/0xbe
>
> Freed by task 2990:
>  save_stack+0x43/0xd0 mm/kasan/kasan.c:447
>  set_track mm/kasan/kasan.c:459 [inline]
>  kasan_slab_free+0x71/0xc0 mm/kasan/kasan.c:524
>  __cache_free mm/slab.c:3492 [inline]
>  kfree+0xca/0x250 mm/slab.c:3807
>  tipc_group_delete+0x2c0/0x3c0 net/tipc/group.c:206
>  tipc_sk_join net/tipc/socket.c:2764 [inline]
>  tipc_setsockopt+0xb33/0xc00 net/tipc/socket.c:2863
>  SYSC_setsockopt net/socket.c:1851 [inline]
>  SyS_setsockopt+0x189/0x360 net/socket.c:1830
>  entry_SYSCALL_64_fastpath+0x1f/0xbe

Should be fixed by:

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index b3b72d8e9543..ea61c32f6b80 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -2756,8 +2756,10 @@ static int tipc_sk_join(struct tipc_sock *tsk,
struct tipc_group_req *mreq)
        seq.upper = seq.lower;
        tipc_nametbl_build_group(net, grp, mreq->type, domain);
        rc = tipc_sk_publish(tsk, mreq->scope, &seq);
-       if (rc)
+       if (rc) {
                tipc_group_delete(net, grp);
+               tsk->group = NULL;
+       }

        /* Eliminate any risk that a broadcast overtakes the sent JOIN */
        tsk->mc_method.rcast = true;
