From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: Re: [PATCH 4/7] Add "depth".
Date: Sun, 29 Jul 2007 13:21:15 -0700
Message-ID: <46ACF6BB.7010703@fatooh.org>
References: <11856929352537-git-send-email-bugfood-ml@fatooh.org> <11856929352115-git-send-email-bugfood-ml@fatooh.org> <11856929362692-git-send-email-bugfood-ml@fatooh.org> <200707292041.45495.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:45707 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933564AbXG2UVP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Jul 2007 16:21:15 -0400
In-Reply-To: <200707292041.45495.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Sunday 29 July 2007 09:08:51 Corey Hickey wrote:
>>  	p = d;
>>  	n = q->dep[d].next;
>> @@ -215,7 +216,7 @@ static unsigned int sfq_drop(struct Qdisc *sch)
>>  	   drop a packet from it */
>>  
>>  	if (d > 1) {
>> -		sfq_index x = q->dep[d+SFQ_DEPTH].next;
>> +		sfq_index x = q->dep[d+q->depth].next;
> 
> Please q->dep[d + q->depth]
> Makes it _much_ more readable. And doesn't confuse my brain with a
> minus and a BiggerThan sign ;)

Ok.

>> @@ -383,6 +384,16 @@ static void sfq_perturbation(unsigned long arg)
>>  static void sfq_q_destroy(struct sfq_sched_data *q)
>>  {
>>  	del_timer(&q->perturb_timer);
>> +	if(q->dep)
>> +		kfree(q->dep);
>> +	if(q->next)
>> +		kfree(q->next);
>> +	if(q->allot)
>> +		kfree(q->allot);
>> +	if(q->hash)
>> +		kfree(q->hash);
>> +	if(q->qs)
>> +		kfree(q->qs);
> 
> No need to check for !=NULL. kfree handles NULL.

Ok. Thanks.

>>  }
>>  
>>  static void sfq_destroy(struct Qdisc *sch)
>> @@ -394,6 +405,7 @@ static void sfq_destroy(struct Qdisc *sch)
>>  static int sfq_q_init(struct sfq_sched_data *q, struct rtattr *opt)
>>  {
>>  	struct tc_sfq_qopt *ctl = RTA_DATA(opt);
>> +	sfq_index p = ~0U/2;
>>  	int i;
>>  
>>  	if (opt && opt->rta_len < RTA_LENGTH(sizeof(*ctl)))
>> @@ -401,30 +413,53 @@ static int sfq_q_init(struct sfq_sched_data *q, struct rtattr *opt)
>>  
>>  	q->perturbation = 0;
>>  	q->max_depth = 0;
>> -	q->tail = q->limit = SFQ_DEPTH;
>>  	if (opt == NULL) {
>>  		q->perturb_period = 0;
>> +		q->tail = q->limit = q->depth = SFQ_DEPTH_DEFAULT;
>>  	} else {
>>  		struct tc_sfq_qopt *ctl = RTA_DATA(opt);
>>  		if (ctl->quantum)
>>  			q->quantum = ctl->quantum;
>>  		q->perturb_period = ctl->perturb_period*HZ;
>> +		q->tail = q->limit = q->depth = ctl->flows ? : SFQ_DEPTH_DEFAULT;
>> +
>> +		if (q->depth > p - 1)
>> +			return -EINVAL;
> 
> Compare depth against (~0U/2)-1? What's that doing? Should probably add a comment.

~0U/2 - 1 is the maximum value depth can be, based on how it is used in 
indexing q->dep. I agree, though, that deserves a comment. Actually, 
I'll also change it to '#define SFQ_DEPTH_MAX (~0U/2 - 1)' and put it 
near the top of the file next to the 'typedef unsigned int sfq_index;'.

I could also include limits.h and use UINT_MAX instead of ~0U; would 
that be preferable?

>>  
>>  		if (ctl->limit)
>> -			q->limit = min_t(u32, ctl->limit, SFQ_DEPTH);
>> +			q->limit = min_t(u32, ctl->limit, q->depth);
>>  	}
>>  
>> +	q->dep = kmalloc((1+q->depth*2)*sizeof(struct sfq_head), GFP_KERNEL);
>> +	if (!q->dep)
>> +		goto err_case;
>> +	q->next = kmalloc(q->depth*sizeof(sfq_index), GFP_KERNEL);
>> +	if (!q->next)
>> +		goto err_case;
>> +	q->allot = kmalloc(q->depth*sizeof(short), GFP_KERNEL);
>> +	if (!q->allot)
>> +		goto err_case;
>> +	q->hash = kmalloc(q->depth*sizeof(unsigned short), GFP_KERNEL);
>> +	if (!q->hash)
>> +		goto err_case;
>> +	q->qs = kmalloc(q->depth*sizeof(struct sk_buff_head), GFP_KERNEL);
>> +	if (!q->qs)
>> +		goto err_case;
> 
> You may chose to use kcalloc for array allocations.

The arrays in the original code don't get zeroed either, so that 
shouldn't be necessary (and I haven't heard of any problems so far). Do 
you suggest I use kcalloc() anyway, just as a good practice?

>>  	for (i=0; i<SFQ_HASH_DIVISOR; i++)
>> -		q->ht[i] = SFQ_DEPTH;
>> -	for (i=0; i<SFQ_DEPTH; i++) {
>> +		q->ht[i] = q->depth;
>> +	for (i=0; i<q->depth; i++) {
>>  		skb_queue_head_init(&q->qs[i]);
>> -		q->dep[i+SFQ_DEPTH].next = i+SFQ_DEPTH;
>> -		q->dep[i+SFQ_DEPTH].prev = i+SFQ_DEPTH;
>> +		q->dep[i+q->depth].next = i+q->depth;
>> +		q->dep[i+q->depth].prev = i+q->depth;
>>  	}
>>  
>> -	for (i=0; i<SFQ_DEPTH; i++)
>> +	for (i=0; i<q->depth; i++)
>>  		sfq_link(q, i);
>>  	return 0;
>> +err_case:
> 
> This leaks a few kmallocs.

Are you saying that the 'err_case:' leaks kmallocs? It calls 
sfq_q_destroy(q), which kfrees each of the arrays: dep, next, allot, 
hash, and qs. Is that sufficient, or am I missing something or 
misunderstanding you?

>> +	sfq_q_destroy(q);
>> +	return -ENOBUFS;
>>  }

Thank you for your review. Could you please clarify the questions I 
have? I'll make, test, and submit a revision of this patch after that.

-Corey
