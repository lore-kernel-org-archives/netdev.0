From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH] net: smsc911x: fix RX FIFO fastforwarding when dropping
 packets
Date: Thu, 12 Apr 2012 14:47:57 +0100
Message-ID: <20120412134757.GH16025@mudshark.cambridge.arm.com>
References: <1334221644-16056-1-git-send-email-will.deacon@arm.com>
 <1334222448.5300.6046.camel@edumazet-glaptop>
 <20120412125355.GG16025@mudshark.cambridge.arm.com>
 <1334235963.5300.6361.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([217.140.96.50]:60741 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933741Ab2DLNsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 09:48:00 -0400
Content-Disposition: inline
In-Reply-To: <1334235963.5300.6361.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 12, 2012 at 02:06:03PM +0100, Eric Dumazet wrote:
> On Thu, 2012-04-12 at 13:53 +0100, Will Deacon wrote:
> > diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
> > index 4a69710..3f43c24 100644
> > --- a/drivers/net/ethernet/smsc/smsc911x.c
> > +++ b/drivers/net/ethernet/smsc/smsc911x.c
> > @@ -1166,10 +1166,8 @@ smsc911x_rx_counterrors(struct net_device *dev, unsigned int rxstat)

[...]

> > -               skb->data = skb->head;
> > -               skb_reset_tail_pointer(skb);
> > -
> > -               /* Align IP on 16B boundary */
> > -               skb_reserve(skb, NET_IP_ALIGN);
> > -               skb_put(skb, pktlength - 4);
> > +               skb_put(skb, pktwords << 2);
> 
> You could remove this line and do it after skb_reserve() ?
> 
> >                 pdata->ops->rx_readfifo(pdata,
> > -                                (unsigned int *)skb->head, pktwords);
> > +                                (unsigned int *)skb->data, pktwords);
> > +               skb_pull(skb, NET_IP_ALIGN);
> 
> 		skb_reserve(skb, NET_IP_ALIGN);

I don't think we want an skb_reserve at all, since the hardware shifts the
data in the RX FIFO, meaning that we will read two bytes of 0 anyway before
valid data.

> 		skb_put(skb, pktlength - 4);

I can move the put here if you like, but we need to use pktwords << 2 to
make sure that we read the leading and trailing zeroes inserted by the
hardware.

> > +               skb_trim(skb, pktlength);
> 
> and remove this skb_trim()

Can do, just thought it might help illustrate that we might have some padding
at the end.

> >                 /* Update counters */
> >                 dev->stats.rx_packets++;
> > -               dev->stats.rx_bytes += (pktlength - 4);
> > +               dev->stats.rx_bytes += pktlength;
> 	
> 	Some drivers account for the FCS, some dont, I guess you can leave the
> line as is

Sure.

Thanks for the comments,

Will
