From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 0/4] skb paged fragment destructors
Date: Tue, 6 Dec 2011 11:57:14 +0000
Message-ID: <1323172634.23681.73.camel@zakaz.uk.xensource.com>
References: <1320850895.955.172.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:49811 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933238Ab1LFL5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 06:57:16 -0500
In-Reply-To: <1320850895.955.172.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-11-09 at 15:01 +0000, Ian Campbell wrote:
>       * split linear data allocation and shinfo allocation into two. I
>         suspect this will have its own performance implications? On the
>         positive side skb_shared_info could come from its own fixed size
>         pool/cache which might have some benefits

I played with this to see how it would look. Illustrative patch below. 

I figure that lots of small frames is the interesting workload for a
change such as this but I don't know if iperf is necessarily the best
benchmark for measuring that.
Before changing things I got:
        iperf -c qarun -m -t 60 -u -b 10000M -l 64
        ------------------------------------------------------------
        Client connecting to qarun, UDP port 5001
        Sending 64 byte datagrams
        UDP buffer size:   224 KByte (default)
        ------------------------------------------------------------
        [  3] local 10.80.225.63 port 45857 connected with 10.80.224.22 port 5001
        [ ID] Interval       Transfer     Bandwidth
        [  3]  0.0-60.0 sec    844 MBytes    118 Mbits/sec
        [  3] Sent 13820376 datagrams
        [  3] Server Report:
        [  3]  0.0-60.0 sec    844 MBytes    118 Mbits/sec  0.005 ms    0/13820375 (0%)
        [  3]  0.0-60.0 sec  1 datagrams received out-of-order
whereas with the patch:
        # iperf -c qarun -m -t 60 -u -b 10000M -l 64
        ------------------------------------------------------------
        Client connecting to qarun, UDP port 5001
        Sending 64 byte datagrams
        UDP buffer size:   224 KByte (default)
        ------------------------------------------------------------
        [  3] local 10.80.225.63 port 42504 connected with 10.80.224.22 port 5001
        [ ID] Interval       Transfer     Bandwidth
        [  3]  0.0-60.0 sec    833 MBytes    116 Mbits/sec
        [  3] Sent 13645857 datagrams
        [  3] Server Report:
        [  3]  0.0-60.0 sec    833 MBytes    116 Mbits/sec  0.005 ms    0/13645856 (0%)
        [  3]  0.0-60.0 sec  1 datagrams received out-of-order

With 1200 byte datagrams I get basically identical throughput.

(nb: none of the skb destructor stuff was present in either case)

>       * steal a bit a pointer to indicate destructor pointer vs regular
>         struct page pointer (moving the struct page into the destructor
>         datastructure for that case). Stops us sharing a single
>         destructor between multiple pages, but that isn't critical

I also implemented this and compared to the above the patch is pretty
fugly, especially its impact on the SUNRPC patches to actually use the
feature. It needs a bit more cleanup before I can post it for comparison
though.

Ian.

 drivers/net/ethernet/broadcom/bnx2.c        |    5 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h |    4 +-
 drivers/net/ethernet/broadcom/tg3.c         |    3 +-
 include/linux/skbuff.h                      |    9 ++-
 net/core/skbuff.c                           |   67 ++++++++++++++++----------
 5 files changed, 51 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 83d8cef..4e37e05 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -5320,8 +5320,7 @@ bnx2_set_rx_ring_size(struct bnx2 *bp, u32 size)
 	/* 8 for CRC and VLAN */
 	rx_size = bp->dev->mtu + ETH_HLEN + BNX2_RX_OFFSET + 8;
 
-	rx_space = SKB_DATA_ALIGN(rx_size + BNX2_RX_ALIGN) + NET_SKB_PAD +
-		SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+	rx_space = SKB_DATA_ALIGN(rx_size + BNX2_RX_ALIGN) + NET_SKB_PAD;
 
 	bp->rx_copy_thresh = BNX2_RX_COPY_THRESH;
 	bp->rx_pg_ring_size = 0;
