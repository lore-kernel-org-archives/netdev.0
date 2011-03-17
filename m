From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH 2/2] virtio_net: remove send completion interrupts and
 avoid TX queue overrun through packet drop
Date: Wed, 16 Mar 2011 17:12:55 -0700
Message-ID: <1300320775.3255.34.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:46976 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751048Ab1CQANE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2011 20:13:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Shirley Ma <xma@us.ibm.com>
---
 drivers/net/virtio_net.c |   39 ++++++++++++++++++++-------------------
 1 files changed, 20 insertions(+), 19 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 82dba5a..c603daa 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -23,6 +23,7 @@
 #include <linux/module.h>
 #include <linux/virtio.h>
 #include <linux/virtio_net.h>
+#include <linux/virtio_ring.h>
 #include <linux/scatterlist.h>
 #include <linux/if_vlan.h>
 #include <linux/slab.h>
@@ -509,19 +510,18 @@ again:
 	return received;
 }
 
-static unsigned int free_old_xmit_skbs(struct virtnet_info *vi)
+static void free_old_xmit_skbs(struct virtnet_info *vi)
 {
 	struct sk_buff *skb;
-	unsigned int len, tot_sgs = 0;
+	unsigned int len;
 
 	while ((skb = virtqueue_get_buf(vi->svq, &len)) != NULL) {
 		pr_debug("Sent skb %p\n", skb);
 		vi->dev->stats.tx_bytes += skb->len;
 		vi->dev->stats.tx_packets++;
-		tot_sgs += skb_vnet_hdr(skb)->num_sg;
 		dev_kfree_skb_any(skb);
 	}
-	return tot_sgs;
+	return;
 }
 
 static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
@@ -574,11 +574,26 @@ static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
 static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
+	bool drop;
+	bool indirect = virtio_has_feature(vi->vdev,
+					   VIRTIO_RING_F_INDIRECT_DESC);
 	int capacity;
 
 	/* Free up any pending old buffers before queueing new ones. */
 	free_old_xmit_skbs(vi);
-
+	capacity = virtqueue_get_capacity(vi->svq);
+
+	/* Drop packet instead of stop queue for better performance */
+	drop = (capacity == 0 && indirect) ||
+	       ((capacity < MAX_SKB_FRAGS + 2) && !indirect);
+	if (unlikely(drop)) {
+		dev->stats.tx_fifo_errors++;
+		dev_warn(&dev->dev, "Unexpected TX queue failure: %d\n",
+			 capacity);
+		dev->stats.tx_dropped++;
+		kfree_skb(skb);
+		return NETDEV_TX_OK;
+	}
 	/* Try to transmit */
 	capacity = xmit_skb(vi, skb);
 
@@ -605,20 +620,6 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
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
 


