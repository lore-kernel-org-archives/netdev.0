From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH linux-next v2 1/2] irq: Add CPU mask affinity hint
Date: Fri, 30 Apr 2010 11:02:36 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.64.1004301059230.6264@PPWASKIE-MOBL2.amr.corp.intel.com>
References: <20100430085150.4630.46790.stgit@ppwaskie-hc2.jf.intel.com>
 <alpine.LFD.2.00.1004301249540.2951@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"arjan@linux.jf.intel.com" <arjan@linux.jf.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1004301249540.2951@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 30 Apr 2010, Thomas Gleixner wrote:

> On Fri, 30 Apr 2010, Peter P Waskiewicz Jr wrote:
>
>> This patch adds a cpumask affinity hint to the irq_desc
>> structure, along with a registration function and a read-only
>> proc entry for each interrupt.
>>
>> This affinity_hint handle for each interrupt can be used by
>> underlying drivers that need a better mechanism to control
>> interrupt affinity.  The underlying driver can register a
>> cpumask for the interrupt, which will allow the driver to
>> provide the CPU mask for the interrupt to anything that
>> requests it.  The intent is to extend the userspace daemon,
>> irqbalance, to help hint to it a preferred CPU mask to balance
>> the interrupt into.
>>
>> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
>> ---
>>
>>  include/linux/interrupt.h |   13 +++++++++++++
>>  include/linux/irq.h       |    1 +
>>  kernel/irq/manage.c       |   28 ++++++++++++++++++++++++++++
>>  kernel/irq/proc.c         |   33 +++++++++++++++++++++++++++++++++
>>  4 files changed, 75 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
>> index 75f3f00..9c9ea2a 100644
>> --- a/include/linux/interrupt.h
>> +++ b/include/linux/interrupt.h
>> @@ -209,6 +209,9 @@ extern int irq_set_affinity(unsigned int irq, const struct cpumask *cpumask);
>>  extern int irq_can_set_affinity(unsigned int irq);
>>  extern int irq_select_affinity(unsigned int irq);
>>
>> +extern int irq_register_affinity_hint(unsigned int irq,
>> +                                      const struct cpumask *m);
>
> I think we can do with a single funtion irq_set_affinity_hint() and
> let the caller set the pointer to NULL.

Ok, I've been running into some issues.  If CONFIG_CPUMASK_OFFSTACK is not 
set, then cpumask_var_t structs are single-element arrays that cannot be 
NULL'd out.  I'm pretty sure I need to keep the unregister part of the 
API.  Thoughts?

>> +	raw_spin_lock_irqsave(&desc->lock, flags);
>> +	if (desc->affinity_hint) {
>> +		seq_cpumask(m, desc->affinity_hint);
>
>  Please make a local copy under desc->mask and do the seq_cpumask()
>  stuff on the local copy outside of desc->lock

I just looked at the original show_affinity function, and it does not grab 
desc->lock before copying mask out of desc.  Should I follow that model, 
or should I fix that function to honor desc->lock?

-PJ
