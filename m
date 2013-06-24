From: David Daney <ddaney.cavm@gmail.com>
Subject: Re: [PATCH 25/45] staging/octeon: Use get/put_online_cpus_atomic()
 to prevent CPU offline
Date: Mon, 24 Jun 2013 11:17:06 -0700
Message-ID: <51C88D22.5000408@gmail.com>
References: <20130623133642.19094.16038.stgit@srivatsabhat.in.ibm.com> <20130623134331.19094.80396.stgit@srivatsabhat.in.ibm.com> <20130623181740.GB24256@kroah.com> <51C744A9.8000406@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	walken@google.com, vincent.guittot@linaro.org,
	laijs@cn.fujitsu.com, rostedt@goodmis.org,
	wangyun@linux.vnet.ibm.com, xiaoguangrong@linux.vnet.ibm.com,
	sbw@mit.edu, fweisbec@gmail.com, zhong@linux.vnet.ibm.com,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devel@driverdev.osuosl.org, ddaney@caviumnetworks.com
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51C744A9.8000406@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/23/2013 11:55 AM, Srivatsa S. Bhat wrote:
> On 06/23/2013 11:47 PM, Greg Kroah-Hartman wrote:
>> On Sun, Jun 23, 2013 at 07:13:33PM +0530, Srivatsa S. Bhat wrote:
>>> Once stop_machine() is gone from the CPU offline path, we won't be able
>>> to depend on disabling preemption to prevent CPUs from going offline
>>> from under us.
>>>
>>> Use the get/put_online_cpus_atomic() APIs to prevent CPUs from going
>>> offline, while invoking from atomic context.
>>>
>>> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>>> Cc: devel@driverdev.osuosl.org
>>> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
>>> ---
>>>
>>>   drivers/staging/octeon/ethernet-rx.c |    3 +++
>>>   1 file changed, 3 insertions(+)
>>>
>>> diff --git a/drivers/staging/octeon/ethernet-rx.c b/drivers/staging/octeon/ethernet-rx.c
>>> index 34afc16..8588b4d 100644
>>> --- a/drivers/staging/octeon/ethernet-rx.c
>>> +++ b/drivers/staging/octeon/ethernet-rx.c
>>> @@ -36,6 +36,7 @@
>>>   #include <linux/prefetch.h>
>>>   #include <linux/ratelimit.h>
>>>   #include <linux/smp.h>
>>> +#include <linux/cpu.h>
>>>   #include <linux/interrupt.h>
>>>   #include <net/dst.h>
>>>   #ifdef CONFIG_XFRM
>>> @@ -97,6 +98,7 @@ static void cvm_oct_enable_one_cpu(void)
>>>   		return;
>>>
>>>   	/* ... if a CPU is available, Turn on NAPI polling for that CPU.  */
>>> +	get_online_cpus_atomic();
>>>   	for_each_online_cpu(cpu) {
>>>   		if (!cpu_test_and_set(cpu, core_state.cpu_state)) {
>>>   			v = smp_call_function_single(cpu, cvm_oct_enable_napi,
>>> @@ -106,6 +108,7 @@ static void cvm_oct_enable_one_cpu(void)
>>>   			break;
>>>   		}
>>>   	}
>>> +	put_online_cpus_atomic();
>>
>> Does this driver really need to be doing this in the first place?  If
>> so, why?  The majority of network drivers don't, why is this one
>> "special"?


It depends on your definition of "need".

The current driver receives packets from *all* network ports into a 
single queue (in OCTEON speak this queue is called a POW group).  Under 
high packet rates, the CPU time required to process the packets may 
exceed the capabilities of a single CPU.

In order to increase throughput beyond the single CPU limited rate, we 
bring more than one CPUs into play for NAPI receive.  The code being 
patched here is part of the logic that controls which CPUs are used for 
NAPI receive.

Just for the record:  Yes I know that doing this may lead to packet 
reordering when doing forwarding.

A further question that wasn't asked is: Will the code work at all if a 
CPU is taken offline even if the race, the patch eliminates, is avoided?

I doubt it.

As far as the patch goes:

Acked-by: David Daney <david.daney@cavium.com>

David Daney

>>
>
> Honestly, I don't know. Let's CC the author of that code (David Daney).
> I wonder why get_maintainer.pl didn't generate his name for this file,
> even though the entire file is almost made up of his commits alone!
>
> Regards,
> Srivatsa S. Bhat
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
