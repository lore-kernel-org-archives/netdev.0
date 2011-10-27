From: Jason Wang <jasowang@redhat.com>
Subject: [RFC v3 PATCH 5/4 PATCH] virtio-net: send gratuitous
	packet when	needed
Date: Thu, 27 Oct 2011 16:57:41 +0800
Message-ID: <20111027085740.15655.37609.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: qemu-devel@nongnu.org, kvm@vger.kernel.org
To: aliguori@us.ibm.com, mst@redhat.com, jan.kiszka@siemens.com,
	rusty@rustcorp.com.au, linux-kernel@vger.kernel.org,
	blauwirbel@gmail.com, netdev@vger.kernel.org, stefanha@gmail.com
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

As hypervior does not have the knowledge of guest network
configuration, it's better to ask guest to send gratuitous packet when
needed.

This make let virtio-net driver can send gratuitous packet.

Guest check VIRTIO_NET_S_ANNOUNCE during config change interrupt. When
this bit is set, a workqueue would be scheduled to send gratuitous
packet through NETDEV_NOTIFY_PEERS.

This feature is negotiated through bit VIRTIO_NET_F_GUEST_ANNOUNCE.

Changes from v2:
- Fix the race between unregister_dev() and workqueue

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c   |   32 ++++++++++++++++++++++++++++++--
 include/linux/virtio_net.h |    2 ++
 2 files changed, 32 insertions(+), 2 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index b8225f3..19ee718 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -71,6 +71,9 @@ struct virtnet_info {
 	/* Work struct for refilling if we run low on memory. */
 	struct delayed_work refill;
 
+	/* Work struct for sending gratituous packet. */
+	struct work_struct announce;
+
 	/* Chain pages by the private ptr. */
 	struct page *pages;
 
@@ -507,6 +510,13 @@ static void refill_work(struct work_struct *work)
 		schedule_delayed_work(&vi->refill, HZ/2);
 }
 
+static void announce_work(struct work_struct *work)
+{
+	struct virtnet_info *vi = container_of(work, struct virtnet_info,
+					       announce);
+	netif_notify_peers(vi->dev);
+}
+
 static int virtnet_poll(struct napi_struct *napi, int budget)
 {
 	struct virtnet_info *vi = container_of(napi, struct virtnet_info, napi);
@@ -923,11 +933,23 @@ static void virtnet_update_status(struct virtnet_info *vi)
 			      &v, sizeof(v));
 
 	/* Ignore unknown (future) status bits */
-	v &= VIRTIO_NET_S_LINK_UP;
+	v &= VIRTIO_NET_S_LINK_UP | VIRTIO_NET_S_ANNOUNCE;
 
 	if (vi->status == v)
 		return;
 
+	if (v & VIRTIO_NET_S_ANNOUNCE) {
+		v &= ~VIRTIO_NET_S_ANNOUNCE;
+		vi->vdev->config->set(vi->vdev,
+				      offsetof(struct virtio_net_config,
+					       status),
+				      &v, sizeof(v));
+
+		if ((v & VIRTIO_NET_S_LINK_UP) &&
+		    virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_ANNOUNCE))
+			schedule_work(&vi->announce);
+	}
+
 	vi->status = v;
 
 	if (vi->status & VIRTIO_NET_S_LINK_UP) {
@@ -1016,6 +1038,8 @@ static int virtnet_probe(struct virtio_device *vdev)
 		goto free;
 
 	INIT_DELAYED_WORK(&vi->refill, refill_work);
+	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_ANNOUNCE))
+		INIT_WORK(&vi->announce, announce_work);
 	sg_init_table(vi->rx_sg, ARRAY_SIZE(vi->rx_sg));
 	sg_init_table(vi->tx_sg, ARRAY_SIZE(vi->tx_sg));
 
@@ -1075,6 +1099,8 @@ static int virtnet_probe(struct virtio_device *vdev)
 	return 0;
 
 unregister:
+	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_ANNOUNCE))
+		cancel_work_sync(&vi->announce);
 	unregister_netdev(dev);
 	cancel_delayed_work_sync(&vi->refill);
 free_vqs:
@@ -1115,7 +1141,8 @@ static void __devexit virtnet_remove(struct virtio_device *vdev)
 	/* Stop all the virtqueues. */
 	vdev->config->reset(vdev);
 
-
+	if(virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_ANNOUNCE))
+		cancel_work_sync(&vi->announce);
 	unregister_netdev(vi->dev);
 	cancel_delayed_work_sync(&vi->refill);
 
@@ -1144,6 +1171,7 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_GUEST_ECN, VIRTIO_NET_F_GUEST_UFO,
 	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ,
 	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN,
+	VIRTIO_NET_F_GUEST_ANNOUNCE,
 };
 
 static struct virtio_driver virtio_net_driver = {
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index 970d5a2..44a38d6 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -49,8 +49,10 @@
 #define VIRTIO_NET_F_CTRL_RX	18	/* Control channel RX mode support */
 #define VIRTIO_NET_F_CTRL_VLAN	19	/* Control channel VLAN filtering */
 #define VIRTIO_NET_F_CTRL_RX_EXTRA 20	/* Extra RX mode control support */
+#define VIRTIO_NET_F_GUEST_ANNOUNCE 21  /* Guest can send gratituous packet */
 
 #define VIRTIO_NET_S_LINK_UP	1	/* Link is up */
+#define VIRTIO_NET_S_ANNOUNCE   2       /* Announcement is needed */
 
 struct virtio_net_config {
 	/* The config defining mac address (if VIRTIO_NET_F_MAC) */
