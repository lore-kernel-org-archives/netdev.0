From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC] v2 not-so-expedited "big hammer" RCU grace periods
Date: Wed, 29 Apr 2009 06:23:23 -0700
Message-ID: <20090429132323.GG6808@linux.vnet.ibm.com>
References: <20090429045310.GA11476@linux.vnet.ibm.com> <20090429055840.GB20625@Krystal>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, mingo@elte.hu,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	davem@davemloft.net, dada1@cosmosbay.com, zbr@ioremap.net,
	jeff.chua.linux@gmail.com, paulus@samba.org, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, benh@kernel.crashing.org
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:42645 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755465AbZD2NX3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Apr 2009 09:23:29 -0400
Content-Disposition: inline
In-Reply-To: <20090429055840.GB20625@Krystal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 29, 2009 at 01:58:40AM -0400, Mathieu Desnoyers wrote:
> * Paul E. McKenney (paulmck@linux.vnet.ibm.com) wrote:

[ . . . ]

> > +
> > +		/*
> > +		 * Wait a bit.  If we have already waited a fair
> > +		 * amount of time, sleep.
> > +		 */
> > +		if (++times < 10)
> > +			udelay(10 * times);
> > +		else
> > +			schedule_timeout_uninterruptible(1);
> 
> Waiting a whole jiffy (e.g. 1ms, 4ms, 10ms) here seems like a big hammer
> to nail a delicate pin. I would not be surprised if your long delay
> would come from here. Is it possible that your ipi+scheduling delay is
> actually longer than the 11 udelays you are doing and that you end up
> calling schedule_timeout_uninterruptible(1) each time ?

It might be -- easy to try increasing the number of udelay passes
through the loop.

On the other hand, the 550 microseconds waited by the sum of the udelay
passes is ridiculously long in and of itself.

Still, would be interesting to know.  I will change the loop to udelay
up to HZ.  Hmmm...  I wonder if udelay() itself is turning into a 1-HZ
wait beyond a certain point.

							Thanx, Paul

