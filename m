From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH RFC v3 2/3] virtio_net: bql
Date: Mon, 20 Oct 2014 09:52:37 +0300
Message-ID: <1413787824-16130-3-git-send-email-mst@redhat.com>
References: <1413787824-16130-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1413787824-16130-1-git-send-email-mst@redhat.com>
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

Improve tx batching using byte queue limits.
Should be especially effective for MQ.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/virtio_net.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 14f4cda..b83d39d 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -227,6 +227,7 @@ static unsigned int free_old_xmit_skbs(struct netdev_queue *txq,
 	struct virtnet_info *vi = sq->vq->vdev->priv;
 	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
 	unsigned int packets = 0;
+	unsigned int bytes = 0;
 
 	while (packets < budget &&
 	       (skb = virtqueue_get_buf(sq->vq, &len)) != NULL) {
@@ -234,6 +235,7 @@ static unsigned int free_old_xmit_skbs(struct netdev_queue *txq,
 
 		u64_stats_update_begin(&stats->tx_syncp);
 		stats->tx_bytes += skb->len;
+		bytes += skb->len;
 		stats->tx_packets++;
 		u64_stats_update_end(&stats->tx_syncp);
 
@@ -241,6 +243,8 @@ static unsigned int free_old_xmit_skbs(struct netdev_queue *txq,
 		packets++;
 	}
 
+	netdev_tx_completed_queue(txq, packets, bytes);
+
 	if (sq->vq->num_free >= 2+MAX_SKB_FRAGS)
 		netif_tx_start_queue(txq);
 
@@ -959,6 +963,7 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 	int err;
 	struct netdev_queue *txq = netdev_get_tx_queue(dev, qnum);
 	bool kick = !skb->xmit_more;
+	unsigned int bytes = skb->len;
 
 	virtqueue_disable_cb(sq->vq);
 
@@ -976,6 +981,8 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_OK;
 	}
 
+	netdev_tx_sent_queue(txq, bytes);
+
 	/* Apparently nice girls don't return TX_BUSY; stop the queue
 	 * before it gets out of hand.  Naturally, this wastes entries. */
 	if (sq->vq->num_free < 2+MAX_SKB_FRAGS)
-- 
MST
