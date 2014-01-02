From: roy.qing.li@gmail.com
Subject: [PATCH] ipv6: fix the use of pcpu_tstats in ip6_vti.c
Date: Thu,  2 Jan 2014 14:24:36 +0800
Message-ID: <1388643876-31865-1-git-send-email-roy.qing.li@gmail.com>
Cc: stephen@networkplumber.org, edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:42553 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860AbaABGYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 01:24:46 -0500
Received: by mail-pd0-f181.google.com with SMTP id p10so13813680pdj.12
        for <netdev@vger.kernel.org>; Wed, 01 Jan 2014 22:24:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

when read/write the 64bit data, the correct lock should be hold.
and we can use the generic vti6_get_stats to return stats, and
not define a new one in ip6_vti.c

Fixes: 87b6d218f3adb ("tunnel: implement 64 bits statistics")
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv6/ip6_vti.c |   24 +++---------------------
 1 file changed, 3 insertions(+), 21 deletions(-)

diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index ed94ba6..a4564b0 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -75,26 +75,6 @@ struct vti6_net {
 	struct ip6_tnl __rcu **tnls[2];
 };
 
-static struct net_device_stats *vti6_get_stats(struct net_device *dev)
-{
-	struct pcpu_tstats sum = { 0 };
-	int i;
-
-	for_each_possible_cpu(i) {
-		const struct pcpu_tstats *tstats = per_cpu_ptr(dev->tstats, i);
-
-		sum.rx_packets += tstats->rx_packets;
-		sum.rx_bytes   += tstats->rx_bytes;
-		sum.tx_packets += tstats->tx_packets;
-		sum.tx_bytes   += tstats->tx_bytes;
-	}
-	dev->stats.rx_packets = sum.rx_packets;
-	dev->stats.rx_bytes   = sum.rx_bytes;
-	dev->stats.tx_packets = sum.tx_packets;
-	dev->stats.tx_bytes   = sum.tx_bytes;
-	return &dev->stats;
-}
-
 #define for_each_vti6_tunnel_rcu(start) \
 	for (t = rcu_dereference(start); t; t = rcu_dereference(t->next))
 
@@ -331,8 +311,10 @@ static int vti6_rcv(struct sk_buff *skb)
 		}
 
 		tstats = this_cpu_ptr(t->dev->tstats);
+		u64_stats_update_begin(&tstats->syncp);
 		tstats->rx_packets++;
 		tstats->rx_bytes += skb->len;
+		u64_stats_update_end(&tstats->syncp);
 
 		skb->mark = 0;
 		secpath_reset(skb);
@@ -716,7 +698,7 @@ static const struct net_device_ops vti6_netdev_ops = {
 	.ndo_start_xmit = vti6_tnl_xmit,
 	.ndo_do_ioctl	= vti6_ioctl,
 	.ndo_change_mtu = vti6_change_mtu,
-	.ndo_get_stats	= vti6_get_stats,
+	.ndo_get_stats64 = ip_tunnel_get_stats64,
 };
 
 /**
-- 
1.7.10.4
