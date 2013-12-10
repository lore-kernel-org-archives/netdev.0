From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/3] virtio_net: remove unused parameter to
	send_command
Date: Mon, 9 Dec 2013 16:17:40 -0800
Message-ID: <20131209161740.5f2cfae7@nehalam.linuxnetplumber.net>
References: <20131209161632.5ac96e5a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>, "Michael S. Tsirkin" <mst@redhat.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20131209161632.5ac96e5a@nehalam.linuxnetplumber.net>
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

All the code passes NULL for the last sg list (in).
Simplify by just removing it.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/drivers/net/virtio_net.c	2013-12-09 16:12:36.353164803 -0800
+++ b/drivers/net/virtio_net.c	2013-12-09 16:12:41.409051865 -0800
@@ -876,13 +876,12 @@ static netdev_tx_t start_xmit(struct sk_
  * never fail unless improperly formated.
  */
 static bool virtnet_send_command(struct virtnet_info *vi, u8 class, u8 cmd,
-				 struct scatterlist *out,
-				 struct scatterlist *in)
+				 struct scatterlist *out)
 {
 	struct scatterlist *sgs[4], hdr, stat;
 	struct virtio_net_ctrl_hdr ctrl;
 	virtio_net_ctrl_ack status = ~0;
-	unsigned out_num = 0, in_num = 0, tmp;
+	unsigned out_num = 0, tmp;
 
 	/* Caller should know better */
 	BUG_ON(!virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ));
@@ -895,16 +894,13 @@ static bool virtnet_send_command(struct
 
 	for (; out; out = sg_next(out))
 		sgs[out_num++] = out;
-	if (in)
-		sgs[out_num + in_num++] = in;
 
 	/* Add return status. */
 	sg_init_one(&stat, &status, sizeof(status));
-	sgs[out_num + in_num++] = &stat;
+	sgs[out_num] = &stat;
 
-	BUG_ON(out_num + in_num > ARRAY_SIZE(sgs));
-	BUG_ON(virtqueue_add_sgs(vi->cvq, sgs, out_num, in_num, vi, GFP_ATOMIC)
-	       < 0);
+	BUG_ON(out_num + 1 > ARRAY_SIZE(sgs));
+	BUG_ON(virtqueue_add_sgs(vi->cvq, sgs, out_num, 1, vi, GFP_ATOMIC) < 0);
 
 	if (unlikely(!virtqueue_kick(vi->cvq)))
 		return status == VIRTIO_NET_OK;
@@ -934,8 +930,7 @@ static int virtnet_set_mac_address(struc
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_MAC_ADDR)) {
 		sg_init_one(&sg, addr->sa_data, dev->addr_len);
 		if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_MAC,
-					  VIRTIO_NET_CTRL_MAC_ADDR_SET,
-					  &sg, NULL)) {
+					  VIRTIO_NET_CTRL_MAC_ADDR_SET, &sg)) {
 			dev_warn(&vdev->dev,
 				 "Failed to set mac address by vq command.\n");
 			return -EINVAL;
@@ -1008,7 +1003,7 @@ static void virtnet_ack_link_announce(st
 {
 	rtnl_lock();
 	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_ANNOUNCE,
-				  VIRTIO_NET_CTRL_ANNOUNCE_ACK, NULL, NULL))
+				  VIRTIO_NET_CTRL_ANNOUNCE_ACK, NULL))
 		dev_warn(&vi->dev->dev, "Failed to ack link announce.\n");
 	rtnl_unlock();
 }
@@ -1026,7 +1021,7 @@ static int virtnet_set_queues(struct vir
 	sg_init_one(&sg, &s, sizeof(s));
 
 	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_MQ,
-				  VIRTIO_NET_CTRL_MQ_VQ_PAIRS_SET, &sg, NULL)) {
+				  VIRTIO_NET_CTRL_MQ_VQ_PAIRS_SET, &sg)) {
 		dev_warn(&dev->dev, "Fail to set num of queue pairs to %d\n",
 			 queue_pairs);
 		return -EINVAL;
@@ -1076,16 +1071,14 @@ static void virtnet_set_rx_mode(struct n
 	sg_init_one(sg, &promisc, sizeof(promisc));
 
 	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_RX,
-				  VIRTIO_NET_CTRL_RX_PROMISC,
-				  sg, NULL))
+				  VIRTIO_NET_CTRL_RX_PROMISC, sg))
 		dev_warn(&dev->dev, "Failed to %sable promisc mode.\n",
 			 promisc ? "en" : "dis");
 
 	sg_init_one(sg, &allmulti, sizeof(allmulti));
 
 	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_RX,
-				  VIRTIO_NET_CTRL_RX_ALLMULTI,
-				  sg, NULL))
+				  VIRTIO_NET_CTRL_RX_ALLMULTI, sg))
 		dev_warn(&dev->dev, "Failed to %sable allmulti mode.\n",
 			 allmulti ? "en" : "dis");
 
@@ -1121,8 +1114,7 @@ static void virtnet_set_rx_mode(struct n
 		   sizeof(mac_data->entries) + (mc_count * ETH_ALEN));
 
 	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_MAC,
-				  VIRTIO_NET_CTRL_MAC_TABLE_SET,
-				  sg, NULL))
+				  VIRTIO_NET_CTRL_MAC_TABLE_SET, sg))
 		dev_warn(&dev->dev, "Failed to set MAC filter table.\n");
 
 	kfree(buf);
@@ -1137,7 +1129,7 @@ static int virtnet_vlan_rx_add_vid(struc
 	sg_init_one(&sg, &vid, sizeof(vid));
 
 	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_VLAN,
-				  VIRTIO_NET_CTRL_VLAN_ADD, &sg, NULL))
+				  VIRTIO_NET_CTRL_VLAN_ADD, &sg))
 		dev_warn(&dev->dev, "Failed to add VLAN ID %d.\n", vid);
 	return 0;
 }
@@ -1151,7 +1143,7 @@ static int virtnet_vlan_rx_kill_vid(stru
 	sg_init_one(&sg, &vid, sizeof(vid));
 
 	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_VLAN,
-				  VIRTIO_NET_CTRL_VLAN_DEL, &sg, NULL))
+				  VIRTIO_NET_CTRL_VLAN_DEL, &sg))
 		dev_warn(&dev->dev, "Failed to kill VLAN ID %d.\n", vid);
 	return 0;
 }
