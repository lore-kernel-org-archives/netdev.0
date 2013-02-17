From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v5 10/11] tbf: take into account gso skbs
Date: Sun, 17 Feb 2013 17:18:03 +0100
Message-ID: <20130217161803.GB1931@minipsycho.orion>
References: <1360663929-1023-1-git-send-email-jiri@resnulli.us>
 <1360663929-1023-11-git-send-email-jiri@resnulli.us>
 <1360687182.6884.5.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	jhs@mojatatu.com, kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:56558 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750994Ab3BQQSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Feb 2013 11:18:09 -0500
Received: by mail-ee0-f50.google.com with SMTP id e51so2485729eek.9
        for <netdev@vger.kernel.org>; Sun, 17 Feb 2013 08:18:08 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1360687182.6884.5.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Feb 12, 2013 at 05:39:42PM CET, eric.dumazet@gmail.com wrote:
>On Tue, 2013-02-12 at 11:12 +0100, Jiri Pirko wrote:
>> Ignore max_size check for gso skbs. This check made bigger packets
>> incorrectly dropped. Remove this limitation for gso skbs.
>> 
>> Also for peaks, ignore mtu for gso skbs.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>>  net/sched/sch_tbf.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>> 
>> diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
>> index c8388f3..8973e93 100644
>> --- a/net/sched/sch_tbf.c
>> +++ b/net/sched/sch_tbf.c
>> @@ -121,7 +121,7 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>>  	struct tbf_sched_data *q = qdisc_priv(sch);
>>  	int ret;
>>  
>> -	if (qdisc_pkt_len(skb) > q->max_size)
>> +	if (qdisc_pkt_len(skb) > q->max_size && !skb_is_gso(skb))
>>  		return qdisc_reshape_fail(skb, sch);
>>  
>>  	ret = qdisc_enqueue(skb, q->qdisc);
>> @@ -165,7 +165,7 @@ static struct sk_buff *tbf_dequeue(struct Qdisc *sch)
>>  
>>  		if (q->peak_present) {
>>  			ptoks = toks + q->ptokens;
>> -			if (ptoks > q->mtu)
>> +			if (ptoks > q->mtu && !skb_is_gso(skb))
>>  				ptoks = q->mtu;
>>  			ptoks -= (s64) psched_l2t_ns(&q->peak, len);
>>  		}
>
>
>I guess this part is wrong.
>
>If we dont cap ptoks to q->mtu we allow bigger bursts.


I'm going through this issue back and front and on the second thought,
I think this patch might not be so wrong after all.

"Accumulating" time in ptoks would effectively cause the skb to be sent
only in case time for whole skb is available (accumulated).

The re-segmenting will only cause the skb fragments sent in each time frame.

I can't see how the bigger bursts you are reffering to can happen.

Or am I missing something?

>
>Ideally we could re-segment the skb if psched_l2t_ns(&q->peak, len) is
>bigger than q->mtu
>
>
>
>
>
>
