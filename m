From: Blaschka <frank.blaschka@de.ibm.com>
Subject: [PATCH][RFC] race in generic address resolution
Date: Mon, 4 Feb 2008 15:27:17 +0100
Message-ID: <20080204142717.GA11020@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:13535 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833AbYBDO1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 09:27:22 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id m14ERLJ6373288
	for <netdev@vger.kernel.org>; Mon, 4 Feb 2008 14:27:21 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m14ERLHY1241262
	for <netdev@vger.kernel.org>; Mon, 4 Feb 2008 15:27:21 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m14ERKWq013868
	for <netdev@vger.kernel.org>; Mon, 4 Feb 2008 15:27:20 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm running a SMP maschine (2 CPUs) configured as a router. During heavy
traffic kernel dies with following message: 

    <2>kernel BUG at /home/autobuild/BUILD/linux-2.6.23-20080125/net/core/skbuff.c:648!
    <4>illegal operation: 0001 [#1] PREEMPT SMP
    <4>Modules linked in: dm_multipath sunrpc dm_mod qeth_l3 vmur vmcp qeth_l2 qeth ccwgroup
    <4>CPU: 1 Not tainted 2.6.23-26.x.20080125-s390xdefault #1
    <4>Process swapper (pid: 0, task: 000000001ff80bb8, ksp: 000000001ff8dd98)
    <4>Krnl PSW : 0704100180000000 000000000034877e (pskb_expand_head+0x3a/0x210)
    <4>           R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:0 CC:1 PM:0 EA:3
    <4>Krnl GPRS: 0000000000000000 0000000000000100 000000001b2b9200 0000000000000000
    <4>           00000000000022be 0000000000000020 000000001acc0301 00000000000022e0
    <4>           00000000000022e0 0000000000000001 0000000000000000 000000001b2b9200
    <4>           000000001b2b9200 0000000000444e08 000000001ff5fa38 000000001ff5f9e8
    <4>Krnl Code: 0000000000348770: d503d01020cc        clc     16(4,%r13),204(%r2)
    <4>           0000000000348776: a7840004            brc     8,34877e
    <4>           000000000034877a: a7f40001            brc     15,34877c
    <4>          >000000000034877e: 18b1                lr      %r11,%r1
    <4>           0000000000348780: 1aba                ar      %r11,%r10
    <4>           0000000000348782: 1ab4                ar      %r11,%r4
    <4>           0000000000348784: a7ba00ff            ahi     %r11,255
    <4>           0000000000348788: a5b7ff00            nill    %r11,65280
    <4>Call Trace:
    <4>([<070000001fb96000>] 0x70000001fb96000)
    <4> [<0000000000348c08>] __pskb_pull_tail+0x2b4/0x38c
    <4> [<0000000000352e62>] dev_queue_xmit+0x1a6/0x310
    <4> [<0000000000357b98>] neigh_update+0x314/0x524
    <4> [<00000000003a11d6>] arp_process+0x2be/0x6f8
    <4> [<00000000003a1708>] arp_rcv+0xf8/0x184
    <4> [<000000000034f840>] netif_receive_skb+0x244/0x338
    <4> [<0000000000352296>] process_backlog+0xc2/0x1a8
    <4> [<0000000000352416>] net_rx_action+0x9a/0x154
    <4> [<0000000000136ba4>] __do_softirq+0x98/0x12c
    <4> [<00000000001106b0>] do_softirq+0xac/0xb0
    <4> [<0000000000136d94>] irq_exit+0x8c/0x90
    <4> [<00000000002e62dc>] do_IRQ+0x108/0x18c
    <4> [<0000000000113f10>] io_return+0x0/0x10
    <4> [<000000000010a6f0>] cpu_idle+0x21c/0x23c
    <4>([<000000000010a6a4>] cpu_idle+0x1d0/0x23c)
    <4> [<00000000001168e6>] start_secondary+0x9e/0xac
    <4> [<0000000000000000>] 0x0
    <4> [<0000000000000000>] 0x0
    <4>
    <4> <0>Kernel panic - not syncing: Fatal exception in interrupt
    <4>

Following patch fixes the problem but I do not know if it is a good sollution.

From: Frank Blaschka <frank.blaschka@de.ibm.com>

neigh_update sends skb from neigh->arp_queue while
neigh_timer_handler has increased skbs refcount and calls
solicit with the skb. Do not send neighbour skbs
marked for solicit (skb_shared).

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 net/core/neighbour.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: git_linus/net/core/neighbour.c
===================================================================
--- git_linus.orig/net/core/neighbour.c	2008-01-31 12:59:57.000000000 +0100
+++ git_linus/net/core/neighbour.c	2008-01-31 13:00:25.000000000 +0100
@@ -1060,7 +1060,8 @@
 			/* On shaper/eql skb->dst->neighbour != neigh :( */
 			if (skb->dst && skb->dst->neighbour)
 				n1 = skb->dst->neighbour;
-			n1->output(skb);
+			if (!skb_shared(skb))
+				n1->output(skb);
 			write_lock_bh(&neigh->lock);
 		}
 		skb_queue_purge(&neigh->arp_queue);

