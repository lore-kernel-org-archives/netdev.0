From: David Kilroy <kilroyd@googlemail.com>
Subject: [PATCH] check spinlock_t/rwlock_t argument type on non-SMP builds
Date: Thu,  2 Jul 2009 19:44:51 +0100
Message-ID: <1246560291-8104-1-git-send-email-kilroyd@googlemail.com>
Cc: netdev@vger.kernel.org, David Kilroy <kilroyd@googlemail.com>,
	Ingo Molnar <mingo@elte.hu>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f215.google.com ([209.85.219.215]:58032 "EHLO
	mail-ew0-f215.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751117AbZGBSwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 14:52:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When writing code for UP without CONFIG_DEBUG_SPINLOCK it's easy to get
the first argument to the spinlock/rwlock functions wrong. This is
because the parameter is not actually used in this configuration.

Typically you will only find out it's wrong
 * by rebuilding with CONFIG_SMP or CONFIG_DEBUG_SPINLOCK
 * after you've submitted your beautiful patch series.

The first means a long wait, and the latter is a bit late.

Add typechecking on the first argument of these macro functions. Note
that since the typecheck now references the variable, the explicit read
is redundant and can be removed.

This change causes compiler warnings in net/ipv4/route.c, as this passes
NULL as the first argument in the UP configuration. Simply cast this.

Signed-off-by: David Kilroy <kilroyd@googlemail.com>
Cc: Ingo Molnar <mingo@elte.hu>
---

I've checked the assembly and object output resulting from this change
for x86. As far as I can tell there are only differences in the
debugging symbols used to refer to some variables. The stripped objects
which I checked are identical.

I've also done an allyesconfig build (with various lock debugging
options off to keep CONFIG_DEBUG_SPINLOCK off), and there are no extra
compiler warnings (except those addressed in route.c).

---
 include/linux/spinlock_api_up.h |   90 +++++++++++++++++++-------------------
 net/ipv4/route.c                |    2 +-
 2 files changed, 46 insertions(+), 46 deletions(-)

diff --git a/include/linux/spinlock_api_up.h b/include/linux/spinlock_api_up.h
index 04e1d31..7780138 100644
--- a/include/linux/spinlock_api_up.h
+++ b/include/linux/spinlock_api_up.h
@@ -24,58 +24,58 @@
  * flags straight, to suppress compiler warnings of unused lock
  * variables, and to add the proper checker annotations:
  */
-#define __LOCK(lock) \
-  do { preempt_disable(); __acquire(lock); (void)(lock); } while (0)
+#define __LOCK(type, lock) \
+  do { typecheck(type*, lock); preempt_disable(); __acquire(lock); } while (0)
 
-#define __LOCK_BH(lock) \
-  do { local_bh_disable(); __LOCK(lock); } while (0)
+#define __LOCK_BH(type, lock) \
+  do { local_bh_disable(); __LOCK(type, lock); } while (0)
 
-#define __LOCK_IRQ(lock) \
-  do { local_irq_disable(); __LOCK(lock); } while (0)
+#define __LOCK_IRQ(type, lock) \
+  do { local_irq_disable(); __LOCK(type, lock); } while (0)
 
-#define __LOCK_IRQSAVE(lock, flags) \
-  do { local_irq_save(flags); __LOCK(lock); } while (0)
+#define __LOCK_IRQSAVE(type, lock, flags) \
+  do { local_irq_save(flags); __LOCK(type, lock); } while (0)
 
-#define __UNLOCK(lock) \
-  do { preempt_enable(); __release(lock); (void)(lock); } while (0)
+#define __UNLOCK(type, lock) \
+  do { typecheck(type*, lock); preempt_enable(); __release(lock); } while (0)
 
-#define __UNLOCK_BH(lock) \
-  do { preempt_enable_no_resched(); local_bh_enable(); __release(lock); (void)(lock); } while (0)
+#define __UNLOCK_BH(type, lock) \
+  do { typecheck(type*, lock); preempt_enable_no_resched(); local_bh_enable(); __release(lock); } while (0)
 
-#define __UNLOCK_IRQ(lock) \
-  do { local_irq_enable(); __UNLOCK(lock); } while (0)
+#define __UNLOCK_IRQ(type, lock) \
+  do { local_irq_enable(); __UNLOCK(type, lock); } while (0)
 
-#define __UNLOCK_IRQRESTORE(lock, flags) \
-  do { local_irq_restore(flags); __UNLOCK(lock); } while (0)
+#define __UNLOCK_IRQRESTORE(type, lock, flags) \
+  do { local_irq_restore(flags); __UNLOCK(type, lock); } while (0)
 
