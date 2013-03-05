From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH V2] lglock: add read-preference local-global rwlock
Date: Tue, 05 Mar 2013 23:25:05 +0530
Message-ID: <51363179.2030109@linux.vnet.ibm.com>
References: <512BBAD8.8010006@linux.vnet.ibm.com> <CACvQF51jCxk5jUqmhD=QBBtUsBkQWZzakacrKO4Gsk=w61rNwQ@mail.gmail.com> <512C7A38.8060906@linux.vnet.ibm.com> <CACvQF51RvhM8XNqu3-1OTQ=cZUZ=pAX+_zx0a29+W67N1X+BgQ@mail.gmail.com> <512CC509.1050000@linux.vnet.ibm.com> <CACvQF50UgiqPpDk3HCmV86zKSf6tPjqr0bZowfPEOJs0g0r0MQ@mail.gmail.com> <512D0D67.9010609@linux.vnet.ibm.com> <CACvQF53ph2ixdM-otzetjM5cR+2kcZj6sckOp3TnzzA_x-EZ8w@mail.gmail.com> <512E7879.20109@linux.vnet.ibm.com>	<5130E8E2.50206@cn.fujitsu.com> <20130301182854.GA3631@redhat.com> <CANN689HEW=b5S93J27p+rBX-5m7jkW4FER=eHDCp7OgMaTWLPw@mail.gmail.com> <5131FB4C.7070408@cn.fujitsu.com> <513232B6.9060905@linux.vnet.ibm.com> <5136123C.3040508@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Michel Lespinasse <walken@google.com>,
	Oleg Nesterov <oleg@redhat.com>,
	Lai Jiangshan <eag0628@gmail.com>, linux-doc@vger.kernel.org,
	peterz@infradead.org, fweisbec@gmail.com,
	linux-kernel@vger.kernel.org, namhyung@kernel.org,
	mingo@kernel.org, linux-arch@vger.kernel.org,
	linux@arm.linux.org.uk, xiaoguangrong@linux.vnet.ibm.com,
	wangyun@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	rusty@rustcorp.com.au, rostedt@goodmis.org, rjw@sisk.pl,
	vincent.guittot@linaro.org, tglx@linutronix.de,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	sbw@mit.edu, tj@kernel.org, akpm@linux-foundation.org,
	linuxppc-dev@lists.ozlabs.org
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <5136123C.3040508@cn.fujitsu.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/05/2013 09:11 PM, Lai Jiangshan wrote:
> On 03/03/13 01:11, Srivatsa S. Bhat wrote:
>> On 03/02/2013 06:44 PM, Lai Jiangshan wrote:
>>> From 345a7a75c314ff567be48983e0892bc69c4452e7 Mon Sep 17 00:00:00 2001
>>> From: Lai Jiangshan <laijs@cn.fujitsu.com>
>>> Date: Sat, 2 Mar 2013 20:33:14 +0800
>>> Subject: [PATCH] lglock: add read-preference local-global rwlock
>>>
>>> Current lglock is not read-preference, so it can't be used on some cases
>>> which read-preference rwlock can do. Example, get_cpu_online_atomic().
>>>
>> [...]
>>> diff --git a/kernel/lglock.c b/kernel/lglock.c
>>> index 6535a66..52e9b2c 100644
>>> --- a/kernel/lglock.c
>>> +++ b/kernel/lglock.c
>>> @@ -87,3 +87,71 @@ void lg_global_unlock(struct lglock *lg)
>>>  	preempt_enable();
>>>  }
>>>  EXPORT_SYMBOL(lg_global_unlock);
>>> +
>>> +#define FALLBACK_BASE	(1UL << 30)
>>> +
>>> +void lg_rwlock_local_read_lock(struct lgrwlock *lgrw)
>>> +{
>>> +	struct lglock *lg = &lgrw->lglock;
>>> +
>>> +	preempt_disable();
>>> +	if (likely(!__this_cpu_read(*lgrw->reader_refcnt))) {
>>> +		rwlock_acquire_read(&lg->lock_dep_map, 0, 0, _RET_IP_);
>>> +		if (unlikely(!arch_spin_trylock(this_cpu_ptr(lg->lock)))) {
>>> +			read_lock(&lgrw->fallback_rwlock);
>>> +			__this_cpu_write(*lgrw->reader_refcnt, FALLBACK_BASE);
>>> +			return;
>>> +		}
>>> +	}
>>> +
>>> +	__this_cpu_inc(*lgrw->reader_refcnt);
>>> +}
>>> +EXPORT_SYMBOL(lg_rwlock_local_read_lock);
>>> +
>>> +void lg_rwlock_local_read_unlock(struct lgrwlock *lgrw)
>>> +{
>>> +	switch (__this_cpu_read(*lgrw->reader_refcnt)) {
>>> +	case 1:
>>> +		__this_cpu_write(*lgrw->reader_refcnt, 0);
>>> +		lg_local_unlock(&lgrw->lglock);
>>> +		return;
>>
>> This should be a break, instead of a return, right?
>> Otherwise, there will be a preempt imbalance...
> 
> 
> "lockdep" and "preempt" are handled in lg_local_unlock(&lgrw->lglock);
> 

Ah, ok.. I had missed that.

Regards,
Srivatsa S. Bhat

