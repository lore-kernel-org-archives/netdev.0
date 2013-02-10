From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 04/45] percpu_rwlock: Implement the core design of
 Per-CPU Reader-Writer Locks
Date: Mon, 11 Feb 2013 01:27:15 +0530
Message-ID: <5117FB9B.8070506@linux.vnet.ibm.com>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com> <20130122073347.13822.85876.stgit@srivatsabhat.in.ibm.com> <20130208231017.GK2666@linux.vnet.ibm.com> <5117F0C0.2030605@linux.vnet.ibm.com> <20130210194759.GJ2666@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, rusty@rustcorp.com.au, mingo@kernel.org,
	akpm@linux-foundation.org, namhyung@kernel.org,
	rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, rjw@sisk.pl, sbw@mit.edu,
	fweisbec@gmail.com, linux@arm.linux.org.uk,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <20130210194759.GJ2666@linux.vnet.ibm.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/11/2013 01:17 AM, Paul E. McKenney wrote:
> On Mon, Feb 11, 2013 at 12:40:56AM +0530, Srivatsa S. Bhat wrote:
>> On 02/09/2013 04:40 AM, Paul E. McKenney wrote:
>>> On Tue, Jan 22, 2013 at 01:03:53PM +0530, Srivatsa S. Bhat wrote:
>>>> Using global rwlocks as the backend for per-CPU rwlocks helps us avoid many
>>>> lock-ordering related problems (unlike per-cpu locks). However, global
>>>> rwlocks lead to unnecessary cache-line bouncing even when there are no
>>>> writers present, which can slow down the system needlessly.
>>>>
>> [...]
>>>> +	/*
>>>> +	 * We never allow heterogeneous nesting of readers. So it is trivial
>>>> +	 * to find out the kind of reader we are, and undo the operation
>>>> +	 * done by our corresponding percpu_read_lock().
>>>> +	 */
>>>> +	if (__this_cpu_read(*pcpu_rwlock->reader_refcnt)) {
>>>> +		this_cpu_dec(*pcpu_rwlock->reader_refcnt);
>>>> +		smp_wmb(); /* Paired with smp_rmb() in sync_reader() */
>>>
>>> Given an smp_mb() above, I don't understand the need for this smp_wmb().
>>> Isn't the idea that if the writer sees ->reader_refcnt decremented to
>>> zero, it also needs to see the effects of the corresponding reader's
>>> critical section?
>>>
>>
>> Not sure what you meant, but my idea here was that the writer should see
>> the reader_refcnt falling to zero as soon as possible, to avoid keeping the
>> writer waiting in a tight loop for longer than necessary.
>> I might have been a little over-zealous to use lighter memory barriers though,
>> (given our lengthy discussions in the previous versions to reduce the memory
>> barrier overheads), so the smp_wmb() used above might be wrong.
>>
>> So, are you saying that the smp_mb() you indicated above would be enough
>> to make the writer observe the 1->0 transition of reader_refcnt immediately?
>>
>>> Or am I missing something subtle here?  In any case, if this smp_wmb()
>>> really is needed, there should be some subsequent write that the writer
>>> might observe.  From what I can see, there is no subsequent write from
>>> this reader that the writer cares about.
>>
>> I thought the smp_wmb() here and the smp_rmb() at the writer would ensure
>> immediate reflection of the reader state at the writer side... Please correct
>> me if my understanding is incorrect.
> 
> Ah, but memory barriers are not so much about making data move faster
> through the machine, but more about making sure that ordering constraints
> are met.  After all, memory barriers cannot make electrons flow faster
> through silicon.  You should therefore use memory barriers only to
> constrain ordering, not to try to expedite electrons.
>

I guess I must have been confused after looking at that graph which showed
how much time it takes for other CPUs to notice the change in value of a
variable performed in a given CPU.. and must have gotten the (wrong) idea
that memory barriers also help speed that up! Very sorry about that!
 
>>>> +	} else {
>>>> +		read_unlock(&pcpu_rwlock->global_rwlock);
>>>> +	}
>>>> +
>>>> +	preempt_enable();
>>>> +}
>>>> +
>>>> +static inline void raise_writer_signal(struct percpu_rwlock *pcpu_rwlock,
>>>> +				       unsigned int cpu)
>>>> +{
>>>> +	per_cpu(*pcpu_rwlock->writer_signal, cpu) = true;
>>>> +}
>>>> +
>>>> +static inline void drop_writer_signal(struct percpu_rwlock *pcpu_rwlock,
>>>> +				      unsigned int cpu)
>>>> +{
>>>> +	per_cpu(*pcpu_rwlock->writer_signal, cpu) = false;
>>>> +}
>>>> +
>>>> +static void announce_writer_active(struct percpu_rwlock *pcpu_rwlock)
>>>> +{
>>>> +	unsigned int cpu;
>>>> +
>>>> +	for_each_online_cpu(cpu)
>>>> +		raise_writer_signal(pcpu_rwlock, cpu);
>>>> +
>>>> +	smp_mb(); /* Paired with smp_rmb() in percpu_read_[un]lock() */
>>>> +}
>>>> +
>>>> +static void announce_writer_inactive(struct percpu_rwlock *pcpu_rwlock)
>>>> +{
>>>> +	unsigned int cpu;
>>>> +
>>>> +	drop_writer_signal(pcpu_rwlock, smp_processor_id());
>>>
>>> Why do we drop ourselves twice?  More to the point, why is it important to
>>> drop ourselves first?
>>
>> I don't see where we are dropping ourselves twice. Note that we are no longer
>> in the cpu_online_mask, so the 'for' loop below won't include us. So we need
>> to manually drop ourselves. It doesn't matter whether we drop ourselves first
>> or later.
> 
> Good point, apologies for my confusion!  Still worth a commment, though.
> 

Sure, will add it.

>>>> +
>>>> +	for_each_online_cpu(cpu)
>>>> +		drop_writer_signal(pcpu_rwlock, cpu);
>>>> +
>>>> +	smp_mb(); /* Paired with smp_rmb() in percpu_read_[un]lock() */
>>>> +}
>>>> +
>>>> +/*
>>>> + * Wait for the reader to see the writer's signal and switch from percpu
>>>> + * refcounts to global rwlock.
>>>> + *
>>>> + * If the reader is still using percpu refcounts, wait for him to switch.
>>>> + * Else, we can safely go ahead, because either the reader has already
>>>> + * switched over, or the next reader that comes along on that CPU will
>>>> + * notice the writer's signal and will switch over to the rwlock.
>>>> + */
>>>> +static inline void sync_reader(struct percpu_rwlock *pcpu_rwlock,
>>>> +			       unsigned int cpu)
>>>> +{
>>>> +	smp_rmb(); /* Paired with smp_[w]mb() in percpu_read_[un]lock() */
>>>
>>> As I understand it, the purpose of this memory barrier is to ensure
>>> that the stores in drop_writer_signal() happen before the reads from
>>> ->reader_refcnt in reader_uses_percpu_refcnt(),
>>
>> No, that was not what I intended. announce_writer_inactive() already does
>> a full smp_mb() after calling drop_writer_signal().
>>
>> I put the smp_rmb() here and the smp_wmb() at the reader side (after updates
>> to the ->reader_refcnt) to reflect the state change of ->reader_refcnt
>> immediately at the writer, so that the writer doesn't have to keep spinning
>> unnecessarily still referring to the old (non-zero) value of ->reader_refcnt.
>> Or perhaps I am confused about how to use memory barriers properly.. :-(
> 
> Sadly, no, memory barriers don't make electrons move faster.  So you
> should only need the one -- the additional memory barriers are just
> slowing things down.
> 

Ok..

>>> thus preventing the
>>> race between a new reader attempting to use the fastpath and this writer
>>> acquiring the lock.  Unless I am confused, this must be smp_mb() rather
>>> than smp_rmb().
>>>
>>> Also, why not just have a single smp_mb() at the beginning of
>>> sync_all_readers() instead of executing one barrier per CPU?
>>
>> Well, since my intention was to help the writer see the update (->reader_refcnt
>> dropping to zero) ASAP, I kept the multiple smp_rmb()s.
> 
> At least you were consistent.  ;-)
>

Haha, that's an optimistic way of looking at it, but its no good if I was
consistently _wrong_! ;-)

