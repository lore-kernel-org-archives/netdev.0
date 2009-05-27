From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH RFC] v5 expedited "big hammer" RCU grace periods
Date: Thu, 28 May 2009 00:57:05 +0200
Message-ID: <20090527225705.GA2594@elte.hu>
References: <20090518075630.GA10687@elte.hu> <20090518151421.GB6768@linux.vnet.ibm.com> <20090518154241.GA27047@elte.hu> <20090518160254.GD6768@linux.vnet.ibm.com> <20090519085825.GA9388@elte.hu> <20090519123316.GA7159@linux.vnet.ibm.com> <20090519124436.GA6238@elte.hu> <20090519161839.GA6750@linux.vnet.ibm.com> <20090520080924.GA6736@elte.hu> <20090520153023.GB6729@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, davem@davemloft.net,
	dada1@cosmosbay.com, zbr@ioremap.net, jeff.chua.linux@gmail.com,
	paulus@samba.org, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Gautham R Shenoy <ego@in.ibm.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090520153023.GB6729@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:

> On Wed, May 20, 2009 at 10:09:24AM +0200, Ingo Molnar wrote:
> > 
> > * Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> > 
> > > On Tue, May 19, 2009 at 02:44:36PM +0200, Ingo Molnar wrote:
> > > > 
> > > > * Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> > > > 
> > > > > On Tue, May 19, 2009 at 10:58:25AM +0200, Ingo Molnar wrote:
> > > > > > 
> > > > > > * Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> > > > > > 
> > > > > > > On Mon, May 18, 2009 at 05:42:41PM +0200, Ingo Molnar wrote:
> > > > > > > > 
> > > > > > > > * Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> > > > > > > > 
> > > > > > > > > > i might be missing something fundamental here, but why not just 
> > > > > > > > > > have per CPU helper threads, all on the same waitqueue, and wake 
> > > > > > > > > > them up via a single wake_up() call? That would remove the SMP 
> > > > > > > > > > cross call (wakeups do immediate cross-calls already).
> > > > > > > > > 
> > > > > > > > > My concern with this is that the cache misses accessing all the 
> > > > > > > > > processes on this single waitqueue would be serialized, slowing 
> > > > > > > > > things down. In contrast, the bitmask that smp_call_function() 
> > > > > > > > > traverses delivers on the order of a thousand CPUs' worth of bits 
> > > > > > > > > per cache miss.  I will give it a try, though.
> > > > > > > > 
> > > > > > > > At least if you go via the migration threads, you can queue up 
> > > > > > > > requests to them locally. But there's going to be cachemisses 
> > > > > > > > _anyway_, since you have to access them all from a single CPU, 
> > > > > > > > and then they have to fetch details about what to do, and then 
> > > > > > > > have to notify the originator about completion.
> > > > > > > 
> > > > > > > Ah, so you are suggesting that I use smp_call_function() to run 
> > > > > > > code on each CPU that wakes up that CPU's migration thread?  I 
> > > > > > > will take a look at this.
> > > > > > 
> > > > > > My suggestion was to queue up a dummy 'struct migration_req' up with 
> > > > > > it (change migration_req::task == NULL to mean 'nothing') and simply 
> > > > > > wake it up using wake_up_process().
> > > > > 
> > > > > OK.  I was thinking of just using wake_up_process() without the
> > > > > migration_req structure, and unconditionally setting a per-CPU
> > > > > variable from within migration_thread() just before the list_empty()
> > > > > check.  In your approach we would need a NULL-pointer check just
> > > > > before the call to __migrate_task().
> > > > > 
> > > > > > That will force a quiescent state, without the need for any extra 
> > > > > > information, right?
> > > > > 
> > > > > Yep!
> > > > > 
> > > > > > This is what the scheduler code does, roughly:
> > > > > > 
> > > > > >                 wake_up_process(rq->migration_thread);
> > > > > >                 wait_for_completion(&req.done);
> > > > > > 
> > > > > > and this will always have to perform well. The 'req' could be put 
> > > > > > into PER_CPU, and a loop could be done like this:
> > > > > > 
> > > > > > 	for_each_online_cpu(cpu)
> > > > > >                 wake_up_process(cpu_rq(cpu)->migration_thread);
> > > > > > 
> > > > > > 	for_each_online_cpu(cpu)
> > > > > >                 wait_for_completion(&per_cpu(req, cpu).done);
> > > > > > 
> > > > > > hm?
> > > > > 
> > > > > My concern is the linear slowdown for large systems, but this 
> > > > > should be OK for modest systems (a few 10s of CPUs).  However, I 
> > > > > will try it out -- it does not need to be a long-term solution, 
> > > > > after all.
> > > > 
> > > > I think there is going to be a linear slowdown no matter what - 
> > > > because sending that many IPIs is going to be linear. (there are 
> > > > no 'broadcast to all' IPIs anymore - on x86 we only have them if 
> > > > all physical APIC IDs are 7 or smaller.)
> > > 
> > > With the current code, agreed.  One could imagine making an IPI 
> > > tree, so that a given CPU IPIs (say) eight subordinates.  Making 
> > > this work nice with CPU hotplug would be entertaining, to say the 
> > > least.
> > 
> > Certainly! :-)
> > 
> > As a general note, unrelated to your patches: i think our 
> > CPU-hotplug related complexity seems to be a bit too much. This is 
> > really just a gut feeling - from having seen many patches that also 
> > have hotplug notifiers.
> > 
> > I'm wondering whether this is because it's structured in a 
> > suboptimal way, or because i'm (intuitively) under-estimating the 
> > complexity of what it takes to express what happens when a CPU is 
> > offlined and then onlined?
> 
> I suppose that I could take this as a cue to reminisce about the 
> old days in a past life with a different implementation of CPU 
> online/offline, but life is just too short for that sort of thing.  
> Not that guys my age let that stop them.  ;-)
> 
> And in that past life, exercising CPU online/offline usually 
> exposed painful bugs in new code, so I cannot claim that the 
> old-life approach to CPU hotplug was perfect.  Interestingly 
> enough, running uniprocessor also exposed painful bugs more often 
> than not.  Of course, the only way to run uniprocessor was to 
> offline all but one of the CPUs, so you would hit the 
> online/offline bugs before hitting the uniprocessor-only bugs.
> 
> The thing that worries me most about CPU hotplug in Linux is that 
> there is no clear hierarchy of CPU function in the offline 
> process, given that the offlining process invokes notifiers in the 
> same order as does the onlining process.  Whether this is a real 
> defect in the CPU hotplug design or is instead simply a symptom of 
> my not yet being fully comfortable with the two-phase CPU-removal 
> process is an interesting question to which I do not have an 
> answer.

