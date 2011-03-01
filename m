From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH] arch/tile: fix deadlock bugs in rwlock implementation
Date: Tue, 1 Mar 2011 13:30:15 -0500
Message-ID: <201103011935.p21JZZU0010332@farm-0010.internal.tilera.com>
References: <4D5DA60A.8080201@tilera.com>
	<20110217.145333.232751283.davem@davemloft.net>
	<4D5DA96D.5060200@tilera.com>
	<20110217.151147.35033921.davem@davemloft.net>
	<4D5DACC5.60105@tilera.com>
Cc: David Miller <davem@davemloft.net>, <xiyou.wangcong@gmail.com>,
	<eric.dumazet@gmail.com>, <netdev@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTim1F679mmnbHnYkvi6ZDojxD-tPGer4F+61C+di@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The first issue fixed in this patch is that pending rwlock write locks
could lock out new readers; this could cause a deadlock if a read lock was
held on cpu 1, a write lock was then attempted on cpu 2 and was pending,
and cpu 1 was interrupted and attempted to re-acquire a read lock.
The write lock code was modified to not lock out new readers.

The second issue fixed is that there was a narrow race window where a tns
instruction had been issued (setting the lock value to "1") and the store
instruction to reset the lock value correctly had not yet been issued.
In this case, if an interrupt occurred and the same cpu then tried to
manipulate the lock, it would find the lock value set to "1" and spin
forever, assuming some other cpu was partway through updating it.  The fix
is to enforce an interrupt critical section around the tns/store pair.

Since these changes make the rwlock "fast path" code heavier weight,
I decided to move all the rwlock code all out of line, leaving only the
conventional spinlock code with fastpath inlines.

As part of this change I also eliminate support for the now-obsolete
tns_atomic mode.

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 arch/tile/include/asm/spinlock_32.h |   84 ++----------------
 arch/tile/lib/spinlock_32.c         |  163 +++++++++++++++++++++--------------
 2 files changed, 108 insertions(+), 139 deletions(-)

diff --git a/arch/tile/include/asm/spinlock_32.h b/arch/tile/include/asm/spinlock_32.h
index 88efdde..32ba1fe 100644
--- a/arch/tile/include/asm/spinlock_32.h
+++ b/arch/tile/include/asm/spinlock_32.h
@@ -21,6 +21,7 @@
 #include <asm/page.h>
 #include <asm/system.h>
 #include <linux/compiler.h>
+#include <arch/spr_def.h>
 
 /*
  * We only use even ticket numbers so the '1' inserted by a tns is
@@ -78,13 +79,6 @@ void arch_spin_unlock_wait(arch_spinlock_t *lock);
 #define _RD_COUNT_SHIFT 24
 #define _RD_COUNT_WIDTH 8
 
-/* Internal functions; do not use. */
-void arch_read_lock_slow(arch_rwlock_t *, u32);
-int arch_read_trylock_slow(arch_rwlock_t *);
-void arch_read_unlock_slow(arch_rwlock_t *);
-void arch_write_lock_slow(arch_rwlock_t *, u32);
-void arch_write_unlock_slow(arch_rwlock_t *, u32);
-
 /**
  * arch_read_can_lock() - would read_trylock() succeed?
  */
@@ -104,94 +98,32 @@ static inline int arch_write_can_lock(arch_rwlock_t *rwlock)
 /**
  * arch_read_lock() - acquire a read lock.
  */
-static inline void arch_read_lock(arch_rwlock_t *rwlock)
-{
-	u32 val = __insn_tns((int *)&rwlock->lock);
-	if (unlikely(val << _RD_COUNT_WIDTH)) {
-		arch_read_lock_slow(rwlock, val);
-		return;
-	}
-	rwlock->lock = val + (1 << _RD_COUNT_SHIFT);
-}
+void arch_read_lock(arch_rwlock_t *rwlock);
 
 /**
- * arch_read_lock() - acquire a write lock.
+ * arch_write_lock() - acquire a write lock.
  */
