From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 6/9] spinlock: Add spin_lock_bh_nested()
Date: Fri,  2 Jan 2015 23:00:19 +0100
Message-ID: <f858445f9a939d8c543fe9b34246ef7165072413.1420230585.git.tgraf@suug.ch>
References: <cover.1420230585.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	herbert@gondor.apana.org.au, paulmck@linux.vnet.ibm.com,
	edumazet@google.com, john.r.fastabend@intel.com,
	josh@joshtriplett.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1420230585.git.tgraf@suug.ch>
In-Reply-To: <cover.1420230585.git.tgraf@suug.ch>
References: <cover.1420230585.git.tgraf@suug.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/linux/spinlock.h         | 8 ++++++++
 include/linux/spinlock_api_smp.h | 2 ++
 include/linux/spinlock_api_up.h  | 1 +
 kernel/locking/spinlock.c        | 8 ++++++++
 4 files changed, 19 insertions(+)

diff --git a/include/linux/spinlock.h b/include/linux/spinlock.h
index 262ba4e..3e18379 100644
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
@@ -205,6 +207,7 @@ static inline void do_raw_spin_unlock(raw_spinlock_t *lock) __releases(lock)
 # define raw_spin_lock_nested(lock, subclass)		\
 	_raw_spin_lock(((void)(subclass), (lock)))
 # define raw_spin_lock_nest_lock(lock, nest_lock)	_raw_spin_lock(lock)
+# define raw_spin_lock_bh_nested(lock, subclass)	_raw_spin_lock_bh(lock)
 #endif
 
 #if defined(CONFIG_SMP) || defined(CONFIG_DEBUG_SPINLOCK)
@@ -324,6 +327,11 @@ do {								\
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
