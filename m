From: Richard <fuzzyer0@gmail.com>
Subject: BUG: net/core: use-after-free in fib_nl_dumprule
Date: Fri, 13 May 2016 23:59:27 +0800
Message-ID: <5735F9DF.90104@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, tgraf@suug.ch, wkok@cumulusnetworks.com,
	roopa@cumulusnetworks.com, phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35784 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751948AbcEMQAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 12:00:24 -0400
Received: by mail-pf0-f195.google.com with SMTP id b66so1666477pfb.2
        for <netdev@vger.kernel.org>; Fri, 13 May 2016 09:00:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
I've got the following report (use-after-free in  fib_nl_dumprule) while 
running syzkaller.
Unfortunately no reproducer.The kernel version is 4.6.0-rc2+.

==================================================================
BUG: KASAN: use-after-free in fib_nl_dumprule+0x43a/0x4b0 at addr 
ffff880036a6d9d0
Read of size 4 by task syz-executor/31203
=============================================================================
BUG kmalloc-1024 (Not tainted): kasan: bad access detected
-----------------------------------------------------------------------------

Disabling lock debugging due to kernel taint
INFO: Allocated in 0xbbbbbbbbbbbbbbbb age=18446610057847848626 cpu=0 pid=0
[<      none      >] __alloc_skb+0xf0/0x5f0 /net/core/skbuff.c:230
[<      none      >] ___slab_alloc+0x4c7/0x500 /mm/slub.c:2446
[<      none      >] __slab_alloc+0x4c/0x90 /mm/slub.c:2475
[<     inline     >] slab_alloc_node /mm/slub.c:2538
[<      none      >] __kmalloc_node_track_caller+0xba/0x420 /mm/slub.c:4095
[<      none      >] __kmalloc_reserve.isra.33+0x41/0xe0 
/net/core/skbuff.c:137
[<      none      >] __alloc_skb+0xf0/0x5f0 /net/core/skbuff.c:230
[<     inline     >] alloc_skb /include/linux/skbuff.h:895
[<     inline     >] netlink_alloc_large_skb /net/netlink/af_netlink.c:1086
[<      none      >] netlink_sendmsg+0x8cd/0xcb0 
/net/netlink/af_netlink.c:1761
[<     inline     >] sock_sendmsg_nosec /net/socket.c:612
[<      none      >] sock_sendmsg+0xca/0x110 /net/socket.c:622
[<      none      >] ___sys_sendmsg+0x728/0x860 /net/socket.c:1946
[<      none      >] __sys_sendmsg+0xd1/0x170 /net/socket.c:1980
[<     inline     >] SYSC_sendmsg /net/socket.c:1991
[<      none      >] SyS_sendmsg+0x2d/0x50 /net/socket.c:1987
[<      none      >] entry_SYSCALL_64_fastpath+0x23/0xc1 
/arch/x86/entry/entry_64.S:207
INFO: Freed in 0x1002b3e95 age=18446610062142815928 cpu=0 pid=0
[<     inline     >] skb_free_head /net/core/skbuff.c:579
[<      none      >] skb_release_data+0x361/0x430 /net/core/skbuff.c:610
[<      none      >] __slab_free+0x1e8/0x300 /mm/slub.c:2657
[<     inline     >] slab_free /mm/slub.c:2810
[<      none      >] kfree+0x255/0x2d0 /mm/slub.c:3661
[<     inline     >] skb_free_head /net/core/skbuff.c:579
[<      none      >] skb_release_data+0x361/0x430 /net/core/skbuff.c:610
[<      none      >] skb_release_all+0x4a/0x60 /net/core/skbuff.c:669
[<     inline     >] __kfree_skb /net/core/skbuff.c:683
[<      none      >] consume_skb+0x11b/0x2f0 /net/core/skbuff.c:756
[<      none      >] netlink_dump+0x81f/0xa40 /net/netlink/af_netlink.c:2139
[<      none      >] netlink_recvmsg+0x8fb/0xe00 
/net/netlink/af_netlink.c:1869
[<     inline     >] sock_recvmsg_nosec /net/socket.c:714
[<      none      >] sock_recvmsg+0x9d/0xb0 /net/socket.c:722
[<      none      >] SYSC_recvfrom+0x1e1/0x330 /net/socket.c:1699
[<      none      >] SyS_recvfrom+0x40/0x50 /net/socket.c:1672
[<      none      >] entry_SYSCALL_64_fastpath+0x23/0xc1 
/arch/x86/entry/entry_64.S:207
INFO: Slab 0xffffea0000da9a00 objects=24 used=7 fp=0xffff880036a6d9d0 
flags=0x1fffc0000004080
INFO: Object 0xffff880036a6d9c8 @offset=22984 fp=0xbbbbbbbbbbbbbbbb
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 
rel-1.8.2-0-g33fbe13 by qemu-project.org 04/01/2014
  0000000000000003 ffff88003761f8e0 ffffffff829557d1 ffff88003e806f00
  ffff880036a6d9c8 ffffea0000da9a00 ffff880036a68000 ffff88003761f910
  ffffffff8170fabd ffff88003e806f00 ffffea0000da9a00 ffff880036a6d9c8
