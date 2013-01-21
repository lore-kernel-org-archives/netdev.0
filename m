From: Amos Kong <akong@redhat.com>
Subject: [PATCH v5 1/3] move virtnet_send_command() above virtnet_set_mac_address()
Date: Mon, 21 Jan 2013 19:17:21 +0800
Message-ID: <1358767043-24548-2-git-send-email-akong@redhat.com>
References: <1358767043-24548-1-git-send-email-akong@redhat.com>
Cc: mst@redhat.com, rusty@rustcorp.com.au, qemu-devel@nongnu.org,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1358767043-24548-1-git-send-email-akong@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We want to send vq command to set mac address in
virtnet_set_mac_address(), so do this function moving.
Fixed a little issue of coding style.

Signed-off-by: Amos Kong <akong@redhat.com>
---
 drivers/net/virtio_net.c |   89 ++++++++++++++++++++++-----------------------
 1 files changed, 44 insertions(+), 45 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index a6fcf15..395ab4f 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -753,6 +753,50 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+/*
+ * Send command via the control virtqueue and check status.  Commands
+ * supported by the hypervisor, as indicated by feature bits, should
+ * never fail unless improperly formated.
+ */
+static bool virtnet_send_command(struct virtnet_info *vi, u8 class, u8 cmd,
+				 struct scatterlist *data, int out, int in)
+{
+	struct scatterlist *s, sg[VIRTNET_SEND_COMMAND_SG_MAX + 2];
+	struct virtio_net_ctrl_hdr ctrl;
+	virtio_net_ctrl_ack status = ~0;
+	unsigned int tmp;
+	int i;
+
+	/* Caller should know better */
+	BUG_ON(!virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ) ||
+		(out + in > VIRTNET_SEND_COMMAND_SG_MAX));
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
+	for_each_sg(data, s, out + in - 2, i)
+		sg_set_buf(&sg[i + 1], sg_virt(s), s->length);
+	sg_set_buf(&sg[out + in - 1], &status, sizeof(status));
+
+	BUG_ON(virtqueue_add_buf(vi->cvq, sg, out, in, vi, GFP_ATOMIC) < 0);
+
+	virtqueue_kick(vi->cvq);
+
+	/* Spin for a response, the kick causes an ioport write, trapping
+	 * into the hypervisor, so the request should be handled immediately.
+	 */
+	while (!virtqueue_get_buf(vi->cvq, &tmp))
+		cpu_relax();
+
+	return status == VIRTIO_NET_OK;
+}
+
 static int virtnet_set_mac_address(struct net_device *dev, void *p)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
@@ -819,51 +863,6 @@ static void virtnet_netpoll(struct net_device *dev)
 }
 #endif
 
-/*
- * Send command via the control virtqueue and check status.  Commands
- * supported by the hypervisor, as indicated by feature bits, should
- * never fail unless improperly formated.
- */
-static bool virtnet_send_command(struct virtnet_info *vi, u8 class, u8 cmd,
-				 struct scatterlist *data, int out, int in)
-{
-	struct scatterlist *s, sg[VIRTNET_SEND_COMMAND_SG_MAX + 2];
-	struct virtio_net_ctrl_hdr ctrl;
-	virtio_net_ctrl_ack status = ~0;
-	unsigned int tmp;
-	int i;
-
-	/* Caller should know better */
-	BUG_ON(!virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ) ||
-		(out + in > VIRTNET_SEND_COMMAND_SG_MAX));
-
-	out++; /* Add header */
-	in++; /* Add return status */
-
-	ctrl.class = class;
-	ctrl.cmd = cmd;
-
-	sg_init_table(sg, out + in);
-
-	sg_set_buf(&sg[0], &ctrl, sizeof(ctrl));
-	for_each_sg(data, s, out + in - 2, i)
-		sg_set_buf(&sg[i + 1], sg_virt(s), s->length);
-	sg_set_buf(&sg[out + in - 1], &status, sizeof(status));
-
-	BUG_ON(virtqueue_add_buf(vi->cvq, sg, out, in, vi, GFP_ATOMIC) < 0);
-
-	virtqueue_kick(vi->cvq);
-
-	/*
-	 * Spin for a response, the kick causes an ioport write, trapping
-	 * into the hypervisor, so the request should be handled immediately.
-	 */
-	while (!virtqueue_get_buf(vi->cvq, &tmp))
-		cpu_relax();
-
-	return status == VIRTIO_NET_OK;
-}
-
 static void virtnet_ack_link_announce(struct virtnet_info *vi)
 {
 	rtnl_lock();
-- 
1.7.1

