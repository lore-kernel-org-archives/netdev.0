From: Brice Goglin <brice@myri.com>
Subject: [PATCH net-next] myri10ge: force stats update in ethtool gstats
Date: Thu, 16 Apr 2009 14:23:56 +0200
Message-ID: <49E7235C.4080601@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1976 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751141AbZDPMXx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2009 08:23:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Force a statistics update when our ethtool gstats routine
is called.  Otherwise, ethtool will continue to read stale
stats until something forces an update by reading /proc/net/dev

This requires putting a lock around the stats update to guard
against 2 threads (one via ethtool, and one via procfs)
updating the stats at once.

Signed-off-by: Brice Goglin <brice@myri.com>

--- linux-tmp.20090327.1716.42/drivers/net/myri10ge/myri10ge.c	2009-03-24 10:50:10.000000000 +0100
+++ linux-tmp/drivers/net/myri10ge/myri10ge.c	2009-03-27 17:16:43.000000000 +0100
@@ -361,6 +361,8 @@ static inline void put_be32(__be32 val, 
 	__raw_writel((__force __u32) val, (__force void __iomem *)p);
 }
 
+static struct net_device_stats *myri10ge_get_stats(struct net_device *dev);
+
 static int
 myri10ge_send_cmd(struct myri10ge_priv *mgp, u32 cmd,
 		  struct myri10ge_cmd *data, int atomic)
@@ -1803,6 +1805,8 @@ myri10ge_get_ethtool_stats(struct net_de
 	int slice;
 	int i;
 
+	/* force stats update */
+	(void)myri10ge_get_stats(netdev);
 	for (i = 0; i < MYRI10GE_NET_STATS_LEN; i++)
 		data[i] = ((unsigned long *)&mgp->stats)[i];
 
@@ -2968,6 +2972,7 @@ static struct net_device_stats *myri10ge
 	struct net_device_stats *stats = &mgp->stats;
 	int i;
 
+	spin_lock(&mgp->stats_lock);
 	memset(stats, 0, sizeof(*stats));
 	for (i = 0; i < mgp->num_slices; i++) {
 		slice_stats = &mgp->ss[i].stats;
@@ -2978,6 +2983,7 @@ static struct net_device_stats *myri10ge
 		stats->rx_dropped += slice_stats->rx_dropped;
 		stats->tx_dropped += slice_stats->tx_dropped;
 	}
+	spin_unlock(&mgp->stats_lock);
 	return stats;
 }
 
@@ -3901,6 +3907,7 @@ static int myri10ge_probe(struct pci_dev
 	setup_timer(&mgp->watchdog_timer, myri10ge_watchdog_timer,
 		    (unsigned long)mgp);
 
+	spin_lock_init(&mgp->stats_lock);
 	SET_ETHTOOL_OPS(netdev, &myri10ge_ethtool_ops);
 	INIT_WORK(&mgp->watchdog_work, myri10ge_watchdog);
 	status = register_netdev(netdev);


