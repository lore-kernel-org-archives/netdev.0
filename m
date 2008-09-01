From: Nick Piggin <npiggin@suse.de>
Subject: [patch][rfc] bitops: remove volatile
Date: Mon, 1 Sep 2008 14:51:53 +0200
Message-ID: <20080901125152.GA18225__13836.2085716382$1220273655$gmane$org@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: torvalds@linux-foundation.org, Dave Airlie <airlied@redhat.com>,
	dri-devel@lists.sourceforge.net, ram.vepa@neterion.com,
	santosh.rastapur@neterion.com, sivakumar.subramani@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:39380 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752506AbYIAMv6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Sep 2008 08:51:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

This is a sweep of the tree to remove volatile qualifier from bitops, and I
have then tried to fix the resulting fallout. This will be split up as
individual patches before submission, but for now I include the entire thing
in one.

The benefit of this is to relieve the compiler of the constraints demanded
by volatile, we get a smaller icache footprint, generally due to fewer loads
and stores. It saves over 20k of text on an allyesconfig on x86-64. (BTW. gcc
really does some idiotic things when inline is nooped: it out of lines things
like constant_test_bit...)

The downside is that we can no longer use bitops on volatile data types, but
there are very few users of this, and it would be nice to convert them away
from volatile anyway. I have attempted to do that here:

s2io: only affected is use of test_bit on a previously volatile type. btw:
      set_bit and clear_bit do not provide SMP ordering guarantees, in
      particular they can't be used for critical sections. Just be careful
      eg. with __S2IO_STATE_LINK_TASK bit.
drm:  Made wrapped and context_state non volatile. Remember set_bit and
      clear_bit can't be used to open and close a critical section (is
      wrapped OK here?).
3w-xxxx: made flags non volatile. Only test_bit should be affected.
sn2:  small change to sn_ack_irq and sn_end_irq... I know ia64 guys have
      been known to rely on gcc generating hardware barriers with volatile.
      Please take a look.

Cc: torvalds@linux-foundation.org
Cc: Dave Airlie <airlied@redhat.com>
Cc: dri-devel@lists.sourceforge.net
Cc: ram.vepa@neterion.com
Cc: santosh.rastapur@neterion.com
Cc: sivakumar.subramani@neterion.com
Cc: sreenivasa.honnur@neterion.com
Cc: netdev@vger.kernel.org
Cc: linuxraid@amcc.com
Cc: linux-scsi@vger.kernel.org
Cc: jes@sgi.com
Cc: linux-altix@sgi.com
Cc: linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-arch@vger.kernel.org
---
 Documentation/atomic_ops.txt            |   26 ++++++-------
 arch/alpha/include/asm/bitops.h         |   32 ++++++++---------
 arch/arm/include/asm/bitops.h           |   36 +++++++++----------
 arch/avr32/include/asm/bitops.h         |   12 +++---
 arch/blackfin/include/asm/bitops.h      |   36 +++++++++----------
 arch/ia64/include/asm/bitops.h          |   26 ++++++-------
 arch/ia64/sn/kernel/irq.c               |    4 +-
 arch/m68knommu/include/asm/bitops.h     |   24 ++++++------
 arch/mn10300/lib/bitops.c               |    4 +-
 arch/powerpc/include/asm/bitops.h       |   18 ++++-----
 arch/s390/include/asm/bitops.h          |   36 +++++++++----------
 arch/sh/include/asm/bitops-grb.h        |   24 ++++++------
 arch/sh/include/asm/bitops-irq.h        |   24 ++++++------
 arch/sparc/include/asm/bitops_32.h      |   12 +++---
 arch/sparc/include/asm/bitops_64.h      |   12 +++---
 drivers/gpu/drm/mga/mga_drv.h           |    2 -
 drivers/net/s2io.h                      |    2 -
 drivers/scsi/3w-xxxx.h                  |    2 -
 include/asm-cris/bitops.h               |    6 +--
 include/asm-frv/bitops.h                |   60 ++++++++++++++++----------------
 include/asm-generic/bitops/atomic.h     |   12 +++---
 include/asm-generic/bitops/non-atomic.h |   14 +++----
 include/asm-m32r/bitops.h               |   12 +++---
 include/asm-m68k/bitops.h               |    8 ++--
 include/asm-mips/bitops.h               |   32 ++++++++---------
 include/asm-mn10300/bitops.h            |   20 +++++-----
 include/asm-parisc/bitops.h             |   12 +++---
 include/asm-x86/bitops.h                |   38 ++++++++++----------
 include/asm-x86/sync_bitops.h           |   14 +++----
 include/drm/drmP.h                      |    2 -
 include/linux/cpumask.h                 |    4 +-
 include/linux/nodemask.h                |    4 +-
 32 files changed, 285 insertions(+), 285 deletions(-)

Index: linux-2.6/Documentation/atomic_ops.txt
===================================================================
--- linux-2.6.orig/Documentation/atomic_ops.txt	2008-09-01 21:57:27.000000000 +1000
+++ linux-2.6/Documentation/atomic_ops.txt	2008-09-01 21:57:50.000000000 +1000
@@ -341,9 +341,9 @@ to the size of an "unsigned long" C data
 size.  The endianness of the bits within each "unsigned long" are the
 native endianness of the cpu.
 
-	void set_bit(unsigned long nr, volatile unsigned long *addr);
-	void clear_bit(unsigned long nr, volatile unsigned long *addr);
-	void change_bit(unsigned long nr, volatile unsigned long *addr);
+	void set_bit(unsigned long nr, unsigned long *addr);
+	void clear_bit(unsigned long nr, unsigned long *addr);
+	void change_bit(unsigned long nr, unsigned long *addr);
 
 These routines set, clear, and change, respectively, the bit number
 indicated by "nr" on the bit mask pointed to by "ADDR".
@@ -351,9 +351,9 @@ indicated by "nr" on the bit mask pointe
 They must execute atomically, yet there are no implicit memory barrier
 semantics required of these interfaces.
 
-	int test_and_set_bit(unsigned long nr, volatile unsigned long *addr);
-	int test_and_clear_bit(unsigned long nr, volatile unsigned long *addr);
-	int test_and_change_bit(unsigned long nr, volatile unsigned long *addr);
+	int test_and_set_bit(unsigned long nr, unsigned long *addr);
+	int test_and_clear_bit(unsigned long nr, unsigned long *addr);
+	int test_and_change_bit(unsigned long nr, unsigned long *addr);
 
 Like the above, except that these routines return a boolean which
 indicates whether the changed bit was set _BEFORE_ the atomic bit
@@ -393,7 +393,7 @@ memory operation done by test_and_set_bi
 
 Finally there is the basic operation:
 
-	int test_bit(unsigned long nr, __const__ volatile unsigned long *addr);
+	int test_bit(unsigned long nr, __const__ unsigned long *addr);
 
 Which returns a boolean indicating if bit "nr" is set in the bitmask
 pointed to by "addr".
@@ -440,12 +440,12 @@ expensive non-atomic operations may be u
 They have names similar to the above bitmask operation interfaces,
 except that two underscores are prefixed to the interface name.
 
-	void __set_bit(unsigned long nr, volatile unsigned long *addr);
-	void __clear_bit(unsigned long nr, volatile unsigned long *addr);
-	void __change_bit(unsigned long nr, volatile unsigned long *addr);
-	int __test_and_set_bit(unsigned long nr, volatile unsigned long *addr);
-	int __test_and_clear_bit(unsigned long nr, volatile unsigned long *addr);
-	int __test_and_change_bit(unsigned long nr, volatile unsigned long *addr);
+	void __set_bit(unsigned long nr, unsigned long *addr);
+	void __clear_bit(unsigned long nr, unsigned long *addr);
+	void __change_bit(unsigned long nr, unsigned long *addr);
+	int __test_and_set_bit(unsigned long nr, unsigned long *addr);
+	int __test_and_clear_bit(unsigned long nr, unsigned long *addr);
+	int __test_and_change_bit(unsigned long nr, unsigned long *addr);
 
 These non-atomic variants also do not require any special memory
 barrier semantics.
Index: linux-2.6/arch/alpha/include/asm/bitops.h
===================================================================
--- linux-2.6.orig/arch/alpha/include/asm/bitops.h	2008-09-01 21:57:27.000000000 +1000
+++ linux-2.6/arch/alpha/include/asm/bitops.h	2008-09-01 21:57:50.000000000 +1000
@@ -25,7 +25,7 @@
  */
 
 static inline void
