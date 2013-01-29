From: Namhyung Kim <namhyung@kernel.org>
Subject: Re: [PATCH v5 04/45] percpu_rwlock: Implement the core design of Per-CPU Reader-Writer Locks
Date: Tue, 29 Jan 2013 20:12:37 +0900
Message-ID: <87ip6gutsq.fsf@sejong.aot.lge.com>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
	<20130122073347.13822.85876.stgit@srivatsabhat.in.ibm.com>
	<20130123185522.GG2373@mtj.dyndns.org>
	<51003B20.2060506@linux.vnet.ibm.com>
	<20130123195740.GI2373@mtj.dyndns.org>
	<5100B8CC.4080406@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tejun Heo <tj@kernel.org>, tglx@linutronix.de,
	peterz@infradead.org, oleg@redhat.com, paulmck@linux.vnet.ibm.com,
	rusty@rustcorp.com.au, mingo@kernel.org, akpm@linux-foundation.org,
	rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, rjw@sisk.pl, sbw@mit.edu,
	fweisbec@gmail.com, linux@arm.linux.org.uk,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	walken@google.com
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from LGEMRELSE7Q.lge.com ([156.147.1.151]:60701 "EHLO
	LGEMRELSE7Q.lge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751720Ab3A2LMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 06:12:40 -0500
In-Reply-To: <5100B8CC.4080406@linux.vnet.ibm.com> (Srivatsa S. Bhat's message
	of "Thu, 24 Jan 2013 10:00:04 +0530")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Jan 2013 10:00:04 +0530, Srivatsa S. Bhat wrote:
> On 01/24/2013 01:27 AM, Tejun Heo wrote:
>> On Thu, Jan 24, 2013 at 01:03:52AM +0530, Srivatsa S. Bhat wrote:
>>> CPU 0                          CPU 1
>>>
>>> read_lock(&rwlock)
>>>
>>>                               write_lock(&rwlock) //spins, because CPU 0
>>>                               //has acquired the lock for read
>>>
>>> read_lock(&rwlock)
>>>    ^^^^^
>>> What happens here? Does CPU 0 start spinning (and hence deadlock) or will
>>> it continue realizing that it already holds the rwlock for read?
>> 
>> I don't think rwlock allows nesting write lock inside read lock.
>> read_lock(); write_lock() will always deadlock.
>> 
>
> Sure, I understand that :-) My question was, what happens when *two* CPUs
> are involved, as in, the read_lock() is invoked only on CPU 0 whereas the
> write_lock() is invoked on CPU 1.
>
> For example, the same scenario shown above, but with slightly different
> timing, will NOT result in a deadlock:
>
> Scenario 2:
>   CPU 0                                CPU 1
>
> read_lock(&rwlock)
>
>
> read_lock(&rwlock) //doesn't spin
>
>                                     write_lock(&rwlock) //spins, because CPU 0
>                                     //has acquired the lock for read
>
>
> So I was wondering whether the "fairness" logic of rwlocks would cause
> the second read_lock() to spin (in the first scenario shown above) because
> a writer is already waiting (and hence new readers should spin) and thus
> cause a deadlock.

In my understanding, current x86 rwlock does basically this (of course,
in an atomic fashion):


#define RW_LOCK_BIAS 0x10000

rwlock_init(rwlock)
{
	rwlock->lock = RW_LOCK_BIAS;
}

arch_read_lock(rwlock)
{
retry:
	if (--rwlock->lock >= 0)
		return;

        rwlock->lock++;
        while (rwlock->lock < 1)
        	continue;

        goto retry;
}

arch_write_lock(rwlock)
{
retry:
	if ((rwlock->lock -= RW_LOCK_BIAS) == 0)
        	return;

        rwlock->lock += RW_LOCK_BIAS;
	while (rwlock->lock != RW_LOCK_BIAS)
		continue;

        goto retry;
}


So I can't find where the 'fairness' logic comes from..

Thanks,
Namhyung
