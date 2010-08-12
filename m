From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] netpoll: use non-BH variant of RCU
Date: Thu, 12 Aug 2010 08:42:13 -0700
Message-ID: <20100812154213.GB2524@linux.vnet.ibm.com>
References: <20100810211932.GG2379@linux.vnet.ibm.com>
 <20100810.163117.241919476.davem@davemloft.net>
 <20100811220047.GH2516@linux.vnet.ibm.com>
 <20100811.230936.183035599.davem@davemloft.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, linville@tuxdriver.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:38932 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933825Ab0HLPm1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Aug 2010 11:42:27 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7CFSlWG002283
	for <netdev@vger.kernel.org>; Thu, 12 Aug 2010 11:28:47 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7CFgE4o1798202
	for <netdev@vger.kernel.org>; Thu, 12 Aug 2010 11:42:14 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7CFgD03032105
	for <netdev@vger.kernel.org>; Thu, 12 Aug 2010 11:42:14 -0400
Content-Disposition: inline
In-Reply-To: <20100811.230936.183035599.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 11, 2010 at 11:09:36PM -0700, David Miller wrote:
> From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> Date: Wed, 11 Aug 2010 15:00:47 -0700
> 
> > @@ -113,6 +113,12 @@ int rcu_my_thread_group_empty(void)
> >  	return thread_group_empty(current);
> >  }
> >  EXPORT_SYMBOL_GPL(rcu_my_thread_group_empty);
> > +
> > +void rcu_read_unlock_bh_irqsoff_check(void)
> > +{
> > +	WARN_ON_ONCE(in_irq() || irqs_disabled());
> > +}
> > +EXPORT_SYMBOL_GPL(rcu_read_unlock_bh_irqsoff_check);
> >  #endif /* #ifdef CONFIG_PROVE_RCU */
> 
> Is this WARN_ON_ONCE() test inverted?  It seems to be called where we
> "should be" in an IRQ or have IRQs disabled.

You are quite correct.  (Beat head against wall.)  :-/

------------------------------------------------------------------------

#!/bin/bash

for ((i=0;i<100;i++))
do
	echo "De Morgan when converting rcu_lockdep_assert() to WARN_ON_ONCE()"
done

------------------------------------------------------------------------

This does sort of defeat the purpose of writing something 100 times, but 
I am after all a software developer!!!

Thank you very much for catching this, and please see below for a
replacement patch.

							Thanx, Paul


commit 2c9ace45088a25b474167d04b416d279f4ea3401
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
index 4d16983..ae6ae40 100644
--- a/kernel/rcupdate.c
+++ b/kernel/rcupdate.c
@@ -113,6 +113,12 @@ int rcu_my_thread_group_empty(void)
 	return thread_group_empty(current);
 }
 EXPORT_SYMBOL_GPL(rcu_my_thread_group_empty);
+
+void rcu_read_unlock_bh_irqsoff_check(void)
+{
+	WARN_ON_ONCE(!in_irq() && !irqs_disabled());
+}
+EXPORT_SYMBOL_GPL(rcu_read_unlock_bh_irqsoff_check);
 #endif /* #ifdef CONFIG_PROVE_RCU */
 
 #ifdef CONFIG_DEBUG_OBJECTS_RCU_HEAD
