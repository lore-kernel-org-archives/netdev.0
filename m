From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH v7 resubmit 2/4] arch: Add lightweight memory
 barriers dma_rmb() and dma_wmb()
Date: Thu, 11 Dec 2014 15:02:06 -0800
Message-ID: <20141211230206.25464.76276.stgit@ahduyck-server>
References: <20141211225250.25464.30291.stgit@ahduyck-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: mathieu.desnoyers@polymtl.ca, peterz@infradead.org,
	benh@kernel.crashing.org, heiko.carstens@de.ibm.com,
	mingo@kernel.org, linux-arch@vger.kernel.org, mikey@neuling.org,
	linux@arm.linux.org.uk, donald.c.skidmore@intel.com,
	matthew.vick@intel.com, geert@linux-m68k.org,
	jeffrey.t.kirsher@intel.com, romieu@fr.zoreil.com,
	paulmck@linux.vnet.ibm.com, nic_swsd@realtek.com, arnd@arndb.de,
	will.deacon@arm.com, michael@ellerman.id.au, tony.luck@intel.com,
	torvalds@linux-foundation.org, oleg@redhat.com,
	schwidefsky@de.ibm.com, fweisbec@gmail.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141211225250.25464.30291.stgit@ahduyck-server>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a number of situations where the mandatory barriers rmb() and
wmb() are used to order memory/memory operations in the device drivers
and those barriers are much heavier than they actually need to be.  For
example in the case of PowerPC wmb() calls the heavy-weight sync
instruction when for coherent memory operations all that is really needed
is an lsync or eieio instruction.

This commit adds a coherent only version of the mandatory memory barriers
rmb() and wmb().  In most cases this should result in the barrier being the
same as the SMP barriers for the SMP case, however in some cases we use a
barrier that is somewhere in between rmb() and smp_rmb().  For example on
ARM the rmb barriers break down as follows:

  Barrier   Call     Explanation
  --------- -------- ----------------------------------
  rmb()     dsb()    Data synchronization barrier - system
  dma_rmb() dmb(osh) data memory barrier - outer sharable
  smp_rmb() dmb(ish) data memory barrier - inner sharable

These new barriers are not as safe as the standard rmb() and wmb().
Specifically they do not guarantee ordering between coherent and incoherent
memories.  The primary use case for these would be to enforce ordering of
reads and writes when accessing coherent memory that is shared between the
CPU and a device.

It may also be noted that there is no dma_mb().  Most architectures don't
provide a good mechanism for performing a coherent only full barrier without
resorting to the same mechanism used in mb().  As such there isn't much to
be gained in trying to define such a function.

Cc: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: Michael Ellerman <michael@ellerman.id.au>
Cc: Michael Neuling <mikey@neuling.org>
Cc: Russell King <linux@arm.linux.org.uk>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: David Miller <davem@davemloft.net>
Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Acked-by: Will Deacon <will.deacon@arm.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 Documentation/memory-barriers.txt   |   42 +++++++++++++++++++++++++++++++++++
 arch/arm/include/asm/barrier.h      |    4 +++
 arch/arm64/include/asm/barrier.h    |    3 +++
 arch/ia64/include/asm/barrier.h     |    3 +++
 arch/metag/include/asm/barrier.h    |   14 ++++++------
 arch/mips/include/asm/barrier.h     |    9 ++++----
 arch/powerpc/include/asm/barrier.h  |   13 +++++++----
 arch/s390/include/asm/barrier.h     |    2 ++
 arch/sparc/include/asm/barrier_64.h |    3 +++
 arch/x86/include/asm/barrier.h      |   11 ++++++---
 arch/x86/um/asm/barrier.h           |   13 ++++++-----
 include/asm-generic/barrier.h       |    8 +++++++
 12 files changed, 99 insertions(+), 26 deletions(-)

