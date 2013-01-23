From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 04/45] percpu_rwlock: Implement the core design of
 Per-CPU Reader-Writer Locks
Date: Thu, 24 Jan 2013 01:03:52 +0530
Message-ID: <51003B20.2060506@linux.vnet.ibm.com>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com> <20130122073347.13822.85876.stgit@srivatsabhat.in.ibm.com> <20130123185522.GG2373@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, peterz@infradead.org, oleg@redhat.com,
	paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, rjw@sisk.pl, sbw@mit.edu,
	fweisbec@gmail.com, linux@arm.linux.org.uk,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20130123185522.GG2373@mtj.dyndns.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/24/2013 12:25 AM, Tejun Heo wrote:
> Hello, Srivatsa.
> 
> First of all, I'm not sure whether we need to be this step-by-step
> when introducing something new.  It's not like we're transforming an
> existing implementation and it doesn't seem to help understanding the
> series that much either.
> 

Hmm.. I split it up into steps to help explain the reasoning behind
the code sufficiently, rather than spring all of the intricacies at
one go (which would make it very hard to write the changelog/comments
also). The split made it easier for me to document it well in the
changelog, because I could deal with reasonable chunks of code/complexity
at a time. IMHO that helps people reading it for the first time to
understand the logic easily.

> On Tue, Jan 22, 2013 at 01:03:53PM +0530, Srivatsa S. Bhat wrote:
>> Using global rwlocks as the backend for per-CPU rwlocks helps us avoid many
>> lock-ordering related problems (unlike per-cpu locks). However, global
> 
> So, unfortunately, this already seems broken, right?  The problem here
> seems to be that previously, say, read_lock() implied
> preempt_disable() but as this series aims to move away from it, it
> introduces the problem of locking order between such locks and the new
> contruct.
>

Not sure I got your point correctly. Are you referring to Steve's comment
that rwlocks are probably fair now (and hence not really safe when used
like this)? If yes, I haven't actually verified that yet, but yes, that
will make this hard to use, since we need to take care of locking rules.

But suppose rwlocks are unfair (as I had assumed them to be), then we
have absolutely no problems and no lock-ordering to worry about.
 
> The only two options are either punishing writers or identifying and
> updating all such possible deadlocks.  percpu_rwsem does the former,
> right?  I don't know how feasible the latter would be.

I don't think we can avoid looking into all the possible deadlocks,
as long as we use rwlocks inside get/put_online_cpus_atomic() (assuming
rwlocks are fair). Even with Oleg's idea of using synchronize_sched()
at the writer, we still need to take care of locking rules, because the
synchronize_sched() only helps avoid the memory barriers at the reader,
and doesn't help get rid of the rwlocks themselves.
So in short, I don't see how we can punish the writers and thereby somehow
avoid looking into possible deadlocks (if rwlocks are fair).

>  Srivatsa,
> you've been looking at all the places which would require conversion,
> how difficult would doing the latter be?
> 

The problem is that some APIs like smp_call_function() will need to use
get/put_online_cpus_atomic(). That is when the locking becomes tricky
in the subsystem which invokes these APIs with other (subsystem-specific,
internal) locks held. So we could potentially use a convention such as
"Make get/put_online_cpus_atomic() your outer-most calls, within which
you nest the other locks" to rule out all ABBA deadlock possibilities...
But we might still hit some hard-to-convert places.. 

BTW, Steve, fair rwlocks doesn't mean the following scenario will result
in a deadlock right?

CPU 0                          CPU 1

read_lock(&rwlock)

                              write_lock(&rwlock) //spins, because CPU 0
                              //has acquired the lock for read

read_lock(&rwlock)
   ^^^^^
What happens here? Does CPU 0 start spinning (and hence deadlock) or will
it continue realizing that it already holds the rwlock for read?

If the above ends in a deadlock, then its next to impossible to convert
all the places safely (because the above mentioned convention will simply
fall apart).

>> +#define reader_uses_percpu_refcnt(pcpu_rwlock, cpu)			\
>> +		(ACCESS_ONCE(per_cpu(*((pcpu_rwlock)->reader_refcnt), cpu)))
>> +
>> +#define reader_nested_percpu(pcpu_rwlock)				\
>> +			(__this_cpu_read(*((pcpu_rwlock)->reader_refcnt)) > 1)
>> +
>> +#define writer_active(pcpu_rwlock)					\
>> +			(__this_cpu_read(*((pcpu_rwlock)->writer_signal)))
> 
> Why are these in the public header file?  Are they gonna be used to
> inline something?
>

No, I can put it in the .c file itself. Will do.
 
>> +static inline void raise_writer_signal(struct percpu_rwlock *pcpu_rwlock,
>> +				       unsigned int cpu)
>> +{
>> +	per_cpu(*pcpu_rwlock->writer_signal, cpu) = true;
>> +}
>> +
>> +static inline void drop_writer_signal(struct percpu_rwlock *pcpu_rwlock,
>> +				      unsigned int cpu)
>> +{
>> +	per_cpu(*pcpu_rwlock->writer_signal, cpu) = false;
>> +}
>> +
>> +static void announce_writer_active(struct percpu_rwlock *pcpu_rwlock)
>> +{
>> +	unsigned int cpu;
>> +
>> +	for_each_online_cpu(cpu)
>> +		raise_writer_signal(pcpu_rwlock, cpu);
>> +
>> +	smp_mb(); /* Paired with smp_rmb() in percpu_read_[un]lock() */
>> +}
>> +
>> +static void announce_writer_inactive(struct percpu_rwlock *pcpu_rwlock)
>> +{
>> +	unsigned int cpu;
>> +
>> +	drop_writer_signal(pcpu_rwlock, smp_processor_id());
>> +
>> +	for_each_online_cpu(cpu)
>> +		drop_writer_signal(pcpu_rwlock, cpu);
>> +
>> +	smp_mb(); /* Paired with smp_rmb() in percpu_read_[un]lock() */
>> +}
> 
> It could be just personal preference but I find the above one line
> wrappers more obfuscating than anything else.  What's the point of
> wrapping writer_signal = true/false into a separate function?  These
> simple wrappers just add layers that people have to dig through to
> figure out what's going on without adding anything of value.  I'd much
> prefer collapsing these into the percpu_write_[un]lock().
>

Sure, I see your point. I'll change that.

Thanks a lot for your feedback Tejun!

Regards,
Srivatsa S. Bhat

