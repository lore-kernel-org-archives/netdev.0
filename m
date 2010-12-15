From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [RFC PATCH 07/12] vlan: convert VLAN devices to use ndo_fix_features()
Date: Wed, 15 Dec 2010 23:24:29 +0100 (CET)
Message-ID: <34dbc2d3d83d82f506f0f073dbf00444885e4f81.1292451560.git.mirq-linux@rere.qmqm.pl>
References: <cover.1292451559.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:53554 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752205Ab0LOWYc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Dec 2010 17:24:32 -0500
In-Reply-To: <cover.1292451559.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Note: get_flags was actually broken, because it should return the
flags capped with vlan_features. This is now done implicitly by
limiting netdev->hw_features.

RX checksumming offload control is (and was) broken, as there was no wa=
y
before to say whether it's done for tagged packets.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 net/8021q/vlan.c     |    3 +-
 net/8021q/vlan_dev.c |   51 ++++++++++++++----------------------------=
-------
 2 files changed, 16 insertions(+), 38 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 6e64f7c..583d47b 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -329,8 +329,7 @@ static void vlan_transfer_features(struct net_devic=
e *dev,
 {
 	unsigned long old_features =3D vlandev->features;
=20
-	vlandev->features &=3D ~dev->vlan_features;
-	vlandev->features |=3D dev->features & dev->vlan_features;
+	netdev_update_features(vlandev);
 	vlandev->gso_max_size =3D dev->gso_max_size;
=20
 	if (dev->features & NETIF_F_HW_VLAN_TX)
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index be73753..468c899 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -691,8 +691,8 @@ static int vlan_dev_init(struct net_device *dev)
 					  (1<<__LINK_STATE_DORMANT))) |
 		      (1<<__LINK_STATE_PRESENT);
=20
-	dev->features |=3D real_dev->features & real_dev->vlan_features;
-	dev->features |=3D NETIF_F_LLTX;
+	dev->hw_features =3D real_dev->vlan_features;
+	dev->features |=3D real_dev->vlan_features | NETIF_F_LLTX;
 	dev->gso_max_size =3D real_dev->gso_max_size;
=20
 	/* ipv6 shared card related stuff */
@@ -745,6 +745,18 @@ static void vlan_dev_uninit(struct net_device *dev=
)
 	}
 }
=20
+static unsigned long vlan_dev_fix_features(struct net_device *dev,
+	unsigned long features)
+{
+	struct net_device *real_dev =3D vlan_dev_info(dev)->real_dev;
+
+	features &=3D (real_dev->features | NETIF_F_LLTX);
+	if (dev_ethtool_get_rx_csum(real_dev))
+		features |=3D NETIF_F_RXCSUM;
+
+	return features;
+}
+
 static int vlan_ethtool_get_settings(struct net_device *dev,
 				     struct ethtool_cmd *cmd)
 {
@@ -760,18 +772,6 @@ static void vlan_ethtool_get_drvinfo(struct net_de=
vice *dev,
 	strcpy(info->fw_version, "N/A");
 }
=20
-static u32 vlan_ethtool_get_rx_csum(struct net_device *dev)
-{
-	const struct vlan_dev_info *vlan =3D vlan_dev_info(dev);
-	return dev_ethtool_get_rx_csum(vlan->real_dev);
-}
-
-static u32 vlan_ethtool_get_flags(struct net_device *dev)
-{
-	const struct vlan_dev_info *vlan =3D vlan_dev_info(dev);
-	return dev_ethtool_get_flags(vlan->real_dev);
-}
-
 static struct rtnl_link_stats64 *vlan_dev_get_stats64(struct net_devic=
e *dev, struct rtnl_link_stats64 *stats)
 {
=20
@@ -809,32 +809,10 @@ static struct rtnl_link_stats64 *vlan_dev_get_sta=
ts64(struct net_device *dev, st
 	return stats;
 }
=20
-static int vlan_ethtool_set_tso(struct net_device *dev, u32 data)
-{
-       if (data) {
-		struct net_device *real_dev =3D vlan_dev_info(dev)->real_dev;
-
-		/* Underlying device must support TSO for VLAN-tagged packets
-		 * and must have TSO enabled now.
-		 */
-		if (!(real_dev->vlan_features & NETIF_F_TSO))
-			return -EOPNOTSUPP;
-		if (!(real_dev->features & NETIF_F_TSO))
-			return -EINVAL;
-		dev->features |=3D NETIF_F_TSO;
-	} else {
-		dev->features &=3D ~NETIF_F_TSO;
-	}
-	return 0;
-}
-
 static const struct ethtool_ops vlan_ethtool_ops =3D {
 	.get_settings	        =3D vlan_ethtool_get_settings,
 	.get_drvinfo	        =3D vlan_ethtool_get_drvinfo,
 	.get_link		=3D ethtool_op_get_link,
-	.get_rx_csum		=3D vlan_ethtool_get_rx_csum,
-	.get_flags		=3D vlan_ethtool_get_flags,
-	.set_tso                =3D vlan_ethtool_set_tso,
 };
=20
 static const struct net_device_ops vlan_netdev_ops =3D {
@@ -859,6 +837,7 @@ static const struct net_device_ops vlan_netdev_ops =
=3D {
 	.ndo_fcoe_disable	=3D vlan_dev_fcoe_disable,
 	.ndo_fcoe_get_wwn	=3D vlan_dev_fcoe_get_wwn,
 #endif
+	.ndo_fix_features	=3D vlan_dev_fix_features,
 };
=20
 void vlan_setup(struct net_device *dev)
--=20
1.7.2.3

