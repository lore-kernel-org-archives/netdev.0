From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC/PATCH] lockless loopback patch for 2.6 (version 2)
Date: Mon, 14 Jun 2004 20:23:31 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040614182331.GA11862@wotan.suse.de>
References: <Pine.SGI.4.56.0406141000060.479900@neteng.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arthur Kepner <akepner@sgi.com>
Content-Disposition: inline
In-Reply-To: <Pine.SGI.4.56.0406141000060.479900@neteng.engr.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> +#define LOOPBACK_STAT_INC(field)				\
> +	(per_cpu_ptr(loopback_stats, smp_processor_id())->field++)
> +#define LOOPBACK_STAT_ADD(field, n)				\
> +	(per_cpu_ptr(loopback_stats, smp_processor_id())->field += n)

This is too complicated and not preempt safe. Use 
__get_cpu_var(loopback_stats).field++; 

I would also remove the macros and do this directly.

> +	struct net_device_stats *stats = dev->priv;
> +	int i;
> +
> +	if (unlikely(!stats)) {

Tests for NULL don't need an unlikely, because gcc does that by 
default for itself. But why can the stats here be NULL anyways?

>  #ifdef CONFIG_NET_RADIO
>  #include <linux/wireless.h>		/* Note : will define WIRELESS_EXT */
>  #include <net/iw_handler.h>
> @@ -1277,6 +1278,20 @@
>  	return 0;
>  }
>  
> +#define HARD_TX_LOCK_BH(dev, cpu) {			\
> +	if ( dev->features && NETIF_F_LLTX  == 0 ) {	\

&& instead of & and missing brackets.

> +		spin_lock_bh(&dev->xmit_lock);		\
> +		dev->xmit_lock_owner = cpu;		\
> +	}						\
> +}
> +
> +#define HARD_TX_UNLOCK_BH(dev) {			\
> +	if ( dev->features && NETIF_F_LLTX  == 0 ) {	\

Same.

> -	if (ops->reset)
> -		ops->reset(qdisc);
> -	if (ops->destroy)
> -		ops->destroy(qdisc);
> -	module_put(ops->owner);
> -	if (!(qdisc->flags&TCQ_F_BUILTIN))
> -		kfree(qdisc);
> +
> +	call_rcu(&qdisc->q_rcu, __qdisc_destroy, qdisc);

I think you need at least a wmb() after 

           if (q == qdisc) {
		         *qp = q->next;
				 break;
			}

Otherwise the order of updates to the readers is no guaranteed. 
Also if you want to support alpha there will need to be 
smp_read_barrier_depends() in the reader walking this list.

-Andi
