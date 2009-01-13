From: Alex Williamson <alex.williamson@hp.com>
Subject: [PATCH 1/4] virtio_net: Allow setting the MAC address of the NIC
Date: Tue, 13 Jan 2009 14:23:16 -0700
Message-ID: <1231881796.9095.186.camel@bling>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kvm <kvm@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Mark McLoughlin <markmc@redhat.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:7212 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753655AbZAMVXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 16:23:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
---

 drivers/net/virtio_net.c |   23 +++++++++++++++++++++--
 1 files changed, 21 insertions(+), 2 deletions(-)


diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 43f6523..e7700de 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -561,6 +561,22 @@ stop_queue:
 	goto done;
 }
 
+static int virtnet_set_mac_address(struct net_device *dev, void *p)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	struct virtio_device *vdev = vi->vdev;
+	int ret;
+
+	ret = eth_mac_addr(dev, p);
+	if (ret)
+		return ret;
+
+	vdev->config->set(vdev, offsetof(struct virtio_net_config, mac),
+			  dev->dev_addr, dev->addr_len);
+
+	return 0;
+}
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void virtnet_netpoll(struct net_device *dev)
 {
@@ -629,7 +645,7 @@ static const struct net_device_ops virtnet_netdev = {
 	.ndo_stop   	     = virtnet_close,
 	.ndo_start_xmit      = start_xmit,
 	.ndo_validate_addr   = eth_validate_addr,
-	.ndo_set_mac_address = eth_mac_addr,
+	.ndo_set_mac_address = virtnet_set_mac_address,
 	.ndo_change_mtu	     = virtnet_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = virtnet_netpoll,
@@ -677,8 +693,11 @@ static int virtnet_probe(struct virtio_device *vdev)
 		vdev->config->get(vdev,
 				  offsetof(struct virtio_net_config, mac),
 				  dev->dev_addr, dev->addr_len);
-	} else
+	} else {
 		random_ether_addr(dev->dev_addr);
+		vdev->config->set(vdev, offsetof(struct virtio_net_config, mac),
+				  dev->dev_addr, dev->addr_len);
+	}
 
 	/* Set up our device-specific information */
 	vi = netdev_priv(dev);


