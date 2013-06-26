From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 15/45] rcu: Use get/put_online_cpus_atomic() to
 prevent CPU offline
Date: Wed, 26 Jun 2013 07:33:33 -0700
Message-ID: <20130626143333.GM3828@linux.vnet.ibm.com>
References: <20130625202452.16593.22810.stgit@srivatsabhat.in.ibm.com>
 <20130625202755.16593.67819.stgit@srivatsabhat.in.ibm.com>
 <20130625220026.GG3828@linux.vnet.ibm.com>
 <51CAF624.6060004@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, rusty@rustcorp.com.au, mingo@kernel.org,
	akpm@linux-foundation.org, namhyung@kernel.org, walken@google.com,
	vincent.guittot@linaro.org, laijs@cn.fujitsu.com,
	rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, sbw@mit.edu, fweisbec@gmail.com,
	zhong@linux.vnet.ibm.com, nikunj@linux.vnet.ibm.com,
	linux-pm@vger.kernel.org, linux-arch@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Dipankar Sarma <dipankar@in.ibm.com>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <51CAF624.6060004@linux.vnet.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 26, 2013 at 07:39:40PM +0530, Srivatsa S. Bhat wrote:
> On 06/26/2013 03:30 AM, Paul E. McKenney wrote:
> > On Wed, Jun 26, 2013 at 01:57:55AM +0530, Srivatsa S. Bhat wrote:
> >> Once stop_machine() is gone from the CPU offline path, we won't be able
> >> to depend on disabling preemption to prevent CPUs from going offline
> >> from under us.
> >>
> >> In RCU code, rcu_implicit_dynticks_qs() checks if a CPU is offline,
> >> while being protected by a spinlock. Use the get/put_online_cpus_atomic()
> >> APIs to prevent CPUs from going offline, while invoking from atomic context.
> > 
> > I am not completely sure that this is needed.  Here is a (quite possibly
> > flawed) argument for its not being needed:
> > 
> > o	rcu_gp_init() holds off CPU-hotplug operations during
> > 	grace-period initialization.  Therefore, RCU will avoid
> > 	looking for quiescent states from CPUs that were offline
> > 	(and thus in an extended quiescent state) at the beginning
> > 	of the grace period.
> > 
> > o	If force_qs_rnp() is looking for a quiescent state from
> > 	a given CPU, and if it senses that CPU as being offline,
> > 	then even without synchronization we know that the CPU
> > 	was offline some time during the current grace period.
> > 
> > 	After all, it was online at the beginning of the grace
> > 	period (otherwise, we would not be looking at it at all),
> > 	and our later sampling of its state must have therefore
> > 	happened after the start of the grace period.  Given that
> > 	the grace period has not yet ended, it also has to happened
> > 	before the end of the grace period.
> > 
> > o	Therefore, we should be able to sample the offline state
> > 	without synchronization.
> >
> 
> Thanks a lot for explaining the synchronization design in detail, Paul!
> I agree that get/put_online_cpus_atomic() is not necessary here.
> 
> Regarding the debug checks under CONFIG_DEBUG_HOTPLUG_CPU, to avoid
> false-positives, I'm thinking of introducing a few _nocheck() variants,
> on a case-by-case basis, like cpu_is_offline_nocheck() (useful here in RCU)
> and for_each_online_cpu_nocheck() (useful in percpu-counter code, as
> pointed out by Tejun Heo). These fine synchronization details are kinda
> hard to encapsulate in that debug logic, so we can use the _nocheck()
> variants here to avoid getting splats when running with DEBUG_HOTPLUG_CPU
> enabled.

Good point, and seems like a reasonable approach to me.

							Thanx, Paul
