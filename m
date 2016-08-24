From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 05/15] net: sched: a dflt qdisc may be used with
 per cpu stats
Date: Wed, 24 Aug 2016 10:13:18 -0700
Message-ID: <57BDD5AE.8030208@gmail.com>
References: <20160823202135.14368.62466.stgit@john-Precision-Tower-5810>
 <20160823202445.14368.4352.stgit@john-Precision-Tower-5810>
 <1472056898.14381.95.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, davem@davemloft.net, brouer@redhat.com,
        xiyou.wangcong@gmail.com, alexei.starovoitov@gmail.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35259 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753148AbcHXSFp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 14:05:45 -0400
Received: by mail-pa0-f66.google.com with SMTP id cf3so1569724pad.2
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 11:04:21 -0700 (PDT)
In-Reply-To: <1472056898.14381.95.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-24 09:41 AM, Eric Dumazet wrote:
> On Tue, 2016-08-23 at 13:24 -0700, John Fastabend wrote:
>> Enable dflt qdisc support for per cpu stats before this patch a
>> dflt qdisc was required to use the global statistics qstats and
>> bstats.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>>  net/sched/sch_generic.c |   24 ++++++++++++++++++++----
>>  1 file changed, 20 insertions(+), 4 deletions(-)
>>
>> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
>> index 80544c2..910b4d15 100644
>> --- a/net/sched/sch_generic.c
>> +++ b/net/sched/sch_generic.c
>> @@ -646,18 +646,34 @@ struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
>>  	struct Qdisc *sch;
>>  
>>  	if (!try_module_get(ops->owner))
>> -		goto errout;
>> +		return NULL;
>>  
>>  	sch = qdisc_alloc(dev_queue, ops);
>>  	if (IS_ERR(sch))
>> -		goto errout;
>> +		return NULL;
>>  	sch->parent = parentid;
>>  
>> -	if (!ops->init || ops->init(sch, NULL) == 0)
>> +	if (!ops->init)
>>  		return sch;
>>  
>> -	qdisc_destroy(sch);
>> +	if (ops->init(sch, NULL))
>> +		goto errout;
>> +
>> +	/* init() may have set percpu flags so init data structures */
>> +	if (qdisc_is_percpu_stats(sch)) {
>> +		sch->cpu_bstats =
>> +			netdev_alloc_pcpu_stats(struct gnet_stats_basic_cpu);
>> +		if (!sch->cpu_bstats)
>> +			goto errout;
>> +
>> +		sch->cpu_qstats = alloc_percpu(struct gnet_stats_queue);
>> +		if (!sch->cpu_qstats)
>> +			goto errout;
>> +	}
>> +
> 
> Why are you attempting these allocations here instead of qdisc_alloc()
> 
> This looks weird, I would expect base qdisc being fully allocated before
> ops->init() is attempted.
> 
> 
> 

I could fully allocate it in qdisc_alloc() but we don't know if the
qdisc needs per cpu data structures until after the init call. So it
would sit unused in those cases if done from qdisc_alloc(). It seems
best to me at least to just avoid the allocation in qdisc_alloc() and
do it after init like I did here.

Perhaps it would be nice to pull these into a function call
post_init_qdisc_alloc() that does all this allocation?

.John
