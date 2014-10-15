From: Jason Wang <jasowang@redhat.com>
Subject: [RFC PATCH net-next 5/6] virtio-net: enable tx interrupt
Date: Wed, 15 Oct 2014 15:25:29 +0800
Message-ID: <1413357930-45302-6-git-send-email-jasowang@redhat.com>
References: <1413357930-45302-1-git-send-email-jasowang@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Jason Wang <jasowang@redhat.com>
To: rusty@rustcorp.com.au, mst@redhat.com,
	virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413357930-45302-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Orphan skb in ndo_start_xmit() breaks socket accounting and packet
queuing. This in fact breaks lots of things such as pktgen and several
TCP optimizations. And also make BQL can't be implemented for
virtio-net.

This patch tries to solve this issue by enabling tx interrupt. To
avoid introducing extra spinlocks, a tx napi was scheduled to free
those packets.

More tx interrupt mitigation method could be used on top.

Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c |  125 +++++++++++++++++++++++++++++++---------------
 1 files changed, 85 insertions(+), 40 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index ccf98f9..2afc2e2 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -72,6 +72,8 @@ struct send_queue {
 
 	/* Name of the send queue: output.$index */
 	char name[40];
+
+	struct napi_struct napi;
 };
 
 /* Internal representation of a receive virtqueue */
@@ -217,15 +219,40 @@ static struct page *get_a_page(struct receive_queue *rq, gfp_t gfp_mask)
 	return p;
 }
 
+static int free_old_xmit_skbs(struct send_queue *sq, int budget)
+{
+	struct sk_buff *skb;
+	unsigned int len;
+	struct virtnet_info *vi = sq->vq->vdev->priv;
+	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
+	u64 tx_bytes = 0, tx_packets = 0;
+
+	while (tx_packets < budget &&
+	       (skb = virtqueue_get_buf(sq->vq, &len)) != NULL) {
+		pr_debug("Sent skb %p\n", skb);
+
+		tx_bytes += skb->len;
+		tx_packets++;
+
+		dev_kfree_skb_any(skb);
+	}
+
+	u64_stats_update_begin(&stats->tx_syncp);
+	stats->tx_bytes += tx_bytes;
+	stats->tx_packets =+ tx_packets;
+	u64_stats_update_end(&stats->tx_syncp);
+
+	return tx_packets;
+}
+
 static void skb_xmit_done(struct virtqueue *vq)
 {
 	struct virtnet_info *vi = vq->vdev->priv;
+	struct send_queue *sq = &vi->sq[vq2txq(vq)];
 
-	/* Suppress further interrupts. */
-	virtqueue_disable_cb(vq);
-
-	/* We were probably waiting for more output buffers. */
-	netif_wake_subqueue(vi->dev, vq2txq(vq));
+	if (napi_schedule_prep(&sq->napi)) {
+		__napi_schedule(&sq->napi);
+	}
 }
 
 static unsigned int mergeable_ctx_to_buf_truesize(unsigned long mrg_ctx)
@@ -774,7 +801,39 @@ again:
 	return received;
 }
 
+static int virtnet_poll_tx(struct napi_struct *napi, int budget)
+{
+	struct send_queue *sq =
+		container_of(napi, struct send_queue, napi);
+	struct virtnet_info *vi = sq->vq->vdev->priv;
+	struct netdev_queue *txq = netdev_get_tx_queue(vi->dev, vq2txq(sq->vq));
+	unsigned int r, sent = 0;
+
+again:
+	__netif_tx_lock(txq, smp_processor_id());
+	virtqueue_disable_cb(sq->vq);
+	sent += free_old_xmit_skbs(sq, budget - sent);
+
+	if (sent < budget) {
+		r = virtqueue_enable_cb_prepare(sq->vq);
+		napi_complete(napi);
+		__netif_tx_unlock(txq);
+		if (unlikely(virtqueue_poll(sq->vq, r)) &&
+		    napi_schedule_prep(napi)) {
+			virtqueue_disable_cb(sq->vq);
+			__napi_schedule(napi);
+			goto again;
+		}
+	} else {
+		__netif_tx_unlock(txq);
+	}
+
+	netif_wake_subqueue(vi->dev, vq2txq(sq->vq));
+	return sent;
+}
+
 #ifdef CONFIG_NET_RX_BUSY_POLL
+
 /* must be called with local_bh_disable()d */
 static int virtnet_busy_poll(struct napi_struct *napi)
 {
@@ -822,36 +881,12 @@ static int virtnet_open(struct net_device *dev)
 			if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
 				schedule_delayed_work(&vi->refill, 0);
 		virtnet_napi_enable(&vi->rq[i]);
+		napi_enable(&vi->sq[i].napi);
 	}
 
 	return 0;
 }
 
