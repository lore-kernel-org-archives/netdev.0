From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [RFC] [PATCH net-next] Phonet: convert devices list to RCU
Date: Tue, 17 Nov 2009 15:02:36 +0200
Message-ID: <1258462956-31549-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:40769 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750990AbZKQNCb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Nov 2009 08:02:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/pn_dev.h |    2 +-
 net/phonet/pn_dev.c         |   63 ++++++++++++++++++++++++++++-------=
--------
 net/phonet/pn_netlink.c     |    6 ++--
 3 files changed, 45 insertions(+), 26 deletions(-)

diff --git a/include/net/phonet/pn_dev.h b/include/net/phonet/pn_dev.h
index afa7def..d7b989c 100644
--- a/include/net/phonet/pn_dev.h
+++ b/include/net/phonet/pn_dev.h
@@ -25,7 +25,7 @@
=20
 struct phonet_device_list {
 	struct list_head list;
-	spinlock_t lock;
+	struct mutex lock;
 };
=20
 struct phonet_device_list *phonet_device_list(struct net *net);
diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
index 3287f8f..3d9608f 100644
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -61,7 +61,8 @@ static struct phonet_device *__phonet_device_alloc(st=
ruct net_device *dev)
 	pnd->netdev =3D dev;
 	bitmap_zero(pnd->addrs, 64);
=20
-	list_add(&pnd->list, &pndevs->list);
+	BUG_ON(!mutex_is_locked(&pndevs->lock));
+	list_add_rcu(&pnd->list, &pndevs->list);
 	return pnd;
 }
=20
@@ -70,6 +71,7 @@ static struct phonet_device *__phonet_get(struct net_=
device *dev)
 	struct phonet_device_list *pndevs =3D phonet_device_list(dev_net(dev)=
);
 	struct phonet_device *pnd;
=20
+	BUG_ON(!mutex_is_locked(&pndevs->lock));
 	list_for_each_entry(pnd, &pndevs->list, list) {
 		if (pnd->netdev =3D=3D dev)
 			return pnd;
@@ -77,6 +79,18 @@ static struct phonet_device *__phonet_get(struct net=
_device *dev)
 	return NULL;
 }
