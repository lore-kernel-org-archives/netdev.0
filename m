From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: skb allocation from interrupt handler?
Date: Wed, 9 Aug 2017 12:04:57 -0400
Message-ID: <598B32A9.9070704@ti.com>
References: <598A3890.80705@ti.com> <1502231355.23698.5.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Matteo Croce <mcroce@redhat.com>,
        "open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx210.ext.ti.com ([198.47.19.17]:65402 "EHLO
        fllnx210.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753267AbdHIQEE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 12:04:04 -0400
In-Reply-To: <1502231355.23698.5.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/08/2017 06:29 PM, Matteo Croce wrote:
> netdev_alloc_skb() passes GFP_ATOMIC to alloc_skb() so it should work
> in an interrupt handler too.

I will provide more background on my work as response to your next 
response. This is running RT Linux kernel. I have CONFIG_IRQ_FORCED_THREADING
enabled. So my understanding is that the irq handler will be executed as
part of a kernel thread. So it is not actually from a hard irq context.
Correct? 

So what why does the following trace complains?


root@am57xx-evm:~# [  108.745031] BUG: sleeping function called from invalid context at kernel/locking/rtmutex.c:987
[  108.745035] in_atomic(): 1, irqs_disabled(): 128, pid: 0, name: swapper/0
[  108.745038] no locks held by swapper/0/0.
[  108.745040] irq event stamp: 292222
[  108.745054] hardirqs last  enabled at (292221): [<c0208eb0>] arch_cpu_idle+0x20/0x3c
[  108.745060] hardirqs last disabled at (292222): [<c020c8ac>] __irq_svc+0x4c/0xa8
[  108.745063] softirqs last  enabled at (0): [<  (null)>]   (null)
[  108.745066] softirqs last disabled at (0): [<  (null)>]   (null)
[  108.745076] Preemption disabled at:
[  108.745077] [<c0936f24>] schedule_preempt_disabled+0x1c/0x20
[  108.745084] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.9.38-rt23-02686-gc7fcc4e7-dirty #4
[  108.745087] Hardware name: Generic DRA74X (Flattened Device Tree)
[  108.745100] [<c021007c>] (unwind_backtrace) from [<c020bdcc>] (show_stack+0x10/0x14)
[  108.745111] [<c020bdcc>] (show_stack) from [<c0517780>] (dump_stack+0x98/0xc4)
[  108.745122] [<c0517780>] (dump_stack) from [<c0256a70>] (___might_sleep+0x1b8/0x2a4)
[  108.745133] [<c0256a70>] (___might_sleep) from [<c0939e80>] (rt_spin_lock+0x24/0x5c)
[  108.745143] [<c0939e80>] (rt_spin_lock) from [<c07d827c>] (__netdev_alloc_skb+0xd0/0x254)
[  108.745166] [<c07d827c>] (__netdev_alloc_skb) from [<bf23a544>] (emac_rx_hardirq+0x374/0x554 [prueth])
[  108.745212] [<bf23a544>] (emac_rx_hardirq [prueth]) from [<c02925dc>] (__handle_irq_event_percpu+0x9c/0x128)
[  108.745221] [<c02925dc>] (__handle_irq_event_percpu) from [<c02926b0>] (handle_irq_event_percpu+0x48/0x84)
[  108.745229] [<c02926b0>] (handle_irq_event_percpu) from [<c0292724>] (handle_irq_event+0x38/0x5c)
[  108.745238] [<c0292724>] (handle_irq_event) from [<c0295b1c>] (handle_level_irq+0xc4/0x16c)
[  108.745246] [<c0295b1c>] (handle_level_irq) from [<c0291880>] (generic_handle_irq+0x24/0x34)
[  108.745257] [<c0291880>] (generic_handle_irq) from [<bf214244>] (pruss_intc_irq_handler+0xdc/0x130 [pruss_intc])
[  108.745270] [<bf214244>] (pruss_intc_irq_handler [pruss_intc]) from [<c0291880>] (generic_handle_irq+0x24/0x34)
[  108.745277] [<c0291880>] (generic_handle_irq) from [<c0291de0>] (__handle_domain_irq+0x7c/0xec)
[  108.745284] [<c0291de0>] (__handle_domain_irq) from [<c020154c>] (gic_handle_irq+0x48/0x8c)
[  108.745290] [<c020154c>] (gic_handle_irq) from [<c020c8bc>] (__irq_svc+0x5c/0xa8)

Here is the code snippet. This is part of an experiment, that I will explain in
the next message where you have talked about NAPI.

	skb = netdev_alloc_skb(ndev, pkt_info.length + 2);
	if (!skb) {
		if (netif_msg_rx_err(emac) && net_ratelimit())
			netdev_err(ndev, "failed rx buffer alloc\n");
		return -ENOMEM;
	}

        <====== Code to get the packet from the firmware FIFO =====>
	/* send packet up the stack */
	skb_put(skb, pkt_info.length);
	skb->protocol = eth_type_trans(skb, ndev);
	netif_rx(skb);

	/* update stats */
	ndev->stats.rx_bytes += pkt_info.length;
	ndev->stats.rx_packets++;

Also want to know if there is a real SKB alloc function that can be used from
hard irq context.

-- 
Murali Karicheri
Linux Kernel, Keystone
