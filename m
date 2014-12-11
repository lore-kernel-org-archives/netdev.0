From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH v7 resubmit 1/4] arch: Cleanup
 read_barrier_depends() and comments
Date: Thu, 11 Dec 2014 15:01:55 -0800
Message-ID: <20141211230155.25464.9783.stgit@ahduyck-server>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48222 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965920AbaLKXEh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Dec 2014 18:04:37 -0500
In-Reply-To: <20141211225250.25464.30291.stgit@ahduyck-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is meant to cleanup the handling of read_barrier_depends and
smp_read_barrier_depends.  In multiple spots in the kernel headers
read_barrier_depends is defined as "do {} while (0)", however we then go
into the SMP vs non-SMP sections and have the SMP version reference
read_barrier_depends, and the non-SMP define it as yet another empty
do/while.

With this commit I went through and cleaned out the duplicate definitions
and reduced the number of definitions down to 2 per header.  In addition I
moved the 50 line comments for the macro from the x86 and mips headers that
defined it as an empty do/while to those that were actually defining the
macro, alpha and blackfin.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 arch/alpha/include/asm/barrier.h    |   51 ++++++++++++++++++++++++++++++
 arch/blackfin/include/asm/barrier.h |   51 ++++++++++++++++++++++++++++++
 arch/ia64/include/asm/barrier.h     |   22 +++++--------
 arch/metag/include/asm/barrier.h    |    7 ++--
 arch/mips/include/asm/barrier.h     |   52 -------------------------------
 arch/powerpc/include/asm/barrier.h  |    6 ++--
 arch/s390/include/asm/barrier.h     |    5 ++-
 arch/sparc/include/asm/barrier_64.h |    4 +-
 arch/x86/include/asm/barrier.h      |   59 ++---------------------------------
 arch/x86/um/asm/barrier.h           |    7 ++--
 10 files changed, 129 insertions(+), 135 deletions(-)

diff --git a/arch/alpha/include/asm/barrier.h b/arch/alpha/include/asm/barrier.h
index 3832bdb..77516c8 100644
--- a/arch/alpha/include/asm/barrier.h
+++ b/arch/alpha/include/asm/barrier.h
@@ -7,6 +7,57 @@
 #define rmb()	__asm__ __volatile__("mb": : :"memory")
 #define wmb()	__asm__ __volatile__("wmb": : :"memory")
 
+/**
+ * read_barrier_depends - Flush all pending reads that subsequents reads
+ * depend on.
+ *
+ * No data-dependent reads from memory-like regions are ever reordered
+ * over this barrier.  All reads preceding this primitive are guaranteed
+ * to access memory (but not necessarily other CPUs' caches) before any
+ * reads following this primitive that depend on the data return by
+ * any of the preceding reads.  This primitive is much lighter weight than
+ * rmb() on most CPUs, and is never heavier weight than is
+ * rmb().
+ *
+ * These ordering constraints are respected by both the local CPU
+ * and the compiler.
+ *
+ * Ordering is not guaranteed by anything other than these primitives,
+ * not even by data dependencies.  See the documentation for
+ * memory_barrier() for examples and URLs to more information.
+ *
+ * For example, the following code would force ordering (the initial
+ * value of "a" is zero, "b" is one, and "p" is "&a"):
+ *
+ * <programlisting>
+ *	CPU 0				CPU 1
+ *
+ *	b = 2;
+ *	memory_barrier();
+ *	p = &b;				q = p;
+ *					read_barrier_depends();
+ *					d = *q;
+ * </programlisting>
+ *
+ * because the read of "*q" depends on the read of "p" and these
+ * two reads are separated by a read_barrier_depends().  However,
+ * the following code, with the same initial values for "a" and "b":
+ *
+ * <programlisting>
+ *	CPU 0				CPU 1
+ *
+ *	a = 2;
+ *	memory_barrier();
+ *	b = 3;				y = b;
+ *					read_barrier_depends();
+ *					x = a;
+ * </programlisting>
+ *
+ * does not enforce ordering, since there is no data dependency between
+ * the read of "a" and the read of "b".  Therefore, on some CPUs, such
+ * as Alpha, "y" could be set to 3 and "x" to 0.  Use rmb()
+ * in cases like this where there are no data dependencies.
+ */
 #define read_barrier_depends() __asm__ __volatile__("mb": : :"memory")
 
 #ifdef CONFIG_SMP
