From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 2/6] pkt_sched: sch_htb: Consider used jiffies in
	htb_dequeue()
Date: Tue, 9 Dec 2008 13:08:03 +0000
Message-ID: <20081209130803.GB15353@ff.dom.local>
References: <20081209102118.GB14862@ff.dom.local> <493E485C.9090706@trash.net> <20081209113205.GA15353@ff.dom.local> <493E63AB.80400@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Martin Devera <devik@cdi.cz>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:1280 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751742AbYLINIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 08:08:11 -0500
Received: by ug-out-1314.google.com with SMTP id 39so1081356ugf.37
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2008 05:08:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <493E63AB.80400@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 09, 2008 at 01:25:15PM +0100, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> On Tue, Dec 09, 2008 at 11:28:44AM +0100, Patrick McHardy wrote:
>>>> -	/* too much load - let's continue on next jiffie (including above) */
>>>> -	return q->now + 2 * PSCHED_TICKS_PER_SEC / HZ;
>>>> +	/*
>>>> +	 * Too much load - let's continue on next jiffie.
>>>> +	 * (Used jiffies are charged later.)
>>>> +	 */
>>>> +	return q->now + 1;
>>>>  
>>> This (including the last patch) is really confusing - q->now doesn't
>>> contain HZ values but psched ticks. Could you describe the overall
>>> algorithm you're trying to implement please?
>>
>> The algorithm is we want to "continue on the next jiffie". We know
>> we've lost here a lot of time (~2 jiffies), and this will be added
>> later. Since these jiffies are not precise enough wrt. psched ticks
>> or ktime, and we will add around 2000 (for HZ 1000) psched ticks
>> anyway this +1 here simply doesn't matter and can mean "a bit after
>> q->now".
>
> This might as well return q->now, no?

Yes, but IMHO it looks worse, considering the problem here (we want to
avoid scheduling in the past).

> The elapsed time is added
> on top later anyways. But anyways, I think both the approach and
> the patch are wrong.
>
> 	/* charge used jiffies */
> 	start_at = jiffies - start_at;
> 	if (start_at > 0)
> 		next_event += start_at * PSCHED_TICKS_PER_SEC / HZ;
>
> What relationship does the duration it ran for has to the time it
> should run at again?

The scheduling times won't be in the past mostly and hrtimers won't
trigger too soon, but approximately around we really need and can
afford a new try without stopping everything else.

> The focus on jiffies is wrong IMO, the reason why we get high
> load is because the CPU can't keep up, delaying things even
> longer is not going to help get the work done. The only reason to
> look at jiffies is because its a cheap indication that it has
> ran for too long and we should give other tasks a change to run
> as well, but it should continue immediately after it did that.
> So all it should do is make sure that the watchdog is scheduled
> with a very small positive delay.

This needs additional psched_get_time(), and as I've written before
there is no apparent advantage in problematic cases, but this would
add more overhead for common cases.

> As for the implementation: the increase in delay (the snippet
> above) is also done in the case that no packets were available
> for other reasons (throttling), in which case we might needlessly
> delay for an extra jiffie if jiffies wrapped while it tried to
> dequeue.

But in another similar cases there could be no change in jiffies, but
almost a jiffie used for counting, so wrong schedule time as well.
Approximatly this all should be fine, and it still can be tuned later.
IMHO, this all should not affect "common" cases, which are expected to
use less then jiffie here.

Jarek P.
