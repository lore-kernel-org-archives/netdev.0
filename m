From: Alex Williamson <alex.williamson@hp.com>
Subject: [PATCH] virtio_net: Cleanup command queue scatterlist usage
Date: Fri, 01 May 2009 21:27:56 -0600
Message-ID: <20090502032646.7927.99584.stgit@debian.lart>
References: <20090501.153301.42015656.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alex.williamson@hp.com, sfr@canb.auug.org.au,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-next@vger.kernel.org
To: davem@davemloft.net, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:2750 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752045AbZEBDcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 23:32:21 -0400
In-Reply-To: <20090501.153301.42015656.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We were avoiding calling sg_init* on scatterlists passed
into virtnet_send_command to prevent extraneous end markers.
This caused build warnings for uninitialized variables.
Cleanup the code to create proper scatterlists.

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
---

 Patch against net-2.6.git 7a67e56fd362d3edfde1f19170893508c3940d3a
 
 drivers/net/virtio_net.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 9c82a39..23eb282 100644
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
 
 	if (!virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ)) {
 		BUG();  /* Caller should know better */
@@ -637,7 +638,8 @@ static bool virtnet_send_command(struct virtnet_info *vi, u8 class, u8 cmd,
 	sg_init_table(sg, out + in);
 
 	sg_set_buf(&sg[0], &ctrl, sizeof(ctrl));
-	memcpy(&sg[1], data, sizeof(struct scatterlist) * (out + in - 2));
+	for_each_sg(data, s, out + in - 2, i)
+		sg_set_buf(&sg[i + 1], sg_virt(s), s->length);
 	sg_set_buf(&sg[out + in - 1], &status, sizeof(status));
 
 	if (vi->cvq->vq_ops->add_buf(vi->cvq, sg, out, in, vi) != 0)
@@ -692,7 +694,7 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 	promisc = ((dev->flags & IFF_PROMISC) != 0);
 	allmulti = ((dev->flags & IFF_ALLMULTI) != 0);
 
-	sg_set_buf(sg, &promisc, sizeof(promisc));
+	sg_init_one(sg, &promisc, sizeof(promisc));
 
 	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_RX,
 				  VIRTIO_NET_CTRL_RX_PROMISC,
@@ -700,7 +702,7 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 		dev_warn(&dev->dev, "Failed to %sable promisc mode.\n",
 			 promisc ? "en" : "dis");
 
-	sg_set_buf(sg, &allmulti, sizeof(allmulti));
+	sg_init_one(sg, &allmulti, sizeof(allmulti));
 
 	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_RX,
 				  VIRTIO_NET_CTRL_RX_ALLMULTI,
@@ -716,6 +718,8 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 		return;
 	}
 
+	sg_init_table(sg, 2);
+
 	/* Store the unicast list and count in the front of the buffer */
 	mac_data->entries = dev->uc_count;
 	addr = dev->uc_list;
@@ -749,7 +753,7 @@ static void virnet_vlan_rx_add_vid(struct net_device *dev, u16 vid)
 	struct virtnet_info *vi = netdev_priv(dev);
 	struct scatterlist sg;
 
-	sg_set_buf(&sg, &vid, sizeof(vid));
+	sg_init_one(&sg, &vid, sizeof(vid));
 
 	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_VLAN,
 				  VIRTIO_NET_CTRL_VLAN_ADD, &sg, 1, 0))
@@ -761,7 +765,7 @@ static void virnet_vlan_rx_kill_vid(struct net_device *dev, u16 vid)
 	struct virtnet_info *vi = netdev_priv(dev);
 	struct scatterlist sg;
 
-	sg_set_buf(&sg, &vid, sizeof(vid));
+	sg_init_one(&sg, &vid, sizeof(vid));
 
 	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_VLAN,
 				  VIRTIO_NET_CTRL_VLAN_DEL, &sg, 1, 0))

