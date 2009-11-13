From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH net-next 2/2] Phonet: convert routing table to RCU
Date: Fri, 13 Nov 2009 17:01:19 +0200
Message-ID: <1258124479-1167-2-git-send-email-remi@remlab.net>
References: <1258124479-1167-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:42996 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754986AbZKMPBO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 10:01:14 -0500
In-Reply-To: <1258124479-1167-1-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/pn_dev.c |   59 +++++++++++++++++++++++++++++--------------=
-------
 1 files changed, 34 insertions(+), 25 deletions(-)

diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
index 6d64fda..3287f8f 100644
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -34,7 +34,7 @@
 #include <net/phonet/pn_dev.h>
=20
 struct phonet_routes {
-	spinlock_t		lock;
+	struct mutex		lock;
 	struct net_device	*table[64];
 };
=20
@@ -248,17 +248,22 @@ static void phonet_route_autodel(struct net_devic=
e *dev)
=20
 	/* Remove left-over Phonet routes */
 	bitmap_zero(deleted, 64);
-	spin_lock_bh(&pnn->routes.lock);
+	mutex_lock(&pnn->routes.lock);
 	for (i =3D 0; i < 64; i++)
 		if (dev =3D=3D pnn->routes.table[i]) {
+			rcu_assign_pointer(pnn->routes.table[i], NULL);
 			set_bit(i, deleted);
-			pnn->routes.table[i] =3D NULL;
-			dev_put(dev);
 		}
-	spin_unlock_bh(&pnn->routes.lock);
+	mutex_unlock(&pnn->routes.lock);
+
+	if (bitmap_empty(deleted, 64))
+		return; /* short-circuit RCU */
+	synchronize_rcu();
 	for (i =3D find_first_bit(deleted, 64); i < 64;
-			i =3D find_next_bit(deleted, 64, i + 1))
+			i =3D find_next_bit(deleted, 64, i + 1)) {
 		rtm_phonet_notify(RTM_DELROUTE, dev, i);
+		dev_put(dev);
+	}
 }
=20
 /* notify Phonet of device events */
@@ -300,7 +305,7 @@ static int phonet_init_net(struct net *net)
=20
 	INIT_LIST_HEAD(&pnn->pndevs.list);
 	spin_lock_init(&pnn->pndevs.lock);
-	spin_lock_init(&pnn->routes.lock);
+	mutex_init(&pnn->routes.lock);
 	net_assign_generic(net, phonet_net_id, pnn);
 	return 0;
 }
@@ -361,13 +366,13 @@ int phonet_route_add(struct net_device *dev, u8 d=
addr)
 	int err =3D -EEXIST;
=20
 	daddr =3D daddr >> 2;
-	spin_lock_bh(&routes->lock);
+	mutex_lock(&routes->lock);
 	if (routes->table[daddr] =3D=3D NULL) {
-		routes->table[daddr] =3D dev;
+		rcu_assign_pointer(routes->table[daddr], dev);
 		dev_hold(dev);
 		err =3D 0;
 	}
-	spin_unlock_bh(&routes->lock);
+	mutex_unlock(&routes->lock);
 	return err;
 }
=20
@@ -375,17 +380,20 @@ int phonet_route_del(struct net_device *dev, u8 d=
addr)
 {
 	struct phonet_net *pnn =3D net_generic(dev_net(dev), phonet_net_id);
 	struct phonet_routes *routes =3D &pnn->routes;
-	int err =3D -ENOENT;
=20
 	daddr =3D daddr >> 2;
-	spin_lock_bh(&routes->lock);
-	if (dev =3D=3D routes->table[daddr]) {
-		routes->table[daddr] =3D NULL;
-		dev_put(dev);
-		err =3D 0;
-	}
-	spin_unlock_bh(&routes->lock);
-	return err;
+	mutex_lock(&routes->lock);
+	if (dev =3D=3D routes->table[daddr])
+		rcu_assign_pointer(routes->table[daddr], NULL);
+	else
+		dev =3D NULL;
+	mutex_unlock(&routes->lock);
+
+	if (!dev)
+		return -ENOENT;
+	synchronize_rcu();
+	dev_put(dev);
+	return 0;
 }
=20
 struct net_device *phonet_route_get(struct net *net, u8 daddr)
@@ -397,9 +405,9 @@ struct net_device *phonet_route_get(struct net *net=
, u8 daddr)
 	ASSERT_RTNL(); /* no need to hold the device */
=20
 	daddr >>=3D 2;
-	spin_lock_bh(&routes->lock);
-	dev =3D routes->table[daddr];
-	spin_unlock_bh(&routes->lock);
+	rcu_read_lock();
+	dev =3D rcu_dereference(routes->table[daddr]);
+	rcu_read_unlock();
 	return dev;
 }
=20
@@ -409,11 +417,12 @@ struct net_device *phonet_route_output(struct net=
 *net, u8 daddr)
 	struct phonet_routes *routes =3D &pnn->routes;
 	struct net_device *dev;
=20
-	spin_lock_bh(&routes->lock);
-	dev =3D routes->table[daddr >> 2];
+	daddr >>=3D 2;
+	rcu_read_lock();
+	dev =3D rcu_dereference(routes->table[daddr]);
 	if (dev)
 		dev_hold(dev);
-	spin_unlock_bh(&routes->lock);
+	rcu_read_unlock();
=20
 	if (!dev)
 		dev =3D phonet_device_get(net); /* Default route */
--=20
1.6.3.3

