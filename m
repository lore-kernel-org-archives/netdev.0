From: Jason Wang <jasowang@redhat.com>
Subject: [RFC V7 PATCH 5/7] virtio_net: enable tx interrupt
Date: Mon, 25 May 2015 01:24:02 -0400
Message-ID: <1432531444-50193-6-git-send-email-jasowang@redhat.com>
References: <1432531444-50193-1-git-send-email-jasowang@redhat.com>
Cc: rusty@rustcorp.com.au, Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432531444-50193-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch enable tx interrupt for virtio-net driver. This can make
socket accounting works again and help to reduce the buffer bloat. To
reduce the performance impacts, only enable tx interrupt on newer host
with interrupt coalescing support.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c | 214 ++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 164 insertions(+), 50 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 4ad739f..a48b1f9 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -72,6 +72,8 @@ struct send_queue {
 
 	/* Name of the send queue: output.$index */
 	char name[40];
+
+	struct napi_struct napi;
 };
 
 /* Internal representation of a receive virtqueue */
@@ -123,6 +125,9 @@ struct virtnet_info {
 	/* Host can handle any s/g split between our header and packet data */
 	bool any_header_sg;
 
+	/* Host can coalesce interrupts */
+	bool intr_coalescing;
+
 	/* Packet virtio header size */
 	u8 hdr_len;
 
@@ -215,15 +220,54 @@ static struct page *get_a_page(struct receive_queue *rq, gfp_t gfp_mask)
 	return p;
 }
 
+static unsigned int free_old_xmit_skbs(struct netdev_queue *txq,
+				       struct send_queue *sq, int budget)
+{
+	struct sk_buff *skb;
+	unsigned int len;
+	struct virtnet_info *vi = sq->vq->vdev->priv;
+	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
+	unsigned int packets = 0, bytes = 0;
+
+	while (packets < budget &&
+	       (skb = virtqueue_get_buf(sq->vq, &len)) != NULL) {
+		pr_debug("Sent skb %p\n", skb);
+
+		bytes += skb->len;
+		packets++;
+
+		dev_kfree_skb_any(skb);
+	}
+
+	if (vi->intr_coalescing &&
+	    sq->vq->num_free >= 2 + MAX_SKB_FRAGS)
+		netif_wake_subqueue(vi->dev, vq2txq(sq->vq));
+
+	u64_stats_update_begin(&stats->tx_syncp);
+	stats->tx_bytes += bytes;
+	stats->tx_packets += packets;
+	u64_stats_update_end(&stats->tx_syncp);
+
+	return packets;
+}
+
 static void skb_xmit_done(struct virtqueue *vq)
 {
 	struct virtnet_info *vi = vq->vdev->priv;
+	struct send_queue *sq = &vi->sq[vq2txq(vq)];
 
-	/* Suppress further interrupts. */
-	virtqueue_disable_cb(vq);
+	if (vi->intr_coalescing) {
+		if (napi_schedule_prep(&sq->napi)) {
+			virtqueue_disable_cb(sq->vq);
+			__napi_schedule(&sq->napi);
+		}
+	} else {
+		/* Suppress further interrupts. */
+		virtqueue_disable_cb(vq);
 
-	/* We were probably waiting for more output buffers. */
-	netif_wake_subqueue(vi->dev, vq2txq(vq));
+		/* We were probably waiting for more output buffers. */
+		netif_wake_subqueue(vi->dev, vq2txq(vq));
+	}
 }
 
 static unsigned int mergeable_ctx_to_buf_truesize(unsigned long mrg_ctx)
@@ -775,6 +819,30 @@ static int virtnet_poll(struct napi_struct *napi, int budget)
 	return received;
 }
 
