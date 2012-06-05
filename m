From: Jason Wang <jasowang@redhat.com>
Subject: [net-next RFC PATCH] virtio_net: collect satistics and export
	through ethtool
Date: Tue, 05 Jun 2012 16:38:41 +0800
Message-ID: <20120605083841.11878.69056.stgit@amd-6168-8-1.englab.nay.redhat.com>
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

Satistics counters is useful for debugging and performance optimization, so this
patch lets virtio_net driver collect following and export them to userspace
through "ethtool -S":

- number of packets sent/received
- number of bytes sent/received
- number of callbacks for tx/rx
- number of kick for tx/rx
- number of bytes/packets queued for tx

As virtnet_stats were per-cpu, so both per-cpu and gloabl satistics were exposed
like:

NIC statistics:
     tx_bytes[0]: 2551
     tx_packets[0]: 12
     tx_kick[0]: 12
     tx_callbacks[0]: 1
     tx_queued_packets[0]: 12
     tx_queued_bytes[0]: 3055
     rx_bytes[0]: 0
     rx_packets[0]: 0
     rx_kick[0]: 0
     rx_callbacks[0]: 0
     tx_bytes[1]: 5575
     tx_packets[1]: 37
     tx_kick[1]: 38
     tx_callbacks[1]: 0
     tx_queued_packets[1]: 38
     tx_queued_bytes[1]: 5217
     rx_bytes[1]: 4175
     rx_packets[1]: 25
     rx_kick[1]: 1
     rx_callbacks[1]: 16
     tx_bytes: 8126
     tx_packets: 49
     tx_kick: 50
     tx_callbacks: 1
     tx_queued_packets: 50
     tx_queued_bytes: 8272
     rx_bytes: 4175
     rx_packets: 25
     rx_kick: 1
     rx_callbacks: 16

TODO:

- more satistics
- unitfy the ndo_get_stats64 and get_ethtool_stats
- calculate the pending bytes/pkts

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c |  130 +++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 127 insertions(+), 3 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 5214b1e..7ab0cc1 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -41,6 +41,10 @@ module_param(gso, bool, 0444);
 #define VIRTNET_SEND_COMMAND_SG_MAX    2
 #define VIRTNET_DRIVER_VERSION "1.0.0"
 
