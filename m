From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 2/4] flowcache: make flow_cache_hash_size() return "unsigned
 int"
Date: Mon, 20 Mar 2017 01:24:49 +0300
Message-ID: <20170319222449.GB17015@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
        netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:36850 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752143AbdCSWYy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Mar 2017 18:24:54 -0400
Received: by mail-lf0-f66.google.com with SMTP id g70so8818027lfh.3
        for <netdev@vger.kernel.org>; Sun, 19 Mar 2017 15:24:53 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hash size can't negative so "unsigned int" is logically correct.

Propagate "unsigned int" to loop counters.

Space savings:

	add/remove: 0/0 grow/shrink: 2/2 up/down: 6/-18 (-12)
	function                                     old     new   delta
	flow_cache_flush_tasklet                     362     365      +3
	__flow_cache_shrink                          333     336      +3
	flow_cache_cpu_up_prep                       178     171      -7
	flow_cache_lookup                           1159    1148     -11
	Total: Before=170822884, After=170822872, chg -0.00%

Lookup becomes smaller and this is what matters.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/core/flow.c |   14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -47,7 +47,7 @@ struct flow_flush_info {
 
 static struct kmem_cache *flow_cachep __read_mostly;
 
-#define flow_cache_hash_size(cache)	(1 << (cache)->hash_shift)
+#define flow_cache_hash_size(cache)	(1U << (cache)->hash_shift)
 #define FLOW_HASH_RND_PERIOD		(10 * 60 * HZ)
 
 static void flow_cache_new_hashrnd(unsigned long arg)
@@ -119,9 +119,10 @@ static void __flow_cache_shrink(struct flow_cache *fc,
 	struct flow_cache_entry *fle;
 	struct hlist_node *tmp;
 	LIST_HEAD(gc_list);
-	int i, deleted = 0;
+	int deleted = 0;
 	struct netns_xfrm *xfrm = container_of(fc, struct netns_xfrm,
 						flow_cache_global);
+	unsigned int i;
 
 	for (i = 0; i < flow_cache_hash_size(fc); i++) {
 		int saved = 0;
@@ -295,9 +296,10 @@ static void flow_cache_flush_tasklet(unsigned long data)
 	struct flow_cache_entry *fle;
 	struct hlist_node *tmp;
 	LIST_HEAD(gc_list);
-	int i, deleted = 0;
+	int deleted = 0;
 	struct netns_xfrm *xfrm = container_of(fc, struct netns_xfrm,
 						flow_cache_global);
+	unsigned int i;
 
 	fcp = this_cpu_ptr(fc->percpu);
 	for (i = 0; i < flow_cache_hash_size(fc); i++) {
@@ -327,7 +329,7 @@ static void flow_cache_flush_tasklet(unsigned long data)
 static int flow_cache_percpu_empty(struct flow_cache *fc, int cpu)
 {
 	struct flow_cache_percpu *fcp;
-	int i;
+	unsigned int i;
 
 	fcp = per_cpu_ptr(fc->percpu, cpu);
 	for (i = 0; i < flow_cache_hash_size(fc); i++)
@@ -402,12 +404,12 @@ void flow_cache_flush_deferred(struct net *net)
 static int flow_cache_cpu_prepare(struct flow_cache *fc, int cpu)
 {
 	struct flow_cache_percpu *fcp = per_cpu_ptr(fc->percpu, cpu);
-	size_t sz = sizeof(struct hlist_head) * flow_cache_hash_size(fc);
+	unsigned int sz = sizeof(struct hlist_head) * flow_cache_hash_size(fc);
 
 	if (!fcp->hash_table) {
 		fcp->hash_table = kzalloc_node(sz, GFP_KERNEL, cpu_to_node(cpu));
 		if (!fcp->hash_table) {
-			pr_err("NET: failed to allocate flow cache sz %zu\n", sz);
+			pr_err("NET: failed to allocate flow cache sz %u\n", sz);
 			return -ENOMEM;
 		}
 		fcp->hash_rnd_recalc = 1;
