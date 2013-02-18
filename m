From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 08/46] CPU hotplug: Provide APIs to prevent CPU offline
 from atomic context
Date: Mon, 18 Feb 2013 22:13:34 +0530
Message-ID: <51225A36.40600@linux.vnet.ibm.com>
References: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com> <20130218123920.26245.56709.stgit@srivatsabhat.in.ibm.com> <CANN689HhVxDv+3Bn9UAxOMzj0egTvVp_c7oAmQ2nnQ8Xjn_aMA@mail.gmail.com>
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
In-Reply-To: <CANN689HhVxDv+3Bn9UAxOMzj0egTvVp_c7oAmQ2nnQ8Xjn_aMA@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/18/2013 09:53 PM, Michel Lespinasse wrote:
> On Mon, Feb 18, 2013 at 8:39 PM, Srivatsa S. Bhat
> <srivatsa.bhat@linux.vnet.ibm.com> wrote:
>> Some important design requirements and considerations:
>> -----------------------------------------------------
[...]
>> +/*
>> + * Invoked by atomic hotplug reader (a task which wants to prevent
>> + * CPU offline, but which can't afford to sleep), to prevent CPUs from
>> + * going offline. So, you can call this function from atomic contexts
>> + * (including interrupt handlers).
>> + *
>> + * Note: This does NOT prevent CPUs from coming online! It only prevents
>> + * CPUs from going offline.
>> + *
>> + * You can call this function recursively.
>> + *
>> + * Returns with preemption disabled (but interrupts remain as they are;
>> + * they are not disabled).
>> + */
>> +void get_online_cpus_atomic(void)
>> +{
>> +       percpu_read_lock_irqsafe(&hotplug_pcpu_rwlock);
>> +}
>> +EXPORT_SYMBOL_GPL(get_online_cpus_atomic);
>> +
>> +void put_online_cpus_atomic(void)
>> +{
>> +       percpu_read_unlock_irqsafe(&hotplug_pcpu_rwlock);
>> +}
>> +EXPORT_SYMBOL_GPL(put_online_cpus_atomic);
> 
> So, you made it clear why you want a recursive read side here.
> 
> I am wondering though, if you could take care of recursive uses in
> get/put_online_cpus_atomic() instead of doing it as a property of your
> rwlock:
> 
> get_online_cpus_atomic()
> {
>     unsigned long flags;
>     local_irq_save(flags);
>     if (this_cpu_inc_return(hotplug_recusion_count) == 1)
>         percpu_read_lock_irqsafe(&hotplug_pcpu_rwlock);
>     local_irq_restore(flags);
> }
> 
> Once again, the idea there is to avoid baking the reader side
> recursive properties into your rwlock itself, so that it won't be
> impossible to implement reader/writer fairness into your rwlock in the
> future (which may be not be very important for the hotplug use, but
> could be when other uses get introduced).
> 

Hmm, your proposal above looks good to me, at first glance.
(Sorry, I had mistaken your earlier mails to mean that you were against
recursive reader-side, while you actually meant that you didn't like
implementing the recursive reader-side logic using the recursive property
of rwlocks).

While your idea above looks good, it might introduce more complexity
in the unlock path, since this would allow nesting of heterogeneous readers
(ie., if hotplug_recursion_count == 1, you don't know whether you need to
simply decrement the counter or unlock the rwlock as well).

But I'll give this some more thought to see if we can implement this
without making it too complex. Thank you!

Regards,
Srivatsa S. Bhat

