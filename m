From: Alex Williamson <alex.williamson@hp.com>
Subject: [PATCH] virtio_net: Allow setting the MAC address of the NIC
Date: Wed, 04 Feb 2009 12:26:06 -0700
Message-ID: <20090204191826.2481.17875.stgit@debian.lart>
References: <200901271305.16832.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: markmc@redhat.com, netdev@vger.kernel.org, kvm@vger.kernel.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:16471 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751188AbZBDT3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 14:29:10 -0500
In-Reply-To: <200901271305.16832.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many physical NICs let the OS re-program the "hardware" MAC
address.  Virtual NICs should allow this too.

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
Acked-by: Mark McLoughlin <markmc@redhat.com>
---

Rusty, you've already applied this to your patch queue, but that version
won't apply cleanly after the MAC and VLAN filtering patches I just sent
for net-next-2.6 (just diff context changes).  This version should apply
cleanly, so either drop the original and apply this after rebase, or
maybe it should just go directly into net-next-2.6?  Thanks,

Alex

 drivers/net/virtio_net.c |   23 +++++++++++++++++++++--
 1 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index e68813a..3d00339 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -565,6 +565,22 @@ stop_queue:
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
@@ -774,7 +790,7 @@ static const struct net_device_ops virtnet_netdev = {
 	.ndo_stop   	     = virtnet_close,
 	.ndo_start_xmit      = start_xmit,
 	.ndo_validate_addr   = eth_validate_addr,
-	.ndo_set_mac_address = eth_mac_addr,
+	.ndo_set_mac_address = virtnet_set_mac_address,
 	.ndo_set_rx_mode     = virtnet_set_rx_mode,
 	.ndo_change_mtu	     = virtnet_change_mtu,
 	.ndo_vlan_rx_add_vid = virnet_vlan_rx_add_vid,
@@ -860,8 +876,11 @@ static int virtnet_probe(struct virtio_device *vdev)
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