diff --git a/arch/blackfin/include/asm/barrier.h b/arch/blackfin/include/asm/barrier.h
index 4200068..dfb66fe 100644
--- a/arch/blackfin/include/asm/barrier.h
+++ b/arch/blackfin/include/asm/barrier.h
@@ -22,6 +22,57 @@
 # define mb()	do { barrier(); smp_check_barrier(); smp_mark_barrier(); } while (0)
 # define rmb()	do { barrier(); smp_check_barrier(); } while (0)
 # define wmb()	do { barrier(); smp_mark_barrier(); } while (0)
+/*
+ * read_barrier_depends - Flush all pending reads that subsequents reads
+ * depend on.
+ *
+ * No data-dependent reads from memory-like regions are ever reordered
+ * over this barrier.  All reads preceding this primitive are guaranteed
+ * to access memory (but not necessarily other CPUs' caches) before any
+ * reads following this primitive that depend on the data return by
+ * any of the preceding reads.  This primitive is much lighter weight than
+ * rmb() on most CPUs, and is never heavier weight than is
+ * rmb().
+ *
+ * These ordering constraints are respected by both the local CPU
+ * and the compiler.
+ *
+ * Ordering is not guaranteed by anything other than these primitives,
+ * not even by data dependencies.  See the documentation for
+ * memory_barrier() for examples and URLs to more information.
+ *
+ * For example, the following code would force ordering (the initial
+ * value of "a" is zero, "b" is one, and "p" is "&a"):
+ *
+ * <programlisting>
+ *	CPU 0				CPU 1
+ *
+ *	b = 2;
+ *	memory_barrier();
+ *	p = &b;				q = p;
+ *					read_barrier_depends();
+ *					d = *q;
+ * </programlisting>
+ *
+ * because the read of "*q" depends on the read of "p" and these
+ * two reads are separated by a read_barrier_depends().  However,
+ * the following code, with the same initial values for "a" and "b":
+ *
+ * <programlisting>
+ *	CPU 0				CPU 1
+ *
+ *	a = 2;
+ *	memory_barrier();
+ *	b = 3;				y = b;
+ *					read_barrier_depends();
+ *					x = a;
+ * </programlisting>
+ *
+ * does not enforce ordering, since there is no data dependency between
+ * the read of "a" and the read of "b".  Therefore, on some CPUs, such
+ * as Alpha, "y" could be set to 3 and "x" to 0.  Use rmb()
+ * in cases like this where there are no data dependencies.
+ */
 # define read_barrier_depends()	do { barrier(); smp_check_barrier(); } while (0)
 #endif
 
diff --git a/arch/ia64/include/asm/barrier.h b/arch/ia64/include/asm/barrier.h
index a48957c..e8fffb0 100644
--- a/arch/ia64/include/asm/barrier.h
+++ b/arch/ia64/include/asm/barrier.h
@@ -35,26 +35,22 @@
  * it's (presumably) much slower than mf and (b) mf.a is supported for
  * sequential memory pages only.
  */
-#define mb()	ia64_mf()
-#define rmb()	mb()
-#define wmb()	mb()
-#define read_barrier_depends()	do { } while(0)
+#define mb()		ia64_mf()
+#define rmb()		mb()
+#define wmb()		mb()
 
 #ifdef CONFIG_SMP
 # define smp_mb()	mb()
-# define smp_rmb()	rmb()
-# define smp_wmb()	wmb()
-# define smp_read_barrier_depends()	read_barrier_depends()
-
 #else
