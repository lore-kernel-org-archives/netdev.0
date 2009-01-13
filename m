From: Alex Williamson <alex.williamson@hp.com>
Subject: [PATCH 2/4] virtio_net: Add a virtqueue for outbound control
 commands
Date: Tue, 13 Jan 2009 14:23:17 -0700
Message-ID: <1231881797.9095.187.camel@bling>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kvm <kvm@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Mark McLoughlin <markmc@redhat.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This will be used for RX mode, MAC filter table, VLAN filtering, etc...

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
---

 drivers/net/virtio_net.c   |   55 +++++++++++++++++++++++++++++++++++++++++++-
 include/linux/virtio_net.h |    3 ++
 2 files changed, 57 insertions(+), 1 deletions(-)


diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index e7700de..de348de 100644
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
 
@@ -603,6 +603,47 @@ static int virtnet_open(struct net_device *dev)
 	return 0;
 }
 
+static int virtnet_send_command(struct virtnet_info *vi, u8 class, u8 cmd,
+				void *data, unsigned int len)
+{
+	struct scatterlist sg[3];
+	struct {
+		u8 class;
+		u8 cmd;
+	} ctrl_cmd;
+	u8 ctrl_status;
+	unsigned int tmp;
+	int i = 0;
+
+	if (!vi->cvq)
+		return -EFAULT;
+
+	sg_init_table(sg, len ? 3 : 2);
+
+	sg_set_buf(&sg[i++], &ctrl_cmd, sizeof(ctrl_cmd));
+	if (len)
+		sg_set_buf(&sg[i++], data, len);
+	sg_set_buf(&sg[i], &ctrl_status, sizeof(ctrl_status));
+
+	ctrl_cmd.class = class;
+	ctrl_cmd.cmd = cmd;
+
+	ctrl_status = ~0;
+
+	if (vi->cvq->vq_ops->add_buf(vi->cvq, sg, i, 1, vi) != 0)
+		BUG();
+
+	vi->cvq->vq_ops->kick(vi->cvq);
+
+	while (!vi->cvq->vq_ops->get_buf(vi->cvq, &tmp))
+		cpu_relax();
+
+	if (ctrl_status == VIRTIO_NET_OK)
+		return 0;
+	else
+		return -EFAULT;
+}
+
 static int virtnet_close(struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
@@ -733,6 +774,14 @@ static int virtnet_probe(struct virtio_device *vdev)
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
@@ -763,6 +812,8 @@ static int virtnet_probe(struct virtio_device *vdev)
 unregister:
 	unregister_netdev(dev);
 free_send:
+	if (vi->cvq)
+		vdev->config->del_vq(vi->cvq);
 	vdev->config->del_vq(vi->svq);
 free_recv:
 	vdev->config->del_vq(vi->rvq);
@@ -793,6 +844,8 @@ static void virtnet_remove(struct virtio_device *vdev)
 
 	vdev->config->del_vq(vi->svq);
 	vdev->config->del_vq(vi->rvq);
+	if (vi->cvq)
+		vdev->config->del_vq(vi->cvq);
 	unregister_netdev(vi->dev);
 
 	while (vi->pages)
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index 5cdd0aa..1de7c86 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -53,4 +53,7 @@ struct virtio_net_hdr_mrg_rxbuf {
 	__u16 num_buffers;	/* Number of merged rx buffers */
 };
 
+#define VIRTIO_NET_OK     0
+#define VIRTIO_NET_ERR    1
+
 #endif /* _LINUX_VIRTIO_NET_H */