> Mathieu
> 
> > +		/* FIXME: need to complain about holdout CPUs if too long. */
> > +	}
> > +
> > +	synchronize_rcu_bh_completed++;
> > +	mutex_unlock(&synchronize_rcu_bh_mutex);
> > +}
> > +EXPORT_SYMBOL_GPL(synchronize_rcu_expedited);
> > +
> > +void synchronize_rcu_bh_expedited(void)
> > +{
> > +	synchronize_rcu_expedited();
> > +}
> > +EXPORT_SYMBOL_GPL(synchronize_rcu_bh_expedited);
> > +
> > +#endif /* #else #ifndef CONFIG_SMP */
> > +
> >  void __init rcu_init(void)
> >  {
> >  	__rcu_init();
> >  	hotcpu_notifier(rcu_barrier_cpu_hotplug, 0);
> > +	synchronize_rcu_expedited_init();
> >  }
> >  
> >  void rcu_scheduler_starting(void)
> > diff --git a/kernel/rcutorture.c b/kernel/rcutorture.c
> > index 9b4a975..8845936 100644
> > --- a/kernel/rcutorture.c
> > +++ b/kernel/rcutorture.c
> > @@ -257,14 +257,14 @@ struct rcu_torture_ops {
> >  	void (*init)(void);
> >  	void (*cleanup)(void);
> >  	int (*readlock)(void);
> > -	void (*readdelay)(struct rcu_random_state *rrsp);
> > +	void (*read_delay)(struct rcu_random_state *rrsp);
> >  	void (*readunlock)(int idx);
> >  	int (*completed)(void);
> > -	void (*deferredfree)(struct rcu_torture *p);
> > +	void (*deferred_free)(struct rcu_torture *p);
> >  	void (*sync)(void);
> >  	void (*cb_barrier)(void);
> >  	int (*stats)(char *page);
> > -	int irqcapable;
> > +	int irq_capable;
> >  	char *name;
> >  };
> >  static struct rcu_torture_ops *cur_ops = NULL;
> > @@ -320,7 +320,7 @@ rcu_torture_cb(struct rcu_head *p)
> >  		rp->rtort_mbtest = 0;
> >  		rcu_torture_free(rp);
> >  	} else
> > -		cur_ops->deferredfree(rp);
> > +		cur_ops->deferred_free(rp);
> >  }
> >  
> >  static void rcu_torture_deferred_free(struct rcu_torture *p)
> > @@ -329,18 +329,18 @@ static void rcu_torture_deferred_free(struct rcu_torture *p)
> >  }
> >  
> >  static struct rcu_torture_ops rcu_ops = {
> > -	.init = NULL,
> > -	.cleanup = NULL,
> > -	.readlock = rcu_torture_read_lock,
> > -	.readdelay = rcu_read_delay,
> > -	.readunlock = rcu_torture_read_unlock,
> > -	.completed = rcu_torture_completed,
> > -	.deferredfree = rcu_torture_deferred_free,
> > -	.sync = synchronize_rcu,
> > -	.cb_barrier = rcu_barrier,
> > -	.stats = NULL,
> > -	.irqcapable = 1,
> > -	.name = "rcu"
> > +	.init		= NULL,
> > +	.cleanup	= NULL,
> > +	.readlock	= rcu_torture_read_lock,
> > +	.read_delay	= rcu_read_delay,
> > +	.readunlock	= rcu_torture_read_unlock,
> > +	.completed	= rcu_torture_completed,
> > +	.deferred_free	= rcu_torture_deferred_free,
> > +	.sync		= synchronize_rcu,
> > +	.cb_barrier	= rcu_barrier,
> > +	.stats		= NULL,
> > +	.irq_capable 	= 1,
> > +	.name 		= "rcu"
> >  };
> >  
> >  static void rcu_sync_torture_deferred_free(struct rcu_torture *p)
> > @@ -370,18 +370,18 @@ static void rcu_sync_torture_init(void)
> >  }
> >  
> >  static struct rcu_torture_ops rcu_sync_ops = {
> > -	.init = rcu_sync_torture_init,
> > -	.cleanup = NULL,
> > -	.readlock = rcu_torture_read_lock,
> > -	.readdelay = rcu_read_delay,
> > -	.readunlock = rcu_torture_read_unlock,
> > -	.completed = rcu_torture_completed,
> > -	.deferredfree = rcu_sync_torture_deferred_free,
> > -	.sync = synchronize_rcu,
> > -	.cb_barrier = NULL,
> > -	.stats = NULL,
> > -	.irqcapable = 1,
> > -	.name = "rcu_sync"
> > +	.init		= rcu_sync_torture_init,
> > +	.cleanup	= NULL,
> > +	.readlock	= rcu_torture_read_lock,
> > +	.read_delay	= rcu_read_delay,
> > +	.readunlock	= rcu_torture_read_unlock,
> > +	.completed	= rcu_torture_completed,
> > +	.deferred_free	= rcu_sync_torture_deferred_free,
> > +	.sync		= synchronize_rcu,
> > +	.cb_barrier	= NULL,
> > +	.stats		= NULL,
> > +	.irq_capable	= 1,
> > +	.name		= "rcu_sync"
> >  };
> >  
> >  /*
> > @@ -432,33 +432,53 @@ static void rcu_bh_torture_synchronize(void)
> >  }
> >  
> >  static struct rcu_torture_ops rcu_bh_ops = {
> > -	.init = NULL,
> > -	.cleanup = NULL,
> > -	.readlock = rcu_bh_torture_read_lock,
> > -	.readdelay = rcu_read_delay,  /* just reuse rcu's version. */
> > -	.readunlock = rcu_bh_torture_read_unlock,
> > -	.completed = rcu_bh_torture_completed,
> > -	.deferredfree = rcu_bh_torture_deferred_free,
> > -	.sync = rcu_bh_torture_synchronize,
> > -	.cb_barrier = rcu_barrier_bh,
> > -	.stats = NULL,
> > -	.irqcapable = 1,
> > -	.name = "rcu_bh"
> > +	.init		= NULL,
> > +	.cleanup	= NULL,
> > +	.readlock	= rcu_bh_torture_read_lock,
> > +	.read_delay	= rcu_read_delay,  /* just reuse rcu's version. */
> > +	.readunlock	= rcu_bh_torture_read_unlock,
> > +	.completed	= rcu_bh_torture_completed,
> > +	.deferred_free	= rcu_bh_torture_deferred_free,
> > +	.sync		= rcu_bh_torture_synchronize,
> > +	.cb_barrier	= rcu_barrier_bh,
> > +	.stats		= NULL,
> > +	.irq_capable	= 1,
> > +	.name		= "rcu_bh"
> >  };
> >  
> >  static struct rcu_torture_ops rcu_bh_sync_ops = {
> > -	.init = rcu_sync_torture_init,
> > -	.cleanup = NULL,
> > -	.readlock = rcu_bh_torture_read_lock,
> > -	.readdelay = rcu_read_delay,  /* just reuse rcu's version. */
> > -	.readunlock = rcu_bh_torture_read_unlock,
> > -	.completed = rcu_bh_torture_completed,
> > -	.deferredfree = rcu_sync_torture_deferred_free,
> > -	.sync = rcu_bh_torture_synchronize,
> > -	.cb_barrier = NULL,
> > -	.stats = NULL,
> > -	.irqcapable = 1,
> > -	.name = "rcu_bh_sync"
> > +	.init		= rcu_sync_torture_init,
> > +	.cleanup	= NULL,
> > +	.readlock	= rcu_bh_torture_read_lock,
> > +	.read_delay	= rcu_read_delay,  /* just reuse rcu's version. */
> > +	.readunlock	= rcu_bh_torture_read_unlock,
> > +	.completed	= rcu_bh_torture_completed,
> > +	.deferred_free	= rcu_sync_torture_deferred_free,
> > +	.sync		= rcu_bh_torture_synchronize,
> > +	.cb_barrier	= NULL,
> > +	.stats		= NULL,
> > +	.irq_capable	= 1,
> > +	.name		= "rcu_bh_sync"
> > +};
> > +
> > +static int rcu_bh_expedited_torture_completed(void)
> > +{
> > +	return rcu_batches_completed_bh_expedited();
> > +}
> > +
> > +static struct rcu_torture_ops rcu_bh_expedited_ops = {
> > +	.init		= rcu_sync_torture_init,
> > +	.cleanup	= NULL,
> > +	.readlock	= rcu_bh_torture_read_lock,
> > +	.read_delay	= rcu_read_delay,  /* just reuse rcu's version. */
> > +	.readunlock	= rcu_bh_torture_read_unlock,
> > +	.completed	= rcu_bh_expedited_torture_completed,
> > +	.deferred_free	= rcu_sync_torture_deferred_free,
> > +	.sync		= synchronize_rcu_bh_expedited,
> > +	.cb_barrier	= NULL,
> > +	.stats		= NULL,
> > +	.irq_capable	= 1,
> > +	.name		= "rcu_bh_expedited"
> >  };
> >  
> >  /*
> > @@ -530,17 +550,17 @@ static int srcu_torture_stats(char *page)
> >  }
> >  
> >  static struct rcu_torture_ops srcu_ops = {
> > -	.init = srcu_torture_init,
> > -	.cleanup = srcu_torture_cleanup,
> > -	.readlock = srcu_torture_read_lock,
> > -	.readdelay = srcu_read_delay,
> > -	.readunlock = srcu_torture_read_unlock,
> > -	.completed = srcu_torture_completed,
> > -	.deferredfree = rcu_sync_torture_deferred_free,
> > -	.sync = srcu_torture_synchronize,
> > -	.cb_barrier = NULL,
> > -	.stats = srcu_torture_stats,
> > -	.name = "srcu"
> > +	.init		= srcu_torture_init,
> > +	.cleanup	= srcu_torture_cleanup,
> > +	.readlock	= srcu_torture_read_lock,
> > +	.read_delay	= srcu_read_delay,
> > +	.readunlock	= srcu_torture_read_unlock,
> > +	.completed	= srcu_torture_completed,
> > +	.deferred_free	= rcu_sync_torture_deferred_free,
> > +	.sync		= srcu_torture_synchronize,
> > +	.cb_barrier	= NULL,
> > +	.stats		= srcu_torture_stats,
> > +	.name		= "srcu"
> >  };
> >  
> >  /*
> > @@ -574,32 +594,32 @@ static void sched_torture_synchronize(void)
> >  }
> >  
> >  static struct rcu_torture_ops sched_ops = {
> > -	.init = rcu_sync_torture_init,
> > -	.cleanup = NULL,
> > -	.readlock = sched_torture_read_lock,
> > -	.readdelay = rcu_read_delay,  /* just reuse rcu's version. */
> > -	.readunlock = sched_torture_read_unlock,
> > -	.completed = sched_torture_completed,
> > -	.deferredfree = rcu_sched_torture_deferred_free,
> > -	.sync = sched_torture_synchronize,
> > -	.cb_barrier = rcu_barrier_sched,
> > -	.stats = NULL,
> > -	.irqcapable = 1,
> > -	.name = "sched"
> > +	.init		= rcu_sync_torture_init,
> > +	.cleanup	= NULL,
> > +	.readlock	= sched_torture_read_lock,
> > +	.read_delay	= rcu_read_delay,  /* just reuse rcu's version. */
> > +	.readunlock	= sched_torture_read_unlock,
> > +	.completed	= sched_torture_completed,
> > +	.deferred_free	= rcu_sched_torture_deferred_free,
> > +	.sync		= sched_torture_synchronize,
> > +	.cb_barrier	= rcu_barrier_sched,
> > +	.stats		= NULL,
> > +	.irq_capable	= 1,
> > +	.name		= "sched"
> >  };
> >  
> >  static struct rcu_torture_ops sched_ops_sync = {
> > -	.init = rcu_sync_torture_init,
> > -	.cleanup = NULL,
> > -	.readlock = sched_torture_read_lock,
> > -	.readdelay = rcu_read_delay,  /* just reuse rcu's version. */
> > -	.readunlock = sched_torture_read_unlock,
> > -	.completed = sched_torture_completed,
> > -	.deferredfree = rcu_sync_torture_deferred_free,
> > -	.sync = sched_torture_synchronize,
> > -	.cb_barrier = NULL,
> > -	.stats = NULL,
> > -	.name = "sched_sync"
> > +	.init		= rcu_sync_torture_init,
> > +	.cleanup	= NULL,
> > +	.readlock	= sched_torture_read_lock,
> > +	.read_delay	= rcu_read_delay,  /* just reuse rcu's version. */
> > +	.readunlock	= sched_torture_read_unlock,
> > +	.completed	= sched_torture_completed,
> > +	.deferred_free	= rcu_sync_torture_deferred_free,
> > +	.sync		= sched_torture_synchronize,
> > +	.cb_barrier	= NULL,
> > +	.stats		= NULL,
> > +	.name		= "sched_sync"
> >  };
> >  
> >  /*
> > @@ -635,7 +655,7 @@ rcu_torture_writer(void *arg)
> >  				i = RCU_TORTURE_PIPE_LEN;
> >  			atomic_inc(&rcu_torture_wcount[i]);
> >  			old_rp->rtort_pipe_count++;
> > -			cur_ops->deferredfree(old_rp);
> > +			cur_ops->deferred_free(old_rp);
> >  		}
> >  		rcu_torture_current_version++;
> >  		oldbatch = cur_ops->completed();
> > @@ -700,7 +720,7 @@ static void rcu_torture_timer(unsigned long unused)
> >  	if (p->rtort_mbtest == 0)
> >  		atomic_inc(&n_rcu_torture_mberror);
> >  	spin_lock(&rand_lock);
> > -	cur_ops->readdelay(&rand);
> > +	cur_ops->read_delay(&rand);
> >  	n_rcu_torture_timers++;
> >  	spin_unlock(&rand_lock);
> >  	preempt_disable();
> > @@ -738,11 +758,11 @@ rcu_torture_reader(void *arg)
> >  
> >  	VERBOSE_PRINTK_STRING("rcu_torture_reader task started");
> >  	set_user_nice(current, 19);
> > -	if (irqreader && cur_ops->irqcapable)
> > +	if (irqreader && cur_ops->irq_capable)
> >  		setup_timer_on_stack(&t, rcu_torture_timer, 0);
> >  
> >  	do {
> > -		if (irqreader && cur_ops->irqcapable) {
> > +		if (irqreader && cur_ops->irq_capable) {
> >  			if (!timer_pending(&t))
> >  				mod_timer(&t, 1);
> >  		}
> > @@ -757,7 +777,7 @@ rcu_torture_reader(void *arg)
> >  		}
> >  		if (p->rtort_mbtest == 0)
> >  			atomic_inc(&n_rcu_torture_mberror);
> > -		cur_ops->readdelay(&rand);
> > +		cur_ops->read_delay(&rand);
> >  		preempt_disable();
> >  		pipe_count = p->rtort_pipe_count;
> >  		if (pipe_count > RCU_TORTURE_PIPE_LEN) {
> > @@ -778,7 +798,7 @@ rcu_torture_reader(void *arg)
> >  	} while (!kthread_should_stop() && fullstop == FULLSTOP_DONTSTOP);
> >  	VERBOSE_PRINTK_STRING("rcu_torture_reader task stopping");
> >  	rcutorture_shutdown_absorb("rcu_torture_reader");
> > -	if (irqreader && cur_ops->irqcapable)
> > +	if (irqreader && cur_ops->irq_capable)
> >  		del_timer_sync(&t);
> >  	while (!kthread_should_stop())
> >  		schedule_timeout_uninterruptible(1);
> > @@ -1078,6 +1098,7 @@ rcu_torture_init(void)
> >  	int firsterr = 0;
> >  	static struct rcu_torture_ops *torture_ops[] =
> >  		{ &rcu_ops, &rcu_sync_ops, &rcu_bh_ops, &rcu_bh_sync_ops,
> > +		  &rcu_bh_expedited_ops,
> >  		  &srcu_ops, &sched_ops, &sched_ops_sync, };
> >  
> >  	mutex_lock(&fullstop_mutex);
> > diff --git a/kernel/rcutree.c b/kernel/rcutree.c
> > index d2a372f..bf2c21d 100644
> > --- a/kernel/rcutree.c
> > +++ b/kernel/rcutree.c
> > @@ -89,6 +89,7 @@ void rcu_qsctr_inc(int cpu)
> >  	struct rcu_data *rdp = &per_cpu(rcu_data, cpu);
> >  	rdp->passed_quiesc = 1;
> >  	rdp->passed_quiesc_completed = rdp->completed;
> > +	synchronize_rcu_expedited_qs(cpu);
> >  }
> >  
> >  void rcu_bh_qsctr_inc(int cpu)
> 
> -- 
> Mathieu Desnoyers
> OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
