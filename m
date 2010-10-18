From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/3] net: allocate tx queues in register_netdevice
Date: Mon, 18 Oct 2010 22:41:20 +0100
Message-ID: <1287438080.2252.792.camel@achroite.uk.solarflarecom.com>
References: <alpine.DEB.1.00.1010181057580.16304@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, John Fastabend <john.r.fastabend@intel.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:57672 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806Ab0JRVlX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 17:41:23 -0400
In-Reply-To: <alpine.DEB.1.00.1010181057580.16304@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-10-18 at 11:02 -0700, Tom Herbert wrote:
> This patch introduces netif_alloc_netdev_queues which is called from
> register_device instead of alloc_netdev_mq.  This makes TX queue
> allocation symmetric with RX allocation similarly allows drivers to
> change dev->num_tx_queues after allocating netdev and before
> registering it.

Changing num_tx_queues is probably *not* desirable, same as for
num_rx_queues.

[...]
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1553,18 +1553,24 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
>   * Routine to help set real_num_tx_queues. To avoid skbs mapped to queues
>   * greater then real_num_tx_queues stale skbs on the qdisc must be flushed.
>   */
> -void netif_set_real_num_tx_queues(struct net_device *dev, unsigned int txq)
> +int netif_set_real_num_tx_queues(struct net_device *dev, unsigned int txq)
>  {
> -	unsigned int real_num = dev->real_num_tx_queues;
> +	if (txq < 1)
> +		return -EINVAL;
>  
> -	if (unlikely(txq > dev->num_tx_queues))
> -		;
> -	else if (txq > real_num)
> -		dev->real_num_tx_queues = txq;
> -	else if (txq < real_num) {
> -		dev->real_num_tx_queues = txq;
> -		qdisc_reset_all_tx_gt(dev, txq);
> -	}
> +	if (dev->reg_state == NETREG_REGISTERED) {
> +		ASSERT_RTNL();
> +
> +		if (txq > dev->num_tx_queues)
> +			return -EINVAL;
> +
> +		if (txq < dev->real_num_tx_queues)
> +			qdisc_reset_all_tx_gt(dev, txq);
> +	} else
> +		dev->num_tx_queues = txq;
[...]

The kernel-doc comment should be updated to reflect the locking
requirement and the possibility of failure when called after
registration.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

