From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] myricom: remove stats_lock
Date: Mon, 20 Jun 2011 08:07:46 +0200
Message-ID: <1308550066.3539.129.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Andrew Gallatin <gallatin@myri.com>,
	Brice Goglin <brice@myri.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60277 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751447Ab1FTGH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 02:07:56 -0400
Received: by wwe5 with SMTP id 5so2192440wwe.1
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 23:07:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

stats_lock is non useless, lets remove it.

Also, ndo_get_stats64() doesnt have to clear the stats, caller takes
care of this.

Note: folding 32bit fields in 64bit one is problematic when one of 32bit
values wraps : SNMP reader will see a ~2^32 back change in a 64bit
value. A future patch should fix this.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Stephen Hemminger <shemminger@vyatta.com>
CC: Andrew Gallatin <gallatin@myri.com>
CC: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |   10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 04e10f4..3e89a84 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -210,7 +210,6 @@ struct myri10ge_priv {
 	int big_bytes;
 	int max_intr_slots;
 	struct net_device *dev;
-	spinlock_t stats_lock;
 	u8 __iomem *sram;
 	int sram_size;
 	unsigned long board_span;
@@ -1837,6 +1836,7 @@ myri10ge_get_ethtool_stats(struct net_device *netdev,
 	int i;
 
 	/* force stats update */
+	memset(&link_stats, 0, sizeof(link_stats));
 	(void)myri10ge_get_stats(netdev, &link_stats);
 	for (i = 0; i < MYRI10GE_NET_STATS_LEN; i++)
 		data[i] = ((u64 *)&link_stats)[i];
@@ -2981,12 +2981,10 @@ drop:
 static struct rtnl_link_stats64 *myri10ge_get_stats(struct net_device *dev,
 						    struct rtnl_link_stats64 *stats)
 {
-	struct myri10ge_priv *mgp = netdev_priv(dev);
-	struct myri10ge_slice_netstats *slice_stats;
+	const struct myri10ge_priv *mgp = netdev_priv(dev);
+	const struct myri10ge_slice_netstats *slice_stats;
 	int i;
 
-	spin_lock(&mgp->stats_lock);
-	memset(stats, 0, sizeof(*stats));
 	for (i = 0; i < mgp->num_slices; i++) {
 		slice_stats = &mgp->ss[i].stats;
 		stats->rx_packets += slice_stats->rx_packets;
@@ -2996,7 +2994,6 @@ static struct rtnl_link_stats64 *myri10ge_get_stats(struct net_device *dev,
 		stats->rx_dropped += slice_stats->rx_dropped;
 		stats->tx_dropped += slice_stats->tx_dropped;
 	}
-	spin_unlock(&mgp->stats_lock);
 	return stats;
 }
 
@@ -3966,7 +3963,6 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	setup_timer(&mgp->watchdog_timer, myri10ge_watchdog_timer,
 		    (unsigned long)mgp);
 
-	spin_lock_init(&mgp->stats_lock);
 	SET_ETHTOOL_OPS(netdev, &myri10ge_ethtool_ops);
 	INIT_WORK(&mgp->watchdog_work, myri10ge_watchdog);
 	status = register_netdev(netdev);


