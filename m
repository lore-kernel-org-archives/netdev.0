From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH RFC 3/3] net_sched: Add size table for qdiscs
Date: Thu, 17 Jul 2008 12:30:48 +0200
Message-ID: <487F1F58.3040701@trash.net>
References: <20080717100921.3327.3324.stgit@fate.lan> <20080717100938.3327.45121.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51821 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753901AbYGQKax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 06:30:53 -0400
In-Reply-To: <20080717100938.3327.45121.stgit@fate.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jussi Kivilinna wrote:
> diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
> index dbb7ac3..eae53bf 100644
> --- a/include/linux/pkt_sched.h
> +++ b/include/linux/pkt_sched.h
> @@ -85,6 +85,27 @@ struct tc_ratespec
>  
>  #define TC_RTAB_SIZE	1024
>  
> +struct tc_sizespec {
> +	unsigned char	cell_log;
> +	unsigned char	size_log;
> +	short		cell_align;
> +	int		overhead;
> +	unsigned	linklayer;
> +	unsigned	mpu;
> +	unsigned	mtu;
> +};

Please use "unsigned int".

> +
> +#define TC_STAB_DATA_SIZE 1024
> +
> +enum {
> +	TCA_STAB_UNSPEC,
> +	TCA_STAB_BASE,
> +	TCA_STAB_DATA,
> +	__TCA_STAB_MAX
> +};

Since you already split the STAB into a base and a data
structure, wouldn't it make sense to have the data size
dynamic for user-defined granularity?

> +static LIST_HEAD(qdisc_stab_list);
> +
> +static const struct nla_policy stab_policy[TCA_STAB_MAX + 1] = {
> +	[TCA_STAB_BASE]	= { .len = sizeof(struct tc_sizespec) },
> +	[TCA_STAB_DATA] = { .type = NLA_BINARY, .len = TC_STAB_DATA_SIZE },
> +};
> +
> +static struct qdisc_size_table *qdisc_get_stab(struct nlattr *opt, int *err)
> +{
> +	struct nlattr *tb[TCA_STAB_MAX + 1];
> +	struct qdisc_size_table *stab;
> +	struct tc_sizespec *s;
> +	u16 *tab;
> +
> +	*err = nla_parse_nested(tb, TCA_STAB_MAX, opt, stab_policy);
> +	if (*err < 0)
> +		return NULL;

ERR_PTR is cleaner than pointer return values IMO.

> diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
> index bc9d6af..f75ba82 100644
> --- a/net/sched/sch_netem.c
> +++ b/net/sched/sch_netem.c
> @@ -84,7 +84,7 @@ struct netem_skb_cb {
>  
>  static inline struct netem_skb_cb *netem_skb_cb(struct sk_buff *skb)
>  {
> -	return (struct netem_skb_cb *)skb->cb;
> +	return (struct netem_skb_cb *)qdisc_skb_cb(skb)->data;
>  }

A BUILD_BUG_ON to make sure the skb->cb size is not exceeded would
be good to have.

>  /* init_crandom - initialize correlated random number generator
> @@ -189,6 +189,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  		u32 dupsave = q->duplicate; /* prevent duplicating a dup... */
>  		q->duplicate = 0;
>  
> +		qdisc_root_init_tx_len(skb2, rootq);
>  		qdisc_enqueue(skb2, rootq);

How about adding qdisc_enqueue_root() to perform both these steps
(its similar to net/core/dev.c).

> diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
> index 1e3d52e..862c0e3 100644
> --- a/net/sched/sch_tbf.c
> +++ b/net/sched/sch_tbf.c
> @@ -123,9 +123,9 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc* sch)
>  	struct tbf_sched_data *q = qdisc_priv(sch);
>  	int ret;
>  
> -	/* qdisc_tx_len() before qdisc_enqueue() wrapper, might return different
> -	 * length than after wrapper. Should recalculate tx_len here if q->qdisc
> -	 * has size table? */
> +	if (q->qdisc->stab)
> +		qdisc_calculate_tx_len(skb, q->qdisc->stab);
> +

I don't think this will help, the inner qdisc might again have
an inner qdisc that increases the size. So this probably needs
to be handled during dequeue.

>  	if (qdisc_tx_len(skb) > q->max_size) {
>  		sch->qstats.drops++;
>  #ifdef CONFIG_NET_CLS_ACT
> 

