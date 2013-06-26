From: Paolo Bonzini <pbonzini@redhat.com>
Subject: Re: [PATCH v2 29/45] kvm/vmx: Use get/put_online_cpus_atomic() to
 prevent CPU offline
Date: Wed, 26 Jun 2013 10:57:49 +0200
Message-ID: <51CAAD0D.8090601@redhat.com>
References: <20130625202452.16593.22810.stgit@srivatsabhat.in.ibm.com> <20130625203043.16593.1600.stgit@srivatsabhat.in.ibm.com> <51CA9C5E.1030609@redhat.com> <51CAA116.2060906@linux.vnet.ibm.com> <51CAA514.8050609@redhat.com> <51CAA921.7030906@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Gleb Natapov <gleb@redhat.com>, peterz@infradead.org,
	fweisbec@gmail.com, linux-kernel@vger.kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>, walken@google.com,
	mingo@kernel.org, linux-arch@vger.kernel.org,
	vincent.guittot@linaro.org, kvm@vger.kernel.org, x86@kernel.org,
	xiaoguangrong@linux.vnet.ibm.com, Ingo Molnar <mingo@redhat.com>,
	wangyun@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	rusty@rustcorp.com.au, rostedt@goodmis.org, namhyung@kernel.org,
	tglx@linutronix.de, laijs@cn.fujitsu.com, zhong@linux.vnet.ibm.com,
	netdev@vger.kernel.org, oleg@redhat.com, sbw@mit.edu,
	tj@kernel.org, akpm@linux-foundation.org,
	linuxppc-dev@lists.ozlabs.org
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <51CAA921.7030906@linux.vnet.ibm.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Il 26/06/2013 10:41, Srivatsa S. Bhat ha scritto:
> On 06/26/2013 01:53 PM, Paolo Bonzini wrote:
>> Il 26/06/2013 10:06, Srivatsa S. Bhat ha scritto:
>>> On 06/26/2013 01:16 PM, Paolo Bonzini wrote:
>>>> Il 25/06/2013 22:30, Srivatsa S. Bhat ha scritto:
>>>>> -	cpu = get_cpu();
>>>>> +	cpu = get_online_cpus_atomic();
>>>>>  	vmx_vcpu_load(&vmx->vcpu, cpu);
>>>>>  	vmx->vcpu.cpu = cpu;
>>>>>  	err = vmx_vcpu_setup(vmx);
>>>>>  	vmx_vcpu_put(&vmx->vcpu);
>>>>> -	put_cpu();
>>>>> +	put_online_cpus_atomic();
>>>>
>>>> The new API has a weird name.  Why are you adding new functions instead
>>>> of just modifying get/put_cpu?
>>>>
>>>
>>> Because the purpose of those two functions are distinctly different
>>> from each other.
>>>
>>> get/put_cpu() is used to disable preemption on the local CPU. (Which
>>> also disables offlining the local CPU during that critical section).
>>
>> Ok, then I understood correctly... and I acked the other KVM patch.
>>
> 
> Thank you!
>  
>> However, keeping the code on the local CPU is exactly the point of this
>> particular use of get_cpu()/put_cpu().  Why does it need to synchronize
>> with offlining of other CPUs?
> 
> Now that I looked at it again, I think you are right, get/put_cpu() is
> good enough here.
> 
> But let me explain why I initially thought we needed full synchronization
> with CPU offline. In short, I wanted to synchronize the calls to
> __loaded_vmcs_clear(). We have the scenario shown below:
> 
> CPU offline:
> 	CPU_DYING:
> 		hardware_disable();
> 		->vmclear_local_loaded_vmcss();
> 		  ->__loaded_vmcs_clear(v);
> 
> 
> 
> And vmx_vcpu_load() (among others) can do:
>        vmx_vcpu_load();
>        -> loaded_vmcs_clear();
>           -> __loaded_vmcs_clear();
> 
> 
> So I wanted to avoid this race-condition and hence wrapped the code with
> get/put_online_cpus_atomic().
> 
> But the point I missed earlier is that loaded_vmcs_clear() calls
> __loaded_vmcs_clear() using smp_call_function_single(), which itself
> synchronizes properly with CPU hotplug. So there is no need to add full
> hotplug synchronization in the vmx code, as you noted above.

Makes sense, and I see now that it's patch 9 in this series.

In general, I would rather add an extra get_online_cpus_atomic pair
where it it actually needed (i.e. closer to where cpu_online is actually
used), and leave get_cpu/put_cpu as is in the caller... which is exactly
what happens in this case, since "where it is actually needed" is "in
smp_call_function_single()".

> So, please ignore this patch, and sorry for the noise!

No problem, thanks for the heads-up.

Paolo

