From: Nelson Elhage <nelhage@ksplice.com>
Subject: NULL dereference in econet AUN-over-UDP receive
Date: Wed, 8 Dec 2010 19:30:15 -0500
Message-ID: <20101209003015.GA27906@ksplice.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:44568 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753767Ab0LIAfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 19:35:55 -0500
Received: by qwa26 with SMTP id 26so1938580qwa.19
        for <netdev@vger.kernel.org>; Wed, 08 Dec 2010 16:35:54 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While testing one of my econet reproducers on a patched kernel, I triggered a
NULL pointer dereference in the econet AUN-over-UDP receive path. Upon further
investigation, I now suspect that this code path hasn't worked at all in years.

A copy of the oops is below for your reference, but here's my analysis:

When aun_data_available receives a data packet (ah->code == 2), it calls
aun_incoming to process the skb. The start of aun_incoming looks like:

static void aun_incoming(struct sk_buff *skb, struct aunhdr *ah, size_t len)
{
	struct iphdr *ip = ip_hdr(skb);
	unsigned char stn = ntohl(ip->saddr) & 0xff;
	struct sock *sk = NULL;
	struct sk_buff *newskb;
---> 	struct ec_device *edev = skb->dev->ec_ptr;    


However, as far as I can tell, skb->dev is always NULL, meaning that that last
line will fault immediately before this function can do any real work.

In particular, 'skb' comes from "skb = skb_recv_datagram(sk, 0, 1, &err)" in
aun_data_available. skb_recv_datagram() pulls skb's off of sk->sk_receive_queue,
and (unless I'm missing something), the only way things get on that queue is via
sock_queue_rcv_skb, which explicitly sets skb->dev = NULL.

So, if I understand this all correctly, receiving AUN-over-UDP just plain hasn't
worked at all for a long time -- I can reproduce this crash on 2.6.12, which is
the earliest I've tested, and from reading code I suspect it's been broken at
least since 2.6.0.

I am not an expert in the networking subsystem, though, so if I am missing some
way that this code does actually work, please feel to correct me.

If, on the other hand, this code really hasn't worked in years, and no one
noticed, I wonder if we should reconsider moving this code into staging and
eventually out entirely, at least unless any real users step forward.

- Nelson


---- snip here ----

BUG: unable to handle kernel NULL pointer dereference at 0000000000000240
IP: [<ffffffff813a303e>] aun_data_available+0xb3/0x28d
PGD e818067 PUD e819067 PMD 0 
Oops: 0000 [#1] SMP 
last sysfs file: /sys/devices/virtual/net/lo/operstate
CPU 0 
Modules linked in:

Pid: 0, comm: swapper Not tainted 2.6.37-rc3 #39 /Bochs
RIP: 0010:[<ffffffff813a303e>]  [<ffffffff813a303e>] aun_data_available+0xb3/0x28d
RSP: 0018:ffff88000fc03b00  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff88000fc03b3c RCX: ffff88000e808800
RDX: 0000000000000002 RSI: 0000000000000286 RDI: ffff88000e8060d4
RBP: ffff88000fc03b70 R08: 0000000000000003 R09: 0000000000000002
R10: ffff88000e69ac00 R11: 00000000ffffffff R12: ffff88000e80886a
R13: ffff88000e439500 R14: ffff88000e8060d4 R15: ffff88000e80884e
FS:  0000000000000000(0000) GS:ffff88000fc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000240 CR3: 000000000e813000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffffffff81600000, task ffffffff8162b020)
Stack:
 ffff88000fc03ba0 ffffffff8131d614 ffff880000000010 ffff88000e806000
 0200000100000000 0202000a00000000 ffffc90000086d48 0000000000000246
 ffff88000fc03b70 ffff88000e806000 ffff88000e439500 0000000000000000
Call Trace:
 <IRQ> 
 [<ffffffff8131d614>] ? rt_intern_hash+0x5de/0x606
 [<ffffffff812f7839>] sock_queue_rcv_skb+0x168/0x187
 [<ffffffff81325641>] ip_queue_rcv_skb+0x45/0x4c
 [<ffffffff81031aa0>] ? try_to_wake_up+0x265/0x277
 [<ffffffff8133ee23>] __udp_queue_rcv_skb+0x50/0xb9
 [<ffffffff813403b0>] udp_queue_rcv_skb+0x1ad/0x26e
 [<ffffffff81340b67>] __udp4_lib_rcv+0x30a/0x50d
 [<ffffffff81340d7f>] udp_rcv+0x15/0x17
 [<ffffffff813206b1>] ip_local_deliver+0x12d/0x1d0
 [<ffffffff81320546>] ip_rcv+0x4f2/0x530
 [<ffffffff81300fb3>] __netif_receive_skb+0x34d/0x377
 [<ffffffff81301c1d>] netif_receive_skb+0x67/0x6e
 [<ffffffff812fb763>] ? __netdev_alloc_skb+0x1d/0x3a
 [<ffffffff8129a189>] cp_rx_poll+0x2e8/0x3ab
 [<ffffffff81007414>] ? nommu_map_page+0x0/0xa0
 [<ffffffff81302308>] net_rx_action+0xa7/0x215
 [<ffffffff8103c0f9>] __do_softirq+0xcd/0x18c
 [<ffffffff81002e4c>] call_softirq+0x1c/0x28
 [<ffffffff810042c3>] do_softirq+0x33/0x68
 [<ffffffff8103bc61>] irq_exit+0x36/0x38
 [<ffffffff810039a8>] do_IRQ+0xa3/0xba
 [<ffffffff813be8d3>] ret_from_intr+0x0/0xa
 <EOI> 
 [<ffffffff810089a1>] ? default_idle+0x62/0x7a
 [<ffffffff813c1882>] ? atomic_notifier_call_chain+0x13/0x15
 [<ffffffff81001321>] cpu_idle+0x54/0xbe
 [<ffffffff813a3d49>] rest_init+0x6d/0x6f
 [<ffffffff8169cc85>] start_kernel+0x332/0x33d
 [<ffffffff8169c2a8>] x86_64_start_reservations+0xb8/0xbc
 [<ffffffff8169c39e>] x86_64_start_kernel+0xf2/0xf9
Code: 00 80 fa 04 0f 84 bb 01 00 00 80 fa 02 0f 85 c3 01 00 00 45 8b bd a0 00 00 00 4e 8d 3c 39 41 8b 47 0c 0f c8 88 45 b7 49 8b 45 20 <4c> 8b b0 40 02 00 00 4d 85 f6 0f 84 4f 01 00 00 41 8a 46 01 48 
RIP  [<ffffffff813a303e>] aun_data_available+0xb3/0x28d
 RSP <ffff88000fc03b00>
CR2: 0000000000000240
---[ end trace 8e7c904f0da8a9a0 ]---
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 0, comm: swapper Tainted: G      D     2.6.37-rc3 #39
Call Trace:
 <IRQ>  [<ffffffff813bc1b4>] panic+0x8c/0x18d
 [<ffffffff810374ff>] ? kmsg_dump+0x115/0x12f
 [<ffffffff813bf5a2>] oops_end+0x81/0x8e
 [<ffffffff81020b01>] no_context+0x1f7/0x206
 [<ffffffff81067af6>] ? handle_IRQ_event+0x52/0x117
 [<ffffffff81020c92>] __bad_area_nosemaphore+0x182/0x1a5
 [<ffffffff81069aa5>] ? handle_fasteoi_irq+0xd5/0xe0
 [<ffffffff81020cc3>] bad_area_nosemaphore+0xe/0x10
 [<ffffffff813c160a>] do_page_fault+0x1e3/0x3db
 [<ffffffff810039a8>] ? do_IRQ+0xa3/0xba
 [<ffffffff813be8d3>] ? ret_from_intr+0x0/0xa
 [<ffffffff8102c35c>] ? enqueue_task_fair+0x156/0x162
 [<ffffffff812fcb99>] ? __skb_recv_datagram+0x116/0x258
 [<ffffffff813beadf>] page_fault+0x1f/0x30
 [<ffffffff813a303e>] ? aun_data_available+0xb3/0x28d
 [<ffffffff8131d614>] ? rt_intern_hash+0x5de/0x606
 [<ffffffff812f7839>] sock_queue_rcv_skb+0x168/0x187
 [<ffffffff81325641>] ip_queue_rcv_skb+0x45/0x4c
 [<ffffffff81031aa0>] ? try_to_wake_up+0x265/0x277
 [<ffffffff8133ee23>] __udp_queue_rcv_skb+0x50/0xb9
 [<ffffffff813403b0>] udp_queue_rcv_skb+0x1ad/0x26e
 [<ffffffff81340b67>] __udp4_lib_rcv+0x30a/0x50d
 [<ffffffff81340d7f>] udp_rcv+0x15/0x17
 [<ffffffff813206b1>] ip_local_deliver+0x12d/0x1d0
 [<ffffffff81320546>] ip_rcv+0x4f2/0x530
 [<ffffffff81300fb3>] __netif_receive_skb+0x34d/0x377
 [<ffffffff81301c1d>] netif_receive_skb+0x67/0x6e
 [<ffffffff812fb763>] ? __netdev_alloc_skb+0x1d/0x3a
 [<ffffffff8129a189>] cp_rx_poll+0x2e8/0x3ab
 [<ffffffff81007414>] ? nommu_map_page+0x0/0xa0
 [<ffffffff81302308>] net_rx_action+0xa7/0x215
 [<ffffffff8103c0f9>] __do_softirq+0xcd/0x18c
 [<ffffffff81002e4c>] call_softirq+0x1c/0x28
 [<ffffffff810042c3>] do_softirq+0x33/0x68
 [<ffffffff8103bc61>] irq_exit+0x36/0x38
 [<ffffffff810039a8>] do_IRQ+0xa3/0xba
 [<ffffffff813be8d3>] ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff810089a1>] ? default_idle+0x62/0x7a
 [<ffffffff813c1882>] ? atomic_notifier_call_chain+0x13/0x15
 [<ffffffff81001321>] cpu_idle+0x54/0xbe
 [<ffffffff813a3d49>] rest_init+0x6d/0x6f
 [<ffffffff8169cc85>] start_kernel+0x332/0x33d
 [<ffffffff8169c2a8>] x86_64_start_reservations+0xb8/0xbc
 [<ffffffff8169c39e>] x86_64_start_kernel+0xf2/0xf9
