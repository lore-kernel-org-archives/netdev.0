From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 6/6] Phonet: use per-namespace devices list
Date: Fri, 23 Jan 2009 15:00:30 +0200
Message-ID: <1232715630-24951-6-git-send-email-remi.denis-courmont@nokia.com>
References: <200901231459.29743.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:50751 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755749AbZAWNAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 08:00:47 -0500
Received: from esebh105.NOE.Nokia.com (esebh105.ntc.nokia.com [172.21.138.211])
	by mgw-mx06.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id n0ND0Mlk011170
	for <netdev@vger.kernel.org>; Fri, 23 Jan 2009 15:00:44 +0200
Received: from localhost.localdomain (esdhcp041160.research.nokia.com [172.21.41.160])
	by mgw-int01.ntc.nokia.com (Switch-3.2.5/Switch-3.2.5) with ESMTP id n0ND0Fo9027886
	for <netdev@vger.kernel.org>; Fri, 23 Jan 2009 15:00:22 +0200
In-Reply-To: <200901231459.29743.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/pn_dev.h |    2 +-
 net/phonet/pn_dev.c         |  108 ++++++++++++++++++++++++++++++-----=
--------
 net/phonet/pn_netlink.c     |   11 ++--
 3 files changed, 81 insertions(+), 40 deletions(-)

diff --git a/include/net/phonet/pn_dev.h b/include/net/phonet/pn_dev.h
index 4ba2aed..5054dc5 100644
--- a/include/net/phonet/pn_dev.h
+++ b/include/net/phonet/pn_dev.h
@@ -28,7 +28,7 @@ struct phonet_device_list {
 	spinlock_t lock;
 };
