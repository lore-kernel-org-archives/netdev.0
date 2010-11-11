From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH] virtio-net: init link state correctly
Date: Thu, 11 Nov 2010 11:15:41 +1030
Message-ID: <201011111115.41256.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51556 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757607Ab0KKApr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Nov 2010 19:45:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Wang <jasowang@redhat.com>

For device that supports VIRTIO_NET_F_STATUS, there's no need to
assume the link is up and we need to call nerif_carrier_off() before
querying device status, otherwise we may get wrong operstate after
diver was loaded because the link watch event was not fired as
expected.

For device that does not support VIRITO_NET_F_STATUS, we could not get
its status through virtnet_update_status() and what we can only do is
always assuming the link is up.

Acked-by: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/virtio_net.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index bb6b67f..b6d4028 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -986,9 +986,15 @@ static int virtnet_probe(struct virtio_device *vdev)
 		goto unregister;
 	}
 
-	vi->status = VIRTIO_NET_S_LINK_UP;
-	virtnet_update_status(vi);
-	netif_carrier_on(dev);
+	/* Assume link up if device can't report link status,
+	   otherwise get link status from config. */
+	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_STATUS)) {
+		netif_carrier_off(dev);
+		virtnet_update_status(vi);
+	} else {
+		vi->status = VIRTIO_NET_S_LINK_UP;
+		netif_carrier_on(dev);
+	}
 
 	pr_debug("virtnet: registered device %s\n", dev->name);
 	return 0;
