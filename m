From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH 1/4] rcu: introduce noref debug
Date: Fri,  6 Oct 2017 14:57:46 +0200
Message-ID: <bc39fa36c0765e6d2f7dab82e4c6460989669957.1507294365.git.pabeni@redhat.com>
References: <cover.1507294365.git.pabeni@redhat.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Josh Triplett <josh@joshtriplett.org>,
        Steven Rostedt <rostedt@goodmis.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1507294365.git.pabeni@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We currently lack a debugging infrastructure to ensure that
long-lived noref dst are properly handled - namely dropped
or converted to a refcounted version before escaping the current
RCU section.

This changeset implements such infra, tracking the noref pointer
on a per CPU store and checking that all noref tracked at any
given RCU nesting level are cleared before leaving such RCU
section.

Each noref entity is identified using the entity pointer and an
additional, optional, key/opaque pointer. This is needed to cope
with usage case scenario where the same noref entity is stored
in different places (e.g. noref dst on skb_clone()).

To keep the patch/implementation simple RCU_NOREF_DEBUG depends
on PREEMPT_RCU=n in Kconfig.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/linux/rcupdate.h | 11 ++++++
 kernel/rcu/Kconfig.debug | 15 ++++++++
 kernel/rcu/Makefile      |  1 +
 kernel/rcu/noref_debug.c | 89 ++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 116 insertions(+)
 create mode 100644 kernel/rcu/noref_debug.c

diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
index de50d8a4cf41..20c1ce08e3eb 100644
--- a/include/linux/rcupdate.h
+++ b/include/linux/rcupdate.h
@@ -60,6 +60,15 @@ void call_rcu_sched(struct rcu_head *head, rcu_callback_t func);
 void synchronize_sched(void);
 void rcu_barrier_tasks(void);
 
+#ifdef CONFIG_RCU_NOREF_DEBUG
+void rcu_track_noref(void *key, void *noref, bool track);
+void __rcu_check_noref(void);
+
+#else
+static inline void rcu_track_noref(void *key, void *noref, bool add) { }
+static inline void __rcu_check_noref(void) { }
+#endif
+
 #ifdef CONFIG_PREEMPT_RCU
 
 void __rcu_read_lock(void);
@@ -85,6 +94,7 @@ static inline void __rcu_read_lock(void)
 
 static inline void __rcu_read_unlock(void)
 {
+	__rcu_check_noref();
 	if (IS_ENABLED(CONFIG_PREEMPT_COUNT))
 		preempt_enable();
 }
@@ -723,6 +733,7 @@ static inline void rcu_read_unlock_bh(void)
 			 "rcu_read_unlock_bh() used illegally while idle");
 	rcu_lock_release(&rcu_bh_lock_map);
 	__release(RCU_BH);
+	__rcu_check_noref();
 	local_bh_enable();
 }
 
diff --git a/kernel/rcu/Kconfig.debug b/kernel/rcu/Kconfig.debug
index 0ec7d1d33a14..6c7f52a3e809 100644
--- a/kernel/rcu/Kconfig.debug
+++ b/kernel/rcu/Kconfig.debug
@@ -68,6 +68,21 @@ config RCU_TRACE
 	  Say Y here if you want to enable RCU tracing
 	  Say N if you are unsure.
 
+config RCU_NOREF_DEBUG
+	bool "Debugging for RCU-protected noref entries"
+	depends on PREEMPT_RCU=n
+	select PREEMPT_COUNT
+	default n
+	help
+	  In case of long lasting rcu_read_lock sections this debug
+	  feature enables one to ensure that no rcu managed dereferenced
+	  data leaves the locked section. One use case is the tracking
+	  of dst_entries in struct sk_buff ->dst, which is used to pass
+	  the dst_entry around in the whole stack while under RCU lock.
+
+	  Say Y here if you want to enable noref RCU debugging
+	  Say N if you are unsure.
+
 config RCU_EQS_DEBUG
 	bool "Provide debugging asserts for adding NO_HZ support to an arch"
 	depends on DEBUG_KERNEL
