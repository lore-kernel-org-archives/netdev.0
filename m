From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Xmit Packet Steering (XPS)
Date: Fri, 20 Nov 2009 13:32:45 +0000
Message-ID: <20091120133245.GA9038@ff.dom.local>
References: <4B05D8DC.7020907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:40595 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753351AbZKTNcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 08:32:43 -0500
Received: by bwz27 with SMTP id 27so3325860bwz.21
        for <netdev@vger.kernel.org>; Fri, 20 Nov 2009 05:32:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4B05D8DC.7020907@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20-11-2009 00:46, Eric Dumazet wrote:
> Here is first version of XPS.
> 
> Goal of XPS is to free TX completed skbs by the cpu that submitted the transmit.

But why?... OK, you write in another message about sock_wfree(). Then
how about users, who don't sock_wfree (routers)? Will there be any way
to disable it?

> 
> Because I chose to union skb->iif with skb->sending_cpu, I chose
> to introduce a new xps_consume_skb(skb), and not generalize consume_skb() itself.
> 
> This means that selected drivers must use new function to benefit from XPS
> 
> Preliminary tests are quite good, especially on NUMA machines.
> 
> Only NAPI drivers can use this new infrastructure (xps_consume_skb() cannot
> be called from hardirq context, only from softirq)
> 
> I converted tg3 and pktgen for my tests
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
...
> diff --git a/net/core/xps.c b/net/core/xps.c
> index e69de29..e580159 100644
> --- a/net/core/xps.c
> +++ b/net/core/xps.c
> @@ -0,0 +1,145 @@
> +/*
> + * XPS : Xmit Packet Steering
> + *
> + * TX completion packet freeing is performed on cpu that sent packet.
> + */
> +#if defined(CONFIG_SMP)

Shouldn't it be in the Makefile?

...
> +/*
> + * called at end of net_rx_action()
> + * preemption (and cpu migration/offline/online) disabled
> + */
> +void xps_flush(void)
> +{
> +	int cpu, prevlen;
> +	struct sk_buff_head *head = per_cpu_ptr(xps_array, smp_processor_id());
> +	struct xps_pcpu_queue *q;
> +	struct sk_buff *skb;
> +
> +	for_each_cpu_mask_nr(cpu, __get_cpu_var(xps_cpus)) {
> +		q = &per_cpu(xps_pcpu_queue, cpu);
> +		if (cpu_online(cpu)) {
> +			spin_lock(&q->list.lock);

This lock probably needs irq disabling: let's say 2 cpus run this at
the same time and both are interrupted with these (previously
scheduled) IPIs?

> +			prevlen = skb_queue_len(&q->list);
> +			skb_queue_splice_init(&head[cpu], &q->list);
> +			spin_unlock(&q->list.lock);
> +			/*
> +			 * We hope remote cpu will be fast enough to transfert
> +			 * this list to its completion queue before our
> +			 * next xps_flush() call
> +			 */
> +			if (!prevlen)
> +				__smp_call_function_single(cpu, &q->csd, 0);
> +			continue;
> +		}
> +		/*
> +		 * ok, we must free these skbs, even if we tried to avoid it :)
> +		 */
> +		while ((skb = __skb_dequeue(&head[cpu])) != NULL)
> +			__kfree_skb(skb);
> +	}
> +	cpus_clear(__get_cpu_var(xps_cpus));
> +}
> +
> +/*
> + * called from hardirq (IPI) context
> + */
> +static void remote_free_skb_list(void *arg)
> +{
> +	struct sk_buff *last;
> +	struct softnet_data *sd;
> +	struct xps_pcpu_queue *q = arg; /* &__get_cpu_var(xps_pcpu_queue); */
> +
> +	spin_lock(&q->list.lock);
> +
> +	last = q->list.prev;

Is q->list handled in case this cpu goes down before this IPI is
triggered?

Jarek P.

> +	sd = &__get_cpu_var(softnet_data);
> +	last->next = sd->completion_queue;
> +	sd->completion_queue = q->list.next;
> +	__skb_queue_head_init(&q->list);
> +
> +	spin_unlock(&q->list.lock);
> +
> +	raise_softirq_irqoff(NET_TX_SOFTIRQ);
> +}
...
