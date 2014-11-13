From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [PATCH 1/3] arch: Introduce load_acquire() and store_release()
Date: Thu, 13 Nov 2014 11:27:23 -0800
Message-ID: <20141113192723.12579.25343.stgit@ahduyck-server>
References: <20141113191250.12579.19694.stgit@ahduyck-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: mikey@neuling.org, tony.luck@intel.com,
	mathieu.desnoyers@polymtl.ca, donald.c.skidmore@intel.com,
	peterz@infradead.org, benh@kernel.crashing.org,
	heiko.carstens@de.ibm.com, oleg@redhat.com, will.deacon@arm.com,
	davem@davemloft.net, michael@ellerman.id.au,
	matthew.vick@intel.com, nic_swsd@realtek.com, geert@linux-m68k.org,
	jeffrey.t.kirsher@intel.com, fweisbec@gmail.com,
	schwidefsky@de.ibm.com, linux@arm.linux.org.uk,
	paulmck@linux.vnet.ibm.com, torvalds@linux-foundation.org,
	mingo@kernel.org
To: linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141113191250.12579.19694.stgit@ahduyck-server>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is common for device drivers to make use of acquire/release semantics
when dealing with descriptors stored in device memory.  On reviewing the
documentation and code for smp_load_acquire() and smp_store_release() as
well as reviewing an IBM website that goes over the use of PowerPC barriers
at http://www.ibm.com/developerworks/systems/articles/powerpc.html it
occurred to me that the same code could likely be applied to device drivers.

As a result this patch introduces load_acquire() and store_release().  The
load_acquire() function can be used in the place of situations where a test
for ownership must be followed by a memory barrier.  The below example is
from ixgbe:

	if (!rx_desc->wb.upper.status_error)
		break;

	/* This memory barrier is needed to keep us from reading
	 * any other fields out of the rx_desc until we know the
	 * descriptor has been written back
	 */
	rmb();

With load_acquire() this can be changed to:

	if (!load_acquire(&rx_desc->wb.upper.status_error))
		break;

A similar change can be made in the release path of many drivers.  For
example in the Realtek r8169 driver there are a number of flows that
consist of something like the following:

	wmb();

	status = opts[0] | len | (RingEnd * !((entry + 1) % NUM_TX_DESC));
	txd->opts1 = cpu_to_le32(status);

	tp->cur_tx += frags + 1;

	wmb();

With store_release() this can be changed to the following:

	status = opts[0] | len | (RingEnd * !((entry + 1) % NUM_TX_DESC));
	store_release(&txd->opts1, cpu_to_le32(status));

	tp->cur_tx += frags + 1;

	wmb();

The resulting assembler code generated as a result can be significantly
less expensive on architectures such as x86 and s390 that support strong
ordering.  On architectures that are able to use different primitives than
their rmb/wmb() such as powerpc, ia64, and arm64 we should see gains as we
are able to use less expensive barriers, and for other architectures we end
up using a mb() which may come at the same amount of overhead or more than
a rmb/wmb() as we must ensure Load/Store ordering.

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
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
Cc: Will Deacon <will.deacon@arm.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 arch/arm/include/asm/barrier.h      |   15 +++++++++
 arch/arm64/include/asm/barrier.h    |   59 ++++++++++++++++++-----------------
 arch/ia64/include/asm/barrier.h     |    7 +++-
 arch/metag/include/asm/barrier.h    |   15 +++++++++
 arch/mips/include/asm/barrier.h     |   15 +++++++++
 arch/powerpc/include/asm/barrier.h  |   24 +++++++++++---
 arch/s390/include/asm/barrier.h     |    7 +++-
 arch/sparc/include/asm/barrier_64.h |    6 ++--
 arch/x86/include/asm/barrier.h      |   22 ++++++++++++-
 include/asm-generic/barrier.h       |   15 +++++++++
 10 files changed, 144 insertions(+), 41 deletions(-)

diff --git a/arch/arm/include/asm/barrier.h b/arch/arm/include/asm/barrier.h
index c6a3e73..bbdcd34 100644
--- a/arch/arm/include/asm/barrier.h
+++ b/arch/arm/include/asm/barrier.h
@@ -59,6 +59,21 @@
 #define smp_wmb()	dmb(ishst)
 #endif
 
