From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2.6.29 02/14] gianfar: Fix skb allocation error
Date: Tue, 16 Dec 2008 15:28:15 -0800 (PST)
Message-ID: <20081216.152815.55433113.davem@davemloft.net>
References: <1229469667-25002-1-git-send-email-afleming@freescale.com>
	<1229469667-25002-2-git-send-email-afleming@freescale.com>
	<1229469667-25002-3-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, galak@kernel.crashing.org, netdev@vger.kernel.org
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52187
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759303AbYLPX2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 18:28:13 -0500
In-Reply-To: <1229469667-25002-3-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Tue, 16 Dec 2008 17:20:55 -0600

> We don't want to unmap the skb if we've decided to use the old one, so we only
> unmap it if we're *not* using the old one.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>

This does not apply to net-next-2.6, the code in this area doesn't
look anything like the context in this patch.  What are you
generating this against?

> @@ -1659,8 +1659,7 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
>  
>  			if (unlikely(!newskb))
>  				newskb = skb;
> -
> -			if (skb) {
> +			else if (skb) {
>  				dma_unmap_single(&priv->dev->dev,
>  						bdp->bufPtr,
>  						priv->rx_buffer_size,

That code reads:

			if (unlikely(!newskb))
				newskb = skb;

			if (skb)
				dev_kfree_skb_any(skb);

in my tree and the dma_unmap_single() is unconditionally executed
further up before the:

		/* We drop the frame if we failed to allocate a new buffer */
		if (unlikely(!newskb || !(bdp->status & RXBD_LAST) ||
				 bdp->status & RXBD_ERR)) {

check.

Please sort this out and be more careful in the future.

Thanks.
