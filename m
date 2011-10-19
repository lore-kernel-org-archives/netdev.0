From: raj@tardy.cup.hp.com (Rick Jones)
Subject: [PATCH net-next] Add ethtool -g support to virtio_net
Date: Wed, 19 Oct 2011 11:10:59 -0700 (PDT)
Message-ID: <20111019181059.C644A29003F6@tardy>
To: <netdev@vger.kernel.org>, <rusty@rustcorp.com.au>,
	<mst@redhat.com>, <virtualization@lists.linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:45008 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625Ab1JSSLD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 14:11:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>

Add support for reporting ring sizes via ethtool -g to the virtio_net
driver.

Signed-off-by: Rick Jones <rick.jones2@hp.com>

---

Tested briefly in a single guest:

raj@raj-ubuntu-guest:~$ ethtool -g eth0
Ring parameters for eth0:
Pre-set maximums:
RX:		256
RX Mini:	0
RX Jumbo:	0
TX:		256
Current hardware settings:
RX:		256
RX Mini:	0
RX Jumbo:	0
TX:		256


diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index b8225f3..3e642a4 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -880,8 +880,21 @@ static void virtnet_vlan_rx_kill_vid(struct net_device *dev, u16 vid)
 		dev_warn(&dev->dev, "Failed to kill VLAN ID %d.\n", vid);
 }
 
+static void virtnet_get_ringparam(struct net_device *dev,
+				struct ethtool_ringparam *ring)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+
+	ring->rx_max_pending = virtqueue_get_vring_size(vi->rvq);
+	ring->tx_max_pending = virtqueue_get_vring_size(vi->svq);
+	ring->rx_pending = ring->rx_max_pending;
+	ring->tx_pending = ring->tx_max_pending;
+
+}
+
 static const struct ethtool_ops virtnet_ethtool_ops = {
 	.get_link = ethtool_op_get_link,
+	.get_ringparam = virtnet_get_ringparam,
 };
 
 #define MIN_MTU 68
diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index 68b9136..4acf888 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -529,4 +529,14 @@ void vring_transport_features(struct virtio_device *vdev)
 }
 EXPORT_SYMBOL_GPL(vring_transport_features);
 
+/* return the size of the vring within the virtqueue */
+unsigned int virtqueue_get_vring_size(struct virtqueue *_vq)
+{
+
+	struct vring_virtqueue *vq = to_vvq(_vq);
+
+	return vq->vring.num;
+}
+EXPORT_SYMBOL_GPL(virtqueue_get_vring_size);
+
 MODULE_LICENSE("GPL");
diff --git a/include/linux/virtio.h b/include/linux/virtio.h
index 7108857..851ebf1 100644
--- a/include/linux/virtio.h
+++ b/include/linux/virtio.h
@@ -61,6 +61,9 @@ struct virtqueue {
  * virtqueue_detach_unused_buf: detach first unused buffer
  * 	vq: the struct virtqueue we're talking about.
  * 	Returns NULL or the "data" token handed to add_buf
+ * virtqueue_get_vring_size: return the size of the virtqueue's vring
+ *	vq: the struct virtqueue containing the vring of interest.
+ *	Returns the size of the vring.
  *
  * Locking rules are straightforward: the driver is responsible for
  * locking.  No two operations may be invoked simultaneously, with the exception
@@ -97,6 +100,8 @@ bool virtqueue_enable_cb_delayed(struct virtqueue *vq);
 
 void *virtqueue_detach_unused_buf(struct virtqueue *vq);
 
+unsigned int virtqueue_get_vring_size(struct virtqueue *vq);
+
 /**
  * virtio_device - representation of a device using virtio
  * @index: unique position on the virtio bus
