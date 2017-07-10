From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: [PATCH v2 0/9] Remove spin_unlock_wait()
Date: Mon, 10 Jul 2017 19:22:19 +0200
Message-ID: <fd375869-ca43-b58f-025d-bd1e873e136a@colorfullife.com>
References: <Pine.LNX.4.44L0.1707081157020.17878-100000@netrider.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Peter Zijlstra <peterz@infradead.org>,
        David Laight <David.Laight@ACULAB.COM>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "oleg@redhat.com" <oleg@redhat.com>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "mingo@redhat.com" <mingo@redhat.com>,
        "dave@stgolabs.net" <dave@stgolabs.net>,
        "tj@kernel.org" <tj@kernel.org>, "arnd@arndb.de" <arnd@arndb.de>,
        "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
        "will.deacon@arm.com" <will.deacon@arm.com>,
        "parri.andrea@gmail.com" <parri.andrea@gmail.com>,
        "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
To: Alan Stern <stern@rowland.harvard.edu>,
        Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.44L0.1707081157020.17878-100000@netrider.rowland.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Alan,

On 07/08/2017 06:21 PM, Alan Stern wrote:
> Pardon me for barging in, but I found this whole interchange extremely
> confusing...
>
> On Sat, 8 Jul 2017, Ingo Molnar wrote:
>
>> * Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
>>
>>> On Sat, Jul 08, 2017 at 10:35:43AM +0200, Ingo Molnar wrote:
>>>> * Manfred Spraul <manfred@colorfullife.com> wrote:
>>>>
>>>>> Hi Ingo,
>>>>>
>>>>> On 07/07/2017 10:31 AM, Ingo Molnar wrote:
>>>>>> There's another, probably just as significant advantage: queued_spin_unlock_wait()
>>>>>> is 'read-only', while spin_lock()+spin_unlock() dirties the lock cache line. On
>>>>>> any bigger system this should make a very measurable difference - if
>>>>>> spin_unlock_wait() is ever used in a performance critical code path.
>>>>> At least for ipc/sem:
>>>>> Dirtying the cacheline (in the slow path) allows to remove a smp_mb() in the
>>>>> hot path.
>>>>> So for sem_lock(), I either need a primitive that dirties the cacheline or
>>>>> sem_lock() must continue to use spin_lock()/spin_unlock().
> This statement doesn't seem to make sense.  Did Manfred mean to write
> "smp_mb()" instead of "spin_lock()/spin_unlock()"?
Option 1:
     fastpath:
         spin_lock(local_lock)
         smp_mb(); [[1]]
         smp_load_acquire(global_flag);
     slow path:
         global_flag = 1;
         smp_mb();
         <spin_unlock_wait_without_cacheline_dirtying>

Option 2:
     fastpath:
         spin_lock(local_lock);
         smp_load_acquire(global_flag)
     slow path:
         global_flag = 1;
         spin_lock(local_lock);spin_unlock(local_lock).

Rational:
The ACQUIRE from spin_lock is at the read of local_lock, not at the write.
i.e.: Without the smp_mb() at [[1]], the CPU can do:
         read local_lock;
         read global_flag;
         write local_lock;
For Option 2, the smp_mb() is not required, because fast path and slow 
path acquire the same lock.

>>>> Technically you could use spin_trylock()+spin_unlock() and avoid the lock acquire
>>>> spinning on spin_unlock() and get very close to the slow path performance of a
>>>> pure cacheline-dirtying behavior.
> This is even more confusing.  Did Ingo mean to suggest using
> "spin_trylock()+spin_unlock()" in place of "spin_lock()+spin_unlock()"
> could provide the desired ordering guarantee without delaying other
> CPUs that may try to acquire the lock?  That seems highly questionable.
I agree :-)

--
     Manfred
