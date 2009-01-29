From: Alex Williamson <alex.williamson@hp.com>
Subject: [PATCH v2 3/4] virtio_net: Add a MAC filter table
Date: Thu, 29 Jan 2009 16:05:18 -0700
Message-ID: <20090129230518.2672.20841.stgit@debian.lart>
References: <20090129230502.2672.87669.stgit@debian.lart>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: markmc@redhat.com, netdev@vger.kernel.org, kvm@vger.kernel.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:13265 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753588AbZA2XHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 18:07:54 -0500
In-Reply-To: <20090129230502.2672.87669.stgit@debian.lart>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make use of the MAC control virtqueue class to support a MAC
filter table.  The filter table is managed by the hypervisor.
We consider the table to be available if the CTRL_MAC feature
bit is set.  We leave it to the hypervisor to manage the table
and enable promiscuous or all-multi mode as necessary depending
on the resources available to it.

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
---

 drivers/net/virtio_net.c   |   89 +++++++++++++++++++++++++++++++++++++++++++-
 include/linux/virtio_net.h |   17 ++++++++
 2 files changed, 103 insertions(+), 3 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index b247558..23610ce 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -664,12 +664,22 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 	u8 promisc, allmulti;
+	struct scatterlist sg[4];
+	struct virtio_net_ctrl_hdr ctrl;
+	virtio_net_ctrl_ack status;
+	u8 *uc_buf = NULL, *mc_buf = NULL;
+	unsigned int tmp;
 
 	if (!virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_RX))
 		return;
 
-	promisc = ((dev->flags & IFF_PROMISC) != 0 || dev->uc_count > 0);
-	allmulti = ((dev->flags & IFF_ALLMULTI) != 0 || dev->mc_count > 0);
+	promisc = ((dev->flags & IFF_PROMISC) != 0);
+	allmulti = ((dev->flags & IFF_ALLMULTI) != 0);
+
+	if (!virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_MAC)) {
+		promisc |= (dev->uc_count > 0);
+		allmulti |= (dev->mc_count > 0);
+	}
 
 	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_RX,
 				  VIRTIO_NET_CTRL_RX_PROMISC,
@@ -682,6 +692,79 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 				  &allmulti, sizeof(allmulti)))
 		printk(KERN_WARNING "%s: Failed to %sable allmulti mode.\n",
 		       dev->name, allmulti ? "en" : "dis");
+
+	if (!virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_MAC))
+		return;
+
+	sg_init_table(sg, 4);
+
+	sg_set_buf(&sg[0], &ctrl, sizeof(ctrl));
+	sg_set_buf(&sg[3], &status, sizeof(status));
+
+	ctrl.class = VIRTIO_NET_CTRL_MAC;
+	ctrl.cmd = VIRTIO_NET_CTRL_MAC_TABLE_SET;
+
+	status = ~0;
+
+	if (dev->uc_count) {
+		u8 *cur;
+		struct dev_addr_list *uc;
+		int i;
+
+		cur = uc_buf = kzalloc(dev->uc_count * ETH_ALEN, GFP_ATOMIC);
+		if (!uc_buf) {
+			printk(KERN_WARNING "%s: No memory for UC list\n",
+			       dev->name);
+			return;
+		}
+
+		uc = dev->uc_list;
+		for (i = 0; i < dev->uc_count; i++) {
+			memcpy(cur, uc->da_addr, ETH_ALEN);
+			cur += ETH_ALEN;
+			uc = uc->next;
+		}
+
+		sg_set_buf(&sg[1], uc_buf, dev->uc_count * ETH_ALEN);
+	}
+
+	if (dev->mc_count) {
+		u8 *cur;
+		struct dev_addr_list *mc;
+		int i;
+
+		cur = mc_buf = kzalloc(dev->mc_count * ETH_ALEN, GFP_ATOMIC);
+		if (!mc_buf) {
+			printk(KERN_WARNING "%s: No memory for MC list\n",
+			       dev->name);
+			goto free_uc;
+		}
+
+		mc = dev->mc_list;
+		for (i = 0; i < dev->mc_count; i++) {
+			memcpy(cur, mc->da_addr, ETH_ALEN);
+			cur += ETH_ALEN;
+			mc = mc->next;
+		}
+
+		sg_set_buf(&sg[2], mc_buf, dev->mc_count * ETH_ALEN);
+	}
+
+	if (vi->cvq->vq_ops->add_buf(vi->cvq, sg, 3, 1, vi) != 0)
+		BUG();
+
+	vi->cvq->vq_ops->kick(vi->cvq);
+
+	while (!vi->cvq->vq_ops->get_buf(vi->cvq, &tmp))
+		cpu_relax();
+
+	if (status != VIRTIO_NET_OK)
+		printk(KERN_WARNING "%s: Failed to set MAC filter table (%d)\n",
+		       dev->name, status);
+
+	kfree(mc_buf);
+free_uc:
+	kfree(uc_buf);
 }
 
 static struct ethtool_ops virtnet_ethtool_ops = {
@@ -927,7 +1010,7 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_HOST_ECN, VIRTIO_NET_F_GUEST_TSO4, VIRTIO_NET_F_GUEST_TSO6,
 	VIRTIO_NET_F_GUEST_ECN, /* We don't yet handle UFO input. */
 	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ,
-	VIRTIO_NET_F_CTRL_RX,
+	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_MAC,
 	VIRTIO_F_NOTIFY_ON_EMPTY,
 };
 
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index aac09ec..c8e945a 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -24,6 +24,7 @@
 #define VIRTIO_NET_F_STATUS	16	/* virtio_net_config.status available */
 #define VIRTIO_NET_F_CTRL_VQ	17	/* Control channel available */
 #define VIRTIO_NET_F_CTRL_RX	18	/* Control channel RX mode support */
+#define VIRTIO_NET_F_CTRL_MAC	19	/* Control channel MAC filtering */
 
 #define VIRTIO_NET_S_LINK_UP	1	/* Link is up */
 
@@ -86,4 +87,20 @@ typedef __u8 virtio_net_ctrl_ack;
  #define VIRTIO_NET_CTRL_RX_PROMISC      0
  #define VIRTIO_NET_CTRL_RX_ALLMULTI     1
 
+/*
+ * Control the MAC filter table.
+ *
+ * The MAC filter table is managed by the hypervisor, the guest should
+ * assume the size is infinite.  Filtering should be considered
+ * non-perfect, ie. based on hypervisor resources, the guest may
+ * received packets from sources not specified in the filter list.
+ *
+ * In addition to the class/cmd header, the TABLE_SET command requires
+ * two out scatterlists.  The first is a concatenated byte stream of the
+ * ETH_ALEN unicast MAC addresses for the table, the second is the same
+ * for multicast addresses.
+ */
+#define VIRTIO_NET_CTRL_MAC    1
+ #define VIRTIO_NET_CTRL_MAC_TABLE_SET        0
+
 #endif /* _LINUX_VIRTIO_NET_H */

