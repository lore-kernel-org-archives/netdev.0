From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 1/3] net: Add ops->ndo_xmit_flush()
Date: Sat, 23 Aug 2014 16:34:50 -0700
Message-ID: <53F9251A.80005@gmail.com>
References: <20140823.132823.531609193955178433.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, jhs@mojatatu.com, hannes@stressinduktion.org,
	edumazet@google.com, jeffrey.t.kirsher@intel.com,
	rusty@rustcorp.com.au
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33123 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751724AbaHWXev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2014 19:34:51 -0400
Received: by mail-pa0-f41.google.com with SMTP id rd3so18604743pab.28
        for <netdev@vger.kernel.org>; Sat, 23 Aug 2014 16:34:51 -0700 (PDT)
In-Reply-To: <20140823.132823.531609193955178433.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/23/2014 01:28 PM, David Miller wrote:
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 7e2b0b8..1d05932 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -782,6 +782,19 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
>   *        (can also return NETDEV_TX_LOCKED iff NETIF_F_LLTX)
>   *	Required can not be NULL.
>   *
> + * void (*ndo_xmit_flush)(struct net_device *dev, u16 queue);
> + *	A driver implements this function when it wishes to support
> + *	deferred TX queue flushing.  The idea is that the expensive
> + *	operation to trigger TX queue processing can be done after
> + *	N calls to ndo_start_xmit rather than being done every single
> + *	time.  In this regime ndo_start_xmit will be called one or more
> + *	times, and then a final ndo_xmit_flush call will be made to
> + *	have the driver tell the device about the new pending TX queue
> + *	entries.  The kernel keeps track of which queues need flushing
> + *	by monitoring skb->queue_mapping of the packets it submits to
> + *	ndo_start_xmit.  This is the queue value that will be passed
> + *	to ndo_xmit_flush.
> + *
>   * u16 (*ndo_select_queue)(struct net_device *dev, struct sk_buff *skb,
>   *                         void *accel_priv, select_queue_fallback_t fallback);
>   *	Called to decide which queue to when device supports multiple
> @@ -1005,6 +1018,7 @@ struct net_device_ops {
>  	int			(*ndo_stop)(struct net_device *dev);
>  	netdev_tx_t		(*ndo_start_xmit) (struct sk_buff *skb,
>  						   struct net_device *dev);
> +	void			(*ndo_xmit_flush)(struct net_device *dev, u16 queue);
>  	u16			(*ndo_select_queue)(struct net_device *dev,
>  						    struct sk_buff *skb,
>  						    void *accel_priv,
> @@ -3358,6 +3372,27 @@ int __init dev_proc_init(void);
>  #define dev_proc_init() 0
>  #endif
>  
> +static inline netdev_tx_t __netdev_start_xmit(const struct net_device_ops *ops,
> +					      struct sk_buff *skb, struct net_device *dev)
> +{
> +	netdev_tx_t ret;
> +	u16 q;
> +
> +	q = skb->queue_mapping;
> +	ret = ops->ndo_start_xmit(skb, dev);
> +	if (ops->ndo_xmit_flush)
> +		ops->ndo_xmit_flush(dev, q);
> +
> +	return ret;
> +}
> +

What about the case of ndo_start_xmit returning something like
NETDEV_TX_BUSY?  I am pretty sure you shouldn't be flushing unless
something has been enqueued.  You might want to add a new return that
specified that a frame has been enqueued but not flushed and then start
down the ndo_xmit_flush path.  Maybe something like NETDEV_TX_DEFERRED.

You might even want to have a return from ndo_xmit_flush just to cover
any oddball cases like a lockless Tx where we might not be able to flush
because the queue is already being flushed by another entity.

Thanks,

Alex
