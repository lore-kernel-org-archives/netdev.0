From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH,RFC] generic skb recycling
Date: Wed, 6 May 2009 16:12:43 +0200
Message-ID: <20090506141243.GK24429@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: afleming@freescale.com, bkostya@marvell.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:52129 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756948AbZEFOF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 10:05:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This RFC patch removes the skb recycling that was added to mv643xx_eth
a while ago and moves it into the stack, based on an earlier idea by
Kostya Belezko <bkostya@marvell.com>.  There's a couple of reasons for
doing this:

- Make skb recycling available to all drivers, without needing driver
  modifications.

- Allow recycling skbuffs in more cases, by having the recycle check
  in __kfree_skb() instead of in the ethernet driver transmit
  completion routine.  This also allows for example recycling locally
  destined skbuffs, instead of only recycling forwarded skbuffs as
  the transmit completion-time check does.

- Allow more consumers of skbuffs in the system use recycled skbuffs,
  and not just the rx refill process in the driver.

- Having a per-interface recycle list doesn't allow skb recycling when
  you're e.g. unidirectionally routing from eth0 to eth1, as eth1 will
  be producing a lot of recycled skbuffs but eth0 won't have any skbuffs
  to allocate from its recycle list.


Generic skb recycling is slightly slower than doing it in the driver,
e.g. in the case of mv643xx_eth about 70 cycles per packet.  Given the
benefits I think that's an OK price to pay.


Open items:

- I tried putting the recycle list in the per-CPU softnet state, but
  the skb allocator is initialised before the softnet state is, and I
  ended up with ugly tests in __{alloc,kfree}_skb() to check whether
  softnet init is done yet.  (Maybe softnet state can be initialised
  earlier?)

- I picked SKB_DATA_ALIGN(ETH_FRAME_LEN + SMP_CACHE_BYTES) as the skb
  size threshold for skb recycling, as with NET_SKB_PAD padding included
  that's what I suppose most non-frag RX drivers will end up allocating
  for their receive ring (which is the main source for recycled skbuffs).
  I haven't yet measured the effect on frag RX with LRO/GRO to see if
  there's a benefit in recycling there as well.

- Determine a sensible value for the recycle queue length.  For
  in-driver recycling, I chose the rx queue length, as we'll never
  allocate more than that in one go, but here it's a bit less clear
  what a good value would be.


Thoughts?


diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index d583852..738b5c3 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -403,7 +403,6 @@ struct mv643xx_eth_private {
 	u8 work_rx_refill;
 
 	int skb_size;
-	struct sk_buff_head rx_recycle;
 
 	/*
 	 * RX state.
@@ -656,10 +655,7 @@ static int rxq_refill(struct rx_queue *rxq, int budget)
 		int rx;
 		struct rx_desc *rx_desc;
 
-		skb = __skb_dequeue(&mp->rx_recycle);
-		if (skb == NULL)
-			skb = dev_alloc_skb(mp->skb_size);
-
+		skb = dev_alloc_skb(mp->skb_size);
 		if (skb == NULL) {
 			mp->oom = 1;
 			goto oom;
@@ -962,14 +958,8 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 				       desc->byte_cnt, DMA_TO_DEVICE);
 		}
 
-		if (skb != NULL) {
-			if (skb_queue_len(&mp->rx_recycle) <
-					mp->rx_ring_size &&
-			    skb_recycle_check(skb, mp->skb_size))
-				__skb_queue_head(&mp->rx_recycle, skb);
-			else
-				dev_kfree_skb(skb);
-		}
+		if (skb != NULL)
+			dev_kfree_skb(skb);
 	}
 
 	__netif_tx_unlock(nq);
@@ -2368,8 +2358,6 @@ static int mv643xx_eth_open(struct net_device *dev)
 
 	napi_enable(&mp->napi);
 
-	skb_queue_head_init(&mp->rx_recycle);
-
 	mp->int_mask = INT_EXT;
 
 	for (i = 0; i < mp->rxq_count; i++) {
@@ -2464,8 +2452,6 @@ static int mv643xx_eth_stop(struct net_device *dev)
 	mib_counters_update(mp);
 	del_timer_sync(&mp->mib_counters_timer);
 
-	skb_queue_purge(&mp->rx_recycle);
-
 	for (i = 0; i < mp->rxq_count; i++)
 		rxq_deinit(mp->rxq + i);
 	for (i = 0; i < mp->txq_count; i++)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d152394..c9c111f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -56,6 +56,7 @@
 #include <linux/init.h>
 #include <linux/scatterlist.h>
 #include <linux/errqueue.h>
+#include <linux/cpu.h>
 
 #include <net/protocol.h>
 #include <net/dst.h>
@@ -71,6 +72,9 @@
 
 static struct kmem_cache *skbuff_head_cache __read_mostly;
 static struct kmem_cache *skbuff_fclone_cache __read_mostly;
+static DEFINE_PER_CPU(struct sk_buff_head, skbuff_recycle_list);
+
+#define SKB_MIN_RECYCLE_SIZE	SKB_DATA_ALIGN(ETH_FRAME_LEN + SMP_CACHE_BYTES)
 
 static void sock_pipe_buf_release(struct pipe_inode_info *pipe,
 				  struct pipe_buffer *buf)
@@ -176,6 +180,14 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	struct sk_buff *skb;
 	u8 *data;
 
+	if (size <= SKB_MIN_RECYCLE_SIZE && !fclone) {
+		struct sk_buff_head *h = &__get_cpu_var(skbuff_recycle_list);
+
+		skb = skb_dequeue(h);
+		if (skb != NULL)
+			return skb;
+	}
+
 	cache = fclone ? skbuff_fclone_cache : skbuff_head_cache;
 
 	/* Get the HEAD */
@@ -423,7 +435,37 @@ static void skb_release_all(struct sk_buff *skb)
 
 void __kfree_skb(struct sk_buff *skb)
 {
-	skb_release_all(skb);
+	struct sk_buff_head *h = &__get_cpu_var(skbuff_recycle_list);
+
+	skb_release_head_state(skb);
+
+	if (skb_queue_len(h) < 256 &&
+	    !skb_cloned(skb) && !skb_is_nonlinear(skb) &&
+	    skb->fclone == SKB_FCLONE_UNAVAILABLE &&
+	    skb_end_pointer(skb) - skb->head >= SKB_MIN_RECYCLE_SIZE) {
+		struct skb_shared_info *shinfo;
+
+		shinfo = skb_shinfo(skb);
+		atomic_set(&shinfo->dataref, 1);
+		shinfo->nr_frags = 0;
+		shinfo->gso_size = 0;
+		shinfo->gso_segs = 0;
+		shinfo->gso_type = 0;
+		shinfo->ip6_frag_id = 0;
+		shinfo->tx_flags.flags = 0;
+		shinfo->frag_list = NULL;
+		memset(&shinfo->hwtstamps, 0, sizeof(shinfo->hwtstamps));
+
+		memset(skb, 0, offsetof(struct sk_buff, tail));
+		skb->data = skb->head;
+		skb_reset_tail_pointer(skb);
+
+		skb_queue_head(h, skb);
+
+		return;
+	}
+
+	skb_release_data(skb);
 	kfree_skbmem(skb);
 }
 EXPORT_SYMBOL(__kfree_skb);
@@ -2756,8 +2798,24 @@ done:
 }
 EXPORT_SYMBOL_GPL(skb_gro_receive);
 
+static int
+skb_cpu_callback(struct notifier_block *nfb,
+		 unsigned long action, void *ocpu)
+{
+	unsigned long oldcpu = (unsigned long)ocpu;
+
+	if (action == CPU_DEAD || action == CPU_DEAD_FROZEN) {
+		struct sk_buff_head *h = &per_cpu(skbuff_recycle_list, oldcpu);
+		skb_queue_purge(h);
+	}
+
+	return NOTIFY_OK;
+}
+
 void __init skb_init(void)
 {
+	int i;
+
 	skbuff_head_cache = kmem_cache_create("skbuff_head_cache",
 					      sizeof(struct sk_buff),
 					      0,
@@ -2769,6 +2827,13 @@ void __init skb_init(void)
 						0,
 						SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 						NULL);
+
+	for_each_possible_cpu(i) {
+		struct sk_buff_head *h = &per_cpu(skbuff_recycle_list, i);
+		skb_queue_head_init(h);
+	}
+
+	hotcpu_notifier(skb_cpu_callback, 0);
 }
 
 /**
-- 
1.5.6.4
