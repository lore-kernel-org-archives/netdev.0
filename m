From: Alex Williamson <alex.williamson@hp.com>
Subject: [PATCH v2 1/4] virtio_net: Add a virtqueue for outbound control
	commands
Date: Thu, 29 Jan 2009 16:05:07 -0700
Message-ID: <20090129230507.2672.97837.stgit@debian.lart>
References: <20090129230502.2672.87669.stgit@debian.lart>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: markmc@redhat.com, netdev@vger.kernel.org, kvm@vger.kernel.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:30854 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753068AbZA2XHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 18:07:43 -0500
In-Reply-To: <20090129230502.2672.87669.stgit@debian.lart>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will be used for RX mode, MAC filter table, VLAN filtering, etc...

The control transaction consists of one or more "out" sg entries and
one or more "in" sg entries.  The first out entry contains a header
defining the class and command.  Additional out entries may provide
data for the command.  The last in entry provides a status response
back from the command.

Virtqueues typically run asynchronous, running a callback function
when there's data in the channel.  We can't readily make use of this
in the command paths where we need to use this.  Instead, we kick
the virtqueue and spin.  The kick causes an I/O write, triggering an
immediate trap into the hypervisor.

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
---

 drivers/net/virtio_net.c   |   54 ++++++++++++++++++++++++++++++++++++++++++--
 include/linux/virtio_net.h |   18 +++++++++++++++
 2 files changed, 69 insertions(+), 3 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index bf65978..c909444 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -40,7 +40,7 @@ module_param(gso, bool, 0444);
 struct virtnet_info
 {
 	struct virtio_device *vdev;
-	struct virtqueue *rvq, *svq;
+	struct virtqueue *rvq, *svq, *cvq;
 	struct net_device *dev;
 	struct napi_struct napi;
 	unsigned int status;
@@ -605,6 +605,41 @@ static int virtnet_open(struct net_device *dev)
 	return 0;
 }
 
+static bool virtnet_send_command(struct virtnet_info *vi, u8 class, u8 cmd,
+				 void *data, unsigned int len)
+{
+	struct scatterlist sg[3];
+	struct virtio_net_ctrl_hdr ctrl;
+	virtio_net_ctrl_ack status;
+	unsigned int tmp;
+	int i = 0;
+
+	if (!virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ))
+		return false;
+
+	sg_init_table(sg, len ? 3 : 2);
+
+	sg_set_buf(&sg[i++], &ctrl, sizeof(ctrl));
+	if (len)
+		sg_set_buf(&sg[i++], data, len);
+	sg_set_buf(&sg[i], &status, sizeof(status));
+
+	ctrl.class = class;
+	ctrl.cmd = cmd;
+
+	status = ~0;
+
+	if (vi->cvq->vq_ops->add_buf(vi->cvq, sg, i, 1, vi) != 0)
+		BUG();
+
+	vi->cvq->vq_ops->kick(vi->cvq);
+
+	while (!vi->cvq->vq_ops->get_buf(vi->cvq, &tmp))
+		cpu_relax();
+
+	return status == VIRTIO_NET_OK ? true : false;
+}
+
 static int virtnet_close(struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
@@ -771,6 +806,14 @@ static int virtnet_probe(struct virtio_device *vdev)
 		goto free_recv;
 	}
 
+	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ)) {
+		vi->cvq = vdev->config->find_vq(vdev, 2, NULL);
+		if (IS_ERR(vi->cvq)) {
+			err = PTR_ERR(vi->svq);
+			goto free_send;
+		}
+	}
+
 	/* Initialize our empty receive and send queues. */
 	skb_queue_head_init(&vi->recv);
 	skb_queue_head_init(&vi->send);
@@ -783,7 +826,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 	err = register_netdev(dev);
 	if (err) {
 		pr_debug("virtio_net: registering device failed\n");
-		goto free_send;
+		goto free_ctrl;
 	}
 
 	/* Last of all, set up some receive buffers. */
@@ -803,6 +846,9 @@ static int virtnet_probe(struct virtio_device *vdev)
 
 unregister:
 	unregister_netdev(dev);
+free_ctrl:
+	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ))
+		vdev->config->del_vq(vi->cvq);
 free_send:
 	vdev->config->del_vq(vi->svq);
 free_recv:
@@ -834,6 +880,8 @@ static void virtnet_remove(struct virtio_device *vdev)
 
 	vdev->config->del_vq(vi->svq);
 	vdev->config->del_vq(vi->rvq);
+	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ))
+		vdev->config->del_vq(vi->cvq);
 	unregister_netdev(vi->dev);
 
 	while (vi->pages)
@@ -853,7 +901,7 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_HOST_TSO4, VIRTIO_NET_F_HOST_UFO, VIRTIO_NET_F_HOST_TSO6,
 	VIRTIO_NET_F_HOST_ECN, VIRTIO_NET_F_GUEST_TSO4, VIRTIO_NET_F_GUEST_TSO6,
 	VIRTIO_NET_F_GUEST_ECN, /* We don't yet handle UFO input. */
-	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS,
+	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ,
 	VIRTIO_F_NOTIFY_ON_EMPTY,
 };
 
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index f76bd4a..fd0981c 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -22,6 +22,7 @@
 #define VIRTIO_NET_F_HOST_UFO	14	/* Host can handle UFO in. */
 #define VIRTIO_NET_F_MRG_RXBUF	15	/* Host can merge receive buffers. */
 #define VIRTIO_NET_F_STATUS	16	/* virtio_net_config.status available */
+#define VIRTIO_NET_F_CTRL_VQ	17	/* Control channel available */
 
 #define VIRTIO_NET_S_LINK_UP	1	/* Link is up */
 
@@ -58,4 +59,21 @@ struct virtio_net_hdr_mrg_rxbuf {
 	__u16 num_buffers;	/* Number of merged rx buffers */
 };
 
+/*
+ * Control virtqueue data structures
+ *
+ * The control virtqueue expects a header in the first sg entry
+ * and an ack/status response in the last entry.  Data for the
+ * command goes in between.
+ */
+struct virtio_net_ctrl_hdr {
+	__u8 class;
+	__u8 cmd;
+} __attribute__((packed));
+
+typedef __u8 virtio_net_ctrl_ack;
+
+#define VIRTIO_NET_OK     0
+#define VIRTIO_NET_ERR    1
+
 #endif /* _LINUX_VIRTIO_NET_H */

