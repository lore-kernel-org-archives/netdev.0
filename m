From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v5 1/6] net: virtio dynamically disable/enable LRO
Date: Wed, 07 Dec 2016 12:11:11 -0800
Message-ID: <20161207201111.28121.4879.stgit@john-Precision-Tower-5810>
References: <20161207200139.28121.4811.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com, brouer@redhat.com
To: daniel@iogearbox.net, mst@redhat.com, shm@cumulusnetworks.com,
        davem@davemloft.net, tgraf@suug.ch, alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36359 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932424AbcLGULb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 15:11:31 -0500
Received: by mail-pf0-f193.google.com with SMTP id c4so21055001pfb.3
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 12:11:30 -0800 (PST)
In-Reply-To: <20161207200139.28121.4811.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for dynamically setting the LRO feature flag. The
message to control guest features in the backend uses the
CTRL_GUEST_OFFLOADS msg type.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/virtio_net.c |   40 +++++++++++++++++++++++++++++++++++++++-
 1 file changed, 39 insertions(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index a21d93a..a5c47b1 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1419,6 +1419,36 @@ static void virtnet_init_settings(struct net_device *dev)
 	.set_settings = virtnet_set_settings,
 };
 
+static int virtnet_set_features(struct net_device *netdev,
+				netdev_features_t features)
+{
+	struct virtnet_info *vi = netdev_priv(netdev);
+	struct virtio_device *vdev = vi->vdev;
+	struct scatterlist sg;
+	u64 offloads = 0;
+
+	if (features & NETIF_F_LRO)
+		offloads |= (1 << VIRTIO_NET_F_GUEST_TSO4) |
+			    (1 << VIRTIO_NET_F_GUEST_TSO6);
+
+	if (features & NETIF_F_RXCSUM)
+		offloads |= (1 << VIRTIO_NET_F_GUEST_CSUM);
+
+	if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_GUEST_OFFLOADS)) {
+		sg_init_one(&sg, &offloads, sizeof(uint64_t));
+		if (!virtnet_send_command(vi,
+					  VIRTIO_NET_CTRL_GUEST_OFFLOADS,
+					  VIRTIO_NET_CTRL_GUEST_OFFLOADS_SET,
+					  &sg)) {
+			dev_warn(&netdev->dev,
+				 "Failed to set guest offloads by virtnet command.\n");
+			return -EINVAL;
+		}
+	}
+
+	return 0;
+}
+
 static const struct net_device_ops virtnet_netdev = {
 	.ndo_open            = virtnet_open,
 	.ndo_stop   	     = virtnet_close,
@@ -1435,6 +1465,7 @@ static void virtnet_init_settings(struct net_device *dev)
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	.ndo_busy_poll		= virtnet_busy_poll,
 #endif
+	.ndo_set_features	= virtnet_set_features,
 };
 
 static void virtnet_config_changed_work(struct work_struct *work)
@@ -1815,6 +1846,12 @@ static int virtnet_probe(struct virtio_device *vdev)
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_CSUM))
 		dev->features |= NETIF_F_RXCSUM;
 
+	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO4) &&
+	    virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO6)) {
+		dev->features |= NETIF_F_LRO;
+		dev->hw_features |= NETIF_F_LRO;
+	}
+
 	dev->vlan_features = dev->features;
 
 	/* MTU range: 68 - 65535 */
@@ -2057,7 +2094,8 @@ static int virtnet_restore(struct virtio_device *vdev)
 	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN, \
 	VIRTIO_NET_F_GUEST_ANNOUNCE, VIRTIO_NET_F_MQ, \
 	VIRTIO_NET_F_CTRL_MAC_ADDR, \
-	VIRTIO_NET_F_MTU
+	VIRTIO_NET_F_MTU, \
+	VIRTIO_NET_F_CTRL_GUEST_OFFLOADS
 
 static unsigned int features[] = {
 	VIRTNET_FEATURES,
