From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Wed, 02 Apr 2014 17:49:05 +0200
Message-ID: <4698724.S4F2PxkdOH@wuerfel>
References: <1396358832-15828-1-git-send-email-zhangfei.gao@linaro.org> <9532591.5yuCbpL4pV@wuerfel> <063D6719AE5E284EB5DD2968C1650D6D0F6EE729@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Zhangfei Gao <zhangfei.gao@linaro.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux@arm.linux.org.uk" <linux@arm.linux.org.uk>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.24]:49590 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932386AbaDBPtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 11:49:14 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6EE729@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 02 April 2014 10:04:34 David Laight wrote:
> From: Arnd Bergmann
> > On Tuesday 01 April 2014 21:27:12 Zhangfei Gao wrote:
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
> I'm not sure, the writes to uncached memory will probably be
> asynchronous, but you may avoid a stall by separating the
> cycles in time.

Right.

> What you need to avoid is reads from uncached memory.
> It may well beneficial for the tx reclaim code to first
> check whether all the transmits have completed (likely)
> instead of testing each descriptor in turn.

Good point, reading from noncached memory is actually the
part that matters. For slow networks (e.g. 10mbit), checking if
all of the descriptors have finished is not quite as likely to succeed
as for fast (gbit), especially if the timeout is set to expire
before all descriptors have completed.

If it makes a lot of difference to performance, one could use
a binary search over the outstanding descriptors rather than looking
just at the last one.

> > The same would be true for the rx descriptors.
> 
> Actually it is reasonably feasible to put the rx descriptors
> in cacheable memory and to flush the cache lines after adding
> new entries.
> You just need to add the entries one cache line full at a time
> (and ensure that the rx processing code doesn't dirty the line).

rx descriptors are already using the streaming mapping, so ignore
what I said about them.

	Arnd
