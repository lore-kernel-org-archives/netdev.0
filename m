From: roy.qing.li@gmail.com
Subject: [PATCH v2] ipv6: fix the use of pcpu_tstats in ip6_tunnel
Date: Thu,  2 Jan 2014 13:20:12 +0800
Message-ID: <1388640012-16406-1-git-send-email-roy.qing.li@gmail.com>
Cc: stephen@networkplumber.org, edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:51829 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708AbaABFUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 00:20:12 -0500
Received: by mail-pd0-f169.google.com with SMTP id v10so13738224pde.14
        for <netdev@vger.kernel.org>; Wed, 01 Jan 2014 21:20:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

when read/write the 64bit data, the correct lock should be hold.

Fixes: 87b6d218f3adb ("tunnel: implement 64 bits statistics")

Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv6/ip6_tunnel.c |   21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 8d7c986..f68bcca 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -102,16 +102,25 @@ struct ip6_tnl_net {
 
 static struct net_device_stats *ip6_get_stats(struct net_device *dev)
 {
-	struct pcpu_tstats sum = { 0 };
+	struct pcpu_tstats tmp, sum = { 0 };
 	int i;
 
 	for_each_possible_cpu(i) {
+		unsigned int start;
 		const struct pcpu_tstats *tstats = per_cpu_ptr(dev->tstats, i);
 
-		sum.rx_packets += tstats->rx_packets;
-		sum.rx_bytes   += tstats->rx_bytes;
-		sum.tx_packets += tstats->tx_packets;
-		sum.tx_bytes   += tstats->tx_bytes;
+		do {
+			start = u64_stats_fetch_begin_bh(&tstats->syncp);
+			tmp.rx_packets = tstats->rx_packets;
+			tmp.rx_bytes = tstats->rx_bytes;
+			tmp.tx_packets = tstats->tx_packets;
+			tmp.tx_bytes =  tstats->tx_bytes;
+		} while (u64_stats_fetch_retry_bh(&tstats->syncp, start));
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
