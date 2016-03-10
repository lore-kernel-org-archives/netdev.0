From: Aaron Conole <aconole@redhat.com>
Subject: [RFC -next 2/2] virtio_net: Read and use the advised MTU
Date: Thu, 10 Mar 2016 09:28:12 -0500
Message-ID: <1457620092-24170-3-git-send-email-aconole@redhat.com>
References: <1457620092-24170-1-git-send-email-aconole@redhat.com>
To: netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58064 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752104AbcCJO2R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2016 09:28:17 -0500
In-Reply-To: <1457620092-24170-1-git-send-email-aconole@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch checks the feature bit for the VIRTIO_NET_F_MTU feature. If it
exists, read the advised MTU and use it.

No proper error handling is provided for the case where a user changes the
negotiated MTU. A future commit will add proper error handling. Instead, a
warning is emitted if the guest changes the device MTU after previously being
given advice.

Signed-off-by: Aaron Conole <aconole@redhat.com>
---
 drivers/net/virtio_net.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 767ab11..7175563 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -146,6 +146,7 @@ struct virtnet_info {
 	virtio_net_ctrl_ack ctrl_status;
 	u8 ctrl_promisc;
 	u8 ctrl_allmulti;
+	bool negotiated_mtu;
 };
 
 struct padded_vnet_hdr {
@@ -1390,8 +1391,12 @@ static const struct ethtool_ops virtnet_ethtool_ops = {
 
 static int virtnet_change_mtu(struct net_device *dev, int new_mtu)
 {
+	struct virtnet_info *vi = netdev_priv(dev);
 	if (new_mtu < MIN_MTU || new_mtu > MAX_MTU)
 		return -EINVAL;
+	if (vi->negotiated_mtu == true) {
+		pr_warn("changing mtu from negotiated mtu.");
+	}
 	dev->mtu = new_mtu;
 	return 0;
 }
@@ -1836,6 +1841,13 @@ static int virtnet_probe(struct virtio_device *vdev)
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_VQ))
 		vi->has_cvq = true;
 
+	if (virtio_has_feature(vdev, VIRTIO_NET_F_MTU)) {
+		vi->negotiated_mtu = true;
+		dev->mtu = virtio_cread16(vdev,
+					  offsetof(struct virtio_net_config,
+						   mtu));
+	}
+
 	if (vi->any_header_sg)
 		dev->needed_headroom = vi->hdr_len;
 
@@ -2017,8 +2029,9 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ,
 	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN,
 	VIRTIO_NET_F_GUEST_ANNOUNCE, VIRTIO_NET_F_MQ,
-	VIRTIO_NET_F_CTRL_MAC_ADDR,
+	VIRTIO_NET_F_CTRL_MAC_ADDR, 
 	VIRTIO_F_ANY_LAYOUT,
+	VIRTIO_NET_F_MTU,
 };
 
 static struct virtio_driver virtio_net_driver = {
-- 
2.5.0
