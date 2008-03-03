From: Blaschka <frank.blaschka@de.ibm.com>
Subject: [PATCH] race in generic address resolution
Date: Mon, 3 Mar 2008 14:13:44 +0100
Message-ID: <20080303131344.GA13659@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ben.thery@gmail.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:15755 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809AbYCCNNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 08:13:47 -0500
Received: from d12nrmr1507.megacenter.de.ibm.com (d12nrmr1507.megacenter.de.ibm.com [9.149.167.1])
	by mtagate7.de.ibm.com (8.13.8/8.13.8) with ESMTP id m23DDjN2123374
	for <netdev@vger.kernel.org>; Mon, 3 Mar 2008 13:13:45 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1507.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m23DDjpr1818854
	for <netdev@vger.kernel.org>; Mon, 3 Mar 2008 14:13:45 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m23DDjsK023480
	for <netdev@vger.kernel.org>; Mon, 3 Mar 2008 13:13:45 GMT
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

to fix this issue I tried your suggestion to copy the skb. I did not
see problems so far. This time we tested IPv6 also. Sorry we missed IPv6
the last time.

    <2>kernel BUG at /home/autobuild/BUILD/linux-2.6.23-20080125/net/core/skbuff.c:648!
    <4>illegal operation: 0001 [#1] PREEMPT SMP
     ....
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

From: Frank Blaschka <frank.blaschka@de.ibm.com>

neigh_update sends skb from neigh->arp_queue while
neigh_timer_handler has increased skbs refcount and calls
solicit with the skb. neigh_timer_handler should not increase skbs
refcount but make a copy of the skb and do solicit with the copy.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 net/core/neighbour.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: git_davem/net/core/neighbour.c
===================================================================
--- git_davem.orig/net/core/neighbour.c	2008-02-29 10:31:14.000000000 +0100
+++ git_davem/net/core/neighbour.c	2008-02-29 10:33:28.000000000 +0100
@@ -839,7 +839,7 @@
 		struct sk_buff *skb = skb_peek(&neigh->arp_queue);
 		/* keep skb alive even if arp_queue overflows */
 		if (skb)
-			skb_get(skb);
+			skb = skb_copy(skb, GFP_ATOMIC);
 		write_unlock(&neigh->lock);
 		neigh->ops->solicit(neigh, skb);
 		atomic_inc(&neigh->probes);

