From: Alex Williamson <alex.williamson@hp.com>
Subject: [PATCH v3 3/4] virtio_net: Add a MAC filter table
Date: Sun, 01 Feb 2009 13:05:20 -0700
Message-ID: <20090201200520.8183.3168.stgit@debian.lart>
References: <20090201200504.8183.58421.stgit@debian.lart>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: markmc@redhat.com, netdev@vger.kernel.org, kvm@vger.kernel.org
To: rusty@rustcorp.com.au
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090201200504.8183.58421.stgit@debian.lart>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make use of the MAC control virtqueue class to support a MAC
filter table.  The filter table is managed by the hypervisor.
We consider the table to be available if the CTRL_RX feature
bit is set.  We leave it to the hypervisor to manage the table
and enable promiscuous or all-multi mode as necessary depending
on the resources available to it.

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
---

 drivers/net/virtio_net.c   |   53 ++++++++++++++++++++++++++++++++++++++------
 include/linux/virtio_net.h |   25 ++++++++++++++++++++-
 2 files changed, 70 insertions(+), 8 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index f43b9d3..e03eebf 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -675,31 +675,70 @@ static int virtnet_set_tx_csum(struct net_device *dev, u32 data)
 static void virtnet_set_rx_mode(struct net_device *dev)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
-	struct scatterlist sg;
+	struct scatterlist sg[2];
 	u8 promisc, allmulti;
+	struct virtio_net_ctrl_mac *mac_data;
+	struct dev_addr_list *addr;
+	void *buf;
+	int i;
 
 	/* We can't dynamicaly set ndo_set_rx_mode, so return gracefully */
 	if (!virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_RX))
 		return;
 
-	promisc = ((dev->flags & IFF_PROMISC) != 0 || dev->uc_count > 0);
-	allmulti = ((dev->flags & IFF_ALLMULTI) != 0 || dev->mc_count > 0);
+	promisc = ((dev->flags & IFF_PROMISC) != 0);
+	allmulti = ((dev->flags & IFF_ALLMULTI) != 0);
 
-	sg_set_buf(&sg, &promisc, sizeof(promisc));
+	sg_set_buf(sg, &promisc, sizeof(promisc));
 
 	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_RX,
 				  VIRTIO_NET_CTRL_RX_PROMISC,
-				  &sg, 1, 0))
+				  sg, 1, 0))
 		dev_warn(&dev->dev, "Failed to %sable promisc mode.\n",
 			 promisc ? "en" : "dis");
 
-	sg_set_buf(&sg, &allmulti, sizeof(allmulti));
+	sg_set_buf(sg, &allmulti, sizeof(allmulti));
 
 	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_RX,
 				  VIRTIO_NET_CTRL_RX_ALLMULTI,
-				  &sg, 1, 0))
+				  sg, 1, 0))
 		dev_warn(&dev->dev, "Failed to %sable allmulti mode.\n",
 			 allmulti ? "en" : "dis");
+
+	/* MAC filter - use one buffer for both lists */
+	mac_data = buf = kzalloc(((dev->uc_count + dev->mc_count) * ETH_ALEN) +
+				 (2 * sizeof(mac_data->entries)), GFP_ATOMIC);
+	if (!buf) {
+		dev_warn(&dev->dev, "No memory for MAC address buffer\n");
+		return;
+	}
+
+	/* Store the unicast list and count in the front of the buffer */
+	mac_data->entries = dev->uc_count;
+	addr = dev->uc_list;
+	for (i = 0; i < dev->uc_count; i++, addr = addr->next)
+		memcpy(&mac_data->macs[i * ETH_ALEN], addr->da_addr, ETH_ALEN);
+
+	sg_set_buf(&sg[0], mac_data,
+		   sizeof(mac_data->entries) + (dev->uc_count * ETH_ALEN));
+
+	/* multicast list and count fill the end */
+	mac_data = (void *)&mac_data->macs[dev->uc_count * ETH_ALEN];
+
+	mac_data->entries = dev->mc_count;
+	addr = dev->mc_list;
+	for (i = 0; i < dev->mc_count; i++, addr = addr->next)
+		memcpy(&mac_data->macs[i * ETH_ALEN], addr->da_addr, ETH_ALEN);
+
+	sg_set_buf(&sg[1], mac_data,
+		   sizeof(mac_data->entries) + (dev->mc_count * ETH_ALEN));
+
+	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_MAC,
+				  VIRTIO_NET_CTRL_MAC_TABLE_SET,
+				  sg, 2, 0))
+		dev_warn(&dev->dev, "Failed to set MAC fitler table.\n");
+
+	kfree(buf);
 }
 
 static struct ethtool_ops virtnet_ethtool_ops = {
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index 69569e1..06d9dd6 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -77,7 +77,7 @@ typedef __u8 virtio_net_ctrl_ack;
 #define VIRTIO_NET_OK     0
 #define VIRTIO_NET_ERR    1
 
-#define VIRTIO_NET_MAX_CTRL_ARGS   3
+#define VIRTIO_NET_MAX_CTRL_ARGS   4
 
 /*
  * Control the RX mode, ie. promisucous and allmulti.  PROMISC and
@@ -89,4 +89,27 @@ typedef __u8 virtio_net_ctrl_ack;
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
+ * two out scatterlists.  Each contains a 4 byte count of entries followed
+ * by a concatenated byte stream of the ETH_ALEN MAC addresses.  The
+ * first sg list contains unicast addresses, the second is for multicast.
+ * This functionality is present if the VIRTIO_NET_F_CTRL_RX feature
+ * is available.
+ */
+struct virtio_net_ctrl_mac {
+	__u32 entries;
+	__u8 macs[];
+} __attribute__((packed));
+
+#define VIRTIO_NET_CTRL_MAC    1
+ #define VIRTIO_NET_CTRL_MAC_TABLE_SET        0
+
 #endif /* _LINUX_VIRTIO_NET_H */

