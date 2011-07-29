From: synapse <synapse@hippy.csoma.elte.hu>
Subject: PROBLEM: BUG (NULL ptr dereference in ipv4_dst_check)
Date: Fri, 29 Jul 2011 15:18:52 +0200
Message-ID: <4E32B33C.2020103@hippy.csoma.elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:44687 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756537Ab1G2NTA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2011 09:19:00 -0400
Received: from hippy.csoma.elte.hu ([157.181.199.200])
	by mx3.mail.elte.hu with esmtp (Exim)
	id 1Qmmxu-0006vS-6T
	from <synapse@hippy.csoma.elte.hu>
	for <netdev@vger.kernel.org>; Fri, 29 Jul 2011 15:18:58 +0200
Received: from [192.168.12.22] (client-203.doclerweb.com [80.77.114.203])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by hippy.csoma.elte.hu (Postfix) with ESMTPSA id 12A3BA3211
	for <netdev@vger.kernel.org>; Fri, 29 Jul 2011 15:18:58 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello guys,

I have a problem that I hope you can help me resolv. This is my first 
real bug report, so please be
patient :)

### Description:
3.0.0-rc4 routinely locks up with BUG: unable to handle kernel NULL 
pointer dereference at 000000000000002c
I have an intel sr2600 machine with a 10Gbit interface, it periodically 
locks up after a few days.
It serves a lot of traffic. The trace is at the end of the mail.
###

### My efforts:
I've traced the error back from atomic_dec_and_test() to:

ipv4_dst_check()
check_peer_redir()
neigh_release()
atomic_dec_and_test()

The parameter to atomic_dec_and_test() is NULL (&neigh->refcnt in 
neigh_release), so atomic_dec_and_test()
at /arch/x86/include/asm/atomic.h dies at offset 0xffffffff8140f56f.

ffffffff8140f560:       48 8b 15 19 47 2f 00    mov    
0x2f4719(%rip),%rdx        # 0xffffffff81703c80
ffffffff8140f567:       48 89 50 18             mov    %rdx,0x18(%rax)
ffffffff8140f56b:       48 8b 7b 40             mov    0x40(%rbx),%rdi
ffffffff8140f56f:       f0 ff 4f 2c             lock decl 0x2c(%rdi)
ffffffff8140f573:       0f 94 c0                sete   %al
ffffffff8140f576:       84 c0                   test   %al,%al
ffffffff8140f578:       0f 85 ab 00 00 00       jne    0xffffffff8140f629

 From what I've seen is that this code is responsible for pmtu related 
things. The refcount member of struct neighbour
is NULL and the neigh pointer (struct neighbour *) in neigh_release() is 
not. I have no clue how this might happen,
though I suspect somebody releases the data structure somehow. Note that 
this code is invoked when redirect_learned.a4
is set and is different from rt_gateway in ipv4_dst_check().

Is it possible that two packets go to two different cores for processing 
and one core invalidates the rt entry
the other is currently working on (meaning the second will try to 
dereference a NULL ptr)?
###


This is just my clumsy attempt at tracking this down, I'm not a kernel 
expert unfortunately. I'm happy to provide
further info on the matter. If I'm completely on the wrong track please 
let me know.

Thank you for any help,
Gergely Kalman


