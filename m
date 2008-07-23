From: denys@visp.net.lb
Subject: Re: NMI lockup, 2.6.26 release
Date: Thu, 24 Jul 2008 02:56:35 +0300
Message-ID: <200807240256.36098.denys@visp.net.lb>
References: <200807222142.23710.denys@visp.net.lb> <20080723222631.GA2397@ami.dom.local> <20080723232456.GA5835@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:41640 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754058AbYGWX4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 19:56:48 -0400
In-Reply-To: <20080723232456.GA5835@ami.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I dont have any problem to restart :-)
Build system and restart (over kexec) is automated..
Rebooting now.

On Thursday 24 July 2008, Jarek Poplawski wrote:
> (take 3)
> 
> ...I'm really sorry! If it's possible better try to restart with this one.
> 
> Jarek P.
> 
> ---
> 
> diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
> index 3fb58f4..6b6fff3 100644
> --- a/net/sched/sch_htb.c
> +++ b/net/sched/sch_htb.c
> @@ -169,7 +169,8 @@ struct htb_sched {
>  
>  	int rate2quantum;	/* quant = rate / rate2quantum */
>  	psched_time_t now;	/* cached dequeue time */
> -	struct qdisc_watchdog watchdog;
> +	//struct qdisc_watchdog watchdog;
> +	struct timer_list timer;	/* send delay timer */
>  
>  	/* non shaped skbs; let them go directly thru */
>  	struct sk_buff_head direct_queue;
> @@ -893,6 +894,14 @@ next:
>  	return skb;
>  }
>  
> +static void htb_timer(unsigned long arg)
> +{
> +	struct Qdisc *sch = (struct Qdisc*)arg;
> +	sch->flags &= ~TCQ_F_THROTTLED;
> +	wmb();
> +	netif_schedule(sch->dev);
> +}
> +
>  static struct sk_buff *htb_dequeue(struct Qdisc *sch)
>  {
>  	struct sk_buff *skb = NULL;
> @@ -943,7 +952,10 @@ static struct sk_buff *htb_dequeue(struct Qdisc *sch)
>  		}
>  	}
>  	sch->qstats.overlimits++;
> -	qdisc_watchdog_schedule(&q->watchdog, next_event);
> +	//qdisc_watchdog_schedule(&q->watchdog, next_event);
> +	next_event = next_event - q->now;
> +	mod_timer(&q->timer, jiffies + (unsigned long)next_event * HZ /
> +				 PSCHED_TICKS_PER_SEC);
>  fin:
>  	return skb;
>  }
> @@ -996,7 +1008,9 @@ static void htb_reset(struct Qdisc *sch)
>  
>  		}
>  	}
> -	qdisc_watchdog_cancel(&q->watchdog);
> +	//qdisc_watchdog_cancel(&q->watchdog);
> +	sch->flags &= ~TCQ_F_THROTTLED;
> +	del_timer(&q->timer);
>  	__skb_queue_purge(&q->direct_queue);
>  	sch->q.qlen = 0;
>  	memset(q->row, 0, sizeof(q->row));
> @@ -1047,7 +1061,11 @@ static int htb_init(struct Qdisc *sch, struct nlattr *opt)
>  	for (i = 0; i < TC_HTB_NUMPRIO; i++)
>  		INIT_LIST_HEAD(q->drops + i);
>  
> -	qdisc_watchdog_init(&q->watchdog, sch);
> +	//qdisc_watchdog_init(&q->watchdog, sch);
> +	q->timer.function = htb_timer;
> +	q->timer.data = (unsigned long)sch;
> +	init_timer(&q->timer);
> +
>  	skb_queue_head_init(&q->direct_queue);
>  
>  	q->direct_qlen = sch->dev->tx_queue_len;
> @@ -1262,7 +1280,8 @@ static void htb_destroy(struct Qdisc *sch)
>  {
>  	struct htb_sched *q = qdisc_priv(sch);
>  
> -	qdisc_watchdog_cancel(&q->watchdog);
> +	//qdisc_watchdog_cancel(&q->watchdog);
> +	del_timer_sync(&q->timer);
>  	/* This line used to be after htb_destroy_class call below
>  	   and surprisingly it worked in 2.4. But it must precede it
>  	   because filter need its target class alive to be able to call
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


