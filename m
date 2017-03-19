From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 3/4] flowcache: make struct
 flow_cache_percpu::hash_rnd_recalc bool
Date: Mon, 20 Mar 2017 01:27:43 +0300
Message-ID: <20170319222743.GC17015@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
        netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:35706 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752177AbdCSW1s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Mar 2017 18:27:48 -0400
Received: by mail-lf0-f67.google.com with SMTP id v2so8835439lfi.2
        for <netdev@vger.kernel.org>; Sun, 19 Mar 2017 15:27:47 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

->hash_rnd_recalc is only used in boolean context.

Space savings on x86_64 come from the fact that "MOV rm8, imm8" is
shorter than "MOV rm32, imm32" by at least 3 bytes.

	add/remove: 0/0 grow/shrink: 0/3 up/down: 0/-10 (-10)
	function                                     old     new   delta
	flow_cache_new_hashrnd                       166     163      -3
	flow_cache_cpu_up_prep                       171     168      -3
	flow_cache_lookup                           1148    1144      -4
	Total: Before=170822872, After=170822862, chg -0.00%

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/flowcache.h |    2 +-
 net/core/flow.c         |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

--- a/include/net/flowcache.h
+++ b/include/net/flowcache.h
@@ -10,7 +10,7 @@ struct flow_cache_percpu {
 	struct hlist_head		*hash_table;
 	int				hash_count;
 	u32				hash_rnd;
-	int				hash_rnd_recalc;
+	bool				hash_rnd_recalc;
 	struct tasklet_struct		flush_tasklet;
 };
 
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -56,7 +56,7 @@ static void flow_cache_new_hashrnd(unsigned long arg)
 	int i;
 
 	for_each_possible_cpu(i)
-		per_cpu_ptr(fc->percpu, i)->hash_rnd_recalc = 1;
+		per_cpu_ptr(fc->percpu, i)->hash_rnd_recalc = true;
 
 	fc->rnd_timer.expires = jiffies + FLOW_HASH_RND_PERIOD;
 	add_timer(&fc->rnd_timer);
@@ -155,7 +155,7 @@ static void flow_new_hash_rnd(struct flow_cache *fc,
 			      struct flow_cache_percpu *fcp)
 {
 	get_random_bytes(&fcp->hash_rnd, sizeof(u32));
-	fcp->hash_rnd_recalc = 0;
+	fcp->hash_rnd_recalc = false;
 	__flow_cache_shrink(fc, fcp, 0);
 }
 
@@ -412,7 +412,7 @@ static int flow_cache_cpu_prepare(struct flow_cache *fc, int cpu)
 			pr_err("NET: failed to allocate flow cache sz %u\n", sz);
 			return -ENOMEM;
 		}
-		fcp->hash_rnd_recalc = 1;
+		fcp->hash_rnd_recalc = true;
 		fcp->hash_count = 0;
 		tasklet_init(&fcp->flush_tasklet, flow_cache_flush_tasklet, 0);
 	}