+static int virtnet_poll_tx(struct napi_struct *napi, int budget)
+{
+	struct send_queue *sq =
+		container_of(napi, struct send_queue, napi);
+	struct virtnet_info *vi = sq->vq->vdev->priv;
+	struct netdev_queue *txq = netdev_get_tx_queue(vi->dev, vq2txq(sq->vq));
+	u32 limit = vi->tx_work_limit;
+	unsigned int r, sent;
+
+	__netif_tx_lock(txq, smp_processor_id());
+	sent = free_old_xmit_skbs(txq, sq, limit);
+	if (sent < limit) {
+		r = virtqueue_enable_cb_prepare(sq->vq);
+		napi_complete(napi);
+		if (unlikely(virtqueue_poll(sq->vq, r)) &&
+		    napi_schedule_prep(napi)) {
+			virtqueue_disable_cb(sq->vq);
+			__napi_schedule(napi);
+		}
+	}
+	__netif_tx_unlock(txq);
+	return sent < limit ? 0 : budget;
+}
+
 #ifdef CONFIG_NET_RX_BUSY_POLL
 /* must be called with local_bh_disable()d */
 static int virtnet_busy_poll(struct napi_struct *napi)
@@ -823,40 +891,12 @@ static int virtnet_open(struct net_device *dev)
 			if (!try_fill_recv(vi, &vi->rq[i], GFP_KERNEL))
 				schedule_delayed_work(&vi->refill, 0);
 		virtnet_napi_enable(&vi->rq[i]);
+		napi_enable(&vi->sq[i].napi);
 	}
 
 	return 0;
 }
 
-static void free_old_xmit_skbs(struct send_queue *sq)
-{
-	struct sk_buff *skb;
-	unsigned int len;
-	struct virtnet_info *vi = sq->vq->vdev->priv;
-	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
-	unsigned int packets = 0, bytes = 0;
-
-	while ((skb = virtqueue_get_buf(sq->vq, &len)) != NULL) {
-		pr_debug("Sent skb %p\n", skb);
-
-		bytes += skb->len;
-		packets++;
-
-		dev_kfree_skb_any(skb);
-	}
-
-	/* Avoid overhead when no packets have been processed
-	 * happens when called speculatively from start_xmit.
-	 */
-	if (!packets)
-		return ;
-
-	u64_stats_update_begin(&stats->tx_syncp);
-	stats->tx_bytes += bytes;
-	stats->tx_packets += packets;
-	u64_stats_update_end(&stats->tx_syncp);
-}
-
 static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
 {
 	struct virtio_net_hdr_mrg_rxbuf *hdr;
@@ -921,7 +961,9 @@ static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
 		sg_set_buf(sq->sg, hdr, hdr_len);
 		num_sg = skb_to_sgvec(skb, sq->sg + 1, 0, skb->len) + 1;
 	}
-	return virtqueue_add_outbuf(sq->vq, sq->sg, num_sg, skb, GFP_ATOMIC);
+
+	return virtqueue_add_outbuf(sq->vq, sq->sg, num_sg, skb,
+				    GFP_ATOMIC);
 }
 
 static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
@@ -934,7 +976,7 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 	bool kick = !skb->xmit_more;
 
 	/* Free up any pending old buffers before queueing new ones. */
-	free_old_xmit_skbs(sq);
+	free_old_xmit_skbs(txq, sq, virtqueue_get_vring_size(sq->vq));
 
 	/* timestamp packet in software */
 	skb_tx_timestamp(skb);
@@ -957,21 +999,13 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 	skb_orphan(skb);
 	nf_reset(skb);
 
