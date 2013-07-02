From: Michael Wang <wangyun@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 10/45] smp: Use get/put_online_cpus_atomic() to prevent
 CPU offline
Date: Tue, 02 Jul 2013 16:47:24 +0800
Message-ID: <51D2939C.5090205@linux.vnet.ibm.com>
References: <20130627195136.29830.10445.stgit@srivatsabhat.in.ibm.com> <20130627195418.29830.34958.stgit@srivatsabhat.in.ibm.com> <51D2660A.8000401@linux.vnet.ibm.com> <51D28E69.9060205@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	walken@google.com, vincent.guittot@linaro.org,
	laijs@cn.fujitsu.com, David.Laight@aculab.com, rostedt@goodmis.org,
	xiaoguangrong@linux.vnet.ibm.com, sbw@mit.edu, fweisbec@gmail.com,
	zhong@linux.vnet.ibm.com, nikunj@linux.vnet.ibm.com,
	linux-pm@vger.kernel.org, linux-arch@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Wang YanQing <udknight@gmail.com>,
	Shaohua Li <shli@fusionio.com>,
	Jan Beulich <jbeulich@suse.com>,
	liguang <lig.fnst@cn.fujitsu.com>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <51D28E69.9060205@linux.vnet.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/02/2013 04:25 PM, Srivatsa S. Bhat wrote:
> Hi Michael,
> 
> On 07/02/2013 11:02 AM, Michael Wang wrote:
>> Hi, Srivatsa
>>
>> On 06/28/2013 03:54 AM, Srivatsa S. Bhat wrote:
>> [snip]
>>> @@ -625,8 +632,9 @@ EXPORT_SYMBOL(on_each_cpu_mask);
>>>   * The function might sleep if the GFP flags indicates a non
>>>   * atomic allocation is allowed.
>>>   *
>>> - * Preemption is disabled to protect against CPUs going offline but not online.
>>> - * CPUs going online during the call will not be seen or sent an IPI.
>>> + * We use get/put_online_cpus_atomic() to protect against CPUs going
>>> + * offline but not online. CPUs going online during the call will
>>> + * not be seen or sent an IPI.
>>
>> I was a little confused about this comment, if the offline-cpu still
>> have chances to become online, then there is chances that we will pick
>> it from for_each_online_cpu(), isn't it? Did I miss some point?
>>
> 
> Whether or not the newly onlined CPU is observed in our for_each_online_cpu()
> loop, is dependent on timing. On top of that, there are 2 paths in the code:
> one which uses a temporary cpumask and the other which doesn't. In the former
> case, if a CPU comes online _after_ we populate the temporary cpumask, then
> we won't send an IPI to that cpu, since the temporary cpumask doesn't contain
> that CPU. Whereas, if we observe the newly onlined CPU in the for_each_online_cpu()
> loop itself (either in the former or the latter case), then yes, we will send
> the IPI to that CPU.

So it is not 'during the call' but 'during the call of
on_each_cpu_mask()', correct?

The comment position seems like it declaim that during the call of this
func, online-cpu won't be seem and send IPI...

Regards,
Michael Wang

> 
> Regards,
> Srivatsa S. Bhat
> 
>>
>>>   *
>>>   * You must not call this function with disabled interrupts or
>>>   * from a hardware interrupt handler or from a bottom half handler.
>>> @@ -641,26 +649,26 @@ void on_each_cpu_cond(bool (*cond_func)(int cpu, void *info),
>>>  	might_sleep_if(gfp_flags & __GFP_WAIT);
>>>
>>>  	if (likely(zalloc_cpumask_var(&cpus, (gfp_flags|__GFP_NOWARN)))) {
>>> -		preempt_disable();
>>> +		get_online_cpus_atomic();
>>>  		for_each_online_cpu(cpu)
>>>  			if (cond_func(cpu, info))
>>>  				cpumask_set_cpu(cpu, cpus);
>>>  		on_each_cpu_mask(cpus, func, info, wait);
>>> -		preempt_enable();
>>> +		put_online_cpus_atomic();
>>>  		free_cpumask_var(cpus);
>>>  	} else {
>>>  		/*
>>>  		 * No free cpumask, bother. No matter, we'll
>>>  		 * just have to IPI them one by one.
>>>  		 */
>>> -		preempt_disable();
>>> +		get_online_cpus_atomic();
>>>  		for_each_online_cpu(cpu)
>>>  			if (cond_func(cpu, info)) {
>>>  				ret = smp_call_function_single(cpu, func,
>>>  								info, wait);
>>>  				WARN_ON_ONCE(!ret);
>>>  			}
>>> -		preempt_enable();
>>> +		put_online_cpus_atomic();
>>>  	}
>>>  }
>>>  EXPORT_SYMBOL(on_each_cpu_cond);
>>>
>>
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
