From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: Irq architecture for multi-core network driver.
Date: Wed, 16 Dec 2009 15:26:02 -0800
Message-ID: <4B296C8A.6000900@caviumnetworks.com>
References: <4AE0D14B.1070307@caviumnetworks.com>       <4AE0D72A.4090607@nortel.com>   <4AE0DB98.1000101@caviumnetworks.com>   <b2f3590f0912161408u73947f6fx6902ebef927caf94@mail.gmail.com>   <4B295F8C.4050905@caviumnetworks.com> <20091216150051.63b6e31c@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chetan Loke <chetanloke@gmail.com>,
        Chris Friesen <cfriesen@nortel.com>, netdev@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-mips <linux-mips@linux-mips.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <20091216150051.63b6e31c@nehalam>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Wed, 16 Dec 2009 14:30:36 -0800
> David Daney <ddaney@caviumnetworks.com> wrote:
> 
>> Chetan Loke wrote:
>>>>> Does your hardware do flow-based queues?  In this model you have
>>>>> multiple rx queues and the hardware hashes incoming packets to a single
>>>>> queue based on the addresses, ports, etc. This ensures that all the
>>>>> packets of a single connection always get processed in the order they
>>>>> arrived at the net device.
>>>>>
>>>> Indeed, this is exactly what we have.
>>>>
>>>>
>>>>> Typically in this model you have as many interrupts as queues
>>>>> (presumably 16 in your case).  Each queue is assigned an interrupt and
>>>>> that interrupt is affined to a single core.
>>>> Certainly this is one mode of operation that should be supported, but I
>>>> would also like to be able to go for raw throughput and have as many cores
>>>> as possible reading from a single queue (like I currently have).
>>>>
>>> Well, you could let the NIC firmware(f/w) handle this. The f/w would
>>> know which interrupt was just injected recently.In other words it
>>> would have a history of which CPU's would be available. So if some
>>> previously interrupted CPU isn't making good progress then the
>>> firmware should route the incoming response packets to a different
>>> queue. This way some other CPU will pick it up.
>>>
>>
>> It isn's a NIC.  There is no firmware.  The system interrupt hardware is 
>> what it is and cannot be changed.
>>
>> My current implementation still has a single input queue configured and 
>> I get a maskable interrupt on a single CPU when packets are available. 
>> If the queue depth increases above a given threshold, I optionally send 
>> an IPI to another CPU to enable NAPI polling on that CPU.
>>
>> Currently I have a module parameter that controls the maximum number of 
>> CPUs that will have NAPI polling enabled.
>>
>> This allows me to get multiple CPUs doing receive processing without 
>> having to hack into the lower levels of the system's interrupt 
>> processing code to try to do interrupt steering.  Since all the 
>> interrupt service routine was doing was call netif_rx_schedule(), I can 
>> simply do this via smp_call_function_single().
> 
> Better to look into receive packet steering patches that are still
> under review (rather than reinventing it just for your driver)
> 

Indeed.  Although it turns out that I can do packet steering in hardware 
  across up to 16 queues each with their own irq and thus dedicated CPU. 
  So it is unclear to me if the receive packet steering patches offer 
much benefit to this hardware.

One concern is the ability to forward as many packets as possible from a 
very low number of flows (between 1 and 4).  Since it is an artificial 
benchmark, we can arbitrarily say that packet reordering is allowed. 
The simple hack to do NAPI polling on all CPUs from a single queue gives 
good results.  There is no need to remind me that packet reordering 
should be avoided, I already know this.

David Daney
