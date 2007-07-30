From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 6/7] Make qdisc changeable.
Date: Mon, 30 Jul 2007 16:11:22 +0200
Message-ID: <46ADF18A.4060008@trash.net>
References: <11857548771998-git-send-email-bugfood-ml@fatooh.org> <11857548783311-git-send-email-bugfood-ml@fatooh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Corey Hickey <bugfood-ml@fatooh.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38185 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753685AbXG3OLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 10:11:43 -0400
In-Reply-To: <11857548783311-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Corey Hickey wrote:
> Re-implement sfq_change() and enable Qdisc_opts.change so "tc qdisc
> change" will work.
> 
> Signed-off-by: Corey Hickey <bugfood-ml@fatooh.org>
> ---
>  net/sched/sch_sfq.c |   51 ++++++++++++++++++++++++++++++++++++++++++++++++++-
>  1 files changed, 50 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
> index e6a6a21..e042cd0 100644
> --- a/net/sched/sch_sfq.c
> +++ b/net/sched/sch_sfq.c
> @@ -485,6 +485,55 @@ static int sfq_init(struct Qdisc *sch, struct rtattr *opt)
>  	return 0;
>  }
>  
> +static int sfq_change(struct Qdisc *sch, struct rtattr *opt)
> +{
> +	struct sfq_sched_data *q = qdisc_priv(sch);
> +	struct sfq_sched_data tmp;
> +	struct sk_buff *skb;
> +	int err;
> +	
> +	/* set up tmp queue */
> +	memset(&tmp, 0, sizeof(struct sfq_sched_data));
> +	tmp.quantum = psched_mtu(sch->dev); /* default */


If no value is given it should use the old value instead of
reinitializing to the default.

> +	if ((err = sfq_q_init(&tmp, opt)))
> +		return err;


This will also use defaults for all unspecified values. It would
be more consistent with other qdiscs to only change those values
that are actually specified, so something like "tc qdisc change ...
perturb 10" will *only* change the perturbation parameter.
I'm not sure reusing the initialization function and copying the
parameters is the best way to do this.

> +
> +	/* copy packets from the old queue to the tmp queue */
> +	sch_tree_lock(sch);
> +	while (sch->q.qlen >= tmp.limit - 1)
> +		sfq_drop(sch);
> +	while ((skb = sfq_q_dequeue(q)) != NULL)
> +		sfq_q_enqueue(skb, &tmp, SFQ_TAIL);
> +	
> +	/* clean up the old queue */
> +	sfq_q_destroy(q);
> +
> +	/* copy elements of the tmp queue into the old queue */
> +	q->perturb_period = tmp.perturb_period;
> +	q->quantum        = tmp.quantum;
> +	q->limit          = tmp.limit;
> +	q->depth          = tmp.depth;
> +	q->hash_divisor   = tmp.hash_divisor;
> +	q->tail           = tmp.tail;
> +	q->max_depth      = tmp.max_depth;
> +	q->ht    = tmp.ht;
> +	q->dep   = tmp.dep;
> +	q->next  = tmp.next;
> +	q->allot = tmp.allot;
> +	q->hash  = tmp.hash;
> +	q->qs    = tmp.qs;
> +
> +	/* finish up */
> +	if (q->perturb_period) {
> +		q->perturb_timer.expires = jiffies + q->perturb_period;
> +		add_timer(&q->perturb_timer);
> +	} else {
> +		q->perturbation = 0;
> +	}
> +	sch_tree_unlock(sch);
> +	return 0;
> +}
> +
