From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH] lockdep: annotate rcu_read_{,un}lock()
Date: Thu, 16 Aug 2007 16:25:07 +0200
Message-ID: <1187274307.6114.92.camel@twins>
References: <af57f1ac0708141130v729fa636k3150673809ec20a8@mail.gmail.com>
	 <E1ILEJr-0005Fl-00@gondolin.me.apana.org.au>
	 <20070815.144628.104052147.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, 123.oleg@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Daniel Walker <dwalker@mvista.com>
To: Paul E McKenney <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:52712 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753566AbXHPOZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 10:25:45 -0400
In-Reply-To: <20070815.144628.104052147.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


There seem to be some unbalanced rcu_read_{,un}lock() issues of late,
how about doing something like this:

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/lockdep.h  |    7 +++++++
 include/linux/rcupdate.h |   12 ++++++++++++
 kernel/rcupdate.c        |    8 ++++++++
 3 files changed, 27 insertions(+)

Index: linux-2.6/include/linux/lockdep.h
===================================================================
--- linux-2.6.orig/include/linux/lockdep.h
+++ linux-2.6/include/linux/lockdep.h
@@ -252,6 +252,13 @@ extern void lockdep_init_map(struct lock
 			     struct lock_class_key *key, int subclass);
 
 /*
+ * To initialize a lockdep_map statically use this macro.
+ * Note that _name must not be NULL.
+ */
+#define STATIC_LOCKDEP_MAP_INIT(_name, _key) \
+	{ .name = (_name), .key = (void *)(_key), }
+
+/*
  * Reinitialize a lock key - for cases where there is special locking or
  * special initialization of locks so that the validator gets the scope
  * of dependencies wrong: they are either too broad (they need a class-split)
Index: linux-2.6/include/linux/rcupdate.h
===================================================================
--- linux-2.6.orig/include/linux/rcupdate.h
+++ linux-2.6/include/linux/rcupdate.h
@@ -41,6 +41,7 @@
 #include <linux/percpu.h>
 #include <linux/cpumask.h>
 #include <linux/seqlock.h>
+#include <linux/lockdep.h>
 
 /**
  * struct rcu_head - callback structure for use with RCU
@@ -133,6 +134,15 @@ static inline void rcu_bh_qsctr_inc(int 
 extern int rcu_pending(int cpu);
 extern int rcu_needs_cpu(int cpu);
 
+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+extern struct lockdep_map rcu_lock_map;
+# define rcu_read_acquire()	lock_acquire(&rcu_lock_map, 0, 0, 2, 1, _THIS_IP_)
+# define rcu_read_release()	lock_release(&rcu_lock_map, 1, _THIS_IP_)
+#else
+# define rcu_read_acquire()	do { } while (0)
+# define rcu_read_release()	do { } while (0)
+#endif
+
 /**
  * rcu_read_lock - mark the beginning of an RCU read-side critical section.
  *
@@ -166,6 +176,7 @@ extern int rcu_needs_cpu(int cpu);
 	do { \
 		preempt_disable(); \
 		__acquire(RCU); \
+		rcu_read_acquire(); \
 	} while(0)
 
 /**
@@ -175,6 +186,7 @@ extern int rcu_needs_cpu(int cpu);
  */
 #define rcu_read_unlock() \
 	do { \
+		rcu_read_release(); \
 		__release(RCU); \
 		preempt_enable(); \
 	} while(0)
Index: linux-2.6/kernel/rcupdate.c
===================================================================
--- linux-2.6.orig/kernel/rcupdate.c
+++ linux-2.6/kernel/rcupdate.c
@@ -49,6 +49,14 @@
 #include <linux/cpu.h>
 #include <linux/mutex.h>
 
+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+static struct lock_class_key rcu_lock_key;
+struct lockdep_map rcu_lock_map =
+	STATIC_LOCKDEP_MAP_INIT("rcu_read_lock", &rcu_lock_key);
+
+EXPORT_SYMBOL_GPL(rcu_lock_map);
+#endif
+
 /* Definition for rcupdate control block. */
 static struct rcu_ctrlblk rcu_ctrlblk = {
 	.cur = -300,


