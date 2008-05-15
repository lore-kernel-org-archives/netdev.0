From: Nick Piggin <npiggin@suse.de>
Subject: [patch][rfc] ccid: fix memory ordering in locking
Date: Thu, 15 May 2008 04:19:26 +0200
Message-ID: <20080515021926.GG30448@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, oleg@tv-sign.ru, acme@mandriva.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:47628 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751738AbYEOCT1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2008 22:19:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Just happened upon this code, which I think looks risky. Would be nice to
clean it up, although I admit I have not tested this patch because I'm
not exactly sure how to exercise it.

ccids_read_unlock does simply an atomic_dec to unlock. atomic_dec does not
provide any memory ordering guarantees, so loads under the locked section
might end up being performed after the store to unlock becomes visible.
Use regular locking primitives for this instead. Please always do this
rather than open coding them. (also, yield might be a busy loop if we're
the only one on the CPU, so add a cpu_relax too).

What exactly is being protected with the read lock, BTW? It looks like
to prevent module freeing after we find it but before we take a reference
on the module? I'd have thought the module unloading code should provide
facilities to do this easily without taking any locks. If not, we could do
it using RCU in the unregister routine quite easily by the look of it.

Thanks,
Nick

Index: linux-2.6/net/dccp/ccid.c
===================================================================
--- linux-2.6.orig/net/dccp/ccid.c
+++ linux-2.6/net/dccp/ccid.c
@@ -14,9 +14,7 @@
 #include "ccid.h"
 
 static struct ccid_operations *ccids[CCID_MAX];
-#if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
-static atomic_t ccids_lockct = ATOMIC_INIT(0);
-static DEFINE_SPINLOCK(ccids_lock);
+static DEFINE_RWLOCK(ccids_lock);
 
 /*
  * The strategy is: modifications ccids vector are short, do not sleep and
@@ -24,38 +22,29 @@ static DEFINE_SPINLOCK(ccids_lock);
  */
 static void ccids_write_lock(void)
 {
-	spin_lock(&ccids_lock);
-	while (atomic_read(&ccids_lockct) != 0) {
-		spin_unlock(&ccids_lock);
-		yield();
-		spin_lock(&ccids_lock);
+	while (!write_trylock(&ccids_lock)) {
+		while (!write_can_lock(&ccids_lock)) {
+			cpu_relax();
+			yield();
+		}
 	}
 }
 
 static inline void ccids_write_unlock(void)
 {
-	spin_unlock(&ccids_lock);
+	write_unlock(&ccids_lock);
 }
 
 static inline void ccids_read_lock(void)
 {
-	atomic_inc(&ccids_lockct);
-	smp_mb__after_atomic_inc();
-	spin_unlock_wait(&ccids_lock);
+	read_lock(&ccids_lock);
 }
 
 static inline void ccids_read_unlock(void)
 {
-	atomic_dec(&ccids_lockct);
+	read_unlock(&ccids_lock);
 }
 
-#else
-#define ccids_write_lock() do { } while(0)
-#define ccids_write_unlock() do { } while(0)
-#define ccids_read_lock() do { } while(0)
-#define ccids_read_unlock() do { } while(0)
-#endif
-
 static struct kmem_cache *ccid_kmem_cache_create(int obj_size, const char *fmt,...)
 {
 	struct kmem_cache *slab;
