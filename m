From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 2/2] virtio_net: fix oom handling on tx
Date: Sat, 3 Jul 2010 12:34:01 +1000
Message-ID: <201007031234.01937.rusty@rustcorp.com.au>
References: <201007031232.56510.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:46175 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753062Ab0GCCeG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jul 2010 22:34:06 -0400
In-Reply-To: <201007031232.56510.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

virtio net will never try to overflow the TX ring, so the only reason
add_buf may fail is out of memory. Thus, we can not stop the
device until some request completes - there's no guarantee anything
at all is outstanding.

Make the error message clearer as well: error here does not
indicate queue full.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au> (...and avoid TX_BUSY)
Cc: stable@kernel.org  # .34.x (s/virtqueue_/vi->svq->vq_ops->/)
---
 drivers/net/virtio_net.c |   21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -562,7 +562,6 @@ static netdev_tx_t start_xmit(struct sk_
 	struct virtnet_info *vi = netdev_priv(dev);
 	int capacity;
 
-again:
 	/* Free up any pending old buffers before queueing new ones. */
 	free_old_xmit_skbs(vi);
 
@@ -571,14 +570,20 @@ again:
 
 	/* This can happen with OOM and indirect buffers. */
 	if (unlikely(capacity < 0)) {
-		netif_stop_queue(dev);
-		dev_warn(&dev->dev, "Unexpected full queue\n");
-		if (unlikely(!virtqueue_enable_cb(vi->svq))) {
-			virtqueue_disable_cb(vi->svq);
-			netif_start_queue(dev);
-			goto again;
+		if (net_ratelimit()) {
+			if (likely(capacity == -ENOMEM)) {
+				dev_warn(&dev->dev,
+					 "TX queue failure: out of memory\n");
+			} else {
+				dev->stats.tx_fifo_errors++;
+				dev_warn(&dev->dev,
+					 "Unexpected TX queue failure: %d\n",
+					 capacity);
+			}
 		}
-		return NETDEV_TX_BUSY;
+		dev->stats.tx_dropped++;
+		kfree_skb(skb);
+		return NETDEV_TX_OK;
 	}
 	virtqueue_kick(vi->svq);
 
