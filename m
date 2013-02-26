From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 04/46] percpu_rwlock: Implement the core design of
 Per-CPU Reader-Writer Locks
Date: Wed, 27 Feb 2013 01:00:47 +0530
Message-ID: <512D0D67.9010609@linux.vnet.ibm.com>
References: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com> <20130218123856.26245.46705.stgit@srivatsabhat.in.ibm.com> <CANN689F9S7c1M8+cEpz3tsxGF34+NTRBLvxgPUOtbvav5u+RRA@mail.gmail.com> <5122551E.1080703@linux.vnet.ibm.com>	<51226B46.9080707@linux.vnet.ibm.com> <CANN689FSxOz+0Cu7EG_yKD8ZE1OpT4kyT+ybLfXSqaifodJRpw@mail.gmail.com> <51226F91.7000108@linux.vnet.ibm.com> <CACvQF53bdh4_BxF0y1fnTVR+T2OmRc0jmWQYftsvx92-fg-Lug@mail.gmail.com> <512BBAD8.8010006@linux.vnet.ibm.com> <CACvQF51jCxk5jUqmhD=QBBtUsBkQWZzakacrKO4Gsk=w61rNwQ@mail.gmail.com> <512C7A38.8060906@linux.vnet.ibm.com> <CACvQF51RvhM8XNqu3-1OTQ=cZUZ=pAX+_zx0a29+W67N1X+BgQ@mail.gmail.com> <512CC509.1050000@linux.vnet.ibm.com> <CACvQF50UgiqPpDk3HCmV86zKSf6tPjqr0bZowfPEOJs0g0r0MQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Michel Lespinasse <walken@google.com>, linux-doc@vger.kernel.org,
	peterz@infradead.org, fweisbec@gmail.com,
	linux-kernel@vger.kernel.org, namhyung@kernel.org,
	mingo@kernel.org, linux-arch@vger.kernel.org,
	linux@arm.linux.org.uk, xiaoguangrong@linux.vnet.ibm.com,
	wangyun@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	rusty@rustcorp.com.au, rostedt@goodmis.org, rjw@sisk.pl,
	vincent.guittot@linaro.org, tglx@linutronix.de,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	oleg@redhat.com, sbw@mit.edu, tj@kernel.org,
	akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org
To: Lai Jiangshan <eag0628@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CACvQF50UgiqPpDk3HCmV86zKSf6tPjqr0bZowfPEOJs0g0r0MQ@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/26/2013 09:55 PM, Lai Jiangshan wrote:
> On Tue, Feb 26, 2013 at 10:22 PM, Srivatsa S. Bhat
> <srivatsa.bhat@linux.vnet.ibm.com> wrote:
>>
>> Hi Lai,
>>
>> I'm really not convinced that piggy-backing on lglocks would help
>> us in any way. But still, let me try to address some of the points
>> you raised...
>>
>> On 02/26/2013 06:29 PM, Lai Jiangshan wrote:
>>> On Tue, Feb 26, 2013 at 5:02 PM, Srivatsa S. Bhat
>>> <srivatsa.bhat@linux.vnet.ibm.com> wrote:
>>>> On 02/26/2013 05:47 AM, Lai Jiangshan wrote:
>>>>> On Tue, Feb 26, 2013 at 3:26 AM, Srivatsa S. Bhat
>>>>> <srivatsa.bhat@linux.vnet.ibm.com> wrote:
>>>>>> Hi Lai,
>>>>>>
>>>>>> On 02/25/2013 09:23 PM, Lai Jiangshan wrote:
>>>>>>> Hi, Srivatsa,
>>>>>>>
>>>>>>> The target of the whole patchset is nice for me.
>>>>>>
>>>>>> Cool! Thanks :-)
>>>>>>
>>>> [...]
>>>>
>>>> Unfortunately, I see quite a few issues with the code above. IIUC, the
>>>> writer and the reader both increment the same counters. So how will the
>>>> unlock() code in the reader path know when to unlock which of the locks?
>>>
>>> The same as your code, the reader(which nested in write C.S.) just dec
>>> the counters.
>>
>> And that works fine in my case because the writer and the reader update
>> _two_ _different_ counters.
> 
> I can't find any magic in your code, they are the same counter.
> 
>         /*
>          * It is desirable to allow the writer to acquire the percpu-rwlock
>          * for read (if necessary), without deadlocking or getting complaints
>          * from lockdep. To achieve that, just increment the reader_refcnt of
>          * this CPU - that way, any attempt by the writer to acquire the
>          * percpu-rwlock for read, will get treated as a case of nested percpu
>          * reader, which is safe, from a locking perspective.
>          */
>         this_cpu_inc(pcpu_rwlock->rw_state->reader_refcnt);
>

