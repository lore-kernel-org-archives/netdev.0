From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH for-2.6.35] virtio_net: fix oom handling on tx
Date: Thu, 10 Jun 2010 18:20:41 +0300
Message-ID: <20100610152041.GA3480__19787.0024749593$1276183588$gmane$org@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: virtualization@lists.linux-foundation.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Jiri Pirko <jpirko@redhat.com>, Shirley Ma <xma@us.ibm.com>,
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21634 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751893Ab0FJPZz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jun 2010 11:25:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

virtio net will never try to overflow the TX ring, so the only reason
add_buf may fail is out of memory. Thus, we can not stop the
device until some request completes - there's no guarantee anything
at all is outstanding.

Make the error message clearer as well: error here does not
indicate queue full.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/virtio_net.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 85615a3..e48a06f 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -563,7 +563,6 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct virtnet_info *vi = netdev_priv(dev);
 	int capacity;
 
-again:
 	/* Free up any pending old buffers before queueing new ones. */
 	free_old_xmit_skbs(vi);
 
@@ -572,12 +571,14 @@ again:
 
 	/* This can happen with OOM and indirect buffers. */
 	if (unlikely(capacity < 0)) {
-		netif_stop_queue(dev);
-		dev_warn(&dev->dev, "Unexpected full queue\n");
-		if (unlikely(!virtqueue_enable_cb(vi->svq))) {
-			virtqueue_disable_cb(vi->svq);
-			netif_start_queue(dev);
-			goto again;
+		if (net_ratelimit()) {
+			if (likely(capacity == -ENOMEM))
+				dev_warn(&dev->dev,
+					 "TX queue failure: out of memory\n");
+			else
+				dev_warn(&dev->dev,
+					 "Unexpected TX queue failure: %d\n",
+					 capacity);
 		}
 		return NETDEV_TX_BUSY;
 	}
-- 
1.7.1.12.g42b7f
