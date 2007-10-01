From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 10/10] Use nested compat attributes to pass parameters.
Date: Mon, 01 Oct 2007 15:54:38 +0200
Message-ID: <4700FC1E.9040309@trash.net>
References: <1191019977201-git-send-email-bugfood-ml@fatooh.org> <11910199782593-git-send-email-bugfood-ml@fatooh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Corey Hickey <bugfood-ml@fatooh.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33346 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751906AbXJANzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 09:55:03 -0400
In-Reply-To: <11910199782593-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Corey Hickey wrote:
> This fixes the ambiguity between, for example:
> tc qdisc change ... perturb 0
> tc qdisc change ...
> 
> Without this patch, there is no way for SFQ to differentiate between
> a parameter specified to be 0 and a parameter that was omitted.
> 

> diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
> index 170fd37..36197f6 100644
> --- a/net/sched/sch_sfq.c
> +++ b/net/sched/sch_sfq.c
> @@ -428,25 +428,31 @@ sfq_q_init(struct sfq_sched_data *q, struct rtattr *opt)
>  	 * the previous values (sfq_change). So, overwrite the parameters as
>  	 * specified. */
>  	if (opt) {
> -		struct tc_sfq_qopt *ctl = RTA_DATA(opt);
> -
> -		if (opt->rta_len < RTA_LENGTH(sizeof(*ctl)))
> -			return -EINVAL;
> -
> -		if (ctl->quantum)
> -			q->quantum = ctl->quantum;
> -		if (ctl->perturb_period)
> -			q->perturb_period = ctl->perturb_period;
> -		if (ctl->divisor)
> -			q->hash_divisor = ctl->divisor;
> -		if (ctl->flows)
> -			q->depth = ctl->flows;
> -		if (ctl->limit)
> -			q->limit = ctl->limit;
> -
> +		struct tc_sfq_qopt *ctl;
> +		struct rtattr *tb[TCA_SFQ_MAX];
> +
> +		if (rtattr_parse_nested_compat(tb, TCA_SFQ_MAX, opt, ctl,
> +				       sizeof(*ctl)))
> +			goto rtattr_failure;
> +
> +#define GET_PARAM(dst, nest, compat) do { \
> +	struct rtattr *rta = tb[(nest) - 1]; \
> +	if (rta) \
> +		(dst) = RTA_GET_U32(rta); \
> +	else if ((compat)) \
> +		(dst) = (compat); \
> +} while (0)


An inline function and a comment why this is done would increase
readability.

> +
> +		GET_PARAM(q->quantum,        TCA_SFQ_QUANTUM, ctl->quantum);
> +		GET_PARAM(q->perturb_period, TCA_SFQ_PERTURB,
> +				ctl->perturb_period);
> +		GET_PARAM(q->hash_divisor,   TCA_SFQ_DIVISOR, ctl->divisor);
> +		GET_PARAM(q->depth,          TCA_SFQ_FLOWS,   ctl->flows);
> +		GET_PARAM(q->limit,          TCA_SFQ_LIMIT,   ctl->limit);
> +		
>  		if (q->perturb_period > SFQ_MAX_PERTURB ||
>  		    q->depth > SFQ_MAX_DEPTH)
> -			return -EINVAL;
> +			goto rtattr_failure;
>  	}
>  	q->limit = min_t(u32, q->limit, q->depth - 2);
>  	q->tail = q->depth;
> @@ -482,6 +488,8 @@ sfq_q_init(struct sfq_sched_data *q, struct rtattr *opt)
>  	for (i=0; i < q->depth; i++)
>  		sfq_link(q, i);
>  	return 0;
> +rtattr_failure:
> +	return -EINVAL;
>  err_case:
>  	sfq_q_destroy(q);
>  	return -ENOBUFS;
> @@ -559,17 +567,26 @@ static int sfq_dump(struct Qdisc *sch, struct sk_buff *skb)
>  {
>  	struct sfq_sched_data *q = qdisc_priv(sch);
>  	unsigned char *b = skb_tail_pointer(skb);
> +	struct rtattr *nest;
>  	struct tc_sfq_qopt opt;
>  
>  	opt.quantum = q->quantum;
>  	opt.perturb_period = q->perturb_period;
> -
>  	opt.limit = q->limit;
>  	opt.divisor = q->hash_divisor;
>  	opt.flows = q->depth;
>  
> +	nest = RTA_NEST_COMPAT(skb, TCA_OPTIONS, sizeof(opt), &opt);
> +
> +	RTA_PUT_U32(skb, TCA_SFQ_QUANTUM, q->quantum);
> +	RTA_PUT_U32(skb, TCA_SFQ_PERTURB, q->perturb_period);
> +	RTA_PUT_U32(skb, TCA_SFQ_LIMIT,   q->limit);
> +	RTA_PUT_U32(skb, TCA_SFQ_DIVISOR, q->hash_divisor);
> +	RTA_PUT_U32(skb, TCA_SFQ_FLOWS,   q->depth);
>  	RTA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);


This is wrong, RTA_NEST_COMPAT already dumps the structure.

>  
> +	RTA_NEST_COMPAT_END(skb, nest);
> +
>  	return skb->len;
>  
>  rtattr_failure:

