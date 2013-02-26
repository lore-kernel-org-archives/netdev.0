From: Lai Jiangshan <eag0628@gmail.com>
Subject: Re: [PATCH v6 04/46] percpu_rwlock: Implement the core design of
 Per-CPU Reader-Writer Locks
Date: Wed, 27 Feb 2013 00:25:33 +0800
Message-ID: <CACvQF50UgiqPpDk3HCmV86zKSf6tPjqr0bZowfPEOJs0g0r0MQ@mail.gmail.com>
References: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com>
	<20130218123856.26245.46705.stgit@srivatsabhat.in.ibm.com>
	<CANN689F9S7c1M8+cEpz3tsxGF34+NTRBLvxgPUOtbvav5u+RRA@mail.gmail.com>
	<5122551E.1080703@linux.vnet.ibm.com>
	<51226B46.9080707@linux.vnet.ibm.com>
	<CANN689FSxOz+0Cu7EG_yKD8ZE1OpT4kyT+ybLfXSqaifodJRpw@mail.gmail.com>
	<51226F91.7000108@linux.vnet.ibm.com>
	<CACvQF53bdh4_BxF0y1fnTVR+T2OmRc0jmWQYftsvx92-fg-Lug@mail.gmail.com>
	<512BBAD8.8010006@linux.vnet.ibm.com>
	<CACvQF51jCxk5jUqmhD=QBBtUsBkQWZzakacrKO4Gsk=w61rNwQ@mail.gmail.com>
	<512C7A38.8060906@linux.vnet.ibm.com>
	<CACvQF51RvhM8XNqu3-1OTQ=cZUZ=pAX+_zx0a29+W67N1X+BgQ@mail.gmail.com>
	<512CC509.1050000@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
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
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <512CC509.1050000@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 26, 2013 at 10:22 PM, Srivatsa S. Bhat
<srivatsa.bhat@linux.vnet.ibm.com> wrote:
>
> Hi Lai,
>
> I'm really not convinced that piggy-backing on lglocks would help
> us in any way. But still, let me try to address some of the points
> you raised...
>
> On 02/26/2013 06:29 PM, Lai Jiangshan wrote:
>> On Tue, Feb 26, 2013 at 5:02 PM, Srivatsa S. Bhat
>> <srivatsa.bhat@linux.vnet.ibm.com> wrote:
>>> On 02/26/2013 05:47 AM, Lai Jiangshan wrote:
>>>> On Tue, Feb 26, 2013 at 3:26 AM, Srivatsa S. Bhat
>>>> <srivatsa.bhat@linux.vnet.ibm.com> wrote:
>>>>> Hi Lai,
>>>>>
>>>>> On 02/25/2013 09:23 PM, Lai Jiangshan wrote:
>>>>>> Hi, Srivatsa,
>>>>>>
>>>>>> The target of the whole patchset is nice for me.
>>>>>
>>>>> Cool! Thanks :-)
>>>>>
>>> [...]
>>>
>>> Unfortunately, I see quite a few issues with the code above. IIUC, the
>>> writer and the reader both increment the same counters. So how will the
>>> unlock() code in the reader path know when to unlock which of the locks?
>>
>> The same as your code, the reader(which nested in write C.S.) just dec
>> the counters.
>
> And that works fine in my case because the writer and the reader update
> _two_ _different_ counters.

I can't find any magic in your code, they are the same counter.

        /*
         * It is desirable to allow the writer to acquire the percpu-rwlock
         * for read (if necessary), without deadlocking or getting complaints
         * from lockdep. To achieve that, just increment the reader_refcnt of
         * this CPU - that way, any attempt by the writer to acquire the
         * percpu-rwlock for read, will get treated as a case of nested percpu
         * reader, which is safe, from a locking perspective.
         */
        this_cpu_inc(pcpu_rwlock->rw_state->reader_refcnt);


