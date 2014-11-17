From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/4] arch: Add lightweight memory barriers fast_rmb() and
 fast_wmb()
Date: Mon, 17 Nov 2014 12:18:23 -0800
Message-ID: <20141117201823.GD5050@linux.vnet.ibm.com>
References: <20141117171005.22333.96544.stgit@ahduyck-server>
 <20141117171812.22333.90395.stgit@ahduyck-server>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mathieu.desnoyers@polymtl.ca,
	peterz@infradead.org, benh@kernel.crashing.org,
	heiko.carstens@de.ibm.com, mingo@kernel.org, mikey@neuling.org,
	linux@arm.linux.org.uk, donald.c.skidmore@intel.com,
	matthew.vick@intel.com, geert@linux-m68k.org,
	jeffrey.t.kirsher@intel.com, romieu@fr.zoreil.com,
	nic_swsd@realtek.com, will.deacon@arm.com, michael@ellerman.id.au,
	tony.luck@intel.com, torvalds@linux-foundation.org,
	oleg@redhat.com, schwidefsky@de.ibm.com, fweisbec@gmail.com,
	davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141117171812.22333.90395.stgit@ahduyck-server>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 17, 2014 at 09:18:13AM -0800, Alexander Duyck wrote:
> There are a number of situations where the mandatory barriers rmb() and
> wmb() are used to order memory/memory operations in the device drivers
> and those barriers are much heavier than they actually need to be.  For
> example in the case of PowerPC wmb() calls the heavy-weight sync
> instruction when for memory/memory operations all that is really needed is
> an lsync or eieio instruction.

Is this still the case if one of the memory operations is MMIO?  Last
I knew, it was not.

> This commit adds a fast (and loose) version of the mandatory memory
> barriers rmb() and wmb().  The prefix to the name is actually based on the
> version of the functions that already exist in the mips and tile trees.
> However I thought it applicable since it gets at what we are trying to
> accomplish with these barriers and somethat implies their risky nature.
> 
> These new barriers are not as safe as the standard rmb() and wmb().
> Specifically they do not guarantee ordering between cache-enabled and
> cache-inhibited memories.  The primary use case for these would be to
> enforce ordering of memory reads/writes when accessing cache-enabled memory
> that is shared between the CPU and a device.
> 
> It may also be noted that there is no fast_mb().  This is due to the fact
> that most architectures didn't seem to have a good way to do a full memory
> barrier quickly and so they usually resorted to an mb() for their smp_mb
> call.  As such there no point in adding a fast_mb() function if it is going
> to map to mb() for all architectures anyway.

I must confess that I still don't entirely understand the motivation.

Some problems in PowerPC barrier.h called out below.

							Thanx, Paul

> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Frederic Weisbecker <fweisbec@gmail.com>
> Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
> Cc: Michael Ellerman <michael@ellerman.id.au>
> Cc: Michael Neuling <mikey@neuling.org>
> Cc: Russell King <linux@arm.linux.org.uk>
> Cc: Geert Uytterhoeven <geert@linux-m68k.org>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---
>  Documentation/memory-barriers.txt   |   41 +++++++++++++++++++++++++++++++++++
>  arch/arm/include/asm/barrier.h      |    4 +++
>  arch/arm64/include/asm/barrier.h    |    3 +++
>  arch/ia64/include/asm/barrier.h     |    3 +++
>  arch/metag/include/asm/barrier.h    |   14 ++++++------
>  arch/powerpc/include/asm/barrier.h  |   22 +++++++++++--------
>  arch/s390/include/asm/barrier.h     |    2 ++
>  arch/sparc/include/asm/barrier_64.h |    3 +++
>  arch/x86/include/asm/barrier.h      |   11 ++++++---
>  arch/x86/um/asm/barrier.h           |   13 ++++++-----
>  include/asm-generic/barrier.h       |    8 +++++++
>  11 files changed, 98 insertions(+), 26 deletions(-)
> 
> diff --git a/Documentation/memory-barriers.txt b/Documentation/memory-barriers.txt
> index 22a969c..fe55dea 100644
> --- a/Documentation/memory-barriers.txt
> +++ b/Documentation/memory-barriers.txt
> @@ -1615,6 +1615,47 @@ There are some more advanced barrier functions:
>       operations" subsection for information on where to use these.
> 
> 
> + (*) fast_wmb();
> + (*) fast_rmb();
> +
> +     These are for use with memory based device I/O to guarantee the ordering
> +     of cache-enabled writes or reads with respect to other writes or reads
> +     to cache-enabled memory.
> +
> +     For example, consider a device driver that shares memory with a device
> +     and uses a descriptor status value to indicate if the descriptor belongs
> +     to the device or the CPU, and a doorbell to notify it when new
> +     descriptors are available:
> +
> +	if (desc->status != DEVICE_OWN) {
> +		/* do not read data until we own descriptor */
> +		fast_rmb();
> +
> +		/* read/modify data */
> +		read_data = desc->data;
> +		desc->data = write_data;
> +
> +		/* flush modifications before status update */
> +		fast_wmb();
> +
> +		/* assign ownership */
> +		desc->status = DEVICE_OWN;
> +
> +		/* force memory to sync before notifying device via MMIO */
> +		wmb();
> +
> +		/* notify device of new descriptors */
> +		writel(DESC_NOTIFY, doorbell);
> +	}
> +
> +     The fast_rmb() allows us guarantee the device has released ownership
> +     before we read the data from the descriptor, and he fast_wmb() allows
> +     us to guarantee the data is written to the descriptor before the device
> +     can see it now has ownership.  The wmb() is needed to guarantee that the
> +     cache-enabled memory writes have completed before attempting a write to
> +     the cache-inhibited MMIO region.
> +
> +
>  MMIO WRITE BARRIER
>  ------------------
> 
> diff --git a/arch/arm/include/asm/barrier.h b/arch/arm/include/asm/barrier.h
> index c6a3e73..c57903c 100644
> --- a/arch/arm/include/asm/barrier.h
> +++ b/arch/arm/include/asm/barrier.h
> @@ -43,10 +43,14 @@
>  #define mb()		do { dsb(); outer_sync(); } while (0)
>  #define rmb()		dsb()
>  #define wmb()		do { dsb(st); outer_sync(); } while (0)
> +#define fast_rmb()	dmb()
> +#define fast_wmb()	dmb(st)
>  #else
>  #define mb()		barrier()
>  #define rmb()		barrier()
>  #define wmb()		barrier()
> +#define fast_rmb()	barrier()
> +#define fast_wmb()	barrier()
>  #endif
> 
>  #ifndef CONFIG_SMP
> diff --git a/arch/arm64/include/asm/barrier.h b/arch/arm64/include/asm/barrier.h
> index 6389d60..3ca1a15 100644
> --- a/arch/arm64/include/asm/barrier.h
> +++ b/arch/arm64/include/asm/barrier.h
> @@ -32,6 +32,9 @@
>  #define rmb()		dsb(ld)
>  #define wmb()		dsb(st)
> 
> +#define fast_rmb()	dmb(ld)
> +#define fast_wmb()	dmb(st)
> +
>  #ifndef CONFIG_SMP
>  #define smp_mb()	barrier()
>  #define smp_rmb()	barrier()
> diff --git a/arch/ia64/include/asm/barrier.h b/arch/ia64/include/asm/barrier.h
> index e8fffb0..997f5b0 100644
> --- a/arch/ia64/include/asm/barrier.h
> +++ b/arch/ia64/include/asm/barrier.h
> @@ -39,6 +39,9 @@
>  #define rmb()		mb()
>  #define wmb()		mb()
> 
> +#define fast_rmb()	mb()
> +#define fast_wmb()	mb()
> +
>  #ifdef CONFIG_SMP
>  # define smp_mb()	mb()
>  #else
> diff --git a/arch/metag/include/asm/barrier.h b/arch/metag/include/asm/barrier.h
> index 6d8b8c9..edddb6d 100644
> --- a/arch/metag/include/asm/barrier.h
> +++ b/arch/metag/include/asm/barrier.h
> @@ -4,8 +4,6 @@
>  #include <asm/metag_mem.h>
> 
>  #define nop()		asm volatile ("NOP")
> -#define mb()		wmb()
> -#define rmb()		barrier()
> 
>  #ifdef CONFIG_METAG_META21
> 
> @@ -41,11 +39,13 @@ static inline void wr_fence(void)
> 
>  #endif /* !CONFIG_METAG_META21 */
> 
> -static inline void wmb(void)
> -{
> -	/* flush writes through the write combiner */
> -	wr_fence();
> -}
> +/* flush writes through the write combiner */
> +#define mb()		wr_fence()
> +#define rmb()		barrier()
> +#define wmb()		mb()
> +
> +#define fast_rmb()	rmb()
> +#define fast_wmb()	wmb()
> 
>  #ifndef CONFIG_SMP
>  #define fence()		do { } while (0)
> diff --git a/arch/powerpc/include/asm/barrier.h b/arch/powerpc/include/asm/barrier.h
> index cb6d66c..f480097 100644
> --- a/arch/powerpc/include/asm/barrier.h
> +++ b/arch/powerpc/include/asm/barrier.h
> @@ -36,22 +36,20 @@
> 
>  #define set_mb(var, value)	do { var = value; mb(); } while (0)
> 
> -#ifdef CONFIG_SMP
> -
>  #ifdef __SUBARCH_HAS_LWSYNC
>  #    define SMPWMB      LWSYNC
>  #else
>  #    define SMPWMB      eieio
>  #endif
> 
> -#define __lwsync()	__asm__ __volatile__ (stringify_in_c(LWSYNC) : : :"memory")
> +#define fast_rmb()	__asm__ __volatile__ (stringify_in_c(LWSYNC) : : :"memory")
> +#define fast_wmb()	__asm__ __volatile__ (stringify_in_c(SMPWMB) : : :"memory")
> 
> +#ifdef CONFIG_SMP
>  #define smp_mb()	mb()
> -#define smp_rmb()	__lwsync()
> -#define smp_wmb()	__asm__ __volatile__ (stringify_in_c(SMPWMB) : : :"memory")
> +#define smp_rmb()	fast_rmb()
> +#define smp_wmb()	fast_wmb()
>  #else
> -#define __lwsync()	barrier()
> -
>  #define smp_mb()	barrier()
>  #define smp_rmb()	barrier()
>  #define smp_wmb()	barrier()
> @@ -69,10 +67,16 @@
>  #define data_barrier(x)	\
>  	asm volatile("twi 0,%0,0; isync" : : "r" (x) : "memory");
> 
> +/*
> + * The use of smp_rmb() in these functions are actually meant to map from
> + * smp_rmb()->fast_rmb()->LWSYNC.  This way if smp is disabled then
> + * smp_rmb()->barrier(), or if the platform doesn't support lwsync it will
> + * map to the more heavy-weight sync.
> + */
>  #define smp_store_release(p, v)						\
>  do {									\
>  	compiletime_assert_atomic_type(*p);				\
> -	__lwsync();							\
> +	smp_rmb();							\

This is not good at all.  For smp_store_release(), we absolutely
must order prior loads and stores against the assignment on the following
line.  This is not something that smp_rmb() does, nor is it something
that smp_wmb() does.  Yes, it might happen to now, but this could easily
break in the future -- plus this change is extremely misleading.

The original __lwsync() is much more clear.

>  	ACCESS_ONCE(*p) = (v);						\
>  } while (0)
> 
> @@ -80,7 +84,7 @@ do {									\
>  ({									\
>  	typeof(*p) ___p1 = ACCESS_ONCE(*p);				\
>  	compiletime_assert_atomic_type(*p);				\
> -	__lwsync();							\
> +	smp_rmb();							\
>  	___p1;								\
>  })
> 
> diff --git a/arch/s390/include/asm/barrier.h b/arch/s390/include/asm/barrier.h
> index 33d191d..9a31301 100644
> --- a/arch/s390/include/asm/barrier.h
> +++ b/arch/s390/include/asm/barrier.h
> @@ -24,6 +24,8 @@
> 
>  #define rmb()				mb()
>  #define wmb()				mb()
> +#define fast_rmb()			rmb()
> +#define fast_wmb()			wmb()
>  #define smp_mb()			mb()
>  #define smp_rmb()			rmb()
>  #define smp_wmb()			wmb()
> diff --git a/arch/sparc/include/asm/barrier_64.h b/arch/sparc/include/asm/barrier_64.h
> index 6c974c0..eac2777 100644
> --- a/arch/sparc/include/asm/barrier_64.h
> +++ b/arch/sparc/include/asm/barrier_64.h
> @@ -37,6 +37,9 @@ do {	__asm__ __volatile__("ba,pt	%%xcc, 1f\n\t" \
>  #define rmb()	__asm__ __volatile__("":::"memory")
>  #define wmb()	__asm__ __volatile__("":::"memory")
> 
> +#define fast_rmb()	rmb()
> +#define fast_wmb()	wmb()
> +
>  #define set_mb(__var, __value) \
>  	do { __var = __value; membar_safe("#StoreLoad"); } while(0)
> 
> diff --git a/arch/x86/include/asm/barrier.h b/arch/x86/include/asm/barrier.h
> index 5238000..cf440e7 100644
> --- a/arch/x86/include/asm/barrier.h
> +++ b/arch/x86/include/asm/barrier.h
> @@ -24,13 +24,16 @@
>  #define wmb()	asm volatile("sfence" ::: "memory")
>  #endif
> 
> -#ifdef CONFIG_SMP
> -#define smp_mb()	mb()
>  #ifdef CONFIG_X86_PPRO_FENCE
> -# define smp_rmb()	rmb()
> +#define fast_rmb()	rmb()
>  #else
> -# define smp_rmb()	barrier()
> +#define fast_rmb()	barrier()
>  #endif
> +#define fast_wmb()	barrier()
> +
> +#ifdef CONFIG_SMP
> +#define smp_mb()	mb()
> +#define smp_rmb()	fast_rmb()
>  #define smp_wmb()	barrier()
>  #define set_mb(var, value) do { (void)xchg(&var, value); } while (0)
>  #else /* !SMP */
> diff --git a/arch/x86/um/asm/barrier.h b/arch/x86/um/asm/barrier.h
> index d6511d9..2c0405d 100644
> --- a/arch/x86/um/asm/barrier.h
> +++ b/arch/x86/um/asm/barrier.h
> @@ -29,17 +29,18 @@
> 
>  #endif /* CONFIG_X86_32 */
> 
> -#ifdef CONFIG_SMP
> -
> -#define smp_mb()	mb()
>  #ifdef CONFIG_X86_PPRO_FENCE
> -#define smp_rmb()	rmb()
> +#define fast_rmb()	rmb()
>  #else /* CONFIG_X86_PPRO_FENCE */
> -#define smp_rmb()	barrier()
> +#define fast_rmb()	barrier()
>  #endif /* CONFIG_X86_PPRO_FENCE */
> +#define fast_wmb()	barrier()
> 
> -#define smp_wmb()	barrier()
> +#ifdef CONFIG_SMP
> 
> +#define smp_mb()	mb()
> +#define smp_rmb()	fast_rmb()
> +#define smp_wmb()	fast_wmb()
>  #define set_mb(var, value) do { (void)xchg(&var, value); } while (0)
> 
>  #else /* CONFIG_SMP */
> diff --git a/include/asm-generic/barrier.h b/include/asm-generic/barrier.h
> index 1402fa8..c1d60b9 100644
> --- a/include/asm-generic/barrier.h
> +++ b/include/asm-generic/barrier.h
> @@ -42,6 +42,14 @@
>  #define wmb()	mb()
>  #endif
> 
> +#ifndef fast_rmb
> +#define fast_rmb()	rmb()
> +#endif
> +
> +#ifndef fast_wmb
> +#define fast_wmb()	wmb()
> +#endif
> +
>  #ifndef read_barrier_depends
>  #define read_barrier_depends()		do { } while (0)
>  #endif
> 
