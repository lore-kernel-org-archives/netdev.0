From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v3 net-next 2/5] net: add netdev_lockdep_set_classes() helper
Date: Thu,  9 Jun 2016 07:45:12 -0700
Message-ID: <1465483515-10821-3-git-send-email-edumazet@google.com>
References: <1465483515-10821-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	David Ahern <dsa@cumulusnetworks.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34890 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752356AbcFIOp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 10:45:27 -0400
Received: by mail-pa0-f51.google.com with SMTP id hl6so13483156pac.2
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 07:45:26 -0700 (PDT)
In-Reply-To: <1465483515-10821-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is time to add netdev_lockdep_set_classes() helper
so that lockdep annotations per device type are easier to manage.

This removes a lot of copies and missing annotations.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/bonding/bond_main.c | 24 +-----------------------
 drivers/net/ppp/ppp_generic.c   |  6 +-----
 drivers/net/team/team.c         | 21 +--------------------
 include/linux/netdevice.h       | 17 +++++++++++++++++
 net/bluetooth/6lowpan.c         | 15 +--------------
 net/ieee802154/6lowpan/core.c   | 16 +---------------
 net/l2tp/l2tp_eth.c             |  6 +-----
 7 files changed, 23 insertions(+), 82 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 681af31a60ed..90157e20357e 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4607,28 +4607,6 @@ static int bond_check_params(struct bond_params *params)
 	return 0;
 }
 
-static struct lock_class_key bonding_netdev_xmit_lock_key;
-static struct lock_class_key bonding_netdev_addr_lock_key;
-static struct lock_class_key bonding_tx_busylock_key;
-static struct lock_class_key bonding_qdisc_running_key;
-
-static void bond_set_lockdep_class_one(struct net_device *dev,
-				       struct netdev_queue *txq,
-				       void *_unused)
-{
-	lockdep_set_class(&txq->_xmit_lock,
-			  &bonding_netdev_xmit_lock_key);
-}
-
-static void bond_set_lockdep_class(struct net_device *dev)
-{
-	lockdep_set_class(&dev->addr_list_lock,
-			  &bonding_netdev_addr_lock_key);
-	netdev_for_each_tx_queue(dev, bond_set_lockdep_class_one, NULL);
-	dev->qdisc_tx_busylock = &bonding_tx_busylock_key;
-	dev->qdisc_running_key = &bonding_qdisc_running_key;
-}
-
 /* Called from registration process */
 static int bond_init(struct net_device *bond_dev)
 {
@@ -4641,7 +4619,7 @@ static int bond_init(struct net_device *bond_dev)
 	if (!bond->wq)
 		return -ENOMEM;
 
-	bond_set_lockdep_class(bond_dev);
+	netdev_lockdep_set_classes(bond_dev);
 
 	list_add_tail(&bond->bond_list, &bn->dev_list);
 
diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index aeabaa42317f..17953ab15000 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -1312,13 +1312,9 @@ ppp_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats64)
 	return stats64;
 }
 
-static struct lock_class_key ppp_tx_busylock;
-static struct lock_class_key ppp_qdisc_running_key;
-
 static int ppp_dev_init(struct net_device *dev)
 {
-	dev->qdisc_tx_busylock = &ppp_tx_busylock;
-	dev->qdisc_running_key = &ppp_qdisc_running_key;
+	netdev_lockdep_set_classes(dev);
 	return 0;
 }
 
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 00eb38956a2c..0a1bb8387d96 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1574,25 +1574,6 @@ static const struct team_option team_options[] = {
 	},
 };
 
