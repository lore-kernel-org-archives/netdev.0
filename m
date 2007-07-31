From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: Re: [PATCH 2/7] Preparatory refactoring part 2.
Date: Tue, 31 Jul 2007 00:43:43 -0700
Message-ID: <46AEE82F.5040603@fatooh.org>
References: <11857548771998-git-send-email-bugfood-ml@fatooh.org> <11857548771609-git-send-email-bugfood-ml@fatooh.org> <46ADEEC5.9030600@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:55492 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751344AbXGaHnk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2007 03:43:40 -0400
In-Reply-To: <46ADEEC5.9030600@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Corey Hickey wrote:
>> diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
>> index 8ae077f..0c46938 100644
>> --- a/net/sched/sch_sfq.c
>> +++ b/net/sched/sch_sfq.c
>> @@ -380,71 +380,71 @@ static void sfq_perturbation(unsigned long arg)
>>  	}
>>  }
>>  
>> -static int sfq_change(struct Qdisc *sch, struct rtattr *opt)
>> +static int sfq_q_init(struct sfq_sched_data *q, struct rtattr *opt)
>>  {
>> -	struct sfq_sched_data *q = qdisc_priv(sch);
>>  	struct tc_sfq_qopt *ctl = RTA_DATA(opt);
>> -	unsigned int qlen;
>> +	int i;
>>  
>> -	if (opt->rta_len < RTA_LENGTH(sizeof(*ctl)))
>> +	if (opt && opt->rta_len < RTA_LENGTH(sizeof(*ctl)))
> 
> 
> opt is dereferenced above (RTA_DATA), so if it is NULL we've already
> crashed.

I think that test made ESFQ not crash when I did a "qdisc change" 
without giving any parameters, but that was a while ago and I might be 
mistaken. I'll need to rewrite much of this function anyway, and I'll 
pay attention to what happens when I get there.

>>  		return -EINVAL;
>>  
>> -	sch_tree_lock(sch);
>> -	q->quantum = ctl->quantum ? : psched_mtu(sch->dev);
>> -	q->perturb_period = ctl->perturb_period*HZ;
>> -	if (ctl->limit)
>> -		q->limit = min_t(u32, ctl->limit, SFQ_DEPTH);
>> +	q->perturbation = 0;
>> +	q->max_depth = 0;
>> +	q->tail = q->limit = SFQ_DEPTH;
>> +	if (opt == NULL) {
>> +		q->perturb_period = 0;
>> +	} else {
>> +		struct tc_sfq_qopt *ctl = RTA_DATA(opt);
>> +		if (ctl->quantum)
>> +			q->quantum = ctl->quantum;
>> +		q->perturb_period = ctl->perturb_period*HZ;
>>  
>> -	qlen = sch->q.qlen;
>> -	while (sch->q.qlen >= q->limit-1)
>> -		sfq_drop(sch);
>> -	qdisc_tree_decrease_qlen(sch, qlen - sch->q.qlen);
> 
> 
> I hope that patch that makes changing possible brings this back ..
> <checking> .. it doesn't. Please either keep this or fix up 6/7
> to bring it back.

It got lost in translation; I will add it to 6/7.

Thanks,
Corey