+#define store_release(p, v)						\
+do {									\
+	compiletime_assert_atomic_type(*p);				\
+	mb();								\
+	ACCESS_ONCE(*p) = (v);						\
+} while (0)
+
+#define load_acquire(p)							\
+({									\
+	typeof(*p) ___p1 = ACCESS_ONCE(*p);				\
+	compiletime_assert_atomic_type(*p);				\
+	mb();								\
+	___p1;								\
+})
+
 #define smp_store_release(p, v)						\
 do {									\
 	compiletime_assert_atomic_type(*p);				\
diff --git a/arch/arm64/include/asm/barrier.h b/arch/arm64/include/asm/barrier.h
index 6389d60..c91571c 100644
--- a/arch/arm64/include/asm/barrier.h
+++ b/arch/arm64/include/asm/barrier.h
@@ -32,33 +32,7 @@
 #define rmb()		dsb(ld)
 #define wmb()		dsb(st)
 
-#ifndef CONFIG_SMP
-#define smp_mb()	barrier()
-#define smp_rmb()	barrier()
-#define smp_wmb()	barrier()
-
-#define smp_store_release(p, v)						\
-do {									\
-	compiletime_assert_atomic_type(*p);				\
-	barrier();							\
-	ACCESS_ONCE(*p) = (v);						\
-} while (0)
-
-#define smp_load_acquire(p)						\
-({									\
-	typeof(*p) ___p1 = ACCESS_ONCE(*p);				\
-	compiletime_assert_atomic_type(*p);				\
-	barrier();							\
-	___p1;								\
-})
-
-#else
-
-#define smp_mb()	dmb(ish)
-#define smp_rmb()	dmb(ishld)
-#define smp_wmb()	dmb(ishst)
-
-#define smp_store_release(p, v)						\
+#define store_release(p, v)						\
 do {									\
 	compiletime_assert_atomic_type(*p);				\
 	switch (sizeof(*p)) {						\
@@ -73,7 +47,7 @@ do {									\
 	}								\
 } while (0)
 
-#define smp_load_acquire(p)						\
+#define load_acquire(p)							\
 ({									\
 	typeof(*p) ___p1;						\
 	compiletime_assert_atomic_type(*p);				\
@@ -90,6 +64,35 @@ do {									\
 	___p1;								\
 })
 
+#ifndef CONFIG_SMP
+#define smp_mb()	barrier()
+#define smp_rmb()	barrier()
+#define smp_wmb()	barrier()
+
+#define smp_store_release(p, v)						\
+do {									\
+	compiletime_assert_atomic_type(*p);				\
+	barrier();							\
+	ACCESS_ONCE(*p) = (v);						\
+} while (0)
+
+#define smp_load_acquire(p)						\
+({									\
+	typeof(*p) ___p1 = ACCESS_ONCE(*p);				\
+	compiletime_assert_atomic_type(*p);				\
+	barrier();							\
+	___p1;								\
+})
+
+#else
+
+#define smp_mb()	dmb(ish)
+#define smp_rmb()	dmb(ishld)
+#define smp_wmb()	dmb(ishst)
+
+#define smp_store_release(p, v)	store_release(p, v)
+#define smp_load_acquire(p)	load_acquire(p)
+
 #endif
 
 #define read_barrier_depends()		do { } while(0)
diff --git a/arch/ia64/include/asm/barrier.h b/arch/ia64/include/asm/barrier.h
index a48957c..d7fe208 100644
--- a/arch/ia64/include/asm/barrier.h
+++ b/arch/ia64/include/asm/barrier.h
@@ -63,14 +63,14 @@
  * need for asm trickery!
  */
 
-#define smp_store_release(p, v)						\
+#define store_release(p, v)						\
 do {									\
 	compiletime_assert_atomic_type(*p);				\
 	barrier();							\
 	ACCESS_ONCE(*p) = (v);						\
 } while (0)
 
-#define smp_load_acquire(p)						\
+#define load_acquire(p)						\
 ({									\
 	typeof(*p) ___p1 = ACCESS_ONCE(*p);				\
 	compiletime_assert_atomic_type(*p);				\
@@ -78,6 +78,9 @@ do {									\
 	___p1;								\
 })
 
+#define smp_store_release(p, v)	store_release(p, v)
+#define smp_load_acquire(p)	load_acquire(p)
+
 /*
  * XXX check on this ---I suspect what Linus really wants here is
  * acquire vs release semantics but we can't discuss this stuff with
diff --git a/arch/metag/include/asm/barrier.h b/arch/metag/include/asm/barrier.h
index c7591e8..9beb687 100644
--- a/arch/metag/include/asm/barrier.h
+++ b/arch/metag/include/asm/barrier.h
@@ -85,6 +85,21 @@ static inline void fence(void)
 #define smp_read_barrier_depends()     do { } while (0)
 #define set_mb(var, value) do { var = value; smp_mb(); } while (0)
 
+#define store_release(p, v)						\
+do {									\
+	compiletime_assert_atomic_type(*p);				\
+	mb();								\
+	ACCESS_ONCE(*p) = (v);						\
+} while (0)
+
+#define load_acquire(p)							\
+({									\
+	typeof(*p) ___p1 = ACCESS_ONCE(*p);				\
+	compiletime_assert_atomic_type(*p);				\
+	mb();								\
+	___p1;								\
+})
+
 #define smp_store_release(p, v)						\
 do {									\
 	compiletime_assert_atomic_type(*p);				\
diff --git a/arch/mips/include/asm/barrier.h b/arch/mips/include/asm/barrier.h
index d0101dd..fc7323c 100644
--- a/arch/mips/include/asm/barrier.h
+++ b/arch/mips/include/asm/barrier.h
@@ -180,6 +180,21 @@
 #define nudge_writes() mb()
 #endif
 
+#define store_release(p, v)						\
+do {									\
+	compiletime_assert_atomic_type(*p);				\
+	mb();								\
+	ACCESS_ONCE(*p) = (v);						\
+} while (0)
+
+#define load_acquire(p)							\
+({									\
+	typeof(*p) ___p1 = ACCESS_ONCE(*p);				\
+	compiletime_assert_atomic_type(*p);				\
+	mb();								\
+	___p1;								\
+})
+
 #define smp_store_release(p, v)						\
 do {									\
 	compiletime_assert_atomic_type(*p);				\
diff --git a/arch/powerpc/include/asm/barrier.h b/arch/powerpc/include/asm/barrier.h
index bab79a1..f2a0d73 100644
--- a/arch/powerpc/include/asm/barrier.h
+++ b/arch/powerpc/include/asm/barrier.h
@@ -37,6 +37,23 @@
 
 #define set_mb(var, value)	do { var = value; mb(); } while (0)
 
+#define __lwsync() __asm__ __volatile__ (stringify_in_c(LWSYNC) : : :"memory")
+
+#define store_release(p, v)						\
+do {									\
+	compiletime_assert_atomic_type(*p);				\
+	__lwsync();							\
+	ACCESS_ONCE(*p) = (v);						\
+} while (0)
+
+#define load_acquire(p)							\
+({									\
+	typeof(*p) ___p1 = ACCESS_ONCE(*p);				\
+	compiletime_assert_atomic_type(*p);				\
+	__lwsync();							\
+	___p1;								\
+})
+
 #ifdef CONFIG_SMP
 
 #ifdef __SUBARCH_HAS_LWSYNC
@@ -45,15 +62,12 @@
 #    define SMPWMB      eieio
 #endif
 
-#define __lwsync()	__asm__ __volatile__ (stringify_in_c(LWSYNC) : : :"memory")
 
 #define smp_mb()	mb()
 #define smp_rmb()	__lwsync()
 #define smp_wmb()	__asm__ __volatile__ (stringify_in_c(SMPWMB) : : :"memory")
 #define smp_read_barrier_depends()	read_barrier_depends()
 #else
-#define __lwsync()	barrier()
-
 #define smp_mb()	barrier()
 #define smp_rmb()	barrier()
 #define smp_wmb()	barrier()
@@ -72,7 +86,7 @@
 #define smp_store_release(p, v)						\
 do {									\
 	compiletime_assert_atomic_type(*p);				\
-	__lwsync();							\
+	smp_rmb();							\
 	ACCESS_ONCE(*p) = (v);						\
 } while (0)
 
@@ -80,7 +94,7 @@ do {									\
 ({									\
 	typeof(*p) ___p1 = ACCESS_ONCE(*p);				\
 	compiletime_assert_atomic_type(*p);				\
-	__lwsync();							\
+	smp_rmb();							\
 	___p1;								\
 })
 
diff --git a/arch/s390/include/asm/barrier.h b/arch/s390/include/asm/barrier.h
index b5dce65..637d7a9 100644
--- a/arch/s390/include/asm/barrier.h
+++ b/arch/s390/include/asm/barrier.h
@@ -35,14 +35,14 @@
 
 #define set_mb(var, value)		do { var = value; mb(); } while (0)
 
-#define smp_store_release(p, v)						\
+#define store_release(p, v)						\
 do {									\
 	compiletime_assert_atomic_type(*p);				\
 	barrier();							\
 	ACCESS_ONCE(*p) = (v);						\
 } while (0)
 
-#define smp_load_acquire(p)						\
+#define load_acquire(p)							\
 ({									\
 	typeof(*p) ___p1 = ACCESS_ONCE(*p);				\
 	compiletime_assert_atomic_type(*p);				\
@@ -50,4 +50,7 @@ do {									\
 	___p1;								\
 })
 
+#define smp_store_release(p, v)		store_release(p, v)
+#define smp_load_acquire(p)		load_acquire(p)
+
 #endif /* __ASM_BARRIER_H */
diff --git a/arch/sparc/include/asm/barrier_64.h b/arch/sparc/include/asm/barrier_64.h
index 305dcc3..7de3c69 100644
--- a/arch/sparc/include/asm/barrier_64.h
+++ b/arch/sparc/include/asm/barrier_64.h
@@ -53,14 +53,14 @@ do {	__asm__ __volatile__("ba,pt	%%xcc, 1f\n\t" \
 
 #define smp_read_barrier_depends()	do { } while(0)
 
-#define smp_store_release(p, v)						\
+#define store_release(p, v)						\
 do {									\
 	compiletime_assert_atomic_type(*p);				\
 	barrier();							\
 	ACCESS_ONCE(*p) = (v);						\
 } while (0)
 
-#define smp_load_acquire(p)						\
+#define load_acquire(p)							\
 ({									\
 	typeof(*p) ___p1 = ACCESS_ONCE(*p);				\
 	compiletime_assert_atomic_type(*p);				\
@@ -68,6 +68,8 @@ do {									\
 	___p1;								\
 })
 
+#define smp_store_release(p, v)	store_release(p, v)
+#define smp_load_acquire(p)	load_acquire(p)
 #define smp_mb__before_atomic()	barrier()
 #define smp_mb__after_atomic()	barrier()
 
diff --git a/arch/x86/include/asm/barrier.h b/arch/x86/include/asm/barrier.h
index 0f4460b..3d2aa18 100644
--- a/arch/x86/include/asm/barrier.h
+++ b/arch/x86/include/asm/barrier.h
@@ -103,6 +103,21 @@
  * model and we should fall back to full barriers.
  */
 
+#define store_release(p, v)						\
+do {									\
+	compiletime_assert_atomic_type(*p);				\
+	mb();								\
+	ACCESS_ONCE(*p) = (v);						\
+} while (0)
+
+#define load_acquire(p)							\
+({									\
+	typeof(*p) ___p1 = ACCESS_ONCE(*p);				\
+	compiletime_assert_atomic_type(*p);				\
+	mb();								\
+	___p1;								\
+})
+
 #define smp_store_release(p, v)						\
 do {									\
 	compiletime_assert_atomic_type(*p);				\
@@ -120,14 +135,14 @@ do {									\
 
 #else /* regular x86 TSO memory ordering */
 
-#define smp_store_release(p, v)						\
+#define store_release(p, v)						\
 do {									\
 	compiletime_assert_atomic_type(*p);				\
 	barrier();							\
 	ACCESS_ONCE(*p) = (v);						\
 } while (0)
 
-#define smp_load_acquire(p)						\
+#define load_acquire(p)							\
 ({									\
 	typeof(*p) ___p1 = ACCESS_ONCE(*p);				\
 	compiletime_assert_atomic_type(*p);				\
@@ -135,6 +150,9 @@ do {									\
 	___p1;								\
 })
 
+#define smp_store_release(p, v)	store_release(p, v)
+#define smp_load_acquire(p)	load_acquire(p)
+
 #endif
 
 /* Atomic operations are already serializing on x86 */
diff --git a/include/asm-generic/barrier.h b/include/asm-generic/barrier.h
index 1402fa8..c6e4b99 100644
--- a/include/asm-generic/barrier.h
+++ b/include/asm-generic/barrier.h
@@ -70,6 +70,21 @@
 #define smp_mb__after_atomic()	smp_mb()
 #endif
 
+#define store_release(p, v)						\
+do {									\
+	compiletime_assert_atomic_type(*p);				\
+	mb();								\
+	ACCESS_ONCE(*p) = (v);						\
+} while (0)
+
+#define load_acquire(p)							\
+({									\
+	typeof(*p) ___p1 = ACCESS_ONCE(*p);				\
+	compiletime_assert_atomic_type(*p);				\
+	mb();								\
+	___p1;								\
+})
+
 #define smp_store_release(p, v)						\
 do {									\
 	compiletime_assert_atomic_type(*p);				\
