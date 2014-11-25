From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH v5 2/4] arch: Add lightweight memory barriers dma_rmb()
 and dma_wmb()
Date: Tue, 25 Nov 2014 08:26:28 -0800
Message-ID: <5474ADB4.5070200@redhat.com>
References: <20141119012205.9563.95544.stgit@ahduyck-server> <20141119012400.9563.21117.stgit@ahduyck-server> <20141125140130.GC8541@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mathieu.desnoyers@polymtl.ca" <mathieu.desnoyers@polymtl.ca>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"benh@kernel.crashing.org" <benh@kernel.crashing.org>,
	"heiko.carstens@de.ibm.com" <heiko.carstens@de.ibm.com>,
	"mingo@kernel.org" <mingo@kernel.org>,
	"mikey@neuling.org" <mikey@neuling.org>,
	"linux@arm.linux.org.uk" <linux@arm.linux.org.uk>,
	"donald.c.skidmore@intel.com" <donald.c.skidmore@intel.com>,
	"matthew.vick@intel.com" <matthew.vick@intel.com>,
	"geert@linux-m68k.org" <geert@linux-m68k.org>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"romieu@fr.zoreil.com" <romieu@fr.zoreil.com>,
	"paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>,
	"nic_swsd@realtek.com" <nic_
To: Will Deacon <will.deacon@arm.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20141125140130.GC8541@arm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 11/25/2014 06:01 AM, Will Deacon wrote:
> On Wed, Nov 19, 2014 at 01:24:02AM +0000, Alexander Duyck wrote:
>> diff --git a/Documentation/memory-barriers.txt b/Documentation/memory-barriers.txt
>> index 22a969c..a1c589b 100644
>> --- a/Documentation/memory-barriers.txt
>> +++ b/Documentation/memory-barriers.txt
>> @@ -1615,6 +1615,47 @@ There are some more advanced barrier functions:
>>        operations" subsection for information on where to use these.
>>
>>
>> + (*) dma_wmb();
>> + (*) dma_rmb();
>> +
>> +     These are for use with memory based device I/O to guarantee the ordering
>> +     of cache coherent writes or reads with respect to other writes or reads
>> +     to cache coherent DMA memory.
> Can you please make it crystal clear that "memory based device I/O" != MMIO?
> If people get these barriers wrong, then debugging will be a nightmare.

I think I'll update that to the following to avoid any confusion:
      These are for use with consistent memory to guarantee the ordering
      of writes or reads of shared memory accessible to both the CPU and a
      DMA capable device.

I will also add a reference to DMA-API.txt at the end for more info on 
what consistent memory is.

>> diff --git a/arch/arm/include/asm/barrier.h b/arch/arm/include/asm/barrier.h
>> index c6a3e73..d2f81e6 100644
>> --- a/arch/arm/include/asm/barrier.h
>> +++ b/arch/arm/include/asm/barrier.h
>> @@ -43,10 +43,14 @@
>>   #define mb()           do { dsb(); outer_sync(); } while (0)
>>   #define rmb()          dsb()
>>   #define wmb()          do { dsb(st); outer_sync(); } while (0)
>> +#define dma_rmb()      dmb(osh)
>> +#define dma_wmb()      dmb(oshst)
>>   #else
>>   #define mb()           barrier()
>>   #define rmb()          barrier()
>>   #define wmb()          barrier()
>> +#define dma_rmb()      barrier()
>> +#define dma_wmb()      barrier()
>>   #endif
>>
>>   #ifndef CONFIG_SMP
>> diff --git a/arch/arm64/include/asm/barrier.h b/arch/arm64/include/asm/barrier.h
>> index 6389d60..a5abb00 100644
>> --- a/arch/arm64/include/asm/barrier.h
>> +++ b/arch/arm64/include/asm/barrier.h
>> @@ -32,6 +32,9 @@
>>   #define rmb()          dsb(ld)
>>   #define wmb()          dsb(st)
>>
>> +#define dma_rmb()      dmb(oshld)
>> +#define dma_wmb()      dmb(oshst)
>> +
>>   #ifndef CONFIG_SMP
>>   #define smp_mb()       barrier()
>>   #define smp_rmb()      barrier()
> The arm/arm64 bits look fine to me.
>
>    Acked-by: Will Deacon <will.deacon@arm.com>

Thanks for the review.

> If we ever see platforms using Linux/dma_alloc_coherent with devices
> mastering from a different outer-shareable domain that the one containing
> the CPUs, then we'll need to revisit this.

Would we just need a system wide memory barrier in that case instead of 
an outer shareable memory barrier, or would we need to look as something 
like a sync barrier?

- Alex
