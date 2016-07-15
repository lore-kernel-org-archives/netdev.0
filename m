From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH v2 08/10] net: sched: pfifo_fast use alf_queue
Date: Thu, 14 Jul 2016 17:07:33 -0700
Message-ID: <57882945.4090101@gmail.com>
References: <20160714061852.8270.66271.stgit@john-Precision-Tower-5810>
 <20160714062312.8270.65942.stgit@john-Precision-Tower-5810>
 <20160714234207.GA93671@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, jhs@mojatatu.com, eric.dumazet@gmail.com,
	brouer@redhat.com, netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33636 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751285AbcGOAHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 20:07:45 -0400
Received: by mail-pf0-f196.google.com with SMTP id i6so5159403pfe.0
        for <netdev@vger.kernel.org>; Thu, 14 Jul 2016 17:07:45 -0700 (PDT)
In-Reply-To: <20160714234207.GA93671@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-07-14 04:42 PM, Alexei Starovoitov wrote:
> On Wed, Jul 13, 2016 at 11:23:12PM -0700, John Fastabend wrote:
>> This converts the pfifo_fast qdisc to use the alf_queue enqueue and
>> dequeue routines then sets the NOLOCK bit.
>>
>> This also removes the logic used to pick the next band to dequeue from
>> and instead just checks each alf_queue for packets from top priority
>> to lowest. This might need to be a bit more clever but seems to work
>> for now.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>>  net/sched/sch_generic.c |  131 +++++++++++++++++++++++++++--------------------
> 
>>  static int pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc *qdisc,
>>  			      struct sk_buff **to_free)
>>  {
>> -	return qdisc_drop(skb, qdisc, to_free);
>> +	err = skb_array_produce_bh(q, skb);
> ..
>>  static struct sk_buff *pfifo_fast_dequeue(struct Qdisc *qdisc)
>>  {
>> +		skb = skb_array_consume_bh(q);
> 
> For this particular qdisc the performance gain should come from
> granularityof spin_lock, right?

And the fact that the consumer and producer are using different
locks now.

> Before we were taking the lock much earlier. Here we keep the lock,
> but for the very short time.
>         original pps        lockless        diff
>         1       1418168             1269450         -148718
>         2       1587390             1553408         -33982
>         4       1084961             1683639         +598678
>         8       989636              1522723         +533087
>         12      1014018             1348172         +334154
> so perf for 1 cpu case is mainly due to array vs list,
> since number of locks is still the same and there is no collision ?
> but then why shorter lock give higher overhead in multi cpu cases?

So in this case running pfifo_fast as the root qdisc with 12 threads
means we have 12 producers hitting a single enqueue() path where as with
mq and only looking at pktgen numbers we have one thread for each
skb_array.

> That would have been the main target for performance improvement?
> 

Maybe I should fire up a TCP test with 1000's of threads to see what
the perf numbers look like.

> Looks like mq gets the most benefit, because it's lockless internally
> which makes sense.
> In general I think this is the right direction where tc infra should move to.
> I'm only not sure whether it's worth converting pfifo to skb_array.
> Probably alf queue would have been a better alternative.
> 

Tomorrows task is to resurrect the alf_queue and look at its numbers
compared to this. Today was spent trying to remove the HARD_TX_LOCK
that protects the driver, in the mq case it seems this is not really
needed either.

.John
