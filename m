From: Michael Wang <wangyun@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 10/45] smp: Use get/put_online_cpus_atomic() to prevent
 CPU offline
Date: Tue, 02 Jul 2013 18:08:34 +0800
Message-ID: <51D2A6A2.207@linux.vnet.ibm.com>
References: <20130627195136.29830.10445.stgit@srivatsabhat.in.ibm.com> <20130627195418.29830.34958.stgit@srivatsabhat.in.ibm.com> <51D2660A.8000401@linux.vnet.ibm.com> <51D28E69.9060205@linux.vnet.ibm.com> <51D2939C.5090205@linux.vnet.ibm.com> <51D2A289.7070805@linux.vnet.ibm.com>
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
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <51D2A289.7070805@linux.vnet.ibm.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/02/2013 05:51 PM, Srivatsa S. Bhat wrote:
[snip]
> 
> Well, as I said, its timing dependent. We might miss the newly onlined CPU in
> the for_each_online_cpu() loop itself, based on when exactly the CPU was added
> to the cpu_online_mask. So you can't exactly pin-point the places where you'll
> miss the CPU and where you won't. Besides, is it _that_ important? It is after
> all unpredictable..

Sure, it's nothing important ;-)

I just think this comment:

+ * We use get/put_online_cpus_atomic() to protect against CPUs going
+ * offline but not online. CPUs going online during the call will
+ * not be seen or sent an IPI

It told people that the cpu could online during the call, but won't get
IPI, while actually they have a chance to get it, folks haven't look
inside may missed some thing when use it.

But it's just self-opinion, so let's put down the discuss :)

Regards,
Michael Wang

> 
>> The comment position seems like it declaim that during the call of this
>> func, online-cpu won't be seem and send IPI...
>>
> 
> Doesn't matter, AFAICS. The key take-away from that whole comment is: nothing is
> done to prevent CPUs from coming online while the function is running, whereas
> the online CPUs are guaranteed to remain online throughout the function. In other
> words, its a weaker form of get_online_cpus()/put_online_cpus(), providing a
> one-way synchronization (CPU offline).
> 
> As long as that idea is conveyed properly, the purpose of that comment is served,
> IMHO.
> 
> Regards,
> Srivatsa S. Bhat
> 
> 
>>>>>   *
>>>>>   * You must not call this function with disabled interrupts or
>>>>>   * from a hardware interrupt handler or from a bottom half handler.
>>>>> @@ -641,26 +649,26 @@ void on_each_cpu_cond(bool (*cond_func)(int cpu, void *info),
>>>>>  	might_sleep_if(gfp_flags & __GFP_WAIT);
>>>>>
>>>>>  	if (likely(zalloc_cpumask_var(&cpus, (gfp_flags|__GFP_NOWARN)))) {
>>>>> -		preempt_disable();
>>>>> +		get_online_cpus_atomic();
>>>>>  		for_each_online_cpu(cpu)
>>>>>  			if (cond_func(cpu, info))
>>>>>  				cpumask_set_cpu(cpu, cpus);
>>>>>  		on_each_cpu_mask(cpus, func, info, wait);
>>>>> -		preempt_enable();
>>>>> +		put_online_cpus_atomic();
>>>>>  		free_cpumask_var(cpus);
>>>>>  	} else {
>>>>>  		/*
>>>>>  		 * No free cpumask, bother. No matter, we'll
>>>>>  		 * just have to IPI them one by one.
>>>>>  		 */
>>>>> -		preempt_disable();
>>>>> +		get_online_cpus_atomic();
>>>>>  		for_each_online_cpu(cpu)
>>>>>  			if (cond_func(cpu, info)) {
>>>>>  				ret = smp_call_function_single(cpu, func,
>>>>>  								info, wait);
>>>>>  				WARN_ON_ONCE(!ret);
>>>>>  			}
>>>>> -		preempt_enable();
>>>>> +		put_online_cpus_atomic();
>>>>>  	}
>>>>>  }
>>>>>  EXPORT_SYMBOL(on_each_cpu_cond);
>>>>>
>>>>
>>>
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

