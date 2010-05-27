From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6] net: replace hooks in __netif_receive_skb
Date: Thu, 27 May 2010 16:06:54 +0200
Message-ID: <4BFE7C7E.8090803@trash.net>
References: <20100527134935.GA6916@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, shemminger@vyatta.com,
	eric.dumazet@gmail.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43891 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750831Ab0E0OGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 10:06:55 -0400
In-Reply-To: <20100527134935.GA6916@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko wrote:
> @@ -511,10 +512,16 @@ static void macvlan_setup(struct net_device *dev)
>  	dev->tx_queue_len	= 0;
>  }
>  
> +static struct netdev_rx_handler macvlan_rx_handler = {
> +	.order		= NETDEV_RX_HANDLER_ORDER_MACVLAN,
> +	.callback	= macvlan_handle_frame,
> +};

It seems this could be const since you duplicate it on
registration.

> +
>  static int macvlan_port_create(struct net_device *dev)
>  {
>  	struct macvlan_port *port;
>  	unsigned int i;
> +	int err;
>  
>  	if (dev->type != ARPHRD_ETHER || dev->flags & IFF_LOOPBACK)
>  		return -EINVAL;
> @@ -528,6 +535,15 @@ static int macvlan_port_create(struct net_device *dev)
>  	for (i = 0; i < MACVLAN_HASH_SIZE; i++)
>  		INIT_HLIST_HEAD(&port->vlan_hash[i]);
>  	rcu_assign_pointer(dev->macvlan_port, port);
> +
> +	err = netdev_rx_handler_register(dev, &macvlan_rx_handler);
> +	if (err) {
> +		rcu_assign_pointer(dev->macvlan_port, NULL);
> +		synchronize_rcu();
> +		kfree(port);
> +		return err;
> +	}

I'd prefer goto-based unroll since that makes changes in the
future easier.

> +
>  	return 0;
>  }
>  
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index a1bff65..8e95b2d 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -254,6 +254,15 @@ struct netdev_hw_addr_list {
>  #define netdev_for_each_mc_addr(ha, dev) \
>  	netdev_hw_addr_list_for_each(ha, &(dev)->mc)
>  
> +
> +struct netdev_rx_handler {
> +	struct list_head	list;
> +	unsigned int		order;
> +#define NETDEV_RX_HANDLER_ORDER_BRIDGE	1
> +#define NETDEV_RX_HANDLER_ORDER_MACVLAN	2

Any reason for not using an enum?

> +	struct sk_buff		*(*callback)(struct sk_buff *skb);
> +};
> +
>  struct hh_cache {
>  	struct hh_cache *hh_next;	/* Next entry			     */
>  	atomic_t	hh_refcnt;	/* number of users                   */
> @@ -1031,6 +1040,10 @@ struct net_device {
>  	/* GARP */
>  	struct garp_port	*garp_port;
>  
> +	/* receive handlers (hooks) list */
> +	spinlock_t		rx_handlers_lock;
> +	struct list_head	rx_handlers;
> +
>  	/* class/net/name entry */
>  	struct device		dev;
>  	/* space for optional device, statistics, and wireless sysfs groups */
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 6c82065..8d4a817 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2744,6 +2688,82 @@ void netif_nit_deliver(struct sk_buff *skb)
>  	rcu_read_unlock();
>  }
>  
> +static bool rx_handlers_equal(struct netdev_rx_handler *rh1,
> +			      struct netdev_rx_handler *rh2)
> +{
> +	return (rh1->order == rh2->order) && (rh1->callback == rh2->callback);
> +}
> +
> +/**
> + *	netdev_rx_handler_register - register receive handler
> + *	@dev: device to register a handler for
> + *	@rh: receive handler to register
> + *
> + *	Register a receive hander for a device. This handler will then be
> + *	called from __netif_receive_skb. A negative errno code is returned
> + *	on a failure.
> + */
> +int netdev_rx_handler_register(struct net_device *dev,
> +			       struct netdev_rx_handler *rh)
> +{
> +	struct list_head *list, *add_after;
> +	struct netdev_rx_handler *rh1;
> +	int err = 0;
> +
> +	spin_lock_bh(&dev->rx_handlers_lock);

Why are you using a spin lock and even disable BHs? This function
should only be called from user context, so a mutex will work fine
(and would fix the use of GFP_KERNEL in an atomic section).

> +	add_after = &dev->rx_handlers;
> +	list_for_each(list, &dev->rx_handlers) {

Naming the element "list" is confusing. Also this should be
using list_for_each_entry().

> +		rh1 = list_entry(list, struct netdev_rx_handler, list);
> +		if (rx_handlers_equal(rh, rh1)) {
> +			err = -EEXIST;
> +			goto unlock;
> +		}
> +		if (rh1->order > rh->order)
> +			break;
> +		add_after = list;
> +	}
> +	rh1 = kzalloc(sizeof(*rh), GFP_KERNEL);
> +	if (!rh1) {
> +		err = -ENOMEM;
> +		goto unlock;
> +	}
> +
> +	rh1->order = rh->order;
> +	rh1->callback = rh->callback;
> +	list_add_rcu(&rh1->list, add_after);
> +
> +unlock:
> +	spin_unlock_bh(&dev->rx_handlers_lock);
> +
> +	return err;
> +}
> +EXPORT_SYMBOL(netdev_rx_handler_register);
