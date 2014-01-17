From: Michael Dalton <mwdalton@google.com>
Subject: [PATCH net-next v5 3/6] virtio-net: auto-tune mergeable rx buffer size for improved performance
Date: Thu, 16 Jan 2014 18:36:13 -0800
Message-ID: <1389926176-6699-4-git-send-email-mwdalton@google.com>
References: <1389926176-6699-1-git-send-email-mwdalton@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	virtualization@lists.linux-foundation.org,
	Michael Dalton <mwdalton@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f201.google.com ([209.85.220.201]:55422 "EHLO
	mail-vc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310AbaAQCga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 21:36:30 -0500
Received: by mail-vc0-f201.google.com with SMTP id hq11so321187vcb.0
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 18:36:29 -0800 (PST)
In-Reply-To: <1389926176-6699-1-git-send-email-mwdalton@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 2613af0ed18a ("virtio_net: migrate mergeable rx buffers to page frag
allocators") changed the mergeable receive buffer size from PAGE_SIZE to
MTU-size, introducing a single-stream regression for benchmarks with large
average packet size. There is no single optimal buffer size for all
workloads.  For workloads with packet size <= MTU bytes, MTU + virtio-net
header-sized buffers are preferred as larger buffers reduce the TCP window
due to SKB truesize. However, single-stream workloads with large average
packet sizes have higher throughput if larger (e.g., PAGE_SIZE) buffers
are used.

This commit auto-tunes the mergeable receiver buffer packet size by
choosing the packet buffer size based on an EWMA of the recent packet
sizes for the receive queue. Packet buffer sizes range from MTU_SIZE +
virtio-net header len to PAGE_SIZE. This improves throughput for
large packet workloads, as any workload with average packet size >=
PAGE_SIZE will use PAGE_SIZE buffers.

These optimizations interact positively with recent commit
ba275241030c ("virtio-net: coalesce rx frags when possible during rx"),
which coalesces adjacent RX SKB fragments in virtio_net. The coalescing
optimizations benefit buffers of any size.

Benchmarks taken from an average of 5 netperf 30-second TCP_STREAM runs
between two QEMU VMs on a single physical machine. Each VM has two VCPUs
with all offloads & vhost enabled. All VMs and vhost threads run in a
single 4 CPU cgroup cpuset, using cgroups to ensure that other processes
in the system will not be scheduled on the benchmark CPUs. Trunk includes
SKB rx frag coalescing.

net-next w/ virtio_net before 2613af0ed18a (PAGE_SIZE bufs): 14642.85Gb/s
net-next (MTU-size bufs):  13170.01Gb/s
net-next + auto-tune: 14555.94Gb/s

Jason Wang also reported a throughput increase on mlx4 from 22Gb/s
using MTU-sized buffers to about 26Gb/s using auto-tuning.

Acked-by: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Michael Dalton <mwdalton@google.com>
---
v2->v3: Remove per-receive queue metadata ring. Encode packet buffer
        base address and truesize into an unsigned long by requiring a
        minimum packet size alignment of 256. Permit attempts to fill
        an already-full RX ring (reverting the change in v2).
v1->v2: Add per-receive queue metadata ring to track precise truesize for
        mergeable receive buffers. Remove all truesize approximation. Never
        try to fill a full RX ring (required for metadata ring in v2).

 drivers/net/virtio_net.c | 99 ++++++++++++++++++++++++++++++++++++------------
 1 file changed, 74 insertions(+), 25 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 36cbf06..3e82311 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -26,6 +26,7 @@
 #include <linux/if_vlan.h>
 #include <linux/slab.h>
 #include <linux/cpu.h>
+#include <linux/average.h>
 
 static int napi_weight = NAPI_POLL_WEIGHT;
 module_param(napi_weight, int, 0444);
@@ -36,11 +37,18 @@ module_param(gso, bool, 0444);
 
 /* FIXME: MTU in config. */
 #define GOOD_PACKET_LEN (ETH_HLEN + VLAN_HLEN + ETH_DATA_LEN)
-#define MERGE_BUFFER_LEN (ALIGN(GOOD_PACKET_LEN + \
-                                sizeof(struct virtio_net_hdr_mrg_rxbuf), \
-                                L1_CACHE_BYTES))
 #define GOOD_COPY_LEN	128
 
