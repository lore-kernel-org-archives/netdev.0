From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v4 02/16] net: rcu-ify tcf_proto
Date: Fri, 12 Sep 2014 08:03:29 -0700
Message-ID: <54130B41.4090409@gmail.com>
References: <20140910154517.2036.53084.stgit@nitbit.x32>  <20140910154723.2036.13857.stgit@nitbit.x32> <1410397004.7106.41.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net, jhs@mojatatu.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f45.google.com ([209.85.219.45]:55747 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750859AbaILPDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 11:03:48 -0400
Received: by mail-oa0-f45.google.com with SMTP id m1so596456oag.32
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 08:03:48 -0700 (PDT)
In-Reply-To: <1410397004.7106.41.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/10/2014 05:56 PM, Eric Dumazet wrote:
> On Wed, 2014-09-10 at 08:47 -0700, John Fastabend wrote:
>> rcu'ify tcf_proto this allows calling tc_classify() without holding
>> any locks. Updaters are protected by RTNL.
>>
>> This patch prepares the core net_sched infrastracture for running
>> the classifier/action chains without holding the qdisc lock however
>> it does nothing to ensure cls_xxx and act_xxx types also work without
>> locking. Additional patches are required to address the fall out.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
> ...
>> diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
>> index ed30e43..4b52b70 100644
>> --- a/net/sched/sch_choke.c
>> +++ b/net/sched/sch_choke.c
>> @@ -57,7 +57,7 @@ struct choke_sched_data {
>>
>>   /* Variables */
>>   	struct red_vars  vars;
>> -	struct tcf_proto *filter_list;
>> +	struct tcf_proto __rcu *filter_list;
>>   	struct {
>>   		u32	prob_drop;	/* Early probability drops */
>>   		u32	prob_mark;	/* Early probability marks */
>> @@ -193,9 +193,11 @@ static bool choke_classify(struct sk_buff *skb,
>>   {
>>   	struct choke_sched_data *q = qdisc_priv(sch);
>>   	struct tcf_result res;
>> +	struct tcf_proto *fl;
>>   	int result;
>>
>> -	result = tc_classify(skb, q->filter_list, &res);
>> +	fl = rcu_dereference_bh(q->filter_list);
>
> Hmm... please change the caller to pass fl.
>
> Idea is to read q->filter_list once.
>

I'll just use rcu_access_pointer() in the caller and leave this
rcu_dereference_bh() here.

>> +	result = tc_classify(skb, fl, &res);
>>   	if (result >= 0) {
>>   #ifdef CONFIG_NET_CLS_ACT
>>   		switch (result) {
>> @@ -244,12 +246,14 @@ static bool choke_match_random(const struct choke_sched_data *q,
>>   			       unsigned int *pidx)
>>   {
>>   	struct sk_buff *oskb;
>> +	struct tcf_proto *fl;
>>
>>   	if (q->head == q->tail)
>>   		return false;
>>
>>   	oskb = choke_peek_random(q, pidx);
>> -	if (q->filter_list)
>> +	fl = rcu_dereference_bh(q->filter_list);
>
> You could use rcu_access_pointer() and not have this fl variable.
>

done thanks.

>> +	if (fl)
>>   		return choke_get_classid(nskb) == choke_get_classid(oskb);
>>
>>   	return choke_match_flow(oskb, nskb);
>> @@ -259,9 +263,11 @@ static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>>   {
>>   	struct choke_sched_data *q = qdisc_priv(sch);
>>   	const struct red_parms *p = &q->parms;
>> +	struct tcf_proto *fl;
>>   	int ret = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
>>
>> -	if (q->filter_list) {
>> +	fl = rcu_dereference_bh(q->filter_list);
>> +	if (fl) {
>>   		/* If using external classifiers, get result and record it. */
>>   		if (!choke_classify(skb, sch, &ret))
>
> Here I think you should pass fl as an additional parameter to
> choke_classify()
>
>
> OR, just use rcu_access_pointer() here as you do not deref
> q->filter_list here.
>

Went with rcu_access_pointer.

>
>>   			goto other_drop;	/* Packet was eaten by filter */
>> @@ -554,7 +560,8 @@ static unsigned long choke_bind(struct Qdisc *sch, unsigned long parent,
>>   	return 0;
>>   }
>>
>> -static struct tcf_proto **choke_find_tcf(struct Qdisc *sch, unsigned long cl)
>> +static struct tcf_proto __rcu **choke_find_tcf(struct Qdisc *sch,
>> +					       unsigned long cl)
>>   {
>>   	struct choke_sched_data *q = qdisc_priv(sch);
>>
>
> remaining part seems fine.
>
>


-- 
John Fastabend         Intel Corporation