diff --git a/kernel/rcu/Makefile b/kernel/rcu/Makefile
index 13c0fc852767..c67d7c65c582 100644
--- a/kernel/rcu/Makefile
+++ b/kernel/rcu/Makefile
@@ -11,3 +11,4 @@ obj-$(CONFIG_TREE_RCU) += tree.o
 obj-$(CONFIG_PREEMPT_RCU) += tree.o
 obj-$(CONFIG_TINY_RCU) += tiny.o
 obj-$(CONFIG_RCU_NEED_SEGCBLIST) += rcu_segcblist.o
+obj-$(CONFIG_RCU_NOREF_DEBUG) += noref_debug.o
\ No newline at end of file
diff --git a/kernel/rcu/noref_debug.c b/kernel/rcu/noref_debug.c
new file mode 100644
index 000000000000..ae2e104b11d6
--- /dev/null
+++ b/kernel/rcu/noref_debug.c
@@ -0,0 +1,89 @@
+#include <linux/bug.h>
+#include <linux/percpu.h>
+#include <linux/skbuff.h>
+#include <linux/bitops.h>
+
+#define NOREF_MAX 7
+struct noref_entry {
+	void *noref;
+	void *key;
+	int nesting;
+};
+
+struct noref_cache {
+	struct noref_entry store[NOREF_MAX];
+};
+
+static DEFINE_PER_CPU(struct noref_cache, per_cpu_noref_cache);
+
+static int noref_cache_lookup(struct noref_cache *cache, void *noref, void *key)
+{
+	int i;
+
+	for (i = 0; i < NOREF_MAX; ++i)
+		if (cache->store[i].noref == noref &&
+		    cache->store[i].key == key)
+			return i;
+
+	return -1;
+}
+
+void rcu_track_noref(void *key, void *noref, bool track)
+{
+	struct noref_cache *cache = this_cpu_ptr(&per_cpu_noref_cache);
+	int i;
+
+	if (track) {
+		/* find the first empty slot */
+		i = noref_cache_lookup(cache, NULL, 0);
+		if (i < 0) {
+			WARN_ONCE(1, "can't find empty an slot to track a noref"
+				  " noref tracking will be inaccurate");
+			return;
+		}
+
+		cache->store[i].noref = noref;
+		cache->store[i].key = key;
+		cache->store[i].nesting = preempt_count();
+		return;
+	}
+
+	i = noref_cache_lookup(cache, noref, key);
+	if (i == -1) {
+		WARN_ONCE(1, "to-be-untracked noref entity %p not found in "
+			  "cache\n", noref);
+		return;
+	}
+
+	cache->store[i].noref = NULL;
+	cache->store[i].key = NULL;
+	cache->store[i].nesting = 0;
+}
+EXPORT_SYMBOL_GPL(rcu_track_noref);
+
+void __rcu_check_noref(void)
+{
+	struct noref_cache *cache = this_cpu_ptr(&per_cpu_noref_cache);
+	char *cur, buf[strlen("0xffffffffffffffff") * NOREF_MAX + 1];
+	int nesting = preempt_count();
+	int i, ret, cnt = 0;
+
+	cur = buf;
+	for (i = 0; i < NOREF_MAX; ++i) {
+		if (!cache->store[i].noref ||
+		    cache->store[i].nesting != nesting)
+			continue;
+
+		cnt++;
+		ret = sprintf(cur, " %p", cache->store[i].noref);
+		if (ret >= 0)
+			cur += ret;
+		cache->store[i].noref = NULL;
+		cache->store[i].key = NULL;
+		cache->store[i].nesting = 0;
+	}
+
+	WARN_ONCE(cnt, "%d noref entities escaped an RCU section, "
+		  "nesting %d, leaked noref list %s", cnt, nesting, buf);
+}
+EXPORT_SYMBOL_GPL(__rcu_check_noref);
-- 
2.13.6
