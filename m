From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/7] Preparatory refactoring part 2.
Date: Mon, 30 Jul 2007 15:59:33 +0200
Message-ID: <46ADEEC5.9030600@trash.net>
References: <11857548771998-git-send-email-bugfood-ml@fatooh.org> <11857548771609-git-send-email-bugfood-ml@fatooh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Corey Hickey <bugfood-ml@fatooh.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37953 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752320AbXG3N7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 09:59:53 -0400
In-Reply-To: <11857548771609-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Corey Hickey wrote:
> diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
> index 8ae077f..0c46938 100644
> --- a/net/sched/sch_sfq.c
> +++ b/net/sched/sch_sfq.c
> @@ -380,71 +380,71 @@ static void sfq_perturbation(unsigned long arg)
>  	}
>  }
>  
> -static int sfq_change(struct Qdisc *sch, struct rtattr *opt)
> +static int sfq_q_init(struct sfq_sched_data *q, struct rtattr *opt)
>  {
> -	struct sfq_sched_data *q = qdisc_priv(sch);
>  	struct tc_sfq_qopt *ctl = RTA_DATA(opt);
> -	unsigned int qlen;
> +	int i;
>  
> -	if (opt->rta_len < RTA_LENGTH(sizeof(*ctl)))
> +	if (opt && opt->rta_len < RTA_LENGTH(sizeof(*ctl)))


opt is dereferenced above (RTA_DATA), so if it is NULL we've already
crashed.

>  		return -EINVAL;
>  
> -	sch_tree_lock(sch);
> -	q->quantum = ctl->quantum ? : psched_mtu(sch->dev);
> -	q->perturb_period = ctl->perturb_period*HZ;
> -	if (ctl->limit)
> -		q->limit = min_t(u32, ctl->limit, SFQ_DEPTH);
> +	q->perturbation = 0;
> +	q->max_depth = 0;
> +	q->tail = q->limit = SFQ_DEPTH;
> +	if (opt == NULL) {
> +		q->perturb_period = 0;
> +	} else {
> +		struct tc_sfq_qopt *ctl = RTA_DATA(opt);
> +		if (ctl->quantum)
> +			q->quantum = ctl->quantum;
> +		q->perturb_period = ctl->perturb_period*HZ;
>  
> -	qlen = sch->q.qlen;
> -	while (sch->q.qlen >= q->limit-1)
> -		sfq_drop(sch);
> -	qdisc_tree_decrease_qlen(sch, qlen - sch->q.qlen);


I hope that patch that makes changing possible brings this back ..
<checking> .. it doesn't. Please either keep this or fix up 6/7
to bring it back.

> +		if (ctl->limit)
> +			q->limit = min_t(u32, ctl->limit, SFQ_DEPTH);
> +	}
>  
> -	del_timer(&q->perturb_timer);
> -	if (q->perturb_period) {
> -		q->perturb_timer.expires = jiffies + q->perturb_period;
> -		add_timer(&q->perturb_timer);
> +	for (i=0; i<SFQ_HASH_DIVISOR; i++)
> +		q->ht[i] = SFQ_DEPTH;
> +	for (i=0; i<SFQ_DEPTH; i++) {
> +		skb_queue_head_init(&q->qs[i]);
> +		q->dep[i+SFQ_DEPTH].next = i+SFQ_DEPTH;
> +		q->dep[i+SFQ_DEPTH].prev = i+SFQ_DEPTH;
>  	}
> -	sch_tree_unlock(sch);
> +
> +	for (i=0; i<SFQ_DEPTH; i++)
> +		sfq_link(q, i);
>  	return 0;
>  }
>  

> +static void sfq_q_destroy(struct sfq_sched_data *q)
> +{
> +	del_timer(&q->perturb_timer);
> +}
> +
>  static void sfq_destroy(struct Qdisc *sch)
>  {
>  	struct sfq_sched_data *q = qdisc_priv(sch);
> -	del_timer(&q->perturb_timer);
> +	sfq_q_destroy(q);
>  }

That really does look a bit pointless.
