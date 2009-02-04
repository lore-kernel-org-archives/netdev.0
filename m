From: Alex Williamson <alex.williamson@hp.com>
Subject: [PATCH v5 1/4] virtio_net: Add a virtqueue for outbound control
	commands
Date: Wed, 04 Feb 2009 12:02:34 -0700
Message-ID: <20090204190234.2512.55769.stgit@debian.lart>
References: <20090204190229.2512.93552.stgit@debian.lart>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, markmc@redhat.com, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:15595 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760899AbZBDTFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 14:05:30 -0500
In-Reply-To: <20090204190229.2512.93552.stgit@debian.lart>
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
Acked-by: Rusty Russell <rusty@rustcorp.com.au>
---

 drivers/net/virtio_net.c   |   68 ++++++++++++++++++++++++++++++++++++++++++--
 include/linux/virtio_net.h |   18 ++++++++++++
 2 files changed, 83 insertions(+), 3 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index fe576e7..67bb583 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -37,10 +37,12 @@ module_param(gso, bool, 0444);
 #define MAX_PACKET_LEN (ETH_HLEN + VLAN_HLEN + ETH_DATA_LEN)
 #define GOOD_COPY_LEN	128
 
+#define VIRTNET_SEND_COMMAND_SG_MAX    0
+
 struct virtnet_info
 {
 	struct virtio_device *vdev;
-	struct virtqueue *rvq, *svq;
+	struct virtqueue *rvq, *svq, *cvq;
 	struct net_device *dev;
 	struct napi_struct napi;
 	unsigned int status;
@@ -589,6 +591,53 @@ static int virtnet_open(struct net_device *dev)
 	return 0;
 }
 
+/*
+ * Send command via the control virtqueue and check status.  Commands
+ * supported by the hypervisor, as indicated by feature bits, should
+ * never fail unless improperly formated.
+ */
+static bool virtnet_send_command(struct virtnet_info *vi, u8 class, u8 cmd,
+				 struct scatterlist *data, int out, int in)
+{
+	struct scatterlist sg[VIRTNET_SEND_COMMAND_SG_MAX + 2];
+	struct virtio_net_ctrl_hdr ctrl;
+	virtio_net_ctrl_ack status = ~0;
+	unsigned int tmp;
+
+	if (!virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ)) {
+		BUG();  /* Caller should know better */
+		return false;
+	}
+
+	BUG_ON(out + in > VIRTNET_SEND_COMMAND_SG_MAX);
+
+	out++; /* Add header */
+	in++; /* Add return status */
+
+	ctrl.class = class;
+	ctrl.cmd = cmd;
+
+	sg_init_table(sg, out + in);
+
+	sg_set_buf(&sg[0], &ctrl, sizeof(ctrl));
+	memcpy(&sg[1], data, sizeof(struct scatterlist) * (out + in - 2));
+	sg_set_buf(&sg[out + in - 1], &status, sizeof(status));
+
+	if (vi->cvq->vq_ops->add_buf(vi->cvq, sg, out, in, vi) != 0)
+		BUG();
+
+	vi->cvq->vq_ops->kick(vi->cvq);
+
+	/*
+	 * Spin for a response, the kick causes an ioport write, trapping
+	 * into the hypervisor, so the request should be handled immediately.
+	 */
+	while (!vi->cvq->vq_ops->get_buf(vi->cvq, &tmp))
+		cpu_relax();
+
+	return status == VIRTIO_NET_OK;
+}
+
 static int virtnet_close(struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
@@ -752,6 +801,14 @@ static int virtnet_probe(struct virtio_device *vdev)
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
@@ -764,7 +821,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 	err = register_netdev(dev);
 	if (err) {
 		pr_debug("virtio_net: registering device failed\n");
-		goto free_send;
+		goto free_ctrl;
 	}
 
 	/* Last of all, set up some receive buffers. */
@@ -784,6 +841,9 @@ static int virtnet_probe(struct virtio_device *vdev)
 
 unregister:
 	unregister_netdev(dev);
+free_ctrl:
+	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ))
+		vdev->config->del_vq(vi->cvq);
 free_send:
 	vdev->config->del_vq(vi->svq);
 free_recv:
@@ -815,6 +875,8 @@ static void virtnet_remove(struct virtio_device *vdev)
 
 	vdev->config->del_vq(vi->svq);
 	vdev->config->del_vq(vi->rvq);
+	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ))
+		vdev->config->del_vq(vi->cvq);
 	unregister_netdev(vi->dev);
 
 	while (vi->pages)
@@ -834,7 +896,7 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_HOST_TSO4, VIRTIO_NET_F_HOST_UFO, VIRTIO_NET_F_HOST_TSO6,
 	VIRTIO_NET_F_HOST_ECN, VIRTIO_NET_F_GUEST_TSO4, VIRTIO_NET_F_GUEST_TSO6,
 	VIRTIO_NET_F_GUEST_ECN, /* We don't yet handle UFO input. */
-	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS,
+	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ,
 	VIRTIO_F_NOTIFY_ON_EMPTY,
 };
 
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index d8e362d..245eda8 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -23,6 +23,7 @@
 #define VIRTIO_NET_F_HOST_UFO	14	/* Host can handle UFO in. */
 #define VIRTIO_NET_F_MRG_RXBUF	15	/* Host can merge receive buffers. */
 #define VIRTIO_NET_F_STATUS	16	/* virtio_net_config.status available */
+#define VIRTIO_NET_F_CTRL_VQ	17	/* Control channel available */
 
 #define VIRTIO_NET_S_LINK_UP	1	/* Link is up */
 
@@ -59,4 +60,21 @@ struct virtio_net_hdr_mrg_rxbuf {
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

