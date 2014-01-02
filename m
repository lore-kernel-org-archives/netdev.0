From: roy.qing.li@gmail.com
Subject: [PATCH net-next] ipv6: fix the use of pcpu_tstats in ip6_tunnel
Date: Thu,  2 Jan 2014 08:49:40 +0800
Message-ID: <1388623780-1484-1-git-send-email-roy.qing.li@gmail.com>
Cc: edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:39738 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127AbaABAtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 19:49:40 -0500
Received: by mail-pa0-f54.google.com with SMTP id rd3so13885221pab.41
        for <netdev@vger.kernel.org>; Wed, 01 Jan 2014 16:49:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

when read/write the 64bit data, the correct lock should be hold. and use the
BUILD_BUG_ON check to ensure the syncp is last element of struct pcpu_tstats,
then reduce the copy the syncp when get the stats

Eric Dumazet <edumazet@google.com>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv6/ip6_tunnel.c |   25 ++++++++++++++++++-------
 1 file changed, 18 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 8d7c986..8eedb0c 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -102,16 +102,25 @@ struct ip6_tnl_net {
 
 static struct net_device_stats *ip6_get_stats(struct net_device *dev)
 {
-	struct pcpu_tstats sum = { 0 };
+	struct pcpu_tstats tmp, sum = { 0 };
 	int i;
 
-	for_each_possible_cpu(i) {
-		const struct pcpu_tstats *tstats = per_cpu_ptr(dev->tstats, i);
+	BUILD_BUG_ON(offsetof(typeof(tmp), syncp) !=
+		     sizeof(tmp) - sizeof(tmp.syncp));
 
-		sum.rx_packets += tstats->rx_packets;
-		sum.rx_bytes   += tstats->rx_bytes;
-		sum.tx_packets += tstats->tx_packets;
-		sum.tx_bytes   += tstats->tx_bytes;
+	for_each_possible_cpu(i) {
+		unsigned int start;
+		const struct pcpu_tstats *stat = per_cpu_ptr(dev->tstats, i);
+
+		do {
+			start = u64_stats_fetch_begin_bh(&stat->syncp);
+			memcpy(&tmp, stat, sizeof(tmp) - sizeof(stat->syncp));
+		} while (u64_stats_fetch_retry_bh(&stat->syncp, start));
+
+		sum.rx_packets += tmp.rx_packets;
+		sum.rx_bytes   += tmp.rx_bytes;
+		sum.tx_packets += tmp.tx_packets;
+		sum.tx_bytes   += tmp.tx_bytes;
 	}
 	dev->stats.rx_packets = sum.rx_packets;
 	dev->stats.rx_bytes   = sum.rx_bytes;
@@ -823,8 +832,10 @@ static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
 		}
 
 		tstats = this_cpu_ptr(t->dev->tstats);
+		u64_stats_update_begin(&tstats->syncp);
 		tstats->rx_packets++;
 		tstats->rx_bytes += skb->len;
+		u64_stats_update_end(&tstats->syncp);
 
 		netif_rx(skb);
 
-- 
1.7.10.4