-	/* If running out of space, stop queue to avoid getting packets that we
-	 * are then unable to transmit.
-	 * An alternative would be to force queuing layer to requeue the skb by
-	 * returning NETDEV_TX_BUSY. However, NETDEV_TX_BUSY should not be
-	 * returned in a normal path of operation: it means that driver is not
-	 * maintaining the TX queue stop/start state properly, and causes
-	 * the stack to do a non-trivial amount of useless work.
-	 * Since most packets only take 1 or 2 ring slots, stopping the queue
-	 * early means 16 slots are typically wasted.
-	 */
+	/* Apparently nice girls don't return TX_BUSY; stop the queue
+	 * before it gets out of hand.  Naturally, this wastes entries. */
 	if (sq->vq->num_free < 2+MAX_SKB_FRAGS) {
 		netif_stop_subqueue(dev, qnum);
 		if (unlikely(!virtqueue_enable_cb_delayed(sq->vq))) {
 			/* More just got used, free them then recheck. */
-			free_old_xmit_skbs(sq);
+			free_old_xmit_skbs(txq, sq, virtqueue_get_vring_size(sq->vq));
 			if (sq->vq->num_free >= 2+MAX_SKB_FRAGS) {
 				netif_start_subqueue(dev, qnum);
 				virtqueue_disable_cb(sq->vq);
@@ -985,6 +1019,50 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+static netdev_tx_t start_xmit_txintr(struct sk_buff *skb, struct net_device *dev)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	int qnum = skb_get_queue_mapping(skb);
+	struct send_queue *sq = &vi->sq[qnum];
+	int err;
+	struct netdev_queue *txq = netdev_get_tx_queue(dev, qnum);
+	bool kick = !skb->xmit_more;
+
+	virtqueue_disable_cb(sq->vq);
+
+	/* timestamp packet in software */
+	skb_tx_timestamp(skb);
+
+	/* Try to transmit */
+	err = xmit_skb(sq, skb);
+
+	/* This should not happen! */
+	if (unlikely(err)) {
+		dev->stats.tx_fifo_errors++;
+		if (net_ratelimit())
+			dev_warn(&dev->dev,
+				 "Unexpected TXQ (%d) queue failure: %d\n", qnum, err);
+		dev->stats.tx_dropped++;
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
+	}
+
+	/* Apparently nice girls don't return TX_BUSY; stop the queue
+	 * before it gets out of hand.  Naturally, this wastes entries. */
+	if (sq->vq->num_free < 2+MAX_SKB_FRAGS)
+		netif_stop_subqueue(dev, qnum);
+
+	if (kick || netif_xmit_stopped(txq)) {
+		virtqueue_kick(sq->vq);
+		if (!virtqueue_enable_cb_delayed(sq->vq) &&
+		    napi_schedule_prep(&sq->napi)) {
+			virtqueue_disable_cb(sq->vq);
+			__napi_schedule(&sq->napi);
+		}
+	}
+	return NETDEV_TX_OK;
+}
+
 /*
  * Send command via the control virtqueue and check status.  Commands
  * supported by the hypervisor, as indicated by feature bits, should
@@ -1159,8 +1237,10 @@ static int virtnet_close(struct net_device *dev)
 	/* Make sure refill_work doesn't re-enable napi! */
 	cancel_delayed_work_sync(&vi->refill);
 
-	for (i = 0; i < vi->max_queue_pairs; i++)
+	for (i = 0; i < vi->max_queue_pairs; i++) {
 		napi_disable(&vi->rq[i].napi);
+		napi_disable(&vi->sq[i].napi);
+	}
 
 	return 0;
 }
@@ -1485,6 +1565,25 @@ static const struct net_device_ops virtnet_netdev = {
 #endif
 };
 
+static const struct net_device_ops virtnet_netdev_txintr = {
+	.ndo_open            = virtnet_open,
+	.ndo_stop   	     = virtnet_close,
+	.ndo_start_xmit      = start_xmit_txintr,
+	.ndo_validate_addr   = eth_validate_addr,
+	.ndo_set_mac_address = virtnet_set_mac_address,
+	.ndo_set_rx_mode     = virtnet_set_rx_mode,
+	.ndo_change_mtu	     = virtnet_change_mtu,
+	.ndo_get_stats64     = virtnet_stats,
+	.ndo_vlan_rx_add_vid = virtnet_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid = virtnet_vlan_rx_kill_vid,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller = virtnet_netpoll,
+#endif
+#ifdef CONFIG_NET_RX_BUSY_POLL
+	.ndo_busy_poll		= virtnet_busy_poll,
+#endif
+};
+
 static void virtnet_config_changed_work(struct work_struct *work)
 {
 	struct virtnet_info *vi =
@@ -1531,6 +1630,7 @@ static void virtnet_free_queues(struct virtnet_info *vi)
 	for (i = 0; i < vi->max_queue_pairs; i++) {
 		napi_hash_del(&vi->rq[i].napi);
 		netif_napi_del(&vi->rq[i].napi);
+		netif_napi_del(&vi->sq[i].napi);
 	}
 
 	kfree(vi->rq);
@@ -1685,6 +1785,8 @@ static int virtnet_alloc_queues(struct virtnet_info *vi)
 		netif_napi_add(vi->dev, &vi->rq[i].napi, virtnet_poll,
 			       napi_weight);
 		napi_hash_add(&vi->rq[i].napi);
+		netif_napi_add(vi->dev, &vi->sq[i].napi, virtnet_poll_tx,
+			       napi_weight);
 
 		sg_init_table(vi->rq[i].sg, ARRAY_SIZE(vi->rq[i].sg));
 		ewma_init(&vi->rq[i].mrg_avg_pkt_len, 1, RECEIVE_AVG_WEIGHT);
@@ -1819,7 +1921,10 @@ static int virtnet_probe(struct virtio_device *vdev)
 
 	/* Set up network device as normal. */
 	dev->priv_flags |= IFF_UNICAST_FLT | IFF_LIVE_ADDR_CHANGE;
-	dev->netdev_ops = &virtnet_netdev;
+	if (virtio_has_feature(vdev, VIRTIO_RING_F_INTR_COALESCING))
+		dev->netdev_ops = &virtnet_netdev_txintr;
+	else
+		dev->netdev_ops = &virtnet_netdev;
 	dev->features = NETIF_F_HIGHDMA;
 
 	dev->ethtool_ops = &virtnet_ethtool_ops;
@@ -1906,6 +2011,9 @@ static int virtnet_probe(struct virtio_device *vdev)
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_VQ))
 		vi->has_cvq = true;
 
