From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 04/11] net: bulk alloc and reuse of SKBs in NAPI
 context
Date: Tue, 02 Feb 2016 22:12:01 +0100
Message-ID: <20160202211159.16315.58487.stgit@firesoul>
References: <20160202211051.16315.51808.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl@linux.com>, tom@herbertland.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	alexei.starovoitov@gmail.com,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	ogerlitz@mellanox.com, gerlitz.or@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36343 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933063AbcBBVMD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 16:12:03 -0500
In-Reply-To: <20160202211051.16315.51808.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Think twice before applying
 - This patch can potentially introduce added latency in some workloads

This patch introduce bulk alloc of SKBs and allow reuse of SKBs
free'ed in same softirq cycle.  SKBs are normally free'ed during TX
completion, but most high speed drivers also cleanup TX ring during
NAPI RX poll cycle.  Thus, if using napi_consume_skb/__kfree_skb_defer,
SKBs will be avail in the napi_alloc_cache->skb_cache.

If no SKBs are avail for reuse, then only bulk alloc 8 SKBs, to limit
the potential overshooting unused SKBs needed to free'ed when NAPI
cycle ends (flushed in net_rx_action via __kfree_skb_flush()).

Benchmarking IPv4-forwarding, on CPU i7-4790K @4.2GHz (no turbo boost)
(GCC version 5.1.1 20150618 (Red Hat 5.1.1-4))
 Allocator SLUB:
  Single CPU/flow numbers: before: 2064446 pps -> after: 2083031 pps
  Improvement: +18585 pps, -4.3 nanosec, +0.9%
 Allocator SLAB:
  Single CPU/flow numbers: before: 2035949 pps -> after: 2033567 pps
  Regression: -2382 pps, +0.57 nanosec, -0.1 %

Even-though benchmarking does show an improvement for SLUB(+0.9%), I'm
not convinced bulk alloc will be a win in all situations:
 * I see stalls on walking the SLUB freelist (normal hidden by prefetch)
 * In case RX queue is not full, alloc and free more SKBs than needed

More testing is needed with more real life benchmarks.

Joint work with Alexander Duyck.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/core/skbuff.c |   35 +++++++++++++++++++++++++++++++----
 1 file changed, 31 insertions(+), 4 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d278e51789e9..ae8cdbec90ee 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -483,13 +483,14 @@ struct sk_buff *__napi_alloc_skb(struct napi_struct *napi, unsigned int len,
 				 gfp_t gfp_mask)
 {
 	struct napi_alloc_cache *nc = this_cpu_ptr(&napi_alloc_cache);
+	struct skb_shared_info *shinfo;
 	struct sk_buff *skb;
 	void *data;
 
 	len += NET_SKB_PAD + NET_IP_ALIGN;
 
-	if ((len > SKB_WITH_OVERHEAD(PAGE_SIZE)) ||
-	    (gfp_mask & (__GFP_DIRECT_RECLAIM | GFP_DMA))) {
+	if (unlikely((len > SKB_WITH_OVERHEAD(PAGE_SIZE)) ||
+		     (gfp_mask & (__GFP_DIRECT_RECLAIM | GFP_DMA)))) {
 		skb = __alloc_skb(len, gfp_mask, SKB_ALLOC_RX, NUMA_NO_NODE);
 		if (!skb)
 			goto skb_fail;
@@ -506,12 +507,38 @@ struct sk_buff *__napi_alloc_skb(struct napi_struct *napi, unsigned int len,
 	if (unlikely(!data))
 		return NULL;
 
-	skb = __build_skb(data, len);
-	if (unlikely(!skb)) {
+#define BULK_ALLOC_SIZE 8
+	if (!nc->skb_count) {
+		nc->skb_count = kmem_cache_alloc_bulk(skbuff_head_cache,
+						      gfp_mask, BULK_ALLOC_SIZE,
+						      nc->skb_cache);
+	}
+	if (likely(nc->skb_count)) {
+		skb = (struct sk_buff *)nc->skb_cache[--nc->skb_count];
+	} else {
+		/* alloc bulk failed */
 		skb_free_frag(data);
 		return NULL;
 	}
 
+	len -= SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+
+	memset(skb, 0, offsetof(struct sk_buff, tail));
+	skb->truesize = SKB_TRUESIZE(len);
+	atomic_set(&skb->users, 1);
+	skb->head = data;
+	skb->data = data;
+	skb_reset_tail_pointer(skb);
+	skb->end = skb->tail + len;
+	skb->mac_header = (typeof(skb->mac_header))~0U;
+	skb->transport_header = (typeof(skb->transport_header))~0U;
+
+	/* make sure we initialize shinfo sequentially */
+	shinfo = skb_shinfo(skb);
+	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
+	atomic_set(&shinfo->dataref, 1);
+	kmemcheck_annotate_variable(shinfo->destructor_arg);
+
 	/* use OR instead of assignment to avoid clearing of bits in mask */
 	if (nc->page.pfmemalloc)
 		skb->pfmemalloc = 1;
