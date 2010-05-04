From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: __alloc_skb() speedup
Date: Tue, 04 May 2010 19:10:54 +0200
Message-ID: <1272993054.2245.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f217.google.com ([209.85.218.217]:55963 "EHLO
	mail-bw0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760018Ab0EDRLH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 13:11:07 -0400
Received: by bwz9 with SMTP id 9so2365773bwz.29
        for <netdev@vger.kernel.org>; Tue, 04 May 2010 10:10:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With following patch I can reach maximum rate of my pktgen+udpsink
simulator :
- 'old' machine : dual quad core E5450  @3.00GHz
- 64 UDP rx flows (only differ by destination port)
- RPS enabled, NIC interrupts serviced on cpu0
- rps dispatched on 7 other cores. (~130.000 IPI per second)
- SLAB allocator (faster than SLUB in this workload)
- tg3 NIC
- 1.080.000 pps without a single drop at NIC level.

Idea is to add two prefetchw() calls in __alloc_skb(), one to prefetch
first sk_buff cache line, the second to prefetch the shinfo part.

Also using one memset() to initialize all skb_shared_info fields instead
of one by one to reduce number of instructions, using long word moves.

All skb_shared_info fields before 'dataref' are cleared in 
__alloc_skb().

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/skbuff.h |    7 ++++++-
 net/core/skbuff.c      |   21 +++++----------------
 2 files changed, 11 insertions(+), 17 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 746a652..f32ccc9 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -187,7 +187,6 @@ union skb_shared_tx {
  * the end of the header data, ie. at skb->end.
  */
 struct skb_shared_info {
-	atomic_t	dataref;
 	unsigned short	nr_frags;
 	unsigned short	gso_size;
 	/* Warning: this field is not always filled in (UFO)! */
@@ -197,6 +196,12 @@ struct skb_shared_info {
 	union skb_shared_tx tx_flags;
 	struct sk_buff	*frag_list;
 	struct skb_shared_hwtstamps hwtstamps;
+
+	/*
+	 * Warning : all fields before dataref are cleared in __alloc_skb()
+	 */
+	atomic_t	dataref;
+	
 	skb_frag_t	frags[MAX_SKB_FRAGS];
 	/* Intermediate layers must ensure that destructor_arg
 	 * remains valid until skb destructor */
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 8b9c109..a9b0e1f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -181,12 +181,14 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	skb = kmem_cache_alloc_node(cache, gfp_mask & ~__GFP_DMA, node);
 	if (!skb)
 		goto out;
+	prefetchw(skb);
 
 	size = SKB_DATA_ALIGN(size);
 	data = kmalloc_node_track_caller(size + sizeof(struct skb_shared_info),
 			gfp_mask, node);
 	if (!data)
 		goto nodata;
+	prefetchw(data + size);
 
 	/*
 	 * Only clear those fields we need to clear, not those that we will
@@ -208,15 +210,8 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 
 	/* make sure we initialize shinfo sequentially */
 	shinfo = skb_shinfo(skb);
+	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
 	atomic_set(&shinfo->dataref, 1);
-	shinfo->nr_frags  = 0;
-	shinfo->gso_size = 0;
-	shinfo->gso_segs = 0;
-	shinfo->gso_type = 0;
-	shinfo->ip6_frag_id = 0;
-	shinfo->tx_flags.flags = 0;
-	skb_frag_list_init(skb);
-	memset(&shinfo->hwtstamps, 0, sizeof(shinfo->hwtstamps));
 
 	if (fclone) {
 		struct sk_buff *child = skb + 1;
@@ -505,16 +500,10 @@ int skb_recycle_check(struct sk_buff *skb, int skb_size)
 		return 0;
 
 	skb_release_head_state(skb);
+
 	shinfo = skb_shinfo(skb);
+	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
 	atomic_set(&shinfo->dataref, 1);
-	shinfo->nr_frags = 0;
-	shinfo->gso_size = 0;
-	shinfo->gso_segs = 0;
-	shinfo->gso_type = 0;
-	shinfo->ip6_frag_id = 0;
-	shinfo->tx_flags.flags = 0;
-	skb_frag_list_init(skb);
-	memset(&shinfo->hwtstamps, 0, sizeof(shinfo->hwtstamps));
 
 	memset(skb, 0, offsetof(struct sk_buff, tail));
 	skb->data = skb->head + NET_SKB_PAD;


