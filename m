From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 8/8] sch_teql: convert to net_device_ops
Date: Mon, 05 Jan 2009 12:14:50 -0800
Message-ID: <20090105201514.904622653@vyatta.com>
References: <20090105201442.749889072@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:35275 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753157AbZAEUYW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2009 15:24:22 -0500
Content-Disposition: inline; filename=sch_teql.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert this driver to net_device_ops.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/sched/sch_teql.c	2009-01-04 21:54:09.746040057 -0800
+++ b/net/sched/sch_teql.c	2009-01-04 22:12:59.598053054 -0800
@@ -289,9 +289,9 @@ restart:
 
 	do {
 		struct net_device *slave = qdisc_dev(q);
-		struct netdev_queue *slave_txq;
+		struct netdev_queue *slave_txq = netdev_get_tx_queue(slave, 0);
+		const struct net_device_ops *slave_ops = slave->netdev_ops;
 
-		slave_txq = netdev_get_tx_queue(slave, 0);
 		if (slave_txq->qdisc_sleeping != q)
 			continue;
 		if (__netif_subqueue_stopped(slave, subq) ||
@@ -305,7 +305,7 @@ restart:
 			if (__netif_tx_trylock(slave_txq)) {
 				if (!netif_tx_queue_stopped(slave_txq) &&
 				    !netif_tx_queue_frozen(slave_txq) &&
-				    slave->hard_start_xmit(skb, slave) == 0) {
+				    slave_ops->ndo_start_xmit(skb, slave) == 0) {
 					__netif_tx_unlock(slave_txq);
 					master->slaves = NEXT_SLAVE(q);
 					netif_wake_queue(dev);
@@ -420,6 +420,14 @@ static int teql_master_mtu(struct net_de
 	return 0;
 }
 
+static const struct net_device_ops teql_netdev_ops = {
+	.ndo_open	= teql_master_open,
+	.ndo_stop	= teql_master_close,
+	.ndo_start_xmit	= teql_master_xmit,
+	.ndo_get_stats	= teql_master_stats,
+	.ndo_change_mtu	= teql_master_mtu,
+};
+
 static __init void teql_master_setup(struct net_device *dev)
 {
 	struct teql_master *master = netdev_priv(dev);
@@ -436,11 +444,7 @@ static __init void teql_master_setup(str
 	ops->destroy	=	teql_destroy;
 	ops->owner	=	THIS_MODULE;
 
-	dev->open		= teql_master_open;
-	dev->hard_start_xmit	= teql_master_xmit;
-	dev->stop		= teql_master_close;
-	dev->get_stats		= teql_master_stats;
-	dev->change_mtu		= teql_master_mtu;
+	dev->netdev_ops =       &teql_netdev_ops;
 	dev->type		= ARPHRD_VOID;
 	dev->mtu		= 1500;
 	dev->tx_queue_len	= 100;

-- 

