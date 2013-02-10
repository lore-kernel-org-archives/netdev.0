From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 04/45] percpu_rwlock: Implement the core design of
 Per-CPU Reader-Writer Locks
Date: Mon, 11 Feb 2013 00:08:36 +0530
Message-ID: <5117E92C.3050207@linux.vnet.ibm.com>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com> <20130122073347.13822.85876.stgit@srivatsabhat.in.ibm.com> <20130123185522.GG2373@mtj.dyndns.org> <51003B20.2060506@linux.vnet.ibm.com> <20130123195740.GI2373@mtj.dyndns.org> <5100B8CC.4080406@linux.vnet.ibm.com> <87ip6gutsq.fsf@sejong.aot.lge.com> <20130208224742.GJ2666@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Namhyung Kim <namhyung@kernel.org>, Tejun Heo <tj@kernel.org>,
	tglx@linutronix.de, peterz@infradead.org, oleg@redhat.com,
	rusty@rustcorp.com.au, mingo@kernel.org, akpm@linux-foundation.org,
	rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, rjw@sisk.pl, sbw@mit.edu,
	fweisbec@gmail.com, linux@arm.linux.org.uk,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	walken@google.com
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20130208224742.GJ2666@linux.vnet.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/09/2013 04:17 AM, Paul E. McKenney wrote:
> On Tue, Jan 29, 2013 at 08:12:37PM +0900, Namhyung Kim wrote:
>> On Thu, 24 Jan 2013 10:00:04 +0530, Srivatsa S. Bhat wrote:
>>> On 01/24/2013 01:27 AM, Tejun Heo wrote:
>>>> On Thu, Jan 24, 2013 at 01:03:52AM +0530, Srivatsa S. Bhat wrote:
>>>>> CPU 0                          CPU 1
>>>>>
>>>>> read_lock(&rwlock)
>>>>>
>>>>>                               write_lock(&rwlock) //spins, because CPU 0
>>>>>                               //has acquired the lock for read
>>>>>
>>>>> read_lock(&rwlock)
>>>>>    ^^^^^
>>>>> What happens here? Does CPU 0 start spinning (and hence deadlock) or will
>>>>> it continue realizing that it already holds the rwlock for read?
>>>>
>>>> I don't think rwlock allows nesting write lock inside read lock.
>>>> read_lock(); write_lock() will always deadlock.
>>>>
>>>
>>> Sure, I understand that :-) My question was, what happens when *two* CPUs
>>> are involved, as in, the read_lock() is invoked only on CPU 0 whereas the
>>> write_lock() is invoked on CPU 1.
>>>
>>> For example, the same scenario shown above, but with slightly different
>>> timing, will NOT result in a deadlock:
>>>
>>> Scenario 2:
>>>   CPU 0                                CPU 1
>>>
>>> read_lock(&rwlock)
>>>
>>>
>>> read_lock(&rwlock) //doesn't spin
>>>
>>>                                     write_lock(&rwlock) //spins, because CPU 0
>>>                                     //has acquired the lock for read
>>>
>>>
>>> So I was wondering whether the "fairness" logic of rwlocks would cause
>>> the second read_lock() to spin (in the first scenario shown above) because
>>> a writer is already waiting (and hence new readers should spin) and thus
>>> cause a deadlock.
>>
>> In my understanding, current x86 rwlock does basically this (of course,
>> in an atomic fashion):
>>
>>
>> #define RW_LOCK_BIAS 0x10000
>>
>> rwlock_init(rwlock)
>> {
>> 	rwlock->lock = RW_LOCK_BIAS;
>> }
>>
>> arch_read_lock(rwlock)
>> {
>> retry:
>> 	if (--rwlock->lock >= 0)
>> 		return;
>>
>>         rwlock->lock++;
>>         while (rwlock->lock < 1)
>>         	continue;
>>
>>         goto retry;
>> }
>>
>> arch_write_lock(rwlock)
>> {
>> retry:
>> 	if ((rwlock->lock -= RW_LOCK_BIAS) == 0)
>>         	return;
>>
>>         rwlock->lock += RW_LOCK_BIAS;
>> 	while (rwlock->lock != RW_LOCK_BIAS)
>> 		continue;
>>
>>         goto retry;
>> }
>>
>>
>> So I can't find where the 'fairness' logic comes from..
> 
> I looked through several of the rwlock implementations, and in all of
> them the writer backs off if it sees readers -- or refrains from asserting
> ownership of the lock to begin with.
> 
> So it should be OK to use rwlock as shown in the underlying patch.
> 

Thanks a lot for confirming that Paul! So I guess we can use rwlocks
as it is, since its behaviour suits our needs perfectly. So I won't tinker
with atomic counters for a while, atleast not until someone starts making
rwlocks fair.. ;-)

Regards,
Srivatsa S. Bhat
