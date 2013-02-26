From: Lai Jiangshan <eag0628@gmail.com>
Subject: Re: [PATCH v6 04/46] percpu_rwlock: Implement the core design of
 Per-CPU Reader-Writer Locks
Date: Tue, 26 Feb 2013 21:34:09 +0800
Message-ID: <CACvQF53gcuEfgM=L8-mPTt4W3GFMte-w6eyO0iv2CobAN68SNw@mail.gmail.com>
References: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com>
	<20130218123856.26245.46705.stgit@srivatsabhat.in.ibm.com>
	<CANN689F9S7c1M8+cEpz3tsxGF34+NTRBLvxgPUOtbvav5u+RRA@mail.gmail.com>
	<5122551E.1080703@linux.vnet.ibm.com>
	<51226B46.9080707@linux.vnet.ibm.com>
	<CANN689FSxOz+0Cu7EG_yKD8ZE1OpT4kyT+ybLfXSqaifodJRpw@mail.gmail.com>
	<51226F91.7000108@linux.vnet.ibm.com>
	<CACvQF53bdh4_BxF0y1fnTVR+T2OmRc0jmWQYftsvx92-fg-Lug@mail.gmail.com>
	<512BBAD8.8010006@linux.vnet.ibm.com>
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
	akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org,
	Lai Jiangshan <laijs@cn.fujitsu.com>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <512BBAD8.8010006@linux.vnet.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 26, 2013 at 3:26 AM, Srivatsa S. Bhat
<srivatsa.bhat@linux.vnet.ibm.com> wrote:
> Hi Lai,
>
> On 02/25/2013 09:23 PM, Lai Jiangshan wrote:
>> Hi, Srivatsa,
>>
>> The target of the whole patchset is nice for me.
>
> Cool! Thanks :-)
>
>> A question: How did you find out the such usages of
>> "preempt_disable()" and convert them? did all are converted?
>>
>
> Well, I scanned through the source tree for usages which implicitly
> disabled CPU offline and converted them over.

How do you scan? could you show the way you scan the source tree.
I can follow your instructions for double checking.

> Its not limited to uses
> of preempt_disable() alone - even spin_locks, rwlocks, local_irq_disable()
> etc also help disable CPU offline. So I tried to dig out all such uses
> and converted them. However, since the merge window is open, a lot of
> new code is flowing into the tree. So I'll have to rescan the tree to
> see if there are any more places to convert.

I remember some code has such assumption:
    preempt_disable() (or something else)
    //the code assume that the cpu_online_map can't be changed.
    preempt_enable()

It is very hard to find out all such kinds of assumptions and fixes them.
(I notice your code mainly fixes code around send_xxxx())