+#define VIRTNET_STAT_OFF(m) offsetof(struct virtnet_stats, m)
+#define VIRTNET_STAT(stat, i) (*((u64 *)((char *)stat + \
+			       virtnet_stats_str_attr[i].stat_offset)))
+
 struct virtnet_stats {
 	struct u64_stats_sync syncp;
 	u64 tx_bytes;
@@ -48,8 +52,33 @@ struct virtnet_stats {
 
 	u64 rx_bytes;
 	u64 rx_packets;
+
+	u64 tx_kick;
+	u64 rx_kick;
+	u64 tx_callbacks;
+	u64 rx_callbacks;
+	u64 tx_queued_packets;
+	u64 tx_queued_bytes;
+};
+
+static struct {
+	char string[ETH_GSTRING_LEN];
+	int stat_offset;
+} virtnet_stats_str_attr[] = {
+	{ "tx_bytes", VIRTNET_STAT_OFF(tx_bytes)},
+	{ "tx_packets", VIRTNET_STAT_OFF(tx_packets)},
+	{ "tx_kick", VIRTNET_STAT_OFF(tx_kick)},
+	{ "tx_callbacks", VIRTNET_STAT_OFF(tx_callbacks)},
+	{ "tx_queued_packets", VIRTNET_STAT_OFF(tx_queued_packets)},
+	{ "tx_queued_bytes", VIRTNET_STAT_OFF(tx_queued_bytes)},
+	{ "rx_bytes" , VIRTNET_STAT_OFF(rx_bytes)},
+	{ "rx_packets", VIRTNET_STAT_OFF(rx_packets)},
+	{ "rx_kick", VIRTNET_STAT_OFF(rx_kick)},
+	{ "rx_callbacks", VIRTNET_STAT_OFF(rx_callbacks)},
 };
 
+#define VIRTNET_NUM_STATS ARRAY_SIZE(virtnet_stats_str_attr)
+
 struct virtnet_info {
 	struct virtio_device *vdev;
 	struct virtqueue *rvq, *svq, *cvq;
@@ -142,6 +171,11 @@ static struct page *get_a_page(struct virtnet_info *vi, gfp_t gfp_mask)
 static void skb_xmit_done(struct virtqueue *svq)
 {
 	struct virtnet_info *vi = svq->vdev->priv;
+	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
+
+	u64_stats_update_begin(&stats->syncp);
+	stats->tx_callbacks++;
+	u64_stats_update_end(&stats->syncp);
 
 	/* Suppress further interrupts. */
 	virtqueue_disable_cb(svq);
@@ -461,6 +495,7 @@ static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
 {
 	int err;
 	bool oom;
+	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
 
 	do {
 		if (vi->mergeable_rx_bufs)
@@ -477,13 +512,24 @@ static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
 	} while (err > 0);
 	if (unlikely(vi->num > vi->max))
 		vi->max = vi->num;
-	virtqueue_kick(vi->rvq);
+	if (virtqueue_kick_prepare(vi->rvq)) {
+		virtqueue_notify(vi->rvq);
+		u64_stats_update_begin(&stats->syncp);
+		stats->rx_kick++;
+		u64_stats_update_end(&stats->syncp);
+	}
 	return !oom;
 }
 
 static void skb_recv_done(struct virtqueue *rvq)
 {
 	struct virtnet_info *vi = rvq->vdev->priv;
+	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
+
+	u64_stats_update_begin(&stats->syncp);
+	stats->rx_callbacks++;
+	u64_stats_update_end(&stats->syncp);
+
 	/* Schedule NAPI, Suppress further interrupts if successful. */
 	if (napi_schedule_prep(&vi->napi)) {
 		virtqueue_disable_cb(rvq);
@@ -626,7 +672,9 @@ static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
 static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
+	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
 	int capacity;
+	bool kick;
 
 	/* Free up any pending old buffers before queueing new ones. */
 	free_old_xmit_skbs(vi);
@@ -651,7 +699,17 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 		kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
-	virtqueue_kick(vi->svq);
+
+	kick = virtqueue_kick_prepare(vi->svq);
+	if (kick)
+		virtqueue_notify(vi->svq);
+
+	u64_stats_update_begin(&stats->syncp);
+	if (kick)
+		stats->tx_kick++;
+	stats->tx_queued_bytes += skb->len;
+	stats->tx_queued_packets++;
+	u64_stats_update_end(&stats->syncp);
 
 	/* Don't wait up for transmitted skbs to be freed. */
 	skb_orphan(skb);
@@ -926,7 +984,6 @@ static void virtnet_get_ringparam(struct net_device *dev,
 
 }
 
-
 static void virtnet_get_drvinfo(struct net_device *dev,
 				struct ethtool_drvinfo *info)
 {
@@ -939,10 +996,77 @@ static void virtnet_get_drvinfo(struct net_device *dev,
 
 }
 
+static void virtnet_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
+{
+	int i, cpu;
+	switch (stringset) {
+	case ETH_SS_STATS:
+		for_each_possible_cpu(cpu)
+			for (i = 0; i < VIRTNET_NUM_STATS; i++) {
+				sprintf(buf, "%s[%u]",
+					virtnet_stats_str_attr[i].string, cpu);
+				buf += ETH_GSTRING_LEN;
+			}
+		for (i = 0; i < VIRTNET_NUM_STATS; i++) {
+			memcpy(buf, virtnet_stats_str_attr[i].string,
+				ETH_GSTRING_LEN);
+			buf += ETH_GSTRING_LEN;
+		}
+		break;
+	}
+}
+
+static int virtnet_get_sset_count(struct net_device *dev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return VIRTNET_NUM_STATS * (num_online_cpus() + 1);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static void virtnet_get_ethtool_stats(struct net_device *dev,
+				struct ethtool_stats *stats, u64 *buf)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	int cpu, i;
+	unsigned int start;
+	struct virtnet_stats sample, total;
+
+	memset(&total, 0, sizeof(total));
+	memset(&sample, 0, sizeof(sample));
+
+	for_each_possible_cpu(cpu) {
+		struct virtnet_stats *stats = per_cpu_ptr(vi->stats, cpu);
+		do {
+			start = u64_stats_fetch_begin(&stats->syncp);
+			for (i = 0; i < VIRTNET_NUM_STATS; i++) {
+				VIRTNET_STAT(&sample, i) =
+					VIRTNET_STAT(stats, i);
+
+			}
+		} while (u64_stats_fetch_retry(&stats->syncp, start));
+		for (i = 0; i < VIRTNET_NUM_STATS; i++) {
+			*buf = VIRTNET_STAT(&sample, i);
+			VIRTNET_STAT(&total, i) += VIRTNET_STAT(stats, i);
+			buf++;
+		}
+	}
+
+	for (i = 0; i < VIRTNET_NUM_STATS; i++) {
+		*buf = VIRTNET_STAT(&total, i);
+		buf++;
+	}
+}
+
 static const struct ethtool_ops virtnet_ethtool_ops = {
 	.get_drvinfo = virtnet_get_drvinfo,
 	.get_link = ethtool_op_get_link,
 	.get_ringparam = virtnet_get_ringparam,
+	.get_ethtool_stats = virtnet_get_ethtool_stats,
+	.get_strings = virtnet_get_strings,
+	.get_sset_count = virtnet_get_sset_count,
 };
 
 #define MIN_MTU 68
