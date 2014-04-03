From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Thu, 3 Apr 2014 16:27:46 +0100
Message-ID: <20140403152746.GQ7528@n2100.arm.linux.org.uk>
References: <1396358832-15828-1-git-send-email-zhangfei.gao@linaro.org> <1396358832-15828-4-git-send-email-zhangfei.gao@linaro.org> <9532591.5yuCbpL4pV@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zhangfei Gao <zhangfei.gao@linaro.org>, davem@davemloft.net,
	f.fainelli@gmail.com, sergei.shtylyov@cogentembedded.com,
	mark.rutland@arm.com, David.Laight@aculab.com,
	eric.dumazet@gmail.com, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, devicetree@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:49620 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752304AbaDCP2W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 11:28:22 -0400
Content-Disposition: inline
In-Reply-To: <9532591.5yuCbpL4pV@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 02, 2014 at 11:21:45AM +0200, Arnd Bergmann wrote:
> - As David Laight pointed out earlier, you must also ensure that
>   you don't have too much /data/ pending in the descriptor ring
>   when you stop the queue. For a 10mbit connection, you have already
>   tested (as we discussed on IRC) that 64 descriptors with 1500 byte
>   frames gives you a 68ms round-trip ping time, which is too much.
>   Conversely, on 1gbit, having only 64 descriptors actually seems
>   a little low, and you may be able to get better throughput if
>   you extend the ring to e.g. 512 descriptors.

You don't manage that by stopping the queue - there's separate interfaces
where you report how many bytes you've queued (netdev_sent_queue()) and
how many bytes/packets you've sent (netdev_tx_completed_queue()).  This
allows the netdev schedulers to limit how much data is held in the queue,
preserving interactivity while allowing the advantages of larger rings.

> > +       phys = dma_map_single(&ndev->dev, skb->data, skb->len, DMA_TO_DEVICE);
> > +       if (dma_mapping_error(&ndev->dev, phys)) {
> > +               dev_kfree_skb(skb);
> > +               return NETDEV_TX_OK;
> > +       }
> > +
> > +       priv->tx_skb[tx_head] = skb;
> > +       priv->tx_phys[tx_head] = phys;
> > +       desc->send_addr = cpu_to_be32(phys);
> > +       desc->send_size = cpu_to_be16(skb->len);
> > +       desc->cfg = cpu_to_be32(DESC_DEF_CFG);
> > +       phys = priv->tx_desc_dma + tx_head * sizeof(struct tx_desc);
> > +       desc->wb_addr = cpu_to_be32(phys);
> 
> One detail: since you don't have cache-coherent DMA, "desc" will
> reside in uncached memory, so you try to minimize the number of accesses.
> It's probably faster if you build the descriptor on the stack and
> then atomically copy it over, rather than assigning each member at
> a time.

DMA coherent memory is write combining, so multiple writes will be
coalesced.  This also means that barriers may be required to ensure the
descriptors are pushed out in a timely manner if something like writel()
is not used in the transmit-triggering path.

-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.
