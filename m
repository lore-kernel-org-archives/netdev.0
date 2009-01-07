From: Alex Williamson <alex.williamson@hp.com>
Subject: [PATCH 1/2][RFC] virtio_net: Enable setting MAC, promisc, and
 allmulti mode
Date: Wed, 07 Jan 2009 11:06:02 -0700
Message-ID: <1231351562.7109.129.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kvm <kvm@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Mark McLoughlin <markmc@redhat.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

virtio_net: Enable setting MAC, promisc, and allmulti mode

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
---

 drivers/net/virtio_net.c   |   79 ++++++++++++++++++++++++++++++++++++++++----
 include/linux/virtio_net.h |   11 ++++++
 2 files changed, 82 insertions(+), 8 deletions(-)


diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 3af5e33..f502edd 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -41,7 +41,14 @@ struct virtnet_info
 	struct virtqueue *rvq, *svq;
 	struct net_device *dev;
 	struct napi_struct napi;
-	unsigned int status;
+	union {
+		u16 raw;
+		struct {
+			u16 link:1;
+			u16 promisc:1;
+			u16 allmulti:1;
+		} bits;
+	} status; 
 
 	/* The skb we couldn't send because buffers were full. */
 	struct sk_buff *last_xmit_skb;
@@ -476,6 +483,54 @@ static int virtnet_set_tx_csum(struct net_device *dev, u32 data)
 	return ethtool_op_set_tx_hw_csum(dev, data);
 }
 
+static int virtnet_set_mac_address(struct net_device *dev, void *p)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	struct virtio_device *vdev = vi->vdev;
+	struct sockaddr *addr = p;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+
+	vdev->config->set(vdev, offsetof(struct virtio_net_config, mac),
+			  dev->dev_addr, dev->addr_len);
+
+	return 0;
+}
+
+static void virtnet_set_rx_mode(struct net_device *dev)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	struct virtio_device *vdev = vi->vdev;
+	u16 status = vi->status.raw;
+
+	if (!virtio_has_feature(vi->vdev, VIRTIO_NET_F_STATUS))
+		return;
+
+	if (dev->flags & IFF_PROMISC)
+		status |= VIRTIO_NET_S_PROMISC;
+	else
+		status &= ~VIRTIO_NET_S_PROMISC;
+
+	if (dev->flags & IFF_ALLMULTI)
+		status |= VIRTIO_NET_S_ALLMULTI;
+	else
+		status &= ~VIRTIO_NET_S_ALLMULTI;
+		
+	if (dev->uc_count)
+		status |= VIRTIO_NET_S_PROMISC;
+	if (dev->mc_count)
+		status |= VIRTIO_NET_S_ALLMULTI;
+
+	if (status != vi->status.raw) {
+		vi->status.raw = status;
+		vdev->config->set(vdev, offsetof(struct virtio_net_config,
+				  status), &vi->status, sizeof(vi->status));
+	}
+}
+
 static struct ethtool_ops virtnet_ethtool_ops = {
 	.set_tx_csum = virtnet_set_tx_csum,
 	.set_sg = ethtool_op_set_sg,
@@ -494,14 +549,15 @@ static void virtnet_update_status(struct virtnet_info *vi)
                               &v, sizeof(v));
 
 	/* Ignore unknown (future) status bits */
-	v &= VIRTIO_NET_S_LINK_UP;
+	v &= VIRTIO_NET_S_LINK_UP | VIRTIO_NET_S_PROMISC |
+             VIRTIO_NET_S_ALLMULTI;
 
-	if (vi->status == v)
+	if (vi->status.raw == v)
 		return;
 
-	vi->status = v;
+	vi->status.raw = v;
 
-	if (vi->status & VIRTIO_NET_S_LINK_UP) {
+	if (vi->status.bits.link) {
 		netif_carrier_on(vi->dev);
 		netif_wake_queue(vi->dev);
 	} else {
@@ -563,8 +619,17 @@ static int virtnet_probe(struct virtio_device *vdev)
 		vdev->config->get(vdev,
 				  offsetof(struct virtio_net_config, mac),
 				  dev->dev_addr, dev->addr_len);
-	} else
+	} else {
+		struct sockaddr addr;
+
 		random_ether_addr(dev->dev_addr);
+		memset(&addr, 0, sizeof(addr));
+		memcpy(&addr.sa_data, dev->dev_addr, dev->addr_len);
+		virtnet_set_mac_address(dev, &addr);
+	}
+
+	dev->set_mac_address = virtnet_set_mac_address;
+	dev->set_rx_mode = virtnet_set_rx_mode;
 
 	/* Set up our device-specific information */
 	vi = netdev_priv(dev);
@@ -621,7 +686,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 		goto unregister;
 	}
 
-	vi->status = VIRTIO_NET_S_LINK_UP;
+	vi->status.raw = VIRTIO_NET_S_LINK_UP;
 	virtnet_update_status(vi);
 
 	pr_debug("virtnet: registered device %s\n", dev->name);
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index d9174be..5a70edb 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -23,6 +23,8 @@
 #define VIRTIO_NET_F_STATUS	16	/* virtio_net_config.status available */
 
 #define VIRTIO_NET_S_LINK_UP	1	/* Link is up */
+#define VIRTIO_NET_S_PROMISC	2	/* Promiscuous mode */
+#define VIRTIO_NET_S_ALLMULTI	4	/* All-multicast mode */
 
 struct virtio_net_config
 {
@@ -30,7 +32,14 @@ struct virtio_net_config
 	__u8 mac[6];
 	/* Status supplied by host; see VIRTIO_NET_F_STATUS and VIRTIO_NET_S_*
 	 * bits above */
-	__u16 status;
+	union {
+		__u16 raw;
+		struct {
+			__u16 link:1;
+			__u16 promisc:1;
+			__u16 allmulti:1;
+		} bits;
+       } status;
 } __attribute__((packed));
 
 /* This is the first element of the scatter-gather list.  If you don't


