From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 4/5] Phonet: get rid of deferred work on the transmission path
Date: Wed, 17 Dec 2008 16:07:53 +0200
Message-ID: <1229522874-20636-4-git-send-email-remi.denis-courmont@nokia.com>
References: <200812171607.14184.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:31023 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751533AbYLQOIN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 09:08:13 -0500
Received: from esebh107.NOE.Nokia.com (esebh107.ntc.nokia.com [172.21.143.143])
	by mgw-mx03.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id mBHE808q021598
	for <netdev@vger.kernel.org>; Wed, 17 Dec 2008 16:08:10 +0200
Received: from localhost.localdomain (esdhcp041160.research.nokia.com [172.21.41.160])
	by mgw-int02.ntc.nokia.com (Switch-3.2.5/Switch-3.2.5) with ESMTP id mBHE7sde016910
	for <netdev@vger.kernel.org>; Wed, 17 Dec 2008 16:07:58 +0200
In-Reply-To: <200812171607.14184.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/pep-gprs.c |   91 +++++++++++++++--------------------------=
--------
 1 files changed, 28 insertions(+), 63 deletions(-)

diff --git a/net/phonet/pep-gprs.c b/net/phonet/pep-gprs.c
index a287320..b0ceac2 100644
--- a/net/phonet/pep-gprs.c
+++ b/net/phonet/pep-gprs.c
@@ -41,11 +41,6 @@ struct gprs_dev {
 	void			(*old_write_space)(struct sock *);
=20
 	struct net_device	*dev;
-
-	struct sk_buff_head	tx_queue;
-	struct work_struct	tx_work;
-	spinlock_t		tx_lock;
-	unsigned		tx_max;
 };
=20
 static __be16 gprs_type_trans(struct sk_buff *skb)
@@ -66,6 +61,14 @@ static __be16 gprs_type_trans(struct sk_buff *skb)
 	return htons(0);
 }
=20
+static void gprs_writeable(struct gprs_dev *gp)
+{
+	struct net_device *dev =3D gp->dev;
+
+	if (pep_writeable(gp->sk))
+		netif_wake_queue(dev);
+}
+
 /*
  * Socket callbacks
  */
@@ -157,14 +160,9 @@ static void gprs_data_ready(struct sock *sk, int l=
en)
 static void gprs_write_space(struct sock *sk)
 {
 	struct gprs_dev *gp =3D sk->sk_user_data;
-	struct net_device *dev =3D gp->dev;
-	unsigned credits =3D pep_writeable(sk);
=20
-	spin_lock_bh(&gp->tx_lock);
-	gp->tx_max =3D credits;
-	if (credits > skb_queue_len(&gp->tx_queue) && netif_running(dev))
-		netif_wake_queue(dev);
-	spin_unlock_bh(&gp->tx_lock);
+	if (netif_running(gp->dev))
+		gprs_writeable(gp);
 }
=20
 /*
@@ -175,22 +173,21 @@ static int gprs_open(struct net_device *dev)
 {
 	struct gprs_dev *gp =3D netdev_priv(dev);
=20
-	gprs_write_space(gp->sk);
+	gprs_writeable(gp);
 	return 0;
 }
=20
 static int gprs_close(struct net_device *dev)
 {
-	struct gprs_dev *gp =3D netdev_priv(dev);
-
 	netif_stop_queue(dev);
-	flush_work(&gp->tx_work);
 	return 0;
 }
=20
 static int gprs_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct gprs_dev *gp =3D netdev_priv(dev);
+	struct sock *sk =3D gp->sk;
+	int len, err;
=20
 	switch (skb->protocol) {
 	case  htons(ETH_P_IP):
@@ -201,51 +198,24 @@ static int gprs_xmit(struct sk_buff *skb, struct =
net_device *dev)
 		return 0;
 	}
=20
-	spin_lock(&gp->tx_lock);
-	if (likely(skb_queue_len(&gp->tx_queue) < gp->tx_max)) {
-		skb_queue_tail(&gp->tx_queue, skb);
-		skb =3D NULL;
-	}
-	if (skb_queue_len(&gp->tx_queue) >=3D gp->tx_max)
-		netif_stop_queue(dev);
-	spin_unlock(&gp->tx_lock);
-
-	schedule_work(&gp->tx_work);
-	if (unlikely(skb))
+	skb_orphan(skb);
+	skb_set_owner_w(skb, sk);
+	len =3D skb->len;
+	err =3D pep_write(sk, skb);
+	if (err) {
+		LIMIT_NETDEBUG(KERN_WARNING"%s: TX error (%d)\n",
+				dev->name, err);
+		dev->stats.tx_aborted_errors++;
+		dev->stats.tx_errors++;
 		dev_kfree_skb(skb);
-	return 0;
-}
-
-static void gprs_tx(struct work_struct *work)
-{
-	struct gprs_dev *gp =3D container_of(work, struct gprs_dev, tx_work);
-	struct net_device *dev =3D gp->dev;
-	struct sock *sk =3D gp->sk;
-	struct sk_buff *skb;
-
-	while ((skb =3D skb_dequeue(&gp->tx_queue)) !=3D NULL) {
-		int err;
-
-		dev->stats.tx_bytes +=3D skb->len;
+	} else {
 		dev->stats.tx_packets++;
-
-		skb_orphan(skb);
-		skb_set_owner_w(skb, sk);
-
-		lock_sock(sk);
-		err =3D pep_write(sk, skb);
-		if (err) {
-			LIMIT_NETDEBUG(KERN_WARNING"%s: TX error (%d)\n",
-					dev->name, err);
-			dev->stats.tx_aborted_errors++;
-			dev->stats.tx_errors++;
-		}
-		release_sock(sk);
+		dev->stats.tx_bytes +=3D len;
 	}
=20
-	lock_sock(sk);
-	gprs_write_space(sk);
-	release_sock(sk);
+	if (!pep_writeable(sk))
+		netif_stop_queue(dev);
+	return 0;
 }
=20
 static int gprs_set_mtu(struct net_device *dev, int new_mtu)
@@ -297,11 +267,8 @@ int gprs_attach(struct sock *sk)
 	if (!dev)
 		return -ENOMEM;
 	gp =3D netdev_priv(dev);
+	gp->sk =3D sk;
 	gp->dev =3D dev;
-	gp->tx_max =3D 0;
-	spin_lock_init(&gp->tx_lock);
-	skb_queue_head_init(&gp->tx_queue);
-	INIT_WORK(&gp->tx_work, gprs_tx);
=20
 	netif_stop_queue(dev);
 	err =3D register_netdev(dev);
@@ -328,9 +295,7 @@ int gprs_attach(struct sock *sk)
 	sk->sk_data_ready	=3D gprs_data_ready;
 	sk->sk_write_space	=3D gprs_write_space;
 	release_sock(sk);
-
 	sock_hold(sk);
-	gp->sk =3D sk;
=20
 	printk(KERN_DEBUG"%s: attached\n", dev->name);
 	return dev->ifindex;
--=20
1.5.4.3