diff --git a/Documentation/memory-barriers.txt b/Documentation/memory-barriers.txt
index 22a969c..e5d5732 100644
--- a/Documentation/memory-barriers.txt
+++ b/Documentation/memory-barriers.txt
@@ -1615,6 +1615,48 @@ There are some more advanced barrier functions:
      operations" subsection for information on where to use these.
 
 
+ (*) dma_wmb();
+ (*) dma_rmb();
+
+     These are for use with consistent memory to guarantee the ordering
+     of writes or reads of shared memory accessible to both the CPU and a
+     DMA capable device.
+
+     For example, consider a device driver that shares memory with a device
+     and uses a descriptor status value to indicate if the descriptor belongs
+     to the device or the CPU, and a doorbell to notify it when new
+     descriptors are available:
+
+	if (desc->status != DEVICE_OWN) {
+		/* do not read data until we own descriptor */
+		dma_rmb();
+
+		/* read/modify data */
+		read_data = desc->data;
+		desc->data = write_data;
+
+		/* flush modifications before status update */
+		dma_wmb();
+
+		/* assign ownership */
+		desc->status = DEVICE_OWN;
+
+		/* force memory to sync before notifying device via MMIO */
+		wmb();
+
+		/* notify device of new descriptors */
+		writel(DESC_NOTIFY, doorbell);
+	}
+
+     The dma_rmb() allows us guarantee the device has released ownership
+     before we read the data from the descriptor, and he dma_wmb() allows
+     us to guarantee the data is written to the descriptor before the device
+     can see it now has ownership.  The wmb() is needed to guarantee that the
+     cache coherent memory writes have completed before attempting a write to
+     the cache incoherent MMIO region.
+
+     See Documentation/DMA-API.txt for more information on consistent memory.
+
 MMIO WRITE BARRIER
 ------------------
 
diff --git a/arch/arm/include/asm/barrier.h b/arch/arm/include/asm/barrier.h
index c6a3e73..d2f81e6 100644
--- a/arch/arm/include/asm/barrier.h
+++ b/arch/arm/include/asm/barrier.h
@@ -43,10 +43,14 @@
 #define mb()		do { dsb(); outer_sync(); } while (0)
 #define rmb()		dsb()
 #define wmb()		do { dsb(st); outer_sync(); } while (0)
+#define dma_rmb()	dmb(osh)
+#define dma_wmb()	dmb(oshst)
 #else
 #define mb()		barrier()
 #define rmb()		barrier()
 #define wmb()		barrier()
+#define dma_rmb()	barrier()
+#define dma_wmb()	barrier()
 #endif
 
 #ifndef CONFIG_SMP
diff --git a/arch/arm64/include/asm/barrier.h b/arch/arm64/include/asm/barrier.h
index 6389d60..a5abb00 100644
--- a/arch/arm64/include/asm/barrier.h
+++ b/arch/arm64/include/asm/barrier.h
@@ -32,6 +32,9 @@
 #define rmb()		dsb(ld)
 #define wmb()		dsb(st)
 
+#define dma_rmb()	dmb(oshld)
+#define dma_wmb()	dmb(oshst)
+
 #ifndef CONFIG_SMP
 #define smp_mb()	barrier()
 #define smp_rmb()	barrier()
diff --git a/arch/ia64/include/asm/barrier.h b/arch/ia64/include/asm/barrier.h
index e8fffb0..f6769eb 100644
--- a/arch/ia64/include/asm/barrier.h
+++ b/arch/ia64/include/asm/barrier.h
@@ -39,6 +39,9 @@
 #define rmb()		mb()
 #define wmb()		mb()
 
+#define dma_rmb()	mb()
+#define dma_wmb()	mb()
+
 #ifdef CONFIG_SMP
 # define smp_mb()	mb()
 #else
diff --git a/arch/metag/include/asm/barrier.h b/arch/metag/include/asm/barrier.h
index 6d8b8c9..d703d8e 100644
--- a/arch/metag/include/asm/barrier.h
+++ b/arch/metag/include/asm/barrier.h
@@ -4,8 +4,6 @@
 #include <asm/metag_mem.h>
 
 #define nop()		asm volatile ("NOP")
