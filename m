From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] net: core: introduce mini_Qdisc and eliminate
 usage of tp->q for clsact fastpath
Date: Tue, 24 Oct 2017 16:30:03 +0200
Message-ID: <20171024143003.GA1901@nanopsycho>
References: <20171023212832.1332-1-jiri@resnulli.us>
 <59EF1AED.2010401@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, mlxsw@mellanox.com, edumazet@google.com,
        alexander.h.duyck@intel.com, willemb@google.com,
        john.fastabend@gmail.com, alexei.starovoitov@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:46128 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750908AbdJXOaH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 10:30:07 -0400
Received: by mail-wr0-f195.google.com with SMTP id l1so20915918wrc.3
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 07:30:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <59EF1AED.2010401@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Oct 24, 2017 at 12:50:21PM CEST, daniel@iogearbox.net wrote:
>On 10/23/2017 11:28 PM, Jiri Pirko wrote:
>[...]
>> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
>> index 031dffd..c7ddbdb 100644
>> --- a/include/net/sch_generic.h
>> +++ b/include/net/sch_generic.h
>> @@ -143,6 +143,36 @@ static inline int qdisc_avail_bulklimit(const struct netdev_queue *txq)
>>   #endif
>>   }
>> 
>> +/* Mini Qdisc serves for specific needs of ingress/clsact Qdisc.
>> + * The fast path only needs to access filter list and to update stats
>> + */
>> +struct mini_Qdisc {
>> +	struct tcf_proto __rcu *filter_list;
>> +	struct gnet_stats_basic_cpu __percpu *cpu_bstats;
>> +	struct gnet_stats_queue	__percpu *cpu_qstats;
>> +	struct mini_Qdisc __rcu **p_miniq;
>> +};
>> +
>> +static inline void mini_qdisc_init(struct mini_Qdisc *miniq,
>> +				   struct Qdisc *qdisc,
>> +				   struct mini_Qdisc __rcu **p_miniq)
>> +{
>> +	miniq->cpu_bstats = qdisc->cpu_bstats;
>> +	miniq->cpu_qstats = qdisc->cpu_qstats;
>> +	miniq->p_miniq = p_miniq;
>> +}
>> +
>> +static inline void mini_qdisc_enable(struct mini_Qdisc *miniq)
>> +{
>> +	rcu_assign_pointer(*miniq->p_miniq, miniq);
>> +}
>> +
>> +static inline void mini_qdisc_disable(struct mini_Qdisc *miniq)
>> +{
>> +	RCU_INIT_POINTER(*miniq->p_miniq, NULL);
>> +	rcu_barrier();
>
>Can you add a comment against which call_rcu() above barrier
>protects against?

Will do.

>
>> +}
>> +
>>   struct Qdisc_class_ops {
>>   	/* Child qdisc manipulation */
>>   	struct netdev_queue *	(*select_queue)(struct Qdisc *, struct tcmsg *);
>> @@ -259,9 +289,13 @@ struct qdisc_skb_cb {
>>   	unsigned char		data[QDISC_CB_PRIV_LEN];
>>   };
>> 
>> +typedef void tcf_chain_change_empty_t(struct tcf_proto __rcu **p_filter_chain,
>> +				      bool empty);
>> +
>>   struct tcf_chain {
>>   	struct tcf_proto __rcu *filter_chain;
>>   	struct tcf_proto __rcu **p_filter_chain;
>> +	tcf_chain_change_empty_t *chain_change_empty;
>>   	struct list_head list;
>>   	struct tcf_block *block;
>>   	u32 index; /* chain index */
>> @@ -605,6 +639,12 @@ static inline void qdisc_bstats_cpu_update(struct Qdisc *sch,
>>   	bstats_cpu_update(this_cpu_ptr(sch->cpu_bstats), skb);
>>   }
>> 
>> +static inline void mini_qdisc_bstats_cpu_update(struct mini_Qdisc *miniq,
>> +						const struct sk_buff *skb)
>> +{
>> +	bstats_cpu_update(this_cpu_ptr(miniq->cpu_bstats), skb);
>> +}
>> +
>>   static inline void qdisc_bstats_update(struct Qdisc *sch,
>>   				       const struct sk_buff *skb)
>>   {
>> @@ -648,6 +688,11 @@ static inline void qdisc_qstats_cpu_drop(struct Qdisc *sch)
>>   	this_cpu_inc(sch->cpu_qstats->drops);
>>   }
>> 
>> +static inline void mini_qdisc_qstats_cpu_drop(struct mini_Qdisc *miniq)
>> +{
>> +	this_cpu_inc(miniq->cpu_qstats->drops);
>> +}
>> +
>>   static inline void qdisc_qstats_overlimit(struct Qdisc *sch)
>>   {
>>   	sch->qstats.overlimits++;
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 24ac908..b4a5812 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -3274,14 +3274,16 @@ EXPORT_SYMBOL(dev_loopback_xmit);
>>   static struct sk_buff *
>>   sch_handle_egress(struct sk_buff *skb, int *ret, struct net_device *dev)
>>   {
>> -	struct tcf_proto *cl = rcu_dereference_bh(dev->egress_cl_list);
>> +	struct mini_Qdisc *miniq = rcu_dereference_bh(skb->dev->miniq_egress);
>
>We already have dev passed here, so lets use it as done previously.

Oops. Will do.


>
>>   	struct tcf_result cl_res;
>> +	struct tcf_proto *cl;
>> 
>> -	if (!cl)
>> +	if (!miniq)
>>   		return skb;
>> +	cl = rcu_dereference_bh(miniq->filter_list);
>
>This one still has two RCU dereferences instead of just one. Could
>we bind the lifetime of the miniq 1:1 to the filter_list head such
>that we can then also get rid of the 2nd rcu_dereference_bh() and
>piggy-back on the first one for the filter_list there, thus we push
>this into control slow-path instead?

The miniq is not assigned (skb->dev->miniq_egress == NULL) in case the
miniq->filter_list is empty. That is ensured by the slow-path and what
is why I don't check cl == NULL here.

I was thinking how to avoid the second rcu_dereference, but I was not
able to achieve that.

I don't get what you mean by "piggy-back" here. Could you please
elaborate a bit more?
