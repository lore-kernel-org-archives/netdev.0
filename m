From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net: use-after-free in worker_thread
Date: Sat, 3 Dec 2016 13:58:08 +0100
Message-ID: <CAAeHK+zDnDugPcdEGBnC6rt5iJMffz+tmmDkF=vv6u0YF=EMwg@mail.gmail.com>
References: <CAAeHK+x95-n__YSbzebp51ez78yjqjK4CJL=tgOgPuBuGh+q1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kostya Serebryany <kcc@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Johannes Berg <johannes.berg@intel.com>,
        Florian Westphal <fw@strlen.de>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Eric Dumazet <edumazet@google.com>,
        Bob Copeland <me@bobcopeland.com>,
        Tom Herbert <tom@herbertland.com>,
        David Decotigny <decot@googlers.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:35716 "EHLO
        mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751907AbcLCNGB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 08:06:01 -0500
Received: by mail-lf0-f41.google.com with SMTP id b14so213041230lfg.2
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2016 05:06:00 -0800 (PST)
In-Reply-To: <CAAeHK+x95-n__YSbzebp51ez78yjqjK4CJL=tgOgPuBuGh+q1A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+syzkaller@googlegroups.com

On Sat, Dec 3, 2016 at 1:56 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> Hi!
>
> I'm seeing lots of the following error reports while running the
> syzkaller fuzzer.
>
> Reports appeared when I updated to 3c49de52 (Dec 2) from 2caceb32 (Dec 1).
>
> ==================================================================
> BUG: KASAN: use-after-free in worker_thread+0x17d8/0x18a0
> Read of size 8 at addr ffff880067f3ecd8 by task kworker/3:1/774
>
> page:ffffea00019fce00 count:1 mapcount:0 mapping:          (null)
> index:0xffff880067f39c10 compound_mapcount: 0
> flags: 0x500000000004080(slab|head)
> page dumped because: kasan: bad access detected
>
> CPU: 3 PID: 774 Comm: kworker/3:1 Not tainted 4.9.0-rc7+ #66
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>  ffff88006c267838 ffffffff81f882da ffffffff6c25e338 1ffff1000d84ce9a
>  ffffed000d84ce92 ffff88006c25e340 0000000041b58ab3 ffffffff8541e198
>  ffffffff81f88048 0000000100000000 0000000041b58ab3 ffffffff853d3ee8
> Call Trace:
>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>  [<ffffffff81f882da>] dump_stack+0x292/0x398 lib/dump_stack.c:51
>  [<     inline     >] describe_address mm/kasan/report.c:262
>  [<ffffffff817e50d1>] kasan_report_error+0x121/0x560 mm/kasan/report.c:368
>  [<     inline     >] kasan_report mm/kasan/report.c:390
>  [<ffffffff817e560e>] __asan_report_load8_noabort+0x3e/0x40
> mm/kasan/report.c:411
>  [<ffffffff81329b88>] worker_thread+0x17d8/0x18a0 kernel/workqueue.c:2228
>  [<ffffffff8133ebf3>] kthread+0x323/0x3e0 kernel/kthread.c:209
>  [<ffffffff84a2a22a>] ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:433
>
> The buggy address belongs to the object at ffff880067f3e6d0
>  which belongs to the cache kmalloc-2048 of size 2048
> The buggy address ffff880067f3ecd8 is located 1544 bytes inside
>  of 2048-byte region [ffff880067f3e6d0, ffff880067f3eed0)
>
> Freed by task 0:
>  [<ffffffff81203526>] save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
>  [<ffffffff817e4173>] save_stack+0x43/0xd0 mm/kasan/kasan.c:495
>  [<     inline     >] set_track mm/kasan/kasan.c:507
>  [<ffffffff817e4a53>] kasan_slab_free+0x73/0xc0 mm/kasan/kasan.c:571
>  [<     inline     >] slab_free_hook mm/slub.c:1352
>  [<     inline     >] slab_free_freelist_hook mm/slub.c:1374
>  [<     inline     >] slab_free mm/slub.c:2951
>  [<ffffffff817e0eb7>] kfree+0xe7/0x2b0 mm/slub.c:3871
>  [<     inline     >] sk_prot_free net/core/sock.c:1372
>  [<ffffffff831ea1c7>] __sk_destruct+0x5c7/0x6e0 net/core/sock.c:1445
>  [<ffffffff831f3517>] sk_destruct+0x47/0x80 net/core/sock.c:1453
>  [<ffffffff831f35a7>] __sk_free+0x57/0x230 net/core/sock.c:1461
>  [<ffffffff831f37a3>] sk_free+0x23/0x30 net/core/sock.c:1472
>  [<     inline     >] sock_put include/net/sock.h:1591
>  [<ffffffff8348ca9c>] deferred_put_nlk_sk+0x2c/0x40 net/netlink/af_netlink.c:671
>  [<     inline     >] __rcu_reclaim kernel/rcu/rcu.h:118
>  [<ffffffff8146d42f>] rcu_do_batch.isra.67+0x8ff/0xc50 kernel/rcu/tree.c:2776
>  [<     inline     >] invoke_rcu_callbacks kernel/rcu/tree.c:3040
>  [<     inline     >] __rcu_process_callbacks kernel/rcu/tree.c:3007
>  [<ffffffff8146e097>] rcu_process_callbacks+0x2b7/0xba0 kernel/rcu/tree.c:3024
>  [<ffffffff84a2d08b>] __do_softirq+0x2fb/0xb63 kernel/softirq.c:284
>
> Allocated by task 10748:
>  [<ffffffff81203526>] save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57
>  [<ffffffff817e4173>] save_stack+0x43/0xd0 mm/kasan/kasan.c:495
>  [<     inline     >] set_track mm/kasan/kasan.c:507
>  [<ffffffff817e43fd>] kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:598
>  [<ffffffff817e0050>] __kmalloc+0xa0/0x2d0 mm/slub.c:3734
>  [<     inline     >] kmalloc include/linux/slab.h:495
>  [<ffffffff831e4c01>] sk_prot_alloc+0x101/0x2a0 net/core/sock.c:1333
>  [<ffffffff831efd15>] sk_alloc+0x105/0x1000 net/core/sock.c:1389
>  [<ffffffff8348ad46>] __netlink_create+0x66/0x1d0 net/netlink/af_netlink.c:588
>  [<ffffffff8348cdab>] netlink_create+0x2fb/0x500 net/netlink/af_netlink.c:647
>  [<ffffffff831dd1d6>] __sock_create+0x4f6/0x880 net/socket.c:1168
>  [<     inline     >] sock_create net/socket.c:1208
>  [<     inline     >] SYSC_socket net/socket.c:1238
>  [<ffffffff831dd799>] SyS_socket+0xf9/0x230 net/socket.c:1218
>  [<ffffffff84a29fc1>] entry_SYSCALL_64_fastpath+0x1f/0xc2
>
> Memory state around the buggy address:
>  ffff880067f3eb80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>  ffff880067f3ec00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>ffff880067f3ec80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>                                                     ^
>  ffff880067f3ed00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>  ffff880067f3ed80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> ==================================================================
