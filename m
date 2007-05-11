From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] make qdisc_restart more readable
Date: Fri, 11 May 2007 19:01:26 +0200
Message-ID: <20070511170126.GH521@postel.suug.ch>
References: <1178842400.5008.17.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:57640 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757075AbXEKRBG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 13:01:06 -0400
Content-Disposition: inline
In-Reply-To: <1178842400.5008.17.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <j.hadi123@gmail.com> 2007-05-10 20:13
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index f671cd2..718d6fd 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -83,6 +83,9 @@ struct wireless_dev;
>  #define NETDEV_TX_OK 0		/* driver took care of packet */
>  #define NETDEV_TX_BUSY 1	/* driver tx path was busy*/
>  #define NETDEV_TX_LOCKED -1	/* driver tx lock was already taken */
> +#define NETDEV_TX_DROP -2	/* request caller to drop packet */
> +#define NETDEV_TX_QUEUE -3	/* request caller to requeue packet */
> +
>  
>  /*
>   *	Compute the worst case header length according to the protocols
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index f28bb2d..b821040 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -59,7 +59,79 @@ void qdisc_unlock_tree(struct net_device *dev)
>  	spin_unlock_bh(&dev->queue_lock);
>  }
>  
> -/*
> +static inline int qqlen(struct Qdisc *q)
> +{
> +	BUG_ON((int) q->q.qlen < 0);
> +	return q->q.qlen;
> +}

Nitpicking but qdisc_qlen() sounds a lot better to me.

> +
> +static inline int handle_dev_cpu_collision(struct net_device *dev)
> +{
> +	if (dev->xmit_lock_owner == smp_processor_id()) {
> +		if (net_ratelimit())
> +			printk(KERN_DEBUG
> +			       "Dead loop on netdevice %s, fix it urgently!\n",
> +			       dev->name);
> +		return NETDEV_TX_DROP;
> +	}
> +	/* XXX: This maintains original code, but i think we should
> +	 * update cpu_collision always
> +	*/
> +	__get_cpu_var(netdev_rx_stat).cpu_collision++;
> +	return NETDEV_TX_QUEUE;
> +}
> +
> +static inline int
> +handle_dev_requeue(struct sk_buff *skb, struct net_device *dev, struct Qdisc *q)
> +{
> +
> +	if (unlikely(q == &noop_qdisc))
> +		kfree_skb(skb);
> +
> +	if (skb->next)

Oops, missing else here, this will crash.

> +		dev->gso_skb = skb;
> +	else
> +		q->ops->requeue(skb, q);
> +	/* XXX: Could netif_schedule fail? Or is that fact we are
> +	 * requeueing imply the hardware path is closed
> +	 * and even if we fail, some interupt will wake us
> +	*/
> +	netif_schedule(dev);
> +	return 0;
> +}
> +
> +static inline int
> +try_get_tx_pkt(struct sk_buff **skb, struct net_device *dev, struct Qdisc *q)
> +{
> +	if (((*skb = dev->gso_skb)) || ((*skb = q->dequeue(q)))) {
> +
> +		dev->gso_skb = NULL;
> +		return -1;
> +	}
> +
> +	return 0;
> +}

Seems simpler to just return the skb or NULL instead