> If both of them update the same counter, there
> will be a semantic clash - an increment of the counter can either mean that
> a new writer became active, or it can also indicate a nested reader. A decrement
> can also similarly have 2 meanings. And thus it will be difficult to decide
> the right action to take, based on the value of the counter.
>
>>
>>> (The counter-dropping-to-zero logic is not safe, since it can be updated
>>> due to different reasons). And now that I look at it again, in the absence
>>> of the writer, the reader is allowed to be recursive at the heavy cost of
>>> taking the global rwlock for read, every 2nd time you nest (because the
>>> spinlock is non-recursive).
>>
>> (I did not understand your comments of this part)
>> nested reader is considered seldom.
>
> No, nested readers can be _quite_ frequent. Because, potentially all users
> of preempt_disable() are readers - and its well-known how frequently we
> nest preempt_disable(). As a simple example, any atomic reader who calls
> smp_call_function() will become a nested reader, because smp_call_function()
> itself is a reader. So reader nesting is expected to be quite frequent.
>
>> But if N(>=2) nested readers happen,
>> the overhead is:
>>     1 spin_try_lock() + 1 read_lock() + (N-1) __this_cpu_inc()
>>
>
> In my patch, its just this_cpu_inc(). Note that these are _very_ hot paths.
> So every bit of optimization that you can add is worthwhile.
>
> And your read_lock() is a _global_ lock - thus, it can lead to a lot of
> cache-line bouncing. That's *exactly* why I have used per-cpu refcounts in
> my synchronization scheme, to avoid taking the global rwlock as much as possible.
>
> Another important point to note is that, the overhead we are talking about
> here, exists even when _not_ performing hotplug. And its the replacement to
> the super-fast preempt_disable(). So its extremely important to consciously
> minimize this overhead - else we'll end up slowing down the system significantly.
>

All I was considered is "nested reader is seldom", so I always
fallback to rwlock when nested.
If you like, I can add 6 lines of code, the overhead is
1 spin_try_lock()(fast path)  + N  __this_cpu_inc()

The overhead of your code is
2 smp_mb() + N __this_cpu_inc()

I don't see how much different.

>>> Also, this lg_rwlock implementation uses 3
>>> different data-structures - a per-cpu spinlock, a global rwlock and
>>> a per-cpu refcnt, and its not immediately apparent why you need those many
>>> or even those many varieties.
>>
>> data-structures is the same as yours.
>> fallback_reader_refcnt <--> reader_refcnt
>
> This has semantic problems, as noted above.
>
>> per-cpu spinlock <--> write_signal
>
> Acquire/release of (spin) lock is costlier than inc/dec of a counter, IIUC.
>
>> fallback_rwlock  <---> global_rwlock
>>
>>> Also I see that this doesn't handle the
>>> case of interrupt-handlers also being readers.
>>
>> handled. nested reader will see the ref or take the fallback_rwlock
>>

Sorry, _reentrance_ read_lock() will see the ref or take the fallback_rwlock

>
> I'm not referring to simple nested readers here, but interrupt handlers who
> can act as readers. For starters, the arch_spin_trylock() is not safe when
> interrupt handlers can also run the same code, right? You'll need to save
> and restore interrupts at critical points in the code. Also, the __foo()
> variants used to read/update the counters are not interrupt-safe.

I must missed something.

Could you elaborate more why arch_spin_trylock() is not safe when
interrupt handlers can also run the same code?

Could you elaborate more why __this_cpu_op variants is not
interrupt-safe since they are always called paired.


> And,
> the unlock() code in the reader path is again going to be confused about
> what to do when interrupt handlers interrupt regular readers, due to the
> messed up refcount.

I still can't understand.

>
>>>
>>> IMHO, the per-cpu rwlock scheme that I have implemented in this patchset
>>> has a clean, understandable design and just enough data-structures/locks
>>> to achieve its goal and has several optimizations (like reducing the
>>> interrupts-disabled time etc) included - all in a very straight-forward
>>> manner. Since this is non-trivial, IMHO, starting from a clean slate is
>>> actually better than trying to retrofit the logic into some locking scheme
>>> which we actively want to avoid (and hence effectively we aren't even
>>> borrowing anything from!).
>>>
>>> To summarize, if you are just pointing out that we can implement the same
>>> logic by altering lglocks, then sure, I acknowledge the possibility.
>>> However, I don't think doing that actually makes it better; it either
>>> convolutes the logic unnecessarily, or ends up looking _very_ similar to
>>> the implementation in this patchset, from what I can see.
>>>
>