-#define _spin_lock(lock)			__LOCK(lock)
-#define _spin_lock_nested(lock, subclass)	__LOCK(lock)
-#define _read_lock(lock)			__LOCK(lock)
-#define _write_lock(lock)			__LOCK(lock)
-#define _spin_lock_bh(lock)			__LOCK_BH(lock)
-#define _read_lock_bh(lock)			__LOCK_BH(lock)
-#define _write_lock_bh(lock)			__LOCK_BH(lock)
-#define _spin_lock_irq(lock)			__LOCK_IRQ(lock)
-#define _read_lock_irq(lock)			__LOCK_IRQ(lock)
-#define _write_lock_irq(lock)			__LOCK_IRQ(lock)
-#define _spin_lock_irqsave(lock, flags)		__LOCK_IRQSAVE(lock, flags)
-#define _read_lock_irqsave(lock, flags)		__LOCK_IRQSAVE(lock, flags)
-#define _write_lock_irqsave(lock, flags)	__LOCK_IRQSAVE(lock, flags)
-#define _spin_trylock(lock)			({ __LOCK(lock); 1; })
-#define _read_trylock(lock)			({ __LOCK(lock); 1; })
-#define _write_trylock(lock)			({ __LOCK(lock); 1; })
-#define _spin_trylock_bh(lock)			({ __LOCK_BH(lock); 1; })
-#define _spin_unlock(lock)			__UNLOCK(lock)
-#define _read_unlock(lock)			__UNLOCK(lock)
-#define _write_unlock(lock)			__UNLOCK(lock)
-#define _spin_unlock_bh(lock)			__UNLOCK_BH(lock)
-#define _write_unlock_bh(lock)			__UNLOCK_BH(lock)
-#define _read_unlock_bh(lock)			__UNLOCK_BH(lock)
-#define _spin_unlock_irq(lock)			__UNLOCK_IRQ(lock)
-#define _read_unlock_irq(lock)			__UNLOCK_IRQ(lock)
-#define _write_unlock_irq(lock)			__UNLOCK_IRQ(lock)
-#define _spin_unlock_irqrestore(lock, flags)	__UNLOCK_IRQRESTORE(lock, flags)
-#define _read_unlock_irqrestore(lock, flags)	__UNLOCK_IRQRESTORE(lock, flags)
-#define _write_unlock_irqrestore(lock, flags)	__UNLOCK_IRQRESTORE(lock, flags)
+#define _spin_lock(lock)			__LOCK(spinlock_t, lock)
+#define _spin_lock_nested(lock, subclass)	__LOCK(spinlock_t, lock)
+#define _read_lock(lock)			__LOCK(rwlock_t, lock)
+#define _write_lock(lock)			__LOCK(rwlock_t, lock)
+#define _spin_lock_bh(lock)			__LOCK_BH(spinlock_t, lock)
+#define _read_lock_bh(lock)			__LOCK_BH(rwlock_t, lock)
+#define _write_lock_bh(lock)			__LOCK_BH(rwlock_t, lock)
+#define _spin_lock_irq(lock)			__LOCK_IRQ(spinlock_t, lock)
+#define _read_lock_irq(lock)			__LOCK_IRQ(rwlock_t, lock)
+#define _write_lock_irq(lock)			__LOCK_IRQ(rwlock_t, lock)
+#define _spin_lock_irqsave(lock, flags)		__LOCK_IRQSAVE(spinlock_t, lock, flags)
+#define _read_lock_irqsave(lock, flags)		__LOCK_IRQSAVE(rwlock_t, lock, flags)
+#define _write_lock_irqsave(lock, flags)	__LOCK_IRQSAVE(rwlock_t, lock, flags)
+#define _spin_trylock(lock)			({ __LOCK(spinlock_t, lock); 1; })
+#define _read_trylock(lock)			({ __LOCK(rwlock_t, lock); 1; })
+#define _write_trylock(lock)			({ __LOCK(rwlock_t, lock); 1; })
+#define _spin_trylock_bh(lock)			({ __LOCK_BH(spinlock_t, lock); 1; })
+#define _spin_unlock(lock)			__UNLOCK(spinlock_t, lock)
+#define _read_unlock(lock)			__UNLOCK(rwlock_t, lock)
+#define _write_unlock(lock)			__UNLOCK(rwlock_t, lock)
+#define _spin_unlock_bh(lock)			__UNLOCK_BH(spinlock_t, lock)
+#define _write_unlock_bh(lock)			__UNLOCK_BH(rwlock_t, lock)
+#define _read_unlock_bh(lock)			__UNLOCK_BH(rwlock_t, lock)
+#define _spin_unlock_irq(lock)			__UNLOCK_IRQ(spinlock_t, lock)
+#define _read_unlock_irq(lock)			__UNLOCK_IRQ(rwlock_t, lock)
+#define _write_unlock_irq(lock)			__UNLOCK_IRQ(rwlock_t, lock)
+#define _spin_unlock_irqrestore(lock, flags)	__UNLOCK_IRQRESTORE(spinlock_t, lock, flags)
+#define _read_unlock_irqrestore(lock, flags)	__UNLOCK_IRQRESTORE(rwlock_t, lock, flags)
+#define _write_unlock_irqrestore(lock, flags)	__UNLOCK_IRQRESTORE(rwlock_t, lock, flags)
 
 #endif /* __LINUX_SPINLOCK_API_UP_H */
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 28205e5..8edfffd 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -242,7 +242,7 @@ static __init void rt_hash_lock_init(void)
 		spin_lock_init(&rt_hash_locks[i]);
 }
 #else
-# define rt_hash_lock_addr(slot) NULL
+# define rt_hash_lock_addr(slot) ((spinlock_t *) NULL)
 
 static inline void rt_hash_lock_init(void)
 {
-- 
1.6.0.6

