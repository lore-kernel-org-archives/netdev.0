From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 4/5] spinlock: Add spin_lock_bh_nested()
Date: Mon, 15 Sep 2014 14:18:03 +0200
Message-ID: <146176bc39cec27e9e40a7a484581beed0f1b176.1410782841.git.tgraf@suug.ch>
References: <cover.1410782841.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, eric.dumazet@gmail.com,
	paulmck@linux.vnet.ibm.com, john.r.fastabend@intel.com,
	kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:47323 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813AbaIOMSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 08:18:10 -0400
In-Reply-To: <cover.1410782841.git.tgraf@suug.ch>
In-Reply-To: <cover.1410782841.git.tgraf@suug.ch>
References: <cover.1410782841.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/linux/spinlock.h         | 8 ++++++++
 include/linux/spinlock_api_smp.h | 2 ++
 include/linux/spinlock_api_up.h  | 1 +
 kernel/locking/spinlock.c        | 8 ++++++++
 4 files changed, 19 insertions(+)

diff --git a/include/linux/spinlock.h b/include/linux/spinlock.h
index 3f2867f..481180a 100644
--- a/include/linux/spinlock.h
+++ b/include/linux/spinlock.h
@@ -190,6 +190,8 @@ static inline void do_raw_spin_unlock(raw_spinlock_t *lock) __releases(lock)
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
 # define raw_spin_lock_nested(lock, subclass) \
 	_raw_spin_lock_nested(lock, subclass)
+# define raw_spin_lock_bh_nested(lock, subclass) \
+	_raw_spin_lock_bh_nested(lock, subclass)
 
 # define raw_spin_lock_nest_lock(lock, nest_lock)			\
 	 do {								\
@@ -199,6 +201,7 @@ static inline void do_raw_spin_unlock(raw_spinlock_t *lock) __releases(lock)
 #else
 # define raw_spin_lock_nested(lock, subclass)		_raw_spin_lock(lock)
 # define raw_spin_lock_nest_lock(lock, nest_lock)	_raw_spin_lock(lock)
+# define raw_spin_lock_bh_nested(lock, subclass)	_raw_spin_lock_bh(lock)
 #endif
 
 #if defined(CONFIG_SMP) || defined(CONFIG_DEBUG_SPINLOCK)
@@ -318,6 +321,11 @@ do {								\
 	raw_spin_lock_nested(spinlock_check(lock), subclass);	\
 } while (0)
 
+#define spin_lock_bh_nested(lock, subclass)			\
+do {								\
+	raw_spin_lock_bh_nested(spinlock_check(lock), subclass);\
+} while (0)
+
 #define spin_lock_nest_lock(lock, nest_lock)				\
 do {									\
 	raw_spin_lock_nest_lock(spinlock_check(lock), nest_lock);	\
diff --git a/include/linux/spinlock_api_smp.h b/include/linux/spinlock_api_smp.h
index 42dfab8..5344268 100644
--- a/include/linux/spinlock_api_smp.h
+++ b/include/linux/spinlock_api_smp.h
@@ -22,6 +22,8 @@ int in_lock_functions(unsigned long addr);
 void __lockfunc _raw_spin_lock(raw_spinlock_t *lock)		__acquires(lock);
 void __lockfunc _raw_spin_lock_nested(raw_spinlock_t *lock, int subclass)
 								__acquires(lock);
+void __lockfunc _raw_spin_lock_bh_nested(raw_spinlock_t *lock, int subclass)
+								__acquires(lock);
 void __lockfunc
 _raw_spin_lock_nest_lock(raw_spinlock_t *lock, struct lockdep_map *map)
 								__acquires(lock);
diff --git a/include/linux/spinlock_api_up.h b/include/linux/spinlock_api_up.h
index d0d1888..d3afef9 100644
--- a/include/linux/spinlock_api_up.h
+++ b/include/linux/spinlock_api_up.h
@@ -57,6 +57,7 @@
 
 #define _raw_spin_lock(lock)			__LOCK(lock)
 #define _raw_spin_lock_nested(lock, subclass)	__LOCK(lock)
+#define _raw_spin_lock_bh_nested(lock, subclass) __LOCK(lock)
 #define _raw_read_lock(lock)			__LOCK(lock)
 #define _raw_write_lock(lock)			__LOCK(lock)
 #define _raw_spin_lock_bh(lock)			__LOCK_BH(lock)
diff --git a/kernel/locking/spinlock.c b/kernel/locking/spinlock.c
index 4b082b5..db3ccb1 100644
--- a/kernel/locking/spinlock.c
+++ b/kernel/locking/spinlock.c
@@ -363,6 +363,14 @@ void __lockfunc _raw_spin_lock_nested(raw_spinlock_t *lock, int subclass)
 }
 EXPORT_SYMBOL(_raw_spin_lock_nested);
 
+void __lockfunc _raw_spin_lock_bh_nested(raw_spinlock_t *lock, int subclass)
+{
+	__local_bh_disable_ip(_RET_IP_, SOFTIRQ_LOCK_OFFSET);
+	spin_acquire(&lock->dep_map, subclass, 0, _RET_IP_);
+	LOCK_CONTENDED(lock, do_raw_spin_trylock, do_raw_spin_lock);
+}
+EXPORT_SYMBOL(_raw_spin_lock_bh_nested);
+
 unsigned long __lockfunc _raw_spin_lock_irqsave_nested(raw_spinlock_t *lock,
 						   int subclass)
 {
-- 
1.9.3
