From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v3 1/6] net: virtio dynamically disable/enable LRO
Date: Tue, 29 Nov 2016 12:09:33 -0800
Message-ID: <20161129200933.26851.41883.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        bblanco@plumgrid.com, john.fastabend@gmail.com, brouer@redhat.com
To: eric.dumazet@gmail.com, daniel@iogearbox.net,
        shm@cumulusnetworks.com, davem@davemloft.net, tgraf@suug.ch,
        alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33942 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755903AbcK2UKZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 15:10:25 -0500
Received: by mail-pf0-f195.google.com with SMTP id y68so8840989pfb.1
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 12:09:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for dynamically setting the LRO feature flag. The
message to control guest features in the backend uses the
CTRL_GUEST_OFFLOADS msg type.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/virtio_net.c |   45 ++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 44 insertions(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index ca5239a..8189e5b 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1419,6 +1419,41 @@ static void virtnet_init_settings(struct net_device *dev)
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
+	} else if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_GUEST_OFFLOADS) &&
+		   !virtio_has_feature(vdev, VIRTIO_F_VERSION_1)) {
+		dev_warn(&netdev->dev,
+			 "No support for setting offloads pre version_1.\n");
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
 static const struct net_device_ops virtnet_netdev = {
 	.ndo_open            = virtnet_open,
 	.ndo_stop   	     = virtnet_close,
@@ -1435,6 +1470,7 @@ static void virtnet_init_settings(struct net_device *dev)
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	.ndo_busy_poll		= virtnet_busy_poll,
 #endif
+	.ndo_set_features	= virtnet_set_features,
 };
 
 static void virtnet_config_changed_work(struct work_struct *work)
@@ -1810,6 +1846,12 @@ static int virtnet_probe(struct virtio_device *vdev)
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
@@ -2047,7 +2089,8 @@ static int virtnet_restore(struct virtio_device *vdev)
 	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN, \
 	VIRTIO_NET_F_GUEST_ANNOUNCE, VIRTIO_NET_F_MQ, \
 	VIRTIO_NET_F_CTRL_MAC_ADDR, \
-	VIRTIO_NET_F_MTU
+	VIRTIO_NET_F_MTU, \
+	VIRTIO_NET_F_CTRL_GUEST_OFFLOADS
 
 static unsigned int features[] = {
 	VIRTNET_FEATURES,
