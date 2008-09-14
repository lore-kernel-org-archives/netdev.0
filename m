From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 2/2] mv643xx_eth: hook up skb recycling
Date: Sun, 14 Sep 2008 21:30:33 +0200
Message-ID: <20080914193033.GH28798@xi.wantstofly.org>
References: <1220450101-21317-1-git-send-email-buytenh@wantstofly.org> <1220450101-21317-3-git-send-email-buytenh@wantstofly.org> <48BE9E5E.2010702@cosmosbay.com> <20080904042005.GA27272@xi.wantstofly.org> <48BF690E.7090501@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Dale Farnsworth <dale@farnsworth.org>,
	Ashish Karkare <akarkare@marvell.com>,
	Nicolas Pitre <nico@cam.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:40357 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753385AbYINTah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2008 15:30:37 -0400
Content-Disposition: inline
In-Reply-To: <48BF690E.7090501@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 04, 2008 at 06:50:22AM +0200, Eric Dumazet wrote:

> >>>This increases the maximum loss-free packet forwarding rate in
> >>>routing workloads by typically about 25%.
> >>>
> >>>Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> >>Interesting...
> >>
> >>>	refilled = 0;
> >>>	while (refilled < budget && rxq->rx_desc_count < rxq->rx_ring_size) {
> >>>		struct sk_buff *skb;
> >>>		int unaligned;
> >>>		int rx;
> >>>
> >>>-		skb = dev_alloc_skb(skb_size + dma_get_cache_alignment() - 
> >>>1);
> >>>+		skb = __skb_dequeue(&mp->rx_recycle);
> >>Here you take one skb at the head of queue
> >>
> >>>+		if (skb == NULL)
> >>>+			skb = dev_alloc_skb(mp->skb_size +
> >>>+					    dma_get_cache_alignment() - 1);
> >>>+
> >>>		if (skb == NULL) {
> >>>			mp->work_rx_oom |= 1 << rxq->index;
> >>>			goto oom;
> >>>@@ -600,8 +591,8 @@ static int rxq_refill(struct rx_queue *rxq, int 
> >>>budget)
> >>>			rxq->rx_used_desc = 0;
> >>>
> >>>		rxq->rx_desc_area[rx].buf_ptr = dma_map_single(NULL, 
> >>>		skb->data,
> >>>-						skb_size, DMA_FROM_DEVICE);
> >>>-		rxq->rx_desc_area[rx].buf_size = skb_size;
> >>>+						mp->skb_size, 
> >>>DMA_FROM_DEVICE);
> >>>+		rxq->rx_desc_area[rx].buf_size = mp->skb_size;
> >>>		rxq->rx_skb[rx] = skb;
> >>>		wmb();
> >>>		rxq->rx_desc_area[rx].cmd_sts = BUFFER_OWNED_BY_DMA |
> >>>@@ -905,8 +896,13 @@ static int txq_reclaim(struct tx_queue *txq, int 
> >>>budget, int force)
> >>>		else
> >>>			dma_unmap_page(NULL, addr, count, DMA_TO_DEVICE);
> >>>
> >>>-		if (skb)
> >>>-			dev_kfree_skb(skb);
> >>>+		if (skb != NULL) {
> >>>+			if (skb_queue_len(&mp->rx_recycle) < 1000 &&
> >>>+			    skb_recycle_check(skb, mp->skb_size))
> >>>+				__skb_queue_tail(&mp->rx_recycle, skb);
> >>>+			else
> >>>+				dev_kfree_skb(skb);
> >>>+		}
> >>Here you put a skb at the head of queue. So you use a FIFO mode.
> 
> Here, I meant "tail of queue", you obviously already corrected this :) 

Yep. :)