=20
+static struct phonet_device *__phonet_get_rcu(struct net_device *dev)
+{
+	struct phonet_device_list *pndevs =3D phonet_device_list(dev_net(dev)=
);
+	struct phonet_device *pnd;
+
+	list_for_each_entry_rcu(pnd, &pndevs->list, list) {
+		if (pnd->netdev =3D=3D dev)
+			return pnd;
+	}
+	return NULL;
+}
+
 static void phonet_device_destroy(struct net_device *dev)
 {
 	struct phonet_device_list *pndevs =3D phonet_device_list(dev_net(dev)=
);
@@ -84,11 +98,11 @@ static void phonet_device_destroy(struct net_device=
 *dev)
=20
 	ASSERT_RTNL();
=20
-	spin_lock_bh(&pndevs->lock);
+	mutex_lock(&pndevs->lock);
 	pnd =3D __phonet_get(dev);
 	if (pnd)
-		list_del(&pnd->list);
-	spin_unlock_bh(&pndevs->lock);
+		list_del_rcu(&pnd->list);
+	mutex_unlock(&pndevs->lock);
=20
 	if (pnd) {
 		u8 addr;
@@ -106,8 +120,8 @@ struct net_device *phonet_device_get(struct net *ne=
t)
 	struct phonet_device *pnd;
 	struct net_device *dev =3D NULL;
=20
-	spin_lock_bh(&pndevs->lock);
-	list_for_each_entry(pnd, &pndevs->list, list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(pnd, &pndevs->list, list) {
 		dev =3D pnd->netdev;
 		BUG_ON(!dev);
=20
@@ -118,7 +132,7 @@ struct net_device *phonet_device_get(struct net *ne=
t)
 	}
 	if (dev)
 		dev_hold(dev);
-	spin_unlock_bh(&pndevs->lock);
+	rcu_read_unlock();
 	return dev;
 }
=20
@@ -128,7 +142,7 @@ int phonet_address_add(struct net_device *dev, u8 a=
ddr)
 	struct phonet_device *pnd;
 	int err =3D 0;
=20
-	spin_lock_bh(&pndevs->lock);
+	mutex_lock(&pndevs->lock);
 	/* Find or create Phonet-specific device data */
 	pnd =3D __phonet_get(dev);
 	if (pnd =3D=3D NULL)
@@ -137,7 +151,7 @@ int phonet_address_add(struct net_device *dev, u8 a=
ddr)
 		err =3D -ENOMEM;
 	else if (test_and_set_bit(addr >> 2, pnd->addrs))
 		err =3D -EEXIST;
-	spin_unlock_bh(&pndevs->lock);
+	mutex_unlock(&pndevs->lock);
 	return err;
 }
=20
@@ -147,27 +161,32 @@ int phonet_address_del(struct net_device *dev, u8=
 addr)
 	struct phonet_device *pnd;
 	int err =3D 0;
=20
-	spin_lock_bh(&pndevs->lock);
+	mutex_lock(&pndevs->lock);
 	pnd =3D __phonet_get(dev);
-	if (!pnd || !test_and_clear_bit(addr >> 2, pnd->addrs))
+	if (!pnd || !test_and_clear_bit(addr >> 2, pnd->addrs)) {
 		err =3D -EADDRNOTAVAIL;
-	else if (bitmap_empty(pnd->addrs, 64)) {
-		list_del(&pnd->list);
+		pnd =3D NULL;
+	} else if (bitmap_empty(pnd->addrs, 64))
+		list_del_rcu(&pnd->list);
+	else
+		pnd =3D NULL;
+	mutex_unlock(&pndevs->lock);
+
+	if (pnd) {
+		synchronize_rcu();
 		kfree(pnd);
 	}
-	spin_unlock_bh(&pndevs->lock);
 	return err;
 }
=20
 /* Gets a source address toward a destination, through a interface. */
 u8 phonet_address_get(struct net_device *dev, u8 daddr)
 {
-	struct phonet_device_list *pndevs =3D phonet_device_list(dev_net(dev)=
);
 	struct phonet_device *pnd;
 	u8 saddr;
=20
-	spin_lock_bh(&pndevs->lock);
-	pnd =3D __phonet_get(dev);
+	rcu_read_lock();
+	pnd =3D __phonet_get_rcu(dev);
 	if (pnd) {
 		BUG_ON(bitmap_empty(pnd->addrs, 64));
=20
@@ -178,7 +197,7 @@ u8 phonet_address_get(struct net_device *dev, u8 da=
ddr)
 			saddr =3D find_first_bit(pnd->addrs, 64) << 2;
 	} else
 		saddr =3D PN_NO_ADDR;
-	spin_unlock_bh(&pndevs->lock);
+	rcu_read_unlock();
=20
 	if (saddr =3D=3D PN_NO_ADDR) {
 		/* Fallback to another device */
@@ -200,8 +219,8 @@ int phonet_address_lookup(struct net *net, u8 addr)
 	struct phonet_device *pnd;
 	int err =3D -EADDRNOTAVAIL;
=20
-	spin_lock_bh(&pndevs->lock);
-	list_for_each_entry(pnd, &pndevs->list, list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(pnd, &pndevs->list, list) {
 		/* Don't allow unregistering devices! */
 		if ((pnd->netdev->reg_state !=3D NETREG_REGISTERED) ||
 				((pnd->netdev->flags & IFF_UP)) !=3D IFF_UP)
@@ -213,7 +232,7 @@ int phonet_address_lookup(struct net *net, u8 addr)
 		}
 	}
 found:
-	spin_unlock_bh(&pndevs->lock);
+	rcu_read_unlock();
 	return err;
 }
=20
@@ -304,7 +323,7 @@ static int phonet_init_net(struct net *net)
 	}
=20
 	INIT_LIST_HEAD(&pnn->pndevs.list);
-	spin_lock_init(&pnn->pndevs.lock);
+	mutex_init(&pnn->pndevs.lock);
 	mutex_init(&pnn->routes.lock);
 	net_assign_generic(net, phonet_net_id, pnn);
 	return 0;
diff --git a/net/phonet/pn_netlink.c b/net/phonet/pn_netlink.c
index 609e509..2e6c7eb 100644
--- a/net/phonet/pn_netlink.c
+++ b/net/phonet/pn_netlink.c
@@ -131,8 +131,8 @@ static int getaddr_dumpit(struct sk_buff *skb, stru=
ct netlink_callback *cb)
 	int addr_idx =3D 0, addr_start_idx =3D cb->args[1];
=20
 	pndevs =3D phonet_device_list(sock_net(skb->sk));
-	spin_lock_bh(&pndevs->lock);
-	list_for_each_entry(pnd, &pndevs->list, list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(pnd, &pndevs->list, list) {
 		u8 addr;
=20
 		if (dev_idx > dev_start_idx)
@@ -154,7 +154,7 @@ static int getaddr_dumpit(struct sk_buff *skb, stru=
ct netlink_callback *cb)
 	}
=20
 out:
-	spin_unlock_bh(&pndevs->lock);
+	rcu_read_unlock();
 	cb->args[0] =3D dev_idx;
 	cb->args[1] =3D addr_idx;
=20
--=20
1.6.3.3

