From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] [PATCH] net: Add support for ndo_select_queue() functions to
	cache the queue mapping
Date: Thu, 28 Jan 2010 23:39:55 +0530
Message-ID: <OF2C36A392.08814AE1-ON652576B9.00617C98-652576B9.0062AE8B@in.ibm.com>
References: <1264700317.2783.15.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp06.in.ibm.com ([122.248.162.6]:60178 "EHLO
	e28smtp06.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753957Ab0A1R55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 12:57:57 -0500
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp06.in.ibm.com (8.14.3/8.13.1) with ESMTP id o0SHvtpW019072
	for <netdev@vger.kernel.org>; Thu, 28 Jan 2010 23:27:55 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0SHvs2c1994854
	for <netdev@vger.kernel.org>; Thu, 28 Jan 2010 23:27:55 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0SHvsGl012116
	for <netdev@vger.kernel.org>; Fri, 29 Jan 2010 04:57:54 +1100
In-Reply-To: <1264700317.2783.15.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Ben Hutchings <bhutchings@solarflare.com>
>
> We think it's worth matching up RX and TX queue selection for a socket
> when the queues share an interrupt.  Currently the default TX queue
> selection is unlikely to match RX queue selection.  TX queue selectionc
> can be overridden by the driver to match RX queue selection, but at the
> expense of caching.  We found that without caching the cost of
> recalculating the the hash in software for each packet outweighed the
> benefit of good queue selection.
>
> This adds two simple helper functions: sk_may_set_tx_queue() reports
> whether the queue mapping should be cacheable for a socket, and
> netif_sk_tx_queue_set() sets it after validating the queue index.  This
> will allow drivers to evalulate expensive queue selection functions
> (such as Toeplitz hash functions) only once for connected sockets, and
> to avoid doing so for other skbs.
> ---
>  include/linux/netdevice.h |    3 +++
>  include/net/sock.h        |   11 +++++++++++
>  net/core/dev.c            |   19 ++++++++++++++++++-
>  3 files changed, 32 insertions(+), 1 deletions(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index a3fccc8..5354765 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1510,6 +1510,9 @@ static inline int netif_is_multiqueue(const
> struct net_device *dev)
>     return (dev->num_tx_queues > 1);
>  }
>
> +extern void netif_sk_tx_queue_set(struct net_device *dev, struct sock
*sk,
> +              u16 queue_index);
> +
>  /* Use this variant when it is known for sure that it
>   * is executing from hardware interrupt context or with hardware
interrupts
>   * disabled.
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 3f1a480..176fdff 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1105,6 +1105,17 @@ static inline void sock_put(struct sock *sk)
>  extern int sk_receive_skb(struct sock *sk, struct sk_buff *skb,
>             const int nested);
>
> +/**
> + *   sk_may_set_tx_queue - is socket's TX queue mapping cacheable?
> + *   @sk: socket from skb to be transmitted; may be %NULL
> + *
> + * Report whether a queue mapping should be set for this socket.
> + */
> +static inline bool sk_may_set_tx_queue(const struct sock *sk)
> +{
> +   return sk && sk->sk_dst_cache;
> +}
> +
>  static inline void sk_tx_queue_set(struct sock *sk, int tx_queue)
>  {
>     sk->sk_tx_queue_mapping = tx_queue;
> diff --git a/net/core/dev.c b/net/core/dev.c
> index be9924f..09ac29e 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1931,7 +1931,7 @@ static struct netdev_queue *dev_pick_tx(struct
> net_device *dev,
>           if (dev->real_num_tx_queues > 1)
>              queue_index = skb_tx_hash(dev, skb);
>
> -         if (sk && sk->sk_dst_cache)
> +         if (sk_may_set_tx_queue(sk))
>              sk_tx_queue_set(sk, queue_index);
>        }
>     }
> @@ -1940,6 +1940,23 @@ static struct netdev_queue *dev_pick_tx
> (struct net_device *dev,
>     return netdev_get_tx_queue(dev, queue_index);
>  }
>
> +/**
> + *   netif_sk_tx_queue_set - set socket's TX queue mapping
> + *   @dev: network device used for transmission
> + *   @sk: socket from skb to be transmitted
> + *   @queue_index: chosen queue index
> + *
> + * Set the TX queue index to be used for future skbs in the same flow
> + * rather than calling the device's ndo_select_queue function.
> + * sk_may_set_tx_queue(@sk) must be true.
> + */
> +void netif_sk_tx_queue_set(struct net_device *dev, struct sock *sk,
> +            u16 queue_index)
> +{
> +   sk_tx_queue_set(sk, dev_cap_txqueue(dev, queue_index));
> +}
> +EXPORT_SYMBOL(netif_sk_tx_queue_set);
> +
>  static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
>               struct net_device *dev,
>               struct netdev_queue *txq)

I am confused about this - isn't the txq# and rxq# already
matched due to the check for skb_rx_queue_recorded?
sk_dst_cache is also not set for these routing/forwarding
workloads, this can be relied only for locally connected
xmits.

Other than that, I saw netif_sk_tx_queue_set is not called.
And dev_pick_tx has already capped automatically, you probably
don't need another here?

thanks,

- KK