> >>To have best performance (cpu cache hot), you might try to use a LIFO 
> >>mode (use __skb_queue_head()) ?
> >
> >That sounds like a good idea.  I'll try that, thanks.
> >
> >
> >>Could you give us your actual bench results (number of packets received 
> >>per second, number of transmited packets per second), and your machine 
> >>setup.
> >
> >mv643xx_eth isn't your typical PCI network adapter, it's a silicon
> >block that is found in PPC/MIPS northbridges and in ARM System-on-Chips
> >(SoC = CPU + peripherals integrated in one chip).
> >
> >The particular platform I did these tests on is a wireless access
> >point.  It has an ARM SoC running at 1.2 GHz, with relatively small
> >(16K/16K) L1 caches, 256K of L2 cache, and DDR2-400 memory, and a
> >hardware switch chip.  Networking is hooked up as follows:
> >
> >	+-----------+       +-----------+
> >	|           |       |           |
> >	|           |       |           +------ 1000baseT MDI ("WAN")
> >	|           | RGMII |  6-port   +------ 1000baseT MDI ("LAN1")
> >	|    CPU    +-------+  ethernet +------ 1000baseT MDI ("LAN2")
> >	|           |       |  switch   +------ 1000baseT MDI ("LAN3")
> >	|           |       |  w/5 PHYs +------ 1000baseT MDI ("LAN4")
> >	|           |       |           |
> >	+-----------+       +-----------+
> >
> >The protocol that the ethernet switch speaks is called DSA
> >("Distributed Switch Architecture"), which is basically just ethernet
> >with a header that's inserted between the ethernet header and the data
> >(just like 802.1q VLAN tags) telling the switch what to do with the
> >packet.  (I hope to submit the DSA driver I am writing soon.)  But for
> >these purposes of this test, the switch chip is in pass-through mode,
> >where DSA tagging is not used and the switch behaves like an ordinary
> >6-port ethernet chip.
> >
> >The network benchmarks are done with a Smartbits 600B traffic
> >generator/measurement device.  What it does is a bisection search of
> >sending traffic at different packet-per-second rates to pin down the
> >maximum loss-free forwarding rate, i.e. the maximum packet rate at
> >which there is still no packet loss.
> >
> >My notes say that before recycling (i.e. with all the mv643xx_eth
> >patches I posted yesterday), the typical rate was 191718 pps, and
> >after, 240385 pps.  The 2.6.27 version of the driver gets ~130kpps.
> >(The different injection rates are achieved by varying the inter-packet
> >gap at byte granularities, so you don't get nice round numbers.)
> >
> >Those measurements were made more than a week ago, though, and my
> >mv643xx_eth patch stack has seen a lot of splitting and reordering and
> >recombining and rewriting since then, so I'm not sure if those numbers
> >are accurate anymore.  I'll do some more benchmarks when I get access
> >to the smartbits again.  Also, I'll get TX vs. RX curves if you care
> >about those.
> >
> >(The same hardware has been seen to do ~300 kpps or ~380 kpps or ~850
> >kpps depending on how much of the networking stack you bypass, but I'm
> >trying to find ways to optimise the routing throughput without
> >bypassing the stack, i.e. while retaining full functionality.)
> 
> Thanks a lot for this detailed informations, definitly usefull !
>
> As a slide note, you have an arbitrary long limit on rx_recycle queue 
> length (1000), maybe you could use rx_ring_size instead.

I've been trying this as well.  (Sorry for the delay in getting back
to you about this.)

One thing that has made testing all of this nontrivial is that when
you get to the level where single cache misses have visible effects on
performance, e.g. deleting some code from a function (which is supposed
to then speed things up or keep performance the same) can actually drop
your routing performance by 20kpps or more due to causing a hot function
that comes before this function in the kernel text and a hot function
that comes after this function in the kernel text to now conflict in
the Icache (i.e. occupy the same addresses modulo the cache way size)
while they didn't before.

