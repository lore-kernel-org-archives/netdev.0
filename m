From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: BUG: KASAN: use-after-free in udp_lib_get_port
Date: Sun, 16 Oct 2016 12:53:24 -0700
Message-ID: <CAM_iQpVExpqdOXZp0Lw+4Nr2_9W24P2dQFdM=EoYwBkHtwDoPw@mail.gmail.com>
References: <31cb3583-5620-de3f-784d-300df3fda0a4@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>
To: Baozeng Ding <sploving1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:33079 "EHLO
        mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757006AbcJPTxq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 16 Oct 2016 15:53:46 -0400
Received: by mail-io0-f182.google.com with SMTP id q192so169612064iod.0
        for <netdev@vger.kernel.org>; Sun, 16 Oct 2016 12:53:45 -0700 (PDT)
In-Reply-To: <31cb3583-5620-de3f-784d-300df3fda0a4@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 16, 2016 at 6:46 AM, Baozeng Ding <sploving1@gmail.com> wrote:
> Hello all,
> While running syzkaller fuzzer I have got the following use-after-free
> bug in udp_lib_get_port. The kernel version is 4.8.0+ (on Oct 7 commit d1f5323370fceaed43a7ee38f4c7bfc7e70f28d0). Unfortunately I failed to find a reproducer for it.
>
> BUG: KASAN: use-after-free in udp_lib_get_port+0x1573/0x1860 at addr ffff88000804cb60
> Write of size 8 by task syz-executor/31190
> CPU: 0 PID: 31190 Comm: syz-executor Not tainted 4.8.0+ #39
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.8.2-0-g33fbe13 by qemu-project.org 04/01/2014
>  ffff880015ac7a48 ffffffff829f835b ffff880032b531c0 ffff88000804cb40
>  ffff88000804d250 ffff880017415a4a ffff880015ac7a70 ffffffff8174d3cc
>  ffff880015ac7b00 ffff88000804cb00 ffff880032b531c0 ffff880015ac7af0
> Call Trace:
>  [<ffffffff829f835b>] dump_stack+0xb3/0x118 lib/dump_stack.c:15
>  [<ffffffff8174d3cc>] kasan_object_err+0x1c/0x70 mm/kasan/report.c:156
>  [<     inline     >] print_address_description mm/kasan/report.c:194
>  [<ffffffff8174d666>] kasan_report_error+0x1f6/0x4d0 mm/kasan/report.c:283
>  [<     inline     >] kasan_report mm/kasan/report.c:303
>  [<ffffffff8174db7e>] __asan_report_store8_noabort+0x3e/0x40 mm/kasan/report.c:329
>  [<     inline     >] hlist_add_head_rcu ./include/linux/rculist.h:487
>  [<ffffffff850866e3>] udp_lib_get_port+0x1573/0x1860 net/ipv4/udp.c:345
>  [<ffffffff8525cc27>] udp_v6_get_port+0xa7/0xd0 net/ipv6/udp.c:106
>  [<ffffffff851df52c>] inet6_bind+0x89c/0xfb0 net/ipv6/af_inet6.c:384
>  [<ffffffff84c492fa>] SYSC_bind+0x1ea/0x250 net/socket.c:1367
>  [<ffffffff84c4ba34>] SyS_bind+0x24/0x30 net/socket.c:1353
>  [<ffffffff85e4d685>] entry_SYSCALL_64_fastpath+0x23/0xc6


We should have a reference to this sock via fd and its sock->sk too,
so I fail to see why it could be freed while we holding this reference.
Maybe a VFS layer bug?

