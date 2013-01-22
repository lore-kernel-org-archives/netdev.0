From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 01/45] percpu_rwlock: Introduce the global reader-writer
 lock backend
Date: Wed, 23 Jan 2013 01:11:55 +0530
Message-ID: <50FEEB83.7030804@linux.vnet.ibm.com>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com> <20130122073315.13822.27093.stgit@srivatsabhat.in.ibm.com> <20130122104506.32b4e581@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, rjw@sisk.pl, sbw@mit.edu,
	fweisbec@gmail.com, linux@arm.linux.org.uk,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20130122104506.32b4e581@nehalam.linuxnetplumber.net>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/23/2013 12:15 AM, Stephen Hemminger wrote:
> On Tue, 22 Jan 2013 13:03:22 +0530
> "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com> wrote:
> 
>> A straight-forward (and obvious) algorithm to implement Per-CPU Reader-Writer
>> locks can also lead to too many deadlock possibilities which can make it very
>> hard/impossible to use. This is explained in the example below, which helps
>> justify the need for a different algorithm to implement flexible Per-CPU
>> Reader-Writer locks.
>>
>> We can use global rwlocks as shown below safely, without fear of deadlocks:
>>
>> Readers:
>>
>>          CPU 0                                CPU 1
>>          ------                               ------
>>
>> 1.    spin_lock(&random_lock);             read_lock(&my_rwlock);
>>
>>
>> 2.    read_lock(&my_rwlock);               spin_lock(&random_lock);
>>
>>
>> Writer:
>>
>>          CPU 2:
>>          ------
>>
>>        write_lock(&my_rwlock);
>>
>>
>> We can observe that there is no possibility of deadlocks or circular locking
>> dependencies here. Its perfectly safe.
>>
>> Now consider a blind/straight-forward conversion of global rwlocks to per-CPU
>> rwlocks like this:
>>
>> The reader locks its own per-CPU rwlock for read, and proceeds.
>>
>> Something like: read_lock(per-cpu rwlock of this cpu);
>>
>> The writer acquires all per-CPU rwlocks for write and only then proceeds.
>>
>> Something like:
>>
>>   for_each_online_cpu(cpu)
>> 	write_lock(per-cpu rwlock of 'cpu');
>>
>>
>> Now let's say that for performance reasons, the above scenario (which was
>> perfectly safe when using global rwlocks) was converted to use per-CPU rwlocks.
>>
>>
>>          CPU 0                                CPU 1
>>          ------                               ------
>>
>> 1.    spin_lock(&random_lock);             read_lock(my_rwlock of CPU 1);
>>
>>
>> 2.    read_lock(my_rwlock of CPU 0);       spin_lock(&random_lock);
>>
>>
>> Writer:
>>
>>          CPU 2:
>>          ------
>>
>>       for_each_online_cpu(cpu)
>>         write_lock(my_rwlock of 'cpu');
>>
>>
>> Consider what happens if the writer begins his operation in between steps 1
>> and 2 at the reader side. It becomes evident that we end up in a (previously
>> non-existent) deadlock due to a circular locking dependency between the 3
>> entities, like this:
>>
>>
>> (holds              Waiting for
>>  random_lock) CPU 0 -------------> CPU 2  (holds my_rwlock of CPU 0
>>                                                for write)
>>                ^                   |
>>                |                   |
>>         Waiting|                   | Waiting
>>           for  |                   |  for
>>                |                   V
>>                 ------ CPU 1 <------
>>
>>                 (holds my_rwlock of
>>                  CPU 1 for read)
>>
>>
>>
>> So obviously this "straight-forward" way of implementing percpu rwlocks is
>> deadlock-prone. One simple measure for (or characteristic of) safe percpu
>> rwlock should be that if a user replaces global rwlocks with per-CPU rwlocks
>> (for performance reasons), he shouldn't suddenly end up in numerous deadlock
>> possibilities which never existed before. The replacement should continue to
>> remain safe, and perhaps improve the performance.
>>
>> Observing the robustness of global rwlocks in providing a fair amount of
>> deadlock safety, we implement per-CPU rwlocks as nothing but global rwlocks,
>> as a first step.
>>
>>
>> Cc: David Howells <dhowells@redhat.com>
>> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
> 
> We got rid of brlock years ago, do we have to reintroduce it like this?
> The problem was that brlock caused starvation.
> 

Um? I still see it in include/linux/lglock.h and its users in fs/ directory.

BTW, I'm not advocating that everybody start converting their global reader-writer
locks to per-cpu rwlocks, because such a conversion probably won't make sense
in all scenarios.

The thing is, for CPU hotplug in particular, the "preempt_disable() at the reader;
stop_machine() at the writer" scheme had some very desirable properties at the
reader side (even though people might hate stop_machine() with all their
heart ;-)), namely : 

At the reader side:

o No need to hold locks to prevent CPU offline
o Extremely fast/optimized updates (the preempt count)
o No need for heavy memory barriers
o Extremely flexible nesting rules

So this made perfect sense at the reader for CPU hotplug, because it is expected
that CPU hotplug operations are very infrequent, and it is well-known that quite
a few atomic hotplug readers are in very hot paths. The problem was that the
stop_machine() at the writer was not only a little too heavy, but also inflicted
real-time latencies on the system because it needed cooperation from _all_ CPUs
synchronously, to take one CPU down.

So the idea is to get rid of stop_machine() without hurting the reader side.
And this scheme of per-cpu rwlocks comes close to ensuring that. (You can look
at the previous versions of this patchset [links given in cover letter] to see
what other schemes we hashed out before coming to this one).

The only reason I exposed this as a generic locking scheme was because Tejun
pointed out that, complex locking schemes implemented in individual subsystems
is not such a good idea. And also this comes at a time when per-cpu rwsemaphores
have just been introduced in the kernel and Oleg had ideas about converting the
cpu hotplug (sleepable) locking to use them.

Regards,
Srivatsa S. Bhat
