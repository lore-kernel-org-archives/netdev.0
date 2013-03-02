From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: Re: [PATCH] lglock: add read-preference local-global rwlock
Date: Sat, 02 Mar 2013 21:42:15 +0800
Message-ID: <513201B7.5070004@cn.fujitsu.com>
References: <512BBAD8.8010006@linux.vnet.ibm.com> <CACvQF51jCxk5jUqmhD=QBBtUsBkQWZzakacrKO4Gsk=w61rNwQ@mail.gmail.com> <512C7A38.8060906@linux.vnet.ibm.com> <CACvQF51RvhM8XNqu3-1OTQ=cZUZ=pAX+_zx0a29+W67N1X+BgQ@mail.gmail.com> <512CC509.1050000@linux.vnet.ibm.com> <CACvQF50UgiqPpDk3HCmV86zKSf6tPjqr0bZowfPEOJs0g0r0MQ@mail.gmail.com> <512D0D67.9010609@linux.vnet.ibm.com> <CACvQF53ph2ixdM-otzetjM5cR+2kcZj6sckOp3TnzzA_x-EZ8w@mail.gmail.com> <512E7879.20109@linux.vnet.ibm.com> <5130E8E2.50206@cn.fujitsu.com> <20130301182854.GA3631@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
	Lai Jiangshan <eag0628@gmail.com>,
	Michel Lespinasse <walken@google.com>,
	linux-doc@vger.kernel.org, peterz@infradead.org,
	fweisbec@gmail.com, linux-kernel@vger.kernel.org,
	namhyung@kernel.org, mingo@kernel.org, linux-arch@vger.kernel.org,
	linux@arm.linux.org.uk, xiaoguangrong@linux.vnet.ibm.com,
	wangyun@linux.vnet.ibm.com, nikunj@linux.vnet.ibm.com,
	linux-pm@vger.kernel.org, rusty@rustcorp.com.au,
	rostedt@goodmis.org, rjw@sisk.pl, vincent.guittot@linaro.org,
	tglx@linutronix.de, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, sbw@mit.edu, tj@kernel.org,
	akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org
To: Oleg Nesterov <oleg@redhat.com>, paulmck@linux.vnet.ibm.com
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20130301182854.GA3631@redhat.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/03/13 02:28, Oleg Nesterov wrote:
> Lai, I didn't read this discussion except the code posted by Michel.
> I'll try to read this patch carefully later, but I'd like to ask
> a couple of questions.
> 
> This version looks more complex than Michel's, why? Just curious, I
> am trying to understand what I missed. See
> http://marc.info/?l=linux-kernel&m=136196350213593

Michel changed my old draft version a little, his version is good enough for me.
My new version tries to add a little better nestable support with only
adding single __this_cpu_op() in _read_[un]lock().

> 
> And I can't understand FALLBACK_BASE...
> 
> OK, suppose that CPU_0 does _write_unlock() and releases ->fallback_rwlock.
> 
> CPU_1 does _read_lock(), and ...
> 
>> +void lg_rwlock_local_read_lock(struct lgrwlock *lgrw)
>> +{
>> +	struct lglock *lg = &lgrw->lglock;
>> +
>> +	preempt_disable();
>> +	rwlock_acquire_read(&lg->lock_dep_map, 0, 0, _RET_IP_);
>> +	if (likely(!__this_cpu_read(*lgrw->reader_refcnt))) {
>> +		if (!arch_spin_trylock(this_cpu_ptr(lg->lock))) {
> 
> _trylock() fails,
> 
>> +			read_lock(&lgrw->fallback_rwlock);
>> +			__this_cpu_add(*lgrw->reader_refcnt, FALLBACK_BASE);
> 
> so we take ->fallback_rwlock and ->reader_refcnt == FALLBACK_BASE.
> 
> CPU_0 does lg_global_unlock(lgrw->lglock) and finishes _write_unlock().
> 
> Interrupt handler on CPU_1 does _read_lock() notices ->reader_refcnt != 0
> and simply does this_cpu_inc(), so reader_refcnt == FALLBACK_BASE + 1.
> 
> Then irq does _read_unlock(), and
> 
>> +void lg_rwlock_local_read_unlock(struct lgrwlock *lgrw)
>> +{
>> +	switch (__this_cpu_dec_return(*lgrw->reader_refcnt)) {
>> +	case 0:
>> +		lg_local_unlock(&lgrw->lglock);
>> +		return;
>> +	case FALLBACK_BASE:
>> +		__this_cpu_sub(*lgrw->reader_refcnt, FALLBACK_BASE);
>> +		read_unlock(&lgrw->fallback_rwlock);
> 
> hits this case?
> 
> Doesn't look right, but most probably I missed something.

Your are right, I just realized that I had spit a code which should be atomic.

I hope this patch(V2) can get more reviews.

My first and many locking knowledge is learned from Paul.
Paul, would you also review it?

Thanks,
Lai

> 
> Oleg.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

