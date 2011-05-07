From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: bonding: factor out rlock(bond->lock) in xmit path
Date: Sat,  7 May 2011 13:48:02 +0200 (CEST)
Message-ID: <20110507114802.9CE7513A6A@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:55065 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753756Ab1EGLsF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 May 2011 07:48:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pull read_lock(&bond->lock) and BOND_IS_OK() to bond_start_xmit() from
mode-dependent xmit functions.

netif_running() is always true in hard_start_xmit.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/bonding/bond_3ad.c  |   10 +-----
 drivers/net/bonding/bond_alb.c  |   11 +-----
 drivers/net/bonding/bond_main.c |   74 +++++++++++++++++--------------=
--------
 3 files changed, 35 insertions(+), 60 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_=
3ad.c
index d4160f8..c7537abc 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2403,14 +2403,6 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struc=
t net_device *dev)
 	struct ad_info ad_info;
 	int res =3D 1;
=20
-	/* make sure that the slaves list will
-	 * not change during tx
-	 */
-	read_lock(&bond->lock);
-
-	if (!BOND_IS_OK(bond))
-		goto out;
-
 	if (bond_3ad_get_active_agg_info(bond, &ad_info)) {
 		pr_debug("%s: Error: bond_3ad_get_active_agg_info failed\n",
 			 dev->name);
@@ -2464,7 +2456,7 @@ out:
 		/* no suitable interface, frame not sent */
 		dev_kfree_skb(skb);
 	}
-	read_unlock(&bond->lock);
+
 	return NETDEV_TX_OK;
 }
=20
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_=
alb.c
index 3b7b040..8f2d2e7 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1225,16 +1225,10 @@ int bond_alb_xmit(struct sk_buff *skb, struct n=
et_device *bond_dev)
 	skb_reset_mac_header(skb);
 	eth_data =3D eth_hdr(skb);
=20
-	/* make sure that the curr_active_slave and the slaves list do
-	 * not change during tx
+	/* make sure that the curr_active_slave do not change during tx
 	 */
-	read_lock(&bond->lock);
 	read_lock(&bond->curr_slave_lock);
=20
-	if (!BOND_IS_OK(bond)) {
-		goto out;
-	}
-
 	switch (ntohs(skb->protocol)) {
 	case ETH_P_IP: {
 		const struct iphdr *iph =3D ip_hdr(skb);
@@ -1334,13 +1328,12 @@ int bond_alb_xmit(struct sk_buff *skb, struct n=
et_device *bond_dev)
 		}
 	}
=20
-out:
 	if (res) {
 		/* no suitable interface, frame not sent */
 		dev_kfree_skb(skb);
 	}
 	read_unlock(&bond->curr_slave_lock);
-	read_unlock(&bond->lock);
+
 	return NETDEV_TX_OK;
 }
=20
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 04a2205..1f8902e 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3975,10 +3975,6 @@ static int bond_xmit_roundrobin(struct sk_buff *=
skb, struct net_device *bond_dev
 	int i, slave_no, res =3D 1;
 	struct iphdr *iph =3D ip_hdr(skb);
=20
-	read_lock(&bond->lock);
-
-	if (!BOND_IS_OK(bond))
-		goto out;
 	/*
 	 * Start with the curr_active_slave that joined the bond as the
 	 * default for sending IGMP traffic.  For failover purposes one
@@ -4025,7 +4021,7 @@ out:
 		/* no suitable interface, frame not sent */
 		dev_kfree_skb(skb);
 	}
-	read_unlock(&bond->lock);
+
 	return NETDEV_TX_OK;
 }
=20
@@ -4039,24 +4035,18 @@ static int bond_xmit_activebackup(struct sk_buf=
f *skb, struct net_device *bond_d
 	struct bonding *bond =3D netdev_priv(bond_dev);
 	int res =3D 1;
=20
-	read_lock(&bond->lock);
 	read_lock(&bond->curr_slave_lock);
=20
-	if (!BOND_IS_OK(bond))
-		goto out;
+	if (bond->curr_active_slave)
+		res =3D bond_dev_queue_xmit(bond, skb,
+			bond->curr_active_slave->dev);
=20
-	if (!bond->curr_active_slave)
-		goto out;
-
-	res =3D bond_dev_queue_xmit(bond, skb, bond->curr_active_slave->dev);
-
-out:
 	if (res)
 		/* no suitable interface, frame not sent */
 		dev_kfree_skb(skb);
=20
 	read_unlock(&bond->curr_slave_lock);
-	read_unlock(&bond->lock);
+
 	return NETDEV_TX_OK;
 }
