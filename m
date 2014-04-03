From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Thu, 03 Apr 2014 19:57:53 +0200
Message-ID: <5153369.PcVDn1cGQl@wuerfel>
References: <1396358832-15828-1-git-send-email-zhangfei.gao@linaro.org> <9532591.5yuCbpL4pV@wuerfel> <20140403152746.GQ7528@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Zhangfei Gao <zhangfei.gao@linaro.org>, davem@davemloft.net,
	f.fainelli@gmail.com, sergei.shtylyov@cogentembedded.com,
	mark.rutland@arm.com, David.Laight@aculab.com,
	eric.dumazet@gmail.com, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, devicetree@vger.kernel.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.13]:59000 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753112AbaDCR6c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 13:58:32 -0400
In-Reply-To: <20140403152746.GQ7528@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 03 April 2014 16:27:46 Russell King - ARM Linux wrote:
> On Wed, Apr 02, 2014 at 11:21:45AM +0200, Arnd Bergmann wrote:
> > - As David Laight pointed out earlier, you must also ensure that
> >   you don't have too much /data/ pending in the descriptor ring
> >   when you stop the queue. For a 10mbit connection, you have already
> >   tested (as we discussed on IRC) that 64 descriptors with 1500 byte
> >   frames gives you a 68ms round-trip ping time, which is too much.
> >   Conversely, on 1gbit, having only 64 descriptors actually seems
> >   a little low, and you may be able to get better throughput if
> >   you extend the ring to e.g. 512 descriptors.
> 
> You don't manage that by stopping the queue - there's separate interfaces
> where you report how many bytes you've queued (netdev_sent_queue()) and
> how many bytes/packets you've sent (netdev_tx_completed_queue()).  This
> allows the netdev schedulers to limit how much data is held in the queue,
> preserving interactivity while allowing the advantages of larger rings.

Ah, I didn't know about these.  However, reading through the dql code,
it seems that will not work if the tx reclaim is triggered by a timer,
since it expects to get feedback from the actual hardware behavior. :(

I guess this is (part of) what David Miller also meant by saying it won't
ever work properly. 

> > > +       phys = dma_map_single(&ndev->dev, skb->data, skb->len, DMA_TO_DEVICE);
> > > +       if (dma_mapping_error(&ndev->dev, phys)) {
> > > +               dev_kfree_skb(skb);
> > > +               return NETDEV_TX_OK;
> > > +       }
> > > +
> > > +       priv->tx_skb[tx_head] = skb;
> > > +       priv->tx_phys[tx_head] = phys;
> > > +       desc->send_addr = cpu_to_be32(phys);
> > > +       desc->send_size = cpu_to_be16(skb->len);
> > > +       desc->cfg = cpu_to_be32(DESC_DEF_CFG);
> > > +       phys = priv->tx_desc_dma + tx_head * sizeof(struct tx_desc);
> > > +       desc->wb_addr = cpu_to_be32(phys);
> > 
> > One detail: since you don't have cache-coherent DMA, "desc" will
> > reside in uncached memory, so you try to minimize the number of accesses.
> > It's probably faster if you build the descriptor on the stack and
> > then atomically copy it over, rather than assigning each member at
> > a time.
> 
> DMA coherent memory is write combining, so multiple writes will be
> coalesced.  This also means that barriers may be required to ensure the
> descriptors are pushed out in a timely manner if something like writel()
> is not used in the transmit-triggering path.

Right, makes sense. There is a writel() right after this, so no need
for extra barriers. We already concluded that the store operation on
uncached memory isn't actually a problem, and Zhangfei Gao did some
measurements to check the overhead of the one read from uncached
memory that is in the tx path, which was lost in the noise.

	Arnd
