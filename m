From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: Re: [PATCH 1/7] Preparatory refactoring part 1.
Date: Mon, 30 Jul 2007 18:26:47 -0700
Message-ID: <46AE8FD7.3010201@fatooh.org>
References: <11857548771998-git-send-email-bugfood-ml@fatooh.org> <11857548774008-git-send-email-bugfood-ml@fatooh.org> <46ADECC9.7010303@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:35997 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759355AbXGaB0t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jul 2007 21:26:49 -0400
In-Reply-To: <46ADECC9.7010303@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
>> -static int
>> -sfq_enqueue(struct sk_buff *skb, struct Qdisc* sch)
>> +static void sfq_q_enqueue(struct sk_buff *skb, struct sfq_sched_data *q, unsigned int end)
> 
> 
> Please make sure to break at 80 chars and to keep the style
> in this file consistent (newline before function name).

Ok. For what it's worth, though, most of the original functions in the 
file don't have a newline before the function name. Omitting the newline 
  would thus make the new/changed functions more consistent with the 
rest of the file. I don't have a preference either way, so unless you 
change your mind I'll put the newline back in..

>>  {
>> -	struct sfq_sched_data *q = qdisc_priv(sch);
>>  	unsigned hash = sfq_hash(q, skb);
>>  	sfq_index x;
>>  
>> @@ -256,8 +257,12 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc* sch)
>>  		q->ht[hash] = x = q->dep[SFQ_DEPTH].next;
>>  		q->hash[x] = hash;
>>  	}
>> -	sch->qstats.backlog += skb->len;
> 
> Why not keep this instead of having both callers do it?

My idea was to have all the sfq_q_* functions operate on "struct 
sfq_sched_data" and have no knowledge of the "struct Qdisc". I did this 
in order to be able to use the new functions in sfq_change() when the 
temporary sfq_sched_data doesn't have a parent Qdisc.

There's probably a better way, and I am of course open to suggestions, 
but what I did made sense to me.

>> -	__skb_queue_tail(&q->qs[x], skb);
>> +
>> +	if (end == SFQ_TAIL)
>> +		__skb_queue_tail(&q->qs[x], skb);
>> +	else
>> +		__skb_queue_head(&q->qs[x], skb);
>> +
>>  	sfq_inc(q, x);
>>  	if (q->qs[x].qlen == 1) {		/* The flow is new */
>>  		if (q->tail == SFQ_DEPTH) {	/* It is the first flow */
>> @@ -270,12 +275,21 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc* sch)
>>  			q->tail = x;
>>  		}
>>  	}
>> +}
>> +
>> +static int
>> +sfq_enqueue(struct sk_buff *skb, struct Qdisc* sch)
>> +{
>> +	struct sfq_sched_data *q = qdisc_priv(sch);
> 
> newline please.

Ok.

>> +	sfq_q_enqueue(skb, q, SFQ_TAIL);
>> +	sch->qstats.backlog += skb->len;
>>  	if (++sch->q.qlen < q->limit-1) {
>>  		sch->bstats.bytes += skb->len;
>>  		sch->bstats.packets++;
>>  		return 0;
>>  	}
>>  
>> +	sch->qstats.drops++;
> 
> sfq_drop already increments this.

You're right, of course. When I look at the original sfq_requeue(), 
though, I see that same line right before sfq_drop(). That's probably 
why it ended up in my patch. Is that a bug? The original sfq_enqueue() 
doesn't have that line.

http://git.kernel.org/?p=linux/kernel/git/jgarzik/netdev-2.6.git;a=blob;f=net/sched/sch_sfq.c
line 314

>>  	sfq_drop(sch);
>>  	return NET_XMIT_CN;
>>  }
>> @@ -284,28 +298,8 @@ static int
>>  sfq_requeue(struct sk_buff *skb, struct Qdisc* sch)
>>  {
>>  	struct sfq_sched_data *q = qdisc_priv(sch);
> 
> newline please

Ok.

>> -static struct sk_buff *
>> -sfq_dequeue(struct Qdisc* sch)
>> +static struct sk_buff *sfq_q_dequeue(struct sfq_sched_data *q)
> 
> 
> Keep style consistent please.

Ok.

Thank you for the review. I'll address the rest of your comments when I 
have time later.

-Corey