Whoa! Hold on, were you really referring to _this_ increment when you said
that, in your patch you would increment the refcnt at the writer? Then I guess
there is a major disconnect in our conversations. (I had assumed that you were
referring to the update of writer_signal, and were just trying to have a single
refcnt instead of reader_refcnt and writer_signal).

So, please let me clarify things a bit here. Forget about the above increment
of reader_refcnt at the writer side. Its almost utterly insignificant for our
current discussion. We can simply replace it with a check as shown below, at
the reader side:

void percpu_read_lock_irqsafe()
{
	if (current == active_writer)
		return;

	/* Rest of the code */
}

Now, assuming that, in your patch, you were trying to use the per-cpu refcnt
to allow the writer to safely take the reader path, you can simply get rid of
that percpu-refcnt, as demonstrated above.

So that would reduce your code to the following (after simplification):

lg_rwlock_local_read_lock()
{
	if (current == active_writer)
		return;
	if (arch_spin_trylock(per-cpu-spinlock))
		return;
	read_lock(global-rwlock);
}

Now, let us assume that hotplug is not happening, meaning, nobody is running
the writer side code. Now let's see what happens at the reader side in your
patch. As I mentioned earlier, the readers are _very_ frequent and can be in
very hot paths. And they also happen to be nested quite often. 

So, a non-nested reader acquires the per-cpu spinlock. Every subsequent nested
reader on that CPU has to acquire the global rwlock for read. Right there you
have 2 significant performance issues -
1. Acquiring the (spin) lock is costly
2. Acquiring the global rwlock causes cacheline bouncing, which hurts
   performance.

And why do we care so much about performance here? Because, the existing
kernel does an efficient preempt_disable() here - which is an optimized
per-cpu counter increment. Replacing that with such heavy primitives on the
reader side can be very bad.

Now, how does my patchset tackle this? My scheme just requires an increment
of a per-cpu refcnt (reader_refcnt) and memory barrier. Which is acceptable
from a performance-perspective, because IMHO its not horrendously worse than
a preempt_disable().

> 
>> If both of them update the same counter, there
>> will be a semantic clash - an increment of the counter can either mean that
>> a new writer became active, or it can also indicate a nested reader. A decrement
>> can also similarly have 2 meanings. And thus it will be difficult to decide
>> the right action to take, based on the value of the counter.
>>
>>>
>>>> (The counter-dropping-to-zero logic is not safe, since it can be updated
>>>> due to different reasons). And now that I look at it again, in the absence
>>>> of the writer, the reader is allowed to be recursive at the heavy cost of
>>>> taking the global rwlock for read, every 2nd time you nest (because the
>>>> spinlock is non-recursive).
>>>
>>> (I did not understand your comments of this part)
>>> nested reader is considered seldom.
>>
>> No, nested readers can be _quite_ frequent. Because, potentially all users
>> of preempt_disable() are readers - and its well-known how frequently we
>> nest preempt_disable(). As a simple example, any atomic reader who calls
>> smp_call_function() will become a nested reader, because smp_call_function()
>> itself is a reader. So reader nesting is expected to be quite frequent.
>>
>>> But if N(>=2) nested readers happen,
>>> the overhead is:
>>>     1 spin_try_lock() + 1 read_lock() + (N-1) __this_cpu_inc()
>>>
>>
>> In my patch, its just this_cpu_inc(). Note that these are _very_ hot paths.
>> So every bit of optimization that you can add is worthwhile.
>>
>> And your read_lock() is a _global_ lock - thus, it can lead to a lot of
>> cache-line bouncing. That's *exactly* why I have used per-cpu refcounts in
>> my synchronization scheme, to avoid taking the global rwlock as much as possible.
>>
>> Another important point to note is that, the overhead we are talking about
>> here, exists even when _not_ performing hotplug. And its the replacement to
>> the super-fast preempt_disable(). So its extremely important to consciously
>> minimize this overhead - else we'll end up slowing down the system significantly.
>>
> 
> All I was considered is "nested reader is seldom", so I always
> fallback to rwlock when nested.
> If you like, I can add 6 lines of code, the overhead is
> 1 spin_try_lock()(fast path)  + N  __this_cpu_inc()
> 