-set_bit(unsigned long nr, volatile void * addr)
+set_bit(unsigned long nr, void * addr)
 {
 	unsigned long temp;
 	int *m = ((int *) addr) + (nr >> 5);
@@ -46,7 +46,7 @@ set_bit(unsigned long nr, volatile void 
  * WARNING: non atomic version.
  */
 static inline void
-__set_bit(unsigned long nr, volatile void * addr)
+__set_bit(unsigned long nr, void * addr)
 {
 	int *m = ((int *) addr) + (nr >> 5);
 
@@ -57,7 +57,7 @@ __set_bit(unsigned long nr, volatile voi
 #define smp_mb__after_clear_bit()	smp_mb()
 
 static inline void
-clear_bit(unsigned long nr, volatile void * addr)
+clear_bit(unsigned long nr, void * addr)
 {
 	unsigned long temp;
 	int *m = ((int *) addr) + (nr >> 5);
@@ -75,7 +75,7 @@ clear_bit(unsigned long nr, volatile voi
 }
 
 static inline void
-clear_bit_unlock(unsigned long nr, volatile void * addr)
+clear_bit_unlock(unsigned long nr, void * addr)
 {
 	smp_mb();
 	clear_bit(nr, addr);
@@ -85,7 +85,7 @@ clear_bit_unlock(unsigned long nr, volat
  * WARNING: non atomic version.
  */
 static __inline__ void
-__clear_bit(unsigned long nr, volatile void * addr)
+__clear_bit(unsigned long nr, void * addr)
 {
 	int *m = ((int *) addr) + (nr >> 5);
 
@@ -93,14 +93,14 @@ __clear_bit(unsigned long nr, volatile v
 }
 
 static inline void
-__clear_bit_unlock(unsigned long nr, volatile void * addr)
+__clear_bit_unlock(unsigned long nr, void * addr)
 {
 	smp_mb();
 	__clear_bit(nr, addr);
 }
 
 static inline void
-change_bit(unsigned long nr, volatile void * addr)
+change_bit(unsigned long nr, void * addr)
 {
 	unsigned long temp;
 	int *m = ((int *) addr) + (nr >> 5);
@@ -121,7 +121,7 @@ change_bit(unsigned long nr, volatile vo
  * WARNING: non atomic version.
  */
 static __inline__ void
-__change_bit(unsigned long nr, volatile void * addr)
+__change_bit(unsigned long nr, void * addr)
 {
 	int *m = ((int *) addr) + (nr >> 5);
 
@@ -129,7 +129,7 @@ __change_bit(unsigned long nr, volatile 
 }
 
 static inline int
-test_and_set_bit(unsigned long nr, volatile void *addr)
+test_and_set_bit(unsigned long nr, void *addr)
 {
 	unsigned long oldbit;
 	unsigned long temp;
@@ -159,7 +159,7 @@ test_and_set_bit(unsigned long nr, volat
 }
 
 static inline int
-test_and_set_bit_lock(unsigned long nr, volatile void *addr)
+test_and_set_bit_lock(unsigned long nr, void *addr)
 {
 	unsigned long oldbit;
 	unsigned long temp;
@@ -189,7 +189,7 @@ test_and_set_bit_lock(unsigned long nr, 
  * WARNING: non atomic version.
  */
 static inline int
-__test_and_set_bit(unsigned long nr, volatile void * addr)
+__test_and_set_bit(unsigned long nr, void * addr)
 {
 	unsigned long mask = 1 << (nr & 0x1f);
 	int *m = ((int *) addr) + (nr >> 5);
@@ -200,7 +200,7 @@ __test_and_set_bit(unsigned long nr, vol
 }
 
 static inline int
-test_and_clear_bit(unsigned long nr, volatile void * addr)
+test_and_clear_bit(unsigned long nr, void * addr)
 {
 	unsigned long oldbit;
 	unsigned long temp;
@@ -233,7 +233,7 @@ test_and_clear_bit(unsigned long nr, vol
  * WARNING: non atomic version.
  */
 static inline int
-__test_and_clear_bit(unsigned long nr, volatile void * addr)
+__test_and_clear_bit(unsigned long nr, void * addr)
 {
 	unsigned long mask = 1 << (nr & 0x1f);
 	int *m = ((int *) addr) + (nr >> 5);
@@ -244,7 +244,7 @@ __test_and_clear_bit(unsigned long nr, v
 }
 
 static inline int
-test_and_change_bit(unsigned long nr, volatile void * addr)
+test_and_change_bit(unsigned long nr, void * addr)
 {
 	unsigned long oldbit;
 	unsigned long temp;
@@ -275,7 +275,7 @@ test_and_change_bit(unsigned long nr, vo
  * WARNING: non atomic version.
  */
 static __inline__ int
-__test_and_change_bit(unsigned long nr, volatile void * addr)
+__test_and_change_bit(unsigned long nr, void * addr)
 {
 	unsigned long mask = 1 << (nr & 0x1f);
 	int *m = ((int *) addr) + (nr >> 5);
@@ -286,7 +286,7 @@ __test_and_change_bit(unsigned long nr, 
 }
 
 static inline int
-test_bit(int nr, const volatile void * addr)
+test_bit(int nr, const void * addr)
 {
 	return (1UL & (((const int *) addr)[nr >> 5] >> (nr & 31))) != 0UL;
 }
Index: linux-2.6/arch/arm/include/asm/bitops.h
===================================================================
--- linux-2.6.orig/arch/arm/include/asm/bitops.h	2008-09-01 21:57:27.000000000 +1000
+++ linux-2.6/arch/arm/include/asm/bitops.h	2008-09-01 21:57:50.000000000 +1000
@@ -34,7 +34,7 @@
  *
  * First, the atomic bitops. These use native endian.
  */
-static inline void ____atomic_set_bit(unsigned int bit, volatile unsigned long *p)
+static inline void ____atomic_set_bit(unsigned int bit, unsigned long *p)
 {
 	unsigned long flags;
 	unsigned long mask = 1UL << (bit & 31);
@@ -46,7 +46,7 @@ static inline void ____atomic_set_bit(un
 	raw_local_irq_restore(flags);
 }
 
-static inline void ____atomic_clear_bit(unsigned int bit, volatile unsigned long *p)
+static inline void ____atomic_clear_bit(unsigned int bit, unsigned long *p)
 {
 	unsigned long flags;
 	unsigned long mask = 1UL << (bit & 31);
@@ -58,7 +58,7 @@ static inline void ____atomic_clear_bit(
 	raw_local_irq_restore(flags);
 }
 
-static inline void ____atomic_change_bit(unsigned int bit, volatile unsigned long *p)
+static inline void ____atomic_change_bit(unsigned int bit, unsigned long *p)
 {
 	unsigned long flags;
 	unsigned long mask = 1UL << (bit & 31);
@@ -71,7 +71,7 @@ static inline void ____atomic_change_bit
 }
 
 static inline int
-____atomic_test_and_set_bit(unsigned int bit, volatile unsigned long *p)
+____atomic_test_and_set_bit(unsigned int bit, unsigned long *p)
 {
 	unsigned long flags;
 	unsigned int res;
@@ -88,7 +88,7 @@ ____atomic_test_and_set_bit(unsigned int
 }
 
 static inline int
-____atomic_test_and_clear_bit(unsigned int bit, volatile unsigned long *p)
+____atomic_test_and_clear_bit(unsigned int bit, unsigned long *p)
 {
 	unsigned long flags;
 	unsigned int res;
@@ -105,7 +105,7 @@ ____atomic_test_and_clear_bit(unsigned i
 }
 
 static inline int
-____atomic_test_and_change_bit(unsigned int bit, volatile unsigned long *p)
+____atomic_test_and_change_bit(unsigned int bit, unsigned long *p)
 {
 	unsigned long flags;
 	unsigned int res;
@@ -151,12 +151,12 @@ ____atomic_test_and_change_bit(unsigned 
 /*
  * Little endian assembly bitops.  nr = 0 -> byte 0 bit 0.
  */
-extern void _set_bit_le(int nr, volatile unsigned long * p);
-extern void _clear_bit_le(int nr, volatile unsigned long * p);
-extern void _change_bit_le(int nr, volatile unsigned long * p);
-extern int _test_and_set_bit_le(int nr, volatile unsigned long * p);
-extern int _test_and_clear_bit_le(int nr, volatile unsigned long * p);
-extern int _test_and_change_bit_le(int nr, volatile unsigned long * p);
+extern void _set_bit_le(int nr, unsigned long * p);
+extern void _clear_bit_le(int nr, unsigned long * p);
+extern void _change_bit_le(int nr, unsigned long * p);
+extern int _test_and_set_bit_le(int nr, unsigned long * p);
+extern int _test_and_clear_bit_le(int nr, unsigned long * p);
+extern int _test_and_change_bit_le(int nr, unsigned long * p);
 extern int _find_first_zero_bit_le(const void * p, unsigned size);
 extern int _find_next_zero_bit_le(const void * p, int size, int offset);
 extern int _find_first_bit_le(const unsigned long *p, unsigned size);
@@ -165,12 +165,12 @@ extern int _find_next_bit_le(const unsig
 /*
  * Big endian assembly bitops.  nr = 0 -> byte 3 bit 0.
  */
-extern void _set_bit_be(int nr, volatile unsigned long * p);
-extern void _clear_bit_be(int nr, volatile unsigned long * p);
-extern void _change_bit_be(int nr, volatile unsigned long * p);
-extern int _test_and_set_bit_be(int nr, volatile unsigned long * p);
-extern int _test_and_clear_bit_be(int nr, volatile unsigned long * p);
-extern int _test_and_change_bit_be(int nr, volatile unsigned long * p);
+extern void _set_bit_be(int nr, unsigned long * p);
+extern void _clear_bit_be(int nr, unsigned long * p);
+extern void _change_bit_be(int nr, unsigned long * p);
+extern int _test_and_set_bit_be(int nr, unsigned long * p);
+extern int _test_and_clear_bit_be(int nr, unsigned long * p);
+extern int _test_and_change_bit_be(int nr, unsigned long * p);
 extern int _find_first_zero_bit_be(const void * p, unsigned size);
 extern int _find_next_zero_bit_be(const void * p, int size, int offset);
 extern int _find_first_bit_be(const unsigned long *p, unsigned size);
Index: linux-2.6/arch/avr32/include/asm/bitops.h
===================================================================
--- linux-2.6.orig/arch/avr32/include/asm/bitops.h	2008-09-01 21:57:27.000000000 +1000
+++ linux-2.6/arch/avr32/include/asm/bitops.h	2008-09-01 21:57:50.000000000 +1000
@@ -32,7 +32,7 @@
  * Note that @nr may be almost arbitrarily large; this function is not
  * restricted to acting on a single-word quantity.
  */
-static inline void set_bit(int nr, volatile void * addr)
+static inline void set_bit(int nr, void * addr)
 {
 	unsigned long *p = ((unsigned long *)addr) + nr / BITS_PER_LONG;
 	unsigned long tmp;
@@ -71,7 +71,7 @@ static inline void set_bit(int nr, volat
  * you should call smp_mb__before_clear_bit() and/or smp_mb__after_clear_bit()
  * in order to ensure changes are visible on other processors.
  */
-static inline void clear_bit(int nr, volatile void * addr)
+static inline void clear_bit(int nr, void * addr)
 {
 	unsigned long *p = ((unsigned long *)addr) + nr / BITS_PER_LONG;
 	unsigned long tmp;
@@ -109,7 +109,7 @@ static inline void clear_bit(int nr, vol
  * Note that @nr may be almost arbitrarily large; this function is not
  * restricted to acting on a single-word quantity.
  */
-static inline void change_bit(int nr, volatile void * addr)
+static inline void change_bit(int nr, void * addr)
 {
 	unsigned long *p = ((unsigned long *)addr) + nr / BITS_PER_LONG;
 	unsigned long mask = 1UL << (nr % BITS_PER_LONG);
@@ -134,7 +134,7 @@ static inline void change_bit(int nr, vo
  * This operation is atomic and cannot be reordered.
  * It also implies a memory barrier.
  */
-static inline int test_and_set_bit(int nr, volatile void * addr)
+static inline int test_and_set_bit(int nr, void * addr)
 {
 	unsigned long *p = ((unsigned long *)addr) + nr / BITS_PER_LONG;
 	unsigned long mask = 1UL << (nr % BITS_PER_LONG);
@@ -174,7 +174,7 @@ static inline int test_and_set_bit(int n
  * This operation is atomic and cannot be reordered.
  * It also implies a memory barrier.
  */
-static inline int test_and_clear_bit(int nr, volatile void * addr)
+static inline int test_and_clear_bit(int nr, void * addr)
 {
 	unsigned long *p = ((unsigned long *)addr) + nr / BITS_PER_LONG;
 	unsigned long mask = 1UL << (nr % BITS_PER_LONG);
@@ -215,7 +215,7 @@ static inline int test_and_clear_bit(int
  * This operation is atomic and cannot be reordered.
  * It also implies a memory barrier.
  */
-static inline int test_and_change_bit(int nr, volatile void * addr)
+static inline int test_and_change_bit(int nr, void * addr)
 {
 	unsigned long *p = ((unsigned long *)addr) + nr / BITS_PER_LONG;
 	unsigned long mask = 1UL << (nr % BITS_PER_LONG);
Index: linux-2.6/arch/blackfin/include/asm/bitops.h
===================================================================
--- linux-2.6.orig/arch/blackfin/include/asm/bitops.h	2008-09-01 21:57:27.000000000 +1000
+++ linux-2.6/arch/blackfin/include/asm/bitops.h	2008-09-01 21:57:50.000000000 +1000
@@ -20,7 +20,7 @@
 #include <asm-generic/bitops/sched.h>
 #include <asm-generic/bitops/ffz.h>
 
-static __inline__ void set_bit(int nr, volatile unsigned long *addr)
+static __inline__ void set_bit(int nr, unsigned long *addr)
 {
 	int *a = (int *)addr;
 	int mask;
@@ -33,7 +33,7 @@ static __inline__ void set_bit(int nr, v
 	local_irq_restore(flags);
 }
 
-static __inline__ void __set_bit(int nr, volatile unsigned long *addr)
+static __inline__ void __set_bit(int nr, unsigned long *addr)
 {
 	int *a = (int *)addr;
 	int mask;
@@ -49,7 +49,7 @@ static __inline__ void __set_bit(int nr,
 #define smp_mb__before_clear_bit()	barrier()
 #define smp_mb__after_clear_bit()	barrier()
 
-static __inline__ void clear_bit(int nr, volatile unsigned long *addr)
+static __inline__ void clear_bit(int nr, unsigned long *addr)
 {
 	int *a = (int *)addr;
 	int mask;
@@ -61,7 +61,7 @@ static __inline__ void clear_bit(int nr,
 	local_irq_restore(flags);
 }
 
-static __inline__ void __clear_bit(int nr, volatile unsigned long *addr)
+static __inline__ void __clear_bit(int nr, unsigned long *addr)
 {
 	int *a = (int *)addr;
 	int mask;
@@ -71,7 +71,7 @@ static __inline__ void __clear_bit(int n
 	*a &= ~mask;
 }
 
-static __inline__ void change_bit(int nr, volatile unsigned long *addr)
+static __inline__ void change_bit(int nr, unsigned long *addr)
 {
 	int mask, flags;
 	unsigned long *ADDR = (unsigned long *)addr;
@@ -83,7 +83,7 @@ static __inline__ void change_bit(int nr
 	local_irq_restore(flags);
 }
 
-static __inline__ void __change_bit(int nr, volatile unsigned long *addr)
+static __inline__ void __change_bit(int nr, unsigned long *addr)
 {
 	int mask;
 	unsigned long *ADDR = (unsigned long *)addr;
@@ -96,7 +96,7 @@ static __inline__ void __change_bit(int 
 static __inline__ int test_and_set_bit(int nr, void *addr)
 {
 	int mask, retval;
-	volatile unsigned int *a = (volatile unsigned int *)addr;
+	unsigned int *a = (unsigned int *)addr;
 	unsigned long flags;
 
 	a += nr >> 5;
@@ -109,10 +109,10 @@ static __inline__ int test_and_set_bit(i
 	return retval;
 }
 
-static __inline__ int __test_and_set_bit(int nr, volatile unsigned long *addr)
+static __inline__ int __test_and_set_bit(int nr, unsigned long *addr)
 {
 	int mask, retval;
-	volatile unsigned int *a = (volatile unsigned int *)addr;
+	unsigned int *a = (unsigned int *)addr;
 
 	a += nr >> 5;
 	mask = 1 << (nr & 0x1f);
@@ -121,10 +121,10 @@ static __inline__ int __test_and_set_bit
 	return retval;
 }
 
-static __inline__ int test_and_clear_bit(int nr, volatile unsigned long *addr)
+static __inline__ int test_and_clear_bit(int nr, unsigned long *addr)
 {
 	int mask, retval;
-	volatile unsigned int *a = (volatile unsigned int *)addr;
+	unsigned int *a = (unsigned int *)addr;
 	unsigned long flags;
 
 	a += nr >> 5;
@@ -137,10 +137,10 @@ static __inline__ int test_and_clear_bit
 	return retval;
 }
 
-static __inline__ int __test_and_clear_bit(int nr, volatile unsigned long *addr)
+static __inline__ int __test_and_clear_bit(int nr, unsigned long *addr)
 {
 	int mask, retval;
-	volatile unsigned int *a = (volatile unsigned int *)addr;
+	unsigned int *a = (unsigned int *)addr;
 
 	a += nr >> 5;
 	mask = 1 << (nr & 0x1f);
@@ -149,10 +149,10 @@ static __inline__ int __test_and_clear_b
 	return retval;
 }
 
-static __inline__ int test_and_change_bit(int nr, volatile unsigned long *addr)
+static __inline__ int test_and_change_bit(int nr, unsigned long *addr)
 {
 	int mask, retval;
-	volatile unsigned int *a = (volatile unsigned int *)addr;
+	unsigned int *a = (unsigned int *)addr;
 	unsigned long flags;
 
 	a += nr >> 5;
@@ -165,10 +165,10 @@ static __inline__ int test_and_change_bi
 }
 
 static __inline__ int __test_and_change_bit(int nr,
-					    volatile unsigned long *addr)
+					    unsigned long *addr)
 {
 	int mask, retval;
-	volatile unsigned int *a = (volatile unsigned int *)addr;
+	unsigned int *a = (unsigned int *)addr;
 
 	a += nr >> 5;
 	mask = 1 << (nr & 0x1f);
@@ -183,7 +183,7 @@ static __inline__ int __test_and_change_
 static __inline__ int __constant_test_bit(int nr, const void *addr)
 {
 	return ((1UL << (nr & 31)) &
-		(((const volatile unsigned int *)addr)[nr >> 5])) != 0;
+		(((const unsigned int *)addr)[nr >> 5])) != 0;
 }
 
 static __inline__ int __test_bit(int nr, const void *addr)
Index: linux-2.6/arch/ia64/include/asm/bitops.h
===================================================================
--- linux-2.6.orig/arch/ia64/include/asm/bitops.h	2008-09-01 21:57:27.000000000 +1000
+++ linux-2.6/arch/ia64/include/asm/bitops.h	2008-09-01 21:57:50.000000000 +1000
@@ -35,7 +35,7 @@
  * bit 0 is the LSB of addr; bit 32 is the LSB of (addr+1).
  */
 static __inline__ void
-set_bit (int nr, volatile void *addr)
+set_bit (int nr, void *addr)
 {
 	__u32 bit, old, new;
 	volatile __u32 *m;
@@ -60,7 +60,7 @@ set_bit (int nr, volatile void *addr)
  * may be that only one operation succeeds.
  */
 static __inline__ void
-__set_bit (int nr, volatile void *addr)
+__set_bit (int nr, void *addr)
 {
 	*((__u32 *) addr + (nr >> 5)) |= (1 << (nr & 31));
 }
@@ -82,7 +82,7 @@ __set_bit (int nr, volatile void *addr)
  * in order to ensure changes are visible on other processors.
  */
 static __inline__ void
-clear_bit (int nr, volatile void *addr)
+clear_bit (int nr, void *addr)
 {
 	__u32 mask, old, new;
 	volatile __u32 *m;
@@ -106,7 +106,7 @@ clear_bit (int nr, volatile void *addr)
  * contain a memory barrier suitable for unlock type operations.
  */
 static __inline__ void
-clear_bit_unlock (int nr, volatile void *addr)
+clear_bit_unlock (int nr, void *addr)
 {
 	__u32 mask, old, new;
 	volatile __u32 *m;
@@ -148,7 +148,7 @@ __clear_bit_unlock(int nr, void *addr)
  * may be that only one operation succeeds.
  */
 static __inline__ void
-__clear_bit (int nr, volatile void *addr)
+__clear_bit (int nr, void *addr)
 {
 	*((__u32 *) addr + (nr >> 5)) &= ~(1 << (nr & 31));
 }
@@ -163,7 +163,7 @@ __clear_bit (int nr, volatile void *addr
  * restricted to acting on a single-word quantity.
  */
 static __inline__ void
-change_bit (int nr, volatile void *addr)
+change_bit (int nr, void *addr)
 {
 	__u32 bit, old, new;
 	volatile __u32 *m;
@@ -188,7 +188,7 @@ change_bit (int nr, volatile void *addr)
  * may be that only one operation succeeds.
  */
 static __inline__ void
-__change_bit (int nr, volatile void *addr)
+__change_bit (int nr, void *addr)
 {
 	*((__u32 *) addr + (nr >> 5)) ^= (1 << (nr & 31));
 }
@@ -202,7 +202,7 @@ __change_bit (int nr, volatile void *add
  * It also implies the acquisition side of the memory barrier.
  */
 static __inline__ int
-test_and_set_bit (int nr, volatile void *addr)
+test_and_set_bit (int nr, void *addr)
 {
 	__u32 bit, old, new;
 	volatile __u32 *m;
@@ -237,7 +237,7 @@ test_and_set_bit (int nr, volatile void 
  * but actually fail.  You must protect multiple accesses with a lock.
  */
 static __inline__ int
-__test_and_set_bit (int nr, volatile void *addr)
+__test_and_set_bit (int nr, void *addr)
 {
 	__u32 *p = (__u32 *) addr + (nr >> 5);
 	__u32 m = 1 << (nr & 31);
@@ -256,7 +256,7 @@ __test_and_set_bit (int nr, volatile voi
  * It also implies the acquisition side of the memory barrier.
  */
 static __inline__ int
-test_and_clear_bit (int nr, volatile void *addr)
+test_and_clear_bit (int nr, void *addr)
 {
 	__u32 mask, old, new;
 	volatile __u32 *m;
@@ -282,7 +282,7 @@ test_and_clear_bit (int nr, volatile voi
  * but actually fail.  You must protect multiple accesses with a lock.
  */
 static __inline__ int
-__test_and_clear_bit(int nr, volatile void * addr)
+__test_and_clear_bit(int nr, void * addr)
 {
 	__u32 *p = (__u32 *) addr + (nr >> 5);
 	__u32 m = 1 << (nr & 31);
@@ -301,7 +301,7 @@ __test_and_clear_bit(int nr, volatile vo
  * It also implies the acquisition side of the memory barrier.
  */
 static __inline__ int
-test_and_change_bit (int nr, volatile void *addr)
+test_and_change_bit (int nr, void *addr)
 {
 	__u32 bit, old, new;
 	volatile __u32 *m;
@@ -336,7 +336,7 @@ __test_and_change_bit (int nr, void *add
 }
 
 static __inline__ int
-test_bit (int nr, const volatile void *addr)
+test_bit (int nr, const void *addr)
 {
 	return 1 & (((const volatile __u32 *) addr)[nr >> 5] >> (nr & 31));
 }
Index: linux-2.6/arch/ia64/sn/kernel/irq.c
===================================================================
--- linux-2.6.orig/arch/ia64/sn/kernel/irq.c	2008-09-01 21:57:27.000000000 +1000
+++ linux-2.6/arch/ia64/sn/kernel/irq.c	2008-09-01 21:57:50.000000000 +1000
@@ -108,7 +108,7 @@ static void sn_ack_irq(unsigned int irq)
 	event_occurred = HUB_L((u64*)LOCAL_MMR_ADDR(SH_EVENT_OCCURRED));
 	mask = event_occurred & SH_ALL_INT_MASK;
 	HUB_S((u64*)LOCAL_MMR_ADDR(SH_EVENT_OCCURRED_ALIAS), mask);
-	__set_bit(irq, (volatile void *)pda->sn_in_service_ivecs);
+	__set_bit(irq, (void *)pda->sn_in_service_ivecs);
 
 	move_native_irq(irq);
 }
@@ -130,7 +130,7 @@ static void sn_end_irq(unsigned int irq)
 					  IA64_IPI_DM_INT, 0);
 		}
 	}
-	__clear_bit(ivec, (volatile void *)pda->sn_in_service_ivecs);
+	__clear_bit(ivec, (void *)pda->sn_in_service_ivecs);
 	if (sn_force_interrupt_flag)
 		force_interrupt(irq);
 }
Index: linux-2.6/arch/m68knommu/include/asm/bitops.h
===================================================================
--- linux-2.6.orig/arch/m68knommu/include/asm/bitops.h	2008-09-01 21:57:27.000000000 +1000
+++ linux-2.6/arch/m68knommu/include/asm/bitops.h	2008-09-01 21:57:50.000000000 +1000
@@ -49,7 +49,7 @@ static inline int __ffs(unsigned int val
 #include <asm-generic/bitops/sched.h>
 #include <asm-generic/bitops/ffz.h>
 
-static __inline__ void set_bit(int nr, volatile unsigned long * addr)
+static __inline__ void set_bit(int nr, unsigned long * addr)
 {
 #ifdef CONFIG_COLDFIRE
 	__asm__ __volatile__ ("lea %0,%%a0; bset %1,(%%a0)"
@@ -72,7 +72,7 @@ static __inline__ void set_bit(int nr, v
 #define smp_mb__before_clear_bit()	barrier()
 #define smp_mb__after_clear_bit()	barrier()
 
-static __inline__ void clear_bit(int nr, volatile unsigned long * addr)
+static __inline__ void clear_bit(int nr, unsigned long * addr)
 {
 #ifdef CONFIG_COLDFIRE
 	__asm__ __volatile__ ("lea %0,%%a0; bclr %1,(%%a0)"
@@ -89,7 +89,7 @@ static __inline__ void clear_bit(int nr,
 
 #define __clear_bit(nr, addr) clear_bit(nr, addr)
 
-static __inline__ void change_bit(int nr, volatile unsigned long * addr)
+static __inline__ void change_bit(int nr, unsigned long * addr)
 {
 #ifdef CONFIG_COLDFIRE
 	__asm__ __volatile__ ("lea %0,%%a0; bchg %1,(%%a0)"
@@ -106,7 +106,7 @@ static __inline__ void change_bit(int nr
 
 #define __change_bit(nr, addr) change_bit(nr, addr)
 
-static __inline__ int test_and_set_bit(int nr, volatile unsigned long * addr)
+static __inline__ int test_and_set_bit(int nr, unsigned long * addr)
 {
 	char retval;
 
@@ -127,7 +127,7 @@ static __inline__ int test_and_set_bit(i
 
 #define __test_and_set_bit(nr, addr) test_and_set_bit(nr, addr)
 
-static __inline__ int test_and_clear_bit(int nr, volatile unsigned long * addr)
+static __inline__ int test_and_clear_bit(int nr, unsigned long * addr)
 {
 	char retval;
 
@@ -148,7 +148,7 @@ static __inline__ int test_and_clear_bit
 
 #define __test_and_clear_bit(nr, addr) test_and_clear_bit(nr, addr)
 
-static __inline__ int test_and_change_bit(int nr, volatile unsigned long * addr)
+static __inline__ int test_and_change_bit(int nr, unsigned long * addr)
 {
 	char retval;
 
@@ -172,12 +172,12 @@ static __inline__ int test_and_change_bi
 /*
  * This routine doesn't need to be atomic.
  */
-static __inline__ int __constant_test_bit(int nr, const volatile unsigned long * addr)
+static __inline__ int __constant_test_bit(int nr, const unsigned long * addr)
 {
-	return ((1UL << (nr & 31)) & (((const volatile unsigned int *) addr)[nr >> 5])) != 0;
+	return ((1UL << (nr & 31)) & (((const unsigned int *) addr)[nr >> 5])) != 0;
 }
 
-static __inline__ int __test_bit(int nr, const volatile unsigned long * addr)
+static __inline__ int __test_bit(int nr, const unsigned long * addr)
 {
 	int 	* a = (int *) addr;
 	int	mask;
@@ -196,7 +196,7 @@ static __inline__ int __test_bit(int nr,
 #include <asm-generic/bitops/hweight.h>
 #include <asm-generic/bitops/lock.h>
 
-static __inline__ int ext2_set_bit(int nr, volatile void * addr)
+static __inline__ int ext2_set_bit(int nr, void * addr)
 {
 	char retval;
 
@@ -215,7 +215,7 @@ static __inline__ int ext2_set_bit(int n
 	return retval;
 }
 
-static __inline__ int ext2_clear_bit(int nr, volatile void * addr)
+static __inline__ int ext2_clear_bit(int nr, void * addr)
 {
 	char retval;
 
@@ -252,7 +252,7 @@ static __inline__ int ext2_clear_bit(int
 		ret;					\
 	})
 
-static __inline__ int ext2_test_bit(int nr, const volatile void * addr)
+static __inline__ int ext2_test_bit(int nr, const void * addr)
 {
 	char retval;
 
Index: linux-2.6/arch/mn10300/lib/bitops.c
===================================================================
--- linux-2.6.orig/arch/mn10300/lib/bitops.c	2008-09-01 21:57:27.000000000 +1000
+++ linux-2.6/arch/mn10300/lib/bitops.c	2008-09-01 21:57:50.000000000 +1000
@@ -15,7 +15,7 @@
 /*
  * try flipping a bit using BSET and BCLR
  */
-void change_bit(int nr, volatile void *addr)
+void change_bit(int nr, void *addr)
 {
 	if (test_bit(nr, addr))
 		goto try_clear_bit;
@@ -34,7 +34,7 @@ try_clear_bit:
 /*
  * try flipping a bit using BSET and BCLR and returning the old value
  */
-int test_and_change_bit(int nr, volatile void *addr)
+int test_and_change_bit(int nr, void *addr)
 {
 	if (test_bit(nr, addr))
 		goto try_clear_bit;
Index: linux-2.6/arch/powerpc/include/asm/bitops.h
===================================================================
--- linux-2.6.orig/arch/powerpc/include/asm/bitops.h	2008-09-01 21:57:27.000000000 +1000
+++ linux-2.6/arch/powerpc/include/asm/bitops.h	2008-09-01 21:57:50.000000000 +1000
@@ -56,7 +56,7 @@
 #define BITOP_WORD(nr)		((nr) / BITS_PER_LONG)
 #define BITOP_LE_SWIZZLE	((BITS_PER_LONG-1) & ~0x7)
 
-static __inline__ void set_bit(int nr, volatile unsigned long *addr)
+static __inline__ void set_bit(int nr, unsigned long *addr)
 {
 	unsigned long old;
 	unsigned long mask = BITOP_MASK(nr);
@@ -73,7 +73,7 @@ static __inline__ void set_bit(int nr, v
 	: "cc" );
 }
 
-static __inline__ void clear_bit(int nr, volatile unsigned long *addr)
+static __inline__ void clear_bit(int nr, unsigned long *addr)
 {
 	unsigned long old;
 	unsigned long mask = BITOP_MASK(nr);
@@ -90,7 +90,7 @@ static __inline__ void clear_bit(int nr,
 	: "cc" );
 }
 
-static __inline__ void clear_bit_unlock(int nr, volatile unsigned long *addr)
+static __inline__ void clear_bit_unlock(int nr, unsigned long *addr)
 {
 	unsigned long old;
 	unsigned long mask = BITOP_MASK(nr);
@@ -108,7 +108,7 @@ static __inline__ void clear_bit_unlock(
 	: "cc", "memory");
 }
 
-static __inline__ void change_bit(int nr, volatile unsigned long *addr)
+static __inline__ void change_bit(int nr, unsigned long *addr)
 {
 	unsigned long old;
 	unsigned long mask = BITOP_MASK(nr);
@@ -126,7 +126,7 @@ static __inline__ void change_bit(int nr
 }
 
 static __inline__ int test_and_set_bit(unsigned long nr,
-				       volatile unsigned long *addr)
+				       unsigned long *addr)
 {
 	unsigned long old, t;
 	unsigned long mask = BITOP_MASK(nr);
@@ -148,7 +148,7 @@ static __inline__ int test_and_set_bit(u
 }
 
 static __inline__ int test_and_set_bit_lock(unsigned long nr,
-				       volatile unsigned long *addr)
+				       unsigned long *addr)
 {
 	unsigned long old, t;
 	unsigned long mask = BITOP_MASK(nr);
@@ -169,7 +169,7 @@ static __inline__ int test_and_set_bit_l
 }
 
 static __inline__ int test_and_clear_bit(unsigned long nr,
-					 volatile unsigned long *addr)
+					 unsigned long *addr)
 {
 	unsigned long old, t;
 	unsigned long mask = BITOP_MASK(nr);
@@ -191,7 +191,7 @@ static __inline__ int test_and_clear_bit
 }
 
 static __inline__ int test_and_change_bit(unsigned long nr,
-					  volatile unsigned long *addr)
+					  unsigned long *addr)
 {
 	unsigned long old, t;
 	unsigned long mask = BITOP_MASK(nr);
@@ -228,7 +228,7 @@ static __inline__ void set_bits(unsigned
 
 #include <asm-generic/bitops/non-atomic.h>
 
-static __inline__ void __clear_bit_unlock(int nr, volatile unsigned long *addr)
+static __inline__ void __clear_bit_unlock(int nr, unsigned long *addr)
 {
 	__asm__ __volatile__(LWSYNC_ON_SMP "" ::: "memory");
 	__clear_bit(nr, addr);
Index: linux-2.6/arch/s390/include/asm/bitops.h
===================================================================
--- linux-2.6.orig/arch/s390/include/asm/bitops.h	2008-09-01 21:57:27.000000000 +1000
+++ linux-2.6/arch/s390/include/asm/bitops.h	2008-09-01 21:57:50.000000000 +1000
@@ -149,7 +149,7 @@ extern const char _sb_findmap[];
 /*
  * SMP safe set_bit routine based on compare and swap (CS)
  */
-static inline void set_bit_cs(unsigned long nr, volatile unsigned long *ptr)
+static inline void set_bit_cs(unsigned long nr, unsigned long *ptr)
 {
         unsigned long addr, old, new, mask;
 
@@ -165,7 +165,7 @@ static inline void set_bit_cs(unsigned l
 /*
  * SMP safe clear_bit routine based on compare and swap (CS)
  */
-static inline void clear_bit_cs(unsigned long nr, volatile unsigned long *ptr)
+static inline void clear_bit_cs(unsigned long nr, unsigned long *ptr)
 {
         unsigned long addr, old, new, mask;
 
@@ -181,7 +181,7 @@ static inline void clear_bit_cs(unsigned
 /*
  * SMP safe change_bit routine based on compare and swap (CS)
  */
-static inline void change_bit_cs(unsigned long nr, volatile unsigned long *ptr)
+static inline void change_bit_cs(unsigned long nr, unsigned long *ptr)
 {
         unsigned long addr, old, new, mask;
 
@@ -198,7 +198,7 @@ static inline void change_bit_cs(unsigne
  * SMP safe test_and_set_bit routine based on compare and swap (CS)
  */
 static inline int
-test_and_set_bit_cs(unsigned long nr, volatile unsigned long *ptr)
+test_and_set_bit_cs(unsigned long nr, unsigned long *ptr)
 {
         unsigned long addr, old, new, mask;
 
@@ -217,7 +217,7 @@ test_and_set_bit_cs(unsigned long nr, vo
  * SMP safe test_and_clear_bit routine based on compare and swap (CS)
  */
 static inline int
-test_and_clear_bit_cs(unsigned long nr, volatile unsigned long *ptr)
+test_and_clear_bit_cs(unsigned long nr, unsigned long *ptr)
 {
         unsigned long addr, old, new, mask;
 
@@ -236,7 +236,7 @@ test_and_clear_bit_cs(unsigned long nr, 
  * SMP safe test_and_change_bit routine based on compare and swap (CS) 
  */
 static inline int
-test_and_change_bit_cs(unsigned long nr, volatile unsigned long *ptr)
+test_and_change_bit_cs(unsigned long nr, unsigned long *ptr)
 {
         unsigned long addr, old, new, mask;
 
@@ -255,7 +255,7 @@ test_and_change_bit_cs(unsigned long nr,
 /*
  * fast, non-SMP set_bit routine
  */
-static inline void __set_bit(unsigned long nr, volatile unsigned long *ptr)
+static inline void __set_bit(unsigned long nr, unsigned long *ptr)
 {
 	unsigned long addr;
 
@@ -267,7 +267,7 @@ static inline void __set_bit(unsigned lo
 }
 
 static inline void 
-__constant_set_bit(const unsigned long nr, volatile unsigned long *ptr)
+__constant_set_bit(const unsigned long nr, unsigned long *ptr)
 {
 	unsigned long addr;
 
@@ -284,7 +284,7 @@ __constant_set_bit(const unsigned long n
  * fast, non-SMP clear_bit routine
  */
 static inline void 
-__clear_bit(unsigned long nr, volatile unsigned long *ptr)
+__clear_bit(unsigned long nr, unsigned long *ptr)
 {
 	unsigned long addr;
 
@@ -296,7 +296,7 @@ __clear_bit(unsigned long nr, volatile u
 }
 
 static inline void 
-__constant_clear_bit(const unsigned long nr, volatile unsigned long *ptr)
+__constant_clear_bit(const unsigned long nr, unsigned long *ptr)
 {
 	unsigned long addr;
 
@@ -312,7 +312,7 @@ __constant_clear_bit(const unsigned long
 /* 
  * fast, non-SMP change_bit routine 
  */
-static inline void __change_bit(unsigned long nr, volatile unsigned long *ptr)
+static inline void __change_bit(unsigned long nr, unsigned long *ptr)
 {
 	unsigned long addr;
 
@@ -324,7 +324,7 @@ static inline void __change_bit(unsigned
 }
 
 static inline void 
-__constant_change_bit(const unsigned long nr, volatile unsigned long *ptr) 
+__constant_change_bit(const unsigned long nr, unsigned long *ptr)
 {
 	unsigned long addr;
 
@@ -341,7 +341,7 @@ __constant_change_bit(const unsigned lon
  * fast, non-SMP test_and_set_bit routine
  */
 static inline int
-test_and_set_bit_simple(unsigned long nr, volatile unsigned long *ptr)
+test_and_set_bit_simple(unsigned long nr, unsigned long *ptr)
 {
 	unsigned long addr;
 	unsigned char ch;
@@ -361,7 +361,7 @@ test_and_set_bit_simple(unsigned long nr
  * fast, non-SMP test_and_clear_bit routine
  */
 static inline int
-test_and_clear_bit_simple(unsigned long nr, volatile unsigned long *ptr)
+test_and_clear_bit_simple(unsigned long nr, unsigned long *ptr)
 {
 	unsigned long addr;
 	unsigned char ch;
@@ -381,7 +381,7 @@ test_and_clear_bit_simple(unsigned long 
  * fast, non-SMP test_and_change_bit routine
  */
 static inline int
-test_and_change_bit_simple(unsigned long nr, volatile unsigned long *ptr)
+test_and_change_bit_simple(unsigned long nr, unsigned long *ptr)
 {
 	unsigned long addr;
 	unsigned char ch;
@@ -418,18 +418,18 @@ test_and_change_bit_simple(unsigned long
  * This routine doesn't need to be atomic.
  */
 
-static inline int __test_bit(unsigned long nr, const volatile unsigned long *ptr)
+static inline int __test_bit(unsigned long nr, const unsigned long *ptr)
 {
 	unsigned long addr;
 	unsigned char ch;
 
 	addr = (unsigned long) ptr + ((nr ^ (__BITOPS_WORDSIZE - 8)) >> 3);
-	ch = *(volatile unsigned char *) addr;
+	ch = *(unsigned char *) addr;
 	return (ch >> (nr & 7)) & 1;
 }
 
 static inline int 
-__constant_test_bit(unsigned long nr, const volatile unsigned long *addr) {
+__constant_test_bit(unsigned long nr, const unsigned long *addr) {
     return (((volatile char *) addr)
 	    [(nr^(__BITOPS_WORDSIZE-8))>>3] & (1<<(nr&7))) != 0;
 }
Index: linux-2.6/arch/sh/include/asm/bitops-grb.h
===================================================================
--- linux-2.6.orig/arch/sh/include/asm/bitops-grb.h	2008-09-01 21:57:27.000000000 +1000
+++ linux-2.6/arch/sh/include/asm/bitops-grb.h	2008-09-01 21:57:50.000000000 +1000
@@ -1,10 +1,10 @@
 #ifndef __ASM_SH_BITOPS_GRB_H
 #define __ASM_SH_BITOPS_GRB_H
 
-static inline void set_bit(int nr, volatile void * addr)
+static inline void set_bit(int nr, void * addr)
 {
 	int	mask;
-	volatile unsigned int *a = addr;
+	unsigned int *a = addr;
 	unsigned long tmp;
 
 	a += nr >> 5;
@@ -25,10 +25,10 @@ static inline void set_bit(int nr, volat
                 : "memory" , "r0", "r1");
 }
 
-static inline void clear_bit(int nr, volatile void * addr)
+static inline void clear_bit(int nr, void * addr)
 {
 	int	mask;
-	volatile unsigned int *a = addr;
+	unsigned int *a = addr;
         unsigned long tmp;
 
 	a += nr >> 5;
@@ -48,10 +48,10 @@ static inline void clear_bit(int nr, vol
                 : "memory" , "r0", "r1");
 }
 
-static inline void change_bit(int nr, volatile void * addr)
+static inline void change_bit(int nr, void * addr)
 {
         int     mask;
-        volatile unsigned int *a = addr;
+        unsigned int *a = addr;
         unsigned long tmp;
 
         a += nr >> 5;
@@ -71,10 +71,10 @@ static inline void change_bit(int nr, vo
                 : "memory" , "r0", "r1");
 }
 
-static inline int test_and_set_bit(int nr, volatile void * addr)
+static inline int test_and_set_bit(int nr, void * addr)
 {
         int     mask, retval;
-	volatile unsigned int *a = addr;
+	unsigned int *a = addr;
         unsigned long tmp;
 
 	a += nr >> 5;
@@ -102,10 +102,10 @@ static inline int test_and_set_bit(int n
         return retval;
 }
 
-static inline int test_and_clear_bit(int nr, volatile void * addr)
+static inline int test_and_clear_bit(int nr, void * addr)
 {
         int     mask, retval,not_mask;
-        volatile unsigned int *a = addr;
+        unsigned int *a = addr;
         unsigned long tmp;
 
         a += nr >> 5;
@@ -136,10 +136,10 @@ static inline int test_and_clear_bit(int
         return retval;
 }
 
-static inline int test_and_change_bit(int nr, volatile void * addr)
+static inline int test_and_change_bit(int nr, void * addr)
 {
         int     mask, retval;
-        volatile unsigned int *a = addr;
+        unsigned int *a = addr;
         unsigned long tmp;
 
         a += nr >> 5;
Index: linux-2.6/arch/sh/include/asm/bitops-irq.h
===================================================================
--- linux-2.6.orig/arch/sh/include/asm/bitops-irq.h	2008-09-01 21:57:27.000000000 +1000
+++ linux-2.6/arch/sh/include/asm/bitops-irq.h	2008-09-01 21:57:50.000000000 +1000
@@ -1,10 +1,10 @@
 #ifndef __ASM_SH_BITOPS_IRQ_H
 #define __ASM_SH_BITOPS_IRQ_H
 
-static inline void set_bit(int nr, volatile void *addr)
+static inline void set_bit(int nr, void *addr)
 {
 	int	mask;
-	volatile unsigned int *a = addr;
+	unsigned int *a = addr;
 	unsigned long flags;
 
 	a += nr >> 5;
@@ -14,10 +14,10 @@ static inline void set_bit(int nr, volat
 	local_irq_restore(flags);
 }
 
-static inline void clear_bit(int nr, volatile void *addr)
+static inline void clear_bit(int nr, void *addr)
 {
 	int	mask;
-	volatile unsigned int *a = addr;
+	unsigned int *a = addr;
 	unsigned long flags;
 
 	a += nr >> 5;
@@ -27,10 +27,10 @@ static inline void clear_bit(int nr, vol
 	local_irq_restore(flags);
 }
 
-static inline void change_bit(int nr, volatile void *addr)
+static inline void change_bit(int nr, void *addr)
 {
 	int	mask;
-	volatile unsigned int *a = addr;
+	unsigned int *a = addr;
 	unsigned long flags;
 
 	a += nr >> 5;
@@ -40,10 +40,10 @@ static inline void change_bit(int nr, vo
 	local_irq_restore(flags);
 }
 
-static inline int test_and_set_bit(int nr, volatile void *addr)
+static inline int test_and_set_bit(int nr, void *addr)
 {
 	int	mask, retval;
-	volatile unsigned int *a = addr;
+	unsigned int *a = addr;
 	unsigned long flags;
 
 	a += nr >> 5;
@@ -56,10 +56,10 @@ static inline int test_and_set_bit(int n
 	return retval;
 }
 
-static inline int test_and_clear_bit(int nr, volatile void *addr)
+static inline int test_and_clear_bit(int nr, void *addr)
 {
 	int	mask, retval;
-	volatile unsigned int *a = addr;
+	unsigned int *a = addr;
 	unsigned long flags;
 
 	a += nr >> 5;
@@ -72,10 +72,10 @@ static inline int test_and_clear_bit(int
 	return retval;
 }
 
-static inline int test_and_change_bit(int nr, volatile void *addr)
+static inline int test_and_change_bit(int nr, void *addr)
 {
 	int	mask, retval;
-	volatile unsigned int *a = addr;
+	unsigned int *a = addr;
 	unsigned long flags;
 
 	a += nr >> 5;
Index: linux-2.6/arch/sparc/include/asm/bitops_32.h
===================================================================
--- linux-2.6.orig/arch/sparc/include/asm/bitops_32.h	2008-09-01 21:57:27.000000000 +1000
+++ linux-2.6/arch/sparc/include/asm/bitops_32.h	2008-09-01 21:57:50.000000000 +1000
@@ -28,7 +28,7 @@ extern unsigned long ___change_bit(unsig
  * within the first byte. Sparc is BIG-Endian. Unless noted otherwise
  * all bit-ops return 0 if bit was previously clear and != 0 otherwise.
  */
-static inline int test_and_set_bit(unsigned long nr, volatile unsigned long *addr)
+static inline int test_and_set_bit(unsigned long nr, unsigned long *addr)
 {
 	unsigned long *ADDR, mask;
 
@@ -38,7 +38,7 @@ static inline int test_and_set_bit(unsig
 	return ___set_bit(ADDR, mask) != 0;
 }
 
-static inline void set_bit(unsigned long nr, volatile unsigned long *addr)
+static inline void set_bit(unsigned long nr, unsigned long *addr)
 {
 	unsigned long *ADDR, mask;
 
@@ -48,7 +48,7 @@ static inline void set_bit(unsigned long
 	(void) ___set_bit(ADDR, mask);
 }
 
-static inline int test_and_clear_bit(unsigned long nr, volatile unsigned long *addr)
+static inline int test_and_clear_bit(unsigned long nr, unsigned long *addr)
 {
 	unsigned long *ADDR, mask;
 
@@ -58,7 +58,7 @@ static inline int test_and_clear_bit(uns
 	return ___clear_bit(ADDR, mask) != 0;
 }
 
-static inline void clear_bit(unsigned long nr, volatile unsigned long *addr)
+static inline void clear_bit(unsigned long nr, unsigned long *addr)
 {
 	unsigned long *ADDR, mask;
 
@@ -68,7 +68,7 @@ static inline void clear_bit(unsigned lo
 	(void) ___clear_bit(ADDR, mask);
 }
 
-static inline int test_and_change_bit(unsigned long nr, volatile unsigned long *addr)
+static inline int test_and_change_bit(unsigned long nr, unsigned long *addr)
 {
 	unsigned long *ADDR, mask;
 
@@ -78,7 +78,7 @@ static inline int test_and_change_bit(un
 	return ___change_bit(ADDR, mask) != 0;
 }
 
-static inline void change_bit(unsigned long nr, volatile unsigned long *addr)
+static inline void change_bit(unsigned long nr, unsigned long *addr)
 {
 	unsigned long *ADDR, mask;
 
Index: linux-2.6/arch/sparc/include/asm/bitops_64.h
===================================================================
--- linux-2.6.orig/arch/sparc/include/asm/bitops_64.h	2008-09-01 21:57:27.000000000 +1000
+++ linux-2.6/arch/sparc/include/asm/bitops_64.h	2008-09-01 21:57:50.000000000 +1000
@@ -14,12 +14,12 @@
 #include <linux/compiler.h>
 #include <asm/byteorder.h>
 
-extern int test_and_set_bit(unsigned long nr, volatile unsigned long *addr);
-extern int test_and_clear_bit(unsigned long nr, volatile unsigned long *addr);
-extern int test_and_change_bit(unsigned long nr, volatile unsigned long *addr);
-extern void set_bit(unsigned long nr, volatile unsigned long *addr);
-extern void clear_bit(unsigned long nr, volatile unsigned long *addr);
-extern void change_bit(unsigned long nr, volatile unsigned long *addr);
+extern int test_and_set_bit(unsigned long nr, unsigned long *addr);
+extern int test_and_clear_bit(unsigned long nr, unsigned long *addr);
+extern int test_and_change_bit(unsigned long nr, unsigned long *addr);
+extern void set_bit(unsigned long nr, unsigned long *addr);
+extern void clear_bit(unsigned long nr, unsigned long *addr);
+extern void change_bit(unsigned long nr, unsigned long *addr);
 
 #include <asm-generic/bitops/non-atomic.h>
 
Index: linux-2.6/include/asm-cris/bitops.h
===================================================================
--- linux-2.6.orig/include/asm-cris/bitops.h	2008-09-01 21:57:27.000000000 +1000
+++ linux-2.6/include/asm-cris/bitops.h	2008-09-01 21:57:50.000000000 +1000
@@ -70,7 +70,7 @@
  * It also implies a memory barrier.
  */
 
-static inline int test_and_set_bit(int nr, volatile unsigned long *addr)
+static inline int test_and_set_bit(int nr, unsigned long *addr)
 {
 	unsigned int mask, retval;
 	unsigned long flags;
@@ -100,7 +100,7 @@ static inline int test_and_set_bit(int n
  * It also implies a memory barrier.
  */
 
-static inline int test_and_clear_bit(int nr, volatile unsigned long *addr)
+static inline int test_and_clear_bit(int nr, unsigned long *addr)
 {
 	unsigned int mask, retval;
 	unsigned long flags;
@@ -124,7 +124,7 @@ static inline int test_and_clear_bit(int
  * It also implies a memory barrier.
  */
 
-static inline int test_and_change_bit(int nr, volatile unsigned long *addr)
+static inline int test_and_change_bit(int nr, unsigned long *addr)
 {
 	unsigned int mask, retval;
 	unsigned long flags;
Index: linux-2.6/include/asm-frv/bitops.h
===================================================================
--- linux-2.6.orig/include/asm-frv/bitops.h	2008-09-01 21:57:27.000000000 +1000
+++ linux-2.6/include/asm-frv/bitops.h	2008-09-01 21:57:50.000000000 +1000
@@ -33,7 +33,7 @@
 
 #ifndef CONFIG_FRV_OUTOFLINE_ATOMIC_OPS
 static inline
-unsigned long atomic_test_and_ANDNOT_mask(unsigned long mask, volatile unsigned long *v)
+unsigned long atomic_test_and_ANDNOT_mask(unsigned long mask, unsigned long *v)
 {
 	unsigned long old, tmp;
 
@@ -56,7 +56,7 @@ unsigned long atomic_test_and_ANDNOT_mas
 }
 
 static inline
-unsigned long atomic_test_and_OR_mask(unsigned long mask, volatile unsigned long *v)
+unsigned long atomic_test_and_OR_mask(unsigned long mask, unsigned long *v)
 {
 	unsigned long old, tmp;
 
@@ -79,7 +79,7 @@ unsigned long atomic_test_and_OR_mask(un
 }
 
 static inline
-unsigned long atomic_test_and_XOR_mask(unsigned long mask, volatile unsigned long *v)
+unsigned long atomic_test_and_XOR_mask(unsigned long mask, unsigned long *v)
 {
 	unsigned long old, tmp;
 
@@ -103,57 +103,57 @@ unsigned long atomic_test_and_XOR_mask(u
 
 #else
 
-extern unsigned long atomic_test_and_ANDNOT_mask(unsigned long mask, volatile unsigned long *v);
-extern unsigned long atomic_test_and_OR_mask(unsigned long mask, volatile unsigned long *v);
-extern unsigned long atomic_test_and_XOR_mask(unsigned long mask, volatile unsigned long *v);
+extern unsigned long atomic_test_and_ANDNOT_mask(unsigned long mask, unsigned long *v);
+extern unsigned long atomic_test_and_OR_mask(unsigned long mask, unsigned long *v);
+extern unsigned long atomic_test_and_XOR_mask(unsigned long mask, unsigned long *v);
 
 #endif
 
 #define atomic_clear_mask(mask, v)	atomic_test_and_ANDNOT_mask((mask), (v))
 #define atomic_set_mask(mask, v)	atomic_test_and_OR_mask((mask), (v))
 
-static inline int test_and_clear_bit(int nr, volatile void *addr)
+static inline int test_and_clear_bit(int nr, void *addr)
 {
-	volatile unsigned long *ptr = addr;
+	unsigned long *ptr = addr;
 	unsigned long mask = 1UL << (nr & 31);
 	ptr += nr >> 5;
 	return (atomic_test_and_ANDNOT_mask(mask, ptr) & mask) != 0;
 }
 
-static inline int test_and_set_bit(int nr, volatile void *addr)
+static inline int test_and_set_bit(int nr, void *addr)
 {
-	volatile unsigned long *ptr = addr;
+	unsigned long *ptr = addr;
 	unsigned long mask = 1UL << (nr & 31);
 	ptr += nr >> 5;
 	return (atomic_test_and_OR_mask(mask, ptr) & mask) != 0;
 }
 
-static inline int test_and_change_bit(int nr, volatile void *addr)
+static inline int test_and_change_bit(int nr, void *addr)
 {
-	volatile unsigned long *ptr = addr;
+	unsigned long *ptr = addr;
 	unsigned long mask = 1UL << (nr & 31);
 	ptr += nr >> 5;
 	return (atomic_test_and_XOR_mask(mask, ptr) & mask) != 0;
 }
 
-static inline void clear_bit(int nr, volatile void *addr)
+static inline void clear_bit(int nr, void *addr)
 {
 	test_and_clear_bit(nr, addr);
 }
 
-static inline void set_bit(int nr, volatile void *addr)
+static inline void set_bit(int nr, void *addr)
 {
 	test_and_set_bit(nr, addr);
 }
 
-static inline void change_bit(int nr, volatile void * addr)
+static inline void change_bit(int nr, void * addr)
 {
 	test_and_change_bit(nr, addr);
 }
 
-static inline void __clear_bit(int nr, volatile void * addr)
+static inline void __clear_bit(int nr, void * addr)
 {
-	volatile unsigned long *a = addr;
+	unsigned long *a = addr;
 	int mask;
 
 	a += nr >> 5;
@@ -161,9 +161,9 @@ static inline void __clear_bit(int nr, v
 	*a &= ~mask;
 }
 
-static inline void __set_bit(int nr, volatile void * addr)
+static inline void __set_bit(int nr, void * addr)
 {
-	volatile unsigned long *a = addr;
+	unsigned long *a = addr;
 	int mask;
 
 	a += nr >> 5;
@@ -171,9 +171,9 @@ static inline void __set_bit(int nr, vol
 	*a |= mask;
 }
 
-static inline void __change_bit(int nr, volatile void *addr)
+static inline void __change_bit(int nr, void *addr)
 {
-	volatile unsigned long *a = addr;
+	unsigned long *a = addr;
 	int mask;
 
 	a += nr >> 5;
@@ -181,9 +181,9 @@ static inline void __change_bit(int nr, 
 	*a ^= mask;
 }
 
-static inline int __test_and_clear_bit(int nr, volatile void * addr)
+static inline int __test_and_clear_bit(int nr, void * addr)
 {
-	volatile unsigned long *a = addr;
+	unsigned long *a = addr;
 	int mask, retval;
 
 	a += nr >> 5;
@@ -193,9 +193,9 @@ static inline int __test_and_clear_bit(i
 	return retval;
 }
 
-static inline int __test_and_set_bit(int nr, volatile void * addr)
+static inline int __test_and_set_bit(int nr, void * addr)
 {
-	volatile unsigned long *a = addr;
+	unsigned long *a = addr;
 	int mask, retval;
 
 	a += nr >> 5;
@@ -205,9 +205,9 @@ static inline int __test_and_set_bit(int
 	return retval;
 }
 
-static inline int __test_and_change_bit(int nr, volatile void * addr)
+static inline int __test_and_change_bit(int nr, void * addr)
 {
-	volatile unsigned long *a = addr;
+	unsigned long *a = addr;
 	int mask, retval;
 
 	a += nr >> 5;
@@ -220,12 +220,12 @@ static inline int __test_and_change_bit(
 /*
  * This routine doesn't need to be atomic.
  */
-static inline int __constant_test_bit(int nr, const volatile void * addr)
+static inline int __constant_test_bit(int nr, const void * addr)
 {
-	return ((1UL << (nr & 31)) & (((const volatile unsigned int *) addr)[nr >> 5])) != 0;
+	return ((1UL << (nr & 31)) & (((const unsigned int *) addr)[nr >> 5])) != 0;
 }
 
-static inline int __test_bit(int nr, const volatile void * addr)
+static inline int __test_bit(int nr, const void * addr)
 {
 	int 	* a = (int *) addr;
 	int	mask;
Index: linux-2.6/include/asm-generic/bitops/atomic.h
===================================================================
--- linux-2.6.orig/include/asm-generic/bitops/atomic.h	2008-09-01 21:57:27.000000000 +1000
+++ linux-2.6/include/asm-generic/bitops/atomic.h	2008-09-01 21:57:50.000000000 +1000
@@ -61,7 +61,7 @@ extern raw_spinlock_t __atomic_hash[ATOM
  * Note that @nr may be almost arbitrarily large; this function is not
  * restricted to acting on a single-word quantity.
  */
-static inline void set_bit(int nr, volatile unsigned long *addr)
+static inline void set_bit(int nr, unsigned long *addr)
 {
 	unsigned long mask = BIT_MASK(nr);
 	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
@@ -82,7 +82,7 @@ static inline void set_bit(int nr, volat
  * you should call smp_mb__before_clear_bit() and/or smp_mb__after_clear_bit()
  * in order to ensure changes are visible on other processors.
  */
-static inline void clear_bit(int nr, volatile unsigned long *addr)
+static inline void clear_bit(int nr, unsigned long *addr)
 {
 	unsigned long mask = BIT_MASK(nr);
 	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
@@ -103,7 +103,7 @@ static inline void clear_bit(int nr, vol
  * Note that @nr may be almost arbitrarily large; this function is not
  * restricted to acting on a single-word quantity.
  */
-static inline void change_bit(int nr, volatile unsigned long *addr)
+static inline void change_bit(int nr, unsigned long *addr)
 {
 	unsigned long mask = BIT_MASK(nr);
 	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
@@ -123,7 +123,7 @@ static inline void change_bit(int nr, vo
  * It may be reordered on other architectures than x86.
  * It also implies a memory barrier.
  */
-static inline int test_and_set_bit(int nr, volatile unsigned long *addr)
+static inline int test_and_set_bit(int nr, unsigned long *addr)
 {
 	unsigned long mask = BIT_MASK(nr);
 	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
@@ -147,7 +147,7 @@ static inline int test_and_set_bit(int n
  * It can be reorderdered on other architectures other than x86.
  * It also implies a memory barrier.
  */
-static inline int test_and_clear_bit(int nr, volatile unsigned long *addr)
+static inline int test_and_clear_bit(int nr, unsigned long *addr)
 {
 	unsigned long mask = BIT_MASK(nr);
 	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
@@ -170,7 +170,7 @@ static inline int test_and_clear_bit(int
  * This operation is atomic and cannot be reordered.
  * It also implies a memory barrier.
  */
-static inline int test_and_change_bit(int nr, volatile unsigned long *addr)
+static inline int test_and_change_bit(int nr, unsigned long *addr)
 {
 	unsigned long mask = BIT_MASK(nr);
 	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
Index: linux-2.6/include/asm-generic/bitops/non-atomic.h
===================================================================
--- linux-2.6.orig/include/asm-generic/bitops/non-atomic.h	2008-09-01 21:57:27.000000000 +1000
+++ linux-2.6/include/asm-generic/bitops/non-atomic.h	2008-09-01 21:57:50.000000000 +1000
@@ -12,7 +12,7 @@
  * If it's called on the same region of memory simultaneously, the effect
  * may be that only one operation succeeds.
  */
-static inline void __set_bit(int nr, volatile unsigned long *addr)
+static inline void __set_bit(int nr, unsigned long *addr)
 {
 	unsigned long mask = BIT_MASK(nr);
 	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
@@ -20,7 +20,7 @@ static inline void __set_bit(int nr, vol
 	*p  |= mask;
 }
 
-static inline void __clear_bit(int nr, volatile unsigned long *addr)
+static inline void __clear_bit(int nr, unsigned long *addr)
 {
 	unsigned long mask = BIT_MASK(nr);
 	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
@@ -37,7 +37,7 @@ static inline void __clear_bit(int nr, v
  * If it's called on the same region of memory simultaneously, the effect
  * may be that only one operation succeeds.
  */
-static inline void __change_bit(int nr, volatile unsigned long *addr)
+static inline void __change_bit(int nr, unsigned long *addr)
 {
 	unsigned long mask = BIT_MASK(nr);
 	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
@@ -54,7 +54,7 @@ static inline void __change_bit(int nr, 
  * If two examples of this operation race, one can appear to succeed
  * but actually fail.  You must protect multiple accesses with a lock.
  */
-static inline int __test_and_set_bit(int nr, volatile unsigned long *addr)
+static inline int __test_and_set_bit(int nr, unsigned long *addr)
 {
 	unsigned long mask = BIT_MASK(nr);
 	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
@@ -73,7 +73,7 @@ static inline int __test_and_set_bit(int
  * If two examples of this operation race, one can appear to succeed
  * but actually fail.  You must protect multiple accesses with a lock.
  */
-static inline int __test_and_clear_bit(int nr, volatile unsigned long *addr)
+static inline int __test_and_clear_bit(int nr, unsigned long *addr)
 {
 	unsigned long mask = BIT_MASK(nr);
 	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
@@ -85,7 +85,7 @@ static inline int __test_and_clear_bit(i
 
 /* WARNING: non atomic and it can be reordered! */
 static inline int __test_and_change_bit(int nr,
-					    volatile unsigned long *addr)
+					    unsigned long *addr)
 {
 	unsigned long mask = BIT_MASK(nr);
 	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
@@ -100,7 +100,7 @@ static inline int __test_and_change_bit(
  * @nr: bit number to test
  * @addr: Address to start counting from
  */
-static inline int test_bit(int nr, const volatile unsigned long *addr)
+static inline int test_bit(int nr, const unsigned long *addr)
 {
 	return 1UL & (addr[BIT_WORD(nr)] >> (nr & (BITS_PER_LONG-1)));
 }
Index: linux-2.6/include/asm-m32r/bitops.h
===================================================================
--- linux-2.6.orig/include/asm-m32r/bitops.h	2008-09-01 21:57:27.000000000 +1000
+++ linux-2.6/include/asm-m32r/bitops.h	2008-09-01 21:57:50.000000000 +1000
@@ -39,7 +39,7 @@
  * Note that @nr may be almost arbitrarily large; this function is not
  * restricted to acting on a single-word quantity.
  */
-static __inline__ void set_bit(int nr, volatile void * addr)
+static __inline__ void set_bit(int nr, void * addr)
 {
 	__u32 mask;
 	volatile __u32 *a = addr;
@@ -75,7 +75,7 @@ static __inline__ void set_bit(int nr, v
  * you should call smp_mb__before_clear_bit() and/or smp_mb__after_clear_bit()
  * in order to ensure changes are visible on other processors.
  */
-static __inline__ void clear_bit(int nr, volatile void * addr)
+static __inline__ void clear_bit(int nr, void * addr)
 {
 	__u32 mask;
 	volatile __u32 *a = addr;
@@ -114,7 +114,7 @@ static __inline__ void clear_bit(int nr,
  * Note that @nr may be almost arbitrarily large; this function is not
  * restricted to acting on a single-word quantity.
  */
-static __inline__ void change_bit(int nr, volatile void * addr)
+static __inline__ void change_bit(int nr, void * addr)
 {
 	__u32  mask;
 	volatile __u32  *a = addr;
@@ -148,7 +148,7 @@ static __inline__ void change_bit(int nr
  * This operation is atomic and cannot be reordered.
  * It also implies a memory barrier.
  */
-static __inline__ int test_and_set_bit(int nr, volatile void * addr)
+static __inline__ int test_and_set_bit(int nr, void * addr)
 {
 	__u32 mask, oldbit;
 	volatile __u32 *a = addr;
@@ -183,7 +183,7 @@ static __inline__ int test_and_set_bit(i
  * This operation is atomic and cannot be reordered.
  * It also implies a memory barrier.
  */
-static __inline__ int test_and_clear_bit(int nr, volatile void * addr)
+static __inline__ int test_and_clear_bit(int nr, void * addr)
 {
 	__u32 mask, oldbit;
 	volatile __u32 *a = addr;
@@ -220,7 +220,7 @@ static __inline__ int test_and_clear_bit
  * This operation is atomic and cannot be reordered.
  * It also implies a memory barrier.
  */
-static __inline__ int test_and_change_bit(int nr, volatile void * addr)
+static __inline__ int test_and_change_bit(int nr, void * addr)
 {
 	__u32 mask, oldbit;
 	volatile __u32 *a = addr;
Index: linux-2.6/include/asm-m68k/bitops.h
===================================================================
--- linux-2.6.orig/include/asm-m68k/bitops.h	2008-09-01 21:57:27.000000000 +1000
+++ linux-2.6/include/asm-m68k/bitops.h	2008-09-01 21:57:50.000000000 +1000
@@ -56,14 +56,14 @@ static inline int __generic_test_and_set
 
 #define __set_bit(nr,vaddr) set_bit(nr,vaddr)
 
-static inline void __constant_set_bit(int nr, volatile unsigned long *vaddr)
+static inline void __constant_set_bit(int nr, unsigned long *vaddr)
 {
 	char *p = (char *)vaddr + (nr ^ 31) / 8;
 	__asm__ __volatile__ ("bset %1,%0"
 			: "+m" (*p) : "di" (nr & 7));
 }
 
-static inline void __generic_set_bit(int nr, volatile unsigned long *vaddr)
+static inline void __generic_set_bit(int nr, unsigned long *vaddr)
 {
 	__asm__ __volatile__ ("bfset %1{%0:#1}"
 			: : "d" (nr^31), "o" (*vaddr) : "memory");
@@ -110,14 +110,14 @@ static inline int __generic_test_and_cle
    __generic_clear_bit(nr, vaddr))
 #define __clear_bit(nr,vaddr) clear_bit(nr,vaddr)
 
-static inline void __constant_clear_bit(int nr, volatile unsigned long *vaddr)
+static inline void __constant_clear_bit(int nr, unsigned long *vaddr)
 {
 	char *p = (char *)vaddr + (nr ^ 31) / 8;
 	__asm__ __volatile__ ("bclr %1,%0"
 			: "+m" (*p) : "di" (nr & 7));
 }
 
-static inline void __generic_clear_bit(int nr, volatile unsigned long *vaddr)
+static inline void __generic_clear_bit(int nr, unsigned long *vaddr)
 {
 	__asm__ __volatile__ ("bfclr %1{%0:#1}"
 			: : "d" (nr^31), "o" (*vaddr) : "memory");
Index: linux-2.6/include/asm-mips/bitops.h
===================================================================
--- linux-2.6.orig/include/asm-mips/bitops.h	2008-09-01 21:57:27.000000000 +1000
+++ linux-2.6/include/asm-mips/bitops.h	2008-09-01 21:57:50.000000000 +1000
@@ -55,7 +55,7 @@
  * Note that @nr may be almost arbitrarily large; this function is not
  * restricted to acting on a single-word quantity.
  */
-static inline void set_bit(unsigned long nr, volatile unsigned long *addr)
+static inline void set_bit(unsigned long nr, unsigned long *addr)
 {
 	unsigned long *m = ((unsigned long *) addr) + (nr >> SZLONG_LOG);
 	unsigned short bit = nr & SZLONG_MASK;
@@ -98,7 +98,7 @@ static inline void set_bit(unsigned long
 		: "=&r" (temp), "=m" (*m)
 		: "ir" (1UL << bit), "m" (*m));
 	} else {
-		volatile unsigned long *a = addr;
+		unsigned long *a = addr;
 		unsigned long mask;
 		unsigned long flags;
 
@@ -120,7 +120,7 @@ static inline void set_bit(unsigned long
  * you should call smp_mb__before_clear_bit() and/or smp_mb__after_clear_bit()
  * in order to ensure changes are visible on other processors.
  */
-static inline void clear_bit(unsigned long nr, volatile unsigned long *addr)
+static inline void clear_bit(unsigned long nr, unsigned long *addr)
 {
 	unsigned long *m = ((unsigned long *) addr) + (nr >> SZLONG_LOG);
 	unsigned short bit = nr & SZLONG_MASK;
@@ -163,7 +163,7 @@ static inline void clear_bit(unsigned lo
 		: "=&r" (temp), "=m" (*m)
 		: "ir" (~(1UL << bit)), "m" (*m));
 	} else {
-		volatile unsigned long *a = addr;
+		unsigned long *a = addr;
 		unsigned long mask;
 		unsigned long flags;
 
@@ -183,7 +183,7 @@ static inline void clear_bit(unsigned lo
  * clear_bit() is atomic and implies release semantics before the memory
  * operation. It can be used for an unlock.
  */
-static inline void clear_bit_unlock(unsigned long nr, volatile unsigned long *addr)
+static inline void clear_bit_unlock(unsigned long nr, unsigned long *addr)
 {
 	smp_mb__before_clear_bit();
 	clear_bit(nr, addr);
@@ -198,7 +198,7 @@ static inline void clear_bit_unlock(unsi
  * Note that @nr may be almost arbitrarily large; this function is not
  * restricted to acting on a single-word quantity.
  */
-static inline void change_bit(unsigned long nr, volatile unsigned long *addr)
+static inline void change_bit(unsigned long nr, unsigned long *addr)
 {
 	unsigned short bit = nr & SZLONG_MASK;
 
@@ -232,7 +232,7 @@ static inline void change_bit(unsigned l
 		: "=&r" (temp), "=m" (*m)
 		: "ir" (1UL << bit), "m" (*m));
 	} else {
-		volatile unsigned long *a = addr;
+		unsigned long *a = addr;
 		unsigned long mask;
 		unsigned long flags;
 
@@ -253,7 +253,7 @@ static inline void change_bit(unsigned l
  * It also implies a memory barrier.
  */
 static inline int test_and_set_bit(unsigned long nr,
-	volatile unsigned long *addr)
+	unsigned long *addr)
 {
 	unsigned short bit = nr & SZLONG_MASK;
 	unsigned long res;
@@ -297,7 +297,7 @@ static inline int test_and_set_bit(unsig
 		: "r" (1UL << bit), "m" (*m)
 		: "memory");
 	} else {
-		volatile unsigned long *a = addr;
+		unsigned long *a = addr;
 		unsigned long mask;
 		unsigned long flags;
 
@@ -323,7 +323,7 @@ static inline int test_and_set_bit(unsig
  * after the memory operation.
  */
 static inline int test_and_set_bit_lock(unsigned long nr,
-	volatile unsigned long *addr)
+	unsigned long *addr)
 {
 	unsigned short bit = nr & SZLONG_MASK;
 	unsigned long res;
@@ -365,7 +365,7 @@ static inline int test_and_set_bit_lock(
 		: "r" (1UL << bit), "m" (*m)
 		: "memory");
 	} else {
-		volatile unsigned long *a = addr;
+		unsigned long *a = addr;
 		unsigned long mask;
 		unsigned long flags;
 
@@ -390,7 +390,7 @@ static inline int test_and_set_bit_lock(
  * It also implies a memory barrier.
  */
 static inline int test_and_clear_bit(unsigned long nr,
-	volatile unsigned long *addr)
+	unsigned long *addr)
 {
 	unsigned short bit = nr & SZLONG_MASK;
 	unsigned long res;
@@ -454,7 +454,7 @@ static inline int test_and_clear_bit(uns
 		: "r" (1UL << bit), "m" (*m)
 		: "memory");
 	} else {
-		volatile unsigned long *a = addr;
+		unsigned long *a = addr;
 		unsigned long mask;
 		unsigned long flags;
 
@@ -480,7 +480,7 @@ static inline int test_and_clear_bit(uns
  * It also implies a memory barrier.
  */
 static inline int test_and_change_bit(unsigned long nr,
-	volatile unsigned long *addr)
+	unsigned long *addr)
 {
 	unsigned short bit = nr & SZLONG_MASK;
 	unsigned long res;
@@ -524,7 +524,7 @@ static inline int test_and_change_bit(un
 		: "r" (1UL << bit), "m" (*m)
 		: "memory");
 	} else {
-		volatile unsigned long *a = addr;
+		unsigned long *a = addr;
 		unsigned long mask;
 		unsigned long flags;
 
@@ -552,7 +552,7 @@ static inline int test_and_change_bit(un
  * operation. It can be used for an unlock if no other CPUs can concurrently
  * modify other bits in the word.
  */
-static inline void __clear_bit_unlock(unsigned long nr, volatile unsigned long *addr)
+static inline void __clear_bit_unlock(unsigned long nr, unsigned long *addr)
 {
 	smp_mb();
 	__clear_bit(nr, addr);
Index: linux-2.6/include/asm-mn10300/bitops.h
===================================================================
--- linux-2.6.orig/include/asm-mn10300/bitops.h	2008-09-01 21:57:27.000000000 +1000
+++ linux-2.6/include/asm-mn10300/bitops.h	2008-09-01 21:57:50.000000000 +1000
@@ -27,7 +27,7 @@
  */
 #define __set_bit(nr, addr)					\
 ({								\
-	volatile unsigned char *_a = (unsigned char *)(addr);	\
+	unsigned char *_a = (unsigned char *)(addr);	\
 	const unsigned shift = (nr) & 7;			\
 	_a += (nr) >> 3;					\
 								\
@@ -44,7 +44,7 @@
  */
 #define ___clear_bit(nr, addr)					\
 ({								\
-	volatile unsigned char *_a = (unsigned char *)(addr);	\
+	unsigned char *_a = (unsigned char *)(addr);	\
 	const unsigned shift = (nr) & 7;			\
 	_a += (nr) >> 3;					\
 								\
@@ -57,7 +57,7 @@
 #define clear_bit(nr, addr) ___clear_bit((nr), (addr))
 
 
-static inline void __clear_bit(int nr, volatile void *addr)
+static inline void __clear_bit(int nr, void *addr)
 {
 	unsigned int *a = (unsigned int *) addr;
 	int mask;
@@ -70,7 +70,7 @@ static inline void __clear_bit(int nr, v
 /*
  * test bit
  */
-static inline int test_bit(int nr, const volatile void *addr)
+static inline int test_bit(int nr, const void *addr)
 {
 	return 1UL & (((const unsigned int *) addr)[nr >> 5] >> (nr & 31));
 }
@@ -78,7 +78,7 @@ static inline int test_bit(int nr, const
 /*
  * change bit
  */
-static inline void __change_bit(int nr, volatile void *addr)
+static inline void __change_bit(int nr, void *addr)
 {
 	int	mask;
 	unsigned int *a = (unsigned int *) addr;
@@ -88,14 +88,14 @@ static inline void __change_bit(int nr, 
 	*a ^= mask;
 }
 
-extern void change_bit(int nr, volatile void *addr);
+extern void change_bit(int nr, void *addr);
 
 /*
  * test and set bit
  */
 #define __test_and_set_bit(nr,addr)				\
 ({								\
-	volatile unsigned char *_a = (unsigned char *)(addr);	\
+	unsigned char *_a = (unsigned char *)(addr);	\
 	const unsigned shift = (nr) & 7;			\
 	unsigned epsw;						\
 	_a += (nr) >> 3;					\
@@ -116,7 +116,7 @@ extern void change_bit(int nr, volatile 
  */
 #define __test_and_clear_bit(nr, addr)				\
 ({								\
-        volatile unsigned char *_a = (unsigned char *)(addr);	\
+        unsigned char *_a = (unsigned char *)(addr);	\
 	const unsigned shift = (nr) & 7;			\
 	unsigned epsw;						\
 	_a += (nr) >> 3;					\
@@ -135,7 +135,7 @@ extern void change_bit(int nr, volatile 
 /*
  * test and change bit
  */
-static inline int __test_and_change_bit(int nr, volatile void *addr)
+static inline int __test_and_change_bit(int nr, void *addr)
 {
 	int	mask, retval;
 	unsigned int *a = (unsigned int *)addr;
@@ -148,7 +148,7 @@ static inline int __test_and_change_bit(
 	return retval;
 }
 
-extern int test_and_change_bit(int nr, volatile void *addr);
+extern int test_and_change_bit(int nr, void *addr);
 
 #include <asm-generic/bitops/lock.h>
 
Index: linux-2.6/include/asm-parisc/bitops.h
===================================================================
--- linux-2.6.orig/include/asm-parisc/bitops.h	2008-09-01 21:57:27.000000000 +1000
+++ linux-2.6/include/asm-parisc/bitops.h	2008-09-01 21:57:50.000000000 +1000
@@ -28,7 +28,7 @@
  *	__*_bit() are "relaxed" and don't use spinlock or volatile.
  */
 
-static __inline__ void set_bit(int nr, volatile unsigned long * addr)
+static __inline__ void set_bit(int nr, unsigned long * addr)
 {
 	unsigned long mask = 1UL << CHOP_SHIFTCOUNT(nr);
 	unsigned long flags;
@@ -39,7 +39,7 @@ static __inline__ void set_bit(int nr, v
 	_atomic_spin_unlock_irqrestore(addr, flags);
 }
 
-static __inline__ void clear_bit(int nr, volatile unsigned long * addr)
+static __inline__ void clear_bit(int nr, unsigned long * addr)
 {
 	unsigned long mask = ~(1UL << CHOP_SHIFTCOUNT(nr));
 	unsigned long flags;
@@ -50,7 +50,7 @@ static __inline__ void clear_bit(int nr,
 	_atomic_spin_unlock_irqrestore(addr, flags);
 }
 
-static __inline__ void change_bit(int nr, volatile unsigned long * addr)
+static __inline__ void change_bit(int nr, unsigned long * addr)
 {
 	unsigned long mask = 1UL << CHOP_SHIFTCOUNT(nr);
 	unsigned long flags;
@@ -61,7 +61,7 @@ static __inline__ void change_bit(int nr
 	_atomic_spin_unlock_irqrestore(addr, flags);
 }
 
-static __inline__ int test_and_set_bit(int nr, volatile unsigned long * addr)
+static __inline__ int test_and_set_bit(int nr, unsigned long * addr)
 {
 	unsigned long mask = 1UL << CHOP_SHIFTCOUNT(nr);
 	unsigned long old;
@@ -79,7 +79,7 @@ static __inline__ int test_and_set_bit(i
 	return set;
 }
 
-static __inline__ int test_and_clear_bit(int nr, volatile unsigned long * addr)
+static __inline__ int test_and_clear_bit(int nr, unsigned long * addr)
 {
 	unsigned long mask = 1UL << CHOP_SHIFTCOUNT(nr);
 	unsigned long old;
@@ -97,7 +97,7 @@ static __inline__ int test_and_clear_bit
 	return set;
 }
 
-static __inline__ int test_and_change_bit(int nr, volatile unsigned long * addr)
+static __inline__ int test_and_change_bit(int nr, unsigned long * addr)
 {
 	unsigned long mask = 1UL << CHOP_SHIFTCOUNT(nr);
 	unsigned long oldbit;
Index: linux-2.6/include/asm-x86/sync_bitops.h
===================================================================
--- linux-2.6.orig/include/asm-x86/sync_bitops.h	2008-09-01 21:57:27.000000000 +1000
+++ linux-2.6/include/asm-x86/sync_bitops.h	2008-09-01 21:57:50.000000000 +1000
@@ -13,7 +13,7 @@
  * bit 0 is the LSB of addr; bit 32 is the LSB of (addr+1).
  */
 
-#define ADDR (*(volatile long *)addr)
+#define ADDR (*(long *)addr)
 
 /**
  * sync_set_bit - Atomically set a bit in memory
@@ -26,7 +26,7 @@
  * Note that @nr may be almost arbitrarily large; this function is not
  * restricted to acting on a single-word quantity.
  */
-static inline void sync_set_bit(int nr, volatile unsigned long *addr)
+static inline void sync_set_bit(int nr, unsigned long *addr)
 {
 	asm volatile("lock; btsl %1,%0"
 		     : "+m" (ADDR)
@@ -44,7 +44,7 @@ static inline void sync_set_bit(int nr, 
  * you should call smp_mb__before_clear_bit() and/or smp_mb__after_clear_bit()
  * in order to ensure changes are visible on other processors.
  */
-static inline void sync_clear_bit(int nr, volatile unsigned long *addr)
+static inline void sync_clear_bit(int nr, unsigned long *addr)
 {
 	asm volatile("lock; btrl %1,%0"
 		     : "+m" (ADDR)
@@ -61,7 +61,7 @@ static inline void sync_clear_bit(int nr
  * Note that @nr may be almost arbitrarily large; this function is not
  * restricted to acting on a single-word quantity.
  */
-static inline void sync_change_bit(int nr, volatile unsigned long *addr)
+static inline void sync_change_bit(int nr, unsigned long *addr)
 {
 	asm volatile("lock; btcl %1,%0"
 		     : "+m" (ADDR)
@@ -77,7 +77,7 @@ static inline void sync_change_bit(int n
  * This operation is atomic and cannot be reordered.
  * It also implies a memory barrier.
  */
-static inline int sync_test_and_set_bit(int nr, volatile unsigned long *addr)
+static inline int sync_test_and_set_bit(int nr, unsigned long *addr)
 {
 	int oldbit;
 
@@ -95,7 +95,7 @@ static inline int sync_test_and_set_bit(
  * This operation is atomic and cannot be reordered.
  * It also implies a memory barrier.
  */
-static inline int sync_test_and_clear_bit(int nr, volatile unsigned long *addr)
+static inline int sync_test_and_clear_bit(int nr, unsigned long *addr)
 {
 	int oldbit;
 
@@ -113,7 +113,7 @@ static inline int sync_test_and_clear_bi
  * This operation is atomic and cannot be reordered.
  * It also implies a memory barrier.
  */
-static inline int sync_test_and_change_bit(int nr, volatile unsigned long *addr)
+static inline int sync_test_and_change_bit(int nr, unsigned long *addr)
 {
 	int oldbit;
 
Index: linux-2.6/include/linux/cpumask.h
===================================================================
--- linux-2.6.orig/include/linux/cpumask.h	2008-09-01 21:57:27.000000000 +1000
+++ linux-2.6/include/linux/cpumask.h	2008-09-01 21:57:50.000000000 +1000
@@ -142,13 +142,13 @@ typedef struct { DECLARE_BITMAP(bits, NR
 extern cpumask_t _unused_cpumask_arg_;
 
 #define cpu_set(cpu, dst) __cpu_set((cpu), &(dst))
-static inline void __cpu_set(int cpu, volatile cpumask_t *dstp)
+static inline void __cpu_set(int cpu, cpumask_t *dstp)
 {
 	set_bit(cpu, dstp->bits);
 }
 
 #define cpu_clear(cpu, dst) __cpu_clear((cpu), &(dst))
-static inline void __cpu_clear(int cpu, volatile cpumask_t *dstp)
+static inline void __cpu_clear(int cpu, cpumask_t *dstp)
 {
 	clear_bit(cpu, dstp->bits);
 }
Index: linux-2.6/include/linux/nodemask.h
===================================================================
--- linux-2.6.orig/include/linux/nodemask.h	2008-09-01 21:57:27.000000000 +1000
+++ linux-2.6/include/linux/nodemask.h	2008-09-01 21:57:50.000000000 +1000
@@ -93,13 +93,13 @@ typedef struct { DECLARE_BITMAP(bits, MA
 extern nodemask_t _unused_nodemask_arg_;
 
 #define node_set(node, dst) __node_set((node), &(dst))
-static inline void __node_set(int node, volatile nodemask_t *dstp)
+static inline void __node_set(int node, nodemask_t *dstp)
 {
 	set_bit(node, dstp->bits);
 }
 
 #define node_clear(node, dst) __node_clear((node), &(dst))
-static inline void __node_clear(int node, volatile nodemask_t *dstp)
+static inline void __node_clear(int node, nodemask_t *dstp)
 {
 	clear_bit(node, dstp->bits);
 }
Index: linux-2.6/drivers/gpu/drm/mga/mga_drv.h
===================================================================
--- linux-2.6.orig/drivers/gpu/drm/mga/mga_drv.h	2008-09-01 21:57:27.000000000 +1000
+++ linux-2.6/drivers/gpu/drm/mga/mga_drv.h	2008-09-01 21:57:50.000000000 +1000
@@ -51,7 +51,7 @@ typedef struct drm_mga_primary_buffer {
 
 	u32 tail;
 	int space;
-	volatile long wrapped;
+	long wrapped;
 
 	volatile u32 *status;
 
Index: linux-2.6/drivers/net/s2io.h
===================================================================
--- linux-2.6.orig/drivers/net/s2io.h	2008-09-01 21:57:27.000000000 +1000
+++ linux-2.6/drivers/net/s2io.h	2008-09-01 21:57:50.000000000 +1000
@@ -982,7 +982,7 @@ struct s2io_nic {
 	unsigned long	sending_both;
 	u8		lro;
 	u16		lro_max_aggr_per_sess;
-	volatile unsigned long state;
+	unsigned long	state;
 	u64		general_int_mask;
 
 #define VPD_STRING_LEN 80
Index: linux-2.6/include/drm/drmP.h
===================================================================
--- linux-2.6.orig/include/drm/drmP.h	2008-09-01 21:57:27.000000000 +1000
+++ linux-2.6/include/drm/drmP.h	2008-09-01 21:57:50.000000000 +1000
@@ -716,7 +716,7 @@ struct drm_device {
 	/*@{ */
 	int irq;			/**< Interrupt used by board */
 	int irq_enabled;		/**< True if irq handler is enabled */
-	__volatile__ long context_flag;	/**< Context swapping flag */
+	long context_flag;		/**< Context swapping flag */
 	__volatile__ long interrupt_flag; /**< Interruption handler flag */
 	__volatile__ long dma_flag;	/**< DMA dispatch flag */
 	struct timer_list timer;	/**< Timer for delaying ctx switch */
Index: linux-2.6/drivers/scsi/3w-xxxx.h
===================================================================
--- linux-2.6.orig/drivers/scsi/3w-xxxx.h	2008-09-01 21:57:27.000000000 +1000
+++ linux-2.6/drivers/scsi/3w-xxxx.h	2008-09-01 21:57:50.000000000 +1000
@@ -424,7 +424,7 @@ typedef struct TAG_TW_Device_Extension {
 	unsigned short		aen_queue[TW_Q_LENGTH];
 	unsigned char		aen_head;
 	unsigned char		aen_tail;
-	volatile long		flags; /* long req'd for set_bit --RR */
+	long			flags; /* long req'd for set_bit */
 	int			reset_print;
 	volatile int		chrdev_request_id;
 	wait_queue_head_t	ioctl_wqueue;
Index: linux-2.6/include/asm-x86/bitops.h
===================================================================
--- linux-2.6.orig/include/asm-x86/bitops.h	2008-09-01 21:57:53.000000000 +1000
+++ linux-2.6/include/asm-x86/bitops.h	2008-09-01 22:19:19.000000000 +1000
@@ -23,9 +23,9 @@
 #if __GNUC__ < 4 || (__GNUC__ == 4 && __GNUC_MINOR__ < 1)
 /* Technically wrong, but this avoids compilation errors on some gcc
    versions. */
-#define BITOP_ADDR(x) "=m" (*(volatile long *) (x))
+#define BITOP_ADDR(x) "=m" (*(long *) (x))
 #else
-#define BITOP_ADDR(x) "+m" (*(volatile long *) (x))
+#define BITOP_ADDR(x) "+m" (*(long *) (x))
 #endif
 
 #define ADDR				BITOP_ADDR(addr)
@@ -53,7 +53,7 @@
  * Note that @nr may be almost arbitrarily large; this function is not
  * restricted to acting on a single-word quantity.
  */
-static inline void set_bit(unsigned int nr, volatile unsigned long *addr)
+static inline void set_bit(unsigned int nr, unsigned long *addr)
 {
 	if (IS_IMMEDIATE(nr)) {
 		asm volatile(LOCK_PREFIX "orb %1,%0"
@@ -75,7 +75,7 @@ static inline void set_bit(unsigned int 
  * If it's called on the same region of memory simultaneously, the effect
  * may be that only one operation succeeds.
  */
-static inline void __set_bit(int nr, volatile unsigned long *addr)
+static inline void __set_bit(int nr, unsigned long *addr)
 {
 	asm volatile("bts %1,%0" : ADDR : "Ir" (nr) : "memory");
 }
@@ -90,7 +90,7 @@ static inline void __set_bit(int nr, vol
  * you should call smp_mb__before_clear_bit() and/or smp_mb__after_clear_bit()
  * in order to ensure changes are visible on other processors.
  */
-static inline void clear_bit(int nr, volatile unsigned long *addr)
+static inline void clear_bit(int nr, unsigned long *addr)
 {
 	if (IS_IMMEDIATE(nr)) {
 		asm volatile(LOCK_PREFIX "andb %1,%0"
@@ -111,13 +111,13 @@ static inline void clear_bit(int nr, vol
  * clear_bit() is atomic and implies release semantics before the memory
  * operation. It can be used for an unlock.
  */
-static inline void clear_bit_unlock(unsigned nr, volatile unsigned long *addr)
+static inline void clear_bit_unlock(unsigned nr, unsigned long *addr)
 {
 	barrier();
 	clear_bit(nr, addr);
 }
 
-static inline void __clear_bit(int nr, volatile unsigned long *addr)
+static inline void __clear_bit(int nr, unsigned long *addr)
 {
 	asm volatile("btr %1,%0" : ADDR : "Ir" (nr));
 }
@@ -134,7 +134,7 @@ static inline void __clear_bit(int nr, v
  * No memory barrier is required here, because x86 cannot reorder stores past
  * older loads. Same principle as spin_unlock.
  */
-static inline void __clear_bit_unlock(unsigned nr, volatile unsigned long *addr)
+static inline void __clear_bit_unlock(unsigned nr, unsigned long *addr)
 {
 	barrier();
 	__clear_bit(nr, addr);
@@ -152,7 +152,7 @@ static inline void __clear_bit_unlock(un
  * If it's called on the same region of memory simultaneously, the effect
  * may be that only one operation succeeds.
  */
-static inline void __change_bit(int nr, volatile unsigned long *addr)
+static inline void __change_bit(int nr, unsigned long *addr)
 {
 	asm volatile("btc %1,%0" : ADDR : "Ir" (nr));
 }
@@ -166,7 +166,7 @@ static inline void __change_bit(int nr, 
  * Note that @nr may be almost arbitrarily large; this function is not
  * restricted to acting on a single-word quantity.
  */
-static inline void change_bit(int nr, volatile unsigned long *addr)
+static inline void change_bit(int nr, unsigned long *addr)
 {
 	asm volatile(LOCK_PREFIX "btc %1,%0" : ADDR : "Ir" (nr));
 }
@@ -179,7 +179,7 @@ static inline void change_bit(int nr, vo
  * This operation is atomic and cannot be reordered.
  * It also implies a memory barrier.
  */
-static inline int test_and_set_bit(int nr, volatile unsigned long *addr)
+static inline int test_and_set_bit(int nr, unsigned long *addr)
 {
 	int oldbit;
 
@@ -196,7 +196,7 @@ static inline int test_and_set_bit(int n
  *
  * This is the same as test_and_set_bit on x86.
  */
-static inline int test_and_set_bit_lock(int nr, volatile unsigned long *addr)
+static inline int test_and_set_bit_lock(int nr, unsigned long *addr)
 {
 	return test_and_set_bit(nr, addr);
 }
@@ -210,7 +210,7 @@ static inline int test_and_set_bit_lock(
  * If two examples of this operation race, one can appear to succeed
  * but actually fail.  You must protect multiple accesses with a lock.
  */
-static inline int __test_and_set_bit(int nr, volatile unsigned long *addr)
+static inline int __test_and_set_bit(int nr, unsigned long *addr)
 {
 	int oldbit;
 
@@ -229,7 +229,7 @@ static inline int __test_and_set_bit(int
  * This operation is atomic and cannot be reordered.
  * It also implies a memory barrier.
  */
-static inline int test_and_clear_bit(int nr, volatile unsigned long *addr)
+static inline int test_and_clear_bit(int nr, unsigned long *addr)
 {
 	int oldbit;
 
@@ -249,7 +249,7 @@ static inline int test_and_clear_bit(int
  * If two examples of this operation race, one can appear to succeed
  * but actually fail.  You must protect multiple accesses with a lock.
  */
-static inline int __test_and_clear_bit(int nr, volatile unsigned long *addr)
+static inline int __test_and_clear_bit(int nr, unsigned long *addr)
 {
 	int oldbit;
 
@@ -261,7 +261,7 @@ static inline int __test_and_clear_bit(i
 }
 
 /* WARNING: non atomic and it can be reordered! */
-static inline int __test_and_change_bit(int nr, volatile unsigned long *addr)
+static inline int __test_and_change_bit(int nr, unsigned long *addr)
 {
 	int oldbit;
 
@@ -281,7 +281,7 @@ static inline int __test_and_change_bit(
  * This operation is atomic and cannot be reordered.
  * It also implies a memory barrier.
  */
-static inline int test_and_change_bit(int nr, volatile unsigned long *addr)
+static inline int test_and_change_bit(int nr, unsigned long *addr)
 {
 	int oldbit;
 
@@ -292,13 +292,13 @@ static inline int test_and_change_bit(in
 	return oldbit;
 }
 
-static inline int constant_test_bit(int nr, const volatile unsigned long *addr)
+static inline int constant_test_bit(int nr, const unsigned long *addr)
 {
 	return ((1UL << (nr % BITS_PER_LONG)) &
 		(((unsigned long *)addr)[nr / BITS_PER_LONG])) != 0;
 }
 
-static inline int variable_test_bit(int nr, volatile const unsigned long *addr)
+static inline int variable_test_bit(int nr, const unsigned long *addr)
 {
 	int oldbit;
 
@@ -316,7 +316,7 @@ static inline int variable_test_bit(int 
  * @nr: bit number to test
  * @addr: Address to start counting from
  */
-static int test_bit(int nr, const volatile unsigned long *addr);
+static int test_bit(int nr, const unsigned long *addr);
 #endif
 
 #define test_bit(nr, addr)			\
