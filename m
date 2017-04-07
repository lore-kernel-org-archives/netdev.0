From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 11/12] ftgmac100: Add support for fragmented tx
Date: Sat, 08 Apr 2017 09:19:09 +1000
Message-ID: <1491607149.4166.165.camel@kernel.crashing.org>
References: <20170407033105.29558-1-benh@kernel.crashing.org>
         <20170407033105.29558-12-benh@kernel.crashing.org>
         <13383518-1602-e3e4-3ac5-4d44ac91be20@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:36641 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751221AbdDGXTR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 19:19:17 -0400
In-Reply-To: <13383518-1602-e3e4-3ac5-4d44ac91be20@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-04-07 at 06:26 -0700, Florian Fainelli wrote:
> 
> On 04/06/2017 08:31 PM, Benjamin Herrenschmidt wrote:
> > Add NETIF_F_SG and create multiple TX ring entries for skb fragments.
> > 
> > On reclaim, the skb is only freed on the segment marked as "last".
> > 
> > > > Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> > 
> 
> [snip]
> >  
> > > > -	dma_unmap_single(priv->dev, map, skb_headlen(skb), DMA_TO_DEVICE);
> > > > +		if (skb_shinfo(skb)->nr_frags == 0 && len < ETH_ZLEN)
> > +			len = ETH_ZLEN;
> 
> This is where skb_put_padto() would help you eliminate this test since
> you'd be dealing skb->len >= ETH_ZLEN.

Ok, thanks.

> > +		dma_unmap_single(priv->dev, map, len, DMA_TO_DEVICE);
> > > > +	} else {
> > > > +		dma_unmap_page(priv->dev, map,
> > > > +			       ftgmac100_txdes_get_buffer_size(txdes),
> > > > +			       DMA_TO_DEVICE);
> > > > +	}
> >  
> > > > -	dev_kfree_skb(skb);
> > > > +	if (ftgmac100_txdes_get_last_segment(txdes))
> > +		dev_kfree_skb(skb);
> 
> This makes you do an uncached access to the descriptor, right? is there
> a way you could use bookeeping information to free the last fragment?

Not a big deal, it's handled in a subsequent patch. I have to read the
descriptor first word anyway to know the packet has been completed, 
a further patch I just pass that info along to ftgmac100_free_tx_packet

> >  	priv->tx_skbs[pointer] = NULL;
> >  
> > > >  	/* Clear txdes0 except end of ring bit, clear txdes1 as we
> > @@ -623,10 +642,9 @@ static void ftgmac100_tx_complete(struct ftgmac100 *priv)
> >  static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
> > > >  				     struct net_device *netdev)
> >  {
> > > > -	unsigned int len = (skb->len < ETH_ZLEN) ? ETH_ZLEN : skb->len;
> > > >  	struct ftgmac100 *priv = netdev_priv(netdev);
> > > > -	struct ftgmac100_txdes *txdes;
> > > > -	unsigned int pointer;
> > > > +	struct ftgmac100_txdes *txdes, *first;
> > > > +	unsigned int pointer, nfrags, len, i, j;
> > > >  	dma_addr_t map;
> >  
> > > >  	/* The HW doesn't pad small frames */
> > @@ -642,26 +660,35 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
> > > >  		goto drop;
> > > >  	}
> >  
> > > > -	map = dma_map_single(priv->dev, skb->data, skb_headlen(skb), DMA_TO_DEVICE);
> > > > -	if (unlikely(dma_mapping_error(priv->dev, map))) {
> > > > -		/* drop packet */
> > > > +	/* Do we have a limit on #fragments ? I yet have to get a reply
> > > > +	 * from Aspeed. If there's one I haven't hit it.
> > > > +	 */
> > > > +	nfrags = skb_shinfo(skb)->nr_frags;
> > +
> > > > +	/* Get header len and pad for non-fragmented packets */
> > > > +	len = skb_headlen(skb);
> > > > +	if (nfrags == 0 && len < ETH_ZLEN)
> > +		len = ETH_ZLEN;
> 
> Same here skb_put_padto() would eliminate the test.

Yup, I'll fix that, thx.

> [snip]
> 
> >  
> > + dma_err:
> > > > +	if (net_ratelimit())
> > +		netdev_err(netdev, "map tx fragment failed\n");
> 
> You may consider adding a software counter that tracks mapping failures
> (few drivers do that) in a subsequent set of changes.

Ok. I want to add a bunch of SW counters for other things too so
I'll add to the list.

Cheers,
Ben.
