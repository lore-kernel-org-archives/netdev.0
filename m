From: Jason Wang <jasowang@redhat.com>
Subject: [V5 PATCH] virtio-net: send gratuitous packets when needed
Date: Fri, 16 Mar 2012 17:01:01 +0800
Message-ID: <20120316090100.5223.50783.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, rusty@rustcorp.com.au,
	virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
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
 drivers/net/virtio_net.c   |   27 ++++++++++++++++++++++++++-
 include/linux/virtio_net.h |    2 ++
 2 files changed, 28 insertions(+), 1 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 4880aa8..450d358 100644
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
 
@@ -512,6 +515,13 @@ static void refill_work(struct work_struct *work)
 		queue_delayed_work(system_nrt_wq, &vi->refill, HZ/2);
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
@@ -787,6 +797,7 @@ static int virtnet_close(struct net_device *dev)
 
 	/* Make sure refill_work doesn't re-enable napi! */
 	cancel_delayed_work_sync(&vi->refill);
+	cancel_work_sync(&vi->announce);
 	napi_disable(&vi->napi);
 
 	return 0;
@@ -962,11 +973,22 @@ static void virtnet_update_status(struct virtnet_info *vi)
 		return;
 
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
+		if (v & VIRTIO_NET_S_LINK_UP)
+			schedule_work(&vi->announce);
+	}
+
 	vi->status = v;
 
 	if (vi->status & VIRTIO_NET_S_LINK_UP) {
@@ -1076,6 +1098,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 		goto free;
 
 	INIT_DELAYED_WORK(&vi->refill, refill_work);
+	INIT_WORK(&vi->announce, announce_work);
 	sg_init_table(vi->rx_sg, ARRAY_SIZE(vi->rx_sg));
 	sg_init_table(vi->tx_sg, ARRAY_SIZE(vi->tx_sg));
 
@@ -1187,6 +1210,7 @@ static int virtnet_freeze(struct virtio_device *vdev)
 	virtqueue_disable_cb(vi->svq);
 	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ))
 		virtqueue_disable_cb(vi->cvq);
+	cancel_work_sync(&vi->announce);
 
 	netif_device_detach(vi->dev);
 	cancel_delayed_work_sync(&vi->refill);
@@ -1233,6 +1257,7 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_GUEST_ECN, VIRTIO_NET_F_GUEST_UFO,
 	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ,
 	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN,
+	VIRTIO_NET_F_GUEST_ANNOUNCE,
 };
 
 static struct virtio_driver virtio_net_driver = {
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index 970d5a2..5094c2d 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -49,8 +49,10 @@
 #define VIRTIO_NET_F_CTRL_RX	18	/* Control channel RX mode support */
 #define VIRTIO_NET_F_CTRL_VLAN	19	/* Control channel VLAN filtering */
 #define VIRTIO_NET_F_CTRL_RX_EXTRA 20	/* Extra RX mode control support */
+#define VIRTIO_NET_F_GUEST_ANNOUNCE 21  /* Guest can send gratituous packet */
 
 #define VIRTIO_NET_S_LINK_UP	1	/* Link is up */
+#define VIRTIO_NET_S_ANNOUNCE   0x100   /* Announcement is needed */
 
 struct virtio_net_config {
 	/* The config defining mac address (if VIRTIO_NET_F_MAC) */
