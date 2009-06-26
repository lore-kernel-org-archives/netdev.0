From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH 1/1] veth: don't free priv->status until dev->destructor
	(v2)
Date: Fri, 26 Jun 2009 11:24:18 -0500
Message-ID: <20090626162418.GA24828@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Containers <containers@lists.osdl.org>,
	Sachin Sant <sachinp@in.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, matthltc@us.ibm.com,
	lkml <linux-kernel@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758946AbZFZQd6@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Based on the commit msg on ae0e8e82205c903978a79ebf5e31c670b61fa5b4, it looks
like oopses were caused when people were reading the veth dev stats while the
module was being unloaded, causing a deref of freed memory in veth_get_stats()?
If so, I believe the following patch (still against mainline, so not on top of
my previous patch or on top of a git-revert of
ae0e8e82205c903978a79ebf5e31c670b61fa5b)) should prevent that.  All the stats
are gathered within one rcu cycle, while the device free hook first sets the
device stats struct to NULL, waits an rcu cycle before freeing it.

I haven't been able to reproduce the original oops though (been trying
to cat the stats sysfs files while rmmoding veth, to no avail, and haven't
found an original bug report or testcase), so can't verify whether this patch
prevents the original oops.

Does this look sufficient?

thanks,
-serge

>From a8eb0950b47ff6c5dfe2debafbd203dcced75bd3 Mon Sep 17 00:00:00 2001
From: root <root@elm3b203.beaverton.ibm.com>
Date: Wed, 24 Jun 2009 20:26:17 -0700
Subject: [PATCH 1/1] veth: don't free priv->status until dev->destructor (v2)

Since commit ae0e8e82205c903978a79ebf5e31c670b61fa5b4, priv->status
has been freed at veth_close().  But that causes a NULL deref at
veth_xmit.  This patch moves priv->status free back to the device
destructor.  It also tries to prevent the original possible
sysfs-induced oops.  All the stats are now gathered within one rcu
cycle, while the device free hook first sets the device stats struct to
NULL, waits an rcu cycle before freeing
it.

Changelog:
	June 26: try to fix the original oops.

Signed-off-by: Serge Hallyn <serue@us.ibm.com>
---
 drivers/net/veth.c |   22 ++++++++++++++++++----
 1 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 87197dd..112add0 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -208,7 +208,7 @@ rx_drop:
 
 static struct net_device_stats *veth_get_stats(struct net_device *dev)
 {
-	struct veth_priv *priv = netdev_priv(dev);
+	struct veth_priv *priv;
 	struct net_device_stats *dev_stats = &dev->stats;
 	unsigned int cpu;
 	struct veth_net_stats *stats;
@@ -220,6 +220,8 @@ static struct net_device_stats *veth_get_stats(struct net_device *dev)
 	dev_stats->tx_dropped = 0;
 	dev_stats->rx_dropped = 0;
 
+	rcu_read_lock();
+	priv = netdev_priv(dev);
 	if (priv->stats)
 		for_each_online_cpu(cpu) {
 			stats = per_cpu_ptr(priv->stats, cpu);
@@ -231,6 +233,7 @@ static struct net_device_stats *veth_get_stats(struct net_device *dev)
 			dev_stats->tx_dropped += stats->tx_dropped;
 			dev_stats->rx_dropped += stats->rx_dropped;
 		}
+	rcu_read_unlock();
 
 	return dev_stats;
 }
@@ -257,8 +260,6 @@ static int veth_close(struct net_device *dev)
 	netif_carrier_off(dev);
 	netif_carrier_off(priv->peer);
 
-	free_percpu(priv->stats);
-	priv->stats = NULL;
 	return 0;
 }
 
@@ -299,6 +300,19 @@ static const struct net_device_ops veth_netdev_ops = {
 	.ndo_set_mac_address = eth_mac_addr,
 };
 
+static void veth_dev_free(struct net_device *dev)
+{
+	struct veth_priv *priv;
+	struct veth_net_stats *stats;
+
+	priv = netdev_priv(dev);
+	stats = priv->stats;
+	priv->stats = NULL;
+	synchronize_rcu();
+	free_percpu(stats);
+	free_netdev(dev);
+}
+
 static void veth_setup(struct net_device *dev)
 {
 	ether_setup(dev);
@@ -306,7 +320,7 @@ static void veth_setup(struct net_device *dev)
 	dev->netdev_ops = &veth_netdev_ops;
 	dev->ethtool_ops = &veth_ethtool_ops;
 	dev->features |= NETIF_F_LLTX;
-	dev->destructor = free_netdev;
+	dev->destructor = veth_dev_free;
 }
 
 /*
-- 
1.6.2.3
