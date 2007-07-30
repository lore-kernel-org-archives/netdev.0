From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/7] Preparatory refactoring part 1.
Date: Mon, 30 Jul 2007 15:51:05 +0200
Message-ID: <46ADECC9.7010303@trash.net>
References: <11857548771998-git-send-email-bugfood-ml@fatooh.org> <11857548774008-git-send-email-bugfood-ml@fatooh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Corey Hickey <bugfood-ml@fatooh.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37780 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755312AbXG3Nv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 09:51:26 -0400
In-Reply-To: <11857548774008-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Corey Hickey wrote:
> diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
> index 9579573..8ae077f 100644
> --- a/net/sched/sch_sfq.c
> +++ b/net/sched/sch_sfq.c
> @@ -77,6 +77,9 @@
>  #define SFQ_DEPTH		128
>  #define SFQ_HASH_DIVISOR	1024
>  
> +#define SFQ_HEAD 0
> +#define SFQ_TAIL 1
> +
>  /* This type should contain at least SFQ_DEPTH*2 values */
>  typedef unsigned char sfq_index;
>  
> @@ -244,10 +247,8 @@ static unsigned int sfq_drop(struct Qdisc *sch)
>  	return 0;
>  }
>  
> -static int
> -sfq_enqueue(struct sk_buff *skb, struct Qdisc* sch)
> +static void sfq_q_enqueue(struct sk_buff *skb, struct sfq_sched_data *q, unsigned int end)


Please make sure to break at 80 chars and to keep the style
in this file consistent (newline before function name).

>  {
> -	struct sfq_sched_data *q = qdisc_priv(sch);
>  	unsigned hash = sfq_hash(q, skb);
>  	sfq_index x;
>  
> @@ -256,8 +257,12 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc* sch)
>  		q->ht[hash] = x = q->dep[SFQ_DEPTH].next;
>  		q->hash[x] = hash;
>  	}
> -	sch->qstats.backlog += skb->len;


Why not keep this instead of having both callers do it?

> -	__skb_queue_tail(&q->qs[x], skb);
> +
> +	if (end == SFQ_TAIL)
> +		__skb_queue_tail(&q->qs[x], skb);
> +	else
> +		__skb_queue_head(&q->qs[x], skb);
> +
>  	sfq_inc(q, x);
>  	if (q->qs[x].qlen == 1) {		/* The flow is new */
>  		if (q->tail == SFQ_DEPTH) {	/* It is the first flow */
> @@ -270,12 +275,21 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc* sch)
>  			q->tail = x;
>  		}
>  	}
> +}
> +
> +static int
> +sfq_enqueue(struct sk_buff *skb, struct Qdisc* sch)
> +{
> +	struct sfq_sched_data *q = qdisc_priv(sch);


newline please.

> +	sfq_q_enqueue(skb, q, SFQ_TAIL);
> +	sch->qstats.backlog += skb->len;
>  	if (++sch->q.qlen < q->limit-1) {
>  		sch->bstats.bytes += skb->len;
>  		sch->bstats.packets++;
>  		return 0;
>  	}
>  
> +	sch->qstats.drops++;


sfq_drop already increments this.

>  	sfq_drop(sch);
>  	return NET_XMIT_CN;
>  }
> @@ -284,28 +298,8 @@ static int
>  sfq_requeue(struct sk_buff *skb, struct Qdisc* sch)
>  {
>  	struct sfq_sched_data *q = qdisc_priv(sch);

newline please

> -	unsigned hash = sfq_hash(q, skb);
> -	sfq_index x;
> -
> -	x = q->ht[hash];
> -	if (x == SFQ_DEPTH) {
> -		q->ht[hash] = x = q->dep[SFQ_DEPTH].next;
> -		q->hash[x] = hash;
> -	}
> +	sfq_q_enqueue(skb, q, SFQ_HEAD);
>  	sch->qstats.backlog += skb->len;
> -	__skb_queue_head(&q->qs[x], skb);
> -	sfq_inc(q, x);
> -	if (q->qs[x].qlen == 1) {		/* The flow is new */
> -		if (q->tail == SFQ_DEPTH) {	/* It is the first flow */
> -			q->tail = x;
> -			q->next[x] = x;
> -			q->allot[x] = q->quantum;
> -		} else {
> -			q->next[x] = q->next[q->tail];
> -			q->next[q->tail] = x;
> -			q->tail = x;
> -		}
> -	}
>  	if (++sch->q.qlen < q->limit - 1) {
>  		sch->qstats.requeues++;
>  		return 0;
> @@ -316,13 +310,8 @@ sfq_requeue(struct sk_buff *skb, struct Qdisc* sch)
>  	return NET_XMIT_CN;
>  }
>  
> -
> -
> -
> -static struct sk_buff *
> -sfq_dequeue(struct Qdisc* sch)
> +static struct sk_buff *sfq_q_dequeue(struct sfq_sched_data *q)


Keep style consistent please.

>  {
> -	struct sfq_sched_data *q = qdisc_priv(sch);
>  	struct sk_buff *skb;
>  	sfq_index a, old_a;
>  
> @@ -335,8 +324,6 @@ sfq_dequeue(struct Qdisc* sch)
>  	/* Grab packet */
>  	skb = __skb_dequeue(&q->qs[a]);
>  	sfq_dec(q, a);
> -	sch->q.qlen--;
> -	sch->qstats.backlog -= skb->len;
>  
>  	/* Is the slot empty? */
>  	if (q->qs[a].qlen == 0) {
> @@ -353,6 +340,21 @@ sfq_dequeue(struct Qdisc* sch)
>  		a = q->next[a];
>  		q->allot[a] += q->quantum;
>  	}
> +
> +	return skb;
> +}
> +
> +static struct sk_buff
> +*sfq_dequeue(struct Qdisc* sch)
> +{
> +	struct sfq_sched_data *q = qdisc_priv(sch);
> +	struct sk_buff *skb;
> +
> +	skb = sfq_q_dequeue(q);
> +	if (skb == NULL)
> +		return NULL;
> +	sch->q.qlen--;
> +	sch->qstats.backlog -= skb->len;
>  	return skb;
>  }
>  

