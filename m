From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC] v5 expedited "big hammer" RCU grace periods
Date: Mon, 18 May 2009 07:40:39 -0700
Message-ID: <20090518144039.GA6768@linux.vnet.ibm.com>
References: <20090517191141.GA25915@linux.vnet.ibm.com> <4A110768.2040707@cn.fujitsu.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, mingo@elte.hu,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	davem@davemloft.net, dada1@cosmosbay.com, zbr@ioremap.net,
	jeff.chua.linux@gmail.com, paulus@samba.org, jengelh@medozas.de,
	r000n@r000n.net, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A110768.2040707@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 18, 2009 at 02:59:52PM +0800, Lai Jiangshan wrote:
> Paul E. McKenney wrote:
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
> [...]
> 
> > +		get_online_cpus();
> > +		preempt_disable();
> > +		mycpu = smp_processor_id();
> > +		smp_call_function(sched_expedited_wake, NULL, 1);
> 
> sched_expedited_wake() calls mutex_lock() which may sleep?

Good eyes!  Fixing this and the failure to release this lock in
krcu_sched_expedited_percpu() allows it to survive 10 hours of
rcutorture running in parallel with onlining/offlining random CPUs.

> And I think you have re-implement workqueue.

Hmmm...  I suppose I could use schedule_work(), though I am concerned
about interference from other work.  But I will give this some thought.

							Thanx, Paul
