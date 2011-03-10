From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PoC PATCH] net: convert xen-netfront to hw_features
Date: Thu, 10 Mar 2011 18:43:57 +0100 (CET)
Message-ID: <c313c8276ae485213dd70ff67ec5acb3512d9012.1299778467.git.mirq-linux@rere.qmqm.pl>
References: <AANLkTinHyFLRkeb60x4Q6uUw6p43XBjk5rpqCMo49WKF@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <AANLkTinHyFLRkeb60x4Q6uUw6p43XBjk5rpqCMo49WKF@mail.gmail.com>
From: Michał Mirosław <mirqus@gmail.com>
List-Unsubscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

This patch converts xen-netfront to hw_features.

It's not tested in any way. The original code for offload setting seems
broken as it resets the features on every netback reconnect.

This will set GSO_ROBUST at device creation time (earlier than connect ti=
me).

RX checksum offload is forced on - so advertise as it is.

netdev_update_features() should be called whenever offload conditions cha=
nge.
This in turn calls ndo_fix_features() and ndo_set_features() to verify th=
em.
I leave this to you as I don't know when or how the notifications get pas=
sed.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/xen-netfront.c |   57 +++++++++++++++++---------------------=
-----
 1 files changed, 23 insertions(+), 34 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index da1f121..c642fd3 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1148,6 +1148,8 @@ static const struct net_device_ops xennet_netdev_op=
s =3D {
 	.ndo_change_mtu	     =3D xennet_change_mtu,
 	.ndo_set_mac_address =3D eth_mac_addr,
 	.ndo_validate_addr   =3D eth_validate_addr,
+	.ndo_fix_features    =3D xennet_fix_features,
+	.ndo_set_features    =3D xennet_set_features,
 };
=20
 static struct net_device * __devinit xennet_create_dev(struct xenbus_dev=
ice *dev)
@@ -1209,7 +1211,9 @@ static struct net_device * __devinit xennet_create_=
dev(struct xenbus_device *dev
 	netdev->netdev_ops	=3D &xennet_netdev_ops;
=20
 	netif_napi_add(netdev, &np->napi, xennet_poll, 64);
-	netdev->features        =3D NETIF_F_IP_CSUM;
+	netdev->features        =3D NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
+				  NETIF_F_GSO_ROBUST;
+	netdev->hw_features	=3D NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO;
=20
 	SET_ETHTOOL_OPS(netdev, &xennet_ethtool_ops);
 	SET_NETDEV_DEV(netdev, &dev->dev);
@@ -1510,52 +1514,40 @@ again:
 	return err;
 }
=20
-static int xennet_set_sg(struct net_device *dev, u32 data)
+static u32 xennet_fix_features(struct net_device *dev, u32 features)
 {
-	if (data) {
-		struct netfront_info *np =3D netdev_priv(dev);
-		int val;
+	struct netfront_info *np =3D netdev_priv(dev);
+	int val;
=20
+	if (features & NETIF_F_SG) {
 		if (xenbus_scanf(XBT_NIL, np->xbdev->otherend, "feature-sg",
 				 "%d", &val) < 0)
 			val =3D 0;
+
 		if (!val)
-			return -ENOSYS;
-	} else if (dev->mtu > ETH_DATA_LEN)
-		dev->mtu =3D ETH_DATA_LEN;
-
-	return ethtool_op_set_sg(dev, data);
-}
-
-static int xennet_set_tso(struct net_device *dev, u32 data)
-{
-	if (data) {
-		struct netfront_info *np =3D netdev_priv(dev);
-		int val;
+			features &=3D ~NETIF_F_SG;
+	}
=20
+	if (features & NETIF_F_TSO) {
 		if (xenbus_scanf(XBT_NIL, np->xbdev->otherend,
 				 "feature-gso-tcpv4", "%d", &val) < 0)
 			val =3D 0;
+
 		if (!val)
-			return -ENOSYS;
+			features &=3D ~NETIF_F_TSO;
 	}
=20
-	return ethtool_op_set_tso(dev, data);
+	return features;
 }
=20
-static void xennet_set_features(struct net_device *dev)
+static int xennet_set_features(struct net_device *dev, u32 features)
 {
-	/* Turn off all GSO bits except ROBUST. */
-	dev->features &=3D ~NETIF_F_GSO_MASK;
-	dev->features |=3D NETIF_F_GSO_ROBUST;
-	xennet_set_sg(dev, 0);
+	if (!(features & NETIF_F_SG) && dev->mtu > ETH_DATA_LEN) {
+		netdev_info(dev, "Reducing MTU because no SG offload");
+		dev->mtu =3D ETH_DATA_LEN;
+	}
=20
-	/* We need checksum offload to enable scatter/gather and TSO. */
-	if (!(dev->features & NETIF_F_IP_CSUM))
-		return;
-
-	if (!xennet_set_sg(dev, 1))
-		xennet_set_tso(dev, 1);
+	return 0;
 }
=20
 static int xennet_connect(struct net_device *dev)
@@ -1582,7 +1574,7 @@ static int xennet_connect(struct net_device *dev)
 	if (err)
 		return err;
=20
-	xennet_set_features(dev);
+	netdev_update_features(dev);
=20
 	spin_lock_bh(&np->rx_lock);
 	spin_lock_irq(&np->tx_lock);
@@ -1710,9 +1702,6 @@ static void xennet_get_strings(struct net_device *d=
ev, u32 stringset, u8 * data)
=20
 static const struct ethtool_ops xennet_ethtool_ops =3D
 {
-	.set_tx_csum =3D ethtool_op_set_tx_csum,
-	.set_sg =3D xennet_set_sg,
-	.set_tso =3D xennet_set_tso,
 	.get_link =3D ethtool_op_get_link,
=20
 	.get_sset_count =3D xennet_get_sset_count,
--=20
1.7.2.3
