From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH RFC v4 net-next 3/5] virtio-net: optimize free_old_xmit_skbs
	stats
Date: Mon,  1 Dec 2014 18:17:06 +0800
Message-ID: <1417429028-11971-4-git-send-email-jasowang@redhat.com>
References: <1417429028-11971-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pagupta@redhat.com
To: mst@redhat.com, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org, davem@davemloft.net
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1417429028-11971-1-git-send-email-jasowang@redhat.com>
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

We already have counters for sent packets and sent bytes.
Use them to reduce the number of u64_stats_update_begin/end().

Take care not to bother with stats update when called
speculatively.

Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/virtio_net.c | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 0ed24ff..9f420c9 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -230,16 +230,23 @@ static unsigned int free_old_xmit_skbs(struct netdev_queue *txq,
 	       (skb = virtqueue_get_buf(sq->vq, &len)) != NULL) {
 		pr_debug("Sent skb %p\n", skb);
 
-		u64_stats_update_begin(&stats->tx_syncp);
-		stats->tx_bytes += skb->len;
 		bytes += skb->len;
-		stats->tx_packets++;
-		u64_stats_update_end(&stats->tx_syncp);
+		packets++;
 
 		dev_kfree_skb_any(skb);
-		packets++;
 	}
 
+	/* Avoid overhead when no packets have been processed
+	 * happens when called speculatively from start_xmit.
+	 */
+	if (!packets)
+		return 0;
+
+	u64_stats_update_begin(&stats->tx_syncp);
+	stats->tx_bytes += bytes;
+	stats->tx_packets += packets;
+	u64_stats_update_end(&stats->tx_syncp);
+
 	netdev_tx_completed_queue(txq, packets, bytes);
 
 	if (sq->vq->num_free >= 2+MAX_SKB_FRAGS)
-- 
1.8.3.1
