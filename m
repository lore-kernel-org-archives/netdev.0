From: Ingo Molnar <mingo@elte.hu>
Subject: [patch] locking, percpu counters: introduce separate lock classes
Date: Mon, 29 Dec 2008 13:44:44 +0100
Message-ID: <20081229124444.GA20306@elte.hu>
References: <EA929A9653AAE14F841771FB1DE5A1365F56B664A3@rrsmsx501.amr.corp.intel.com> <1230544927.16718.12.camel@twins> <20081229103154.GA9691@gondor.apana.org.au> <20081229103735.GA9763@gondor.apana.org.au> <20081229112858.GA16385@elte.hu> <20081229114907.GA10170@gondor.apana.org.au> <20081229115827.GA441@elte.hu> <20081229120132.GA10363@gondor.apana.org.au> <20081229121626.GF9628@elte.hu> <20081229123819.GA18321@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:55715 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752855AbYL2MpE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Dec 2008 07:45:04 -0500
Content-Disposition: inline
In-Reply-To: <20081229123819.GA18321@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> hm, even with the revert i got the splat below. So some other commits 
> are causing this too?

in any case, i picked up and tidied up Peter's annotation patch - see it 
below. Chances are that this plus the revert will do the trick - and 
that's what i'm testing now in tip/master.

	Ingo

------------------------>
>From ea319518ba3de282c13ae1cf4bf2215c5e03e67e Mon Sep 17 00:00:00 2001
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Fri, 26 Dec 2008 15:08:55 +0100
Subject: [PATCH] locking, percpu counters: introduce separate lock classes

Impact: fix lockdep false positives

Classify percpu_counter instances similar to regular lock objects --
that is, per instantiation site.

The networking code has increased its use of percpu_counters, which
leads to false positives if they are treated as a single class.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 include/linux/percpu_counter.h |   14 ++++++++++----
 lib/percpu_counter.c           |   18 ++++--------------
 lib/proportions.c              |    6 +++---
 mm/backing-dev.c               |    2 +-
 4 files changed, 18 insertions(+), 22 deletions(-)

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

