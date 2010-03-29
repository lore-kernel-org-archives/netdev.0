From: Timo Teras <timo.teras@iki.fi>
Subject: [PATCH 3/7] flow: allocate hash table for online cpus only
Date: Mon, 29 Mar 2010 17:12:40 +0300
Message-ID: <1269871964-5412-4-git-send-email-timo.teras@iki.fi>
References: <1269871964-5412-1-git-send-email-timo.teras@iki.fi>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Timo Teras <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:39800 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752742Ab0C2ONA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 10:13:00 -0400
Received: by mail-ew0-f220.google.com with SMTP id 20so705352ewy.1
        for <netdev@vger.kernel.org>; Mon, 29 Mar 2010 07:12:59 -0700 (PDT)
In-Reply-To: <1269871964-5412-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of unconditionally allocating hash table for all possible
cpu's, allocate it only for online cpu's and release related
memory if cpu goes down.

Signed-off-by: Timo Teras <timo.teras@iki.fi>
---
 net/core/flow.c |   43 ++++++++++++++++++++++++++++++-------------
 1 files changed, 30 insertions(+), 13 deletions(-)

diff --git a/net/core/flow.c b/net/core/flow.c
index 1d27ca6..104078d 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -309,36 +309,49 @@ void flow_cache_flush(void)
 	put_online_cpus();
 }
 
-static void __init flow_cache_cpu_prepare(struct flow_cache *fc,
-					  struct flow_cache_percpu *fcp)
+static void __cpuinit flow_cache_cpu_prepare(struct flow_cache *fc,
+					     struct flow_cache_percpu *fcp)
 {
 	fcp->hash_table = (struct flow_cache_entry **)
 		__get_free_pages(GFP_KERNEL|__GFP_ZERO, fc->order);
-	if (!fcp->hash_table)
-		panic("NET: failed to allocate flow cache order %lu\n", fc->order);
-
 	fcp->hash_rnd_recalc = 1;
 	fcp->hash_count = 0;
 	tasklet_init(&fcp->flush_tasklet, flow_cache_flush_tasklet, 0);
 }
 
-static int flow_cache_cpu(struct notifier_block *nfb,
-			  unsigned long action,
-			  void *hcpu)
+static int __cpuinit flow_cache_cpu(struct notifier_block *nfb,
+				    unsigned long action,
+				    void *hcpu)
 {
 	struct flow_cache *fc = container_of(nfb, struct flow_cache, hotcpu_notifier);
 	int cpu = (unsigned long) hcpu;
 	struct flow_cache_percpu *fcp = per_cpu_ptr(fc->percpu, cpu);
 
-	if (action == CPU_DEAD || action == CPU_DEAD_FROZEN)
-		__flow_cache_shrink(fc, fcp, 0);
+	switch (action) {
+	case CPU_UP_PREPARE:
+	case CPU_UP_PREPARE_FROZEN:
+		flow_cache_cpu_prepare(fc, fcp);
+		if (!fcp->hash_table)
+			return NOTIFY_BAD;
+		break;
+	case CPU_UP_CANCELED:
+	case CPU_UP_CANCELED_FROZEN:
+	case CPU_DEAD:
+	case CPU_DEAD_FROZEN:
+		if (fcp->hash_table) {
+			__flow_cache_shrink(fc, fcp, 0);
+			free_pages((unsigned long) fcp->hash_table, fc->order);
+			fcp->hash_table = NULL;
+		}
+		break;
+	}
 	return NOTIFY_OK;
 }
 
 static int flow_cache_init(struct flow_cache *fc)
 {
 	unsigned long order;
-	int i;
+	int i, r;
 
 	fc->hash_shift = 10;
 	fc->low_watermark = 2 * flow_cache_hash_size(fc);
@@ -357,8 +370,12 @@ static int flow_cache_init(struct flow_cache *fc)
 	fc->rnd_timer.expires = jiffies + FLOW_HASH_RND_PERIOD;
 	add_timer(&fc->rnd_timer);
 
-	for_each_possible_cpu(i)
-		flow_cache_cpu_prepare(fc, per_cpu_ptr(fc->percpu, i));
+	for_each_online_cpu(i) {
+		r = flow_cache_cpu(&fc->hotcpu_notifier,
+				   CPU_UP_PREPARE, (void*) i);
+		if (r != NOTIFY_OK)
+			panic("NET: failed to allocate flow cache order %lu\n", order);
+	}
 
 	fc->hotcpu_notifier = (struct notifier_block){
 		.notifier_call = flow_cache_cpu,
-- 
1.6.3.3