I strongly believe it's the former.

> Either way, the thought process is different.  In my old life, 
> CPUs shed roles in the opposite order that they acquired them.  

Yeah, that looks a whole lot more logical to do.

> This meant that a given CPU was naturally guaranteed to be 
> correctly taking interrupts for the entire time that it was 
> capable of running user-level processes. Later in the offlining 
> process, it would still take interrupts, but would be unable to 
> run user processes.  Still later, it would no longer be taking 
> interrupts, and would stop participating in RCU and in the global 
> TLB-flush algorithm.  There was no need to stop the whole machine 
> to make a given CPU go offline, in fact, most of the work was done 
> by the CPU in question.
> 
> In the case of RCU, this meant that there was no need for 
> double-checking for offlined CPUs, because CPUs could reliably 
> indicate a quiescent state on their way out.
> 
> On the other hand, there was no equivalent of dynticks in the old 
> days. And it is dynticks that is responsible for most of the 
> complexity present in force_quiescent_state(), not CPU hotplug.
> 
> So I cannot hold up RCU as something that would be greatly 
> simplified by changing the CPU hotplug design, much as I might 
> like to.  ;-)

We could probably remove a fair bit of dynticks complexity by 
removing non-dynticks and removing non-hrtimer. People could still 
force a 'periodic' interrupting mode (if they want, or if their hw 
forces that), but that would be a plain periodic hrtimer firing off 
all the time.

	Ingo
