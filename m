From: Baozeng Ding <sploving1@gmail.com>
Subject: BUG: use-after-free in netlink_dump
Date: Sun, 15 May 2016 23:24:35 +0800
Message-ID: <573894B3.8030009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, herbert@gondor.apana.org.au,
	chamaken@gmail.com, daniel@iogearbox.net, daniel@iogearbox.net,
	daniel@iogearbox.net, daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35442 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754045AbcEOPYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 11:24:47 -0400
Received: by mail-pf0-f193.google.com with SMTP id b66so5520209pfb.2
        for <netdev@vger.kernel.org>; Sun, 15 May 2016 08:24:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
I've got the following report (use-after-free in netlink_dump) while 
running syzkaller.
Unfortunately no reproducer.The kernel version is 4.6.0-rc2+.

==================================================================
BUG: KASAN: use-after-free in netlink_dump+0x4eb/0xa40 at addr 
ffff880036ae7988
Read of size 4 by task syz-executor/14596
=============================================================================
BUG kmalloc-1024 (Tainted: G    B          ): kasan: bad access detected
-----------------------------------------------------------------------------

INFO: Allocated in 0xbbbbbbbbbbbbbbbb age=18446681375777959590 cpu=0 pid=0
[<      none      >] __alloc_skb+0xf0/0x5f0 net/core/skbuff.c:230
[<      none      >] ___slab_alloc+0x4c7/0x500 mm/slub.c:2446
[<      none      >] __slab_alloc+0x4c/0x90 mm/slub.c:2475
[<     inline     >] slab_alloc_node mm/slub.c:2538
[<      none      >] __kmalloc_node_track_caller+0xba/0x420 mm/slub.c:4095
[<      none      >] __kmalloc_reserve.isra.33+0x41/0xe0 
net/core/skbuff.c:137
[<      none      >] __alloc_skb+0xf0/0x5f0 net/core/skbuff.c:230
[<     inline     >] alloc_skb include/linux/skbuff.h:895
[<     inline     >] netlink_alloc_large_skb net/netlink/af_netlink.c:1086
[<      none      >] netlink_sendmsg+0x8cd/0xcb0 
net/netlink/af_netlink.c:1761
[<     inline     >] sock_sendmsg_nosec net/socket.c:612
[<      none      >] sock_sendmsg+0xca/0x110 net/socket.c:622
[<      none      >] ___sys_sendmsg+0x728/0x860 net/socket.c:1946
[<      none      >] __sys_sendmsg+0xd1/0x170 net/socket.c:1980
[<     inline     >] SYSC_sendmsg net/socket.c:1991
[<      none      >] SyS_sendmsg+0x2d/0x50 net/socket.c:1987
[<      none      >] entry_SYSCALL_64_fastpath+0x23/0xc1 
arch/x86/entry/entry_64.S:207
INFO: Freed in 0x1000f2d5f age=18446681375777959590 cpu=0 pid=0
[<     inline     >] skb_free_head net/core/skbuff.c:579
[<      none      >] skb_release_data+0x361/0x430 net/core/skbuff.c:610
[<      none      >] __slab_free+0x1e8/0x300 mm/slub.c:2657
[<     inline     >] slab_free mm/slub.c:2810
[<      none      >] kfree+0x255/0x2d0 mm/slub.c:3661
[<     inline     >] skb_free_head net/core/skbuff.c:579
[<      none      >] skb_release_data+0x361/0x430 net/core/skbuff.c:610
[<      none      >] skb_release_all+0x4a/0x60 net/core/skbuff.c:669
[<     inline     >] __kfree_skb net/core/skbuff.c:683
[<      none      >] consume_skb+0x11b/0x2f0 net/core/skbuff.c:756
[<     inline     >] netlink_unicast_kernel net/netlink/af_netlink.c:1215
[<      none      >] netlink_unicast+0x5aa/0x890 
net/netlink/af_netlink.c:1240
[<      none      >] netlink_sendmsg+0x981/0xcb0 
net/netlink/af_netlink.c:1786
[<     inline     >] sock_sendmsg_nosec net/socket.c:612
[<      none      >] sock_sendmsg+0xca/0x110 net/socket.c:622
[<      none      >] ___sys_sendmsg+0x728/0x860 net/socket.c:1946
[<      none      >] __sys_sendmsg+0xd1/0x170 net/socket.c:1980
[<     inline     >] SYSC_sendmsg net/socket.c:1991
[<      none      >] SyS_sendmsg+0x2d/0x50 net/socket.c:1987
[<      none      >] entry_SYSCALL_64_fastpath+0x23/0xc1 
arch/x86/entry/entry_64.S:207
INFO: Slab 0xffffea0000dab800 objects=24 used=8 fp=0xffff880036ae7980 
flags=0x1fffc0000004080
INFO: Object 0xffff880036ae7978 @offset=31096 fp=0xbbbbbbbbbbbbbbbb
CPU: 0 PID: 14596 Comm: syz-executor Tainted: G    B 4.6.0-rc2+ #16

