From: Alex Williamson <alex.williamson@hp.com>
Subject: [PATCH v2 2/4] virtio_net: Add a set_rx_mode interface
Date: Thu, 29 Jan 2009 16:05:12 -0700
Message-ID: <20090129230512.2672.13107.stgit@debian.lart>
References: <20090129230502.2672.87669.stgit@debian.lart>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: markmc@redhat.com, netdev@vger.kernel.org, kvm@vger.kernel.org
To: rusty@rustcorp.com.au
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090129230502.2672.87669.stgit@debian.lart>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make use of the RX_MODE control virtqueue class to enable the
set_rx_mode netdev interface.  This allows us to selectively
enable/disable promiscuous and allmulti mode so we don't see
packets we don't want.  We'll automatically enable these as
needed if additional unicast or multicast addresses are
requested.

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
---

 drivers/net/virtio_net.c   |   26 ++++++++++++++++++++++++++
 include/linux/virtio_net.h |   10 ++++++++++
 2 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index c909444..b247558 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -660,6 +660,30 @@ static int virtnet_set_tx_csum(struct net_device *dev, u32 data)
 	return ethtool_op_set_tx_hw_csum(dev, data);
 }
 
+static void virtnet_set_rx_mode(struct net_device *dev)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	u8 promisc, allmulti;
+
+	if (!virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_RX))
+		return;
+
+	promisc = ((dev->flags & IFF_PROMISC) != 0 || dev->uc_count > 0);
+	allmulti = ((dev->flags & IFF_ALLMULTI) != 0 || dev->mc_count > 0);
+
+	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_RX,
+				  VIRTIO_NET_CTRL_RX_PROMISC,
+				  &promisc, sizeof(promisc)))
+		printk(KERN_WARNING "%s: Failed to %sable promisc mode.\n",
+		       dev->name, promisc ? "en" : "dis");
+
+	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_RX,
+				  VIRTIO_NET_CTRL_RX_ALLMULTI,
+				  &allmulti, sizeof(allmulti)))
+		printk(KERN_WARNING "%s: Failed to %sable allmulti mode.\n",
+		       dev->name, allmulti ? "en" : "dis");
+}
+
 static struct ethtool_ops virtnet_ethtool_ops = {
 	.set_tx_csum = virtnet_set_tx_csum,
 	.set_sg = ethtool_op_set_sg,
@@ -684,6 +708,7 @@ static const struct net_device_ops virtnet_netdev = {
 	.ndo_start_xmit      = start_xmit,
 	.ndo_validate_addr   = eth_validate_addr,
 	.ndo_set_mac_address = virtnet_set_mac_address,
+	.ndo_set_rx_mode     = virtnet_set_rx_mode,
 	.ndo_change_mtu	     = virtnet_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = virtnet_netpoll,
@@ -902,6 +927,7 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_HOST_ECN, VIRTIO_NET_F_GUEST_TSO4, VIRTIO_NET_F_GUEST_TSO6,
 	VIRTIO_NET_F_GUEST_ECN, /* We don't yet handle UFO input. */
 	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ,
+	VIRTIO_NET_F_CTRL_RX,
 	VIRTIO_F_NOTIFY_ON_EMPTY,
 };
 
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index fd0981c..aac09ec 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -23,6 +23,7 @@
 #define VIRTIO_NET_F_MRG_RXBUF	15	/* Host can merge receive buffers. */
 #define VIRTIO_NET_F_STATUS	16	/* virtio_net_config.status available */
 #define VIRTIO_NET_F_CTRL_VQ	17	/* Control channel available */
+#define VIRTIO_NET_F_CTRL_RX	18	/* Control channel RX mode support */
 
 #define VIRTIO_NET_S_LINK_UP	1	/* Link is up */
 
@@ -76,4 +77,13 @@ typedef __u8 virtio_net_ctrl_ack;
 #define VIRTIO_NET_OK     0
 #define VIRTIO_NET_ERR    1
 
+/*
+ * Control the RX mode, ie. promisucous and allmulti.  PROMISC and
+ * ALLMULTI commands require an "out" sg entry containing a 1 byte
+ * state value, zero = disable, non-zero = enable.
+ */
+#define VIRTIO_NET_CTRL_RX    0
+ #define VIRTIO_NET_CTRL_RX_PROMISC      0
+ #define VIRTIO_NET_CTRL_RX_ALLMULTI     1
+
 #endif /* _LINUX_VIRTIO_NET_H */

