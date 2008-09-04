From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 2/2] mv643xx_eth: hook up skb recycling
Date: Thu, 4 Sep 2008 06:20:05 +0200
Message-ID: <20080904042005.GA27272@xi.wantstofly.org>
References: <1220450101-21317-1-git-send-email-buytenh@wantstofly.org> <1220450101-21317-3-git-send-email-buytenh@wantstofly.org> <48BE9E5E.2010702@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dale@farnsworth.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:37882 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002AbYIDEUH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 00:20:07 -0400
Content-Disposition: inline
In-Reply-To: <48BE9E5E.2010702@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 03, 2008 at 04:25:34PM +0200, Eric Dumazet wrote:

> >This increases the maximum loss-free packet forwarding rate in
> >routing workloads by typically about 25%.
> >
> >Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> 
> Interesting...
> 
> > 	refilled = 0;
> > 	while (refilled < budget && rxq->rx_desc_count < rxq->rx_ring_size) {
> > 		struct sk_buff *skb;
> > 		int unaligned;
> > 		int rx;
> > 
> >-		skb = dev_alloc_skb(skb_size + dma_get_cache_alignment() - 
> >1);
> >+		skb = __skb_dequeue(&mp->rx_recycle);
> 
> Here you take one skb at the head of queue
> 
> >+		if (skb == NULL)
> >+			skb = dev_alloc_skb(mp->skb_size +
> >+					    dma_get_cache_alignment() - 1);
> >+
> > 		if (skb == NULL) {
> > 			mp->work_rx_oom |= 1 << rxq->index;
> > 			goto oom;
> >@@ -600,8 +591,8 @@ static int rxq_refill(struct rx_queue *rxq, int budget)
> > 			rxq->rx_used_desc = 0;
> > 
> > 		rxq->rx_desc_area[rx].buf_ptr = dma_map_single(NULL, 
> > 		skb->data,
> >-						skb_size, DMA_FROM_DEVICE);
> >-		rxq->rx_desc_area[rx].buf_size = skb_size;
> >+						mp->skb_size, 
> >DMA_FROM_DEVICE);
> >+		rxq->rx_desc_area[rx].buf_size = mp->skb_size;
> > 		rxq->rx_skb[rx] = skb;
> > 		wmb();
> > 		rxq->rx_desc_area[rx].cmd_sts = BUFFER_OWNED_BY_DMA |
> >@@ -905,8 +896,13 @@ static int txq_reclaim(struct tx_queue *txq, int 
> >budget, int force)
> > 		else
> > 			dma_unmap_page(NULL, addr, count, DMA_TO_DEVICE);
> > 
> >-		if (skb)
> >-			dev_kfree_skb(skb);
> >+		if (skb != NULL) {
> >+			if (skb_queue_len(&mp->rx_recycle) < 1000 &&
> >+			    skb_recycle_check(skb, mp->skb_size))
> >+				__skb_queue_tail(&mp->rx_recycle, skb);
> >+			else
> >+				dev_kfree_skb(skb);
> >+		}
> 
> Here you put a skb at the head of queue. So you use a FIFO mode.
> 
> To have best performance (cpu cache hot), you might try to use a LIFO mode 
> (use __skb_queue_head()) ?

That sounds like a good idea.  I'll try that, thanks.


> Could you give us your actual bench results (number of packets received per 
> second, number of transmited packets per second), and your machine setup.

mv643xx_eth isn't your typical PCI network adapter, it's a silicon
block that is found in PPC/MIPS northbridges and in ARM System-on-Chips
(SoC = CPU + peripherals integrated in one chip).

The particular platform I did these tests on is a wireless access
point.  It has an ARM SoC running at 1.2 GHz, with relatively small
(16K/16K) L1 caches, 256K of L2 cache, and DDR2-400 memory, and a
hardware switch chip.  Networking is hooked up as follows:

	+-----------+       +-----------+
	|           |       |           |
	|           |       |           +------ 1000baseT MDI ("WAN")
	|           | RGMII |  6-port   +------ 1000baseT MDI ("LAN1")
	|    CPU    +-------+  ethernet +------ 1000baseT MDI ("LAN2")
	|           |       |  switch   +------ 1000baseT MDI ("LAN3")
	|           |       |  w/5 PHYs +------ 1000baseT MDI ("LAN4")
	|           |       |           |
	+-----------+       +-----------+

The protocol that the ethernet switch speaks is called DSA
("Distributed Switch Architecture"), which is basically just ethernet
with a header that's inserted between the ethernet header and the data
(just like 802.1q VLAN tags) telling the switch what to do with the
packet.  (I hope to submit the DSA driver I am writing soon.)  But for
these purposes of this test, the switch chip is in pass-through mode,
where DSA tagging is not used and the switch behaves like an ordinary
6-port ethernet chip.

The network benchmarks are done with a Smartbits 600B traffic
generator/measurement device.  What it does is a bisection search of
sending traffic at different packet-per-second rates to pin down the
maximum loss-free forwarding rate, i.e. the maximum packet rate at
which there is still no packet loss.

My notes say that before recycling (i.e. with all the mv643xx_eth
patches I posted yesterday), the typical rate was 191718 pps, and
after, 240385 pps.  The 2.6.27 version of the driver gets ~130kpps.
(The different injection rates are achieved by varying the inter-packet
gap at byte granularities, so you don't get nice round numbers.)

Those measurements were made more than a week ago, though, and my
mv643xx_eth patch stack has seen a lot of splitting and reordering and
recombining and rewriting since then, so I'm not sure if those numbers
are accurate anymore.  I'll do some more benchmarks when I get access
to the smartbits again.  Also, I'll get TX vs. RX curves if you care
about those.

(The same hardware has been seen to do ~300 kpps or ~380 kpps or ~850
kpps depending on how much of the networking stack you bypass, but I'm
trying to find ways to optimise the routing throughput without
bypassing the stack, i.e. while retaining full functionality.)
