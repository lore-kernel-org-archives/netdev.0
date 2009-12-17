From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with vhost-net
Date: Thu, 17 Dec 2009 20:28:57 +0100
Message-ID: <4B2A8679.2030201@gmail.com>
References: <20091217112034.9937.48474.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, herbert@gondor.apana.org.au, mst@redhat.com,
	netdev@vger.kernel.org, rusty@rustcorp.com.au, sri@us.ibm.com
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:55257 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965382AbZLQT3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 14:29:35 -0500
Received: by fxm21 with SMTP id 21so2213130fxm.21
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 11:29:33 -0800 (PST)
In-Reply-To: <20091217112034.9937.48474.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krishna Kumar wrote, On 12/17/2009 12:20 PM:

...
> [ Resending, since I sent to wrong id last time - sorry for
> some duplicates ]
> 
> On a (slightly) related note, qdisc_restart() has this code:
> 	/* Dequeue packet */
> 	skb = dequeue_skb(q);
> 	if (unlikely(!skb))
> 		return 0;
> 
> When a txq is stopped, all subsequent dev_queue_xmits will
> execute this path, pass the "unlikely" code, and return. Is
> it reasonable to remove "unlikely" in both dequeue_skb and
> qdisc_restart, if so patch inlined below:


IMHO we should rather care for the "non-stopped" even if
these cases are equally probable, but I doubt they are,
especially wrt. modern super-fast NICs, so it would be
nice to prove such a change with some test, I guess.

Thanks,
Jarek P.

> 
> thanks,
> 
> - KK
> 
> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> 1. Remove two unlikely checks since stopped queue's will result
> 	int getting a NULL skb.
> 2. Remove an extra space after unlikely check.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
>  net/sched/sch_generic.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff -ruNp org/net/sched/sch_generic.c new/net/sched/sch_generic.c
> --- org/net/sched/sch_generic.c	2009-12-17 16:29:59.000000000 +0530
> +++ new/net/sched/sch_generic.c	2009-12-17 16:30:55.000000000 +0530
> @@ -51,7 +51,7 @@ static inline struct sk_buff *dequeue_sk
>  {
>  	struct sk_buff *skb = q->gso_skb;
>  
> -	if (unlikely(skb)) {
> +	if (skb) {
>  		struct net_device *dev = qdisc_dev(q);
>  		struct netdev_queue *txq;
>  
> @@ -134,7 +134,7 @@ int sch_direct_xmit(struct sk_buff *skb,
>  		ret = handle_dev_cpu_collision(skb, txq, q);
>  	} else {
>  		/* Driver returned NETDEV_TX_BUSY - requeue skb */
> -		if (unlikely (ret != NETDEV_TX_BUSY && net_ratelimit()))
> +		if (unlikely(ret != NETDEV_TX_BUSY && net_ratelimit()))
>  			printk(KERN_WARNING "BUG %s code %d qlen %d\n",
>  			       dev->name, ret, q->q.qlen);
>  
> @@ -176,7 +176,7 @@ static inline int qdisc_restart(struct Q
>  
>  	/* Dequeue packet */
>  	skb = dequeue_skb(q);
> -	if (unlikely(!skb))
> +	if (!skb)
>  		return 0;
>  
>  	root_lock = qdisc_lock(q);
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