-
 # define smp_mb()	barrier()
-# define smp_rmb()	barrier()
-# define smp_wmb()	barrier()
-# define smp_read_barrier_depends()	do { } while(0)
-
 #endif
 
+#define smp_rmb()	smp_mb()
+#define smp_wmb()	smp_mb()
+
+#define read_barrier_depends()		do { } while (0)
+#define smp_read_barrier_depends()	do { } while (0)
+
 #define smp_mb__before_atomic()	barrier()
 #define smp_mb__after_atomic()	barrier()
 
diff --git a/arch/metag/include/asm/barrier.h b/arch/metag/include/asm/barrier.h
index c7591e8..6d8b8c9 100644
--- a/arch/metag/include/asm/barrier.h
+++ b/arch/metag/include/asm/barrier.h
@@ -47,8 +47,6 @@ static inline void wmb(void)
 	wr_fence();
 }
 
-#define read_barrier_depends()  do { } while (0)
-
 #ifndef CONFIG_SMP
 #define fence()		do { } while (0)
 #define smp_mb()        barrier()
@@ -82,7 +80,10 @@ static inline void fence(void)
 #define smp_wmb()       barrier()
 #endif
 #endif
-#define smp_read_barrier_depends()     do { } while (0)
+
+#define read_barrier_depends()		do { } while (0)
+#define smp_read_barrier_depends()	do { } while (0)
+
 #define set_mb(var, value) do { var = value; smp_mb(); } while (0)
 
 #define smp_store_release(p, v)						\
diff --git a/arch/mips/include/asm/barrier.h b/arch/mips/include/asm/barrier.h
index d0101dd..3d69aa8 100644
--- a/arch/mips/include/asm/barrier.h
+++ b/arch/mips/include/asm/barrier.h
@@ -10,58 +10,6 @@
 
 #include <asm/addrspace.h>
 
-/*
- * read_barrier_depends - Flush all pending reads that subsequents reads
- * depend on.
- *
- * No data-dependent reads from memory-like regions are ever reordered
- * over this barrier.  All reads preceding this primitive are guaranteed
- * to access memory (but not necessarily other CPUs' caches) before any
- * reads following this primitive that depend on the data return by
- * any of the preceding reads.  This primitive is much lighter weight than
- * rmb() on most CPUs, and is never heavier weight than is
- * rmb().
- *
- * These ordering constraints are respected by both the local CPU
- * and the compiler.
- *
- * Ordering is not guaranteed by anything other than these primitives,
- * not even by data dependencies.  See the documentation for
- * memory_barrier() for examples and URLs to more information.
- *
- * For example, the following code would force ordering (the initial
- * value of "a" is zero, "b" is one, and "p" is "&a"):
- *
- * <programlisting>
- *	CPU 0				CPU 1
- *
- *	b = 2;
- *	memory_barrier();
- *	p = &b;				q = p;
- *					read_barrier_depends();
- *					d = *q;
- * </programlisting>
- *
- * because the read of "*q" depends on the read of "p" and these
- * two reads are separated by a read_barrier_depends().  However,
- * the following code, with the same initial values for "a" and "b":
- *
- * <programlisting>
- *	CPU 0				CPU 1
- *
- *	a = 2;
- *	memory_barrier();
- *	b = 3;				y = b;
- *					read_barrier_depends();
- *					x = a;
- * </programlisting>
- *
- * does not enforce ordering, since there is no data dependency between
- * the read of "a" and the read of "b".  Therefore, on some CPUs, such
- * as Alpha, "y" could be set to 3 and "x" to 0.  Use rmb()
- * in cases like this where there are no data dependencies.
- */
-
 #define read_barrier_depends()		do { } while(0)
 #define smp_read_barrier_depends()	do { } while(0)
 
