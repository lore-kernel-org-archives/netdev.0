From: Michael Dalton <mwdalton@google.com>
Subject: [PATCH net-next 4/4] virtio-net: auto-tune mergeable rx buffer size for improved performance
Date: Tue, 12 Nov 2013 14:21:25 -0800
Message-ID: <1384294885-6444-4-git-send-email-mwdalton@google.com>
References: <1384294885-6444-1-git-send-email-mwdalton@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jason Wang <jasowang@redhat.com>,
	Eric Northup <digitaleric@google.com>,
	virtualization@lists.linux-foundation.org,
	Michael Dalton <mwdalton@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:35387 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757326Ab3KLWVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 17:21:52 -0500
Received: by mail-ob0-f202.google.com with SMTP id gq1so1250394obb.3
        for <netdev@vger.kernel.org>; Tue, 12 Nov 2013 14:21:52 -0800 (PST)
In-Reply-To: <1384294885-6444-1-git-send-email-mwdalton@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 2613af0ed18a ("virtio_net: migrate mergeable rx buffers to page frag
allocators") changed the mergeable receive buffer size from PAGE_SIZE to
MTU-size, introducing a single-stream regression for benchmarks with large
average packet size. There is no single optimal buffer size for all workloads.
For workloads with packet size <= MTU bytes, MTU + virtio-net header-sized
buffers are preferred as larger buffers reduce the TCP window due to SKB
truesize. However, single-stream workloads with large average packet sizes
have higher throughput if larger (e.g., PAGE_SIZE) buffers are used.

This commit auto-tunes the mergeable receiver buffer packet size by choosing
the packet buffer size based on an EWMA of the recent packet sizes for the
receive queue. Packet buffer sizes range from MTU_SIZE + virtio-net header
len to PAGE_SIZE. This improves throughput for large packet workloads, as
any workload with average packet size >= PAGE_SIZE will use PAGE_SIZE
buffers.

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

net-next trunk w/ virtio_net before 2613af0ed18a (PAGE_SIZE bufs): 14642.85Gb/s
net-next trunk (MTU-size bufs):  13170.01Gb/s
net-next trunk + auto-tune: 14555.94Gb/s

Signed-off-by: Michael Dalton <mwdalton@google.com>
---
 drivers/net/virtio_net.c | 73 +++++++++++++++++++++++++++++++++++-------------
 1 file changed, 53 insertions(+), 20 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 0c93054..b1086e0 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -27,6 +27,7 @@
 #include <linux/if_vlan.h>
 #include <linux/slab.h>
 #include <linux/cpu.h>
+#include <linux/average.h>
 
 static int napi_weight = NAPI_POLL_WEIGHT;
 module_param(napi_weight, int, 0444);
@@ -37,10 +38,8 @@ module_param(gso, bool, 0444);
 
 /* FIXME: MTU in config. */
 #define GOOD_PACKET_LEN (ETH_HLEN + VLAN_HLEN + ETH_DATA_LEN)
-#define MERGE_BUFFER_LEN (ALIGN(GOOD_PACKET_LEN + \
-                                sizeof(struct virtio_net_hdr_mrg_rxbuf), \
-                                L1_CACHE_BYTES))
 #define GOOD_COPY_LEN	128
+#define RECEIVE_AVG_WEIGHT 64
 
 #define VIRTNET_DRIVER_VERSION "1.0.0"
 
@@ -79,6 +78,9 @@ struct receive_queue {
 	/* Chain pages by the private ptr. */
 	struct page *pages;
 
+	/* Average packet length for mergeable receive buffers. */
+	struct ewma mrg_avg_pkt_len;
+
 	/* Page frag for GFP_ATOMIC packet buffer allocation. */
 	struct page_frag atomic_frag;
 
@@ -302,14 +304,17 @@ static struct sk_buff *page_to_skb(struct receive_queue *rq,
 	return skb;
 }
 
-static int receive_mergeable(struct receive_queue *rq, struct sk_buff *head_skb)
+static int receive_mergeable(struct receive_queue *rq, struct sk_buff *head_skb,
+			     struct page *head_page)
 {
 	struct skb_vnet_hdr *hdr = skb_vnet_hdr(head_skb);
 	struct sk_buff *curr_skb = head_skb;
+	struct page *page = head_page;
 	char *buf;
-	struct page *page;
-	int num_buf, len, offset, truesize;
+	int num_buf, len, offset;
+	u32 est_buffer_len;
 
+	len = head_skb->len;
 	num_buf = hdr->mhdr.num_buffers;
 	while (--num_buf) {
 		int num_skb_frags = skb_shinfo(curr_skb)->nr_frags;
@@ -320,7 +325,6 @@ static int receive_mergeable(struct receive_queue *rq, struct sk_buff *head_skb)
 			head_skb->dev->stats.rx_length_errors++;
 			return -EINVAL;
 		}
-		truesize = max_t(int, len, MERGE_BUFFER_LEN);
 		if (unlikely(num_skb_frags == MAX_SKB_FRAGS)) {
 			struct sk_buff *nskb = alloc_skb(0, GFP_ATOMIC);
 			if (unlikely(!nskb)) {
@@ -338,20 +342,38 @@ static int receive_mergeable(struct receive_queue *rq, struct sk_buff *head_skb)
 		if (curr_skb != head_skb) {
 			head_skb->data_len += len;
 			head_skb->len += len;
-			head_skb->truesize += truesize;
+			head_skb->truesize += len;
 		}
 		page = virt_to_head_page(buf);
 		offset = buf - (char *)page_address(page);
 		if (skb_can_coalesce(curr_skb, num_skb_frags, page, offset)) {
 			put_page(page);
 			skb_coalesce_rx_frag(curr_skb, num_skb_frags - 1,
-					     len, truesize);
+					     len, len);
 		} else {
 			skb_add_rx_frag(curr_skb, num_skb_frags, page,
-					offset, len, truesize);
+					offset, len, len);
 		}
 		--rq->num;
 	}
+	/* All frags before the last frag are fully used -- for those frags,
+	 * truesize = len. Use the size of the most recent buffer allocation
+	 * from the last frag's page to estimate the truesize of the last frag.
+	 * EWMA with a weight of 64 makes the size adjustments quite small in
+	 * the frags allocated on one page (even a order-3 one), and truesize
+	 * doesn't need to be 100% accurate.
+	 */
+	if (page) {
+		est_buffer_len = page_private(page);
+		if (est_buffer_len > len) {
+			u32 truesize_delta = est_buffer_len - len;
+
+			curr_skb->truesize += truesize_delta;
+			if (curr_skb != head_skb)
+				head_skb->truesize += truesize_delta;
+		}
+	}
+	ewma_add(&rq->mrg_avg_pkt_len, head_skb->len);
 	return 0;
 }
 