@@ -5345,7 +5344,7 @@ bnx2_set_rx_ring_size(struct bnx2 *bp, u32 size)
 	bp->rx_buf_use_size = rx_size;
 	/* hw alignment + build_skb() overhead*/
 	bp->rx_buf_size = SKB_DATA_ALIGN(bp->rx_buf_use_size + BNX2_RX_ALIGN) +
-		NET_SKB_PAD + SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+		NET_SKB_PAD;
 	bp->rx_jumbo_thresh = rx_size - BNX2_RX_OFFSET;
 	bp->rx_ring_size = size;
 	bp->rx_max_ring = bnx2_find_max_ring(size, MAX_RX_RINGS);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 0f7b7a4..b3de327 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1203,9 +1203,7 @@ struct bnx2x {
 	 */
 #define BNX2X_FW_RX_ALIGN_START	(1UL << BNX2X_RX_ALIGN_SHIFT)
 
-#define BNX2X_FW_RX_ALIGN_END					\
-	max(1UL << BNX2X_RX_ALIGN_SHIFT, 			\
-	    SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
+#define BNX2X_FW_RX_ALIGN_END	(1UL << BNX2X_RX_ALIGN_SHIFT)
 
 #define BNX2X_PXP_DRAM_ALIGN		(BNX2X_RX_ALIGN_SHIFT - 5)
 
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index d9e9c8c..dbea57b 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -5426,8 +5426,7 @@ static int tg3_alloc_rx_data(struct tg3 *tp, struct tg3_rx_prodring_set *tpr,
 	 * Callers depend upon this behavior and assume that
 	 * we leave everything unchanged if we fail.
 	 */
-	skb_size = SKB_DATA_ALIGN(data_size + TG3_RX_OFFSET(tp)) +
-		   SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+	skb_size = SKB_DATA_ALIGN(data_size + TG3_RX_OFFSET(tp));
 	data = kmalloc(skb_size, GFP_ATOMIC);
 	if (!data)
 		return -ENOMEM;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 09b7ea5..48e91a0 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -40,8 +40,7 @@
 
 #define SKB_DATA_ALIGN(X)	(((X) + (SMP_CACHE_BYTES - 1)) & \
 				 ~(SMP_CACHE_BYTES - 1))
-#define SKB_WITH_OVERHEAD(X)	\
-	((X) - SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
+#define SKB_WITH_OVERHEAD(X)	((X))
 #define SKB_MAX_ORDER(X, ORDER) \
 	SKB_WITH_OVERHEAD((PAGE_SIZE << (ORDER)) - (X))
 #define SKB_MAX_HEAD(X)		(SKB_MAX_ORDER((X), 0))
@@ -476,6 +475,7 @@ struct sk_buff {
 	sk_buff_data_t		end;
 	unsigned char		*head,
 				*data;
+	struct skb_shared_info	*shinfo;
 	unsigned int		truesize;
 	atomic_t		users;
 };
@@ -634,7 +634,10 @@ static inline unsigned char *skb_end_pointer(const struct sk_buff *skb)
 #endif
 
 /* Internal */
-#define skb_shinfo(SKB)	((struct skb_shared_info *)(skb_end_pointer(SKB)))
+static inline struct skb_shared_info *skb_shinfo(const struct sk_buff *skb)
+{
+	return skb->shinfo;
+}
 
 static inline struct skb_shared_hwtstamps *skb_hwtstamps(struct sk_buff *skb)
 {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7dc05ec..cfbe8e5 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -73,6 +73,7 @@
 
 static struct kmem_cache *skbuff_head_cache __read_mostly;
 static struct kmem_cache *skbuff_fclone_cache __read_mostly;
+static struct kmem_cache *skbuff_shinfo_cache __read_mostly;
 
 static void sock_pipe_buf_release(struct pipe_inode_info *pipe,
 				  struct pipe_buffer *buf)
@@ -118,7 +119,7 @@ static const struct pipe_buf_operations sock_pipe_buf_ops = {
  *
  *	Out of line support code for skb_put(). Not user callable.
  */
-static void skb_over_panic(struct sk_buff *skb, int sz, void *here)
+static void skb_over_panic(struct sk_buff*skb, int sz, void *here)
 {
 	printk(KERN_EMERG "skb_over_panic: text:%p len:%d put:%d head:%p "
 			  "data:%p tail:%#lx end:%#lx dev:%s\n",
@@ -184,22 +185,21 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 		goto out;
 	prefetchw(skb);
 
+	shinfo = kmem_cache_alloc_node(skbuff_shinfo_cache,
+				       gfp_mask & ~__GFP_DMA, node);
+	if (!shinfo)
+		goto noshinfo;
+	prefetchw(shinfo);
+
 	/* We do our best to align skb_shared_info on a separate cache
 	 * line. It usually works because kmalloc(X > SMP_CACHE_BYTES) gives
 	 * aligned memory blocks, unless SLUB/SLAB debug is enabled.
 	 * Both skb->head and skb_shared_info are cache line aligned.
 	 */
 	size = SKB_DATA_ALIGN(size);
-	size += SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 	data = kmalloc_node_track_caller(size, gfp_mask, node);
 	if (!data)
 		goto nodata;
-	/* kmalloc(size) might give us more room than requested.
-	 * Put skb_shared_info exactly at the end of allocated zone,
-	 * to allow max possible filling before reallocation.
-	 */
-	size = SKB_WITH_OVERHEAD(ksize(data));
-	prefetchw(data + size);
 
 	/*
 	 * Only clear those fields we need to clear, not those that we will
@@ -210,6 +210,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	/* Account for allocated memory : skb + skb->head */
 	skb->truesize = SKB_TRUESIZE(size);
 	atomic_set(&skb->users, 1);
+	skb->shinfo = shinfo;
 	skb->head = data;
 	skb->data = data;
 	skb_reset_tail_pointer(skb);
@@ -219,7 +220,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 #endif
 
 	/* make sure we initialize shinfo sequentially */
-	shinfo = skb_shinfo(skb);
+	BUG_ON(shinfo != skb_shinfo(skb));
 	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
 	atomic_set(&shinfo->dataref, 1);
 	kmemcheck_annotate_variable(shinfo->destructor_arg);
@@ -238,6 +239,8 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 out:
 	return skb;
 nodata:
+	kmem_cache_free(skbuff_shinfo_cache, shinfo);
+noshinfo:
 	kmem_cache_free(cache, skb);
 	skb = NULL;
 	goto out;
@@ -254,8 +257,8 @@ EXPORT_SYMBOL(__alloc_skb);
  * On a failure the return is %NULL, and @data is not freed.
  * Notes :
  *  Before IO, driver allocates only data buffer where NIC put incoming frame
- *  Driver should add room at head (NET_SKB_PAD) and
- *  MUST add room at tail (SKB_DATA_ALIGN(skb_shared_info))
+ *  Driver should add room at head (NET_SKB_PAD) and need not
+ *  add room at tail (SKB_DATA_ALIGN(skb_shared_info))
  *  After IO, driver calls build_skb(), to allocate sk_buff and populate it
  *  before giving packet to stack.
  *  RX rings only contains data buffers, not full skbs.
@@ -270,11 +273,17 @@ struct sk_buff *build_skb(void *data)
 	if (!skb)
 		return NULL;
 
-	size = ksize(data) - SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+	shinfo = kmem_cache_alloc(skbuff_shinfo_cache, GFP_ATOMIC);
+	if (!shinfo)
+		goto noshinfo;
+	prefetchw(shinfo);
+
+	size = ksize(data);
 
 	memset(skb, 0, offsetof(struct sk_buff, tail));
 	skb->truesize = SKB_TRUESIZE(size);
 	atomic_set(&skb->users, 1);
+	skb->shinfo = shinfo;
 	skb->head = data;
 	skb->data = data;
 	skb_reset_tail_pointer(skb);
@@ -284,12 +293,17 @@ struct sk_buff *build_skb(void *data)
 #endif
 
 	/* make sure we initialize shinfo sequentially */
-	shinfo = skb_shinfo(skb);
+	BUG_ON(shinfo != skb_shinfo(skb));
 	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
 	atomic_set(&shinfo->dataref, 1);
 	kmemcheck_annotate_variable(shinfo->destructor_arg);
 
+out:
 	return skb;
+noshinfo:
+	kmem_cache_free(skbuff_head_cache, skb);
+	skb = NULL;
+	goto out;
 }
 EXPORT_SYMBOL(build_skb);
 
@@ -378,7 +392,7 @@ static void skb_clone_fraglist(struct sk_buff *skb)
 		skb_get(list);
 }
 
-static void skb_release_data(struct sk_buff *skb)
+static void skb_release_data(struct sk_buff *skb, int free_shinfo)
 {
 	if (!skb->cloned ||
 	    !atomic_sub_return(skb->nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 : 1,
@@ -404,6 +418,8 @@ static void skb_release_data(struct sk_buff *skb)
 		if (skb_has_frag_list(skb))
 			skb_drop_fraglist(skb);
 
+		if (free_shinfo)
+			kmem_cache_free(skbuff_shinfo_cache, skb_shinfo(skb));
 		kfree(skb->head);
 	}
 }
@@ -474,7 +490,7 @@ static void skb_release_head_state(struct sk_buff *skb)
 static void skb_release_all(struct sk_buff *skb)
 {
 	skb_release_head_state(skb);
-	skb_release_data(skb);
+	skb_release_data(skb, 1);
 }
 
 /**
@@ -646,6 +662,7 @@ static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff *skb)
 	C(tail);
 	C(end);
 	C(head);
+	C(shinfo);
 	C(data);
 	C(truesize);
 	atomic_set(&n->users, 1);
@@ -941,18 +958,14 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 		fastpath = atomic_read(&skb_shinfo(skb)->dataref) == delta;
 	}
 
-	if (fastpath &&
-	    size + sizeof(struct skb_shared_info) <= ksize(skb->head)) {
-		memmove(skb->head + size, skb_shinfo(skb),
-			offsetof(struct skb_shared_info,
-				 frags[skb_shinfo(skb)->nr_frags]));
+	if (fastpath && size <= ksize(skb->head)) {
 		memmove(skb->head + nhead, skb->head,
 			skb_tail_pointer(skb) - skb->head);
 		off = nhead;
 		goto adjust_others;
 	}
 
-	data = kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
+	data = kmalloc(size, gfp_mask);
 	if (!data)
 		goto nodata;
 
@@ -961,10 +974,6 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 	 */
 	memcpy(data + nhead, skb->head, skb_tail_pointer(skb) - skb->head);
 
-	memcpy((struct skb_shared_info *)(data + size),
-	       skb_shinfo(skb),
-	       offsetof(struct skb_shared_info, frags[skb_shinfo(skb)->nr_frags]));
-after apply
 	if (fastpath) {
 		kfree(skb->head);
 	} else {
@@ -979,7 +988,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 		if (skb_has_frag_list(skb))
 			skb_clone_fraglist(skb);
 
-		skb_release_data(skb);
+		skb_release_data(skb, 0);
 	}
 	off = (data + nhead) - skb->head;
 
@@ -2956,6 +2965,12 @@ void __init skb_init(void)
 						0,
 						SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 						NULL);
+
+	skbuff_shinfo_cache = kmem_cache_create("skbuff_shinfo_cache",
+						sizeof(struct skb_shared_info),
+						0,
+						SLAB_HWCACHE_ALIGN|SLAB_PANIC,
+						NULL);
 }
 
 /**
