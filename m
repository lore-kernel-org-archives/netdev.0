From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 09/45] smp, cpu hotplug: Fix smp_call_function_*()
 to prevent CPU offline properly
Date: Mon, 11 Feb 2013 01:11:29 +0530
Message-ID: <5117F7E9.7070906@linux.vnet.ibm.com>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com> <20130122073508.13822.12784.stgit@srivatsabhat.in.ibm.com> <20130209000717.GP2666@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, rusty@rustcorp.com.au, mingo@kernel.org,
	akpm@linux-foundation.org, namhyung@kernel.org,
	rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, rjw@sisk.pl, sbw@mit.edu,
	fweisbec@gmail.com, linux@arm.linux.org.uk,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20130209000717.GP2666@linux.vnet.ibm.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/09/2013 05:37 AM, Paul E. McKenney wrote:
> On Tue, Jan 22, 2013 at 01:05:10PM +0530, Srivatsa S. Bhat wrote:
>> Once stop_machine() is gone from the CPU offline path, we won't be able to
>> depend on preempt_disable() to prevent CPUs from going offline from under us.
>>
>> Use the get/put_online_cpus_atomic() APIs to prevent CPUs from going offline,
>> while invoking from atomic context.
>>
>> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
> 
> Would it make sense for get_online_cpus_atomic() to return the current
> CPU number?

Hmm, I'm not so sure. I tried to model it after get_online_cpus(), which doesn't
return anything (for other reasons, of course..)

Moreover, a function name like *_cpu_* returning the CPU number would be intuitive.
But a name such as *_cpus_* (plural) returning a CPU number might appear confusing..

And also I don't think it'll make a huge improvement in the callers.. (We might
be better off avoiding an smp_processor_id() if possible, since this function could
be called in very hot paths).. So I don't see a strong case for returning the
CPU number. But let me know if you think it'll still be worth it for some reason...

>  Looks good otherwise.
> 

Thank you very much for the detailed review, Paul!

Regards,
Srivatsa S. Bhat

