From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 3/4] [RFC] virtio-net: Changes to virtio-net driver
Date: Wed, 04 May 2011 19:33:32 +0530
Message-ID: <20110504140332.14817.91910.sendpatchset@krkumar2.in.ibm.com>
References: <20110504140258.14817.66596.sendpatchset@krkumar2.in.ibm.com>
Cc: eric.dumazet@gmail.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, rusty@rustcorp.com.au,
	Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110504140258.14817.66596.sendpatchset@krkumar2.in.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changes:

1. Remove xmit notification
2. free_old_xmit_skbs() frees upto a limit to reduce tx jitter.
3. xmit_skb() precalculates the number of slots and checks if
   that is available. It assumes that we are not using
   indirect descriptors at this time.
4. start_xmit() becomes a small routine that removes most error
   checks, does not drop packets but instead returns EBUSY if
   there is no space to transmit. It also sets when to restart
   xmits in future.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 drivers/net/virtio_net.c |   70 ++++++++++---------------------------
 1 file changed, 20 insertions(+), 50 deletions(-)

diff -ruNp org/drivers/net/virtio_net.c new/drivers/net/virtio_net.c
--- org/drivers/net/virtio_net.c	2011-05-04 18:57:06.000000000 +0530
+++ new/drivers/net/virtio_net.c	2011-05-04 18:57:09.000000000 +0530
@@ -117,17 +117,6 @@ static struct page *get_a_page(struct vi
 	return p;
 }
 
-static void skb_xmit_done(struct virtqueue *svq)
-{
-	struct virtnet_info *vi = svq->vdev->priv;
-
-	/* Suppress further interrupts. */
-	virtqueue_disable_cb(svq);
-
-	/* We were probably waiting for more output buffers. */
-	netif_wake_queue(vi->dev);
-}
-
 static void set_skb_frag(struct sk_buff *skb, struct page *page,
 			 unsigned int offset, unsigned int *len)
 {
@@ -509,19 +498,18 @@ again:
 	return received;
 }
 
-static unsigned int free_old_xmit_skbs(struct virtnet_info *vi)
+static inline void free_old_xmit_skbs(struct virtnet_info *vi)
 {
 	struct sk_buff *skb;
-	unsigned int len, tot_sgs = 0;
+	unsigned int count = 0, len;
 
-	while ((skb = virtqueue_get_buf(vi->svq, &len)) != NULL) {
+	while (count++ < MAX_SKB_FRAGS+2 &&
+	       (skb = virtqueue_get_buf(vi->svq, &len)) != NULL) {
 		pr_debug("Sent skb %p\n", skb);
 		vi->dev->stats.tx_bytes += skb->len;
 		vi->dev->stats.tx_packets++;
-		tot_sgs += skb_vnet_hdr(skb)->num_sg;
 		dev_kfree_skb_any(skb);
 	}
-	return tot_sgs;
 }
 
 static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
@@ -531,6 +519,12 @@ static int xmit_skb(struct virtnet_info 
 
 	pr_debug("%s: xmit %p %pM\n", vi->dev->name, skb, dest);
 
+	hdr->num_sg = skb_to_sgvec(skb, vi->tx_sg + 1, 0, skb->len) + 1;
+	if (unlikely(hdr->num_sg > virtqueue_get_capacity(vi->svq))) {
+		/* Don't rely on indirect descriptors when reaching capacity */
+		return -ENOSPC;
+	}
+
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		hdr->hdr.flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
 		hdr->hdr.csum_start = skb_checksum_start_offset(skb);
@@ -566,7 +560,6 @@ static int xmit_skb(struct virtnet_info 
 	else
 		sg_set_buf(vi->tx_sg, &hdr->hdr, sizeof hdr->hdr);
 
-	hdr->num_sg = skb_to_sgvec(skb, vi->tx_sg + 1, 0, skb->len) + 1;
 	return virtqueue_add_buf(vi->svq, vi->tx_sg, hdr->num_sg,
 					0, skb);
 }
@@ -574,30 +567,21 @@ static int xmit_skb(struct virtnet_info 
 static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
-	int capacity;
 
 	/* Free up any pending old buffers before queueing new ones. */
 	free_old_xmit_skbs(vi);
 
 	/* Try to transmit */
-	capacity = xmit_skb(vi, skb);
+	if (unlikely(xmit_skb(vi, skb) < 0)) {
+		struct netdev_queue *txq;
 
-	/* This can happen with OOM and indirect buffers. */
-	if (unlikely(capacity < 0)) {
-		if (net_ratelimit()) {
-			if (likely(capacity == -ENOMEM)) {
-				dev_warn(&dev->dev,
-					 "TX queue failure: out of memory\n");
-			} else {
-				dev->stats.tx_fifo_errors++;
-				dev_warn(&dev->dev,
-					 "Unexpected TX queue failure: %d\n",
-					 capacity);
-			}
-		}
-		dev->stats.tx_dropped++;
-		kfree_skb(skb);
-		return NETDEV_TX_OK;
+		/*
+		 * Tell kernel to restart xmits after 1 jiffy to help the
+		 * host catch up.
+		 */
+		txq = netdev_get_tx_queue(dev, 0);
+		txq->xmit_restart_jiffies = jiffies + 1;
+		return NETDEV_TX_BUSY;
 	}
 	virtqueue_kick(vi->svq);
 
@@ -605,20 +589,6 @@ static netdev_tx_t start_xmit(struct sk_
 	skb_orphan(skb);
 	nf_reset(skb);
 
-	/* Apparently nice girls don't return TX_BUSY; stop the queue
-	 * before it gets out of hand.  Naturally, this wastes entries. */
-	if (capacity < 2+MAX_SKB_FRAGS) {
-		netif_stop_queue(dev);
-		if (unlikely(!virtqueue_enable_cb(vi->svq))) {
-			/* More just got used, free them then recheck. */
-			capacity += free_old_xmit_skbs(vi);
-			if (capacity >= 2+MAX_SKB_FRAGS) {
-				netif_start_queue(dev);
-				virtqueue_disable_cb(vi->svq);
-			}
-		}
-	}
-
 	return NETDEV_TX_OK;
 }
 
@@ -881,7 +851,7 @@ static int virtnet_probe(struct virtio_d
 	struct net_device *dev;
 	struct virtnet_info *vi;
 	struct virtqueue *vqs[3];
-	vq_callback_t *callbacks[] = { skb_recv_done, skb_xmit_done, NULL};
+	vq_callback_t *callbacks[] = { skb_recv_done, NULL, NULL};
 	const char *names[] = { "input", "output", "control" };
 	int nvqs;
 
