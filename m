From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH linux-next 1/2] irq: Add CPU mask affinity hint callback
 framework
Date: Thu, 22 Apr 2010 05:11:12 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.64.1004220459110.3324@PPWASKIE-MOBL2.amr.corp.intel.com>
References: <20100420180112.1276.11906.stgit@ppwaskie-hc2.jf.intel.com>
 <1271854785.2101.17.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "tglx@linutronix.de" <tglx@linutronix.de>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"arjan@linux.jf.intel.com" <arjan@linux.jf.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1271854785.2101.17.camel@achroite.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 21 Apr 2010, Ben Hutchings wrote:

> On Tue, 2010-04-20 at 11:01 -0700, Peter P Waskiewicz Jr wrote:
>> This patch adds a callback function pointer to the irq_desc
>> structure, along with a registration function and a read-only
>> proc entry for each interrupt.
>>
>> This affinity_hint handle for each interrupt can be used by
>> underlying drivers that need a better mechanism to control
>> interrupt affinity.  The underlying driver can register a
>> callback for the interrupt, which will allow the driver to
>> provide the CPU mask for the interrupt to anything that
>> requests it.  The intent is to extend the userspace daemon,
>> irqbalance, to help hint to it a preferred CPU mask to balance
>> the interrupt into.
>
> Doesn't it make more sense to have the driver follow affinity decisions
> made from user-space?  I realise that reallocating queues is disruptive
> and we probably don't want irqbalance to trigger that, but there should
> be a mechanism for the administrator to trigger it.

The driver here would be assisting userspace (irqbalance) to provide 
better details how the HW is laid out with respect to flows.  As it stands 
today, irqbalance is almost guaranteed to move interrups to CPUs that are 
not aligned with where applications are running for network adapters. 
This is very apparent when running at speeds in the 10 Gigabit range, or 
even multiple 1 Gigabit ports running at the same time.

>
> Looking at your patch for ixgbe:
>
> [...]
>> diff --git a/drivers/net/ixgbe/ixgbe_main.c
>> b/drivers/net/ixgbe/ixgbe_main.c
>> index 1b1419c..3e00d41 100644
>> --- a/drivers/net/ixgbe/ixgbe_main.c
>> +++ b/drivers/net/ixgbe/ixgbe_main.c
> [...]
>> @@ -1083,6 +1113,16 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
>>                         q_vector->eitr = adapter->rx_eitr_param;
>>
>>                 ixgbe_write_eitr(q_vector);
>> +
>> +               /*
>> +                * Allocate the affinity_hint cpumask, assign the mask for
>> +                * this vector, and register our affinity_hint callback.
>> +                */
>> +               alloc_cpumask_var(&q_vector->affinity_mask, GFP_KERNEL);
>> +               cpumask_set_cpu(v_idx, q_vector->affinity_mask);
>> +               irq_register_affinity_hint(adapter->msix_entries[v_idx].vector,
>> +                                          adapter,
>> +                                          &ixgbe_irq_affinity_callback);
>>         }
>>
>>         if (adapter->hw.mac.type == ixgbe_mac_82598EB)
> [...]
>
> This just assigns IRQs to the first n CPU threads.  Depending on the
> enumeration order, this might result in assigning an IRQ to each of 2
> threads on a core while leaving other cores unused!

This ixgbe patch is only meant to be an example of how you could use it. 
I didn't hammer out all the corner cases of interrupt alignment in it yet. 
However, ixgbe is already aligning Tx flows onto the CPU/queue pair the Tx 
occurred (i.e. Tx session from CPU 4 will be queued on Tx queue 4), and 
then uses our Flow Director HW offload to steer Rx to Rx queue 4, assuming 
that the interrupt for Rx queue 4 is affinitized to CPU 4.  The flow 
alignment breaks when the IRQ affinity has no knowledge what the 
underlying set of vectors are bound to, and what mode the HW is running 
in.

FCoE offloads that spread multiple SCSI exchange IDs across CPU cores also 
needs this to properly align things.  John Fastabend is going to provide 
some examples where this is very useful in the FCoE case.

> irqbalance can already find the various IRQs associated with a single
> net device by looking at the handler names.  So it can do at least as
> well as this without such a hint.  Unless drivers have *useful* hints to
> give, I don't see the point in adding this mechanism.

irqbalance identifies which interrupts go with which network device.  But 
it has no clue about flow management, and often will make a decision that 
hurts performance scaling.  I have data showing when scaling multiple 10 
Gigabit ports (4 in the current test), I can gain an extra 10 Gigabits of 
throughput just by aligning the interrupts properly (go from ~58 Gbps to 
~68 Gbps in bi-directional tests).

I do have the patches for irqbalance that uses this new handle to make 
better decisions for devices implementing the mask.  I can send those to 
help show the whole picture of what's happening.

Appreciate the feedback though Ben.

Cheers,
-PJ
