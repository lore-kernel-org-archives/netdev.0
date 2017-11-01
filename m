From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3 2/2] net: core: introduce mini_Qdisc and
 eliminate usage of tp->q for clsact fastpath
Date: Wed, 1 Nov 2017 09:18:03 +0100
Message-ID: <20171101081803.GB1977@nanopsycho.orion>
References: <20171031151222.5021-1-jiri@resnulli.us>
 <20171031151222.5021-3-jiri@resnulli.us>
 <20171101021248.624bvt5jcqr37w5e@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, mlxsw@mellanox.com, edumazet@google.com,
        daniel@iogearbox.net, alexander.h.duyck@intel.com,
        willemb@google.com, john.fastabend@gmail.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:48643 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753244AbdKAISF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 04:18:05 -0400
Received: by mail-wr0-f195.google.com with SMTP id 15so1259124wrb.5
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 01:18:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171101021248.624bvt5jcqr37w5e@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Nov 01, 2017 at 03:12:50AM CET, alexei.starovoitov@gmail.com wrote:
>On Tue, Oct 31, 2017 at 04:12:22PM +0100, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> In sch_handle_egress and sch_handle_ingress tp->q is used only in order
>> to update stats. So stats and filter list are the only things that are
>> needed in clsact qdisc fastpath processing. Introduce new mini_Qdisc
>> struct to hold those items. Also, introduce a helper to swap the
>> mini_Qdisc structures in case filter list head changes.
>> 
>> This removes need for tp->q usage without added overhead.
>> 
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>> v2->v3:
>> - Using head change callback to replace miniq pointer every time tp head
>>   changes. This eliminates one rcu dereference and makes the claim "without
>>   added overhead" valid.
>
>you kidding, right?
>It's still two loads.

I'm not.
I replace:

one rcu_dereference_bh(dev->egress_cl_list)
	by one rcu_dereference_bh(dev->miniq_egress)

one dereference cl->q
	by one dereference miniq->filter_list

What do I miss?


>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 24ac908..1423cf4 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -3274,22 +3274,22 @@ EXPORT_SYMBOL(dev_loopback_xmit);
>>  static struct sk_buff *
>>  sch_handle_egress(struct sk_buff *skb, int *ret, struct net_device *dev)
>>  {
>> -	struct tcf_proto *cl = rcu_dereference_bh(dev->egress_cl_list);
>> +	struct mini_Qdisc *miniq = rcu_dereference_bh(dev->miniq_egress);
>>  	struct tcf_result cl_res;
>>  
>> -	if (!cl)
>> +	if (!miniq)
>>  		return skb;
>>  
>>  	/* qdisc_skb_cb(skb)->pkt_len was already set by the caller. */
>> -	qdisc_bstats_cpu_update(cl->q, skb);
>> +	mini_qdisc_bstats_cpu_update(miniq, skb);
>>  
>> -	switch (tcf_classify(skb, cl, &cl_res, false)) {
>> +	switch (tcf_classify(skb, miniq->filter_list, &cl_res, false)) {
>
>I don't think it's great, but I don't have any suggestions on
>how to avoid it, so I'm not objecting. Just disappointed that
>you keep adding stuff to tc and messing with sw fast path only to
>make parity with some obscure hw feature.
>If it keeps going like this we'd need to come up with some new fast
>hook for clsbpf in ingress/egress paths. We use it for
>every packet, so extra loads are not great.
>I guess they should be cache hits, but will take extra cache line.
>All of the bugs in tc logic recently are not comforting either.
>
