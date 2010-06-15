From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] bridge: 64bit rx/tx counters
Date: Tue, 15 Jun 2010 12:39:36 +0200
Message-ID: <1276598376.2541.93.camel@edumazet-laptop>
References: <1276531162.2478.121.camel@edumazet-laptop>
	 <20100614.231412.39191304.davem@davemloft.net>
	 <1276596856.2541.84.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	Nick Piggin <npiggin@suse.de>
To: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:60486 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757337Ab0FOKjo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 06:39:44 -0400
Received: by wwb18 with SMTP id 18so4629524wwb.19
        for <netdev@vger.kernel.org>; Tue, 15 Jun 2010 03:39:42 -0700 (PDT)
In-Reply-To: <1276596856.2541.84.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Note : should be applied after "net: Introduce 
u64_stats_sync infrastructure", if accepted.


Thanks

[PATCH net-next-2.6] bridge: 64bit rx/tx counters

Use u64_stats_sync infrastructure to provide 64bit rx/tx 
counters even on 32bit hosts.

It is safe to use a single u64_stats_sync for rx and tx,
because BH is disabled on both, and we use per_cpu data.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/bridge/br_device.c  |   24 +++++++++++++++---------
 net/bridge/br_input.c   |    2 ++
 net/bridge/br_private.h |    9 +++++----
 3 files changed, 22 insertions(+), 13 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index b898364..d7bfe31 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -38,8 +38,10 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 #endif
 
+	u64_stats_update_begin(&brstats->syncp);
 	brstats->tx_packets++;
 	brstats->tx_bytes += skb->len;
+	u64_stats_update_end(&brstats->syncp);
 
 	BR_INPUT_SKB_CB(skb)->brdev = dev;
 
@@ -92,21 +94,25 @@ static int br_dev_stop(struct net_device *dev)
 	return 0;
 }
 
-static struct net_device_stats *br_get_stats(struct net_device *dev)
+static struct rtnl_link_stats64 *br_get_stats64(struct net_device *dev)
 {
 	struct net_bridge *br = netdev_priv(dev);
-	struct net_device_stats *stats = &dev->stats;
-	struct br_cpu_netstats sum = { 0 };
+	struct rtnl_link_stats64 *stats = &dev->stats64;
+	struct br_cpu_netstats tmp, sum = { 0 };
 	unsigned int cpu;
 
 	for_each_possible_cpu(cpu) {
+		unsigned int start;
 		const struct br_cpu_netstats *bstats
 			= per_cpu_ptr(br->stats, cpu);
-
-		sum.tx_bytes   += bstats->tx_bytes;
-		sum.tx_packets += bstats->tx_packets;
-		sum.rx_bytes   += bstats->rx_bytes;
-		sum.rx_packets += bstats->rx_packets;
+		do {
+			start = u64_stats_fetch_begin(&bstats->syncp);
+			memcpy(&tmp, bstats, sizeof(tmp));
+		} while (u64_stats_fetch_retry(&bstats->syncp, start));
+		sum.tx_bytes   += tmp.tx_bytes;
+		sum.tx_packets += tmp.tx_packets;
+		sum.rx_bytes   += tmp.rx_bytes;
+		sum.rx_packets += tmp.rx_packets;
 	}
 
 	stats->tx_bytes   = sum.tx_bytes;
@@ -288,7 +294,7 @@ static const struct net_device_ops br_netdev_ops = {
 	.ndo_open		 = br_dev_open,
 	.ndo_stop		 = br_dev_stop,
 	.ndo_start_xmit		 = br_dev_xmit,
-	.ndo_get_stats		 = br_get_stats,
+	.ndo_get_stats64	 = br_get_stats64,
 	.ndo_set_mac_address	 = br_set_mac_address,
 	.ndo_set_multicast_list	 = br_dev_set_multicast_list,
 	.ndo_change_mtu		 = br_change_mtu,
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 99647d8..86d357b 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -27,8 +27,10 @@ static int br_pass_frame_up(struct sk_buff *skb)
 	struct net_bridge *br = netdev_priv(brdev);
 	struct br_cpu_netstats *brstats = this_cpu_ptr(br->stats);
 
+	u64_stats_update_begin(&brstats->syncp);
 	brstats->rx_packets++;
 	brstats->rx_bytes += skb->len;
+	u64_stats_update_end(&brstats->syncp);
 
 	indev = skb->dev;
 	skb->dev = brdev;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index c83519b..f078c54 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -146,10 +146,11 @@ struct net_bridge_port
 };
 
 struct br_cpu_netstats {
-	unsigned long	rx_packets;
-	unsigned long	rx_bytes;
-	unsigned long	tx_packets;
-	unsigned long	tx_bytes;
+	u64			rx_packets;
+	u64			rx_bytes;
+	u64			tx_packets;
+	u64			tx_bytes;
+	struct u64_stats_sync	syncp;
 };
 
 struct net_bridge


