From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 6/13] bridge: Add core IGMP snooping support
Date: Wed, 10 Mar 2010 05:19:46 -0800
Message-ID: <20100310131946.GB6267@linux.vnet.ibm.com>
References: <20100228054012.GA7583@gondor.apana.org.au> <201003092212.59627.arnd@arndb.de> <20100310021410.GD6203@linux.vnet.ibm.com> <201003101041.32518.arnd@arndb.de>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:51523 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756444Ab0CJNTs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Mar 2010 08:19:48 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e2.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o2AD9IcG016011
	for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 08:09:18 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2ADJlwh156868
	for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 08:19:47 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2ADJkgb032250
	for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 08:19:47 -0500
Content-Disposition: inline
In-Reply-To: <201003101041.32518.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 10, 2010 at 10:41:32AM +0100, Arnd Bergmann wrote:
> On Wednesday 10 March 2010 03:14:10 Paul E. McKenney wrote:
> > On Tue, Mar 09, 2010 at 10:12:59PM +0100, Arnd Bergmann wrote:
> >
> > > I've just tried annotating net/ipv4/route.c like this and did not get
> > > very far, because the same pointers are used for rcu and rcu_bh.
> > > Could you check if this is a false positive or an actual finding?
> > 
> > Hmmm...  I am only seeing a call_rcu_bh() here, so unless I am missing
> > something, this is a real problem in TREE_PREEMPT_RCU kernels.  The
> > call_rcu_bh() only interacts with the rcu_read_lock_bh() readers, not
> > the rcu_read_lock() readers.
> > 
> > One approach is to run freed blocks through both types of grace periods,
> > I suppose.
> 
> Well, if I introduce different __rcu and __rcu_bh address space annotations,
> sparse would still not like that, because then you can only pass the annotated
> pointers into either rcu_dereference or rcu_dereference_bh.
> 
> What the code seems to be doing here is in some places
> 
> 	local_bh_disable();
> 	...
> 	rcu_read_lock();
> 	rcu_dereference(rt_hash_table[h].chain);
> 	rcu_read_unlock();
> 	...
> 	local_bh_enable();
> 
> and in others
> 
> 	rcu_read_lock_bh();
> 	rcu_dereference_bh(rt_hash_table[h].chain);
> 	rcu_read_unlock_bh();

Hmmm...  This is actually legal.

> When rt_hash_table[h].chain gets the __rcu_bh annotation, we'd have to
> turn first rcu_dereference into rcu_dereference_bh in order to have a clean
> build with sparse. Would that change be
> a) correct from RCU perspective,
> b) desirable for code inspection, and
> c) lockdep-clean?

I have a patch queued up that will make rcu_dereference_bh() handle this
correctly -- current -tip and mainline would complain.  Please see below
for a sneak preview.

Thoughts?

							Thanx, Paul

rcu: make rcu_read_lock_bh_held() allow for disabled BH

Disabling BH can stand in for rcu_read_lock_bh(), and this patch updates
rcu_read_lock_bh_held() to allow for this.  In order to avoid
include-file hell, this function is moved out of line to kernel/rcupdate.c.

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
---

include/linux/rcupdate.h |   19 ++++---------------
 kernel/rcupdate.c        |   22 ++++++++++++++++++++++
 2 files changed, 26 insertions(+), 15 deletions(-)

diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
index 75921b8..c393acc 100644
--- a/include/linux/rcupdate.h
+++ b/include/linux/rcupdate.h
@@ -119,22 +119,11 @@ static inline int rcu_read_lock_held(void)
 	return lock_is_held(&rcu_lock_map);
 }
 
-/**
- * rcu_read_lock_bh_held - might we be in RCU-bh read-side critical section?
- *
- * If CONFIG_PROVE_LOCKING is selected and enabled, returns nonzero iff in
- * an RCU-bh read-side critical section.  In absence of CONFIG_PROVE_LOCKING,
- * this assumes we are in an RCU-bh read-side critical section unless it can
- * prove otherwise.
- *
- * Check rcu_scheduler_active to prevent false positives during boot.
+/*
+ * rcu_read_lock_bh_held() is defined out of line to avoid #include-file
+ * hell.
  */
-static inline int rcu_read_lock_bh_held(void)
-{
-	if (!debug_lockdep_rcu_enabled())
-		return 1;
-	return lock_is_held(&rcu_bh_lock_map);
-}
+extern int rcu_read_lock_bh_held(void);
 
 /**
  * rcu_read_lock_sched_held - might we be in RCU-sched read-side critical section?
diff --git a/kernel/rcupdate.c b/kernel/rcupdate.c
index f1125c1..913eccb 100644
--- a/kernel/rcupdate.c
+++ b/kernel/rcupdate.c
@@ -45,6 +45,7 @@
 #include <linux/mutex.h>
 #include <linux/module.h>
 #include <linux/kernel_stat.h>
+#include <linux/hardirq.h>
 
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
 static struct lock_class_key rcu_lock_key;
@@ -66,6 +67,27 @@ EXPORT_SYMBOL_GPL(rcu_sched_lock_map);
 int rcu_scheduler_active __read_mostly;
 EXPORT_SYMBOL_GPL(rcu_scheduler_active);
 
+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+
+/**
+ * rcu_read_lock_bh_held - might we be in RCU-bh read-side critical section?
+ *
+ * Check for bottom half being disabled, which covers both the
+ * CONFIG_PROVE_RCU and not cases.  Note that if someone uses
+ * rcu_read_lock_bh(), but then later enables BH, lockdep (if enabled)
+ * will show the situation.
+ *
+ * Check debug_lockdep_rcu_enabled() to prevent false positives during boot.
+ */
+int rcu_read_lock_bh_held(void)
+{
+	if (!debug_lockdep_rcu_enabled())
+		return 1;
+	return in_softirq();
+}
+
+#endif /* #ifdef CONFIG_DEBUG_LOCK_ALLOC */
+
 /*
  * This function is invoked towards the end of the scheduler's initialization
  * process.  Before this is called, the idle task might contain
