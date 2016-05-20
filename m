From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC] net: remove busylock
Date: Fri, 20 May 2016 09:29:03 +0200
Message-ID: <20160520092903.38620c60@redhat.com>
References: <1463677716.18194.203.camel@edumazet-glaptop3.roam.corp.google.com>
	<CAKgT0UfBxW=KpqJux+tjyNpHQUHhZ5Laiqnt5FPs=jpkBJWrHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Alexander Duyck <aduyck@mirantis.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53122 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754089AbcETH3J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 May 2016 03:29:09 -0400
In-Reply-To: <CAKgT0UfBxW=KpqJux+tjyNpHQUHhZ5Laiqnt5FPs=jpkBJWrHA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 May 2016 11:03:32 -0700
Alexander Duyck <alexander.duyck@gmail.com> wrote:

> On Thu, May 19, 2016 at 10:08 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > busylock was added at the time we had expensive ticket spinlocks
> >
> > (commit 79640a4ca6955e3ebdb7038508fa7a0cd7fa5527 ("net: add additional
> > lock to qdisc to increase throughput")
> >
> > Now kernel spinlocks are MCS, this busylock things is no longer
> > relevant. It is slowing down things a bit.
> >
> >
> > With HTB qdisc, here are the numbers for 200 concurrent TCP_RR, on a host with 48 hyperthreads.
> >
[...]
> 
> The main point of the busy lock is to deal with the bulk throughput
> case, not the latency case which would be relatively well behaved.
> The problem wasn't really related to lock bouncing slowing things
> down.  It was the fairness between the threads that was killing us
> because the dequeue needs to have priority.

Yes, exactly.
 
> The main problem that the busy lock solved was the fact that you could
> start a number of stream tests equal to the number of CPUs in a given
> system and the result was that the performance would drop off a cliff
> and you would drop almost all the packets for almost all the streams
> because the qdisc never had a chance to drain because it would be CPU
> - 1 enqueues, followed by 1 dequeue.

Notice 1 enqueue does not guarantee 1 dequeue.  If one CPU has entered
dequeue/xmit state (setting __QDISC___STATE_RUNNING) then other CPUs
will just enqueue.  Thus, N CPUs will enqueue (a packet each), and 1 CPU
will dequeue a packet.

The problem arise due to the fairness of the ticket spinlock, and AFAIK
the MCS lock is even more fair.  All enqueue's get their turn before
the dequeue can move forward.  And the qdisc dequeue CPU have an
unfortunate pattern of releasing the qdisc root_lock and acquiring it
again (qdisc_restart+sch_direct_xmit). Thus, while dequeue is waiting
re-aquire the root_lock, N CPUs will enqueue packets.

The hole idea behind allowing bulk qdisc dequeue, was to mitigate this,
by allowing dequeue to do more work, while holding the lock.

You mention HTB.  Notice HTB does not take advantage of bulk dequeue.
Have you tried to enable/allow HTB to bulk dequeue?


> What we need if we are going to get rid of busy lock would be some
> sort of priority locking mechanism that would allow the dequeue thread
> to jump to the head of the line if it is attempting to take the lock.
> Otherwise you end up spending all your time enqueuing packets into
> oblivion because the qdiscs just overflow without the busy lock in
> place.

Exactly. The qdisc locking scheme is designed to only allow one
dequeuing CPU to run (via state __QDISC___STATE_RUNNING).  Jamal told
me this was an optimization.  Maybe this optimization "broke" when
locking got fair?

I don't want to offend the original qdisc designers, but when I look at
the qdisc locking code, I keep thinking this scheme is broken.

Wouldn't it be better to have seperate an enqueue lock and a dequeue
lock? (with a producer/consumer queue).

Once we get John's lockless qdisc scheme, then the individual qdiscs
can implement a locking scheme like this, and we can keep the old
locking scheme intact for legacy qdisc. Or we can clean up this locking
scheme and update the legacy qdisc to use a MPMC queue?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
