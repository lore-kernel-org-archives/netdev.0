From: Baozeng Ding <sploving1@gmail.com>
Subject: BUG: KASAN: use-after-free in udp_lib_rehash
Date: Sun, 16 Oct 2016 21:54:22 +0800
Message-ID: <15f0a0f5-e5dc-c845-b890-ba531064189d@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:35080 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752389AbcJPNyd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 16 Oct 2016 09:54:33 -0400
Received: by mail-oi0-f66.google.com with SMTP id d132so10758624oib.2
        for <netdev@vger.kernel.org>; Sun, 16 Oct 2016 06:54:32 -0700 (PDT)
Received: from [192.168.1.101] ([119.80.189.206])
        by smtp.gmail.com with ESMTPSA id h24sm9357596otc.19.2016.10.16.06.54.27
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Oct 2016 06:54:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,
While running syzkaller fuzzer I have got the following use-after-free
bug in udp_lib_rehash. The kernel version is 4.8.0+ (on Oct 7 commit d1f5323370fceaed43a7ee38f4c7bfc7e70f28d0). Unfortunately I failed to find a reproducer for it.

BUG: KASAN: use-after-free in udp_lib_rehash+0x634/0x640 at addr ffff88002f3fe1e0
Write of size 8 by task syz-executor/11156
CPU: 3 PID: 11156 Comm: syz-executor Not tainted 4.8.0+ #39
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.8.2-0-g33fbe13 by qemu-project.org 04/01/2014
 ffff88001acb7b58 ffffffff829f835b ffff880034acd900 ffff88002f3fe1c0
 ffff88002f3fe8d0 ffffc90000230810 ffff88001acb7b80 ffffffff8174d3cc
 ffff88001acb7c10 ffff88002f3fe180 ffff880034acd900 ffff88001acb7c00
Call Trace:
 [<ffffffff829f835b>] dump_stack+0xb3/0x118 lib/dump_stack.c:15
 [<ffffffff8174d3cc>] kasan_object_err+0x1c/0x70 mm/kasan/report.c:156
 [<     inline     >] print_address_description mm/kasan/report.c:194
 [<ffffffff8174d666>] kasan_report_error+0x1f6/0x4d0 mm/kasan/report.c:283
 [<     inline     >] kasan_report mm/kasan/report.c:303
 [<ffffffff8174db7e>] __asan_report_store8_noabort+0x3e/0x40 mm/kasan/report.c:329
 [<     inline     >] hlist_add_head_rcu ./include/linux/rculist.h:487
 [<ffffffff85083384>] udp_lib_rehash+0x634/0x640 net/ipv4/udp.c:1429
 [<ffffffff8525d502>] udp_v6_rehash+0x72/0xa0 net/ipv6/udp.c:115
 [<ffffffff852a69d6>] ip6_datagram_connect+0x786/0xc40
 [<ffffffff850b3162>] inet_dgram_connect+0x112/0x1f0 net/ipv4/af_inet.c:530
 [<ffffffff84c4959e>] SYSC_connect+0x23e/0x2e0 net/socket.c:1533
 [<ffffffff84c4bd14>] SyS_connect+0x24/0x30 net/socket.c:1514
 [<ffffffff85e4d685>] entry_SYSCALL_64_fastpath+0x23/0xc6
Object at ffff88002f3fe1c0, in cache UDPv6 size: 1496
Allocated:
PID = 11149
 [ 1921.980207] [<ffffffff811ddcb6>] save_stack_trace+0x16/0x20
 [ 1921.980207] [<ffffffff8174c736>] save_stack+0x46/0xd0
 [ 1921.980207] [<ffffffff8174c9ad>] kasan_kmalloc+0xad/0xe0
 [ 1921.980207] [<ffffffff8174cee2>] kasan_slab_alloc+0x12/0x20
 [ 1921.980207] [<     inline     >] slab_post_alloc_hook mm/slab.h:417
 [ 1921.980207] [<     inline     >] slab_alloc_node mm/slub.c:2708
 [ 1921.980207] [<     inline     >] slab_alloc mm/slub.c:2716
 [ 1921.980207] [<ffffffff817476a8>] kmem_cache_alloc+0xc8/0x2b0 mm/slub.c:2721
 [ 1921.980207] [<ffffffff84c4f6a9>] sk_prot_alloc+0x69/0x2b0 net/core/sock.c:1326
 [ 1921.980207] [<ffffffff84c58ac8>] sk_alloc+0x38/0xae0 net/core/sock.c:1388
 [ 1921.980207] [<ffffffff851ddf67>] inet6_create+0x2d7/0x1000 net/ipv6/af_inet6.c:182
 [ 1921.980207] [<ffffffff84c4af7b>] __sock_create+0x37b/0x640 net/socket.c:1153
 [ 1921.980207] [<     inline     >] sock_create net/socket.c:1193
 [ 1921.980207] [<     inline     >] SYSC_socket net/socket.c:1223
 [ 1921.980207] [<ffffffff84c4b46f>] SyS_socket+0xef/0x1b0 net/socket.c:1203
 [ 1921.980207] [<ffffffff85e4d685>] entry_SYSCALL_64_fastpath+0x23/0xc6
