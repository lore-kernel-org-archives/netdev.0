From: Alex Williamson <alex.williamson@hp.com>
Subject: [PATCH 5/5] virtio_net: Add support for VLAN filtering in the
	hypervisor
Date: Tue, 20 Jan 2009 09:36:36 -0700
Message-ID: <20090120163636.10034.5080.stgit@debian.lart>
References: <1232357520.5627.15.camel@blaa>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, markmc@redhat.com, kvm@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1232357520.5627.15.camel@blaa>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

VLAN filtering allows the hypervisor to drop packets from VLANs
that we're not a part of, further reducing the number of extraneous
packets recieved.  This makes use of the VLAN virtqueue command class.
The ENABLE command is used both to activate the filter and verify the
existence of the functionality on the backend.

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
---

Updated with suggestions from Mark McLoughlin:
 - VLAN packet length fix split into separate patch
 - Indenting fix
 - Lower priority VLAN enabled printk
 - Renamed VLAN_KILL to VLAN_DEL

 drivers/net/virtio_net.c   |   49 +++++++++++++++++++++++++++++++++++++-------
 include/linux/virtio_net.h |   15 +++++++++++++
 2 files changed, 56 insertions(+), 8 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index f3849d1..e07019c 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -744,6 +744,28 @@ set_mode:
 		       dev->name, allmulti ? "en" : "dis");
 }
 
+static void virnet_vlan_rx_add_vid(struct net_device *dev, u16 vid)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	u16 id = vid;
+
+	if (virtnet_send_command(vi, VIRTIO_NET_CTRL_VLAN,
+				 VIRTIO_NET_CTRL_VLAN_ADD, &id, sizeof(id)))
+		printk(KERN_WARNING "%s: Failed to add VLAN ID %d.\n",
+		       dev->name, id);
+}
+
+static void virnet_vlan_rx_kill_vid(struct net_device *dev, u16 vid)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	u16 id = vid;
+
+	if (virtnet_send_command(vi, VIRTIO_NET_CTRL_VLAN,
+				 VIRTIO_NET_CTRL_VLAN_DEL, &id, sizeof(id)))
+		printk(KERN_WARNING "%s: Failed to kill VLAN ID %d.\n",
+		       dev->name, id);
+}
+
 static struct ethtool_ops virtnet_ethtool_ops = {
 	.set_tx_csum = virtnet_set_tx_csum,
 	.set_sg = ethtool_op_set_sg,
@@ -762,15 +784,17 @@ static int virtnet_change_mtu(struct net_device *dev, int new_mtu)
 }
 
 static const struct net_device_ops virtnet_netdev = {
-	.ndo_open            = virtnet_open,
-	.ndo_stop   	     = virtnet_close,
-	.ndo_start_xmit      = start_xmit,
-	.ndo_validate_addr   = eth_validate_addr,
-	.ndo_set_mac_address = virtnet_set_mac_address,
-	.ndo_set_rx_mode     = virtnet_set_rx_mode,
-	.ndo_change_mtu	     = virtnet_change_mtu,
+	.ndo_open             = virtnet_open,
+	.ndo_stop   	      = virtnet_close,
+	.ndo_start_xmit       = start_xmit,
+	.ndo_validate_addr    = eth_validate_addr,
+	.ndo_set_mac_address  = virtnet_set_mac_address,
+	.ndo_set_rx_mode      = virtnet_set_rx_mode,
+	.ndo_change_mtu	      = virtnet_change_mtu,
+	.ndo_vlan_rx_add_vid  = virnet_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid = virnet_vlan_rx_kill_vid,
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	.ndo_poll_controller = virtnet_netpoll,
+	.ndo_poll_controller  = virtnet_netpoll,
 #endif
 };
 
@@ -864,6 +888,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 		vi->cvq = NULL;
 	else {
 		unsigned int entries;
+		u8 vlan_filter = 1;
 
 		/*
 		 * We use a separate stack variable here because the
@@ -879,6 +904,14 @@ static int virtnet_probe(struct virtio_device *vdev)
 			       "MAC filter table allocation failed.\n");
 			mac_entries = 0;
 		}
+
+		/* Enable VLAN filtering if supported by the backend */
+		if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_VLAN,
+					  VIRTIO_NET_CTRL_VLAN_ENABLE,
+					  &vlan_filter, sizeof(vlan_filter))) {
+			printk(KERN_DEBUG "virtio_net: VLAN filter enabled\n");
+			dev->features |= NETIF_F_HW_VLAN_FILTER;
+		}
 	}
 
 	/* Initialize our empty receive and send queues. */
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index 84086a6..1d7171c 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -99,4 +99,19 @@ typedef __u8 virtio_net_ctrl_ack;
  #define VIRTIO_NET_CTRL_MAC_TABLE_ALLOC      0
  #define VIRTIO_NET_CTRL_MAC_TABLE_SET        1
 
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

