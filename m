From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux-CoA6ZxLDdyEEUmgCuDUIdw@public.gmane.org>
Subject: [PATCH] net: infiniband/ulp/ipoib: convert to hw_features
Date: Tue, 19 Apr 2011 12:43:20 +0200 (CEST)
Message-ID: <20110419104320.7D01C13A67@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux-CoA6ZxLDdyEEUmgCuDUIdw@public.gmane.org>
---
 drivers/infiniband/ulp/ipoib/ipoib.h         |    1 -
 drivers/infiniband/ulp/ipoib/ipoib_cm.c      |   11 +--------
 drivers/infiniband/ulp/ipoib/ipoib_ethtool.c |   28 ------------------=
--------
 drivers/infiniband/ulp/ipoib/ipoib_ib.c      |    2 +-
 drivers/infiniband/ulp/ipoib/ipoib_main.c    |   26 ++++++++++++++++--=
-----
 5 files changed, 21 insertions(+), 47 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib.h b/drivers/infiniband/=
ulp/ipoib/ipoib.h
index ab97f92..7b6985a 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib.h
+++ b/drivers/infiniband/ulp/ipoib/ipoib.h
@@ -91,7 +91,6 @@ enum {
 	IPOIB_STOP_REAPER	  =3D 7,
 	IPOIB_FLAG_ADMIN_CM	  =3D 9,
 	IPOIB_FLAG_UMCAST	  =3D 10,
-	IPOIB_FLAG_CSUM		  =3D 11,
=20
 	IPOIB_MAX_BACKOFF_SECONDS =3D 16,
=20
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_cm.c b/drivers/infiniba=
nd/ulp/ipoib/ipoib_cm.c
index 93d5580..39913a0 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_cm.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
@@ -1463,8 +1463,7 @@ static ssize_t set_mode(struct device *d, struct =
device_attribute *attr,
 		set_bit(IPOIB_FLAG_ADMIN_CM, &priv->flags);
 		ipoib_warn(priv, "enabling connected mode "
 			   "will cause multicast packet drops\n");
-
-		dev->features &=3D ~(NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO);
+		netdev_update_features(dev);
 		rtnl_unlock();
 		priv->tx_wr.send_flags &=3D ~IB_SEND_IP_CSUM;
=20
@@ -1474,13 +1473,7 @@ static ssize_t set_mode(struct device *d, struct=
 device_attribute *attr,
=20
 	if (!strcmp(buf, "datagram\n")) {
 		clear_bit(IPOIB_FLAG_ADMIN_CM, &priv->flags);
-
-		if (test_bit(IPOIB_FLAG_CSUM, &priv->flags)) {
-			dev->features |=3D NETIF_F_IP_CSUM | NETIF_F_SG;
-			priv->dev->features |=3D NETIF_F_GRO;
-			if (priv->hca_caps & IB_DEVICE_UD_TSO)
-				dev->features |=3D NETIF_F_TSO;
-		}
+		netdev_update_features(dev);
 		dev_set_mtu(dev, min(priv->mcast_mtu, dev->mtu));
 		rtnl_unlock();
 		ipoib_flush_paths(dev);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ethtool.c b/drivers/inf=
iniband/ulp/ipoib/ipoib_ethtool.c
index 19f7f52..29bc7b5 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_ethtool.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_ethtool.c
@@ -42,32 +42,6 @@ static void ipoib_get_drvinfo(struct net_device *net=
dev,
 	strncpy(drvinfo->driver, "ipoib", sizeof(drvinfo->driver) - 1);
 }
=20
-static u32 ipoib_get_rx_csum(struct net_device *dev)
-{
-	struct ipoib_dev_priv *priv =3D netdev_priv(dev);
-	return test_bit(IPOIB_FLAG_CSUM, &priv->flags) &&
-		!test_bit(IPOIB_FLAG_ADMIN_CM, &priv->flags);
-}
-
-static int ipoib_set_tso(struct net_device *dev, u32 data)
-{
-	struct ipoib_dev_priv *priv =3D netdev_priv(dev);
-
-	if (data) {
-		if (!test_bit(IPOIB_FLAG_ADMIN_CM, &priv->flags) &&
-		    (dev->features & NETIF_F_SG) &&
-		    (priv->hca_caps & IB_DEVICE_UD_TSO)) {
-			dev->features |=3D NETIF_F_TSO;
-		} else {
-			ipoib_warn(priv, "can't set TSO on\n");
-			return -EOPNOTSUPP;
-		}
-	} else
-		dev->features &=3D ~NETIF_F_TSO;
-
-	return 0;
-}
-
 static int ipoib_get_coalesce(struct net_device *dev,
 			      struct ethtool_coalesce *coal)
 {
@@ -108,8 +82,6 @@ static int ipoib_set_coalesce(struct net_device *dev=
,
=20
 static const struct ethtool_ops ipoib_ethtool_ops =3D {
 	.get_drvinfo		=3D ipoib_get_drvinfo,
-	.get_rx_csum		=3D ipoib_get_rx_csum,
-	.set_tso		=3D ipoib_set_tso,
 	.get_coalesce		=3D ipoib_get_coalesce,
 	.set_coalesce		=3D ipoib_set_coalesce,
 };
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ib.c b/drivers/infiniba=
nd/ulp/ipoib/ipoib_ib.c
index 806d029..81ae61d 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_ib.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
@@ -292,7 +292,7 @@ static void ipoib_ib_handle_rx_wc(struct net_device=
 *dev, struct ib_wc *wc)
 	dev->stats.rx_bytes +=3D skb->len;
=20
 	skb->dev =3D dev;
-	if (test_bit(IPOIB_FLAG_CSUM, &priv->flags) && likely(wc->csum_ok))
+	if ((dev->features & NETIF_F_RXCSUM) && likely(wc->csum_ok))
 		skb->ip_summed =3D CHECKSUM_UNNECESSARY;
=20
 	napi_gro_receive(&priv->napi, skb);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infini=
band/ulp/ipoib/ipoib_main.c
index aca3b44..86addca 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -171,6 +171,16 @@ static int ipoib_stop(struct net_device *dev)
 	return 0;
 }
=20
+static u32 ipoib_fix_features(struct net_device *dev, u32 features)
+{
+	struct ipoib_dev_priv *priv =3D netdev_priv(dev);
+
+	if (test_bit(IPOIB_FLAG_ADMIN_CM, &priv->flags))
+		features &=3D ~(NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO);
+
+	return features;
+}
+
 static int ipoib_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct ipoib_dev_priv *priv =3D netdev_priv(dev);
@@ -970,6 +980,7 @@ static const struct net_device_ops ipoib_netdev_ops=
 =3D {
 	.ndo_open		 =3D ipoib_open,
 	.ndo_stop		 =3D ipoib_stop,
 	.ndo_change_mtu		 =3D ipoib_change_mtu,
+	.ndo_fix_features	 =3D ipoib_fix_features,
 	.ndo_start_xmit	 	 =3D ipoib_start_xmit,
 	.ndo_tx_timeout		 =3D ipoib_timeout,
 	.ndo_set_multicast_list	 =3D ipoib_set_mcast_list,
@@ -1154,19 +1165,18 @@ int ipoib_set_dev_features(struct ipoib_dev_pri=
v *priv, struct ib_device *hca)
 	kfree(device_attr);
=20
 	if (priv->hca_caps & IB_DEVICE_UD_IP_CSUM) {
-		set_bit(IPOIB_FLAG_CSUM, &priv->flags);
-		priv->dev->features |=3D NETIF_F_SG | NETIF_F_IP_CSUM;
+		priv->dev->hw_features =3D NETIF_F_SG |
+			NETIF_F_IP_CSUM | NETIF_F_RXCSUM;
+
+		if (priv->hca_caps & IB_DEVICE_UD_TSO)
+			priv->dev->hw_features |=3D NETIF_F_TSO;
+
+		priv->dev->features |=3D priv->dev->hw_features;
 	}
=20
-	priv->dev->features |=3D NETIF_F_GRO;
-
-	if (priv->dev->features & NETIF_F_SG && priv->hca_caps & IB_DEVICE_UD=
_TSO)
-		priv->dev->features |=3D NETIF_F_TSO;
-
 	return 0;
 }
=20
-
 static struct net_device *ipoib_add_port(const char *format,
 					 struct ib_device *hca, u8 port)
 {
--=20
1.7.2.5

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
