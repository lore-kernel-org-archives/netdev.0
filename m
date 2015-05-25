From: Jason Wang <jasowang@redhat.com>
Subject: [RFC V7 PATCH 3/7] virtio-net: optimize free_old_xmit_skbs stats
Date: Mon, 25 May 2015 01:24:00 -0400
Message-ID: <1432531444-50193-4-git-send-email-jasowang@redhat.com>
References: <1432531444-50193-1-git-send-email-jasowang@redhat.com>
Cc: rusty@rustcorp.com.au, Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432531444-50193-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We already have counters for sent packets and sent bytes.
Use them to reduce the number of u64_stats_update_begin/end().

Take care not to bother with stats update when called
speculatively.

Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/virtio_net.c | 18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 63c7810..744f0b1 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -826,17 +826,27 @@ static void free_old_xmit_skbs(struct send_queue *sq)
 	unsigned int len;
 	struct virtnet_info *vi = sq->vq->vdev->priv;
 	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
+	unsigned int packets = 0, bytes = 0;
 
 	while ((skb = virtqueue_get_buf(sq->vq, &len)) != NULL) {
 		pr_debug("Sent skb %p\n", skb);
 
-		u64_stats_update_begin(&stats->tx_syncp);
-		stats->tx_bytes += skb->len;
-		stats->tx_packets++;
-		u64_stats_update_end(&stats->tx_syncp);
+		bytes += skb->len;
+		packets++;
 
 		dev_kfree_skb_any(skb);
 	}
+
+	/* Avoid overhead when no packets have been processed
+	 * happens when called speculatively from start_xmit.
+	 */
+	if (!packets)
+		return ;
+
+	u64_stats_update_begin(&stats->tx_syncp);
+	stats->tx_bytes += bytes;
+	stats->tx_packets += packets;
+	u64_stats_update_end(&stats->tx_syncp);
 }
 
 static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
-- 
1.8.3.1