TRACE:
===============================================================
BUG: unable to handle kernel NULL pointer dereference at 000000000000002c
IP: [<ffffffff8140f56f>] ipv4_dst_check+0xaf/0x190
PGD 0
Oops: 0002 [#1] SMP
CPU 8
Modules linked in: 8021q garp bridge stp llc iptable_filter ip_tables 
ixgbe ioatdma mdio dca hed

Pid: 0, comm: kworker/0:1 Not tainted 3.0.0-rc4-10g-lvs-pktgen #1 Intel 
Corporation S5520UR/S5520UR
RIP: 0010:[<ffffffff8140f56f>]  [<ffffffff8140f56f>] 
ipv4_dst_check+0xaf/0x190
RSP: 0018:ffff8801efc83a40  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff88014d428900 RCX: ffff8801a44fa000
RDX: 0000000000000000 RSI: ffff8801a4335bc0 RDI: 0000000000000000
RBP: 00000000fea2476d R08: 000000000000fa4b R09: 0000000000007d25
R10: 00000000000000c0 R11: 0000000000000003 R12: ffff8801a4335bc0
R13: 0000000000006bc1 R14: 0000000000000000 R15: ffff88016291da20
FS:  0000000000000000(0000) GS:ffff8801efc80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 000000000000002c CR3: 0000000001697000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kworker/0:1 (pid: 0, threadinfo ffff8801e90ee000, task 
ffff8801e90d9680)
Stack:
  ffff88014d428900 ffff88016291d780 0000000000000000 ffffffff813dccfa
  ffff88036fff9000 ffff8801b77bfc58 ffff88016291d780 ffffffff81417a82
  ffff8801a44fb0a0 ffff88016291d780 ffff8801b77bfc58 ffff8801b77bfc80
Call Trace:
<IRQ>
  [<ffffffff813dccfa>] ? __sk_dst_check+0x4a/0x70
  [<ffffffff81417a82>] ? ip_queue_xmit+0x2b2/0x3c0
  [<ffffffff8142c23b>] ? tcp_transmit_skb+0x3bb/0x850
  [<ffffffff8142e8cc>] ? tcp_write_xmit+0x1ec/0xa10
  [<ffffffff8142f239>] ? __tcp_push_pending_frames+0x19/0x80
  [<ffffffff81426076>] ? tcp_data_snd_check+0x36/0x120
  [<ffffffff8142a5d9>] ? tcp_rcv_established+0x349/0x7c0
  [<ffffffff8143204f>] ? tcp_v4_do_rcv+0x10f/0x2e0
  [<ffffffff81412300>] ? ip_rcv_finish+0x350/0x350
  [<ffffffff81433102>] ? tcp_v4_rcv+0x4e2/0x7a0
  [<ffffffff8141237d>] ? ip_local_deliver_finish+0x7d/0x130
  [<ffffffff813e802e>] ? __netif_receive_skb+0x1ae/0x350
  [<ffffffff813edc78>] ? netif_receive_skb+0x78/0x80
  [<ffffffff813ee21b>] ? napi_gro_receive+0xbb/0xd0
  [<ffffffff813edda8>] ? napi_skb_finish+0x38/0x50
  [<ffffffffa004c372>] ? ixgbe_clean_rx_irq+0x4f2/0x780 [ixgbe]
  [<ffffffffa004eddd>] ? ixgbe_clean_rxtx_many+0xed/0x1f0 [ixgbe]
  [<ffffffff8120b890>] ? timerqueue_add+0x60/0xb0
  [<ffffffff813ee366>] ? net_rx_action+0x86/0x170
  [<ffffffff8104aab1>] ? __do_softirq+0x91/0x140
  [<ffffffff8107ccfa>] ? handle_irq_event_percpu+0x7a/0x140
  [<ffffffff81474e4c>] ? call_softirq+0x1c/0x30
  [<ffffffff8100428d>] ? do_softirq+0x4d/0x80
  [<ffffffff8104a975>] ? irq_exit+0xb5/0xc0
  [<ffffffff81003aac>] ? do_IRQ+0x5c/0xd0
  [<ffffffff814737d3>] ? common_interrupt+0x13/0x13
<EOI>
  [<ffffffff81251c8c>] ? acpi_hw_read_multiple+0x28/0x60
  [<ffffffff81261afd>] ? acpi_idle_enter_bm+0x22c/0x260
  [<ffffffff81261af8>] ? acpi_idle_enter_bm+0x227/0x260
  [<ffffffff813b7281>] ? cpuidle_idle_call+0x81/0xf0
  [<ffffffff810017d8>] ? cpu_idle+0x58/0xb0
Code: 00 89 83 d4 00 00 00 eb 98 0f 1f 00 48 85 db 74 16 48 8b 43 40 31 
ff 48 85 c0 74 0f 48 8b 15 19 47 2f 00 48 89 50 18 48 8b 7b 40 <f0> ff 
4f 2c 0f 94 c0 84 c0 0f 85 ab 00 00 00 48 c7 43 40 00 00
RIP  [<ffffffff8140f56f>] ipv4_dst_check+0xaf/0x190
  RSP <ffff8801efc83a40>
CR2: 000000000000002c
---[ end trace 8a3fd44eb302579f ]---
