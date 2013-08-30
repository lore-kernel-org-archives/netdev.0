From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2 06/11] net: calxedaxgmac: fix race with tx queue
 stop/wake
Date: Fri, 30 Aug 2013 18:12:46 +0100
Message-ID: <1377882766.2065.18.camel@bwh-desktop.uk.level5networks.com>
References: <1377832428-18117-1-git-send-email-robherring2@gmail.com>
	 <1377832428-18117-6-git-send-email-robherring2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	"Rob Herring" <rob.herring@calxeda.com>
To: Rob Herring <robherring2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:43094 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752525Ab3H3VKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 17:10:18 -0400
In-Reply-To: <1377832428-18117-6-git-send-email-robherring2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-29 at 22:13 -0500, Rob Herring wrote:
> From: Rob Herring <rob.herring@calxeda.com>
> 
> Since the xgmac transmit start and completion work locklessly, it is
> possible for xgmac_xmit to stop the tx queue after the xgmac_tx_complete
> has run resulting in the tx queue never being woken up. Fix this by
> ensuring that ring buffer index updates are visible and recheck the ring
> space after stopping the queue.
> 
> The implementation used here was copied from
> drivers/net/ethernet/broadcom/tg3.c.
> 
> Signed-off-by: Rob Herring <rob.herring@calxeda.com>
> ---
> v2:
> - drop netif_tx_lock
> - use netif_start_queue instead of netif_wake_queue
[...]
> @@ -1125,10 +1130,15 @@ static netdev_tx_t xgmac_xmit(struct sk_buff *skb, struct net_device *dev)
>  
>  	priv->tx_head = dma_ring_incr(entry, DMA_TX_RING_SZ);
>  
> -	if (dma_ring_space(priv->tx_head, priv->tx_tail, DMA_TX_RING_SZ) <
> -	    MAX_SKB_FRAGS)
> +	/* Ensure tx_head update is visible to tx completion */
> +	smp_mb();
> +	if (unlikely(tx_dma_ring_space(priv) < MAX_SKB_FRAGS)) {
[...]

On re-reading, I see there's an off-by-one bug lingering here.  You use
up to 1 + MAX_SKB_FRAGS descriptors per skb.  So you must stop the queue
when the ring space is <= MAX_SKB_FRAGS.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
