From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC] v7 expedited "big hammer" RCU grace periods
Date: Mon, 25 May 2009 18:28:43 -0700
Message-ID: <20090526012843.GF7168@linux.vnet.ibm.com>
References: <20090522190525.GA13286@linux.vnet.ibm.com> <4A1A3C23.8090004@cn.fujitsu.com> <20090525164446.GD7168@linux.vnet.ibm.com> <4A1B3FFB.7090306@cn.fujitsu.com>
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
In-Reply-To: <4A1B3FFB.7090306@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 26, 2009 at 09:03:55AM +0800, Lai Jiangshan wrote:
> Paul E. McKenney wrote:
> > 
> > Good point -- I should at the very least add a comment to
> > synchronize_sched_expedited() stating that it cannot be called holding
> > any lock that is acquired in a CPU hotplug notifier.  If this restriction
> > causes any problems, then your approach seems like a promising fix.
> 
> Reviewed-by: Lai Jiangshan <laijs@cn.fujitsu.com>

Thank you very much for your review and comments!!!

> >> The coupling of synchronize_sched_expedited() and migration_req
> >> is largely increased:
> >>
> >> 1) The offline cpu's per_cpu(rcu_migration_req, cpu) is handled.
> >>    See migration_call::CPU_DEAD
> > 
> > Good.  ;-)
> > 
> >> 2) migration_call() is the highest priority of cpu notifiers,
> >>    So even any other cpu notifier calls synchronize_sched_expedited(),
> >>    It'll not cause DEADLOCK.
> > 
> > You mean if using your preempt_disable() approach, right?  Unless I am
> > missing something, the current get_online_cpus() approach would deadlock
> > in this case.
> 
> Yes, I mean if using my preempt_disable() approach. The current
> get_online_cpus() approach would NOT deadlock in this case also,
> we can require get_online_cpus() in cpu notifiers.

I have added the comment for the time being, but should people need to
use this in CPU-hotplug notifiers, then again your preempt_disable()
approach looks to be a promising fix.

> > diff --git a/include/linux/rcupreempt.h b/include/linux/rcupreempt.h
> > index fce5227..78117ed 100644
> > --- a/include/linux/rcupreempt.h
> > +++ b/include/linux/rcupreempt.h
> > @@ -74,6 +74,16 @@ extern int rcu_needs_cpu(int cpu);
> >  
> >  extern void __synchronize_sched(void);
> >  
> > +static inline void synchronize_rcu_expedited(void)
> > +{
> > +	synchronize_rcu();  /* Placeholder for new rcupreempt implementation. */
> > +}
> > +
> > +static inline void synchronize_rcu_bh_expedited(void)
> > +{
> > +	synchronize_rcu();  /* Placeholder for new rcupreempt implementation. */
> > +}
> > +
> 
> Why not synchronize_rcu_bh() ?

Ummm...  Because I did a typo.  Fixed.

> In mainline, rcu_read_lock_bh() is not preemptable,
> So I think synchronize_sched_expedited() is better.
> 
> Anyway, synchronize_rcu() is OK for me, because it is
> "Placeholder for new rcupreempt implementation".

And I am worried that preemptable RCU's rcu_bh read sides might someday
become preemptable.  Seems a bit unlikely at this point, but why tempt
fate?

							Thanx, Paul