>
>> And I think the lock is too complex and reinvent the wheel, why don't
>> you reuse the lglock?
>
> lglocks? No way! ;-) See below...
>
>> I wrote an untested draft here.
>>
>> Thanks,
>> Lai
>>
>> PS: Some HA tools(I'm writing one) which takes checkpoints of
>> virtual-machines frequently, I guess this patchset can speedup the
>> tools.
>>
>> From 01db542693a1b7fc6f9ece45d57cb529d9be5b66 Mon Sep 17 00:00:00 2001
>> From: Lai Jiangshan <laijs@cn.fujitsu.com>
>> Date: Mon, 25 Feb 2013 23:14:27 +0800
>> Subject: [PATCH] lglock: add read-preference local-global rwlock
>>
>> locality via lglock(trylock)
>> read-preference read-write-lock via fallback rwlock_t
>>
>> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
>> ---
>>  include/linux/lglock.h |   31 +++++++++++++++++++++++++++++++
>>  kernel/lglock.c        |   45 +++++++++++++++++++++++++++++++++++++++++++++
>>  2 files changed, 76 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/linux/lglock.h b/include/linux/lglock.h
>> index 0d24e93..30fe887 100644
>> --- a/include/linux/lglock.h
>> +++ b/include/linux/lglock.h
>> @@ -67,4 +67,35 @@ void lg_local_unlock_cpu(struct lglock *lg, int cpu);
>>  void lg_global_lock(struct lglock *lg);
>>  void lg_global_unlock(struct lglock *lg);
>>
>> +struct lgrwlock {
>> +     unsigned long __percpu *fallback_reader_refcnt;
>> +     struct lglock lglock;
>> +     rwlock_t fallback_rwlock;
>> +};
>> +
>> +#define DEFINE_LGRWLOCK(name)                                                \
>> +     static DEFINE_PER_CPU(arch_spinlock_t, name ## _lock)           \
>> +     = __ARCH_SPIN_LOCK_UNLOCKED;                                    \
>> +     static DEFINE_PER_CPU(unsigned long, name ## _refcnt);          \
>> +     struct lgrwlock name = {                                        \
>> +             .fallback_reader_refcnt = &name ## _refcnt,             \
>> +             .lglock = { .lock = &name ## _lock } }
>> +
>> +#define DEFINE_STATIC_LGRWLOCK(name)                                 \
>> +     static DEFINE_PER_CPU(arch_spinlock_t, name ## _lock)           \
>> +     = __ARCH_SPIN_LOCK_UNLOCKED;                                    \
>> +     static DEFINE_PER_CPU(unsigned long, name ## _refcnt);          \
>> +     static struct lgrwlock name = {                                 \
>> +             .fallback_reader_refcnt = &name ## _refcnt,             \
>> +             .lglock = { .lock = &name ## _lock } }
>> +
>> +static inline void lg_rwlock_init(struct lgrwlock *lgrw, char *name)
>> +{
>> +     lg_lock_init(&lgrw->lglock, name);
>> +}
>> +
>> +void lg_rwlock_local_read_lock(struct lgrwlock *lgrw);
>> +void lg_rwlock_local_read_unlock(struct lgrwlock *lgrw);
>> +void lg_rwlock_global_write_lock(struct lgrwlock *lgrw);
>> +void lg_rwlock_global_write_unlock(struct lgrwlock *lgrw);
>>  #endif
>> diff --git a/kernel/lglock.c b/kernel/lglock.c
>> index 6535a66..463543a 100644
>> --- a/kernel/lglock.c
>> +++ b/kernel/lglock.c
>> @@ -87,3 +87,48 @@ void lg_global_unlock(struct lglock *lg)
>>       preempt_enable();
>>  }
>>  EXPORT_SYMBOL(lg_global_unlock);
>> +
>> +void lg_rwlock_local_read_lock(struct lgrwlock *lgrw)
>> +{
>> +     struct lglock *lg = &lgrw->lglock;
>> +
>> +     preempt_disable();
>> +     if (likely(!__this_cpu_read(*lgrw->fallback_reader_refcnt))) {
>> +             if (likely(arch_spin_trylock(this_cpu_ptr(lg->lock)))) {
>> +                     rwlock_acquire_read(&lg->lock_dep_map, 0, 0, _RET_IP_);
>> +                     return;
>> +             }
>> +             read_lock(&lgrw->fallback_rwlock);
>> +     }
>> +
>> +     __this_cpu_inc(*lgrw->fallback_reader_refcnt);
>> +}
>> +EXPORT_SYMBOL(lg_rwlock_local_read_lock);
>> +
>> +void lg_rwlock_local_read_unlock(struct lgrwlock *lgrw)
>> +{
>> +     if (likely(!__this_cpu_read(*lgrw->fallback_reader_refcnt))) {
>> +             lg_local_unlock(&lgrw->lglock);
>> +             return;
>> +     }
>> +
>> +     if (!__this_cpu_dec_return(*lgrw->fallback_reader_refcnt))
>> +             read_unlock(&lgrw->fallback_rwlock);
>> +
>> +     preempt_enable();
>> +}
>> +EXPORT_SYMBOL(lg_rwlock_local_read_unlock);
>> +
>
> If I read the code above correctly, all you are doing is implementing a
> recursive reader-side primitive (ie., allowing the reader to call these
> functions recursively, without resulting in a self-deadlock).
>
> But the thing is, making the reader-side recursive is the least of our
> problems! Our main challenge is to make the locking extremely flexible
> and also safe-guard it against circular-locking-dependencies and deadlocks.
> Please take a look at the changelog of patch 1 - it explains the situation
> with an example.
>
>> +void lg_rwlock_global_write_lock(struct lgrwlock *lgrw)
>> +{
>> +     lg_global_lock(&lgrw->lglock);
>
> This does a for-loop on all CPUs and takes their locks one-by-one. That's
> exactly what we want to prevent, because that is the _source_ of all our
> deadlock woes in this case. In the presence of perfect lock ordering
> guarantees, this wouldn't have been a problem (that's why lglocks are
> being used successfully elsewhere in the kernel). In the stop-machine()
> removal case, the over-flexibility of preempt_disable() forces us to provide
> an equally flexible locking alternative. Hence we can't use such per-cpu
> locking schemes.
>
> You might note that, for exactly this reason, I haven't actually used any
> per-cpu _locks_ in this synchronization scheme, though it is named as
> "per-cpu rwlocks". The only per-cpu component here are the refcounts, and
> we consciously avoid waiting/spinning on them (because then that would be
> equivalent to having per-cpu locks, which are deadlock-prone). We use
> global rwlocks to get the deadlock-safety that we need.
>
>> +     write_lock(&lgrw->fallback_rwlock);
>> +}
>> +EXPORT_SYMBOL(lg_rwlock_global_write_lock);
>> +
>> +void lg_rwlock_global_write_unlock(struct lgrwlock *lgrw)
>> +{
>> +     write_unlock(&lgrw->fallback_rwlock);
>> +     lg_global_unlock(&lgrw->lglock);
>> +}
>> +EXPORT_SYMBOL(lg_rwlock_global_write_unlock);
>>
>
> Regards,
> Srivatsa S. Bhat
>
