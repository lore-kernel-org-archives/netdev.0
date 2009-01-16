From: Alex Williamson <alex.williamson@hp.com>
Subject: [PATCH 2/5] virtio_net: Add a virtqueue for outbound control commands
Date: Fri, 16 Jan 2009 14:13:23 -0700
Message-ID: <20090116211323.22836.40477.stgit@debian.lart>
References: <20090116211312.22836.34331.stgit@debian.lart>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, markmc@redhat.com, kvm@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:39974 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763245AbZAPVPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 16:15:16 -0500
In-Reply-To: <20090116211312.22836.34331.stgit@debian.lart>
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

 drivers/net/virtio_net.c   |   49 +++++++++++++++++++++++++++++++++++++++++++-
 include/linux/virtio_net.h |   17 +++++++++++++++
 2 files changed, 65 insertions(+), 1 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index e7700de..d4be0a2 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -39,7 +39,7 @@ module_param(gso, bool, 0444);
 struct virtnet_info
 {
 	struct virtio_device *vdev;
-	struct virtqueue *rvq, *svq;
+	struct virtqueue *rvq, *svq, *cvq;
 	struct net_device *dev;
 	struct napi_struct napi;
 
@@ -603,6 +603,41 @@ static int virtnet_open(struct net_device *dev)
 	return 0;
 }
 
+static int virtnet_send_command(struct virtnet_info *vi, u8 class, u8 cmd,
+				void *data, unsigned int len)
+{
+	struct scatterlist sg[3];
+	struct virtio_net_ctrl_hdr ctrl;
+	virtio_net_ctrl_ack status;
+	unsigned int tmp;
+	int i = 0;
+
+	if (!vi->cvq)
+		return -EIO;
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
+	return status ? -EFAULT : 0;
+}
+
 static int virtnet_close(struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
@@ -733,6 +768,14 @@ static int virtnet_probe(struct virtio_device *vdev)
 		goto free_recv;
 	}
 
+	/*
+	 * Outbound control channel virtqueue.  We can live without it,
+	 * so don't go fatal if it's not there.
+	 */
+	vi->cvq = vdev->config->find_vq(vdev, 2, NULL);
+	if (IS_ERR(vi->cvq))
+		vi->cvq = NULL;
+
 	/* Initialize our empty receive and send queues. */
 	skb_queue_head_init(&vi->recv);
 	skb_queue_head_init(&vi->send);
@@ -763,6 +806,8 @@ static int virtnet_probe(struct virtio_device *vdev)
 unregister:
 	unregister_netdev(dev);
 free_send:
+	if (vi->cvq)
+		vdev->config->del_vq(vi->cvq);
 	vdev->config->del_vq(vi->svq);
 free_recv:
 	vdev->config->del_vq(vi->rvq);
@@ -793,6 +838,8 @@ static void virtnet_remove(struct virtio_device *vdev)
 
 	vdev->config->del_vq(vi->svq);
 	vdev->config->del_vq(vi->rvq);
+	if (vi->cvq)
+		vdev->config->del_vq(vi->cvq);
 	unregister_netdev(vi->dev);
 
 	while (vi->pages)
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index 5cdd0aa..e2c1d81 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -53,4 +53,21 @@ struct virtio_net_hdr_mrg_rxbuf {
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
+};
+
+typedef __u8 virtio_net_ctrl_ack;
+
+#define VIRTIO_NET_OK     0
+#define VIRTIO_NET_ERR    1
+
 #endif /* _LINUX_VIRTIO_NET_H */

