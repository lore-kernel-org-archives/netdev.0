From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH] sched: Optimize return value of qdisc_restart
Date: Wed, 9 May 2007 20:17:08 +0530
Message-ID: <OFBBEFE969.8AD5C0AA-ON652572D6.004FC535-652572D6.00513837@in.ibm.com>
References: <1178715404.4073.21.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	J Hadi Salim <j.hadi123@gmail.com>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:34714 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754106AbXEIOsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 10:48:05 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l49F7jet340538
	for <netdev@vger.kernel.org>; Thu, 10 May 2007 01:07:45 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l49EpY6m082562
	for <netdev@vger.kernel.org>; Thu, 10 May 2007 00:51:34 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l49Em1OK012876
	for <netdev@vger.kernel.org>; Thu, 10 May 2007 00:48:02 +1000
In-Reply-To: <1178715404.4073.21.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jamal,

J Hadi Salim <j.hadi123@gmail.com> wrote on 05/09/2007 06:26:43 PM:

> On Wed, 2007-09-05 at 01:12 -0700, David Miller wrote:
>
> > Something this evening is obviously making it impossible
> > for my brain to understand this function and your patch,
> > so I'm going to sleep on it and try again tomorrow :-)
>
> It is one of those areas that are hard to size-up in a blink;->
> Gut-feeling: It doesnt sit right with me as well.
>
> With (2.6.18-rxX++) QDISC_RUNNING changes that mean only one of N CPUs
> will be dequeueing while the N-1 maybe enqueueing concurently. All N

Concurrently is not possible, since everyone needs the queue_lock
to add/delete. Did I misunderstand your comment ?

> CPUs contend for the queue lock; and theres a possible window between
> releasing the queue lock by the dequeuer-CPU and enqueuer-CPU for a
> race. The dequeuer-CPU entering one last time helps.

The dev->queue_lock is held by both enqueue'r and dequeue'r (though
the dequeue'r drops it before calling xmit). But once the dequeue'r
re-gets the lock, it is guaranteed that no one else has the lock
Other CPU's trying to add will block on the lock, or if they have
already added by getting the lock for a short time while my CPU was
doing the xmit, then their qdisc_run returns doing nothing as RUNNING
is true.

Since I am holding a lock in these two changed areas till I return
back to __qdisc_run (which clears the RUNNING bit) and then drop the
lock, there is no way packets can be on the queue while I falsely
return 0, or no packets on the queue while I falsely return -1.

I hope my explanation was not confusing.

> Krishna, you probably saw this "wasted entry into qdisc" under low
> traffic conditions with more than likely only one CPU sending, am i
> correct? Under heavier traffic when we have multiple CPUs funneling to

Actually, I have never seen this problem, just code reading while
trying to implement something else in this area, for which I plan to
bug Dave in a few days.

Thanks,

- KK

> the same device, that entry is not really a "waste" because we endup
> only go in once per X number of packets enqueued on the qdisc and that
> check is absolutely necessary because a different CPU may have enqueued
> while you were not looking. In the case of low traffic, X=1 - so it is a
> waste there albeit a necessary one.


>
> cheers,
> jamal
>
>

