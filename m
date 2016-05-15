From: Baozeng Ding <sploving1@gmail.com>
Subject: BUG: net/ipv4: KASAN: use-after-free in tcp_sendmsg
Date: Mon, 16 May 2016 00:09:17 +0800
Message-ID: <57389F2D.4060701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36189 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754344AbcEOQJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 12:09:28 -0400
Received: by mail-pf0-f193.google.com with SMTP id g132so13547622pfb.3
        for <netdev@vger.kernel.org>; Sun, 15 May 2016 09:09:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
I've got the following report use-after-free in  tcp_sendmsg (net/ipv4) 
while running syzkaller.
Unfortunately no reproducer.The kernel version is 4.6.0-rc2+.

==================================================================
BUG: KASAN: use-after-free in release_sock+0x4a0/0x510 at addr 
ffff8800380279c0
Read of size 8 by task sshd/7035
=============================================================================
BUG skbuff_head_cache (Tainted: G    B D        ): kasan: bad access 
detected
-----------------------------------------------------------------------------

INFO: Freed in e1000_clean+0xa08/0x24a0 age=6364136656 cpu=2226773637 pid=-1
[<     inline     >] napi_poll net/core/dev.c:5087
[<      none      >] net_rx_action+0x751/0xd80 net/core/dev.c:5152
[<      none      >] __do_softirq+0x22b/0x8da kernel/softirq.c:273
[<     inline     >] invoke_softirq kernel/softirq.c:350
[<      none      >] irq_exit+0x15d/0x190 kernel/softirq.c:391
[<     inline     >] exiting_irq ./arch/x86/include/asm/apic.h:658
[<      none      >] do_IRQ+0x86/0x1a0 arch/x86/kernel/irq.c:252
[<      none      >] ret_from_intr+0x0/0x20 arch/x86/entry/entry_64.S:454
[<      none      >] kfree_skbmem+0xe6/0x100 net/core/skbuff.c:622
[<      none      >] __slab_free+0x1e8/0x300 mm/slub.c:2657
[<     inline     >] slab_free mm/slub.c:2810
[<      none      >] kmem_cache_free+0x298/0x320 mm/slub.c:2819
[<      none      >] kfree_skbmem+0xe6/0x100 net/core/skbuff.c:622
[<      none      >] __kfree_skb+0x1d/0x20 net/core/skbuff.c:684
[<      none      >] kfree_skb+0x107/0x310 net/core/skbuff.c:704
[<      none      >] packet_rcv_spkt+0xd8/0x4a0 net/packet/af_packet.c:1822
[<     inline     >] deliver_skb net/core/dev.c:1814
[<     inline     >] deliver_ptype_list_skb net/core/dev.c:1829
[<      none      >] __netif_receive_skb_core+0x134a/0x3060 
net/core/dev.c:4143
[<      none      >] __netif_receive_skb+0x2a/0x160 net/core/dev.c:4198

Call Trace:
  [<     inline     >] __dump_stack lib/dump_stack.c:15
  [<ffffffff829557d1>] dump_stack+0xb3/0x112 lib/dump_stack.c:51
  [<ffffffff8170fabd>] print_trailer+0x10d/0x190 mm/slub.c:667
  [<ffffffff817165af>] object_err+0x2f/0x40 mm/slub.c:674
  [<     inline     >] print_address_description mm/kasan/report.c:179
  [<ffffffff81718dd8>] kasan_report_error+0x218/0x530 mm/kasan/report.c:275
  [<     inline     >] ? rdtsc ./arch/x86/include/asm/msr.h:155
  [<     inline     >] ? rdtsc_ordered ./arch/x86/include/asm/msr.h:183
  [<ffffffff82983d18>] ? delay_tsc+0x18/0x70 arch/x86/lib/delay.c:58
  [<     inline     >] kasan_report mm/kasan/report.c:297
  [<ffffffff817191ee>] __asan_report_load8_noabort+0x3e/0x40 
mm/kasan/report.c:318
  [<     inline     >] ? __raw_spin_unlock 
include/linux/spinlock_api_smp.h:153
  [<ffffffff85c8a400>] ? _raw_spin_unlock+0x20/0x30 