=20
-extern struct phonet_device_list pndevs;
+struct phonet_device_list *phonet_device_list(struct net *net);
=20
 struct phonet_device {
 	struct list_head list;
diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
index 3e24c05..80a322d 100644
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -28,32 +28,41 @@
 #include <linux/netdevice.h>
 #include <linux/phonet.h>
 #include <net/sock.h>
+#include <net/netns/generic.h>
 #include <net/phonet/pn_dev.h>
=20
-/* when accessing, remember to lock with spin_lock(&pndevs.lock); */
-struct phonet_device_list pndevs =3D {
-	.list =3D LIST_HEAD_INIT(pndevs.list),
-	.lock =3D __SPIN_LOCK_UNLOCKED(pndevs.lock),
+struct phonet_net {
+	struct phonet_device_list pndevs;
 };
=20
+int phonet_net_id;
+
+struct phonet_device_list *phonet_device_list(struct net *net)
+{
+	struct phonet_net *pnn =3D net_generic(net, phonet_net_id);
+	return &pnn->pndevs;
+}
+
 /* Allocate new Phonet device. */
 static struct phonet_device *__phonet_device_alloc(struct net_device *=
dev)
 {
+	struct phonet_device_list *pndevs =3D phonet_device_list(dev_net(dev)=
);
 	struct phonet_device *pnd =3D kmalloc(sizeof(*pnd), GFP_ATOMIC);
 	if (pnd =3D=3D NULL)
 		return NULL;
 	pnd->netdev =3D dev;
 	bitmap_zero(pnd->addrs, 64);
=20
-	list_add(&pnd->list, &pndevs.list);
+	list_add(&pnd->list, &pndevs->list);
 	return pnd;
 }
=20
 static struct phonet_device *__phonet_get(struct net_device *dev)
 {
+	struct phonet_device_list *pndevs =3D phonet_device_list(dev_net(dev)=
);
 	struct phonet_device *pnd;
=20
-	list_for_each_entry(pnd, &pndevs.list, list) {
+	list_for_each_entry(pnd, &pndevs->list, list) {
 		if (pnd->netdev =3D=3D dev)
 			return pnd;
 	}
@@ -68,32 +77,33 @@ static void __phonet_device_free(struct phonet_devi=
ce *pnd)
=20
 struct net_device *phonet_device_get(struct net *net)
 {
+	struct phonet_device_list *pndevs =3D phonet_device_list(net);
 	struct phonet_device *pnd;
 	struct net_device *dev;
=20
-	spin_lock_bh(&pndevs.lock);
-	list_for_each_entry(pnd, &pndevs.list, list) {
+	spin_lock_bh(&pndevs->lock);
+	list_for_each_entry(pnd, &pndevs->list, list) {
 		dev =3D pnd->netdev;
 		BUG_ON(!dev);
=20
-		if (net_eq(dev_net(dev), net) &&
-			(dev->reg_state =3D=3D NETREG_REGISTERED) &&
+		if ((dev->reg_state =3D=3D NETREG_REGISTERED) &&
 			((pnd->netdev->flags & IFF_UP)) =3D=3D IFF_UP)
 			break;
 		dev =3D NULL;
 	}
 	if (dev)
 		dev_hold(dev);
-	spin_unlock_bh(&pndevs.lock);
+	spin_unlock_bh(&pndevs->lock);
 	return dev;
 }
=20
 int phonet_address_add(struct net_device *dev, u8 addr)
 {
+	struct phonet_device_list *pndevs =3D phonet_device_list(dev_net(dev)=
);
 	struct phonet_device *pnd;
 	int err =3D 0;
=20
-	spin_lock_bh(&pndevs.lock);
+	spin_lock_bh(&pndevs->lock);
 	/* Find or create Phonet-specific device data */
 	pnd =3D __phonet_get(dev);
 	if (pnd =3D=3D NULL)
@@ -102,31 +112,33 @@ int phonet_address_add(struct net_device *dev, u8=
 addr)
 		err =3D -ENOMEM;
 	else if (test_and_set_bit(addr >> 2, pnd->addrs))
 		err =3D -EEXIST;
-	spin_unlock_bh(&pndevs.lock);
+	spin_unlock_bh(&pndevs->lock);
 	return err;
 }
=20
 int phonet_address_del(struct net_device *dev, u8 addr)
 {
+	struct phonet_device_list *pndevs =3D phonet_device_list(dev_net(dev)=
);
 	struct phonet_device *pnd;
 	int err =3D 0;
=20
-	spin_lock_bh(&pndevs.lock);
+	spin_lock_bh(&pndevs->lock);
 	pnd =3D __phonet_get(dev);
 	if (!pnd || !test_and_clear_bit(addr >> 2, pnd->addrs))
 		err =3D -EADDRNOTAVAIL;
 	else if (bitmap_empty(pnd->addrs, 64))
 		__phonet_device_free(pnd);
-	spin_unlock_bh(&pndevs.lock);
+	spin_unlock_bh(&pndevs->lock);
 	return err;
 }
=20
 /* Gets a source address toward a destination, through a interface. */
 u8 phonet_address_get(struct net_device *dev, u8 addr)
 {
+	struct phonet_device_list *pndevs =3D phonet_device_list(dev_net(dev)=
);
 	struct phonet_device *pnd;
=20
-	spin_lock_bh(&pndevs.lock);
+	spin_lock_bh(&pndevs->lock);
 	pnd =3D __phonet_get(dev);
 	if (pnd) {
 		BUG_ON(bitmap_empty(pnd->addrs, 64));
@@ -136,30 +148,31 @@ u8 phonet_address_get(struct net_device *dev, u8 =
addr)
 			addr =3D find_first_bit(pnd->addrs, 64) << 2;
 	} else
 		addr =3D PN_NO_ADDR;
-	spin_unlock_bh(&pndevs.lock);
+	spin_unlock_bh(&pndevs->lock);
 	return addr;
 }
=20
 int phonet_address_lookup(struct net *net, u8 addr)
 {
+	struct phonet_device_list *pndevs =3D phonet_device_list(net);
 	struct phonet_device *pnd;
+	int err =3D -EADDRNOTAVAIL;
=20
-	spin_lock_bh(&pndevs.lock);
-	list_for_each_entry(pnd, &pndevs.list, list) {
-		if (!net_eq(dev_net(pnd->netdev), net))
-			continue;
+	spin_lock_bh(&pndevs->lock);
+	list_for_each_entry(pnd, &pndevs->list, list) {
 		/* Don't allow unregistering devices! */
 		if ((pnd->netdev->reg_state !=3D NETREG_REGISTERED) ||
 				((pnd->netdev->flags & IFF_UP)) !=3D IFF_UP)
 			continue;
=20
 		if (test_bit(addr >> 2, pnd->addrs)) {
-			spin_unlock_bh(&pndevs.lock);
-			return 0;
+			err =3D 0;
+			goto found;
 		}
 	}
-	spin_unlock_bh(&pndevs.lock);
-	return -EADDRNOTAVAIL;
+found:
+	spin_unlock_bh(&pndevs->lock);
+	return err;
 }
=20
 /* notify Phonet of device events */
@@ -169,14 +182,16 @@ static int phonet_device_notify(struct notifier_b=
lock *me, unsigned long what,
 	struct net_device *dev =3D arg;
=20
 	if (what =3D=3D NETDEV_UNREGISTER) {
+		struct phonet_device_list *pndevs;
 		struct phonet_device *pnd;
=20
 		/* Destroy phonet-specific device data */
-		spin_lock_bh(&pndevs.lock);
+		pndevs =3D phonet_device_list(dev_net(dev));
+		spin_lock_bh(&pndevs->lock);
 		pnd =3D __phonet_get(dev);
 		if (pnd)
 			__phonet_device_free(pnd);
-		spin_unlock_bh(&pndevs.lock);
+		spin_unlock_bh(&pndevs->lock);
 	}
 	return 0;
=20
@@ -187,10 +202,41 @@ static struct notifier_block phonet_device_notifi=
er =3D {
 	.priority =3D 0,
 };
=20
+/* Per-namespace Phonet devices handling */
+static int phonet_init_net(struct net *net)
+{
+	struct phonet_net *pnn =3D kmalloc(sizeof(*pnn), GFP_KERNEL);
+	if (!pnn)
+		return -ENOMEM;
+
+	INIT_LIST_HEAD(&pnn->pndevs.list);
+	spin_lock_init(&pnn->pndevs.lock);
+	net_assign_generic(net, phonet_net_id, pnn);
+	return 0;
+}
+
+static void phonet_exit_net(struct net *net)
+{
+	struct phonet_net *pnn =3D net_generic(net, phonet_net_id);
+	struct phonet_device *pnd, *n;
+
+	list_for_each_entry_safe(pnd, n, &pnn->pndevs.list, list)
+		__phonet_device_free(pnd);
+
+	kfree(pnn);
+}
+
+static struct pernet_operations phonet_net_ops =3D {
+	.init =3D phonet_init_net,
+	.exit =3D phonet_exit_net,
+};
+
 /* Initialize Phonet devices list */
 int __init phonet_device_init(void)
 {
-	int err;
+	int err =3D register_pernet_gen_device(&phonet_net_id, &phonet_net_op=
s);
+	if (err)
+		return err;
=20
 	register_netdevice_notifier(&phonet_device_notifier);
 	err =3D phonet_netlink_register();
@@ -201,11 +247,7 @@ int __init phonet_device_init(void)
=20
 void phonet_device_exit(void)
 {
-	struct phonet_device *pnd, *n;
-
 	rtnl_unregister_all(PF_PHONET);
 	unregister_netdevice_notifier(&phonet_device_notifier);
-
-	list_for_each_entry_safe(pnd, n, &pndevs.list, list)
-		__phonet_device_free(pnd);
+	unregister_pernet_gen_device(phonet_net_id, &phonet_net_ops);
 }
diff --git a/net/phonet/pn_netlink.c b/net/phonet/pn_netlink.c
index 918a4f0..1ceea1f 100644
--- a/net/phonet/pn_netlink.c
+++ b/net/phonet/pn_netlink.c
@@ -123,17 +123,16 @@ nla_put_failure:
=20
 static int getaddr_dumpit(struct sk_buff *skb, struct netlink_callback=
 *cb)
 {
-	struct net *net =3D sock_net(skb->sk);
+	struct phonet_device_list *pndevs;
 	struct phonet_device *pnd;
 	int dev_idx =3D 0, dev_start_idx =3D cb->args[0];
 	int addr_idx =3D 0, addr_start_idx =3D cb->args[1];
=20
-	spin_lock_bh(&pndevs.lock);
-	list_for_each_entry(pnd, &pndevs.list, list) {
+	pndevs =3D phonet_device_list(sock_net(skb->sk));
+	spin_lock_bh(&pndevs->lock);
+	list_for_each_entry(pnd, &pndevs->list, list) {
 		u8 addr;
=20
-		if (!net_eq(dev_net(pnd->netdev), net))
-			continue;
 		if (dev_idx > dev_start_idx)
 			addr_start_idx =3D 0;
 		if (dev_idx++ < dev_start_idx)
@@ -153,7 +152,7 @@ static int getaddr_dumpit(struct sk_buff *skb, stru=
ct netlink_callback *cb)
 	}
=20
 out:
-	spin_unlock_bh(&pndevs.lock);
+	spin_unlock_bh(&pndevs->lock);
 	cb->args[0] =3D dev_idx;
 	cb->args[1] =3D addr_idx;
=20
--=20
1.5.6.3

