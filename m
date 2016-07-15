From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH v2 08/10] net: sched: pfifo_fast use alf_queue
Date: Fri, 15 Jul 2016 13:23:29 +0200
Message-ID: <20160715132329.0d04ac42@redhat.com>
References: <20160714061852.8270.66271.stgit@john-Precision-Tower-5810>
	<20160714062312.8270.65942.stgit@john-Precision-Tower-5810>
	<20160714234207.GA93671@ast-mbp.thefacebook.com>
	<57882945.4090101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>, fw@strlen.de,
	jhs@mojatatu.com, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38764 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932483AbcGOLXf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2016 07:23:35 -0400
In-Reply-To: <57882945.4090101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Jul 2016 17:07:33 -0700
John Fastabend <john.fastabend@gmail.com> wrote:

> On 16-07-14 04:42 PM, Alexei Starovoitov wrote:
> > On Wed, Jul 13, 2016 at 11:23:12PM -0700, John Fastabend wrote:  
> >> This converts the pfifo_fast qdisc to use the alf_queue enqueue and
> >> dequeue routines then sets the NOLOCK bit.
> >>
> >> This also removes the logic used to pick the next band to dequeue from
> >> and instead just checks each alf_queue for packets from top priority
> >> to lowest. This might need to be a bit more clever but seems to work
> >> for now.
> >>
> >> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> >> ---
> >>  net/sched/sch_generic.c |  131 +++++++++++++++++++++++++++--------------------  
> >   
> >>  static int pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc *qdisc,
> >>  			      struct sk_buff **to_free)
> >>  {
> >> -	return qdisc_drop(skb, qdisc, to_free);
> >> +	err = skb_array_produce_bh(q, skb);  
> > ..  
> >>  static struct sk_buff *pfifo_fast_dequeue(struct Qdisc *qdisc)
> >>  {
> >> +		skb = skb_array_consume_bh(q);  
> > 
> > For this particular qdisc the performance gain should come from
> > granularityof spin_lock, right?  
> 
> And the fact that the consumer and producer are using different
> locks now.

Yes. Splitting up enqueue'ers (producer's) from the dequeuer (consumer)
is an important step, because today the qdisc layer have this problem
that enqueue'ers can starve the single dequeuer.  The current
mitigation tricks are the enq busy_lock and bulk dequeue.

As John says, using skb_array cause producers and consumer to use
different locks.

> > Before we were taking the lock much earlier. Here we keep the lock,
> > but for the very short time.
> >         original pps        lockless        diff
> >         1       1418168             1269450         -148718
> >         2       1587390             1553408         -33982
> >         4       1084961             1683639         +598678
> >         8       989636              1522723         +533087
> >         12      1014018             1348172         +334154
> >

It looks problematic that lockless is slower in the base single CPU
case, orig (1418168 pps) to lockless (1269450).  By approx
(1/1418168-1/1269450)*10^9 = -82.60 ns.  That base "regression" look
too high to start with.

How I view the results:
Negative scaling starts early for "original", which is the main problem
that we are looking to solve.  The lockless does not show as much
scaling effect as expected, and start to show a trend towards negative
scaling.

> > so perf for 1 cpu case is mainly due to array vs list,
> > since number of locks is still the same and there is no collision ?
> > but then why shorter lock give higher overhead in multi cpu cases?  
> 
> So in this case running pfifo_fast as the root qdisc with 12 threads
> means we have 12 producers hitting a single enqueue() path where as with
> mq and only looking at pktgen numbers we have one thread for each
> skb_array.

The skb_array allow multi producer multi consumer (MPMC), but is
optimized towards the case of a single producer and a single consumer
(SPSC).  The SPSC queue is usually implemented with much less
synchronization, but then you need some other guarantee that only a
single producer/consumer can be running.

> > That would have been the main target for performance improvement?
> >   
> 
> Maybe I should fire up a TCP test with 1000's of threads to see what
> the perf numbers look like.
> 
> > Looks like mq gets the most benefit, because it's lockless internally
> > which makes sense.
> > In general I think this is the right direction where tc infra should move to.
> > I'm only not sure whether it's worth converting pfifo to skb_array.
> > Probably alf queue would have been a better alternative.
> >   
> 
> Tomorrows task is to resurrect the alf_queue and look at its numbers
> compared to this. Today was spent trying to remove the HARD_TX_LOCK
> that protects the driver, in the mq case it seems this is not really
> needed either.

I would be very interested in the alf_queue numbers. As alf_queue
should perform better with multiple producers.  If you kept the single
TC dequeue'er rule, then you could use the MPSC variant of alf_queue.

My benchmarks from 2014 are avail in this presentation:
 http://people.netfilter.org/hawk/presentations/nfws2014/dp-accel-qdisc-lockless.pdf
Also showing the mitigation effect of bulk-dequeue patches slide 12
(But I would like to see some new benchmarks for alf_queue slide 14)


But do notice, alf_queue have a design problem that skb_array solved.
Alf_queue have the problem of read-bouncing the remote/opposite CPUs
cache line, because it need to (1) at enqueue (producer) look if there
is free space (reading consumer.tail), and (2) at dequeue (consumer) if
any object are avail (reading producer.tail).

The alf_queue mitigate this by design problem by allowing doing bulk
enqueue and bulk dequeue. But I guess, you will not use that "mode", I
think I did in my NFWS2014 benchmarks.

The skb_array solved this design problem, by using the content of the
queue objects as a maker for free/full condition.  The alf_queue cannot
do so easily, because of it's bulk design, that need to reserve part of
the queue.  Thus, we likely need some new queue design, which is a
hybrid between alf_queue and skb_array, for this use-case.



I actually wrote some queue micro-benchmarks that show the strength and
weaknesses of both skb_array[1] and alf_queue[2].

[1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/lib/skb_array_parallel01.c
[2] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/lib/alf_queue_parallel01.c
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
