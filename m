From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] bonding: fix bond_get_stats()
Date: Thu, 17 Mar 2016 17:23:36 -0700
Message-ID: <1458260616.31963.14.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33346 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967191AbcCRAXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 20:23:39 -0400
Received: by mail-pf0-f178.google.com with SMTP id 4so11219805pfd.0
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 17:23:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

bond_get_stats() can be called from rtnetlink (with RTNL held)
or from /proc/net/dev seq handler (with RCU held)

The logic added in commit 5f0c5f73e5ef ("bonding: make global bonding
stats more reliable") kind of assumed only one cpu could run there.

If multiple threads are reading /proc/net/dev, stats can be really
messed up after a while.

A second problem is that some fields are 32bit, so we need to properly
handle the wrap around problem.

Given that RTNL is not always held, we need to use
bond_for_each_slave_rcu().

Fixes: 5f0c5f73e5ef ("bonding: make global bonding stats more reliable")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>
Cc: Jay Vosburgh <j.vosburgh@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>
---
 drivers/net/bonding/bond_main.c |   66 +++++++++++++++---------------
 include/net/bonding.h           |    1 
 2 files changed, 36 insertions(+), 31 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b6236ff3dbdd..9524253fcabc 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3301,6 +3301,30 @@ static int bond_close(struct net_device *bond_dev)
 	return 0;
 }
 
+/* fold stats, assuming all rtnl_link_stats64 fields are u64, but
+ * that some drivers can provide 32bit values only.
+ */
+static void bond_fold_stats(struct rtnl_link_stats64 *_res,
+			    const struct rtnl_link_stats64 *_new,
+			    const struct rtnl_link_stats64 *_old)
+{
+	const u64 *new = (const u64 *)_new;
+	const u64 *old = (const u64 *)_old;
+	u64 *res = (u64 *)_res;
+	int i;
+
+	for (i = 0; i < sizeof(*_res) / sizeof(u64); i++) {
+		u64 nv = new[i];
+		u64 ov = old[i];
+
+		/* detects if this particular field is 32bit only */
+		if (((nv | ov) >> 32) == 0)
+			res[i] += (u32)nv - (u32)ov;
+		else
+			res[i] += nv - ov;
+	}
+}
+
 static struct rtnl_link_stats64 *bond_get_stats(struct net_device *bond_dev,
 						struct rtnl_link_stats64 *stats)
 {
@@ -3309,44 +3333,23 @@ static struct rtnl_link_stats64 *bond_get_stats(struct net_device *bond_dev,
 	struct list_head *iter;
 	struct slave *slave;
 
+	spin_lock(&bond->stats_lock);
 	memcpy(stats, &bond->bond_stats, sizeof(*stats));
 
-	bond_for_each_slave(bond, slave, iter) {
-		const struct rtnl_link_stats64 *sstats =
+	rcu_read_lock();
+	bond_for_each_slave_rcu(bond, slave, iter) {
+		const struct rtnl_link_stats64 *new =
 			dev_get_stats(slave->dev, &temp);
-		struct rtnl_link_stats64 *pstats = &slave->slave_stats;
-
-		stats->rx_packets +=  sstats->rx_packets - pstats->rx_packets;
-		stats->rx_bytes += sstats->rx_bytes - pstats->rx_bytes;
-		stats->rx_errors += sstats->rx_errors - pstats->rx_errors;
-		stats->rx_dropped += sstats->rx_dropped - pstats->rx_dropped;
-		stats->rx_nohandler += sstats->rx_nohandler - pstats->rx_nohandler;
-
-		stats->tx_packets += sstats->tx_packets - pstats->tx_packets;;
-		stats->tx_bytes += sstats->tx_bytes - pstats->tx_bytes;
-		stats->tx_errors += sstats->tx_errors - pstats->tx_errors;
-		stats->tx_dropped += sstats->tx_dropped - pstats->tx_dropped;
-
-		stats->multicast += sstats->multicast - pstats->multicast;
-		stats->collisions += sstats->collisions - pstats->collisions;
-
-		stats->rx_length_errors += sstats->rx_length_errors - pstats->rx_length_errors;
-		stats->rx_over_errors += sstats->rx_over_errors - pstats->rx_over_errors;
-		stats->rx_crc_errors += sstats->rx_crc_errors - pstats->rx_crc_errors;
-		stats->rx_frame_errors += sstats->rx_frame_errors - pstats->rx_frame_errors;
-		stats->rx_fifo_errors += sstats->rx_fifo_errors - pstats->rx_fifo_errors;
-		stats->rx_missed_errors += sstats->rx_missed_errors - pstats->rx_missed_errors;
-
-		stats->tx_aborted_errors += sstats->tx_aborted_errors - pstats->tx_aborted_errors;
-		stats->tx_carrier_errors += sstats->tx_carrier_errors - pstats->tx_carrier_errors;
-		stats->tx_fifo_errors += sstats->tx_fifo_errors - pstats->tx_fifo_errors;
-		stats->tx_heartbeat_errors += sstats->tx_heartbeat_errors - pstats->tx_heartbeat_errors;
-		stats->tx_window_errors += sstats->tx_window_errors - pstats->tx_window_errors;
+
+		bond_fold_stats(stats, new, &slave->slave_stats);
 
 		/* save off the slave stats for the next run */
-		memcpy(pstats, sstats, sizeof(*sstats));
+		memcpy(&slave->slave_stats, new, sizeof(*new));
 	}
+	rcu_read_unlock();
+
 	memcpy(&bond->bond_stats, stats, sizeof(*stats));
+	spin_unlock(&bond->stats_lock);
 
 	return stats;
 }
@@ -4160,6 +4163,7 @@ void bond_setup(struct net_device *bond_dev)
 	struct bonding *bond = netdev_priv(bond_dev);
 
 	spin_lock_init(&bond->mode_lock);
+	spin_lock_init(&bond->stats_lock);
 	bond->params = bonding_defaults;
 
 	/* Initialize pointers */
diff --git a/include/net/bonding.h b/include/net/bonding.h
index ee6c52053aa3..791800ddd6d9 100644
--- a/include/net/bonding.h
+++ b/include/net/bonding.h
@@ -215,6 +215,7 @@ struct bonding {
 	 * ALB mode (6) - to sync the use and modifications of its hash table
 	 */
 	spinlock_t mode_lock;
+	spinlock_t stats_lock;
 	u8	 send_peer_notif;
 	u8       igmp_retrans;
 #ifdef CONFIG_PROC_FS
