From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Wed, 02 Apr 2014 17:24:24 +0200
Message-ID: <4242558.6NaQec4f7j@wuerfel>
References: <1396358832-15828-1-git-send-email-zhangfei.gao@linaro.org> <9532591.5yuCbpL4pV@wuerfel> <533BDDBA.1060800@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: zhangfei <zhangfei.gao@linaro.org>, mark.rutland@arm.com,
	devicetree@vger.kernel.org, f.fainelli@gmail.com,
	linux@arm.linux.org.uk, eric.dumazet@gmail.com,
	sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
	David.Laight@aculab.com, davem@davemloft.net
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.13]:50849 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758804AbaDBPZA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 11:25:00 -0400
In-Reply-To: <533BDDBA.1060800@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 02 April 2014 17:51:54 zhangfei wrote:
> Dear Arnd
> 
> On 04/02/2014 05:21 PM, Arnd Bergmann wrote:
> > On Tuesday 01 April 2014 21:27:12 Zhangfei Gao wrote:
> >> +static int hip04_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
> >
> > While it looks like there are no serious functionality bugs left, this
> > function is rather inefficient, as has been pointed out before:
> 
> Yes, still need more performance tuning in the next step.
> We need to enable the hardware feature of cache flush, under help of 
> arm-smmu, as a result dma_map_single etc can be removed.

You cannot remove the dma_map_single call here, but the implementation
of that function will be different when you use the iommu_coherent_ops:
Instead of flushing the caches, it will create or remove an iommu entry
and return the bus address.

I remember you mentioned before that using the iommu on this particular
SoC actually gives you cache-coherent DMA, so you may also be able
to use arm_coherent_dma_ops if you can set up a static 1:1 mapping 
between bus and phys addresses.

> >> +{
> >> +       struct hip04_priv *priv = netdev_priv(ndev);
> >> +       struct net_device_stats *stats = &ndev->stats;
> >> +       unsigned int tx_head = priv->tx_head;
> >> +       struct tx_desc *desc = &priv->tx_desc[tx_head];
> >> +       dma_addr_t phys;
> >> +
> >> +       hip04_tx_reclaim(ndev, false);
> >> +       mod_timer(&priv->txtimer, jiffies + RECLAIM_PERIOD);
> >> +
> >> +       if (priv->tx_count >= TX_DESC_NUM) {
> >> +               netif_stop_queue(ndev);
> >> +               return NETDEV_TX_BUSY;
> >> +       }
> >
> > This is where you have two problems:
> >
> > - if the descriptor ring is full, you wait for RECLAIM_PERIOD,
> >    which is far too long at 500ms, because during that time you
> >    are not able to add further data to the stopped queue.
> 
> Understand
> The idea here is not using the timer as much as possible.
> As experiment shows, only xmit reclaim buffers, the best throughput can 
> be achieved.

I'm only talking about the case where that doesn't work: once you stop
the queue, the xmit function won't get called again until the timer
causes the reclaim be done and restart the queue.

> > - As David Laight pointed out earlier, you must also ensure that
> >    you don't have too much /data/ pending in the descriptor ring
> >    when you stop the queue. For a 10mbit connection, you have already
> >    tested (as we discussed on IRC) that 64 descriptors with 1500 byte
> >    frames gives you a 68ms round-trip ping time, which is too much.
> 
> When iperf & ping running together and only ping, it is 0.7 ms.
> 
> >    Conversely, on 1gbit, having only 64 descriptors actually seems
> >    a little low, and you may be able to get better throughput if
> >    you extend the ring to e.g. 512 descriptors.
> 
> OK, Will check throughput of upgrade xmit descriptors.
> But is it said not using too much descripors for xmit since no xmit 
> interrupt?

The important part is to limit the time that data spends in the queue,
which is a function of the interface tx speed and the number of bytes
in the queue.

> >> +       phys = dma_map_single(&ndev->dev, skb->data, skb->len, DMA_TO_DEVICE);
> >> +       if (dma_mapping_error(&ndev->dev, phys)) {
> >> +               dev_kfree_skb(skb);
> >> +               return NETDEV_TX_OK;
> >> +       }
> >> +
> >> +       priv->tx_skb[tx_head] = skb;
> >> +       priv->tx_phys[tx_head] = phys;
> >> +       desc->send_addr = cpu_to_be32(phys);
> >> +       desc->send_size = cpu_to_be16(skb->len);
> >> +       desc->cfg = cpu_to_be32(DESC_DEF_CFG);
> >> +       phys = priv->tx_desc_dma + tx_head * sizeof(struct tx_desc);
> >> +       desc->wb_addr = cpu_to_be32(phys);
> >
> > One detail: since you don't have cache-coherent DMA, "desc" will
> > reside in uncached memory, so you try to minimize the number of accesses.
> > It's probably faster if you build the descriptor on the stack and
> > then atomically copy it over, rather than assigning each member at
> > a time.
> 
> I am sorry, not quite understand, could you clarify more?
> The phys and size etc of skb->data is changing, so need to assign.
> If member contents keep constant, it can be set when initializing.

I meant you should use 64-bit accesses here instead of multiple 32 and
16 bit accesses, but as David noted, it's actually not that much of
a deal for the writes as it is for the reads from uncached memory.

The important part is to avoid the line where you do 'if (desc->send_addr
!= 0)' as much as possible.

	Arnd
