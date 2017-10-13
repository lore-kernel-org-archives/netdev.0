From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next] virtio_net: implement VIRTIO_CONFIG_S_NEEDS_RESET
Date: Fri, 13 Oct 2017 11:51:40 -0400
Message-ID: <20171013155140.124530-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, mst@redhat.com, jasowang@redhat.com,
        virtualization@lists.linux-foundation.org,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:56362 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758110AbdJMPvt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 11:51:49 -0400
Received: by mail-qt0-f193.google.com with SMTP id z28so17922286qtz.13
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 08:51:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Implement the reset communication request defined in the VIRTIO 1.0
specification and introduces in Linux in commit c00bbcf862896 ("virtio:
add VIRTIO_CONFIG_S_NEEDS_RESET device status bit").

Use the virtnet_reset function introduced in commit 2de2f7f40ef9
("virtio_net: XDP support for adjust_head"). That was removed in
commit 4941d472bf95 ("virtio-net: do not reset during XDP set"),
because no longer used. Bring it back, minus the xdp specific code.

Before tearing down any state, virtnet_freeze_down quiesces the
device with netif_tx_disable. virtnet_reset also ensures that no
other config operations can run concurrently.

On successful reset, the host can observe that the flag has been
cleared. There is no need for the explicit control flag introduced
in the previous RFC of this patch.

Changes
  RFC -> v1
  - drop VIRTIO_NET_CTRL_RESET_ACK message
  - drop VIRTIO_F_CAN_RESET flag to notify guest support

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 drivers/net/virtio_net.c | 48 ++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 44 insertions(+), 4 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index fc059f193e7d..8e768b54844f 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1903,13 +1903,14 @@ static const struct ethtool_ops virtnet_ethtool_ops = {
 	.set_link_ksettings = virtnet_set_link_ksettings,
 };
 
-static void virtnet_freeze_down(struct virtio_device *vdev)
+static void virtnet_freeze_down(struct virtio_device *vdev, bool in_config)
 {
 	struct virtnet_info *vi = vdev->priv;
 	int i;
 
-	/* Make sure no work handler is accessing the device */
-	flush_work(&vi->config_work);
+	/* Make sure no other work handler is accessing the device */
+	if (!in_config)
+		flush_work(&vi->config_work);
 
 	netif_device_detach(vi->dev);
 	netif_tx_disable(vi->dev);
@@ -1924,6 +1925,7 @@ static void virtnet_freeze_down(struct virtio_device *vdev)
 }
 
 static int init_vqs(struct virtnet_info *vi);
+static void remove_vq_common(struct virtnet_info *vi);
 
 static int virtnet_restore_up(struct virtio_device *vdev)
 {
@@ -1952,6 +1954,40 @@ static int virtnet_restore_up(struct virtio_device *vdev)
 	return err;
 }
 
+static int virtnet_reset(struct virtnet_info *vi)
+{
+	struct virtio_device *dev = vi->vdev;
+	int ret;
+
+	virtio_config_disable(dev);
+	dev->failed = dev->config->get_status(dev) & VIRTIO_CONFIG_S_FAILED;
+	virtnet_freeze_down(dev, true);
+	remove_vq_common(vi);
+
+	virtio_add_status(dev, VIRTIO_CONFIG_S_ACKNOWLEDGE);
+	virtio_add_status(dev, VIRTIO_CONFIG_S_DRIVER);
+
+	ret = virtio_finalize_features(dev);
+	if (ret)
+		goto err;
+
+	ret = virtnet_restore_up(dev);
+	if (ret)
+		goto err;
+
+	ret = virtnet_set_queues(vi, vi->curr_queue_pairs);
+	if (ret)
+		goto err;
+
+	virtio_add_status(dev, VIRTIO_CONFIG_S_DRIVER_OK);
+	virtio_config_enable(dev);
+	return 0;
+
+err:
+	virtio_add_status(dev, VIRTIO_CONFIG_S_FAILED);
+	return ret;
+}
+
 static int virtnet_set_guest_offloads(struct virtnet_info *vi, u64 offloads)
 {
 	struct scatterlist sg;
@@ -2136,6 +2172,10 @@ static void virtnet_config_changed_work(struct work_struct *work)
 		virtnet_ack_link_announce(vi);
 	}
 
+	if (vi->vdev->config->get_status(vi->vdev) &
+	    VIRTIO_CONFIG_S_NEEDS_RESET)
+		virtnet_reset(vi);
+
 	/* Ignore unknown (future) status bits */
 	v &= VIRTIO_NET_S_LINK_UP;
 
@@ -2756,7 +2796,7 @@ static __maybe_unused int virtnet_freeze(struct virtio_device *vdev)
 	struct virtnet_info *vi = vdev->priv;
 
 	virtnet_cpu_notif_remove(vi);
-	virtnet_freeze_down(vdev);
+	virtnet_freeze_down(vdev, false);
 	remove_vq_common(vi);
 
 	return 0;
-- 
2.15.0.rc0.271.g36b669edcc-goog