diff --git a/arch/powerpc/include/asm/barrier.h b/arch/powerpc/include/asm/barrier.h
index bab79a1..cb6d66c 100644
--- a/arch/powerpc/include/asm/barrier.h
+++ b/arch/powerpc/include/asm/barrier.h
@@ -33,7 +33,6 @@
 #define mb()   __asm__ __volatile__ ("sync" : : : "memory")
 #define rmb()  __asm__ __volatile__ ("sync" : : : "memory")
 #define wmb()  __asm__ __volatile__ ("sync" : : : "memory")
-#define read_barrier_depends()  do { } while(0)
 
 #define set_mb(var, value)	do { var = value; mb(); } while (0)
 
@@ -50,16 +49,17 @@
 #define smp_mb()	mb()
 #define smp_rmb()	__lwsync()
 #define smp_wmb()	__asm__ __volatile__ (stringify_in_c(SMPWMB) : : :"memory")
-#define smp_read_barrier_depends()	read_barrier_depends()
 #else
 #define __lwsync()	barrier()
 
 #define smp_mb()	barrier()
 #define smp_rmb()	barrier()
 #define smp_wmb()	barrier()
-#define smp_read_barrier_depends()	do { } while(0)
 #endif /* CONFIG_SMP */
 
+#define read_barrier_depends()		do { } while (0)
+#define smp_read_barrier_depends()	do { } while (0)
+
 /*
  * This is a barrier which prevents following instructions from being
  * started until the value of the argument x is known.  For example, if
diff --git a/arch/s390/include/asm/barrier.h b/arch/s390/include/asm/barrier.h
index b5dce65..33d191d 100644
--- a/arch/s390/include/asm/barrier.h
+++ b/arch/s390/include/asm/barrier.h
@@ -24,11 +24,12 @@
 
 #define rmb()				mb()
 #define wmb()				mb()
-#define read_barrier_depends()		do { } while(0)
 #define smp_mb()			mb()
 #define smp_rmb()			rmb()
 #define smp_wmb()			wmb()
-#define smp_read_barrier_depends()	read_barrier_depends()
+
+#define read_barrier_depends()		do { } while (0)
+#define smp_read_barrier_depends()	do { } while (0)
 
 #define smp_mb__before_atomic()		smp_mb()
 #define smp_mb__after_atomic()		smp_mb()
diff --git a/arch/sparc/include/asm/barrier_64.h b/arch/sparc/include/asm/barrier_64.h
index 305dcc3..6c974c0 100644
--- a/arch/sparc/include/asm/barrier_64.h
+++ b/arch/sparc/include/asm/barrier_64.h
@@ -37,7 +37,6 @@ do {	__asm__ __volatile__("ba,pt	%%xcc, 1f\n\t" \
 #define rmb()	__asm__ __volatile__("":::"memory")
 #define wmb()	__asm__ __volatile__("":::"memory")
 
-#define read_barrier_depends()		do { } while(0)
 #define set_mb(__var, __value) \
 	do { __var = __value; membar_safe("#StoreLoad"); } while(0)
 
@@ -51,7 +50,8 @@ do {	__asm__ __volatile__("ba,pt	%%xcc, 1f\n\t" \
 #define smp_wmb()	__asm__ __volatile__("":::"memory")
 #endif
 
-#define smp_read_barrier_depends()	do { } while(0)
+#define read_barrier_depends()		do { } while (0)
+#define smp_read_barrier_depends()	do { } while (0)
 
 #define smp_store_release(p, v)						\
 do {									\
diff --git a/arch/x86/include/asm/barrier.h b/arch/x86/include/asm/barrier.h
index 0f4460b..5238000 100644
--- a/arch/x86/include/asm/barrier.h
+++ b/arch/x86/include/asm/barrier.h
@@ -24,60 +24,6 @@
 #define wmb()	asm volatile("sfence" ::: "memory")
 #endif
 
-/**
- * read_barrier_depends - Flush all pending reads that subsequents reads
- * depend on.
- *
- * No data-dependent reads from memory-like regions are ever reordered
- * over this barrier.  All reads preceding this primitive are guaranteed
- * to access memory (but not necessarily other CPUs' caches) before any
- * reads following this primitive that depend on the data return by
- * any of the preceding reads.  This primitive is much lighter weight than
- * rmb() on most CPUs, and is never heavier weight than is
- * rmb().
- *
- * These ordering constraints are respected by both the local CPU
- * and the compiler.
- *
- * Ordering is not guaranteed by anything other than these primitives,
- * not even by data dependencies.  See the documentation for
- * memory_barrier() for examples and URLs to more information.
- *
- * For example, the following code would force ordering (the initial
- * value of "a" is zero, "b" is one, and "p" is "&a"):
- *
- * <programlisting>
- *	CPU 0				CPU 1
- *
- *	b = 2;
- *	memory_barrier();
- *	p = &b;				q = p;
- *					read_barrier_depends();
- *					d = *q;
- * </programlisting>
- *
- * because the read of "*q" depends on the read of "p" and these
- * two reads are separated by a read_barrier_depends().  However,
- * the following code, with the same initial values for "a" and "b":
- *
- * <programlisting>
- *	CPU 0				CPU 1
- *
- *	a = 2;
- *	memory_barrier();
- *	b = 3;				y = b;
- *					read_barrier_depends();
- *					x = a;
- * </programlisting>
- *
- * does not enforce ordering, since there is no data dependency between
- * the read of "a" and the read of "b".  Therefore, on some CPUs, such
- * as Alpha, "y" could be set to 3 and "x" to 0.  Use rmb()
- * in cases like this where there are no data dependencies.
- **/
-
-#define read_barrier_depends()	do { } while (0)
-
 #ifdef CONFIG_SMP
 #define smp_mb()	mb()
 #ifdef CONFIG_X86_PPRO_FENCE