-static struct lock_class_key team_netdev_xmit_lock_key;
-static struct lock_class_key team_netdev_addr_lock_key;
-static struct lock_class_key team_tx_busylock_key;
-static struct lock_class_key team_qdisc_running_key;
-
-static void team_set_lockdep_class_one(struct net_device *dev,
-				       struct netdev_queue *txq,
-				       void *unused)
-{
-	lockdep_set_class(&txq->_xmit_lock, &team_netdev_xmit_lock_key);
-}
-
-static void team_set_lockdep_class(struct net_device *dev)
-{
-	lockdep_set_class(&dev->addr_list_lock, &team_netdev_addr_lock_key);
-	netdev_for_each_tx_queue(dev, team_set_lockdep_class_one, NULL);
-	dev->qdisc_tx_busylock = &team_tx_busylock_key;
-	dev->qdisc_running_key = &team_qdisc_running_key;
-}
 
 static int team_init(struct net_device *dev)
 {
@@ -1628,7 +1609,7 @@ static int team_init(struct net_device *dev)
 		goto err_options_register;
 	netif_carrier_off(dev);
 
-	team_set_lockdep_class(dev);
+	netdev_lockdep_set_classes(dev);
 
 	return 0;
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 541562333ba5..4f234b102892 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1946,6 +1946,23 @@ static inline void netdev_for_each_tx_queue(struct net_device *dev,
 		f(dev, &dev->_tx[i], arg);
 }
 
+#define netdev_lockdep_set_classes(dev)				\
+{								\
+	static struct lock_class_key qdisc_tx_busylock_key;	\
+	static struct lock_class_key qdisc_running_key;		\
+	static struct lock_class_key qdisc_xmit_lock_key;	\
+	static struct lock_class_key dev_addr_list_lock_key;	\
+	unsigned int i;						\
+								\
+	(dev)->qdisc_tx_busylock = &qdisc_tx_busylock_key;	\
+	(dev)->qdisc_running_key = &qdisc_running_key;		\
+	lockdep_set_class(&(dev)->addr_list_lock,		\
+			  &dev_addr_list_lock_key); 		\
+	for (i = 0; i < (dev)->num_tx_queues; i++)		\
+		lockdep_set_class(&(dev)->_tx[i]._xmit_lock,	\
+				  &qdisc_xmit_lock_key);	\
+}
+
 struct netdev_queue *netdev_pick_tx(struct net_device *dev,
 				    struct sk_buff *skb,
 				    void *accel_priv);
diff --git a/net/bluetooth/6lowpan.c b/net/bluetooth/6lowpan.c
index 977a11e418d0..d020299baba4 100644
--- a/net/bluetooth/6lowpan.c
+++ b/net/bluetooth/6lowpan.c
@@ -627,22 +627,9 @@ static netdev_tx_t bt_xmit(struct sk_buff *skb, struct net_device *netdev)
 	return err < 0 ? NET_XMIT_DROP : err;
 }
 
-static struct lock_class_key bt_tx_busylock;
-static struct lock_class_key bt_netdev_xmit_lock_key;
-static struct lock_class_key bt_qdisc_running_key;
-
-static void bt_set_lockdep_class_one(struct net_device *dev,
-				     struct netdev_queue *txq,
-				     void *_unused)
-{
-	lockdep_set_class(&txq->_xmit_lock, &bt_netdev_xmit_lock_key);
-}
-
 static int bt_dev_init(struct net_device *dev)
 {
-	netdev_for_each_tx_queue(dev, bt_set_lockdep_class_one, NULL);
-	dev->qdisc_tx_busylock = &bt_tx_busylock;
-	dev->qdisc_running_key = &bt_qdisc_running_key;
+	netdev_lockdep_set_classes(dev);
 
 	return 0;
 }
diff --git a/net/ieee802154/6lowpan/core.c b/net/ieee802154/6lowpan/core.c
index 14aa5effd29a..4e2b30894224 100644
--- a/net/ieee802154/6lowpan/core.c
+++ b/net/ieee802154/6lowpan/core.c
@@ -58,23 +58,9 @@ static struct header_ops lowpan_header_ops = {
 	.create	= lowpan_header_create,
 };
 
-static struct lock_class_key lowpan_tx_busylock;
-static struct lock_class_key lowpan_netdev_xmit_lock_key;
-static struct lock_class_key lowpan_qdisc_running_key;
-
-static void lowpan_set_lockdep_class_one(struct net_device *ldev,
-					 struct netdev_queue *txq,
-					 void *_unused)
-{
-	lockdep_set_class(&txq->_xmit_lock,
-			  &lowpan_netdev_xmit_lock_key);
-}
-
 static int lowpan_dev_init(struct net_device *ldev)
 {
-	netdev_for_each_tx_queue(ldev, lowpan_set_lockdep_class_one, NULL);
-	ldev->qdisc_tx_busylock = &lowpan_tx_busylock;
-	ldev->qdisc_running_key = &lowpan_qdisc_running_key;
+	netdev_lockdep_set_classes(ldev);
 
 	return 0;
 }
diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index c00d72d182fa..57fc5a46ce06 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -67,9 +67,6 @@ static inline struct l2tp_eth_net *l2tp_eth_pernet(struct net *net)
 	return net_generic(net, l2tp_eth_net_id);
 }
 
-static struct lock_class_key l2tp_eth_tx_busylock;
-static struct lock_class_key l2tp_qdisc_running_key;
-
 static int l2tp_eth_dev_init(struct net_device *dev)
 {
 	struct l2tp_eth *priv = netdev_priv(dev);
@@ -77,8 +74,7 @@ static int l2tp_eth_dev_init(struct net_device *dev)
 	priv->dev = dev;
 	eth_hw_addr_random(dev);
 	eth_broadcast_addr(dev->broadcast);
-	dev->qdisc_tx_busylock = &l2tp_eth_tx_busylock;
-	dev->qdisc_running_key = &l2tp_qdisc_running_key;
+	netdev_lockdep_set_classes(dev);
 
 	return 0;
 }
-- 
2.8.0.rc3.226.g39d4020