The patch below is a hacky (workload-dependent) way of working around
this, by making sure that several hot functions involved in routing are
laid out sequentially in the kernel text, preventing the possibility of
them pushing each other out of the Icache (ignore the --gc-sections in
the patch -- it doesn't make a difference).  The official Marvell
patchkits for Linux support for their ARM SoCs have been doing something
like this for a pretty long time now, so this trick is pretty old.


I redid the benchmarks with the function reordering applied, plus a
patch that checks received packets in the mv643xx_eth driver to see
if they have an ethernet header that matches the one from the packet
generator, and if yes, replaces the header and sends the packet out
again (to cut the IP stack out of the loop so that that doesn't affect
the measurements).

For each of combination of {50,1000} entry skb recycle queue limit
and inserting recycled skbs at the {head,tail} of the recycle queue,
I did five trials of measuring maximum loss-free forwarding rate in
packets per second:
- insert skb at tail of recycle list, 1000 entries max
  - 411184 411184 411184 405844 405844
- insert skb at tail of recycle list, 50 entries max
  - 411184 411184 411184 411184 411184
- insert skb at head of recycle list, 1000 entries max
  - 428082 422297 428082 428082 422297
- insert skb at head of recycle list, 50 entries max
  - 422297 422297 422297 422297 422297

That shows that:
- Inserting skbuffs at the head of the queue is a win.
- Not limiting the recycle queue to less than the receive ring size is
  a slight win (I'll use the receive ring size as the limit), but there
  doesn't seem to be a loss from setting the queue size higher than that.

In contrast, five pps trials without recycling:
- 322165 322165 336022 343407 332447

So skb recycling improves routing performance by about 30% (~100 kpps).

Given that, and the fact that the patch that adds skb_recycle_check()
isn't really intrusive, I was hoping that it could be considered for
inclusion.  Even if it helps only on constrained systems[*], it helps
a lot on those systems.


[*] Although this 1.2 GHz ARM CPU is probably one of the fastest ARM
    CPUs (if not the fastest ARM CPU) out there.



diff --git a/arch/arm/Makefile b/arch/arm/Makefile
index 703a44f..da19608 100644
--- a/arch/arm/Makefile
+++ b/arch/arm/Makefile
@@ -27,6 +27,9 @@ ifeq ($(CONFIG_MMU),)
 MMUEXT		:= -nommu
 endif
 
+KBUILD_CFLAGS	+= -ffunction-sections
+LINKFLAGS	+= --gc-sections
+
 ifeq ($(CONFIG_FRAME_POINTER),y)
 KBUILD_CFLAGS	+=-fno-omit-frame-pointer -mapcs -mno-sched-prolog
 endif
diff --git a/arch/arm/kernel/vmlinux.lds.S b/arch/arm/kernel/vmlinux.lds.S
index 4898bdc..0bad3b6 100644
--- a/arch/arm/kernel/vmlinux.lds.S
+++ b/arch/arm/kernel/vmlinux.lds.S
@@ -92,6 +92,51 @@ SECTIONS
 			*(.exception.text)
 			__exception_text_end = .;
 			TEXT_TEXT
+*(.text.feroceon_l2_inv_range)
+*(.text.dma_cache_maint)
+*(.text.rxq_process)
+*(.text.ip_rcv)
+*(.text.__memzero)
+*(.text.mv643xx_eth_xmit)
+*(.text.netif_receive_skb)
+*(.text.ip_route_input)
+*(.text.dev_queue_xmit)
+*(.text.ip_forward)
+*(.text.eth_type_trans)
+*(.text.rxq_refill)
+*(.text.__qdisc_run)
+*(.text.skb_recycle_check)
+*(.text.txq_reclaim)
+*(.text.ip_finish_output)
+*(.text.feroceon_l2_clean_range)
+*(.text.memcpy)
+*(.text.pfifo_fast_enqueue)
+*(.text.skb_release_head_state)
+*(.text.skb_put)
+*(.text.pfifo_fast_dequeue)
+*(.text.ip_output)
+*(.text.dev_hard_start_xmit)
+*(.text.mv643xx_eth_poll)
+*(.text.local_bh_enable)
+*(.text.feroceon_range_dma_clean_range)
+*(.text.__kmalloc)
+*(.text.skb_release_data)
+*(.text.__alloc_skb)
+*(.text.skb_pull)
+*(.text.__kfree_skb)
+*(.text.txq_enable)
+*(.text.dst_release)
+*(.text.feroceon_range_dma_inv_range)
+*(.text.txq_alloc_desc_index)
+*(.text.skb_push)
+*(.text.kmem_cache_alloc)
+*(.text.local_bh_disable)
+*(.text.dev_alloc_skb)
+*(.text.mv643xx_eth_collect_events)
+*(.text.net_rx_action)
+*(.text.kfree)
+*(.text.skb_release_all)
+*(.text.skb_clone)
 			SCHED_TEXT
 			LOCK_TEXT
 			KPROBES_TEXT
