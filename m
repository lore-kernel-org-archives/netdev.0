From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 5/6] virtio_net: rework mergeable buffer handling
Date: Wed, 29 Mar 2017 23:48:55 +0300
Message-ID: <1490820507-8005-6-git-send-email-mst@redhat.com>
References: <1490820507-8005-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, John Fastabend <john.fastabend@gmail.com>,
	virtualization@lists.linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1490820507-8005-1-git-send-email-mst@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Use the new _ctx virtio API to maintain true length for each buffer.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/virtio_net.c | 91 +++++++++++++++++++++++-------------------------
 1 file changed, 44 insertions(+), 47 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 340f737..94f94f3 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -250,24 +250,6 @@ static void skb_xmit_done(struct virtqueue *vq)
 	netif_wake_subqueue(vi->dev, vq2txq(vq));
 }
 
-static unsigned int mergeable_ctx_to_buf_truesize(unsigned long mrg_ctx)
-{
-	unsigned int truesize = mrg_ctx & (MERGEABLE_BUFFER_ALIGN - 1);
-	return (truesize + 1) * MERGEABLE_BUFFER_ALIGN;
-}
-
-static void *mergeable_ctx_to_buf_address(unsigned long mrg_ctx)
-{
-	return (void *)(mrg_ctx & -MERGEABLE_BUFFER_ALIGN);
-
-}
-
-static unsigned long mergeable_buf_to_ctx(void *buf, unsigned int truesize)
-{
-	unsigned int size = truesize / MERGEABLE_BUFFER_ALIGN;
-	return (unsigned long)buf | (size - 1);
-}
-
 /* Called from bottom half context */
 static struct sk_buff *page_to_skb(struct virtnet_info *vi,
 				   struct receive_queue *rq,
@@ -511,15 +493,13 @@ static struct page *xdp_linearize_page(struct receive_queue *rq,
 
 	while (--*num_buf) {
 		unsigned int buflen;
-		unsigned long ctx;
 		void *buf;
 		int off;
 
-		ctx = (unsigned long)virtqueue_get_buf(rq->vq, &buflen);
-		if (unlikely(!ctx))
+		buf = virtqueue_get_buf(rq->vq, &buflen);
+		if (unlikely(!buf))
 			goto err_buf;
 
-		buf = mergeable_ctx_to_buf_address(ctx);
 		p = virt_to_head_page(buf);
 		off = buf - page_address(p);
 
@@ -548,10 +528,10 @@ static struct page *xdp_linearize_page(struct receive_queue *rq,
 static struct sk_buff *receive_mergeable(struct net_device *dev,
 					 struct virtnet_info *vi,
 					 struct receive_queue *rq,
-					 unsigned long ctx,
+					 void *buf,
+					 void *ctx,
 					 unsigned int len)
 {
-	void *buf = mergeable_ctx_to_buf_address(ctx);
 	struct virtio_net_hdr_mrg_rxbuf *hdr = buf;
 	u16 num_buf = virtio16_to_cpu(vi->vdev, hdr->num_buffers);
 	struct page *page = virt_to_head_page(buf);
@@ -639,7 +619,13 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 	}
 	rcu_read_unlock();
 
-	truesize = max(len, mergeable_ctx_to_buf_truesize(ctx));
+	if (unlikely(len > (unsigned long)ctx)) {
+		pr_debug("%s: rx error: len %u exceeds truesize 0x%lu\n",
+			 dev->name, len, (unsigned long)ctx);
+		dev->stats.rx_length_errors++;
+		goto err_skb;
+	}
+	truesize = (unsigned long)ctx;
 	head_skb = page_to_skb(vi, rq, page, offset, len, truesize);
 	curr_skb = head_skb;
 
@@ -648,7 +634,7 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 	while (--num_buf) {
 		int num_skb_frags;
 
-		ctx = (unsigned long)virtqueue_get_buf(rq->vq, &len);
+		buf = virtqueue_get_buf_ctx(rq->vq, &len, &ctx);
 		if (unlikely(!ctx)) {
 			pr_debug("%s: rx error: %d buffers out of %d missing\n",
 				 dev->name, num_buf,
@@ -658,8 +644,14 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 			goto err_buf;
 		}
 
-		buf = mergeable_ctx_to_buf_address(ctx);
 		page = virt_to_head_page(buf);
+		if (unlikely(len > (unsigned long)ctx)) {
+			pr_debug("%s: rx error: len %u exceeds truesize 0x%lu\n",
+				 dev->name, len, (unsigned long)ctx);
+			dev->stats.rx_length_errors++;
+			goto err_skb;
+		}
+		truesize = (unsigned long)ctx;
 
 		num_skb_frags = skb_shinfo(curr_skb)->nr_frags;
 		if (unlikely(num_skb_frags == MAX_SKB_FRAGS)) {
@@ -675,7 +667,6 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 			head_skb->truesize += nskb->truesize;
 			num_skb_frags = 0;
 		}
-		truesize = max(len, mergeable_ctx_to_buf_truesize(ctx));
 		if (curr_skb != head_skb) {
 			head_skb->data_len += len;
 			head_skb->len += len;
@@ -700,14 +691,14 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 err_skb:
 	put_page(page);
 	while (--num_buf) {
-		ctx = (unsigned long)virtqueue_get_buf(rq->vq, &len);
-		if (unlikely(!ctx)) {
+		buf = virtqueue_get_buf(rq->vq, &len);
+		if (unlikely(!buf)) {
 			pr_debug("%s: rx error: %d buffers missing\n",
 				 dev->name, num_buf);
 			dev->stats.rx_length_errors++;
 			break;
 		}
-		page = virt_to_head_page(mergeable_ctx_to_buf_address(ctx));
+		page = virt_to_head_page(buf);
 		put_page(page);
 	}
 err_buf:
@@ -718,7 +709,7 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 }
 
 static int receive_buf(struct virtnet_info *vi, struct receive_queue *rq,
-		       void *buf, unsigned int len)
+		       void *buf, unsigned int len, void **ctx)
 {
 	struct net_device *dev = vi->dev;
 	struct sk_buff *skb;
@@ -729,9 +720,7 @@ static int receive_buf(struct virtnet_info *vi, struct receive_queue *rq,
 		pr_debug("%s: short packet %i\n", dev->name, len);
 		dev->stats.rx_length_errors++;
 		if (vi->mergeable_rx_bufs) {
-			unsigned long ctx = (unsigned long)buf;
-			void *base = mergeable_ctx_to_buf_address(ctx);
-			put_page(virt_to_head_page(base));
+			put_page(virt_to_head_page(buf));
 		} else if (vi->big_packets) {
 			give_pages(rq, buf);
 		} else {
@@ -741,7 +730,7 @@ static int receive_buf(struct virtnet_info *vi, struct receive_queue *rq,
 	}
 
 	if (vi->mergeable_rx_bufs)
-		skb = receive_mergeable(dev, vi, rq, (unsigned long)buf, len);
+		skb = receive_mergeable(dev, vi, rq, buf, ctx, len);
 	else if (vi->big_packets)
 		skb = receive_big(dev, vi, rq, buf, len);
 	else
@@ -869,7 +858,7 @@ static int add_recvbuf_mergeable(struct virtnet_info *vi,
 	struct page_frag *alloc_frag = &rq->alloc_frag;
 	unsigned int headroom = virtnet_get_headroom(vi);
 	char *buf;
-	unsigned long ctx;
+	void *ctx;
 	int err;
 	unsigned int len, hole;
 
@@ -879,7 +868,7 @@ static int add_recvbuf_mergeable(struct virtnet_info *vi,
 
 	buf = (char *)page_address(alloc_frag->page) + alloc_frag->offset;
 	buf += headroom; /* advance address leaving hole at front of pkt */
-	ctx = mergeable_buf_to_ctx(buf, len);
+	ctx = (void *)(unsigned long)len;
 	get_page(alloc_frag->page);
 	alloc_frag->offset += len + headroom;
 	hole = alloc_frag->size - alloc_frag->offset;
@@ -894,7 +883,7 @@ static int add_recvbuf_mergeable(struct virtnet_info *vi,
 	}
 
 	sg_init_one(rq->sg, buf, len);
-	err = virtqueue_add_inbuf(rq->vq, rq->sg, 1, (void *)ctx, gfp);
+	err = virtqueue_add_inbuf_ctx(rq->vq, rq->sg, 1, buf, ctx, gfp);
 	if (err < 0)
 		put_page(virt_to_head_page(buf));
 
@@ -988,10 +977,20 @@ static int virtnet_receive(struct receive_queue *rq, int budget)
 	void *buf;
 	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
 
-	while (received < budget &&
-	       (buf = virtqueue_get_buf(rq->vq, &len)) != NULL) {
-		bytes += receive_buf(vi, rq, buf, len);
-		received++;
+	if (vi->mergeable_rx_bufs) {
+		void *ctx;
+
+		while (received < budget &&
+		       (buf = virtqueue_get_buf_ctx(rq->vq, &len, &ctx))) {
+			bytes += receive_buf(vi, rq, buf, len, ctx);
+			received++;
+		}
+	} else {
+		while (received < budget &&
+		       (buf = virtqueue_get_buf(rq->vq, &len)) != NULL) {
+			bytes += receive_buf(vi, rq, buf, len, NULL);
+			received++;
+		}
 	}
 
 	if (rq->vq->num_free > virtqueue_get_vring_size(rq->vq) / 2) {
@@ -2014,9 +2013,7 @@ static void free_unused_bufs(struct virtnet_info *vi)
 
 		while ((buf = virtqueue_detach_unused_buf(vq)) != NULL) {
 			if (vi->mergeable_rx_bufs) {
-				unsigned long ctx = (unsigned long)buf;
-				void *base = mergeable_ctx_to_buf_address(ctx);
-				put_page(virt_to_head_page(base));
+				put_page(virt_to_head_page(buf));
 			} else if (vi->big_packets) {
 				give_pages(&vi->rq[i], buf);
 			} else {
@@ -2044,7 +2041,7 @@ static int virtnet_find_vqs(struct virtnet_info *vi)
 	int ret = -ENOMEM;
 	int i, total_vqs;
 	const char **names;
-	const bool *ctx;
+	bool *ctx;
 
 	/* We expect 1 RX virtqueue followed by 1 TX virtqueue, followed by
 	 * possible N-1 RX/TX queue pairs used in multiqueue mode, followed by
-- 
MST
