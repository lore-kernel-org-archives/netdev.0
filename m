From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v5 2/4] arch: Add lightweight memory barriers dma_rmb()
 and dma_wmb()
Date: Tue, 25 Nov 2014 14:01:30 +0000
Message-ID: <20141125140130.GC8541@arm.com>
References: <20141119012205.9563.95544.stgit@ahduyck-server>
 <20141119012400.9563.21117.stgit@ahduyck-server>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss-mx-na.foss.arm.com ([217.140.108.86]:38925 "EHLO
	foss-mx-na.foss.arm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751353AbaKYOBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 09:01:31 -0500
Content-Disposition: inline
In-Reply-To: <20141119012400.9563.21117.stgit@ahduyck-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 19, 2014 at 01:24:02AM +0000, Alexander Duyck wrote:
> diff --git a/Documentation/memory-barriers.txt b/Documentation/memory-barriers.txt
> index 22a969c..a1c589b 100644
> --- a/Documentation/memory-barriers.txt
> +++ b/Documentation/memory-barriers.txt
> @@ -1615,6 +1615,47 @@ There are some more advanced barrier functions:
>       operations" subsection for information on where to use these.
> 
> 
> + (*) dma_wmb();
> + (*) dma_rmb();
> +
> +     These are for use with memory based device I/O to guarantee the ordering
> +     of cache coherent writes or reads with respect to other writes or reads
> +     to cache coherent DMA memory.

Can you please make it crystal clear that "memory based device I/O" != MMIO?
If people get these barriers wrong, then debugging will be a nightmare.

> diff --git a/arch/arm/include/asm/barrier.h b/arch/arm/include/asm/barrier.h
> index c6a3e73..d2f81e6 100644
> --- a/arch/arm/include/asm/barrier.h
> +++ b/arch/arm/include/asm/barrier.h
> @@ -43,10 +43,14 @@
>  #define mb()           do { dsb(); outer_sync(); } while (0)
>  #define rmb()          dsb()
>  #define wmb()          do { dsb(st); outer_sync(); } while (0)
> +#define dma_rmb()      dmb(osh)
> +#define dma_wmb()      dmb(oshst)
>  #else
>  #define mb()           barrier()
>  #define rmb()          barrier()
>  #define wmb()          barrier()
> +#define dma_rmb()      barrier()
> +#define dma_wmb()      barrier()
>  #endif
> 
>  #ifndef CONFIG_SMP
> diff --git a/arch/arm64/include/asm/barrier.h b/arch/arm64/include/asm/barrier.h
> index 6389d60..a5abb00 100644
> --- a/arch/arm64/include/asm/barrier.h
> +++ b/arch/arm64/include/asm/barrier.h
> @@ -32,6 +32,9 @@
>  #define rmb()          dsb(ld)
>  #define wmb()          dsb(st)
> 
> +#define dma_rmb()      dmb(oshld)
> +#define dma_wmb()      dmb(oshst)
> +
>  #ifndef CONFIG_SMP
>  #define smp_mb()       barrier()
>  #define smp_rmb()      barrier()

The arm/arm64 bits look fine to me.

  Acked-by: Will Deacon <will.deacon@arm.com>

If we ever see platforms using Linux/dma_alloc_coherent with devices
mastering from a different outer-shareable domain that the one containing
the CPUs, then we'll need to revisit this.

Will
