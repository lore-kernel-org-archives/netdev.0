From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH net-2.6] Phonet: keep TX queue disabled when the device is off
Date: Thu, 11 Dec 2008 16:04:02 +0200
Message-ID: <1229004242-18089-1-git-send-email-remi.denis-courmont@nokia.com>
References: <20081211.003323.193691721.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:37800 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755942AbYLKOFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 09:05:14 -0500
Received: from esebh107.NOE.Nokia.com (esebh107.ntc.nokia.com [172.21.143.143])
	by mgw-mx03.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id mBBE4pHj025179
	for <netdev@vger.kernel.org>; Thu, 11 Dec 2008 16:05:10 +0200
Received: from localhost.localdomain (esdhcp041160.research.nokia.com [172.21.41.160])
	by mgw-int01.ntc.nokia.com (Switch-3.2.5/Switch-3.2.5) with ESMTP id mBBE42Ym017235
	for <netdev@vger.kernel.org>; Thu, 11 Dec 2008 16:04:03 +0200
In-Reply-To: <20081211.003323.193691721.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/pep-gprs.c |   27 ++++++++++++++++++++++-----
 1 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/net/phonet/pep-gprs.c b/net/phonet/pep-gprs.c
index e6e8e44..22848dd 100644
--- a/net/phonet/pep-gprs.c
+++ b/net/phonet/pep-gprs.c
@@ -155,12 +155,13 @@ static void gprs_data_ready(struct sock *sk, int =
len)
 static void gprs_write_space(struct sock *sk)
 {
 	struct gprs_dev *dev =3D sk->sk_user_data;
+	struct net_device *net =3D dev->net;
 	unsigned credits =3D pep_writeable(sk);
=20
 	spin_lock_bh(&dev->tx_lock);
 	dev->tx_max =3D credits;
-	if (credits > skb_queue_len(&dev->tx_queue))
-		netif_wake_queue(dev->net);
+	if (credits > skb_queue_len(&dev->tx_queue) && netif_running(net))
+		netif_wake_queue(net);
 	spin_unlock_bh(&dev->tx_lock);
 }
=20
@@ -168,6 +169,23 @@ static void gprs_write_space(struct sock *sk)
  * Network device callbacks
  */
=20
+static int gprs_open(struct net_device *dev)
+{
+	struct gprs_dev *gp =3D netdev_priv(dev);
+
+	gprs_write_space(gp->sk);
+	return 0;
+}
+
+static int gprs_close(struct net_device *dev)
+{
+	struct gprs_dev *gp =3D netdev_priv(dev);
+
+	netif_stop_queue(dev);
+	flush_work(&gp->tx_work);
+	return 0;
+}
+
 static int gprs_xmit(struct sk_buff *skb, struct net_device *net)
 {
 	struct gprs_dev *dev =3D netdev_priv(net);
@@ -248,6 +266,8 @@ static void gprs_setup(struct net_device *net)
 	net->tx_queue_len	=3D 10;
=20
 	net->destructor		=3D free_netdev;
+	net->open		=3D gprs_open;
+	net->stop		=3D gprs_close;
 	net->hard_start_xmit	=3D gprs_xmit; /* mandatory */
 	net->change_mtu		=3D gprs_set_mtu;
 }
@@ -311,7 +331,6 @@ int gprs_attach(struct sock *sk)
 	dev->sk =3D sk;
=20
 	printk(KERN_DEBUG"%s: attached\n", net->name);
-	gprs_write_space(sk); /* kick off TX */
 	return net->ifindex;
=20
 out_rel:
@@ -334,7 +353,5 @@ void gprs_detach(struct sock *sk)
=20
 	printk(KERN_DEBUG"%s: detached\n", net->name);
 	unregister_netdev(net);
-	flush_scheduled_work();
 	sock_put(sk);
-	skb_queue_purge(&dev->tx_queue);
 }
--=20
1.5.4.3