=20
@@ -4073,11 +4063,6 @@ static int bond_xmit_xor(struct sk_buff *skb, st=
ruct net_device *bond_dev)
 	int i;
 	int res =3D 1;
=20
-	read_lock(&bond->lock);
-
-	if (!BOND_IS_OK(bond))
-		goto out;
-
 	slave_no =3D bond->xmit_hash_policy(skb, bond->slave_cnt);
=20
 	bond_for_each_slave(bond, slave, i) {
@@ -4097,12 +4082,11 @@ static int bond_xmit_xor(struct sk_buff *skb, s=
truct net_device *bond_dev)
 		}
 	}
=20
-out:
 	if (res) {
 		/* no suitable interface, frame not sent */
 		dev_kfree_skb(skb);
 	}
-	read_unlock(&bond->lock);
+
 	return NETDEV_TX_OK;
 }
=20
@@ -4117,11 +4101,6 @@ static int bond_xmit_broadcast(struct sk_buff *s=
kb, struct net_device *bond_dev)
 	int i;
 	int res =3D 1;
=20
-	read_lock(&bond->lock);
-
-	if (!BOND_IS_OK(bond))
-		goto out;
-
 	read_lock(&bond->curr_slave_lock);
 	start_at =3D bond->curr_active_slave;
 	read_unlock(&bond->curr_slave_lock);
@@ -4160,7 +4139,6 @@ out:
 		dev_kfree_skb(skb);
=20
 	/* frame sent to all suitable interfaces */
-	read_unlock(&bond->lock);
 	return NETDEV_TX_OK;
 }
=20
@@ -4192,10 +4170,8 @@ static inline int bond_slave_override(struct bon=
ding *bond,
 	struct slave *slave =3D NULL;
 	struct slave *check_slave;
=20
-	read_lock(&bond->lock);
-
-	if (!BOND_IS_OK(bond) || !skb->queue_mapping)
-		goto out;
+	if (!skb->queue_mapping)
+		return 1;
=20
 	/* Find out if any slaves have the same mapping as this skb. */
 	bond_for_each_slave(bond, check_slave, i) {
@@ -4211,8 +4187,6 @@ static inline int bond_slave_override(struct bond=
ing *bond,
 		res =3D bond_dev_queue_xmit(bond, skb, slave->dev);
 	}
=20
-out:
-	read_unlock(&bond->lock);
 	return res;
 }
=20
@@ -4234,17 +4208,10 @@ static u16 bond_select_queue(struct net_device =
*dev, struct sk_buff *skb)
 	return txq;
 }
=20
-static netdev_tx_t bond_start_xmit(struct sk_buff *skb, struct net_dev=
ice *dev)
+static netdev_tx_t __bond_start_xmit(struct sk_buff *skb, struct net_d=
evice *dev)
 {
 	struct bonding *bond =3D netdev_priv(dev);
=20
-	/*
-	 * If we risk deadlock from transmitting this in the
-	 * netpoll path, tell netpoll to queue the frame for later tx
-	 */
-	if (is_netpoll_tx_blocked(dev))
-		return NETDEV_TX_BUSY;
-
 	if (TX_QUEUE_OVERRIDE(bond->params.mode)) {
 		if (!bond_slave_override(bond, skb))
 			return NETDEV_TX_OK;
@@ -4274,6 +4241,29 @@ static netdev_tx_t bond_start_xmit(struct sk_buf=
f *skb, struct net_device *dev)
 	}
 }
=20
+static netdev_tx_t bond_start_xmit(struct sk_buff *skb, struct net_dev=
ice *dev)
+{
+	struct bonding *bond =3D netdev_priv(dev);
+	netdev_tx_t ret =3D NETDEV_TX_OK;
+
+	/*
+	 * If we risk deadlock from transmitting this in the
+	 * netpoll path, tell netpoll to queue the frame for later tx
+	 */
+	if (is_netpoll_tx_blocked(dev))
+		return NETDEV_TX_BUSY;
+
+	read_lock(&bond->lock);
+
+	if (bond->slave_cnt)
+		ret =3D __bond_start_xmit(skb, dev);
+	else
+		dev_kfree_skb(skb);
+
+	read_unlock(&bond->lock);
+
+	return ret;
+}
=20
 /*
  * set bond mode specific net device operations
--=20
1.7.2.5

