From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Fri, 24 Jul 2009 08:30:06 +0000
Message-ID: <20090724083006.GA5698@ff.dom.local>
References: <20090720074607.32463.23013.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:57864 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826AbZGXIaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 04:30:13 -0400
Received: by fxm18 with SMTP id 18so1296948fxm.37
        for <netdev@vger.kernel.org>; Fri, 24 Jul 2009 01:30:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090720074607.32463.23013.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20-07-2009 09:46, Krishna Kumar wrote:
> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> Driver sends an skb and stops the queue if no more space is
> available on the device, and returns OK. When dev_queue_xmit
> runs for the next skb, it enqueue's the skb & calls qdisc_run.
> qdisc_run dequeue's the skb and finds the queue is stopped
> after getting the HARD_LOCK_TX, and puts the skb back on
> gso_skb (the next iteration fails faster at dequeue_skb).
> 
> This patch avoids calling __qdisc_run if the queue is stopped.
> This also lets us remove the queue_stopped check in dequeue_skb
> and in qdisc_restart.

It was designed wrt. multiqueue handling mainly, were such a check
isn't enough at this place.

Jarek P.

> When the queue is re-enabled, it runs with
> one less queue_stopped() check for every skb on the queue (we
> still need to own the __QDISC_STATE_RUNNING bit to catch the
> stopped condition correctly since stopped cannot be set without
> holding this bit).
> 
> Results for 3 iteration testing for 1, 4, 8, 12 netperf sessions
> running for 1 minute each:
> 
> -----------------------------------------------------------------
> 	       System-X			         P6
> -----------------------------------------------------------------
> Size	ORG BW		NEW BW		ORG BW		NEW BW
> -----------------------------------------------------------------
> 16K	72183.05	74417.79	60775.76	63413.17
> 128K	69097.87	72447.12	61692.16	62251.07
> 256K	60456.21	61415.81	59694.03	61641.81
> -----------------------------------------------------------------
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
> 
>  include/net/pkt_sched.h |    9 +++++++--
>  net/sched/sch_generic.c |    9 ++-------
>  2 files changed, 9 insertions(+), 9 deletions(-)
> 
> diff -ruNp org/include/net/pkt_sched.h new/include/net/pkt_sched.h
> --- org/include/net/pkt_sched.h	2009-06-22 11:40:31.000000000 +0530
> +++ new/include/net/pkt_sched.h	2009-07-20 13:09:18.000000000 +0530
> @@ -92,8 +92,13 @@ extern void __qdisc_run(struct Qdisc *q)
>  
>  static inline void qdisc_run(struct Qdisc *q)
>  {
> -	if (!test_and_set_bit(__QDISC_STATE_RUNNING, &q->state))
> -		__qdisc_run(q);
> +	if (!test_and_set_bit(__QDISC_STATE_RUNNING, &q->state)) {
> +		if (!netif_tx_queue_stopped(q->dev_queue))
> +			__qdisc_run(q);
> +		else
> +			/* driver will wake us up anyway, just clear */
> +			clear_bit(__QDISC_STATE_RUNNING, &q->state);
> +	}
>  }
>  
>  extern int tc_classify_compat(struct sk_buff *skb, struct tcf_proto *tp,
> diff -ruNp org/net/sched/sch_generic.c new/net/sched/sch_generic.c
> --- org/net/sched/sch_generic.c	2009-05-25 07:48:07.000000000 +0530
> +++ new/net/sched/sch_generic.c	2009-07-20 13:09:18.000000000 +0530
> @@ -56,12 +56,8 @@ static inline struct sk_buff *dequeue_sk
>  	struct sk_buff *skb = q->gso_skb;
>  
>  	if (unlikely(skb)) {
> -		struct net_device *dev = qdisc_dev(q);
> -		struct netdev_queue *txq;
> -
>  		/* check the reason of requeuing without tx lock first */
> -		txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
> -		if (!netif_tx_queue_stopped(txq) && !netif_tx_queue_frozen(txq))
> +		if (!netif_tx_queue_frozen(q->dev_queue))
>  			q->gso_skb = NULL;
>  		else
>  			skb = NULL;
> @@ -142,8 +138,7 @@ static inline int qdisc_restart(struct Q
>  	txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
>  
>  	HARD_TX_LOCK(dev, txq, smp_processor_id());
> -	if (!netif_tx_queue_stopped(txq) &&
> -	    !netif_tx_queue_frozen(txq))
> +	if (!netif_tx_queue_frozen(txq))
>  		ret = dev_hard_start_xmit(skb, dev, txq);
>  	HARD_TX_UNLOCK(dev, txq);
>  
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