+/* Weight used for the RX packet size EWMA. The average packet size is used to
+ * determine the packet buffer size when refilling RX rings. As the entire RX
+ * ring may be refilled at once, the weight is chosen so that the EWMA will be
+ * insensitive to short-term, transient changes in packet size.
+ */
+#define RECEIVE_AVG_WEIGHT 64
+
+/* Minimum alignment for mergeable packet buffers. */
+#define MERGEABLE_BUFFER_ALIGN max(L1_CACHE_BYTES, 256)
+
 #define VIRTNET_DRIVER_VERSION "1.0.0"
 
 struct virtnet_stats {
@@ -78,6 +86,9 @@ struct receive_queue {
 	/* Chain pages by the private ptr. */
 	struct page *pages;
 
+	/* Average packet length for mergeable receive buffers. */
+	struct ewma mrg_avg_pkt_len;
+
 	/* Page frag for packet buffer allocation. */
 	struct page_frag alloc_frag;
 
@@ -219,6 +230,23 @@ static void skb_xmit_done(struct virtqueue *vq)
 	netif_wake_subqueue(vi->dev, vq2txq(vq));
 }
 
+static unsigned int mergeable_ctx_to_buf_truesize(unsigned long mrg_ctx)
+{
+	unsigned int truesize = mrg_ctx & (MERGEABLE_BUFFER_ALIGN - 1);
+	return truesize * MERGEABLE_BUFFER_ALIGN;
+}
+
+static void *mergeable_ctx_to_buf_address(unsigned long mrg_ctx)
+{
+	return (void *)(mrg_ctx & -MERGEABLE_BUFFER_ALIGN);
+
+}
+
+static unsigned long mergeable_buf_to_ctx(void *buf, unsigned int truesize)
+{
+	return (unsigned long)buf | (truesize / MERGEABLE_BUFFER_ALIGN);
+}
+
 /* Called from bottom half context */
 static struct sk_buff *page_to_skb(struct receive_queue *rq,
 				   struct page *page, unsigned int offset,
@@ -327,31 +355,33 @@ err:
 
 static struct sk_buff *receive_mergeable(struct net_device *dev,
 					 struct receive_queue *rq,
-					 void *buf,
+					 unsigned long ctx,
 					 unsigned int len)
 {
+	void *buf = mergeable_ctx_to_buf_address(ctx);
 	struct skb_vnet_hdr *hdr = buf;
 	int num_buf = hdr->mhdr.num_buffers;
 	struct page *page = virt_to_head_page(buf);
 	int offset = buf - page_address(page);
-	unsigned int truesize = max_t(unsigned int, len, MERGE_BUFFER_LEN);
+	unsigned int truesize = max(len, mergeable_ctx_to_buf_truesize(ctx));
+
 	struct sk_buff *head_skb = page_to_skb(rq, page, offset, len, truesize);
 	struct sk_buff *curr_skb = head_skb;
 
 	if (unlikely(!curr_skb))
 		goto err_skb;
-
 	while (--num_buf) {
 		int num_skb_frags;
 
-		buf = virtqueue_get_buf(rq->vq, &len);
-		if (unlikely(!buf)) {
+		ctx = (unsigned long)virtqueue_get_buf(rq->vq, &len);
+		if (unlikely(!ctx)) {
 			pr_debug("%s: rx error: %d buffers out of %d missing\n",
 				 dev->name, num_buf, hdr->mhdr.num_buffers);
 			dev->stats.rx_length_errors++;
 			goto err_buf;
 		}
 
+		buf = mergeable_ctx_to_buf_address(ctx);
 		page = virt_to_head_page(buf);
 		--rq->num;
 
@@ -369,7 +399,7 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 			head_skb->truesize += nskb->truesize;
 			num_skb_frags = 0;
 		}
-		truesize = max_t(unsigned int, len, MERGE_BUFFER_LEN);
+		truesize = max(len, mergeable_ctx_to_buf_truesize(ctx));
 		if (curr_skb != head_skb) {
 			head_skb->data_len += len;
 			head_skb->len += len;
@@ -386,19 +416,20 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 		}
 	}
 
+	ewma_add(&rq->mrg_avg_pkt_len, head_skb->len);
 	return head_skb;
 
 err_skb:
 	put_page(page);
 	while (--num_buf) {
-		buf = virtqueue_get_buf(rq->vq, &len);
-		if (unlikely(!buf)) {
+		ctx = (unsigned long)virtqueue_get_buf(rq->vq, &len);
+		if (unlikely(!ctx)) {
 			pr_debug("%s: rx error: %d buffers missing\n",
 				 dev->name, num_buf);
 			dev->stats.rx_length_errors++;
 			break;
 		}
-		page = virt_to_head_page(buf);
+		page = virt_to_head_page(mergeable_ctx_to_buf_address(ctx));
 		put_page(page);
 		--rq->num;
 	}
@@ -419,17 +450,20 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
 	if (unlikely(len < sizeof(struct virtio_net_hdr) + ETH_HLEN)) {
 		pr_debug("%s: short packet %i\n", dev->name, len);
 		dev->stats.rx_length_errors++;
-		if (vi->mergeable_rx_bufs)
-			put_page(virt_to_head_page(buf));
-		else if (vi->big_packets)
+		if (vi->mergeable_rx_bufs) {
+			unsigned long ctx = (unsigned long)buf;
+			void *base = mergeable_ctx_to_buf_address(ctx);
+			put_page(virt_to_head_page(base));
+		} else if (vi->big_packets) {
 			give_pages(rq, buf);
-		else
+		} else {
 			dev_kfree_skb(buf);
+		}
 		return;
 	}
 
 	if (vi->mergeable_rx_bufs)
-		skb = receive_mergeable(dev, rq, buf, len);
+		skb = receive_mergeable(dev, rq, (unsigned long)buf, len);
 	else if (vi->big_packets)
 		skb = receive_big(dev, rq, buf, len);
 	else
@@ -572,25 +606,36 @@ static int add_recvbuf_big(struct receive_queue *rq, gfp_t gfp)
 
 static int add_recvbuf_mergeable(struct receive_queue *rq, gfp_t gfp)
 {
+	const size_t hdr_len = sizeof(struct virtio_net_hdr_mrg_rxbuf);
 	struct page_frag *alloc_frag = &rq->alloc_frag;
 	char *buf;
+	unsigned long ctx;
 	int err;
 	unsigned int len, hole;
 
-	if (unlikely(!skb_page_frag_refill(MERGE_BUFFER_LEN, alloc_frag, gfp)))
+	len = hdr_len + clamp_t(unsigned int, ewma_read(&rq->mrg_avg_pkt_len),
+				GOOD_PACKET_LEN, PAGE_SIZE - hdr_len);
+	len = ALIGN(len, MERGEABLE_BUFFER_ALIGN);
+	if (unlikely(!skb_page_frag_refill(len, alloc_frag, gfp)))
 		return -ENOMEM;
+
 	buf = (char *)page_address(alloc_frag->page) + alloc_frag->offset;
+	ctx = mergeable_buf_to_ctx(buf, len);
 	get_page(alloc_frag->page);
-	len = MERGE_BUFFER_LEN;
 	alloc_frag->offset += len;
 	hole = alloc_frag->size - alloc_frag->offset;
-	if (hole < MERGE_BUFFER_LEN) {
+	if (hole < len) {
+		/* To avoid internal fragmentation, if there is very likely not
+		 * enough space for another buffer, add the remaining space to
+		 * the current buffer. This extra space is not included in
+		 * the truesize stored in ctx.
+		 */
 		len += hole;
 		alloc_frag->offset += hole;
 	}
 
 	sg_init_one(rq->sg, buf, len);
-	err = virtqueue_add_inbuf(rq->vq, rq->sg, 1, buf, gfp);
+	err = virtqueue_add_inbuf(rq->vq, rq->sg, 1, (void *)ctx, gfp);
 	if (err < 0)
 		put_page(virt_to_head_page(buf));
 
@@ -1394,12 +1439,15 @@ static void free_unused_bufs(struct virtnet_info *vi)
 		struct virtqueue *vq = vi->rq[i].vq;
 
 		while ((buf = virtqueue_detach_unused_buf(vq)) != NULL) {
-			if (vi->mergeable_rx_bufs)
-				put_page(virt_to_head_page(buf));
-			else if (vi->big_packets)
+			if (vi->mergeable_rx_bufs) {
+				unsigned long ctx = (unsigned long)buf;
+				void *base = mergeable_ctx_to_buf_address(ctx);
+				put_page(virt_to_head_page(base));
+			} else if (vi->big_packets) {
 				give_pages(&vi->rq[i], buf);
-			else
+			} else {
 				dev_kfree_skb(buf);
+			}
 			--vi->rq[i].num;
 		}
 		BUG_ON(vi->rq[i].num != 0);
@@ -1509,6 +1557,7 @@ static int virtnet_alloc_queues(struct virtnet_info *vi)
 			       napi_weight);
 
 		sg_init_table(vi->rq[i].sg, ARRAY_SIZE(vi->rq[i].sg));
+		ewma_init(&vi->rq[i].mrg_avg_pkt_len, 1, RECEIVE_AVG_WEIGHT);
 		sg_init_table(vi->sq[i].sg, ARRAY_SIZE(vi->sq[i].sg));
 	}
 
-- 
1.8.5.2
