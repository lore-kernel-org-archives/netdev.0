From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 04/46] percpu_rwlock: Implement the core design of
 Per-CPU Reader-Writer Locks
Date: Tue, 26 Feb 2013 14:32:48 +0530
Message-ID: <512C7A38.8060906@linux.vnet.ibm.com>
References: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com> <20130218123856.26245.46705.stgit@srivatsabhat.in.ibm.com> <CANN689F9S7c1M8+cEpz3tsxGF34+NTRBLvxgPUOtbvav5u+RRA@mail.gmail.com> <5122551E.1080703@linux.vnet.ibm.com>	<51226B46.9080707@linux.vnet.ibm.com> <CANN689FSxOz+0Cu7EG_yKD8ZE1OpT4kyT+ybLfXSqaifodJRpw@mail.gmail.com> <51226F91.7000108@linux.vnet.ibm.com> <CACvQF53bdh4_BxF0y1fnTVR+T2OmRc0jmWQYftsvx92-fg-Lug@mail.gmail.com> <512BBAD8.8010006@linux.vnet.ibm.com> <CACvQF51jCxk5jUqmhD=QBBtUsBkQWZzakacrKO4Gsk=w61rNwQ@mail.gmail.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACvQF51jCxk5jUqmhD=QBBtUsBkQWZzakacrKO4Gsk=w61rNwQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/26/2013 05:47 AM, Lai Jiangshan wrote:
> On Tue, Feb 26, 2013 at 3:26 AM, Srivatsa S. Bhat
> <srivatsa.bhat@linux.vnet.ibm.com> wrote:
>> Hi Lai,
>>
>> On 02/25/2013 09:23 PM, Lai Jiangshan wrote:
>>> Hi, Srivatsa,
>>>
>>> The target of the whole patchset is nice for me.
>>
>> Cool! Thanks :-)
>>
[...]
>>> I wrote an untested draft here.
>>>
>>> Thanks,
>>> Lai
>>>
>>> PS: Some HA tools(I'm writing one) which takes checkpoints of
>>> virtual-machines frequently, I guess this patchset can speedup the
>>> tools.
>>>
>>> From 01db542693a1b7fc6f9ece45d57cb529d9be5b66 Mon Sep 17 00:00:00 2001
>>> From: Lai Jiangshan <laijs@cn.fujitsu.com>
>>> Date: Mon, 25 Feb 2013 23:14:27 +0800
>>> Subject: [PATCH] lglock: add read-preference local-global rwlock
>>>
>>> locality via lglock(trylock)
>>> read-preference read-write-lock via fallback rwlock_t
>>>
>>> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
>>> ---
>>>  include/linux/lglock.h |   31 +++++++++++++++++++++++++++++++
>>>  kernel/lglock.c        |   45 +++++++++++++++++++++++++++++++++++++++++++++
>>>  2 files changed, 76 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/include/linux/lglock.h b/include/linux/lglock.h
>>> index 0d24e93..30fe887 100644
>>> --- a/include/linux/lglock.h
>>> +++ b/include/linux/lglock.h
>>> @@ -67,4 +67,35 @@ void lg_local_unlock_cpu(struct lglock *lg, int cpu);
>>>  void lg_global_lock(struct lglock *lg);
>>>  void lg_global_unlock(struct lglock *lg);
>>>
>>> +struct lgrwlock {
>>> +     unsigned long __percpu *fallback_reader_refcnt;
>>> +     struct lglock lglock;
>>> +     rwlock_t fallback_rwlock;
>>> +};
>>> +
>>> +#define DEFINE_LGRWLOCK(name)                                                \
>>> +     static DEFINE_PER_CPU(arch_spinlock_t, name ## _lock)           \
>>> +     = __ARCH_SPIN_LOCK_UNLOCKED;                                    \
>>> +     static DEFINE_PER_CPU(unsigned long, name ## _refcnt);          \
>>> +     struct lgrwlock name = {                                        \
>>> +             .fallback_reader_refcnt = &name ## _refcnt,             \
>>> +             .lglock = { .lock = &name ## _lock } }
>>> +
>>> +#define DEFINE_STATIC_LGRWLOCK(name)                                 \
>>> +     static DEFINE_PER_CPU(arch_spinlock_t, name ## _lock)           \
>>> +     = __ARCH_SPIN_LOCK_UNLOCKED;                                    \
>>> +     static DEFINE_PER_CPU(unsigned long, name ## _refcnt);          \
>>> +     static struct lgrwlock name = {                                 \
>>> +             .fallback_reader_refcnt = &name ## _refcnt,             \
>>> +             .lglock = { .lock = &name ## _lock } }
>>> +
>>> +static inline void lg_rwlock_init(struct lgrwlock *lgrw, char *name)
>>> +{
>>> +     lg_lock_init(&lgrw->lglock, name);
>>> +}
>>> +
>>> +void lg_rwlock_local_read_lock(struct lgrwlock *lgrw);
>>> +void lg_rwlock_local_read_unlock(struct lgrwlock *lgrw);
>>> +void lg_rwlock_global_write_lock(struct lgrwlock *lgrw);
>>> +void lg_rwlock_global_write_unlock(struct lgrwlock *lgrw);
>>>  #endif
>>> diff --git a/kernel/lglock.c b/kernel/lglock.c
>>> index 6535a66..463543a 100644
>>> --- a/kernel/lglock.c
>>> +++ b/kernel/lglock.c
>>> @@ -87,3 +87,48 @@ void lg_global_unlock(struct lglock *lg)
>>>       preempt_enable();
>>>  }
>>>  EXPORT_SYMBOL(lg_global_unlock);
>>> +
>>> +void lg_rwlock_local_read_lock(struct lgrwlock *lgrw)
>>> +{
>>> +     struct lglock *lg = &lgrw->lglock;
>>> +
>>> +     preempt_disable();
>>> +     if (likely(!__this_cpu_read(*lgrw->fallback_reader_refcnt))) {
>>> +             if (likely(arch_spin_trylock(this_cpu_ptr(lg->lock)))) {
>>> +                     rwlock_acquire_read(&lg->lock_dep_map, 0, 0, _RET_IP_);
>>> +                     return;
>>> +             }
>>> +             read_lock(&lgrw->fallback_rwlock);
>>> +     }
>>> +
>>> +     __this_cpu_inc(*lgrw->fallback_reader_refcnt);
>>> +}
>>> +EXPORT_SYMBOL(lg_rwlock_local_read_lock);
>>> +
>>> +void lg_rwlock_local_read_unlock(struct lgrwlock *lgrw)
>>> +{
>>> +     if (likely(!__this_cpu_read(*lgrw->fallback_reader_refcnt))) {
>>> +             lg_local_unlock(&lgrw->lglock);
>>> +             return;
>>> +     }
>>> +
>>> +     if (!__this_cpu_dec_return(*lgrw->fallback_reader_refcnt))
>>> +             read_unlock(&lgrw->fallback_rwlock);
>>> +
>>> +     preempt_enable();
>>> +}
>>> +EXPORT_SYMBOL(lg_rwlock_local_read_unlock);
>>> +
>>
>> If I read the code above correctly, all you are doing is implementing a
>> recursive reader-side primitive (ie., allowing the reader to call these
>> functions recursively, without resulting in a self-deadlock).
>>
>> But the thing is, making the reader-side recursive is the least of our
>> problems! Our main challenge is to make the locking extremely flexible
>> and also safe-guard it against circular-locking-dependencies and deadlocks.
>> Please take a look at the changelog of patch 1 - it explains the situation
>> with an example.
> 
> 
> My lock fixes your requirements(I read patch 1-6 before I sent). In
> readsite, lglock 's lock is token via trylock, the lglock doesn't
> contribute to deadlocks, we can consider it doesn't exist when we find
> deadlock from it. And global fallback rwlock doesn't result to
> deadlocks because it is read-preference(you need to inc the
> fallback_reader_refcnt inside the cpu-hotplug write-side, I don't do
> it in generic lgrwlock)
>

Ah, since you hadn't mentioned the increment at the writer-side in your
previous email, I had missed the bigger picture of what you were trying
to achieve.
 
> 
> If lg_rwlock_local_read_lock() spins, which means
> lg_rwlock_local_read_lock() spins on fallback_rwlock, and which means
> lg_rwlock_global_write_lock() took the lgrwlock successfully and
> return, and which means lg_rwlock_local_read_lock() will stop spinning
> when the write side finished.
> 

Unfortunately, I see quite a few issues with the code above. IIUC, the
writer and the reader both increment the same counters. So how will the
unlock() code in the reader path know when to unlock which of the locks?
(The counter-dropping-to-zero logic is not safe, since it can be updated
due to different reasons). And now that I look at it again, in the absence
of the writer, the reader is allowed to be recursive at the heavy cost of
taking the global rwlock for read, every 2nd time you nest (because the
spinlock is non-recursive). Also, this lg_rwlock implementation uses 3
different data-structures - a per-cpu spinlock, a global rwlock and
a per-cpu refcnt, and its not immediately apparent why you need those many
or even those many varieties. Also I see that this doesn't handle the
case of interrupt-handlers also being readers.

IMHO, the per-cpu rwlock scheme that I have implemented in this patchset
has a clean, understandable design and just enough data-structures/locks
to achieve its goal and has several optimizations (like reducing the
interrupts-disabled time etc) included - all in a very straight-forward
manner. Since this is non-trivial, IMHO, starting from a clean slate is
actually better than trying to retrofit the logic into some locking scheme
which we actively want to avoid (and hence effectively we aren't even
borrowing anything from!).

To summarize, if you are just pointing out that we can implement the same
logic by altering lglocks, then sure, I acknowledge the possibility.
However, I don't think doing that actually makes it better; it either
convolutes the logic unnecessarily, or ends up looking _very_ similar to
the implementation in this patchset, from what I can see.

Regards,
Srivatsa S. Bhat
