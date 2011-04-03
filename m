From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] xen: netfront: fix declaration order
Date: Sun, 03 Apr 2011 13:07:19 +0200
Message-ID: <1301828839.2837.143.camel@edumazet-laptop>
References: <20110331110136.03A1A13A6A@rere.qmqm.pl>
	 <20110401.205455.70198735.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org,
	jeremy.fitzhardinge@citrix.com, konrad.wilk@oracle.com,
	Ian.Campbell@citrix.com, xen-devel@lists.xensource.com,
	virtualization@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37314 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751488Ab1DCLH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2011 07:07:27 -0400
Received: by wya21 with SMTP id 21so3995515wya.19
        for <netdev@vger.kernel.org>; Sun, 03 Apr 2011 04:07:26 -0700 (PDT)
In-Reply-To: <20110401.205455.70198735.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 01 avril 2011 =C3=A0 20:54 -0700, David Miller a =C3=A9crit=
 :
> From: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> Date: Thu, 31 Mar 2011 13:01:35 +0200 (CEST)
>=20
> > Not tested in any way. The original code for offload setting seems =
broken
> > as it resets the features on every netback reconnect.
> >=20
> > This will set GSO_ROBUST at device creation time (earlier than conn=
ect time).
> >=20
> > RX checksum offload is forced on - so advertise as it is.
> >=20
> > Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
>=20
> Applied.

Hmm... I had to apply following patch to make it actually compile.

Thanks

[PATCH] xen: netfront: fix declaration order

Must declare xennet_fix_features() and xennet_set_features() before
using them.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/xen-netfront.c |   72 +++++++++++++++++------------------
 1 file changed, 36 insertions(+), 36 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index f6e7e27..0cfe4cc 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1140,6 +1140,42 @@ static void xennet_uninit(struct net_device *dev=
)
 	gnttab_free_grant_references(np->gref_rx_head);
 }
=20
+static u32 xennet_fix_features(struct net_device *dev, u32 features)
+{
+	struct netfront_info *np =3D netdev_priv(dev);
+	int val;
+
+	if (features & NETIF_F_SG) {
+		if (xenbus_scanf(XBT_NIL, np->xbdev->otherend, "feature-sg",
+				 "%d", &val) < 0)
+			val =3D 0;
+
+		if (!val)
+			features &=3D ~NETIF_F_SG;
+	}
+
+	if (features & NETIF_F_TSO) {
+		if (xenbus_scanf(XBT_NIL, np->xbdev->otherend,
+				 "feature-gso-tcpv4", "%d", &val) < 0)
+			val =3D 0;
+
+		if (!val)
+			features &=3D ~NETIF_F_TSO;
+	}
+
+	return features;
+}
+
+static int xennet_set_features(struct net_device *dev, u32 features)
+{
+	if (!(features & NETIF_F_SG) && dev->mtu > ETH_DATA_LEN) {
+		netdev_info(dev, "Reducing MTU because no SG offload");
+		dev->mtu =3D ETH_DATA_LEN;
+	}
+
+	return 0;
+}
+
 static const struct net_device_ops xennet_netdev_ops =3D {
 	.ndo_open            =3D xennet_open,
 	.ndo_uninit          =3D xennet_uninit,
@@ -1513,42 +1549,6 @@ again:
 	return err;
 }
=20
-static u32 xennet_fix_features(struct net_device *dev, u32 features)
-{
-	struct netfront_info *np =3D netdev_priv(dev);
-	int val;
-
-	if (features & NETIF_F_SG) {
-		if (xenbus_scanf(XBT_NIL, np->xbdev->otherend, "feature-sg",
-				 "%d", &val) < 0)
-			val =3D 0;
-
-		if (!val)
-			features &=3D ~NETIF_F_SG;
-	}
-
-	if (features & NETIF_F_TSO) {
-		if (xenbus_scanf(XBT_NIL, np->xbdev->otherend,
-				 "feature-gso-tcpv4", "%d", &val) < 0)
-			val =3D 0;
-
-		if (!val)
-			features &=3D ~NETIF_F_TSO;
-	}
-
-	return features;
-}
-
-static int xennet_set_features(struct net_device *dev, u32 features)
-{
-	if (!(features & NETIF_F_SG) && dev->mtu > ETH_DATA_LEN) {
-		netdev_info(dev, "Reducing MTU because no SG offload");
-		dev->mtu =3D ETH_DATA_LEN;
-	}
-
-	return 0;
-}
-
 static int xennet_connect(struct net_device *dev)
 {
 	struct netfront_info *np =3D netdev_priv(dev);


