From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/6] pkt_sched: sch_htb: Consider used jiffies in	htb_dequeue()
Date: Tue, 09 Dec 2008 15:56:09 +0100
Message-ID: <493E8709.5070601@trash.net>
References: <20081209102118.GB14862@ff.dom.local> <493E485C.9090706@trash.net> <20081209113205.GA15353@ff.dom.local> <493E63AB.80400@trash.net> <20081209130803.GB15353@ff.dom.local> <493E7080.5060308@trash.net> <20081209144534.GC15353@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Martin Devera <devik@cdi.cz>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:32989 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752738AbYLIO4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 09:56:15 -0500
In-Reply-To: <20081209144534.GC15353@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> To David Miller: David don't apply yet - this patch needs change.
> 
> Patrick, read below:
> 
> On Tue, Dec 09, 2008 at 02:20:00PM +0100, Patrick McHardy wrote:
>>>>
>>>> The focus on jiffies is wrong IMO, the reason why we get high
>>>> load is because the CPU can't keep up, delaying things even
>>>> longer is not going to help get the work done. The only reason to
>>>> look at jiffies is because its a cheap indication that it has
>>>> ran for too long and we should give other tasks a change to run
>>>> as well, but it should continue immediately after it did that.
>>>> So all it should do is make sure that the watchdog is scheduled
>>>> with a very small positive delay.
 >>>>
>>> This needs additional psched_get_time(), and as I've written before
>>> there is no apparent advantage in problematic cases, but this would
>>> add more overhead for common cases.
 >>>
>> htb_do_events() exceeding two jiffies is fortunately not a common
>> case. You (incorrectly) made the calculation somewhat of a common
>> case by also adding to the delay if the inner classes simply throttled
>> and already returned the exact delay they want.
> 
> I see! You are right and this needs fixing.
> 
>> Much better (again considering what we want to achieve here) would
>> be to not use the hrtimer watchdog at all. We want to give lower
>> priority tasks a chance to run, so ideally we'd use a low priority
>> task for wakeup.
> 
> I'm not sure I get ot right: for precise scheduling hrtimers look
> useful. Do you really mean "at all"?

I meant "at all" for the wakeup after we've decided HTB has too much
work to do at once. A work queue seems better suited since that makes
sure we allow other processes to run, but don't wait unnecessarily
long when there is no other work.

>>>> As for the implementation: the increase in delay (the snippet
>>>> above) is also done in the case that no packets were available
>>>> for other reasons (throttling), in which case we might needlessly
>>>> delay for an extra jiffie if jiffies wrapped while it tried to
>>>> dequeue.
 >>>>
>>> But in another similar cases there could be no change in jiffies, but
>>> almost a jiffie used for counting, so wrong schedule time as well.
>> Its not "wrong". We don't want to delay. Its a courtesy to the
>> remaining system.
> 
> In this case it's probably self-courtesy too: this ksoftirqd takes
> most of the time and it's useless.

Well, it calls back to HTB, which continues to do real work. But
leaving HTB, scheduling a timer just to be called immediately again
is useless overhead, I agree.

>>> Approximatly this all should be fine, and it still can be tuned later.
>>> IMHO, this all should not affect "common" cases, which are expected to
>>> use less then jiffie here.
 >>>
>> Jiffies might wrap even if it only took only a few nanoseconds.
>> And its not fine, in the case of throttled classes there's no
>> reason to add extra delay *at all*.
> 
> Yes, you are right with this. I can try too fix this tomorrow, unless
> you prefer to send your version of this patch.

I don't have a version of my own, so please go ahead :)
