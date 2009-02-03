From: Alex Williamson <alex.williamson@hp.com>
Subject: [PATCH v4 4/4] virtio_net: Add support for VLAN filtering in the
	hypervisor
Date: Tue, 03 Feb 2009 12:26:11 -0700
Message-ID: <20090203192611.2678.16606.stgit@debian.lart>
References: <20090203192550.2678.14498.stgit@debian.lart>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: markmc@redhat.com, netdev@vger.kernel.org, kvm@vger.kernel.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:11984 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753080AbZBCT3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 14:29:04 -0500
In-Reply-To: <20090203192550.2678.14498.stgit@debian.lart>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VLAN filtering allows the hypervisor to drop packets from VLANs
that we're not a part of, further reducing the number of extraneous
packets recieved.  This makes use of the VLAN virtqueue command class.
The CTRL_VLAN feature bit tells us whether the backend supports VLAN
filtering.

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
---

 drivers/net/virtio_net.c   |   31 ++++++++++++++++++++++++++++++-
 include/linux/virtio_net.h |   14 ++++++++++++++
 2 files changed, 44 insertions(+), 1 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 937a256..3d00339 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -743,6 +743,30 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 	kfree(buf);
 }
 
+static void virnet_vlan_rx_add_vid(struct net_device *dev, u16 vid)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	struct scatterlist sg;
+
+	sg_set_buf(&sg, &vid, sizeof(vid));
+
+	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_VLAN,
+				  VIRTIO_NET_CTRL_VLAN_ADD, &sg, 1, 0))
+		dev_warn(&dev->dev, "Failed to add VLAN ID %d.\n", vid);
+}
+
+static void virnet_vlan_rx_kill_vid(struct net_device *dev, u16 vid)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	struct scatterlist sg;
+
+	sg_set_buf(&sg, &vid, sizeof(vid));
+
+	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_VLAN,
+				  VIRTIO_NET_CTRL_VLAN_DEL, &sg, 1, 0))
+		dev_warn(&dev->dev, "Failed to kill VLAN ID %d.\n", vid);
+}
+
 static struct ethtool_ops virtnet_ethtool_ops = {
 	.set_tx_csum = virtnet_set_tx_csum,
 	.set_sg = ethtool_op_set_sg,
@@ -769,6 +793,8 @@ static const struct net_device_ops virtnet_netdev = {
 	.ndo_set_mac_address = virtnet_set_mac_address,
 	.ndo_set_rx_mode     = virtnet_set_rx_mode,
 	.ndo_change_mtu	     = virtnet_change_mtu,
+	.ndo_vlan_rx_add_vid = virnet_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid = virnet_vlan_rx_kill_vid,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = virtnet_netpoll,
 #endif
@@ -896,6 +922,9 @@ static int virtnet_probe(struct virtio_device *vdev)
 			err = PTR_ERR(vi->svq);
 			goto free_send;
 		}
+
+		if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VLAN))
+			dev->features |= NETIF_F_HW_VLAN_FILTER;
 	}
 
 	/* Initialize our empty receive and send queues. */
@@ -986,7 +1015,7 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_HOST_ECN, VIRTIO_NET_F_GUEST_TSO4, VIRTIO_NET_F_GUEST_TSO6,
 	VIRTIO_NET_F_GUEST_ECN, /* We don't yet handle UFO input. */
 	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ,
-	VIRTIO_NET_F_CTRL_RX,
+	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN,
 	VIRTIO_F_NOTIFY_ON_EMPTY,
 };
 
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index ba82b65..242348b 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -25,6 +25,7 @@
 #define VIRTIO_NET_F_STATUS	16	/* virtio_net_config.status available */
 #define VIRTIO_NET_F_CTRL_VQ	17	/* Control channel available */
 #define VIRTIO_NET_F_CTRL_RX	18	/* Control channel RX mode support */
+#define VIRTIO_NET_F_CTRL_VLAN	19	/* Control channel VLAN filtering */
 
 #define VIRTIO_NET_S_LINK_UP	1	/* Link is up */
 
@@ -111,4 +112,17 @@ struct virtio_net_ctrl_mac {
 #define VIRTIO_NET_CTRL_MAC    1
  #define VIRTIO_NET_CTRL_MAC_TABLE_SET        0
 
+/*
+ * Control VLAN filtering
+ *
+ * The VLAN filter table is controlled via a simple ADD/DEL interface.
+ * VLAN IDs not added may be filterd by the hypervisor.  Del is the
+ * opposite of add.  Both commands expect an out entry containing a 2
+ * byte VLAN ID.  VLAN filterting is available with the
+ * VIRTIO_NET_F_CTRL_VLAN feature bit.
+ */
+#define VIRTIO_NET_CTRL_VLAN       2
+ #define VIRTIO_NET_CTRL_VLAN_ADD             0
+ #define VIRTIO_NET_CTRL_VLAN_DEL             1
+
 #endif /* _LINUX_VIRTIO_NET_H */

