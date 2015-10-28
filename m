From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v2 1/3] virtio_net: Stop doing DMA from the stack
Date: Tue, 27 Oct 2015 22:30:19 -0700
Message-ID: <b049d57c66d2fa62e0bafa9cf982de62310f4423.1446009834.git.luto@kernel.org>
References: <cover.1446009834.git.luto@kernel.org>
Cc: Joerg Roedel <jroedel@suse.de>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	Sebastian Ott <sebott@linux.vnet.ibm.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Christoph Hellwig <hch@lst.de>, benh@kernel.crashing.org,
	KVM <kvm@vger.kernel.org>, dwmw2@infradead.org,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	linux-s390 <linux-s390@vger.kernel.org>,
	Andy Lutomirski <luto@amacapital.net>, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org,
	Andy Lutomirski <luto@kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1446009834.git.luto@kernel.org>
In-Reply-To: <cover.1446009834.git.luto@kernel.org>
References: <cover.1446009834.git.luto@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Lutomirski <luto@amacapital.net>

Once virtio starts using the DMA API, we won't be able to safely DMA
from the stack.  virtio-net does a couple of config DMA requests
from small stack buffers -- switch to using dynamically-allocated
memory.

This should have no effect on any performance-critical code paths.

Cc: netdev@vger.kernel.org
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtualization@lists.linux-foundation.org
Reviewed-by: Joerg Roedel <jroedel@suse.de>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---

Hi Michael and DaveM-

This is a prerequisite for the virtio DMA fixing project.  It works
as a standalone patch, though.  Would it make sense to apply it to
an appropriate networking tree now?

 drivers/net/virtio_net.c | 53 ++++++++++++++++++++++++++++++++----------------
 1 file changed, 36 insertions(+), 17 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index d8838dedb7a4..4f10f8a58811 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -976,31 +976,43 @@ static bool virtnet_send_command(struct virtnet_info *vi, u8 class, u8 cmd,
 				 struct scatterlist *out)
 {
 	struct scatterlist *sgs[4], hdr, stat;
-	struct virtio_net_ctrl_hdr ctrl;
-	virtio_net_ctrl_ack status = ~0;
+
+	struct {
+		struct virtio_net_ctrl_hdr ctrl;
+		virtio_net_ctrl_ack status;
+	} *buf;
+
 	unsigned out_num = 0, tmp;
+	bool ret;
 
 	/* Caller should know better */
 	BUG_ON(!virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ));
 
-	ctrl.class = class;
-	ctrl.cmd = cmd;
+	buf = kmalloc(sizeof(*buf), GFP_ATOMIC);
+	if (!buf)
+		return false;
+	buf->status = ~0;
+
+	buf->ctrl.class = class;
+	buf->ctrl.cmd = cmd;
 	/* Add header */
-	sg_init_one(&hdr, &ctrl, sizeof(ctrl));
+	sg_init_one(&hdr, &buf->ctrl, sizeof(buf->ctrl));
 	sgs[out_num++] = &hdr;
 
 	if (out)
 		sgs[out_num++] = out;
 
 	/* Add return status. */
-	sg_init_one(&stat, &status, sizeof(status));
+	sg_init_one(&stat, &buf->status, sizeof(buf->status));
 	sgs[out_num] = &stat;
 
 	BUG_ON(out_num + 1 > ARRAY_SIZE(sgs));
 	virtqueue_add_sgs(vi->cvq, sgs, out_num, 1, vi, GFP_ATOMIC);
 
-	if (unlikely(!virtqueue_kick(vi->cvq)))
-		return status == VIRTIO_NET_OK;
+	if (unlikely(!virtqueue_kick(vi->cvq))) {
+		ret = (buf->status == VIRTIO_NET_OK);
+		goto out;
+	}
 
 	/* Spin for a response, the kick causes an ioport write, trapping
 	 * into the hypervisor, so the request should be handled immediately.
@@ -1009,7 +1021,11 @@ static bool virtnet_send_command(struct virtnet_info *vi, u8 class, u8 cmd,
 	       !virtqueue_is_broken(vi->cvq))
 		cpu_relax();
 
-	return status == VIRTIO_NET_OK;
+	ret = (buf->status == VIRTIO_NET_OK);
+
+out:
+	kfree(buf);
+	return ret;
 }
 
 static int virtnet_set_mac_address(struct net_device *dev, void *p)
@@ -1151,7 +1167,7 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 	struct scatterlist sg[2];
-	u8 promisc, allmulti;
+	u8 *cmdbyte;
 	struct virtio_net_ctrl_mac *mac_data;
 	struct netdev_hw_addr *ha;
 	int uc_count;
@@ -1163,22 +1179,25 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 	if (!virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_RX))
 		return;
 
-	promisc = ((dev->flags & IFF_PROMISC) != 0);
-	allmulti = ((dev->flags & IFF_ALLMULTI) != 0);
+	cmdbyte = kmalloc(sizeof(*cmdbyte), GFP_ATOMIC);
+	if (!cmdbyte)
+		return;
 
-	sg_init_one(sg, &promisc, sizeof(promisc));
+	sg_init_one(sg, cmdbyte, sizeof(*cmdbyte));
 
+	*cmdbyte = ((dev->flags & IFF_PROMISC) != 0);
 	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_RX,
 				  VIRTIO_NET_CTRL_RX_PROMISC, sg))
 		dev_warn(&dev->dev, "Failed to %sable promisc mode.\n",
-			 promisc ? "en" : "dis");
-
-	sg_init_one(sg, &allmulti, sizeof(allmulti));
+			 *cmdbyte ? "en" : "dis");
 
+	*cmdbyte = ((dev->flags & IFF_ALLMULTI) != 0);
 	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_RX,
 				  VIRTIO_NET_CTRL_RX_ALLMULTI, sg))
 		dev_warn(&dev->dev, "Failed to %sable allmulti mode.\n",
-			 allmulti ? "en" : "dis");
+			 *cmdbyte ? "en" : "dis");
+
+	kfree(cmdbyte);
 
 	uc_count = netdev_uc_count(dev);
 	mc_count = netdev_mc_count(dev);
-- 
2.4.3