Call Trace:
  [<     inline     >] __dump_stack lib/dump_stack.c:15
  [<ffffffff829557d1>] dump_stack+0xb3/0x112 lib/dump_stack.c:51
  [<ffffffff8170fabd>] print_trailer+0x10d/0x190 mm/slub.c:667
  [<ffffffff817165af>] object_err+0x2f/0x40 mm/slub.c:674
  [<     inline     >] print_address_description mm/kasan/report.c:179
  [<ffffffff81718dd8>] kasan_report_error+0x218/0x530 mm/kasan/report.c:275
  [<     inline     >] kasan_report mm/kasan/report.c:297
  [<ffffffff817191ae>] __asan_report_load4_noabort+0x3e/0x40 
mm/kasan/report.c:317
  [<     inline     >] ? nlmsg_put_answer include/net/netlink.h:471
  [<ffffffff84cdc34b>] ? netlink_dump+0x4eb/0xa40 
net/netlink/af_netlink.c:2120
  [<     inline     >] nlmsg_put_answer include/net/netlink.h:471
  [<ffffffff84cdc34b>] netlink_dump+0x4eb/0xa40 
net/netlink/af_netlink.c:2120
  [<ffffffff84cdd19b>] netlink_recvmsg+0x8fb/0xe00 
net/netlink/af_netlink.c:1869
  [<ffffffff84cdc8a0>] ? netlink_dump+0xa40/0xa40 
include/linux/skbuff.h:1980
  [<ffffffff81768c23>] ? rw_copy_check_uvector+0x1c3/0x260 
fs/read_write.c:818
  [<ffffffff829953b6>] ? import_iovec+0x216/0x3c0 lib/iov_iter.c:811
  [<ffffffff829951a0>] ? iov_iter_get_pages_alloc+0x960/0x960 
lib/iov_iter.c:629
  [<ffffffff82696ecf>] ? security_socket_recvmsg+0x8f/0xc0 
security/security.c:1244
  [<     inline     >] sock_recvmsg_nosec net/socket.c:714
  [<ffffffff84b3797d>] sock_recvmsg+0x9d/0xb0 net/socket.c:722
  [<ffffffff84b378e0>] ? __sock_recv_wifi_status+0x180/0x180 
./arch/x86/include/asm/bitops.h:311
  [<ffffffff84b3a769>] ___sys_recvmsg+0x259/0x540 net/socket.c:2104
  [<     inline     >] ? sock_sendmsg_nosec net/socket.c:612
  [<ffffffff84b3a510>] ? ___sys_sendmsg+0x860/0x860 net/socket.c:1943
  [<     inline     >] ? rcu_read_unlock include/linux/rcupdate.h:922
  [<ffffffff817c165c>] ? __fget+0x20c/0x3b0 fs/file.c:712
  [<     inline     >] ? rcu_lock_release include/linux/rcupdate.h:491
  [<     inline     >] ? rcu_read_unlock include/linux/rcupdate.h:926
  [<ffffffff817c1685>] ? __fget+0x235/0x3b0 fs/file.c:712
  [<ffffffff817c1497>] ? __fget+0x47/0x3b0 fs/file.c:696
  [<ffffffff817c18e1>] ? __fget_light+0xa1/0x1f0 fs/file.c:759
  [<ffffffff817c1a48>] ? __fdget+0x18/0x20 fs/file.c:764
  [<ffffffff84b360c8>] ? sockfd_lookup_light+0xf8/0x1f0 net/socket.c:463
  [<ffffffff84b3c95e>] __sys_recvmsg+0xce/0x170 net/socket.c:2150
  [<ffffffff84b3c890>] ? SyS_sendmmsg+0x60/0x60 net/socket.c:2064
  [<     inline     >] SYSC_recvmsg net/socket.c:2162
  [<ffffffff84b3ca2d>] SyS_recvmsg+0x2d/0x50 net/socket.c:2157
  [<ffffffff85c8ab80>] entry_SYSCALL_64_fastpath+0x23/0xc1 
arch/x86/entry/entry_64.S:207
Memory state around the buggy address:
  ffff880036ae7880: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
  ffff880036ae7900: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
 >ffff880036ae7980: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                       ^
  ffff880036ae7a00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
  ffff880036ae7a80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================

Best Regards,
Baozeng Ding
