From: Jason Wang <jasowang@redhat.com>
Subject: [V2 RFC net-next PATCH 1/2] virtio_net: convert the statistics into
	array
Date: Wed, 06 Jun 2012 15:52:09 +0800
Message-ID: <20120606075208.29081.75284.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, rusty@rustcorp.com.au,
	virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
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

Currently, we store the statistics in the independent fields of virtnet_stats,
this is not scalable when we want to add more counters. As suggested by Michael,
this patch convert it to an array and use the enum as the index to access them.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c |   30 +++++++++++++++++-------------
 1 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 5214b1e..6e4aa6f 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -41,13 +41,17 @@ module_param(gso, bool, 0444);
 #define VIRTNET_SEND_COMMAND_SG_MAX    2
 #define VIRTNET_DRIVER_VERSION "1.0.0"
 
+enum virtnet_stats_type {
+	VIRTNET_TX_BYTES,
+	VIRTNET_TX_PACKETS,
+	VIRTNET_RX_BYTES,
+	VIRTNET_RX_PACKETS,
+	VIRTNET_NUM_STATS,
+};
+
 struct virtnet_stats {
 	struct u64_stats_sync syncp;
-	u64 tx_bytes;
-	u64 tx_packets;
-
-	u64 rx_bytes;
-	u64 rx_packets;
+	u64 data[VIRTNET_NUM_STATS];
 };
 
 struct virtnet_info {
@@ -301,8 +305,8 @@ static void receive_buf(struct net_device *dev, void *buf, unsigned int len)
 	hdr = skb_vnet_hdr(skb);
 
 	u64_stats_update_begin(&stats->syncp);
-	stats->rx_bytes += skb->len;
-	stats->rx_packets++;
+	stats->data[VIRTNET_RX_BYTES] += skb->len;
+	stats->data[VIRTNET_RX_PACKETS]++;
 	u64_stats_update_end(&stats->syncp);
 
 	if (hdr->hdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
@@ -566,8 +570,8 @@ static unsigned int free_old_xmit_skbs(struct virtnet_info *vi)
 		pr_debug("Sent skb %p\n", skb);
 
 		u64_stats_update_begin(&stats->syncp);
-		stats->tx_bytes += skb->len;
-		stats->tx_packets++;
+		stats->data[VIRTNET_TX_BYTES] += skb->len;
+		stats->data[VIRTNET_TX_PACKETS]++;
 		u64_stats_update_end(&stats->syncp);
 
 		tot_sgs += skb_vnet_hdr(skb)->num_sg;
@@ -704,10 +708,10 @@ static struct rtnl_link_stats64 *virtnet_stats(struct net_device *dev,
 
 		do {
 			start = u64_stats_fetch_begin(&stats->syncp);
-			tpackets = stats->tx_packets;
-			tbytes   = stats->tx_bytes;
-			rpackets = stats->rx_packets;
-			rbytes   = stats->rx_bytes;
+			tpackets = stats->data[VIRTNET_TX_PACKETS];
+			tbytes   = stats->data[VIRTNET_TX_BYTES];
+			rpackets = stats->data[VIRTNET_RX_PACKETS];
+			rbytes   = stats->data[VIRTNET_RX_BYTES];
 		} while (u64_stats_fetch_retry(&stats->syncp, start));
 
 		tot->rx_packets += rpackets;
