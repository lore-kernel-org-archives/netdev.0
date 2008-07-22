From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: Fix build failure with 'make mandocs'.
Date: Tue, 22 Jul 2008 13:24:39 -0700
Message-ID: <20080722132439.dfbd6597.randy.dunlap@oracle.com>
References: <20080721205229.GA26812@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:53155 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750868AbYGVU0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 16:26:18 -0400
In-Reply-To: <20080721205229.GA26812@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Jul 2008 16:52:29 -0400 Dave Jones wrote:

> The function header comments have to go with the functions
> they are documenting, or things go horribly wrong when we
> try to process them with the docbook tools.
> 
> Warning(include/linux/netdevice.h:1006): No description found for parameter 'dev_queue'
> Warning(include/linux/netdevice.h:1033): No description found for parameter 'dev_queue'
> Warning(include/linux/netdevice.h:1067): No description found for parameter 'dev_queue'
> Warning(include/linux/netdevice.h:1093): No description found for parameter 'dev_queue'
> Warning(include/linux/netdevice.h:1474): No description found for parameter 'txq'
> Error(net/core/dev.c:1674): cannot understand prototype: 'u32 simple_tx_hashrnd; '
> 
> Signed-off-by: Dave Jones <davej@redhat.com>

Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

DaveM, please expedite since this Error is fatal (breaks 'make *docs').


