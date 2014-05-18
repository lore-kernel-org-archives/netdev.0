From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH] net: Provide linear backoff mechanism for
 constrained resources at the driver
Date: Sun, 18 May 2014 12:19:46 -0400
Message-ID: <20140518161946.GA19956@hmsreliant.think-freely.org>
References: <20140507.155613.630399521517455317.davem@davemloft.net>
 <1399577392-4457-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39654 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368AbaERQTz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2014 12:19:55 -0400
Content-Disposition: inline
In-Reply-To: <1399577392-4457-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 08, 2014 at 03:29:52PM -0400, Neil Horman wrote:
> What about something like this?  Its not even compile tested, but let me know
> what you think of the idea.  The reasoning behind it is that transient resources
> like dma address ranges in the iommu or swiotlb have the following attributes
> 
> 1) they are quickly allocated and freed
> 
> 2) Usually handled by simply trying again at some later point in time
> 
> 3) Likely to fail again if tried again immediately.
> 
> 4) Not condusive to interlocked signaling mechanisms as the time it takes to
> find and signal a waiting tx queue that resources are now available may take
> longer than needed, and may still result in failure, as competing allocators
> may race in and claim said resources during the signaling period.
> 
> As such, what if we try something more simple like a linear backoff? In this
> example we add a TX return code that indicates that the driver is not busy, but
> unable to transmit due to resource constraints.  This signals the qdisc layer to
> skip trying to drain this transmit queue for a short period of time, with
> subsequent simmilar errors causing increased backoff.  Once the condition is
> cleared, the backoff delay is removed and operation returns to normal.
> 
> Thouthgs?
> 
> Neil
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> ---
>  include/linux/netdevice.h |  4 ++++
>  net/sched/sch_generic.c   | 20 ++++++++++++++++++++
>  2 files changed, 24 insertions(+)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index a803d79..2b88ccd 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -105,6 +105,7 @@ enum netdev_tx {
>  	NETDEV_TX_OK	 = 0x00,	/* driver took care of packet */
>  	NETDEV_TX_BUSY	 = 0x10,	/* driver tx path was busy*/
>  	NETDEV_TX_LOCKED = 0x20,	/* driver tx lock was already taken */
> +	NETDEV_TX_BACKOFF= 0x40		/* driver resource contrained */
>  };
>  typedef enum netdev_tx netdev_tx_t;
>  
> @@ -572,6 +573,9 @@ struct netdev_queue {
>  
>  	unsigned long		state;
>  
> +	unsigned long		backoff_count;
> +	unsigned long		skip_count;
> +
>  #ifdef CONFIG_BQL
>  	struct dql		dql;
>  #endif
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index e1543b0..64bf6fe 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -30,6 +30,8 @@
>  #include <net/pkt_sched.h>
>  #include <net/dst.h>
>  
> +#define MAX_BACKOFF_COUNT 4
> +
>  /* Qdisc to use by default */
>  const struct Qdisc_ops *default_qdisc_ops = &pfifo_fast_ops;
>  EXPORT_SYMBOL(default_qdisc_ops);
> @@ -121,6 +123,15 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
>  {
>  	int ret = NETDEV_TX_BUSY;
>  
> +	/* Only attempt transmit module the backoff_count */
> +	if ((txq->backoff_count) {
> +		if (txq->skip_count % txq->backoff_count) {
> +			txq->skip_count++;
> +			return ret;
> +		}
> +		txq->skip_count = 0;
> +	}
> +		
>  	/* And release qdisc */
>  	spin_unlock(root_lock);
>  
> @@ -135,9 +146,17 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
>  	if (dev_xmit_complete(ret)) {
>  		/* Driver sent out skb successfully or skb was consumed */
>  		ret = qdisc_qlen(q);
> +		txq->backoff_count = 0;
>  	} else if (ret == NETDEV_TX_LOCKED) {
>  		/* Driver try lock failed */
>  		ret = handle_dev_cpu_collision(skb, txq, q);
> +		txq->backoff_count = 0;
> +	} else if (ret == NETDEV_TX_BACKOFF) {
> +		/* The driver claims to be resource constrained */
> +		if (txq->backoff_count != MAX_BACKOFF_COUNT)
> +			txq->backoff_count++;
> +		txq->skip_count++;
> +		ret = dev_requeue_skb(skb, q);
>  	} else {
>  		/* Driver returned NETDEV_TX_BUSY - requeue skb */
>  		if (unlikely(ret != NETDEV_TX_BUSY))
> @@ -145,6 +164,7 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
>  					     dev->name, ret, q->q.qlen);
>  
>  		ret = dev_requeue_skb(skb, q);
> +		txq->backoff_count = 0;
>  	}
>  
>  	if (ret && netif_xmit_frozen_or_stopped(txq))

Ping, Dave do you have any thoughts on this approach?  Is it worth proposing
formally?
Neil