-static inline void arch_write_lock(arch_rwlock_t *rwlock)
-{
-	u32 val = __insn_tns((int *)&rwlock->lock);
-	if (unlikely(val != 0)) {
-		arch_write_lock_slow(rwlock, val);
-		return;
-	}
-	rwlock->lock = 1 << _WR_NEXT_SHIFT;
-}
+void arch_write_lock(arch_rwlock_t *rwlock);
 
 /**
  * arch_read_trylock() - try to acquire a read lock.
  */
-static inline int arch_read_trylock(arch_rwlock_t *rwlock)
-{
-	int locked;
-	u32 val = __insn_tns((int *)&rwlock->lock);
-	if (unlikely(val & 1))
-		return arch_read_trylock_slow(rwlock);
-	locked = (val << _RD_COUNT_WIDTH) == 0;
-	rwlock->lock = val + (locked << _RD_COUNT_SHIFT);
-	return locked;
-}
+int arch_read_trylock(arch_rwlock_t *rwlock);
 
 /**
  * arch_write_trylock() - try to acquire a write lock.
  */
-static inline int arch_write_trylock(arch_rwlock_t *rwlock)
-{
-	u32 val = __insn_tns((int *)&rwlock->lock);
-
-	/*
-	 * If a tns is in progress, or there's a waiting or active locker,
-	 * or active readers, we can't take the lock, so give up.
-	 */
-	if (unlikely(val != 0)) {
-		if (!(val & 1))
-			rwlock->lock = val;
-		return 0;
-	}
-
-	/* Set the "next" field to mark it locked. */
-	rwlock->lock = 1 << _WR_NEXT_SHIFT;
-	return 1;
-}
+int arch_write_trylock(arch_rwlock_t *rwlock);
 
 /**
  * arch_read_unlock() - release a read lock.
  */
-static inline void arch_read_unlock(arch_rwlock_t *rwlock)
-{
-	u32 val;
-	mb();  /* guarantee anything modified under the lock is visible */
-	val = __insn_tns((int *)&rwlock->lock);
-	if (unlikely(val & 1)) {
-		arch_read_unlock_slow(rwlock);
-		return;
-	}
-	rwlock->lock = val - (1 << _RD_COUNT_SHIFT);
-}
+void arch_read_unlock(arch_rwlock_t *rwlock);
 
 /**
  * arch_write_unlock() - release a write lock.
  */
-static inline void arch_write_unlock(arch_rwlock_t *rwlock)
-{
-	u32 val;
-	mb();  /* guarantee anything modified under the lock is visible */
-	val = __insn_tns((int *)&rwlock->lock);
-	if (unlikely(val != (1 << _WR_NEXT_SHIFT))) {
-		arch_write_unlock_slow(rwlock, val);
-		return;
-	}
-	rwlock->lock = 0;
-}
+void arch_write_unlock(arch_rwlock_t *rwlock);
 
 #define arch_read_lock_flags(lock, flags) arch_read_lock(lock)
 #define arch_write_lock_flags(lock, flags) arch_write_lock(lock)
diff --git a/arch/tile/lib/spinlock_32.c b/arch/tile/lib/spinlock_32.c
index 5cd1c40..723e789 100644
--- a/arch/tile/lib/spinlock_32.c
+++ b/arch/tile/lib/spinlock_32.c
@@ -91,75 +91,82 @@ EXPORT_SYMBOL(arch_spin_unlock_wait);
 #define RD_COUNT_MASK   ((1 << RD_COUNT_WIDTH) - 1)
 
 
