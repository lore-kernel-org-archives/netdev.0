From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v2] net: xen-netback: convert to hw_features
Date: Tue, 19 Apr 2011 15:35:06 +0200 (CEST)
Message-ID: <20110419133506.D332413909@rere.qmqm.pl>
References: <20110419115612.C4ACA13909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ian Campbell <ian.campbell@citrix.com>,
	xen-devel@lists.xensource.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:59338 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751418Ab1DSNfI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2011 09:35:08 -0400
In-Reply-To: <20110419115612.C4ACA13909@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
Acked-by: Ian Campbell <ian.campbell@citrix.com>

---
v2: fix xenvif_fix_features() arguments

 drivers/net/xen-netback/common.h    |    3 -
 drivers/net/xen-netback/interface.c |   84 ++++++---------------------=
-------
 2 files changed, 15 insertions(+), 72 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback=
/common.h
index 5d7bbf2..8753e6d 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -73,9 +73,6 @@ struct xenvif {
 	struct vm_struct *tx_comms_area;
 	struct vm_struct *rx_comms_area;
=20
-	/* Flags that must not be set in dev->features */
-	u32 features_disabled;
-
 	/* Frontend feature information. */
 	u8 can_sg:1;
 	u8 gso:1;
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netb=
ack/interface.c
index de569cc..0ca86f9 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -165,69 +165,18 @@ static int xenvif_change_mtu(struct net_device *d=
ev, int mtu)
 	return 0;
 }
=20
-static void xenvif_set_features(struct xenvif *vif)
-{
-	struct net_device *dev =3D vif->dev;
-	u32 features =3D dev->features;
-
-	if (vif->can_sg)
-		features |=3D NETIF_F_SG;
-	if (vif->gso || vif->gso_prefix)
-		features |=3D NETIF_F_TSO;
-	if (vif->csum)
-		features |=3D NETIF_F_IP_CSUM;
-
-	features &=3D ~(vif->features_disabled);
-
-	if (!(features & NETIF_F_SG) && dev->mtu > ETH_DATA_LEN)
-		dev->mtu =3D ETH_DATA_LEN;
-
-	dev->features =3D features;
-}
-
-static int xenvif_set_tx_csum(struct net_device *dev, u32 data)
+static u32 xenvif_fix_features(struct net_device *dev, u32 features)
 {
 	struct xenvif *vif =3D netdev_priv(dev);
-	if (data) {
-		if (!vif->csum)
-			return -EOPNOTSUPP;
-		vif->features_disabled &=3D ~NETIF_F_IP_CSUM;
-	} else {
-		vif->features_disabled |=3D NETIF_F_IP_CSUM;
-	}
-
-	xenvif_set_features(vif);
-	return 0;
-}
=20
-static int xenvif_set_sg(struct net_device *dev, u32 data)
-{
-	struct xenvif *vif =3D netdev_priv(dev);
-	if (data) {
-		if (!vif->can_sg)
-			return -EOPNOTSUPP;
-		vif->features_disabled &=3D ~NETIF_F_SG;
-	} else {
-		vif->features_disabled |=3D NETIF_F_SG;
-	}
-
-	xenvif_set_features(vif);
-	return 0;
-}
-
-static int xenvif_set_tso(struct net_device *dev, u32 data)
-{
-	struct xenvif *vif =3D netdev_priv(dev);
-	if (data) {
-		if (!vif->gso && !vif->gso_prefix)
-			return -EOPNOTSUPP;
-		vif->features_disabled &=3D ~NETIF_F_TSO;
-	} else {
-		vif->features_disabled |=3D NETIF_F_TSO;
-	}
+	if (!vif->can_sg)
+		features &=3D ~NETIF_F_SG;
+	if (!vif->gso && !vif->gso_prefix)
+		features &=3D ~NETIF_F_TSO;
+	if (!vif->csum)
+		features &=3D ~NETIF_F_IP_CSUM;
=20
-	xenvif_set_features(vif);
-	return 0;
+	return features;
 }
=20
 static const struct xenvif_stat {
@@ -274,12 +223,6 @@ static void xenvif_get_strings(struct net_device *=
dev, u32 stringset, u8 * data)
 }
=20
 static struct ethtool_ops xenvif_ethtool_ops =3D {
-	.get_tx_csum	=3D ethtool_op_get_tx_csum,
-	.set_tx_csum	=3D xenvif_set_tx_csum,
-	.get_sg		=3D ethtool_op_get_sg,
-	.set_sg		=3D xenvif_set_sg,
-	.get_tso	=3D ethtool_op_get_tso,
-	.set_tso	=3D xenvif_set_tso,
 	.get_link	=3D ethtool_op_get_link,
=20
 	.get_sset_count =3D xenvif_get_sset_count,
@@ -293,6 +236,7 @@ static struct net_device_ops xenvif_netdev_ops =3D =
{
 	.ndo_open	=3D xenvif_open,
 	.ndo_stop	=3D xenvif_close,
 	.ndo_change_mtu	=3D xenvif_change_mtu,
+	.ndo_fix_features =3D xenvif_fix_features,
 };
=20
 struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
@@ -331,7 +275,8 @@ struct xenvif *xenvif_alloc(struct device *parent, =
domid_t domid,
 	vif->credit_timeout.expires =3D jiffies;
=20
 	dev->netdev_ops	=3D &xenvif_netdev_ops;
-	xenvif_set_features(vif);
+	dev->hw_features =3D NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
+	dev->features =3D dev->hw_features;
 	SET_ETHTOOL_OPS(dev, &xenvif_ethtool_ops);
=20
 	dev->tx_queue_len =3D XENVIF_QUEUE_LENGTH;
@@ -367,8 +312,6 @@ int xenvif_connect(struct xenvif *vif, unsigned lon=
g tx_ring_ref,
 	if (vif->irq)
 		return 0;
=20
-	xenvif_set_features(vif);
-
 	err =3D xen_netbk_map_frontend_rings(vif, tx_ring_ref, rx_ring_ref);
 	if (err < 0)
 		goto err;
@@ -384,9 +327,12 @@ int xenvif_connect(struct xenvif *vif, unsigned lo=
ng tx_ring_ref,
 	xenvif_get(vif);
=20
 	rtnl_lock();
-	netif_carrier_on(vif->dev);
 	if (netif_running(vif->dev))
 		xenvif_up(vif);
+	if (!vif->can_sg && vif->dev->mtu > ETH_DATA_LEN)
+		dev_set_mtu(vif->dev, ETH_DATA_LEN);
+	netdev_update_features(vif->dev);
+	netif_carrier_on(vif->dev);
 	rtnl_unlock();
=20
 	return 0;
--=20
1.7.2.5

