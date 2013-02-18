From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 08/46] CPU hotplug: Provide APIs to prevent CPU offline
 from atomic context
Date: Tue, 19 Feb 2013 00:20:56 +0530
Message-ID: <51227810.6090009@linux.vnet.ibm.com>
References: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com> <20130218123920.26245.56709.stgit@srivatsabhat.in.ibm.com> <CANN689HhVxDv+3Bn9UAxOMzj0egTvVp_c7oAmQ2nnQ8Xjn_aMA@mail.gmail.com> <51225A36.40600@linux.vnet.ibm.com> <CANN689FJPLfz06MFRJ9T+BuToejAzjYP_yrw_H4iGi1Kb3p2-g@mail.gmail.com>
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
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CANN689FJPLfz06MFRJ9T+BuToejAzjYP_yrw_H4iGi1Kb3p2-g@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/18/2013 10:51 PM, Michel Lespinasse wrote:
> On Tue, Feb 19, 2013 at 12:43 AM, Srivatsa S. Bhat
> <srivatsa.bhat@linux.vnet.ibm.com> wrote:
>> On 02/18/2013 09:53 PM, Michel Lespinasse wrote:
>>> I am wondering though, if you could take care of recursive uses in
>>> get/put_online_cpus_atomic() instead of doing it as a property of your
>>> rwlock:
>>>
>>> get_online_cpus_atomic()
>>> {
>>>     unsigned long flags;
>>>     local_irq_save(flags);
>>>     if (this_cpu_inc_return(hotplug_recusion_count) == 1)
>>>         percpu_read_lock_irqsafe(&hotplug_pcpu_rwlock);
>>>     local_irq_restore(flags);
>>> }
>>>
>>> Once again, the idea there is to avoid baking the reader side
>>> recursive properties into your rwlock itself, so that it won't be
>>> impossible to implement reader/writer fairness into your rwlock in the
>>> future (which may be not be very important for the hotplug use, but
>>> could be when other uses get introduced).
>>
>> Hmm, your proposal above looks good to me, at first glance.
>> (Sorry, I had mistaken your earlier mails to mean that you were against
>> recursive reader-side, while you actually meant that you didn't like
>> implementing the recursive reader-side logic using the recursive property
>> of rwlocks).
> 
> To be honest, I was replying as I went through the series, so I hadn't
> digested your hotplug use case yet :)
> 
> But yes - I don't like having the rwlock itself be recursive, but I do
> understand that you have a legitimate requirement for
> get_online_cpus_atomic() to be recursive. This IMO points to the
> direction I suggested, of explicitly handling the recusion in
> get_online_cpus_atomic() so that the underlying rwlock doesn't have to
> support recursive reader side itself.
> 
> (And this would work for the idea of making writers own the reader
> side as well - you can do it with the hotplug_recursion_count instead
> of with the underlying rwlock).
> 
>> While your idea above looks good, it might introduce more complexity
>> in the unlock path, since this would allow nesting of heterogeneous readers
>> (ie., if hotplug_recursion_count == 1, you don't know whether you need to
>> simply decrement the counter or unlock the rwlock as well).
> 
> Well, I think the idea doesn't make the underlying rwlock more
> complex, since you could in principle keep your existing
> percpu_read_lock_irqsafe implementation as is and just remove the
> recursive behavior from its documentation.
> 
> Now ideally if we're adding a bit of complexity in
> get_online_cpus_atomic() it'd be nice if we could remove some from
> percpu_read_lock_irqsafe, but I haven't thought about that deeply
> either. I think you'd still want to have the equivalent of a percpu
> reader_refcnt, except it could now be a bool instead of an int, and
> percpu_read_lock_irqsafe would still set it to back to 0/false after
> acquiring the global read side if a writer is signaled. Basically your
> existing percpu_read_lock_irqsafe code should still work, and we could
> remove just the parts that were only there to deal with the recursive
> property.
> 

But, the whole intention behind removing the parts depending on the
recursive property of rwlocks would be to make it easier to make rwlocks
fair (going forward) right? Then, that won't work for CPU hotplug, because,
just like we have a legitimate reason to have recursive
get_online_cpus_atomic(), we also have a legitimate reason to have
unfairness in locking (i.e., for deadlock-safety). So we simply can't
afford to make the locking fair - we'll end up in too many deadlock
possibilities, as hinted in the changelog of patch 1.

(Remember, we are replacing preempt_disable(), which had absolutely no
special nesting rules or locking implications. That is why we are forced
to provide maximum locking flexibility and safety against new/previously
non-existent deadlocks, in the new synchronization scheme).

So the only long-term solution I can think of is to decouple
percpu-rwlocks and rwlock_t (like what Tejun suggested) by implementing
our own unfair locking scheme inside. What do you think?

Regards,
Srivatsa S. Bhat

