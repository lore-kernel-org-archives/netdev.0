From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] netpoll: use non-BH variant of RCU
Date: Wed, 11 Aug 2010 15:00:47 -0700
Message-ID: <20100811220047.GH2516@linux.vnet.ibm.com>
References: <1281471924-2237-1-git-send-email-linville@tuxdriver.com>
 <20100810204358.GA1076@gondor.apana.org.au>
 <20100810211932.GG2379@linux.vnet.ibm.com>
 <20100810.163117.241919476.davem@davemloft.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, linville@tuxdriver.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:49100 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751392Ab0HKWBA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Aug 2010 18:01:00 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7BLhT52016260
	for <netdev@vger.kernel.org>; Wed, 11 Aug 2010 17:43:29 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7BM0nTM1962200
	for <netdev@vger.kernel.org>; Wed, 11 Aug 2010 18:00:49 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7BM0mbC015965
	for <netdev@vger.kernel.org>; Wed, 11 Aug 2010 18:00:49 -0400
Content-Disposition: inline
In-Reply-To: <20100810.163117.241919476.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 10, 2010 at 04:31:17PM -0700, David Miller wrote:
> From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> Date: Tue, 10 Aug 2010 14:19:32 -0700
> 
> > Your suggestion of providing another API rcu_read_lock_irqsoff()
> > and rcu_read_unlock_irqsoff() is the best I can think of right offhand.
> > 
> > What tree/commit do you need the patch against?
> 
> Linus's tree is fine for this.
> 
> But we need this fix for 2.6.35-stable too.  Herbert would
> you object to putting John's more simple fix there?
> 
> John, when referencing other commits in commit messages,
> please provide the SHA1 ID as well as the commit message
> header line.

And here is an interim patch.  I have queued a slightly different
patch that takes advantage of the more sophisticated PROVE_RCU handling
currently in -tip, but the API is the same, so code written against
this patch will work against the upcoming patch.

Thoughts?

							Thanx, Paul

commit 8934f3fd1092b7ef6a1524e1d2356baeec9f330e
Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Date:   Wed Aug 11 14:54:33 2010 -0700

    rcu: add rcu_read_lock_bh_irqsoff() and rcu_read_unlock_bh_irqsoff()
    
    The rcu_read_lock_bh() and rcu_read_unlock_bh() functions can no
    longer be used when interrupts are disabled due to new debug checks in
    the _local_bh_enable() function.  This commit therefore supplies new
    functions that may only be called with either interrupts disabled or
    from interrupt handlers, and this is checked for under CONFIG_PROVE_RCU.
    
    Requested-by: Herbert Xu <herbert@gondor.apana.org.au>
    Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
index 9fbc54a..08cdc58 100644
--- a/include/linux/rcupdate.h
+++ b/include/linux/rcupdate.h
@@ -270,10 +270,13 @@ extern int rcu_my_thread_group_empty(void);
 		(p); \
 	})
 
+void rcu_read_unlock_bh_irqsoff_check(void);
+
 #else /* #ifdef CONFIG_PROVE_RCU */
 
 #define rcu_dereference_check(p, c)	rcu_dereference_raw(p)
 #define rcu_dereference_protected(p, c) (p)
+#define rcu_read_unlock_bh_irqsoff_check() do { } while (0)
 
 #endif /* #else #ifdef CONFIG_PROVE_RCU */
 
@@ -361,13 +364,13 @@ static inline void rcu_read_unlock(void)
  */
 static inline void rcu_read_lock_bh(void)
 {
-	__rcu_read_lock_bh();
+	local_bh_disable();
 	__acquire(RCU_BH);
 	rcu_read_acquire_bh();
 }
 
 /*
- * rcu_read_unlock_bh - marks the end of a softirq-only RCU critical section
+ * rcu_read_unlock_bh() - marks the end of a softirq-only RCU critical section
  *
  * See rcu_read_lock_bh() for more information.
  */
@@ -375,7 +378,34 @@ static inline void rcu_read_unlock_bh(void)
 {
 	rcu_read_release_bh();
 	__release(RCU_BH);
-	__rcu_read_unlock_bh();
+	local_bh_enable();
+}
+
+/**
+ * rcu_read_lock_bh_irqsoff() - mark the beginning of an RCU-bh critical section
+ *
+ * This is equivalent of rcu_read_lock_bh(), but to be used where the
+ * caller either is in an irq handler or has irqs disabled.  Note that
+ * this function assumes that PREEMPT_RT kernels run irq handlers at
+ * higher priority than softirq handlers!
+ */
+static inline void rcu_read_lock_bh_irqsoff(void)
+{
+	rcu_read_unlock_bh_irqsoff_check();
+	__acquire(RCU_BH);
+	rcu_read_acquire_bh();
+}
+
+/*
+ * rcu_read_unlock_bh_irqsoff - marks the end of an RCU-bh critical section
+ *
+ * See rcu_read_lock_bh_irqsoff() for more information.
+ */
+static inline void rcu_read_unlock_bh_irqsoff(void)
+{
+	rcu_read_release_bh();
+	__release(RCU_BH);
+	rcu_read_unlock_bh_irqsoff_check();
 }
 
 /**
diff --git a/include/linux/rcutiny.h b/include/linux/rcutiny.h
index e2e8931..009c7f3 100644
--- a/include/linux/rcutiny.h
+++ b/include/linux/rcutiny.h
@@ -36,8 +36,6 @@ static inline void rcu_note_context_switch(int cpu)
 
 #define __rcu_read_lock()	preempt_disable()
 #define __rcu_read_unlock()	preempt_enable()
-#define __rcu_read_lock_bh()	local_bh_disable()
-#define __rcu_read_unlock_bh()	local_bh_enable()
 #define call_rcu_sched		call_rcu
 
 #define rcu_init_sched()	do { } while (0)
diff --git a/include/linux/rcutree.h b/include/linux/rcutree.h
index c0ed1c0..98b50d8 100644
--- a/include/linux/rcutree.h
+++ b/include/linux/rcutree.h
@@ -75,15 +75,6 @@ static inline int rcu_preempt_depth(void)
 
 #endif /* #else #ifdef CONFIG_TREE_PREEMPT_RCU */
 
-static inline void __rcu_read_lock_bh(void)
-{
-	local_bh_disable();
-}
-static inline void __rcu_read_unlock_bh(void)
-{
-	local_bh_enable();
-}
-
 extern void call_rcu_sched(struct rcu_head *head,
 			   void (*func)(struct rcu_head *rcu));
 extern void synchronize_rcu_bh(void);
diff --git a/kernel/rcupdate.c b/kernel/rcupdate.c
index 4d16983..d159835 100644
--- a/kernel/rcupdate.c
+++ b/kernel/rcupdate.c
@@ -113,6 +113,12 @@ int rcu_my_thread_group_empty(void)
 	return thread_group_empty(current);
 }
 EXPORT_SYMBOL_GPL(rcu_my_thread_group_empty);
+
+void rcu_read_unlock_bh_irqsoff_check(void)
+{
+	WARN_ON_ONCE(in_irq() || irqs_disabled());
+}
+EXPORT_SYMBOL_GPL(rcu_read_unlock_bh_irqsoff_check);
 #endif /* #ifdef CONFIG_PROVE_RCU */
 
 #ifdef CONFIG_DEBUG_OBJECTS_RCU_HEAD