> Object at ffff88000804cb40, in cache UDPv6 size: 1496
> Allocated:
> PID = 30789
>  [  378.305168] [<ffffffff811ddcb6>] save_stack_trace+0x16/0x20
>  [  378.305168] [<ffffffff8174c736>] save_stack+0x46/0xd0
>  [  378.305168] [<ffffffff8174c9ad>] kasan_kmalloc+0xad/0xe0
>  [  378.305168] [<ffffffff8174cee2>] kasan_slab_alloc+0x12/0x20
>  [  378.305168] [<     inline     >] slab_post_alloc_hook mm/slab.h:417
>  [  378.305168] [<     inline     >] slab_alloc_node mm/slub.c:2708
>  [  378.305168] [<     inline     >] slab_alloc mm/slub.c:2716
>  [  378.305168] [<ffffffff817476a8>] kmem_cache_alloc+0xc8/0x2b0 mm/slub.c:2721
>  [  378.305168] [<ffffffff84c4f6a9>] sk_prot_alloc+0x69/0x2b0 net/core/sock.c:1326
>  [  378.305168] [<ffffffff84c58ac8>] sk_alloc+0x38/0xae0 net/core/sock.c:1388
>  [  378.305168] [<ffffffff851ddf67>] inet6_create+0x2d7/0x1000 net/ipv6/af_inet6.c:182
>  [  378.305168] [<ffffffff84c4af7b>] __sock_create+0x37b/0x640 net/socket.c:1153
>  [  378.305168] [<     inline     >] sock_create net/socket.c:1193
>  [  378.305168] [<     inline     >] SYSC_socket net/socket.c:1223
>  [  378.305168] [<ffffffff84c4b46f>] SyS_socket+0xef/0x1b0 net/socket.c:1203
>  [  378.305168] [<ffffffff85e4d685>] entry_SYSCALL_64_fastpath+0x23/0xc6
> Freed:
> PID = 30789
>  [  378.305168] [<ffffffff811ddcb6>] save_stack_trace+0x16/0x20
>  [  378.305168] [<ffffffff8174c736>] save_stack+0x46/0xd0
>  [  378.305168] [<ffffffff8174cf61>] kasan_slab_free+0x71/0xb0
>  [  378.305168] [<     inline     >] slab_free_hook mm/slub.c:1352
>  [  378.305168] [<     inline     >] slab_free_freelist_hook mm/slub.c:1374
>  [  378.305168] [<     inline     >] slab_free mm/slub.c:2951
>  [  378.305168] [<ffffffff81748b28>] kmem_cache_free+0xc8/0x330 mm/slub.c:2973
>  [  378.305168] [<     inline     >] sk_prot_free net/core/sock.c:1369
>  [  378.305168] [<ffffffff84c541eb>] __sk_destruct+0x32b/0x4f0 net/core/sock.c:1444
>  [  378.305168] [<ffffffff84c5aca4>] sk_destruct+0x44/0x80 net/core/sock.c:1452
>  [  378.305168] [<ffffffff84c5ad33>] __sk_free+0x53/0x220 net/core/sock.c:1460
>  [  378.305168] [<ffffffff84c5af23>] sk_free+0x23/0x30 net/core/sock.c:1471
>  [  378.305168] [<ffffffff84c5cb6c>] sk_common_release+0x28c/0x3e0 ./include/net/sock.h:1589
>  [  378.305168] [<ffffffff852569e5>] udp_lib_close+0x15/0x20 ./include/net/udp.h:203
>  [  378.305168] [<ffffffff850b2dfd>] inet_release+0xed/0x1c0 net/ipv4/af_inet.c:415
>  [  378.305168] [<ffffffff851dc5a0>] inet6_release+0x50/0x70 net/ipv6/af_inet6.c:422
>  [  378.305168] [<ffffffff84c4581d>] sock_release+0x8d/0x1d0 net/socket.c:570
>  [  378.305168] [<ffffffff84c45976>] sock_close+0x16/0x20 net/socket.c:1017
>  [  378.305168] [<ffffffff817a108c>] __fput+0x28c/0x780 fs/file_table.c:208
>  [  378.305168] [<ffffffff817a1605>] ____fput+0x15/0x20 fs/file_table.c:244
>  [  378.305168] [<ffffffff813774f9>] task_work_run+0xf9/0x170
>  [  378.305168] [<ffffffff81324aae>] do_exit+0x85e/0x2a00
>  [  378.305168] [<ffffffff81326dc8>] do_group_exit+0x108/0x330
>  [  378.376437] [<ffffffff81348cf7>] get_signal+0x617/0x17a0 kernel/signal.c:2307
>  [  378.376437] [<ffffffff811b49af>] do_signal+0x7f/0x18f0
>  [  378.376437] [<ffffffff810039bf>] exit_to_usermode_loop+0xbf/0x150 arch/x86/entry/common.c:156
>  [  378.376437] [<     inline     >] prepare_exit_to_usermode arch/x86/entry/common.c:190
>  [  378.376437] [<ffffffff81006060>] syscall_return_slowpath+0x1a0/0x1e0 arch/x86/entry/common.c:259
>  [  378.376437] [<ffffffff85e4d726>] entry_SYSCALL_64_fastpath+0xc4/0xc6
> Memory state around the buggy address:
>  ffff88000804ca00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>  ffff88000804ca80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>>ffff88000804cb00: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
>                                                        ^
>  ffff88000804cb80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>  ffff88000804cc00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> ==================================================================
>
> Thanks && Best Regards,
> Baozeng Ding
