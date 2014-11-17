From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/4] arch: Add lightweight memory barriers fast_rmb() and
 fast_wmb()
Date: Mon, 17 Nov 2014 15:17:41 -0800
Message-ID: <20141117231741.GI5050@linux.vnet.ibm.com>
References: <20141117171005.22333.96544.stgit@ahduyck-server>
 <20141117171812.22333.90395.stgit@ahduyck-server>
 <20141117201823.GD5050@linux.vnet.ibm.com>
 <546A649D.2000007@redhat.com>
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
In-Reply-To: <546A649D.2000007@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 17, 2014 at 01:11:57PM -0800, Alexander Duyck wrote:
> On 11/17/2014 12:18 PM, Paul E. McKenney wrote:
> >On Mon, Nov 17, 2014 at 09:18:13AM -0800, Alexander Duyck wrote:
> >>There are a number of situations where the mandatory barriers rmb() and
> >>wmb() are used to order memory/memory operations in the device drivers
> >>and those barriers are much heavier than they actually need to be.  For
> >>example in the case of PowerPC wmb() calls the heavy-weight sync
> >>instruction when for memory/memory operations all that is really needed is
> >>an lsync or eieio instruction.
> >
> >Is this still the case if one of the memory operations is MMIO?  Last
> >I knew, it was not.
> 
> This barrier is not meant for use in MMIO operations, for that you
> still need a full barrier as I call out in the documentation
> section. What the barrier does is allow for a lightweight barrier
> for accesses to coherent system memory. So for example many device
> drivers have to perform a read of the descriptor to see if the
> device is done with it. We need an rmb() following that check to
> prevent any other accesses.
> 
> Right now on x86 that rmb() becomes an lfence instruction and is
> quite expensive, and as it turns out we don't need it since the x86
> doesn't reorder reads. The same kind of thing applies to PowerPC,
> only in that case we use a sync when what we really need is a
> lwsync.