Freed:
PID = 11157
 [ 1921.980207] [<ffffffff811ddcb6>] save_stack_trace+0x16/0x20
 [ 1921.980207] [<ffffffff8174c736>] save_stack+0x46/0xd0
 [ 1921.980207] [<ffffffff8174cf61>] kasan_slab_free+0x71/0xb0
 [ 1921.980207] [<     inline     >] slab_free_hook mm/slub.c:1352
 [ 1921.980207] [<     inline     >] slab_free_freelist_hook mm/slub.c:1374
 [ 1921.980207] [<     inline     >] slab_free mm/slub.c:2951
 [ 1921.980207] [<ffffffff81748b28>] kmem_cache_free+0xc8/0x330 mm/slub.c:2973
 [ 1921.980207] [<     inline     >] sk_prot_free net/core/sock.c:1369
 [ 1921.980207] [<ffffffff84c541eb>] __sk_destruct+0x32b/0x4f0 net/core/sock.c:1444
 [ 1921.980207] [<ffffffff84c5aca4>] sk_destruct+0x44/0x80 net/core/sock.c:1452
 [ 1921.980207] [<ffffffff84c5ad33>] __sk_free+0x53/0x220 net/core/sock.c:1460
 [ 1921.980207] [<ffffffff84c5af23>] sk_free+0x23/0x30 net/core/sock.c:1471
 [ 1921.980207] [<ffffffff84c5cb6c>] sk_common_release+0x28c/0x3e0 ./include/net/sock.h:1589
 [ 1921.980207] [<ffffffff852569e5>] udp_lib_close+0x15/0x20 ./include/net/udp.h:203
 [ 1921.980207] [<ffffffff850b2dfd>] inet_release+0xed/0x1c0 net/ipv4/af_inet.c:415
 [ 1921.980207] [<ffffffff851dc5a0>] inet6_release+0x50/0x70 net/ipv6/af_inet6.c:422
 [ 1921.980207] [<ffffffff84c4581d>] sock_release+0x8d/0x1d0 net/socket.c:570
 [ 1921.980207] [<ffffffff84c45976>] sock_close+0x16/0x20 net/socket.c:1017
 [ 1921.980207] [<ffffffff817a108c>] __fput+0x28c/0x780 fs/file_table.c:208
 [ 1921.980207] [<ffffffff817a1605>] ____fput+0x15/0x20 fs/file_table.c:244
 [ 1921.980207] [<ffffffff813774f9>] task_work_run+0xf9/0x170
 [ 1921.980207] [<ffffffff81324aae>] do_exit+0x85e/0x2a00
 [ 1921.980207] [<ffffffff81326dc8>] do_group_exit+0x108/0x330
 [ 1921.980207] [<ffffffff81348cf7>] get_signal+0x617/0x17a0 kernel/signal.c:2307
 [ 1921.980207] [<ffffffff811b49af>] do_signal+0x7f/0x18f0
 [ 1921.980207] [<ffffffff810039bf>] exit_to_usermode_loop+0xbf/0x150 arch/x86/entry/common.c:156
 [ 1921.980207] [<     inline     >] prepare_exit_to_usermode arch/x86/entry/common.c:190
 [ 1921.980207] [<ffffffff81006060>] syscall_return_slowpath+0x1a0/0x1e0 arch/x86/entry/common.c:259
 [ 1921.980207] [<ffffffff85e4d726>] entry_SYSCALL_64_fastpath+0xc4/0xc6
Memory state around the buggy address:
 ffff88002f3fe080: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
 ffff88002f3fe100: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>ffff88002f3fe180: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
                                                       ^
 ffff88002f3fe200: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff88002f3fe280: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb

Thansk && Best Regards,
Baozeng Ding
