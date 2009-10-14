From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH 2/5] Phonet: routing table backend
Date: Wed, 14 Oct 2009 13:48:28 +0300
Message-ID: <1255517311-19527-2-git-send-email-remi@remlab.net>
References: <06dcdf33b2a0132b2a05c3220735a81e@chewa.net>
 <1255517311-19527-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:36522 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932869AbZJNKtI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2009 06:49:08 -0400
In-Reply-To: <1255517311-19527-1-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

The Phonet "universe" only has 64 addresses, so we keep a trivial flat
routing table.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/pn_dev.h |    5 ++
 net/phonet/pn_dev.c         |  100 +++++++++++++++++++++++++++++++++++=
+++++---
 2 files changed, 99 insertions(+), 6 deletions(-)

diff --git a/include/net/phonet/pn_dev.h b/include/net/phonet/pn_dev.h
index 44c923c..87b5d81 100644
--- a/include/net/phonet/pn_dev.h
+++ b/include/net/phonet/pn_dev.h
@@ -47,6 +47,11 @@ u8 phonet_address_get(struct net_device *dev, u8 add=
r);
 int phonet_address_lookup(struct net *net, u8 addr);
 void phonet_address_notify(int event, struct net_device *dev, u8 addr)=
;
=20
+int phonet_route_add(struct net_device *dev, u8 daddr);
+int phonet_route_del(struct net_device *dev, u8 daddr);
+struct net_device *phonet_route_get(struct net *net, u8 daddr);
+struct net_device *phonet_route_output(struct net *net, u8 daddr);
+
 #define PN_NO_ADDR	0xff
=20
 extern const struct file_operations pn_sock_seq_fops;
diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
index 5f42f30..71fffa5 100644
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -33,8 +33,14 @@
 #include <net/netns/generic.h>
 #include <net/phonet/pn_dev.h>
=20
+struct phonet_routes {
+	spinlock_t		lock;
+	struct net_device	*table[64];
+};
+
 struct phonet_net {
 	struct phonet_device_list pndevs;
+	struct phonet_routes routes;
 };
=20
 int phonet_net_id;
@@ -154,10 +160,11 @@ int phonet_address_del(struct net_device *dev, u8=
 addr)
 }
=20
 /* Gets a source address toward a destination, through a interface. */
-u8 phonet_address_get(struct net_device *dev, u8 addr)
+u8 phonet_address_get(struct net_device *dev, u8 daddr)
 {
 	struct phonet_device_list *pndevs =3D phonet_device_list(dev_net(dev)=
);
 	struct phonet_device *pnd;
+	u8 saddr;
=20
 	spin_lock_bh(&pndevs->lock);
 	pnd =3D __phonet_get(dev);
@@ -165,12 +172,26 @@ u8 phonet_address_get(struct net_device *dev, u8 =
addr)
 		BUG_ON(bitmap_empty(pnd->addrs, 64));
=20
 		/* Use same source address as destination, if possible */
-		if (!test_bit(addr >> 2, pnd->addrs))
-			addr =3D find_first_bit(pnd->addrs, 64) << 2;
+		if (test_bit(daddr >> 2, pnd->addrs))
+			saddr =3D daddr;
+		else
+			saddr =3D find_first_bit(pnd->addrs, 64) << 2;
 	} else
-		addr =3D PN_NO_ADDR;
+		saddr =3D PN_NO_ADDR;
 	spin_unlock_bh(&pndevs->lock);
-	return addr;
+
+	if (saddr =3D=3D PN_NO_ADDR) {
+		/* Fallback to another device */
+		struct net_device *def_dev;
+
+		def_dev =3D phonet_device_get(dev_net(dev));
+		if (def_dev) {
+			if (def_dev !=3D dev)
+				saddr =3D phonet_address_get(def_dev, daddr);
+			dev_put(def_dev);
+		}
+	}
+	return saddr;
 }
=20
 int phonet_address_lookup(struct net *net, u8 addr)
@@ -246,7 +267,7 @@ static struct notifier_block phonet_device_notifier=
 =3D {
 /* Per-namespace Phonet devices handling */
 static int phonet_init_net(struct net *net)
 {
-	struct phonet_net *pnn =3D kmalloc(sizeof(*pnn), GFP_KERNEL);
+	struct phonet_net *pnn =3D kzalloc(sizeof(*pnn), GFP_KERNEL);
 	if (!pnn)
 		return -ENOMEM;
=20
@@ -257,6 +278,7 @@ static int phonet_init_net(struct net *net)
=20
 	INIT_LIST_HEAD(&pnn->pndevs.list);
 	spin_lock_init(&pnn->pndevs.lock);
+	spin_lock_init(&pnn->routes.lock);
 	net_assign_generic(net, phonet_net_id, pnn);
 	return 0;
 }
@@ -300,3 +322,69 @@ void phonet_device_exit(void)
 	unregister_netdevice_notifier(&phonet_device_notifier);
 	unregister_pernet_gen_device(phonet_net_id, &phonet_net_ops);
 }
+
+int phonet_route_add(struct net_device *dev, u8 daddr)
+{
+	struct phonet_net *pnn =3D net_generic(dev_net(dev), phonet_net_id);
+	struct phonet_routes *routes =3D &pnn->routes;
+	int err =3D -EEXIST;
+
+	daddr =3D daddr >> 2;
+	spin_lock_bh(&routes->lock);
+	if (routes->table[daddr] =3D=3D NULL) {
+		routes->table[daddr] =3D dev;
+		dev_hold(dev);
+		err =3D 0;
+	}
+	spin_unlock_bh(&routes->lock);
+	return err;
+}
+
+int phonet_route_del(struct net_device *dev, u8 daddr)
+{
+	struct phonet_net *pnn =3D net_generic(dev_net(dev), phonet_net_id);
+	struct phonet_routes *routes =3D &pnn->routes;
+	int err =3D -ENOENT;
+
+	daddr =3D daddr >> 2;
+	spin_lock_bh(&routes->lock);
+	if (dev =3D=3D routes->table[daddr]) {
+		routes->table[daddr] =3D NULL;
+		dev_put(dev);
+		err =3D 0;
+	}
+	spin_unlock_bh(&routes->lock);
+	return err;
+}
+
+struct net_device *phonet_route_get(struct net *net, u8 daddr)
+{
+	struct phonet_net *pnn =3D net_generic(net, phonet_net_id);
+	struct phonet_routes *routes =3D &pnn->routes;
+	struct net_device *dev;
+
+	ASSERT_RTNL(); /* no need to hold the device */
+
+	daddr >>=3D 2;
+	spin_lock_bh(&routes->lock);
+	dev =3D routes->table[daddr];
+	spin_unlock_bh(&routes->lock);
+	return dev;
+}
+
+struct net_device *phonet_route_output(struct net *net, u8 daddr)
+{
+	struct phonet_net *pnn =3D net_generic(net, phonet_net_id);
+	struct phonet_routes *routes =3D &pnn->routes;
+	struct net_device *dev;
+
+	spin_lock_bh(&routes->lock);
+	dev =3D routes->table[daddr >> 2];
+	if (dev)
+		dev_hold(dev);
+	spin_unlock_bh(&routes->lock);
+
+	if (!dev)
+		dev =3D phonet_device_get(net); /* Default route */
+	return dev;
+}
--=20
1.6.0.4