> --- linux-2.6.26.noarch/net/core/dev.c~	2008-07-21 16:49:10.000000000 -0400
> +++ linux-2.6.26.noarch/net/core/dev.c	2008-07-21 16:49:47.000000000 -0400
> @@ -1645,32 +1645,6 @@ out_kfree_skb:
>  	return 0;
>  }
>  
> -/**
> - *	dev_queue_xmit - transmit a buffer
> - *	@skb: buffer to transmit
> - *
> - *	Queue a buffer for transmission to a network device. The caller must
> - *	have set the device and priority and built the buffer before calling
> - *	this function. The function can be called from an interrupt.
> - *
> - *	A negative errno code is returned on a failure. A success does not
> - *	guarantee the frame will be transmitted as it may be dropped due
> - *	to congestion or traffic shaping.
> - *
> - * -----------------------------------------------------------------------------------
> - *      I notice this method can also return errors from the queue disciplines,
> - *      including NET_XMIT_DROP, which is a positive value.  So, errors can also
> - *      be positive.
> - *
> - *      Regardless of the return value, the skb is consumed, so it is currently
> - *      difficult to retry a send to this method.  (You can bump the ref count
> - *      before sending to hold a reference for retry if you are careful.)
> - *
> - *      When calling this method, interrupts MUST be enabled.  This is because
> - *      the BH enable code must have IRQs enabled so that it will not deadlock.
> - *          --BLG
> - */
> -
>  static u32 simple_tx_hashrnd;
>  static int simple_tx_hashrnd_initialized = 0;
>  
> @@ -1738,6 +1712,31 @@ static struct netdev_queue *dev_pick_tx(
>  	return netdev_get_tx_queue(dev, queue_index);
>  }
>  
> +/**
> + *	dev_queue_xmit - transmit a buffer
> + *	@skb: buffer to transmit
> + *
> + *	Queue a buffer for transmission to a network device. The caller must
> + *	have set the device and priority and built the buffer before calling
> + *	this function. The function can be called from an interrupt.
> + *
> + *	A negative errno code is returned on a failure. A success does not
> + *	guarantee the frame will be transmitted as it may be dropped due
> + *	to congestion or traffic shaping.
> + *
> + * -----------------------------------------------------------------------------------
> + *      I notice this method can also return errors from the queue disciplines,
> + *      including NET_XMIT_DROP, which is a positive value.  So, errors can also
> + *      be positive.
> + *
> + *      Regardless of the return value, the skb is consumed, so it is currently
> + *      difficult to retry a send to this method.  (You can bump the ref count
> + *      before sending to hold a reference for retry if you are careful.)
> + *
> + *      When calling this method, interrupts MUST be enabled.  This is because
> + *      the BH enable code must have IRQs enabled so that it will not deadlock.
> + *          --BLG
> + */
>  int dev_queue_xmit(struct sk_buff *skb)
>  {
>  	struct net_device *dev = skb->dev;
> --- linux-2.6.26.noarch/include/linux/netdevice.h~	2008-07-21 16:46:36.000000000 -0400
> +++ linux-2.6.26.noarch/include/linux/netdevice.h	2008-07-21 16:48:53.000000000 -0400
> @@ -996,17 +996,17 @@ static inline void netif_tx_schedule_all
>  		netif_schedule_queue(netdev_get_tx_queue(dev, i));
>  }
>  
> +static inline void netif_tx_start_queue(struct netdev_queue *dev_queue)
> +{
> +	clear_bit(__QUEUE_STATE_XOFF, &dev_queue->state);
> +}
> +
>  /**
>   *	netif_start_queue - allow transmit
>   *	@dev: network device
>   *
>   *	Allow upper layers to call the device hard_start_xmit routine.
>   */
> -static inline void netif_tx_start_queue(struct netdev_queue *dev_queue)
> -{
> -	clear_bit(__QUEUE_STATE_XOFF, &dev_queue->state);
> -}
> -
>  static inline void netif_start_queue(struct net_device *dev)
>  {
>  	netif_tx_start_queue(netdev_get_tx_queue(dev, 0));
> @@ -1022,13 +1022,6 @@ static inline void netif_tx_start_all_qu
>  	}
>  }
>  
> -/**
> - *	netif_wake_queue - restart transmit
> - *	@dev: network device
> - *
> - *	Allow upper layers to call the device hard_start_xmit routine.
> - *	Used for flow control when transmit resources are available.
> - */
>  static inline void netif_tx_wake_queue(struct netdev_queue *dev_queue)
>  {
>  #ifdef CONFIG_NETPOLL_TRAP
> @@ -1041,6 +1034,13 @@ static inline void netif_tx_wake_queue(s
>  		__netif_schedule(dev_queue->qdisc);
>  }
>  
> +/**
> + *	netif_wake_queue - restart transmit
> + *	@dev: network device
> + *
> + *	Allow upper layers to call the device hard_start_xmit routine.
> + *	Used for flow control when transmit resources are available.
> + */
>  static inline void netif_wake_queue(struct net_device *dev)
>  {
>  	netif_tx_wake_queue(netdev_get_tx_queue(dev, 0));
> @@ -1056,6 +1056,11 @@ static inline void netif_tx_wake_all_que
>  	}
>  }
>  
> +static inline void netif_tx_stop_queue(struct netdev_queue *dev_queue)
> +{
> +	set_bit(__QUEUE_STATE_XOFF, &dev_queue->state);
> +}
> +
>  /**
>   *	netif_stop_queue - stop transmitted packets
>   *	@dev: network device
> @@ -1063,11 +1068,6 @@ static inline void netif_tx_wake_all_que
>   *	Stop upper layers calling the device hard_start_xmit routine.
>   *	Used for flow control when transmit resources are unavailable.
>   */
> -static inline void netif_tx_stop_queue(struct netdev_queue *dev_queue)
> -{
> -	set_bit(__QUEUE_STATE_XOFF, &dev_queue->state);
> -}
> -
>  static inline void netif_stop_queue(struct net_device *dev)
>  {
>  	netif_tx_stop_queue(netdev_get_tx_queue(dev, 0));
> @@ -1083,17 +1083,17 @@ static inline void netif_tx_stop_all_que
>  	}
>  }
>  
> +static inline int netif_tx_queue_stopped(const struct netdev_queue *dev_queue)
> +{
> +	return test_bit(__QUEUE_STATE_XOFF, &dev_queue->state);
> +}
> +
>  /**
>   *	netif_queue_stopped - test if transmit queue is flowblocked
>   *	@dev: network device
>   *
>   *	Test if transmit queue on device is currently unable to send.
>   */
> -static inline int netif_tx_queue_stopped(const struct netdev_queue *dev_queue)
> -{
> -	return test_bit(__QUEUE_STATE_XOFF, &dev_queue->state);
> -}
> -
>  static inline int netif_queue_stopped(const struct net_device *dev)
>  {
>  	return netif_tx_queue_stopped(netdev_get_tx_queue(dev, 0));
> @@ -1463,13 +1463,6 @@ static inline void netif_rx_complete(str
>  	local_irq_restore(flags);
>  }
>  
> -/**
> - *	netif_tx_lock - grab network device transmit lock
> - *	@dev: network device
> - *	@cpu: cpu number of lock owner
> - *
> - * Get network device transmit lock
> - */
>  static inline void __netif_tx_lock(struct netdev_queue *txq, int cpu)
>  {
>  	spin_lock(&txq->_xmit_lock);
> @@ -1482,6 +1475,13 @@ static inline void __netif_tx_lock_bh(st
>  	txq->xmit_lock_owner = smp_processor_id();
>  }
>  
> +/**
> + *	netif_tx_lock - grab network device transmit lock
> + *	@dev: network device
> + *	@cpu: cpu number of lock owner
> + *
> + * Get network device transmit lock
> + */
>  static inline void netif_tx_lock(struct net_device *dev)
>  {
>  	int cpu = smp_processor_id();
> 
> -- 

---
~Randy
Linux Plumbers Conference, 17-19 September 2008, Portland, Oregon USA
http://linuxplumbersconf.org/
