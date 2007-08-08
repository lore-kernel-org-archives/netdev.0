From: Chris Snook <csnook@redhat.com>
Subject: [PATCH] make atomic_t volatile on all architectures
Date: Wed, 8 Aug 2007 19:07:33 -0400
Message-ID: <20070808230733.GA17270@shell.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, schwidefsky@de.ibm.com,
	wensong@linux-vs.org, horms@verge.net.au, wjiang@resilience.com,
	cfriesen@nortel.com, zlynx@acm.org
To: akpm@linux-foundation.org, torvalds@linux-foundation.org,
	ak@suse.de, heiko.carstens@de.ibm.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S936215AbXHHXI2@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Snook <csnook@redhat.com>

Some architectures currently do not declare the contents of an atomic_t to be
volatile.  This causes confusion since atomic_read() might not actually read
anything if an optimizing compiler re-uses a value stored in a register, which
can break code that loops until something external changes the value of an
atomic_t.  Avoiding such bugs requires using barrier(), which causes re-loads
of all registers used in the loop, thus hurting performance instead of helping
it, particularly on architectures where it's unnecessary.  Since we generally
want to re-read the contents of an atomic variable on every access anyway,
let's standardize the behavior across all architectures and avoid the
performance and correctness problems of requiring the use of barrier() in
loops that expect atomic_t variables to change externally.  This is relevant
even on non-smp architectures, since drivers may use atomic operations in
interrupt handlers.

Signed-off-by: Chris Snook <csnook@redhat.com>


diff -urp linux-2.6.23-rc2-orig/include/asm-blackfin/atomic.h linux-2.6.23-rc2/include/asm-blackfin/atomic.h
--- linux-2.6.23-rc2-orig/include/asm-blackfin/atomic.h	2007-07-08 19:32:17.000000000 -0400
+++ linux-2.6.23-rc2/include/asm-blackfin/atomic.h	2007-08-08 18:18:43.000000000 -0400
@@ -13,8 +13,13 @@
  * Tony Kou (tonyko@lineo.ca)   Lineo Inc.   2001
  */
 
+/*
+ * Make atomic_t volatile to remove the need for barriers in loops that
+ * wait for an outside event.  We generally want to re-load the atomic_t
+ * variable each time anyway, but don't need to re-load everything else.
+ */
 typedef struct {
-	int counter;
+	volatile int counter;
 } atomic_t;
 #define ATOMIC_INIT(i)	{ (i) }
 
diff -urp linux-2.6.23-rc2-orig/include/asm-frv/atomic.h linux-2.6.23-rc2/include/asm-frv/atomic.h
--- linux-2.6.23-rc2-orig/include/asm-frv/atomic.h	2007-07-08 19:32:17.000000000 -0400
+++ linux-2.6.23-rc2/include/asm-frv/atomic.h	2007-08-08 18:21:55.000000000 -0400
@@ -35,8 +35,13 @@
 #define smp_mb__before_atomic_inc()	barrier()
 #define smp_mb__after_atomic_inc()	barrier()
 
+/*
+ * Make atomic_t volatile to remove the need for barriers in loops that
+ * wait for an outside event.  We generally want to re-load the atomic_t
+ * variable each time anyway, but don't need to re-load everything else.
+ */
 typedef struct {
-	int counter;
+	volatile int counter;
 } atomic_t;
 
 #define ATOMIC_INIT(i)		{ (i) }
diff -urp linux-2.6.23-rc2-orig/include/asm-h8300/atomic.h linux-2.6.23-rc2/include/asm-h8300/atomic.h
--- linux-2.6.23-rc2-orig/include/asm-h8300/atomic.h	2007-07-08 19:32:17.000000000 -0400
+++ linux-2.6.23-rc2/include/asm-h8300/atomic.h	2007-08-08 18:24:02.000000000 -0400
@@ -6,7 +6,12 @@
  * resource counting etc..
  */
 
-typedef struct { int counter; } atomic_t;
+/*
+ * Make atomic_t volatile to remove the need for barriers in loops that
+ * wait for an outside event.  We generally want to re-load the atomic_t
+ * variable each time anyway, but don't need to re-load everything else.
+ */
+typedef struct { volatile int counter; } atomic_t;
 #define ATOMIC_INIT(i)	{ (i) }
 
 #define atomic_read(v)		((v)->counter)
diff -urp linux-2.6.23-rc2-orig/include/asm-i386/atomic.h linux-2.6.23-rc2/include/asm-i386/atomic.h
--- linux-2.6.23-rc2-orig/include/asm-i386/atomic.h	2007-07-08 19:32:17.000000000 -0400
+++ linux-2.6.23-rc2/include/asm-i386/atomic.h	2007-08-08 18:26:09.000000000 -0400
@@ -14,8 +14,12 @@
  * Make sure gcc doesn't try to be clever and move things around
  * on us. We need to use _exactly_ the address the user gave us,
  * not some alias that contains the same information.
+ *
+ * Make atomic_t volatile to remove the need for barriers in loops that
+ * wait for an outside event.  We generally want to re-load the atomic_t
+ * variable each time anyway, but don't need to re-load everything else.
  */
