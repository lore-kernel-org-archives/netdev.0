From: Rob Herring <robherring2@gmail.com>
Subject: Re: alignment faults in 3.6
Date: Thu, 11 Oct 2012 08:20:14 -0500
Message-ID: <5076C78E.1020408@gmail.com>
References: <20121005082439.GF4625@n2100.arm.linux.org.uk>  <20121011103257.GO4625@n2100.arm.linux.org.uk>  <1349952574.21172.8604.camel@edumazet-glaptop>  <201210111228.25995.arnd@arndb.de> <1349959248.21172.8970.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>,
	linux-arm-kernel@lists.infradead.org,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Jon Masters <jonathan@jonmasters.org>, netdev@vger.kernel.org,
	=?UTF-8?B?TcOlbnMgUnVsbGfDpXJk?= <mans@mansr.com>,
	David Laight <David.Laight@aculab.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:64914 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758633Ab2JKNUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 09:20:20 -0400
Received: by mail-oa0-f46.google.com with SMTP id h16so1668384oag.19
        for <netdev@vger.kernel.org>; Thu, 11 Oct 2012 06:20:19 -0700 (PDT)
In-Reply-To: <1349959248.21172.8970.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/11/2012 07:40 AM, Eric Dumazet wrote:
> On Thu, 2012-10-11 at 12:28 +0000, Arnd Bergmann wrote:
> 
>>
>> Rob Herring as the original reporter has dropped off the Cc list, adding
>> him back.
>>
>> I assume that the calxeda xgmac driver is the culprit then. It uses
>> netdev_alloc_skb() rather than netdev_alloc_skb_ip_align() in
>> xgmac_rx_refill but it is not clear whether it does so intentionally
>> or by accident.

This in fact does work and eliminates the unaligned traps. However, not
all h/w can do IP aligned DMA (i.MX FEC for example), so I still think
this is a questionable optimization by the compiler. We're saving 1 load
instruction here for data that is likely already in the cache. It may be
legal per the ABI, but the downside of this optimization is much greater
than the upside.

> 
> Thanks Arnd
> 
> It seems an accident, since driver doesnt check skb->data alignment at
> all (this can change with SLAB debug on/off)
> 
> It also incorrectly adds 64 bytes to bfsize, there is no need for this.

I'm pretty sure this was needed as the h/w writes out full bursts of
data, but I'll go back and check.

Rob

> (or if its needed, a comment would be nice, because on prior kernels,
> this makes skb->head allocations uses kmalloc-4096 instead of
> kmalloc-2048 slab cache... With 3.7 its less an issue now we use order-3
> pages to deliver fragments for rx skbs
>
> So the following patch should fix the alignment, and makes driver uses
> half memory than before for stable kernels
> 
> diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
> index 16814b3..a895e18 100644
> --- a/drivers/net/ethernet/calxeda/xgmac.c
> +++ b/drivers/net/ethernet/calxeda/xgmac.c
> @@ -671,7 +671,8 @@ static void xgmac_rx_refill(struct xgmac_priv *priv)
>  		p = priv->dma_rx + entry;
>  
>  		if (priv->rx_skbuff[entry] == NULL) {
> -			skb = netdev_alloc_skb(priv->dev, priv->dma_buf_sz);
> +			skb = netdev_alloc_skb_ip_align(priv->dev,
> +							priv->dma_buf_sz);
>  			if (unlikely(skb == NULL))
>  				break;
>  
> @@ -703,7 +704,7 @@ static int xgmac_dma_desc_rings_init(struct net_device *dev)
>  	/* Set the Buffer size according to the MTU;
>  	 * indeed, in case of jumbo we need to bump-up the buffer sizes.
>  	 */
> -	bfsize = ALIGN(dev->mtu + ETH_HLEN + ETH_FCS_LEN + NET_IP_ALIGN + 64,
> +	bfsize = ALIGN(dev->mtu + ETH_HLEN + ETH_FCS_LEN,
>  		       64);
>  
>  	netdev_dbg(priv->dev, "mtu [%d] bfsize [%d]\n", dev->mtu, bfsize);
> 
> 
