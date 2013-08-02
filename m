From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] sis900: Fix the tx queue timeout issue
Date: Fri, 2 Aug 2013 14:03:39 +0200
Message-ID: <1375445019.11783.5.camel@deadeye.wl.decadent.org.uk>
References: <1375281782-2332-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <venza@brownhat.org>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Denis Kirjanov <kda@linux-powerpc.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:25077 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751548Ab3HBMDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 08:03:46 -0400
In-Reply-To: <1375281782-2332-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-31 at 18:43 +0400, Denis Kirjanov wrote:
[...]
> We are trying to initiate a frame transmission even
> if we are not ready to do so due auto negotiation progress:
> 
> timer routine checks the link status and if it's up calls
> netif_carrier_on() allowing upper layer to start the tx queue

Right.  So why is sis900_start_xmit() still being called?  Is this
handling the case where the link just went down and the TX scheduler has
not yet reacted to this?

Would it actually hurt if a packet is queued at this point?  I see no
reason to think it would.  In that case you could remove the entire
if-statement.

Ben.

> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
> ---
>  drivers/net/ethernet/sis/sis900.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
> index eb4aea3..9516734 100644
> --- a/drivers/net/ethernet/sis/sis900.c
> +++ b/drivers/net/ethernet/sis/sis900.c
> @@ -1613,9 +1613,13 @@ sis900_start_xmit(struct sk_buff *skb, struct net_device *net_dev)
>  	unsigned int  count_dirty_tx;
>  
>  	/* Don't transmit data before the complete of auto-negotiation */
> -	if(!sis_priv->autong_complete){
> -		netif_stop_queue(net_dev);
> -		return NETDEV_TX_BUSY;
> +	if (unlikely(!sis_priv->autong_complete)) {
> +		if (netif_msg_tx_err(sis_priv) && net_ratelimit())
> +			printk(KERN_DEBUG "%s: Auto negotiation in progress\n",
> +					net_dev->name);
> +		net_dev->stats.tx_dropped++;
> +		dev_kfree_skb(skb);
> +		return NETDEV_TX_OK;
>  	}
>  
>  	spin_lock_irqsave(&sis_priv->lock, flags);

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
