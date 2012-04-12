From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: smsc911x: fix RX FIFO fastforwarding when
 dropping packets
Date: Thu, 12 Apr 2012 15:06:03 +0200
Message-ID: <1334235963.5300.6361.camel@edumazet-glaptop>
References: <1334221644-16056-1-git-send-email-will.deacon@arm.com>
	 <1334222448.5300.6046.camel@edumazet-glaptop>
	 <20120412125355.GG16025@mudshark.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: Will Deacon <will.deacon@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:54180 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756590Ab2DLNGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 09:06:08 -0400
Received: by wibhr17 with SMTP id hr17so4923223wib.1
        for <netdev@vger.kernel.org>; Thu, 12 Apr 2012 06:06:07 -0700 (PDT)
In-Reply-To: <20120412125355.GG16025@mudshark.cambridge.arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-12 at 13:53 +0100, Will Deacon wrote:
> Hi Eric,
> 
> Thanks for taking a look.
> 
> On Thu, Apr 12, 2012 at 10:20:48AM +0100, Eric Dumazet wrote:
> > On Thu, 2012-04-12 at 10:07 +0100, Will Deacon wrote:
> > > diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
> > > index 4a69710..b5599bc 100644
> > > --- a/drivers/net/ethernet/smsc/smsc911x.c
> > > +++ b/drivers/net/ethernet/smsc/smsc911x.c
> > > @@ -1228,7 +1228,7 @@ static int smsc911x_poll(struct napi_struct *napi, int budget)
> > >  				  "Discarding packet with error bit set");
> > >  			/* Packet has an error, discard it and continue with
> > >  			 * the next */
> > > -			smsc911x_rx_fastforward(pdata, pktwords);
> > > +			smsc911x_rx_fastforward(pdata, pktlength);
> > >  			dev->stats.rx_dropped++;
> > >  			continue;
> > >  		}
> 
> [...]
> 
> > Hum, looking at this driver, I see wrong code in lines 1246/1247
> > 
> > skb->data = skb->head;
> > skb_reset_tail_pointer(skb);
> > 
> > I suspect its hiding a buffer overflow bug or something.
> 
> Yes, you're right.
> 
> > netdev_alloc_skb() reserved NET_SKB_PAD bytes. A driver should not
> > un-reserve this headroom, or some networking setups can be very slow.
> > 
> > So 
> > 
> > pdata->ops->rx_readfifo(pdata,
> > 	(unsigned int *)skb->head, pktwords);
> > 
> > also should be fixed to use skb->data instead.
> 
> Right, this seems to do the trick (and can replace my original patch by
> actually passing in the number of words to the fastforward function). I'm
> not sure whether the skb_trim is really required, but it makes the data
> format slightly clearer.
> 
> It would be nice to get some input from Steve, but his email address seems
> to be bouncing at the moment.
> 
> Will
> 
> 
> diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
> index 4a69710..3f43c24 100644
> --- a/drivers/net/ethernet/smsc/smsc911x.c
> +++ b/drivers/net/ethernet/smsc/smsc911x.c
> @@ -1166,10 +1166,8 @@ smsc911x_rx_counterrors(struct net_device *dev, unsigned int rxstat)
>  
>  /* Quickly dumps bad packets */
>  static void
> -smsc911x_rx_fastforward(struct smsc911x_data *pdata, unsigned int pktbytes)
> +smsc911x_rx_fastforward(struct smsc911x_data *pdata, unsigned int pktwords)
>  {
> -       unsigned int pktwords = (pktbytes + NET_IP_ALIGN + 3) >> 2;
> -
>         if (likely(pktwords >= 4)) {
>                 unsigned int timeout = 500;
>                 unsigned int val;
> @@ -1233,7 +1231,7 @@ static int smsc911x_poll(struct napi_struct *napi, int budget)
>                         continue;
>                 }
>  
> -               skb = netdev_alloc_skb(dev, pktlength + NET_IP_ALIGN);
> +               skb = netdev_alloc_skb(dev, pktwords << 2);
>                 if (unlikely(!skb)) {
>                         SMSC_WARN(pdata, rx_err,
>                                   "Unable to allocate skb for rx packet");
> @@ -1243,21 +1241,19 @@ static int smsc911x_poll(struct napi_struct *napi, int budget)
>                         break;
>                 }
>  
> -               skb->data = skb->head;
> -               skb_reset_tail_pointer(skb);
> -
> -               /* Align IP on 16B boundary */
> -               skb_reserve(skb, NET_IP_ALIGN);
> -               skb_put(skb, pktlength - 4);
> +               skb_put(skb, pktwords << 2);

You could remove this line and do it after skb_reserve() ?

>                 pdata->ops->rx_readfifo(pdata,
> -                                (unsigned int *)skb->head, pktwords);
> +                                (unsigned int *)skb->data, pktwords);
> +               skb_pull(skb, NET_IP_ALIGN);

		skb_reserve(skb, NET_IP_ALIGN);
		skb_put(skb, pktlength - 4);

> +               skb_trim(skb, pktlength);

and remove this skb_trim()

> +
>                 skb->protocol = eth_type_trans(skb, dev);
>                 skb_checksum_none_assert(skb);
>                 netif_receive_skb(skb);
>  
>                 /* Update counters */
>                 dev->stats.rx_packets++;
> -               dev->stats.rx_bytes += (pktlength - 4);
> +               dev->stats.rx_bytes += pktlength;
	
	Some drivers account for the FCS, some dont, I guess you can leave the
line as is

>         }
>  
>         /* Return total received packets */
> @@ -1565,7 +1561,7 @@ static int smsc911x_open(struct net_device *dev)
>         smsc911x_reg_write(pdata, FIFO_INT, temp);
>  
>         /* set RX Data offset to 2 bytes for alignment */
> -       smsc911x_reg_write(pdata, RX_CFG, (2 << 8));
> +       smsc911x_reg_write(pdata, RX_CFG, (NET_IP_ALIGN << 8));

	Good ;)

>  
>         /* enable NAPI polling before enabling RX interrupts */
>         napi_enable(&pdata->napi);
> 

Thanks