> +static inline int
> +handle_tx_locked(struct sk_buff *skb, struct net_device *dev, struct Qdisc *q)
> +{
> +	int ret = handle_dev_cpu_collision(dev);
> +
> +	if (ret == NETDEV_TX_DROP) {
> +		kfree_skb(skb);
> +		return qqlen(q);
> +	}
> +
> +	return handle_dev_requeue(skb, dev, q);
> +}
> +
> +
> +/* 
> +   NOTE: Called under dev->queue_lock with locally disabled BH.
> +
> +   __LINK_STATE_QDISC_RUNNING guarantees only one CPU
> +   can enter this region at a time.
> +
>     dev->queue_lock serializes queue accesses for this device
>     AND dev->qdisc pointer itself.
>  
> @@ -67,114 +139,63 @@ void qdisc_unlock_tree(struct net_device *dev)
>  
>     dev->queue_lock and netif_tx_lock are mutually exclusive,
>     if one is grabbed, another must be free.
> - */
>  
> +   Multiple CPUs may contend for the two locks.
>  
> -/* Kick device.
> +   Note, that this procedure can be called by a watchdog timer, so that
> +   we do not check dev->tbusy flag here.
>  
> +   Returns to the caller:  
>     Returns:  0  - queue is empty or throttled.
>  	    >0  - queue is not empty.
> -
> -   NOTE: Called under dev->queue_lock with locally disabled BH.
>  */
>  
> -static inline int qdisc_restart(struct net_device *dev)
> +int 
> +qdisc_restart(struct net_device *dev)
>  {
>  	struct Qdisc *q = dev->qdisc;
> -	struct sk_buff *skb;
> -
> -	/* Dequeue packet */
> -	if (((skb = dev->gso_skb)) || ((skb = q->dequeue(q)))) {
> -		unsigned nolock = (dev->features & NETIF_F_LLTX);
> +	unsigned lockless = (dev->features & NETIF_F_LLTX);
> +	struct sk_buff *skb = NULL;
> +	int ret;
> +
> +	ret = try_get_tx_pkt(&skb, dev, q);
> +	if (ret == 0)
> +		return qqlen(q);
> +
> +	/* we have a packet to send */
> +	if (!lockless) {
> +		if (!netif_tx_trylock(dev))
> +			return handle_tx_locked(skb, dev, q);
> +	}
> +		
> +	/* all clear .. */
> +	spin_unlock(&dev->queue_lock);
>  
> -		dev->gso_skb = NULL;
> +	/* churn baby churn .. */
> +	ret = dev_hard_start_xmit(skb, dev);

Check whether queue is stopped got lost here

> -		/*
> -		 * When the driver has LLTX set it does its own locking
> -		 * in start_xmit. No need to add additional overhead by
> -		 * locking again. These checks are worth it because
> -		 * even uncongested locks can be quite expensive.
> -		 * The driver can do trylock like here too, in case
> -		 * of lock congestion it should return -1 and the packet
> -		 * will be requeued.
> -		 */
> -		if (!nolock) {
> -			if (!netif_tx_trylock(dev)) {
> -			collision:
> -				/* So, someone grabbed the driver. */
> -
> -				/* It may be transient configuration error,
> -				   when hard_start_xmit() recurses. We detect
> -				   it by checking xmit owner and drop the
> -				   packet when deadloop is detected.
> -				*/
> -				if (dev->xmit_lock_owner == smp_processor_id()) {
> -					kfree_skb(skb);
> -					if (net_ratelimit())
> -						printk(KERN_DEBUG "Dead loop on netdevice %s, fix it urgently!\n", dev->name);
> -					goto out;
> -				}
> -				__get_cpu_var(netdev_rx_stat).cpu_collision++;
> -				goto requeue;
> -			}
> -		}
> +	if (!lockless)  
> +		netif_tx_unlock(dev);
>  
> -		{
> -			/* And release queue */
> -			spin_unlock(&dev->queue_lock);
> -
> -			if (!netif_queue_stopped(dev)) {
> -				int ret;
> -
> -				ret = dev_hard_start_xmit(skb, dev);
> -				if (ret == NETDEV_TX_OK) {
> -					if (!nolock) {
> -						netif_tx_unlock(dev);
> -					}
> -					spin_lock(&dev->queue_lock);
> -					q = dev->qdisc;
> -					goto out;
> -				}
> -				if (ret == NETDEV_TX_LOCKED && nolock) {
> -					spin_lock(&dev->queue_lock);
> -					q = dev->qdisc;
> -					goto collision;
> -				}
> -			}
> +	spin_lock(&dev->queue_lock);
>  
> -			/* NETDEV_TX_BUSY - we need to requeue */
> -			/* Release the driver */
> -			if (!nolock) {
> -				netif_tx_unlock(dev);
> -			}
> -			spin_lock(&dev->queue_lock);
> -			q = dev->qdisc;
> -		}
> +	q = dev->qdisc;

Maybe comment why q needs to be refreshed so nobody removes
it by accident.

> +	/* most likely result, packet went ok */
> +	if (ret == NETDEV_TX_OK)
> +		return qqlen(q);
> +	/* only for lockless drivers .. */
> +	if (ret == NETDEV_TX_LOCKED && lockless) {
> +		return handle_tx_locked(skb, dev, q);
> +	}

Your style of placing parentheses seems to vary randomly :-)
