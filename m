From: Alex Williamson <alex.williamson@hp.com>
Subject: [PATCH] virtio_net: Cleanup command queue scatterlist usage
Date: Mon, 27 Apr 2009 09:50:03 -0600
Message-ID: <20090427154925.4771.63651.stgit@debian.lart>
References: <20090426.233014.216353908.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alex.williamson@hp.com, sfr@canb.auug.org.au,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-next@vger.kernel.org
To: davem@davemloft.net, rusty@rustcorp.com.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090426.233014.216353908.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We were avoiding calling sg_init* on scatterlists passed
into virtnet_send_command to prevent extraneous end markers.
This caused build warnings for uninitialized variables.
Cleanup the code to create proper scatterlists.

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
---

 drivers/net/virtio_net.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 0718558..ed70df4 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -616,10 +616,11 @@ static int virtnet_open(struct net_device *dev)
 static bool virtnet_send_command(struct virtnet_info *vi, u8 class, u8 cmd,
 				 struct scatterlist *data, int out, int in)
 {
-	struct scatterlist sg[VIRTNET_SEND_COMMAND_SG_MAX + 2];
+	struct scatterlist *s, sg[VIRTNET_SEND_COMMAND_SG_MAX + 2];
 	struct virtio_net_ctrl_hdr ctrl;
 	virtio_net_ctrl_ack status = ~0;
 	unsigned int tmp;
+	int i;
 
 	/* Caller should know better */
 	BUG_ON(!virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ) ||
@@ -634,7 +635,8 @@ static bool virtnet_send_command(struct virtnet_info *vi, u8 class, u8 cmd,
 	sg_init_table(sg, out + in);
 
 	sg_set_buf(&sg[0], &ctrl, sizeof(ctrl));
-	memcpy(&sg[1], data, sizeof(struct scatterlist) * (out + in - 2));
+	for_each_sg(data, s, out + in - 2, i)
+		sg_set_buf(&sg[i + 1], sg_virt(s), s->length);
 	sg_set_buf(&sg[out + in - 1], &status, sizeof(status));
 
 	BUG_ON(vi->cvq->vq_ops->add_buf(vi->cvq, sg, out, in, vi));
@@ -688,7 +690,7 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 	promisc = ((dev->flags & IFF_PROMISC) != 0);
 	allmulti = ((dev->flags & IFF_ALLMULTI) != 0);
 
-	sg_set_buf(sg, &promisc, sizeof(promisc));
+	sg_init_one(sg, &promisc, sizeof(promisc));
 
 	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_RX,
 				  VIRTIO_NET_CTRL_RX_PROMISC,
@@ -696,7 +698,7 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 		dev_warn(&dev->dev, "Failed to %sable promisc mode.\n",
 			 promisc ? "en" : "dis");
 
-	sg_set_buf(sg, &allmulti, sizeof(allmulti));
+	sg_init_one(sg, &allmulti, sizeof(allmulti));
 
 	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_RX,
 				  VIRTIO_NET_CTRL_RX_ALLMULTI,
@@ -712,6 +714,8 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 		return;
 	}
 
+	sg_init_table(sg, 2);
+
 	/* Store the unicast list and count in the front of the buffer */
 	mac_data->entries = dev->uc_count;
 	addr = dev->uc_list;
@@ -745,7 +749,7 @@ static void virnet_vlan_rx_add_vid(struct net_device *dev, u16 vid)
 	struct virtnet_info *vi = netdev_priv(dev);
 	struct scatterlist sg;
 
-	sg_set_buf(&sg, &vid, sizeof(vid));
+	sg_init_one(&sg, &vid, sizeof(vid));
 
 	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_VLAN,
 				  VIRTIO_NET_CTRL_VLAN_ADD, &sg, 1, 0))
@@ -757,7 +761,7 @@ static void virnet_vlan_rx_kill_vid(struct net_device *dev, u16 vid)
 	struct virtnet_info *vi = netdev_priv(dev);
 	struct scatterlist sg;
 
-	sg_set_buf(&sg, &vid, sizeof(vid));
+	sg_init_one(&sg, &vid, sizeof(vid));
 
 	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_VLAN,
 				  VIRTIO_NET_CTRL_VLAN_DEL, &sg, 1, 0))
