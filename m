From: kuznet@ms2.inr.ac.ru
Subject: Re: route cache DoS testing and softirqs
Date: Wed, 31 Mar 2004 00:05:05 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403302005.AAA00466@yakov.inr.ac.ru>
References: <20040329222926.GF3808@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dipankar@in.ibm.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        Robert.Olsson@data.slu.se, paulmck@us.ibm.com (Paul E. McKenney),
        davem@redhat.com (Dave Miller),
        kuznet@ms2.inr.ac.ru (Alexey Kuznetsov), akpm@osdl.org (Andrew Morton)
Return-path: <netdev-bounce@oss.sgi.com>
To: andrea@suse.de (Andrea Arcangeli)
In-Reply-To: <20040329222926.GF3808@dualathlon.random> from "Andrea Arcangeli" at Мар 30, 2004 12:29:26 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> > Robert demonstrated to us sometime ago with a small
> > timestamping user program to show that it can get starved for
> > more than 6 seconds in his system. So userland starvation is an
> > issue.
> 
> softirqs are already capable of being offloaded to scheduler-friendy
> kernel threads to avoid starvation, if this wasn't the case NAPI would
> have no way to work in the first place and everything else would fall
> apart too, not just the rcu-route-cache. I don't think high latencies
> and starvation are the same thing, starvation means for "indefinite
> time" and you can't hang userspace for indefinite time using softirqs.
> For sure the irq based load, and in turn softirqs too, can take a large
> amount of cpu (though not 100%, this is why it cannot be called
> starvation).
> 
> the only real starvation you can claim is in presence of an _hard_irq
> flood, not a softirq one.

There are no hardirqs in the case under investigation, remember?

What's about the problem it really splits to two ones:

1. The _new_ problem when bad latency of rcu hurts core
   functionality. This is precise description:

> to keep up with the softirq load.  This has never been the case so far,
> and serving softirq as fast as possible is normally a good thing for
> server/firewalls, the small unfariness (note unfariness != starvation)
> it generates has never been an issue, because so far the softirq never
> required the scheduler to work in order to do their work, rcu changed
> this in the routing cache specific case.

We had one full solution for this issue not changing anything
in scheduler/softirq relationship: to run rcu task for the things
sort of dst cache not from process context, but essentially as part
of do_softirq(). Simple, stupid and apparently solves new problems
which rcu created.

Another solution is just to increase memory consumption limits
to deal with current rcu latency. F.e. 300ms latency just requires
additional space for pps*300ms objects, which are handled by RCU.
The problem with this is that pps is the thing which increases
when cpu power grows and that 300ms is not a mathematically established
limit too.


> So you're simply asking the ksoftirqd offloading to become more
> aggressive,

It is the second challenge.

Andrea, it is experimenatl fact: this "small unfariness" stalls process
contexts for >=6 seconds and gives them microscopic slices. We could live
with this (provided RCU problem is solved in some way). Essentially,
the only trouble for me was that we could use existing rcu bits to make
offloading to ksoftirqd more smart (not aggressive, _smart_). The absense
of RCU quiescent states looks too close to absence of forward progress
in process contexts, it was anticipating similarity. The dumb throttling
do_softirq made not from ksoftirqd context when starvation is detected
which we tested the last summer is not only ugly, it really might hurt
router performance, you are right here too. It is the challenge:
or we proceed with this idea and invent something, or we just forget
about this concentrating on RCU.

Alexey