-static int free_old_xmit_skbs(struct send_queue *sq)
-{
-	struct sk_buff *skb;
-	unsigned int len;
-	struct virtnet_info *vi = sq->vq->vdev->priv;
-	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
-	u64 tx_bytes = 0, tx_packets = 0;
-
-	while ((skb = virtqueue_get_buf(sq->vq, &len)) != NULL) {
-		pr_debug("Sent skb %p\n", skb);
-
-		tx_bytes += skb->len;
-		tx_packets++;
-
-		dev_kfree_skb_any(skb);
-	}
-
-	u64_stats_update_begin(&stats->tx_syncp);
-	stats->tx_bytes += tx_bytes;
-	stats->tx_packets =+ tx_packets;
-	u64_stats_update_end(&stats->tx_syncp);
-
-	return tx_packets;
-}
-
 static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
 {
 	struct skb_vnet_hdr *hdr;
@@ -917,6 +952,7 @@ static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
 		sg_set_buf(sq->sg, hdr, hdr_len);
 		num_sg = skb_to_sgvec(skb, sq->sg + 1, 0, skb->len) + 1;
 	}
+
 	return virtqueue_add_outbuf(sq->vq, sq->sg, num_sg, skb, GFP_ATOMIC);
 }
 
@@ -925,10 +961,11 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct virtnet_info *vi = netdev_priv(dev);
 	int qnum = skb_get_queue_mapping(skb);
 	struct send_queue *sq = &vi->sq[qnum];
-	int err;
+	int err, qsize = virtqueue_get_vring_size(sq->vq);
 
+	virtqueue_disable_cb(sq->vq);
 	/* Free up any pending old buffers before queueing new ones. */
-	free_old_xmit_skbs(sq);
+	free_old_xmit_skbs(sq, qsize);
 
 	/* Try to transmit */
 	err = xmit_skb(sq, skb);
@@ -944,22 +981,20 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_OK;
 	}
 
-	/* Don't wait up for transmitted skbs to be freed. */
-	skb_orphan(skb);
-	nf_reset(skb);
-
 	/* Apparently nice girls don't return TX_BUSY; stop the queue
 	 * before it gets out of hand.  Naturally, this wastes entries. */
 	if (sq->vq->num_free < 2+MAX_SKB_FRAGS) {
 		netif_stop_subqueue(dev, qnum);
 		if (unlikely(!virtqueue_enable_cb_delayed(sq->vq))) {
 			/* More just got used, free them then recheck. */
-			free_old_xmit_skbs(sq);
+			free_old_xmit_skbs(sq, qsize);
 			if (sq->vq->num_free >= 2+MAX_SKB_FRAGS) {
 				netif_start_subqueue(dev, qnum);
 				virtqueue_disable_cb(sq->vq);
 			}
 		}
+	} else if (virtqueue_enable_cb(sq->vq)) {
+		free_old_xmit_skbs(sq, qsize);
 	}
 
 	if (__netif_subqueue_stopped(dev, qnum) || !skb->xmit_more)
@@ -1141,8 +1176,10 @@ static int virtnet_close(struct net_device *dev)
 	/* Make sure refill_work doesn't re-enable napi! */
 	cancel_delayed_work_sync(&vi->refill);
 
-	for (i = 0; i < vi->max_queue_pairs; i++)
+	for (i = 0; i < vi->max_queue_pairs; i++) {
 		napi_disable(&vi->rq[i].napi);
+		napi_disable(&vi->sq[i].napi);
+	}
 
 	return 0;
 }
@@ -1461,8 +1498,10 @@ static void virtnet_free_queues(struct virtnet_info *vi)
 {
 	int i;
 
-	for (i = 0; i < vi->max_queue_pairs; i++)
+	for (i = 0; i < vi->max_queue_pairs; i++) {
 		netif_napi_del(&vi->rq[i].napi);
+		netif_napi_del(&vi->sq[i].napi);
+	}
 
 	kfree(vi->rq);
 	kfree(vi->sq);
@@ -1616,6 +1655,8 @@ static int virtnet_alloc_queues(struct virtnet_info *vi)
 		netif_napi_add(vi->dev, &vi->rq[i].napi, virtnet_poll,
 			       napi_weight);
 		napi_hash_add(&vi->rq[i].napi);
+		netif_napi_add(vi->dev, &vi->sq[i].napi, virtnet_poll_tx,
+			       napi_weight);
 
 		sg_init_table(vi->rq[i].sg, ARRAY_SIZE(vi->rq[i].sg));
 		ewma_init(&vi->rq[i].mrg_avg_pkt_len, 1, RECEIVE_AVG_WEIGHT);
@@ -1920,8 +1961,10 @@ static int virtnet_freeze(struct virtio_device *vdev)
 	if (netif_running(vi->dev)) {
 		for (i = 0; i < vi->max_queue_pairs; i++) {
 			napi_disable(&vi->rq[i].napi);
+			napi_disable(&vi->sq[i].napi);
 			napi_hash_del(&vi->rq[i].napi);
 			netif_napi_del(&vi->rq[i].napi);
+			netif_napi_del(&vi->sq[i].napi);
 		}
 	}
 
@@ -1946,8 +1989,10 @@ static int virtnet_restore(struct virtio_device *vdev)
 			if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
 				schedule_delayed_work(&vi->refill, 0);
 
-		for (i = 0; i < vi->max_queue_pairs; i++)
+		for (i = 0; i < vi->max_queue_pairs; i++) {
 			virtnet_napi_enable(&vi->rq[i]);
+			napi_enable(&vi->sq[i].napi);
+		}
 	}
 
 	netif_device_attach(vi->dev);
-- 
1.7.1
