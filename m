From: Mark McLoughlin <markmc@redhat.com>
Subject: [PATCH] virtio_net: add link status handling
Date: Tue, 09 Dec 2008 10:19:33 +0000
Message-ID: <1228817973.26198.1.camel@blaa>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, kvm <kvm@vger.kernel.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow the host to inform us that the link is down by adding
a VIRTIO_NET_F_STATUS which indicates that device status is
available in virtio_net config.

This is currently useful for simulating link down conditions
(e.g. using proposed qemu 'set_link' monitor command) but
would also be needed if we were to support device assignment
via virtio.

Signed-off-by: Mark McLoughlin <markmc@redhat.com>
---
 drivers/net/virtio_net.c   |   40 +++++++++++++++++++++++++++++++++++++++-
 include/linux/virtio_net.h |    5 +++++
 2 files changed, 44 insertions(+), 1 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 71ca29c..128c38d 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -42,6 +42,7 @@ struct virtnet_info
 	struct virtqueue *rvq, *svq;
 	struct net_device *dev;
 	struct napi_struct napi;
+	unsigned int status;
 
 	/* The skb we couldn't send because buffers were full. */
 	struct sk_buff *last_xmit_skb;
@@ -611,6 +612,7 @@ static struct ethtool_ops virtnet_ethtool_ops = {
 	.set_tx_csum = virtnet_set_tx_csum,
 	.set_sg = ethtool_op_set_sg,
 	.set_tso = ethtool_op_set_tso,
+	.get_link = ethtool_op_get_link,
 };
 
 #define MIN_MTU 68
@@ -624,6 +626,38 @@ static int virtnet_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
+static void virtnet_update_status(struct virtnet_info *vi)
+{
+	u16 v;
+
+	if (!virtio_has_feature(vi->vdev, VIRTIO_NET_F_STATUS))
+		return;
+
+        vi->vdev->config->get(vi->vdev,
+                              offsetof(struct virtio_net_config, status),
+                              &v, sizeof(v));
+
+	if (vi->status == v)
+		return;
+
+	vi->status = v;
+
+	if (vi->status & VIRTIO_NET_S_LINK_UP) {
+		netif_carrier_on(vi->dev);
+		netif_wake_queue(vi->dev);
+	} else {
+		netif_carrier_off(vi->dev);
+		netif_stop_queue(vi->dev);
+	}
+}
+
+static void virtnet_config_changed(struct virtio_device *vdev)
+{
+	struct virtnet_info *vi = vdev->priv;
+
+	virtnet_update_status(vi);
+}
+
 static int virtnet_probe(struct virtio_device *vdev)
 {
 	int err;
@@ -732,6 +766,9 @@ static int virtnet_probe(struct virtio_device *vdev)
 		goto unregister;
 	}
 
+	vi->status = VIRTIO_NET_S_LINK_UP;
+	virtnet_update_status(vi);
+
 	pr_debug("virtnet: registered device %s\n", dev->name);
 	return 0;
 
@@ -787,7 +824,7 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_HOST_TSO4, VIRTIO_NET_F_HOST_UFO, VIRTIO_NET_F_HOST_TSO6,
 	VIRTIO_NET_F_HOST_ECN, VIRTIO_NET_F_GUEST_TSO4, VIRTIO_NET_F_GUEST_TSO6,
 	VIRTIO_NET_F_GUEST_ECN, /* We don't yet handle UFO input. */
-	VIRTIO_NET_F_MRG_RXBUF,
+	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS,
 	VIRTIO_F_NOTIFY_ON_EMPTY,
 };
 
@@ -799,6 +836,7 @@ static struct virtio_driver virtio_net = {
 	.id_table =	id_table,
 	.probe =	virtnet_probe,
 	.remove =	__devexit_p(virtnet_remove),
+	.config_changed = virtnet_config_changed,
 };
 
 static int __init init(void)
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index 5cdd0aa..f76bd4a 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -21,11 +21,16 @@
 #define VIRTIO_NET_F_HOST_ECN	13	/* Host can handle TSO[6] w/ ECN in. */
 #define VIRTIO_NET_F_HOST_UFO	14	/* Host can handle UFO in. */
 #define VIRTIO_NET_F_MRG_RXBUF	15	/* Host can merge receive buffers. */
+#define VIRTIO_NET_F_STATUS	16	/* virtio_net_config.status available */
+
+#define VIRTIO_NET_S_LINK_UP	1	/* Link is up */
 
 struct virtio_net_config
 {
 	/* The config defining mac address (if VIRTIO_NET_F_MAC) */
 	__u8 mac[6];
+	/* See VIRTIO_NET_F_STATUS and VIRTIO_NET_S_* above */
+	__u16 status;
 } __attribute__((packed));
 
 /* This is the first element of the scatter-gather list.  If you don't
-- 
1.6.0.3

