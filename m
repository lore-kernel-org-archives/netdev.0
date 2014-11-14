From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH 1/3] arch: Introduce load_acquire() and store_release()
Date: Fri, 14 Nov 2014 08:00:05 -0800
Message-ID: <54662705.9050603@redhat.com>
References: <20141113191250.12579.19694.stgit@ahduyck-server> <20141113192723.12579.25343.stgit@ahduyck-server> <20141114101902.GA27963@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mikey@neuling.org" <mikey@neuling.org>,
	"tony.luck@intel.com" <tony.luck@intel.com>,
	"mathieu.desnoyers@polymtl.ca" <mathieu.desnoyers@polymtl.ca>,
	"donald.c.skidmore@intel.com" <donald.c.skidmore@intel.com>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"benh@kernel.crashing.org" <benh@kernel.crashing.org>,
	"heiko.carstens@de.ibm.com" <heiko.carstens@de.ibm.com>,
	"oleg@redhat.com" <oleg@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"michael@ellerman.id.au" <michael@ellerman.id.au>,
	"matthew.vick@intel.com" <matthew.vick@intel.com>,
	"nic_swsd@realtek.com" <nic_swsd@realtek.com>,
	"geert@linux-m68k.org" <geert@linux-m68k.org>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
To: Will Deacon <will.deacon@arm.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20141114101902.GA27963@arm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 11/14/2014 02:19 AM, Will Deacon wrote:
> Hi Alex,
>
> On Thu, Nov 13, 2014 at 07:27:23PM +0000, Alexander Duyck wrote:
>> It is common for device drivers to make use of acquire/release semantics
>> when dealing with descriptors stored in device memory.  On reviewing the
>> documentation and code for smp_load_acquire() and smp_store_release() as
>> well as reviewing an IBM website that goes over the use of PowerPC barriers
>> at http://www.ibm.com/developerworks/systems/articles/powerpc.html it
>> occurred to me that the same code could likely be applied to device drivers.
>>
>> As a result this patch introduces load_acquire() and store_release().  The
>> load_acquire() function can be used in the place of situations where a test
>> for ownership must be followed by a memory barrier.  The below example is
>> from ixgbe:
>>
>>          if (!rx_desc->wb.upper.status_error)
>>                  break;
>>
>>          /* This memory barrier is needed to keep us from reading
>>           * any other fields out of the rx_desc until we know the
>>           * descriptor has been written back
>>           */
>>          rmb();
>>
>> With load_acquire() this can be changed to:
>>
>>          if (!load_acquire(&rx_desc->wb.upper.status_error))
>>                  break;
> I still don't think this is a good idea for the specific use-case you're
> highlighting.
>
> On ARM, an mb() can be *significantly* more expensive than an rmb() (since
> we may have to drain store buffers on an outer L2 cache) and on arm64 it's
> not at all clear that an LDAR is more efficient than an LDR; DMB LD
> sequence. I can certainly imagine implementations where the latter would
> be preferred.

Yeah, I am pretty sure I overdid it in using a mb() for arm.  I think 
what I should probably be using is something like dmb(ish) which is used 
for smp_mb() instead.  The general idea is to enforce memory-memory 
accesses.  The memory-mmio accesses still should be using a full 
rmb()/wmb() barrier.

The alternative I am mulling over is creating something like a 
lightweight set of memory barriers named lw_mb(), lw_rmb(), lw_wmb(), 
that could be used instead.  The general idea is that on many 
architectures a full mb/rmb/wmb is far too much for just guaranteeing 
ordering for system memory only writes or reads.  I'm thinking I could 
probably use the smp_ varieties as a template for them since I'm 
thinking that in most cases this should be correct.

Also, just to be clear I am not advocating replacing the wmb() in most 
I/O setups where we have to sync the system memory before doing the MMIO 
write.  This is for the case where the device descriptor ring has some 
bit indicating ownership by either the device or the CPU.  So for 
example on the r8169 they have to do a wmb() before writing the DescOwn 
bit in the first descriptor of a given set of Tx descriptors to 
guarantee the rest are written, then they set the DescOwn bit, then they 
call wmb() again to flush that last bit before notifying the device it 
can start fetching the descriptors. My goal is to deal with that first 
wmb() and leave the second as it since it is correct.

> So, whilst I'm perfectly fine to go along with mandatory acquire/release
> macros (we should probably add a check to barf on __iomem pointers), I
> don't agree with using them in preference to finer-grained read/write
> barriers. Doing so will have a real impact on I/O performance.

Couldn't that type of check be added to compiletime_assert_atomic_type?  
That seems like that would be the best place for something like that.


> Finally, do you know of any architectures where load_acquire/store_release
> aren't implemented the same way as the smp_* variants on SMP kernels?
>
> Will

I should probably go back through and sort out the cases where mb() and 
smp_mb() are not the same thing.  I think I probably went with too harsh 
of a barrier in probably a couple of other cases.

Thanks,

Alex
