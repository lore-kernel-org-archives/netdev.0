From: Jason Wang <jasowang@redhat.com>
Subject: [RFC v2 PATCH 5/4 PATCH] virtio-net: send gratuitous packet when
	needed
Date: Sat, 22 Oct 2011 13:43:11 +0800
Message-ID: <20111022054311.21798.3340.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: pbonzini@redhat.com, rusty@rustcorp.com.au, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: aliguori@us.ibm.com, quintela@redhat.com, jan.kiszka@siemens.com,
	mst@redhat.com, qemu-devel@nongnu.org, blauwirbel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59140 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750927Ab1JVFnW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Oct 2011 01:43:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This make let virtio-net driver can send gratituous packet by a new
config bit - VIRTIO_NET_S_ANNOUNCE in each config update
interrupt. When this bit is set by backend, the driver would schedule
a workqueue to send gratituous packet through NETDEV_NOTIFY_PEERS.

This feature is negotiated through bit VIRTIO_NET_F_GUEST_ANNOUNCE.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c   |   31 ++++++++++++++++++++++++++++++-
 include/linux/virtio_net.h |    2 ++
 2 files changed, 32 insertions(+), 1 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index b8225f3..1cdecf7 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -71,6 +71,9 @@ struct virtnet_info {
 	/* Work struct for refilling if we run low on memory. */
 	struct delayed_work refill;
 
+	/* Work struct for send gratituous packet. */
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
@@ -923,11 +933,22 @@ static void virtnet_update_status(struct virtnet_info *vi)
 			      &v, sizeof(v));
 
 	/* Ignore unknown (future) status bits */
-	v &= VIRTIO_NET_S_LINK_UP;
+	v &= VIRTIO_NET_S_LINK_UP | VIRTIO_NET_S_ANNOUNCE;
 
 	if (vi->status == v)
 		return;
 
+	if (v & VIRTIO_NET_S_ANNOUNCE) {
+		if ((v & VIRTIO_NET_S_LINK_UP) &&
+		    virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_ANNOUNCE))
+			schedule_work(&vi->announce);
+		v &= ~VIRTIO_NET_S_ANNOUNCE;
+                vi->vdev->config->set(vi->vdev,
+                                      offsetof(struct virtio_net_config,
+		                               status),
+                                      &v, sizeof(v));
+	}
+
 	vi->status = v;
 
 	if (vi->status & VIRTIO_NET_S_LINK_UP) {
@@ -937,6 +958,7 @@ static void virtnet_update_status(struct virtnet_info *vi)
 		netif_carrier_off(vi->dev);
 		netif_stop_queue(vi->dev);
 	}
+
 }
 
 static void virtnet_config_changed(struct virtio_device *vdev)
@@ -1016,6 +1038,8 @@ static int virtnet_probe(struct virtio_device *vdev)
 		goto free;
 
 	INIT_DELAYED_WORK(&vi->refill, refill_work);
+	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_ANNOUNCE))
+		INIT_WORK(&vi->announce, announce_work);
 	sg_init_table(vi->rx_sg, ARRAY_SIZE(vi->rx_sg));
 	sg_init_table(vi->tx_sg, ARRAY_SIZE(vi->tx_sg));
 
@@ -1077,6 +1101,8 @@ static int virtnet_probe(struct virtio_device *vdev)
 unregister:
 	unregister_netdev(dev);
 	cancel_delayed_work_sync(&vi->refill);
+	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_ANNOUNCE))
+		cancel_work_sync(&vi->announce);
 free_vqs:
 	vdev->config->del_vqs(vdev);
 free_stats:
@@ -1118,6 +1144,8 @@ static void __devexit virtnet_remove(struct virtio_device *vdev)
 
 	unregister_netdev(vi->dev);
 	cancel_delayed_work_sync(&vi->refill);
+	if(virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_ANNOUNCE))
+		cancel_work_sync(&vi->announce);
 
 	/* Free unused buffers in both send and recv, if any. */
 	free_unused_bufs(vi);
@@ -1144,6 +1172,7 @@ static unsigned int features[] = {
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
