From: Alex Williamson <alex.williamson@hp.com>
Subject: [PATCH 1/5] virtio_net: Allow setting the MAC address of the NIC
Date: Fri, 16 Jan 2009 14:13:18 -0700
Message-ID: <20090116211318.22836.87192.stgit@debian.lart>
References: <20090116211312.22836.34331.stgit@debian.lart>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, markmc@redhat.com, kvm@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:26793 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762905AbZAPVPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 16:15:10 -0500
In-Reply-To: <20090116211312.22836.34331.stgit@debian.lart>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many physical NICs let the OS re-program the "hardware" MAC
address.  Virtual NICs should allow this too.

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

