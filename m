From: Jason Wang <jasowang@redhat.com>
Subject: [V6 PATCH] virtio-net: send gratuitous packets when needed
Date: Wed, 28 Mar 2012 13:44:28 +0800
Message-ID: <20120328054428.34415.75432.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, qemu-devel@nongnu.org
To: netdev@vger.kernel.org, rusty@rustcorp.com.au, mst@redhat.com,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

As hypervior does not have the knowledge of guest network configuration, it's
better to ask guest to send gratuitous packets when needed.

Guest tests VIRTIO_NET_S_ANNOUNCE bit during config change interrupt and when it
is set, a workqueue is scheduled to send gratuitous packet through
NETDEV_NOTIFY_PEERS. This feature is negotiated through bit
VIRTIO_NET_F_GUEST_ANNOUNCE.

Changes from v5:
- notify the chain before acking the link annoucement
- ack the link announcement notification through control vq

Changes from v4:
- typos
- handle workqueue unconditionally
- move VIRTIO_NET_S_ANNOUNCE to bit 8 to separate rw bits from ro bits

Changes from v3:
- cancel the workqueue during freeze

Changes from v2:
- fix the race between unregister_dev() and workqueue

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c   |   32 +++++++++++++++++++++++++++++++-
 include/linux/virtio_net.h |   13 +++++++++++++
 2 files changed, 44 insertions(+), 1 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 4880aa8..0f60da7 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -72,6 +72,9 @@ struct virtnet_info {
 	/* Work struct for refilling if we run low on memory. */
 	struct delayed_work refill;
 
+	/* Work struct for sending gratuitous packets. */
+	struct work_struct announce;
+
 	/* Chain pages by the private ptr. */
 	struct page *pages;
 
@@ -781,12 +784,30 @@ static bool virtnet_send_command(struct virtnet_info *vi, u8 class, u8 cmd,
 	return status == VIRTIO_NET_OK;
 }
 
+static void virtnet_ack_link_announce(struct virtnet_info *vi)
+{
+	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_ANNOUNCE,
+				  VIRTIO_NET_CTRL_ANNOUNCE_ACK, NULL,
+				  0, 0)) {
+		dev_warn(&vi->dev->dev, "Failed to ack link nnounce.\n");
+	}
+}
+
+static void announce_work(struct work_struct *work)
+{
+	struct virtnet_info *vi = container_of(work, struct virtnet_info,
+					       announce);
+	netif_notify_peers(vi->dev);
+	virtnet_ack_link_announce(vi);
+}
+
 static int virtnet_close(struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 
 	/* Make sure refill_work doesn't re-enable napi! */
 	cancel_delayed_work_sync(&vi->refill);
+	cancel_work_sync(&vi->announce);
 	napi_disable(&vi->napi);
 
 	return 0;
@@ -962,11 +983,17 @@ static void virtnet_update_status(struct virtnet_info *vi)
 		return;
 
 	/* Ignore unknown (future) status bits */
-	v &= VIRTIO_NET_S_LINK_UP;
+	v &= VIRTIO_NET_S_LINK_UP | VIRTIO_NET_S_ANNOUNCE;
 
 	if (vi->status == v)
 		return;
 
+	if (v & VIRTIO_NET_S_ANNOUNCE) {
+		v &= ~VIRTIO_NET_S_ANNOUNCE;
+		if (v & VIRTIO_NET_S_LINK_UP)
+			schedule_work(&vi->announce);
+	}
+
 	vi->status = v;
 
 	if (vi->status & VIRTIO_NET_S_LINK_UP) {
@@ -1076,6 +1103,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 		goto free;
 
 	INIT_DELAYED_WORK(&vi->refill, refill_work);
+	INIT_WORK(&vi->announce, announce_work);
 	sg_init_table(vi->rx_sg, ARRAY_SIZE(vi->rx_sg));
 	sg_init_table(vi->tx_sg, ARRAY_SIZE(vi->tx_sg));
 
@@ -1187,6 +1215,7 @@ static int virtnet_freeze(struct virtio_device *vdev)
 	virtqueue_disable_cb(vi->svq);
 	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ))
 		virtqueue_disable_cb(vi->cvq);
+	cancel_work_sync(&vi->announce);
 
 	netif_device_detach(vi->dev);
 	cancel_delayed_work_sync(&vi->refill);
@@ -1233,6 +1262,7 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_GUEST_ECN, VIRTIO_NET_F_GUEST_UFO,
 	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ,
 	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN,
+	VIRTIO_NET_F_GUEST_ANNOUNCE,
 };
 
 static struct virtio_driver virtio_net_driver = {
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index 970d5a2..383e8a0 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -49,8 +49,10 @@
 #define VIRTIO_NET_F_CTRL_RX	18	/* Control channel RX mode support */
 #define VIRTIO_NET_F_CTRL_VLAN	19	/* Control channel VLAN filtering */
 #define VIRTIO_NET_F_CTRL_RX_EXTRA 20	/* Extra RX mode control support */
+#define VIRTIO_NET_F_GUEST_ANNOUNCE 21  /* Guest can send gratituous packet */
 
 #define VIRTIO_NET_S_LINK_UP	1	/* Link is up */
+#define VIRTIO_NET_S_ANNOUNCE   2	/* Announcement is needed */
 
 struct virtio_net_config {
 	/* The config defining mac address (if VIRTIO_NET_F_MAC) */
@@ -152,4 +154,15 @@ struct virtio_net_ctrl_mac {
  #define VIRTIO_NET_CTRL_VLAN_ADD             0
  #define VIRTIO_NET_CTRL_VLAN_DEL             1
 
+/*
+ * Control link announce acknowledgement
+ *
+ * The command VIRTIO_NET_CTRL_ANNOUNCE_ACK is used to indicate that
+ * driver has recevied the notification and device would clear the
+ * VIRTIO_NET_S_ANNOUNCE bit in the status filed after it received
+ * this command.
+ */
+#define VIRTIO_NET_CTRL_ANNOUNCE       3
+ #define VIRTIO_NET_CTRL_ANNOUNCE_ACK         0
+
 #endif /* _LINUX_VIRTIO_NET_H */
