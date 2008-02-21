From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] alloc_percpu() fails to allocate percpu data
Date: Thu, 21 Feb 2008 19:00:03 +0100
Message-ID: <47BDBC23.10605@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090507080405000509050906"
Cc: linux kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Christoph Lameter <clameter@sgi.com>,
	"Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
To: "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758853AbYBUSAe@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090507080405000509050906
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Some oprofile results obtained while using tbench on a 2x2 cpu machine 
were very surprising.

For example, loopback_xmit() function was using high number of cpu 
cycles to perform
the statistic updates, supposed to be real cheap since they use percpu data

        pcpu_lstats = netdev_priv(dev);
        lb_stats = per_cpu_ptr(pcpu_lstats, smp_processor_id());
        lb_stats->packets++;  /* HERE : serious contention */
        lb_stats->bytes += skb->len;


struct pcpu_lstats is a small structure containing two longs. It appears 
that on my 32bits platform,
alloc_percpu(8) allocates a single cache line,  instead of giving to 
each cpu a separate
cache line.

Using the following patch gave me impressive boost in various benchmarks 
( 6 % in tbench)
(all percpu_counters hit this bug too)

Long term fix (ie >= 2.6.26) would be to let each CPU allocate their own 
block of memory, so that we
dont need to roudup sizes to L1_CACHE_BYTES, or merging the SGI stuff of 
course...

Note : SLUB vs SLAB is important here to *show* the improvement, since 
they dont have the same minimum
allocation sizes (8 bytes vs 32 bytes).
This could very well explain regressions some guys reported when they 
switched to SLUB.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

 mm/allocpercpu.c |   15 ++++++++++++++-
 1 files changed, 14 insertions(+), 1 deletion(-)



--------------090507080405000509050906
Content-Type: text/plain;
 name="percpu_populate.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="percpu_populate.patch"

diff --git a/mm/allocpercpu.c b/mm/allocpercpu.c
index 7e58322..b0012e2 100644
--- a/mm/allocpercpu.c
+++ b/mm/allocpercpu.c
@@ -6,6 +6,10 @@
 #include <linux/mm.h>
 #include <linux/module.h>
 
+#ifndef cache_line_size
+#define cache_line_size()	L1_CACHE_BYTES
+#endif
+
 /**
  * percpu_depopulate - depopulate per-cpu data for given cpu
  * @__pdata: per-cpu data to depopulate
@@ -52,6 +56,11 @@ void *percpu_populate(void *__pdata, size_t size, gfp_t gfp, int cpu)
 	struct percpu_data *pdata = __percpu_disguise(__pdata);
 	int node = cpu_to_node(cpu);
 
+	/*
+	 * We should make sure each CPU gets private memory.
+	 */
+	size = roundup(size, cache_line_size());
+
 	BUG_ON(pdata->ptrs[cpu]);
 	if (node_online(node))
 		pdata->ptrs[cpu] = kmalloc_node(size, gfp|__GFP_ZERO, node);
@@ -98,7 +107,11 @@ EXPORT_SYMBOL_GPL(__percpu_populate_mask);
  */
 void *__percpu_alloc_mask(size_t size, gfp_t gfp, cpumask_t *mask)
 {
-	void *pdata = kzalloc(nr_cpu_ids * sizeof(void *), gfp);
+	/*
+	 * We allocate whole cache lines to avoid false sharing
+	 */
+	size_t sz = roundup(nr_cpu_ids * sizeof(void *), cache_line_size());
+	void *pdata = kzalloc(sz, gfp);
 	void *__pdata = __percpu_disguise(pdata);
 
 	if (unlikely(!pdata))

--------------090507080405000509050906--
