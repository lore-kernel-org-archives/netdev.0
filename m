From: Jason Wang <jasowang@redhat.com>
Subject: [RFC V7 PATCH 4/7] virtio-net: add basic interrupt coalescing support
Date: Mon, 25 May 2015 01:24:01 -0400
Message-ID: <1432531444-50193-5-git-send-email-jasowang@redhat.com>
References: <1432531444-50193-1-git-send-email-jasowang@redhat.com>
Cc: rusty@rustcorp.com.au, Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432531444-50193-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch enables the interrupt coalescing setting through ethtool.

Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c         | 62 ++++++++++++++++++++++++++++++++++++++++
 drivers/virtio/virtio_ring.c     |  2 ++
 include/uapi/linux/virtio_ring.h |  1 +
 3 files changed, 65 insertions(+)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 744f0b1..4ad739f 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -140,6 +140,14 @@ struct virtnet_info {
 
 	/* CPU hot plug notifier */
 	struct notifier_block nb;
+
+	/* Budget for polling tx completion */
+	u32 tx_work_limit;
+
+	__u32 rx_coalesce_usecs;
+	__u32 rx_max_coalesced_frames;
+	__u32 tx_coalesce_usecs;
+	__u32 tx_max_coalesced_frames;
 };
 
 struct padded_vnet_hdr {
@@ -1384,6 +1392,58 @@ static void virtnet_get_channels(struct net_device *dev,
 	channels->other_count = 0;
 }
 
+static int virtnet_set_coalesce(struct net_device *dev,
+				struct ethtool_coalesce *ec)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	int i;
+
+	if (!vi->vdev->config->set_coalesce) {
+		dev_warn(&dev->dev, "Transport does not support coalescing.\n");
+		return -EINVAL;
+	}
+
+	if (vi->rx_coalesce_usecs != ec->rx_coalesce_usecs ||
+	    vi->rx_max_coalesced_frames != ec->rx_max_coalesced_frames) {
+		for (i = 0; i < vi->max_queue_pairs; i++) {
+			vi->vdev->config->set_coalesce(vi->vdev, rxq2vq(i),
+						ec->rx_max_coalesced_frames,
+						ec->rx_coalesce_usecs);
+		}
+		vi->rx_coalesce_usecs = ec->rx_coalesce_usecs;
+		vi->rx_max_coalesced_frames = ec->rx_max_coalesced_frames;
+	}
+
+	if (vi->tx_coalesce_usecs != ec->tx_coalesce_usecs ||
+	    vi->tx_max_coalesced_frames != ec->tx_max_coalesced_frames) {
+		for (i = 0; i < vi->max_queue_pairs; i++) {
+			vi->vdev->config->set_coalesce(vi->vdev, txq2vq(i),
+						ec->tx_max_coalesced_frames,
+						ec->tx_coalesce_usecs);
+		}
+		vi->tx_coalesce_usecs = ec->tx_coalesce_usecs;
+		vi->tx_max_coalesced_frames = ec->tx_max_coalesced_frames;
+	}
+
+	vi->tx_work_limit = ec->tx_max_coalesced_frames_irq;
+
+	return 0;
+}
+
+static int virtnet_get_coalesce(struct net_device *dev,
+				struct ethtool_coalesce *ec)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+
+	ec->rx_coalesce_usecs = vi->rx_coalesce_usecs;
+	ec->rx_max_coalesced_frames = vi->rx_max_coalesced_frames;
+	ec->tx_coalesce_usecs = vi->tx_coalesce_usecs;
+	ec->tx_max_coalesced_frames = vi->tx_max_coalesced_frames;
+	ec->tx_max_coalesced_frames_irq = vi->tx_work_limit;
+
+	return 0;
+}
+
 static const struct ethtool_ops virtnet_ethtool_ops = {
 	.get_drvinfo = virtnet_get_drvinfo,
 	.get_link = ethtool_op_get_link,
@@ -1391,6 +1451,8 @@ static const struct ethtool_ops virtnet_ethtool_ops = {
 	.set_channels = virtnet_set_channels,
 	.get_channels = virtnet_get_channels,
 	.get_ts_info = ethtool_op_get_ts_info,
+	.set_coalesce = virtnet_set_coalesce,
+	.get_coalesce = virtnet_get_coalesce,
 };
 
 #define MIN_MTU 68
diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index a83aebc..a2cdbe3 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -780,6 +780,8 @@ void vring_transport_features(struct virtio_device *vdev)
 			break;
 		case VIRTIO_RING_F_EVENT_IDX:
 			break;
+		case VIRTIO_RING_F_INTR_COALESCING:
+			break;
 		case VIRTIO_F_VERSION_1:
 			break;
 		default:
diff --git a/include/uapi/linux/virtio_ring.h b/include/uapi/linux/virtio_ring.h
index 915980a..e9756d8 100644
--- a/include/uapi/linux/virtio_ring.h
+++ b/include/uapi/linux/virtio_ring.h
@@ -58,6 +58,7 @@
 /* The Host publishes the avail index for which it expects a kick
  * at the end of the used ring. Guest should ignore the used->flags field. */
 #define VIRTIO_RING_F_EVENT_IDX		29
+#define VIRTIO_RING_F_INTR_COALESCING   31
 
 /* Virtio ring descriptors: 16 bytes.  These can chain together via "next". */
 struct vring_desc {
-- 
1.8.3.1