>>>> +
>>>> +	while (reader_uses_percpu_refcnt(pcpu_rwlock, cpu))
>>>> +		cpu_relax();
>>>> +}
>>>> +
>>>> +static void sync_all_readers(struct percpu_rwlock *pcpu_rwlock)
>>>> +{
>>>> +	unsigned int cpu;
>>>> +
>>>> +	for_each_online_cpu(cpu)
>>>> +		sync_reader(pcpu_rwlock, cpu);
>>>>  }
>>>>
>>>>  void percpu_write_lock(struct percpu_rwlock *pcpu_rwlock)
>>>>  {
>>>> +	/*
>>>> +	 * Tell all readers that a writer is becoming active, so that they
>>>> +	 * start switching over to the global rwlock.
>>>> +	 */
>>>> +	announce_writer_active(pcpu_rwlock);
>>>> +	sync_all_readers(pcpu_rwlock);
>>>>  	write_lock(&pcpu_rwlock->global_rwlock);
>>>>  }
>>>>
>>>>  void percpu_write_unlock(struct percpu_rwlock *pcpu_rwlock)
>>>>  {
>>>> +	/*
>>>> +	 * Inform all readers that we are done, so that they can switch back
>>>> +	 * to their per-cpu refcounts. (We don't need to wait for them to
>>>> +	 * see it).
>>>> +	 */
>>>> +	announce_writer_inactive(pcpu_rwlock);
>>>>  	write_unlock(&pcpu_rwlock->global_rwlock);
>>>>  }
>>>>
>>>>
>>
>> Thanks a lot for your detailed review and comments! :-)
> 
> It will be good to get this in!
>

Thank you :-) I'll try to address the review comments and respin the
patchset soon.

Regards,
Srivatsa S. Bhat

