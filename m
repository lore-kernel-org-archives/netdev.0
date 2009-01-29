From: Alex Williamson <alex.williamson@hp.com>
Subject: [PATCH v2 4/4] virtio_net: Add support for VLAN filtering in the
	hypervisor
Date: Thu, 29 Jan 2009 16:05:23 -0700
Message-ID: <20090129230523.2672.55464.stgit@debian.lart>
References: <20090129230502.2672.87669.stgit@debian.lart>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: markmc@redhat.com, netdev@vger.kernel.org, kvm@vger.kernel.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:21072 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754023AbZA2XIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 18:08:20 -0500
In-Reply-To: <20090129230502.2672.87669.stgit@debian.lart>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VLAN filtering allows the hypervisor to drop packets from VLANs
that we're not a part of, further reducing the number of extraneous
packets recieved.  This makes use of the VLAN virtqueue command class.
The CTRL_VLAN feature bit tells us whether the backend supports VLAN
filtering.

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
---

 drivers/net/virtio_net.c   |   37 ++++++++++++++++++++++++++++++++++++-
 include/linux/virtio_net.h |   16 ++++++++++++++++
 2 files changed, 52 insertions(+), 1 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 23610ce..14ee139 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -767,6 +767,26 @@ free_uc:
 	kfree(uc_buf);
 }
 
+static void virnet_vlan_rx_add_vid(struct net_device *dev, u16 vid)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+
+	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_VLAN,
+				  VIRTIO_NET_CTRL_VLAN_ADD, &vid, sizeof(vid)))
+		printk(KERN_WARNING "%s: Failed to add VLAN ID %d.\n",
+		       dev->name, vid);
+}
+
+static void virnet_vlan_rx_kill_vid(struct net_device *dev, u16 vid)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+
+	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_VLAN,
+				  VIRTIO_NET_CTRL_VLAN_DEL, &vid, sizeof(vid)))
+		printk(KERN_WARNING "%s: Failed to kill VLAN ID %d.\n",
+		       dev->name, vid);
+}
+
 static struct ethtool_ops virtnet_ethtool_ops = {
 	.set_tx_csum = virtnet_set_tx_csum,
 	.set_sg = ethtool_op_set_sg,
@@ -793,6 +813,8 @@ static const struct net_device_ops virtnet_netdev = {
 	.ndo_set_mac_address = virtnet_set_mac_address,
 	.ndo_set_rx_mode     = virtnet_set_rx_mode,
 	.ndo_change_mtu	     = virtnet_change_mtu,
+	.ndo_vlan_rx_add_vid = virnet_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid = virnet_vlan_rx_kill_vid,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = virtnet_netpoll,
 #endif
@@ -920,6 +942,19 @@ static int virtnet_probe(struct virtio_device *vdev)
 			err = PTR_ERR(vi->svq);
 			goto free_send;
 		}
+
+		if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VLAN)) {
+			u8 enable = 1;
+
+			/* Enable VLAN filtering */
+			if (virtnet_send_command(vi, VIRTIO_NET_CTRL_VLAN,
+						 VIRTIO_NET_CTRL_VLAN_ENABLE,
+						 &enable, sizeof(enable)))
+				dev->features |= NETIF_F_HW_VLAN_FILTER;
+			else
+				printk(KERN_WARNING "virtio_net: "
+				       "Failed to enable VLAN filter\n");
+		}
 	}
 
 	/* Initialize our empty receive and send queues. */
@@ -1010,7 +1045,7 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_HOST_ECN, VIRTIO_NET_F_GUEST_TSO4, VIRTIO_NET_F_GUEST_TSO6,
 	VIRTIO_NET_F_GUEST_ECN, /* We don't yet handle UFO input. */
 	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ,
-	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_MAC,
+	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_MAC, VIRTIO_NET_F_CTRL_VLAN,
 	VIRTIO_F_NOTIFY_ON_EMPTY,
 };
 
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index c8e945a..8733a66 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -25,6 +25,7 @@
 #define VIRTIO_NET_F_CTRL_VQ	17	/* Control channel available */
 #define VIRTIO_NET_F_CTRL_RX	18	/* Control channel RX mode support */
 #define VIRTIO_NET_F_CTRL_MAC	19	/* Control channel MAC filtering */
+#define VIRTIO_NET_F_CTRL_VLAN	20	/* Control channel VLAN filtering */
 
 #define VIRTIO_NET_S_LINK_UP	1	/* Link is up */
 
@@ -103,4 +104,19 @@ typedef __u8 virtio_net_ctrl_ack;
 #define VIRTIO_NET_CTRL_MAC    1
  #define VIRTIO_NET_CTRL_MAC_TABLE_SET        0
 
+/*
+ * Control VLAN filtering
+ *
+ * The VLAN filter table is controlled via a simple ADD/DEL interface.
+ * VLAN IDs not added will be dropped.  Del is the opposite of add.
+ * Both commands expect an out entry containing a 2 byte VLAN ID.
+ * The ENABLE command expects an out entry containing a single byte,
+ * zero to disable, non-zero to enable.  The default state is disabled
+ * for compatibility.
+ */
+#define VIRTIO_NET_CTRL_VLAN       2
+ #define VIRTIO_NET_CTRL_VLAN_ENABLE          0
+ #define VIRTIO_NET_CTRL_VLAN_ADD             1
+ #define VIRTIO_NET_CTRL_VLAN_DEL             2
+
 #endif /* _LINUX_VIRTIO_NET_H */