-typedef struct { int counter; } atomic_t;
+typedef struct { volatile int counter; } atomic_t;
 
 #define ATOMIC_INIT(i)	{ (i) }
 
diff -urp linux-2.6.23-rc2-orig/include/asm-m68k/atomic.h linux-2.6.23-rc2/include/asm-m68k/atomic.h
--- linux-2.6.23-rc2-orig/include/asm-m68k/atomic.h	2007-07-08 19:32:17.000000000 -0400
+++ linux-2.6.23-rc2/include/asm-m68k/atomic.h	2007-08-08 18:28:58.000000000 -0400
@@ -13,7 +13,12 @@
  * We do not have SMP m68k systems, so we don't have to deal with that.
  */
 
-typedef struct { int counter; } atomic_t;
+/*
+ * Make atomic_t volatile to remove the need for barriers in loops that
+ * wait for an outside event.  We generally want to re-load the atomic_t
+ * variable each time anyway, but don't need to re-load everything else.
+ */
+typedef struct { volatile int counter; } atomic_t;
 #define ATOMIC_INIT(i)	{ (i) }
 
 #define atomic_read(v)		((v)->counter)
diff -urp linux-2.6.23-rc2-orig/include/asm-m68knommu/atomic.h linux-2.6.23-rc2/include/asm-m68knommu/atomic.h
--- linux-2.6.23-rc2-orig/include/asm-m68knommu/atomic.h	2007-07-08 19:32:17.000000000 -0400
+++ linux-2.6.23-rc2/include/asm-m68knommu/atomic.h	2007-08-08 18:30:32.000000000 -0400
@@ -12,7 +12,12 @@
  * We do not have SMP m68k systems, so we don't have to deal with that.
  */
 
-typedef struct { int counter; } atomic_t;
+/*
+ * Make atomic_t volatile to remove the need for barriers in loops that
+ * wait for an outside event.  We generally want to re-load the atomic_t
+ * variable each time anyway, but don't need to re-load everything else.
+ */
+typedef struct { volatile int counter; } atomic_t;
 #define ATOMIC_INIT(i)	{ (i) }
 
 #define atomic_read(v)		((v)->counter)
diff -urp linux-2.6.23-rc2-orig/include/asm-s390/atomic.h linux-2.6.23-rc2/include/asm-s390/atomic.h
--- linux-2.6.23-rc2-orig/include/asm-s390/atomic.h	2007-08-08 17:48:53.000000000 -0400
+++ linux-2.6.23-rc2/include/asm-s390/atomic.h	2007-08-08 18:40:17.000000000 -0400
@@ -23,8 +23,13 @@
  * S390 uses 'Compare And Swap' for atomicity in SMP enviroment
  */
 
+/*
+ * Make atomic_t volatile to remove the need for barriers in loops that
+ * wait for an outside event.  We generally want to re-load the atomic_t
+ * variable each time anyway, but don't need to re-load everything else.
+ */
 typedef struct {
-	int counter;
+	volatile int counter;
 } __attribute__ ((aligned (4))) atomic_t;
 #define ATOMIC_INIT(i)  { (i) }
 
diff -urp linux-2.6.23-rc2-orig/include/asm-v850/atomic.h linux-2.6.23-rc2/include/asm-v850/atomic.h
--- linux-2.6.23-rc2-orig/include/asm-v850/atomic.h	2007-07-08 19:32:17.000000000 -0400
+++ linux-2.6.23-rc2/include/asm-v850/atomic.h	2007-08-08 18:42:37.000000000 -0400
@@ -21,7 +21,12 @@
 #error SMP not supported
 #endif
 
-typedef struct { int counter; } atomic_t;
+/*
+ * Make atomic_t volatile to remove the need for barriers in loops that
+ * wait for an outside event.  We generally want to re-load the atomic_t
+ * variable each time anyway, but don't need to re-load everything else.
+ */
+typedef struct { volatile int counter; } atomic_t;
 
 #define ATOMIC_INIT(i)	{ (i) }
 
diff -urp linux-2.6.23-rc2-orig/include/asm-x86_64/atomic.h linux-2.6.23-rc2/include/asm-x86_64/atomic.h
--- linux-2.6.23-rc2-orig/include/asm-x86_64/atomic.h	2007-07-08 19:32:17.000000000 -0400
+++ linux-2.6.23-rc2/include/asm-x86_64/atomic.h	2007-08-08 18:44:18.000000000 -0400
@@ -21,8 +21,12 @@
  * Make sure gcc doesn't try to be clever and move things around
  * on us. We need to use _exactly_ the address the user gave us,
  * not some alias that contains the same information.
+ *
+ * Make atomic_t volatile to remove the need for barriers in loops that
+ * wait for an outside event.  We generally want to re-load the atomic_t
+ * variable each time anyway, but don't need to re-load everything else.
  */
-typedef struct { int counter; } atomic_t;
+typedef struct { volatile int counter; } atomic_t;
 
 #define ATOMIC_INIT(i)	{ (i) }
 