I'm assuming that calculation is no longer valid, considering that
we just discussed how the per-cpu refcnt that you were using is quite
unnecessary and can be removed.

IIUC, the overhead with your code, as per above discussion would be:
1 spin_try_lock() [non-nested] + N read_lock(global_rwlock).

Note that I'm referring to the scenario when hotplug is _not_ happening
(ie., nobody is running writer side code).

> The overhead of your code is
> 2 smp_mb() + N __this_cpu_inc()
> 

Right. And as you can see, this is much much better than the overhead
shown above.

> I don't see how much different.
> 
>>>> Also, this lg_rwlock implementation uses 3
>>>> different data-structures - a per-cpu spinlock, a global rwlock and
>>>> a per-cpu refcnt, and its not immediately apparent why you need those many
>>>> or even those many varieties.
>>>
>>> data-structures is the same as yours.
>>> fallback_reader_refcnt <--> reader_refcnt
>>
>> This has semantic problems, as noted above.
>>
>>> per-cpu spinlock <--> write_signal
>>
>> Acquire/release of (spin) lock is costlier than inc/dec of a counter, IIUC.
>>
>>> fallback_rwlock  <---> global_rwlock
>>>
>>>> Also I see that this doesn't handle the
>>>> case of interrupt-handlers also being readers.
>>>
>>> handled. nested reader will see the ref or take the fallback_rwlock
>>>
> 
> Sorry, _reentrance_ read_lock() will see the ref or take the fallback_rwlock
> 
>>
>> I'm not referring to simple nested readers here, but interrupt handlers who
>> can act as readers. For starters, the arch_spin_trylock() is not safe when
>> interrupt handlers can also run the same code, right? You'll need to save
>> and restore interrupts at critical points in the code. Also, the __foo()
>> variants used to read/update the counters are not interrupt-safe.
> 
> I must missed something.
> 
> Could you elaborate more why arch_spin_trylock() is not safe when
> interrupt handlers can also run the same code?
> 
> Could you elaborate more why __this_cpu_op variants is not
> interrupt-safe since they are always called paired.
>

Take a look at include/linux/percpu.h. You'll note that __this_cpu_*
operations map to __this_cpu_generic_to_op(), which doesn't disable interrupts
while doing the update. Hence you can get inconsistent results if an interrupt
hits the CPU at that time and the interrupt handler tries to do the same thing.
In contrast, if you use this_cpu_inc() for example, interrupts are explicitly
disabled during the update and hence you won't get inconsistent results.

> 
>> And,
>> the unlock() code in the reader path is again going to be confused about
>> what to do when interrupt handlers interrupt regular readers, due to the
>> messed up refcount.
> 
> I still can't understand.
>

The primary reason _I_ was using the refcnt vs the reason _you_ were using the
refcnt, appears to be very different. Maybe that's why the above statement
didn't make sense. In your case, IIUC, you can simply get rid of the refcnt
and replace it with the simple check I mentioned above. Whereas, I use
refcnts to keep the reader-side synchronization fast (and for reader-writer
communication).

 
Regards,
Srivatsa S. Bhat

