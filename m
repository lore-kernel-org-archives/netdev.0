From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC] v5 expedited "big hammer" RCU grace periods
Date: Mon, 18 May 2009 08:14:21 -0700
Message-ID: <20090518151421.GB6768@linux.vnet.ibm.com>
References: <20090517191141.GA25915@linux.vnet.ibm.com> <20090518075630.GA10687@elte.hu>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, davem@davemloft.net,
	dada1@cosmosbay.com, zbr@ioremap.net, jeff.chua.linux@gmail.com,
	paulus@samba.org, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090518075630.GA10687@elte.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 18, 2009 at 09:56:30AM +0200, Ingo Molnar wrote:
> 
> * Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> 
> > +void sched_expedited_wake(void *unused)
> > +{
> > +	mutex_lock(&__get_cpu_var(sched_expedited_done_mutex));
> > +	if (__get_cpu_var(sched_expedited_done_qs) ==
> > +	    SCHED_EXPEDITED_QS_DONE_QS) {
> > +		__get_cpu_var(sched_expedited_done_qs) =
> > +			SCHED_EXPEDITED_QS_NEED_QS;
> > +		wake_up(&__get_cpu_var(sched_expedited_qs_wq));
> > +	}
> > +	mutex_unlock(&__get_cpu_var(sched_expedited_done_mutex));
> > +}
> 
> ( hm, IPI handlers are supposed to be atomic. )

<red face>

> > +/*
> > + * Kernel thread that processes synchronize_sched_expedited() requests.
> > + * This is implemented as a separate kernel thread to avoid the need
> > + * to mess with other tasks' cpumasks.
> > + */
> > +static int krcu_sched_expedited(void *arg)
> > +{
> > +	int cpu;
> > +	int mycpu;
> > +	int nwait;
> > +
> > +	do {
> > +		wait_event_interruptible(need_sched_expedited_wq,
> > +					 need_sched_expedited);
> > +		smp_mb(); /* In case we didn't sleep. */
> > +		if (!need_sched_expedited)
> > +			continue;
> > +		need_sched_expedited = 0;
> > +		get_online_cpus();
> > +		preempt_disable();
> > +		mycpu = smp_processor_id();
> > +		smp_call_function(sched_expedited_wake, NULL, 1);
> > +		preempt_enable();
> 
> i might be missing something fundamental here, but why not just have 
> per CPU helper threads, all on the same waitqueue, and wake them up 
> via a single wake_up() call? That would remove the SMP cross call 
> (wakeups do immediate cross-calls already).

My concern with this is that the cache misses accessing all the processes
on this single waitqueue would be serialized, slowing things down.
In contrast, the bitmask that smp_call_function() traverses delivers on
the order of a thousand CPUs' worth of bits per cache miss.  I will give
it a try, though.

> Even more - we already have a per-CPU, high RT priority helper 
> thread that could be reused: the per CPU migration threads. Couldnt 
> we queue these requests to them? RCU is arguably closely related to 
> scheduling so there's no layering violation IMO.
> 
> There's already a struct migration_req machinery that performs 
> something quite similar. (do work on behalf of another task, on a 
> specific CPU, and then signal completion)
> 
> Also, per CPU workqueues have similar features as well.

Good points!!!

I will post a working patch using my current approach, then try out some
of these approaches.

							Thanx, Paul
