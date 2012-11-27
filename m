From: Jason Wang <jasowang@redhat.com>
Subject: [net-next rfc v7 1/3] virtio-net: separate fields of
	sending/receiving queue from virtnet_info
Date: Tue, 27 Nov 2012 18:15:58 +0800
Message-ID: <1354011360-39479-2-git-send-email-jasowang@redhat.com>
References: <1354011360-39479-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jwhan@filewood.snu.ac.kr, shiyer@redhat.com,
	kvm@vger.kernel.org
To: rusty@rustcorp.com.au, mst@redhat.com, krkumar2@in.ibm.com,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1354011360-39479-1-git-send-email-jasowang@redhat.com>
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

To support multiqueue transmitq/receiveq, the first step is to separate queue
related structure from virtnet_info. This patch introduce send_queue and
receive_queue structure and use the pointer to them as the parameter in
functions handling sending/receiving.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c |  289 +++++++++++++++++++++++++---------------------
 1 files changed, 158 insertions(+), 131 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 26c502e..7975133 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -51,16 +51,44 @@ struct virtnet_stats {
 	u64 rx_packets;
 };
 
+/* Internal representation of a send virtqueue */
+struct send_queue {
+	/* Virtqueue associated with this send _queue */
+	struct virtqueue *vq;
+
+	/* TX: fragments + linear part + virtio header */
+	struct scatterlist sg[MAX_SKB_FRAGS + 2];
+};
+
+/* Internal representation of a receive virtqueue */
+struct receive_queue {
+	/* Virtqueue associated with this receive_queue */
+	struct virtqueue *vq;
+
+        struct napi_struct napi;
+
+        /* Number of input buffers, and max we've ever had. */
+        unsigned int num, max;
+
+	/* Work struct for refilling if we run low on memory. */
+	struct delayed_work refill;
+
+	/* Chain pages by the private ptr. */
+	struct page *pages;
+
+	/* RX: fragments + linear part + virtio header */
+	struct scatterlist sg[MAX_SKB_FRAGS + 2];
+};
+
 struct virtnet_info {
 	struct virtio_device *vdev;
-	struct virtqueue *rvq, *svq, *cvq;
+	struct virtqueue *cvq;
 	struct net_device *dev;
 	struct napi_struct napi;
+	struct send_queue sq;
+	struct receive_queue rq;
 	unsigned int status;
 
-	/* Number of input buffers, and max we've ever had. */
-	unsigned int num, max;
-
 	/* I like... big packets and I cannot lie! */
 	bool big_packets;
 
@@ -73,21 +101,11 @@ struct virtnet_info {
 	/* Active statistics */
 	struct virtnet_stats __percpu *stats;
 
-	/* Work struct for refilling if we run low on memory. */
-	struct delayed_work refill;
-
 	/* Work struct for config space updates */
 	struct work_struct config_work;
 
 	/* Lock for config space updates */
 	struct mutex config_lock;
-
-	/* Chain pages by the private ptr. */
-	struct page *pages;
-
-	/* fragments + linear part + virtio header */
-	struct scatterlist rx_sg[MAX_SKB_FRAGS + 2];
-	struct scatterlist tx_sg[MAX_SKB_FRAGS + 2];
 };
 
 struct skb_vnet_hdr {
@@ -117,22 +135,22 @@ static inline struct skb_vnet_hdr *skb_vnet_hdr(struct sk_buff *skb)
  * private is used to chain pages for big packets, put the whole
  * most recent used list in the beginning for reuse
  */
-static void give_pages(struct virtnet_info *vi, struct page *page)
+static void give_pages(struct receive_queue *rq, struct page *page)
 {
 	struct page *end;
 
-	/* Find end of list, sew whole thing into vi->pages. */
+	/* Find end of list, sew whole thing into vi->rq.pages. */
 	for (end = page; end->private; end = (struct page *)end->private);
-	end->private = (unsigned long)vi->pages;
-	vi->pages = page;
+	end->private = (unsigned long)rq->pages;
+	rq->pages = page;
 }
 
-static struct page *get_a_page(struct virtnet_info *vi, gfp_t gfp_mask)
+static struct page *get_a_page(struct receive_queue *rq, gfp_t gfp_mask)
 {
-	struct page *p = vi->pages;
+	struct page *p = rq->pages;
 
 	if (p) {
-		vi->pages = (struct page *)p->private;
+		rq->pages = (struct page *)p->private;
 		/* clear private here, it is used to chain pages */
 		p->private = 0;
 	} else
@@ -140,12 +158,12 @@ static struct page *get_a_page(struct virtnet_info *vi, gfp_t gfp_mask)
 	return p;
 }
 
-static void skb_xmit_done(struct virtqueue *svq)
+static void skb_xmit_done(struct virtqueue *vq)
 {
-	struct virtnet_info *vi = svq->vdev->priv;
+	struct virtnet_info *vi = vq->vdev->priv;
 
 	/* Suppress further interrupts. */
-	virtqueue_disable_cb(svq);
+	virtqueue_disable_cb(vq);
 
 	/* We were probably waiting for more output buffers. */
 	netif_wake_queue(vi->dev);
@@ -167,9 +185,10 @@ static void set_skb_frag(struct sk_buff *skb, struct page *page,
 }
 
 /* Called from bottom half context */
-static struct sk_buff *page_to_skb(struct virtnet_info *vi,
+static struct sk_buff *page_to_skb(struct receive_queue *rq,
 				   struct page *page, unsigned int len)
 {
+	struct virtnet_info *vi = rq->vq->vdev->priv;
 	struct sk_buff *skb;
 	struct skb_vnet_hdr *hdr;
 	unsigned int copy, hdr_len, offset;
@@ -224,12 +243,12 @@ static struct sk_buff *page_to_skb(struct virtnet_info *vi,
 	}
 
 	if (page)
-		give_pages(vi, page);
+		give_pages(rq, page);
 
 	return skb;
 }
 
-static int receive_mergeable(struct virtnet_info *vi, struct sk_buff *skb)
+static int receive_mergeable(struct receive_queue *rq, struct sk_buff *skb)
 {
 	struct skb_vnet_hdr *hdr = skb_vnet_hdr(skb);
 	struct page *page;
@@ -243,7 +262,7 @@ static int receive_mergeable(struct virtnet_info *vi, struct sk_buff *skb)
 			skb->dev->stats.rx_length_errors++;
 			return -EINVAL;
 		}
-		page = virtqueue_get_buf(vi->rvq, &len);
+		page = virtqueue_get_buf(rq->vq, &len);
 		if (!page) {
 			pr_debug("%s: rx error: %d buffers missing\n",
 				 skb->dev->name, hdr->mhdr.num_buffers);
@@ -256,14 +275,15 @@ static int receive_mergeable(struct virtnet_info *vi, struct sk_buff *skb)
 
 		set_skb_frag(skb, page, 0, &len);
 
-		--vi->num;
+		--rq->num;
 	}
 	return 0;
 }
 
-static void receive_buf(struct net_device *dev, void *buf, unsigned int len)
+static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
 {
-	struct virtnet_info *vi = netdev_priv(dev);
+	struct virtnet_info *vi = rq->vq->vdev->priv;
+	struct net_device *dev = vi->dev;
 	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
 	struct sk_buff *skb;
 	struct page *page;
@@ -273,7 +293,7 @@ static void receive_buf(struct net_device *dev, void *buf, unsigned int len)
 		pr_debug("%s: short packet %i\n", dev->name, len);
 		dev->stats.rx_length_errors++;
 		if (vi->mergeable_rx_bufs || vi->big_packets)
-			give_pages(vi, buf);
+			give_pages(rq, buf);
 		else
 			dev_kfree_skb(buf);
 		return;
@@ -285,14 +305,14 @@ static void receive_buf(struct net_device *dev, void *buf, unsigned int len)
 		skb_trim(skb, len);
 	} else {
 		page = buf;
-		skb = page_to_skb(vi, page, len);
+		skb = page_to_skb(rq, page, len);
 		if (unlikely(!skb)) {
 			dev->stats.rx_dropped++;
-			give_pages(vi, page);
+			give_pages(rq, page);
 			return;
 		}
 		if (vi->mergeable_rx_bufs)
-			if (receive_mergeable(vi, skb)) {
+			if (receive_mergeable(rq, skb)) {
 				dev_kfree_skb(skb);
 				return;
 			}
@@ -359,8 +379,9 @@ frame_err:
 	dev_kfree_skb(skb);
 }
 
-static int add_recvbuf_small(struct virtnet_info *vi, gfp_t gfp)
+static int add_recvbuf_small(struct receive_queue *rq, gfp_t gfp)
 {
+	struct virtnet_info *vi = rq->vq->vdev->priv;
 	struct sk_buff *skb;
 	struct skb_vnet_hdr *hdr;
 	int err;
@@ -372,77 +393,77 @@ static int add_recvbuf_small(struct virtnet_info *vi, gfp_t gfp)
 	skb_put(skb, MAX_PACKET_LEN);
 
 	hdr = skb_vnet_hdr(skb);
-	sg_set_buf(vi->rx_sg, &hdr->hdr, sizeof hdr->hdr);
+	sg_set_buf(rq->sg, &hdr->hdr, sizeof hdr->hdr);
 
-	skb_to_sgvec(skb, vi->rx_sg + 1, 0, skb->len);
+	skb_to_sgvec(skb, rq->sg + 1, 0, skb->len);
 
-	err = virtqueue_add_buf(vi->rvq, vi->rx_sg, 0, 2, skb, gfp);
+	err = virtqueue_add_buf(rq->vq, rq->sg, 0, 2, skb, gfp);
 	if (err < 0)
 		dev_kfree_skb(skb);
 
 	return err;
 }
 
-static int add_recvbuf_big(struct virtnet_info *vi, gfp_t gfp)
+static int add_recvbuf_big(struct receive_queue *rq, gfp_t gfp)
 {
 	struct page *first, *list = NULL;
 	char *p;
 	int i, err, offset;
 
-	/* page in vi->rx_sg[MAX_SKB_FRAGS + 1] is list tail */
+	/* page in rq->sg[MAX_SKB_FRAGS + 1] is list tail */
 	for (i = MAX_SKB_FRAGS + 1; i > 1; --i) {
-		first = get_a_page(vi, gfp);
+		first = get_a_page(rq, gfp);
 		if (!first) {
 			if (list)
-				give_pages(vi, list);
+				give_pages(rq, list);
 			return -ENOMEM;
 		}
-		sg_set_buf(&vi->rx_sg[i], page_address(first), PAGE_SIZE);
+		sg_set_buf(&rq->sg[i], page_address(first), PAGE_SIZE);
 
 		/* chain new page in list head to match sg */
 		first->private = (unsigned long)list;
 		list = first;
 	}
 
-	first = get_a_page(vi, gfp);
+	first = get_a_page(rq, gfp);
 	if (!first) {
-		give_pages(vi, list);
+		give_pages(rq, list);
 		return -ENOMEM;
 	}
 	p = page_address(first);
 
-	/* vi->rx_sg[0], vi->rx_sg[1] share the same page */
-	/* a separated vi->rx_sg[0] for virtio_net_hdr only due to QEMU bug */
-	sg_set_buf(&vi->rx_sg[0], p, sizeof(struct virtio_net_hdr));
+	/* rq->sg[0], rq->sg[1] share the same page */
+	/* a separated rq->sg[0] for virtio_net_hdr only due to QEMU bug */
+	sg_set_buf(&rq->sg[0], p, sizeof(struct virtio_net_hdr));
 
-	/* vi->rx_sg[1] for data packet, from offset */
+	/* rq->sg[1] for data packet, from offset */
 	offset = sizeof(struct padded_vnet_hdr);
-	sg_set_buf(&vi->rx_sg[1], p + offset, PAGE_SIZE - offset);
+	sg_set_buf(&rq->sg[1], p + offset, PAGE_SIZE - offset);
 
 	/* chain first in list head */
 	first->private = (unsigned long)list;
-	err = virtqueue_add_buf(vi->rvq, vi->rx_sg, 0, MAX_SKB_FRAGS + 2,
+	err = virtqueue_add_buf(rq->vq, rq->sg, 0, MAX_SKB_FRAGS + 2,
 				first, gfp);
 	if (err < 0)
-		give_pages(vi, first);
+		give_pages(rq, first);
 
 	return err;
 }
 
-static int add_recvbuf_mergeable(struct virtnet_info *vi, gfp_t gfp)
+static int add_recvbuf_mergeable(struct receive_queue *rq, gfp_t gfp)
 {
 	struct page *page;
 	int err;
 
-	page = get_a_page(vi, gfp);
+	page = get_a_page(rq, gfp);
 	if (!page)
 		return -ENOMEM;
 
-	sg_init_one(vi->rx_sg, page_address(page), PAGE_SIZE);
+	sg_init_one(rq->sg, page_address(page), PAGE_SIZE);
 
-	err = virtqueue_add_buf(vi->rvq, vi->rx_sg, 0, 1, page, gfp);
+	err = virtqueue_add_buf(rq->vq, rq->sg, 0, 1, page, gfp);
 	if (err < 0)
-		give_pages(vi, page);
+		give_pages(rq, page);
 
 	return err;
 }
@@ -454,97 +475,101 @@ static int add_recvbuf_mergeable(struct virtnet_info *vi, gfp_t gfp)
  * before we're receiving packets, or from refill_work which is
  * careful to disable receiving (using napi_disable).
  */
-static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
+static bool try_fill_recv(struct receive_queue *rq, gfp_t gfp)
 {
+	struct virtnet_info *vi = rq->vq->vdev->priv;
 	int err;
 	bool oom;
 
 	do {
 		if (vi->mergeable_rx_bufs)
-			err = add_recvbuf_mergeable(vi, gfp);
+			err = add_recvbuf_mergeable(rq, gfp);
 		else if (vi->big_packets)
-			err = add_recvbuf_big(vi, gfp);
+			err = add_recvbuf_big(rq, gfp);
 		else
-			err = add_recvbuf_small(vi, gfp);
+			err = add_recvbuf_small(rq, gfp);
 
 		oom = err == -ENOMEM;
 		if (err < 0)
 			break;
-		++vi->num;
+		++rq->num;
 	} while (err > 0);
-	if (unlikely(vi->num > vi->max))
-		vi->max = vi->num;
-	virtqueue_kick(vi->rvq);
+	if (unlikely(rq->num > rq->max))
+		rq->max = rq->num;
+	virtqueue_kick(rq->vq);
 	return !oom;
 }
 
 static void skb_recv_done(struct virtqueue *rvq)
 {
 	struct virtnet_info *vi = rvq->vdev->priv;
+	struct receive_queue *rq = &vi->rq;
+
 	/* Schedule NAPI, Suppress further interrupts if successful. */
-	if (napi_schedule_prep(&vi->napi)) {
+	if (napi_schedule_prep(&rq->napi)) {
 		virtqueue_disable_cb(rvq);
-		__napi_schedule(&vi->napi);
+		__napi_schedule(&rq->napi);
 	}
 }
 
-static void virtnet_napi_enable(struct virtnet_info *vi)
+static void virtnet_napi_enable(struct receive_queue *rq)
 {
-	napi_enable(&vi->napi);
+	napi_enable(&rq->napi);
 
 	/* If all buffers were filled by other side before we napi_enabled, we
 	 * won't get another interrupt, so process any outstanding packets
 	 * now.  virtnet_poll wants re-enable the queue, so we disable here.
 	 * We synchronize against interrupts via NAPI_STATE_SCHED */
-	if (napi_schedule_prep(&vi->napi)) {
-		virtqueue_disable_cb(vi->rvq);
+	if (napi_schedule_prep(&rq->napi)) {
+		virtqueue_disable_cb(rq->vq);
 		local_bh_disable();
-		__napi_schedule(&vi->napi);
+		__napi_schedule(&rq->napi);
 		local_bh_enable();
 	}
 }
 
 static void refill_work(struct work_struct *work)
 {
-	struct virtnet_info *vi;
+	struct receive_queue *rq =
+		container_of(work, struct receive_queue, refill.work);
 	bool still_empty;
 
-	vi = container_of(work, struct virtnet_info, refill.work);
-	napi_disable(&vi->napi);
-	still_empty = !try_fill_recv(vi, GFP_KERNEL);
-	virtnet_napi_enable(vi);
+	napi_disable(&rq->napi);
+	still_empty = !try_fill_recv(rq, GFP_KERNEL);
+	virtnet_napi_enable(rq);
 
 	/* In theory, this can happen: if we don't get any buffers in
 	 * we will *never* try to fill again. */
 	if (still_empty)
-		schedule_delayed_work(&vi->refill, HZ/2);
+		schedule_delayed_work(&rq->refill, HZ/2);
 }
 
 static int virtnet_poll(struct napi_struct *napi, int budget)
 {
-	struct virtnet_info *vi = container_of(napi, struct virtnet_info, napi);
+	struct receive_queue *rq =
+		container_of(napi, struct receive_queue, napi);
 	void *buf;
 	unsigned int len, received = 0;
 
 again:
 	while (received < budget &&
-	       (buf = virtqueue_get_buf(vi->rvq, &len)) != NULL) {
-		receive_buf(vi->dev, buf, len);
-		--vi->num;
+	       (buf = virtqueue_get_buf(rq->vq, &len)) != NULL) {
+		receive_buf(rq, buf, len);
+		--rq->num;
 		received++;
 	}
 
-	if (vi->num < vi->max / 2) {
-		if (!try_fill_recv(vi, GFP_ATOMIC))
-			schedule_delayed_work(&vi->refill, 0);
+	if (rq->num < rq->max / 2) {
+		if (!try_fill_recv(rq, GFP_ATOMIC))
+			schedule_delayed_work(&rq->refill, 0);
 	}
 
 	/* Out of packets? */
 	if (received < budget) {
 		napi_complete(napi);
-		if (unlikely(!virtqueue_enable_cb(vi->rvq)) &&
+		if (unlikely(!virtqueue_enable_cb(rq->vq)) &&
 		    napi_schedule_prep(napi)) {
-			virtqueue_disable_cb(vi->rvq);
+			virtqueue_disable_cb(rq->vq);
 			__napi_schedule(napi);
 			goto again;
 		}
@@ -553,13 +578,14 @@ again:
 	return received;
 }
 
-static unsigned int free_old_xmit_skbs(struct virtnet_info *vi)
+static unsigned int free_old_xmit_skbs(struct send_queue *sq)
 {
 	struct sk_buff *skb;
 	unsigned int len, tot_sgs = 0;
+	struct virtnet_info *vi = sq->vq->vdev->priv;
 	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
 
-	while ((skb = virtqueue_get_buf(vi->svq, &len)) != NULL) {
+	while ((skb = virtqueue_get_buf(sq->vq, &len)) != NULL) {
 		pr_debug("Sent skb %p\n", skb);
 
 		u64_stats_update_begin(&stats->tx_syncp);
@@ -573,10 +599,11 @@ static unsigned int free_old_xmit_skbs(struct virtnet_info *vi)
 	return tot_sgs;
 }
 
-static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
+static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
 {
 	struct skb_vnet_hdr *hdr = skb_vnet_hdr(skb);
 	const unsigned char *dest = ((struct ethhdr *)skb->data)->h_dest;
+	struct virtnet_info *vi = sq->vq->vdev->priv;
 
 	pr_debug("%s: xmit %p %pM\n", vi->dev->name, skb, dest);
 
@@ -611,25 +638,26 @@ static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
 
 	/* Encode metadata header at front. */
 	if (vi->mergeable_rx_bufs)
-		sg_set_buf(vi->tx_sg, &hdr->mhdr, sizeof hdr->mhdr);
+		sg_set_buf(sq->sg, &hdr->mhdr, sizeof hdr->mhdr);
 	else
-		sg_set_buf(vi->tx_sg, &hdr->hdr, sizeof hdr->hdr);
+		sg_set_buf(sq->sg, &hdr->hdr, sizeof hdr->hdr);
 
-	hdr->num_sg = skb_to_sgvec(skb, vi->tx_sg + 1, 0, skb->len) + 1;
-	return virtqueue_add_buf(vi->svq, vi->tx_sg, hdr->num_sg,
+	hdr->num_sg = skb_to_sgvec(skb, sq->sg + 1, 0, skb->len) + 1;
+	return virtqueue_add_buf(sq->vq, sq->sg, hdr->num_sg,
 				 0, skb, GFP_ATOMIC);
 }
 
 static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
+	struct send_queue *sq = &vi->sq;
 	int capacity;
 
 	/* Free up any pending old buffers before queueing new ones. */
-	free_old_xmit_skbs(vi);
+	free_old_xmit_skbs(sq);
 
 	/* Try to transmit */
-	capacity = xmit_skb(vi, skb);
+	capacity = xmit_skb(sq, skb);
 
 	/* This can happen with OOM and indirect buffers. */
 	if (unlikely(capacity < 0)) {
@@ -648,7 +676,7 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 		kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
-	virtqueue_kick(vi->svq);
+	virtqueue_kick(sq->vq);
 
 	/* Don't wait up for transmitted skbs to be freed. */
 	skb_orphan(skb);
@@ -658,12 +686,12 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * before it gets out of hand.  Naturally, this wastes entries. */
 	if (capacity < 2+MAX_SKB_FRAGS) {
 		netif_stop_queue(dev);
-		if (unlikely(!virtqueue_enable_cb_delayed(vi->svq))) {
+		if (unlikely(!virtqueue_enable_cb_delayed(sq->vq))) {
 			/* More just got used, free them then recheck. */
-			capacity += free_old_xmit_skbs(vi);
+			capacity += free_old_xmit_skbs(sq);
 			if (capacity >= 2+MAX_SKB_FRAGS) {
 				netif_start_queue(dev);
-				virtqueue_disable_cb(vi->svq);
+				virtqueue_disable_cb(sq->vq);
 			}
 		}
 	}
@@ -731,7 +759,7 @@ static void virtnet_netpoll(struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 
-	napi_schedule(&vi->napi);
+	napi_schedule(&vi->rq.napi);
 }
 #endif
 
@@ -740,10 +768,10 @@ static int virtnet_open(struct net_device *dev)
 	struct virtnet_info *vi = netdev_priv(dev);
 
 	/* Make sure we have some buffers: if oom use wq. */
-	if (!try_fill_recv(vi, GFP_KERNEL))
-		schedule_delayed_work(&vi->refill, 0);
+	if (!try_fill_recv(&vi->rq, GFP_KERNEL))
+		schedule_delayed_work(&vi->rq.refill, 0);
 
-	virtnet_napi_enable(vi);
+	virtnet_napi_enable(&vi->rq);
 	return 0;
 }
 
@@ -807,8 +835,8 @@ static int virtnet_close(struct net_device *dev)
 	struct virtnet_info *vi = netdev_priv(dev);
 
 	/* Make sure refill_work doesn't re-enable napi! */
-	cancel_delayed_work_sync(&vi->refill);
-	napi_disable(&vi->napi);
+	cancel_delayed_work_sync(&vi->rq.refill);
+	napi_disable(&vi->rq.napi);
 
 	return 0;
 }
@@ -920,11 +948,10 @@ static void virtnet_get_ringparam(struct net_device *dev,
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 
-	ring->rx_max_pending = virtqueue_get_vring_size(vi->rvq);
-	ring->tx_max_pending = virtqueue_get_vring_size(vi->svq);
+	ring->rx_max_pending = virtqueue_get_vring_size(vi->rq.vq);
+	ring->tx_max_pending = virtqueue_get_vring_size(vi->sq.vq);
 	ring->rx_pending = ring->rx_max_pending;
 	ring->tx_pending = ring->tx_max_pending;
-
 }
 
 
@@ -1034,8 +1061,8 @@ static int init_vqs(struct virtnet_info *vi)
 	if (err)
 		return err;
 
-	vi->rvq = vqs[0];
-	vi->svq = vqs[1];
+	vi->rq.vq = vqs[0];
+	vi->sq.vq = vqs[1];
 
 	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ)) {
 		vi->cvq = vqs[2];
@@ -1099,22 +1126,22 @@ static int virtnet_probe(struct virtio_device *vdev)
 
 	/* Set up our device-specific information */
 	vi = netdev_priv(dev);
-	netif_napi_add(dev, &vi->napi, virtnet_poll, napi_weight);
+	netif_napi_add(dev, &vi->rq.napi, virtnet_poll, napi_weight);
 	vi->dev = dev;
 	vi->vdev = vdev;
 	vdev->priv = vi;
-	vi->pages = NULL;
+	vi->rq.pages = NULL;
 	vi->stats = alloc_percpu(struct virtnet_stats);
 	err = -ENOMEM;
 	if (vi->stats == NULL)
 		goto free;
 
-	INIT_DELAYED_WORK(&vi->refill, refill_work);
+	INIT_DELAYED_WORK(&vi->rq.refill, refill_work);
 	mutex_init(&vi->config_lock);
 	vi->config_enable = true;
 	INIT_WORK(&vi->config_work, virtnet_config_changed_work);
-	sg_init_table(vi->rx_sg, ARRAY_SIZE(vi->rx_sg));
-	sg_init_table(vi->tx_sg, ARRAY_SIZE(vi->tx_sg));
+	sg_init_table(vi->rq.sg, ARRAY_SIZE(vi->rq.sg));
+	sg_init_table(vi->sq.sg, ARRAY_SIZE(vi->sq.sg));
 
 	/* If we can receive ANY GSO packets, we must allocate large ones. */
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO4) ||
@@ -1136,10 +1163,10 @@ static int virtnet_probe(struct virtio_device *vdev)
 	}
 
 	/* Last of all, set up some receive buffers. */
-	try_fill_recv(vi, GFP_KERNEL);
+	try_fill_recv(&vi->rq, GFP_KERNEL);
 
 	/* If we didn't even get one input buffer, we're useless. */
-	if (vi->num == 0) {
+	if (vi->rq.num == 0) {
 		err = -ENOMEM;
 		goto unregister;
 	}
@@ -1172,22 +1199,22 @@ static void free_unused_bufs(struct virtnet_info *vi)
 {
 	void *buf;
 	while (1) {
-		buf = virtqueue_detach_unused_buf(vi->svq);
+		buf = virtqueue_detach_unused_buf(vi->sq.vq);
 		if (!buf)
 			break;
 		dev_kfree_skb(buf);
 	}
 	while (1) {
-		buf = virtqueue_detach_unused_buf(vi->rvq);
+		buf = virtqueue_detach_unused_buf(vi->rq.vq);
 		if (!buf)
 			break;
 		if (vi->mergeable_rx_bufs || vi->big_packets)
-			give_pages(vi, buf);
+			give_pages(&vi->rq, buf);
 		else
 			dev_kfree_skb(buf);
-		--vi->num;
+		--vi->rq.num;
 	}
-	BUG_ON(vi->num != 0);
+	BUG_ON(vi->rq.num != 0);
 }
 
 static void remove_vq_common(struct virtnet_info *vi)
@@ -1199,8 +1226,8 @@ static void remove_vq_common(struct virtnet_info *vi)
 
 	vi->vdev->config->del_vqs(vi->vdev);
 
-	while (vi->pages)
-		__free_pages(get_a_page(vi, GFP_KERNEL), 0);
+	while (vi->rq.pages)
+		__free_pages(get_a_page(&vi->rq, GFP_KERNEL), 0);
 }
 
 static void __devexit virtnet_remove(struct virtio_device *vdev)
@@ -1233,10 +1260,10 @@ static int virtnet_freeze(struct virtio_device *vdev)
 	mutex_unlock(&vi->config_lock);
 
 	netif_device_detach(vi->dev);
-	cancel_delayed_work_sync(&vi->refill);
+	cancel_delayed_work_sync(&vi->rq.refill);
 
 	if (netif_running(vi->dev))
-		napi_disable(&vi->napi);
+		napi_disable(&vi->rq.napi);
 
 	remove_vq_common(vi);
 
@@ -1255,12 +1282,12 @@ static int virtnet_restore(struct virtio_device *vdev)
 		return err;
 
 	if (netif_running(vi->dev))
-		virtnet_napi_enable(vi);
+		virtnet_napi_enable(&vi->rq);
 
 	netif_device_attach(vi->dev);
 
-	if (!try_fill_recv(vi, GFP_KERNEL))
-		schedule_delayed_work(&vi->refill, 0);
+	if (!try_fill_recv(&vi->rq, GFP_KERNEL))
+		schedule_delayed_work(&vi->rq.refill, 0);
 
 	mutex_lock(&vi->config_lock);
 	vi->config_enable = true;
-- 
1.7.1
