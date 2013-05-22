From: annie li <annie.li@oracle.com>
Subject: Re: [PATCH net-next V3 2/3] xen-netfront: split event channels support
 for Xen frontend driver
Date: Wed, 22 May 2013 15:32:49 -0400
Message-ID: <519D1D61.8030500@oracle.com>
References: <1369240487-18834-1-git-send-email-wei.liu2@citrix.com> <1369240487-18834-3-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org, jbeulich@suse.com,
	ian.campbell@citrix.com, konrad.wilk@oracle.com,
	david.vrabel@citrix.com
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:41451 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756139Ab3EVTc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 15:32:29 -0400
In-Reply-To: <1369240487-18834-3-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013-5-22 12:34, Wei Liu wrote:
> [...]
>   
> -static irqreturn_t xennet_interrupt(int irq, void *dev_id)
> +static irqreturn_t xennet_tx_interrupt(int irq, void *dev_id)
>   {
> -	struct net_device *dev = dev_id;
> -	struct netfront_info *np = netdev_priv(dev);
> +	struct netfront_info *np = dev_id;
> +	struct net_device *dev = np->netdev;
>   	unsigned long flags;
>   
>   	spin_lock_irqsave(&np->tx_lock, flags);
> +	xennet_tx_buf_gc(dev);
> +	spin_unlock_irqrestore(&np->tx_lock, flags);
>   
> -	if (likely(netif_carrier_ok(dev))) {
> -		xennet_tx_buf_gc(dev);
> -		/* Under tx_lock: protects access to rx shared-ring indexes. */
> -		if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx))
> +	return IRQ_HANDLED;
> +}
> +
> +static irqreturn_t xennet_rx_interrupt(int irq, void *dev_id)
> +{
> +	struct netfront_info *np = dev_id;
> +	struct net_device *dev = np->netdev;
> +
> +	if (likely(netif_carrier_ok(dev) &&
> +		   RING_HAS_UNCONSUMED_RESPONSES(&np->rx)))
>   			napi_schedule(&np->napi);
> -	}
>   
> -	spin_unlock_irqrestore(&np->tx_lock, flags);

Originally, netfront protects access to rx shared-ring with tx_lock, you 
remove this protection here. It is better to protect the ring access by 
a sperate rx_lock then.

Thanks
Annie
