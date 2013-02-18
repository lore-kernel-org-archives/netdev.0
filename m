From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 04/46] percpu_rwlock: Implement the core design of
 Per-CPU Reader-Writer Locks
Date: Mon, 18 Feb 2013 21:51:50 +0530
Message-ID: <5122551E.1080703@linux.vnet.ibm.com>
References: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com> <20130218123856.26245.46705.stgit@srivatsabhat.in.ibm.com> <CANN689F9S7c1M8+cEpz3tsxGF34+NTRBLvxgPUOtbvav5u+RRA@mail.gmail.com>
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
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	vincent.guittot@linaro.org
To: Michel Lespinasse <walken@google.com>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <CANN689F9S7c1M8+cEpz3tsxGF34+NTRBLvxgPUOtbvav5u+RRA@mail.gmail.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Michel,

On 02/18/2013 09:15 PM, Michel Lespinasse wrote:
> Hi Srivasta,
> 
> I admit not having followed in detail the threads about the previous
> iteration, so some of my comments may have been discussed already
> before - apologies if that is the case.
> 
> On Mon, Feb 18, 2013 at 8:38 PM, Srivatsa S. Bhat
> <srivatsa.bhat@linux.vnet.ibm.com> wrote:
>> Reader-writer locks and per-cpu counters are recursive, so they can be
>> used in a nested fashion in the reader-path, which makes per-CPU rwlocks also
>> recursive. Also, this design of switching the synchronization scheme ensures
>> that you can safely nest and use these locks in a very flexible manner.
> 
> I like the general idea of switching between per-cpu and global
> rwlocks as needed; however I dislike unfair locks, and especially
> unfair recursive rwlocks.
> 
> If you look at rwlock_t, the main reason we haven't been able to
> implement reader/writer fairness there is because tasklist_lock makes
> use of the recursive nature of the rwlock_t read side. I'm worried
> about introducing more lock usages that would make use of the same
> property for your proposed lock.
> 
> I am fine with your proposal not implementing reader/writer fairness
> from day 1, but I am worried about your proposal having a recursive
> reader side. Or, to put it another way: if your proposal didn't have a
> recursive reader side, and rwlock_t could somehow be changed to
> implement reader/writer fairness, then this property could
> automatically propagate into your proposed rwlock; but if anyone makes
> use of the recursive nature of your proposal then implementing
> reader/writer fairness later won't be as easy.
>

Actually, we don't want reader/writer fairness in this particular case.
We want deadlock safety - and in this particular case, this is guaranteed
by the unfair nature of rwlocks today.

I understand that you want to make rwlocks fair. So, I am thinking of
going ahead with Tejun's proposal - implementing our own unfair locking
scheme inside percpu-rwlocks using atomic ops or something like that, and
being completely independent of rwlock_t. That way, you can easily go
ahead with making rwlocks fair without fear of breaking CPU hotplug.
However I would much prefer making that change to percpu-rwlocks as a
separate patchset, after this patchset goes in, so that we can also see
how well this unfair logic performs in practice.

And regarding recursive reader side,... the way I see it, having a
recursive reader side is a primary requirement in this case. The reason is
that the existing reader side (with stop_machine) uses preempt_disable(),
which is recursive. So our replacement also has to be recursive.
 
> I see that the very next change in this series is talking about
> acquiring the read side from interrupts, so it does look like you're
> planning to make use of the recursive nature of the read side.

Yes.. I don't think we can avoid that. Moreover, since we _want_ unfair
reader/writer semantics to allow flexible locking rules and guarantee
deadlock-safety, having a recursive reader side is not even an issue, IMHO.

> I kinda
> wish you didn't, as this is exactly replicating the design of
> tasklist_lock which is IMO problematic. Your prior proposal of
> disabling interrupts during the read side had other disadvantages, but
> I think it was nice that it didn't rely on having a recursive read
> side.
> 

We can have readers from non-interrupt contexts too, which depend on the
recursive property...

>> +#define reader_yet_to_switch(pcpu_rwlock, cpu)                             \
>> +       (ACCESS_ONCE(per_cpu_ptr((pcpu_rwlock)->rw_state, cpu)->reader_refcnt))
>> +
>> +#define reader_percpu_nesting_depth(pcpu_rwlock)                 \
>> +       (__this_cpu_read((pcpu_rwlock)->rw_state->reader_refcnt))
>> +
>> +#define reader_uses_percpu_refcnt(pcpu_rwlock)                         \
>> +                               reader_percpu_nesting_depth(pcpu_rwlock)
>> +
>> +#define reader_nested_percpu(pcpu_rwlock)                              \
>> +                       (reader_percpu_nesting_depth(pcpu_rwlock) > 1)
>> +
>> +#define writer_active(pcpu_rwlock)                                     \
>> +       (__this_cpu_read((pcpu_rwlock)->rw_state->writer_signal))
> 
> I'm personally not a fan of such one-line shorthand functions - I
> think they tend to make the code harder to read instead of easier, as
> one constantly has to refer to them to understand what's actually
> going on.
> 

I got rid of most of the helper functions in this version. But I would rather
prefer retaining the above ones, because they are unwieldy and long. And IMHO
the short-hand names are pretty descriptive, so you might not actually need
to keep referring to their implementations all the time.

>>  void percpu_write_lock(struct percpu_rwlock *pcpu_rwlock)
>>  {
>> +       unsigned int cpu;
>> +
>> +       /*
>> +        * Tell all readers that a writer is becoming active, so that they
>> +        * start switching over to the global rwlock.
>> +        */
>> +       for_each_possible_cpu(cpu)
>> +               per_cpu_ptr(pcpu_rwlock->rw_state, cpu)->writer_signal = true;
> 
> I don't see anything preventing a race with the corresponding code in
> percpu_write_unlock() that sets writer_signal back to false. Did I
> miss something here ? It seems to me we don't have any guarantee that
> all writer signals will be set to true at the end of the loop...
> 

Ah, thanks for pointing that out! IIRC Oleg had pointed this issue in the last
version, but back then, I hadn't fully understood what he meant. Your
explanation made it clear. I'll work on fixing this.

Thanks a lot for your review Michel!

Regards,
Srivatsa S. Bhat

