From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: fix potential neighbour race in dst_ifdown()
Date: Tue, 09 Aug 2011 08:56:14 +0200
Message-ID: <1312872974.2531.51.camel@edumazet-laptop>
References: <20110729.081902.300678107767426313.davem@davemloft.net>
	 <1311954208.2843.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1312002053.2873.41.camel@edumazet-laptop>
	 <20110803.033442.1456080508068739176.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: synapse@hippy.csoma.elte.hu, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33589 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751140Ab1HIG4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 02:56:23 -0400
Received: by wyg24 with SMTP id 24so143084wyg.19
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2011 23:56:22 -0700 (PDT)
In-Reply-To: <20110803.033442.1456080508068739176.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 03 ao=C3=BBt 2011 =C3=A0 03:34 -0700, David Miller a =C3=A9=
crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sat, 30 Jul 2011 07:00:53 +0200
>=20
> > [PATCH] net: fix NULL dereferences in check_peer_redir()
>=20
> I'm adding this now to my tree so it gets more widespread
> testing.

Thanks David

We probably have other races, here is a followup patch, probably suited
for net-next, since its not clear if its a real problem while device is
unregistering. Consider it as a cleanup at very least.

[PATCH] net: fix potential neighbour race in dst_ifdown()

=46ollowup of commit f2c31e32b378a (fix NULL dereferences in
check_peer_redir()).

We need to make sure dst neighbour doesnt change in dst_ifdown().

=46ix some sparse errors.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/dst.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/core/dst.c b/net/core/dst.c
index 14b33baf..d5e2c4c 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -171,7 +171,7 @@ void *dst_alloc(struct dst_ops *ops, struct net_dev=
ice *dev,
 	dst_init_metrics(dst, dst_default_metrics, true);
 	dst->expires =3D 0UL;
 	dst->path =3D dst;
-	dst->_neighbour =3D NULL;
+	RCU_INIT_POINTER(dst->_neighbour, NULL);
 #ifdef CONFIG_XFRM
 	dst->xfrm =3D NULL;
 #endif
@@ -229,11 +229,11 @@ struct dst_entry *dst_destroy(struct dst_entry * =
dst)
 	smp_rmb();
=20
 again:
-	neigh =3D dst->_neighbour;
+	neigh =3D rcu_dereference_protected(dst->_neighbour, 1);
 	child =3D dst->child;
=20
 	if (neigh) {
-		dst->_neighbour =3D NULL;
+		RCU_INIT_POINTER(dst->_neighbour, NULL);
 		neigh_release(neigh);
 	}
=20
@@ -360,14 +360,19 @@ static void dst_ifdown(struct dst_entry *dst, str=
uct net_device *dev,
 	if (!unregister) {
 		dst->input =3D dst->output =3D dst_discard;
 	} else {
+		struct neighbour *neigh;
+
 		dst->dev =3D dev_net(dst->dev)->loopback_dev;
 		dev_hold(dst->dev);
 		dev_put(dev);
-		if (dst->_neighbour && dst->_neighbour->dev =3D=3D dev) {
-			dst->_neighbour->dev =3D dst->dev;
+		rcu_read_lock();
+		neigh =3D dst_get_neighbour(dst);
+		if (neigh && neigh->dev =3D=3D dev) {
+			neigh->dev =3D dst->dev;
 			dev_hold(dst->dev);
 			dev_put(dev);
 		}
+		rcu_read_unlock();
 	}
 }
=20


