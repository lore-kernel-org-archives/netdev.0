From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH] Phonet: use net_device built-in stats for GPRS
Date: Fri,  7 Nov 2008 15:47:05 +0200
Message-ID: <1226065625-26660-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:31520 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751543AbYKGNrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 08:47:40 -0500
Received: from esebh107.NOE.Nokia.com (esebh107.ntc.nokia.com [172.21.143.143])
	by mgw-mx09.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id mA7DlBmj011286
	for <netdev@vger.kernel.org>; Fri, 7 Nov 2008 07:47:38 -0600
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/pep-gprs.c |   33 +++++++++++++--------------------
 1 files changed, 13 insertions(+), 20 deletions(-)

diff --git a/net/phonet/pep-gprs.c b/net/phonet/pep-gprs.c
index a432407..e6e8e44 100644
--- a/net/phonet/pep-gprs.c
+++ b/net/phonet/pep-gprs.c
@@ -41,7 +41,6 @@ struct gprs_dev {
 	void			(*old_write_space)(struct sock *);
=20
 	struct net_device	*net;
-	struct net_device_stats	stats;
=20
 	struct sk_buff_head	tx_queue;
 	struct work_struct	tx_work;
@@ -83,6 +82,7 @@ static void gprs_state_change(struct sock *sk)
=20
 static int gprs_recv(struct gprs_dev *dev, struct sk_buff *skb)
 {
+	struct net_device *net =3D dev->net;
 	int err =3D 0;
 	__be16 protocol =3D gprs_type_trans(skb);
=20
@@ -99,7 +99,7 @@ static int gprs_recv(struct gprs_dev *dev, struct sk_=
buff *skb)
 		 * so wrap the IP packet as a single fragment of an head-less
 		 * socket buffer. The network stack will pull what it needs,
 		 * but at least, the whole IP payload is not memcpy'd. */
-		rskb =3D netdev_alloc_skb(dev->net, 0);
+		rskb =3D netdev_alloc_skb(net, 0);
 		if (!rskb) {
 			err =3D -ENOBUFS;
 			goto drop;
@@ -123,11 +123,11 @@ static int gprs_recv(struct gprs_dev *dev, struct=
 sk_buff *skb)
=20
 	skb->protocol =3D protocol;
 	skb_reset_mac_header(skb);
-	skb->dev =3D dev->net;
+	skb->dev =3D net;
=20
-	if (likely(dev->net->flags & IFF_UP)) {
-		dev->stats.rx_packets++;
-		dev->stats.rx_bytes +=3D skb->len;
+	if (likely(net->flags & IFF_UP)) {
+		net->stats.rx_packets++;
+		net->stats.rx_bytes +=3D skb->len;
 		netif_rx(skb);
 		skb =3D NULL;
 	} else
@@ -136,7 +136,7 @@ static int gprs_recv(struct gprs_dev *dev, struct s=
k_buff *skb)
 drop:
 	if (skb) {
 		dev_kfree_skb(skb);
-		dev->stats.rx_dropped++;
+		net->stats.rx_dropped++;
 	}
 	return err;
 }
@@ -199,14 +199,15 @@ static int gprs_xmit(struct sk_buff *skb, struct =
net_device *net)
 static void gprs_tx(struct work_struct *work)
 {
 	struct gprs_dev *dev =3D container_of(work, struct gprs_dev, tx_work)=
;
+	struct net_device *net =3D dev->net;
 	struct sock *sk =3D dev->sk;
 	struct sk_buff *skb;
=20
 	while ((skb =3D skb_dequeue(&dev->tx_queue)) !=3D NULL) {
 		int err;
=20
-		dev->stats.tx_bytes +=3D skb->len;
-		dev->stats.tx_packets++;
+		net->stats.tx_bytes +=3D skb->len;
+		net->stats.tx_packets++;
=20
 		skb_orphan(skb);
 		skb_set_owner_w(skb, sk);
@@ -215,9 +216,9 @@ static void gprs_tx(struct work_struct *work)
 		err =3D pep_write(sk, skb);
 		if (err) {
 			LIMIT_NETDEBUG(KERN_WARNING"%s: TX error (%d)\n",
-					dev->net->name, err);
-			dev->stats.tx_aborted_errors++;
-			dev->stats.tx_errors++;
+					net->name, err);
+			net->stats.tx_aborted_errors++;
+			net->stats.tx_errors++;
 		}
 		release_sock(sk);
 	}
@@ -236,13 +237,6 @@ static int gprs_set_mtu(struct net_device *net, in=
t new_mtu)
 	return 0;
 }
=20
-static struct net_device_stats *gprs_get_stats(struct net_device *net)
-{
-	struct gprs_dev *dev =3D netdev_priv(net);
-
-	return &dev->stats;
-}
-
 static void gprs_setup(struct net_device *net)
 {
 	net->features		=3D NETIF_F_FRAGLIST;
@@ -256,7 +250,6 @@ static void gprs_setup(struct net_device *net)
 	net->destructor		=3D free_netdev;
 	net->hard_start_xmit	=3D gprs_xmit; /* mandatory */
 	net->change_mtu		=3D gprs_set_mtu;
-	net->get_stats		=3D gprs_get_stats;
 }
=20
 /*
--=20
1.5.4.3

