From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3 08/11] tbf: fix value set for q->ptokens
Date: Sun, 10 Feb 2013 09:18:24 +0100
Message-ID: <20130210081824.GA1570@minipsycho.orion>
References: <1360428312-1277-1-git-send-email-jiri@resnulli.us>
 <1360428312-1277-9-git-send-email-jiri@resnulli.us>
 <1360459846.20362.2.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	jhs@mojatatu.com, kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:44323 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752461Ab3BJIS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 03:18:28 -0500
Received: by mail-ea0-f175.google.com with SMTP id d1so2224531eab.20
        for <netdev@vger.kernel.org>; Sun, 10 Feb 2013 00:18:27 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1360459846.20362.2.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Feb 10, 2013 at 02:30:46AM CET, eric.dumazet@gmail.com wrote:
>On Sat, 2013-02-09 at 17:45 +0100, Jiri Pirko wrote:
>> q->ptokens is in ns and we are assigning q->mtu directly to it. That is
>> wrong. psched_l2t_ns() should be used to compute correct value.
>> 
>
>
>Not clear why its a separate patch, and not folded in the 6th

This is independent on 6th. Would be needed even if 6th wouldn't be
there.

>
>
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>>  net/sched/sch_tbf.c | 9 +++++----
>>  1 file changed, 5 insertions(+), 4 deletions(-)
>> 
>> diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
>> index dc562a8..6e8b670 100644
>> --- a/net/sched/sch_tbf.c
>> +++ b/net/sched/sch_tbf.c
>> @@ -165,8 +165,8 @@ static struct sk_buff *tbf_dequeue(struct Qdisc *sch)
>>  
>>  		if (q->peak_present) {
>>  			ptoks = toks + q->ptokens;
>> -			if (ptoks > (long)q->mtu)
>> -				ptoks = q->mtu;
>> +			if (ptoks > (s64) psched_l2t_ns(&q->peak, q->mtu))
>> +				ptoks = (s64) psched_l2t_ns(&q->peak, q->mtu);
>
>It seems a bit expensive to perform this in fast path.
>
>Please add a variable to cache psched_l2t_ns(&q->peak, q->mtu)

Okay, I did not think that this is necessary, but sure, I will do that.

Thanks!

>
>
>>  			ptoks -= (s64) psched_l2t_ns(&q->peak, len);
>>  		}
>>  		toks += q->tokens;
>> @@ -215,7 +215,8 @@ static void tbf_reset(struct Qdisc *sch)
>>  	sch->q.qlen = 0;
>>  	q->t_c = ktime_to_ns(ktime_get());
>>  	q->tokens = q->buffer;
>> -	q->ptokens = q->mtu;
>> +	if (q->peak_present)
>> +		q->ptokens = (s64) psched_l2t_ns(&q->peak, q->mtu);
>>  	qdisc_watchdog_cancel(&q->watchdog);
>>  }
>>  
>> @@ -296,11 +297,11 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
>>  	q->max_size = max_size;
>>  	q->buffer = PSCHED_TICKS2NS(qopt->buffer);
>>  	q->tokens = q->buffer;
>> -	q->ptokens = q->mtu;
>>  
>>  	psched_ratecfg_precompute(&q->rate, rtab->rate.rate);
>>  	if (ptab) {
>>  		psched_ratecfg_precompute(&q->peak, ptab->rate.rate);
>> +		q->ptokens = (s64) psched_l2t_ns(&q->peak, q->mtu);
>
>Here probably.
>
>
>
