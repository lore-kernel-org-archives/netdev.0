From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v5 22/45] virtio_net: pass vi around
Date: Thu, 27 Nov 2014 14:31:55 +0200
Message-ID: <1417091078-24611-23-git-send-email-mst@redhat.com>
References: <1417091078-24611-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cornelia.huck@de.ibm.com,
	rusty@au1.ibm.com, nab@linux-iscsi.org, pbonzini@redhat.com,
	thuth@linux.vnet.ibm.com, dahi@linux.vnet.ibm.com,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1417091078-24611-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Too many places poke at [rs]q->vq->vdev->priv just to get
the vi structure.  Let's just pass the pointer around: seems
cleaner, and might even be faster.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Reviewed-by: Cornelia Huck <cornelia.huck@de.ibm.com>
---
 drivers/net/virtio_net.c | 38 ++++++++++++++++++++------------------
 1 file changed, 20 insertions(+), 18 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index c07e030..1630c21 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -241,11 +241,11 @@ static unsigned long mergeable_buf_to_ctx(void *buf, unsigned int truesize)
 }
 
 /* Called from bottom half context */
-static struct sk_buff *page_to_skb(struct receive_queue *rq,
+static struct sk_buff *page_to_skb(struct virtnet_info *vi,
+				   struct receive_queue *rq,
 				   struct page *page, unsigned int offset,
 				   unsigned int len, unsigned int truesize)
 {
-	struct virtnet_info *vi = rq->vq->vdev->priv;
 	struct sk_buff *skb;
 	struct skb_vnet_hdr *hdr;
 	unsigned int copy, hdr_len, hdr_padded_len;
@@ -328,12 +328,13 @@ static struct sk_buff *receive_small(void *buf, unsigned int len)
 }
 
 static struct sk_buff *receive_big(struct net_device *dev,
+				   struct virtnet_info *vi,
 				   struct receive_queue *rq,
 				   void *buf,
 				   unsigned int len)
 {
 	struct page *page = buf;
-	struct sk_buff *skb = page_to_skb(rq, page, 0, len, PAGE_SIZE);
+	struct sk_buff *skb = page_to_skb(vi, rq, page, 0, len, PAGE_SIZE);
 
 	if (unlikely(!skb))
 		goto err;
@@ -359,7 +360,8 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
 	int offset = buf - page_address(page);
 	unsigned int truesize = max(len, mergeable_ctx_to_buf_truesize(ctx));
 
-	struct sk_buff *head_skb = page_to_skb(rq, page, offset, len, truesize);
+	struct sk_buff *head_skb = page_to_skb(vi, rq, page, offset, len,
+					       truesize);
 	struct sk_buff *curr_skb = head_skb;
 
 	if (unlikely(!curr_skb))
@@ -433,9 +435,9 @@ err_buf:
 	return NULL;
 }
 
-static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
+static void receive_buf(struct virtnet_info *vi, struct receive_queue *rq,
+			void *buf, unsigned int len)
 {
-	struct virtnet_info *vi = rq->vq->vdev->priv;
 	struct net_device *dev = vi->dev;
 	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
 	struct sk_buff *skb;
@@ -459,7 +461,7 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
 	if (vi->mergeable_rx_bufs)
 		skb = receive_mergeable(dev, vi, rq, (unsigned long)buf, len);
 	else if (vi->big_packets)
-		skb = receive_big(dev, rq, buf, len);
+		skb = receive_big(dev, vi, rq, buf, len);
 	else
 		skb = receive_small(buf, len);
 
@@ -539,9 +541,9 @@ frame_err:
 	dev_kfree_skb(skb);
 }
 
-static int add_recvbuf_small(struct receive_queue *rq, gfp_t gfp)
+static int add_recvbuf_small(struct virtnet_info *vi, struct receive_queue *rq,
+			     gfp_t gfp)
 {
-	struct virtnet_info *vi = rq->vq->vdev->priv;
 	struct sk_buff *skb;
 	struct skb_vnet_hdr *hdr;
 	int err;
@@ -664,9 +666,9 @@ static int add_recvbuf_mergeable(struct receive_queue *rq, gfp_t gfp)
  * before we're receiving packets, or from refill_work which is
  * careful to disable receiving (using napi_disable).
  */
-static bool try_fill_recv(struct receive_queue *rq, gfp_t gfp)
+static bool try_fill_recv(struct virtnet_info *vi, struct receive_queue *rq,
+			  gfp_t gfp)
 {
-	struct virtnet_info *vi = rq->vq->vdev->priv;
 	int err;
 	bool oom;
 
@@ -677,7 +679,7 @@ static bool try_fill_recv(struct receive_queue *rq, gfp_t gfp)
 		else if (vi->big_packets)
 			err = add_recvbuf_big(rq, gfp);
 		else
-			err = add_recvbuf_small(rq, gfp);
+			err = add_recvbuf_small(vi, rq, gfp);
 
 		oom = err == -ENOMEM;
 		if (err)
@@ -726,7 +728,7 @@ static void refill_work(struct work_struct *work)
 		struct receive_queue *rq = &vi->rq[i];
 
 		napi_disable(&rq->napi);
-		still_empty = !try_fill_recv(rq, GFP_KERNEL);
+		still_empty = !try_fill_recv(vi, rq, GFP_KERNEL);
 		virtnet_napi_enable(rq);
 
 		/* In theory, this can happen: if we don't get any buffers in
@@ -745,12 +747,12 @@ static int virtnet_receive(struct receive_queue *rq, int budget)
 
 	while (received < budget &&
 	       (buf = virtqueue_get_buf(rq->vq, &len)) != NULL) {
-		receive_buf(rq, buf, len);
+		receive_buf(vi, rq, buf, len);
 		received++;
 	}
 
 	if (rq->vq->num_free > virtqueue_get_vring_size(rq->vq) / 2) {
-		if (!try_fill_recv(rq, GFP_ATOMIC))
+		if (!try_fill_recv(vi, rq, GFP_ATOMIC))
 			schedule_delayed_work(&vi->refill, 0);
 	}
 
@@ -826,7 +828,7 @@ static int virtnet_open(struct net_device *dev)
 	for (i = 0; i < vi->max_queue_pairs; i++) {
 		if (i < vi->curr_queue_pairs)
 			/* Make sure we have some buffers: if oom use wq. */
-			if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
+			if (!try_fill_recv(vi, &vi->rq[i], GFP_KERNEL))
 				schedule_delayed_work(&vi->refill, 0);
 		virtnet_napi_enable(&vi->rq[i]);
 	}
@@ -1851,7 +1853,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 
 	/* Last of all, set up some receive buffers. */
 	for (i = 0; i < vi->curr_queue_pairs; i++) {
-		try_fill_recv(&vi->rq[i], GFP_KERNEL);
+		try_fill_recv(vi, &vi->rq[i], GFP_KERNEL);
 
 		/* If we didn't even get one input buffer, we're useless. */
 		if (vi->rq[i].vq->num_free ==
@@ -1971,7 +1973,7 @@ static int virtnet_restore(struct virtio_device *vdev)
 
 	if (netif_running(vi->dev)) {
 		for (i = 0; i < vi->curr_queue_pairs; i++)
-			if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
+			if (!try_fill_recv(vi, &vi->rq[i], GFP_KERNEL))
 				schedule_delayed_work(&vi->refill, 0);
 
 		for (i = 0; i < vi->max_queue_pairs; i++)
-- 
MST
