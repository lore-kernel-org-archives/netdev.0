From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Xmit Packet Steering (XPS)
Date: Fri, 20 Nov 2009 21:53:54 +0100
Message-ID: <4B0701E2.1070806@gmail.com>
References: <4B05D8DC.7020907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:63378 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754921AbZKTUyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 15:54:12 -0500
Received: by bwz27 with SMTP id 27so3761202bwz.21
        for <netdev@vger.kernel.org>; Fri, 20 Nov 2009 12:54:17 -0800 (PST)
In-Reply-To: <4B05D8DC.7020907@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote, On 11/20/2009 12:46 AM:

> Here is first version of XPS.
> 
> Goal of XPS is to free TX completed skbs by the cpu that submitted the transmit.
> 
> Because I chose to union skb->iif with skb->sending_cpu, I chose
> to introduce a new xps_consume_skb(skb), and not generalize consume_skb() itself.

...

> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 63f4742..e8e4795 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -366,7 +366,10 @@ struct sk_buff {
>  	struct nf_bridge_info	*nf_bridge;
>  #endif
>  
> -	int			iif;
> +	union {
> +		int		iif;
> +		int		sending_cpu;
> +	};

...

> diff --git a/net/core/dev.c b/net/core/dev.c
> index 9977288..9e134f6 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1965,6 +1965,7 @@ int dev_queue_xmit(struct sk_buff *skb)
>  	struct netdev_queue *txq;
>  	struct Qdisc *q;
>  	int rc = -ENOMEM;
> +	int cpu;
>  
>  	/* GSO will handle the following emulations directly. */
>  	if (netif_needs_gso(dev, skb))
> @@ -2000,6 +2001,7 @@ gso:
>  	 */
>  	rcu_read_lock_bh();
>  
> +	skb->sending_cpu = cpu = smp_processor_id();

There is one more problem: this will break things like act_mirred + ifb,
and other cases using skb->iif e.g. for filtering on virtual devices at
the xmit path.

Jarek P.