-/* Lock the word, spinning until there are no tns-ers. */
-static inline u32 get_rwlock(arch_rwlock_t *rwlock)
+/*
+ * We spin until everything but the reader bits (which are in the high
+ * part of the word) are zero, i.e. no active or waiting writers, no tns.
+ *
+ * We guard the tns/store-back with an interrupt critical section to
+ * preserve the semantic that the same read lock can be acquired in an
+ * interrupt context.
+ *
+ * ISSUE: This approach can permanently starve readers.  A reader who sees
+ * a writer could instead take a ticket lock (just like a writer would),
+ * and atomically enter read mode (with 1 reader) when it gets the ticket.
+ * This way both readers and writers will always make forward progress
+ * in a finite time.
+ */
+void arch_read_lock(arch_rwlock_t *rwlock)
 {
-	u32 iterations = 0;
+	u32 val, iterations = 0;
+
 	for (;;) {
-		u32 val = __insn_tns((int *)&rwlock->lock);
-		if (unlikely(val & 1)) {
-			delay_backoff(iterations++);
-			continue;
+		__insn_mtspr(SPR_INTERRUPT_CRITICAL_SECTION, 1);
+		val = __insn_tns((int *)&rwlock->lock);
+		if (likely((val << _RD_COUNT_WIDTH) == 0)) {
+			rwlock->lock = val + (1 << RD_COUNT_SHIFT);
+			__insn_mtspr(SPR_INTERRUPT_CRITICAL_SECTION, 0);
+			break;
 		}
-		return val;
+		if ((val & 1) == 0)
+			rwlock->lock = val;
+		__insn_mtspr(SPR_INTERRUPT_CRITICAL_SECTION, 0);
+		delay_backoff(iterations++);
 	}
 }
+EXPORT_SYMBOL(arch_read_lock);
 
-int arch_read_trylock_slow(arch_rwlock_t *rwlock)
+int arch_read_trylock(arch_rwlock_t *rwlock)
 {
-	u32 val = get_rwlock(rwlock);
-	int locked = (val << RD_COUNT_WIDTH) == 0;
-	rwlock->lock = val + (locked << RD_COUNT_SHIFT);
+	u32 val;
+	int locked;
+
+	__insn_mtspr(SPR_INTERRUPT_CRITICAL_SECTION, 1);
+	val = __insn_tns((int *)&rwlock->lock);
+	locked = ((val << _RD_COUNT_WIDTH) == 0);
+	if (likely(locked))
+		rwlock->lock = val + (1 << RD_COUNT_SHIFT);
+	else if ((val & 1) == 0)
+		rwlock->lock = val;
+	__insn_mtspr(SPR_INTERRUPT_CRITICAL_SECTION, 0);
 	return locked;
 }
-EXPORT_SYMBOL(arch_read_trylock_slow);
+EXPORT_SYMBOL(arch_read_trylock);
 
-void arch_read_unlock_slow(arch_rwlock_t *rwlock)
+void arch_read_unlock(arch_rwlock_t *rwlock)
 {
-	u32 val = get_rwlock(rwlock);
-	rwlock->lock = val - (1 << RD_COUNT_SHIFT);
-}
-EXPORT_SYMBOL(arch_read_unlock_slow);
+	u32 val, iterations = 0;
 
-void arch_write_unlock_slow(arch_rwlock_t *rwlock, u32 val)
-{
-	u32 eq, mask = 1 << WR_CURR_SHIFT;
-	while (unlikely(val & 1)) {
-		/* Limited backoff since we are the highest-priority task. */
-		relax(4);
+	mb();  /* guarantee anything modified under the lock is visible */
+	for (;;) {
+		__insn_mtspr(SPR_INTERRUPT_CRITICAL_SECTION, 1);
 		val = __insn_tns((int *)&rwlock->lock);
+		if (likely(val & 1) == 0) {
+			rwlock->lock = val - (1 << _RD_COUNT_SHIFT);
+			__insn_mtspr(SPR_INTERRUPT_CRITICAL_SECTION, 0);
+			break;
+		}
+		__insn_mtspr(SPR_INTERRUPT_CRITICAL_SECTION, 0);
+		delay_backoff(iterations++);
 	}
-	val = __insn_addb(val, mask);
-	eq = __insn_seqb(val, val << (WR_CURR_SHIFT - WR_NEXT_SHIFT));
-	val = __insn_mz(eq & mask, val);
-	rwlock->lock = val;
 }
-EXPORT_SYMBOL(arch_write_unlock_slow);
+EXPORT_SYMBOL(arch_read_unlock);
 
 /*
- * We spin until everything but the reader bits (which are in the high
- * part of the word) are zero, i.e. no active or waiting writers, no tns.
- *
- * ISSUE: This approach can permanently starve readers.  A reader who sees
- * a writer could instead take a ticket lock (just like a writer would),
- * and atomically enter read mode (with 1 reader) when it gets the ticket.
- * This way both readers and writers will always make forward progress
- * in a finite time.
+ * We don't need an interrupt critical section here (unlike for
+ * arch_read_lock) since we should never use a bare write lock where
+ * it could be interrupted by code that could try to re-acquire it.
  */
-void arch_read_lock_slow(arch_rwlock_t *rwlock, u32 val)
-{
-	u32 iterations = 0;
-	do {
-		if (!(val & 1))
-			rwlock->lock = val;
-		delay_backoff(iterations++);
-		val = __insn_tns((int *)&rwlock->lock);
-	} while ((val << RD_COUNT_WIDTH) != 0);
-	rwlock->lock = val + (1 << RD_COUNT_SHIFT);
-}
-EXPORT_SYMBOL(arch_read_lock_slow);
-
-void arch_write_lock_slow(arch_rwlock_t *rwlock, u32 val)
+void arch_write_lock(arch_rwlock_t *rwlock)
 {
 	/*
 	 * The trailing underscore on this variable (and curr_ below)
@@ -168,6 +175,12 @@ void arch_write_lock_slow(arch_rwlock_t *rwlock, u32 val)
 	 */
 	u32 my_ticket_;
 	u32 iterations = 0;
+	u32 val = __insn_tns((int *)&rwlock->lock);
+
+	if (likely(val == 0)) {
+		rwlock->lock = 1 << _WR_NEXT_SHIFT;
+		return;
+	}
 
 	/*
 	 * Wait until there are no readers, then bump up the next
@@ -206,23 +219,47 @@ void arch_write_lock_slow(arch_rwlock_t *rwlock, u32 val)
 			relax(4);
 	}
 }
-EXPORT_SYMBOL(arch_write_lock_slow);
+EXPORT_SYMBOL(arch_write_lock);
 
-int __tns_atomic_acquire(atomic_t *lock)
+int arch_write_trylock(arch_rwlock_t *rwlock)
 {
-	int ret;
-	u32 iterations = 0;
+	u32 val = __insn_tns((int *)&rwlock->lock);
 
-	BUG_ON(__insn_mfspr(SPR_INTERRUPT_CRITICAL_SECTION));
-	__insn_mtspr(SPR_INTERRUPT_CRITICAL_SECTION, 1);
+	/*
+	 * If a tns is in progress, or there's a waiting or active locker,
+	 * or active readers, we can't take the lock, so give up.
+	 */
+	if (unlikely(val != 0)) {
+		if (!(val & 1))
+			rwlock->lock = val;
+		return 0;
+	}
 
-	while ((ret = __insn_tns((void *)&lock->counter)) == 1)
-		delay_backoff(iterations++);
-	return ret;
+	/* Set the "next" field to mark it locked. */
+	rwlock->lock = 1 << _WR_NEXT_SHIFT;
+	return 1;
 }
+EXPORT_SYMBOL(arch_write_trylock);
 
-void __tns_atomic_release(atomic_t *p, int v)
+void arch_write_unlock(arch_rwlock_t *rwlock)
 {
-	p->counter = v;
-	__insn_mtspr(SPR_INTERRUPT_CRITICAL_SECTION, 0);
+	u32 val, eq, mask;
+
+	mb();  /* guarantee anything modified under the lock is visible */
+	val = __insn_tns((int *)&rwlock->lock);
+	if (likely(val == (1 << _WR_NEXT_SHIFT))) {
+		rwlock->lock = 0;
+		return;
+	}
+	while (unlikely(val & 1)) {
+		/* Limited backoff since we are the highest-priority task. */
+		relax(4);
+		val = __insn_tns((int *)&rwlock->lock);
+	}
+	mask = 1 << WR_CURR_SHIFT;
+	val = __insn_addb(val, mask);
+	eq = __insn_seqb(val, val << (WR_CURR_SHIFT - WR_NEXT_SHIFT));
+	val = __insn_mz(eq & mask, val);
+	rwlock->lock = val;
 }
+EXPORT_SYMBOL(arch_write_unlock);
-- 
1.6.5.2
