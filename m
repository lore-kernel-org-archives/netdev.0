From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/2] rps: core implementation
Date: Thu, 19 Nov 2009 09:57:31 +0000
Message-ID: <20091119095730.GA7661@ff.dom.local>
References: <65634d660911102253o2b4f7a19kfed5849e5c88bfe1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:57683 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752773AbZKSJ5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 04:57:32 -0500
Received: by fxm21 with SMTP id 21so2176723fxm.21
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2009 01:57:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <65634d660911102253o2b4f7a19kfed5849e5c88bfe1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11-11-2009 07:53, Tom Herbert wrote:
> Third version of RPS.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
...
> @@ -2266,10 +2401,10 @@ void netif_nit_deliver(struct sk_buff *skb)
>  }
> 
>  /**
> - *	netif_receive_skb - process receive buffer from network
> + *	__netif_receive_skb - process receive buffer from network
>   *	@skb: buffer to process
>   *
> - *	netif_receive_skb() is the main receive data processing function.
> + *	__netif__napireceive_skb() is the main receive data processing function.

--------------->^^^^^^^^^^^^ ?

>   *	It always succeeds. The buffer may be dropped during processing
>   *	for congestion control or by the protocol layers.
>   *
> @@ -2280,7 +2415,8 @@ void netif_nit_deliver(struct sk_buff *skb)
>   *	NET_RX_SUCCESS: no congestion
>   *	NET_RX_DROP: packet was dropped
>   */
> -int netif_receive_skb(struct sk_buff *skb)
> +
> +int __netif_receive_skb(struct sk_buff *skb)
>  {
>  	struct packet_type *ptype, *pt_prev;
>  	struct net_device *orig_dev;
> @@ -2378,6 +2514,16 @@ out:
>  }
>  EXPORT_SYMBOL(netif_receive_skb);
> 
> +int netif_receive_skb(struct sk_buff *skb)
> +{
> +	int cpu = get_rps_cpu(skb->dev, skb);
> +
> +	if (cpu < 0)

The description reads: "This solution queues packets early on in the
receive path on the backlog queues of other CPUs.", so I'm not sure
it's intended. Did you test it like this (and it was visibly worse)?:

	if (cpu < 0 || cpu == smp_processor_id())

> +		return __netif_receive_skb(skb);
> +	else
> +		return enqueue_to_backlog(skb, cpu);
> +}
> +

Jarek P.
