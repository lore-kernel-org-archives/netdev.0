From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] virtio_net: convert to hw_features
Date: Thu, 31 Mar 2011 13:01:35 +0200 (CEST)
Message-ID: <20110331110135.6988113A64@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:50959 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757297Ab1CaLBi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Mar 2011 07:01:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/virtio_net.c |   46 +++++++++++++++++++-------------------=
--------
 1 files changed, 19 insertions(+), 27 deletions(-)

This is an example conversion to hw_features when constraints are
constant and can be detected at init time.

Build tested only.

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 82dba5a..0cb0b06 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -710,17 +710,6 @@ static int virtnet_close(struct net_device *dev)
 	return 0;
 }
=20
-static int virtnet_set_tx_csum(struct net_device *dev, u32 data)
-{
-	struct virtnet_info *vi =3D netdev_priv(dev);
-	struct virtio_device *vdev =3D vi->vdev;
-
-	if (data && !virtio_has_feature(vdev, VIRTIO_NET_F_CSUM))
-		return -ENOSYS;
-
-	return ethtool_op_set_tx_hw_csum(dev, data);
-}
-
 static void virtnet_set_rx_mode(struct net_device *dev)
 {
 	struct virtnet_info *vi =3D netdev_priv(dev);
@@ -822,10 +811,6 @@ static void virtnet_vlan_rx_kill_vid(struct net_de=
vice *dev, u16 vid)
 }
=20
 static const struct ethtool_ops virtnet_ethtool_ops =3D {
-	.set_tx_csum =3D virtnet_set_tx_csum,
-	.set_sg =3D ethtool_op_set_sg,
-	.set_tso =3D ethtool_op_set_tso,
-	.set_ufo =3D ethtool_op_set_ufo,
 	.get_link =3D ethtool_op_get_link,
 };
=20
@@ -912,22 +897,29 @@ static int virtnet_probe(struct virtio_device *vd=
ev)
 	SET_NETDEV_DEV(dev, &vdev->dev);
=20
 	/* Do we support "hardware" checksums? */
-	if (csum && virtio_has_feature(vdev, VIRTIO_NET_F_CSUM)) {
+	if (virtio_has_feature(vdev, VIRTIO_NET_F_CSUM)) {
 		/* This opens up the world of extra features. */
-		dev->features |=3D NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST;
-		if (gso && virtio_has_feature(vdev, VIRTIO_NET_F_GSO)) {
-			dev->features |=3D NETIF_F_TSO | NETIF_F_UFO
+		dev->hw_features |=3D NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST;
+		if (csum)
+			dev->features |=3D NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST;
+
+		if (virtio_has_feature(vdev, VIRTIO_NET_F_GSO)) {
+			dev->hw_features |=3D NETIF_F_TSO | NETIF_F_UFO
 				| NETIF_F_TSO_ECN | NETIF_F_TSO6;
 		}
 		/* Individual feature bits: what can host handle? */
-		if (gso && virtio_has_feature(vdev, VIRTIO_NET_F_HOST_TSO4))
-			dev->features |=3D NETIF_F_TSO;
-		if (gso && virtio_has_feature(vdev, VIRTIO_NET_F_HOST_TSO6))
-			dev->features |=3D NETIF_F_TSO6;
-		if (gso && virtio_has_feature(vdev, VIRTIO_NET_F_HOST_ECN))
-			dev->features |=3D NETIF_F_TSO_ECN;
-		if (gso && virtio_has_feature(vdev, VIRTIO_NET_F_HOST_UFO))
-			dev->features |=3D NETIF_F_UFO;
+		if (virtio_has_feature(vdev, VIRTIO_NET_F_HOST_TSO4))
+			dev->hw_features |=3D NETIF_F_TSO;
+		if (virtio_has_feature(vdev, VIRTIO_NET_F_HOST_TSO6))
+			dev->hw_features |=3D NETIF_F_TSO6;
+		if (virtio_has_feature(vdev, VIRTIO_NET_F_HOST_ECN))
+			dev->hw_features |=3D NETIF_F_TSO_ECN;
+		if (virtio_has_feature(vdev, VIRTIO_NET_F_HOST_UFO))
+			dev->hw_features |=3D NETIF_F_UFO;
+
+		if (gso)
+			dev->features |=3D dev->hw_features & (NETIF_F_ALL_TSO|NETIF_F_UFO)=
;
+		/* (!csum && gso) case will be fixed by register_netdev() */
 	}
=20
 	/* Configuration may specify what MAC to use.  Otherwise random. */
--=20
1.7.2.5

