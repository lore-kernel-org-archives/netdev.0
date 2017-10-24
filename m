From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [patch net-next] net: core: introduce mini_Qdisc and eliminate
 usage of tp->q for clsact fastpath
Date: Tue, 24 Oct 2017 12:50:21 +0200
Message-ID: <59EF1AED.2010401@iogearbox.net>
References: <20171023212832.1332-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, edumazet@google.com,
        alexander.h.duyck@intel.com, willemb@google.com,
        john.fastabend@gmail.com, alexei.starovoitov@gmail.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58964 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932230AbdJXKuZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 06:50:25 -0400
In-Reply-To: <20171023212832.1332-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2017 11:28 PM, Jiri Pirko wrote:
[...]
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index 031dffd..c7ddbdb 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -143,6 +143,36 @@ static inline int qdisc_avail_bulklimit(const struct netdev_queue *txq)
>   #endif
>   }
>
> +/* Mini Qdisc serves for specific needs of ingress/clsact Qdisc.
> + * The fast path only needs to access filter list and to update stats
> + */
> +struct mini_Qdisc {
> +	struct tcf_proto __rcu *filter_list;
> +	struct gnet_stats_basic_cpu __percpu *cpu_bstats;
> +	struct gnet_stats_queue	__percpu *cpu_qstats;
> +	struct mini_Qdisc __rcu **p_miniq;
> +};
> +
> +static inline void mini_qdisc_init(struct mini_Qdisc *miniq,
> +				   struct Qdisc *qdisc,
> +				   struct mini_Qdisc __rcu **p_miniq)
> +{
> +	miniq->cpu_bstats = qdisc->cpu_bstats;
> +	miniq->cpu_qstats = qdisc->cpu_qstats;
> +	miniq->p_miniq = p_miniq;
> +}
> +
> +static inline void mini_qdisc_enable(struct mini_Qdisc *miniq)
> +{
> +	rcu_assign_pointer(*miniq->p_miniq, miniq);
> +}
> +
> +static inline void mini_qdisc_disable(struct mini_Qdisc *miniq)
> +{
> +	RCU_INIT_POINTER(*miniq->p_miniq, NULL);
> +	rcu_barrier();

Can you add a comment against which call_rcu() above barrier
protects against?

> +}
> +
>   struct Qdisc_class_ops {
>   	/* Child qdisc manipulation */
>   	struct netdev_queue *	(*select_queue)(struct Qdisc *, struct tcmsg *);
> @@ -259,9 +289,13 @@ struct qdisc_skb_cb {
>   	unsigned char		data[QDISC_CB_PRIV_LEN];
>   };
>
> +typedef void tcf_chain_change_empty_t(struct tcf_proto __rcu **p_filter_chain,
> +				      bool empty);
> +
>   struct tcf_chain {
>   	struct tcf_proto __rcu *filter_chain;
>   	struct tcf_proto __rcu **p_filter_chain;
> +	tcf_chain_change_empty_t *chain_change_empty;
>   	struct list_head list;
>   	struct tcf_block *block;
>   	u32 index; /* chain index */
> @@ -605,6 +639,12 @@ static inline void qdisc_bstats_cpu_update(struct Qdisc *sch,
>   	bstats_cpu_update(this_cpu_ptr(sch->cpu_bstats), skb);
>   }
>
> +static inline void mini_qdisc_bstats_cpu_update(struct mini_Qdisc *miniq,
> +						const struct sk_buff *skb)
> +{
> +	bstats_cpu_update(this_cpu_ptr(miniq->cpu_bstats), skb);
> +}
> +
>   static inline void qdisc_bstats_update(struct Qdisc *sch,
>   				       const struct sk_buff *skb)
>   {
> @@ -648,6 +688,11 @@ static inline void qdisc_qstats_cpu_drop(struct Qdisc *sch)
>   	this_cpu_inc(sch->cpu_qstats->drops);
>   }
>
> +static inline void mini_qdisc_qstats_cpu_drop(struct mini_Qdisc *miniq)
> +{
> +	this_cpu_inc(miniq->cpu_qstats->drops);
> +}
> +
>   static inline void qdisc_qstats_overlimit(struct Qdisc *sch)
>   {
>   	sch->qstats.overlimits++;
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 24ac908..b4a5812 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3274,14 +3274,16 @@ EXPORT_SYMBOL(dev_loopback_xmit);
>   static struct sk_buff *
>   sch_handle_egress(struct sk_buff *skb, int *ret, struct net_device *dev)
>   {
> -	struct tcf_proto *cl = rcu_dereference_bh(dev->egress_cl_list);
> +	struct mini_Qdisc *miniq = rcu_dereference_bh(skb->dev->miniq_egress);

We already have dev passed here, so lets use it as done previously.

>   	struct tcf_result cl_res;
> +	struct tcf_proto *cl;
>
> -	if (!cl)
> +	if (!miniq)
>   		return skb;
> +	cl = rcu_dereference_bh(miniq->filter_list);

This one still has two RCU dereferences instead of just one. Could
we bind the lifetime of the miniq 1:1 to the filter_list head such
that we can then also get rid of the 2nd rcu_dereference_bh() and
piggy-back on the first one for the filter_list there, thus we push
this into control slow-path instead?

>   	/* qdisc_skb_cb(skb)->pkt_len was already set by the caller. */
> -	qdisc_bstats_cpu_update(cl->q, skb);
> +	mini_qdisc_bstats_cpu_update(miniq, skb);
>
>   	switch (tcf_classify(skb, cl, &cl_res, false)) {
>   	case TC_ACT_OK:
> @@ -3289,7 +3291,7 @@ sch_handle_egress(struct sk_buff *skb, int *ret, struct net_device *dev)
>   		skb->tc_index = TC_H_MIN(cl_res.classid);
>   		break;
>   	case TC_ACT_SHOT:
> -		qdisc_qstats_cpu_drop(cl->q);
> +		mini_qdisc_qstats_cpu_drop(miniq);
>   		*ret = NET_XMIT_DROP;
>   		kfree_skb(skb);
>   		return NULL;
> @@ -4189,16 +4191,19 @@ sch_handle_ingress(struct sk_buff *skb, struct packet_type **pt_prev, int *ret,
>   		   struct net_device *orig_dev)
>   {
>   #ifdef CONFIG_NET_CLS_ACT
> -	struct tcf_proto *cl = rcu_dereference_bh(skb->dev->ingress_cl_list);
> +	struct mini_Qdisc *miniq = rcu_dereference_bh(skb->dev->miniq_ingress);
>   	struct tcf_result cl_res;
> +	struct tcf_proto *cl;
>
>   	/* If there's at least one ingress present somewhere (so
>   	 * we get here via enabled static key), remaining devices
>   	 * that are not configured with an ingress qdisc will bail
>   	 * out here.
>   	 */
> -	if (!cl)
> +	if (!miniq)
>   		return skb;
> +	cl = rcu_dereference_bh(miniq->filter_list);
> +
>   	if (*pt_prev) {
>   		*ret = deliver_skb(skb, *pt_prev, orig_dev);
>   		*pt_prev = NULL;
> @@ -4206,7 +4211,7 @@ sch_handle_ingress(struct sk_buff *skb, struct packet_type **pt_prev, int *ret,
>
>   	qdisc_skb_cb(skb)->pkt_len = skb->len;
>   	skb->tc_at_ingress = 1;
> -	qdisc_bstats_cpu_update(cl->q, skb);
> +	mini_qdisc_bstats_cpu_update(miniq, skb);
>
>   	switch (tcf_classify(skb, cl, &cl_res, false)) {
>   	case TC_ACT_OK:
> @@ -4214,7 +4219,7 @@ sch_handle_ingress(struct sk_buff *skb, struct packet_type **pt_prev, int *ret,
>   		skb->tc_index = TC_H_MIN(cl_res.classid);
>   		break;
>   	case TC_ACT_SHOT:
> -		qdisc_qstats_cpu_drop(cl->q);
> +		mini_qdisc_qstats_cpu_drop(miniq);
>   		kfree_skb(skb);
>   		return NULL;
>   	case TC_ACT_STOLEN:

Thanks,
Daniel