@@ -86,16 +32,17 @@
 # define smp_rmb()	barrier()
 #endif
 #define smp_wmb()	barrier()
-#define smp_read_barrier_depends()	read_barrier_depends()
 #define set_mb(var, value) do { (void)xchg(&var, value); } while (0)
 #else /* !SMP */
 #define smp_mb()	barrier()
 #define smp_rmb()	barrier()
 #define smp_wmb()	barrier()
-#define smp_read_barrier_depends()	do { } while (0)
 #define set_mb(var, value) do { var = value; barrier(); } while (0)
 #endif /* SMP */
 
+#define read_barrier_depends()		do { } while (0)
+#define smp_read_barrier_depends()	do { } while (0)
+
 #if defined(CONFIG_X86_PPRO_FENCE)
 
 /*
diff --git a/arch/x86/um/asm/barrier.h b/arch/x86/um/asm/barrier.h
index cc04e67..d6511d9 100644
--- a/arch/x86/um/asm/barrier.h
+++ b/arch/x86/um/asm/barrier.h
@@ -29,8 +29,6 @@
 
 #endif /* CONFIG_X86_32 */
 
-#define read_barrier_depends()	do { } while (0)
-
 #ifdef CONFIG_SMP
 
 #define smp_mb()	mb()
@@ -42,7 +40,6 @@
 
 #define smp_wmb()	barrier()
 
-#define smp_read_barrier_depends()	read_barrier_depends()
 #define set_mb(var, value) do { (void)xchg(&var, value); } while (0)
 
 #else /* CONFIG_SMP */
@@ -50,11 +47,13 @@
 #define smp_mb()	barrier()
 #define smp_rmb()	barrier()
 #define smp_wmb()	barrier()
-#define smp_read_barrier_depends()	do { } while (0)
 #define set_mb(var, value) do { var = value; barrier(); } while (0)
 
 #endif /* CONFIG_SMP */
 
+#define read_barrier_depends()		do { } while (0)
+#define smp_read_barrier_depends()	do { } while (0)
+
 /*
  * Stop RDTSC speculation. This is needed when you need to use RDTSC
  * (or get_cycles or vread that possibly accesses the TSC) in a defined
