From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: Queue with wait-free enqueue, blocking dequeue, splice
Date: Tue, 21 Oct 2014 00:04:10 +0000 (UTC)
Message-ID: <285747581.12566.1413849850921.JavaMail.zimbra@efficios.com>
References: <1311316954.11157.1413631325000.JavaMail.zimbra@efficios.com> <412768308.11171.1413632892841.JavaMail.zimbra@efficios.com> <20141020160237.302aa17c@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.efficios.com ([78.47.125.74]:49292 "EHLO mail.efficios.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752177AbaJUAES (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Oct 2014 20:04:18 -0400
In-Reply-To: <20141020160237.302aa17c@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----- Original Message -----
> From: "Jesper Dangaard Brouer" <brouer@redhat.com>
> To: "Mathieu Desnoyers" <mathieu.desnoyers@efficios.com>
> Cc: brouer@redhat.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, netdev@vger.kernel.org, "Jamal Hadi Salim"
> <jhs@mojatatu.com>
> Sent: Monday, October 20, 2014 10:02:37 AM
> Subject: Re: Queue with wait-free enqueue, blocking dequeue, splice
> 
> 
> On Sat, 18 Oct 2014 11:48:12 +0000 (UTC) Mathieu Desnoyers
> <mathieu.desnoyers@efficios.com> wrote:
> 
> > Following our LPC discussion on lock-free queue algorithms
> > for qdisc, here is some info on the wfcqueue implementation
> > found in Userspace RCU. See http://urcu.so for info and
> > git repository.
> 
> Thank for following up on our very interesting discussions.
> 
> I've started with the more simple variant "urcu/static/wfqueue.h" to
> understand the concepts.  And I'm now reading wfcqueue.h, which I guess
> it replacing wfqueue.h.

Yep, this is correct.

> 
>  
> > Here is the wfcqueue ported to the Linux kernel I sent last
> > year as RFC:
> > https://lkml.org/lkml/2013/3/14/289
> > 
> > I'm very interested to learn if it fits well for your
> > use-case,
> 
> Does this wfcqueue API support bulk dequeue?  (A feature needed for the
> lock-less qdisc implementation, else it cannot compete with our new
> bulk dequeue strategy).

Yes, it does. See the "__wfcq_splice" API.

> 
> AFAIK your queue implementation is a CAS-based, Wait-Free on enqueue,
> but Lock-Free on dequeue with the potential for waiting/blocking on
> a enqueue processes.
>  I'm not 100% sure, that we want this behavior for the qdisc system.

It's actually xchg-based (not CAS-based). It is indeed wait-free
in the strictest sense of the term on enqueue (at least on x86,
some other arch implement xchg using ll/sc, which is not strictly
wait-free).

On dequeue, it can busy-wait for a short while that the enqueue
completes. Note that in kernel, since we disable preemption during
enqueue, the dequeue does not have to ever block, just busy-looping
is OK, since the longest thing that could nest over the enqueue
is possibly an interrupt and softirq. So yes, I guess the dequeue
would qualify as lock-free.

> 
> I can certainly use the wfcq_empty() check,

Not sure why you would want to use it, considering that the dequeue
operation implies it. If there is nothing to dequeue, we just return
immediately. Dequeue operation does not block on empty queue. It
just busy waits if it happen to see the queue in an intermediate
state of the enqueue operation (which is very short, few instructions
at most, with preemption disabled).

> but I guess I need to
> maintain a separate counter to maintain the qdisc limit, right?
> (I would use the approximate/split counter API percpu_counter to keep
> this scalable, and wfcq_empty() would provide an accurate empty check)

Yes for split counters, not sure why you need the empty check explicitly
in your use-case though.

> 
> 
> I think, we/I should start micro benchmarking the different approaches.
> As our time budget is only 67.2ns
>  http://netoptimizer.blogspot.dk/2014/05/the-calculations-10gbits-wirespeed.html
> (or bulking tricks artificially "increase" this budget)
> 
> 
> The motivation behind this lockless qdisc is, the current qdisc locking
> cost 48ns, see slide 9/16 titled "Qdisc locking is nasty":
>  http://people.netfilter.org/hawk/presentations/LinuxPlumbers2014/performance_tx_qdisc_bulk_LPC2014.pdf
> 

Chances are that the scheme:

__wfcq_enqueue() on enqueue

__wfcq_splice() for bulk dequeue

__wfcq_first()
__wfcq_next()  for iteration on the splice dest queue

Would be must faster than the ton of locks you use currently.
The nice part about using just enqueue and splice is that you
don't need locking on the queue at all. Iteration on the
destination queue can be done by a single thread, so no need
for explicit locking there neither.

By the way, you should look at the kernel wfcq implementation
I posted earlier. It's more compact that the one in userspace RCU
because we don't need to support blocking/nonblocking modes,
because we have the luxury of disabling preemption in the kernel.

I look forward to see the numbers,

Thanks!

Mathieu

> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Sr. Network Kernel Developer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer
> 

-- 
Mathieu Desnoyers
EfficiOS Inc.
http://www.efficios.com
