From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/4] net: add netdev_lockdep_set_classes() helper
Date: Wed,  8 Jun 2016 16:55:24 -0700
Message-ID: <1465430127-22993-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	David Ahern <dsa@cumulusnetworks.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34351 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932121AbcFHXzc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 19:55:32 -0400
Received: by mail-pa0-f44.google.com with SMTP id bz2so6890972pad.1
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 16:55:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is time to add netdev_lockdep_set_classes() helper
so that lockdep annotations per device type are easier to manage.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/bonding/bond_main.c | 5 +----
 drivers/net/ppp/ppp_generic.c   | 6 +-----
 drivers/net/team/team.c         | 5 +----
 include/linux/netdevice.h       | 9 +++++++++
 net/bluetooth/6lowpan.c         | 5 +----
 net/ieee802154/6lowpan/core.c   | 5 +----
 net/l2tp/l2tp_eth.c             | 6 +-----
 7 files changed, 15 insertions(+), 26 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 681af31a60ed..a729f0f8cb7b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4609,8 +4609,6 @@ static int bond_check_params(struct bond_params *params)
 
 static struct lock_class_key bonding_netdev_xmit_lock_key;
 static struct lock_class_key bonding_netdev_addr_lock_key;
-static struct lock_class_key bonding_tx_busylock_key;
-static struct lock_class_key bonding_qdisc_running_key;
 
 static void bond_set_lockdep_class_one(struct net_device *dev,
 				       struct netdev_queue *txq,
@@ -4625,8 +4623,7 @@ static void bond_set_lockdep_class(struct net_device *dev)
 	lockdep_set_class(&dev->addr_list_lock,
 			  &bonding_netdev_addr_lock_key);
 	netdev_for_each_tx_queue(dev, bond_set_lockdep_class_one, NULL);
-	dev->qdisc_tx_busylock = &bonding_tx_busylock_key;
-	dev->qdisc_running_key = &bonding_qdisc_running_key;
+	netdev_lockdep_set_classes(dev);
 }
 
 /* Called from registration process */
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
index 00eb38956a2c..d01ad0d2658b 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1576,8 +1576,6 @@ static const struct team_option team_options[] = {
 
 static struct lock_class_key team_netdev_xmit_lock_key;
 static struct lock_class_key team_netdev_addr_lock_key;
-static struct lock_class_key team_tx_busylock_key;
-static struct lock_class_key team_qdisc_running_key;
 
 static void team_set_lockdep_class_one(struct net_device *dev,
 				       struct netdev_queue *txq,
@@ -1590,8 +1588,7 @@ static void team_set_lockdep_class(struct net_device *dev)
 {
 	lockdep_set_class(&dev->addr_list_lock, &team_netdev_addr_lock_key);
 	netdev_for_each_tx_queue(dev, team_set_lockdep_class_one, NULL);
-	dev->qdisc_tx_busylock = &team_tx_busylock_key;
-	dev->qdisc_running_key = &team_qdisc_running_key;
+	netdev_lockdep_set_classes(dev);
 }
 
 static int team_init(struct net_device *dev)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 59d7e06d88d5..3d61192159d5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1945,6 +1945,15 @@ static inline void netdev_for_each_tx_queue(struct net_device *dev,
 		f(dev, &dev->_tx[i], arg);
 }
 
+#define netdev_lockdep_set_classes(dev)			\
+{							\
+	static struct lock_class_key tx_busylock_key;	\
+	static struct lock_class_key qdisc_running_key;	\
+							\
+	dev->qdisc_tx_busylock = &tx_busylock_key;	\
+	dev->qdisc_running_key = &qdisc_running_key;	\
+}
+
 struct netdev_queue *netdev_pick_tx(struct net_device *dev,
 				    struct sk_buff *skb,
 				    void *accel_priv);
diff --git a/net/bluetooth/6lowpan.c b/net/bluetooth/6lowpan.c
index 977a11e418d0..0da875a69e47 100644
--- a/net/bluetooth/6lowpan.c
+++ b/net/bluetooth/6lowpan.c
@@ -627,9 +627,7 @@ static netdev_tx_t bt_xmit(struct sk_buff *skb, struct net_device *netdev)
 	return err < 0 ? NET_XMIT_DROP : err;
 }
 
-static struct lock_class_key bt_tx_busylock;
 static struct lock_class_key bt_netdev_xmit_lock_key;
-static struct lock_class_key bt_qdisc_running_key;
 
 static void bt_set_lockdep_class_one(struct net_device *dev,
 				     struct netdev_queue *txq,
@@ -641,8 +639,7 @@ static void bt_set_lockdep_class_one(struct net_device *dev,
 static int bt_dev_init(struct net_device *dev)
 {
 	netdev_for_each_tx_queue(dev, bt_set_lockdep_class_one, NULL);
-	dev->qdisc_tx_busylock = &bt_tx_busylock;
-	dev->qdisc_running_key = &bt_qdisc_running_key;
+	netdev_lockdep_set_classes(dev);
 
 	return 0;
 }
diff --git a/net/ieee802154/6lowpan/core.c b/net/ieee802154/6lowpan/core.c
index 14aa5effd29a..139dbe3f7cc6 100644
--- a/net/ieee802154/6lowpan/core.c
+++ b/net/ieee802154/6lowpan/core.c
@@ -58,9 +58,7 @@ static struct header_ops lowpan_header_ops = {
 	.create	= lowpan_header_create,
 };
 
-static struct lock_class_key lowpan_tx_busylock;
 static struct lock_class_key lowpan_netdev_xmit_lock_key;
-static struct lock_class_key lowpan_qdisc_running_key;
 
 static void lowpan_set_lockdep_class_one(struct net_device *ldev,
 					 struct netdev_queue *txq,
@@ -73,8 +71,7 @@ static void lowpan_set_lockdep_class_one(struct net_device *ldev,
 static int lowpan_dev_init(struct net_device *ldev)
 {
 	netdev_for_each_tx_queue(ldev, lowpan_set_lockdep_class_one, NULL);
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