> 
>> ---
>>
>>  kernel/smp.c |   40 ++++++++++++++++++++++++++--------------
>>  1 file changed, 26 insertions(+), 14 deletions(-)
>>
>> diff --git a/kernel/smp.c b/kernel/smp.c
>> index 29dd40a..f421bcc 100644
>> --- a/kernel/smp.c
>> +++ b/kernel/smp.c
>> @@ -310,7 +310,8 @@ int smp_call_function_single(int cpu, smp_call_func_t func, void *info,
>>  	 * prevent preemption and reschedule on another processor,
>>  	 * as well as CPU removal
>>  	 */
>> -	this_cpu = get_cpu();
>> +	get_online_cpus_atomic();
>> +	this_cpu = smp_processor_id();
>>
>>  	/*
>>  	 * Can deadlock when called with interrupts disabled.
>> @@ -342,7 +343,7 @@ int smp_call_function_single(int cpu, smp_call_func_t func, void *info,
>>  		}
>>  	}
>>
>> -	put_cpu();
>> +	put_online_cpus_atomic();
>>
>>  	return err;
>>  }
>> @@ -371,8 +372,10 @@ int smp_call_function_any(const struct cpumask *mask,
>>  	const struct cpumask *nodemask;
>>  	int ret;
>>
>> +	get_online_cpus_atomic();
>>  	/* Try for same CPU (cheapest) */
>> -	cpu = get_cpu();
>> +	cpu = smp_processor_id();
>> +
>>  	if (cpumask_test_cpu(cpu, mask))
>>  		goto call;
>>
>> @@ -388,7 +391,7 @@ int smp_call_function_any(const struct cpumask *mask,
>>  	cpu = cpumask_any_and(mask, cpu_online_mask);
>>  call:
>>  	ret = smp_call_function_single(cpu, func, info, wait);
>> -	put_cpu();
>> +	put_online_cpus_atomic();
>>  	return ret;
>>  }
>>  EXPORT_SYMBOL_GPL(smp_call_function_any);
>> @@ -409,25 +412,28 @@ void __smp_call_function_single(int cpu, struct call_single_data *data,
>>  	unsigned int this_cpu;
>>  	unsigned long flags;
>>
>> -	this_cpu = get_cpu();
>> +	get_online_cpus_atomic();
>> +
>> +	this_cpu = smp_processor_id();
>> +
>>  	/*
>>  	 * Can deadlock when called with interrupts disabled.
>>  	 * We allow cpu's that are not yet online though, as no one else can
>>  	 * send smp call function interrupt to this cpu and as such deadlocks
>>  	 * can't happen.
>>  	 */
>> -	WARN_ON_ONCE(cpu_online(smp_processor_id()) && wait && irqs_disabled()
>> +	WARN_ON_ONCE(cpu_online(this_cpu) && wait && irqs_disabled()
>>  		     && !oops_in_progress);
>>
>>  	if (cpu == this_cpu) {
>>  		local_irq_save(flags);
>>  		data->func(data->info);
>>  		local_irq_restore(flags);
>> -	} else {
>> +	} else if ((unsigned)cpu < nr_cpu_ids && cpu_online(cpu)) {
>>  		csd_lock(data);
>>  		generic_exec_single(cpu, data, wait);
>>  	}
>> -	put_cpu();
>> +	put_online_cpus_atomic();
>>  }
>>
>>  /**
>> @@ -451,6 +457,8 @@ void smp_call_function_many(const struct cpumask *mask,
>>  	unsigned long flags;
>>  	int refs, cpu, next_cpu, this_cpu = smp_processor_id();
>>
>> +	get_online_cpus_atomic();
>> +
>>  	/*
>>  	 * Can deadlock when called with interrupts disabled.
>>  	 * We allow cpu's that are not yet online though, as no one else can
>> @@ -467,17 +475,18 @@ void smp_call_function_many(const struct cpumask *mask,
>>
>>  	/* No online cpus?  We're done. */
>>  	if (cpu >= nr_cpu_ids)
>> -		return;
>> +		goto out_unlock;
>>
>>  	/* Do we have another CPU which isn't us? */
>>  	next_cpu = cpumask_next_and(cpu, mask, cpu_online_mask);
>>  	if (next_cpu == this_cpu)
>> -		next_cpu = cpumask_next_and(next_cpu, mask, cpu_online_mask);
>> +		next_cpu = cpumask_next_and(next_cpu, mask,
>> +						cpu_online_mask);
>>
>>  	/* Fastpath: do that cpu by itself. */
>>  	if (next_cpu >= nr_cpu_ids) {
>>  		smp_call_function_single(cpu, func, info, wait);
>> -		return;
>> +		goto out_unlock;
>>  	}
>>
>>  	data = &__get_cpu_var(cfd_data);
>> @@ -523,7 +532,7 @@ void smp_call_function_many(const struct cpumask *mask,
>>  	/* Some callers race with other cpus changing the passed mask */
>>  	if (unlikely(!refs)) {
>>  		csd_unlock(&data->csd);
>> -		return;
>> +		goto out_unlock;
>>  	}
>>
>>  	raw_spin_lock_irqsave(&call_function.lock, flags);
>> @@ -554,6 +563,9 @@ void smp_call_function_many(const struct cpumask *mask,
>>  	/* Optionally wait for the CPUs to complete */
>>  	if (wait)
>>  		csd_lock_wait(&data->csd);
>> +
>> +out_unlock:
>> +	put_online_cpus_atomic();
>>  }
>>  EXPORT_SYMBOL(smp_call_function_many);
>>
>> @@ -574,9 +586,9 @@ EXPORT_SYMBOL(smp_call_function_many);
>>   */
>>  int smp_call_function(smp_call_func_t func, void *info, int wait)
>>  {
>> -	preempt_disable();
>> +	get_online_cpus_atomic();
>>  	smp_call_function_many(cpu_online_mask, func, info, wait);
>> -	preempt_enable();
>> +	put_online_cpus_atomic();
>>
>>  	return 0;
>>  }
>>

