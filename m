From: Amos Kong <akong@redhat.com>
Subject: [PATCH v5 3/3] virtio-net: introduce a new control to set macaddr
Date: Mon, 21 Jan 2013 19:17:23 +0800
Message-ID: <1358767043-24548-4-git-send-email-akong@redhat.com>
References: <1358767043-24548-1-git-send-email-akong@redhat.com>
Cc: mst@redhat.com, rusty@rustcorp.com.au, qemu-devel@nongnu.org,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24778 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752981Ab3AULRp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2013 06:17:45 -0500
In-Reply-To: <1358767043-24548-1-git-send-email-akong@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we write MAC address to pci config space byte by byte,
this means that we have an intermediate step where mac is wrong.
This patch introduced a new control command to set MAC address,
it's atomic.

VIRTIO_NET_F_CTRL_MAC_ADDR is a new feature bit for compatibility.

Signed-off-by: Amos Kong <akong@redhat.com>
---
 drivers/net/virtio_net.c        |   21 ++++++++++++++++++---
 include/uapi/linux/virtio_net.h |    8 +++++++-
 2 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 395ab4f..701408a 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -802,14 +802,28 @@ static int virtnet_set_mac_address(struct net_device *dev, void *p)
 	struct virtnet_info *vi = netdev_priv(dev);
 	struct virtio_device *vdev = vi->vdev;
 	int ret;
+	struct sockaddr *addr = p;
+	struct scatterlist sg;
 
-	ret = eth_mac_addr(dev, p);
+	ret = eth_prepare_mac_addr_change(dev, p);
 	if (ret)
 		return ret;
 
-	if (virtio_has_feature(vdev, VIRTIO_NET_F_MAC))
+	if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_MAC_ADDR)) {
+		sg_init_one(&sg, addr->sa_data, dev->addr_len);
+		if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_MAC,
+					  VIRTIO_NET_CTRL_MAC_ADDR_SET,
+					  &sg, 1, 0)) {
+			dev_warn(&vdev->dev,
+				 "Failed to set mac address by vq command.\n");
+			return -EINVAL;
+		}
+	} else if (virtio_has_feature(vdev, VIRTIO_NET_F_MAC)) {
 		vdev->config->set(vdev, offsetof(struct virtio_net_config, mac),
-		                  dev->dev_addr, dev->addr_len);
+				  addr->sa_data, dev->addr_len);
+	}
+
+	eth_commit_mac_addr_change(dev, p);
 
 	return 0;
 }
@@ -1627,6 +1641,7 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ,
 	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN,
 	VIRTIO_NET_F_GUEST_ANNOUNCE, VIRTIO_NET_F_MQ,
+	VIRTIO_NET_F_CTRL_MAC_ADDR,
 };
 
 static struct virtio_driver virtio_net_driver = {
diff --git a/include/uapi/linux/virtio_net.h b/include/uapi/linux/virtio_net.h
index 848e358..a5a8c88 100644
--- a/include/uapi/linux/virtio_net.h
+++ b/include/uapi/linux/virtio_net.h
@@ -53,6 +53,7 @@
 					 * network */
 #define VIRTIO_NET_F_MQ	22	/* Device supports Receive Flow
 					 * Steering */
+#define VIRTIO_NET_F_CTRL_MAC_ADDR 23	/* Set MAC address */
 
 #define VIRTIO_NET_S_LINK_UP	1	/* Link is up */
 #define VIRTIO_NET_S_ANNOUNCE	2	/* Announcement is needed */
@@ -127,7 +128,7 @@ typedef __u8 virtio_net_ctrl_ack;
  #define VIRTIO_NET_CTRL_RX_NOBCAST      5
 
 /*
- * Control the MAC filter table.
+ * Control the MAC
  *
  * The MAC filter table is managed by the hypervisor, the guest should
  * assume the size is infinite.  Filtering should be considered
@@ -140,6 +141,10 @@ typedef __u8 virtio_net_ctrl_ack;
  * first sg list contains unicast addresses, the second is for multicast.
  * This functionality is present if the VIRTIO_NET_F_CTRL_RX feature
  * is available.
+ *
+ * The ADDR_SET command requests one out scatterlist, it contains a
+ * 6 bytes MAC address. This functionality is present if the
+ * VIRTIO_NET_F_CTRL_MAC_ADDR feature is available.
  */
 struct virtio_net_ctrl_mac {
 	__u32 entries;
@@ -148,6 +153,7 @@ struct virtio_net_ctrl_mac {
 
 #define VIRTIO_NET_CTRL_MAC    1
  #define VIRTIO_NET_CTRL_MAC_TABLE_SET        0
+ #define VIRTIO_NET_CTRL_MAC_ADDR_SET         1
 
 /*
  * Control VLAN filtering
-- 
1.7.1
