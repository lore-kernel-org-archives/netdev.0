From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: localed stuck in recent 3.18 git in copy_net_ns?
Date: Tue, 28 Oct 2014 05:50:59 -0700
Message-ID: <20141028125059.GO5718@linux.vnet.ibm.com>
References: <20141024225931.GC4977@linux.vnet.ibm.com>
 <20141024230524.GA16023@linux.vnet.ibm.com>
 <10136.1414196448@famine>
 <20141025020324.GA28247@linux.vnet.ibm.com>
 <11813.1414211613@famine>
 <20141025051602.GB28247@linux.vnet.ibm.com>
 <15891.1414255096@famine>
 <20141025181827.GE28247@linux.vnet.ibm.com>
 <20141027174539.GC27568@linux.vnet.ibm.com>
 <20141028081243.GA32082@declera.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <jay.vosburgh@canonical.com>,
	Josh Boyer <jwboyer@fedoraproject.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>,
	Kevin Fenzi <kevin@scrye.com>, netdev <netdev@vger.kernel.org>,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
	mroos@linux.ee, tj@kernel.org
To: Yanko Kaneti <yaneti@declera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141028081243.GA32082@declera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 28, 2014 at 10:12:43AM +0200, Yanko Kaneti wrote:
> On Mon-10/27/14-2014 10:45, Paul E. McKenney wrote:
> > On Sat, Oct 25, 2014 at 11:18:27AM -0700, Paul E. McKenney wrote:
> > > On Sat, Oct 25, 2014 at 09:38:16AM -0700, Jay Vosburgh wrote:
> > > > Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> > > > 
> > > > >On Fri, Oct 24, 2014 at 09:33:33PM -0700, Jay Vosburgh wrote:
> > > > >> 	Looking at the dmesg, the early boot messages seem to be
> > > > >> confused as to how many CPUs there are, e.g.,
> > > > >> 
> > > > >> [    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
> > > > >> [    0.000000] Hierarchical RCU implementation.
> > > > >> [    0.000000]  RCU debugfs-based tracing is enabled.
> > > > >> [    0.000000]  RCU dyntick-idle grace-period acceleration is enabled.
> > > > >> [    0.000000]  RCU restricting CPUs from NR_CPUS=256 to nr_cpu_ids=4.
> > > > >> [    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=4
> > > > >> [    0.000000] NR_IRQS:16640 nr_irqs:456 0
> > > > >> [    0.000000]  Offload RCU callbacks from all CPUs
> > > > >> [    0.000000]  Offload RCU callbacks from CPUs: 0-3.
> > > > >> 
> > > > >> 	but later shows 2:
> > > > >> 
> > > > >> [    0.233703] x86: Booting SMP configuration:
> > > > >> [    0.236003] .... node  #0, CPUs:      #1
> > > > >> [    0.255528] x86: Booted up 1 node, 2 CPUs
> > > > >> 
> > > > >> 	In any event, the E8400 is a 2 core CPU with no hyperthreading.
> > > > >
> > > > >Well, this might explain some of the difficulties.  If RCU decides to wait
> > > > >on CPUs that don't exist, we will of course get a hang.  And rcu_barrier()
> > > > >was definitely expecting four CPUs.
> > > > >
> > > > >So what happens if you boot with maxcpus=2?  (Or build with
> > > > >CONFIG_NR_CPUS=2.) I suspect that this might avoid the hang.  If so,
> > > > >I might have some ideas for a real fix.
> > > > 
> > > > 	Booting with maxcpus=2 makes no difference (the dmesg output is
> > > > the same).
> > > > 
> > > > 	Rebuilding with CONFIG_NR_CPUS=2 makes the problem go away, and
> > > > dmesg has different CPU information at boot:
> > > > 
> > > > [    0.000000] smpboot: 4 Processors exceeds NR_CPUS limit of 2
> > > > [    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
> > > >  [...]
> > > > [    0.000000] setup_percpu: NR_CPUS:2 nr_cpumask_bits:2 nr_cpu_ids:2 nr_node_ids:1
> > > >  [...]
> > > > [    0.000000] Hierarchical RCU implementation.
> > > > [    0.000000] 	RCU debugfs-based tracing is enabled.
> > > > [    0.000000] 	RCU dyntick-idle grace-period acceleration is enabled.
> > > > [    0.000000] NR_IRQS:4352 nr_irqs:440 0
> > > > [    0.000000] 	Offload RCU callbacks from all CPUs
> > > > [    0.000000] 	Offload RCU callbacks from CPUs: 0-1.
> > > 
> > > Thank you -- this confirms my suspicions on the fix, though I must admit
> > > to being surprised that maxcpus made no difference.
> > 
> > And here is an alleged fix, lightly tested at this end.  Does this patch
> > help?
> 
> Tested this on top of rc2 (as found in Fedora, and failing without the patch)
> with all my modprobe scenarios and it seems to have fixed it.

Very good!  May I apply your Tested-by?

							Thanx, Paul

> Thanks
> -Yanko
> 
> 
> > 							Thanx, Paul
> > 
> > ------------------------------------------------------------------------
> > 
> > rcu: Make rcu_barrier() understand about missing rcuo kthreads
> > 
> > Commit 35ce7f29a44a (rcu: Create rcuo kthreads only for onlined CPUs)
> > avoids creating rcuo kthreads for CPUs that never come online.  This
> > fixes a bug in many instances of firmware: Instead of lying about their
> > age, these systems instead lie about the number of CPUs that they have.
> > Before commit 35ce7f29a44a, this could result in huge numbers of useless
> > rcuo kthreads being created.
> > 
> > It appears that experience indicates that I should have told the
> > people suffering from this problem to fix their broken firmware, but
> > I instead produced what turned out to be a partial fix.   The missing
> > piece supplied by this commit makes sure that rcu_barrier() knows not to
> > post callbacks for no-CBs CPUs that have not yet come online, because
> > otherwise rcu_barrier() will hang on systems having firmware that lies
> > about the number of CPUs.
> > 
> > It is tempting to simply have rcu_barrier() refuse to post a callback on
> > any no-CBs CPU that does not have an rcuo kthread.  This unfortunately
> > does not work because rcu_barrier() is required to wait for all pending
> > callbacks.  It is therefore required to wait even for those callbacks
> > that cannot possibly be invoked.  Even if doing so hangs the system.
> > 
> > Given that posting a callback to a no-CBs CPU that does not yet have an
> > rcuo kthread can hang rcu_barrier(), It is tempting to report an error
> > in this case.  Unfortunately, this will result in false positives at
> > boot time, when it is perfectly legal to post callbacks to the boot CPU
> > before the scheduler has started, in other words, before it is legal
> > to invoke rcu_barrier().
> > 
> > So this commit instead has rcu_barrier() avoid posting callbacks to
> > CPUs having neither rcuo kthread nor pending callbacks, and has it
> > complain bitterly if it finds CPUs having no rcuo kthread but some
> > pending callbacks.  And when rcu_barrier() does find CPUs having no rcuo
> > kthread but pending callbacks, as noted earlier, it has no choice but
> > to hang indefinitely.
> > 
> > Reported-by: Yanko Kaneti <yaneti@declera.com>
> > Reported-by: Jay Vosburgh <jay.vosburgh@canonical.com>
> > Reported-by: Meelis Roos <mroos@linux.ee>
> > Reported-by: Eric B Munson <emunson@akamai.com>
> > Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > 
> > diff --git a/include/trace/events/rcu.h b/include/trace/events/rcu.h
> > index aa8e5eea3ab4..c78e88ce5ea3 100644
> > --- a/include/trace/events/rcu.h
> > +++ b/include/trace/events/rcu.h
> > @@ -660,18 +660,18 @@ TRACE_EVENT(rcu_torture_read,
> >  /*
> >   * Tracepoint for _rcu_barrier() execution.  The string "s" describes
> >   * the _rcu_barrier phase:
> > - *	"Begin": rcu_barrier_callback() started.
> > - *	"Check": rcu_barrier_callback() checking for piggybacking.
> > - *	"EarlyExit": rcu_barrier_callback() piggybacked, thus early exit.
> > - *	"Inc1": rcu_barrier_callback() piggyback check counter incremented.
> > - *	"Offline": rcu_barrier_callback() found offline CPU
> > - *	"OnlineNoCB": rcu_barrier_callback() found online no-CBs CPU.
> > - *	"OnlineQ": rcu_barrier_callback() found online CPU with callbacks.
> > - *	"OnlineNQ": rcu_barrier_callback() found online CPU, no callbacks.
> > + *	"Begin": _rcu_barrier() started.
> > + *	"Check": _rcu_barrier() checking for piggybacking.
> > + *	"EarlyExit": _rcu_barrier() piggybacked, thus early exit.
> > + *	"Inc1": _rcu_barrier() piggyback check counter incremented.
> > + *	"OfflineNoCB": _rcu_barrier() found callback on never-online CPU
> > + *	"OnlineNoCB": _rcu_barrier() found online no-CBs CPU.
> > + *	"OnlineQ": _rcu_barrier() found online CPU with callbacks.
> > + *	"OnlineNQ": _rcu_barrier() found online CPU, no callbacks.
> >   *	"IRQ": An rcu_barrier_callback() callback posted on remote CPU.
> >   *	"CB": An rcu_barrier_callback() invoked a callback, not the last.
> >   *	"LastCB": An rcu_barrier_callback() invoked the last callback.
> > - *	"Inc2": rcu_barrier_callback() piggyback check counter incremented.
> > + *	"Inc2": _rcu_barrier() piggyback check counter incremented.
> >   * The "cpu" argument is the CPU or -1 if meaningless, the "cnt" argument
> >   * is the count of remaining callbacks, and "done" is the piggybacking count.
> >   */
> > diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
> > index f6880052b917..7680fc275036 100644
> > --- a/kernel/rcu/tree.c
> > +++ b/kernel/rcu/tree.c
> > @@ -3312,11 +3312,16 @@ static void _rcu_barrier(struct rcu_state *rsp)
> >  			continue;
> >  		rdp = per_cpu_ptr(rsp->rda, cpu);
> >  		if (rcu_is_nocb_cpu(cpu)) {
> > -			_rcu_barrier_trace(rsp, "OnlineNoCB", cpu,
> > -					   rsp->n_barrier_done);
> > -			atomic_inc(&rsp->barrier_cpu_count);
> > -			__call_rcu(&rdp->barrier_head, rcu_barrier_callback,
> > -				   rsp, cpu, 0);
> > +			if (!rcu_nocb_cpu_needs_barrier(rsp, cpu)) {
> > +				_rcu_barrier_trace(rsp, "OfflineNoCB", cpu,
> > +						   rsp->n_barrier_done);
> > +			} else {
> > +				_rcu_barrier_trace(rsp, "OnlineNoCB", cpu,
> > +						   rsp->n_barrier_done);
> > +				atomic_inc(&rsp->barrier_cpu_count);
> > +				__call_rcu(&rdp->barrier_head,
> > +					   rcu_barrier_callback, rsp, cpu, 0);
> > +			}
> >  		} else if (ACCESS_ONCE(rdp->qlen)) {
> >  			_rcu_barrier_trace(rsp, "OnlineQ", cpu,
> >  					   rsp->n_barrier_done);
> > diff --git a/kernel/rcu/tree.h b/kernel/rcu/tree.h
> > index 4beab3d2328c..8e7b1843896e 100644
> > --- a/kernel/rcu/tree.h
> > +++ b/kernel/rcu/tree.h
> > @@ -587,6 +587,7 @@ static void print_cpu_stall_info(struct rcu_state *rsp, int cpu);
> >  static void print_cpu_stall_info_end(void);
> >  static void zero_cpu_stall_ticks(struct rcu_data *rdp);
> >  static void increment_cpu_stall_ticks(void);
> > +static bool rcu_nocb_cpu_needs_barrier(struct rcu_state *rsp, int cpu);
> >  static void rcu_nocb_gp_set(struct rcu_node *rnp, int nrq);
> >  static void rcu_nocb_gp_cleanup(struct rcu_state *rsp, struct rcu_node *rnp);
> >  static void rcu_init_one_nocb(struct rcu_node *rnp);
> > diff --git a/kernel/rcu/tree_plugin.h b/kernel/rcu/tree_plugin.h
> > index 927c17b081c7..68c5b23b7173 100644
> > --- a/kernel/rcu/tree_plugin.h
> > +++ b/kernel/rcu/tree_plugin.h
> > @@ -2050,6 +2050,33 @@ static void wake_nocb_leader(struct rcu_data *rdp, bool force)
> >  }
> >  
> >  /*
> > + * Does the specified CPU need an RCU callback for the specified flavor
> > + * of rcu_barrier()?
> > + */
> > +static bool rcu_nocb_cpu_needs_barrier(struct rcu_state *rsp, int cpu)
> > +{
> > +	struct rcu_data *rdp = per_cpu_ptr(rsp->rda, cpu);
> > +	struct rcu_head *rhp;
> > +
> > +	/* No-CBs CPUs might have callbacks on any of three lists. */
> > +	rhp = ACCESS_ONCE(rdp->nocb_head);
> > +	if (!rhp)
> > +		rhp = ACCESS_ONCE(rdp->nocb_gp_head);
> > +	if (!rhp)
> > +		rhp = ACCESS_ONCE(rdp->nocb_follower_head);
> > +
> > +	/* Having no rcuo kthread but CBs after scheduler starts is bad! */
> > +	if (!ACCESS_ONCE(rdp->nocb_kthread) && rhp) {
> > +		/* RCU callback enqueued before CPU first came online??? */
> > +		pr_err("RCU: Never-onlined no-CBs CPU %d has CB %p\n",
> > +		       cpu, rhp->func);
> > +		WARN_ON_ONCE(1);
> > +	}
> > +
> > +	return !!rhp;
> > +}
> > +
> > +/*
> >   * Enqueue the specified string of rcu_head structures onto the specified
> >   * CPU's no-CBs lists.  The CPU is specified by rdp, the head of the
> >   * string by rhp, and the tail of the string by rhtp.  The non-lazy/lazy
> > @@ -2646,6 +2673,10 @@ static bool init_nocb_callback_list(struct rcu_data *rdp)
> >  
> >  #else /* #ifdef CONFIG_RCU_NOCB_CPU */
> >  
> > +static bool rcu_nocb_cpu_needs_barrier(struct rcu_state *rsp, int cpu)
> > +{
> > +}
> > +
> >  static void rcu_nocb_gp_cleanup(struct rcu_state *rsp, struct rcu_node *rnp)
> >  {
> >  }
> > 
> 
