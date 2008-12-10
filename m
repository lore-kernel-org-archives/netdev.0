From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH net-next] Phonet: improve GPRS variable names
Date: Wed, 10 Dec 2008 15:15:29 +0200
Message-ID: <1228914929-26337-2-git-send-email-remi.denis-courmont@nokia.com>
References: <200812101514.56827.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:41457 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754945AbYLJNPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 08:15:36 -0500
Received: from vaebh105.NOE.Nokia.com (vaebh105.europe.nokia.com [10.160.244.31])
	by mgw-mx03.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id mBADFO1O017780
	for <netdev@vger.kernel.org>; Wed, 10 Dec 2008 15:15:33 +0200
Received: from localhost.localdomain (esdhcp041160.research.nokia.com [172.21.41.160])
	by mgw-int01.ntc.nokia.com (Switch-3.2.5/Switch-3.2.5) with ESMTP id mBADFTXA010974
	for <netdev@vger.kernel.org>; Wed, 10 Dec 2008 15:15:31 +0200
In-Reply-To: <200812101514.56827.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/pep-gprs.c |  170 +++++++++++++++++++++++++----------------=
--------
 1 files changed, 86 insertions(+), 84 deletions(-)

diff --git a/net/phonet/pep-gprs.c b/net/phonet/pep-gprs.c
index 5985bc5..e60ba59 100644
--- a/net/phonet/pep-gprs.c
+++ b/net/phonet/pep-gprs.c
@@ -40,7 +40,7 @@ struct gprs_dev {
 	void			(*old_data_ready)(struct sock *, int);
 	void			(*old_write_space)(struct sock *);
=20
-	struct net_device	*net;
+	struct net_device	*dev;
=20
 	struct sk_buff_head	tx_queue;
 	struct work_struct	tx_work;
@@ -72,17 +72,19 @@ static __be16 gprs_type_trans(struct sk_buff *skb)
=20
 static void gprs_state_change(struct sock *sk)
 {
-	struct gprs_dev *dev =3D sk->sk_user_data;
+	struct gprs_dev *gp =3D sk->sk_user_data;
=20
 	if (sk->sk_state =3D=3D TCP_CLOSE_WAIT) {
-		netif_stop_queue(dev->net);
-		netif_carrier_off(dev->net);
+		struct net_device *dev =3D gp->dev;
+
+		netif_stop_queue(dev);
+		netif_carrier_off(dev);
 	}
 }
=20
-static int gprs_recv(struct gprs_dev *dev, struct sk_buff *skb)
+static int gprs_recv(struct gprs_dev *gp, struct sk_buff *skb)
 {
-	struct net_device *net =3D dev->net;
+	struct net_device *dev =3D gp->dev;
 	int err =3D 0;
 	__be16 protocol =3D gprs_type_trans(skb);
=20
@@ -99,7 +101,7 @@ static int gprs_recv(struct gprs_dev *dev, struct sk=
_buff *skb)
 		 * so wrap the IP packet as a single fragment of an head-less
 		 * socket buffer. The network stack will pull what it needs,
 		 * but at least, the whole IP payload is not memcpy'd. */
-		rskb =3D netdev_alloc_skb(net, 0);
+		rskb =3D netdev_alloc_skb(dev, 0);
 		if (!rskb) {
 			err =3D -ENOBUFS;
 			goto drop;
@@ -123,11 +125,11 @@ static int gprs_recv(struct gprs_dev *dev, struct=
 sk_buff *skb)
=20
 	skb->protocol =3D protocol;
 	skb_reset_mac_header(skb);
-	skb->dev =3D net;
+	skb->dev =3D dev;
=20
-	if (likely(net->flags & IFF_UP)) {
-		net->stats.rx_packets++;
-		net->stats.rx_bytes +=3D skb->len;
+	if (likely(dev->flags & IFF_UP)) {
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes +=3D skb->len;
 		netif_rx(skb);
 		skb =3D NULL;
 	} else
@@ -136,41 +138,41 @@ static int gprs_recv(struct gprs_dev *dev, struct=
 sk_buff *skb)
 drop:
 	if (skb) {
 		dev_kfree_skb(skb);
-		net->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 	}
 	return err;
 }
=20
 static void gprs_data_ready(struct sock *sk, int len)
 {
-	struct gprs_dev *dev =3D sk->sk_user_data;
+	struct gprs_dev *gp =3D sk->sk_user_data;
 	struct sk_buff *skb;
=20
 	while ((skb =3D pep_read(sk)) !=3D NULL) {
 		skb_orphan(skb);
-		gprs_recv(dev, skb);
+		gprs_recv(gp, skb);
 	}
 }
=20
 static void gprs_write_space(struct sock *sk)
 {
-	struct gprs_dev *dev =3D sk->sk_user_data;
+	struct gprs_dev *gp =3D sk->sk_user_data;
 	unsigned credits =3D pep_writeable(sk);
=20
-	spin_lock_bh(&dev->tx_lock);
-	dev->tx_max =3D credits;
-	if (credits > skb_queue_len(&dev->tx_queue))
-		netif_wake_queue(dev->net);
-	spin_unlock_bh(&dev->tx_lock);
+	spin_lock_bh(&gp->tx_lock);
+	gp->tx_max =3D credits;
+	if (credits > skb_queue_len(&gp->tx_queue))
+		netif_wake_queue(gp->dev);
+	spin_unlock_bh(&gp->tx_lock);
 }
=20
 /*
  * Network device callbacks
  */
=20
-static int gprs_xmit(struct sk_buff *skb, struct net_device *net)
+static int gprs_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct gprs_dev *dev =3D netdev_priv(net);
+	struct gprs_dev *gp =3D netdev_priv(dev);
=20
 	switch (skb->protocol) {
 	case  htons(ETH_P_IP):
@@ -181,17 +183,17 @@ static int gprs_xmit(struct sk_buff *skb, struct =
net_device *net)
 		return 0;
 	}
=20
-	spin_lock(&dev->tx_lock);
-	if (likely(skb_queue_len(&dev->tx_queue) < dev->tx_max)) {
-		skb_queue_tail(&dev->tx_queue, skb);
-		dev_hold(net);
+	spin_lock(&gp->tx_lock);
+	if (likely(skb_queue_len(&gp->tx_queue) < gp->tx_max)) {
+		skb_queue_tail(&gp->tx_queue, skb);
+		dev_hold(dev);
 		skb =3D NULL;
 	}
-	if (skb_queue_len(&dev->tx_queue) >=3D dev->tx_max)
-		netif_stop_queue(net);
-	spin_unlock(&dev->tx_lock);
+	if (skb_queue_len(&gp->tx_queue) >=3D gp->tx_max)
+		netif_stop_queue(dev);
+	spin_unlock(&gp->tx_lock);
=20
-	schedule_work(&dev->tx_work);
+	schedule_work(&gp->tx_work);
 	if (unlikely(skb))
 		dev_kfree_skb(skb);
 	return 0;
@@ -199,16 +201,16 @@ static int gprs_xmit(struct sk_buff *skb, struct =
net_device *net)
=20
 static void gprs_tx(struct work_struct *work)
 {
-	struct gprs_dev *dev =3D container_of(work, struct gprs_dev, tx_work)=
;
-	struct net_device *net =3D dev->net;
-	struct sock *sk =3D dev->sk;
+	struct gprs_dev *gp =3D container_of(work, struct gprs_dev, tx_work);
+	struct net_device *dev =3D gp->dev;
+	struct sock *sk =3D gp->sk;
 	struct sk_buff *skb;
=20
-	while ((skb =3D skb_dequeue(&dev->tx_queue)) !=3D NULL) {
+	while ((skb =3D skb_dequeue(&gp->tx_queue)) !=3D NULL) {
 		int err;
=20
-		net->stats.tx_bytes +=3D skb->len;
-		net->stats.tx_packets++;
+		dev->stats.tx_bytes +=3D skb->len;
+		dev->stats.tx_packets++;
=20
 		skb_orphan(skb);
 		skb_set_owner_w(skb, sk);
@@ -217,12 +219,12 @@ static void gprs_tx(struct work_struct *work)
 		err =3D pep_write(sk, skb);
 		if (err) {
 			LIMIT_NETDEBUG(KERN_WARNING"%s: TX error (%d)\n",
-					net->name, err);
-			net->stats.tx_aborted_errors++;
-			net->stats.tx_errors++;
+					dev->name, err);
+			dev->stats.tx_aborted_errors++;
+			dev->stats.tx_errors++;
 		}
 		release_sock(sk);
-		dev_put(net);
+		dev_put(dev);
 	}
=20
 	lock_sock(sk);
@@ -230,28 +232,28 @@ static void gprs_tx(struct work_struct *work)
 	release_sock(sk);
 }
=20
-static int gprs_set_mtu(struct net_device *net, int new_mtu)
+static int gprs_set_mtu(struct net_device *dev, int new_mtu)
 {
 	if ((new_mtu < 576) || (new_mtu > (PHONET_MAX_MTU - 11)))
 		return -EINVAL;
=20
-	net->mtu =3D new_mtu;
+	dev->mtu =3D new_mtu;
 	return 0;
 }
=20
-static void gprs_setup(struct net_device *net)
+static void gprs_setup(struct net_device *dev)
 {
-	net->features		=3D NETIF_F_FRAGLIST;
-	net->type		=3D ARPHRD_NONE;
-	net->flags		=3D IFF_POINTOPOINT | IFF_NOARP;
-	net->mtu		=3D GPRS_DEFAULT_MTU;
-	net->hard_header_len	=3D 0;
-	net->addr_len		=3D 0;
-	net->tx_queue_len	=3D 10;
-
-	net->destructor		=3D free_netdev;
-	net->hard_start_xmit	=3D gprs_xmit; /* mandatory */
-	net->change_mtu		=3D gprs_set_mtu;
+	dev->features		=3D NETIF_F_FRAGLIST;
+	dev->type		=3D ARPHRD_NONE;
+	dev->flags		=3D IFF_POINTOPOINT | IFF_NOARP;
+	dev->mtu		=3D GPRS_DEFAULT_MTU;
+	dev->hard_header_len	=3D 0;
+	dev->addr_len		=3D 0;
+	dev->tx_queue_len	=3D 10;
+
+	dev->destructor		=3D free_netdev;
+	dev->hard_start_xmit	=3D gprs_xmit; /* mandatory */
+	dev->change_mtu		=3D gprs_set_mtu;
 }
=20
 /*
@@ -265,28 +267,28 @@ static void gprs_setup(struct net_device *net)
 int gprs_attach(struct sock *sk)
 {
 	static const char ifname[] =3D "gprs%d";
-	struct gprs_dev *dev;
-	struct net_device *net;
+	struct gprs_dev *gp;
+	struct net_device *dev;
 	int err;
=20
 	if (unlikely(sk->sk_type =3D=3D SOCK_STREAM))
 		return -EINVAL; /* need packet boundaries */
=20
 	/* Create net device */
-	net =3D alloc_netdev(sizeof(*dev), ifname, gprs_setup);
-	if (!net)
+	dev =3D alloc_netdev(sizeof(*gp), ifname, gprs_setup);
+	if (!dev)
 		return -ENOMEM;
-	dev =3D netdev_priv(net);
-	dev->net =3D net;
-	dev->tx_max =3D 0;
-	spin_lock_init(&dev->tx_lock);
-	skb_queue_head_init(&dev->tx_queue);
-	INIT_WORK(&dev->tx_work, gprs_tx);
-
-	netif_stop_queue(net);
-	err =3D register_netdev(net);
+	gp =3D netdev_priv(dev);
+	gp->dev =3D dev;
+	gp->tx_max =3D 0;
+	spin_lock_init(&gp->tx_lock);
+	skb_queue_head_init(&gp->tx_queue);
+	INIT_WORK(&gp->tx_work, gprs_tx);
+
+	netif_stop_queue(dev);
+	err =3D register_netdev(dev);
 	if (err) {
-		free_netdev(net);
+		free_netdev(dev);
 		return err;
 	}
=20
@@ -300,43 +302,43 @@ int gprs_attach(struct sock *sk)
 		err =3D -EINVAL;
 		goto out_rel;
 	}
-	sk->sk_user_data	=3D dev;
-	dev->old_state_change	=3D sk->sk_state_change;
-	dev->old_data_ready	=3D sk->sk_data_ready;
-	dev->old_write_space	=3D sk->sk_write_space;
+	sk->sk_user_data	=3D gp;
+	gp->old_state_change	=3D sk->sk_state_change;
+	gp->old_data_ready	=3D sk->sk_data_ready;
+	gp->old_write_space	=3D sk->sk_write_space;
 	sk->sk_state_change	=3D gprs_state_change;
 	sk->sk_data_ready	=3D gprs_data_ready;
 	sk->sk_write_space	=3D gprs_write_space;
 	release_sock(sk);
=20
 	sock_hold(sk);
-	dev->sk =3D sk;
+	gp->sk =3D sk;
=20
-	printk(KERN_DEBUG"%s: attached\n", net->name);
+	printk(KERN_DEBUG"%s: attached\n", dev->name);
 	gprs_write_space(sk); /* kick off TX */
-	return net->ifindex;
+	return dev->ifindex;
=20
 out_rel:
 	release_sock(sk);
-	unregister_netdev(net);
+	unregister_netdev(dev);
 	return err;
 }
=20
 void gprs_detach(struct sock *sk)
 {
-	struct gprs_dev *dev =3D sk->sk_user_data;
-	struct net_device *net =3D dev->net;
+	struct gprs_dev *gp =3D sk->sk_user_data;
+	struct net_device *dev =3D gp->dev;
=20
 	lock_sock(sk);
 	sk->sk_user_data	=3D NULL;
-	sk->sk_state_change	=3D dev->old_state_change;
-	sk->sk_data_ready	=3D dev->old_data_ready;
-	sk->sk_write_space	=3D dev->old_write_space;
+	sk->sk_state_change	=3D gp->old_state_change;
+	sk->sk_data_ready	=3D gp->old_data_ready;
+	sk->sk_write_space	=3D gp->old_write_space;
 	release_sock(sk);
=20
-	printk(KERN_DEBUG"%s: detached\n", net->name);
-	unregister_netdev(net);
+	printk(KERN_DEBUG"%s: detached\n", dev->name);
+	unregister_netdev(dev);
 	flush_scheduled_work();
 	sock_put(sk);
-	skb_queue_purge(&dev->tx_queue);
+	skb_queue_purge(&gp->tx_queue);
 }
--=20
1.5.4.3

