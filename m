From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH] virtio-net: Read MAC only after initializing MSI-X
Date: Sat, 13 Aug 2011 11:51:01 +0300
Message-ID: <1313225461-24458-1-git-send-email-levinsasha928@gmail.com>
Cc: Sasha Levin <levinsasha928@gmail.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The MAC of a virtio-net device is located at the first field of the device
specific header. This header is located at offset 20 if the device doesn't
support MSI-X or offset 24 if it does.

Current code in virtnet_probe() used to probe the MAC before checking for
MSI-X, which means that the read was always made from offset 20 regardless
of whether MSI-X in enabled or not.

This patch moves the MAC probe to after the detection of whether MSI-X is
enabled. This way the MAC will be read from offset 24 if the device indeed
supports MSI-X.

Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: virtualization@lists.linux-foundation.org
Cc: netdev@vger.kernel.org
Cc: kvm@vger.kernel.org
Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 drivers/net/virtio_net.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 0c7321c..55ccf96 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -981,14 +981,6 @@ static int virtnet_probe(struct virtio_device *vdev)
 		/* (!csum && gso) case will be fixed by register_netdev() */
 	}
 
-	/* Configuration may specify what MAC to use.  Otherwise random. */
-	if (virtio_has_feature(vdev, VIRTIO_NET_F_MAC)) {
-		vdev->config->get(vdev,
-				  offsetof(struct virtio_net_config, mac),
-				  dev->dev_addr, dev->addr_len);
-	} else
-		random_ether_addr(dev->dev_addr);
-
 	/* Set up our device-specific information */
 	vi = netdev_priv(dev);
 	netif_napi_add(dev, &vi->napi, virtnet_poll, napi_weight);
@@ -1032,6 +1024,14 @@ static int virtnet_probe(struct virtio_device *vdev)
 			dev->features |= NETIF_F_HW_VLAN_FILTER;
 	}
 
+	/* Configuration may specify what MAC to use.  Otherwise random. */
+	if (virtio_has_feature(vdev, VIRTIO_NET_F_MAC)) {
+		vdev->config->get(vdev,
+				  offsetof(struct virtio_net_config, mac),
+				  dev->dev_addr, dev->addr_len);
+	} else
+		random_ether_addr(dev->dev_addr);
+
 	err = register_netdev(dev);
 	if (err) {
 		pr_debug("virtio_net: registering device failed\n");
-- 
1.7.6
