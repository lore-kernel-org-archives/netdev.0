From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [BUG] INFO: inconsistent lock state
Date: Wed, 07 Jan 2009 23:13:50 +1100
Message-ID: <E1LKXIE-0006dE-Lq@gondolin.me.apana.org.au>
References: <4962C322.8000201@cn.fujitsu.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: lizf@cn.fujitsu.com (Li Zefan)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33645 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750883AbZAGMN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 07:13:59 -0500
In-Reply-To: <4962C322.8000201@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Li Zefan <lizf@cn.fujitsu.com> wrote:
> I am using Linus' tree, and the top commit is:
> 
> commit fe0bdec68b77020281dc814805edfe594ae89e0f
> Merge: 099e657... 5af75d8...
> Author: Linus Torvalds <torvalds@linux-foundation.org>
> Date:   Sun Jan 4 16:32:11 2009 -0800
> 
>    Merge branch 'audit.b61' of git://git.kernel.org/pub/scm/linux/kernel/git/viro/audit-current
> 
> don't know how I triggered this, and not sure whom to CC, network related?

You need

commit ea319518ba3de282c13ae1cf4bf2215c5e03e67e
Author: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date:   Fri Dec 26 15:08:55 2008 +0100

    locking, percpu counters: introduce separate lock classes
    
    Impact: fix lockdep false positives
    
    Classify percpu_counter instances similar to regular lock objects --
    that is, per instantiation site.
    
    The networking code has increased its use of percpu_counters, which
    leads to false positives if they are treated as a single class.
    
    Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/include/linux/percpu_counter.h b/include/linux/percpu_counter.h
index 9007ccd..96bdde3 100644
--- a/include/linux/percpu_counter.h
+++ b/include/linux/percpu_counter.h
@@ -30,8 +30,16 @@ struct percpu_counter {
 #define FBC_BATCH	(NR_CPUS*4)
 #endif
 
-int percpu_counter_init(struct percpu_counter *fbc, s64 amount);
-int percpu_counter_init_irq(struct percpu_counter *fbc, s64 amount);
+int __percpu_counter_init(struct percpu_counter *fbc, s64 amount,
+			  struct lock_class_key *key);
+
+#define percpu_counter_init(fbc, value)					\
+	({								\
+		static struct lock_class_key __key;			\
+									\
+		__percpu_counter_init(fbc, value, &__key);		\
+	})
+
 void percpu_counter_destroy(struct percpu_counter *fbc);
 void percpu_counter_set(struct percpu_counter *fbc, s64 amount);
 void __percpu_counter_add(struct percpu_counter *fbc, s64 amount, s32 batch);
@@ -85,8 +93,6 @@ static inline int percpu_counter_init(struct percpu_counter *fbc, s64 amount)
 	return 0;
 }
 
-#define percpu_counter_init_irq percpu_counter_init
-
 static inline void percpu_counter_destroy(struct percpu_counter *fbc)
 {
 }
diff --git a/lib/percpu_counter.c b/lib/percpu_counter.c
index a866389..c7fe2e4 100644
--- a/lib/percpu_counter.c
+++ b/lib/percpu_counter.c
@@ -71,11 +71,11 @@ s64 __percpu_counter_sum(struct percpu_counter *fbc)
 }
 EXPORT_SYMBOL(__percpu_counter_sum);
 
-static struct lock_class_key percpu_counter_irqsafe;
-
-int percpu_counter_init(struct percpu_counter *fbc, s64 amount)
+int __percpu_counter_init(struct percpu_counter *fbc, s64 amount,
+			  struct lock_class_key *key)
 {
 	spin_lock_init(&fbc->lock);
+	lockdep_set_class(&fbc->lock, key);
 	fbc->count = amount;
 	fbc->counters = alloc_percpu(s32);
 	if (!fbc->counters)
@@ -87,17 +87,7 @@ int percpu_counter_init(struct percpu_counter *fbc, s64 amount)
 #endif
 	return 0;
 }
-EXPORT_SYMBOL(percpu_counter_init);
-
-int percpu_counter_init_irq(struct percpu_counter *fbc, s64 amount)
-{
-	int err;
-
-	err = percpu_counter_init(fbc, amount);
-	if (!err)
-		lockdep_set_class(&fbc->lock, &percpu_counter_irqsafe);
-	return err;
-}
+EXPORT_SYMBOL(__percpu_counter_init);
 
 void percpu_counter_destroy(struct percpu_counter *fbc)
 {
diff --git a/lib/proportions.c b/lib/proportions.c
index 4f387a6..7367f2b 100644
--- a/lib/proportions.c
+++ b/lib/proportions.c
@@ -83,11 +83,11 @@ int prop_descriptor_init(struct prop_descriptor *pd, int shift)
 	pd->index = 0;
 	pd->pg[0].shift = shift;
 	mutex_init(&pd->mutex);
-	err = percpu_counter_init_irq(&pd->pg[0].events, 0);
+	err = percpu_counter_init(&pd->pg[0].events, 0);
 	if (err)
 		goto out;
 
-	err = percpu_counter_init_irq(&pd->pg[1].events, 0);
+	err = percpu_counter_init(&pd->pg[1].events, 0);
 	if (err)
 		percpu_counter_destroy(&pd->pg[0].events);
 
@@ -191,7 +191,7 @@ int prop_local_init_percpu(struct prop_local_percpu *pl)
 	spin_lock_init(&pl->lock);
 	pl->shift = 0;
 	pl->period = 0;
-	return percpu_counter_init_irq(&pl->events, 0);
+	return percpu_counter_init(&pl->events, 0);
 }
 
 void prop_local_destroy_percpu(struct prop_local_percpu *pl)
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index f2e574d..f3b1258 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -220,7 +220,7 @@ int bdi_init(struct backing_dev_info *bdi)
 	bdi->max_prop_frac = PROP_FRAC_BASE;
 
 	for (i = 0; i < NR_BDI_STAT_ITEMS; i++) {
-		err = percpu_counter_init_irq(&bdi->bdi_stat[i], 0);
+		err = percpu_counter_init(&bdi->bdi_stat[i], 0);
 		if (err)
 			goto err;
 	}

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
