From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 2/6] pkt_sched: sch_htb: Consider used jiffies in
	htb_dequeue()
Date: Tue, 9 Dec 2008 11:32:05 +0000
Message-ID: <20081209113205.GA15353@ff.dom.local>
References: <20081209102118.GB14862@ff.dom.local> <493E485C.9090706@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Martin Devera <devik@cdi.cz>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:41235 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753041AbYLILcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 06:32:11 -0500
Received: by nf-out-0910.google.com with SMTP id d3so790713nfc.21
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2008 03:32:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <493E485C.9090706@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 09, 2008 at 11:28:44AM +0100, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> Next event time should consider jiffies used for recounting. Otherwise
>> qdisc_watchdog_schedule() triggers hrtimer immediately with the event
>> in the past, and may cause very high ksoftirqd cpu usage (if highres
>> is on). This patch charges jiffies globally, so we can skip this in
>> htb_do_events().
>>
>> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
>> ---
>>  net/sched/sch_htb.c |   14 ++++++++++++--
>>  1 files changed, 12 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
>> index d6eb4a7..102866d 100644
>> --- a/net/sched/sch_htb.c
>> +++ b/net/sched/sch_htb.c
>> @@ -685,8 +685,11 @@ static psched_time_t htb_do_events(struct htb_sched *q, int level)
>>  		if (cl->cmode != HTB_CAN_SEND)
>>  			htb_add_to_wait_tree(q, cl, diff);
>>  	}
>> -	/* too much load - let's continue on next jiffie (including above) */
>> -	return q->now + 2 * PSCHED_TICKS_PER_SEC / HZ;
>> +	/*
>> +	 * Too much load - let's continue on next jiffie.
>> +	 * (Used jiffies are charged later.)
>> +	 */
>> +	return q->now + 1;
>>  
>
> This (including the last patch) is really confusing - q->now doesn't
> contain HZ values but psched ticks. Could you describe the overall
> algorithm you're trying to implement please?

The algorithm is we want to "continue on the next jiffie". We know
we've lost here a lot of time (~2 jiffies), and this will be added
later. Since these jiffies are not precise enough wrt. psched ticks
or ktime, and we will add around 2000 (for HZ 1000) psched ticks
anyway this +1 here simply doesn't matter and can mean "a bit after
q->now".

We can try to do this more precisely with additional psched_get_time(),
instead of jiffies, but my "tests" didn't show any advantage. What
matters is to avoid longer scheduling with the past time.

This case can probably happen only with very low rate limits for a
large number of classes, and I guess they simply need some spare time,
not necessarily at psched tick precision.

Jarek P.