kernel/locking/spinlock.c:183
  [<     inline     >] ? __release_sock net/core/sock.c:1984
  [<ffffffff84b45a80>] ? release_sock+0x4a0/0x510 net/core/sock.c:2442
  [<     inline     >] __release_sock net/core/sock.c:1984
  [<ffffffff84b45a80>] release_sock+0x4a0/0x510 net/core/sock.c:2442
  [<ffffffff84edc13e>] tcp_sendmsg+0x1de/0x2a90 net/ipv4/tcp.c:1293
  [<ffffffff84edbf60>] ? tcp_sendpage+0x1820/0x1820 
include/linux/skbuff.h:1491
  [<     inline     >] ? sock_rps_record_flow include/net/sock.h:878
  [<ffffffff84f94493>] ? inet_sendmsg+0x73/0x4c0 net/ipv4/af_inet.c:733
  [<     inline     >] ? rcu_read_unlock include/linux/rcupdate.h:922
  [<     inline     >] ? sock_rps_record_flow_hash include/net/sock.h:871
  [<     inline     >] ? sock_rps_record_flow include/net/sock.h:878
  [<ffffffff84f9461a>] ? inet_sendmsg+0x1fa/0x4c0 net/ipv4/af_inet.c:733
  [<ffffffff84f94715>] inet_sendmsg+0x2f5/0x4c0 net/ipv4/af_inet.c:740
  [<     inline     >] ? sock_rps_record_flow include/net/sock.h:878
  [<ffffffff84f94493>] ? inet_sendmsg+0x73/0x4c0 net/ipv4/af_inet.c:733
  [<ffffffff84f94420>] ? inet_recvmsg+0x4a0/0x4a0 
include/linux/compiler.h:222
  [<     inline     >] sock_sendmsg_nosec net/socket.c:612
  [<ffffffff84b3858a>] sock_sendmsg+0xca/0x110 net/socket.c:622
  [<ffffffff84b387e6>] sock_write_iter+0x216/0x3a0 net/socket.c:821
  [<ffffffff84b385d0>] ? sock_sendmsg+0x110/0x110 net/socket.c:612
  [<ffffffff82992caf>] ? iov_iter_init+0xaf/0x1d0 lib/iov_iter.c:359
  [<     inline     >] new_sync_write fs/read_write.c:518
  [<ffffffff81762fa0>] __vfs_write+0x300/0x4b0 fs/read_write.c:531
  [<ffffffff81762ca0>] ? do_iter_readv_writev+0x2b0/0x2b0 
fs/read_write.c:707
  [<ffffffff8132ccb0>] ? retarget_shared_pending+0x210/0x210 
include/linux/signal.h:117
  [<     inline     >] ? spin_unlock_irq include/linux/spinlock.h:357
  [<ffffffff813360f0>] ? __set_current_blocked+0x80/0xa0 
kernel/signal.c:2490
  [<ffffffff8275d442>] ? apparmor_file_permission+0x22/0x30 
security/apparmor/lsm.c:446
  [<ffffffff81764242>] ? rw_verify_area+0x102/0x2c0 fs/read_write.c:448
  [<ffffffff81764877>] vfs_write+0x167/0x4a0 fs/read_write.c:578
  [<     inline     >] SYSC_write fs/read_write.c:625
  [<ffffffff817686b1>] SyS_write+0x111/0x220 fs/read_write.c:617
  [<ffffffff817685a0>] ? SyS_read+0x220/0x220 fs/read_write.c:599
  [<ffffffff8100301b>] ? trace_hardirqs_on_thunk+0x1b/0x1d 
arch/x86/entry/thunk_64.S:42
  [<ffffffff85c8ab80>] entry_SYSCALL_64_fastpath+0x23/0xc1 
arch/x86/entry/entry_64.S:207
Memory state around the buggy address:
  ffff880038027880: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
  ffff880038027900: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
 >ffff880038027980: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
                                            ^
  ffff880038027a00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
  ffff880038027a80: fb fb fb fb fc fc fc fc fc fc fc fc fc fc fc fc
==================================================================


Best Regards,
Baozeng Ding
