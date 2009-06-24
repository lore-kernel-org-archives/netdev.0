From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 2/2] Phonet: generate Netlink RTM_DELADDR when destroying a device
Date: Wed, 24 Jun 2009 14:07:45 +0300
Message-ID: <1245841665-14213-2-git-send-email-remi.denis-courmont@nokia.com>
References: <1245841665-14213-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:22229 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751566AbZFXLIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 07:08:21 -0400
Received: from esebh106.NOE.Nokia.com (esebh106.ntc.nokia.com [172.21.138.213])
	by mgw-mx06.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n5OB83Xr009656
	for <netdev@vger.kernel.org>; Wed, 24 Jun 2009 14:08:15 +0300
Received: from localhost.localdomain (esdhcp035213.research.nokia.com [172.21.35.213])
	by mgw-da01.ext.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id n5OB7ipj001750
	for <netdev@vger.kernel.org>; Wed, 24 Jun 2009 14:07:46 +0300
In-Reply-To: <1245841665-14213-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Netlink address deletion events were not sent when a network device
vanished neither when Phonet was unloaded.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/pn_dev.c |   52 ++++++++++++++++++++++++++++++-------------=
-------
 1 files changed, 31 insertions(+), 21 deletions(-)

diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
index 80a322d..b0d6ddd 100644
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -69,10 +69,27 @@ static struct phonet_device *__phonet_get(struct ne=
t_device *dev)
 	return NULL;
 }
=20
-static void __phonet_device_free(struct phonet_device *pnd)
+static void phonet_device_destroy(struct net_device *dev)
 {
-	list_del(&pnd->list);
-	kfree(pnd);
+	struct phonet_device_list *pndevs =3D phonet_device_list(dev_net(dev)=
);
+	struct phonet_device *pnd;
+
+	ASSERT_RTNL();
+
+	spin_lock_bh(&pndevs->lock);
+	pnd =3D __phonet_get(dev);
+	if (pnd)
+		list_del(&pnd->list);
+	spin_unlock_bh(&pndevs->lock);
+
+	if (pnd) {
+		u8 addr;
+
+		for (addr =3D find_first_bit(pnd->addrs, 64); addr < 64;
+			addr =3D find_next_bit(pnd->addrs, 64, 1+addr))
+			phonet_address_notify(RTM_DELADDR, dev, addr);
+		kfree(pnd);
+	}
 }
=20
 struct net_device *phonet_device_get(struct net *net)
@@ -126,8 +143,10 @@ int phonet_address_del(struct net_device *dev, u8 =
addr)
 	pnd =3D __phonet_get(dev);
 	if (!pnd || !test_and_clear_bit(addr >> 2, pnd->addrs))
 		err =3D -EADDRNOTAVAIL;
-	else if (bitmap_empty(pnd->addrs, 64))
-		__phonet_device_free(pnd);
+	else if (bitmap_empty(pnd->addrs, 64)) {
+		list_del(&pnd->list);
+		kfree(pnd);
+	}
 	spin_unlock_bh(&pndevs->lock);
 	return err;
 }
@@ -181,18 +200,8 @@ static int phonet_device_notify(struct notifier_bl=
ock *me, unsigned long what,
 {
 	struct net_device *dev =3D arg;
=20
-	if (what =3D=3D NETDEV_UNREGISTER) {
-		struct phonet_device_list *pndevs;
-		struct phonet_device *pnd;
-
-		/* Destroy phonet-specific device data */
-		pndevs =3D phonet_device_list(dev_net(dev));
-		spin_lock_bh(&pndevs->lock);
-		pnd =3D __phonet_get(dev);
-		if (pnd)
-			__phonet_device_free(pnd);
-		spin_unlock_bh(&pndevs->lock);
-	}
+	if (what =3D=3D NETDEV_UNREGISTER)
+		phonet_device_destroy(dev);
 	return 0;
=20
 }
@@ -218,11 +227,12 @@ static int phonet_init_net(struct net *net)
 static void phonet_exit_net(struct net *net)
 {
 	struct phonet_net *pnn =3D net_generic(net, phonet_net_id);
-	struct phonet_device *pnd, *n;
-
-	list_for_each_entry_safe(pnd, n, &pnn->pndevs.list, list)
-		__phonet_device_free(pnd);
+	struct net_device *dev;
=20
+	rtnl_lock();
+	for_each_netdev(net, dev)
+		phonet_device_destroy(dev);
+	rtnl_unlock();
 	kfree(pnn);
 }
=20
--=20
1.6.0.4

