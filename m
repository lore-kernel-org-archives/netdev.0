From: akong@redhat.com
Subject: [PATCH v3 1/2] move virtnet_send_command() above
	virtnet_set_mac_address()
Date: Thu, 17 Jan 2013 18:40:11 +0800
Message-ID: <1358419212-32356-2-git-send-email-akong@redhat.com>
References: <1358419212-32356-1-git-send-email-akong@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, qemu-devel@nongnu.org,
	virtualization@lists.linux-foundation.org, davem@davemloft.net
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1358419212-32356-1-git-send-email-akong@redhat.com>
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

From: Amos Kong <akong@redhat.com>

We will send vq command to set mac address in virtnet_set_mac_address()
a little fix of coding style

Signed-off-by: Amos Kong <akong@redhat.com>
---
 drivers/net/virtio_net.c | 89 ++++++++++++++++++++++++------------------------
 1 file changed, 44 insertions(+), 45 deletions(-)

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
1.7.11.7