Would it make sense to have a memory barrier that enforced the
non-store-buffer orderings, that is prior reads before later
reads and writes and prior writes before later writes?  This was
discussed earlier this year ((http://lwn.net/Articles/586838/,
https://lwn.net/Articles/588300/).  If I recall correctly, one of
the biggest obstacles was the name.  ;-)

> >>This commit adds a fast (and loose) version of the mandatory memory
> >>barriers rmb() and wmb().  The prefix to the name is actually based on the
> >>version of the functions that already exist in the mips and tile trees.
> >>However I thought it applicable since it gets at what we are trying to
> >>accomplish with these barriers and somethat implies their risky nature.
> >>
> >>These new barriers are not as safe as the standard rmb() and wmb().
> >>Specifically they do not guarantee ordering between cache-enabled and
> >>cache-inhibited memories.  The primary use case for these would be to
> >>enforce ordering of memory reads/writes when accessing cache-enabled memory
> >>that is shared between the CPU and a device.
> >>
> >>It may also be noted that there is no fast_mb().  This is due to the fact
> >>that most architectures didn't seem to have a good way to do a full memory
> >>barrier quickly and so they usually resorted to an mb() for their smp_mb
> >>call.  As such there no point in adding a fast_mb() function if it is going
> >>to map to mb() for all architectures anyway.
> >
> >I must confess that I still don't entirely understand the motivation.
> 
> The motivation is to provide finer grained barriers. So this
> provides an in-between that allows us to "choose the right hammer".
> In the case of PowerPC it is the difference between sync/lwsync, on
> ARM it is dsb()/dmb(), and on x86 it is lfence/barrier().

Ah, so ARM will motivate a fast_wmb(), given its instruction set.

> >Some problems in PowerPC barrier.h called out below.
> >
> >							Thanx, Paul
> >
> 
> <snip>
> 
> >>diff --git a/Documentation/memory-barriers.txt b/Documentation/memory-barriers.txt
> >>index 22a969c..fe55dea 100644
> >>--- a/Documentation/memory-barriers.txt
> >>+++ b/Documentation/memory-barriers.txt
> >>@@ -1615,6 +1615,47 @@ There are some more advanced barrier functions:
> >>       operations" subsection for information on where to use these.
> >>
> >>
> >>+ (*) fast_wmb();
> >>+ (*) fast_rmb();
> >>+
> >>+     These are for use with memory based device I/O to guarantee the ordering
> >>+     of cache-enabled writes or reads with respect to other writes or reads
> >>+     to cache-enabled memory.
> >>+
> >>+     For example, consider a device driver that shares memory with a device
> >>+     and uses a descriptor status value to indicate if the descriptor belongs
> >>+     to the device or the CPU, and a doorbell to notify it when new
> >>+     descriptors are available:
> >>+
> >>+	if (desc->status != DEVICE_OWN) {
> >>+		/* do not read data until we own descriptor */
> >>+		fast_rmb();
> >>+
> >>+		/* read/modify data */
> >>+		read_data = desc->data;
> >>+		desc->data = write_data;
> >>+
> >>+		/* flush modifications before status update */
> >>+		fast_wmb();
> >>+
> >>+		/* assign ownership */
> >>+		desc->status = DEVICE_OWN;
> >>+
> >>+		/* force memory to sync before notifying device via MMIO */
> >>+		wmb();
> >>+
> >>+		/* notify device of new descriptors */
> >>+		writel(DESC_NOTIFY, doorbell);
> >>+	}
> >>+
> >>+     The fast_rmb() allows us guarantee the device has released ownership
> >>+     before we read the data from the descriptor, and he fast_wmb() allows
> >>+     us to guarantee the data is written to the descriptor before the device
> >>+     can see it now has ownership.  The wmb() is needed to guarantee that the
> >>+     cache-enabled memory writes have completed before attempting a write to
> >>+     the cache-inhibited MMIO region.
> >>+
> >>+
> >>  MMIO WRITE BARRIER
> >>  ------------------
> 
> The general idea is that the device/CPU follow acquire/release style
> semantics and we need the lightweight barriers to enforce ordering
> to prevent us from accessing the descriptors during those periods
> where we do not own them.  As the example shows we still need a full
> barrier when going between MMIO and standard memory.  Hopefully that
> is what is conveyed in the documentation bits I have above.

Thank you for the clarification.

> <snip>
> 
> >>diff --git a/arch/powerpc/include/asm/barrier.h b/arch/powerpc/include/asm/barrier.h
> >>index cb6d66c..f480097 100644
> >>--- a/arch/powerpc/include/asm/barrier.h
> >>+++ b/arch/powerpc/include/asm/barrier.h
> >>@@ -36,22 +36,20 @@
> >>
> >>  #define set_mb(var, value)	do { var = value; mb(); } while (0)
> >>
> >>-#ifdef CONFIG_SMP
> >>-
> >>  #ifdef __SUBARCH_HAS_LWSYNC
> >>  #    define SMPWMB      LWSYNC
> >>  #else
> >>  #    define SMPWMB      eieio
> >>  #endif
> >>
> >>-#define __lwsync()	__asm__ __volatile__ (stringify_in_c(LWSYNC) : : :"memory")
> >>+#define fast_rmb()	__asm__ __volatile__ (stringify_in_c(LWSYNC) : : :"memory")
> >>+#define fast_wmb()	__asm__ __volatile__ (stringify_in_c(SMPWMB) : : :"memory")
> >>
> >>+#ifdef CONFIG_SMP
> >>  #define smp_mb()	mb()
> >>-#define smp_rmb()	__lwsync()
> >>-#define smp_wmb()	__asm__ __volatile__ (stringify_in_c(SMPWMB) : : :"memory")
> >>+#define smp_rmb()	fast_rmb()
> >>+#define smp_wmb()	fast_wmb()
> >>  #else
> >>-#define __lwsync()	barrier()
> >>-
> >>  #define smp_mb()	barrier()
> >>  #define smp_rmb()	barrier()
> >>  #define smp_wmb()	barrier()
> >>@@ -69,10 +67,16 @@
> >>  #define data_barrier(x)	\
> >>  	asm volatile("twi 0,%0,0; isync" : : "r" (x) : "memory");
> >>
> >>+/*
> >>+ * The use of smp_rmb() in these functions are actually meant to map from
> >>+ * smp_rmb()->fast_rmb()->LWSYNC.  This way if smp is disabled then
> >>+ * smp_rmb()->barrier(), or if the platform doesn't support lwsync it will
> >>+ * map to the more heavy-weight sync.
> >>+ */
> >>  #define smp_store_release(p, v)						\
> >>  do {									\
> >>  	compiletime_assert_atomic_type(*p);				\
> >>-	__lwsync();							\
> >>+	smp_rmb();							\
> >
> >This is not good at all.  For smp_store_release(), we absolutely
> >must order prior loads and stores against the assignment on the following
> >line.  This is not something that smp_rmb() does, nor is it something
> >that smp_wmb() does.  Yes, it might happen to now, but this could easily
> >break in the future -- plus this change is extremely misleading.
> >
> >The original __lwsync() is much more clear.
> 
> The problem I had with __lwsync is that it really wasn't all that
> clear. It was the lwsync instruction if SMP was enabled, otherwise
> it was just a barrier call. What I did is move the definition of
> __lwsync in the SMP case into fast_rmb, which in turn is accessed by
> smp_rmb. I tried to make this clear in the comment just above the
> two calls. The resultant assembly code should be exactly the same.
> 
> What I could do is have it added back as a smp_lwsync if that works
> for you. That way there is something there to give you a hint that
> it becomes a barrier() call as soon as SMP is disabled.

An smp_lwsync() would be a great improvement!

							Thanx, Paul
