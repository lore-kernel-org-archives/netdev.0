From: Tom Parkin <tparkin@katalix.com>
Subject: [RFC PATCH] prevent oops in udp rcv path
Date: Thu,  7 Mar 2013 22:36:39 +0000
Message-ID: <1362695800-8633-1-git-send-email-tparkin@katalix.com>
Cc: Tom Parkin <tparkin@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:35657 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751268Ab3CGWgp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 17:36:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During stress testing of some l2tp patches, I've been able to cause an oops in
the udp rcv path by tearing down l2tp sessions while they're passing data.
The oops text is below -- this is for a udp-encap l2tp tunnel containing a
number of ethernet pseudowires.

So far, I've only managed to reproduce this oops with a PREEMPT kernel running
on a VM.  Based on my debugging here it seems that the failure case is caused
by a fragmented IP packet being queued/reassembled across the device shutdown
event.  When such a packet hits udp_rcv, skb_dst(skb)->dev is NULL, which
leads to an oops when the receive code attempts to associate the skb with a
udp socket.

The accompanying patch, which I don't really propose as a fix so much as an
illustration of what goes wrong, "fixes" this problem by dropping packets with
a NULL dev field in the dst_entry.

I'm not sure what is the real root cause of this bug, though -- hence the RFC.

BUG: unable to handle kernel NULL pointer dereference at 0000000000000478
IP: [<ffffffff81618c54>] __udp4_lib_rcv+0x514/0xa80
PGD ac38067 PUD 11492067 PMD 0
Oops: 0000 [#1] PREEMPT SMP
Modules linked in: l2tp_eth l2tp_netlink l2tp_core microcode psmouse seri0
CPU 0
Pid: 12607, comm: ip Tainted: G        W    3.8.0-l2tp-pw-fixups-2-dev-6+x
RIP: 0010:[<ffffffff81618c54>]  [<ffffffff81618c54>] __udp4_lib_rcv+0x5140
RSP: 0000:ffff880014403a10  EFLAGS: 00010286
RAX: 0000000000000000 RBX: ffff880010c3f700 RCX: 000000006800000a
RDX: 0000000000008813 RSI: 000000008300000a RDI: 0000000000000246
RBP: ffff880014403a90 R08: 0000000000008813 R09: 0000000000000003
R10: 000000008300000a R11: 0000000000000001 R12: ffff88000c232ea2
R13: 0000000000000011 R14: ffffffff81cc19c0 R15: 00000000000005de
FS:  00007f2d5efd6700(0000) GS:ffff880014400000(0000) knlGS:00000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000478 CR3: 0000000011c35000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process ip (pid: 12607, threadinfo ffff88000c05c000, task ffff88000bc1a2e)
Stack:
 ffff880014403a50 da950d56ef5b821f ffff88000c05dfd8 000000008300000a
 0000000000000003 ffff88006800000a 8813881314403a50 ffffffff81ce5750
 ffff880014403a90 6800000a8300000a 0000000000000246 ffff880010c3f700
Call Trace:
 <IRQ>
 [<ffffffff816191da>] udp_rcv+0x1a/0x20
 [<ffffffff815e0a96>] ip_local_deliver_finish+0xd6/0x530
 [<ffffffff815e0a0a>] ? ip_local_deliver_finish+0x4a/0x530
 [<ffffffff815e1b44>] ip_local_deliver+0x134/0x410
 [<ffffffff815e1080>] ip_rcv_finish+0x190/0x8d0
 [<ffffffff815e203d>] ip_rcv+0x21d/0x300
 [<ffffffff815a531b>] __netif_receive_skb_core+0xa7b/0xd50
 [<ffffffff815a49e2>] ? __netif_receive_skb_core+0x142/0xd50
 [<ffffffff815a5611>] __netif_receive_skb+0x21/0x70
 [<ffffffff815a5823>] netif_receive_skb+0x23/0x1f0
 [<ffffffff815a6678>] napi_gro_receive+0xe8/0x140
 [<ffffffffa0002aa8>] e1000_clean_rx_irq+0x2b8/0x520 [e1000]
 [<ffffffffa000317e>] e1000_clean+0x28e/0x990 [e1000]
 [<ffffffff810af709>] ? __lock_acquire+0x469/0x1e60
 [<ffffffff815a73a9>] net_rx_action+0x179/0x3c0
 [<ffffffff810ad496>] ? mark_held_locks+0x86/0x150
 [<ffffffff81084718>] ? sched_clock_cpu+0xb8/0x130
 [<ffffffff8104b548>] __do_softirq+0xe8/0x460
 [<ffffffff8136876d>] ? do_raw_spin_unlock+0x5d/0xb0
 [<ffffffff816e1a7c>] call_softirq+0x1c/0x30
 [<ffffffff810042a5>] do_softirq+0xa5/0xe0
 [<ffffffff8104ba6e>] irq_exit+0x9e/0xc0
 [<ffffffff816e1b73>] do_IRQ+0x63/0xd0
 [<ffffffff816d85b2>] common_interrupt+0x72/0x72
 <EOI>
 [<ffffffff81134c62>] ? find_get_page+0xb2/0x230
 [<ffffffff81134d95>] ? find_get_page+0x1e5/0x230
 [<ffffffff81134bb5>] ? find_get_page+0x5/0x230
 [<ffffffff81009d22>] ? native_sched_clock+0x22/0x80
 [<ffffffff8113696b>] filemap_fault+0x8b/0x4f0
 [<ffffffff8115b929>] __do_fault+0x69/0x4c0
 [<ffffffff810af709>] ? __lock_acquire+0x469/0x1e60
 [<ffffffff8115e800>] handle_pte_fault+0x90/0x850
 [<ffffffff81084575>] ? sched_clock_local+0x25/0x90
 [<ffffffff811601e1>] handle_mm_fault+0x241/0x340
 [<ffffffff816dbba7>] __do_page_fault+0x197/0x5e0
 [<ffffffff811ad7f9>] ? fget_light+0x3e9/0x4e0
 [<ffffffff813622bd>] ? trace_hardirqs_off_thunk+0x3a/0x3c
 [<ffffffff816dbffe>] do_page_fault+0xe/0x10
 [<ffffffff816d88e8>] page_fault+0x28/0x30
Code: 45 85 c9 75 07 44 8b 8b a0 00 00 00 85 f6 8b 4a 10 44 8b 52 0c 0f 8
RIP  [<ffffffff81618c54>] __udp4_lib_rcv+0x514/0xa80
 RSP <ffff880014403a10>
CR2: 0000000000000478
---[ end trace da950d56ef5b8221 ]---

Tom Parkin (1):
  udp: don't rereference dst_entry dev pointer on rcv

 net/ipv4/udp.c |    3 +++
 1 file changed, 3 insertions(+)

--
1.7.9.5