@@ -382,16 +404,21 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
 		skb_trim(skb, len);
 	} else if (vi->mergeable_rx_bufs) {
 		struct page *page = virt_to_head_page(buf);
-		int truesize = max_t(int, len, MERGE_BUFFER_LEN);
+		/* Use an initial truesize of 'len' bytes for page_to_skb --
+		 * receive_mergeable will fixup the truesize of the last page
+		 * frag if the packet is non-linear (> GOOD_COPY_LEN bytes).
+		 */
 		skb = page_to_skb(rq, page,
 				  (char *)buf - (char *)page_address(page),
-				  len, truesize);
+				  len, len);
 		if (unlikely(!skb)) {
 			dev->stats.rx_dropped++;
 			put_page(page);
 			return;
 		}
-		if (receive_mergeable(rq, skb)) {
+		if (!skb_is_nonlinear(skb))
+			page = NULL;
+		if (receive_mergeable(rq, skb, page)) {
 			dev_kfree_skb(skb);
 			return;
 		}
@@ -540,24 +567,29 @@ static int add_recvbuf_big(struct receive_queue *rq, gfp_t gfp)
 static int add_recvbuf_mergeable(struct receive_queue *rq, gfp_t gfp)
 {
 	struct virtnet_info *vi = rq->vq->vdev->priv;
+	const size_t hdr_len = sizeof(struct virtio_net_hdr_mrg_rxbuf);
 	struct page_frag *alloc_frag;
 	char *buf;
-	int err, len, hole;
+	int err, hole;
+	u32 buflen;
 
+	buflen = hdr_len + clamp_t(u32, ewma_read(&rq->mrg_avg_pkt_len),
+				   GOOD_PACKET_LEN, PAGE_SIZE - hdr_len);
+	buflen = ALIGN(buflen, L1_CACHE_BYTES);
 	alloc_frag = (gfp & __GFP_WAIT) ? &vi->sleep_frag : &rq->atomic_frag;
-	if (unlikely(!skb_page_frag_refill(MERGE_BUFFER_LEN, alloc_frag, gfp)))
+	if (unlikely(!skb_page_frag_refill(buflen, alloc_frag, gfp)))
 		return -ENOMEM;
 	buf = (char *)page_address(alloc_frag->page) + alloc_frag->offset;
 	get_page(alloc_frag->page);
-	len = MERGE_BUFFER_LEN;
-	alloc_frag->offset += len;
+	alloc_frag->offset += buflen;
+	set_page_private(alloc_frag->page, buflen);
 	hole = alloc_frag->size - alloc_frag->offset;
-	if (hole < MERGE_BUFFER_LEN) {
-		len += hole;
+	if (hole < buflen) {
+		buflen += hole;
 		alloc_frag->offset += hole;
 	}
 
-	sg_init_one(rq->sg, buf, len);
+	sg_init_one(rq->sg, buf, buflen);
 	err = virtqueue_add_inbuf(rq->vq, rq->sg, 1, buf, gfp);
 	if (err < 0)
 		put_page(virt_to_head_page(buf));
@@ -1475,6 +1507,7 @@ static int virtnet_alloc_queues(struct virtnet_info *vi)
 			       napi_weight);
 
 		sg_init_table(vi->rq[i].sg, ARRAY_SIZE(vi->rq[i].sg));
+		ewma_init(&vi->rq[i].mrg_avg_pkt_len, 1, RECEIVE_AVG_WEIGHT);
 		sg_init_table(vi->sq[i].sg, ARRAY_SIZE(vi->sq[i].sg));
 	}
 
-- 
1.8.4.1
