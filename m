From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Multicast packet loss
Date: Tue, 17 Mar 2009 12:57:05 +0100
Message-ID: <1237291025.5189.504.camel@laptop>
References: <49B4B909.7050002@cosmosbay.com>
	 <20090313.145152.121603300.davem@davemloft.net>
	 <49BADE87.40407@cosmosbay.com>
	 <20090313.153851.11725991.davem@davemloft.net>
	 <49BED109.3020504@cosmosbay.com> <1237284716.5189.284.camel@laptop>
	 <49BF84C0.2000808@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kchang@athenacr.com,
	netdev@vger.kernel.org, cl@linux-foundation.org, bmb@athenacr.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:42404 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755120AbZCQL5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 07:57:16 -0400
In-Reply-To: <49BF84C0.2000808@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-03-17 at 12:08 +0100, Eric Dumazet wrote:

> >> +
> >> +/*
> >> + * Caller must disable preemption, and take care of appropriate
> >> + * locking and refcounting
> >> + */
> > 
> > Shouldn't we call it __softirq_delay_queue() if the caller needs to
> > disabled preemption?
> 
> I was wondering if some BUG_ON() can be added to crash if preemption is enabled
> at this point.

__get_cpu_var() has a preemption check and will generate BUGs when
CONFIG_DEBUG_PREEMPT similar to smp_processor_id().

>  Could not find an existing check,
> doing again the 'if (running_from_softirq())'" test might be overkill,
> should I document caller should do :
> 
> skeleton :
> 
>     lock_my_data(data); /* barrier here */
>     sdel = &data->sdel;
>     if (running_from_softirq()) {

Small nit: I don't particularly like the running_from_softirq() name,
but in_softirq() is already taken, and sadly means something slightly
different.

> 	if (softirq_delay_queue(sdel)) {
> 		hold a refcount on data;
> 	} else {
> 		/* already queued, nothing to do */
> 	}
>     } else {
> 	/* cannot queue the work , must do it right now */
> 	do_work(data);
>     }
>     release_my_data(data);
> }
> 
> > 
> > Futhermore, don't we always require the caller to take care of lifetime
> > issues when we queue something?
> 
> You mean comment is too verbose... or 

Yeah.

> > Aah, the crux is in the re-use policy.. that most certainly does deserve
> > a comment.
> 
> Hum, so my comment was not verbose enough :)

That too :-) 

> >> +static void sock_readable_defer(struct softirq_delay *sdel)
> >> +{
> >> +	struct sock *sk = container_of(sdel, struct sock, sk_delay);
> >> +
> >> +	sdel->next = NULL;
> >> +	/*
> >> +	 * At this point, we dont own a lock on socket, only a reference.
> >> +	 * We must commit above write, or another cpu could miss a wakeup
> >> +	 */
> >> +	smp_wmb();
> > 
> > Where's the matching barrier?
> 
> Check softirq_delay_exec(void) comment, where I stated synchronization had
> to be done by the subsystem.

afaiu the memory barrier semantics you cannot pair a wmb with a lock
barrier, it must either be a read, read_barrier_depends or full barrier.

> In this socket case, caller of softirq_delay_exec() has a lock on socket.
> 
> Problem is I dont want to get this lock again in sock_readable_defer() callback
> 
> if sdel->next is not committed, another cpu could call _softirq_delay_queue() and
> find sdel->next being not null (or != sdel with your suggestion). Then next->func()
> wont be called as it should (or called litle bit too soon)

Right, what we can do is put the wmb in the callback and the rmb right
before the __queue op, or simply integrate it into the framework.

> > OK, so the idea is to handle a bunch of packets and instead of waking N
> > threads for each packet, only wake them once at the end of the batch?
> > 
> > Sounds like a sensible idea.. 
> 
> Idea is to batch wakeups() yes, and if we receive several packets for
> the same socket(s), we reduce number of wakeups to one. In the multicast stress
> situation of Athena CR, it really helps, no packets dropped instead of
> 30%

Yes I can see that helping tremendously.

