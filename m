From: Lars Persson <lars.persson@axis.com>
Subject: Re: [PATCH net v2] net: sched: do not requeue a NULL skb
Date: Mon, 11 Apr 2016 15:38:15 +0200
Message-ID: <570BA8C7.1000905@axis.com>
References: <1460355869-13539-1-git-send-email-larper@axis.com> <1460380981.6473.544.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <jhs@mojatatu.com>,
	<linux-kernel@vger.kernel.org>, <xiyou.wangcong@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Lars Persson <larper@axis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bastet.se.axis.com ([195.60.68.11]:37345 "EHLO
	bastet.se.axis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932583AbcDKNiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 09:38:21 -0400
In-Reply-To: <1460380981.6473.544.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/11/2016 03:23 PM, Eric Dumazet wrote:
> On Mon, 2016-04-11 at 08:24 +0200, Lars Persson wrote:
>> A failure in validate_xmit_skb_list() triggered an unconditional call
>> to dev_requeue_skb with skb=NULL. This slowly grows the queue
>> discipline's qlen count until all traffic through the queue stops.
>>
>> By introducing a NULL check in dev_requeue_skb it was also necessary
>> to make the __netif_schedule call conditional to avoid scheduling an
>> empty queue.
>>
>> Fixes: 55a93b3ea780 ("qdisc: validate skb without holding lock")
>> Signed-off-by: Lars Persson <larper@axis.com>
>> ---
>>   net/sched/sch_generic.c | 11 +++++++----
>>   1 file changed, 7 insertions(+), 4 deletions(-)
>>
>> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
>> index f18c350..4e6a79c 100644
>> --- a/net/sched/sch_generic.c
>> +++ b/net/sched/sch_generic.c
>> @@ -47,10 +47,13 @@ EXPORT_SYMBOL(default_qdisc_ops);
>>
>>   static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
>>   {
>> -	q->gso_skb = skb;
>> -	q->qstats.requeues++;
>> -	q->q.qlen++;	/* it's still part of the queue */
>> -	__netif_schedule(q);
>> +	if (skb) {
>> +		q->gso_skb = skb;
>> +		q->qstats.requeues++;
>> +		q->q.qlen++;	/* it's still part of the queue */
>> +	}
>> +	if (qdisc_qlen(q))
>> +		__netif_schedule(q);
>>
>>   	return 0;
>>   }
>
>
> Please always CC patch author when fixing a bug.
>
> Why adding the if (qdisc_qlen(q)) extra test ?
>
> This seems unrelated to the bug fix, and probably should be part of a
> second patch targeting net-next tree.

I though it would be prudent because the queue can be non-empty even for 
the case of skb=NULL. So should it be there in this patch, another patch 
or not at all ?

>
> Also please add a likely() clause
>
> if (likely(skb)) {
>          q->gso_skb = skb;
>          q->qstats.requeues++;
>          q->q.qlen++;    /* it's still part of the queue */
>          __netif_schedule(q);
> }

Will fix.

> Thanks !
>
>
>
>
>
