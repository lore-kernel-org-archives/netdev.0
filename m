From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 2/6] pkt_sched: sch_htb: Consider used jiffies in
	htb_dequeue()
Date: Tue, 9 Dec 2008 14:45:34 +0000
Message-ID: <20081209144534.GC15353@ff.dom.local>
References: <20081209102118.GB14862@ff.dom.local> <493E485C.9090706@trash.net> <20081209113205.GA15353@ff.dom.local> <493E63AB.80400@trash.net> <20081209130803.GB15353@ff.dom.local> <493E7080.5060308@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Martin Devera <devik@cdi.cz>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.181]:49116 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752649AbYLIOpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 09:45:42 -0500
Received: by ik-out-1112.google.com with SMTP id c29so1360286ika.5
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2008 06:45:40 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <493E7080.5060308@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To David Miller: David don't apply yet - this patch needs change.

Patrick, read below:

On Tue, Dec 09, 2008 at 02:20:00PM +0100, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> On Tue, Dec 09, 2008 at 01:25:15PM +0100, Patrick McHardy wrote:
>>> Jarek Poplawski wrote:
>>>> The algorithm is we want to "continue on the next jiffie". We know
>>>> we've lost here a lot of time (~2 jiffies), and this will be added
>>>> later. Since these jiffies are not precise enough wrt. psched ticks
>>>> or ktime, and we will add around 2000 (for HZ 1000) psched ticks
>>>> anyway this +1 here simply doesn't matter and can mean "a bit after
>>>> q->now".
>>> This might as well return q->now, no?
>>
>> Yes, but IMHO it looks worse, considering the problem here (we want to
>> avoid scheduling in the past).
>
> I guess its a matter of taste.

Exactly. (And could be changed.)

>
>>> The elapsed time is added
>>> on top later anyways. But anyways, I think both the approach and
>>> the patch are wrong.
>>>
>>> 	/* charge used jiffies */
>>> 	start_at = jiffies - start_at;
>>> 	if (start_at > 0)
>>> 		next_event += start_at * PSCHED_TICKS_PER_SEC / HZ;
>>>
>>> What relationship does the duration it ran for has to the time it
>>> should run at again?
>>
>> The scheduling times won't be in the past mostly and hrtimers won't
>> trigger too soon, but approximately around we really need and can
>> afford a new try without stopping everything else.
>
> Sure. But it also won't be in the past if we simply add .. lets say
> the current uptime in ms. My point was that there's absolutely no
> relationship between those two times and combining them just to
> get a value thats not in the past is wrong. Especially considering
> *why* we want a value in the future and what we'll get from that
> calculation.
>
>>> The focus on jiffies is wrong IMO, the reason why we get high
>>> load is because the CPU can't keep up, delaying things even
>>> longer is not going to help get the work done. The only reason to
>>> look at jiffies is because its a cheap indication that it has
>>> ran for too long and we should give other tasks a change to run
>>> as well, but it should continue immediately after it did that.
>>> So all it should do is make sure that the watchdog is scheduled
>>> with a very small positive delay.
>>
>> This needs additional psched_get_time(), and as I've written before
>> there is no apparent advantage in problematic cases, but this would
>> add more overhead for common cases.
>
> htb_do_events() exceeding two jiffies is fortunately not a common
> case. You (incorrectly) made the calculation somewhat of a common
> case by also adding to the delay if the inner classes simply throttled
> and already returned the exact delay they want.

I see! You are right and this needs fixing.

> Much better (again considering what we want to achieve here) would
> be to not use the hrtimer watchdog at all. We want to give lower
> priority tasks a chance to run, so ideally we'd use a low priority
> task for wakeup.

I'm not sure I get ot right: for precise scheduling hrtimers look
useful. Do you really mean "at all"?
 
>
>>> As for the implementation: the increase in delay (the snippet
>>> above) is also done in the case that no packets were available
>>> for other reasons (throttling), in which case we might needlessly
>>> delay for an extra jiffie if jiffies wrapped while it tried to
>>> dequeue.
>>
>> But in another similar cases there could be no change in jiffies, but
>> almost a jiffie used for counting, so wrong schedule time as well.
>
> Its not "wrong". We don't want to delay. Its a courtesy to the
> remaining system.

In this case it's probably self-courtesy too: this ksoftirqd takes
most of the time and it's useless.

>
>> Approximatly this all should be fine, and it still can be tuned later.
>> IMHO, this all should not affect "common" cases, which are expected to
>> use less then jiffie here.
>
> Jiffies might wrap even if it only took only a few nanoseconds.
> And its not fine, in the case of throttled classes there's no
> reason to add extra delay *at all*.

Yes, you are right with this. I can try too fix this tomorrow, unless
you prefer to send your version of this patch.

Thanks,
Jarek P.