+	if (virtio_has_feature(vdev, VIRTIO_RING_F_INTR_COALESCING))
+		vi->intr_coalescing = true;
+
 	if (vi->any_header_sg)
 		dev->needed_headroom = vi->hdr_len;
 
@@ -1918,6 +2026,8 @@ static int virtnet_probe(struct virtio_device *vdev)
 	if (err)
 		goto free_stats;
 
+	vi->tx_work_limit = napi_weight;
+
 #ifdef CONFIG_SYSFS
 	if (vi->mergeable_rx_bufs)
 		dev->sysfs_rx_queue_group = &virtio_net_mrg_rx_group;
@@ -2030,8 +2140,10 @@ static int virtnet_freeze(struct virtio_device *vdev)
 	cancel_delayed_work_sync(&vi->refill);
 
 	if (netif_running(vi->dev)) {
-		for (i = 0; i < vi->max_queue_pairs; i++)
+		for (i = 0; i < vi->max_queue_pairs; i++) {
 			napi_disable(&vi->rq[i].napi);
+			napi_disable(&vi->sq[i].napi);
+		}
 	}
 
 	remove_vq_common(vi);
@@ -2055,8 +2167,10 @@ static int virtnet_restore(struct virtio_device *vdev)
 			if (!try_fill_recv(vi, &vi->rq[i], GFP_KERNEL))
 				schedule_delayed_work(&vi->refill, 0);
 
-		for (i = 0; i < vi->max_queue_pairs; i++)
+		for (i = 0; i < vi->max_queue_pairs; i++) {
 			virtnet_napi_enable(&vi->rq[i]);
+			napi_enable(&vi->sq[i].napi);
+		}
 	}
 
 	netif_device_attach(vi->dev);
-- 
1.8.3.1
