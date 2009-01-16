From: Alex Williamson <alex.williamson@hp.com>
Subject: [PATCH 3/5] virtio_net: Add a set_rx_mode interface
Date: Fri, 16 Jan 2009 14:13:28 -0700
Message-ID: <20090116211328.22836.70727.stgit@debian.lart>
References: <20090116211312.22836.34331.stgit@debian.lart>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, markmc@redhat.com, kvm@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:45524 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763487AbZAPVPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 16:15:21 -0500
In-Reply-To: <20090116211312.22836.34331.stgit@debian.lart>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make use of the RX_MODE control virtqueue class to enable the
set_rx_mode netdev interface.  This allows us to selectively
enable/disable promiscuous and allmulti mode so we don't see
packets we don't want.  We'll automatically enable these as
needed if additional unicast or multicast addresses are
requested.

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
---

 drivers/net/virtio_net.c   |   28 +++++++++++++++++++++++++++-
 include/linux/virtio_net.h |    9 +++++++++
 2 files changed, 36 insertions(+), 1 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index d4be0a2..da96368 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -658,6 +658,31 @@ static int virtnet_set_tx_csum(struct net_device *dev, u32 data)
 	return ethtool_op_set_tx_hw_csum(dev, data);
 }
 
+static void virtnet_set_rx_mode(struct net_device *dev)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	u8 promisc, allmulti;
+
+	/* we're useless without the control virtqueue */
+	if (!vi->cvq)
+		return;
+
+	promisc = ((dev->flags & IFF_PROMISC) != 0 || dev->uc_count > 0);
+	allmulti = ((dev->flags & IFF_ALLMULTI) != 0 || dev->mc_count > 0);
+
+	if (virtnet_send_command(vi, VIRTIO_NET_CTRL_RX_MODE,
+				 VIRTIO_NET_CTRL_RX_MODE_PROMISC,
+				 &promisc, sizeof(promisc)))
+		printk(KERN_WARNING "%s: Failed to %sable promisc mode.\n",
+		       dev->name, promisc ? "en" : "dis");
+
+	if (virtnet_send_command(vi, VIRTIO_NET_CTRL_RX_MODE,
+				 VIRTIO_NET_CTRL_RX_MODE_ALLMULTI,
+				 &allmulti, sizeof(allmulti)))
+		printk(KERN_WARNING "%s: Failed to %sable allmulti mode.\n",
+		       dev->name, allmulti ? "en" : "dis");
+}
+
 static struct ethtool_ops virtnet_ethtool_ops = {
 	.set_tx_csum = virtnet_set_tx_csum,
 	.set_sg = ethtool_op_set_sg,
@@ -681,6 +706,7 @@ static const struct net_device_ops virtnet_netdev = {
 	.ndo_start_xmit      = start_xmit,
 	.ndo_validate_addr   = eth_validate_addr,
 	.ndo_set_mac_address = virtnet_set_mac_address,
+	.ndo_set_rx_mode     = virtnet_set_rx_mode,
 	.ndo_change_mtu	     = virtnet_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = virtnet_netpoll,
@@ -770,7 +796,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 
 	/*
 	 * Outbound control channel virtqueue.  We can live without it,
-	 * so don't go fatal if it's not there.
+	 * so don't go fatal if it's not there.  Required for set_rx_mode.
 	 */
 	vi->cvq = vdev->config->find_vq(vdev, 2, NULL);
 	if (IS_ERR(vi->cvq))
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index e2c1d81..f8afef3 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -70,4 +70,13 @@ typedef __u8 virtio_net_ctrl_ack;
 #define VIRTIO_NET_OK     0
 #define VIRTIO_NET_ERR    1
 
+/*
+ * Control the RX mode, ie. promisucous and allmulti.  PROMISC and
+ * ALLMULTI commands require an "out" sg entry containing a 1 byte
+ * state value, zero = disable, non-zero = enable.
+ */
+#define VIRTIO_NET_CTRL_RX_MODE    0
+ #define VIRTIO_NET_CTRL_RX_MODE_PROMISC      0
+ #define VIRTIO_NET_CTRL_RX_MODE_ALLMULTI     1
+
 #endif /* _LINUX_VIRTIO_NET_H */

