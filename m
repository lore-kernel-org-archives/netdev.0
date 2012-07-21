From: Kevin Groeneveld <kgroeneveld@gmail.com>
Subject: [PATCH] net: fix race condition in several drivers when reading stats
Date: Sat, 21 Jul 2012 12:30:50 -0400
Message-ID: <1342888250-28352-1-git-send-email-kgroeneveld@gmail.com>
Cc: Kevin Groeneveld <kgroeneveld@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:39724 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751085Ab2GUQa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2012 12:30:59 -0400
Received: by obbuo13 with SMTP id uo13so6601994obb.19
        for <netdev@vger.kernel.org>; Sat, 21 Jul 2012 09:30:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix race condition in several network drivers when reading stats on 32bit
UP architectures.  These drivers update their stats in a BH context and
therefore should use u64_stats_fetch_begin_bh/u64_stats_fetch_retry_bh
instead of u64_stats_fetch_begin/u64_stats_fetch_retry when reading the
stats.

Signed-off-by: Kevin Groeneveld <kgroeneveld@gmail.com>
---
 drivers/net/dummy.c                            |    4 ++--
 drivers/net/ethernet/neterion/vxge/vxge-main.c |    8 ++++----
 drivers/net/loopback.c                         |    4 ++--
 drivers/net/virtio_net.c                       |    8 ++++----
 net/bridge/br_device.c                         |    4 ++--
 5 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 9d6a067..c260af5 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -63,10 +63,10 @@ static struct rtnl_link_stats64 *dummy_get_stats64(struct net_device *dev,
 
 		dstats = per_cpu_ptr(dev->dstats, i);
 		do {
-			start = u64_stats_fetch_begin(&dstats->syncp);
+			start = u64_stats_fetch_begin_bh(&dstats->syncp);
 			tbytes = dstats->tx_bytes;
 			tpackets = dstats->tx_packets;
-		} while (u64_stats_fetch_retry(&dstats->syncp, start));
+		} while (u64_stats_fetch_retry_bh(&dstats->syncp, start));
 		stats->tx_bytes += tbytes;
 		stats->tx_packets += tpackets;
 	}
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index 4e20c5f..de21904 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -3131,12 +3131,12 @@ vxge_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *net_stats)
 		u64 packets, bytes, multicast;
 
 		do {
-			start = u64_stats_fetch_begin(&rxstats->syncp);
+			start = u64_stats_fetch_begin_bh(&rxstats->syncp);
 
 			packets   = rxstats->rx_frms;
 			multicast = rxstats->rx_mcast;
 			bytes     = rxstats->rx_bytes;
-		} while (u64_stats_fetch_retry(&rxstats->syncp, start));
+		} while (u64_stats_fetch_retry_bh(&rxstats->syncp, start));
 
 		net_stats->rx_packets += packets;
 		net_stats->rx_bytes += bytes;
@@ -3146,11 +3146,11 @@ vxge_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *net_stats)
 		net_stats->rx_dropped += rxstats->rx_dropped;
 
 		do {
-			start = u64_stats_fetch_begin(&txstats->syncp);
+			start = u64_stats_fetch_begin_bh(&txstats->syncp);
 
 			packets = txstats->tx_frms;
 			bytes   = txstats->tx_bytes;
-		} while (u64_stats_fetch_retry(&txstats->syncp, start));
+		} while (u64_stats_fetch_retry_bh(&txstats->syncp, start));
 
 		net_stats->tx_packets += packets;
 		net_stats->tx_bytes += bytes;
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 32eb94e..e2a06fd 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -107,10 +107,10 @@ static struct rtnl_link_stats64 *loopback_get_stats64(struct net_device *dev,
 
 		lb_stats = per_cpu_ptr(dev->lstats, i);
 		do {
-			start = u64_stats_fetch_begin(&lb_stats->syncp);
+			start = u64_stats_fetch_begin_bh(&lb_stats->syncp);
 			tbytes = lb_stats->bytes;
 			tpackets = lb_stats->packets;
-		} while (u64_stats_fetch_retry(&lb_stats->syncp, start));
+		} while (u64_stats_fetch_retry_bh(&lb_stats->syncp, start));
 		bytes   += tbytes;
 		packets += tpackets;
 	}
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 1db445b..83d2b0c 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -704,16 +704,16 @@ static struct rtnl_link_stats64 *virtnet_stats(struct net_device *dev,
 		u64 tpackets, tbytes, rpackets, rbytes;
 
 		do {
-			start = u64_stats_fetch_begin(&stats->tx_syncp);
+			start = u64_stats_fetch_begin_bh(&stats->tx_syncp);
 			tpackets = stats->tx_packets;
 			tbytes   = stats->tx_bytes;
-		} while (u64_stats_fetch_retry(&stats->tx_syncp, start));
+		} while (u64_stats_fetch_retry_bh(&stats->tx_syncp, start));
 
 		do {
-			start = u64_stats_fetch_begin(&stats->rx_syncp);
+			start = u64_stats_fetch_begin_bh(&stats->rx_syncp);
 			rpackets = stats->rx_packets;
 			rbytes   = stats->rx_bytes;
-		} while (u64_stats_fetch_retry(&stats->rx_syncp, start));
+		} while (u64_stats_fetch_retry_bh(&stats->rx_syncp, start));
 
 		tot->rx_packets += rpackets;
 		tot->tx_packets += tpackets;
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index f4be1bb..3334845 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -127,9 +127,9 @@ static struct rtnl_link_stats64 *br_get_stats64(struct net_device *dev,
 		const struct br_cpu_netstats *bstats
 			= per_cpu_ptr(br->stats, cpu);
 		do {
-			start = u64_stats_fetch_begin(&bstats->syncp);
+			start = u64_stats_fetch_begin_bh(&bstats->syncp);
 			memcpy(&tmp, bstats, sizeof(tmp));
-		} while (u64_stats_fetch_retry(&bstats->syncp, start));
+		} while (u64_stats_fetch_retry_bh(&bstats->syncp, start));
 		sum.tx_bytes   += tmp.tx_bytes;
 		sum.tx_packets += tmp.tx_packets;
 		sum.rx_bytes   += tmp.rx_bytes;
-- 
1.7.9.5