Call Trace:
  [<     inline     >] __dump_stack /lib/dump_stack.c:15
  [<ffffffff829557d1>] dump_stack+0xb3/0x112 /lib/dump_stack.c:51
  [<ffffffff8170fabd>] print_trailer+0x10d/0x190 /mm/slub.c:667
  [<ffffffff817165af>] object_err+0x2f/0x40 /mm/slub.c:674
  [<     inline     >] print_address_description /mm/kasan/report.c:179
  [<ffffffff81718dd8>] kasan_report_error+0x218/0x530 /mm/kasan/report.c:275
  [<     inline     >] ? kasan_poison_shadow /mm/kasan/kasan.c:52
  [<ffffffff817184ae>] ? kasan_kmalloc+0x5e/0x70 /mm/kasan/kasan.c:523
  [<ffffffff81718959>] ? kasan_krealloc+0x79/0xa0 /mm/kasan/kasan.c:569
  [<     inline     >] kasan_report /mm/kasan/report.c:297
  [<ffffffff817191ae>] __asan_report_load4_noabort+0x3e/0x40 
/mm/kasan/report.c:317
  [<     inline     >] ? trace_consume_skb /include/trace/events/skb.h:36
  [<ffffffff84b57b00>] ? napi_consume_skb+0x3e0/0x450 /net/core/skbuff.c:815
  [<     inline     >] ? __read_once_size /include/linux/compiler.h:222
  [<ffffffff84c0a42a>] ? fib_nl_dumprule+0x43a/0x4b0 
/net/core/fib_rules.c:675
  [<     inline     >] __read_once_size /include/linux/compiler.h:222
  [<ffffffff84c0a42a>] fib_nl_dumprule+0x43a/0x4b0 /net/core/fib_rules.c:675
  [<ffffffff81458ade>] ? rcu_read_lock_sched_held+0x9e/0x120 
/kernel/rcu/update.c:113
  [<ffffffff84cdc1ca>] netlink_dump+0x36a/0xa40 
/net/netlink/af_netlink.c:2108
  [<ffffffff84cdd19b>] netlink_recvmsg+0x8fb/0xe00 
/net/netlink/af_netlink.c:1869
  [<ffffffff84cdc8a0>] ? netlink_dump+0xa40/0xa40 
/include/linux/skbuff.h:1980
  [<     inline     >] ? rcu_read_unlock /include/linux/rcupdate.h:922
  [<ffffffff817c165c>] ? __fget+0x20c/0x3b0 /fs/file.c:712
  [<     inline     >] ? rcu_lock_release /include/linux/rcupdate.h:491
  [<     inline     >] ? rcu_read_unlock /include/linux/rcupdate.h:926
  [<ffffffff817c1685>] ? __fget+0x235/0x3b0 /fs/file.c:712
  [<ffffffff817c1497>] ? __fget+0x47/0x3b0 /fs/file.c:696
  [<     inline     >] ? futex_unlock_pi /kernel/futex.c:668
  [<ffffffff814ad266>] ? do_futex+0x3d6/0x1650 /kernel/futex.c:3172
  [<ffffffff82696ecf>] ? security_socket_recvmsg+0x8f/0xc0 
/security/security.c:1244
  [<     inline     >] sock_recvmsg_nosec /net/socket.c:714
  [<ffffffff84b3797d>] sock_recvmsg+0x9d/0xb0 /net/socket.c:722
  [<ffffffff84b37ff1>] SYSC_recvfrom+0x1e1/0x330 /net/socket.c:1699
  [<ffffffff84b37e10>] ? kernel_recvmsg+0x120/0x120 /net/socket.c:748
  [<     inline     >] ? rcu_read_unlock_sched 
/include/linux/rcupdate.h:1005
  [<ffffffff817c3199>] ? __fd_install+0x229/0x590 /fs/file.c:622
  [<     inline     >] ? rcu_lock_release /include/linux/rcupdate.h:491
  [<     inline     >] ? rcu_read_unlock_sched 
/include/linux/rcupdate.h:1007
  [<ffffffff817c31b6>] ? __fd_install+0x246/0x590 /fs/file.c:622
  [<ffffffff817c2f70>] ? get_unused_fd_flags+0xd0/0xd0 
/include/linux/compiler.h:222
  [<ffffffff817c2f70>] ? get_unused_fd_flags+0xd0/0xd0 
/include/linux/compiler.h:222
  [<ffffffff84b328f0>] ? sock_splice_read+0xf0/0xf0 /net/socket.c:776
  [<     inline     >] ? SYSC_futex /kernel/futex.c:3218
  [<ffffffff814ae61f>] ? SyS_futex+0x13f/0x2b0 /kernel/futex.c:3186
  [<ffffffff817c354d>] ? fd_install+0x4d/0x60 /fs/file.c:627
  [<ffffffff814ae4e0>] ? do_futex+0x1650/0x1650 /kernel/futex.c:1470
  [<     inline     >] ? SYSC_socket /net/socket.c:1240
  [<ffffffff84b3b2f8>] ? SyS_socket+0x128/0x1b0 /net/socket.c:1210
  [<ffffffff84b3bca0>] SyS_recvfrom+0x40/0x50 /net/socket.c:1672
  [<ffffffff85c8ab80>] entry_SYSCALL_64_fastpath+0x23/0xc1 
/arch/x86/entry/entry_64.S:207
Memory state around the buggy address:
  ffff880036a6d880: fb fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
  ffff880036a6d900: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
 >ffff880036a6d980: fc fc fc fc fc fc fc fc fc fc fb fb fb fb fb fb
                                                  ^
  ffff880036a6da00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
  ffff880036a6da80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================

Best Wishes,
Richard Criswell
