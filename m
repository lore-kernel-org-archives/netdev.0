From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 11/39]: netdev: Move next_sched into struct
	netdev_queue.
Date: Mon, 14 Jul 2008 11:49:13 +0000
Message-ID: <20080714114913.GA4504@ff.dom.local>
References: <20080703.000333.199735542.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vinay-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, Matheos.Worku-UdXhSnd/wVw@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080703.000333.199735542.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03-07-2008 09:03, David Miller wrote:
> We schedule queues, not the device, for output queue
> processing in BH.
> 
...
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 8e38948..c5e3532 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1323,13 +1323,14 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
>  void __netif_schedule(struct net_device *dev)
>  {
>  	if (!test_and_set_bit(__LINK_STATE_SCHED, &dev->state)) {

Isn't this bit supposed to be set/tested per queue as well, or do I
miss something?

Jarek P.

> +		struct netdev_queue *txq = &dev->tx_queue;
>  		unsigned long flags;
>  		struct softnet_data *sd;
>  
>  		local_irq_save(flags);
>  		sd = &__get_cpu_var(softnet_data);
> -		dev->next_sched = sd->output_queue;
> -		sd->output_queue = dev;
> +		txq->next_sched = sd->output_queue;
> +		sd->output_queue = txq;
>  		raise_softirq_irqoff(NET_TX_SOFTIRQ);
>  		local_irq_restore(flags);
>  	}
> @@ -1912,7 +1913,7 @@ static void net_tx_action(struct softirq_action *h)
>  	}
>  
>  	if (sd->output_queue) {
> -		struct net_device *head;
> +		struct netdev_queue *head;
>  
>  		local_irq_disable();
>  		head = sd->output_queue;
> @@ -1920,12 +1921,10 @@ static void net_tx_action(struct softirq_action *h)
>  		local_irq_enable();
>  
>  		while (head) {
> -			struct net_device *dev = head;
> -			struct netdev_queue *txq;
> +			struct netdev_queue *txq = head;
> +			struct net_device *dev = txq->dev;
>  			head = head->next_sched;
>  
> -			txq = &dev->tx_queue;
> -
>  			smp_mb__before_clear_bit();
>  			clear_bit(__LINK_STATE_SCHED, &dev->state);
>  
> @@ -4346,7 +4345,7 @@ static int dev_cpu_callback(struct notifier_block *nfb,
>  			    void *ocpu)
>  {
>  	struct sk_buff **list_skb;
> -	struct net_device **list_net;
> +	struct netdev_queue **list_net;
>  	struct sk_buff *skb;
>  	unsigned int cpu, oldcpu = (unsigned long)ocpu;
>  	struct softnet_data *sd, *oldsd;
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