-#define mb()		wmb()
-#define rmb()		barrier()
 
 #ifdef CONFIG_METAG_META21
 
@@ -41,11 +39,13 @@ static inline void wr_fence(void)
 
 #endif /* !CONFIG_METAG_META21 */
 
-static inline void wmb(void)
-{
-	/* flush writes through the write combiner */
-	wr_fence();
-}
+/* flush writes through the write combiner */
+#define mb()		wr_fence()
+#define rmb()		barrier()
+#define wmb()		mb()
+
+#define dma_rmb()	rmb()
+#define dma_wmb()	wmb()
 
 #ifndef CONFIG_SMP
 #define fence()		do { } while (0)
diff --git a/arch/mips/include/asm/barrier.h b/arch/mips/include/asm/barrier.h
index 3d69aa8..2b8bbbc 100644
--- a/arch/mips/include/asm/barrier.h
+++ b/arch/mips/include/asm/barrier.h
@@ -75,20 +75,21 @@
 
 #include <asm/wbflush.h>
 
-#define wmb()		fast_wmb()
-#define rmb()		fast_rmb()
 #define mb()		wbflush()
 #define iob()		wbflush()
 
 #else /* !CONFIG_CPU_HAS_WB */
 
-#define wmb()		fast_wmb()
-#define rmb()		fast_rmb()
 #define mb()		fast_mb()
 #define iob()		fast_iob()
 
 #endif /* !CONFIG_CPU_HAS_WB */
 
+#define wmb()		fast_wmb()
+#define rmb()		fast_rmb()
+#define dma_wmb()	fast_wmb()
+#define dma_rmb()	fast_rmb()
+
 #if defined(CONFIG_WEAK_ORDERING) && defined(CONFIG_SMP)
 # ifdef CONFIG_CPU_CAVIUM_OCTEON
 #  define smp_mb()	__sync()
diff --git a/arch/powerpc/include/asm/barrier.h b/arch/powerpc/include/asm/barrier.h
index cb6d66c..a3bf5be 100644
--- a/arch/powerpc/include/asm/barrier.h
+++ b/arch/powerpc/include/asm/barrier.h
@@ -36,8 +36,6 @@
 
 #define set_mb(var, value)	do { var = value; mb(); } while (0)
 
-#ifdef CONFIG_SMP
-
 #ifdef __SUBARCH_HAS_LWSYNC
 #    define SMPWMB      LWSYNC
 #else
@@ -45,12 +43,17 @@
 #endif
 
 #define __lwsync()	__asm__ __volatile__ (stringify_in_c(LWSYNC) : : :"memory")
+#define dma_rmb()	__lwsync()
+#define dma_wmb()	__asm__ __volatile__ (stringify_in_c(SMPWMB) : : :"memory")
+
+#ifdef CONFIG_SMP
+#define smp_lwsync()	__lwsync()
 
 #define smp_mb()	mb()
 #define smp_rmb()	__lwsync()
 #define smp_wmb()	__asm__ __volatile__ (stringify_in_c(SMPWMB) : : :"memory")
 #else
-#define __lwsync()	barrier()
+#define smp_lwsync()	barrier()
 
 #define smp_mb()	barrier()
 #define smp_rmb()	barrier()
@@ -72,7 +75,7 @@
 #define smp_store_release(p, v)						\
 do {									\
 	compiletime_assert_atomic_type(*p);				\
-	__lwsync();							\
+	smp_lwsync();							\
 	ACCESS_ONCE(*p) = (v);						\
 } while (0)
 
