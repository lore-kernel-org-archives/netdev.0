From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH linux-next 1/2] irq: Add CPU mask affinity hint callback
 framework
Date: Fri, 23 Apr 2010 02:27:54 -0700
Message-ID: <4BD1681A.3010901@intel.com>
References: <20100420180112.1276.11906.stgit@ppwaskie-hc2.jf.intel.com>	 <1271854785.2101.17.camel@achroite.uk.solarflarecom.com>	 <Pine.WNT.4.64.1004220459110.3324@PPWASKIE-MOBL2.amr.corp.intel.com> <1271950900.2095.25.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"arjan@linux.jf.intel.com" <arjan@linux.jf.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1271950900.2095.25.camel@achroite.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Hutchings wrote:
> On Thu, 2010-04-22 at 05:11 -0700, Peter P Waskiewicz Jr wrote:
>> On Wed, 21 Apr 2010, Ben Hutchings wrote:
>>
>>> On Tue, 2010-04-20 at 11:01 -0700, Peter P Waskiewicz Jr wrote:
>>>> This patch adds a callback function pointer to the irq_desc
>>>> structure, along with a registration function and a read-only
>>>> proc entry for each interrupt.
>>>>
>>>> This affinity_hint handle for each interrupt can be used by
>>>> underlying drivers that need a better mechanism to control
>>>> interrupt affinity.  The underlying driver can register a
>>>> callback for the interrupt, which will allow the driver to
>>>> provide the CPU mask for the interrupt to anything that
>>>> requests it.  The intent is to extend the userspace daemon,
>>>> irqbalance, to help hint to it a preferred CPU mask to balance
>>>> the interrupt into.
>>> Doesn't it make more sense to have the driver follow affinity decisions
>>> made from user-space?  I realise that reallocating queues is disruptive
>>> and we probably don't want irqbalance to trigger that, but there should
>>> be a mechanism for the administrator to trigger it.
>> The driver here would be assisting userspace (irqbalance) to provide 
>> better details how the HW is laid out with respect to flows.  As it stands 
>> today, irqbalance is almost guaranteed to move interrups to CPUs that are 
>> not aligned with where applications are running for network adapters. 
>> This is very apparent when running at speeds in the 10 Gigabit range, or 
>> even multiple 1 Gigabit ports running at the same time.
> 
> I'm well aware that irqbalance isn't making good decisions at the
> moment.  The question is whether this will really help irqbalance to do
> better.
> 

FCoE is one example where these hints can really help irqbalance make 
good decisions.  By aligning the interrupt affinity with the FCoE 
receive processing thread we can avoid context switching from the NET_RX
softirq to the receive processing thread.

Because the base driver knows which rx rings are being used for FCoE in 
a particular configuration and their corresponding vectors it seems to 
be in the best position to provide good hints to irqbalance.  Also if 
the mapping changes at some point the base driver will be aware of it.

> [...]
>>> This just assigns IRQs to the first n CPU threads.  Depending on the
>>> enumeration order, this might result in assigning an IRQ to each of 2
>>> threads on a core while leaving other cores unused!
>> This ixgbe patch is only meant to be an example of how you could use it. 
>> I didn't hammer out all the corner cases of interrupt alignment in it yet. 
>> However, ixgbe is already aligning Tx flows onto the CPU/queue pair the Tx 
>> occurred (i.e. Tx session from CPU 4 will be queued on Tx queue 4),
> [...]
> 
> OK, now I remember ixgbe has this odd select_queue() implementation.
> But this behaviour can result in reordering whenever a user thread
> migrates, and in any case Dave discourages people from setting
> select_queue().  So I see that these changes would be useful for ixgbe
> (together with an update to irqbalance), but they don't seem to fit the
> general direction of multiqueue networking on Linux.

For DCB setting select_queue() is useful because we want to map traffic 
types to specific tx queues not hash them across all queues.  In this 
case where we are placing specific traffic on specific queues it also 
makes sense to align the interrupts for some types such as FCoE.  There 
shouldn't be any issues with user thread migration in this specific example.

> 
> (Actually, the hints seem to be incomplete.  If there are more than 16
> CPU threads then multiple CPU threads can map to the same queues, but it
> looks like you only include the first in the queue's hint.)
> 
> An alternate approach is to use the RX queue index to drive TX queue
> selection.  I posted a patch to do that earlier this week.  However I
> haven't yet had a chance to try that on a suitably large system.
>

I'll post an FCoE example patch soon and take a closer look at your 
patch, but mapping TX/RX queues in sock's won't help for cases like FCoE.

Thanks,
John.