@@ -80,7 +83,7 @@ do {									\
 ({									\
 	typeof(*p) ___p1 = ACCESS_ONCE(*p);				\
 	compiletime_assert_atomic_type(*p);				\
-	__lwsync();							\
+	smp_lwsync();							\
 	___p1;								\
 })
 
diff --git a/arch/s390/include/asm/barrier.h b/arch/s390/include/asm/barrier.h
index 33d191d..8d72471 100644
--- a/arch/s390/include/asm/barrier.h
+++ b/arch/s390/include/asm/barrier.h
@@ -24,6 +24,8 @@
 
 #define rmb()				mb()
 #define wmb()				mb()
+#define dma_rmb()			rmb()
+#define dma_wmb()			wmb()
 #define smp_mb()			mb()
 #define smp_rmb()			rmb()
 #define smp_wmb()			wmb()
diff --git a/arch/sparc/include/asm/barrier_64.h b/arch/sparc/include/asm/barrier_64.h
index 6c974c0..7664894 100644
--- a/arch/sparc/include/asm/barrier_64.h
+++ b/arch/sparc/include/asm/barrier_64.h
@@ -37,6 +37,9 @@ do {	__asm__ __volatile__("ba,pt	%%xcc, 1f\n\t" \
 #define rmb()	__asm__ __volatile__("":::"memory")
 #define wmb()	__asm__ __volatile__("":::"memory")
 
+#define dma_rmb()	rmb()
+#define dma_wmb()	wmb()
+
 #define set_mb(__var, __value) \
 	do { __var = __value; membar_safe("#StoreLoad"); } while(0)
 
diff --git a/arch/x86/include/asm/barrier.h b/arch/x86/include/asm/barrier.h
index 5238000..2ab1eb3 100644
--- a/arch/x86/include/asm/barrier.h
+++ b/arch/x86/include/asm/barrier.h
@@ -24,13 +24,16 @@
 #define wmb()	asm volatile("sfence" ::: "memory")
 #endif
 
-#ifdef CONFIG_SMP
-#define smp_mb()	mb()
 #ifdef CONFIG_X86_PPRO_FENCE
-# define smp_rmb()	rmb()
+#define dma_rmb()	rmb()
 #else
-# define smp_rmb()	barrier()
+#define dma_rmb()	barrier()
 #endif
+#define dma_wmb()	barrier()
+
+#ifdef CONFIG_SMP
+#define smp_mb()	mb()
+#define smp_rmb()	dma_rmb()
 #define smp_wmb()	barrier()
 #define set_mb(var, value) do { (void)xchg(&var, value); } while (0)
 #else /* !SMP */
diff --git a/arch/x86/um/asm/barrier.h b/arch/x86/um/asm/barrier.h
index d6511d9..2d7d9a1 100644
--- a/arch/x86/um/asm/barrier.h
+++ b/arch/x86/um/asm/barrier.h
@@ -29,17 +29,18 @@
 
 #endif /* CONFIG_X86_32 */
 
-#ifdef CONFIG_SMP
-
-#define smp_mb()	mb()
 #ifdef CONFIG_X86_PPRO_FENCE
-#define smp_rmb()	rmb()
+#define dma_rmb()	rmb()
 #else /* CONFIG_X86_PPRO_FENCE */
-#define smp_rmb()	barrier()
+#define dma_rmb()	barrier()
 #endif /* CONFIG_X86_PPRO_FENCE */
+#define dma_wmb()	barrier()
 
-#define smp_wmb()	barrier()
+#ifdef CONFIG_SMP
 
+#define smp_mb()	mb()
+#define smp_rmb()	dma_rmb()
+#define smp_wmb()	barrier()
 #define set_mb(var, value) do { (void)xchg(&var, value); } while (0)
 
 #else /* CONFIG_SMP */
diff --git a/include/asm-generic/barrier.h b/include/asm-generic/barrier.h
index 1402fa8..f5c40b0 100644
--- a/include/asm-generic/barrier.h
+++ b/include/asm-generic/barrier.h
@@ -42,6 +42,14 @@
 #define wmb()	mb()
 #endif
 
+#ifndef dma_rmb
+#define dma_rmb()	rmb()
+#endif
+
+#ifndef dma_wmb
+#define dma_wmb()	wmb()
+#endif
+
 #ifndef read_barrier_depends
 #define read_barrier_depends()		do { } while (0)
 #endif
